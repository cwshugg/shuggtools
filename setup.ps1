# This PowerShell script downloads and installs various tools onto my Windows
# machine, then downloads the proper configuration files from this GitHub
# repository to configure each of them.

# ================================= Helpers ================================== #
# Constructs and returns a string that indicates where the repository should be
# installed on the Windows system.
function get_install_path
{
    # construct the path to the directory
    $result = Join-Path -Path "$home" -ChildPath ".shuggtools"

    # if the folder doesn't already exist, create it
    if (!(Test-Path -Path "$result"))
    { New-Item -ItemType Directory -Path "$result" }

    return $result
}

# Generates and installs a `profile.ps1` file to the appropriate location in
# Windows, such that all of my PowerShell aliases/utilities are available
# whenever PowerShell is launched.
#
# Returns 0 on success, and non-zero on failure.
#
# See this link for more information on customizing the PowerShell environment:
# https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles
function install_powershell_profile
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$InstallPath
    )
    
    # retrieve a list of all PowerShell scripts in the source directory
    # (`*.ps1`). These will represent all of the files that need to be added to
    # the `profile.ps1` file we're about to generate
    $scripts = Get-ChildItem -Path "$SourcePath" -Filter "*.ps1" -Recurse
    if ($scripts.Length -eq 0)
    {
        Write-Warning "Could not find any PowerShell scripts within: `"$SourcePath`"."
        return 1
    }

    # make sure the parent directory (and grandparent, great-grandparent, etc.)
    # exists, before we attempt to write to the PowerShell profile file
    $install_parent_path = Split-Path -Path "$InstallPath"
    if (!(Test-Path -Path "$install_parent_path"))
    { New-Item -ItemType Directory -Path "$install_parent_path" -Force }

    # open the file for writing (forcefully create it if it doesn't exist yet)
    Set-Content -Path "$InstallPath" `
                -Force `
                -Value "# Connor's PowerShell Profile`n"

    # get the full path to *this* script we're currently executing (we'll use
    # this in the below loop)
    $this_script_path = (Get-Item -Path "$PSCommandPath").FullName

    # now, for each of the scripts we collected earlier, add a line to the file
    # that sources the script
    foreach ($script in $scripts)
    {
        # resolve the script's path to ensure we are working with the full,
        # absolute file path
        $script_path = (Get-Item -Path "$script").FullName

        # make sure this particular script isn't the one we're executing *right
        # now*. Skip it, if so
        if ("$script_path" -eq "$this_script_path")
        { continue }

        # add a line to the file
        Add-Content -Path "$InstallPath" `
                    -Value ". $script_path"
    }

    return 0
}

# Takes in information about a GitHub repository and pings GitHub to retrieve
# information about a repo's release. If the release version is not specified,
# the latest release is used.
function github_retrieve_release
{
    # TODO
}


# =================================== Vim ==================================== #
# Main function for downloading and setting up Vim.
#
# Returns 0 on success, and non-zero on failure.
function vim_main
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SourcePath
    )
    
    # TODO: Install Vim from here: https://github.com/vim/vim-win32-installer/releases

    # if the `vimfiles` directory doesn't exist yet, create it
    $install_path = Join-Path -Path "$home" -ChildPath "vimfiles"
    if (!(Test-Path -Path "$install_path"))
    { New-Item -ItemType Directory -Path "$install_path" }

    # install my vimrc
    $result = vim_install_vimrc -SourcePath "$SourcePath" `
                                -InstallPath "$install_path"
    if ($result -ne 0)
    { return $result }

    # install my color scheme
    $result = vim_install_colorscheme -SourcePath "$SourcePath" `
                                      -InstallPath "$install_path"
    if ($result -ne 0)
    { return $result }

    # eventually, I want this script to install my Vim plugins
    # TODO

    return 0
}

# Installs my vimrc file.
function vim_install_vimrc
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$InstallPath
    )
    
    # create source and destination paths for the vimrc
    $vim_src = Join-Path -Path "$SourcePath" -ChildPath "vim"
    $vimrc_src = Join-Path -Path "$vim_src" -ChildPath "vimrc.vim"
    $vimrc_dst = Join-Path -Path "$InstallPath" -ChildPath "vimrc"
    if (!(Test-Path -Path "$vimrc_src"))
    {
        Write-Warning "Could not find vimrc at: `"$vimrc_src`". Install failed."
        return 1
    }

    # copy the file over
    Copy-Item -Path "$vimrc_src" -Destination "$vimrc_dst" -Force
    Write-Host "Installed vimrc to: `"$vimrc_dst`"."
    return 0
}

# Installs my preferred Vim colorscheme.
function vim_install_colorscheme
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$InstallPath
    )
    
    # first, create the vim colors directory if it doesn't exist
    $colors_path = Join-Path -Path "$InstallPath" -ChildPath "colors"
    if (!(Test-Path -Path "$colors_path"))
    { New-Item -ItemType Directory -Path "$colors_path" }

    # next, download my preferred colorscheme from github
    # TODO

    return 0
}


# ================================= WezTerm ================================== #
# Main function for downloading and setting up WezTerm.
#
# Returns 0 on success, and non-zero on failure.
function wezterm_main
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SourcePath
    )
    
    # TODO: Install WezTerm from here: https://github.com/wezterm/wezterm/releases/latest

    # create source/destination paths for my wezterm config file
    $wezterm_src = Join-Path -Path "$SourcePath" -ChildPath "wezterm"
    $wezterm_config_src = Join-Path -Path "$wezterm_src" -ChildPath "wezterm.lua"
    $wezterm_config_dst = Join-Path -Path "$home" -ChildPath ".wezterm.lua"

    # make sure the source config file exists
    if (!(Test-Path -Path "$wezterm_config_src"))
    {
        Write-Warning "Could not find WezTerm config file at: `"$wezterm_config_src`". Install failed."
        return 1
    }

    # copy the config file into the destination
    Copy-Item -Path "$wezterm_config_src" `
              -Destination "$wezterm_config_dst" `
              -Force
    Write-Host "Installed WezTerm config to: `"$wezterm_config_dst`"."
    return 0
}


# ============================ Main Functionality ============================ #
# Main function.
function main
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$SourcePath=$PSScriptRoot
    )
    
    # retrieve the source path, at which the repository's contents exist
    $source = (Resolve-Path -Path "$SourcePath").ProviderPath
    Write-Host "Source path: `"$source`""

    # set upand retrieve the path at which we'll install the repo into Windows
    $destination = get_install_path
    Write-Host "Install path: `"$destination`""

    # copy all files from the source path into the destination path (excluding
    # some directories, like the `.git` metadata and the `links` directory,
    # which is used in Linux, but not Windows)
    Copy-Item -Path "${source}\*" `
              -Destination "${destination}" `
              -Recurse `
              -Force `
              -Exclude @("links", ".git")
    Write-Host "Copied all files to install path: `"${destination}`"."
    
    # next, we need to create a `profile.ps1` file that contains all of my
    # powershell utilities in `powershell/`. This `profile.ps1` file is what
    # PowerShell sources whenever it's launched
    $profile_path = $PROFILE.CurrentUserAllHosts
    $result = install_powershell_profile `
              -SourcePath "$source" `
              -InstallPath "$profile_path"
    if ($result -ne 0)
    {
        Write-Warning "Failed to install PowerShell profile."
        return 1
    }
    Write-Host "Installed PowerShell profile to: `"$profile_path`"."

    # install Vim configuration/plugin files
    $result = vim_main -SourcePath "$source"
    if ($result -ne 0)
    { Write-Warning "Failed to install Vim configurations and plugins." }
    
    # install WezTerm configuration file
    $result = wezterm_main -SourcePath "$source"
    if ($result -ne 0)
    { Write-Warning "Failed to install WezTerm configuration." }
}

$result = main @args
exit $result

