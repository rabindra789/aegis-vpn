#!/bin/bash
#===========================================================
# WireGuard VPN Client Config Generator
# Author: Rabindra
# Description: Generates client keys, configuration, and QR
#              for easy mobile/desktop setup.
# Usage: sudo ./add-client.sh <client-name>
#===========================================================

set -e


# Check input
if [ -z "$1" ]; then
    echo "Usage: sudo ./add-client.sh <client-name>"
    exit 1
fi

CLIENT_NAME="$1"
WG_INTERFACE="wg0"
WG_DIR="/etc/wireguard"
CLIENTS_DIR="$PWD/clients"
SERVER_PUBLIC_KEY=$(cat $WG_DIR/publickey)
SERVER_IP=$(curl -s https://ipinfo.io/ip)
VPN_SUBNET="10.10.0.0/24"

# Ensure clients directory exists
mkdir -p $CLIENTS_DIR


# Generate client keys
echo "[*] Generating keys for $CLIENT_NAME..."
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)
CLIENT_IP="10.10.0.$(( $(ls $CLIENTS_DIR | grep -c '.conf$') + 2 ))"


# Create client configuration
CLIENT_CONF="$CLIENTS_DIR/$CLIENT_NAME.conf"
echo "[*] Creating client configuration at $CLIENT_CONF..."
cat > $CLIENT_CONF <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

chmod 600 $CLIENT_CONF


# Add client to server
echo "[*] Adding $CLIENT_NAME to server configuration..."
cat >> $WG_DIR/$WG_INTERFACE.conf <<EOF

# $CLIENT_NAME
[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOF

wg addpeer $WG_INTERFACE public-key "$CLIENT_PUBLIC_KEY" allowed-ips "$CLIENT_IP/32"


# Generate QR code
echo "[*] Generating QR code for mobile setup..."
qrencode -t ansiutf8 < $CLIENT_CONF

echo "[*] Client $CLIENT_NAME added successfully!"
echo "Config file: $CLIENT_CONF"
