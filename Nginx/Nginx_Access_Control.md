### Nginx Access Control

- NGINX has inbuilt capability for Accept and Deny traffic on IP basis
- Allow Traffic from specific IP
```bash
location /admin {
            allow 190.99.00.071;
            deny all;
}
```

* Suppose there are multiple ip's in order to allow it create a file in /etc/nginx with name **whitelist** and add all the ip's in it
```bash
cd /etc/nginx
vim whitelist
```

* Open nginx configuration
```bash
vim /etc/nginx/nginx.conf
```

```nginx
include /etc/nginx/whitelist;
```

* reload the nginx
```bash
nginx -s reload
```
