# nas.cpoff.com Configuration (Synology NAS)

## 📦 Role
- Hosts core services:
  - Plex Media Server
  - Home Assistant
  - Portainer
  - NGINX Proxy Manager
  - Docker Stack
  - Tailscale Endpoint

## 🌐 Network Setup
- **VLAN**: 10 (Trusted)
- **Static IP**: 192.168.10.2
- **FQDN**: nas.cpoff.com

## 🛡️ UFW Rules
```bash
# Allow dashboards from Trusted VLAN
ufw allow from 192.168.10.0/24 to any port 80,443

# Allow Plex traffic from Trusted + IoT VLANs
ufw allow from 192.168.10.0/24 to any port 32400
ufw allow from 192.168.20.0/24 to any port 32400

# Allow ingress from Tailscale overlay network
ufw allow from 100.64.0.0/10

# Default firewall policy
ufw default deny incoming
ufw default allow outgoing
```

## 📦 Container Services (via Portainer)

- Home Assistant (8123)
- NGINX Proxy Manager (80/443)
- Plex (32400)
- Portainer
- Tailscale daemon or overlay access

## 🧪 Validation

- Access: https://nas.cpoff.com or via respective subdomains
- Plex test: http://nas.cpoff.com:32400/web
- NPM certificates validate over wildcard (`*.cpoff.com`)
