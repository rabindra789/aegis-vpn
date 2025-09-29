# 🛡️ Aegis-VPN
![Aegis-VPN](https://github.com/rabindra789/aegis-vpn/blob/main/images/image.png)

- Aegis-VPN is my **personal VPN server project** built on top of [WireGuard](https://www.wireguard.com/).  
- It’s designed to give **secure remote access** without the “mystery box” feeling of commercial VPNs.  
- Everything is open, automated and documented so you can run it yourself.

While building this I ran into all sorts of small obstacles, missing dependencies on some VPSs, odd routing rules, QR code issues on mobile, and figuring out the safest defaults for WireGuard.  
The current version already hides most of those pain-points for you, but you’ll still learn what’s happening under the hood.



## Features

- WireGuard VPN (fast, modern, secure)  
- Automated server setup (`setup.sh`)  
- Easy client addition (`add_client.sh`)  
- Hardened server configuration  
- Documentation & diagrams included  



## Repository Structure
```
personal-vpn-server/
├── setup.sh              # Server setup script
├── add_client.sh         # Add client script
├── manage_client.sh      # manage client script (add, remove, list)
├── cleanup.sh            # Cleanup script for whole setup
├── server/               # Server configs & hardening notes
├── clients/              # Client configs & onboarding guide
├── diagrams/             # Architecture & networking visuals
├── docs/                 # Documentation
└── LICENSE               # License file

```


## Quick Start

### 1. Setup Server
```bash
sudo ./setup.sh
```
- This installs WireGuard, sets up the server configuration and firewall rules automatically.

### 2. Add Clients

```bash
sudo ./manage_client.sh add <client-name>
```
- This generates a .conf file for the client.
- For mobile: scan the QR code displayed in your terminal with the WireGuard app.
- For desktop: import the .conf file.

```bash
sudo ./manage_client.sh remove <client-name>
```
- This removes the client's configuration and revokes their access.

```bash
sudo ./manage_client.sh list
```
- This lists all currently connected clients.

- Scan QR code for mobile setup or import `.conf` on desktop.

### 3. Verify Connection

```bash
sudo wg show
ping 10.10.0.1
```



## Documentation

- `docs/why-wireguard.md` – Why WireGuard over OpenVPN/IPSec

- `docs/security-model.md` – Threat model & mitigations

 ![VPN flow diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/architecture.png)

 ![NAT & routing diagram](https://github.com/rabindra789/aegis-vpn/blob/main/diagrams/networking.png)



## Roadmap (v1.1)

The following features are planned or partially implemented in **Aegis-VPN v1.1**:

* **Interactive Client Management** ✅
  One unified script (`manage_client.sh`) to **add, remove, or list clients**, replacing separate scripts.

* **Auto QR Codes for Mobile Apps** ✅
  After generating a client configuration, a **QR code is displayed automatically** for easy mobile setup.

* **Unattended Install Mode** ✅
  `setup.sh --auto` flag runs a **fully non-interactive installation**, ideal for cloud or VPS deployments.

* **IPv6 Support (Dual Stack)** ✅
  Server and client configurations now support **IPv4 + IPv6 addresses** for dual-stack connectivity.

* **Terminal Banner (ASCII Art)** ✅
  `setup.sh` now displays a **Metasploit-style AEGIS VPN banner** on startup for a professional look.

* **Improved Error Handling & Dependencies** ✅
  Automatic checks and fixes for **missing packages, routing issues, and QR code generation**, minimizing setup pain points.

* **Future Improvements**

  * Logging & monitoring of connected clients
  * Automated key rotation & expiration policies
  * Optional DNS-over-HTTPS or DNS-over-TLS for privacy
  * Advanced firewall hardening with rate-limiting and geo-blocking

Contributions, testing feedback, and suggestions are always welcome!


## License

MIT License – see [LICENSE](LICENSE) file.
