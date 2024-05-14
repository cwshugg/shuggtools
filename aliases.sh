# A shell script that sets up my preferred aliases.
#
#   Connor Shugg

# force bash to expand environment variables when using tab complete
shopt -s direxpand

# set editor to vim
export EDITOR="vim"

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

# coding/debugging aliases
alias valg="valgrind -v --leak-check=full --show-leak-kinds=all --track-origins=yes"
alias gdb="gdb -q" # quiet-mode GDB (don't print intro)

# other alises
alias dir="ls"
alias h="history"
alias bell="echo -en \"\a\""
alias g="git"

# tmux aliases
alias tmux-pane="tmux display -pt \"${TMUX_PANE:?}\" \"#{pane_index}\""


# ------------------------------ Task Tracking ------------------------------- #
# I am currently working on writing my own advanced task tracking tool, but in
# the meantime, I need something to work with. This is a simple solution.

function __todos_grep_for_tag()
{
    name="$1"
    result="$(grep "@\\<${name}\\>" -R --color=never 2> /dev/null)"
    grep_result=$?

    # if grep succeeded and we found output, we'll create a nicely-formatted
    # output string to print
    if [ ! -z "${result}" ]; then
        # iterate through the output, line-by-line
        echo "${result}" | while read line; do
            # split the output so we retrieve the file name and the grepped
            # line within the file
            fpath="$(echo "${line}" | cut -d ":" -f 1)"
            fline="$(echo "${line}" | cut -d ":" -f 2)"

            # generate a deterministic color to color-code the file path
            fpath_color="$(__shuggtool_color_hash_fg "${fpath}")"

            # echo the new line out
            echo -e "${fpath_color}${fpath}${C_NONE}: ${fline}"
        done
    fi

    return ${grep_result}
}

function __todos_show()
{
    tag="$1"
    description="$2"

    # search for the result. If none was found, return
    result="$(__todos_grep_for_tag "${tag}")"
    retval=$?
    if [ -z "${result}" ]; then
        return ${retval}
    fi

    # use my 'sep' script if it's found, to print a header. Otherwise, print a
    # message
    sep="$(which "sep")"
    if [ ! -z "${sep}" ]; then
        sep -t "${description}"
    else
        color="$(__shuggtool_color_rgb_fg 100 150 255)"
        echo -e "${color}•${C_NONE} Task Group: ${color}${description}${C_NONE}:"
    fi

    # echo the grep output and return the grep's return value
    echo "${result}"
    return ${retval}
}

function __todos_all()
{
    # show "eventually" tasks
    __todos_show "eventually" "EVENTUALLY"
    result=$?
    if [ ${result} -eq 0 ]; then
        echo ""
    fi
    
    # show tasks for this month
    __todos_show "month" "THIS MONTH"
    result=$?
    if [ ${result} -eq 0 ]; then
        echo ""
    fi
    
    # show tasks for this week
    __todos_show "week" "THIS WEEK"
    result=$?
    if [ ${result} -eq 0 ]; then
        echo ""
    fi
    
    # show tasks for tomorrow
    __todos_show "tomorrow" "TOMORROW"
    result=$?
    if [ ${result} -eq 0 ]; then
        echo ""
    fi
    
    # show tasks for today
    __todos_show "today" "TODAY"
    result=$?
    if [ ${result} -eq 0 ]; then
        echo ""
    fi
}

alias todos="__todos_all"
alias today="__todos_grep_for_tag today"
alias tomorrow="__todos_grep_for_tag tomorrow"
alias this-week="__todos_grep_for_tag week"
alias this-month="__todos_grep_for_tag month"
alias eventually="__todos_grep_for_tag eventually"

# ---------------------------- Directory Changes ----------------------------- #
# CDF: Change Directory Find
# Searches for a matching file/directory, given a string, and either changes to
# the directory or pushes it onto the directory stack (if a match is found).
function __shuggtool_alias_cdf_helper()
{
    name="$1"
    do_push=$2 # 0=change, 1=push
 
    # search for the name; if one isn't found, complain and return
    result="$(find $(pwd) -name "${name}" 2> /dev/null | head -n 1)"
    if [ -z "${result}" ]; then
        __shuggtool_print_error "Failed to find matching file or directory: ${C_GRAY}${name}${C_NONE}"
        return 1
    fi

    if [ -f "${result}" ]; then
        # if the result is a file, grab its directory (if it's a direcotyr,
        # we'll# use it as-is)
        result="$(dirname "${result}")"
    elif [ ! -d "${result}" ]; then
        # otherwise, if it's NOT a directory, we've got a problem
        __shuggtool_print_error "The matched result is neither file nor directory: ${C_GRAY}${result}${C_NONE}"
        return 1
    fi
    
    # finally, either change or push
    if [ ${do_push} -ne 0 ]; then
        pushd "${result}"
    else
        cd "${result}"
    fi
    return 0
}    

# cdf: Change Directory Find
function __shuggtool_alias_cdf()
{
    # make sure at least one argument was given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "Please provide the name of a file or directory to search for."
        return 1
    fi
    __shuggtool_alias_cdf_helper "$1" 0
    return 0
}

# pushdf: Push Directory Find
function __shuggtool_alias_pushdf()
{
    # make sure at least one argument was given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "Please provide the name of a file or directory to search for."
        return 1
    fi
    __shuggtool_alias_cdf_helper "$1" 1
    return 0
}

# directory chance aliases
alias cdf="__shuggtool_alias_cdf"
alias pushdf="__shuggtool_alias_pushdf"

