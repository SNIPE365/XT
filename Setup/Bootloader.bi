
#ifndef __NoCompile__
#error "Do not compile bootloader.bi directly. Include it from bootloader.bas only."
#endif

Sub WriteBootloaderHeader(f As Integer)
    Print #f, "org 0x7c00"
    Print #f, "bits 16"
    Print #f, ""
    Print #f, "; bootloader start"
    Print #f, "start:"
    Print #f, "    cli"                 ' disable interrupts
    Print #f, "    xor ax, ax"
    Print #f, "    mov ds, ax"
    Print #f, "    mov es, ax"
    Print #f, "    mov ss, ax"
    Print #f, "    mov sp, 0x7c00"       ' set stack pointer
    Print #f, "    sti"                 ' enable interrupts
    Print #f, ""
End Sub

Sub WriteGraphicsMode(f As Integer)
    Print #f, "; Set VGA graphics mode 13h (320x200 256 color)"
    Print #f, "    mov ah, 0x00"
    Print #f, "    mov al, 0x13"
    Print #f, "    int 0x10"
    _ ' Set video memory segment
    Print #f, "    push 0xA000"
    Print #f, "    pop es"
    Print #f, ""
End Sub

Sub WriteTextMode(f As Integer)
    Print #f, "; Set VGA text mode 3 (80x25 color)"
    Print #f, "    mov ah, 0x00"
    Print #f, "    mov al, 0x03"
    Print #f, "    int 0x10"
    Print #f, ""
End Sub

Sub WriteHaltLoop(f As Integer)
    Print #f, "; Halt CPU infinite loop"
    Print #f, "halt_loop:"
    Print #f, "    hlt"
    Print #f, "    jmp halt_loop"
    Print #f, ""
End Sub

Sub WriteBootloaderFooter(f As Integer)
    Print #f, "times 510 - ($ - $$) db 0"
    Print #f, "dw 0xAA55"
    Print #f, "times (512*18*80*2-512) db 0x0"
End Sub
