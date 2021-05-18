#!/bin/bash
# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"

# other alises
alias dir="ls"

# fancy colored prompt
bgc="48;2"          # prefix for background colors
fgc="38;2"          # prefix for foreground colors
pc1="210;129;7"     # yellow    (235, 154,  32)
pc2="180;17;33"     # red       (205,  42,  58)
pc3="0;30;128"      # blue      ( 20,  55, 143)
pc_black="0;0;0"    # black
pc_white="255;255;255" # white
pc_none="0"         # none
PS1="\[\033[${bgc};${pc3};${fgc};${pc_white}m\] \u \[\033[${bgc};${pc2};${fgc};${pc_black}m\] \h \[\033[${bgc};${pc1};${fgc};${pc_black}m\] \W \[\033[${pc_none}m\] "

# standard colored prompt
#PS1="[\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;31m\]\h\[\033[00m\]: \[\033[01;36m\]\W\[\033[00m\]] ";
# colorless prompt
#PS1="[\! \u@\h: \W] "
