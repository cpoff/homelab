# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — Revised to Reflect Service Separation**  
🎯 Guiding Principle:  
→ Headless services live on `dietbox` (native or containerized)  
→ GUI workflows and client tools stay on `minibox`, Chromebooks, and streaming clients  
→ `dellbox` fully retired  

---

## 🔐 VLAN Overview

| VLAN | Label       | Subnet           | Role                                                             |
|------|-------------|------------------|------------------------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | Desktop devices and orchestration nodes                         |
| 20   | IoT         | 10.10.20.0/24    | Smart hardware, MQTT clients, Kasa devices                      |
| 30   | Guest       | 10.10.30.0/24    | Internet-only devices                                            |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS, router, switch, utility Pi nodes                      |

---

## 🧮 Active Device Inventory

### 🟩 Trusted VLAN

| Hostname       | Device / OS              | Role                                                   |
|----------------|---------------------------|--------------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless service node: Docker + native apps           |
| `minibox`      | MiniPC / Ubuntu Desktop   | GUI desktop for user apps + Home Assistant front-end  |
| `chromebook1`  | ChromeOS                  | Plex client, browsing                                 |
| `chromebook2`  | ChromeOS                  | Plex client, browsing                                 |

### 🟨 IoT VLAN

| Hostname       | Device / Type             | Role                                                   |
|----------------|---------------------------|--------------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Dockge (Docker UI), Mosquitto MQTT (Docker), Kuma     |
| `printer`      | Network Printer           | Available only to Trusted devices                     |
| `googletv`     | Google TV HDMI            | **Primary Plex playback endpoint**                    |
| `smarttv`      | Google TV                 | **Backup Plex client**                                |
| `kasa-*`       | Kasa Smart Devices        | Switched, plug, and strip automation via Home Assistant |

### 🟦 Services VLAN

| Hostname       | Device / OS              | Role                                                   |
|----------------|---------------------------|--------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers                |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS server                           |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved for experiments                               |
| `router`       | TP-Link AX6600            | VLAN routing + DHCP + DNS relay                        |
| `switch`       | Tenda TEG208E             | VLAN trunking and backbone switching                   |

---

## 🔁 Service Assignment Strategy

### ✅ Hosted Natively on `dietbox`
- **Netdata**: System metrics (via DietPi-Software)
- **Grafana**: Performance dashboards  
- **Mosquitto**: MQTT broker  
- **Uptime Kuma (optionally)**: Node health checks  
- **Ansible CLI**: Playbook runner if needed  
- **Other DietPi-optimized services**: Future expansion ready

### 🐳 Docker-Based Apps on `dietbox`
- **NGINX Proxy Manager**: Reverse proxy and SSL manager  
- **Homarr Dashboard**: Central tile interface  
- **Optional containers**: Node-RED, Kuma (if kept in container form)

### 🖥️ GUI / Client Tools on `minibox` & Others
- Plex client access  
- Home Assistant UI interaction  
- ChromeOS browsing + media playback  
- Local configuration tools

---

## 🌐 Reverse Proxy Map (via NGINX on `dietbox`)

| Public URL               | Internal Host         | Description                       |
|--------------------------|------------------------|-----------------------------------|
| `https://plex.home`      | `nas:32400`            | Plex media server                 |
| `https://assist.home`    | `nas:8123`             | Home Assistant UI                 |
| `https://dockge.home`    | `raspi5:5001`          | Docker UI                         |
| `https://kuma.home`      | `raspi5:3001` or `dietbox` | Status monitoring            |
| `https://dashboard.home` | `dietbox:7575`         | Homarr dashboard                  |
| `http://dns.home/admin`  | `raspi3:80`            | Pi-hole DNS admin                 |

---

## 🔋 Summary of Roles

| Node        | Role Description                                 |
|-------------|--------------------------------------------------|
| `dietbox`   | Centralized service host: proxy, dashboards, MQTT, monitoring  
| `minibox`   | GUI desktop for user-facing apps and interaction |
| `raspi5`    | Lightweight container management, broker duties  |
| `nas`       | Plex and automation heavy lifting                |
| `raspi3`    | DNS backbone with Pi-hole + Unbound              |
| `chromebooks`| GUI media clients                               |
| `googletv`  | Direct Plex streaming target                     |
| `smarttv`   | Secondary client                                 |
| `printer`   | Networked for direct discovery                   |

---

You’ve now got a topology that respects performance, service types, and role clarity. If you'd like to visualize this into a live diagram, prep YAML for native vs container comparisons, or stage install scripts for DietPi-native services, I’m on deck.
