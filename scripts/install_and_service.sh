#!/bin/bash
# ===================================================================
# Squid Proxy Installation & Service Management Script
# Target OS: CentOS 7 / RHEL 7
# ===================================================================

set -e

echo "[*] Updating system repositories..."
sudo yum update -y | grep -i "error" || true

echo "[*] Installing Squid Proxy Server..."
sudo yum install squid openssl -y

echo "[*] Initializing Squid cache directories..."
# -z creates swap directories
sudo squid -z

echo "[*] Enabling and starting Squid service..."
sudo systemctl enable squid
sudo systemctl start squid

echo "[*] Verifying Service Status..."
sudo systemctl status squid --no-pager

echo ""
echo "[SUCCESS] Squid Proxy has been installed and started."
echo "[INFO] Configuration path: /etc/squid/squid.conf"
echo "[INFO] Access logs: /var/log/squid/access.log"
# ===================================================================
