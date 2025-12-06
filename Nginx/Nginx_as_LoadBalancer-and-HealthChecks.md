### Load balancing in Nginx

**Load balancer performs the following functions :**
* Distributes client requests on network load efficiently across multiple servers
* Ensures high availability and reliability by sending requests only to servers that are online
* Provides the flexibility to add or subtract servers as demand dictates

**Load balancing Algorithms -**

**Round Robin** - Request are distributed across the group of servers sequently. it is easy for the load balancers to implement, but does dont take into account the load already on a server

**Least Connection Method** - A New request is sent to the server with the fewest current connections to clients. Whereas round robin does not account for the current load on a server (only its place in the rotation), the least connection method does make this evolution and, as a result, it usually delivers superior performance

**Least Response Time Method** - Sends requests to the server selected by a formula that combines the faster response time and fewest active connections. More sophesticated then the least connection method and Exclusively used by **NGINX Plus**

**Least Bandwidth Method** - A relatively simple algorithm, the least bandwidth method looks for the server currently serving the least amount of traffic as measured in megabits per second

**Hashing Method** - Distributes requests based on a key you define, such as client IP address or the request URL. Nginx Plus can optionally apply a consistent hash to minimize redistribution of loads if the set of upstream servers changes


### Simple load balancer

**Diagram**
```bash
                      +-----------+
                      |           |
                      |   Nginx   |
                      |           |
                      +-----------+
                     /             \
                    /               \
                   /                 \
                  /                   \ 
                 /                     \
    +-----------+                       +-----------+
    |           |                       |           |
    | Machine 1 |                       | Machine 2 |
    |           |                       |           |
    +-----------+                       +-----------+
```

1. Setup load balancer nginx
```bash
cd /etc/nginx/ 
vim nginx.conf
```

2. Inside http server block add this 
```nginx
http {
        upstream appserver {
            server [[**First Servers Ip **]];
            server [[**Second servers Ip**]] ;   
        }
        
        server {
            location / {
                    proxy_pass http://appserver;
                    }
        }
}
```

3. Reload Nginx
```bash
sudo nginx -s reload
sudo systemctl restart nginx
```

### Healthcheck in Nginx Load Balancer

**Health check** 
- Health check is a scheduled rule used to send the same request to each member
- Nginx plus and open source can continually test our upstream servers, avoid the servers that have failed and gracefully add the recovered servers into the load-balanced group
- Two types of healthcheck:

1. Passive HealthCheck (Avalable on Opersource)

- For passive health checks, NGINX and NGINX Plus monitor transactions as they happen, and try to resume failed connections.If the transaction still cannot be resumed, NGINX open source and NGINX Plus mark the server as unavailable and temporarily stop sending requests to it untill it is marked active again

**fail_timeout** 
- Sets the time during which a number of failed attempts must happen for the server to be marked unavailable, and also the time for which the server is marked unavailable (default is 10 seconds) 

**max_fails** 
- Sets the number of failed attempts that must occur during the fail_timeout period for the server to be marked unavailable (default 1 attempt)
- If there is only a single server in a group, the fail_timeout and max_fails parameters are ignored and the server is never marked unavailable

```nginx
http {
        upstream appserver {
            server [[**First Servers Ip **]] max_failes=5 fail_timeout=30s;
            server [[**Second servers Ip**]] ;
        }

        server {
            location / {
                    proxy_pass http://appserver;
                    }
        }
}
```
- Restart the server now
```bash
nginx -s reload
```

2. Active HealthCheck (Avalable on Nginx+ only)
- NGINX Plus can periodically check the health of upstream servers by sending special health-check requests to each server and verifying the correct response
- **health check directive**
- Intervals, fails and passes health check
```nginx
server {
    location {
        proxy_pass http://backend;
        health_check interval=10 fails=3 passes=2;
        }
} 
```

**Custom condition**
```nginx
http {
    #....
    match server_ok{
        status  200-399;
        body !~ "maintanance mode";
    }
    
    server {
        #....
        location / {
            proxy_pass http://backend;
            health_check match=server_ok;
        }
    }
}
```
