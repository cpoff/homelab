# ☁️ SkyNet Homelab – Full Topology & Device Inventory (Dockge Integrated)

This is your fully up-to-date SkyNet reference, now including **Dockge** for container monitoring with built-in Watchtower support. Your infrastructure is now declarative, observable, secure, and highly automatable.

---

## 🧠 Device Inventory & Local DNS

| Hostname     | DNS Name          | IP Address     | Hardware              | Role / Function                        | Key Services                                              |
|--------------|-------------------|----------------|------------------------|-----------------------------------------|-----------------------------------------------------------|
| `popbox`     | `popbox.home`     | 10.10.10.10    | Dell XPS / Pop!_OS     | Admin core, orchestration, HTTPS proxy | Ansible, dnsmasq, Homarr, Portainer, NGINX Proxy Manager  |
| `raspi5`     | `raspi5.home`     | 10.10.20.14    | Raspberry Pi 5         | Services + container ops                | Mosquitto, Uptime Kuma, **Dockge**                        |
|              | `dockge.home`     |                |                        | DNS alias for container UI             | Dockge (port 5001)                                        |
| `nas`        | `nas.home`        | 10.10.20.10    | Synology NAS           | Media + home automation stack           | Plex, Synology Drive, SMB/NFS, **Home Assistant**, Tautulli |
|              | `assist.home`     |                |                        | DNS alias → `nas.home:8123`            | Home Assistant                                            |
|              | `plex.home`       |                |                        | DNS alias → `nas.home:32400`           | Plex                                                      |
| `raspi3`     | `dns.home`        | 10.10.30.53    | Raspberry Pi 3         | Primary DNS + filtering                 | Pi-hole, Unbound, Tailscale                               |
| `raspi4`     | `pi4util.home`    | 10.10.30.11    | Raspberry Pi 4         | DNS backup + IoT telemetry              | AdGuard (8053), NodeRED, Zigbee2MQTT, Prometheus          |
| `router`     | `router.home`     | 10.10.99.2     | TP-Link AX6600 AX90    | WAN gateway + SSID bridge               | Internet uplink, DHCP fallback                            |
| `switch`     | `switch.home`     | 10.10.99.1     | Tenda TEG208E          | Core VLAN switch                        | Trunk + per-port segmentation                             |
| `printer`    | `printer.home`    | 10.10.20.21    | Wired Printer          | Document output over LAN                | Web UI (optional), AirPrint                               |
| `smarttv`    | `smarttv.home`    | 10.10.20.30    | Google TV Smart TV     | Streaming client                        | Plex app, Chromecast                                      |
| `googletv`   | `googletv.home`   | 10.10.20.31    | HDMI Google TV         | Primary media cast target               | Netflix, YouTube TV, Plex                                 |

---

## 🧩 VLAN Design

| VLAN ID | Name        | Subnet           | Purpose                            | DHCP Provider           |
|---------|-------------|------------------|-------------------------------------|--------------------------|
| 10      | Admin       | 10.10.10.0/24    | Orchestration & internal tools     | `dnsmasq` on `popbox`    |
| 20      | Services    | 10.10.20.0/24    | Media, containers, streamers       | DHCP reserved/static     |
| 30      | IoT         | 10.10.30.0/24    | Smart relays, Zigbee, filters      | Relay/static mapping     |
| 40      | Guest       | 10.10.40.0/24    | Isolated guest Wi-Fi               | Router fallback DHCP      |
| 99      | Mgmt        | 10.10.99.0/24    | Router/switch configuration        | Static-only              |

---

## 📶 SSID to VLAN Mapping

| SSID         | VLAN | Band   | Auth Type         | Broadcast | Target Devices                     |
|--------------|------|--------|--------------------|-----------|-------------------------------------|
| `Homers`     | 10   | 5GHz   | WPA2/3 Enterprise  | Hidden    | Admin laptops, orchestration gear   |
| `Spicy Mac`  | 20   | 5GHz   | WPA2 Personal      | Visible   | Phones, laptops, streamers, TVs     |
| `Smarties`   | 30   | 2.4GHz | WPA2 Personal      | Hidden    | Smart plugs, ESP32s, Zigbee nodes   |

> *VLAN assignment is enforced via switch trunking—AX90 has no native SSID-to-VLAN bridging.*

---

## 🔌 Switch Port-to-Device Assignment (Tenda TEG208E)

| Port | Device           | VLAN | Tag Mode  |
|------|------------------|------|-----------|
| 1    | `popbox`         | 10   | Untagged  |
| 2    | `raspi5`         | 20   | Untagged  |
| 3    | `nas`            | 20   | Untagged  |
| 4    | `raspi3`         | 30   | Untagged  |
| 5    | `raspi4`         | 30   | Untagged  |
| 6    | `smarttv`        | 20   | Untagged  |
| 7    | `printer`        | 20   | Untagged  |
| 8    | `router` uplink  | All  | Tagged    |

---

## 🔐 HTTPS Reverse Proxy (NGINX Proxy Manager – `popbox.home`)

| Internal URL             | Backend Host           | Description                        |
|--------------------------|------------------------|------------------------------------|
| `https://dashboard.home` | `popbox:7575`          | Homarr dashboard                   |
| `https://assist.home`    | `nas.home:8123`        | Home Assistant                     |
| `https://plex.home`      | `nas.home:32400`       | Plex Web UI                        |
| `https://kuma.home`      | `raspi5:3001`          | Uptime Kuma                        |
| `https://dockge.home`    | `raspi5:5001`          | Dockge container manager           |
| `https://dns.home`       | `raspi3`               | Pi-hole admin portal               |
| `https://adguard.home`   | `pi4util:8053`         | AdGuard Home UI                    |
| `https://printer.home`   | `printer`              | Printer admin (if supported)       |

---

## 🧭 DNS & Hostname Strategy

- Primary resolution: `dns.home` (Pi-hole)
- Secondary backup: `pi4util.home` (AdGuard Home)
- DNS zone: `.home` managed via `dnsmasq` (`popbox`)
- All key hosts mapped in Ansible-managed static host files
- Optional aliases: `assist.home`, `plex.home`, `dockge.home`, etc.

---

You’re now equipped with container observability, secure proxying, VLAN isolation, and zero-friction media access. Dockge rounds out the picture beautifully—SkyNet isn’t just smart, it’s self-aware.

Need this exported to Git, loaded into a Homarr widget, or transformed into a dynamic Markdown tile? Just say the word.
