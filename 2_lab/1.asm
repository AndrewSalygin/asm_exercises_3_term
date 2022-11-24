	.model small                 ; Модель памяти SMALL использует сегменты размером не более 64 Кб
	.stack 100h                  ; Сегмент стека размером 100h (256 байт)
	.data                        ; Начало сегмента данных
	student db 'Salygin Andrew 241', 0dh, 0ah, '$'
	.code                        ; Начало сегмента кода
start:
	mov AX, @data                ;Предопределенная метка @data обозначает
	;адрес сегмента данных в момент запуска программы, 
	mov DS, AX
	mov AH, 09h                  ; функция вывода строки на экран
	mov DX, offset student
	int 21h
	mov AX, 3
	add AX, 30h                  ; 0 в таблице ASCII
	mov BX, 7
	add BX, 30h
	mov AH, 02h                  ; функция вывода символа на экран
	mov DL, AL
	int 21h                      ; выводим 3
	mov DL, 00h
	int 21h                      ; выводим пробел
	mov DL, BL
	int 21h                      ; выводим 7
	mov AX, 4C00h
	int 21h                      ; завершаем программу с кодом выхода 00h
	end start
