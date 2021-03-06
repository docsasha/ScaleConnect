;�������� ���� ��������� �������������� �������� ������ � ������������
;���������� �� �� � ���������������� ����
	include <MCSetup.inc>
;��������� ������� �������
	include <TM1621Setup.inc>
;���� �������
	include <TM1621.inc>
;��������� ���������� ��� �������� ������
	udata
;���������� ��� ������� ������ � �������
LCD_bufer 	res .18 ;����� ������ ������� � ������� ������������� �����
bufer_count	res .1 ;������� ������ ���������� �������� ��� (������ ������������� ����� ����� ������)
bit_buffer	res .1 ;������� ��� ��� ������� � �������
byte_buffer	res .1 ;������� ���� ��� ������� � �������
;-----------------------------------------
	extern pause_05s ;<pauses_20MHz.asm>
	extern init_LCD, LCD_Data_Duplicate ;<TM1621LCD.asm>

;���������� ������� ����������� ������

;�������

;����� ��������� �������� ����

	org 0x0000
	goto start
	org 0x0004 ;������ ����������
;-----------------------------------------------------------------------
	bcf INTCON,7 ;��������� ����������
;������ ������ � ������� �����
	include <TM1621Capture.inc> ;������ ������ � �������
	include <TM1621ClrBuf.inc>  ;������� ���������� �� ����� �������
;-----------------------------------------------------------------------	
start
	lcall initMC;<initMC.inc> ������������� ����������������
	lcall init_LCD;<TM1621LCD.asm> ������������� �������	
	lcall pause_05s ;<pauses_20MHz.asm>�����
	lcall clr_bufer ;<TM1621ClrBuf.inc> ������� ���������� �� ����� �������
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