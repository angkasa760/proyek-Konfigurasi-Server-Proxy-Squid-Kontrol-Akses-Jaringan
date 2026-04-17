#!/bin/bash
# ===================================================================
# master_dashboard.sh - High-Fidelity Squid Proxy Status Dashboard
# Usage: sudo ./scripts/master_dashboard.sh
# ===================================================================

set -e

# --- Visual Styles ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}======================================================"
echo -e "   ⚓ SQUID PROXY ENTERPRISE - MASTER DASHBOARD"
echo -e "   $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "======================================================${NC}"

# --- 1. Service Status ---
echo -e "\n${BOLD}[1] CORE SERVICES STATUS${NC}"
services=("squid" "c-icap" "clamd@scan" "httpd")

for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        echo -e "  %-15s : ${GREEN}ACTIVE${NC}" "$svc"
    else
        echo -e "  %-15s : ${RED}INACTIVE${NC}" "$svc"
    fi
done

# --- 2. Network Ports ---
echo -e "\n${BOLD}[2] NETWORK LISTENERS${NC}"
ports=("3128:Proxy" "3129:SSL-Bump" "1344:ICAP" "80:SARG/Web")

for pinfo in "${ports[@]}"; do
    port="${pinfo%%:*}"
    label="${pinfo#*:}"
    if ss -tlnp 2>/dev/null | grep -q ":$port"; then
        echo -e "  %-15s : ${GREEN}LISTENING${NC}" "$label ($port)"
    else
        echo -e "  %-15s : ${YELLOW}CLOSED${NC}" "$label ($port)"
    fi
done

# --- 3. Resource Usage ---
echo -e "\n${BOLD}[3] RESOURCE USAGE (SQUID)${NC}"
if pgrep squid > /dev/null; then
    CPU=$(ps -C squid -o %cpu --no-headers | awk '{s+=$1} END {print s"%"}')
    MEM=$(ps -C squid -o %mem --no-headers | awk '{s+=$1} END {print s"%"}')
    UPTIME=$(ps -C squid -o etime --no-headers | head -1 | sed 's/ //g')
    echo -e "  CPU Usage      : $CPU"
    echo -e "  Memory Usage   : $MEM"
    echo -e "  Uptime         : $UPTIME"
else
    echo -e "  ${RED}Squid process not found.${NC}"
fi

# --- 4. Live Traffic Stream ---
echo -e "\n${BOLD}[4] RECENT TRAFFIC (access.log - Last 5)${NC}"
LOG="/var/log/squid/access.log"
if [ -f "$LOG" ]; then
    tail -5 "$LOG" | awk '{print "  " $3 " -> " $7 " [" $4 "]"}' | cut -c1-100
else
    echo -e "  ${YELLOW}Log file not found.${NC}"
fi

# --- 5. Security Warnings ---
echo -e "\n${BOLD}[5] SECURITY & INTEGRITY${NC}"
if [ -f "/etc/squid/ssl_cert/myCA.crt" ]; then
    echo -e "  SSL Inspection : ${GREEN}ENABLED (CA Found)${NC}"
else
    echo -e "  SSL Inspection : ${YELLOW}NOT SETUP (CA Missing)${NC}"
fi

if grep -q "icap_enable on" /etc/squid/squid.conf 2>/dev/null; then
    echo -e "  ICAP Scanning  : ${GREEN}ACTIVE${NC}"
else
    echo -e "  ICAP Scanning  : ${YELLOW}INACTIVE${NC}"
fi

echo -e "\n${CYAN}======================================================${NC}"
echo -e "${BOLD}Dashboard complete. Press Ctrl+C to exit.${NC}"
# ===================================================================
