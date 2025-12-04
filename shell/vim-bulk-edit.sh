# Vim Bulk Edit
# A script that builds a Vim command and launches it such that a long list of
# files are opened and split between several tabs and windows.
#
#   Connor Shugg

# Uses git commands to compare branches and prints a report.
function __shuggtool_vim_bulk_edit_cmp()
{
    b1="$1"
    b2="$2"

    # get the diff between b1 and b2
    diff1=$(git rev-list ${b1} --not ${b2} 2> /dev/null | wc -l)
    if [ ${diff1} -eq 0 ]; then
        echo -e "Branch ${C_LTGREEN}${b1}${C_NONE} has no commits" \
                "branch ${C_LTYELLOW}${b2}${C_NONE} lacks."
    else
        echo -e "Branch ${C_LTGREEN}${b1}${C_NONE} has" \
                "${C_LTBLUE}${diff1}${C_NONE} commit(s) that" \
                "branch ${C_LTYELLOW}${b2}${C_NONE} does not."
    fi

    # get the diff between b2 and b1
    diff2=$(git rev-list ${b2} --not ${b1} 2> /dev/null | wc -l)
    if [ ${diff2} -eq 0 ]; then
        echo -e "Branch ${C_LTYELLOW}${b2}${C_NONE} has no commits" \
                "branch ${C_LTGREEN}${b1}${C_NONE} lacks."
    else
        echo -e "Branch ${C_LTYELLOW}${b2}${C_NONE} has" \
                "${C_LTBLUE}${diff1}${C_NONE} commit(s) that" \
                "branch ${C_LTGREEN}${b1}${C_NONE} does not."
    fi
}

# Help menu
function __shuggtool_vim_bulk_edit_usage()
{
    echo "Vim Bulk Edit: Open a long list of files in Vim."
    echo ""
    echo "Usage: vim-bulk-edit [options] [file1 file2 ... fileN]"
    echo "Invocation arguments:"
    echo "-------------------------------------------------------------------------"
    echo " -h               Shows this help menu"
    echo " -v               Enables verbose prints."
    echo " -w               Specifies the number of windows to open per tab."
    echo "                  This must be a positive, non-zero integer."
    echo "                  Default: 2"
    echo "-------------------------------------------------------------------------"
}

# Main function.
function __shuggtool_vim_bulk_edit ()
{
    verbose=0
    windows_per_tab=2

    # first, check for command-line arguments
    local OPTIND h w
    while getopts "hvw:" opt; do
        case ${opt} in
            h)
                __shuggtool_vim_bulk_edit_usage
                return 0
                ;;
            v)
                verbose=1
                ;;
            w)
                # make sure the argument is a positive integer
                if ! [[ ${OPTARG} =~ ^[1-9][0-9]*$ ]]; then
                    __shuggtool_print_error "Invalid number of windows: ${OPTARG}"
                    __shuggtool_vim_bulk_edit_usage
                    return 1
                fi
                windows_per_tab=${OPTARG}
                ;;
            *)
                __shuggtool_vim_bulk_edit_usage
                return 1
                ;;
        esac
    done

    # collect a list of all files passed in as arguments
    shift $((OPTIND - 1))
    files=("$@")
    files_len=${#files[@]}

    # if no files were provided, exit early
    if [ ${files_len} -eq 0 ]; then
        __shuggtool_print_error "No files specified for bulk edit."
        __shuggtool_vim_bulk_edit_usage
        return 1
    fi

    # print output describing what will be opened in vim
    echo -e "Opening ${C_LTBLUE}${files_len}${C_NONE} file(s) in Vim with" \
            "${C_LTBLUE}${windows_per_tab}${C_NONE} window(s) per tab."

    # construct a Vim script to open all files in the desired layout
    script=""
    script="${script}tabonly\n"
    script="${script}silent only\n"

    # for each file, append it to the command
    file_idx=0
    for file in "${files[@]}"; do
        file_realpath=$(realpath "${file}")
        script="${script}edit ${file_realpath}\n"

        # if we've reached the window limit for this tab, create a new tab to
        # prepare for the next loop iteration
        file_idx_modulus=$(((file_idx + 1) % windows_per_tab))
        if [ ${file_idx_modulus} -eq 0 ]; then
            # only append this command if there are more files to open
            if [ ${file_idx} -lt $((files_len - 1)) ]; then
                script="${script}1wincmd w\n" # <-- move to first window in this tab
                script="${script}tabnew\n"
            fi
        # otherwise, if we haven't reached the window limit, split to a new
        # window within the same tab
        else
            # only append this command if there are more files to open
            if [ ${file_idx} -lt $((files_len - 1)) ]; then
                script="${script}vsplit\n"
            fi
        fi

        file_idx=$((file_idx + 1))
    done

    # run one last `1wincmd w` to ensure we're focused in the first window of
    # the last tab, then run a `tabfirst` command to focus on the very first
    # tab
    script="${script}1wincmd w\n"
    script="${script}tabfirst\n"

    # dump the Vim script into a temporary file
    script_tmpfile="${HOME}/.vim_bulk_edit_script_$$.vim"
    echo -e "${script}" > "${script_tmpfile}"

    # if the verbose switch is activated, print the constructed script
    if [ ${verbose} -ne 0 ]; then
        echo -e "Temporary Vim script (${C_YELLOW}${script_tmpfile}${C_NONE}):"
        echo -e "${C_DKGRAY}$(cat ${script_tmpfile})${C_NONE}"
    fi

    # open vim and point it at the script
    cmd="vim -c \"source ${script_tmpfile}\""
    #cmd="vim -S \"${script_tmpfile}\""
    echo -e "Executing Vim command: ${C_LTBLUE}${cmd}${C_NONE}"
    eval "${cmd}"

    # delete the vim script file
    if [ ${verbose} -ne 0 ]; then
        echo -e "Deleting temporary Vim script (${C_YELLOW}${script_tmpfile}${C_NONE})."
    fi
    rm -f "${script_tmpfile}"

}

__shuggtool_vim_bulk_edit "$@"

