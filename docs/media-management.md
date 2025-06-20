# SkyNet Media Management Stack – Sonarr + Radarr Blueprint

This document outlines how to deploy Sonarr and Radarr as a unified pipeline for managing TV and movie libraries in your Plex environment. These tools automate download, organization, and metadata for seamless ingestion into `nas.cpoff.com`.

---

## 🧰 Core Function

| Tool    | Use Case                              | Content Type |
|---------|----------------------------------------|--------------|
| **Sonarr** | TV series management and auto-download | TV Shows     |
| **Radarr** | Movie management and auto-download     | Movies       |

---

## 🧠 Deployment Strategy

- Location: `forge.cpoff.com` or nested in Docker stack on `nas.cpoff.com`
- Reverse Proxy: Routed via NGINX Proxy Manager on `nas.cpoff.com`
- DNS (Pi-hole):  
  - `sonarr.cpoff.com → 192.168.10.3`  
  - `radarr.cpoff.com → 192.168.10.3`

---

## 📦 Docker Compose Sample

```yaml
version: '3.8'
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Denver
    volumes:
      - /data/config/sonarr:/config
      - /media:/media
      - /downloads:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Denver
    volumes:
      - /data/config/radarr:/config
      - /media:/media
      - /downloads:/downloads
    ports:
      - 7878:7878
    restart: unless-stopped
```

---

## 🔁 Download Workflow Overview

```text
Internet Feed → Torrent/NZB Indexer (e.g. NZBGeek, Jackett)
                ↓
          Sonarr / Radarr
                ↓
        Download Client (qBittorrent, SABnzbd)
                ↓
   Files auto-renamed + moved to /media
                ↓
         Plex scans → Library updated
```

---

## 🔧 Folder Mapping Example

```bash
/media/
├── TV/                   ← Sonarr Target
│   └── Breaking Bad/
│       └── Season 01/
├── Movies/               ← Radarr Target
│   └── The Matrix (1999)/
```

---

## 🛡️ UFW Port Recommendations (`forge.cpoff.com`)

```bash
ufw allow from 192.168.10.0/24 to any port 7878 proto tcp  # Radarr
ufw allow from 192.168.10.0/24 to any port 8989 proto tcp  # Sonarr
```

---

## 🧪 Validation Checklist

- [ ] Access `http://sonarr.cpoff.com:8989` and `radarr.cpoff.com:7878`
- [ ] Add indexers (e.g., Jackett, Usenet)
- [ ] Link to download client (via Web UI)
- [ ] Confirm auto-rename + file structure in `/media`
- [ ] Plex reflects updated media within a scan interval

---

## 🔧 Optional Add-ons

| Tool      | Role                         |
|-----------|------------------------------|
| **Jackett** | Torrent indexer aggregator |
| **Bazarr**  | Subtitle fetch + sync      |
| **Tautulli**| Plex usage analytics        |

---

_Last Updated: SkyNet Prod 3 – Media Management Pipeline_
