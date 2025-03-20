# This PowerShell script implements functions to retrieve and work with windows
# that are tied to processes.

$script:window_dependencies_initialized = 0

# Helper function used to import DLL dependencies in order to work with
# windows.
function Window-ImportDependencies
{
	# only proceed if this hasn't been initialized yet
	if ($script:window_dependencies_initialized -ne 0)
	{ return; }

	Add-Type @"
	using System;
    using System.Runtime.InteropServices;
    public class Window
    {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowTextLength(IntPtr hWnd);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool IsWindowVisible(IntPtr hWnd);
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
        [DllImport("user32.dll", SetLastError = true)]
		public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
		
		// Returns a list of all active windows.
        public static System.Collections.Generic.List<IntPtr> GetWindows()
		{
            System.Collections.Generic.List<IntPtr> windowHandles = new System.Collections.Generic.List<IntPtr>();
            EnumWindows(delegate (IntPtr hWnd, IntPtr lParam)
			{
                windowHandles.Add(hWnd);
                return true;
            }, IntPtr.Zero);
            return windowHandles;
        }
		
		// Returns the title of the window.
        public static string GetWindowTitle(IntPtr hWnd)
		{
            int length = GetWindowTextLength(hWnd);
            System.Text.StringBuilder sb = new System.Text.StringBuilder(length + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            return sb.ToString();
        }
		
		// Returns the process ID that corresponds to the given window.
        public static int GetWindowProcessID(IntPtr hWnd)
		{
            int processId;
            GetWindowThreadProcessId(hWnd, out processId);
            return processId;
        }
    }
"@
	
	$script:window_dependencies_initialized = 1
}

# Returns a list of all active windows.
function Window-GetAll
{
	Window-ImportDependencies
	
	# iterate through the returned window objects and build a list of
	# PowerShell custom objects to contain the Window information
	$windows = [Window]::GetWindows()
	$result = @()
	foreach ($window in $windows)
	{
		$process_id = [Window]::GetWindowProcessID($window)
		$title = [Window]::GetWindowTitle($window)
		
		# construct the custom object, and add it to the resulting list
		$obj = [PSCustomObject]@{
			Handle = $window
			Title = $title
			ProcessID = $process_id
		}
		$result += @($obj)
	}

	return $result
}

# Retrieves and returns the window that corresponds to the given process ID.
function Window-GetFromProcessID
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [int]$ProcessID
    )
    
	Window-ImportDependencies
	
	# retrieve a list of windows, then iterate through it to find any that
	# match the given process ID
	$windows = Window-GetAll
	$result = @()
	foreach ($window in $windows)
	{
		if ($window.ProcessID -eq $ProcessID)
		{ $result += @($window) }
	}
	return $result
}

