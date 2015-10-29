.386
.MODEL FLAT, STDCALL

EXTERN	GetStdHandle@4:		PROC
EXTERN	WriteConsoleA@20:	PROC
EXTERN	CharToOemA@8:		PROC
EXTERN	ReadConsoleA@20:	PROC
EXTERN	ExitProcess@4:		PROC
EXTERN	lstrlenA@4:			PROC

remsym MACRO symbol, begadres, bufadres, len; тут должно быть что-то еще
	MOV len, 0
	MOV EDI, begadres
	MOV ESI, bufadres
	MOV BL, [ESI]
	.WHILE BL != 0
		.IF BL == 13 && len == 0
			JMP ex
		.ENDIF
		.IF BL != symbol
			MOV AL, [ESI]
			MOV [EDI], AL
			INC EDI
			INC ESI
			INC len
		.ELSE
			INC ESI
		.ENDIF
		MOV BL, [ESI]
	.ENDW
	MOV begadres, EDI
	ex:

ENDM

.DATA
dout DD ?					; дескриптор вывода
din DD ?					; дескриптор ввода
len DD ?					; длина строки
text DB 1000 dup (?)		; выводимый текст
buf DB 200 dup (?)			; вводимый текст
sym DB ?					; символ
textadres DD ?				; адрес на текущего места в тексте
textlen DD ?				; длина выводимого текста текста
bufadres DD ?				; 
symline DB "Введите символ, который необходимо удалить:",13,10,0
textline DB "Введите текст, который хотите изменить, для выхода из режима нажмите '#'",13,10,0
resline DB "Готовый текст",13,10,0

.code
main PROC
	PUSH OFFSET symline		; перекодировка строчек
	PUSH OFFSET symline
	CALL CharToOemA@8
	PUSH OFFSET textline
	PUSH OFFSET textline
	CALL CharToOemA@8
	PUSH OFFSET resline
	PUSH OFFSET resline
	CALL CharToOemA@8		; перекодировали строчки
	PUSH -10				; получение дескриптора ввода и вывода
	CALL GetStdHandle@4
	MOV din, EAX
	PUSH -11
	CALL GetStdHandle@4
	MOV dout, EAX			; получили дескриптор ввода и вывода
	PUSH OFFSET symline		; вывод первой строки
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET symline
	PUSH dout
	CALL WriteConsoleA@20	; вывели строку "Введите символ, который необходимо удалить:"
	PUSH 0					; считываем символ
	PUSH offset len
	PUSH 200
	PUSH offset sym
	PUSH din
	CALL ReadConsoleA@20	; считали символ
	PUSH OFFSET textline	; выводи строчку перед вводом текста
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET textline
	PUSH dout
	MOV textadres, OFFSET text
	MOV textlen, 0
	CALL WriteConsoleA@20	; вывели строчку "Введите текст, который хотите изменить, для выхода из режима нажмите '#'"
	read:					; считывание текста
		PUSH 0				; ввод строки
		PUSH OFFSET len
		PUSH 200
		PUSH OFFSET buf 
		PUSH din
		CALL ReadConsoleA@20; ввели строку
		MOV bufadres, OFFSET buf	
		MOV ESI, OFFSET buf	; проверка на символ окончания работы
		MOV BL, [ESI]
		.IF BL == '#' && len == 3
			JMP exit
		.ENDIF
		remsym sym, textadres, bufadres, ECX
		ADD textlen, ECX
		; повтор цикла
		JMP read
		; выход из цикла
	exit:
	PUSH OFFSET resline		; выводим строку
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET resline
	PUSH dout
	CALL WriteConsoleA@20	; вывели строку "результат"
	PUSH 0					; выводим измененную строку
	PUSH OFFSET textlen
	PUSH textlen
	PUSH OFFSET text
	PUSH dout
	CALL WriteConsoleA@20	; вывели строку
	MOV ECX, 0AFFFFFFFH		; задержка, ведь запустить из консоли так сложно
	l1: 
	LOOP l1
	PUSH 0					; выход из программы
	CALL ExitProcess@4
main ENDP
END main