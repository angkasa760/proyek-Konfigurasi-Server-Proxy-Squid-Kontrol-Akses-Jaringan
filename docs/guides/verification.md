# Verification & Troubleshooting Guide

This guide describes how to verify the Squid Proxy configuration and troubleshoot common connectivity issues.

## ✅ Functional Verification

### 1. Service Integrity
Ensure the Squid service is active and running without errors:
```bash
sudo systemctl status squid
```

### 2. Syntax Validation
Before applying changes, always check for configuration errors:
```bash
sudo squid -k parse
```

### 3. Real-time Traffic Monitoring
Monitor the access logs to confirm traffic flow and see TCP status codes (e.g., `TCP_MISS/200`, `TCP_DENIED/403`):
```bash
sudo tail -f /var/log/squid/access.log
```

---

## 🧪 Testing Connectivity

### 1. Command Line (cURL)
Test HTTP and HTTPS connectivity through the proxy:
```bash
# HTTP Test
curl -x http://172.24.0.1:3128 -I http://example.com

# HTTPS Test
curl -x http://172.24.0.1:3128 -I https://www.google.com
```

### 2. Text-Based Browsing
Using `elinks` or `lynx` to verify web content rendering:
```bash
elinks --dump http://www.google.com | head -n 10
```

---

## 🛠 Troubleshooting Common Issues

| Symptom | Possible Cause | Solution |
| :--- | :--- | :--- |
| `Connection Refused` | Squid service is down | `sudo systemctl start squid` |
| `Access Denied (403)` | Client IP not allowed | Check `acl localnet` in `squid.conf` |
| `SSL Connection Error` | Missing CA Certificate | Import `myCA.crt` to client's Trusted Roots |
| `DNS Resolution Failure` | Squid can't resolve WAN | Check `/etc/resolv.conf` on the proxy server |

---

> [!TIP]
> Use `sudo squid -k reconfigure` to apply configuration changes without restarting the entire service.
