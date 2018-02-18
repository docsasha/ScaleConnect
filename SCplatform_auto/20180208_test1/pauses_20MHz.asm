	title "Ѕлок пауз дл€ 20ћ√ц"
	list p=16f887
	include <p16f887.inc>

	;функции и переменные доступные извне
	global pause_5s, pause_1s, pause_05s, pause_5us, pause_3us

	udata_ovr ;секци€ переменных
counta 	res 1  
countb 	res 1 
countc 	res 1 
m5 	 	res 1
	code
;-----------------------------------------------------------------------
;пауза примерно 5с 
pause_5s
	banksel counta
	movlw .130
	movwf counta
cicle72
	movlw .255
	movwf countb
cicle71	
	movlw .255
	movwf countc
cicle70
	decfsz countc,1
	goto cicle70
	decfsz countb,1
	goto cicle71
	decfsz counta,1
	goto cicle72
	return
;-----------------------------------------------------------------------
;пауза примерно 1с 
pause_1s
	banksel counta
	movlw .26
	movwf counta
cicle82
	movlw .255
	movwf countb
cicle81	
	movlw .255
	movwf countc
cicle80
	decfsz countc,1
	goto cicle80
	decfsz countb,1
	goto cicle81
	decfsz counta,1
	goto cicle82
	return
;-----------------------------------------------------------------------
;пауза примерно 0,5с 
pause_05s
	banksel counta
	movlw .13
	movwf counta
cicle92
	movlw .255
	movwf countb
cicle91	
	movlw .255
	movwf countc
cicle90
	decfsz countc,1
	goto cicle90
	decfsz countb,1
	goto cicle91
	decfsz counta,1
	goto cicle92
	return
;---------------------------------------------------------------------
pause_5us ;5us
	movlw .6
	movwf m5
pause_cicle5
	decfsz	m5,1
	goto pause_cicle5
	return
;------------------------------ѕауза 3 мкс 
pause_3us ;3us
	movlw .3
	movwf m5
pause_cicle3
	decfsz	m5,1
	goto pause_cicle3
	return
;---------------------------------------------------------------------
	end