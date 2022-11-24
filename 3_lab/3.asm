	; Программа 3.3:
	.model small
	.stack 100h
	.data
	.code
start:
	
	mov AX, 12
	mov BX, 38
	
	cmp AX, BX
	jl vr2                       ; используем jl, так как числа могут быть со знаком
	
vr1:
	mov DX, BX
	jmp end_program
	
vr2:
	mov DX, AX
	
end_program:
	mov AX, 4C00h
	int 21h
	end start
