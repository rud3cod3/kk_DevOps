### Text Direction : Building NGINX from Source Code

1. Update Packages
```bash
Ubuntu - apt-get update
CentOS - yum update
```

2. Download the NGINX source code from nginx.org
```bash
https://nginx.org/download/nginx-1.19.1.tar.gz
```

3. Unzip the file.
```bash
tar -zxvf nginx-1.19.1.tar.gz
```

4. Configure source code to the build.
```bash
./configure
```

4. Install code compiler
```bash
Ubuntu : apt-get install build-essential
CentOS : yum groupinstall "Development Tools"
```

5. Configure source code to the build.
```bash
./configure
```

6. GET Support Libraries
```bash
Ubuntu : apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev make
CentOS : yum install pcre pcre-devel zlib zlib-devel openssl openssl-devel make
```

7. Execute configuration again
```bash
./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
```

8. Compile and install Nginx
```bash
make
make install
```
