# SARG — Squid Analysis Report Generator

**SARG** menghasilkan laporan visual traffic web dari log Squid, mencakup statistik per-user, domain terbanyak dikunjungi, dan bandwidth usage.

---

## Langkah 1 — Install SARG

### CentOS 7 (via EPEL)

```bash
# Aktifkan EPEL repository
sudo yum install -y epel-release

# Install SARG
sudo yum install -y sarg

# Verifikasi instalasi
sarg --version
```

> Jika SARG tidak tersedia di EPEL, install dari source:
> ```bash
> sudo yum groupinstall -y "Development Tools"
> sudo yum install -y libgd-devel
> cd /tmp && wget https://sourceforge.net/projects/sarg/files/latest/download -O sarg.tar.gz
> tar -xzf sarg.tar.gz && cd sarg-*
> ./configure && make && sudo make install
> ```

---

## Langkah 2 — Konfigurasi SARG

Edit file konfigurasi SARG:

```bash
sudo nano /etc/sarg/sarg.conf
```

Pastikan baris berikut sudah benar:

```text
# Lokasi access.log Squid
access_log /var/log/squid/access.log

# Direktori output laporan HTML
output_dir /var/www/html/sarg

# Format log Squid (standar)
date_format e   # e = DD/MM/YYYY (format Indonesia)

# Bahasa laporan
lang Indonesian

# Tampilkan top N situs
topuser_num 50
topsites_num 100

# Tampilkan grafik bandwidth
graphs yes
graph_days_bytes_bar_color orange
```

---

## Langkah 3 — Generate Laporan

```bash
# Generate laporan dari log hari ini
sudo sarg -l /var/log/squid/access.log -o /var/www/html/sarg

# Generate laporan dari rentang tanggal tertentu
sudo sarg -l /var/log/squid/access.log -o /var/www/html/sarg \
    -d 15/04/2026-17/04/2026
```

---

## Langkah 4 — Akses Laporan via Web

Install Apache untuk menyajikan laporan:

```bash
sudo yum install -y httpd
sudo systemctl enable --now httpd
```

Akses laporan dari browser client:
```
http://172.24.0.1/sarg/
```

---

## Langkah 5 — Jadwalkan Otomatis (Cron)

Generate laporan harian otomatis tiap tengah malam:

```bash
# Buka crontab
sudo crontab -e

# Tambahkan baris ini:
0 0 * * * /usr/bin/sarg -l /var/log/squid/access.log -o /var/www/html/sarg >> /var/log/sarg.log 2>&1
```

---

## Contoh Output Laporan

Laporan SARG menampilkan:

| Kolom | Keterangan |
|---|---|
| **Userid** | IP address atau username client |
| **Connect** | Jumlah koneksi |
| **Bytes** | Total data yang diunduh |
| **In Cache** | Data yang diambil dari cache |
| **Out Cache** | Data yang diambil dari internet |
| **Elapsed Time** | Total waktu browsing |

---

## Troubleshooting

```bash
# Jika laporan kosong/error
sudo sarg -x -l /var/log/squid/access.log   # Mode debug

# Cek format log Squid
sudo head -5 /var/log/squid/access.log

# Permission issue
sudo chown -R apache:apache /var/www/html/sarg
```
