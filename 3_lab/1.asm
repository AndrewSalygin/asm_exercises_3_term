	; Программа 3.1:
	.model small
	.stack 100h
	.data
	student db 'Salygin Andrew 241', 0dh, 0ah, '$'
	space db 0dh, 0ah, '$'
	.code
	
start:
	mov AX, @data
	mov DS, AX
	
	mov DX, offset student
	call print_str
	mov DX, offset space
	call print_str
	
	mov AX, 254Ah                ; заносим число, которое хотим вывести
	mov BX, 0Ah                  ; берём основание системы счисления на которую будем делить
	; так как нам нужно вывести число в 10 системе счисления, то её и пишем
	mov CX, 0                    ; Обнуляем счётчик для цикла
	
push_digits_in_stack:
	mov DX, 0                    ; обнуляем остаток от прошлого деления
	div BX                       ; делим на 10
	push DX                      ; заносим остаток, т.е число в 10 СС в стек
	inc CX                       ; прибавляем счётчик
	cmp AX, 0                    ; проверяем закончилось ли число
	JNE push_digits_in_stack     ; если нет (то есть флаг нуля не поднят), 
	; то переходим на начало метки, если же 0 - то ассемблер просто
	; пойдет дальше
	
print_digits_out_stack:
	pop DX                       ; достаем значение (на первой итерации это будет то же число, 
	; потому что мы не обнулили dl)
	call print_symbol            ; выводим символ (прошлая лабораторная)
	LOOP print_digits_out_stack  ; (пока CX не 0, повторяем)
	
	mov AX, 4C00h
	int 21h
	
	print_symbol proc
	add DL, 30h
	mov AH, 02h
	int 21h
	ret
	endp print_symbol
	
	print_str proc
	mov AH, 09h
	int 21h
	ret
	endp print_str
	
	end start
