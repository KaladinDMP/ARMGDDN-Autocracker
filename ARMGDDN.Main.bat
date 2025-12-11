@echo off
echo.
echo ============================================
echo   ARMGDDN Autocracker - GBE FORK
echo ============================================
echo.
echo Processing file: "%~1"
echo.

set "droppedFile=%~1"
set "droppedDir=%~dp1"
set "fileName=%~n1"
set "fileExt=%~x1"
set "userChoice=%~2"
if "%droppedFile%"=="" (
    echo No file was dropped onto the script.    
	echo.
    echo Please drag and drop an EXE or DLL file onto the script to process it
    echo OR use the context menu options.
	echo.
    pause
    exit /b
)
echo Searching for steam_appid.txt...
set "appIdFile="
for /r "%droppedDir%" %%f in (steam_appid.txt) do (
    if exist "%%f" (
        set "appIdFile=%%f"
        for /f "usebackq delims=" %%i in ("%%f") do set "appId=%%i"
        set "appId=%appId: =%"
		echo Found: %%f
        echo Moving steam_appid.txt to "%droppedDir%"...
        move "%%f" "%droppedDir%" >nul 2>&1
    )
)

if /i "%fileExt%"==".exe" (
    echo Entering EXE processing block...
    goto exe_menu
) else if /i "%fileExt%"==".dll" (
    if /i not "%fileName%%fileExt%"=="steam_api64.dll" if /i not "%fileName%%fileExt%"=="steam_api.dll" (
        CLS
        echo WARNING: The DLL file must be either steam_api64 or steam_api.
		echo.
        echo Dropped file: %fileName%%fileExt%
        echo.
        echo NOW EXITING...
        echo.
        pause
        exit /b 1
    )
    echo File type: Steam API DLL
    echo.
    echo Running ARMGDDN.Autocracker.exe...
    call "%~dp0Resources\ARMGDDN.Autocracker.exe" "%droppedFile%"
) else (
    echo Unsupported file type. Please drop an EXE or DLL file. 
    echo.
    pause
    exit /b
)
goto end
:exe_menu
PAUSE
CLS

REM Use separate goto instead of if-else blocks
if "%userChoice%"=="1" goto do_stub
if "%userChoice%"=="2" goto do_vdbat  
if "%userChoice%"=="3" goto do_coldclient
goto show_menu

:do_stub
echo Running ARMGDDN.Stub.Remover.exe...
call "%~dp0Resources\ARMGDDN.Stub.Remover.exe" "%droppedFile%"
goto end

:do_vdbat
echo Running ARMGDDN.VD.Batmaker.exe...
call "%~dp0Resources\ARMGDDN.VD.Batmaker.exe" "%droppedFile%"
if exist "%~dp0VD.bat" (
    move "%~dp0VD.bat" "%droppedDir%"
)
goto end

:do_coldclient
echo Running ARMGDDN.Cold.Client.exe (GBE FORK)...
call "%~dp0Resources\ARMGDDN.Cold.Client.exe" "%droppedFile%"
goto end

:show_menu
CLS
echo.
echo ============================================
echo   ARMGDDN Autocracker - GBE FORK
echo ============================================
echo.
echo Executable: %fileName%%fileExt%
echo Directory: %droppedDir%
echo.
echo ============================================
echo   Select an option:
echo ============================================
echo.
echo 1. Check for and remove Steam Stub
echo.
echo 2. VD bat for Virtual Desktop owners - VR ONLY
echo.
echo 3. Cold Client Loader Setup (GBE FORK)
echo.
echo 4. Quit
echo.
set /p choice="Enter your choice (1-4): "
CLS
if "%choice%"=="1" goto do_stub_menu
if "%choice%"=="2" goto do_vdbat_menu
if "%choice%"=="3" goto do_coldclient_menu
if "%choice%"=="4" goto end
echo Invalid choice. Please try again.
pause
goto show_menu

:do_stub_menu
echo Running ARMGDDN.Stub.Remover.exe...
call "%~dp0Resources\ARMGDDN.Stub.Remover.exe" "%droppedFile%"
pause
goto show_menu

:do_vdbat_menu
echo Running ARMGDDN.VD.Batmaker.exe...
call "%~dp0Resources\ARMGDDN.VD.Batmaker.exe" "%droppedFile%"
if exist "%~dp0VD.bat" (
    move "%~dp0VD.bat" "%droppedDir%"
)
pause
goto show_menu

:do_coldclient_menu
echo Running ARMGDDN.Cold.Client.exe (GBE FORK)...
call "%~dp0Resources\ARMGDDN.Cold.Client.exe" "%droppedFile%" "%appId%"
pause
goto show_menu

pause
:end
