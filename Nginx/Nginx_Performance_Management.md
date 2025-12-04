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
