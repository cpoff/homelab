# 🤖 SkyNet – Full Topology & Infrastructure Map (Prod 1 – IoT Access + Personal Devices + UFW Commentary)

This snapshot represents the finalized “**Prod 1**” configuration of **SkyNet**, incorporating:

- Updated hostnames (`raspi3.home`, `raspi4.home`)
- Chromebooks on VLAN 20 with DNS integration
- Home Assistant + mobile device control of IoT smart plugs
- UFW firewall rule commentary for clarity and auditability

---

## 🧠 Node Directory & DNS Map

| Hostname       | DNS Name            | IP Address     | OS / Type          | Role & Services                                        |
|----------------|---------------------|----------------|---------------------|---------------------------------------------------------|
| `popbox`       | `popbox.home`       | 10.10.10.10    | Pop!_OS             | Admin + orchestration (NGINX, dnsmasq, Homarr)          |
| `raspi5`       | `raspi5.home`       | 10.10.20.14    | Raspberry Pi OS     | Dockge, Uptime Kuma, Mosquitto                          |
| `raspi3`       | `raspi3.home`       | 10.10.30.53    | DietPi              | Pi-hole + Unbound                                       |
| `raspi4`       | `raspi4.home`       | 10.10.30.11    | DietPi              | AdGuard Home, Zigbee2MQTT, NodeRED                     |
| `nas`          | `nas.home`          | 10.10.20.10    | Synology DSM        | Plex, Home Assistant, Dockge, shared media              |
| `printer`      | `printer.home`      | 10.10.20.21    | HW Device           | Wired AirPrint-compatible printer                       |
| `smarttv`      | `smarttv.home`      | 10.10.20.30    | Google TV           | Media display (Plex, YouTube)                           |
| `googletv`     | `googletv.home`     | 10.10.20.31    | Google TV HDMI      | Primary HDMI streaming stick                            |
| `chromebook1`  | `cb1.home`          | 10.10.20.41    | ChromeOS            | Personal laptop                                         |
| `chromebook2`  | `cb2.home`          | 10.10.20.42    | ChromeOS            | Personal laptop                                         |
| `router`       | `router.home`       | 10.10.99.2     | TP-Link AX6600      | VLAN trunk + fallback DHCP                              |
| `switch`       | `switch.home`       | 10.10.99.1     | Tenda TEG208E       | VLAN-aware switch                                       |

---

## 🧩 VLAN Design

| VLAN | Name      | Subnet           | Purpose                                     |
|------|-----------|------------------|---------------------------------------------|
| 10   | Admin     | 10.10.10.0/24    | Trusted orchestration + work laptops        |
| 20   | Services  | 10.10.20.0/24    | NAS, Dockge, TV, Plex, mobile + Chromebooks |
| 30   | IoT       | 10.10.30.0/24    | Smart plugs, Zigbee, relays                 |
| 40   | Guest     | 10.10.40.0/24    | Internet-only Wi-Fi                         |
| 99   | Mgmt      | 10.10.99.0/24    | Static config for router/switch             |

---

## 📶 SSIDs → VLAN Mapping

| SSID         | VLAN | Band   | Devices Served                                |
|--------------|------|--------|-----------------------------------------------|
| `Homers`     | 10   | 5GHz   | Pop box, work laptops                         |
| `Spicy Mac`  | 20   | 5GHz   | Phones, Chromebooks, TVs                      |
| `Smarties`   | 30   | 2.4GHz | Kasa smart plugs, Zigbee/ESP devices          |

---

## 🔌 Switch Port-to-Device Map (TEG208E)

| Port | Connection                     | VLAN | Tag Mode  |
|------|--------------------------------|------|-----------|
| 1    | Pop box + work laptops switch  | 10   | Untagged  |
| 2    | `raspi5`                       | 20   | Untagged  |
| 3    | `nas`                          | 20   | Untagged  |
| 4    | `raspi3`                       | 30   | Untagged  |
| 5    | `raspi4`                       | 30   | Untagged  |
| 6    | SmartTV + Googletv (unmanaged) | 20   | Untagged  |
| 7    | Printer                        | 20   | Untagged  |
| 8    | Router uplink                  | All  | Tagged    |

---

## 🔐 Reverse Proxy Map (NGINX Proxy Manager @ `popbox.home`)

| URL                        | Internal Target      | Notes                                     |
|----------------------------|-----------------------|--------------------------------------------|
| `https://dashboard.home`   | `popbox:7575`         | Homarr                                     |
| `https://assist.home`      | `nas.home:8123`       | Home Assistant                             |
| `https://plex.home`        | `nas.home:32400`      | Plex                                       |
| `https://dockge.home`      | `raspi5.home:5001`    | Dockge (raspi5 containers)                 |
| `https://dockge-nas.home`  | `nas.home:5002`       | Dockge (NAS containers)                    |
| `https://raspi3.home`      | `raspi3.home`         | Pi-hole Web UI                             |
| `https://raspi4.home`      | `raspi4.home:8053`    | AdGuard Home                               |
| `https://printer.home`     | `printer.home`        | Printer UI (if available)                  |

---

## 🛡️ UFW Rules with Full Commentary

### 🔹 `raspi5.home` (VLAN 20 – Dockge, Kuma, Mosquitto)
```bash
# Default deny all inbound traffic unless explicitly allowed
sudo ufw default deny incoming

# Allow all outbound traffic (e.g. updates, DNS)
sudo ufw default allow outgoing

# SSH access from local net (port 22)
sudo ufw allow ssh  # Secure shell for remote access

# Allow inbound access to Dockge web UI
sudo ufw allow 5001/tcp  # Dockge container manager

# Allow Uptime Kuma dashboard access
sudo ufw allow 3001/tcp  # Uptime Kuma HTTP UI

# Allow access from popbox (Admin VLAN) to both web services
sudo ufw allow from 10.10.10.10 to any port 5001,3001  # Admin interface access
```

### 🔹 `raspi3.home` (VLAN 30 – Pi-hole + Unbound)
```bash
sudo ufw default deny incoming
sudo ufw allow ssh                         # SSH for management
sudo ufw allow 53                         # DNS over TCP/UDP
sudo ufw allow 80                         # Web interface (admin UI)
sudo ufw allow from 10.10.10.0/24         # Admin VLAN access
sudo ufw allow from 10.10.20.0/24         # HA + clients access
```

### 🔹 `raspi4.home` (VLAN 30 – AdGuard, Zigbee2MQTT)
```bash
sudo ufw default deny incoming
sudo ufw allow ssh                        # SSH access
sudo ufw allow 8053/tcp                   # AdGuard UI
sudo ufw allow 53                         # DNS over TCP/UDP
sudo ufw allow from 10.10.10.0/24         # Admin VLAN access
sudo ufw allow from 10.10.20.0/24         # User devices can resolve via AdGuard
```

### 🔹 `popbox.home` (VLAN 10 – NGINX, dnsmasq, Homarr)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80,443/tcp                 # NGINX reverse proxy (TLS + HTTP)
sudo ufw allow 7575/tcp                   # Homarr dashboard
sudo ufw allow from 10.10.20.0/24 to any port 443 comment 'Allow clients to access reverse proxy'
```

---

## 🔄 Home Assistant & Mobile ↔ IoT Access Summary

| Flow                          | Port(s) Used           | Protocols     | Notes                                        |
|-------------------------------|------------------------|---------------|----------------------------------------------|
| HA → Kasa plugs (VLAN 30)     | 9999, 80, 443, 554     | TCP/UDP       | Allows control from VLAN 20 → 30             |
| Phone → Kasa plugs (VLAN 30)  | Same                   | TCP/UDP       | App control works via `Spicy Mac` SSID       |
| Optional: Multicast bridging  | 224.0.0.251:5353       | mDNS          | For discovery; may need Avahi or mdns repe
