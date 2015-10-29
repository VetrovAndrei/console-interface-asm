.386
.MODEL FLAT, STDCALL

EXTERN	GetStdHandle@4:		PROC
EXTERN	WriteConsoleA@20:	PROC
EXTERN	CharToOemA@8:		PROC
EXTERN	ReadConsoleA@20:	PROC
EXTERN	ExitProcess@4:		PROC
EXTERN	lstrlenA@4:			PROC

remsym MACRO symbol, begadres, bufadres, len; ��� ������ ���� ���-�� ���
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
dout DD ?					; ���������� ������
din DD ?					; ���������� �����
len DD ?					; ����� ������
text DB 1000 dup (?)		; ��������� �����
buf DB 200 dup (?)			; �������� �����
sym DB ?					; ������
textadres DD ?				; ����� �� �������� ����� � ������
textlen DD ?				; ����� ���������� ������ ������
bufadres DD ?				; 
symline DB "������� ������, ������� ���������� �������:",13,10,0
textline DB "������� �����, ������� ������ ��������, ��� ������ �� ������ ������� '#'",13,10,0
resline DB "������� �����",13,10,0

.code
main PROC
	PUSH OFFSET symline		; ������������� �������
	PUSH OFFSET symline
	CALL CharToOemA@8
	PUSH OFFSET textline
	PUSH OFFSET textline
	CALL CharToOemA@8
	PUSH OFFSET resline
	PUSH OFFSET resline
	CALL CharToOemA@8		; �������������� �������
	PUSH -10				; ��������� ����������� ����� � ������
	CALL GetStdHandle@4
	MOV din, EAX
	PUSH -11
	CALL GetStdHandle@4
	MOV dout, EAX			; �������� ���������� ����� � ������
	PUSH OFFSET symline		; ����� ������ ������
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET symline
	PUSH dout
	CALL WriteConsoleA@20	; ������ ������ "������� ������, ������� ���������� �������:"
	PUSH 0					; ��������� ������
	PUSH offset len
	PUSH 200
	PUSH offset sym
	PUSH din
	CALL ReadConsoleA@20	; ������� ������
	PUSH OFFSET textline	; ������ ������� ����� ������ ������
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET textline
	PUSH dout
	MOV textadres, OFFSET text
	MOV textlen, 0
	CALL WriteConsoleA@20	; ������ ������� "������� �����, ������� ������ ��������, ��� ������ �� ������ ������� '#'"
	read:					; ���������� ������
		PUSH 0				; ���� ������
		PUSH OFFSET len
		PUSH 200
		PUSH OFFSET buf 
		PUSH din
		CALL ReadConsoleA@20; ����� ������
		MOV bufadres, OFFSET buf	
		MOV ESI, OFFSET buf	; �������� �� ������ ��������� ������
		MOV BL, [ESI]
		.IF BL == '#' && len == 3
			JMP exit
		.ENDIF
		remsym sym, textadres, bufadres, ECX
		ADD textlen, ECX
		; ������ �����
		JMP read
		; ����� �� �����
	exit:
	PUSH OFFSET resline		; ������� ������
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET len
	PUSH EAX
	PUSH OFFSET resline
	PUSH dout
	CALL WriteConsoleA@20	; ������ ������ "���������"
	PUSH 0					; ������� ���������� ������
	PUSH OFFSET textlen
	PUSH textlen
	PUSH OFFSET text
	PUSH dout
	CALL WriteConsoleA@20	; ������ ������
	MOV ECX, 0AFFFFFFFH		; ��������, ���� ��������� �� ������� ��� ������
	l1: 
	LOOP l1
	PUSH 0					; ����� �� ���������
	CALL ExitProcess@4
main ENDP
END main