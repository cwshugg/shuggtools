#!/bin/bash
# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# source globals file
globals_file=globals.sh
source $globals_file

# cscope adjustments (if it's installed)
cscope_exists="$(which cscope 2>&1)"
if [[ ${cscope_exists} != *"no cscope"* ]]; then
    export CSCOPE_EDITOR=$(which vim)
fi

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"

# other alises
alias dir="ls"

