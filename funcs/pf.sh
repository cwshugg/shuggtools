# Ping File (PF)
# This is a simple utility that manages a special file that is emptied each time
# the shell prompt enters a new line.
#
#   Connor Shugg

# Function to show pingfile contents as a dialog box.
function __shuggtool_pf_show_dialog()
{
    # local the dialog command and invoke it to display a simple message
    dlg=$(which dialog)
    ${dlg} --title "You have new pingfile content" --clear \
           --msgbox "$(cat ${ST_PINGFILE_SRC})" 0 0
}

# Function to show a simple alert for pingfile contents.
function __shuggtool_pf_show_simple()
{
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
    echo -e "\n${C_YELLOW}${banner}\n${C_CYAN}${line}${C_NONE}"
    cat ${ST_PINGFILE_SRC}
    echo -e "${C_CYAN}${line}${C_NONE}\n"
}

# Empties out the contents of the pingfile.
function __shuggtool_pf_empty_file()
{
    cat /dev/null > ${ST_PINGFILE_SRC}
}

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

    # if arguments were given, we'll take them and dump them into the file as
    # separate lines, then quit
    if [ $# -ge 1 ]; then
        for arg in "$@"; do
            echo "${arg}" >> ${ST_PINGFILE_SRC}
        done
    fi

    # otherwise, examine the file contents. If it's empty, do nothing
    if [ ! -s ${ST_PINGFILE_SRC} ]; then
        return
    fi

    # we'll either use 'dialog' or a simple print-out to alert the user,
    # depending on what's installed
    if [ ! -z "$(which dialog)" ]; then
        __shuggtool_pf_show_dialog
    else
        __shuggtool_pf_show_simple
    fi

    # empty out the pingfile after the alert has been shown
    __shuggtool_pf_empty_file
}

# pass all args to main function
__shuggtool_pf "$@"

