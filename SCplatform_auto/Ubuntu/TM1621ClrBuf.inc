;подготовка и очистка буфера перед записью
clr_bufer
	banksel bufer_count 
	clrf bufer_count 
	movlw LCD_bufer ;начало буфера
	movwf FSR
	movlw .18 ;
	movwf byte_buffer ;счетчик заполненных байт буфера
	clrf LCD_bufer+.17
	return