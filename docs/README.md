# 🛡️ Aegis-VPN v1.2

![Aegis-VPN](https://github.com/rabindra789/aegis-vpn/blob/main/images/image.png)
Aegis‑VPN is built on top of the open-source WireGuard protocol, delivering a lightweight, high-performance, and secure VPN solution for remote access, internal testing, and private networks. 
Fully automated and well documented, Aegis‑VPN gives operators and users full control over server provisioning, client onboarding (including QR-based mobile setup), and security best practices such as IPv6 dual‑stack support and unattended installations.

---

## 🚀 Features

* **WireGuard VPN**: Fast, modern, and secure VPN connections.
* **Automated Server Setup**: `setup.sh` installs WireGuard, configures firewall rules, and prepares the server.
* **Client Management**: `manage_client.sh` allows adding, removing, and listing clients.
* **Interactive Menu System**: `bin/aegis-vpn` provides a terminal-based menu for server and client management.
* **Security Hardening**: Implements best practices for secure server deployment.
* **Documentation & Diagrams**: Architecture and network diagrams included.
* **Mobile & Desktop Support**: QR codes for mobile apps; `.conf` files for desktop clients.
* **IPv6 Dual-Stack**: Supports IPv4 + IPv6.
* **Open-Source & Transparent**: Everything is automated and documented for learning and contribution.

---

## 📁 Repository Structure

```
aegis-vpn/
├── bin/                  # Interactive menu scripts, including aegis-vpn.sh
├── clients/              # Client configuration files and onboarding guides
├── diagrams/             # Architecture and networking diagrams
├── docs/                 # Documentation (why WireGuard, security model, contributing)
├── images/               # Images used in documentation and README
├── scripts/              # Helper scripts for automation and setup
├── server/               # Server configuration files and hardening notes
├── var/log/aegis-vpn/    # Logs for server and clients
├── cleanup.sh            # Full cleanup script to remove server setup
├── setup.sh              # Automated server setup script
└── manage_client.sh      # Script to add/remove/list VPN clients
```

---

## ⚙️ Installation & Usage

### 1. Setup Server

```bash
sudo ./setup.sh
```

* Installs WireGuard, server configs, firewall rules.
* For unattended installation (ideal for VPS or cloud):

```bash
sudo ./setup.sh --auto
```

### 2. Manage Clients

```bash
sudo ./manage_client.sh add <client-name>
sudo ./manage_client.sh remove <client-name>
sudo ./manage_client.sh list
```

* Mobile: scan QR code displayed in terminal.
* Desktop: import the `.conf` file into WireGuard.

### 3. Interactive Menu

```bash
cd bin/
./aegis-vpn
```

The menu allows:

* Starting/stopping VPN service
* Adding/removing/listing clients
* Viewing server and client status
* Accessing configuration files
* Monitoring connected clients

---

## 📚 Documentation

* [`docs/why-wireguard.md`](docs/why-wireguard.md) – Rationale for WireGuard over OpenVPN/IPSec
* [`docs/security-model.md`](docs/security-model.md) – Threat model & mitigations

![VPN Flow Diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/architecture.png)
![NAT & Routing Diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/networking.png)

---

## 🛠️ Roadmap (v1.2)

**Implemented in v1.2**:

* Unified client management via `manage_client.sh`
* Auto QR codes for mobile clients
* Unattended installation mode (`--auto`)
* IPv6 dual-stack support
* Terminal banner (ASCII art)
* Interactive menu system (`bin/aegis-vpn`)
* Improved error handling & dependency checks
* Client logging & monitoring

**Planned Features:**

* Automated key rotation & expiration
* Optional DNS-over-HTTPS / DNS-over-TLS
* Advanced firewall hardening with rate-limiting and geo-blocking

---

## 🤝 Contribution

Contributions are welcome! Workflow:

1. **Fork** the repository
2. Create a new **branch** for your feature or bug fix
3. **Commit** changes with clear messages
4. **Push** to your fork
5. Submit a **pull request**

Refer to [`docs/contributing.md`](docs/contributing.md) for guidelines.

---

## 📄 License

MIT License – see [LICENSE](LICENSE) file.
