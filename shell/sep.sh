# Helper function that simply prints a line across the width of the terminal.
# Used to visually separate things when dealing with a lot of text. Text can be
# printed in the middle of the line with the '-t' argument, and the character
# used to draw the line can be specified with the '-c' argument
#
#   Connor Shugg

# main function
function __shuggtool_line_separator()
{
    line_character="="
    line_text=""
    line_color=${C_NONE}
    line_text_color=${C_YELLOW}

    # check a few possible command-line arguments (set each argument as local
    # so problems don't arise with multiple runs)
    local OPTIND h c t
    while getopts "hc:t:" opt; do
        case $opt in
            h)
                __shuggtool_line_separator_usage
                return
                ;;
            c)
                line_character=${OPTARG}
                ;;
            t)
                line_text=${OPTARG}
                ;;
            *)
                __shuggtool_line_separator_usage
                return
                ;;
        esac
    done
    
    # invoke the global terminal_size function to get the number of columns
    # making up the current terminal's size
    __shuggtool_terminal_size
    columns=$shuggtools_terminal_cols

    # if the text was not blank, determine where to place it on the line (to
    # ensure the text is centered)
    column_to_write_text=-1
    if [ ! -z "$line_text" ]; then
        # calculate the space on the line the text will make up (strlen + 2
        # spaces on either side)
        len=$(expr $(expr length "$line_text") + 2)
        column_to_write_text=$(expr $(expr $columns - $len) / 2)
    fi

    # append the correct number of characters to the line string
    line="${line_color}"
    for (( i=0; i<$columns; i++ ))
    do
        # check for text writing
        if [ $column_to_write_text -gt -1 ]; then
            # if we're on the correct column, append the line text
            if [ $i -eq $column_to_write_text ]; then
                line="$line $line_text_color$line_text$line_color "
                # increment $i the number of characters we just added
                i=$(expr $i + $(expr length "$line_text") + 2)
            fi
        fi

        # append the next character
        line="$line$line_character"
    done

    # print out the line
    echo -e $line
}

# The 'usage' function prints out the help menu
function __shuggtool_line_separator_usage()
{
    echo "Line separator: prints a line across the width of the terminal."
    echo ""
    echo "Invocation arguments:"
    echo "--------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -c <char>    Sets the line character"
    echo " -t <text>    Sets the text to be displayed on the line"
    echo "--------------------------------------------------------"
}

# call main function and pass in all arguments
__shuggtool_line_separator "$@"
