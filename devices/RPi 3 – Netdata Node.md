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


# INSTALLATION - node.cpoff.com Configuration (RPi 3 – Netdata + Utility Monitor)

## 📦 Role

This node provides lightweight system monitoring and diagnostic support via Netdata. Positioned in VLAN 99, it acts as a health beacon for the rest of SkyNet’s infrastructure while keeping a low attack surface.

---

## 🌐 Network Configuration

- **VLAN**: 99 (Infra)
- **Static IP**: `192.168.99.3`
- **Hostname**: `node`
- **FQDN**: `node.cpoff.com`

### `/etc/hostname`

```bash
node
```

### `/etc/hosts`

```bash
127.0.0.1       localhost
127.0.1.1       node.cpoff.com node
```

### `/etc/dhcpcd.conf`

```bash
interface eth0
static ip_address=192.168.99.3/24
static routers=192.168.99.1
static domain_name_servers=192.168.99.2
```

Then reboot:

```bash
sudo reboot
```

---

## 🛡️ Firewall Configuration (UFW)

```bash
# Allow Netdata UI access from NAS only
ufw allow from 192.168.10.2 to any port 19999

# Allow diagnostics (ping, etc.) from Trusted VLAN
ufw allow from 192.168.10.0/24 to any

# Allow Infra VLAN to access services
ufw allow from 192.168.99.0/24 to any

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

**Install and enable:**

```bash
sudo apt update
sudo apt install ufw -y
sudo ufw enable
```

---

## 📊 Netdata Installation

Install via the official kickstart script:

```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

**Enable and check status:**

```bash
sudo systemctl enable netdata
sudo systemctl status netdata
```

**Web UI:**  
http://node.cpoff.com:19999  
(Accessible only from `192.168.10.2` or VLAN 10 clients if adjusted)

---

## 🔍 Validation Checklist

- ✅ Hostname resolves correctly: `ping node.cpoff.com`
- ✅ Dashboard loads from NAS: `curl http://node.cpoff.com:19999`
- ✅ Firewall isolates from IoT and Guest VLANs
- ✅ System metrics flowing via Netdata panel

---

## 🧰 Optional Enhancements

- Install `lm-sensors` for temp monitoring:

```bash
sudo apt install lm-sensors -y
sudo sensors-detect
```

- Add custom Netdata alarms or panels
- Integrate with Dashy:  
  `node.cpoff.com` → `Netdata Monitor` with icon + link

---

_Last Updated: SkyNet Prod 3_

