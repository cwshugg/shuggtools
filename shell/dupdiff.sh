# DupDiff ("Duplicate Differences")
# A script that compares two different directories (usually two different
# clones of the same git repo) containing the same files, and looks for
# differences between those same files.
#
# This can be useful for detecting differences between two different local repo
# clones.
#
#   Connor Shugg

# Produces a list of files to compare for a provided directory.
function __shuggtool_dupdiff_get_file_list()
{
    d="$1"

    # determine if either directory is inside a git repository
    is_git="$(git -C "${d}" rev-parse --is-inside-work-tree 2> /dev/null)"

    # produce a list of files (using the first directory as the reference) to
    # compare with
    flist=()
    if [ ! -z "${is_git}" ]; then
        # produce a list of all files tracked by git in the directory
        git -C "${d}" ls-files --others --cached --exclude-standard "${d}"
    else
        # otherwise, produce a list of all files in the directory
        find "${d}" -type "f"
    fi
}

# Main function.
function __shuggtool_dupdiff()
{
    # at least one argument must be given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "At least one path to a directory must be given."
        return 1
    fi

    # determine which directories to use, depending on the arguments given
    dir1=""
    dir2=""

    # if more than one argument was given, use the first two as the two
    # directories to compare
    if [ $# -ge 2 ]; then
        dir1="$(realpath $1)"
        dir2="$(realpath $2)"
    else
        # if only one argument was given, use the current shell directory as
        # the first directory, and the provided argument as the second
        dir1="$(pwd)"
        dir2="$(realpath $1)"
    fi

    echo -e "Comparing files between directory-1" \
            "(${C_LTBLUE}${dir1}${C_NONE})" \
            "and directory-2" \
            "(${C_LTPURPLE}${dir2}${C_NONE})"

    # get a list of files to compare from each directory
    flist_dir1=($(__shuggtool_dupdiff_get_file_list "${dir1}"))
    flist_dir2=($(__shuggtool_dupdiff_get_file_list "${dir2}"))
    issue_count=0

    # identify files that are shared, but differ, and identify files that are
    # only present in dir1, but not dir2
    for f in "${flist_dir1[@]}"; do
        f_real="${dir1}/${f}"
        f_relative="$(realpath --relative-to="${dir1}" "${f_real}")"
        f_in_dir2="${dir2}/${f_relative}"

        # does the file exist in dir2?
        if [ -f "${f_in_dir2}" ]; then
            # do the files differ?
            diff_output="$(diff -q "${f_real}" "${f_in_dir2}")"
            if [ ! -z "${diff_output}" ]; then
                echo -e "${C_LTRED}Shared File Differs:${C_NONE} ${f_relative}"
                issue_count=$((issue_count + 1))
            fi
        else
            echo -e "${C_LTBLUE}Directory-1 Only:   ${C_NONE} ${f_relative}"
            issue_count=$((issue_count + 1))
        fi
    done

    # identify files that are only present in dir2, but not dir1
    for f in "${flist_dir2[@]}"; do
        f_real="${dir2}/${f}"
        f_relative="$(realpath --relative-to="${dir2}" "${f_real}")"
        f_in_dir1="${dir1}/${f_relative}"

        # does the file exist in dir1?
        if [ ! -f "${f_in_dir1}" ]; then
            echo -e "${C_LTPURPLE}Directory-2 Only:   ${C_NONE} ${f_relative}"
            issue_count=$((issue_count + 1))
        fi
    done

    # print out a message is no issues were found
    if [ ${issue_count} -eq 0 ]; then
        echo -e "${C_GREEN}No differences found.${C_NONE}"
    fi
}

__shuggtool_dupdiff "$@"

