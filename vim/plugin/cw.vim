" CW = Column Wrap
" A shortcut for setting the column color and text width to my favorite
" width (80 columns). Useful when trying to keep my lines under 80 columns.
"
"   Connor Shugg

" Global variables
let g:ci_cols = '80'
let g:ci_state = 'off'

" Function - does the work.
function! CW(...)
    " if we were given a first argument, parse it as column numbers and force
    " enablement to happen below
    let s:cols = g:ci_cols
    if a:0 >= 1
        let s:cols = a:1
        let g:ci_state = 'off'
    endif

    " based on the global state variable, enable or disable the indicator
    if g:ci_state ==? 'off'
        let g:ci_state = 'on'
        exec 'set colorcolumn=' . s:cols
        exec 'set textwidth=' . s:cols
    else
        let g:ci_state = 'off'
        exec 'set colorcolumn=0'
        exec 'set textwidth=0'
    endif
endfunction

" Command - shortens the use in vim.
"   -nargs=*    <-- specifies it takes zero or more args
command! -nargs=* CW call CW(<f-args>)

