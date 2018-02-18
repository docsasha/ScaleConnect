;Основной блок программы автоматической отправки данных о взвешиваниях
;информация об МК и конфигурационные биты
	include <MCSetup.inc>
;настройка выводов дисплея
	include <TM1621Setup.inc>
;коды дисплея
	include <TM1621.inc>
;объявляем переменные для главного модуля
	global LCD_bufer, bufer_count

	udata
;переменные для захвата данных с дисплея
LCD_bufer 	res .18 ;адрес ячейки начиная с которой располагается буфер
bufer_count	res .1 ;счетчик общего количества принятых бит (должен распологаться сразу после буфера)
bit_buffer	res .1 ;счетчик бит при захвате с дисплея
byte_buffer	res .1 ;счетчик байт при захвате с дисплея
;-----------------------------------------
	extern simb_pos, Display_Data  ;<TM1621LCD.asm>
	extern init_LCD, LCD_Data_Duplicate, PrintSimb, PrintMsg ;<TM1621LCD.asm>
	extern pause_5s, pause_05s ;<pauses_20MHz.asm>
	extern LCD_Data_Recognize ;<TM1621Recognize.asm>
	extern seg1_1,seg1_2,seg1_3,seg1_4,seg1_5;<TM1621Recognize.asm>
	extern seg2_1,seg2_2,seg2_3,seg2_4,seg2_5;<TM1621Recognize.asm>
	extern seg3_1,seg3_2,seg3_3,seg3_4,seg3_5,seg3_6;<TM1621Recognize.asm>
	extern koma;<TM1621Recognize.asm>

;подключаем внешние программные модули

;макросы

;пишем начальные значения ППЗУ

	org 0x0000
	goto start
	org 0x0004 ;вектор прерываний
;-----------------------------------------------------------------------
	bcf INTCON,7 ;запрещаем прерывания
;Захват данных с дисплея весов
	include <TM1621Capture.inc> ;захват даныых с дисплея
	include <TM1621ClrBuf.inc>  ;очистка указателей на буфер дисплея
;-----------------------------------------------------------------------	
start
	lcall initMC;<initMC.inc> Инициализация микроконтроллера
	lcall init_LCD;<TM1621LCD.asm> инициализация дисплея	
	lcall pause_05s ;<pauses_20MHz.asm>пауза
	lcall clr_bufer ;<TM1621ClrBuf.inc> очистка указателей на буфер дисплея
	pagesel $
	;тестируем функции печати
	banksel seg1_1
	movlw 'H'
	movwf seg1_1
	movlw 'E'
	movwf seg1_2
	movlw 'L'
	movwf seg1_3
	movlw 'L'
	movwf seg1_4
	movlw 'O'
	movwf seg1_5	
	movlw 'H'
	movwf seg2_1
	movlw 'E'
	movwf seg2_2
	movlw 'L'
	movwf seg2_3
	movlw 'L'
	movwf seg2_4
	movlw 'O'
	movwf seg2_5
	movlw 'H'
	movwf seg3_1
	movlw 'E'
	movwf seg3_2
	movlw 'L'
	movwf seg3_3
	movlw 'L'
	movwf seg3_4
	movlw 'O'
	movwf seg3_5
	movlw ' '
	movwf seg3_6
	movlw seg1_1		
	lcall PrintMsg
	lcall pause_5s
	pagesel $
	bsf INTCON,7
	goto $
	
;Распознавание пришедших данных

;Определяем превышен ли минимальный вес реакции

;Если превышен засекаем установленное в настройках время

;Если время прошло, а данные не поменялись - отправляем их на сервер

;Если отправка не удалась - сохраняем данные во внутренней памяти

;Инициализация микроконтроллера
	include <initMC.inc>
	goto $
	end