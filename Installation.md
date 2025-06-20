# SkyNet – Prod 3 Installation Checklist (Full Sequence)

This file provides a step-by-step installation and configuration sequence for building out the SkyNet Prod 3 infrastructure from scratch. It assumes base Raspberry Pi OS Lite or Debian-based installations where applicable and a Pop!_OS control workstation.

---

## ⚙️ Global Assumptions

- All devices receive static IPs via `dhcpcd.conf` or DHCP reservations
- VLAN-aware topology with trunked switch configuration (see `switch.cpoff.com.md`)
- Internal DNS resolution handled by `dns.cpoff.com` (Pi-hole + Unbound)
- Overlay mesh connectivity established via Tailscale
- All administrative operations handled from Pop!_OS workstation

---

## 🔢 Installation Sequence

### ✅ 1. Configure Infrastructure Devices

#### 1.1 `router.cpoff.com` (TP-Link AX6600)

- Disable DHCP  
- Set static IP: `192.168.99.1`  
- Define VLAN trunk to managed switch  
- Set DNS servers: `192.168.99.2`, `1.1.1.1`  
- Secure admin panel (disable remote mgmt, UPNP)

#### 1.2 `switch.cpoff.com` (Tenda TEG208E)

- Set static IP: e.g., `192.168.99.x`  
- Define port VLAN assignments (tagged/untagged)  
- Verify management VLAN (99) access from admin port  
- Test inter-VLAN isolation and trunk configuration  

---

### ✅ 2. Deploy Core Nodes

#### 2.1 `dns.cpoff.com` (RPi 4 – Pi-hole + Unbound)

- Set hostname: `dns`
- Set static IP: `192.168.99.2`
- Install Pi-hole and Unbound:
  ```bash
  curl -sSL https://install.pi-hole.net | bash
  sudo apt install unbound -y
  ```
- Configure `/etc/unbound/unbound.conf.d/pi-hole.conf`
- Apply UFW rules (allow DNS from VLANs 10/20/99, Pi-hole UI from VLAN 10 only)
- Join Tailscale with hostname `dns`
- Validate DNS recursion and web UI

#### 2.2 `plex.cpoff.com` (Synology NAS)

- Assign static IP: `192.168.10.2`
- Install:
  - Home Assistant (Docker)
  - NGINX Proxy Manager (Docker)
  - Portainer
  - Plex Media Server
- Link subdomains via Pi-hole and wildcard DNS
- Configure NGINX to use Let's Encrypt certs via DNS-01 (Cloudflare)
- Apply UFW: open ports 80, 443, 32400 (VLANs 10/20), allow 100.64.0.0/10
- Join Tailscale with hostname `plex`

#### 2.3 `forge.cpoff.com` (RPi 5 – App Stack)

- Set hostname: `forge`
- Set static IP: `192.168.10.3`
- Install Docker + Docker Compose:
  ```bash
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  ```
- Install:
  - Dashy
  - Jellyfin
  - CasaOS or custom containers
- Apply UFW: allow 80/443, 3000–3999 from VLAN 10; deny VLAN 20
- Join Tailscale with hostname `forge` + tag `tag:apps` (optional)
- Access Dashy at `http://dashy.cpoff.com`

#### 2.4 `node.cpoff.com` (RPi 3 – Utility Monitor)

- Set hostname: `node`
- Set static IP: `192.168.99.3`
- Install UFW and Netdata:
  ```bash
  sudo apt install ufw -y
  bash <(curl -Ss https://my-netdata.io/kickstart.sh)
  ```
- Apply UFW:
  - Allow `192.168.10.2` to port 19999
  - Allow VLAN 10 and VLAN 99 internal traffic
- Join Tailscale with hostname `node` + tag `tag:infra` (optional)
- Validate Netdata at `http://node.cpoff.com:19999`

---

### ✅ 3. Configure Admin Workstation (Pop!_OS)

- Assign to VLAN 10 (DHCP or static)
- Create `.bash_aliases` with:
  - UFW tools
  - Docker helpers
  - SSH targets (e.g. `ssh curt@forge.cpoff.com`)
  - Tailscale and diagnostics

```bash
source ~/.bash_aliases
```

- Join Tailscale with hostname `opscenter`
- Validate SSH, dashboards, Netdata, DNS resolution

---

### ✅ 4. Apply Tailscale Mesh

- Install Tailscale on all nodes:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up --authkey tskey-xxxx --hostname <node> [--advertise-tags=tag:infra]
  ```

- Suggested tags:
  - `dns` → no tag
  - `plex` → `tag:media`
  - `forge` → `tag:apps`
  - `node` → `tag:infra`

- Create ACLs in admin console to control:
  - Port 53 (dns)
  - Port 32400 (plex)
  - Port 19999 (node)
  - Ports 3000–3999 (forge)

---

## 📋 Final Validation Checklist

- [ ] Pi-hole resolving `*.cpoff.com`
- [ ] UFW properly isolates VLANs
- [ ] NAS issues Let’s Encrypt cert via NPM + Cloudflare
- [ ] Tailscale mesh up and visible in admin console
- [ ] SSH and dashboards accessible from Pop!_OS
- [ ] Netdata UI functional for `node.cpoff.com`
- [ ] Dashy, Jellyfin running on `forge.cpoff.com`
- [ ] Admin alias fleet functional and sourced

---

## 🧠 Suggested File Layout in Repo

```
/README.md                      ← Full topology and alias library
/docs/tailscale.md             ← Overlay config (this file)
/devices/
  dns.cpoff.com.md
  plex.cpoff.com.md
  forge.cpoff.com.md
  node.cpoff.com.md
  switch.cpoff.com.md
  router.cpoff.com.md
  workstation.md
```

---

_Last Updated: SkyNet Prod 3 Installation — Complete Sequence_
