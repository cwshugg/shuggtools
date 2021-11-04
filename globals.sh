# This file contains global definitions of variables/aliases/whatever needed by
# the various scripts
#
#   Connor Shugg

# ============================ Global Variables ============================= #
# Color escape sequences
c_none="\033[0m"
c_black="\033[0;30m"
c_red="\033[0;31m"
c_green="\033[0;32m"
c_brown="\033[0;33m"
c_blue="\033[0;34m"
c_purple="\033[0;35m"
c_cyan="\033[0;36m"
c_ltgray="\033[0;37m"
c_dkgray="\033[1;30m"
c_ltred="\033[1;31m"
c_ltgreen="\033[1;32m"
c_yellow="\033[1;33m"
c_ltblue="\033[1;34m"
c_ltpurple="\033[1;35m"
c_ltcyan="\033[1;36m"
c_white="\033[1;37m"

# Tree-like space-tabs
STAB="    "
STAB_TREE1=" \u2514\u2500 "
STAB_TREE2=" \u251c\u2500 "
STAB_TREE3=" \u2503  "

# Information file
shuggtools_info_file=info.txt

# ============================ Global Functions ============================= #
# A small helper function that takes in text as a parameter and prints it out
# as an error
function __shuggtool_print_error()
{
    # make sure text was actually given
    if [ $# -lt 1 ]; then
        msg="error-printer must be invoked with one argument."
    else
        msg=$1
    fi

    # print the error (to stderr)
    echo -e "${c_red}Shuggtool error: ${c_none}$msg${c_none}" 1>&2
}

# Helper function that sets two global variables equal to the number of rows
# and number of columns (in characters) that make up the current terminal
shuggtools_terminal_rows=0
shuggtools_terminal_cols=0
function __shuggtool_terminal_size()
{
    # 'stty size' tells the number of columns in the current terminal window.
    # We can tell it to look at our current terminal by running 'tty' to get
    # which /dev/pts/* our terminal belongs to
    tty_size=$(stty size < $(tty))  # output looks like:       "<rows> <cols>"
    tty_size_arr=($tty_size)        # turn output into array:  [<rows>, <cols>]

    # get the rows and columns
    shuggtools_terminal_rows=${tty_size_arr[0]}
    shuggtools_terminal_cols=${tty_size_arr[1]}
}

# Helper function that takes in text and prints it centered to the current
# dimensions of the terminal. Parameters:
#   $1      The text to print
function __shuggtool_print_text_centered()
{
    # make sure at least one argument was provided
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "to print centered text, you must invoke with one argument."
        return
    fi
    text=$1
    
    # get the width of the terminal
    __shuggtool_terminal_size
    columns=$shuggtools_terminal_cols

    # calculate how to center the text
    text_len=$(expr length "$text")
    column_to_write_text=$(expr $(expr $columns - $text_len) / 2)

    # insert the correct number of spaces
    for (( sc=0; sc<$column_to_write_text; sc++ ))
    do
        text=" $text"
    done

    # print the text
    echo -e "$text"

}

# Helper function that's invoked by setup.sh to create an information file with
# various version information for shuggtools. Parameters:
#   $1      The full path to the information file
function __shuggtool_write_info_file()
{
    # make sure an argument was given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "info file could not be set up: the full path was not specified."
        return
    fi
    info_file=$1

    # dump git version information into a text file (for the 'shuggtools' script)
    shuggtools_git_remote_url="$(git config --get remote.origin.url)"
    shuggtools_git_commit_hash="$(git rev-parse --short HEAD)"
    echo "Remote URL:    $shuggtools_git_remote_url"    > $info_file
    echo "Commit Hash:   $shuggtools_git_commit_hash"   >> $info_file
}

# Helper function that takes in a single string argument and sets a global
# variable equal to the hashed value. Makes use of cksum.
shuggtools_hash_string_retval=0
function __shuggtool_hash_string()
{
    # first, attempt to find an executable to use to hash the string
    hasher=$(which cksum)
    if [ -z $hasher ]; then
        hasher=$(which sum)
    fi
    # if a suitable executable can't be found, default to 0 and return
    if [ -z $hasher ]; then
        __shuggtool_hash_string_retval=0
        return
    fi

    # otherwise, pass the string as input into the hashing program
    __shuggtool_hash_string_retval=$(echo "$1" | $hasher | cut -f 1 -d ' ')
}


