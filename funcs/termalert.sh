# Termalert (terminal alert)
# Helper function that prints a large, obnoxious message to the terminal to
# alert me when something happens. For example, this could be used for:
#   ./really_long_test; terminalert
#
#   Connor Shugg

# main function
function __shuggtool_terminal_alert()
{
    text="HEY! This is an alert. Whatever you just launched is finished."

    # define colors
    color_text=$C_RED
    declare -a colors_top=(
        $C_CYAN
        $C_LTBLUE
        $C_GREEN
        $C_YELLOW
        $C_BROWN
    )
    declare -a colors_bot=(
        ${colors_top[4]}
        ${colors_top[3]}
        ${colors_top[2]}
        ${colors_top[1]}
        ${colors_top[0]}
    )

    # define characters
    declare -a chars_top=(
        "."
        "-"
        ":"
        "="
        "#"
    )

    # get the terminal size
    __shuggtool_terminal_size
    columns=$shuggtools_terminal_cols
    
    # print the top section
    for (( i=0; i<${#chars_top[@]}; i++ ))
    do
        __shuggtool_terminal_alert_line $columns ${chars_top[$i]} ${colors_top[$i]}
    done
    
    # print the text (centered)
    echo -e "${color_text}"
    __shuggtool_print_text_centered "$text"
    echo -e -n "${C_NONE}"

    # print the bottom section
    for (( i=${#chars_top[@]}; i>=0; i-- ))
    do
        __shuggtool_terminal_alert_line $columns ${chars_top[$i]} ${colors_top[$i]}
    done
}

# Helper function that draws a line with the given parameters:
#   $1      the number of columns to draw
#   $2      the character to draw
#   $3      the color to draw the line
function __shuggtool_terminal_alert_line()
{
    columns=$1
    character=$2
    color=$3
    
    line="${color}"
    for (( c=0; c<$columns; c++ ))
    do
        # append the next line character
        line="$line$character"
    done
    
    # reset the color at the end of the line and echo it out
    line="$line${C_NONE}"
    echo -e $line
}

# pass all args to main function
__shuggtool_terminal_alert "$@"
