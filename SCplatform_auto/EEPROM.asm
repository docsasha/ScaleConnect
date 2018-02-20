	title "���� ��� ������ � ����"
	list p=16f887
	include <p16f887.inc>
	global ee_read, ee_write


	code
;=======��������� ������ ����� �� EEPROM � ������ ����������� � ������������======
ee_read
	banksel EEADR
	movwf EEADR
	banksel EECON1	
	bsf EECON1,RD ;������������� ������ - ����� ������ ���������� �������
	nop ;����� ���� ������
	nop
	banksel EEDATA
	movf EEDATA,0 ;��������� � ����������� �������� ������
	nop
	bcf STATUS,RP1;������� � 0� ���� ;!!!!!
	bcf STATUS,RP0;!!!!!

	RETURN
;=== ��������� ������ ����� � EEPROM ������������ ������ ��������� � ������������==
;����� ������ ��� ������ ������������� �� ������ ���������
ee_write
	banksel EEDATA
	movwf EEDATA
	banksel EECON1
	bsf EECON1,WREN ;��������� ������ - ����� ������ ���������� �������
	movlw 0x55
	movwf EECON2
	movlw 0xAA
	movwf EECON2
	bsf EECON1,WR ;�������� ������
	nop
	nop
wr
	btfsc EECON1,WR ;���� ��������� ������
	goto wr
	bcf EECON1,WREN ;��������� ������
	bcf STATUS,RP1;������� � 0� ����
	bcf STATUS,RP0
	RETURN
;------------------------------------------------------------------------
	end