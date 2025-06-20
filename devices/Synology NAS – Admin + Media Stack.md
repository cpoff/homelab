# nas.cpoff.com Configuration (Synology NAS)

## 📦 Role

- Hosts core infrastructure services:
  - Plex Media Server
  - Home Assistant
  - Portainer
  - NGINX Proxy Manager (NPM)
  - Docker Stack (apps, proxies)
  - Tailscale endpoint for overlay access

---

## 🌐 Network Setup

- **VLAN**: 10 (Trusted)
- **Static IP**: `192.168.10.2`
- **Hostname (FQDN)**: `nas.cpoff.com`

### Recommended DNS Entries (Pi-hole or Unbound)

```text
nas.cpoff.com             → 192.168.10.2
ha.cpoff.com              → 192.168.10.2
portainer.cpoff.com       → 192.168.10.2
npm.cpoff.com             → 192.168.10.2
tailscale.cpoff.com       → 192.168.10.2
```

---

## 🛡️ UFW Rules

```bash
# Allow web UI (HTTPS/Dashboard) from Trusted VLAN
ufw allow from 192.168.10.0/24 to any port 80,443

# Allow Plex media access from Trusted + IoT VLANs
ufw allow from 192.168.10.0/24 to any port 32400
ufw allow from 192.168.20.0/24 to any port 32400

# Allow remote overlay access via Tailscale
ufw allow from 100.64.0.0/10

# Harden everything else
ufw default deny incoming
ufw default allow outgoing
```

---

## 📦 Container Services (Deployed via Portainer)

| Service              | Port(s)     | Notes                                       |
|----------------------|-------------|---------------------------------------------|
| Home Assistant       | 8123        | Local automation + integrations             |
| NGINX Proxy Manager  | 80, 443     | Wildcard HTTPS via Cloudflare DNS-01       |
| Plex Media Server    | 32400       | Local + remote streaming (via apps)         |
| Portainer            | 9443        | Container management dashboard              |
| Tailscale (optional) | —           | Daemon or CLI authentication                |

---

## 🧪 Validation

- Web access: https://nas.cpoff.com or respective subdomains
- NPM cert status: check Let's Encrypt via UI  
- Plex: http://nas.cpoff.com:32400/web  
- Portainer: https://portainer.cpoff.com  
- Tailscale presence: `tailscale status`

---

_Last Updated: SkyNet Prod 3 – NAS Node_
