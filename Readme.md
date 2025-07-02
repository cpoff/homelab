# 🤖 SkyNet – Full Topology & Configuration Map  
📌 **Prod 2 Final Snapshot (with Mosquitto MQTT + Full Config Integration)**

This is the complete and up-to-date map of **SkyNet**, designed for clarity, easy installation, and long-term maintainability. It includes:

- Full node roles, VLANs, and config strategy
- UFW firewall rules (fully annotated)
- DNS + DHCP provisioning
- Container orchestration via Dockge
- Secure reverse proxy routing
- IoT device control paths (no mDNS reflection)
- **New:** Mosquitto MQTT hosted on `raspi5`

---

## 🧠 Node Directory + Configuration Overview

| Hostname       | IP Address     | OS / Type           | Roles & Services                                                   | Config Method(s)               |
|----------------|----------------|----------------------|----------------------------------------------------------------------|--------------------------------|
| `popbox`       | 10.10.10.10    | Pop!_OS              | Admin orchestrator: Homarr, dnsmasq, NGINX Proxy                    | 🤖 Ansible + 📝 Compose         |
| `raspi5`       | 10.10.20.14    | Raspberry Pi OS      | Dockge, Uptime Kuma, **Mosquitto MQTT**                             | 🤖 Ansible + 📝 Compose + UFW   |
| `raspi3`       | 10.10.30.53    | DietPi               | Pi-hole + Unbound DNS                                               | 🤖 Ansible + 📝 Static config   |
| `raspi4`       | 10.10.30.11    | DietPi               | AdGuard, NodeRED, Zigbee2MQTT, Prometheus                           | 🤖 Ansible + 📝 Compose         |
| `nas`          | 10.10.20.10    | Synology DSM         | Plex, Home Assistant, Dockge-NAS                                    | 🛡️ DSM GUI + Docker GUI        |
| `printer`      | 10.10.20.21    | HW Device            | AirPrint-enabled printer                                            | 🖐️ DHCP Reservation            |
| `smarttv`      | 10.10.20.30    | Google TV            | Plex client, casting                                                | 🖐️ IP Reservation              |
| `googletv`     | 10.10.20.31    | Google TV HDMI       | Primary streamer                                                    | 🖐️ IP Reservation              |
| `chromebook1`  | 10.10.20.41    | ChromeOS             | Personal laptop                                                     | 🖐️ MAC reservation             |
| `chromebook2`  | 10.10.20.42    | ChromeOS             | Personal laptop                                                     | 🖐️ MAC reservation             |
| `router`       | 10.10.99.2     | TP-Link AX6600       | VLAN-aware SSIDs + fallback DHCP                                    | 🖐️ Web GUI                     |
| `switch`       | 10.10.99.1     | Tenda TEG208E        | Core VLAN segmentation                                              | 🖐️ Web GUI                     |

---

## 🧩 VLAN Structure

| VLAN | Name      | Subnet           | Purpose                                         |
|------|-----------|------------------|-------------------------------------------------|
| 10   | Admin     | 10.10.10.0/24    | Trusted orchestration + admin tools             |
| 20   | Services  | 10.10.20.0/24    | NAS, Dockge, Plex, MQTT, Chromebooks            |
| 30   | IoT       | 10.10.30.0/24    | Smart plugs, Zigbee, DNS filters                |
| 40   | Guest     | 10.10.40.0/24    | Internet-only clients                           |
| 99   | Mgmt      | 10.10.99.0/24    | Static routing and VLAN trunking                |

**Switch Port Overview**

| Port | Device(s)                        | VLAN | Tag Mode  |
|------|----------------------------------|------|-----------|
| 1    | Pop box + work switch            | 10   | Untagged  |
| 2    | `raspi5`                         | 20   | Untagged  |
| 3    | `nas`                            | 20   | Untagged  |
| 4    | `raspi3`                         | 30   | Untagged  |
| 5    | `raspi4`                         | 30   | Untagged  |
| 6    | TV + GoogleTV unmanaged switch   | 20   | Untagged  |
| 7    | `printer`                        | 20   | Untagged  |
| 8    | Router uplink                    | All  | Tagged    |

---

## 🔐 UFW Firewall Rules (Fully Annotated)

### `popbox.home`

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh                                 # Admin terminal
sudo ufw allow 80,443/tcp                           # NGINX reverse proxy
sudo ufw allow 7575/tcp                             # Homarr UI
sudo ufw allow from 10.10.20.0/24 to any port 443 proto tcp \
  comment 'Proxy access from VLAN 20 clients'
```

---

### `raspi5.home` (Now with MQTT)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh                                  # Remote management
sudo ufw allow 5001/tcp                             # Dockge
sudo ufw allow 3001/tcp                             # Uptime Kuma
sudo ufw allow 1883/tcp                             # Mosquitto MQTT
sudo ufw allow from 10.10.30.0/24 to any port 1883 proto tcp \
  comment 'Allow IoT devices to publish via MQTT'
sudo ufw allow from 10.10.20.10 to any port 1883 proto tcp \
  comment 'Allow Home Assistant (NAS) to subscribe to Mosquitto'
```

---

### `raspi3.home`

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 53                                   # DNS over TCP/UDP
sudo ufw allow 80                                   # Pi-hole Web UI
sudo ufw allow from 10.10.10.0/24                   # Admin VLAN
sudo ufw allow from 10.10.20.0/24                   # Clients, HA
```

---

### `raspi4.home`

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8053/tcp                             # AdGuard Web UI
sudo ufw allow 53                                   # DNS TCP/UDP
sudo ufw allow from 10.10.10.0/24                   # Admin
sudo ufw allow from 10.10.20.0/24                   # HA + Clients
```

---

## 📡 MQTT Integration

| Function         | Detail                                                    |
|------------------|-----------------------------------------------------------|
| Broker Host      | `raspi5.home` (VLAN 20)                                   |
| DNS Alias        | `mqtt.home` via `dnsmasq`                                 |
| Ports Open       | `1883/tcp`                                                |
| Access From      | `Home Assistant` (NAS) + IoT devices (VLAN 30)            |
| Config Method    | 📝 `docker-compose.yml` under Ansible role or manually    |
| HA Config Snip   | See `configuration.yaml` under `mqtt:` integration        |

---

## 📲 Inter-VLAN Routing (No mDNS Bridging)

| Source            | Target VLAN | Ports                    | Purpose                      |
|-------------------|-------------|---------------------------|-------------------------------|
| `nas` (HA)        | VLAN 30     | 9999, 80, 554, 443        | Kasa + Zigbee MQTT control   |
| Phones (VLAN 20)  | VLAN 30     | 9999                      | Kasa app control             |

_No Avahi or multicast reflection used. All traffic is routed and permissioned explicitly._

---

## 🧭 DNS & DHCP

- `.home` domain managed via:
  - `dnsmasq` on `popbox` (authoritative)
  - DNS filtering via `raspi3` (Pi-hole) + `raspi4` (AdGuard)
- Static reservations defined via:
  - 🤖 `host_vars/` in Ansible
  - 🖐️ Router GUI MAC bindings
- Split DNS optional for remote clients (e.g. via Tailscale)

---

SkyNet is fully segmented, routable, monitorable, documented, and extensible—with install clarity and administrative sanity baked in. If you want this exported as a Markdown file, install script, or Ansible skeleton, I’ve got you covered.
