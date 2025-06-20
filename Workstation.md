# Pop!_OS Workstation – Admin Control Center

## 📦 Role
- Master console for VLAN management, SSH access, browser UIs
- Hosts admin alias library and terminal dashboard

## 🌐 Network Setup
- **VLAN**: 10 (Trusted)
- **IP**: Static or DHCP-reserved
- **Hostname**: command.cpoff.com (optional)

## 🔐 Admin Tooling

- `.bash_aliases` for UFW, Docker, Tailscale, SSH
- `ufw-gtk` (optional GUI)
- `gnome-terminal` or `tilix` (multi-tab layout)
- `cockpit`, `remmina`, or `virt-manager` (optional)

## 🧪 Validation

- Ping all major nodes:
  - `ping dns.cpoff.com`
  - `ssh forge` (via alias)
- Launch admin dashboards:
  - `routerui`, `switchui`, `nas`, `portainer`

## 📁 Notes

Alias file lives in:

```bash
~/.bash_aliases
```

Reload with:

```bash
source ~/.bash_aliases
```
