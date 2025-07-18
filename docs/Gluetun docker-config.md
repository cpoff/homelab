# Prod 1.3.0 — Docker Compose Configuration

This configuration sets up Gluetun with IVPN using WireGuard, optimized for performance with secure environment variable management.

## docker-compose.yml

```yaml
version: "3"
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    env_file:
      - .env
