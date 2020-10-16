; Catchy32 v1.6-2 - Length Disassembler Engine 32bit
; original source Catchy32.inc-orig (c) sars [HI-TECH] 2003
; this slightly opimized version - herm1t'2004
		BITS	32
		CPU	386
		global	catchy32

pref66h 	equ	1
pref67h 	equ	2

catchy32:	pushad
		mov	esi, [esp + 36]		; pointer to opcode
		sub	esp, 256		; allocate space for the table in stack
		mov	ebp, esp		; ebp <- opcode table
		mov	edi, esp
		push	esi
;; (1) unpack table
		mov	edx, esp		; save stack pointer
		push	115
		pop	ecx
		call	.data
		db      0x45,0x29,0x20,0x45,0x29,0x20,0x45,0x29
		db      0x20,0x45,0x29,0x20,0x45,0x29,0x36,0x45
		db      0x29,0x36,0x45,0x29,0x36,0x45,0x29,0x36
		db      0xe0,0xe0,0x60,0x25,0x57,0x30,0x28,0x40
		db      0xe7,0x27,0x2c,0x2b,0xc5,0xa0,0x31,0x40
		db      0x4f,0x40,0x29,0x60,0x87,0x8f,0x2b,0x2d
		db      0x25,0x2c,0x2e,0x2d,0x22,0x20,0x45,0x27
		db      0x20,0x85,0x87,0x2f,0x32,0x40,0x36,0x37
		db      0x20,0x25,0x60,0x65,0x33,0x40,0x35,0x34
		db      0x23,0x85,0x26,0x75,0x45,0x46,0x85,0x60
		db      0xb5,0xe5,0xe5,0xe5,0x65,0x4b,0x25,0x24
		db      0x85,0xef,0x2f,0xe5,0x25,0x20,0x21,0x2a
		db      0x25,0x20,0x21,0x2a,0xa5,0x35,0x2a,0x65
		db      0x2a,0x2b,0x2a,0x80,0x34,0xe5,0xe5,0x25
		db      0x34,0xc5,0x26
		; xlat table
		db	0x00,0x01,0x02,0x03,0x10,0x11,0x1e,0x22
		db	0x23,0x28,0x31,0x33,0x39,0x40,0x60,0x88
		db	0x89,0xc0,0xc2,0xe0,0xe1,0xee,0xf0,0xff
.data:		pop	esi
		lea	ebx, [esi + ecx]
		xor	eax, eax
.next:		lodsb
		push	ecx
		mov	ecx, eax
		shr	ecx, 5
		and	al, 31
		xlat
		rep	stosb
		pop	ecx
		loop	.next
		mov	esp, edx		; restore stack frame
;; /unpack
		pop	esi
		push	edi			; (2)
		mov	edi, esi		; (3)

		cmp	word [esi], 20cdh	; VXD call (6 bytes)
		jne	ExtFlags
		inc	esi
		inc	esi
		lodsd
CalcLen:	sub	esi, edi		; (3)
		cmp	esi, 15
		jbe 	OK
Error:		xor	esi, esi
		dec	esi
OK:		pop	esp			; (2)
		mov 	[esp+4*7], esi
		popad
		ret		
		; ecx zero after loop
;==============================================================================
ExtFlags:	xor	eax, eax
		xor	ebx, ebx	
		cdq
		lodsb				;al <- opcode
		mov 	cl, al			;cl <- opcode
		cmp	al, 0fh			;Test on prefix 0Fh
		jne 	NormTable		
		lodsb
		inc 	ah			;EAX=al+100h (100h/2 - lenght first table)
NormTable:	shr 	eax, 1			;Elements tables on 4 bits
		mov 	al, byte [ebp + eax]
		jc 	IFC1 
		shr	eax, 4			;Get high 4-bits block if offset is odd, otherwise...
IFC1:		and	al, 0fh
		xchg 	eax, ebx		;EAX will be needed for other purposes
CheckFlags:	cmp 	bl, 0Eh			;Test on ErrorFlag
		je 	Error
		cmp 	bl, 0Fh			;Test on PrefixFlag
		je 	Prefix
		or 	ebx, ebx		;One byte command   
		jz 	CalcLen
		btr	ebx, 0			;Command with ModRM byte
		jc 	ModRM
		btr 	ebx, 1			;Test on imm8,rel8 etc flag
		jc 	incr1
		btr	ebx, 2			;Test on ptr16 etc flag
		jc 	incr2
		and 	bl, 11110111b    	;Reset 16/32 sign 
		cmp 	cl, 0A0h		;Processing group 0A0h-0A3h
		jb	Check66h
		cmp	cl, 0A3h
		ja	Check66h
		test	ch, pref67h
		jnz	incr2
		jmp	incr4
Check66h:	test	ch, pref66h
		jnz	incr2
incr4:		inc	esi
		inc	esi
incr2:		inc	esi
incr1:		inc	esi
jmp_CheckFlags:	jmp 	CheckFlags
;-----------------------------------------------
Prefix:		cmp 	cl, 66h
		je 	SetF66h
		cmp 	cl, 67h
		jne	ExtFlags	
SetF67h:	or	ch, pref67h
		jmp	ExtFlags
;-----------------------------------------------
SetF66h:	or 	ch, pref66h
		jmp 	ExtFlags
;-----------------------------------------------
ModRM:		lodsb
		cmp 	cl, 0F7h		;Check on 0F6h and 0F7h groups
		je 	F6F7
		cmp 	cl, 0F6h
		jne 	ModXX			
F6F7:		test 	al, 00111000b		;Processing groups 0F6h and 0F7h
		jnz 	ModXX
		test 	cl, 00000001b
		jz	incbt1			
		test	ch, 1
		jnz	incbt2	
		inc 	esi
		inc 	esi
incbt2:		inc 	esi
incbt1:		inc 	esi
ModXX:		mov 	edx, eax		;Processing MOD bits
		and 	al, 00000111b		;al <- only R/M bits
		test	dl, 11000000b		;Check MOD bits
		jz  	Mod00
		jp  	CheckFlags		;Or c_Mod11
		js  	Mod10
Mod01:		test 	ch, pref67h
		jnz 	incr1			;16-bit addressing
		cmp 	al, 4			;Check SIB
		je 	incr2
		jmp 	incr1
;-----------------------------------------------
Mod00:		test 	ch, pref67h
		jz 	Mod00_32		;32-bit addressing
		cmp 	al, 6
		je 	incr2
		jmp 	jmp_CheckFlags
;-----------------------------------------------
Mod00_32:	cmp 	al, 4			;Check SIB
		jne 	disp32
		lodsb				;Processing SIB byte
		and 	al, 00000111b
disp32:		cmp 	al, 5
		je 	incr4
		jmp 	jmp_CheckFlags
;-----------------------------------------------
Mod10:		test 	ch, pref67h
		jnz 	incr2			;16-bit addressing
		cmp 	al, 4			;Check SIB
		jne	incr4
		inc 	esi
		jmp	incr4
