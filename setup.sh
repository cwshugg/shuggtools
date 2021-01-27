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

# if the source directory exists, just exit - no need to remake
if [ -d "$source_dir" ]; then
    return;
fi

# echo the correct "source" command into each function file
for func in $function_dir/*.sh; do
    # search for the occurrence of 'globals.sh'. If it's there we'll assume the
    # function has run 'source <path>/globals.sh' already
    global_source=$(grep -i "$globals_file" $func)
    
    # if the string was found, remove the old line
    if [ ! -z "$global_source" ]; then
        # replace all "/" with "\/" to be read as escape sequences by sed
        sed_pattern=$(echo "$global_source" | sed 's#/#\\/#g')
        # use sed to delete the line where the pattern occurs
        temp=$(sed "/${sed_pattern}/d" $func)
        echo "$temp" > $func
    fi

    # TODO: put "#!/bin/bash" before the "source" line

    # echo the source command and the file contents into a temp file, then move
    # it all back to the original file
    echo "source $globals" > temp.txt
    cat $func >> temp.txt
    cat temp.txt > $func
    rm temp.txt

    # make the file executable
    chmod 755 $func
    # create a link for it in the source directory
    ln -s -r $func $source_dir/$(basename $func .sh)
done

# lastly, modify the path variable to include the source directory in .bashrc
PATH=$PATH:$source_dir
PATH=$PATH:./

# set up aliases
source aliases.sh


# ========================== Generating Info File =========================== #
# invoke the script that writes to the globals file
__shuggtool_write_info_file $setup_dir/$shuggtools_info_file

