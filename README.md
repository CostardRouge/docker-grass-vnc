# Grass VNC Docker Setup

## File structure

```
your-build-folder/
├── Dockerfile
├── docker-compose.yml
├── supervisord.conf
├── entrypoint.sh
└── grass.deb          ← your Grass .deb file goes here
```

---

## Step 1 — Build the image (on your dev machine)

Place your `grass.deb` file alongside the `Dockerfile`, then:

```bash
docker build -t grass-vnc:latest .
```

---

## Step 2 — Transfer the image to your Mac server

```bash
# Save the image to a tar file
docker save grass-vnc:latest | gzip > grass-vnc.tar.gz

# Copy it to your Mac (Ubuntu Server)
scp grass-vnc.tar.gz user@your-mac-ip:/home/user/

# On the Mac — load the image into Docker
docker load < grass-vnc.tar.gz
```

---

## Step 3 — Deploy via Portainer

### Option A — Portainer Stacks (recommended)
1. Open Portainer → **Stacks** → **Add stack**
2. Paste the contents of `docker-compose.yml`
3. Make sure the image name matches (`grass-vnc:latest`)
4. Click **Deploy the stack**

### Option B — CLI on the Mac server
```bash
docker compose up -d
```

---

## Accessing the container

| Method      | URL / Address                          | Tool needed         |
|-------------|----------------------------------------|---------------------|
| **noVNC**   | `http://<mac-ip>:6080/vnc.html`        | Any web browser     |
| **VNC**     | `<mac-ip>:5901`                        | VNC Viewer, RealVNC |

**Default VNC password:** `vncpassword`
→ Change it in the `Dockerfile` before building (line with `echo "vncpassword"`)

---

## Launching Grass inside the container

Once connected via VNC you'll see the XFCE4 desktop. Open a terminal and run:

```bash
# Find the exact binary name installed by the .deb
ls /usr/bin/grass* /opt/grass* 2>/dev/null || dpkg -L grass | grep bin
```

Then launch it, or add it to the XFCE autostart if you want it to start automatically.

---

## Customisation tips

| What                        | Where to change                            |
|-----------------------------|--------------------------------------------|
| Screen resolution           | `VNC_RESOLUTION` env var in compose file   |
| VNC password                | `Dockerfile` line 47 (`echo "vncpassword"`)  |
| Timezone                    | `TZ` env var in compose file               |
| Persist more app data       | Add extra paths under `volumes:` in compose|
| Auto-launch Grass on start  | Add to `/home/grassuser/.config/autostart/`|
