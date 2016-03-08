# Tutorial 02 - Joypad

This tutorial is primarily intended to teach myself how to read the joypad. In Tutorial-01, there was practically no code written by me - as with most introductions I simply took existing code and got it to compile on my machine. Tutorial-02 is where I start to customize the environment and add my coding style.

The tutorial will cover 3 basic elements:

- Reading the Genesis Joypad
- Separating the code into logical entities
- Modifying the initialization code to my liking

## Reading the Joypad
### Protocol
The Genesis 3 button joypad is a fairly simple device. It consists of a 6bit data bus which multiplexes the different button values. Why 6 bits? Well, the original Master System controller only had 6 buttons (Up, Down, Left, Right, 1, 2) and Sega wished to keep the same physical interface on the Genesis. But, the Genesis has 8 total buttons on the standard controller, therefore, we need to do a bit of processing in order to retrieve the full status of the Joypad.

In the Joypad, a 74HC157 multiplexes the different buttons onto the 6 bit bus. A select signal (called TH from here on) controls which buttons are currently broadcast onto the bus.

Data | TH = '1' | TH = '0'
------------ | ------------- | -------------
DO | Up | Up 
D1 | Down | Down
D2 | Left | '0'
D3 | Right | '0'
D4 | B | A
D5 | C | Start

When TH - '1', the Joypad acts as a Master System controller. In fact, when using a Power Base Converter, buttons B & C become buttons 1 and 2 of the Master System respectively. When TH = '0', the buttons A and Start are broadcast.

### Joypad Init Routine
First, we need some code to initialize the Joypad:

```
sys/sysInit.asm
Line 85:
	move.b 	#$40, IO_CTRL_1	  		; Controller port 1 CTRL, TH = output
	move.b 	#$40, IO_CTRL_2	 		; Controller port 2 CTRL, TH = output
	move.b 	#$00, IO_CTRL_EXP 		; EXP port CTRL
	move.b	#$40, IO_DATA_1			; Idle with TH = '1'
	move.b	#$40, IO_DATA_2			; Idle with TH = '1'
```
Line 85, 86 make TH an output (bit6 = '1') so that we can use it to drive the select signal of the multiplexer inside the joypad.

Line 88, 89 set the TH pins to '1' immediately (bit6 = '1'). This way, when reach our joypad reading subroutine the joypad databus will already have stable data for TH = '1'.

The labels **IO_CTRL_1** and others are defined in **sys/sysDef.asm** which contain all relevant Genesis definitions. I will discuss this more in the last section of this tutorial
```
sys/sysDef.asm
IO_DATA_1				equ $00A10003
IO_DATA_2				equ $00A10005
[etc...]
```

### Joypad Read Routine
The joypad read subroutine is rather simple. I make use of the M68K's address and data registers to process the information quickly - as with any M68K assembly code optimization lies in proper usage of these registers.
```
joypad.asm
Line 19:
JOYPAD_ReadPad01:
	move.l	#IO_DATA_1, A0			; load data_1 address
	move.l	#joy1State, A1			; point to RAM placeholder for joystate
```
I start by loading two addresses in A0 and A1. A0 points to **IO_DATA_1** register ($00A10003) which contains the 6bit joypad bus discussed earlier. A1 points to a RAM variable which will be used to store the joypad state.
```
	move.b	(A0), D6				; read status j1 = 00CBRLDU
	move.b 	#$00, (A0)				; set TH low
	nop								; wait to settle
```
Since we setup TH to idle at '1', the first read (into D6) contains 0,0,C,B,Right,Left,Down,Up. Then I write $00 to the joypad data port, TH is the only pin set to an output therefore it is the only bit affected by this write. This is followed by a NOP to let the signals settle before we attempt another read.
```
	move.b  (A0), D5				; read status = 00SA00DU
	rol.b	#2, D5					; SA00DU??
	andi.b	#$C0, D5				; SA000000
	or.b	D5, D6					; D6 = SACBRLDU
```
Next I read the second series of values from the joypad into D5 (earlier we used D6) since this read contains new data. We can exploit the fact that the first read contains zeros in bits 6 & 7 and shift up our second read by two bits such that the Start and A values are now found in bits 6 & 7 (rol.b #2, D5). Then, I mask off all other bits since we already have them in D6 (andi.b #$C0, D5) and or the result with D6. After this, D6 now contains: Start, A, C, B, Right, Left, Down and Up.
```
	move.b	#$40, (A0)				; set TH high for next pass
	move.w	D6, (A1)				; store to RAM
	rts
```
I finish the joypad read subroutine by setting TH to '1' again to be ready for the next read. Finally, I store D6 to RAM variable location we loaded earlier so that the main code can use the joypad status.

That's it! There's a second routine in joypad.asm which reads both joypads and stores the results in the format:
```
xxxxxxxx SACBLRDU xxxxxxxx SACBLRDU
```
Why did I leave a blank byte between each joypad state? Simple, I will probably want to add 6 button support to my routines in the future. This data configuration is expandable and will be backwards compatible.

##Separating the code into logical entities

New in Tutorial-02's structure is the sys folder. I decided all system relevant date, defines, etc... should be include in the sys folder. The sys folder contains address definitions, start-up code - anything which is generic enough to be similar throughout many/any project will be dumped into sys. Adopting this structure will make creating a new project quite simple.

### SYS Folder
- sys/sysDef.asm
  - contains static addresses and useful bitmasks
- sys/sysInit.asm
  - contains entry start-up code (ORG $200) which initialize the memory, video and sound subsystems to known states
- sys/sysMacros.asm
  - contains useful macros for operations which will be used frequently in game code
- sys/sysRAM.asm
  - contains a RAM map for variables used by the system such as interrupt vectors, joypad status, etc...

The SYS folder will evolve with each tutorial but it will always only contain generic code/data that is reusable. I did not include header.asm in the SYS folder because header is supposed to contain data specific to a project, i.e. project name, size, checksum, SRAM usage, etc...

### MAIN.asm
**Main.asm** is where all files are regrouped and organized. This is the top-level .asm file which is called by build.sh. The idea here is to only use 'include' and other assembler directives in order to organize defines/macros/code/data to your liking. In Tutorial-02, I did the following:
```
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
```
In the above, up until the section **Header and Startup Code** there is no actual assembled code; it only consists of definitions and macros (and should be kept that way). The file **header.asm** contains data which MUST be at memory location $000000 and therefore no other assembled code or data can exist before it. Afterwards, **sys/sysInit.asm**, as discussed earlier, contains generic start-up code which is dynamically referenced by **header.asm** but should idealy still be placed immediately after the header. Finally, the section **User Program**, obviously, is where the project specific files should be included. When *sysInit.asm* is done is will jump to the label **__main:** which should flow right into any file included immediately after it.
