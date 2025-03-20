# This PowerShell script defines a number of helper functions related to
# Microsoft Teams.
#
# I wrote these so I could automate certain tasks on Windows, especially when
# I'm in the middle of a Teams meeting.

# Searches for any Microsoft Teams processes, and returns a list of them if
# found. If no Teams processes are found, `$null` is returned.
function Teams-GetProcesses
{
    # iterate through all processes running on the system. (each process is a
    # System.Diagnostics.Process)
    # https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process
    $procs = @()
    foreach ($proc in Get-Process)
    {
        # convert the process' name to lowercase and compare it with a glob
        # string. If it matches, we'll assume it's one of the Microsoft Teams
        # processes
        $name = $proc.Name.ToLower()
        if ($name -like "*teams*")
        { $procs += @($proc) }
    }

    # if we never found any Teams processes in the above loop, return `$null`
    if ($procs.Length -eq 0)
    { return $null }
    return $procs
}

# Returns `$true` if Microsoft Teams is running, and `$false` otherwise.
function Teams-IsRunning
{
    $procs = Teams-GetProcesses
	if ($procs -ne $null)
	{ return $true }
	return $false
}

# Returns a list of windows that correspond to any/all running Microsoft Teams
# processes.
#
# If there are no Teams processes, or there are no windows, `$null` is
# returned.
function Teams-GetWindows
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [System.Diagnostics.Process[]]$Processes=$null
    )

    # if a list of processes was not provided, retrieve a list
    $procs = $Processes
    if ($Processes -eq $null)
    { $procs = Teams-GetProcesses }
	
	# if there are no processes, return early
	if ($procs -eq $null)
	{ return $null }

	$result = @()
	
	# retrieve all windows for each active process, and add them to one
	# combined list
	foreach ($proc in $procs)
	{
		$windows = Window-GetFromProcessID -ProcessID $proc.Id
		$result += $windows
	}

	# return null if we didn't find any windows
	if ($result.Length -eq 0)
	{ return $null }
	return $result
}

# Returns a list of Microsoft Teams processes that belong to active Teams
# meetings. If no Teams meeting processes are found, `$null` is returned.
function Teams-GetMeetings
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [System.Diagnostics.Process[]]$Processes=$null
    )

    # if a list of processes was not provided, retrieve a list
    $procs = $Processes
    if ($Processes -eq $null)
    { $procs = Teams-GetProcesses }

    # if Teams isn't running, return early
    if ($procs -eq $null)
    { return $null }
	
	# TODO
}

