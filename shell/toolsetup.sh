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

    # optional argument: a prefix string
    prefix_str="•"
    if [ $# -ge 3 ]; then
        prefix_str="$3"
    fi

    # create and print the prefix, then pad with spaces
    prefix="${color}${prefix_str}${C_NONE} ${C_DKGRAY}${__shuggtool_toolsetup_print_prefix}${C_NONE} "
    prefix_len=${#__shuggtool_toolsetup_print_prefix}
    prefix_len=$((prefix_len+2))
    max_len=12
    
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

function __shuggtool_toolsetup_print_alert()
{
    __shuggtool_toolsetup_print_helper "$1" "${C_PURPLE}"
}

function __shuggtool_toolsetup_print_question()
{
    __shuggtool_toolsetup_print_helper "$1" "${C_LTRED}" "?"
}

__shuggtool_toolsetup_prompt_result=""
function __shuggtool_toolsetup_prompt()
{
    # print the question/message
    msg="$1"
    __shuggtool_toolsetup_print_question "${msg}"

    # read input until a non-blank answer is given
    text=""
    while [ -z "${text}" ]; do
        echo -en "${C_DKGRAY}>${C_NONE} ${C_YELLOW}"
        text="$(__shuggtool_read_input)"
        echo -en "${C_NONE}"
    done

    __shuggtool_toolsetup_prompt_result="${text}"
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
        mkdir ${vim_dir}
        __shuggtool_toolsetup_print_note "Created ${C_YELLOW}${vim_dir}${C_NONE}."
    else
        rm -rf ${theme_repo_dir}
    fi

    # first, we'll attempt to clone a repository containing the theme into our
    # ~/.vim directory
    git clone ${theme_repo_url}.git ${theme_repo_dir} > /dev/null 2> /dev/null
    
    # check for the existence of the repo. If it failed, stop trying
    if [ ! -d ${theme_repo_dir} ]; then
        msg="Failed to clone theme from repository: ${C_YELLOW}${theme_repo_dir}${C_NONE}."
        __shuggtool_toolsetup_print_bad "${msg}"
        return
    fi

    # if the 'colors' subdirectory doesn't exist in ~/.vim, make it
    vim_color_dir=${vim_dir}/colors
    if [ ! -d ${vim_color_dir} ]; then
        mkdir ${vim_color_dir}
    fi
    
    # locate the '.vim' file
    color_file=$(find ${theme_repo_dir} -name "*.vim" | grep -v "airline" | head -n 1)
    if [ -z ${color_file} ]; then
        msg="Failed to find theme ${C_YELLOW}.vim${C_NONE} file."
        __shuggtool_toolsetup_print_bad "${msg}"
        return
    fi

    # copy the color file into the vim color subdirectory, and update the
    # global color variable
    theme_dst=${vim_color_dir}/${theme_name}.vim
    cp ${color_file} ${theme_dst}
    __shuggtool_toolsetup_vim_theme_name="${theme_name}"
    __shuggtool_toolsetup_print_note "Theme repository: ${C_YELLOW}${theme_repo_url}${C_NONE}."
    __shuggtool_toolsetup_print_good "Installed ${theme_name} theme at: ${C_LTBLUE}${theme_dst}${C_NONE}."

    # look for an airline vim theme
    airline_file=$(find ${theme_repo_dir} -name "*airline*.vim" | head -n 1)
    if [ -z "${airline_file}" ] || [ ! -f "${airline_file}" ]; then
        __shuggtool_toolsetup_print_bad "Failed to find airline theme ${C_YELLOW}.vim${C_NONE} file."
    else
        # look for the existence of the vim-airline-themes directory into which
        # we can copy the file
        #airline_theme_dir=${vim_dir}/bundle/vim-airline-themes/autoload/airline/themes
        airline_theme_dir=$(find ${vim_dir} -wholename "*vim-airline-themes/*/themes" | head -n 1)
        if [ -z "${airline_theme_dir}" ] || [ ! -d "${airline_theme_dir}" ]; then
            # tell the user to first install the plugins
            msg="Failed to find airline theme directory. "
            __shuggtool_toolsetup_print_bad "${msg}"
        else
            # copy the theme file into the correct location
            dst="${airline_theme_dir}/dwarrowdelf.vim"
            cp ${airline_file} ${dst}
            __shuggtool_toolsetup_print_good "Installed ${theme_name} airline theme at ${C_LTBLUE}${dst}${C_NONE}."
        fi
    fi
    
    # once finished, remove the repository directory
    rm -rf ${theme_repo_dir}
}

# Helper function used to load any plugins I've created or use.
function __shuggtool_toolsetup_vim_plugins()
{
    # set up the source and destination for plugin files
    vim_plugin_src=${sthome}/vim/shuggtools
    vim_plugin_dst=~/.vim/shuggtools
    if [ ! -d ${vim_plugin_dst} ]; then
        mkdir -p ${vim_plugin_dst}
    fi
    rm -rf ${vim_plugin_dst}/* ${vim_plugin_dst}/.git

    # if the Vundle-based directory exists, delete it
    vundle_plugin_dir=~/.vim/bundle/shuggtools
    if [ -d ${vundle_plugin_dir} ]; then
        rm -rf ${vundle_plugin_dir}
    fi
    
    # copy all plugin files to the destination
    __shuggtool_toolsetup_print_note "Installing my local plugins..."
    cp -r ${vim_plugin_src}/* ${vim_plugin_dst}/

    # initialize an empty git repository in this destination directory, and
    # make a single commit. This is required by Vundle; when you point it at a
    # file-local directory containing a plugin, it expects a git repository to
    # be initialized for it
    pushd ${vim_plugin_dst}                 > /dev/null
    git init                                > /dev/null
    git add .                               > /dev/null
    git commit -m "LOCAL PLUGIN INSTALL"    > /dev/null
    popd                                    > /dev/null

    # print out the result
    pcount=0
    for f in ${vim_plugin_dst}/plugin/*.vim; do
        fname="$(basename "${f}")"
        __shuggtool_toolsetup_print_good "${STAB_TREE2}installed ${C_GREEN}${fname}${C_NONE}."
        pcount=$((pcount+1))
    done
    __shuggtool_toolsetup_print_good "${STAB_TREE1}installed ${pcount} plugin(s) from ${C_LTBLUE}${vim_plugin_src}${C_NONE}."
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
    git clone ${vundle_url} ${vundle_dir} > /dev/null 2> /dev/null

    # check that the directory has been filled up with files from vundle
    if [ ! -z "$(ls ${vundle_dir})" ]; then
        __shuggtool_toolsetup_print_good "Installed vundle to ${C_LTBLUE}${vundle_dir}${C_NONE}."
    else
        __shuggtool_toolsetup_print_bad "Failed to install vundle."
    fi
}

# main function
function __shuggtool_toolsetup_vim()
{
    # check for vim install
    vim_bin="$(which vim 2> /dev/null)"
    if [ -z "${vim_bin}" ]; then
        __shuggtool_toolsetup_print_bad "Couldn't find vim. Is it installed?"
        __shuggtool_toolsetup_print_alert "Make sure it's installed to at least version 8.1."
    else
        __shuggtool_toolsetup_print_note "Found ${C_YELLOW}$(${vim_bin} --version | head -n 1)${C_NONE}."
    fi

    vimrc_location=~/.vimrc
    vimrc_source=${sthome}/vim/vimrc.vim

    # copy the vimrc file to the correct location
    if [ ! -f ${vimrc_source} ]; then
        __shuggtool_toolsetup_print_bad "Failed to find source vimrc at ${C_LTBLUE}${vimrc_source}${C_NONE}"
    else
        cp ${vimrc_source} ${vimrc_location}
    fi
    __shuggtool_toolsetup_print_good "Installed .vimrc to ${C_LTBLUE}${vimrc_location}${C_NONE}."
    
    # next we'll install any plugins we have
    __shuggtool_toolsetup_vim_plugins
    __shuggtool_toolsetup_vim_vundle

    # with all the added changes, launch vim and attempt to run ':PluginInstall'
    # to ensure all plugins and themes are installed correctly
    $(which vim) -c "PluginInstall" -c "qa!"
    __shuggtool_toolsetup_print_note "Launched vim and executed ${C_YELLOW}:PluginInstall${C_NONE}."

    # finally, try to install the theme
    __shuggtool_toolsetup_vim_theme
    
}


# =================================== Tmux =================================== #
# Installs my tmux config file.
function __shuggtool_toolsetup_tmux()
{
    config_src=${sthome}/tmux/tmux.conf
    config_dst=~/.tmux.conf

    # check for tmux install
    tmux_bin="$(which tmux 2> /dev/null)"
    if [ -z "${tmux_bin}" ]; then
        __shuggtool_toolsetup_print_bad "Couldn't find tmux. Is it installed?"
        __shuggtool_toolsetup_print_alert "Make sure it's installed to at least version 3.0."
    else
        __shuggtool_toolsetup_print_note "Found ${C_YELLOW}$(${tmux_bin} -V)${C_NONE}."
    fi
    
    # install tmux config
    cp ${config_src} ${config_dst}
    __shuggtool_toolsetup_print_good "Installed config file at ${C_LTBLUE}${config_dst}${C_NONE}."
}


# =================================== GDB ==================================== #
# Helper function used to load any plugins I've created or use.
function __shuggtool_toolsetup_gdb()
{
    # in the shuggtools home directory there's a 'gdb/' directory containing
    # my .gdbinit file. We'll locate it and copy it over.
    gdbinit_src=${sthome}/gdb/.gdbinit
    gdbinit_dest=~/.gdbinit

    cp ${gdbinit_src} ${gdbinit_dest}
    __shuggtool_toolsetup_print_good "Installed GDB init file to ${C_LTBLUE}${gdbinit_dest}${C_NONE}."
}


# ============================ Bat (Colored Cat) ============================= #
# Forks and installs the 'bat' utility to replace the standard 'cat'.
function __shuggtool_toolsetup_cat()
{
    repo_url="https://github.com/sharkdp/bat"

    # look for 'bat' or 'batcat'
    binary="$(which bat 2> /dev/null)"
    binary2="$(which batcat 2> /dev/null)"
    if [ ! -z "${binary}" ] || [ ! -z "${binary2}" ]; then
        __shuggtool_toolsetup_print_good "Already installed. Try running ${C_YELLOW}bat${C_NONE} or ${C_YELLOW}batcat${C_NONE}."
        return
    fi
    
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


# =================================== Git ==================================== #
# Installs my git config settings.
function __shuggtool_toolsetup_git()
{
    git_config_src=${sthome}/git/.gitconfig
    git_config_dst=~/.gitconfig

    if [ ! -f ${git_config_src} ]; then
        __shuggtool_toolsetup_print_bad "Failed to find source ${C_LTBLUE}$(basename ${git_config_src})${C_NONE}."
        return 1
    fi

    # we don't want to blindly copy my gitconfig to the destination; we might
    # overwrite something important an an existing .gitconfig. So, we'll do the
    # following:

    # first, check to see if a .gitconfig exists at the destination. If it
    # doesn't, we'll create one
    if [ ! -f ${git_config_dst} ]; then
        __shuggtool_toolsetup_print_note "No git config file exists at ${C_LTBLUE}${git_config_dst}${C_NONE}."
        __shuggtool_toolsetup_print_good "Creating new git config file."
        touch ${git_config_dst}
    fi

    # search the file to see if it has an `include` statement pointed at this
    # file. If it doesn't, we'll add one to the bottom of the file
    git_config_src_real="$(realpath "${git_config_src}")"
    if [ -z "$(grep "\[include\]" "${git_config_dst}")" ] ||
       [ -z "$(grep "path\s*=\s*${git_config_src_real}\s*" "${git_config_dst}")" ]; then
        msg=""
        msg="${msg}Found existing git config file at ${C_LTBLUE}${git_config_dst}${C_NONE} "
        msg="${msg}with no include statement."
        __shuggtool_toolsetup_print_note "${msg}"
        
        # add the line to the git config
        echo -e "[include]\n    path = ${git_config_src_real}\n" >> "${git_config_dst}"
        msg=""
        msg="${msg}Added include statement to ${C_LTBLUE}${git_config_dist}${C_NONE} "
        msg="${msg}to include configurations from ${C_LTBLUE}${git_config_src}${C_NONE}."
        __shuggtool_toolsetup_print_good "${msg}"
    fi

    # search the file to see if it has a username and email field. If it
    # doesn't, we'll add one
    if [ -z "$(grep "\[user\]" "${git_config_dst}")" ]; then
        __shuggtool_toolsetup_print_note "Found no user configuration in git config file."

        # read the desired username
        msg="What username would you like to use for your git config?"
        __shuggtool_toolsetup_prompt "${msg}"
        git_config_name="${__shuggtool_toolsetup_prompt_result}"

        # read the desired email
        msg="What email would you like to use for your git config?"
        __shuggtool_toolsetup_prompt "${msg}"
        git_config_email="${__shuggtool_toolsetup_prompt_result}"

        # add the user block with the given values
        echo -e "[user]"                                >> "${git_config_dst}"
        echo -e "    name = \"${git_config_name}\""     >> "${git_config_dst}"
        echo -e "    email = \"${git_config_email}\""   >> "${git_config_dst}"

        # print a confirmation message
        msg=""
        msg="${msg}Added username ${C_YELLOW}${git_config_name}${C_NONE} "
        msg="${msg}and email ${C_YELLOW}${git_config_email}${C_NONE} "
        msg="${msg}to git config."
        __shuggtool_toolsetup_print_good "${msg}"
    fi

    __shuggtool_toolsetup_print_good "Git config setup complete."
}


# ================================= Wezterm ================================== #
# Installs my wezterm configurations.
function __shuggtool_toolsetup_wezterm()
{
    wez_config_src=${sthome}/wezterm/wezterm.lua
    wez_config_dst=~/.wezterm.lua

    # if wezterm isn't installed, skip this
    wez_bin="$(which wezterm 2> /dev/null)"
    if [ -z "${wez_bin}" ]; then
        __shuggtool_toolsetup_print_note "Wezterm doesn't appear to be installed. Skipping configuration."
        return
    fi
    
    # copy config file into the correct spot
    if [ ! -f ${wez_config_src} ]; then
        __shuggtool_toolsetup_print_bad "Failed to find source ${C_LTBLUE}$(basename ${wez_config_src})${C_NONE}."
    else
        cp ${wez_config_src} ${wez_config_dst}
        __shuggtool_toolsetup_print_good "Installed config to ${C_LTBLUE}${wez_config_dst}${C_NONE}."
    fi
}


# =================================== Main =================================== #
function __shuggtool_toolsetup()
{
    __shuggtool_toolsetup_print_prefix="vim"
    __shuggtool_toolsetup_vim
    echo ""

    __shuggtool_toolsetup_print_prefix="tmux"
    __shuggtool_toolsetup_tmux
    echo ""

    __shuggtool_toolsetup_print_prefix="gdb"
    __shuggtool_toolsetup_gdb
    echo ""

    __shuggtool_toolsetup_print_prefix="cat"
    __shuggtool_toolsetup_cat
    echo ""

    __shuggtool_toolsetup_print_prefix="git"
    __shuggtool_toolsetup_git
    echo ""

    __shuggtool_toolsetup_print_prefix="wezterm"
    __shuggtool_toolsetup_wezterm
}

__shuggtool_toolsetup "$@"

