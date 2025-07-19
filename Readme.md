# 🧠 SkyNet — Full Homelab Topology Map

## 📌 Prod 3 Snapshot
**Topology with VLAN Segmentation, NAS Mounting, VPN Grooming Node, and Wireless SSIDs**

### ✅ Highlights
- `dellbox` (Debian) placed on VLAN 40 in the rack zone for secure downloading and post-processing
- NAS media share (`/volume2/media`) mounted via SMB on `dellbox` at `/mnt/nas_media`
- `.home` internal DNS domain for service resolution
- Tenda TEG208E serves as the core switch, uplinking to TP-Link access switches
- SSID mapping ensures wireless clients are properly segmented by access role

---

## 📶 Wireless SSIDs

| SSID Name         | Associated VLAN | Purpose                            |
|-------------------|------------------|------------------------------------|
| `SkyNet-Trusted`  | VLAN 10          | Full access for orchestration nodes and personal devices |
| `SkyNet-IoT`      | VLAN 20          | Smart devices and broadcast clients |
| `SkyNet-Guest`    | VLAN 30          | Internet-only access for guests     |

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Devices                                                | Purpose                                     |
|------|-------------|------------------|--------------------------------------------------------|---------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | `dietbox`, `minibox`, `workbox`, `chromebooks`        | GUI desktops, orchestration nodes           |
| 20   | IoT         | 10.10.20.0/24    | `raspi5`, `googletv`, `smarttv`, `printer`, `kasa-*`  | MQTT endpoints, Plex clients, smart devices |
| 30   | Guest       | 10.10.30.0/24    | (Wi-Fi guests)                                         | Internet-only clients                       |
| 40   | VPN Zone    | 10.10.40.0/24    | `dellbox`                                              | Secure downloading + media grooming         |
| 99   | Services    | 10.10.99.0/24    | `raspi4`, `nas`, `router`, `switch`, `raspi3`          | DNS, DHCP, storage, staging                 |

---

## 🧮 Physical Wiring — Tenda Core (8-Port Max)

### 🌐 Tenda TEG208E — Core Managed Switch

| Port | Connected Device / Uplink      | VLAN     | Role                                 |
|------|--------------------------------|----------|--------------------------------------|
| 1    | `router`                       | 99       | Gateway, DHCP, VLAN control          |
| 2    | `nas`                          | 99       | Synology Plex / media storage        |
| 3    | `raspi4`                       | 99       | Pi-hole + Unbound DNS                |
| 4    | `raspi3`                       | 99       | Experimental node                    |
| 5    | `dellbox`                      | 40       | VPN downloads + FileBot stack        |
| 6    | TP-Link #1 — Desk Zone         | 10       | `dietbox`, `minibox`, `workbox`, chromebooks |
| 7    | TP-Link #2 — TV / IoT Zone     | 20       | `googletv`, `smarttv`, printer, Kasa |
| 8    | TP-Link #3 — Lab / Staging     | 99       | Test devices, overflow containers    |

> TP-Link #4 (Spare Shelf) is not currently uplinked due to port constraints.

---

## 🧩 Device Inventory by VLAN

### 🟩 VLAN 10 — Trusted Clients

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Node-RED, Kuma, Homarr, Proxy Manager               |
| `minibox`      | MiniPC / Ubuntu + Win11   | Plex client, HA frontend                            |
| `workbox`      | Work Desktop / OS TBD     | Professional use only                               |
| `chromebook1`  | ChromeOS                  | Media/browser client                                |
| `chromebook2`  | ChromeOS                  | Media/browser client                                |

### 🟨 VLAN 20 — IoT Messaging Zone

| Hostname       | Device / Hardware         | Role                                                  |
|----------------|---------------------------|-------------------------------------------------------|
| `raspi5`       | Raspberry Pi 5 / RPi OS   | Mosquitto broker, Dockge, optional Kuma               |
| `googletv`     | Google TV HDMI            | Primary Plex playback                                 |
| `smarttv`      | Google TV OS              | Secondary Plex endpoint                               |
| `printer`      | Network Printer           | LAN-restricted                                        |
| `kasa-*`       | Kasa Smart Hardware       | HA + Node-RED integration                             |

### 🛡️ VLAN 40 — VPN Grooming Node

| Hostname       | Device / OS              | Role                                                        |
|----------------|---------------------------|-------------------------------------------------------------|
| `dellbox`      | Dell Desktop / Debian     | Gluetun VPN, qBittorrent, Sonarr/Radarr/FileBot stack  
> Mount point: `/mnt/nas_media` ←→ NAS `/volume2/media` via SMB  
> Cross-VLAN access via static route / firewall rules  

### 🟦 VLAN 99 — Infrastructure Backbone

| Hostname       | Device / Hardware         | Role                                                  |
|----------------|---------------------------|-------------------------------------------------------|
| `raspi4`       | Raspberry Pi 4 / DietPi   | Pi-hole + Unbound DNS Resolver                        |
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker, `/volume2/media`        |
| `router`       | TP-Link AX6600            | DHCP, routing, VLAN control                           |
| `switch`       | Tenda TEG208E             | Core VLAN trunking                                    |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Experimental node                                     |

---

## 📦 Service Summary

| Service             | Host Device     | Access Domain         | Role                                        |
|---------------------|-----------------|------------------------|---------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Internal media streaming                    |
| Home Assistant      | `nas`           | `https://assist.home`  | Smart home automation engine                |
| Mosquitto MQTT      | `raspi5`        | `mqtt.home:1883`       | Lightweight message broker                  |
| Node-RED            | `dietbox`       | `http://node-red.home` | Visual automation controller                |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Launchpad interface                         |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | SSL termination + reverse proxy             |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Container orchestration                     |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Status checks and heartbeat monitoring      |
| Pi-hole Admin       | `raspi4`        | `http://dns.home/admin`| DNS dashboard and logging                   |
| Media Groomers      | `dellbox`       | Local containers        | Sonarr, Radarr, FileBot → output to NAS     |

---

## 🧠 Internal DNS `.home` Records

| Domain Name         | IP Address       | Host Device                  |
|---------------------|------------------|-------------------------------|
| `plex.home`         | `10.10.99.10`    | `nas`                         |
| `assist.home`       | `10.10.99.10`    | `nas`                         |
| `dockge.home`       | `10.10.20.15`    | `raspi5`                      |
| `dashboard.home`    | `10.10.10.10`    | `dietbox`                     |
| `kuma.home`         | `10.10.10.10`    | `dietbox`                     |
| `dns.home`          | `10.10.99.4`     | `raspi4`                      |
| `mqtt.home`         | `10.10.20.15`    | `raspi5`                      |
| `node-red.home`     | `10.10.10.10`    | `dietbox`                     |
