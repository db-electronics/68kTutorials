; ************************************
; Title
; ************************************
;
;    Title:          sysJoypad.asm
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
; JOYPAD_ReadPad01:
;
; destroys:
;		A0, A1, D5, D6
; returns:
;		D6 = SACBRLDU
;		joy1State (RAM) = D6		
; ************************************
JOYPAD_ReadPad01:
	move.l	#IO_DATA_1, A0			; load data_1 address
	move.l	#joy1State, A1			; point to RAM placeholder for joystate
	move.b	(A0), D6				; read status j1 = 00CBRLDU
	move.b 	#$00, (A0)				; set TH low
	nop								; wait to settle
	nop								;
	move.b  (A0), D5				; read status = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#$C0, D5				; SA000000
	or.b	D5, D6					; D6 = SACBRLDU
	not.b	D6						; invert, 1 = pressed
	move.b	#$40, (A0)				; set TH high for next pass
	move.w	D6, (A1)				; store to RAM
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
	move.l	#joy1State, A1			; point to RAM placeholder for joystate
	move.b	(A0), D6				; read status j2 = 00CBRLDU
	move.b 	#$00, (A0)				; set TH low
	nop								; wait to settle
	nop								;
	move.b  (A0), D5				; read status  = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#$C0, D5				; SA000000
	or.b	D5, D6					; D6.b = SACBRLDU j2
	swap	D6						; move j2 to high word in D6
	subq.l	#IO_DATA_2-IO_DATA_1, A0; load data_2 address by cheating a bit
	move.b	#$40, (A0)				; set TH high for next pass
	move.b	(A0), D6				; read status j1 = 00CBRLDU
	move.b 	#$00, (A0)				; set TH low
	nop								; wait to settle
	nop								;
	move.b  (A0), D5				; read status  = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#$C0, D5				; SA000000
	or.b	D5, D6					; D6.b = SACBRLDU j1
	move.b	#$40, (A0)				; set TH high for next pass
	move.l	D6, (A1)				; store to RAM
	rts
