; Date		: 27-1-1989
; Ver		: 1.04
; Program	: Kill the Brain Virus
Cseg		Segment Para Public 'MyCode'
		Assume	cs:Cseg,ds:Cseg
		Org	100h
Start:		Mov	dx,offset CRight	;print copyright notice
		Call	DispStr
		Mov	ah,19h			;get current drive
		Int	21h
		Mov	Drive,al		;save it
		Call	GetDrive		;Get drive if possible
		Jc	Exit
		Call	ChVirus 		;virus present?
		Jc	Exit			;exit if not
		Call	FindBoot		;Find correct boot sector
		Mov	dx,offset VirusKill
		Call	DispStr
		Call	ReadFats		;Read the FAT tables
		Jc	Exit
		Call	CheckBad
Exit:		Mov	ax,4C00h
		Int	21h
FindBoot	Proc
		Mov	dl,[si+6]
		Mov	ax,18			;9 sectors/track * 2 sides
		Mov	cl,[si+8]
		Mul	cl
		Or	dl,dl
		Jz	Fb1
		Add	ax,10			;Move to the next side
Fb1:		Mov	dx,ax			;read this sector
		Mov	cx,1			;Read one sector
		Mov	bx,offset PrgEnd	;Read it here
		Mov	al,Drive		;Get drive number
		Int	25h			;Read interrupt
		Jnc	Fb2
		Add	sp,2
		Mov	dx,offset MesOh1
		Call	DispStr
		Stc
		Ret
Fb2:		Add	sp,2
		Xor	dx,dx			;Write at boot
		Mov	cx,1			;Write one sector
		Mov	bx,offset PrgEnd	;Write from here
		Mov	al,Drive		;Get drive number
		Int	26h			;Write interrupt
		Jnc	Fb3
		Add	sp,2
		Mov	dx,offset MesOh2	;Print message
		Call	DispStr
		Stc
		Ret
Fb3:		Add	sp,2
		Clc
		Ret
FindBoot	Endp
PointTo 	Proc
		Push	bx
		Mov	dx,ax
		Add	ax,ax
		Add	ax,dx
		Mov	dx,ax
		Shr	ax,1			;Cluster * 1.5
		Mov	bx,offset PrgEnd
		Add	bx,ax
		Mov	ax,ds:[bx]		;Get entry
		Test	dx,1
		Jnz	Point1
		And	ax,0FFFh
		Jmp	short Point0
Point1: 	Shr	ax,1
		Shr	ax,1
		Shr	ax,1
		Shr	ax,1
Point0: 	Pop	bx
		Ret
PointTo 	Endp
ReadFats	Proc
		Mov	bx,offset PrgEnd
		Mov	al,Drive
		Mov	cx,4			;read FAT1 and FAT2
		Mov	dx,1			;FAT sectors
		Int	25h			;Read FAT tables
		Jnc	Rf1
		Add	sp,2
		Mov	dx,offset FatError
		Call	DispStr
		Stc
		Ret
Rf1:		Add	sp,2
		Clc
		Ret
ReadFats	Endp

CheckBad	Proc
		Call	FindBad 		;Find real boot sector
		Call	WriteFats
Exit1:		Ret
CheckBad	Endp
FindBad 	Proc
		Mov	cx,354			;Check 354 clusters
		Mov	ax,2			;start with cluster 2
		Mov	bx,ax
FM:		Call	PointTo 		;Find where it points
		Cmp	ax,0FF7h		;Is it bad?
		Jz	ChkBd			;Check if realy bad
FindMore1:	Inc	bx
		Mov	ax,bx
		Loop	FM
		Ret
ChkBd:		Push	ax
		Call	CheckCluster		;bx=cluster number, try to read
		Pop	ax
		Jmp	short FindMore1
FindBad 	Endp
WriteFats	Proc
		Mov	bx,offset PrgEnd
		Mov	al,Drive
		Mov	cx,4			;FAT1 and FAT2
		Mov	dx,1			;Start of FAT sectors
		Int	26h			;Write FAT tables
		Jnc	Wf1			;Jump if not fail
		Add	sp,2
		Mov	dx,offset MesOh3	;Write error
		Call	DispStr
		Stc
		Ret
Wf1:		Add	sp,2
		Clc
		Ret
WriteFats	Endp
CheckCluster	Proc
		Push	bx
		Push	cx
		Sub	bx,2
		Sal	bx,1
		Add	bx,12			;bx=sector number
		Mov	dx,bx			;sector
		Mov	cx,2			;2 sectors
		Mov	bx,offset PrgEnd+205
		Mov	al,Drive
		Int	25h			;Read sectors
		Jnc	QRc1
		Add	sp,2
		Mov	al,2			;err 2=try more
		Pop	cx
		Pop	bx
		Ret
QRc1:		Add	sp,2
		Pop	cx
		Pop	bx			;Mark cluster bx as not bad
		Mov	ax,bx
		Push	bx
		Mov	dx,ax
		Add	ax,ax
		Add	ax,dx
		Mov	dx,ax
		Shr	ax,1			;Cluster * 1.5
		Mov	bx,offset PrgEnd
		Add	bx,ax
		Mov	ax,ds:[bx]		;Get entry
		Test	dx,1
		Jnz	QPo1
		And	ax,0F000h
		Jmp	short QPo2
QPo1:		And	ax,000Fh
QPo2:		Mov	ds:[bx],ax		;Write entry to FAT1
		Mov	ds:[bx+1024],ax 	;Write entry to FAT2
		Pop	bx
		Ret
CheckCluster	Endp

ChVirus 	Proc
		Call	ReadBoot		;Read the boot sector
		Jnc	ChVirus1
		Ret
ChVirus1:	Mov	si,offset PrgEnd
		Mov	dx,offset MesBad	;Assume bad news
		Cmp	word ptr [si+4],1234h
		Jz	InThere
		Mov	dx,offset MesGood	;Assume all OK
		Mov	di,436			;Vector of interrupt 13h
		Push	es
		Xor	ax,ax
		Mov	es,ax
		Mov	ax,es:[di+2]		;get segment of the interrupt
		Pop	es
		Cmp	ax,0C800h
		Jb	InThere
		Mov	dx,offset MesBad1	;active now!
		Call	DispStr
		Mov	bx,offset PrgEnd
		Mov	ah,2			;Read
		Mov	al,1			;1 sector
		Mov	dl,Drive
		Xor	dh,dh			;head number
		Xor	ch,ch			;track number
		Mov	cl,1			;sector 1
		Int	6Dh			;Virus uses interrupt 6Dh
		Mov	si,offset PrgEnd
		Mov	dx,offset MesBad
		Cmp	word ptr [si+4],1234h
		Jz	InThere1
		Mov	dx,offset MesGood
		Call	DispStr
		Stc				;No need to do more.
		Ret
InThere:	Call	DispStr
		Clc				;Do more
		Ret
InThere1:	Call	DispStr 		;write bad news
		Mov	dx,offset MesBad2	;No lasting effect
		Jmp	short InThere
ChVirus 	Endp
ReadBoot	Proc
		Mov	bx,offset PrgEnd	;Put it here
		Mov	al,Drive		;Drive to use
		Mov	cx,1			;One sector
		Xor	dx,dx			;Boot sector
		Int	25h			;Read it
		Jnc	P0
		Add	sp,2
		Mov	dx,offset MesBoot
		Cmp	ah,80h			;Time-out?
		Jz	P1
		Mov	dx,offset MesBoot1
P1:		Call	DispStr
		Stc				;Error
		Ret				;Go
P0:		Add	sp,2
		Clc				;No error
		Ret				;Go
ReadBoot	Endp
GetDrive	Proc
		Mov	si,80h
		Mov	cl,[si] 		;Get length of command tail
		Xor	ch,ch
		Or	cx,cx
		Jnz	Lab1
		Cmp	byte ptr Drive,2
		Jae	DriveError1
		Clc
		Ret
Lab1:		Add	si,cx
		Inc	si
		Mov	byte ptr [si],0 	;Command ends with 0
		Mov	si,81h
		Cld
SpOut:		Lodsb
		Cmp	al,32
		Jz	SpOut			;Skip blanks
		Or	al,al
		Jnz	Stan1
		Ret

Stan1:		Lodsb
		Or	al,al
		Jnz	Check1
		Ret
Check1: 	Cmp	al,':'
		Jnz	Stan1
		Cmp	si,84h
DriveCheck:	Jb	DriveError
		Mov	al,[si-2]
		And	al,223			;Convert to upper case
		Cmp	al,'A'
		Jb	DriveError1
		Cmp	al,'B'
		Ja	DriveError1
		Sub	al,65			;Convert drive to 0 or 1
		Mov	Drive,al
		Clc
		Ret
DriveError:	Mov	dx,offset Err8		;Drive expected
		Call	DispStr
		Stc
		Ret
DriveError1:	Mov	dx,offset Err9		;Invalid drive
		Call	DispStr
		Stc
		Ret
GetDrive	Endp
DispStr 	Proc
		Mov	ah,9
		Int	21h
		Ret
DispStr 	Endp

CRight		db	13,10
		db	'Kill the <Brain> virus Ver 1.04, 27-1-1989',13,10
		db	'(C) Fragakis Stelios 1988,1989',13,10,13,10,'$'


Err8		db	'Error 8 : Drive expected.$'
Err9		db	'Error 9 : Invalid drive specified. Must be A or B.$'
MesBoot 	db	13,10
		db	'Program execution aborted. Door open?',13,10,'$'
MesBoot1	db	13,10
		db	'I can not read the boot sector.',13,10
		db	'Disk can not contain the virus <Brain>.',13,10,'$'
FatError	db	13,10
		db	'Sorry, I can not read the FAT tables.',13,10
		db	'FAT corrections not written to disk.',13,10,'$'
VirusKill	db	'Virus <Brain> was successfully killed.',13,10,'$'
MesOh1		db	'DISK ERROR : I can not read the correct boot sector.'
		db	13,10,'$'
MesOh2		db	'Failed to write correct boot sector in boot area.'
		db	13,10,'$'
MesOh3		db	'Failed to write FAT tables. Corrections lost.'
		db	13,10,'$'
MesGood 	db	'Good News : The disk is not <Brain> contaminated.'
		db	13,10,'$'
MesBad		db	'Bad News : The disk is <Brain> contaminated.'
		db	13,10,'$'

MesBad1 	db	'* WARNING *',13,10
		db	'Virus <Brain> is active right now !',13,10,'$'

MesBad2 	db	13,10
		db	'Remove the disk after the virus is killed',13,10
		db	'to avoid the risk of contamination.',13,10,13,10,'$'

Count		db	0			;Count 0..58
Drive		db	0			;Current drive

PrgEnd:
Cseg		Ends
		End	Start
