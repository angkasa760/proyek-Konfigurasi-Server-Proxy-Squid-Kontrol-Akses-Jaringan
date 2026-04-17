#!/bin/bash
# ===================================================================
# backup_config.sh - Backup Konfigurasi Squid Proxy
# Usage: sudo ./scripts/backup_config.sh
# ===================================================================

set -euo pipefail

BACKUP_DIR="/var/backup/squid"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/squid_config_${TIMESTAMP}.tar.gz"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Script ini harus dijalankan sebagai root (sudo)."
    exit 1
fi

echo "[*] Membuat direktori backup: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

echo "[*] Membackup konfigurasi Squid..."
tar -czf "${BACKUP_FILE}" \
    /etc/squid/ \
    /etc/sysconfig/squid 2>/dev/null || true

echo "[+] Backup berhasil: ${BACKUP_FILE}"
echo ""

# Bersihkan backup lama (lebih dari 30 hari)
echo "[*] Membersihkan backup lama (>30 hari)..."
find "${BACKUP_DIR}" -name "squid_config_*.tar.gz" -mtime +30 -delete
echo "[+] Cleanup selesai."

# Tampilkan daftar backup yang ada
echo ""
echo "Daftar backup tersedia:"
ls -lh "${BACKUP_DIR}"/*.tar.gz 2>/dev/null || echo "  (tidak ada)"
