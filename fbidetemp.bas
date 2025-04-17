#cmdline "-s gui -dll"

#include "windows.bi"
#include "crt.bi"

static shared as hwnd hConsole
static shared as bool bMustFreeConsole
static shared as hwnd g_hRunDlg , g_hRunCombo
static shared as rect g_tDlgRect

static shared as any ptr pOrgDlgProc
function DlgProc( hwnd as HWND , uMsg as ULONG , wParam as WPARAM , lParam as LPARAM ) as LResult   
   if pOrgDlgProc=0 then return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   select case uMsg      
   case WM_SIZE,WM_SIZING
      if g_hRunDlg andalso g_hRunCombo then
         dim as rect tNewDlgRc , tComboRc , tTempRc
         GetClientRect( hwnd , @tNewDlgRc )
         GetWindowRect( g_hRunCombo , @tComboRc )
         dim as HWND hCTL
         var iYDiff = cint(tNewDlgRc.bottom)-cint(g_tDlgRect.bottom)
         do
            hCTL = FindWindowEx( g_hRunDlg , hCTL , NULL , NULL )
            if hCTL = 0 then exit do
            if hCTL = g_hRunCombo then continue do
            GetWindowRect( hCTL , @tTempRc )
            if tTempRc.top > tComboRc.top then
               ScreenToClient( hwnd , cast(POINT ptr,@tTempRc.left) )
               tTempRc.top += iYDiff
               SetWindowPos( hCtl , 0 , tTempRc.left,tTempRc.top , 0,0 , SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOZORDER )
            end if
         loop      
         g_tDlgRect = tNewDlgRc
      end if
      'return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   end select
   return CallWindowProc( pOrgDlgProc , hwnd , uMsg , wParam , lParam )
end function

function DllThread( hModule as any ptr ) as DWORD
   
   g_hRunDlg = FindWindow( "#32770" , "Run" )   
   if g_hRunDlg=0 then 
      Messagebox( null , "ERROR" , null , MB_ICONERROR )
      FreeLibraryAndExitThread( hModule , 0 )   
   end if   
   print "OK"    
   var hMenu = GetSystemMenu( g_hRunDlg , false )
   if GetMenuState( hMenu , SC_SIZE , MF_BYCOMMAND )=&hFFFFFFFF then
      puts("Adding 'size' menu back")
      InsertMenu( hMenu , 0 , MF_BYPOSITION , SC_SIZE , "Size" )
   end if
   
   pOrgDlgProc = cast(any ptr, SetWindowLongPtr( g_hRunDlg , GWLP_WNDPROC , cast(LONG_PTR,@dlgProc) ) )
   
   var lStyle = GetWindowLong( g_hRunDlg , GWL_STYLE )
   SetWindowLong( g_hRunDlg , GWL_STYLE , lStyle or WS_SIZEBOX ) 
   SetWindowPos( g_hRunDlg , 0,0,0,0,0 , SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED )
   
   dim as HWND hwnd
   do
      hWnd = FindWindowEx( g_hRunDlg , hWnd , NULL , NULL )
      if hWnd=0 then exit do
      ShowWindow( hWnd , SW_SHOWNA )
      EnableWindow( hWnd , true )
   loop
   
   GetClientRect( g_hRunDlg , @g_tDlgRect )
   g_hRunCombo = FindWindowEx( g_hRunDlg , 0 , "ComboBox" , NULL )
   var hEdit = FindWindowEx( g_hRunCombo , 0 , "edit" , NULL )
   lStyle = GetWindowLong( hEdit , GWL_STYLE )
   SetWindowLong( hEdit , GWL_STYLE , lStyle or WS_VSCROLL or ES_MULTILINE ) 
   SetWindowPos( hEdit , 0,0,0,0,0 , SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED )
   'SetWindowText( hEdit , "Hello World" )
      
   dim as RECT tRC , tOldRC
   dim as HWND hWndPnt
   
   while IsWindow( g_hRunDlg )
      dim as POINT tCurPT = any
      GetCursorPos( @tCurPT )
      var hWnd = WindowFromPoint( tCurPT )
      if hWnd <> hWndPnt then
         hWndPnt = hWnd
         dim as zstring*256 zCls=any,zTit=any
         var iTit = GetWindowText( hWnd , zTit , 255 )
         var iCls = GetClassName( hWnd , zCls , 255 )
         var iWid = loword(width())-1, iTot = (iCls+iTit+14)
         if iTot > iWid then            
            if iCls > 24 then
               if (iCls-(iTot-iWid)) < 24 then
                  zCls = left(zCls,24)
               else
                  zCls = left(zCls,iCls-(iTot-iWid))
               end if
               iTot = (iCls+iTit+14)
            end if
         end if
         if iTot > iWid then                        
            zTit = right(zTit,iTit-(iTot-iWid))
         end if         
         'print hex(hWnd,8) & " {" & zCls & "} '" & zTit & "'"
      end if 
      
      #if 0
         GetWindowRect( g_hRunCombo , @tRc )
         if memcmp( @tRC , @tOldRC , sizeof(tRC) ) then
            tOldRC = tRC
            with tRC
               'print "Combo: " & .left & "," & .top & "-" & .right & "," & .bottom & " (" & .right-.left & "x" & .bottom-.top & ")"
            end with
         end if
      #endif
      sleep 50,1
   wend
   
   FreeLibraryAndExitThread( hModule , 0 )   
   return 0 'we will never reach here
end function

sub Cleanup()
   print "Cleanup"
   if bMustFreeConsole then FreeConsole()
end sub
sub BeforeExit() destructor
   print "Exitting..."
   Cleanup()
end sub
sub DllMain() constructor
   hConsole = GetConsoleWindow()
   if hConsole=NULL then
      bMustFreeConsole = 1 : AllocConsole()
      freopen("con", "r", stdin)
      freopen("con", "w", stdout)
      freopen("con", "w", stderr)
      SetForegroundWindow( GetConsoleWindow() )
   end if   
   dim dwTID as dword , hModule as Handle
   GetModuleHandleExA( &h4+&h2 , cast(any ptr,@DllThread) , @hModule )
   CloseHandle( CreateThread( NULL , 0 , @DllThread , hModule , 0 , @dwTID ) )
   
end sub
sub Dummy cdecl alias "Dummy" () export 'just so we have a export
   rem nothing
end sub

