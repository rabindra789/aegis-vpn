# Adding a New WireGuard Client

This guide explains how to add a new client to your WireGuard VPN server.

---

## 1. Generate Client Configuration

Run the `add-client.sh` script with your chosen client name:

```bash
sudo ./add-client.sh <client-name>
```

```bash
sudo ./add-client.sh <client-name>
```

-   Creates a client configuration file at `clients/<client-name>.conf`.
-   Displays a QR code for quick mobile setup.

---

## 2. Connect on Mobile/Desktop

### Mobile

-   Open the WireGuard app.
-   Scan the QR code displayed in the terminal.
-   The client will be added automatically.

### Desktop

-   Import the generated configuration file `<client-name>.conf` into your WireGuard client.

---

## 3. Verify Connection

Check the connection on the server:

```bash
sudo wg show
ping 10.10.0.1
```

-   The client should appear in `wg show`.
-   `ping` to the server VPN IP should succeed.

---

## Notes

-   Each client gets a unique VPN IP automatically.
-   Keep client private keys secure.
-   Use descriptive client names for easier management.
