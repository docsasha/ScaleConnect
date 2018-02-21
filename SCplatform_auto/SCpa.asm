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
	;����������� ������ Tiny RTC - ������ � ���� 24C32N	
	

;-----------------------------------------------------------------------
;�������
	include <macroTM1621.inc>
;1)������ ���� �������� ������� � ���������� !��� ������� (16 ��������)
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
	include <macroTinyRTC.inc>
;1)������ ������ ����������� ������� �� �������� - ������ ��������� � ������� BCD
;WRITE_RTC MACRO HOURS, MINUTES, SECONDS, DAY_of_WEEK, DATE, MONTH, YEAR
;2)������ ������ ������� �� �������� - ������ ��������� � ������� BCD
;WRITE_TIME MACRO HOURS, MINUTES, SECONDS
;3)������ ������ ���� �� �������� - ������ ��������� � ������� BCD
;WRITE_DATE MACRO DATE, MONTH, YEAR
;4)������ ������ ��� ������ �� ��������� - ������ ��������� � ������� BCD
;WRITE_DAY_of_WEEK MACRO DAY_of_WEEK
;-----------------------------------------------------------------------

;����� ��������� �������� ����

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
	lcall init_LCD;<TM1621LCD.asm> ������������� �������	
	lcall pause_05s ;<pauses_20MHz.asm>�����
	lcall clr_bufer ;<TM1621ClrBuf.inc> ������� ���������� �� ����� �������
	pagesel $
	;��������� ������� ������
	banksel koma
	clrf koma
	clrf koma+.1

	PRINT_STR 't','1','n','n','E',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .8
	SET_KOMA .10

	;����� ����� � ����
	WRITE_RTC 0x10, 0x45, 0x00,.3, 0x21, 0x02, 0x18
	
time_to_LCD
	;������ ����� �� �����
	lcall ReadRTCData
	pagesel $
	;������� ����� � 3� ������
	banksel HH
	swapf HH,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_1
	movwf seg3_1

	banksel HH
	movf HH,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_2
	movwf seg3_2

	banksel MM
	swapf MM,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_3
	movwf seg3_3

	banksel MM
	movf MM,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_4
	movwf seg3_4

	banksel SS
	swapf SS,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_5
	movwf seg3_5

	banksel SS
	movf SS,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_6
	movwf seg3_6
	
	movlw seg3_1		
	lcall PrintThirdStr
	pagesel $

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