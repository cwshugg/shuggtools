" Invokes the Render plugin code.

command!
    \ -nargs=*
    \ -complete=customlist,render#arg_completion
    \ Render
    \ call render#main(<q-args>)

