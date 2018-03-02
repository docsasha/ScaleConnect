;макросы для работы с UART
;------------------------------------------------------------------------
;макрос отправки в порт значения переменной
UART_SEND_VAL MACRO VAL
	banksel VAL
	movf VAL,0
	lcall SendBytetoUART
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос отправки в порт константы
UART_SEND_CONST MACRO CONST
	movlw CONST
	lcall SendBytetoUART
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос отправки в порт значений записанных в области начиная с BEGIN_ADDR
;длиной SEND_LEN (до 8 байт)
UART_SEND_MEM MACRO BEGIN_ADDR, SEND_LEN
	banksel BEGIN_ADDR
	movf BEGIN_ADDR,0
	banksel UART_Buf
	movwf UART_Buf

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.1,0
	banksel UART_Buf
	movwf UART_Buf+.1

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.2,0
	banksel UART_Buf
	movwf UART_Buf+.2

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.3,0
	banksel UART_Buf
	movwf UART_Buf+.3

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.4,0
	banksel UART_Buf
	movwf UART_Buf+.4

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.5,0
	banksel UART_Buf
	movwf UART_Buf+.5

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.6,0
	banksel UART_Buf
	movwf UART_Buf+.6

	banksel BEGIN_ADDR
	movf BEGIN_ADDR+.7,0
	banksel UART_Buf
	movwf UART_Buf+.7

	banksel TX_LEN			
	movlw SEND_LEN
	movwf TX_LEN
	lcall SendPackettoUART
	pagesel $
	ENDM