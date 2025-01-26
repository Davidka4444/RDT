@echo off
@chcp 65001 >nul
title Recovery and Debugging Tool (RDT)
color 80

:: Check for administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Running as administrator...
    powershell -Command "Start-Process cmd -Argument '/c %~s0' -Verb RunAs"
    exit
)

:menu
cls
echo  _____                 _      _     _
echo ^|  __ \               (_)    ^| ^|   (_)
echo ^| ^|  ^| ^|  __ _ __   __ _   __^| ^|    _  _ __    ___
echo ^| ^|  ^| ^| / _` ^|\ \ / /^| ^| / _` ^|   ^| ^|^| '_ \  / __^|
echo ^| ^|__^| ^|^| (_^| ^| \ V / ^| ^|^| (_^| ^| _ ^| ^|^| ^| ^| ^|^| (__ 
echo ^|_____/  \__,_^|  ^\_^/  ^|_^| \__,_^|(_)^|_^|^|_^| ^|_^| \___^|
echo ================================
echo Recovery and Debugging Tool (RDT)
echo ================================
echo 1. Check system files
echo 2. Check disk for errors
echo 3. Clean temporary files
echo 4. Unlock menu
echo 5. Clear DNS cache
echo 6. Disable Windows Update service
echo 7. Enable Windows Update service
echo 8. Check network status
echo 9. Display system information
echo 10. Create a system restore point
echo 11. Delete temporary files from Windows folder
echo 12. Display disk information
echo 13. Check for Windows updates
echo 14. Display list of installed programs
echo 15. CPU stress test
echo 16. Exit
echo ================================
set /p choice="Select an option (1-16): "

:: Process user choice
call :handleChoice %choice%
goto menu

:handleChoice
setlocal
set choice=%1
if "%choice%"=="1" goto sfc
if "%choice%"=="2" goto chkdsk
if "%choice%"=="3" goto cleanup
if "%choice%"=="4" goto unlockMenu
if "%choice%"=="5" goto flushdns
if "%choice%"=="6" goto disablewu
if "%choice%"=="7" goto enablewu
if "%choice%"=="8" goto netstatus
if "%choice%"=="9" goto sysinfo
if "%choice%"=="10" goto restorepoint
if "%choice%"=="11" goto cleanupwindows
if "%choice%"=="12" goto diskinfo
if "%choice%"=="13" goto checkupdates
if "%choice%"=="14" goto installedprograms
if "%choice%"=="15" goto stresstest
if "%choice%"=="16" exit
if "%choice%"=="$creator$" goto creator
goto menu
endlocal

:: Functions
:sfc
echo Checking system files...
sfc /scannow
call :pause
goto menu

:chkdsk
echo Checking disk for errors...
chkdsk C: /f /r
call :pause
goto menu

:cleanup
echo Cleaning temporary files...
del /q /f %temp%\* >nul 2>&1
if %errorlevel%==0 (
    echo Temporary files cleaned.
) else (
    echo Error cleaning temporary files.
)
call :pause
goto menu

:unlockMenu
cls
echo ================================
echo Unlock Menu
echo ================================
echo 1. Unlock Task Manager
echo 2. Unlock Settings
echo 3. Unlock Registry Editor
echo 4. Unlock Command Prompt
echo 5. Unlock Control Panel
echo 6. Return to main menu
echo ================================
set /p unlockChoice="Select an option (1-6): "

if "%unlockChoice%"=="1" goto unlockTaskManager
if "%unlockChoice%"=="2" goto unlockSettings
if "%unlockChoice%"=="3" goto unlockRegEditor
if "%unlockChoice%"=="4" goto unlockCmd
if "%unlockChoice%"=="5" goto unlockControlPanel
if "%unlockChoice%"=="6" goto menu
goto unlockMenu

:unlockTaskManager
echo Unlocking Task Manager...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableTaskMgr" /f >nul 2>&1
echo Task Manager unlocked. Please restart your computer to apply changes.
call :pause
goto unlockMenu

:unlockSettings
echo Unlocking Settings...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "NoControlPanel" /f >nul 2>&1
echo Settings unlocked. Please restart your computer to apply changes.
call :pause
goto unlockMenu

:unlockRegEditor
echo Unlocking Registry Editor...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableRegistryTools" /f >nul 2>&1
echo Registry Editor unlocked. Please restart your computer to apply changes.
call :pause
goto unlockMenu

:unlockCmd
echo Unlocking Command Prompt...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableCMD" /f >nul 2>&1
echo Command Prompt unlocked. Please restart your computer to apply changes.
call :pause
goto unlock

:unlockControlPanel
echo Unlocking Control Panel...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "NoControlPanel" /f >nul 2>&1
echo Control Panel unlocked. Please restart your computer to apply changes.
call :pause
goto unlockMenu

:flushdns
echo Clearing DNS cache...
ipconfig /flushdns
echo DNS cache cleared.
call :pause
goto menu

:disablewu
echo Disabling Windows Update service...
sc stop wuauserv >nul 2>&1
sc config wuauserv start= disabled
echo Windows Update service disabled.
call :pause
goto menu

:enablewu
echo Enabling Windows Update service...
sc config wuauserv start= auto
sc start wuauserv
echo Windows Update service enabled.
call :pause
goto menu

:netstatus
echo Checking network status...
ipconfig /all
call :pause
goto menu

:sysinfo
echo System information:
systeminfo
call :pause
goto menu

:restorepoint
echo Creating a system restore point...
powershell -Command "Checkpoint-Computer -Description 'RDT Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo Restore point created.
) else (
    echo Error creating restore point.
)
call :pause
goto menu

:cleanupwindows
echo Deleting temporary files from Windows folder...
del /q /f C:\Windows\Temp\* >nul 2>&1
if %errorlevel%==0 (
    echo Temporary files from Windows folder cleaned.
) else (
    echo Error cleaning temporary files from Windows folder.
)
call :pause
goto menu

:diskinfo
echo Disk information:
wmic logicaldisk get name, size, freespace
call :pause
goto menu

:checkupdates
echo Checking for Windows updates...
powershell -Command "Get-WindowsUpdate"
call :pause
goto menu

:installedprograms
echo List of installed programs:
wmic product get name, version
call :pause
goto menu

:stresstest
echo Starting CPU stress test...
set /p processCount="Enter number of threads (recommended 4): "
for /L %%i in (1,1,%processCount%) do (
    start "CPU Stress Test" cmd /c "powershell -Command while ($true) { [Math]::Sqrt(12345)}"
)

echo Stress test started. Press any key to stop the test.

:: Wait for key press
pause >nul

:: Close all windows with the specified title
taskkill /FI "WINDOWTITLE eq Administrator: CPU Stress Test" /F

goto menu

:creator
color 60
echo You've found the secret command!
echo David.inc, all rights reserved
call pause
color 80
goto menu

:pause
echo Press any key to continue...
pause >nul
exit /b

pause