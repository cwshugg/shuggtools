# Helper function that makes a .vimrc with my custom settings in ~/
#
#   Connor Shugg

__shuggtool_vimsetup_theme_name="elflord" # by default, we'll use this theme

# Function that attempts to download and install a vim theme
function __shuggtool_vimsetup_theme()
{
    vim_dir=~/.vim
    theme_repo_url=https://github.com/cwshugg/dwarrowdelf
    theme_repo_dir=${vim_dir}/__shuggtool_vim_theme
    theme_name=dwarrowdelf

    # make the '.vim' directory if it doesn't already exist
    if [ ! -d ${vim_dir} ]; then
        echo -e "Making ${C_YELLOW}${vim_dir}${C_NONE}..."
        mkdir ${vim_dir}
    else
        rm -rf ${theme_repo_dir}
    fi

    # first, we'll attempt to clone a repository containing the theme into our
    # ~/.vim directory
    echo -e "Cloning theme repository: ${C_YELLOW}${theme_repo_url}${C_NONE}..."
    git clone ${theme_repo_url}.git ${theme_repo_dir} > /dev/null 2> /dev/null
    
    # check for the existence of the repo. If it failed, stop trying
    if [ ! -d ${theme_repo_dir} ]; then
        echo -en "${C_RED}Clone failed.${C_NONE} "
        echo -e "Using default theme: ${C_YELLOW}${__shuggtool_vimsetup_theme}${C_NONE}"
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
        echo -en "Couldn't find ${C_YELLOW}.vim${C_NONE} file. "
        echo -e "Using default theme: ${C_YELLOW}${__shuggtool_vimsetup_theme}${C_NONE}"
        return
    fi

    # copy the color file into the vim color subdirectory, and update the
    # global color variable
    cp ${color_file} ${vim_color_dir}/${theme_name}.vim
    __shuggtool_vimsetup_theme_name="${theme_name}"
    
    # once finished, remove the repository directory
    rm -rf ${theme_repo_dir}
}

# Helper function used to load any plugins I've created or use.
function __shuggtool_vimsetup_plugins()
{
    # in the shuggtools home directory there's a 'vim/' directory containing
    # plugins I've written. We'll locate it and copy import/read statements
    # into the vimrc

    vimrc_path=$1
    vim_plugin_src=${sthome}/vim
    vim_plugin_dst=~/.vim/plugin

    # make the directory if it doesn't exist
    if [ ! -d ${vim_plugin_dst} ]; then
        mkdir ${vim_plugin_dst}
    fi

    echo -e "Installing plugins and vim scripts..."
    pcount=0
    for fpath in ${vim_plugin_src}/*.vim; do
        # if for some reason we're not looking at a file, skip it
        if [ ! -f ${fpath} ]; then
            continue
        fi
        
        # copy the vim file into the correct directory
        fname=shuggtool_$(basename ${fpath})
        cp ${fpath} ${vim_plugin_dst}/${fname}

        echo -e "${STAB_TREE2}copied ${C_GREEN}${fname}${C_NONE}."
        pcount=$((pcount+1))
    done
    echo -e "${STAB_TREE1}copied ${pcount} plugins from ${C_LTBLUE}${vim_plugin_src}${C_NONE}."
}

# main function
function __shuggtool_vimsetup()
{
    # first, try to install a theme
    __shuggtool_vimsetup_theme
    
    vimrc_location=~/.vimrc
    echo -en "Writing to ${C_LTBLUE}${vimrc_location}${C_NONE}... "

    # create an array of lines to dump into the file
    lines=("\" ----- general settings" \
        "syntax on                               \" syntax highlighting" \
        "colorscheme ${__shuggtool_vimsetup_theme_name} \" modifies color scheme" \
        "set tabstop=4 shiftwidth=4 expandtab    \" tabs = 4 spaces" \
        "set softtabstop=4                       \" enables backspace to clear out 4 spaces" \
        "set autoindent                          \" forces vim to auto-indent" \
        "set smartindent                         \" smart indentation - helps with backspace" \
        "set number                              \" displays page numbers" \
        "au FileType * set formatoptions-=cro    \" disable automatic comment insertion for all file types" \
        "set undolevels=1000                     \" LOTS of undos available" \
        "\n\"----- line/column highlighting" \
        "set cursorline                          \" highlight current line cursor is on" \
        "set cursorcolumn                        \" highlight current column cursor is on" \
        "\n\" ----- search settings" \
        "set hlsearch                            \" highlight search results" \
        "set is                                  \" highlight searches as you type" \
        "\n\" ----- gvim settings" \
        "if has('gui_running')" \
        "    set guifont=Consolas:h11            \" set gvim font" \
        "    set guioptions -=m                  \" remove menu bar" \
        "    set guioptions -=T                  \" remove toolbar" \
        "endif" \
        "\n\" ----- the below shortcut allows you to press space to clear highlighted search terms" \
        "\" ----- thanks to: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches" \
        "nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>"
        ""
    )

    # loop through each line in the array and write it out to the file
    echo "\" Connor's Vim Settings\n" > ${vimrc_location}
    for ((i=0; i<${#lines[@]}; i++)); do
        echo -e "${lines[${i}]}" >> ${vimrc_location}
    done

    echo -e "${C_GREEN}success${C_NONE}."
    
    # next we'll install any plugins we have
    __shuggtool_vimsetup_plugins ${vimrc_location}
}

__shuggtool_vimsetup "$@"

