	title "Блок для работы с ППЗУ"
	list p=16f887
	include <p16f887.inc>
	global ee_read, ee_write


	code
;=======процедура чтения байта из EEPROM с адреса записанного в аккумуляторе======
ee_read
	banksel EEADR
	movwf EEADR
	banksel EECON1	
	bsf EECON1,RD ;инициализация чтения - адрес должен задаваться заранее
	nop ;пауза чтоб успеть
	nop
	banksel EEDATA
	movf EEDATA,0 ;сохраняем в аккумулятор считаные данные
	nop
	bcf STATUS,RP1;переход в 0й банк ;!!!!!
	bcf STATUS,RP0;!!!!!

	RETURN
;=== процедура записи байта в EEPROM записываемые данные находятся в аккумуляторе==
;адрес ячейки для записи устанавливает до вызова процедуры
ee_write
	banksel EEDATA
	movwf EEDATA
	banksel EECON1
	bsf EECON1,WREN ;разрешаем запись - адрес должен задаваться заранее
	movlw 0x55
	movwf EECON2
	movlw 0xAA
	movwf EECON2
	bsf EECON1,WR ;начинаем запись
	nop
	nop
wr
	btfsc EECON1,WR ;ждем окончания записи
	goto wr
	bcf EECON1,WREN ;запрещаем запись
	bcf STATUS,RP1;переход в 0й банк
	bcf STATUS,RP0
	RETURN
;------------------------------------------------------------------------
	end