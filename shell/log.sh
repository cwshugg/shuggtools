# Log
# A daily log tool used to keep track of my daily activity during work.
#
#   Connor Shugg

# Globals
log_dir=${HOME}/.daily_log
log_editor=$(which vim)
log_extension=".md"
allow_weekends=0
verbose=0

# Help menu
function __shuggtool_log_usage()
{
    echo "Log: a daily work log."
    echo "Usage: $0 [options]"
    echo "Invocation arguments:"
    echo "---------------------------------------------------------------------------"
    echo " -h                   Displays this menu."
    echo " -v                   Verbose mode."
    echo " -l                   List all dates for which a log file exists."
    echo " -a                   List ALL dates from the earliest to the latest,"
    echo "                      regardless if a log file exists or not."
    echo " -d YYYY-MM-DD        Opens a log file for the day specified by YYYY-MM-DD."
    echo " -s SEARCH_STRING     Searches all existing log files for the given text."
    echo "---------------------------------------------------------------------------"
}

# Takes in a number and pads it with a leading zero, if necessary.
function __shuggtool_log_pad_number()
{
    num="$1"
    width="$2"
    
    # compare the length of the number to the expected width, then compensate
    # by prepending zeroes to the resulting string
    result="${num}"
    num_width=${#num}
    diff=$((width-num_width))
    while [ ${diff} -gt 0 ]; do
        result="0${result}"
        diff=$((diff-1))
    done
    
    echo "${result}"
}

# Helper function that checks if a string is a number. Echoes a message if the given
# string *is* a number.
function __shuggtool_log_is_number()
{
    if [ "$1" ] && [ -z "${1//[0-9]}" ]; then
        echo "IS a number"
    fi
}

# Prompts the user to reveal where he/she is working from.
__shuggtool_log_get_location_retval=""
function __shuggtool_log_get_location()
{
    __shuggtool_log_get_location_retval=""

    # ask the user what their location is (not as automated and fun, but much
    # more reliable)
    __shuggtool_prompt_choices=("in the office" "at home")
    __shuggtool_prompt_choice "Where are you working from today?" 1
    __shuggtool_log_get_location_retval="${__shuggtool_prompt_choice_retval}"
}

# Takes in a datestring and echoes out its value in Unix epoch seconds.
function __shuggtool_log_get_date_seconds()
{
    if [ $# -lt 1 ]; then
        date +%s
    else
        date -d "$1" +%s
    fi
}

# Echoes out the current year.
function __shuggtool_log_get_date_year()
{
    if [ $# -lt 1 ]; then
        date +%-Y
    else
        date -d "$1" +%-Y
    fi
}

# Echoes out the current month.
function __shuggtool_log_get_date_month()
{
    if [ $# -lt 1 ]; then
        date +%-m
    else
        date -d "$1" +%-m
    fi
}

# Echoes out the current day.
function __shuggtool_log_get_date_day()
{
    if [ $# -lt 1 ]; then
        date +%-d
    else
        date -d "$1" +%-d
    fi
}

# Takes in a date and spits out a formatted YYYY-MM-DD datestring.
function __shuggtool_log_get_datestring()
{
    ds=""
    if [ $# -ge 1 ]; then
        ds="$1"
    else
        ds="$(date -d "$(date)")"
    fi
    
    # get the year, month, and day
    year="$(__shuggtool_log_get_date_year "${ds}")"
    month="$(__shuggtool_log_get_date_month "${ds}")"
    day="$(__shuggtool_log_get_date_day "${ds}")"
    
    # pad with zeroes
    year="$(__shuggtool_log_pad_number "${year}" 4)"
    month="$(__shuggtool_log_pad_number "${month}" 2)"
    day="$(__shuggtool_log_pad_number "${day}" 2)"

    echo "${year}-${month}-${day}"
}

# Takes in a datestring and converts any known keywords to valid datestrings.
function __shuggtool_log_translate_keyword()
{
    # grab the input and convert it to lowercase
    arg="$1"
    str="${arg,,}"
    
    # get the current time in seconds and as a datestring
    now_secs=$(__shuggtool_log_get_date_seconds)
    now_str="$(__shuggtool_log_get_datestring "@${now_secs}")"
    
    # SPECIAL KEYWORD 1: 'yesterday'
    if [[ "${str}" == "yesterday" ]] || [[ "${str}" == "yd" ]]; then
        yd_secs=$((now_secs-86400))
        yd_str="$(__shuggtool_log_get_datestring "@${yd_secs}")"
        # walk backwards until we for-sure hit yesterday
        while [[ "${yd_str}" == "${now_str}" ]]; do
            yd_secs=$((yd_secs-3600))
            yd_str="$(__shuggtool_log_get_datestring "@${yd_secs}")"
        done
        echo "${yd_str}"
        return
    fi

    # if all else fails, just echo the string back out
    echo "${arg}"
}

# Helper function that prints out a log file, either with or without verbose
# output.
function __shuggtool_log_print_logfile()
{
    lf="$(basename $1)"
    lf_date="${lf%.*}"
    color1=""
    color2=""
    if [ ${verbose} -ne 0 ]; then
        color1="$(__shuggtool_log_get_datestring_color "${lf_date}")"
        color2="${C_NONE}"
    fi
    echo -en "${color1}${lf_date}${color2}"

    # if verbose mode is on, print a little extra information
    if [ ${verbose} -ne 0 ]; then
        # count the line numbers
        lf_path=${log_dir}/${lf}
        lcount="${C_DKGRAY}no log exists${C_NONE}"
        if [ -f ${lf_path} ]; then
            lcount="${C_LTCYAN}$(cat ${lf_path} | wc -l) lines${C_NONE}"
        fi

        # retrieve the weekday
        weekday_color="${C_DKGRAY}"
        if [ -f ${lf_path} ]; then
            weekday_color="${C_LTRED}"
        fi
        lf_weekday="${weekday_color}$(date -d "${lf_date}" +%A)${C_NONE}"

        # print out the results
        echo -e " - ${lf_weekday} - ${lcount}"
    else
        echo ""
    fi
}

# Takes in a datestring and echoes out the color to use to print it out.
function __shuggtool_log_get_datestring_color()
{
    ds="$1"
    if [[ "$(__shuggtool_log_get_datestring)" == "${ds}" ]]; then
        echo -n "${C_LTGREEN}"
    elif [ -z "$(find ${log_dir} -name "*${ds}${log_extension}")" ]; then
        echo -n "${C_DKGRAY}"
    else
        echo -n "${C_NONE}"
    fi
}

# Helper function that echoes out the existing log file paths, one per line, in
# sorted order by the date each file name specifies.
function __shuggtool_log_get_files()
{
    ls -1 ${log_dir} | grep -E "\b[0-9]{4}-[0-9]{2}-[0-9]{2}\b" | sort -V
}

# Returns the basename of the file with the earliest date.
function __shuggtool_log_get_earliest_file()
{
    __shuggtool_log_get_files | head -n 1
}

# Returns the basename of the file with the latest date.
function __shuggtool_log_get_latest_file()
{
    __shuggtool_log_get_files | tail -n 1
}

# Takes in a file path and initializes it (if necessary) to hold default logfile
# content.
function __shuggtool_log_file_init()
{
    fpath="$1"
    ds="$2"

    # if the file already exists, don't bother proceeding
    if [ -f ${fpath} ]; then
        if [ ${verbose} -ne 0 ]; then
            echo "Log file ${fpath} already exists."
        fi
        return 0
    fi

    # otherwise, we'll create and fill the file
    if [ ${verbose} -ne 0 ]; then
        echo "Creating log file ${fpath}."
    fi

    # start by retreiving the location from the user. If the user doesn't
    # give a location, abort 
    __shuggtool_log_get_location
    location="${__shuggtool_log_get_location_retval}"
    if [ -z "${location}" ]; then
        if [ ${verbose} -ne 0 ]; then
            echo "No location given. Aborting."
        fi
        return 0
    fi
    
    # create the file, retrieve the weekday, and write a template into the file
    touch ${fpath}
    weekday="$(date -d "${ds}" +%A)"
    echo -e "# ${weekday} ${ds}\n\n* \n\n**Location:** ${location}.\n" > ${fpath}
}

# Searches all log files for a specific string.
function __shuggtool_log_search()
{
    str="$1"
    str="${str,,}"

    # iterate through all files in the log directory
    for lf in $(__shuggtool_log_get_files); do
        lf=${log_dir}/${lf}
        # skip any non-files
        if [ ! -f ${lf} ]; then
            continue
        fi

        # retrieve the file contents and convert to lowercase
        content="$(cat ${lf})"
        content="${content,,}"

        # iterate, line-by-line, through the file, searching for the string
        results=()
        line_num=1
        while read -r line; do
            # convert the line to lowercase and check the search string
            lower_line="${line,,}"
            if [[ "${lower_line}" == *"${str}"* ]]; then
                results+=("${line}")
            fi
            line_num=$((line_num+1))
        done < ${lf}

        # if the result array was filled up, alert the user
        results_len=${#results[@]}
        if [ ${results_len} -gt 0 ]; then
            # get the file's basename without its extension
            __shuggtool_log_print_logfile ${lf}

            # echo the matching lines, if we're verbose
            if [ ${verbose} -ne 0 ]; then
                for (( i=0; i<${results_len}; i++ )); do
                    line="${results[${i}]}"
                    # pick and appropraite prefix, then print out the line
                    prefix="${STAB_TREE2}"
                    if [ ${i} -eq $((results_len-1)) ]; then
                        prefix="${STAB_TREE1}"
                    fi
                    echo -e "${C_DKGRAY}${prefix}${C_NONE}${line}"
                done
            fi
        fi
    done
}

# Lists all dates for which a log file already exists.
function __shuggtool_log_list()
{
    list_all_dates=$1

    # if we're listing all dates, we'll start at the earliest file and iterate
    # *every* day until we get to the last day
    if [ ${list_all_dates} -eq 1 ]; then
        first_date="$(basename $(__shuggtool_log_get_earliest_file))"
        first_date="${first_date%.*}"
        last_date="$(basename $(__shuggtool_log_get_latest_file))"
        last_date="${last_date%.*}"
        curr_date="${first_date}"

        # compute an ending date string
        end_date=$(__shuggtool_log_get_date_seconds "${last_date}")
        end_date=$((end_date+86400))
        end_date="$(__shuggtool_log_get_datestring "@${end_date}")"

        while [[ "${curr_date}" != "${end_date}" ]]; do
            # if a log file exists for this date, print it out as normal
            fp=${curr_date}
            #fp=$(find ${log_dir} -name "*${curr_date}*" | head -n 1)
            __shuggtool_log_print_logfile ${fp}${log_extension}

            # increment the current date by one day
            prev_date="${curr_date}"
            curr_date_secs=$(__shuggtool_log_get_date_seconds "${curr_date}")
            curr_date_secs=$((curr_date_secs+86400))
            curr_date="$(__shuggtool_log_get_datestring "@${curr_date_secs}")"
            # in some cases (such as daylight savings), adding 86400 seconds
            # might not push us to the next calendar day. In case that happens,
            # we'll check here to see if we need to increment more. We'll do
            # so by small increments
            while [[ "${prev_date}" == "${curr_date}" ]]; do
                curr_date_secs=$((curr_date_secs+3600))
                curr_date="$(__shuggtool_log_get_datestring "@${curr_date_secs}")"
            done
        done
        return 0
    fi

    # otherwise, get a summary of all files in the log directory, sorted
    # accordingly
    for lf in $(__shuggtool_log_get_files); do
        __shuggtool_log_print_logfile ${lf}
    done
}

# Main function
function __shuggtool_log()
{
    # allow the log directory to be overridden, if the correct environment
    # variable is set
    if [ ! -z "${LOG_PATH}" ]; then
        log_dir="$(realpath ${LOG_PATH})"
    fi

    # first, make sure the log directory exists
    if [ ! -d ${log_dir} ]; then
        mkdir ${log_dir}
    fi

    # take the current day and form a datestring
    ds="$(__shuggtool_log_get_datestring)"

    # check for command-line arguments
    search_str=""
    do_list=0
    local OPTIND h v d s
    while getopts "hvlad:s:" opt; do
        case ${opt} in
            h)
                __shuggtool_log_usage
                return 0
                ;;
            v)
                verbose=1
                ;;
            l)
                do_list=1
                ;;
            a)
                do_list=2
                ;;
            d)
                ds="${OPTARG}"
                ;;
            s)
                search_str="${OPTARG}"
                ;;
            *)
                __shuggtool_log_usage
                return 0
                ;;
        esac
    done

    # if the search term was set, perform the search and return
    if [ ! -z "${search_str}" ]; then
        __shuggtool_log_search "${search_str}"
        return 0
    fi

    # if the list option was selected, we'll list all files in the log directory
    if [ ${do_list} -ne 0 ]; then
        # depending on if '-a' was given, we'll list all dates (or not)
        list_all_dates=0
        if [ ${do_list} -eq 2 ]; then
            list_all_dates=1
        fi
        __shuggtool_log_list ${list_all_dates}
        return 0
    fi

    # pass the datestring through a function to convert any special keywords
    # into valid datestrings
    ds="$(__shuggtool_log_translate_keyword "${ds}")"

    # check the datestring for validity
    ds_array=(${ds//-/ })
    if [ ${#ds_array[@]} -lt 3 ]; then
        __shuggtool_print_error "the date string must be in the \"YYYY-MM-DD\" format."
        return 1
    fi
    if [[ "$(date -d ${ds} 2>&1)" == *"invalid date"* ]]; then
        __shuggtool_print_error "the given date is invalid."
        return 2
    fi  
    year="${ds_array[0]}"   # grab the year
    month="${ds_array[1]}"  # grab the month
    day="${ds_array[2]}"    # grab the day

    # make sure each piece are numbers
    if [ -z "$(__shuggtool_log_is_number ${year})" ] || \
       [ -z "$(__shuggtool_log_is_number ${month})" ] || \
       [ -z "$(__shuggtool_log_is_number ${day})" ]; then
        __shuggtool_print_error "each part of the date string must be a number."
        return 
    fi
    
    # pad all numbers with zeroes
    year="$(__shuggtool_log_pad_number "${year}" 4)"
    month="$(__shuggtool_log_pad_number "${month}" 2)"
    day="$(__shuggtool_log_pad_number "${day}" 2)"

    # first, determine if the date is on a weekend day. If it is, we'll check
    # with the user to see if they still want to proceed with writing a log file
    weekday="$(date -d "${ds}" +%A)"
    if [[ "${weekday,,}" == "saturday" ]] || \
       [[ "${weekday,,}" == "sunday" ]]; then
        __shuggtool_prompt_yesno "This date is a ${weekday}. Still proceed?"
        yes=$?
        # if the user said 'no', don't proceed
        if [ ${yes} -eq 0 ]; then
            return 0
        fi
    fi

    # create the path for the log file and initialize it
    lfpath=${log_dir}/${year}-${month}-${day}${log_extension}
    __shuggtool_log_file_init ${lfpath} "${year}-${month}-${day}"
    
    # open the log file for viewing/editing
    ${log_editor} ${lfpath} -c ":3"
}

# pass all args to main function
__shuggtool_log "$@"

