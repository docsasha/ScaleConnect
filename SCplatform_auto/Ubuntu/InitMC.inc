;������������� �� � ��������� �������, ���/���� ���������
initMC
	banksel ANSEL
	clrf ANSEL
	clrf ANSELH
	clrf WDTCON
	banksel CM1CON0
	clrf CM1CON0	;�������� �����������
	clrf CM2CON0
	banksel T1CON
	movlw b'00110001'
	movwf	T1CON ;��� TMR1 ���� 1:8 ���������� �������� ������
	banksel VRCON
	bcf	VRCON, VREN	 ;�������� ������� ������ �������
	bcf	VRCON, VROE ;������� ��� �������� �� RA2
	movlw b'10101000'
	movwf OPTION_REG 
	;��� 7 RBPU=1 - ������������� ��������� ���������
	;��� 6 INTEDG=0 - ������� ���������� �� ������� ������
	;��� 5 T0CS=1 - ���������� �������� ���������� ������� 0 
	;��� 4 T0SE=0 - ���������� ������� �� ��������� ������
	;��� 3 PSA=1 - ������������ ����� WDT 
	;���� 2-0 RS2-RS0=000 - ����������� ������������ 1:1
	movlw b'01010000';���������� ���������� - �������� ���������� (���� ���������)
	movwf INTCON ;(����� ������ ������� �� ������ ����������)
;	bsf PIE1,0 ;(TMR1IE) ���������� ���������� �� ������� 1 
	banksel TRISA
	;���������� ��� ������ ��������� �� �����
	clrw
	movwf TRISA
	movwf TRISC
	movwf TRISD
	movwf TRISE
	movwf TRISB
	;�������� ������������ ��� ������������� ����������������� PORTB<2:1>=1
	;������ ������������� ����������� ������� � ����������� �� ��������
	;��������� �������� TRISx � PORTx �� ��� �� ������� �� � ������ ������
	;����� ����������� ������ � ������ define
	bsf CS_IN ;������������� ����� �������� �������� �������
	bsf WR_IN
	bsf DATA_IN
	banksel PORTA
	clrf PORTA
	clrf PORTB ;������������� ������� ������
	clrf PORTC 
	clrf PORTD
	clrf PORTE
	bcf STATUS,RP0 ;��������� � ������� ����
	bcf PIR1, 0
	return
