#!/bin/bash
#===========================================================
# Aegis-VPN Client Manager
# Author: Rabindra
# Description: Add, remove, or list clients interactively
# Usage: sudo ./manage-clients.sh [add|remove|list]
#===========================================================

WG_INTERFACE="wg0"
WG_DIR="/etc/wireguard"
CLIENTS_DIR="$PWD/clients"
mkdir -p $CLIENTS_DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function add_client() {
    read -p "Enter client name: " CLIENT_NAME
    "$DIR/add_client.sh" "$CLIENT_NAME"
}

function remove_client() {
    read -p "Enter client name to remove: " CLIENT_NAME
    CONF="$CLIENTS_DIR/$CLIENT_NAME.conf"
    if [ -f "$CONF" ]; then
        rm -f "$CONF"
        echo "[*] Removed $CONF"
        # TODO: Remove from server config and wg
        echo "[!] Remember to manually remove peer from server config or wg interface."
    else
        echo "[!] Client not found!"
    fi
}

function list_clients() {
    echo "[*] Existing clients:"
    ls $CLIENTS_DIR | grep '.conf$' || echo "No clients found."
}

# Main
if [ -z "$1" ]; then
    echo "Choose action: add / remove / list"
    read ACTION
else
    ACTION="$1"
fi

case $ACTION in
    add) add_client ;;
    remove) remove_client ;;
    list) list_clients ;;
    *) echo "[!] Invalid action. Use add, remove, or list." ;;
esac
