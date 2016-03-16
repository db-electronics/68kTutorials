###Tutorial 03 - Vertical Interrupts

There are three interrupts in the Sega Genesis: vertical, horizontal, and external. This tutorial will deal with basics surrounding the vetical interrupt. I implemented a few system functions which I think will be useful to any future project including a millisecond timer and dynamic vector system. I also improved the build.sh script file from tutorial-02 to now accept a -d parameter to automatically call MESS in debug mode with the built binary - excellent!

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
##Vint Vector
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
These set the labels at which the code execution will vector to when the 68000 receives the appropriate interrupt level. Note that the VDP will only generate levels 2, 4 and 6 - everything else is an error from our point of view and the code will vector to exception (which currently halts everything). The labels for interrupt levels 2, 4 and 6 are defined in **sys/sysInterrupts.68k**.

##Vint Interrupt Routine
My Vint interrupt is very shot and simple. Let's go through it line by line.
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
* Line 4 is where it gets interesting. The **tst.l** opcode is used to whether or not a value is zero. Here I test a RAM variable called *vintvector*. This variable, *vintvector*, will contain the address of the whichever subroutine I decide should be called by Vint. If its value is zero, it means we have no vector and *beq.s .noVector* immediately out of the interrupt routine. HOWEVER, if the main code has set *vintvector* to the address of some routine then the code will reach: 
* Line 7 the *movem.l D0-D6/A0-A6. -(SP)* instruction which is the 68k way of saving the register context to the stack.
* Line 8 takes the address stored in *vinvector* and loads it into A0
* Line 9 jumps to the subroutine pointed to by *vintvector*
* Line 10 restores the register context from the stack once the code has returned from the *vinvector* subroutine. The nice thing here is that I only need to do the expensive push/pop stack operations if a jump to *vintvector* is required since nothing else touches the register context (except for D7 millis timer but my main code will always be aware of this).

##Main Code
Along with the new Vint routine, I wrote a short and simple main loop to interact with the vertical interrupt:
