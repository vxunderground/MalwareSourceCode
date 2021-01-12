code    segment
        assume  cs:code, ds:code, es:code
        org     100h
prog:
        jmp     main

asc     db      256 dup (0)
lll     dw      ?
tbl     dw      256 dup (0)
cod     db      256 dup (0)
len     db      256 dup (0)
dat     db      0,10,16,9,64,8,64,8,0,7
fn1     db      'te.com',0
fn2     db      'sup.com',0
fn3     db      'e1.com',0

main:

        call    read
        call    build
        call    uha
        call    good
        call    write

        mov     al,00h
        mov     ah,4ch
        int     21h

good    proc    near
        mov     ax,cs
        mov     ds,ax
        mov     si,offset asc
        mov     di,179
        mov     cx,130
        rep     movsb

        mov     dx,offset fn3
        mov     al,00h
        mov     ah,3dh
        int     21h
        jc      ssr
        mov     bx,ax
        mov     ax,es
        mov     ds,ax
        sub     dx,dx
        mov     cx,179
        mov     ah,3fh
        int     21h
        jc      ssr
        mov     ah,3eh
        int     21h
        mov     ax,cs
        mov     ds,ax
ssr:    ret
good    endp

uha     proc    near
        mov     ax,cs
        add     ax,1000h
        mov     ds,ax
        add     ax,1000h
        mov     es,ax
        mov     bx,4fffh
        mov     di,bx
        mov     ch,0
        sub     bp,bp
lu10:   sub     ax,ax
        mov     al,[bx]
        mov     si,ax
        mov     al,cs:cod[si]
        mov     dl,cs:len[si]
        mov     cl,dl
        cmp     dl,7
        jne     lu20
        inc     ah
lu20:   sub     cl,ch
        shl     ax,cl
        or      bp,ax
        add     ch,16
        sub     ch,dl
        mov     cl,8
lu30:   cmp     ch,cl
        jc      lu40
        mov     ax,bp
        shl     bp,cl
        mov     es:[di],ah
        dec     di
        sub     ch,cl
        jmp     short lu30
lu40:   dec     bx
        cmp     bx,0ffffh
        jne     lu10
        mov     ax,bp
        mov     es:[di],ah
        mov     lll,di
        mov     ah,0
lu50:   dec     di
        mov     es:[di],ah
        cmp     di,0
        jne     lu50
        ret
uha     endp

fill    proc    near
        sub     si,si
        mov     cx,0100h
lf10:   mov     ax,si
        mov     cs:asc[si],al
        inc     si
        loop    lf10
        sub     bx,bx
        mov     cx,5000h
lf20:   mov     al,[bx]
        mov     si,ax
        shl     si,1
        inc     cs:tbl[si]
        inc     bx
        loop    lf20
        ret
fill    endp

pause   proc    near
        push    ax
        mov     ah,01h
        int     21h
        pop     ax
        ret
pause   endp

sort    proc    near
        mov     cx,00ffh
l10:    mov     di,cx
        mov     bx,cx
        shl     bx,1
        add     bx,offset tbl
        sub     ax,ax
l20:    mov     si,ax
        shl     si,1
        mov     dx,tbl[si]
        cmp     dx,[bx]
        jnc     l30
        xchg    dx,[bx]
        xchg    dx,tbl[si]
        shr     si,1
        mov     dl,asc[si]
        xchg    dl,asc[di]
        xchg    dl,asc[si]
l30:    inc     ax
        cmp     ax,cx
        jc      l20
        loop    l10

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


        ret
sort    endp

make    proc    near
        mov     cx,16
        mov     bx,offset dat
        sub     si,si
        sub     ax,ax
lm10:   mov     al,asc[si]
        mov     di,ax
        mov     dx,si
        add     dl,[bx]
        mov     cod[di],dl
        mov     dl,[bx+1]
        mov     len[di],dl
        inc     si
        cmp     si,cx
        jnz     lm10
        inc     bx
        inc     bx
        shl     cx,1
        cmp     cx,512
        jnz     lm10
        ret
make    endp

build   proc    near
        call    fill
        mov     ax,cs
        mov     ds,ax
        call    sort
        call    make
        ret
build   endp

write   proc    near
        mov     dx,offset fn2
        mov     al,02h
        mov     ah,3dh
        int     21h
        jc      sw
        mov     bx,ax
        mov     ax,es
        mov     ds,ax
        sub     dx,dx
        mov     cx,5000h
        mov     ah,40h
        int     21h
        jc      sw
        mov     ah,3eh
        int     21h
sw:     ret
write   endp

read    proc    near
        mov     dx,offset fn1
        mov     al,00h
        mov     ah,3dh
        int     21h
        jc      sr
        mov     bx,ax
        mov     ax,ds
        add     ax,1000h
        mov     ds,ax
        sub     dx,dx
        mov     cx,5000h
        mov     ah,3fh
        int     21h
        jc      sr
        mov     ah,3eh
        int     21h
sr:     ret
read    endp


last    label   byte
code    ends
        end     prog

