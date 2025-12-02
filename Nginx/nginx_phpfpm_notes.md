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
