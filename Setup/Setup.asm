org 0x7c00
bits 16

; bootloader start
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

; Set VGA graphics mode 13h (320x200 256 color)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

; Halt CPU infinite loop
halt_loop:
    hlt
    jmp halt_loop

times 510 - ($ - $$) db 0
dw 0xAA55
