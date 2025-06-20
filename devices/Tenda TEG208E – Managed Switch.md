# switch.cpoff.com Configuration (Tenda TEG208E)

## 📦 Role
- Core switch for inter-VLAN trunking
- Manages VLAN IDs 10, 20, 30, 99
- Links all hardwired infrastructure devices

## 🌐 Network Setup
- **VLAN**: 99 (Infra)
- **Static IP**: 192.168.99.x or DHCP reservation
- **FQDN**: `switch.cpoff.com`
- **Mgmt VLAN**: 99 (untagged on admin port)

## ⚙️ Port Plan (Sample)

| Port | Role            | VLAN Assignment               |
|------|-----------------|-------------------------------|
| 1    | Uplink to router| Tagged: 10,20,30,99           |
| 2    | NAS             | Untagged: 10                  |
| 3    | RPi 4 (DNS)     | Untagged: 99                  |
| 4    | RPi 5 (Apps)    | Untagged: 10                  |
| 5    | RPi 3 (Monitor) | Untagged: 99                  |
| 6–7  | Open/IoT clients| Untagged: 20 or 30            |
| 8    | Admin Desktop   | Untagged: 10 (fallback access)|

## 🔐 Management Notes

- Web UI reachable via: `http://switch.cpoff.com`
- Strong admin password recommended
- VLAN config should match router trunk (tagged/untagged)
- Firmware upgrades via Tenda’s admin panel

## 🧪 Validation

- VLAN tagging test: `ping` between VLANs via Pi-hole logs  
- Validate switch port isolation and tagging logic  
- Confirm DNS resolves via VLAN 20 → 99 relay
