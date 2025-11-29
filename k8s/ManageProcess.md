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

# To launch a command with nice value
nice -n [NICE VALUE] [COMMAND]

# Regular user can only assign value between [0] to [19] 
# For to assign lower nice value we need root preveledges

# To change nicevalue of any command
# Here regular user cant set value down like if it was 8 before regular user cant set it for 6but root user can
renice [NEW NICE VALUE] [PID]
```

### We can kill process in order to stop it
```bash
# To see list of kill signals use
# SIGTERM is the default signal
# 9 is forcekill
kill -l

# To kill using pid 
# Find pid 
pgrep -a bash

# Then kill it
pkill -KILL bash
```
