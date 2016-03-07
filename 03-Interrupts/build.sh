#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

if test -d out
then
	echo "cleaning out directory"
	rm -r out/*
else
	mkdir out	
fi

asmx -C 68000 -e -w -b 0 -l out/rom.lst -o out/rom.bin -- main.asm

while getopts ":d" opt; do
    case "$opt" in
    d)
        echo "debug selected - starting mess" >&2
		mess genesis -cart out/rom.bin -debug
        ;;
	\?)
		echo "Invalid Option: -$OPTARG" >&2
		;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.
