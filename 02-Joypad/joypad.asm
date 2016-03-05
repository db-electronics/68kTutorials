; ************************************
; JOYPAD_READ1
;
; destroys:
;		A0, D5, D6
; returns:
;		D6 = SACBRLDU		
; ************************************
JOYPAD_READ1:
	move.l	#IO_DATA_1, A0			; load data_1 address
	move.b	(A0), D6				; read status j1 = 00CBRLDU
	move.b 	#0x00, (A0)				; set TH low
	nop								; wait to settle
	move.b  (A0), D5				; read status = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#0xC0, D5				; SA000000
	or.b	D5, D6					; D6 = SACBRLDU
	move.b	#0x40, (A0)				; set TH high for next pass
	rts
	
; ************************************
; JOYPAD_READ12
;
; destroys:
;		A0, D5, D6
; returns:
;						j2				j1
;		D6 = xxxxxxxx SACBRLDU xxxxxxxx	SACBRLDU
; ************************************
JOYPAD_READ12:
	move.l	#IO_DATA_2, A0			; load data_2 address
	move.b	(A0), D6				; read status j2 = 00CBRLDU
	move.b 	#0x00, (A0)				; set TH low
	nop								; wait to settle
	move.b  (A0), D5				; read status  = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#0xC0, D5				; SA000000
	or.b	D5, D6					; D6.b = SACBRLDU j2
	swap	D6						; move j2 to high word in D6
	move.b	#0x40, (A0)-			; set TH high for next pass
	move.b	-(A0), D6				; read status j1 = 00CBRLDU
	move.b 	#0x00, (A0)				; set TH low
	nop								; wait to settle
	move.b  (A0), D5				; read status  = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#0xC0, D5				; SA000000
	or.b	D5, D6					; D6.b = SACBRLDU j1
	move.b	#0x40, (A0)				; set TH high for next pass
	rts

WaitVBlankStart:
   move.w vdp_control, d0 ; Move VDP status word to d0
   andi.w #0x0008, d0     ; AND with bit 4 (vblank), result in status register
   bne.s    WaitVBlankStart ; Branch if not equal (to zero)
   rts
 
WaitVBlankEnd:
   move.w vdp_control, d0 ; Move VDP status word to d0
   andi.w #0x0008, d0     ; AND with bit 4 (vblank), result in status register
   beq.s    WaitVBlankEnd   ; Branch if equal (to zero)
   rts
