#!/bin/bash
# ---------- ST.BOILERPLATE: BEGIN [Tue Jul 29 09:46:23 EDT 2025] ---------- #
sthome=/home/connorshugg/toolbox/shuggtools
source ${sthome}/globals.sh
# ----------- ST.BOILERPLATE: END [Tue Jul 29 09:46:23 EDT 2025] ----------- #
# Ring
# Repeatedly sends the bell character to the terminal, to fire a visual or
# audible bell for the user to see/hear.
#
#   Connor Shugg

# Globals
__shuggtool_ring_file_home="${HOME}"

# Help menu
function __shuggtool_ring_usage()
{
    echo "Ring: Repeatedly sends the bell character to the terminal."
    echo ""
    echo "Usage: ring [-r RATE_SECONDS]"
    echo "Invocation arguments:"
    echo "-------------------------------------------------------------------------"
    echo " -h               Shows this help menu"
    echo " -r RATE_SECONDS  Specifies the number of seconds to wait between bells."
    echo " -t TEXT          Specifies the text to display when ringing."
    echo " -q               Enables \"quiet mode\", which disables text printing."
    echo " -d               Dumps out a summary of all currently-ringing terminals."
    echo "-------------------------------------------------------------------------"
}

# Writes information into a "ring file", which is used to provide information
# to the user if `ring` is executed in check mode.
# "Check mode" will go and find all the existing ring files and print out
# information about the ringing terminal. Information such as:
#   - The machine the ringing is occurring on
#   - The tmux session (and other info) the ringing is occurring on
#   - The text that is being displayed
#   - The last time the ringing terminal rang.
function __shuggtool_ring_file_write()
{
    # retrieve information about the current terminal instance
    text="$1"
    pid="$$"
    
    # generate a unique file name and form the full file path
    ring_hash="$(echo "${pid}${text}" | cksum | cut -d " " -f 1)"
    rf="${__shuggtool_ring_file_home}/.shuggtool_ring_${ring_hash}"

    # write into the file
    echo -n ""                      > ${rf}
    echo "machine:$(hostname)"      >> ${rf}
    echo "pid:${pid}"               >> ${rf}
    echo "text:${text}"             >> ${rf}

    # write tmux info into the file, if applicable
    if [ ! -z "${TMUX}" ]; then
        echo "tmux_session:$(tmux display-message -p "#{session_name}")"    >> ${rf}
        echo "tmux_window:$(tmux display-message -p "#{window_index}")"     >> ${rf}
        echo "tmux_pane:$(tmux display-message -p "#{pane_index}")"         >> ${rf}
    fi
}

# Takes in a path to a ring file and dumps out its information.
function __shuggtool_ring_file_dump()
{
    rf="$1"

    machine="?"
    pid="?"
    text="?"
    date="$(date -r "${rf}" "+%s")"
    tmux_session="?"
    tmux_window="?"
    tmux_pane="?"

    cdate="$(date "+%s")"
    date_diff=$((cdate-date))

    # read the file, line by line
    while read -r line; do
        # extract the field and value pairs
        field="$(echo "${line}" | cut -d ":" -f 1)"
        value="$(echo "${line}" | cut -d ":" -f 2-)"

        # match up field names to variable to save
        if [[ "${field}" == "machine" ]]; then
            machine="${value}"
        elif [[ "${field}" == "pid" ]]; then
            pid="${value}"
        elif [[ "${field}" == "text" ]]; then
            text="${value}"
        elif [[ "${field}" == "tmux_session" ]]; then
            tmux_session="${value}"
        elif [[ "${field}" == "tmux_window" ]]; then
            tmux_window="${value}"
        elif [[ "${field}" == "tmux_pane" ]]; then
            tmux_pane="${value}"
        fi
    done < "${rf}"

    # print out all retrieved fields
    echo -e "${C_WHITE}$(basename ${rf})${C_NONE}"
    echo -e "${STAB_TREE2}${C_DKGRAY}Message:${C_NONE}      ${C_LTBLUE}${text}${C_NONE}"
    echo -e "${STAB_TREE2}${C_DKGRAY}Machine:${C_NONE}      ${machine}"
    echo -e "${STAB_TREE2}${C_DKGRAY}PID:${C_NONE}          ${pid}"

    # print out the tmux fields
    if [ ! -z "${tmux_session}" ]; then
        echo -e "${STAB_TREE2}${C_DKGRAY}Tmux Info:${C_NONE}   " \
                "session ${C_LTGREEN}${tmux_session}${C_NONE}," \
                "window ${C_LTGREEN}${tmux_window}${C_NONE}," \
                "pane ${C_LTGREEN}${tmux_pane}${C_NONE}"
    fi

    # print out the latest ring time
    date_diff_unit="s"
    date_diff_color="${C_GREEN}"
    if [ ${date_diff} -ge 3600 ]; then
        date_diff_unit="h"
        date_diff_color="${C_NONE}"
        date_diff=$((date_diff/3600))
    elif [ ${date_diff} -ge 60 ]; then
        date_diff_unit="m"
        date_diff_color="${C_NONE}"
        date_diff=$((date_diff/60))
    fi
    date_diff_str="${date_diff}${date_diff_unit} ago"
    echo -e "${STAB_TREE1}${C_DKGRAY}Last Rung:${C_NONE}   " \
            "$(date -d "@${date}" "+%Y-%m-%d %I:%M:%S %p")" \
            "(${date_diff_color}${date_diff_str}${C_NONE})"
}

# Goes and deletes all the existing ring files.
function __shuggtool_ring_file_prune()
{
    rm -f ${__shuggtool_ring_file_home}/.shuggtool_ring_*
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
    do_dump=0
    
    # first, check for command-line arguments
    local OPTIND h c t
    while getopts "hr:t:qd" opt; do
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
            d)
                do_dump=1
                ;;
            *)
                __shuggtool_ring_usage
                return 1
                ;;
        esac
    done

    # if the dump was specified, perform it and exit
    if [ ${do_dump} -ne 0 ]; then
        # iterate through all files in the home directory
        for rf in $(find ${__shuggtool_ring_file_home} -maxdepth 1 -name ".shuggtool_ring_*"); do
            __shuggtool_ring_file_dump "${rf}"
        done
        __shuggtool_ring_file_prune
        return 0
    fi

    # delete any old ring files before beginning to ring (helps keep things
    # tidy)
    __shuggtool_ring_file_prune

    # repeatedly bell
    c_idx_last=-1
    while true; do
        if [ ${bell_quiet} -eq 0 ]; then
            __shuggtool_ring_print_frame "${bell_text}"
            __shuggtool_ring_file_write "${bell_text}"
        else
            echo -en "\a"
        fi

        # sleep until the next one
        sleep ${bell_rate}
    done
}

# pass all args to main function
__shuggtool_ring "$@"

