source /data/users/t-coshug/shuggtools/globals.st
#!/bin/bash
# Termalert (terminal alert)
# Helper function that prints a large, obnoxious message to the terminal to
# alert me when something happens. For example, this could be used for:
#   ./really_long_test; terminalert
#
#   Connor Shugg

function __shuggtool_terminal_alert()
{
    echo -e "${c_cyan}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
    echo -e "${c_ltblue}- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -e "${c_blue}---------------------------------------------------------------------"
    echo -e "${c_purple}====================================================================="
    echo -e ""
    echo -e "    ${c_red}HEY! This is an alert. Whatever you just launched is finished.${c_white}"
    echo -e ""
    echo -e "${c_purple}====================================================================="
    echo -e "${c_blue}---------------------------------------------------------------------"
    echo -e "${c_ltblue}- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -e "${c_cyan}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
}

__shuggtool_terminal_alert "$@"
