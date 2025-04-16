# DataStage Remote Engine Knowledge Hub

A curated collection of troubleshooting tips, best practices, and must-know commands for working with DataStage Remote Engine.

### What's Inside

- **Troubleshooting:** Common issues and how to resolve them
- **Best Practices:** Deployment, performance tuning, and more
- **Sample Packages:** Frequently used CLI and admin commands

# Table of Contents 

## 🛠️ DataStage Remote Engine Troubleshooting Guide

This folder contains solutions to common issues encountered when installing and running the IBM DataStage Remote Engine with Podman or Docker.

The issues are grouped into key categories for easy reference.

---

### 📡 Networking Issues

- [`resolving_icr.io.md`](./networking/resolving_icr.io.md)  
  Fixes DNS resolution issues when pulling container images from `icr.io`.

- [`engine_hostname_issue.md`](./networking/engine_hostname_issue.md)  
  Resolves job startup failures caused by incorrect host IP mapping in `/etc/hosts`.

---

### 🐳 Podman Runtime Issues

- [`rootless-cgroup-controller.md`](./podman/rootless-cgroup-controller.md)  
  Enables missing `cpu` and `cpuset` controllers for rootless Podman users.

- [`rootless-subuids-subgids.md`](./podman/rootless-subuids-subgids.md)  
  Adds the required UID/GID ranges for running rootless containers.

- [`sh_permission_denied.md`](./podman/sh_permission_denied.md)  
  Resolves volume permission errors causing `init.sh` to fail inside containers.

---

### 💾 Storage Issues

- [`container_image_storage.md`](./storage/container_image_storage.md)  
  Handles insufficient space in `/var` by relocating or cleaning up container storage.

---

### 🧪 Contributing

To add a new troubleshooting guide:

1. Place the file in the appropriate subfolder.
2. Name it descriptively using lowercase and dashes.
3. Use the following header format at the top of each file:

```markdown
# Issue XXX: [Short Title]
# Error Message
# Root Cause Description
# Resolution
