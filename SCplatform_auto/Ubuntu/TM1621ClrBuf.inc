;���������� � ������� ������ ����� �������
clr_bufer
	banksel bufer_count 
	clrf bufer_count 
	movlw LCD_bufer ;������ ������
	movwf FSR
	movlw .18 ;
	movwf byte_buffer ;������� ����������� ���� ������
	clrf LCD_bufer+.17
	return