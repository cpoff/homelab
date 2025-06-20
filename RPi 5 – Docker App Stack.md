
# forge.cpoff.com Configuration (RPi 5)

## 📦 Role
- Core app stack:
  - Dashy dashboard
  - Jellyfin (media)
  - CasaOS + supporting containers

## 🌐 Network Setup
- **VLAN**: 10 (Trusted)
- **Static IP**: 192.168.10.3
- **FQDN**: `forge.cpoff.com`

## 🛡️ UFW Rules
```bash
# Core web apps
ufw allow from 192.168.10.0/24 to any port 80,443

# App ports (e.g., CasaOS, Jellyfin, Dashy, 3000–3999)
ufw allow from 192.168.10.0/24 to any port 3000:3999 proto tcp

# Isolate from IoT VLAN entirely
ufw deny from 192.168.20.0/24

ufw default deny incoming
ufw default allow outgoing
```

## 🔧 Container Stack (via CasaOS or docker-compose)

- Dashy on port 80
- Jellyfin (8096)
- CasaOS (port 80/443 or high ports)
- Custom containers (optional)

## 🧪 Validation

- Access Dashy: http://dashy.cpoff.com  
- Ping container health from NAS: `curl localhost:3000`  
