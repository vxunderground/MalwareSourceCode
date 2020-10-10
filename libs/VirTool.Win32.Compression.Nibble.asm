
; BNCE - BlueOwls Nibble Compression Engine
; *****************************************
; 
;  Introduction
;  ************
;
;  I made this engine for virusses which want to use some algorithm to make
;  themselves  or  something else  smaller  (obviously), but  i  wanted the
;  algorithm to be small too, because if it isn't it would have little  use
;  for virusses. In this case, I tried to make the decompressor as small as 
;  possible, and let the compressor do most of the work.
;
;  How it works
;  ************
;
;  Every byte has 4 nibbles and these can be compressed. The compression is
;  done by counting the number of nibbles  in the entire  data  and  change
;  the  nibble  sizes  accordingly. The most  common  of  the four possible 
;  nibbles will be compressed, #2 will stay the same size and #3 & #4  will
;  be expanded. This means that  as long  as the  number #1s >  the numbers 
;  #3+#4  compression  occurs, otherwise  the  data  will be  expanded. The  
;  maximum reducement is 50%, and the maximum enlargement is 112,5%.
;
;  Notes
;  *****
;
;  - The bnce_compress and bnce_decompress are not in  any way dependent on
;    each other, and both do not use any (external)  data, you can run them
;    without the write flag set.
;  - A  small optimization  is possible  for  the  decryptor if you like to
;    decrypt  only  one thing  with  a static  size with it; remove the (*)
;    lines in the compressor and change the (@) lines in mov ecx, size;
;    or push size, pop  ecx. It  will  save  one  or  three  bytes  in  the
;    decompressor, wow! :P
;  - I have not encounterd any bugs, and  the only errors could arrise from
;    a faulty parameters; too small output buffers  or corrupted compressed
;    data fed to the decompressor. All which are not very likely.
;  - In some extreme cases, already compressed data can be compressed again
;    but this is only possible when the are a lot of same  nibble repeaten-
;    cies; for example: 1111b becomes 00b; and  00b becomes 0b. But it does
;    not occur very often.
;  - As the maximum  enlargement is  112,5%  I would at  least  allocate an
;    output   buffer   of   size   *12 /10   if  the  data  is  not  static.
;
;  Last words
;  **********
;
;  I made this engine for fun and I had fun with it, I hope you like it and
;  can use it in someway. Feel free  to  modify it to your needs. See Notes
;  for more details. Anyway, I  hope you like  it and  if you  like to  let
;  me  know  something  please  do  and  send mail to xblueowl@hotmail.com.

; I compiled this stuff with FASM, but you should be  able to assemble this
; with any popular assembler (MASM/TASM/FASM/NASM?) :).

; compress
; in: esi = ptr to data to compress
;     ecx = size of data to compress
;     edi = ptr to output buffer
; out: edi = end of data put in output buffer
; size: 165 bytes

bnce_compress:	push    03020100h       ; push table
		push	esi
		push	ecx
		sub	eax, eax        ; eax = 0
		cdq		        ; edx = 0
		push	eax	        ; 4 counters for the 4 existing nibbles
		push	eax
		push	eax
		push	eax
count_bytes:	push	ecx	        ; save no. of bytes
		push    4
		pop	ecx	        ; ecx = 4
		lodsb
count_bits:	sub	ah, ah
		shl	eax, 2	        ; ah = first 2 bits
		mov	dl, ah	        ; dl = 2 bits
		inc	dword [esp+4+edx*4] ; count it
		loop	count_bits
		pop	ecx
		loop	count_bytes     ; now the 4 counters are filled with the correct values

sort_again:	sub	ecx, ecx        ; ecx = 0
		mov	esi, esp        ; esi = ptr to first counter
		lodsd		        ; esi = ptr to next counter
no_bubble:	inc	ecx
		cmp	ecx, 4
		jz	sort_done       ; if no changes were made 4 times bubbling is done
		lodsd		        ; eax = this counter; esi = next counter
		cmp     [esi-8], eax    ; compare to previous counter
		jae	no_bubble       ; if previous counter is bigger or equal make no change
		xchg    [esi-8], eax    ; swap counters
		mov     [esi-4], eax
		mov	al, [esp+23+ecx]; swap nibbles
		xchg	al, [esp+24+ecx]
		mov     [esp+23+ecx], al
		jmp	sort_again      ; start over
sort_done:	add	esp, 16         ; delete counters (only nibbles remaining)

		pop	ecx	        ; ecx = size of data
		pop	esi	        ; esi = start of data

		pop	eax	        ; eax = nibble table
		push	eax
		shl	eax, 6	        ; move up table
		stosd		        ; save table

		mov	eax, ecx        ; eax = ecx = size of data (*)
		stosd		        ; save it                  (*)

		sub	edx, edx        ; edx = 0 (bits stored counter)
compress_loop:	push	ecx
		push    4
		pop	ecx	        ; ecx = 4
		lodsb
compress_bits:	sub	ebx, ebx        ; ebx = 0
		sub	ah, ah	        ; ah = 0
		shl	eax, 2	        ; ah = xxb
		inc	ebx	        ; 1 bit large; output is: 0b
		cmp	ah, [esp+0+4]   ; is it main compress byte?
		jz	move_bits
		mov	bh, 10000000b   ; output is: 10b
		inc	ebx	        ; 2 bit large
		cmp	ah, [esp+1+4]
		jz	move_bits
		mov	bh, 11000000b
		inc	ebx	        ; 3 bit large; output is: 110b
		cmp	ah, [esp+2+4]
		jz	move_bits
		mov	bh, 11100000b   ; output is: 111b
move_bits:	shl	dh, 1	        ; get a free bit in dh
		shl	bh, 1	        ; carry on/of
		adc	dh, 0	        ; add it to dh
		inc	edx
		mov     [edi], dh
		cmp	dl, 8
		jnz	no_store_bits
		inc	edi
		sub	edx, edx
no_store_bits:	dec	bl
		jnz	move_bits
		loop	compress_bits
		pop	ecx
		loop	compress_loop

		mov	cl, 8
		sub	cl, dl
		rol	dh, cl	        ; make sure last byte's bits are placed correctly
		mov     [edi], dh
		inc	edi

		pop	eax	        ; table not needed anymore
		ret

; decompress
;
; in: esi = pointer to data to be decompressed
;     edi = pointer to output buffer
; out: edi = pointer to end of output buffer
; size: 54 bytes

bnce_decompress:lodsd
		push	eax	        ; push decoder table
		lodsd			; (@)
		xchg	eax, ecx        ; ecx = size when uncompressed (@)
		mov	dl, 8	        ; indicate new byte needed
decompress_next:push	ecx
		push    4	        ; start byte reconstruction (4 nibbles remaining)
		pop	ecx
decompress_loop:sub	ebx, ebx        ; type = 0
		push	ecx
		push    3	        ; repeat 3 times if necessary
		pop	ecx
find_type:	cmp	dl, 8	        ; next byte needed?
		jnz	dont_fill
		sub	edx, edx        ; clear bit-counter
		lodsb		        ; load new byte
dont_fill:	inc	edx	        ; 1 bit is used from byte
		shl	al, 1	        ; get the bit
		jnc	dmove_bits      ; if it is off, type is found
		inc	ebx	        ; type ++
		loop	find_type       ; repeat
dmove_bits:	pop	ecx	        ; restore ecx (stored bit counter)
		mov	dh, al	        ; save al
		mov	al, [esp+4+ebx] ; get appropiate bits
		shl	eax, 2	        ; add bits to ah
		mov	al, dh	        ; restore al
		loop	decompress_loop ; if byte is not ready to be put, go on
		mov     [edi], ah       ; save byte
		inc	edi	        ; move up ptr
		pop	ecx
		loop	decompress_next ; go on decompressing
		pop	eax
		ret

; BlueOwl 23 august, 2004