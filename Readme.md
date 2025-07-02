# 🤖 SkyNet – Full Topology & Infrastructure Map (Prod 1 + Personal Devices + IoT Control Paths)

This is the updated, complete snapshot of **SkyNet – Prod 1**, now incorporating:

- **Chromebooks** as trusted personal devices on VLAN 20
- IoT access pathways for **Home Assistant** and **your phone**
- A new section defining **UFW firewall rules per device role**
- Clean VLAN segmentation with secure and purposeful inter-VLAN allowances

---

## 🧠 Node Directory & DNS

| Hostname       | DNS Name            | IP Address     | OS / Type          | Role & Notes                                          |
|----------------|---------------------|----------------|---------------------|--------------------------------------------------------|
| `popbox`       | `popbox.home`       | 10.10.10.10    | Pop!_OS             | Admin control plane, NGINX, dnsmasq, Homarr           |
| `raspi5`       | `raspi5.home`       | 10.10.20.14    | Raspberry Pi OS     | Dockge, Uptime Kuma, Mosquitto                        |
| `raspi3`       | `raspi3.home`       | 10.10.30.53    | DietPi              | Pi-hole + Unbound DNS resolver                        |
| `raspi4`       | `raspi4.home`       | 10.10.30.11    | DietPi              | AdGuard Home, Zigbee2MQTT, Prometheus                 |
| `nas`          | `nas.home`          | 10.10.20.10    | Synology DSM        | Plex, Home Assistant, Dockge, shared media            |
| `printer`      | `printer.home`      | 10.10.20.21    | Printer HW          | AirPrint over LAN                                     |
| `smarttv`      | `smarttv.home`      | 10.10.20.30    | Google TV           | Plex app, casting target                              |
| `googletv`     | `googletv.home`     | 10.10.20.31    | Google TV HDMI      | Primary streaming HDMI device                         |
| `chromebook1`  | `cb1.home`          | 10.10.20.41    | ChromeOS            | Personal laptop                                       |
| `chromebook2`  | `cb2.home`          | 10.10.20.42    | ChromeOS            | Personal laptop                                       |
| `router`       | `router.home`       | 10.10.99.2     | TP-Link AX6600      | VLAN SSID bridge + uplink                             |
| `switch`       | `switch.home`       | 10.10.99.1     | Tenda TEG208E       | Core managed switch                                   |

---

## 🧩 VLAN Layout

| VLAN ID | Name      | Subnet           | Purpose                                      |
|---------|-----------|------------------|-----------------------------------------------|
| 10      | Admin     | 10.10.10.0/24    | Trusted: Pop box, orchestration               |
| 20      | Services  | 10.10.20.0/24    | NAS, Dockge, Plex, TVs, personal laptops      |
| 30      | IoT       | 10.10.30.0/24    | Kasa plugs, Zigbee, DNS relays                |
| 40      | Guest     | 10.10.40.0/24    | Internet-only clients                         |
| 99      | Mgmt      | 10.10.99.0/24    | Switch/router config                          |

> IoT VLAN (30) remains isolated but accessible from VLAN 20 for HA and mobile control.

---

## 📶 SSID-to-VLAN Mapping

| SSID         | VLAN | Band   | Devices Served                             |
|--------------|------|--------|--------------------------------------------|
| `Homers`     | 10   | 5GHz   | Pop box, work laptops                      |
| `Spicy Mac`  | 20   | 5GHz   | Chromebooks, phones, TVs, tablets          |
| `Smarties`   | 30   | 2.4GHz | Smart plugs, sensors, Zigbee devices       |

---

## 🔌 Switch Port Assignments (TEG208E)

| Port | Connected Devices                  | VLAN | Tag Mode  |
|------|------------------------------------|------|-----------|
| 1    | Pop box + work laptops (trusted)   | 10   | Untagged  |
| 2    | `raspi5`                           | 20   | Untagged  |
| 3    | `nas`                              | 20   | Untagged  |
| 4    | `raspi3`                           | 30   | Untagged  |
| 5    | `raspi4`                           | 30   | Untagged  |
| 6    | TVs + Chromecast (unmanaged switch)| 20   | Untagged  |
| 7    | `printer`                          | 20   | Untagged  |
| 8    | Router uplink                      | All  | Tagged    |

---

## 🔐 Reverse Proxy (NPM on `popbox`)

| URL                        | Backend             | Description                           |
|----------------------------|---------------------|----------------------------------------|
| `https://assist.home`      | `nas:8123`          | Home Assistant                         |
| `https://plex.home`        | `nas:32400`         | Plex Web UI                            |
| `https://dockge.home`      | `raspi5:5001`       | Dockge for `raspi5` containers         |
| `https://dockge-nas.home`  | `nas:5002`          | Dockge for `nas` containers            |
| `https://kuma.home`        | `raspi5:3001`       | Uptime Kuma                            |
| `https://raspi3.home`      | `raspi3`            | Pi-hole admin                          |
| `https://raspi4.home`      | `raspi4:8053`       | AdGuard Home                           |
| `https://printer.home`     | `printer`           | Printer UI (if applicable)             |

---

## 🔐 Home Assistant + IoT Control Paths

| Source            | Destination Subnet | Access Needed                           |
|-------------------|---------------------|------------------------------------------|
| Home Assistant    | VLAN 30 (IoT)       | Ports: 9999 (TCP/UDP), mDNS, HTTP       |
| Your Phone (SSID) | VLAN 30 (IoT)       | Kasa control app → smart plugs          |

> These flows require a router/firewall rule to allow VLAN 20 → VLAN 30 on select ports.

---

## 🛡️ UFW Firewall Rules by Device

Each device uses UFW to enforce its own security. Here's a recommended set per node:

---

### 🔹 `popbox.home` (Admin Core – VLAN 10)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 7575/tcp    # Homarr
sudo ufw allow 80,443/tcp  # NGINX proxy
sudo ufw allow from 10.10.20.0/24 to any port 443 comment 'Allow HA access to proxied services'
```

---

### 🔹 `raspi5.home` (Services – VLAN 20)
```bash
sudo ufw default deny incoming
sudo ufw allow 22/tcp        # SSH
sudo ufw allow 5001/tcp      # Dockge UI
sudo ufw allow 3001/tcp      # Uptime Kuma
sudo ufw allow from 10.10.10.10 to any port 5001  # Allow admin access from popbox
```

---

### 🔹 `raspi3.home` (Pi-hole – VLAN 30)
```bash
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 53/tcp        # DNS
sudo ufw allow 53/udp
sudo ufw allow 80/tcp        # Admin UI
sudo ufw allow from 10.10.10.0/24
sudo ufw allow from 10.10.20.0/24
```

---

### 🔹 `raspi4.home` (AdGuard Home – VLAN 30)
```bash
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 8053/tcp      # AdGuard UI
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow from 10.10.10.0/24
sudo ufw allow from 10.10.20.0/24
```

---

### 🔹 `nas.home` (Plex + Home Assistant – VLAN 20)

Handled via Synology firewall UI or GUI policy manager:
- Allow inbound on ports:
  - 8123 (HA)
  - 32400 (Plex)
  - 5002 (Dockge)
- Allow outbound to VLAN 30:
  - TCP/UDP 9999, 80, 443, 554, 5353
  - Optional: mDNS multicast (224.0.0.251) if needed

---

SkyNet’s boundaries remain tight—and now, its orchestration nodes and personal clients have deliberate, secure paths to interact with your smart devices. Let me know if you want a `uf
