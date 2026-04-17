# Security Hardening Guide — Squid Proxy

Panduan ini mencakup langkah-langkah memperkuat keamanan Squid Proxy di atas konfigurasi standar, mengikuti prinsip *least privilege* dan *defense in depth*.

---

## Checklist Hardening

### 1. Konfigurasi Squid.conf

**Sembunyikan identitas proxy dari client:**
```text
# Hapus header X-Forwarded-For (jangan ekspos IP client ke server tujuan)
forwarded_for off

# Hapus header Via
via off

# Hapus/anonimkan header yang bisa mengekspos info server
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
```

**Batasi ukuran request (cegah DoS):**
```text
# Batasi ukuran body request upload
request_body_max_size 10 MB

# Batasi jumlah koneksi simultan per IP
acl max_connection_limit maxconn 50
http_access deny max_connection_limit
```

**Nonaktifkan cachemgr dari luar localhost:**
```text
http_access allow localhost manager
http_access deny manager
```

---

### 2. Firewall (iptables / firewalld)

Batasi akses ke proxy hanya dari jaringan internal:

```bash
# Izinkan hanya dari jaringan internal
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.24.0.0/16" port port="3128" protocol="tcp" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.24.0.0/16" port port="3129" protocol="tcp" accept'

# Blokir akses publik ke port proxy
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port port="3128" protocol="tcp" reject'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port port="3129" protocol="tcp" reject'

sudo firewall-cmd --reload
```

---

### 3. Proteksi File Sensitif

```bash
# CA Private Key — hanya root & squid yang boleh baca
sudo chmod 640 /etc/squid/ssl_cert/myCA.key
sudo chown root:squid /etc/squid/ssl_cert/myCA.key

# Config file — hanya root yang boleh tulis
sudo chmod 644 /etc/squid/squid.conf
sudo chown root:squid /etc/squid/squid.conf

# Blocklist — squid bisa baca, tapi tidak bisa tulis
sudo chmod 644 /etc/squid/blocked_sites.txt
sudo chown root:squid /etc/squid/blocked_sites.txt
```

---

### 4. SELinux

Jika SELinux aktif (Enforcing), pastikan konteks yang benar:

```bash
# Cek status SELinux
getenforce

# Restore konteks file Squid
sudo restorecon -Rv /etc/squid/
sudo restorecon -Rv /var/spool/squid/
sudo restorecon -Rv /var/log/squid/

# Jika masih bermasalah, cek policy violations
sudo ausearch -c squid --raw | audit2allow -M squid_policy
sudo semodule -i squid_policy.pp
```

---

### 5. SSL/TLS Hardening

Batasi protokol & cipher yang lemah:

```text
# Di squid.conf — hanya TLS 1.2 ke atas
tls_outgoing_options min-version=1.2

# Nonaktifkan cipher lemah
tls_outgoing_options cipher=HIGH:MEDIUM:!LOW:!SSLv2:!SSLv3:!TLSv1:!TLSv1.1:!RC4:!aNULL:!eNULL
```

---

### 6. Update Berkala

Selalu perbarui Squid dan CA certificates:

```bash
# Update Squid
sudo yum update squid -y

# Update CA certificates sistem
sudo yum update ca-certificates -y

# Update ClamAV database (jika ICAP aktif)
sudo freshclam
```

---

### 7. Monitoring Keamanan

```bash
# Pantau log untuk aktivitas mencurigakan
sudo grep "DENIED" /var/log/squid/access.log | awk '{print $3}' | sort | uniq -c | sort -rn | head -20

# Monitor koneksi berlebihan dari satu IP (potensial abuse)
sudo grep "$(date '+%Y/%m/%d')" /var/log/squid/access.log | awk '{print $3}' | sort | uniq -c | sort -rn | head -10

# Cek apakah ada bypass proxy (akses langsung ke internet)
sudo iptables -L FORWARD -n -v
```

---

## Ringkasan Checklist

| # | Item | Status |
|---|---|---|
| 1 | `forwarded_for off` & `via off` | |
| 2 | Batas koneksi per-IP (`maxconn`) | |
| 3 | Cachemgr hanya dari localhost | |
| 4 | Firewall: blokir port proxy dari internet | |
| 5 | Permission file konfigurasi benar | |
| 6 | SELinux context benar | |
| 7 | TLS 1.2+ dipaksakan | |
| 8 | Update rutin terjadwal | |
| 9 | Monitoring log aktif | |
