
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                             ONE_HALF                                 €€
;€€                                                                      €€
;€€      Created:   19-Oct-94                                            €€
;€€      Passes:    5          Analysis Options on: none                 €€
;€€                                                                      €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target          EQU   'M5'                      ; Target assembler: MASM-5.1

;include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e         equ     2Ch
data_2e         equ     70h
data_3e         equ     72h
data_4e         equ     84h
data_6e         equ     100h
data_7e         equ     2A0h
data_8e         equ     2A2h
data_9e         equ     2A9h
data_10e        equ     2ADh
data_11e        equ     2B8h
main_ram_size_  equ     413h
timer_low_      equ     46Ch
data_12e        equ     56Ah                    ;*
data_13e        equ     600h                    ;*
data_14e        equ     7BEh                    ;*
data_15e        equ     7D1h                    ;*
data_16e        equ     0BABh                   ;*
data_17e        equ     0DD6h                   ;*
data_18e        equ     0                       ;*
data_19e        equ     3                       ;*
data_20e        equ     0
data_21e        equ     1
data_22e        equ     3
data_23e        equ     10h
data_24e        equ     12h
data_25e        equ     16h
data_26e        equ     1Ah
data_27e        equ     22h
data_28e        equ     24h
data_29e        equ     26h
data_30e        equ     2Ah
data_31e        equ     34h
data_32e        equ     3Ch
data_33e        equ     3Eh
data_34e        equ     40h
data_35e        equ     4Ch
data_37e        equ     70h
data_39e        equ     86h
data_40e        equ     0A4h
data_41e        equ     0A6h
data_42e        equ     0A8h
data_43e        equ     0AAh
data_44e        equ     0C6h
data_45e        equ     0F8h
data_46e        equ     0FFh
data_105e       equ     0F35h                   ;*
data_107e       equ     0F39h                   ;*
data_108e       equ     0F55h                   ;*
data_109e       equ     0F5Fh                   ;*
data_111e       equ     0F63h                   ;*
data_112e       equ     0F65h                   ;*
data_113e       equ     0F67h                   ;*
data_114e       equ     0FB4h                   ;*
data_115e       equ     1007h                   ;*
data_116e       equ     1701h                   ;*
data_117e       equ     1B00h                   ;*
data_118e       equ     4E01h                   ;*
data_119e       equ     7C00h                   ;*
data_120e       equ     0BC61h                  ;*
data_121e       equ     0C400h                  ;*
data_122e       equ     0DE8h
data_123e       equ     0DEAh
data_124e       equ     0

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

one_half        proc    far

start:
                pop     dx
                add     ds:data_46e[bx],bx
                add     [bx+si],al
                add     [bp+di+4Fh],al
                dec     bp
                dec     bp
                inc     cx
                dec     si
                inc     sp
                add     [di+5Ah],cl
                mov     [bx+si],ax
                adc     al,[bx+si]
                add     [bx+si],al
                add     al,[bx+si]
                jnz     loc_4                   ; Jump if not zero
                db      0FFh,0FFh, 76h
loc_4:
                add     si,ax
                add     al,[bx+di]
                add     [bx+si],al
                add     [bx+si],cl
                add     bl,ds:data_121e
                add     bp,ss:data_118e[bp+di]
                add     al,2Fh                  ; '/'
                add     ss:data_117e[bp+si],bl
                add     cl,ds:data_116e[bx]
                add     si,si
                add     cl,dl
                add     ss:data_115e[bp+si],si
                jmp     short $-42h
                                                ;* No entry point to code
                call    sub_2
                mov     cx,1004h
                jnc     $+5Ah                   ; Jump if carry=0
                pop     bx
                pop     cx
                pop     dx
                dec     cx
                test    al,1Dh
                mov     cx,698Eh
                clc                             ; Clear carry flag
                push    cx
loc_6:
                mov     cl,4
                shr     ax,cl                   ; Shift w/zeros fill
                mov     cx,es
                add     cx,ax
                push    es
                inc     sp
                lds     dx,dword ptr [bx+si]    ; Load 32 bit ptr
                or      [bx+si],al
loc_7:
                db       60h, 5Ch,0BAh, 0Fh,0F4h,0FFh
                db       3Fh,0EAh, 2Eh, 03h, 01h, 9Ch
                db       2Eh, 0Bh, 07h, 91h

locloop_8:
                movsw                           ; Mov [si] to es:[di]
                movsw                           ; Mov [si] to es:[di]
                sub     si,4
                loop    locloop_8               ; Loop if cx > 0

                or      word ptr [bp+di],0FFDBh
                jnz     loc_6                   ; Jump if not zero
                cld                             ; Clear direction
                push    es
loc_10:
                pop     ds
                lea     si,[di+2]               ; Load effective addr
;*              jz      loc_9                   ;*Jump if zero
                db       74h,0F4h               ;  Fixup - byte match
                jc      loc_10                  ; Jump if carry Set
                add     bp,bp
                dec     dx
                jz      loc_7                   ; Jump if zero
;*              jc      loc_5                   ;*Jump if carry Set
                db       72h, 95h               ;  Fixup - byte match
                mov     dl,10h
                jmp     short loc_11
                                                ;* No entry point to code
                lodsw                           ; String [si] to ax
                xchg    bp,ax
                mov     dl,10h
;*              jmp     short loc_13            ;*
                db      0EBh, 75h               ;  Fixup - byte match
                                                ;* No entry point to code
                add     al,0F3h
                stosw                           ; Store ax to es:[di]
;*              jmp     short loc_12            ;*
                db      0EBh, 2Ah               ;  Fixup - byte match
                                                ;* No entry point to code
                stosb                           ; Store al to es:[di]
                xchg    al,ah
                dec     cx
                adc     [bx+si],al

one_half        endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2           proc    near
                push    ds
                add     [bx+si],al
                add     dh,[bp+di]
                db      0DBh,0FAh,0BCh, 00h, 7Ch, 8Eh
                db      0D3h,0FBh, 8Eh,0DBh, 83h, 2Eh
                db       13h, 04h, 04h
loc_11:
                mov     cl,6
                int     12h                     ; Put (memory size)/1K in ax
                shl     ax,cl                   ; Shift w/zeros fill
                mov     dx,80h
                mov     es,ax
                mov     cx,0Bh
                mov     ax,207h
                push    es
                int     13h                     ; Disk  dl=drive 0  ah=func 02h
                                                ;  read sectors to memory es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                mov     ax,0D3h
                push    ax
                retf
sub_2           endp

                                                ;* No entry point to code
                mov     ds:data_39e,cs
                mov     ax,word ptr ds:[46Ch]
                push    ds
                push    cs
                pop     ds
                mov     word ptr ds:[56Ah],ax
                mov     ax,cs
                inc     ax
                mov     ds:data_21e,ax
                mov     byte ptr ds:[0CEBh],0
                call    sub_3
                pop     es
                mov     bx,sp
                push    es
                mov     si,es:[bx+29h]
;*              cmp     si,7
                db       81h,0FEh, 07h, 00h     ;  Fixup - byte match
                jbe     loc_19                  ; Jump if below or =
                push    si
                sub     si,2
                mov     word ptr ds:[140h],si
                pop     si
                mov     ah,8
                int     13h                     ; Disk  dl=drive a  ah=func 08h
                                                ;  get drive parameters, bl=type
                                                ;   cx=cylinders, dh=max heads
                                                ;   es:di= ptr to drive table
                jc      loc_19                  ; Jump if carry Set
                mov     al,cl
                and     al,3Fh                  ; '?'
                mov     byte ptr ds:[0E2Dh],al
                mov     cl,1
                mov     bh,7Eh                  ; '~'
                mov     word ptr ds:[0E2Fh],bx
                mov     dl,80h
loc_14:
                dec     si
                call    sub_4
                push    dx
loc_15:
                mov     ah,2
                push    ax
                int     13h                     ; Disk  dl=drive 0  ah=func 02h
                                                ;  read sectors to memory es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                pop     ax
                jc      loc_16                  ; Jump if carry Set
                call    $+0D00h
                inc     ah
                push    ax
                int     13h                     ; Disk  dl=drive 0  ah=func 03h
                                                ;  write sectors from mem es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                pop     ax
loc_16:
                jc      loc_21                  ; Jump if carry Set
                test    dh,3Fh                  ; '?'
                jz      loc_17                  ; Jump if zero
                dec     dh
                jmp     short loc_15
loc_17:
                pop     dx
                cmp     si,3A7h
                ja      loc_14                  ; Jump if above
loc_18:
                mov     bh,7Ch                  ; '|'
                mov     es:[bx+29h],si
                mov     ax,301h
                mov     cx,1
                mov     dh,ch
                int     13h                     ; Disk  dl=drive 0  ah=func 03h
                                                ;  write sectors from mem es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
loc_19:
                mov     word ptr ds:[0EEEh],si
                cmp     si,19Ch
                ja      loc_20                  ; Jump if above
                call    sub_5
loc_20:
                mov     ax,201h
                mov     bx,data_119e
                mov     cx,ds:data_44e
                dec     cx
                mov     dx,80h
                int     13h                     ; Disk  dl=drive 0  ah=func 02h
                                                ;  read sectors to memory es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                cli                             ; Disable interrupts
                les     ax,dword ptr es:data_35e        ; Load 32 bit ptr
                mov     ds:data_105e,ax
                mov     word ptr ds:data_105e+2,es
                pop     es
                push    es
                les     ax,dword ptr es:data_37e        ; Load 32 bit ptr
                mov     word ptr ds:[205h],ax
                mov     word ptr ds:[207h],es
                pop     es
                push    es
                mov     word ptr es:data_35e,0E45h
                mov     word ptr es:data_35e+2,cs
                mov     word ptr es:data_37e,1D1h
                mov     word ptr es:data_37e+2,cs
                sti                             ; Enable interrupts
                push    bx
                retf                            ; Return far
loc_21:
                xor     ah,ah                   ; Zero register
                push    ax
                int     13h                     ; Disk  dl=drive a  ah=func 00h
                                                ;  reset disk, al=return status
                pop     ax
loc_22:
                inc     dh
                mov     ah,dh
                pop     dx
                push    dx
                cmp     ah,dh
                ja      loc_23                  ; Jump if above
                mov     dh,ah
                mov     ah,2
                push    ax
                int     13h                     ; Disk  dl=drive a  ah=func 02h
                                                ;  read sectors to memory es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                pop     ax
                call    $+0C68h
                inc     ah
                push    ax
                int     13h                     ; Disk  dl=drive a  ah=func 03h
                                                ;  write sectors from mem es:bx
                                                ;   al=#,ch=cyl,cl=sectr,dh=head
                pop     ax
                jmp     short loc_22
loc_23:
                pop     dx
                inc     si
                jmp     loc_18
                                                ;* No entry point to code
                push    ax
                push    ds
                push    es
                xor     ax,ax                   ; Zero register
                mov     ds,ax
                les     ax,dword ptr ds:data_4e ; Load 32 bit ptr
                mov     word ptr cs:[0DE8h],ax
                mov     ax,es
                cmp     ax,800h
                ja      loc_24                  ; Jump if above
                mov     word ptr cs:[0DEAh],ax
                les     ax,dword ptr cs:[205h]  ; Load 32 bit ptr
                mov     ds:data_2e,ax
                mov     ds:data_3e,es
                mov     word ptr ds:data_4e,0C5Dh
                mov     word ptr ds:data_4e+2,cs
loc_24:
                pop     es
                pop     ds
                pop     ax
;*              jmp     far ptr loc_158         ;*
                db      0EAh
                dw      0FF53h, 0F000h          ;  Fixup - byte match

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3           proc    near
                mov     si,772h
                mov     di,0DD8h
                mov     cx,15Dh
                cld                             ; Clear direction
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                retn
sub_3           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4           proc    near
                push    ax
                mov     ax,si
                mov     ch,al
                push    cx
                mov     cl,4
                shl     ah,cl                   ; Shift w/zeros fill
                pop     cx
                mov     al,3Fh                  ; '?'
                and     dh,al
                and     cl,al
                not     al
                push    ax
                and     ah,al
                or      dh,ah
                pop     ax
                shl     ah,1                    ; Shift w/zeros fill
                shl     ah,1                    ; Shift w/zeros fill
                and     ah,al
                or      cl,ah
                pop     ax
                retn
sub_4           endp

                db      'Dis is one half.', 0Dh, 0Ah, 'Pr'
                db      'ess any key to continue ...', 0Dh
                db      0Ah

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5           proc    near
                mov     ah,4
                int     1Ah                     ; Real time clock   ah=func 04h
                                                ;  get date  cx=year, dx=mon/day
                jc      loc_ret_26              ; Jump if carry Set
                test    dl,3
                jnz     loc_ret_26              ; Jump if not zero
                test    word ptr ds:[0DD6h],1
                jnz     loc_ret_26              ; Jump if not zero
                mov     cx,31h
                mov     si,239h
                mov     ah,0Fh
                int     10h                     ; Video display   ah=functn 0Fh
                                                ;  get state, al=mode, bh=page
                                                ;   ah=columns on screen
                mov     bl,7
                mov     ah,0Eh

locloop_25:
                lodsb                           ; String [si] to al
                int     10h                     ; Video display   ah=functn 0Eh
                                                ;  write char al, teletype mode
                loop    locloop_25              ; Loop if cx > 0

                xor     ah,ah                   ; Zero register
                int     16h                     ; Keyboard i/o  ah=function 00h
                                                ;  get keybd char in al, ah=scan

loc_ret_26:
                retn
sub_5           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6           proc    near
                push    bx
                mov     bx,0
                int     21h                     ; DOS Services  ah=function 42h
                                                ;  move file ptr, bx=file handle
                                                ;   al=method, cx,dx=offset
                pop     bx
                retn
sub_6           endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7           proc    near
                pushf                           ; Push flags
                cli                             ; Disable interrupts
;*              call    far ptr sub_1           ;*
                db      9Ah
                dw      774h, 70h               ;  Fixup - byte match
                retn
sub_7           endp

                                                ;* No entry point to code
                push    bp
                mov     bp,sp
                jmp     short loc_27
                                                ;* No entry point to code
                cmp     word ptr [bp+4],253h
                ja      loc_28                  ; Jump if above
                push    ax
                push    bx
                push    ds
                lds     ax,dword ptr [bp+2]     ; Load 32 bit ptr
                mov     bx,469h
                mov     word ptr cs:[2A0h][bx],ax
                mov     word ptr cs:[2A2h][bx],ds
                mov     byte ptr cs:[2A9h][bx],23h      ; '#'
                pop     ds
                pop     bx
                pop     ax
loc_27:
                and     byte ptr [bp+7],0FEh
loc_28:
                pop     bp
                iret                            ; Interrupt return
loc_29:
                pop     bx
                pop     ax
                push    ax
                dec     ax
                mov     ds,ax
                cmp     byte ptr ds:data_124e,5Ah       ; 'Z'
                jne     loc_31                  ; Jump if not equal
                add     ax,ds:data_22e
                sub     ax,0FFh
                mov     dx,cs
                mov     si,bx
                mov     cl,4
                shr     si,cl                   ; Shift w/zeros fill
                add     dx,si
                mov     si,cs:data_26e[bx]
                cmp     si,106h
                jae     loc_30                  ; Jump if above or =
                mov     si,106h
loc_30:
                add     dx,si
                cmp     ax,dx
                jb      loc_31                  ; Jump if below
                mov     byte ptr ds:data_20e,4Dh        ; 'M'
                sub     word ptr ds:data_22e,100h
                mov     ds:data_24e,ax
                mov     es,ax
                push    cs
                pop     ds
                inc     ax
                mov     ds:data_21e,ax
                mov     byte ptr ds:[0BABh][bx],0EBh
                mov     si,bx
                xor     di,di                   ; Zero register
                mov     cx,0DD8h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                push    es
                pop     ds
                call    sub_3
                xor     ax,ax                   ; Zero register
                mov     ds,ax
                cli                             ; Disable interrupts
                mov     ax,ds:data_4e
                mov     es:data_122e,ax
                mov     ax,word ptr ds:data_4e+2
                mov     es:data_123e,ax
                mov     word ptr ds:data_4e,0C5Dh
                mov     word ptr ds:data_4e+2,es
                sti                             ; Enable interrupts
loc_31:
                jmp     loc_39
                db      0E8h, 00h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8           proc    near
                pop     si
                sub     si,352h
                mov     ds:data_11e[si],si
                push    es
                push    si
                cld                             ; Clear direction
                inc     word ptr ds:data_17e[si]
                mov     byte ptr ds:data_16e[si],74h    ; 't'
                xor     ax,ax                   ; Zero register
                mov     es,ax
                mov     ax,es:timer_low_
                mov     ds:data_12e[si],ax
                mov     ds:data_15e[si],ax
                mov     ax,4B53h
                int     21h                     ; ??INT Non-standard interrupt
                int     3                       ; Debug breakpoint
                dec     bx
                inc     bp
                jz      loc_32                  ; Jump if zero
                mov     ah,52h
                int     21h                     ; DOS Services  ah=function 52h
                                                ;  get DOS data table ptr es:bx
                                                ;*  undocumented function
                mov     ax,es:[bx-2]
                mov     ds:data_10e[si],ax
                mov     byte ptr ds:data_9e[si],0
                mov     ax,3501h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                push    bx
                push    es
                mov     ax,3513h
                int     21h                     ; DOS Services  ah=function 35h
                                                ;  get intrpt vector al in es:bx
                mov     ds:data_7e[si],bx
                mov     ds:data_8e[si],es
                mov     ax,2501h
;*              lea     dx,loc_1[si]            ;*Load effective addr
                db       8Dh, 94h,0A5h, 02h     ;  Fixup - byte match
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                lea     bx,cs:[0DD8h][si]       ; Load effective addr
                mov     cx,1
                mov     dx,80h
                push    cs
                pop     es
                pushf                           ; Push flags
                pop     ax
                or      ah,1
                push    ax
                popf                            ; Pop flags
                mov     ax,201h
                call    sub_7
                pushf                           ; Push flags
                pop     ax
                and     ah,0FEh
                push    ax
                popf                            ; Pop flags
                pop     ds
                pop     dx
                pushf                           ; Push flags
                mov     ax,2501h
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                popf                            ; Pop flags
                jc      loc_36                  ; Jump if carry Set
                push    cs
                pop     ds
                cmp     word ptr [bx+25h],0D3h
                jne     loc_33                  ; Jump if not equal
loc_32:
                jmp     loc_38
loc_33:
                cmp     word ptr ds:[180h][bx],72Eh
                je      loc_36                  ; Jump if equal
                mov     ah,8
                mov     dl,80h
                call    sub_7
                jc      loc_36                  ; Jump if carry Set
                and     cx,3Fh
                mov     byte ptr ds:[814h][si],cl
                mov     byte ptr ds:[89Eh][si],cl
                and     dh,3Fh                  ; '?'
                mov     byte ptr ds:[8A7h][si],dh
                mov     ax,301h
                sub     cl,7
                mov     byte ptr ds:[819h][si],cl
                mov     dx,80h
                call    sub_7
                jc      loc_36                  ; Jump if carry Set
                push    cx
                push    dx
                push    si
                xchg    di,si
                mov     cx,4
                add     bx,1EEh

locloop_34:
                mov     al,[bx+4]
                cmp     al,1
                je      loc_37                  ; Jump if equal
                cmp     al,4
                jb      loc_35                  ; Jump if below
                cmp     al,6
                jbe     loc_37                  ; Jump if below or =
loc_35:
                sub     bx,10h
                loop    locloop_34              ; Loop if cx > 0

                pop     si
                pop     dx
                pop     cx
loc_36:
                jmp     loc_29
loc_37:
                mov     cx,[bx+2]
                mov     dh,[bx+1]
                call    sub_16
                add     si,7
                mov     ds:data_45e[di],si
                xchg    si,ax
                mov     cx,[bx+6]
                mov     dh,[bx+1]
                call    sub_16
                mov     word ptr ds:[882h][di],si
                mov     word ptr ds:[48Ch][di],si
                add     ax,si
                shr     ax,1                    ; Shift w/zeros fill
                mov     word ptr ds:[15Ah][di],ax
                pop     si
                pop     dx
                pop     cx
                mov     ax,307h
                xchg    bx,si
                inc     cx
                mov     ds:data_44e[bx],cx
                call    sub_7
                jc      loc_36                  ; Jump if carry Set
                lea     si,ds:data_43e[bx]      ; Load effective addr
                lea     di,ds:[0DD8h][bx]       ; Load effective addr
                push    di
                mov     cx,29h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                mov     ax,332h
                stosw                           ; Store ax to es:[di]
                mov     ax,301h
                pop     bx
                mov     cx,1
                call    sub_7
                jc      loc_36                  ; Jump if carry Set
loc_38:
                pop     bx
loc_39:
                push    cs
                pop     ds
                push    cs
                pop     es
                lea     si,ds:data_34e[bx]      ; Load effective addr
;*              add     bx,data_30e
                db       81h,0C3h, 2Ah, 00h     ;  Fixup - byte match
                mov     cx,0Ah

locloop_40:
                mov     di,[bx]
                push    cx
                mov     cx,0Ah
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     cx
                inc     bx
                inc     bx
                loop    locloop_40              ; Loop if cx > 0

                pop     es
                add     bx,0FFD2h
                mov     di,es
                add     di,10h
                add     [bx+16h],di
                add     [bx+0Eh],di
                cmp     word ptr [bx+6],0
                je      loc_45                  ; Jump if equal
                mov     ds,es:data_1e
                xor     si,si                   ; Zero register
loc_41:
                inc     si
                cmp     word ptr [si],0
                jne     loc_41                  ; Jump if not equal
                add     si,4
                xchg    dx,si
                mov     ax,3D00h
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ;  open file, al=mode,name@ds:dx
                jc      loc_48                  ; Jump if carry Set
                push    cs
                pop     ds
                mov     word ptr ds:[287h][bx],ax
                mov     dx,[bx+18h]
                mov     ax,4200h
                call    sub_6
                push    es
                xchg    di,ax
loc_42:
                push    ax
                lea     dx,cs:[54Dh][bx]        ; Load effective addr
                mov     cx,[bx+6]
                cmp     cx,29Eh
                jb      loc_43                  ; Jump if below
                mov     cx,29Eh
loc_43:
                sub     [bx+6],cx
                push    cx
                shl     cx,1                    ; Shift w/zeros fill
                shl     cx,1                    ; Shift w/zeros fill
                mov     ah,3Fh                  ; '?'
                call    sub_6
                jc      loc_48                  ; Jump if carry Set
                pop     cx
                pop     ax
                xchg    si,dx

locloop_44:
                add     [si+2],ax
                les     di,dword ptr [si]       ; Load 32 bit ptr
                add     es:[di],ax
                add     si,4
                loop    locloop_44              ; Loop if cx > 0

                cmp     word ptr [bx+6],0
                ja      loc_42                  ; Jump if above
                pop     es
                mov     ah,3Eh                  ; '>'
                call    sub_6
loc_45:
                push    es
                pop     ds
                cmp     byte ptr cs:[bx+12h],0
                jne     loc_46                  ; Jump if not equal
                mov     si,bx
                mov     di,data_6e
                mov     cx,3
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     ax
                jmp     short loc_47
loc_46:
                pop     ax
                cli                             ; Disable interrupts
                mov     sp,cs:[bx+10h]
                mov     ss,cs:[bx+0Eh]
                sti                             ; Enable interrupts
loc_47:
                jmp     dword ptr cs:[bx+14h]   ;*
loc_48:
                mov     ah,4Ch
                int     21h                     ; DOS Services  ah=function 4Ch
                                                ;  terminate with al=return code

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_9:
                mov     word ptr cs:[5A8h],si
                push    ax
                push    bx
                push    cx
                push    dx
                mov     cx,1624h
                mov     bx,2B28h
                mov     dx,15Ah
                mov     ax,4E35h
                xchg    si,ax
                xchg    dx,ax
                test    ax,ax
                jz      loc_49                  ; Jump if zero
                mul     bx                      ; dx:ax = reg * ax
loc_49:
                jcxz    loc_50                  ; Jump if cx=0
                xchg    cx,ax
                mul     si                      ; dx:ax = reg * ax
                add     ax,cx
loc_50:
                xchg    si,ax
                mul     bx                      ; dx:ax = reg * ax
                add     dx,si
                inc     ax
                adc     dx,0
                mov     word ptr cs:[56Ah],ax
                mov     word ptr cs:[567h],dx
                mov     ax,dx
                pop     cx
                xor     dx,dx                   ; Zero register
                jcxz    loc_51                  ; Jump if cx=0
                div     cx                      ; ax,dx rem=dx:ax/reg
loc_51:
                pop     cx
                pop     bx
                pop     ax
                pop     si
                push    si
                cmp     byte ptr cs:[si],0CCh
loc_52:
                je      loc_52                  ; Jump if equal
                mov     si,5CBh
                retn
sub_8           endp

                                                ;* No entry point to code
                add     [bx+si+1],dx
                push    ss
                add     [bx],bx
                add     di,word ptr ds:[469h][bx]
                add     di,ds:data_120e[bx+si]
                add     dh,[bx+di]
                add     ax,8104h
                db      0C0h
data_76         dw      0CAABh
                db       01h, 47h, 04h, 81h,0FFh, 41h
                db       12h, 02h, 75h,0EFh, 90h,0F9h
                db      0F8h,0FBh, 2Eh, 36h, 3Eh,0FCh
                db      0FDh,0F5h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10          proc    near
                or      dx,dx                   ; Zero ?
                jz      loc_ret_54              ; Jump if zero
                push    si
                push    cx
                push    dx
                mov     cx,dx

locloop_53:
                mov     si,5CBh
                mov     dx,0Ah
                call    sub_9
                add     si,dx
                movsb                           ; Mov [si] to es:[di]
                loop    locloop_53              ; Loop if cx > 0

                pop     dx
                pop     cx
                pop     si

loc_ret_54:
                retn
sub_10          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11          proc    near
                mov     ax,dx
                inc     dx
                call    sub_9
                sub     ax,dx
                call    sub_10
                xchg    dx,ax
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
;*              cmp     bx,data_32e
                db       81h,0FBh, 3Ch, 00h     ;  Fixup - byte match
                jnz     loc_55                  ; Jump if not zero
                mov     ax,ds:data_31e
                sub     ax,di
                add     ax,0F3Bh
                sub     ax,[bx]
                dec     di
                stosb                           ; Store al to es:[di]
loc_55:
                call    sub_10
                retn
sub_11          endp

                                                ;* No entry point to code
                mov     dh,5
                mov     bx,0BE05h
                add     ax,5B2h
                mov     bx,0C205h
                add     ax,5C5h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12          proc    near
loc_56:
                lodsw                           ; String [si] to ax
                xchg    di,ax
                mov     al,dl
                cmp     si,61Eh
                jne     loc_57                  ; Jump if not equal
                and     al,5
                cmp     al,1
                jne     loc_58                  ; Jump if not equal
                mov     al,7
loc_57:
                cmp     si,618h
                jne     loc_58                  ; Jump if not equal
                mov     cl,3
                shl     al,cl                   ; Shift w/zeros fill
                or      [di],al
                or      al,0C7h
                jmp     short loc_59
loc_58:
                or      [di],al
                or      al,0F8h
loc_59:
                and     [di],al
                cmp     si,61Ah
                je      loc_ret_60              ; Jump if equal
                cmp     si,622h
                je      loc_ret_60              ; Jump if equal
                jmp     short loc_56

loc_ret_60:
                retn
sub_12          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13          proc    near
                mov     dx,2
                call    sub_9
                mov     byte ptr ds:[5AEh],0Eh
                or      dx,dx                   ; Zero ?
                jz      loc_61                  ; Jump if zero
                mov     byte ptr ds:[5AEh],16h
loc_61:
                mov     si,614h
loc_62:
                mov     dx,8
                call    sub_9
                cmp     dl,4
                je      loc_62                  ; Jump if equal
                mov     bl,dl
                call    sub_12
                mov     si,61Ah
loc_63:
                mov     dx,3
                call    sub_9
                add     dl,6
                cmp     dl,8
                jne     loc_64                  ; Jump if not equal
                mov     dl,3
loc_64:
                cmp     dl,bl
                je      loc_63                  ; Jump if equal
                call    sub_12
                xor     cx,cx                   ; Zero register
                mov     di,2Ah
loc_65:
                cmp     cx,9
                jne     loc_67                  ; Jump if not equal
loc_66:
                mov     dx,0C8h
                call    sub_9
                sub     dx,64h
                add     dx,ds:data_31e
                cmp     dx,0
                jl      loc_66                  ; Jump if <
                cmp     dx,data_76
                jge     loc_66                  ; Jump if > or =
                jmp     short loc_68
loc_67:
                mov     dx,45Ah
                call    sub_9
loc_68:
                jcxz    loc_71                  ; Jump if cx=0
                mov     si,data_30e
                push    cx

locloop_69:
                lodsw                           ; String [si] to ax
                sub     ax,dx
                cmp     ax,0Ah
                jge     loc_70                  ; Jump if > or =
                cmp     ax,0FFF6h
                jle     loc_70                  ; Jump if < or =
                pop     cx
                jmp     short loc_65
loc_70:
                loop    locloop_69              ; Loop if cx > 0

                pop     cx
loc_71:
                xchg    dx,ax
                stosw                           ; Store ax to es:[di]
                inc     cx
                cmp     cx,0Ah
                jb      loc_65                  ; Jump if below
                mov     bx,data_30e
                mov     si,5ABh
loc_72:
                mov     di,0F3Bh
                lodsb                           ; String [si] to al
                mov     cl,al
                mov     dx,8
                sub     dx,cx
                mov     ax,[bx+2]
                sub     ax,[bx]
                cmp     ax,0Ah
                jne     loc_73                  ; Jump if not equal
                inc     dx
                inc     dx
                call    sub_11
                inc     bx
                inc     bx
                jmp     short loc_75
loc_73:
                call    sub_9
                call    sub_11
                mov     dx,di
                sub     dx,0F38h
                add     dx,[bx]
                mov     al,0E9h
                stosb                           ; Store al to es:[di]
                inc     bx
                inc     bx
                mov     ax,[bx]
                sub     ax,dx
                cmp     ax,7Eh
                jg      loc_74                  ; Jump if >
                cmp     ax,0FF7Fh
                jl      loc_74                  ; Jump if <
                inc     ax
                mov     byte ptr [di-1],0EBh
                stosb                           ; Store al to es:[di]
                jmp     short loc_75
loc_74:
                stosw                           ; Store ax to es:[di]
loc_75:
                push    bx
                push    cx
                mov     cx,0
                mov     dx,1E26h
                add     dx,[bx-2]
                adc     cx,0
                push    cx
                push    dx
                call    sub_21
                mov     cx,0Ah
                mov     dx,0A4h
                add     word ptr ds:[74Ah],cx
                call    sub_19
                pop     dx
                pop     cx
                jc      loc_76                  ; Jump if carry Set
                call    sub_21
                xchg    cx,di
                mov     dx,0F3Bh
                sub     cx,dx
;*              call    sub_18                  ;*
                db      0E8h, 6Bh, 01h          ;  Fixup - byte match
loc_76:
                pop     cx
                pop     bx
                jc      loc_ret_77              ; Jump if carry Set
;*              cmp     bx,3Eh
                db       81h,0FBh, 3Eh, 00h     ;  Fixup - byte match
                jnc     loc_ret_77              ; Jump if carry=0
                jmp     loc_72

loc_ret_77:
                retn
sub_13          endp

                                                ;* No entry point to code
                mov     cx,0DD8h
                xor     dx,dx                   ; Zero register
                call    sub_14
                mov     ah,40h                  ; '@'
                mov     bx,ds:data_107e
                pushf                           ; Push flags
                call    far ptr $-881h
                jc      loc_78                  ; Jump if carry Set
                cmp     ax,cx
loc_78:
                pushf                           ; Push flags
                call    sub_14
                popf                            ; Pop flags
                retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14          proc    near
                push    cx
                mov     si,dx
                mov     ax,0
                mov     cx,0DD8h

locloop_79:
                xor     [si],ax
                add     ax,0
                inc     si
                loop    locloop_79              ; Loop if cx > 0

                pop     cx
                retn
sub_14          endp

                db      0B0h, 03h,0CFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_15          proc    near
                pushf                           ; Push flags
                call    dword ptr cs:data_105e
                retn
sub_15          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16          proc    near
                push    cx
                push    dx
                shr     cl,1                    ; Shift w/zeros fill
                shr     cl,1                    ; Shift w/zeros fill
                and     dh,0C0h
                or      dh,cl
                mov     cl,4
                shr     dh,cl                   ; Shift w/zeros fill
                mov     dl,ch
                xchg    si,dx
                pop     dx
                pop     cx
                retn
sub_16          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17          proc    near
                push    ax
                push    bx
                push    cx
                mov     al,0
                mov     bx,data_20e
loc_80:
                mov     cx,100h

locloop_81:
                xor     word ptr es:[bx],2B28h
                inc     bx
                inc     bx
                loop    locloop_81              ; Loop if cx > 0

                dec     al
                jnz     loc_80                  ; Jump if not zero
                pop     cx
                pop     bx
                pop     ax
                retn
sub_17          endp

                                                ;* No entry point to code
                cmp     ah,2
                je      loc_82                  ; Jump if equal
                cmp     ah,3
                je      loc_82                  ; Jump if equal
                jmp     loc_97
loc_82:
                cmp     dx,80h
                jne     loc_91                  ; Jump if not equal
                test    cx,0FFC0h
                jnz     loc_91                  ; Jump if not zero
                push    bx
                push    dx
                push    si
                push    di
                push    cx
                push    cx
                mov     si,ax
                and     si,0FFh
                mov     di,si
                mov     al,1
                push    ax
                jz      loc_86                  ; Jump if zero
                jcxz    loc_90                  ; Jump if cx=0
                cmp     cl,1
                je      loc_88                  ; Jump if equal
loc_83:
                cmp     cl,11h
                ja      loc_90                  ; Jump if above
                cmp     cl,0Ah
                jb      loc_89                  ; Jump if below
                cmp     ah,3
                je      loc_90                  ; Jump if equal
                push    bx
                mov     cx,200h

locloop_84:
                mov     byte ptr es:[bx],0
                inc     bx
                loop    locloop_84              ; Loop if cx > 0

                pop     bx
loc_85:
                add     bx,200h
                pop     ax
                pop     cx
                inc     cx
                push    cx
                push    ax
                dec     si
                jnz     loc_83                  ; Jump if not zero
loc_86:
                clc                             ; Clear carry flag
loc_87:
                pop     ax
                pushf                           ; Push flags
                xchg    di,ax
                sub     ax,si
                popf                            ; Pop flags
                mov     ah,ch
                pop     cx
                pop     cx
                pop     di
                pop     si
                pop     dx
                pop     bx
                retf    2                       ; Return far
loc_88:
                mov     cl,byte ptr cs:[0E7Fh]
loc_89:
                call    sub_15
                mov     ch,ah
                jc      loc_87                  ; Jump if carry Set
                jmp     short loc_85
loc_90:
                stc                             ; Set carry flag
                mov     ch,0BBh
                jmp     short loc_87
loc_91:
                cmp     dl,80h
                jne     loc_97                  ; Jump if not equal
                push    ax
                push    cx
                push    dx
                push    si
                push    ds
                push    cs
                pop     ds
                mov     byte ptr ds:[0E2Dh],0
                mov     word ptr ds:[0E2Fh],bx
                call    sub_16
                and     cl,3Fh                  ; '?'
                and     dh,3Fh                  ; '?'
loc_92:
                or      al,al                   ; Zero ?
                jz      loc_95                  ; Jump if zero
                cmp     si,332h
                jae     loc_95                  ; Jump if above or =
                cmp     si,1234h
                jb      loc_93                  ; Jump if below
                inc     byte ptr ds:[0E2Dh]
                jmp     short loc_94
loc_93:
                add     word ptr ds:[0E2Fh],200h
loc_94:
                dec     al
                inc     cl
                cmp     cl,11h
                jbe     loc_92                  ; Jump if below or =
                mov     cl,1
                inc     dh
                cmp     dh,5
                jbe     loc_92                  ; Jump if below or =
                xor     dh,dh                   ; Zero register
                inc     si
                jmp     short loc_92
loc_95:
                cmp     byte ptr ds:[0E2Dh],0
                pop     ds
                pop     si
                pop     dx
                pop     cx
                pop     ax
                jz      loc_97                  ; Jump if zero
                cmp     ah,2
                je      loc_96                  ; Jump if equal
                call    sub_17
loc_96:
                call    sub_15
                pushf                           ; Push flags
                call    sub_17
                popf                            ; Pop flags
                retf    2                       ; Return far
loc_97:
;*              jmp     far ptr loc_3           ;*
                db      0EAh
                dw      40B4h, 2EBh             ;  Fixup - byte match

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_19          proc    near
                mov     ah,3Fh                  ; '?'
                call    sub_24
                jc      loc_ret_98              ; Jump if carry Set
                cmp     ax,cx

loc_ret_98:
                retn
sub_19          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_20          proc    near
                xor     cx,cx                   ; Zero register
                mov     dx,cx

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_21:
                mov     ax,4200h
                jmp     short loc_99

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_22:
                xor     cx,cx                   ; Zero register
                mov     dx,cx

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_23:
                mov     ax,4202h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_24:
loc_99:
                mov     bx,cs:data_107e

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_25:
                pushf                           ; Push flags
                cli                             ; Disable interrupts
                call    dword ptr cs:[0DE8h]
                retn
sub_20          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_26          proc    near
                mov     bp,sp
                mov     ax,5700h
                call    sub_24
                mov     bx,data_111e
                mov     [bx],cx
                mov     [bx+2],dx
                call    sub_31
                jc      loc_102                 ; Jump if carry Set
                mov     dx,1Eh
                call    sub_9
                or      dx,dx                   ; Zero ?
                jz      loc_100                 ; Jump if zero
                mov     [bx],ax
loc_100:
                mov     word ptr ds:[74Ah],40h
                mov     dx,0FFFFh
                push    dx
                call    sub_9
                mov     word ptr ds:[5B7h],dx
                mov     word ptr ds:[0DFAh],dx
                pop     dx
                call    sub_9
                mov     word ptr ds:[5BFh],dx
                mov     word ptr ds:[0E02h],dx
                call    sub_20
                mov     cx,1Ah
                mov     dx,0F45h
                push    dx
                call    sub_19
                jc      loc_104                 ; Jump if carry Set
                xchg    si,dx
                mov     di,data_23e
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                call    sub_22
                mov     si,ax
                mov     di,dx
                pop     bx
                cmp     word ptr [bx],4D5Ah
                je      loc_101                 ; Jump if equal
                cmp     word ptr [bx],5A4Dh
                je      loc_101                 ; Jump if equal
                mov     byte ptr ds:data_27e,0
                cmp     ax,0EFA6h
                cmc                             ; Complement carry
                jc      loc_104                 ; Jump if carry Set
                mov     ax,3
                cwd                             ; Word to double word
                push    bx
                jmp     short loc_103
loc_101:
                mov     byte ptr ds:data_27e,1
                mov     ax,[bx+4]
                mul     word ptr ds:data_42e    ; ax = data * ax
                sub     ax,si
                sbb     dx,di
loc_102:
                jc      loc_104                 ; Jump if carry Set
                mov     ax,[bx+8]
                mul     word ptr ds:data_40e    ; ax = data * ax
                push    bx
                push    ax
                push    dx
loc_103:
                sub     si,ax
                sbb     di,dx
                or      di,di                   ; Zero ?
                jnz     loc_105                 ; Jump if not zero
                mov     dx,si
                sub     dx,3E8h
loc_104:
                jc      loc_110                 ; Jump if carry Set
                cmp     dx,7D0h
                jbe     loc_106                 ; Jump if below or =
loc_105:
                mov     dx,7D0h
loc_106:
                call    sub_9
                add     dx,3E8h
                mov     word ptr ds:[5B3h],dx
                add     dx,1058h
                cmp     byte ptr ds:data_27e,0
                je      loc_107                 ; Jump if equal
                mov     ds:data_108e,dx
loc_107:
                add     dx,0FD80h
                mov     word ptr ds:[5C6h],dx
                add     dx,0F577h
                mov     ds:data_33e,dx
                add     dx,0FCA8h
                mov     data_76,dx
                add     dx,8
                not     dx
                mov     cx,0FFFFh
                call    sub_23
                mov     word ptr ds:[736h],dx
                mov     word ptr ds:[739h],ax
                cmp     byte ptr ds:data_27e,0
                jne     loc_108                 ; Jump if not equal
                xchg    dx,ax
                add     dx,100h
                jmp     short loc_109
loc_108:
                pop     di
                pop     si
                sub     ax,si
                sbb     dx,di
                div     word ptr ds:data_40e    ; ax,dxrem=dx:ax/data
loc_109:
                add     word ptr ds:[5B3h],dx
                add     word ptr ds:[5C6h],dx
                push    ax
                push    dx
                call    sub_13
loc_110:
                jc      loc_115                 ; Jump if carry Set
                pop     dx
                pop     ax
                mov     cx,0Ah
                mov     si,data_30e

locloop_111:
                add     [si],dx
                inc     si
                inc     si
                loop    locloop_111             ; Loop if cx > 0

                pop     bx
                cmp     byte ptr ds:data_27e,0
                jne     loc_112                 ; Jump if not equal
                mov     byte ptr [bx],0E9h
                mov     ax,ds:data_30e
                sub     ax,103h
                mov     [bx+1],ax
                mov     word ptr ds:data_25e,0
                mov     word ptr ds:data_29e,0FFF0h
                mov     word ptr ds:data_28e,100h
                jmp     short loc_114
loc_112:
                mov     [bx+16h],ax
                mov     [bx+0Eh],ax
                mov     ax,ds:data_30e
                mov     [bx+14h],ax
                add     [bx+10h],dx
                mov     word ptr [bx+6],0
                mov     ax,28h
                cmp     [bx+0Ah],ax
                jae     loc_113                 ; Jump if above or =
                mov     [bx+0Ah],ax
loc_113:
                cmp     [bx+0Ch],ax
                jae     loc_114                 ; Jump if above or =
                mov     [bx+0Ch],ax
loc_114:
                push    bx
                call    sub_22
                call    sub_34
loc_115:
                jc      loc_117                 ; Jump if carry Set
                call    sub_22
                div     word ptr ds:data_42e    ; ax,dxrem=dx:ax/data
                inc     ax
                pop     bx
                cmp     byte ptr ds:data_27e,0
                je      loc_116                 ; Jump if equal
                mov     [bx+4],ax
                mov     [bx+2],dx
loc_116:
                push    bx
                call    sub_20
                mov     cx,1Ah
                pop     dx
;*              call    sub_18                  ;*
                db      0E8h, 30h,0FEh          ;  Fixup - byte match
                jc      loc_117                 ; Jump if carry Set
                mov     ax,5701h
                mov     cx,ds:data_111e
                mov     dx,ds:data_112e
                call    sub_24
loc_117:
                mov     sp,bp
                retn
sub_26          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_27          proc    near
                push    dx
                push    ds
                push    cs
                pop     ds
                mov     ax,3524h
                call    sub_25
                mov     word ptr ds:data_109e+2,es
                mov     ds:data_109e,bx
                mov     ax,2524h
                mov     dx,0E09h
                call    sub_25
                pop     ds
                pop     dx
                retn
sub_27          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_28          proc    near
                mov     ax,2524h
                lds     dx,dword ptr cs:data_109e       ; Load 32 bit ptr
                call    sub_25
                retn
sub_28          endp

                                                ;* No entry point to code
                add     al,2Eh                  ; '.'
                inc     bx
                dec     di
                dec     bp
                add     al,2Eh                  ; '.'
                inc     bp
                pop     ax
                inc     bp
                add     al,53h                  ; 'S'
                inc     bx
                inc     cx
                dec     si
                add     ax,4C43h
                inc     bp
                inc     cx
                dec     si
                or      [bp+49h],al
                dec     si
                inc     sp
                push    si
                dec     cx
                push    dx
                push    bp
                add     ax,5547h
                inc     cx
                push    dx
                inc     sp
                add     cx,[bp+4Fh]
                inc     sp
                add     ax,5356h
                inc     cx
                inc     si
                inc     bp
                add     al,4Dh                  ; 'M'
                push    bx
                inc     cx
                push    si
                push    es
                inc     bx
                dec     ax
                dec     bx
                inc     sp
                push    bx
                dec     bx

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_29          proc    near
                push    dx
                push    bx
                push    cx
                push    si
                push    di
                push    ds
                push    es
                push    ax
                mov     si,dx
                mov     di,data_114e
                push    cs
                pop     es
                lea     bx,[di-1]               ; Load effective addr
                mov     cx,4Bh

locloop_118:
                lodsb                           ; String [si] to al
                cmp     al,61h                  ; 'a'
                jb      loc_119                 ; Jump if below
                cmp     al,7Ah                  ; 'z'
                ja      loc_119                 ; Jump if above
                sub     al,20h                  ; ' '
loc_119:
                push    ax
                push    si
loc_120:
                cmp     al,20h                  ; ' '
                jne     loc_121                 ; Jump if not equal
                lodsb                           ; String [si] to al
                or      al,al                   ; Zero ?
                jnz     loc_120                 ; Jump if not zero
                pop     si
                pop     si
                jmp     short loc_123
loc_121:
                pop     si
                pop     ax
                cmp     al,5Ch                  ; '\'
                je      loc_122                 ; Jump if equal
                cmp     al,2Fh                  ; '/'
                je      loc_122                 ; Jump if equal
                cmp     al,3Ah                  ; ':'
                jne     loc_123                 ; Jump if not equal
loc_122:
                mov     bx,di
loc_123:
                stosb                           ; Store al to es:[di]
                or      al,al                   ; Zero ?
                jz      loc_124                 ; Jump if zero
                loop    locloop_118             ; Loop if cx > 0

loc_124:
                mov     si,0ADCh
                sub     di,5
                push    cs
                pop     ds
                call    sub_30
                jz      loc_125                 ; Jump if zero
                call    sub_30
                jnz     loc_129                 ; Jump if not zero
loc_125:
                pop     ax
                push    ax
                xchg    di,bx
                inc     di
                cmp     ax,4B00h
                jne     loc_126                 ; Jump if not equal
                mov     si,0B0Fh
                call    sub_30
                jnz     loc_126                 ; Jump if not zero
                mov     byte ptr ds:[0C6Ah],2Dh ; '-'
loc_126:
                mov     cx,7
                mov     si,0AE6h

locloop_127:
                push    cx
                call    sub_30
                pop     cx
                jz      loc_129                 ; Jump if zero
                loop    locloop_127             ; Loop if cx > 0

                mov     si,data_114e
                xor     bl,bl                   ; Zero register
                lodsw                           ; String [si] to ax
                cmp     ah,3Ah                  ; ':'
                jne     loc_128                 ; Jump if not equal
                sub     al,40h                  ; '@'
                mov     bl,al
loc_128:
                mov     ax,4408h
                call    sub_25
                or      ax,ax                   ; Zero ?
                jz      loc_131                 ; Jump if zero
                mov     ax,4409h
                call    sub_25
                jc      loc_129                 ; Jump if carry Set
                test    dh,10h
                jnz     loc_131                 ; Jump if not zero
loc_129:
                stc                             ; Set carry flag
loc_130:
                pop     ax
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     cx
                pop     bx
                pop     dx
                retn
loc_131:
                clc                             ; Clear carry flag
                jmp     short loc_130
sub_29          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_30          proc    near
                push    di
                lodsb                           ; String [si] to al
                mov     cl,al
                mov     ax,si
                add     ax,cx
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                mov     si,ax
                pop     di
                retn
sub_30          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_31          proc    near
                push    dx
                mov     ax,es:[bx+2]
                xor     dx,dx                   ; Zero register
                div     word ptr cs:data_41e    ; ax,dxrem=dx:ax/data
                mov     ax,es:[bx]
                and     al,1Fh
                cmp     al,dl
                stc                             ; Set carry flag
                jz      loc_132                 ; Jump if zero
                mov     ax,es:[bx]
                and     ax,0FFE0h
                or      al,dl
                clc                             ; Clear carry flag
loc_132:
                pop     dx
                retn
sub_31          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_32          proc    near
                sub     word ptr es:[bx],0DD8h
                sbb     word ptr es:[bx+2],0
                jnc     loc_ret_133             ; Jump if carry=0
                add     word ptr es:[bx],0DD8h
                adc     word ptr es:[bx+2],0

loc_ret_133:
                retn
sub_32          endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_33          proc    near
                push    ax
                push    bx
                push    cx
                push    si
                push    di
                push    bp
                push    ds
                push    es
                call    sub_27
                mov     ax,4300h
                call    sub_25
                mov     word ptr cs:[0C4Ch],cx
                mov     ax,4301h
                xor     cx,cx                   ; Zero register
                call    sub_25
                jc      loc_135                 ; Jump if carry Set
                mov     ax,3D02h
                call    sub_25
                jc      loc_134                 ; Jump if carry Set
                push    dx
                push    ds
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     ds:data_107e,ax
                call    sub_26
                mov     ah,3Eh                  ; '>'
                call    sub_24
                pop     ds
                pop     dx
loc_134:
                mov     ax,4301h
                mov     cx,20h
                call    sub_25
loc_135:
                call    sub_28
                pop     es
                pop     ds
                pop     bp
                pop     di
                pop     si
                pop     cx
                pop     bx
                pop     ax
                retn
sub_33          endp

                                                ;* No entry point to code
                pushf                           ; Push flags
                sti                             ; Enable interrupts
                cmp     ah,11h
                je      loc_136                 ; Jump if equal
                cmp     ah,12h
                jne     loc_139                 ; Jump if not equal
loc_136:
                jmp     short $+2               ; delay for I/O
                push    bx
                push    es
                push    ax
                mov     ah,2Fh                  ; '/'
                call    sub_25
                pop     ax
                call    sub_25
                cmp     al,0FFh
                je      loc_138                 ; Jump if equal
                push    ax
                cmp     byte ptr es:[bx],0FFh
                jne     loc_137                 ; Jump if not equal
                add     bx,7
loc_137:
                add     bx,17h
                call    sub_31
                pop     ax
                jnc     loc_138                 ; Jump if carry=0
                add     bx,6
                call    sub_32
loc_138:
                pop     es
                pop     bx
                popf                            ; Pop flags
                iret                            ; Interrupt return
loc_139:
                cmp     ah,4Eh                  ; 'N'
                je      loc_140                 ; Jump if equal
                cmp     ah,4Fh                  ; 'O'
                jne     loc_143                 ; Jump if not equal
loc_140:
                push    bx
                push    es
                push    ax
                mov     ah,2Fh                  ; '/'
                call    sub_25
                pop     ax
                call    sub_25
                jc      loc_142                 ; Jump if carry Set
                push    ax
                add     bx,16h
                call    sub_31
                pop     ax
                jnc     loc_141                 ; Jump if carry=0
                add     bx,4
                call    sub_32
loc_141:
                pop     es
                pop     bx
                popf                            ; Pop flags
                clc                             ; Clear carry flag
                retf    2                       ; Return far
loc_142:
                pop     es
                pop     bx
                popf                            ; Pop flags
                stc                             ; Set carry flag
                retf    2                       ; Return far
loc_143:
                cmp     ax,4B53h
                jne     loc_144                 ; Jump if not equal
                mov     ax,454Bh
                popf                            ; Pop flags
                iret                            ; Interrupt return
loc_144:
                cmp     ah,4Ch                  ; 'L'
                jne     loc_145                 ; Jump if not equal
                mov     byte ptr cs:[0C6Ah],0
loc_145:
                cld                             ; Clear direction
                push    dx
                cmp     ax,4B00h
                jne     loc_149                 ; Jump if not equal
                jmp     short loc_148
                                                ;* No entry point to code
                push    ax
                push    bx
                push    ds
                push    es
                mov     ah,52h                  ; 'R'
                call    sub_25
                mov     ax,es:[bx-2]
loc_146:
                mov     ds,ax
                add     ax,ds:data_19e
                inc     ax
                cmp     byte ptr ds:data_18e,5Ah        ; 'Z'
                jne     loc_146                 ; Jump if not equal
                mov     bx,cs
                cmp     ax,bx
                jne     loc_147                 ; Jump if not equal
                mov     byte ptr ds:data_18e,4Dh        ; 'M'
                xor     ax,ax                   ; Zero register
                mov     ds,ax
                add     word ptr ds:main_ram_size_,4
loc_147:
                mov     byte ptr cs:[0CEBh],39h ; '9'
                pop     es
                pop     ds
                pop     bx
                pop     ax
loc_148:
                jmp     short loc_153
loc_149:
                cmp     ah,3Dh                  ; '='
                je      loc_153                 ; Jump if equal
                cmp     ah,56h                  ; 'V'
                je      loc_153                 ; Jump if equal
                cmp     ax,6C00h
                jne     loc_150                 ; Jump if not equal
                test    dl,12h
                mov     dx,si
                jz      loc_153                 ; Jump if zero
                jmp     short loc_154
loc_150:
                cmp     ah,3Ch                  ; '<'
                je      loc_154                 ; Jump if equal
                cmp     ah,5Bh                  ; '['
                je      loc_154                 ; Jump if equal
                cmp     ah,3Eh                  ; '>'
                jne     loc_152                 ; Jump if not equal
                cmp     bx,cs:data_113e
                jne     loc_152                 ; Jump if not equal
                or      bx,bx                   ; Zero ?
                jz      loc_152                 ; Jump if zero
                call    sub_25
                jc      loc_155                 ; Jump if carry Set
                push    ds
                push    cs
                pop     ds
                mov     dx,0F69h
                call    sub_33
                mov     word ptr ds:data_113e,0
                pop     ds
loc_151:
                pop     dx
                popf                            ; Pop flags
                clc                             ; Clear carry flag
                retf    2                       ; Return far
loc_152:
                pop     dx
                popf                            ; Pop flags
                jmp     dword ptr cs:[0DE8h]
loc_153:
                call    sub_29
                jc      loc_152                 ; Jump if carry Set
                call    sub_33
                jmp     short loc_152
loc_154:
                cmp     word ptr cs:data_113e,0
                jne     loc_152                 ; Jump if not equal
                call    sub_29
                jc      loc_152                 ; Jump if carry Set
                mov     word ptr cs:[0D9Dh],dx
                pop     dx
                push    dx
                call    sub_25
                mov     dx,705Ah
                jnc     loc_156                 ; Jump if carry=0
loc_155:
                pop     dx
                popf                            ; Pop flags
                stc                             ; Set carry flag
                retf    2                       ; Return far
loc_156:
                push    cx
                push    si
                push    di
                push    es
                xchg    si,dx
                mov     di,data_113e
                push    cs
                pop     es
                stosw                           ; Store ax to es:[di]
                mov     cx,4Bh
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                pop     es
                pop     di
                pop     si
                pop     cx
                jmp     short loc_151
                db      'Did you leave the room ?'
                db      0E9h, 04h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_34          proc    near
                cli                             ; Disable interrupts
                xor     ax,ax                   ; Zero register
                mov     ss,ax
                mov     sp,7C00h
                mov     si,sp
                push    ax
                pop     es
                push    ax
                pop     ds
                sti                             ; Enable interrupts
                cld                             ; Clear direction
                mov     di,data_13e
                mov     cx,100h
                repne   movsw                   ; Rep zf=0+cx >0 Mov [si] to es:[di]
;*              jmp     far ptr loc_2           ;*
sub_34          endp

                db      0EAh
                dw      61Dh, 0                 ;  Fixup - byte match
                                                ;* No entry point to code
                mov     si,data_14e
                mov     bl,4
                cmp     byte ptr [si],80h
;*              je      loc_157                 ;*Jump if equal
                db       74h, 0Eh               ;  Fixup - byte match
                add     byte ptr [bx+si],0

seg_a           ends



                end     start
