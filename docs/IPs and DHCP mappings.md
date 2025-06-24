# 🏡 Home Network Topology and Device Inventory (`cpoff.com`)

---

## 🔗 Ethernet Connections

### **[Tenda TEG208E Managed Switch] Port Map**
| Port | Device                             | Hostname           | VLAN | IP Address      | Connection Type |
|------|------------------------------------|--------------------|------|------------------|------------------|
| 1    | TP-Link AX6600 Router (uplink)     | —                  | trunk| —                | Ethernet         |
| 2    | Raspberry Pi 5                     | forge.cpoff.com    | 10   | 192.168.10.3     | Ethernet         |
| 3    | Synology NAS                       | plex.cpoff.com     | 10   | 192.168.10.2     | Ethernet         |
| 4    | Raspberry Pi 4                     | dns.cpoff.com      | 99   | 192.168.99.2     | Ethernet         |
| 5    | Raspberry Pi 3                     | node.cpoff.com     | 99   | 192.168.99.3     | Ethernet         |
| 6    | TP-Link AC1200 WiFi Extender       | —                  | 30   | 192.168.30.X     | Ethernet         |
| 7    | Curt-Desktop                       | —                  | 10   | 192.168.10.X     | Ethernet         |
| 8    | TP-Link TL-SG105 (Unmanaged)       | —                  | 10   | —                | Ethernet         |

---

## 📶 Wi-Fi SSIDs and Connected Devices

### **VLAN 10 – Main Wi-Fi (`192.168.10.0/24`)**
- Curt-Laptop
- Wife-Laptop
- Curt-Work Laptop
- Wife-Work Laptop
- Curt-Pixel
- Wife-Pixel

### **VLAN 20 – IoT Wi-Fi (`192.168.20.0/24`)**
- Smart TV
- Roku Soundbar (Back Room)
- Google TV
- Multiple Kasa Smart Plugs

### **VLAN 30 – Guest Wi-Fi (`192.168.30.0/24`)**
