@echo off
setlocal EnableDelayedExpansion

echo.
echo ============================================
echo   ARMGDDN Autocracker - Registry Cleanup
echo   Removes ALL context menu entries (OG + GBE)
echo ============================================
echo.

:: -------------------------------------------------------
::  ADMIN CHECK
:: -------------------------------------------------------
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ERROR: This script requires administrator privileges.
    echo Right-click and select "Run as administrator".
    pause
    exit /b
)

echo Running with administrative privileges.
echo.
echo This will remove *all* ARMGDDN Autocracker context menu entries.
echo.
pause

echo.
echo ============================================
echo   Removing NEW nested menu structure...
echo ============================================
echo.

:: -------------------------------------------------------
::  REMOVE NEW MASTER STRUCTURE (EXE / DLL / DIRECTORY)
:: -------------------------------------------------------
for %%K in (
    "HKEY_CLASSES_ROOT\exefile\shell\ARMGDDNAutocracker"
    "HKEY_CLASSES_ROOT\dllfile\shell\ARMGDDNAutocracker"
    "HKEY_CLASSES_ROOT\Directory\shell\ARMGDDNAutocracker"
    "HKCR\exefile\shell\ARMGDDNAutocracker"
    "HKCR\dllfile\shell\ARMGDDNAutocracker"
    "HKCR\Directory\shell\ARMGDDNAutocracker"
) do (
    echo Removing: %%K
    reg delete "%%~K" /f >nul 2>&1
)

echo.
echo ============================================
echo   Removing OG / GBE subkeys individually...
echo ============================================
echo.

:: -------------------------------------------------------
::  Remove nested OG + GBE menus in case parent remained
:: -------------------------------------------------------
for %%V in (
    "01_GBE"
    "02_OG"
    "01_OG"
    "02_GBE"
    "GBE Fork"
    "OG GSE"
) do (
    for %%T in (exefile dllfile Directory) do (
        reg delete "HKCR\%%T\shell\ARMGDDNAutocracker\shell\%%~V" /f >nul 2>&1
        reg delete "HKEY_CLASSES_ROOT\%%T\shell\ARMGDDNAutocracker\shell\%%~V" /f >nul 2>&1
    )
)

echo.
echo ============================================
echo   Removing Folder Exclusion entries...
echo ============================================
echo.

for %%T in (exefile dllfile Directory) do (
    reg delete "HKCR\%%T\shell\ARMGDDNAutocracker\shell\01_GBE\shell\05_DefenderExclude" /f >nul 2>&1
    reg delete "HKCR\%%T\shell\ARMGDDNAutocracker\shell\02_OG\shell\05_DefenderExclude" /f >nul 2>&1
)

echo.
echo ============================================
echo   Removing AAC Folder Exclude...
echo ============================================
echo.

reg delete "HKCR\Directory\shell\AACFolderExclude" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\AACFolderExclude" /f >nul 2>&1
echo Removed: AACFolderExclude

:: -------------------------------------------------------
::  REMOVE LEGACY FLAT STRUCTURE
:: -------------------------------------------------------
echo.
echo ============================================
echo   Removing OLD flat menu entries (v1.x - v2.x)
echo ============================================
echo.

for %%K in (
    "AutoCracker"
    "ColdClient"
    "Remove Steam Stub"
    "VD bat"
    "ARMGDDN Autocracker"
    "ARMGDDN Cold Client"
    "ARMGDDN Steam Stub Remover"
    "ARMGDDN VD Batmaker"
    "SteamInterfaces"
    "Steam Interfaces"
) do (
    for %%T in (exefile dllfile Directory) do (
        reg delete "HKCR\%%T\shell\%%~K" /f >nul 2>&1
        reg delete "HKEY_CLASSES_ROOT\%%T\shell\%%~K" /f >nul 2>&1
    )
)

echo.
echo ============================================
echo   Removing ALL name variants ever used...
echo ============================================
echo.

for %%K in (
    "ARMGDDNAutocracker"
    "ARMGDDN_Autocracker"
    "ARMGDDN-Autocracker"
    "Autocracker"
) do (
    for %%T in (exefile dllfile Directory) do (
        reg delete "HKCR\%%T\shell\%%~K" /f >nul 2>&1
        reg delete "HKEY_CLASSES_ROOT\%%T\shell\%%~K" /f >nul 2>&1
    )
)

echo.
echo ============================================
echo   VERIFICATION
echo ============================================
echo.

set "stillExists=0"

for %%T in (exefile dllfile Directory) do (
    reg query "HKCR\%%T\shell\ARMGDDNAutocracker" >nul 2>&1 && set "stillExists=1"
)

if "%stillExists%"=="0" (
    echo All ARMGDDN context menu entries removed successfully!
) else (
    echo.
    echo WARNING: Some entries remain.
    echo You may need to delete them manually in regedit:
    echo     HKCR\exefile\shell\
    echo     HKCR\dllfile\shell\
    echo     HKCR\Directory\shell\
)

echo.
echo Cleanup Complete!
echo Restart Explorer or log out/in for menu changes to update.
echo.

pause
endlocal
exit /b
