# Homelab Ansible: DHCP + Pi-hole Automation

## Features
- Local DHCP served by raspi5 (dnsmasq)
- Static IP reservations from MAC addresses
- Pi-hole DNS record syncing
- Declarative host topology

## Usage

Install Ansible:
```bash
sudo apt update && sudo apt install ansible

# 🧭 Subnet Migration: Installation Order Guide

A sequenced approach for migrating devices to a new subnet using a TP-Link router and Ansible automation.

---

## ⚙️ Step 1: Update TP-Link Router LAN Settings
- Change LAN IP (e.g. `192.168.0.1` → `12.12.1.1`)
- Set new DHCP range: `12.12.1.100–199`
- Save and reboot router

> ✅ This aligns DHCP and routing infrastructure before hosts come online with static IPs.

---

## 📌 Step 2: Add Static Reservations (Optional)
- Use TP-Link UI to bind MAC addresses to intended IPs in the new range
- Acts as redundancy in case playbook changes are deferred

---

## 🚀 Step 3: Deploy Ansible Playbook
Run your playbook to configure devices for the new network:
- Push static IP settings (or clear existing ones)
- Apply custom DNS settings (e.g. Pi-hole)
- Align `/etc/network/interfaces` with new subnet

> 🔁 Devices will reboot or renew leases, syncing with the new LAN config.

---

## 🧪 Step 4: Post-Migration Validation
- Check device status via Pi-hole or `dnsmasq.leases`
- SSH into each device using new IP
- Confirm DNS resolution is functional

---

### 💡 Notes
If reverting to default subnet:
- Undo router config
- Re-run playbook with old static IPs
- Restore previous DHCP and DNS settings

---

**Last Updated:** `2025-08-01`

