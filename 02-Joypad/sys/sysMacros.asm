; ************************************
; MACROS
; ************************************
Z80Reset_m		MACRO
	move.w	#$0000, CTRL_Z80RESET
	exg.l	A0,A1					; waste some time
	exg.l	A1,A0
	move.w	#$0100, CTRL_Z80RESET	
	ENDM

Z80Request_m	MACRO
	move.w	#$0100, CTRL_Z80BUSREQ
.\?Wait
	btst.b	#0, CTRL_Z80BUSREQ
	bne.s	.\?Wait
	ENDM

Z80Release_m	MACRO
	move.w	#$0000, CTRL_Z80BUSREQ
	ENDM

WaitVBlankStart_m	MACRO
.\?Wait
   	move.w 	VDP_CTRL, D0 			; Move VDP status word to d0
   	andi.w 	#$0008, D0    			; AND with bit 4 (vblank), result in status register
	bne.s	.\?Wait			 		; Branch if not equal (to zero)
	ENDM
 
WaitVBlankEnd_m		MACRO
.\?Wait
   	move.w 	VDP_CTRL, D0 			; Move VDP status word to d0
   	andi.w 	#$0008, D0     			; AND with bit 4 (vblank), result in status register
   	beq.s	.\?Wait  				; Branch if equal (to zero)
	ENDM
