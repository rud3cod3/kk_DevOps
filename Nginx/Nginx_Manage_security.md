### NGINX Security & SSL Notes
**Implementing SSL**

```bash
+---------+                           +---------+
|         | <-------- Step 1 -------- |         |
| Browser |                           | Server  |
|         | -------- Step 2 ------->  |         |
|         | <-------- Step 3 -------- |         |
|         | -------- Step 4 ------->  |         |
+---------+                           +---------+
```

1. Browser → Server: ClientHello
*Browser sends:*
- Supported TLS versions
- Supported ciphers
- Random number (client_random)
*Handshake begins*

2. Server → Browser: ServerHello + Certificate
*Server sends:*
- Selected cipher
- Random number (server_random)
- SSL certificate (contains server public key)
- Optional key exchange parameters (e.g., ECDHE)
*Browser verifies certificate using trusted CAs.*

3. Browser Creates the Session Key
**Old RSA handshake**
- Browser encrypts session key using server’s public key
- Sends it to server
**Modern TLS (ECDHE — recommended)**
- Browser & server perform a Diffie–Hellman key exchange
- Both independently derive the same session key
- **Key is never transmitted** → Perfect Forward Secrecy (PFS)

4. Server Confirms Key
*Server:*
- Decrypts session key (RSA) or
- Completes ECDHE
- Derives same session key
- Sends encrypted Finished message
*Confirms successful key negotiation.*

5. Symmetric Encryption Begins
*Both sides now share:*
- One symmetric session key (AES)
- Used for fast encryption of all future communication
*Symmetric encryption is much faster than public-key crypto.*

### Setting up SSL in NGINX
```bash
# Navigate to nginx directory
cd /etc/nginx

# Create ssl directory
mkdir -p ssl

# Generate a self-signed certificate
openssl req -x509 -days 100 -nodes -newkey rsa:2048 \
-keyout /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.cert
```

*Update NGINX:*

```bash
server {
        listen 443 ssl;
        server_name agneypatel.info;

        ssl_certificate     /etc/nginx/ssl/self.cert;
        ssl_certificate_key /etc/nginx/ssl/self.key;
}
```

*restart*

```bash
sudo systemctl restart nginx
```

### Enable HTTP/2

**Why HTTP/2?**
- HTTP/1.1 → 1 request per TCP connection
- Browsers opened many connections (waste of network resources)

**HTTP/2 introduces:**

**Multiplexing**
- Multiple streams over a single TCP connection. No blocking.

**Server Push**
- Server sends assets before client asks.

**Binary Protocol**
- Faster, safer, avoids text-based vulnerabilities.

**HPACK Header Compression**
- Stateful compression reduces repeated header overhead.

**Benefits**
- Faster web performance
- Lower latency
- Better mobile performance
- More efficient bandwidth usage

### Enable HTTP/2 in NGINX

*Check compile arguments:*
```bash
nginx -V
```

*Recompile:*
```bash
./configure <existing-flags> --with-http_v2_module
```

*Enable in server block:*
```nginx
server {
        listen 443 ssl http2;
}
```

*Reload:*
```bash
nginx -s reload
sudo systemctl restart nginx
```

### NGINX Rate Limiting
NGINX allows limiting the number of HTTP requests a client can make per second.

**Use cases**
- Throttle brute-force login attempts
- Handle burst traffic
- Prevent DDoS by slowing attackers
- Control abusive APIs
* NGINX uses the leaky bucket algorithm.

### Configure Rate Limit

1. Install Siege (for testing)
```bash
apt install siege
```

2. Test with Siege
```bash
siege -v -r 2 -c 5 http://<URL>
```

### Core NGINX Rate Limit Directives

**limit_req_zone**
*Declared in the http block:*
```bash
limit_req_zone $binary_remote_addr zone=test_zone:10m rate=1r/s;
```

**Meaning:**
- Create a zone named test_zone
- Store 10MB of state
- Allow 1 request per second per IP;

### Using limit_req (with burst and nodelay)
1. Burst
- Allows temporary spikes above the rate limit.

2. nodelay
- Processes the burst immediately instead of queueing.

### Final Recommended Configuration

In your *server* or *location* block:
```bash
limit_req zone=test_zone burst=5 nodelay;
```

**This means:**
- **rate = 1 request per second**
- **burst = 5 extra requests allowed instantly**
- **nodelay = no waiting — extra requests are processed immediately**
        If burst capacity is exceeded → 503 error

### Behavior Example

| Incoming Requests              | Result            |
| ------------------------------ | ----------------- |
| 1 req/sec                      | Allowed           |
| Quick burst of 4 more          | Allowed (burst=5) |
| 6th request in the same moment | **Blocked**       |
| Requests slow down             | Back to normal    |


# NGINX Rate Limiting — Deep Dive (with Diagrams + Hardening)

### 1. Leaky Bucket Algorithm (Simple ASCII Diagram)
```bash
        Incoming Requests
        ───────────────────►   ┌──────────┐
                               │  BUCKET  │  ← holds queued requests
                               └────┬─────┘
                                    │ leak at fixed rate (1 req/sec)
                                    ▼
                                ┌────────┐
                                │ NGINX  │ → processes request
                                └────────┘
```

### 2. Burst + Nodelay Explained Visually
**A. burst without nodelay**
*Requests queue like this:*
```nginx
Client sends:   █ █ █ █ █
Processing:     1 req/sec
Behavior:       Allowed (queued), Allowed, Allowed, Allowed, Allowed
```
- Slows the attacker.
- Smooth experience for real users.

**B. burst with nodelay**
*Requests get accepted instantly, up to the burst limit.*
```bash
Client sends:   █████  (5 instant requests)
Behavior:       Allowed Allowed Allowed Allowed Allowed
6th request → REJECTED
```

### 3. Full Production-Grade Configuration
**Inside http block**

```bash
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=login_limit:10m rate=1r/s;
```

- 5 req/sec for general APIs
- 1 req/sec for login endpoints

**Inside server/location block**
- **General API rate limit**
```nginx
location /api/ {
    limit_req zone=api_limit burst=20 nodelay;
}
```

**Aggressive limit for login**
(Slow down brute force attacks)
```nginx
location /login {
    limit_req zone=login_limit burst=3 nodelay;
}
```

*If attacker sends a huge burst:*
- First 3 allowed
- Everything after 3 discarded immediately

### 4. Combine Rate Limit + WAF-Style Security Headers
Add to *server* or *http* block:

```nginx
# Prevent clickjacking
add_header X-Frame-Options "SAMEORIGIN";

# Prevent MIME sniffing
add_header X-Content-Type-Options "nosniff";

# Prevent XSS
add_header X-XSS-Protection "1; mode=block";

# HSTS (HTTPS only)
add_header Strict-Transport-Security "max-age=31536000" always;

# Remove NGINX version for security
server_tokens off;
```

### 5. Add IP Blacklisting (Simple WAF Rule)
*Temporary ban for malicious IPs:*
```nginx
geo $block_ip {
    default 0;
    45.19.0.10 1;
    102.33.44.55 1;
}

server {
    if ($block_ip) {
        return 403;
    }
}
```

### 6. Rate Limit Logging for Attack Monitoring
*Add this inside http block:*
```nginx
log_format limit '$binary_remote_addr - $request '
                'rate_limited=$limit_req_status';

access_log /var/log/nginx/rate_limit.log limit;
```

*This shows:*
1. PASSED
2. DELAYED
3. REJECTED
*Perfect for SIEM monitoring.*

### 7. Advanced (Optional) — Per-User Token Bucket
*Rate limit based on user ID instead of IP:*

```nginx
map $http_authorization $user_key {
    default $binary_remote_addr;
}
limit_req_zone $user_key zone=user_bucket:20m rate=10r/s;
```

*This prevents:*
- A NAT network from being rate-limited unfairly
- Attackers using rotating IPs from bypassing limits

### 8. Final Master Diagram — End-to-End Request Flow
```bash
Browser
   │
   ▼
NGINX (front door)
   │
   │ Rate limit check (limit_req_zone)
   ▼
Allowed? ──► NO → 503 Reject
   │
   YES
   ▼
WAF Security Headers
   ▼
Proxy / upstream / PHP-FPM / app
   ▼
Response to client
```
