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
    echo " -t TEXT          Specifies the text to display when ringing."
    echo " -q               Enables \"quiet mode\", which disables text printing."
    echo "------------------------------------------------------------------------"
}

# main function
function __shuggtool_ring()
{
    bell_rate=1
    bell_text="ringing..."
    bell_quiet=0
    
    # first, check for command-line arguments
    local OPTIND h c t
    while getopts "hr:t:q" opt; do
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
            t)
                bell_text="${OPTARG}"
                ;;
            q)
                bell_quiet=1
                ;;
            *)
                __shuggtool_ring_usage
                return 1
                ;;
        esac
    done

    # set up an array of colors to use
    bell_colors=("${C_WHITE}" "${C_RED}" "${C_GREEN}" "${C_YELLOW}" "${C_BLUE}"
                 "${C_PURPLE}" "${C_CYAN}" "${C_LTRED}" "${C_LTGREEN}"
                 "${C_LTYELLOW}" "${C_LTBLUE}" "${C_LTPURPLE}" "${C_LTCYAN}")
    bell_colors_len=${#bell_colors[@]}
    
    # repeatedly bell
    c_idx_last=-1
    while true; do
        if [ ${bell_quiet} -eq 0 ]; then
            # select a random color (make sure it's different than the last one)
            c_idx=$((${RANDOM} % bell_colors_len))
            if [ ${c_idx} -eq ${c_idx_last} ]; then
                c_idx=$(((c_idx + 1) % bell_colors_len))
            fi
            c_idx_last=${c_idx}
            c="${bell_colors[${c_idx}]}"
    
            # output the text and the bell
            echo -en "\r${c}${bell_text}${C_NONE}\a"
        else
            echo -en "\a"
        fi

        # sleep until the next one
        sleep ${bell_rate}
    done
}

# pass all args to main function
__shuggtool_ring "$@"

