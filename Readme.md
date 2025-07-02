## 🗺️ Homelab Topology Map

### 🔧 Network Roles

| Role                    | Hostname            | IP Address     | Device / OS             | Services / Apps                                                                             |
|-------------------------|---------------------|----------------|--------------------------|----------------------------------------------------------------------------------------------|
| **Admin Core**          | `admincore.home`    | 10.10.10.10    | Dell XPS / Pop!_OS       | `dnsmasq`, Ansible, Docker, Portainer, Homarr, Watchtower, Netdata, Tailscale, UFW         |
| **Container Node**      | `dockerbox.ts.net`  | 10.10.20.14    | Raspberry Pi 5           | Portainer Agent, Mosquitto, Vaultwarden, Home Assistant (optional), Zigbee2MQTT proxy       |
| **NAS Server**          | `nas.home`          | 10.10.20.10    | Synology NAS             | Plex, Media backup, Tautulli (opt), Synology Drive, SMB/NFS, Snapshots                      |
| **DNS Relay Node**      | `dns.home`          | 10.10.30.53    | Raspberry Pi 3           | Pi-hole, Unbound, Tailscale, UFW (port 53 only)                                             |
| **Utility Pi**          | `pi4-util.home`     | 10.10.30.11    | Raspberry Pi 4           | AdGuard (port 8053), Prometheus exporter, NodeRED (opt), experimental agents                |
| **IoT Clients**         | `kasa01`, etc.      | 10.10.30.x     | Smart Plugs, Switches    | DNS via Pi-hole, MQTT via Mosquitto                                                         |
| **Router / Gateway**    | `router.home`       | 10.10.99.2     | TP-Link AX6600           | DHCP relay, VLAN trunking, subnet routes, Tailscale (opt)                                   |
| **Switch / Core VLAN**  | `switch.home`       | 10.10.99.1     | L2 Managed Switch         | Tagged VLANs: Admin (10), Services (20), IoT (30), Guests (40)                              |

---

### 📡 Services Matrix

| Service / App          | Location              | Notes                                 |
|------------------------|-----------------------|---------------------------------------|
| **Homarr**             | `admincore`           | Drag-and-drop dashboard               |
| **Portainer**          | `admincore` + agent   | Docker container orchestration        |
| **dnsmasq**            | `admincore`           | Primary local DNS + DHCP              |
| **Pi-hole**            | `dns.home`            | DNS filtering & metrics               |
| **Unbound**            | `dns.home`            | Recursive resolver backend            |
| **AdGuard Home**       | `pi4-util`            | Alt DNS on port 8053 (test node)      |
| **Home Assistant**     | `dockerbox`           | Smart home brain (opt)                |
| **Mosquitto**          | `dockerbox`           | MQTT broker for HA + Zigbee           |
| **Zigbee2MQTT**        | `pi4-util`            | Radio + converter                     |
| **Plex**               | `nas`                 | Media server                          |
| **Vaultwarden**        | `dockerbox`           | Self-hosted password manager          |
| **Tautulli** (opt)     | `nas`                 | Plex analytics                        |
| **Netdata**            | `admincore`           | Real-time telemetry                   |
| **Uptime Kuma**        | `dockerbox`           | Service ping + alerts                 |
| **Tailscale**          | Most nodes            | Encrypted overlay w/ MagicDNS         |




# SkyNet – Prod 3 Topology Documentation

---

## 1. Overview

- **Name**: SkyNet  
- **Version**: Prod 3  
- **Role**: Secure, VLAN-segmented, subdomain-routed infrastructure for home and technical operations

---

## 2. Physical Topology

### Rack: 4-Shelf Unit (Point A)

| Shelf | Device                       | Notes                           |
|-------|------------------------------|----------------------------------|
| Top   | TP-Link AX6600 Router        | Main router, ISP uplink         |
| 2nd   | Tenda TEG208E Managed Switch | Core switch, VLAN trunking      |
| 3rd   | Network Printer              | Wired to switch                 |
| 4th   | Synology NAS                 | Hosts Plex, HA, Docker stack    |

### Remote Nodes

- **Point B – Workstation (~25 ft)**  
  - Linux Desktop (wired)  
  - TP-Link TL-SG105 (Unmanaged)

- **Point C – Media Center (~25 ft)**  
  - Smart TV + Google TV  
  - TP-Link Unmanaged Switch

---

## 3. VLAN Assignments

| VLAN ID | Name     | Purpose                       |
|---------|----------|-------------------------------|
| 10      | Trusted  | Core devices & desktops       |
| 20      | IoT      | Smart devices (TVs, plugs)    |
| 30      | Guest    | Internet-only, isolated VLAN  |
| 99      | Infra    | DNS, firewall, monitoring     |

---

## 4. Device Mapping + Hostnames

| Device         | Subdomain           | VLAN | IP Address     | Notes                            |
|----------------|----------------------|------|----------------|----------------------------------|
| Router         | router.cpoff.com     | 99   | 192.168.99.1   | Admin UI                         |
| TEG208E Switch | switch.cpoff.com     | 99   | 192.168.99.8   | Managed UI                       |
| Synology NAS   | nas.cpoff.com        | 10   | 192.168.10.2   | Plex, HA, Portainer              |
| RPi 5          | forge.cpoff.com      | 10   | 192.168.10.3   | CasaOS, Jellyfin, Dashy          |
| RPi 4          | dns.cpoff.com        | 99   | 192.168.99.2   | Pi-hole + Unbound                |
| RPi 3          | node.cpoff.com       | 99   | 192.168.99.3   | Netdata, utility monitoring      |
| Workstation    | —                    | 10   | DHCP or Static | Wired Linux desktop              |
| Printer        | —                    | 10   | DHCP or Static | Wired via rack switch            |
| TV / Google TV | —                    | 20   | DHCP           | IoT VLAN via unmanaged switch    |

---

## 5. Subdomain Routing (`*.cpoff.com`)

All subdomains resolve locally via Pi-hole:

- `nas.cpoff.com`, `ha.cpoff.com`, `portainer.cpoff.com` → NAS  
- `dashy.cpoff.com`, `forge.cpoff.com` → RPi 5  
- `dns.cpoff.com`, `node.cpoff.com` → Infra nodes  
- `router.cpoff.com`, `switch.cpoff.com` → Admin interfaces  

---

## 6. DNS and SSL (Let’s Encrypt)

- **DNS Hosting**: Cloudflare  
- **Certificates**: Wildcard cert for `*.cpoff.com` via DNS-01  
- **Provisioned By**: NGINX Proxy Manager (on NAS)  
- **Renewal**: Automatic every ~60–90 days  
- **Security**: Valid SSL certs for all internal services  

---

## 7. UFW Firewall Rules (With Commentary)

### 📡 RPi 4 — `dns.cpoff.com` (Pi-hole + Unbound)

```bash
# Allow DNS (UDP/TCP) from Trusted VLAN
ufw allow proto udp from 192.168.10.0/24 to any port 53
ufw allow proto tcp from 192.168.10.0/24 to any port 53

# Allow DNS from IoT VLAN
ufw allow proto udp from 192.168.20.0/24 to any port 53
ufw allow proto tcp from 192.168.20.0/24 to any port 53

# Allow DNS from Infra VLAN
ufw allow proto udp from 192.168.99.0/24 to any port 53
ufw allow proto tcp from 192.168.99.0/24 to any port 53

# Allow Pi-hole Web UI from VLAN 10 only
ufw allow from 192.168.10.0/24 to any port 80,443

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

### 🧠 Synology NAS — `nas.cpoff.com`, `ha.cpoff.com`, etc.

```bash
# Web UIs from Trusted VLAN
ufw allow from 192.168.10.0/24 to any port 80,443

# Plex from VLANs 10 & 20
ufw allow from 192.168.10.0/24 to any port 32400
ufw allow from 192.168.20.0/24 to any port 32400

# VPN ingress from Tailscale
ufw allow from 100.64.0.0/10

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

### 🛠️ RPi 5 — `forge.cpoff.com` (App Stack)

```bash
# HTTP/HTTPS access from VLAN 10
ufw allow from 192.168.10.0/24 to any port 80,443

# Access to containerized apps
ufw allow from 192.168.10.0/24 to any port 3000:3999 proto tcp

# Block IoT VLAN
ufw deny from 192.168.20.0/24

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

### 📊 RPi 3 — `node.cpoff.com` (Monitoring Node)

```bash
# Netdata access from NAS
ufw allow from 192.168.10.2 to any port 19999

# General probes from VLAN 10
ufw allow from 192.168.10.0/24 to any

# Internal monitoring from Infra
ufw allow from 192.168.99.0/24 to any

# Default policies
ufw default deny incoming
ufw default allow outgoing
```

---

## 8. Admin Alias Library (`~/.bash_aliases`)

```bash
# === [🔥 UFW – Firewall Control] ===
alias ufwstatus="sudo ufw status numbered"
alias ufwreset="sudo ufw reset && echo 'Firewall reset. Reload your baseline rules.'"
alias ufwreload="sudo ufw reload"
alias ufwtail="journalctl -u ufw -f"

# === [📦 Docker Shortcuts] ===
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias logs="docker compose logs -f"
alias dockernuke="docker system prune -af --volumes"

# === [🔒 Tailscale Utilities] ===
alias tsstatus="tailscale status"
alias tsip="tailscale ip -4 | head -n 1"
alias tsping="tailscale ping dns.cpoff.com && tailscale ping forge.cpoff.com"

# === [🧠 Host Access – Core Nodes] ===
alias forge="ssh curt@forge.cpoff.com"
alias nas="ssh admin@nas.cpoff.com"
alias dns="ssh pi@dns.cpoff.com"
alias node="ssh pi@node.cpoff.com"
alias routerui="firefox http://router.cpoff.com"
alias switchui="firefox http://switch.cpoff.com"

# === [🖥️ System Control – Desktop Tools] ===
alias updates="sudo apt update && sudo apt upgrade -y"
alias rebootme="sudo reboot now"
alias cleanme="sudo apt autoremove -y && sudo apt autoclean"
alias alertlog="journalctl -p 3 -xb"

# === [🔍 Diagnostic Utilities] ===
alias skynetmap="echo 'Trusted: 192.168.10.x | IoT: 192.168.20.x | Infra: 192.168.99.x'"
alias netcheck="ping -c 4 dns.cpoff.com && ping -c 4 1.1.1.1"
alias portwatch="sudo netstat -tulpn | grep LISTEN"
```

# SkyNet Prod 3 – Device Interconnection Topology

This map shows how each node in your SkyNet deployment physically and logically connects via the managed switch and VLAN structure. Designed for clarity during provisioning and future audits.

---

## 🔌 Physical Port-to-Device Mapping (TEG208E Switch)

| Switch Port | Connected Device        | Hostname         | VLAN   | Connection Type     |
|-------------|--------------------------|------------------|--------|----------------------|
| 1           | Router                   | router           | Trunk  | Uplink (VLANs 10/20/99) |
| 2           | Synology NAS             | nas              | 10     | Ethernet             |
| 3           | RPi 4                    | dns              | 99     | Ethernet             |
| 4           | RPi 5                    | forge            | 10     | Ethernet             |
| 5           | RPi 3                    | node             | 99     | Ethernet             |
| 6           | IoT dev/test board       | iot-dev          | 20     | Ethernet             |
| 7           | Smart TV / Firestick hub | media-iot        | 20     | Ethernet/WiFi bridge |
| 8           | Admin Workstation        | opscenter        | 10     | Ethernet             |

---

## 🧠 VLAN Tagging Behavior

| Port | Tagging     | Untagged VLAN | Purpose                        |
|------|-------------|----------------|--------------------------------|
| 1    | Tagged      | —              | Routes all VLANs to router     |
| 2    | Untagged    | 10             | NAS in Trusted VLAN            |
| 3    | Untagged    | 99             | DNS resolver node              |
| 4    | Untagged    | 10             | App stack on Forge             |
| 5    | Untagged    | 99             | Netdata and diagnostics        |
| 6    | Untagged    | 20             | IoT test board                 |
| 7    | Untagged    | 20             | Media IoT segment              |
| 8    | Untagged    | 10             | Admin shell & UI                |

---

## 🌐 Logical Layer 3 Mapping

| Node           | Uplink Path                 | Final Hop Switch Port |
|----------------|-----------------------------|------------------------|
| dns            | Switch Port 3 → Port 1 → Router (VLAN 99) |
| forge          | Switch Port 4 → Port 1 → Router (VLAN 10) |
| nas            | Switch Port 2 → Port 1 → Router (VLAN 10) |
| node           | Switch Port 5 → Port 1 → Router (VLAN 99) |
| iot-dev        | Switch Port 6 → Port 1 → Router (VLAN 20) |
| opscenter      | Switch Port 8 → Port 1 → Router (VLAN 10) |

> All external/ISP traffic leaves via Router VLAN trunk through Port 1.

---

## 🔐 Overlay Map (Tailscale)

- All nodes joined into mesh: `dns`, `forge`, `nas`, `node`, `opscenter`
- No dependency on VLAN reachability for overlay communication
- Enforces zero-trust access to:
  - `:53` DNS (dns)
  - `:32400` Plex (nas)
  - `:19999` Netdata (node)
  - `:3000–3999` App dashboards (forge)

---

_Last Updated: SkyNet Prod 3 – Physical/Logical Device Topology_

