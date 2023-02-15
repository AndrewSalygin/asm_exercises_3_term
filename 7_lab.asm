; Задание 7:

; Сделайте в окне сообщение с Вашей фамилией и именем.

; подключаем функции WinAPI
extrn ExitProcess       : proc,
      MessageBoxA       : proc,
      GetUserNameA      : proc,
      GetComputerNameA  : proc,
      GetTempPathA      : proc,
      wsprintfA         : proc

; макрозамены
      szMAX_COMP_NAME = 16
      szUNLEN = 257
      szMAX_PATH = 261

.data
; объявление глобальных переменных
cap db '64 bit program', 0
fmt db 'Username: %s',0Ah,
       'Computer name: %s', 0Ah,
       'TMP Path: %s', 0

.code
; локальные переменные для хранения результатов функция WinAPI
Start proc
local _msg[1024]                 :byte,
      _username[szUNLEN]         :byte,
      _compname[szMAX_COMP_NAME] :byte,
      _temppath[szMAX_PATH]      :byte,
      _size                      :dword

; подготовка стека
sub RSP, 8*5
and SPL, 0F0h

; получение имени пользователя
mov _size, szUNLEN
lea RCX, _username
lea RDX, _size
call GetUserNameA

; получение названия компьютера
mov _size, szMAX_COMP_NAME
lea RCX, _compname
lea RDX, _size
call GetComputerNameA

; получение пути до директории временных файлов
mov _size, szMAX_PATH
lea RCX, _size
lea RDX, _temppath
call GetTempPathA

;размещение в регистрах результирующей и форматирующей строки
lea RCX, _msg
lea RDX, fmt

; кладём первые два аргумента в регистры
lea R8, _username
lea R9, _compname

; оставшийся в стек, так как основные регистры заняты
lea R10, _temppath 
mov qword ptr [RSP+20h], R10
call wsprintfA

;обнулили регистры
xor RCX, RCX
xor R9, R9

lea RDX, _msg ; положили адрес сообщения
lea R8, cap ; адрес заголовка (передаём по указателю согласно __fastcall)

call MessageBoxA
;завершение работы процесса
xor RCX, RCX
call ExitProcess
Start endp
end