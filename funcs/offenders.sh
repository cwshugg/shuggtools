# Offenders
# A function used to display the top N "offenders" for disk storage. It's
# essentially a way to print the largest N files within a specific directory.
#
#   Connor Shugg

function __shuggtool_storage_offenders_usage()
{
    echo "Storage offenders: shows you the files that take up the most space in a given directory."
    echo ""
    echo "Invocation arguments:"
    echo "-----------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -d DIR_PATH  Searches DIR_PATH for the largest files"
    echo " -n NUM       Displays the largest NUM files"
    echo "-----------------------------------------------------"
}

# Subroutine that takes in a directory to search and the number of entries
# to search for in the directory. Prints information to stdout.
function __shuggtool_storage_offenders_search()
{
    local sdir=$1
    local snum=$2

    # make an array of colors to use to draw the 'heats' of large-to-small
    # files (nice visual effect)
    local heatcolors=("\033[38;2;255;0;0m"   "\033[38;2;255;100;0m" \
                      "\033[38;2;255;150;0m" "\033[38;2;255;200;0m" \
                      "\033[38;2;255;255;0m")
    local heatcolors_len=${#heatcolors[@]}
    local heatcolors_interval=$((snum/heatcolors_len))
    if [ ${heatcolors_interval} -eq 0 ]; then
        heatcolors_interval=1
    fi
    
    # capture the sorted output of the top N files and iterate through it
    count=0
    echo "$(du -a -b ${sdir} 2> /dev/null | sort -n -r)" | while read -r line; do
        # split the line into pieces (pieces[0]=size, piece[1]=file-path)
        pieces=( ${line} )
        fbytes="${pieces[0]}"
        fpath="${pieces[1]}"

        # if the file is a directory, skip it
        if [ -d ${fpath} ]; then
            continue
        fi

        # make sure our count hasn't been exceeded
        if [ ${count} -eq ${snum} ]; then
            break
        fi

        # strip the search-directory prefix from the file path
        fpath="${fpath#${sdir}/}"
        
        # decide on string prefixes to make printing pretty
        prefix1="${STAB_TREE2}"
        prefix2="${STAB_TREE3}"
        if [ ${count} -eq $((snum-1)) ]; then
            prefix1="${STAB_TREE1}"
            prefix2="${STAB}"
        fi

        # decide which heat color to print the byte size in
        local hc_index=$((count/heatcolors_interval))
        if [ ${hc_index} -ge ${heatcolors_len} ]; then
            hc_index=$((heatcolors_len-1))
        fi
        local hc=${heatcolors[${hc_index}]}

        # print an informative message about the current file's size, name, and
        # what kind of file it is
        echo -e "${prefix1}${hc}${fbytes}${C_NONE} bytes:" \
                "${C_LTCYAN}${fpath}${C_NONE}${suffix}"
        ftype="$(file ${fpath} | cut -d ' ' -f 2-)"
        echo -e "${prefix2}${STAB_TREE1}${C_DKGRAY}${ftype}${C_NONE}"

        # increment our counter
        count=$((count+1))
    done

    return 0
}

# Main function
function __shuggtool_storage_offenders()
{
    # by default, we'll search for the top 10 largest files in the current
    # directory
    local sdir=$(pwd)
    local snum=10

    # first, check for command-line arguments to see if the user wants to
    # search elsewhere
    local OPTIND h c t
    while getopts "hd:n:" opt; do
        case ${opt} in
            h)
                __shuggtool_storage_offenders_usage
                return 0
                ;;
            d)
                sdir=${OPTARG}
                ;;
            n)
                snum=${OPTARG}
                ;;
            *)
                __shuggtool_storage_offenders_usage
                return 1
                ;;
        esac
    done

    # perform some error-checking on the inputs
    if [ ! -d ${sdir} ]; then
        __shuggtool_print_error "${sdir} could not be found."
        return 1
    fi
    if [ ${snum} -le 0 ]; then
        __shuggtool_print_error "-d must be followed by a positive non-zero integer."
        return 2
    fi
    
    # print a message to the user
    echo -e "Searching ${C_LTCYAN}${sdir}${C_NONE} for the top" \
            "${C_LTCYAN}${snum}${C_NONE} storage offenders..."
    
    # search the base directory
    __shuggtool_storage_offenders_search ${sdir} ${snum}
    return 0
}

# pass all args to main function
__shuggtool_storage_offenders "$@"

