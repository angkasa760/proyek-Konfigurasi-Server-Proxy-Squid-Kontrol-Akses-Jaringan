#!/bin/bash
# ===================================================================
# install_and_service.sh - Professional Squid Proxy Deployment
# Target OS: CentOS 7 / RHEL 7
# ===================================================================

set -e

# --- Styles ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
error() { echo -e "${RED}[!]${NC} $1"; exit 1; }

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)."
fi

log "System Identity Check..."
if ! grep -q "CentOS" /etc/os-release; then
    log "Warning: This script is optimized for CentOS 7. Performance may vary on other distros."
fi

# --- Main Script ---
log "Updating system repositories..."
yum update -y -q || log "Warning: System update encountered issues. Continuing installation..."

log "Installing Squid Proxy Server and dependencies..."
yum install squid openssl httpd-tools -y -q
success "Squid and utilities installed successfully."

log "Initializing Squid cache directories..."
# -z creates swap directories if they don't exist
if [ ! -d /var/spool/squid/00 ]; then
    squid -z || error "Failed to initialize cache directories."
    success "Cache directories initialized."
else
    log "Cache directories already exist. Skipping..."
fi

log "Copying enterprise configuration templates..."
REPO_DIR=$(pwd)
if [ -f "$REPO_DIR/configs/squid/squid.conf" ]; then
    cp "$REPO_DIR/configs/squid/squid.conf" /etc/squid/squid.conf
    cp "$REPO_DIR/configs/squid/blocked_sites.txt" /etc/squid/blocked_sites.txt || true
    success "Enterprise configuration applied."
else
    log "Warning: Local config files not found in standard paths. Using defaults."
fi

log "Enabling and starting Squid service..."
systemctl enable squid -q
systemctl restart squid
success "Squid service is active and enabled."

# --- Verification ---
echo ""
echo "------------------------------------------------------"
log "Deployment Status:"
systemctl is-active squid >/dev/null && success "Service: ACTIVE" || error "Service: FAILED"
ss -tlnp | grep -q ":3128" && success "Port 3128: OPEN" || error "Port 3128: CLOSED"
echo "------------------------------------------------------"

echo ""
success "Deployment Master complete."
log "Next steps: See README.md for SSL Bump and ICAP setup."
# ===================================================================
