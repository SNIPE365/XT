#cmdline "-s gui -dll"

#include "windows.bi"
#include "crt.bi"

static shared as hwnd hConsole
static shared as bool bMustFreeConsole
static shared as hwnd g_hRunDlg , g_hRunCombo , g_hComboEdit , g_hComboEditTemp
static shared as rect g_tDlgRect

static shared as any ptr pOrgComboEditProc , pOrgComboEditTempProc
function ComboEditTempProc( hwnd as HWND , uMsg as ULONG , wParam as WPARAM , lParam as LPARAM ) as LResult   
   return CallWindowProc( pOrgComboEditTempProc , hwnd , uMsg , wparam , lParam )
end function
function ComboEditProc( hwnd as HWND , uMsg as ULONG , wParam as WPARAM , lParam as LPARAM ) as LResult   
   if g_hComboEditTemp = 0 then
      'var lStyle = GetWindowLong( g_hComboEdit , GWL_STYLE ) (lStyle and (not WS_DISABLED))
      var iID = GetWindowLong( g_hComboEdit , GWL_ID )+1
      var lStyle2 = WS_CHILD or WS_VSCROLL or ES_MULTILINE or WS_VISIBLE or ES_NOHIDESEL
      g_hComboEditTemp = CreateWindowEx( WS_EX_TOPMOST , "edit" , "" , lStyle2 , 0,0,320,60 , g_hRunDlg , cast(HMENU,iID),0,0 )      
      SendMessage( g_hComboEditTemp , WM_SETFONT , CallWindowProc( pOrgComboEditProc , hwnd , WM_GETFONT,0,0) , true )
      pOrgComboEditTempProc = cast(any ptr , SetWindowLongPtr( g_hComboEditTemp , GWLP_WNDPROC , cast(LONG_PTR , @ComboEditTempProc) ) )
   end if
   select case uMsg
   case WM_GETTEXT
      puts("WM_GETTEXT")
      return CallWindowProc( pOrgComboEditTempProc , g_hComboEditTemp , uMsg , wparam , lParam )         
   case WM_SETTEXT
      puts("WM_SETTEXT")
      return CallWindowProc( pOrgComboEditTempProc , g_hComboEditTemp , uMsg , wparam , lParam )
   end select
   'printf(!"hwnd: %p , uMsg=%i , wParam=%p , lParam = %p\n",hwnd,uMsg,wParam,lParam)   
   'SendMessage( g_hComboEditTemp , uMsg , wParam , lParam )
   'CallWindowProc( pOrgComboEditTempProc , g_hComboEditTemp , uMsg , wparam , lParam )         
   return CallWindowProc( pOrgComboEditProc , hwnd , uMsg , wparam , lParam )   
end function

static shared as any ptr pOrgComboProc
function ComboProc( hwnd as HWND , uMsg as ULONG , wParam as WPARAM , lParam as LPARAM ) as LResult   
   if pOrgComboProc=0 then return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   'select case uMsg
   'case WM_SIZE,WM_SIZING
   '   return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   'end select
   return CallWindowProc( pOrgComboProc , hwnd , uMsg , wParam , lParam )
end function

static shared as any ptr pOrgDlgProc
function DlgProc( hwnd as HWND , uMsg as ULONG , wParam as WPARAM , lParam as LPARAM ) as LResult   
   if pOrgDlgProc=0 then return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   select case uMsg      
   case WM_COMMAND
      'puts("WM_COMMAND")
      var wNotifyCode = clng(HIWORD(wParam)) 'notification code 
      var wID = LOWORD(wParam)
      if wNotifyCode = BN_CLICKED then         
         if (wID or (DC_HASDEFID shl 16)) = SendMessage( hWnd , DM_GETDEFID , 0 , 0 ) then
            puts("Default push button!")            
            dim as string sTemp = space( GetWindowTextLength( g_hComboEditTemp ) )
            GetWindowText( g_hComboEditTemp , strptr(sTemp) , len(sTemp)+1 )
            var iMulti = 0, iPosi = 1
            do 
              iPosi = instr( iPosi , sTemp , chr(13,10) )
              if iPosi then iMulti += 1 : *cptr(ushort ptr,strptr(sTemp)+iPosi-1) = &h7C20
            loop while iPosi
            if iMulti then SetWindowText( g_hComboEditTemp , "cmd /c "+sTemp ) 
         end if         
      end if
      'return DefWindowProc( hWnd , uMsg , wParam , lParam )   
   case WM_SIZE,WM_SIZING
      if g_hRunDlg andalso g_hRunCombo andalso IsIconic(g_hRunDlg)=false then
         static tOrgRc as RECT , lCbDiff as long
         dim as rect tNewDlgRc , tComboRc , tTempRc
         GetClientRect( hwnd , @tNewDlgRc )
         if tOrgRc.right = 0 then 
            tOrgRc = tNewDlgRc : GetClientRect( g_hRunCombo , @tTempRc )
            lCbDiff = tOrgRc.right-tTempRc.right
         end if
         if tNewDlgRc.right < tOrgRc.right then tNewDlgRc.right = tOrgRc.right
         if tNewDlgRc.bottom < tOrgRc.bottom then tNewDlgRc.bottom = tOrgRc.bottom         
         
         GetWindowRect( g_hRunCombo , @tComboRc )
         dim as HWND hCTL
         var iYDiff = cint(tNewDlgRc.bottom)-cint(g_tDlgRect.bottom)
         do
            hCTL = FindWindowEx( g_hRunDlg , hCTL , NULL , NULL )
            if hCTL = 0 then exit do
            if hCTL = g_hRunCombo then 
               SetWindowPos( hCtl , 0 , 0,0 , tNewDlgRc.right-lCbDiff,64 , SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOZORDER )
               continue do
            end if
            GetWindowRect( hCTL , @tTempRc )
            if (tTempRc.top) > tComboRc.bottom then
               tTempRc.top += iYDiff
               if tTempRc.top > tComboRc.bottom then               
                  ScreenToClient( hwnd , cast(POINT ptr,@tTempRc.left) )                                                
                  SetWindowPos( hCtl , 0 , tTempRc.left,tTempRc.top , 0,0 , SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOZORDER )
               end if
            end if
         loop      
         g_tDlgRect = tNewDlgRc
         InvalidateRect( g_hRunDlg , NULL , FALSE )
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
   SetWindowLong( g_hRunDlg , GWL_STYLE , lStyle or WS_SIZEBOX ) ' or WS_MINIMIZEBOX ) 
   'SetParent( g_hRunDlg , NULL )
   'SetWindowLong( g_hRunDlg , GWL_HINSTANCE , 0 )

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
   if g_hRunCombo then
      pOrgComboProc = cast(any ptr, SetWindowLongPtr( g_hRunCombo , GWLP_WNDPROC , cast(LONG_PTR,@comboProc) ) )
   end if
   g_hComboEdit = FindWindowEx( g_hRunCombo , 0 , "edit" , NULL )
      
   scope
      'SetWindowLong( hEdit , GWL_STYLE , lStyle or WS_VSCROLL or ES_MULTILINE )          
      'SetWindowPos( hEdit , 0,0,0,0,0 , SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED )   
      printf(!"hEdit = %p\n",g_hComboEdit)      
      ShowWindow( g_hComboEdit , SW_HIDE )      
      pOrgComboEditProc = cast(any ptr,SetWindowLongPtr( g_hComboEdit , GWLP_WNDPROC , cast(LONG_PTR,@ComboEditProc) ))      
      SendMessage( g_hComboEdit , WM_NULL , 0,0 )
   end scope

   'printf(!"Handle=%p\n",SendMessage(g_hComboEdit,EM_GETHANDLE,0,0))
   
   'SetWindowText( g_hComboEdit , "Hello World" )
      
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

