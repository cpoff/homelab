# 🏠 Curt's Homelab Topology – `10.10.1.0/24` Subnet

## 🌐 Router: TP-Link Archer AX90 (AX6600)
- LAN Port 1 → Tenda TEG208E Managed Switch (Port 1)
- DHCP Range: `10.10.1.100–199`
- Static Reservations: Core devices only

---

## 🧠 Tenda TEG208E Managed Switch (Center Rack)

| Port | Device / Connection                             | Static IP     | Hostname         | Role / Notes                        |
|------|--------------------------------------------------|---------------|------------------|-------------------------------------|
| 1    | Router LAN Port 1                                | —             | —                | Gateway                             |
| 2    | Synology NAS DS220+                              | 10.10.1.50    | `nas.home`       | Plex, Home Assistant                |
| 3    | HP Printer                                        | 10.10.1.20    | —                | Semi-trusted, allow from PCs only   |
| 4    | Raspberry Pi 3 (DietPi)                           | 10.10.1.3     | `raspi3.home`    | Pi-hole + Unbound (Backup DNS)      |
| 5    | Raspberry Pi 4 (DietPi)                           | 10.10.1.4     | `raspi4.home`    | Docker host / future expansion      |
| 6    | TP-Link Media Switch (Unmanaged)                 | —             | —                | Smart TV + downstream IoT zone      |
| 7    | TP-Link Office Switch (Unmanaged)                | —             | —                | `minibox.home`, `raspi5.home`       |
| 8    | Tenda Overflow Switch (Unmanaged)                | —             | —                | Reserved for future devices         |

---

## 🖥️ TP-Link Office Switch (Unmanaged)

| Port | Device                          | Static IP     | Hostname         | Role / Notes                        |
|------|----------------------------------|---------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 7)| —             | —                | Backbone                            |
| 2    | GMKtec MiniPC (Ubuntu)          | 10.10.1.60    | `minibox.home`   | Uptime Kuma, Master Dashboard       |
| 3    | Dell Work Desktop               | 10.10.1.70    | —                | Semi-trusted, productivity          |
| 4    | Raspberry Pi 5 (RaspiOS)        | 10.10.1.5     | `raspi5.home`    | Pi-hole + Unbound (Primary DNS)     |
| 5–8  | Reserved                        | —             | —                | Future expansion                    |

---

## 📺 TP-Link Media Switch (Unmanaged)

| Port | Device                          | Static IP     | Hostname         | Role / Notes                        |
|------|----------------------------------|---------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 6)| —             | —                | Backbone                            |
| 2    | Hisense Smart TV (Android TV)   | 10.10.1.90    | —                | Plex client only                    |
| 3–8  | Kasa Smart Plugs & Switches     | DHCP          | —                | Guest SSID only                     |

---

## 🔌 Tenda Overflow Switch (Unmanaged)

| Port | Device                          | Static IP     | Hostname         | Role / Notes                        |
|------|----------------------------------|---------------|------------------|-------------------------------------|
| 1    | Uplink to Tenda Managed (Port 8)| —             | —                | Backbone                            |
| 2–8  | Reserved                        | —             | —                | Future expansion                    |

---

## 📶 SSID & Segmentation Table

| SSID        | Band     | VLAN | Devices Assigned                       | IP Range           | Security Settings               |
|-------------|----------|------|----------------------------------------|--------------------|---------------------------------|
| `Spicy Mac` | Mixed    | —    | `nas.home`, `minibox.home`, `raspi5.home` | 10.10.1.x           | Trusted, unrestricted           |
| `Guster`    | 2.4GHz   | —    | Kasa Smart Plugs, Smart TV             | 10.10.2.100–200     | Guest isolation, no LAN access |

---

## 🧭 Pi-hole Local DNS Records

| Hostname         | IP Address    | Description                          |
|------------------|---------------|--------------------------------------|
| `nas.home`       | 10.10.1.50    | Synology NAS DS220+                  |
| `raspi3.home`    | 10.10.1.3     | Raspberry Pi 3 (DietPi)              |
| `raspi4.home`    | 10.10.1.4     | Raspberry Pi 4 (DietPi)              |
| `raspi5.home`    | 10.10.1.5     | Raspberry Pi 5 (RaspiOS)             |
| `minibox.home`   | 10.10.1.60    | GMKtec MiniPC (Ubuntu)               |

---

## 🔐 Segmentation Enforcement Layers

| Layer         | Method                                | Purpose                          |
|---------------|----------------------------------------|----------------------------------|
| **Router**    | Guest SSID + AP Isolation              | Isolate wireless IoT devices     |
| **Switch**    | Port-level topology                    | Prevent lateral movement         |
| **UFW**       | Host firewalls on Linux nodes          | Block unsolicited traffic        |
| **Pi-hole**   | DNS filtering, ad/telemetry blocking   | Harden IoT and TV environments   |
