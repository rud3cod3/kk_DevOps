### Configuring nginx reverse proxy

#### Overview

* This document explains how to configure Nginx as a Reverse Proxy on one machine (public-facing) and route requests to two backend application servers

**Architecture Summary**

| Machine       | Role                  | Purpose                                                                                    |
| ------------- | --------------------- | ------------------------------------------------------------------------------------------ |
| **Machine 1** | Reverse Proxy (Nginx) | Only public-facing server; receives all user traffic and decides where to forward requests |
| **Machine 2** | Application Server A  | Runs App-1, reachable only from Machine 1 (private network)                                |
| **Machine 3** | Application Server B  | Runs App-2, reachable only from Machine 1 (private network)                                |

**High-Level Flow**

1. Client → hits public IP of Machine 1
2. Machine 1 (Nginx) → checks request path
3. Nginx forwards request internally:
    * /app1 → Machine 2
    * /app2 → Machine 3
4. Nginx returns the backend's response to the client

*The client never knows Machine 2 or Machine 3 exist*

**Why Use a Reverse Proxy?**
1. Security
2. Centralized Control
3. Scalability
4. Cleaner Architecture

**Understanding How Traffic Moves**

**Step 1: Client Sends Request**
```bash
GET http://yourdomain.com/app1/products
```
Client’s browser resolves the domain → gets public IP of Machine 1

**Step 2: Machine 1 (Nginx) Receives It**
Nginx looks at the incoming request path
* */app1/*
* */app2/*

**Step 3: Nginx Forwards to Correct App Server**
*If request path begins with /app1, Nginx removes that prefix and forwards the request to*
```bash
http://10.0.1.10:3000/
```
*(similarly, /app2 → 10.0.1.11:3000)*

**Step 4: Backend Server Responds**
*Machine 2 or 3 returns*
```bash
HTTP/1.1 200 OK
```
*with data*

**Step 5: Nginx Sends Response Back to Client**
*The client thinks everything came from Machine 1*

### Configuration Setup (Machine 1 – Reverse Proxy)
**Install Nginx**
```bash
sudo apt update
sudo apt install nginx -y
```
