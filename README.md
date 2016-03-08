# 68kTutorials
Tutorials to teach myself 68k assembly...

Upon reading BigEvilCorporation blog posts on a similar topic I decided I would finally delve into 68k assembly. The first
tutorial, HelloWorld, is more or less exactly the same as from BigEvilCorp - the only difference is that I have modified a
a few labels to be compatible with the ASMX assembler. I decided to go with ASMX since it supports both 68k and Z80 and can
be built on Linux.

The simple instructions below will help you setup and ASMX and MESS which are required to follow the tutorials. The instructions assume you are using Ubuntu 14.04, I'm sure there's a ton of info available online if you're trying to install these tools on Windows.

## Build ASMX

ASMX is a wonderfully simple assemler which supports both the Motorola 68000 and Zilog Z80, both processors found in the Sega Genesis. It is a no brainer, in my opinion, to use this assembler to learn how to program for the Sega Genesis. Here's how I built and installed ASMX on Ubuntu 14.04.

- Download source code from here (2.0b5): http://xi6.com/projects/asmx/
- Open scr/MakeFile in a text editor and comment out the line "TARGET_ARCH = -arch ppc -arch i686"
- Make, and install the binary to /usr/local/bin

## Install MESS

MESS has great debugging features, install MESS (Ubuntu 14.04):

- sudo apt-get mess
- cd to ~/.mess
- create a mess.ini configuration file by running mess -cc
- edit the resulting mess.ini to your liking
- launch test roms: mess genesis -cart %pathtorom% -debug

