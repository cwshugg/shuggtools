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
    alias cat="${bat_binary} --style=plain --paging=never"
    alias pcat="${bat_binary} --style=plain"
fi

# aliasing ttydo, my command-line task tracker
ttydo_binary="$(which ttydo 2> /dev/null)"
if [ ! -z "${ttydo_binary}" ]; then
    alias td="${ttydo_binary}"
    alias ctd="clear; ${ttydo_binary}"
fi

# coding/debugging aliases
alias valgfull="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"
alias gdb="gdb -q" # quiet-mode GDB (don't print intro)

# other alises
alias dir="ls"
alias h="history"
alias bell="echo -e \"\a\""

# CDF: Change Directory Find
# Searches for a matching file/directory, given a string, and cd's to that
# location if found.
function __shuggtool_alias_cdf()
{
    name="$1"

    # search for the name; if one isn't found, complain and return
    result="$(find $(pwd) -name "${name}" 2> /dev/null | head -n 1)"
    if [ -z "${result}" ]; then
        __shuggtool_print_error "Failed to find matching file or directory: ${C_GRAY}${name}${C_NONE}"
        return 1
    fi

    # if the result is a file, cd to its directory
    if [ -f "${result}" ]; then
        cd "$(dirname "${result}")"
    # if the result is a directory, cd to it
    elif [ -d "${result}" ]; then
        cd "${result}"
    else
        __shuggtool_print_error "The matched result is neither file nor directory: ${C_GRAY}${result}${C_NONE}"
        return 1
    fi
}    
alias cdf="__shuggtool_alias_cdf"

