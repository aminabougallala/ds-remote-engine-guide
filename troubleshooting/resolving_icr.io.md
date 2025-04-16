## Unable to Pull Images from IBM Cloud Container Registry (`icr.io`)

`icr.io` not resolving may be an issue with the default DNS server used by the virtual machine. We've tested on a different machine using IBM Cloud and this is how we can work around it:

---

### Part One

Use `dig` to query A record for `icr.io` using Google DNS:

```bash
dig @8.8.8.8 icr.io
```

Got IP in ANSWERS SECTION:

```text
169.62.37.243
```

Add to `/etc/hosts`:

```bash
echo "169.62.37.243 icr.io" | sudo tee -a /etc/hosts
```

---

### Part Two

Query DNS for `dd2.icr.io`:

```bash
dig @8.8.8.8 dd2.icr.io
```

Got IP in ANSWERS SECTION:

```text
23.221.22.201
```

> [!TIP]  
> Use the first IP returned if there are multiple results.

Add to `/etc/hosts`:

```bash
echo "23.221.22.201 dd2.icr.io" | sudo tee -a /etc/hosts
```

Then re-run:

```bash
./dsengine.sh
```
