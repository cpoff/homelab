# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — Streamlined & Updated**  
🆕 Updates Included:
- Renamed environment to Prod 3  
- DNS stack migrated to Pi-hole + Unbound (`raspi3`)  
- Printer reclassified: available to Trusted devices, no dashboard or reverse proxy entry

---

## 🧮 Device Inventory – by VLAN and Role

### 🟩 **Trusted VLAN (10.10.10.0/24)**

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `dellbox`      | Dell XPS 8300 / Pop!_OS   | Admin orchestrator: `dnsmasq`, NGINX, Homarr, Ansible |
| `dietbox`      | HP EliteDesk / DietPi     | Headless Docker production node (Grafana, Netdata)  |
| `minibox`      | MiniPC / Ubuntu Desktop   | Personal GUI desktop: browsing, Plex client         |
| `chromebook1`  | ChromeOS                  | Personal client, Plex access                        |
| `chromebook2`  | ChromeOS                  | Personal client, Plex access                        |

---

### 🟨 **IoT VLAN (10.10.20.0/24)**

| Hostname       | Device / Type             | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Dockge, Uptime Kuma, Mosquitto MQTT                 |
| `printer`      | Network Printer           | Available to Trusted clients, no overmanagement     |
| `smarttv`      | Google TV                 | Plex playback                                       |
| `googletv`     | Google TV HDMI            | Casting endpoint                                    |
| `kasa-*`       | Kasa Smart Devices        | Smartplugs, switches, power strips (via HA)         |

---

### 🟦 **Services VLAN (10.10.99.0/24)**

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers              |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS server                         |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved for experiments and staging                 |
| `router`       | TP-Link AX6600            | DHCP, VLAN routing, DNS relay                        |
| `switch`       | Tenda TEG208E             | VLAN trunking, port segmentation                     |

---

### 🛑 **Guest VLAN (10.10.30.0/24)**

| Client Type    | Behavior                              |
|----------------|----------------------------------------|
| Wi-Fi guests   | Throttled internet access, no LAN reach|

---

## 🔁 Services Overview – by Host

| Service           | Hosted On     | Port / URL                | Description                       |
|-------------------|---------------|----------------------------|-----------------------------------|
| Plex              | `nas`         | `https://plex.home`       | Media server                      |
| Home Assistant    | `nas`         | `https://assist.home`     | Automation hub                    |
| MQTT Broker       | `raspi5`      | `:1883`                   | IoT message broker                |
| Pi-hole + Unbound | `raspi3`      | `http://dns.home/admin`   | DNS resolution + filtering        |
| Docker Manager    | `raspi5`      | `https://dockge.home`     | Container interface               |
| Homarr Dashboard  | `dellbox`     | `https://dashboard.home`  | Central access tile system        |
| Uptime Kuma       | `raspi5`, `dietbox` | `https://kuma.home` | Node uptime and status monitor   |
| Grafana / Netdata | `dietbox`     | Custom ports               | Metrics and system monitoring     |

---

## 🌐 Reverse Proxy (NGINX on `dellbox`)

| Public URL                | Internal Destination       | Description                  |
|---------------------------|----------------------------|------------------------------|
| `https://plex.home`       | `nas:32400`                | Plex web interface           |
| `https://assist.home`     | `nas:8123`                 | Home Assistant               |
| `https://dockge.home`     | `raspi5:5001`              | Docker management            |
| `https://kuma.home`       | `raspi5:3001`              | Status monitoring            |
| `https://dashboard.home`  | `dellbox:7575`             | Homarr dashboard             |
| `http://dns.home/admin`   | `raspi3:80`                | Pi-hole UI                   |

---

This version of **Prod 3** is leaner and sharper, with a streamlined role for your printer and accurate tracking of critical services. Let me know if you want me to prep a diagram, a firewall matrix, or future expansion templates.

