@echo off

set FBC_DIR=%USERPROFILE%\Desktop\FreeBASIC-1.10.0-winlibs-gcc-9.3.0
set SETUP_DIR=%USERPROFILE%\Desktop\Setup

cd /d %SETUP_DIR%
"%FBC_DIR%\FBC32.exe" "genimg.bas" -x "genimg.exe" -s console
if errorlevel 1 goto :error

"genimg.exe"
call asm2img.bat

echo.
set /p RUNVM=Do you want to run VM.bat? (Y/N): 
if /i "%RUNVM:~0,1%"=="Y" call "%SETUP_DIR%\VMCD.bat"
goto :eof

:error
pause
