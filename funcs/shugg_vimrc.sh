source /home/ugrads/nonmajors/cwshugg/personal/shuggtools/globals.sh
#!/bin/bash
# Helper function that makes a .vimrc with my custom settings in ~/
#
#   Connor Shugg

function __shuggtool_vimrc()
{
    vimrc_location=~/.vimrc
    echo -e "Writing to ${c_green}${vimrc_location}${c_white}..."
    
    # custom .vimrc settings
    echo "\" Connor's Vim Settings" > ~/.vimrc
    echo "syntax on                               \" syntax highlighting" >> ~/.vimrc
    echo "colorscheme desert                      \" modifies color scheme" >> ~/.vimrc
    echo "set tabstop=4 shiftwidth=4 expandtab    \" tabs = 4 spaces" >> ~/.vimrc
    echo "set autoindent                          \" forces vim to auto-indent" >> ~/.vimrc
    echo "set number                              \" displays page numbers" >> ~/.vimrc
    echo "au FileType * set formatoptions-=cro    \" disable automatic comment insertion for all file types" >> ~/.vimrc

    echo -e "${c_green}${vimrc_location}${c_white} written successfully."
}

__shuggtool_vimrc "$@"
