#!/bin/bash
# A small shell script used to set up the shuggtools library. This should be
# 'source'd in order for the PATH to be adjusted correctly.

setup_dir=$(pwd)
function_dir=$setup_dir/funcs
source_dir=$setup_dir/links

# set up globals.sh variables and source the file
globals_file=globals.sh
globals=$setup_dir/$globals_file
source $globals

# sourcing and finalizing function
function __shuggtools_setup_finalize
{
    PATH=$PATH:$source_dir
    PATH=$PATH:./
    source aliases.sh
    source prompt.sh
}

# if we got "-f" as the first argument, we'll force a setup by removing
# the source directory
if [ $# -ge 1 ] && [ "$1" == "-f" ]; then
    rm -rf $source_dir
fi

# if the source directory exists, just modify the path and exit
if [ -d "$source_dir" ]; then
    __shuggtools_setup_finalize
    return
else
    # otherwise, we'll make the directory
    mkdir $source_dir
fi

# echo the correct "source" command into each function file
echo -e -n "\033[33mshuggtools\033[0m: initializing "
for func in $function_dir/*.sh; do
    # search for the occurrence of the 'source ..../global.sh' in the function
    global_source=$(grep -i "source $globals" $func)

    # if it's not found, echo it into the top of the file (with a temp file),
    # along with a "#!/bin/bash" shebang
    if [ -z "$global_source" ]; then
        echo "#!/bin/bash" > temp.txt
        echo "source $globals" >> temp.txt
        cat $func >> temp.txt
        cat temp.txt > $func
        rm temp.txt
    fi

    # at this point, we know it's sourcing the correct globals file, so we'll
    # make the file executable and create a link for it in the source dir
    chmod 755 $func
    ln -s $func $source_dir/$(basename $func .sh)
    
    echo -n "."
done
echo -e " \033[32mdone\033[0m"

__shuggtools_setup_finalize

# ========================== Generating Info File =========================== #
# invoke the script that writes to the globals file
__shuggtool_write_info_file $setup_dir/$shuggtools_info_file

