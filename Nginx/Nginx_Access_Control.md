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

### Limit access on resource
* Limiting bandwidth
* limit_rate directive can be used to rate the bandwidth
```nginx
location /download/ {
        limit_rate 50k;
    }
```

* Limit speed per connection
```nginx
limit_conn_zone $binary_remote_address zone=addr:10m

location /download/ {
    limit_conn addr 1;
    limit_rate 50k;
}
```

* Puting limit upto somesize
* suppose if file is 100MB 50MB will be downloaded by networks speed then remaining 50MB will be downloaded by speed of 500kb/s
```nginx
location / {
    limit_rate_after 50m;
    limit_rate 500k;
```
    
