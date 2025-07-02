# ☁️ SkyNet Homelab – Full Topology & Device Inventory (Updated)

All current device roles, VLANs, local DNS assignments, SSIDs, and reverse proxy mappings—with **Vaultwarden removed** and **Home Assistant running on the Synology NAS** as `assist.home`.

---

## 🧠 Device Inventory & DNS Mapping

| Hostname     | DNS Name          | IP Address     | Hardware              | Role / Function                        | Key Services                                        |
|--------------|-------------------|----------------|------------------------|-----------------------------------------|-----------------------------------------------------|
| `popbox`     | `popbox.home`     | 10.10.10.10    | Dell XPS / Pop!_OS     | Admin core, orchestration, HTTPS proxy | Ansible, dnsmasq, Homarr, Portainer, NGINX Proxy    |
| `raspi5`     | `raspi5.home`     | 10.10.20.14    | Raspberry Pi 5         | Services stack                         | Mosquitto, Uptime Kuma (port 3001)                  |
| `nas`        | `nas.home`        | 10.10.20.10    | Synology NAS           | Media storage + Home Automation        | Plex, Synology Drive, SMB/NFS, **Home Assistant**, Tautulli |
| `raspi3`     | `dns.home`        | 10.10.30.53    | Raspberry Pi 3         | Primary DNS & filtering                | Pi-hole, Unbound, Tailscale                         |
| `raspi4`     | `pi4util.home`    | 10.10.30.11    | Raspberry Pi 4         | IoT telemetry & DNS backup             | AdGuard (8053), NodeRED, Zigbee2MQTT, Prometheus    |
| `router`     | `router.home`     | 10.10.99.2     | TP-Link AX6600 AX90    | Gateway + wireless AP                  | Internet uplink, DHCP fallback                      |
| `switch`     | `switch.home`     | 10.10.99.1     | Tenda TEG208E          | Core switch w/ VLAN trunking           | Port-based VLAN segmentation                        |
| `printer`    | `printer.home`    | 10.10.20.21    | Wired Network Printer  | Office & remote printing               | Accessible via UI (if enabled)                      |
| `smarttv`    | `smarttv.home`    | 10.10.20.30    | Google TV Smart TV     | Streaming & casting                    | Plex client, Chromecast support                     |
| `googletv`   | `googletv.home`   | 10.10.20.31    | Google TV HDMI Device  | Streaming HDMI device                  | Cast target, YouTube TV, Netflix, etc.              |

---

## 🧩 VLAN Assignment & Subnet Roles

| VLAN ID | Name        | Subnet           | Purpose                            | DHCP Source              |
|---------|-------------|------------------|-------------------------------------|---------------------------|
| 10      | Admin       | 10.10.10.0/24    | Secure orchestration & control     | `dnsmasq` on `popbox`     |
| 20      | Services    | 10.10.20.0/24    | Media, containers, streaming stack | DHCP reservations / static|
| 30      | IoT         | 10.10.30.0/24    | Smart devices + DNS filtering      | Relay or static mappings  |
| 40      | Guest       | 10.10.40.0/24    | Isolated Wi-Fi for visitors        | Router fallback           |
| 99      | Mgmt        | 10.10.99.0/24    | Infrastructure config only         | Static IPs                |

---

## 📶 SSID to VLAN Mapping

| SSID         | Band     | VLAN | Hidden | Auth Type         | Devices Served                        |
|--------------|----------|------|--------|--------------------|----------------------------------------|
| `Homers`     | 5GHz     | 10   | Yes    | WPA2/3 Enterprise  | Admin laptops, orchestration gear      |
| `Spicy Mac`  | 5GHz     | 20   | No     | WPA2 Personal      | Phones, tablets, smart TVs, printers   |
| `Smarties`   | 2.4GHz   | 30   | Yes    | WPA2 Personal      | Smart plugs, ESPHome, Zigbee sensors   |

> *Note: VLAN tagging is enforced via switch configuration due to AX90 limitations.*

---

## 🔌 Switch Port-to-Device Map (Tenda TEG208E)

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

| Internal URL              | Backend Host        | Description                         |
|---------------------------|---------------------|-------------------------------------|
| `https://dashboard.home`  | `popbox:7575`       | Homarr dashboard                    |
| `https://assist.home`     | `nas:8123`          | **Home Assistant** web UI           |
| `https://kuma.home`       | `raspi5:3001`       | Uptime Kuma                         |
| `https://dns.home`        | `raspi3`            | Pi-hole admin portal                |
| `https://adguard.home`    | `pi4util:8053`      | AdGuard Home                        |
| `https://printer.home`    | `printer`           | Printer UI (if supported)           |

---

## 🧭 DNS Strategy & Name Resolution

- `.home` domain authoritative via `dnsmasq` on `popbox`
- Pi-hole (`dns.home`) and AdGuard (`pi4util.home`) act as local resolvers
- All hostnames managed in Ansible-driven static maps
- Split DNS optional via hosts override or external zone proxying

---

SkyNet is humming: reverse-proxied, service-aware, and stripped of any bloat. Let me know if you’d like a Markdown file export, a visual network diagram, or updated `host_vars` scaffolding next.
