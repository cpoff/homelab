# 🤖 SkyNet – Full Topology & Configuration Map  
📌 **Prod 2 Final Snapshot**  
_With full configuration details for each component, UFW rules, VLANs, DNS, IoT access paths, and config methods_

---

## 🧠 Node Directory + Configuration Strategy

| Hostname       | IP Address     | OS / Type           | Roles & Services                                         | Configured By |
|----------------|----------------|----------------------|----------------------------------------------------------|----------------|
| `popbox`       | 10.10.10.10    | Pop!_OS              | Admin orchestrator: NGINX Proxy, dnsmasq, Homarr         | 🤖 Ansible: `popbox.yml`<br>📝 `dnsmasq.conf`, NGINX, `docker-compose` |
| `raspi5`       | 10.10.20.14    | Raspberry Pi OS      | Dockge, Uptime Kuma, Mosquitto MQTT                      | 🤖 Ansible: `raspi5.yml`<br>📝 `docker-compose.yml`, UFW rules |
| `raspi3`       | 10.10.30.53    | DietPi               | Pi-hole + Unbound DNS filtering                          | 🤖 Ansible: `raspi3.yml`<br>📝 Pi-hole backup import + static config |
| `raspi4`       | 10.10.30.11    | DietPi               | AdGuard Home, Zigbee2MQTT, Prometheus, NodeRED           | 🤖 Ansible: `raspi4.yml`<br>📝 Zigbee2MQTT via Compose |
| `nas`          | 10.10.20.10    | Synology DSM         | Plex, Home Assistant, Dockge-NAS                         | 🛡️ DSM Firewall + GUI Config<br>📝 Docker GUI, shared folder mounts |
| `printer`      | 10.10.20.21    | HW Device            | LAN-connected printer w/ AirPrint                        | 🖐️ Manual via IP + optional UI |
| `smarttv`      | 10.10.20.30    | Google TV            | Plex app, Chromecast endpoint                            | 🖐️ DHCP reservation, static DNS |
| `googletv`     | 10.10.20.31    | Google TV HDMI       | HDMI streamer (Kasa + Plex App)                          | 🖐️ IP reservation only |
| `chromebook1`  | 10.10.20.41    | ChromeOS             | Personal device (Wi-Fi via `Spicy Mac`)                  | 🖐️ Manual MAC binding on router |
| `chromebook2`  | 10.10.20.42    | ChromeOS             | Personal device                                          | 🖐️ Same as above |
| `router`       | 10.10.99.2     | TP-Link AX6600       | Wi-Fi AP, VLAN trunk uplink                              | 🖐️ GUI SSID to VLAN bindings<br>📝 Static routes |
| `switch`       | 10.10.99.1     | Tenda TEG208E        | VLAN trunking + per-port assignments                     | 🖐️ VLAN map in GUI or CSV template |

---

## 🧩 VLAN Schema + Physical Port Assignments

| VLAN | Name     | Subnet         | Role                   | Set via |
|------|----------|----------------|-------------------------|---------|
| 10   | Admin    | 10.10.10.0/24  | Orchestration, trusted | 🖐️ Switch ports 1 / SSID `Homers` |
| 20   | Services | 10.10.20.0/24  | NAS, Plex, Dockge      | 🖐️ Ports 2,3,6,7 / SSID `Spicy Mac` |
| 30   | IoT      | 10.10.30.0/24  | Smart plugs, Zigbee    | 🖐️ Ports 4,5 / SSID `Smarties` |
| 40   | Guest    | 10.10.40.0/24  | Internet-only clients  | 🖐️ Hidden SSID, fallback VLAN |
| 99   | Mgmt     | 10.10.99.0/24  | Router/switch control  | 🖐️ Static, no DHCP |

**Switch Port Map (TEG208E):**  
```text
Port 1: Admin switch     → VLAN 10 untagged  
Port 2: raspi5           → VLAN 20 untagged  
Port 3: NAS              → VLAN 20 untagged  
Port 4: raspi3           → VLAN 30 untagged  
Port 5: raspi4           → VLAN 30 untagged  
Port 6: Media switch     → VLAN 20 untagged  
Port 7: Printer          → VLAN 20 untagged  
Port 8: Router uplink    → Tagged VLANs: 10,20,30,40,99  
```

---

## 🔐 Reverse Proxy Routes (NGINX)

| URL                        | Destination             | Setup          |
|----------------------------|--------------------------|----------------|
| `https://assist.home`      | `nas:8123`               | 🤖 `reverse_proxy.yml` |
| `https://dockge.home`      | `raspi5:5001`            | 🤖 `docker-compose` |
| `https://dockge-nas.home`  | `nas:5002`               | 🛡️ DSM GUI config |
| `https://kuma.home`        | `raspi5:3001`            | 🤖 Auto-Discover |
| `https://dashboard.home`   | `popbox:7575`            | 🤖 Ansible role |
| `https://raspi3.home`      | `raspi3`                 | Pi-hole UI     |
| `https://raspi4.home`      | `raspi4:8053`            | AdGuard UI     |

---

## 🔐 UFW RULE SETS — FULLY ANNOTATED

### `popbox.home` (VLAN 10)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh                     # Secure shell access
sudo ufw allow 80,443/tcp              # NGINX HTTP/S ports
sudo ufw allow 7575/tcp                # Homarr admin UI
sudo ufw allow from 10.10.20.0/24 to any port 443 proto tcp \
  comment 'VLAN 20 → Proxy access'
```

---

### `raspi5.home` (VLAN 20)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh                    # Headless terminal
sudo ufw allow 5001/tcp               # Dockge UI
sudo ufw allow 3001/tcp               # Uptime Kuma
sudo ufw allow 1883/tcp               # MQTT Broker
sudo ufw allow from 10.10.10.0/24 to any port 5001,3001 proto tcp \
  comment 'Admin → Dockge + Kuma access'
```

---

### `raspi3.home` (VLAN 30)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 53                     # DNS over UDP/TCP
sudo ufw allow 80                     # Pi-hole Web UI
sudo ufw allow from 10.10.10.0/24     # Admin → DNS
sudo ufw allow from 10.10.20.0/24     # Clients + HA → DNS
```

---

### `raspi4.home` (VLAN 30)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8053/tcp               # AdGuard Home UI
sudo ufw allow 53                     # DNS support
sudo ufw allow from 10.10.10.0/24     # Admin VLAN access
sudo ufw allow from 10.10.20.0/24     # Client / HA VLAN
```

---

## 📲 Inter-VLAN Access (IoT Control)

| Source Device      | Destination (VLAN 30) | Ports Allowed               | Setup          |
|--------------------|------------------------|------------------------------|----------------|
| Home Assistant     | Kasa smart plugs       | TCP/UDP 9999, 80, 554, 443   | 🖐️ Router ACL   |
| Phone (VLAN 20)    | IoT devices            | TCP/UDP 9999                 | 🖐️ Router ACL   |
| Optional mDNS Rep. | Broadcast 224.0.0.251  | UDP 5353                     | 📝 `avahi` or `mdns-repeater` |

---

## 🧭 DNS & DHCP Design

| Role                        | Setup                       |
|-----------------------------|------------------------------|
| `.home` zone authority      | 🤖 `dnsmasq` on `popbox`     |
| Recursive resolver          | 📝 Unbound (`raspi3`)        |
| Backup filter DNS           | 📝 AdGuard (`raspi4`)        |
| Static leases               | 🤖 Ansible `host_vars/`      |
| Dynamic DHCP fallback       | 🖐️ Router (VLAN 40 guests)   |


---

## 🔹 Footnotes – Configuration Method Keys

- **¹** 🖐️ Configured manually via GUI or CLI (e.g. DSM, router, switch)
- **²** 🤖 Provisioned using Ansible (host_vars, roles)
- **³** 📝 Configured via static file (e.g. compose, YAML, bash scripts)
- **⁴** 🛡️ Secured via DSM Firewall or GUI-native firewall

---

SkyNet’s configuration strategy is now codified—clearly separating manual setup, automation pipelines, and GUI-managed interfaces. If you want any of this exported into an Ansible-ready inventory or a “rebuild from zero” doc, just say the word.
