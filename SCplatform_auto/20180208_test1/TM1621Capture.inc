;������ ������ � ����� �� ������� TM1621
;�������� � ���� ������������� ����� �.�. ���������� � ���� ��������� ����������
;���� ������� � ������������� ������ � �����
;- ��������� � ��������� � ������ ����� ���������� �� �������
;LCD_Data_Capture(LCD_bufer)  
;LCD_bufer � ����� ������ ������� � ������� ������������� ����� ��� ������ ������ � ������� ����������� � ����� ��������� �������� ���������� 
LCD_Data_Capture
	;��� ������ ����� CS ���� � ������ ��������� ���� �������� �� WR
	;banksel bit_buffer
next_lcd_byte
	movlw .8	
	movwf bit_buffer
next_lcd_bit
	;���� �� WR ������ ������� ��������� ��������� ��� � ������
wait_WR0;���� WR �������
	btfsc CS_IN ;�� ������� �� ����������� ���������� ���� CS � ������ ���������
	goto test_lcd_bytes
	btfsc WR_IN
	goto wait_WR0
wait_WR1
	btfsc CS_IN ;�� ������� �� ����������� ���������� ���� CS � ������ ���������
	goto test_lcd_bytes
	btfss WR_IN
	goto wait_WR1
	;WR ������� ������ ���������
	rlf INDF,1 ;�������� �����
	bcf INDF, 0
	btfsc DATA_IN
	bsf INDF,0;DATA=1
	incf bufer_count, 1 ;����������� ������� ������ ���������� �������� ���
	;��������� ���������� �� �� ��� 8 ���
	decfsz bit_buffer,1
	goto next_lcd_bit ;���� ��� ���� ������������ ���������
	incf byte_buffer,1 ;���� �� ��������� � ���������� �����
	incf FSR,1 ;��������� � ��������� ������ �������� LCD_bufer�
	decfsz byte_buffer,1
	goto next_lcd_byte
	goto exit_int;���� �������� ��� 18 - ��� ���� ������� (!!! ������ �� ������)
test_lcd_bytes	
	;���� ������ 3 ���� �� 101 (������� ������) - ���������� - �������
	banksel LCD_bufer
	movf LCD_bufer, 0
	andlw 0xE0
	xorlw 0xA0
	btfss STATUS, Z
	goto exit_int ;������ ��� �� ������� ������� ������� ������� - �������	
	;���� CS ������� � �������, � �� ���������� ���� �� 12 ��� - ��� �������� ���
	movlw .12
	banksel bufer_count
	subwf bufer_count,0 ;W=bufer_count-12
	btfss STATUS, C
	goto exit_int;���� bufer_count ������ 12 �������
	;���� bufer_count ������ ��� ����� 12 ���� ������
	;���� CS ������� � �������, � �� ���������� ������ ��� ����� 42 ���� - ��� �������� ���
	movlw .138
	subwf bufer_count,0 ;W=bufer_count-138
	btfsc STATUS, C
	goto exit_int;���� bufer_count ������ ��� ����� 138 �������
	;���� bufer_count ������ 138 ���� ������

	;!!!��������� ���������� �������� ��� � ��������� ����� ����� 
	;���� �� ������ 8 ����� ��������� � �������� �� ��������������� �����
 	btfsc LCD_bufer+.17,0;!!!!!!��������	
	bsf LCD_bufer+.17,7;!!!!!!��������
	goto temp_exit ;!!!!!!�������� ���������� ��� ���������
;	movlw 0x07
;	andwf bufer_count,0
;	btfsc STATUS,Z
;	goto dupl_recog	;���� �� ���� �������� ��� ������
;	sublw .8 ;W=8-W ��� �� ������� ����� �������� ��������� ����
;	movwf temp
;shft_last
;	rlf INDF,1
;	decfsz temp,1
;	goto shft_last	
temp_exit ;!!!!!!��������
;!!!!!!!!!!!!��� ����� ���� ������������� � �.�.
	movlw LCD_bufer
	lcall LCD_Data_Duplicate ;<TM1621LCD.asm>
exit_int
	lcall clr_bufer ;<TM1621ClrBuf.inc>;��������� ������� ������ ���������� � ������� ������
	pagesel $
	SET_BANK0
	retfie