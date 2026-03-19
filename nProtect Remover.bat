@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "GG_FOUND=0"

echo Checking for nProtect GameGuard...

REM --- Stop and remove the service if it exists ---
set "GG_SERVICES=npggsvc nProtectGameGuard GameMon"
for %%S in (%GG_SERVICES%) do (
    sc query "%%S" >nul 2>&1
    if !errorLevel! equ 0 (
        set "GG_FOUND=1"
        echo [FOUND] Service: %%S
        sc stop "%%S" >nul 2>&1
        sc delete "%%S" >nul 2>&1
        echo [DONE] Service stopped and removed.
    )
)

REM --- Kill any running GameGuard processes ---
set "GG_PROCS=GameMon.des GameMon64.des GGAuthService.des npggNT.des npgg.des GGinit.des"
for %%P in (%GG_PROCS%) do (
    tasklist /fi "imagename eq %%P" 2>nul | find /i "%%P" >nul
    if !errorLevel! equ 0 (
        taskkill /f /im "%%P" >nul 2>&1
        echo [DONE] Killed process: %%P
    )
)

REM --- Remove known GameGuard driver files ---
set "GG_DRIVERS=npkcrypt.sys npkcusb.sys npkpdb.sys gamemon.des npgg.des npggNT.des"
for %%D in (%GG_DRIVERS%) do (
    if exist "%SystemRoot%\System32\drivers\%%D" (
        set "GG_FOUND=1"
        echo [FOUND] Driver: %%D
        del /f /q "%SystemRoot%\System32\drivers\%%D" >nul 2>&1
        echo [DONE] Deleted %%D
    )
    if exist "%SystemRoot%\System32\%%D" (
        set "GG_FOUND=1"
        echo [FOUND] System file: %%D
        del /f /q "%SystemRoot%\System32\%%D" >nul 2>&1
        echo [DONE] Deleted %%D
    )
)

REM --- Remove npkcrypt.sys and related from Windows root as well ---
if exist "%SystemRoot%\npkcrypt.sys" (
    set "GG_FOUND=1"
    echo [FOUND] %SystemRoot%\npkcrypt.sys
    del /f /q "%SystemRoot%\npkcrypt.sys" >nul 2>&1
    echo [DONE] Deleted npkcrypt.sys from Windows root.
)

REM --- Remove standalone GameGuard folders ---
set "GG_DIRS=C:\GameGuard C:\Program Files\GameGuard C:\Program Files (x86)\GameGuard"
for %%P in (%GG_DIRS%) do (
    if exist "%%P" (
        set "GG_FOUND=1"
        echo [FOUND] Directory: %%P
        rd /s /q "%%P" >nul 2>&1
        echo [DONE] Removed %%P
    )
)

REM --- Clean up registry entries ---
set "GG_KEYS=HKLM\SYSTEM\CurrentControlSet\Services\npggsvc HKLM\SYSTEM\CurrentControlSet\Services\npkcrypt HKLM\SYSTEM\CurrentControlSet\Services\GameMon HKLM\SOFTWARE\nProtect HKLM\SOFTWARE\WOW6432Node\nProtect HKLM\SOFTWARE\INCA Internet"
for %%K in (%GG_KEYS%) do (
    reg query "%%K" >nul 2>&1
    if !errorLevel! equ 0 (
        set "GG_FOUND=1"
        echo [FOUND] Registry key: %%K
        reg delete "%%K" /f >nul 2>&1
        echo [DONE] Deleted registry key.
    )
)

echo.
if "%GG_FOUND%"=="1" (
    echo nProtect GameGuard has been removed. A reboot is recommended.
) else (
    echo No nProtect GameGuard installation was found. Nothing to remove.
)

pause
endlocal
