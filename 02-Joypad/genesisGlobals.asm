; ************************************
; VDP Addresses
; ************************************
VDP_DATA				equ 0x00C00000
VDP_CTRL				equ 0x00C00004
VDP_HVCOUNTER			equ 0x00C00008
VDP_PSG					equ 0x00C00011

vdp_write_palettes		equ 0xF0000000
vdp_write_tiles			equ 0x40000000
vdp_write_plane_a		equ 0x40000003
vdp_write_sprite_tiles	equ 0x60000000
vdp_write_sprite_table	equ 0x60000003

; ************************************
; I/O Addresses
; ************************************
IO_CTRL1DATA			equ 0x00A10002
IO_CTRL2DATA			equ 0x00A10004
IO_EXPDATA				equ 0x00A10006
IO_CTRL1CTRL			equ 0x00A10008
IO_CTRL2CTRL			equ 0x00A1000A
IO_EXPCTRL				equ 0x00A1000C
IO_CTRL1TX				equ 0x00A1000E
IO_CTRL1RX				equ 0x00A10010
IO_CTRL1SCTRL			equ 0x00A10012
IO_CTRL2TX				equ 0x00A10014
IO_CTRL2RX				equ 0x00A10016
IO_CTRL2SCTRL			equ 0x00A10018
IO_EXPTX				equ 0x00A1001A
IO_EXPRX				equ 0x00A1001C
IO_EXPSCTRL				equ 0x00A1001E

; ************************************
; Z80 Addresses
; ************************************
Z80_MEMSPACE			equ 0x00A00000
Z80_BUSREQ				equ	0x00A11100
Z80_RESET				equ 0x00A11200

; ************************************
; Other Addresses
; ************************************
VERSION_REG				equ 0x00A10000
TMSS_REG				equ 0x00A14000
M68K_RAM				equ 0x00FF0000


