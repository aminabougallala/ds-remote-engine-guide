# Remote Engine not starting after 250 seconds (Permission Denied)

## Error Message
```text
waiting for amin-aws_runtime to start... time elapsed: 245 seconds
waiting for amin-aws_runtime to start... time elapsed: 250 seconds
ERROR: Could not start container amin-aws_runtime in 250 seconds, aborting.
```

## Engine logs

```bash
[root@ip-172-31-19-185 docker] podman logs amin-aws_runtime
/bin/bash: line 1: /px-storage/init-volume.sh: Permission denied
/bin/bash: line 1: /px-storage/startup.sh: Permission denied
```

## Root Cause
The ‘Permission denied’ issue can be caused by missing executable permissions to the volume directory for the user running the Remote Engine container.

> [!TIP]  
> If the `--volume-dir` flag is not specified, the `dsengine.sh` script uses `/tmp/docker/volumes` as the default volume directory for persistent storage accessed by the Remote Engine container. 

---

## Resolution

Delete any existing Remote Engine containers, even if not running: 

```bash
podman ps -a
podman rm -f "IMAGE_NAME"
# Example:
podman rm -f my_engine_runtime
```

---

Verify the user’s permissions of the chosen volume directory for persistent storage inside the container (i.e. `/tmp/docker/volumes`):

```bash
whoami
ls -ld /tmp/docker/volumes
```

**Example Output:**

```text
drwxr-xr--  2 root root 4096 Jan 29 10:00 /tmp/docker/volumes
```

In this example, the `etlpoc` user is not the owner of the directory and does not have executable permissions.

---

### Option 1: Modify the directory permissions

```bash
sudo chmod -R 755 /tmp/docker/volumes
```

---

### Option 2: Use the `--volume-dir` flag to specify a fresh directory

```bash
export VOLUME_DIR=test/docker/volumes

./dsengine.sh start -n "$ENGINE_NAME" \
    -a "$CLOUD_API_KEY" \
    -e "$ENCRYPTION_KEY" \
    -i "$ENCRYPTION_IV" \
    -p "$CLOUD_ENTITLEMENT_KEY" \
    --project-id "$PROJECT_ID" \
    --volume-dir "$VOLUME_DIR"
```

---

### Disable SELinux Enforcement

Even if the volume directory is mounted correctly, SELinux can prevent the container from accessing/executing the `init.sh` script.

> [!IMPORTANT]  
> SELinux can block container access even with correct mounts. Disabling SELinux (`--security-opt`) can bypass this restriction.

```bash
./dsengine.sh start -n "$ENGINE_NAME" \
    -a "$CLOUD_API_KEY" \
    -e "$ENCRYPTION_KEY" \
    -i "$ENCRYPTION_IV" \
    -p "$CLOUD_ENTITLEMENT_KEY" \
    --project-id "$PROJECT_ID" \
    --volume-dir "$VOLUME_DIR" \
    --security-opt "label=disable"
```


