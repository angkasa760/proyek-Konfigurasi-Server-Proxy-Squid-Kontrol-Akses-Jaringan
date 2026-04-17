# Enterprise Squid Proxy & Secure Web Gateway (SWG) Configuration

![Squid Proxy Banner](https://img.shields.io/badge/Squid-4.x-blue.svg) ![Security](https://img.shields.io/badge/Security-Access%20Control-red.svg) ![Platform](https://img.shields.io/badge/Platform-CentOS%207-orange.svg)

A professional-grade implementation of **Squid Proxy** on CentOS 7, designed for cybersecurity labs and corporate network environments. This repository provides highly optimized configurations for traffic control, SSL interception (HTTPS inspection), and advanced access management.

## ðŸš€ Key Features

*   **Secure Web Gateway (SWG)**: Full control over inbound and outbound web traffic.
*   **HTTPS Interception (SSL Bump)**: Ability to inspect encrypted traffic for advanced threat protection.
*   **Access Control Lists (ACLs)**: Granular rules based on IP, domains, and keywords.
*   **Website & Extension Blocking**: Pre-configured lists to block malicious or unproductive domains and file types (`.exe`, `.iso`, etc.).
*   **Authentication Integration**: Templates for LDAP and basic authentication.
*   **Network Lab Topology**: Includes a visual guide for lab setup.

---

## ðŸ— Network Architecture

The deployment follows a centralized gateway model where the Squid Server acts as the intermediary for all client requests.

![Network Topology](docs/assets/topology.png)

*   **Internal Network**: `172.24.0.0/16`
*   **Proxy Port**: `3128` (Explicit HTTP) / `3129` (SSL Bump)

---

## ðŸ›  Installation & Deployment

### 1. Prerequisites
*   CentOS 7 (Minimal or Server with GUI)
*   Root or sudo access
*   Two network interfaces (WAN & LAN recommended)

### 2. Quick Install
Run the automated installation script to setup Squid and essential dependencies:

```bash
chmod +x scripts/install_and_service.sh
sudo ./scripts/install_and_service.sh
```

### 3. Apply Configuration
Deploy the enterprise-grade configuration files:

```bash
sudo cp configs/squid/squid.conf /etc/squid/squid.conf
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo systemctl restart squid
```

---

## ðŸ“‚ Repository Structure

```text
â”œâ”€â”€ configs/
â”‚   â”œâ”€â”€ squid/               # Core Squid configuration files
â”‚   â”‚   â”œâ”€â”€ squid.conf       # Main configuration (Enterprise Template)
â”‚   â”‚   â”œâ”€â”€ blocked_sites.txt # Domain blocklist
â”‚   â”‚   â””â”€â”€ auth.conf        # Authentication templates
â”‚   â””â”€â”€ firewall/            # Network security & iptables rules
â”œâ”€â”€ scripts/                 # Automation and maintenance scripts
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ architecture/        # Project design and topology
â”‚   â”œâ”€â”€ guides/              # Step-by-step implementation guides
â”‚   â”œâ”€â”€ manuals/             # legacy PDF documentations
â”‚   â””â”€â”€ assets/              # Images and diagrams
â””â”€â”€ README.md                # Project documentation
```

---

## ðŸ›¡ï¸ Security Best Practices

> [!WARNING]
> SSL Interception (SSL Bump) decrypts private traffic. Ensure users are notified and compliance policies are met before enabling this in a production environment.

> [!TIP]
> Always verify the `squid.conf` syntax before restarting the service: `sudo squid -k parse`

## ðŸ“‹ Documentation Guides

*   [Client Setup Guide](docs/guides/client_setup.md)
*   [Verification & Troubleshooting](docs/guides/verification.md)
*   [Advanced SWG Deployment](docs/guides/deployment_swg.md)

---

## ðŸŽ“ Author & Lab Focus
Developed as part of a **Network Configuration & Cybersecurity** laboratory project. Focus areas: Proxy Mechanics, Access Control, and Perimeter Security.

---
Â© 2026 angkasa760 | Enterprise Network Engineering Lab
