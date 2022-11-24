	; Пример программы деления числа на 2^n
	.model small
	.stack 100h
	.data
	.code
start:
	
	mov AX, 1000h
	mov CL, 3
	SAR AX, CL
	
	mov AX, 4C00h
	int 21h
	end start
