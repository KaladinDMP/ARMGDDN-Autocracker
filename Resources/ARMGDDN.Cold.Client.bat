@echo off
setlocal enabledelayedexpansion
echo.
echo ============================================
echo   ARMGDDN Cold Client - GBE Fork
echo ============================================
echo.

set "droppedFile=%~1"
set "droppedDir=%~dp1"
set "fileName=%~n1"
set "extension=%~x1"
set "batchDir=%~dp0"
set "sourceDir=%batchDir%Client"

echo Game executable: %fileName%%extension%
echo Game directory: %droppedDir%
echo.

REM Look for steam_appid.txt
set "appId="
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
echo   Steam App ID Found
echo ============================================
echo.
echo App ID: %appId%
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

echo Detecting exe architecture...
echo.

REM ---------------------------------------------
REM Detect EXE bitness using PowerShell
REM Returns "32" or "64" or "UNKNOWN"
REM ---------------------------------------------
set "bitness=UNKNOWN"

for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command ^
    "$p='%droppedFile%';" ^
    "try{" ^
        "$fs=[IO.File]::OpenRead($p);" ^
        "$fs.Seek(0x3C,'Begin')> $null;" ^
        "$off=(New-Object IO.BinaryReader $fs).ReadInt32();" ^
        "$fs.Seek($off+4,'Begin')> $null;" ^
        "$m=(New-Object IO.BinaryReader $fs).ReadUInt16();" ^
        "$fs.Close();" ^
        "if($m -eq 0x014C){'32'} elseif($m -eq 0x8664){'64'} else {'UNKNOWN'}" ^
    "}catch{'UNKNOWN'}"`
) do (
    set "bitness=%%a"
)

echo Detected architecture: %bitness%
echo.

echo Copying Cold Client Loader files...
echo.

if not exist "%sourceDir%" (
    echo ERROR: Client folder not found at: %sourceDir%
    echo.
    echo Make sure the GBE Fork Cold Client files are in: %sourceDir%
    echo.
    pause
    exit /b 1
)

xcopy "%sourceDir%\*" "%droppedDir%" /s /e /y >nul
if errorlevel 1 (
    echo ERROR: Could not copy Cold Client files.
    pause
    exit /b 1
)

echo Selecting correct Cold Client loader...
echo.

set "clientDir=%sourceDir%"
set "loader32=steamclient_loader_x32.exe"
set "loader64=steamclient_loader_x64.exe"

if "%bitness%"=="32" (
    echo Game is 32 bit. Using steamclient_loader_x32.exe
    set "chosenLoader=%loader32%"
    set "discardLoader=%loader64%"
) else (
    echo Game is 64 bit or unknown. Using steamclient_loader_x64.exe
    set "chosenLoader=%loader64%"
    set "discardLoader=%loader32%"
)

copy /y "%clientDir%\%chosenLoader%" "%droppedDir%" >nul

if exist "%droppedDir%\%discardLoader%" del /f /q "%droppedDir%\%discardLoader%"

echo Loader in use: %chosenLoader%
echo.

PAUSE
CLS
echo.
echo ============================================
echo   Configure Cold Client Loader
echo ============================================
echo.
echo App ID: %appId%
echo Executable: %fileName%%extension%
echo.

set "args="
set /p args="Enter any launch arguments (leave blank for none): "
echo.

set "iniFile=%droppedDir%ColdClientLoader.ini"

echo Updating ColdClientLoader.ini...

(
echo [SteamClient]
echo # Relative or absolute path to the game's exe
echo exe=%fileName%%extension% 
echo.
echo # Optional: working directory for the exe (leave empty for exe's directory)
echo ExeRunDir=
echo.
echo # Optional: command line arguments
echo ExeCommandLine=%args%
echo.
echo # Steam AppID
echo AppId=%appId%
echo.
echo # path to the steamclient dlls, both must be set, absolute paths or relative to the loader directory
echo SteamClientDll=steamclient.dll
echo SteamClient64Dll=steamclient64.dll
echo.
echo [Injection]
echo # force inject steamclient dll instead of waiting for the app to load it
echo ForceInjectSteamClient=0
echo.
echo # force inject GameOverlayRenderer dll instead of waiting for the app to load it
echo ForceInjectGameOverlayRenderer=0
echo.
echo # path to a folder containing some dlls to inject into the app upon start, DllsToInjectFolder=extra_dlls
echo DllsToInjectFolder=
echo.
echo # don't display an error message when a dll injection fails
echo IgnoreInjectionError=1
echo.
echo # don't display an error message if the architecture of the loader is different from the app
echo IgnoreLoaderArchDifference=0
echo.
echo [Persistence]
echo # Persistence mode: 0=disabled, 1=loader spawns .exe, 2=loader does not spawn .exe
echo SteamClientRemainLoaded=0
echo.
echo [Debug]
echo # Enable debug logging (0=disabled, 1=enabled)
echo ResumeByDebugger=0
) > "%iniFile%"

echo ColdClientLoader.ini updated!
echo.
echo Configuration:
echo   exe=%fileName%%extension%
if "%args%"=="" (
    echo   ExeCommandLine=(none)
) else (
    echo   ExeCommandLine=%args%
)
echo   AppId=%appId%
echo.

pause
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

"%batchDir%ARMGDDN.Steam.Settings.exe" %appId%

echo.
echo ============================================
echo   Cold Client Setup Complete
echo ============================================
echo.
echo To launch the game, run:
echo   %chosenLoader%
echo.
pause
exit /b 0