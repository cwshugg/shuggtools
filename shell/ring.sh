# Ring
# Repeatedly sends the bell character to the terminal, to fire a visual or
# audible bell for the user to see/hear.
#
#   Connor Shugg

# help menu
function __shuggtool_ring_usage()
{
    echo "Ring: Repeatedly sends the bell character to the terminal."
    echo ""
    echo "Usage: ring [-r RATE_SECONDS]"
    echo "Invocation arguments:"
    echo "------------------------------------------------------------------------"
    echo " -h               Shows this help menu"
    echo " -r RATE_SECONDS  Specifies the number of seconds to wait between bells."
    echo "------------------------------------------------------------------------"
}

# main function
function __shuggtool_ring()
{
    bell_rate=1
    
    # first, check for command-line arguments
    local OPTIND h c t
    while getopts "hr:" opt; do
        case ${opt} in
            h)
                __shuggtool_ring_usage
                return 0
                ;;
            r)
                bell_rate=${OPTARG}
                # check for the minimum
                if [ ${bell_rate} -lt 0 ]; then
                    __shuggtool_print_error "-r must be an integer >= 0"
                    return 1
                fi
                ;;
            *)
                __shuggtool_ring_usage
                return 1
                ;;
        esac
    done
    
    # repeatedly bell
    while true; do
        echo -en "\a"
        sleep ${bell_rate}
    done
}

# pass all args to main function
__shuggtool_ring "$@"

