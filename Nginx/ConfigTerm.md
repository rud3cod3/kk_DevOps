### Nginx Configuration Terminology

Main file located at 
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
    ```
    types {
        text/html html;
        text/css css;
    }   
    ```

    ### OR

    # Insted of defining all things manually we can define mine.type
    ```  
    includes mine.types;
    ```
    * This file supports all the extensions which are needed to run code sucessfull.
    ``` 
    server {
    
    # This line defines server is listning on port 80    
    listen 80;      

    # This line defines where to accept request from
    # If we have qualified domain name we can provide domain name aswell, eg . agneypatel.info
    server_name 193.22.11.22;

    # This file defines where to server files from
    # Files will be served from this directory
    root /var/www/html/site_name
    ```
    }
}
```
