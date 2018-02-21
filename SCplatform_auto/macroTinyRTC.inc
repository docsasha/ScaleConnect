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
