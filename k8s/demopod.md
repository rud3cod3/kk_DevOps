### Running nginx pod

```bash
# Creating pod of nginx
kubectl run nginx --image=nginx

# Checking pod
kubectl get pods

# For more detailed information
kubectl describe pod nginx

# For less details
kubectl get pods -o wide
```
