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

	PRINT_STR 'H','E','L','L','O',' ','F','O','r',' ',' ','A','L','L',' ',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .1
	lcall pause_1s
	pagesel $

	PRINT_STR_1 ' ','b','Y','E',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .2
	lcall pause_1s
	pagesel $

	PRINT_STR_2 ' ','n','n','Y',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .3
	lcall pause_1s
	pagesel $

	PRINT_STR_3 'F','r','1','E','n','d'
	lcall pause_1s
	pagesel $

;	CLR_KOMA .5 
;	lcall pause_1s
;	pagesel $

	PRINT_SIMB 'd', .6
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'E', .7
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'A', .8
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'r', .9
	lcall pause_1s
	pagesel $
	PRINT_SIMB ' ', .10
	lcall pause_1s
	pagesel $
	bsf INTCON,7
	goto $
	
;������������� ��������� ������

;���������� �������� �� ����������� ��� �������

;���� �������� �������� ������������� � ���������� �����

;���� ����� ������, � ������ �� ���������� - ���������� �� �� ������

;���� �������� �� ������� - ��������� ������ �� ���������� ������

;������������� ����������������
	include <initMC.inc>
	goto $
	end