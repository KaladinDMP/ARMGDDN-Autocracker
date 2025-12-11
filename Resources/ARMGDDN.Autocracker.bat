@echo off
setlocal enabledelayedexpansion
echo.
echo ============================================
echo   ARMGDDN Autocracker - GBE Fork
echo ============================================
echo.

set "droppedFile=%~1"
set "droppedDir=%~dp1"
set "fileName=%~n1"
set "extension=%~x1"
set "batchDir=%~dp0"

if /i not "%fileName%%extension%"=="steam_api64.dll" if /i not "%fileName%%extension%"=="steam_api.dll" (
    echo WARNING: The DLL file must be either steam_api64.dll or steam_api.dll
    echo.
    echo Dropped file: %fileName%%extension%
    echo.
    echo NOW EXITING...
    echo.
    pause
    exit /b 1
)

set "is64bit=0"
if /i "%fileName%"=="steam_api64" set "is64bit=1"

echo Detected: %fileName%%extension%
if "%is64bit%"=="1" (
    echo Architecture: 64-bit
) else (
    echo Architecture: 32-bit
)
echo.

echo ============================================
echo   Select DLL Version
echo ============================================
echo.
echo 1. Regular (standard emulation)
echo 2. Experimental with Overlay (ExOL)
echo    - Includes overlay (SHIFT+TAB)
echo    - Achievement notifications
echo    - Blocks non-LAN IPs
echo.
set /p dllChoice="Enter your choice (1 or 2): "

if "%dllChoice%"=="1" (
    set "useExperimental=0"
    echo.
    echo Selected: Regular DLLs
) else if "%dllChoice%"=="2" (
    set "useExperimental=1"
    echo.
    echo Selected: Experimental with Overlay
) else (
    echo Invalid choice. Defaulting to Regular.
    set "useExperimental=0"
)
echo.
pause

echo Backing up original DLL...
ren "%droppedFile%" "%fileName%.AG"
if errorlevel 1 (
    echo ERROR: Could not rename original DLL. It may be in use.
    pause
    exit /b 1
)
echo Original backed up as: %fileName%.AG
echo.

if "%is64bit%"=="1" (
    if "%useExperimental%"=="1" (
        set "sourceFile=%batchDir%Api\steam_api64ExOL.dll"
    ) else (
        set "sourceFile=%batchDir%Api\steam_api64.dll"
    )
    set "destFile=%droppedDir%steam_api64.dll"
) else (
    if "%useExperimental%"=="1" (
        set "sourceFile=%batchDir%Api\steam_apiExOL.dll"
    ) else (
        set "sourceFile=%batchDir%Api\steam_api.dll"
    )
    set "destFile=%droppedDir%steam_api.dll"
)

if not exist "%sourceFile%" (
    echo ERROR: Source DLL not found: %sourceFile%
    echo.
    echo Make sure the GBE Fork DLLs are in: %batchDir%Api\
    echo.
    ren "%droppedDir%%fileName%.AG" "%fileName%%extension%"
    pause
    exit /b 1
)

echo Copying GBE Fork DLL...
copy "%sourceFile%" "%destFile%" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not copy DLL.
    ren "%droppedDir%%fileName%.AG" "%fileName%%extension%"
    pause
    exit /b 1
)
echo DLL replaced successfully!
echo.

set "appIdFile="
for /r "%droppedDir%" %%f in (steam_appid.txt) do (
    if exist "%%f" (
        set "appIdFile=%%f"
        goto :foundAppIdFile
    )
)

if "%appIdFile%"=="" (
    echo steam_appid.txt not found in game directory.
    echo Running ARMGDDN.App.ID.exe to find it...
    echo.
    call "%batchDir%AppID\ARMGDDN.App.ID.exe" "%droppedDir%"
    if exist "%batchDir%AppID\steam_appid.txt" (
        echo Moving steam_appid.txt to game directory...
        move "%batchDir%AppID\steam_appid.txt" "%droppedDir%" >nul
        set "appIdFile=%droppedDir%steam_appid.txt"
        goto :foundAppIdFile
    ) else (
		CLS
        echo steam_appid.txt not found. Please enter the Steam App ID manually.
        goto :needAppId
    )
)

:foundAppIdFile
CLS
set /p appId=<"%appIdFile%"
echo.
echo ============================================
echo   Steam App ID Found!
echo ============================================
echo.
echo App ID: %appId%
echo Source: %appIdFile%
echo.
goto :haveAppId

:needAppId
echo.
echo ============================================
echo   Steam App ID Required
echo ============================================
echo.
set /p needHelp="Do you need help finding the App ID? (Y/N): "
if /i "%needHelp%"=="Y" (
    start "" "https://www.youtube.com/watch?v=XHQT7a-ORFk"
) else if /i "%needHelp%"=="Yes" (
    start "" "https://www.youtube.com/watch?v=XHQT7a-ORFk"
)
echo.
set /p appId="Enter the game's Steam App ID: "

:haveAppId
CLS
echo.
echo ============================================
echo   Generating Steam Settings (GBE Format)
echo ============================================
echo.
echo App ID: %appId%
echo.
echo This will create:
echo   - steam_settings/steam_appid.txt
echo   - steam_settings/achievements.json
echo   - steam_settings/stats.json
echo   - steam_settings/images/ (achievement icons)
echo   - steam_settings/configs.app.ini (DLC)
echo   - steam_settings/configs.user.ini (user settings)
echo.
pause

"%batchDir%ARMGDDN.Steam.Settings.exe" %appId%

echo.
echo ============================================
echo   Script Complete!
echo ============================================
echo.
echo DLL Version: %dllChoice% 
if "%useExperimental%"=="1" (
    echo Type: Experimental with Overlay
) else (
    echo Type: Regular
)
echo.
echo Next steps:
echo   1. Check steam_settings folder was created
echo   2. Copy steam_settings to game directory if needed
echo   3. Run the game!
echo.
pause
exit /b 0