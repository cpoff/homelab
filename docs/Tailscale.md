# SkyNet Overlay – Tailscale Integration Guide

This document provides a unified configuration standard for deploying Tailscale across all nodes in the SkyNet Prod 3 network. It ensures secure, peer-to-peer connectivity across VLANs and geographic locations without port forwarding or VPN overhead.

---

## 🧭 Purpose

- **Mesh Connectivity**: Direct node-to-node access regardless of VLAN/subnet  
- **Remote Access**: Secure admin control via Pop!_OS or mobile Tailscale clients  
- **Service Tunneling**: Optional ingress paths to Plex, Netdata, CasaOS  
- **Zero-Trust ACLs**: Restrict services at overlay level via Tailscale console  

---

## 🛠️ Installation (All Devices)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

**Bring online (initial auth):**

```bash
sudo tailscale up --authkey tskey-xxxxxxxxxxxxxxxx --hostname <hostname>
```

- Replace `<hostname>` with the node name: `dns`, `forge`, `node`, `nas`, etc.  
- Use a pre-generated ephemeral auth key from your [admin portal](https://login.tailscale.com/admin/settings/keys)

Confirm connection:

```bash
tailscale status
tailscale ip -4
```

---

## 🌐 Behavior and Scope

| Device           | Tailscale Use Case                                         |
|------------------|------------------------------------------------------------|
| `dns.cpoff.com`  | Allow DNS resolution via port 53 (optional ACL)            |
| `nas.cpoff.com`  | Secure access to Plex, HA, NGINX Proxy Manager             |
| `forge.cpoff.com`| App dashboards (CasaOS, Jellyfin) for internal use         |
| `node.cpoff.com` | Netdata dashboard + ping/metrics tunneling                 |
| Pop!_OS Desktop  | Admin SSH + dashboard access to all nodes via overlay      |

> Optional hostname convention: Match `--hostname` to each node’s short name for clarity in status views.

---

## 🔐 ACL and Tagging Suggestions

Define ACLs in the admin portal (JSON-based):

```json
{
  "tagOwners": {
    "tag:infra": ["autogroup:admin"],
    "tag:media": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "users": ["autogroup:admin"],
      "ports": [
        "dns.cpoff.com:53",
        "nas.cpoff.com:32400",
        "node.cpoff.com:19999",
        "forge.cpoff.com:3000-3999"
      ]
    }
  ]
}
```

Attach tags during join:

```bash
sudo tailscale up --authkey tskey-xxxxx --hostname node --advertise-tags=tag:infra
```

---

## 🧠 Device-Specific Notes

### 📡 `dns.cpoff.com`

- Optional: Respond to DNS over Tailscale (must permit 53 from overlay)  
- Optionally advertise as a DNS nameserver via `--advertise-routes` (not currently used in SkyNet)

### 📦 `nas.cpoff.com`

- Accept HTTPS from Tailscale IP range (100.64.0.0/10)  
- Allow access to:
  - Plex Web: https://nas.cpoff.com:32400/web  
  - Portainer, HA, NPM via subdomains  
- May serve as central ingress hub

### 🛠️ `forge.cpoff.com`

- Useful for launching Dashy, Jellyfin, CasaOS remotely  
- Expose only if ACLs are enforced  
- Optionally run services via NGINX Proxy Manager or `tailscale serve` (experimental)

### 📊 `node.cpoff.com`

- Minimal exposure  
- Ping diagnostics via overlay (`tailscale ping node`)  
- Netdata reachable from NAS only by UFW rule

---

## 🧪 Validation Tests

From any authorized client:

```bash
# Check overlay mesh
tailscale ping forge
tailscale status

# Access dashboards
curl -s http://node.cpoff.com:19999
curl -s https://nas.cpoff.com:32400/web

# Query DNS resolver
dig dashy.cpoff.com @dns.cpoff.com
```

---

## 🔧 Optional Enhancements

- Create admin-only **Tailscale ACL groups** for each VLAN domain (`tag:infra`, `tag:apps`, `tag:media`)  
- Use Tailscale SSH for passwordless administrative access  
- Enable [tailscale serve](https://tailscale.dev/serve) for reverse proxy via CLI  
- Enable MagicDNS only if compatible with Pi-hole’s authoritative DNS

---

_Last Updated: SkyNet Prod 3 – Overlay Topology (with `nas.cpoff.com` naming)_
