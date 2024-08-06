" Invokes the DL ('Divider Line') plugin code.

command!
    \ -nargs=*
    \ -complete=customlist,dl#argument_completion
    \ DL
    \ call dl#main(<q-args>)

