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
    set "loaderName=%fileName%CCLx32.exe"
) else (
    echo Game is 64 bit or unknown. Using steamclient_loader_x64.exe
    set "chosenLoader=%loader64%"
    set "discardLoader=%loader32%"
    set "loaderName=%fileName%CCLx64.exe"
)

REM Copy and rename the loader
copy /y "%clientDir%\%chosenLoader%" "%droppedDir%!loaderName!" >nul

REM Delete both original loaders from game dir (we renamed it)
if exist "%droppedDir%\%loader32%" del /f /q "%droppedDir%\%loader32%"
if exist "%droppedDir%\%loader64%" del /f /q "%droppedDir%\%loader64%"

echo Loader renamed to: !loaderName!
echo.

REM Extract icon from game EXE and apply to loader
echo Extracting icon from game executable...
set "ffmpeg=%batchDir%Tools\ffmpeg.exe"
set "rcedit=%batchDir%Tools\rcedit-x64.exe"
set "tempPng=%TEMP%\aac_temp_icon.png"
set "tempIco=%TEMP%\aac_temp_icon.ico"

if exist "%ffmpeg%" if exist "%rcedit%" (
    REM Extract icon to PNG using PowerShell
    powershell -Command "Add-Type -AssemblyName System.Drawing; $icon = [System.Drawing.Icon]::ExtractAssociatedIcon('%droppedFile%'); $icon.ToBitmap().Save('%tempPng%')"
    
    if exist "!tempPng!" (
        REM Convert PNG to ICO using ffmpeg
        "%ffmpeg%" -y -i "!tempPng!" "!tempIco!" >nul 2>&1
        
        if exist "!tempIco!" (
            REM Apply icon to loader using rcedit
            "%rcedit%" "%droppedDir%!loaderName!" --set-icon "!tempIco!" >nul 2>&1
            if not errorlevel 1 (
                echo Icon applied successfully!
            ) else (
                echo Warning: Could not apply icon, continuing anyway...
            )
            del "!tempIco!" >nul 2>&1
        ) else (
            echo Warning: Could not convert icon, continuing anyway...
        )
        del "!tempPng!" >nul 2>&1
    ) else (
        echo Warning: Could not extract icon, continuing anyway...
    )
) else (
    echo Note: ffmpeg or rcedit not found in Tools folder, skipping icon extraction
)
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

REM Delete existing ini first
if exist "%iniFile%" del /f /q "%iniFile%"

REM Write line by line (handles spaces in path reliably)
echo [SteamClient]> "%iniFile%"
echo # Relative or absolute path to the game's exe>> "%iniFile%"
echo exe=%fileName%%extension%>> "%iniFile%"
echo # Optional: working directory for the exe (leave empty for exe's directory)>> "%iniFile%"
echo ExeRunDir=>> "%iniFile%"
echo # Optional: command line arguments>> "%iniFile%"
echo ExeCommandLine=%args%>> "%iniFile%"
echo # Steam AppID>> "%iniFile%"
echo AppId=%appId%>> "%iniFile%"
echo.>> "%iniFile%"
echo # path to the steamclient dlls, both must be set, absolute paths or relative to the loader directory>> "%iniFile%"
echo SteamClientDll=steamclient.dll>> "%iniFile%"
echo SteamClient64Dll=steamclient64.dll>> "%iniFile%"
echo.>> "%iniFile%"
echo [Injection]>> "%iniFile%"
echo # force inject steamclient dll instead of waiting for the app to load it>> "%iniFile%"
echo ForceInjectSteamClient=0 >> "%iniFile%"
echo.>> "%iniFile%"
echo # force inject GameOverlayRenderer dll instead of waiting for the app to load it>> "%iniFile%"
echo ForceInjectGameOverlayRenderer=0 >> "%iniFile%"
echo.>> "%iniFile%"
echo # path to a folder containing some dlls to inject into the app upon start, DllsToInjectFolder=extra_dlls>> "%iniFile%"
echo DllsToInjectFolder=>> "%iniFile%"
echo.>> "%iniFile%"
echo # don't display an error message when a dll injection fails>> "%iniFile%"
echo IgnoreInjectionError=1>> "%iniFile%"
echo.>> "%iniFile%"
echo # don't display an error message if the architecture of the loader is different from the app>> "%iniFile%"
echo IgnoreLoaderArchDifference=0 >> "%iniFile%"
echo.>> "%iniFile%"
echo [Persistence]>> "%iniFile%"
echo # Persistence mode: 0=disabled, 1=loader spawns .exe, 2=loader does not spawn .exe>> "%iniFile%"
echo SteamClientRemainLoaded=0 >> "%iniFile%"
echo.>> "%iniFile%"
echo [Debug]>> "%iniFile%"
echo # Enable debug logging (0=disabled, 1=enabled)>> "%iniFile%"
echo ResumeByDebugger=0 >> "%iniFile%"

REM Verify
if exist "%iniFile%" (
    echo.
    echo ColdClientLoader.ini created successfully!
    echo.
    echo Configuration:
    echo   exe=%fileName%%extension%
    if "%args%"=="" (
        echo   ExeCommandLine=^(none^)
    ) else (
        echo   ExeCommandLine=%args%
    )
    echo   AppId=%appId%
    echo.
) else (
    echo ERROR: Failed to create ColdClientLoader.ini
    echo Path: %iniFile%
    pause
    exit /b 1
)

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
echo Files created:
echo   - !loaderName! (with game icon)
echo   - ColdClientLoader.ini
echo   - steamclient.dll / steamclient64.dll
echo   - GameOverlayRenderer.dll / GameOverlayRenderer64.dll
echo   - steam_settings/ folder
echo.
echo To launch the game, run:
echo  !loaderName!
echo.
pause
exit /b 0