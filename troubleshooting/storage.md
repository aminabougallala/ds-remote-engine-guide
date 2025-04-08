
# Insufficient Storage for Remote Engine Container Image

## Error Message
```
Error: writing blob: adding layer with blob "sha256:..." unpacking failed (error: exit status 1; output: open /usr/share/zoneinfo/zone.tab: no space left on device)
docker run return code: 125.
```

---

## 💡 Root Cause

Docker/Podman stores container layers, metadata, and volumes in `/var` by default. For Remote Engine installation, **at least 50 GB of free space** is recommended in `/var`.

Check available space with:

```bash
df -h /var
```

**Example output:**

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda4      8.8G  42.4G 52.8G 81% /
```

---

## ✅ Resolution Options

### Option 1: Clean Up Container Storage

Free up space in `/var` by removing unused container images:

```bash
podman system prune
```

> ⚠️ **Caution:** This removes *all unused images*, not just dangling ones. Confirm with the client before executing.

---

### Option 2: Modify `storage.conf` to Use Another Volume

#### 🛠️ Part 1: Mount Additional Volume

1. **Check for available disk:**

```bash
lsblk
```

**Example output:**

```
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
xvda    202:0    0   10G  0 disk
└─xvda4 202:4    0  9.3G  0 part /
xvdb    202:16   0   20G  0 disk
```

2. **Create filesystem on unmounted disk (e.g. `/dev/xvdb`):**

```bash
sudo mkfs.xfs /dev/xvdb
```

3. **Create mount point and mount it:**

```bash
sudo mkdir -p /mnt/data
sudo mount /dev/xvdb /mnt/data
```

4. **Verify mount:**

```bash
df -h
```

**Expected output:**

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvdb        20G  175M   20G   1% /mnt/data
```

5. **Persist the mount across reboots:**

Edit `/etc/fstab` and add:

```
/dev/xvdb /mnt/data xfs defaults 0 0
```

---

#### 📦 Part 2: Create Container Storage Directories

For **rootful** Podman:

```bash
sudo mkdir -p /mnt/data/containers/storage_root
```

For **rootless** Podman:

```bash
sudo mkdir -p /mnt/data/containers/storage_rootless
```

If unsure which mode the client is using, create both.

---

#### 🔐 Part 3: SELinux (if enabled)

Check SELinux status:

```bash
getenforce
```

If result is `Enforcing`, run:

```bash
sudo semanage fcontext -a -e /var/lib/containers/storage /mnt/data/containers/storage_root
sudo restorecon -R -v /mnt/data/containers/storage_root
```

---

#### 👤 Part 4: Set Ownership for Rootless Storage

If running rootless (e.g., user is `amin`):

```bash
sudo chown -R amin:amin /mnt/data/containers/storage_rootless
```

---

#### 📝 Part 5: Modify `storage.conf`

Edit the config file:

```bash
sudo nano /etc/containers/storage.conf
```

For **rootful** Podman:

Change the `graphroot` path:

```ini
graphroot = "/mnt/data/containers/storage_root"
```

For **rootless** Podman:

Uncomment and update the `rootless_storage_path`:

```ini
rootless_storage_path = "/mnt/data/containers/storage_rootless"
```

---

### 🔍 Verify the Changes

Run:

```bash
podman info
```

Look for updated paths:

```
store:
  ...
  graphRoot: /mnt/data/containers/storage_rootless
  ...
  volumePath: /mnt/data/containers/storage_rootless/volumes
```

---

✅ You’re all set! The Remote Engine container image should now install successfully using the new storage path.
