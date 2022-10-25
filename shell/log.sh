# Log
# A daily log tool used to keep track of my daily activity during work.
#
#   Connor Shugg

# Globals
log_dir=${HOME}/.daily_log
log_editor=$(which vim)
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
    echo " -d YYYY-MM-DD        Opens a log file for the day specified by YYYY-MM-DD."
    echo " -s SEARCH_STRING     Searches all existing log files for the given text."
    echo "---------------------------------------------------------------------------"
}

# Helper function that checks if a string is a number. Echoes a message if the given
# string *is* a number.
function __shuggtool_log_is_number()
{
    if [ "$1" ] && [ -z "${1//[0-9]}" ]; then
        echo "IS a number"
    fi
}

# Takes in a datestring and echoes out its value in Unix epoch seconds.
function __shuggtool_log_date_seconds()
{
    date -d "$1" +%s
}

# Helper function that echoes out the existing log file paths, one per line, in
# sorted order by the date each file name specifies.
function __shuggtool_log_get_files()
{
    ls -1 ${log_dir} | sort -V
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
    touch ${fpath}
    weekday="$(date -d "${ds}" +%A)"
    echo -e "# ${weekday} ${ds}\n\n* \n" > ${fpath}
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
            lf_base="$(basename ${lf})"
            lf_base="${lf_base%.*}"
            echo -en "${C_GREEN}${lf_base}${C_NONE}"

            if [ ${verbose} -eq 0 ]; then
                echo -e " matches."
            else
                echo ""
            fi

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
    # get a summary of all files in the log directory, sorted accordingly
    for lf in $(ls ${log_dir} | sort -V); do
        lf_date="${lf%.*}"
        echo -en "${C_GREEN}${lf_date}${C_NONE}"

        # if verbose mode is on, print a little extra information
        if [ ${verbose} -ne 0 ]; then
            lf_path=${log_dir}/${lf}
            lcount=$(cat ${lf_path} | wc -l)
            echo " - ${lcount} lines"
        else
            echo ""
        fi
    done
}

# Main function
function __shuggtool_log()
{
    # first, make sure the log directory exists
    if [ ! -d ${log_dir} ]; then
        mkdir ${log_dir}
    fi

    # take the current day and form a datestring
    year="$(date +%Y)"
    month="$(date +%m)"
    day="$(date +%d)"
    ds="${year}-${month}-${day}"

    # check for command-line arguments
    search_str=""
    do_list=0
    local OPTIND h v d s
    while getopts "hvld:s:" opt; do
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
        __shuggtool_log_list
        return 0
    fi

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
    lfpath=${log_dir}/${year}-${month}-${day}.md
    __shuggtool_log_file_init ${lfpath} "${year}-${month}-${day}"
    
    # open the log file for viewing/editing
    ${log_editor} ${lfpath}
}

# pass all args to main function
__shuggtool_log "$@"

