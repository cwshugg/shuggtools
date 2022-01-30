# Helper function that makes a .vimrc with my custom settings in ~/
#
#   Connor Shugg

__shuggtool_vimrc_theme_name="desert" # by default, we'll use this theme

# Function that attempts to download and install a vim theme
function __shuggtool_vimrc_theme()
{
    vim_dir=~/.vim
    theme_repo_url=https://github.com/cwshugg/dwarrowdelf
    theme_repo_dir=${vim_dir}/__shuggtool_vim_theme
    theme_name=dwarrowdelf

    # make the '.vim' directory if it doesn't already exist
    if [ ! -d ${vim_dir} ]; then
        echo -e "Making ${c_yellow}${vim_dir}${c_none}..."
        mkdir ${vim_dir}
    else
        rm -rf ${theme_repo_dir}
    fi

    # first, we'll attempt to clone a repository containing the theme into our
    # ~/.vim directory
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
    cp ${color_file} ${vim_color_dir}/${theme_name}.vim
    __shuggtool_vimrc_theme_name="${theme_name}"
    
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
    echo -e "\" Connor's Vim Settings\n" \
            "syntax on                               \" syntax highlighting\n" \
            "colorscheme ${__shuggtool_vimrc_theme_name} \" modifies color scheme\n" \
            "set tabstop=4 shiftwidth=4 expandtab    \" tabs = 4 spaces\n" \
            "set autoindent                          \" forces vim to auto-indent\n" \
            "set number                              \" displays page numbers\n" \
            "au FileType * set formatoptions-=cro    \" disable automatic comment insertion for all file types\n" \
            "set undolevels=1000                     \" LOTS of undos available\n" \
            "\n" \
            "\" line/column highlighting\n" \
            "set cursorline                          \" highlight current line cursor is on\n" \
            "set cursorcolumn                        \" highlight current column cursor is on\n" \
            "\n" \
            "\" search settings\n" \
            "set hlsearch                            \" highlight search results\n" \
            "set is                                  \" highlight searches as you type\n" \
            "\" the below shortcut allows you to press space to clear highlighted search terms\n" \
            "\" thanks to: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches\n" \
            "nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>\n" \
            "" > ${vimrc_location}

    echo -e "${c_green}${vimrc_location}${c_none} written successfully."
}

__shuggtool_vimrc "$@"

