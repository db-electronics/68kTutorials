; ************************************
; COMPILER OPTIONS
; ************************************
	LIST MACRO
	LIST NOSYM
	LIST NOTEMP

; ************************************
; SYSTEM DEFINES
; ************************************
	include 'sys/sysDef.asm'
	include 'sys/sysRAM.asm'

; ************************************
; MACROS
; ************************************
	include	'sys/sysMacros.asm'

; ************************************
; HEADER AND STARTUP CODE
; ************************************
	include 'header.asm'
	include 'sys/sysInit.asm'

; ************************************
; USER PROGRAM
; ************************************
__main:
	include 'joypad.asm'
__end:

; debug in MESS using
; mess genesis -cart out/rom.bin -window -debug
