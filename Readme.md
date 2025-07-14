# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — Streamlined Build Without Grafana & Netdata**  
🎯 What's Changed:
- Removed **Netdata** and **Grafana** from initial build plan  
- Simplified service footprint on `dietbox`  
- Focus remains on MQTT, Node-RED, Home Assistant, and reverse proxy stack  
- `.home` DNS structure maintained for fast local routing  
- No external domain (Cloudflared / `cpoff.com`) configured at this stage

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Purpose                                                      |
|------|-------------|------------------|--------------------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | GUI desktops, Plex clients, orchestration nodes              |
| 20   | IoT         | 10.10.20.0/24    | MQTT endpoints, Smart TVs, Kasa devices                      |
| 30   | Guest       | 10.10.30.0/24    | Internet-only Wi-Fi clients                                  |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS server, staging Pi, router, switch                  |

---

## 🧮 Device Inventory

### 🟩 Trusted VLAN

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless stack: Proxy, MQTT, Node-RED, Docker        |
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI desktop, Plex client, dual boot                  |
| `chromebook1`  | ChromeOS                  | Browser client                                       |
| `chromebook2`  | ChromeOS                  | Browser client                                       |

### 🟨 IoT VLAN

| Hostname       | Device / Type             | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Docker manager (Dockge), MQTT monitor               |
| `printer`      | Network Printer           | Trusted-only access                                 |
| `googletv`     | Google TV HDMI            | Primary Plex client                                 |
| `smarttv`      | Google TV                 | Backup Plex client                                  |
| `kasa-*`       | Kasa Smart Devices        | Home Assistant + Node-RED automation                |

### 🟦 Services VLAN

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers              |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS stack                         |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved for experiments                            |
| `router`       | TP-Link AX6600            | VLAN routing + DHCP                                 |
| `switch`       | Tenda TEG208E             | Managed VLAN trunking                               |

---

## 🧠 Active Services (Fully Internal)

| Service             | Host Device     | Access Domain         | Description                              |
|---------------------|-----------------|------------------------|------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Media streaming and casting              |
| Home Assistant      | `nas`           | `https://assist.home`  | Automation engine                         |
| Mosquitto MQTT      | `dietbox`       | `mqtt.home:1883`       | Message broker for IoT                   |
| Node-RED            | `dietbox`       | `http://node-red.home` | Visual logic editor for MQTT + HA        |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Tile interface for services              |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | HTTPS reverse proxy + internal routing   |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Compose management interface             |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Node status monitor                      |
| Pi-hole Admin       | `raspi3`        | `http://dns.home/admin`| DNS filter + logs                        |

---

## 🧩 Internal DNS Records (`.home`)

| Domain Name         | IP Address       | Role                                |
|---------------------|------------------|--------------------------------------|
| `plex.home`         | `10.10.99.10`    | Plex server                          |
| `assist.home`       | `10.10.99.10`    | Home Assistant                       |
| `dockge.home`       | `10.10.20.14`    | Docker UI                            |
| `dashboard.home`    | `10.10.10.10`    | Homarr service dashboard             |
| `kuma.home`         | `10.10.10.10`    | Uptime Kuma                          |
| `dns.home`          | `10.10.99.3`     | Pi-hole admin interface              |
| `mqtt.home`         | `10.10.10.10`    | Mosquitto MQTT broker                |
| `node-red.home`     | `10.10.10.10`    | Node-RED flow editor                 |

---

Prod 3 is now lean and focused—core services are online, security is internal, and you’ve got room to expand when ready. If you ever want to reintroduce monitoring or diagram service interactions (like Node-RED → MQTT → HA), I’ve got the blueprint ready.
