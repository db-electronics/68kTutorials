; ************************************
; Title
; ************************************
;
;    Title:          sysRAM.asm
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
;    Foobar is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;    You should have received a copy of the GNU General Public License
;    along with 68kTutorials.  If not, see <http://www.gnu.org/licenses/>.
;
; ************************************
; Soft Interrupt Vectors
; ************************************
_RAMVECTORSBASE			EQU		M68K_RAM
vintvector				EQU		_RAMVECTORSBASE+0
hintvector				EQU		_RAMVECTORSBASE+4
xintvector				EQU		_RAMVECTORSBASE+8
vintcounter				EQU		_RAMVECTORSBASE+12
intflags				EQU		_RAMVECTORSBASE+14

; ************************************
; Joypads
; ************************************
_RAMJOYSTATEBASE		EQU		$00FF0010
joy1state				EQU		_RAMJOYSTATEBASE+0
joy2state				EQU		_RAMJOYSTATEBASE+2

; ************************************
; UserRAM
; ************************************
_USERRAM				EQU		$00FF0020
