	stak segment stack 'stack'   ;Начало сегмента стека
	db 256 dup (?)               ;Резервируем 256 байт для стека
	stak ends
	.186                         ;Конец сегмента стека
	data segment 'data'          ;Начало сегмента данных ;Строка для вывода
	data ends                    ;Конец сегмента данных
	code segment 'code'          ;Начало сегмента кода
assume CS:code, DS:data, SS:stak ;Сегментный регистр CS будет указывать на сегмент команд, 
	;регистр DS - на сегмент данных, SS – на стек
start:                        ;Точка входа в программу start
	;Обязательная инициализация регистра DS в начале программы
	mov AX, data
	mov DS, AX                   ;Используя сегментный регистр ES, 
	mov AX, 0b900h               ;организовывается запись данных в видеопамять
	mov ES, AX
	;по адресу В900h:0000h (страница 1)
	mov AH, 00h                  ;Запрос на установку видеорежима
	mov AL, 03h                  ;Стандартный цветной текстовый режим
	int 10h
	mov AH, 05h                  ;Выбор функции для вывода страницы
	mov AL, 01h                  ;Страница 1
	int 10h
	
	mov AL, 43h                  ; Символ
	mov AH, 0Ah                  ; Цвет
	mov DI, 3260                 ; начальное смещение
	
	mov CX, 0
	call B10DISPLAY
	
	mov AX, 4C00h                ;Функция 4Ch завершения программы с кодом возврата 0
	int 21h
	
	B10DISPLAY proc
b0: push CX                   ; сохраняем в стек
	mov CX, 8                    ; кол - во символов в строке
b1: mov ES:word ptr[DI], AX   ; вывод на экран (напрямую пишем в память)
	add di, 2                    ; переходим к следующему
	loop b1
	add DI, 144                  ; новая строка
	INC AH                       ; след символ
	INC AL                       ; след цвет
	pop CX
	INC CX
	cmp CX, 5
	jne b0
	ret
	B10DISPLAY endp
	code ends                    ;Вызов функции DOS ;Конец сегмента кода
	end start                    ;Конец текста программы с точкой вход