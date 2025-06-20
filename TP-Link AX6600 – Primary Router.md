# router.cpoff.com Configuration (TP-Link AX6600)

## 📦 Role
- Primary gateway to ISP uplink
- DHCP disabled (handled via Infra VLAN)
- Static routing + VLAN-aware trunk to TEG208E switch

## 🌐 Network Setup
- **VLAN**: 99 (Infra)
- **Static IP**: 192.168.99.1
- **FQDN**: `router.cpoff.com`
- **DHCP**: OFF (handled elsewhere)
- **Default Gateway for VLAN 99 nodes**

## ⚙️ UI Access

- Accessible from VLAN 99 clients only (desktop, NAS)
- Visit: `http://router.cpoff.com` or `192.168.99.1`

## 🔧 Recommended Settings

- **DNS servers**: 192.168.99.2 (Pi-hole), 1.1.1.1 (fallback)
- **DHCP disabled**: Use static assignments per device
- **VLAN pass-through** (if supported): trunk to TEG208E

## 🔐 Firewall/NAT Tips

- WAN firewall enabled  
- UPNP: Disabled  
- Remote mgmt: Disabled  
- Only LAN-side access allowed (VLAN 99 only)

## 🧪 Validation

- Ping from Infra client: `ping router.cpoff.com`
- Web UI opens only within VLAN 99 subnet
