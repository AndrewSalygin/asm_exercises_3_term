	.model small
	.stack 100h
	.data
	student db 'Salygin Andrew 241', 0dh, 0ah, '$'
	space db 0dh, 0ah, '$'
	.code
start:
	mov AX, @data
	mov DS, AX
	mov AH, 09h
	mov DX, offset student
	int 21h
	mov AX, 3
	add AX, 30h
	mov BX, 7
	add BX, 30h
	call subprogram1
	call subprogram2
	XCHG AL, BL
	call subprogram1
	mov AX, 4C00h
	int 21h
	subprogram1 proc
	push AX                      ; заносим значение регистра AX в стек, 
	; т.к при ( * ) значение ( * * ) помещается в AL
	; почему нельзя перенести AL? Потому что каждый элемент в стеке - 
	; это слово (word), а AL - byte
	mov AH, 02h                  ; функция вывода символа на экран
	mov DL, AL
	int 21h
	mov DL, 00h                  ; ( * * )
	int 21h                      ; ( * )
	mov DL, BL
	int 21h
	pop AX                       ; достаем значение AX из стека
	ret
	subprogram1 endp
	subprogram2 proc
	mov AH, 09h
	mov DX, offset space
	int 21h
	ret
	subprogram2 endp
	end start
