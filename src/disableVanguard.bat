@echo off
setlocal

openfiles >nul 2>&1
if %errorlevel% neq 0 (
    :: If not running as Administrator, re-launch the script with Administrator privileges
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0 %*' -Verb runAs"
    exit
)

set SKIP_SERV=0
set SERVICE_NAME=vgc

call :checkServiceExists
if SKIP_SERV equ 1 (
	call :getServiceStartType
	call :setServiceStartType
	call :getServiceStartType
	call :validateServiceStartType
)

set SERVICE_NAME=vgk

call :checkServiceExists
if SKIP_SERV equ 1 (
	call :getServiceStartType
	call :setServiceStartType
	call :getServiceStartType
	call :validateServiceStartType
)

goto :end


:checkServiceExists
    :: Check if the service exists
    sc qc "%SERVICE_NAME%" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Service "%SERVICE_NAME%" does not exist.
        set SKIP_SERV=1
    ) else (
		set SKIP_SERV=0
	)
goto :eof

:getServiceStartType
    :: Get the current start type of the service
    for /f "tokens=2 delims=:" %%i in ('sc qc "%SERVICE_NAME%" ^| find "START_TYPE"') do set START_TYPE=%%i

    :: Remove leading and trailing spaces
    for /f "tokens=* delims= " %%a in ("%START_TYPE%") do set START_TYPE=%%a

    :: Get the second token
    for /f "tokens=2 delims= " %%c in ("%START_TYPE%") do set START_TYPE=%%c
goto :eof

:setServiceStartType
    echo "%START_TYPE%"|findstr /i "AUTO"
    if %errorlevel% equ 0 (
        echo The service "%SERVICE_NAME%" is set to Automatic. Changing to Disabled...
        sc config "%SERVICE_NAME%" start= disabled
    ) else (
        echo The service "%SERVICE_NAME%" is not set to Automatic. No changes made.
    )
goto :eof

:validateServiceStartType
    echo "%START_TYPE%"|findstr /i "DISABLED"
    if %errorlevel% equ 0 (
        goto :end
    ) else (
        goto :errorBox
    )

:errorBox
    echo Set objArgs = WScript.Arguments > "%temp%\alert.vbs"
    echo msgBox "Error: Failed to disable service %SERVICE_NAME%. Please check permissions.", 48, "Service Disable Failed" >> "%temp%\alert.vbs"
    echo Error: Failed to disable service %SERVICE_NAME%. Please check permissions.
    cscript //nologo "%temp%\alert.vbs"
    del "%temp%\alert.vbs"
    exit


:end
    endlocal