@echo off
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
title BattlEye Removal
set "BE_FOUND=0"

echo Checking for BattlEye...

for %%S in (BEService BEService_x64 BattlEye) do (
    sc query "%%S" >nul 2>&1
    if !errorLevel! equ 0 (
        set "BE_FOUND=1"
        echo [FOUND] Service: %%S
        sc stop "%%S" >nul 2>&1
        sc delete "%%S" >nul 2>&1
        echo [DONE] Service stopped and removed.
    )
)

for %%P in (BEService.exe BEService_x64.exe BELauncher.exe BEDaisy.exe) do (
    tasklist /fi "imagename eq %%P" 2>nul | find /i "%%P" >nul
    if !errorLevel! equ 0 (
        taskkill /f /im "%%P" >nul 2>&1
        echo [DONE] Killed process: %%P
    )
)

for %%D in (BEDaisy.sys BattlEye.sys) do (
    if exist "%SystemRoot%\System32\drivers\%%D" (
        set "BE_FOUND=1"
        del /f /q "%SystemRoot%\System32\drivers\%%D" >nul 2>&1
        echo [DONE] Deleted driver: %%D
    )
)

for %%P in (
    "C:\Program Files (x86)\Common Files\BattlEye"
    "C:\Program Files\Common Files\BattlEye"
) do (
    if exist %%P (
        set "BE_FOUND=1"
        rd /s /q %%P >nul 2>&1
        echo [DONE] Removed directory: %%P
    )
)

for %%K in (
    "HKLM\SYSTEM\CurrentControlSet\Services\BEService"
    "HKLM\SYSTEM\CurrentControlSet\Services\BEService_x64"
    "HKLM\SYSTEM\CurrentControlSet\Services\BEDaisy"
    "HKLM\SOFTWARE\BattlEye"
    "HKLM\SOFTWARE\WOW6432Node\BattlEye"
) do (
    reg query %%K >nul 2>&1
    if !errorLevel! equ 0 (
        set "BE_FOUND=1"
        reg delete %%K /f >nul 2>&1
        echo [DONE] Deleted registry key: %%K
    )
)

echo.
if "%BE_FOUND%"=="1" (
    echo BattlEye has been removed. A reboot is recommended.
) else (
    echo No BattlEye installation was found. Nothing to remove.
)

echo Done. You may now close this window.
pause
endlocal
