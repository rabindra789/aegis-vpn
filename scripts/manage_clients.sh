#!/usr/bin/env bash
#===========================================================
# Aegis-VPN Client Manager
# Author: Rabindra
# Description: Add, remove, or list clients interactively
# Usage: sudo ./manage-clients.sh [add|remove|list]
#===========================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"
CLIENTS_DIR="$BASE_DIR/clients"
mkdir -p $CLIENTS_DIR
WG_DIR="/etc/wireguard"
WG_INTERFACE="wg0"

# Source log-hooks
source "$SCRIPTS_DIR/log_hooks.sh"

function add_client() {
    read -p "Enter client name: " CLIENT_NAME
    if [ -z "$CLIENT_NAME" ]; then
        echo "[!] Client name cannot be empty."
        log_error "Attempted to add client with empty name"
        return 1
    fi
    "$SCRIPTS_DIR/add_client.sh" "$CLIENT_NAME"
}

function remove_client() {
    read -p "Enter client name to remove: " CLIENT_NAME
    if [ -z "$CLIENT_NAME" ]; then
        echo "[!] Client name cannot be empty."
        log_error "Attempted to remove client with empty name"
        return 1
    fi

    CONF="$CLIENTS_DIR/$CLIENT_NAME.conf"
    if [ -f "$CONF" ]; then
        rm -f "$CONF"
        echo "[*] Removed $CONF"

        # Remove from server config
        sed -i "/# $CLIENT_NAME/,/\[Peer\]/d" "$WG_DIR/$WG_INTERFACE.conf" || true
        wg set $WG_INTERFACE peer "$(grep -A1 "# $CLIENT_NAME" $WG_DIR/$WG_INTERFACE.conf | grep PublicKey | awk '{print $3}')" remove 2>/dev/null || true

        log_connection "$CLIENT_NAME" "N/A" "disconnected"
        log_audit "Client removed: $CLIENT_NAME"
        echo "[*] Client $CLIENT_NAME successfully removed from server and logs."
    else
        echo "[!] Client not found!"
        log_error "Attempted to remove non-existing client: $CLIENT_NAME"
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
    *) echo "[!] Invalid action. Use add, remove, or list."
        log_error "Invalid action in manage-clients.sh: $ACTION" ;;
esac
