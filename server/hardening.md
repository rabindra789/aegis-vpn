# WireGuard Server Hardening Notes

## 1. Kernel & System
- Ensure latest kernel updates installed.
- Enable IP forwarding (`net.ipv4.ip_forward=1`).
- Disable unused services and ports.

## 2. Firewall
- Only allow UDP on WireGuard port (default 51820).
- Restrict SSH to admin IPs.
- Use UFW or iptables for persistent rules.

## 3. WireGuard
- Keep server private key secure (`chmod 600`).
- Rotate keys periodically.
- Monitor `wg show` for active peers.

## 4. Logging & Monitoring
- Enable logging for connection attempts.
- Consider using fail2ban for brute-force protection.
