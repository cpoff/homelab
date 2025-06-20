# nginx.cpoff.com – NGINX Proxy Manager (NPM) Deployment Guide

This document outlines the installation and configuration of NGINX Proxy Manager within the SkyNet Prod 3 network. It provides reverse proxy functionality for containerized services like Home Assistant, Portainer, Sonarr/Radarr, and more, complete with Let's Encrypt wildcard SSL and Tailscale overlay awareness.

---

## 📦 System Overview

- **Node**: `nas.cpoff.com` (Synology or Linux host)
- **Stack**: Docker Compose deployment
- **Network**: Accessible via VLAN 10 and Tailscale overlay
- **DNS**: `npm.cpoff.com` mapped via Pi-hole
- **Reverse Proxy Targets**:
  - `ha.cpoff.com` (Home Assistant)
  - `portainer.cpoff.com`
  - `dashy.cpoff.com`
  - `radarr.cpoff.com`, `sonarr.cpoff.com`, etc.

---

## 🛠️ Installation (Docker Compose)

**Directory structure:**

```bash
mkdir -p ~/docker/nginx-proxy-manager
cd ~/docker/nginx-proxy-manager
```

**Compose file:**

```yaml
version: '3'
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    ports:
      - 80:80
      - 81:81  # Admin UI
      - 443:443
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    restart: unless-stopped
```

**Startup:**

```bash
docker compose up -d
```

> Access UI: `http://nas.cpoff.com:81`  
> Default credentials: `admin@example.com / changeme`

---

## 🔒 Let's Encrypt (Wildcard DNS)

**DNS Provider**: Cloudflare (via DNS-01)

1. In NPM, go to *SSL Certificates → Add*  
2. Select "Wildcard Certificate"  
3. Domain: `*.cpoff.com`  
4. DNS Challenge: Cloudflare  
5. Enter Cloudflare global API key and account email  
6. Validate and create  
7. Auto-renew enabled by default

---

## 🌐 Proxy Host Configuration

| Service        | Domain                 | Target                          | SSL       |
|----------------|------------------------|----------------------------------|-----------|
| Home Assistant | `ha.cpoff.com`         | `http://nas:8123`                | Full Cert |
| Dashy          | `dashy.cpoff.com`      | `http://forge:8080`              | Full Cert |
| Sonarr         | `sonarr.cpoff.com`     | `http://forge:8989`              | Full Cert |
| Radarr         | `radarr.cpoff.com`     | `http://forge:7878`              | Full Cert |
| Portainer      | `portainer.cpoff.com`  | `https://nas:9443`               | Full Cert |

**Recommended settings per host:**
- Scheme: HTTP/HTTPS depending on target
- Block Common Exploits: ✅
- Websockets Support: ✅ (for HA and Dashy)
- HTTP/2 Support: ✅ (default)

---

## 🔐 UFW Rules on `nas.cpoff.com`

```bash
# Allow HTTPS and HTTP from VLAN 10 and Tailscale
ufw allow from 192.168.10.0/24 to any port 80,443
ufw allow from 100.64.0.0/10 to any port 443
```

---

## 🧪 Validation Checklist

- [ ] NPM UI accessible at `http://nas.cpoff.com:81`
- [ ] SSL wildcard certificate issued and visible in UI
- [ ] Proxy hosts respond correctly via HTTPS
- [ ] Reverse proxies honor upstream subdomain paths
- [ ] Pi-hole resolves `*.cpoff.com` → expected IPs
- [ ] Overlay clients can access services securely

---

## 📝 Notes

- Optional: set NPM UI password vault with Bitwarden Secrets Manager  
- Export NPM config with:
  ```bash
  docker exec nginx-proxy-manager /app/backup/backup.js
  ```
- Verify wildcard cert renewal every 60 days  
- Use NGINX access logs for audit/debug: `~/docker/nginx-proxy-manager/data/logs/`

---

_Last Updated: SkyNet Prod 3 – NGINX Proxy Manager Setup_
