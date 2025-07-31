# ☁️ SkyNet – Prod 2 Architecture Rollup  
**Subnet:** 12.12.1.0/24  
**Overlay Mesh:** Tailscale active on core nodes (local reachability only)

---

## 🌐 Router – TP-Link Archer AX90 (AX6600)
- LAN IP: `12.12.1.1` → `router.home`
- DHCP Range: `12.12.1.100–199`
- Static Reservations: Core infrastructure only
- LAN Port 1 → Tenda TEG208E (Managed Switch Port 1)
- SSIDs:
  - `Spicy Mac` (trusted)
  - `Champs` (isolated IoT)

---

## 🧠 Center Rack – Tenda TEG208E Managed Switch

| Port | Device                           | IP Address     | Hostname         | Role                           |
|------|-----------------------------------|----------------|------------------|--------------------------------|
| 1    | Router LAN Port                   | —              | —                | Gateway backbone               |
| 2    | Synology NAS DS220+               | 12.12.1.50     | `nas.home`       | Plex + Home Assistant          |
| 3    | HP Printer                        | 12.12.1.20     | —                | Semi-trusted network printer   |
| 4    | Raspberry Pi 3 (DietPi)           | 12.12.1.3      | `raspi3.home`    | Pi-hole backup, Tailscale      |
| 5    | Raspberry Pi 4 (DietPi)           | 12.12.1.4      | `raspi4.home`    | Docker host, Uptime Kuma       |
| 6    | TP-Link Media Switch (Unmanaged)  | —              | —                | Smart TV zone uplink           |
| 7    | TP-Link Office Switch (Unmanaged) | —              | —                | Desktop + Pi zone              |
| 8    | Tenda Overflow Switch             | —              | —                | Reserved for expansion         |

---

## 🖥️ Office Zone – TP-Link Switch (Unmanaged)

| Port | Device                    | IP Address     | Hostname         | Role                          |
|------|---------------------------|----------------|------------------|-------------------------------|
| 1    | Uplink to Managed Switch  | —              | —                | Local backbone                |
| 2    | GMKtec MiniPC (Ubuntu)    | 12.12.1.60     | `minibox.home`   | **Personal desktop**, Tailscale |
| 3    | Dell Work Desktop         | 12.12.1.70     | `workbox.home`   | Semi-trusted workstation      |
| 4    | Raspberry Pi 5 (RaspiOS)  | 12.12.1.5      | `raspi5.home`    | Primary Pi-hole DNS, Tailscale |
| 5–8  | —                         | —              | —                | Reserved                      |

---

## 📺 Media Zone – TP-Link Switch (Unmanaged)

| Port | Device                          | IP Address     | Hostname         | Role                        |
|------|----------------------------------|----------------|------------------|-----------------------------|
| 1    | Uplink to Managed Switch        | —              | —                | Backbone link              |
| 2    | Hisense Smart TV (Android TV)   | 12.12.1.90     | —                | Plex client (optional LAN) |
| 3–8  | —                                | —              | —                | Reserved                    |

---

## 🔌 Overflow Zone – Tenda Switch (Unmanaged)

| Port | Device           | IP Address | Hostname | Role         |
|------|------------------|------------|----------|--------------|
| 1    | Uplink to Managed| —          | —        | Backbone     |
| 2–8  | —                | —          | —        | Future use   |

---

## 📶 Wireless Segmentation

| SSID         | Band     | Devices Included                          | Notes                        |
|--------------|----------|-------------------------------------------|------------------------------|
| `Spicy Mac`  | Mixed    | Pi-hole clients, Smart TV, mobile         | Trusted LAN                  |
| `Champs`     | 2.4GHz   | Kasa smart plugs, switches (IoT)          | Guest VLAN isolation enabled |

---

## 🧩 Services & Roles

| Hostname         | IP Address     | Services                          |
|------------------|----------------|------------------------------------|
| `raspi5.home`    | 12.12.1.5      | Pi-hole + Unbound (primary)        |
| `raspi3.home`    | 12.12.1.3      | Pi-hole (backup DNS)               |
| `raspi4.home`    | 12.12.1.4      | Docker containers, monitoring      |
| `nas.home`       | 12.12.1.50     | Plex media server + automation     |
| `minibox.home`   | 12.12.1.60     | Personal desktop, logging          |
| `workbox.home`   | 12.12.1.70     | General PC use                     |

---

## 🛡️ Tailscale Mesh Overlay

| Node             | Tailscale Enabled | Role                           |
|------------------|-------------------|--------------------------------|
| `raspi3.home`    | ✅                | DNS backup / mesh gateway      |
| `raspi4.home`    | ✅                | Containers / metrics           |
| `raspi5.home`    | ✅                | DNS primary / coordination     |
| `nas.home`       | ✅                | Remote Plex (optional)         |
| `minibox.home`   | ✅                | Personal / private access      |
| `workbox.home`   | ✅                | Reachable on demand            |

> 🔒 **Traffic is encrypted and authenticated internally**

---

## 🧭 Pi-hole DNS Records

| Hostname         | IP Address     |
|------------------|----------------|
| `raspi3.home`    | 12.12.1.3      |
| `raspi4.home`    | 12.12.1.4      |
| `raspi5.home`    | 12.12.1.5      |
| `nas.home`       | 12.12.1.50     |
| `minibox.home`   | 12.12.1.60     |
| `workbox.home`   | 12.12.1.70     |

---

## 🔐 Segmentation Enforcement (No VLANs)

| Layer          | Method                      | Purpose                         |
|----------------|-----------------------------|---------------------------------|
| Router         | Guest VLAN + AP isolation   | Quarantine wireless IoT traffic |
| Managed Switch | Physical port assignment    | Prevent lateral sprawl          |
| Host Firewall  | UFW rules on Linux nodes    | Restrict inbound connections    |
| Pi-hole        | Local DNS + telemetry block | Reduce adware/IoT noise         |
| Tailscale      | Authenticated mesh overlay  | Secure inter-node traffic       |
