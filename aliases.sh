#!/bin/bash
# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"

# other alises
alias dir="ls"


#colored prompt
PS1="[\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;31m\]\h\[\033[00m\]: \[\033[01;36m\]\W\[\033[00m\]] ";
# colorless prompt
#PS1="[\! \u@\h: \W] "
