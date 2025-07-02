# ☁️ SkyNet – Topology & Device Inventory

SkyNet is now optimized for seamless media access—with Plex and media libraries on the Synology NAS, visible across all laptops and streaming clients. Vaultwarden has been removed, and Home Assistant runs on `nas.home` as `assist.home`.

---

## 🧠 Device Inventory & DNS Mapping

| Hostname     | DNS Name          | IP Address     | Hardware              | Role / Function                        | Key Services                                              |
|--------------|-------------------|----------------|------------------------|-----------------------------------------|-----------------------------------------------------------|
| `popbox`     | `popbox.home`     | 10.10.10.10    | Dell XPS / Pop!_OS     | Admin core, orchestration, HTTPS proxy | Ansible, dnsmasq, Homarr, Portainer, NGINX Proxy Manager  |
| `raspi5`     | `raspi5.home`     | 10.10.20.14    | Raspberry Pi 5         | Services stack                         | Mosquitto, Uptime Kuma (port 3001)                        |
| `nas`        | `nas.home`        | 10.10.20.10    | Synology NAS           | Media server + Home Assistant          | Plex, Synology Drive, SMB/NFS, Home Assistant, Tautulli   |
|              | `assist.home`     |                |                        | **(DNS alias for Home Assistant)**     | Resolves to `nas.home:8123`                               |
|              | `plex.home`       |                |                        | **(DNS alias for Plex)**               | Resolves to `nas.home:32400`                              |
| `raspi3`     | `dns.home`        | 10.10.30.53    | Raspberry Pi 3         | Primary DNS & filtering                | Pi-hole, Unbound, Tailscale                               |
| `raspi4`     | `pi4util.home`    | 10.10.30.11    | Raspberry Pi 4         | IoT telemetry & DNS backup             | AdGuard (8053), NodeRED, Zigbee2MQTT, Prometheus          |
| `router`     | `router.home`     | 10.10.99.2     | TP-Link AX6600 AX90    | Gateway + wireless AP                  | Internet uplink, DHCP fallback                            |
| `switch`     | `switch.home`     | 10.10.99.1     | Tenda TEG208E          | Core switch w/ VLAN trunking           | Port-based VLAN segmentation                              |
| `printer`    | `printer.home`    | 10.10.20.21    | Wired Network Printer  | Office & remote printing               | Web UI (if available), driverless AirPrint                |
| `smarttv`    | `smarttv.home`    | 10.10.20.30    | Google TV Smart TV     | Streaming & casting                    | Plex client, Chromecast, YouTube TV                       |
| `googletv`   | `googletv.home`   | 10.10.20.31    | Google TV HDMI Device  | Primary streaming device               | Cast target for Plex, Netflix, etc.                       |

---

## 🧩 VLAN Assignment & Subnet Roles

| VLAN ID | Name        | Subnet           | Purpose                            | DHCP Source              |
|---------|-------------|------------------|-------------------------------------|---------------------------|
| 10      | Admin       | 10.10.10.0/24    | Secure orchestration & control     | `dnsmasq` on `popbox`     |
| 20      | Services    | 10.10.20.0/24    | Media, containers, streamers       | DHCP reservations / static|
| 30      | IoT         | 10.10.30.0/24    | Smart devices + DNS filtering      | Relay or static mappings  |
| 40      | Guest       | 10.10.40.0/24    | Isolated Wi-Fi for visitors        | Router fallback           |
| 99      | Mgmt        | 10.10.99.0/24    | Switch/router config only          | Static IPs                |

---

## 📶 SSID to VLAN Mapping

| SSID         | Band     | VLAN | Hidden | Auth Type         | Devices Served                        |
|--------------|----------|------|--------|--------------------|----------------------------------------|
| `Homers`     | 5GHz     | 10   | Yes    | WPA2/3 Enterprise  | Admin laptops, orchestration gear      |
| `Spicy Mac`  | 5GHz     | 20   | No     | WPA2 Personal      | Phones, laptops, smart TVs, streamers  |
| `Smarties`   | 2.4GHz   | 30   | Yes    | WPA2 Personal      | Smart plugs, Zigbee sensors, ESPHome   |

---

## 🔌 Switch Port Assignments (Tenda TEG208E)

| Port | Device             | VLAN | Tag Mode  |
|------|---------------------|------|-----------|
| 1    | `popbox`            | 10   | Untagged  |
| 2    | `raspi5`            | 20   | Untagged  |
| 3    | `nas`               | 20   | Untagged  |
| 4    | `raspi3`            | 30   | Untagged  |
| 5    | `raspi4`            | 30   | Untagged  |
| 6    | `smarttv`           | 20   | Untagged  |
| 7    | `printer`           | 20   | Untagged  |
| 8    | `router` uplink     | All  | Tagged    |

---

## 🔐 HTTPS Reverse Proxy (NGINX Proxy Manager on `popbox.home`)

| Internal URL             | Backend Host           | Description                         |
|--------------------------|------------------------|-------------------------------------|
| `https://dashboard.home` | `popbox:7575`          | Homarr dashboard                    |
| `https://assist.home`    | `nas.home:8123`        | Home Assistant UI                   |
| `https://plex.home`      | `nas.home:32400`       | Plex web interface                  |
| `https://kuma.home`      | `raspi5:3001`          | Uptime Kuma                         |
| `https://dns.home`       | `raspi3`               | Pi-hole admin                       |
| `https://adguard.home`   | `pi4util:8053`         | AdGuard Home                        |
| `https://printer.home`   | `printer`              | Printer UI (if supported)           |

---

## 🧭 DNS Strategy & Local Resolution

- `.home` zone authored via `dnsmasq` on `popbox`
- Pi-hole and AdGuard provide filtered, local-first resolution
- All hostnames provisioned via Ansible static maps
- Split DNS optional via proxy config or VPN exit-node routes

---

Everything is visible where it should be:
- Streamers and TVs see Plex directly
- Laptops resolve `assist.home` and `plex.home` over HTTPS
- VLAN segmentation holds clean boundaries
- Reverse proxy ties it all together under TLS

Let me know if you'd like this as a printable `.md`, visual network map, or Ansible scaffold next.
