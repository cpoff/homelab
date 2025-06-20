# SkyNet Admin Alias Library (`~/.bash_aliases`)

```bash
# === [🔥 UFW – Firewall Control] ===
alias ufwstatus="sudo ufw status numbered"
alias ufwreset="sudo ufw reset && echo 'Firewall reset. Reload your baseline rules.'"
alias ufwreload="sudo ufw reload"
alias ufwtail="journalctl -u ufw -f"

# === [📦 Docker Shortcuts] ===
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias logs="docker compose logs -f"
alias dockernuke="docker system prune -af --volumes"

# === [🔒 Tailscale Utilities] ===
alias tsstatus="tailscale status"
alias tsip="tailscale ip -4 | head -n 1"
alias tsping="tailscale ping dns.cpoff.com && tailscale ping forge.cpoff.com"

# === [🧠 Host Access – Core Nodes] ===
alias forge="ssh curt@forge.cpoff.com"
alias nas="ssh admin@nas.cpoff.com"
alias dns="ssh pi@dns.cpoff.com"
alias node="ssh pi@node.cpoff.com"
alias routerui="firefox http://router.cpoff.com"
alias switchui="firefox http://switch.cpoff.com"

# === [🖥️ System Control – Desktop Tools] ===
alias updates="sudo apt update && sudo apt upgrade -y"
alias rebootme="sudo reboot now"
alias cleanme="sudo apt autoremove -y && sudo apt autoclean"
alias alertlog="journalctl -p 3 -xb"

# === [🔍 Diagnostic Utilities] ===
alias skynetmap="echo 'Trusted: 192.168.10.x | IoT: 192.168.20.x | Infra: 192.168.99.x'"
alias netcheck="ping -c 4 dns.cpoff.com && ping -c 4 1.1.1.1"
alias portwatch="sudo netstat -tulpn | grep LISTEN"
```
