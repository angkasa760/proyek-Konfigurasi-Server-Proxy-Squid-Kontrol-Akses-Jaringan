# Client Configuration Guide

This guide describes how to configure endpoint devices to utilize the Squid Proxy Server for web traffic routing.

## 🖥 Windows Configuration

### Method 1: System-wide Proxy Settings
1. Open **Settings** > **Network & Internet** > **Proxy**.
2. Toggle **Use a proxy server** to **On**.
3. Enter the following details:
   * **Address**: `172.24.0.1`
   * **Port**: `3128`
4. Click **Save**.

### Method 2: PowerShell (Session-based)
To set the proxy for the current PowerShell session:
```powershell
$proxy = "http://172.24.0.1:3128"
$env:HTTP_PROXY = $proxy
$env:HTTPS_PROXY = $proxy
```

---

## 🐧 Linux Configuration

### Method 1: Environment Variables (Persistent)
Add the following lines to your `~/.bashrc` or `/etc/environment`:

```bash
export http_proxy=http://172.24.0.1:3128/
export https_proxy=http://172.24.0.1:3128/
export ftp_proxy=http://172.24.0.1:3128/
export no_proxy="localhost,127.0.0.1"
```

### Method 2: APT Configuration (Debian/Ubuntu)
Create a file at `/etc/apt/apt.conf.d/80proxy`:
```text
Acquire::http::Proxy "http://172.24.0.1:3128";
Acquire::https::Proxy "http://172.24.0.1:3128";
```

### Method 3: YUM/DNF Configuration (CentOS/RHEL)
Edit `/etc/yum.conf`:
```ini
proxy=http://172.24.0.1:3128
```

---

## 🌐 Browser Configuration (Firefox)
1. Go to **Settings** > **General** > **Network Settings**.
2. Select **Manual proxy configuration**.
3. HTTP Proxy: `172.24.0.1`, Port: `3128`.
4. Check **Also use this proxy for HTTPS**.
5. Click **OK**.

---

> [!IMPORTANT]
> If SSL Bump is enabled on the server, you must install the `myCA.crt` certificate in each client's **Trusted Root Certification Authorities** to avoid "Insecure Connection" warnings.
