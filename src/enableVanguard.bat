@echo off
setlocal

openfiles >nul 2>&1
if %errorlevel% neq 0 (
    :: If not running as Administrator, re-launch the script with Administrator privileges
    echo This script requires Administrator privileges. Restarting with elevated permissions...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0 %*' -Verb runAs"
    exit
)

call :confirmRun
if "%userChoice%"=="No" (
	exit /b 1
)

set SERVICE_NAME=vgc

call :checkServiceExists
call :getServiceStartType
call :setServiceStartType
call :getServiceStartType
call :validateServiceStartType

set SERVICE_NAME=vgk

call :checkServiceExists
call :getServiceStartType
call :setServiceStartType
call :getServiceStartType
call :validateServiceStartType


:checkServiceExists
    :: Check if the service exists
    sc qc "%SERVICE_NAME%" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Service "%SERVICE_NAME%" does not exist.
        goto end
    )
goto :eof

:getServiceStartType
    :: Get the current start_type of the service
    for /f "tokens=2 delims=:" %%i in ('sc qc "%SERVICE_NAME%" ^| find "START_TYPE"') do set START_TYPE=%%i

    :: Remove leading and trailing spaces
    for /f "tokens=* delims= " %%a in ("%START_TYPE%") do set START_TYPE=%%a

    :: Get the second token
    for /f "tokens=2 delims= " %%c in ("%START_TYPE%") do set START_TYPE=%%c
goto :eof

:setServiceStartType
    echo "%START_TYPE%"|findstr /i "DISABLED"
    if %errorlevel% equ 0 (
        echo The service "%SERVICE_NAME%" is set to Disabled. Changing to Auto Start...
        sc config "%SERVICE_NAME%" start= auto
    ) else (
        echo The service "%SERVICE_NAME%" is not set to Disabled. No changes made.
    )
goto :eof

:validateServiceStartType
    echo "%START_TYPE%"|findstr /i "AUTO"
    if %errorlevel% equ 0 (
        goto :end
    ) else (
        goto :errorBox
    )

:errorBox
    echo Set objArgs = WScript.Arguments > "%temp%\alert.vbs"
    echo msgBox "Error: Failed to enable service %SERVICE_NAME%. Please check permissions.", 48, "Service Enable Failed" >> "%temp%\alert.vbs"
    echo Error: Failed to enable service %SERVICE_NAME%. Please check permissions.
    cscript //nologo "%temp%\alert.vbs"
    del "%temp%\alert.vbs"
goto :end

:confirmRun
	echo Dim userInput > "%temp%\usrinp.vbs"
	echo userInput = MsgBox("Do you want to enable Vanguard next boot?", vbYesNo + vbQuestion, "Confirm") >> "%temp%\usrinp.vbs"
	echo If userInput = vbYes Then >> "%temp%\usrinp.vbs"
    echo	WScript.Echo "Yes" >> "%temp%\usrinp.vbs"
	echo Else >> "%temp%\usrinp.vbs"
    echo 	WScript.Echo "No" >> "%temp%\usrinp.vbs"
	echo End If >> "%temp%\usrinp.vbs"
	for /f "delims=" %%a in ('cscript //nologo %temp%\usrinp.vbs') do set userChoice=%%a
	del "%temp%\usrinp.vbs"


:end
endlocal