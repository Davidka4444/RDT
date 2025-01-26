@echo off
@chcp 65001 >nul
title Инструмент Восстановления И Отладки (ИВИО)
color 80

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Запуск от имени администратора...
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
echo Инструмент Восстановления И Отладки (ИВИО)
echo ================================
echo 1. Проверка системных файлов
echo 2. Проверка диска на наличие ошибок
echo 3. Очистка временных файлов
echo 4. Меню разблокировки
echo 5. Очистка кэша DNS
echo 6. Отключение службы Windows Update
echo 7. Включение службы Windows Update
echo 8. Проверка состояния сети
echo 9. Вывод информации о системе
echo 10. Создание точки восстановления системы
echo 11. Удаление временных файлов из папки Windows
echo 12. Вывод информации о дисках
echo 13. Проверка обновлений Windows
echo 14. Вывод списка установленных программ
echo 15. Стресс-тест процессора
echo 16. Выход
echo ================================
set /p choice="Выберите опцию (1-16): "

:: Обработка выбора пользователя
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

:: Функции
:sfc
echo Проверка системных файлов...
sfc /scannow
call :pause
goto menu

:chkdsk
echo Проверка диска на наличие ошибок...
chkdsk C: /f /r
call :pause
goto menu

:cleanup
echo Очистка временных файлов...
del /q /f %temp%\* >nul 2>&1
if %errorlevel%==0 (
    echo Временные файлы очищены.
) else (
    echo Ошибка при очистке временных файлов.
)
call :pause
goto menu

:unlockMenu
cls
echo ================================
echo Меню разблокировки
echo ================================
echo 1. Разблокировка диспетчера задач
echo 2. Разблокировка настроек
echo 3. Разблокировка редактора реестра
echo 4. Разблокировка командной строки
echo 5. Разблокировка панели управления
echo 6. Вернуться в главное меню
echo ================================
set /p unlockChoice="Выберите опцию (1-6): "

if "%unlockChoice%"=="1" goto unlockTaskManager
if "%unlockChoice%"=="2" goto unlockSettings
if "%unlockChoice%"=="3" goto unlockRegEditor
if "%unlockChoice%"=="4" goto unlockCmd
if "%unlockChoice%"=="5" goto unlockControlPanel
if "%unlockChoice%"=="6" goto menu
goto unlockMenu

:unlockTaskManager
echo Разблокировка диспетчера задач...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableTaskMgr" /f >nul 2>&1
echo Диспетчер задач разблокирован. Пожалуйста, перезагрузите компьютер для применения изменений.
call :pause
goto unlockMenu

:unlockSettings
echo Разблокировка настроек...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "NoControlPanel
:unlockRegEditor
echo Разблокировка редактора реестра...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableRegistryTools" /f >nul 2>&1
echo Редактор реестра разблокирован. Пожалуйста, перезагрузите компьютер для применения изменений.
call :pause
goto unlockMenu

:unlockCmd
echo Разблокировка командной строки...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" /v "DisableCMD" /f >nul 2>&1
echo Командная строка разблокирована. Пожалуйста, перезагрузите компьютер для применения изменений.
call :pause
goto unlockMenu

:unlockControlPanel
echo Разблокировка панели управления...
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "NoControlPanel" /f >nul 2>&1
echo Панель управления разблокирована. Пожалуйста, перезагрузите компьютер для применения изменений.
call :pause
goto unlockMenu

:flushdns
echo Очистка кэша DNS...
ipconfig /flushdns
echo Кэш DNS очищен.
call :pause
goto menu

:disablewu
echo Отключение службы Windows Update...
sc stop wuauserv >nul 2>&1
sc config wuauserv start= disabled
echo Служба Windows Update отключена.
call :pause
goto menu

:enablewu
echo Включение службы Windows Update...
sc config wuauserv start= auto
sc start wuauserv
echo Служба Windows Update включена.
call :pause
goto menu

:netstatus
echo Проверка состояния сети...
ipconfig /all
call :pause
goto menu

:sysinfo
echo Информация о системе:
systeminfo
call :pause
goto menu

:restorepoint
echo Создание точки восстановления системы...
powershell -Command "Checkpoint-Computer -Description 'IVIO Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo Точка восстановления создана.
) else (
    echo Ошибка при создании точки восстановления.
)
call :pause
goto menu

:cleanupwindows
echo Удаление временных файлов из папки Windows...
del /q /f C:\Windows\Temp\* >nul 2>&1
if %errorlevel%==0 (
    echo Временные файлы из папки Windows очищены.
) else (
    echo Ошибка при очистке временных файлов из папки Windows.
)
call :pause
goto menu

:diskinfo
echo Информация о дисках:
wmic logicaldisk get name, size, freespace
call :pause
goto menu

:checkupdates
echo Проверка обновлений Windows...
powershell -Command "Get-WindowsUpdate"
call :pause
goto menu

:installedprograms
echo Список установленных программ:
wmic product get name, version
call :pause
goto menu

:stresstest
echo Запуск стресс-теста процессора...
set /p processCount="Введите количество потоков (рекомендуется 4): "
for /L %%i in (1,1,%processCount%) do (
    start "Стресс-тест процессора" cmd /c "powershell -Command while ($true) { [Math]::Sqrt(12345)}"
)

echo Стресс-тест запущен. Нажмите любую клавишу, чтобы остановить тест.

:: Ожидание нажатия клавиши
pause >nul

:: Закрытие всех окон с заданным названием
taskkill /FI "WINDOWTITLE eq Администратор: Стресс-тест процессора" /F

goto menu


:creator
color 60
echo Вы нашли пасхалку!
echo David.inc, все права защищены
call :pause
color 80
goto menu

:pause
echo Нажмите любую клавишу для продолжения...
pause >nul
exit /b
