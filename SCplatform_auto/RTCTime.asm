;блок работы с модулем RTC DS1307 - функции часов
	list p=16f887
	include <p16f887.inc>

	#define	SCL	PORTA,2		; SCL RTC
	#define	SDA	PORTA,3		; SDA RTC
	#define	TRIS_SCL	TRISA,2		; направление SCL RTC
	#define	TRIS_SDA	TRISA,3		; направление SDA RTC

	global HH,MM,SS,WD,DD,MO,YY
	global ReadRTCData, ReadTime, ReadDate, ReadDayofWeek
	global WriteRTC, WriteTime, WriteDate, WriteDayofWeek

	udata
HH	res .1 ;часы
MM	res .1 ;минуты
SS	res .1 ;секунды
WD	res .1 ;день недели
DD	res .1 ;число
MO	res .1 ;месяц
YY	res .1 ;год
	udata_ovr
TMP res .1
COUNT res .1

;макросы
;-----------------------------------------------------------------
;установка банка 0
SET_BANK0 MACRO 
	bcf STATUS, RP0
	bcf STATUS, RP1	
	ENDM
;-----------------------------------------------------------------
;установка банка 1
SET_BANK1 MACRO 
	bsf STATUS, RP0
	bcf STATUS, RP1	
	ENDM
;------------------------------------------------------------------
RTC_START MACRO ;!!!!!команда старт для часов реального времени
	SET_BANK0
	bsf	SDA			; SDA high
	nop
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	bcf	SDA			; SDA low (start)
	ENDM
	;-------------------
RTC_STOP MACRO			;!!!!команда стоп для часов реального времени
	SET_BANK0
	bcf	SDA			; SDA low
	nop
	nop
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	bsf	SDA			; SDA high
	ENDM
;------------------------------------------------------------------

	code
;-----------------------------------------------------------------------
;- Считать текущее состояние времени/даты/для недели и т.д.
;ReadRTCData(HH,MM,SS,WD,DD,MO,YY)
ReadRTCData
	RTC_START
	banksel SS
	movlw	b'11010000' ;0D0h			; slave address + write
	call	write_RTC
	movlw	0x00			; set word address to seconds register
	call	write_RTC
	RTC_START
	movlw	b'11010001';0D1h			; slave address + read
	call	write_RTC
	call	read_RTC		; read the seconds data
	movwf	SS			; save it
	call	ack;
	call	read_RTC		; and so on
	movwf	MM
	call	ack;
	call	read_RTC
	movwf	HH
	call	ack;
	call	read_RTC
	movwf	WD
	call	ack;
	call	read_RTC
	movwf	DD
	call	ack;
	call	read_RTC
	movwf	MO
	call	ack;
	call	read_RTC
	movwf	YY
	call	nack;
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Считать отдельно значение времени
;ReadTime(HH,MM,SS)
ReadTime
	RTC_START
	banksel SS
	movlw	b'11010000' ;0D0h			; slave address + write
	call	write_RTC
	movlw	0x00			; set word address to seconds register
	call	write_RTC
	RTC_START
	movlw	b'11010001';0D1h			; slave address + read
	call	write_RTC
	call	read_RTC		; read the seconds data
	movwf	SS			; save it
	call	ack;
	call	read_RTC		; and so on
	movwf	MM
	call	ack;
	call	read_RTC
	movwf	HH
	call	nack;
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Считать отдельно дату
;ReadDate(DD,MO,YY)
ReadDate
	RTC_START
	banksel SS
	movlw	b'11010000' ;0D0h			; slave address + write
	call	write_RTC
	movlw	0x04			; адрес регистра с датой
	call	write_RTC
	RTC_START
	banksel DD
	movlw	b'11010001';0D1h			; slave address + read
	call	write_RTC
	call	read_RTC		; read the seconds data
	movwf	DD
	call	ack;
	call	read_RTC
	movwf	MO
	call	ack;
	call	read_RTC
	movwf	YY
	call	nack;
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Считать отдельно день недели
;ReadDayofWeek(DW)
ReadDayofWeek
	RTC_START
	banksel SS
	movlw	b'11010000' ;0D0h			; slave address + write
	call	write_RTC
	movlw	0x03			; адрес регистра с днем недели
	call	write_RTC
	RTC_START
	banksel SS
	movlw	b'11010001';0D1h			; slave address + read
	call	write_RTC
	call	read_RTC		; read the seconds data
	movwf	WD
	call	nack;
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Установить все временные параметры
;WriteRTC(HH,MM,SS,DW,DD,MO,YY)
WriteRTC
	RTC_START
	movlw	b'11010000';0D0h			; slave address + write
	call	write_RTC
	movlw	0x00			; set word address to seconds register
	call	write_RTC
	banksel SS
	movf	SS,0 ;секунды
	call	write_RTC
	banksel MM
	movf 	MM,0 ;минуты
	call	write_RTC
	banksel HH
	movf	HH,0 ;часы
	call	write_RTC
	banksel WD
	movf	WD,0 ;день недели
	call	write_RTC
	banksel DD
	movf	DD,0 ;число
	call	write_RTC
	banksel MO
	movf	MO,0 ;месяц
	call	write_RTC
	banksel YY
	movf	YY,0 ;год
	call	write_RTC
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Установить время (не меняя при этом все остальное)
;WriteTime(HH,MM,SS)
WriteTime
	RTC_START
	banksel SS
	movlw	b'11010000';0D0h			; slave address + write
	call	write_RTC
	movlw	0x00			; set word address to seconds register
	call	write_RTC
	banksel SS
	movf	SS,0 ;секунды
	call	write_RTC
	banksel MM
	movf 	MM,0 ;минуты
	call	write_RTC
	banksel HH
	movf	HH,0 ;часы
	call	write_RTC
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Установить дату (не меняя при этом все остальное)
;WriteDate(DD,MO,YY)
WriteDate
	RTC_START
	banksel SS
	movlw	b'11010000';0D0h			; slave address + write
	call	write_RTC
	movlw	0x04			; адрес регистра с датой
	call	write_RTC
	banksel DD
	movf	DD,0 ;число
	call	write_RTC
	banksel MO
	movf	MO,0 ;месяц
	call	write_RTC
	banksel YY
	movf	YY,0 ;год
	call	write_RTC
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Установить день недели (не меняя при этом все остальное)
;WriteDayofWeek(DW)
WriteDayofWeek
	RTC_START
	banksel WD
	movlw	b'11010000';0D0h			; slave address + write
	call	write_RTC
	movlw	0x03			; адрес регистра с днем недели
	call	write_RTC
	banksel WD
	movf	WD,0 ;день недели
	call	write_RTC
	RTC_STOP
	return
;---- Read RTC into W  ----
read_RTC:
	SET_BANK1
	bsf	TRIS_SDA		; set SDA for input
	banksel COUNT
	movlw	.8		; send 8 bits
	movwf	COUNT
	SET_BANK0
	bcf	SCL			; clock data out
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	banksel TMP
	clrf	TMP			; clear var
	rlf	TMP, 1			; rotate carry in
	clrf	TMP			; clear var again
I2C_read_loop:
	rlf	TMP, 1
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	btfsc	SDA
	goto set_TMP			; if data out = 1, set bit
cont_I2C_r
	SET_BANK0
	bcf	SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	banksel COUNT
	decfsz	COUNT, 1
	goto	I2C_read_loop
	banksel TMP
	movf	TMP, W
	return
set_TMP
	banksel TMP
	bsf TMP,0
	goto cont_I2C_r
;---- ACK read (assumes SCL=0 on entry) ----
ack:
	SET_BANK0
	bcf		SDA
	SET_BANK1
	bcf	TRIS_SDA		; set SDA for output
	SET_BANK0
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	nop
	bcf	SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	banksel SS
	return
;---- NACK read (assumes SCL = 0 on entry) ----
nack:
	SET_BANK0
	bsf	SDA
	SET_BANK1
	bcf	TRIS_SDA		; set SDA for output
	SET_BANK0
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	bcf	SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	banksel SS
	return
;--- Write the byte in W to RTC ---
write_RTC:
	banksel TMP
	movwf	TMP			;Save the data
;--- Do a I2C bus write of byte in 'TMP' ---
I2C_write:
	SET_BANK1
	bcf	TRIS_SDA		; set SDA for output
	banksel COUNT
	movlw	.8			; send 8 bits
	movwf	COUNT
	SET_BANK0
	bcf	SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
I2C_w_loop:
	SET_BANK0
	bcf	SDA			; assume data out is low
	banksel TMP
	btfsc	TMP, 7
	call set_SDA	
	; nop
	SET_BANK1
	bsf	TRIS_SCL		; SCL high (input)
	banksel TMP
	rlf	TMP, 1
	SET_BANK0
	bcf	SCL			; clock it in
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	banksel COUNT
	decfsz	COUNT, 1
	goto	I2C_w_loop
	SET_BANK1
	bsf	TRIS_SDA		; set SDA for input
	SET_BANK0
	bcf	SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	nop
	nop
	nop
	nop
	bsf	TRIS_SCL		; SCL high (input)
	SET_BANK0
	bcf		SCL
	SET_BANK1
	bcf	TRIS_SCL		; SCL low (output)
	SET_BANK0
	return
set_SDA
	SET_BANK0
	bsf	SDA			; if data out = 1, set bit
	return
;----------------------------------------------------------------------
	end