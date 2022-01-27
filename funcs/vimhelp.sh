# Vim Help. Prints some helpful Vim tips I'm trying to get myself to learn.
#
#   Connor Shugg

cc=${c_dkgray}
cn=${c_none}

# helper printing function
function __shuggtool_vimhelp_print()
{
    prefix=$1
    description=$2
    cmd=$3

    # compute the amount of space we have, minus the length of the prefix
    prefix_len=${#prefix}
    cols=${shuggtools_terminal_cols}
    len=$((cols-prefix_len))

    # split that available length in half (half for description, half for cmd)
    cmd_tlen_max=40 # maximum length of a command
    cmd_tlen=$((len/2))
    if [ ${cmd_tlen} -gt ${cmd_tlen_max} ]; then
        cmd_tlen=${cmd_tlen_max}
    fi
    desc_tlen=$(((len/2)-cmd_len))

    # compute space padding values
    cmd_len=${#cmd}
    desc_len=${#description}
    cmd_diff=$((cmd_tlen-cmd_len))
    desc_diff=$((desc_tlen-desc_len))

    # pad each string accordingly
    while [ ${cmd_diff} -gt 0 ]; do
        cmd="${cmd} "
        cmd_diff=$((cmd_diff-1))
    done
    while [ ${desc_diff} -gt 0 ]; do
        description="${description} "
        desc_diff=$((desc_diff-1))
    done

    echo -e "${prefix}${cc}${cmd}${cn}${description}"
}

function __shuggtool_vimhelp_print_section()
{
    name=$1
    echo -e "\n${c_ltblue}${name}${cn}"

    # print lines below the section header
    i=0
    while [ ${i} -lt ${#name} ]; do
        # pretty formatting
        if [ ${i} -eq 1 ]; then
            echo -en "\u252c"
        else
            echo -en "\u2500"
        fi
        i=$((i+1))
    done
    echo ""
}

# main function
function __shuggtool_vimhelp()
{
    echo -e "${c_yellow}Helpful Vim Tricks${cn}"

    # compute terminal size (used later)
    __shuggtool_terminal_size
   
    # cursor movement section
    pfx="${STAB_TREE2}"
    __shuggtool_vimhelp_print_section "Cursor Movement"
    __shuggtool_vimhelp_print "${pfx}" "Move down a line" "j"
    __shuggtool_vimhelp_print "${pfx}" "Move down 10 lines" "10j"
    __shuggtool_vimhelp_print "${pfx}" "Move up a line" "k"
    __shuggtool_vimhelp_print "${pfx}" "Move up 10 lines" "10k"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor left" "h"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor left 10 columns" "10h"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor right" "l"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor right 10 columns" "10l"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to the top of the screen" "H"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "Move cursor to the bottom of the screen" "L"

    # markers
    __shuggtool_vimhelp_print_section "Markers"
    __shuggtool_vimhelp_print "${pfx}" "Set a marker" "mx"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}x${cn} can be any character" ""
    __shuggtool_vimhelp_print "${pfx}" "Return cursor to a marker" "'x"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}x${cn} is a previously-set marker" ""
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"

    # deletion
    __shuggtool_vimhelp_print_section "Text Deletion"
    echo -e "${STAB_TREE2}Try swapping the ${cc}d${cn} for ${cc}c${cn} in some commands to enter insert mode."
    __shuggtool_vimhelp_print "${pfx}" "Delete current line" "dd"
    __shuggtool_vimhelp_print "${pfx}" "Delete the next 10 lines, starting at the cursor" "10dd"
    __shuggtool_vimhelp_print "${pfx}" "Delete everything inside current brackets" "di{"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}{${cn} can also be: ${cc}(${cn}" ""
    __shuggtool_vimhelp_print "${pfx}" "Delete everything inside current brackets AND the brackets themselves" "da{"
    __shuggtool_vimhelp_print "${pfx}" "Delete all text from the cursor up to a marker" "d'x"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}x${cn} is a previously-set marker" ""
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"
   
    # other text editing
    __shuggtool_vimhelp_print_section "Other Keybindings"
    __shuggtool_vimhelp_print "${pfx}" "Undo latest change" "u"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"

}

# pass all args to main function
__shuggtool_vimhelp "$@"

