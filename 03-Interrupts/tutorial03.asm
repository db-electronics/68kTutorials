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
				
	move.l	#2, D2					; test context saving in Vint
	move.l	#3, D3
	move.l	#4, D4
	move.l	#5, D5
	move.l 	#6, D6
	move.l	#7, D7
	movea.l	#$10, A0
	movea.l	#$11, A1
	movea.l	#$12, A2
	movea.l	#$13, A3
	movea.l	#$14, A4
	movea.l	#$15, A5
	movea.l	#$16, A6
	

.loop	
	WaitVBlankStart_m				; synchronize
	WaitVBlankEnd_m

	addq.l	#1, D1
	move.l	vintcounter, D0			; load the vintcounter into D0
	andi.l	#$00000003, D0			; look at the lowest two bits of vintcounter
	bne.s	.loop					; if zero, load vintvector address, this should execute every 4 frames
	move.l	#VintRoutine, vintvector
	bra.s	.loop

VintRoutine:
	clr.l	D0						; Clear D0
	clr.l	D1						; clear D1
	move.l	D0, vintvector			; clear the vintvector address
	addq.l	#1, _USERRAM			; increment a variable, should be 1/4 the frame rate
	rts								; return
