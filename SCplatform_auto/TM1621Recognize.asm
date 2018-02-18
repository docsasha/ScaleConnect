	list p=16f887
	include <p16f887.inc>

	extern LCD_bufer, bufer_count
	global LCD_Data_Recognize
	global seg1_1,seg1_2,seg1_3,seg1_4,seg1_5
	global seg2_1,seg2_2,seg2_3,seg2_4,seg2_5
	global seg3_1,seg3_2,seg3_3,seg3_4,seg3_5,seg3_6
	global koma

	udata
;ASCII_data res .16 ;������������ ������ � ���� ASCII ���� (���������� � 
;������� 1� ������ 5 ��������, ����� 2� ������ 5 ��������, ����� 3� ������ 6 ��������
;��� �������� ������� �� �������� (������� �������)
seg1_1		res .1 ;1� ������
seg1_2		res .1
seg1_3		res .1
seg1_4		res .1
seg1_5 		res .1 
seg2_1 		res .1 ;2� ������
seg2_2 		res .1
seg2_3 		res .1
seg2_4 		res .1
seg2_5 		res .1 
seg3_1 		res .1 ;3� ������
seg3_2 		res .1
seg3_3 		res .1
seg3_4 		res .1
seg3_5 		res .1
seg3_6 		res .1 
koma 		res .2 ;2 ����� � ��������� �������
;- ���������� � ������������� � ASCII ��� ��������� ������
;LCD_Data_Recognize(LCD_bufer, ASCII_data)
;LCD_bufer - ����� ������ ������� � ������� ������������� ����� ��������� � ����� ������ 
;ASCII_data � ������������ ������ � ���� ASCII ���� (���������� � ������� 1� ������ 5 ��������, ����� 2� ������ 5 ��������, ����� 3� ������ 6 ��������, 2 ����� � ��������� �������)
	code
LCD_Data_Recognize
;��������� ������������� ��������
	;���� ������ ����� ���� 137 ��� - ����� ����� ��� ������
	;��� �� 3+6+4*n (n=1..32) �� ������ ����� 3+6+8*n (n=1..16)
	;�� ���� ��� ���� 17,25,33,41,49,57,65,73,81,89,97,105,113,121,129,137
	;��������� ����� ������� ������� ������������� ��� ���������
	;3 ���� ��� 101, 6 ��� ������, ��������� ���� �������� �� 8 ���	
	banksel bufer_count
	movlw .137
	xorwf bufer_count,0
	btfss STATUS, Z
	goto not_137
	;���� ��� ������ 137 ���, �� ��� ����������� ���� ��� ����������
	;���� � 98 �� 137 �.�. ��� ����� ���������� � ������� ���� ��������
	;1� ������ (�����) ��������� � ����� � 130 �� 137
	;2� ������ (�����) ��������� � ����� � 122 �� 129
	;3� ������ (�����) ��������� � ����� � 114 �� 121
	;4� ������ (�����) ��������� � ����� � 106 �� 113
	;5� ������ (�����) ��������� � ����� � 98 �� 105
	;�.�. ��� ���� �������� �� 1 ��� ����� ���� � ���������� LCD_bufer12-LCD_bufer16
	banksel LCD_bufer
	;���������� ��� ��� �� ����� � ��������� � ASCII ���� ���� ��� ����������� ��������	
	clrf koma
;	clrf koma+1
;	call recog_seg1_1 ;������������� ������ ��� 1�� ������� 1�� ����
;	call recog_seg1_2 ;������������� ������ ��� 2�� ������� 1�� ����
;	call recog_seg1_3 ;������������� ������ ��� 3�� ������� 1�� ����
;	call recog_seg1_4 ;������������� ������ ��� 4�� ������� 1�� ����
;	call recog_seg1_5 ;������������� ������ ��� 5�� ������� 1�� ����
;	call recog_seg2_1 ;������������� ������ ��� 1�� ������� 2�� ����
;	call recog_seg2_2 ;������������� ������ ��� 2�� ������� 2�� ����
;	call recog_seg2_3 ;������������� ������ ��� 3�� ������� 2�� ����
;	call recog_seg2_4 ;������������� ������ ��� 4�� ������� 2�� ����
;	call recog_seg2_5 ;������������� ������ ��� 5�� ������� 2�� ����
;	call recog_seg3_1 ;������������� ������ ��� 1�� ������� 3�� ����
;	call recog_seg3_2 ;������������� ������ ��� 2�� ������� 3�� ����
;	call recog_seg3_3 ;������������� ������ ��� 3�� ������� 3�� ����
;	call recog_seg3_4 ;������������� ������ ��� 4�� ������� 3�� ����
;	call recog_seg3_5 ;������������� ������ ��� 5�� ������� 3�� ����
;	call recog_seg3_6 ;������������� ������ ��� 6�� ������� 3�� ����
;	call recog_bat;���������� ����� ������������
	return
not_137
	;���� ��� ������� ����� ��� ���������� ������� ����������� 
	;� ������ � 22 �� 30 � ����� 2
	;���� ����� ������ � ��� ����� �� ������������� ������� 
	;����� ��������� ���� ����� ��� �� ��������� (��������� � ��� �� �� ������)
	;bufer_count

	return


	end
