# Helper function that sets up my GDB preferences.
#
#   Connor Shugg

# Helper function used to load any plugins I've created or use.
function __shuggtool_gdbsetup()
{
    # in the shuggtools home directory there's a 'gdb/' directory containing
    # my .gdbinit file. We'll locate it and copy it over.
    gdbinit_src=${sthome}/gdb/.gdbinit
    gdbinit_dest=~/.gdbinit

    echo -e "Installing GDB init file to ${C_LTBLUE}${gdbinit_dest}${C_NONE}"
    cp ${gdbinit_src} ${gdbinit_dest}
    echo -e "${C_GREEN}Installation successful.${C_NONE}"
}

__shuggtool_gdbsetup "$@"

