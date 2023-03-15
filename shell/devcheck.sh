# Dev Check
# A tool that searches your source code for TODOs, FIXMEs, DEBUGs, etc. and
# displays a summary for you.
#
#   Connor Shugg

# Keyword definitions
dev_keywords=(
    "FIXME"
    "TODO"
    "DEBUG"
    "NOTE"
)
dev_keywords_colors=(
    "\033[38;2;215;0;0m"
    "\033[38;2;215;95;0m"
    "\033[38;2;255;175;0m"
    "\033[38;2;95;135;135m"
)

# Other globals
verbose=0

# Displays a help menu for this tool.
function __shuggtool_devcheck_usage()
{
    echo "Dev check: searches your code for TODOs and other keywords."
    echo ""
    echo "Usage: devcheck [-f FILE] [-d DIRECTORY]"
    echo "Invocation arguments:"
    echo "------------------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -f           Specifies a single file to search"
    echo " -d           Specifies a directory to recursively search"
    echo "------------------------------------------------------------------"
}

# Searches a single file for developer keywords.
function __shuggtool_devcheck_search_file()
{
    f=$1

    # first, make sure the file exists
    if [ ! -f ${f} ]; then
        __shuggtool_print_error "failed to find file: ${f}"
    fi

    # set up an array of counters
    counts=()
    sum=0
    num_keywords=${#dev_keywords[@]}
    for (( i=0; i<${num_keywords}; i++ )); do
        counts+=(0)
    done

    # iterate through each keyword
    for (( i=0; i<${num_keywords}; i++ )); do
        keyword="${dev_keywords[${i}]}"
            
        # search the file for an occurrence count
        count=$(grep -o "${keyword}" ${f} | wc -l)
        counts[${i}]=${count}
        sum=$((sum+count))
    done

    # if there were NO keywords found at ALL, proceed no further
    if [ ${sum} -eq 0 ]; then
        return
    fi

    # build a list of lines to print
    output_keywords=()
    output_colors=()
    output_counts=()
    for (( i=0; i<${num_keywords}; i++ )); do
        keyword="${dev_keywords[${i}]}"
        color="${dev_keywords_colors[${i}]}"
        count=${counts[${i}]}
        
        # only include the line if it had a greater-than-zero count
        if [ ${count} -gt 0 ]; then
            output_keywords+=("${keyword}")
            output_colors+=("${color}")
            output_counts+=(${count})
        fi
    done

    # print the file name
    printf "${f}\n"

    # now, iterate through the lines and print them out
    num_lines=${#output_keywords[@]}
    for (( i=0; i<${num_lines}; i++ )); do
        # pick out a prefix to print with
        prefix="${STAB_TREE2}"
        if [ ${i} -eq $((num_lines-1)) ]; then
            prefix="${STAB_TREE1}"
        fi

        # print the line
        keyword="${output_keywords[${i}]}"
        color="${output_colors[${i}]}"
        count=${output_counts[${i}]}
        printf "${prefix}%d ${color}${keyword}${C_NONE}(s)\n" "${count}"
    done
}

function __shuggtool_devcheck_search_dir()
{
    d=$1

    # first, make sure the directory exists
    if [ ! -d ${d} ]; then
        __shuggtool_print_error "failed to find directory: ${d}"
        return
    fi

    # find all file paths in the directory and iterate through them
    for path in $(find ${d} -type f); do
        __shuggtool_devcheck_search_file "${path}"
    done
}

# Main function.
function __shuggtool_devcheck()
{
    # if no arguments were specified, show the help menu
    
    file=""
    dir=""

    # check for command-line arguments
    local OPTIND h f d
    while getopts "hf:d:" opt; do
        case ${opt} in
            h)
                __shuggtool_devcheck_usage
                return 0
                ;;
            f)
                file="${OPTARG}"
                ;;
            d)
                dir="${OPTARG}"
                ;;
            *)
                __shuggtool_devcheck_usage
                return 1
                ;;
        esac
    done
    
    # if a file was specified, we'll search only that file
    if [ ! -z "${file}" ]; then
        __shuggtool_devcheck_search_file "${file}"
        return 0
    fi

    # if a directory was specified, we'll recursively search it
    if [ ! -z "${dir}" ]; then
        __shuggtool_devcheck_search_dir "${dir}"
        return 0
    fi
    
    # finally, if no arguments were specified, we'll recursively search the
    # current directory
    if [ $# -lt 1 ]; then
        __shuggtool_devcheck_search_dir "./"
        return 0
    fi

}

__shuggtool_devcheck "$@"

