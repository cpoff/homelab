# 🧠 SkyNet — Full Topology Map  
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

## 🧮 Physical Wiring by Switch

| Location           | Switch            | VLAN         | Connected Devices                                     |
|--------------------|-------------------|--------------|------------------------------------------------------|
| **Center Rack**    | Tenda TEG208E     | Managed      | `router`, `nas`, `raspi4`, `raspi3`, `dellbox`       |
|                    | TP-Link #3        | VLAN 99      | Optional lab/test devices                            |
| **Desk Zone**      | TP-Link #1        | VLAN 10      | `dietbox`, `minibox`, `workbox`                      |
| **TV Zone**        | TP-Link #2        | VLAN 20      | `googletv`, `smarttv`, `printer`, `kasa-*`           |
| **Spare Shelf**    | TP-Link #4        | TBD          | Future nodes — VLANs as needed                       |

---

## 🧩 Device Inventory (By VLAN)

### 🟩 VLAN 10 — Trusted Clients

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Node-RED, Kuma, Homarr, Proxy Manager               |
| `minibox`      | MiniPC / Ubuntu + Win11   | Plex client, HA frontend                            |
| `workbox`      | Work Desktop / OS TBD     | Professional use only                               |
| `chromebook1`  | ChromeOS                  | Media/browser client                                |
| `chromebook2`  | ChromeOS                  | Media/browser client                                |

---

### 🟨 VLAN 20 — IoT Messaging Zone

| Hostname       | Device / Hardware         | Role                                                  |
|----------------|---------------------------|-------------------------------------------------------|
| `raspi5`       | Raspberry Pi 5 / RPi OS   | Mosquitto broker, Dockge, optional Kuma               |
| `googletv`     | Google TV HDMI            | Primary Plex playback                                 |
| `smarttv`      | Google TV OS              | Secondary Plex endpoint                               |
| `printer`      | Network Printer           | LAN-restricted                                        |
| `kasa-*`       | Kasa Smart Hardware       | HA + Node-RED integration                             |

---

### 🛡️ VLAN 40 — VPN Downloads & Processing

| Hostname       | Device / OS              | Role                                                        |
|----------------|---------------------------|-------------------------------------------------------------|
| `dellbox`      | Dell Desktop / Pop!_OS    | Gluetun VPN, qBittorrent, Sonarr/Radarr/FileBot → mounts NAS share

> Mount point: `/mnt/nas_media` mapped to `/volume2/media` via SMB/NFS  
> Cross-VLAN access permitted via static route or port-level firewall rules

---

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
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Container orchestration tool                |
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

---

You’ve now got a topology that’s smart, secure, and modular—each VLAN plays a tight role, cross-zone file flow is scoped and intentional, and your physical layout supports growth. Want me to translate this into a visual rack + switch diagram next?
