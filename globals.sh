# This file contains global definitions of variables/aliases/whatever needed by
# the various scripts
#
#   Connor Shugg

# ============================ Global Variables ============================= #
# Color escape sequences
C_NONE="\033[0m"
C_BLACK="\033[38;2;0;0;0m"          # "\033[0;30m"
C_WHITE="\033[38;2;255;255;255m"    # "\033[1;37m"
C_RED="\033[38;2;255;65;65m"        # "\033[0;31m"
C_GREEN="\033[38;2;34;177;76m"      # "\033[0;32m"
C_YELLOW="\033[38;2;217;192;29m"    # "\033[0;33m"
C_BLUE="\033[38;2;73;165;255m"      # "\033[0;34m"
C_PURPLE="\033[38;2;160;79;255m"    # "\033[0;35m"
C_CYAN="\033[38;2;101;215;255m"     # "\033[0;36m"
C_LTGRAY="\033[38;2;175;175;175m"   # "\033[0;37m"
C_DKGRAY="\033[38;2;130;130;130m"   # "\033[1;30m"
C_LTRED="\033[38;2;255;150;150m"    # "\033[1;31m"
C_LTGREEN="\033[38;2;142;235;172m"  # "\033[1;32m"
C_LTYELLOW="\033[38;2;255;252;79m"  # "\033[1;33m"
C_LTBLUE="\033[38;2;151;211;255m"   # "\033[1;34m"
C_LTPURPLE="\033[38;2;204;161;255m" # "\033[1;35m"
C_LTCYAN="\033[38;2;182;243;255m"   # "\033[1;36m"

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
    echo -e "${C_RED}Error: ${C_NONE}${msg}${C_NONE}" 1>&2
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
    tty_size_arr=(${tty_size})      # turn output into array:  [<rows>, <cols>]

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
    columns=${shuggtools_terminal_cols}

    # calculate how to center the text
    text_len=$(expr length "${text}")
    column_to_write_text=$(expr $(expr ${columns} - ${text_len}) / 2)

    # insert the correct number of spaces
    for (( sc=0; sc<${column_to_write_text}; sc++ ))
    do
        text=" ${text}"
    done

    # print the text
    echo -e "${text}"

}

# Helper function that takes in a single string argument and sets a global
# variable equal to the hashed value. Makes use of cksum.
shuggtools_hash_string_retval=0
function __shuggtool_hash_string()
{
    # first, attempt to find an executable to use to hash the string
    hasher=$(which cksum)
    if [ -z ${hasher} ]; then
        hasher=$(which sum)
    fi
    # if a suitable executable can't be found, default to 0 and return
    if [ -z ${hasher} ]; then
        __shuggtool_hash_string_retval=0
        return
    fi

    # otherwise, pass the string as input into the hashing program
    __shuggtool_hash_string_retval=$(echo "$1" | ${hasher} | cut -f 1 -d ' ')
}


