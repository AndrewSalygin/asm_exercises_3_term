extrn GetStdHandle: proc,     ; получения дескриптора для потока
WriteConsoleA: proc,          ; записи ANSI - строки в поток
ReadConsoleA: proc,           ; чтение ANSI - строки из потока
lstrlenA: proc,               ; получение длины строки.
ExitProcess: proc             ; завершения работы приложения.
	
STACKALLOC macro arg ; макрос для выравнивания стека
push R15                     ; сохраняется указатель на старый стек
mov R15, RSP                 ; новый указатель помещается в R15
sub RSP, 8 * 4 ; выделяется место для 4 - ех обязательных аргументов в стеке
if arg
sub RSP, 8 * arg ; при обнаружении аргумента для него выделяется память
endif
and SPL, 0F0h                ; выравнивание стека
endm

STACKFREE macro arg          ; макрос, освобождающий выделенную память
mov RSP, R15                 ; заносим значение, сохраненное в R15
pop R15                      ; извлекаем из стека старое значение R15
endm

NULL_FIFTH_ARG macro arg     ; установка пятого аргумента в нуль
mov qword ptr [RSP + 32], 0  ; заносится 0, отступая вправо 32 байта
endm

.data
STD_OUTPUT_HANDLE = - 11 ; номер стандартного потока вывода в WinAPI
STD_INPUT_HANDLE = - 10 ; номер стандартного потока ввода в WinAPI

hStdInput qword ?            ; неопределенное значение для дескриптора ввода
hStdOutput qword ?           ; для дескриптора вывода

sum qword ?                  ; неопределенное значение для суммы
	
; строки пользовательского интерфейса:
string1 db 'Num A: ', 0
string2 db 'Num B: ', 0
equality db '78h - (47h - A + B) = ', 0
char_error db 'Invalid character', 0
range_error db 0Ah, 'Range error', 0
	
.code
Start proc
STACKALLOC ; выделим место в стеке под аргументы __fastcall
mov RCX, STD_OUTPUT_HANDLE ; установим номер потока ввода как
; первый аргумент функции
call GetStdHandle            ; получение дескриптора для потока
mov hStdOutput, RAX          ; переместим значение дескриптора в переменную

; аналогично для потока ввода
mov RCX, STD_INPUT_HANDLE
call GetStdHandle
mov hStdInput, RAX

lea RAX, string1             ; заносим адрес выводимой строки
push RAX                     ; заносим RAX в стек
call PrintString             ; выводим строку
call ReadSignedNumFromString ; читаем введённое значение

cmp R10, 0                   ; сравнивается с кодом результата процедуры
jnz checkRangeA              ; если код 0 - проверяется диапазон

; вывод о неправильном символе
printCharError:
	lea RAX, char_error          ; заносим сообщение об ошибке в RAX
	push RAX                     ; заносим его в стек
	call PrintString             ; выводим ошибку
	jmp exit                     ; переходим к завершению программы
	
; Вывод ошибки о выход за границы
printRangeError:
	lea RAX, range_error         ; заносим текст ошибки в RAX
	push RAX                     ; заносим в стек
	call PrintString             ; выводим
	jmp exit                     ; переходим к завершению программы
	
; проверка диапазона
checkRangeA:
	cmp RAX, -32768
	jl printRangeError ; если число меньше, чем - 32768, то выводится ошибка
	cmp RAX, 32767
	jg printRangeError           ; если число больше 32767, то ошибка
	
	mov R8, RAX                  ; сохраним число A в R8
	sub R8, 47h                  ; вычтем из числа A константу 47h.
	neg R8 ; умножим результат на - 1, тем самым получим правильное значение
	
	; аналогично прочитаем второе число (B)
	lea RAX, string2             ; заносим адрес выводимой строки
	push RAX                     ; заносим RAX в стек
	call PrintString             ; выводим строку
	call ReadSignedNumFromString ; читаем введённое значение
	cmp R10, 0                   ; сравнивается с кодом результата процедуры
	jnz checkRangeB              ; если число корректно, проверяем диапазон
	lea RAX, char_error          ; заносим сообщение об ошибке в RAX
	push RAX                     ; заносим его в стек
	call PrintString             ; выводим ошибку
	jmp exit                     ; переходим к завершению программы
	
checkRangeB:
	cmp RAX, -128
	jl printRangeError
	cmp RAX, 127
	jg printRangeError
	
	add R8, RAX                  ; прибавляем число B
	sub R8, 78h                  ; вычитаем из выражения 78h
	neg R8                       ; меняем знак
	
	mov sum, R8                  ; заносим значение суммы в переменную
	
	; вывод выражения
	lea RAX, equality
	push RAX
	call PrintString
	
	; вывод суммы
	push sum
	call PrintSignedNum
	
; завершаем программу
exit:
	xor RCX, RCX
	call ExitProcess
	Start endp
	
; Процедура вывода строки
PrintString proc uses RAX RCX RDX R8 R9 R10 R11, string: qword
	local bytesWritten: qword ; вводим локальную переменную для числа
; записанных байт
	STACKALLOC 1 ; выделим место в стеке под 5 аргументов для 
; WriteConsoleA
	
	mov RCX, string              ; поместим в CX указатель на выводимую строку
	call lstrlenA                ; найдём длину строки (результат в RAX)
	
	; поместим аргументы в соответствующие регистры
	mov RCX, hStdOutput          ; дескриптор
	mov RDX, string              ; строка вывода
	mov R8, RAX                  ; длина строки
	lea R9, bytesWritten         ; число записанных байт
	
	NULL_FIFTH_ARG ; обнуляем пятый аргумент (lpReserved) для функции
	call WriteConsoleA ; выводим строку в поток, используя аргументы 
; в заполненных регистрах
	STACKFREE                    ; освобождаем стек
	ret 8                        ; возвращаемся в основную программу, очищая стек
	PrintString endp
	
	ReadSignedNumFromString proc uses RBX RCX RDX R8 R9
	local readStr[64]: byte,      ; строка для записи считанных символов
	bytesRead: dword              ; число прочитанных символов
	STACKALLOC 2 ; выделим место в стеке под ReadConsoleA и ещё один 
; qword
	; Здесь 2, но вроде под 1 агрумент ещё выделяем

	; заносим необходимые аргументы для вызова ReadConsoleA
	mov RCX, hStdInput           ; дескриптор
	lea RDX, readStr             ; строка для записи данных
	mov R8, 64                   ; максимальная длина строки
	lea R9, bytesRead            ; число считанных байт
	NULL_FIFTH_ARG               ; зануляем пятый аргумент
	call ReadConsoleA            ; вызываем чтение
	
	; вычисление длины строки
	xor RCX, RCX                 ; сбрасываем RCX
	mov ECX, bytesRead           ; перемещаем число прочитанных байт
	sub ECX, 2 ; вычитаем перенос строки и возврат каретки (т.е 2 символа)
	mov readStr[RCX], 0 ; нуль - терминирование (дописываем 0 в конец строки)
	xor RBX, RBX                 ; сброс
	mov R8, 1                    ; здесь хранятся степени 10 для умножения
	
passage:
	dec RCX
	cmp RCX, -1 ; если RCX = -1, то переходим на scanningComplete
	jz scanningComplete
	
	xor RAX, RAX ; обнуляем - здесь будет хранится очередная цифра
	mov AL, readStr[RCX]         ; помещаем в AL очередной символ
	cmp AL, '-'                  ; если нашёл ' - ', то меняем знак числа в RBX
	; и переходим на scanning Complete
	jne eval                     ; иначе переходим на eval
	neg RBX                      ; меняем знак
	jmp scanningComplete
	
; проверим, является ли символ десятичной цифрой
eval:
	; проверяем диапазон ASCII кодов
	cmp AL, 30h
	jl error
	cmp AL, 39h
	jg error
; код символа переводится в число и прибавляется к RBX, увеличивается
; RAX (разряд) (умножается на 10)
	; считывается с первого разряда и увеличивая разряды
	sub RAX, 30h                 ; перевод из символа в число, вычитая '0' из RAX
	mul R8                       ; степень для общей суммы
	add RBX, RAX                 ; общая сумма
	mov RAX, 10                  ; множитель 10
	mul R8                       ; текущая степень 10
	mov R8, RAX                  ; степень переносится в R8
	jmp passage                  ; переходим к следующей цифре
	
; завершение программы при несовпадении ASCII кода
error:
	mov R10, 0
	STACKFREE
	ret
	
; прекращаем читать числа
scanningComplete:
	mov R10, 1
	mov RAX, RBX
	STACKFREE
	ret
	ReadSignedNumFromString endp
	
	
PrintSignedNum proc uses RAX RCX RDX R8 R9 R10 R11, summ: qword
local numberStr[22]: byte     ; выводимая строка
	xor R8, R8                   ; обнуление счетчика для строки
	mov RAX, summ                ; аргумент функции
	
	;
	;btc summ[RAX], RAX
	;JC print
	;
	
	cmp summ, 0                  ; проверка числа на знак
	jge print                    ; если положительное, то переходим в print
	mov numberStr[R8], '-'       ; минус для отрицательных
	inc R8                       ; увеличили число символов на 1
	neg RAX
	
print:
	mov RBX, 10                  ; для деления
	xor RCX, RCX                 ; очищаем RCX для записи длины строки
	
division:
	xor RDX, RDX                 ; Делимое это RDX:RAX, поэтому очищаем
	div RBX ; делим RAX на RBX (целая часть RAX, остаток RDX)
	
	add RDX, 30h                 ; добавляем '0'
	push RDX                     ; помещаем в стек остаток
	inc RCX
	
	cmp RAX, 0                   ; если RAX = 0, то заканчиваем деление
	jnz division
	; иначе выводим из стека все, что получили в обратном порядке
	
printAnswer:
	pop RDX                      ; достаем цифру из стека
	mov numberStr[R8], DL        ; вывод из стека
	inc R8
	loop printAnswer             ; повторяем, пока RCX != 0
	
	mov numberStr[R8], 0         ; в конец строки поставим '0'
	lea RAX, numberStr           ; занесем адрес начала строки в RAX
	push RAX                     ; запоминаем его в стеке
	call PrintString             ; выводим итоговую строку
	STACKFREE
	ret 8
	PrintSignedNum endp
	
end