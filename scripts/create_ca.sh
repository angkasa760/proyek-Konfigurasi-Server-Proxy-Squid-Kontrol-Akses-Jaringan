#!/bin/bash
# ===================================================================
# create_ca.sh - Automated Certificate Authority Generator
# Usage: sudo ./create_ca.sh [COUNTRY] [STATE] [CITY] [ORG] [OU] [CN] [DAYS]
# ===================================================================

set -euo pipefail

# Default Identity Values
COUNTRY="${1:-ID}"
STATE="${2:-Jakarta}"
CITY="${3:-Jakarta}"
ORG="${4:-NetworkLab}"
OU="${5:-CyberSecurity}"
CN="${6:-SquidCA}"
DAYS="${7:-3650}"

SSL_DIR="/etc/squid/ssl_cert"
SSL_DB_DIR="/var/lib/ssl_db"
KEY_FILE="${SSL_DIR}/myCA.key"
CRT_FILE="${SSL_DIR}/myCA.crt"
PEM_FILE="${SSL_DIR}/myCA.pem"

if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] This script must be run as root (sudo)."
  exit 2
fi

echo "[*] Creating SSL directories..."
mkdir -p "${SSL_DIR}"
chmod 755 "${SSL_DIR}"

echo "[*] Generating CA private key (4096 bits)..."
openssl genrsa -out "${KEY_FILE}" 4096
chmod 640 "${KEY_FILE}"

echo "[*] Generating self-signed CA certificate..."
openssl req -new -x509 -days "${DAYS}" \
  -key "${KEY_FILE}" \
  -out "${CRT_FILE}" \
  -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${OU}/CN=${CN}"

chmod 644 "${CRT_FILE}"

echo "[*] Combining certificate and key for Squid (PEM)..."
cat "${CRT_FILE}" "${KEY_FILE}" > "${PEM_FILE}"
chmod 640 "${PEM_FILE}"
chown -R squid:squid "${SSL_DIR}" || true

# Find and Initialize ssl_crtd DB
SSL_CRTD_BIN=""
for path in "/usr/lib64/squid/ssl_crtd" "/usr/lib/squid/ssl_crtd" "/usr/libexec/squid/security_file_certgen"; do
  if [ -x "$path" ]; then
    SSL_CRTD_BIN="$path"
    break
  fi
done

if [ -n "${SSL_CRTD_BIN}" ]; then
  echo "[*] Initializing SSL DB at ${SSL_DB_DIR} ..."
  sudo rm -rf "${SSL_DB_DIR}"
  "${SSL_CRTD_BIN}" -c -s "${SSL_DB_DIR}" -M 4MB || true
  chown -R squid:squid "${SSL_DB_DIR}" || true
  echo "[+] SSL DB initialized successfully."
else
  echo "[!] Warning: ssl_crtd binary not found. You may need to initialize the DB manually."
fi

echo ""
echo "===================================================="
echo "CA Certification Summary:"
echo " - CA Certificate: ${CRT_FILE}"
echo " - CA Private Key: ${KEY_FILE}"
echo " - Squid PEM File: ${PEM_FILE}"
echo "===================================================="
echo "[TIP] Import ${CRT_FILE} to client browsers to trust this proxy."
