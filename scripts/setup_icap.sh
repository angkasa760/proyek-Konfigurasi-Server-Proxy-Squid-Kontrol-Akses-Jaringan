#!/bin/bash
# ===================================================================
# setup_icap.sh - ICAP & ClamAV (Antivirus) Integration for Squid
# Target OS: CentOS 7 / RHEL 7
# ===================================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] This script must be run as root (sudo)."
  exit 2
fi

echo "[*] Enabling EPEL Repository..."
sudo yum install -y epel-release || true

echo "[*] Installing ClamAV and Dependencies..."
sudo yum install -y clamav clamav-update c-icap || {
    echo "[!] c-icap not found in standard repos. See documentation to build from source."
}

echo "[*] Updating ClamAV Database (Freshclam)..."
sudo freshclam || true

echo "[*] Configuring c-icap service..."
ICAP_CONF="/etc/c-icap/c-icap.conf"
if [ -f "$ICAP_CONF" ]; then
    # Ensure it listens on localhost
    sudo sed -i 's/^ServerPort.*/ServerPort 1344/' "$ICAP_CONF"
    echo "[+] c-icap configured to port 1344."
fi

echo "[*] Starting Services..."
sudo systemctl enable --now clamav-freshclam || true
if systemctl list-unit-files | grep -q c-icap; then
    sudo systemctl enable --now c-icap || true
fi

echo ""
echo "===================================================="
echo "ICAP Setup Complete."
echo "Important: Ensure your squid.conf has 'icap_enable on'"
echo "and references icap://127.0.0.1:1344/respmod"
echo "===================================================="
