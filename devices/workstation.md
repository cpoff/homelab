# workstation.md Configuration (Pop!_OS Admin Console)

## 📦 Role

- Central operations terminal for SkyNet Prod 3  
- Used for configuring, validating, and maintaining all nodes  
- Hosts `.bash_aliases`, SSH keys, and Tailscale client  
- Local browser access to all dashboards and diagnostic UIs

---

## 🌐 Network Setup

- **VLAN**: 10 (Trusted)
- **IP Address**: DHCP (recommended reservation) or static (e.g. `192.168.10.10`)
- **Hostname**: `opscenter` (optional, for overlay)

---

## 🔑 SSH & Identity

- Generate SSH keypair if not already present:
  ```bash
  ssh-keygen -t ed25519 -C "curt@opscenter"
  ```
- Copy public key to all hosts (`nas`, `forge`, `dns`, `node`)  
- Enable key-only authentication for all remote connections

---

## ⚙️ Tools & Setup

- Tailscale client installed and connected:
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up --hostname opscenter
  ```
- `.bash_aliases` file includes:
  - Host shortcuts
  - Docker helpers
  - UFW, diagnostics

```bash
source ~/.bash_aliases
```

- Preferred browser: Firefox (for NAS dashboards, NGINX, Portainer)

---

## 🧪 Validation Tasks

- SSH access:
  ```bash
  ssh admin@nas.cpoff.com
  ssh pi@dns.cpoff.com
  ```
- Tailscale overlay status:
  ```bash
  tailscale status
  ```
- DNS Resolution:
  ```bash
  dig forge.cpoff.com @192.168.99.2
  ```

- Confirm access to:
  - http://dashy.cpoff.com
  - http://node.cpoff.com:19999
  - https://nas.cpoff.com
  - https://portainer.cpoff.com

---

## 🛠️ Admin Workflow

- Use workstation to apply UFW updates remotely  
- Git-edit and commit `.md` documentation files  
- Monitor logs and run tests from centralized shell  
- Optionally run Grafana or Netdata viewers locally if added to fleet

---

_Last Updated: SkyNet Prod 3 – Pop!_OS Workstation_
