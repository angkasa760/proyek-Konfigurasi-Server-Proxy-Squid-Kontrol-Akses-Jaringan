# Squid Proxy Server & Secure Web Gateway (SWG)

[![Squid](https://img.shields.io/badge/Squid-4.x-2563eb?style=flat-square&logo=nginx&logoColor=white)](https://www.squid-cache.org/)
[![Platform](https://img.shields.io/badge/Platform-CentOS_7-ee0000?style=flat-square&logo=redhat&logoColor=white)](https://centos.org/)
[![Security](https://img.shields.io/badge/Security-Access_Control-16a34a?style=flat-square&logo=shieldsdotio&logoColor=white)](https://github.com/angkasa760)
[![PowerShell](https://img.shields.io/badge/Scripted-Bash_%26_PowerShell-5391fe?style=flat-square&logo=powershell&logoColor=white)](https://github.com/angkasa760)

> Implementasi Squid Proxy berbasis CentOS 7 untuk lingkungan lab jaringan virtual. Proyek ini mencakup konfigurasi traffic control, SSL interception (HTTPS inspection), website blocking, autentikasi, dan integrasi antivirus via ICAP.

---

## Fitur Utama

- **Secure Web Gateway (SWG)** — Kendali penuh atas traffic HTTP/HTTPS masuk dan keluar
- **HTTPS Interception (SSL Bump)** — Inspeksi traffic terenkripsi untuk deteksi ancaman lanjutan
- **Access Control Lists (ACL)** — Aturan granular berbasis IP, domain, dan kata kunci
- **Website & Extension Blocking** — Daftar blokir domain dan tipe file berbahaya (`.exe`, `.iso`, dll.)
- **Autentikasi LDAP** — Template integrasi dengan Active Directory / OpenLDAP
- **Malware Scanning (ICAP + ClamAV)** — Pemindaian file unduhan secara real-time
- **Topologi Lab Virtual** — Diagram arsitektur jaringan untuk referensi setup

---

## Arsitektur Jaringan

Model penerapan terpusat: Squid Server sebagai gateway tunggal antara semua client dan internet.

![Network Topology](docs/assets/topology.png)

| Parameter | Nilai |
|---|---|
| Internal Network | `172.24.0.0/16` |
| Proxy Port (HTTP) | `3128` |
| Proxy Port (SSL Bump) | `3129` |

---

## Instalasi & Deployment

### Prasyarat
- CentOS 7 (Minimal atau Server with GUI)
- Akses root / sudo
- Dua network interface (WAN + LAN disarankan)

### Langkah 1 — Install Squid

```bash
chmod +x scripts/install_and_service.sh
sudo ./scripts/install_and_service.sh
```

### Langkah 2 — Terapkan Konfigurasi

```bash
sudo cp configs/squid/squid.conf /etc/squid/squid.conf
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo systemctl restart squid
```

### Langkah 3 — (Opsional) SSL Interception

Generate Certificate Authority (CA):

```bash
chmod +x scripts/create_ca.sh
sudo ./scripts/create_ca.sh
```

Deploy CA ke client Windows (jalankan sebagai Administrator):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\deploy_ca_windows.ps1 -CertPath "C:\path\to\myCA.crt"
```

### Langkah 4 — (Opsional) ICAP + ClamAV

```bash
chmod +x scripts/setup_icap.sh
sudo ./scripts/setup_icap.sh
```

---

## Struktur Repository

```text
.
├── configs/
│   ├── squid/
│   │   ├── squid.conf          # Konfigurasi utama Squid (Enterprise Template)
│   │   ├── blocked_sites.txt   # Daftar domain yang diblokir
│   │   ├── auth.conf           # Template autentikasi
│   │   └── denial_rules.conf   # Aturan http_access deny
│   └── firewall/
│       └── centos7_rules.sh    # Aturan firewall untuk CentOS 7
├── scripts/
│   ├── install_and_service.sh  # Instalasi otomatis Squid
│   ├── create_ca.sh            # Generate Certificate Authority untuk SSL Bump
│   ├── setup_icap.sh           # Setup ICAP + ClamAV (Malware Scanning)
│   └── deploy_ca_windows.ps1  # Deploy CA ke client Windows
├── docs/
│   ├── guides/
│   │   ├── client_setup.md     # Panduan konfigurasi client (Linux & Windows)
│   │   ├── verification.md     # Panduan verifikasi & troubleshooting
│   │   └── advanced_swg.md     # Panduan SWG lanjutan (SSL Bump, ICAP, Auth)
│   ├── manuals/                # Dokumen PDF konfigurasi (referensi lab)
│   └── assets/
│       └── topology.png        # Diagram topologi jaringan
└── README.md
```

---

## Verifikasi Cepat

Setelah instalasi, pastikan proxy berjalan:

```bash
# Cek status service
sudo systemctl status squid

# Monitor traffic secara real-time
sudo tail -f /var/log/squid/access.log

# Test koneksi melewati proxy
curl -x http://172.24.0.1:3128 -I http://example.com
```

**Expected output di log:**
- Traffic diizinkan: `TCP_MISS/200`
- Traffic diblokir: `TCP_DENIED/403`

---

## Panduan Lanjutan

- [Konfigurasi Client (Linux & Windows)](docs/guides/client_setup.md)
- [Verifikasi & Troubleshooting](docs/guides/verification.md)
- [SWG Lanjutan: SSL Bump, ICAP, Autentikasi](docs/guides/advanced_swg.md)

---

## Catatan Keamanan

> **Peringatan:** SSL Interception (SSL Bump) mendekripsi traffic privat. Pastikan pengguna telah diberitahu dan kebijakan kepatuhan terpenuhi sebelum diaktifkan di lingkungan produksi.

> **Tips:** Selalu validasi sintaks `squid.conf` sebelum restart: `sudo squid -k parse`

---

**Fokus Proyek:** Proxy Mechanics, Access Control, Perimeter Security

Dikembangkan sebagai bagian dari proyek lab **Konfigurasi Jaringan & Keamanan Siber**.

© 2026 angkasa760