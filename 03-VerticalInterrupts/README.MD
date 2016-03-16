#Tutorial 03 - Vertical Interrupts

There are three interrupts in the Sega Genesis: vertical, horizontal, and external. This tutorial will deal with basics surrounding the vertical interrupt. I implemented a few system functions which I think will be useful to any future project including a millisecond timer and dynamic vector system. I also improved the build.sh script file from tutorial-02 to now accept a -d parameter to automatically call MESS in debug mode with the built binary - excellent!

The tutorial will be split into two sections:
* Vertical Interrupt Basics
* Region Agnostic Timing

##Vertical Interrupts Basics

In the Sega Genesis, interrupts use the AUTO-VECTOR mode of the 68k and are at levels 6, 4, and 2 respectively. The vertical interrupt is the level 6 interrupt which has the highest priority. Vertical interrupts (Vint from here on) occur at the beginning of the vertical blanking portion of each frame; 60Hz for NTSC and 50Hz for PAL. Best practise for any interrupt routine is to be as short as possible.

###Enabling Vint

Vint is doubly enabled in the Sega Genesis. First, the interrupt level mask is set in the 68k's status register is set by writing to the IE0-IE1-IE2 bits (bits 8,9 and 10 of SR). In Tutorial-03 I simply set all bits to zero to enable all interrupt levels. Line 136 of **sys/sysInit.68k** enables the interrupts from the 68k side:
```
	; Init status register (no trace, supervisor mode, all interrupt levels enabled, clear condition code bits)
	move 	#$2000, SR
```
Second, the VDP must be configured to generate Vint. Line 163 of **sys/sysInit.68k** disables the Horizontal interrupts and line 164 enables Vint:
```
VDPRegisters:
	dc.b $04 ; 0: Horiz. interrupt off
	dc.b $74 ; 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
```
###Vint Vector
In **header.68k** I defined vectors for all interrupt levels, starting at line 56:
```
	dc.l   Exception       ; IRQ level 1
	dc.l   ExtInterrupt    ; IRQ level 2 (external interrupt)
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
```
These set the labels at which the code execution will vector to when the 68k receives the appropriate interrupt level. Note that the VDP will only generate levels 2, 4 and 6 - everything else is an error from our point of view and the code will vector to exception (which currently halts everything). The labels for interrupt levels 2, 4 and 6 are defined in **sys/sysInterrupts.68k**.

###Vint Interrupt Routine
My Vint interrupt is very short and simple. Let's go through it line by line.
```
VBlankInterrupt:
	addq.w	#1, sysframecnt				; increment vint counter
	add.w	sysmillisinc, D7			; D7 = global millis counter
	bset	#1, intflags				; set vintflag
	tst.l	vintvector					; test vintvector
	beq.s	.noVector					; if vintvector = 0, get out of here!
.vectorValid
	movem.l D0-D6/A0-A6, -(SP)			; push context to stack
	movea.l	vintvector, A0				; put vintvector in A0
	jsr		(A0)						; jsr to vintvector	
	movem.l (SP)+, D0-D6/A0-A6			; pop context from stack
.noVector
   	rte									; return to main code
```
* Line 1 increments the system frame counter variable in RAM which can be used for timing calculations by the main code. 
* Line 2 increments the system milliseconds timer which is in register D7 (I will always dedicate D7 to millis). Now I can hear you asking: "why have a frame counter AND a millis counter?". Well, PAL and NTSC have different frame rates. Using a millis counter (which is initialized according to PAL or NTSC) means that this simple code can generate region agnostic timing which I will discuss a bit later in this tutorial.
* Line 3 sets a vintflag in RAM, this flag will be used by the main code to syncronize to Vint (i.e. wait for Vint)
* Line 4 is where it gets interesting. The **tst.l** opcode is used to test whether or not a value is zero. Here I test a RAM variable called *vintvector*. This variable, *vintvector*, will contain the address of whichever subroutine I decide should be called by Vint. If its value is zero, it means we have no vector and *beq.s .noVector* takes me immediately out of the interrupt routine. HOWEVER, if the main code has set *vintvector* to the address of some routine then the code will reach: 
* Line 7 the *movem.l D0-D6/A0-A6. -(SP)* instruction which is the 68k way of saving the register context to the stack.
* Line 8 takes the address stored in *vinvector* and loads it into A0
* Line 9 jumps to the subroutine pointed to by *vintvector*
* Line 10 restores the register context from the stack once the code has returned from the *vinvector* subroutine. The nice thing here is that I only need to do the expensive push/pop stack operations if a jump to *vintvector* is required since nothing else touches the register context (except for D7 millis timer but my main code will always be aware of this).

###Main Code
Along with the new Vint routine, I wrote a short and simple main loop to interact with the vertical interrupt which is found in **tutorial03.68k**. At the entrypoint of the file I load a bunch of values into the registers - this was just to test and confirm and that the register context was properly pushed and pop by Vint.
```
.newFrame
	lea		intflags, A0				; A0 points to intflags
.syncVint	
	btst	#1, (A0)					; test if a Vertical Interrupt occured
	beq.s	.syncVint					; wait until vint occurs, bit0 set = vint has happened
	bclr	#1, (A0)					; clear the intflag	

	jsr		sysJoy_Read3Button			; read joypad1 state

	move.w	sysframecnt, D0				; load the sysframecnt into D0
	andi.w	#$0003, D0					; look at the lowest two bits of vintcounter
	bne.s	.newFrame					; if zero, load vintvector address, this should execute every 4 frames
	move.l	#VintRoutine, vintvector
	bra.s	.newFrame
```
This program is very simple. First, I point A0 to a RAM variable called **intflags** which is set by Vint. This synchronizes my code to run once per frame else it would run way to fast due to blast processing. The next two instructions simply test the **intflags** variables in a loop and continues to do so until bit 1 (vint) is set (set by Vint). When it's finally set the first thing we need to do is to clear it *bclr	#1, (A0)*. Then I call **sysJoy_Read3Button** which is more or less what I built in Tutorial-02. Next I look at the *sysframecnt* RAM variable by loading it into D0 and AND'ing it with 3 - if the result is 0 (which will be every 4 frames) I skip the branch *bne.s	.newFrame* and proceed to load an address *move.l	#VintRoutine, vintvector* in RAM variable *vintvector* which is the address of the subroutine I want Vint to execute. Recall from the previous section that when *vintvector* is set to a valid non-zero address Vint will execute it.

Finally, the contents of the *VintRoutine* loaded into *vintvector* are rather simple:
```
VintRoutine:
	move.l	D0, vintvector				; clear the vintvector address
	addq.w	#1, M68K_RAM				; increment a variable, should be 1/4 the frame rate
	rts	
```
I simply clear the *vintvector* RAM location to not vector here again accidently without main code explicitely setting it again in 4 frames. Then I increment a RAM variable which will incremant at 1/4 the frame rate. 

Therefore, when you run this code in MESS with debug enabled, you should see the variable sysframecnt increment by 1 at every frame and the variable at M68K_RAM increment by 1 every 4 frames.

###BORING
Yes I know, this readme file is almost 100 lines long, it's Tutorial-03 and all we've accomplished is incrementing variables - ARGH! Well slow down there Pontiac! You can't run without learninng how to walk first. Mastering interrupts in a system like the Sega Genesis where timing is EVERYTHING is extremely important. Also, being able to change the Vint Vector routine at will whilst having a short and simple core vertical interrupt means that my interrupt system is very flexible. I pondered at first with implementing a jump table but I think this approach is simpler and more flexible.

##Region Agnostic Timing
Recall just a few dozen lines above here I mentioned D7 was increment by *some* value at every Vint to generate region agnostic timing. In fact, D7 is increment by either 20 or 16.7 depending on wheter we are runing on a PAL or NTSC console. So how do you add with decimal points in binary - easy - use a binary point.

###Setting Correct Millis Increment
I made some additions to **sys/sysInit.68k** to store the proper millis increment (16.7 or 20) in RAM. I decided to use a number with the binary point set a bit 4 - this means I have 4 bits to express fractional values. Here's a few examples of an 8 bit number which uses 4 bits for fractionals:

* 0b00010001 = 1 1/16
* 0b00100111 = 2 7/16
* 0b10000000 = 8

Therefore, using 4 bits for fractionals, I simply need to shift any integer 4 bits to the left (i.e. x16) in order to represent it with a 4 bit fractional binary number. Therefore, to express 20 and 16.7:

* 20 * 16 = 320 
* 16.7 * 16 = 267.2 (which I round down to 267)


```
; ************************************
; Write TMSS, get System Region
; ************************************
	move.w	#(20<<4), D1			; millis timer init (20ms for PAL)
									; the millis timer is in D7 and has a binary point at bit4, 
	move.b 	IO_VERSIONNO, D0      	; Move Megadrive hardware version to d0
	btst	#6, D0					; Test VMOD bit for region (PAL = 1, NTSC = 0)
	bne.s	.skipForPal
	subi.w	#53, D1					; change millis timer to ~16.7 for NTSC (3.3 * 16 = 52.8)
.skipForPal
	move.w	D1, sysmillisinc		; store value to sysregion
	andi.b 	#$0F, D0           		; The version is stored in last four bits, so mask it with 0F
	beq.s 	.SkipTMSS              	; If version is equal to 0, skip TMSS signature
	move.l 	#'SEGA', CTRL_TMSS 		; Move the string "SEGA" to $A14000
.SkipTMSS:
```
As shown above, the new init code starts by load 320 (20 << 4) into D1 as the millis increment value. If the code detects the console to be NTSC, it substracts 53 from that value yielding 267. Then the millis increment value is stored to RAM for Vint to use with the millis timer. Main code can now be writing with millis values and generate equivalent timing for either PAL or NTSC even though the frame rate is different.

###How much precision
Millis increments use the full 32 bit width of D7, with 4 bits being fractional this leaves 28 integer bits meaning we can generate delays up to 2^28 = RIDICULOUS amounts of time. If we use just D7 in word width for shorter delays, like animation values for instance, we have 12 integer bits = up to 4095 15/16 ms (4095.9375ms) of timing - probably long enough most animation intervals.
