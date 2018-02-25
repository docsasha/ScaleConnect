;Инициализация МК с указанием выводов, вкл/выкл переферии
initMC
	banksel ANSEL
	clrf ANSEL
	clrf ANSELH
	clrf WDTCON
	banksel CM1CON0
	clrf CM1CON0	;Вимкнути компаратори
	clrf CM2CON0
	banksel T1CON
	movlw b'00110001'
	movwf	T1CON ;вкл TMR1 коэф 1:8 внутренний тактовый сигнал
	banksel VRCON
	bcf	VRCON, VREN	 ;Вимкнути джерело опорної напруги
	bcf	VRCON, VROE ;вольтаж ИОН отключен от RA2
	movlw b'10101000'
	movwf OPTION_REG 
	;бит 7 RBPU=1 - подтягивающие резисторы отключены
	;бит 6 INTEDG=0 - внешнее прерывание по заднему фронту
	;бит 5 T0CS=1 - внутренний источник приращения таймера 0 
	;бит 4 T0SE=0 - приращение таймера по переднему фронту
	;бит 3 PSA=1 - предделитель перед WDT 
	;биты 2-0 RS2-RS0=000 - коэффициент предделителя 1:1
	movlw b'01010000';разрешение прерываний - внешнего прерывания (пока отключены)
	movwf INTCON ;(чтобы раньше времени не пришло прерывание)
;	bsf PIE1,0 ;(TMR1IE) разрешение прерывания от таймера 1 
	banksel TRISA
	;изначально все выводы настроены на выход
	clrw
	movwf TRISA
	movwf TRISC
	movwf TRISD
	movwf TRISE
	movwf TRISB
	;согласно документации при использовании приемопередатчика PORTB<2:1>=1
	;теперь настраивается направление выводов в зависимости от настроек
	;поскольку регистры TRISx и PORTx по тем же адресам но в разных банках
	;можно направления менять с учетом define
	bsf CS_IN ;устанавливаем входы согласно настроек дисплея
	bsf WR_IN
	bsf DATA_IN
	banksel PORTA
	clrf PORTA
	clrf PORTB ;инициализация защелок портов
	clrf PORTC 
	clrf PORTD
	clrf PORTE
	bcf STATUS,RP0 ;переходим в нулевой банк
	bcf PIR1, 0
	return
