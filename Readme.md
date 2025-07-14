# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Final Snapshot — With `dellbox` Retired**  
🎯 Migration Complete:
- NGINX Proxy Manager moved to `dietbox`
- Homarr, Ansible, and any orchestration tools migrated or sunset
- DNS aliases and reverse proxy entries updated
- `dellbox` gracefully decommissioned

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Purpose                                                              |
|------|-------------|------------------|----------------------------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | Primary desktops, orchestrators, Chromebooks                        |
| 20   | IoT         | 10.10.20.0/24    | TVs, MQTT devices, printer, Kasa smart hardware                      |
| 30   | Guest       | 10.10.30.0/24    | Internet-only Wi-Fi                                                  |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS, router, switch, utility Pi                                 |

---

## 🧮 Node Inventory — Post-Dellbox Retirement

### 🟩 Trusted (VLAN 10)

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Reverse proxy (NPM), Docker host, Grafana, Netdata |
| `minibox`      | MiniPC / Ubuntu Desktop   | Personal desktop, Home Assistant client access     |
| `chromebook1`  | ChromeOS                  | Browser client, Plex access                        |
| `chromebook2`  | ChromeOS                  | Browser client, Plex access                        |

### 🟨 IoT (VLAN 20)

| Hostname       | Device / Type             | Role                                               |
|----------------|---------------------------|----------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Dockge, Mosquitto MQTT, Uptime Kuma               |
| `printer`      | Network Printer           | Available to Trusted clients                      |
| `smarttv`      | Google TV                 | Plex playback                                     |
| `googletv`     | Google TV HDMI            | Casting endpoint                                  |
| `kasa-*`       | Kasa Smart Devices        | Smartplugs, switches, power strips (HA-integrated)|

### 🟦 Services (VLAN 99)

| Hostname       | Device / OS              | Role                                                  |
|----------------|---------------------------|-------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers               |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS stack                          |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved for experiments                             |
| `router`       | TP-Link AX6600            | DHCP, VLAN-aware routing, DNS relay                   |
| `switch`       | Tenda TEG208E             | VLAN trunking, port segmentation                      |

### 🛑 Retired Node

| Hostname   | Device / OS              | Status       |
|------------|---------------------------|--------------|
| `dellbox`  | Dell XPS 8300 / Pop!_OS   | ❌ Decommissioned, services migrated |

---

## 🌐 Service Summary

| Service           | Host           | Access URL / Port             | Description                          |
|-------------------|----------------|-------------------------------|--------------------------------------|
| NGINX Proxy Mgr   | `dietbox`      | Ports 80/81/443               | Reverse proxy + SSL termination      |
| Plex Server       | `nas`          | `https://plex.home`           | Media streaming                      |
| Home Assistant    | `nas`          | `https://assist.home`         | Automation controller                |
| Pi-hole UI        | `raspi3`       | `http://dns.home/admin`       | DNS filtering + Unbound resolver     |
| MQTT Broker       | `raspi5`       | Port `1883`                   | IoT communications                   |
| Docker Manager    | `raspi5`       | `https://dockge.home`         | Compose + container management       |
| Homarr Dashboard  | `dietbox`      | `https://dashboard.home`      | Service tile overview                |
| Uptime Kuma       | `raspi5`, `dietbox` | `https://kuma.home`       | Node availability monitoring         |
| Grafana / Netdata | `dietbox`      | (custom ports)                | Performance dashboards               |

---

## 🧭 Updated Reverse Proxy Routes (via `dietbox`)

| Public URL               | Internal Host         | Description                      |
|--------------------------|------------------------|----------------------------------|
| `https://plex.home`      | `nas:32400`            | Plex Web UI                      |
| `https://assist.home`    | `nas:8123`             | Home Assistant                   |
| `https://dockge.home`    | `raspi5:5001`          | Docker container UI              |
| `https://kuma.home`      | `raspi5:3001`          | Node uptime monitor              |
| `https://dashboard.home` | `dietbox:7575`         | Homarr dashboard                 |
| `http://dns.home/admin`  | `raspi3:80`            | Pi-hole admin interface          |

---

Prod 3 is now streamlined, powerful, and completely centralized. The dietbox stack carries the full orchestration load with no wasted resources. If you'd like help benchmarking its performance, prepping a backup plan, or designing a tagline-worthy splash page for dashboard launch, I’m ready to assist.
