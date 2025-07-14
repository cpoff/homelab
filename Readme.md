# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot – Streamlined, Secure, and Fully Internal**  
🎯 Focused on fast local routing, fully private `.home` DNS records, and centralized headless services

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Purpose                                                      |
|------|-------------|------------------|--------------------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | GUI desktops, Plex clients, orchestration nodes              |
| 20   | IoT         | 10.10.20.0/24    | MQTT endpoints, Smart TVs, Kasa devices                      |
| 30   | Guest       | 10.10.30.0/24    | Internet-only Wi-Fi clients                                  |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS server, staging Pi, router, switch                  |

---

## 🧮 Device Inventory (By VLAN)

### 🟩 Trusted VLAN — GUI & Clients

| Hostname       | Device / OS              | Role / Notes                                           |
|----------------|---------------------------|--------------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless host: Proxy, MQTT broker, Node-RED, Grafana   |
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI desktop, Plex client, dual boot setup              |
| `chromebook1`  | ChromeOS                  | Browser-based service access                           |
| `chromebook2`  | ChromeOS                  | Browser-based service access                           |

### 🟨 IoT VLAN — Smart & Automation Devices

| Hostname       | Device / Type             | Role                                                   |
|----------------|---------------------------|--------------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Docker manager (Dockge), MQTT monitor, Kuma mirror    |
| `printer`      | Network Printer           | Direct access from Trusted only                       |
| `googletv`     | Google TV HDMI            | **Primary Plex client** (direct-to-NAS)               |
| `smarttv`      | Google TV                 | **Backup client** for Plex                            |
| `kasa-*`       | Kasa Smart Devices        | Power automation via HA and Node-RED                  |

### 🟦 Services VLAN — Infrastructure Backbone

| Hostname       | Device / OS              | Role                                                   |
|----------------|---------------------------|--------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers                |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS resolver                        |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved node / experiments                           |
| `router`       | TP-Link AX6600            | DHCP, VLAN routing, DNS relay                         |
| `switch`       | Tenda TEG208E             | Managed VLAN trunking                                 |

---

## 🧩 Service Summary (Internal Access Only)

| Service             | Host Device     | Access Domain         | Notes                                      |
|---------------------|-----------------|------------------------|--------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Local streaming via Google TV              |
| Home Assistant      | `nas`           | `https://assist.home`  | Automation engine                          |
| Mosquitto MQTT      | `dietbox`       | `mqtt.home:1883`       | Broker for Kasa / Node-RED topics          |
| Node-RED            | `dietbox`       | `http://node-red.home` | Visual automation flow editor              |
| Grafana / Netdata   | `dietbox`       | Custom ports           | Monitoring dashboards                      |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Service overview tile system              |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | Reverse proxy + SSL management             |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Container composition + monitoring         |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Node monitoring and uptime logs            |
| Pi-hole Admin       | `raspi3`        | `http://dns.home/admin`| DNS dashboard and filtering                |

---

## 🧠 Internal DNS `.home` Records

| Hostname / Domain     | IP Address       | Notes                                  |
|-----------------------|------------------|----------------------------------------|
| `plex.home`           | `10.10.99.10`    | Plex server                            |
| `assist.home`         | `10.10.99.10`    | Home Assistant                         |
| `dockge.home`         | `10.10.20.14`    | Docker manager                         |
| `dashboard.home`      | `10.10.10.10`    | Homarr UI                              |
| `kuma.home`           | `10.10.10.10`    | Uptime Kuma                            |
| `mqtt.home`           | `10.10.10.10`    | Mosquitto broker                       |
| `node-red.home`       | `10.10.10.10`    | Node-RED flow editor                   |
| `dns.home`            | `10.10.99.3`     | Pi-hole dashboard                      |

> DNS entries should be registered via Pi-hole → Local DNS → Custom Records or through your `dnsmasq` override.

---

Prod 3 is now dialed in: headless logic lives on `dietbox`, clients route internally with lightning speed, and `.home` DNS makes it all legible. If you'd like to generate visual diagrams, YAML snapshots, or monitor DNS performance stats over time, I’m here for it.
