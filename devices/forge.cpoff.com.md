# node.cpoff.com Configuration (RPi 3 – Monitoring & Diagnostics)

## 📦 Role

- Provides diagnostic visibility via Netdata dashboard  
- Performs basic uptime, ping, and inter-VLAN monitoring  
- Isolated from exposure; accessible only from trusted nodes (e.g. `nas`)  
- Participates in Tailscale mesh for out-of-band pings and SSH

---

## 🌐 Network Setup

- **VLAN**: 99 (Infra)
- **Static IP**: `192.168.99.3`
- **Hostname (FQDN)**: `node.cpoff.com`

---

## 🛡️ UFW Firewall Rules

```bash
# Allow Netdata Web UI access from nas.cpoff.com
ufw allow from 192.168.10.2 to any port 19999

# Allow diagnostics from Trusted VLAN
ufw allow from 192.168.10.0/24 to any

# Allow Infra-to-Infra communication
ufw allow from 192.168.99.0/24 to any

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

---

## 📊 Netdata Setup

- Installation:
  ```bash
  bash <(curl -Ss https://my-netdata.io/kickstart.sh)
  ```
- Service auto-starts on boot  
- No authentication (protected by network firewall)  
- Optional reverse proxy via `nas.cpoff.com`

### Interface

- Access from NAS or Pop!_OS:
  - http://node.cpoff.com:19999
- Monitor:
  - CPU, disk I/O, network activity
  - Memory usage, uptime, SSH load
  - Docker metrics if enabled later

---

## 🧪 Validation

- Ping from Pop!_OS:
  ```bash
  ping node.cpoff.com
  ```
- Tailscale overlay test:
  ```bash
  tailscale ping node
  ```
- Visit: http://node.cpoff.com:19999 from VLAN 10  
- Check Netdata health alarm count = 0  
- Inspect UFW logs for blocked traffic attempts

---

## 🧠 Notes

- Recommended: log Netdata to RAM to reduce SD wear  
- Optional: install CLI dashboards like `bpytop`, `htop`, or `glances`  
- Overlay ACLs can restrict `:19999` to certain clients

---

_Last Updated: SkyNet Prod 3 – node.cpoff.com_
