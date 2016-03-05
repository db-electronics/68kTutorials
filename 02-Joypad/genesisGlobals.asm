; ************************************
; VDP Addresses
; ************************************
VDP_DATA				equ 0x00C00000
VDP_CTRL				equ 0x00C00004
VDP_HVCOUNTER			equ 0x00C00008
VDP_PSG					equ 0x00C00011

; VDP Control Masks
VDP_VSRAM_WRITE			equ 0x40000010
VDP_VSRAM_READ			equ 0x00000010
VDP_CRAM_WRITE			equ 0xC0000000
VDP_CRAM_READ			equ 0x00000020
VDP_VRAM_WRITE			equ 0x40000000
VDP_VRAM_READ			equ 0x00000000

vdp_write_palettes		equ 0xF0000000
vdp_write_tiles			equ 0x40000000
vdp_write_plane_a		equ 0x40000003
vdp_write_sprite_tiles	equ 0x60000000
vdp_write_sprite_table	equ 0x60000003

; ************************************
; I/O Addresses
; ************************************
IO_VERSIONNO			equ 0x00A10001
IO_DATA_1				equ 0x00A10003		; byte reads
IO_DATA_2				equ 0x00A10005		; byte reads
IO_DATA_EXP				equ 0x00A10007
IO_CTRL_1				equ 0x00A10009
IO_CTRL_2				equ 0x00A1000B
IO_CTRL_EXP				equ 0x00A1000D
IO_TXDATA_1				equ 0x00A1000F
IO_RXDATA_1				equ 0x00A10011
IO_SCTRL_1				equ 0x00A10013
IO_TXDATA_2				equ 0x00A10015
IO_RXDATA_2				equ 0x00A10017
IO_SCTRL_2				equ 0x00A10019
IO_TXDATA_3				equ 0x00A1001B
IO_RXDATA_3				equ 0x00A1001D
IO_SCTRL_EXP			equ 0x00A1001F

; ************************************
; Z80 Addresses
; ************************************
Z80_MEMSPACE			equ 0x00A00000
Z80_RAM					equ 0x00A00000

; ************************************
; CTRL Addresses
; ************************************
CTRL_MEMMODE			equ 0x00A11000
CTRL_Z80BUSREQ			equ	0x00A11100
CTRL_Z80RESET			equ 0x00A11200
CTRL_TIME				equ 0x00A13000
CTRL_TMSS				equ 0x00A14000

; ************************************
; Other Addresses
; ************************************
M68K_RAM				equ 0x00FF0000

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


