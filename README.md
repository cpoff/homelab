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
| TEG208E Switch | switch.cpoff.com     | 99   | DHCP or Static | Managed UI                       |
| Synology NAS   | plex.cpoff.com       | 10   | 192.168.10.2   | Plex, HA, Portainer              |
| RPi 5          | forge.cpoff.com      | 10   | 192.168.10.3   | CasaOS, Jellyfin, Dashy          |
| RPi 4          | dns.cpoff.com        | 99   | 192.168.99.2   | Pi-hole + Unbound                |
| RPi 3          | node.cpoff.com       | 99   | 192.168.99.3   | Netdata, utility monitoring      |
| Workstation    | —                    | 10   | DHCP or Static | Wired Linux desktop              |
| Printer        | —                    | 10   | DHCP or Static | Wired via rack switch            |
| TV / Google TV | —                    | 20   | DHCP           | IoT VLAN via unmanaged switch    |

---

## 5. Subdomain Routing (`*.cpoff.com`)

All subdomains resolve locally via Pi-hole:

- `plex.cpoff.com`, `ha.cpoff.com`, `portainer.cpoff.com` → NAS (192.168.10.2)  
- `dashy.cpoff.com`, `forge.cpoff.com` → RPi 5 (192.168.10.3)  
- `dns.cpoff.com`, `node.cpoff.com` → Infra nodes (RPi 4/3)  
- `router.cpoff.com`, `switch.cpoff.com` → Admin interfaces  

---

## 6. DNS and SSL (Let’s Encrypt)

- **DNS Hosting**: Cloudflare  
- **Certificates**: Wildcard cert for `*.cpoff.com` via DNS-01  
- **Provisioned By**: NGINX Proxy Manager on NAS  
- **Renewal**: Automatic (~60–90 days)  
- **Security**: Valid SSL certs for all internal services  

---

## 7. UFW Firewall Rules (With Commentary)

### 📡 RPi 4 — `dns.cpoff.com` (Pi-hole + Unbound)

```bash
# Allow DNS (UDP/TCP) from Trusted VLAN (workstation, NAS, etc.)
ufw allow proto udp from 192.168.10.0/24 to any port 53
ufw allow proto tcp from 192.168.10.0/24 to any port 53

# Allow DNS from IoT VLAN (TVs, streamers)
ufw allow proto udp from 192.168.20.0/24 to any port 53
ufw allow proto tcp from 192.168.20.0/24 to any port 53

# Allow DNS from Infra VLAN (RPi nodes, NAS, internal resolvers)
ufw allow proto udp from 192.168.99.0/24 to any port 53
ufw allow proto tcp from 192.168.99.0/24 to any port 53

# Allow access to Pi-hole Web UI from VLAN 10 only
ufw allow from 192.168.10.0/24 to any port 80,443

# Deny all other unsolicited inbound packets
ufw default deny incoming

# Permit all outbound traffic
ufw default allow outgoing
```

### 🧠 Synology NAS — `plex.cpoff.com`, `ha.cpoff.com`, etc.

```bash
# Allow dashboard access from Trusted VLAN (workstation)
ufw allow from 192.168.10.0/24 to any port 80,443

# Allow Plex traffic from VLAN 10 (local clients)
ufw allow from 192.168.10.0/24 to any port 32400

# Allow Plex from VLAN 20 (TVs / Google TV)
ufw allow from 192.168.20.0/24 to any port 32400

# Allow ingress from Tailscale overlay (remote access)
ufw allow from 100.64.0.0/10

# Default lockdown for everything else inbound
ufw default deny incoming

# Open egress for updates, DNS, container images, cert refresh
ufw default allow outgoing
```

### 🛠️ RPi 5 — `forge.cpoff.com` (CasaOS, Jellyfin, Dashy)

```bash
# Allow web access to dashboards on HTTP/HTTPS
ufw allow from 192.168.10.0/24 to any port 80,443

# Allow Docker-hosted apps (e.g., CasaOS) on high ports
ufw allow from 192.168.10.0/24 to any port 3000:3999 proto tcp

# Block all inbound connections from VLAN 20 (IoT)
ufw deny from 192.168.20.0/24

# Lockdown all other inbound access
ufw default deny incoming

# Allow outbound to internet, local DNS, update services
ufw default allow outgoing
```

### 📊 RPi 3 — `node.cpoff.com` (Netdata + Diagnostics)

```bash
# Permit Netdata UI access from NAS only
ufw allow from 192.168.10.2 to any port 19999

# Allow general ping + system probes from Trusted VLAN
ufw allow from 192.168.10.0/24 to any

# Allow backend infra communication from VLAN 99
ufw allow from 192.168.99.0/24 to any

# Block all other inbound connections
ufw default deny incoming

# Full egress allowed (for telemetry, sync, updates)
ufw default allow outgoing
```

---

## 8. Admin Terminal Alias Library (`~/.bash_aliases`)

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
alias nas="ssh admin@plex.cpoff.com"
alias dns="ssh pi@dns.cpoff.com"
alias node="ssh pi@node.cpoff.com"
alias routerui="firefox http://router.cpoff.com"
alias switchui="firefox http://switch.cpoff.com"

# === [🖥️ System Control – Desktop Tools] ===
alias updates="sudo apt update && sudo apt upgrade -
