## 🗺️ SkyNet Topology Map

### 🔧 Network Roles

| Role                    | Hostname            | IP Address     | Device / OS             | Services / Apps                                                                             |
|-------------------------|---------------------|----------------|--------------------------|----------------------------------------------------------------------------------------------|
| **Admin Core**          | `admincore.home`    | 10.10.10.10    | Dell XPS / Pop!_OS       | `dnsmasq`, Ansible, Docker, Portainer, Homarr, Watchtower, Netdata, Tailscale, UFW         |
| **Container Node**      | `dockerbox.ts.net`  | 10.10.20.14    | Raspberry Pi 5 / Raspian | Portainer Agent, Mosquitto, Vaultwarden, Home Assistant (optional), Zigbee2MQTT proxy       |
| **NAS Server**          | `nas.home`          | 10.10.20.10    | Synology NAS             | Plex, Media backup, Tautulli (opt), Synology Drive, SMB/NFS, Snapshots                      |
| **DNS Relay Node**      | `dns.home`          | 10.10.30.53    | Raspberry Pi 3 / DietPi  | Pi-hole, Unbound, Tailscale, UFW (port 53 only)                                             |
| **Utility Pi**          | `pi4-util.home`     | 10.10.30.11    | Raspberry Pi 4  / DietPi | AdGuard (port 8053), Prometheus exporter, NodeRED (opt), experimental agents                |
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



# 🗺️ Clint Pickle’s Homelab Reference Map

## 🔧 VLAN Specifications

| VLAN ID | Name           | Subnet            | Purpose                          | DHCP Source           | Notes                                           |
|---------|----------------|-------------------|----------------------------------|------------------------|------------------------------------------------|
| 10      | Admin Core     | 10.10.10.0/24     | Orchestration, DNS/DHCP, Control | `dnsmasq` on AdminCore | Ansible, Portainer, Homarr host                |
| 20      | Services       | 10.10.20.0/24     | Containerized Apps               | Optional relay         | Plex, Vaultwarden, MQTT, Portainer agents      |
| 30      | IoT/Utility    | 10.10.30.0/24     | Smart devices, radios, DNS nodes | Optional relay         | Zigbee2MQTT, Pi-hole, AdGuard                  |
| 40      | Guest          | 10.10.40.0/24     | Internet-only, untrusted clients | Router (fallback)      | Blocked from LAN                               |
| 99      | Management     | 10.10.99.0/24     | Core networking hardware         | Static assignment      | Switch/AP/router configs                        |

---

## 📶 SSID to VLAN Assignments

| SSID Name     | VLAN | Auth Type        | Broadcast | Purpose                                  |
|---------------|------|------------------|-----------|------------------------------------------|
| `AdminLAN`    | 10   | WPA2/3 Enterprise| Hidden    | Secure control access for trusted clients|
| `HomeDevices` | 20   | WPA2 Personal    | Visible   | Phones, tablets, media devices           |
| `SmartMesh`   | 30   | WPA2 Personal    | Hidden    | IoT relays, Zigbee nodes, sensors        |
| `GuestPortal` | 40   | WPA2 + Captive   | Visible   | Internet-only guest network              |

---

## 🖥️ Device Topology

| Hostname           | IP Address     | Hardware / OS            | Role                             | Services / Features                                                                 |
|--------------------|----------------|---------------------------|----------------------------------|--------------------------------------------------------------------------------------|
| `admincore.home`   | 10.10.10.10    | Dell XPS / Pop!_OS        | Orchestration / DNS Core         | `dnsmasq`, Ansible, Docker, Portainer, Homarr, Watchtower, Netdata, UFW             |
| `dockerbox.ts.net` | 10.10.20.14    | Raspberry Pi 5            | Container workload node          | Mosquitto, Vaultwarden, Home Assistant (opt), Portainer Agent                       |
| `nas.home`         | 10.10.20.10    | Synology NAS              | Media + file server              | Plex, Tautulli, Synology Drive, SMB/NFS shares                                       |
| `dns.home`         | 10.10.30.53    | Raspberry Pi 3            | DNS relay + filtering            | Pi-hole, Unbound, UFW, Tailscale                                                     |
| `pi4-util.home`    | 10.10.30.11    | Raspberry Pi 4            | Utility node / testbed           | AdGuard (port 8053), NodeRED (opt), Prometheus exporter                              |
| `router.home`      | 10.10.99.2     | TP-Link AX6600            | Gateway                          | VLAN trunking, optional DHCP relay, Tailscale (opt)                                 |
| `switch.home`      | 10.10.99.1     | L2 Managed Switch         | VLAN segmentation                | Tagged VLANs 10–40, Admin + trunk ports                                              |

---

## 📡 Services Summary

| App / Service       | Hosted On         | Description                                         |
|---------------------|-------------------|-----------------------------------------------------|
| **Homarr**          | `admincore`       | Visual dashboard + quick access                     |
| **Portainer**       | `admincore`       | Container UI + templates                           |
| **dnsmasq**         | `admincore`       | DNS/DHCP authoritative                             |
| **Pi-hole**         | `dns.home`        | DNS filtering, ad-blocking                         |
| **Unbound**         | `dns.home`        | Recursive resolver backend                         |
| **AdGuard**         | `pi4-util`        | Alternate DNS on port 8053                         |
| **Watchtower**      | `admincore`       | Auto-updates for select containers                 |
| **Netdata**         | `admincore`       | Real-time system metrics                           |
| **Uptime Kuma**     | `dockerbox`       | Network and service monitor                        |
| **Home Assistant**  | `dockerbox`       | Home automation brain (optional)                   |
| **Mosquitto**       | `dockerbox`       | MQTT broker for sensor/events                      |
| **Zigbee2MQTT**     | `pi4-util`        | Zigbee coordinator                                 |
| **Vaultwarden**     | `dockerbox`       | Password manager                                   |
| **Plex**            | `nas`             | Media streaming                                    |
| **Tautulli**        | `nas` (opt)       | Plex usage analytics                               |
| **Tailscale**       | All nodes         | Mesh VPN + overlay control plane                   |

---

_This file is a live operational record of your homelab’s topology and intent._

> **Last updated:** `$(date +%Y-%m-%d)`  

