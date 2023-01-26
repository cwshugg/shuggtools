# Helper function that attempts to install the 'bat' utility (an upgraded
# version of 'cat' that highlights language syntax)
#
#   Connor Shugg

# Main function.
function __shuggtool_catsetup()
{
    repo_url="https://github.com/sharkdp/bat"

    # look for 'bat' or 'batcat'
    echo -en "Looking for ${C_YELLOW}bat${C_NONE}... "
    binary="$(which bat 2> /dev/null)"
    binary2="$(which batcat 2> /dev/null)"
    if [ ! -z "${binary}" ] || [ ! -z "${binary2}" ]; then
        echo -e "${C_GREEN}already installed.${C_NONE}"
        echo -e "Try running ${C_YELLOW}bat${C_NONE} or ${C_YELLOW}batcat${C_NONE}."
        return
    fi
    echo -e "${C_RED}not installed.${C_NONE}"
    
    # determine if we have user permissions
    __shuggtool_prompt_yesno "Do you have ${C_YELLOW}sudo${C_NONE} permissions?"
    yes=$?
    if [ ${yes} -ne 0 ]; then
        echo -e "Installing ${C_YELLOW}bat${C_NONE} via apt-get."
        sudo apt install bat
        return
    fi

    # if we don't have sudo permissions, tell the user how to install it
    echo -e "Since you don't have ${C_YELLOW}sudo${C_NONE} permissions," \
            "you'll need to install ${C_YELLOW}bat${C_NONE} manually."
    echo -e "Head to ${C_LTBLUE}${repo_url}${C_NONE} and download a release or build it from source."
}

__shuggtool_catsetup "$@"

