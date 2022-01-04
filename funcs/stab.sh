# Space-Tab (STab)
# A function used to print space tabs (a tab made out of spaces), along with
# some extra handy prints (such as tree-like formatting).
#
#   Connor Shugg

# help menu
function __shuggtool_stab_usage()
{
    echo "Space Tab (STab): prints tabs made out of spaces."
    echo ""
    echo "Usage: stab [-t IDX] [-e]"
    echo "Invocation arguments:"
    echo "-------------------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -i INDENT    Specifies the number of columns to indent (minimum 4)"
    echo " -t IDX       Prints a space tab for tree-like formatting"
    echo " -e           Shows escape sequences for whatever is printed"
    echo "-------------------------------------------------------------------"
    echo ""
    echo "The available tree index values are:"
    for i in {1..3}; do
        command="$0 -t ${i}"
        echo -e " ${i}. \"$(${command})\" (${c_dkgray}${command}${c_none})"
    done
}

# main function
function __shuggtool_stab()
{
    # print characters
    tree_branch1="\u2514"
    tree_branch2="\u251c"
    tree_vline="\u2503"
    tree_hline="\u2500"

    # toggles/settings
    do_escape=0
    do_tree=0
    tree_idx=-1
    indent=4

    # first, check for command-line arguments
    local OPTIND h c t
    while getopts "hi:t:e" opt; do
        case ${opt} in
            h)
                __shuggtool_stab_usage
                return 0
                ;;
            i)
                indent=${OPTARG}
                # check for the minimum
                if [ ${indent} -lt 4 ]; then
                    __shuggtool_print_error "-i must specify an integer >= 4"
                    return 1
                fi
                ;;
            t)
                do_tree=1
                tree_idx=${OPTARG}
                ;;
            e)
                do_escape=1
                ;;
            *)
                __shuggtool_stab_usage
                return 1
                ;;
        esac
    done
    
    print_val=""
    if [ ${do_tree} -eq 1 ]; then
        fill_char="${tree_hline}"
        if [ ${tree_idx} -eq 1 ]; then
            print_val=" ${tree_branch1}"
        elif [ ${tree_idx} -eq 2 ]; then
            print_val=" ${tree_branch2}"
        elif [ ${tree_idx} -eq 3 ]; then
            print_val=" ${tree_vline}"
            fill_char=" "
        else
            __shuggtool_print_error "-t must specify an integer between 1-3"
            return 1
        fi

        # fill in the remaining (N-2)-1 columns
        hline_count=$((indent-3))
        for (( i=0; i<${hline_count}; i++)); do
            print_val="${print_val}${fill_char}"
        done
        # add one final space on the end
        print_val="${print_val} "
    else
        # build a simply string with ${indent} number of spaces
        for (( i=0; i<${indent}; i++ )); do
            print_val="${print_val} "
        done
    fi


    # echo out the chosen print value
    if [ ${do_escape} -eq 1 ]; then
        echo -n "${print_val}"
    else
        echo -en "${print_val}"
    fi
}

# pass all args to main function
__shuggtool_stab "$@"

