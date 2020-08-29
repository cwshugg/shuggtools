source /home/ugrads/nonmajors/cwshugg/personal/shuggtools/globals.sh
# A small function that prints some basic information on shuggtools
#
#   Connor Shugg

# main function
function __shuggtool_summary()
{
    # print a description
    echo -e "${c_yellow}Shuggtools${c_none}"
    echo -e "=========="
    echo -e "A suite of command-line tools developed by Connor Shugg."
    echo -e "Take a look at ${c_ltblue}README.md${c_none} for more information."
    echo -e ""

    # get the path to info.txt
    info_file=$(dirname $0) # should be the path to the links/ directory
    info_file=${info_file}/../$shuggtools_info_file

    # print info file
    echo -e "${c_yellow}Info File${c_none}"
    echo -e "========="
    cat $info_file
}

# pass all args to main function
__shuggtool_summary "$@"
