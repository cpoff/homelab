# ☁️ SkyNet Homelab – Full Topology & Device Inventory

A complete, consolidated view of SkyNet’s infrastructure—including every device, VLAN, DNS name, SSID, service, and switch port assignment. Documented with clarity, hardened with intent.

---

## 🧠 Device Inventory & DNS Mapping

| Hostname     | DNS Name          | IP Address     | Hardware              | Role / Function                        | Key Services                                        |
|--------------|-------------------|----------------|------------------------|-----------------------------------------|-----------------------------------------------------|
| `popbox`     | `popbox.home`     | 10.10.10.10    | Dell XPS / Pop!_OS     | Admin core, orchestration, HTTPS proxy | Ansible, dnsmasq, Homarr, Portainer, NGINX Proxy    |
| `raspi5`     | `raspi5.home`     | 10.10.20.14    | Raspberry Pi 5         | Services stack                         | Vaultwarden, Mosquitto, Home Assistant, Uptime Kuma |
| `nas`        | `nas.home`        | 10.10.20.10    | Synology NAS           | Media storage and sharing              | Plex, Synology Drive, SMB/NFS, Tautulli             |
| `raspi3`     | `dns.home`        | 10.10.30.53    | Raspberry Pi 3         | Primary DNS & filtering                | Pi-hole, Unbound, Tailscale                         |
| `raspi4`     | `pi4util.home`    | 10.10.30.11    | Raspberry Pi 4         | IoT telemetry & DNS backup             | AdGuard (8053), NodeRED, Zigbee2MQTT, Prometheus    |
| `router`     | `router.home`     | 10.10.99.2     | TP-Link AX6600 AX90    | Gateway + wireless AP                  | Internet uplink, DHCP fallback                      |
| `switch`     | `switch.home`     | 10.10.99.1     | Tenda TEG208E          | Core switch w/ VLAN trunking           | Port-based VLAN segmentation                        |
| `printer`    | `printer.home`    | 10.10.20.21    | Wired Network Printer  | Office & remote printing               | Accessible via web UI (if enabled)                  |
| `smarttv`    | `smarttv.home`    | 10.10.20.30    | Google TV Smart TV     | Streaming & casting                    | Plex client, Chromecast support                     |
| `googletv`   | `googletv.home`   | 10.10.20.31    | Google TV Device       | Streaming HDMI device                  | Cast target, YouTube TV, Netflix, etc.              |

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

## 📶 SSID to VLAN Mapping (Wi-Fi Segmentation)

| SSID         | Band     | VLAN | Hidden | Auth Type         | Connected Device Types                |
|--------------|----------|------|--------|--------------------|----------------------------------------|
| `Homers`     | 5GHz     | 10   | Yes    | WPA2/3 Enterprise  | Admin laptops, orchestration gear      |
| `Spicy Mac`  | 5GHz     | 20   | No     | WPA2 Personal      | Phones, tablets, smart TVs, printers   |
| `Smarties`   | 2.4GHz   | 30   | Yes    | WPA2 Personal      | Smart plugs, sensors, Zigbee devices   |

> *Note:* Since the Archer AX90 lacks native VLAN support per SSID, wired segmentation is enforced via switch configuration.

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
| 8    | `router` (uplink)   | 10/20/30/40/99 | Tagged |

---

## 🔐 HTTPS Reverse Proxy (via NGINX Proxy Manager on `popbox.home`)

| Friendly URL               | Backend Host         | Description                            |
|----------------------------|----------------------|-----------------------------------------|
| `https://dashboard.home`   | `popbox:7575`        | Homarr dashboard                        |
| `https://vaultwarden.home`| `raspi5`             | Password manager                        |
| `https://kuma.home`        | `raspi5:3001`        | Uptime Kuma monitoring UI               |
| `https://dns.home`         | `raspi3`             | Pi-hole admin portal                    |
| `https://adguard.home`     | `raspi4:8053`        | AdGuard Home filtering                  |
| `https://printer.home`     | `printer`            | Printer UI (if supported)               |

> TLS certs issued via Let’s Encrypt (DNS-01) or custom internal CA. HTTP access is force-redirected to HTTPS.

---

## 🧭 DNS + Name Resolution Strategy

- Authoritative DNS: `dnsmasq` on `popbox.home` for `.home` domain
- Primary resolver: `dns.home` (Pi-hole + Unbound)
- Secondary backup: `pi4util.home` (AdGuard Home)
- All nodes registered as static hosts in `dnsmasq.hosts` (Ansible-managed)
- Optional `/etc/hosts` on admin nodes for emergency LAN resolution

---

SkyNet is now fully documented and proudly operational:
- Layered DNS + TLS
- Clean VLAN boundaries
- Wire-speed segmentation
- Local service discovery
- Declarative infrastructure

Let me know if you'd like a Markdown export, Homarr tile preset JSON, or rendered network diagram next.
