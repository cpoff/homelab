# ☁️ SkyNet – Prod 2 Architecture Rollup (Subnet: 12.12.1.0/24)

---

## 🌐 Router: TP-Link Archer AX90 (AX6600)
- LAN IP: `12.12.1.1` (`router.home`)
- DHCP Range: `12.12.1.100–199`
- Static Reservations: Core nodes only
- LAN Port 1 → Tenda TEG208E Managed Switch (Port 1)

---

## 🧠 Center Rack – Tenda TEG208E (Managed Switch)

| Port | Device                            | IP Address     | Hostname         | Role                          |
|------|------------------------------------|----------------|------------------|-------------------------------|
| 1    | Router (AX90)                      | —              | —                | Uplink                        |
| 2    | Synology NAS DS220+                | 12.12.1.50     | `nas.home`       | Plex, Home Assistant          |
| 3    | HP Printer                         | 12.12.1.20     | —                | Semi-trusted, print only      |
| 4    | Raspberry Pi 3 (DietPi)            | 12.12.1.3      | `raspi3.home`    | Pi-hole (Backup DNS)          |
| 5    | Raspberry Pi 4 (DietPi)            | 12.12.1.4      | `raspi4.home`    | Uptime Kuma, container host   |
| 6    | TP-Link Media Switch (Unmanaged)   | —              | —                | Smart TV zone                 |
| 7    | TP-Link Office Switch (Unmanaged)  | —              | —                | MiniPC + Raspi5 zone          |
| 8    | Tenda Overflow Switch (Unmanaged)  | —              | —                | Reserved                      |

---

## 🖥️ Office Zone – TP-Link Switch (Unmanaged)

| Port | Device                    | IP Address     | Hostname         | Role                           |
|------|---------------------------|----------------|------------------|--------------------------------|
| 1    | Uplink to Center Rack SW  | —              | —                | Backbone                       |
| 2    | GMKtec MiniPC (Ubuntu)    | 12.12.1.60     | `minibox.home`   | Dashboard, logging             |
| 3    | Dell Work Desktop         | 12.12.1.70     | `workbox.home`   | DHCP-reserved, productivity    |
| 4    | Raspberry Pi 5 (RaspiOS)  | 12.12.1.5      | `raspi5.home`    | Pi-hole (Primary DNS)          |
| 5–8  | —                         | —              | —                | Reserved ports                 |

---

## 📺 Media Zone – TP-Link Switch (Unmanaged)

| Port | Device                          | IP Address     | Hostname         | Role                          |
|------|----------------------------------|----------------|------------------|-------------------------------|
| 1    | Uplink to Center Rack SW        | —              | —                | Backbone                      |
| 2    | Hisense Smart TV (Android TV)   | 12.12.1.90     | —                | Plex client (wired fallback)  |
| 3–8  | —                                | —              | —                | Reserved                      |

---

## 🔌 Overflow Switch – Tenda (Unmanaged)

| Port | Device           | IP Address | Hostname | Role           |
|------|------------------|------------|----------|----------------|
| 1    | Uplink to Rack SW| —          | —        | Backbone       |
| 2–8  | —                | —          | —        | Expansion zone |

---

## 📶 Wi-Fi Overview

| SSID         | Band     | Assigned Devices                     | Security                          |
|--------------|----------|--------------------------------------|-----------------------------------|
| `Spicy Mac`  | Mixed    | NAS, MiniPC, Raspi5, Smart TV        | Trusted, unrestricted LAN access  |
| `Champs`     | 2.4GHz   | Kasa Smart Plugs, switches           | Guest VLAN isolation, no LAN      |

---

## 🧩 Service Map

| Hostname         | IP Address     | Services Provided                          |
|------------------|----------------|---------------------------------------------|
| `raspi5.home`    | 12.12.1.5      | Pi-hole + Unbound (Primary DNS)             |
| `raspi3.home`    | 12.12.1.3      | Pi-hole (Backup DNS)                        |
| `raspi4.home`    | 12.12.1.4      | Uptime Kuma, Docker services                |
| `nas.home`       | 12.12.1.50     | Plex Media Server, Home Assistant           |
| `minibox.home`   | 12.12.1.60     | Log aggregation, dashboard interface        |
| `workbox.home`   | 12.12.1.70     | Standard desktop, semi-trusted firewall     |

---

## 🧭 Pi-hole DNS Records (Local DNS)

| Hostname         | IP Address     | Role                          |
|------------------|----------------|-------------------------------|
| `raspi3.home`    | 12.12.1.3      | Backup DNS node               |
| `raspi4.home`    | 12.12.1.4      | Monitoring + containers       |
| `raspi5.home`    | 12.12.1.5      | Primary DNS node              |
| `nas.home`       | 12.12.1.50     | File/media/automation         |
| `minibox.home`   | 12.12.1.60     | Dashboards + logging          |
| `workbox.home`   | 12.12.1.70     | Desktop workstation           |

---

## 🔐 Segmentation & Security Layers

| Layer          | Enforcement                                | Purpose                          |
|----------------|---------------------------------------------|----------------------------------|
| Router         | Guest VLAN + AP Isolation (`Champs` SSID)   | Quarantine IoT traffic           |
| Managed Switch | Physical port topology                      | Prevent lateral movement         |
| UFW            | Linux host firewalls                        | Restrict inbound connections     |
| Pi-hole        | DNS + telemetry filtering                   | Block adware and callouts        |

