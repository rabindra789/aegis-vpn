#!/usr/bin/env bash
#===========================================================
# Aegis-VPN Setup Script v1.3 (Security Patch - iptables)
# Author: Rabindra
# Description:
#   - WireGuard server (wg0) on 10.10.0.0/24
#   - IPv4 full tunnel for clients (0.0.0.0/0)
#   - IPv6 enabled inside tunnel only (no broken NAT66 hacks)
#   - iptables-only firewall (no UFW)
#   - NAT + forwarding correctly configured
# Usage:
#   sudo ./setup.sh [--auto]
#===========================================================

set -euo pipefail

# --------- Config ---------
WG_INTERFACE="wg0"
WG_PORT="${WG_PORT:-51820}"

WG_DIR="/etc/wireguard"
CLIENTS_DIR="$PWD/clients"

SERVER_V4_CIDR="10.10.0.1/24"
SERVER_V6_CIDR="fd86:ea04:1115::1/64"

# Clients: full IPv4 tunnel, IPv6 internal only (safe default)
CLIENT_ALLOWED_IPS_V4="0.0.0.0/0"
CLIENT_ALLOWED_IPS_V6="fd86:ea04:1115::/64"

DNS_SERVERS="1.1.1.1, 1.0.0.1"
SSH_PORT="${SSH_PORT:-22}"
ALLOW_PING=true

AUTO_MODE=false
[[ "${1:-}" == "--auto" ]] && AUTO_MODE=true

# --------- Helpers ---------
log()  { printf '[*] %s\n' "$*"; }
err()  { printf '[!] %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        die "This script must be run as root (use sudo)."
    fi
}

maybe_install_figlet() {
    if ! command -v figlet >/dev/null 2>&1; then
        log "Installing figlet for banner..."
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y figlet >/dev/null 2>&1 || true
    fi
}

banner() {
    clear || true
    if command -v figlet >/dev/null 2>&1; then
        figlet -f big "AEGIS VPN"
    else
        echo "AEGIS VPN"
    fi
    echo -e "\e[1;32mSecure, Fast, Modern\e[0m"
    echo -e "\e[1;33mby Rabindra - v1.3 (iptables)\e[0m"
    echo
}

detect_wan_interface() {
    # Try to detect default egress interface
    local ifc
    ifc=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {for (i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}' | head -n1)
    if [[ -z "$ifc" ]]; then
        ifc=$(ip route show default 2>/dev/null | awk '/dev/ {for (i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}' | head -n1)
    fi
    if [[ -z "$ifc" ]]; then
        err "Could not auto-detect WAN interface, falling back to eth0"
        WAN_IF="eth0"
    else
        WAN_IF="$ifc"
    fi
    log "Using '$WAN_IF' as WAN interface."
}

get_public_ip() {
    SERVER_PUBLIC_IP=$(curl -4s https://ifconfig.co || curl -4s https://api.ipify.org || echo "UNKNOWN")
}

disable_ufw_if_present() {
    if command -v ufw >/dev/null 2>&1; then
        log "Disabling UFW (iptables-only mode)..."
        ufw disable || true
        systemctl disable ufw 2>/dev/null || true
    fi
}

install_packages() {
    log "Installing dependencies..."
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        wireguard wireguard-tools qrencode \
        iptables iptables-persistent \
        curl >/dev/null
}

enable_ip_forwarding() {
    log "Enabling IPv4 and IPv6 forwarding..."
    local SYSCTL_FILE="/etc/sysctl.conf"

    # Immediate effect
    sysctl -w net.ipv4.ip_forward=1 >/dev/null
    sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null

    # Persist across reboot
    sed -i '/^net\.ipv4\.ip_forward/d' "$SYSCTL_FILE"
    sed -i '/^net\.ipv6\.conf\.all\.forwarding/d' "$SYSCTL_FILE"
    {
        echo "net.ipv4.ip_forward=1"
        echo "net.ipv6.conf.all.forwarding=1"
    } >> "$SYSCTL_FILE"

    sysctl -p >/dev/null
}

ensure_dirs() {
    mkdir -p "$WG_DIR" "$CLIENTS_DIR"
    chmod 700 "$WG_DIR"
}

generate_server_keys() {
    log "Generating WireGuard server keys..."
    umask 077
    wg genkey | tee "$WG_DIR/server_private.key" | wg pubkey > "$WG_DIR/server_public.key"
    SERVER_PRIVATE_KEY=$(<"$WG_DIR/server_private.key")
    SERVER_PUBLIC_KEY=$(<"$WG_DIR/server_public.key")
}

write_server_config() {
    log "Writing $WG_DIR/$WG_INTERFACE.conf ..."
    cat > "$WG_DIR/$WG_INTERFACE.conf" <<EOF
[Interface]
Address = ${SERVER_V4_CIDR}, ${SERVER_V6_CIDR}
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}
SaveConfig = true

# No iptables in PostUp/PostDown – firewall managed separately and persisted.
EOF
    chmod 600 "$WG_DIR/$WG_INTERFACE.conf"
}

apply_firewall_rules() {
    log "Applying iptables firewall rules (drop-by-default)..."

    # Flush and reset
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X

    ip6tables -F
    ip6tables -X
    ip6tables -t nat -F 2>/dev/null || true
    ip6tables -t nat -X 2>/dev/null || true

    # Default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    ip6tables -P INPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -P OUTPUT ACCEPT

    # Allow loopback
    iptables  -A INPUT -i lo -j ACCEPT
    ip6tables -A INPUT -i lo -j ACCEPT

    # Allow established/related
    iptables  -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow ICMP (optional but sane)
    if $ALLOW_PING; then
        iptables  -A INPUT -p icmp -j ACCEPT
        ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
    fi

    # Allow SSH
    iptables  -A INPUT -p tcp --dport "$SSH_PORT" -m conntrack --ctstate NEW -j ACCEPT
    ip6tables -A INPUT -p tcp --dport "$SSH_PORT" -m conntrack --ctstate NEW -j ACCEPT

    # Allow WireGuard UDP
    iptables  -A INPUT -p udp --dport "$WG_PORT" -m conntrack --ctstate NEW -j ACCEPT
    ip6tables -A INPUT -p udp --dport "$WG_PORT" -m conntrack --ctstate NEW -j ACCEPT

    # Forward wg0 <-> WAN (IPv4 + IPv6)
    iptables -A FORWARD -i "$WG_INTERFACE" -o "$WAN_IF" -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -i "$WAN_IF" -o "$WG_INTERFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    ip6tables -A FORWARD -i "$WG_INTERFACE" -o "$WAN_IF" -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A FORWARD -i "$WAN_IF" -o "$WG_INTERFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # NAT for IPv4 clients
    iptables -t nat -A POSTROUTING -s "${SERVER_V4_CIDR%/*}/24" -o "$WAN_IF" -j MASQUERADE

    # Persist rules
    log "Saving iptables rules via iptables-persistent..."
    netfilter-persistent save >/dev/null 2>&1 || {
        iptables-save > /etc/iptables/rules.v4
        ip6tables-save > /etc/iptables/rules.v6
    }
}

enable_wireguard() {
    log "Enabling and starting WireGuard..."
    systemctl enable "wg-quick@${WG_INTERFACE}"
    systemctl restart "wg-quick@${WG_INTERFACE}"
}

maybe_create_first_client() {
    if $AUTO_MODE; then
        return
    fi

    echo
    read -rp "Create first client now? (y/N): " ans
    [[ "$ans" =~ ^[Yy]$ ]] || return

    read -rp "Client name (no spaces): " CLIENT_NAME
    [[ -z "$CLIENT_NAME" ]] && die "Client name cannot be empty."

    local CLIENT_IPv4="10.10.0.2/32"
    local CLIENT_DIR="${CLIENTS_DIR}/${CLIENT_NAME}"
    mkdir -p "$CLIENT_DIR"
    umask 077

    wg genkey | tee "${CLIENT_DIR}/private.key" | wg pubkey > "${CLIENT_DIR}/public.key"

    local CLIENT_PRIV CLIENT_PUB
    CLIENT_PRIV=$(<"${CLIENT_DIR}/private.key")
    CLIENT_PUB=$(<"${CLIENT_DIR}/public.key")

    # Append peer to server config
    cat >> "$WG_DIR/$WG_INTERFACE.conf" <<EOF

[Peer]
# ${CLIENT_NAME}
PublicKey = ${CLIENT_PUB}
AllowedIPs = ${CLIENT_IPv4}
EOF

    # Generate client config
    cat > "${CLIENT_DIR}/${CLIENT_NAME}.conf" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = 10.10.0.2/32, fd86:ea04:1115::2/128
DNS = ${DNS_SERVERS}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_PUBLIC_IP}:${WG_PORT}
AllowedIPs = ${CLIENT_ALLOWED_IPS_V4}, ${CLIENT_ALLOWED_IPS_V6}
PersistentKeepalive = 25
EOF

    log "Client config written to: ${CLIENT_DIR}/${CLIENT_NAME}.conf"

    if command -v qrencode >/dev/null 2>&1; then
        log "QR code for mobile (wg-quick / WireGuard app):"
        qrencode -t ansiutf8 < "${CLIENT_DIR}/${CLIENT_NAME}.conf"
    fi

    log "Reloading WireGuard config with new peer..."
    wg setconf "$WG_INTERFACE" <(wg-quick strip "$WG_INTERFACE")
}

# --------- MAIN ---------
require_root
maybe_install_figlet
banner
disable_ufw_if_present
install_packages
enable_ip_forwarding
ensure_dirs
detect_wan_interface
get_public_ip
generate_server_keys
write_server_config
apply_firewall_rules
enable_wireguard
maybe_create_first_client

echo
log "Aegis-VPN v1.3 setup complete."
log "Public IP: ${SERVER_PUBLIC_IP}"
log "Server config: ${WG_DIR}/${WG_INTERFACE}.conf"
log "Client configs (if created): ${CLIENTS_DIR}"
