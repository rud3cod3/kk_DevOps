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

### 2️⃣ Nginx Sees “This is PHP — I cannot run it”
Config example:

```nginx
location ~ \.php$ {
    fastcgi_pass unix:/run/php/php8.2-fpm.sock;
}
```

**“Send PHP files to PHP-FPM.”**
