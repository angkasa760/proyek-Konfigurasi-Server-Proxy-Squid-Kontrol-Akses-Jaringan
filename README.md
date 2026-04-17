# Squid Proxy Server & Secure Web Gateway (SWG)

[![Squid](https://img.shields.io/badge/Squid-4.x-2563eb?style=flat-square&logo=nginx&logoColor=white)](https://www.squid-cache.org/)
[![Platform](https://img.shields.io/badge/Platform-CentOS_7-ee0000?style=flat-square&logo=redhat&logoColor=white)](https://centos.org/)
[![Security](https://img.shields.io/badge/Security-Access_Control-16a34a?style=flat-square&logo=shieldsdotio&logoColor=white)](https://github.com/angkasa760)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ed?style=flat-square&logo=docker&logoColor=white)](docker/)
[![Vagrant](https://img.shields.io/badge/Vagrant-Lab_Ready-1563ff?style=flat-square&logo=vagrant&logoColor=white)](Vagrantfile)
[![CI](https://github.com/angkasa760/proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan/actions/workflows/lint.yml/badge.svg)](https://github.com/angkasa760/proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan/actions)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

> Implementasi Squid Proxy berbasis CentOS 7 untuk lingkungan lab jaringan virtual. Proyek ini mencakup konfigurasi traffic control, SSL interception, website blocking, autentikasi, ICAP antivirus, bandwidth limiting, time-based ACL, dan monitoring traffic.

---

## Fitur Utama

| Fitur | Deskripsi |
|---|---|
| **Secure Web Gateway (SWG)** | Kendali penuh atas traffic HTTP/HTTPS |
| **HTTPS Interception (SSL Bump)** | Inspeksi traffic terenkripsi |
| **Access Control Lists (ACL)** | Rules berbasis IP, domain, kata kunci |
| **Bandwidth Limiting (Delay Pools)** | Batasi kecepatan per-client atau per-jaringan |
| **Time-Based ACL** | Blokir sosmed jam kerja, izinkan jam istirahat |
| **Website & File Blocking** | Domain blocklist + ekstensi berbahaya |
| **Autentikasi LDAP** | Integrasi Active Directory / OpenLDAP |
| **Malware Scanning (ICAP + ClamAV)** | Pemindaian file real-time |
| **SARG Reporting** | Laporan visual traffic per-user dan per-domain |
| **Docker & Vagrant** | Lab portabel, satu perintah langsung jalan |

---

## Arsitektur Jaringan

```
[ Client Linux ]  ---+
[ Client Windows ] --+--- [SWITCH] --- [SQUID PROXY - 172.24.0.1] --- [INTERNET]
[ Client lainnya ] --+       CentOS 7 | Port 3128 (HTTP) | Port 3129 (HTTPS/SWG)
```

![Topologi Jaringan](docs/assets/topology.png)

| Parameter | Nilai |
|---|---|
| Jaringan Internal | `172.24.0.0/16` |
| IP Proxy Server | `172.24.0.1` |
| Port HTTP Proxy | `3128` |
| Port SSL Bump | `3129` |

---

## Quick Start

### Opsi 1 — Vagrant (Paling Mudah)
```bash
# Prasyarat: VirtualBox + Vagrant
vagrant up
# Selesai! VM CentOS 7 + Squid otomatis tersetup.
```

### Opsi 2 — Docker
```bash
cd docker
docker compose up -d
# Squid berjalan di port 3128 host machine
```

### Opsi 3 — Manual di CentOS 7
```bash
# Langkah 1: Install Squid
chmod +x scripts/install_and_service.sh
sudo ./scripts/install_and_service.sh

# Langkah 2: Terapkan konfigurasi
sudo cp configs/squid/squid.conf /etc/squid/squid.conf
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo squid -k parse   # Validasi dulu
sudo systemctl restart squid
```

---

## Struktur Repository

```text
.
├── .github/
│   ├── workflows/
│   │   └── lint.yml                 # CI: ShellCheck + Squid config validation
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── PULL_REQUEST_TEMPLATE.md
├── configs/
│   ├── squid/
│   │   ├── squid.conf               # Konfigurasi utama
│   │   ├── squid_ssl_bump.conf      # Template SSL Bump lengkap
│   │   ├── blocked_sites.txt        # Domain yang diblokir
│   │   ├── whitelist.txt            # Bypass SSL Bump (banking, updates)
│   │   ├── auth.conf                # Template autentikasi LDAP
│   │   ├── bandwidth_limit.conf     # Delay Pools / pembatasan bandwidth
│   │   ├── time_acl.conf            # Kontrol akses berbasis jam
│   │   └── denial_rules.conf        # Aturan http_access deny
│   └── firewall/
│       └── centos7_rules.sh         # Aturan firewall CentOS 7
├── scripts/
│   ├── install_and_service.sh       # Install otomatis Squid
│   ├── create_ca.sh                 # Generate Certificate Authority
│   ├── setup_icap.sh                # Setup ICAP + ClamAV
│   ├── deploy_ca_windows.ps1        # Deploy CA ke client Windows
│   ├── health_check.sh              # Cek kesehatan proxy
│   ├── backup_config.sh             # Backup konfigurasi
│   ├── rotate_logs.sh               # Rotasi & kompresi log
│   └── uninstall.sh                 # Hapus Squid dengan bersih
├── docker/
│   ├── Dockerfile                   # Image container Squid
│   └── docker-compose.yml           # Orkestrasi lab portabel
├── docs/
│   ├── guides/
│   │   ├── client_setup.md          # Konfigurasi client (Linux & Windows)
│   │   ├── verification.md          # Verifikasi & troubleshooting
│   │   ├── advanced_swg.md          # SWG lanjutan (SSL Bump, ICAP, Auth)
│   │   ├── security_hardening.md    # Hardening & best practices
│   │   ├── sarg_reporting.md        # Laporan traffic dengan SARG
│   │   ├── monitoring.md            # Grafana & ELK Stack integration
│   │   └── faq.md                   # Pertanyaan yang sering ditanyakan
│   ├── manuals/                     # PDF dokumentasi lab
│   └── assets/
│       └── topology.png             # Diagram topologi
├── Vagrantfile                      # Lab otomatis via Vagrant
├── CHANGELOG.md                     # Riwayat perubahan
├── LICENSE                          # MIT License
└── README.md
```

---

## Instalasi Lengkap (Step-by-Step)

### Prasyarat
- CentOS 7 dengan akses root / sudo
- RAM minimal 2 GB, Storage 20 GB
- Dua network interface (WAN + LAN)
- Koneksi internet untuk mengunduh paket

### Step 1 — Clone Repository
```bash
git clone https://github.com/angkasa760/proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan.git
cd proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan
```

### Step 2 — Install Squid
```bash
chmod +x scripts/install_and_service.sh
sudo ./scripts/install_and_service.sh
```

### Step 3 — Terapkan Konfigurasi
```bash
sudo cp configs/squid/squid.conf /etc/squid/squid.conf
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo squid -k parse && sudo systemctl restart squid
```

### Step 4 — (Opsional) SSL Interception
```bash
chmod +x scripts/create_ca.sh
sudo ./scripts/create_ca.sh
# Kemudian deploy CA ke client: scripts/deploy_ca_windows.ps1
```

### Step 5 — (Opsional) Malware Scanning
```bash
chmod +x scripts/setup_icap.sh
sudo ./scripts/setup_icap.sh
```

### Step 6 — Verifikasi
```bash
sudo ./scripts/health_check.sh
sudo tail -f /var/log/squid/access.log
curl -x http://172.24.0.1:3128 -I http://example.com
```

---

## Panduan Lanjutan

| Panduan | Link |
|---|---|
| Konfigurasi Client | [client_setup.md](docs/guides/client_setup.md) |
| Verifikasi & Troubleshooting | [verification.md](docs/guides/verification.md) |
| SWG Lanjutan (SSL Bump, ICAP) | [advanced_swg.md](docs/guides/advanced_swg.md) |
| Security Hardening | [security_hardening.md](docs/guides/security_hardening.md) |
| Laporan Traffic (SARG) | [sarg_reporting.md](docs/guides/sarg_reporting.md) |
| Monitoring Grafana/ELK | [monitoring.md](docs/guides/monitoring.md) |
| FAQ | [faq.md](docs/guides/faq.md) |

---

## Catatan Keamanan

> **Peringatan:** SSL Bump mendekripsi traffic privat. Pastikan pengguna telah diberitahu dan izin telah diperoleh sebelum diaktifkan.

> **Catatan Hukum:** Aplikasi dengan certificate pinning (banking, Telegram) mungkin tidak berfungsi dengan SSL Bump. Tambahkan ke `configs/squid/whitelist.txt`.

---

## Kontribusi

1. Fork repository ini
2. Buat branch baru: `git checkout -b feature/nama-fitur`
3. Commit perubahan: `git commit -m 'feat: deskripsi perubahan'`
4. Push: `git push origin feature/nama-fitur`
5. Buat Pull Request

---

Dikembangkan sebagai proyek lab **Konfigurasi Jaringan & Keamanan Siber** — CentOS 7, Squid 4.x.

(c) 2026 [angkasa760](https://github.com/angkasa760) - MIT License