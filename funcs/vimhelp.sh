# Vim Help. Prints some helpful Vim tips I'm trying to get myself to learn.
#
#   Connor Shugg

cc=${C_DKGRAY}
cn=${C_NONE}

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
    echo -e "\n${C_LTBLUE}${name}${cn}"

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
    echo -e "${C_YELLOW}Helpful Vim Tricks${cn}"

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
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to the middle of the screen" "M"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to the bottom of the screen" "L"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to a specific line 134" ":134"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to 35% of the way through the file" "35%"
    __shuggtool_vimhelp_print "${pfx}" "Jump to the next word" "w"
    __shuggtool_vimhelp_print "${pfx}" "Jump to next non-whitespace" "W"
    __shuggtool_vimhelp_print "${pfx}" "Jump to the previous word" "b"
    __shuggtool_vimhelp_print "${pfx}" "Jump to previous non-whitespace" "B"
    __shuggtool_vimhelp_print "${pfx}" "Page up" "Ctrl-b"
    __shuggtool_vimhelp_print "${pfx}" "Page down" "Ctrl-f"
    __shuggtool_vimhelp_print "${pfx}" "Jump to the end of the line" "$"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "Jump to the beginning of the line" "^"

    # insert mode
    __shuggtool_vimhelp_print_section "Insert Mode"
    __shuggtool_vimhelp_print "${pfx}" "Enter insert mode" "i"
    __shuggtool_vimhelp_print "${pfx}" "Enter insert mode with the cursor one character to the right" "a"
    __shuggtool_vimhelp_print "${pfx}" "Enter insert mode with the cursor at the beginning of the line" "I"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "Enter insert mode with the cursor at the end of the line" "A"

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
    __shuggtool_vimhelp_print "${pfx}" "Delete the current word, starting at the cursor" "dw"
    __shuggtool_vimhelp_print "${pfx}" "Delete the next 10 words, starting at the cursor" "10dw"
    __shuggtool_vimhelp_print "${pfx}" "Delete everything inside current brackets" "di{"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}{${cn} can also be: ${cc}( \"${cn}" ""
    __shuggtool_vimhelp_print "${pfx}" "Delete everything inside current brackets AND the brackets themselves" "da{"
    __shuggtool_vimhelp_print "${pfx}" "Delete all text from the cursor up to a marker" "d'x"
    __shuggtool_vimhelp_print "${STAB_TREE3}" "${STAB}Where ${cc}x${cn} is a previously-set marker" ""
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"

    # copy and paste
    __shuggtool_vimhelp_print_section "Copy and Paste"
    echo -e "${STAB_TREE2}These mostly start with ${cc}y${cn}, short for \"yank\""
    __shuggtool_vimhelp_print "${pfx}" "Copy the current line" "yy"
    __shuggtool_vimhelp_print "${pfx}" "Copy the current word" "yw"
    __shuggtool_vimhelp_print "${pfx}" "Paste what's on the clipboard" "p"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"

    # search and replace
    __shuggtool_vimhelp_print_section "Search and Replace"
    __shuggtool_vimhelp_print "${pfx}" "Search for the word \"dog\"" "/dog"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to the next occurrence of the searched term" "n"
    __shuggtool_vimhelp_print "${pfx}" "Move cursor to the previous occurrence of the searched term" "N"
    __shuggtool_vimhelp_print "${pfx}" "Search and replace \"cat\" with \"dog\" in the whole file" ":%s/cat/dog/g"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"
   
    # other text editing
    __shuggtool_vimhelp_print_section "Other Keybindings"
    __shuggtool_vimhelp_print "${pfx}" "Undo latest change" "u"
    __shuggtool_vimhelp_print "${pfx}" "Redo latest undo" "Ctrl-r"
    __shuggtool_vimhelp_print "${STAB_TREE1}" "" "TODO: ADD MORE"
}

# pass all args to main function
__shuggtool_vimhelp "$@"

