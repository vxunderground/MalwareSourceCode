; BLM ~ BlueOwls Light Meta
; *************************
;
; Details
;
;  Name: BLM (BlueOwls Light Meta)
;  Date: 16 May 2005
;  Size: 412 bytes
;  Morphing power: light
;  Morphing type: non-expansion
;  Compatibility: most common x86 and pentium specific (rdtsc/movzx/..)
;  Platforms: all 32bit (and maybe 16bit) x86 instruction set OSes
;  Used compiler: FASM 1.60
;  Bugs: hopefully none
;
; Morphing
;
;  The following instructions can be morphed:
;
;  1. OP reg, reg -> changing the D bit (2)
;  2. OP (reg,) [(imm32+)reg] -> changing the unused SCALE bits (4)
;  3. OP (reg,) [(imm32+)reg+reg*1] -> swapping the regs (2)
;
;  Any other instruction's size is calculated and skipped.
;
; Usage notes
;
;  BLM can be usefull for any application which would like to do code
;  morphing on its own, or other code. There are however, some things
;  to keep note on:
;
;  - Make sure you don't mix data with code, for example:
;    > CALL _LABEL
;    > DB "some string",0
;    > _LABEL:
;    Would make the meta miscorrectly assume "some string",0 to be
;    code. So make sure that in the codearea you specify is no data.
;  - On input, esi is allowed to equal edi, but it is not recommended
;    if it will cause the meta to morph itself on runtime.
;  - This code does not need any data,  and only needs to be able  to
;    execute. It is completely permutatable.
;
; Agreement
;
;  This  sourcecode  is  meant  to be used  in freeware and  shareware
;  programs, and therefor it is strictly prohibited to add any of this
;  code in binary or source format in  scan strings or other detection
;  methods. If done, it will impact on the sellability of the product,
;  and can result in high fees and/or trials before court.
;  YOU HAVE BEEN WARNED

use32

; ÄÄÄÄÄÄÄÄÄÄÄÄÄ META SOURCE ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; in:   esi(ecx) = start of code to morph
;       edi(ecx) = start of buffer to put morphed code in
;       ecx = size of code to morph (and buffer)
; out:  esi = esi + ecx
;       edi = edi + ecx
;       other registers are destroyed (except esp)

BLM:		cld
		lea	ebx, [esi+ecx]		; ebx = ptr to end of code to morph
nextcode:	push	ebx
		xor	ecx, ecx
		push	4
		pop	ebx
		call	.innext
		pop	ebx
		rol	edx, 7			; simple RAND function
		neg	dx
		cmp	ebx, esi
		ja	nextcode
		ret

.next:		movsb
.innext:	mov	al, [esi]
		and	al, 11100111b
		cmp	al, 00100110b		; es/cs/ss/ds segment?
		jz	.next			; check if more
		mov	al, [esi]
		and	al, 11111110b
		cmp	al, 01100100b		; fs/gs segment?
		jz	.next			; check if more
		cmp	al, 11110010b		; repz/repnz?
		jz	.next			; check if more
		cmp	al, 01100110b		; WORD?
		jnz	opcode
		mov	bl, 2			; set WORD size
		jmp	.next

; -----------------------------------------------------------------------

opcode: 	mov	al, [esi]
		cmp	al, 0fh
		jnz	branch_start
		movsb
		or	al, [esi]		; ????1111
		cmp	al, 10001111b
		jz	.6byte			; -> jxx label32
		cmp	al, 10111111b
		jz	.3byte			; -> movzx/bt?
		jmp	.done
.6byte: 	movsb
		movsb
		movsb
.3byte: 	movsb
.done:		movsb
		ret
branch_start:	shl	al, 1
		jc	branch_1xxxxxxx
branch_0xxxxxxx:shl	al, 1
		jc	branch_01xxxxxx
branch_00xxxxxx:shl	al, 4
		jnc	op_rmrm_d
op_eax: 	mov	al, [esi]
		shr	al, 1
		jc	.pr32
		movsb
		movsb
		ret				; -> op al, imm8
.pr32:		add	ecx, ebx		; -> op eax, imm32
		rep	movsb
		movsb
		ret
branch_01xxxxxx:cmp	al, 11000000b
		jb	.ncjump
		movsb				; -> jxx label8
.ncjump:	cmp	al, 068h
		jz	do_5byte		; -> push imm32
		cmp	al, 06ah
		jnz	.done			; -> popad/pushad/pop/push/dec/inc (reg)
		stosb				; -> push imm8
.done:		movsb
		ret

op_rmrm_d:	mov	al, [esi+1]		; -> add/or/adc/sbb/and/sub/xor/cmp r/m,r/m
		rcr	edx, 1			; rand true/false
		jc	.nomorph
		cmp	al, 11000000b
.nomorph:	jb	op_rm			; (jc == jb so little optimization)
		lodsb
		xor	al, 00000010b
		stosb
		lodsb
		and	eax, 00111111b		; 00000000 00regreg
		shl	eax, 5			; 00000reg reg00000
		shr	al, 2			; 00000reg 00reg000
		or	al, ah			; 00000xxx 00regreg
		or	al, 11000000b		; 11regreg
		stosb
		ret

branch_1xxxxxxx:shl	al, 1
		jc	branch_11xxxxxx
branch_10xxxxxx:shl	al, 1
		jc	branch_101xxxxx
branch_100xxxxx:shl	al, 1
		jc	branch_01xxxxxx.ncjump	; -> xchg eax,reg/cwde/cdq/pushf/popf/sahf/lahf
branch_1000xxxx:cmp	al, 01000000b
		jae	op_rm			; -> test/xchg/mov/lea/pop r/m(,r/m)
		shl	al, 3
		jc	op_rmimm8		; -> add/or/adc/sbb/and/sub/xor/cmp r/m,imm8
		jmp	op_rmimm32		; -> add/or/adc/sbb/and/sub/xor/cmp r/m,imm32
branch_101xxxxx:shl	al, 1
		jc	branch_1011xxxx
branch_1010xxxx:and	al, 11100000b
		cmp	al, 00100000b
		jb	op_eax			; -> test eax, imm
		cmp	al, 10000000b
		jz	do_5byte		; -> mov mem32, eax
		movsb
		ret				; -> movs/stos/lods/scas
branch_1011xxxx:shl	al, 1
		jnc	branch_1100001x.2byte	; -> mov reg, imm8
		jmp	op_eax.pr32		; -> mov reg, imm32
do_5byte:	movsd
		movsb
		ret
branch_11xxxxxx:shl	al, 1
		jc	branch_111xxxxx
branch_110xxxxx:shl	al, 1
		jc	branch_1101xxxx
branch_1100xxxx:cmp	al, 11010000b
		jz	branch_1100001x.2byte	; -> int imm8
		shl	al, 1
		jc	branch_1100001x.done	; -> leave/int 3
branch_11000xxx:shl	al, 1
		jc	op_rm_w 		; -> mov r/m, imm
branch_110000xx:shl	al, 1
		jc	branch_1100001x
		inc	ecx			; -> rol/ror/rcl/rcr/shl/shr/sal/sar reg, 1
		jmp	op_rm
branch_1100001x:shl	al, 1
		jc	.done
.3byte: 	movsb
.2byte: 	movsb				; -> ret imm16
.done:		movsb
		ret				; -> ret
branch_1101xxxx:shl	al, 2
		jc	branch_1100001x.done	; -> xlatb
branch_1101x0xx:jmp	op_rm			; -> rol/ror/rcl/rcr/shl/shr/sal/sar reg, 1

branch_111xxxxx:shl	al, 1
		jc	branch_1111xxxx
branch_1110xxxx:shl	al, 1
		jnc	branch_11101010 	; -> loop label
branch_11101xxx:cmp	al, 00100000b
		jz	branch_111010x0.done	; -> call label
branch_111010x0:shl	al, 2
		jc	branch_11101010
.done:		movsd				; -> jmp label32
		movsb
		ret
branch_11101010:movsb
		movsb
		ret				; -> jmp label8
branch_1111xxxx:shl	al, 1
		jc	branch_11111xxx
branch_11110xxx:shl	al, 2
		jnc	branch_11111xxx.done	; -> cmc
branch_11111x1x:mov	al, [esi+1]		; al = modr/m
		and	al, 00111000b
		jnz	op_rm			; -> not/mul/div/idiv
		jmp	op_rm_w 		; -> test
branch_11111xxx:shl	al, 1
		jc	.done			; -> clc/stc/cli
		shr	al, 1
		jc	op_rm			; -> inc/dec/call/jmp/push
.done:		movsb
		ret				; -> cld/std

; -----------------------------------------------------------------------

op_rm_w:	mov	al, [esi]
		shr	al, 1
		jnc	op_rmimm8
op_rmimm32:	add	ecx, ebx		; imm length will be 4 or 2
		dec	ecx
op_rmimm8:	inc	ecx			; imm length = 1 byte
op_rm:		movsb
		lodsb
		stosb
		cmp	al, 11000000b		; op reg, reg
		jae	.done
		mov	ah, al
		and	al, 111b
		shr	ah, 6
		jz	.regaddr
		cmp	ah, 00000001b
		jz	.ddone
		add	ecx, 3			; op reg, [reg+dword]
.ddone: 	inc	ecx			; op reg, [reg+byte]
.cmpsib:	cmp	al, 00000100b
		jnz	.done
		xor	ebx, ebx
		mov	eax, ebx
		lodsb				; 00000000 iiregreg
		shl	eax, 2			; 000000ii regreg00
		xchg	bl, ah			; 00000000 regreg00
		shl	eax, 3			; 00000reg reg00000
		shr	al, 5			; 00000reg 00000reg
		cmp	ah, 4
		jz	.randindex
		cmp	al, 4
		jz	.nosib
		or	bl, bl			; index = 1?
		jnz	.nosib
		rcr	edx, 1
		jnc	.nosib			; randomly abort switch
		xchg	al, ah
		jmp	.nosib
.randindex:	mov	bl, dl			; index is random
		and	bl, 00000011b
.nosib: 	shl	al, 5			; 00000reg reg00000
		shr	eax, 3			; 00000000 regreg00
		mov	ah, bl			; 000000ii regreg00
		shr	eax, 2			; 00000000 iiregreg
		stosb
.done:		rep	movsb
		ret
.regaddr:	cmp	al, 00000101b		; op reg, [dword]
		jnz	.cmpsib
		movsd
		jmp	.done

; ÄÄÄÄÄÄÄÄÄÄÄÄÄ META BINARY ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; in:   esi(ecx) = start of code to morph
;       edi(ecx) = start of buffer to put morphed code in
;       ecx = size of code to morph (and buffer)
; out:  esi = esi + ecx
;       edi = edi + ecx
;       other registers are destroyed (except esp)

BLM:		db 252,141,28,14,83,49,201,106,4,91,232,13,0,0,0,91
		db 193,194,7,102,247,218,57,243,119,234,195,164,138,6,36,231
		db 60,38,116,247,138,6,36,254,60,100,116,239,60,242,116,235
		db 60,102,117,4,179,2,235,227,138,6,60,15,117,19,164,10
		db 6,60,143,116,6,60,191,116,5,235,4,164,164,164,164,164
		db 195,208,224,114,75,208,224,114,20,192,224,4,115,31,138,6
		db 208,232,114,3,164,164,195,1,217,243,164,164,195,60,192,114
		db 1,164,60,104,116,95,60,106,117,1,170,164,195,138,70,1
		db 209,218,114,2,60,192,15,130,179,0,0,0,172,52,2,170
		db 172,131,224,63,193,224,5,192,232,2,8,224,12,192,170,195
		db 208,224,114,52,208,224,114,23,208,224,114,198,60,64,15,131
		db 139,0,0,0,192,224,3,15,130,129,0,0,0,235,124,208
		db 224,114,12,36,224,60,32,114,149,60,128,116,8,164,195,208
		db 224,115,37,235,146,165,164,195,208,224,114,38,208,224,114,27
		db 60,208,116,20,208,224,114,17,208,224,114,73,208,224,114,3
		db 65,235,76,208,224,114,2,164,164,164,195,192,224,2,114,249
		db 235,61,208,224,114,19,208,224,115,12,60,32,116,5,192,224
		db 2,114,3,165,164,195,164,164,195,208,224,114,14,192,224,2
		db 115,17,138,70,1,36,56,117,22,235,10,208,224,114,4,208
		db 232,114,12,164,195,138,6,208,232,115,3,1,217,73,65,164
		db 172,170,60,192,115,76,136,196,36,7,192,236,6,116,70,128
		db 252,1,116,3,131,193,3,65,60,4,117,54,49,219,137,216
		db 172,193,224,2,134,220,193,224,3,192,232,5,128,252,4,116
		db 16,60,4,116,17,8,219,117,13,209,218,115,9,134,196,235
		db 5,136,211,128,227,3,192,224,5,193,232,3,136,220,193,232
		db 2,170,243,164,195,60,5,117,191,165,235,246

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

