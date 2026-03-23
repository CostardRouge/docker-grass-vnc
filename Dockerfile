# Start with a pre-configured Debian desktop environment
FROM lscr.io/linuxserver/webtop:debian-xfce

# Switch to the root user to install software
USER root

# Copy your local .deb file into the container's temporary folder
COPY grass.deb /tmp/grass.deb

# Update package lists, install the .deb (and any dependencies), then delete the installer
RUN apt-get update && \
    apt-get install -y ca-certificates at-spi2-core && \
        update-ca-certificates && \
    apt-get install -y /tmp/grass.deb && \
    rm /tmp/grass.deb

# We don't need a CMD instruction because the base image already handles starting the GUI!