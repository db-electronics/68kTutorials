#!/bin/bash

if [ -d /out ]
then
	echo "cleaning out directory"
	rm -r out/*
else
	mkdir out	
fi

asmx -C 68000 -e -w -b 0 -l out/rom.lst -o out/rom.bin -- main.asm
