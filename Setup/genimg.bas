#define __NoCompile__
#include "Bootloader.bi"
#include "Graphics.bi"

Dim f As Integer
f = FreeFile()
Open "genimg.asm" For Output As #f

WriteBootloaderHeader(f)
WriteGraphicsMode(f)
DrawBackground(f, 3, 0, 0, 319, 199)
DrawBackground(f, 1, 32, 32, 319-32, 199-32)
WriteHaltLoop(f)
WriteBootloaderFooter(f)

print "Assembly code successfully generated"

Close #f