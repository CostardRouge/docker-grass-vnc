# ============================================================
# Grass Desktop App — Docker + VNC
# Base: Ubuntu 22.04 (best .deb / desktop app compatibility)
# Desktop: XFCE4 (lightweight, stable)
# VNC: TigerVNC + noVNC (web browser access on port 6080)
# ============================================================

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Paris \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=6080 \
    VNC_RESOLUTION=1280x800 \
    VNC_COL_DEPTH=24

# ------------------------------------------------------------
# 1. System dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    wget curl ca-certificates gnupg2 software-properties-common \
    # Desktop environment (XFCE4 — lightweight)
    xfce4 xfce4-terminal xfce4-session \
    # VNC server
    tigervnc-standalone-server tigervnc-common \
    # noVNC web client + websockify
    novnc websockify \
    # Font & display essentials
    fonts-dejavu fonts-liberation dbus-x11 x11-xserver-utils \
    # .deb installer deps
    libgbm1 libxshmfence1 libgles2 libasound2 \
    libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 \
    libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libnss3 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libxss1 libxtst6 xdg-utils \
    # Process management
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 2. Install the Grass .deb package
#    Place your .deb file next to the Dockerfile before building
# ------------------------------------------------------------
COPY grass.deb /tmp/grass.deb
RUN apt-get update && \
    dpkg -i /tmp/grass.deb || apt-get install -f -y && \
    rm /tmp/grass.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 3. Create a non-root user to run the app (good practice)
# ------------------------------------------------------------
RUN useradd -m -s /bin/bash grassuser && \
    echo "grassuser:grasspass" | chpasswd

# ------------------------------------------------------------
# 4. VNC password setup (change 'vncpassword' as needed)
# ------------------------------------------------------------
USER grassuser
RUN mkdir -p /home/grassuser/.vnc && \
    echo "vncpassword" | vncpasswd -f > /home/grassuser/.vnc/passwd && \
    chmod 600 /home/grassuser/.vnc/passwd

# VNC startup script — launches XFCE4 session
RUN echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec startxfce4' > /home/grassuser/.vnc/xstartup && \
    chmod +x /home/grassuser/.vnc/xstartup

USER root

# ------------------------------------------------------------
# 5. Supervisor — manages VNC + noVNC processes
# ------------------------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ------------------------------------------------------------
# 6. Entrypoint script
# ------------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ------------------------------------------------------------
# Ports:
#   5901 — VNC (TigerVNC, use any VNC client)
#   6080 — noVNC (browser access at http://<host>:6080/vnc.html)
# ------------------------------------------------------------
EXPOSE 5901 6080

ENTRYPOINT ["/entrypoint.sh"]
