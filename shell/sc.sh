#!/bin/bash
# ---------- ST.BOILERPLATE: BEGIN [Tue Mar  4 19:19:35 UTC 2025] ---------- #
sthome=/home/connorshugg/toolbox/shuggtools
source ${sthome}/globals.sh
# ----------- ST.BOILERPLATE: END [Tue Mar  4 19:19:35 UTC 2025] ----------- #
# Screen Cover (sc)
# A function used to display some sort of screen-saver or cover over what I
# currently have in my terminal. Good for privacy!
#
#   Connor Shugg

__shuggtool_screen_cover_sc_dir=~/.sc

# binary locator function
__shuggtool_screen_cover_cmatrix_bin=cannot_find_cmatrix_bin
function __shuggtool_screen_cover_find_binary()
{
    cmatrix_dir=${__shuggtool_screen_cover_sc_dir}

    # if the directory doesn't exist, return
    if [ ! -d ${cmatrix_dir} ]; then
        return
    fi

    # iterate through all 'find' results
    bpath=0
    for fpath in $(find ${cmatrix_dir} -name "cmatrix"); do
        # if the file path is a directory, ignore it
        if [ -d ${fpath} ]; then
            continue
        fi
        # grab the current one
        bpath=${fpath}
        
        # if this is an executable, it's probably what we're looking for
        if [[ "$(file ${fpath})" == *"ELF"* ]]; then
            break
        fi
    done
    
    # save to the global variable
    __shuggtool_screen_cover_cmatrix_bin=${bpath}
}

# main function
function __shuggtool_screen_cover()
{
    sc_dir=${__shuggtool_screen_cover_sc_dir}
    cmatrix_url=https://github.com/abishekvashok/cmatrix/releases/download/v2.0/cmatrix-v2.0-Butterscotch.tar

    # attempt to locate the binary
    __shuggtool_screen_cover_find_binary
    cmatrix_bin=${__shuggtool_screen_cover_cmatrix_bin}

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
            echo -e "${C_RED}failure.${C_NONE}"
            __shuggtool_print_error "failed to download ${cmatrix_url}."
            return 1
        fi
        echo -e "${C_LTGREEN}success.${C_NONE}"

        # unpack the tarfile
        echo -n "Unpacking tarfile... "
        tar -xf ${tarfile}
        if [ ! -d ./cmatrix ]; then
            echo -e "${C_RED}failure.${C_NONE}"
            __shuggtool_print_error "failed to unpack: ${sc_dir}/${tarfile}."
            return 2
        fi
        /bin/rm ${tarfile}
        echo -e "${C_LTGREEN}success.${C_NONE}"

        # attempt to build from source
        cd ./cmatrix
        /bin/rm -f ./cmatrix # remove any old gunk
        ./configure
        make
        cd ..

        # locate the binary
        echo -n "Locating binary... "
        __shuggtool_screen_cover_find_binary
        bpath=${__shuggtool_screen_cover_cmatrix_bin}
        if [ ! -f ${bpath} ]; then
            echo -e "${C_RED}failure.${C_NONE} Failed to find binary."
            return 3
        fi
        echo -e "${C_LTGREEN}success.${C_NONE} (${C_DKGRAY}${bpath}${C_NONE})"

        cd ${old_dir}
        echo "Installation successful. Run this again to start the screen cover."
        return 0
    fi
    
    # run the cmatrix binary
    ${cmatrix_bin} -ba
    return 0
}

# pass all args to main function
__shuggtool_screen_cover "$@"

