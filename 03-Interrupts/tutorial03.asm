; ************************************
; Title
; ************************************
;
;    Title:          tutorial03.asm
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
; Tutorial 03
; ************************************
Tutorial03Entry:
				
	move.w	#2, D2						; test context saving in Vint
	move.w	#3, D3
	move.w	#4, D4
	move.w	#5, D5
	move.w 	#6, D6
	movea.l	#$10, A0
	movea.l	#$11, A1
	movea.l	#$12, A2
	movea.l	#$13, A3
	movea.l	#$14, A4
	movea.l	#$15, A5
	movea.l	#$16, A6
	
	; TODO
	; only enable VDP interrupts here

.newFrame
	lea		intflags, A0				; A0 points to intflags
.syncVint	
	btst	#1, (A0)					; test if a Vertical Interrupt occured
	beq.s	.syncVint					; wait until vint occurs, bit0 set = vint has happened
	bclr	#1, (A0)					; clear the intflag	

	jsr		sysJoy_Read3Button			; read joypad1 state

	move.w	sysframecnt, D0				; load the sysframecnt into D0
	andi.w	#$0003, D0					; look at the lowest two bits of vintcounter
	bne.s	.newFrame					; if zero, load vintvector address, this should execute every 4 frames
	move.l	#VintRoutine, vintvector
	bra.s	.newFrame

VintRoutine:
	move.l	D0, vintvector				; clear the vintvector address
	addq.w	#1, _USERRAM				; increment a variable, should be 1/4 the frame rate
	rts									; return
