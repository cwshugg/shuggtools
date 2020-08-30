source /home/cwshugg/toolbox/shuggtools/globals.sh
#!/bin/bash
# A shell script that clones and sets up various cybersecurity tools I've used
# in the past
#
#   Connor Shugg

# main function
function __shuggtool_cybertools()
{
    dir_cyber=~/cybertools
    clean_first=0

    # check a command-line arguments
    local OPTIND h c d
    while getopts "hcd:" opt; do
        case $opt in
            h)
                # print a help menu
                __shuggtool_cybertools_usage
                return
                ;;
            c)
                # toggle a switch to force-remove the old directory
                clean_first=1
                ;;
            d)
                # update the directory location
                dir_cyber=${OPTARG}
                ;;
            *)
                # with any other argument, just print the help menu
                __shuggtool_cybertools_usage
                return
                ;;
        esac
    done
    
    dir_cyber=$(realpath $dir_cyber)
    # update alias file location
    alias_file_name=aliases.sh
    alias_file=$dir_cyber/$alias_file_name


    # if the directory already exists, we'll blindly assume this script has already
    # installed these tools before
    if [ -d $dir_cyber ]; then
        # if 'clean_first' is set, remove the directory and proceed
        if [ $clean_first -eq 1 ]; then
            __shuggtool_cybertools_print "Removing old cybertool directory '$dir_cyber'..."
            rm -rf $dir_cyber
        # otherwise, complain and exit
        else
            __shuggtool_print_error "Cybertool directory '$dir_cyber' already exists."
            return
        fi
    fi

    # make and CD into the directory
    mkdir $dir_cyber
    cd $dir_cyber

    # ---------------------------- Dependencies ----------------------------- #
    __shuggtool_cybertools_print "Installing ${c_yellow}Python 3${c_none}..."
    sudo apt-get install python3 -y
    echo ""
    __shuggtool_cybertools_print "Installing ${c_yellow}Pip${c_none}..."
    sudo apt-get install python-pip -y
    echo ""
    
    # -------------------------- Git Repositories --------------------------- #
    # get 'dirsearch'
    __shuggtool_cybertools_print "Installing ${c_ltblue}dirsearch${c_none}..."
    git clone https://github.com/maurosoria/dirsearch.git
    echo ""

    # get 'sherlock'
    __shuggtool_cybertools_print "Installing ${c_ltblue}sherlock${c_none}..."
    git clone https://github.com/sherlock-project/sherlock.git
    # cd into the directory and install the dependencies
    cd $dir_cyber/sherlock
    python3 -m pip install -r requirements.txt
    cd $dir_cyber
    echo ""

    # -------------------------- apt-get installs --------------------------- #
    # tcpdump
    __shuggtool_cybertools_print "Installing ${c_green}tcpdump${c_none}..."
    sudo apt-get install tcpdump -y
    echo ""
    
    # nmap
    __shuggtool_cybertools_print "Installing ${c_green}nmap${c_none}..."
    sudo apt-get install nmap -y
    echo ""


    # set up the shell script with aliases
    __shuggtool_cybertools_print "Creating alias file..."
    # (create it if it doesn't exist)
    if [ ! -f $alias_file ]; then
        touch $alias_file
    fi
    # write in aliases
    echo "#!/bin/bash"                                                      > $alias_file
    echo "# Aliases for cybertools in this directory"                       >> $alias_file
    echo "alias dirsearch=\"python3 $dir_cyber/dirsearch/dirsearch.py\""    >> $alias_file
    echo "alias sherlock=\"python3 $dir_cyber/sherlock/sherlock\""          >> $alias_file

    __shuggtool_cybertools_print "Cybertool setup complete. Run \"source $dir_cyber/$alias_file_name\" to assign aliases."
}

# print helper function
function __shuggtool_cybertools_print()
{
    # echo a header followed by the given argument
    echo -e "${c_red}==== ${c_none}CYBERTOOLS ${c_red}==== ${c_none}$1"
}

# usage menu printer function
function __shuggtool_cybertools_usage()
{
    echo "Cybertools installer: installs various cybersecurity-related command-line tools into a single directory."
    echo ""
    echo "Invocation arguments:"
    echo "---------------------------------------------------------------------------"
    echo " -h           Shows this help menu"
    echo " -c           If the directory already exists, remove it and make a new one"
    echo " -d <dir>     Specifies where to place the directory containing the tools"
    echo "---------------------------------------------------------------------------"
}


# call main function
__shuggtool_cybertools "$@"
