; ************************************
; ReadJoypad1
; ************************************
ReadJoypad1:
	move.l	#IO_CTRL1DATA, A0		; load ctrl1 address
	move.b	#0x40, (A0)				; set TH high
	nop
	move.b	(A0), D6				; read status
	andi.b	#0x3F, D6				; 00CBRLDU
	move.b 	#0x00, (A0)				; set TH low
	nop
	move.b  (A0), D5				; read status
	rol.b	#2, D5					; SA00DU??
	andi.b	#0xC0, D5				; SA000000
	or.b	D5, D6					; D6 = SACBRLDU
	rts
	
