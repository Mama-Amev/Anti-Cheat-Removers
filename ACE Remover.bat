@echo off
:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges to delete the services and files.
    echo Please accept the permissions prompt to proceed.
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    echo If you declined the permissions prompt, the script cannot continue.
    pause
    exit /b
)

:: Deleting services
echo Checking and deleting services...
sc delete ACE-GAME
sc delete ACE-BASE
sc delete "AntiCheatExpert Service"
sc delete "AntiCheatExpert Protection"

:: Check if services are running
echo Checking if ACE-BASE and AntiCheatExpert Service are still running...
sc query ACE-BASE | findstr /i "STATE" | findstr /i "RUNNING" >nul
set ACE_BASE_RUNNING=%errorlevel%

sc query "AntiCheatExpert Service" | findstr /i "STATE" | findstr /i "RUNNING" >nul
set ANTICHEAT_SERVICE_RUNNING=%errorlevel%

if %ACE_BASE_RUNNING% neq 0 if %ANTICHEAT_SERVICE_RUNNING% neq 0 (
    echo Both services are not running. Proceeding to delete folders and files...

    :: Delete folders
    echo Deleting folder: C:\Program Files\AntiCheatExpert
    rmdir /s /q "C:\Program Files\AntiCheatExpert"

    echo Deleting folder: C:\ProgramData\AntiCheatExpert
    rmdir /s /q "C:\ProgramData\AntiCheatExpert"

    :: Delete file
    echo Deleting file: C:\Windows\System32\drivers\ACE-BASE.sys
    del /f /q "C:\Windows\System32\drivers\ACE-BASE.sys"

    echo All specified folders and files have been deleted.
) else (
    echo One or more services are still running. Please restart your pc and run the this file again.
)
pause
