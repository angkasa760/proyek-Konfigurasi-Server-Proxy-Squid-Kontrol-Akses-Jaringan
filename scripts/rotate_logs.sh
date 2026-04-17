#!/bin/bash
# ===================================================================
# rotate_logs.sh - Rotasi & Kompresi Log Squid Proxy
# Usage: sudo ./scripts/rotate_logs.sh
# Rekomendasi: Jadwalkan via cron — 0 0 * * 0 /path/to/rotate_logs.sh
# ===================================================================

set -euo pipefail

LOG_DIR="/var/log/squid"
ARCHIVE_DIR="/var/log/squid/archive"
TIMESTAMP=$(date '+%Y%m%d')
KEEP_DAYS=30

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Script ini harus dijalankan sebagai root (sudo)."
    exit 1
fi

mkdir -p "${ARCHIVE_DIR}"

echo "[*] Memulai rotasi log Squid — $(date)"

for LOGFILE in access.log cache.log; do
    SRC="${LOG_DIR}/${LOGFILE}"
    DEST="${ARCHIVE_DIR}/${LOGFILE%.log}_${TIMESTAMP}.log.gz"
    
    if [ -f "$SRC" ] && [ -s "$SRC" ]; then
        echo "[*] Mengarsipkan: ${SRC} -> ${DEST}"
        gzip -c "${SRC}" > "${DEST}"
        > "${SRC}"  # Kosongkan file asli (truncate)
        echo "[+] Selesai: ${DEST}"
    else
        echo "[!] ${SRC} tidak ada atau kosong, dilewati."
    fi
done

# Reload Squid agar menulis ke log yang sudah dikosongkan
echo "[*] Reconfiguring Squid..."
squid -k rotate 2>/dev/null || true

# Hapus arsip lama
echo "[*] Membersihkan arsip lama (>${KEEP_DAYS} hari)..."
find "${ARCHIVE_DIR}" -name "*.log.gz" -mtime "+${KEEP_DAYS}" -delete

echo ""
echo "[+] Rotasi log selesai — $(date)"
echo ""
echo "Arsip tersedia di: ${ARCHIVE_DIR}"
ls -lh "${ARCHIVE_DIR}"/*.log.gz 2>/dev/null | tail -10 || echo "  (tidak ada arsip)"
