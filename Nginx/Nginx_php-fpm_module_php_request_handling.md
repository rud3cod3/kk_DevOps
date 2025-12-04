# How Nginx Handles PHP-FPM (Easy Explanation)

##  Big Picture
Nginx **does NOT run PHP itself**.  
It only:
- Serves **static files**  
- Forwards **PHP files** to PHP-FPM

Think of:
- **Nginx = Traffic police**
- **PHP-FPM = Team of PHP workers**

##  How Nginx Handles PHP-FPM

###  Request Comes In
User visits:

*https://example.com/index.php*

Nginx receives the request.

### Nginx Sees “This is PHP — I cannot run it”
Config example:

```nginx
location ~ \.php$ {
    fastcgi_pass unix:/run/php/php8.2-fpm.sock;
}
```

**“Send PHP files to PHP-FPM.”**

### Understanding the Processes

* Nginx Starts
    * 1 master process
    * Multiple worker processes (receive HTTP requests)

* PHP-FPM Starts
    * 1 master process
    * Multiple PHP worker processes (execute PHP code)

### Request Flow Example

Example Request: /home.php

1. Nginx worker receives request
2. Sees .php → forwards to PHP-FPM
3. PHP-FPM worker runs home.php
4. Output returned to Nginx
5. Nginx sends it to browser

### Why Multiple Processes?
* **Nginx:**
    * Event-based
    * Each worker handles many requests

* **PHP-FPM:**
    * Blocking
    * Each worker handles one PHP request at a time

* Example config
```bash
pm.max_children = 10
```

### Real-Life Analogy
* **Nginx = Hospital Receptionist**
    * fast
    * Decides where users go

* **PHP-FPM = Doctors**
    * *Each doctor treats one patient at a time*


### Static vs Dynamic Example
```bash
/var/www/html/style.css → Static → Nginx serves it  
/var/www/html/index.php → Dynamic → Nginx sends to PHP-FPM  
```

### Suppose you want to run a PHP file using Nginx or any dynamic site — you must install PHP-FPM first

1. Install PHP-FPM
```bash
apt update
apt install php7.2-fpm
```

2. Now understand this:
* The **location block** tells Nginx how to handle all *.php* requests.
* When Nginx receives a request like *index.php*, it cannot execute PHP, so it forwards that request to **FastCGI.**
* FastCGI is the **communication protocol** used between Nginx and PHP-FPM.
* So the flow is:
    * Request comes → Nginx receives it
    * Nginx sees it’s a *.php* file
    * Nginx forwards it to PHP-FPM using FastCGI
    * PHP-FPM executes the PHP code
    * PHP-FPM sends back the output
    * Nginx sends that output to the user
* That’s why in the location block we specify that all PHP requests should be handled by FastCGI (PHP-FPM)
* Nginx and PHP-FPM need a **common communication channel**, and that channel is provided by the socket file or sometimes a **TCP port**
* *fastcgi_pass* tells Nginx **where PHP-FPM is listening** so they can talk to each other.
```nginx
# nginx.conf

location ~ \.php$ {
    include fastcgi.conf;
    fastcgi_pass unix:/run/php/php7.2-fpm.sock;
}
```
* A **502** usually means **Nginx could not communicate with PHP-FPM**
* Common reasons:
    * PHP-FPM service is **not running**
    * Socket file permissions mismatch
    * Wrong socket path in *fastcgi_pass*
    * PHP-FPM crashed / is overloaded
* By default:
    * Nginx **master** runs as **root**
    * Nginx **worker processes** run as *www-data* (or nginx user)
* **Simple fix**
```nginx
user www-data;
```
* Then reload nginx
```bash
nginx -s reload
```

### Nginx Performance Optimization

**Worker labs / worker performance optimization**

When Nginx runs, you generally see:

* **Master process**
    * Started by root
    * Manages workers (start, reload, stop)
    * Does NOT handle client traffic

* **Worker processes**
    * Started by master
    * Handle all client connections
    * Do the heavy lifting

* **worker_processes**
* This directive controls *how many worker processes you want*
```nginx
worker_processes auto;

OR

worker_processes 4;
```

* It is common practise to run 1 worker per cpu core
* Worker process directive belongs to Global context

* **worker_connections**
* This tells each worker how many simultaneous connections it can handle.
```nginx
worker_connections 1024;
```

* **Important**
    * Connections ≠ clients
    * One client may use **multiple connections** (e.g., keepalive, assets, HTTP/2)
    * Total possible connections =
```nginx
worker_processes × worker_connections

**Example**
4 workers × 1024 connections = 4096 total connections
```
    
* You are setting how many connections a worker can handle
* A connection = one request or one open channel
* Clients can use multiple connections
* So worker_connections does **not directly equal number of clients**, but number of simultaneous sockets
* context of chile events context
* default value is 768;however, considering that every browser usually opens up at last 2 connection/server, this number cab half

**Buffer**
- Another aspect to manage nginx performance
- Here for to understand consider buffer as post request which has some data this data will be stored in ram if buffer size is too low the system will be forced to write this data into temporary file which will cause the disk read and write constantly which will ultimately slow down nginx server

1. **client_body_buffer_size**
- This handles the client buffer size meaning any POST actions sent to nginx. POST actions are typically form submission

2. **client_header_buffer_size**
- Similar to the preveous directive, only instead it handles the client header size

3. **client_max_body_size**
- The maximum allowed size for a client request. If the maximum size is exceeded, then Nginx will split out a 413 error or Report Entity Too Large

4. **large_client_header_buffer**
- The maximum number and size of buffers for large client

5. **Timeout**
- request timeouts

6. **client_body_timeout** and **client_header_timeout**
- This directives are responsible for the time a server will wait for a client body or client header to be sent  after request. If neither a body or header is sent, the server will issue a **408** error or Request timeout

7. **keepalive_timeout**
- Assigns the timeout for keep-alive connections with the client. Nginx will close connection with the client after this period of time

8. **send_timeout** 
- Established not on the entire transfer of answer, but only between two operation of reading; if after this time client will take nothing, then Nginx is shutting down the connection 

9. **Gzip compression**
- Gzip can help reduce the amount of network transfer Nginx deals with. However, be carefull increasing the *gzip_comp_level* too high as the server will begin wasting cpu cycles

10. **Static file caching**
- It's possible to set expire headers for files that don't change and are served regularly. This directives can be added to the actual Nginx server block



### Modules in the nginx
* Go to /etc/nginx/modules if modules directory is not in there it mean there are no modules added and we need to add them 
* use this command it will show you all the default configuration
```bash
nginx -V
```
* Store output of above given command 
* Download the source code of nginx and unzip it 
* Navigate yourself to dir and then run this commands
```bash
# Here
# configure is main configuration file which will give out bin file for nginx
# output of nginx -V (capital V) 
# at last modules that we want to add in this case [[** --modules-path=/etc/nginx/modules **]]

./configure [Here add output of the nginx -V command] --modules-path=/etc/nginx/modules

# Them use [[** make **]] command
make
make install 
```
* Now to use this module which we recently added add this content in nginx.conf
```nginx
# add path of module after load_module prefix in global context
load_module /etc/nginx/modules/ngx_http_image_filter_module.so*
```
