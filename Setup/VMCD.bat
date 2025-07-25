@echo off
setlocal

set SETUP_DIR=%USERPROFILE%\Desktop\Setup
set VM_NAME=hello_testcd
set FLOPPY_CTL=IDE Controller
set FLOPPY_IMG=%SETUP_DIR%\boot.iso
set VBOX_PATH=C:\Program Files\Oracle\VirtualBox

:: Run assembly-to-image batch file
cd "%SETUP_DIR%"

:: Check if VM exists
"%VBOX_PATH%\VBoxManage" list vms | findstr /i "\"%VM_NAME%\"" >nul
if errorlevel 1 (
    echo VM "%VM_NAME%" not found. Creating...
    "%VBOX_PATH%\VBoxManage" createvm --name "%VM_NAME%" --register
    "%VBOX_PATH%\VBoxManage" modifyvm "%VM_NAME%" ^
        --memory 16 ^
        --floppy off ^
        --boot1 cdrom ^
        --boot2 none ^
        --boot3 none ^
        --boot4 none ^
        --audio none ^
        --usb off ^
        --usbehci off ^
        --usbxhci off ^
        --nic1 none ^
        --nictype1 82540EM ^
        --uart1 off ^
        --uart2 off ^
        --clipboard disabled ^
        --draganddrop disabled ^
        --bioslogofadein off ^
        --bioslogofadeout off ^
        --bioslogoimagepath=none ^
        --biosbootmenu disabled ^
        --sata off ^
        --ide on ^
        --ioapic on ^

        --rtcuseutc on
) else (
    echo VM "%VM_NAME%" already exists.
)

:: Check if cd controller exists
"%VBOX_PATH%\VBoxManage" showvminfo "%VM_NAME%" --machinereadable | findstr /i "storagecontrollername.*%FLOPPY_CTL%" >nul
if errorlevel 1 (
    echo Adding floppy controller...
    "%VBOX_PATH%\VBoxManage" storagectl "%VM_NAME%" --name "%FLOPPY_CTL%" --add ide --controller PIIX4
) else (
    echo dvd controller already exists, skipping add.
)

:: Check if cd image is attached
"%VBOX_PATH%\VBoxManage" showvminfo "%VM_NAME%" --machinereadable | findstr /i /c:"%FLOPPY_CTL%-0-0" | findstr /i /c:"%FLOPPY_IMG%" >nul
if errorlevel 1 (
    echo Attaching cd image...
    "%VBOX_PATH%\VBoxManage" storageattach "%VM_NAME%" --storagectl "%FLOPPY_CTL%" --port 1 --device 0 --type dvddrive --medium "%FLOPPY_IMG%"
) else (
    echo cd image already attached, skipping attach.
)

:: Boot the VM
echo Starting VM "%VM_NAME%"...
"%VBOX_PATH%\VBoxManage" startvm "%VM_NAME%" --type gui

pause
endlocal
