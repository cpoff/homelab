# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — With Cloudflared Integration & HTTPS Automation**  
🎯 Latest Enhancements:
- Public domain `cpoff.com` now active across the stack  
- Internal services securely exposed via **Cloudflared Tunnel**  
- HTTPS automated via **NGINX Proxy Manager + Let’s Encrypt**  
- Node-RED introduced for MQTT-driven visual automation  
- `dietbox` elevated as full orchestration host  
- `dellbox` officially retired for good

---

## 🌐 Domain + Security Architecture

| Layer                 | Function                                            |
|-----------------------|-----------------------------------------------------|
| 🔐 HTTPS Certs        | Auto-managed by NGINX Proxy Manager using Let’s Encrypt  
| ☁️ Cloudflared Tunnel | Exposes internal services (e.g. Plex, HA) via `cpoff.com` subdomains  
| 🧠 DNS Routing        | `.home` domain stays for internal LAN use, while `*.cpoff.com` serves external access  
| 🚫 Zero Trust (optional) | Add access rules for services via Cloudflare's security layer  

---

### 🔁 Example External Routes

| Public Subdomain       | Internal Host         | Purpose                      |
|------------------------|------------------------|------------------------------|
| `plex.cpoff.com`       | `nas:32400`            | External Plex access         |
| `assist.cpoff.com`     | `nas:8123`             | Home Assistant dashboard     |
| `dashboard.cpoff.com`  | `dietbox:7575`         | Homarr dashboard             |
| `dockge.cpoff.com`     | `raspi5:5001`          | Docker manager UI            |
| `kuma.cpoff.com`       | `dietbox`              | Uptime monitor               |

All SSL certs are **auto-renewed** by NGINX Proxy Manager using Let’s Encrypt.

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Purpose                                            |
|------|-------------|------------------|----------------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | GUI desktops and orchestration clients             |
| 20   | IoT         | 10.10.20.0/24    | Smart hardware, Kasa devices, MQTT endpoints       |
| 30   | Guest       | 10.10.30.0/24    | Internet-only Wi-Fi                                |
| 99   | Services    | 10.10.99.0/24    | NAS, DNS, router, switch, utility Pi nodes         |

---

## 🧮 Full Device Inventory

### 🟩 Trusted VLAN – GUI Clients

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Headless service node: Proxy, MQTT, Node-RED, Grafana, Netdata  
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI desktop: Plex client, HA interaction            |
| `chromebook1`  | ChromeOS                  | Browser-based services                              |
| `chromebook2`  | ChromeOS                  | Browser-based services                              |

### 🟨 IoT VLAN – Smart Devices

| Hostname       | Device / Type             | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `raspi5`       | Raspberry Pi 4 / RPi OS   | Docker manager (Dockge), MQTT monitor, Kuma mirror  |
| `printer`      | Network Printer           | Trusted VLAN only access, direct discovery          |
| `googletv`     | Google TV HDMI            | **Primary Plex playback endpoint**                  |
| `smarttv`      | Google TV                 | Backup Plex client                                  |
| `kasa-*`       | Kasa Smart Devices        | Home Assistant + Node-RED automated switching       |

### 🟦 Services VLAN – Core Infrastructure

| Hostname       | Device / OS              | Role                                                 |
|----------------|---------------------------|------------------------------------------------------|
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers              |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Pi-hole + Unbound DNS stack                         |
| `raspi4`       | Raspberry Pi 4 / RPi OS   | Reserved node / staging                             |
| `router`       | TP-Link AX6600            | VLAN routing + DHCP                                 |
| `switch`       | Tenda TEG208E             | Managed VLAN trunking                               |

---

## 🧩 Service Summary (With External Mapping via `cpoff.com`)

| Service             | Internal Host  | External Access           | Role Description                      |
|---------------------|----------------|----------------------------|----------------------------------------|
| Plex                | `nas:32400`    | `plex.cpoff.com`          | Streaming + casting                    |
| Home Assistant      | `nas:8123`     | `assist.cpoff.com`        | Automation engine                      |
| Node-RED            | `dietbox:1880` | Optional / internal only  | Visual flow editor for MQTT            |
| Mosquitto MQTT      | `dietbox:1883` | Internal only             | IoT message broker                     |
| Grafana / Netdata   | `dietbox`      | Internal only             | Monitoring dashboards                  |
| NGINX Proxy Manager | `dietbox`      | Port `81` (internal only) | SSL routing + service aliasing         |
| Homarr Dashboard    | `dietbox:7575` | `dashboard.cpoff.com`     | Central service overview               |
| Docker UI (Dockge)  | `raspi5:5001`  | `dockge.cpoff.com`        | Compose and container manager          |
| Uptime Kuma         | `dietbox`      | `kuma.cpoff.com`          | Node status + alerts                   |
| DNS Admin           | `raspi3:80`    | `http://dns.home/admin`   | Internal DNS control                   |

---

## 🧠 Node-RED Integration Highlights

- Subscribes to **Mosquitto topics** like `/kasa/power/desk`  
- Publishes control logic: timed switches, multi-device triggers  
- Connects directly to Home Assistant for feedback or sensor data  
- Enables dashboard UIs for live monitoring, toggles, or scene control

Optional flows:  
- “If power draw on `kasa-avrack` exceeds threshold → trigger cooling fan”  
- “If motion after 10PM → turn on porch lights + notify HA”  

---

## 📌 HTTPS Enforcement Summary

| Mechanism              | Location            | Description                                  |
|------------------------|---------------------|----------------------------------------------|
| Let’s Encrypt Certs    | `dietbox:NPM`       | Automated per subdomain via Proxy Manager    |
| HTTP → HTTPS Redirects | NGINX Proxy Manager | Force HTTPS on all public routes             |
| Cloudflare SSL Setting | Cloudflare DNS      | Set to **Full (Strict)**                     |
| Cert Renewal           | Automatic           | 90-day rotation via NPM + Let’s Encrypt      |

---

Prod 3 is now securely bridged between internal VLAN logic and public access via `cpoff.com`, with SSL and tunnels running clean and smooth. You've got visual automation, private DNS, performance dashboards, and airtight access all humming together.

Ready to script a Zero Trust access rule, publish a Node-RED dashboard to Cloudflare, or create a splash screen for `missioncontrol.cpoff.com`?
