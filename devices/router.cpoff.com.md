# router.cpoff.com Configuration (TP-Link AX6600)

## 📦 Role

- Primary gateway to ISP and core Layer 3 router for SkyNet  
- VLAN gateway for trunked traffic entering the managed switch  
- Distributes default route and DNS fallback (only if Pi-hole is offline)  
- Minimal NAT/firewall duties; bulk of rules enforced downstream via UFW

---

## 🌐 Network Setup

- **Management Interface**: Web UI via `http://router.cpoff.com`
- **Static IP**: `192.168.99.1`
- **LAN VLAN Trunk Port**: Tagged: 10, 20, 30, 99 → Port 1 (switch uplink)
- **DHCP Server**: Disabled
- **DNS Servers**:
  - Primary: `192.168.99.2` (Pi-hole)
  - Secondary: `1.1.1.1` (Cloudflare fallback)

---

## 🔐 Security Configuration

- Change admin password immediately  
- Disable:
  - Remote management
  - uPNP
  - WPS (if exposed)  
- Ensure no DHCP relay or DNS proxy active  
- Configure static routing only if needed for inter-VLAN rules

---

## 🧪 Validation

- Ping from admin workstation: `ping router.cpoff.com`  
- Web UI access from VLAN 10 or 99 only  
- Confirm DNS lookups route through `192.168.99.2` (Pi-hole)  
- Confirm client VLANs are isolated via switch config  
- Optional: Check WAN IP and uptime from diagnostics panel

---

## 📝 Notes

- Use static ARP and MAC filtering only if required  
- Ensure firmware is up to date; auto-check can remain off  
- Backup configuration post-install in encrypted local directory

---

_Last Updated: SkyNet Prod 3 – router.cpoff.com_
