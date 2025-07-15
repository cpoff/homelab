dietpi-update && \
dietpi-software install 162 && \  # Docker
dietpi-software install 182 && \  # Docker Compose
dietpi-software install 183 && \  # Dockge
dietpi-software install 174 && \  # Fail2Ban (optional)
dietpi-software install 170 && \  # WireGuard tools (optional)
reboot
