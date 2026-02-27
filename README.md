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


configs/squid.conf
# ===================================================================
# squid.conf.example - Secure Web Gateway (SWG) sample
# Features:
#  - explicit proxy (3128)
#  - HTTPS interception (ssl-bump) (3129)
#  - ssl_crtd helper
#  - ICAP hooks (respmod/reqmod) example (requires c-icap or ICAP server)
#  - LDAP authentication example (basic_ldap_auth)
#  - URL / filetype blocking (blocked_sites.txt + urlpath_regex)
#  - logging
#
# IMPORTANT:
#  - Replace placeholders (LDAP bind DN, passwords, paths) before use.
#  - Create CA and ssl_db (see README or comments below).
# ===================================================================

#### Basic ports
# explicit http proxy for clients that configure proxy
http_port 3128

# SSL Bump listener (used for intercepting HTTPS)
# If you choose intercept mode (transparent), use "ssl-bump" on an intercept port and redirect traffic via iptables.
http_port 3129 ssl-bump cert=/etc/squid/ssl_cert/myCA.pem key=/etc/squid/ssl_cert/myCA.key \
    generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

#### SSL cert helper (ssl_crtd)
# Ensure the binary path matches your distro. On CentOS 7 it's usually /usr/lib64/squid/ssl_crtd
sslcrtd_program /usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB
sslcrtd_children 8 startup=1 idle=1

#### SSL Bump policy (peek / bump simple policy)
# - step1 = SslBump1 => peek to see cert, then bump (decrypt) everything
acl step1 at_step SslBump1
ssl_bump peek step1
ssl_bump bump all

# Optionally, to skip interception for sensitive sites (banking) use:
# acl no_intercept dstdomain .bank.com .payments.example
# ssl_bump splice no_intercept

#### ICAP adaptation (example)
# Requires a running ICAP server (e.g., c-icap) configured to accept connections on given URL.
# This is a template; install/configure c-icap or another ICAP server before enabling.
icap_enable on
icap_service resp_mod_service respmod_precache icap://127.0.0.1:1344/respmod
icap_service req_mod_service reqmod_precache icap://127.0.0.1:1344/reqmod
adaptation_send_buffersize 131072
adaptation_receive_buffersize 131072
adaptation_access allow all

#### Authentication (LDAP example)
# Replace:
#   - LDAP_SERVER, LDAP_BASE, BINDDN, BINDPWD with your values.
# The helper binary path may differ on some distros.
auth_param basic program /usr/lib64/squid/basic_ldap_auth -v 3 -b "dc=example,dc=com" -D "cn=binduser,dc=example,dc=com" -w "bindpassword" -f "uid=%s" -h ldap.example.com
auth_param basic children 10
auth_param basic realm "Protected Proxy"
auth_param basic credentialsttl 2 hours

# ACL that requires authentication
acl authenticated proxy_auth REQUIRED

#### NETWORK & ACLs - Adjust to your lab network
# local networks (adjust to your subnets)
acl localnet src 172.24.0.0/16
acl localnet src 10.0.0.0/8
acl localhost src 127.0.0.1/32

# Blocked domains (file-based)
acl blocked_sites dstdomain "/etc/squid/blocked_sites.txt"

# Block by filetype (examples)
acl blocked_files urlpath_regex -i \.exe$ \.msi$ \.bat$ \.cmd$ \.scr$ \.zip$ \.rar$ \.iso$

# Example: block keyword in URL or path
acl blocked_keywords url_regex -i "proxytool|torrent|warez"

#### ACCESS CONTROL ORDERING
# 1) Allow localhost
http_access allow localhost

# 2) Allow authenticated users (if you want auth to override network rules)
#    If you want to force authentication for all users, uncomment next line:
# http_access allow authenticated

# 3) Allow local network to use proxy (if you prefer to allow localnet)
http_access allow localnet

# 4) Deny blocked content
http_access deny blocked_sites
http_access deny blocked_files
http_access deny blocked_keywords

# 5) Example: deny a specific IP range (if needed)
# acl blocked_range src 172.24.0.100/30
# http_access deny blocked_range

# 6) Default: require authentication for others (optional) OR deny all
# If you want unauthenticated users to be denied:
# http_access deny all

# If you want to require auth for all requests (after localnet), use:
# http_access allow authenticated
# http_access deny all

#### PROXY-TO-PROXY (forward) / parent caches (optional)
# cache_peer proxy.example.com parent 3128 0 no-query default

#### Logging
access_log /var/log/squid/access.log squid
cache_log /var/log/squid/cache.log
cache_store_log none

#### Performance / limits (tweak for your environment)
cache_mem 256 MB
maximum_object_size_in_memory 8 KB
maximum_object_size 512 MB
cache_dir ufs /var/spool/squid 100 16 256

#### DNS / SSL proxy settings (optional tuning)
# sslproxy_cert_error allow all
# sslproxy_cert_error deny all

#### Security & misc
# recommended to limit forwarded headers
forwarded_for off

#### HELPFUL NOTES (run these after editing)
# 1) Create SSL DB and set permissions
#    sudo /usr/lib64/squid/ssl_crtd -c -s /var/lib/ssl_db
#    sudo chown -R squid:squid /var/lib/ssl_db
#
# 2) Place CA cert (myCA.crt) into clients' trusted CA stores
#    - Linux: /usr/local/share/ca-certificates/..., update-ca-trust or update-ca-certificates
#    - Windows: import to Trusted Root Certification Authorities (use PowerShell to automate)
#
# 3) Create /etc/squid/blocked_sites.txt and chown it to squid:squid
#    sudo touch /etc/squid/blocked_sites.txt
#    sudo chown squid:squid /etc/squid/blocked_sites.txt
#
# 4) Reload squid after changes
#    sudo squid -k reconfigure
#    or
#    sudo systemctl restart squid
#
# 5) If using ICAP, ensure ICAP server (c-icap) and modules (clamav) are installed and configured.
#
# 6) If using transparent intercept: configure iptables NAT redirect (careful with HTTPS)
#
# ===================================================================
 

Project: Squid Proxy Server & Secure Web Gateway
Focus: Network Security, Access Control, Cybersecurity Lab

