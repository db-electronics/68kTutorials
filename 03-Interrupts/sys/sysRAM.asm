; ************************************
; Soft Interrupt Vectors
; ************************************
_RAMVECTORSBASE			EQU		$00FF0000
vintvector				EQU		_RAMVECTORSBASE+0
hintvector				EQU		_RAMVECTORSBASE+4
xintvector				EQU		_RAMVECTORSBASE+8
vintcounter				EQU		_RAMVECTORSBASE+12

; ************************************
; Joypads
; ************************************
_RAMJOYSTATEBASE		EQU		$00FF0010
joy1state				EQU		_RAMJOYSTATEBASE+0
joy2state				EQU		_RAMJOYSTATEBASE+2

