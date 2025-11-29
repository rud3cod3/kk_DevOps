### Diagnose and Manage Process

```bash
# Process list
ps -a

# List all process
ps aux

# To see process started by user
ps -U ubuntu

# Processes which are wrapped between [ ] are kernel process managed by kernel and we dont have to mess with them

# To continuosly monitor we can make use of 
top

# To find process id
pgrep ssh
```

### Nice value

```bash
# It could be between [-20] to [19]
# Lower number means higher priority
```
