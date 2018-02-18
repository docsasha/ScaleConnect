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
;макросы
;-----------------------------------------------------------------
;установка банка 0
SET_BANK0 MACRO 
	bcf STATUS, RP0
	bcf STATUS, RP1	
	ENDM
;---------------------------------------------------------------------
	code
;-----------------------------------------------------------------------
init_LCD;инициализация дисплея
	SET_BANK0
	bsf CS
	bcf WR
	lcall pause_5us 
	lcall SYS_EN ;команда SYS EN согласно документации на драйвер 100 000000011
	lcall RC_256K ;команда RC_256K согласно документации на драйвер 100 000110000
	lcall BIAS_1_3 ;команда BIAS ab=10:4 LCD 1/3 согласно документации на драйвер 100 001010011
	lcall LCD_OFF ;команда LCD OFF согласно документации на драйвер 100 000000100
	lcall TONE4K
	lcall TNORMAL
	lcall LCD_ON ;команда LCD ON согласно документации на драйвер 100 000000111
	return
;-------------------------------------------------------------------------
;LCD_Data_Duplicate(lcd_data_addr)
;lcd_data_addr - адрес ячейки начиная с которой располагается буфер считанных с весов данных 
;lcd_data_addr перед вызовом процедуры записывается в аккумулятор
LCD_Data_Duplicate
	banksel buf_temp
	movwf buf_temp
	addlw .18 ;bufer_count (LCD_bufer+18)
	movwf FSR
	movf INDF, 0
	movwf temp ;temp=bufer_count т.к. он идет сразу после самого буфера
	movf buf_temp, 0
	movwf FSR
	SET_BANK0
	bcf CS 
	lcall pause_5us ;пауза 5 мкс
	pagesel $
	banksel counter
next_dupl_byte
	movlw .8
	movwf counter
next_dupl_bit
	btfss INDF,7
	goto zero_dupl
	call SET_ONE ;подача логической единицы на драйвер дисплея
test_dupl_bit
	banksel temp
	decfsz temp,1 
	goto next_dupl ;если не все принятые биты переданы идем на передачу
	SET_BANK0
	bsf CS ;если все CS=1 и выходим
	return
next_dupl
	rlf INDF,1 ;
	decfsz counter,1 
	goto next_dupl_bit ;если еще не передан очередной байт
	incf FSR,1
	goto next_dupl_byte
zero_dupl
	call SET_ZERO ;подача логического нуля на драйвер дисплея	
	goto test_dupl_bit
;-------------------------------------------------------------------
;Отправка данных буфера в дисплей
;Data_to_LCD(lcd_data_addr)
;lcd_data_addr - адрес ячейки начиная с которой располагается буфер считанных с весов данных 
;16 байт начиная с адреса записанного в аккумулятор
Data_to_LCD
	banksel buf_temp
	movwf buf_temp ;адрес начала области вывода	
	call WRITE ;команда драйвера дисплея (запись данных) 101
	banksel counter	
	movlw .6 ;подаем начальный адрес 000000
	movwf counter
send_zero_4
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	banksel counter	
	decfsz counter,1
	goto send_zero_4
	;выводим данные 32*4 бит
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
	call SET_ONE ;подача логической единицы на драйвер дисплея
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
	btfss STATUS,Z ;если адрес уже 0х70 - заканчиваем отправку данных
	goto send_next_byte	
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_3us ;пауза 3 мкс
	pagesel $
	return
send_zero
	call SET_ZERO ;подача логического нуля на драйвер дисплея	
	goto shift_bit
;--------------------------------------------------------------------------
show_simb_pos ;вывести на экран символ код которого в аккумуляторе
;в simb_pos - позиция выводимого символа
;в функции мы нумеруем позиции слева направо / сверху вниз
;т.е. первая строка позиции 1-5
;вторая 6-10, третья 11-16
	movwf simb_temp
	call WRITE ;команда драйвера дисплея (запись данных) 101
	;преобразовываем адрес
	decf simb_pos,1 ;pos=pos-1
	comf simb_pos,0
	andlw 0x0F
	movwf temp
	rlf temp,1
	bcf temp,0	
	;передаем адрес
	movlw .6
	movwf counter
send_next_bit2
	btfss temp,5
	goto send_zero2
	call SET_ONE ;подача логической единицы на драйвер дисплея
shift_bit2
	rlf temp,1
	decfsz counter,1
	goto send_next_bit2
	;выводим данные 2*4 бит
	movlw .8
	movwf counter
send_next_bit3
	btfss simb_temp,7
	goto send_zero3
	call SET_ONE ;подача логической единицы на драйвер дисплея
shift_bit3
	rlf simb_temp,1
	decfsz counter,1
	goto send_next_bit3
	;поднимаем CS для того чтобы закончить передачу команды
	bsf CS ;CS=1
	call pause_5us ;пауза 3 мкс
	return
send_zero2
	call SET_ZERO ;подача логического нуля на драйвер дисплея	
	goto shift_bit2
send_zero3
	call SET_ZERO ;подача логического нуля на драйвер дисплея	
	goto shift_bit3
;-----------------------------------------------------------------------
SET_ZERO ;подача логического нуля на драйвер дисплея
	SET_BANK0
	bcf DATA_PIN ;DATA=0
	nop
	bsf WR ;WR=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	SET_BANK0
	bcf WR ;WR=0
	bcf DATA_PIN ;DATA=0
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	return
;--------------------------------------------------------------------------
SET_ONE ;подача логической единицы на драйвер дисплея
	SET_BANK0
	bsf DATA_PIN ;DATA=1
	nop
	bsf WR ;WR=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	SET_BANK0
	bcf WR ;WR=0
	bcf DATA_PIN ;DATA=0
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	return
;--------------------------------------------------------------------------
WRITE ;команда драйвера дисплея (запись данных) 101
	SET_BANK0
	bcf CS ;CS=0
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	return
;--------------------------------------------------------------------------
COMMAND;команда драйвера дисплея (команда кправления) 100
	bcf CS ;CS=0
	call pause_5us ;пауза 3 мкс
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	return
;--------------------------------------------------------------------------
TONE4K ;команда TONE4K согласно документации на драйвер 100 010000000
	call COMMAND;команда драйвера дисплея (команда управления) 100
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	bsf CS ;CS=1
	call pause_5us ;пауза 3 мкс
	return
;--------------------------------------------------------------------------
TNORMAL ;команда TNORMAL согласно документации на драйвер 100 111000111
	call COMMAND;команда драйвера дисплея (команда управления) 100
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	bsf CS ;CS=1
	call pause_5us ;пауза 3 мкс
	return
;--------------------------------------------------------------------------
SYS_EN ;команда SYS EN согласно документации на драйвер 100 000000011
	call COMMAND;команда драйвера дисплея (команда управления) 100
	banksel counter
	movlw .7
	movwf counter
send_zero_1
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	banksel counter
	decfsz counter,1
	goto send_zero_1	
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $	
	return
;--------------------------------------------------------------------------
RC_256K ;команда RC_256K согласно документации на драйвер 100 000110000
	call COMMAND;команда драйвера дисплея (команда управления) 100
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $
	return
;--------------------------------------------------------------------------
BIAS_1_3 ;команда BIAS ab=10:4 LCD 1/3 согласно документации на драйвер 100 001010011
	call COMMAND;команда драйвера дисплея (команда управления) 100
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $	
	return
;--------------------------------------------------------------------------
LCD_OFF ;команда LCD OFF согласно документации на драйвер 100 000000100
	call COMMAND;команда драйвера дисплея (команда управления) 100
	banksel counter
	movlw .6
	movwf counter
send_zero_2
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	banksel counter
	decfsz counter,1
	goto send_zero_2	
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $	
	return
;--------------------------------------------------------------------------
LCD_ON ;команда LCD ON согласно документации на драйвер 100 000000111
	call COMMAND;команда драйвера дисплея (команда управления) 100
	banksel counter
	movlw .6
	movwf counter
send_zero_3
	call SET_ZERO ;подача логического нуля на драйвер дисплея
	banksel counter
	decfsz counter,1
	goto send_zero_3	
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	call SET_ONE ;подача логической единицы на драйвер дисплея
	SET_BANK0
	bsf CS ;CS=1
	lcall pause_5us ;пауза 3 мкс
	pagesel $	
	return
;---------------------------------------------------------------------------
	end