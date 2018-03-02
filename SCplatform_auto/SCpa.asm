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
;вспомогательные переменные
loop_cnt	res .1 ;счетчик цикла
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
	extern HH,MM,SS,WD,DD,MO,YY ;<RTCTime.asm>
	extern ReadRTCData, ReadTime, ReadDate, ReadDayofWeek;<RTCTime.asm>
	extern WriteRTC, WriteTime, WriteDate, WriteDayofWeek;<RTCTime.asm>
	;подключение модуля работы с встроенным ППЗУ
	extern ee_read, ee_write ;<EEPROM.asm>
	;подключение модуля для работы с UART
	extern TX_LEN, UART_TX_ON, UART_TX_OFF;<UART.asm>
	extern UART_Setup, SendBytetoUART, SendPackettoUART, GetUARTByte;<UART.asm>
	extern UART_Buf ;<UART.asm>
	;подключение модуля Tiny RTC - работа с ППЗУ 24C32N	
	extern MEM_ADDR_H, MEM_ADDR_L, MEM_LEN, R_BUFFER;<RTCEEPROM.asm>
	extern WriteADDR, WriteBlock, ReadADDR, ReadBlock	;<RTCEEPROM.asm>
;-----------------------------------------------------------------------
;макросы
	include <macroTM1621.inc>
;1)печать всех разрядов дисплея в виде строки !без запятых (16 символов)
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
;8)Напечатать значение переменной VAL в позиции POS
;PRINT_VAL MACRO VAL, POS ;POS 1..16
	include <macroTinyRTC.inc>
;1)макрос записи показателей времени из констант - данные записанны в формате BCD
;WRITE_RTC MACRO HOURS, MINUTES, SECONDS, DAY_of_WEEK, DATE, MONTH, YEAR
;2)макрос записи времени из констант - данные записанны в формате BCD
;WRITE_TIME MACRO HOURS, MINUTES, SECONDS
;3)макрос записи даты из констант - данные записанны в формате BCD
;WRITE_DATE MACRO DATE, MONTH, YEAR
;4)макрос записи дня недели из константы - данные записанны в формате BCD
;WRITE_DAY_of_WEEK MACRO DAY_of_WEEK
;5)макрос вывода в третью строку текущего времени (переменные HH,MM,SS)
;TIME_to_3STR MACRO
;6)макрос вывода во вторую строку текущей даты (переменные DD,MO)
;DATE_to_2STR MACRO
;7)макрос вывода во вторую строку текущего года 20ХХ (переменная YY)
;YEAR_to_2STR MACRO
;8)макрос вывода в 1ю строку текущего дня недели (переменная WD)
;DW_to_1STR MACRO
;9)макрос записи показателей времени из ППЗУ начиная с адреса TIMEADDR - данные записанны в формате BCD
;WRITE_RTC_EE MACRO TIMEADDR
	include <macroUART.inc>
;1)макрос отправки в порт значения переменной
;UART_SEND_VAL MACRO VAL
;2)макрос отправки в порт константы
;UART_SEND_CONST MACRO CONST
;3)макрос отправки в порт значений записанных в области начиная с BEGIN_ADDR
;длиной SEND_LEN (до 8 байт)
;UART_SEND_MEM MACRO BEGIN_ADDR, SEND_LEN
;-----------------------------------------------------------------------

;пишем начальные значения ППЗУ
	Org 0x2100;пишем в ППЗУ (по адресу 0x00) выставляемое в модуль часов время
	DE 0x16 ;часы
	DE 0x45 ;минуты
	DE 0x00 ;секунды
	DE .3  ;день недели
	DE 0x21 ;число
	DE 0x02 ;месяц
	DE 0x18 ;год 

;основной блок программы
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
	lcall UART_Setup ;<UART.asm> настраиваем модуль UART
	lcall init_LCD;<TM1621LCD.asm> инициализация дисплея	
	lcall pause_05s ;<pauses_20MHz.asm>пауза
	lcall clr_bufer ;<TM1621ClrBuf.inc> очистка указателей на буфер дисплея
	lcall UART_TX_ON ;<UART.asm> включаем передатчик
	pagesel $
	;тестируем функции печати
	banksel koma
	clrf koma
	clrf koma+.1

	;пишем время в часы
	WRITE_RTC_EE 0x00
	;WRITE_RTC 0x17, 0x30, 0x00,.5, 0x02, 0x03, 0x18
	
time_to_LCD
	;читаем время и дату из часов
	lcall ReadTime
	pagesel $
	;выводим день недели в 1ю строку
	DW_to_1STR 
	;выводим дату во 2ю строку
	DATE_to_2STR
	;выводим время в 3ю строку
	TIME_to_3STR

	UART_SEND_VAL SS

	UART_SEND_MEM HH, 7

	lcall pause_1s
	pagesel $
;	bsf INTCON,7
	goto time_to_LCD

;Распознавание пришедших данных

;Определяем превышен ли минимальный вес реакции

;Если превышен засекаем установленное в настройках время

;Если время прошло, а данные не поменялись - отправляем их на сервер

;Если отправка не удалась - сохраняем данные во внутренней памяти

;Инициализация микроконтроллера
	include <initMC.inc>
	goto $
	end