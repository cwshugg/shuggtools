# Screen Cover (sc)
# A function used to display some sort of screen-saver or cover over what I
# currentl have in my terminal. Good for privacy!
#
#   Connor Shugg

# main function
function __shuggtool_screen_cover()
{
    sc_dir=~/.sc
    cmatrix_url=https://github.com/abishekvashok/cmatrix/releases/download/v2.0/cmatrix-v2.0-Butterscotch.tar
    cmatrix_bin=~/.sc/cmatrix

    # if the screen cover directory doesn't exist, make it
    if [ ! -d ${sc_dir} ]; then
        mkdir ${sc_dir}
    fi

    # if 'cmatrix' doesn't exist in the directory, we'll try to download it
    if [ ! -f ${cmatrix_bin} ]; then
        old_dir=$(pwd)
        cd ${sc_dir}
        
        # attempt to 'wget', then make sure we found the tarfile
        echo -n "Downloading cmatrix... "
        tarfile=$(basename ${cmatrix_url})
        wget ${cmatrix_url} > /dev/null 2> /dev/null
        if [ ! -f ${tarfile} ]; then
            echo -e "${c_red}failure.${c_none}"
            __shuggtool_print_error "failed to download ${cmatrix_url}."
            return 1
        fi
        echo -e "${c_ltgreen}success.${c_none}"

        # unpack the tarfile
        echo -n "Unpacking tarfile... "
        tar -xf ${tarfile}
        if [ ! -d ./cmatrix ]; then
            echo -e "${c_red}failure.${c_none}"
            __shuggtool_print_error "failed to unpack: ${sc_dir}/${tarfile}."
            return 2
        fi
        rm ${tarfile}
        echo -e "${c_ltgreen}success.${c_none}"

        # rename the directory and copy the executable out
        echo -n "Copying binary... "
        mv ./cmatrix ./cm
        cp ./cm/cmatrix ${cmatrix_bin}
        if [ ! -f ${cmatrix_bin} ]; then
            echo -e "${c_red}failure.${c_none}"
            __shuggtool_print_error "failed to copy executable to ${cmatrix_bin}."
            return 3
        fi
        rm -rf ./cm
        echo -e "${c_ltgreen}success.${c_none}"

        cd ${old_dir}
        echo "Installation successful. Run this again to start the screen cover."
        return 0
    fi
    
    # run the cmatrix binary
    ${cmatrix_bin} 2> /dev/null
    return 0
}

# pass all args to main function
__shuggtool_screen_cover "$@"

