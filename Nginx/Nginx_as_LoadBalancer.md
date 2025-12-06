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


