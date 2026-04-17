#!/bin/bash
# ===================================================================
# uninstall.sh - Hapus Squid Proxy & semua komponen terkait
# Usage: sudo ./scripts/uninstall.sh
# PERINGATAN: Script ini akan menghapus Squid, konfigurasi, dan cache!
# ===================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Script ini harus dijalankan sebagai root (sudo)."
    exit 1
fi

echo -e "${RED}"
echo "=================================================="
echo "  PERINGATAN: UNINSTALL SQUID PROXY"
echo "=================================================="
echo -e "${NC}"
echo "Script ini akan menghapus:"
echo "  - Squid Proxy (paket & binary)"
echo "  - Konfigurasi: /etc/squid/"
echo "  - Cache: /var/spool/squid/"
echo "  - Log: /var/log/squid/"
echo "  - SSL DB: /var/lib/ssl_db/"
echo ""
echo -e "${YELLOW}Apakah Anda yakin ingin melanjutkan? (ketik 'ya' untuk konfirmasi)${NC}"
read -r KONFIRMASI

if [ "$KONFIRMASI" != "ya" ]; then
    echo "Uninstall dibatalkan."
    exit 0
fi

echo ""
echo "[1/5] Menghentikan dan menonaktifkan service Squid..."
if systemctl is-active --quiet squid 2>/dev/null; then
    systemctl stop squid
    echo -e "  ${GREEN}OK${NC} Service dihentikan."
fi
if systemctl is-enabled --quiet squid 2>/dev/null; then
    systemctl disable squid
    echo -e "  ${GREEN}OK${NC} Service dinonaktifkan."
fi

echo ""
echo "[2/5] Membuat backup konfigurasi terakhir..."
BACKUP_FILE="/root/squid_backup_before_uninstall_$(date +%Y%m%d_%H%M%S).tar.gz"
if [ -d /etc/squid ]; then
    tar -czf "$BACKUP_FILE" /etc/squid/ 2>/dev/null && \
    echo -e "  ${GREEN}OK${NC} Backup tersimpan di: $BACKUP_FILE" || \
    echo -e "  ${YELLOW}WARN${NC} Backup gagal, melanjutkan..."
fi

echo ""
echo "[3/5] Menghapus paket Squid..."
if command -v yum &>/dev/null; then
    yum remove -y squid 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    apt-get remove -y --purge squid squid-common 2>/dev/null || true
fi
echo -e "  ${GREEN}OK${NC} Paket dihapus."

echo ""
echo "[4/5] Membersihkan file dan direktori..."
DIRS_TO_REMOVE=(
    "/etc/squid"
    "/var/spool/squid"
    "/var/log/squid"
    "/var/lib/ssl_db"
    "/etc/squid/ssl_cert"
)
for DIR in "${DIRS_TO_REMOVE[@]}"; do
    if [ -d "$DIR" ]; then
        rm -rf "$DIR"
        echo -e "  ${GREEN}OK${NC} Dihapus: $DIR"
    fi
done

echo ""
echo "[5/5] Membersihkan aturan firewall (jika ada)..."
if command -v firewall-cmd &>/dev/null && firewall-cmd --state &>/dev/null 2>&1; then
    firewall-cmd --permanent --remove-port=3128/tcp 2>/dev/null || true
    firewall-cmd --permanent --remove-port=3129/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    echo -e "  ${GREEN}OK${NC} Port 3128 & 3129 dihapus dari firewall."
fi

echo ""
echo "=================================================="
echo -e "${GREEN}  Uninstall selesai!${NC}"
echo "=================================================="
echo ""
echo "Catatan:"
echo "  - Backup konfigurasi terakhir: $BACKUP_FILE"
echo "  - Jika ingin reinstall: sudo ./scripts/install_and_service.sh"
echo ""
