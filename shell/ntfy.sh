#!/bin/bash
# ---------- ST.BOILERPLATE: BEGIN [Tue Jul 29 09:46:22 EDT 2025] ---------- #
sthome=/home/connorshugg/toolbox/shuggtools
source ${sthome}/globals.sh
# ----------- ST.BOILERPLATE: END [Tue Jul 29 09:46:22 EDT 2025] ----------- #
# Ntfy
# Utility script for easily interacting with ntfy.sh (https://ntfy.sh), a slick
# push notification utility.
#
#   Connor Shugg

# Help menu
function __shuggtool_ntfy_usage()
{
    echo "Ntfy: Send a push notification to https://ntfy.sh."
    echo ""
    echo "Usage: ntfy [options]"
    echo "Invocation arguments:"
    echo "-------------------------------------------------------------------------"
    echo " -h               Shows this help menu"
    echo " -v               Enables verbose prints."
    echo " -t TOPIC_NAME    Specifies the topic name to submit the notification to."
    echo " -s SERVER_URL    Specifies the URL of the ntfy server to contact."
    echo " -T TITLE         Specifies the title of the notification."
    echo " -M MESSAGE       Specifies the message to place in the notification."
    echo "-------------------------------------------------------------------------"
}

# Main function
function __shuggtool_ntfy()
{
    verbose=0
    topic=""
    title=""
    message=""
    server="https://ntfy.sh"
    
    # first, check for command-line arguments
    local OPTIND h c t
    while getopts "hvs:t:T:M:" opt; do
        case ${opt} in
            h)
                __shuggtool_ntfy_usage
                return 0
                ;;
            v)
                verbose=1
                ;;
            s)
                server="${OPTARG}"
                ;;
            t)
                topic="${OPTARG}"
                ;;
            T)
                title="${OPTARG}"
                ;;
            M)
                message="${OPTARG}"
                ;;
            *)
                __shuggtool_ntfy_usage
                return 1
                ;;
        esac
    done

    if [ ${verbose} -ne 0 ]; then
        echo -e "${C_LTCYAN}Server:${C_NONE}  ${C_LTGRAY}${server}${C_NONE}"
        echo -e "${C_LTCYAN}Topic:${C_NONE}   ${C_LTGRAY}${topic}${C_NONE}"
        echo -e "${C_LTCYAN}Title:${C_NONE}   ${C_LTGRAY}${title}${C_NONE}"
        echo -e "${C_LTCYAN}Message:${C_NONE} ${C_LTGRAY}${message}${C_NONE}"
    fi

    # make sure both a topic and a message was specified
    if [ -z "${topic}" ] || [ -z "${message}" ]; then
        __shuggtool_print_error "You must specify both a topic (-t) and a message (-m)."
        return 1
    fi

    # create the URL
    url="${server}/${topic}"
    if [ ${verbose} -ne 0 ]; then
        echo -e "${C_LTCYAN}URL:${C_NONE}     ${C_LTGRAY}${url}${C_NONE}"
    fi

    # combine all possible curl arguments
    args=""
    args="${args} --data \"${message}\""
    if [ ! -z "${title}" ]; then
        args="${args} --header \"Title: ${title}\""
    fi
    if [ ${verbose} -ne 0 ]; then
        args="${args} -v"
    fi

    # add the server+topic URL and form the full command
    args="${args} \"${server}/${topic}\""
    cmd="curl ${args}"

    # send a curl request to the server
    if [ ${verbose} -ne 0 ]; then
        echo -e "${C_DKGRAY}"
    fi
    eval "${cmd}"
    if [ ${verbose} -ne 0 ]; then
        echo -e "${C_NONE}"
    fi
}

# pass all args to main function
__shuggtool_ntfy "$@"

