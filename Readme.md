# 🏠 Curt's Homelab Topology (10.10.1.0/24 Subnet, Updated IPs)

## 🌐 Router: TP-Link Archer AX90 (AX6600)
- LAN Port 1 → Tenda TEG208E Managed Switch (Port 1)
- DHCP Range: 10.10.1.100–199
- Static Reservations: Core devices only

---

## 🧠 Tenda TEG208E Managed Switch (Center Rack)

| Port | Device / Connection                             | Static IP       | Hostname         | Role / Notes                        |
|------|--------------------------------------------------|------------------|------------------|-------------------------------------|
| 1    | Router LAN Port 1                                | —                | —                | Gateway                             |
| 2    | Synology NAS DS220+                              | 10.10.1.50       | `nas.local`      | Plex, Home Assistant                |
| 3    | HP Printer                                        | 10.10.1.20       | —                | Semi-trusted, allow from PCs only   |
| 4    | Raspberry Pi 3 (DietPi)                           | 10.10.1.3        | `raspi3.local`   | Pi-hole + Unbound (Backup DNS)      |
| 5    | Raspberry Pi 4 (DietPi)                           | 10.10.1.4        | `raspi4.local`   | Docker host / future expansion      |
| 6    | TP-Link Media Switch (Unmanaged)                 | —                | —                | Smart TV + downstream IoT zone      |
| 7    | TP-Link Office Switch (Unmanaged)                | —                | —                | MiniPC, Raspi5                      |
| 8    | Tenda Overflow Switch (Unmanaged)                | —                | —                | Reserved for future devices         |

---

## 🖥️ TP-Link Office Switch (Unmanaged)

| Port | Device                          | Static IP       | Hostname         | Role / Notes                        |
|------|----------------------------------|------------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 7)| —                | —                | Backbone                            |
| 2    | GMKtec MiniPC (Ubuntu)          | 10.10.1.60       | `minipc.local`   | Uptime Kuma, Master Dashboard       |
| 3    | Dell Work Desktop               | 10.10.1.70       | —                | Semi-trusted, productivity          |
| 4    | Raspberry Pi 5 (RaspiOS)        | 10.10.1.5        | `raspi5.local`   | Pi-hole + Unbound (Primary DNS)     |
| 5–8  | Reserved                        | —                | —                | Future expansion                    |

---

## 📺 TP-Link Media Switch (Unmanaged)

| Port | Device                          | Static IP       | Hostname         | Role / Notes                        |
|------|----------------------------------|------------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 6)| —                | —                | Backbone                            |
| 2    | Hisense Smart TV (Android TV)   | 10.10.1.90       | —                | Plex client only                    |
| 3–8  | Kasa Smart Plugs & Switches     | DHCP (Guest)     | —                | Wireless only via Guest SSID        |

---

## 🧩 Tenda Overflow Switch (Unmanaged)

| Port | Device                          | Static IP       | Hostname         | Role / Notes                        |
|------|----------------------------------|------------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 8)| —                | —                | Backbone                            |
| 2–8  | Reserved                        | —                | —                | Future devices                      |

---

## 📶 Wireless IoT Devices (via TP-Link AX90 Guest SSID)

| SSID             | Band     | Devices Assigned             | IP Range           | Hostnames         | Security Settings             |
|------------------|----------|------------------------------|--------------------|-------------------|-------------------------------|
| Guest-SSID-3     | 2.4GHz   | Kasa Smart Plugs & Switches | 10.10.2.100–200    | —                 | AP Isolation, No LAN Access   |

---

## 🔐 Segmentation Summary (Fully Specific)

### ✅ Trusted Core Devices

| Device               | Switch Name             | Port # | Static IP       | Hostname         | Role / Notes                        |
|----------------------|--------------------------|--------|------------------|------------------|-------------------------------------|
| Synology NAS DS220+  | Tenda Managed Switch     | Port 2 | 10.10.1.50       | `nas.local`      | Plex, Home Assistant                |
| Raspberry Pi 3       | Tenda Managed Switch     | Port 4 | 10.10.1.3        | `raspi3.local`   | Pi-hole + Unbound (Backup DNS)      |
| Raspberry Pi 4       | Tenda Managed Switch     | Port 5 | 10.10.1.4        | `raspi4.local`   | Docker host / future expansion      |
| GMKtec MiniPC        | TP-Link Office Switch    | Port 2 | 10.10.1.60       | `minipc.local`   | Uptime Kuma, Master Dashboard       |
| Raspberry Pi 5       | TP-Link Office Switch    | Port 4 | 10.10.1.5        | `raspi5.local`   | Pi-hole + Unbound (Primary DNS)     |

---

### ⚠️ Semi-Trusted Devices

| Device               | Switch Name             | Port # | Static IP       | Hostname         | Role / Notes                        |
|----------------------|--------------------------|--------|------------------|------------------|-------------------------------------|
| HP Printer           | Tenda Managed Switch     | Port 3 | 10.10.1.20       | —                | Allow only from trusted PCs         |
| Hisense Smart TV     | TP-Link Media Switch     | Port 2 | 10.10.1.90       | —                | Plex client only; restrict outbound |

---

## 🧭 Pi-hole Local DNS Records

| Hostname         | IP Address       | Description                          |
|------------------|------------------|--------------------------------------|
| `nas.local`      | 10.10.1.50       | Synology NAS DS220+                  |
| `raspi3.local`   | 10.10.1.3        | Raspberry Pi 3 (DietPi)              |
| `raspi4.local`   | 10.10.1.4        | Raspberry Pi 4 (DietPi)              |
| `raspi5.local`   | 10.10.1.5        | Raspberry Pi 5 (RaspiOS)             |
| `minipc.local`   | 10.10.1.60       | GMKtec MiniPC (Ubuntu)               |

---

## 🔐 Enforcement Layers

| Layer         | Method                                | Purpose                          |
|---------------|----------------------------------------|----------------------------------|
| **Router**    | Guest SSID + AP Isolation              | Isolate wireless IoT devices     |
| **Switch**    | Port-level isolation (if supported)    | Prevent TV/printer from reaching core |
| **UFW**       | Host-level firewalling on Linux hosts | Block unsolicited traffic        |
| **Pi-hole**   | DNS filtering for IoT                  | Block telemetry, ads             |

---

## 🧠 Notes

- All core devices are hard-wired and statically assigned in `10.10.1.0/24`
- Wireless IoT devices isolated in `10.10.2.0/24` via Guest SSID
- Hostnames simplify service access and monitoring
- No VLANs used—segmentation via switch isolation, UFW, and Guest Wi-Fi
