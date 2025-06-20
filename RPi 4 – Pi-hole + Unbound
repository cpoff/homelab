# dns.cpoff.com Configuration (RPi 4 – Pi-hole + Unbound)

## 📦 Role
- DNS resolver and filtering hub for all VLANs
- Hosts Pi-hole + Unbound for recursive resolution
- Manages local subdomain DNS for `*.cpoff.com`

## 🌐 Network Setup
- **VLAN**: 99 (Infra)
- **Static IP**: 192.168.99.2
- **Hostname**: `dns`
- **FQDN**: `dns.cpoff.com`

### /etc/dhcpcd.conf snippet:
```bash
interface eth0
static ip_address=192.168.99.2/24
static routers=192.168.99.1
static domain_name_servers=127.0.0.1
```

## 🛡️ UFW Rules
```bash
# DNS (TCP/UDP) from all VLANs
ufw allow proto udp from 192.168.10.0/24 to any port 53
ufw allow proto tcp from 192.168.10.0/24 to any port 53
ufw allow proto udp from 192.168.20.0/24 to any port 53
ufw allow proto tcp from 192.168.20.0/24 to any port 53
ufw allow proto udp from 192.168.99.0/24 to any port 53
ufw allow proto tcp from 192.168.99.0/24 to any port 53

# Web UI (Pi-hole) from VLAN 10 only
ufw allow from 192.168.10.0/24 to any port 80,443

# Lock down everything else
ufw default deny incoming
ufw default allow outgoing
```

## 🧪 Installed Services

- `Pi-hole` (port 53, 80, 443)
- `Unbound` (port 5335, internal)
- Local DNS resolution enabled for:
  - `*.cpoff.com`
  - `.lan` and `.infra` if needed

## ⚙️ Install Commands (Debian/Raspbian)

```bash
curl -sSL https://install.pi-hole.net | bash
sudo apt install unbound -y
```

Configure Unbound via `/etc/unbound/unbound.conf.d/pi-hole.conf`. Test recursion:

```bash
dig google.com @127.0.0.1 -p 5335
```

## 🔍 Validation

- Access Pi-hole UI: http://dns.cpoff.com from VLAN 10 client
- Tail logs: `pihole -t`
- DNS check: `dig dashy.cpoff.com @192.168.99.2`

---

_Last updated: SkyNet Prod 3.0_
