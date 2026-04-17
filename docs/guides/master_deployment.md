# Master Deployment Guide: Squid Proxy Enterprise SWG

Panduan ini adalah standar operasional (SOP) untuk membangun **Secure Web Gateway (SWG)** yang fungsional, aman, dan siap produksi menggunakan Squid Proxy di CentOS 7.

---

## 🏗️ 0. Arsitektur & Filosofi
Proyek ini menggunakan model **Single Gateway Enforcement**. Semua traffic dari LAN (172.24.0.0/16) harus melewati Proxy (172.24.0.1) sebelum mencapai WAN.

### Topologi Logis
`Terminal --[HTTP/HTTPS]--> Squid (Port 3128/3129) --[DPI/AV Scan]--> Internet`

---

## 🛠️ 1. Persiapan Sistem & Hardening
Sebelum instalasi, pastikan OS dalam kondisi prima.

1. **Update Kernel & Packages:**
   ```bash
   sudo yum update -y
   ```
2. **Setup Timezone (Penting untuk logs):**
   ```bash
   sudo timedatectl set-timezone Asia/Jakarta
   ```
3. **Firewall Baseline:**
   Pastikan port 3128 terbuka hanya untuk subnet internal Anda.
   ```bash
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-port=3128/tcp
   sudo firewall-cmd --reload
   ```

---

## 📦 2. Instalasi Core SWG
Lakukan instalasi menggunakan script otomasi untuk menjamin konsistensi.

```bash
git clone https://github.com/angkasa760/proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan.git
cd proyek-Konfigurasi-Server-Proxy-Squid-Kontrol-Akses-Jaringan
sudo ./scripts/install_and_service.sh
```

---

## 🛡️ 3. Konfigurasi Kontrol Akses (ACL)
ACL adalah jantung dari Squid. Konfigurasi kami menggunakan pendekatan **Whitelisting & Blacklisting**.

### A. Mengaktifkan Blokir Domain
Edit `configs/squid/blocked_sites.txt` dan masukkan domain target (misal: `facebook.com`).
```bash
sudo cp configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo systemctl reload squid
```

### B. Konfigurasi ulimit
Untuk beban kerja enterprise, naikkan batas file descriptors di `/etc/security/limits.conf`:
```text
squid soft nofile 4096
squid hard nofile 8192
```

---

## 🔐 4. SSL Interception (SSL Bump)
Ini adalah fitur tercanggih dalam repo ini. Fitur ini memungkinkan inspeksi traffic terenkripsi.

### Langkah-langkah:
1. **Generate Certificate Authority:**
   ```bash
   sudo ./scripts/create_ca.sh
   ```
2. **Distribusi Sertifikat:**
   Ambil file `/etc/squid/ssl_cert/myCA.crt`. Salin ke komputer client dan instal sebagai **Trusted Root Certification Authority**. Tanpa ini, client akan melihat error "SSL Security Warning".

---

## 🦠 5. Anti-Malware Scanning (ICAP)
Mencegah malware masuk ke jaringan dengan memindai setiap file yang diunduh.

1. **Aktivasi Engine:**
   ```bash
   sudo ./scripts/setup_icap.sh
   ```
2. **Verifikasi:**
   Coba unduh file test EICAR dari client: `wget http://www.eicar.org/download/eicar.com.txt`. Jika berhasil, Squid/ICAP akan memblokir unduhan tersebut.

---

## 📊 6. Monitoring & Dashboard
Gunakan dashboard yang telah kami rancang untuk memantau trafik secara real-time.

```bash
sudo ./scripts/master_dashboard.sh
```

Untuk laporan visual harian, gunakan SARG (lihat `docs/guides/sarg_reporting.md`).

---

## 🆘 7. Troubleshooting "Integrity Errors"

| Masalah | Diagnosa | Solusi |
|---|---|---|
| **Situs tertentu tidak bisa dibuka** | Cek `blocked_sites.txt` | Hapus dari daftar jika salah blokir. |
| **Error SSL di Browser Client** | Sertifikat CA belum diimport | Jalankan `deploy_ca_windows.ps1` atau import manual. |
| **Squid Gagal Start** | Sintaks salah | Jalankan `sudo squid -k parse` untuk cek baris mana yang error. |
| **Traffic tidak terdeteksi ICAP** | Service c-icap mati | `sudo systemctl restart c-icap` |

---

## 🧹 8. Maintenance Rutin
Jangan biarkan server mati karena disk penuh.
1. **Log Rotation**: Jalankan `scripts/rotate_logs.sh` seminggu sekali (atau via crontab).
2. **Config Backup**: Jalankan `scripts/backup_config.sh` sebelum melakukan perubahan besar.

---

**Master Guide Terakhir Diperbarui:** 2026-04-17
**Kontribusi:** angkasa760/Enterprise-Network-Lab
