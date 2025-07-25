#ifndef __NoCompile__
#error "Do not compile Graphics.bi directly. Include it from Setup.bas only."
#endif

#if 1
Sub DrawBackground(f As Integer, Bgcolor As Integer, x1 As Integer = 0, y1 As Integer = 0, x2 As Integer = 319, y2 As Integer = 199)

    static as long iN : iN += 1

    #define crlf !"\n"
    Print #f, _
    "; Draw filled rectangle (or full screen) in mode 13h"  crlf _
    "    pusha" crlf _    
    _ ' Set color
    "    mov al, " & BgColor & crlf _
    "    mov di, " & y1*320+x1 & crlf _
    "    mov dx, " & ((y2-y1)+1) & crlf _
    _ ' Outer loop (y)
    ".draw_y_loop" & iN & ":" crlf _
    "    mov cx, " & (x2-x1)+1 & crlf _
    "    rep stosb"  crlf _
    "    add di, " & (320-((x2-x1)+1)) & crlf _
    "    dec dx" crlf _
    "    jnz .draw_y_loop" & iN & crlf _
    _ ' end draw
    "    popa" crlf crlf    
    
End Sub
#else
Sub DrawBackground(f As Integer, Bgcolor As Integer, x1 As Integer = 0, y1 As Integer = 0, x2 As Integer = 319, y2 As Integer = 199)

    Print #f, "; Draw filled rectangle (or full screen) in mode 13h"
    Print #f, "    push ax"
    Print #f, "    push bx"
    Print #f, "    push cx"
    Print #f, "    push dx"
    Print #f, "    push si"
    Print #f, "    push di"

    ' Set video memory segment
    Print #f, "    mov ax, 0xA000"
    Print #f, "    mov es, ax"

    ' Set color
    Print #f, "    mov al, " & Bgcolor
    Print #f, "    mov ah, 0"

    ' Outer loop (y)
    Print #f, "    mov cx, " & y1
    Print #f, ".draw_y_loop:"
    Print #f, "    cmp cx, " & (y2 + 1)
    Print #f, "    jge .end_draw"

    ' Inner loop (x)
    Print #f, "    mov dx, " & x1
    Print #f, ".draw_x_loop:"
    Print #f, "    cmp dx, " & (x2 + 1)
    Print #f, "    jge .next_y"

    ' Calculate offset = cx*320 + dx
    Print #f, "    mov si, cx"
    Print #f, "    mov di, 320"
    Print #f, "    mul di"                ' ax = cx * 320
    Print #f, "    add ax, dx"           ' ax = offset
    Print #f, "    mov di, ax"

    ' Write pixel
    Print #f, "    stosb"

    ' Next x
    Print #f, "    inc dx"
    Print #f, "    jmp .draw_x_loop"

    ' Next y
    Print #f, ".next_y:"
    Print #f, "    inc cx"
    Print #f, "    jmp .draw_y_loop"

    Print #f, ".end_draw:"
    Print #f, "    pop di"
    Print #f, "    pop si"
    Print #f, "    pop dx"
    Print #f, "    pop cx"
    Print #f, "    pop bx"
    Print #f, "    pop ax"
    Print #f, ""
End Sub
#endif
