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

* worker_processes
* This directive controls *how many worker processes you want*
```nginx
worker_processes auto;

OR

worker_processes 4;
```

* It is common practise to run 1 worker per cpu core
* Worker process directive belongs to Global context
