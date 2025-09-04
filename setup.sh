#!/bin/bash
#===========================================================
# Aegis vpn Setup Script (Germany Server)
# Author: Rabindra
# Description: Fully automated WireGuard setup, firewall
#              hardening, and system tuning for secure VPN.
# Usage: sudo ./setup.sh
#===========================================================

set -e 

# Variable
WG_INTERFACE="wg0"
WG_PORT="51820"
SERVER_PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
WG_DIR="/etc/wireguard"
CLIENT_NAME="$PWD/clients"

# Install Wireguard
apt-get update
apt-get install -y wireguard qrencode iptables-persistent

# Enable IP forwarding
echo "[*] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sed -i '/^net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

# Generate server keys
echo "[*] Generating server keys..."
mkdir -p $WG_DIR
cd $WG_DIR
wg genkey | tee privatekey | wg pubkey > publickey
SERVER_PRIVATE_KEY=$(cat privatekey)
SERVER_PUBLIC_KEY=$(cat publickey)

# Create wg0.conf
echo "[*] Creating $WG_INTERFACE.conf..."
cat > $WG_INTERFACE.conf <<EOF
[Interface]
Address = 10.10.0.1/24
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY
SaveConfig = true
PostUp = iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -A FORWARD -o $WG_INTERFACE -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -D FORWARD -o $WG_INTERFACE -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

chmod 600 $WG_INTERFACE.conf

# Start & Enable Wireguard
echo "[*] Starting WireGuard..."
systemctl enable wg-quick@$WG_INTERFACE
systemctl start wg-quick@$WG_INTERFACE

# Firewall
echo "[*] Applying basic firewall rules..."
ufw allow $WG_PORT/udp
ufw enable

echo "[*] WireGuard setup complete!"
echo "Server Public IP: $SERVER_PUBLIC_IP"
echo "Config file location: $WG_DIR/$WG_INTERFACE.conf"
