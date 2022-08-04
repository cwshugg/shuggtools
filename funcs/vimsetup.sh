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
        /bin/rm -rf ${theme_repo_dir}
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
    /bin/rm -rf ${theme_repo_dir}
}

# Helper function used to load any plugins I've created or use.
function __shuggtool_vimsetup_plugins()
{
    # in the shuggtools home directory there's a 'vim/' directory containing
    # plugins I've written. We'll locate it and copy import/read statements
    # into the vimrc

    vimrc_path=$1
    vim_plugin_src=${sthome}/vim/plugin
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
    vimrc_source=${sthome}/vim/vimrc.vim
    echo -en "Copying to ${C_LTBLUE}${vimrc_location}${C_NONE}... "

    # copy the vimrc file to the correct location
    if [ ! -f ${vimrc_source} ]; then
        __shuggtool_print_error "couldn't find source vimrc at ${C_LTBLUE}${vimrc_source}${C_NONE}"
    else
        cp ${vimrc_source} ${vimrc_location}
    fi

    echo -e "${C_GREEN}success${C_NONE}."
    
    # next we'll install any plugins we have
    __shuggtool_vimsetup_plugins ${vimrc_location}
}

__shuggtool_vimsetup "$@"

