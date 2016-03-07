# Tutorial 02 - Joypad

This tutorial is primarily intended to teach myself how to read the joypad. In tutorial 01, there was practically no code written by myself - as with most introductions I simply took existing code and got it to compile on my machine. Tutorial 02 is where I start to customize the environment and add my coding style.

The tutorial will cover 3 basic elements:

- Reading the Genesis Joypad
- Separating the code into logical entities
- Modifying the initialization code to my liking

## Reading the Joypad
### Protocol
The Genesis 3 button joypad is a fairly simple device. It consists of a 6bit data bus which multiplexes the different button values. Why 6bits? Well, the original Master System controller only had 6 buttons (Up, Down, Left, Right, 1, 2) and Sega wished to keep the same physical interface on the Genesis. But, the Genesis has 8 total buttons on the standard controller, therefore, we need to do a bit of processing in order to retrieve the full status of the Joypad.

In the Joypad, a 74HC157 multiplexes the different buttons onto the 6bit bus. A select signal (called TH from here on) controls which buttons are currently broadcast onto the bus.

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
First, we need some code to initialize the Joypad (Line 85, sys/sysInit.asm):

```
85	move.b 	#$40, IO_CTRL_1	  		; Controller port 1 CTRL, TH = output
86	move.b 	#$40, IO_CTRL_2	 		; Controller port 2 CTRL, TH = output
87	move.b 	#$00, IO_CTRL_EXP 		; EXP port CTRL
88	move.b	#$40, IO_DATA_1			; Idle with TH = '1'
89	move.b	#$40, IO_DATA_2			; Idle with TH = '1'
```
Line 85, 86 make the TH an output so that we can use it to drive the select signal of the multiplexer inside the joypad.

Line 88, 89 set the TH pins to '1' immediately. This way, when reach our joypad reading subroutine the joypad databus will already have stable data for TH = '1'.

### Joypad Read Routine
