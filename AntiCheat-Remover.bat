@echo off
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
title Anti-Cheat Removal Tool
echo ========================================
echo        Anti-Cheat Removal Tool
echo ========================================
echo.
echo  [1] EA Anti-Cheat
echo  [2] EasyAntiCheat (EAC)
echo  [3] nProtect GameGuard
echo  [4] AntiCheatExpert (ACE)
echo  [5] BattlEye
echo  [6] Exit
echo.
set /p "choice=Select an option (1-6): "

if "%choice%"=="1" goto ea_anticheat
if "%choice%"=="2" goto eac
if "%choice%"=="3" goto nprotect
if "%choice%"=="4" goto ace
if "%choice%"=="5" goto battleye
if "%choice%"=="6" exit

echo Invalid selection. Please enter a number between 1 and 6.
timeout /t 2 >nul
goto menu


:: ============================================================
:ea_anticheat
cls
title EA Anti-Cheat Removal
set "installer=C:\Program Files\EA\AC\EAAntiCheat.Installer.exe"

if not exist "%installer%" (
    echo EA Anti-Cheat was not found on this system.
    pause & goto menu
)

echo Removing EA Anti-Cheat...
"%installer%" uninstall
echo Done. EA Anti-Cheat has been removed.
pause & goto menu


:: ============================================================
:eac
cls
title EasyAntiCheat Removal
set "EAC_FOUND=0"

echo Checking for EasyAntiCheat...

sc query EasyAntiCheat >nul 2>&1
if %errorLevel% equ 0 (
    set "EAC_FOUND=1"
    echo [FOUND] EasyAntiCheat service.
    sc stop EasyAntiCheat >nul 2>&1
    sc delete EasyAntiCheat >nul 2>&1
    echo [DONE] Service stopped and removed.
)

sc query EasyAntiCheat_EOS >nul 2>&1
if %errorLevel% equ 0 (
    set "EAC_FOUND=1"
    echo [FOUND] EasyAntiCheat_EOS service.
    sc stop EasyAntiCheat_EOS >nul 2>&1
    sc delete EasyAntiCheat_EOS >nul 2>&1
    echo [DONE] EOS service stopped and removed.
)

for %%P in (EasyAntiCheat.exe EasyAntiCheat_EOS.exe) do (
    tasklist /fi "imagename eq %%P" 2>nul | find /i "%%P" >nul
    if !errorLevel! equ 0 (
        taskkill /f /im "%%P" >nul 2>&1
        echo [DONE] Killed %%P
    )
)

for %%D in (EasyAntiCheat.sys EasyAntiCheat_EOS.sys) do (
    if exist "%SystemRoot%\System32\drivers\%%D" (
        set "EAC_FOUND=1"
        del /f /q "%SystemRoot%\System32\drivers\%%D" >nul 2>&1
        echo [DONE] Deleted driver: %%D
    )
)

for %%P in (
    "C:\Program Files (x86)\EasyAntiCheat"
    "C:\Program Files\EasyAntiCheat"
    "C:\Program Files (x86)\EasyAntiCheat_EOS"
    "C:\Program Files\EasyAntiCheat_EOS"
) do (
    if exist %%P (
        set "EAC_FOUND=1"
        rd /s /q %%P >nul 2>&1
        echo [DONE] Removed %%P
    )
)

for %%K in (
    "HKLM\SYSTEM\CurrentControlSet\Services\EasyAntiCheat"
    "HKLM\SYSTEM\CurrentControlSet\Services\EasyAntiCheat_EOS"
    "HKLM\SOFTWARE\EasyAntiCheat"
    "HKLM\SOFTWARE\WOW6432Node\EasyAntiCheat"
) do (
    reg query %%K >nul 2>&1
    if !errorLevel! equ 0 (
        set "EAC_FOUND=1"
        reg delete %%K /f >nul 2>&1
        echo [DONE] Deleted registry key: %%K
    )
)

echo.
if "%EAC_FOUND%"=="1" (
    echo EasyAntiCheat has been removed. A reboot is recommended.
) else (
    echo No EasyAntiCheat installation was found. Nothing to remove.
)
pause & goto menu


:: ============================================================
:nprotect
cls
title nProtect GameGuard Removal
set "GG_FOUND=0"

echo Checking for nProtect GameGuard...

for %%S in (npggsvc nProtectGameGuard GameMon) do (
    sc query "%%S" >nul 2>&1
    if !errorLevel! equ 0 (
        set "GG_FOUND=1"
        echo [FOUND] Service: %%S
        sc stop "%%S" >nul 2>&1
        sc delete "%%S" >nul 2>&1
        echo [DONE] Service stopped and removed.
    )
)

for %%P in (GameMon.des GameMon64.des GGAuthService.des npggNT.des npgg.des GGinit.des) do (
    tasklist /fi "imagename eq %%P" 2>nul | find /i "%%P" >nul
    if !errorLevel! equ 0 (
        taskkill /f /im "%%P" >nul 2>&1
        echo [DONE] Killed process: %%P
    )
)

for %%D in (npkcrypt.sys npkcusb.sys npkpdb.sys gamemon.des npgg.des npggNT.des) do (
    if exist "%SystemRoot%\System32\drivers\%%D" (
        set "GG_FOUND=1"
        del /f /q "%SystemRoot%\System32\drivers\%%D" >nul 2>&1
        echo [DONE] Deleted driver: %%D
    )
    if exist "%SystemRoot%\System32\%%D" (
        set "GG_FOUND=1"
        del /f /q "%SystemRoot%\System32\%%D" >nul 2>&1
        echo [DONE] Deleted system file: %%D
    )
)

if exist "%SystemRoot%\npkcrypt.sys" (
    set "GG_FOUND=1"
    del /f /q "%SystemRoot%\npkcrypt.sys" >nul 2>&1
    echo [DONE] Deleted npkcrypt.sys from Windows root.
)

for %%P in ("C:\GameGuard" "C:\Program Files\GameGuard" "C:\Program Files (x86)\GameGuard") do (
    if exist %%P (
        set "GG_FOUND=1"
        rd /s /q %%P >nul 2>&1
        echo [DONE] Removed %%P
    )
)

for %%K in (
    "HKLM\SYSTEM\CurrentControlSet\Services\npggsvc"
    "HKLM\SYSTEM\CurrentControlSet\Services\npkcrypt"
    "HKLM\SYSTEM\CurrentControlSet\Services\GameMon"
    "HKLM\SOFTWARE\nProtect"
    "HKLM\SOFTWARE\WOW6432Node\nProtect"
    "HKLM\SOFTWARE\INCA Internet"
) do (
    reg query %%K >nul 2>&1
    if !errorLevel! equ 0 (
        set "GG_FOUND=1"
        reg delete %%K /f >nul 2>&1
        echo [DONE] Deleted registry key: %%K
    )
)

echo.
if "%GG_FOUND%"=="1" (
    echo nProtect GameGuard has been removed. A reboot is recommended.
) else (
    echo No nProtect GameGuard installation was found. Nothing to remove.
)
pause & goto menu


:: ============================================================
:ace
cls
title AntiCheatExpert Removal

echo Stopping and removing ACE services...
sc stop ACE-GAME >nul 2>&1 & sc delete ACE-GAME >nul 2>&1
sc stop ACE-BASE >nul 2>&1 & sc delete ACE-BASE >nul 2>&1
sc stop "AntiCheatExpert Service" >nul 2>&1 & sc delete "AntiCheatExpert Service" >nul 2>&1
sc stop "AntiCheatExpert Protection" >nul 2>&1 & sc delete "AntiCheatExpert Protection" >nul 2>&1

sc query ACE-BASE | findstr /i "RUNNING" >nul
set ACE_BASE_RUNNING=%errorlevel%
sc query "AntiCheatExpert Service" | findstr /i "RUNNING" >nul
set ACE_SVC_RUNNING=%errorlevel%

if %ACE_BASE_RUNNING% neq 0 if %ACE_SVC_RUNNING% neq 0 (
    rd /s /q "C:\Program Files\AntiCheatExpert" >nul 2>&1
    rd /s /q "C:\ProgramData\AntiCheatExpert" >nul 2>&1
    del /f /q "C:\Windows\System32\drivers\ACE-BASE.sys" >nul 2>&1
    echo AntiCheatExpert has been removed. A reboot is recommended.
) else (
    echo One or more ACE services are still running. Please reboot and try again.
)
pause & goto menu


:: ============================================================
:battleye
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
pause & goto menu
