# ☁️ SkyNet – Prod 2 Architecture Rollup  
**Subnet:** 12.12.1.0/24  
**Overlay Mesh:** Tailscale enabled on core nodes

---

## 🌐 Router: TP-Link Archer AX90 (AX6600)
- LAN IP: `12.12.1.1` → `router.home`
- DHCP Range: `12.12.1.100–199`
- Connected: LAN Port 1 → Center Rack Switch (Port 1)
- AP Isolation enabled on `Champs` guest SSID

---

## 🧠 Center Rack – Tenda TEG208E (Managed Switch)

| Port | Device / Uplink                      | Static IP     | Hostname         | Role                             |
|------|--------------------------------------|---------------|------------------|----------------------------------|
| 1    | Router LAN Port 1                    | —             | —                | Gateway                          |
| 2    | Synology NAS DS220+                  | 12.12.1.50    | `nas.home`       | Plex + Home Assistant            |
| 3    | HP Printer                           | 12.12.1.20    | —                | Semi-trusted peripheral          |
| 4    | Raspberry Pi 3 (DietPi)              | 12.12.1.3     | `raspi3.home`    | Backup Pi-hole DNS, Tailscale    |
| 5    | Raspberry Pi 4 (DietPi)              | 12.12.1.4     | `raspi4.home`    | Monitoring + Docker, Tailscale   |
| 6    | TP-Link Switch – Media Zone          | —             | —                | Smart TV segment                 |
| 7    | TP-Link Switch – Office Zone         | —             | —                | Desktop + Raspi5 zone            |
| 8    | Tenda Switch – Overflow Zone         | —             | —                | Expansion (future)               |

---

## 🖥️ Office Zone – TP-Link Switch (Unmanaged)

| Port | Device                    | Static IP     | Hostname         | Role                             |
|------|---------------------------|----------------|------------------|----------------------------------|
| 1    | Uplink to Center Rack SW  | —              | —                | Backbone                         |
| 2    | GMKtec MiniPC (Ubuntu)    | 12.12.1.60     | `minibox.home`   | Personal desktop, Tailscale      |
| 3    | Dell Work Desktop         | 12.12.1.70     | `workbox.home`   | Semi-trusted productivity        |
| 4    | Raspberry Pi 5 (RaspiOS)  | 12.12.1.5      | `raspi5.home`    | Pi-hole primary DNS, Tailscale   |
| 5–8  | —                         | —              | —                | Reserved                         |

---

## 📺 Media Zone – TP-Link Switch (Unmanaged)

| Port | Device                          | Static IP     | Hostname         | Role                        |
|------|----------------------------------|---------------|------------------|-----------------------------|
| 1    | Uplink to Center Rack SW        | —             | —                | Backbone                    |
| 2    | Hisense Smart TV (Android TV)   | 12.12.1.90    | —                | Plex client (optional LAN)  |
| 3–8  | —                                | —             | —                | Reserved                    |

---

## 🔌 Overflow Zone – Tenda Switch (Unmanaged)

| Port | Device           | Static IP | Hostname | Role           |
|------|------------------|-----------|----------|----------------|
| 1    | Uplink to Rack SW| —         | —        | Backbone       |
| 2–8  | —                | —         | —        | Expansion zone |

---

## 📶 Wi-Fi Segmentation Table

| SSID         | Band     | Assigned Devices                    | IP Range        | Notes                              |
|--------------|----------|-------------------------------------|------------------|------------------------------------|
| `Spicy Mac`  | Mixed    | Smart TV, Pi-hole clients, desktops| 12.12.1.x        | Trusted LAN, unrestricted          |
| `Champs`     | 2.4GHz   | Kasa plugs, switches                | 12.12.2.100–200  | Guest VLAN isolation, IoT only     |

---

## 🧩 Services Overview

| Hostname         | IP Address     | Services Provided                          |
|------------------|----------------|---------------------------------------------|
| `raspi5.home`    | 12.12.1.5      | Pi-hole + Unbound (Primary DNS), Tailscale  |
| `raspi3.home`    | 12.12.1.3      | Pi-hole (Backup DNS), Tailscale             |
| `raspi4.home`    | 12.12.1.4      | Monitoring, Docker, Tailscale               |
| `nas.home`       | 12.12.1.50     | Plex, Home Assistant, Tailscale             |
| `minibox.home`   | 12.12.1.60     | Personal desktop, Tailscale                 |
| `workbox.home`   | 12.12.1.70     | Semi-trusted desktop, Tailscale             |

---

## 🛡️ Tailscale Mesh Overlay

- **Enabled Nodes**: All devices above except Smart TV and Printer  
- **Role**:
  - Secure inter-node transport  
  - Fallback DNS and dashboard accessibility  
  - Optional MagicDNS override support  
- **Traffic**: Fully encrypted, authenticated per device

---

## 🧭 Pi-hole Local DNS Records

| Hostname         | IP Address     | Description                          |
|------------------|----------------|--------------------------------------|
| `raspi3.home`    | 12.12.1.3      | Backup Pi-hole DNS node              |
| `raspi4.home`    | 12.12.1.4      | Monitor + container host             |
| `raspi5.home`    | 12.12.1.5      | Primary DNS node                     |
| `nas.home`       | 12.12.1.50     | File/media/automation                |
| `minibox.home`   | 12.12.1.60     | Personal Ubuntu desktop              |
| `workbox.home`   | 12.12.1.70     | Desktop workstation                  |

---

## 🔐 Segmentation Layers (No VLANs)

| Layer         | Method                                | Purpose                          |
|---------------|----------------------------------------|----------------------------------|
| Router        | Guest VLAN + AP isolation              | Quarantine wireless IoT          |
| Managed SW    | Physical port zoning                   | Contain device roles             |
| Host Firewall | UFW on all Linux nodes                 | Limit unsolicited inbound traffic|
| Pi-hole       | DNS filtering + domain blocking        | Harden telemetry, filter adware  |
| Tailscale     | Secure mesh, remote access             | Encrypt traffic, remote ops      |
