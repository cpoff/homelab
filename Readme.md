# ☁️ SkyNet Topology Overview

---

## 🖥️ Device Lineup & Local DNS

| Hostname     | DNS Name           | IP Address     | Role / Function               | Key Services & Apps                                             |
|--------------|--------------------|----------------|-------------------------------|-----------------------------------------------------------------|
| `popbox`     | `popbox.home`      | 10.10.10.10    | Admin Core / Reverse Proxy    | Ansible, Homarr, Portainer, dnsmasq, NGINX Proxy Manager, Netdata |
| `raspi5`     | `raspi5.home`      | 10.10.20.14    | Container Node                | Vaultwarden, Mosquitto, Uptime Kuma, Home Assistant (opt)       |
| `nas`        | `nas.home`         | 10.10.20.10    | File & Media Server           | Plex, Synology Drive, Tautulli (opt), SMB/NFS Shares            |
| `raspi3`     | `dns.home`         | 10.10.30.53    | DNS Relay + Filtering Node    | Pi-hole, Unbound, Tailscale                                     |
| `raspi4`     | `pi4util.home`     | 10.10.30.11    | Utility Node / Telemetry      | AdGuard (8053), Zigbee2MQTT, NodeRED, Prometheus Exporters      |
| `router`     | `router.home`      | 10.10.99.2     | Edge Gateway / DHCP fallback  | WAN uplink, VLAN bridge, Wi-Fi SSIDs                            |
| `switch`     | `switch.home`      | 10.10.99.1     | Core VLAN Switch              | Tagged uplinks, untagged port access for each VLAN              |

---

## 🧩 VLAN Configuration

| VLAN ID | Name        | Subnet           | Purpose                              | DHCP Source              |
|---------|-------------|------------------|---------------------------------------|---------------------------|
| 10      | Admin       | 10.10.10.0/24    | Secure orchestration & control plane | `dnsmasq` on `popbox.home` |
| 20      | Services    | 10.10.20.0/24    | Containers, NAS, web UIs             | DHCP reservation or relay |
| 30      | IoT         | 10.10.30.0/24    | Smart plugs, DNS relays, Zigbee      | DHCP relay / static maps  |
| 40      | Guest       | 10.10.40.0/24    | Internet-only network                | Router (fallback DHCP)    |
| 99      | Mgmt        | 10.10.99.0/24    | Router, switch, AP management        | Static IPs only           |

VLAN trunking is enforced from `router` → `switch`, then tagged/untagged per-port.

---

## 📶 Wireless SSIDs and VLAN Mapping

| SSID Name     | Band     | VLAN | Broadcast | Auth Method         | Device Class                     |
|---------------|----------|------|-----------|----------------------|----------------------------------|
| `AdminLAN`    | 5GHz     | 10   | Hidden    | WPA2/3 Enterprise    | Admin laptops, tablets           |
| `HomeDevices` | 5GHz     | 20   | Visible   | WPA2 Personal        | Phones, desktops, streaming gear |
| `SmartMesh`   | 2.4GHz   | 30   | Hidden    | WPA2 Personal        | IoT sensors, smart plugs         |

> **Note:** TP-Link Archer AX90 does not support per-SSID VLAN tagging natively. SSID traffic segmentation must happen via switch trunking or upgrading to VLAN-aware APs like the Omada EAP series.

---

## 🔐 HTTPS Access via NGINX Proxy Manager (`popbox.home`)

All proxied services are accessible via `https://<name>.home`:

| Service            | Reverse Proxy URL           | Internal Host             |
|--------------------|-----------------------------|----------------------------|
| Homarr             | `https://dashboard.home`    | `popbox.home:7575`         |
| Vaultwarden        | `https://vaultwarden.home`  | `raspi5.home:80`           |
| Uptime Kuma        | `https://kuma.home`         | `raspi5.home:3001`         |
| Pi-hole            | `https://dns.home`          | `dns.home`                 |
| AdGuard            | `https://adguard.home`      | `pi4util.home:8053`        |

SSL certs via Let's Encrypt DNS-01 challenge or internal CA. TLS enforced globally.

---

## 🧭 DNS Handling

- **Authoritative DNS & DHCP**: `popbox.home` via `dnsmasq`
- **DNS Filtering**: Primary = `dns.home` (Pi-hole), Secondary = `pi4util.home` (AdGuard Home)
- **Name Resolution**: `.home` domain mapped for all devices; optional entries in `/etc/hosts` or pushed via Ansible

---

If you'd like, I can bundle this into a printable `.md` file, generate a visual network map, or scaffold it into your playbook repo under `docs/topology.md`. SkyNet is now encrypted, segmented, and fully self-aware.
