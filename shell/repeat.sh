#!/bin/bash
# ---------- ST.BOILERPLATE: BEGIN [Tue Jul 29 09:46:22 EDT 2025] ---------- #
sthome=/home/connorshugg/toolbox/shuggtools
source ${sthome}/globals.sh
# ----------- ST.BOILERPLATE: END [Tue Jul 29 09:46:22 EDT 2025] ----------- #
# Repeat
# Tool that takes in text and simply repeats it a specified number of times.
# One copy of the text per line.
#
#   Connor Shugg

# Displays a help menu for this tool.
function __shuggtool_repeat_usage()
{
    echo "Repeat: prints the same text a specified number of times."
    echo ""
    echo "Usage: repeat [-n COUNT] -t TEXT"
    echo "Invocation arguments:"
    echo "------------------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -n           Specifies the number of lines to repeat the text on."
    echo " -t           Specifies the text to repeat."
    echo "------------------------------------------------------------------"
}

# Main function.
function __shuggtool_repeat()
{
    text=""
    count=-1

    # if no arguments were specified, show the help menu
    if [ $# -lt 1 ]; then
        __shuggtool_repeat_usage
        return 0
    fi

    # check for command-line arguments
    local OPTIND h n t
    while getopts "hn:t:" opt; do
        case ${opt} in
            h)
                __shuggtool_repeat_usage
                return 0
                ;;
            n)
                count=${OPTARG}
                ;;
            t)
                text="${OPTARG}"
                ;;
            *)
                __shuggtool_repeat_usage
                return 1
                ;;
        esac
    done

    # now, simply repeat the text the specified number of times
    while [ ${count} -ne 0 ]; do
        echo -e "${text}"
        count=$((count-1))
    done
}

__shuggtool_repeat "$@"

