@echo off
tasklist /FI "IMAGENAME eq FMXStarterKit.exe" | findstr /I "FMXStarterKit.exe" >nul
if %ERRORLEVEL% equ 0 (
    taskkill /F /IM FMXStarterKit.exe
)

call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"

cd /d D:\Github\FMXDesignTemplateAndroid

echo Compiling FMXStarterKit.dproj...
echo.

msbuild FMXStarterKit.dproj /t:Make /p:Config=Debug /p:Platform=Win32 /nologo /v:minimal

echo.
if errorlevel 1 (
    echo COMPILE FAILED
) else (
    echo COMPILE SUCCESS
)

pause