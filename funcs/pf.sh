# Ping File (PF)
# This is a simple utility that manages a special file that is emptied each time
# the shell prompt enters a new line.
#
#   Connor Shugg

# Main function
function __shuggtool_pf()
{
    # take a look at the special environment variable that defines the path to
    # the ping file
    if [ -z "${ST_PINGFILE_SRC}" ]; then
        # if none is set, we'll come up with a default
        export ST_PINGFILE_SRC="${HOME}/.pingfile"
    fi

    # if the pingfile doesn't exist, create it
    if [ ! -f ${ST_PINGFILE_SRC} ]; then
        touch ${ST_PINGFILE_SRC}
    fi

    # otherwise, examine the file contents. If it's empty, do nothing
    if [ ! -s ${ST_PINGFILE_SRC} ]; then
        return
    fi

    # build a small line string for pretty formatting
    banner="You have new pingfile content:"
    line_char="\u2500"
    line=""
    count=0
    while [ ${count} -lt ${#banner} ]; do
        line="${line}${line_char}"
        count=$((count+1))
    done

    # if it's NOT empty, we'll print a small header, dump the contents, then
    # empty out the file
    echo -e "\n${C_RED}${banner}\n${C_CYAN}${line}${C_NONE}"
    cat ${ST_PINGFILE_SRC}
    echo -e "${C_CYAN}${line}${C_NONE}\n"
    cat /dev/null > ${ST_PINGFILE_SRC}
}

# pass all args to main function
__shuggtool_pf "$@"

