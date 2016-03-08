# Tutorial 02 - Joypad

This tutorial is primarily intended to teach myself how to read the joypad. In Tutorial-01, there was practically no code written by me - as with most introductions I simply took existing code and got it to compile on my machine. Tutorial-02 is where I start to customize the environment and add my coding style.

The tutorial will cover 3 basic elements:

- Reading the Genesis Joypad
- Separating the code into logical entities
- Modifying the initialization code to my liking

## Reading the Joypad
### Protocol
The Genesis 3 button joypad is a fairly simple device. It consists of a 6 bit data bus which multiplexes the different button values. Why 6 bits? Well, the original Master System controller only had 6 buttons (Up, Down, Left, Right, 1, 2) and Sega wished to keep the same physical interface on the Genesis. But, the Genesis has 8 total buttons on the standard controller, therefore, we need to do a bit of processing in order to retrieve the full status of the Joypad.

In the Joypad, a 74HC157 multiplexes the different buttons onto the 6 bit bus. A select signal (called TH from here on) controls which buttons are currently broadcast onto the bus.

Data | TH = '1' | TH = '0'
------------ | ------------- | -------------
D0 | Up | Up 
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
85	move.b 	#$40, IO_CTRL_1	  		; Controller port 1 CTRL, TH = output
86	move.b 	#$40, IO_CTRL_2	 		; Controller port 2 CTRL, TH = output
87	move.b 	#$00, IO_CTRL_EXP 		; EXP port CTRL
88	move.b	#$40, IO_DATA_1			; Idle with TH = '1'
89	move.b	#$40, IO_DATA_2			; Idle with TH = '1'
```
Line 85, 86 make TH an output (bit 6 = '1') so that we can use it to drive the select signal of the multiplexer inside the joypad.

Line 88, 89 set the TH pins to '1' immediately (bit 6 = '1'). This way, when reach our joypad reading subroutine the joypad databus will already have stable data for TH = '1'.

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
I start by loading two addresses in A0 and A1. A0 points to **IO_DATA_1** register ($00A10003) which contains the 6 bit joypad bus discussed earlier. A1 points to a RAM variable which will be used to store the joypad state.
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

That's it! There's a second routine in joypad.asm which reads both joypads and stores the results in the RAM location pointed to by **joy1state** in the format:
```
xxxxxxxx SACBLRDU xxxxxxxx SACBLRDU
```

Why did I leave a blank byte between each joypad state? Simple, I will probably want to add 6 button support to my routines in the future. This data configuration is expandable and will be backwards compatible.


We can now verify that the code is functioning properly by assembling it using the included **build.sh** and running the out/rom.bin in MESS with debug enabled:
```
mess genesis -cart out/rom.bin -debug
```
Open a new memory window in MESS, point to beginning of RAM ($FF0000) and run the program. You see see the joystate1 location change bit patterns when you press the keys corresponding to player 1 inputs. As a simple homework assignment, you should try to modify the code to use the other subroutine in **joypad.asm** which reads both joypads.

##Separating the code into logical entities

New in Tutorial-02's structure is the SYS folder. I decided all system relevant data, defines, etc... should be included in the SYS folder. The SYS folder contains address definitions, start-up code - anything which is generic enough to be similar throughout many/any project will be dumped into SYS. Adopting this structure will make creating a new project quite simple.

### SYS Folder Current Contents
- sys/sysDef.asm
  - contains static addresses and useful bitmasks
- sys/sysInit.asm
  - contains entry start-up code (ORG $200) which initialize the memory, video and sound subsystems to known states
- sys/sysMacros.asm
  - contains useful macros for operations which will be used frequently in game code
- sys/sysRAM.asm
  - contains a RAM map for variables used by the system such as interrupt vectors, joypad status, etc...

The SYS folder will evolve with each tutorial but it will always only contain generic code/data that is reusable. For instance, future tutorials will include **sysJoypad.asm** which will contain more or less the joypad subroutines developped in this tutorial since all games need to read from the joypads. I did not include **header.asm** in the SYS folder because header is supposed to contain data specific to a project, i.e. project name, size, checksum, SRAM usage, etc...

### MAIN.asm
**Main.asm** is where all files are regrouped and organized. This is the top-level .asm file which is called by **build.sh**. The idea here is to only use 'include' and other assembler directives in order to organize defines/macros/code/data to your liking. In Tutorial-02, I did the following:
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

##Modifying the Initialization Code

For the average observer, it may seem that I'm giving myself alot of trouble to make a simple joypad reading tutorial. In fact, I know that I'm going to expand on this tutorials ALOT in the future; this is why I am taking extra care in organizing the code and data properly from the get-go. 

### Header

As discussed earlier, I moved the ROM header portion of Tutorial-01's **init.asm** to its own file called **header.asm**. Header should not be part of SYS because it is project specific. The header is $200 bytes in size but there are no safeguards in **header.asm** against this. Therefore, I placed an **ORG $200** at the beginning of **sys/sysInit.asm** which should complain if you accidently make **header.asm** too long.

### Slight Optimizations

In Tutorial-01, the M68K RAM was cleared using this routine:
```
; ************************************
; Clear RAM
; ************************************
	move.l #0x00000000, d0     ; Place a 0 into d0, ready to copy to each longword of RAM
	move.l #0x00000000, a0     ; Starting from address 0x0, clearing backwards
	move.l #0x00003FFF, d1     ; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
.Clear:
	move.l d0, -(a0)           ; Decrement the address by 1 longword, before moving the zero from d0 to it
	dbra d1, .Clear            ; Decrement d0, repeat until depleted
```
There are several ways we can improve this. Firstly, you should never move #$00 into a data register, instead you should use clr.b/clr.w or clr.l. This saves both cycles and data. With the move instructions, the M68K has to perform 2 extra word reads from ROM to retrieve the immediate long value $00 whereas clr is SPECIFICALLY designed to zero registers. 

Next, the loop moves #$00 to A0 - sadly there is no clr for address registers, but you can optimize it to **suba.l A0,A0**. But we're not going to optimize it this way. Instead, we're going to explore the loop a bit more. This Clear RAM starts at the very last RAM address and pre-decrements its way down to the beginning of RAM moving 16K of longs (= 64KB). If you google the M68K instruction set you'll quickly notice that post-incrementing an address register is quicker than pre-decrementing. Since this loop is executing 16K times it's definitely worth it to change. In fact, whenever possible you should always favour post-inc to pre-dec for optimizations.

The optimized loop is as follows:
```
; ************************************
; Clear RAM
; ************************************
	clr.l	D0						; Place a 0 into d0, ready to copy to each longword of RAM
	move.l	M68K_RAM, A0			; A0 points to beginning of RAM
	move.l 	#$00004000, D1     		; Clearing 64k's worth of longwords
.Clear:
	move.l 	D0, (A0)+           	; Post-inc faster than Pre-dec (as last tutorial)
	dbra 	D1, .Clear          	; Decrement d0, repeat until depleted
```

Next let's look at the Z80 Init code:
```
; ************************************
; Init Z80
; ************************************
	move.w #0x0100, 0x00A11100    ; Request access to the Z80 bus, by writing 0x0100 into the BUSREQ port
	move.w #0x0100, 0x00A11200    ; Hold the Z80 in a reset state, by writing 0x0100 into the RESET port

.Wait:
	btst #0x0, 0x00A11100      ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
	bne .Wait                  ; If we don't yet have control, branch back up to Wait
	
	move.l #Z80Data, a0        ; Load address of data into a0
	move.l #0x00A00000, a1     ; Copy Z80 RAM address to a1
	move.l #0x29, d0           ; 42 bytes of init data
.CopyZ80:
	move.b (a0)+, (a1)+        ; Copy data, and increment the source/dest addresses
	dbra d0, .CopyZ80

	move.w #0x0000, 0x00A11200    ; Release reset state
	move.w #0x0000, 0x00A11100    ; Release control of bus
```
The first 4 and last 2 instructions deal with Z80 bus request and release. I know we'll be using this type of code elsewhere in later programs so I decided to make 3 macros out of these: Z80Reset_m, Z80Request_m and Z80Relese_m.
```
Z80Reset_m		MACRO
	move.w	#$0000, CTRL_Z80RESET
	exg.l	A0,A1					; waste some time
	exg.l	A1,A0
	move.w	#$0100, CTRL_Z80RESET	
	ENDM

Z80Request_m	MACRO
	move.w	#$0100, CTRL_Z80BUSREQ
.\?Wait
	btst.b	#0, CTRL_Z80BUSREQ
	bne.s	.\?Wait
	ENDM

Z80Release_m	MACRO
	move.w	#$0000, CTRL_Z80BUSREQ
	ENDM
```
The symbol \? in the above macros is a special ASMX symbol which ensures that labels are not duplicated in multiple macro calls.

Next, the only other thing that I really didn't like about the original Z80 Init code in Tutorial-01 was:
```
move.l #0x29, d0           ; 42 bytes of init data
```
Now it's true that Tutorial-01 does in fact load 42 bytes of init code to the Z80. But what if I want to change that init code, and most likely, I don't remember to also go to the above line of code and update the size of the transfer? Luckily there's a simple solution to this using labels. Assemblers always translate labels to addresses therefore we can label both the start and end of our data block and subtract the two labels - this way the assembler auto-calculates the length of the transfer for us at compile time. I also opted to add extra code in my new Z80init to clear the 8KB of Z80 RAM.
```
; ************************************
; Init Z80
; ************************************
	Z80Reset_m
	Z80Request_m

	; clear the Z80's 8KB of RAM
	move.w	#$2000, D0				; 8KB of Z80 RAM to clear
	move.l	#Z80_RAM, A1			; A1 points to Z80 RAM
.ClearZ80
	clr.b	(A1)+					; clear bytes, $00 is Z80 nop
	dbra	D0, .ClearZ80				

	; load simple program to Z80
	move.l 	#Z80Data, A0        	; Load address of data into a0
	move.l 	#Z80_RAM, A1     		; Copy Z80 RAM address to a1
	move.l 	#Z80DataEnd-Z80Data, D0 ; Auto-calculate size of transfer using labels
.CopyZ80:
	move.b 	(A0)+, (A1)+        	; Copy data, and increment the source/dest addresses
	dbra 	D0, .CopyZ80

	Z80Reset_m
	Z80Release_m
	
Z80Data:
[data goes here, bunch of dc.b...]
Z80DataEnd:
```
There are a few more differences between Tutorial-01 and Tutorial-02's init code. I invite the curious to study the additional differences.
