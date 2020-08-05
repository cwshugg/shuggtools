In order to have this automatically 'source' in your .bashrc, add something
like this to your .bashrc:

    old_dir=$(pwd)
    shuggtools_setup=/data/users/t-coshug/shuggtools/setup.sh
    cd $(dirname $shuggtools_setup)
    source /data/users/t-coshug/shuggtools/setup.sh
    cd $old_dir

At the moment, the setup.sh script must be executed in the correct directory
for the setup to happen.

