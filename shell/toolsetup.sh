# Helper script that sets up my various tools.
#
#   Connor Shugg


# ================================= Helpers ================================== #
__shuggtool_toolsetup_print_prefix="+"

# Uniform printing function helper.
function __shuggtool_toolsetup_print_helper()
{
    msg="$1"
    color="$2"

    # create and print the prefix, then pad with spaces
    prefix="${C_LTBLUE}[${color}${__shuggtool_toolsetup_print_prefix}${C_LTBLUE}]${C_NONE} "
    prefix_len=${#__shuggtool_toolsetup_print_prefix}
    prefix_len=$((prefix_len+2))
    max_len=8
    if [ ${prefix_len} -gt ${max_len} ]; then
        max_len=$((prefix_len+1))
    fi
    printf "${prefix}"
    while [ ${prefix_len} -lt ${max_len} ]; do
        printf " "
        prefix_len=$((prefix_len+1))
    done
    
    # print the message
    printf "${msg}\n" "${prefix}"
}

function __shuggtool_toolsetup_print_note()
{
    __shuggtool_toolsetup_print_helper "$1" "${C_NONE}"
}

function __shuggtool_toolsetup_print_good()
{
    __shuggtool_toolsetup_print_helper "$1" "${C_GREEN}"
}

function __shuggtool_toolsetup_print_bad()
{
    __shuggtool_toolsetup_print_helper "$1" "${C_RED}"
}


# =================================== Vim ==================================== #
__shuggtool_toolsetup_vim_theme_name="elflord" # by default, we'll use this theme

# Function that attempts to download and install a vim theme
function __shuggtool_toolsetup_vim_theme()
{
    vim_dir=~/.vim
    theme_repo_url=https://github.com/cwshugg/dwarrowdelf
    theme_repo_dir=${vim_dir}/__shuggtool_vim_theme
    theme_name=dwarrowdelf

    # make the '.vim' directory if it doesn't already exist
    if [ ! -d ${vim_dir} ]; then
        __shuggtool_toolsetup_print_note "Making ${C_YELLOW}${vim_dir}${C_NONE}..."
        mkdir ${vim_dir}
    else
        rm -rf ${theme_repo_dir}
    fi

    # first, we'll attempt to clone a repository containing the theme into our
    # ~/.vim directory
    __shuggtool_toolsetup_print_note "Cloning theme repository: ${C_YELLOW}${theme_repo_url}${C_NONE}..."
    git clone ${theme_repo_url}.git ${theme_repo_dir} > /dev/null 2> /dev/null
    
    # check for the existence of the repo. If it failed, stop trying
    if [ ! -d ${theme_repo_dir} ]; then
        msg="${C_RED}Clone failed.${C_NONE}"
        msg="${msg} Using default theme: ${C_YELLOW}${__shuggtool_toolsetup_vim_theme}${C_NONE}"
        __shuggtool_toolsetup_print_bad "${msg}"
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
        msg="Couldn't find ${C_YELLOW}.vim${C_NONE} file."
        msg="${msg} Using default theme: ${C_YELLOW}${__shuggtool_toolsetup_vim_theme}${C_NONE}"
        __shuggtool_toolsetup_print_bad "${msg}"
        return
    fi

    # copy the color file into the vim color subdirectory, and update the
    # global color variable
    cp ${color_file} ${vim_color_dir}/${theme_name}.vim
    __shuggtool_toolsetup_vim_theme_name="${theme_name}"
    
    # once finished, remove the repository directory
    rm -rf ${theme_repo_dir}
}

# Helper function used to load any plugins I've created or use.
function __shuggtool_toolsetup_vim_plugins()
{
    # in the shuggtools home directory there's a 'vim/' directory containing
    # plugins I've written. We'll locate it and copy import/read statements
    # into the vimrc
    vim_plugin_src=${sthome}/vim/plugin
    vim_plugin_dst=~/.vim/plugin

    # make the directory if it doesn't exist
    if [ ! -d ${vim_plugin_dst} ]; then
        mkdir ${vim_plugin_dst}
    fi

    __shuggtool_toolsetup_print_note "Installing my plugins and vim scripts..."
    pcount=0
    for fpath in ${vim_plugin_src}/*.vim; do
        # if for some reason we're not looking at a file, skip it
        if [ ! -f ${fpath} ]; then
            continue
        fi
        
        # copy the vim file into the correct directory
        fname=shuggtool_$(basename ${fpath})
        cp ${fpath} ${vim_plugin_dst}/${fname}

        __shuggtool_toolsetup_print_good "${STAB_TREE2}copied ${C_GREEN}${fname}${C_NONE}."
        pcount=$((pcount+1))
    done
    __shuggtool_toolsetup_print_good "${STAB_TREE1}copied ${pcount} plugins from ${C_LTBLUE}${vim_plugin_src}${C_NONE}."
}

# Helper function that installs vundle, a vim plugin manager.
function __shuggtool_toolsetup_vim_vundle()
{
    vundle_url="https://github.com/VundleVim/Vundle.vim"
    vundle_dst=~/.vim/bundle
    vundle_name=Vundle.vim

    # make the directory if it doesn't exist
    if [ ! -d ${vundle_dst} ]; then
        mkdir ${vundle_dst}
    fi
    
    # clone the git repo into the correct directory (delete and re-clone if
    # necessary)
    vundle_dir=${vundle_dst}/${vundle_name}
    if [ -d ${vundle_dir} ]; then
        rm -rf ${vundle_dir}
    fi
    __shuggtool_toolsetup_print_note "Installing vundle to ${C_LTBLUE}${vundle_dir}${C_NONE}..."
    git clone ${vundle_url} ${vundle_dir} > /dev/null 2> /dev/null

    # check that the directory has been filled up with files from vundle
    if [ ! -z "$(ls ${vundle_dir})" ]; then
        msg="Vundle installed. Run vim and execute the ${C_YELLOW}:PluginInstall${C_NONE}"
        msg="${msg} command to install the plugins defined in your .vimrc."
        __shuggtool_toolsetup_print_good "${msg}"
    else
        __shuggtool_toolsetup_print_bad "${C_RED}failure${C_NONE}"
    fi
}

# main function
function __shuggtool_toolsetup_vim()
{
    # first, try to install a theme
    __shuggtool_toolsetup_vim_theme
    
    vimrc_location=~/.vimrc
    vimrc_source=${sthome}/vim/vimrc.vim
    __shuggtool_toolsetup_print_note "Installing .vimrc to ${C_LTBLUE}${vimrc_location}${C_NONE}..."

    # copy the vimrc file to the correct location
    if [ ! -f ${vimrc_source} ]; then
        __shuggtool_toolsetup_print_bad "couldn't find source vimrc at ${C_LTBLUE}${vimrc_source}${C_NONE}"
    else
        cp ${vimrc_source} ${vimrc_location}
    fi
    __shuggtool_toolsetup_print_good "Installed .vimrc successfully."
    
    # next we'll install any plugins we have
    __shuggtool_toolsetup_vim_plugins
    __shuggtool_toolsetup_vim_vundle
}


# =================================== Tmux =================================== #
# Installs my tmux config file.
function __shuggtool_toolsetup_tmux()
{
    config_src=${sthome}/tmux/tmux.conf
    config_dst=~/.tmux.conf

    __shuggtool_toolsetup_print_note "Writing to ${C_GREEN}${config_dst}${C_NONE}..."
    cp ${config_src} ${config_dst}
    
    __shuggtool_toolsetup_print_good "${C_GREEN}${config_dst}${C_NONE} written successfully."
}


# =================================== GDB ==================================== #
# Helper function used to load any plugins I've created or use.
function __shuggtool_toolsetup_gdb()
{
    # in the shuggtools home directory there's a 'gdb/' directory containing
    # my .gdbinit file. We'll locate it and copy it over.
    gdbinit_src=${sthome}/gdb/.gdbinit
    gdbinit_dest=~/.gdbinit

    __shuggtool_toolsetup_print_note "Installing GDB init file to ${C_LTBLUE}${gdbinit_dest}${C_NONE}"
    cp ${gdbinit_src} ${gdbinit_dest}
    __shuggtool_toolsetup_print_good "${C_GREEN}Installation successful.${C_NONE}"
}


# ============================ Bat (Colored Cat) ============================= #
# Forks and installs the 'bat' utility to replace the standard 'cat'.
function __shuggtool_toolsetup_cat()
{
    repo_url="https://github.com/sharkdp/bat"

    # look for 'bat' or 'batcat'
    __shuggtool_toolsetup_print_note "Looking for ${C_YELLOW}bat${C_NONE}... "
    binary="$(which bat 2> /dev/null)"
    binary2="$(which batcat 2> /dev/null)"
    if [ ! -z "${binary}" ] || [ ! -z "${binary2}" ]; then
        __shuggtool_toolsetup_print_good "${C_GREEN}already installed.${C_NONE}"
        __shuggtool_toolsetup_print_good "Try running ${C_YELLOW}bat${C_NONE} or ${C_YELLOW}batcat${C_NONE}."
        return
    fi
    __shuggtool_toolsetup_print_note "${C_RED}not installed.${C_NONE}"
    
    # determine if we have user permissions
    __shuggtool_prompt_yesno "Do you have ${C_YELLOW}sudo${C_NONE} permissions?"
    yes=$?
    if [ ${yes} -ne 0 ]; then
        __shuggtool_toolsetup_print_note "Installing ${C_YELLOW}bat${C_NONE} via apt-get."
        sudo apt install bat
        return
    fi

    # if we don't have sudo permissions, tell the user how to install it
    __shuggtool_toolsetup_print_bad "Since you don't have ${C_YELLOW}sudo${C_NONE} permissions," \
            "you'll need to install ${C_YELLOW}bat${C_NONE} manually."
    __shuggtool_toolsetup_print_bad "Head to ${C_LTBLUE}${repo_url}${C_NONE} and download a release or build it from source."
}




# =================================== Main =================================== #
function __shuggtool_toolsetup()
{
    __shuggtool_toolsetup_print_prefix="VIM"
    __shuggtool_toolsetup_vim
    echo ""

    __shuggtool_toolsetup_print_prefix="TMUX"
    __shuggtool_toolsetup_tmux
    echo ""

    __shuggtool_toolsetup_print_prefix="GDB"
    __shuggtool_toolsetup_gdb
    echo ""

    __shuggtool_toolsetup_print_prefix="CAT"
    __shuggtool_toolsetup_cat
}

__shuggtool_toolsetup "$@"

