# FAQ — Frequently Asked Questions

Kumpulan pertanyaan dan solusi untuk kendala teknis Squid Proxy SWG.

---

### Q1: Saya sudah menambah domain ke `blocked_sites.txt` tapi masih bisa dibuka. Kenapa?
**Solusi:**
1. Pastikan `squid.conf` Anda memiliki baris:
   `acl blocked_sites dstdomain "/etc/squid/blocked_sites.txt"`
   `http_access deny blocked_sites`
2. Pastikan file tersebut berada di lokasi yang benar (`/etc/squid/blocked_sites.txt`).
3. Jalankan `sudo squid -k reconfigure` untuk memuat ulang daftar tanpa mematikan service.

### Q2: Browser client memunculkan error "Your connection is not private".
**Solusi:**
Ini terjadi karena Anda mengaktifkan **SSL Bump** tapi belum mengimport sertifikat CA ke client.
1. Download file `myCA.crt` dari server proxy.
2. Import ke browser client (Settings -> Security -> Manage Certificates -> Trusted Root Certification Authorities).
3. Jika menggunakan Windows, gunakan script `scripts/deploy_ca_windows.ps1` (Jalankan sebagai Admin).

### Q3: Kenapa download file .EXE masih bisa padahal sudah diblokir?
**Solusi:**
Pengecekan regex tipe file memerlukan ketelitian. Pastikan baris ini ada:
`acl blocked_files urlpath_regex -i \.exe$ \.msi$`
`http_access deny blocked_files`
Lalu pindahkan baris `http_access deny` tersebut ke bagian **Paling Atas** di `squid.conf` (sebelum `http_access allow localnet`).

### Q4: SARG tidak mau memunculkan laporan. Port 80 tertutup.
**Solusi:**
Secara default CentOS 7 menutup port 80. Buka via firewall-cmd:
`sudo firewall-cmd --permanent --add-service=http`
`sudo firewall-cmd --reload`
Lalu pastikan layanan Apache berjalan: `sudo systemctl start httpd`.

### Q5: Squid gagal start setelah saya edit konfigurasi. Bagaimana cara cek errornya?
**Solusi:**
Jangan langsung menebak. Gunakan perintah validasi bawaan Squid:
`sudo squid -k parse`
Squid akan memberitahu nomor baris dan jenis errornya (misal: "Invalid ACL type").

### Q6: Bagaimana cara monitor traffic secara live tanpa dashboard?
**Solusi:**
Gunakan perintah `tail` pada file access log:
`sudo tail -f /var/log/squid/access.log | awk '{print $3 " " $4 " " $7}'`

---

**Masih butuh bantuan?**
Buka **Issue** di GitHub atau konsultasikan dengan dokumentasi resmi di [Squid-Cache Wiki](http://wiki.squid-cache.org/).
