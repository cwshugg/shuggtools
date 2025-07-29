# Script that uses some git commands to produce a list of commits that are
# present in one branch but are *not* present in another branch.
#
#   Connor Shugg

# Uses git commands to compare branches and prints a report.
function __shuggtool_git_compare_branch_commits_cmp()
{
    b1="$1"
    b2="$2"
    
    echo -e "Commits that are in ${C_LTGREEN}${b1}${C_NONE}" \
            "but are NOT in ${C_LTYELLOW}${b2}${C_NONE}:"

    git log "${b1}" --not "${b2}" \
            --date=format:"%m-%d-%Y" \
            --pretty=format:"%C(#ffce60)%h%C(reset)%x20%C(#5f87ff)%as%C(reset)%x20%C(#ffffff)%ae%C(reset)%x09%C(#8787af)%s%C(reset)%C(#d75f00)%d%C(reset)"
}

# Main function.
function __shuggtool_git_compare_branch_commits()
{
    # check for a git repository
    if [ -z $(__shuggtool_git_is_currently_in_git_repo) ]; then
        __shuggtool_print_error "You're not inside a git repository."
        return 1
    fi

    # determine what branch to use, based on the arguments given
    b1=""
    b2=""
    if [ $# -ge 1 ]; then
        # make sure the first branch exists
        b1="$1"
        if [ -z $(__shuggtool_git_does_branch_exist "${b1}") ]; then
            __shuggtool_print_error "Branch ${C_LTGREEN}${b1}${C_NONE} does not exist."
            return 1
        fi
        
        # if a second branch is given, use it as the second branch to compare
        if [ $# -ge 2 ]; then
            # make sure the second branch exists
            b2="$2"
            if [ -z $(__shuggtool_git_does_branch_exist "${b2}") ]; then
                __shuggtool_print_error "Branch ${C_LTYELLOW}${b2}${C_NONE} does not exist."
                return 1
            fi
        else
            # if only one branch name is given, we'll use it as the *second*
            # branch, and use the current branch as the *first* branch
            current_branch="$(__shuggtool_git_get_current_branch)"
            if [ -z "${current_branch}" ]; then
                msg="You currently aren't on a specific branch."
                msg="${msg} Please specify two branch names."
                __shuggtool_print_error "${msg}"
                return 1
            fi

            b2="${b1}"
            b1="${current_branch}"
        fi
    else
        # if NO arguments were given, complain and return
        __shuggtool_print_error "Please specify one or two branch names."
        return 1
    fi

    # check if the same two branches were chosen
    if [[ "${b1}" == "${b2}" ]]; then
        echo -e "Cannot compare branch ${C_LTGREEN}${b1}${C_NONE} against itself."
        return 0
    fi

    # invoke the comparison function with the two branches
    __shuggtool_git_compare_branch_commits_cmp "${b1}" "${b2}"
}

__shuggtool_git_compare_branch_commits "$@"

