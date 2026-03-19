@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "EAC_FOUND=0"

echo Checking for EasyAntiCheat...

REM --- Stop and remove the service if it exists ---
sc query EasyAntiCheat >nul 2>&1
if %errorLevel% equ 0 (
    echo [FOUND] EasyAntiCheat service detected.
    set "EAC_FOUND=1"
    sc stop EasyAntiCheat >nul 2>&1
    sc delete EasyAntiCheat >nul 2>&1
    echo [DONE] Service stopped and removed.
)

sc query EasyAntiCheat_EOS >nul 2>&1
if %errorLevel% equ 0 (
    echo [FOUND] EasyAntiCheat_EOS service detected.
    set "EAC_FOUND=1"
    sc stop EasyAntiCheat_EOS >nul 2>&1
    sc delete EasyAntiCheat_EOS >nul 2>&1
    echo [DONE] EOS service stopped and removed.
)

REM --- Kill any running EAC processes ---
tasklist /fi "imagename eq EasyAntiCheat.exe" 2>nul | find /i "EasyAntiCheat.exe" >nul
if %errorLevel% equ 0 (
    taskkill /f /im EasyAntiCheat.exe >nul 2>&1
    echo [DONE] Killed EasyAntiCheat.exe process.
)

tasklist /fi "imagename eq EasyAntiCheat_EOS.exe" 2>nul | find /i "EasyAntiCheat_EOS.exe" >nul
if %errorLevel% equ 0 (
    taskkill /f /im EasyAntiCheat_EOS.exe >nul 2>&1
    echo [DONE] Killed EasyAntiCheat_EOS.exe process.
)

REM --- Remove known EAC driver files ---
set "DRIVERS=EasyAntiCheat.sys EasyAntiCheat_EOS.sys"
for %%D in (%DRIVERS%) do (
    if exist "%SystemRoot%\System32\drivers\%%D" (
        set "EAC_FOUND=1"
        echo [FOUND] Driver: %%D
        del /f /q "%SystemRoot%\System32\drivers\%%D" >nul 2>&1
        echo [DONE] Deleted %%D
    )
)

REM --- Remove common EAC install directories ---
set "EAC_DIRS=C:\Program Files (x86)\EasyAntiCheat C:\Program Files\EasyAntiCheat C:\Program Files (x86)\EasyAntiCheat_EOS C:\Program Files\EasyAntiCheat_EOS"
for %%P in (%EAC_DIRS%) do (
    if exist "%%P" (
        set "EAC_FOUND=1"
        echo [FOUND] Directory: %%P
        rd /s /q "%%P" >nul 2>&1
        echo [DONE] Removed %%P
    )
)

REM --- Clean up registry entries ---
set "EAC_KEYS=HKLM\SYSTEM\CurrentControlSet\Services\EasyAntiCheat HKLM\SYSTEM\CurrentControlSet\Services\EasyAntiCheat_EOS HKLM\SOFTWARE\EasyAntiCheat HKLM\SOFTWARE\WOW6432Node\EasyAntiCheat"
for %%K in (%EAC_KEYS%) do (
    reg query "%%K" >nul 2>&1
    if !errorLevel! equ 0 (
        set "EAC_FOUND=1"
        echo [FOUND] Registry key: %%K
        reg delete "%%K" /f >nul 2>&1
        echo [DONE] Deleted registry key.
    )
)

echo.
if "%EAC_FOUND%"=="1" (
    echo EasyAntiCheat has been removed. A reboot is recommended.
) else (
    echo No EasyAntiCheat installation was found. Nothing to remove.
)

pause
endlocal