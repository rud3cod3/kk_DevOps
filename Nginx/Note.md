### NGINX — Short, Production-Focused Note

### What NGINX Is
#### NGINX is a high-performance, event-driven web server commonly used as:
* Reverse Proxy
* Load Balancer
* Static File Server
* API Gateway
* TLS Termination Point
#### Its asynchronous, non-blocking architecture makes it ideal for heavy concurrent traffic (SRE/DevOps critical).

### Key Features (SRE/DevOps Highlights)

1. Reverse Proxy
```bash
location / {
    proxy_pass http://backend_app;
}
```

2. Load Balancing
```bash
# Supports round-robin, least_conn, IP-hash
upstream backend_app {
    least_conn;
    server 10.0.2.10;
    server 10.0.2.11;
}
```

3. SSL/TLS Termination
```bash
server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
}
```

4. Rate Limiting (SRE-critical)
```bash
# Protects upstream services
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=5r/s;
```

5. Caching
```bash
proxy_cache_path /var/cache/nginx keys_zone=my_cache:10m;
```

6. Observability Hooks
* Access logs
* Error logs
* *stub_status* module for metrics scraping
```bash
location /nginx_status {
    stub_status;
    allow 127.0.0.1;
    deny all;
}
```

### Essential NGINX Commands (Ops Ready)

#### Install
```bash
sudo apt install nginx     # Debian/Ubuntu
sudo systemctl enable --now nginx
```

#### Service Mgmt
```bash
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl reload nginx     # no downtime
```

#### Check Config
```bash
sudo nginx -t
```

#### Test after editing
```bash
sudo nginx -s reload
```

#### Logs
```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

#### Validate upstream health
```bash
curl -I http://localhost
```
