@echo off
title EA Anti-Cheat Removal
set "installer=C:\Program Files\EA\AC\EAAntiCheat.Installer.exe"

if not exist "%installer%" (
    echo EA Anti-Cheat was not found on this system.
    pause & exit
)

echo Removing EA Anti-Cheat...
"%installer%" uninstall
echo Done. You may now close this window.
pause
exit