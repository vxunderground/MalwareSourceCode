code    segment
        assume  cs:code, ds:code
        org     100h

asc2    equ     asc + 128

prog:

        mov     ax,cs
        add     ax,1000h
        mov     es,ax
        mov     si,0100h
        mov     di,si
        mov     cx,5000h
        rep     movsb
        mov     word ptr [next+2],es
        jmp     dword ptr [next]

next    db      1dh,1,0,0

part2:
        push    ds
        pop     es
        push    cs
        pop     ds

        mov     di,offset asc + 128
        sub     bx,bx
k10:    mov     [bx][di],bl
        inc     bl
        jnz     k10
        mov     si,offset asc
k20:    mov     bl,[si]
        mov     byte ptr [bx][di],0
        inc     si
        cmp     si,di
        jne     k20
        dec     di
        mov     cx,128
k30:    inc     di
        cmp     byte ptr [di],0
        je      k30
        mov     al,[di]
        mov     [si],al
        inc     si
        loop    k30

        mov     bx,50ffh
        mov     di,bx
        mov     cl,0
l10:    mov     ah,[di]
        mov     al,[di-1]
        mov     si,ax
        sub     ax,ax
        mov     dl,6
        shl     si,cl
        mov     ch,cl
        mov     cl,12
        shl     si,1
        jnc     l20
        mov     al,64
        dec     cx
        dec     cx
        inc     dx
        inc     dx
        shl     si,1
        jnc     l30
        shl     ax,1
        dec     cx
        inc     dx
        jmp     short l30
l20:    shl     si,1
        jnc     l30
        inc     dx
        mov     al,16
        shl     si,1
        jnc     l30
        shl     ax,1
        dec     cx
        inc     dx
l30:    shr     si,cl
        add     si,ax
        mov     al,asc[si]
        mov     es:[bx],al
        mov     cl,dl
        add     cl,ch
l40:    cmp     cl,8
        jc      l50
        sub     cl,8
        dec     di
        jmp     short l40
l50:    dec     bx
        cmp     bx,00ffh
        jne     l10

        mov     [next],0
        mov     word ptr [next+2],es
        jmp     dword ptr [next]

asc     db      ?

last    label   byte
code    ends
        end     prog

