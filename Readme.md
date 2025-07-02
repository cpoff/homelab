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

# 🔐 UFW Firewall Configuration for SkyNet – Full Annotated Rule Sets
# Applied to: Devices running Raspberry Pi OS, Pop!_OS, DietPi (excludes NAS)
# Method: Provision via Ansible (preferred) or manual script on device startup

# =======================================
# 🧠 popbox.home (Admin Node - VLAN 10)
# OS: Pop!_OS
# =======================================

sudo ufw default deny incoming            # Drop all unsolicited inbound packets
sudo ufw default allow outgoing           # Allow all outbound by default

sudo ufw allow ssh                        # Enable SSH (port 22) for remote login
sudo ufw allow 80,443/tcp                 # NGINX: reverse proxy frontend (HTTP/S)
sudo ufw allow 7575/tcp                   # Homarr dashboard (local admin UI)

# Allow VLAN 20 devices (e.g. Chromebooks, phones, HA) to reach reverse proxy
sudo ufw allow from 10.10.20.0/24 to any port 443 proto tcp \
  comment 'Allow VLAN 20 clients access to TLS proxy'

# Optional: allow DNS requests from LAN
sudo ufw allow 53                        # dnsmasq responder on popbox (optional)

# =======================================
# 📦 raspi5.home (Containers + Telemetry - VLAN 20)
# OS: Raspberry Pi OS
# =======================================

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                        # SSH for administration
sudo ufw allow 5001/tcp                   # Dockge container manager UI
sudo ufw allow 3001/tcp                   # Uptime Kuma dashboard
sudo ufw allow 1883/tcp                   # Mosquitto MQTT broker (if used)

# Allow access to Dockge from Popbox (Admin VLAN)
sudo ufw allow from 10.10.10.0/24 to any port 5001,3001 proto tcp \
  comment 'Admin access to Dockge + Kuma from VLAN 10'

# =======================================
# 🎯 raspi3.home (Pi-hole + Unbound - VLAN 30)
# OS: DietPi
# =======================================

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                        # Headless management
sudo ufw allow 53                         # DNS over TCP/UDP
sudo ufw allow 80                         # Pi-hole Web UI

# Allow queries from Admin (popbox), Services (Chromebooks, phones), HA
sudo ufw allow from 10.10.10.0/24         # Admin VLAN
sudo ufw allow from 10.10.20.0/24         # Services VLAN

# =======================================
# 🧮 raspi4.home (AdGuard Home + Zigbee - VLAN 30)
# OS: DietPi
# =======================================

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh                        # Remote config terminal
sudo ufw allow 8053/tcp                   # AdGuard Home UI
sudo ufw allow 53                         # DNS over TCP/UDP

# Allow visibility from Admin + Services zones
sudo ufw allow from 10.10.10.0/24         # Admin
sudo ufw allow from 10.10.20.0/24         # Clients + HA

# =======================================
# 🧠 Notes
# =======================================
# - Synology NAS is managed via its own firewall system (not UFW)
# - Printers, TVs, Chromebooks, and mobile devices don’t run UFW-capable OS
# - Inter-VLAN permissions enforced via router ACLs (not handled in UFW)
# - Consider enabling UFW logging: sudo ufw logging on
# - For Ansible, translate each rule into tasks using ufw Ansible module or shell tasks


---

## 🔹 Footnotes – Configuration Method Keys

- **¹** 🖐️ Configured manually via GUI or CLI (e.g. DSM, router, switch)
- **²** 🤖 Provisioned using Ansible (host_vars, roles)
- **³** 📝 Configured via static file (e.g. compose, YAML, bash scripts)
- **⁴** 🛡️ Secured via DSM Firewall or GUI-native firewall

---

SkyNet’s configuration strategy is now codified—clearly separating manual setup, automation pipelines, and GUI-managed interfaces. If you want any of this exported into an Ansible-ready inventory or a “rebuild from zero” doc, just say the word.
