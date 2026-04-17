#!/bin/bash
# ===================================================================
# health_check.sh - Squid Proxy Health Monitor
# Usage: sudo ./scripts/health_check.sh
# ===================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "OK" ]; then
        echo -e "  [${GREEN}OK${NC}] $label"
        ((PASS++))
    else
        echo -e "  [${RED}FAIL${NC}] $label — $result"
        ((FAIL++))
    fi
}

warn() {
    echo -e "  [${YELLOW}WARN${NC}] $1"
}

echo "======================================================"
echo "  Squid Proxy Health Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "======================================================"
echo ""

# 1. Service Status
echo "[1] Service Status"
if systemctl is-active --quiet squid; then
    check "squid.service aktif" "OK"
else
    check "squid.service aktif" "Service tidak berjalan — jalankan: sudo systemctl start squid"
fi

# 2. Port Listening
echo ""
echo "[2] Port Listening"
if ss -tlnp 2>/dev/null | grep -q ":3128"; then
    check "Port 3128 (HTTP Proxy) terbuka" "OK"
else
    check "Port 3128 (HTTP Proxy) terbuka" "Port tidak terbuka"
fi

if ss -tlnp 2>/dev/null | grep -q ":3129"; then
    check "Port 3129 (SSL Bump) terbuka" "OK"
else
    warn "Port 3129 (SSL Bump) tidak terbuka — normal jika SSL Bump tidak diaktifkan"
fi

# 3. Config Syntax
echo ""
echo "[3] Konfigurasi"
if squid -k parse 2>&1 | grep -qi "error"; then
    check "Sintaks squid.conf valid" "Ada error di konfigurasi — jalankan: squid -k parse"
else
    check "Sintaks squid.conf valid" "OK"
fi

# 4. Log Files
echo ""
echo "[4] File Log"
if [ -f /var/log/squid/access.log ]; then
    check "access.log ada" "OK"
    LAST=$(tail -1 /var/log/squid/access.log 2>/dev/null || echo "kosong")
    echo "       Last entry: $LAST"
else
    check "access.log ada" "File tidak ditemukan"
fi

# 5. Cache Directory
echo ""
echo "[5] Cache Directory"
if [ -d /var/spool/squid ]; then
    USAGE=$(du -sh /var/spool/squid 2>/dev/null | cut -f1)
    check "Cache directory ada (/var/spool/squid)" "OK"
    echo "       Ukuran cache: $USAGE"
else
    check "Cache directory ada" "Tidak ditemukan — jalankan: sudo squid -z"
fi

# 6. Process
echo ""
echo "[6] Proses"
PID=$(pgrep squid | head -1 || echo "")
if [ -n "$PID" ]; then
    check "Proses Squid berjalan (PID: $PID)" "OK"
else
    check "Proses Squid berjalan" "Proses tidak ditemukan"
fi

# Summary
echo ""
echo "======================================================"
echo -e "  Hasil: ${GREEN}${PASS} OK${NC} | ${RED}${FAIL} GAGAL${NC}"
echo "======================================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
