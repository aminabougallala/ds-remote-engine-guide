# Job Failure Due to Local Hostname Binding in /etc/hosts

##DataStage Job Log Error Message

```text
**** Startup error on node1  connecting with conductor on 172.28.8.119 with cookie 1738260492.844000.1bb1e:  unable to connect to port 10003  on conductor; socket = 0, Bad file descriptor
##E IIS-DSEE-TFPM-00148 
**** Startup error on node2  connecting with conductor on 172.28.8.119 with cookie 1738260492.844000.1bb1e:  unable to connect to port 10003  on conductor; socket = 0, Bad file descriptor
##W IIS-DSEE-TFPM-00152 <main_program> Accept timed out retries = ...
**** Parallel startup failed ****
```

---

## Root Cause

The Remote Engine has started successfully, but job execution fails due to a startup error when resolving and connecting to the conductor pod using the host’s IP address (e.g., `172.28.8.119`).  

This host IP address mapping needs to be removed so that the Remote Engine container uses `127.0.0.1` to resolve the hostname.

---

## Resolution

1. Find the running container:

```bash
docker ps
# OR
podman ps
```

2. Exec into the container:

```bash
sudo docker exec -it <container-name-or-id> bash
# OR
sudo podman exec -it <container-name-or-id> bash
```

3. Edit the hosts file inside the container:

```bash
nano /etc/hosts
```

4. Remove the line that contains the **host IP address** and **host name**.

> [!IMPORTANT]  
> Ensure only the incorrect mappings to the hostname IP address are removed to avoid breaking network connections.
