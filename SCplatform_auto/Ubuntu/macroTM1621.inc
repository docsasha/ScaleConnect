;-----------------------------------------------------------------------
;������ ���� �������� ������� � ���������� ��� ������� (16 ��������)
;������� �������� ��������
PRINT_STR MACRO S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16  
	banksel seg1_1
	movlw S1
	movwf seg1_1
	movlw S2
	movwf seg1_2
	movlw S3
	movwf seg1_3
	movlw S4
	movwf seg1_4
	movlw S5
	movwf seg1_5	
	movlw S6
	movwf seg2_1
	movlw S7
	movwf seg2_2
	movlw S8
	movwf seg2_3
	movlw S9
	movwf seg2_4
	movlw S10
	movwf seg2_5
	movlw S11
	movwf seg3_1
	movlw S12
	movwf seg3_2
	movlw S13
	movwf seg3_3
	movlw S14
	movwf seg3_4
	movlw S15
	movwf seg3_5
	movlw S16
	movwf seg3_6
	movlw seg1_1		
	lcall PrintMsg
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;������ ������ ������ ��� ������� (5 ��������)
PRINT_STR_1 MACRO S1,S2,S3,S4,S5  
	banksel seg1_1
	movlw S1
	movwf seg1_1
	movlw S2
	movwf seg1_2
	movlw S3
	movwf seg1_3
	movlw S4
	movwf seg1_4
	movlw S5
	movwf seg1_5	
	movlw seg1_1		
	lcall PrintFirstStr
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;������ 2�� ������ ��� ������� (5 ��������)
PRINT_STR_2 MACRO S1,S2,S3,S4,S5  
	banksel seg2_1
	movlw S1
	movwf seg2_1
	movlw S2
	movwf seg2_2
	movlw S3
	movwf seg2_3
	movlw S4
	movwf seg2_4
	movlw S5
	movwf seg2_5	
	movlw seg2_1		
	lcall PrintSecondStr
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;������ 3� ������ !��� ������� (6 ��������)
PRINT_STR_3 MACRO S1,S2,S3,S4,S5,S6  
	banksel seg3_1
	movlw S1
	movwf seg3_1
	movlw S2
	movwf seg3_2
	movlw S3
	movwf seg3_3
	movlw S4
	movwf seg3_4
	movlw S5
	movwf seg3_5	
	movlw S6
	movwf seg3_6
	movlw seg3_1		
	lcall PrintThirdStr
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;���������� ������� � ������� POS
SET_KOMA MACRO POS
	banksel KomaPos
	movlw POS
	movwf KomaPos
	movlw koma
	lcall SetKoma
	movlw koma	
	lcall koma_set
	movlw Display_Data
	lcall Data_to_LCD
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;������� ������� � ������� POS
CLR_KOMA MACRO POS
	banksel KomaPos
	movlw POS
	movwf KomaPos
	movlw koma
	lcall ClrKoma
	movlw koma
	lcall koma_set
	movlw Display_Data
	lcall Data_to_LCD
	pagesel $
	ENDM
;-----------------------------------------------------------------------
;���������� ������ SIMB � ������� POS
PRINT_SIMB MACRO SIMB, POS ;POS 1..16
	banksel simb_pos
	movlw POS
	movwf simb_pos
	movlw SIMB	
	lcall PrintSimb
	pagesel $
	ENDM
;----------------------------------------------------------------------
;���������� �������� ���������� VAL � ������� POS
PRINT_VAL MACRO VAL, POS ;POS 1..16
	banksel simb_pos
	movlw POS
	movwf simb_pos
	banksel VAL
	movf VAL,0	
	lcall PrintSimb
	pagesel $
	ENDM