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

#### 2.2 `nas.cpoff.com` (Synology NAS)

- Assign static IP: `192.168.10.2`  
- Install:
  - Home Assistant (Docker)
  - NGINX Proxy Manager (Docker)
  - Portainer
  - Plex Media Server
- Link subdomains via Pi-hole and wildcard DNS  
- Configure NGINX to use Let's Encrypt certs via DNS-01 (Cloudflare)  
- Apply UFW: open ports 80, 443, 32400 (VLANs 10/20), allow 100.64.0.0/10  
- Join Tailscale with hostname `nas`  
- Validate access to:
  - https://nas.cpoff.com
  - Plex: http://nas.cpoff.com:32400/web
  - Portainer and NPM dashboards

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
- Apply UFW:
  - Allow 80/443 and 3000–3999 from VLAN 10
  - Deny all from VLAN 20
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
  - Allow `192.168.10.2` to port 19999 (Netdata)
  - Allow VLAN 10 and VLAN 99 for diagnostics
- Join Tailscale with hostname `node` + tag `tag:infra` (optional)  
- Validate Netdata at `http://node.cpoff.com:19999`  

---

### ✅ 3. Configure Admin Workstation (Pop!_OS)

- Assign to VLAN 10 (DHCP or static)  
- Create `.bash_aliases` with:
  - UFW commands
  - Docker shortcuts
  - SSH access to nodes
  - Tailscale + diagnostics helpers

```bash
source ~/.bash_aliases
```

- Join Tailscale with hostname `opscenter`  
- Validate:
  - SSH into `dns`, `forge`, `nas`, `node`
  - Dashboard access
  - Ping & DNS resolution via Pi-hole

---

### ✅ 4. Apply Tailscale Mesh

- Install Tailscale on all nodes:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up --authkey tskey-xxxx --hostname <node> [--advertise-tags=tag:infra]
  ```

- Suggested tags:
  - `dns` → no tag
  - `nas` → `tag:media`
  - `forge` → `tag:apps`
  - `node` → `tag:infra`

- Define Tailscale ACLs for:

  | Port     | Description               |
  |----------|---------------------------|
  | 53       | DNS (dns.cpoff.com)       |
  | 32400    | Plex (nas.cpoff.com)      |
  | 19999    | Netdata (node.cpoff.com)  |
  | 3000–3999| App stack (forge.cpoff.com)|

---

## 📋 Final Validation Checklist

- [ ] Pi-hole resolving `*.cpoff.com`  
- [ ] VLAN firewalling and subnet segmentation confirmed  
- [ ] NGINX Proxy Manager issues valid cert via Cloudflare  
- [ ] Tailscale overlay mesh visible in admin console  
- [ ] SSH, UFW, Docker, Portainer accessible from Pop!_OS  
- [ ] Netdata web dashboard reachable at `node.cpoff.com:19999`  
- [ ] Dashy/Jellyfin running on `forge.cpoff.com`  
- [ ] Admin alias library sourced and effective  

---

## 🧠 Suggested File Layout in Repo

```
/README.md                     ← Full topology and alias library
/docs/tailscale.md            ← Tailscale overlay config
/docs/install-checklist.md    ← This file
/devices/
  dns.cpoff.com.md
  nas.cpoff.com.md
  forge.cpoff.com.md
  node.cpoff.com.md
  switch.cpoff.com.md
  router.cpoff.com.md
  workstation.md
```

---

_Last Updated: SkyNet Prod 3 Installation — with `nas.cpoff.com` Naming Convention_
