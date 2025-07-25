@echo off

nasm -f bin "%USERPROFILE%\Desktop\Setup\genimg.asm" -o "%USERPROFILE%\Desktop\Setup\boot.img"
if errorlevel 1 goto :error
start /w mkisofs\mkisofs -b boot.img -o boot.iso boot.img
goto :eof

:error
pause
