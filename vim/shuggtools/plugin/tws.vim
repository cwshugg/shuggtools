" TWS = Trim Whitespace
" This is a small function I found to trim whitespace off the end of every line
" in the current file you're editing in Vim.
" Thanks to this StackExchange post:
" https://vi.stackexchange.com/questions/454/whats-the-simplest-way-to-strip-trailing-whitespace-from-all-lines-in-a-file
"
"   Connor Shugg

" Function - does the actual work.
function! TWS()
    let l:save = winsaveview()  " save window state
    keeppatterns %s/\s\+$//e    " remove all extra whitespace at the end of each line
    call winrestview(l:save)    " restore the old window state
endfunction

" Command - shortens the use in vim.
command! TWS call TWS()

