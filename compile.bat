@echo off
tasklist /FI "IMAGENAME eq prjTemplateV4.exe" | findstr /I "prjTemplateV4.exe" >nul
if %ERRORLEVEL% equ 0 (
    taskkill /F /IM prjTemplateV4.exe
)

call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"

cd /d D:\Github\FMXDesignTemplateAndroid\Template v4 (Delphi 12.2)

echo Compiling prjTemplateV4.dproj...
echo.

msbuild prjTemplateV4.dproj /t:Make /p:Config=Debug /p:Platform=Win32 /nologo /v:minimal

echo.
if errorlevel 1 (
    echo COMPILE FAILED
) else (
    echo COMPILE SUCCESS
)

pause