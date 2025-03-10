#!/bin/bash
# [ST.SETUP] <-- KEEP THIS HERE. REQUIRED FOR SETUP.
# A small shell script used to set up the shuggtools library. This should be
# 'source'd in order for the PATH to be adjusted correctly.

# ============================= Variable Setup ============================== #
# this script can be either executed directly (./setup.sh), or it can be
# sourced in a .bashrc or similar file (source ./setup.sh ./setup.sh). If it's
# being sourced, the path to the file must be provided as an argument. This
# code checks that here and attempts to locate the setup script.
setup_fpath=$0
if [ $# -ge 1 ]; then
    setup_fpath=$1
fi
# make sure the argument is a file AND it has the special keyword in it
if [ ! -f ${setup_fpath} ] || [ -z "$(grep 'ST.SETUP' ${setup_fpath})" ]; then
    echo "shuggtools/setup.sh: expected path to setup.sh as first argument"
    return
fi
setup_dir=$(dirname $(realpath ${setup_fpath}))

# set up a few other directory paths
old_dir=$(pwd)
function_dir=${setup_dir}/shell
source_dir=${setup_dir}/links

# set up globals.sh variables and source the file
globals_file=globals.sh
globals=${setup_dir}/${globals_file}
gpath=$(dirname $(realpath ${globals}))
source ${globals}

# ============================ Helper Functions ============================= # 
shuggtool_file_boilerplate_id="ST.BOILERPLATE"
# Function that checks a file to see if boilerplate has already been installed.
# Outputs nothing if boilerplate is found, and echoes something otherwise.
function __shuggtool_file_has_boilerplate()
{
    # if the boilerplate ID string is present, return 1. Otherwise, return 0
    fpath=$1
    bpsearch=$(grep "${shuggtool_file_boilerplate_id}" ${fpath} | wc -l)
    if [ ${bpsearch} -gt 0 ]; then
        return
    fi
    echo "BOILERPLATE NOT FOUND"
}

# Function that takes in a file path and appends a few boilerplate lines to the
# top of it so it can function properly as a shell script.
function __shuggtool_setup_file_boilerplate()
{
    # get needed file names
    fpath=$1
    tfpath=${fpath}.shuggtool.tmp

    # get current date
    cdate="$(date)"

    # add the top lines
    bpid="${shuggtool_file_boilerplate_id}"
    echo "#!/bin/bash"                                              > ${tfpath}
    echo "# ---------- ${bpid}: BEGIN [${cdate}] ---------- #"      >> ${tfpath}
    echo "sthome=${gpath}"                                          >> ${tfpath}
    echo "source \${sthome}/globals.sh"                             >> ${tfpath}
    echo "# ----------- ${bpid}: END [${cdate}] ----------- #"      >> ${tfpath}
    
    # add the script's contents and swap it into the original file
    cat ${fpath} >> ${tfpath}
    cat ${tfpath} > ${fpath}
    /bin/rm ${tfpath}
}

# Adds the given path string to the end of the PATH environment variable, so
# long as it already does not appear in PATH.
function __shuggtool_setup_path_append()
{
    # expand the path string to use the full file path, unless it's the special
    # "current directory" syntax
    p="$1"
    if [[ "${p}" != "./" ]]; then
        p="$(realpath $1)"
    fi
    
    # if the path already contains the string, return early
    if [[ "${PATH}" == *"${p}"* ]]; then
        return
    fi

    export PATH="$PATH:${p}"
}

# Optional function that sets up the 'source directory' (the location that gets
# added to the user's $PATH). This function modifies the scripts within shell/
# by adding a small boilerplate bit of shell code that sources globals.sh, adds
# a shebang, and sets up a 'sthome' (shuggtools home) variable for each script
# to reference.
function __shuggtool_setup_source_dir()
{
    # make the source directory, if applicable
    if [ ! -d ${source_dir} ]; then
        mkdir ${source_dir}
    fi

    # echo the correct "source" command into each function file
    count=0
    for func in ${function_dir}/*.sh; do
        # if the script already has boilerplate code inside, we'll skip it
        has_bp="$(__shuggtool_file_has_boilerplate ${func})"
        if [ -z "${has_bp}" ]; then
            continue
        fi

        # echo out a one-time message if this is the first script we're
        # initializing
        if [ ${count} -eq 0 ]; then
            echo -e "${C_LTBLUE}shuggtools${C_NONE}: initializing scripts..."
        fi
        
        # otherwise, set up the boilerplate code
        echo -en "${STAB_TREE2}$(basename ${func})... "
        __shuggtool_setup_file_boilerplate ${func}
    
        # at this point, we know it's sourcing the correct globals file, so we'll
        # make the file executable and create a link for it in the source dir
        chmod 755 ${func}
        link_fpath=${source_dir}/$(basename ${func} .sh)
        if [ ! -L ${link_fpath} ]; then
            ln -s ${func} ${link_fpath}
        fi
     
        echo -e "${C_GREEN}success${C_NONE}"
        count=$((count+1))
    done

    # if we set up one or more script, echo out one final message
    if [ ${count} -gt 0 ]; then
        echo -e "${STAB_TREE1}initialized ${C_GREEN}${count}${C_NONE} scripts"
    fi
}

# Helper function that creates an information file with various version
# information for shuggtools. Parameters:
#   $1      The full path to the information file
function __shuggtool_setup_info_file()
{
    # navigate to the repo's directory
    cd ${setup_dir}
    
    # make sure an argument was given
    if [ $# -lt 1 ]; then
        __shuggtool_print_error "info file could not be set up: the full path was not specified."
        return
    fi
    info_file=$1

    # dump git version information into a text file (for the 'shuggtools' script)
    shuggtools_git_remote_url="$(git config --get remote.origin.url)"
    shuggtools_git_commit_hash="$(git rev-parse --short HEAD)"
    echo "Remote URL:    ${shuggtools_git_remote_url}"    > $info_file
    echo "Commit Hash:   ${shuggtools_git_commit_hash}"   >> $info_file

    # navigate back to the old directory
    cd ${old_dir}
}

# =============================== Runner Code =============================== # 
# if we got "-f" as the first argument, we'll force a setup by removing
# the source directory
if [ $# -ge 1 ] && [ "$1" == "-f" ]; then
    /bin/rm -rf ${source_dir}
fi

# invoke the setup function for all links that will go into the source directory
__shuggtool_setup_source_dir

# look for any `bin/` directories I might have on my system. We want to add
# these to my PATH so I can access the binaries/scripts within from anywhere
bins=( \
    "${HOME}/bin" \
    "${HOME}/toolbox/bin" \
)
for bin in ${bins[@]}; do
    if [ -d "${bin}" ]; then
        export PATH="${bin}:${PATH}"
    fi
done

# append this repo's source directory to our PATH variable, as well as the
# current directory (so we can locate executables and other files without
# having to type './')
__shuggtool_setup_path_append "${source_dir}"
__shuggtool_setup_path_append "./"

# setup and source our other files - aliases, prompt setup, etc.
other_files=( aliases.sh prompt.sh )
other_files_count=0
for ofile in ${other_files[@]}; do
    ofpath=${setup_dir}/${ofile}

    # if boilerplate isn't found, set it up
    has_bp="$(__shuggtool_file_has_boilerplate ${ofpath})"
    if [ ! -z "${has_bp}" ]; then
        if [ ${other_files_count} -eq 0 ]; then
            echo -e "${C_LTBLUE}shuggtools${C_NONE}: initializing other files..."
        fi

        echo -en "${STAB_TREE2}${other_files[${other_files_count}]}... "
        __shuggtool_setup_file_boilerplate ${ofpath}
        echo -e "${C_GREEN}success${C_NONE}"
        other_files_count=$((other_files_count+1))
    fi
    
    # source the file
    source ${ofpath} 
done
# print if any 'other files' were set up
if [ ${other_files_count} -gt 0 ]; then
    echo -e "${STAB_TREE1}initialized ${C_GREEN}${other_files_count}${C_NONE} other files"
fi

# invoke the script that writes to the globals file
__shuggtool_setup_info_file ${setup_dir}/${shuggtools_info_file}

# initialize OS signals
__shuggtool_os_signal_init

