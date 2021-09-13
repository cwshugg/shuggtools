#!/bin/bash
# A shell script that sets up my preferred bash prompt.
#
#   Connor Shugg

# source globals file
globals_file=globals.sh
source $globals_file

# prompt toggle - set to any values in the below if-statement to adjust what
# prompt is being displayed
ptoggle=0

# fancy prompt variables
bgc="48;2"          # prefix for background colors
fgc="38;2"          # prefix for foreground colors

# set up three arrays of colors choices, for the three prompt colors
#                        dark blue  dark purple dark green
declare -a pc1_choices=("0;30;128" "68;51;113" "22;113;13")
#                        dark red    magenta      dark orange
declare -a pc2_choices=("180;17;33" "145;31;160" "184;94;12")
#                        yellow      light blue
declare -a pc3_choices=("210;129;7" "152;213;231" "207;239;109")


pc_black="0;0;0"    # black
pc_white="255;255;255" # white
pc_none="0"         # none
b_line="$(echo -e '\u2501')"
b_fork="$(echo -e '\u2533')"
b_corner="$(echo -e '\u2517')"

# get a hash value of the username
username="$(whoami)"
__shuggtool_hash_string "${username}"
username_hash=$__shuggtool_hash_string_retval

# choose default values
prompt_color1="${pc1_choices[0]}"
prompt_color2="${pc2_choices[0]}"
prompt_color3="${pc3_choices[0]}"
# if the hash worked, we'll pick pseudo-random values
if [ $username_hash -ne 0 ]; then
    # compute three indexes from the hashed value
    index1=$(((username_hash / 23) % 3))
    index2=$(((username_hash / 125) % 3))
    index3=$(((username_hash / 4) % 3))
    prompt_color1=${pc1_choices[$index1]}
    prompt_color2=${pc2_choices[$index2]}
    prompt_color3=${pc3_choices[$index3]}
fi
# make the color formatter strings
prompt_format1="${bgc};${prompt_color1};${fgc};${pc_white}"
prompt_format2="${bgc};${prompt_color2};${fgc};${pc_white}"
prompt_format3="${bgc};${prompt_color3};${fgc};${pc_black}"


if [ $ptoggle -eq 0 ]; then
    # fancy prompt 1
    PS1="\[\033[${prompt_format1}m\] \u \[\033[${prompt_format2}m\] \h \[\033[${prompt_format3}m\] \W \[\033[${pc_none}m\] "
elif [ $ptoggle -eq 1 ]; then
    # fancy prompt 2
    # compute number of spaces needed for the second line
    space_count=${#username}
    space_count=$((space_count + 3))
    spaces="$(printf "%*s" ${space_count})"
    PS1="\[\033[${prompt_format1}m\] \u \[\033[${pc_none}m\]${b_line}${b_fork}${b_line}\[\033[${prompt_format2}m\] \h \[\033[${prompt_format3}m\] \w \[\033[${pc_none}m\]\[\033[${fgc};${prompt_color3}m\]\[\033[${pc_none}m\]\n${spaces}${b_corner}${b_line} "
else
    # standard colored prompt
    PS1="[\[\033[${fgc};${prompt_color1}m\]\u\[\033[${pc_none}m\]@\[\033[${fgc};${prompt_color2}m\]\h\[\033[${pc_none}m\]: \[\033[${fgc};${prompt_color3}m\]\W\[\033[${pc_none}m\]] "
    # colorless prompt
    #PS1="[\! \u@\h: \W] "
fi

