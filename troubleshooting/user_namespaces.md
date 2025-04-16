# Insufficient subgids/subuids for User Namespace

##Error Message

```shell
Error: writing blob: adding layer with blob "sha256:a9089747d5ad": potentially insufficient UIDs or GIDs...
```

---

##Root Cause

Rootless Podman requires specific UID/GID ranges in `/etc/subuid` and `/etc/subgid`.

---

##Resolution

1. Ensure `shadow-utils` is installed:

```bash
sudo yum -y install shadow-utils
```

2. Edit `/etc/subuid`:

```bash
sudo vi /etc/subuid
```

Add or modify line (e.g., for user `etlpoc`):

```text
etlpoc:100000:1001321001
```

3. Edit `/etc/subgid`:

```bash
sudo vi /etc/subgid
```

Add or modify line similarly:

```text
etlpoc:100000:1001321001
```

4. Verify both:

```bash
cat /etc/subuid
cat /etc/subgid
```

5. Apply changes:

```bash
podman system migrate
```
