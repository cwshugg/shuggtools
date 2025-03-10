# Tmux Shared window. Used to create a shared window through /tmp/.
#
#   Connor Shugg

# Help menu
function __shuggtool_tmux_shared_usage()
{
    echo "tmux-shared: launch a tmux session that's viewable by others."
    echo "Usage: $0 [options]"
    echo "Invocation arguments:"
    echo "---------------------------------------------------------------------"
    echo " -h       Displays this menu."
    echo " -p       Sets the file path at which the tmux socket will be stored."
    echo "          (By default, it's stored in /tmp."
    echo " -n       Sets the name of the tmux session."
    echo "---------------------------------------------------------------------"
}

# Generates a random alphanumeric string, given an optional length.
function __shuggtool_tmux_shared_generate_junk()
{
    junk_length=10
    if [ $# -gt 0 ]; then
        junk_length=$1
    fi

    junk="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c ${junk_length})"
    echo -n "${junk}"
}

# Main function
function __shuggtool_tmux_shared()
{
    socket_path=""
    session_name=""

    # parse command-line arguments
    while getopts "hp:n:" opt; do
        case ${opt} in
            h)
                __shuggtool_tmux_shared_usage
                return 0
                ;;
            p)
                socket_path="${OPTARG}"
                ;;
            n)
                session_name="${OPTARG}"
                ;;
            *)
                __shuggtool_tmux_shared_usage
                return 0
                ;;
        esac
    done

    # if a socket path was NOT provided, generate a random one within /tmp
    if [ -z "${socket_path}" ]; then
        # generate some random junk to append to the end of the name
        junk="$(__shuggtool_tmux_shared_generate_junk 8)"
        socket_name="$(whoami)_tmux_shared_socket_${junk}"
        socket_path="/tmp/${socket_name}"
    fi

    # if a session name was NOT provided, generate one
    if [ -z "${session_name}" ]; then
        # generate random junk to append to the end of the name
        junk="$(__shuggtool_tmux_shared_generate_junk 8)"
        session_name="$(whoami)_${junk}"
    fi

    # create the tmux session
    #   -S tells tmux where to place the socket
    #   -d tels tmux to start the session detached
    #   -s tells tmux the name of the socket
    tmux -S "${socket_path}" new-session -d -s "${session_name}"
    
    # send commands to the session to help kick things off
    cmds=""
    cmds="${cmds} clear; clear;"
    cmds="${cmds} echo -e \"Shared your tmux session by having others run this command:\n\";"
    cmds="${cmds} echo -e \"${STAB}${C_BLUE}tmux -S ${socket_path} attach-session -t ${session_name}${C_NONE}\n\";"
    cmds="${cmds} echo -e \"If you don't want to let them type commands or interact, add ${C_BLUE}-r${C_NONE}.\";"
    tmux -S "${socket_path}" send-keys -t "${session_name}" "${cmds} " ENTER

    # update the permissions on the socket to allow onlookers
    chmod 777 "${socket_path}"

    # attach to the socket
    tmux -S "${socket_path}" attach-session -t "${session_name}"
}

# pass all args to main function
__shuggtool_tmux_shared "$@"

