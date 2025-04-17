#cmdline "-s console"

#include "windows.bi"
#include "crt.bi"

function InjectDll( dwPID as long , sDll as string ) as bool   
   dim as handle hProc,hThread
   dim as any ptr pRemName
   do
      dim as DWORD dwTemp = any
      hProc = OpenProcess( PROCESS_ALL_ACCESS , false , dwPID )
      if hProc=0 then puts("Failed to open process"): function = 0 : exit do
      pRemName = VirtualAllocEx( hProc , 0 , len(sDll)+1 , MEM_COMMIT , PAGE_READWRITE )
      if pRemName=0 then puts("Failed to allocate memory"): function = 0 : exit do      
      if WriteProcessMemory( hProc , pRemName , strptr(sDll) , len(sDll)+1 , @dwTemp )=0 then
         puts("Failed to write memory"): function = 0 : exit do      
      end if
      dim as any ptr pLLA = GetProcAddress( GetModuleHandle( "kernel32.dll") , "LoadLibraryA" )
      if pLLA = 0 then
         puts("Failed to get address of target function"): function = 0 : exit do
      end if
      hThread = CreateRemoteThread( hProc , NULL , 0 , pLLA , pRemName , 0 , @dwTemp )
      if hThread=0 then puts("Failed to create thread"): function = 0: exit do
      if WaitForSingleObject( hThread , 8192 ) then 
         puts("Failed to wait for thread")
         TerminateThread( hThread , 0 )
      end if
      function = 1 : exit do
   loop
   'cleanup
   if hThread then CloseHandle( hThread )
   if pRemName then VirtualFreeEx( hProc , pRemName , 0 , MEM_RELEASE )
   if hProc then CloseHandle( hProc )
end function

dim as HWND hRunDlg

do
   
   sleep 500,1
   
   'keybd_event( VK_LWIN , 0 , 0 , 0 )
   'keybd_event( VK_R , 0 , 0 , 0 )
   'sleep 100,1
   'keybd_event( VK_R , 0 , KEYEVENTF_KEYUP , 0 )
   'keybd_event( VK_LWIN , 0 , KEYEVENTF_KEYUP , 0 )
   
   hRunDlg = NULL : print "Waiting 'RUN' dialog... ";
   while hRunDlg = NULL
     hRunDlg = FindWindow( "#32770" , "Run" )
     sleep 50,1
   wend   
   print "OK"
   
   dim as DWORD dwPID 
   if GetWindowThreadProcessId( hRunDlg , @dwPID ) then
      if InjectDll( dwPID , ExePath()+"\RunDlgDLL.dll" )=0 then
         print "Failed to inject DLL"
      end if
   end if   
   
   while IsWindow( hRunDlg )
      sleep 500,1
   wend
   print "Dialog closed..."
loop   
