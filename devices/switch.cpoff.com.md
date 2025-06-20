# switch.cpoff.com Configuration (Tenda TEG208E – Managed Switch)

## 📦 Role

- Core VLAN-aware managed switch for SkyNet Prod 3  
- Handles trunking between infrastructure nodes and uplink router  
- Provides port-based access for VLAN segmentation  
- Management access strictly via Infra VLAN (99)

---

## 🌐 Network Setup

- **VLAN**: 99 (Infra)
- **Static IP**: `192.168.99.8`
- **Hostname**: `switch.cpoff.com`
- **DHCP**: Disabled (static assignment or DHCP reservation)
- **Access URL**: `http://192.168.99.8`

---

## 🔌 Port VLAN Table

| Port | Assigned Device         | Untagged VLAN | Tagged VLANs     | Notes                    |
|------|--------------------------|----------------|------------------|--------------------------|
| 1    | Router uplink            | —              | 10, 20, 30, 99    | Trunk link               |
| 2    | Synology NAS             | 10             | —                | Trusted VLAN             |
| 3    | `dns.cpoff.com` (RPi 4)  | 99             | —                | Infra-only               |
| 4    | `forge.cpoff.com` (RPi 5)| 10             | —                | Trusted VLAN             |
| 5    | `node.cpoff.com` (RPi 3) | 99             | —                | Monitoring node          |
| 6    | Open / Dev board         | 20             | —                | IoT VLAN                 |
| 7    | IoT Media devices        | 20             | —                | Smart TV, etc.           |
| 8    | Pop!_OS Workstation      | 10             | —                | Wired admin console      |

> VLAN 99 is used as the management VLAN for switch UI access. Only devices on Infra or trusted admin VLAN can reach it.

---

## 🛠️ Configuration Steps

1. Set switch IP to `192.168.99.8` via web UI (Infra VLAN)
2. Change default login credentials
3. Create VLANs 10, 20, 30, 99
4. Assign appropriate VLANs to each port
5. Tag trunk port (Port 1) for all VLANs
6. Disable LLDP and SNMP if not in use
7. Confirm no DHCP server is active

---

## 🔐 Security Considerations

- Management VLAN (99) should not be routed externally  
- UI access restricted to VLAN 10 or VLAN 99 only  
- Set switch to "auto-save config" if supported  
- Optionally backup config to external file

---

## 🧪 Validation

- Ping: `ping 192.168.99.8` or `ping switch.cpoff.com`
- UI: Load `http://switch.cpoff.com` from Pop!_OS or NAS
- Confirm VLAN isolation via ping tests from different devices
- Use Pi-hole logs or Netdata to inspect network segmentation

---

_Last Updated: SkyNet Prod 3 – switch.cpoff.com_
