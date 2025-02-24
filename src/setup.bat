@echo off
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    :: If not running as Administrator, re-launch the script with Administrator privileges
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0 %*' -Verb runAs"
    exit
)

:: This script will create a scheduled task to run a specific bat script on system boot
set script_path="%~dp0disableVanguard.bat"

schtasks /create /tn "VanguardBootDisable" /tr %script_path% /sc onstart /f

schtasks /query /tn "VanguardBootDisable" >nul 2>&1
if %errorlevel% equ 0 (
    echo Vanguard has been set to disable on boot!
) else (
    echo !!!Unable to create task! Attempt running this script as admin!!!
)
pause