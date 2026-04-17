#!/bin/bash
# ===================================================================
# setup_icap.sh - Professional ICAP & ClamAV (Antivirus) Integration
# Target OS: CentOS 7 / RHEL 7
# ===================================================================

set -e

# --- Styles ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
error() { echo -e "${RED}[!]${NC} $1"; exit 1; }

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)."
fi

# --- Main Script ---
log "Enabling EPEL Repository for c-icap..."
yum install -y epel-release -q || true

log "Installing ClamAV, ClamD, and c-icap modules..."
yum install -y clamav clamav-update clamd c-icap c-icap-modules -q || {
    error "Failed to install ICAP components. Ensure EPEL is reachable."
}

log "Configuring ClamD (Antivirus Engine)..."
# Enable clamd in scan.conf
if [ -f /etc/clamd.d/scan.conf ]; then
    sed -i 's/^Example/#Example/' /etc/clamd.d/scan.conf
    sed -i -e 's|^#LocalSocket .*|LocalSocket /var/run/clamd.scan/clamd.sock|' /etc/clamd.d/scan.conf
    success "ClamD configured (Socket: /var/run/clamd.scan/clamd.sock)"
fi

log "Updating ClamAV signature database..."
freshclam || log "Freshclam encountered an issue. Normal if recently updated."

log "Configuring c-icap for ClamAV integration..."
ICAP_CONF="/etc/c-icap/c-icap.conf"
if [ -f "$ICAP_CONF" ]; then
    # Basic c-icap tuning
    sed -i 's/^ServerPort.*/ServerPort 1344/' "$ICAP_CONF"
    # Enable antivirus service if commented
    sed -i 's/^#Service antivirus.*/Service antivirus antivirus.so/' "$ICAP_CONF" || true
    success "c-icap configured for port 1344."
fi

log "Starting and enabling services..."
systemctl enable clamav-freshclam clamd@scan c-icap -q
systemctl restart clamd@scan c-icap
success "ICAP and Antivirus services initiated."

# --- Verification ---
echo ""
echo "------------------------------------------------------"
log "ICAP Health Check:"
systemctl is-active c-icap >/dev/null && success "c-icap: RUNNING" || error "c-icap: FAILED"
systemctl is-active clamd@scan >/dev/null && success "clamd: RUNNING" || error "clamd: FAILED"
ss -tlnp | grep -q ":1344" && success "Port 1344: LISTEN" || error "Port 1344: DOWN"
echo "------------------------------------------------------"

echo ""
success "ICAP Setup Complete."
log "Add this to your squid.conf to activate scanning:"
echo "------------------------------------------------------"
echo "icap_enable on"
echo "icap_service service_avi_resp respmod_precache icap://127.0.0.1:1344/antivirus"
echo "adaptation_access service_avi_resp allow all"
echo "------------------------------------------------------"
# ===================================================================
