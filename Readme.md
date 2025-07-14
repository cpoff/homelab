# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — Corrected Roles, Hostnames, and Hardware Assignments**  
🎯 Summary of Fixes:
- ✅ `raspi5` = **Raspberry Pi 5** → hosts MQTT, Dockge, optional Kuma  
- ✅ `raspi4` = **Raspberry Pi 4** → Pi-hole + Unbound, wired off router  
- ✅ `raspi3` = **Raspberry Pi 3** → moved to experimental bench  
- ✅ Internal DNS records updated  
- ❌ Grafana and Netdata removed from base deployment  
- 🔒 All services remain local; no Cloudflared or public domains active

---

## 🔐 VLAN Assignment Overview

| VLAN | Label       | Subnet           | Purpose                                                    |
|------|-------------|------------------|------------------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | GUI desktops, Plex clients, orchestration nodes            |
| 20   | IoT         | 10.10.20.0/24    | MQTT endpoints, Smart TVs, Kasa devices                    |
| 30   | Guest       | 10.10.30.0/24    | Internet-only Wi-Fi clients                                |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS resolver (`raspi4`), router, switch, staging Pi   |

---

## 🧮 Device Inventory (By VLAN)

### 🟩 Trusted VLAN — GUI & Headless Nodes

| Hostname       | Device / OS              | Role                                                    |
|----------------|---------------------------|---------------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless orchestration: NGINX Proxy, Node-RED, Kuma, Docker |
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI workstation, Plex client, HA front-end              |
| `chromebook1`  | ChromeOS                  | Plex & dashboard client                                 |
| `chromebook2`  | ChromeOS                  | Plex & dashboard client                                 |

---

### 🟨 IoT VLAN — Smart & Messaging Devices

| Hostname       | Device / Hardware         | Role                                                      |
|----------------|---------------------------|-----------------------------------------------------------|
| `raspi5`       | **Raspberry Pi 5**        | Mosquitto MQTT Broker, Dockge UI, optional Uptime Kuma    |
| `printer`      | Network Printer           | Trusted-only access                                       |
| `googletv`     | Google TV HDMI            | Primary Plex endpoint                                     |
| `smarttv`      | Google TV OS              | Backup Plex endpoint                                      |
| `kasa-*`       | Kasa Smart Hardware       | Switches, plugs, strips — integrated via HA + Node-RED    |

---

### 🟦 Services VLAN — Infrastructure Backbone

| Hostname       | Device / Hardware         | Role                                                      |
|----------------|---------------------------|-----------------------------------------------------------|
| `raspi4`       | **Raspberry Pi 4**        | Pi-hole + Unbound DNS Resolver, directly wired to router |
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers                   |
| `router`       | TP-Link AX6600            | VLAN routing, DHCP, DNS relay                             |
| `switch`       | Tenda TEG208E             | VLAN trunking, backbone switching                         |
| `raspi3`       | Raspberry Pi 3            | Experimental bench — no active production services        |

---

## 🧩 Core Services Summary

| Service             | Host Device     | Access Domain         | Purpose                                   |
|---------------------|-----------------|------------------------|-------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Internal media streaming                  |
| Home Assistant      | `nas`           | `https://assist.home`  | Smart home automation                     |
| Mosquitto MQTT      | `raspi5`        | `mqtt.home:1883`       | Lightweight IoT messaging                 |
| Node-RED            | `dietbox`       | `http://node-red.home` | Visual logic editor for MQTT + automations |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Tile interface for service launch points  |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | Reverse proxy and SSL termination         |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Compose-based container manager           |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Node monitoring dashboard                 |
| Pi-hole Admin       | `raspi4`        | `http://dns.home/admin`| DNS filtering and internal records        |

---

## 🧠 Internal DNS — `.home` Resolution Map

| Domain Name         | IP Address       | Resolves To                           |
|---------------------|------------------|----------------------------------------|
| `plex.home`         | `10.10.99.10`    | `nas`                                  |
| `assist.home`       | `10.10.99.10`    | `nas`                                  |
| `dockge.home`       | `10.10.20.15`    | `raspi5` (Pi 5)                         |
| `dashboard.home`    | `10.10.10.10`    | `dietbox`                              |
| `kuma.home`         | `10.10.10.10`    | `dietbox`                              |
| `dns.home`          | `10.10.99.4`     | `raspi4` (Pi 4)                         |
| `mqtt.home`         | `10.10.20.15`    | `raspi5` (Pi 5)                         |
| `node-red.home`     | `10.10.10.10`    | `dietbox`                              |

> ✅ Update Pi-hole → Local DNS → Custom Records or your `dnsmasq.conf` to reflect corrected IP addresses and role shifts.

---

Prod 3 is now cleanly architected—matching hostnames to physical hardware, balancing service loads, and keeping your network agile and efficient. Ready for expansion when needed, but stable out of the gate.

Want to keep building on this with a Node-RED flow map or YAML export? The foundation couldn’t be sharper.
