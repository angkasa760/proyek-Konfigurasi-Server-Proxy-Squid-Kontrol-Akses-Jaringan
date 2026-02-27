 Squid Secure Web Gateway (SWG) Deployment Guide

 Overview

This guide explains how to deploy a **Secure Web Gateway (SWG)** using **Squid Proxy Server** on **CentOS 7**.

 Features Implemented:

* HTTP/HTTPS Proxy (Explicit & Intercept)
* SSL/TLS Inspection (SSL Bump)
* URL & Domain Filtering
* File Type Blocking
* LDAP Authentication
* ICAP Integration (Malware Scanning)
* Logging & Monitoring

---

 System Requirements

* OS: CentOS 7
* RAM: Minimum 2 GB (Recommended 4 GB for SSL Bump)
* CPU: 2 Core (Recommended 4 Core)
* Root Access (sudo)

---

Project Structure

```
squid-proxy-lab/
├── configs/
│   ├── squid.conf.example
│   └── blocked_sites.txt
├── scripts/
│   ├── create-ca.sh
│   ├── install-squid-centos7.sh
│   ├── setup-icap.sh
│   └── deploy-ca-to-windows.ps1
└── README-deploy.md
```

---

Step 1 — Install Squid

```bash
sudo chmod +x scripts/install-squid-centos7.sh
sudo ./scripts/install-squid-centos7.sh
```

---

Step 2 — Create SSL Certificate Authority (CA)

```bash
sudo chmod +x scripts/create-ca.sh
sudo ./scripts/create-ca.sh
```

### Output:

* `/etc/squid/ssl_cert/myCA.crt`
* `/etc/squid/ssl_cert/myCA.key`
* `/etc/squid/ssl_cert/myCA.pem`

---
 Step 3 — Configure Squid

Copy config template:

```bash
sudo cp configs/squid.conf.example /etc/squid/squid.conf
```

Edit configuration:

```bash
sudo nano /etc/squid/squid.conf
```

---
 Step 4 — Setup Website Blocking

```bash
sudo cp configs/blocked_sites.txt /etc/squid/blocked_sites.txt
sudo chown squid:squid /etc/squid/blocked_sites.txt
```

---

 Step 5 — Setup ICAP (Malware Scanning)

```bash
sudo chmod +x scripts/setup-icap.sh
sudo ./scripts/setup-icap.sh
```

---
 Step 6 — Restart Squid

```bash
sudo systemctl restart squid
sudo systemctl status squid
```

---

 Step 7 — Configure Client Proxy

### Manual Proxy:

* IP: `172.24.0.1`
* Port: `3128`

### Test via CLI:

```bash
curl -x http://172.24.0.1:3128 http://example.com -I
```

---
 Step 8 — Deploy CA to Windows Clients

Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\deploy-ca-to-windows.ps1 -CertPath "C:\path\to\myCA.crt"
```

 Step 9 — Verification

 Check Logs:

```bash
tail -f /var/log/squid/access.log
```

 Expected:

* Allowed traffic → `TCP_MISS/200`
* Blocked traffic → `TCP_DENIED/403`

 Optional — Transparent Proxy (Advanced)

```bash
iptables -t nat -A PREROUTING -i ens38 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -i ens38 -p tcp --dport 443 -j REDIRECT --to-port 3129
```

 Troubleshooting

### Squid not starting

```bash
sudo journalctl -xe
```

### Permission issues

```bash
sudo chown -R squid:squid /var/lib/ssl_db
sudo chown -R squid:squid /etc/squid
```

### SSL errors in browser

* Ensure `myCA.crt` is installed on client
* Restart browser

 Security Notes

* SSL Bump inspects encrypted traffic → ensure compliance with policies
* Some websites (banking, HSTS) may break
* Consider bypass rules for sensitive domains

 Future Improvements

* Integration with ELK Stack
* Advanced Threat Detection
* Cloud SWG Integration (Zscaler / Netskope)

 Author

Project: Squid Proxy Server & Secure Web Gateway
Focus: Network Security, Access Control, Cybersecurity Lab

