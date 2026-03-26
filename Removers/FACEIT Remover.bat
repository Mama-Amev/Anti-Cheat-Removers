# Must be run as Administrator

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== FACEIT Anti-Cheat Removal ===" -ForegroundColor Cyan

# Stop and disable services
foreach ($svc in @("FACEIT", "FACEITService")) {
    $s = Get-Service -Name $svc
    if ($s) {
        Write-Host "Stopping service: $svc"
        Stop-Service -Name $svc -Force
        sc.exe delete $svc | Out-Null
    }
}

# Kill any running FACEIT processes
Get-Process | Where-Object { $_.Name -like "*faceit*" } | ForEach-Object {
    Write-Host "Killing process: $($_.Name)"
    $_ | Stop-Process -Force
}

# Run official uninstallers if present
$uninstallers = @(
    "C:\Program Files\FACEIT AC\unins000.exe",
    "C:\Program Files\FACEIT AC Service\unins000.exe",
    "$env:LOCALAPPDATA\Programs\FACEIT Anti-Cheat\unins000.exe"
)

foreach ($u in $uninstallers) {
    if (Test-Path $u) {
        Write-Host "Running uninstaller: $u"
        Start-Process $u -ArgumentList "/SILENT" -Wait
    }
}

# Remove leftover folders
$folders = @(
    "C:\Program Files\FACEIT AC",
    "C:\Program Files\FACEIT AC Service",
    "$env:LOCALAPPDATA\Programs\FACEIT Anti-Cheat",
    "$env:LOCALAPPDATA\FACEIT"
)

foreach ($f in $folders) {
    if (Test-Path $f) {
        Write-Host "Removing folder: $f"
        Remove-Item $f -Recurse -Force
    }
}

# Remove registry keys
$regKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{1419E44C-0EF4-4822-9194-9F1A4D43973D}_is1",
    "HKLM:\System\CurrentControlSet\Services\FACEIT",
    "HKLM:\System\CurrentControlSet\Services\FACEITService"
)

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Write-Host "Removing registry key: $key"
        Remove-Item $key -Recurse -Force
    }
}

# Remove MuiCache entries
$muiCache = "HKCR:\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
if (Test-Path $muiCache) {
    Get-Item $muiCache | Select-Object -ExpandProperty Property |
        Where-Object { $_ -like "*FACEIT*" } | ForEach-Object {
            Write-Host "Removing MuiCache entry: $_"
            Remove-ItemProperty -Path $muiCache -Name $_
        }
}

Write-Host "`nDone. A reboot is recommended to unload the kernel driver." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
