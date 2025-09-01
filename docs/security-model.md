# WireGuard Security Model

## Threats Considered
- MITM attacks: mitigated via public-key crypto.
- Unauthorized access: only peers with valid keys allowed.
- IP leaks: AllowedIPs ensures routing through VPN only.
- Brute-force attempts: firewall + fail2ban recommended.

## Assumptions
- Server private key is never exposed.
- Clients keep their private keys secure.
- Admin monitors active peers regularly.
