# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — Desk VLAN Fix + `dellbox` Relocated to Rack**  
🎯 Key Adjustments:
- ❌ Removed TP-Link #1 as mixed-VLAN desk switch  
- ✅ Relocated `dellbox` to center rack → clean VLAN 40 via direct Tenda access port  
- ✅ All unmanaged switches now carry **single VLAN domains**  
- ✅ Desk zone is VLAN 10 only (`dietbox`, `minibox`)  
- ✅ Behind-TV switch feeds VLAN 20 devices  
- ✅ Center rack hosts VLAN 99 + VLAN 40 endpoints

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Connected Devices                             | Purpose                                         |
|------|-------------|------------------|------------------------------------------------|-------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | `dietbox`, `minibox`, `chromebooks`           | GUI desktops, orchestration nodes              |
| 20   | IoT         | 10.10.20.0/24    | `raspi5`, `googletv`, `smarttv`, `printer`, `kasa-*` | Smart home endpoints + MQTT messaging         |
| 30   | Guest       | 10.10.30.0/24    | (Wi-Fi guests)                                 | Internet-only access                            |
| 40   | VPN Zone    | 10.10.40.0/24    | `dellbox` (now in rack)                        | Gluetun-based secure downloads + media prep     |
| 99   | Services    | 10.10.99.0/24    | `raspi4`, `nas`, `router`, `switch`, `raspi3` | Infra backbone: DNS, storage, test nodes        |

---

## 🧮 Physical Wiring & Switch Placement

| Location             | Switch Type         | VLAN               | Devices                                     |
|----------------------|---------------------|---------------------|---------------------------------------------|
| **Center Rack**      | Tenda TEG208E       | Managed (all VLANs) | `router`, `raspi4`, `raspi3`, `nas`, `dellbox`  
|                      | TP-Link #3 (Unmanaged) | VLAN 99            | Backup or staging devices                  |
| **Desk Zone**        | TP-Link #1 (Unmanaged) | VLAN 10            | `dietbox`, `minibox`                       |
| **TV Zone**          | TP-Link #2 (Unmanaged) | VLAN 20            | `smarttv`, `googletv`, `printer`, `kasa-*` |
| **Spare Shelf**      | TP-Link #4 (Unmanaged) | TBD                | Future lab nodes or temporary connections  |

> All TP-Link unmanaged switches receive VLAN-specific uplinks from the Tenda switch.

---

## 🧩 Device Inventory

### 🟩 VLAN 10 — Trusted Clients

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless orchestrator: Proxy, Node-RED, Kuma, Docker  
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI desktop, Plex client, Home Assistant interface  
| `chromebook1`  | ChromeOS                  | Web dashboard + Plex client                        |
| `chromebook2`  | ChromeOS                  | Web dashboard + Plex client                        |

### 🟨 VLAN 20 — IoT Zone

| Hostname       | Device / Hardware         | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `raspi5`       | Raspberry Pi 5 / RPi OS   | Mosquitto broker, Dockge UI, optional Kuma          |
| `googletv`     | Google TV HDMI            | Plex endpoint                                       |
| `smarttv`      | Google TV OS              | Backup Plex endpoint                               |
| `printer`      | Network Printer           | LAN-restricted service                             |
| `kasa-*`       | Smart plugs/switches      | Automated via HA + Node-RED                        |

### 🛡️ VLAN 40 — VPN Isolation

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dellbox`      | Dell Desktop / Pop!_OS    | Gluetun VPN gateway, media downloader stack (Sonarr, Radarr, FileBot, qBittorrent)

> Now wired directly to Tenda access port for VLAN 40 (no unmanaged switch involved).

### 🟦 VLAN 99 — Services Backbone

| Hostname       | Device / Hardware         | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `raspi4`       | Raspberry Pi 4 / DietPi   | Pi-hole + Unbound DNS Resolver                     |
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers             |
| `router`       | TP-Link AX6600            | DHCP, VLAN routing, DNS relay                      |
| `switch`       | Tenda TEG208E             | Managed backbone switch                            |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Experimental node                                  |

---

## 📦 Services Summary

| Service             | Host Device     | Access Domain         | Purpose                                    |
|---------------------|-----------------|------------------------|--------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Internal streaming                         |
| Home Assistant      | `nas`           | `https://assist.home`  | Smart automation engine                    |
| Mosquitto MQTT      | `raspi5`        | `mqtt.home:1883`       | IoT messaging broker                       |
| Node-RED            | `dietbox`       | `http://node-red.home` | Visual flow logic                          |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Service overview                           |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | Reverse proxy + HTTPS routing              |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Compose-based container control            |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Node health + alerts                       |
| Pi-hole Admin       | `raspi4`        | `http://dns.home/admin`| DNS filtering dashboard                    |
| Media Groomers      | `dellbox`       | (Local containers)     | Radarr, Sonarr, FileBot, routed via Gluetun  
| NAS Volume2         | `nas`           | `/volume2/media`       | Dedicated media storage                     |

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

Your physical layout now matches your logical VLAN model—no cross-domain conflicts, clean handoffs, and streamlined performance from switch to service. We can diagram this visually or start annotating physical ports if you’re ready to label cables. This build hums.
