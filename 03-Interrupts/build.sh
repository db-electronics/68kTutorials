#!/bin/bash
# ************************************
# Title
# ************************************
#
#    Title:          build.sh
#    Author:         René Richard
#    Description:
#
# LICENSE
# 
#    This file is part of 68kTutorials.
#    68kTutorials is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    Foobar is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with 68kTutorials.  If not, see <http://www.gnu.org/licenses/>.
#
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# clean the /out directory if it already exists
if test -d out
then
	echo "cleaning out directory"
	rm -r out/*
else
	mkdir out	
fi

# assemble main.asm 
asmx -C 68000 -e -w -b 0 -l out/rom.lst -o out/rom.bin -- main.asm

# check for options
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

# Shift off the options and optional --.
shift "$((OPTIND-1))"
