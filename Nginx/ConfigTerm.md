### Nginx Configuration Terminology

Main configuration of nginx file is located At :
```bash
cat /etc/nginx/nginx.conf
```

### To check configuration
```bash
nginx -t

# Now reload the nginx not restart nginx
nginx -s reload

# To check logs for it
cat /var/log/nginx* | tail

# To check the status of any file (to check it wether it is being served or not)
curl -I localhost/assets/css/style.css
# If we get response 200 everything is good
```

### Conf file help man
```bash
event {
}


http{
    
    # Why types ?
    # Bydefault nginx will read all files as text and html we need to let know nginx that what is what like css is css and js is js so thats why type block is there
    
    types {
        text/html html;
        text/css css;
    }   
    
    ### OR
    
    # Insted of defining all things manually we can define mine.type
    # This file supports all the extensions which are needed to run code sucessfull. 
    
    include mine.types;
    

    server {
    
    # This line defines server is listning on port 80    
    listen 80;      

    # This line defines where to accept request from
    # If we have qualified domain name we can provide domain name aswell, eg . agneypatel.info
    server_name 193.22.11.22;

    # This file defines where to server files from
    # Files will be served from this directory
    root /var/www/html/site_name
    
    # Location 
    # Always keep location context into the server context since the location is a child context
    # When we open link like localhost/images the location context comes into the picture it let server know which page or content needs be served
    # Here aboutus will return 200 response code and string message
    location /aboutus {   
        return 200 "You have got it"
        }
    # Here we can make use of multiple identifiers
    # = it will match exact page like if ```location = /contactus it will serve contactus page only if we write it like ContactUs it will return 404
    # ~ means case sensitive
    # ~* means Not case senstive 
    
    # Priority
    
    1. Exact Match                  =  URI
    2. Preferential Prefix Match    ^~ URI
    3. Regex Match                  ~* URI 
    }
}
```


### Variables in nginx
We can make use of variables in nginx (string values)

#### To set value
```bash
set $a "agneypatel.info";

$args - List of arguments on the request line
$body_bytes_sent - Number of bytes sent to the client
$byets_received - Number of bytes received from a client
$connection_request - Current number of connection made via connection
$date_local - Current time in local time zone
$hostname - hostname
$nginx_version - nginx version

### Using variable and args to serve back response
### Add this in nginx.conf file
### args are the one which we pass into url

location /find {
    return 200 "$hostname \n $args \n $connection_requests \n $nginx_version";
}

### We can also use conditional statements

server {
    if  ( $arg_name = "Agney Patel"){
        return 200 "HELLO YOU ARE TALKING TO AGNEY PATEL"
    }
    location /find {
        return 200 "$hostname \n $args \n $connection_requests  \n $nginx_version
    }
}

### Now if we access localhost/find?"agneypatel"

it will return argsname = agneypatel
```

### Return and Rewrite in nginx.conf

#### Return Directive
* Return is the simpler directive to use compare to NGINX rewrite
* Lower resource consumption than rewrite
* Return must  be enclosed within a *server* or *location* block which defines which URL should be rewritten

#### Rewrite Directive
* This Directive needs to be in a *location* or  *server* lock in order to rewrite the URL 
* Rewrite directive can be used to perform granular tasks as with it you can perform more complicated URL distinctions such as:
    * Capture elements in the original URL
    * Change or add elements in the path
* Syntax
```bash    
rewrite regex URL;
```
* Rewrite directives does not send a redirect to the client in all cases. If the rewritten URL matches with another following directive, Nginx will rewrite the URL again.


### try_files
* It is used to chech wether specified directories exists or not
* Always write it into server block
* This will redirect request to /video whenever we hit lovalhost/testobject
```bash
try_files testobject /video
```
* Whenever the request for localhost/testobject is made the response of that object will be given and if the object is not found the second parameter in our example which is video will be reponded
