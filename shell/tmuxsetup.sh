# Helper function that makes ~/.tmux.conf and applies settings to it
#
#   Connor Shugg

# main function
function __shuggtool_tmux_config()
{
    config_src=${sthome}/tmux/tmux.conf
    config_dst=~/.tmux.conf

    echo -e "Writing to ${C_GREEN}${config_dst}${C_NONE}..."
    cp ${config_src} ${config_dst}
    
    echo -e "${C_GREEN}${config_dst}${C_NONE} written successfully."
}

__shuggtool_tmux_config "$@"

