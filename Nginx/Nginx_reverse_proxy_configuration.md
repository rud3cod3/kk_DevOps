### Configuring nginx reverse proxy

#### Overview

* This document explains how to configure Nginx as a Reverse Proxy on one machine (public-facing) and route requests to two backend application servers

**Architecture Summary**

| Machine       | Role                  | Purpose                                                                                    |
| ------------- | --------------------- | ------------------------------------------------------------------------------------------ |
| **Machine 1** | Reverse Proxy (Nginx) | Only public-facing server; receives all user traffic and decides where to forward requests |
| **Machine 2** | Application Server A  | Runs App-1, reachable only from Machine 1 (private network)                                |
| **Machine 3** | Application Server B  | Runs App-2, reachable only from Machine 1 (private network)                                |

**High-Level Flow**

1. Client → hits public IP of Machine 1
2. Machine 1 (Nginx) → checks request path
3. Nginx forwards request internally:
    * /app1 → Machine 2
    * /app2 → Machine 3
4. Nginx returns the backend's response to the client

*The client never knows Machine 2 or Machine 3 exist*

**Why Use a Reverse Proxy?**
1. Security
2. Centralized Control
3. Scalability
4. Cleaner Architecture

**Understanding How Traffic Moves**

**Step 1: Client Sends Request**
```bash
GET http://yourdomain.com/app1/products
```
Client’s browser resolves the domain → gets public IP of Machine 1

**Step 2: Machine 1 (Nginx) Receives It**
Nginx looks at the incoming request path
* */app1/*
* */app2/*

**Step 3: Nginx Forwards to Correct App Server**
*If request path begins with /app1, Nginx removes that prefix and forwards the request to*
```bash
http://10.0.1.10:3000/
```
*(similarly, /app2 → 10.0.1.11:3000)*

**Step 4: Backend Server Responds**
*Machine 2 or 3 returns*
```bash
HTTP/1.1 200 OK
```
*with data*

**Step 5: Nginx Sends Response Back to Client**
*The client thinks everything came from Machine 1*

### Configuration Setup (Machine 1 – Reverse Proxy)
**Install Nginx**
```bash
sudo apt update
sudo apt install nginx -y
```

**Create Reverse Proxy Configuration**
*Edit site config*
```bash
sudo vim /etc/nginx/sites-available/reverse.conf
```

*Paste*
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # Requests for APP SERVER A
    location /app1/ {
        # Send to Machine 2
        proxy_pass http://10.0.1.10:3000/;

        # Pass important headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Requests for APP SERVER B
    location /app2/ {
        # Send to Machine 3
        proxy_pass http://10.0.1.11:3000/;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

**Enable Site**
```bash
sudo ln -s /etc/nginx/sites-available/reverse.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Backend Application Server Setup (Machine 2 & 3)**
* Both machines should:
    * Run the application on an internal port like 3000
    * Only allow inbound traffic from Machine 1's private IP
    * Have firewalls block everything else

**Example:Machine 2 (APP)**
```bash
node app1.js   # running on 3000
```

*Machine 3 (App2) is similar*

**What the Reader Should Clearly Understand**

* This architecture:
    * Keeps only one machine public
    * Hides application servers completely
    * Nginx becomes the single point of entry
    * Paths (/app1, /app2) decide backend routing
    * Backends operate privately and securely
    * Nginx returns the response as if it generated it
    * Client is unaware of internal infrastructure
    * Easy to scale without changing external behavior

**Diagram (Conceptual)**
```bash
   INTERNET
       |
       v
┌───────────────────────────┐
│  Machine 1 (Reverse Proxy)│   Public IP
│       Nginx               │
└───────┬─────────┬─────────┘
        |         |
        |         |
        v         v
┌──────────────┐ ┌──────────────┐
│ Machine 2    │ │ Machine 3    │
│ App Server A │ │ App Server B │
│ 10.0.1.10    │ │ 10.0.1.11    │
└──────────────┘ └──────────────┘
```

**Optional: Load Balancing (If App1 & App2 Are Same Service)**
```nginx
upstream backend_cluster {
    server 10.0.1.10:3000;
    server 10.0.1.11:3000;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend_cluster;
    }
}
```

**Summary**
* This 3-machine structure is a production-grade architecture used in real-world deployments because:
    * It isolates exposed components
    * It enforces security boundaries
    * It gives flexibility for routing, scaling, SSL, caching
    * It keeps backend logic simple and behind the firewall

### NGINX : X-ReaL-IP-Directive

**COMMON ARCHITECTURE**

```bash
+----------+                    +---------+                     +----------+
|          |    ---------->     |         |     ---------->     |          |
|  Client  |    <----------     |  NGINX  |     <----------     |  ACTUAL  |
|          |                    |         |                     |  SERVER  |
+----------+                    +---------+                     +----------+
```

**Some problem we have to think of**
When the request comes from client to nginx, nginx will transfer it to the application servers. now suppose if there are multiple clients how does the application server supposed to know which to responsd to beacuse it is getting request from the nginx reverse proxy server in such cases we can make use of this x-real-ip-directive

**Solution**
To resolve this problem we will have to make use of nginx module
```bash
nginx http realip module
```

**Now get all the *configure arguments***
```bash 
nginx -V
```

**Output**
```bash
configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-aSXKE0/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/build/nginx-aSXKE0/nginx-1.18.0/debian/modules/http-geoip2 --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
```

**Installation**

* Go to dir where we extracted the source code of nginx
```bash
cd /opt/nginx
```

* now run configure with the all the preveous configure arguments and the added real-ip-module
```bash
./configure configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-aSXKE0/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/build/nginx-aSXKE0/nginx-1.18.0/debian/modules/http-geoip2 --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module [[**--with-http_realip_module**]]
```

* Then run
```bash 
make install
```

**Now edit the nginx.conf file again with this things**
```nginx
# Add this to the server which is acting as reverse proxy

location / {
    proxy_pass http://**Server_Ip**;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;        
}
```

**Now reload the nginx**
```bash 
nginx -s reload
```

**Now add this where application nginx server is running add this into the http context**
```nginx
log_format speciallog '$http_x_real_ip - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agnet" $remote_addr';

access_log /var/log/nginx/access-special.log specialog;
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log
```

**Now again use**
```bash
nginx -t
nginx -s reload
```
 
