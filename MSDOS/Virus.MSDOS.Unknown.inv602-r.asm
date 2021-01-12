;
; InVircible v6.02 Registrator, (c)1995 ûirogen
;
; This little utility simply installs InVircible's registration key onto
; your hard drive. It is located on the last sector of the first cylinder
; and is designated by the word 48A5h residing at the end of the sector.
; After installing this, all current and future copies of InVircible installed
; on that hard drive will be registered, or licenced rather.
;

segment     cseg
            assume  cs: cseg, ds: cseg, es: cseg, ss: cseg

cr          equ     0ah
lf          equ     0dh

org         100h
start:
            lea     dx,intro                    ; display intro / prompt
            call    disp
get_y_n:
            mov     ah,8                        ; make sure the user wants to
            int     21h
            cmp     al,'Y'
            jz      yes
            cmp     al,'y'
            jz      yes
            cmp     al,'N'
            jz      no
            cmp     al,'n'
            jz      no
            jmp     get_y_n
yes:
            call    disp_al
            mov     dh,1
            mov     cx,1
            call    read_sec                    ; read boot sector
            mov     dh,0
            mov     cx,word ptr sec_buf[18h]    ; get cylinder per sector
            call    read_sec                    ; read last sector of cyl 0
            mov     word ptr sec_buf[1FEh],0A548h ; throw word
            mov     ax,0301h                    ; write new sector to disk
            int     13h
            lea     dx,done_msg
            jmp     exit
no:
            call    disp_al
            lea     dx,abort_msg
exit:
            call    disp
            ret


read_sec:
            mov     ax,0201h
            lea     bx,sec_buf
            mov     dl,80h
            int     13h

            ret
disp:
            mov     ah,9
            int     21h
            ret

disp_al:
            mov     dl,al
            mov     ah,2
            int     21h
            ret

intro:
 db      cr,lf,' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
 db      cr,lf,' ³ InVircible v6.02 Registrator, (c)1995 ûirogen [NuKE] ³'
 db      cr,lf,' ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³'
 db      cr,lf,' ³    Please distribute all over the known universe     ³'
 db      cr,lf,' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
 db      cr,lf,'  WARNING: This software is about to make changes to the last sector'
 db      cr,lf,'  of cylinfer 0, head 0 of your hard drive. It is unlikely that any'
 db      cr,lf,'  problems will arise, but be cautious.'
 db      cr,lf,'  Do you wish to continue [Y/N]? $'
done_msg    db      cr,lf,cr,lf, '  InVircible Registrator Complete!$'
abort_msg   db      cr,lf,cr,lf, '  InVircible Registrator Aborted By User!$'
sec_buf:
cseg        ends
            end     start
