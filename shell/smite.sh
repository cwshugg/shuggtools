# Smite: takes in either a process name or PID and attempts to send the SIGKILL
# signal to it. Useful for being too lazy to explicitly call 'kill' or 'pkill'
#
#   Connor Shugg

# main function
function __shuggtool_smite
{
    # don't-kill list: processes NOT to kill, even if given as input (useful
    # for when I goof up and accidentally kill my tmux process)
    declare -a nokills=(
        "tmux: server"
        "bash"
    )

    # ------------- Variable/Argument Setup ------------- #
    # make sure at least one argument was given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "smite${C_NONE} must be invoked with: ${C_YELLOW}smite <PID/PName>${C_NONE}"
#        echo -e "${C_YELLOW}Usage: smite <PID/PName>${C_NONE}"
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
        echo -e "${C_YELLOW}The process thou wishes to smite was not found."
        echo -e "${C_YELLOW}(The process name must be an exact match)${C_NONE}"
        return
    fi

    # search the don't-kill list
    for name in "${nokills[@]}"
    do
        # if the name matches the current process name, don't kill it!
        if [ "$pname" == "$name" ]; then
            echo -e "${C_YELLOW}The process thou wishes to smite is on the no-smite list.${C_NONE}"
            return
        fi
    done

    # ------------ Killing and Finalization ------------- #
    # otherwise, invoke 'kill' and capture any error messages
    kill_result=$(kill -9 $pid 2>&1)    # '2>&1' = pipe stderr --> stdout

    # if the kill command worked, no output should be produced
    if [ -z "$kill_result" ]; then
        # if it was a success, print the smite message
        echo -e "${C_YELLOW}        ,/"
        echo -e "${C_YELLOW}      ,'/"
        echo -e "${C_YELLOW}    ,' /"
        echo -e "${C_YELLOW}  ,'  /_____,   ${C_CYAN} Thou art smitten,"
        echo -e "${C_YELLOW}.'____    ,'    ${C_CYAN} $pname"
        echo -e "${C_YELLOW}     /  ,'"
        echo -e "${C_YELLOW}    / ,'"
        echo -e "${C_YELLOW}   /,'"
        echo -e "${C_YELLOW}  /'${C_NONE}"
    else
        # otherwise, SOMETHING was printed after the kill command. Print it out
        echo -e "${C_YELLOW}Smiting not possible:"
        echo -e "${C_YELLOW}$kill_result${C_NONE}"
    fi
}

__shuggtool_smite "$@"
