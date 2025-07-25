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
    push 0xA000
    pop es

; Draw filled rectangle (or full screen) in mode 13h
    pusha
    mov al, 3
    mov di, 0
    mov dx, 200
.draw_y_loop1:
    mov cx, 320
    rep stosb
    add di, 0
    dec dx
    jnz .draw_y_loop1
    popa


; Draw filled rectangle (or full screen) in mode 13h
    pusha
    mov al, 1
    mov di, 10272
    mov dx, 136
.draw_y_loop2:
    mov cx, 256
    rep stosb
    add di, 64
    dec dx
    jnz .draw_y_loop2
    popa


; Halt CPU infinite loop
halt_loop:
    hlt
    jmp halt_loop

times 510 - ($ - $$) db 0
dw 0xAA55
times (512*18*80*2-512) db 0x0
