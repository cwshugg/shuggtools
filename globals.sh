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

# Helper function used to prompt the user for a yes-no answer.
# Returns 1 for yes and 0 for no.
function __shuggtool_prompt_yesno()
{
    msg="$1"
    yes=0

    # iterate until a proper answer is given
    while true; do
        echo -en "${msg} ${C_LTGRAY}(${C_GREEN}y${C_LTGRAY}/${C_RED}n${C_LTGRAY})${C_NONE}"
        read -p " " answer
        
        # if the response is blank, just re-loop
        if [ -z "${answer}" ]; then
            continue
        fi

        # parse the response
        case ${answer} in
            [yY])
                yes=1
                break
                ;;
            [nN])
                yes=0
                break
                ;;
            *)
                echo -e "Please enter ${C_GREEN}y${C_NONE} or ${C_RED}n${C_NONE}."
                ;;
        esac
    done
    return ${yes}
}

# Helper function that prompts the user to choose from a number of string
# options, stored in the below global variable.
# To use this, first set the below global variable to hold all the possible
# options, then pass in the following arguments:
#   $1      The prompt message to display
#   $2      0 or 1, specifying if user is allowed to type in something else
#           entirely as an "other" option
__shuggtool_prompt_choices=("you" "must" "set" "this" "global" "array" "first")
__shuggtool_prompt_choice_retval=""
function __shuggtool_prompt_choice()
{
    msg="$1"
    allow_other=$2

    # zero-out the return value
    __shuggtool_prompt_choice_retval=""
    
    # count the number of options, then output the prompt message
    ccount="${#__shuggtool_prompt_choices[@]}"
    if [ ${ccount} -le 0 ]; then
        __shuggtool_print_error "zero options were specified."
        return
    fi
    echo -en "${msg} (enter ${C_LTBLUE}1-${ccount}${C_NONE}"
    if [ ${allow_other} -ne 0 ]; then
        echo -en ", or something else entirely"
    fi
    echo -e ")"

    # echo out all the possible choices to the user
    for (( i=0; i<${ccount}; i++ )); do
        choice="${__shuggtool_prompt_choices[${i}]}"
        prefix="${STAB_TREE2}"
        if [ ${i} -eq $((ccount-1)) ]; then
            prefix="${STAB_TREE1}"
        fi
        echo -e "${C_DKGRAY}${prefix}${C_LTBLUE}$((i+1)).${C_NONE} ${choice}"
    done
    
    # read the user's answer until a proper one is given
    while true; do
        read -p "" answer
        # if the answer is blank, re-loop
        if [ -z "${answer}" ]; then
            continue
        fi
        
        # if the answer was a number, we'll see if it's in the correct range
        if [[ "${answer}" =~ ^[0-9]+$ ]]; then
            # if a number was given, check the range
            if [ ${answer} -le 0 ] || [ ${answer} -gt ${ccount} ]; then
                echo -e "Your choice must be between ${C_LTBLUE}1-${ccount}${C_NONE} (inclusive)."
                continue
            fi

            # otherwise, set the return value global and return
            __shuggtool_prompt_choice_retval="${__shuggtool_prompt_choices[$((answer-1))]}"
            return
        fi 

        # otherwise, if 'other' isn't allowed, forbid it
        if [ ${allow_other} -eq 0 ]; then
            echo -e "You must enter a choice between ${C_LTBLUE}1-${ccount}${C_NONE} (inclusive)."
            continue
        fi
        # set the return value global and return
        __shuggtool_prompt_choice_retval="${answer}"
        return
    done
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

# Uses the 'ip' linux utility to parse and echo out the machine's current IP
# address.
function __shuggtool_get_ip_address()
{
    # the 'ip route' command produces output formatted like so:
    #   default via 192.168.0.1 dev eth0
    #   192.168.0.113/20 dev eth0 proto kernel scope link src 192.168.0.113
    out="$(ip route | tail -n 1 | cut -d "/" -f 1)"
    echo "${out}"
}

