@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=
REM BFCPEICON=
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=0
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=Product Name
REM BFCPEVERDESC=Product Description
REM BFCPEVERCOMPANY=Your Company
REM BFCPEVERCOPYRIGHT=Copyright Info
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=30
REM BFCPEWINDOWWIDTH=120
REM BFCPEWTITLE=Window Title
REM BFCPEOPTIONEND
@echo off
setlocal EnableDelayedExpansion

:: -------------------------------------------------------
::  MASTER DIR IS ONE LEVEL ABOVE WHERE THIS SCRIPT LIVES
::  So script can live in:
::    ...\ARMGDDN.Autocracker.OG-GSE\
::    ...\ARMGDDN.Autocracker.GBE-Fork\
::  But masterDir will be:
::    ...\ARMGDDN.Autocracker\
:: -------------------------------------------------------
set "scriptDir=%~dp0"
set "masterDir=%scriptDir%.."

:: Normalize masterDir to full path, no trailing slash
for %%A in ("%masterDir%") do set "masterDir=%%~fA"

:: Version dirs (no extra backslashes)
set "ogDir=%masterDir%\ARMGDDN.Autocracker.OG-GSE"
set "gbeDir=%masterDir%\ARMGDDN.Autocracker.GBE-Fork"

echo Master dir: %masterDir%
echo OG dir:     %ogDir%
echo GBE dir:    %gbeDir%
echo.

:: -------------------------------------------------------
::  FIND NIRCMD
:: -------------------------------------------------------
set "nircmdPath="

for %%P in ("%ogDir%\Resources\Tools\nircmd.exe" "%gbeDir%\Resources\Tools\nircmd.exe") do (
    if exist "%%~P" (
        set "nircmdPath=%%~P"
        goto :found_nircmd
    )
)

echo ERROR: nircmd.exe not found.
echo Expected in either:
echo   %ogDir%\Resources\Tools\
echo   %gbeDir%\Resources\Tools\
pause
exit /b

:found_nircmd
echo Found nircmd: %nircmdPath%
echo.

:: -------------------------------------------------------
::  TALKY INTRO + ADMIN CHECK
:: -------------------------------------------------------
"%nircmdPath%" infobox "This Script TALKS." "Warning!"
"%nircmdPath%" infobox "LOUDLY..." "Warning!"
"%nircmdPath%" infobox "Turn down your volume NOW..." "Warning!"
"%nircmdPath%" infobox "Ok I'm waiting..." "Warning!"

cls

"%nircmdPath%" speak text "This script needs admin to run."
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Please run this script as administrator.
    pause
    exit /b
)

"%nircmdPath%" speak text "Installing Armageddon Autocracker context menus."
echo.

:: -------------------------------------------------------
::  DETECT OG / GBE AND SET PATHS
:: -------------------------------------------------------
set "haveOG="
set "haveGBE="

:: OG
if exist "%ogDir%\ARMGDDN.Main.exe" (
    set "haveOG=1"
    set "ogMain=%ogDir%\ARMGDDN.Main.exe"
    set "ogIcon=%ogDir%\ARMGDDN.Main.exe,0"
    set "ogCold=%ogDir%\Resources\ARMGDDN.Cold.Client.exe,0"
    set "ogStub=%ogDir%\Resources\SteamlessCLI\Steamless.CLI.exe,0"
    set "ogVDBat=%ogDir%\Resources\ARMGDDN.VD.Batmaker.exe,0"
    set "ogSI=%ogDir%\Resources\Tools\generate_interfaces_file.exe"
)

:: GBE
if exist "%gbeDir%\ARMGDDN.Main.exe" (
    set "haveGBE=1"
    set "gbeMain=%gbeDir%\ARMGDDN.Main.exe"
    set "gbeIcon=%gbeDir%\ARMGDDN.Main.exe,0"
    set "gbeCold=%gbeDir%\Resources\ARMGDDN.Cold.Client.exe,0"
    set "gbeStub=%gbeDir%\Resources\SteamlessCLI\Steamless.CLI.exe,0"
    set "gbeVDBat=%gbeDir%\Resources\ARMGDDN.VD.Batmaker.exe,0"
    set "gbeSI=%gbeDir%\Resources\Tools\generate_interfaces_file.exe"
)

if not defined haveOG if not defined haveGBE (
    echo ERROR: Neither OG nor GBE detected.
    echo Expected:
    echo   %ogDir%\ARMGDDN.Main.exe
    echo   %gbeDir%\ARMGDDN.Main.exe
    pause
    exit /b
)

echo Detected:
if defined haveOG  echo   - OG GSE
if defined haveGBE echo   - GBE Fork
echo.

:: -------------------------------------------------------
::  FIND AAC AUTOCRACKER ICON (MAIN PARENT ICON)
:: -------------------------------------------------------
set "aacIcon="

for %%P in ("%ogDir%\Resources\Tools\AAC_Autocracker.ico" "%gbeDir%\Resources\Tools\AAC_Autocracker.ico") do (
    if exist "%%~P" (
        set "aacIcon=%%~P"
        goto :found_aac
    )
)

echo ERROR: AAC_Autocracker.ico missing.
echo Expected in either:
echo   %ogDir%\Resources\Tools\AAC_Autocracker.ico
echo   %gbeDir%\Resources\Tools\AAC_Autocracker.ico
pause
exit /b

:found_aac
echo Using AAC Autocracker icon:
echo   %aacIcon%
echo.

:: -------------------------------------------------------
::  CREATE PARENT MENUS FOR EXE / DLL / DIRECTORY
:: -------------------------------------------------------
for %%T in (exefile dllfile) do (
    reg add "HKCR\%%T\shell\ARMGDDNAutocracker" /v "MUIVerb" /t REG_SZ /d "ARMGDDN Autocracker" /f
    reg add "HKCR\%%T\shell\ARMGDDNAutocracker" /v "Icon"   /t REG_SZ /d "%aacIcon%" /f
    reg add "HKCR\%%T\shell\ARMGDDNAutocracker" /v "SubCommands" /t REG_SZ /d "" /f
)

:: -------------------------------------------------------
::  AAC FOLDER EXCLUDE - TOP LEVEL DIRECTORY MENU
:: -------------------------------------------------------
set "excludeExe="

:: Find ExclusionHelper from either version
for %%P in ("%gbeDir%\Resources\Tools\ExclusionHelper.exe" "%ogDir%\Resources\Tools\ExclusionHelper.exe") do (
    if exist "%%~P" (
        set "excludeExe=%%~P"
        goto :found_exclude
    )
)
goto :skip_exclude

:found_exclude
echo Adding Defender Exclusion context menu...
reg add "HKCR\Directory\shell\AACFolderExclude" /v "MUIVerb" /t REG_SZ /d "AAC Folder Exclude" /f
reg add "HKCR\Directory\shell\AACFolderExclude" /v "Icon" /t REG_SZ /d "%excludeExe%,0" /f
reg add "HKCR\Directory\shell\AACFolderExclude\command" /ve /d "\"%excludeExe%\" \"%%1\"" /f
"%nircmdPath%" speak text "Added Defender folder exclusion context menu."

:skip_exclude

:: -------------------------------------------------------
::  GBE FORK SUBMENUS (01_GBE)
:: -------------------------------------------------------
if defined haveGBE (
    :: EXE
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "MUIVerb" /d "GBE Fork" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "Icon"   /d "%gbeIcon%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "SubCommands" /d "" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker" /v "MUIVerb" /d "Autocracker" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker" /v "Icon"   /d "%gbeIcon%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker\command" /ve /d "\"%gbeMain%\" \"%%1\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_ColdClient" /v "MUIVerb" /d "Cold Client" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_ColdClient" /v "Icon"   /d "%gbeCold%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_ColdClient\command" /ve /d "\"%gbeMain%\" \"%%1\" \"3\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\03_SteamStub" /v "MUIVerb" /d "Steam Stub Remover" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\03_SteamStub" /v "Icon"   /d "%gbeStub%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\03_SteamStub\command" /ve /d "\"%gbeMain%\" \"%%1\" \"1\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\04_VDBat" /v "MUIVerb" /d "VD Batmaker (VR)" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\04_VDBat" /v "Icon"   /d "%gbeVDBat%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\04_VDBat\command" /ve /d "\"%gbeMain%\" \"%%1\" \"2\"" /f

    :: DLL
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "MUIVerb" /d "GBE Fork" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "Icon"   /d "%gbeIcon%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE" /v "SubCommands" /d "" /f

    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker" /v "MUIVerb" /d "Autocracker" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker" /v "Icon"   /d "%gbeIcon%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\01_Autocracker\command" /ve /d "\"%gbeMain%\" \"%%1\"" /f

    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_SteamInterfaces" /v "MUIVerb" /d "Steam Interfaces" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_SteamInterfaces" /v "Icon"   /d "%gbeCold%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\01_GBE\shell\02_SteamInterfaces\command" /ve /d "\"%gbeSI%\" \"%%1\"" /f
	)
	"%nircmdPath%" speak text "Added Goldberg Steam Emu Fork submenu for executable, DLL, and folder context menus."
)


:: -------------------------------------------------------
::  OG GSE SUBMENUS (02_OG)
:: -------------------------------------------------------
if defined haveOG (
    :: EXE
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG" /v "MUIVerb" /d "OG GSE" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG" /v "Icon"   /d "%ogIcon%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG" /v "SubCommands" /d "" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker" /v "MUIVerb" /d "Autocracker" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker" /v "Icon"   /d "%ogIcon%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker\command" /ve /d "\"%ogMain%\" \"%%1\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_ColdClient" /v "MUIVerb" /d "Cold Client" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_ColdClient" /v "Icon"   /d "%ogCold%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_ColdClient\command" /ve /d "\"%ogMain%\" \"%%1\" \"3\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\03_SteamStub" /v "MUIVerb" /d "Steam Stub Remover" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\03_SteamStub" /v "Icon"   /d "%ogStub%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\03_SteamStub\command" /ve /d "\"%ogMain%\" \"%%1\" \"1\"" /f

    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\04_VDBat" /v "MUIVerb" /d "VD Batmaker (VR)" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\04_VDBat" /v "Icon"   /d "%ogVDBat%" /f
    reg add "HKCR\exefile\shell\ARMGDDNAutocracker\shell\02_OG\shell\04_VDBat\command" /ve /d "\"%ogMain%\" \"%%1\" \"2\"" /f

    :: DLL
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG" /v "MUIVerb" /d "OG GSE" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG" /v "Icon"   /d "%ogIcon%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG" /v "SubCommands" /d "" /f

    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker" /v "MUIVerb" /d "Autocracker" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker" /v "Icon"   /d "%ogIcon%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\01_Autocracker\command" /ve /d "\"%ogMain%\" \"%%1\"" /f

    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_SteamInterfaces" /v "MUIVerb" /d "Steam Interfaces" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_SteamInterfaces" /v "Icon"   /d "%ogCold%" /f
    reg add "HKCR\dllfile\shell\ARMGDDNAutocracker\shell\02_OG\shell\02_SteamInterfaces\command" /ve /d "\"%ogSI%\" \"%%1\"" /f
    )
    "%nircmdPath%" speak text "Added O.G. Goldberg Steam Emu submenu for executable, DLL, and folder context menus."
)

echo.
echo ============================================
echo   Context Menu Installation Complete!
echo ============================================
echo.
echo   ARMGDDN Autocracker
echo     +-- GBE Fork  (if present)
echo     +-- OG GSE    (if present)
echo.
echo   AAC Folder Exclude (standalone)
echo.
"%nircmdPath%" speak text "All context menu options added successfully. Enjoy."
pause

endlocal
exit /b