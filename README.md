# Dotfiles, Configs, and Scripts

This repository contains a variety of configuration files, shell scripts, and
dotfiles for various command-line tools I use on a day-to-day basis. I've built
shell scripts to make setup dead easy, so I can set up my command-line
environment on any machine in a snap.

## Files

Contained in this repository is the following:

* `setup.sh` - the setup script (see below)
* `globals.sh` - global variables and functions used by this repo's shell scripts
* `prompt.sh` - my custom prompt routine
* `aliases.sh` - any aliases and other miscellaneous settings
* `shell/` - a directory containing various shell scripts I've written
* `vim/` - a directory containing any [Vim](https://www.vim.org/) scripts I've written
* `tmux/` - a directory containing my configurations for [tmux](https://github.com/tmux/tmux/wiki)
* `gdb/` - a directory containing any [GDB](https://sourceware.org/gdb/) scripts I've written
* `remind/` - a directory containing any files I've written for the [remind](https://dianne.skoll.ca/wiki/Remind) Linux utility.
* `wezterm/` - a directory containing my configurations for [Wezterm](https://wezfurlong.org/wezterm), my terminal of choice.

# Setup

To use these tools, start by cloning the repository:

```bash
$ git clone https://github.com/cwshugg/shuggtools.git
```

Once cloned, simply source the setup script:

```bash
$ source /your/path/to/shuggtools/setup.sh
```

This will apply the changes to your current bash instance. If you'd like to have this source automatically, you'll have to `source` and provide it the path to itself as an argument. Place this code in your `.bashrc` or `.bash_profile`:

```bash
stsetup=/your/path/to/shuggtools/setup.sh
source ${stsetup} ${stsetup}
```

