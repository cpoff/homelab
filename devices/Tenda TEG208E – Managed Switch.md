# switch.cpoff.com Configuration (Tenda TEG208E)

## 📦 Role

- Primary managed switch for SkyNet Prod 3
- Provides inter-VLAN routing via trunking
- Assigns untagged VLANs to endpoint ports
- Central traffic hub between router, NAS, Pi nodes, and workstation

---

## 🌐 Network Setup

- **Management VLAN**: 99 (Infra)
- **Static IP**: `192.168.99.8`
- **Hostname (FQDN)**: `switch.cpoff.com`
- **DHCP**: Disabled
- **Access**: http://192.168.99.8 or http://switch.cpoff.com (via Pi-hole)

### Recommended DHCP Reservation (optional)

If using Pi-hole DHCP, set the switch MAC to receive `.8` for consistency.

---

## 🛡️ VLAN Trunking and Port Assignments

| Port | Role/Device          | VLAN Mode     | Untagged VLAN | Tagged VLANs              |
|------|-----------------------|---------------|---------------|---------------------------|
| 1    | Uplink to router      | Trunk         | None          | 10, 20, 30, 99            |
| 2    | Synology NAS          | Access        | 10            | —                         |
| 3    | RPi 4 (DNS)           | Access        | 99            | —                         |
| 4    | RPi 5 (Apps)          | Access        | 10            | —                         |
| 5    | RPi 3 (Netdata Node)  | Access        | 99            | —                         |
| 6    | Unused / Dev Board    | Access        | 20 or 10      | —                         |
| 7    | Smart Device Segment  | Access        | 20            | —                         |
| 8    | Workstation (Admin)   | Access        | 10            | —                         |

> Tip: Use port mirroring or storm control if supported to monitor untagged traffic.

---

## 🔐 Security Tips

- Change admin password on first login  
- Disable LLDP/CDP unless required  
- Disable switch-side DHCP (if applicable)  
- Enable VLAN 99 as the only management-accessible VLAN  

---

## 🧪 Validation

- Ping: `ping 192.168.99.8` or `ping switch.cpoff.com`  
- Access UI from workstation: `http://switch.cpoff.com`  
- Confirm VLAN tagging via Pi-hole logs or Netdata node  
- Verify isolation: VLAN 20 devices cannot access VLAN 10 targets  

---

## 📁 Notes

- Save configuration to flash after changes  
- Export backup configuration to file  
- Use Chrome or Firefox for optimal UI compatibility

---

_Last Updated: SkyNet Prod 3 – switch.cpoff.com_
