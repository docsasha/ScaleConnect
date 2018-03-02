;�������� ���� ��������� �������������� �������� ������ � ������������
;���������� �� �� � ���������������� ����
	include <MCSetup.inc>
;��������� ������� �������
	include <TM1621Setup.inc>
;���� �������
	include <TM1621.inc>
;��������� ���������� ��� �������� ������
	global LCD_bufer, bufer_count

	udata
;���������� ��� ������� ������ � �������
LCD_bufer 	res .18 ;����� ������ ������� � ������� ������������� �����
bufer_count	res .1 ;������� ������ ���������� �������� ��� (������ ������������� ����� ����� ������)
bit_buffer	res .1 ;������� ��� ��� ������� � �������
byte_buffer	res .1 ;������� ���� ��� ������� � �������
;��������������� ����������
loop_cnt	res .1 ;������� �����
;-----------------------------------------
;���������� ������� ����������� ������
	;����������� ������ ������ �� �������
	extern simb_pos, Display_Data, Data_to_LCD  ;<TM1621LCD.asm>
	extern init_LCD, LCD_Data_Duplicate, PrintSimb,PrintMsg  ;<TM1621LCD.asm>
	extern PrintFirstStr, PrintSecondStr, PrintThirdStr;<TM1621LCD.asm>
	extern SetKoma, ClrKoma, KomaPos, koma_set
	;����������� ������ ����
	extern pause_5s, pause_1s, pause_05s ;<pauses_20MHz.asm>
	;����������� ������ ������������� ������ ��������� ������ �� �������
	extern LCD_Data_Recognize ;<TM1621Recognize.asm>
	extern seg1_1,seg1_2,seg1_3,seg1_4,seg1_5;<TM1621Recognize.asm>
	extern seg2_1,seg2_2,seg2_3,seg2_4,seg2_5;<TM1621Recognize.asm>
	extern seg3_1,seg3_2,seg3_3,seg3_4,seg3_5,seg3_6;<TM1621Recognize.asm>
	extern koma;<TM1621Recognize.asm>
	;����������� ������ Tiny RTC - ������ � ������ DS1307
	extern HH,MM,SS,WD,DD,MO,YY ;<RTCTime.asm>
	extern ReadRTCData, ReadTime, ReadDate, ReadDayofWeek;<RTCTime.asm>
	extern WriteRTC, WriteTime, WriteDate, WriteDayofWeek;<RTCTime.asm>
	;����������� ������ ������ � ���������� ����
	extern ee_read, ee_write ;<EEPROM.asm>
	;����������� ������ ��� ������ � UART
	extern TX_LEN, UART_TX_ON, UART_TX_OFF;<UART.asm>
	extern UART_Setup, SendBytetoUART, SendPackettoUART, GetUARTByte;<UART.asm>
	extern UART_Buf ;<UART.asm>
	;����������� ������ Tiny RTC - ������ � ���� 24C32N	
	extern MEM_ADDR_H, MEM_ADDR_L, MEM_LEN, R_BUFFER;<RTCEEPROM.asm>
	extern WriteADDR, WriteBlock, ReadADDR, ReadBlock	;<RTCEEPROM.asm>
;-----------------------------------------------------------------------
;�������
	include <macroTM1621.inc>
;1)������ ���� �������� ������� � ���� ������ !��� ������� (16 ��������)
;PRINT_STR MACRO S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16 
;2)������ ������ ������ !��� ������� (5 ��������)
;PRINT_STR_1 MACRO S1,S2,S3,S4,S5  
;3)������ 2�� ������ !��� ������� (5 ��������)
;PRINT_STR_2 MACRO S1,S2,S3,S4,S5 
;4)������ 3� ������ !��� ������� (6 ��������)
;PRINT_STR_3 MACRO S1,S2,S3,S4,S5,S6 
;5)���������� ������� � ������� POS (1-16)
;SET_KOMA MACRO POS
;6)������� ������� � ������� POS (1-16)
;CLR_KOMA MACRO POS  
;7)���������� ������ SIMB � ������� POS
;PRINT_SIMB MACRO SIMB, POS
;8)���������� �������� ���������� VAL � ������� POS
;PRINT_VAL MACRO VAL, POS ;POS 1..16
	include <macroTinyRTC.inc>
;1)������ ������ ����������� ������� �� �������� - ������ ��������� � ������� BCD
;WRITE_RTC MACRO HOURS, MINUTES, SECONDS, DAY_of_WEEK, DATE, MONTH, YEAR
;2)������ ������ ������� �� �������� - ������ ��������� � ������� BCD
;WRITE_TIME MACRO HOURS, MINUTES, SECONDS
;3)������ ������ ���� �� �������� - ������ ��������� � ������� BCD
;WRITE_DATE MACRO DATE, MONTH, YEAR
;4)������ ������ ��� ������ �� ��������� - ������ ��������� � ������� BCD
;WRITE_DAY_of_WEEK MACRO DAY_of_WEEK
;5)������ ������ � ������ ������ �������� ������� (���������� HH,MM,SS)
;TIME_to_3STR MACRO
;6)������ ������ �� ������ ������ ������� ���� (���������� DD,MO)
;DATE_to_2STR MACRO
;7)������ ������ �� ������ ������ �������� ���� 20�� (���������� YY)
;YEAR_to_2STR MACRO
;8)������ ������ � 1� ������ �������� ��� ������ (���������� WD)
;DW_to_1STR MACRO
;9)������ ������ ����������� ������� �� ���� ������� � ������ TIMEADDR - ������ ��������� � ������� BCD
;WRITE_RTC_EE MACRO TIMEADDR
	include <macroUART.inc>
;1)������ �������� � ���� �������� ����������
;UART_SEND_VAL MACRO VAL
;2)������ �������� � ���� ���������
;UART_SEND_CONST MACRO CONST
;3)������ �������� � ���� �������� ���������� � ������� ������� � BEGIN_ADDR
;������ SEND_LEN (�� 8 ����)
;UART_SEND_MEM MACRO BEGIN_ADDR, SEND_LEN
;-----------------------------------------------------------------------

;����� ��������� �������� ����
	Org 0x2100;����� � ���� (�� ������ 0x00) ������������ � ������ ����� �����
	DE 0x16 ;����
	DE 0x45 ;������
	DE 0x00 ;�������
	DE .3  ;���� ������
	DE 0x21 ;�����
	DE 0x02 ;�����
	DE 0x18 ;��� 

;�������� ���� ���������
	org 0x0000
	goto start
	org 0x0004 ;������ ����������
;-----------------------------------------------------------------------
	bcf INTCON,7 ;��������� ����������
	;�������� �������� ����������
	;btfsc PIR1,0 ;(TMR1IF)
	;goto TMR1_int ;���� �� ��������� ���������� �� ������� 1

;������ ������ � ������� �����
	include <TM1621Capture.inc> ;������ ������ � �������
	include <TM1621ClrBuf.inc>  ;������� ���������� �� ����� �������
;-----------------------------------------------------------------------	
start
	lcall initMC;<initMC.inc> ������������� ����������������
	lcall UART_Setup ;<UART.asm> ����������� ������ UART
	lcall init_LCD;<TM1621LCD.asm> ������������� �������	
	lcall pause_05s ;<pauses_20MHz.asm>�����
	lcall clr_bufer ;<TM1621ClrBuf.inc> ������� ���������� �� ����� �������
	lcall UART_TX_ON ;<UART.asm> �������� ����������
	pagesel $
	;��������� ������� ������
	banksel koma
	clrf koma
	clrf koma+.1

	;����� ����� � ����
	WRITE_RTC_EE 0x00
	;WRITE_RTC 0x17, 0x30, 0x00,.5, 0x02, 0x03, 0x18
	
time_to_LCD
	;������ ����� � ���� �� �����
	lcall ReadTime
	pagesel $
	;������� ���� ������ � 1� ������
	DW_to_1STR 
	;������� ���� �� 2� ������
	DATE_to_2STR
	;������� ����� � 3� ������
	TIME_to_3STR

	UART_SEND_VAL SS

	UART_SEND_MEM HH, 7

	lcall pause_1s
	pagesel $
;	bsf INTCON,7
	goto time_to_LCD

;������������� ��������� ������

;���������� �������� �� ����������� ��� �������

;���� �������� �������� ������������� � ���������� �����

;���� ����� ������, � ������ �� ���������� - ���������� �� �� ������

;���� �������� �� ������� - ��������� ������ �� ���������� ������

;������������� ����������������
	include <initMC.inc>
	goto $
	end