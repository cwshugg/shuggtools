# Same Remove (SRM)
# A script that takes in arguments the exact same way as the 'rm' command.
# This checks each argument for a few things:
#   - A file not owned by the user
#   - A file not in the user's groups
#   - A file without write permissions
# If the file is suspicious, '-i' is added to the rm command call to make
# sure the user is prompted before deletion.
#
# I decided to create this after almost nuking /* with a bad shell script.
#
#   Connor Shugg

# main function
function __shuggtool_srm()
{
    args=()
    files=()
    add_check=0
    # iterate through all arguments and perform checks
    for arg in "$@"; do
        # if the argument begins with "-", it's just a command-line argument
        # for srm - keep it around and don't do any checks
        if [[ "${arg}" == "-"* ]]; then
            args+=("${arg}")
            continue
        fi

        files+=("${arg}")

        # otherwise, check the argument for any potential unintended removals
        perms="$(stat -L -c "%a" ${arg} 2> /dev/null)"
        if [ -z "${perms}" ]; then
            # file doesn't exist, but we'll leave that to 'rm' to figure out
            continue
        fi
        
        # stat a few more times to gather permissions
        group="$(stat -L -c "%G" ${arg} 2> /dev/null)"
        owner="$(stat -L -c "%U" ${arg} 2> /dev/null)"

        # check the owner against the current user
        user="$(whoami)"
        if [[ "${user}" != "${owner}" ]]; then
            add_check=1
            continue
        fi

        # check the file group for a group the current user is NOT in
        userg="$(groups)"
        if [[ "${userg}" != *"${group}"* ]]; then
            add_check=1
            continue
        fi

        # check file permissions for lack of write permission
        if [[ "${perms}" != "7"* ]] && [[ "${perms}" != "6"* ]] && \
           [[ "${perms}" != "3"* ]] && [[ "${perms}" != "2"* ]]; then
            add_check=1
            continue
        fi  
    done

    # make another pass through the arguments given if we're going to add a
    # '-i' to them. We want to avoid having '-i' overridden by something like
    # '-f'
    if [ ${add_check} -gt 0 ]; then
        adjusted_arg=""
        idx=0
        for arg in "${args[@]}"; do
            echo "ARG: ${arg}"
            # loop through each character in the argument
            for (( i=0; i<${#arg}; i++ )); do
                # get the substring of length 1 at the current character
                c="${arg:${i}:1}"
                echo -e "\tCHAR: ${c}"
                # if the character if 'f', don't include it in the adjusted
                # argument string
                if [[ "${c}" == "f" ]]; then
                    continue
                fi
                adjusted_arg="${adjusted_arg}${c}"
            done
            args[${idx}]="${adjusted_arg}"
            idx=$((idx+1))
        done
    fi

    # if we've reached the end and 'add_check' is true, we'll make sure to
    # pass '-i' as the first argument to 'rm' to have it do checks while
    # removing files
    if [ ${add_check} -gt 0 ]; then
        rm -i ${args[@]} ${files[@]}
    else
        rm ${args[@]} ${files[@]}
    fi
}

# pass all args to main function
__shuggtool_srm "$@"

