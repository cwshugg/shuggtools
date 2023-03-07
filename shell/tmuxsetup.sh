# Helper function that makes ~/.tmux.conf and applies settings to it
#
#   Connor Shugg

# main function
function __shuggtool_tmux_config()
{
    config_location=~/.tmux.conf
    echo -e "Writing to ${C_GREEN}${config_location}${C_NONE}..."
    
    status_bg_color="colour235" # dark gray
    status_fg_color="colour46"  # green
    pane_active_color="${status_fg_color}"
    pane_inactive_color="${status_bg_color}"

    # custom tmux settings
    echo "# Connor's tmux settings"                     > $config_location
    echo "# enable tmux window colors"                  >> $config_location
    echo "set -g default-terminal \"screen-256color\""  >> $config_location
    echo "set -g terminal-overrides \",*256col*:RGB\""  >> $config_location
    echo "# set status bar color"                       >> $config_location
    echo "set -g status-bg ${status_bg_color}"          >> $config_location
    echo "set -g status-fg ${status_fg_color}"          >> $config_location
    echo "# set pane divider colors"                    >> $config_location
    echo "set -g pane-border-style fg=${pane_inactive_color}" >> $config_location
    echo "set -g pane-active-border-style fg=${pane_active_color}" >> $config_location
    echo "# force window name format"                   >> $config_location
    echo "set -g pane-border-format \"#{pane_index} #{pane_current_command}\"" >> $config_location
    echo "set -g allow-rename off"                 >> $config_location
    echo "# use vim key bindings"                       >> $config_location
    echo "set-window-option -g mode-keys vi"            >> $config_location
    echo "bind-key -t vi-copy \"v\" begin-selection"    >> $config_location
    echo "bind-key -t vi-copy \"y\" copy-selection"     >> $config_location
    
    #echo "set -g visual-activity on" >> $config_location
    #echo "setw -g monitor-activity on" >> $config_location
    #echo "set-window-option -g visual-bell on" >> $config_location

    echo -e "${C_GREEN}${config_location}${C_NONE} written successfully."
}

__shuggtool_tmux_config "$@"

