#!/usr/bin/env bash
#===========================================================
# Aegis-VPN Cleanup Script v1.2
# Author: Rabindra
# Description: Completely removes Aegis-VPN setup, configs,
#              logs, firewall rules, and WireGuard for all users.
# Usage: sudo ./cleanup.sh
#===========================================================

set -e

echo "[*] WARNING: This will remove all Aegis-VPN files and configurations."
read -p "Do you really want to continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[*] Cleanup aborted."
    exit 0
fi

# Stop and disable WireGuard
echo "[*] Stopping and disabling WireGuard..."
systemctl stop wg-quick@wg0 2>/dev/null || true
systemctl disable wg-quick@wg0 2>/dev/null || true
systemctl daemon-reload

# Remove Aegis-VPN directories
echo "[*] Removing Aegis-VPN files..."
PROJECT_DIRS=(
    "/etc/wireguard"
    "/home/*/aegis-vpn/clients"
    "/home/*/aegis-vpn/diagrams"
    "/home/*/aegis-vpn/docs"
    "/home/*/aegis-vpn/scripts"
    "/home/*/aegis-vpn/bin"
    "/home/*/aegis-vpn/var"
    "/home/*/aegis-vpn/setup.sh"
    "/home/*/aegis-vpn/LICENSE"
)

for dir in "${PROJECT_DIRS[@]}"; do
    rm -rf $dir 2>/dev/null || true
done

# Remove firewall rules
echo "[*] Removing firewall rules..."
ufw delete allow 51820/udp 2>/dev/null || true
ufw reload 2>/dev/null || true
iptables -F || true
ip6tables -F || true

# Optional: Remove WireGuard & dependencies
read -p "Do you want to remove WireGuard and dependencies? (y/N): " dep_confirm
if [[ "$dep_confirm" == "y" || "$dep_confirm" == "Y" ]]; then
    echo "[*] Removing WireGuard and dependencies..."
    apt-get remove --purge wireguard wireguard-tools qrencode ufw -y || true
    apt-get autoremove -y || true
fi

echo "[*] Cleanup complete! All Aegis-VPN files and settings have been removed."
