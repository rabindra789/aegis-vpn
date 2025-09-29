#!/bin/bash
#===========================================================
# Aegis-VPN Cleanup Script
# Author: Rabindra
# Description: Completely removes Aegis-VPN setup, configs,
#              firewall rules, and WireGuard for all users.
# Usage: sudo ./cleanup.sh
#===========================================================

set -e

echo "[*] Stopping and disabling WireGuard..."
systemctl stop wg-quick@wg0 2>/dev/null || true
systemctl disable wg-quick@wg0 2>/dev/null || true
systemctl daemon-reload

echo "[*] Removing VPN configuration files..."
rm -rf /etc/wireguard
rm -rf /home/*/aegis-vpn/clients
rm -rf /home/*/aegis-vpn/diagrams
rm -rf /home/*/aegis-vpn/docs
rm -f /home/*/aegis-vpn/setup.sh
rm -f /home/*/aegis-vpn/add-client.sh
rm -f /home/*/aegis-vpn/manage-clients.sh
rm -f /home/*/aegis-vpn/LICENSE

echo "[*] Removing firewall rules..."
ufw delete allow 51820/udp || true
ufw reload || true
iptables -F || true
ip6tables -F || true

echo "[*] Removing WireGuard and dependencies (optional)..."
apt-get remove --purge wireguard wireguard-tools qrencode ufw -y || true
apt-get autoremove -y || true

echo "[*] Cleanup complete! Your system no longer has Aegis-VPN."
