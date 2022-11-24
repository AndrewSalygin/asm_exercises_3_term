	; Программа 4:
	.model small
	.stack 100h
	.data
	MAS DW 20 DUP (?)            ; Определяем массив из 20 неинициализированных слов
	nl DB 0Dh, 0Ah, '$'
	.code
start:
	MOV AX, @data
	MOV DS, AX
	
	MOV SI, 0                    ; задаём первый элемент массива
	MOV AX, 3                    ; начальное число
	MOV BX, 2                    ; первое число на которое нужно умножить
	
	MOV CX, 10                   ; кол - во итераций
	
push_in_mas_first:
	MOV MAS[SI], AX              ; кладём число
	MOV AX, 3                    ; базовое число (которое постоянно умножается)
	ADD SI, 2                    ; увеличиваем на 2, так как массив слов
	MUL BX                       ; умножаем
	ADD BX, 1                    ; получили следующее число, на которое нужно умножить
	loop push_in_mas_first
	
	MOV BX, 0                    ; первое число из массива, которое будем возводить в квадрат
	MOV CX, 10                   ; кол - во чисел
	
push_in_mas_second:
	MOV AX, [BX]                 ; положили базовое число
	MUL AX                       ; умножаем
	MOV MAS[SI], AX              ; заносим получившееся число
	ADD SI, 2                    ; переходим к следующему пустому месту
	ADD BX, 2                    ; переходим к следующему числу
	loop push_in_mas_second
	
	MOV SI, 0                    ; задаём начало массива
	MOV CX, 2                    ; кол - во строк массива
print_mas:
	PUSH CX                      ; сохранили кол - во строк массива
	MOV CX, 10                   ; занесли кол - во цифр в строке
print_inner:
	MOV AX, [SI]                 ; получаем число из массива
	PUSH CX                      ; сохраняем кол - во итераций
	MOV CX, 0                    ; кол - во цифр в числе
push_num:
	MOV DX, 0
	MOV BX, 0Ah                  ; Система счисления
	DIV BX                       ; делим на неё
	PUSH DX                      ; остаток (т. е последнее число) в стек
	ADD CX, 1                    ; считаем кол - во цифр
	CMP AX, 0                    ; пока не ноль
	JNE push_num                 ; повторяем
	
	MOV BX, 5                    ; кол - во разрядов
	SUB BX, CX                   ; кол - во пробелов
	PUSH CX                      ; заносим кол - во знаков числа в стек
	MOV CX, BX                   ; кол - во пробелов переносим в CX
	
	MOV DL, 0                    ; готовимся выводить пробелы
print_space:
	call print_symbol            ; выводим пробелы
	loop print_space
	
	POP CX                       ; достаем кол - во знаков числа
print_num:
	MOV DL, 30h                  ; 0 в ASCII
	POP AX                       ; достаём цифру
	ADD DL, AL                   ; получаем её код в ASCII
	call print_symbol            ; выводим
	loop print_num
	
	ADD SI, 2                    ; переходим к следующему числу в массиве
	pop CX                       ; считаем кол - во чисел в строке
	loop print_inner
	mov DX, offset nl
	call print_str               ; делаем новую строку
	pop CX                       ; достаём количество строк
	loop print_mas
	MOV AX, 4C00h
	int 21h
	
	print_symbol proc
	MOV AH, 02h
	int 21h
	ret
	endp print_symbol
	
	print_str proc
	mov AH, 09h
	int 21h
	ret
	endp print_str
	
	end start
