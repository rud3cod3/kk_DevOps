### Nginx cache entry

```bash

    +-----------+           +-----------+           +-----------+
    |           |           |           |           |           |
    |   Nginx   |  =====>   |  cache    |  =====>   | Main App. |
    |           |           |  server   |           | Server    |
    +-----------+           +-----------+           +-----------+

```

### Cache content header
- A cache-control is an HTTP header used to specify **browser caching** policies in both client reuests and server response

**Cache-Control: Max-Age** 
- The max-age request directives defines, in seconds, the amount of time it takes for a cached copy of a resource to expire. After expiring, a browser must refresh its version of the resource by sending another request to a server
- For example, **cache-control: max-age=120** means that the returned resource is valid for 120 seconds, after which the browsers has to request a newer version

**Cache-Control: No-Cache**
- The no-cache directives means that a browser may cache a response, but must first submit a validation request to an *origin server*

**Cache-Control: No-store**
- The no-store directives means browsers aren't allowed to cache a response and must pull it from the server each time it's requested. This setting is usually used for sensitive data, such as personal banking details

**Cache-Control: Public**
- The public reponse directive indicates that a resource can be cached by any cache

**Cache-Control: Private**
- The private response directive indicates that a resource is user specific-it can still be cached, but only on a client device

### Stop caching jpg file
```nginx
# In server block define

server {
    location {
        add_header Cache-Control no-store;
    }
}
```

**Problem** - Suppose client asked for some file and proxy server served it but what if the application server has made some changes to the main file at the webserver. The proxy server might not share the updated file that coule create a problem in order to overcome that problem we use **if-modified** header

**if-modified-Since HTTP Header** 
- If-Modified-Since header indicates the time for which a browser first downloaded a resource from the server.This helps determine wether or not the resource has changed since the last time it was accessed.
