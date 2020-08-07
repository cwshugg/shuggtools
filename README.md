# Terminal Hackery Helpers
This is a repository containing tools I created to use on the command-line. It's structured to make set up easy.

# Using these tools
To use these tools yourself, you'll first have to clone the repository:

    git clone https://github.com/cwshugg/shuggtools.git

Once cloned, all you *should* need to do is source the setup script:

    cd shuggtools
    source setup.sh

(Presently, `setup.sh` must be sourced while inside the directory it's located in.) This will apply the changes to your current bash instance. Once you exit this instance (i.e. close the terminal), you'll need to do it again in your new one.

If you'd like to have this source automatically, place something like this inside your `.bashrc` or `.bash_profile`:

    old_dir=$(pwd)
    shuggtools_setup=<path_to_repo>/shuggtools/setup.sh
    cd $(dirname $shuggtools_setup)
    source $shuggtools_setup
    cd $old_dir
