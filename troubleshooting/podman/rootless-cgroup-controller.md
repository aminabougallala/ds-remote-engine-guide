# Insufficient ‘cpu’ and ‘cpuset’ Permissions

## Error Message

```shell
Error: OCI runtime error: crun: the requested cgroup controller `cpu` is not available
```

---

## Root Cause

On some systemd-based systems, non-root users do not have resource limit delegation permissions. This causes setting resource limits in rootless Podman to fail (e.g., allocating 8 cores to the Remote Engine).

---

## Resolution

1. Log into the affected user.

2. Verify if resource limit delegation is enabled:

```bash
cat "/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers"
```

**Example Output:**
```text
memory pids
```

3. If `cpu` and `cpuset` are missing, add them by creating this file:

```bash
sudo mkdir -p /etc/systemd/system/user@.service.d/
sudo touch /etc/systemd/system/user@.service.d/delegate.conf
```

4. Edit the file: 
```bash
sudo nano /etc/systemd/system/user@.service.d/delegate.conf
```

5. Insert the following:

```ini
[Service]
Delegate=memory pids cpu cpuset
```

4. Apply the changes:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
```

5. Log out and log back in, then verify:

```bash
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
```

**Expected Output:**

```text
cpuset cpu memory pids
```
