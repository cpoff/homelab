# 🤖 SkyNet – Full Topology & Infrastructure Map

This is the comprehensive **Prod 2** map of **SkyNet**, now fully incorporating:

- Finalized hostnames, VLANs, OS mappings, and physical layout
- UFW firewall rule coverage with inline commentary for all applicable nodes
- Secure inter-VLAN rules for Home Assistant + Kasa IoT control
- Personal devices integrated cleanly into the Services zone
- Reverse proxy endpoints, DNS mappings, and broadcast domain designations

---

## 🧠 Node Directory & DNS

| Hostname       | DNS Name            | IP Address     | OS / Type          | Role & Services                                          |
|----------------|---------------------|----------------|---------------------|-----------------------------------------------------------|
| `popbox`       | `popbox.home`       | 10.10.10.10    | Pop!_OS             | Admin orchestrator: NGINX Proxy, dnsmasq, Homarr          |
| `raspi5`       | `raspi5.home`       | 10.10.20.14    | Raspberry Pi OS     | Dockge, Uptime Kuma, Mosquitto                            |
| `raspi3`       | `raspi3.home`       | 10.10.30.53    | DietPi              | Pi-hole + Unbound DNS                                     |
| `raspi4`       | `raspi4.home`       | 10.10.30.11    | DietPi              | AdGuard Home, NodeRED, Zigbee2MQTT, Prometheus            |
| `nas`          | `nas.home`          | 10.10.20.10    | Synology DSM        | Plex, Home Assistant, Dockge (with Synology Firewall)     |
| `printer`      | `printer.home`      | 10.10.20.21    | HW Device           | Wired printer, driverless + web UI                        |
| `smarttv`      | `smarttv.home`      | 10.10.20.30    | Google TV           | Streaming Plex, Chromecast                                |
| `googletv`     | `googletv.home`     | 10.10.20.31    | Google TV HDMI      | Streaming HDMI stick                                      |
| `chromebook1`  | `cb1.home`          | 10.10.20.41    | ChromeOS            | Personal laptop 1                                         |
| `chromebook2`  | `cb2.home`          | 10.10.20.42    | ChromeOS            | Personal laptop 2                                         |
| `router`       | `router.home`       | 10.10.99.2     | TP-Link AX6600      | Wi-Fi AP + uplink trunk                                   |
| `switch`       | `switch.home`       | 10.10.99.1     | Tenda TEG208E       | Core switch with port-based VLAN segmentation             |

---

## 🧩 VLANs & Subnet Purpose

| VLAN | Name      | Subnet           | Purpose                                             |
|------|-----------|------------------|------------------------------------------------------|
| 10   | Admin     | 10.10.10.0/24    | Trusted orchestration + work machines               |
| 20   | Services  | 10.10.20.0/24    | NAS, Plex, TVs, Chromebooks, Home Assistant         |
| 30   | IoT       | 10.10.30.0/24    | Kasa plugs, Zigbee bridges, DNS relays              |
| 40   | Guest     | 10.10.40.0/24    | Internet-only Wi-Fi                                 |
| 99   | Mgmt      | 10.10.99.0/24    | Static access to router/switch                      |

---

## 📶 SSID-to-VLAN Mapping

| SSID         | VLAN | Band   | Devices Served                               |
|--------------|------|--------|----------------------------------------------|
| `Homers`     | 10   | 5GHz   | Pop box, work laptops                        |
| `Spicy Mac`  | 20   | 5GHz   | Phones, Chromebooks, streaming clients       |
| `Smarties`   | 30   | 2.4GHz | Smart plugs, Zigbee devices                  |

---

## 🔌 Switch Port Map (Tenda TEG208E)

| Port | Connected Device(s)                  | VLAN | Tag Mode  |
|------|---------------------------------------|------|-----------|
| 1    | Trusted switch (Pop box + work PCs)  | 10   | Untagged  |
| 2    | `raspi5`                             | 20   | Untagged  |
| 3    | `nas`                                | 20   | Untagged  |
| 4    | `raspi3`                             | 30   | Untagged  |
| 5    | `raspi4`                             | 30   | Untagged  |
| 6    | TV switch (SmartTV, GoogleTV)        | 20   | Untagged  |
| 7    | Printer                               | 20   | Untagged  |
| 8    | Router uplink                         | All  | Tagged    |

---

## 🔐 Reverse Proxy Services (`popbox` / NGINX Proxy Manager)

| URL                        | Backend Target          | Description                                |
|----------------------------|--------------------------|---------------------------------------------|
| `https://assist.home`      | `nas.home:8123`          | Home Assistant UI                          |
| `https://plex.home`        | `nas.home:32400`         | Plex Web & Cast                            |
| `https://dockge.home`      | `raspi5.home:5001`       | Dockge for `raspi5` containers             |
| `https://dockge-nas.home`  | `nas.home:5002`          | Dockge for `nas.home`                      |
| `https://kuma.home`        | `raspi5.home:3001`       | Uptime Kuma                                |
| `https://raspi3.home`      | `raspi3.home`            | Pi-hole UI                                 |
| `https://raspi4.home`      | `raspi4.home:8053`       | AdGuard Home                               |
| `https://printer.home`     | `printer.home`           | Printer Web UI (if supported)              |

---

## 🧭 DNS Architecture

- Authoritative zone: `.home` served via `dnsmasq` on `popbox`
- Recursive filtered resolution:
  - 🟢 Primary: `raspi3.home` (Pi-hole + Unbound)
  - 🔵 Secondary: `raspi4.home` (AdGuard Home)
- Static DNS entries and DHCP managed via Ansible
- VPN-friendly: Split-DNS adaptable for remote access

---

## 🔄 IoT Control Pathways

| Access Source    | Destination (IoT Devices – VLAN 30) | Ports / Protocols               | Purpose                          |
|------------------|--------------------------------------|----------------------------------|----------------------------------|
| Home Assistant    | Kasa plugs, Zigbee relays           | TCP/UDP 9999, 80, 443, 554       | Smart plug control               |
| Mobile devices    | Kasa plugs                          | TCP/UDP 9999                     | App-based smart plug control     |
| mDNS bridging (optional) | IoT devices across VLANs     | 5353 (UDP), multicast            | Discovery support                |

---

## 🛡️ UFW Rules per Device (Annotated)

### 🔹 `popbox.home` (Admin – VLAN 10)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                             # Secure shell for admin login
sudo ufw allow 80,443/tcp                      # NGINX for HTTPS proxy
sudo ufw allow 7575/tcp                        # Homarr dashboard
sudo ufw allow from 10.10.20.0/24 to any port 443  # Allow proxy access from VLAN 20 clients
```

---

### 🔹 `raspi5.home` (Services – VLAN 20)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                             # Remote access
sudo ufw allow 5001/tcp                        # Dockge UI
sudo ufw allow 3001/tcp                        # Uptime Kuma
sudo ufw allow 1883/tcp                        # Mosquitto MQTT
sudo ufw allow from 10.10.10.0/24 to any port 5001,3001  # Admin access from `popbox`
```

---

### 🔹 `raspi3.home` (DNS Filter – VLAN 30)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                             # Admin access
sudo ufw allow 53/tcp                          # DNS over TCP
sudo ufw allow 53/udp                          # DNS over UDP
sudo ufw allow 80/tcp                          # Pi-hole Web UI
sudo ufw allow from 10.10.10.0/24              # Allow queries from Admin VLAN
sudo ufw allow from 10.10.20.0/24              # Allow from clients and HA
```

---

### 🔹 `raspi4.home` (IoT Relay – VLAN 30)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                             # SSH management
```


---

## 📲 Home Assistant + Mobile ↔ IoT Pathways

| Source            | Target (VLAN 30)   | Allowed Ports (TCP/UDP)      | Purpose                       |
|-------------------|--------------------|-------------------------------|-------------------------------|
| `nas.home` (HA)   | Kasa plugs / IoT   | 9999, 80, 443, 554, 5353      | Smart plug control + discovery|
| Mobile Phone (Wi-Fi) | Kasa IoT         | Same                          | Kasa App control              |

Recommended: Avahi or mDNS bridge container (optional) for device discovery across VLANs.

---

SkyNet Prod 2 is active, segmented, secure, and orchestrated with surgical clarity. Let me know if you’d like this exported as a `.md` file, visual diagram, or integration with Homarr.

