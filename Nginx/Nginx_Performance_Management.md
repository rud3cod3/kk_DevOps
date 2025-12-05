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
