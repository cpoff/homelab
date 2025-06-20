# node.cpoff.com Configuration (RPi 3)

## 📦 Role
- System monitoring, utility services
- Hosts lightweight Netdata stack

## 🌐 Network Setup
- **VLAN**: 99 (Infra)
- **Static IP**: 192.168.99.3
- **FQDN**: `node.cpoff.com`

## 🛡️ UFW Rules
```bash
# Netdata Web UI – NAS only
ufw allow from 192.168.10.2 to any port 19999

# General ICMP, system probes from VLAN 10
ufw allow from 192.168.10.0/24 to any

# Allow inter-VLAN from Infra VLAN
ufw allow from 192.168.99.0/24 to any

ufw default deny incoming
ufw default allow outgoing
```

## 🛠️ Services

- Netdata (port 19999)
- Optional: scripts for CPU temp, container pings, etc.

## 🧪 Validation

- `curl http://node.cpoff.com:19999`
- Ping check from `forge` or NAS
