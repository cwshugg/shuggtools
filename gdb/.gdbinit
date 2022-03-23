# My GDB config file. Sourced by GDB at runtime to set my preferences.

# =============================== GDB Options ================================ #
# colored GDB prompt
set prompt \033[90m(\033[36mgdb\033[90m)\033[0m 

# disable the prompt for needing to press keys when long output is scrolling
set pagination off

# disable need for confirmation when making decisions
set confirm off

# turn on logging to save the most previous GDB session to a file in the home
# directory. Useful for saving output and examining later.
set logging overwrite on
set logging file ~/.gdb.log
set logging on

# ============================= Helper Functions ============================= #
# Helper function that sets a breakpoint on exit() and runs the program again,
# causing for infinite runs. This is useful for finding rare cases of deadlock
# or an evasive SIGSEGV.
define run-forever
    break exit
    commands
    run
    end
    run
end

