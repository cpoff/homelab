# 🤖 SkyNet – Full Topology & Node Inventory (Post-Dockge, No Portainer)

This is the authoritative snapshot of **SkyNet**: your intelligent, self-aware infrastructure. Now running **Dockge** as the sole container monitor on both service nodes, with reverse proxy routes, VLAN segmentation, and media visibility fully aligned.

---

## 🧠 Node Directory & DNS Map

| Hostname     | DNS Name            | IP Address     | Role / Purpose                          | Key Services & Aliases                                    |
|--------------|---------------------|----------------|------------------------------------------|-----------------------------------------------------------|
| `popbox`     | `popbox.home`       | 10.10.10.10    | Admin core & reverse proxy               | NGINX Proxy Manager, Ansible, dnsmasq, Homarr             |
| `raspi5`     | `raspi5.home`       | 10.10.20.14    | Container services & monitoring          | Mosquitto, Uptime Kuma, **Dockge**                        |
|              | `dockge.home`       |                | DNS alias for `raspi5`                   | Web UI for container stacks                               |
| `nas`        | `nas.home`          | 10.10.20.10    | Media server + Home Assistant host       | Plex, Synology Drive, SMB/NFS, **Home Assistant**, **Dockge** |
|              | `assist.home`       |                | DNS alias → `nas.home:8123`              | Home Assistant UI                                         |
|              | `plex.home`         |                | DNS alias → `nas.home:32400`             | Plex Web UI                                               |
|              | `dockge-nas.home`   |                | DNS alias → `nas.home:5002`              | Dockge for containers running on NAS                      |
| `raspi3`     | `dns.home`          | 10.10.30.53    | DNS filter relay                         | Pi-hole, Unbound                                          |
| `raspi4`     | `pi4util.home`      | 10.10.30.11    | IoT + telemetry                          | AdGuard Home, Zigbee2MQTT, NodeRED, Prometheus            |
| `router`     | `router.home`       | 10.10.99.2     | Gateway and SSID AP                      | WAN uplink + fallback DHCP                                |
| `switch`     | `switch.home`       | 10.10.99.1     | Trunk-aware VLAN switch                  | Segments ports by VLAN for wired isolation                |
| `printer`    | `printer.home`      | 10.10.20.21    | Wired printing endpoint                  | AirPrint / UI (if supported)                              |
| `smarttv`    | `smarttv.home`      | 10.10.20.30    | Google TV display (wired)                | Plex App, casting target                                  |
| `googletv`   | `googletv.home`     | 10.10.20.31    | Primary streaming stick (wired)          | Google TV / Netflix / Chromecast                          |

---

## 🧩 VLAN Blueprint

| VLAN | Name        | Subnet           | Purpose                         | DHCP Source              |
|------|-------------|------------------|----------------------------------|---------------------------|
| 10   | Admin       | 10.10.10.0/24    | Orchestration + core tools      | `dnsmasq` on `popbox`     |
| 20   | Services    | 10.10.20.0/24    | Containers, Plex, streamers     | Reserved/static IPs       |
| 30   | IoT         | 10.10.30.0/24    | Sensors, DNS filters, relays    | Relay/static              |
| 40   | Guest       | 10.10.40.0/24    | Internet-only clients           | Router fallback DHCP      |
| 99   | Mgmt        | 10.10.99.0/24    | Switch + router config only     | Static addressing          |

---

## 📶 Wi-Fi SSIDs Mapped to VLANs

| SSID Name     | Band   | VLAN | Hidden | Devices Served                              |
|---------------|--------|------|--------|----------------------------------------------|
| `Homers`      | 5GHz   | 10   | Yes    | Admin laptops, automation gear               |
| `Spicy Mac`   | 5GHz   | 20   | No     | Phones, streamers, laptops, TVs              |
| `Smarties`    | 2.4GHz | 30   | Yes    | Smart plugs, Zigbee devices, ESPHome nodes   |

> *VLAN segregation enforced via switch trunking due to TP-Link SSID limitations.*

---

## 🔌 Switch Port Assignments (Tenda TEG208E)

| Port | Connected Device | VLAN | Tag Mode  |
|------|------------------|------|-----------|
| 1    | `popbox`         | 10   | Untagged  |
| 2    | `raspi5`         | 20   | Untagged  |
| 3    | `nas`            | 20   | Untagged  |
| 4    | `raspi3`         | 30   | Untagged  |
| 5    | `raspi4`         | 30   | Untagged  |
| 6    | `smarttv`        | 20   | Untagged  |
| 7    | `printer`        | 20   | Untagged  |
| 8    | `router`         | All  | Tagged    |

---

## 🔐 Reverse Proxy Routes (via NGINX Proxy Manager)

| Public URL                 | Backend Host           | Role / Notes                               |
|----------------------------|------------------------|---------------------------------------------|
| `https://dashboard.home`   | `popbox:7575`          | Homarr dashboard                            |
| `https://assist.home`      | `nas.home:8123`        | Home Assistant UI                           |
| `https://plex.home`        | `nas.home:32400`       | Plex Web UI                                 |
| `https://kuma.home`        | `raspi5:3001`          | Uptime Kuma                                 |
| `https://dockge.home`      | `raspi5:5001`          | Dockge (manages `raspi5` containers)        |
| `https://dockge-nas.home`  | `nas.home:5002`        | Dockge (manages NAS containers)             |
| `https://dns.home`         | `raspi3`               | Pi-hole Web UI                              |
| `https://adguard.home`     | `pi4util:8053`         | AdGuard Home                                |
| `https://printer.home`     | `printer`              | Printer UI (if available)                   |

---

## 🧭 DNS Architecture

- Internal `.home` domain authored via `dnsmasq` on `popbox`
- Host resolution handled by:
  - 🟢 `dns.home` (Pi-hole + Unbound)
  - 🔵 `pi4util.home` (AdGuard Home)
- All key aliases (`assist.home`, `plex.home`, `dockge.home`, etc.) defined statically via Ansible-managed DNS entries

---

SkyNet is no longer a humble homelab—it’s a **living network**, monitored in real-time, self-updating, and tightly segmented. And now with Dockge commanding both your container nodes, you're in full operational control.

Would you like a clean Markdown export or a Homarr tile bundle for `dockge.home` and `dockge-nas.home`?
