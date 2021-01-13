;----------------------------------------------------------------------------
;   TPE-GEN   -   This program generates 50 TPE encrypted test files
; 
;   This source can be compiled with MASM 5.0 or TASM 2.01
;   (and perhaps others too, but this is not tested.)
;----------------------------------------------------------------------------

                .model  tiny
                .RADIX  16

                .code

                extrn   crypt:near              ;external routines in engine
                extrn   rnd_get:near
                extrn   rnd_init:near


                org     0100

begin:          call    rnd_init                ;init. random number generator

                mov     dx,offset starttxt      ;print message
                mov     ah,09
                int     21

                mov     cx,50d                  ;repeat 50 times
lop:            push    cx

                mov     ah,3C                   ;create a new file
                mov     dx,offset filename
                mov     cx,0020
                int     21
                xchg    ax,bx

                push    ds
                push    es
                push    bx

                mov     ax,cs                   ;input parameters for engine
                mov     ds,ax
                add     ax,0400
                mov     es,ax                   ;ES = DS + 400h
                xor     si,si                   ;code will be right after decr.
                mov     dx,offset hello         ;this will be encrtypted
                mov     cx,100d                 ;length of code to encrypt
                mov     bp,0100                 ;decryptor will start at 100h
                call    rnd_get                 ;AX register will be random

                call    crypt                   ;call the engine

                pop     bx                      ;write crypted file
                mov     ah,40
                int     21

                mov     ah,3E                   ;close the file
                int     21

                pop     es
                pop     ds
                
                mov     di,offset filename      ;adjust name for next file
                mov     bx,7                    ; (increment number)
incnum:         inc     byte ptr ds:[bx+di]
                cmp     byte ptr ds:[bx+di],'9'
                jbe     numok
                mov     byte ptr ds:[bx+di],'0'
                dec     bx
                jnz     incnum

numok:          pop     cx                      ;do it again...
                loop    lop

exit:           int     20


;----------------------------------------------------------------------------
;               Text and data
;----------------------------------------------------------------------------

starttxt        db      'TPE-GEN  -  Generates 50 TPE encrypted test files.'
                db      0Dh, 0Ah, '$'

filename        db      '00000000.COM',0


;----------------------------------------------------------------------------
;               The small test file that will be encrypted
;----------------------------------------------------------------------------

hello:          call    next                    ;get relative offset
next:           pop     dx
                add     dx,10d                  ;find begin of message
                mov     ah,09                   ;print message
                int     21
                int     20

                db      'Hello, world!', 0Dh, 0A, '$'
                db      (100d) dup (90)

                end    begin
