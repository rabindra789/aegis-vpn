# 🛡️ Aegis-VPN

![Aegis-VPN](https://github.com/rabindra789/aegis-vpn/blob/main/images/image.png)

**Aegis-VPN** is an **open-source WireGuard VPN** project for secure remote access and safe testing environments. Fully automated, documented, and designed to eliminate the “mystery box” feeling of commercial VPNs.

Everything is transparent: server setup, client onboarding, hardening, and networking – you can run it yourself and understand what’s happening under the hood.

---

## Features

* Fast, modern, and secure **WireGuard VPN**
* Automated server setup (`setup.sh`)
* Easy client management (`manage_client.sh`) – add, remove, list
* Hardened server configuration and firewall rules
* Fully documented with **architecture & network diagrams**
* Mobile-ready with QR codes for client setup

---

## Repository Structure

```
personal-vpn-server/
├── setup.sh              # Automated server setup
├── manage_client.sh      # Add, remove, list clients
├── cleanup.sh            # Full cleanup script
├── server/               # Server configs & hardening notes
├── clients/              # Client configs & onboarding guide
├── diagrams/             # Architecture & networking diagrams
├── docs/                 # Documentation and guides
└── LICENSE               # MIT License
```

---

## Quick Start

### 1. Setup Server

```bash
sudo ./setup.sh
```

* Installs WireGuard, server configuration, and firewall rules automatically.
* Optional unattended mode:

```bash
sudo ./setup.sh --auto
```

---

### 2. Manage Clients

```bash
sudo ./manage_client.sh add <client-name>
sudo ./manage_client.sh remove <client-name>
sudo ./manage_client.sh list
```

* Mobile setup: scan the QR code displayed in the terminal using the WireGuard app.
* Desktop setup: import the generated `.conf` file.

---

### 3. Verify Connection

```bash
sudo wg show
ping 10.10.0.1
```

---

## Documentation

* [`docs/why-wireguard.md`](docs/why-wireguard.md) – Why WireGuard over OpenVPN/IPSec
* [`docs/security-model.md`](docs/security-model.md) – Threat model & mitigation strategies

![VPN flow diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/architecture.png)
![NAT & routing diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/networking.png)

---

## Roadmap (v1.1)

* ✅ Unified client management (`manage_client.sh`)
* ✅ Auto QR codes for mobile clients
* ✅ Unattended installation (`--auto`)
* ✅ IPv6 dual-stack support
* ✅ Terminal banner (ASCII art)
* ✅ Improved error handling & dependency checks

**Future improvements:**

* Client logging & monitoring
* Automated key rotation
* Optional DNS-over-HTTPS / DNS-over-TLS
* Advanced firewall rules with rate-limiting and geo-blocking

---

## Contribution

Contributions, bug reports, and feature requests are welcome! Please read the [CONTRIBUTING.md](docs/contributing.md) guide if you want to contribute.

---

## License

MIT License – see [LICENSE](LICENSE) file.
