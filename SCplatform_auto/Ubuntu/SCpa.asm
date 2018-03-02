;Select MC and configuration bits sets
	include <MCSetup.inc>
;pinouts setting - shows connecting LCD driver chip to MC I/O ports
	include <TM1621Setup.inc>
;codes of simbols for LCD driver TM1621
	include <TM1621.inc>
;global variables which uses after capture data from LCD to recognize data and others
	global LCD_bufer, bufer_count

	udata
;Variables for capture data from LCD driver TM1621
LCD_bufer 	res .18 ;buffer to save captured data
bufer_count	res .1 ;counter for loops in LCD capture procedure
bit_buffer	res .1 ;counter which shows with what number of captured bit we are working now
byte_buffer	res .1 ;counter which shows with what number of captured byte we are working now
;additional variables
loop_cnt	res .1 ;counter for different additional loops
;-----------------------------------------
;include external methods and variables
	;include methods for initialize and output data to LCD
	extern simb_pos, Display_Data, Data_to_LCD  ;<TM1621LCD.asm>
	extern init_LCD, LCD_Data_Duplicate, PrintSimb,PrintMsg  ;<TM1621LCD.asm>
	extern PrintFirstStr, PrintSecondStr, PrintThirdStr;<TM1621LCD.asm>
	extern SetKoma, ClrKoma, KomaPos, koma_set
	;include methods of pauses on 20MHz frequency oscilator
	extern pause_5s, pause_1s, pause_05s ;<pauses_20MHz.asm>
	;include methods for recognize simbols from LCD
	extern LCD_Data_Recognize ;<TM1621Recognize.asm>
	extern seg1_1,seg1_2,seg1_3,seg1_4,seg1_5;<TM1621Recognize.asm>
	extern seg2_1,seg2_2,seg2_3,seg2_4,seg2_5;<TM1621Recognize.asm>
	extern seg3_1,seg3_2,seg3_3,seg3_4,seg3_5,seg3_6;<TM1621Recognize.asm>
	extern koma;<TM1621Recognize.asm>
	;include methods for module Tiny RTC - working with timer chip DS1307
	extern HH,MM,SS,WD,DD,MO,YY ;<RTCTime.asm>
	extern ReadRTCData, ReadTime, ReadDate, ReadDayofWeek;<RTCTime.asm>
	extern WriteRTC, WriteTime, WriteDate, WriteDayofWeek;<RTCTime.asm>
	;include methods for read/write internal EEPROM
	extern ee_read, ee_write ;<EEPROM.asm>
	;include methods for working with internal UART module
	extern TX_LEN, UART_TX_ON, UART_TX_OFF;<UART.asm>
	extern UART_Setup, SendBytetoUART, SendPackettoUART, GetUARTByte;<UART.asm>
	extern UART_Buf ;<UART.asm>
	;include methods for module Tiny RTC - working with EEPROM chip 24C32N	
	extern MEM_ADDR_H, MEM_ADDR_L, MEM_LEN, R_BUFFER;<RTCEEPROM.asm>
	extern WriteADDR, WriteBlock, ReadADDR, ReadBlock	;<RTCEEPROM.asm>
;-----------------------------------------------------------------------
;macroses
	include <macroTM1621.inc>
;1)print constant string to LCD (16 simbols)
;PRINT_STR MACRO S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16 
;2)print constant string in 1st row (5 simbols)
;PRINT_STR_1 MACRO S1,S2,S3,S4,S5  
;3)print constant string in 2nd row (5 simbols)
;PRINT_STR_2 MACRO S1,S2,S3,S4,S5 
;4)print constant string in 3rd row (6 simbols)
;PRINT_STR_3 MACRO S1,S2,S3,S4,S5,S6 
;5)set comma in position with number POS  (1-16)
;SET_KOMA MACRO POS
;6)clear comma in position with number POS (1-16)
;CLR_KOMA MACRO POS  
;7)print simbol with ASCII code SIMB in position POS
;PRINT_SIMB MACRO SIMB, POS
;8)print value of variable with name VAL in position POS
;PRINT_VAL MACRO VAL, POS ;POS 1..16
	include <macroTinyRTC.inc>
;1)write to RTC all data from constants in BCD format
;WRITE_RTC MACRO HOURS, MINUTES, SECONDS, DAY_of_WEEK, DATE, MONTH, YEAR
;2)write only time to RTC from constants in BCD format
;WRITE_TIME MACRO HOURS, MINUTES, SECONDS
;3)write only date to RTC from constants in BCD format
;WRITE_DATE MACRO DATE, MONTH, YEAR
;4)write only day of week to RTC from constant BCD format (0x01-0x07)
;WRITE_DAY_of_WEEK MACRO DAY_of_WEEK
;5)print time in 3rd LCD string (from variables HH,MM,SS)
;TIME_to_3STR MACRO
;6)print date/month in 2nd LCD string (from variables DD,MO)
;DATE_to_2STR MACRO
;7)print year in 2nd LCD string in format 20XX (from variable YY)
;YEAR_to_2STR MACRO
;8)макрос вывода в 1ю строку текущего дня недели (переменная WD)
;DW_to_1STR MACRO
;9)макрос записи показателей времени из ППЗУ начиная с адреса TIMEADDR - данные записанны в формате BCD
;WRITE_RTC_EE MACRO TIMEADDR
;-----------------------------------------------------------------------

;EEPROM write block
	Org 0x2100;write to EEPROM before flashing MC from address 0x00
	DE 0x16 ;hours
	DE 0x45 ;minutes
	DE 0x00 ;seconds
	DE .3  ;day of week
	DE 0x21 ;date
	DE 0x02 ;month
	DE 0x18 ;year

;program code begining
	org 0x0000
	goto start
	org 0x0004 ;interrupt vector
;-----------------------------------------------------------------------
	bcf INTCON,7 ;disable interrupts
	;check the interrupt source
	;btfsc PIR1,0 ;(TMR1IF)
	;goto TMR1_int ;go to service TMR1 interrupt

;programs code for capture LCD data
	include <TM1621Capture.inc> ;capture LCD data code 
	include <TM1621ClrBuf.inc>  ;cleaning buffer code for capturing LCD data
;-----------------------------------------------------------------------	
start
	lcall initMC;<initMC.inc> initialisation of MCs peripherals
	lcall UART_Setup ;<UART.asm>
	lcall init_LCD;<TM1621LCD.asm> initialisation of LCD	
	lcall pause_05s ;<pauses_20MHz.asm> pause
	lcall clr_bufer ;<TM1621ClrBuf.inc> очистка указателей на буфер дисплея
	pagesel $
	;clear all commas
	banksel koma
	clrf koma
	clrf koma+.1

	;write time to RTC from EEPROM address
	WRITE_RTC_EE 0x00
	;WRITE_RTC 0x12, 0x10, 0x00,.3, 0x21, 0x02, 0x18
	
time_to_LCD
	;reading time to special variables
	lcall ReadTime
	pagesel $
	;day of week print in 1st LCD string
	DW_to_1STR 
	;date and month print in 2nd LCD string
	DATE_to_2STR
	;print time in 3rd LCD string
	TIME_to_3STR

	banksel SS
	movf SS,0
	lcall SendBytetoUART

;	banksel HH
;	movf HH,0
;	movwf UART_Buf
;	movf MM, 0
;	movwf UART_Buf+.1
;	movf SS,0
;	movwf UART_Buf+.2
;	movf WD,0
;	movwf UART_Buf+.3
;	movf DD,0
;	movwf UART_Buf+.4
;	movf MO,0
;	movwf UART_Buf+.5
;	movf YY,0
;	movwf UART_Buf+.6
;	banksel TX_LEN			
;	movlw .7
;	movwf TX_LEN
;	lcall SendPackettoUART

	lcall pause_1s
	pagesel $
;	bsf INTCON,7
	goto time_to_LCD


;microcontroller periphery initialisation
	include <InitMC.inc>
	goto $
	end