	title "���� ��� ������ UART"
	list p=16f887
	include <p16f887.inc>

;	global HH,MM,SS,WD,DD,MO,YY
;	global ReadRTCData, ReadTime, ReadDate, ReadDayofWeek

;	udata

;	udata_ovr

;�������
;------------------------------------------------------------------

	code
;------------------------------------------------------------------
;- ��������� UART
;UART_ON
;------------------------------------------------------------------
;- ���������� UART
;UART_OFF
;------------------------------------------------------------------
;- ��������� �������� UART
;SetUARTSpeed(UARTSpeed)
;------------------------------------------------------------------
;- ��������� ���� �� UART
;SendBytetoUART(UARTbyte)
;------------------------------------------------------------------
;- ��������� ����� (�� 64) ���� (����������� � ������ ������� � ���������� ������) �� UART
;SendPackettoUART(ADDR,LEN)
;------------------------------------------------------------------
;- ��������� ��������� �� UART ���� � �������
;GetUARTByte(ADDR)
;------------------------------------------------------------------
	end