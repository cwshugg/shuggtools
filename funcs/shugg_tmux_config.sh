# Helper function that makes ~/.tmux.conf and applies settings to it
#
#   Connor Shugg

# main function
function __shuggtool_tmux_config()
{
    config_location=~/.tmux.conf
    echo -e "Writing to ${c_green}${config_location}${c_none}..."
    
    # based on the username, decide what color to use
    status_bg_color="colour18"  # dark blue
    status_fg_color="colour172" # yellow
    pane_active_color="${status_fg_color}"
    pane_inactive_color="${status_bg_color}"

    # special case for root
    username=$(whoami)
    if [[ "$username" == "root" ]]; then
        status_bg_color="colour235" # dark gray
        status_fg_color="colour46"  # green
        pane_active_color="${status_fg_color}"
        pane_inactive_color="${status_bg_color}"
    fi

    # custom tmux settings
    echo "# Connor's tmux settings"                     > $config_location
    echo "# enable tmux window colors"                  >> $config_location
    echo "set -g default-terminal \"screen-256color\""  >> $config_location
    echo "# set status bar color"                       >> $config_location
    echo "set -g status-bg ${status_bg_color}"          >> $config_location
    echo "set -g status-fg ${status_fg_color}"          >> $config_location
    echo "# set pane divider colors"                    >> $config_location
    echo "set -g pane-border-style fg=${pane_inactive_color}" >> $config_location
    echo "set -g pane-active-border-style fg=${pane_active_color}" >> $config_location

    echo -e "${c_green}${config_location}${c_none} written successfully."
}

__shuggtool_tmux_config "$@"
