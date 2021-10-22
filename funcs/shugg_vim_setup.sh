# Helper function that makes a .vimrc with my custom settings in ~/
#
#   Connor Shugg

__shuggtool_vimrc_theme_name="desert"

# Function that attempts to download and install a vim theme
function __shuggtool_vimrc_theme()
{
    vim_dir=~/.vim
    theme_repo_url=https://github.com/agude/vim-eldar
    theme_repo_dir=${vim_dir}/__shuggtool_vim_theme

    # make the '.vim' directory if it doesn't already exist
    if [ ! -d ${vim_dir} ]; then
        echo -e "Making ${c_yellow}${vim_dir}${c_none}..."
        mkdir ${vim_dir}
    else
        rm -rf ${theme_repo_dir}
    fi

    # first, we'll attempt to clone a repository containing the 'Eldar' theme
    # into our ~/.vim directory
    echo -e "Cloning theme repository: ${c_yellow}${theme_repo_url}${c_none}..."
    git clone ${theme_repo_url}.git ${theme_repo_dir} > /dev/null 2> /dev/null
    
    # check for the existence of the repo. If it failed, stop trying
    if [ ! -d ${theme_repo_dir} ]; then
        echo -en "${c_red}Clone failed.${c_none} "
        echo -e "Using default theme: ${c_yellow}${__shuggtool_vimrc_theme}${c_none}"
        return
    fi

    # if the 'colors' subdirectory doesn't exist in ~/.vim, make it
    vim_color_dir=${vim_dir}/colors
    if [ ! -d ${vim_color_dir} ]; then
        mkdir ${vim_color_dir}
    fi
    
    # locate the '.vim' file
    color_file=$(find ${theme_repo_dir} -name "*.vim" | head -n 1)
    if [ -z ${color_file} ]; then
        echo -en "Couldn't find ${c_yellow}.vim${c_none} file. "
        echo -e "Using default theme: ${c_yellow}${__shuggtool_vimrc_theme}${c_none}"
        return
    fi

    # copy the color file into the vim color subdirectory, and update the
    # global color variable
    cp ${color_file} ${vim_color_dir}/shugg.vim
    __shuggtool_vimrc_theme_name="shugg"
    
    # once finished, remove the repository directory
    rm -rf ${theme_repo_dir}
}

# main function
function __shuggtool_vimrc()
{
    # first, try to install a theme
    __shuggtool_vimrc_theme

    vimrc_location=~/.vimrc
    echo -e "Writing to ${c_green}${vimrc_location}${c_none}..."
    
    # custom .vimrc settings
    echo "\" Connor's Vim Settings" > $vimrc_location
    echo "syntax on                               \" syntax highlighting" >> $vimrc_location
    echo "colorscheme ${__shuggtool_vimrc_theme_name} \" modifies color scheme" >> $vimrc_location
    echo "set tabstop=4 shiftwidth=4 expandtab    \" tabs = 4 spaces" >> $vimrc_location
    echo "set autoindent                          \" forces vim to auto-indent" >> $vimrc_location
    echo "set number                              \" displays page numbers" >> $vimrc_location
    echo "au FileType * set formatoptions-=cro    \" disable automatic comment insertion for all file types" >> $vimrc_location

    echo -e "${c_green}${vimrc_location}${c_none} written successfully."
}

__shuggtool_vimrc "$@"
