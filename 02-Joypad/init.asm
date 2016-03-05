	include 'genesisGlobals.asm'

; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
	dc.l   0x00FFE000      ; Initial stack pointer value
	dc.l   EntryPoint      ; Start of program
	dc.l   Exception       ; Bus error
	dc.l   Exception       ; Address error
	dc.l   Exception       ; Illegal instruction
	dc.l   Exception       ; Division by zero
	dc.l   Exception       ; CHK exception
	dc.l   Exception       ; TRAPV exception
	dc.l   Exception       ; Privilege violation
	dc.l   Exception       ; TRACE exception
	dc.l   Exception       ; Line-A emulator
	dc.l   Exception       ; Line-F emulator
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Spurious exception
	dc.l   Exception       ; IRQ level 1
	dc.l   Exception       ; IRQ level 2
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
	dc.l   Exception       ; TRAP #00 exception
	dc.l   Exception       ; TRAP #01 exception
	dc.l   Exception       ; TRAP #02 exception
	dc.l   Exception       ; TRAP #03 exception
	dc.l   Exception       ; TRAP #04 exception
	dc.l   Exception       ; TRAP #05 exception
	dc.l   Exception       ; TRAP #06 exception
	dc.l   Exception       ; TRAP #07 exception
	dc.l   Exception       ; TRAP #08 exception
	dc.l   Exception       ; TRAP #09 exception
	dc.l   Exception       ; TRAP #10 exception
	dc.l   Exception       ; TRAP #11 exception
	dc.l   Exception       ; TRAP #12 exception
	dc.l   Exception       ; TRAP #13 exception
	dc.l   Exception       ; TRAP #14 exception
	dc.l   Exception       ; TRAP #15 exception
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)

; size    012345678901234567890123456789012345678901234567
	dc.b "SEGA GENESIS    "									; Console name - 16
	dc.b "(C)db   2016.MAR"									; Copyright holder and release date - 16
	dc.b "DB JOYPAD TUTORIAL                              "	; Domestic name - 48
	dc.b "DB JOYPAD TUTORIAL                              "	; International name - 48
	dc.b "GM JPTUTORIAL-01"									; Version number - 48
	dc.w 0x1234												; Checksum
	dc.b "J               "									; I/O support - 16
	dc.l 0x00000000											; Start address of ROM
	dc.l __end												; End address of ROM
	dc.l 0x00FF0000											; Start address of RAM
	dc.l 0x00FFFFFF											; End address of RAM
	dc.l 0x00000000											; SRAM enabled
	dc.l 0x00000000											; Unused
	dc.l 0x00000000											; Start address of SRAM
	dc.l 0x00000000											; End address of SRAM
	dc.l 0x00000000											; Unused
	dc.l 0x00000000											; Unused
	dc.b "                                        "			; Notes (unused)
	dc.b "JUE             "									; Country codes

EntryPoint:           ; Entry point address set in ROM header

; ************************************
; Test reset button
; ************************************
	tst.w 	0x00A10008  			; Test mystery reset (expansion port reset?)
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main
	tst.w 	IO_EXPCTRL  			; Test reset button
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main

; ************************************
; Clear RAM
; ************************************
	move.l 	#0x00000000, d0     	; Place a 0 into d0, ready to copy to each longword of RAM
	move.l 	#0x00000000, a0     	; Starting from address 0x0, clearing backwards
	move.l 	#0x00003FFF, d1     	; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
.Clear:
	move.l 	d0, -(a0)           	; Decrement the address by 1 longword, before moving the zero from d0 to it
	dbra 	d1, .Clear          	; Decrement d0, repeat until depleted
	
; ************************************
; Write TMSS
; ************************************
	move.b 	0x00A10001, d0      	; Move Megadrive hardware version to d0
	andi.b 	#0x0F, d0           	; The version is stored in last four bits, so mask it with 0F
	beq.s 	.Skip               	; If version is equal to 0, skip TMSS signature
	move.l 	#'SEGA', CTRL_TMSS 		; Move the string "SEGA" to 0xA14000
.Skip:

; ************************************
; Init Z80
; ************************************
	move.w 	#0x0100, CTRL_Z80BUSREQ ; Request access to the Z80 bus, by writing 0x0100 into the BUSREQ port
	move.w 	#0x0100, CTRL_Z80RESET  ; Hold the Z80 in a reset state, by writing 0x0100 into the RESET port

.Wait:
	btst 	#0x0, CTRL_Z80BUSREQ    ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
	bne.s 	.Wait                  	; If we don't yet have control, branch back up to Wait
	
	move.l 	#Z80Data, a0        	; Load address of data into a0
	move.l 	#Z80_RAM, a1     		; Copy Z80 RAM address to a1
	move.l 	#42, d0           		; 42 bytes of init data
.CopyZ80:
	move.b 	(a0)+, (a1)+        	; Copy data, and increment the source/dest addresses
	dbra 	d0, .CopyZ80

	move.w 	#0x0000, CTRL_Z80RESET  ; Release reset state
	move.w	#0x0000, CTRL_Z80BUSREQ ; Release control of bus

; ************************************
; Init PSG
; ************************************
	move.l 	#PSGData, a0        	; Load address of PSG data into a0
	move.l 	#0x03, d0           	; 4 bytes of data
.CopyPSG:
	move.b 	(a0)+, VDP_PSG   		; Copy data to PSG RAM
	dbra 	d0, .CopyPSG
	
; ************************************
; Init VDP
; ************************************
	move.l 	#VDPRegisters, a0   	; Load address of register table into a0
	move.l 	#0x18, d0           	; 24 registers to write
	move.l 	#0x00008000, d1     	; 'Set register 0' command (and clear the rest of d1 ready)

.CopyVDP:
	move.b 	(a0)+, d1           	; Move register value to lower byte of d1
	move.w 	d1, VDP_CTRL     		; Write command and value to VDP control port
	add.w 	#0x0100, d1          	; Increment register #
	dbra 	d0, .CopyVDP

; ************************************
; Init IO Ports
; ************************************
	move.b 	#0x00, IO_CTRL_1	  	; Controller port 1 CTRL
	move.b 	#0x00, IO_CTRL_2	 	; Controller port 2 CTRL
	move.b 	#0x00, IO_CTRL_EXP 		; EXP port CTRL
	move.b	#0x40, IO_DATA_1		; Idle with TH = '1'
	move.b	#0x40, IO_DATA_2		; Idle with TH = '1'	

; ************************************
; Cleanup
; ************************************
	move.l 	#0x00FF0000, a0     	; Move address of first byte of ram (contains zero, RAM has been cleared) to a0
	movem.l (a0), d0-d7/a1-a7  		; Multiple move zero to all registers
	move.l 	#0x00000000, a0     	; Clear a0

	; Init status register (no trace, supervisor mode, all interrupt levels enabled, clear condition code bits)
	move 	#0x2000, sr

; ************************************
; Main
; ************************************
Main:
	jmp __main 						; Begin external main

HBlankInterrupt:
	rts
VBlankInterrupt:
	addi.l	#1, d7					; increment d7 as Vint counter
   	rts

Exception:
   	stop #$2700 					; Halt CPU
   
Z80Data:
   	dc.w 0xaf01, 0xd91f
   	dc.w 0x1127, 0x0021
   	dc.w 0x2600, 0xf977
   	dc.w 0xedb0, 0xdde1
   	dc.w 0xfde1, 0xed47
   	dc.w 0xed4f, 0xd1e1
   	dc.w 0xf108, 0xd9c1
   	dc.w 0xd1e1, 0xf1f9
   	dc.w 0xf3ed, 0x5636
   	dc.w 0xe9e9, 0x8104
   	dc.w 0x8f01

PSGData:
   	dc.w 0x9fbf, 0xdfff
   
VDPRegisters:
	dc.b 0x14 ; 0: Horiz. interrupt on, display on
	dc.b 0x74 ; 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
   	dc.b 0x30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
   	dc.b 0x40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
   	dc.b 0x05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
   	dc.b 0x70 ; 5: Sprite table at 0xE000 (bits 0-6)
   	dc.b 0x00 ; 6: Unused
   	dc.b 0x00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   	dc.b 0x00 ; 8: Unused
   	dc.b 0x00 ; 9: Unused
   	dc.b 0x00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   	dc.b 0x08 ; 11: External interrupts on, V/H scrolling on
   	dc.b 0x81 ; 12: Shadows and highlights off, interlace off, H40 mode (64 cells horizontally)
   	dc.b 0x34 ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
   	dc.b 0x00 ; 14: Unused
   	dc.b 0x00 ; 15: Autoincrement off
   	dc.b 0x01 ; 16: Vert. scroll 32, Horiz. scroll 64
   	dc.b 0x00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   	dc.b 0x00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   	dc.b 0x00 ; 19: DMA length lo byte
   	dc.b 0x00 ; 20: DMA length hi byte
   	dc.b 0x00 ; 21: DMA source address lo byte
   	dc.b 0x00 ; 22: DMA source address mid byte
   	dc.b 0x00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
