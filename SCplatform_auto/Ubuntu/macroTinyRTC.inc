;макросы для работы с модулем часов реального времени
;------------------------------------------------------------------------
;макрос записи показателей времени из констант - данные записанны в формате BCD
WRITE_RTC MACRO HOURS, MINUTES, SECONDS, DAY_of_WEEK, DATE, MONTH, YEAR
	banksel HH
	movlw HOURS
	movwf HH
	movlw MINUTES
	movwf MM
	movlw SECONDS
	movwf SS
	movlw YEAR
	movwf YY
	movlw MONTH
	movwf MO
	movlw DATE
	movwf DD
	movlw DAY_of_WEEK
	movwf WD
	lcall WriteRTC
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос записи времени из констант - данные записанны в формате BCD
WRITE_TIME MACRO HOURS, MINUTES, SECONDS
	banksel HH
	movlw HOURS
	movwf HH
	movlw MINUTES
	movwf MM
	movlw SECONDS
	movwf SS
	lcall WriteTime
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос записи даты из констант - данные записанны в формате BCD
WRITE_DATE MACRO DATE, MONTH, YEAR
	banksel YY	
	movlw YEAR
	movwf YY
	movlw MONTH
	movwf MO
	movlw DATE
	movwf DD
	lcall WriteDate
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос записи дня недели из константы - данные записанны в формате BCD
WRITE_DAY_of_WEEK MACRO DAY_of_WEEK
	banksel WD
	movlw DAY_of_WEEK
	movwf WD
	lcall WriteDayofWeek
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос вывода в третью строку текущего времени (переменные HH,MM,SS)
TIME_to_3STR MACRO
	banksel HH
	swapf HH,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_1
	movwf seg3_1

	banksel HH
	movf HH,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_2
	movwf seg3_2

	banksel MM
	swapf MM,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_3
	movwf seg3_3

	banksel MM
	movf MM,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_4
	movwf seg3_4

	banksel SS
	swapf SS,0
	andlw 0x0F
	addlw 0x30
	banksel seg3_5
	movwf seg3_5

	banksel SS
	movf SS,0
	andlw 0x0F
	addlw 0x30	
	banksel seg3_6
	movwf seg3_6
	
	movlw seg3_1		
	lcall PrintThirdStr
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос вывода во вторую строку текущей даты (переменные DD,MO)
DATE_to_2STR MACRO
	banksel DD
	swapf DD,0
	andlw 0x0F
	addlw 0x30
	banksel seg2_1
	movwf seg2_1

	banksel DD
	movf DD,0
	andlw 0x0F
	addlw 0x30	
	banksel seg2_2
	movwf seg2_2
	movlw '-'
	movwf seg2_3

	banksel MO
	swapf MO,0
	andlw 0x0F
	addlw 0x30
	banksel seg2_4
	movwf seg2_4

	banksel MO
	movf MO,0
	andlw 0x0F
	addlw 0x30	
	banksel seg2_5
	movwf seg2_5

	movlw seg2_1		
	lcall PrintSecondStr
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос вывода во вторую строку текущего года 20ХХ (переменная YY)
YEAR_to_2STR MACRO
	banksel seg2_1
	movlw ' '
	movwf seg2_1
	movlw '2'
	movwf seg2_2
	movlw '0'
	movwf seg2_3
	
	banksel YY
	swapf YY,0
	andlw 0x0F
	addlw 0x30
	banksel seg2_4
	movwf seg2_4

	banksel YY
	movf YY,0
	andlw 0x0F
	addlw 0x30	
	banksel seg2_5
	movwf seg2_5

	movlw seg2_1		
	lcall PrintSecondStr
	pagesel $
	ENDM
;------------------------------------------------------------------------
;макрос вывода в 1ю строку текущего дня недели (переменная WD)
;nnon tUE5 UUEd tH1r Fr1 5At 5Un
DW_to_1STR MACRO
	banksel WD
	movf WD,0
	xorlw .1
	btfsc STATUS,Z
	goto its_monday
	movf WD,0
	xorlw .2
	btfsc STATUS,Z
	goto its_tuesday
	movf WD,0
	xorlw .3
	btfsc STATUS,Z
	goto its_wednesday
	movf WD,0
	xorlw .4
	btfsc STATUS,Z
	goto its_thirsday
	movf WD,0
	xorlw .5
	btfsc STATUS,Z
	goto its_friday
	movf WD,0
	xorlw .6
	btfsc STATUS,Z
	goto its_saturday
its_sunday
	PRINT_STR_1 ' ','5','U','n',' '
	goto exit_dw_test  
its_monday
	PRINT_STR_1 ' ','n','n','0','n'
	goto exit_dw_test 
its_tuesday
	PRINT_STR_1 ' ','t','U','E','5' 
	goto exit_dw_test
its_wednesday
	PRINT_STR_1 ' ','U','U','E','d'
	goto exit_dw_test
its_thirsday
	PRINT_STR_1 ' ','t','H','1','r'
	goto exit_dw_test 
its_friday
	PRINT_STR_1 ' ','F','r','1',' ' 
	goto exit_dw_test
its_saturday
	PRINT_STR_1 ' ','5','A','t',' ' 	
exit_dw_test
	ENDM
;------------------------------------------------------------------------
;макрос записи показателей времени из ППЗУ начиная с адреса TIMEADDR - данные записанны в формате BCD
WRITE_RTC_EE MACRO TIMEADDR
	movlw TIMEADDR
	lcall ee_read
	pagesel $
	banksel HH
	movwf HH
	movlw TIMEADDR+.1
	lcall ee_read
	pagesel $
	banksel MM
	movwf MM
	movlw TIMEADDR+.2
	lcall ee_read
	pagesel $
	banksel SS
	movwf SS
	movlw TIMEADDR+.3
	lcall ee_read
	pagesel $
	banksel WD
	movwf WD
	movlw TIMEADDR+.4
	lcall ee_read
	pagesel $
	banksel DD
	movwf DD
	movlw TIMEADDR+.5
	lcall ee_read
	pagesel $
	banksel MO
	movwf MO
	movlw TIMEADDR+.6
	lcall ee_read
	pagesel $
	banksel YY
	movwf YY
	lcall WriteRTC
	pagesel $
	ENDM