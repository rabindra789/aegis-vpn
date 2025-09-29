# Contributing to Aegis-VPN

Thank you for your interest in contributing to **Aegis-VPN**!  
By contributing, you help make this VPN project more secure, reliable, and user-friendly.

This guide outlines how to contribute effectively, including reporting issues, submitting pull requests, and following coding standards.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)  
- [How to Contribute](#how-to-contribute)  
  - [Reporting Issues](#reporting-issues)  
  - [Suggesting Features](#suggesting-features)  
  - [Submitting Pull Requests](#submitting-pull-requests)  
- [Development Setup](#development-setup)  
- [Coding Standards](#coding-standards)  
- [Testing Your Changes](#testing-your-changes)  
- [License](#license)  

---

## Code of Conduct

Please follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/).  
All contributors are expected to be respectful, constructive, and professional.

---

## How to Contribute

### Reporting Issues

If you find a bug, vulnerability, or unexpected behavior:

1. Check if the issue already exists in [Issues](https://github.com/rabindra789/aegis-vpn/issues).  
2. Open a new issue with the following information:
   - **Title:** Short descriptive name of the problem.
   - **Description:** Clear explanation of the issue.
   - **Steps to Reproduce:** Include commands, scripts, or configuration snippets.
   - **Expected vs Actual Behavior**
   - **Environment Details:** OS, WireGuard version, server type, etc.
3. Attach logs, screenshots, or diagrams if relevant.

---

### Suggesting Features

To propose a new feature or improvement:

1. Check if a similar feature request exists.  
2. Open a new issue with:
   - **Feature Description:** What it does and why it is useful.
   - **Use Cases:** Example scenarios where this feature helps.
   - **Optional:** Draft of implementation idea or diagram.

---

### Submitting Pull Requests

1. Fork the repository.  
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/aegis-vpn.git
    ```

3. Create a new branch:

   ```bash
   git checkout -b feature/awesome-feature
   ```
4. Make your changes with clear commit messages:

   ```bash
   git commit -m "Add feature X to improve VPN client setup"
   ```
5. Push your branch:

   ```bash
   git push origin feature/awesome-feature
   ```
6. Open a Pull Request against the `main` branch with:

   * Clear description of changes
   * Reference related issues (e.g., `Fixes #12`)
   * Screenshots, if UI or CLI changes are involved
7. Wait for review, respond to comments, and iterate as needed.

> ⚠️ Do not push directly to `main`.

---

## Development Setup

To work locally:

1. Install **WireGuard** and required packages:

   ```bash
   sudo apt update
   sudo apt install wireguard qrencode bash
   ```
2. Clone the repository:

   ```bash
   git clone https://github.com/rabindra789/aegis-vpn.git
   cd aegis-vpn
   ```
3. Use the **setup script** for a test environment:

   ```bash
   sudo ./setup.sh --auto
   ```
4. Add a test client:

   ```bash
   sudo ./manage_client.sh add test-client
   ```

---

## Coding Standards

* Use **bash scripting best practices**:

  * Use `#!/usr/bin/env bash` shebang
  * Quote variables: `"$VAR"`
  * Use functions for repeated logic
  * Handle errors gracefully with `set -e` or custom error checks
* Comments are **mandatory** for complex sections.
* Follow **naming conventions**:

  * Scripts: `snake_case.sh`
  * Variables: `UPPERCASE` for constants, `lowercase` for locals

---

## Testing Your Changes

Before submitting PRs:

1. Test on a **fresh VPS instance**.
2. Ensure scripts:

   * Successfully run end-to-end
   * Generate client configs correctly
   * Apply firewall rules without errors
3. Verify **WireGuard connectivity** and packet routing.

---

## License

By contributing, you agree that your contributions will be licensed under the **MIT License**.
