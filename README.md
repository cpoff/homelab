# SkyNet – Prod 3 Topology Documentation

---

## 1. Overview

- **Name**: SkyNet  
- **Version**: Prod 3  
- **Environment Role**: Secure, VLAN-segmented, subdomain-routed infrastructure for home and technical operations

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

- **Point B – Workstation (~25 ft from rack)**
  - Linux Desktop (wired)
  - TP-Link TL-SG105 (Unmanaged)

- **Point C – Media Center (~25 ft opposite direction)**
  - Smart TV + Google TV
  - TP-Link Unmanaged Switch

---

## 3. VLAN Assignments

| VLAN ID | Name     | Purpose                          |
|---------|----------|----------------------------------|
| 10      | Trusted  | Core devices & desktops          |
| 20      | IoT      | Smart devices (TVs, plugs)       |
| 30      | Guest    | Internet-only, isolated VLAN     |
| 99      | Infra    | DNS, firewall, monitoring        |

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

## 6. UFW (Firewall) Highlights

**RPi 4 – dns.cpoff.com**
- Allows DNS (UDP/TCP 53) from VLANs 10, 20, 99  
- Allows web UI from VLAN 10  
- Denies all other inbound traffic  

**NAS – plex.cpoff.com**
- Allows HTTP/HTTPS from VLAN 10  
- Plex access from VLANs 10 & 20  
- Allows Tailscale ingress (100.64.0.0/10)  

**RPi 5 – forge.cpoff.com**
- Allows port 80/443 + 3000–3999 TCP from VLAN 10  
- Blocks all from VLAN 20  

**RPi 3 – node.cpoff.com**
- Allows Netdata (port 19999) from VLAN 10  
- General ICMP / health probes allowed  

---

## 7. DNS and SSL (Let’s Encrypt)

- **DNS Hosting**: Cloudflare (API token used by NGINX Proxy Manager)  
- **Certificates**: Wildcard cert for `*.cpoff.com` via DNS-01 challenge  
- **Provisioned By**: NGINX Proxy Manager (hosted on NAS)  
- **Renewal**: Automatic every ~60–90 days  
- **Security**: Valid SSL certs for all internal services

---

## 8. UFW Rules

### RPi 4 — dns.cpoff.com

```bash
ufw allow proto udp from 192.168.10.0/24 to any port 53
ufw allow proto tcp from 192.168.10.0/24 to any port 53
ufw allow proto udp from 192.168.20.0/24 to any port 53
ufw allow proto tcp from 192.168.20.0/24 to any port 53
ufw allow proto udp from 192.168.99.0/24 to any port 53
ufw allow proto tcp from 192.168.99.0/24 to any port 53
ufw allow from 192.168.10.0/24 to any port 80,443
ufw default deny incoming
ufw default allow outgoing
