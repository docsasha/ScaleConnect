;блок работы с модулем RTC AT24C32 - функции работы с памятью
	list p=16f887
	include <p16f887.inc>

	#define	SCL	PORTA,2		; SCL RTC
	#define	SDA	PORTA,3		; SDA RTC
	#define	TRIS_SCL	TRISA,2		; направление SCL RTC
	#define	TRIS_SDA	TRISA,3		; направление SDA RTC

	global MEM_ADDR_H, MEM_ADDR_L, MEM_LEN, R_BUFFER
	global WriteADDR, WriteBlock, ReadADDR, ReadBlock

	udata
MEM_ADDR_H	res .1 ;адрес куда писать (старший байт)
MEM_ADDR_L	res .1 ;адрес куда писать (младший байт)
MEM_LEN		res .1 ;количество данных для записи
R_BUFFER	res .1 ;переменная хранящая адрес буфера чтения или один считанный байт
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
;- Записать байт по указанному адресу
;WriteADDR(MEM_ADDR)
;адрес задается в переменных MEM_ADDR_H, MEM_ADDR_L
;значение которое надо писать помещается перед вызовом в аккумулятор
WriteADDR
	banksel R_BUFFER
	movwf R_BUFFER ;сохраняем значение для записи
	RTC_START
	movlw	b'10100000';0A0h			; slave address + write
	call	write_RTC
	movf	MEM_ADDR_H,0			; старший байт адреса
	call	write_RTC
	movf	MEM_ADDR_L,0			; младший байт адреса
	call	write_RTC
	banksel R_BUFFER
	movf	R_BUFFER,0 ;секунды
	call	write_RTC
	RTC_STOP
	return
;-----------------------------------------------------------------------
;- Записать последовательность байт (до 64) начиная с адреса
;WriteBlock(MEM_ADDR,MEM_LEN)
WriteBlock

	return
;-----------------------------------------------------------------------
;- Считать байт по указанному адресу в выводом его в аккумулятор
;MEM_ADDR_H, MEM_ADDR_L задается заранее
;ReadADDR(MEM_ADDR)
ReadADDR
	RTC_START
	movlw	b'10100000' ;0A0h адрес устройства и бит записи
	call	write_RTC
	banksel MEM_ADDR_H	; старший байт адреса
	movf MEM_ADDR_H, 0
	call	write_RTC
	banksel MEM_ADDR_L	; младший байт адреса
	movf MEM_ADDR_L, 0
	call	write_RTC
	RTC_START
	movlw	b'10100001';0A1h адрес устройства и бит записи
	call	write_RTC
	call	read_RTC		; read the seconds data
	banksel R_BUFFER
	movwf	R_BUFFER	; save it
	call	nack;
	RTC_STOP
	banksel R_BUFFER
	movf R_BUFFER,0
	return
;-----------------------------------------------------------------------
;- Считать последовательность байт (до 64) начиная с адреса
;в аккумуляторе адрес начала области куда считаны байты R_BUFFER
;ReadBlock(MEM_ADDR,MEM_LEN,R_BUFFER)
ReadBlock

	return
;-----------------------------------------------------------------------
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