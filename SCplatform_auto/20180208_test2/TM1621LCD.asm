	list p=16f887
	include <p16f887.inc>
	extern pause_5us, pause_3us ;<pauses_20MHz.asm>	
	global simb_pos, Display_Data
	global init_LCD, LCD_Data_Duplicate, Data_to_LCD
	global LCD_ON, LCD_OFF, PrintSimb, PrintMsg

	#define CS PORTB,4
	#define WR PORTB,5
	#define DATA_PIN PORTB,7

;���� �������
	include <TM1621.inc>

	extern LCD_bufer
	udata
simb_pos	res 1
Display_Data res .16 ;������� ���������� ���� ��� ������ �� �����
	udata_ovr
temp 		res 1
buf_temp 	res 1
counter 	res 1
simb_temp 	res 1
ASCII_buf	res 1
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
;- ������� ������ � ��������� �������
;PrintSimb(SimbCode, Simb_Pos)
;SimbCode - ASCII ��� ���������� �������
;Simb_Pos � ������� � ������� �������� ������ (�� 0 �� 15: 0-4 ������ ������, 5-9 ������ ������, 10-15 ������ ������)
PrintSimb
	lcall ASCII_to_LCDcode
	pagesel $
	banksel simb_temp
	movwf simb_temp
	call WRITE ;������� �������� ������� (������ ������) 101
	;��������������� �����
	banksel simb_pos
	comf simb_pos,0 ;����������� ������� �.�. ��������� �������� � �������� �������
	andlw 0x0F
	banksel temp
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
	banksel simb_temp
	rlf simb_temp,1
	decfsz counter,1
	goto send_next_bit3
	;��������� CS ��� ���� ����� ��������� �������� �������
	SET_BANK0	
	bsf CS ;CS=1
	lcall pause_5us ;����� 3 ���
	pagesel $
	return
send_zero2
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto shift_bit2
send_zero3
	call SET_ZERO ;������ ����������� ���� �� ������� �������	
	goto shift_bit3
;-----------------------------------------------------------------------
;- ������������� ASCII ����� (16 ��������+2 ����� � ��������� �������) � ��� ��� ����� �� �������
;Convert_ASCII_to_LCD(lcd_data_addr, ASCII_data)
;lcd_data_addr - ����� ������ ������� � ������� ������������� ����� ��� ������ �� �������
;ASCII_data � ������ � ���� ASCII ���� (���������� � ������� 1� ������ 5 ��������, ����� 2� ������ 5 ��������, ����� 3� ������ 6 ��������)
;����� ASCII ���� �������� � ������������
;����� ������� 16 ���� ������� � Display_Data
Convert_ASCII_to_LCD
	;������ ������ ������� ����������� �������������� ������ �������� � ASCII ����
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp
	movlw .16
	movwf counter
nextASCII
	movf buf_temp,0
	movwf FSR
	movf INDF,0 ;W=ASCII[i]
	lcall ASCII_to_LCDcode ;w=LCDcode[i]
	pagesel $
	movwf temp
	decf counter,0 ;W=counter-1
	addlw Display_Data ;W=Display_Data+counter-1 �.�. ����� ������ ������ � ���. ���� ������
	movwf FSR
	movf temp,0
	movwf INDF ;Display_Data[j]=LCDcode[i]
	incf buf_temp,1
	decfsz counter,1
	goto nextASCII
	
	movf simb_temp,0
	movwf FSR ;��������������� FSR
	return
;-----------------------------------------------------------------------
;- ������� ��������� �� ��� ������ (16 ��������)
;PrintMsg(MsgAddr)
;MsgAddr � ����� ������ ������� ������ ��� �������� 16 �������� � ASCII ���� ��� ������ �� �������
;� 2 ����� � ��������� �������
;����� ������ ������� 18 ���� ��������� � ������������
;����� ������� 16 ���� ������� � Display_Data
PrintMsg
	call Convert_ASCII_to_LCD
	movlw Display_Data
	call Data_to_LCD	
	return
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
;-----------------------------------------------------------------------------
;- ������������� ������ � ���� ASCII � ��� �������
;ASCII_to_LCDcode(ASCIIcode):LCDcode
;ASCIIcode - ������ � ���� ASCII
;LCDcode - ������ � ���� �������
;������� ������ ASCIIcode �������� � ������������ 
;� �������� ������ LCDcode �������� � ������������
ASCII_to_LCDcode
;���������� ���������� �������
	banksel temp
	movwf temp
	xorlw '0'
	btfsc STATUS,Z
	retlw simb0

	movf temp,0
	xorlw '1'
	btfsc STATUS,Z	
	retlw simb1		

	movf temp,0
	xorlw '2'
	btfsc STATUS,Z	
	retlw simb2
	
	movf temp,0
	xorlw '3'
	btfsc STATUS,Z	
	retlw simb3

	movf temp,0
	xorlw '4'
	btfsc STATUS,Z	
	retlw simb4	

	movf temp,0
	xorlw '5'
	btfsc STATUS,Z	
	retlw simb5		

	movf temp,0
	xorlw '6'
	btfsc STATUS,Z	
	retlw simb6	

	movf temp,0
	xorlw '7'
	btfsc STATUS,Z	
	retlw simb7	

	movf temp,0
	xorlw '8'
	btfsc STATUS,Z	
	retlw simb8	

	movf temp,0
	xorlw '9'
	btfsc STATUS,Z	
	retlw simb9

	movf temp,0
	xorlw 'A'
	btfsc STATUS,Z	
	retlw simbA	

	movf temp,0
	xorlw 'b'
	btfsc STATUS,Z	
	retlw simbb	

	movf temp,0
	xorlw 'C'
	btfsc STATUS,Z	
	retlw simbC

	movf temp,0
	xorlw 'd'
	btfsc STATUS,Z	
	retlw simbd

	movf temp,0
	xorlw 'E'
	btfsc STATUS,Z	
	retlw simbE	

	movf temp,0
	xorlw 'F'
	btfsc STATUS,Z	
	retlw simbF

	movf temp,0
	xorlw 'G'
	btfsc STATUS,Z	
	retlw simbG

	movf temp,0
	xorlw 'H'
	btfsc STATUS,Z	
	retlw simbH

	movf temp,0
	xorlw 'J'
	btfsc STATUS,Z	
	retlw simbJ

	movf temp,0
	xorlw 'L'
	btfsc STATUS,Z	
	retlw simbL

	movf temp,0
	xorlw 'n'
	btfsc STATUS,Z	
	retlw simbn

	movf temp,0
	xorlw 'O'
	btfsc STATUS,Z	
	retlw simb0

	movf temp,0
	xorlw 'p'
	btfsc STATUS,Z	
	retlw simbP

	movf temp,0
	xorlw 'r'
	btfsc STATUS,Z	
	retlw simbr

	movf temp,0
	xorlw 'S'
	btfsc STATUS,Z	
	retlw simb5

	movf temp,0
	xorlw 't'
	btfsc STATUS,Z	
	retlw simbt

	movf temp,0
	xorlw 'U'
	btfsc STATUS,Z	
	retlw simbU

	movf temp,0
	xorlw '-'
	btfsc STATUS,Z	
	retlw simbmin

	movf temp,0
	xorlw ' '
	btfsc STATUS,Z	
	retlw empty
	return
;---------------------------------------------------------------------------
	end