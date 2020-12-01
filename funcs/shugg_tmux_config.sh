source /home/snowmiser/shuggtools/globals.sh
# Helper function that makes ~/.tmux.conf and applies settings to it
#
#   Connor Shugg

# main function
function __shuggtool_tmux_config()
{
    config_location=~/.tmux.conf
    echo -e "Writing to ${c_green}${config_location}${c_none}..."
    
    # custom tmux settings
    echo "# Connor's tmux settings" > $config_location
    echo "# enable tmux window colors" >> $config_location
    echo "set -g default-terminal \"screen-256color\"" >> $config_location

    echo -e "${c_green}${config_location}${c_none} written successfully."
}

__shuggtool_tmux_config "$@"
