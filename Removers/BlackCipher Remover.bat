# Must be run as Administrator

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== BlackCipher / Nexon Game Security Removal ===" -ForegroundColor Cyan

# Use the official uninstaller first if present
$ngServicePaths = @(
    "C:\ProgramData\Nexon\NGS\NGService.exe",
    "C:\Program Files (x86)\Common Files\BlackCipher\NGService.exe",
    "C:\Program Files (x86)\Nexon\NGService.exe"
)

foreach ($ng in $ngServicePaths) {
    if (Test-Path $ng) {
        Write-Host "Running official uninstaller: $ng"
        Start-Process $ng -ArgumentList "--uninstall" -Verb RunAs -Wait
        break
    }
}

# Stop and remove the service
foreach ($svc in @("NGS", "NexonGameSecurity", "Nexon Game Security", "BlackCipher")) {
    $s = Get-Service -Name $svc
    if ($s) {
        Write-Host "Stopping service: $svc"
        Stop-Service -Name $svc -Force
        sc.exe delete $svc | Out-Null
    }
}

# Kill any running processes
Get-Process | Where-Object { $_.Name -match "BlackCipher|NGService|NexonGame|NGM64|NMService" } | ForEach-Object {
    Write-Host "Killing process: $($_.Name)"
    $_ | Stop-Process -Force
}

# Remove leftover folders
$folders = @(
    "C:\ProgramData\Nexon",
    "C:\Program Files (x86)\Common Files\BlackCipher",
    "C:\Program Files (x86)\Common Files\Nexon",
    "C:\Program Files (x86)\Nexon",
    "$env:LOCALAPPDATA\Nexon"
)

foreach ($f in $folders) {
    if (Test-Path $f) {
        Write-Host "Removing folder: $f"
        Remove-Item $f -Recurse -Force
    }
}

# Remove registry entries
$regKeys = @(
    "HKLM:\System\CurrentControlSet\Services\NGS",
    "HKLM:\System\CurrentControlSet\Services\NexonGameSecurity",
    "HKLM:\Software\Nexon",
    "HKLM:\Software\WOW6432Node\Nexon",
    "HKCU:\Software\Nexon"
)

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Write-Host "Removing registry key: $key"
        Remove-Item $key -Recurse -Force
    }
}

# Sweep remaining Nexon registry entries
Write-Host "Scanning registry for remaining Nexon/BlackCipher entries..."
$hives = @("HKLM:\Software", "HKLM:\Software\WOW6432Node", "HKCU:\Software")
foreach ($hive in $hives) {
    Get-ChildItem $hive -Recurse | Where-Object { $_.Name -match "Nexon|BlackCipher|NGService" } | ForEach-Object {
        Write-Host "  Removing: $($_.Name)"
        Remove-Item $_.PSPath -Recurse -Force
    }
}

Write-Host "`nDone. Reboot recommended to fully unload the kernel driver." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
