source /home/ugrads/nonmajors/cwshugg/personal/shuggtools/globals.sh
#!/bin/bash
# Smite: takes in either a process name or PID and attempts to send the SIGKILL
# signal to it.
#
#   Connor Shugg

# source global definitions

function __shuggtool_smite
{
    # don't-kill list: processes NOT to kill, even if given as input (useful
    # for when I goof up and accidentally kill my tmux process)
    declare -a nokills=(
        "tmux: server"
    )

    # ------------- Variable/Argument Setup ------------- #
    # make sure at least one argument was given
    if [ $# -lt 1 ]; then
        echo -e "${c_yellow}Usage: smite <PID/PName>${c_none}"
        return
    fi

    # variable setup
    process=$1          # input param 1
    pname=""            # found process name
    pid=""              # found PID
    kill_result=""      # any error messages from calling 'kill'

    # ---------------- Process Searching ---------------- #
    # use regex to look for an integer (PID)
    pid_regex="^[0-9]+$"
    if [[ $process =~ $pid_regex ]]; then
        # ------ PID Approach ------- #
        pid=$process
        pname=$(ps -p $process -o "%c" --no-headers)
    else
        # ----- PName Approach ------ #
        # get the correct process name and kill the process
        pid=$(pgrep -x "$process" | head -n 1)
        if [ ! -z "$pid" ]; then
            pname=$(ps -p $pid -o "%c" --no-headers);
        fi
    fi

    # if the PID wasn't set, print error and exit
    if [ -z "$pid" ]; then
        echo -e "${c_yellow}The process thou wishes to smite was not found."
        echo -e "${c_yellow}(The process name must be an exact match)${c_none}"
        return
    fi

    # search the don't-kill list
    for name in "${nokills[@]}"
    do
        # if the name matches the current process name, don't kill it!
        if [ "$pname" == "$name" ]; then
            echo -e "${c_yellow}The process thou wishes to smite is on the no-smite list.${c_none}"
            return
        fi
    done

    # ------------ Killing and Finalization ------------- #
    # otherwise, invoke 'kill' and capture any error messages
    kill_result=$(kill -9 $pid 2>&1)    # '2>&1' = pipe stderr --> stdout

    # if the kill command worked, no output should be produced
    if [ -z "$kill_result" ]; then
        # if it was a success, print the smite message
        echo -e "${c_yellow}        ,/"
        echo -e "${c_yellow}      ,'/"
        echo -e "${c_yellow}    ,' /"
        echo -e "${c_yellow}  ,'  /_____,   ${c_cyan} Thou art smitten,"
        echo -e "${c_yellow}.'____    ,'    ${c_cyan} $pname"
        echo -e "${c_yellow}     /  ,'"
        echo -e "${c_yellow}    / ,'"
        echo -e "${c_yellow}   /,'"
        echo -e "${c_yellow}  /'${c_none}"
    else
        # otherwise, SOMETHING was printed after the kill command. Print it out
        echo -e "${c_yellow}Smiting not possible:"
        echo -e "${c_yellow}$kill_result${c_none}"
    fi
}

__shuggtool_smite "$@"
