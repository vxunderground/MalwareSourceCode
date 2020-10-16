;                                                     ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;   ÚÄ Benny's Compression Engine for Win32 Ä¿        ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;   ³                   by                   ³         ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ Benny / 29A ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                     ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
;
;
;Hello everybody,
;
;let me introduce my second compression engine for Win32 enviroment (u can
;find my first engine in Win32.Benny and Win98.Milennium). This engine
;worx on "compressin' bit groups" base. When I started to write this stuff,
;i wanted to write engine, that would work on Huffmann base. Then I decided
;it's not needed to implement this complicated algorithm here, coz I wanna
;be this engine small and effective.
;
;Not only this is truth. This engine is very fast, very small (only 478 bytes)
;and has implemented my special compression algorithm, that is simple and has
;very, ehrm, let's call it "interesting" compression ratio X-D.
;
;
;
;So how does it work ?
;======================
;
;I said, this engine worx on "compressin' bit groups" base. What does it mean ?
;Bit group (as I call it) is group of two bits. U know, every byte has 8 bits.
;
;Example:       byte 9Ah       group0 group1 group2 group3
;               10011010  ===>   10     10     01     10
;
;As u can see, every byte has 4 bit groups and I said, it compresses
;bit groups. Heh, u think i'm crazy when im tryin' to compress
;two bits, yeah :?)
;
;
;This engine will (on the beginnin') calculate, which bit group has
;the biggest count of repetency, which second biggest, etc...
;
;Example:     group      count
;               00  ===>  74
;               01  ===>  32
;               10  ===>  12
;               11  ===>  26
;
;
;That's not all. It has to sort items to know, which group has the biggest
;count. I decided it's best to use "bubble sort algorithm". Then there isn't
;any problem to use "our algorithm".

;Look at this table, when in first column r sorted groups and in second
;comlumn r <another> bits, which will represent new compressed data.
;
;Sorted by count:       1.  ===>  1
;                       2.  ===>  00
;                       3.  ===>  010
;                       4.  ===>  011
;
;Finally, engine will replace bit groups with these bits.
;Gewd thing on this algorithm is that there aren't needed same bytes to have
;good compression ratio, but only some bits.
;So now u know whole secret of my compression algorithm. U also know, why
;I said, it has "interesting compression ratio". Look at the table and u will
;see, what type of files can we strongly compress. They r both of binaries
;and texts, but not every binaries or texts can be compressed as well as otherz. 
;We can compress some binaries again with the same or better ratio. Why ?
;Imagine, u have file with 1000x 0x0s. After compression we have 125x 0xFFs, that
;can be compressed again. Some files can be after compression (negative even -
;file is bigger) compressed again with positive compression (file is smaller).
;Heh, crazy, isn't it ? X-DDD.
;
;
;
;How can I use BCE32 in my virus ?
;==================================
;
;BCE32 is placed in two procedures called BCE32_Compress and BCE32_Decompress.
;
;
;a) BCE32_Compress:
;-------------------
;Input state:
;	1) ESI register - pointer to data, which will be compressed
;	2) EDI register - pointer to memory, where will be placed compressed data
;	3) ECX register - number of bytes to compress + 1 (do not forget "+ 1" !)
;	4) EBX register - work memory (16 bytes)
;	5) EDX register - work memory (16 bytes). MUST NOT be same as EBX !
;
;	call BCE32_Compress
;
;Output state:
;	1) EAX register - new size of compressed data
;	2) CF set, if negative compression
;	3) Other registers r preserved (except FLAGS)
;
;
;b) BCE32_Decompress:
;---------------------
;Input state:
;	1) ESI register - pointer to compressed data
;	2) EDI register - pointer to memory, where will be placed decompressed data
;	3) ECX register - number of bytes to decompress (EAX value returned by
;			  BCE32_Compress) - 1 (do not forget "- 1" !)
;
;	call BCE32_Decompress
;
;Output state:
;	1) All registers r preserved
;
;
;WARNING: 	Be sure, u have enought memory for case of negative compression.
;NOTE:		U can compress (in some special cases) already compressed data.
;		For this purpose exists output parameters EAX and CF.
;
;
;
;Do u like this (or my another work) ?
;======================================
;
;Gimme know. If u have some notes or commentz for this, for another work,
;or if u simply like it, mail me to benny@post.cz. Thanx.
;
;
;
;Don't u like it ?
;==================
;
;Fuck u.
;
;
;
;(c) by Benny/29A May 1999.




BCE32_Compress	Proc				;compression procedure
	pushad					;save all regs

;stage 1
	pushad					;and again
create_table:
	push ecx				;save for l8r usage
	push 4
	pop ecx					;ECX = 4
	lodsb					;load byte to AL
l_table:push eax				;save it
	xor edx, edx				;EDX = 0
	and al, 3				;this stuff will separate and test
	je st_end				;bit groups
	cmp al, 2
	je st2
	cmp al, 3
	je st3
st1:	inc edx					;01
	jmp st_end
st2:	inc edx					;10
	inc edx
	jmp st_end
st3:	mov dl, 3				;11
st_end:	inc dword ptr [ebx+4*edx]		;increment count in table
	pop eax
	ror al, 2				;next bit group
	loop l_table
	pop ecx					;restore number of bytes
	loop create_table			;next byte

	push 4					;this will check for same numbers
	pop ecx					;ECX = 4
re_t:	cdq					;EDX = 0
t_loop:	mov eax, [ebx+4*edx]			;load DWORD
	inc dword ptr [ebx+4*edx]		;increment it
	cmp eax, [ebx]				;test for same numbers
	je _inc_				;...
	cmp eax, [ebx+4]			;...
	je _inc_				;...
	cmp eax, [ebx+8]			;...
	je _inc_				;...
	cmp eax, [ebx+12]			;...
	jne ninc_				;...
_inc_:	inc dword ptr [ebx+4*edx]		;same, increment it
	inc ecx					;increment counter (check it in next turn)
ninc_:	cmp dl, 3				;table overflow ?
	je re_t					;yeah, once again
	inc edx					;increment offset to table
	loop t_loop				;loop
	popad					;restore regs

;stage 2
	pushad					;save all regs
	mov esi, ebx				;get pointer to table
	push 3
	pop ebx					;EBX = 3
	mov ecx, ebx				;ECX = 3
rep_sort:					;bubble sort = the biggest value will
						;always "bubble up", so we know number
						;steps
	push ecx				;save it
	mov ecx, ebx				;set pointerz
	mov edi, edx				;...
	push edx				;save it
	lodsd					;load DWORD (count)
	mov edx, eax				;save it
sort:	lodsd					;load next
	cmp eax, edx				;is it bigger
	jb noswap				;no, store it
	xchg eax, edx				;yeah, swap DWORDs
noswap:	stosd					;store it
	loop sort				;next DWORD
	mov eax, edx				;biggest in EDX, swap it
	stosd					;and store
	lea esi, [edi-16]			;get back pointer
	pop edx					;restore regs
	pop ecx
	loop rep_sort				;and try next DWORD
	popad

;stage 3
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	push eax				;save it
	push 4
	pop ecx					;ECX = 4
n_search:
	push edx				;save regs
	push ecx
	lea esi, [ebx+4*eax]			;get pointer to table
	push eax				;store reg
	lodsd					;load DWORD to EAX
	push 3
	pop ecx					;ECX = 3
	mov edi, ecx				;set pointerz
search:	mov esi, edx
	push eax				;save it
	lodsd					;load next
	mov ebp, eax
	pop eax
	cmp eax, ebp				;end ?
	je end_search
	dec edi					;next search
	add edx, 4
	loop search
end_search:
	pop eax					;and next step
	inc eax
	pop ecx
	pop edx
	add [esp], edi
	rol byte ptr [esp], 2
	loop n_search
	pop [esp.Pushad_ebx]			;restore all
	popad					;...

;stage 4
	xor ebp, ebp				;EBP = 0
	xor edx, edx				;EDX = 0
	mov [edi], bl				;store decryption key
	inc edi					;increment pointer
next_byte:
	xor eax, eax				;EAX = 0
	push ecx
	lodsb					;load next byte
	push 4
	pop ecx					;ECX = 4
next_bits:
	push ecx				;store regs
	push eax
	and al, 3				;separate bit group

	push ebx				;compare with next group
	and bl, 3
	cmp al, bl
	pop ebx
	je cb0

	push ebx				;compare with next group
	ror bl, 2
	and bl, 3
	cmp al, bl
	pop ebx
	je cb1

	push ebx				;compare with next group
	ror bl, 4
	and bl, 3
	cmp al, bl
	pop ebx
	je cb2

	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	call copy_bit
cb0:	push 1					;store bit 1
end_cb1:call copy_bit
	pop eax
	pop ecx
	ror al, 2
	loop next_bits				;next bit
	pop ecx
	loop next_byte				;next byte
	mov eax, edi				;save new size
	sub eax, [esp.Pushad_edi]		;...
	mov [esp.Pushad_eax], eax		;...
	popad					;restore all regs
	cmp eax, ecx				;test for negative compression
	jb c_ok					;positive compression
	stc					;clear flag
	ret					;and quit
c_ok:	clc					;negative compression, set flag
	ret					;and quit
cb1:	push 0					;store bit 0
end_cb2:call copy_bit
	push 0					;store bit 0
	jmp end_cb1
cb2:	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	jmp end_cb2
copy_bit:
	mov eax, ebp				;get byte from EBP
	shl al, 1				;make space for next bit
	or al, [esp+4]				;set bit
cbit:	inc edx					;increment counter
	cmp dl, 8				;byte full ?
	jne n_byte				;no, continue
	stosb					;yeah, store byte
	xor eax, eax				;and prepare next one
	cdq					;...
n_byte:	mov ebp, eax				;save back byte
	ret Pshd		;quit from procedure with one parameter on stack
	db	'[BCE32]', 0			;little signature
BCE32_Compress	EndP				;end of compression procedure



BCE32_Decompress	Proc			;decompression procedure
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	xor ebp, ebp				;EBP = 0
	cdq					;EDX = 0

	lodsb					;load decryption key
	push eax				;store it
	lodsb					;load first byte
	push 8					;store 8
	push edx				;store 0
d_bits:	push ecx				;store ECX

	test al, 80h				;test for 1
	jne db0
	test al, 0c0h				;test for 00
	je db1
	test al, 0a0h				;test for 010
	je db2
	mov cl, 6				;its 011
	jmp tb2

testb:	test bl, 1				;is it 1 ?
	jne p1
	push 0					;no, store 0
_tb_:	mov eax, ebp				;load byte to EAX
	or al, [esp]				;set bit
	ror al, 1				;and make space for next one
	call cbit				;end of procedure
	ret					;...
p1:	push 1					;store 1
	jmp _tb_				;and continue

db0:	xor cl, cl				;CL = 0
	mov byte ptr [esp+4], 1			;store 1
testbits:
	push eax				;store it
	push ebx				;...
	mov ebx, [esp+20]			;load parameter
	ror bl, cl				;shift to next bit group
	call testb				;test bit
	ror bl, 1				;next bit
	call testb				;test it
	pop ebx					;restore regs
	pop eax

	mov ecx, [esp+4]			;load parameter
bcopy:	cmp byte ptr [esp+8], 8			;8. bit ?
	jne dnlb				;nope, continue
	mov ebx, eax				;load next byte
	lodsb
	xchg eax, ebx
	mov byte ptr [esp+8], 0			;and nulify parameter
	dec dword ptr [esp]			;decrement parameter
dnlb:	shl al, 1				;next bit
	test bl, 80h				;is it 1 ?
	je nb					;no, continue
	or al, 1				;yeah, set bit
nb:	rol bl, 1				;next bit
	inc byte ptr [esp+8]			;increment parameter
	loop bcopy				;and align next bits
	pop ecx					;restore ECX
	inc ecx					;test flags
	dec ecx					;...
	jns d_bits				;if not sign, jump

	pop eax					;delete pushed parameters
	pop eax					;...
	pop eax					;...
	popad					;restore all regs
	ret					;and quit

db1:	mov cl, 2				;2. bit in decryption key
	mov [esp+4], cl				;2 bit wide
	jmp testbits				;test bits
db2:	mov cl, 4				;4. bit
tb2:	mov byte ptr [esp+4], 3			;3 bit wide
	jmp testbits				;test bits
BCE32_Decompress	EndP			;end of decompression procedure
