; ************************************
; Title
; ************************************
;
;    Title:          sysInit.asm
;    Author:         René Richard
;    Description:
;        
;    Target Hardware:
;        Sega Genesis / Megadrive
;    Assembler:
;        ASMX
;
; LICENSE
; 
;    This file is part of 68kTutorials.
;    68kTutorials is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;    68kTutorials is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;    You should have received a copy of the GNU General Public License
;    along with 68kTutorials.  If not, see <http://www.gnu.org/licenses/>.
;
; ************************************
; Start of System Initialization
; ************************************

	ORG		$00000200				; header section should get us to $200
									; but ORG in case we made a mistake (ASMX will complain)
EntryPoint:           				; Entry point address set in ROM header

; ************************************
; Test reset button
; ************************************
	tst.w 	$00A10008  				; Test mystery reset (expansion port reset?)
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main
	tst.w 	$00A1000C	  			; Test reset button
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main

; ************************************
; Clear RAM
; ************************************
	clr.l	D0						; Place a 0 into d0, ready to copy to each longword of RAM
	move.l	M68K_RAM, A0			; A0 points to beginning of RAM
	move.l 	#$00004000, D1     		; Clearing 64k's worth of longwords
.Clear:
	move.l 	D0, (A0)+           	; Post-inc faster than Pre-dec (as last tutorial)
	dbra 	D1, .Clear          	; Decrement d0, repeat until depleted
	
; ************************************
; Write TMSS, get System Region
; ************************************
	move.w	#20, D1					; millis timer init (20ms for PAL)
	move.b 	IO_VERSIONNO, D0      	; Move Megadrive hardware version to d0
	btst	#6, D0					; Test VMOD bit for region (PAL = 1, NTSC = 0)
	bne.s	.skipForPal
	subi.w	#3, D1					; change millis timer to 17 for NTSC
.skipForPal
	move.w	D1, sysmillisinc		; store value to sysregion
	andi.b 	#$0F, D0           		; The version is stored in last four bits, so mask it with 0F
	beq.s 	.SkipTMSS              	; If version is equal to 0, skip TMSS signature
	move.l 	#'SEGA', CTRL_TMSS 		; Move the string "SEGA" to $A14000
.SkipTMSS:

; ************************************
; Init Z80
; ************************************
	Z80Reset_m
	Z80Request_m

	; clear the Z80's 8KB of RAM
	move.w	#$2000, D0				; 8KB of Z80 RAM to clear
	move.l	#Z80_RAM, A1			; A1 points to Z80 RAM
.ClearZ80
	clr.b	(A1)+					; clear bytes, $00 is Z80 nop
	dbra	D0, .ClearZ80				

	; load simple program to Z80
	move.l 	#Z80Data, A0        	; Load address of data into a0
	move.l 	#Z80_RAM, A1     		; Copy Z80 RAM address to a1
	move.l 	#Z80DataEnd-Z80Data, D0 ; Auto-calculate size of transfer using labels
.CopyZ80:
	move.b 	(A0)+, (A1)+        	; Copy data, and increment the source/dest addresses
	dbra 	D0, .CopyZ80

	Z80Reset_m
	Z80Release_m

; ************************************
; Init PSG
; ************************************
	move.b	$9F, VDP_PSG			; mutes all PSG channels
	move.b	$BF, VDP_PSG
	move.b	$DF, VDP_PSG
	move.b	$FF, VDP_PSG

; ************************************
; Init VDP
;	DO 		- iterations
;	D1.uw 	- register number in VDP
;	D1.lw 	- register value
;	A0 		- pointer to VDP register value array 
; ************************************
	move.l 	#VDPRegisters, A0   	; Load address of register table into a0
	move.l 	#24, D0           		; 24 registers to write
	move.l 	#$00008000, d1     		; 'Set register 0' command (and clear the rest of d1 ready)

.CopyVDP:
	move.b 	(A0)+, D1           	; Move register value to lower byte of d1
	move.w 	D1, VDP_CTRL     		; Write command and value to VDP control port
	add.w 	#$0100, D1          	; Increment register #
	dbra 	D0, .CopyVDP

; ************************************
; Init IO Ports
; ************************************
	move.b 	#$40, IO_CTRL_1	  		; Controller port 1 CTRL, TH = output
	move.b 	#$40, IO_CTRL_2	 		; Controller port 2 CTRL, TH = output
	move.b 	#$00, IO_CTRL_EXP 		; EXP port CTRL
	move.b	#$40, IO_DATA_1			; Idle with TH = '1'
	move.b	#$40, IO_DATA_2			; Idle with TH = '1'	

; ************************************
; Cleanup
; ************************************
	move.l 	#M68K_RAM, A0     		; A0 points to $00 value in RAM (has been cleared)
	movem.l (A0), D0-D7/A1-A6  		; Multiple move zero to all registers
	suba.l	A0, A0					; Clear A0

	; Init status register (no trace, supervisor mode, all interrupt levels enabled, clear condition code bits)
	move 	#$2000, SR

; ************************************
; Main
; ************************************
Main:
	jmp __main 						; Begin external main

; ************************************
; Data
; ************************************

Z80Data:
   	dc.w $af01, $d91f
   	dc.w $1127, $0021
   	dc.w $2600, $f977
   	dc.w $edb0, $dde1
   	dc.w $fde1, $ed47
   	dc.w $ed4f, $d1e1
   	dc.w $f108, $d9c1
   	dc.w $d1e1, $f1f9
   	dc.w $f3ed, $5636
   	dc.w $e9e9, $8104
   	dc.w $8f01
Z80DataEnd:
   
VDPRegisters:
	dc.b $04 ; 0: Horiz. interrupt off
	dc.b $74 ; 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
   	dc.b $30 ; 2: Pattern table for Scroll Plane A at $C000 (bits 3-5)
   	dc.b $40 ; 3: Pattern table for Window Plane at $10000 (bits 1-5)
   	dc.b $05 ; 4: Pattern table for Scroll Plane B at $A000 (bits 0-2)
   	dc.b $70 ; 5: Sprite table at $E000 (bits 0-6)
   	dc.b $00 ; 6: Unused
   	dc.b $00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   	dc.b $00 ; 8: Unused
   	dc.b $00 ; 9: Unused
   	dc.b $00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   	dc.b $00 ; 11: External interrupts off, V/H scrolling on
   	dc.b $81 ; 12: Shadows and highlights off, interlace off, H40 mode (64 cells horizontally)
   	dc.b $34 ; 13: Horiz. scroll table at $D000 (bits 0-5)
   	dc.b $00 ; 14: Unused
   	dc.b $00 ; 15: Autoincrement off
   	dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
   	dc.b $00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   	dc.b $00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   	dc.b $00 ; 19: DMA length lo byte
   	dc.b $00 ; 20: DMA length hi byte
   	dc.b $00 ; 21: DMA source address lo byte
   	dc.b $00 ; 22: DMA source address mid byte
   	dc.b $00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
VDPRegistersEnd:
