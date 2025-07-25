
#define __NoCompile__
#include "Bootloader.bi"
Dim f As Integer = FreeFile()

Open "genimg.asm" For Output As #f

WriteBootloaderHeader(f)

' You can choose to write graphics or text mode setup here:
WriteGraphicsMode(f)
' WriteTextMode(f)  ' Uncomment this line instead if you want text mode

WriteHaltLoop(f)
WriteBootloaderFooter(f)

Close #f

Print "genimg.asm file written."
