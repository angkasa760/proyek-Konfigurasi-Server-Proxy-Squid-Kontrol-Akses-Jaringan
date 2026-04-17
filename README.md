# Squid Proxy Server & Secure Web Gateway (SWG)

[![Squid](https://img.shields.io/badge/Squid-4.x-2563eb?style=flat-square&logo=nginx&logoColor=white)](https://www.squid-cache.org/)
[![Platform](https://img.shields.io/badge/Platform-CentOS_7-ee0000?style=flat-square&logo=redhat&logoColor=white)](https://centos.org/)
[![Security](https://img.shields.io/badge/Security-Access_Control-16a34a?style=flat-square&logo=shieldsdotio&logoColor=white)](https://github.com/angkasa760)
[![Scripted](https://img.shields.io/badge/Scripted-Bash_%26_PowerShell-5391fe?style=flat-square&logo=powershell&logoColor=white)](https://github.com/angkasa760)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

> Implementasi Squid Proxy berbasis CentOS 7 untuk lingkungan lab jaringan virtual. Proyek ini mencakup konfigurasi traffic control, SSL interception (HTTPS inspection), website blocking, autentikasi, dan integrasi antivirus via ICAP.

---

## Fitur Utama

| Fitur | Deskripsi |
|---|---|
| **Secure Web Gateway (SWG)** | Kendali penuh atas traffic HTTP/HTTPS masuk dan keluar |
| **HTTPS Interception (SSL Bump)** | Inspeksi traffic terenkripsi untuk deteksi ancaman lanjutan |
| **Access Control Lists (ACL)** | Aturan granular berbasis IP, domain, dan kata kunci |
| **Website & Extension Blocking** | Blokir domain dan tipe file berbahaya (`.exe`, `.iso`, dll.) |
| **Autentikasi LDAP** | Integrasi dengan Active Directory / OpenLDAP |
| **Malware Scanning (ICAP + ClamAV)** | Pemindaian file unduhan secara real-time |
| **Topologi Lab Virtual** | Diagram arsitektur jaringan untuk referensi setup |

---

## Arsitektur Jaringan

Model penerapan terpusat: Squid Server sebagai gateway tunggal antara semua client dan internet.

```
[ Client Linux ]  ─┐
[ Client Windows ] ─┤─── [SWITCH] ─── [SQUID PROXY SERVER] ─── [INTERNET]
[ Client lainnya ] ─┘         CentOS 7 | 172.24.0.1
                                Port 3128 (HTTP) | Port 3129 (HTTPS)
```

![Network Topology](docs/assets/topology.png)

| Parameter | Nilai |
|---|---|
| Internal Network | `172.24.0.0/16` |
| IP Proxy Server | `172.24.0.1` |
| Proxy Port (HTTP Explicit) | `3128` |
| Proxy Port (SSL Bump/HTTPS) | `3129` |

---

## Spesifikasi Sistem

| Komponen | Minimum | Rekomendasi |
|---|---|---|
| OS | CentOS 7 Minimal | CentOS 7 Server with GUI |
| CPU | 2 vCPU | 4 vCPU |
| RAM | 2 GB | 4 GB |
| Storage | 20 GB | 50 GB |
| Network Interface | 1 NIC | 2 NIC (WAN + LAN) |
| Squid Version | 3.5 | 4.x |

---

## Instalasi & Deployment

### Prasyarat
- CentOS 7 dengan akses root / sudo
- Dua network interface (WAN + LAN disarankan)
- Koneksi internet untuk mengunduh paket

### Langkah 1 — Install Squid

```bash
chmod +x scripts/install_and_service.sh
sudo ./scripts/install_and_service.sh
```

### Langkah 2 — Terapkan Konfigurasi

```bash
sudo cp configs/squid/squid.conf /etc/squid/squid.conf
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt

# Validasi konfigurasi sebelum restart
sudo squid -k parse

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
│       └── centos7_rules.sh    # Aturan firewall & iptables untuk CentOS 7
├── scripts/
│   ├── install_and_service.sh  # Instalasi otomatis Squid
│   ├── create_ca.sh            # Generate Certificate Authority untuk SSL Bump
│   ├── setup_icap.sh           # Setup ICAP + ClamAV (Malware Scanning)
│   └── deploy_ca_windows.ps1   # Deploy CA ke client Windows
├── docs/
│   ├── guides/
│   │   ├── client_setup.md     # Panduan konfigurasi client (Linux & Windows)
│   │   ├── verification.md     # Panduan verifikasi & troubleshooting
│   │   └── advanced_swg.md     # Panduan SWG lanjutan (SSL Bump, ICAP, Auth)
│   ├── manuals/                # Dokumen PDF konfigurasi lab (referensi)
│   └── assets/
│       └── topology.png        # Diagram topologi jaringan
└── README.md
```

---

## Alur Kerja Proxy

```
Client Request
     |
     v
[Squid Proxy - Port 3128/3129]
     |
     +---> ACL Check (IP / Domain / Keyword)
     |         |
     |     [BLOCKED?] --> Kirim TCP_DENIED/403 ke client
     |         |
     |     [ALLOWED]
     |         |
     +---> ICAP / ClamAV Scan (jika aktif)
     |         |
     |     [THREAT?] --> Blokir dan log ancaman
     |         |
     |     [CLEAN]
     |         |
     +---> Forward ke Internet
     |
     v
Log di /var/log/squid/access.log
```

---

## Verifikasi Cepat

Setelah instalasi, pastikan proxy berjalan:

```bash
# Cek status service
sudo systemctl status squid

# Validasi konfigurasi
sudo squid -k parse

# Monitor traffic secara real-time
sudo tail -f /var/log/squid/access.log

# Test koneksi HTTP melewati proxy
curl -x http://172.24.0.1:3128 -I http://example.com

# Test koneksi HTTPS melewati proxy
curl -x http://172.24.0.1:3128 -I https://www.google.com
```

**Expected output di log:**
- Traffic diizinkan: `TCP_MISS/200`
- Traffic diblokir: `TCP_DENIED/403`

---

## Troubleshooting

| Gejala | Kemungkinan Penyebab | Solusi |
|---|---|---|
| `Connection Refused` | Service Squid mati | `sudo systemctl start squid` |
| `Access Denied (403)` | IP client tidak diizinkan | Cek ACL `localnet` di `squid.conf` |
| `SSL Connection Error` | CA Certificate belum diimport | Import `myCA.crt` ke browser/OS client |
| `DNS Resolution Failure` | Squid tidak bisa resolve WAN | Cek `/etc/resolv.conf` di server proxy |
| `Squid tidak bisa start` | Error konfigurasi | Jalankan `sudo squid -k parse` |
| `Log tidak muncul traffic` | Client belum dikonfigurasi proxy | Cek setting proxy di client |

```bash
# Lihat log error Squid
sudo journalctl -u squid -xe

# Cek permission cache directory
sudo chown -R squid:squid /var/spool/squid /var/log/squid
```

---

## Panduan Lanjutan

- [Konfigurasi Client (Linux & Windows)](docs/guides/client_setup.md)
- [Verifikasi & Troubleshooting](docs/guides/verification.md)
- [SWG Lanjutan: SSL Bump, ICAP, Autentikasi](docs/guides/advanced_swg.md)

---

## Catatan Keamanan

> **Peringatan:** SSL Interception (SSL Bump) mendekripsi traffic privat. Pastikan pengguna telah diberitahu dan kebijakan kepatuhan terpenuhi sebelum diaktifkan di lingkungan produksi.

> **Tips:** Selalu validasi sintaks `squid.conf` sebelum restart: `sudo squid -k parse`

> **Catatan Hukum:** Beberapa website dengan HSTS atau certificate pinning (seperti banking apps) mungkin tidak berfungsi dengan SSL Bump aktif. Tambahkan domain tersebut ke `ssl_bump splice` list.

---

## Kontribusi

Pull Request dan Issues sangat terbuka. Untuk perubahan besar, buka Issue terlebih dahulu untuk mendiskusikan yang ingin diubah.

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/namafitur`)
3. Commit perubahan (`git commit -m 'feat: tambah fitur X'`)
4. Push ke branch (`git push origin feature/namafitur`)
5. Buat Pull Request

---

**Fokus Proyek:** Proxy Mechanics, Access Control, Perimeter Security

Dikembangkan sebagai bagian dari proyek lab **Konfigurasi Jaringan & Keamanan Siber** menggunakan lingkungan virtual CentOS 7.

© 2026 [angkasa760](https://github.com/angkasa760) — MIT License