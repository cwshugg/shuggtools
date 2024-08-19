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

# Bash version
__shuggtool_bash_version_major=$(echo ${BASH_VERSION} | cut -d "." -f 1)
__shuggtool_bash_version_minor=$(echo ${BASH_VERSION} | cut -d "." -f 2)

# Information file
shuggtools_info_file=info.txt


# ============================ Global Functions ============================= #
# Takes in three values (red, green, blue) and returns a foreground color
# string.
function __shuggtool_color_rgb_fg()
{
    red="$1"
    green="$2"
    blue="$3"
    echo -en "\033[38;2;${red};${green};${blue}m"
}

# Takes in three values (red, green, blue) and returns a background color
# string.
function __shuggtool_color_rgb_bg()
{
    red="$1"
    green="$2"
    blue="$3"
    echo -en "\033[48;2;${red};${green};${blue}m"
}

# Takes in a string, hashes it, and echoes out a foreground or background color
# based on the hash.
function __shuggtool_color_hash_helper()
{
    str="$1"
    do_bg=$2

    # compute the string's hash
    __shuggtool_hash_string "${str}"
    str_hash=${__shuggtool_hash_string_retval}

    # find some way to turn the hash integer into three RGB integers
    red=$(((str_hash/3)%256))
    green=$(((str_hash/5)%256))
    blue=$(((str_hash/2)%256))

    # brighten up the colors, if needed
    if [ ${red} -lt 100 ]; then
        increment=$(((str_hash/4)%100))
        red=$((red+increment))
    fi
    if [ ${green} -lt 100 ]; then
        increment=$(((str_hash/6)%100))
        green=$((green+increment))
    fi
    if [ ${blue} -lt 100 ]; then
        increment=$(((str_hash/8)%100))
        blue=$((blue+increment))
    fi

    # choose foreground or background
    if [ ${do_bg} -ne 0 ]; then
        __shuggtool_color_rgb_bg ${red} ${green} ${blue}
    else
        __shuggtool_color_rgb_fg ${red} ${green} ${blue}
    fi
}

# Takes in a string, hashes it, and echoes out a foreground color.
function __shuggtool_color_hash_fg()
{
    __shuggtool_color_hash_helper "$1" 0
}

# Takes in a string, hashes it, and echoes out a background color.
function __shuggtool_color_hash_bg()
{
    __shuggtool_color_hash_helper "$1" 1
}

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
    echo -e "${C_RED}Error:${C_NONE} ${msg}${C_NONE}" 1>&2
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

# Awaits user input and echoes it back out.
function __shuggtool_read_input()
{
    read text
    echo "${text}"
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
        return ${__shuggtool_hash_string_retval}
    fi

    # otherwise, pass the string as input into the hashing program
    __shuggtool_hash_string_retval=$(echo "$1" | ${hasher} | cut -f 1 -d ' ')
    return ${__shuggtool_hash_string_retval}
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


# ---------------------------- Random Generation ----------------------------- #
# Generates and echoes random bytes of the specified length.
function __shuggtool_rand_bytes()
{
    len=8
    if [ $# -ge 1 ]; then
        len=$1
    fi

    # read from /dev/urandom
    val=$(dd if=/dev/urandom bs=1 count=${len} 2> /dev/null)
    echo -n ${val}
}

# Returns a random unsigned integer, given the number of bytes to use for
# generation.
function __shuggtool_rand_uint()
{
    bytes=8
    if [ $# -ge 1 ]; then
        bytes=$1
    fi

    val=$(__shuggtool_rand_bytes ${bytes} | od -t uL -A n | xargs)
    echo -n ${val}
}

## Returns a random 8-bit integer.
function __shuggtool_rand_uint8()
{
    __shuggtool_rand_uint 1
}

# Returns a random 16-bit integer.
function __shuggtool_rand_uint16()
{
    __shuggtool_rand_uint 2
}

# Returns a random 32-bit integer.
function __shuggtool_rand_uint32()
{
    __shuggtool_rand_uint 4
}

# Returns a random 64-bit integer.
function __shuggtool_rand_uint64()
{
    __shuggtool_rand_uint 8
}

# Returns a random number given a range. The lower range is inclusive and the
# upper range is exclusive.
function __shuggtool_rand_range()
{
    lower=0
    if [ $# -ge 1 ]; then
        lower=$1
    fi
    upper=0
    if [ $# -ge 2 ]; then
        upper=$2
    fi
    
    val=$(__shuggtool_rand_uint32)
    val=$(expr ${val} % $((upper - lower)))
    val=$(expr ${val} + ${lower})
    echo -n ${val}
}

# Returns a random hex string. The first argument, if specified, sets the
# number of bytes to generate. Because each byte is represented by two hex
# characters, the number of produced characters will be double the input
# argument.
function __shuggtool_rand_hex()
{
    # check for the first argument
    len=4;
    if [ $# -ge 1 ]; then
        len=$1
    fi

    # check for the second argument; uppercase or lowercase
    uppercase=0
    if [ $# -ge 2 ]; then
        if [ $2 -ne 0 ] || [[ "$2" == *"up"* ]] || [[ "$2" == *"UP"* ]]; then
            uppercase=1
        fi
    fi
    
    # run the hexdump command
    if [ ${uppercase} -ne 0 ]; then
        hexdump -n ${len} -v -e '"%0X"' < /dev/urandom 2> /dev/null
    else
        hexdump -n ${len} -v -e '"%0x"' < /dev/urandom 2> /dev/null
    fi
}

# Generates and returns a random english word. This utilizes the dictionary
# files built into most Linux systems.
function __shuggtool_rand_word()
{
    # look for a dictionary file on the system
    dictionary_paths=( \
        "/usr/share/dict/words" \
        "/etc/dictionaries-common/words" \
        "/usr/share/dict/american-english" \
    )
    dictionary_path=""
    for path in ${dictionary_paths[@]}; do
        if [ -f "${path}" ]; then
            dictionary_file="${path}"
            break
        fi
    done
    
    # if we didn't find a dictionary file, output an error
    if [ -z "${dictionary_file}" ] || [ ! -f "${dictionary_file}" ]; then
        __shuggtool_print_error "Failed to find a suitable dictionary file on the system."
        return 1
    fi

    # repeatedly select random words from the file until we find one that only
    # contains letters (we don't want punctuation)
    word="-"
    while true; do
        word="$(shuf -n 1 "${dictionary_file}")"
        if [[ "${word}" =~ ^[a-zA-Z]+$ ]]; then
            break
        fi
    done

    # echo the word out in all lowercase
    echo -n "${word,,}"
}


# -------------------------------- OS Signals -------------------------------- #
__shuggtool_os_signal_names=()
__shuggtool_os_signal_numbers=()

# Initialization function to parse all OS signals and associate each with a
# signal number.
function __shuggtool_os_signal_init()
{
    # empty out the arrays
    __shuggtool_os_signal_names=()
    __shuggtool_os_signal_numbers=()

    # invoke the built-in `kill` command to parse out all signal names
    for word in $(kill -l | xargs); do
        # only include the signal names (i.e. starts with "SIG")
        if [[ "${word}" != *"SIG"* ]]; then
            continue
        fi
        
        # get the signal's number, then add both to the arrays
        signum=$(kill -l "${word}")
        __shuggtool_os_signal_names+=("${word}")
        __shuggtool_os_signal_numbers+=(${signum})
    done
}

# Takes in a bash return code and echoes out the matching signal name, if
# applicable.
function __shuggtool_os_signal_retval()
{
    retval=$1

    # bash indicates a signal as a return value of 128 + X, where X is the
    # signal number. So, if the retval isn't greater than 128, don't continue
    if [ ${retval} -le 128 ]; then
        return 0
    fi
    signum=$((retval-128))

    # iterate through all signals to determine if the retval matches
    for (( i=0; i<${#__shuggtool_os_signal_names[@]}; i++ )); do
        name="${__shuggtool_os_signal_names[${i}]}"
        num=${__shuggtool_os_signal_numbers[${i}]}
        # if the number matches, echo the signal name and exit
        if [ ${num} -eq ${signum} ]; then
            echo -n "${name}"
            return 0
        fi
    done
}

