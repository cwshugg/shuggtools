# A shell script that sets up my preferred bash prompt.
#
#   Connor Shugg

# prompt toggle - set to any values in the below if-statement to adjust what
# prompt is being displayed
ptoggle=0

# fancy prompt variables
bgc="48;2"          # prefix for background colors
fgc="38;2"          # prefix for foreground colors

# set up three arrays of colors choices, for the three prompt colors
#                        dark blue  dark purple dark blue-green
declare -a pc1_choices=("0;30;128" "68;51;113" "14;59;67")
#                        dark red    magenta      medium blue
declare -a pc2_choices=("180;17;33" "145;31;160" "25;70;150")
#                        yellow      light blue   light pink
declare -a pc3_choices=("210;129;7" "152;213;231" "235;186;179")


pc_black="0;0;0"    # black
pc_white="255;255;255" # white
pc_none="0"         # none
b_line="$(echo -e '\u2501')"
b_fork="$(echo -e '\u2533')"
b_corner="$(echo -e '\u2517')"

# get a hash value of the username (if the username is one of my own, I'll
# manually set it so I get my favorite colors in the prompt)
special_usernames=("cwshugg" "connor" "connorshugg")
username="$(whoami)"
if [ ! -z "$(echo ${special_usernames[@]} | grep "${username}")" ]; then
    username="cwshugg"
fi
__shuggtool_hash_string "${username}"
username_hash=$__shuggtool_hash_string_retval

# choose default values
text_color1=${pc_white}
text_color2=${pc_white}
text_color3=${pc_black}
prompt_color1="${pc1_choices[0]}"
prompt_color2="${pc2_choices[0]}"
prompt_color3="${pc3_choices[0]}"

# if the hash worked, we'll pick pseudo-random values
if [ $username_hash -ne 0 ]; then
    # compute three indexes from the hashed value
    index1=$(((username_hash / 23) % 3))
    index2=$(((username_hash / 125) % 3))
    index3=$(((username_hash / 4) % 3))
    prompt_color1=${pc1_choices[$index1]}
    prompt_color2=${pc2_choices[$index2]}
    prompt_color3=${pc3_choices[$index3]}
fi
# make adjustments if we're the root user
if [[ "${username}" == "root" ]]; then
    ptoggle=1
    text_color1="0;255;0"       # green username text
    text_color2="0;255;0"       # green text
    text_color3="128;255;128"   # green text
    prompt_color1="14;49;57"    # dark blue-green
    prompt_color2="32;32;32"    # dark gray
    prompt_color3="40;40;40"    # not-as-dark gray
fi


# make the color formatter strings
prompt_format1="${bgc};${prompt_color1};${fgc};${text_color1}"
prompt_format2="${bgc};${prompt_color2};${fgc};${text_color2}"
prompt_format3="${bgc};${prompt_color3};${fgc};${text_color3}"


if [ $ptoggle -eq 0 ]; then
    # fancy prompt 1
    PS1="\[\033[${prompt_format1}m\] \u \[\033[${prompt_format2}m\] \h \[\033[${prompt_format3}m\] \W \[\033[${pc_none}m\] "
elif [ $ptoggle -eq 1 ]; then
    # fancy prompt 2
    # compute number of spaces needed for the second line
    space_count=${#username}
    space_count=$((space_count + 3))
    spaces="$(printf "%*s" ${space_count})"
    PS1="\[\033[${prompt_format1}m\] \u \[\033[${pc_none}m\]${b_line}${b_fork}${b_line}\[\033[${prompt_format2}m\] \h \[\033[${prompt_format3}m\] \w \[\033[${pc_none}m\]\[\033[${fgc};${prompt_color3}m\]\[\033[${pc_none}m\]\n${spaces}${b_corner}${b_line} "
else
    # standard colored prompt
    PS1="[\[\033[${fgc};${prompt_color1}m\]\u\[\033[${pc_none}m\]@\[\033[${fgc};${prompt_color2}m\]\h\[\033[${pc_none}m\]: \[\033[${fgc};${prompt_color3}m\]\W\[\033[${pc_none}m\]] "
    # colorless prompt
    #PS1="[\! \u@\h: \W] "
fi

# add the pingfile check to the PROMPT_COMMAND bash variable
pf="$(which pf)"
PROMPT_COMMAND="${pf}"
