#include "windows.bi"

function GrabWindow() as hwnd
  dim as zstring*64 zTitle
  dim as hwnd hOldWnd
  dim as long iShift
  do
    var hNewWnd = GetForegroundWindow()
    if hNewWnd <> hOldWnd then
      hOldWnd = hNewWnd
      if GetWindowText(hNewWnd,@zTitle,64)=0 then
        GetClassName(hNewWnd,@zTitle,64)
      end if
      var sTemp = "'"+zTitle+"'"+space(64)
      print left(sTemp,66);!"\r";
    end if
    if (GetAsyncKeyState( VK_LSHIFT ) shr 7) then
      if iShift=0 then iShift=1
    else
      if iShift=1 then iShift=0 : exit do
    end if
    SleepEx(1,1)
  loop
  print 
  return hOldWnd
end function

print "activate the 'left' window and then press-release lshift"
var hWndLeft = GrabWindow()
print "activate the 'right' window and then press-release lshift"
var hWndRight = GrabWindow()
print "Close this console to unlink"

dim as RECT tRcLeft = type(-1,-1,-1,-1)

do
  dim as RECT tRc = any : GetWindowRect( hWndLeft , @tRc )
  if *cptr(ulongint ptr,@tRcLeft) <> *cptr(ulongint ptr,@tRc) then
    tRcLeft = tRc
    SetWindowPos( hWndRight , HWND_TOP	 , tRcLeft.right , tRcLeft.top , 0,0 , SWP_NOSIZE )
  end if
  SleepEx(1,1)
loop
