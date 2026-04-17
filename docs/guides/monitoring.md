# Monitoring Traffic Squid dengan Grafana & ELK Stack

Panduan ini menjelaskan cara memvisualisasikan log Squid menggunakan dua metode populer.

---

## Opsi A — Grafana + Prometheus (Lightweight)

### Langkah 1 — Install Prometheus

```bash
# Unduh Prometheus
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-*.linux-amd64.tar.gz
tar xzf prometheus-*.tar.gz && cd prometheus-*

# Jalankan (atau setup sebagai service)
./prometheus --config.file=prometheus.yml &
```

### Langkah 2 — Install Squid Exporter

```bash
# Squid Exporter mengekspos metrics Squid ke Prometheus
wget https://github.com/boynux/squid-exporter/releases/latest/download/squid-exporter-linux-amd64
chmod +x squid-exporter-linux-amd64

# Jalankan (pastikan Squid cachemgr aktif)
./squid-exporter-linux-amd64 -squid-hostname 127.0.0.1 -squid-port 3128 &
```

### Langkah 3 — Install Grafana

```bash
# Tambah repo Grafana
sudo tee /etc/yum.repos.d/grafana.repo << 'EOF'
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

sudo yum install -y grafana
sudo systemctl enable --now grafana-server
```

### Langkah 4 — Akses Grafana

```
URL     : http://172.24.0.1:3000
Username: admin
Password: admin (ganti setelah login pertama)
```

Import dashboard Squid dari Grafana Labs:
- Cari dashboard ID: **13386** (Squid Proxy Dashboard)

---

## Opsi B — ELK Stack (Elasticsearch + Logstash + Kibana)

### Langkah 1 — Install Elasticsearch

```bash
# Tambah repo Elastic
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo tee /etc/yum.repos.d/elasticsearch.repo << 'EOF'
[elasticsearch]
name=Elasticsearch repository
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sudo yum install -y elasticsearch
sudo systemctl enable --now elasticsearch
```

### Langkah 2 — Konfigurasi Logstash

Install Logstash dan buat pipeline:

```bash
sudo yum install -y logstash
```

Buat file pipeline `/etc/logstash/conf.d/squid.conf`:

```text
input {
  file {
    path => "/var/log/squid/access.log"
    start_position => "beginning"
    sincedb_path => "/var/lib/logstash/sincedb_squid"
    type => "squid-access"
  }
}

filter {
  if [type] == "squid-access" {
    grok {
      match => {
        "message" => "%{NUMBER:timestamp}\.%{NUMBER} +%{NUMBER:duration} %{IPORHOST:client_ip} %{WORD:result_code}/%{NUMBER:http_code} %{NUMBER:bytes} %{WORD:method} %{NOTSPACE:url} %{NOTSPACE:user} %{WORD:hierarchy}/%{IPORHOST:server} %{NOTSPACE:content_type}"
      }
    }
    date {
      match => ["timestamp", "UNIX"]
      target => "@timestamp"
    }
    mutate {
      convert => {
        "duration" => "integer"
        "bytes" => "integer"
        "http_code" => "integer"
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "squid-logs-%{+YYYY.MM.dd}"
  }
}
```

```bash
sudo systemctl enable --now logstash
```

### Langkah 3 — Install Kibana

```bash
sudo yum install -y kibana
sudo systemctl enable --now kibana
```

Akses Kibana:
```
URL: http://172.24.0.1:5601
```

### Langkah 4 — Buat Dashboard di Kibana

1. Buka **Discover** → pilih index `squid-logs-*`
2. Buat visualisasi di **Visualize**:
   - **Pie Chart**: top 10 domain dikunjungi (`url` field)
   - **Bar Chart**: traffic per jam (`@timestamp` vs `bytes`)
   - **Data Table**: daftar IP client aktif
3. Gabungkan di **Dashboard**

---

## Referensi Port

| Service | Port |
|---|---|
| Elasticsearch | 9200, 9300 |
| Kibana | 5601 |
| Grafana | 3000 |
| Prometheus | 9090 |
| Squid Exporter | 9301 |
