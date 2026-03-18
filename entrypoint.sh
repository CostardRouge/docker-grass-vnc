#!/bin/bash
set -e

# Clean up stale VNC lock files from previous container runs
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# Ensure log directory exists
mkdir -p /var/log/supervisor

echo "========================================"
echo "  Grass VNC Container Starting"
echo "  VNC  → port 5901 (any VNC client)"
echo "  Web  → http://<host>:6080/vnc.html"
echo "  Pass → vncpassword (change in Dockerfile)"
echo "========================================"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
