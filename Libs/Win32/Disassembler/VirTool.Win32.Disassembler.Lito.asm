;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                  ;
;                                                                                  ;
;                                                                      ###         ;
;                                                                        ###       ;
;             ###        ####################################################      ;
;             ###        ####################################################      ;
;             ###                      	 ###                             ###       ;
;             ###             ###    	 ###           #########       ###         ;
;             ###             ###    	 ###          ###########                  ;
;             ###                    	 ###         ##         ##                 ;
;             ###             ###    	 ###         ##         ##                 ;
;             ###             ###    	 ###         ##         ##                 ;
;             ###      ###    ###    	 ###         ##         ##                 ;
;             ###      ###    ###    	 ###         ##         ##                 ;
;             ############    ###    	 ###          ###########                  ;
;       ################################################################	   ;            
;                                                                                  ;
;                                                                                  ;                                                                          
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                  ;
;             		Advanced Length dIsassembler moTOr:)                       ;
;                                                                                  ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                  ; 
;                                   Версия 2.1					   ;                                                
;                                                                                  ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;функция _LiTo_                                                                    ;
;дизассемблирование машинной команды						   ;
;определение длины машинной команды                                                ;
;Вход:                                                                             ;
;esi - адрес разбираемой машинной команды                                          ;
;edi - указатель на выходную структуру (или буфер) (назовем ее INSTR:)		   ;
;Выход:                                                                            ;
;в eax - длина машинной команды.                                                   ;
;Заметки:                                                                          ;
;(x) Выходная структура (или буфер) заполняется в процессе дизассемблирования      ;
;инструкции и должна представлять собой следующее:                                 ;
;                                                                                  ;
;	INSTR1	struct                                                             ;
;	(+ 00) len_com		db 00h 	      ;	- длина команды;                   ;
;	(+ 01) flags		dd 00h 	      ;	- выставленные флаги               ;
;	(+ 05) seg		db 00h 	      ;	- сегмент (если есть);             ;
;	(+ 06) repx		db 00h 	      ;	- префикс (0F2h/0F3h) (если есть); ;
;	(+ 07) len_offset	db 00h 	      ;	- размер смещения;                 ;
;	(+ 08) len_operand	db 00h 	      ;	- размер операнда;                 ;
;	(+ 09) opcode 		db 00h 	      ;	- опкод (если опкод=0Fh, тогда     ;
;					      ;	  сюда сохраняется 2-ой опкод, и   ;
;					      ;	  устанавливается флаг B_OPCODE2); ;
;	(+ 10) modrm		db 00h 	      ;	- байт MODRM (также, если есть)    ;
;	(+ 11) sib		db 00h 	      ;	- байт SIB                         ;
;	(+ 12) offset		db 8 dup (00h);	- смещение инструкции              ;
;	(+ 20) operand		db 8 dup (00h);	- операнд  инструкции              ;
;	INSTR1	ends                                                               ;
;                                                                                  ;
;(х) понимаются (пока) только general purpose & fpu instructions                   ;
;    (остальные - в топку:)!                                                       ;
;(х) нет проверки на максимальную длину инструкции (15 байт) (нахрен)              ;
;(х) Как построены эти таблички:                                                   ;
;	ОЧЕНЬ ПРОСТО: так как в этом дизасме используются флаги с числовым    	   ;
;	обозначением <=8, то для одного флага достаточно места в половину байта    ;
;	(максимальное число =8 (B_PREFIX6X) - в двоичном представлении =1000b).    ;
;	Зная это, просто тупо в один байт запихиваем 2 флага - вот и все. Таким    ;
;	образом, каждая табличка в 256 байт урезается до 128.                      ;                            
;(х) Для 32-битного исполняемого кода.						   ;
;(х) Кто хочет, пусть нафиг сам и добавляет остальные команды и всякие там         ;
;    проверки.                                                                     ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                                                                                   ;
                                                                                   ;
                                                                                   ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;				ФИЧИ:                                              ;
;(+) базонезависимость								   ;
;(+) упакованные таблички							   ;                                           
;                                                                                  ;
;(-) муторно добавлять новые инструкции						   ;                                                                                                                                                   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                                                                                   ;
                                                                                   ;
                                                                                   ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;				ИСПОЛЬЗОВАНИЕ:                                     ;
;1)Подключение:                                                                    ;
;	lito.asm                                                                   ;
;2)Вызов:(пример)                                                                  ;
;	lea	esi,XXXXXXXXh	;адрес команды, чью длину надо узнать		   ;              
;	lea	edi,XXXXXXXXh	;lea edi,INSTR1					   ;
;	call	LiTo                                                               ;                                                                                                                  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                                                                                   

									;m1x
							           ;pr0mix@mail.ru	

_LiTo_:
	pushad
	call	_delta_lito_
;===================================================================================

;строка префиксов
pfx:
db 2Eh,36h,3Eh,26h,64h,65h,0F2h,0F3h,0F0h,66h,67h

SizePfx		equ $-pfx					;длина pfx

;===================================================================================

;таблица флагов для однобайтных опкодов
TableFlags1:

;  01  23  45  67  89  AB  CD  EF
db 11h,11h,28h,00h,11h,11h,28h,00h	;00
db 11h,11h,28h,00h,11h,11h,28h,00h      ;01
db 11h,11h,28h,00h,11h,11h,28h,00h      ;02
db 11h,11h,28h,00h,11h,11h,28h,00h      ;03
db 00h,00h,00h,00h,00h,00h,00h,00h	;04
db 00h,00h,00h,00h,00h,00h,00h,00h	;05
db 00h,11h,00h,00h,89h,23h,00h,00h	;06
db 22h,22h,22h,22h,22h,22h,22h,22h	;07
db 39h,33h,11h,11h,11h,11h,11h,11h	;08
db 00h,00h,00h,00h,00h,0C0h,00h,00h	;09
db 88h,88h,00h,00h,28h,00h,00h,00h	;0A
db 22h,22h,22h,22h,88h,88h,88h,88h	;0B
db 33h,40h,11h,39h,60h,40h,02h,00h	;0C
db 11h,11h,22h,00h,11h,11h,11h,11h	;0D
db 22h,22h,22h,22h,88h,0C2h,00h,00h	;0E
db 00h,00h,00h,11h,00h,00h,00h,11h	;0F


;===================================================================================

;таблица флагов для двухбайтных опкодов
TableFlags2:

;  01  23  45  67  89  AB  CD  EF
db 11h,11h,00h,00h,00h,00h,01h,00h	;00
db 00h,00h,00h,00h,00h,00h,00h,01h	;01
db 11h,11h,00h,00h,00h,00h,00h,00h	;02
db 00h,00h,00h,00h,00h,00h,00h,00h	;03
db 11h,11h,11h,11h,11h,11h,11h,11h	;04
db 00h,00h,00h,00h,00h,00h,00h,00h	;05
db 00h,00h,00h,00h,00h,00h,00h,00h	;06
db 00h,00h,00h,00h,00h,00h,00h,00h	;07
db 88h,88h,88h,88h,88h,88h,88h,88h	;08
db 11h,11h,11h,11h,11h,11h,11h,11h	;09
db 00h,01h,31h,00h,00h,01h,31h,01h	;0A
db 11h,11h,11h,11h,00h,31h,11h,11h	;0B
db 11h,00h,00h,01h,00h,00h,00h,00h	;0C
db 00h,00h,00h,00h,00h,00h,00h,00h	;0D
db 00h,00h,00h,00h,00h,00h,00h,00h	;0E
db 00h,00h,00h,00h,00h,00h,00h,00h	;0F   
;===================================================================================

SizeTbl		equ $-pfx
;===================================================================================
;флаги
;-----------------------------------------------------------------------------------
B_NONE		equ	00h		;xex
B_MODRM		equ	01h             ;present byte MODRM
B_DATA8		equ	02h             ;present imm8,rel8, etc
B_DATA16	equ	04h             ;present imm16,rel16, etc
B_PREFIX6X	equ	08h             ;present imm16/imm32 (в зависимости от наличия префикса 0x66 (0x67 для опкодов 0xA0-0xA3))
B_SEG		equ	10h             ;present segment (пример: 0x2e,0x3E, etc)
B_PFX66		equ	20h             ;present byte 0x66
B_PFX67		equ	40h             ;present byte 0x67
B_LOCK		equ	80h             ;present byte LOCK (0xF0)
B_REP		equ	100h            ;present byte rep[e/ne]
B_OPCODE2	equ	200h            ;present second opcode (first opcode=0x0F)
B_SIB		equ	400h		;present byte SIB
B_RELX		equ	800h		;present jxx/jmp/call (rel8,rel16,rel32)
;===================================================================================

_delta_lito_:
	pop	ebp
	cld
	xor	eax,eax
	xor	ebx,ebx
	cdq				        		;в edx: dl(0/1) - нет/есть префикс 0x66
	                                                        ;	dh(0/1) - нет/есть префикс 0x67
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG поиск префиксовxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_nextpfx_:					
	lodsb                                			;получаем очередной байт команды
	push	edi
	lea	edi,[ebp+(pfx-_delta_lito_+SizeTbl)]            ;в edi - адрес строки префиксов
	db	6Ah,SizePfx
	pop	ecx
	repne	scasb                                           ;есть ли в разбираемой команде префиксы?
	pop	edi
	jne	_endpfx_                                        ;нет? - на выход
	cmp	ecx,5
	jl	_lock_
	or	bl,B_SEG
	mov	byte ptr [edi+05h],al				;seg
_lock_:
	cmp	al,0F0h
	jne	_rep_
	or	bl,B_LOCK
_rep_:
	mov	ch,al
	and	ch,0FEh
	cmp	ch,0F2h
	jne	_66_
	or	bx,B_REP
	mov	byte ptr [edi+06h],al				;rep
_66_:
	cmp	al,66h                                          ;иначе смотрим, это 0x66?
	jne	_67_
	mov	dl,1
	or	bl,B_PFX66
_67_:
	cmp	al,67h                                          ;иначе, это 0x67?
	jnz	_nextpfx_                                       ;если нет, то ищем другие префиксы
	mov	dh,1
	or	bl,B_PFX67
	jmp	_nextpfx_                                       ;продолжаем поиск
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEND поиск префиксовxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_endpfx_:
_search_jxx_call_jmp_:
	mov	ch,al
	and	ch,0FEh
	cmp	ch,0E8h
	je	_jxxok_		
	mov	ch,al
	and	ch,11110000b
	cmp	ch,70h
	je	_jxxok_
	cmp	al,0EBh
	je	_jxxok_
	cmp	al,0Fh                                        	;опкод состоит из 2-х байт?
	jne	_opcode_
	lodsb                                                   ;если да, то берем 2-ой байт опкода
	mov	cl,80h                                          ;и увеличиваем cl=80h
	or	bx,B_OPCODE2
	mov	ch,al
	and	ch,11110000b
	cmp	ch,80h
	jne	_opcode_
_jxxok_:
	or	bx,B_RELX

;-----------------------------------------------------------------------------------
_opcode_:
	xor	ch,ch
        mov	byte ptr [edi+09h],al				;save first opcode
	lea	ebp,[ebp+ecx+(TableFlags1-_delta_lito_+SizeTbl)];в edi - адрес нужной таблицы флагов(хар-к)
	cmp	al,0A0h                                         ;если опкод>=0xA0 и опкод<=A3,
	jl	_01_;jb                                            ;
	cmp	al,0A3h
	jg	_01_
	test	cl,cl
	jne	_01_;je                                 	;то dl=dh
	mov	dl,dh						;mov	dl,dh
;-----------------------------------------------------------------------------------
_01_:
	push	eax
	shr	eax,1
	mov	cl,byte ptr [ebp+eax]				;в cl - флаги команды
	jc	_noCF_
	shr	cl,4
_noCF_:
        and	cl,0Fh
	xor	ebp,ebp				        	;в ebp - будет храниться длина смещения(offset)

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG разбор MODRMxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

        or	ecx,ebx
	pop	ebx						;bl=opcode
	test	cl,B_MODRM                                      ;присутствует ли байт modrm?
	je	_endmodrm_                                      ;нет? на выход
	lodsb                 	  				;al=modrm
	mov	byte ptr [edi+10],al				;MODRM
	mov	ah,al
;-----------------------------------------------------------------------------------
	shr	ah,6   						;ah=mod
;-----------------------------------------------------------------------------------	
	test	al,38h    					;далее смотрим, равно ли поле reg==0?
	jne	_03_
	sub	bl,0F6h                                         ;если да, то смотрим на опкод:
	jne	_02_                                            ;равен ли он 0xF6 или 0xF7(test)?
	or	cl,B_DATA8                                      ;если да, то устанавливаем нужный флаг
_02_:
	dec	ebx
	jne	_03_
	or	cl,B_PREFIX6X
;-----------------------------------------------------------------------------------	
_03_:
	and	al,07h
	xor	ebx,ebx                                         ;bl отвечает за присутствие байта sib
	mov	bh,ah                                           ;bh=mod
	cmp	dh,1                                      	;есть ли в разбираемой команде префикс 0x67?                            		
	je	_mod00_                                         ;если да, то перескакиваем
	cmp	al,4                                            ;иначе проверяем,равно ли поле rm==4?
	jne	_mod00_
	inc	ebx                                             ;если да, то возможно есть sib
;-----------------------------------------------------------------------------------
_mod00_:
	test	ah,ah                                           ;поле mod==0?
	jne	_mod01_
	dec	dh                                      	;содержит ли команда 0x67?						
	jne	_nop67_	                                        ;нет? перескакиваем
	cmp	al,6                                            ;если да, то rm==6?
	jne	_sib_
	inc	ebp                                             ;если да, то длина смещения=2(16 bit)
	inc	ebp
_nop67_:
	cmp	al,5                                            ;иначе, rm==5?
	jne	_sib_
	add	ebp,4                                           ;если да, то длина оффсета=4 (32 bit)
	jmp	_sib_                                           ;идем дальше
;-----------------------------------------------------------------------------------		
_mod01_:		                                        ;mod==1?
	dec	ah                                              
	jne	_mod02_
	inc	ebp                                             ;да? тогда ebp=1
	jmp	_sib_		
;-----------------------------------------------------------------------------------	                        
_mod02_:                                    			;mod==2?
	dec	ah
	jne	_mod03_
	inc	ebp             				;ebp=2
	inc	ebp
	dec	dh                                      	;если есть префикса 0x67, перескакиваем дальше
	je	_sib_
	inc	ebp                                             ;то ebp+=2
	inc	ebp          	
	inc	ebx
;-----------------------------------------------------------------------------------
_mod03_:                                                        ;mod==3?
        dec	bl                                              ;если да, тогда sib'а точно нет!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEND разбор MODRMxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG получение SIBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_sib_:
	dec	bl                                              ;есть ли байт sib?
	jne	_endmodrm_
	or	cx,B_SIB
	lodsb                                                   ;если да, то в al теперь лежит sib(al=sib) 
	mov	byte ptr [edi+11],al				;SIB
	and	al,7                                            ;далее, 
	cmp	al,5                                            ;al==5?
	jne	_endmodrm_
	test	bh,bh                                           ;если да, то смотрим, поле mod==0?
	jne	_endmodrm_
	push	4                                               ;если да, то есть 4-байтовое смещение
	pop	ebp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEND получение SIBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG флагиxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_endmodrm_:
        xor	ebx,ebx
	test	cl,B_DATA8                                  	;есть ли однобайтовое смещение?
	je	_nf1_
	inc	ebx
_nf1_:
	test	cl,B_DATA16                                     ;есть ли двухбайтовое смещение?
	je	_nf2_
	inc	ebx
	inc	ebx
_nf2_:
	test	cl,B_PREFIX6X                                   ;есть ли в команде непосредственное значение?
	je	_endflag_
	dec	dl					;есть ли 0x66(0x67 для [0xA0,0xA3]) в разбираемой команде?                                              
	je	_okp66_
	inc	ebx
	inc	ebx
_okp66_:
        inc	ebx
        inc	ebx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEND флагиxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_endflag_:
        push	ecx
        push	edi
        mov	ecx,ebp
        add	edi,12
        rep	movsb	
        sub	edi,ebp
        add	edi,8
        mov	ecx,ebx
        rep	movsb
        pop	edi
	pop	dword ptr [edi+1]
	sub	esi,dword ptr [esp+4];eax
	xchg	esi,eax
	mov	byte ptr [edi+0],al
	mov	dword ptr [esp+7*4],eax                         ;сохраняем размер в еах
	xchg	ebp,eax
	mov	byte ptr [edi+7],al
	mov	byte ptr [edi+8],bl	
	popad
	ret	                                               	;выходим:)
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции _LiTo_                                                              ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


SizeOfLiTo	equ $-_LiTo_					;размер функции _LiTo_
