# 🤖 SkyNet – Full Topology & Infrastructure Map (Prod 1 – OS & Hostname Finalization)

This is the definitive **Prod 1** configuration of **SkyNet**, now incorporating:

- Accurate OS assignments across Raspberry Pi devices
- Updated hostnames: `raspi3.home` and `raspi4.home`
- Dockge deployed on both `raspi5` and `nas`
- Pop box and work laptops isolated on VLAN 10 switch
- Smart TV and Google TV grouped on unmanaged switch (VLAN 20)
- Reverse proxy, DNS, and container visibility fully operational

---

## 🧠 Node Directory & DNS

| Hostname     | DNS Name            | IP Address     | OS                  | Role & Key Services                                      |
|--------------|---------------------|----------------|---------------------|----------------------------------------------------------|
| `popbox`     | `popbox.home`       | 10.10.10.10    | Pop!_OS             | Admin control plane: NGINX Proxy, Homarr, dnsmasq        |
| `raspi5`     | `raspi5.home`       | 10.10.20.14    | Raspberry Pi OS     | Dockge, Uptime Kuma, Mosquitto (VLAN 20)                 |
|              | `dockge.home`       |                |                     | Web UI for raspi5 containers (port 5001)                 |
| `raspi3`     | `raspi3.home`       | 10.10.30.53    | DietPi              | Pi-hole + Unbound DNS resolver (VLAN 30)                 |
| `raspi4`     | `raspi4.home`       | 10.10.30.11    | DietPi              | AdGuard, NodeRED, Zigbee2MQTT, Prometheus (VLAN 30)      |
| `nas`        | `nas.home`          | 10.10.20.10    | Synology DSM        | Plex, Home Assistant, Dockge, NFS/SMB shares (VLAN 20)   |
|              | `assist.home`       |                |                     | HA UI proxy → `nas:8123`                                 |
|              | `plex.home`         |                |                     | Plex UI proxy → `nas:32400`                              |
|              | `dockge-nas.home`   |                |                     | Dockge UI for NAS containers (port 5002)                 |
| `printer`    | `printer.home`      | 10.10.20.21    | N/A (HW device)     | Office printing over VLAN 20                             |
| `smarttv`    | `smarttv.home`      | 10.10.20.30    | Google TV           | Plex client + streamer (on media switch)                 |
| `googletv`   | `googletv.home`     | 10.10.20.31    | Google TV           | HDMI dongle, casting (on media switch)                   |
| `router`     | `router.home`       | 10.10.99.2     | TP-Link AX6600      | Wi-Fi SSID hub + VLAN trunking uplink                    |
| `switch`     | `switch.home`       | 10.10.99.1     | Tenda TEG208E       | Trunk-aware switch for all VLAN routing                  |

---

## 🧩 VLAN Architecture

| VLAN ID | Name      | Subnet           | Purpose                          | DHCP Source           |
|---------|-----------|------------------|-----------------------------------|------------------------|
| 10      | Admin     | 10.10.10.0/24    | Trusted devices + orchestration  | `dnsmasq` on `popbox`  |
| 20      | Services  | 10.10.20.0/24    | NAS, Dockge, Plex, TVs, Raspi5   | Static / reserved      |
| 30      | IoT       | 10.10.30.0/24    | DNS relays, smart plugs, sensors | Relay or static        |
| 40      | Guest     | 10.10.40.0/24    | Isolated Wi-Fi clients           | Router fallback        |
| 99      | Mgmt      | 10.10.99.0/24    | Switch/router config only        | Static                 |

---

## 📶 SSID-to-VLAN Mapping

| SSID         | VLAN | Band   | Visibility | Devices Served                        |
|--------------|------|--------|------------|----------------------------------------|
| `Homers`     | 10   | 5GHz   | Hidden     | Work laptops, Pop box (trusted)        |
| `Spicy Mac`  | 20   | 5GHz   | Visible    | Phones, TVs, tablets, Plex devices     |
| `Smarties`   | 30   | 2.4GHz | Hidden     | Zigbee + ESPHome-based IoT nodes       |

---

## 🔌 Switch Ports – TEG208E Layout

| Port | Function                          | VLAN | Tag Mode  |
|------|-----------------------------------|------|-----------|
| 1    | Pop box + work laptops switch     | 10   | Untagged  |
| 2    | `raspi5`                          | 20   | Untagged  |
| 3    | `nas`                             | 20   | Untagged  |
| 4    | `raspi3`                          | 30   | Untagged  |
| 5    | `raspi4`                          | 30   | Untagged  |
| 6    | Media switch: Smart TV + streamer | 20   | Untagged  |
| 7    | `printer`                         | 20   | Untagged  |
| 8    | Uplink to AX6600 router           | All  | Tagged    |

---

## 🔐 Reverse Proxy (NGINX Proxy Manager on `popbox`)

| Friendly URL             | Internal Target         | Purpose                                    |
|--------------------------|--------------------------|---------------------------------------------|
| `https://dashboard.home` | `popbox:7575`            | Homarr dashboard                            |
| `https://assist.home`    | `nas:8123`               | Home Assistant                              |
| `https://plex.home`      | `nas:32400`              | Plex Web UI                                 |
| `https://dockge.home`    | `raspi5:5001`            | Dockge for `raspi5` containers              |
| `https://dockge-nas.home`| `nas:5002`               | Dockge for `nas.home` containers            |
| `https://kuma.home`      | `raspi5:3001`            | Uptime Kuma                                 |
| `https://raspi3.home`    | `raspi3`                 | Pi-hole Admin                               |
| `https://raspi4.home`    | `raspi4:8053`            | AdGuard Home                                |
| `https://printer.home`   | `printer`                | Printer Web UI (if available)               |

---

## 🧭 DNS Map & Resolution Strategy

- Authoritative DNS: `dnsmasq` on `popbox.home`
- Primary resolver: `raspi3.home` → Pi-hole + Unbound
- Secondary resolver: `raspi4.home` → AdGuard Home
- All entries managed via Ansible and statically mapped
- Aliases like `assist.home`, `dockge.home`, and `plex.home` route via NGINX proxy

---

SkyNet now reflects your clean naming conventions, lean OS footprint, hardened VLAN boundaries, and a sharp separation of trusted vs. service nodes.

Let me know if you’d like a provisioning checklist, repo-ready `host_vars`, or a Markdown export of this config to throw into version control. SkyNet’s not just online—it’s production-grade.
