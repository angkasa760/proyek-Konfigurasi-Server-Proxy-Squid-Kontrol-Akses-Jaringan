<#
.SYNOPSIS
    Deploys the Squid Proxy CA certificate to the Windows Trusted Root store.

.DESCRIPTION
    This script imports a specified certificate file (.crt or .pem) into the 
    Local Machine's Trusted Root Certification Authorities store. Requires Admin privileges.

.PARAMETER CertPath
    The absolute path to the certificate file.

.PARAMETER RestartBrowser
    If set, attempts to close common browsers to ensure they reload the certificate store.

.EXAMPLE
    .\deploy_ca_windows.ps1 -CertPath "C:\certs\myCA.crt" -RestartBrowser
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CertPath,

    [switch]$RestartBrowser
)

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Error "Elevated privileges required. Please run PowerShell as Administrator."
    exit 1
}

if (-not (Test-Path $CertPath)) {
    Write-Error "Certificate file not found at: $CertPath"
    exit 2
}

Write-Host "[*] Importing certificate into Local Machine Root store..." -ForegroundColor Cyan

try {
    # Using certutil for compatibility across Windows versions
    $certutilArgs = @("-addstore", "-f", "Root", "`"$CertPath`"")
    Start-Process -FilePath "certutil.exe" -ArgumentList $certutilArgs -Wait -NoNewWindow
    
    Write-Host "[SUCCESS] Certificate imported successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to import certificate. Error: $($_.Exception.Message)"
    exit 3
}

if ($RestartBrowser) {
    Write-Host "[*] Restarting browsers (Edge, Chrome, Firefox)..." -ForegroundColor Yellow
    Get-Process -Name msedge, chrome, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "[INFO] Browsers closed. Please restart them manually." -ForegroundColor Gray
}

Write-Host "[DONE] Client configuration complete." -ForegroundColor Green
