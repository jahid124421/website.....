FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Fix: Add i386 architecture and update apt indexes in the same step
RUN dpkg --add-architecture i386 && apt update

# Install all desktop, RDP, browser, and 32-bit Wine dependencies
RUN apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32 \
    firefox-esr && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root" | chpasswd

# Configure X11 wrapper permissions
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# Setup user session for root login
RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# Optimize XRDP settings for better client compatibility and lower latency
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

# Assign user permissions for SSL certificates
RUN adduser xrdp ssl-cert

# Copy setup entrypoint shell script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
