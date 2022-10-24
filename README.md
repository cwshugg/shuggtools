# Terminal Hackery Helpers

This is a repository containing tools I created to use on the command-line. It's structured to make set up easy.

## Files

Contained in this repository is the following:

* `setup.sh` - the setup script (see below)
* `globals.sh` - global variables and functions used by this repo's shell scripts
* `prompt.sh` - my custom prompt routine
* `aliases.sh` - any aliases and other miscellaneous settings
* `shell/` - a directory containing various shell scripts I've written
* `vim/` - a directory containing any Vim scripts I've written
* `gdb/` - a directory containing any GDB scripts I've written

# Setup

To use these tools yourself, you'll first have to clone the repository:

```bash
$ git clone https://github.com/cwshugg/shuggtools.git
```

Once cloned, simply run the setup script:

```bash
$ /your/path/to/shuggtools/setup.sh
```

This will apply the changes to your current bash instance. If you'd like to have this source automatically, you'll have to `source` and provide it the path to itself as an argument. Place this code in your `.bashrc` or `.bash_profile`:

```bash
stsetup=/your/path/to/shuggtools/setup.sh
source ${stsetup} ${stsetup}
```

