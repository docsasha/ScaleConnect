	list p=16f887
	include <p16f887.inc>
	extern pause_5us, pause_3us ;<pauses_20MHz.asm>	
	global simb_pos, Display_Data
	global init_LCD, LCD_Data_Duplicate, Data_to_LCD
	global LCD_ON, LCD_OFF, PrintSimb, PrintMsg
	global PrintFirstStr, PrintSecondStr, PrintThirdStr
	global SetKoma, ClrKoma, KomaPos, koma_set

	#define CS PORTB,4
	#define WR PORTB,5
	#define DATA_PIN PORTB,7

;���� �������
	include <TM1621.inc>

	udata
simb_pos	res 1
Display_Data res .16 ;������� ���������� ���� ��� ������ �� �����
KomaPos		res 1
	udata_ovr
temp 		res 1
buf_temp 	res 1
counter 	res 1
simb_temp 	res 1
temp2		res 1
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
;SimbCode - ASCII ��� ���������� ������� ��� ������ �������� � �����������
;Simb_Pos � ������� � ������� �������� ������ (�� 1 �� 16: 1-5 ������ ������, 6-10 ������ ������, 11-16 ������ ������)
PrintSimb
	lcall ASCII_to_LCDcode ;w=LCDcode(ASCIIcode)
	pagesel $
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp

	movf simb_pos,0
	sublw .16 ;w=16-simb_pos
	addlw Display_Data ;w=Display_Data+16-simb_pos
	movwf FSR
	movf buf_temp,0
	movwf INDF

	movf simb_temp,0
	movwf FSR ;��������������� FSR
	
	movlw Display_Data
	call Data_to_LCD
	return
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
	addlw Display_Data ;W=[Display_Data]+counter-1 �.�. ����� ������ ������ � ���. ���� ������
	movwf FSR
	movf temp,0
	movwf INDF ;Display_Data[j]=LCDcode[i]
	incf buf_temp,1
	decfsz counter,1
	goto nextASCII

	movf buf_temp,0 ;������ ����� ����� ������� ������� 
	call koma_set ;����������� �������
	
	movf simb_temp,0
	movwf FSR ;��������������� FSR
	return
;-----------------------------------------------------------------------
;��������� ������� � ����������� �� ��������� ���������� ����������
;� ���� ������ ������� � ������ ���������� � ������������
koma_set
	banksel temp
	movwf FSR
	movf INDF,0
	movwf temp
	incf FSR,1
	movf INDF,0
	movwf temp2

	movlw Display_Data ;���������� ������� ��� ������� 
	movwf FSR ;���� ����� ��������� � ������ �����
	movlw .16
	movwf counter
next_koma
	bcf INDF, 7
	incf FSR,1
	decfsz counter,1
	goto next_koma	

koma_set1
	;����� � ��� 7� ��� ���� ������� ������� ��������� koma � ������ �� ���� �����
	btfsc temp,7
	bsf Display_Data+.15,7
	btfsc temp,6
	bsf Display_Data+.14,7
	btfsc temp,5
	bsf Display_Data+.13,7
	btfsc temp,4
	bsf Display_Data+.12,7
	btfsc temp,3
	bsf Display_Data+.11,7
koma_set2
	btfsc temp,2
	bsf Display_Data+.10,7
	btfsc temp,1
	bsf Display_Data+.9,7
	btfsc temp,0
	bsf Display_Data+.8,7
	btfsc temp2,7
	bsf Display_Data+.7,7
	btfsc temp2,6
	bsf Display_Data+.6,7
koma_set3
	btfsc temp2,5
	bsf Display_Data+.5,7
	btfsc temp2,4
	bsf Display_Data+.4,7
	btfsc temp2,3
	bsf Display_Data+.3,7
	btfsc temp2,2
	bsf Display_Data+.2,7
	btfsc temp2,1
	bsf Display_Data+.1,7
	btfsc temp2,0
	bsf Display_Data,7
	return
;-----------------------------------------------------------------------
;- ���������� �������
;SetKoma(komaPos)
;KomaPos � ������ ����� ������� ���� ��������� �������
;� ������������ ����� ������� �� ���� ���� � ��������� �������
SetKoma
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp
	movf buf_temp,0
	movwf FSR
	banksel KomaPos
	movf KomaPos,0
	xorlw .1
	btfsc STATUS,Z
	bsf INDF,7
	movf KomaPos,0
	xorlw .2
	btfsc STATUS,Z
	bsf INDF,6
	movf KomaPos,0
	xorlw .3
	btfsc STATUS,Z
	bsf INDF,5
	movf KomaPos,0
	xorlw .4
	btfsc STATUS,Z
	bsf INDF,4
	movf KomaPos,0
	xorlw .5
	btfsc STATUS,Z
	bsf INDF,3
	movf KomaPos,0
	xorlw .6
	btfsc STATUS,Z
	bsf INDF,2
	movf KomaPos,0
	xorlw .7
	btfsc STATUS,Z
	bsf INDF,1
	movf KomaPos,0
	xorlw .8
	btfsc STATUS,Z
	bsf INDF,0
	incf FSR,1
	movf KomaPos,0
	xorlw .9
	btfsc STATUS,Z
	bsf INDF,7
	movf KomaPos,0
	xorlw .10
	btfsc STATUS,Z
	bsf INDF,6
	movf KomaPos,0
	xorlw .11
	btfsc STATUS,Z
	bsf INDF,5
	movf KomaPos,0
	xorlw .12
	btfsc STATUS,Z
	bsf INDF,4
	movf KomaPos,0
	xorlw .13
	btfsc STATUS,Z
	bsf INDF,3
	movf KomaPos,0
	xorlw .14
	btfsc STATUS,Z
	bsf INDF,2
	movf KomaPos,0
	xorlw .15
	btfsc STATUS,Z
	bsf INDF,1
	movf KomaPos,0
	xorlw .16
	btfsc STATUS,Z
	bsf INDF,0
	movf simb_temp,0
	movwf FSR ;��������������� FSR
	return
;-----------------------------------------------------------------------
;- ������ �������
;ClrKoma(komaPos)
;KomaPos � ������ ����� ������� ���� ������ �������
;� ������������ ����� ������� �� ���� ���� � ��������� �������
ClrKoma
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp
	movf buf_temp,0
	movwf FSR
	banksel KomaPos
	movf KomaPos,0
	xorlw .1
	btfsc STATUS,Z
	bcf INDF,7
	movf KomaPos,0
	xorlw .2
	btfsc STATUS,Z
	bcf INDF,6
	movf KomaPos,0
	xorlw .3
	btfsc STATUS,Z
	bcf INDF,5
	movf KomaPos,0
	xorlw .4
	btfsc STATUS,Z
	bcf INDF,4
	movf KomaPos,0
	xorlw .5
	btfsc STATUS,Z
	bcf INDF,3
	movf KomaPos,0
	xorlw .6
	btfsc STATUS,Z
	bcf INDF,2
	movf KomaPos,0
	xorlw .7
	btfsc STATUS,Z
	bcf INDF,1
	movf KomaPos,0
	xorlw .8
	btfsc STATUS,Z
	bcf INDF,0
	incf FSR,1
	movf KomaPos,0
	xorlw .9
	btfsc STATUS,Z
	bcf INDF,7
	movf KomaPos,0
	xorlw .10
	btfsc STATUS,Z
	bcf INDF,6
	movf KomaPos,0
	xorlw .11
	btfsc STATUS,Z
	bcf INDF,5
	movf KomaPos,0
	xorlw .12
	btfsc STATUS,Z
	bcf INDF,4
	movf KomaPos,0
	xorlw .13
	btfsc STATUS,Z
	bcf INDF,3
	movf KomaPos,0
	xorlw .14
	btfsc STATUS,Z
	bcf INDF,2
	movf KomaPos,0
	xorlw .15
	btfsc STATUS,Z
	bcf INDF,1
	movf KomaPos,0
	xorlw .16
	btfsc STATUS,Z
	bcf INDF,0
	movf simb_temp,0
	movwf FSR ;��������������� FSR
	return
;-----------------------------------------------------------------------
;- ������� ��������� � ������ ������
;PrintFirstStr(MsgAddr)
;MsgAddr � ����� ������ ������� ������ ��� �������� 5 �������� � ASCII ���� ��� ������ � ������ ������
;- ������� ��������� �� ������ ������
;����� ������ ������� 5 ���� ��������� � ������������
;����� ������� 16 ���� ������� � Display_Data
PrintFirstStr
;�� ���� ���� ����� ��� � ��� ����� ������� 
;������ ��� ��������� ��������������� ������ ASCII ���� ������ ������
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp

	movlw .5
	movwf counter
nextASCII_1
	movf buf_temp,0
	movwf FSR
	movf INDF,0 ;W=ASCII[i]
	lcall ASCII_to_LCDcode ;w=LCDcode[i]
	pagesel $
	movwf temp
	movlw .10
	addwf counter,0 ;W=counter+10
	addlw Display_Data ;W=[Display_Data]+counter+10 �.�. ����� ������ ������ � ���. ���� ������
	movwf FSR
	movf temp,0
	movwf INDF ;Display_Data[j]=LCDcode[i]
	incf buf_temp,1
	decfsz counter,1
	goto nextASCII_1

	movf buf_temp,0
	addlw .11 ;����� ������� �������
	call koma_set ;����������� �������

	movf simb_temp,0
	movwf FSR ;��������������� FSR
	
	movlw Display_Data
	call Data_to_LCD
	return
;-----------------------------------------------------------------------
;- ������� ��������� � 2�� ������
;PrintSecondStr(MsgAddr)
;MsgAddr � ����� ������ ������� ������ ��� �������� 5 �������� � ASCII ���� ��� ������ � ������ ������
;- ������� ��������� �� ������ ������
;����� ������ ������� 5 ���� ��������� � ������������
;����� ������� 16 ���� ������� � Display_Data
PrintSecondStr
;�� ���� ���� ����� ��� � ��� ����� ������� 
;������ ��� ��������� ��������������� ������ ASCII ���� 2�� ������
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp

	movlw .5
	movwf counter
nextASCII_2
	movf buf_temp,0
	movwf FSR
	movf INDF,0 ;W=ASCII[i]
	lcall ASCII_to_LCDcode ;w=LCDcode[i]
	pagesel $
	movwf temp
	movlw .5
	addwf counter,0 ;W=counter+5
	addlw Display_Data ;W=[Display_Data]+counter+5 �.�. ����� ������ ������ � ���. ���� ������
	movwf FSR
	movf temp,0
	movwf INDF ;Display_Data[j]=LCDcode[i]
	incf buf_temp,1
	decfsz counter,1
	goto nextASCII_2

	movf buf_temp,0
	addlw .6 ;����� ������� ������� 
	call koma_set ;����������� �������

	movf simb_temp,0
	movwf FSR ;��������������� FSR
	
	movlw Display_Data
	call Data_to_LCD
	return
;-----------------------------------------------------------------------
;- ������� ��������� � 3� ������
;PrintThirdStr(MsgAddr)
;MsgAddr � ����� ������ ������� ������ ��� �������� 6 �������� � ASCII ���� ��� ������ � ������ ������
;- ������� ��������� �� ������ ������
;����� ������ ������� 6 ���� ��������� � ������������
;����� ������� 16 ���� ������� � Display_Data
PrintThirdStr
;�� ���� ���� ����� ��� � ��� ����� ������� 
;������ ��� ��������� ��������������� ������ ASCII ���� 3� ������
	banksel buf_temp
	movwf buf_temp
	movf FSR,0 ;��������� FSR
	movwf simb_temp

	movlw .6
	movwf counter
nextASCII_3
	movf buf_temp,0
	movwf FSR
	movf INDF,0 ;W=ASCII[i]
	lcall ASCII_to_LCDcode ;w=LCDcode[i]
	pagesel $
	movwf temp
	decf counter,0 ;W=counter-1
	addlw Display_Data ;W=[Display_Data]+counter-1 �.�. ����� ������ ������ � ���. ���� ������
	movwf FSR
	movf temp,0
	movwf INDF ;Display_Data[j]=LCDcode[i]
	incf buf_temp,1
	decfsz counter,1
	goto nextASCII_3

	movf buf_temp,0 ;����� ������� �������
	call koma_set ;����������� �������

	movf simb_temp,0
	movwf FSR ;��������������� FSR
	
	movlw Display_Data
	call Data_to_LCD
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
	xorlw 'Y'
	btfsc STATUS,Z	
	retlw simbY

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