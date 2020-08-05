#!/bin/bash
# A small shell script used to set up the shuggtools library. This should be
# 'source'd in order for the PATH to be adjusted correctly.

setup_dir=$(pwd)
function_dir=$setup_dir/funcs
source_dir=$setup_dir/links

globals=$setup_dir/globals.st

# if the source directory exists, wipe it and remake it
if [ -d "$source_dir" ]; then
    rm -rf $source_dir
fi
mkdir $source_dir

# echo the correct "source" command into each function file
for func in $function_dir/*.st; do
    # search for the occurrence of 'globals.st'. If it's there we'll assume the
    # function has run 'source <path>/globals.st' already
    global_source=$(grep -i "$globals" $func)
    
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
done

# make all st's in the func dir executable
chmod 755 $function_dir/*.st

# create links for each function
ln -s -r $function_dir/smite.st             $source_dir/smite
ln -s -r $function_dir/line_separator.st    $source_dir/sep
ln -s -r $function_dir/shugg_vimrc.st       $source_dir/shugg_vimrc
ln -s -r $function_dir/termalert.st         $source_dir/termalert

# lastly, modify the path variable to include the source directory in .bashrc
PATH=$PATH:$source_dir
PATH=$PATH:./

echo "Shuggtools initialized."

