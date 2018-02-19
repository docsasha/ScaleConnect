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
;подключаем внешние программные модули
	;подключение модуля вывода на дисплей
	extern simb_pos, Display_Data, Data_to_LCD  ;<TM1621LCD.asm>
	extern init_LCD, LCD_Data_Duplicate, PrintSimb,PrintMsg  ;<TM1621LCD.asm>
	extern PrintFirstStr, PrintSecondStr, PrintThirdStr;<TM1621LCD.asm>
	extern SetKoma, ClrKoma, KomaPos, koma_set
	;подключение модуля пауз
	extern pause_5s, pause_1s, pause_05s ;<pauses_20MHz.asm>
	;подключение модуля распознавания данных выводимых весами на дисплей
	extern LCD_Data_Recognize ;<TM1621Recognize.asm>
	extern seg1_1,seg1_2,seg1_3,seg1_4,seg1_5;<TM1621Recognize.asm>
	extern seg2_1,seg2_2,seg2_3,seg2_4,seg2_5;<TM1621Recognize.asm>
	extern seg3_1,seg3_2,seg3_3,seg3_4,seg3_5,seg3_6;<TM1621Recognize.asm>
	extern koma;<TM1621Recognize.asm>
	;подключение модуля Tiny RTC - работа с часами DS1307

	;подключение модуля Tiny RTC - работа с ППЗУ 24C32N	
	

;-----------------------------------------------------------------------
;макросы
	include <macroTM1621.inc>
;1)печать всех разрядов дисплея в видестроки !без запятых (16 символов)
;PRINT_STR MACRO S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16 
;2)печать первой строки !без запятых (5 символов)
;PRINT_STR_1 MACRO S1,S2,S3,S4,S5  
;3)печать 2ой строки !без запятых (5 символов)
;PRINT_STR_2 MACRO S1,S2,S3,S4,S5 
;4)печать 3й строки !без запятых (6 символов)
;PRINT_STR_3 MACRO S1,S2,S3,S4,S5,S6 
;5)установить запятую в позицию POS (1-16)
;SET_KOMA MACRO POS
;6)удалить запятую в позиции POS (1-16)
;CLR_KOMA MACRO POS  
;7)Напечатать символ SIMB в позиции POS
;PRINT_SIMB MACRO SIMB, POS
;-----------------------------------------------------------------------

;пишем начальные значения ППЗУ

	org 0x0000
	goto start
	org 0x0004 ;вектор прерываний
;-----------------------------------------------------------------------
	bcf INTCON,7 ;запрещаем прерывания
	;выясняем источник прерывания
	;btfsc PIR1,0 ;(TMR1IF)
	;goto TMR1_int ;идем на обработку прерывания от таймера 1

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
	banksel koma
	clrf koma
	clrf koma+.1

	PRINT_STR 'H','E','L','L','O',' ','F','O','r',' ',' ','A','L','L',' ',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .1
	lcall pause_1s
	pagesel $

	PRINT_STR_1 ' ','b','Y','E',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .2
	lcall pause_1s
	pagesel $

	PRINT_STR_2 ' ','n','n','Y',' '
	lcall pause_1s
	pagesel $

	SET_KOMA .3
	lcall pause_1s
	pagesel $

	PRINT_STR_3 'F','r','1','E','n','d'
	lcall pause_1s
	pagesel $

;	CLR_KOMA .5 
;	lcall pause_1s
;	pagesel $

	PRINT_SIMB 'd', .6
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'E', .7
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'A', .8
	lcall pause_1s
	pagesel $
	PRINT_SIMB 'r', .9
	lcall pause_1s
	pagesel $
	PRINT_SIMB ' ', .10
	lcall pause_1s
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