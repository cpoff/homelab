# dns.cpoff.com Configuration (RPi 4 – Pi-hole + Unbound)

## 📦 Role

- Primary DNS resolver for all VLANs
- Provides recursive DNS via Unbound
- Local authoritative DNS for `*.cpoff.com` subdomains via Pi-hole
- Tailscale overlay node for internal resolution
- UFW-restricted per VLAN for fine-grained access control

---

## 🌐 Network Setup

- **VLAN**: 99 (Infra)
- **Static IP**: `192.168.99.2`
- **Hostname (FQDN)**: `dns.cpoff.com`

---

## 🔧 DNS Service Configuration

- **Pi-hole**:  
  - Handles local DNS resolution and blocklists  
  - Authoritative for `*.cpoff.com` subdomains (via Local DNS Records)

- **Unbound**:  
  - Recursive DNS resolver (no upstreams)  
  - Installed via APT and configured per Pi-hole documentation

---

## 🔐 UFW Firewall Rules

```bash
# Allow DNS (UDP/TCP) from VLAN 10
ufw allow proto udp from 192.168.10.0/24 to any port 53
ufw allow proto tcp from 192.168.10.0/24 to any port 53

# Allow DNS from VLAN 20
ufw allow proto udp from 192.168.20.0/24 to any port 53
ufw allow proto tcp from 192.168.20.0/24 to any port 53

# Allow DNS from Infra VLAN
ufw allow proto udp from 192.168.99.0/24 to any port 53
ufw allow proto tcp from 192.168.99.0/24 to any port 53

# Allow Pi-hole Web UI from Trusted VLAN
ufw allow from 192.168.10.0/24 to any port 80,443

# Default policy
ufw default deny incoming
ufw default allow outgoing
```

---

## 🌐 Local DNS Mappings (Sample)

```text
nas.cpoff.com        → 192.168.10.2
forge.cpoff.com      → 192.168.10.3
dns.cpoff.com        → 192.168.99.2
node.cpoff.com       → 192.168.99.3
switch.cpoff.com     → 192.168.99.8
```

---

## 🧪 Validation

- Access Pi-hole UI: `http://dns.cpoff.com/admin` from VLAN 10  
- Recursive resolution:
  ```bash
  dig google.com @192.168.99.2
  dig forge.cpoff.com @192.168.99.2
  ```
- Overlay DNS response from Tailscale node:
  ```bash
  dig ha.cpoff.com @dns.cpoff.com
  ```

---

## 📝 Notes

- Log retention in Pi-hole set to minimal for performance
- Unbound logs enabled via `/etc/unbound/unbound.conf.d/pi-hole.conf`
- Optionally sync blocklists via cron or Gravity Sync

---

_Last Updated: SkyNet Prod 3 – dns.cpoff.com_
