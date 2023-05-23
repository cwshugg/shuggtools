# A shell script that sets up my preferred bash prompt.
#
#   Connor Shugg

# knobs to adjust the prompt building
__shuggtool_prompt_show_jobs=1              # show jobs in background
__shuggtool_prompt_show_git=1               # enables git repo stats
__shuggtool_prompt_show_git_repo_name=1     # shows git repo name
__shuggtool_prompt_show_git_repo_branch=1   # shows git branch name
__shuggtool_prompt_show_git_repo_diff=1     # show git diffs

# other globals
__shuggtool_prompt_bg_format="48;2"         # prefix for background colors
__shuggtool_prompt_fg_format="38;2"         # prefix for foreground colors

# Helper function that creates a PS1-friendly string that represents a colored
# block containing given text, then adds it to PS1.
function __shuggtool_prompt_block()
{
    # get the three required arguments
    bgc="$1" # background (block) color
    fgc="$2" # foreground (text) color
    txt="$3" # text to display

    # form the format string
    format=""
    if [ "${bgc}" != "0" ]; then
        format="${format}${__shuggtool_prompt_bg_format};${bgc}"
        # add a semicolon in between background and foreground formatting
        if [ "${fgc}" != "0" ]; then
            format="${format};"
        fi
    fi
    if [ "${fgc}" != "0" ]; then
        format="${format}${__shuggtool_prompt_fg_format};${fgc}"
    fi

    # create the final string and add it to PS1
    PS1="${PS1}\[\033[${format}m\]${txt}\[\033[0m\]"
}

# Function to update PS1 after each command.
function __shuggtool_prompt_command()
{
    # reset PS1
    PS1=""

    # add username block to PS1
    username_bgc="0;30;128"
    username_fgc="255;255;255"
    __shuggtool_prompt_block "${username_bgc}" "${username_fgc}" " \u "

    # add hostname block
    hostname_bgc="180;17;33"
    hostname_fgc="255;255;255"
    __shuggtool_prompt_block "${hostname_bgc}" "${hostname_fgc}" " \h "

    # add current directory block
    pwd_bgc="210;129;7"
    pwd_fgc="0;0;0"
    __shuggtool_prompt_block "${pwd_bgc}" "${pwd_fgc}" " \W "

    # check for active jobs and append to PS1 if there are pending ones
    if [ ${__shuggtool_prompt_show_jobs} -ne 0 ]; then
        job_count="$(jobs | wc -l)"
        if [ ${job_count} -gt 0 ]; then
            # add a prefix
            pfx="$(echo -e "\u2501")"
            pfx_bgc="0"
            pfx_fgc="150;150;150"
            __shuggtool_prompt_block "${pfx_bgc}" "${pfx_fgc}" "${pfx}"
            
            # add the job count itself
            job_bgc="75;75;75"
            job_fgc="225;50;50"
            __shuggtool_prompt_block "${job_bgc}" "${job_fgc}" " ${job_count} "
        fi
    fi

    # check for the current git repo
    if [ ${__shuggtool_prompt_show_git} -ne 0 ]; then
        repo_url="$(git remote get-url origin 2> /dev/null)"
        if [ ! -z "${repo_url}" ]; then
            git_bgc="200;200;200"

            # add a prefix
            pfx="$(echo -e "\u2501")"
            pfx_bgc="0"
            pfx_fgc="150;150;150"
            __shuggtool_prompt_block "${pfx_bgc}" "${pfx_fgc}" "${pfx}"

            # format the repo name and add it
            if [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                repo_name="$(basename ${repo_url})"
                repo_name="${repo_name%.*}"
                
                repo_name_bgc="${git_bgc}"
                repo_name_fgc="0;30;128"
                __shuggtool_prompt_block "${repo_name_bgc}" "${repo_name_fgc}" " ${repo_name}"
            fi
            
            # format the repo branch and add it
            if [ ${__shuggtool_prompt_show_git_repo_branch} -ne 0 ]; then
                repo_branch="$(git rev-parse --abbrev-ref HEAD)"

                # add a separator between the repo name and branch name
                if [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                    sep_bgc="${git_bgc}"
                    sep_fgc="0;0;0"
                    __shuggtool_prompt_block "${sep_bgc}" "${sep_fgc}" " ->"
                fi

                repo_branch_bgc="${git_bgc}"
                repo_branch_fgc="14;59;67"
                __shuggtool_prompt_block "${repo_branch_bgc}" "${repo_branch_fgc}" " ${repo_branch}"

                # get the number of commits the local branch is ahead (or behind)
                # the remote end
                commit_diff=$(git rev-list --count HEAD...@{upstream} 2> /dev/null)
                if [ ! -z "${commit_diff}" ] && [ ${commit_diff} -ne 0 ]; then
                    # use "+" or "-" to indicate branch diff
                    pfx="+"
                    commit_fgc="30;75;10"
                    if [ ${commit_diff} -lt 0 ]; then
                        pfx="-"
                        commit_fgc="100;10;10"
                    fi

                    commit_bgc="${git_bgc}"
                    __shuggtool_prompt_block "${commit_bgc}" "${commit_fgc}" " ${pfx}${commit_diff}"
                fi
            fi
            
            # format the various changes in the file and add it
            if [ ${__shuggtool_prompt_show_git_repo_diff} -ne 0 ]; then 
                # get number of modified files and other stats
                stat="$(git diff --shortstat)"
                stat_files="$(echo ${stat} | cut -d "," -f 1 | xargs | cut -d " " -f 1)"
                stat_adds="$(echo ${stat} | cut -d "," -f 2 | xargs | cut -d " " -f 1)"
                stat_dels="$(echo ${stat} | cut -d "," -f 3 | xargs | cut -d " " -f 1)"

                # if at least one statistic is non-empty, we'll add a separator
                if [ ${__shuggtool_prompt_show_git_repo_branch} -ne 0 ] || \
                   [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                    if [ ! -z "${stat_files}" ] || [ ! -z "${stat_adds}" ] || [ ! -z "${stat_dels}" ]; then
                    # add a separator between the branch name and stats
                        sep_bgc="${git_bgc}"
                        sep_fgc="0;0;0"
                        __shuggtool_prompt_block "${sep_bgc}" "${sep_fgc}" " ->"
                    fi
                fi

                # add the number of files changed
                if [ ! -z "${stat_files}" ] && [ ${stat_files} -gt 0 ]; then
                    bgc="${git_bgc}"
                    fgc="60;10;75"
                    pfx="$(echo -e "\u2022")"
                    __shuggtool_prompt_block "${bgc}" "${fgc}" " ${pfx}${stat_files}"
                fi

                # add the number of additions
                if [ ! -z "${stat_adds}" ] && [ ${stat_adds} -gt 0 ]; then
                    bgc="${git_bgc}"
                    fgc="50;75;10"
                    pfx="+"
                    __shuggtool_prompt_block "${bgc}" "${fgc}" " ${pfx}${stat_adds}"
                fi

                # add the number of deletions
                if [ ! -z "${stat_dels}" ] && [ ${stat_dels} -gt 0 ]; then
                    bgc="${git_bgc}"
                    fgc="100;10;10"
                    pfx="-"
                    __shuggtool_prompt_block "${bgc}" "${fgc}" " ${pfx}${stat_dels}"
                fi
            fi

            # add a final space to the git section
            __shuggtool_prompt_block "${git_bgc}" "0;0;0" " "
        fi
    fi
    
    # add a space at the end of the prompt
    PS1="${PS1} "
}
__shuggtool_prompt_command

PROMPT_COMMAND="__shuggtool_prompt_command"

