# 🐳 `dellbox` — Docker Setup Files (DietPi + VPN-Grooming Stack)

Here's your complete bundle for bootstrapping `dellbox` with DietPi, Docker, Dockge, Watchtower, and a secure media pipeline routed via Gluetun. This assumes a clean install of DietPi with software selections done via `dietpi-software`.

---

## 📁 File Structure Layout

```
~/docker/download-stack/
├── docker-compose.yml         # Full stack config
├── .env                       # VPN credentials (optional)
├── config/
│   ├── sonarr/                # Sonarr config
│   ├── radarr/                # Radarr config
│   └── gluetun/               # Gluetun WireGuard config
├── downloads/                 # Torrent output folder
```

---

## 📦 `docker-compose.yml`

```yaml
version: "3.8"
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    volumes:
      - ./config/gluetun:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=ivpn
      - VPN_TYPE=wireguard
      - SERVER_COUNTRIES=US
      - TZ=America/Denver
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent
    container_name: qbittorrent
    network_mode: "container:gluetun"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Denver
      - WEBUI_PORT=8080
    volumes:
      - ./downloads:/downloads
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    network_mode: "container:gluetun"
    volumes:
      - ./config/sonarr:/config
      - ./downloads:/downloads
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr
    container_name: radarr
    network_mode: "container:gluetun"
    volumes:
      - ./config/radarr:/config
      - ./downloads:/downloads
    restart: unless-stopped

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
    environment:
      - WATCHTOWER_POLL_INTERVAL=86400
```

---

## 🔑 `.env` (Optional for secrets)

```dotenv
VPN_SERVICE_PROVIDER=ivpn
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=replace_me
WIREGUARD_ADDRESSES=10.64.x.x/32
SERVER_COUNTRIES=US
TZ=America/Denver
```

Use `.env` if you'd rather not hard-code sensitive values into your compose file.

---

## 📂 Gluetun Config (`config/gluetun/wg0.conf`)

Paste your IVPN WireGuard config here (can be generated from IVPN’s control panel):

```
[Interface]
PrivateKey = replace_me
Address = 10.64.x.x/32
DNS = 10.0.0.1

[Peer]
PublicKey = IVPN_public_key
AllowedIPs = 0.0.0.0/0
Endpoint = wireguard.endpoint.ip:port
PersistentKeepalive = 25
```

---

## 🗂 Sonarr/Radarr Folders (created manually)

```bash
mkdir -p ~/docker/download-stack/config/{sonarr,radarr,gluetun}
mkdir -p ~/docker/download-stack/downloads
chmod -R 755 ~/docker/download-stack
```

---

## 🚀 Starting the Stack

Use Dockge UI to add this stack or run manually:

```bash
cd ~/docker/download-stack
docker compose up -d
```

---

Let me know when you’re ready to mount `/mnt/nas_media` and I’ll fold in NAS volume bindings + fstab support. We can also extend this with FileBot automation or Prowlarr indexers once you’re back home. This stack’s got room to grow. 🧱🧠🔒
