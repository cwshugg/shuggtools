# Git Branch-Diff
# Script that uses some git commands to produce a report showing the differences
# between two branches.
#
#   Connor Shugg

# Uses git commands to compare branches and prints a report.
function __shuggtool_git_branchdiff_cmp()
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

# Main function.
function __shuggtool_git_branchdiff()
{
    # check for a git repository
    git_dir="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -z "${git_dir}" ]; then
        __shuggtool_print_error "You're not inside a git repository."
        return 1
    fi

    # determine what branch to use, based on the arguments given
    b1=""
    b2=""
    if [ $# -ge 1 ]; then
        b1="$1"
        # make sure the branch exists
        if [ -z "$(git rev-parse --verify ${b1} 2> /dev/null)" ]; then
            __shuggtool_print_error "Branch ${C_LTGREEN}${b1}${C_NONE} does not exist."
            return 1
        fi
        
        # if a second branch is given, use it as the second branch to compare
        if [ $# -ge 2 ]; then
            b2="$2"
            # make sure the branch exists
            if [ -z "$(git rev-parse --verify ${b2} 2> /dev/null)" ]; then
                __shuggtool_print_error "Branch ${C_LTYELLOW}${b2}${C_NONE} does not exist."
                return 1
            fi
        else
            # if only one branch name is given, we'll interpret the second
            # branch as the remote or local version of the same branch
            if [[ "${b1}" == *"origin/"* ]]; then
                b2="${b1/origin\//}"
            else
                b2="origin/${b1}"
            fi
        fi
    else
        # if NO arguments were given, use the current branch
        b1="$(git rev-parse --abbrev-ref HEAD)"
        if [[ "${b1}" == "HEAD" ]]; then
            __shuggtool_print_error "You're not on a branch."
            return 1
        fi
        b2="origin/${b1}"
    fi

    # check if the same two branches were chosen
    if [[ "${b1}" == "${b2}" ]]; then
        echo -e "Cannot compare branch ${C_LTGREEN}${b1}${C_NONE} against itself."
        return 0
    fi

    # invoke the comparison function with the two branches
    __shuggtool_git_branchdiff_cmp "${b1}" "${b2}"
}

__shuggtool_git_branchdiff "$@"

