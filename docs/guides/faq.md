# FAQ — Pertanyaan yang Sering Ditanyakan

Kumpulan pertanyaan dan jawaban umum seputar konfigurasi dan penggunaan Squid Proxy di lab ini.

---

## Instalasi & Setup

### Q: Apakah Squid bisa diinstall di Ubuntu/Debian?
Ya, tapi script `install_and_service.sh` dioptimalkan untuk CentOS 7. Di Ubuntu gunakan:
```bash
sudo apt-get install squid -y
sudo systemctl enable --now squid
```

### Q: Bagaimana cara cek versi Squid yang terinstall?
```bash
squid -v | head -1
```

### Q: Squid gagal start setelah konfigurasi, apa yang harus dilakukan?
Langkah debug:
```bash
# Langkah 1: Validasi sintaks konfigurasi
sudo squid -k parse

# Langkah 2: Lihat log error detail
sudo journalctl -u squid -xe --no-pager | tail -50

# Langkah 3: Cek permission
sudo chown -R squid:squid /var/spool/squid /var/log/squid /etc/squid
sudo chmod 750 /var/spool/squid
```

### Q: Bagaimana cara reload konfigurasi tanpa restart service?
```bash
sudo squid -k reconfigure
# atau
sudo systemctl reload squid
```

---

## SSL & HTTPS Inspection

### Q: Apa itu SSL Bump dan apa risikonya?
SSL Bump memungkinkan Squid mendekripsi traffic HTTPS untuk inspeksi konten. **Risikonya:**
- Melanggar privasi pengguna jika tidak ada kebijakan yang jelas
- Bisa merusak aplikasi dengan certificate pinning (banking apps, Telegram, dll.)
- Membutuhkan distribusi CA ke semua client

### Q: Browser menampilkan "Your connection is not private" setelah SSL Bump aktif?
Artinya CA Squid belum diimport ke browser/OS client. Ikuti panduan:
- [Client Setup Guide](client_setup.md) — bagian "Install CA Certificate"

### Q: Aplikasi banking/BPJS tidak bisa dibuka setelah SSL Bump aktif?
Tambahkan domain tersebut ke whitelist:
```bash
sudo nano /etc/squid/whitelist.txt
# Tambahkan domain, contoh: .bca.co.id
sudo squid -k reconfigure
```

### Q: Bagaimana cara generate ulang CA jika sudah expired?
```bash
sudo ./scripts/create_ca.sh
# Kemudian redistribute myCA.crt ke semua client
```

---

## ACL & Access Control

### Q: Bagaimana cara memblokir satu domain spesifik?
```bash
# Tambahkan di /etc/squid/blocked_sites.txt
echo ".tiktok.com" | sudo tee -a /etc/squid/blocked_sites.txt
sudo squid -k reconfigure
```

### Q: Bagaimana cara memblokir akses berdasarkan jam tertentu?
Gunakan template: `configs/squid/time_acl.conf`
Bisa juga lihat panduan lanjutan: [Advanced SWG Deployment](advanced_swg.md)

### Q: Bagaimana cara membatasi kecepatan download client tertentu?
Gunakan template Delay Pools: `configs/squid/bandwidth_limit.conf`

### Q: Semua traffic diblokir (403), padahal IP sudah ada di localnet?
Cek urutan ACL di `squid.conf` — `http_access allow localnet` harus **sebelum** `http_access deny all`:
```bash
sudo squid -k parse   # Cek syntax
sudo tail -f /var/log/squid/access.log   # Monitor log
```

---

## Monitoring & Log

### Q: Di mana file log Squid berada?
| Log | Path |
|---|---|
| Access Log | `/var/log/squid/access.log` |
| Cache Log | `/var/log/squid/cache.log` |

### Q: Bagaimana cara membaca access.log?
Format: `waktu durasi_ms client_ip status/http_code bytes metode url`
```
1713369600.123   1200 172.24.0.10 TCP_MISS/200 8372 GET http://example.com/
```

### Q: Bagaimana cara generate laporan traffic harian?
Install dan gunakan SARG. Lihat panduan: [SARG Reporting Guide](sarg_reporting.md)

### Q: Log berukuran sangat besar, bagaimana cara mengelolanya?
Gunakan script rotasi log:
```bash
sudo ./scripts/rotate_logs.sh
```
Jadwalkan otomatis via cron:
```bash
echo "0 0 * * 0 root /path/to/scripts/rotate_logs.sh" | sudo tee -a /etc/crontab
```

---

## Performa & Optimasi

### Q: Berapa ukuran cache optimal untuk lab dengan 10 client?
```text
cache_mem 256 MB
maximum_object_size_in_memory 8 KB
cache_dir ufs /var/spool/squid 2000 16 256  # 2 GB disk cache
```

### Q: Squid lambat untuk banyak koneksi HTTPS, apa solusinya?
Tambah jumlah `sslcrtd_children`:
```text
sslcrtd_children 16 startup=4 idle=2
```

---

## Uninstall

### Q: Bagaimana cara menghapus Squid dengan bersih?
```bash
sudo ./scripts/uninstall.sh
```
