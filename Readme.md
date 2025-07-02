# 🤖 SkyNet – Full Topology & Infrastructure Map (Finalized Physical Layout)

The authoritative and up-to-date blueprint of **SkyNet**, now reflecting:
- Dockge as the sole container dashboard (on `raspi5` and `nas`)
- No Portainer
- Work devices and Pop box isolated on a trusted switch (VLAN 10)
- Smart TV + Google TV grouped on an unmanaged switch (VLAN 20)
- Physical and logical segmentation enforced with purpose

---

## 🧠 Node Directory & DNS

| Hostname     | DNS Name            | IP Address     | Role & Function                         | Key Services & Aliases                                       |
|--------------|---------------------|----------------|------------------------------------------|--------------------------------------------------------------|
| `popbox`     | `popbox.home`       | 10.10.10.10    | Admin orchestration + NGINX reverse proxy | Ansible, dnsmasq, Homarr, NPM                               |
|              |                     |                | **Physically isolated on VLAN 10 switch** |                                                              |
| `raspi5`     | `raspi5.home`       | 10.10.20.14    | Container stack + observer               | Mosquitto, Uptime Kuma, **Dockge**                          |
|              | `dockge.home`       |                | DNS alias (Dockge @ port 5001)           | UI for containers on `raspi5`                               |
| `nas`        | `nas.home`          | 10.10.20.10    | Plex, Home Assistant, media libraries     | Plex, Synology Drive, SMB/NFS, **HA**, **Dockge**           |
|              | `assist.home`       |                | DNS alias → `nas.home:8123`              | Home Assistant UI                                           |
|              | `plex.home`         |                | DNS alias → `nas.home:32400`             | Plex Web UI                                                 |
|              | `dockge-nas.home`   |                | DNS alias → `nas.home:5002`              | Dockge for NAS containers                                   |
| `raspi3`     | `dns.home`          | 10.10.30.53    | Primary DNS & filter node                | Pi-hole, Unbound, Tailscale                                 |
| `raspi4`     | `pi4util.home`      | 10.10.30.11    | DNS backup + telemetry                   | AdGuard, Zigbee2MQTT, NodeRED, Prometheus                   |
| `router`     | `router.home`       | 10.10.99.2     | Wi-Fi AP & WAN gateway                   | AX6600 uplink                                                |
| `switch`     | `switch.home`       | 10.10.99.1     | VLAN trunking + switch control           | TEG208E managed interface                                    |
| `printer`    | `printer.home`      | 10.10.20.21    | Wired LAN printer                        | UI optional                                                  |
| `smarttv`    | `smarttv.home`      | 10.10.20.30    | Google TV smart display                  | Plex client, casting                                         |
| `googletv`   | `googletv.home`     | 10.10.20.31    | Chromecast / HDMI streamer               | Google TV, Plex, YouTube TV                                 |

---

## 🧩 VLAN Blueprint

| VLAN ID | Name      | Subnet           | Purpose                              | DHCP Control           |
|---------|-----------|------------------|---------------------------------------|-------------------------|
| 10      | Admin     | 10.10.10.0/24    | Orchestration, laptops, Pop box       | `dnsmasq` on `popbox`   |
| 20      | Services  | 10.10.20.0/24    | NAS, Dockge, Plex, TVs, streamers     | Static/reserved         |
| 30      | IoT       | 10.10.30.0/24    | Smart plugs, relays, Zigbee bridges   | Static or relay         |
| 40      | Guest     | 10.10.40.0/24    | Internet-only clients (BYOD)          | Router fallback         |
| 99      | Mgmt      | 10.10.99.0/24    | Router/switch control                 | Static                  |

---

## 📶 SSIDs and VLAN Routing

| SSID         | VLAN | Band   | Broadcast | Devices Served                            |
|--------------|------|--------|-----------|--------------------------------------------|
| `Homers`     | 10   | 5GHz   | Hidden    | Work laptops, Pop box (hidden/secure)      |
| `Spicy Mac`  | 20   | 5GHz   | Visible   | Phones, smart TVs, Google TV               |
| `Smarties`   | 30   | 2.4GHz | Hidden    | Zigbee/ESP/IoT clients                     |

> SSID VLANs enforced upstream via tagging on TEG208E.

---

## 🔌 Switch Port Map – TEG208E

| Port | Connected Device/Switch          | VLAN | Tag Mode  |
|------|----------------------------------|------|-----------|
| 1    | Pop box + work laptops switch    | 10   | Untagged  |
| 2    | `raspi5`                         | 20   | Untagged  |
| 3    | `nas`                            | 20   | Untagged  |
| 4    | `raspi3`                         | 30   | Untagged  |
| 5    | `raspi4`                         | 30   | Untagged  |
| 6    | Unmanaged media switch           | 20   | Untagged  |
| 7    | `printer`                        | 20   | Untagged  |
| 8    | Uplink to AX6600 router          | All  | Tagged    |

---

## 🌐 Reverse Proxy Map (NPM @ `popbox.home`)

| URL                         | Target Backend        | Description                          |
|-----------------------------|------------------------|---------------------------------------|
| `https://dashboard.home`    | `popbox:7575`          | Homarr UI                            |
| `https://assist.home`       | `nas.home:8123`        | Home Assistant                       |
| `https://plex.home`         | `nas.home:32400`       | Plex server                          |
| `https://kuma.home`         | `raspi5:3001`          | Uptime Kuma                          |
| `https://dockge.home`       | `raspi5:5001`          | Dockge (container UI on `raspi5`)    |
| `https://dockge-nas.home`   | `nas.home:5002`        | Dockge (container UI on NAS)         |
| `https://dns.home`          | `raspi3`               | Pi-hole                              |
| `https://adguard.home`      | `pi4util:8053`         | AdGuard                              |
| `https://printer.home`      | `printer`              | Printer Web UI (if enabled)          |

---

## 🧭 DNS Strategy

- `.home` zone served by `dnsmasq` on `popbox`
- Internal resolution handled by:
  - `dns.home` (Pi-hole, Unbound)
  - `pi4util.home` (AdGuard Home backup)
- All hostnames and aliases Ansible-managed
- Split DNS optional via VPN or `/etc/hosts` overlays

---

SkyNet is now:
- Physically segmented
- VLAN-routed
- Container-monitored
- Reverse-proxied
- Docs-backed

Let me know if you'd like a printable `.md`, an SVG diagram, or Homarr tile JSON for rapid UI scaffolding. SkyNet is operational—and self-aware.
