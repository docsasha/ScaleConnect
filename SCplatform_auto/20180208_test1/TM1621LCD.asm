	list p=16f887
	include <p16f887.inc>
	extern pause_5us, pause_3us ;<pauses_20MHz.asm>	
	global simb_pos
	global init_LCD, LCD_Data_Duplicate, Data_to_LCD, show_simb_pos 
	global LCD_ON, LCD_OFF

	#define CS PORTB,4
	#define WR PORTB,5
	#define DATA_PIN PORTB,7

	udata
simb_pos	res 1
	udata_ovr
temp 		res 1
buf_temp 	res 1
counter 	res 1
simb_temp 	res 1
;------------------------------------------------------------------------------
;�������
;-----------------------------------------------------------------
;��������� ����� 0
SET_BANK0 MACRO 
	bcf STATUS, RP0
	bcf STATUS, RP1	
	ENDM
;---------------------------------------------------------------------
	code
;-----------------------------------------------------------------------
init_LCD;������������� �������
	SET_BANK0
	bsf CS
	bcf WR
	lcall pause_5us 
	lcall SYS_EN ;������� SYS EN �������� ������������ �� ������� 100 000000011
	lcall RC_256K ;������� RC_256K �������� ������������ �� ������� 100 000110000
	lcall BIAS_1_3 ;������� BIAS ab=10:4 LCD 1/3 �������� ������������ �� ������� 100 001010011
	lcall LCD_OFF ;������� LCD OFF �������� ������������ �� ������� 100 000000100
	lcall TONE4K
	lcall TNORMAL
	lcall LCD_ON ;������� LCD ON �������� ������������ �� ������� 100 000000111
	return
;-------------------------------------------------------------------------
;LCD_Data_Duplicate(lcd_data_addr)
;lcd_data_addr - ����� ������ ������� � ������� ������������� ����� ��������� � ����� ������ 
;lcd_data_addr ����� ������� ��������� ������������ � �����������
LCD_Data_Duplicate
	banksel buf_temp
	movwf buf_temp
	addlw .18 ;bufer_count (LCD_bufer+18)
	movwf FSR
	movf INDF, 0
	movwf temp ;temp=bufer_count �.�. �� ���� ����� ����� ������ ������
	movf buf_temp, 0
	movwf FSR
	SET_BANK0
	bcf CS 
	lcall pause_5us ;����� 5 ���
	pagesel $
	banksel counter
next_dupl_byte
	movlw .8
	movwf counter
next_dupl_bit
	btfss INDF,7
	goto zero_dupl
	call SET_ONE ;������ ���������� ������� �� ������� �������
test_dupl_bit
	banksel temp
	decfsz temp,1 
	goto next_dupl ;���� �� ��� �������� ���� �������� ���� �� ��������
	SET_BANK0
	bsf CS ;���� ��� CS=1 � �������
	return
next_dupl
	rlf INDF,1 ;
	decfsz counter,1 
	goto next_dupl_bit ;���� ��� �� ������� ��������� ����
	incf FSR,1
	goto next_dupl_byte
zero_dupl
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto test_dupl_bit
;-------------------------------------------------------------------
;�������� ������ ������ � �������
;Data_to_LCD(lcd_data_addr)
;lcd_data_addr - ����� ������ ������� � ������� ������������� ����� ��������� � ����� ������ 
;16 ���� ������� � ������ ����������� � �����������
Data_to_LCD
	banksel buf_temp
	movwf buf_temp ;����� ������ ������� ������	
	call WRITE ;������� �������� ������� (������ ������) 101
	banksel counter	
	movlw .6 ;������ ��������� ����� 000000
	movwf counter
send_zero_4
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	banksel counter	
	decfsz counter,1
	goto send_zero_4
	;������� ������ 32*4 ���
;	movlw 0x60
	movf buf_temp,0
	movwf FSR
send_next_byte	
	movlw .8
	movwf counter
	movf INDF,0
	movwf temp
send_next_bit
	btfss temp,7
	goto send_zero
	call SET_ONE ;������ ���������� ������� �� ������� �������
shift_bit
	banksel temp	
	rlf temp,1
	decfsz counter,1
	goto send_next_bit
	incf FSR,1
;	movf FSR,0
;	xorlw 0x70
	movf buf_temp,0 ;!!
	addlw 0x10	;!!
	xorwf FSR, 0 ;!!
	btfss STATUS,Z ;���� ����� ��� 0�70 - ����������� �������� ������
	goto send_next_byte	
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_3us ;����� 3 ���
	pagesel $
	return
send_zero
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto shift_bit
;--------------------------------------------------------------------------
show_simb_pos ;������� �� ����� ������ ��� �������� � ������������
;� simb_pos - ������� ���������� �������
;� ������� �� �������� ������� ����� ������� / ������ ����
;�.�. ������ ������ ������� 1-5
;������ 6-10, ������ 11-16
	movwf simb_temp
	call WRITE ;������� �������� ������� (������ ������) 101
	;��������������� �����
	decf simb_pos,1 ;pos=pos-1
	comf simb_pos,0
	andlw 0x0F
	movwf temp
	rlf temp,1
	bcf temp,0	
	;�������� �����
	movlw .6
	movwf counter
send_next_bit2
	btfss temp,5
	goto send_zero2
	call SET_ONE ;������ ���������� ������� �� ������� �������
shift_bit2
	rlf temp,1
	decfsz counter,1
	goto send_next_bit2
	;������� ������ 2*4 ���
	movlw .8
	movwf counter
send_next_bit3
	btfss simb_temp,7
	goto send_zero3
	call SET_ONE ;������ ���������� ������� �� ������� �������
shift_bit3
	rlf simb_temp,1
	decfsz counter,1
	goto send_next_bit3
	;��������� CS ��� ���� ����� ��������� �������� �������
	bsf CS ;CS=1
	call pause_5us ;����� 3 ���
	return
send_zero2
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto shift_bit2
send_zero3
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto shift_bit3
;-----------------------------------------------------------------------
SET_ZERO ;������ ����������� ���� �� ������� �������
	SET_BANK0
	bcf DATA_PIN ;DATA=0
	nop
	bsf WR ;WR=1
	lcall pause_5us ;����� 3 ���
	pagesel $
	SET_BANK0
	bcf WR ;WR=0
	bcf DATA_PIN ;DATA=0
	lcall pause_5us ;����� 3 ���
	pagesel $
	return
;--------------------------------------------------------------------------
SET_ONE ;������ ���������� ������� �� ������� �������
	SET_BANK0
	bsf DATA_PIN ;DATA=1
	nop
	bsf WR ;WR=1
	lcall pause_5us ;����� 3 ���
	pagesel $
	SET_BANK0
	bcf WR ;WR=0
	bcf DATA_PIN ;DATA=0
	lcall pause_5us ;����� 3 ���
	pagesel $
	return
;--------------------------------------------------------------------------
WRITE ;������� �������� ������� (������ ������) 101
	SET_BANK0
	bcf CS ;CS=0
	lcall pause_5us ;����� 3 ���
	pagesel $
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	return
;--------------------------------------------------------------------------
COMMAND;������� �������� ������� (������� ����������) 100
	bcf CS ;CS=0
	call pause_5us ;����� 3 ���
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	return
;--------------------------------------------------------------------------
TONE4K ;������� TONE4K �������� ������������ �� ������� 100 010000000
	call COMMAND;������� �������� ������� (������� ����������) 100
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	bsf CS ;CS=1
	call pause_5us ;����� 3 ���
	return
;--------------------------------------------------------------------------
TNORMAL ;������� TNORMAL �������� ������������ �� ������� 100 111000111
	call COMMAND;������� �������� ������� (������� ����������) 100
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	bsf CS ;CS=1
	call pause_5us ;����� 3 ���
	return
;--------------------------------------------------------------------------
SYS_EN ;������� SYS EN �������� ������������ �� ������� 100 000000011
	call COMMAND;������� �������� ������� (������� ����������) 100
	banksel counter
	movlw .7
	movwf counter
send_zero_1
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	banksel counter
	decfsz counter,1
	goto send_zero_1	
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $	
	return
;--------------------------------------------------------------------------
RC_256K ;������� RC_256K �������� ������������ �� ������� 100 000110000
	call COMMAND;������� �������� ������� (������� ����������) 100
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $
	return
;--------------------------------------------------------------------------
BIAS_1_3 ;������� BIAS ab=10:4 LCD 1/3 �������� ������������ �� ������� 100 001010011
	call COMMAND;������� �������� ������� (������� ����������) 100
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $	
	return
;--------------------------------------------------------------------------
LCD_OFF ;������� LCD OFF �������� ������������ �� ������� 100 000000100
	call COMMAND;������� �������� ������� (������� ����������) 100
	banksel counter
	movlw .6
	movwf counter
send_zero_2
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	banksel counter
	decfsz counter,1
	goto send_zero_2	
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $	
	return
;--------------------------------------------------------------------------
LCD_ON ;������� LCD ON �������� ������������ �� ������� 100 000000111
	call COMMAND;������� �������� ������� (������� ����������) 100
	banksel counter
	movlw .6
	movwf counter
send_zero_3
	call SET_ZERO ;������ ����������� ���� �� ������� �������
	banksel counter
	decfsz counter,1
	goto send_zero_3	
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	call SET_ONE ;������ ���������� ������� �� ������� �������
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $	
	return
;---------------------------------------------------------------------------
	end