# Insufficient Storage for Remote Engine Container Image

## Error Message

```shell
Error: writing blob: adding layer with blob "sha256:..." unpacking failed (error: exit status 1; output: open /usr/share/zoneinfo/zone.tab: no space left on device)
docker run return code: 125.
```

---

## Root Cause

Podman stores container layers, metadata, and volumes in `/var/lib/containers` for root containers and `$HOME/.local/share/containers` for rootless containers, by default. For Remote Engine installation as either rootful or rootless Podman, it is recommendeded to have at least 50 GB of free space in at least one of these directories.

Check available space:

```bash
df -h /var
```

**Example output:**

```shell
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda4      8.8G  42.4G  52.8G  81% /
```

---

## ✅ Resolution Options

### Option 1: Clean Up Container Storage

Free up disk space by removing unused container images:

```bash
podman system prune
```

> [!IMPORTANT]  
> This will remove **all unused images**, including those that were manually pulled but aren't currently running.

> [!TIP]  
> Confirm with the user before executing, especially in environments where image cleanup could impact other workloads.

---

### Option 2: Modify Container Storage Location

If `/var` is full, use another mounted volume for container storage.

---

#### Part 1: Mount a New Volume

1. Check available volumes:

    ```bash
    lsblk
    ```

2. Format the new volume (e.g. `/dev/xvdb`):

    ```bash
    sudo mkfs.xfs /dev/xvdb
    ```

3. Mount the volume:

    ```bash
    sudo mkdir -p /mnt/data
    sudo mount /dev/xvdb /mnt/data
    ```

4. Make it persistent after reboot:

    ```bash
    sudo nano /etc/fstab
    ```

    Add this line:

    ```text
    /dev/xvdb /mnt/data xfs defaults 0 0
    ```

> [!NOTE]  
> You can validate with `df -h` to confirm `/mnt/data` is mounted correctly.

---

#### Part 2: Set Up Storage Directories

```bash
# For rootful Podman
sudo mkdir -p /mnt/data/containers/storage_root

# For rootless Podman
sudo mkdir -p /mnt/data/containers/storage_rootless
```

If you’re unsure, create both.

---

#### Part 3: Set SELinux Context (Rootful Only)

Check if SELinux is enforcing:

```bash
getenforce
```

If it returns `Enforcing`, run:

```bash
sudo semanage fcontext -a -e /var/lib/containers/storage /mnt/data/containers/storage_root
sudo restorecon -R -v /mnt/data/containers/storage_root
```

> [!NOTE]  
> SELinux adjustments are **not required** for rootless containers.

---

#### Part 4: Adjust Ownership for Rootless Podman

If the user is `amin`, grant permissions:

```bash
sudo chown -R amin:amin /mnt/data/containers/storage_rootless
```

---

#### Part 5: Edit `storage.conf`

Open the config:

```bash
sudo nano /etc/containers/storage.conf
```

- For **rootful** users, change:

    ```ini
    graphroot = "/mnt/data/containers/storage_root"
    ```

- For **rootless** users, uncomment and change:

    ```ini
    rootless_storage_path = "/mnt/data/containers/storage_rootless"
    ```

---

### Final Step: Verify Configuration

Check that Podman recognizes the new storage paths:

```bash
podman info
```

Look for this in the output:

```text
store:
  graphRoot: /mnt/data/containers/storage_rootless
  ...
  volumePath: /mnt/data/containers/storage_rootless/volumes
```

---


✅ You’re all set! The Remote Engine container image should now install successfully using the new storage path.
