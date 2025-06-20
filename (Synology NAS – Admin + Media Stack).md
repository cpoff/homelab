# plex.cpoff.com Configuration (Synology NAS)

## 📦 Role
- Central host for:
  - Plex
  - Home Assistant
  - Portainer
  - NGINX Proxy Manager
- Entry point for Tailscale and wildcard SSL provisioning

## 🌐 Network Setup
- **VLAN**: 10 (Trusted)
- **Static IP**: 192.168.10.2
- **FQDN**: `plex.cpoff.com`

> All services reverse-proxied with HTTPS via NGINX Proxy Manager (NPM)

## 🛡️ UFW Rules
```bash
# Web UIs: HA, NPM, Portainer
ufw allow from 192.168.10.0/24 to any port 80,443

# Plex LAN + IoT streaming
ufw allow from 192.168.10.0/24 to any port 32400
ufw allow from 192.168.20.0/24 to any port 32400

# VPN ingress from Tailscale
ufw allow from 100.64.0.0/10

# Default lockdown
ufw default deny incoming
ufw default allow outgoing
```

## 🔧 Containerized Services (via DSM or Portainer)

- **Home Assistant** (8123)
- **NGINX Proxy Manager** (TCP 80/443, DNS challenge config)
- **Portainer** (https://plex.cpoff.com:9443)
- **Plex Media Server** (TCP 32400, plus auto-discovered)

## 🧪 Validation

- NPM reachable at `plex.cpoff.com`
- Let’s Encrypt cert valid via Cloudflare API token
- Portainer shows healthy stack status
