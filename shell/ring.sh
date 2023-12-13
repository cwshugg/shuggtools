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

# Writes a header that goes at the front of the line.
function __shuggtool_ring_print_header()
{
    flag_color="$(__shuggtool_color_rgb_fg "255" "255" "255")"
    if [ $# -gt 0 ]; then
        flag_color="$1"
    fi

    # write a bell symbol, surrounded by a gray color
    echo -en "$(__shuggtool_color_rgb_bg "68" "68" "68")"
    echo -en "${flag_color}"
    echo -en " ⚑ "
}

# Writes a footer that goes at the end of the line.
function __shuggtool_ring_print_footer()
{
    __shuggtool_ring_print_header "$@"
}

function __shuggtool_ring_print_frame()
{
    text="$1"

    # get the length of the terminal
    __shuggtool_terminal_size
    th=${shuggtools_terminal_rows}
    tw=${shuggtools_terminal_cols}

    # first, write a carriage return
    echo -en "\r"

    # choose a random color to use (keep it somewhat light)
    rc_r=$(((${RANDOM} % 156) + 100))
    rc_g=$(((${RANDOM} % 156) + 100))
    rc_b=$(((${RANDOM} % 156) + 100))
    fgc="$(__shuggtool_color_rgb_fg "${rc_r}" "${rc_g}" "${rc_b}")"

    # set the background color color
    bg_r=38
    bg_g=38
    bg_b=38
    bgc="$(__shuggtool_color_rgb_bg "${bg_r}" "${bg_g}" "${bg_b}")"
    
    # write the header
    __shuggtool_ring_print_header "${fgc}"

    # set the colors for the middle section
    echo -en "${bgc}${fgc}"

    # determine how much space on the line the text has, and cut if off if it's
    # too long (the entire print should only take up a single line)
    header_len=3
    footer_len=3
    text_len=${#text}
    text_padding_len=2
    allowed_len=$((tw - (header_len + footer_len + text_padding_len)))
    if [ ${text_len} -gt ${allowed_len} ]; then
        # add a suffix to the print so the user knows text was cut off
        suffix="[...]"
        suffix_len=${#suffix}
        suffix_fgc="$(__shuggtool_color_rgb_fg "255" "0" "0")"
        
        # echo out a substring of the text and the colored suffix
        echo -en " ${text:0:$((allowed_len - suffix_len))}"
        echo -en "${suffix_fgc}${suffix} "
    else
        echo -en " ${text} "
    fi

    # fill in the remaining space on the with empty characters
    empty_len=$((tw - (header_len + footer_len + text_len + text_padding_len)))
    padding=""
    for (( i=0; i<${empty_len}; i++ )); do
        padding="${padding} "
    done
    echo -en "${padding}"

    # write the footer
    __shuggtool_ring_print_footer "${fgc}"

    # finally write the bell character and cancel out previous colors
    echo -en "\033[0m\a"
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

    # repeatedly bell
    c_idx_last=-1
    while true; do
        if [ ${bell_quiet} -eq 0 ]; then
            __shuggtool_ring_print_frame "${bell_text}"
        else
            echo -en "\a"
        fi

        # sleep until the next one
        sleep ${bell_rate}
    done
}

# pass all args to main function
__shuggtool_ring "$@"

