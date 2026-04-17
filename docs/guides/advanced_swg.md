# Advanced Secure Web Gateway (SWG) Deployment

This guide covers the advanced features of the Squid Proxy, turning it into a full-featured **Secure Web Gateway (SWG)** with SSL Inspection, Malware Scanning, and Authentication.

## 🛡️ SSL Inspection (SSL Bump)

SSL Interception allows Squid to decrypt and inspect HTTPS traffic. This is essential for URL filtering on HTTPS sites and for malware scanning of encrypted downloads.

### 1. Generate the Certificate Authority (CA)
Run the professional CA creation script:
```bash
sudo chmod +x scripts/create_ca.sh
sudo ./scripts/create_ca.sh
```

### 2. Configure Squid for SSL Bump
Add the following snippets to your `squid.conf`:
```text
# Interception Port
http_port 3129 ssl-bump cert=/etc/squid/ssl_cert/myCA.pem key=/etc/squid/ssl_cert/myCA.key generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

# Helper for Certificate Generation
sslcrtd_program /usr/lib64/squid/security_file_certgen -s /var/lib/ssl_db -M 4MB

# SslBump Policies
acl step1 at_step SslBump1
ssl_bump peek step1
ssl_bump bump all
```

---

## 🦠 Malware Scanning (ICAP + ClamAV)

Integrating an antivirus engine ensures that files downloaded through the proxy are scanned for threats.

### 1. Setup ICAP & ClamAV
```bash
sudo chmod +x scripts/setup_icap.sh
sudo ./scripts/setup_icap.sh
```

### 2. Enable ICAP in Squid
```text
icap_enable on
icap_service resp_mod_service respmod_precache icap://127.0.0.1:1344/respmod
adaptation_access allow all
```

---

## 👤 User Authentication (LDAP)

Integrate with Windows Active Directory or OpenLDAP for user-based reporting and policies.

```text
auth_param basic program /usr/lib64/squid/basic_ldap_auth -v 3 -b "dc=example,dc=com" -D "cn=binduser,dc=example,dc=com" -w "password" -f "uid=%s" -h ldap.example.com
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
```

---

## 🚦 Transparent Interception (iptables)

To force all traffic through the proxy without client-side configuration, use transparent redirection on the gateway:

```bash
# Redirect HTTP (80)
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j REDIRECT --to-port 3128

# Redirect HTTPS (443)
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 3129
```

---

> [!CAUTION]
> Testing in a staging environment is highly recommended before deploying Transparent Interception in production, as it can disrupt applications using certificate pinning.
