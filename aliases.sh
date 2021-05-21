#!/bin/bash
# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"

# other alises
alias dir="ls"


# ------------------------------- bash prompt ------------------------------- #
ptoggle=0

# fancy prompt variables
bgc="48;2"          # prefix for background colors
fgc="38;2"          # prefix for foreground colors
pc1="210;129;7"     # dark yellow   (original: (235, 154,  32))
pc2="180;17;33"     # dark red      (original: (205,  42,  58))
pc3="0;30;128"      # dark blue     (original: ( 20,  55, 143))
pc4="255;174;52"    # light yellow
pc5="225;62;78"     # light red
pc6="40;75;163"     # light blue
pc_black="0;0;0"    # black
pc_white="255;255;255" # white
pc_none="0"         # none
p_suffix="" #"$(echo -e '\u2596')"
b_line="$(echo -e '\u2500')"
b_fork="$(echo -e '\u2533')"
b_corner="$(echo -e '\u2517')"

if [ $ptoggle -eq 0 ]; then
    # fancy prompt 1
    PS1="\[\033[${bgc};${pc3};${fgc};${pc_white}m\] \u \[\033[${bgc};${pc2};${fgc};${pc_white}m\] \h \[\033[${bgc};${pc1};${fgc};${pc_black}m\] \W \[\033[${pc_none}m\]\[\033[${fgc};${pc1}m\]${p_suffix}\[\033[${pc_none}m\] "
elif [ $ptoggle -eq 1 ]; then
    # fancy prompt 2
    PS1="\[\033[${bgc};${pc3};${fgc};${pc_white}m\] \u \[\033[${pc_none}m\]${b_line}${b_fork}${b_line}\[\033[${bgc};${pc2};${fgc};${pc_white}m\] \h \[\033[${bgc};${pc1};${fgc};${pc_black}m\] \w \[\033[${pc_none}m\]\[\033[${fgc};${pc1}m\]${p_suffix}\[\033[${pc_none}m\]\n          ${b_corner}${b_line} "
else
    # standard colored prompt
    PS1="[\[\033[${fgc};${pc6}m\]\u\[\033[${pc_none}m\]@\[\033[${fgc};${pc5}m\]\h\[\033[${pc_none}m\]: \[\033[${fgc};${pc4}m\]\W\[\033[${pc_none}m\]] "
    # colorless prompt
    #PS1="[\! \u@\h: \W] "
fi

# --------------------------------------------------------------------------- #

