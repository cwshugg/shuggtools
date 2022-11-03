# Termalert (terminal alert)
# Helper function that prints a large, obnoxious message to the terminal to
# alert me when something happens. For example, this could be used for:
#   ./really_long_test; terminalert
#
#   Connor Shugg

# Main function.
function __shuggtool_terminal_alert()
{
    # use the first argument as the alert text (or choose a default)
    text="$1"
    if [ -z "${text}" ]; then
        text="HEY! This is an alert."
    fi

    # determine if 'dialog' is installed
    dlg=$(which dialog 2> /dev/null)
    if [ -z "${dlg}" ]; then
        clear

        # compute how many lines to enter to meet the middle of the screen
        __shuggtool_terminal_size
        rows=${shuggtools_terminal_rows}
        rows_half=$((rows/2))
        while [ ${rows} -gt ${rows_half} ]; do
            echo -en "\n"
            rows=$((rows-1))
        done
        
        # print the text horizontally-centered on the terminal
        echo -en "${C_LTRED}"
        __shuggtool_print_text_centered "${text}"
        echo -en "${C_NONE}"

        # print the remaining newlines
        while [ ${rows} -gt 0 ]; do
            echo -en "\n"
            rows=$((rows-1))
        done
    else
        # if dialog IS installed, clear and show one
        clear
        ${dlg} --title "ALERT" \
               --clear \
               --msgbox "${text}" 0 0
        clear
    fi
}

# pass all args to main function
__shuggtool_terminal_alert "$@"

