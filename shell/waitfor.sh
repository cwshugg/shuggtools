#!/bin/bash
# ---------- ST.BOILERPLATE: BEGIN [Tue Jul 29 09:46:24 EDT 2025] ---------- #
sthome=/home/connorshugg/toolbox/shuggtools
source ${sthome}/globals.sh
# ----------- ST.BOILERPLATE: END [Tue Jul 29 09:46:24 EDT 2025] ----------- #
# Wait For
# A small utility that, given a PID, waits for the process to terminate, while
# periodically printing messages and sleeping. Each time it wakes, it checks if
# the process is still alive.
#
#   Connor Shugg

# Helper function that's used to print a status message.
function __shuggtool_waitfor_print()
{
    msg="$1"
    
    # build components of a date string
    date="$(date +"%Y-%m-%d")"
    time="$(date +"%H:%M:%S %P")"

    # write full message
    echo -e "${C_LTGRAY}[${C_BLUE}${date} ${C_LTBLUE}${time}${C_LTGRAY}]${C_NONE} ${msg}"
}

# Main function
function __shuggtool_waitfor()
{
    pid="0"
    rate=5

    # check a few possible command-line arguments (set each argument as local
    # so problems don't arise with multiple runs)
    local OPTIND h c t
    while getopts "hp:r:" opt; do
        case $opt in
            h)
                __shuggtool_waitfor_usage
                return
                ;;
            p)
                pid="${OPTARG}"
                ;;
            r)
                rate=${OPTARG}
                ;;
            *)
                __shuggtool_waitfor_usage
                return
                ;;
        esac
    done

    # make sure a PID was specified
    if [ ${pid} -eq 0 ]; then
        __shuggtool_print_error "You must specify a PID via -p."
        return 1
    fi

    # iterate until the process pseudo-directory is gone
    total_time=0
    while [ -d /proc/${pid} ]; do
        # write a brief message to the terminal
        if [ ${total_time} -gt 1 ]; then
            __shuggtool_waitfor_print "Waiting for PID ${pid}. ${C_DKGRAY}${total_time} seconds have passed.${C_NONE}"
        else
            __shuggtool_waitfor_print "Waiting for PID ${pid}."
        fi

        # sleep before looping again
        sleep ${rate}
        total_time=$((total_time+rate))
    done

    # if we waited for no time at all, the process must not exist
    if [ ${total_time} -eq 0 ]; then
        __shuggtool_print_error "A process with PID ${pid} does not exist."
        return 1
    fi
    
    __shuggtool_waitfor_print "Waiting complete after ${total_time} seconds."
    return 0
}

# The 'usage' function prints out the help menu
function __shuggtool_waitfor_usage()
{
    echo "Waitfor: Waits for a given process to exit."
    echo ""
    echo "Invocation arguments:"
    echo "------------------------------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -p <pid>     Sets the PID to wait for."
    echo " -r <seconds> Sets the refresh rate in seconds (how often the PID is checked)."
    echo "------------------------------------------------------------------------------"
}

# call main function and pass in all arguments
__shuggtool_waitfor "$@"

