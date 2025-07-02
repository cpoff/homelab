# 🤖 SkyNet – Full Topology & Infrastructure Map

This is the fully updated **Prod 2** version of **SkyNet**, capturing:

- VLAN-aware segmentation across trusted, service, IoT, and guest zones
- Accurate OS and hostname mapping across all Raspi nodes
- Personal devices (Chromebooks) integrated on VLAN 20
- Home Assistant and phone-based control over Kasa smart plugs (IoT)
- 🔐 UFW firewall rules with full inline commentary
- Clean reverse proxy and `.home` DNS with TLS termination

---

## 🧠 Node Directory & Host Assignments

| Hostname       | DNS Name            | IP Address     | OS / Type            | Role & Key Services                                           |
|----------------|---------------------|----------------|----------------------|----------------------------------------------------------------|
| `popbox`       | `popbox.home`       | 10.10.10.10    | Pop!_OS              | Admin core: NGINX Proxy, dnsmasq, Homarr                       |
| `raspi5`       | `raspi5.home`       | 10.10.20.14    | Raspberry Pi OS      | Dockge, Uptime Kuma, Mosquitto                                 |
| `raspi3`       | `raspi3.home`       | 10.10.30.53    | DietPi               | Pi-hole + Unbound DNS                                          |
| `raspi4`       | `raspi4.home`       | 10.10.30.11    | DietPi               | AdGuard Home, Zigbee2MQTT, Prometheus, NodeRED                |
| `nas`          | `nas.home`          | 10.10.20.10    | Synology DSM         | Plex, Home Assistant, Dockge                                   |
|                | `assist.home`       | —              | DNS Alias            | HA UI (via `nas.home:8123`)                                    |
|                | `plex.home`         | —              | DNS Alias            | Plex Web UI (`nas.home:32400`)                                 |
|                | `dockge-nas.home`   | —              | DNS Alias            | NAS Docker UI (port 5002)                                      |
| `printer`      | `printer.home`      | 10.10.20.21    | Network Printer       | LAN printing, optional web UI                                  |
| `smarttv`      | `smarttv.home`      | 10.10.20.30    | Google TV             | Media playback and casting                                     |
| `googletv`     | `googletv.home`     | 10.10.20.31    | Google TV HDMI        | Primary streaming device                                       |
| `chromebook1`  | `cb1.home`          | 10.10.20.41    | ChromeOS              | Personal laptop #1                                             |
| `chromebook2`  | `cb2.home`          | 10.10.20.42    | ChromeOS              | Personal laptop #2                                             |
| `router`       | `router.home`       | 10.10.99.2     | TP-Link AX6600        | SSID bridge + tagged uplink                                    |
| `switch`       | `switch.home`       | 10.10.99.1     | Tenda TEG208E         | Core VLAN switch                                               |

---

## 🧩 VLAN Schema

| VLAN | Name        | Subnet           | Purpose                                              |
|------|-------------|------------------|-------------------------------------------------------|
| 10   | Admin       | 10.10.10.0/24    | Orchestration + workstations                         |
| 20   | Services    | 10.10.20.0/24    | NAS, Dockge, Plex, personal clients, mobile          |
| 30   | IoT         | 10.10.30.0/24    | Smart plugs, Zigbee, DNS relay nodes                 |
| 40   | Guest       | 10.10.40.0/24    | Isolated client Wi-Fi                                |
| 99   | Management  | 10.10.99.0/24    | Switch and router interfaces                         |

---

## 📶 Wi-Fi SSID → VLAN Mapping

| SSID         | VLAN | Band   | Devices Served                                 |
|--------------|------|--------|------------------------------------------------|
| `Homers`     | 10   | 5GHz   | Work laptops, orchestration                    |
| `Spicy Mac`  | 20   | 5GHz   | Phones, Chromebooks, Plex clients, Dockge UI   |
| `Smarties`   | 30   | 2.4GHz | Smart plugs, sensors, ESP/Zigbee devices       |

---

## 🔌 TEG208E Switch Port Map

| Port | Connected Devices / Switches           | VLAN | Tagging  |
|------|----------------------------------------|------|----------|
| 1    | Pop box + work laptop switch (trusted) | 10   | Untagged |
| 2    | `raspi5`                               | 20   | Untagged |
| 3    | `nas`                                  | 20   | Untagged |
| 4    | `raspi3`                               | 30   | Untagged |
| 5    | `raspi4`                               | 30   | Untagged |
| 6    | SmartTV + GoogleTV via unmanaged switch| 20   | Untagged |
| 7    | Printer                                 | 20   | Untagged |
| 8    | Uplink to AX6600 router                | All  | Tagged   |

---

## 🔐 NGINX Proxy Routes (`popbox.home`)

| URL                        | Destination Target      | Description                                |
|----------------------------|--------------------------|---------------------------------------------|
| `https://dashboard.home`   | `popbox:7575`            | Homarr UI                                   |
| `https://assist.home`      | `nas:8123`               | Home Assistant                              |
| `https://plex.home`        | `nas:32400`              | Plex                                         |
| `https://dockge.home`      | `raspi5:5001`            | Dockge (raspi5)                             |
| `https://dockge-nas.home`  | `nas:5002`               | Dockge (NAS)                                |
| `https://raspi3.home`      | `raspi3`                 | Pi-hole Admin                               |
| `https://raspi4.home`      | `raspi4:8053`            | AdGuard Home UI                             |
| `https://printer.home`     | `printer`                | Printer web admin (if available)            |

---

## 🛡️ UFW Rules (Sample – with Full Commentary)

### 🔹 `raspi5.home` (VLAN 20 – Dockge, Kuma)
```bash
sudo ufw default deny incoming                       # Block all incoming by default
sudo ufw default allow outgoing                      # Allow all outbound traffic

sudo ufw allow ssh                                   # Allow SSH admin access
sudo ufw allow 5001/tcp                              # Dockge web UI
sudo ufw allow 3001/tcp                              # Uptime Kuma HTTP UI
sudo ufw allow from 10.10.10.10 to any port 5001,3001  # Allow access from Admin node (Popbox)
```

### 🔹 `raspi3.home` (VLAN 30 – DNS)
```bash
sudo ufw default deny incoming
sudo ufw allow ssh                                   # Remote terminal
sudo ufw allow 53                                   # DNS over TCP/UDP
sudo ufw allow 80                                   # Pi-hole Admin UI
sudo ufw allow from 10.10.10.0/24                   # Admin VLAN access
sudo ufw allow from 10.10.20.0/24                   # Services VLAN (HA, phones, TVs)
```

> All other devices follow the same pattern: open minimal inbound services + allow required inter-VLAN access with clear commentary.

---

## 📲 Home Assistant + Mobile ↔ IoT Pathways

| Source            | Target (VLAN 30)   | Allowed Ports (TCP/UDP)      | Purpose                       |
|-------------------|--------------------|-------------------------------|-------------------------------|
| `nas.home` (HA)   | Kasa plugs / IoT   | 9999, 80, 443, 554, 5353      | Smart plug control + discovery|
| Mobile Phone (Wi-Fi) | Kasa IoT         | Same                          | Kasa App control              |

Recommended: Avahi or mDNS bridge container (optional) for device discovery across VLANs.

---

SkyNet Prod 2 is active, segmented, secure, and orchestrated with surgical clarity. Let me know if you’d like this exported as a `.md` file, visual diagram, or integration with Homarr.

