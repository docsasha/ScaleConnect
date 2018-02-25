;Захват данных с весов на драйвер TM1621
;выполнен в виде встраиваемого файла т.к. помещается в блок обработки прерываний
;Блок захвата и распознавания данных с весов
;- Захватить и сохранить в памяти пакет подаваемый на дисплей
;LCD_Data_Capture(LCD_bufer)  
;LCD_bufer – адрес ячейки начиная с которой располагается буфер для чтения данных – функция размещается в блоке обработки внешнего прерывания 
LCD_Data_Capture
	;как только вывод CS ушел в нижнее состояние ждем высокого на WR
	;banksel bit_buffer
next_lcd_byte
	movlw .8	
	movwf bit_buffer
next_lcd_bit
	;если на WR пришло высокое сохраняем очередной бит в память
wait_WR0;ждем WR низкого
	btfsc CS_IN ;не выходим из обработчика прерывания пока CS в низком состоянии
	goto test_lcd_bytes
	btfsc WR_IN
	goto wait_WR0
wait_WR1
	btfsc CS_IN ;не выходим из обработчика прерывания пока CS в низком состоянии
	goto test_lcd_bytes
	btfss WR_IN
	goto wait_WR1
	;WR высокое значит сохраняем
	rlf INDF,1 ;сдвигаем влево
	bcf INDF, 0
	btfsc DATA_IN
	bsf INDF,0;DATA=1
	incf bufer_count, 1 ;увеличиваем счетчик общего количества принятых бит
	;проверяем обработали ли мы уже 8 бит
	decfsz bit_buffer,1
	goto next_lcd_bit ;если нет идем обрабатывать следующий
	incf byte_buffer,1 ;если да переходим к следующему байту
	incf FSR,1 ;переходим к следующей ячейке хранения LCD_buferХ
	decfsz byte_buffer,1
	goto next_lcd_byte
	goto exit_int;если значение уже 18 - это явно перебор (!!! данные не верные)
test_lcd_bytes	
	;если первые 3 бита не 101 (команда записи) - игнорируем - выходим
	banksel LCD_bufer
	movf LCD_bufer, 0
	andlw 0xE0
	xorlw 0xA0
	btfss STATUS, Z
	goto exit_int ;значит это не команда которая выводит символы - выходим	
	;если CS перешло в высокое, а не накопилось хотя бы 12 бит - это мусорный код
	movlw .12
	banksel bufer_count
	subwf bufer_count,0 ;W=bufer_count-12
	btfss STATUS, C
	goto exit_int;если bufer_count меньше 12 выходим
	;если bufer_count больше или равно 12 идем дальше
	;если CS перешло в высокое, а не накопилось больше или равно 42 бита - это мусорный код
	movlw .138
	subwf bufer_count,0 ;W=bufer_count-138
	btfsc STATUS, C
	goto exit_int;если bufer_count больше или равно 138 выходим
	;если bufer_count меньше 138 идем дальше

	;!!!поскольку количество принятых бит в последнем байте может 
	;быть не кратно 8 нужно проверить и сдвинуть на соответствующее число
 	btfsc LCD_bufer+.17,0;!!!!!!временно	
	bsf LCD_bufer+.17,7;!!!!!!временно
	goto temp_exit ;!!!!!!временно пропускаем эту процедуру
;	movlw 0x07
;	andwf bufer_count,0
;	btfsc STATUS,Z
;	goto dupl_recog	;если не надо сдвигать дем дальше
;	sublw .8 ;W=8-W тут на сколько нужно сдвинуть последний байт
;	movwf temp
;shft_last
;	rlf INDF,1
;	decfsz temp,1
;	goto shft_last	
temp_exit ;!!!!!!временно
;!!!!!!!!!!!!ТУТ МОЖЕТ БЫТЬ РАСПОЗНОВАНИЕ И Т.Д.
	movlw LCD_bufer
	lcall LCD_Data_Duplicate ;<TM1621LCD.asm>
exit_int
	lcall clr_bufer ;<TM1621ClrBuf.inc>;процедура очистки буфера полученных с дисплея данных
	pagesel $
	SET_BANK0
	retfie