# 🤖 SkyNet – Full Topology & Infrastructure Map (📌 Prod 2)

Each component of this architecture is annotated with a superscript footnote 🔹 indicating its intended configuration method:
- 🖐️ **Manually configured via GUI or CLI**
- 🤖 **Provisioned using Ansible**
- 📝 **Defined via static config file or compose**
- 🛡️ **Configured through dedicated firewall interface**

---

## 🧠 Node Directory & DNS

| Hostname       | IP Address     | OS / Type           | Role & Services                                                                 |
|----------------|----------------|----------------------|----------------------------------------------------------------------------------|
| `popbox`¹²³    | 10.10.10.10    | Pop!_OS              | Admin node with `dnsmasq`, Homarr, NGINX Proxy Manager                          |
| `raspi5`¹²³    | 10.10.20.14    | Raspberry Pi OS      | Dockge (w/ Watchtower), Uptime Kuma, Mosquitto                                  |
| `raspi3`¹²³    | 10.10.30.53    | DietPi               | Pi-hole + Unbound                                                               |
| `raspi4`¹²³    | 10.10.30.11    | DietPi               | AdGuard Home, Zigbee2MQTT, NodeRED, Prometheus                                  |
| `nas`⁴         | 10.10.20.10    | Synology DSM         | Plex, Home Assistant, Dockge + Synology Firewall                                |
| `printer`¹      | 10.10.20.21    | Hardware             | Web UI optional, AirPrint-enabled                                               |
| `smarttv`¹      | 10.10.20.30    | Google TV            | Streaming media client                                                          |
| `googletv`¹     | 10.10.20.31    | Google TV HDMI       | Cast receiver + streaming                                                       |
| `chromebook1`¹  | 10.10.20.41    | ChromeOS             | Personal laptop                                                                 |
| `chromebook2`¹  | 10.10.20.42    | ChromeOS             | Personal laptop                                                                 |
| `router`¹       | 10.10.99.2     | TP-Link AX6600       | WAN uplink + SSIDs                                                              |
| `switch`¹       | 10.10.99.1     | TEG208E Managed      | VLAN trunk + port segmentation                                                  |

---

## 🧩 VLAN Architecture

| VLAN | Name      | Subnet           | Purpose                                        | Configured By |
|------|-----------|------------------|------------------------------------------------|---------------|
| 10   | Admin     | 10.10.10.0/24    | Orchestration, trusted laptops                 | 🖐️ Router + Switch UI |
| 20   | Services  | 10.10.20.0/24    | NAS, Dockge, Plex, phones, Chromebooks         | 🖐️ Router + Switch UI |
| 30   | IoT       | 10.10.30.0/24    | Smart plugs, relays, filtering nodes           | 🖐️ Router + Switch UI |
| 40   | Guest     | 10.10.40.0/24    | Internet-only clients                          | 🖐️ Router UI           |
| 99   | Mgmt      | 10.10.99.0/24    | Switch + router admin                          | 🖐️ Switch config        |

---

## 📶 SSID-to-VLAN Mapping

| SSID         | VLAN | Devices Served                       | Configured By |
|--------------|------|--------------------------------------|---------------|
| `Homers`     | 10   | Pop box, work machines               | 🖐️ Router UI  |
| `Spicy Mac`  | 20   | Personal devices (phones, laptops)   | 🖐️ Router UI  |
| `Smarties`   | 30   | Smart plugs, Zigbee endpoints        | 🖐️ Router UI  |

---

## 🔌 Switch Port Assignments

| Port | Connection                      | VLAN | Configured By |
|------|----------------------------------|------|----------------|
| 1    | Pop box + work laptops (admin)   | 10   | 🖐️ Switch UI   |
| 2    | `raspi5`                         | 20   | 🖐️ Switch UI   |
| 3    | `nas`                            | 20   | 🖐️ Switch UI   |
| 4    | `raspi3`                         | 30   | 🖐️ Switch UI   |
| 5    | `raspi4`                         | 30   | 🖐️ Switch UI   |
| 6    | TVs / GoogleTV (unmanaged)       | 20   | 🖐️ Switch UI   |
| 7    | Printer                          | 20   | 🖐️ Switch UI   |
| 8    | Router uplink                    | All  | 🖐️ Switch UI   |

---

## 🔐 NGINX Reverse Proxy Routes

| URL                        | Backend Target         | Description                      | Configured By |
|----------------------------|-------------------------|-----------------------------------|---------------|
| `https://assist.home`      | `nas:8123`              | Home Assistant                    | 🤖 NGINX via Ansible |
| `https://plex.home`        | `nas:32400`             | Plex UI                           | 🤖              |
| `https://dockge.home`      | `raspi5:5001`           | Dockge (raspi5)                   | 🤖              |
| `https://dockge-nas.home`  | `nas:5002`              | Dockge (NAS)                      | 🤖              |
| `https://dashboard.home`   | `popbox:7575`           | Homarr UI                         | 🤖              |
| `https://raspi3.home`      | `raspi3`                | Pi-hole Admin                     | 🤖              |
| `https://raspi4.home`      | `raspi4:8053`           | AdGuard Admin                     | 🤖              |
| `https://printer.home`     | `printer`               | Printer Web UI                    | 🤖              |

---

## 🧭 DNS + DHCP Design

| Function            | Role                                 | Configured By |
|---------------------|--------------------------------------|---------------|
| `.home` domain      | Authored by `dnsmasq` on popbox      | 🤖 Ansible     |
| Static IP leases    | Devices manually mapped              | 🤖 + 🖐️        |
| Client filtering    | Pi-hole (`raspi3`) + AdGuard (`raspi4`) | 📝 YAML + GUI |
| Upstream resolvers  | Unbound (recursive)                  | 📝            |

---

## 🔄 Home Assistant & IoT Control Routing

| Source Device     | Target VLAN / Devices | Ports / Protocols                  | Configured By |
|-------------------|-----------------------|------------------------------------|---------------|
| Home Assistant    | VLAN 30 IoT devices   | TCP/UDP 9999, 80, 443, 554         | 🖐️ Router firewall |
| Mobile (VLAN 20)  | Kasa smart plugs      | TCP/UDP 9999                       | 🖐️ Router firewall |
| mDNS Reflection   | Optional Avahi bridge | UDP 5353, multicast                | 📝 Compose or Ansible container |

---

## 🛡️ UFW Rules (Annotated & Managed)

| Device           | UFW Applied | Configured By | Notes                      |
|------------------|-------------|----------------|----------------------------|
| `popbox`         | ✅           | 🤖 Ansible      | Admin node                 |
| `raspi5`         | ✅           | 🤖 Ansible      | Dockge + Kuma              |
| `raspi3`         | ✅           | 🤖 or 📝 shell   | Pi-hole DNS relay          |
| `raspi4`         | ✅           | 🤖 or 📝 shell   | AdGuard Home relay         |
| `nas` (Synology) | ❌ (DSM GUI) | 🛡️ DSM Firewall  | Uses Synology native tools |

---

## 🔹 Footnotes – Configuration Method Keys

- **¹** 🖐️ Configured manually via GUI or CLI (e.g. DSM, router, switch)
- **²** 🤖 Provisioned using Ansible (host_vars, roles)
- **³** 📝 Configured via static file (e.g. compose, YAML, bash scripts)
- **⁴** 🛡️ Secured via DSM Firewall or GUI-native firewall

---

SkyNet’s configuration strategy is now codified—clearly separating manual setup, automation pipelines, and GUI-managed interfaces. If you want any of this exported into an Ansible-ready inventory or a “rebuild from zero” doc, just say the word.
