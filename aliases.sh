# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# force bash to expand environment variables when using tab complete
shopt -s direxpand

# cscope adjustments (if it's installed)
cscope_exists="$(which cscope 2>&1)"
if [[ ${cscope_exists} != *"no cscope"* ]]; then
    export CSCOPE_EDITOR=$(which vim)
fi

# change the git core editor to vim
git="$(which git 2>&1)"
if [ ! -z "${git}" ]; then
    ${git} config --global core.editor "'$(which vim)'"
fi

# alias 'bat' or 'batcat' to 'cat' (syntax-highlighting!)
bat_binary="$(which batcat 2> /dev/null)"
if [ -z "${bat_binary}" ]; then
    bat_binary="$(which bat 2> /dev/null)"
fi
if [ ! -z "${bat_binary}" ]; then
    alias cat="${bat_binary} --paging=never"
    alias pcat="${bat_binary}"
fi

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"
alias gdb="gdb -q" # quiet-mode GDB (don't print intro)

# other alises
alias dir="ls"
alias h="history"
alias bell="echo -e \"\a\""

