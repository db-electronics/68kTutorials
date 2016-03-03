# 68kTutorials
Tutorials to teach myself 68k assembly...

Upon reading BigEvilCorporation blog posts on a similar topic I decided I would finally delve into 68k assembly. The first
tutorial, HelloWorld, is more or less exactly the same as from BigEvilCorp - the only difference is that I have modified a
a few labels to be compatible with the ASMX assembler. I decided to go with ASMX since it supports both 68k and Z80 and can
be built on Linux.

To build ASMX

-Download source code from here (2.0b5):
http://xi6.com/projects/asmx/

-Open scr/MakeFile in a text editor and comment out the line "TARGET_ARCH = -arch ppc -arch i686"

-Make, and install the binary to /usr/local/bin


