## 🗺️ SkyNet Topology Map

### 🔧 Network Roles

| Role                    | Hostname            | IP Address     | Device / OS             | Services / Apps                                                                             |
|-------------------------|---------------------|----------------|--------------------------|----------------------------------------------------------------------------------------------|
| **Admin Core**          | `admincore.home`    | 10.10.10.10    | Dell XPS / Pop!_OS       | `dnsmasq`, Ansible, Docker, Portainer, Homarr, Watchtower, Netdata, Tailscale, UFW         |
| **Container Node**      | `dockerbox.ts.net`  | 10.10.20.14    | Raspberry Pi 5           | Portainer Agent, Mosquitto, Vaultwarden, Home Assistant (optional), Zigbee2MQTT proxy       |
| **NAS Server**          | `nas.home`          | 10.10.20.10    | Synology NAS             | Plex, Media backup, Tautulli (opt), Synology Drive, SMB/NFS, Snapshots                      |
| **DNS Relay Node**      | `dns.home`          | 10.10.30.53    | Raspberry Pi 3           | Pi-hole, Unbound, Tailscale, UFW (port 53 only)                                             |
| **Utility Pi**          | `pi4-util.home`     | 10.10.30.11    | Raspberry Pi 4           | AdGuard (port 8053), Prometheus exporter, NodeRED (opt), experimental agents                |
| **IoT Clients**         | `kasa01`, etc.      | 10.10.30.x     | Smart Plugs, Switches    | DNS via Pi-hole, MQTT via Mosquitto                                                         |
| **Router / Gateway**    | `router.home`       | 10.10.99.2     | TP-Link AX6600           | DHCP relay, VLAN trunking, subnet routes, Tailscale (opt)                                   |
| **Switch / Core VLAN**  | `switch.home`       | 10.10.99.1     | L2 Managed Switch         | Tagged VLANs: Admin (10), Services (20), IoT (30), Guests (40)                              |

---

### 📡 Services Matrix

| Service / App          | Location              | Notes                                 |
|------------------------|-----------------------|---------------------------------------|
| **Homarr**             | `admincore`           | Drag-and-drop dashboard               |
| **Portainer**          | `admincore` + agent   | Docker container orchestration        |
| **dnsmasq**            | `admincore`           | Primary local DNS + DHCP              |
| **Pi-hole**            | `dns.home`            | DNS filtering & metrics               |
| **Unbound**            | `dns.home`            | Recursive resolver backend            |
| **AdGuard Home**       | `pi4-util`            | Alt DNS on port 8053 (test node)      |
| **Home Assistant**     | `dockerbox`           | Smart home brain (opt)                |
| **Mosquitto**          | `dockerbox`           | MQTT broker for HA + Zigbee           |
| **Zigbee2MQTT**        | `pi4-util`            | Radio + converter                     |
| **Plex**               | `nas`                 | Media server                          |
| **Vaultwarden**        | `dockerbox`           | Self-hosted password manager          |
| **Tautulli** (opt)     | `nas`                 | Plex analytics                        |
| **Netdata**            | `admincore`           | Real-time telemetry                   |
| **Uptime Kuma**        | `dockerbox`           | Service ping + alerts                 |
| **Tailscale**          | Most nodes            | Encrypted overlay w/ MagicDNS         |




# SkyNet – Prod 3 Topology Documentation

---


