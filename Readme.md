# 🧠 SkyNet — Full Topology Map  
📌 **Prod 3 Snapshot — VLAN Update + Recommissioned `dellbox`**  
🎯 Key Updates:
- ✅ VLAN 40 created for `dellbox` with Gluetun-based secure downloads  
- ✅ `raspi5` confirmed as **Raspberry Pi 5**  
- ✅ `raspi4` now DNS resolver (Pi-hole + Unbound), directly wired to router  
- ✅ `raspi3` repurposed for experimentation  
- ✅ Desk switch setup clarified: unmanaged TP-Link feeds both `dietbox` and `dellbox`  

---

## 🔐 VLAN Assignment Summary

| VLAN | Label       | Subnet           | Connected Devices                           | Purpose                                     |
|------|-------------|------------------|----------------------------------------------|---------------------------------------------|
| 10   | Trusted     | 10.10.10.0/24    | `dietbox`, `minibox`, `chromebook1/2`        | GUI desktops, orchestration nodes           |
| 20   | IoT         | 10.10.20.0/24    | `raspi5`, `printer`, `googletv`, `smarttv`, `kasa-*` | Messaging devices, Smart TVs, HA hardware   |
| 30   | Guest       | 10.10.30.0/24    | (Wi-Fi guests)                               | Internet-only clients                       |
| 40   | VPN Zone    | 10.10.40.0/24    | `dellbox`                                    | Secure, anonymous media downloads           |
| 99   | Services    | 10.10.99.0/24    | `raspi4`, `nas`, `router`, `switch`, `raspi3`| Infra backbone, DNS, storage, staging       |

---

## 🧮 Device Inventory by VLAN

### 🟩 VLAN 10 — Trusted Zone

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dietbox`      | HP EliteDesk / DietPi     | Node-RED, NGINX Proxy, Docker, Homarr, Kuma        |
| `minibox`      | MiniPC / Ubuntu + Win11   | GUI desktop, Plex client, HA frontend              |
| `chromebook1`  | ChromeOS                  | Browser-based media control                        |
| `chromebook2`  | ChromeOS                  | Browser-based media control                        |

### 🟨 VLAN 20 — IoT Zone

| Hostname       | Device / Hardware         | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `raspi5`       | Raspberry Pi 5 / RPi OS   | Mosquitto broker, Docker manager (Dockge), optional Kuma  
| `printer`      | Network Printer           | Limited to Trusted clients                         |
| `googletv`     | Google TV HDMI            | Primary Plex endpoint                              |
| `smarttv`      | Google TV OS              | Secondary Plex endpoint                            |
| `kasa-*`       | Smart plugs, switches     | Automated via Node-RED + Home Assistant            |

### 🛡️ VLAN 40 — VPN-Isolated Downloads

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `dellbox`      | Dell Desktop / Pop!_OS    | Gluetun VPN, qBittorrent, Sonarr, Radarr, FileBot, NAS mover  

> Connected via unmanaged TP-Link desk switch, VLAN tagging applied at NIC using `nmcli`.

### 🟦 VLAN 99 — Services Backbone

| Hostname       | Device / OS              | Role                                                |
|----------------|---------------------------|-----------------------------------------------------|
| `raspi4`       | Raspberry Pi 4 / DietPi   | Pi-hole + Unbound DNS Resolver, directly off router  
| `nas`          | Synology DSM              | Plex, Home Assistant, Docker containers, Volume2 media share  
| `router`       | TP-Link AX6600            | Routing, VLANs, DHCP, DNS relay                     |
| `switch`       | Tenda TEG208E             | Managed VLAN trunking                               |
| `raspi3`       | Raspberry Pi 3 / DietPi   | Experimental node — staging, trials, test scripts   |

---

## 🧩 Core Services Summary

| Service             | Host Device     | Access Domain         | Role                                            |
|---------------------|-----------------|------------------------|-------------------------------------------------|
| Plex Server         | `nas`           | `https://plex.home`    | Internal media streaming                        |
| Home Assistant      | `nas`           | `https://assist.home`  | Smart automation                                |
| Mosquitto MQTT      | `raspi5`        | `mqtt.home:1883`       | IoT messaging                                   |
| Node-RED            | `dietbox`       | `http://node-red.home` | Flow editor + automations                       |
| Homarr Dashboard    | `dietbox`       | `https://dashboard.home`| Tile-style UI for service overview             |
| NGINX Proxy Manager | `dietbox`       | Internal port `81`     | SSL handling, reverse proxy                     |
| Docker UI (Dockge)  | `raspi5`        | `https://dockge.home`  | Visual container management                     |
| Uptime Kuma         | `dietbox`       | `https://kuma.home`    | Node status and alerts                          |
| Pi-hole Admin       | `raspi4`        | `http://dns.home/admin`| DNS filtering + logging                         |
| Media Groomers      | `dellbox`       | Local containers        | Sonarr, Radarr, FileBot, all routed via Gluetun  
| NAS Volume2         | `nas`           | `/volume2/media`       | Dedicated media storage                         |

---

## 🧠 Internal DNS `.home` Records

| Domain Name         | IP Address       | Linked Host Device            |
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

Your VLANs are now segmented by intent: orchestration, IoT messaging, secure downloads, and infrastructure. Each node is doing what it does best, and the desk switch layout is efficient with per-device tagging.

Want to annotate this map with links to Docker Compose files, storage mounts, or VLAN flow diagrams? This topology deserves a trophy case.
