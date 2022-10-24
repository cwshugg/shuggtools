# Tmux Shared window. Used to create a shared window through /tmp/.
#
#   Connor Shugg

# main function
function __shuggtool_tmux_shared_new()
{
    # generate a default name for the shared socket
    socket=$(whoami)_tmux_shared_socket
    junk_length=10
    junk=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c $junk_length)
    socket=${socket}_${junk}

    # check for a command-line argument
    if [ $# -ge 1 ]; then
        socket=$1
    fi

    # attempt to create the tmux session in /tmp
    # ('-d' tells tmux to start the session detatched)
    tmux -S /tmp/$socket new-session -d -s $socket
    
    # send a command up to print out info for the onlookers
    comm1="clear; clear; echo 'Onlookers can attach via:';"
    comm2="echo '-------------------------';"
    comm3="echo 'tmux -S /tmp/$socket attach-session -t $socket';"
    comm4="echo '-------------------------';"
    comm5="echo '(Add -r to make it read-only)';"
    tmux -S /tmp/$socket send-keys -t $socket \
         "$comm1 $comm2 $comm3 $comm4 $comm5 " ENTER

    # update the permissions on the socket to allow onlookers
    chmod 777 /tmp/$socket

    # attach to the socket
    tmux -S /tmp/$socket attach-session -t $socket
}

# pass all args to main function
__shuggtool_tmux_shared_new "$@"

