#!/usr/bin/env bash
#===========================================================
# Aegis VPN Log Hooks
# Author: Rabindra
# Description: Logging functions for connection, error, and audit events.
#===========================================================

# Paths
LOG_DIR="$(dirname "$(dirname "$0")")/var/log/aegis-vpn"
CONNECTION_LOG="$LOG_DIR/connections.log"
ERROR_LOG="$LOG_DIR/errors.log"
AUDIT_LOG="$LOG_DIR/audit.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR"

# Ensure log files exist
touch "$CONNECTION_LOG" "$ERROR_LOG" "$AUDIT_LOG"
chmod 600 "$CONNECTION_LOG" "$ERROR_LOG" "$AUDIT_LOG"

# Timestamp helper
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Logging Functions

# Log client connection/disconnection
# Usage: log_connection "peer_name" "vpn_ip" "connected|disconnected"
log_connection() {
    local peer="$1"
    local ip="$2"
    local action="$3"
    local ts
    ts=$(timestamp)

    echo "[$ts] event=client_$action peer=$peer ip=$ip" >> "$CONNECTION_LOG"
}

# Log errors
# Usage: log_error "Error message"
log_error() {
    local msg="$1"
    local ts
    ts=$(timestamp)

    echo "[$ts] event=error message=\"$msg\"" >> "$ERROR_LOG"
}

# Log audit events (server start/stop/config reload)
# Usage: log_audit "Audit message"
log_audit() {
    local msg="$1"
    local ts
    ts=$(timestamp)

    echo "[$ts] event=audit message=\"$msg\"" >> "$AUDIT_LOG"
}

# Example usage (can be removed in production)

    # log_connection "rk-client" "10.0.0.2" "connected"
    # log_error "Handshake failed for peer alice"
    # log_audit "Server started (v1.2)"
