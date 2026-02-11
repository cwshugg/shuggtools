# A shell script that sets up my preferred bash prompt.
#
#   Connor Shugg

# knobs to adjust the prompt building
__shuggtool_prompt_show_jobs=1              # show jobs in background
__shuggtool_prompt_show_exitcode=1          # show exit codes
__shuggtool_prompt_show_workspace=1         # show current workspace
__shuggtool_prompt_show_conda_env=1         # show conda environment
__shuggtool_prompt_show_git=1               # enables git repo stats
__shuggtool_prompt_show_git_repo_name=1     # shows git repo name
__shuggtool_prompt_show_git_repo_branch=1   # shows git branch name
__shuggtool_prompt_show_git_repo_diff=1     # show git diffs

# knobs to adjust what fields in the prompt to "collapse" (i.e. remove the text
# and only show a small color block in its place). I added these in to have my
# prompt take up less room if necessary.
__shuggtool_prompt_collapse_username=0      # collapse username block
__shuggtool_prompt_collapse_hostname=0      # collapse hostname block
__shuggtool_prompt_collapse_pwd=0           # collapse current directory block
__shuggtool_prompt_collapse_workspace=0     # collapse current workspace

# other globals
__shuggtool_prompt_bg_format="48;2"         # prefix for background colors
__shuggtool_prompt_fg_format="38;2"         # prefix for foreground colors
__shuggtool_prompt_previous_cmdnum=0        # prefix bash command number
__shuggtool_prompt_previous_retval=0        # return captured during previous prompt generation


# ------------------------ Prompt Adjustment Aliases ------------------------- #
# Takes in a string and uses it to determine what global settings to tweak to
# collapse a certain section of the prompt.
function __shuggtool_prompt_configure_collapse_helper()
{
    # argument 1: 1 = collapse, 0 = expand
    collapse=1
    if [ $# -ge 2 ]; then
        collapse=$1
        if [ ${collapse} -ne 0 ]; then
            collapse=1
        fi
    fi

    # argument 2: a string containing keywords to select certain settings
    target=""
    if [ $# -ge 1 ]; then
        target="$2"
        target="${target,,}"
    fi

    # if the target is empty, apply the setting to all
    if [ -z "${target}" ]; then
        __shuggtool_prompt_collapse_username=${collapse}
        __shuggtool_prompt_collapse_hostname=${collapse}
        __shuggtool_prompt_collapse_pwd=${collapse}
        __shuggtool_prompt_collapse_workspace=${collapse}
    fi

    # apply the setting based on the target text
    if [[ "${target}" == *"username"* ]]; then
        __shuggtool_prompt_collapse_username=${collapse}
    fi
    if [[ "${target}" == *"hostname"* ]]; then
        __shuggtool_prompt_collapse_hostname=${collapse}
    fi
    if [[ "${target}" == *"pwd"* ]]; then
        __shuggtool_prompt_collapse_pwd=${collapse}
    fi
    if [[ "${target}" == *"workspace"* ]]; then
        __shuggtool_prompt_collapse_workspace=${collapse}
    fi
}

# Used for collapsing prompt components.
function __shuggtool_prompt_configure_collapse()
{
    __shuggtool_prompt_configure_collapse_helper 1 "$1"
}

# Used for expanding prompt components.
function __shuggtool_prompt_configure_expand()
{
    __shuggtool_prompt_configure_collapse_helper 0 "$1"
}

# Used to enable or disable git in the prompt
function __shuggtool_prompt_configure_git()
{
    __shuggtool_prompt_show_git=$1
}

# Expansion/collapsing aliases
alias prompt-collapse="__shuggtool_prompt_configure_collapse"
alias prompt-collapse-username="__shuggtool_prompt_configure_collapse \"username\""
alias prompt-collapse-hostname="__shuggtool_prompt_configure_collapse \"hostname\""
alias prompt-collapse-pwd="__shuggtool_prompt_configure_collapse \"pwd\""
alias prompt-collapse-workspace="__shuggtool_prompt_configure_collapse \"workspace\""
alias prompt-expand="__shuggtool_prompt_configure_expand"
alias prompt-expand-username="__shuggtool_prompt_configure_expand \"username\""
alias prompt-expand-hostname="__shuggtool_prompt_configure_expand \"hostname\""
alias prompt-expand-pwd="__shuggtool_prompt_configure_expand \"pwd\""
alias prompt-expand-workspace="__shuggtool_prompt_configure_expand \"workspace\""
alias prompt-enable-git="__shuggtool_prompt_configure_git 1"
alias prompt-disable-git="__shuggtool_prompt_configure_git 0"


# -------------------------- Prompt String Building -------------------------- #
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

# Helper function that adds a line separator to be placed between two blocks.
function __shuggtool_prompt_block_separator()
{
    # take in the colors and the length (length is optional)
    bgc="$1"
    fgc="$2"
    len=1
    if [ $# -ge 3 ]; then
        len=$3
    fi

    # build the string, based on the length
    pfx=""
    for (( i=0; i<${len}; i++ )); do
        pfx="${pfx}\u2501"
    done
    pfx="$(echo -e "${pfx}")"

    __shuggtool_prompt_block "${bgc}" "${fgc}" "${pfx}"
}

# Function to update PS1 after each command.
function __shuggtool_prompt_command()
{
    # retrieve the last command's return value and the current shell PID
    retval=$?
    shell_pid="$$"

    # if the bash version is 4.4 or greater, we can use '@P' expansion to force
    # PS1-style expansion of the "\#" string
    bash_version_4_4=0
    if [ ${__shuggtool_bash_version_major} -gt 4 ]; then
        bash_version_4_4=1
    elif [ ${__shuggtool_bash_version_major} -eq 4 ] && [ ${__shuggtool_bash_version_minor} -ge 4 ]; then
        bash_version_4_4=1
    fi

    if [ ${bash_version_4_4} -ne 0 ]; then
        cmdnum_str="\#"
        cmdnum="${cmdnum_str@P}" # expand string as if it was PS1
    else
        # if '@P' isn't available, we'll grab the last history command value
        # instead
        cmdnum="$(history 1 | xargs | cut -d " " -f 1)"
    fi

    # reset PS1
    PS1=""

    # set colors for the main three blocks of the prompt
    username_bgc="0;30;128"
    username_fgc="255;255;255"
    hostname_bgc="180;17;33"
    hostname_fgc="255;255;255"
    pwd_bgc="210;129;7"
    pwd_fgc="0;0;0"

    # if we're currently inside a virtual environment, we'll modify the prompt
    # coloring to indicate it
    if [ ! -z "${VIRTUAL_ENV}" ]; then
        username_bgc="50;50;50"
        username_fgc="255;255;255"
        hostname_bgc="48;105;152"
        hostname_fgc="255;255;255"
        pwd_bgc="235;192;39"
        pwd_fgc="0;0;0"
    fi

    # add a username block to PS1
    username_str=" \u "
    if [ ${__shuggtool_prompt_collapse_username} -ne 0 ]; then
        username_str="  "
    fi
    __shuggtool_prompt_block "${username_bgc}" "${username_fgc}" "${username_str}"

    # add a hostname block
    hostname_str=" \h "
    if [ ${__shuggtool_prompt_collapse_hostname} -ne 0 ]; then
        hostname_str="  "
    fi
    __shuggtool_prompt_block "${hostname_bgc}" "${hostname_fgc}" "${hostname_str}"

    # add current directory block
    pwd_str=" \W "
    if [ ${__shuggtool_prompt_collapse_pwd} -ne 0 ]; then
        pwd_str="  "
    fi
    __shuggtool_prompt_block "${pwd_bgc}" "${pwd_fgc}" "${pwd_str}"

    # set color for prefix/separator colors
    pfx_bgc="0;0;0"
    pfx_fgc="130;130;130"

    # is the shell currently inside a workspace? If show, we'll add a block to
    # our prompt to reflect this
    if [ ${__shuggtool_prompt_show_workspace} -ne 0 ] && [ ! -z "${WORKSPACE}" ]; then
        __shuggtool_prompt_block_separator "${pfx_bgc}" "${pfx_fgc}"

        # add a workspace symbol
        ws_bgc="145;185;164"
        ws_fgc="125;15;15"
        __shuggtool_prompt_block "${ws_bgc}" "${ws_fgc}" " ⚒ "

        if [ ${__shuggtool_prompt_collapse_workspace} -eq 0 ]; then
            # add the workspace name
            ws_fgc="10;10;10"
            wsname="$(basename ${WORKSPACE})"
            __shuggtool_prompt_block "${ws_bgc}" "${ws_fgc}" "${wsname} "
        fi
    fi

    # are we in a conda environment? If so, we'll add a block to our prompt to
    # reflect this
    conda_env="${CONDA_DEFAULT_ENV}"
    if [ ${__shuggtool_prompt_show_conda_env} ] && \
       [ ! -z "${conda_env}" ] && \
       [[ "${conda_env}" != "base" ]]; then
        __shuggtool_prompt_block_separator "${pfx_bgc}" "${pfx_fgc}"

        # add a workspace symbol
        conda_env_bgc="185;185;164"
        conda_env_fgc="50;50;185"
        __shuggtool_prompt_block "${conda_env_bgc}" "${conda_env_fgc}" " ⚒ "

        if [ ${__shuggtool_prompt_collapse_workspace} -eq 0 ]; then
            # add the workspace name
            conda_env_fgc="10;10;10"
            __shuggtool_prompt_block "${conda_env_bgc}" "${conda_env_fgc}" "${conda_env} "
        fi
    fi

    # check for active jobs and append to PS1 if there are pending ones
    if [ ${__shuggtool_prompt_show_jobs} -ne 0 ]; then
        # count the number of child PIDs reported from pgrep
        job_count=-1 # start at negative one to offset 'ps' reporting itself
        children=$(ps --no-header --ppid "${shell_pid}" -o pid)
        for cpid in ${children[@]}; do
            job_count=$((job_count+1))
        done

        # if there's at least one child process...
        if [ ${job_count} -gt 0 ]; then
            # add a prefix
            __shuggtool_prompt_block_separator "${pfx_bgc}" "${pfx_fgc}"

            # add a character indicating an alive process
            retval_bgc="75;75;75"
            retval_fgc="225;225;225"
            __shuggtool_prompt_block "${retval_bgc}" "${retval_fgc}" " ↻"

            # add the job count
            job_bgc="75;75;75"
            job_fgc="225;200;50"
            __shuggtool_prompt_block "${job_bgc}" "${job_fgc}" " ${job_count} "
        fi
    fi

    # check the last command's return value and act if:
    #  - it's non-zero, AND
    #  - a command was just run (i.e. the user didn't press 'enter' with a blank line)
    if [ ${__shuggtool_prompt_show_exitcode} -ne 0 ] && \
       [ ${retval} -ne 0 ] && \
       [[ "${cmdnum}" != "${__shuggtool_prompt_previous_cmdnum}" ]]; then
        # add a separator
        __shuggtool_prompt_block_separator "${pfx_bgc}" "${pfx_fgc}"

        # add a character indicating that this was the last command's return value
        retval_bgc="75;75;75"
        retval_fgc="225;225;225"
        __shuggtool_prompt_block "${retval_bgc}" "${retval_fgc}" " ⚑"

        # add the return value number block (OR a signal name)
        retval_fgc="225;50;50"
        signame="$(__shuggtool_os_signal_retval ${retval})"
        retval_str="${retval}"
        if [ ! -z "${signame}" ]; then
            retval_str="${signame}"
        fi
        __shuggtool_prompt_block "${retval_bgc}" "${retval_fgc}" " ${retval_str} "
    fi

    # check for the current git repo
    if [ ${__shuggtool_prompt_show_git} -ne 0 ]; then
        # grab a path to the git binary, determine if it's a Windows executable
        # (if that's the case we must be on WSL, executing `git` on the Windows
        # filesystem)
        git="$(__shuggtool_git_binary)"
        repo_is_on_windows=0
        if [[ "${git}" == *".exe" ]]; then
            repo_is_on_windows=1
        fi

        repo_url="$("${git}" remote get-url origin 2> /dev/null)"

        # determine if the repository is bare, if no remote URL was found
        repo_is_bare=0
        if [ -z "${repo_url}" ]; then
            if [[ "$("${git}" rev-parse --is-bare-repository 2> /dev/null)" == "true" ]]; then
                repo_is_bare=1
            fi
        fi

        if [ ! -z "${repo_url}" ] || [ ${repo_is_bare} -ne 0 ]; then
            git_bgc="175;175;175"
            # choose a background color based on where the repo comes from
            if [[ "${repo_url}" == *"github"* ]]; then
                git_bgc="170;150;190"
            elif [[ "${repo_url}" == *"azure"* ]]; then
                git_bgc="150;150;210"
            fi

            # add a prefix and count what we're displaying
            __shuggtool_prompt_block_separator "${pfx_bgc}" "${pfx_fgc}"
            blocks_added=0

            # if we're running Git on Windows, add an icon to indicate this
            if [ ${repo_is_on_windows} -ne 0 ]; then
                repo_windows_bgc="${git_bgc}"
                repo_windows_fgc="0;164;239"
                __shuggtool_prompt_block "${repo_windows_bgc}" "${repo_windows_fgc}" " ❖"
            fi

            # format the repo name and add it
            if [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                blocks_added=$((blocks_added+1))

                repo_name_bgc="${git_bgc}"
                repo_name_fgc="0;30;128"

                # extract the name from the remote URL, if the repository isn't
                # bare. If it *IS* bare, we'll use a special name
                if [ ${repo_is_bare} -eq 0 ]; then
                    repo_name="$(basename "${repo_url}")"
                    repo_name="${repo_name%.*}"
                else
                    repo_name="[BARE]"
                    repo_name_fgc="128;30;0"
                fi

                __shuggtool_prompt_block "${repo_name_bgc}" "${repo_name_fgc}" " ${repo_name}"
            fi

            # format the repo branch and add it
            if [ ${__shuggtool_prompt_show_git_repo_branch} -ne 0 ]; then
                blocks_added=$((blocks_added+1))
                repo_branch="$("${git}" rev-parse --abbrev-ref HEAD 2> /dev/null)"
                repo_tag=""

                # if the branch name itself is displayed as HEAD, we won't
                # gather info on how many commits ahead/behind the remote
                # end we are.
                is_detached=0
                if [[ "${repo_branch}" == "HEAD" ]]; then
                    is_detached=1
                    repo_tag="$("${git}" describe --tags --abbrev=0 2> /dev/null)"
                fi

                # add a separator between the repo name and branch name
                if [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                    sep_bgc="${git_bgc}"
                    sep_fgc="0;0;0"
                    __shuggtool_prompt_block "${sep_bgc}" "${sep_fgc}" " ->"
                fi


                # if the repo is in a detached state, we'll use the tag name
                # instead of the branch name (prefixed to indicate it's detached)
                repo_branch_bgc="${git_bgc}"
                repo_branch_fgc="14;59;67"
                if [ ${is_detached} -ne 0 ]; then
                    repo_tag_fgc="67;39;14"
                    __shuggtool_prompt_block "${repo_branch_bgc}" "${repo_tag_fgc}" " ¦"
                    __shuggtool_prompt_block "${repo_branch_bgc}" "${repo_branch_fgc}" "${repo_tag}"
                else
                    __shuggtool_prompt_block "${repo_branch_bgc}" "${repo_branch_fgc}" " ${repo_branch}"
                fi

                # get the number of commits the local branch is ahead (or behind)
                # the remote end (as long as we're not in a detached state)
                if [ ${is_detached} -eq 0 ]; then
                    # parse out the number of commits AHEAD and BEHIND the
                    # remote end (default to 0 if we don't get any output)
                    commit_counts=($("${git}" rev-list --count --left-right HEAD...@{upstream} 2> /dev/null))
                    commits_ahead=0
                    commits_behind=0
                    if [ ! -z "${commit_counts}" ]; then
                        commits_ahead=${commit_counts[0]}
                        commits_behind=${commit_counts[1]}
                    fi

                    # based on the AHEAD and BEHIND values, add blocks onto the
                    # prompt to display this value
                    if [ ${commits_behind} -gt 0 ]; then
                        fgc="100;10;10"
                        bgc="${git_bgc}"
                        __shuggtool_prompt_block "${bgc}" "${fgc}" " -${commits_behind}"
                    fi
                    if [ ${commits_ahead} -gt 0 ]; then
                        fgc="30;75;10"
                        bgc="${git_bgc}"
                        __shuggtool_prompt_block "${bgc}" "${fgc}" " +${commits_ahead}"
                    fi
                fi
            fi

            # format the various changes in the file and add it
            if [ ${__shuggtool_prompt_show_git_repo_diff} -ne 0 ]; then
                blocks_added=$((blocks_added+1))
                # get number of modified files and other stats
                stat="$("${git}" diff --shortstat 2> /dev/null)"
                stat_files="$(echo ${stat} | cut -d "," -f 1 | xargs | cut -d " " -f 1)"
                stat_adds="$(echo ${stat} | cut -d "," -f 2 | xargs | cut -d " " -f 1)"
                stat_dels="$(echo ${stat} | cut -d "," -f 3 | xargs | cut -d " " -f 1)"

                # get number of files that are staged for commit
                stat="$("${git}" diff --shortstat --cached 2> /dev/null)"
                staged_files="$(echo ${stat} | cut -d "," -f 1 | xargs | cut -d " " -f 1)"

                # if at least one statistic is non-empty, we'll add a separator
                if [ ${__shuggtool_prompt_show_git_repo_branch} -ne 0 ] || \
                   [ ${__shuggtool_prompt_show_git_repo_name} -ne 0 ]; then
                    if [ ! -z "${stat_files}" ] || \
                       [ ! -z "${stat_adds}" ] || \
                       [ ! -z "${stat_dels}" ] || \
                       [ ! -z "${staged_files}" ]; then
                    # add a separator between the branch name and stats
                        sep_bgc="${git_bgc}"
                        sep_fgc="0;0;0"
                        __shuggtool_prompt_block "${sep_bgc}" "${sep_fgc}" " ->"
                    fi
                fi

                # add the number of staged files
                if [ ! -z "${staged_files}" ] && [ ${staged_files} -gt 0 ]; then
                    bgc="${git_bgc}"
                    fgc="10;70;50"
                    pfx="$(echo -e "\u2191")"
                    __shuggtool_prompt_block "${bgc}" "${fgc}" " ${pfx}${staged_files}"
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
                    fgc="30;75;10"
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

            # if no blocks were added (due to options being disabled), we'll
            # instead add a single symbol to indicate that we are in a git repo
            if [ ${blocks_added} -eq 0 ]; then
                __shuggtool_prompt_block "${git_bgc}" "0;0;0" " git"
            fi

            # add a final space to the git section
            __shuggtool_prompt_block "${git_bgc}" "0;0;0" " "
        fi
    fi

    # save the captured return value and cmdnum for next iteration
    __shuggtool_prompt_previous_retval=${retval}
    __shuggtool_prompt_previous_cmdnum="${cmdnum}"

    # add a space at the end of the prompt
    PS1="${PS1} "
}
__shuggtool_prompt_command

PROMPT_COMMAND="__shuggtool_prompt_command"

