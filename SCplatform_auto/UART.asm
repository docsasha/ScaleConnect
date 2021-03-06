	title "���� ��� ������ UART"
	list p=16f887
	include <p16f887.inc>

	global TX_LEN, UART_Buf, UART_TX_ON, UART_TX_OFF
	global UART_Setup, SendBytetoUART, SendPackettoUART, GetUARTByte

	udata
TX_LEN res .1
UART_Buf res .8 ;����� ������-�����������
	udata_ovr
TX_temp res .1
RX_temp res .1
STATUS_temp	res .1
FSR_temp res .1

;�������
;------------------------------------------------------------------

	code
;----------------------------------------------------------------
;- ��������� ������-�����������
;UART_Setup
UART_Setup
	banksel SPBRG
	movlw .129
	movwf SPBRG ;������������� �������� 9600 ���
	;������ �������� SPBRG ��� �������� ������� 20���:
	; .129 - 9600; .64 - 19200; .32 - 38400; .21 - 57600; .10 - 115200 
	movlw b'00100100'
	movwf TXSTA ;�������� ����������� �����, ������� �������� ��������
	;TXSTA ��� 7 (CSRC) � ������������ ������ �� ����� ��������
	;��� 6 (��9) =0 - 8�� ������ ��������
	;��� 5 (TXEN) =1 - �������� ���������
	;��� 4 (SYNC) =0 - ����������� ����� ������ 
	;��� 3 - �� ������������, �������� ��� 0
	;��� 2 (BRGH) =1 ���������������� �����
	;��� 1 (TRMT) =0 ������ TSR ���� ������� ���������� �������� �����������
	;��� 0 (TX9D) 9� ��� ������������ ������ ��� ���������������� ������
;	bsf PIE1, 5 ;��������� ���������� �� ��������� 
	banksel PIR1
	bcf PIR1,5
	bcf PIR1,4 ;���������� ����� ���������� �� �����������������
	movlw b'00010000'
	movwf RCSTA ;����������� �����, ����� ��������
	;RCSTA ��� 7 (SPEN) =1 ������ ����������������� ����� �������� ��������
	;��� 6 (R�9) =0 - 8�� ������ �����
	;��� 5 (SREN) =0 - � ����������� ������ �� ����� ��������
	;��� 4 (CREN) =1 - ����� ��������
	;��� 3 (ADDEN) =0 � ����������� 8�� ������ ������ �� ����� ��������
	;��� 2 (FERR) =0 ������ ����� �� ����
	;��� 1 (OERR) =0 ������ ������������ �� ����
	;��� 0 (RX9D) =0 9� ��� ����������� ������ ��� ���������������� ������
	return
;------------------------------------------------------------------
;- ��������� �������� UART
;SetUARTSpeed(UARTSpeed)
;------------------------------------------------------------------
;- ��������� ���� �� UART
;SendBytetoUART(UARTbyte) ������������ ���� � ������������
SendBytetoUART 
	banksel TXREG
    movwf  TXREG
    banksel TXSTA
per btfss  TXSTA,1   ; ���� 1-� ��� �������� TXSTA = 1,
                       ; �� �������� ��������� (TSR ����)
    goto   per
	return
;------------------------------------------------------------------
;- ��������� ����� (�� 8) ���� (����������� � ������ ������� � ���������� ������) �� UART
;SendPackettoUART(UART_Buf,TX_LEN)
SendPackettoUART
;��������� � ���� �� 8 ���� ���������� � ������ c ������ UART_Buf 
;� TX_LEN - ���������� ���� ��� �������� � ����
;	call UART_TX_ON;�������� ����������
	movf FSR,0
	banksel TX_temp
	movwf TX_temp ;��������� ���������� �������� �������� ��������� ���������

	movlw UART_Buf
	bankisel UART_Buf 
	movwf FSR
trans32	
	movf INDF,0
	call SendBytetoUART 
	bankisel UART_Buf 
	incf FSR,1
	banksel TX_LEN
	decfsz TX_LEN,1
	goto trans32

	banksel TX_temp
	movf TX_temp,0
	movwf FSR ;���������������� ����������� �������� �������� ��������� ���������
;	call UART_TX_OFF;��������� ����������
	return	
;------------------------------------------------------------------
;- ��������� ��������� �� UART ���� � ������� ����� �������� ������ � ������������
;GetUARTByte(ADDR)
GetUARTByte
	banksel RX_temp
	movwf RX_temp ;��������� �������� ������ � ������� ���� ���������
	call save_reg ;��������� �������� 
	banksel RX_temp
	movf RX_temp,0
	movwf FSR
	banksel RCREG	
	movf   RCREG,0  ; ������ ����� ��������� � �����������
	bankisel RX_temp
	movwf INDF ;���������� ��������� ���� � ���������� ������ ������
	call load_reg;��������������� ����������� ��������
	return	
;------------------------------------------------------------------
UART_TX_ON;�������� ����������
	banksel TXSTA
	bsf TXSTA,5	;�������� ����������
	banksel RCSTA	  	
	bsf RCSTA,7
	return
;-----------------------------------------------------------------------
UART_TX_OFF;��������� ����������
	banksel TXSTA
	bcf TXSTA,5	;��������� ����������
	banksel RCSTA	 
	bcf RCSTA,7
	return
;-----------------------------------------------------------------------
load_reg ;��������������� ����������� ��������
	banksel STATUS_temp
	movf STATUS_temp,0 ;��������������� STATUS
	movwf STATUS
	movf FSR_temp,0
	movwf FSR
	return
	;----------------------------------------------------
save_reg ;��������� �������� 
	banksel STATUS_temp
	movf STATUS,0
	movwf STATUS_temp ;��������� STATUS
	movf  FSR,0
	movwf FSR_temp		
	return
	;----------------------------------------------------
	end