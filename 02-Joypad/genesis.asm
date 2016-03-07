; ************************************
; VDP Addresses
; ************************************
VDP_DATA				equ $00C00000
VDP_CTRL				equ $00C00004
VDP_HVCOUNTER			equ $00C00008
VDP_PSG					equ $00C00011

; VDP Control Masks
VDP_VSRAM_WRITE			equ $40000010
VDP_VSRAM_READ			equ $00000010
VDP_CRAM_WRITE			equ $C0000000
VDP_CRAM_READ			equ $00000020
VDP_VRAM_WRITE			equ $40000000
VDP_VRAM_READ			equ $00000000

vdp_write_palettes		equ $F0000000
vdp_write_tiles			equ $40000000
vdp_write_plane_a		equ $40000003
vdp_write_sprite_tiles	equ $60000000
vdp_write_sprite_table	equ $60000003

; ************************************
; I/O Addresses
; ************************************
IO_VERSIONNO			equ $00A10001
IO_DATA_1				equ $00A10003		; byte reads
IO_DATA_2				equ $00A10005		; byte reads
IO_DATA_EXP				equ $00A10007
IO_CTRL_1				equ $00A10009
IO_CTRL_2				equ $00A1000B
IO_CTRL_EXP				equ $00A1000D
IO_TXDATA_1				equ $00A1000F
IO_RXDATA_1				equ $00A10011
IO_SCTRL_1				equ $00A10013
IO_TXDATA_2				equ $00A10015
IO_RXDATA_2				equ $00A10017
IO_SCTRL_2				equ $00A10019
IO_TXDATA_3				equ $00A1001B
IO_RXDATA_3				equ $00A1001D
IO_SCTRL_EXP			equ $00A1001F

; ************************************
; Z80 Addresses
; ************************************
Z80_MEMSPACE			equ $00A00000
Z80_RAM					equ $00A00000

; ************************************
; CTRL Addresses
; ************************************
CTRL_MEMMODE			equ $00A11000
CTRL_Z80BUSREQ			equ	$00A11100
CTRL_Z80RESET			equ $00A11200
CTRL_TIME				equ $00A13000
CTRL_TMSS				equ $00A14000

Z80Reset_m		MACRO
	move.w	#$0000, CTRL_Z80RESET
	exg.l	A0,A1					; waste some time
	exg.l	A1,A0
	move.w	#$0100, CTRL_Z80RESET	
	ENDM

Z80Request_m	MACRO
	move.w	#$0100, CTRL_Z80BUSREQ
.Wait
	btst.b	#0, CTRL_Z80BUSREQ
	bne.s	.Wait
	ENDM

Z80Release_m	MACRO
	move.w	#$0000, CTRL_Z80BUSREQ
	ENDM

; ************************************
; Other Addresses
; ************************************
M68K_RAM				equ $00FF0000

; ************************************
; JOY bit numbers 	SACBRLDU
; ************************************
JOY_UP           		equ 0
JOY_DOWN         		equ 1
JOY_LEFT         		equ 2
JOY_RIGHT        		equ 3
JOY_A            		equ 6
JOY_B            		equ 4
JOY_C            		equ 5
JOY_START        		equ 7


