### Client Side Caching in NginX

* **Client Caching:** We will learn how all browsers supports client-side caching
* Web servers do not control **client-side caching** to full extent, obviously, but they may issue recommendations about what to cache and how, in the form of special **HTTP response headers**
* **Cache-control Header** this is the most important header to set as it effectively 'switches on' caching in the browser
* Without this header the browser will re-request the file on each subsequent request

* **Cache Header Value**
- **Public** - Public resources can be cached not only by the end-user's browser but also by any intermediate proxies that may be serving many other users as well.
*Cache-Control:public*
- **Private** - Private resources are bypassed by intermediate proxies and can only by end-client
*Cache-Control:private*
- **max-age** - Indicating the maximum amount of time it can be cached before considered stale.This value sets a timespan for how long to cache the resource (in seconds)
*Cache-Control:public, max-age=31536000*
- **Expire** - When accompanying the cache-control header, **Expire** simply sets a date from which the cached resource should no longer be considered valid
- From this date forward the browser will request a fresh copy of the resource. Until then, the browser local cached copy will be used
- if both Expires and max-age are set max-age will take the precedense
```nginx
location = /port.jpg {
    return 200 "Hello this is Dummy Location";
    add_header Cache-Control public;
    add_header pragma public; # Pragma is the earlier header before cache-control, old
    add_header Vary Accept-Encoding;
    expires 1M;             # Expiry set to 1 Month  
} 
```

### Gzip response at server side
- How fast a website will load depends on the size of all the files that have to be downloaded by the browser
- Reducing the size of files to be transmitted can make the website not only load faster, but also cheaper to those who have to pay for their bandwith usage
- Response file can be minimized by configure Nginx to user gzip to compress files it server on the fly
- Compress file use up server resources, so it is best to compress only those files that will reduce its size considerably in result
```nginx
http {
    include mime.types;
    
    gzip on;
    gzip_comp_level 4;      # there are total 0 to 10 level the more higher level we describe the more system resource it will use to archive all response so use which can create a balance
    gzip_types text/plain text/css application/json;
}
```

### Micro cache in Nginx

* Micro caching is limited
* Caching **Static content** such as images, javascript and css files, and web content that rarely changes is a relatively straightforward process.
* Can we cache dynamic content too?
```bash
**Static content**                          **Dynamic content**                                     **Personlaized Content**
*Images, CSS,                               Blog posts, status pages                                Shopping cart,
simple web                                                                                          account data
pages                                       <========================>

**Easy to cache**                           **Micro-cacheable ?**                                   **Cannot cache**
```

* caching **personalized content** (that is, content customized for each user by the server application) is generally not possible, beacuse the server's response differs for every request for the same resource.

* **Dynamic content** - This content can change unpredictably, but is not personanlized for each user (or is personalized using javascript on the client device)
* Example of dynamic content suitable for caching include
    * The front page of a busy news or blog site, where new articles are posted every few seconds
    * An RSS feed of recent information
    * The status page for a continuos integration (CI) or build platform
    * An inventory, status, or fundraising  counter
    * Lottery results
    * Calender events
    * Personalized dynamic content is generated on the client device, such as advertising content or data ("hello, your name") that is calculated using cookie data

*  **micro caching** is used to cache the dynamic content
* *Microcaching* is a caching technique whereby content is cached for a very short perfiod of time
* **Nginx** uses a persistent disk-cache located in somewhere in the local file system

```bash

    
+----------+                    +----------+                                +------------+
|          |  Dynamic Request   |          |   php-fpm process for req      |            |
|  Client  |  -------------->   |  Nginx   |   ---------------------->      |  Php-fpm   |
|          |  <--------------   |          |   <----------------------      |            |
+----------+  Response HTML     +----------+   Response data                +------------+
                                                                                  
                                     🡇                                           🡇     Reuest Processing
                                                                             
                              +-------0--------+                             +-------------+     
                              | Stores data in |                             |             |
                              | Local disk for |                             |     DB      |
                              | Short time     |                             |             |
                              +----------------+                             +-------------+
```
* **fast-cgi** is widely-used protocol for interfacing interactive application such as **PHP** with web servers such as NGINX 
* The main advantage of **FCGI** is that manages multiple CGI requests in a single process
* Under NGINX, the fasrcgi content cache is declared using a directive called *fastcgi_cache_path* in the top-level **http{}** context, within the NGINX configuration structure
* *fastcgi_cache_key* can be used for caching

#### fastcgi_cache_path Directive Parameters 

*  **/var/cache/nginx** - the path to the local disk directory for the cache
* **levels** - defines the hierachy levels of a cache, it sets up a two-level directory hierachy under /var/cache/nginx
* **keys_zone** - enables the creation of a shared memory zone where all active keys and information about data are stored.Note that storing the keys in memory speeds up the checking process, by making it easier for NGINX to determine whether it's a MISS or HIT, without checking the status on disk
* **inactive** - specifies the amount of time after which cached data that are not accessed during the time specified get deleted from the cache regardless of their freshness
* **max_size** - specifies the maximum size of cache

**fastcgi_cache_key Directive Parameters**
    - NGINX uses them in calculating the key of a request. Importantly to send a cached response to the client, the request must have the same key as a  cached response
    - **$scheme** - request scheme, HTTP or HTTPS
    - **$request_method** - request method, usually "GET" or "POST"
    - **$host** - this can be hostname from the request  line, or hostname from the "Host" request header field, or the server name matching a request, in the order the of precedence
    - **$request_uri** - means the full original request URI

### LAB for micro caching in nginx
To do it define fastcgi cache path in http context block

```nginx
fastcgi_cache_path /tmp/cache_nginx level=1:2 keys_zone=ZONE_1:100m inactive=60m;
fastcgi_cache_key "$scheme$request_method$request_uri";
```

* Now go to php location block add this there
* This will cache all the php cache to zone 1 which is in /tmp/cache_nginx
```bash
fastcgi_cache ZONE_1;
fastcgi_cache_valid 200 60m;
```

* Now to test it use apache-bench
* Install it first
```bash
apt-get -y install apache2-utils
```
* user ab command for the installation verification
```bash
ab
```
* ab to send 200 request with 20 connection
```bash
ab -n 200 -c 20 http://domain.com:80/
```


***strictly for refrence***
```nginx
 NGINX Configuration File - (You need to update server name and other related content)

user www-data;
worker_processes auto;
load_module /etc/nginx/modules/ngx_http_image_filter_module.so;
events {
worker_connections 1024;
}
http {
    include mime.types;
	fastcgi_cache_path /tmp/cache_nginx levels=1:2 keys_zone=ZONE_1:100m inactive=60m;
	fastcgi_cache_key "$scheme$request_method$host$request_uri";
	add_header X-Cache $upstream_cache_status;
    server {
	listen 80;
	server_name 104.131.80.130;
	root /bloggingtemplate/;
	index index.php index.html;
	location / {
   		try_files $uri $uri/ =404;
  	}
	location ~\.php$ {
      		# Pass php requests to the php-fpm service (fastcgi)
      		include fastcgi.conf;
      		fastcgi_pass unix:/run/php/php7.2-fpm.sock;	
		fastcgi_cache ZONE_1;
		fastcgi_cache_valid 200 60m;
	}
    }
}
```
