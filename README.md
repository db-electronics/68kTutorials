# 68kTutorials
Tutorials to teach myself 68k assembly within the context of Sega Genesis hardware...

## Inspiration
Upon reading BigEvilCorporation blog posts on a similar topic I decided I would finally delve into 68k assembly. The first
tutorial, HelloWorld, is more or less exactly the same as from BigEvilCorp - the only difference is that I have modified a few labels to be compatible with the ASMX assembler. I decided to go with ASMX since it supports both 68k and Z80 and can
be built on Linux.

## Not For Beginners
I'm not writing these tutorials for beginners. I don't assume the reader is a complete noob with respect to assembly, electronics, programming, etc... If you're a beginner in any of those categories then these tutorials are probably not for you and you should search elsewhere for beginners' guides before continuing here. I'm an electronics engineer and my main motivation for writing these is first and foremost to further my own knowledge. Think of all these tutorials as 68k lab journal of sorts.

## Format
Tutorial-01 is just a compile test. From Tutorial-02 onwards I heavily modify the existing code, add my own code, and explore a few aspects of the Genesis in each tutorial in the hopes both fully understanding the underlying concepts and to properly communicate those concepts to whomever is reading this. The goal of these tutorials is not necessarily to teach anyone M68K assembly, but rather, to learn about the Sega Genesis hardware within the context of assembly.

## Getting Ready
The instructions below will help you setup and ASMX and MESS which are required to follow the tutorials. The instructions assume you are using Linux Ubuntu 14.04, I'm sure there's a ton of info available online if you're trying to install these tools on Windows.

### Build ASMX
ASMX is a wonderfully simple assemler which supports both the Motorola 68000 and Zilog Z80, both processors found in the Sega Genesis. It is a no brainer, in my opinion, to use this assembler to learn how to program for the Sega Genesis. Here's how I built and installed ASMX on Ubuntu 14.04.

- Download source code from here (2.0b5): http://xi6.com/projects/asmx/
- Open scr/MakeFile in a text editor and comment out the line "TARGET_ARCH = -arch ppc -arch i686"
- Make, and install the binary to /usr/local/bin

### Install MESS
MESS has great debugging features, install MESS (Ubuntu 14.04):

- sudo apt-get mess
- cd to ~/.mess
- create a mess.ini configuration file by running mess -cc
- edit the resulting mess.ini to your liking
- launch test roms: mess genesis -cart %pathtorom% -debug
