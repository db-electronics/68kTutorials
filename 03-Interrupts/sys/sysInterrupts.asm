; ************************************
; Title
; ************************************
;
;    Title:          sysInterrupts.asm
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
; Horizontal Interrupts
; ************************************
HBlankInterrupt:
	rte

; ************************************
; Vertical Interrupts
; ************************************
VBlankInterrupt:
	addq.w	#1, vintcounter			; increment vint counter
	addq.w	#1, vintoccured			; increment vint occured
	tst.l	vintvector				; test vintvector
	beq.s	.noVector				; if vintvector = 0, get out of here!
.vectorValid
	movem.l D0-D7/A0-A6, -(SP)		; push context to stack
	movea.l	vintvector, A0			; put vintvector in A0
	jsr		(A0)					; jsr to vintvector	
	movem.l (SP)+, D0-D7/A0-A6		; pop context from stack
.noVector
   	rte								; return to main code

; ************************************
; Exception
; ************************************
Exception:
   	stop #$2700 					; Halt CPU

