#!/bin/bash
# Helper function that makes a .vimrc with my custom settings in ~/
#
#   Connor Shugg

# main function
function __shuggtool_vimrc()
{
    vimrc_location=~/.vimrc
    echo -e "Writing to ${c_green}${vimrc_location}${c_none}..."
    
    # custom .vimrc settings
    echo "\" Connor's Vim Settings" > $vimrc_location
    echo "syntax on                               \" syntax highlighting" >> $vimrc_location
    echo "colorscheme desert                      \" modifies color scheme" >> $vimrc_location
    echo "set tabstop=4 shiftwidth=4 expandtab    \" tabs = 4 spaces" >> $vimrc_location
    echo "set autoindent                          \" forces vim to auto-indent" >> $vimrc_location
    echo "set number                              \" displays page numbers" >> $vimrc_location
    echo "au FileType * set formatoptions-=cro    \" disable automatic comment insertion for all file types" >> $vimrc_location

    echo -e "${c_green}${vimrc_location}${c_none} written successfully."
}

__shuggtool_vimrc "$@"
