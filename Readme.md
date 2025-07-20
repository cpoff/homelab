# 🧠 SkyNet — IoT-Secured Homelab Network Layout (Simplified, No Guest Network)

## 🧩 Zones Overview

| Zone             | Devices                                                  | Role                                          | Notes                                               |
|------------------|-----------------------------------------------------------|-----------------------------------------------|-----------------------------------------------------|
| **Trusted LAN**  | `dietbox`, `minibox`, `workbox`, `chromebooks`           | Personal & homelab orchestration nodes        | Full access to infrastructure + dashboards          |
| **IoT Zone**     | `googletv`, `smarttv`, `printer`, `kasa-*`               | Noisy/broadcast devices                       | Internet-only access via firewall isolation         |
| **VPN Grooming** | `dellbox`                                                | qBittorrent, Sonarr/Radarr/FileBot stack      | Can mount NAS share, isolated from other LAN zones |
| **Infrastructure** | `raspi4`, `raspi3`, `nas`, `router`, `switch`         | Core services                                 | DNS, DHCP, media library, routing                   |

---

## 📶 SSID Configuration

| SSID Name         | Associated Zone   | Device Access                   | Controls                                     |
|-------------------|-------------------|----------------------------------|----------------------------------------------|
| `SkyNet-Trusted`  | Trusted LAN       | `dietbox`, `workbox`, etc.      | Full access to LAN, NAS, dashboards          |
| `SkyNet-IoT`      | IoT Zone          | Smart TVs, bulbs, printer       | Blocked from LAN; allowed internet only      |

---

## 🔐 Suggested Firewall Rules

| Source Zone     | Destination Zone    | Rule Description                                 |
|------------------|---------------------|--------------------------------------------------|
| IoT             | Trusted             | ❌ Deny all                                      |
| IoT             | Infrastructure      | ❌ Deny (except optional DNS)                   |
| IoT             | Internet            | ✅ Allow (rate-limited or monitored)            |
| Trusted         | Infrastructure      | ✅ Allow                                        |
| VPN Grooming    | NAS (`/mnt/nas_media`) | ✅ Allow (via IP whitelist or port restriction) |

---

## 📦 Device Role Map

### 🟩 Trusted LAN Devices

| Device       | Role                                       |
|--------------|--------------------------------------------|
| `dietbox`    | Automation hub (Node-RED, Kuma, Homarr)    |
| `minibox`    | Plex client, HA frontend                   |
| `workbox`    | Workstation node                           |
| `chromebooks`| Media/browser clients                      |

### 🟨 IoT Zone Devices

| Device       | Role                                       |
|--------------|--------------------------------------------|
| `googletv`   | Primary Plex playback                      |
| `smarttv`    | Secondary Plex endpoint                    |
| `printer`    | LAN-restricted print node                  |
| `kasa-*`     | Smart plugs/lights (HA triggers)           |

### 🛡️ VPN Grooming Node

| Device       | Role                                       |
|--------------|--------------------------------------------|
| `dellbox`    | Debian box running Gluetun, grooming stack |
|              | Mounts NAS media share via SMB             |

### 🏛️ Infrastructure Devices

| Device       | Role                                       |
|--------------|--------------------------------------------|
| `nas`        | Jellyfin, Plex, Home Assistant             |
| `raspi4`     | Pi-hole + DNS                              |
| `raspi3`     | Experimental node                          |
| `router`     | DHCP, routing                              |
| `switch`     | Core trunk distribution                    |

---

## 🧠 Monitoring + Hardening Tips

- 🧱 Use Pi-hole (on `raspi4`) to log and block outbound IoT traffic
- 🎚️ Limit device access with static IPs + DNS zone files
- 🕵️ Consider enabling host-level firewalls on NAS and `dellbox`
- 🗂️ Use NAS accounts with folder-level permissions (read-only for groomers)

---
## 🧮 Physical Wiring Layout — IoT-Secured Design with Existing Switches

Even in a simplified segmentation model, your managed switch and TP-Link units play a critical role in physical organization. Here's how to leverage all switches while keeping the zones clean and secure.

---

### 🌐 Core Switch — Tenda TEG208E (8-Port Limit)

| Port | Uplink / Device           | Role / VLAN / Zone                       |
|------|---------------------------|------------------------------------------|
| 1    | `router`                  | Routing, DHCP (Infrastructure)           |
| 2    | `nas`                     | Media server + HA host (Infrastructure) |
| 3    | `raspi4`                  | Pi-hole DNS (Infrastructure)            |
| 4    | `raspi3`                  | Experimental node (Infrastructure)      |
| 5    | `dellbox`                 | VPN Grooming, NAS mount (VPN zone)      |
| 6    | TP-Link #1 — Desk Zone    | `dietbox`, `minibox`, `workbox`, chromebooks (Trusted) |
| 7    | TP-Link #2 — IoT Zone     | `googletv`, `smarttv`, `printer`, `kasa-*` (IoT) |
| 8    | TP-Link #3 — Overflow Lab | Staging gear, containers (Trusted or Infra) |

> TP-Link #4 (Spare Shelf): Optional daisy-chain from TP-Link #3 or local-only devices

---

### 🖥️ TP-Link #1 — Desk / Trusted Zone

| Connected Devices          | Role                             |
|----------------------------|----------------------------------|
| `dietbox`                 | Node-RED, Kuma, Homarr           |
| `minibox`                 | Plex client, HA frontend         |
| `workbox`                 | Workstation                      |
| `chromebook1/2`           | Media/browser clients            |

---

### 📺 TP-Link #2 — TV / IoT Zone

| Connected Devices          | Role                             |
|----------------------------|----------------------------------|
| `googletv`                | Primary Plex client              |
| `smarttv`                 | Secondary Plex client            |
| `printer`                 | Network print node               |
| `kasa-*`                  | Smart devices (HA triggers)      |

---

### 🧪 TP-Link #3 — Lab / Overflow Staging

| Connected Devices          | Role                             |
|----------------------------|----------------------------------|
| Test containers or nodes  | Debug, isolation, expansion      |

---

### 🔄 TP-Link #4 — Spare Shelf

| Status                     | Role                             |
|----------------------------|----------------------------------|
| Unused (no uplink)         | Reserved for future expansion    |

---


# 🧠 SkyNet — Full Homelab Topology Map  HARD 

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
