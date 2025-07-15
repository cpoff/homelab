GRANT PERMISSIONS AFTER RUNNING:
chmod +x dellbox-init.sh
--------------------------------

#!/bin/bash
# dellbox-init.sh — Setup script for VPN-secured media grooming stack
# Target: DietPi x86 box running headless

echo "🔄 Updating system..."
dietpi-update

echo "📦 Installing Docker, Compose, and Dockge..."
dietpi-software install 162  # Docker
dietpi-software install 182  # Docker Compose
dietpi-software install 183  # Dockge

echo "🔐 Installing optional security and VPN tools..."
dietpi-software install 174  # Fail2Ban
dietpi-software install 170  # WireGuard (for Gluetun/IVPN debugging)

echo "🌐 Setting system timezone to America/Phoenix..."
timedatectl set-timezone America/Phoenix

echo "📁 Preparing Docker directory structure..."
mkdir -p ~/docker/download-stack/{downloads,config/{gluetun,sonarr,radarr}}

echo "🧽 Setting directory permissions..."
chmod -R 755 ~/docker/download-stack

echo "📄 Writing docker-compose.yml to stack folder..."
cat > ~/docker/download-stack/docker-compose.yml <<'EOF'
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
      - TZ=America/Phoenix
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent
    container_name: qbittorrent
    network_mode: "container:gluetun"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Phoenix
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
EOF

echo "🟢 Setup complete!"
echo "🔐 Drop your WireGuard config into: ~/docker/download-stack/config/gluetun"
echo "🧠 Access Dockge at: http://<dellbox-IP>:5001"
echo "🚀 Launch your stack with: docker compose -f ~/docker/download-stack/docker-compose.yml up -d"
