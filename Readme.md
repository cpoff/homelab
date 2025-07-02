# ☁️ SkyNet Homelab Topology

---

## 🖥️ Device Lineup

| Hostname     | Local DNS Name        | IP Address     | Hardware / OS           | Role                       | Services                                                    |
|--------------|-----------------------|----------------|--------------------------|----------------------------|-------------------------------------------------------------|
| `popbox`     | `popbox.home`         | 10.10.10.10    | Dell XPS / Pop!_OS       | Admin core / orchestration| Ansible, Docker, Portainer, Homarr, dnsmasq, Netdata       |
| `raspi5`     | `raspi5.home`         | 10.10.20.14    | Raspberry Pi 5           | Containers + IoT stack     | Vaultwarden, Mosquitto, Uptime Kuma, Home Assistant (opt)  |
| `nas`        | `nas.home`            | 10.10.20.10    | Synology NAS             | Storage & media            | Plex, SMB/NFS, Synology Drive, Tautulli (opt)              |
| `raspi3`     | `dns.home`            | 10.10.30.53    | Raspberry Pi 3           | DNS relay & filtering      | Pi-hole, Unbound, Tailscale                                |
| `raspi4`     | `pi4util.home`        | 10.10.30.11    | Raspberry Pi 4           | Utility / testbed node     | AdGuard (8053), NodeRED, Zigbee2MQTT, Prometheus           |
| `router`     | `router.home`         | 10.10.99.2     | TP-Link AX6600 (AX90)    | Core router/gateway        | LAN routing, DHCP relay (opt), SSID broadcast              |
| `switch`     | `switch.home`         | 10.10.99.1     | Tenda TEG208E switch     | VLAN segmentation          | Tagged uplinks, untagged access ports                      |

---

## 🧩 VLAN Configuration

| VLAN ID | Name        | Subnet           | Purpose                              | DHCP Source        |
|---------|-------------|------------------|---------------------------------------|---------------------|
| 10      | Admin       | 10.10.10.0/24    | Management and orchestration layer   | dnsmasq on `popbox.home` |
| 20      | Services    | 10.10.20.0/24    | Containers, NAS, dashboard access    | Relay or static     |
| 30      | IoT         | 10.10.30.0/24    | DNS, smart plugs, Zigbee relays      | Relay or static     |
| 40      | Guest       | 10.10.40.0/24    | Visitor Wi-Fi                        | Router fallback     |
| 99      | Management  | 10.10.99.0/24    | Router/switch/infra config access    | Static-only         |

---

## 📶 Wireless SSID to VLAN Assignments

| SSID         | Band     | VLAN | Broadcast | Auth Type          | Devices Targeted                  |
|--------------|----------|------|-----------|---------------------|------------------------------------|
| AdminLAN     | 5GHz     | 10   | Hidden    | WPA2/3 Enterprise   | Admin devices, on-call laptops     |
| HomeDevices  | 5GHz     | 20   | Visible   | WPA2 Personal       | Phones, Plex clients, workstations |
| SmartMesh    | 2.4GHz   | 30   | Hidden    | WPA2 Personal       | IoT switches, sensors, ESPHome     |

> *Note: The AX90 does not support VLAN tagging per SSID natively. Wireless traffic will need to be bridged through your TEG208E switch for tagging or upgraded via VLAN-capable APs.*

---

## 🔐 HTTPS Policy (SkyNet Principle)

> Use HTTPS wherever possible, even internally.  
> Deploy NGINX Proxy Manager or Caddy on `popbox.home` to terminate TLS.  
> Issue certs via Let's Encrypt DNS-01 or a trusted internal CA (e.g., Smallstep).

---

Let me know if you’d like a rendered network diagram, DNS `hosts` file template, or YAML vars scaffold for use in Ansible roles. SkyNet now answers to clean names across every layer.
