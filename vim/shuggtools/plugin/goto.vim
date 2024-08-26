" Invokes the Goto plugin code.

command!
    \ -nargs=*
    \ -complete=customlist,goto#arg_completion
    \ Goto
    \ call goto#main(<q-args>)

